@A+
//==== Business-Control ==================================================
//
//  Prozedur    Msl_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  17.08.2010  AI  Ermittlung in MSL_Data ausgelagert
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  23.07.2013  ST  Rechte für Excel Im-/Export hinzugefügt
//  23.06.2016  AH  Kopierfunktion
//  07.12.2016  ST  Bugfix: Gütenauswahl
//  2022-06-28  AH  ERX
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusWgrVon()
//    SUB AusWgrBis()
//    SUB AusMSVon()
//    SUB AusMSBis()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusAFOben()
//    SUB AusAFUnten()
//    SUB AusKunde()
//    SUB AusLieferant()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Strukturliste'
  cFile :     220
  cMenuName : 'Msl.Bearbeiten'
  cPrefix :   'Msl'
  cZList :    $ZL.MSL
  cKey :      1
end;

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

Lib_Guicom2:Underline($edMSL.von.Warengruppe);
Lib_Guicom2:Underline($edMSL.von.Status);
Lib_Guicom2:Underline($edMSL.Guetenstufe);
Lib_Guicom2:Underline($edMSL.Guete);
Lib_Guicom2:Underline($edMSL.AF.Oben);
Lib_Guicom2:Underline($edMSL.AF.Unten);;
Lib_Guicom2:Underline($edMSL.bis.Warengruppe);
Lib_Guicom2:Underline($edMSL.bis.Status);
Lib_Guicom2:Underline($edMSL.Kundennr);
Lib_Guicom2:Underline($edMSL.Lieferantennr);


  SetStdAusFeld('edMSL.von.Warengruppe' ,'WgrVon');
  SetStdAusFeld('edMSL.bis.Warengruppe' ,'WgrBis');
  SetStdAusFeld('edMSL.von.Status'      ,'MSVon');
  SetStdAusFeld('edMSL.bis.Status'      ,'MSBis');
  SetStdAusFeld('edMSL.Guetenstufe'     ,'Guetenstufe');
  SetStdAusFeld('edMSL.Guete'           ,'Güte');
  SetStdAusFeld('edMSL.AF.Oben'         ,'AF.Oben');
  SetStdAusFeld('edMSL.AF.Unten'        ,'AF.Unten');
  SetStdAusFeld('edMSL.Kundennr'        ,'Kunde');
  SetStdAusFeld('edMSL.Lieferantennr'   ,'Lieferant');
  SetStdAusFeld('edMSL.Preis.MEH'       ,'MEH');

  App_Main:EvtInit(aEvt);
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
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  $lb.Nummer->wpcaption # aint(MSL.Nummer);

  // Ausführung ??
  $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  // Währung
  $lb.HW1->wpcaption # "Set.Hauswährung.Kurz";

  // Ergebnissumme der Strukturliste
  if (aName='') or (aName='Summen') then begin
   $lb.Sum.Stueckzahl->WinUpdate(_WinUpdFld2Obj);
   $lb.Sum.Gewicht->WinUpdate(_WinUpdFld2Obj);
   $lb.Sum.von.Preis->WinUpdate(_WinUpdFld2Obj);
   $lb.Sum.bis.Preis->WinUpdate(_WinUpdFld2Obj);
   $lb.Sum.Wert->WinUpdate(_WinUpdFld2Obj);

   if ("MSL.Sum.Stückzahl" <> 0) then
     $lb.Sum.Mittel->wpcaption # ANum(MSL.Sum.Wert / CnvFI("MSL.Sum.Stückzahl"),2);
   else
     $lb.Sum.Mittel->wpcaption # '0';

  end;

  // von-/bis-Felder
  if (aName='') or (aName='edMSL.von.Warengruppe') then begin
    Erx # RecLink(819,220,3,0);
    if (Erx<=_rLocked) then
      $Lb.WgrVon->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.WgrVon->wpcaption # '';
  end;

  if (aName='') or (aName='edMSL.bis.Warengruppe') then begin
    Erx # RecLink(819,220,4,0);
    if (Erx<=_rLocked) then
      $Lb.WgrBis->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.WgrBis->wpcaption # '';
  end;

  if (aName='') or (aName='edMSL.von.Status') then begin
    Erx # RecLink(820,220,6,0);
    if (Erx<=_rLocked) then
      $Lb.MatStatVon->wpcaption # Mat.Sta.Bezeichnung
    else
      $Lb.MatStatVon->wpcaption # '';
  end;

  if (aName='') or (aName='edMSL.bis.Status') then begin
    Erx # RecLink(820,220,7,0);
    if (Erx<=_rLocked) then
      $Lb.MatStatBis->wpcaption # Mat.Sta.Bezeichnung
    else
      $Lb.MatStatBis->wpcaption # '';
  end;

  // REMOVE
  /*
  if (aName='') or (aName='edMSL.ObfNr') then begin
    Erx # RecLink(841,220,5,0);
    if (Erx<=_rLocked) then
      $Lb.Obf->wpcaption # Obf.Bezeichnung.L1
    else
      $Lb.Obf->wpcaption # '';
  end;
  */

  if (aName='') or (aName='edMSL.Kundennr') then begin
    Erx # RecLink(100,220,1,0);
    if (Erx<=_rLocked) and (Msl.Kundennr<>0) then
      $Lb.Kunde->wpcaption # Adr.Stichwort
    else
      $Lb.Kunde->wpcaption # '';
  end;

  if (aName='') or (aName='edMSL.Lieferantennr') then begin
    Erx # RecLink(100,220,2,0);
    if (Erx<=_rLocked) and (Msl.Lieferantennr<>0) then
      $Lb.Lieferant->wpcaption # Adr.Stichwort
    else
      $Lb.Lieferant->wpcaption # '';
  end;

  // leere 'bis'-Felder vorbelegen
  if (MSL.bis.Warengruppe = 0) and (MSL.von.Warengruppe <> 0) then begin
    MSL.bis.Warengruppe # MSL.von.Warengruppe;
    $edMSL.von.Warengruppe->WinUpdate(_WinUpdFld2Obj);
    RefreshIfm('edMSL.bis.Warengruppe');
  end;

  if (MSL.bis.Status = 0) and (MSL.von.Status <> 0) then begin
    MSL.bis.Status # MSL.von.Status;
    $edMSL.von.Status->WinUpdate(_WinUpdFld2Obj);
    RefreshIfm('edMSL.bis.Status');
  end;

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
begin

  if (w_AppendNr<>0) then begin
    MSL.Nummer # w_AppendNr;
    RecRead(220,1,0);
    w_AppendNr # 0;
    "MSL.Sum.Stückzahl"   # 0;
    MSL.Sum.Gewicht       # 0.0;
    MSL.Sum.Wert          # 0.0;
    MSL.Min.Preis         # 0.0;
    MSL.Max.Preis         # 0.0;
    MSL.Ermittlung.Datum  # 0.0.0;
    MSL.Ermittlung.Zeit   # 0:0;
    MSL.Ermittlung.User   # '';
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edMSL.Nummer->WinFocusSet(true);

  // Währung setzen
  $lb.HW1->wpcaption # "Set.Hauswährung.Kurz";
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    Msl.Anlage.Datum  # Today;
    Msl.Anlage.Zeit   # Now;
    Msl.Anlage.User   # gUserName;
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
begin

  if (aEvt:obj->wpName='edMSL.Guete') and ($edMSL.Guete->wpchanged) then begin
    MQu_Data:Autokorrektur(var "MSL.Güte");
    $edMSL.Guete->Winupdate();
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

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
  vA      : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
