@A+
//===== Business-Control =================================================
//
//  Prozedur    App_Extras
//                  OHNE E_R_G
    //  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  29.04.2013  AI  Neu: TESTBA
//  26.09.2014  AH  Command "Sql_Syncone"
//  17.08.2016  AH  "Diagnose" entfernt auch falsche Aufpreise
//  26.01.2017  AH  "BlobInfo"
//  13.03.2017  AH  "CheckAblage"
//  07.01.2020  AH  "Debug"
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB BlobInfo();
//    SUB ClearMark(aFile : int;)
//    SUB HardLogout();
//    SUB Diagnose();
//    SUB KeyReorg();
//    SUB UserCleanUp()
//    SUB INICleanUp()
//    SUB Kommandozeile();
//    SUB EtiDMSNeu();
//    SUB EtiDMSImport();
//    SUB Helpdesk();
//
//========================================================================
@I:Def_Global

declare Diagnose();
declare UserCleanup();

//========================================================================
//
//========================================================================
sub SumBlobs
(
  aBinDir           : int;
) : int;
local begin
  tObjName  : alpha;
  tObjHdl   : int;
  tCntObj   : int;
  vSize     : int;
end;
begin

  tCntObj # 0;

  // alle Objekte zu diesem Verzeichnis ermitteln
  tObjName # BinDirRead(aBinDir,_BinFirst)

  while(tObjName != '') do begin
    tObjHdl # BinOpen(aBinDir,tObjName);
//debug('       '+tObjHdl->spFullName);
vSize # vSize + tObjHdl->spSizeDba;
//vSize # vSize + 1;
    tObjName # BinDirRead(aBinDir,_BinNext);
    BinClose(tObjHdl);
  end;

  RETURN vSize;
end;


//========================================================================
//
//========================================================================
sub BlobInfo(
  opt aDepth  : int;
  opt aBinDir : int;
) : int;
local
begin
  vSize       : int;
  vGesSum     : int;
  tDirHdl     : int;
  tDirName    : alpha;
end
begin

  // Alle Verzeichnisse ermitteln
  tDirName # BinDirRead(aBinDir,_BinFirst|_BinDirectory)
  WHILE(tDirName != '') do begin

    // Verzeichnis ueber den Namen oeffnen
    tDirHdl # BinDirOpen(aBinDir,tDirName)

//debug(StrChar(32, aDepth*2)+tDirHdl->spFullName+':');
    vSize # SumBlobs(tDirHdl);
    // Unterverzeichnisse zu diesem Verzeichnis ermitteln
    vSize # vSize + BlobInfo(aDepth + 1, tDirHdl);

//debug(StrChar(32,aDepth*2)+' SUM '+aInt(vSize));
    vGesSum # vGesSum + vSize;

    // Verzeichnis wieder schliessen
    BinClose(tDirHdl);

    // naechsten Verzeichnis(Namen) ermitteln
    tDirName # BinDirRead(aBinDir,_BinNext|_BinDirectory)
  END;

  if (aDepth=0) then begin
    Msg(99,'Gesamtgröße: '+cnvai(vGesSum)+' bytes',0,0,0);
  end;
  RETURN vGesSum;

end;



//========================================================================
//  CreateEntwickler
//
//========================================================================
sub CreateEntwickler(aEntwickler : alpha);
local begin
  vTmp  : int;
  Erx   : int;
end;
begin
  aEntwickler # StrCnv(aEntwickler,_StrUpper);

  Erx # UserCreate(aEntwickler, 'PROGRAMMIERER');
  if (Erx <> _rOK) then begin
    UserPassword(aEntwickler, '', '');     // Passwort leeren
    RETURN;
  end;

  vTMP # UrmOpen(_UrmTypeUser,_UrmLock, aEntwickler);
    // Hauptbenutzer setzen...
  vTMP->UrmPropSet(_UrmPropUserGroup,'PROGRAMMIERER');
  vTMP->UrmPropSet(_UrmPropOwner,'SUPERUSER');
  // Diesen Benuter der Gruppe Sales zuordnen
  Erx # vTMP->UrmCreate(_UrmTypeMember,'_Everyone');
  Erx # vTMP->UrmCreate(_UrmTypeMember,'PROGRAMMIERER');
  vTMP->UrmClose();

  TxtCopy('INI.USER','INI.'+aEntwickler,0);

  RecBufClear(800);
  Usr.Username  # aEntwickler;
  Usr.Funktion  # 'AUTOMATISCH';
  RekInsert(800,_recunlock,'AUTO');

