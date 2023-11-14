@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_IO_O_Main
//                  OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  11.10.2021  AH  ERX
//  08.06.2022  AH  Neu: WalzSpulen
//
//  Subprozeduren
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstRecControl(aEvt : Event; aRecId : int) : logic;
//    SUB AuswahlEvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB AuswahlEvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB AuswahlEvLstRecControl(aEvt : event; aID : int) : logic;
//    SUB FMAuswahlEvLstRecControl(aEvt : event; aID : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtMenuInitPopup..
//
//========================================================================
@I:Def_global
@I:Def_BAG

//========================================================================
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  vHdl # Winsearch(aEvt:obj, 'bt.BIS');
  if (vHdl<>0) and (BA1_P_Data:Muss1AutoFertigungHaben()) then vHdl->wpdisabled # true;
  RETURN(true);
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
begin

  Gv.Alpha.01 # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAG.IO.Breite,"Set.Stellen.Breite");
  if ("BAG.IO.Länge"<>0.0) then Gv.Alpha.01 # Gv.Alpha.01 + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");

//  Refreshmode();
end;


//========================================================================
//  EvtLstRecControl
//
//========================================================================
sub EvtLstRecControl(
	aEvt         : event;    // Ereignis
	aRecID       : int       // Record-ID des Datensatzes
) : logic
begin
  // nur Weiterbearbeitungen anzeigen
  RETURN (BAG.IO.Materialtyp=c_IO_BAG);
end;


//========================================================================
//  AuswahlEvtLstDataInit
//
//========================================================================
sub AuswahlEvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  vBuf703   : handle;
  Erx       : int;
end;
begin

  // Ankerfunktion
  if (RunAFX('BA1.IO.O.AW.LstDInit','')<>0) then RETURN;

  Gv.Alpha.02 # ANum(BAG.IO.Plan.IN.Menge,Set.Stellen.Menge)+' '+BAG.IO.MEH.In;
  Gv.Alpha.03 # ANum(BAG.IO.Ist.IN.Menge,Set.Stellen.Menge)+' '+BAG.IO.MEH.In;

  // MS 02 08 2008
  Gv.Alpha.04 # ANum(BAG.IO.Plan.In.GewN,Set.Stellen.Menge)+' kg';
  Gv.Alpha.05 # ANum(BAG.IO.Ist.In.GewN,Set.Stellen.Menge)+' kg';

  if (BAG.P.Aktion=c_BAG_SpaltSpulen) or (BAG.P.Aktion=c_BAG_WalzSpulen) then begin
  end
  else begin
    if (BAG.IO.Plan.In.Stk<=BAG.IO.Ist.In.Stk) then
      Lib_GuiCom:ZLColorLine($ZL.BAG.IO.Auswahl,Set.Col.RList.Deletd);
  end;
  
  
  vBuf703 # RecBufCreate(703);
  Erx # RecLink(vBuf703,701,3,_recfirst);   // Aus Fertigung holen
  if (vBuf703->BAG.F.PlanSchrottYN) then
    Lib_GuiCom:ZLColorLine($ZL.BAG.IO.Auswahl, _WinColLightYellow);
  RecBufDestroy(vBuf703);

end;


//========================================================================
//  AuswahlEvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub AuswahlEvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  vTmp : int;
end;
begin

  if (aButton=_WinMouseDouble | _WinMouseLeft) then begin
    gSelected # aID;

    vTmp # Wininfo(aEvt:obj, _winparent);
    if (vTmp=0) then vTmp # Winsearch(gFrmMain,'BA1.IO.Auswahl');
    if (vTmp=0) then vTmp # Winsearch(gFrmMain,Lib_Guicom:GetAlternativeName('BA1.FM.I.Auswahl'));
    if (vTmp=0) then vTmp # Winsearch(gFrmMain,'BA1.FM.O.Auswahl');
    if (vTmp<>0) then vTmp->Winclose();
  end;

end;


//========================================================================
//  AuswahlEvtLstRecControl
//
//========================================================================
sub AuswahlEvLstRecControl(
  aEvt  : event;
  aID   : int;
) : logic;
local begin
  vOK : logic;
  vID : int;
