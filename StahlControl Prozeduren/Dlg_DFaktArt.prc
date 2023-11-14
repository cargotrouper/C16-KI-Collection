@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_DFaktArt
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  02.02.2022  AH  EinsatzMenge kann nicht höher als Art.C.Bestand sein
//  30.05.2022  AH  FIX für Warengruppen ohne Mengenführung
//
//  Subprozeduren
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtMenuCommand (aEvt : event; aMenuItem : int) : logic
//
//    SUB DFaktArt(var aMenge : float; var aStk : int; var aMengeFak : float; var aGew : float; var aDatum : date; var aBem : alpha) : logic;
//    SUB MatzArt(var aMenge : float; var aStk : int; var aMengeFak : float; var aGew : float) : logic;
//========================================================================
@I:Def_Global


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin
  if (aEvt:Obj->Wininfo(_WinType)=_WinTypeCheckbox) then
     aEvt:Obj->wpColBkg # _WinColCyan;
  else
    aEvt:Obj->wpColFocusBkg # ColFocus;
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt weg
//========================================================================
sub EvtFocusTerm(
  aEvt                 : event;    // Ereignis
  aFocusObject         : int;      // Objekt, das den Fokus bekommt
) : logic;
begin

  if (aEvt:obj->wpname='ed.Input') /*and ($ed.Input->wpchanged)*/ then begin
    if ($ed.Stueck->wpcaptionint=0) or (Art.MEH='Stk') then
      $ed.Stueck->wpcaptionint # cnvif(Lib_Einheiten:WandleMEH(252, 0, 0.0, $ed.Input->wpcaptionfloat , Art.MEH, 'Stk'));
    if ($ed.Output->wpcaptionfloat=0.0) then
      $ed.Output->wpcaptionfloat # Lib_Einheiten:WandleMEH(252, 0, 0.0, $ed.Input->wpcaptionfloat , Art.MEH, Auf.P.MEH.Preis);
  end;

  if (aEvt:obj->wpname='ed.Stueck') /*and ($ed.Stueck->wpchanged)*/ then begin
    if ($ed.Input->wpcaptionfloat=0.0) then
      $ed.Input->wpcaptionfloat # Lib_Einheiten:WandleMEH(252, $ed.Stueck->wpcaptionint, 0.0, 0.0,'', Art.MEH);
    if ($ed.Output->wpcaptionfloat=0.0) then
      $ed.Output->wpcaptionfloat # Lib_Einheiten:WandleMEH(252, $ed.Stueck->wpcaptionint, 0.0, 0.0,'', Auf.P.MEH.Preis);
  end;

  if (aEvt:obj->wpname='ed.Output') /*and ($ed.Output->wpchanged)*/ then begin
    if ($ed.Input->wpcaptionfloat=0.0) then
      $ed.Input->wpcaptionfloat # Lib_Einheiten:WandleMEH(252, 0, 0.0, $ed.Output->wpcaptionfloat , Auf.P.MEH.Preis, Art.MEH);
    if ($ed.Stueck->wpcaptionint=0) then
      $ed.Stueck->wpcaptionint # cnvif(Lib_Einheiten:WandleMEH(252, 0, 0.0, $ed.Output->wpcaptionfloat , Auf.P.MEH.Preis, 'Stk'));
  end;


  RETURN(true);
end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vStk        : int;
  vGew        : float;
  vM1,vM2     : float;
  vMEH1,vMEH2 : alpha;
end;
begin

  vM1       # $ed.Input->wpcaptionfloat;
  vM2       # $ed.Output->wpcaptionfloat;
  vGew      # $ed.Gewicht->wpcaptionfloat;
  vStk      # $ed.Stueck->wpcaptionint;
  vMEH1     # $lb.MEH.IN->wpcaption;
  vMEH2     # $lb.MEH.Out->wpcaption;
  case (aMenuItem->wpName) of

    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='ed.Gewicht') then begin
        vGew # Lib_Einheiten:WandleMEH(252, vStk, 0.0, vM2, vMEH2, 'kg');
        $ed.Gewicht->wpcaptionfloat # vGew;
        $ed.Gewicht->winFocusset(true);
      end;
    end;
  end; // case