end;

begin

  case aBereich of

    'WgrVon' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgrVon');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'WgrBis' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgrBis');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MSVon' : begin
      RecBufClear(820);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mst.Verwaltung',here+':AusMSVon');
      Lib_GuiCom:RunChildWindow(gMDI);
      gMdi->WinUpdate(_WinUpdOn);
    end;


    'MSBis' : begin
      RecBufClear(820);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mst.Verwaltung',here+':AusMSBis');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Güte' : begin
      RecBufClear(832);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "MSL.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guetenstufe' : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Oben' : begin
      RecBufClear(221);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.AF.Verwaltung',here+':AusAFOben');
      VarInstance(WindowBonus, cnvIA(gMDI->wpCustom));
      vFilter # RecFilterCreate(221, 1);
      vFilter->RecFilterAdd(1, _fltAND, _fltEq, MSL.Nummer);
      vFilter->RecFilterAdd(2, _fltAND, _fltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Unten' : begin
      RecBufClear(221);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.AF.Verwaltung',here+':AusAFUnten');
      VarInstance(WindowBonus, cnvIA(gMDI->wpCustom));
      vFilter # RecFilterCreate(221, 1);
      vFilter->RecFilterAdd(1, _fltAND, _fltEq, MSL.Nummer);
      vFilter->RecFilterAdd(2, _fltAND, _fltEq, '2');
      gZLlist->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edMSL.Preis.MEH,220,1,17);
    end;

  end;