end;
begin
  vID # cnvia($ZL.BAG.IO.Auswahl->wpcustom);
  // nur echten Input anzeigen?
  if ($ZL.BAG.IO.Auswahl->wpdbkeyno=2) then begin
    vOk # (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_BAG) or (BAG.IO.MaterialTyp=c_IO_VSB);
  end
  else begin
    vOk # (BAG.IO.BruderID=0) and (BAG.IO.MaterialTyp=c_IO_BAG) and
      ( (BAG.IO.VonID=vID) or (vID=0) or (BAG.IO.VonId=0)) ;
    // nur NICHT weiterbearbeitete anzeigen
    vOK # vOK and (BAG.IO.NachBAG=0);
  end;

  RETURN vOK;
end;


//========================================================================
//  FMAuswahlEvtLstRecControl
//
//========================================================================
sub FMAuswahlEvLstRecControl(
  aEvt  : event;
  aID   : int;
) : logic;
local begin
  vOK : logic;
  vID : int;
end;
begin
  if (BAG.P.Aktion=c_BAG_Messen) then begin    // 07.05.2021 AH
    RETURN (BAG.IO.VonFertigmeld>0);
  end;

  vID # cnvia($ZL.BAG.IO.Auswahl->wpcustom);
  // nur echten Input anzeigen?
  if ($ZL.BAG.IO.Auswahl->wpdbkeyno=2) then begin
    vOk # (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_BAG) or (BAG.IO.MaterialTyp=c_IO_VSB);
  end
  else begin
    vOk # (BAG.IO.BruderID=0) and (BAG.IO.MaterialTyp=c_IO_BAG) and
      ( (BAG.IO.VonID=vID) or (vID=0) or (BAG.IO.VonId=0)) ;
  end;

  RETURN vOK;
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(
	aEvt         : event     // Ereignis
) : logic
begin

  if (aEvt:Obj->wpname='bt.BIS') then begin

    if (BA1_IO_Data:CreateBIS()=false) then begin
      ErrorOutput;
    end;

    $ZL.BAG.IO.Auswahl->winUpdate(_WinUpdon, _WinLstFromFirst|_WinLstPosBottom);
//todo('mindere ID:'+cnvai(BAG.FM.InputBAG)+'/'+cnvai(BAG.FM.InputID));

  //  RecRead(701
  end;

	RETURN (true);
end;


//========================================================================
//========================================================================
sub EvtMenuInitPopup(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüeintrag
) : logic;
local begin
  Erx   : int;
  vMenu : handle;
  vItem : handle;
  v701  : int;
  v702  : int;
end;
begin

  // Kontext - Menü
  if (aMenuItem <> 0) then RETURN true;

  // Ermitteln des Kontextmenüs des Frame-Objektes.
  vMenu # aEvt:Obj->WinInfo(_WinContextMenu);
  if (vMenu = 0) then RETURN true;

  // ersten Eintrag löschen, wenn kein Titel angegeben ist
  vItem # vMenu->WinInfo(_WinFirst);
  if (vItem > 0 and vItem->wpCaption = '') then vItem->WinMenuItemRemove(FALSE);

  if (aEvt:Obj->wpDbRecId=0) then RETURN true;

  // Keine Weiterbearbeitung von Umlagerungen
  if (Bag.P.Aktion = c_BAG_Umlager) then
    RETURN true;

  v701 # RecBufCreate(701);
  Erx # RecRead(v701, 0, _recId, aEvt:Obj->wpdbRecId);
  if (v701->BAG.IO.BruderID<>0) or (v701->BAG.IO.NachPOsition<>0) or (v701->BAG.IO.Materialtyp<>c_IO_BAG) then begin
    RecBufDestroy(v701);
    RETURN true;
  end;
  RecBufDestroy(v701);

  v702 # RecBufCreate(702);
  FOR Erx # RecLink(v702, 700, 1, _recfirst)  // Positionen loopen...
  LOOP Erx # RecLink(v702, 700, 1, _recNext)
  WHILE (erx<=_rLocked) do begin
    if (v702->BAG.P.Typ.VSBYN) then CYCLE;
    if (v702->BAG.P.Aktion = c_BAG_Umlager) then CYCLE;

    vItem # vMenu->WinMenuItemAdd('Ktx.AusbNachPos'+aint(v702->BAG.P.Position), Translate('nach Pos.')+aint(v702->BAG.P.Position)+' '+v702->bag.p.bezeichnung);
    if (vItem<>0) then begin
      if (v702->Bag.P.Position = BAG.P.Position) or
        (v702->"BAG.P.Löschmarker"<>'') then vItem->wpDisabled # true;
    end;
  END;

  RecBufDestroy(v702);

  RETURN(true);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================