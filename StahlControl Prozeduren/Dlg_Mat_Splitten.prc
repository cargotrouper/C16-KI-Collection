@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_Mat_Splitten
//                    OHNE E_R_G
//  Info
//
//
//  08.04.2011  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB EvtClose(aEvt : event) : logic
//
//
//    SUB Splitten(var aStk : int; var aGewicht : float; var aNetto : float; var aBrutto : float; var aDat : date; aNettoSperr : logic;
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
// EvtInit
//
//========================================================================
Sub EvtInit(
  aEvt  : event;
) : logic
begin
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

  if (aMenuItem->wpname='Mnu.Save') then begin
      aEvt:obj->WinDialogResult(_WinIDOK);
      aEvt:Obj->WinClose();
  end;


  if (aMenuItem->wpname='Mnu.Ktx.Errechnen') then begin
    if (aEvt:Obj->wpname='ed.Stueck') then begin
//      vX # $ed.Gewicht->wpcaptionfloat;
//      vI # Lib_Berechnungen:STK_aus_KgDBLWgrArt(vX, Mat.Dicke, Mat.Breite, "MAt.länge", Mat.Warengruppe, '');
//      $ed.Stueck->wpcaptionint # vI;
    end;
    if (aEvt:Obj->wpname='ed.Gewicht') then begin
      vI # $ed.Stueck->wpcaptionint;
      if (Mat.Bestand.Stk<>0) then
        vX # (Mat.Bestand.Gew / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
      $ed.Gewicht->wpcaptionfloat # vX;
    end;
    if (aEvt:Obj->wpname='ed.NettoGewicht') then begin
      vI # $ed.Stueck->wpcaptionint;
//      vX # Lib_Berechnungen:KG_aus_StkDBLWgrArt(vI, Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, '');
      if (Mat.Bestand.Stk<>0) then
        vX # (Mat.Gewicht.Netto / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
      $ed.NettoGewicht->wpcaptionfloat # vX;
    end;
    if (aEvt:Obj->wpname='ed.BruttoGewicht') then begin
      vI # $ed.Stueck->wpcaptionint;
//      vX # Lib_Berechnungen:KG_aus_StkDBLWgrArt(vI, Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, '');
      if (Mat.Bestand.Stk<>0) then
        vX # (Mat.Gewicht.Brutto / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
      $ed.BruttoGewicht->wpcaptionfloat # vX;
    end;
  end;
	
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
local begin
  vI  : int;
  vX  : float;
end;
begin
//  aEvt:Obj->wpColBkg # _WinColParent;


  if (aEvt:Obj->wpname='ed.Stueck') then begin
    if ($ed.Gewicht->wpcaptionfloat=0.0) then begin
      vI # $ed.Stueck->wpcaptionint;
      if (Mat.Bestand.Stk<>0) then
        vX # (Mat.Bestand.Gew / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
      $ed.Gewicht->wpcaptionfloat # vX;
    end;
    if ($ed.Nettogewicht->wpcaptionfloat=0.0) then begin
      vI # $ed.Stueck->wpcaptionint;
      if (Mat.Bestand.Stk<>0) then
        vX # (Mat.Gewicht.Netto / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
      $ed.NettoGewicht->wpcaptionfloat # vX;
    end;
    if ($ed.BruttoGewicht->wpcaptionfloat=0.0) then begin
      vI # $ed.Stueck->wpcaptionint;
      if (Mat.Bestand.Stk<>0) then
        vX # (Mat.Gewicht.Brutto / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
      $ed.BruttoGewicht->wpcaptionfloat # vX;
    end;
  end;

  if (aEvt:Obj->wpname='ed.Gewicht') then begin
    if ($ed.NettoGewicht->wpreadonly) then begin
      $ed.NettoGewicht->wpcaptionfloat # aEvt:OBj->wpcaptionfloat
      winupdate($ed.NettoGewicht);
      end
    else begin
      $ed.BruttoGewicht->wpcaptionfloat # aEvt:OBj->wpcaptionfloat
      winupdate($ed.BruttoGewicht);
    end;
  end;

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

    'Bt.OK' : begin
      gSelected # 0;
      if ($Bt.OK->wpcustom<>'') then begin
        vHdl # vWin->Winsearch($Bt.OK->wpcustom);
        if (vHdl<>0) then begin
          case WinInfo(vHdl,_wintype) of
            _WinTypeDataList :  gSelected # vHdl->wpCurrentInt;
            _WinTypeRecList :   gSelected # vHdl->wpDbRecId;
          end;
        end;
      end;
      vWin->winClose();
    end;


    'Bt.Abbruch' : begin
      gSelected # 0;
      vWin->winClose();
    end;
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
  RETURN true;
end;

//========================================================================


//========================================================================
// Splitten
//
//========================================================================
sub Splitten(
  var aStk      : int;
  var aGewicht  : float;
  var aNetto    : float;
  var aBrutto   : float;
  var aDat      : date;
  aNettoSperr   : logic;
) : logic;
local begin
  Erx     : int;
  vHdl    : int;
  vId     : int;
  vPrefix : alpha;
  vA      : alpha(200);
end;
begin

  vDialog # 'Mat_Splitten';
  vPrefix # gPrefix;

  vHdl # WinOpen('Dlg.Mat.Splitten',_WinOpenDialog);
  Erx  # vHdl->WinSearch('ed.Stueck');
  Erx->wpCaptionInt   # aStk;
  Erx  # vHdl->WinSearch('ed.NettoGewicht');
  Erx->wpCaptionFloat # aNetto;
  if (aNettoSperr) then
    Lib_GuiCom:Disable(Erx);
  Erx  # vHdl->WinSearch('ed.BruttoGewicht');
  Erx->wpCaptionFloat # aBrutto;
  if (aNettoSperr=false) then
    Lib_GuiCom:Disable(Erx);
  Erx  # vHdl->WinSearch('ed.Gewicht');
  Erx->wpCaptionFloat # aGewicht;
  Erx  # vHdl->WinSearch('ed.Datum');
  Erx->wpCaptionDate # aDat;

  Erx  # vHdl->WinSearch('edMat.Bestand.Stk');
  Lib_GuiCOm:Disable(Erx);
  Erx  # vHdl->WinSearch('edMat.Gewicht.Brutto');
  Lib_GuiCOm:Disable(Erx);
  Erx  # vHdl->WinSearch('edMat.Gewicht.Netto');
  Lib_GuiCOm:Disable(Erx);
  Erx  # vHdl->WinSearch('edMat.Bestand.Gew');
  Lib_GuiCOm:Disable(Erx);

  // Dialog starten
  REPEAT
    vID # vHdl->Windialogrun(0,gMDI);//gFrmMain);
    if (vID != _winIdOk) then begin // Abbruch?
      vHdl->winclose();
      RETURN false;
    end
    else begin // Sichern?
      Erx     # vHdl->WinSearch('ed.Stueck');
      aStk    # Erx->wpCaptionInt;
      Erx     # vHdl->WinSearch('ed.NettoGewicht');
      aNetto  # Erx->wpCaptionFloat;
      Erx     # vHdl->WinSearch('ed.BruttoGewicht');
      aBrutto # Erx->wpCaptionFloat;
      Erx     # vHdl->WinSearch('ed.Gewicht');
      aGewicht # Erx->wpCaptionFloat;
      Erx     # vHdl->WinSearch('ed.Datum');
      aDat    # Erx->wpCaptiondate;
      vHdl->winclose();
      RETURN true;
    end;

  UNTIL (1=1);
end;


//=========================================================================
//=========================================================================