end;


//========================================================================
//  AusWgrVon
//
//========================================================================
sub AusWgrVon()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    MSL.von.Warengruppe # Wgr.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edMSL.von.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMSL.von.Warengruppe');
end;


//========================================================================
//  AusWgrBis
//
//========================================================================
sub AusWgrBis()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    MSL.bis.Warengruppe # Wgr.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edMSL.bis.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMSL.bis.Warengruppe');
end;


//========================================================================
//  AusMSVon
//
//========================================================================
sub AusMSVon()
begin
  if (gSelected<>0) then begin
    RecRead(820,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    MSL.von.Status # Mat.Sta.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edMSL.von.Status->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMSL.von.Status');
end;


//========================================================================
//  AusMSBis
//
//========================================================================
sub AusMSBis()
begin
  if (gSelected<>0) then begin
    RecRead(820,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    MSL.bis.Status # Mat.Sta.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edMSL.bis.Status->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMSL.bis.Status');
end;


//========================================================================
//  AusGüte
//
//========================================================================
sub AusGuete()
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);

    gSelected # 0;
    // Feldübernahme
    if ("MQu.ErsetzenDurch"<>'') then
      "MSL.Güte" # "MQu.ErsetzenDurch"
    else if ("MQu.Güte1"<>'') then
      "MSL.Güte" # "MQu.Güte1"
    else
      "MSL.Güte" # "MQu.Güte2";
   end;
  // Focus auf Editfeld setzen:
  //$edMsl.Guete->WinUpdate(_WinUpdFld2Obj);
  $edMSL.Guete->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('');
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "MSL.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edMSL.Guetenstufe->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
local begin
  vAF : alpha(100);
end;
begin
  gSelected # 0;

  "MSL.Ausführung.Oben" # Obf_Data:BildeAFString(220,'1');

  // Focus auf Editfeld setzen:
  $edMSL.AF.Oben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
local begin
  vAF : alpha(100);
end;
begin
  gSelected # 0;

  "MSL.Ausführung.Unten" # Obf_Data:BildeAFString(220,'2');

  // Focus auf Editfeld setzen:
  $edMSL.AF.Unten->Winfocusset(true);
end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    MSL.Kundennr # Adr.Kundennr;
   end;
  // Focus auf Editfeld setzen:
  $edMSL.Kundennr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMSL.Kundennr');
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    MSL.Lieferantennr # Adr.Lieferantennr;
   end;
  // Focus auf Editfeld setzen:
  $edMSL.Lieferantennr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMSL.Lieferantennr');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Msl_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Msl_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode)  or (Rechte[Rgt_Msl_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Msl_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode)  or (Rechte[Rgt_Msl_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Msl_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_MSL_Anlegen]=n);


  vHdl # gMdi->WinSearch('Mnu.Berechnen');
  if (vHdl <> 0) then begin;
    if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
      vHdl->wpDisabled # true;
    else
      vHdl->wpDisabled # false;
  end;


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Msl_Excel_Export]=false;

  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Msl_Excel_Import]=false;


  $bt.BErechnen->wpdisabled # (Mode<>c_ModeView);

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Copy' : begin
      w_AppendNr # MSL.Nummer;
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


   'Mnu.Mark.Sel' : begin
      MSL_Mark_Sel();
    end;


    'Mnu.Berechnen' : begin
      MSL_Data:StrukturBerechnen();
      RefreshIfm('Summen');
      Msg(999998,'',0,0,0);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Msl.Anlage.Datum, Msl.Anlage.Zeit, Msl.Anlage.User);
    end;

  end; // case

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (aEvt:OBj->wpname='bt.Berechnen') then begin
    MSL_data:StrukturBerechnen();
    RefreshIfm('Summen');
    Msg(999998,'',0,0,0);
    RETURN true;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.WgrVon'       : Auswahl('WgrVon');
    'bt.WgrBis'       : Auswahl('WgrBis');
    'bt.MSVon'        : Auswahl('MSVon');
    'bt.MSBis'        : Auswahl('MSBis');
    'bt.Guete'        : Auswahl('Güte');
    'bt.Guetenstufe'  : Auswahl('Guetenstufe');
    'bt.AFOben'       : Auswahl('AF.Oben');
    'bt.AFUnten'      : Auswahl('AF.Unten');
    'bt.Kunde'        : Auswahl('Kunde');
    'bt.Lieferant'    : Auswahl('Lieferant');
    'bt.Meh'          : Auswahl('MEH');
  end;

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
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbMSL.EinkaufYN') then begin
    $cbMSL.VerkaufYN->wpCheckState # _WinStateChkUnchecked;
    $cbMSL.MaterialYN->wpCheckState # _WinStateChkUnchecked;

    MSL.EinkaufYN # true;
    MSL.VerkaufYN # false;
    MSL.MaterialYN # false;
  end;

  if (aEvt:Obj->wpname='cbMSL.VerkaufYN') then begin
    $cbMSL.EinkaufYN->wpCheckState # _WinStateChkUnchecked;
    $cbMSL.MaterialYN->wpCheckState # _WinStateChkUnchecked;

    MSL.EinkaufYN # false;
    MSL.VerkaufYN # true;
    MSL.MaterialYN # false;
  end;

  if (aEvt:Obj->wpname='cbMSL.MaterialYN') then begin
    $cbMSL.EinkaufYN->wpCheckState # _WinStateChkUnchecked;
    $cbMSL.VerkaufYN->wpCheckState # _WinStateChkUnchecked;

    MSL.EinkaufYN # false;
    MSL.VerkaufYN # false;
    MSL.MaterialYN # true;
  end;

    /*if ($cb.Artikel->wpCheckstate=_WinStateChkChecked) then begin
      $cb.Arbeitsgang->wpCheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpCheckstate # _WinStateChkUnChecked;*/

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
//  Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edMSL.von.Warengruppe') AND (aBuf->MSL.von.Warengruppe<>0)) then begin
    RekLink(819,220,3,0);   // Warengruppe von holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMSL.von.Status') AND (aBuf->MSL.von.Status<>0)) then begin
    RekLink(820,220,6,0);   // Materialstatus holen
    Lib_Guicom2:JumpToWindow('Mst.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMSL.Guetenstufe') AND (aBuf->"MSL.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "MSL.Gütenstufe";
    RecRead(848,1,0);
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMSL.Guete') AND (aBuf->"MSL.Güte"<>'')) then begin
    "MQu.Güte1" # "MSL.Güte";
    RecRead(832,2,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMSL.bis.Warengruppe') AND (aBuf->MSL.bis.Warengruppe<>0)) then begin
    RekLink(819,220,4,0);   // Warengruppe bis holen
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMSL.bis.Status') AND (aBuf->MSL.bis.Status<>0)) then begin
    RekLink(820,220,7,0);   // Status bis holen
    Lib_Guicom2:JumpToWindow('Mst.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMSL.Kundennr') AND (aBuf->MSL.Kundennr<>0)) then begin
    RekLink(100,220,1,0);   // Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edMSL.Lieferantennr') AND (aBuf->MSL.Lieferantennr<>0)) then begin
    RekLink(100,220,2,0);   // lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