end;


//========================================================================
//  EntwicklerVersion
//
//========================================================================
sub EntwicklerVersion();
begin

  if (App_Main:Entwicklerversion()=false) then RETURN;
  // User anlegen...
  CreateEntwickler('AH');
  CreateEntwickler('DS');
  CreateEntwickler('FS');
  CreateEntwickler('HB');
  CreateEntwickler('MR');
  CreateEntwickler('TJ');
  CreateEntwickler('TM');
  CreateEntwickler('SR');
  CreateEntwickler('ST');
  CreateEntwickler('UNITTEST');
//  UserPassword('AI', '', 'xxx');
end;


//========================================================================
//  ClearMark
//
//========================================================================
sub ClearMark(
  aFile     : int;
)
local begin
  Erx : int;
end;
begin

  Erx # RecRead(aFile,1,_recFirst);
  WHILE (Erx<_rLocked) do begin
    if (Lib_Mark:IstMarkiert(aFile,RecInfo(aFile,_RecId))) then begin
      RekDelete(aFile,0,'MAN');
      Erx # RecRead(aFile,1,0);
      Erx # RecRead(aFile,1,0);
    end
    else begin
      Erx # RecRead(aFile,1,_recNext);
    end;
  END;

end;


//========================================================================
//  HardLogout
//        Schmeisst den User aus dem Programm!!!
//========================================================================
sub HardLogout();
begin

  if (gMdiAdr<>0) then WinClose(gMdiAdr);
  if (gMdiMat<>0) then WinClose(gMdiMat);
  if (gMdiAuf<>0) then WinClose(gMdiAuf);
  if (gMdiEin<>0) then WinClose(gMdiEin);
  if (gMdiBdf<>0) then WinClose(gMdiBdf);
  if (gMdiLfs<>0) then WinClose(gMdiLfs);
  if (gMdiPrj<>0) then WinClose(gMdiPrj);
  if (gMdiBAG<>0) then WinClose(gMdiBAG);
  if (gMdiErl<>0) then WinClose(gMdiErl);
  if (gMdiEKK<>0) then WinClose(gMdiEKK);
  if (gMdiOfp<>0) then WinClose(gMdiOfp);
  if (gMdiERe<>0) then WinClose(gMdiEre);
  if (gMdiMenu<>0) then WinClose(gMdiMenu);
  if (gFrmUsr>0) then WinClose(gFrmUsr);
  if (gMdiPara<>0) then WinClose(gMdiPara);
  if (gMdiRsoKalender<>0) then WinClose(gMdiRsoKalender);
  if (gMdiArt<>0) then WinClose(gMdiArt);
  if (gMdiMath<>0) then WinClose(gMdiMath);
  if (gMdiMathVar<>0) then WinClose(gMdiMathVar);
  if (gMdiMathAlphabet<>0) then WinClose(gMdiMathAlphabet);
  if (gMdiMathVarMiniPrg<>0) then WinClose(gMdiMathVarMiniPrg);

  if (gFrmMain<>0) then WinClose(gFrmMain);


  // SOUND beenden
  Lib_Sound:Terminate();

  // User aufräumen
  UserCleanup();

  // ODBC beenden
  Lib_ODBC:Term();

  // TAPI beenden
  Lib_Tapi:TAPITerm();

  // Job-Thread beenden
  Lib_Jobber:Term();

  // BCS_COM beenden
  Lib_BCSCOM:UnloadDLL();

  // Debugger beenden
  Lib_Debug:TermDebug();

  // AFX beenden
  Lib_SFX:TermAFX();

  // Aufräumen
  Org_Data:Killme();
  if (gUserINI<>0) then TextClose(gUserINI);
  varfree(VarSysPublic);
  Liz_Data:SystemTerm();

  WinHalt();

end;


