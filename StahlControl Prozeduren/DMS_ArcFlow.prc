@A+
//===== Business-Control =================================================
//
//  Prozedur    DMS_ArcFlow
//                    OHNE E_R_G
//  Info
//
//              Struktur in ARCFLOW:  !SC\Adressen\Duck\Einkauf
//                                    !SC\Adressen\Duck\Produktion
//                                    !SC\Adressen\Duck\Verkauf
//                                    !SC\Adressen\Duck\Lieferschein
//                                    !SC\Adressen\Duck\VK Rechnungen
//                                    !SC\Adressen\Duck\VK Werkszeugnisse
//                                    !SC\Adressen\Duck\EK Werkszeugnisse

//                                    !SC\Adressen\Einkauf
//                                    !SC\Adressen\Produktion
//                                    !SC\Adressen\Verkauf
//                                    !SC\Adressen\Lieferscheine
//                                    !SC\Adressen\VK Rechnungen
//                                    !SC\Adressen\VK Werkszeugnisse
//                                    !SC\Adressen\EK Werkszeugnisse
//
//  25.10.2007  AI  Erstellung der Prozedur
//  25.06.2012  AI  Ausgabe über Drucker ODER PDF
//  30.07.2012  AI  Datenbanken mit Namen "*TEST*" werden nicht archiviert, Projekt 1326/270
//  25.01.2013  AI  Neu: "CreateMetaData", "WriteMetaData", "CloseMetaData"
//  12.03.2015  AH  PDFs ab jetzt als PDF/A
//  12.05.2016  AH  Neu: "SetSqlPdfName"
//
//  Subprozeduren
//  SUB WriteAdrMetadata(aAdr : int);
//  SUB SetDokName(aTyp : alpha; aNr : int; aAdr : Int; opt aZusatz : alpha (120)) : logic;
//  SUB SetSqlPdfName(aTyp : alpha; aNr  : int; aAdr : Int; opt aZusatz : alpha (120);
//  SUB ShowAdr(aName : alpha);
//  SUB ShowAbm(aName : alpha; aNr : int; aAdr : int);
//  SUB InsertDok(aPath : alpha) : int;
//  SUB SearchDok(aSearchTerm : alpha; aDateBegin : date; aDateEnd : date);
//
//========================================================================
@I:Def_Global

define begin
  sCNVAI(a)     : CNVAI(a,_FmtNumNoGroup)

  sAbmSearchParent      : 0 // durchsucht nur die direkten Untermappen der übergebene Mappe
  sAbmSearchSub         : 1 // durchsucht alle Untermappen der übErxebenen Mappe

  sAFAbmKndPath     : '\!SC\Adressen'           // Pfad zur Mappe Kunden (z.B. \Firma\Kunden)
  sAFAbmTemplate    : 'Vorlage_Adressen'        // Name der Vorlagemappe
end;

// NEU AB 5.6:


//========================================================================
//  WriteAdrMetaData
//
//========================================================================
sub WriteAdrMetadata(aAdr : int);
local begin
  vBuf100 : int;
  vFile   : int;
  vErx    : int;
  vA      : alpha(200);
  vPath   : alpha(1000);
end;
begin
  if (aAdr=0) then RETURN;
  if (Set.DMS.MetaDataPath='') then RETURN;
