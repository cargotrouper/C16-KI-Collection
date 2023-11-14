@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Dokumente
//                          OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  01.08.2012  AI  "PrintForm" kann Ausgabedateinamen verarbeiten
//  27.05.2013  ST  Import von Externen PDF Dokumenten in Dokuablage hinzugefügt
//  10.08.2013  AH  PDFCreator
//  10.02.2014  AH  Externe DokCA1
//  08.04.2016  AH  Listen können über Formular-Menüpunkt gestartet werden
//  15.08.2016  ST  Aufruf "ShowPDF" als Form oder Report erweitert
//  09.06.2017  ST  Kein Fensterfrefresh für SOA User bei Direktdruck
//  18.10.2018  AH  @-Userlogik für Formularname
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  05.12.2018  AH  BugFix: "GetDokID" hat nicht den richtigen Namen genutzt
//  18.12.2108  ST  Druckgenerierung für SOA aussschließlich über JOB Server möglich
//  26.02.2019  AH  Kopienanzahl auch aus Text
//  17.04.2019  AH  APPOFF nicht mehr bei SQL (Problem z.B: bei AufFM und MsgBox als User!!!!)
//  13.11.2020  AH  SaveDokPdf
//  27.07.2021  AH  ERX
//  10.09.2021  ST  Neu: Formulardruck unterstützt Aufruf für mehrere Keys; Müssen in Formzlarproz. auseinandergenommen werden
//  09.11.2021  ST  Fix: ImportPdf EmailAdressen auf 1000 Zeichen erhöht
//  10.11.2021  ST  Edit: SC + Arcflow Archivierung per Installname
//  19.05.2022  DS  aFilename mit an AFX 'DMS.Insert' übergeben in sub ImportPDF() (erforderlich für EcoDMS Anbindung)
//  14.06.2022  DS  Bugfix: Endlosschleife beim Löschen der Job-Datei
//  27.09.2022  ST  Edit: Sonderlösung MWH Importjob importiert in ArcFlow und SC
//  2022-10-24  DS  CheckForm ignoriert BSC/EcoDMS-spezifisch ein leeres Feld Frm.Prozedur
//  2023-05-03  DS  Nur wenn das Speichern einer Dokumentenart laut 912 aktiv ist, wird nach dem bereits gedruckten Dokument gefragt (denn ohne Speichern kann es beliebig veraltet sein)
//
//
//  Subprozeduren
//    SUB GetDokID(aBereich : int; aFormular : alpha; aName : alpha) : int
//    SUB KillJob();
//    SUB ImportPDF(aBereich : int; aFormular : alpha; aName : alpha; aNummer : int; aSprache : alpha)
//    SUB ImportJOB(aBereich : int; aFormular : alpha; aName : alpha; aNummer : int; aSprache : alpha; aFax: alpha; aEMail : alpha)
//
//    SUB GetLastDok(aBereich : int; aKuerzel : alpha; aName : alpha; aSprache : alpha) : int;
//    SUB ShowDok(aNummer : int) : logic
//    SUB SaveDokPdf(aNummer : int; aPath : alpha(4000)) : logic
//    SUB CheckForm(aBereich : int; aFormular : alpha) : int
//    SUB AddDokumentToJobServerQueue(opt aSkriptNr : int)
//    SUB PrintJob(opt aPara : alpha) : logic
//    SUB PrintForm(aBereich : int; aFormular : alpha aCheck : logic; aFileName : alpha) : logic
//    SUB ClearThisDoc() : logic
//    SUB ClearAllDocs() : logic
//
//========================================================================
@I:Def_Global


define begin
  Log(a)      :  Lib_Soa:Dbg(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);
end

//========================================================================
// RekReadFrm
//========================================================================
sub RekReadFrm(
  aBereich  : int;
  aFormular : alpha) : int
local begin
  Erx     : int;
  vTxt    : int;
  vI      : int;
  vA,vB   : alpha(1000);
end;
begin
  // spezielles Userfomular?
  Frm.Bereich # aBereich;
  Frm.Name    # StrCut(aFormular + '@'+gUsername,1,32);
  Erx # RecRead(912,1,0);
  if (erx<=_rLocked) then begin
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  Frm.Bereich # aBereich;
  Frm.Name    # aFormular;
  Erx # RecRead(912,1,0);
  if (Erx>_rLocked) then begin
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  vTxt # TextOpen(20);
  Erx # TextRead(vTxt, '~912.'+CnvAI(RecInfo(912,_RecID),_FmtNumLeadZero | _FmtNumNoGroup,0,8), 0);
  if (Erx=_rOK) then begin
    vI # TextSearch(vTxt, 1, 1, _TextSearchCI, '@'+gUsername+'@');
    if (vI>0) then begin
       vB # TextLineRead(vTxt, vI, 0); // y;y;Epson;@AH@ST@MK@
      vA # Str_Token(vB,';',1);
      Frm.VorschauYN # (vA='y') or (vA='Y') or (vA='J') or (vA='j') or (vA='1');
      vA # Str_Token(vB,';',2);
      Frm.DirektdruckYN # (vA='y') or (vA='Y') or (vA='J') or (vA='j') or (vA='1');
      Frm.Drucker # StrCut(Str_Token(vB,';',3),1,128);
      // 26.02.2019 AH: Kopien auch
      vA # Str_Token(vB,';',5);
      if (cnvia(vA)>0) then Frm.Kopien # cnvia(vA);
    end;
  end;
  TextClose(vTxt);

  RETURN _rOK;
end;


//========================================================================
//  GetDokID
//          Prüft, ob es ein Formular "Bereich, Formular, Name" schon gibt die
//          interne Dokumentnummer zurück (oder NULL)
//========================================================================
Sub GetDokID
(
  aBereich  : int;
  aFormular : alpha;
  aName     : alpha;
) : int
local begin
  vFilter : int;
  vNr     : int;
end;
begin
  If (RekReadFrm(aBereich, aFormular) > _rLocked) then RETURN 0;

  RecBufClear(915);
  vFilter # RecFilterCreate(915,1);
  RecFilterAdd(vFilter,1,_FltAnd,_FltEq,  Frm.Bereich);
  RecFilterAdd(vFilter,2,_FltAnd,_FltEq,  "Frm.Kürzel");
//  RecFilterAdd(vFilter,3,_FltAnd,_FltEq,  Frm.Name);    // 05.12.2018
  RecFilterAdd(vFilter,3,_FltAnd,_FltEq,  aName);

  If (RecRead(915,1,_RecLast,vFilter)<> _rNoKey) then
    vNr # Dok.Nummer;
  RecFilterDestroy(vFilter);
  RETURN vNr;
