@A+
//==== Business-Control ==================================================
//
//  Prozedur    ERe_Z_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  30.05.2012  AI  Löschen von verbuchtne Zahlungen verboten (Projekt 1377/39)
//  19.11.2012  AI  Projekt 1369/45
//  29.11.2012  AI  NEU: Sofortiger Scheckdruck
//  10.12.2012  AI  Bug: Währungskurs wurde multipliziiert statt dividiert
//  03.04.2013  AI  RND
//  17.10.2016  AH  Zau.Zahldatum wird immer angezeigt und ist Pflichtfeld
//  01.03.2019  AH  Fix: Vorkasse sind schon gelöschte Zahlungen (weil Zahldatum gesetzt), müssen aber trotzdem zugeordet werden können
//  10.05.2022  AH  ERX
//  22.07.20122  HA  Quuick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusRechnung()
//    SUB AusZahlungsausgang()
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
@I:Lib_Nummern

define begin
  cTitle :    'Zahlungsausgänge'
  cFile :     561
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'ERe_Z'
  cZList :    $ZL.Aus.Zahlungen
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

Lib_Guicom2:Underline($edERe.Z.Nummer);
Lib_Guicom2:Underline($edERe.Z.Zahlungsnr);

  SetStdAusFeld('edERe.Z.Nummer'       ,'Rechnung');
  SetStdAusFeld('edERe.Z.Zahlungsnr'   ,'Zahlungsausgang');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx       : int;
  vBetrag   : float;
  vBetrag2  : float;
  vBetrag3  : float;
  vBetragW1 : float;

  vDiff     : float;
  vText     : alpha;
  vText3    : alpha;
  vBuf561   : int;
  vTmp      : int;
  vZauDatum : date;
