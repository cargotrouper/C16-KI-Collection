@A+
//===== Business-Control =================================================
//
//  Prozedur    App_Commands
//
//  Info
//
//
//  05.02.2008  AI  Erstellung der Prozedur
//  04.07.2012  AI  Erweiter: Cleanup leert AFX/SFX/Customfelder
//  08.04.2013  AI  Erweitern: Cleanup für KAssenbuch 570
//  09.04.2018  AH  Mathemodul raus, dafür Inventur als eigener Punkt
//  20.06.2018  AH  "Cleanup" für VorlageBAs
//
//  Subprozeduren
//    SUB RepairOfPZEi() : logic;
//    SUB FormPreview(aCmd : alpha);
//    SUB RenameProc(aCmd : alpha);
//    SUB EinkaufRecalc(aCmd : alpha);
//    SUB AuftragRecalc(aCmd : alpha);
//    SUB ArtikelRecalc(aCmd : alpha);
//    SUB BARecalc(aCmd : alpha);
//    SUB Backup(aCmd : alpha);
//    SUB ClearDocs(aCmd : alpha);
//    SUB CleanUp(aCmd : alpha);
//    SUB DispoRecalc(aCmd : alpha);
//    SUB MaterialRecalc(aCmd : alpha);
//    SUB OSTNeu(aCmd : alpha);
//    SUB REDO100(aCmd : alpha);
//    SUB RestoreAll(aCmd : alpha);
//    SUB TestReset(aCmd : alpha);
//    SUB CopyDB(aCmd : alpha);
//    SUB CheckAFX(aCmd : alpha);
//
//========================================================================
@I:Def_Global

declare RestoreAll(aCmd : alpha; opt aSilent : logic) : logic;

//========================================================================
//  call App_Commands:RepairOfPZEi
//    MS
//========================================================================
sub RepairOfPZEi() : logic;
local begin
  vSel      : int;
  vSelName  : alpha;
  vQ460     : alpha;
  vProgress : int;
