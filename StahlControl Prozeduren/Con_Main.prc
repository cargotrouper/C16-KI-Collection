@A+
//==== Business-Control ==================================================
//
//  Prozedur    Con_Main
//                    OHNE E_R_G
//  Info
//
//
//  14.12.2009  AI  Erstellung der Prozedur
//  18.03.2010  ST  Ausgliederung Recalc, Generierung von Kennzahlen
//  25.03.2010  ST  Serienmarkierung hinzugefügt
//  03.08.2011  ST  Auftragsart hinzugefügt
//  05.04.2022  AH  ERX
//  21.07.2022  HA  Quick jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshDataList();
//    SUB Edit(aMonat : int);
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAdresse()
//    SUB AusVertreter()
//    SUB AusWGr()
//    SUB AusAGr()
//    SUB AusArtikel()
//    SUB AusGuete()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic;
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Controlling'
  cFile       :  950
  cMenuName   : 'Con.Bearbeiten'
  cPrefix     : 'Con'
  cZList      : $ZL.Controlling
  cKey        : 1
end;

declare RefreshDataList();

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
 
Lib_Guicom2:Underline($edCon.Adressnummer);
Lib_Guicom2:Underline($edCon.Auftragsart);
Lib_Guicom2:Underline($edCon.Vertreternr);
Lib_Guicom2:Underline($edCon.Warengruppe);
Lib_Guicom2:Underline($edCon.Artikelnummer);
Lib_Guicom2:Underline($edCon.Artikelgruppe);


  SetStdAusFeld('edCon.Adressnummer'  ,'Adresse');
  SetStdAusFeld('edCon.Vertreternr'   ,'Vertreter');
  SetStdAusFeld('edCon.Warengruppe'   ,'WGr');
  SetStdAusFeld('edCon.Artikelgruppe' ,'AGr');
  SetStdAusFeld('edCon.Artikelnummer' ,'Artikel');
  SetStdAusFeld('edCon.Auftragsart'   ,'Auftragsart');

  RefreshDataList();

  Lib_GuiCom:RecallList($dl.Tabelle);

  App_Main:EvtInit(aEvt);
  
//  if (gMdiMath=0) then begin
//    gMdiMath # WinAddByName(gFrmMain, Lib_GuiCom:GetAlternativeName('Mdi.Test'), _WinAddHidden);
 //   gMdiMath->WinUpdate(_WinUpdOn);
//  end
//  else begin
   // WinUpdate(gMDIMath, _winupdactivate);
//  end;

end;


//========================================================================
//  RefreshDataList
//
//========================================================================
sub RefreshDataList();
local begin
  vI    : int;
  vX    : float;
  vHdl  : handle;
  vPos  : int;
end;
begin
  vHdl # $dl.Tabelle;
  vPos # vHdl->wpcurrentint;
  vHDL->WinLstDatLineRemove(_winLstDatLineall);

  FOR vI # 1 loop inc(vI) while (vI<=13) do begin
    if (vHdl->wpcustom='Umsatz') then begin
      vX # FldFloat(950, 5, vI);
      vHDL->WinLstDatLineAdd(vX);
      vX # FldFloat(950, 6, vI);
      vHDL->WinLstCellSet(vX,2,_WinLstDatLineLast);
      vX # FldFloat(950, 7, vI);
      vHDL->WinLstCellSet(vX,3,_WinLstDatLineLast);

      vX # 0.0;
      if (FldFloat(950, 2, vI)<>0.0) then vX # FldFloat(950,5,vI) / FldFloat(950,2,vI);
      vHDL->WinLstCellSet(vX,4,_WinLstDatLineLast);
      vX # 0.0;
      if (FldFloat(950, 3, vI)<>0.0) then vX # FldFloat(950,6,vI) / FldFloat(950,3,vI);
      vHDL->WinLstCellSet(vX,5,_WinLstDatLineLast);
      vX # 0.0;
      if (FldFloat(950, 4, vI)<>0.0) then vX # FldFloat(950,7,vI) / FldFloat(950,4,vI);
      vHDL->WinLstCellSet(vX,6,_WinLstDatLineLast);
    end;
    if (vHdl->wpcustom='Menge') then begin
      vX # FldFloat(950, 2, vI);
      vHDL->WinLstDatLineAdd(vX);
      vX # FldFloat(950, 3, vI);
      vHDL->WinLstCellSet(vX,2,_WinLstDatLineLast);
      vX # FldFloat(950, 4, vI);
      vHDL->WinLstCellSet(vX,3,_WinLstDatLineLast);
    end;
    if (vHdl->wpcustom='DB') then begin
      vX # FldFloat(950, 11, vI);
      vHDL->WinLstDatLineAdd(vX);
      vX # FldFloat(950, 12, vI);
      vHDL->WinLstCellSet(vX,2,_WinLstDatLineLast);
      vX # FldFloat(950, 13, vI);
      vHDL->WinLstCellSet(vX,3,_WinLstDatLineLast);

      vX # 0.0;
      if (FldFloat(950, 2, vI)<>0.0) then vX # FldFloat(950,11,vI) / FldFloat(950,2,vI);
      vHDL->WinLstCellSet(vX,4,_WinLstDatLineLast);
      vX # 0.0;
      if (FldFloat(950, 3, vI)<>0.0) then vX # FldFloat(950,12,vI) / FldFloat(950,3,vI);
      vHDL->WinLstCellSet(vX,5,_WinLstDatLineLast);
      vX # 0.0;
      if (FldFloat(950, 4, vI)<>0.0) then vX # FldFloat(950,13,vI) / FldFloat(950,4,vI);
      vHDL->WinLstCellSet(vX,6,_WinLstDatLineLast);

    end;
  END;

  vHdl->wpcurrentint # vPos;