//========================================================================
//  Diagnose
//        Entfernt leere Köpfe und temp. Positionen
//========================================================================
sub Diagnose();
local begin
  Erx : int;
end;
begin

  Adr_Data:Diagnose();

  // Aufträge reorgen
  Erx # RecRead(400,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (RecLinkInfo(401,400,9,_RecCount)=0) then begin
      Auf_Data:DeleteKopf();
      Erx # RecRead(400,1,0);
      Erx # RecRead(400,1,0);
    end
    else begin
      Erx # RecRead(400,1,_RecNext);
    end;
  END;


  Erx # RecRead(401,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.P.Nummer>1000000000) or (RecLinkInfo(400,401,3,_RecCount)=0) then begin
      Auf_Data:DeletePos();
      Erx # RecRead(401,1,0);
      Erx # RecRead(401,1,0);
    end
    else begin
      Erx # RecRead(401,1,_RecNext);
    end;
  END;

  // Aufpreise löschen
  RecBufClear(403);
  Auf.Z.Nummer # 1000000000;
  Erx # RecRead(403,1,0);
  WHILE (Erx<_rNoRec) and (Auf.Z.Nummer>1000000000) do begin
    RekDelete(403);
    Erx # RecRead(403,1,0);
    Erx # RecRead(403,1,0);
  END;

  // LFS reorgen...
  Erx # RecRead(441,1,_RecLast);
  WHILE (Erx<=_rLocked) and (Lfs.P.Nummer>1000000000) do begin
    RekDelete(441,0,'MAN');
    Erx # RecRead(441,1,_RecLast);
  END;


  // Bestellungen reorgen
  Erx # RecRead(500,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (RecLinkInfo(501,500,9,_RecCount)=0) then begin
      Ein_Data:DeleteKopf();
      Erx # RecRead(500,1,0);
      Erx # RecRead(500,1,0);
    end
    else begin
      Erx # RecRead(500,1,_RecNext);
    end;
  END;


  Erx # RecRead(501,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.P.Nummer>1000000000) or (RecLinkInfo(500,501,3,_RecCount)=0) then begin
      Ein_Data:DeletePos();
      Erx # RecRead(501,1,0);
      Erx # RecRead(501,1,0);
    end
    else begin
      Erx # RecRead(501,1,_RecNext);
    end;
  END;

  WindialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)

end;


//========================================================================
//  KeyReorg
//
//========================================================================
sub KeyReorg();
begin
  DbaKeyRebuild(0,0,_KeyWait);
end;


//========================================================================
//  UserCleanUp
//
//========================================================================
sub UserCleanUp()
local begin
  erx   : int;
  vA    : alpha;
  vX    : int;
  vBuf  : int;
end;
begin

  // tmp. Texte löschen
  TxtDelete(myTmpText,0);
  TxtDelete('~TMP.ADR.' + UserInfo(_UserCurrent),0);

  // tmp. Selektionen löschen
  FOR vX # 1 loop inc(vX) WHILE (vX<=999) do begin
    if (FileInfo(vX,_FileExists)=0) then CYCLE;
    SelDelete(vX,MyTmpSel);
  END;

  if (DbaInfo(_DbaUserCount)<=1) then begin  // letzter User??
    // alle tmp. Texte löschen
    vBuf # TextOpen(16);
    REPEAT
      Erx # TextRead(vBuf,'Tmp.',_TextNoContents);
      vA # TextInfoAlpha(vBuf,_TextName);
      if (vA<'Tmp.z') and (vA>'Tmp.') then TxtDelete(vA,0);
    UNTIL (vA>'Tmp.z') or (Erx>=4);

    REPEAT
      Erx # TextRead(vBuf,'~TMP.',_TextNoContents);
      vA # TextInfoAlpha(vBuf,_TextName);
      if (vA<'~TMP.z') and (vA>'~TMP.') then TxtDelete(vA,0);
    UNTIL (vA>'~TMP.z') or (Erx>=4);
    vBuf->TextClose();

    // alle tmp. Selektionen löschen
    vBuf # SelOpen();
    FOR vX # 1 loop inc(vX) WHILE (vX<=999) do begin
      if (FileInfo(vX,_FileExists)=0) then CYCLE;
      REPEAT
        Erx # Selread(vBuf,vX,0,'TMP.');
        if (Erx>=_rLastrec) then BREAK;
        vA # SelInfoAlpha(vBuf,_SelName);
        if (vA<'TMP.999999') and (vA>'TMP.') then SelDelete(vX,vA);
      UNTIL (vA>'TMP.999999');
    END;
    vBuf->SelClose();


    // temp. LFS-Positionen löschen....
    Erx # RecRead(441,1,_recLast);
    WHILE (Erx<=_rLocked) and (Lfs.P.Nummer>100000000) do begin
      RekDelete(441,0,'MAN');
      Erx # RecRead(441,1,_recLast);
    END;

    // temp. BA-Ausführungen löschen....    25.10.2021 AH
    Erx # RecRead(705,1,_recLast);
    WHILE (Erx<=_rLocked) and (BAG.AF.Nummer>100000000) do begin
      RekDelete(705,0,'MAN');
      Erx # RecRead(705,1,_recLast);
    END;
