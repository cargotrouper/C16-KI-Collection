@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Notifier
//                      OHNE E_R_G
//  Info
//
//
//  25.02.2008  ST  Erstellung der Prozedur
//  05.06.2012  AI  neue TAPI
//  25.06.2012  AI  NEU: RemoveEvent
//  23.11.2017  AH  Erweiterung für RequestID
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//
//    SUB Initialize() : logic
//    SUB MsgCreate(aUser   : alpha; aText   : alpha; opt aOption : alpha;
//                  opt aFarbe  : alpha; opt aDatum  : date; opt aZeit : time;opt aPrio : word) : logic
//    SUB GetQueuePath() : alpha
//    SUB ResolveColor(aCol : alpha; ) : alpha
//    SUB NewEvent(aUser : alpha; aAkt : alpha(200); aText : alpha(1000); opt aAktNr : int; opt aDatum : date; opt aZeit : time; opt aPrio : word)
//    SUB NewRequestID() : bigint;
//    SUB WaitForRequest(aReqID : bigint)
//    SUB NewInfo(aUser : alpha; aText : alpha(1000); opt aReqID : bigint) : bigint
//    SUB UpdateInfo ( aUser : alpha; aReqID : bigint; aText2 : alpha(1000))
//    SUB NewPrjNote ( aUser : alpha; aPrj : int; aPos : int; opt aDatum : date; opt aZeit : time )
//    SUB RemoveEvent(aAkt : alpha; opt aNotUser : alpha);
//    SUB Exists(aAkt : alpha; aUser : alpha) : logic;
//
//    SUB EvtPosChanged(...) : logic
//    SUB EvtLstDataInit(...) : logic
//    SUB EvtMouseItem(...) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

declare GetQueuePath() : alpha
declare ResolveColor(aCol : alpha; ) : alpha

//========================================================================
// Start
//              Startet den Nofitier mit angegebenen Parametern
//========================================================================
sub xxxStart() : logic
local begin
  vHdl       : int;
  vFont      : font;
end;
begin

  if (Usr.NotifierYN=n) then RETURN true;

  if (gMdiNotifier=0) then begin
    gNotifierCounter # -1;
    gMdiNotifier # WinAddByName(gFrmMain, Lib_GuiCom:GetAlternativeName('Mdi.Notifier'), _WinAddHidden);
    vHDL # Winsearch(gMdiNotifier,'rl.Messages');

    // Usersettings holen
    Lib_GuiCom:RecallWindow(gMdiNotifier);
    Lib_GuiCom:RecallList(vHDL);

    vHDL->wpColFocusBkg    # Set.Col.RList.Cursor;
    vHDL->wpColFocusOffBkg # "Set.Col.RList.CurOff";
    if (Usr.Font.Size<>0) then begin
      vFont # vHDL->wpfont;
      vFont:Size # Usr.Font.Size * 10;
      vHDL->wpfont # vFont;
    end;
    /*  DEAKTIVIERT MS 23.05.2012
    if Rechte[Rgt_Notifier_Close] then
      gMDINotifier->wpStyleCloseBox # y;
    */
    gMdiNotifier->WinUpdate(_WinUpdOn);
  end
  else begin
//        gMdiNotifier->WinFocusSet(true);
    WinUpdate(gMDINotifier, _winupdactivate);
  end;


  RETURN true;
end;


//========================================================================
// Start
//              Startet den Nofitier mit angegebenen Parametern
//========================================================================
sub Start() : logic
local begin
  vHdl      : int;
  vFont     : font;
  vName     : alpha;
end;
begin

  if (Usr.NotifierYN=n) then RETURN true;

  if (gMdiNotifier=0) then begin
    gNotifierCounter # -1;

    vName # Lib_GuiCom:GetAlternativeName('Mdi.Notifier');
    if (StrFind(vName,'Notifier',0)>0) then begin
      gMdiNotifier # WinAddByName(gFrmMain, vName, _WinAddHidden);
      vHdl # Winsearch(gMdiNotifier,'rl.Messages');
      if (vHdl<>0) then Lib_GuiCom:ReCallList(vHDL);
    end
    else begin
//      gMdiNotifier # WinAddByName(gFrmMain, Lib_GuiCom:GetAlternativeName('Mdi.Cockpit'), _WinAddHidden);
      gMdiNotifier # WinAddByName(gFrmMain, vName, _WinAddHidden);
    end;

    // Usersettings holen
    Lib_GuiCom:RecallWindow(gMdiNotifier);
//    Lib_GuiCom:RecallList(vHDL);
    gMdiNotifier->WinUpdate(_WinUpdOn);
  end
  else begin
//        gMdiNotifier->WinFocusSet(true);
    WinUpdate(gMDINotifier, _winupdactivate);
  end;


  RETURN true;
