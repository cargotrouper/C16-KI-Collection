@A+
//===== Business-Control =================================================
//
//  Prozedur  Anh_Filescanner
//                  OHNE E_R_G
//  Info
//    Enthält Funktionen zum automatisierten Import von Dateianhängen
//
//  01.07.2019  ST  Erstellung der Prozedur
//  02.10.2020  ST  Dokutyp INV für Inventur hinzgefügt
//  01.02.2021  ST  Erweiterung für mehrere Vorgänge (Echte Kopie, kein Link)
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    sub MoveToFailedFolder(aPara : alpha(4000))
//    sub ReadFromKey(aBereich : alpha; aKey : alpha; var aDatei : int) : int
//    sub Attach(aPara : alpha(4000); aBereich : alpha; aKey : alpha; aMetainfo : alpha) : logic
//    sub HandleError()
//    sub ParseMetafile(aPara : alpha(4000)) : logic
//    sub Import(aPara : alpha(4000)) : logic
//    sub ImportFileDialog()
//
//========================================================================
@I:Def_Global

define begin
  cDBA  : _BinDBA3
end;


//========================================================================
//  sub MoveToFailedFolderFolder(aFile : alpha(4000))
//    verschiebt die Datei in den "Fehlerhaft" Ordner
//========================================================================
sub MoveToFailedFolder(aPara : alpha(4000); aFileList : int)
local begin
  vPfad       : alpha(1000);
  vFilename   : alpha;
  vNode       : int;
  vErrListSave : int;
end
begin
  // Failed Ordner erstellen
  vPfad  #  FsiSplitName(aPara,_FsiNameP) + '..' + '\Failed\'+FsiSplitName(aPara,_FsiNameN) +'_'+Lib_Strings:TimestampFullYearMs()+'\';
  Lib_FileIO:CreateFullPath(vPfad);

  // Metadatei Datei verschieben
  vFilename  # FsiSplitName(aPara,_FsiNameNE);
  Lib_FileIO:FsiCopy(aPara, vPfad + vFilename ,true);
    
  // Alle Datein laut Metadaten in den Fehler Ordner verschieben
  FOR   vNode # aFilelist->CteRead(_CteFirst)
  LOOP  vNode # aFilelist->CteRead(_CteNext,vNode)
  WHILE (vNode  <> 0) DO begin
    Lib_FileIO:FsiCopy(vNode->spName, FsiSplitName(vPfad,_FsiNameP) + FsiSplitName(vNode->spName,_FsiNameNE),true);
  end;

  // Fehlermeldungsdatei schreiben
  Lib_Error:ListCopy(var vErrListSave);
  Lib_Error:OutputToFile(vPfad + 'ERROR.txt')
  Lib_Error:ListCopy(var vErrListSave,true);
end;



//========================================================================
//  sub ReadFromKey(aBereich : alpha; aKey : alpha; var aDatei : int) : int
//    Liest den durch Bereich und KEy angegebenen Datensatz
//========================================================================
sub ReadFromKey(aBereich : alpha; aKey : alpha; var aDatei : int) : int
local begin
  vRet  : int;
  Erx   : int;
