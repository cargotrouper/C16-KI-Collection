@A+
//==== Business-Control ==================================================
//
//  Prozedur    OfP_Z_Main
//                  OHNE E_R_G
//  Info
//    Steuert die Verwaltung der Zahlungseingänge für die Offenen Posten
//
//  22.09.2003  ST  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  14.02.2012  AI  lb.HW1 rausgenommen - Objekt unbekannt??!
//  09.01.2013  ST  Feld "Fibudatum" hinzugefügt und disabled (wird durch Fibuschnittstelle gesetzt)
//  26.05.2014  AH  von Fremd in Eigenwährung Umrechung über gefixten Kurs nicht mehr aus Vorgabe
//  2022-06-28  AH  ERX
//  26.07.2022  HA  Quick Jump
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
//    SUB AusZahlungseingang()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Lib_Nummern

define begin
  cTitle :    'Offene Posten Zahlungen'
  cFile :     461
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'OfP_Z'
  cZList :    $ZL.OfP.Zahlungen
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

Lib_Guicom2:Underline($edOfP.Z.Rechnungsnr);
Lib_Guicom2:Underline($edOfP.Z.Zahlungsnr);

  SetStdAusFeld('edOfP.Z.Rechnungsnr' ,'Rechnung');
  SetStdAusFeld('edOfP.Z.Zahlungsnr'  ,'Zahlungseingang');

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
  vText     : alpha;
  vText3    : alpha;
  vTmp      : int;
end;
begin

  if (Mode=c_ModeList) then begin
    vBetrag   # 0.0;
    vBetrag2  # 0.0;
    vBetrag3  # 0.0;

    if (gZLList->wpdbFileno=465) then begin
      Erx # RecLink(461,465,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vBetrag2 # Rnd(vBetrag2 + OfP.Z.Betrag,2);
        Erx # RecLink(461,465,1,_recNext);
      END;
      vBetrag   # ZEi.Betrag;
      vBetrag3  # vBetrag - vBetrag2;
      vText     # Translate('Zahlungsbetrag');
      vText3    # Translate('Restbetrag');
    end;

    if (gZLList->wpdbFileno=460) then begin
      Erx # RecLink(461,460,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vBetrag2 # Rnd(vBetrag2 + OfP.Z.Betrag,2);
        vBetrag3 # Rnd(vBetrag3 + OfP.Z.Skontobetrag,2);
        Erx # RecLink(461,460,1,_recNext);
      END;
      vBetrag   # Ofp.Rest;
      vText     # Translate('Restbetrag');
      vText3    # Translate('Skontobetrag');
    end;

    $lb.Ofp.z.BetragSumme->wpcaption # ANum(vBetrag,2);
    $lb.Ofp.z.ZugeordnetSumme->wpcaption # ANum(vBetrag2,2);
    $lb.Ofp.z.RestSumme->wpcaption # ANum(vBetrag3,2);
    $lb.Betrag1->wpcaption # vText;
    $lb.Betrag3->wpcaption # vText3;
  end;


  if (Mode=c_ModeNew) then begin
    if (OfP.Z.Zahlungsnr=0) then
      Lib_GuiCom:Enable($edZei.Datum)
    else
      Lib_GuiCom:Disable($edZei.Datum);
  end;

  if ((aName='') or (aName='edOfP.Z.Rechnungsnr')) then begin
    if (cZList->wpDbFileNo = 465) then begin
      Erx # RecLink(460,461,1,0);   // Offenen Posten lesen
      if (Erx > _rLocked) then RecBufClear(460);
    end;

    // W1 aus dem Offenen Posten übernehmen
    RecLink(814,460,7,_recFirst);
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
//    end;

    // HW vom Kunden des Offenen Postens
    Adr.Kundennr # OfP.Kundennummer;
    If (RecRead(100,2,0) <> _rNoRec) then begin