end;


//========================================================================
// ResolveColor
//              Wertet eine Farbangabe aus
//========================================================================
sub ResolveColor(
  aCol  : alpha
) : alpha
local begin
  vColor   : alpha;
end;
begin

  // Sollte ein Farbwert in R,G,B übergeben werden,
  // ist dies dann schon korrekt
  if (Lib_Strings:Strings_Count(aCol,',') = 2) then
    vColor # aCol;

  // Liste der verfügbaren Farben (hier nur ein paar Beispiele)
  CASE (aCol) OF
    'rot'   : vColor # '255,0,0';
    'orange': vColor # '255,125,0';
    'gelb'  : vColor # '255,255,0';
    'gruen' : vColor # '0,255,0';
    'blau'  : vColor # '0,125,255';
  END;

  RETURN vColor;
end;


//=========================================================================
// NewEvent
//        Legt ein neues Event für den Benutzer an.
//=========================================================================
sub NewEvent (
  aUser       : alpha;
  aAkt        : alpha(200);
  aText       : alpha(1000);
  opt aAktNr  : int;
  opt aDatum  : date;
  opt aZeit   : time;
  opt aPrio   : word)
local begin
  Erx     : int;
  vBuf800 : handle;
end;
begin
//  if ( !Set.TimerYN ) then
//    RETURN;

//  AKTION                        AKTIONSNR
//  122>800/Prj/Pos   - Projekt   0
//  TAPI/100/Nummer   - Anruf
//  TAPI/102/Nummer   - Anruf
//  TAPI/110/Nummer   - Anruf
//  TAPI/999/Nummer   - Anruf
//  980               - Termin    Terminnr.

//debug(aint(Tem.A.Datei)+'   C:'+tem.a.code+'   '+Tem.A.key);
  // Erstelldatum festlegen
  if ( aDatum = 0.0.0 ) then begin
    aDatum # today;
    aZeit  # now;
  end;
//debugX('new event für '+aUser);
  // Event für User anlegen
  vBuf800 # RecBufCreate( 800 );
  vBuf800->Usr.Username # aUser;
  if ( RecRead( vBuf800, 1, 0 ) <= _rLocked ) and ( vBuf800->Usr.NotifierYN ) then begin
    RecBufClear( 989 );
    TeM.E.ID # Lib_Nummern:ReadNummer( 'Meldungen' );
    if ( TeM.E.ID != 0 ) then begin
      Lib_Nummern:SaveNummer();
      TeM.E.NeuYN     # true;
      TeM.E.User      # aUser;
      TeM.E.Datum     # aDatum;
      TeM.E.Zeit      # aZeit;
      TeM.E.Aktion    # StrCut(aAkt,1,32);
      TeM.E.Aktionsnr # aAktNr;
      TeM.E.Bemerkung # StrCut( aText, 1, 64 );
      "TeM.E.Priorität" # aPrio;
      erx # RekInsert(989, 0, 'AUTO' );
      
//debugx('newevent:'+Tem.E.Aktion+' '+aint(Tem.e.Aktionsnr));
    end;
  end;
  vBuf800->RecBufDestroy();
end;


//=========================================================================
// NewRequestID
//      beschafft Userweise eindeutige RequestID
//=========================================================================
sub NewRequestID() : bigint;
local begin
  vBig  : bigint;
end;
begin

  REPEAT
    vBig # cnvbd(today) / 10000; // von NANO auf 0,1 MILLI
    vBig # vBig + (cnvbt(Systime(_TimeSec | _TimeHSec | _TimeServer)) / 10000);

    RecBufClear(989);
    TeM.E.User      # gUsername;
    TeM.E.RequestID # vBig;
    if (RecRead(989,6,_recTest) <= _rMultikey) then begin
      Winsleep(1);
      CYCLE;
    end;
  UNTIL (1=1);

  RETURN vBig;
end;


//=========================================================================
//  WaitForRequest
//=========================================================================
sub WaitForRequest(aReqID : bigint)
local begin
  Erx : int;
end;
begin

  RecBufClear(989);
  TeM.E.User      # gUsername;
  TeM.E.RequestID # aReqID;
  REPEAT
    Erx # RecRead(989,6,_recTest);
    if (Erx>_rMultikey) then Winsleep(10);
  UNTIL (Erx<=_rMultikey);

end;


//=========================================================================
// NewInfo
//        Legt ein neues INFOEvent für den Benutzer an.
//=========================================================================
sub NewInfo (
  aUser       : alpha;
  aText       : alpha(1000);
  aText2      : alpha(1000);
  aReqID      : bigint) : logic
local begin
  vBuf800     : handle;
