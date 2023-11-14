@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_Notifier
//                    OHNE E_R_G
//  Info
//
//
//  21.11.2013  AI  Erstellung der Prozedur
//
//
//  Subprozeduren
//    SUB Dlg_Drop(var aText : alpha; var aDetail : logic) : logic;
//
//========================================================================
@I:Def_Global

sub EvtPosChanged
(
  aEvt                 : event;    // Ereignis
  aRect                : rect;     // Größe des Fensters
  aClientSize          : point;    // Größe des Client-Bereichs
  aFlags               : int;      // Aktion
)
: logic;
local begin
  vRect : rect;
end;
begin

vrect # gMdiNotifier->wpArea;
vRect:left # (aRect:right + 5);
gMdiNotifier->wparea # vRect;

  return(true);
end;


//========================================================================
// Dlg_Drop
//
//========================================================================
sub Dlg_Drop(
  var aText     : alpha;
  var aDetail   : logic) : logic;
local begin
  vID     : int;
  vPrefix : alpha;
  vMDI    : int;
  vHdl    : int;
  vHdl2   : int;
end;
begin
  vPrefix # gPrefix;

  vMDI # gMDI;
  if (gMDI=0) then vMDI # gFrmMain;
  if (gMDI=gMDINOtifier) or (gMDI=gMdiWorkbench) or (gMDI=gMdiMenu) then vMDI # gFrmMain;

  vHdl  # WinOpen('Dlg.Notifier.Drop',_WinOpenDialog)
  vHdl2 # Winsearch(vHdl, 'edText');
  vHdl2->wpcaption # aText;
  vHdl2 # Winsearch(vHdl, 'cbDetail');
  if (aDetail) then vHdl2->wpCheckState # _WinStateChkChecked;

  // Dialog starten
  vID     # vHdl->Windialogrun(0,vMDI);
  If (vId = _WinIdOk) then begin
    vHdl2 # Winsearch(vHdl, 'edText');
    aText # vHdl2->wpcaption;
    vHdl2 # Winsearch(vHdl, 'cbDetail');
    aDetail # vHdl2->wpCheckState=_WinStateChkChecked;
    vHdl->winclose();
    RETURN true;
  end;

  aText   # '';
  aDetail # false;
  vHdl->winclose();
  RETURN false;
end;


//=========================================================================
//=========================================================================