//      Wae.Nummer # "Adr.EK.Währung";
//      IF (RecRead(814,1,0) <> _rNoRec) then begin
//        $Lb.HW1 -> wpCaption # "Wae.Kürzel";
//        RecBufClear(814);
//      end;
    end;

    $LB.OfP.Rest->wpcaption           # ANum(OfP.Rest,2);
    $LB.OfP.Skonto->wpcaption         # ANum(OfP.Skonto,2);
    $LB.OfP.SkontoProzent->wpcaption  # ANum(OfP.Skontoprozent,2);
    $LB.Zei.Frei->wpcaption           # ANum(Zei.Betrag-Zei.Zugeordnet,2);
    $edOfP.Zieldatum->winupdate(_WinUpdFld2Obj);
    $edOfP.Skontodatum->winupdate(_WinUpdFld2Obj);
    $edZei.Datum->wpcaptiondate # Zei.Zahldatum;
  end;


  if ((aName='') or (aName='edOfP.Z.Rechnungsnr')) AND
    (cZList->wpDbFileNo = 460) then begin
    Erx # RecLink(465,461,2,0);   // Zahlungseingang lesen
    if (Erx > _rLocked) then RecBufClear(465);
    $LB.OfP.Rest->wpcaption           # ANum(OfP.Rest,2);
    $LB.OfP.Skonto->wpcaption         # ANum(OfP.Skonto,2);
    $LB.OfP.SkontoProzent->wpcaption  # ANum(OfP.Skontoprozent,2);
    $LB.Zei.Frei->wpcaption           # ANum(Zei.Betrag-Zei.Zugeordnet,2);
    $edOfP.Zieldatum->winupdate(_WinUpdFld2Obj);
    $edOfP.Skontodatum->winupdate(_WinUpdFld2Obj);
    $edZei.Datum->wpcaptiondate # Zei.Zahldatum;
  end;


  if (aName = 'edOfP.Z.Betrag') then begin
    vBetrag   # $edOfP.Z.Betrag -> wpCaptionFloat;
// 26.05.2014:
//    Wae_Umrechnen(vBetrag, "OfP.Währung", var vBetrag, 1);
    if (cZList->wpDbFileNo = 460) then begin
      if ("OfP.Währungskurs"<>0.0) then
        vBetragW1 # Rnd(vBetrag / "OfP.Währungskurs",2);
    end
    else begin
      if ("ZEi.Währungskurs"<>0.0) then
        vBetragW1 # Rnd(vBetrag / "Zei.Währungskurs",2);
    end;
    OfP.Z.BetragW1  # vBetragW1;
  end;

  if (aName = 'edOfP.Z.Skontobetrag') then begin
    vBetrag               # OfP.Z.Skontobetrag;
// 26.05.2014:
//    Wae_Umrechnen(vBetrag, "OfP.Währung", var OfP.Z.SkontobetragW1, 1);
    if (cZList->wpDbFileNo = 460) then begin
      if ("OfP.Währungskurs"<>0.0) then
        OfP.Z.SkontobetragW1  # Rnd(vBetrag / "OfP.Währungskurs",2);
    end
    else begin
      if ("Zei.Währungskurs"<>0.0) then
        OfP.Z.SkontobetragW1  # Rnd(vBetrag / "ZEi.Währungskurs",2);
    end;
  end;

  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
    vBetrag   # OfP.Rest - ($edOfP.Z.Betrag -> wpCaptionFloat);
    vBetrag2  # OfP.Rest - OfP.Z.Betrag - OfP.Z.Skontobetrag;
  end
  else begin
    vBetrag   # OfP.Rest;
    vBetrag2  # OfP.Rest;
  end;
  $LB.OfP.Z.Diff->wpCaption # ANum(vBetrag,2);
  $LB.OfP.Z.Rest->wpCaption # ANum(vBetrag2,2);

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  Lib_GuiCom:Disable($edOfp.Z.Fibudatum);

  $Lb.Wae1->wpCaption # '';
  $Lb.HW1->wpCaption  # '';

  // Focus setzen auf Feld:

  // Eingangszuordnung aus Offenen Posten?
  if (cZList->wpDbFileNo = 460) then begin
    OfP.Z.Rechnungsnr # OfP.Rechnungsnr;