/**
  vBuf100 # RecBufCreate(100);
  vBuf100->Adr.Nummer # aAdr;
  if (Adr.Nummer<>aAdr) then begin
    vErx # RecRead(vBuf100,1,0);
    if (vErx>_rLocked) then RecBufClear(vBuf100);
  end;
**/
  if (aAdr<>Adr.Nummer) then begin
    vBuf100 # RekSave(100);
    Adr.Nummer # aAdr;
    vErx # RecRead(100,1,0);
  end;

  vPath # Set.DMS.MetadataPath;
  if (StrCut(vPath, StrLen(vPath), 1) <>'\') then
    vPath # vPath + '\';

  // 25.11.2016 AH
  if (Lib_Strings:Strings_Count(vPath,'|')>0) then begin
    if (isTestsystem) then
      vPath # Str_Token(vPath,'|',2)
    else
      vPath # Str_Token(vPath,'|',1);
  end;


  vFile # FSIOpen(vPath+'ADR_'+cnvai(Adr.Nummer, _FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.TXT', _FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile>0) then begin
    vA # Adr.Stichwort + StrChar(13);
    FsiWrite(vFile, vA);
    vA # Adr.Ort + StrChar(13);
    FsiWrite(vFile, vA);
    vA # Adr.Telefon1 + StrChar(13);
    FsiWrite(vFile, vA);
    vA # Adr.Telefax + StrChar(13);
    FsiWrite(vFile, vA);
    vA # Adr.eMail + StrChar(13);
    FsiWrite(vFile, vA);
    vA # aint(Adr.Kundennr) + StrChar(13);
    FsiWrite(vFile, vA);
    vA # aint(Adr.Lieferantennr) + StrChar(13);
    FsiWrite(vFile, vA);
    FsiClose(vFile);
  end;

  if (vBuf100<>0) then RekRestore(vBuf100);
//  RecBufDestroy(vBuf100);
end;


//========================================================================
//  CreateMetaData
//
//========================================================================
sub CreateMetadata(aName : alpha) : int;
local begin
  vFile   : int;
  vPath   : alpha(1000);
end;
begin
  if (Set.DMS.MetaDataPath='') then RETURN 0;

  vPath # Set.DMS.MetadataPath;

  if (StrCut(vPath, StrLen(vPath), 1) <>'\') then
    vPath # vPath + '\';

  // 25.11.2016 AH
  if (Lib_Strings:Strings_Count(vPath,'|')>0) then begin
    if (isTestsystem) then
      vPath # Str_Token(vPath,'|',2)
    else
      vPath # Str_Token(vPath,'|',1);
  end;

  vFile # FSIOpen(vPath+aName+'.TXT', _FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  RETURN vFile;
end;


//========================================================================
//  WriteMetaData
//
//========================================================================
sub WriteMetadata(
  aFile : int;
  aText : alpha);
begin
  if (aFile<=0) then RETURN;
  FsiWrite(aFile, aText);
  FsiWrite(aFile, StrChar(13)+strchar(10));
end;


//========================================================================
//  CloseMetaData
//
//========================================================================
sub CloseMetadata(
  aFile : int);
begin
  if (aFile<=0) then RETURN;
  FsiClose(aFile);
end;


//========================================================================
//  SetDokName
//
//========================================================================
sub SetDokName(
  aTyp        : alpha;
  aNr         : int;
  aAdr        : Int;
  opt aZusatz : alpha (120);
  ) : logic;
local begin
  vParID  : int;
  vAbm    : int;
  vA      : alpha(240);
  vDok    : int;
end;
begin

  if (Set.DMS.AF.ApiPath = '') then // kein ArcFlow
    RETURN false;


  // 30.07.2012 AI: Projekt 1326/270
  if (StrFind( StrCnv( DbaName( _dbaAreaAlias ), _strUpper ) ,'TEST',0 )>0) then RETURN false;


  // DOKUMENTNAME=Typ;Numemr;Adr

  if (aZusatz='') then begin
    if (aAdr<>0) then begin
      vA # aTyp+';'+aint(aNr)+';'+aint(aAdr);
    end
    else begin
      vA # aTyp+';'+aint(aNr);
    end;
  end
  else begin
    vA # aTyp+';'+aZusatz;
  end;

  vDok # form_Job->PrtInfo(_PrtDoc);
  if (vA<>'') then begin

    if (aAdr<>0) then WriteAdrMetaData(aAdr);

    vDok # form_Job->PrtInfo(_PrtDoc);
    vDok->ppname # vA;
//debug('AF DOKNAME : '+vA);
    vDok->ppcustom # '->ArcFlow';
    RETURN true;
  end;

  RETURN false;
end;


//========================================================================
//  SetSqlPDFName
//
//========================================================================
sub SetSqlPdfName(
  aTyp        : alpha;
  aNr         : int;
  aAdr        : Int;
  opt aZusatz : alpha (120);
  ) : logic;
local begin
  vParID  : int;
  vAbm    : int;
  vA      : alpha(240);
  vDok    : int;
end;
begin

  if (Set.DMS.AF.ApiPath = '') or (Set.DMS.PDFPath='') then // kein ArcFlow
    RETURN false;

  //if (StrFind( StrCnv( DbaName( _dbaAreaAlias ), _strUpper ) ,'TESTSYSTEM',0 )>0) then RETURN false;
  if (isTestsystem) then RETURN false;

  // DOKUMENTNAME=Typ;Numemr;Adr
  if (aZusatz='') then begin
    if (aAdr<>0) then begin
      vA # aTyp+';'+aint(aNr)+';'+aint(aAdr);
    end
    else begin
      vA # aTyp+';'+aint(aNr);
    end;
  end
  else begin
    vA # aTyp+';'+aZusatz;
  end;

  if (aAdr<>0) then WriteAdrMetaData(aAdr);

  gPDFDMS     # '->FS';
  gPDFDmsPath # Set.DMS.PDFPath;
  gPDFTitel   # vA;

  RETURN true;
end;


//========================================================================
//  ShowAdr
//
//========================================================================
sub ShowAdr(aName : alpha);
local begin
  vA    : alpha;
  vPara : alpha(1000);
end;
begin

  WriteAdrMetaData(Adr.Nummer);

  vA # Str_ReplaceAll(Adr.STichwort,' ','$$$');
  vA    # StrCnv(vA,_StrToHTML);
  aName # StrCnv(aName,_StrToHTML);
//  aName # StrCnv(Adr.STichwort,_StrToOEM);
//AF_RmtControl.exe /USER=admin /PASSWORD=ares /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show /DOCTYPE=aaa /DOCNO=123 /DOCID=!SC\Adressen\1362\Verkauf
  vPara # '/USER='+Set.DMS.AF.User;
  vPara # vPara + ' /PASSWORD='+Set.DMS.AF.User.PW;
  vPara # vPara + ' /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show';
  vPara # vPara + ' /DOCTYPE="ADR"';
  vPAra # vPara + ' /DOCNO="'+aName+'"';
  vPara # vPara + ' /DOCID="'+vA+'"';
//FsiPathChange('T:\');
//FsiPathChange('T:\LIB\AF_RmtControl\');
  SysExecute(Set.DMS.AF.ApiPath+'\AF_RmtControl.exe',vPara,_ExecMaximized);
//debug(vPara);
end;


//========================================================================
//  ShowAbm
//
//========================================================================
sub ShowAbm(
  aName : alpha;
  aNr   : int;
  aAdr  : int);
local begin
  vPara : alpha(1000);
end;
begin

  WriteAdrMetaData(aAdr);

//  aName # StrCnv(Adr.STichwort,_StrToOEM);
//AF_RmtControl.exe /USER=admin /PASSWORD=ares /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show /DOCTYPE=aaa /DOCNO=123 /DOCID=!SC\Adressen\1362\Verkauf
  vPara # '/USER='+Set.DMS.AF.User;
  vPara # vPara + ' /PASSWORD='+Set.DMS.AF.User.PW;
  vPara # vPara + ' /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show';
  vPara # vPara + ' /DOCTYPE="'+aName+'"';
  vPAra # vPara + ' /DOCNO="'+aint(aNr)+'"';
  vPara # vPara + ' /DOCID="'+aint(aAdr)+'"';
//FsiPathChange('T:\');
//FsiPathChange('T:\LIB\AF_RmtControl\');
//  SysExecute('T:\LIB\AF_RmtControl\AF_RmtControl.exe',vPara,_ExecMaximized);
  SysExecute(Set.DMS.AF.ApiPath+'\AF_RmtControl.exe',vPara,_ExecMaximized);
//debug(vPara);
end;


//========================================================================
//  InserDok
//
//========================================================================
sub InsertDok(
  aPath : alpha
  ) : int;
local begin
  vJob    : int;
  vDok    : int;
  vDev    : int;
  vOK     : logic;
  vA      : alpha;
end;
begin

  vJob # PrtJobOpen('',aPath,_PrtJobOpenRead);
//  if (vJob > 0) and (Set.DMS.AF.SrvName<>'') then begin
  //if (vJob > 0) and (Set.DMS.PDFPath<>'') then begin
  if (vJob > 0) then begin
    vDok # vJob->PrtInfo(_PrtDoc);
    if (vDok->ppcustom='->ArcFlow') then begin

      vA # Str_Token(vDok->ppname,';',3);
      if (vA<>'') then WriteAdrMetaData(cnvia(vA));

      // an ArcFlow-Drucker senden...
      if (Set.DMS.PDFPath='') then begin
        if (Set.DMS.AF.Drucker='') then
          vDev # PrtDeviceOpen('ArcFlow Systemdrucker',_PrtDeviceSystem)
        else
          vDev # PrtDeviceOpen(Set.DMS.AF.Drucker,_PrtDeviceSystem);
        if (vDev>0) then begin
          vOK # y;
          vJob->PrtJobClose(_PrtJobPrint, vDev);// = _ErrOK;
          vDev->PrtDeviceClose();
        end;

      end
      else begin    // als PDF speichern...

        if (StrCut(Set.DMS.PDFPath, StrLen(Set.DMS.PDFPath), 1) <>'\') then
          Set.DMS.PDFPath # Set.DMS.PDFPath + '\';
        vJob->ppPDFFileName         # Set.DMS.PDFPath+vDok->ppname+'.pdf';
        vJob->ppPDFTitle            # 'Stahl-Control';
        vJob->ppPDFAuthor           # 'Stahl-Control';
        vJob->ppPDFCreator          # 'Stahl-Control';
        vJob->ppPDFRestriction      # _pdfDenyNone;
        vJob->ppPDFImageResolution  # 150;
        vJob->ppPDFJPEGQuality      # 100;
        vJob->ppPDFCompression      # _pdfCompressionJPGMax;
        vJob->PPPDFMode             # _PdfModePdfA;   // 12.03.2015
        vJob->PrtJobClose(_prtJobPDF);
      end;

    end
    else vJob->PrtJobClose(_PrtJobCancel);
  end;

//  if (vOK=n) then
//    vJob->PrtJobClose(_PrtJobCancel);

end;


//========================================================================
//  SearchDok
//
//========================================================================
sub SearchDok(
  aSearchTerm  : alpha;
  aDateBegin   : date;
  aDateEnd     : date);
local begin
  vPara : alpha(1000);
end;
begin
//  aName # StrCnv(Adr.STichwort,_StrToOEM);
//AF_RmtControl.exe /USER=admin /PASSWORD=ares /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show /DOCTYPE=aaa /DOCNO=123 /DOCID=!SC\Adressen\1362\Verkauf
  vPara # '/USER='+Set.DMS.AF.User;
  vPara # vPara + ' /PASSWORD='+Set.DMS.AF.User.PW;
  vPara # vPara + ' /ACTION=OPEN_DIALOG /FNC=AFArcSearchRmtCtrlShow';
  vPara # vPara + ' /SEARCHSTR="' + aSearchTerm + '"';
  vPara # vPara + ' /DATEBEGIN='+ cnvAD(aDateBegin);
  vPara # vPara + ' /DATEEND='+ cnvAD(aDateEnd);

//FsiPathChange('T:\');
//FsiPathChange('T:\LIB\AF_RmtControl\');
//  SysExecute('T:\LIB\AF_RmtControl\AF_RmtControl.exe',vPara,_ExecMaximized);
  SysExecute(Set.DMS.AF.ApiPath + '\AF_RmtControl.exe', vPara, _ExecMaximized);
//debug(vPara);
end;




/***** ALLES VERALTET

//========================================================================
//  Init
//
//========================================================================
sub xxxInit() : int;
local begin
  vI  : int;
end;
begin
  if(Set.DMS.AF.ApiPath = '') then // kein ArcFlow
    RETURN -1;

  TODO('FALSCHE ARCFLOW ANSTEUERUNG!');
  RETURN -1;

  if (Set.DMS.AF.SrvName='') then RETURN -1;
  vI # AF_SYS_ArcFlow:InitArcflow();
  if (vI<>0) then TODO('AF-Init-Error:'+cnvai(vI));
  RETURN vI;
end;


//========================================================================
//  Term
//
//========================================================================
sub xxxTerm();
begin
  if(Set.DMS.AF.ApiPath = '') then // kein ArcFlow
    RETURN ;

  TODO('FALSCHE ARCFLOW ANSTEUERUNG!');
  RETURN;
  AF_SYS_ArcFlow:TermArcflow();
end;


//========================================================================
//  GetKndMappenID
//
//========================================================================
sub xxxGetKndMappenID(
  aAdrNr            : int;          // Kundennummer aus Kundendatei
  aKndName          : alpha(250);   // Kundenname aus Kundendatei
  var aKndAbmId     : int;          // Id der Kundenmappe
  var aErrCodeAlpha : alpha;        // Alphanumerischer Fehlercode, sofern ein Fehler auftritt
  opt aAbmKndCreate : logic;        // Mappen anlegen wenn nicht vorhanden
  opt aAbmKndUpdate : logic;        // Mappen updaten falls vorhanden
) : int;
local begin
  tErr            : int;
  tAbmId          : int;
  tAbmName        : alpha(250);
  tAbmParent      : int;
  tAbmDescr       : alpha(250);
  tAbmCloseDate   : date;
  tAbmPartition   : int;
  tAbmType        : int;

  tAbmTmpId       : int;  // ID der Auftragsmappe
  tAbmIdPrev      : int;  // zuvor gelesen Arbeitsmappenid
  tAbmIdKunden    : int;

  tAbmTemplateId  : int;

  tReadOpt        : int;    // Schleifenoption
  tFirstLetter    : alpha;  // Erster Buchstabe eines String
  tAbmKndName     : alpha(200);  // Name der Arbeitsmappe des Kunden

  tAbmSearchPath  : alpha(4096); // Pfad zur Kundenmappe
  tAbmSearchName  : alpha(250);  // gesuchte Mappe
end;
begin
  // Pfad aus den Einstellungen ermitteln
  if (StrCut(sAFAbmKndPath, 1, 1) = '\') then
    tAbmSearchPath  # StrDel(sAFAbmKndPath, 1, 1);
  else
    tAbmSearchPath  # sAFAbmKndPath;

  tAbmIdPrev  # 0;

  // Name der ersten Arbeitsmappe ermitteln
  tAbmSearchName  # AF_SYS_ArcFlow:GetSeparatedContent(tAbmSearchPath, '\', 1);
  WHILE (tAbmSearchName != '') do begin

    // Mappe ermitteln  (als Elternmappe wird tAbmId[MappenId der übErxeordneten Mappe] übErxeben)
    tErr # AF_API:AFAbmReadByName(tAbmSearchName,tAbmIdPrev,sAbmSearchParent,
                               var tAbmId, var tAbmName, var tAbmParent,
                               var tAbmDescr, var tAbmCloseDate, var tAbmPartition, var tAbmType);

    if (tErr != _ErrOK) then begin
      aErrCodeAlpha # 'MAPPE: "' + tAbmSearchName + '" nicht gefunden.';
      RETURN (tErr);
    end;

    tAbmIdPrev # tAbmId

    // Name der nächsten Arbeitsmappe ermitteln
    tAbmSearchPath  # StrDel(tAbmSearchPath, 1, StrLen(tAbmSearchName) + 1);
    tAbmSearchName  # AF_SYS_ArcFlow:GetSeparatedContent(tAbmSearchPath, '\', 1);
  END;

  tAbmIdKunden # tAbmId

  // Vorlagemappe "VOR_Kunden" ermitteln
  tErr # AF_API:AFAbmReadByName(sAFAbmTemplate,0,sAbmSearchParent,
                               var tAbmTemplateId, var tAbmName, var tAbmParent,
                               var tAbmDescr, var tAbmCloseDate, var tAbmPartition, var tAbmType);
  if (tErr != _ErrOK) then begin
    aErrCodeAlpha # 'VORLAGEMAPPE: "' + sAFAbmTemplate + '" nicht gefunden.';
    RETURN (tErr)
  end;

  // Auf Basis vom Kundennamen den Anfangsbuchstaben ermitteln
  tFirstLetter # StrCnv(StrCut(aKndName,1,1), _StrUpper);

/***
  // Mappe tFirstLetter ermitteln
  tErr # AF.API:AFAbmReadByName(tFirstLetter,tAbmIdKunden,sAbmSearchParent,
                             var tAbmId, var tAbmName, var tAbmParent,
                             var tAbmDescr, var tAbmCloseDate, var tAbmPartition, var tAbmType);
  if (tErr != _rOK) then begin
    aErrCodeAlpha # 'BUCHSTABENMAPPE: "'+tFirstLetter+'" nicht gefunden.';

    // ist der Modus eingeschaltet, dass die Mappe angelegt werden soll wenn diese
    // nicht vorhanden ist?
    if (aAbmKndCreate) then begin
      tErr # AF.API:AFAbmCreate(tAbmIdKunden,tFirstLetter,tFirstLetter,var tAbmId);
      if (tErr != _rOK) then begin
        aErrCodeAlpha # 'BUCHSTABENMAPPE: "'+tFirstLetter+'" konnte nicht angelegt werden.';
        RETURN (tErr)
      end;
    end
    else begin
      RETURN (tErr);
    end;
  end;

  tAbmIdPrev # tAbmId;
***/


  // Kundenmappe lesen
  // !Anwender!: tAbmKndName falls nötig auf den gewünschten Namen der Kundenmappe ändern
  // Aktuelle Form: K<KundenID>, wobei der Wert <KundenID> der Funktion übErxeben wird.
  tAbmKndName # ''+sCNVAI(aAdrNr);
  tErr # AF_API:AFAbmReadByName(tAbmKndName,tAbmIdPrev,sAbmSearchParent,
                             var tAbmId, var tAbmName, var tAbmParent,
                             var tAbmDescr, var tAbmCloseDate, var tAbmPartition, var tAbmType);
  if (tErr != _rOK) then begin
    aErrCodeAlpha # 'KUNDENMAPPE: "'+tAbmKndName+'" nicht gefunden.';
    // ist der Modus eingeschaltet, dass die Mappe angelegt werden soll wenn diese
    // nicht vorhanden ist?
    if (aAbmKndCreate) then begin
      tErr # AF_API:AFAbmCreateByTemplate(tAbmIdPrev,tAbmKndName, aKndName , tAbmTemplateId, var tAbmId);
      if (tErr != _rOK) then begin
        aErrCodeAlpha # 'Kundenmappe: "'+tAbmKndName+'" konnte nicht angelegt werden.';
        RETURN (tErr);
      end
      else begin
        aKndAbmId # tAbmId

        // Mappenfelder füllen
        // !Anwender!: Um die Mappenfelder zu füllen wird folgende Funktion ausgeführt:
        // AF.API:AFAbmFldSet(tAbmId, '<Mappenfeldname>', '<Mappenfeldinhalt>');
        // Die Parameter <Mappenfeldname> und <Mappenfeldinhalt> müssen definiert werden.
        // Beide Parameter sind vom Typ Alpha

        aErrCodeAlpha # '';
      end;
    end
    // Mappe soll geupdatet werden
    else if (aAbmKndUpdate) then begin
      // Arbeitsmappe unter der Kundenmappe suchen
      tErr  # AF_API:AFAbmReadByName(tAbmKndName, tAbmIdKunden, sAbmSearchSub, var tAbmId, var tAbmName,
                               var tAbmParent, var tAbmDescr, var tAbmCloseDate, var tAbmPartition,
                               var tAbmType);

      // Immer noch keine Mappe gefunden => Fehler ausgeben
      if (tErr != _rOK) then RETURN (tErr);
    end
    else begin
      RETURN (tErr);
    end;
  end;

  // Soll die Mappe geupdatet werden?
  if (aAbmKndUpdate) then begin
    // Ja => erst die Arbeitsmappe ändern
    AF_API:AFAbmRead(tAbmId,var tAbmName, var tAbmParent,
                             var tAbmDescr, var tAbmCloseDate, var tAbmPartition,
                             var tAbmType);
    tErr # AF_API:AFAbmEdit(tAbmId, tAbmIdPrev, tAbmKndName, aKndName, tAbmCloseDate, tAbmPartition);

    // dann Mappenfelder füllen
//    tErr # AF_API:AFAbmFldSet(tAbmId, 'Name', Adr.Name);
    tErr # AF_API:AFAbmFldSet(tAbmId, 'Telefon', Adr.Telefon1);
    tErr # AF_API:AFAbmFldSet(tAbmId, 'Telefax', "Adr.Telefax");
    tErr # AF_API:AFAbmFldSet(tAbmId, 'eMail', Adr.EMail);
    tErr # AF_API:AFAbmFldSet(tAbmId, 'Ort', Adr.Ort);
    tErr # AF_API:AFAbmFldSet(tAbmId, 'KundenNr.', cnvai(Adr.Kundennr,_fmtnumnogroup));
    tErr # AF_API:AFAbmFldSet(tAbmId, 'LieferantenNr.', cnvai(Adr.Lieferantennr,_fmtnumnogroup));

  END;

  // Id der gefunden Kundenmappe zurückgeben
  aKndAbmId # tAbmId;

  RETURN (_ErrOK)

end;


//========================================================================
//  _FindAbmID
//
//========================================================================
sub xxx_FindAbmID(
  aName   : alpha;
  aBez    : alpha;
  aParID  : int;
  aCreate : logic;
) : int;
local begin
  vAbmID    : int;
  vAbmName  : alpha;
  vParID    : int;
  vBez      : alpha;
  vDat      : date;
  vParti    : int;
  vType     : int;
end;
begin

  Erx # AF_API:AFAbmReadByName(aName, aParID, sAbmSearchParent,
                               var vAbmID, var vAbmName, var vParID,
                               var vBez, var vDat, var vParti, var vType);
  if (Erx <> _ErrOK) then begin
    if (aCreate) then begin
      Erx # AF_API:AFAbmCreate(aParID, aName, aBez , var vAbmID );
      if (Erx != _rOK) then RETURN 0;
    end
    else begin
      RETURN 0;
    end;
  end;

  RETURN vAbmID;