end;
begin

  // Event für User anlegen
  vBuf800 # RecBufCreate( 800 );
  vBuf800->Usr.Username # aUser;
  if ( RecRead( vBuf800, 1, 0 ) <= _rLocked ) and ( vBuf800->Usr.NotifierYN ) then begin

    RecBufClear( 989 );
    TeM.E.ID # Lib_Nummern:ReadNummer( 'Meldungen' );
    if ( TeM.E.ID != 0 ) then begin
      Lib_Nummern:SaveNummer();
      TeM.E.NeuYN     # true;
      TeM.E.User      # aUser;
      TeM.E.Datum     # today;
      TeM.E.Zeit      # now;
      TeM.E.Aktion    # 'INFO';
      TeM.E.Bemerkung     # StrCut( aText, 1, 64 );
      TeM.E.ErgebnisText  # StrCut( aText2, 1, 64 );
      TeM.E.RequestID # aReqID;
      RekInsert(989, 0, 'AUTO' );
    end;
  end;
  vBuf800->RecBufDestroy();

  RETURN true;
end;


//=========================================================================
// UpdateInfo
//        'Ändert ein INFOEvent
//=========================================================================
sub UpdateInfo (
  aUser       : alpha;
  aReqID      : bigint;
  aText2      : alpha(1000))
local begin
  Erx         : int;
  v989        : int;
  vBig        : int;
  vI          : int;
end;
begin

  // NEU??
  if (aReqID=0) then begin
    NewInfo(aUser, aText2, '', NewRequestID());
    RETURN;
  end;


  RecBufClear(989);
  TeM.E.User      # aUser;
  TeM.E.RequestID # aReqID;
  Erx # RecRead(989,6,0);
  if (Erx>_rMultikey) then begin
    NewInfo(aUser, 'Infomeldung #'+cnvab(aReqID)+' NICHT gefunden!', '', 0);
    RETURN;
  end;

  // INFO-Message updaten...
  REPEAT
    Erx # RecRead(989,1,_recLock);
    if (Erx<>_rok) then begin
      Winsleep(100);
    end;
    inc(vI);
  UNTIL (Erx=_rOK) or (vI>10);
  TeM.E.NotifiedYN    # false;
  TeM.E.ErgebnisText  # StrCut( aText2, 1, 64 );
  RekReplace(989, 0, 'AUTO' );

end;


//=========================================================================
// NewPrjNote
//        Legt eine neue Projektmeldung für den Benutzer an.
//=========================================================================
sub NewPrjNote ( aUser : alpha; aPrj : int; aPos : int; opt aDatum : date; opt aZeit : time )
local begin
  vBuf122 : handle;
  vBuf120 : handle;
  vA      : alpha;
end;
begin
  vBuf122 # RecBufCreate( 122 );
  vBuf122->Prj.P.Nummer   # aPrj;
  vBuf122->Prj.P.Position # aPos;

  if ( RecRead( vBuf122, 1, 0 ) <= _rLocked ) then begin
    vBuf120 # RecBufCreate( 120 );
    RecLink( vBuf120, vBuf122, 1, _recFirst );

//    NewEvent( aUser, '122>800/' + AInt( vBuf122->Prj.P.Nummer ) + '/' + AInt( vBuf122->Prj.P.Position ),
//      'Prj.' + AInt( vBuf122->Prj.P.Nummer ) + '/' + AInt( vBuf122->Prj.P.Position ) + ' ' + vBuf120->Prj.AdressStichwort + ': ' + vBuf122->Prj.P.Bezeichnung,
//      0, aDatum, aZeit );
    
    vA # AInt(vBuf122->Prj.P.Nummer)+'/'+AInt(vBuf122->Prj.P.Position);
    if (vBuf122->Prj.P.SubPosition>0) then
      vA # vA + '/'+aint(vBuf122->Prj.P.SubPosition);
    NewEvent( aUser, '122>800/'+ vA,
      '' + vA + ' ' + vBuf120->Prj.AdressStichwort + ': ' + vBuf122->Prj.P.Bezeichnung,
      0, aDatum, aZeit );


    vBuf120->RecBufDestroy();
  end;
  vBuf122->RecBufDestroy();
end;


//=========================================================================
//  Exists
//
//=========================================================================
sub Exists(
  aAkt    : alpha;
  aAktNr  : int;
  aUser   : alpha) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(989);
  TeM.E.Aktion    # aAkt;
  TeM.E.Aktionsnr # aAktNr;
  Erx # Recread(989,4,0);
  WHILE (Erx<=_rMultikey) and (TeM.E.Aktion=aAkt) and
    ((aAktNr=0) or (aAktNr=Tem.E.Aktionsnr)) do begin
    if (TeM.E.User=aUser) then RETURN true;
    Erx # Recread(989,4,_recNext);
  END;

  RETURN false;
