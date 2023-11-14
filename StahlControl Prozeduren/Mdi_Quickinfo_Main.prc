@A+
//===== Business-Control =================================================
//
//  Prozedur    Mdi_Quickinfo_Main
//                  OHNE E_R_G
//  Info        Routinen für die Quickinfo anzeige
//
//
//  26.09.2012  ST  Erstellung der Prozedur
//  10.01.2013  ST  Erweiterung um Einfärbung summierbare Felder
//
//  Subprozeduren
//    SUB EvtInit(aEvt: event; ): logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect; aClientSize  : point; aFlags : int ) : logic
//    SUB EvtFocusInit (   aEvt: event; aFocusObject: int) : logic
//    SUB EvtFocusTerm (aEvt : event; aFocusObj : int
//    SUB EvtMenuCommand(  aEvt      : event;  aMenuItem : handle;) : logic
//    SUB EvtTerm(aEvt : event; ): logic
//
//========================================================================
@I:Def_Global

define begin
  cMenuName : 'Mdi.Quickinfo';
  cPrefix   :  'Mdi_QuickInfo';
end;

LOCAL begin
  d_X         : int;
  d_text      : int;
  d_frame     : int;
  d_Button    : int;
  d_MenuItem  : int;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gSelected # 0;

  App_Main:EvtInit(aEvt);

  WinSearchPath(aEvt:Obj);
end;


//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl : int;

  tObj : int;
end;
begin

  gZLList # 0;
  vHdl # w_lastfocus;
  Call('App_Main:EvtMdiActivate',aEvt);

end;



//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
end
begin
  if (aFlags & _WinPosSized != 0) and ($DLRamBaum<>0) then begin
    vRect           # $DLRamBaum->wpArea;
    vRect:right     # aRect:right-aRect:left-25;
    vRect:bottom    # aRect:bottom-aRect:Top-45;
    $DLRamBaum->wparea # vRect;
  end;

	RETURN (true);
end;



//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  RETURN true;
end;


//========================================================================
//  EvtFocusTerm
//                Fokus wechselt hier weg
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObj             : int           // nächstes Objekt
) : logic
local begin
  vHdl :int;
end;
begin

  RETURN true;
end;



//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vParent : int;
  vName   : alpha;
  vTmp    : int;
end;
begin

   if (gFrmMain <> $AppFrameFM) then   // Beim Appframe FM wird kein Tree geöffnet
     if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
       RETURN false;


  // Parentfenster koennen nicht geschlossen werden
  if (w_Child<>0) then RETURN false;

  // Sortierung nicht bei "Auswahl" merken !!!
  //Erx # Lib_GuiCom:FindWindowRelation(gMdi);

  gFile   # 0;
  gPrefix # '';
  gZLList # 0;
/*** ???
  // Wenn Unterfenster dann Parent aktivieren
  vParent # Lib_GuiCom:FindParentWindow(aEvt:Obj);
  if (vParent<>0) then begin
    Lib_GuiCom:ChangeChild(aEvt:Obj);
    vParent->wpdisabled # false;
    vParent->wpCustom # Mode; //c_ModeView;
    vParent->WinUpdate(_WinUpdActivate);
    gMdi # vParent;
    App_Main:RefreshMode();
  end;
****/
  // Elternbeziehung aufheben?
  if (w_Parent<>0) then begin
    vTmp # VarInfo(Windowbonus);
    VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
    w_Child # 0;
    if (gZLList<>0) then gZLList->wpdisabled # false;
    VarInstance(WindowBonus,vTmp);
    w_Parent->wpdisabled # n;
    w_Parent->WinUpdate(_WinUpdActivate);
  end;

  RETURN true;
end;


//=========================================================================
// EvtMenuCommand
//
//=========================================================================
sub EvtMenuCommand(
  aEvt      : event;
  aMenuItem : handle;
) : logic
local begin
  vSelected : int;
  vRecId    : int;
  vFile     : int;
  vName     : alpha;
  vPref     : alpha;
end;
begin

  // Kontextmenüauswertung
  case (aMenuItem->wpName) of

    'Mnu.Ktx.Workbench' : begin

      vSelected # $DLRamBaum->wpCurrentInt;
      if (vSelected <= 0) then
        RETURN false;

      $DLRamBaum->WinLstCellGet(vRecId, 1,vSelected);
      $DLRamBaum->WinLstCellGet(vFile,  2,vSelected);

      RecRead(vFile, 0, 0, vRecId); // Datensatz holen

      Lib_Workbench:CreateName(vFile, var vPref, var vName);
      if (vName<>'') then begin
        vName # vPref + ':'+vName;
        if (Lib_Workbench:Insert(vName, vFile, vRecId) = false) then
          todo('Hat nicht geklappt');
      end;
    end;


    'Grp.Cancel' : begin
      gSelected # 0;
      gMDI->Winclose();
    end;

  end;

  RETURN true;
end;


//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTermProc : alpha;
  vHdl      : int;
end;
begin
  if (aEvt:obj->wpcustom<>'') then VarInstance(WindowBonus,cnvIA(aEvt:Obj->wpcustom));

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    if (w_parent<>0) then begin
      WinSearchPath(w_Parent);
      VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    end;
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
  end;

  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  vCol : int;

  vCell : int;
  vEven : logic;
  vFixed : int;
end;
begin
  if (aRecId <> CnvIa($DLRamBaum->wpCustom)) then
    return;

  //vCol # RGB(255,255,255);
  vCol # Set.Col.RList.Deletd;


  FOR  vCell # $DLRamBaum->WinInfo( _winFirst, 0, _winTypeListColumn );
  LOOP vCell # vCell->WinInfo( _winNext, 0, _winTypeListColumn );
  WHILE ( vCell != 0 ) DO BEGIN
    vCell->wpClmColBkg         # vCol;
    vCell->wpClmColFocusBkg    # vCol;
    vCell->wpClmColFocusOffBkg # vCol;
  END;


end;


//========================================================================