end;
begin

  RestoreAll('460', true); // Offene Posten aus Ablage holen

  vQ460 # '(OfP.Bemerkung = '''
  + Translate('STORNO-OP')
  + ''') OR (OfP.Bemerkung = '''
   + Translate('STORNIERT') + ''')';

  vSel # SelCreate(460, 1);
  Erg # vSel->SelDefQuery('', vQ460);
  if (Erg <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Korrigiere Offene Posten/Zahlungseingaenge ...', RecInfo(460, _recCount, vSel));

  WinSleep(1000);

  FOR Erg # RecRead(460, vSel, _recFirst); // Selektierte Fertigungen loopen
  LOOP Erg # RecRead(460, vSel, _recNext);
  WHILE (Erg <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(460, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN false;
    end;

    FOR Erg # RecLink(461, 460, 1,_recFirst); // Selektierte Fertigungen loopen
    LOOP Erg # RecLink(461, 460, 1,_recNext);
    WHILE(Erg <= _rLocked) DO BEGIN
      if(OfP.Z.Zahlungsnr = 1) then begin
        Erg # RecRead(461, 1, _recLock);
        if(Erg <> _rOK) then begin
        end;

        Ptd_Main:Memorize(461);

        OfP.Z.Zahlungsnr  # 0;

        Erg # RekReplace(461, _recUnlock, 'AUTO');
        if(Erg <> _rOK) then begin
        end;

        Ptd_Main:Compare(461);
      end;
    END;
  END;

  SelClose(vSel);
  SelDelete(460, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Term();
end;

//========================================================================
//  FormPreview
//
//========================================================================
sub FormPreview();
begin
  if(WinDialogBox(gFrmMain,'COMMAND', Translate('Wollen Sie alle Formular auf Vorschau setzen?'),_WinIcoInformation,_WinDialogYesNo,0) = _WinIdYes) then begin
    FOR Erg # RecRead(912, 1, _recFirst | _recLock);
    LOOP Erg # RecRead(912, 1, _recNext | _recLock);
    WHILE(Erg = _rOK) DO BEGIN
      Frm.DirektdruckYN # false;
      Frm.VorschauYN # true;
      Erg # RekReplace(912, _recUnlock, 'AUTO');
    END;
    WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
  end;
end;


//========================================================================
//  App_Commands:RenameProc
//  Zum umbennen/kopieren von Kundenprozeduren
//  Aufruf zB. RenameProc SSK->VWW
//  wuerde alle Staufen Prozeduren in Voelkel umbennen
//  !Prozedurinhalte muessen weiterhin manuel geaendert werden
//  MS 13.07.2010
//========================================================================
sub RenameProc(aCmd : alpha);
local begin
  vHdl : int;
  vProc : alpha;
  vToken : alpha;
  vNewProc : alpha;
  vNewToken : alpha;
  vDel      : logic;
end;
begin

  Erg # StrFind(aCmd, '->', 0);
  if(Erg = 0) then
    RETURN;

  vToken # StrCnv((StrAdj(StrCut(aCmd, StrFind(aCmd, ' ', 0) + 1, Erg - (StrFind(aCmd, ' ', 0) + 1)), _StrBegin | _StrEnd)), _StrUpper);
  vNewToken # StrCnv(StrAdj(StrCut(aCmd, Erg + 2, StrLen(aCmd) - Erg + 2), _StrBegin | _StrEnd), _StrUpper);

  vDel # false;
  if(WinDialogBox(gFrmMain,'COMMAND', Translate('Wollen Sie Prozeduren mit Namen ' + vToken + ' kopieren und in ' + vNewToken + ' umbennen?'),_WinIcoInformation,_WinDialogYesNo,0) = _WinIdYes) then begin
    if(WinDialogBox(gFrmMain,'COMMAND', Translate('SICHER?'),_WinIcoInformation,_WinDialogYesNo,0) = _WinIdYes) then begin
      if(WinDialogBox(gFrmMain,'COMMAND', Translate('Alte Prozduren mit ' + vToken + 'löschen?'),_WinIcoInformation,_WinDialogYesNo,0) = _WinIdYes) then
        vDel # true;
      vHdl # TextOpen(16);
      FOR Erg # vHdl -> TextRead('', _TextFirst | _TextProc);
      LOOP Erg # vHdl -> TextRead(vProc, _TextNext | _TextProc);
      WHILE(Erg <= _rLocked) DO BEGIN
        vProc # vHdl -> TextInfoAlpha(_TextName);
        if(StrFind(vProc, vToken, 0) > 0) then begin
          vNewProc # Str_ReplaceAll(vProc, vToken, vNewToken);
          TxtCopy(vProc, vNewProc, _TextProc);
          if(vDel = true) then
            TxtDelete(vProc, _TextProc);
        end;
      END;
      vHdl -> TextClose();
    end;
  end;

  if(WinDialogBox(gFrmMain,'COMMAND', Translate('Formulare ' + vToken + ' umbennen in ' + vNewToken +'?'),_WinIcoInformation,_WinDialogYesNo,0) = _WinIdYes) then begin
    // Formulare in den Settings umbennen
    FOR  Erg # RecRead(912, 1, _recFirst | _recLock);
    LOOP Erg # RecRead(912, 1, _recNext | _recLock);
    WHILE(Erg <= _rLocked) DO BEGIN
      Frm.Prozedur # Str_ReplaceAll(Frm.Prozedur, vToken, vNewToken);
      RekReplace(912, _recUnlock, 'MAN')
    END;
  end;
end;

//========================================================================
//  call App_Commands:EinkaufRepair
//
//========================================================================
//sub EinkaufRepair(aCmd : alpha);
sub EinkaufRepair();
local begin
  vProgress   : handle;
  vCount      : int;
  vI          : int;
  vAlterRest  : float;
end;
begin
  vCount # RecInfo(501, _recCount);
  vI # 0;
  vProgress # Lib_Progress:Init('EinkaufRecalc', vCount);
  TRANSON;
  FOR Erg # RecRead(501, 1, _recFirst);
  LOOP Erg # RecRead(501, 1, _recNext)
  WHILE(Erg <= _rLocked) DO BEGIN
    inc(vI);
    vProgress->Lib_Progress:Step()
    vProgress->Lib_Progress:SetLabel(AInt(vI) + '/' + AInt(vCount))

    Erg # RecRead(501, 1, _recLock); // Position sperren
    if(Erg <> _rOK) then begin
      TRANSBRK;
      Error(001001, AInt(Ein.P.Nummer) + '/' + AInt(Ein.P.Position));
      vProgress->Lib_Progress:Term();
      BREAK;
    end;

    if (Wgr_Data:IstMat()) then begin
      Ein.P.Menge.Wunsch  # Ein.P.Gewicht;
      Ein.P.Menge         # Ein.P.Gewicht;
    end;

    vAlterRest # Ein.P.FM.Rest;

    Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;

    Ein_Data:SumAufpreise(c_ModeEdit);

    Erg # Ein_Data:PosReplace(_recUnlock, 'MAN'); // Position zurueckspeichern
    if(Erg <> _rOK) then begin
      TRANSBRK;
      Error(999999, 'SavPos ' + AInt(Ein.P.Nummer) + '/' + AInt(Ein.P.Position));
      vProgress->Lib_Progress:Term();
      BREAK;
    end;

  END;

  if(ErrList = 0) then
    TRANSOFF;

  ErrorOutput;
  vProgress->Lib_Progress:Term();
  WinDialogBox(gFrmMain, 'DONE', 'DONE!', _WinIcoInformation, _WinDialogOk, 0)
end;


//========================================================================
//  EinkaufRecalc
//
//========================================================================
sub EinkaufRecalc(aCmd : alpha);
local begin
  vProgress : handle;
  vCount    : int;
  vI        : int;
end;
begin
  vCount # RecInfo(501, _recCount);
  vI # 0;
  vProgress # Lib_Progress:Init('EinkaufRecalc', vCount);
  FOR Erg # RecRead(501, 1, _recFirst);
  LOOP Erg # RecRead(501, 1, _recNext)
  WHILE(Erg <= _rLocked) DO BEGIN
    Erg # RecLink(504, 501, 15, _recFirst); // 1 Aktion holen
    if(Erg > _rLocked) then
      RecBufClear(504);

    inc(vI);
    vProgress->Lib_Progress:Step()
    vProgress->Lib_Progress:SetLabel(AInt(vI) + '/' + AInt(vCount))
    if (Ein_A_Data:RecalcAll()=false) then
      ErrorOutput;
  END;
  vProgress->Lib_Progress:Term();
  WinDialogBox(gFrmMain, 'DONE', 'DONE!', _WinIcoInformation, _WinDialogOk, 0)
end;


//========================================================================
//  AuftragRepair
//
//========================================================================
sub AuftragRepair();
local begin
  vProgress : handle;
  vCount    : int;
  vI        : int;
end;
begin
  vCount # RecInfo(401, _recCount);
  vI # 0;
  vProgress # Lib_Progress:Init('AuftragRecalc', vCount);
  TRANSON;
  FOR Erg # RecRead(401, 1, _recFirst);
  LOOP Erg # RecRead(401, 1, _recNext)
  WHILE(Erg <= _rLocked) DO BEGIN
    Erg # RecRead(401, 1, _recLock); // Position sperren
    if(Erg <> _rOK) then begin
      TRANSBRK;
      Error(001001, AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position));
      vProgress->Lib_Progress:Term();
      BREAK;
    end;

    inc(vI);
    vProgress->Lib_Progress:Step()
    vProgress->Lib_Progress:SetLabel(AInt(vI) + '/' + AInt(vCount))

    Auf.P.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
    Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);

    Erg # Auf_Data:PosReplace( _recUnlock, 'MAN'); // Position zurueckspeichern
    if(Erg <> _rOK) then begin
      TRANSBRK;
      Error(999999, 'SavPos ' + AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position));
      vProgress->Lib_Progress:Term();
      BREAK;
    end;
  END;

  vProgress->Lib_Progress:Term();

  if(ErrList = 0) then begin
    vCount # RecInfo(411, _recCount);
    vI # 0;
    vProgress # Lib_Progress:Init('AuftragRecalc', vCount);
    FOR Erg # RecRead(411, 1, _recFirst);
    LOOP Erg # RecRead(411, 1, _recNext)
    WHILE(Erg <= _rLocked) DO BEGIN
      Erg # RecRead(411, 1, _recLock); // Position sperren
      if(Erg <> _rOK) then begin
        TRANSBRK;
        Error(001001, AInt("Auf~P.Nummer") + '/' + AInt("Auf~P.Position"));
        vProgress->Lib_Progress:Term();
        BREAK;
      end;

      inc(vI);
      vProgress->Lib_Progress:Step()
      vProgress->Lib_Progress:SetLabel(AInt(vI) + '/' + AInt(vCount))

      "Auf~P.Einzelpreis" # "Auf~P.Grundpreis" + "Auf~P.Aufpreis";
      "Auf~P.Gesamtpreis" # Auf_data:SumGesamtpreis("Auf~P.Menge", "Auf~P.Stückzahl" , "Auf~P.Gewicht");

      Erg # RekReplace(411, _recUnlock, 'MAN'); // Position zurueckspeichern
      if(Erg <> _rOK) then begin
        TRANSBRK;
        Error(999999, 'SavPos ' + AInt("Auf~P.Nummer") + '/' + AInt("Auf~P.Position"));
        vProgress->Lib_Progress:Term();
        BREAK;
      end;

    END;
  end;

  if(ErrList = 0) then
    TRANSOFF;

  ErrorOutput;
  vProgress->Lib_Progress:Term();
  WinDialogBox(gFrmMain, 'DONE', 'DONE!', _WinIcoInformation, _WinDialogOk, 0)
end;



//========================================================================
//  AuftragRecalc
//
//========================================================================
sub AuftragRecalc(aCmd : alpha);
local begin
  vProgress : handle;
  vCount    : int;
  vI        : int;
end;
begin
  vCount # RecInfo(401, _recCount);
  vI # 0;
  vProgress # Lib_Progress:Init('AuftragRecalc', vCount);
  FOR Erg # RecRead(401, 1, _recFirst);
  LOOP Erg # RecRead(401, 1, _recNext)
  WHILE(Erg <= _rLocked) DO BEGIN
    Erg # RecLink(404, 401, 12, _recFirst); // 1 Aktion holen
    if(Erg > _rLocked) then
      RecBufClear(404);

    inc(vI);
    vProgress->Lib_Progress:Step()
    vProgress->Lib_Progress:SetLabel(AInt(vI) + '/' + AInt(vCount))
    if (Auf_A_Data:RecalcAll()=false) then
      ErrorOutput;
  END;
  vProgress->Lib_Progress:Term();
  WinDialogBox(gFrmMain, 'DONE', 'DONE!', _WinIcoInformation, _WinDialogOk, 0)
end;

//========================================================================
//  RepairAbruf
//
//========================================================================
sub RepairAbruf(aCmd : alpha);
local begin
  vProgress : handle;
  vCount    : int;
  vI        : int;
  vQ400     : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
end;
begin

  vQ400 # '';
  Lib_Sel:QLogic(var vQ400, 'Auf.AbrufYN', true);

  vSel # SelCreate(400, 1);
  Erg # vSel->SelDefQuery('', vQ400);
  if (Erg <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Korrigiere Abrufe/Rahmen ...', RecInfo(400, _recCount, vSel));

  WinSleep(1000);

  TRANSON;

  FOR Erg # RecRead(400, vSel, _recFirst); // Selektierte Fertigungen loopen
  LOOP Erg # RecRead(400, vSel, _recNext);
  WHILE (Erg <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(400, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    Erg # RecLink(401, 400, 9, _recFirst); // 1. Auftragspos.
    if(Erg > _rLocked) then
      RecBufClear(401);

    if (Auf_Data:VerbucheAbruf(false) = false) then begin
      /*
      TRANSBRK;
      SelClose(vSel);
      SelDelete(400, vSelName);
      vProgress->Lib_Progress:Term();
      Msg(401401, AInt(Auf.P.Nummer) + ' / ' + AInt(Auf.P.Position),0,0,0);
      ErrorOutput;
      RETURN;
     */
     end;

  END;

  TRANSOFF;

  SelClose(vSel);
  SelDelete(400, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Term();


  WinDialogBox(gFrmMain, 'DONE', 'DONE!', _WinIcoInformation, _WinDialogOk, 0)
end;


//========================================================================
//  ArtikelRecalc
//
//========================================================================
sub ArtikelRecalc(aCmd : alpha);
begin
  Art_Data:ReCalcAll();
  WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  BARecalcOutput
//
//========================================================================
sub BARecalcOutput(aCmd : alpha);
begin
  BA1_Subs:RecalcOutput();
  WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  Backup
//
//========================================================================
sub Backup(aCmd : alpha);
begin
  DbaControl(_DbaBackupStart,60);
  WinDialogBox(gFrmMain,'COMMAND',Translate('!!! Datenbank ist im BACKUPMODUS !!!'),_WinIcoWarning,_WinDialogOkCancel,0);
  dbaControl(_DbaBackupStop);
end;


//========================================================================
//  Cleanup
//
//========================================================================
sub CleanUp ( aCmd : alpha );
local begin
  vHdl    : handle;
  vPrgr   : handle;
  vName   : alpha;
end;
begin
  vHdl # WinOpen( 'Frame.Cmd.CleanUp', _winOpenDialog );
  if ( vHdl <= 0 ) then
    RETURN;

  vHdl->WinDialogRun();
  if ( vHdl->WinDialogResult() = _winIdOk ) then begin
    vPrgr # Lib_Progress:Init( 'Cleanup', 46+2+4 );
    

    /* Auftrag */
    if ( vHdl->WinSearch( 'cb400' )->wpCheckState = _winStateChkChecked ) then begin // Aufträge
      Lib_Rec:ClearFile( 400 ); // Auftragskopf
      Lib_Rec:ClearFile( 401 ); // Positionen
      Lib_Rec:ClearFile( 402 ); // AF
      Lib_Rec:ClearFile( 403 ); // Aufpreise
      Lib_Rec:ClearFile( 404 ); // Aktionen
      Lib_Rec:ClearFile( 405 ); // Kalkulation
      Lib_Rec:ClearFile( 406 ); // Einteilung
      Lib_Rec:ClearFile( 407 ); // Verpackung
      Lib_Rec:ClearFile( 408 ); // Feinabrufe
      Lib_Rec:ClearFile( 409 ); // Stückliste

      Lib_Texte:TxtDelRange( '~400', '~409' );
      Lib_Texte:TxtDelRange( '~420', '~449' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb410' )->wpCheckState = _winStateChkChecked ) then begin // Auftragsablage
      Lib_Rec:ClearFile( 410 ); // ~Auftragskopf
      Lib_Rec:ClearFile( 411 ); // ~Positionen
      Lib_Texte:TxtDelRange( '~410', '~419' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb440' )->wpCheckState = _winStateChkChecked ) then begin // Lieferscheine
      Lib_Rec:ClearFile( 440 ); // Lieferkopf
      Lib_Rec:ClearFile( 441 ); // Positionen
    end;
    if ( vHdl->WinSearch( 'cb130' )->wpCheckState = _winStateChkChecked ) then begin // Lieferantenrklärungen
      Lib_Rec:ClearFile( 130 ); // Lieferantenerklärung
      Lib_Rec:ClearFile( 131 ); // Positionen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb650' )->wpCheckState = _winStateChkChecked ) then begin // Versand (inkl. Abl.)
      Lib_Rec:ClearFile( 650 ); // Versand
      Lib_Rec:ClearFile( 651 ); // Versand.Pos
      Lib_Rec:ClearFile( 655 ); // Versandpool
      Lib_Rec:ClearFile( 656 ); // ~Versandpool
    end;
    vPrgr->Lib_Progress:Step();

    /* Einkauf */
    if ( vHdl->WinSearch( 'cb500' )->wpCheckState = _winStateChkChecked ) then begin // Einkauf
      Lib_Rec:ClearFile( 500 ); // Einkaufskopf
      Lib_Rec:ClearFile( 501 ); // Positionen
      Lib_Rec:ClearFile( 502 ); // AF
      Lib_Rec:ClearFile( 503 ); // Aufpreise
      Lib_Rec:ClearFile( 504 ); // Aktionen
      Lib_Rec:ClearFile( 505 ); // Kalkulation
      Lib_Rec:ClearFile( 506 ); // Wareneingang
      Lib_Rec:ClearFile( 507 ); // WE-AF

      Lib_Texte:TxtDelRange( '~500', '~509' );
      Lib_Texte:TxtDelRange( '~520', '~599' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb510' )->wpCheckState = _winStateChkChecked ) then begin // Einkaufsablage
      Lib_Rec:ClearFile( 510 ); // ABLAGE Einkaufskopf
      Lib_Rec:ClearFile( 511 ); // ABLAGE Positionen
      Lib_Texte:TxtDelRange( '~510', '~519' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb540' )->wpCheckState = _winStateChkChecked ) then begin // Bedarfsdatei
      Lib_Rec:ClearFile( 540 ); // Bedarf
      Lib_Rec:ClearFile( 541 ); // Aktionen

      Lib_Rec:ClearFile( 545 ); // ABLAGE Bedarf
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb190' )->wpCheckState = _winStateChkChecked ) then begin // Hilfs- und Betriebsstoffe EK
      Lib_Rec:ClearFile( 190 ); // HUB EK Köpfe
      Lib_Rec:ClearFile( 191 ); // HUB EK Positionen
      Lib_Rec:ClearFile( 192 ); // HUB EK Wareneingänge
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb620' )->wpCheckState = _winStateChkChecked ) then begin // Sammelwareneingänge
      Lib_Rec:ClearFile( 620 ); // SWE
      Lib_Rec:ClearFile( 621 ); // SWE-Pos.
      Lib_Rec:ClearFile( 622 ); // SWE-Pos.-AF
    end;
    vPrgr->Lib_Progress:Step();

    /* Produktion */
    if ( vHdl->WinSearch( 'cb700' )->wpCheckState = _winStateChkChecked ) and
      ( vHdl->WinSearch( 'cb700Vorlage' )->wpCheckState = _winStateChkChecked ) then begin // Betriebsaufträge
      Lib_Rec:ClearFile( 700 ); // Kopf
      Lib_Rec:ClearFile( 701 ); // IO
      Lib_Rec:ClearFile( 702 ); // Position
      Lib_Rec:ClearFile( 703 ); // Fertigung
      Lib_Rec:ClearFile( 704 ); // Verpackung
      Lib_Rec:ClearFile( 705 ); // AF
      Lib_Rec:ClearFile( 706 ); // Ressource
      Lib_Rec:ClearFile( 707 ); // FM
      Lib_Rec:ClearFile( 708 ); // FM Betriebsmittel
      Lib_Rec:ClearFile( 709 ); // Zeiten
      Lib_Rec:ClearFile( 710 ); // Fehler
      Lib_Rec:ClearFile( 711 ); // Positionszusatz

      Lib_Rec:ClearFile( 170 ); // Rso-Reservierungen
      Lib_Rec:ClearFile( 171 ); // Rso-Res-Verbindungen
      Lib_Texte:TxtDelRange( '~700', '~709' );
    end
    else begin
      Erg # RecRead(700,1,_recFirst);
      WHILE (erg<=_rLocked) do begin
        if ((BAG.VorlageYN) and (vHdl->WinSearch( 'cb700Vorlage' )->wpCheckState = _winStateChkChecked )) or
           ((BAG.VorlageYN=false) and (vHdl->WinSearch( 'cb700' )->wpCheckState = _winStateChkChecked )) then begin
          FOR Erg # RecLink(701,700,3 ,_RecFirst)
          LOOP Erg # RecLink(701,700,3 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(701);
          END;
          FOR Erg # RecLink(702,700,1 ,_RecFirst)
          LOOP Erg # RecLink(702,700,1 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K';
            TxtDelete(vName,0)
            vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
            TxtDelete(vName,0)
            RekDelete(702);
          END;
          FOR Erg # RecLink(703,700,6 ,_RecFirst)
          LOOP Erg # RecLink(703,700,6 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            vName # '~703.'+CnvAI(BAG.F.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+CnvAI(BAG.F.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+CnvAI(BAG.F.Fertigung,_FmtNumLeadZero | _FmtNumNoGroup,0,4);
            TxtDelete(vName,0);
            RekDelete(703);
          END;
          FOR Erg # RecLink(704,700,2 ,_RecFirst)
          LOOP Erg # RecLink(704,700,2 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(704);
          END;
          FOR Erg # RecLink(705,700,7 ,_RecFirst)
          LOOP Erg # RecLink(705,700,7 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(705);
          END;
          FOR Erg # RecLink(706,700,8 ,_RecFirst)
          LOOP Erg # RecLink(706,700,8 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(706);
          END;
          FOR Erg # RecLink(707,700,5 ,_RecFirst)
          LOOP Erg # RecLink(707,700,5 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(707);
          END;
          FOR Erg # RecLink(708,700,11,_RecFirst)
          LOOP Erg # RecLink(708,700,11,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(708);
          END;
          FOR Erg # RecLink(709,700,9 ,_RecFirst)
          LOOP Erg # RecLink(709,700,9 ,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(709);
          END;
          FOR Erg # RecLink(710,700,12,_RecFirst)
          LOOP Erg # RecLink(710,700,12,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(719);
          END;
          FOR Erg # RecLink(711,700,10,_RecFirst)
          LOOP Erg # RecLink(711,700,10,_RecFirst)
          WHILE (erg<=_rLocked) do begin
            RekDelete(711);
          END;

          RekDelete(700);
          Erg # RecRead(700,1,0);
          Erg # RecRead(700,1,0);
          CYCLE;
        end;
        Erg # RecRead(700,1,_recNext);
      END;

    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb600' )->wpCheckState = _winStateChkChecked ) then begin // Grobplanungen
      Lib_Rec:ClearFile( 600 ); //
      Lib_Rec:ClearFile( 601 ); //
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb280' )->wpCheckState = _winStateChkChecked ) then begin // Pakete
      Lib_Rec:ClearFile( 280 ); // Pakete
      Lib_Rec:ClearFile( 281 ); // Paketpositionen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb300' )->wpCheckState = _winStateChkChecked ) then begin // Reklamationen
      Lib_Rec:ClearFile( 300 ); // Reklamationen
      Lib_Rec:ClearFile( 301 ); // Positionen
      Lib_Rec:ClearFile( 302 ); // Aktionen
      Lib_Texte:TxtDelRange( '~300', '~349' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb310' )->wpCheckState = _winStateChkChecked ) then begin // 8D-Reports
      Lib_Rec:ClearFile( 310 ); // 8D-Reports
    end;
    vPrgr->Lib_Progress:Step();

    /* Finanzen */
    if ( vHdl->WinSearch( 'cb450' )->wpCheckState = _winStateChkChecked ) then begin // Rechnungsdatei
      Lib_Rec:ClearFile( 450 ); // Erlöse
      Lib_Rec:ClearFile( 451 ); // Konten
      Lib_Texte:TxtDelRange('~450','~451');
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb460' )->wpCheckState = _winStateChkChecked ) then begin // Offene Posten (inkl. Abl.)
      Lib_Rec:ClearFile( 460 ); // Erlöse
      Lib_Rec:ClearFile( 461 ); // Konten
      Lib_Rec:ClearFile( 470 ); // Ablage
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb465' )->wpCheckState = _winStateChkChecked ) then begin // Zahlungseingang
      Lib_Rec:ClearFile( 465 ); // Erlöse
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb550' )->wpCheckState = _winStateChkChecked ) then begin // Verbindlichkeiten
      Lib_Rec:ClearFile( 550 ); // Verbindlichkeiten
      Lib_Rec:ClearFile( 551 ); // Konten
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb570' )->wpCheckState = _winStateChkChecked ) then begin // Kassenbuch
      Lib_Rec:ClearFile( 570 ); // Kasse
      Lib_Rec:ClearFile( 571 ); // Kassenbuch
      Lib_Rec:ClearFile( 572 ); // Kassenbuchposten
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb560' )->wpCheckState = _winStateChkChecked ) then begin // Eingangsrechnungen
      Lib_Rec:ClearFile( 560 ); // Eingangsrechnungnen
      Lib_Rec:ClearFile( 561 ); // Zahlungen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb565' )->wpCheckState = _winStateChkChecked ) then begin // Zahlungsausgang
      Lib_Rec:ClearFile( 565 ); // Zahlungsausgang
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb555' )->wpCheckState = _winStateChkChecked ) then begin // Einkaufskontrolle
      Lib_Rec:ClearFile( 555 ); // Kontrolle
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb558' )->wpCheckState = _winStateChkChecked ) then begin // Fixkosten
      Lib_Rec:ClearFile( 558 ); // Fixkosten
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb890' )->wpCheckState = _winStateChkChecked ) then begin // Statistiken
      Lib_Rec:ClearFile( 890 ); // Online1
      Lib_Rec:ClearFile( 891 ); // Online2
      Lib_Rec:ClearFile( 892 ); // Online3
      Lib_Rec:ClearFile( 899 ); // Statistik
    end;
    vPrgr->Lib_Progress:Step();

    /* Schlüsseldateien */
    if ( vHdl->WinSearch( 'cb840' )->wpCheckState = _winStateChkChecked ) then begin // Aufpreisliste
      Lib_Rec:ClearFile( 842 ); // Kopf
      Lib_Rec:ClearFile( 843 ); // Position
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb8xx' )->wpCheckState = _winStateChkChecked ) then begin // alle Schlüsseldateien
      Lib_Rec:ClearFile( 810 ); // Gruppen
      Lib_Rec:ClearFile( 811 ); // Anreden
      Lib_Rec:ClearFile( 812 ); // Länder
      Lib_Rec:ClearFile( 813 ); // Steuerschlüssel
      Lib_Rec:ClearFile( 814 ); // Währungen
      Lib_Rec:ClearFile( 815 ); // Lieferbed.
      Lib_Rec:ClearFile( 816 ); // Zahlungsbed
      Lib_Rec:ClearFile( 817 ); // Versandarten
      Lib_Rec:ClearFile( 818 ); // Verwiegungsarten
      Lib_Rec:ClearFile( 819 ); // Warengruppen
      //Lib_Rec:ClearFile( 820 ); // Materail  Stati
      Lib_Rec:ClearFile( 821 ); // Abteilungen
      Lib_Rec:ClearFile( 822 ); // Ressourcengruppen
      Lib_Rec:ClearFile( 823 ); // IHA Meldungen
      Lib_Rec:ClearFile( 824 ); // IHA Ursachen
      Lib_Rec:ClearFile( 825 ); // IHA Maßnahmen
      Lib_Rec:ClearFile( 826 ); // Artikelgruppen
      //Lib_Rec:ClearFile( 827 ); // Mathealphabet
      //Lib_Rec:ClearFile( 828 ); // Arbeitsgänge
      Lib_Rec:ClearFile( 829 ); // Skizzen
      Lib_Rec:ClearFile( 832 ); // Qualitäten
      Lib_Rec:ClearFile( 833 ); // Mechanik
      Lib_Rec:ClearFile( 834 ); // Toleranzen
      Lib_Rec:ClearFile( 835 ); // Auftragsarten
      Lib_Rec:ClearFile( 836 ); // BDS
      Lib_Rec:ClearFile( 838 ); // Unterlagen
      Lib_Rec:ClearFile( 839 ); // Zeugnisse
      Lib_Rec:ClearFile( 840 ); // Etiketten
      Lib_Rec:ClearFile( 841 ); // Oberflächen
      Lib_Rec:ClearFile( 844 ); // Lagerplätze
      Lib_Rec:ClearFile( 846 ); // Kostenstellen
      Lib_Rec:ClearFile( 849 ); // Reklamationsarten
      Lib_Rec:ClearFile( 850 ); // Vorgangsstati
      Lib_Rec:ClearFile( 851 ); // Fehlercodes
      Lib_Rec:ClearFile( 852 ); // Zahlungsarten
    end;
    vPrgr->Lib_Progress:Step();

    /* Sonstiges */
/***
if ( vHdl->WinSearch( 'cb770' )->wpCheckState = _winStateChkChecked ) then begin // Mathemodul
      Lib_Rec:ClearFile( 770 ); //
      Lib_Rec:ClearFile( 771 ); //
      Lib_Rec:ClearFile( 772 ); //
      Lib_Rec:ClearFile( 773 ); //
      Lib_Rec:ClearFile( 774 ); //
      Lib_Rec:ClearFile( 775 ); //
      Lib_Rec:ClearFile( 776 ); //
      Lib_Rec:ClearFile( 777 ); //
      Lib_Rec:ClearFile( 778 ); //
      Lib_Rec:ClearFile( 779 ); //
    end;
    vPrgr->Lib_Progress:Step();
***/
    if ( vHdl->WinSearch( 'cb980' )->wpCheckState = _winStateChkChecked ) then begin // Aktivitäten
      Lib_Rec:ClearFile( 980 ); // Termine
      Lib_Rec:ClearFile( 981 ); // Anker
      Lib_Rec:ClearFile( 982 ); // Berichte
      Lib_Rec:ClearFile( 989 ); // Events

      Lib_Texte:TxtDelRange( '~982', '~983' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb940' )->wpCheckState = _winStateChkChecked ) then begin // Statistiken
      Lib_Rec:ClearFile( 940 ); // WoF Schema
      Lib_Rec:ClearFile( 941 ); // WoF Aktivität
      Lib_Rec:ClearFile( 942 ); // WoF Bedingungen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb950' )->wpCheckState = _winStateChkChecked ) then begin // Statistiken
      Lib_Rec:ClearFile( 950 ); // Controlling
    end;
    vPrgr->Lib_Progress:Step();

    /* Stammdaten */
    if ( vHdl->WinSearch( 'cb100' )->wpCheckState = _winStateChkChecked ) then begin // Adressen
      Lib_Rec:ClearFile( 100 ); // Hauptdaten
      Lib_Rec:ClearFile( 101 ); // Anschriften
      Lib_Rec:ClearFile( 102 ); // Ansprechpartner
      Lib_Rec:ClearFile( 103 ); // Kreditlimit
      Lib_Rec:ClearFile( 105 ); // Verpackungen
      Lib_Rec:ClearFile( 106 ); // +Ausführungen
      Lib_Rec:ClearFile( 107 ); // Kontakte
      Lib_Rec:ClearFile( 109 ); // +Scripte
      Lib_Texte:TxtDelRange( '~100', '~109' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb110' )->wpCheckState = _winStateChkChecked ) then begin // Vertreter & Verbände
      Lib_Rec:ClearFile( 110 ); // Vertreterverbände
      Lib_Rec:ClearFile( 111 ); // Provisionstabelle
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb250' )->wpCheckState = _winStateChkChecked ) then begin // Artikel
      Lib_Rec:ClearFile( 250 ); // Artikel
      Lib_Rec:ClearFile( 251 ); // Reservierungen
      Lib_Rec:ClearFile( 252 ); // Chargen
      Lib_Rec:ClearFile( 253 ); // Journal
      Lib_Rec:ClearFile( 254 ); // Preise
      Lib_Rec:ClearFile( 255 ); // SL-Kopf
      Lib_Rec:ClearFile( 256 ); // SL
      Lib_Rec:ClearFile( 259 ); // Inventurdatei
      Lib_Texte:TxtDelRange( '~250', '~259' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb259' )->wpCheckState = _winStateChkChecked ) then begin // Inventurdatei
      Lib_Rec:ClearFile( 259 ); // Inventurdatei
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb200' )->wpCheckState = _winStateChkChecked ) then begin // Material (inkl. Dispo.)
      Lib_Rec:ClearFile( 200 ); // Material
      Lib_Rec:ClearFile( 201 ); // Ausführungen
      Lib_Rec:ClearFile( 202 ); // Bestandsbuch
      Lib_Rec:ClearFile( 203 ); // Reservierungen
      Lib_Rec:ClearFile( 204 ); // Aktionen
      Lib_Rec:ClearFile( 205 ); // Lagerprotokoll

      Lib_Rec:ClearFile( 240 ); // Dispobestand
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb210' )->wpCheckState = _winStateChkChecked ) then begin // Materialablage
      Lib_Rec:ClearFile( 210 ); // Materialabalge
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb220' )->wpCheckState = _winStateChkChecked ) then begin // Materialstrukturliste
      Lib_Rec:ClearFile( 220 ); // Struktur
      Lib_Rec:ClearFile( 221 ); // StrukturAusführung
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb230' )->wpCheckState = _winStateChkChecked ) then begin // Materialanalysen
      Lib_Rec:ClearFile( 230 ); // Köpfe
      Lib_Rec:ClearFile( 231 ); // Analysen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb180' )->wpCheckState = _winStateChkChecked ) then begin // Hilfs- und Betriebsstoffe VK
      Lib_Rec:ClearFile( 180 ); // HUB Artikel
      Lib_Rec:ClearFile( 181 ); // HUB Preise
      Lib_Rec:ClearFile( 182 ); // HUB Journal
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb120' )->wpCheckState = _winStateChkChecked ) then begin // Projekte
      Lib_Rec:ClearFile( 120 ); // Hauptdaten
      Lib_Rec:ClearFile( 121 ); // Stückliste
      Lib_Rec:ClearFile( 122 ); // Positionen
      Lib_Rec:ClearFile( 123 ); // Zeiten
      Lib_Texte:TxtDelRange( '~120', '~129' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb160' )->wpCheckState = _winStateChkChecked ) then begin // Ressourcen
      Lib_Rec:ClearFile( 160 ); // Ressourcen
      Lib_Rec:ClearFile( 161 ); // Zusatztabellen
      Lib_Rec:ClearFile( 165 ); // Instandhaltung
      Lib_Rec:ClearFile( 166 ); // Ursachen
      Lib_Rec:ClearFile( 167 ); // Maßnahmen
      Lib_Rec:ClearFile( 168 ); // Ersatzteile
      Lib_Rec:ClearFile( 169 ); // Ressourcen Ressourcen

      Lib_Rec:ClearFile( 163 ); // Kalender
      Lib_Rec:ClearFile( 164 ); // Tage
    end;
    vPrgr->Lib_Progress:Step();

    /* System */
    if ( vHdl->WinSearch( 'cb800' )->wpCheckState = _winStateChkChecked ) then begin // User
      Lib_Rec:ClearFile( 800 ); // User
      Lib_Rec:ClearFile( 801 ); // Usr.Gruppen
      Lib_Rec:ClearFile( 802 ); // Usergruppenvergleich
      Lib_Rec:ClearFile( 803 ); // User Favoriten
      Lib_Texte:TxtDelRange( 'INI.', 'INI.z' );
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb904' )->wpCheckState = _winStateChkChecked ) then begin // Übersetzungen
      Lib_Rec:ClearFile( 904 ); // Übersetzungen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb911' )->wpCheckState = _winStateChkChecked ) then begin // Listenberechtigungen
      Lib_Rec:ClearFile( 911 ); // Userberechtigungen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb915' )->wpCheckState = _winStateChkChecked ) then begin // Dokumentenablage
      Lib_Rec:ClearFile( 915, 'TEXT' ); // Dokumentenablage
      RekDeleteAll( 915 );
      Lib_Dokumente:ClearAllDocs();
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb990' )->wpCheckState = _winStateChkChecked ) then begin // Datenänderungsprotokoll
      Lib_Rec:ClearFile( 990 ); // Protokoll
      Lib_Rec:ClearFile( 991 ); // Löschungen
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb837' )->wpCheckState = _winStateChkChecked ) then begin // Textbausteine
      Lib_Rec:ClearFile( 837 ); // Texte
      Lib_Texte:TxtDelRange( '~837', '~838' );
    end;
    vPrgr->Lib_Progress:Step();


    if ( vHdl->WinSearch( 'cb922' )->wpCheckState = _winStateChkChecked ) then begin // SFX/AFX/Customfleder
      Lib_Rec:ClearFile( 922 ); // SFX
      Lib_Rec:ClearFile( 924 ); // SFX-User
      // AFX leeren...
      FOR Erg # RecRead(923,1,_recfirst)
      LOOP Erg # RecRead(923,1,_recNext)
      WHILE (Erg<=_rLocked) do begin
        if (AFX.Prozedur<>'') or (AFX.WoF.Nummer<>0) then begin
          RecRead(923,1,_ReCLock);
          AFX.Prozedur    # '';
          AFX.WOf.Nummer  # 0;
          AFX.WoF.Datei   # 0;
          RekReplace(923,_recunlock,'AUTO');
        end;
      END;
      Lib_Rec:ClearFile( 930 ); // Customfelderpool
      Lib_Rec:ClearFile( 931 ); // Felder
      Lib_Rec:ClearFile( 932 ); // Auswahlfelder
    end;


    if ( vHdl->WinSearch( 'cb905' )->wpCheckState = _winStateChkChecked ) then begin // Job-Server
      Lib_Rec:ClearFile( 905 ); // Jobs
      Lib_Rec:ClearFile( 908 ); // Job-Error
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb907' )->wpCheckState = _winStateChkChecked ) then begin // Pflichtfelder
      Lib_Rec:ClearFile( 907 ); // Pflichtfelder
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb916' )->wpCheckState = _winStateChkChecked ) then begin // Anhänge
      Lib_Rec:ClearFile( 916 ); // Anhänge
      Lib_Rec:ClearFile( 917 ); // Blob-Rechte
    end;
    vPrgr->Lib_Progress:Step();

    if ( vHdl->WinSearch( 'cb960' )->wpCheckState = _winStateChkChecked ) then begin // SOA
      Lib_Rec:ClearFile( 960 ); // SOA
      Lib_Rec:ClearFile( 961 ); //
      Lib_Rec:ClearFile( 965 ); //
    end;
    vPrgr->Lib_Progress:Step();

    vPrgr->Lib_Progress:Term();
    WinDialogBox( gFrmMain, 'Vorgang abgeschlossen', 'Cleanup durchgeführt.', _winIcoInformation, _winDialogOk, 0 );
    WinDialogBox( gFrmMain, 'Achtung', 'ggf. BLOBs noch leeren!', _winIcoInformation, _winDialogOk, 0 );
  end;

  vHdl->WinClose();
end;


//=========================================================================
// CleanUp_EvtClicked
//        CleanUp EvtClicked
//=========================================================================
sub CleanUp_EvtClicked ( aEvt : event )
local begin
  vNewValue : int;
  vSetValue : logic;
end;
begin
  case ( aEvt:obj->wpName ) of
    'Bt.SelectAll' : begin
      vSetValue # true;
      vNewValue # _winStateChkChecked;
    end;

    'Bt.SelectNone' : begin
      vSetValue # true;
      vNewValue # _winStateChkUnchecked;
    end;
  end;

  if ( vSetValue ) then begin
    /* Auftrag */
    $cb400->wpCheckState # vNewValue; // Aufträge
    $cb410->wpCheckState # vNewValue; // Auftragsablage
    $cb440->wpCheckState # vNewValue; // Lieferscheine
    $cb130->wpCheckState # vNewValue; // Lieferantenerklärung
    $cb650->wpCheckState # vNewValue; // Versand (inkl. Abl.)
    /* Einkauf */
    $cb500->wpCheckState # vNewValue; // Einkauf
    $cb510->wpCheckState # vNewValue; // Einkaufsablage
    $cb540->wpCheckState # vNewValue; // Bedarfsdatei
    $cb190->wpCheckState # vNewValue; // Hilfs- und Betriebsstoffe EK
    $cb620->wpCheckState # vNewValue; // Sammelwareneingänge
    /* Produktion */
    $cb700->wpCheckState # vNewValue; // Betriebsaufträge
    $cb700Vorlage->wpCheckState # vNewValue; // Betriebsaufträge Vorlage
    $cb600->wpCheckState # vNewValue; // Grobplanungen
    $cb280->wpCheckState # vNewValue; // Pakete
    $cb300->wpCheckState # vNewValue; // Reklamationen
    $cb310->wpCheckState # vNewValue; // 8D-Reports
    /* Finanzen */
    $cb450->wpCheckState # vNewValue; // Rechnungsdatei
    $cb460->wpCheckState # vNewValue; // Offene Posten (inkl. Abl.)
    $cb465->wpCheckState # vNewValue; // Zahlungseingang
    $cb550->wpCheckState # vNewValue; // Verbindlichkeiten
    $cb560->wpCheckState # vNewValue; // Eingangsrechnungen
    $cb565->wpCheckState # vNewValue; // Zahlungsausgang
    $cb555->wpCheckState # vNewValue; // Einkaufskontrolle
    $cb558->wpCheckState # vNewValue; // Fixkosten
    $cb570->wpCheckState # vNewValue; // Kassenbuch
    $cb890->wpCheckState # vNewValue; // Statistiken
    /* Schlüsseldateien */
    $cb840->wpCheckState # vNewValue; // Aufpreisliste
    $cb8xx->wpCheckState # vNewValue; // alle Schlüsseldateien

    $cb259->wpCheckState # vNewValue; // Inventurdatei

    /* Sonstiges */
//    $cb770->wpCheckState # vNewValue; // Mathemodul
    $cb980->wpCheckState # vNewValue; // Aktivitäten
    $cb922->wpCheckState # vNewValue; // SFX/AFX
    /* Stammdaten */
    $cb100->wpCheckState # vNewValue; // Adressen
    $cb110->wpCheckState # vNewValue; // Vertreter & Verbände
    $cb250->wpCheckState # vNewValue; // Artikel
    $cb200->wpCheckState # vNewValue; // Material (inkl. Dispo.)
    $cb210->wpCheckState # vNewValue; // Materialablage
    $cb220->wpCheckState # vNewValue; // Materialstrukturliste
    $cb230->wpCheckState # vNewValue; // Materialanalysen
    $cb180->wpCheckState # vNewValue; // Hilfs- und Betriebsstoffe VK
    $cb120->wpCheckState # vNewValue; // Projekte
    $cb160->wpCheckState # vNewValue; // Ressourcen
    /* System */
    $cb800->wpCheckState # vNewValue; // User
    $cb904->wpCheckState # vNewValue; // Übersetzungen
    $cb911->wpCheckState # vNewValue; // Listenberechtigungen
    $cb915->wpCheckState # vNewValue; // Dokumentenablage
    $cb990->wpCheckState # vNewValue; // Datenänderungsprotokoll
    $cb837->wpCheckState # vNewValue; // Textbausteine

    $cb940->wpCheckState # vNewValue; // WOf
    $cb950->wpCheckState # vNewValue; // COntrolling
    $cb905->wpCheckState # vNewValue; // Job-Server
    $cb907->wpCheckState # vNewValue; // Pflichtfelder
    $cb916->wpCheckState # vNewValue; // Anhänge
    $cb960->wpCheckState # vNewValue; // SOA
  end;
end;


//========================================================================
//  ClearDocs
//
//========================================================================
sub ClearDocs(aCmd : alpha);
begin
  if (WindialogBox(gFrmMain,'Dateicleanup',Translate('Alle Dokumente löschen?'),_WinIcoQuestion,_WinDialogYesNo,0) = _WinIdYes) then begin
    RekDeleteAll(915);
    Lib_Dokumente:ClearAllDocs();
    WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
  end;
end;


//========================================================================
//  DispoRecalc
//
//========================================================================
sub DispoRecalc(aCmd : alpha);
begin
  DiB_Data:ReCalcAll();
  WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  MaterialRecalc
//
//========================================================================
sub MaterialRecalc(aCmd : alpha);
begin
  Mat_Data:ReCalcAll();
  WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  OSTNeu
//
//========================================================================
sub OSTNeu(aCmd : alpha);
local begin
  vAbschl : date;
end;
begin
  if (Msg(890001,'',_WinIcoWarning,_WinDialogYesNo,2)=_WinIDYes) then begin
    if (Dlg_Standard:Datum(Translate('ab Datum'),var vAbschl)=false) then RETURN
    if (OsT_Data:Recalc(vAbschl)=true) then Msg(999998,'',0,0,0)
    else Msg(999999,'',0,0,0);
  end;
end;


//========================================================================
//  REDO100
//
//========================================================================
sub REDO100(aCmd : alpha);
local begin
  vA  : alpha;
end;
begin
  TRANSON;

  Erg # RecRead(100,1,_recFirst);
  WHILE (erg<=_rLocked) do begin
    vA # Adr_Data:SetStichwort(Adr.Stichwort);
    if (vA<>'') then begin
      TRANSBRK;
      WinDialogBox(gFrmMain,'ERORR','ERROR '+vA+' bei '+Adr.Stichwort,_WinIcoInformation,_WinDialogOk,0)
      RETURN;
    end;
    Erg # RecRead(100,1,_recNext);
  END;

  TRANSOFF;
  WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  RestoreAll
//
//========================================================================
sub RestoreAll(aCmd : alpha; opt aSilent : logic) : logic;
local begin
  vProgress   : handle;
  vCount      : int;
end;
begin

  // Einkauf?
  if (cnvIA(aCmd)=500) then begin
    TRANSON;
    vCount # RecInfo(511, _recCount)
    vProgress # Lib_Progress:Init('RestoreAll Einkauf ...', vCount);

    Erg # RecRead(511,1,_recFirst);
    WHILE (erg<_rLocked) do begin
      // Progress
      if (!vProgress->Lib_Progress:StepTo(vCount - RecInfo(511, _recCount))) then begin
        vProgress->Lib_Progress:Term();
        TRANSBRK;
        RETURN false;
      end;

      if (Ein_Abl_Data:RestoreAusAblage("Ein~P.Nummer")=false) then begin
        TRANSBRK;
        if(aSilent = false) then
          Msg(999999,'',0,0,0)
        RETURN false;
      end;
      Erg # RecRead(511,1,_recFirst);
    END;

    vProgress->Lib_Progress:Term();
    TRANSOFF;
  end;  // 500

  // Verkauf?
  if (cnvIA(aCmd)=400) then begin
    TRANSON;
    vCount # RecInfo(411, _recCount)
    vProgress # Lib_Progress:Init('RestoreAll Auftrag ...', vCount);

    Erg # RecRead(411,1,_recFirst);
    WHILE (erg<_rLocked) do begin
      // Progress
      if (!vProgress->Lib_Progress:StepTo(vCount - RecInfo(411, _recCount))) then begin
        vProgress->Lib_Progress:Term();
        TRANSBRK;
        RETURN false;
      end;

      if (Auf_Abl_Data:RestoreAusAblage("Auf~P.Nummer")=false) then begin
        TRANSBRK;
        if(aSilent = false) then
          Msg(999999,'',0,0,0)
        RETURN false;
      end;
      Erg # RecRead(411,1,_recFirst);
    END;

    vProgress->Lib_Progress:Term();
    TRANSOFF;
  end;  // 400

  // Material?
  if (cnvIA(aCmd)=200) then begin
    TRANSON;
    vCount # RecInfo(210, _recCount)
    vProgress # Lib_Progress:Init('RestoreAll Material ...', vCount);

    Erg # RecRead(210, 1, _recFirst);
    WHILE (erg<_rLocked) do begin
      // Progress
      if (!vProgress->Lib_Progress:StepTo(vCount - RecInfo(210, _recCount))) then begin
        vProgress->Lib_Progress:Term();
        TRANSBRK;
        RETURN false;
      end;

      if (Mat_Abl_Data:RestoreAusAblage("Mat~Nummer")=false) then begin
        TRANSBRK;
        if(aSilent = false) then
          Msg(999999,'',0,0,0);
        RETURN false;
      end;
      Erg # RecRead(210, 1, _recFirst);
    END;

    vProgress->Lib_Progress:Term();
    TRANSOFF;
  end;  // 200

  // Offene Posten?
  if (cnvIA(aCmd)=460) then begin
    TRANSON;
    vCount # RecInfo(470, _recCount)
    vProgress # Lib_Progress:Init('RestoreAll Offene Posten ...', vCount);

    Erg # RecRead(470, 1, _recFirst);
    WHILE (erg<_rLocked) do begin
      // Progress
      if (!vProgress->Lib_Progress:StepTo(vCount - RecInfo(470, _recCount))) then begin
        vProgress->Lib_Progress:Term();
        TRANSBRK;
        RETURN false;
      end;

      if (Ofp_Abl_Data:RestoreAusAblage("OfP~Rechnungsnr") = false) then begin
        TRANSBRK;
        if(aSilent = false) then
          Msg(999999,'',0,0,0);
        RETURN false;
      end;
      Erg # RecRead(470, 1, _recFirst);
    END;

    vProgress->Lib_Progress:Term();
    TRANSOFF;
  end;  // 460

  if(aSilent = false) then
    Msg(999998,'',0,0,0)
  RETURN true;
end;


//========================================================================
//  TestReset
//
//========================================================================
sub TestReset(aCmd : alpha);
begin
  Lib_Rec:ClearFile(400);
  Lib_Rec:ClearFile(401);
  Lib_Rec:ClearFile(402);
  Lib_Rec:ClearFile(403);
  Lib_Rec:ClearFile(404);
  Lib_Rec:ClearFile(405);
  Lib_Rec:ClearFile(407);
  Lib_Rec:ClearFile(408);
  Lib_Rec:ClearFile(409);
  Lib_Texte:TxtDelRange('~400','~449');

  Lib_Rec:ClearFile(440);
  Lib_Rec:ClearFile(441);

  Lib_Rec:ClearFile(450);
  Lib_Rec:ClearFile(451);
  Lib_Rec:ClearFile(460);
  Lib_Rec:ClearFile(461);
  Lib_Rec:ClearFile(465);

  Lib_Rec:ClearFile(500);
  Lib_Rec:ClearFile(501);
  Lib_Rec:ClearFile(502);
  Lib_Rec:ClearFile(503);
  Lib_Rec:ClearFile(504);
  Lib_Rec:ClearFile(505);
  Lib_Rec:ClearFile(506);
  Lib_Texte:TxtDelRange('~500','~599');

  Lib_Rec:ClearFile(540);
  Lib_Rec:ClearFile(541);

  Lib_Rec:ClearFile(555);

  Lib_Rec:ClearFile(251);
  Lib_Rec:ClearFile(252);
  Lib_Rec:ClearFile(253);
//ClrFile(254);

  // Basischargen anlegen
  Erg # RecRead(250,1,_reCfirst);
  WHILE (erg<=_rLocked) do begin
    RecBufClear(252);
    Art.C.ArtikelNr   # Art.Nummer;
    Art_Data:OpenCharge(n);
    Erg # RecRead(250,1,_recNext);
  END;

  Art_Data:ReCalcAll();
  WinDialogBox(gFrmMain,'DONE','DONE!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  CopyDB DEST
//
//========================================================================
sub CopyDB(aCmd : alpha);
begin
//  todo(dbaName(_DbaAreaNAme));
//  todo(FsiPath());
//  DbaInfo
/***/
  if (aCMD='') then begin
    Msg(99,'Bitte Zielpfad angeben z.B. f:\c16\c16\client.55\update',0,0,0);
    RETURN;
  end;
  Msg(99,'Achtung!! Der Zielpfad muss vom Server aus gesehen werden und darf KEINE Netzwerkfreigabe sein !!!',0,0,0);

  DbaControl(_DbaBackupStart,60);
  Winsleep(3000);
//  Lib_FileIO:FSICopy(dbaName(_DbaAreaNAme), 'Z:\C16\client.55\update\aaa.ca1' , n);

  RmtCall('Lib_Server:CopyDB', dbaname(_DBAAreaName),aCMD + '\COPY.CA1');//'F:\c16\c16\client.55\update\aaa.ca1');//Fsipath()+'\update\aaa.ca1');
//  RmtCall('Lib_Server:CopyDB', 'D:\c16\c16\Daten\kunde\future\future.ca1','D:\c16\copy.ca1');

  WinDialogBox(gFrmMain,'COMMAND','!! Auf KOPIE warten !!!',_WinIcoWarning,_WinDialogOk,0);
  dbaControl(_DbaBackupStop);
/****/

end;


//========================================================================
//
//
//========================================================================
sub _CheckAFX_Login(
  aServ : alpha;
  aDB   : alpha;
  aUser : alpha;
  aPass : alpha;
  aAFX  : alphA;
) : alpha;
local begin
  vWert : alpha;
end;
begin
//debug(aDB+ ' '+aAFX);
  Erg # DBAConnect(2,'X_','TCP:'+aServ, aDB, aUser, aPass,'');
  if (erg<>_rOK) then RETURN 'ERROR:'+aint(Erg);

  Try begin
    ErrTryIgnore(_ErrStringOverflow);
    FldDef(2923,1,1,aAFX);
  end;
  Erg # RecRead(2923,1,0);
  if (erg<=_rLocked) then vWert # FldAlpha(2923,1,2);
  DBADisconnect(2);

  RETURN vWert;
end;


//========================================================================
//  CheckAFX
//
//========================================================================
sub CheckAFX(aCmd : alpha);
local begin
  vTxt  : int;
  vA    : alpha(200);
  vServ : alpha;
  vUser : alpha;
  vPass : alpha;
  vI    : int;
  vWert : alpha;
  vText : alpha(4000);
end;
begin

  vTxt # Textopen(20);
  vTxt->TextRead('!!!DATENBANKEN', 0);

  vI # 1;
  vServ # TextLineRead(vTxt, vI, 0);
  inc(vI);
  vUser # TextLineRead(vTxt, vI, 0);
  inc(vI);
  vPass # TextLineRead(vTxt, vI, 0);
  inc(vI);

  vA    # TextLineRead(vTxt, vI, 0);
  vA # StrAdj(vA, _StrBegin);
  inc(vI);
  WHILE (vA<>'') do begin
    vA # Str_Token(vA,'<Name=''',2);
    if (StrCut(vA, StrLen(vA)-1,2)='''>') then
      vA # StrCut(vA, 1, StrLen(vA)-2);
    vWert # _CheckAFX_Login(vServ, vA, vUser, vPass, aCMD);
    if (vWert<>'') then begin
      vText # vText + vA + ' : '+vWert+StrChar(13);
//debug(vA+' : '+vWert);
    end;
    vA    # TextLineRead(vTxt, vI, 0);
    vA # StrAdj(vA, _StrBegin);
    inc(vI);
  END;

  TextClose(vTXT);

//  Msg(99,'Ausgabe in der DEBUG.TXT !',0,0,0)
  Erg # WindialogBox(gFrmMain,'AFX : '+aCmd,vText, _WinIcoInformation, _WinDialogOk|_WinDialogAlwaysOnTop,1);

end;


//========================================================================
// CreateCustom Adr.Verwaltung SFX_Horst
//========================================================================
SUB CreateCustom(
  aDlgName  : alpha;
  aPrefix   : alpha);
local begin
  vBonus    : int;
  vHdl      : int;
  vA,vB     : alpha;
  vDlgNeu   : alpha;
  vProc     : alpha;
  vProcNeu  : alpha;
  vTxt      : int;
  vPre      : alpha;
  vPreNeu   : alpha;
  vI        : int;
end;
begin

  vBonus # VarInfo(WindowBonus);
  if (StrCut(aPrefix,StrLen(aPrefix), 1)<>'_') and
    (StrCut(aPrefix,StrLen(aPrefix), 1)<>'.') then aPrefix # aPrefix + '.';

  vA # lib_Strings:Strings_ReplaceAll(aPrefix, '_', '.');
  vDlgNeu  # vA + aDlgName;

  if (Msg(99,'Kopiere Dialog '+aDlgName+' nach '+vDlgNeu,_WinIcoQuestion, _WinDialogYesNo,2)<>_winidyes) then RETURN;

  vHdl # WinOpen(aDlgName, _winOpenLock | _WinOpeneventsoff);
//  vHdl # WinOpen(aDlgName, _WinOpeneventsoff);
  if (vHdl<=0) then begin
    Msg(99,'Dialog nicht gefunden:'+aDlgName,0,0,0);
    RETURN;
  end;

  vProc # WinEvtProcNameGet(vHdl, _winevtinit);
  vProc # Str_Token(vProc, ':',1);

  // Proc:    Adr_Main        ->  SFX_XYZ_Adr_Main
  // Dialog:  Adr.Verwaltung  ->  SFX.XYZ.Adr.Verwaltung

  vA # lib_Strings:Strings_ReplaceAll(aPrefix, '.', '_');
  vProcNeu  # vA + vProc;

  vPre    # Str_ReplaceAll(vProc,'_Main','');
  vPreNeu # Str_ReplaceAll(vProcNeu,'_Main','');

//debug('neuP:'+vProcNeu+'   dlgneu:'+vDlgNeu);
//debug('Prefix:'+vPre+' -> '+vPreNeu);

  vTxt # TextOpen(10);
  TextRead(vTxt, vProc, _textproc);
  if (TextInfo(vTxt, _TextSize)<=2) then begin
    Msg(99,'Prozedur nicht lesbar: '+vProc,0,0,0);
  end
  else begin
    // Prozedur anpassen:

    vA # 'cPrefix.*\:.*\'''+vPre+'\''';   //cPrefix :   'Mat'
    vB # StrChar(9)+'cPrefix'+Strchar(9)+':'+Strchar(9,2)+''''+vPreNeu+'''';
    vI # TextsearchRegEx(vTxt, 1, 1, _textSearchCI, vA);
    if (vI<>0) then
      TextLineWrite(vTxt, vI, vB, 0);

    Textwrite(vTxt, vProcNeu, _TextProc);
    if (ProcCompile(vProcNeu)<>_errOK) then begin
      Msg(99,'Prozedur-Compile-Error in: '+vProcNeu,0,0,0);
    end;
  end;
  TextClose(vTxt);

  Lib_GuiCom2:SwitchAllEvents(vHdl, vProc, vProcNeu);

  WinSave(vHdl, _WinSaveDefault, vDlgNeu);
  Winclose(vHdl);


  Varinstance(Windowbonus, vBonus);
  Msg(999998,'',0,0,0);

end;

// createcustom mat.verwaltung horst

//========================================================================