end;


//=========================================================================
//  RemoveAllEvents
//
//=========================================================================
sub RemoveAllEvents(
  aAkt          : alpha;
  aAktNr        : int;
  opt aNotUser  : alpha;
);
local begin
  Erx : int;
end;
begin
/**
  if (aNotUser='') then begin
    REPEAT
      RecBufClear(989);
      TeM.E.Aktion # aAkt;
      Erx # Recread(989,4,0);
      if (Erx>_rMultikey) then RETURN;
//      RekDelete(989,_recUnlock,'AUTO');
      Erx # RecRead(989,1,_recLock);
      "TeM.E.LöschenYN" # y;
      Erx # Rekreplace(989,_recUnlock,'AUTO');
    UNTIL (1=2);
  end;
**/

  RecBufClear(989);
  TeM.E.Aktion    # aAkt;
  TeM.E.Aktionsnr # aAktNr;
  Erx # Recread(989,4,0);
  WHILE (Erx<=_rMultiKey) and (TeM.E.Aktion=aAkt) and
    ((aAktNr=0) or (aAktNr=Tem.E.Aktionsnr)) do begin

    if (TeM.E.User=aNotUser) then begin
      Erx # Recread(989,4,_recNext);
      CYCLE;
    end;

    if ("TeM.E.LöschenYN"=false) then begin
      Erx # RecRead(989,1,_recLock);
      "TeM.E.LöschenYN" # y;
      Erx # Rekreplace(989,_recUnlock,'AUTO');

//      Erx # Recread(989,4,0);
//      Erx # Recread(989,4,0);
//      end
//    else begin
//      Erx # Recread(989,4,_recNext);
    end;
    Erx # Recread(989,4,_recNext);
  END;


end;


//=========================================================================
//  RemoveOneEvent
//
//=========================================================================
sub RemoveOneEvent(
  aAkt          : alpha;
  aAktNr        : int;
  aUser         : alpha;
);
local begin
  Erx : int;
end;
begin
  RecBufClear(989);
  TeM.E.Aktion    # aAkt;
  TeM.E.Aktionsnr # aAktNr;
  Erx # Recread(989,4,0);
  WHILE (Erx<=_rMultiKey) and (TeM.E.Aktion=aAkt) and
    ((aAktNr=0) or (aAktNr=Tem.E.Aktionsnr)) do begin
    if (TeM.E.User=aUser) and ("TeM.E.LöschenYN"=false) then begin
      Erx # RecRead(989,1,_recLock);
      "TeM.E.LöschenYN" # y;
      Erx # Rekreplace(989,_recUnlock,'AUTO');
    end;
    Erx # Recread(989,4,_recNext);
  END;


end;


//=========================================================================
// Meldungsfenster
//=========================================================================

//=========================================================================
// EvtPosChanged
//        Passt die Meldungsliste an die geänderte Größe des Fensters an.
//=========================================================================
sub EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
local begin
  vRect : rect;
end
begin
  if ( aFlags & _winPosSized != 0 ) then begin
    vRect        # $rl.Messages->wpArea;
    vRect:right  # aRect:right - aRect:left - 8-8;
    vRect:bottom # aRect:bottom - aRect:top - 40;
    $rl.Messages->wpArea # vRect;
  end;

  RETURN true;
end;


//=========================================================================
// EvtLstDataInit
//        Formatiert die Ausgabe der Meldungen.
//=========================================================================
sub EvtLstDataInit ( aEvt : event; aID : int ) : logic
local begin
  vClmD   : handle;
  vClmT   : handle;
  vColor  : int;
  vDate   : date;
  vHdl    : handle;