end;


//========================================================================
//  Edit
//
//========================================================================
sub Edit(aMonat : int);
begin
  if (aMonat<1) or (aMonat>12) then RETURN;
  if (Rechte[Rgt_CON_Aendern]=n) then RETURN;

  gZLList->wpcustom # '->DATALIST';
  $dl.Tabelle->wpdisabled # y;

  App_Main:Action(c_ModeEdit);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx   : int;
  vName : alpha;
  vHdl  : handle;
  vHdl2 : handle;
  vTmp  : int;
  vDS   : logic;
end;
begin
  
  case (Con.Typ) of
    ''  : vName # 'Erlöse';
    'A' : vName # 'Auftragserfassung';
    'B' : vName # 'Bestellerfassung';
    'G' : vName # 'Angebotserfassung';
  end;
  $lbTyp->wpCaption # vName;
  $bt.Refresh->wpDisabled # mode <> c_modeView;
  $bt.Graph->wpDisabled # mode <> c_modeView;

  $bt.DB->wpDisabled # (Con.Typ<>'');

  if (Con.Refreshdatum>1.1.1900) then begin
    $lbDatum->wpCaption # cnvad(Con.Refreshdatum);
    $lbZEit->wpcaption  # cnvat(Con.Refreshzeit);
  end
  else begin
    $lbDatum->wpCaption # '';
    $lbZeit->wpcaption # '';
  end;
  
  if (Mode=c_ModeView) then begin
    RefreshDataList();
  end;

  if (aName='') or (aName='edCon.Adressnummer') then begin
    Erx # RecLink(100,950,1,0);     // Adresse holen
    if (Erx<=_rLocked) then
      $Lb.Adresse->wpcaption # Adr.Stichwort
    else
      $Lb.Adresse->wpcaption # '';
  end;
  if (aName='') or (aName='edCon.Vertreternr') then begin
    Erx # RecLink(110,950,2,0);     // Vertreter holen
    if (Erx<=_rLocked) then
      $Lb.Vertreter->wpcaption # Ver.Stichwort
    else
      $Lb.Vertreter->wpcaption # '';
  end;
  if (aName='') or (aName='edCon.Warengruppe') then begin
    Erx # RecLink(819,950,3,0);     // WGr holen
    if (Erx<=_rLocked) then
      $Lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.Warengruppe->wpcaption # '';
  end;
  if (aName='') or (aName='edCon.Artikelgruppe') then begin
    Erx # RecLink(826,950,4,0);     // AGr holen
    if (Erx<=_rLocked) then
      $Lb.Artikelgruppe->wpcaption # Agr.Bezeichnung.L1
    else
      $Lb.Artikelgruppe->wpcaption # '';
  end;

  if (aName='') or (aName='edCon.Auftragsart') then begin
    Erx # RecLink(835,950,7,0);     // Auftragsart holen
    if (Erx<=_rLocked) then
      $lb.AuftragsArt->wpcaption # AAr.Bezeichnung
    else
      $lb.AuftragsArt->wpcaption # '';
  end;


  if (aName='') or (aName='edCon.Artikelnummer') then begin
    if (Con.Dateinr=250) then begin
      Erx # RecLink(250,950,5,0);   // Artikel holen
      if (Erx<=_rLocked) then
        $Lb.Artikel->wpcaption # Art.Stichwort
      else
        $Lb.Artikel->wpcaption # '';
      if (aChanged) or ($edCon.Artikelnummer->wpchanged) then
        Con.MEH # Art.MEH;
      end
    else begin
      $Lb.Artikel->wpcaption # '';
      Con.MEH # 't';
    end;
    $lb.MEH1->winupdate(_WinUpdFld2Obj);
  end;
