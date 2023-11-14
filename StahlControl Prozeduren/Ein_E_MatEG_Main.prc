@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_E_MatEG_Main
//                      OHNE E_R_G
//  Info
//
//
//  21.10.2010  AI  Erstellung der Prozedur
//  28.04.2016  AH  BugFix: Ein.E.Menge wird errechnet
//  10.05.2022  AH  ERX
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
  cPrefix         : 'Ein_E_MatEG'
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
//  if(aMenuItem->wpName='Mnu.DL.Delete') then RecDel();
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
  if (vCoil='') then vCoil # Ein.E.Coilnummer;
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
  vBuf507     : int;
  vBuf506     : int;
end;
begin

  vEinzelSTK # WinLstDatLineInfo($DL.List, _WinLstDatInfoCount);

  // kein Einträge?
  if (vEinzelStk = 0) then RETURN true;

  if ("Ein.E.Stückzahl"<>vEinzelStk) then begin
    Erx # Msg(506015,aint(vEinzelStk)+'|'+aInt("Ein.E.Stückzahl"),_WinIcoWarning, _WinDialogYesNoCancel,2);
    if (Erx=_WinIdNo) then RETURN false;
    if (Erx=_WinIdCancel) then RETURN true;
  end
  else begin
    Erx # Msg(506016,aint(vEinzelStk),_WinIcoQuestion, _WinDialogYesNoCancel,2);
    if (Erx=_WinIdNo) then RETURN false;
    if (Erx=_WinIdCancel) then RETURN true;
  end;

  // Verbuchen.........
  Erx # RecLink(818,506,12,_recFirst);   // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  Ein.E.Nummer        # Ein.P.Nummer;
  Ein.E.Anlage.User   # gUserName;
  vLfd                # Ein.E.Eingangsnr;

  vBuf506 # RekSave(506);
  FOR vI # 1 loop inc(vI) WHILE (vI<=WinLstDatLineInfo($DL.List, _WinLstDatInfoCount)) do begin

    RecBufCopy(vBuf506,506);
    "Ein.E.Stückzahl"   # 1;

//      Dlg_Standard:Menge(aint(vI)+'. '+Translate('Gewicht'), var "Ein.E.Gewicht", Ein.E.Gewicht);
    WinLstCellGet($DL.List, Ein.E.Gewicht.Netto , 1, vI);
    WinLstCellGet($DL.List, Ein.E.Gewicht.Brutto , 2, vI);
    WinLstCellGet($DL.List, Ein.E.Coilnummer, 3, vI);

    if (VWa.NettoYN) then
      Ein.E.Gewicht # Ein.E.Gewicht.Netto
    else
      Ein.E.Gewicht # ein.e.Gewicht.Brutto;

    // 28.04.2016 AH:
    Ein.E.Menge # 0.0;
    if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
      Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    end
    else if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
      Ein.E.Menge # Ein.E.Gewicht;
    end
    begin
      if (Ein.E.Menge=0.0) then Ein.E.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0,'', Ein.E.MEH);
    end;


    TRANSON;
    REPEAT
      Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
      Ein.E.Anlage.Datum  # Today;
      Ein.E.Anlage.Zeit   # Now;
      Erx # RekInsert(506,0,'MAN');
    UNTIL (Erx=_rOK);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN false;
    end;

    // Ausführungen kopieren
    vNr               # Ein.E.Eingangsnr;
    Ein.E.Nummer      # myTmpNummer;
    Ein.E.Eingangsnr  # vlfd;
    // Ausführungen kopieren
    Erx # RecLink(507,506,13,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf507 # RekSave(507);
      Ein.E.AF.Nummer       # Ein.P.Nummer;
      Ein.E.AF.Eingang      # vNr;
      RekInsert(507,0,'AUTO');
      RekRestore(vBuf507);
      RecRead(507,1,0);
      Erx # RecLink(507,506,13,_recNext);
    END;

    Ein.E.Nummer      # Ein.P.Nummer;
    Ein.E.Eingangsnr  # vNr;

    // Vorgang buchen
    if (Ein_E_Data:Verbuchen(y)=false) then begin
      TRANSBRK;
      Error(506001,'');
      ErrorOutput;
      RETURN false;
    end;
    TRANSOFF;

    // Etikettendruck?
    if (Ein.E.Materialnr<>0) and (Set.Ein.WE.Etikett<>0) then begin
      Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
      if (Set.Ein.WE.Etikett=999) then
        Mat_Etikett:Etikett(0,y,1)
      else
        Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
    end;

  END;  // ...For Einzelkarte

  RekRestore(vBuf506);

  // Ausführungen löschen
  vNr               # Ein.E.Eingangsnr;
  Ein.E.Nummer      # myTmpNummer;
  Ein.E.Eingangsnr  # vlfd;
  WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
    RekDelete(507,0,'AUTO');
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