end;


//========================================================================
//  _GotoAbm
//
//========================================================================
sub xxx_GotoAbm(
  aPath   : alpha(1000);
) : int;

local begin
  vToken    : alpha;

  vAbmID    : int;
  vAbmName  : alpha;
  vParID    : int;
  vBez      : alpha;
  vDat      : date;
  vParti    : int;
  vType     : int;
  vParID2   : int;
end;

begin

  vParID # 0;

  // Name der ersten Arbeitsmappe ermitteln
  vToken  # AF_SYS_ArcFlow:GetSeparatedContent(aPath, '\', 1);
  WHILE (vToken != '') do begin

    // Mappe ermitteln  (als Elternmappe wird tAbmId[MappenId der übErxeordneten Mappe] übErxeben)
    Erx # AF_API:AFAbmReadByName(vToken, vParID, sAbmSearchParent,
                               var vAbmID, var vAbmName, var vParID2,
                               var vBez, var vDat, var vParti, var vType);
    if (Erx != _ErrOK) then RETURN 0;

    vParID # vAbmID;

    // Name der nächsten Arbeitsmappe ermitteln
    aPath # StrDel(aPath, 1, StrLen(vToken) + 1);
    vToken  # AF_SYS_ArcFlow:GetSeparatedContent(aPath, '\', 1);
  END;

  RETURN vAbmID;