/*
  if (aName='') or (aName='edCon.Kostenstelle') then begin
    Erx # RecLink(846,950,6,0);     // Kostenstelle holen
    if (Erx<=_rLocked) then
      $lb.Kostenstelle->wpcaption # KSt.Bezeichnung;
    else
      $lb.Kostenstelle->wpcaption # '';
  end;
*/

  if (aName='') then begin
    if (Con.DateiNr=200) then begin
      $cb.Material->wpCheckState # _WinStateChkchecked;
      $cb.Artikel->wpCheckState # _WinStateChkUnchecked;
      $lbCon.Artikelgruppe->wpvisible # false;
      $edCon.Artikelgruppe->wpvisible # false;
      $bt.AGr->wpvisible              # false;
      $lb.Artikelgruppe->wpvisible    # false;
      $lbCon.Artikelnummer->wpcaption # Translate('Güte');
    end
    else begin
      $cb.Material->wpCheckState # _WinStateChkUnchecked;
      $cb.Artikel->wpCheckState # _WinStateChkchecked;
      $lbCon.Artikelgruppe->wpvisible # true;
      $edCon.Artikelgruppe->wpvisible # true;
      $bt.AGr->wpvisible              # true;
      $lb.Artikelgruppe->wpvisible    # true;
      $lbCon.Artikelnummer->wpcaption # Translate('Artikelnummer');
    end;
  end;

  $bt.Menge->wpdisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit);
  $bt.Umsatz->wpdisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit);
  $bt.DB->wpdisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit);
  vHdl # $dl.Tabelle;
  if (vHdl->wpcustom='Umsatz') then begin
    vName # Translate('Umsatz');
    vDS # y;
  end
  else if (vHdl->wpcustom='DB') then begin
    vName # Translate('DB');
    vDS # y;
  end
  else begin
    vName # Translate('Menge');
    vDS # n;
  end;
  vHdl2 # Winsearch(vHdl, 'clm.Soll');
  vHdl2->wpcaption # vName+'-'+Translate('Soll');
  vHdl2 # Winsearch(vHdl, 'clm.Ist');
  vHdl2->wpcaption # vName+'-'+Translate('Ist');
  vHdl2 # Winsearch(vHdl, 'clm.Sim');
  vHdl2->wpcaption # vName+'-'+Translate('Simulation');
  vHdl->winupdate(_WinUpdon);
  vHdl2 # Winsearch(vHdl, 'clm.SollDS');
  vHdl2->wpvisible # vDS;
  vHdl2 # Winsearch(vHdl, 'clm.IstDS');
  vHdl2->wpvisible # vDS;
  vHdl2 # Winsearch(vHdl, 'clm.SImDS');
  vHdl2->wpvisible # vDS;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vDat  : date;
  vTmp  : int;
