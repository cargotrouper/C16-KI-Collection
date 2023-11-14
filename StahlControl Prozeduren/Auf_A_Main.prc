@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_A_Main
//                  OHNE E_R_G
//  Info
//
//
//  30.03.2004  AI  Erstellung der Prozedur
//  30.09.2010  AI  Gutschrift/Belastung kann EK-Wert ändern (VB)
//  10.02.2012  AI  NEU: Menü Info.Vorgang
//  30.08.2012  AT  EvtListDataInit Umstellung auf Materialnr/Artikelnummer  (1326/287)
//  24.10.2013  AH  BA_S ist nicht berechenbar (Projekt 1326/373)
//  31.07.2014  ST  Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  14.08.2014  AH  Prüfung auf Abschlussdatum dekativiert
//  04.02.2015  ST  MenuCmd "MatVsbReset" hinzugefügt Projekt 1507/54
//  24.06.2015  AH  Druck anzeigen
//  25.08.2015  AH  Gut/Bel belegt Menge vor
//  04.09.2015  AH  VSB-Aktionen können manuell storniert werden
//  13.01.2016  AH  Fix: Rechungsmenge bei Gut/Bel richtig rechnen
//  04.09.2017  ST  Afx "Auf.A.EvtLstDataInit" hinzugefügt
//  19.04.2018  ST  Afx "Auf.A.DokAnzeigen" hinzugefügt
//  28.05.2018  ST  AFX "Auf.A.Init.Pre" und "Auf.A.Init" hinzugefügt
//  28.05.2018  ST  AFX "Auf.A.JumpTo" hinzugefügt
//  04.04.2022  AH  ERX
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
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle        : 'Aktionen'
  cFile         : 404
  cMenuName     : 'Auf.A.Bearbeiten'
  cPrefix       : 'Auf_A'
  cZList        : $ZL.Auf.Aktionen
  cKey          : 1
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

  if (Auf.P.MEH.Einsatz=Auf.P.MEH.Preis) then
    $clmAuf.A.Menge.Preis->wpVisible # n
  else
    $clmAuf.A.Menge.Preis->wpcaption # Translate('Menge')+' '+Auf.P.MEH.Preis;

  RunAFX('Auf.A.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Auf.A.Init',aint(aEvt:Obj));
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN; // Pflichtfelder
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
  Lib_GuiCom:Pflichtfeld($edAuf.A.Aktionsdatum);
  Lib_GuiCom:Pflichtfeld($edAuf.A.TerminStart);
  Lib_GuiCom:Pflichtfeld($edAuf.A.TerminEnde);
//  Lib_GuiCom:Pflichtfeld($edAuf.A.Rechnungsdatum);

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vHdl  : int;
  Erx   : int;