end;


//========================================================================
//  _ImportScans
//
//========================================================================
sub xxx_ImportScans(
  aAbm  : alpha;
  aNr   : Int;
  aPath : alpha
  ) : logic;

local begin
  vParID  : int;
  vAbm    : int;
  vArchiv : alpha;
end;

begin

  // Struktur erstmal durchlaufen...
  vParID # xxx_GotoAbm(aAbm);
  if (vParID<=0) then RETURN false;

  // finale Mappe suchen/erzeugen...
  vAbm # xxx_FindAbmID(cnvai(aNr,_FmtNumNoGroup),cnvai(aNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8), vParID, y);
  if (vAbm<=0) then RETURN false;

  // neues Archiv anlegen und Scans importieren...
  Erx # AF_API:AFScanSave(var vArchiv, aPath, y);
  if (Erx<>0) then RETURN false;

  // Archiv in Mappe stecken...
  Erx # AF_API:AFArcAbmAdd(vArchiv, vAbm);
  if (Erx<>0) then RETURN false;

  RETURN true;
end;


//========================================================================
//  ScanLauf
//
//========================================================================
sub xxxScanLauf() : alpha;
local begin
  vTest   : logic;

  vErx    : int;
  vMax    : int;
  vPath   : alpha;
  vPath2  : alpha;
  vFile   : alpha;
  vOK     : logic;
  vHdl    : int;
  vA      : alpha;
  vDokNr  : int;
  vBCMax  : int;
  vBCNr   : int;
  vBC     : alpha;
  vOrd1   : alpha;
  vOrd2   : int;
  vNr     : int;

  vOrd1B  : alpha;
  vOrd2B  : int;

  vOrdAnz : int;