end;


//========================================================================
//  KillJob
//          löscht einen temp. JOB
//========================================================================
sub KillJob()
local begin
  vPath   : alpha;
  vErr    : int;
end;
begin
  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPath   # vPath+'tmp'+AInt(gUserID)+'.Job';

  vErr    # FsiDelete(vPath); // JobDatei löschen
end;



//========================================================================
//  ImportPDF
//    Importiert ein externes Dokument, legt es in der Stahl-Control
//    Dokumentenablage ab.
//    01.04.2021 AH: kann auch doppelt Archivieren d.h. ArcFlow + Eigen
//========================================================================
sub ImportPDF(
  aFilename : alpha;
  aBereich  : int;
  aFormular : alpha;
  aName     : alpha;
  aSprache  : alpha;
  aFax      : alpha;
  aEmail    : alpha(1000);
  aNoDel    : logic;
  )
local begin
  vA          : alpha(4000);
  vIndex      : int;
  vNummer     : int;
  vDir        : int;
  vSubDir     : int;
  vDatei      : int;
  vErr        : int;
  vDokNr      : int;
  vJob        : int;
  vDok        : int;
  vDBAConnect : int;
  vPara       : int;
  vInEigen    : logic;
end;
begin

  // Ankerfunktion?
  vA # aint(aBereich)+'|'+aFormular+'|'+aName+'|'+aSprache+'|'+aFax+'|'+aEMail+'|'+aFilename;
  if (RunAFX('DMS.Insert',vA)<0) then RETURN;
//debugx(vA + '    gPdfDMS:'+gPDFDMS+'   aFile:'+aFilename);

  if (aBereich=0) then RETURN;

  vInEigen # Frm.SpeichernYN;
// pdfCREATOR
  // ARCFLOW aktiv?
  if (gPDFDMS='->ArcFlow') then begin
    gPDFDMS # '';
    // ARCFLOW
    DMS_ArcFlow:InsertDok(aFilename);
    Frm.SpeichernYN # n;    // NICHT in eigenes System speichern
    vInEigen # false;
    
/*
    if (Set.Installname='MWH') then
      vInEigen # true;
*/
      
  end
  else if (gPDFDMS='->FS') then begin
    gPDFDMS # '';
//debugx('nach '+gPDFDMSPath + ''+ gPDFTitel+'.PDF');
    Lib_FileIO:FsiCopy(aFilename, gPDFDMSPath + ''+ gPDFTitel+'.PDF', false);
    Frm.SpeichernYN # n;    // NICHT in eigenes System speichern
    vInEigen # false;
  end
  else begin
    vInEigen # y;
  end;
  
  // ------------------------------------------------------
  //  Sonderbehandlung für SC + Arcflow Archivierung
  // ------------------------------------------------------
  case Set.Installname of
    'MWH',
    'HWE':  vInEigen # true;
  end;
  
  if (vInEigen) then begin

    If (GetDokID(Frm.Bereich,Frm.Name,aName) > 0) then
      vIndex # Dok.Index + 1;
    else
      vIndex # 1;

    If (aSprache = '') then aSprache # Set.Sprache1.Kurz;
    If (aSprache = '') then aSprache # 'D';
    aName # aName + ':' + aSprache;

    // Eintrag in Dokumentmanagement vornehmen
    REPEAT
      vDokNr # Lib_Nummern:ReadNummer('Dokumente');
      if (vDokNr=0) then begin
        TODO('DOKUMENT NUMMER FREIGEBEN!!!');
      end;
    UNTIL (vDokNr<>0);
    Lib_Nummern:SaveNummer();

    RecBufClear(915);
    Dok.Bereich       # aBereich;
    "Dok.Kürzel"      # "Frm.Kürzel";
    Dok.FormularName  # aName;
    Dok.Index         # vIndex;
    Dok.Sprache       # aSprache;
    Dok.Nummer        # vDokNr;
    Dok.Datum         # today;
    Dok.Zeit          # Now;
    Dok.User          # gUserName;
    Dok.FAX           # aFax;
    Dok.EMail         # StrCut(aEMail,1,80);
    WHILE RekInsert(915,0,'') <> _rOk do Inc(Dok.Index);

    if (gDBAConnect=3) then vPara # _BinDba3
    else if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then begin
      vPara # _BinDba3;
      vDBAConnect # 3;
    end;

    // PDF Datei in Blob importieren
    vDir    # BinDirOpen(0,'Dokumente',_BinCreate | vPara);
    vSubDir # BinDirOpen(vDir,"Dok.Kürzel",_BinCreate | vPara);
    vDatei  # BinOpen(vSubDir,AInt(Dok.Nummer)+'.pdf',_BinCreate | _BinLock | vPara)
    vErr    # vDatei->BinImport(aFilename,4);

    vSubDir->BinClose();
    vDir->BinClose();
    vDatei->BinClose();

    if (vDBAConnect<>0) then begin
      try begin
        ErrTryIgnore(_ErrValueInvalid);
        DbaDisconnect(vDBAConnect);
      end;
    end;
  end;

  if (aNoDel) then RETURN;

  //  14.06.2022  DS  Bugfix: Endlosschleife beim Löschen der Job-Datei
  REPEAT
    vErr # FsiDelete(aFilename); // JobDatei löschen
    if (vErr <> _ErrOK and vErr <> _ErrFsiNoFile) then Winsleep(500);
  UNTIL (vErr = _ErrOK or vErr = _ErrFsiNoFile);
  
end;


//========================================================================
//  ImportJOB
//          speichert einen JOB als Dokument-BLOB ab
//========================================================================
sub ImportJOB(
  aBereich  : int;
  aFormular : alpha;
  aName     : alpha;
  aSprache  : alpha;
  aFax      : alpha;
  aEmail    : alpha;
)
local begin
  vA          : alpha(1000);
  vIndex      : int;
  vNummer     : int;
  vPath       : alpha;
  vDir        : int;
  vSubDir     : int;
  vDatei      : int;
  vErr        : int;
  vDokNr      : int;
  vJob        : int;
  vDok        : int;
  vPara       : int;
  vDBAConnect : int;
end;
begin

  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPath   # vPath+'tmp'+AInt(gUserID)+'.Job';
/**
  // PDF Import?
  if (false) then begin
    vPath # Set.Druckerpfad;
    If (vPath = '') then vPath # 'c:\';
    vPath   # vPath+'tmp_'+AInt(gUserID)+'.pdf';

    ImportDok(vPath,aBereich,aFormular,aName,aSprache,aFax,aEmail);
    RETURN;
  end;
**/


  // Ankerfunktion?
  vA # aint(aBereich)+'|'+aFormular+'|'+aName+'|'+aSprache+'|'+aFax+'|'+aEMail;
  if (RunAFX('DMS.Insert',vA)<0) then RETURN;


  // DMS aktiv?