end;
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  if (Mode=c_modeNew) then begin
    Con.Dateinr # 250;
    Con.MEH     # 't';
    Con.Typ     # '_';

    RefreshDataList();
    vDat # today;
    Con.Jahr # vDat->vpyear;
    $edCon.Jahr->WinFocusSet(true);
    
    vTmp # WinDialog('Con.Typ.Auswahl',_WinDialogCenter,gMDI);
    IF (vTmp= _WinIdClose) or (gSelected=0) then begin
      App_Main_Sub:StopModeNew();   // Neuerfassung abbrechen
      RETURN;
    end;

    gMDI->winfocusset(true);
    vTmp # gSelected;
    gSelected # 0;
    case vTmp of
      450 :   Con.Typ # '';
      401 :   Con.Typ # 'A';
      501 :   Con.Typ # 'B';
      1401 :  Con.Typ # 'G';
    end;

  end
  else begin
    $ed.Soll.Menge->WinFocusSet(true);
  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vM    : int;
  vI    : int;
  vX    : float;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    vM # Cnvia($lb.Monat->wpcustom);
    if (vM>=1) and (vM<=12) then begin
      Con.Soll.Menge.Sum  # Con.Soll.Menge.Sum - FldFloat(950,2,vM);
      Con.Sim.Menge.Sum   # Con.Sim.Menge.Sum - FldFloat(950,4,vM);
      Con.Soll.Umsatz.Sum # Con.Soll.Umsatz.Sum - FldFloat(950,5,vM);
      Con.Sim.Umsatz.Sum  # Con.Sim.Umsatz.Sum - FldFloat(950,7,vM);
      Con.Soll.DB.Sum     # Con.Soll.DB.Sum - FldFloat(950,11,vM);
      Con.Sim.DB.Sum      # Con.Sim.DB.Sum - FldFloat(950,13,vM);
      FldDef(950,2,vM, $ed.Soll.Menge->wpcaptionfloat);
      FldDef(950,4,vM, $ed.Sim.Menge->wpcaptionfloat);
      FldDef(950,5,vM, $ed.Soll.Umsatz->wpcaptionfloat);
      FldDef(950,7,vM, $ed.Sim.Umsatz->wpcaptionfloat);
      FldDef(950,8,vM, $ed.Soll.Proz->wpcaptionfloat);
      FldDef(950,10,vM,$ed.Sim.Proz->wpcaptionfloat);
      FldDef(950,11,vM, cnvfa($lb.Soll.DB->wpcaption));
      FldDef(950,13,vM, cnvfa($lb.Sim.DB->wpcaption));
      Con.Soll.Menge.Sum  # Con.Soll.Menge.Sum + FldFloat(950,2,vM);
      Con.Sim.Menge.Sum   # Con.Sim.Menge.Sum + FldFloat(950,4,vM);
      Con.Soll.Umsatz.Sum # Con.Soll.Umsatz.Sum + FldFloat(950,5,vM);
      Con.Sim.Umsatz.Sum  # Con.Sim.Umsatz.Sum + FldFloat(950,7,vM);
      Con.Soll.DB.Sum     # Con.Soll.DB.Sum + FldFloat(950,11,vM);
      Con.Sim.DB.Sum      # Con.Sim.DB.Sum + FldFloat(950,13,vM);

      Con.Soll.Proz.Sum   # 0.0;
      Con.Sim.Proz.Sum   # 0.0;
      FOR vI # 1 loop inc (vI) WHILE (vI<=12) do begin
        Con.Soll.Proz.Sum # Con.Soll.Proz.Sum + FldFloat(950,8,vI);
        Con.Sim.Proz.Sum  # Con.Sim.Proz.Sum + FldFloat(950,10,vI);
      END;
      Con.Soll.Proz.Sum # Rnd(Con.Soll.Proz.Sum / 12.0,2);
      Con.Sim.Proz.Sum  # Rnd(Con.Sim.Proz.Sum / 12.0,2);
//      Con.Soll.DB.Sum   # Con.Soll.Umsatz.Sum * (Con.Soll.Proz.Sum / 100.0);
//      Con.Sim.DB.Sum    # Con.Sim.Umsatz.Sum * (Con.Sim.Proz.Sum / 100.0);
      $dl.Tabelle->wpdisabled # n;
    end;
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);

