@A+
//===== Business-Control =================================================
//
//  Prozedur  Anh_Data
//                OHNE E_R_G
//  Info
//
//
//  18.02.2014  AH  Erstellung der Prozedur
//  06.03.2014  AH  "FindArchivName"
//  24.04.2014  AH  für BLOBDB gängig gemacht
//  06.05.2014  AH  Verknüpfungen umgesetzt
//  21.05.2014  AH  "CopyAll" kopiert auch Links ordentlich
//  25.02.2015  ST  Konverter für bestehende Archivdaten
//  04.03.2015  ST  Dateinamen für Blobanhänge auf max 60 Stellen gelürzt
//  11.06.2016  AH  Fix: "CopyAll" setzt Anhänge richtig
//  21.03.2018  ST  "Execute" öffnet existierende Dateien, bevor in Ext.CA gesucht wird
//  25.06.2019  AH  Umbau für SubProjekte
//  15.01.2020  AH  Unterstützung für CmdTwain
//  25.05.2020  AH  Fix: "CopyAll" von Verknüpfungen
//  24.11.2020  AH  Neu: "ExportBereich"
//  08.12.2020  ST  Neu: "CopyAll" Verschiebt Anhänge bei Move auch in Blob CA1
//  03.02.2022  AH  ERX und Fix für doppelte Eintäge
//  29.03.2022  AH  Neu: "ReadByTypName"
//  04.04.2022  DS  Neu: "getAttachmentFilenames()" liefert Namen der Anhänge als String Array.
//  24.05.2022  DS  Neu: "readAnhFromDok()" und "readDokFromAnh()" die die Verlinkung zwischen 915 und 916 per RecIDs herstellen
//  2022-07-04  AH  Kopfanhänge werden in Positionen mit angezeigt (401,501)
//  2022-09-26  AH  "Remap"
//  2022-10-19  AH  Fix für Remap
//  2023-01-06  ST  Neu: "CheckBlobIntegrity"
//
//  Subprozeduren
//    SUB BLOBPath
//    SUB Reamp
//    SUB CreateBLOBPath
//    SUB Check
//    SUB StartScan
//    SUB StartScanSettings
//    SUB CopyAll
//    SUB DragDrop
//    SUB FindArchivName
//    SUB Execute
//    SUB Delete
//    SUB ExportBereich
//    SUB ReadByTypName
//    SUB getAttachmentFilenames
//    SUB readAnhFromDok
//    SUB readDokFromAnh
//
//========================================================================
@I:Def_Global

define begin
  cDBA  : _BinDBA3

  cProtokoll    : GV.Int.11
  Proto(a)      : if (cProtokoll > 0) then TextAddLine(cProtokoll, a);

end;


declare FindArchivName(
  aFilename : alpha(2000);
  aDatei    : int;
  aKey      : alpha;
) : alpha;

declare BLOBPath(
  aDatei  : int;
  aKey    : alpha
) : alpha;

declare CreateBLOBPath(
  aDatei  : int;
  aKey    : alpha;
  opt aDba : int
) : alpha;

declare MakeKey(
  aFile : int
) : alpha;



sub MakeTS(
  aDat  : date;
  aTim  : time) : bigint
begin
  RETURN (cnvbi(cnvid(aDat)-cnvid(1.1.2000))*24\b*60\b*1000\b)+cnvbi(cnvit(aTim));
end;


//========================================================================
//  BLOBPath
//
//========================================================================
Sub BLOBPath(
  aDatei  : int;
  aKey    : alpha) : alpha;
begin
  RETURN 'Anhänge' + '\'+aint(aDatei) + '\' + aKey
end;


//========================================================================
//========================================================================
sub Insert(opt aID : bigint) : int;
local begin
  Erx   : int;
  vMyID : logic;
end;
begin
  Anh.Anlage.Datum  # Today;
  Anh.Anlage.User   # gUserName;
  REPEAT
    Anh.Anlage.Zeit   # Now;
    if (aID=0) then
      Anh.ID            # MakeTS(today, now)
    else
      Anh.ID            # aID;
    if (Anh.ZuID=0) or (vMyID) then begin
      Anh.ZuID # Anh.ID;
      vMyID # y;
    end;
    Erx # RekInsert(916,_recunlock,'AUTO');
    if (erx<>_rOK) then begin
      Winsleep(1);
      CYCLE;
    end;
  UNTIL (Erx=_rOK);
  
  RETURN Erx;
end;


/*========================================================================
2022-09-26  AH
    Konvertiert eine Tabellennr. in eine andere z.B. von der Position auf den Kopf
    Es wird mittels aZumSave unterschieden, ob wir nur lesen/anzeigen, wobei wir weitere Attachments von anderen Tabellen sehen (dann false),
    oder ob wir über Insert eines neuen Anhangs sprechen (dann true), wobei STD-seitig nichts an der eingegebenen aTable Nummer geändert wird.
    
    Ausnahmen von diesen Regeln lassen sich über die AFX am Anfang der Funktion realisieren.
    
========================================================================*/
sub Remap(
  aTable    : int;
  aZumSave  : logic) : int;
begin
  
  if (RunAFX('Anh.Remap',aint(aTable)+'|'+abool(aZumSave))<0) then begin
    RETURN AfxRes;
  end;

  // STD addiert bei Anzeige weitere Sätze...
  if (aZumSave=false) then begin
    case aTable of
      281 : aTable # 280;   // Paket
      301 : aTable # 300;   // Reklamation
      401 : aTable # 400;   // Auftrag
      501 : aTable # 500;   // Bestellung
      441 : aTable # 440;   // Lieferschein
      651 : aTable # 650;   // Versand
      702 : aTable # 700;   // Betriebsauftrag
    end;
  end;
  
  RETURN aTable;
end;


/*========================================================================
2022-09-26  AH

nimmt an, dass ein eventuelles Anh_Data:Remap(aTable, ...) noch NICHT
stattgefunden hat (siehe App_Main:AttachmentsShow())
========================================================================*/
sub SelQuery(aTable : int) : alpha;
local begin
  vQ,vQ2  : alpha(4000);
  vTable  : int;
end;
begin
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Anh.Datei', '=', aTable);
  Lib_Sel:QAlpha(var vQ, 'Anh.Key', '=', Anh_Data:MakeKey(aTable));

  vTable # Anh_Data:Remap(aTable, false);
  if (vTable<>0) and (vTable<>aTable) then begin
    Lib_Sel:QInt(var vQ2, 'Anh.Datei', '=', vTable);
    Lib_Sel:QAlpha(var vQ2, 'Anh.Key', '=', Anh_Data:MakeKey(vTable));
    vQ # '('+vQ+') OR ('+vQ2+')';
  end;
  
  //DebugM(__PROCFUNC__ + ':' + cCrlf + 'aTable: ' + CnvAI(aTable) + cCrlf + 'vTable: ' + CnvAI(vTable) + cCrlf + 'vQ: ' + vQ);
  
  RETURN vQ;
end;


//========================================================================
//========================================================================
sub MakeKey(aFile : int) : alpha;
local begin
  vDatei  : int;
  vA      : alpha;
end;
begin

  if (aFile=0) then RETURN '';

  if (aFile>1000) then begin