//    $edOfP.Z.Rechnungsnr->wpCaptionInt # Ofp.Z.Rechnungsnr;
    $edOfP.Z.Rechnungsnr->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Disable($edOfP.Z.Rechnungsnr);
    Lib_GuiCom:Disable($bt.Rechnung);
    $edOfP.Z.Zahlungsnr->WinFocusSet(true);
    $edZei.Datum->wpcaptiondate # today;
  end;

  // Eingangszuordnung aus Zahlungseingang?
  if (cZList->wpDbFileNo = 465) then begin
    OfP.Z.Zahlungsnr # ZEi.Nummer;
    $edOfP.Z.Zahlungsnr->wpCaptionInt # Ofp.Z.Zahlungsnr;
    Lib_GuiCom:Disable($edOfP.Z.Zahlungsnr);
    Lib_GuiCom:Disable($bt.Zahlung);
    $edOfP.Z.Rechnungsnr->WinFocusSet(true);
    $edZei.Datum->wpcaptiondate # Zei.ZahlDatum;
  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vX,vY : float;
  Erx   : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung

  // Nummernvergabe
  If (Ofp.Z.Rechnungsnr=0) then begin
    RETURN false;
  end;

// 26.05.2014:
//  Wae_Umrechnen(OfP.Z.Betrag, "OfP.Währung", var OfP.Z.BetragW1, 1);
//  Wae_Umrechnen(OfP.Z.SkontoBetrag, "OfP.Währung", var OfP.Z.SkontoBetragW1, 1);
  if (cZList->wpDbFileNo = 460) then begin
    if ("OfP.Währungskurs"<>0.0) then begin
      OfP.Z.BetragW1        # Rnd(OfP.Z.Betrag / "OfP.Währungskurs",2);
      OfP.Z.SkontobetragW1  # Rnd(OfP.Z.SkontoBetrag / "OfP.Währungskurs",2);
    end;
  end
  else begin
    if ("Zei.Währungskurs"<>0.0) then begin
      OfP.Z.BetragW1        # Rnd(OfP.Z.Betrag / "Zei.Währungskurs",2);
      OfP.Z.SkontobetragW1  # Rnd(OfP.Z.SkontoBetrag / "Zei.Währungskurs",2);
    end;
  end;

  // Satz zurückspeichern & protokollieren  (keine Editierung möglich)
  if (Mode=c_ModeNew) then begin


    // ggf. automatischen Zahlungseingang generieren
    if (OfP.Z.Zahlungsnr=0) then begin

      if ($edZei.Datum->wpcaptiondate=0.0.0) then begin
        Msg(001200,Translate('Zahldatum'),0,0,0);
        $NB.Main->wpcurrent # 'NB.Page1';
        $edZei.Datum->WinFocusSet(true);
        RETURN false;
      end;

      if (Msg(461001,'',_WinicoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN false;

      TRANSON;

      OfP.Z.Zahlungsnr # ReadNummer('Zahlungseingang'); // Nummer lesen
      if (OfP.Z.Zahlungsnr=0) then begin
        TRANSBRK;
        RETURN false;
      end;
      SaveNummer();                                     // Nummernkreis aktuallisiern

      ZEi.Nummer          # OfP.Z.Zahlungsnr;
      ZEi.Kundennummer    # OfP.Kundennummer;
      ZEi.KundenStichwort # OfP.Kundenstichwort;
      "ZEi.Währung"       # "OfP.Währung";
      "ZEi.Währungskurs"  # "OfP.Währungskurs";
      ZEi.Betrag          # Ofp.Z.Betrag;
      ZEi.BetragW1        # OfP.Z.BetragW1;
      ZEi.Zahldatum       # $edZei.Datum->wpcaptiondate;
      ZEi.Anlage.Datum    # Today;
      ZEi.Anlage.Zeit     # now;
      ZEi.Anlage.User     # gUsername;
      Erx # RekInsert(465,0,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    end
    else begin
      TRANSON;
    end;

    OfP.Z.Anlage.Datum  # Today;
    OfP.Z.Anlage.Zeit   # Now;
    OfP.Z.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Zahlungen und Restbeträge errechnen
    IF (RecLink(465,461,2,_RecLock) = _rOk) then begin
      ZEi.Zugeordnet    # Rnd(ZEi.Zugeordnet + OfP.Z.Betrag,2);
      ZEi.ZugeordnetW1  # Rnd(ZEi.ZugeordnetW1 + OfP.Z.BetragW1,2);
      RekReplace(465,_recUnlock,'AUTO');
    end;

    IF (RecLink(460,461,1,_REcFirst|_RecLock) = _rOk) then begin
      OfP.Zahlungen   # Rnd(OfP.Zahlungen   + OfP.Z.Betrag + OfP.Z.Skontobetrag,2);
      OfP.ZahlungenW1 # Rnd(OfP.ZahlungenW1 + OfP.Z.BetragW1 + OfP.Z.SkontobetragW1,2);
      OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
      OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);
      if (OfP.Z.RestSkontoYN) or (Abs(Rnd(OfP.Rest))<1.0) then begin
        Erx # Ofp_Data:ReplaceMitLoeschmarker('*');
      end
      else begin
        Erx # Ofp_Data:ReplaceMitLoeschmarker('');
      end;
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;

      // bei erledigtem OfP, Finanzdaten des Kunden aktualisieren
      if ( "OfP.Löschmarker" = '*' ) then begin
        if ( RecLink( 100, 465, 2, _recFirst | _recLock ) = _rOk ) then begin
          vX # CnvFI( CnvID( ZEi.Zahldatum ) - CnvID( Ofp.Zieldatum ) );
          vY # Adr.Fin.Vzg.Offset * CnvFI( Adr.Fin.Vzg.AnzZhlg );
          Adr.Fin.Vzg.AnzZhlg # Adr.Fin.Vzg.AnzZhlg + 1;
          Adr.Fin.Vzg.Offset  # ( vX + vY ) / CnvFI( Adr.Fin.Vzg.AnzZhlg );
          RekReplace( 100, _recUnlock, 'AUTO' );
        end;
      end;
    end;

    TRANSOFF;


    RETURN true;  // Speichern erfolgreich
  end;


  RETURN false;
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
local begin
  Erx : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;


  // Zahlungen und Restbeträge stornieren
  IF (RecLink(465,461,2,_RecLock) = _rOk) then begin
    ZEi.Zugeordnet    # Rnd(ZEi.Zugeordnet - OfP.Z.Betrag,2);
    ZEi.ZugeordnetW1  # Rnd(ZEi.ZugeordnetW1 - OfP.Z.BetragW1,2);
    RekReplace(465,_recUnlock,'AUTO');
  end;

  TRANSON;

  IF (RecLink(460,461,1,_REcFirst|_RecLock) = _rOk) then begin
    OfP.Zahlungen   # Rnd(OfP.Zahlungen   - OfP.Z.Betrag - OfP.Z.Skontobetrag,2);
    OfP.ZahlungenW1 # Rnd(OfP.ZahlungenW1 - OfP.Z.BetragW1 - OfP.Z.SkontobetragW1,2);
    OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
    OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);
    Erx # Ofp_Data:ReplaceMitLoeschmarker('');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;
  end;

  RekDelete(gFile,0,'MAN');

  TRANSOFF;

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

  if (OfP.Z.Rechnungsnr=0) then begin
    if (aEvt:obj->wpname='edOfP.Z.Zahlungsnr') or
      (aEvt:obj->wpname='cbOfP.Z.RestSkontoYN') or
      (aEvt:obj->wpname='edOfP.Z.Bemerkung') or
      (aEvt:obj->wpname='edOfP.Z.Betrag') then begin

      $edOfP.Z.Rechnungsnr->winfocusset(true);
      RETURN false;
    end;
  end;

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

  if (aEvt:Obj->wpName='edOfP.Z.Rechnungsnr') and ($edOfP.Z.Rechnungsnr->wpchanged) then begin
    Erx # RecLink(460,461,1,0);   // Offenen Posten lesen
    if (Erx > _rLocked) then RecBufClear(460);
    if ("Ofp.Währung"<>"Zei.Währung") then begin
      Msg(461002,'',_WinicoError,_WinDialogok,1);
      Ofp.Z.Rechnungsnr # 0;
      RETURN false;
    end;
  end;

  if (aEvt:Obj->wpName='edOfP.Z.Zahlungsnr') and ($edOfP.Z.Zahlungsnr->wpchanged) and (Ofp.Z.Zahlungsnr<>0) then begin

    Erx # RecLink(465,461,2,0);   // Zahlungseingang lesen
    if (Erx > _rLocked) then RecBufClear(465);
    if ("Ofp.Währung"<>"Zei.Währung") then begin
      Msg(461002,'',_WinicoError,_WinDialogok,1);
      Ofp.Z.Zahlungsnr # 0;