end;

end;


//========================================================================
//  INICleanUp
//
//========================================================================
sub INICleanUp()
local begin
  Erx   : int;
  vA    : alpha;
  vX    : int;
  vBuf  : int;
end;
begin

  vBuf # TextOpen(16);
  REPEAT
    Erx # TextRead(vBuf,'INI.',_TextNoContents);
    vA # TextInfoAlpha(vBuf,_TextName);
    if (vA<'INI.ZZZZZZ') and (vA>'INI.') then TxtDelete(vA,0);
  UNTIL (vA>'INI.ZZZZZZ');
  vBuf->TextClose();

end;


//========================================================================
//========================================================================
sub CheckAblage()
local begin
  Erx   : int;
  vTxt  : int;
  vI    : int
end
begin

  vTxt # TextOpen(20);
  TextAddLine(vTxt, 'Doppelte Datensätze in Bestand und Ablage:');

  // Material --------------------------------------------------
  if (RecInfo(200,_recCount)<Recinfo(210,_recCount)) then begin
    FOR Erx # RecRead(200,1,_recFirst)
    LOOP Erx # RecRead(200,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      "Mat~Nummer" # Mat.Nummer;
      if (RecRead(210,1,_recTest)<=_rLocked) then
        TextAddLine(vTxt, 'Mat:'+aint(Mat.Nummer));
    END;
  end
  else begin
    FOR Erx # RecRead(210,1,_recFirst)
    LOOP Erx # RecRead(210,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      "Mat.Nummer" # "Mat~Nummer";
      if (RecRead(200,1,_recTest)<=_rLocked) then
        TextAddLine(vTxt, 'Mat:'+aint("Mat~Nummer"));
    END;
  end;


  // Auftragspos -----------------------------------------------
  if (RecInfo(401,_recCount)<Recinfo(411,_recCount)) then begin
    FOR Erx # RecRead(401,1,_recFirst)
    LOOP Erx # RecRead(401,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      "Auf~P.Nummer"    # "Auf.P.Nummer";
      "Auf~P.Position"  # "Auf.P.Position";
      if (RecRead(411,1,_recTest)<=_rLocked) then
        TextAddLine(vTxt, 'AufPos:'+aint("Auf.P.Nummer")+'/'+aint("auf.P.Position"));
    END;
  end
  else begin
    FOR Erx # RecRead(411,1,_recFirst)
    LOOP Erx # RecRead(411,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      "Auf.P.Nummer"    # "Auf~P.Nummer";
      "Auf.P.Position"  # "Auf~P.Position";
      if (RecRead(401,1,_recTest)<=_rLocked) then
        TextAddLine(vTxt, 'AufPos:'+aint("Auf~P.Nummer")+'/'+aint("auf~P.Position"));
    END;
  end;


  TextDelete(myTmpText,0);
  TextWrite(vTxt,MyTmpText,0);
  TextClose(vTxt);
  Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll');
  TextDelete(myTmpText,0);

end;


//========================================================================
//  Kommandozeile
//
//========================================================================
sub Kommandozeile();
local begin
  vA    : alpha(200);
  vB    : alpha(200);
  vC    : alpha(200);
  vFile : int;
  vUser : int;
  vOK   : logic;