end
begin
  vRet    # -1;
  aDatei  # 0;

  case StrCnv(aBereich,_StrUpper) of
    'ADR','100' : begin
                    Adr.Nummer # CnvIa(Str_Token(aKey,'/',1));
                    Erx # RecRead(100,1,0);
                    if (Erx = _rok) OR (Erx = _rLocked) then begin
                      vRet    # _rOK;
                      aDatei  # 100;
                    end;
                  end;
                  
    'MAT','200' : begin
              Erx # Mat_Data:Read(CnvIa(Str_Token(aKey,'/',1)));
              if (Erx = 200) OR (Erx = _rLocked) then begin
                vRet    # _rOK;
                aDatei  # 200;
              end;
            end;
    
    'LFS','440','LIEFERSCHEIN' : begin
              Lfs.Nummer # CnvIa(Str_Token(aKey,'/',1));
              Erx # RecRead(440,1,0);
              if (Erx = _rOK) OR (Erx = _rLocked) then begin
                vRet   # _rOK;
                aDatei # 440;
              end;
            end;
   
    'BAG','700' : begin
              Bag.Nummer # CnvIa(Str_Token(aKey,'/',1));
              Erx # RecRead(700,1,0);
              if (Erx = _rOK) OR (Erx = _rLocked) then begin
                vRet    # _rOK;
                aDatei  # 700;
              end;
            end;
    
    'BAGP','702' :  begin
              if (Lib_Strings:Strings_Count(aKey,'_') = 2) then begin
                Bag.P.Nummer    # CnvIa(Str_Token(aKey,'/',1));
                Bag.P.Position  # CnvIa(Str_Token(aKey,'/',2));
                Erx # RecRead(700,1,0);
                if (Erx = _rOK) OR (Erx = _rLocked) then begin
                  vRet    # _rOK;
                  aDatei  # 702;
                end;
              end else
                vRet # -1;
            end;
           
    'AUF','400' :  begin
              Auf.Nummer # CnvIa(aKey);
              Erx # RecRead(400,1,0);
              if (Erx = _rOK) OR (Erx = _rLocked) then begin
                vRet    # _rOK;
                aDatei  # 400;
              end;
            end;
    
    'AUFP','401' : begin
              if (Lib_Strings:Strings_Count(aKey,'_') = 2) then begin
                Auf.P.Nummer    # CnvIa(Str_Token(aKey,'/',1));
                Auf.P.Position  # CnvIa(Str_Token(aKey,'/',2));
                Erx # RecRead(401,1,0);
                if (Erx = _rOK) OR (Erx = _rLocked) then begin
                  vRet    # _rOK;
                  aDatei  # 401;
                end;
              end else
                vRet # -1;
            end;
           
    'REKL','300'  : begin
                Rek.Nummer # CnvIa(aKey);
                Erx # RecRead(300,1,0);
                if (Erx = _rOK) OR (Erx = _rLocked) then begin
                  vRet    # _rOK;
                  aDatei  # 300;
                end;
              end;
              
              
    'INV','259' : begin
                    Art.Inv.Nummer # CnvIa(Str_Token(aKey,'/',1));
                    Erx # RecRead(259,1,0);
                    if (Erx = _rok) OR (Erx = _rLocked) then begin
                      vRet    # _rOK;
                      aDatei  # 259;
                    end;
                  end;
                  
                  
  end;

  RETURN vRet;
end;


//========================================================================
//  sub Attach(...)
//  Liest den angegbenen Datensatz und erstellt den Anhangeintrag
//========================================================================
sub Attach(aPara : alpha(4000); aBereich : alpha; aKey : alpha; aMetainfo : alpha) : logic
local begin
  Erx       : int;
  vDatei    : int;
  
  vKey      : alpha;
  
  vName     : alpha(1000);
  vFileSrc  : alpha(1000);
  vFileDest : alpha(1000);
  vUniqueifier  : alpha;

  // Blob
  vDBAConnect : int;
  vBlobID     : int;
  vPath       : alpha(250);
end
begin
  // Datensatz lesen
  Erx  # ReadFromKey(aBereich,aKey, var vDatei);
  if (Erx <> _rOK) then begin
    ERROR(99,FsiSplitName(aPara,_FsiNameNE) + ': Datensatz nicht gefunden');
    RETURN false;
  end;
  
  vKey  # Anh_Data:MakeKey(vDatei);
  vUniqueifier # '_'+ Lib_Strings:TimestampFullYearMs();
  vUniqueifier # StrCut(vUniqueifier,StrLen(vUniqueifier)-7,4);   // ST Verkürzung des Uniqufiers auf die MMSS
  
  vFileDest # FsiSplitname(aPara, _FSINameP)+FsiSplitname(aPara, _FSINameN)+vUniqueifier+ '.'+FSISplitName(aPara, _FSINameE);
  
  // Kopie zum Einlesen erstellen
  Lib_FileIO:FsiCopy(aPara,vFileDest,false);

  if (Set.ExtArchiev.Path='CA1') then begin
    if (gDBAConnect=0) then begin
      if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
      else RETURN false;
    end;

    vPath # Anh_Data:CreateBLOBPath(vDatei, vKey);
    if (vPath<>'') then begin
      Erx # Lib_Blob:Import(vFileDest, vPath, cDBA, 0, n, var vBlobID);
      if (erx<>_rOK) then RETURN false;
    end;
    if (vDBAConnect<>0) then begin
      DbaDisconnect(vDBAConnect);
    end;
    FsiDelete(vFileDest);
    vFileDest # FSISplitName(vFileDest, _fsinameNE);
  end else
  begin
    // kopieren
    vName # FsiSplitname(vFileDest, _FsiNameNE);
    vName # Anh_Data:FindArchivName(vName, vDatei, vKey);
    Lib_FileIO:FsiCopy(vFileDest, vName, n);
    FsiDelete(vFileDest);
    vFileDest # vName;
  end;
  

  RecBufClear(916);
  Anh.Bemerkung     # aMetainfo;
  Anh.Datei         # vDatei;
  Anh.File          # vFileDest;
  Anh.Key           # vKey;
  Anh.lfdnr         # 0;
  Anh.BlobID        # vBlobID;
  Anh_Data:Insert();

  RETURN true;