//debug('B');
  vJob # PrtJobOpen('',vPath,_PrtJobOpenRead);
  if (vJob > 0) then begin
//debug('C');
    vDok # vJob->PrtInfo(_PrtDoc);
    if (vDok->wpcustom='->ArcFlow') then begin
//debug('D');
      vJob->PrtJobClose(_PrtJobCancel);
      // ARCFLOW
      DMS_ArcFlow:InsertDok(vPath);
      if (Set.Installname<>'BCS') then begin
        Frm.SpeichernYN # n;    // NICHT in eigenes System speichern
      
        case Set.Installname of
          'MWH',
          'HWE':  Frm.SpeichernYN # true;
        end;
        
      end;
    end
    else begin
      vJob->PrtJobClose(_PrtJobCancel);
    end;
  end;



  if (aBereich=0) then RETURN;

  // KEINE Archivierung??
  if ("Frm.SpeichernYN"=n) then begin
    REPEAT
      vIndex # vIndex + 1;
      vErr # FsiDelete(vPath); // JobDatei löschen
      if (vErr<>_ErrOK) then Winsleep(500);
      if (vIndex=10) then begin
        Msg(999999,'Datei '+vPath+' konnte NICHT gelöscht werden!!!',0,0,0);
        RETURN;
      end;
    UNTIL (vErr=_ErrOK);
    RETURN;
  end;


  If (GetDokID(Frm.Bereich,Frm.Name,aName) > 0) then
    vIndex # Dok.Index + 1;
  else
    vIndex # 1;

  If (aSprache = '') then aSprache # Set.Sprache1.Kurz;
  If (aSprache = '') then aSprache # 'D';
  aName # aName + ':' + aSprache;

  // Eintrag in Dokumentmanagement vornehmen
  REPEAT
    vDokNr # Lib_Nummern:ReadNummer('Dokumente');
    if (vDokNr=0) then begin
      TODO('DOKUMENT NUMMER FREIGEBEN!!!');
    end;
  UNTIL (vDokNr<>0);
  Lib_Nummern:SaveNummer();
//debug('D');

  RecBufClear(915);
  Dok.Bereich       # aBereich;
  "Dok.Kürzel"      # "Frm.Kürzel";
  Dok.FormularName  # aName;
  Dok.Index         # vIndex;
  Dok.Sprache       # aSprache;
  Dok.Nummer        # vDokNr;
  Dok.Datum         # today;
  Dok.Zeit          # Now;
  Dok.User          # gUserName;
  Dok.FAX           # aFax;
  Dok.EMail         # aEMail;
  WHILE RekInsert(915,0,'') <> _rOk do Inc(Dok.Index);


  if (gDBAConnect=3) then vPara # _BinDba3
  else if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then begin
    vPara # _BinDba3;
    vDBAConnect # 3;
  end;


  // JobDatei in Blob importieren
  vDir    # BinDirOpen(0,'Dokumente',_BinCreate | vPara);
  vSubDir # BinDirOpen(vDir,"Dok.Kürzel",_BinCreate | vPara );
  vDatei  # BinOpen(vSubDir,AInt(Dok.Nummer)+'.Job',_BinCreate | _BinLock | vPara)
  vErr    # vDatei->BinImport(vPath,4);

  vSubDir->BinClose();
  vDir->BinClose();
  vDatei->BinClose();

  if (vDBAConnect<>0) then begin
    try begin
      ErrTryIgnore(_ErrValueInvalid);
      DbaDisconnect(vDBAConnect);
    end;
  end;

  REPEAT
    vErr # FsiDelete(vPath); // JobDatei löschen
    if (vErr<>_ErrOK) then Winsleep(500);
  UNTIL (vErr=_ErrOK);
end;


//========================================================================
// GetLastDok
//
//========================================================================
sub GetLastDok
(
  aBereich  : int;
  aKuerzel  : alpha;
  aName     : alpha;
  aSprache  : alpha;
) : int;
local begin
  vDok    : int;
  vFilter : int;
  vRead   : int;
end;
begin
  RecBufClear(915);
  vFilter # RecFilterCreate(915,1);
  RecFilterAdd(vFilter,1,_FltAnd,_FltEq,aBereich);
  RecFilterAdd(vFilter,2,_FltAnd,_FltEq,aKuerzel);
  RecFilterAdd(vFilter,3,_FltAnd,_FltEq,aName);
  If RecRead(915,1,_RecFirst,vFilter) = _rNoRec then return 0;
  vRead # _RecLast;
  while (RecRead(915,1,vRead,vFilter) <= _rLocked) and (aSprache <> '') and (aSprache <> Dok.Sprache) do
    vRead # _RecPrev;
  If (aSprache = '') or (aSprache = Dok.Sprache) then vDok # Dok.Nummer;
  RecFilterDestroy(vFilter);
  Return vDok;
end;


//========================================================================
// Showdok
//
//========================================================================
sub ShowDok(
  aNummer         : int;
  opt aNurIntern  : logic;
) : logic
Local begin
  vPath   : alpha;
  vPath2  : alpha(1000);
  vPathOhneExt : alpha;

  vPrtJob   : int;
  vDok      : int;
  vDir      : int;
  vDatei    : int;
  vErr      : int;
  vOK       : logic;
  vZList    : int;
  vA        : alpha;
  vI        : int;
  vName     : alpha;

  vDokname  : alpha;
  vPDF      : logic;
  vExtPath  : alpha(1000);

  vExternal : logic;
  vPara     : int;
end;
begin

  // Ankerfunktion?
  vA # aint(aNummer);
  if (RunAFX('DMS.Show', vA) < 0) then
  begin
    return true;
  end


  vZList # gZLList;
  RecBufClear(915);
  Dok.Nummer # aNummer;
  If (RecRead(915,2,0) > _rLocked) or (aNummer = 0) then return False;
  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPath   # vPath+"Dok.Kürzel"+'_'+AInt(Dok.Nummer)+'.Job';

  if (aNurIntern=false) then begin
    // Erst NUR intern...
    vok # ShowDok(aNummer, true);
    if (vOk) then RETURN true;

//debug('Check extern');
    // EXTERNAL...
    if (gDBAConnect=0) then begin
      if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vExternal # true;
    end
    else begin
      vExternal # true;
    end;
    if (vExternal) then begin
      vPara # _BinDba3;
    end;
  end
  else begin
    // ist intern