end;
begin

  vA # '';
  if (GUsername='AH') then vA # 'CALL Test+2';

  REPEAT

    Dlg_Standard:Standard('Command:',var vA);
    if (vA='') then RETURN;

    // Excel-Export
    if (StrCnv(vA,_StrUpper) =* 'EXCELEXPORT*') then begin
      if (App_Commands:Excel.Export(cnvia(vA))) then begin
      end;
    end;

    // Excel-Import
    if (StrCnv(vA,_StrUpper) =* 'EXCELIMPORT*') then begin
      if (App_Commands:Excel.Import(cnvia(vA))) then begin
      end;
    end;

    // Git-Export
    if (StrCnv(vA,_StrUpper) =* 'GITEXPORT*') then begin
      if (Git_for_C16:wrapperExport() = _ErrOK) then begin
      end;
    end;
    
    // Git-Import
    if (StrCnv(vA,_StrUpper) =* 'GITIMPORT_NOCH_NICHT_FREIGEGEBEN*') then begin
      if (Git_for_C16:wrapperImport() = _ErrOK) then begin
      end;
    end;

    // SQL: Informarionen über Syns
    if (StrCnv(vA,_StrUpper) =* 'SQL_SYNC_INFO*') then begin
      Lib_Sync:SyncInfoByRecId();
    end;
    

    // SQL: Bulk
    if (StrCnv(vA,_StrUpper) =* 'SQL_BULK*') then begin
      if (Lib_Transfers:SYNC(cnvia(vA))) then begin
      end;
    end;


    // 2022-10-26 AH  SQL: alles auf Stand bringen (ScriptTable + FillTable ODER Altertable)
    if (StrCnv(vA,_StrUpper) =* 'SQL_UPDATE') then begin
      if (Lib_Odbc:MoveOldNew(9999)) then begin
      end;
    end;

    // SQL: Eine Tabelle syncen
    if (StrCnv(vA,_StrUpper) =* 'SQL_ALTERTABLE*') then begin
      if (Lib_Odbc:MoveOldNew(cnvia(vA))) then begin
      end;
    end;
/*** geht nicht wegen Reihenfolge der Felder !!!
    // SQL: Ein Feld hinzugügen
    if (StrCnv(vA,_StrUpper) =* 'SQL_ADDFIELD*') then begin
      Lib_Odbc:AlterTable(vA);
    end;
***/
    // SQL: Eine Tabelle syncen
    if (StrCnv(vA,_StrUpper) =* 'SQL_SYNCONE*') then begin
      if ( Lib_Odbc:ScriptOneTable(cnvia(vA))) then begin
        if (Lib_Odbc:SyncOneTable(cnvia(vA))) then begin
        end;
      end;
    end;

    if (StrCnv(vA,_StrUpper) =* 'SQL_FILLONE*') then begin
      if (Lib_Odbc:SyncOneTable(cnvia(vA))) then begin
      end;
    end;

    // Markierte Löschen
    if (StrCnv(vA,_StrUpper) =* 'CLRMARK*') then begin
      if (WinDialogBox(gFrmMain,vA,
      Translate('Fortfahren mit der Löschung der markierten Sätze der Datei')+' '+AInt(cnvia(vA)),
      _WinIcoWarning,_WinDialogYesNo,2)=_WinIDYes) then begin
        ClearMark(CnvIa(vA));
      end;
    end;

    // Einzeldatei Löschen
    if (StrCnv(vA,_StrUpper) =* 'CLRFILE*') then begin
      if (WinDialogBox(gFrmMain,vA, Translate('Fortfahren mit der kompletten Löschung des Inhalts? Anzahl:')+AInt(Recinfo(cnvIA(vA),_RecCount) ),_WinIcoWarning,_WinDialogYesNo,2)=_WinIDYes) then begin
        Lib_Rec:ClearFile(CnvIa(vA),'TEXT');
      end;
    end;

    // Einzeldatei Löschen
    if (StrCnv(vA,_StrUpper) =* 'CALL *') then begin
      vB # Str_Token(vA,' ',2);
      if (WinDialogBox(gFrmMain,vA,'Prozedur '+vB+' starten ?',_WinIcoWarning,_WinDialogYesNo,2)=_WinIDYes) then begin
        Call(vB);
      end;
    end;

    // Ablage restoren
    if (StrCnv(vA,_StrUpper) =* 'RESTOREALL *') then begin
      vB # Str_Token(vA,' ',2);
      App_Commands:RestoreAll(vB);
    end;

    // Prozeduren umbenennen
    if (StrCnv(vA,_StrUpper) =* 'RENAMEPROC *') then begin
      vB # Str_Token(vA,' ',2);
      App_Commands:RenameProc(vB);
    end;

    // Dialog umkopieren samt Prozedur
    if (StrCnv(vA,_StrUpper) =* 'CREATECUSTOM *') then begin
      vB # Str_Token(vA,' ',2);
      vC # Str_Token(vA,' ',3);
      App_Commands:CreateCustom(vB, vC, Str_Token(vA, ' ',4));
    end;

    // Datenbank kopieren nach PFAD (OHNE Filename!!!)
    if (StrCnv(vA,_StrUpper) =* 'COPYDB *') then begin
      vB # Str_Token(vA,' ',2);
      App_Commands:CopyDB(vB);
    end;

    // AFX durchsuchen
    if (StrCnv(vA,_StrUpper) =* 'CHECKAFX *') then begin
      vB # Str_Token(vA,' ',2);
      App_Commands:CheckAFX(vB);
    end;

    if (StrCnv(vA,_StrUpper) =* 'TESTBA *') then begin
      BAG.Nummer # cnvia(vA);
      RecRead(700,1,0);
      winDialog('Test.BA1',0,gFrmMain);
      RETURN;
    end;

    case StrCnv(vA,_StrUpper) of

