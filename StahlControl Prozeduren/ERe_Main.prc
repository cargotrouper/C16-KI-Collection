@A+
//==== Business-Control ==================================================
//
//  Prozedur    ERe_Main
//                  OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  18.09.2012  AI  neues Setting für "RealeKosten" : Projekt 1337/169
//  01.07.2013  ST  Ankerfunktion für RecSave hinzugefügt
//  01.07.2013  ST  Customfeldverbindung hinzugefügt
//  13.01.2014  ST  Bei Kontierungsprüfung per Setting Projekt 1326/337:
//                    Die Kontierungen müssen in Netto überprüft werden, da Stahl Control mit Nettopreisen rechnet(EKK)
//  15.08.2014  AH  Reverse-Charge
//  12.12.2014  ST  Skontoberechnung rundet auf 2 Stellen nach dem Komma Projekt 1420/17
//  24.08.2015  AH  Neu: Werstellungsdatum
//  07.12.2015  AH  Edit: Steuerbetrag wieder vorbelegen
//  23.03.2016  ST  Neu: Setting Set.ERe.Prueftyp hinzugefügt
//  04.11.2016  AH  Stuerbetrag errechnet ggf. aus Adress-Steuersatz
//  17.11.2016  AH  MatAktionen
//  01.12.2016  ST  Auswahlfeld für Bestellung und Projektnummer hinzugefügt
//  09.02.2017  AH  Setting: "Set.ERe.PruefRefTyp"
//  17.03.2017  AH  "RealeKostenVererben" OHNE TRANSAKTION
//  23.03.2017  AH  AFX: "ERE.Unpruefen", "ERe.RecInit"
//  16.01.2018  AH  "Inhalte übernehmen" löscht doch fast alles
//  31.07.2018  AH  Neu: LKZ, AFX "EvtLstDataInit"
//  15.08.2018  AH  Neu: ERe.Netto ist Pflichtfeld
//  27.09.2018  AH  Neu: Rechnungstyp wird beim Speichern geprüft
//  19.03.2019  AH  Neu: Meldung, wenn Steuer abweichend ist
//  07.06.2019  AH  Neu: AFX "ERe.MatAktionen"
//  26.10.2021  ST  ERX
//  26.06.2022  MR  Fix 2242/3
//  22.07.2022  HA  Quick Jump
//  28.11.2022  ST  Neu: AFX "Ere.RecSave.Post"  <--- Marked for Deletion
//  2023-01-24  AH  Fremdwährungen in EKK
//  2023-07-25  AH  AFX "ERe.Init.Pre"
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha opt aChagend : logic)
//    SUB RecInit(opt aBehalten : logic);
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant()
//    SUB AusTyp()
//    SUB AusLKZ()
//    SUB AusWaehrung()
//    SUB AusSteuerschl();
//    SUB AusEKK()
//    SUB AusKontierung()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Eingangsrechnungen'
  cFile :     560
  cMenuName : 'ERe.Bearbeiten'
  cPrefix :   'ERe'
  cZList :    $ZL.ERe
  cKey :      1
end;