//    RefreshDataList();
  end
  else begin
    Con.Refreshdatum  # today;
    Con.Refreshzeit   # now;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  $dl.Tabelle->wpdisabled # n;
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
    RefreshDataList();
  end;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (aEvt:Obj->wpname='Edit') then begin
    if (gZLList->wpcustom='->DATALIST') then begin
      $dl.Tabelle->winfocusset(true);
      gZLList->wpcustom # '2DATALIST';
      RETURN true;
    end;
    if (gZLList->wpcustom='2DATALIST') then begin
      $dl.Tabelle->winfocusset(true);
      gZLList->wpcustom # '3DATALIST';
      RETURN true;
    end;
    if (gZLList->wpcustom='3DATALIST') then begin
      $dl.Tabelle->winfocusset(true);
      gZLList->wpcustom # '';
    end;
    RETURN App_Main:EvtFocusInit(aEvt, aFocusObject);
  end;

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
local begin
  vM    : int;
  vX    : float;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  vM # Cnvia($lb.Monat->wpcustom);
  if (vM>=1) and (vM<=12) then begin
    vX # $ed.Soll.Umsatz->wpcaptionfloat;
    vX # vX * ($ed.Soll.Proz->wpcaptionfloat/100.0);
    vX # Rnd(vX,2);
    $lb.Soll.DB->wpcaption # ANum(vX,2);

    vX # $ed.Sim.Umsatz->wpcaptionfloat;
    vX # vX * ($ed.Sim.Proz->wpcaptionfloat/100.0);
    vX # Rnd(vX,2);
    $lb.Sim.DB->wpcaption # ANum(vX,2);
    end
  else begin
    $lb.Soll.DB->wpcaption # '';
    $lb.Sim.DB->wpcaption # '';
  end;

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  vA    : alpha;
end;

begin

  case aBereich of
    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vertreter' : begin
      RecBufClear(110);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusVertreter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'WGr' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'WGr.Verwaltung',here+':AusWGr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AGr' : begin
      RecBufClear(826);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'AGr.Verwaltung',here+':AusAGr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Auftragsart' : begin
      RecBufClear(835);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'AAr.Verwaltung',here+':AusAuftragsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel' : begin
      if (Con.Dateinr=250) then begin
        RecBufClear(250);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Art.Verwaltung',here+':AusArtikel');
        end
      else begin
        RecBufClear(832);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'MQu.Verwaltung',here+':AusGuete');
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