end;


//========================================================================
// DFaktArt
//
//========================================================================
sub DFaktArt(
  var aMenge    : float;  // Pointer
  var aStk      : int;
  var aMengeFak : float;
  var aGew      : float;
  var aDatum    : date;
  var aBem      : alpha;
  aMEH1         : alpha;
  aMEH2         : alpha;
) : logic;
local begin
  vID     : int;

  vHDL      : int;
  vHInput   : int;
  vHOutput  : int;
  vHStk     : int;
  vHBem     : int;
  vHMEH1    : int;
  vHMEH2    : int;
  vHMEH1b   : int;
  vHMEH2b   : int;
  vHGew     : int;
  vHDatum   : int;
end;
begin

  if (aDatum=0.0.0) then aDatum # today;

  RecLink(819,250,10,0);    // 30.05.2022 AH, Warengruppe holen
  
  // Dialog laden...
  vHDL # winOpen('Dlg.DFaktArt',_WinOpenDialog);;

  if (aMEH1='Stk') then
    $lb.BestandMenge->wpcaption   # ANum(Art.C.Bestand, 0)
  else
    $lb.BestandMenge->wpcaption   # ANum(Art.C.Bestand, Set.Stellen.Menge);
  $lb.BestandStueck->wpcaption  # AInt(Art.C.Bestand.Stk);
  if (aMEH2='Stk') then
    $lb.AufMenge->wpcaption     # ANum(Auf.P.Prd.Rest, 0)
  else
    $lb.AufMenge->wpcaption     # ANum(Auf.P.Prd.Rest, Set.Stellen.Menge);
  $lb.AufGewicht->wpcaption     # ANum(Auf.P.Prd.Rest.Gew, Set.Stellen.Menge);

  vHInput   # vHdl->winSearch('ed.Input');
  if (vHInput<>0) then begin    // 02.02.2022 AH:
    vHInput->wpMinFloat # 0.0;
    if (Wgr.OhneBestandYN=false) then vHInput->wpMaxFloat # Art.C.Bestand;    /// 30.05.2022AH
  end;
  vHOutput  # vHdl->winSearch('ed.Output');
  vHStk     # vHdl->winSearch('ed.Stueck');
  if (vHStk<>0) then begin    // 02.02.2022 AH:
    vHStk->wpMinInt   # 0;
    vHStk->wpMaxInt   # Art.C.Bestand.Stk;
  end;

  vHMEH1    # vHdl->winSearch('lb.MEH.IN');
  vHMEH2    # vHdl->winSearch('lb.MEH.OUT');
  vHMEH1b   # vHdl->winSearch('lb.MEH.IN2');
  vHMEH2b   # vHdl->winSearch('lb.MEH.OUT2');
  vHGew     # vHdl->winSearch('ed.Gewicht');
  vHDatum   # vHdl->winSearch('ed.Datum');
  vHBem     # vHdl->winSearch('ed.Bemerkung');

  vHInput->wpcaptionfloat   # aMenge;
  vHInput->wpDecimals       # Set.Stellen.Menge;
  vHOutput->wpcaptionfloat  # aMengeFak;
  vHOutput->wpDecimals      # Set.Stellen.Menge;
  vHGew->wpcaptionfloat     # aGew;
  vHGew->wpDecimals         # Set.Stellen.Gewicht;
  vHStk->wpcaptionint       # aStk;
  vHMEH1->wpcaption         # aMEH1;//Art.MEH;
  vHMEH2->wpcaption         # aMEH2;//Auf.P.MEH.Preis;
  vHMEH1b->wpcaption        # aMEH1;//Art.MEH;
  vHMEH2b->wpcaption        # aMEH2;//Auf.P.MEH.Preis;
  vHDatum->wpcaptionDate    # aDatum;
  vHBem->wpcaption          # aBem;

  if (aMEH1='Stk') then begin
    vHStk->wpvisible # false;
    $lb.Stueck->wpvisible # false;
    $lb.Stueck2->wpvisible # false;
    //Lib_GuiCom:Disable(vHStk);
  end;
  if (aMEH2='kg') then begin
    vHGew->wpvisible # false;
    $lb.Gewicht->wpvisible # false;
    $lb.Gewicht2->wpvisible # false;
    //Lib_GuiCom:Disable(vHGew);
  end;

  // Dialog starten...
  vID # WinDialogRun(vHdl, _WinDialogCenter, gMDI);

  If (vId = _WinIdOk) then begin
    aMenge    # Rnd(vHInput->wpcaptionfloat, Set.Stellen.Menge);
    aMengeFak # Rnd(vHOutput->wpcaptionfloat, Set.Stellen.Menge);
    aGew      # Rnd(vHGew->wpcaptionfloat,Set.Stellen.Gewicht);
    aStk      # vHStk->wpcaptionint;
    if (aMEH1='Stk') then aStk # cnvif(aMenge);
    if (aMEH2='kg') then aGew # aMengeFak;
    aDatum    # vHDatum->wpcaptiondate;
    aBem      # vHBem->wpcaption;
    WinClose(vHdl);
    RETURN true;
    end
  else begin
    WinClose(vHdl);
    RETURN false;
  end;