declare AusEKK();

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

  Lib_Guicom2:Underline($edERe.Rechnungstyp);
  Lib_Guicom2:Underline($edERe.Lieferant);
  Lib_Guicom2:Underline($edERe.Adr.Steuerschl);
  Lib_Guicom2:Underline($edERe.LKZ);
  Lib_Guicom2:Underline($edERe.Einkaufsnr);
  Lib_Guicom2:Underline($edERe.Projektnr);
  Lib_Guicom2:Underline($edERe.Waehrung);

  SetStdAusFeld('edERe.Waehrung'        ,'Waehrung');
  SetStdAusFeld('edERe.Lieferant'       ,'Lieferant');
  SetStdAusFeld('edERe.Rechnungstyp'    ,'Typ');
  SetStdAusFeld('edERe.Adr.Steuerschl'  ,'Steuerschl');
  SetStdAusFeld('edERe.LKZ'            ,'LKZ');

  SetStdAusFeld('edERe.Einkaufsnr'      ,'Bestellung');
  SetStdAusFeld('edERe.Projektnr'       ,'Projekt');

  RunAFX('ERe.Init.Pre',aint(aEvt:Obj));    // 2023-07-25 AH
  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_ERe;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edERe.Lieferant);
  Lib_GuiCom:Pflichtfeld($edERe.Rechnungsnr);
  Lib_GuiCom:Pflichtfeld($edERe.Rechnungstyp);
  Lib_GuiCom:Pflichtfeld($edERe.Waehrung);
  Lib_GuiCom:Pflichtfeld($edERe.Netto);
  Lib_GuiCom:Pflichtfeld($edERe.Brutto);
  Lib_GuiCom:Pflichtfeld($edERe.Rechnungsdatum);
  Lib_GuiCom:Pflichtfeld($edERe.WertstellungsDat);
  Lib_GuiCom:Pflichtfeld($edERe.Valuta);
  Lib_GuiCom:Pflichtfeld($edERe.Zieldatum);

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  if (aName='') or (aName='edERe.Lieferant') then begin
    Erx # RecLink(100,560,5,0);
    if (Erx<=_rLocked) and (ERe.Lieferant<>0) then begin
      $Lb.Stichwort->wpcaption# Adr.Stichwort;
      $Lb.Name->wpcaption     # Adr.Name;
      $Lb.Strasse->wpcaption  # "Adr.Straße";
      $Lb.Ort->wpcaption      # Adr.Ort;
      $Lb.Telefon->wpcaption  # Adr.Telefon1;
      $Lb.RefNr->wpcaption    # Adr.EK.Referenznr;
      if (aName='edERe.Lieferant') and (($edERe.Lieferant->wpchanged) or (aChanged)) then begin
        "ERe.Währung"           # "Adr.EK.Währung";
        ERe.LieferStichwort     # Adr.Stichwort;
        if ($edERe.Lieferant->wpchanged) then begin
          ERe.ADr.Steuerschl  # "Adr.Steuerschlüssel";
          ERe.LKZ             # Adr.LKZ;
          RefreshIfm('edERe.Adr.Steuerschl');
        end;
        RefreshIfm('edERe.Waehrung',y);
        RefreshIfm('edERe.LKZ',y);
      end;
    end
    else begin
      $Lb.Stichwort->wpcaption# '';
      $Lb.Name->wpcaption     # '';
      $Lb.Strasse->wpcaption  # '';
      $Lb.Ort->wpcaption      # '';
      $Lb.Telefon->wpcaption  # '';
      $Lb.RefNr->wpcaption    # '';
    end;
  end;

  if (aName='') or (aName='edERe.Adr.Steuerschl') then begin
    Erx # RecLink(813,560,8,_RecFirst);   // Steuerschlüssel holen
    if (Erx<=_rLocked) then
      $Lb.steuerschl->wpcaption # Sts.Bezeichnung
    else
      $Lb.Steuerschl->wpcaption # '';
  end;


  if (aName='') or (aName='edERe.LKZ') then begin
    Erx # RekLink(812,560,9,0);
    $Lb.Land->wpcaption # Lnd.Name.L1;
  end;

  if (aName='') or (aName='edERe.Rechnungstyp') then begin
    Erx # RecLink(853,560,7,_RecFirst);   // Rechnungstyp holen
    if (Erx<=_rLocked) then
      $Lb.Typ->wpcaption # RTy.Bezeichnung
    else
      $Lb.Typ->wpcaption # '';
  end;

  if (aName='') or (aName='edERe.Waehrung') then begin
    Erx # RecLink(814,560,6,0);
    if (Erx<=_rLocked) then begin
      $Lb.Waehrung->wpcaption # "Wae.Kürzel";
      if (aName='edERe.Waehrung') and (($edERe.Waehrung->wpchanged) or (aChanged)) then
        "ERe.Währungskurs" # Wae.EK.Kurs;
        $edERe.Whrungskurs->winupdate(_WinUpdFld2Obj);
    end
    else begin
      $Lb.Waehrung->wpcaption # '';
    end;
    $Lb.Wae1->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae2->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae3->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae4->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae5->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae6->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae7->wpCaption # $Lb.Waehrung->wpcaption;
    $Lb.Wae8->wpCaption # $Lb.Waehrung->wpcaption;
  end;

  if (aName='') then begin
    $Lb.HW1->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW2->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW3->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW4->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW5->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW6->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW7->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW8->wpCaption # "Set.Hauswährung.Kurz";
  end;

  // Hauswährungsfelder berechenen, Wenn eine seperate Währung eingetragen wird
  if ("ERe.Währungskurs" <> 0.0) then begin
    // Werte errechnen
    Ere.NettoW1         # ERe.Netto        / "ERe.Währungskurs";
    Ere.SteuerW1        # ERe.Steuer       / "ERe.Währungskurs";
    Ere.BruttoW1        # ERe.Brutto       / "ERe.Währungskurs";
    ERe.SkontoW1        # ERe.Skonto       / "ERe.Währungskurs";
    ERe.RestW1          # ERe.Rest         / "ERe.Währungskurs";
  end;

  // Werte an die Labels übergeben
  $Lb.NettoW1     -> WpCaption  # ANum(ERe.NettoW1,2);
  $Lb.SteuerW1    -> WpCaption  # ANum(ERe.SteuerW1,2);
  $Lb.BruttoW1    -> WpCaption  # ANum(ERe.BruttoW1,2);
  $Lb.SkontoW1    -> WpCaption  # ANum(ERe.SkontoW1,2);
  $Lb.Pruefdatum  -> wpcaption  # CnvAD("ERe.Prüfdatum");
  $Lb.Pruefer     -> wpcaption  # "ERe.Prüfer";

  $Lb.KontiertGew -> wpcaption    # ANum(ERe.Kontiert.Gewicht,Set.Stellen.Gewicht);
  $Lb.KontiertStk    -> wpcaption # AInt("ERe.Kontiert.Stück");
  $Lb.Kontiert      -> wpcaption  # ANum(ERe.KontiertBetrag,2);
  $Lb.KontiertW1    -> wpcaption  # ANum(ERe.KontiertBetragW1,2);

  $Lb.ZugeordnetGew -> wpcaption  # ANum(ERe.Kontroll.Gewicht,Set.Stellen.Gewicht);
  $Lb.ZugeordnetStk -> wpcaption  # AInt("ERe.Kontroll.Stück");
  $Lb.Zugeordnet    -> wpcaption  # ANum(ERe.KontrollBetrag,2);
  $Lb.ZugeordnetW1  -> wpcaption  # ANum(ERe.KontrollBetragW1,2);

  $Lb.Zahlung   -> wpcaption  # ANum(ERe.Zahlungen,2);
  $Lb.ZahlungW1 -> wpcaption  # ANum(ERe.ZahlungenW1,2);
  $Lb.Rest      -> wpcaption  # ANum(ERe.Rest,2);
  $Lb.RestW1    -> wpcaption  # ANum(ERe.RestW1,2);

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  Pflichtfelder()

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit(opt aBehalten : logic)
local begin
  v560  : int;
  vHdl  : int;