//      $edOfP.Z.Zahlungsnr->winupdate(_WinUpdFld2Obj);
      RETURN false;
    end;
    $edZei.Datum->wpcaptiondate # Zei.Zahldatum;

    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edZei.Datum') and (Ofp.Z.Zahlungsnr<>0) then begin
        $edOfP.Z.Betrag->winFocusset(true)
      end;
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
      RecBufClear(460);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'OfP.Verwaltung',here+':AusRechnung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Zahlungseingang' : begin
      RecBufClear(465);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZEi.Verwaltung',here+':AusZahlungseingang');
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
    RecRead(460,0,_RecId,gSelected);
    // Feldübernahme
    if ("Ofp.Währung"<>"Zei.Währung") then begin
      Msg(461002,'',_WinicoError,_WinDialogok,1);
      end
    else begin
      OfP.Z.Rechnungsnr # OfP.RechnungsNr;
    end;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edOfP.Z.Rechnungsnr->Winfocusset(false);

  // ggf. Labels refreshen
  RefreshIfm('');
end;


//========================================================================
//  AusZahlungseingang
//
//========================================================================
sub AusZahlungseingang()
local begin
  vErx  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(465,0,_RecId,gSelected);
    // Feldübernahme
    if ("Ofp.Währung"<>"Zei.Währung") then begin
      Msg(461002,'',_WinicoError,_WinDialogok,1);
      end
    else begin
      OfP.Z.Zahlungsnr # ZEi.Nummer;
      $edZei.Datum->wpcaptiondate # Zei.Zahldatum;
    end;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edOfP.Z.Zahlungsnr->Winfocusset(false);

  OfP.Z.Betrag  #   ZEi.Betrag;

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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Z_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Z_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');         /* Zahlungen nicht Editierbar */
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_Modelist) or (Rechte[Rgt_OfP_Z_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_Modelist) or (Rechte[Rgt_OfP_Z_Loeschen]=n);

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, OfP.Z.Anlage.Datum, OfP.Z.Anlage.Zeit, OfP.Z.Anlage.User );
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
    'bt.Rechnung' :   Auswahl('Rechnung');
    'bt.Zahlung'  :   Auswahl('Zahlungseingang');
  end;

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
  Erx # RecLink(465,461,2,0);   // Zahlungseingang lesen
  if (Erx>_rLocked) then RecBufClear(465);

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
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-60;
    gZLList->wparea # vRect;

    Lib_GUiCom:ObjSetPos($lb.Betrag1, 16, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Ofp.z.Betragsumme, 144, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Wae10, 240, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Betrag2, 376, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Ofp.z.ZugeordnetSumme, 504, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Wae11, 600, vRect:bottom+8);

    Lib_GUiCom:ObjSetPos($lb.Betrag3, 376, vRect:bottom+8+28);
    Lib_GUiCom:ObjSetPos($lb.Ofp.z.Restsumme, 504, vRect:bottom+8+28);
    Lib_GUiCom:ObjSetPos($lb.Wae10, 600, vRect:bottom+8+28);
  end;
	RETURN (true);
end;



sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edOfP.Z.Rechnungsnr') AND (aBuf->OfP.Z.Rechnungsnr<>0)) then begin
    RekLink(460,461,1,0);   // Rechnungsnr. holen
    Lib_Guicom2:JumpToWindow('OfP.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edOfP.Z.Zahlungsnr') AND (aBuf->OfP.Z.Zahlungsnr<>0)) then begin
    RekLink(465,461,2,0);   // Zahlungsnr. holen
    Lib_Guicom2:JumpToWindow('ZEi.Verwaltung');
    RETURN;
  end;
  
end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================