end;
begin

  if (Mode=c_ModeList) then begin
    vBetrag   # 0.0;
    vBetrag2  # 0.0;
    vBetrag3  # 0.0;

    if (gZLList->wpdbFileno=565) then begin
      vBuf561 # RecBufCreate(561);
      Erx # RecLink(vBuf561,565,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vBetrag2 # vBetrag2 + vBuf561->ERe.Z.Betrag;
        Erx # RecLink(vBuf561,565,1,_recNext);
      END;
      RecBufDestroy(vBuf561);

      vBetrag   # ZAu.Betrag;
      vBetrag3  # vBetrag - vBetrag2;
      vText     # Translate('Zahlungsbetrag');
      vText3    # Translate('Restbetrag');
    end;

    if (gZLList->wpdbFileno=560) then begin
      vBuf561 # RecBufCreate(561);
      Erx # RecLink(vBuf561,560,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vBetrag2 # vBetrag2 + vBuf561->ERe.Z.Betrag;
        vBetrag3 # vBetrag3 + vBuf561->ERe.Z.Skontobetrag;
        Erx # RecLink(vBuf561,560,1,_recNext);
      END;
      RecBufDestroy(vBuf561);

      vBetrag   # ERe.Rest;
      vText     # Translate('Restbetrag');
      vText3    # Translate('Skontobetrag');
    end;

    $lb.ERe.z.BetragSumme->wpcaption # ANum(vBetrag,2);
    $lb.ERe.z.ZugeordnetSumme->wpcaption # ANum(vBetrag2,2);
    $lb.ERe.z.RestSumme->wpcaption # ANum(vBetrag3,2);
    $lb.Betrag1->wpcaption # vText;
    $lb.Betrag3->wpcaption # vText3;
  end; // ModeList


  if (Mode=c_ModeNew) then begin
    if (ERe.Z.Zahlungsnr=0) then
      Lib_GuiCom:Enable($edZAu.Datum)
    else
      Lib_GuiCom:Disable($edZAu.Datum);
  end;


  if ((aName='') or (aName='edERe.Z.Nummer')) AND
    (cZList->wpDbFileNo = 565) then begin
    Erx # RecLink(560,561,1,0);   // Eingangsrech. lesen
    if (Erx > _rLocked) then RecBufClear(560);

    // W1 aus der Eingangsrech. übernehmen
    Wae.Nummer #  "ERe.Währung";
    If (RecRead(814,1,0) <> _rNoRec) then begin
      $Lb.Wae1 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae2 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae3 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae4 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae5 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae6 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae7 -> wpCaption # "Wae.Kürzel";

      $Lb.Wae10-> wpCaption # "Wae.Kürzel";
      $Lb.Wae11-> wpCaption # "Wae.Kürzel";
      $Lb.Wae12-> wpCaption # "Wae.Kürzel";
      RecBufClear(814);
    end;

    // HW vom Kunden des Offenen Postens
    Adr.Kundennr # ERe.Lieferant;
    If (RecRead(100,2,0) <> _rNoRec) then begin
      Wae.Nummer # "Adr.VK.Währung";
      IF (RecRead(814,1,0) <> _rNoRec) then begin
        $Lb.HW1 -> wpCaption # "Wae.Kürzel";
        RecBufClear(814);
      end;
    end;

    $LB.ERe.Rest->wpcaption           # ANum(ERe.Rest,2);
    $LB.ERe.Skonto->wpcaption         # ANum(ERe.Skonto,2);
    $LB.ERe.SkontoProzent->wpcaption  # ANum(ERe.Skontoprozent,2);
    $LB.ZAu.Frei->wpcaption           # ANum(ZAu.Betrag-ZAu.Zugeordnet,2);
    $edERe.Zieldatum->winupdate(_WinUpdFld2Obj);
    $edERe.Skontodatum->winupdate(_WinUpdFld2Obj);
    $edZAu.Datum->winupdate(_WinUpdFld2Obj);
  end;


  if ((aName='') or (aName='edERe.Z.Nummer')) AND
    (cZList->wpDbFileNo = 560) then begin

    // W1 aus der Eingangsrech. übernehmen
    Wae.Nummer #  "ERe.Währung";
    If (RecRead(814,1,0) <> _rNoRec) then begin
      $Lb.Wae1 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae2 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae3 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae4 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae5 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae6 -> wpCaption # "Wae.Kürzel";
      $Lb.Wae7 -> wpCaption # "Wae.Kürzel";

      $Lb.Wae10-> wpCaption # "Wae.Kürzel";
      $Lb.Wae11-> wpCaption # "Wae.Kürzel";
      $Lb.Wae12-> wpCaption # "Wae.Kürzel";
      RecBufClear(814);
    end;
  end;

  if ((aName='') or ((aName='edERe.Z.Nummer') and ($edERe.Z.Nummer->wpchanged))) AND
    (cZList->wpDbFileNo = 560) then begin

    if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
      vZauDatum # Zau.ZahlDatum;

    Erx # RekLink(565, 561, 2, _recFirst);   // Zahlungseingang lesen
    if (Mode=c_modeView) then
      vZauDatum # Zau.ZahlDatum;

    Zau.ZahlDatum                     # vZauDatum;
    $LB.ERe.Rest->wpcaption           # ANum(ERe.Rest,2);
    $LB.ERe.Skonto->wpcaption         # ANum(ERe.Skonto,2);
    $LB.ERe.SkontoProzent->wpcaption  # ANum(ERe.Skontoprozent,2);
    $LB.ZAu.Frei->wpcaption           # ANum(ZAu.Betrag-ZAu.Zugeordnet,2);
    $edERe.Zieldatum->winupdate(_WinUpdFld2Obj);
    $edERe.Skontodatum->winupdate(_WinUpdFld2Obj);
    $edZAu.Datum->winupdate(_WinUpdFld2Obj);
  end;

  if (aName='') OR (aName = 'edERe.Z.Betrag') then begin
    vDiff     # $edERe.Z.Betrag -> wpCaptionFloat;
    if ("Ere.Währungskurs"<>0.0) then
      vBetragW1 # Rnd(vBetrag / "ERe.Währungskurs",2)
    else
      vBetragW1 # 0.0;
    ERe.Z.BetragW1  # vBetragW1;
  end;

  if (aName='') OR (aName = 'edERe.Z.Skontobetrag') then begin
    vDiff                 # ERe.Z.Skontobetrag;
    if ("Ere.Währungskurs"<>0.0) then
      ERe.Z.SkontobetragW1  # Rnd(vBetrag / "ERe.Währungskurs",2)
    else
      Ere.Z.SkontobetragW1 # 0.0;
  end;

  if (Mode=c_ModeNew) then begin
    vDiff     # ERe.Rest - ($edERe.Z.Betrag -> wpCaptionFloat);
    vBetrag2  # ERe.Rest - ERe.Z.Betrag - ERE.Z.Skontobetrag;
  end
  else if (Mode=c_ModeEdit) then begin

    vDiff     # ERe.Rest + ProtokollBuffer[561]->ERe.Z.Betrag + ProtokollBuffer[561]->ERe.Z.Skontobetrag
              - ($edERe.Z.Betrag -> wpCaptionFloat);
    vBetrag2  # ERe.Rest - ERe.Z.Betrag - ERe.Z.Skontobetrag;
    vBetrag2  # vBetrag2 + ProtokollBuffer[561]->ERe.Z.Betrag + ProtokollBuffer[561]->ERe.Z.SkontoBetrag;

    $LB.ERe.Rest->wpcaption # ANum(ERe.Rest + ProtokollBuffer[561]->ERe.Z.Betrag + ProtokollBuffer[561]->ERe.Z.SkontoBetrag,2);

  end
  else if (Mode=c_ModeView) then begin
    vDiff   # ERe.Rest;
    vBetrag2  # ERe.Rest;// - ERE.Z.Skontobetrag;
  end;

  $LB.ERe.Z.Diff->wpCaption # ANum(vDiff,2);
  $LB.ERe.Z.Rest  -> wpCaption # ANum(vBetrag2,2);


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // dynamische Pflichtfelder einfärben
  Lib_GuiCom:Pflichtfeld($edZAu.Datum);
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  if (RunAFX('ERe.Z.RecInit', '') < 0) then  // Ankerfunktion?
    RETURN;

  $Lb.Wae1            -> wpCaption # '';
  $Lb.HW1             -> wpCaption # '';


  // Eingangszuordnung aus Offenen Posten?
  if (cZList->wpDbFileNo = 560) then begin
    ERe.Z.Nummer # ERe.Nummer;
    $edERe.Z.Nummer->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Disable($edERe.Z.Nummer);
    Lib_GuiCom:Disable($bt.Rechnung);
    $edERe.Z.Zahlungsnr->WinFocusSet(true);
    if (Mode = c_modeNew) then RecBufClear(565);
  end
  else if (cZList->wpDbFileNo = 565) then begin
    // Eingangszuordnung aus Zahlungseingang?
    ERe.Z.Zahlungsnr # ZAu.Nummer;
    $edERe.Z.Zahlungsnr->wpCaptionInt # ERe.Z.Zahlungsnr;
    Lib_GuiCom:Disable($edERe.Z.Zahlungsnr);
    Lib_GuiCom:Disable($bt.Zahlung);
    $edERe.Z.Nummer->WinFocusSet(true);
  end;