end;

begin

/* ABLAUF:
  - Scanner-DLL einladen
  - Scanner starten -> liefert Seitenzahl
  - OCR starten -> generiert TXTs + BRCs
  - Scanner-DLL entladen
  - Seiten loopen
    - BRC interpretieren
    - bei BRC Wechsel Import nach ArcFlow starten
      - Orderstruktur druchlaufen (!SC\Einkauf\...)
      - finalen Ordner finden/anlegen (...\12345)
      - Files dort in neues Archiv packen
    - zusammenhängende Dateien in Unterverzeichnis kopieren
*/

  vPath   # 'C:\ScanTemp';
  vPath2  # vPath+'\import';
  vTest   # false;

  // ggf. Verzeichnisse anlegen
  FsiPathCreate(vPath);
  FsiPathCreate(vPath2);
  Lib_FileIO:EmptyDir(vPath2);
  if (vTest=n) then begin
    Lib_FileIO:EmptyDir(vPath);
  end;

  // SCANNER *****************************************************
  if (vTest) then begin
    vMax # 5;
  end
  else begin
    vMax # 0;
    // DLL einbinden...
    vA # UserInfo(_UserSysName,  CnvIA(UserInfo(_UserCurrent)));
    Erx # AF_API:AFScanDllLoad(vA);
    if (Erx<>_errOK) then RETURN ('DLL-Load : '+cnvai(Erx));

    // Scanner starten...
    Erx # AF_API:AFScanStart(vPath, gFrmMain, var vMax);
    if (Erx<>_errOK) then begin
      vErx # AF_API:AFScanDllUnload();
      //if (vErx<>_errOK) then RETURN ('DLL-Unload : '+cnvai(vErx));
      RETURN ('Scan-Service : '+cnvai(Erx));
    end;

    // Texterkennung starten...
    AF_API:AFRecognizeScanPages(vPath, '.TIF|.PNG', gFrmMain, y);   // Barcodeerkennung