//      'SQL_FIRSTSYNC'   : Lib_Odbc:FirstSync();
//      'SQL_FIRSTSCRIPT' : Lib_Odbc:FirstScript();
      'SQL_INIT'        : if (TransActive=false) and (gBluemode=false) then begin
                            DbaLog(_LogError, N, 'manueller SQL_INIT bei Stamp:'+cnvab(Version.Stamp));
                            if ( Lib_Odbc:FirstScript()) then begin
                              if (Lib_Odbc:FirstSync()) then begin
                                RecDeleteAll(997);
                                RecbufClear(997);
                                Lib_Rec:StampDB();
                                // ist im StampDB drin :   Lib_ODBC:TransferStamp();
                                DbaLog(_LogError, N, 'danach Stamp:'+cnvab(Version.Stamp));
                              end;
                            end;
                          end;

      'FORMPREVIEW'     : App_Commands:FormPreview();

      'BARECALCOUTPUT'  : App_Commands:BARecalcOutput(vA);

      'ARTIKELRECALC',
      'RECALCARTIKEL'   : App_Commands:ArtikelRecalc(vA);

      'AUFTRAGRECALC',
      'RECALCAUFTRAG'   : App_Commands:AuftragRecalc(vA);

      'EINKAUFRECALC',
      'RECALCEINKAUF'   : App_Commands:EinkaufRecalc(vA);

      'REPAIRABRUF',
      'ABRUFREPAIR'     : App_Commands:RepairAbruf(vA);


      'DISPORECALC'     : App_Commands:DispoRecalc(vA);

      'BACKUP'          : App_Commands:Backup(vA);

      'BINDATA',
      'BLOB',
      'BLOBS'           : C16_BinData();

      'BLOBINFO'        : BlobInfo();

      'CHECKABLAGEN',
      'CHECKABLAGE'     : CheckAblage();

      'CLEANUP'         : App_Commands:CleanUp(vA);

      'CLEARDOKS',
      'CLEARDOCS',
      'CLEARALLDOCS'    : App_Commands:ClearDocs(vA);

      'CREATEUPDATE'    : begin
        if (gJobController<>0) then vOK # y;
        App_Update_data:CreateUpdate();
        // ODBC initalizieren
        Lib_ODBC:Init();
        if (vOK) and (gJobController=0) then Lib_Jobber:Init();
      end;

      'DEBUG'           : begin
        if (gTmpA='DEBUG') then begin
          gTmpA # '';
          Msg(99,'Remotedebugging deaktiviert!',0,0,0);
        end
        else begin
          gTmpA # 'DEBUG';
          Dlg_Standard:Standard('Lokaler FRX-Pfad (z.B. P:\BFS)', var vA);
          gTmpA # gTmpA + '|'+vA;
          Msg(99,'Remotedebugging AKTIVIERT!',0,0,0);
        end;
      end;

      'DIAGNOSE'        : Diagnose();

      'MATERIALRECALC',
      'RECALCMATERIALL' : App_Commands:MaterialRecalc(vA);

      'OSTNEU',
      'OST-NEU'         : App_Commands:OSTNeu(vA);

      'PROCINFO'        : CallOld('old_ProcInfo')

      'REDO 100'        : App_Commands:REDO100(vA);

      'STO',
      'STORAGE',
      'STORED'          : C16_StoDir();

      'TEST'            : Call('Test+2');

      'TESTLOAD'        : Lib_debug:ResetData(y);
      'TESTRESET'       : App_Commands:TestReset(vA);
      'TESTSAVE'        : Lib_debug:ResetData(n);

      'TRANSLATEALL'    :  Lng_Subs:InitTranslation();

      'WINHALT'         : winhalt();
      
      'INSTALLCTX'      : App_Commands:InstallCtxOffice();
      
      

      //'MAKEPROCINFO' :  _ProcInfo();
  /*
      'LOGOUT' : begin
        // User durchlaufen
        FOR   vUser # CnvIa(UserInfo(_UserNextId))
        LOOP  vUser # CnvIa(UserInfo(_UserNextId,vUser))
        WHILE (vUser > 0) DO BEGIN
          if (gUserid<>vUser) then begin
            RecBufClear(989);
            TeM.E.User  # UserInfo(_UserName,vUser);
            TeM.E.Aktion # 'LOGOUT';
            REPEAT
            Tem.E.ID #
              TeM.E.Datum # today;
              TeM.E.Zeit  # Now;
              erx RekInsert(989,0,'AUTO');
            UNTIL (Erx=_rOK);
          end;
        END;
      end;
  */
  /**
      'MSG2ALL' : begin
        vA # '';
        Dlg_Standard:Standard('Message:',var vA);
        if (vA='') then RETURN;

        // User durchlaufen
        FOR   vUser # CnvIa(UserInfo(_UserNextId))
        LOOP  vUser # CnvIa(UserInfo(_UserNextId,vUser))
        WHILE (vUser > 0) DO BEGIN
          if (gUserid<>vUser) then begin
            RecBufClear(989);
            TeM.E.User  # UserInfo(_UserName,vUser);
            TeM.E.Aktion # 'MSG';
            TeM.E.Bemerkung # gUserName+': '+vA;
            REPEAT
            Tem.E.ID
              TeM.E.Datum # today;
              TeM.E.Zeit  # Now;
              erx RekInsert(989,0,'AUTO');
            UNTIL (erx=_rOK);
          END;
        end;
      end;
  **/
  //    'RGT' :   Call('Rgt_Menudata');

    end;

  UNTIL (true=false);