end;


//========================================================================
// MatzArt
//
//========================================================================
sub MatzArt(
  var aMenge    : float;  // Pointer
  var aStk      : int;
  var aMengeFak : float;
  var aGew      : float;
) : logic;
local begin
  vID     : int;
  vHDL      : int;
  vHInput   : int;
  vHOutput  : int;
  vHStk     : int;
  vHGew     : int;
  vHMEH1    : int;
  vHMEH2    : int;
  vHMEH1b   : int;
  vHMEH2b   : int;
end;
begin

  // Dialog laden...
  vHDL # winOpen('Dlg.MatzArt',_WinOpenDialog);;

  vHInput   # vHdl->winSearch('ed.Input');
  vHOutput  # vHdl->winSearch('ed.Output');
  vHStk     # vHdl->winSearch('ed.Stueck');
  vHMEH1    # vHdl->winSearch('lb.MEH.IN');
  vHMEH2    # vHdl->winSearch('lb.MEH.OUT');
  vHGew     # vHdl->winSearch('ed.Gewicht');

  vHInput->wpcaptionfloat   # aMenge;
  vHInput->wpDecimals       # Set.Stellen.Menge;
  vHOutput->wpcaptionfloat  # aMengeFak;
  vHOutput->wpDecimals      # Set.Stellen.Menge;
  vHStk->wpcaptionint       # aStk;
  vHGew->wpcaptionfloat     # aGew;
  vHGew->wpDecimals         # Set.Stellen.Gewicht;
  vHMEH1->wpcaption         # Art.MEH;
  vHMEH2->wpcaption         # Auf.P.MEH.Preis;

//  if (Art.MEH='Stk') then Lib_GuiCom:Disable(vHStk);
  if (Art.MEH='Stk') then begin
    vHStk->wpvisible # false;
    $lb.Stueck->wpvisible # false;
  end;
  if (Auf.P.MEH.Preis='kg') then begin
    vHGew->wpvisible # false;
    $lb.Gewicht->wpvisible # false;
  end;

  // Dialog starten...
  vID # WinDialogRun(vHdl, _WinDialogCenter, gMDI);

  If (vId = _WinIdOk) then begin
    aMenge    # Rnd(vHInput->wpcaptionfloat, Set.Stellen.Menge);
    aMengeFak # Rnd(vHOutput->wpcaptionfloat,Set.Stellen.Menge);
    aStk      # vHStk->wpcaptionint;
    aGew      # Rnd(vHGew->wpcaptionfloat,Set.Stellen.Gewicht);
    if (Art.MEH='Stk') then aStk # cnvif(aMenge);
    if (Auf.P.MEH.Preis='kg') then aGew # aMengeFak;
    WinClose(vHdl);
    RETURN true;
    end
  else begin
    WinClose(vHdl);
    RETURN false;
  end;
end;


//========================================================================
//========================================================================