/***
    JPG=Preview, TIG=Scan, BRC=Barkode, TXT=Volltext

    BARCODECOUNT: <Anzahl Barcodes>
  <Nummer>-[<PosX>/<PosY>]-[<PosX>/<PosY>]<Wert>
  ...
    Die Anzahl der gefundenen Barcodes wird 4-stellig mit führenden Nullen angegeben.
    Die untere Zeile wiederholt sich für jeden erkannten Barcode. Die Angabe der
    <Nummer> erfolgt 4-stellig mit führenden Nullen. Die beiden <PosX>/<PosY> Angaben
    beziehen sich auf die Position des Barcodes auf der Seite. Sie enthalten den Abstand
    der linken oberen und der rechten unteren Ecke des Barcodes vom Anfang der Seite aus.
    Die Angaben sind 5-stellig mit führenden Nullen in Pixel. Der eigentliche Wert des
    Barcodes steht am Ende der Zeile.
    Beispiel:
    BARCODECOUNT: 0002
    0001-[00050/00100]-[00450/00400]4002221002319
    0002-[00050/00420]-[00450/00720]4002221002531
  ****/

    // Unload...
    Erx # AF_API:AFScanDllUnload();
    if (Erx<>_errOK) then RETURN ('DLL-Unload : '+cnvai(Erx));
  end;  // TEST


  // FILES BEARBEITEN ***********************************************
  vOK # y;
  FOR vDokNr # 1 loop inc(vDokNr) WHILE ((vDokNr<=vMax) and (vOK)) do begin

    // open Barcodefile...
    vFile # vPath+'\'+'AFS'+cnvai(vDokNr,_FmtNumNoGroup|_FmtNumLeadZero,0,6)+'.BRC';
    vHdl # FsiOpen(vFile,_FsiStdRead);
    if (vHdl<=0) then begin
      vOK # n;
      BREAK;
    end;

    FsiMark(vHdl,10);
    FsiRead(vHdl,vA);
    if (StrCut(vA,1,13)='BARCODECOUNT:') then begin
      vBCMax # cnvia(StrCut(vA,14,4));
      // alle BCs loopen...
      FOR vBCNr # 1 loop inc(vBCNr) WHILE (vBCNr<=vBCMax) do begin
        FsiRead(vHdl,vA);
        vBC # StrCut(vA,33,20);
        vA  # StrCut(vBC,1,3);
        vNr # Cnvia(StrCut(vBC,4,10));

        case vA of
          'SCA' : begin
            vOrd1 # '!SC\Verkauf';
            vOrd2 # vNr;
          end;
          'SCE' : begin
            vOrd1 # '!SC\Einkauf';
            vOrd2 # vNr;
          end;
        end;

      END;  // alle BCs loop
    end;  // Barcodedatei ok
    FsiClose(vHdl);


    // Ordnerwechsel??
    if (vOrd1B<>'') and
      ((vOrd2<>vOrd2B) or (vOrd1<>vOrd1B)) then begin
      // IMPORTIEREN...
      if (_ImportScans(vOrd1B, vOrd2B, vPath2)=false) then
        RETURN ('Import nach ArcFlow (teilweise?) fehlgeschalgen!');
      vOrdAnz # vOrdAnz + 1;
      Lib_FileIO:EmptyDir(vPath2);
    end;

    // Vorgänger merken...
    vOrd1B # vOrd1;
    vOrd2B # vOrd2;

    // Zielordner angegeben...
    if (vOrd1<>'') then begin
      vFile # 'AFP'+cnvai(vDokNr,_FmtNumNoGroup|_FmtNumLeadZero,0,6)+'.jpg';
      Lib_FileIO:FsiCopy(vPath+'\'+vFile, vPath2+'\'+vFile,n);
      vFile # 'AFS'+cnvai(vDokNr,_FmtNumNoGroup|_FmtNumLeadZero,0,6)+'.tif';
      Lib_FileIO:FsiCopy(vPath+'\'+vFile, vPath2+'\'+vFile,n);
      vFile # 'AFS'+cnvai(vDokNr,_FmtNumNoGroup|_FmtNumLeadZero,0,6)+'.TXT';
      Lib_FileIO:FsiCopy(vPath+'\'+vFile, vPath2+'\'+vFile,n);
    end;

  END;  // loop doks...

  if (vOrd1B<>'') then begin
    // IMPORTIEREN...
    if (_ImportScans(vOrd1B, vOrd2B, vPath2)=false) then
      RETURN ('Import nach ArcFlow (teilweise?) fehlgeschalgen!');
    vOrdAnz # vOrdAnz + 1;
    Lib_FileIO:EmptyDir(vPath2);
  end;


  Msg(99,'ArcFlow-Import erfolgreich!%CR%'+cnvai(vmax)+' Seiten in '+cnvai(vOrdAnz)+' Archive gespeichert.',_WinIcoInformation,_WinDialogOk,1);

  RETURN '';
end;


//========================================================================
//  SetDokName
//
//========================================================================
sub xxxSetDokName(
  aOrd  : alpha;
  aName : alpha;
  aNr   : int;
  ) : logic;
local begin
  vParID  : int;
  vAbm    : int;
  vA      : alpha;
  vDok    : int;
end;
begin
//debug('AF init...');
  if (xxxInit()<>0) then RETURN false;
//debug('AF init ok');
  // Struktur erstmal durchlaufen...
  vParID # _GotoAbm(aOrd);//'!SC\Verkauf');
  if (vParID>0) then begin
    // finale Mappe suchen/erzeugen...
    vAbm # _FindAbmID(cnvai(aNr,_FmtNumNoGroup),cnvai(aNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8), vParID, y);
    if (vAbm>0) then begin
      vA  # 'A__'+CNVAI(vAbm,_FmtNumNoGroup|_FmtNumLeadZero,0,7)+aName+' '+cnvai(aNr,_FmtNumNoGroup);
    end;
  end;
  xxxTerm();

  vDok # form_Job->PrtInfo(_PrtDoc);
  if (vA<>'') then begin
    vDok # form_Job->PrtInfo(_PrtDoc);
    vDok->ppname # vA;
debug('set AF DOKNAME : '+vA);
    vDok->ppcustom # '->ArcFlow';
    RETURN true;
  end;

  RETURN false;
end;


//========================================================================
//  OpenAbm
//
//========================================================================
sub xxxOpenAbm(aName : alpha);
local begin
  vPara : alpha(1000);
end;
begin
//AF_RmtControl.exe /USER=admin /PASSWORD=ares /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show /DOCTYPE=aaa /DOCNO=123 /DOCID=!SC\Adressen\1362\Verkauf
  vPara # '/USER='+Set.DMS.AF.User;
  vPara # vPara + ' /PASSWORD='+Set.DMS.AF.User.PW;
  vPara # vPara + ' /ACTION=OPEN_DIALOG /FNC=AFArcFileShowByScript /SCRIPT=SC_Abm_Show';
  vPara # vPara + ' /DOCTYPE=3';
  vPAra # vPara + ' /DOCNO='+aint(adr.Nummer);
  vPara # vPara + ' /DOCID='+aName;
//FsiPathChange('T:\');
//FsiPathChange('T:\LIB\AF_RmtControl\');
//  SysExecute('T:\LIB\AF_RmtControl\AF_RmtControl.exe',vPara,_ExecMaximized);
  SysExecute(Set.DMS.AF.ApiPath+'\AF_RmtControl.exe',vPara,_ExecMaximized);
end;


//========================================================================
//  Show
//
//========================================================================
sub Show(
  aOrd  : alpha;
  aNr   : int;
  );
local begin
  vParID  : int;
  vAbm    : int;
end;
begin

  Erx # xxxInit();
//if (gUsername='AH') then debug('a: Erx');
  if (Erx<>0) then RETURN;

//if (gUsername='AH') then debug('b');

  if (Strfind(aOrd,'%ADR%',0)>0) then begin
    aOrd # Str_ReplaceAll(aOrd, '%ADR%', cnvai(Adr.Nummer,_FmtNumNoGroup));
  end;
//if (gUsername='AH') then debug('c');

  // Struktur erstmal durchlaufen...
  vParID # _GotoAbm(aOrd);//'!SC\Verkauf');
  if (vParID>0) then begin

    if (aNr<>0) then begin
      // finale Mappe suchen/erzeugen...
      vAbm # _FindAbmID(cnvai(aNr,_FmtNumNoGroup),cnvai(aNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8), vParID, y);
    end
    else begin
      vAbm # vParID;
    end;
    if (vAbm>0) then begin
      AF_MFrm_ArcFlow(gFrmMain, vAbm);
    end;
  end;
  xxxTerm();

end;


//================================================================================================================================================
//================================================================================================================================================
//================================================================================================================================================
//================================================================================================================================================
//================================================================================================================================================
//================================================================================================================================================

****/

//========================================================================