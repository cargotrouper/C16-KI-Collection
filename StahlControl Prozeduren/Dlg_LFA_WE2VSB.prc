@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_LFA_WE2VSB
//                    OHNE E_R_G
//  Info
//
//
//  21.02.2011  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//
//  Subprozeduren
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB EvtClose(aEvt : event) : logic
//
//    SUB Start() : int;
//
//========================================================================
@I:Def_Global

LOCAL begin
  vDialog : alpha;
  vNoMDI  : logic;
  vFrage  : alpha;
  vText   : alpha;
  vKW     : word;
  vJahr   : word;

  vDatum1 : date;
  vDatum2 : date;

  vZahl1  : int;
  vZahl2  : int;
  vMenge  : float;

  vZeit   : Time;

end;


//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
	aEvt         : event;    // Ereignis
	aMenuItem    : int       // Auslösender Menüpunkt / Toolbar-Button
) : logic
local begin
  vX  : float;
  vI  : int;
end;
begin
	RETURN true;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vTmp  : int;
end;
begin

  if (aEvt:Obj->Wininfo(_WinType)=_WinTypeCheckbox) then
     aEvt:Obj->wpColBkg # _WinColCyan;
  else
    aEvt:Obj->wpColFocusBkg # ColFocus;
end;


//========================================================================
//  EvtFocusTerm
//            Fokus von Objekt wegnehmen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // nachfolgendes Objekt
) : logic
begin
  aEvt:Obj->wpColBkg # _WinColParent;
  RETURN true;
end;


//========================================================================
// EvtClicked
//
//========================================================================
Sub EvtClicked(
  aEvt   : event;
) : logic
local begin
  vHdl : int;
  vWin : int;
end;
begin

  vWin # aEvt:Obj->WinInfo(_WinFrame);

  case (aEvt:Obj->wpName) of
    'OK' : begin
      vText # $edText->wpCaption;
    end; //case
  end;

  RETURN true;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  RETURN true;
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  vText # $edText->wpCaption;

  RETURN true;
end;


//========================================================================
// Start
//
//========================================================================
sub Start() : int;
local begin
  Erx     : int;
  vID     : int;
  vPrefix : alpha;
  vHdl    : int;
  vTmp    : int;
  vA      : alpha(300);
end;
begin
  vPrefix # gPrefix;

  vHDL # WinOpen('Dlg.LFA.WE2VSB',_WinOpenDialog);

  vTmp # Winsearch(vHDL,'cb.KillRest');
  vA # vTmp->wpcaption;
  vA # Str_ReplaceAll(vA,'%1%',anum(Mat.Bestand.Gew, Set.Stellen.Gewicht));
  vTmp->wpcaption # vA;

  // Dialog starten
  vID # vHDL->Windialogrun(0,gMDI);//gFrmMain);
//  gPrefix # vPrefix;

  If (vId = _WinIdNo) then begin
    vHDL->winclose();
    RETURN 0;
  end;

  vID # 1;
  Erx     # vHDL->Winsearch('cb.Ersetzen');
  if (Erx<>0) then
    if (Erx->wpCheckState=_WinStateChkchecked) then vID # vID + 2;
  Erx     # vHDL->Winsearch('cb.KillRest');
  if (Erx<>0) then
    if (Erx->wpCheckState=_WinStateChkchecked) then vID # vID + 4;
  Erx     # vHDL->Winsearch('cb.FM');
  if (Erx<>0) then
    if (Erx->wpCheckState=_WinStateChkchecked) then vID # vID + 8;

  vHDL->winclose();
  RETURN vID;
end;


//=========================================================================
//=========================================================================