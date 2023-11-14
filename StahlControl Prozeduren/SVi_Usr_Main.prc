@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVi_Usr_Main
//                OHNE E_R_G
//  Info    Verwaltet die Auswahl der Benutzer für einen Service
//
//
//  13.09.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB Starten(aNr : int)
//    SUB Auswahl(aBereich : alpha)
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB evtlstselect(aevt : event; aRecId : int) : logic
//    SUB EvtLstRecControl(aEvt : event; aRecID : int) : logic
//========================================================================
@I:Def_global

LOCAL begin
end;

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  gTitle  # 'User';
  gPrefix # 'SVi';
  gFrmMain->wpMenuname # 'SVi.User';
  gZLList # 0;
  Call('App_Main:EvtMdiActivate',aEvt);
end;



//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  Mode # c_ModeCancel;
  RETURN APP_Main:EvtClose(aEvt);
end;


//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;        // Tastaturcode
  aID                   : int;        // RecId
)
local begin
  vHdl : int;
end;
begin
  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    vHdl # $SVi.Usertyp;
    if (vHdl<>0) then vHdl->Winclose();
  end;
end;


//========================================================================
//  EvtMouseItem
//                Mausklick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin
  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;

    gTmp # $SVi.Usertyp;
    if (gTmp<>0) then gTmp->Winclose();
  end;

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl  : int;
  vHdl2 : int;
end;
begin

  vHdl # $SVi.Usertyp;
  if (vHdl<>0) then WinSearchPath(vHDL);

  case (aEvt:Obj->wpName) of
    'Bt.OK' : begin
      vHdl # $SVi.Usertyp->Winsearch('DL.Typ');
      gSelected # vHdl->wpCurrentInt;
      vHdl # $SVi.Usertyp;
      if (vHdl<>0) then vHdl->winClose();
    end;

    'Bt.Abbruch' : begin
      gSelected # 0;
      vHdl # $SVi.Usertyp;
      if (vHdl<>0) then vHdl->winClose();
    end;

  end;

  RETURN true;
end;





//========================================================================
//========================================================================
//========================================================================