end;
begin
  Gv.Int.01 # 174; // Delete Icon anzeigen = 3
  Gv.Int.02 # 163; // Delete Icon anzeigen = 3

  // Spaltenhintergrund
  if ( TeM.E.Datum = 0.0.0 ) then
    vColor # 0;
  else if ( Str_Token( TeM.E.Aktion, '/', 1 ) = '122>800' ) then begin // Projekte anders markieren
    vDate  # TeM.E.Datum;
    vDate->vmDayModify( 7 );

    if ( today <= vDate ) then
      vColor # RGB( 255, 96, 96 );
    else if ( TeM.E.Datum = today ) then
      vColor # _winColLightRed;
  end
  else if ( Str_Token( TeM.E.Aktion, '/', 1 ) = 'TAPI' ) then begin // Telefon anders markieren
    vHdl # Winsearch(aEvt:Obj, 'clmTeM.E.Bemerkung');
    if (vHdl<>0) then begin
      vHdl->wpClmColBkg         # _WinColLightcyan;
      vHdl->wpClmColFocusBkg    # _WinColLightcyan;
      vHdl->wpClmColFOcusOffBkg # _WinColLightcyan;
    end;
  end
  else if ( TeM.E.Datum < today ) or ( ( TeM.E.Datum = today ) and ( TeM.E.Zeit <= now ) ) then
    vColor # _winColLightRed;

  vClmD # WinSearch( aEvt:obj, 'clmTeM.E.Datum' );
  vClmT # WinSearch( aEvt:obj, 'clmTeM.E.Zeit' );
  if ( vColor != 0 ) then begin
    vClmD->wpClmColFocusBkg     # vColor;
    vClmD->wpClmColBkg          # vColor;
    vClmD->wpClmColFocusOffBkg  # vColor;
    vClmT->wpClmColFocusBkg     # vColor;
    vClmT->wpClmColBkg          # vColor;
    vClmT->wpClmColFocusOffBkg  # vColor;
  end
  else begin // Markierung entfernen
    vClmD->wpClmColFocusBkg     # Set.Col.RList.Cursor;
    vClmD->wpClmColBkg          # _WinColWhite;
    vClmD->wpClmColFocusOffBkg  # Set.Col.RList.CurOff;
    vClmT->wpClmColFocusBkg     # Set.Col.RList.Cursor;
    vClmT->wpClmColBkg          # _WinColWhite;
    vClmT->wpClmColFocusOffBkg  # Set.Col.RList.CurOff;
  end;

  if ("TeM.E.Priorität">0) then begin
    vHdl # Winsearch(aEvt:Obj, 'clmTeM.E.Bemerkung');
    if (vHdl<>0) then begin
      vHdl->wpClmColBkg         # _WinColLightYellow;
      vHdl->wpClmColFocusBkg    # _WinColLightYellow;
      vHdl->wpClmColFOcusOffBkg # _WinColLightYellow;
    end;

  end;

end;


//=========================================================================
// EvtMouseItem
//        Führt Aktion bei Doppelklick aus.
//=========================================================================
sub EvtMouseItem (
  aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aId       : int ) : logic
local begin
  vA      : alpha;
  vQ      : alpha;
  vHdl    : handle;
  vNew    : logic;
  vRecID  : int;
  vList   : handle;
end;
begin
  // nur Doppelklick akzeptieren
  if ( aButton & _winMouseLeft = 0 ) or ( aButton & _winMouseDouble = 0 ) then
    RETURN true;

  if ( aItem = 0 ) or ( aId = 0 ) then
    RETURN true;

  // Meldung löschen
  if ( aItem->wpName = 'clmGV.Int.01' ) then begin
    if ( RecRead( 989, 0, _recId, aId ) <= _rLocked ) then
      RekDelete( 989, 0, 'MAN' );
//    aEvt:obj->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect| _winLstRecEvtSkip );
    aEvt:obj->WinUpdate( _winUpdOn, _WinLstFromSelected | _winLstRecDoSelect| _winLstRecEvtSkip );
    RETURN true;
  end;

  // Meldung laden
  if ( RecRead( 989, 0, _recId, aId ) > _rLocked ) then
    RETURN true;

  // Projektposition?
  if (StrCut(TeM.E.Aktion, 1,7)='122>800') then begin

      Prj_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), cnvia(Str_Token(TeM.E.Aktion,'/',4)), y);