end;
begin
  if (Auf.Vorgangstyp=c_BOGUT) or
    (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or
    (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then
    $NB.Sub->wpcurrent(_WinFlagNoFocusSet) # 'NB.Sub2'
  else
    $NB.Sub->wpcurrent(_WinFlagNoFocusSet) # 'NB.Sub1';

  if (aName='') then begin

    if (Auf.A.AktionsTyp=c_akt_Kasse) then
      $edAuf.A.Menge->wpdecimals # 2
    else
      $edAuf.A.Menge->wpdecimals # Set.Stellen.Menge;

    // Adresse
    Erx # RecLink(100,404,2,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Adresse->wpcaption # Adr.Stichwort
    else
      $Lb.Adresse->wpcaption # '';

    // Artikel
    Erx # RecLink(250,404,3,_RecFirst);
    if (Erx<=_rLocked) and (Auf.A.ArtikelNr<>'') then
      $Lb.Artikel->wpcaption # Art.Nummer
    else
      $Lb.Artikel->wpcaption # '';

    if (Auf.A.Materialnr<>0) then
      $Lb.Material->wpcaption # AInt(Auf.A.MaterialNr)
    else
      $Lb.Material->wpcaption # '';

    // Artikel-Charge
    $Lb.Charge->wpcaption # Auf.A.Charge

    $Lb.MEH->wpcaption # Auf.A.MEH;
    $Lb.MEH_Gut->wpcaption # Auf.A.MEH;
    $Lb.MEH.Preis->wpcaption # Auf.A.MEH.Preis;
    $lb.EK_HW->wpcaption # "Set.Hauswährung.Kurz";
    $lb.VK_HW2->wpcaption # "Set.Hauswährung.Kurz";
    $lb.VK_HW->wpcaption # "Set.Hauswährung.Kurz";
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
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
  Erx : int;
end;
begin

  // Focus setzen auf Feld:
  $edAuf.A.TerminStart->WinFocusSet(true);

  if (Mode=c_ModeEdit) then begin
    //Lib_GuiCom:Enable($edAuf.A.Rechnungsnr);
    //Lib_GuiCom:Enable($edAuf.A.Rechnungsdatum);
    Lib_GuiCom:Enable($edAuf.A.RechPreisW1);
    Lib_GuiCom:Enable($edAuf.A.EKPreisSummeW1);
    Lib_GuiCom:Enable($edAuf.A.interneKostW1);
  end;

  if (Mode=c_ModeNew) then begin
    recbufClear(404);
    Erx # RecLink(100,401,4,_Recfirst);   // Kunde holen...
    Auf.A.Nummer      # Auf.P.Nummer;
    Auf.A.Position    # Auf.P.Position;
    Auf.A.Aktion      # 1;
    Auf.A.MEH           # Auf.P.MEH.Preis;
    Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
    Auf.A.Artikelnr     # Auf.P.Artikelnr;
    //Aufx.A.Adressnummer  # Adr.Nummer;
    Auf.A.TerminStart   # today;
    Auf.A.TerminEnde    # today;
    Auf.A.Aktionsdatum  # today;

    if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin
      Auf.A.Aktionstyp  # c_Akt_DFaktGut;
      Auf.A.MEH.Preis   # Auf.P.MEH.Preis;
      //  13.01.2016 AH
//      Auf.A.Menge       # Auf.P.Menge;
      if (Auf.A.MEH.Preis=Auf.P.MEH.Wunsch) then
        Auf.A.Menge # Auf.P.Menge.Wunsch
      else
        Auf.A.Menge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
    end
    else if (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then begin
      Auf.A.Aktionstyp  # c_Akt_DFaktBel;
      Auf.A.MEH.Preis   # Auf.P.MEH.Preis;
    end
    else
      Auf.A.Aktionstyp  # 'MAN';
  end;

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
  If (Auf.A.MEH='') then begin
    Msg(001200,Translate('MEH'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.Aktionsdatum->WinFocusSet(true);
    RETURN false;
  end;

  If (Auf.A.Aktionsdatum=0.0.0) then begin
    Msg(001200,Translate('Aktionsdatum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.Aktionsdatum->WinFocusSet(true);
    RETURN false;
  end;

  If (Auf.A.TerminStart=0.0.0) then begin
    Msg(001200,Translate('Starttermin'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.TerminStart->WinFocusSet(true);
    RETURN false;
  end;

  If (Auf.A.TerminEnde=0.0.0) then begin
    Msg(001200,Translate('Endtermin'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.TerminEnde->WinFocusSet(true);
    RETURN false;
  end;
/*
  if (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false) then begin
    Msg(001400,Translate('Aktionsdatum') + '|'+ CnvAd(Auf.A.Aktionsdatum),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.Aktionsdatum->WinFocusSet(true);
    RETURN false;
  end;

  if (Lib_Faktura:Abschlusstest(Auf.A.TerminStart) = false) then begin
    Msg(001400,Translate('Starttermin') + '|'+ CnvAd(Auf.A.TerminStart),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.TerminStart->WinFocusSet(true);
    RETURN false;
  end;

  if (Lib_Faktura:Abschlusstest(Auf.A.TerminEnde) = false) then begin
    Msg(001400,Translate('Endtermin') + '|'+ CnvAd(Auf.A.TerminEnde),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.A.TerminEnde->WinFocusSet(true);
    RETURN false;
  end;
*/


  // Gutschrift?
  if (Auf.A.Aktionstyp=c_Akt_DFaktGut) then begin
    if (Auf.A.Menge>0.0) then Auf.A.Menge # (-1.0) * Auf.A.Menge;
    if (Auf.A.Menge.Preis>0.0) then Auf.A.Menge.Preis # (-1.0) * Auf.A.Menge.Preis;
    if ("Auf.A.Stückzahl">0) then "Auf.A.Stückzahl" # (-1) * "Auf.A.Stückzahl";
    if (Auf.A.Gewicht>0.0) then Auf.A.Gewicht # (-1.0) * Auf.A.Gewicht;
    if (Auf.A.NettoGewicht>0.0) then Auf.A.NettoGewicht # (-1.0) * Auf.A.NettoGewicht;
    if (Auf.P.PEH<>0) and ("Auf.A.RückEinzelEKW1"<>0.0) and (Auf.A.Menge<>0.0) and (Auf.A.EKPReisSummeW1=0.0) then
      Auf.A.EKPreisSummeW1  # Rnd("Auf.A.RückEinzelEKW1" * Auf.A.Menge / cnvfi(Auf.P.PEH),2);
    if (Auf.A.MEH=Auf.A.MEH.Preis) then
      Auf.A.Menge.Preis # Auf.a.Menge;
  end;
  // Belastung?
  if (Auf.A.Aktionstyp=c_Akt_DFaktBel) then begin
    if (Auf.A.Menge<0.0) then Auf.A.Menge # (-1.0) * Auf.A.Menge;
    if (Auf.A.Menge.Preis<0.0) then Auf.A.Menge.Preis # (-1.0) * Auf.A.Menge.Preis;
    if ("Auf.A.Stückzahl"<0) then "Auf.A.Stückzahl" # (-1) * "Auf.A.Stückzahl";
    if (Auf.A.Gewicht<0.0) then Auf.A.Gewicht # (-1.0) * Auf.A.Gewicht;
    if (Auf.A.NettoGewicht<0.0) then Auf.A.NettoGewicht # (-1.0) * Auf.A.NettoGewicht;
    if (Auf.P.PEH<>0) and (Auf.A.EKPReisSummeW1=0.0) then
      Auf.A.EKPreisSummeW1  # Rnd("Auf.A.RückEinzelEKW1" * Auf.A.Menge / cnvfi(Auf.P.PEH),2);
    if (Auf.A.MEH=Auf.A.MEH.Preis) then
      Auf.A.Menge.Preis # Auf.a.Menge;
  end;

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
    Auf.A.Anlage.Datum  # Today;
    Auf.A.Anlage.Zeit   # Now;
    Auf.A.Anlage.User   # gUserName;
    Erx # Auf_A_Data:NeuAnlegen(n);
    if (erx<>_ROK) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  if (Auf_A_Data:RecalcAll()=false) then begin
    ErrorOutput;
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RecRead(gFile,0,0,gZLList->wpdbrecid);

  if (Auf.A.Rechnungsnr<>0) then RETURN;

/*
  if (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false) then begin
    Msg(001400,Translate('Aktionsdatum') + '|'+ CnvAd(Auf.A.Aktionsdatum),0,0,0);
    RETURN;
  end;

  if (Lib_Faktura:Abschlusstest(Auf.A.TerminStart) = false) then begin
    Msg(001400,Translate('Starttermin') + '|'+ CnvAd(Auf.A.TerminStart),0,0,0);
    RETURN ;
  end;

  if (Lib_Faktura:Abschlusstest(Auf.A.TerminEnde) = false) then begin
    Msg(001400,Translate('Endtermin') + '|'+ CnvAd(Auf.A.TerminEnde),0,0,0);
    RETURN;
  end;
*/

  if (Auf.A.Aktionstyp=c_Akt_DFAkt) and ("Auf.A.Löschmarker"='*') then begin
    Msg(404000,'',0,0,0);
    RETURN;
  end;

  Auf_A_Data:ToggleLoeschmarker();

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
begin
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl  : int;
  vOK   : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or (vHdl->wpDisabled) or (Rechte[Rgt_Auf_A_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or (vHdl->wpDisabled) or (Rechte[Rgt_Auf_A_Anlegen]=n);



  if (Auf.A.Rechnungsnr=0) then begin
    vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (w_Context='ABLAGE') or (vHdl->wpDisabled) or
                                                 (Rechte[Rgt_Auf_A_Aendern]=n) or
                                                 (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false);
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (w_Context='ABLAGE') or (vHdl->wpDisabled) or
                                                 (Rechte[Rgt_Auf_A_Aendern]=n) or
                                                 (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false);
  end
  else begin
    vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (w_Context='ABLAGE') or (vHdl->wpDisabled) or
                                                 (Rechte[Rgt_Auf_A_Aendern2]=n) or
                                                 (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false);
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (w_Context='ABLAGE') or (vHdl->wpDisabled) or (Rechte[Rgt_Auf_A_Aendern2]=n) or
                                                 (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false);
  end;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or
                      (vHdl->wpDisabled) or (Rechte[Rgt_Auf_A_Loeschen]=n) or
                      (Auf.A.Aktionstyp=C_Akt_Storniert) or
                      (Auf.A.Aktionstyp=c_Akt_LFS) or (Auf.A.Aktionstyp=c_AKT_StornoLFS) or
                      (Auf.A.Aktionstyp=c_Akt_VSB) or /*(Auf.A.Aktionstyp=c_AKT_StornoVSB) or*/
                      (Auf.A.Aktionstyp=c_Akt_DFAKT) or (Auf.A.Aktionstyp=c_AKT_StornoDFAKT) or
                      (Auf.A.Aktionstyp=c_Akt_Sperre) or (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or
                      (vHdl->wpDisabled) or (Rechte[Rgt_Auf_A_Loeschen]=n) or
                      (Auf.A.Aktionstyp=C_Akt_Storniert) or
                      (Auf.A.Aktionstyp=c_Akt_LFS) or (Auf.A.Aktionstyp=c_AKT_StornoLFS) or
                      (Auf.A.Aktionstyp=c_Akt_VSB) or /*(Auf.A.Aktionstyp=c_AKT_StornoVSB) or*/
                      (Auf.A.Aktionstyp=c_Akt_DFAKT) or (Auf.A.Aktionstyp=c_AKT_StornoDFAKT) or
                      (Auf.A.Aktionstyp=c_Akt_Sperre) or (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false);

  vHdl # gMenu->WinSearch('Mnu.RecalcPos');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE');


  vHdl # gMenu->WinSearch('Mnu.Berechnen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or
                      (Auf.PAbrufYN) or
                      ((Mode<>c_ModeList) and (mode<>c_ModeView)) or (Rechte[Rgt_Auf_A_Berechnen]=n) or
                      ("Auf.P.Löschmarker"='*');

  vHdl # gMenu->WinSearch('Mnu.Storno');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or
                      ((Mode<>c_ModeList) and (mode<>c_ModeView)) or (Rechte[Rgt_Auf_A_Storno]=n) or
                      ((Auf.A.Aktionstyp<>c_Akt_VSB) and (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false)) or
                      ((Auf.A.Aktionstyp<>c_Akt_VSB) and (Auf.A.Aktionstyp<>c_Akt_DFAKT) );
                      // ( (Auf.A.Aktionstyp<>c_Akt_LFS) and (Auf.A.Aktionstyp<>c_Akt_VSB) and (Auf.A.Aktionstyp<>c_Akt_DFAKT) ); // LFS herausgenommen 2015-02-09 TM
  vHdl # gMenu->WinSearch('Mnu.Kommission');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or
      ((Mode<>c_ModeList) and (mode<>c_ModeView)) or (Rechte[Rgt_Auf_A_Aendern]=n) or
      ("Auf.A.Löschmarker"='*') or (Auf.A.Aktionstyp<>c_Akt_LFS) or ("Auf.P.Löschmarker"='*');

  vHdl # gMenu->WinSearch('Mnu.Sperre');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (w_Context='ABLAGE') or
                      ((Mode<>c_ModeList) and (mode<>c_ModeView)) or (Rechte[Rgt_Auf_A_Sperre]=n) or
                      (Auf.A.Aktionstyp<>c_Akt_Sperre);
  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Auf_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Auf_Excel_Import]=false;

  vOK # (Rechte[Rgt_BAG]) and (
        (Auf.A.Aktionstyp=c_Akt_BA           ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Plan      ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Plan_Fahr ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Fertig    ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Ausfall   ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Einsatz   ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Rest      ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Kosten    ) or
        (Auf.A.Aktionstyp=c_Akt_BA_UmlagePLUS) or
        (Auf.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or
        (Auf.A.Aktionstyp=c_Akt_BA_Verbrauch ) or
        (Auf.A.Aktionstyp=c_Akt_BA_Beistell  ));
  vOK # vOK or
        ((Rechte[Rgt_Einkauf]) and
        (Auf.A.Aktionstyp=c_Akt_Bestellung));
  vHdl # gMenu->WinSearch('Mnu.Info.Vorgang');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (!vOK) or ((mode<>c_ModeList) and (Mode<>c_ModeView));

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
  Erx         : int;
  vHdl        : int;
  vMode       : alpha;
  vParent     : int;
  vFilter     : int;
  vPos        : int;
  vPos1       : int;
  vBuf404     : int;
  vDokTyp     : alpha;
  vDokDatei   : int;
  vDokFilter  : alpha;
  vBuf        : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Info.Vorgang' : begin
      if ((Auf.A.Aktionstyp=c_Akt_BA           ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Plan      ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Plan_Fahr ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Fertig    ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Ausfall   ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Einsatz   ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Rest      ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Kosten    ) or
          (Auf.A.Aktionstyp=c_Akt_BA_UmlagePLUS) or
          (Auf.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or
          (Auf.A.Aktionstyp=c_Akt_BA_Verbrauch ) or
          (Auf.A.Aktionstyp=c_Akt_BA_Beistell  )) and
          (Rechte[Rgt_BAG]) then
          BA1_Subs:ShowAufBAG(Auf.A.Aktionsnr,0);

      if (Auf.A.Aktionstyp=c_Akt_Bestellung) and
        (Rechte[Rgt_Einkauf]) then begin

        Erx # RekLink(501,404,13,_recfirst);    // Bestellposition holen
        if (Erx<=_rLocked) then begin
          if (gMdiEin = 0) then begin
            //gFrmMain->wpDisabled # true;
//            gMdiEin # Lib_GuiCom:OpenMdi(gFrmMain, 'Ein.P.Verwaltung', _WinAddHidden);
//            VarInstance(WindowBonus,cnvIA(gMDIEin->wpcustom));
//            w_Command  # 'REPOS';
//            w_Cmd_Para # AInt( RecInfo( 501, _recId ));
//            gMdiEin->WinUpdate(_WinUpdOn);
//            $NB.Main->WinFocusSet(true);
// 25.02.2020 AH : wie JUMPTO
              vBuf # RecBufCreate(501);
              vBuf->Ein.P.Nummer    # Auf.A.Aktionsnr;
              vBuf->Ein.P.Position  # Auf.A.Aktionspos;
              Erx # RecRead(vBuf,1,0);
              if (Erx <= _rLocked) then
                // Bestand
                Ein_P_Main:Start(0, Auf.A.Aktionsnr,Auf.A.Aktionspos ,y);
          end
          else begin
            Lib_GuiCom:RePos(var gMDIEin, 'Ein.P.Verwaltung', RecInfo(501,_recId),n);
            Lib_guiCom:ReOpenMDI(gMDIEin);
          end;
        end;
      end;
    end;


    'Mnu.Sperre' : begin
      if (Rechte[Rgt_Auf_A_Sperre]=n) or (Auf.A.Aktionstyp<>c_Akt_Sperre) then RETURN true;
      Auf_A_Data:SperreUmsetzen();
    end;


    'Mnu.MatVsbReset' : begin
      if (Auf_A_Data:MatVsbReset() = false) then
        ErrorOutput;
    end;


    'Mnu.Kommission' : begin
      if ("Auf.P.Löschmarker"<>'') then RETURN false;
      vPos # 0;
      vPos1 # Auf.P.Position;
      if (Dlg_Standard:Anzahl(Translate('neue Position'), var vPos, vPos)=false) then RETURN false;
      if (vPos=Auf.A.Position) then RETURN false;

      Auf.P.Position # vPos;
      Erx # RecRead(401,1,_RecTest);
      if (Erx<>_rOK) then RETURN false;
      RecLink(401,404,1,_recFirst);   // Ursprungspos. holen


      TRANSON;

      // alte Aktion löschen...
      vBuf404 # RekSave(404);
      if (Auf_A_Data:Entfernen(y)=false) then begin
        RekRestore(vBuf404);
        TRANSBRK;
        RETURN false;
      end;
      // gelöschte Aktion ändern...
      RecRead(404,1,_recLock);
      Auf.A.Aktionstyp  # c_AKT_KLFS;
      Auf.A.Bemerkung   # c_AktBem_KLFS+cnvai(Auf.A.Nummer)+'/'+Cnvai(vPos);
      Erx # RekReplace(404,_recUnlock,'MAN');
      if (Erx<>_rOK) then begin
        RekRestore(vBuf404);
        TRANSBRK;
        RETURN false;
      end;

      RecBufCopy(vBuf404,404);

      // neu Anlegen bei neuer Position...
      Auf.P.Position # vPos;
      RecRead(401,1,0);

      Auf.A.Position # vPos;
      if (Auf_A_Data:NeuAnlegen()<>_rOK) then begin
        RekRestore(vBuf404);
        Auf.P.Position # vPos1;
        RecRead(401,1,0);
        TRANSBRK;
        RETURN false;
      end;

      RekRestore(vBuf404);
      Auf.P.Position # vPos1;
      RecRead(401,1,0);

      TRANSOFF;

      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.RecalcPos' : begin
      if (Auf_A_Data:RecalcAll()=false) then begin
        ErrorOutput;
        RETURN false;
      end;
      Msg(999998,'',0,0,0);
      RETURN true;
    end;


    'Mnu.Storno' : begin
      if ("Auf.P.Löschmarker"<>'') then RETURN false;
      Auf_A_Data:Storno();
      gZLList->WinUpdate(_WinUpdOn, _WinLstFromfirst | _WinLstRecDoSelect);
    end;


    'Mnu.Dok.Anzeigen' : begin
      // 2018-04-19 Prj 1630/5109
      if (RunAFX('Auf.A.DokAnzeigen',Aint(Auf.A.Nummer)+'|' + Aint(Auf.A.Position) + '|' + Aint(Auf.A.Position2) + '|'  + Aint(Auf.A.Aktion)) < 0) then
        RETURN true;

      if (Auf.A.Aktionstyp=c_Akt_LFS) then begin
        vDokTyp     # 'LFS';
        vDokFilter  # 'LFS';
        vDokDatei   # 440;
      end
      else if ((Auf.A.Aktionstyp=c_Akt_Druck) and (Auf.A.Bemerkung=c_AktBem_AB)) then begin
        vDokTyp     # 'AUFBE';
        vDokFilter  # 'AB';
        vDokDatei   # 400;
      end
      else if (Auf.A.Aktionstyp=c_Akt_Anfrage) then begin
        vDokTyp     # 'ANF';
        vDokFilter  # 'ANF';
        vDokDatei   # 540;
      end;

      if (vDokDatei<>0) and (Auf.A.Aktionsnr<>0) then begin
        RecBufClear(915);
        gDokTyp # vDokTyp;
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dok.Verwaltung','');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vFilter # RecFilterCreate(915,1);
        vFilter->RecFilterAdd(1,_FltAND,_FltEq, vDokDatei);
        vFilter->RecFilterAdd(2,_FltAND,_FltEq, vDokFilter);
        vFilter->RecFilterAdd(3,_FltAND,_FltScan, cnvai(Auf.A.Aktionsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8));
        gZLList->wpdbfilter # vFilter;
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Mnu.Dok.Anzeigen.Re' : begin
      if (Auf.A.Rechnungsnr<>0) then begin
        RecBufClear(915);
        gDokTyp # 'RECH';
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dok.Verwaltung','');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vFilter # RecFilterCreate(915,1);
        vFilter->RecFilterAdd(1,_FltAND,_FltEq,450);
        vFilter->RecFilterAdd(2,_FltAND,_FltEq,'RE');
        vFilter->RecFilterAdd(3,_FltAND,_FltScan, cnvai(Auf.A.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8));
        gZLList->wpdbfilter # vFilter;
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Mnu.Berechnen' : begin
      if (Auf.PAbrufYN) then RETURN false;
      if ("Auf.P.Löschmarker"<>'') then RETURN false;
      RecRead(gFile,0,0,gZLList->wpdbrecid);

      // 24.10.2013 AH : Projekt 1326/373
      if (Auf.A.Rechnungsnr=0) and (Auf.A.Aktionstyp=c_Akt_BA_Plan) then begin
        Msg(404005,'',0,0,0);
        RETURN false;
      end;

      TRANSON;

      PtD_Main:Memorize(404);
      RecRead(404,1,_recLock);
      if ("Auf.A.Rechnungsmark"='$') then begin
        "Auf.A.Rechnungsmark" # '';
      end;
      else if (Auf.A.Rechnungsnr=0) then
        "Auf.A.Rechnungsmark" # '$';
      Erx # RekReplace(404,_recUnlock,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(400003,aint(Auf.A.Position),0,0,0);
        RETURN true;
      end;
      PtD_Main:Compare(404);
      if (Auf_A_Data:RecalcAll()=false) then begin
        ErrorOutput;
      end;

      TRANSOFF;

      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Auf.A.Anlage.Datum, Auf.A.Anlage.Zeit, Auf.A.Anlage.User );
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

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.xxxxx' :   Auswahl('...');
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
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  Erx   : int;
  vPEH  : int;
  vA    : alpha;
end;
begin

  if (aMark) then begin
    if (RunAFX('Auf.A.EvtLstDataInit','y' + aEvt:obj->wpName)<0) then RETURN;
  end
  else if (RunAFX('Auf.A.EvtLstDataInit','n' + aEvt:obj->wpName)<0) then RETURN;

  Erx # RecLink(100,404,2,_recFirst);     // Adresse holen
  if (Erx>_rLocked) then RecBufClear(100);

  if (Auf.A.Artikelnr<>'') AND (Auf.A.Materialnr = 0) then begin
    Erx # RecLink(250,404,3,_recFirst);     // Artikel holen
    if (Erx>_rLocked) then RecBufClear(250);
    Gv.Alpha.02 # Art.Stichwort;
  end
  else begin

    if (Auf.A.Materialnr<>0) then begin

      Gv.Alpha.02 # ANum(Auf.A.Dicke,Set.Stellen.Dicke)+' x '+ANum(Auf.A.Breite,Set.Stellen.Dicke);
      if ("Auf.A.Länge"<>0.0) then
        Gv.Alpha.02 # Gv.Alpha.02 + ' x '+ANum("Auf.A.Länge","Set.Stellen.Länge");
    end
    else begin
      Art.Nummer  # '';
      Gv.Alpha.02 # '';
    end;

  end;

  vA # '';
  if (Auf.A.RechpreisW1<>0.0) //then begin
    and (Auf.A.Menge.Preis<>0.0) then begin
      vA # ANum(Auf.A.RechPreisW1 / Auf.A.Menge.Preis * cnvfi(Auf.A.RechPEH),2)
      vA # vA + ' / '+aint(Auf.A.RechPEH)+' '+Auf.A.MEH.Preis;
  end;
  Gv.Alpha.03 # vA;

  Gv.Alpha.01 # Auf.A.Aktionstyp;
  if (Auf.A.Aktionsnr<>0) then    Gv.Alpha.01 # Gv.ALpha.01 + ' ' + AInt(Auf.A.AktionsNr)
  if (Auf.A.Aktionspos<>0) then   Gv.Alpha.01 # Gv.ALpha.01 + '/' + AInt(Auf.A.AktionsPos);
  if (Auf.A.AktionsPos2<>0) then  Gv.Alpha.01 # Gv.ALpha.01 + '/' + AInt(Auf.A.AktionsPos2);


  // Farbe setzen...
  if (aMark=n) then begin
    if ("Auf.A.Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
  end;



  /// ---------------------------------
  // Jumplogik kennzeichnen
  if (Auf.A.Adressnummer <> 0) then
    Lib_GuiCom:ZLQuickJumpInfo($clmAdr.Stichwort);

  if (Auf.A.Rechnungsnr<>0) then
    Lib_GuiCom:ZLQuickJumpInfo($clmAuf.A.Rechnungsnr);

  if (Auf.A.Artikelnr <> '') then
    Lib_GuiCom:ZLQuickJumpInfo($clmArt.Nummer);

  if(Auf.A.Materialnr <> 0) then
    Lib_GuiCom:ZLQuickJumpInfo($clmMat.Nummer);

  if (Auf.A.Aktionsnr <> 0) then begin
    case Auf.A.Aktionstyp of
      c_Akt_VLDAW,
      c_Akt_LFS,
      c_Akt_BA_Plan_Fahr,
      c_Akt_Bestellung,
      c_Akt_BA           ,
      c_Akt_BA_Plan      ,
      c_Akt_BA_Fertig    ,
      c_Akt_BA_Ausfall   ,
      c_Akt_BA_Einsatz   ,
      c_Akt_BA_Rest      ,
      c_Akt_BA_Kosten    ,
      c_Akt_Reklamation : begin Lib_GuiCom:ZLQuickJumpInfo($clmGV.Alpha.01);  end;
    end;
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
begin
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin

  if (Auf.A.Nummer=0) or (gZLList->wpdbrecid=0) then RETURN true;
  RecRead(gFile,0,0,gZLList->wpdbrecid);

/***  07.12.2015
  // AuftragsPos holen
  if (Auf.A.Position<>0) then begin
    Erx # RecLink(401,404,1,_recFirst);
    If (Erx>_rLocked) then begin
      Erx # RecLink(411,404,7,_recFirst);
      If (Erx>_rLocked) then begin
        Msg(404107,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position),0,0,0);
        RETURN false;
      end;
      RETURN true;
    end;
  end;

  // Auftragskopf holen
  Erx # RecLink(400,401,3,_recFirst);
  If (Erx>_rLocked) then begin
    Msg(404105,AInt(Auf.A.Nummer),0,0,0);
    RETURN false;
  end;
**/

/*
  // Position anpassen
  RecRead(401,1,_RecLock);
  Auf_Data:Pos_BerechneMarker();
  Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(404102,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position),0,0,0);
    RETURN false;
  end;

  // Kopf anpassen
  RecRead(400,1,_RecLock);
  Auf_Data:BerechneMarker();
  Erx # RekReplace(400,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(404106,AInt(Auf.A.Nummer),0,0,0);
    RETURN false;
  end;
*/

  RETURN true;
end;



//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  Erx         : int;
  vBuf,vBuf2  : int;
end;
begin

  if (aName = StrCnv('clmAdr.Stichwort',_StrUpper) AND (aBuf->Auf.A.Adressnummer<>0)) then
    Adr_Main:Start(0, aBuf->Auf.A.Adressnummer,y);

  if (aName = StrCnv('clmAuf.A.Rechnungsnr',_StrUpper) AND (aBuf->Auf.A.Rechnungsnr<>0)) then
    Erl_Main:Start(0, aBuf->Auf.A.Rechnungsnr,y);

  if (aName = StrCnv('clmArt.Nummer',_StrUpper) AND (aBuf->Auf.A.Artikelnr <> '')) then
    Art_Main:Start(0, aBuf->Auf.A.Artikelnr,y);

  if (aName = StrCnv('clmMat.Nummer',_StrUpper) AND (aBuf->Auf.A.Materialnr <> 0)) then begin
    if (Mat_Data:Read(aBuf->Auf.A.Materialnr,_RecUnlock,0,true) > 0) then
      Mat_Main:Start(0, aBuf->Auf.A.Materialnr,y);
  end;


  // Klick auf Aktionkürzel
  if (aName = StrCnv('clmGV.Alpha.01',_StrUpper)) AND (aBuf->Auf.A.Aktionsnr <> 0) then begin
    case aBuf->Auf.A.Aktionstyp of

      // Ziel Lieferschein:
      c_Akt_VLDAW,
      c_Akt_LFS : begin
                    Erx # RekLinkB(vBuf, aBuf, 11,_recfirst); // Lfs für RecId Lesen
                    if (Erx <= _rLocked) then
                      Lfs_Main:Start(RecInfo(vBuf,_RecId),y);
                  end;

      c_Akt_BA_Plan_Fahr : begin
                    vBuf # RecBufCreate(440);
                    vBuf->Lfs.zuBA.Nummer   # aBuf->Auf.A.Aktionsnr;
                    vBuf->Lfs.zuBA.Position # aBuf->Auf.A.Aktionspos;
                    Erx # RecRead(vBuf,2,0);
                    if (Erx <= _rMultikey) then begin
                      Recread(vBuf,1,0);
                      Lfs_Main:Start(RecInfo(vBuf,_RecId),y);
                    end;
                  end;


      // Ziel Bestellung:
      c_Akt_Bestellung : begin
                    vBuf # RecBufCreate(501);
                    vBuf->Ein.P.Nummer    # aBuf->Auf.A.Aktionsnr;
                    vBuf->Ein.P.Position  # aBuf->Auf.A.Aktionspos;
                    Erx # RecRead(vBuf,1,0);
                    if (Erx <= _rLocked) then
                      // Bestand
                      Ein_P_Main:Start(0, aBuf->Auf.A.Aktionsnr,aBuf->Auf.A.Aktionspos ,y);

                    else begin
                      // Ablage
                      RecBufDestroy(vBuf);
                      vBuf # RecBufCreate(511);
                      vBuf->"Ein~P.Nummer"   # aBuf->Auf.A.Aktionsnr;
                      vBuf->"Ein~P.Position"  # aBuf->Auf.A.Aktionspos;
                      Erx # RecRead(vBuf,1,0);
                      if (Erx = _rOK) then begin
                        // Bestellung in Ablage, zurückholen?
                        if (Msg(510012,'',_WinIcoInformation,_WinDialogYesNo,1) = _WinIdYes) then begin
                          Ein_Abl_Data:RestoreAusAblage(aBuf->Auf.A.Aktionsnr);
                          Ein_P_Main:Start(0, aBuf->Auf.A.Aktionsnr,aBuf->Auf.A.Aktionspos ,y);
                        end;
                      end;

                    end;
                    RecBufDestroy(vBuf);

            end;

      // Ziel Betriebsauftrag
      c_Akt_BA           ,
      c_Akt_BA_Plan      ,
      c_Akt_BA_Fertig    ,
      c_Akt_BA_Ausfall   ,
      c_Akt_BA_Einsatz   ,
      c_Akt_BA_Rest      ,
      c_Akt_BA_Kosten    : begin
                            BA1_Main:Start(0, aBuf->Auf.A.Aktionsnr,y);
                           end;
      // ZIEL Reklamaktion:
      c_Akt_Reklamation : begin
                            vBuf  # RecBufCreate(300);
                            vBuf->Rek.Nummer  # aBuf->Auf.A.Aktionsnr;
                            Erx # RecRead(vBuf,1,0);
                            if (Erx <= _rMultikey) then begin

                              // Reklamationskopf zur Position gefunden
                              vBuf2 # RecBufCreate(301);
                              Erx # RecLink(vBuf2,vBuf,1,_RecFirst)
                              if (Erx <= _rLocked) then
                                Rek_P_Main:Start(0, vBuf2->Rek.P.Nummer,vBuf2->Rek.P.Position,y);

                              RecBufDestroy(vBuf2);
                            end;
                            RecBufDestroy(vBuf);
                          end;
    end;

  end;

  RunAFX('Auf.A.JumpTo',aName+'|'+aint(aBuf));
end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================