end;
begin
  // Ankerfunktion?
  if (aBehalten) then begin
    if (RunAFX('ERe.RecInit','Y')<0) then RETURN;
  end
  else begin
    if (RunAFX('ERe.RecInit','N')<0) then RETURN;
  end;

  // Felder Disablen durch:
  Lib_GuiCom:Disable($edERe.Nummer);
  Lib_GuiCom:Disable($edERe.Anlage.Datum);

  if (mode=c_ModeNew) then begin

    // 07.04.2017 AH: direkt aus EKK?
    if (StrCut(w_command,1,6)='vonEKK') then begin
    w_NoList # true;
      v560 # cnvia(Str_Token(w_Command,'|',2));
      RecBufCopy(v560, 560);
      RecBufDestroy(v560);
    //    w_command # '';
    //    gTimer2 # SysTimerCreate(300,1,gMdi);
      Lib_GuiCom:Disable($cbERe.NichtInOrdnung);
      Lib_GuiCom:Disable($cbERe.InOrdnung);
      $edERe.Rechnungsnr->WinFocusSet( true );
      RETURN;
    end;


    if (aBehalten) then begin
      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);
//      ERe.Nummer          # 0;

      v560 # RekSave(560);
      RecBufClear(560);
      ERe.Lieferant       # v560->ERe.Lieferant;
      ERe.LieferStichwort # v560->ERe.LieferStichwort;
      ERe.Rechnungstyp    # v560->ERe.REchnungstyp;
      "ERe.Währung"       # v560->"ERe.Währung";
      "ERe.Währungskurs"  # v560->"ERe.Währungskurs";
      ERe.Adr.Steuerschl  # v560->ERe.Adr.Steuerschl;
      ERe.LKZ             # v560->ERe.LKZ;

      RecBufdestroy(v560);
      vHdl # Winfocusget();
      if (vHdl<>0) then
        vHdl->Winupdate(_WinUpdFld2Obj);

    end
    else begin
      ERe.Rechnungstyp # Set.ERe.Rechnungstyp;
    end;
  end;

  if (Rechte[Rgt_ERe_Pruefen]) and (Mode<>c_modeNew) then begin
    Lib_GuiCom:Enable($cbERe.NichtInOrdnung);
    Lib_GuiCom:Enable($cbERe.InOrdnung);
  end
  else begin
    Lib_GuiCom:Disable($cbERe.NichtInOrdnung);
    Lib_GuiCom:Disable($cbERe.InOrdnung);
  end;

  // Focus setzen auf Feld:
  if ( ERe.Rechnungstyp = 0 ) then
    $edERe.Rechnungstyp->WinFocusSet( true );
  else
    $edERe.Lieferant->WinFocusSet( true );
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vOK   : logic;
  vList : int;
  vITem : int;
  aAfxPostPara : alpha;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  ERe.Zahlungen   # Rnd(ERe.Zahlungen,2);
  ERe.ZahlungenW1 # Rnd(ERe.ZahlungenW1,2);
  ERe.Rest        # Rnd(ERe.Rest,2);
  ERe.RestW1      # Rnd(ERe.RestW1,2);


  // logische Prüfung
  If (ERe.Rechnungstyp=0) then begin
    Msg(001200,Translate('Rechnungstyp'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Rechnungstyp->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(853,560,7,_RecFirst);   // Rechnungstyp holen
  If (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Rechnungstyp', 'NB.Page1', 'edERe.Lieferant');
    RETURN false;
  end;

  If (ERe.Lieferant=0) then begin
    Msg(001200,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Lieferant->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(100,560,5,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Lieferant->WinFocusSet(true);
    RETURN false;
  end;

  if (ERe.Adr.Steuerschl<>0) then begin
    Erx # RecLink(813,560,8,0);
    If (Erx>_rLocked) or (ERe.Adr.Steuerschl>999) then begin
      Msg(001201,Translate('Steuerschlüssel'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edERe.Adr.Steuerschl->Winfocusset(true);
      RETURN false;
    end;
  end;

  if (ERe.Lkz<>'') then begin
    Erx # RekLink(812,560,9,0);
    If (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('LKZ', 'NB.Page1', 'edERe.LKZ');
      RETURN false;
    end;
  end;

  If (ERe.Rechnungsnr='') then begin
    Msg(001200,Translate('Rechnungsnummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Rechnungsnr->WinFocusSet(true);
    RETURN false;
  end;

  If (ERe.Rechnungsdatum<1.1.1900) then begin
    Msg(001200,Translate('Rechnungsdatum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Rechnungsdatum->WinFocusSet(true);
    RETURN false;
  end;
  If (ERe.WertstellungsDat<1.1.1900) then begin
    Msg(001200,Translate('Weststellungsdatum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.m->WinFocusSet(true);
    RETURN false;
  end;

  If (ERe.Valuta<1.1.1900) then begin
    Msg(001200,Translate('Valuta'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Valuta->WinFocusSet(true);
    RETURN false;
  end;

  If (ERe.Zieldatum<1.1.1900) then begin
    Msg(001200,Translate('Fälligkeitsdatum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Zieldatum->WinFocusSet(true);
    RETURN false;
  end;

  If ("ERe.Währungskurs"=0.0) then begin
    Msg(001200,Translate('Währungskurs'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Whrungskurs->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(814,560,6,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Währung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Waehrung->WinFocusSet(true);
    RETURN false;
  end;


  If (ERe.Brutto=0.0) then begin
    Msg(001200,Translate('Bruttobetrag'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edERe.Brutto->WinFocusSet(true);
    RETURN false;
  end;


  // Prüfen, ob schon eine Eingangsrechnung
  // von dieser Adresse mit der Rechnungsnummer
  // existiert
  if (ERe_Data:ExistiertSchon() = true) then begin
    vOK # false;
    if (Set.ERe.PruefRefTyp='W') then begin
      vOK # (Msg(560018,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes);
    end
    else begin
      Msg(001204,'',0,0,0);
    end;
    if (vOK=false) then begin
      $NB.Main->wpcurrent # 'NB.Page1';
      RETURN false;
    end;
  end;


  if (Ere.Rechnungsdatum>today) or (Ere.Wertstellungsdat>today) then begin
    Msg(560014,'',0,0,0);
  end;

  if (Set.ERe.TestAbsch) then begin
    if (Lib_Faktura:Abschlusstest(ERe.WertstellungsDat) = false) then begin
      Error(001400 ,Translate('Wertstellungsdatum') + '|'+ CnvAd(ERe.WertstellungsDat));
      ErrorOutput;
      RETURN false;
    end;
  end;


  // Ankerfunktion
  if (RunAFX('ERE.RecSave','')<>0) then begin
    if (AfxRes = _rOk) then begin
      w_Command # '';
      RETURN true;
    end
    else begin
      RETURN false;
    end;
  end;


  // Nummernvergabe
  if (Mode=c_ModeNew) then begin
    ERe.Anlage.Datum  # SysDate();
    ERe.Anlage.Zeit   # Now;
    ERe.Anlage.User   # gUserName;

    ERe.Nummer # Lib_Nummern:ReadNummer('Eingangsrechnung');
    if (ERe.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;
  end;

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    vOK # ProtokollBuffer[gFile]->ERe.InOrdnung;

    // auf "InOrdnung" verändert?
    if (Set.Auf.GutBelLFNull = false) or
      ((Set.Auf.GutBelLFNull = true) and
        (ERe.REchnungstyp <> c_ERL_REKOR) and (ERe.REchnungstyp <> c_ERL_BEL_KD) and
        (ERe.Rechnungstyp <> c_ERL_Gut) and (ERe.REchnungstyp <> c_ERL_BEL_LF)) then begin
      if (vOK=false) and (ERe.inOrdnung) then begin
        if (vOK=false) and (Rnd(ERe.KontrollBetragW1-ERe.NettoW1)<>0.0) then begin
          if (Set.ERe.Prueftyp = 'Z') OR (Set.ERe.Prueftyp = 'B') then
            if (Msg(560012,ANum(Abs(ERe.KontrollBetragW1-ERe.NettoW1),2)+"Set.Hauswährung.Kurz",_WinIcoWarning, _WinDialogYesNo, 2)<>_WinIdYes) then vOK # y;
        end;
        if (vOK=false) and (Rnd(ERe.KontiertBetragW1-ERe.NettoW1)<>0.0) then begin
          if (Set.ERe.Prueftyp = 'K') OR (Set.ERe.Prueftyp = 'B') then
            if (Msg(560013,ANum(Abs(ERe.KontiertBetragW1-ERe.NettoW1),2)+"Set.Hauswährung.Kurz",_WinIcoWarning, _WinDialogYesNo, 2)<>_WinIdYes) then vOK # y;
        end;
        if (vOK) then begin
          $NB.Main->wpcurrent # 'NB.Page1';
          $cbERe.InOrdnung->WinFocusSet(true);
          RETURN false;
        end;
      end;

      if (ERe.InOrdnung=false) then ERe.JobAusstehendJN # false;
    end;

    TRANSON;

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Verbindlichkeit anlegen
    Vbk_Data:Update(560);

    PtD_Main:Compare(560);

    TRANSOFF;   // 17.11.2016

    // auf "InOrdnung" verändert?
    if (vOK=false) and (ERe.inOrdnung) then begin
      if (Set.ERD.RealeKosten='I') then begin
      end
      else begin
        // nur wenn NICHT über HobJServer
        if (ERe.JobAusstehendJN=false) then begin
          if (ERe_Data:RealeKostenVererben()=false) then begin
            ErrorOutput;
            Msg(560011,'',0,0,0);
            RETURN true;
          end;
        end;
      end;

      if (ERe_Data:MatKosten(Ere.Nummer, Ere.NettoW1, Ere.WertstellungsDat, true)=false) then begin
        Msg(560011,'',0,0,0);
        RETURN true;
      end;
    end;

  end
  else begin
    TRANSON;

    ERe.Anlage.Datum  # Today;
    ERe.Anlage.Zeit   # Now;
    ERe.Anlage.User   # gUsername;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx <>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (StrCut(w_command,1,6)='vonEKK') then begin
      vList # cnvia(Str_Token(w_Command,'|',3));
      APPOFF();
      FOR vItem # vList->CteRead(_CteFirst)
      LOOP vItem # vList->CteRead(_CteNext, vItem)
      WHILE (vItem > 0) DO BEGIN
        RecRead(555,0,_RecId,vItem->spID);
        if (ERe_Data:EKK_Zuordnen(1)=false) then begin
          APPON();
          TRANSBRK;
          Msg(555003,'',0,0,0);
          RETURN False;
        end;
      END;
      Lib_RamSort:KillList(vList);
      Lib_Mark:Reset(555);
      AusEKK();
      TRANSOFF;
      w_command # 'X';
      APPON();
      RETURN true;
    end;

    TRANSOFF;

    if (gZLList<>0) then
      if (gZLList->wpDbSelection<>0) then
        SelRecInsert(gZLList->wpDbSelection,gfile);

    // Verbindlichkeit anlegen
    Vbk_Data:Update(560);

    // Weitere neue Einträge?
    if (Msg(000009,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
      RecInit(y);
      gMDI->winupdate(_WinUpdFld2Obj);
      gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
      RETURN false;
    end;
  end;  // Neuanlage
  
// ST 2023-01-18 2255/64: Deaktiviert nicht mehr benötiogt und Buggy: Kann nach dem näachsten Update gelölscht werden
/*
  // Ankerfunktion
  if (ProtokollBuffer[gFile] != 0) then begin
    aAfxPostPara # '';
    if (ProtokollBuffer[gFile]->ERe.InOrdnung) then
      aAfxPostPara # 'Y';
    else
      aAfxPostPara # 'N';
    if (ProtokollBuffer[gFile]->ERe.NichtInOrdnung) then
      aAfxPostPara # 'Y';
    else
      aAfxPostPara # 'N';
    RunAFX('Ere.RecSave.Post',aAfxPostPara);
  end;
*/
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  vList : int;
end;
begin
  if (StrCut(w_command,1,6)='vonEKK') then begin
    vList # cnvia(Str_Token(w_Command,'|',3));
    Lib_RamSort:KillList(vList);
    w_command # 'X';
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx   : int;
end
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  TRANSON;
  
  Erx # Recread(560,1,_RecLock);
  If (Erx = _rOK) then begin
    If ("ERe.Löschmarker" = '') then  "ERe.Löschmarker" # '*'
    else                              "ERe.Löschmarker" # '';
    Erx # RekReplace(560,_RecUnlock,'AUTO');
    if (Erx=_rOK) then begin
      // 2022-09-13 AH : EKKs aufheben Proj. 2429/303/10
      if (ERe.InOrdnung=false) and (ERe.NichtInOrdnung=false) then begin
        FOR Erx # RecLink(555,560,4,_recFirst)
        LOOP Erx # RecLink(555,560,4,_recFirst)
        WHILE (Erx<=_rLocked) do begin
          Erx # EKK_Data:Aufheben();
        END;
        if (erx<>_rOK) and (Erx<>_rNoRec) then begin
          if (Erx<>_rDeadLock) then TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN;
        end;
        AusEKK();
        TRANSOFF;
        RETURN;
      end;
    end;
  end;
  if (erx=_rOK) then begin
    TRANSOFF;
    RETURN;
  end;
  if (Erx<>_rDeadLock) then TRANSBRK;
  Msg(001000+Erx,gTitle,0,0,0);
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
local begin
  Erx   : int;
  vX  : float;
end;
begin

  if ((aEvt:Obj->wpname='edERe.Rechnungsdatum') and ($edERe.Rechnungsdatum->wpchanged)) then begin
    if (ERe.Valuta=0.0.0) then begin
      ERe.Valuta # ERe.Rechnungsdatum;
      $edERe.Valuta->WinUpdate(_WinUpdFld2Obj);
    end;
    if (ERe.WertstellungsDat=0.0.0) then begin
      ERe.WertstellungsDat # ERe.Rechnungsdatum;
      $edERe.WertstellungsDat->WinUpdate(_WinUpdFld2Obj);
    end;
  end;

  if ((aEvt:Obj->wpname='edERe.Valuta') and (ERe.Valuta<>0.0.0)) then begin
    Erx # RecLink(100,560,5,0);   // Lieferant holen
    if (Erx<=_rLocked) then begin

      RecBufClear(460);   // OP "missbrauchen"
      Ofp.Zahlungsbed     # Adr.EK.Zahlungsbed;
      Ofp.Rechnungsdatum  # ERe.Valuta;
      OfP_Data:BerechneZielDaten(ERe.Valuta);

      if (ERe.Skontoprozent=0.0) then ERe.Skontoprozent # OfP.Skontoprozent;
      if (ERe.Zieldatum=0.0.0) then ERE.Zieldatum # OfP.Zieldatum;
      if (ERe.Skontodatum=0.0.0) then ERe.Skontodatum # OfP.Skontodatum;
      /*
      if (ERe.Skontodatum=0.0.0) and (OfP.Skontoprozent<>0.0) then begin
        if (ZaB.SkonVorZielDatYN=n) then begin
          ERe.Skontodatum # OFp.Rechnungsdatum;
          ERe.Skontodatum->vmdaymodify(ZAb.Skontotage);
        end
        else begin
          ERe.Skontodatum # OFp.Zieldatum;
          ERe.Skontodatum->vmdaymodify(-ZAb.Skontotage);
        end;
      end;
      */

      $edERe.Skontoprozent->WinUpdate(_WinUpdFld2Obj);
      $edERe.Skontodatum->WinUpdate(_WinUpdFld2Obj);
      $edERe.Zieldatum->WinUpdate(_WinUpdFld2Obj);
    end;
  end;

  // Steuerbetrag errechnen ueber den Steuerschluessel des Lieferanten
/* 15.08.2014 Reverse-Charge*/
/* 07.12.2015 AH : Reaktiviert bei Prozent<>0.0 */
// 19.03.2019 AH: mit Abfrage
  if (aEvt:Obj->wpname='edERe.Netto') and ($edERe.Netto->wpchanged) then begin
    Erx # RecLink(813,560,8,_recFirst);   // Steuerschluessel holen
    if(Erx > _rLocked) then
      RecBufClear(813);
    if (Sts.Prozent<>0.0) then begin
      vX # Rnd((ERe.Netto/100.0)*StS.Prozent,2);
      if (ERe.Steuer = 0.0) then begin
        ERe.Steuer # Rnd((ERe.Netto/100.0)*StS.Prozent,2);
      end
      else begin
        if (Msg(560019,anum(vX,2),_WinIcoQuestion, _WinDialogYesNo, 1)=_Winidyes) then
          ERe.Steuer # vX;
      end;
      $edERe.Steuer->winupdate(_WinUpdFld2Obj);
      Refreshifm('edERe.Netto');
    end;
  end;


  if ((aEvt:Obj->wpname='edERe.Netto') and ($edERe.Netto->wpchanged)) or
    ((aEvt:Obj->wpname='edERe.Steuer') and ($edERe.Steuer->wpchanged)) then begin
    ERe.Brutto    # ERe.Netto + ERe.Steuer;
    ERe.BruttoW1  # ERe.NettoW1 + ERe.SteuerW1;
    Refreshifm('edERe.Brutto');
  end;
  ERe.Rest   # Rnd(ERe.Brutto - ERe.Zahlungen,2);
  ERe.RestW1 # Rnd(ERe.BruttoW1 - ERe.ZahlungenW1,2);


  if ((aEvt:Obj->wpname='edERe.Netto') and ($edERe.Netto->wpchanged)) or
    ((aEvt:Obj->wpname='edERe.Steuer') and ($edERe.Steuer->wpchanged)) or
    ((aEvt:Obj->wpname='edERe.Brutto') and ($edERe.Brutto->wpchanged)) or
    ((aEvt:Obj->wpname='edERe.SkontoProzent') and ($edERe.SkontoProzent->wpchanged)) then begin

    // ST 2014-12-12 Rundung auf 2 Nachkommastellen
    ERe.Skonto    # Rnd(ERe.Brutto * ERe.SkontoProzent/100.0,2);
    ERe.SkontoW1  # Rnd(ERe.BruttoW1 * ERe.SkontoProzent/100.0,2);
    Refreshifm('edERe.Skonto');
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
  vA    : alpha;
end;

begin

  case aBereich of

    'Lieferant' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',Here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Steuerschl' : begin
      RecBufClear(813);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sts.Verwaltung',Here+':AusSteuerschl');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'LKZ' : begin
      RecBufClear(812);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lnd.Verwaltung', here+':AusLKZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Waehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',Here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Typ' : begin
      RecBufClear(853);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'RTy.Verwaltung',here+':AusTyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

   'Projekt' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',Here+':AusProjekt');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


   'Bestellung' : begin

      If (Msg(560016,'',_WinIcoQuestion,_WinDialogYesNo,2) = _WinIdYes) then begin
        RecBufClear(511);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Ablage',Here+':AusBestellungAbl');

      end else begin
        RecBufClear(501);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',Here+':AusBestellung');
      end;


      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


  end;

end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Lieferant       # Adr.Lieferantennr;
    ERe.ADr.Steuerschl  # "Adr.Steuerschlüssel";
    ERe.LKZ             # Adr.LKZ;
    gSelected # 0;
    RefreshIfm('edERe.Adr.Steuerschl');
  end;
  // Focus auf Editfeld setzen:
  $edERe.Lieferant->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edERe.Lieferant', y);
end;


//========================================================================
//  AusSteuerschl
//
//========================================================================
sub AusSteuerschl()
begin
  if (gSelected<>0) then begin
    RecRead(813,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Adr.Steuerschl # Sts.nummer;
    if (StS.LKZ<>'') then
      ERe.LKZ # StS.LKZ;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edERe.Adr.Steuerschl->Winfocusset(false);
end;


//========================================================================
//  AusLKZ
//
//========================================================================
sub AusLKZ()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    gSelected # 0;
    ERe.LKZ               # "Lnd.Kürzel";
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edERe.LKZ->Winfocusset(false);
end;


//========================================================================
//  AusTyp
//
//========================================================================
sub AusTyp()
begin
  if (gSelected<>0) then begin
    RecRead(853,0,_RecId,gSelected);
    ERe.Rechnungstyp # RTy.Nummer;
    gSelected # 0;
  end;
  $edERe.Rechnungstyp->Winfocusset(false);
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    "ERe.Währung" # Wae.Nummer;
    gSelected # 0;
  end;
  $edERe.Waehrung->Winfocusset(false);
  RefreshIfm('edERe.Waehrung',y);
end;


//========================================================================
//  AusProjekt
//
//========================================================================
sub AusProjekt()
begin
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Projektnr # Prj.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edERe.Projektnr->Winfocusset(false);
end;


//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellung()
begin
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Einkaufsnr # Ein.P.Nummer;
    gSelected # 0;
  end;
  // Focus auf  setzen:
  $edERe.Einkaufsnr->Winfocusset(false);
end;

//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellungAbl()
begin
  if (gSelected<>0) then begin
    RecRead(511,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Einkaufsnr # "Ein~P.Nummer";
    gSelected # 0;
  end;
  // Focus auf  setzen:
  $edERe.Einkaufsnr->Winfocusset(false);
end;


//========================================================================
//  AusEKK
//
//========================================================================
sub AusEKK()
local begin
  Erx   : int;
  vWert   : float;
  vWertW1 : float;
  vStk    : int;
  vGew    : float;
end;
begin
  gSelected # 0;

  Erx # RecLink(555,560,4,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    vWert   # vWert   + EKK.Preis;
    vWertW1 # vWertW1 + EKK.PreisW1;
    vStk    # vStk    + "EKK.Stückzahl";
    vGew    # vGew    + EKK.Gewicht;
    Erx # RecLink(555,560,4,_recNext);
  END;
  
  // 2023-01-24 AH  : wenn andere Währung, dann Umrechnen aus W1
  if ("Ekk.Währung"<>"ERe.Währung") then begin
    Erx # RecLink(814,560,6,0);   // Währung holen
    vWert # vWertW1 * Wae.EK.Kurs;
  end;
  
  
  if (vWert<>ERe.Kontrollbetrag) or
    (vWertW1<>ERe.KontrollbetragW1) or
    (vStk<>"ERe.Kontroll.Stück") or
    (vGew<>ERe.Kontroll.Gewicht) then begin
    RecRead(560,1,_recLock);
    ERe.Kontrollbetrag    # vWert;
    ERe.KontrollbetragW1  # vWertW1;
    "ERe.Kontroll.Stück"  # vStk;
    ERe.Kontroll.Gewicht  # vGew;
    RekReplace(560,_recUnlock,'AUTO');
  end;

  if (Mode=c_ModeView) then begin
    Refreshifm();
    
    //[+] Fix 2242/1 MR 26.06.2022
    RefreshIfm('Lb.ZugeordnetGew');
    RefreshIfm('Lb.ZugeordnetStk');
    RefreshIfm('Lb.Zugeordnet');
    RefreshIfm('Lb.ZugeordnetW1');
  end;

  $ed.Suche->Winfocusset(false);
end;


//========================================================================
//  AusKontierung
//
//========================================================================
sub AusKontierung()
local begin
  vWert   : float;
  vWertW1 : float;
  vStk    : int;
  vGew    : float;
end;
begin
  gSelected # 0;

  RecRead(560,1,0);

  if (Mode=c_ModeView) then Refreshifm();

  $ed.Suche->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or (Rechte[Rgt_ERe_Aendern]=n) or (ERe.InOrdnung);
//    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or (Rechte[Rgt_ERe_Aendern]=n) or (ERe.InOrdnung);
//    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Aendern]=n) or (ERe.InOrdnung);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_ERe_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_ERe_Excel_Import]=false;

  d_MenuItem # gMenu->WinSearch('Mnu.Zahlungen');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_ERe_Z]=false)) or (ERe.InOrdnung=n);

  d_MenuItem # gMenu->WinSearch('Mnu.Kontierung');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_VBk_K]=false));

  d_MenuItem # gMenu->WinSearch('Mnu.EKK');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_EKK]=false));

  d_MenuItem # gMenu->WinSearch('Mnu.MatAktionen');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_EKK]=false));


  vHdl # gMenu->WinSearch('Mnu.Fibu');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
                or (Rechte[Rgt_ERe_Fibu]=n);

  vHdl # gMenu->WinSearch('Mnu.nichtOK');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
                (Rechte[Rgt_ERe_Pruefen]=n) or
                ((ERe.InOrdnung=n) and (ERe.NichtInOrdnung=n));

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
  Erx       : int;
  vHdl      : int;
  vTmp      : int;
  vSel      : alpha;
  vSelName  : alpha;
  vSel2     : int;
  vQ        : alpha(4000);
end;
begin

  if (Mode=c_ModeList) then
    RecRead(gFile, 0, 0, gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.MatAktionen' : begin
      if (RunAFX('ERe.MatAktionen','')<>0) then RETURN true;

      RecBufClear(204);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.A.Verwaltung','', true);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Mat.A.EK.RechNr'  , '=', ERe.Nummer);
      vHdl # SelCreate(204, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Scannen' : begin
      ERe_Data:Scannen();
    end;


    'Mnu.BarcodeEtikett' : begin
      Lib_Dokumente:Printform(560, 'BarcodeEtikett', true);
    end;


    'Mnu.Filter.Geloescht' : begin
      Filter_ERe # !Filter_ERe;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_ERe;

      if ( gZLList->wpDbSelection != 0 ) then begin
        vHdl # gZLList->wpDbSelection;
        gZLlist->wpDbSelection # 0;
        SelClose( vHdl );
        SelDelete( gFile, w_selName );
        w_selName # '';
        if (gZLList->wpDbRecId=0) then
          gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect)
        else
          gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
        App_Main:Refreshmode();
        RETURN true;
      end;
      Lib_Sel:QRecList( 0, '"ERe.Löschmarker" = ''''' );
      if (gZLList->wpDbRecId=0) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect)
      else
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);

      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.nichtOK' : begin
      if (Rechte[Rgt_ERe_Pruefen]) and ((ERe.InOrdnung) or (ERe.NichtInOrdnung)) then begin
        // noch Zahlungen aktiv?
        if (RecLinkInfo(561,560,1,_recCount)>0) then begin
          Msg(560007,'',0,0,0);
          RETURN false;
        end;
        if (Msg(560009,AInt(Ere.Nummer),_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN true;


        if (RunAFX('ERE.Unpruefen','')<0) then begin
          RETURN true;
        end;

        TRANSON;

        RecRead(560,1,_recLock);
        //"ERe.Prüfer"        # '';
        //"ERe.Prüfdatum"     # sysdate();
        ERe.InOrdnung         # n;
        ERe.NichtInOrdnung    # n;
        ERe.JobAusstehendJN   # false;
        Erx # RekReplace(560,_recUnlock,'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;

        if (ERe_Data:MatKosten(Ere.Nummer, Ere.NettoW1, Ere.WertstellungsDat, false)=false) then begin
          TRANSBRK;
          Msg(001000,gTitle,0,0,0);
          RETURN False;
        end;

        Vbk_Data:Update(560);

        TRANSOFF;
      end;
    end;


    'Mnu.Mark.Sel' : begin
      ERe_Mark_Sel();
    end;


    'Mnu.Fibu' : begin
      if (Set.Fibu.Prozedur<>'') then
        Call(Set.Fibu.Prozedur+':ERe_Export')
      else
        Msg(450101,'',0,0,0);
    end;


    'Mnu.Zahlungen' : begin
      RecBufClear(561);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ERe.Z.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->WinFocusSet(true);
    end;


    'Mnu.Kontierung' : begin
      RecBufClear(551);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VbK.K.Verwaltung',here+':ausKontierung',y);
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->WinFocusSet(true);
    end;


    'Mnu.EKK' : begin
      RecBufClear(555);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, Lib_GuiCom:GetAlternativeName( 'ERe.EKK.Verwaltung'),here+':AusEKK',y)
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.SumMarkiert' : begin
      Msg(560006,cnvaf(ERe_Data:SumMarkiert())+' '+"Set.Hauswährung.Kurz",0,0,0);
    end;


    'Mnu.ZahlGenerate' : begin
      ERe_Data:ZahlGenerate();
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, ERe.Anlage.Datum, ERe.Anlage.Zeit, ERe.Anlage.User );
    end;

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
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
local begin
  Erx   : int;
  vF  : float;
end;
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Lieferant'  :   Auswahl('Lieferant');
    'bt.Waehrung'   :   Auswahl('Waehrung');
    'bt.Typ'        :   Auswahl('Typ');
    'bt.Steuerschl' :   Auswahl('Steuerschl');
    'bt.Bestellung' :   Auswahl('Bestellung');
    'bt.Projekt'    :   Auswahl('Projekt');

    'bt.Steuer'     :   begin
      Erx # RekLink(813,560,8,_RecFirst);   // Steuerschlüssel holen
      vF # Sts.Prozent;
      if (Dlg_Standard:Menge(Translate('Prozent'), var vF)) then begin
        ERe.Steuer    # Rnd(ERe.Netto * vF / 100.0,2);
        ERe.SteuerW1  # ERe.Steuer       / "ERe.Währungskurs";
        ERe.Brutto    # ERe.Steuer + ERe.Netto;
        ERe.BruttoW1  # ERe.Brutto       / "ERe.Währungskurs";
        $Lb.SteuerW1    -> WpCaption  # ANum(ERe.SteuerW1,2);
        $Lb.BruttoW1    -> WpCaption  # ANum(ERe.BruttoW1,2);
        $edERe.Steuer->winupdate(_WinUpdFld2Obj);
        $edERe.Brutto->winupdate(_WinUpdFld2Obj);
        $edERe.Steuer->WinFocusSet( true );
        // 01.03.2021 AH:
        ERe.Skonto    # Rnd(ERe.Brutto * ERe.SkontoProzent/100.0,2);
        ERe.SkontoW1  # Rnd(ERe.BruttoW1 * ERe.SkontoProzent/100.0,2);
        Refreshifm('edERe.Skonto');

      end;
    end;
  end;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTmp  : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbERe.InOrdnung') then begin
    // ST 2014-01-13 / Projekt 1326/337: Die Kontierungen müssen in Netto überprüft werden, da Stahl Control mit Nettopreisen rechnet(EKK)
    //if (Set.ERD.Warntyp='K') and (ERe.KontiertBetragW1<>ERe.BruttoW1) then begin
    if (Set.ERD.Warntyp='K') and (ERe.KontiertBetragW1<>ERe.NettoW1) then begin
      Msg(560010,'',0,0,0);
    end;
    "ERe.Prüfer"    # gUserName;
    "ERe.Prüfdatum" # today;
    ERe.NichtInOrdnung # !(ERe.InOrdnung);
    vTmp # gMdi->winsearch('cbERe.NichtInOrdnung');
    if (vTmp<>0) then
      vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='cbERe.NichtInOrdnung') then begin
    "ERe.Prüfer"    # gUserName;
    "ERe.Prüfdatum" # today;
    ERe.InOrdnung # !(ERe.NichtInOrdnung);
    vTmp # gMdi->winsearch('cbERe.InOrdnung');
    if (vTmp<>0) then
      vTmp->winupdate(_WinUpdFld2Obj);
  end;

//  $lbERe.Prüfdatum" # today;
  RefreshIfm();

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
  vCol  : int;
end;
begin

  // Sonderfunktion:
  if (aMark) then begin
    if (RunAFX('ERe.EvtLstDataInit','y')<0) then RETURN;
  end
  else begin
    if (RunAFX('ERe.EvtLstDataInit','n')<0) then RETURN;
  end;

  // Zeilenfarbe anpassen
  if (aMark=n) then begin
    vCol # 0;
    if ("ERe.Löschmarker"='*') then vCol # Set.Col.RList.Deletd;
    if (vCol<>0) then Lib_GuiCom:ZLColorLine(gZLList,vCol);
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
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edERe.Rechnungstyp') AND (aBuf->Ere.Rechnungstyp<>0)) then begin
    RekLink(853,560,7,0);   // Typ holen
    Lib_Guicom2:JumpToWindow('RTy.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.Lieferant') AND (aBuf->ERe.Lieferant<>0)) then begin
    RekLink(100,560,5,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.Adr.Steuerschl') AND (aBuf->ERe.Adr.Steuerschl<>0)) then begin
    RekLink(813,560,8,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('Sts.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.LKZ') AND (aBuf->ERe.LKZ<>'')) then begin
    RekLink(812,560,9,0);   // Land holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.Einkaufsnr') AND (aBuf->ERe.Einkaufsnr<>0)) then begin
   todo('Bestellung')
    //RekLink(812,560,9,0);   // Bestellung holen
    Lib_Guicom2:JumpToWindow('Ein.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.Projektnr') AND (aBuf->ERe.Projektnr<>0)) then begin
    Prj.Nummer # ERe.Projektnr;
    RecRead(120,1,0);
    Lib_Guicom2:JumpToWindow('Prj.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.Waehrung') AND (aBuf->"ERe.Währung"<>0)) then begin
    RekLink(812,560,9,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================