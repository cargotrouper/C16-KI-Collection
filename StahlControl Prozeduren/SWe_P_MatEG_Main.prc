@A+
//==== Business-Control ==================================================
//
//  Prozedur    SWe_P_MatEG_Main
//                OHNE E_R_G
//  Info
//
//
//  06.01.2011  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit ( aEvt : event ) : logic
//    SUB RecDel();
//    SUB RefreshIfm ( opt aName : alpha; opt aChanged : logic )
//    SUB EvtFocusInit ( aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm ( aEvt : event; aFocusObject : int) : logic
//    SUB EvtMenuCommand ( aEvt : event; aMenuItem : int ) : logic
//    SUB RefreshMode ( opt aNoRefresh : logic )
//    SUB EvtLstDataInit ( aEvt : event; aRecId : int )
//    SUB EvtLstSelect ( aEvt : event; aRecID : int ) : logic
//    SUB EvtClose ( aEvt : event ) : logic
//    SUB EvtClicked ( aEvt : event ) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle          : 'Einzelgewichte'
  cMenuName       : 'Std.DL.Bearbeiten'
//  cMenuName : 'Std.Bearbeiten'
  cPrefix         : 'SWe_P_MatEG'
  cVerwiegungsart : 1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit (
  aEvt      : event;
): logic
begin
  gTitle    # Translate( cTitle );
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  Mode      # c_modeEdList;
  App_Main:EvtInit( aEvt );
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

  vHdl # Winsearch(gMDI, 'DL.List');
  if (vHdl=0) then RETURN;
  if (vHdl->wpCurrentInt=0) then RETURN

  vHdl->WinLstDatLineRemove( _WinLstDatLineCurrent );
  vHdl->WinUpdate( _winUpdOn, _winLstPosTop );
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm (
  opt aName     : alpha;
  opt aChanged  : logic;
)
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
  if(aMenuItem->wpName='Mnu.DL.Delete') then RecDel();

  RETURN Lib_Datalist:EvtMenuCommand( aEvt, aMenuItem );
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
  vHdl # gMdi->WinSearch( 'Mark' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch( 'Search' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged (
	aEvt             : event;
	aRect            : rect;
	aClientSize      : point;
	aFlags           : int;
) : logic
local begin
  vRect     : rect;
end
begin
  if ( aFlags & _winPosSized != 0 ) then begin
    vRect            # $DL.List->wpArea;
    vRect:right      # aRect:right  - aRect:left - 4;
    vRect:bottom     # aRect:bottom - aRect:top  - 28;
    $DL.List->wpArea # vRect;
  end;
  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit (
  aEvt            : event;
  aId             : int;
) : logic
local begin
  vOk             : logic;
  vEinsatzmatNr   : int;
  vCoilNr         : alpha;
end;
begin
// Fehler ROT machen
//  aEvt:obj->WinLstCellGet( vOk, 10, aId );
//  if ( vOk = true ) then
//    Lib_GuiCom:ZLColorLine( aEvt:obj, _winColLightRed );
end;


//========================================================================
//  EvtLstLineEdited
//              Sonderfunktion der Lib_Datalist
//========================================================================
sub EvtLstLineEdited (
  aDataList       : int;
  aColumn         : int;
  aRow            : int;
)
local begin
  vNetto            : float;
  vBrutto           : float;
  vCoil             : alpha;
end;
begin
  aDataList->WinLstCellGet( vNetto,        1, aRow );
  aDataList->WinLstCellGet( vBrutto,       2, aRow );
  aDataList->WinLstCellGet( vCoil,         3, aRow );
  if (vNetto=0.0) then vNetto # vBrutto;
  if (vBrutto=0.0) then vBrutto # vNetto;
  if (vCoil='') then vCoil # SWe.P.Coilnummer;
  aDataList->WinLstCellSet( vNetto,    1, aRow );
  aDataList->WinLstCellSet( vBrutto,   2, aRow );
  aDataList->WinLstCellSet( vCoil,     3, aRow );
  // DataList neu aufbauen
  aDataList->WinUpdate( _winUpdOn, _winLstPosTop );
end;


//========================================================================
// EvtClose
//              Schliessen eines Fensters
//========================================================================
sub EvtClose (
  aEvt            : event;
) : logic
local begin
  Erx         : int;
  vOK         : logic;
  vI          : int;
  vLfd        : int;
  vNr         : int;
  vEinzelStk  : int;
  vBuf622     : int;
  vBuf621     : int;