/*
    'Kostenstelle' : begin
      RecBufClear(846);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'KSt.Verwaltung',here+':AusKSt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
*/
  end;  // ...case

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Adressnummer # Adr.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Adressnummer->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Vertreternr # Ver.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Vertreternr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusAuftragsart
//
//========================================================================
sub AusAuftragsart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(835,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Auftragsart # AAr.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Auftragsart->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusWGr
//
//========================================================================
sub AusWGr()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Warengruppe # WGr.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusAGr
//
//========================================================================
sub AusAGr()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(826,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Artikelgruppe # Agr.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Artikelgruppe->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;



//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Artikelnummer # Art.Nummer;
    Con.MEH           # Art.MEH;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edCon.Artikelnummer',y);
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
   RecRead(832,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      Con.Artikelnummer # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      Con.Artikelnummer # "MQu.Güte1"
    else
      Con.Artikelnummer # "MQu.Güte2";

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusKSt
//
//========================================================================
sub AusKSt()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Con.Kostenstelle # KSt.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edCon.Kostenstelle->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl    : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_CON_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_CON_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_CON_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_CON_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_CON_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_CON_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Recalc');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_ModeList) or (Rechte[Rgt_CON_Aendern]=n);

  vHdl # gMenu->WinSearch('Mnu.Generieren');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_ModeList) or (Rechte[Rgt_CON_Aendern]=n);


  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of


    'Mnu.Recalc' : begin
      Con_Data:Recalc(true);
    end;

    'Mnu.Generieren' : begin
      Con_Data:Generieren();
    end;

    'Mnu.GenerierenVorgaben' : begin
      Con_Data:GenerierenVorgaben();
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
    end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;


    'Mnu.Mark.Sel' : begin
      Con_Mark_Sel();  // Aufruf für Selektionsmaske
    end;



  end; // ...case


end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFontB  : font;
  vFont   : font;
end;
begin

  vFont   # $bt.Menge->wpfont;
  vFontB  # $bt.Menge->wpfont;
  vFont:Attributes  # 0;
  vFontB:Attributes # _WinFontAttrB;

  case (aEvt:Obj->wpName) of
    'btAuf'   : gSelected # 401;
    'btBest'  : gSelected # 501;
    'btAng'   : gSelected # 1401;
    'btErl'   : gSelected # 450;

    'bt.Graph'  : Mdi_Con_Graph:SpawnGraph(RecBufDefault(950), $dl.Tabelle->wpcustom);
    
    'bt.Refresh'     : begin
      Con_Data:Recalc(false);
      REfreshifm();
    end;

    'bt.Umsatz'     : begin
      $dl.Tabelle->wpcustom # 'Umsatz';
      $bt.Umsatz->wpfont  # vFontB;
      $bt.Menge->wpfont   # vFont;
      $bt.DB->wpfont      # vFont;
      Refreshifm();
      RefreshDataList();
      end;

    'bt.Menge'     : begin
      $dl.Tabelle->wpcustom # 'Menge';
      $bt.Umsatz->wpfont  # vFont;
      $bt.Menge->wpfont   # vFontB;
      $bt.DB->wpfont      # vFont;
      Refreshifm();
      RefreshDataList();
      end;

    'bt.DB'        : begin
      $dl.Tabelle->wpcustom # 'DB';
      $bt.Umsatz->wpfont  # vFont;
      $bt.Menge->wpfont   # vFont;
      $bt.DB->wpfont      # vFontB;
      Refreshifm();
      RefreshDataList();
      end;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Adresse'      : Auswahl('Adresse');
    'bt.Vertreter'    : Auswahl('Vertreter');
    'bt.WGr'          : Auswahl('WGr');
    'bt.AGr'          : Auswahl('AGr');
    'bt.Artikel'      : Auswahl('Artikel');
    'bt.Auftragsart'  : Auswahl('Auftragsart');
  end;  // ...case

  if (gSelected<>0) then begin
    $Con.Typ.Auswahl->Winclose();
  end;
  
end;


//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cb.Artikel') and (aEvt:OBj->wpCheckState=_WinStateChkChecked) then begin
//    $cb.Material->wpCheckState # _WinStateChkUnchecked;
    Con.Dateinr # 250;
  end;
  if (aEvt:Obj->wpname='cb.Material') and (aEvt:OBj->wpCheckState=_WinStateChkChecked) then begin
//    $cb.Artikel->wpCheckState # _WinStateChkUnchecked;
    Con.Dateinr # 200;
  end;

  RefreshIFM();

  RETURN (true);
end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin
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
  Erx : int;
end;
begin

  Erx # 100;
  if (Con.Adressnummer<>0) then
    Erx # RecLink(100,950,1,0);     // Adresse holen
  if (Erx>_rLocked) then RecBufClear(100);

  Erx # 100;
  if (Con.VertreterNr<>0) then
    Erx # RecLink(110,950,2,0);     // Vertreter holen
  if (Erx>_rLocked) then RecBufClear(110);

  Erx # 100;
  if (Con.Auftragsart<>0) then
    Erx # RecLink(835,950,7,0);     // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);

  Erx # 100;
  if (Con.Warengruppe<>0) then
    Erx # RecLink(819,950,3,0);     // WGr holen
  if (Erx>_rLocked) then RecBufClear(819);

  Erx # 100;
  if (Con.Artikelgruppe<>0) then
    Erx # RecLink(826,950,4,0);     // AGr holen
  if (Erx>_rLocked) then RecBufClear(826);

  Erx # 100;
  if (Con.Artikelnummer<>'') and (Con.Dateinr=250) then
      Erx # RecLink(250,950,5,0);   // Artikel holen
  if (Erx>_rLocked) then RecBufClear(250);

  GV.Alpha.01 # '';
  case (Con.Typ) of
    ''  : Gv.Alpha.01 # Translate('Erlöse');
    'A' : Gv.Alpha.01 # Translate('Auftragserfassung');
    'B' : Gv.Alpha.01 # Translate('Bestellerfassung');
    'G' : Gv.Alpha.01 # Translate('Angebotserfassung');
  end;

end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  vM  : int;
end;
begin

  if (aEvt:Obj=gZLList) then begin
    RecRead(gFile,0,_recid,aRecID);
    RETURN true;
  end;

  if (Mode=c_ModeEdit) then RETURN true;

  vM # $dl.Tabelle->wpcurrentint;
  if (vM>=1) and (vM<=12) then begin
    $lb.Monat->wpcaption      # AInt(vM)+'/'+Aint(Con.Jahr);
    $lb.Monat->wpcustom       # AInt(vM);

    $lb.Ist.Menge->wpcaption  # ANum( FldFloat(950,3,vM) ,Set.Stellen.Menge);
    $lb.Ist.Umsatz->wpcaption # ANum( FldFloat(950,6,vM) ,2);
    $lb.Ist.Proz->wpcaption   # ANum( FldFloat(950,9,vM) ,2);

    $lb.Soll.DB->wpcaption    # ANum( FldFloat(950,11,vM) ,2);
    $lb.Ist.DB->wpcaption     # ANum( FldFloat(950,12,vM) ,2);
    $lb.Sim.DB->wpcaption     # ANum( FldFloat(950,13,vM) ,2);

    $ed.Soll.Menge->wpcaptionfloat  # FldFloat(950,2,vM);
    $ed.Sim.Menge->wpcaptionfloat   # FldFloat(950,4,vM);
    $ed.Soll.Umsatz->wpcaptionfloat # FldFloat(950,5,vM);
    $ed.Sim.Umsatz->wpcaptionfloat  # FldFloat(950,7,vM);
    $ed.Soll.Proz->wpcaptionfloat   # FldFloat(950,8,vM);
    $ed.Sim.Proz->wpcaptionfloat    # FldFloat(950,10,vM);
    end
  else begin
    $lb.Monat->wpcaption            # '';
    $lb.Ist.Menge->wpcaption        # '';
    $lb.Ist.Umsatz->wpcaption       # '';
    $lb.Ist.Proz->wpcaption         # '';
    $lb.Ist.DB->wpcaption           # '';
    $lb.Soll.DB->wpcaption          # '';
    $lb.Sim.DB->wpcaption           # '';
    $ed.Soll.Menge->wpcaptionfloat  # 0.0;
    $ed.Sim.Menge->wpcaptionfloat   # 0.0;
    $ed.Soll.Umsatz->wpcaptionfloat # 0.0;
    $ed.Sim.Umsatz->wpcaptionfloat  # 0.0;
    $ed.Soll.Proz->wpcaptionfloat   # 0.0;
    $ed.Sim.Proz->wpcaptionfloat    # 0.0;
  end;

end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  Lib_GuiCom:RememberList($dl.Tabelle);

  Lib_GuiCom2:CloseAllChilds(aEvt:obj);
  
  RETURN true;
end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : int;      // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph
) : logic;
begin

  if ((aButton & _WinMouseDouble)>0) and
    ((aButton & _WinMouseLeft)>0) then begin
    Edit($dl.Tabelle->wpcurrentint);
  end;

  RETURN(true);
end;


//========================================================================
//  EvtKeyItem
//
//========================================================================
sub EvtKeyItem(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView
) : logic;
begin
  if (aKey=_WinKeyReturn) then begin
    Edit($dl.Tabelle->wpcurrentint);
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub ScaleObjects(aReset : logic)
local begin
  vFont : font;
  vI    : int;
  vHdl  : int;
  vY    : int;
  vH    : int;
end;
begin

_app->wpLockAreaSize # true;

//  if (aReset) then RETURN;
  vFont # $lbMonat1->wpFont;//$dl.Tabelle->wpFont;
  vY    # $lbMonat1->wpAreaTop;
  vH    # vFont:Size / 5;
//  vFont:Size # 130; 279   -305= 25
//debug('font:'+aint(vFont:Size));
//  vFont:Size # 20 * 10;
  $dl.Tabelle->wpFont # vFont;
  FOR vI # 2
  LOOP inc(vI)
  WHILE (vI<=13) do begin
    vY # vY + vH;
    vHdl # Winsearch(gMDI,'lbMonat'+aint(vI));
    if (vHdl<>0) then begin
      vHdl->wpAreaTop # vY;
//debug(aint(vY));
    end;
  END;

_app->wpLockAreaSize # false;
  
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edCon.Adressnummer') AND (aBuf->Con.Adressnummer<>0)) then begin
    RekLink(100,950,1,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edCon.Auftragsart') AND (aBuf->Con.Auftragsart<>0)) then begin
    RekLink(110,950,7,0);   // Auftragsart holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edCon.Vertreternr') AND (aBuf->Con.Vertreternr<>0)) then begin
    RekLink(100,950,2,0);   // Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edCon.Warengruppe') AND (aBuf->Con.Warengruppe<>0)) then begin
    RekLink(819,950,3,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('WGr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edCon.Artikelnummer') AND (aBuf->Con.Artikelnummer<>'')) then begin
    RekLink(250,950,5,0);   // Artieklnummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edCon.Artikelgruppe') AND (aBuf->Con.Artikelgruppe<>0)) then begin
    RekLink(826,950,4,0);   // Artikelgruppe holen
    Lib_Guicom2:JumpToWindow('AGr.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