end;


//========================================================================
//  EtiDMSNeu
//
//========================================================================
sub EtiDMSNeu();
local begin
  vHdl    : int;
  vHdl2   : int;
  vA      : alpha;
  vB      : alpha;
  vTyp    : int;
  vT1,vT2 : alpha;
end;
begin

// A-uftrag
// E-inkauf
// W-erkszeugnis
// R-echnung
// P-roduktion

  vTyp # 1;
  REPEAT
    vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
    vHdl->wpcaption # Translate('Etikettentyp auswählen...');
    vHdl2 # vHdl->WinSearch('Clm.Sort');
    vHdl2->wpcaption # Translate('Etikett');

    vHdl2 # vHdl->WinSearch('Dl.Sort');
    vHdl2->WinLstDatLineAdd(Translate('Auftrag'));
    vHdl2->WinLstDatLineAdd(Translate('Einkauf'));
    vHdl2->WinLstDatLineAdd(Translate('Produktion'));
    vHdl2->WinLstDatLineAdd(Translate('Rechnung'));
    vHdl2->WinLstDatLineAdd(Translate('Werkszeugniss'));
    vHdl2->wpcurrentint # vTyp;

    vHdl->WinDialogRun(_WindialogCenter,gFrmMain);

    vHdl2->WinLstCellGet(vA, 1, _WinLstDatLineCurrent);
    vHdl->WinClose();
    if (gSelected=0) then RETURN;   // keine Sortierung ausgewählt? ->  ENDE
    vTyp # gSelected;
    gSelected # 0;

    vB # '';
    if (Dlg_Standard:Standard(vA+'-'+Translate('Nummer'),var vB)) then begin
      vT1 # '';
      vT2 # '';
      case vTyp of
        1 : begin
          vT1 # 'SCA'+vB;
          vT2 # 'A'+vB;
        end;

        2 : begin
          vT1 # 'SCE'+vB;
          vT2 # 'E'+vB;
        end;

        3 : begin
          vT1 # 'SCP'+vB;
          vT2 # 'P'+vB;
        end;

        4 : begin
          vT1 # 'SCR'+vB;
          vT2 # 'R'+vB;
        end;

        5 : begin
          vT1 # 'SCW'+vB;
          vT2 # 'W'+vB;
        end;
      end;

      if (vT1<>'') then begin