end;


//========================================================================
//  sub HandleError()
//    Informiert die Benutzer über einen aufgetretenen Fehler
//========================================================================
sub HandleError()
local begin
  vFilename : alpha(1000);
end;;
begin
  // Add Jobserver Error
  Lib_Error:OutputToJobserverErrProt('Anhangscan');

  // Trigger workflow
  // Write Errlog
end;


//========================================================================
//  sub ParseMetafile()
//    Parsed das Metafile auf Dateinamen, bezeichnungen, Daten
//========================================================================
sub ParseMetafile(aPara : alpha(4000); var aFilelistHdl : int) : logic
local begin
  // -- Metafile handling
  vFsiHdl       : int;
  vBytes        : int;
  vLine         : alpha(500);
    
  // -- Parsing
  vFilename     : alpha(4000);
  vBereich      : alpha;
  vKeys         : alpha(500);
  vKeyCnt       : int;
  vKey          : alpha;
  
  vMetaInfo     : alpha;
  vI,vJ         : int;
end;
begin
  aFilelistHdl # CteOpen(_CteList);
  
  vFsiHdl # FsiOpen(aPara,_FsiStdRead);
  vFsiHdl->FsiMark(10);
  FOR   vBytes # vFsiHdl->FsiRead(vLine);
  LOOP  vBytes # vFsiHdl->FsiRead(vLine);
  WHILE vBytes > 0 DO BEGIN
    vFilename # FsiSplitName(aPara,_FsiNameP) + Str_Token(vLine,'|',1);
    vBereich  # Str_Token(vLine,'|',2);
    vKeys     # Str_Token(vLine,'|',3);
    vMetaInfo # StrCut(Str_Token(vLine,'|',4),1,64);
      
    vKeyCnt   # Str_Count(vKeys,';')+1;
    FOR   vJ # 1
    LOOP  inc(vJ)
    WHIle vJ <= vKeyCnt DO BEGIN
      vKey # Str_Token(vKeys,';',vJ);
      
      if (Attach(vFilename,vBereich,vKey,vMetainfo)) then
        aFilelistHdl->CteInsertItem(vFilename,vI,'OK',_CteLast);
      else begin
        ERROR(99,FsiSplitName(aPara,_FsiNameNE) + ' ist fehlerhaft');
        aFilelistHdl->CteInsertItem(vFilename,vI,'ERR',_CteLast);
      end
    
    END;
    inc(vI);
      
  END;
  
  FsiClose(vFsiHdl);
  RETURN (ErrList = 0)
end;


//========================================================================
//  sub Import(aPara : alpha(4000)) : logic
//  Startet den Import einer Metadatei
//  Anh_Filescanner:Impport
//========================================================================
sub Import(aPara : alpha(4000)) : logic
local begin
  vRet : logic;
  
  vFilelist : int;
  vNode     : int;
end;
begin
  Lib_Error:_Flush();
  vRet  # false;

  if (StrCnv(FsiSplitName(aPara,_FsiNameE),_StrUpper) = 'META') then begin
    ErrList # 0;
    if (ParseMetafile(aPara, var vFileList) = false) then begin
      // Fehlerfall
      MoveToFailedFolder(aPara, vFileList);
      HandleError();
      vRet # false;
    end else begin
      // alles OK, dann Fileliste löschen
      FOR   vNode # vFilelist->CteRead(_CteFirst)
      LOOP  vNode # vFilelist->CteRead(_CteNext,vNode)
      WHILE (vNode  <> 0) DO
        FsiDelete(vNode->spName);
        
      vRet # true;
    end;
  end;
  vFilelist->CteClear(true);
  vFilelist->CteClose();
  
  Lib_Error:_Flush();
  
  RETURN vRet;
end;


//========================================================================
//  sub ImportFileDialog()
//  Importiert eine XML Datei inkl. Dateiauswahl
//  Anh_Filescanner:ImportFileDialog
//========================================================================
sub ImportFileDialog()
local begin
  vFile : alpha(1000);
  vOK : logic;
end
begin
  vFile # Lib_FileIO:FileIO('_WINCOMFILEOPEN',0,'','*.meta');
  if (vFile = '') then
    RETURN;

  vOK # Import(vFile);
  if (vOK) then
    Msg(99,'Datei erfolgreich importiert',0,0,0);
  else
    Msg(99,'Datei nicht importiert',0,0,0);
end;

//========================================================================