/*** in sub START
    // Fenster bereits offen??
    if (gMDIPrj<>0) then begin
      if (gMDIPrj->wpname<>'Prj.P.Verwaltung') then RETURN false;
      VarInstance(WindowBonus,cnvIA(gMDIPrj->wpcustom));
      if (Mode<>c_ModeList) and (Mode<>c_modeView) then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        RETURN false;
      end;
      vHdl # gZLList->wpDbSelection;
      if (w_SelName<>'') and (vHdl<>0) then begin
        gZLList->wpautoupdate # false;
        gZLList->wpdbselection # 0;
        SelClose(vHdl);
        SelDelete(gFile,w_selName);
      end;
    end;

    vA # Str_Token(TeM.E.Aktion,'/',2);
    Prj.Nummer # cnvia(vA);
    Erx # RecRead(120,1,0);
    if (Erx<=_rLocked) then begin
      Prj.P.Nummer # Prj.Nummer;
      vA # Str_Token(TeM.E.Aktion,'/',3);
      Prj.P.Position # cnvia(vA);
      Erx # RecRead(122,1,0);
      if (Erx<=_rLocked) then begin
        vRecID # RecInfo(122,_recID);

        if (gMDIPrj=0) then begin
          gMDIPrj # Lib_GuiCom:OpenMdi(gFrmMain, 'Prj.P.Verwaltung', _WinAddHidden);
          vNew # y;
        end;

        VarInstance(WindowBonus,cnvIA(gMDIPrj->wpcustom));
        w_Command   # 'REPOS';
        w_Cmd_Para  # aInt(vRecId);

        vList # gZLList;
        mode # c_modeBald+c_ModeView
        vHdl # Winsearch(gMDIPrj,'NB.Main');
        vQ # '';
        Lib_Sel:QInt( var vQ, '"Prj.P.Nummer"', '=', Prj.Nummer);
        Lib_Sel:QRecList(0,vQ);

        if (vNew) then begin
          gMDIPrj->WinUpdate(_WinUpdOn);
        end
        else begin
          vHdl->WinFocusSet(true);
          RecRead(122,0,_recId, vRecID);
          vList->Winupdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
          gMDIPrj->WinFocusSet(true);
        end;
      end;
    end;
***/
  end

  // Anruf?
  else if (StrCut(TeM.E.Aktion, 1,4)='TAPI') then begin
    if ( Rechte[Rgt_Adressen]=false) then RETURN false;
     // Eingehender Anruf
    vA # Str_Token( TeM.E.Aktion, '/', 2 );
    if ( vA = '' ) then RETURN true; // interner Anruf

    if ( vA = '999' ) then begin // unbekannte Nummer?
      if (Msg(99,'Nummer anrufen?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
        vA # Str_Token(TeM.E.Aktion, '/', 3 );
        Lib_Tapi:TapiDialNumber(vA);
        RETURN true;
      end;
      if (Msg(99,'Nummer in Zwischenablage kopieren?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
        vA # Str_Token(TeM.E.Aktion, '/', 3 );
        ClipboardWrite(vA);
        RETURN true;
      end;

    end
    else if ( vA = '100' ) then begin // Adr.Adressen
      if (Msg(99,'Nummer anrufen?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
        vA # Str_Token(TeM.E.Aktion, '/', 3 );
        Lib_Tapi:TapiDialNumber(vA);
        RETURN true;
      end;
      if (Msg(99,'Zur Adresse springen?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
        vA # Str_Token(TeM.E.Aktion, '/', 3 );
        Adr_Main:Start(Tem.E.Aktionsnr,0,y);
        RETURN true;
      end;

    end
    else if ( vA = '102' ) then begin // Adr.Ansprechpartner
      if (Msg(99,'Nummer anrufen?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
        vA # Str_Token(TeM.E.Aktion, '/', 3 );
        Lib_Tapi:TapiDialNumber(vA);
        RETURN true;
      end;
      if (Msg(99,'Zum Ansprechpartner springen?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
        vA # Str_Token(TeM.E.Aktion, '/', 3 );
        Adr_P_Main:Start(Tem.E.Aktionsnr,0,0,y);
        RETURN true;
      end;
    end;
  end

  // Termin?
  else if (StrCut(Tem.E.Aktion,1,3)='980') then begin

    TeM.Nummer # CnvIA( StrCut( TeM.E.Aktion, 5, 20 ) );
    if (Tem.Nummer=0) then Tem.Nummer # Tem.E.Aktionsnr;  // 21.02.2014
    if ( RecRead( 980, 1, 0 ) > _rLocked ) then
      RETURN false;

    if ( gMdiPara = 0 ) then begin
      gMdiPara # Lib_GuiCom:OpenMdi( gFrmMain, 'TeM.Verwaltung', _winAddHidden );
      VarInstance(WindowBonus,cnvIA(gMDIpara->wpcustom));
      Mode       # c_ModeBald + c_ModeView;
      w_Command  # 'REPOS';
      w_Cmd_Para # AInt( RecInfo( 980, _recId ) );
      gMdiPara->WinUpdate( _winUpdOn );
      gMdiPara->WinFocusSet( true );
/***
        if (TeM.Wof.Datei=400) then begin
          if Rechte[Rgt_Auftrag] then begin
            if (gMdiAuf = 0) then begin

if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then
  RecLink(401,400,9,_recFirst);

              //gFrmMain->wpDisabled # true;
              gMdiAuf # Lib_GuiCom:OpenMdi(gFrmMain, 'Auf.P.Verwaltung', _WinAddHidden);

//        Mode       # c_ModeBald + c_ModeView;
        w_Command  # 'REPOS';
        w_Cmd_Para # AInt( RecInfo( 401, _recId ) );

              gMdiAuf->WinUpdate(_WinUpdOn);
              //gFrmMain->wpDisabled # false;
              $NB.Main->WinFocusSet(true);
            end
            else begin
              Lib_guiCom:ReOpenMDI(gMDIAuf);
            end;
          end;

        end;
***/
    end
    else begin
      if (gMDIPara->wpname=Lib_GuiCom:GetAlternativeName('TeM.Verwaltung')) then
        Lib_GuiCom:RePos(var gMDIPara, 'TeM.Verwaltung', RecInfo(980,_recId),y);
      Lib_GuiCom:ReOpenMDI( gMdiPara );
    end;

    RETURN true;
  end

  else begin

  if (TeM.E.Aktion='100') then begin
    Adr_Main:Start(TeM.E.Aktionsnr, 0, y);
  end;

  end;

  RETURN true;
end;


//=========================================================================
// EvtMenuCommand
//        Führt Aktion aus Kontextmenü aus.
//=========================================================================
sub EvtMenuCommand ( aEvt : event; aMenuItem : int; ) : logic
local begin
  Erx   : int;
  vTree : handle;
  vItem : handle;
end;
begin
  case ( aMenuItem->wpName ) of
    // Doppelte Einträge entfernen
    'Mnu.Ktx.RemoveDoubles' : begin
      vTree # CteOpen( _cteTreeCI );

      FOR  Erx # RecLink( 989, 999, 6, _recLast );
      LOOP Erx # RecLink( 989, 999, 6, _recPrev );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        vItem # CteOpen( _cteItem );
        if ( vItem = 0 ) then
          BREAK;

        vItem->spName # TeM.E.Aktion + '|' + TeM.E.Bemerkung;
        vItem->spID   # RecInfo( 989, _recId );

        if ( !vTree->CteInsert( vItem ) ) then begin
          vItem->CteClose();
          RekDelete( 989, 0, 'MAN' );
        end;
      END;

      Sort_KillList( vTree );
      aEvt:Obj->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect | _winLstRecEvtSkip );
    end;

    // Alle Einträge entfernen
    'Mnu.Ktx.RemoveAll' : begin
      if(Msg(000001, '', 0, 0, 2) = _WinIdNo) then
        RETURN false;

      FOR  Erx # RecLink( 989, 999, 6, _recFirst );
      LOOP Erx # RecLink( 989, 999, 6, _recFirst );
      WHILE ( Erx = _rOk ) DO BEGIN
        RekDelete( 989, 0, 'MAN' );
      END;

      aEvt:Obj->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect | _winLstRecEvtSkip );
    end;

    // Alte Projekte entfernen
    'Mnu.Ktx.RemoveOldProjects' : begin
      FOR  Erx # RecLink( 989, 999, 6, _recLast );
      LOOP Erx # RecLink( 989, 999, 6, _recPrev );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        if ( Str_Token( TeM.E.Aktion, '/', 1 ) != '122>800' ) then
          CYCLE;

        Prj.P.Nummer   # CnvIA( Str_Token( TeM.E.Aktion, '/', 2 ) );
        Prj.P.Position # CnvIA( Str_Token( TeM.E.Aktion, '/', 3 ) );
        if ( RecRead( 122, 1, 0 ) > _rLocked ) then
          CYCLE;

        if (!( Prj.P.WiedervorlUser =* '*' + gUserName + '*') or ("Prj.P.Lösch.Datum" <> 00.00.0000)) then
          RekDelete( 989, 0, 'MAN' );
      END;

      aEvt:Obj->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect | _winLstRecEvtSkip );
    end;
  end;
end;


//========================================================================
//========================================================================
sub NewTermin(
  aTyp        : alpha;
  aName       : alpha(250);
  aText       : alpha(250);
  aKeinPlan   : logic;
  opt aVonDT  : caltime;
  opt aBisDT  : caltime;
) : logic;
local begin
  vDate : CalTime;
  vTmp  : int;
end;
begin

  vDate->vpdate # today;
  vDate->vptime # now;
  RecBufClear(980);
  TeM.Nummer # Lib_Nummern:ReadNummer('Termin');    // Nummer lesen
  if (TeM.Nummer=0) then RETURN false;
  Lib_Nummern:SaveNummer();                         // Nummernkreis aktuallisiern

  TeM.Start.Von.Datum   # vDate->vpdate;
  TeM.Start.Von.Zeit    # vDate->vpTime;

  if (cnvbc(aVonDT)>0\b) then begin
    TeM.Start.Von.Datum # DateMake(aVonDT->vpday, aVonDT->vpmonth, aVonDT->vpyear-1900);
    TeM.Start.Von.Zeit  # TimeMake(aVonDT->vpHours, aVonDT->vpMinutes, aVonDT->vpseconds, aVonDT->vpMilliseconds / 10);
  end;

  TeM.Start.Bis.Datum   # TeM.Start.Von.Datum;
  TeM.Start.Bis.Zeit    # TeM.Start.Von.Zeit;

  TeM.Ende.Von.Datum    # vDate->vpdate;
  TeM.Ende.Von.Zeit     # vDate->vpTime;

  if (cnvbc(aBisDT)>0\b) then begin
    TeM.Ende.Von.Datum  # DateMake(aBisDT->vpday, aBisDT->vpmonth, aBisDT->vpyear-1900);
    TeM.Ende.Von.Zeit   # TimeMake(aBisDT->vpHours, aBisDT->vpMinutes, aBisDT->vpseconds, aBisDT->vpMilliseconds / 10);
  end;

  TeM.Ende.Bis.Datum    # TeM.Ende.Von.Datum;
  TeM.Ende.Bis.Zeit     # TeM.Ende.Von.Zeit;


  TeM.Anlage.Datum      # Today;
  TeM.Anlage.Zeit       # Now;
  TeM.Anlage.User       # gUserName;
  TeM.Typ               # aTyp;
  TeM.Bezeichnung       # StrCut(aName,1,64);
  TeM.Bemerkung         # StrCut(aText,1,192);
  TeM.SichtbarPlanerYN  # (aKeinPLan=false);
  TeM.PrivatYN          # n;
  TeM.Erledigt.User     # '';

  // Dauer errechnen
  TeM.Dauer # 0.0;
  if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
    vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp);
    vTmp # (CnvID(TeM.Ende.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Ende.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp) - TeM.Dauer;
  end;

  if (RekInsert(980,0,'AUTO')<>_rOK) then RETURN false;
  RETURN true;
end;

//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vFormat : int;
  vTxt    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
	RETURN (true);
end;


//=========================================================================
//=========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vPref   : alpha;
  vA      : alpha;
  vBem    : alpha(192);
  vDatei  : int;
  vID     : int;
  vDetail : logic;
  vBuf    : int;
  vKey    : alpha;
end;
begin
  if (aEffect | _WinDropEffectCopy=0) or (aEffect | _WinDropEffectMove=0) then RETURN false;

  if (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpcustom<>'') then begin
    vA      # StrFmt(aDataObject->wpName,30,_strend);
    vDatei  # Cnvia(StrCut(vA,1,3));
    vID     # Cnvia(StrCut(vA,5,15));
    vKey    # StrCut(vA,17,48);
    Lib_Workbench:CreateName(vDatei, var vPref, var vA);

//if (RecInfo(989,_reccount)>=5) then RecDeleteAll(989);
//    RecBufClear(989);
//    TeM.E.User      # gUsername;
//    TeM.E.Datum     # today;
//    TeM.E.Zeit      # now;
//    TeM.E.Aktion    # '';
//    TeM.E.Bemerkung # vA;

//dlg_Standard:Standard('Info',var vA);
    if (Dlg_Notifier:Dlg_Drop(var vA, var vDetail)=false) then RETURN false;

    if (vDetail) then begin

      if (NewTermin('AFG', vA, vBem, true)=false) then RETURN false;

      // User verankern
      Usr_data:RecReadThisUser();
      RecBufClear(981);
      TeM.A.Nummer      # TeM.Nummer;
      TeM.A.Code        # gUsername;
      TeM.A.Datei       # 800;
      TeM.A.Start.Datum # today;
      TeM.A.Start.Zeit  # now;
      TeM.A.lfdNr       # 1;
      TeM.A.EventErzeugtYN # y;
//      REPEAT
        //TeM_A_Data:Insert(0,'AUTO');
//        if (Erx<>_rOK) then inc(TeM.A.lfdNr);
//      UNTIl (Erx=_rOK);
      TeM_A_Data:Anker(800, 'AUTO', true);


      // Datensatz verankern
      vBuf # RekSave(vDatei);
      Lib_rec:ReadbyKey(vDatei, vKey);
      RecBufClear(981);
      TeM.A.Nummer      # TeM.Nummer;
//      TeM.A.ID1         # Adr.Nummer;
      TeM.A.Datei       # vDatei;
      TeM.A.Start.Datum # today;
      TeM.A.Start.Zeit  # now;
      TeM.A.lfdNr       # 1;
      TeM.A.EventErzeugtYN # y;
//      REPEAT
//        TeM_A_Data:Insert(0,'AUTO');
//        if (Erx<>_rOK) then inc(TeM.A.lfdNr);
//      UNTIl (Erx=_rOK);
      TeM_A_Data:Anker(vDatei, 'AUTO', true);

      vID # RecInfo(980,_recid);
      RekRestore(vBuf);

      NewEvent(gUsername, '980/'+AInt(TeM.Nummer), vA, vID ,today, now, 0);
    end
    else begin
      NewEvent(gUsername, aint(vDatei), vA, vID ,today, now, 0);
    end;

  end;

//todo('copy');
  RETURN(true);
end;


//=========================================================================
//=========================================================================