//        CallOld('D_ArcFlow_Eti', vT1 , vT2, 1);
        GV.Alpha.01 # vT1;
        GV.Alpha.02 # vT2;
        Lib_Dokumente:Printform(915,'Etikett',false);
      end;

      vB # '';
    end;

  UNTIL (1=2);

end;


//========================================================================
//  EtiDMSImport
//
//========================================================================
sub EtiDMSImport();
local begin
  vA  : alpha;
end;
begin
RETURN;

  // ArcFlow vorhanden?
//  if (Set.DMS.AF.SrvName='') then RETURN;

//  DMS_ArcFlow:Init();
//  vA # DMS_ArcFlow:ScanLauf();
//  DMS_ArcFlow:Term();

//  if (vA<>'') then
//    Msg(999999,vA,0,0,0);

end;


//========================================================================
//  Helpdesk
//
//========================================================================
sub Helpdesk();
local begin
  Erx   : int;
  vTxt  : int;
  vRtf  : int;
  vI    : int;
end;
begin
//  per   set HTTP_PROXY_USER=username
// oder auch set HTTP_PROXY_USER=%loginname%
//
  if (Set.Helpdesk.Exe='') then begin
    Erx # FsiAttributes('.\helpdesk\proxy.bat')
    if (Erx>0) then
      SysExecute('.\helpdesk\proxy.bat','',0)
    else
      SysExecute('.\helpdesk\SC.exe','',0);
  end
  else begin
    if (Lib_FileIO:FileExists('.\helpdesk\'+Set.Helpdesk.exe)=false) then begin

      vTxt # TextOpen(20);
      TextLineWrite(vTxt, 1,'\cf1 Bitte laden Sie sich unser Helpdesk-Tool aus dem Web herunter unter:\cf1', _TextLineinsert);
      TextAddLine(vTxt, '');
      TextAddLine(vTxt, '');
      TextAddLine(vTxt, '');
      vRtf # TextOpen(20);
      Lib_Texte:Txt2Rtf(vTxt, vRTF, 'Calibre', 15, 0, (TextInfo(vRTF,_textLines)>0));
      vI # TextInfo(vRTF,_textLines);
      TextLineWrite(vRTF, vI-1, '{\cf0\f2\fs30\lang7{\field{\*\fldinst{HYPERLINK www.stahl-control.de\\\\downloads\\\\anydesk.exe }}{\fldrslt{www.stahl-control.de\\downloads\\anydesk.exe\ul0\cf0}}}}\par',_TextLineInsert);
//textwrite(vRTF,'',_TextClipboard);
      Dlg_Standard:TooltipRTF(vRTF,'Helpdesk');
      TextClose(vRtf);
      TextClose(vTxt);
     
    end
    else begin
      SysExecute('.\helpdesk\'+Set.Helpdesk.exe,'',0);
    end;
  end;

end;


//========================================================================