end;
begin

  vEinzelSTK # WinLstDatLineInfo($DL.List, _WinLstDatInfoCount);

  // kein Einträge?
  if (vEinzelStk = 0) then RETURN true;

  if ("SWe.P.Stückzahl"<>vEinzelStk) then begin
    Erx # Msg(506015,aint(vEinzelStk)+'|'+aInt("SWe.P.Stückzahl"),_WinIcoWarning, _WinDialogYesNoCancel,2);
    if (Erx=_WinIdNo) then RETURN false;
    if (Erx=_WinIdCancel) then RETURN true;
  end
  else begin
    Erx # Msg(506016,aint(vEinzelStk),_WinIcoQuestion, _WinDialogYesNoCancel,2);
    if (Erx=_WinIdNo) then RETURN false;
    if (Erx=_WinIdCancel) then RETURN true;
  end;

  // Verbuchen.........
  Erx # RecLink(818,621,11,_recFirst);   // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  SWe.P.Nummer        # SWe.Nummer;
  SWe.P.Anlage.User   # gUserName;
  vLfd                # SWe.P.Eingangsnr;

  vBuf621 # RekSave(621);
  FOR vI # 1 loop inc(vI) WHILE (vI<=WinLstDatLineInfo($DL.List, _WinLstDatInfoCount)) do begin

    RecBufCopy(vBuf621,621);
    "SWe.P.Stückzahl"   # 1;

//      Dlg_Standard:Menge(aint(vI)+'. '+Translate('Gewicht'), var "SWe.P.Gewicht", SWe.P.Gewicht);
    WinLstCellGet($DL.List, SWe.P.Gewicht.Netto , 1, vI);
    WinLstCellGet($DL.List, SWe.P.Gewicht.Brutto , 2, vI);
    WinLstCellGet($DL.List, SWe.P.Coilnummer, 3, vI);

    if (VWa.NettoYN) then
      SWe.P.Gewicht # SWe.P.Gewicht.Netto
    else
      SWe.P.Gewicht # SWe.P.Gewicht.Brutto;

    TRANSON;
    SWe.P.Eingangsnr # SWe.P.Eingangsnr - 1;
    REPEAT
      SWe.P.Eingangsnr # SWe.P.Eingangsnr + 1;
      SWe.P.Anlage.Datum  # Today;
      SWe.P.Anlage.Zeit   # Now;
      Erx # RekInsert(621,0,'MAN');
    UNTIL (erx=_rOK);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN false;
    end;

    // Ausführungen kopieren
    vNr               # SWe.P.Eingangsnr;
    SWe.P.Nummer      # myTmpNummer;
    SWe.P.Eingangsnr  # vlfd;
    // Ausführungen kopieren
    Erx # RecLink(622,621,10,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf622 # RekSave(622);
      SWe.P.AF.Nummer       # SWe.Nummer;
      SWe.P.AF.Eingang      # vNr;
      RekInsert(622,0,'AUTO');
      RekRestore(vBuf622);
      RecRead(622,1,0);
      Erx # RecLink(622,621,10,_recNext);
    END;

    SWe.P.Nummer      # SWe.Nummer;
    SWe.P.Eingangsnr  # vNr;

    // Vorgang buchen
    if (SWe_P_Data:Verbuchen(true)=false) then begin
      TRANSBRK;
      Error(506001,'');
      ErrorOutput;
      RETURN false;
    end;
    TRANSOFF;

    // Etikettendruck?
    if (SWe.P.Materialnr<>0) and (Set.Ein.WE.Etikett<>0) then begin
      Erx # RecLink(200,621,6,_RecFirst); // Eingangsmaterial holen
      if (Set.Ein.WE.Etikett=999) then
        Mat_Etikett:Etikett(0,y,1)
      else
        Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
    end;

  END;  // ...For Einzelkarte

  RekRestore(vBuf621);

  // Ausführungen löschen
  vNr               # SWe.P.Eingangsnr;
  SWe.P.Nummer      # myTmpNummer;
  SWe.P.Eingangsnr  # vlfd;
  WHILE (RecLink(622,621,10,_RecFirst)=_rOK) do begin
    RekDelete(622,0,'AUTO');
  END;

  gSelected # 1;

  RETURN true;
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked (
  aEvt            : event
) : logic
local begin
  vColumn         : int;
  vColType        : int;
end;
begin
  case ( aEvt:obj->wpName ) of
    'Delete' :
      RecDel();
  end;
end;


//========================================================================