end;



//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vAuto   : logic;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  If (Zau.ZahlDatum=0.0.0) then begin
    Lib_Guicom2:InhaltFehlt('Zahldatum', 'NB.Page1', 'edZAu.Datum');
    RETURN false;
  end;


  If (ERe.Z.Nummer=0) then begin
    RETURN false;
  end;


  if (ERe.Z.ZAhlungsnr<>0) then begin
    ZAu.Nummer # ERe.Z.Zahlungsnr;
    IF (RecRead(565,1,0) > 2) then begin
      Msg(560002,Translate('Zahlungen'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edERe.Z.Zahlungsnr->WinFocusSet(true);
      RETURN false;
    end;

    ERe.Nummer # ERe.Z.Nummer;
    IF (RecRead(560,1,0) > 2) then begin
      Msg(560003,Translate('Eingangsrechnung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edERe.Z.Zahlungsnr->WinFocusSet(true);
      RETURN false;
    end;

    if (ERe.InOrdnung=n) then begin
      Msg(560008,AInt(ERe.Nummer),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edERe.Z.Zahlungsnr->WinFocusSet(true);
      RETURN false;
    end;

    If (ERe.Lieferant <> ZAu.Lieferant) then begin
      Msg(560001,Translate('Lieferanten'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edERe.Z.Zahlungsnr->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Ere.Währungskurs"<>0.0) then
    ERe.Z.BetragW1        # Rnd(ERe.Z.Betrag / "ERe.Währungskurs",2)
  else
    ERe.Z.BetragW1        # 0.0;
  if ("Ere.Währungskurs"<>0.0) then
    ERe.Z.SkontobetragW1  # Rnd(ERe.Z.SkontoBetrag / "ERe.Währungskurs",2)
  else
    ERE.Z.SkontobetragW1 # 0.0;


  // Satz zurückspeichern & protokollieren  (keine Editierung möglich)
  if (Mode=c_ModeNew) then begin

    // ggf. automatischen Zahlungseingang generieren
    if (ERe.Z.Zahlungsnr=0) then begin
      if (Msg(561002,'',_WinicoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN false;

      TRANSON;

      ERe.Z.Zahlungsnr # ReadNummer('Zahlungsausgang'); // Nummer lesen
      if (ERe.Z.Zahlungsnr=0) then begin
        TRANSBRK;
        RETURN false;
      end;
      SaveNummer();                                     // Nummernkreis aktuallisiern

      ZAu.Nummer          # ERe.Z.Zahlungsnr;
      ZAu.Lieferant       # ERe.Lieferant;
      ZAU.LieferStichwort # ERe.Lieferstichwort;
      "ZAu.Währung"       # "ERe.Währung";
      "ZAu.Währungskurs"  # "ERe.Währungskurs";
      ZAu.Betrag          # ERe.Z.Betrag;
      ZAu.BetragW1        # ERe.Z.BetragW1;
      ZAu.Anlage.Datum    # Today;
      ZAu.Anlage.Zeit     # now;
      ZAu.Anlage.User     # gUsername;
      Erx # RekInsert(565,0,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
      vAuto # y;
    end
    else begin
      TRANSON;
    end;

    ERe.Z.Anlage.Datum  # Today;
    ERe.Z.Anlage.Zeit   # Now;
    ERe.Z.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Zahlungen und Restbeträge errechnen
    IF (RecLink(565,561,2,_RecLock) = _rOk) then begin
// 01.03.2019 AH wegen Vorkasse
//      if (vAuto=n) and (ZAu.Zahldatum<>0.0.0) then begin
//        TRANSBRK;
//        Msg(561001,'',0,0,0);
//        RETURN false;
//      end;
      ZAu.Zugeordnet    # Rnd(ZAu.Zugeordnet + ERe.Z.Betrag,2);
      ZAu.ZugeordnetW1  # Rnd(ZAu.ZugeordnetW1 + ERe.Z.BetragW1,2);
      Erx # RekReplace(565,_recUnlock,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    end;
    IF (RecRead(560,1,_RecLock) = _rOk) then begin
      ERe.Zahlungen   # Rnd(ERe.Zahlungen   + ERE.Z.Betrag + ERe.Z.Skontobetrag,2);
      ERe.ZahlungenW1 # Rnd(ERe.ZahlungenW1 + ERe.Z.BetragW1 + ERe.Z.SkontobetragW1,2);
      ERe.Rest        # Rnd(ERe.Brutto      - ERe.Zahlungen,2);
      ERe.RestW1      # Rnd(ERe.BruttoW1    - ERe.ZahlungenW1,2);
      if /**(ERe.Z.Rest__SkontoYN) or **/(Abs(Rnd(ERe.Rest))<1.0) then begin
        "ERe.Löschmarker" # '*';
      end
      else begin
        "ERe.Löschmarker" # '';
      end;
      Erx # RekReplace(560,_RecUnlock,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    end;

    TRANSOFF;

    if (vAuto) and (Rechte[Rgt_ZAu_Druck_Avis]) and (Set.ZAu.Druck.Avis<>'') then begin
      if (Set.ZAu.Druck.Avis='S') then begin
        Lib_Dokumente:Printform(565,'Zahlungsavis',false);
      end
      else begin
        if (Msg(565004,'',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes) then
          Lib_Dokumente:Printform(565,'Zahlungsavis',false);
      end;
    end;

    if (vAuto) and (Rechte[Rgt_ZAu_Druck_Scheck]) and (Set.ZAu.Druck.Scheck<>'') then begin
      if (Set.ZAu.Druck.Scheck='S') then begin
        Lib_Dokumente:Printform(565,'Scheck',false);
      end
      else begin
        if (Msg(565005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes) then
          Lib_Dokumente:Printform(565,'Scheck',false);
      end;
    end;


    RETURN true;  // Speichern erfolgreich
  end;



  // EDIT ------------------------------------------------

  TRANSON;

  Erx # RekReplace(gFile,_recUnlock,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  // Zahlungen und Restbeträge errechnen
  IF (RecLink(565,561,2,_RecLock) = _rOk) then begin
// 01.03.2019 AH: Wegen Vorkasse
//    if (ZAu.Zahldatum<>0.0.0) then begin
//      TRANSBRK;
//      Msg(561001,'',0,0,0);
//      RETURN false;
//    end;
    ZAu.Zugeordnet    # Rnd(ZAu.Zugeordnet + ERe.Z.Betrag - Protokollbuffer[561]->ERe.Z.Betrag,2);
    ZAu.ZugeordnetW1  # Rnd(ZAu.ZugeordnetW1 + ERe.Z.BetragW1 -Protokollbuffer[561]->ERe.Z.BetragW1,2);
    Erx # RekReplace(565,_recUnlock,'AUTO');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;
  IF (RecRead(560,1,_RecLock) = _rOk) then begin
    ERe.Zahlungen   # Rnd(ERe.Zahlungen   + ERE.Z.Betrag + ERe.Z.Skontobetrag -
        Protokollbuffer[561]->ERe.Z.Betrag - Protokollbuffer[561]->ERe.Z.Skontobetrag ,2);
    ERe.ZahlungenW1 # Rnd(ERe.ZahlungenW1 + ERe.Z.BetragW1 + ERe.Z.SkontobetragW1 -
        Protokollbuffer[561]->ERe.Z.BetragW1 - Protokollbuffer[561]->ERe.Z.SkontoBetragW1,2);

    ERe.Rest        # Rnd(ERe.Brutto      - ERe.Zahlungen,2);
    ERe.RestW1      # Rnd(ERe.BruttoW1    - ERe.ZahlungenW1,2);
    if /**(ERe.Z.Rest__SkontoYN) or*/ (Abs(Rnd(ERe.Rest))<1.0) then begin
      "ERe.Löschmarker" # '*';
    end
    else begin
      "ERe.Löschmarker" # '';
    end;
    Erx # RekReplace(560,_RecUnlock,'AUTO');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  TRANSOFF;

  PtD_Main:Compare(gFile);


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

  // Zahlungen und Restbeträge stornieren
  IF (RecLink(565,561,2,_RecLock) = _rOk) then begin
    // Projekt 1377/39
    if (ZAu.Zahldatum<>0.0.0) then begin
      Msg(561001,'',0,0,0);
      RETURN;
    end;
    ZAu.Zugeordnet    # ZAU.Zugeordnet - ERe.Z.Betrag;
    ZAu.ZugeordnetW1  # ZAU.ZugeordnetW1 - ERe.Z.BetragW1;
    RekReplace(565,_recUnlock,'AUTO');
  end;
  IF (RecLink(560,561,1,_RecLock) = _rOk) then begin
    ERe.Zahlungen   # Rnd(ERe.Zahlungen   - ERe.Z.Betrag - ERe.Z.Skontobetrag,2);
    ERe.ZahlungenW1 # Rnd(ERe.ZahlungenW1 - ERe.Z.BetragW1 - ERe.Z.SkontobetragW1,2);
    ERe.Rest        # Rnd(ERe.Brutto      - ERe.Zahlungen,2);
    ERe.RestW1      # Rnd(ERe.BruttoW1    - ERe.ZahlungenW1,2);
    "ERe.Löschmarker" # '';
    RekReplace(560,_RecUnlock,'AUTO');
  end;
  RekDelete(gFile,0,'MAN');

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
  Erx : int;
end;
begin

  if (aEvt:Obj->wpName='edERe.Z.Nummer') and ($edERe.Z.Nummer->wpchanged) then begin
    Erx # RecLink(560,561,1,0);   // Eingangsrech. lesen
    if (Erx > _rLocked) then RecBufClear(560);
    if ("ERe.Währung"<>"ZAu.Währung") then begin
      Msg(461002,'',_WinicoError,_WinDialogok,1);
      ERe.Z.Nummer # 0;
      RETURN false;
    end;
  end;

  if (aEvt:Obj->wpName='edERe.Z.Zahlungsnr') and ($edERe.Z.Zahlungsnr->wpchanged) then begin
    Erx # RecLink(565,561,2,0);   // Zahlungsausgang lesen
    if (Erx > _rLocked) then RecBufClear(565);
    if ("ERe.Währung"<>"ZAu.Währung") then begin
      Msg(461002,'',_WinicoError,_WinDialogok,1);
      ERe.Z.Zahlungsnr # 0;
      RETURN false;
    end;
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
    'Rechnung' : begin
      RecBufClear(560);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ERe.Verwaltung',here+':AusRechnung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Zahlungsausgang' : begin
      RecBufClear(565);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZAu.Verwaltung',here+':AusZahlungsausgang');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;
end;


//========================================================================
//  AusRechnung
//
//========================================================================

sub AusRechnung()
local begin
  vRechnung : int;
  vZahlung  : int;
  vErx  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(560,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Z.Nummer # ERe.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edERe.Z.Nummer->Winfocusset(false);

  // ggf. Labels refreshen
  RefreshIfm('');
end;


//========================================================================
//  AusZahlungseingang
//
//========================================================================

sub AusZahlungsausgang()
local begin
  vErx  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(565,0,_RecId,gSelected);
    // Feldübernahme
    ERe.Z.Zahlungsnr # ZAu.Nummer;

    gSelected # 0;

  end;
  // Focus auf Editfeld setzen:
  $edERe.Z.Zahlungsnr->Winfocusset(false);

  ERe.Z.Betrag  #   ZAu.Betrag;

  // ggf. Labels refreshen
  RefreshIfm('');
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
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Z_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Z_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Z_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Z_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Z_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ERe_Z_Loeschen]=n);


  RefreshIfm();

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
  vHdl : int;
  vMode : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, ERe.Z.Anlage.Datum, ERe.Z.Anlage.Zeit, ERe.Z.Anlage.User );
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
    'bt.Rechnung'   :   Auswahl('Rechnung');
    'bt.Lieferant'  :   Auswahl('Lieferant');
    'bt.Waehrung'   :   Auswahl('Waehrung');
    'bt.Zahlung'    :   Auswahl('Zahlungsausgang');
  end;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged
(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

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
//  Refreshmode();

  if (aMark=n) then begin
    Erx # RecLink(565,561,2,_recfirst);   // Zahlung holen
    if (Erx<=_rLocked) and (ZAu.Zahldatum<>0.0.0) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
  end;

  Erx # RecLink(560,561,1,0);


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

  if ((aName =^ 'edERe.Z.Nummer') AND (aBuf->ERe.Z.Nummer<>0)) then begin
    RekLink(560,560,1,0);   // Èingangsr.Nr holen
    Lib_Guicom2:JumpToWindow('ERe.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edERe.Z.Zahlungsnr') AND (aBuf->ERe.Z.Zahlungsnr<>0)) then begin
    RekLink(565,560,2,0);   // Zahlungsnr holen
    Lib_Guicom2:JumpToWindow('ZAu.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================