//debug('Check intern');
  end;

  vDir    # BinDirOpen(0,'Dokumente\'+"Dok.Kürzel",_BinCreate | vPara)
  if (vDir<0) then begin
    If (vExternal) then DbaDisconnect(3);
    RETURN false;  // neu seit April
  end;

   // PDF anstatt JOB?
  vPDF # false;
  vPath2 # Set.DruckerPfad;
  if (vPath2='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath2 # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPathOhneExt # vPath2 + "Dok.Kürzel" + '_'+AInt(Dok.Nummer);
  if (BinOpen(vDir,AInt(Dok.Nummer)+'.Job') < 0) then begin
    vDokname  # AInt(Dok.Nummer)+'.pdf';
    vExtPath  # vPathOhneExt + '.pdf';
    vPDF    # true;
  end
  else begin
    vDokname # AInt(Dok.Nummer)+'.Job';
  end;


  // StahlControl-Vorschau...
  if ((StrFind(Set.Module,'P',0)>0) or (gUsername='DRUCKTEST')) then begin

    if (vExternal) then
      vPath # '>3\Dokumente\'+"Dok.Kürzel"+'\'+vDokname
    else
      vPath # '>0\Dokumente\'+"Dok.Kürzel"+'\'+vDokname;

    vA # Str_Token(Dok.FormularName,':',1);
    vI # cnvia(vA);
    vName # "Dok.Kürzel"+'_'+aInt(vI);

    if (vPDF) then begin
      // PDF aus Blob extrahieren und PDF anzeigen
      TRY begin
        ErrTryCatch(_ErrHdlInvalid, y);
        vDatei  # BinOpen(vDir, vDokname, vPara);
      end;
      if (ErrGet()<>_rOK) or (vDatei<0) then begin
//debugx('nix da');
        if (vExternal) and (gDBACOnnect=0) then begin
          try begin
            ErrTryIgnore(_ErrValueInvalid);
            DbaDisconnect(3);
          end;
        end;
        RETURN false;
      end;

      vErr # vDatei->BinExport(vExtPath);

      vDir->BinClose();
      vDatei->BinClose();

      if (vExternal) and (gDBACOnnect=0) then begin
        try begin
          ErrTryIgnore(_ErrValueInvalid);
          DbaDisconnect(3);
        end;
      end;

      Dlg_PDFPreview:ShowPDF(vExtPath, true, Dok.EMail,Dok.FAX,0,1);
      FsiDelete(vExtPath);

    end
    else begin
      // "normale" Druckvorschau
      Dlg_PrintPreview:ShowJob(vPath,vName,0, 1, Dok.EMail, Dok.FAX);
      // macht ggf DISCONNECT
//      if (vExternal) then DbaDisconnect(3);
    end;

    RETURN true;
  end;


  // C16-Vorschau...
  //vDatei  # BinOpen(vDir,AInt(Dok.Nummer)+'.Job',0);
  TRY begin
    ErrTryCatch(_ErrHdlInvalid, y);
    vDatei  # BinOpen(vDir,vDokname, vPara);
  end;
  if (ErrGet()<>_rOK) or (vDatei<0) then begin
    if (vExternal) and (gDBACOnnect=0) then begin
      try begin
        ErrTryIgnore(_ErrValueInvalid);
        DbaDisconnect(3);
      end;
    end;
    RETURN false;
  end;

  vErr # vDatei->BinExport(vPath);
  vDir->BinClose();
  vDatei->BinClose();

 if (vExternal) and (gDBACOnnect=0) then begin
    try begin
      ErrTryIgnore(_ErrValueInvalid);
      DbaDisconnect(3);
    end;
  end;

  vPrtJob # PrtJobOpen('',vPath,_PrtJobOpenRead);
  if (vPrtJob > 0) then begin
    vDok # vPrtJob->PrtInfo(_PrtDoc);
    If vDok > 0 then begin
      vDok->ppRuler    # _PrtRulerNone;
      vDok->ppPageZoom # _PrtPageZoomPageWidth;
    end;
    vOK # vPrtJob->PrtJobClose(_PrtJobPreview) = _ErrOK;
    FsiDelete(vPath);
    gZLlist # vZList;
    RETURN vOK;
  end
  else begin
    FsiDelete(vPath);
    gZLlist # vZList;
    RETURN false;
  end;

end;


//========================================================================
// SaveDokPdf
//
//========================================================================
sub SaveDokPdf(
  aNummer         : int;
  aPath           : alpha(4000);
) : logic
Local begin
  vPath   : alpha;

  vPrtJob   : int;
  vDok      : int;
  vDir      : int;
  vDatei    : int;
  vErr      : int;
  vOK       : logic;
  vA        : alpha;
  vI        : int;
  vName     : alpha;

  vDokname  : alpha;
  vPDF      : logic;

  vExternal : logic;
  vPara     : int;
end;
begin

  if (StrFind(Set.Module,'P',0)<=0) then RETURN false;

  RecBufClear(915);
  Dok.Nummer # aNummer;
  If (RecRead(915,2,0) > _rLocked) or (aNummer = 0) then return False;
  
  FsiDelete(aPath);

  
   if (gDBAConnect=0) then begin
    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vExternal # true;
  end
  else begin
    vExternal # true;
  end;
  if (vExternal) then begin
    vPara # _BinDba3;
  end;


  
  // ist intern
  vDir    # BinDirOpen(0,'Dokumente\'+"Dok.Kürzel",_BinCreate | vPara)
  if (vDir<0) then begin
    If (vExternal) then DbaDisconnect(3);
    RETURN false;  // neu seit April
  end;

   // PDF anstatt JOB?
  vPDF # false;

  vDokname  # AInt(Dok.Nummer)+'.pdf';
  vPDF    # true;

  if (vExternal) then
    vPath # '>3\Dokumente\'+"Dok.Kürzel"+'\'+vDokname
  else
    vPath # '>0\Dokumente\'+"Dok.Kürzel"+'\'+vDokname;

  vA # Str_Token(Dok.FormularName,':',1);
  vI # cnvia(vA);
  vName # "Dok.Kürzel"+'_'+aInt(vI);

  if (vPDF) then begin
    // PDF aus Blob extrahieren und PDF anzeigen
    TRY begin
      ErrTryCatch(_ErrHdlInvalid, y);
      vDatei  # BinOpen(vDir, vDokname, vPara);
    end;
    if (ErrGet()<>_rOK) or (vDatei<0) then begin
//debugx('nix da');
      if (vExternal) and (gDBACOnnect=0) then begin
        try begin
          ErrTryIgnore(_ErrValueInvalid);
          DbaDisconnect(3);
        end;
      end;
      RETURN false;
    end;

    vErr # vDatei->BinExport(aPath);

    vDir->BinClose();
    vDatei->BinClose();

    if (vExternal) and (gDBACOnnect=0) then begin
      try begin
        ErrTryIgnore(_ErrValueInvalid);
        DbaDisconnect(3);
      end;
    end;
  end
  else begin
    // "normale" Druckvorschau
//    Dlg_PrintPreview:ShowJob(vPath,vName,0, 1, Dok.EMail, Dok.FAX);
    // macht ggf DISCONNECT
//      if (vExternal) then DbaDisconnect(3);
  end;

  RETURN true;
end;


/***
//========================================================================
// Showdok
//
//========================================================================
sub ShowDok(
  aNummer : int;
) : logic
Local begin
  vPath   : alpha;
  vPathOhneExt : alpha;

  vPrtJob : int;
  vDok    : int;
  vDir    : int;
  vDatei  : int;
  vErr    : int;
  vOK     : logic;
  vZList  : int;
  vA      : alpha;
  vI      : int;
  vName   : alpha;

  vDokname  : alpha;
  vPDF      : logic;
  vExtPath : alpha(1000);
end;
begin
  vZList # gZLList;
  RecBufClear(915);
  Dok.Nummer # aNummer;
  If (RecRead(915,2,0) > _rLocked) or (aNummer = 0) then return False;
  vPath # Set.Druckerpfad;
  If vPath = '' then vPath # 'c:\';
  vPath   # vPath+"Dok.Kürzel"+'_'+AInt(Dok.Nummer)+'.Job';
  vDir    # BinDirOpen(0,'Dokumente\'+"Dok.Kürzel",_BinCreate);

   // PDF anstatt JOB?
  vPDF # false;
  vPathOhneExt # Set.Druckerpfad + "Dok.Kürzel" + '_'+AInt(Dok.Nummer);
  if (BinOpen(vDir,AInt(Dok.Nummer)+'.Job') < 0) then begin
    vDokname  # AInt(Dok.Nummer)+'.pdf';
    vExtPath  # vPathOhneExt + '.pdf';
    vPDF    # true;
  end
  else begin
    vDokname # AInt(Dok.Nummer)+'.Job';
  end;

  // StahlControl-Vorschau...
  if (StrFind(Set.Module,'P',0)>0) or (gUsername='DRUCKTEST') then begin
    //vPath # '>0\Dokumente\'+"Dok.Kürzel"+'\'+AInt(Dok.Nummer)+'.Job';
    vPath # '>0\Dokumente\'+"Dok.Kürzel"+'\'+vDokname;
    vA # Str_Token(Dok.FormularName,':',1);
    vI # cnvia(vA);
    vName # "Dok.Kürzel"+'_'+aInt(vI);

    if (vPDF) then begin
      // PDF aus Blob extrahieren und PDF anzeigen
      vDatei  # BinOpen(vDir,vDokname,0);
      vErr # vDatei->BinExport(vExtPath);

      vDir->BinClose();
      vDatei->BinClose();

      Dlg_PDFPreview:ShowPDF(vExtPath, Dok.EMail,Dok.FAX,0,1);
      FsiDelete(vExtPath);

    end
    else begin
      // "normale" Druckvorschau
      Dlg_PrintPreview:ShowJob(vPath,vName,0, 1, Dok.EMail, Dok.FAX);
    end;

    RETURN true;
  end;


  // C16-Vorschau...
  //vDatei  # BinOpen(vDir,AInt(Dok.Nummer)+'.Job',0);
  vDatei  # BinOpen(vDir,vDokname,0);
  vErr # vDatei->BinExport(vPath);
  vDir->BinClose();
  vDatei->BinClose();
  vPrtJob # PrtJobOpen('',vPath,_PrtJobOpenRead);
  if (vPrtJob > 0) then begin
    vDok # vPrtJob->PrtInfo(_PrtDoc);
    If vDok > 0 then begin
      vDok->ppRuler    # _PrtRulerNone;
      vDok->ppPageZoom # _PrtPageZoomPageWidth;
    end;
    vOK # vPrtJob->PrtJobClose(_PrtJobPreview) = _ErrOK;
    FsiDelete(vPath);
    gZLlist # vZList;
    RETURN vOK;
  end
  else begin
    FsiDelete(vPath);
    gZLlist # vZList;
    RETURN false;
  end;

end;
***/


//========================================================================
// CheckForm
//
//========================================================================
sub CheckForm(
  aBereich  : int;
  aFormular : alpha;
) : int
local begin
  vDokName    : alpha;
  vDokNummer  : int;
  vNummer     : int;
  xvDev       : int;
  vSprache    : alpha;
  xvVS,vDD    : logic;
  vAdr        : int;
  vScript     : int;
end;
begin

  If (RekReadFrm(aBereich, aFormular) > _rLocked) then begin
    Msg(912002,aFormular,0,0,0);
    RETURN 0;
  end;

  try begin
    ErrTryIgnore(_rlocked,_rNoRec);
    ErrTryCatch(_ErrNoProcInfo,y);
    ErrTryCatch(_ErrNoSub,y);
    gPDFTitel   # '';
    gPDFName    # '';
    gPDFDMS     # '';
    gPDFDMSPath # '';
    vDokName # Call(Frm.Prozedur+':GetDokName', var vSprache, var vAdr);
  end;
  if (ErrGet()<>_ErrOK) then begin
  
    // DS 2022-10-24
    RecRead(903, 1, _recFirst);  // Settings lesen
    if (Set.Installname='BSC') and (Frm.Prozedur) = '' then
    begin
      // ignorieren, weil manuell in BSC's EcoDMS hinzugefügte Dokumente erwarteterweise ein leeres Feld Frm.Prozedur haben
    end
    else
    begin
      Todo('Formularprozedur '+Frm.Prozedur);
    end
    RETURN 0;
  end;

  // 08.04.2016 AH: Listen, die als Formular gestartet werden, setzen Adresse auf -1 zum Beenden
  if (vAdr=-1) then RETURN 0;

  If (vSprache<>'') then
    vDokName # vDokName + ':'+vSprache
  else if (Set.Sprache1.Kurz<>'') then
    vDokName # vDokName + ':'+Set.Sprache1.Kurz
  else
    vDokName # vDokName + ':D';

  // ABLAGE PRÜFEN??
  If (vDokName <> '') then begin
    RETURN GetDokID(Frm.Bereich, Frm.Name, vDokName);
  end;

  RETURN 0;
end;

//========================================================================
// sub AddDokumentToJobServerQueue(opt aNr : int
//  Fügt ein neuen Druckjob in die Serverqueue hinzu
//========================================================================
sub AddDokumentToJobServerQueue(opt aSkriptNr : int; opt aKeys : alpha(1000))
local begin
  Erx         : int;
  vDokName    : alpha;
  vSprache    : int;
  vAdr        : int;
  vPara       : alpha;
  vKey        : alpha(1000);
  vBereichOrScript : alpha;
  
  vParaComplete : alpha(1000);
  
end
begin
  vKey # Lib_Rec:MakeKey(Frm.Bereich,false,',');
  if  (aKeys <> '') then
    vKey # aKeys;
    
  // ST 2021-10-14: Letztes Keysep. abschneiden, wenn vorhanden
  if (StrCut(vKey,Strlen(vKey),1) = ',') then
    vKey # StrCut(vKEy,1,StrLen(vKey)-1);
  
  RecBufClear(905);
  Job.Aktion # 'Lib_Dokumente:PrintJob';
    
  vBereichOrScript # Aint("Frm.Bereich");
  if (aSkriptNr <> 0) then begin
    vBereichOrScript # 'S'+Aint(aSkriptNr);
  end;

  Job.Beschreibung # 'Druck von SOA';
  Job.Start.Datum  # today;
  Job.Start.Zeit   # now;
  Job.Resheduling  # '';    // Leeres Rescheduling -> JOb wird nach Ausführung gelöscht
      if (Set.Installname = 'ISB') then //MK 28.11.22 2347/79/1 - Dirty Fix für INMET in Absprache mit AH  bis Allg. Lösung fertig
    Job.Gruppe # 1;
  
  vParaComplete # vBereichOrScript + '|' +
                  "Frm.Name"    + '|' +
                  Aint(vAdr)    + '|' +
                  gUsername     + '|' +
                  vKey          + '|' +
                  Aint(gLastDruckerID); //2023-04-20  MR  2436/418

  if (StrLen(vParaComplete) <= 250) then
    Job.Parameter # vParaComplete;
  else begin
    Job.Parameter     # StrCut(vParaComplete,1,250);
    Job.Beschreibung  # 'PARAMETERFEHLER';
    Job.Start.Datum   # 31.12.2099;
  end;
  
  Job.Nummer # 999;
  REPEAT
    Job.Nummer # Job.Nummer + 1;
    Erx # RekInsert(905,0,'MAN');
  UNTIL (Erx  = _rOK);
end;


//========================================================================
// sub PrintJob()
//  Druckt ein Dokument über den Jobserver
//========================================================================
sub PrintJob(opt aPara : alpha(1000)) : logic
local begin
  Erx         : int;
  vBereichOrScript  : alpha;
  vIsSkript   : logic;
  vKey        : alpha(250);
  vAdr        : int;
  vDruckerID  : int;
  vUserPrint  : alpha;
  vUsername   : alpha;
end
begin
  vUsername   # gUsername;
  RecBufClear(912);
  
  vBereichOrScript  #   Str_Token(aPara, '|', 1);
  Frm.Name    #         Str_Token(aPara, '|', 2);
  vAdr        #   CnvIa(Str_Token(aPAra, '|', 3));
  vUserPrint  #         Str_Token(aPAra, '|', 4);
  vKey        #         Str_Token(aPAra, '|', 5);
  vDruckerID  #   CnvIa(Str_Token(aPAra, '|', 6));//2023-04-20  MR  2436/418
  // Daten lesen
  if (Str_Count(vKey,',') = 0) then
    Lib_Rec:ReadByKey(CnvIa(vBereichOrScript),vKey);
  
  gUsername   # vUserPrint;
  Adr.Nummer  # vAdr;
  Erx # RecRead(100,1,0);
  if (Erx <> _rOK) then
    RecBufClear(100);
  

  // Druck oder Skript ausführen
  if (StrFind(vBereichOrScript,'S',0) > 0) then begin
    // Script
    Lib_Script:Run(CnvIa(vBereichOrScript));
  end
  else begin
    // Formulardruck
    Frm.Bereich # CnvIa(vBereichOrScript);
    Lib_Dokumente:Printform(Frm.Bereich, Frm.Name,false, vKey, '', vDruckerID); //2023-04-20  MR  2436/418
  end
    
  // Wieder ale Job-Server weiterarbeiten
  gUsername # vUsername;
  RETURN true;
end;


//========================================================================
// PrintForm
//
//========================================================================
sub PrintForm(
  aBereich        : int;
  aFormular       : alpha;
  aCheck          : logic;
  opt aFilename   : alpha(4096);
  opt aKeys       : alpha(250);
  opt aDruckerID  : int;
) : logic
local begin
  Erx         : int;
  vDokName    : alpha;
  vDokNummer  : int;
  vNummer     : int;
  vDev        : int;

  vAnzahl     : int;
  vKopien     : int;
  vMarke      : alpha(200);
  vSchacht    : alpha(200);
  vDruckerName : alpha(1000);

  vSprache    : alpha;
  vVS,vDD     : logic;
  vAdr        : int;
  vScript     : int;
  vPostScript : int;
  vTmp        : int;
  vBonus      : handle;
  vPath       : alpha(1000);
end;
begin
  LastPrinter       # '';
  gBCPS_Outputfile  # '';

  /// FÜR SOA
//  Log('PrintForm: ' + Aint(aBereich)  + ' ' + aFormular + ' als ' + gUsername);

  If (RekReadFrm(aBereich, aFormular) > _rLocked) then begin
    if (gUsergroup <> 'JOB-SERVER') AND (gUsergroup <> 'SOA_SERVER') and ((gUsername=*^'SOA*')=false) then
      Msg(912002,aFormular,0,0,0);
    else
      Error(912002,aFormular);
    RETURN false;
  end;
   
   // AUSGABE PRÜFEN
  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;


  Erx # FsiOpen(vPath+'TEST.TXT', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (erx<0) then begin
    Msg(912005,'',_WinIcoError,_windialogok,1);
    RETURN false;
  end
  else begin
    Erx->FsiCLose();
    FsiDelete(vPath+'TEST.TXT');
  end;
  
  try begin
    ErrTryIgnore(_rlocked,_rNoRec);
    ErrTryCatch(_ErrNoProcInfo,y);
    ErrTryCatch(_ErrNoSub,y);
    gPDFTitel   # '';
    gPDFName    # '';
    gPDFDMS     # '';
    gPDFDMSPath # '';
    vDokName    # Call(Frm.Prozedur+':GetDokName', var vSprache, var vAdr);
  end;
  if (ErrGet()<>_ErrOK) then begin
    if (gUsergroup <> 'JOB-SERVER') AND (gUsergroup <> 'SOA_SERVER') and ((gUsername=*^'SOA*')=false) then
      Todo('Formularprozedur '+Frm.Prozedur);
    RETURN false;
  end;

  // 08.04.2016 AH: Listen, die als Formular gestartet werden, setzen Adresse auf -1 zum Beenden
  if (vAdr=-1) then RETURN true;

  If (vSprache<>'') then
    vDokName # vDokName + ':'+vSprache
  else if (Set.Sprache1.Kurz<>'') then
    vDokName # vDokName + ':'+Set.Sprache1.Kurz
  else
    vDokName # vDokName + ':D';

  // ABLAGE PRÜFEN??
  If (aCheck) and (vDokName <> '') and (gUsergroup<>'JOB-SERVER') and (gUsergroup<>'SOA_SERVER') and ((gUsername=*^'SOA*')=false) then begin
    vDokNummer # GetDokID(Frm.Bereich, Frm.Name, vDokName);

    If (vDokNummer > 0) then begin
    
      // 2023-05-03  DS
      // Nur wenn das Speichern dieser Dokumentenart laut 912 aktiv ist, sollte nach dem bereits gedruckten Dokument gefragt werden (das tut Msg(912001,...))
      // Denn wenn das Speichern nicht akiviert ist, könnte das gespeicherte Dokument stark veraltet seit.
      // Dies hilft auch in dem Fall, dass für EcoDMS Dokumentenarten das Speichern und Einpflegen in EcoDMS nachträglich deaktiviert wurde.
      if Frm.SpeichernYN then
      begin
      
        Case Msg(912001,'',_WinIcoQuestion,_WinDialogYesNoCancel,1) of
          _WinIdYes      : begin
            ShowDok(vDokNummer);
            RETURN false;
          end;
          _WinIdNo      : begin
            // Weiter im Code unten...
          end;
          _WinIdCancel  : begin
            RETURN false
          end;
        end; // Case
      end

    end;
  end;

/*
  if (gTimer<>0) then begin
    gTimer->SysTimerClose();
    gTimer # 1;
  end;
  if (gTimer2<>0) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 1;
  end;
*/


  // SCRIPTLOGIK:
 
  vScript # 0;
  // existiert ein Adress-Script ??
  if (Lib_Script:Check(vAdr, 0, Cnvai(aBereich)+'/'+aFormular)=true) then vScript # Scr.Nummer;
  // existiert ein standard Script ??
  if (vScript=0) and (Lib_script:Check(0, 0, Cnvai(aBereich)+'/'+aFormular)=true) then vScript # Scr.Nummer;
  if (vScript<>0) then begin
    Lib_Script:Run(vScript);
    RETURN true;
  end;

  // -----------------------------------
  //    SOA darf NIE selber Drucken
  // ------------------------------------
  if (gUsergroup = 'SOA_SERVER') then begin
    AddDokumentToJobServerQueue(vScript, aKeys);
    RETURN true;
  end;

  // Post-Scripte?
  // existiert ein Adress-Script ??
  if (Lib_Script:Check(vAdr, 0, Cnvai(aBereich)+'/'+aFormular+'.POST')=true) then vPostScript # Scr.Nummer;
  // existiert ein standard Script ??
  if (vPostScript=0) and (Lib_script:Check(0, 0, Cnvai(aBereich)+'/'+aFormular+'.POST')=true) then vPostScript # Scr.Nummer;
  RecBufClear(920);
  RecBufClear(921);
  if (vPostScript<>0) then begin
    Scr.Nummer # vPostScript;
    RecRead(920,1,0);
  end;

  WinEvtProcessSet(_WinEvtTimer,false);


  vMarke        # Frm.Markierung;
  vSchacht      # Frm.Schacht;
  if (Frm.Kopien=0) then Frm.Kopien # 1;
  vKopien       # Frm.Kopien;
  vVS           # Frm.VorschauYN;
  vDD           # Frm.DirektDruckYN;
  
  
  //2023-04-20  MR 2436/418
  if(aDruckerID = 0) then
    vDruckerName  # Frm.Drucker;
  else begin
    Dzo.Nummer # aDruckerID;
    Erx # RecRead(913,1,0);
    
    vDruckerName # Dzo.Drucker;
    Frm.Drucker # vDruckerName;
  end

  // Log('x');

  // exisitiert eine Formularprozedur in der Sprache?
  if (vSprache<>'D') and (StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0) then begin
    vTMP # textopen(1);
    Erx # Textread(vTMP, Frm.Prozedur+'_'+vSprache, _TextNoContents | _TextProc);
    vTMP->textclose();
    if (erx<>_rOK) then vSprache # 'D';
  end;

  // PDFcreator
  if (Set.PDF.Creator<>'') and (Set.PDF.CreatorPAth<>'') then begin
    Frm.VorschauYN          # n;
    if (vSprache<>'D') and(StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0) then
      Frm.Prozedur # Frm.Prozedur+'_'+vSprache;
    "Frm.DirektdruckYN"     # y;    // KEINE C16-VORSCHAU MEHR
    Frm.Markierung          # Str_Token(vMarke,'|',vAnzahl);
    Frm.Schacht             # '';
    Frm.Drucker             # Set.PDF.Creator;//'\\192.168.0.2\PDFCreator';
    gPDFName                # aint(gUserid);


    // Formular generieren + ggf. Druck
    if (gUsergroup <> 'SOA_SERVER') then
      vBonus # VarInfo(WindowBonus);

    if (StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0) then APPOFF();

    Adr.Nummer  # vAdr;     // 07.01.2022 AH: damit die "F_SQL" für PureSQL den Adressaten hat
    Adr.Sprache # vSprache; // "
    if (aKeys = '') then
      Call(Frm.Prozedur);
    else
      Call(Frm.Prozedur,aKeys);
      
    APPON();

    if (gUsergroup <> 'SOA_SERVER') then begin
      if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
      gFrmMain->Winupdate(_WinUpdActivate);
    end;

    if (vDD) then begin
      Dlg_PDFPreview:DirekterDruck(Set.PDF.CreatorPath+gPDFname+'.pdf', Frm.Kopien, vDruckerName, 0, Str_Token(vSchacht,'|',1));
    end;
    if (vVS) then begin
      Dlg_PDFPreview:ShowPDF(Set.PDF.CreatorPath+gPDFname+'.pdf', true, Dok.EMail,Dok.FAX, 0, 1, gPDFTitel);
    end;


    if (Frm.SpeichernYN) then begin
  //    Lib_Dokumente:ImportPDF(cpdfcPath+gPDFname+'.pdf', Frm.Bereich, Frm.Name, Form_DokName, Form_DokSprache, form_FaxNummer, form_EMA);
    end;

    FSIDelete(Set.PDF.CreatorPath+gPDFname+'.pdf');

  end
  else begin

  // Log('x');
    // DIREKT DRUCKEN ****************************
    if (vDD) then begin
      if (vSprache<>'D') and(StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0)then
        Frm.Prozedur # Frm.Prozedur+'_'+vSprache;
      Frm.VorschauYN          # n;
      "Frm.DirektdruckYN"     # y;    // KEINE C16-VORSCHAU MEHR
      Frm.Markierung          # Str_Token(vMarke,'|',vAnzahl);
      Frm.Schacht             # Str_Token(vSchacht,'|',1);
  // Log('x');
      // Formular generieren + ggf. Druck
      vBonus # VarInfo(WindowBonus);
  // Log('x');
      if (StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0) then APPOFF();

// Log('z : Frm.Prozedur:' + Frm.Prozedur);
      if (aFilename<>'') then
        Call(Frm.Prozedur, aFilename);      // Alter FRM Druck
      else begin
        // SQL Druck
        if (aKeys = '') then
          Call(Frm.Prozedur);
        else
          Call(Frm.Prozedur,aKeys);
      end;
              
              
// Log('zzzz');
      APPON();
// Log('yyyy');

// Log('y');
      if (gUsergroup <> 'JOB-SERVER') AND (gUserGroup <> 'SOA_SERVER') and ((gUsername=*^'SOA*')=false) then begin
        if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
        gFrmMain->Winupdate(_WinUpdActivate);
      end;
  // Log('x!!!!');
    end;  // DRUCKEN

    // VORSCHAU ANZEIGEN ************************* 02.06.2020 AH: "vDD=..."
    if (vVS) or ((vDD=false) and (Frm.SpeichernYN)) then begin
      Frm.DirektDruckYN # n;
      Frm.VorschauYN    # y;
      if (vSprache<>'D') and (StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0) then
        Frm.Prozedur # Frm.Prozedur+'_'+vSprache;

      // Formular generieren + ggf. Druck
      vBonus # VarInfo(WindowBonus);
      if (StrFind(StrCnv(Frm.Prozedur,_StrUpper),'SQL',0,0)=0) then APPOFF();
      
      if (aFilename<>'') then
        Call(Frm.Prozedur, aFilename)
      else begin
         // SQL Druck
        if (aKeys = '') then
          Call(Frm.Prozedur);
        else
          Call(Frm.Prozedur,aKeys);
      end;
        
      APPON();
      if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
      gFrmMain->Winupdate(_WinUpdActivate);
    end;  // VORSCHAU

  end;

//DbaLog(_LogInfo, N, ThisLine);
  // Log('x');
  WinEvtProcessSet(_WinEvtTimer,true);
  LastPrinter # '';

//DbaLog(_LogInfo, N, ThisLine);
  if (gMDI<>0) and (gMDI->wpcustom<>'') then
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  // Log('x');
//DbaLog(_LogInfo, N, ThisLine);
  // POST-SCript?
  if (vPostScript<>0) then begin
    if (msg(912007,'',_WinIcoQuestion,_WinDialogYesNo, 1)=_winIdYes) then
      Lib_Script:Run(vPostScript);
  end;

  gBCPS_Outputfile # '';

  RETURN true;
end;


//========================================================================
// ClearThisDoc
//
//========================================================================
Sub ClearThisDoc () : logic
local begin
  vIndex  : int;
  vNummer : int;
  vPath   : alpha;
  vDir    : int;
  vDatei  : int;
  vErr    : int;
end;
begin
  vDir    # BinDirOpen(0,'Dokumente\'+"Dok.Kürzel",_BinCreate);
//  vDatei  # BinOpen(vDir,CnvAI(Dok.Nummer,_FmtInternal)+'.Job',0);
  bindelete(vDir,AInt(Dok.Nummer)+'.Job',0);
  vDir->BinClose();
//  vErr # vDatei->BinClose();
end;


//========================================================================
// ClearAllDocs
//
//========================================================================
Sub ClearAllDocs () : logic
begin
  RETURN BinDirDelete(0,'Dokumente',_BinDeleteAll) = _ErrOK;
end;

//========================================================================
// call Lib_dokumente:InitDokCa1
//========================================================================
Sub InitDokCa1();
local begin
   vErr       : int;
   vDir2      : int;
   vSubDir2   : int;
   vDatei2    : int;
   vDir1      : int;
   vSubDir1   : int;
   vDatei1    : int;
   vDirName   : alpha;
   vFileName  : alpha;
   vWin       : int;
end;
begin

  if (RunAFX('XLINK.CONNECT.DOKCA1','')<0) then begin
    Msg(99,'XLink nicht startbar!',0,0,0);
    RETURN;
  end;

debug('start copy...');
  vWin # Lib_Progress:Init('Export Dokumente');

  vDir1   # BinDirOpen(0,'Dokumente', 0);
  vDir2   # BinDirOpen(0, 'Dokumente', _BinCreate | _BinDba3);

   // alle Objekte zu diesem Verzeichnis ermitteln
  vDirName # BinDirRead(vDir1,_BinFirst | _BinDirectory);
  WHILE (vDirName != '') do begin

    vSubDir2 # BinDirOpen(vDir2, vDirName, _BinCreate | _BinDba3);

    vSubDir1 # BinDirOpen(vDir1, vDirName);

    vFilename # BinDirRead(vSubDir1,_BinFirst);
    WHILE (vFilename != '') do begin

//debug('copy:'+vDirName+'\'+vFilename);

      Lib_Progress:Setlabel(vWin, vDirname+'\'+vFilename);

      vDatei1 # BinOpen(vSubDir1, vFilename, 0);
      vErr # vDatei1->BinExport('C:\debug\TEST.JOB');
if (verr<>_ErrOK) then debugx('Error :' +aint(verr));

      vDatei2 # BinOpen(vSubDir2, vFilename, _BinCreate | _BinLock | _BinDba3);
      vErr    # vDatei2->BinImport('C:\debug\TEST.JOB', 4);
//      vErr    # BinCopy(vDatei1, vDatei2);
if (verr<>_ErrOK) then debugx('Error :' +aint(verr));
      BinClose(vDatei1);
      BinClose(vDatei2);

      vFileName # BinDirRead(vSubDir1, _BinNext, vFileName);
    END;
    BinClose(vSubDir1);
    BinClose(vSubDir2);

    vDirName # BinDirRead(vDir1, _BinNext | _BinDirectory, vDirName);
  END;

  BinClose(vDir1);
  BinClose(vDir2);

  DbaDisconnect(3);

  Lib_Progress:Term(vWin);

  Msg(99,'Done!',0,0,0);

  RETURN;
end;


//========================================================================
