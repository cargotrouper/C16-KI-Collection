@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_Dispo_Main
//                  OHNE E_R_G
//  Info
//
//
//  05.03.2015  AH  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB EvtInit ( aEvt : event ) : logic
//    SUB RecDel();
//    SUB RefreshIfm ( opt aName : alpha; opt aChanged : logic )
//    SUB EvtFocusInit ( aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm ( aEvt : event; aFocusObject : int) : logic
//    SUB EvtMenuCommand ( aEvt : event; aMenuItem : int ) : logic
//    SUB RefreshMode ( opt aNoRefresh : logic )
//    SUB EvtLstDataInit
//    SUB EvtLstSelect
//    SUB EvtClose
//    SUB EvtClicked
//    SUB JumpTo(aName : alpha; aBuf : int);
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle          : 'Dispoliste'
  cMenuName       : 'Std.Bearbeiten'
  cPrefix         : 'Art_Dispo'
  cZList          : $DL.Dispoliste
end;


//========================================================================
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
  vHdl      : int;
  vPicH     : int;
end
begin

  vPicH # 200;

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  //Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

  if (aFlags & _WinPosSized != 0) then begin
    if (gZLList<>0) then vHdl # gZLList;
    else if (gDataList<>0) then vHdl # gDataList
    else RETURN true;

    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28 - w_QBHeight - vPicH;
    vHdl->wparea # vRect;


    vHdl # $Picture1;
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:top       # aRect:bottom-aRect:Top-28 - w_QBHeight - vPicH + 5;
    vRect:bottom    # aRect:bottom-aRect:Top-28 - w_QBHeight;
    vHdl->wparea # vRect;
  end;

	RETURN (true);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit (
  aEvt      : event;
): logic
local begin
  vRect : rect;
  vPo   : point;
end;
begin
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # 0;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gDataList # cZList;
  gKey      # 0;

  App_Main:EvtInit(aEvt);
  Mode # c_modeList;
  
  EvtPosChanged(aEvt, vRect, vPo, _WinPosSized);

end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  vHdl  : int;
  vID   : int;
end;
begin
  RETURN;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm (
  opt aName     : alpha;
  opt aChanged  : logic)
begin
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt          : event;
  aFocusObject  : int;
) : logic
begin
  RETURN true;
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt          : event;
  aFocusObject  : int;
) : logic
begin
  RETURN true;
end;


//========================================================================
//  EvtMenuCommand
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtMenuCommand (
  aEvt            : event;
  aMenuItem       : int;
) : logic
begin
  RETURN true;
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode (
  opt aNoRefresh : logic;
)
local begin
  vHdl           : int;
end
begin
  gMenu # gFrmMain->WinInfo( _winMenu );

  // Buttons und Menüs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch( 'Mark' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # false;//dumbo true;

  vHdl # gMdi->WinSearch( 'Search' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;
end;


//========================================================================
// EvtClose
//              Schliessen eines Fensters
//========================================================================
sub EvtClose (
  aEvt            : event;
) : logic
local begin
  vI          : int;
  vAnz        : int;
  v703        : int;
end;
begin
  RETURN true;
end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName     : alpha;
  aBuf      : int);
local begin
  vBuf      : int;
  vColCust  : int;
  vA        : alpha;
  vTyp      : int;
  vRecId    : int;
end;
begin

  GDataList->wpCurrentInt # aBuf;
  
  if (aName='CLMVORGANG') then begin
    vColCust # Lib_GuiCom2:FindColumn(gDataList, 'ClmCustom');
    gDataList->WinLstCellGet(vA, vColCust, aBuf);
    vTyp    # cnvia(Str_token(vA,'|',1));
    vRecId  # cnvia(Str_token(vA,'|',2));
    case vTyp of

      200 : begin   // Materialkarte
      end;

      203 : begin   // Materialreservierung
      end;

      250 : begin   // Artikel
      end;

      252 : begin   // Artikel-Charge
      end;

      1401,401 : begin   // Auftrag
        RecRead(401,0,0,vRecID);
        Auf_P_Main:Start(0, Auf.P.Nummer,Auf.P.Position ,y);
      end;

      404 : begin   // Auftragsaktion
      end;
      1404 : begin   // Auftragsaktion
      end;

      409 : begin   // Auftragsstückliste
      end;

      501 : begin   // Bestellung
        RecRead(501,0,0,vRecID);
        Ein_P_Main:Start(0, Ein.P.Nummer,Ein.P.Position ,y);
      end;

      701 : begin   // BAG INPUT
        RecRead(701,0,0,vRecID);
        BA1_Main:Start(0, BAG.IO.Nummer,y);
      end;

      1701 : begin   // ArtPRD (Output)
        RecRead(701,0,0,vRecID);
        BA1_Main:Start(0, BAG.IO.Nummer,y);
      end;

      2701 : begin   // VSB (Output)
        RecRead(701,0,0,vRecID);
        BA1_Main:Start(0, BAG.IO.Nummer,y);
      end
    end;
    
  end;

end;


//========================================================================