//  if (HdlInfo(aFile, _HdlExists)>0) then begin
    vDatei # HdlInfo(aFile, _HdlSubType);
  end
  else begin
    vDatei # aFile;
    aFile # RecBufDefault(aFile);
  end;

  vA # Lib_Rec:MakeKey(aFile);
  if (vDatei=122) and (aFile->Prj.P.SubPosition=0) then begin
    vA # Str_token(vA, StrChar(255,1),1)+StrChar(255,1)+Str_token(vA, StrChar(255,1),2)+StrChar(255,1);
  end
  else if (vDatei=123) and (aFile->Prj.Z.SubPosition=0) then begin
    vA # Str_token(vA, StrChar(255,1),1)+StrChar(255,1)+Str_token(vA, StrChar(255,1),2)+StrChar(255,1)+Str_token(vA, StrChar(255,1),4)+StrChar(255,1);
  end;

  RETURN vA;
end;


//========================================================================
//  CreateBLOBPath
//
//========================================================================
Sub CreateBLOBPath(
  aDatei  : int;
  aKey    : alpha;
  opt aDba : int) : alpha;
local begin
  vPath   : alpha(4000);
  vDba    : int;
end
begin

  if (Set.ExtArchiev.Path<>'CA1') then RETURN '';

  if (aDba = 0) then
    vDba # cDBA;
  else
    vDba # aDBA;

  vPath # 'Anhänge';

  if (Lib_Blob:ExistsDir(vPath, vDba)<=0) then begin
    if (Lib_Blob:CreateDir('', vPath, vDba, 0)<>_errOK) then begin
      Msg(917010,vPath,0,0,0);
      RETURN '';
    end;
  end;

  if (Lib_Blob:ExistsDir(vPath+'\'+aint(aDatei), vDba)<=0) then begin
    if (Lib_Blob:CreateDir(vPath, aint(aDatei), vDba, 0)<>_errOK) then begin
      Msg(917010, aint(aDatei),0,0,0);
      RETURN '';
    end;
  end;

  vPath # vPath + '\'+aint(aDatei);
  if (Lib_Blob:ExistsDir(vPath+'\'+aKey, vDba)<=0) then begin
    if (Lib_Blob:CreateDir(vPath, aKey, vDba, 0)<>_errOK) then begin
      Msg(917010, aKey,0,0,0);
      RETURN '';
    end;
  end;

  vPath # vPath + '\'+aKey;

  RETURN vPath;
end;


//========================================================================
//  StartScan
//
//========================================================================
Sub StartScan(
  aDatei  : int;
  aKey    : alpha;
) : logic;
local begin
  vName       : alpha(4000);
  vNr         : int;
  vNewN       : alpha;
  vPath       : alpha(4000);
  vDBAConnect : int;
  vBlobID     : int;
  vBem        : alpha(1000);
  vA          : alpha(2000);
end;
begin

//  Erx # RecRead(916, gZLList->wpdbSelection, _recLast);
//  if (Erx<>_rOK) then vLfd # 0
//  else vLfd # Anh.lfdNr;

//  if (RunAFX('Anh.Scan',aint(aDatei)+'|'+aKey)<0) then RETURN (Erx=_rOK);
  if (RunAFX('Anh.Scan','')>=0) then begin
    vName # Lib_BCSCOM:StartScan();
  end
  else begin
    vName # GV.ALpha.01;
  end;
  if (vName='') then RETURN false;

  if (Dlg_Standard:Standard(Translate('Bemerkung'),var vBem, n, 64)=false) then RETURN false;

  vNr # Lib_Nummern:ReadNummer('Scan');
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else RETURN false;

  vNewN # FsiSplitname(vName, _FSINameP)+Translate('Scan')+aint(vNr)+'.'+FSISplitName(vName, _FSINameE);
  FSIDelete(vNewN);
  FSIRename(vName, vNewN);

  if (Set.ExtArchiev.Path='CA1') then begin
    if (gDBAConnect=0) then begin
      if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
      else RETURN false;
    end;

    vPath # CreateBLOBPath(aDatei, aKey);
    if (vPath<>'') then begin
      Lib_Blob:Import(vNewN, vPath, cDBA, 0, n, var vBlobID);
    end;
    if (vDBAConnect<>0) then begin
      DbaDisconnect(vDBAConnect);
    end;
    FSIDelete(vNewN);
    vNewN # FSISplitName(vNewN, _fsinameNE);
  end
  else begin
    // kopieren
    vA # FsiSplitname(vNewN, _FsiNameNE);
    vA # Anh_Data:FindArchivName(vA, aDatei, aKey);
    Lib_FileIO:FsiCopy(vNewN, vA, n);
    FsiDelete(vNewN);
    vNewN # vA;
  end;

  RecBufClear(916);
  Anh.Bemerkung     # StrCut(vBem,1,64);
  Anh.Datei         # aDatei;
  Anh.File          # vNewN;
  Anh.Key           # aKey;
//  Anh.lfdnr         # vLfd;
  Anh.BlobID        # vBlobID;
  Insert();
  
  RETURN true;
end;


//========================================================================
//  StartScanSettings
//
//========================================================================
Sub StartScanSettings();
begin
  if (RunAFX('Anh.Scan.Settings','')<0) then RETURN;
  Lib_BCSCOM:ScanSettings();
end;


//========================================================================
//  CopyAll
//
//========================================================================
SUB CopyAll(
  aVonBuf       : int;
  aNachBuf      : int;
  aMove         : logic;
  aLink         : logic) : logic;
local begin
  Erx     : int;
  vDatei1 : int;
  vDatei2 : int;
  vKey1   : alpha;
  vKey2   : alpha;
  v916    : int;
  vLDatei : int;
  vLKey   : alpha;
  vLLfdNr : int;
  vBig    : bigint;
  vLFile  : alpha(250);
  vErg    : int;
  vPath       : alpha(4000);
  vDBAConnect : int;
  
  vSrcPath : alpha(4000);
  vDestPath : alpha(4000);
  vBlobID : int;
end;
begin

// Dateu, key, lfdnr

  vErg # Erg;
  if (aVonBuf=0) or (aNachBuf=0) then RETURN false;
  if (HdlInfo(aVonBuf, _HdlExists)>0) then
    vDatei1 # HdlInfo(aVonBuf, _HdlSubtype)
  else
    vDatei1 # aVonBuf;
  if (HdlInfo(aNachBuf, _HdlExists)>0) then
    vDatei2 # HdlInfo(aNachBuf, _HdlSubtype)
  else
    vDatei2 # aNachBuf;

  vKey1 # MakeKey(aVonBuf);
  vKey2 # MakeKey(aNachBuf);

//  vNr # 1;

  TRANSON;

  RecBufClear(916);
  Anh.Datei # vDatei1;
  Anh.Key   # vKey1;
  Erx # RecRead(916,1,0);
  WHILE (Erx<_rNoRec) and
    (Anh.Datei = vDatei1) and
    (Anh.Key   = vKey1) do begin

    v916 # RekSave(916);
    // MOVE?
    if (aMove) then begin
    
      // ID eindeutig setzen
      vBig # Anh.ID;
      REPEAT
        Anh.ID            # vBig;
        Erx # RecRead(916,3,_recTest);
        if (Erx<=_rMultikey) then begin
          inc(vBig);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufCopy(v916,916);

      Erx # RecRead(916,1,_recLock);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Erg # vErg;
        RETURN false;
      end;
      vPath # 'Anhänge\'+aint(Anh.Datei)+'\'+Anh.Key;
      Anh.Datei # vDatei2;
      Anh.Key   # vKey2;
      Anh.ID    # vBig;
      Anh.ZuID  # vBig; // hmmm...?TODO`?

      Erx # RekReplace(916,_recunlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RekRestore(v916);
        RETURN false;
      end;

      // 15.03.2016 AH:
      if (Set.ExtArchiev.Path='CA1') then begin
        if (gDBAConnect=0) then begin
          if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
          else begin
            TRANSBRK;
            RekRestore(v916);
            RETURN false;
          end;
        end;
        
        if (vDatei1 = vDatei2) then begin
          Erx # Lib_Blob:RenameDir(vPath, Anh.Key, cDBA, 0);
        end else begin
          // Dir Kopieren
          vSrcPath  # 'Anhänge\'+aint(vDatei1)+'\'+vKey1;
          vDestPath # 'Anhänge\'+aint(vDatei2)+'\'+vKey2;
          
          // Zielordner erstellen
          Erx # Lib_Blob:CreateDir('Anhänge',Aint(vDatei2), cDBA,0);
          Erx # Lib_Blob:CreateDir('Anhänge\'+aint(vDatei2),vKey2, cDBA,0);
          if (Erx = _rOK) then begin
            if (Lib_Blob:Copy(vSrcPath+'\'+Anh.File,vDestPath,cDBA,0,true,var vBlobID) = _rOK) then begin
              if (aMove) then
                Lib_Blob:Delete(Anh.File,vSrcPath,cDBA,0);
//              Lib_Blob:DeleteDir(vSrcPath,cDBA,0,0);
            end;
          end;
        end;
          
        if (vDBAConnect<>0) then DbaDisconnect(vDBAConnect);
      end;

      RekRestore(v916);
      Erx # RecRead(916,1,0);
      CYCLE;
    end;


    // COPY
    vLDatei   # v916->Anh.Datei;
    vLKey     # v916->Anh.Key;
    vLlfdNr   # v916->Anh.lfdnr;
    vLFile    # StrCut('->'+v916->Anh.File,1,250);
    vBig      # v916->Anh.ID
    // ist schon ein Link?
    if (Anh.Link.Datei<>0) then begin
      vLDatei   # v916->Anh.Link.Datei;
      vLKey     # v916->Anh.Link.Key;
      vLlfdNr   # v916->Anh.Link.lfdnr;
      vLFile    # v916->Anh.File;
//      vBig      # v916->Anh.ID;
      vBig      # v916->Anh.Link.ID;  // 25.05.2020 AH
    end;

    Anh.Datei # vDatei2;
    Anh.Key   # vKey2;

    if (Set.ExtArchiev.Path='CA1') then begin
      if (aLink) then begin
        Anh.Link.Datei      # vLDatei;
        Anh.Link.Key        # vLKey;
        Anh.Link.lfdNr      # vLlfdnr;
        Anh.Link.ID         # vBig;
        Anh.File            # vLFile;
      end;
    end;
    
    Anh.ZuID # 0;
    
    Insert();

    RekRestore(v916);
    Erx # RecRead(916,1,_recNext);
  END;

  TRANSOFF;

  Erg # vErg;
  RETURN true;

end;

//========================================================================
//========================================================================
Sub DragDrop(
  aVon        : alpha(4000);
  aNachDatei  : int;
  aNachKey    : alpha;
  aNachPfad   : alpha(4000);    // WENN OHNE DATEI
  aWie        : alpha;
  aRecList    : int;
  opt aTyp    : alpha;
  opt aName   : alpha;
) : logic;
local begin
  Erx       : int;
  vA        : alpha(4000);
  vI        : int;
  v916      : int;
//  vNr       : int;
  vDBACon   : int;
  vFilename : alpha(4000);
  vPath     : alpha(4000);
  vPath2    : alpha(4000);
  vBlobID   : int;
  vOK       : logic;
  vExists   : logic;
end;
begin
//debugx(aVon+' -> '+aint(aNachDatei)+':'+aNachPfad+'|'+aNachKey);

  // nur mit BLOB-DB
  if (Set.ExtArchiev.Path<>'CA1') then RETURN false;
  if (aWie='LINK') and (aNachPfad<>'') then RETURN false;
  if (aNachPfad<>'') then begin
    aNachDatei # 0;
    aNachKey   # '';
  end;

  vA # Str_Token(aVon,'|',1);

  v916 # RecBufCreate(916);

  // VON Anhang?
  if (vA='916') then begin

    if (aWie<>'COPY') and (aWie<>'LINK') then begin
      vI # Msg(916004,'',_WinIcoQuestion, _WinDialogYesNoCancel, 1);
      if (vI=_WinIdCancel) then RETURN false;
      if (vI=_Winidyes) then aWie # 'LINK';
      else aWie # 'COPY';
    end;

    vI # cnvia(Str_Token(aVon,'|',2));
    Erx # RecRead(v916,0,_RecId, vI);    // Satz holen
    if (Erx>_rLocked) then begin
      RecBufDestroy(v916);
      RETURN false;
    end;

    vFilename # v916->Anh.File;
    vPath  # Anh_Data:BLOBPath(v916->Anh.Datei, v916->Anh.Key);
    if (vPath='') then RETURN false;

    vFilename # v916->Anh.File;
  end
  // VON Blob?
  else if (vA='Blob') then begin
    vA # Str_Token(aVon,'|',2);
    RecBufClear(v916);
    vPath     # FsiSplitname(vA, _FsiNamePP);
    vFilename # FsiSplitname(vA, _FsiNameNE);
    aWie # 'COPY';
  end
  else begin
    RecBufDestroy(v916);
    RETURN false;
  end;

  if (aRecList<>0) and (aNachDatei<>0) then begin
  //  Erx # RecRead(916, aRecList->wpdbselection, _recLast);
  //  if (Erx<>_rOK) then vNr # 1
  //  else vNr # Anh.lfdNr + 1;
    RecBufClear(916);
  end;


  // Verknüpfen?
  if (aWie='LINK') then begin
    Anh.Datei           # aNachDatei;
    Anh.File            # StrCut('->'+vFilename,1,250);
    Anh.Key             # aNachKey;
    Anh.BlobID          # v916->Anh.BlobID;
    Anh.Link.Datei      # v916->Anh.Datei;
    Anh.Link.Key        # v916->Anh.Key;
    Anh.Link.lfdNr      # v916->Anh.lfdnr;
    Anh.Link.ID         # v916->Anh.ID;
    Anh.Bemerkung       # v916->Anh.Bemerkung;
    Anh.Name            # aName;
    Anh.Typ             # aTyp;
//    Anh.lfdnr           # vNr;
    Insert(v916->Anh.ID);

  end
  // COPY...
  else if (aWie='COPY') then begin

   if (gDBAConnect=0) and (vDBACon=0) then begin
      if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBACon # 3
      else begin
        RecBufDestroy(v916);
        RETURN false;;
      end;
    end;

    // nach 916?
    if (aNachPfad='') then begin
     vPath2 # Anh_Data:CreateBLOBPath(aNachDatei, aNachKey);
      if (vPath2='') then begin
        if (vDBACon<>0) then DbaDisconnect(vDBACon);
        RecBufDestroy(v916);
        RETURN false;
      end;
    end
    // direkt nach Blob...
    else begin

      Erx # Lib_blob:Exists(var vOK, aNachPfad, vFilename, cDBA);
      if (erx<>_rOK) then RETURN false;
      if (vOK) then begin
        if (Lib_blob:Recht(aNachPfad+'\'+vFilename, 'E', cDBA)=false) then begin
          RecBufDestroy(v916);
          Msg(917005,' ('+vFilename+')',0,0,0);
          RETURN true;
        end;
        vOK # y;
      end;
      if (vOK) then begin
        if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then begin
          recBufDestroy(v916);
          RETURN true;
        end;
        vExists # true;   // 03.02.2022 AH
      end;
      vPath2 # aNachPfad;

    end;

//debugx('copy '+vPath+'\'+vFilename+' ---> '+vPath2);
    vI # Lib_Blob:Copy(vPath+'\'+vFilename, vPath2, cDBA, 0, false, var vBlobID);
    if (vDBACon<>0) then DbaDisconnect(vDBACon);
    if (vI<>_ErrOK) then begin
      RecBufDestroy(v916);
      RETURN false;
    end;

    if (aNachDatei<>0) and (vExists=false) then begin
      RecBufCleaR(916);
      Anh.Datei           # aNachDatei;
      Anh.File            # StrCut(''+vFilename,1,250);
      Anh.Key             # aNachKey;
      Anh.BlobID          # vBlobID;
      Anh.Link.Datei      # 0;
      Anh.Link.Key        # '';
      Anh.Link.lfdNr      # 0;
      Anh.Link.ID         # 0;
      Anh.Bemerkung       # v916->Anh.Bemerkung;
      Anh.Name            # aName;
      Anh.Typ             # aTyp;
//      Anh.lfdnr           # vNr;
      Insert();
    end;
  end
  else begin
    RecBufDestroy(v916);
    RETURN false;
  end;

  if (aRecList<>0) and (aNachDatei<>0) then begin
    if (aRecList->wpDbSelection<>0) then
      SelRecInsert(aRecList->wpDbSelection,916);
    aRecList->winupdate(_winupdon, _WinLstFromFirst);
  end;

  RecBufDestroy(v916);

  RETURN true;
end;


//========================================================================
//   FindArchivName
//
//========================================================================
sub FindArchivName(
  aFilename : alpha(2000);
  aDatei    : int;
  aKey      : alpha;
) : alpha;
local begin
  vPath       : alpha(2000);
  vA          : alpha;
end;
begin

  vPath # Set.ExtArchiev.Path;
  vA # SbrName(aDatei,1);           // z.B. Adr.P.Hauptdaten
  vA # fsisplitname(vA,_fsinameN);  // z.B. Adr.P
  vA # Lib_FileIO:NormalizedFilename(vA);
  vPath # vPath + vA;               // z.B. "W:\store\Adr"

  // AFX
  Gv.Alpha.01 # '';
//  Call('Test+2:myAFX', aint(aDatei)+'|'+aKey);
  if (RunAFX('AnH.FindArchivName', aint(aDatei)+'|'+aKey)<>0) and (AfxRes=_rOK) then
    vPath # vPath + Gv.Alpha.01;

  Lib_FileIO:CreateFullPath(vPath);
  vPath # vPath + '\';              // z.B. "W:\store\Adr\"

  REPEAT
    if (lib_fileio:FileExists(vPath + aFilename)) then begin
      Msg(998018,'',0,0,0);
      if (Dlg_Standard:Standard(Translate('Dateinamen')+':', var aFilename)=false) then RETURN '';
      CYCLE;
    end;
  UNTIL (1=1);
  aFilename # vPath + aFilename;

  RETURN aFilename;
end;


//========================================================================
//========================================================================
sub _Convert(aDatei : int) : int
begin
  case Anh.Link.Datei of
    200 : RETURN 210;
    400 : RETURN 410;
    401 : RETURN 411;
    460 : RETURN 470;
    500 : RETURN 510;
    501 : RETURN 511;
    540 : RETURN 545;
    655 : RETURN 656;

    210 : RETURN 200;
    410 : RETURN 400;
    411 : RETURN 401;
    470 : RETURN 460;
    510 : RETURN 500;
    511 : RETURN 501;
    545 : RETURN 540;
    656 : RETURN 655;
    otherwise RETURN -1;
  end;
end;


//========================================================================
//  Execute
//
//========================================================================
Sub Execute() : logic;
local begin
  Erx         : int;
  vPath       : alpha(4000);
  vName       : alpha(4000);
  vDBAConnect : int;
  v916        : int;
  vDatei      : int;
  vZLList     : int;
  vSep        : alpha;
  vDokIdSC    : int;
end;
begin

  vZLList # gZLList;;

  // Anhang ist angegeben....
  if (Anh.File = '') then RETURN false;
  
  // Ankerfunktion 'DMS.Show' aktivieren, falls es sich um ein EcoDMS Dokument handelt. Damit können also EcoDMS Dokumente
  // per Doppelklick auf entsprechenden Anhang geöffnet werden, sofern 'DMS.Show' auf Funktion SFX_EcoDMS:AFX.ShowDocument zeigt.
  if (StrCnv(Anh.Typ, _StrLower) = 'ecodms') then
  begin
    vSep # 'Stahl-Control Dok.Nummer: ';
    if StrCut(Anh.File, 1, StrLen(vSep)) = vSep then
    begin
      vDokIdSC # CnvIA(Lib_Strings:Strings_Token(Anh.File, vSep, 2));
      if (RunAFX('DMS.Show', aint(vDokIdSC)) < 0) then
      begin
        return true;
      end
    end
  end
 
  if (Anh.File=*^'HTTP*') then begin    // 16.02.2022 AH
    SysExecute('*'+anh.file,'',0);
    RETURN true;
  end;
  
  if (Lib_FileIO:FileExists(Anh.File)) then begin
    // EXTERN öffnen
    SysExecute('*'+Anh.File,'',0);
    RETURN true;
  end;

  // als BLOB öffnen?
  if (Set.ExtArchiev.Path='CA1') then begin
    if (gDBAConnect=0) then begin
      if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
      else RETURN false;
    end

    // Verknüpfung???;
    if (Anh.Link.Datei<>0) then begin
      v916 # RekSave(916);
      Anh.Datei     # Anh.Link.Datei;
      Anh.Key       # Anh.Link.Key;
      Anh.lfdNr     # Anh.Link.LfdNr;
      Anh.ID        # Anh.Link.ID;
      Erx # RecRead(916,1,0);
      // ABLAGE??
      if (Erx>_rLocked) then begin
        Anh.Link.Datei # _Convert(Anh.Link.Datei);
        if (Anh.Link.Datei<=0) then begin
          RekRestore(v916);
          if (vDbaConnect<>0) then DbaDisconnect(vDbaConnect);  // 28.09.2015
          RETURN false;
        end;

        Anh.Datei     # Anh.Link.Datei;
        Anh.Key       # Anh.Link.Key;
        Anh.lfdNr     # Anh.Link.LfdNr;
        Anh.ID        # Anh.Link.ID;
        Erx # RecRead(916,1,0);
        if (Erx>_rLocked) then begin
          RekRestore(v916);
          if (vDbaConnect<>0) then DbaDisconnect(vDbaConnect);  // 28.09.2015
          RETURN false;
        end;
      end;
    end

    vPath # 'Anhänge\'+aint(Anh.Datei)+'\'+Anh.Key+'\'+Anh.File;
    vName # Lib_Blob:Execute(vPath, cDBA);
    if (vName='') then begin
      vDatei # _Convert(Anh.Datei);
      if (vDatei>0) then begin
        vPath # 'Anhänge\'+aint(vDatei)+'\'+Anh.Key+'\'+Anh.File;
        vName # Lib_Blob:Execute(vPath, cDBA);
      end;
    end;
    if (vDBAConnect<>0) then DbaDisconnect(vDBAConnect);

    if (v916<>0) then RekRestore(v916);

    if (vName<>'') then Lib_Jobber:WatchFile(vName, vPath);

    RETURN true;
  end;

  RefreshList(vZllist, _WinLstRecFromRecid | _WinLstRecDoSelect); // 15.02.2021 AH: VBS vespringt?

end;


//========================================================================
//  Delete
//
//========================================================================
Sub Delete() : int;
local begin
  Erx         : int;
  vPath       : alpha(4000);
  vDBAConnect : int;
end;
begin

  // Anhang ist angegeben....
  if (Anh.File = '') then RETURN _rOK;

  // nur Verknüpfung? JA -> Blob NICHT löschen!
  if (Anh.Link.Datei<>0) then begin
    RETURN _rOK;
  end;

  // als BLOB löschen?
  if (Set.ExtArchiev.Path='CA1') then begin
    if (gDBAConnect=0) then begin
      if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
      else RETURN _rNoRec;
    end;
    vPath # 'Anhänge\'+aint(Anh.Datei)+'\'+Anh.Key;
    Erx # Lib_Blob:Delete(Anh.File, vPath, cDBA, 0);
    if (vDBAConnect<>0) then begin
      DbaDisconnect(vDBAConnect);
    end;
    RETURN Erx;
  end;


  // EXTERN löschen
  // nur, wenn im allgeminene ArchivPfad:
  if (StrFind(Anh.File, Set.ExtArchiev.Path,0, _StrCaseIgnore)=1) then
    FSIDelete(Anh.File);

  RETURN _rOK;
end;


//========================================================================
//  _MoveToBlob()
//  Verschiebt eine Datei vom Dateisystem in die Blob Datenbank
//========================================================================
sub _MoveToBlob(aDatei : int; aKey : alpha; aLfndNr : int; aDba : int) : int
local begin
  Erx       : int;
  vBuff916  : int;
  vAnhKey   : alpha;
  vFile     : int;
  vFilename : alpha(4000);
  vBlobPath : alpha(1000);
  vBlobId   : int;
end
begin
  vBuff916 # RekSave(916);

  vAnhKey   # Aint(aDatei) + '/' + aKey + '/' +Aint(aLfndNr);     // Für Fehlerausgaben

  Anh.Datei   # aDatei;
  Anh.Key     # aKey;
  Anh.lfdNr   # aLfndNr;
  Erx # Recread(916,1,0);
  if (Erx <> _rOK) then begin
    proto('Anhang konnte nicht gelesen werden: ' + vAnhKey);
    RekRestore(vBuff916);
    RETURN -1;
  end;

  // Bei Link, die Quelle aufrufen und die Verschieben
  if (Anh.Link.Datei <> 0) then begin
    RekRestore(vBuff916);
    RETURN _MoveToBlob(aDatei, aKey, aLfndNr, aDba);
  end;

  // Anhang ist schon verknüpft oder kein Pfad angegeben -> nichts tun
  if (Anh.BlobID <> 0) OR  (Anh.File = '')  OR
     ((StrFind(Anh.File,':\',1)=0) AND (StrFind(Anh.File,'\\',1)=0)) then begin
    RekRestore(vBuff916);
    RETURN 0;
  end;


  vBlobPath  # CreateBLOBPath(Anh.Datei, Anh.Key, aDba); // Verzeichnis erstellen
  if (vBlobPath <> '') then begin

    Lib_Blob:Import(Anh.File,vBlobPath, aDba, 0,n, var vBLobId);
    if (Erx=_rOK) and (vBLobId <>  0) then begin
      // Blob erfolgreich verschoben
      Erx # RecRead(916,1,_RecLock);
      if (Erx <> _rOK) then begin
        proto('Anhang konnte nicht gesperrt werden:' + vAnhKey);
        RekRestore(vBuff916);
        RETURN -1;
      end;

      Anh.BlobID # vBLobId;
      Anh.File # FsiSplitName(Anh.File,_FsiNameNE);

      Erx # RekReplace(916,_RecUnlock,'MAN');
      if (Erx <> _rOK) then begin
        proto('Anhang konnte nicht gespeichert werden:' + vAnhKey);
        RekRestore(vBuff916);
        RETURN -1;
      end;

    end
    else begin
      proto('Konnte nicht verschoben werden (' + vAnhKey + '):');
      proto(Anh.File);
      proto('');
      RekRestore(vBuff916);
      RekDelete(916);
      RETURN -1;
    end;

  end;

  RekRestore(vBuff916);
end;


//========================================================================
//  MoveToBlob()
//
//========================================================================
sub ConvertAnhToBlob() : int
local begin
  Erx         : int;
  vProgress   : int;
  vDBAConnect : int;
  vErr        : int;
  vExtAchivPfad : alpha;
end
begin

  if (gDBAConnect=0) then begin
    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then
       vDBAConnect # cDBA
    else
      RETURN -1;
  end;

  // Protokoll öffnen
  cProtokoll # TextOpen(20);


  // Pfad für den Export setzen
  vExtAchivPfad # Set.ExtArchiev.Path;
  Set.ExtArchiev.Path  #  'CA1';

  // Alle Anhänge durchlaufen
  vProgress # Lib_Progress:Init('Verschiebe Daten in Archivdatenbank',RecInfo(916,_RecCount));
  FOR   Erx # RecRead(916,1,_RecFirst)
  LOOP  Erx # RecRead(916,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then
      break;

    // Anhang verschieben
    if (_MoveToBlob(Anh.Datei, Anh.Key, Anh.lfdNr, vDBAConnect) < 0) then
      inc(vErr);

  END;
  vProgress->Lib_Progress:Term();

  try begin
    ErrTryIgnore(_ErrValueRange, _ErrValueInvalid);
    DbaDisconnect(3);
  end;
  ErrSet(_ErrOK);

  proto('----------------------------------------------------------');
  proto('   Import abgeschlossen');
  proto('----------------------------------------------------------');
  if (vErr = 0) then begin
    proto('Die Quelldaten sind komplett in die Archivdatenbank');
    proto('übertragen worden worden und können jetzt gelöscht/verschoben werden');
  end;

  // Protokoll schließen und anzeigen
  TxtDelete(myTmpText,0);
  TxtWrite(cProtokoll,MyTmpText,0);
  TextClose(cProtokoll);
  Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll','',gFrmMain);
  TxtDelete(myTmpText,0);

  Set.ExtArchiev.Path # vExtAchivPfad;

end;


//========================================================================
//========================================================================
sub Check(aFile : int) : int
local begin
  Erx     : int;
  vA      : alpha;
  vFilter : int;
  vFile   : int;
end;
begin
  if (aFile=0) then RETURN _rNoRec;

  vA # MakeKey(aFile);
  vFilter # RecFilterCreate(916,1);
  vFilter->RecFilterAdd(1,_fltAnd,_FltEq, aFile);
  vFilter->RecFilterAdd(2,_Fltand,_FltEq, StrCut(vA,1,64));
  Erx # RecRead(916,1,_recFirst|_RecTest, vFilter);
  vFilter->RecFilterDestroy();
  
  //DebugM(__PROCFUNC__ + ':' + cCrlf + 'aFile: ' + CnvAI(aFile) + cCrlf + 'vA: ' + vA);

  // 2022-07-04 AH : Köpfe einbeziehen
  // 2022-09-26 AH Umbau auf Remap
  if (Erx>_rLocked) then begin
    vFile # Remap(aFile, false);   // 2022-09-26 AH
    if (vFile=aFile) then RETURN Erx;

    vA # MakeKey(vFile);
    vFilter # RecFilterCreate(916,1);
    vFilter->RecFilterAdd(1,_fltAnd,_FltEq, vFile);
    vFilter->RecFilterAdd(2,_Fltand,_FltEq, StrCut(vA,1,64));
    Erx # RecRead(916,1,_recFirst|_RecTest, vFilter);
    vFilter->RecFilterDestroy();
  end;

  RETURN Erx;
end;


//========================================================================
//========================================================================
// GssEziSort Freeware: CmdTwain
//========================================================================
//========================================================================
Sub CmdTwain_Execute(aSetting : alpha(4095)) : logic
local begin
  vApp    : alpha(4000);
  vPath   : alpha(4000);
  vBonus  : int;
  vI      : int;
end;
begin
  vBonus # VarInfo(Windowbonus);

  vApp  # 'GssEziSoft\CmdTwain\cmdtwain.exe';
  vPath # Lib_FileIO:FindInstalledApp(vApp);
  if (vPath='') then begin
    Msg(99, 'GssEziSoft-CmdTwain NICHT installiert!',0,0,0);
    RETURN false;
  end;

  vI # SysExecute(vPath, aSetting, _ExecWait);

  if (vBonus<>0) then Varinstance(Windowbonus, vBonus);

  RETURN (vI=_errOK);
end;
    

//========================================================================
Sub CmdTwain_Scan(aPara : alpha(4096)): int
local begin
  vPara   : alpha(4000);
  vName   : alpha(4000);
  vHdl    : int;
end;
begin

  GV.Alpha.01 # '';
  vName # lib_Strings:Strings_Win2Dos(SysGetEnv('TEMP'))+'\StahlControl\Scan';
  Lib_FileIO:CreateFullPath(vName);
  vName # vName+'\'+gUsername+'.pdf';
  FsiDelete(vName);


  vPara # Usr_Data:ReadValue('CmdTwain');
  if (vPara='') then begin
    Msg(99,'Bitte den Scanner erst für diesen User einrichten!',0,0,0);
    RETURN -1;
  end;
  
//debug('ini:'+vPAra);
  // "DPI 300 GRAY ADF 1 AS 1 DPX 1"
  // "DPI 300 COLOR ADF 1 AS 1 DPX 1"

  vPara # '-c "'+vPara+'" PDF3 '+vName;
  if (CmdTwain_Execute(vPara)) then begin
    if (Lib_FileIO:FileExists(vName)) then begin
      vHdl # FsiOpen(vName,_FsiAcsR);
      if (vHdl>0) then begin
        if (FsiSize(vHdl)>1000) then begin    // nur wenn das PDF "gescheit" gross ist
          GV.Alpha.01 # vName;
        end;
        FsiClose(vHdl);
      end;
    end;
  end;
  
  RETURN -1;
end;


//========================================================================
//========================================================================
Sub CmdTwain_Settings(aPara : alpha(4096)): int
local begin
  vPara : alpha(250);
end;
begin
  
  if (CmdTwain_Execute('/source')) then begin
    vPara # Usr_Data:ReadValue('CmdTwain');
    if (Dlg_Standard:Standard('Parameterstring',var vPara)) then begin
      Usr_Data:SaveValue('CmdTwain', vPara);
    end;
  end;
    
  RETURN -1;
end;


//========================================================================
//========================================================================
sub Comment(
  aDatei  : int;
  aRoot   : logic;)
local begin
  vA    : alpha(250);
  vKey  : alpha;
  v916  : int;
  vHdl  : int;
end;
begin

  vKey # Anh_Data:MakeKey(aDatei);
  if (aDatei=916) then v916 # RekSave(916);
  
  if (Dlg_Standard:Standard(translate('Kommentar'),var vA, n, 250)=false) then begin
    if (v916<>0) then RekRestore(v916);
    RETURN;
  end;
  
  RecBufClear(916);
  if (aDatei=916) then begin
    if (aRoot) then begin
      vHdl # gMDI->winsearch('lb.key1');
      if (vHdl<>0) then
        Anh.Datei # cnvia(vHdl->wpcustom);
      vHdl # gMDI->winsearch('lb.key2');
      if (vHdl<>0) then
        Anh.Key   # vHdl->wpcustom;
//debugx(aint(anh.datei)+'/'+anh.key);
    end
    else begin
      Anh.Datei         # v916->Anh.Datei;
      Anh.Key           # v916->Anh.Key;
      Anh.ZuID          # v916->Anh.ZuID; // immer auf ROOT
    end;
  end
  else begin
    Anh.Datei         # aDatei;
    Anh.Key           # vKey;
  end;
  
  Anh.File          # '';
  Anh.Bemerkung     # vA;
  Insert();

end;


//========================================================================
// call Anh_data:LaufSetID
//========================================================================
sub LaufSetID()
local begin
  Erx   : int;
  vBig  : bigint;
  v916  : int;
end;
begin

  Erx # RecRead(916,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Anh.ID<>0) then begin
      Erx # RecRead(916,1,_recNext);
      CYCLE;
    end;
    
    if (Anh.Anlage.Datum=0.0.0) then
      vBig # cnvit(Anh.Anlage.Zeit)
    else
      vBig # MakeTS(Anh.Anlage.Datum, Anh.Anlage.Zeit);
      
//debug('aus KEY916');
    v916 # RekSave(916);
    REPEAT
      Anh.ID            # vBig;
      Erx # RecRead(916,3,_recTest);
      if (Erx<=_rMultikey) then begin
        inc(vBig);
        CYCLE;
      end;
    UNTIL (1=1);
    RekRestore(v916);

    RecRead(916,1,_RecLock);
    Anh.ID            # vBig;
    Anh.ZuID          # vBig;
    Erx # RecReplace(916,_recUnlock);
/***
    RecRead(916,1,_RecLock);
    REPEAT
      Anh.ID            # vBig;
      Erx # RecReplace(916,_recUnlock);
      if (Erx<>_rOK) then begin
        inc(vBig);
        CYCLE;
      end;
    UNTIL (1=1);
***/
//debug('wird KEY916');

    Anh.ID # 0;
    Erx # RecRead(916,1,0);
    Erx # RecRead(916,1,0);
  END;

  // LinkIDs verbinden.....
  v916 # RecBufCreate(916);
  FOR Erx # RecRead(916,1,_recFirst)
  LOOP Erx # RecRead(916,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Anh.Link.Datei=0) then CYCLE;

    v916->Anh.Datei # Anh.Link.Datei;
    v916->Anh.Key   # Anh.Link.Key;
    v916->Anh.lfdNr # Anh.Link.lfdNr;
    v916->Anh.Id    # 0;
    Erx # RecRead(v916,1,0);
    if (Erx<_rNoRec) and (v916->Anh.Datei=Anh.Link.Datei) and
      (v916->Anh.Key=Anh.Link.Key) and (v916->Anh.lfdNr=Anh.Link.lfdNr) then begin
      RecRead(916,1,_RecLock);
      Anh.Link.ID # v916->Anh.ID;
      RecReplace(916,_recunlock);
    end;
  END;
  RecBufDestroy(v916);
  
end;


//========================================================================
//========================================================================
sub _Export1AnhInner(
  aName     : alpha(1000);
  aPathFunc : alpha(1000);
  aDBA  : int;
) : alpha
local begin
  vZiel : alpha(1000);
end;
begin
  vZiel # call(aPathFunc);
  
  if (Lib_Blob:Export(aName, vZiel, aDBA, true)<>_errOK) then RETURN '';
  aName # FsiSplitName(aName, _FsiNameNE);
  RETURN vZiel+'\'+aName;
end;


//========================================================================
//========================================================================
sub _Export1Anh(
  aPathFunc : alpha(1000);
)
local begin
  vPath   : alpha(1000);
  vName   : alpha(1000);
  vDatei  : int;
end;
begin
  vPath # 'Anhänge\'+aint(Anh.Datei)+'\'+Anh.Key+'\'+Anh.File;
  vName # _EXport1AnhInner(vPath, aPathFunc, cDBA);

  if (vName='') then begin
    vDatei # _Convert(Anh.Datei);
    if (vDatei>0) then begin
      vPath # 'Anhänge\'+aint(vDatei)+'\'+Anh.Key+'\'+Anh.File;
        vName # _EXport1AnhInner(vPath, aPathFunc, cDBA);
    end;
  end;
//debugx(vName);
end;


//========================================================================
//========================================================================
sub _ExportAnhs(
  aFile : int;
  aZiel : alpha(1000));
local begin
  Erx     : int;
  vA      : alpha;
  vFilter : int;
end;
begin
  vA # MakeKey(aFile);
  vFilter # RecFilterCreate(916,1);
  vFilter->RecFilterAdd(1,_fltAnd,_FltEq, aFile);
  vFilter->RecFilterAdd(2,_Fltand,_FltEq, StrCut(vA,1,64));
  
  // Anhänge loopen...
  FOR Erx # RecRead(916,1,_recFirst, vFilter)
  LOOP Erx # RecRead(916,1,_recNext, vFilter)
  WHILE (Erx<=_rLocked) do begin
    _Export1Anh(aZiel);
  END;
  
  vFilter->RecFilterDestroy();
end;


//========================================================================
//  ExportBereich
//
//========================================================================
Sub ExportBereich(
  aFile     : int;
  aNameFunc : alpha;)
: logic;
local begin
  Erx         : int;
  vDBAConnect : int;
end;
begin

  // als BLOB öffnen?
  if (Set.ExtArchiev.Path<>'CA1') then RETURN false;

  if (gDBAConnect=0) then begin
    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
    else RETURN false;
  end

  // Datei loopen...
  FOR Erx # RecRead(aFile,1,_recfirst)
  LOOP Erx # RecRead(aFile,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    _ExportAnhs(aFile, aNameFunc);
  END;

  if (vDBAConnect<>0) then DbaDisconnect(vDBAConnect);
end;
  

//========================================================================
// ReadByTypName
//========================================================================
sub ReadByTypName(
  aDatei  : int;
  aKey    : alpha;
  aTyp    : alpha;
  aName   : alpha) : logic
local begin
  Erx : int;
end;
begin
  RecBufClear(916);
  Anh.Datei # aDatei;
  Anh.Key   # aKey;
  Anh.Typ   # aTyp;
  Anh.Name  # aName;
  Erx # RecRead(916,6,0);
  RETURN (Erx<=_rMultikey);
end;



//========================================================================
//  2022-04-04  DS                                               2222/51/1
//
//  Liefert Namen der Anhänge als String Array
//========================================================================


sub getAttachmentFilenames
(
  // Nummer der Tabelle aus der Anhänge geliefert werden sollen.
  // Es wird angenommen dass beim Aufruf dieser Funktion der Feldpuffer dieser Tabelle auf den Datensatz zeigt um dessen Anhänge es gehen soll,
  // d.h. es werden NICHT ALLE Anhänge zu der Tabellennummer geliefert, sondern nur die Anhänge zu den aktuell im Feldpuffer befindlichen Primärschlüssel-Werten.
  aTableNumber                : int;
  // Array in das die Dateinamen der Anhänge eingelesen werden. Länge der Strings wird vom Aufrufer festgelegt und sollte mindestens 250 Zeichen sein.
  // Wird in der Funktion allokiert und muss vom Aufrufer wieder deallokiert werden (VarFree()).
  var aOutAttachmentFilenames : alpha[];
) : logic  // gibt es Anhänge?
local begin
  Erx                         : int;
  vAttKey                     : alpha;
  vNumAttachments             : int;
  vIdx                        : int;
  vRetVal                     : logic;
end
begin

  // init
  RecBufClear(916);
  vAttKey # MakeKey(aTableNumber);  // erzeugt den Anh.Key den der aktuell im Feldpuffer von aTableNumber stehende Datensatz in 916 bekommen würde
  Anh.Datei # aTableNumber;
  Anh.Key # vAttKey;
  Anh.LfdNr # 1;
  Anh.ID # 0;
  Erx # RecRead(916,1,0);
  
  // finde Anzahl der Anhänge:
  vNumAttachments # 0;
  WHILE (Erx < _rNoRec) AND (Anh.Datei = aTableNumber) AND (Anh.Key = vAttKey) DO
  BEGIN
    Inc(vNumAttachments)
    Erx # RecRead(916,1,_RecNext);
  END;
  
  if vNumAttachments = 0 then
  begin
    vRetVal # false;
  end
  else
  begin
    // iteriere zweites Mal über Anhänge und schreibe Dateinamen in aOutAttachmentFilenames
    VarAllocate(aOutAttachmentFilenames, vNumAttachments);

    RecBufClear(916);
    Anh.Datei # aTableNumber;
    Anh.Key # vAttKey;
    Anh.LfdNr # 1;
    Anh.ID # 0;
    Erx # RecRead(916,1,0);
  
    vIdx # 0;
    WHILE (Erx < _rNoRec) AND (Anh.Datei = aTableNumber) AND (Anh.Key = vAttKey) DO
    BEGIN
      Inc(vIdx)
      aOutAttachmentFilenames[vIdx] # Anh.File;
      Erx # RecRead(916,1,_RecNext);
    END;
    
    vRetVal # true;

  end
  
  return vRetVal
end



//========================================================================
//  2022-05-23  DS                                               2407/3
//
//  Lädt zum aktuell geladenen Dokument (915) den entsprechenden
//  Anhang (916), anhand von Dok.ZuAnhID.
//========================================================================
sub readAnhFromDok
(
) : int  // Fehlercode < 0 oder 0 bei Erfolg
local begin
  recID : bigint;
  Erx   : int;
end
begin

  RecBufClear(916);

  recID # Dok.ZuAnhID;

  if recID <= 0 then
  begin
    return -100000;  // Steht für Fehler dass Verweis in Dokument nicht gesetzt (also leeres Dok.ZuAnhID)
  end
  else
  begin
    // Anhang von Dok laden
    Erx # RecRead(916, 0, _recID, recID);
    return Erx;
  end
  
end



//========================================================================
//  2022-05-23  DS                                               2407/3
//
//  Lädt zum aktuell geladenen Anhang (916) das entsprechende
//  Dokument (915), anhand von Anh.ZuDokID.
//========================================================================
sub readDokFromAnh
(
) : int  // Fehlercode < 0 oder 0 bei Erfolg
local begin
  recID : bigint;
  Erx   : int;
end
begin

  RecBufClear(915);

  recID # Anh.ZuDokID;

  if recID <= 0 then
  begin
    return -100000;  // Steht für Fehler dass Verweis in Anhang nicht gesetzt (also leeres Anh.ZuDokID)
  end
  else
  begin
    // Dok von Anhang laden
    Erx # RecRead(915, 0, _recID, recID);
    return Erx;
  end
  
end




/*
========================================================================
2022-10-27  DS                                               für BSC

Ersetzt einen gegebenen Basis-Pfad von Anhängen in Tabelle 916
durch ein neues Basis-Verzeichnis. Dies bezieht sich ausschließlich auf
Anhänge die im Filesystem liegen!
========================================================================
*/
sub __cleanup_replaceAttachmentsBasePath
(
  Erx         : int;
  aOperation  : alpha(256);
  aIdx        : int;
)
begin
  TRANSBRK;
  DebugM('Fehler "' + ErrMapText(Erx) + '" (Erx=' + CnvAI(Erx) + ') bei "' + aOperation + '" auf Datensatz ' + CnvAI(aIdx));
end


sub replaceAttachmentsBasePath
(
  aOldBasePath  : alpha(256);
  aNewBasePath  : alpha(256);
) : int // Erx-ish
local begin
  Erx                         : int;
  vCurrentAnh.File            : alpha(512);
  vIdx                        : int;
end
begin

  if _WinIdNo = WinDialogBox(
    0,
    __PROCFUNC__,
    'ACHTUNG: Wenn Sie "Ja" klicken, wird der Basis-Pfad aller Anhänge DAUERHAFT von "' + aOldBasePath + '" auf "' + aNewBasePath + ' umgebogen!' + cCrlf2  +
    'Sind Sie SICHER?',
    _WinIcoQuestion,
    _WinDialogYesNo,
    0)
  then
  begin
    return -1;
  end

  // init
  RecBufClear(916);
  
  vIdx # 1;
  
  TRANSON;

  Erx # RecRead(916, 1, _RecFirst);
  if Erx <> _ErrOK then
  begin
    __cleanup_replaceAttachmentsBasePath(Erx, 'RecRead(..._RecFirst)', vIdx);
    return Erx;
  end
  
  WHILE (Erx = _ErrOK) DO
  BEGIN
  
    // Pfad anpassen
    vCurrentAnh.File # Anh.File;
    if StrCnv(StrCut(vCurrentAnh.File, 1, StrLen(aOldBasePath)), _StrUpper) = StrCnv(aOldBasePath, _StrUpper) then
      // nur wenn der Pfad aus 916 mit aOldBasePath beginnt (case-insensitive)...
    begin
      // ergebnis = neuer pfad + pfad des Anhangs von dem alter pfad abgeschnitten wurde:
      vCurrentAnh.File # aNewBasePath + StrCut(vCurrentAnh.File, StrLen(aOldBasePath)+1, 4096);
    end
    
    //DebugM('alt: ' + cCrlf + Anh.File + cCrlf2 + 'neu: ' + cCrlf + vCurrentAnh.File);
    
    // sperren
    Erx # RecRead(916, 1, _RecLock);
    if Erx <> _ErrOK then
    begin
      __cleanup_replaceAttachmentsBasePath(Erx, 'RecRead(..._RecLock)', vIdx);
      return Erx;
    end
    
    // schreiben inkl. Entsperren danach
    Anh.File # vCurrentAnh.File;
    Erx # RekReplace(916, _RecUnlock);
    if Erx <> _ErrOK then
    begin
      __cleanup_replaceAttachmentsBasePath(Erx, 'RekReplace(..._RecUnlock)', vIdx);
      return Erx;
    end
  
    // next
    Erx # RecRead(916, 1 ,_RecNext);
    if Erx <> _ErrOK and Erx <> _rLastRec and Erx <> _rNoRec then
    begin
      __cleanup_replaceAttachmentsBasePath(Erx, 'RecRead(..._RecNext)', vIdx);
      return Erx;
    end
    Inc(vIdx);
    
  END;
  
  if Erx <> _rLastRec and Erx <> _rNoRec then
  begin
    __cleanup_replaceAttachmentsBasePath(Erx, 'Schleife wurde weder mit Erx=_rLastRec noch Erx=_rNoRec verlassen.' + cCrlf2 + 'Was ist da los?', vIdx);
    return Erx;
  end
  
  // erst wenn alles passt, "committen":
  TRANSOFF;
    
  return _ErrOK;
end





/*
========================================================================
2023-01-06  ST                                          2405/11

Durch läuft alle Anhänge und prüft, ob die Datei auch im Blobspeicher
vorhanden ist und erstellt ein Logfile mit den Prüfergebnissen

call Anh_Data:CheckBlobIntegrity

========================================================================
*/
sub CheckBlobIntegrity()
local begin
  Erx       : int;
  vPrgr     : int;
  vFileName : alpha(1000);
  vFileHdl : handle;
  vLine     : alpha(1000);
  vOK       : logic;
  
  vDBAConnect : int;
  vBlobPath   : alpha(1000);
end
begin

  // als BLOB öffnen?
  if (Set.ExtArchiev.Path<>'CA1') then begin
    MsgErr(99,'Blobdatenbank nicht eingestellt, sondern: "' + Set.ExtArchiev.Path + '" anstatt CA1');
    RETURN;
  end;


  if (gDBAConnect=0) then begin
    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then
      vDBAConnect # 3;
    else
      MsgErr(99,'Blobdatenbank konnte nicht geöffnet werden');
  end
  
  vFileName # Lib_FIleIO:FileIO(_WINCOMFILESAVE,0,'','.csv','BlobIntegrityLog-'+CnvAd(today)+ '.csv');

  if (vFilename = '') then
    RETURN;

  vFileHdl  # FsiOpen(vFilename,_FsiStdWrite);
  
  
  // Header schreiben
  vLine # '"ID";"Key";"Bereich";"Vorgang";"Dateiname";"BlobPfad";"gefunden";"Anlage am";"Anlage um";"USer";'+cCRLF;
  FsiWrite(vFileHdl,vLine);
   
  // Progress Init
  vPrgr # Lib_Progress:Init('Prüfe Anhänge',RecInfo(916,_RecCount));
  FOR   Erx # RecRead(916,1,_RecFirst)
  LOOP  Erx # RecRead(916,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    if (vPrgr->Lib_Progress:Step() = false) then begin
      vLine # 'BENUTZERABBRUCH'+cCRLF;
      FsiWrite(vFileHdl,vLine);
      BREAK;
    end;

    vOK # true;
    vBlobPath  # '\Anhänge\'+aint(Anh.Datei)+'\' + Anh.Key;
    Erx # Lib_Blob:Exists(var vOK, vBlobPath,Anh.File,cDBA);
    
    vLine # CnvAB(Anh.ID)                         + ';'  +
                  Anh.Key                         + ';'  +
            Aint( Anh.Datei)                      + ';'  +
            '"' + FIleName(anh.DAtei)+ '"'        + ';'  +
            '"' + Anh.File         + '"'          + ';'  +
            '"' + vBlobPath         + '"'         + ';'  +
            Aint( CnvIl(vOK))                     + ';'  +
            '"' + CnvAd(Anh.Anlage.Datum)  +'"'   + ';'  +
            '"' + CnvAT(Anh.Anlage.Zeit)   +'"'   + ';'  +
            '"' + Anh.Anlage.User          + '"'  + ';'  + cCRLF;

    FsiWrite(vFileHdl,vLine);
  END;
   
  // Progress Term
  if (vDBAConnect<>0) then
    DbaDisconnect(vDBAConnect);
    
  vPrgr->Lib_Progress:Term();

  FsiClose(vFileHdl);
 
  MsgInfo(99,'Prüfung abgeschlossen');
end;




/*
========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/
MAIN()
local begin
  Erx    : int;
  vAlpha : alpha;
  vInt   : int;
  vLogic : logic;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  
  
  /*
  // DIESER CODE IST NICHT ZUM TESTEN / KEIN SPIELZEUG! (siehe Doku von replaceAttachmentsBasePath)
  //Erx # replaceAttachmentsBasePath('n:\qualitätswesen', 'm:\qualitätswesen_test');
  //DebugM('Ausgabe von replaceAttachmentsBasePath(): ' + CnvAI(Erx));
  // revert:  Erx # replaceAttachmentsBasePath('m:\qualitätswesen_test', 'n:\qualitätswesen');
  */
  

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end

//========================================================================

