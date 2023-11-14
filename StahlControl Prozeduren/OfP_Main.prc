@A+
//==== Business-Control ==================================================
//
//  Prozedur    OfP_Main
//                OHNE E_R_G
//  Info
//
//
//  04.09.2003  ST  Erstellung der Prozedur
//  03.02.2009  ST  Berechnung des Wiedervorlagedatums hinzugefügt
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  15.10.2012  AI  "RecSave" addiert Zahlungen
//  08.07.2016  AH  "JumpTo"
//  27.10.2020  AH  Projektnr.
//  16.11.2021  MR  Neu   AFX OfP.EvtLstDataInit & OfP.Init.Pre Projekt(2166/176)
//  02.02.2022  AH  ERX, Filter
//  25.07.2022  HA  Quick Jump
//  2022-12-20  DS  Sonderlocke für Handke Wiros aus Ticket 2343/93
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
//    SUB AusKunde()
//    SUB AusTyp()
//    SUB AusZahlungsbed()
//    SUB AusLieferbed()
//    SUB AusWaehrung()
//    SUB AusVertreter()
//    SUB AusVerband()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB JumpTo(aName : alpha; aBuf  : int);
//
//========================================================================
@I:Def_Global
@I:Def_Rights


// Definition der Struktur um den Mahnungslauf zu drucken
//global KndMahnData begin
//  itemKunde     : alpha;
//  itemRechnung  : int;
//end;

define begin
  cTitle :    'Offene Posten'
  cFile :     460
  cMenuName : 'OfP.Bearbeiten'
  cPrefix :   'OfP'
  cZList :    $ZL.OffenePosten
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

Lib_Guicom2:Underline($edOfP.Kundennummer);
Lib_Guicom2:Underline($edOfP.Zahlungsbed);
Lib_Guicom2:Underline($edOfP.Lieferbed);
Lib_Guicom2:Underline($edOfP.Waehrung);
Lib_Guicom2:Underline($edOfP.Rechnungstyp);
Lib_Guicom2:Underline($edOfP.Vertreter);
Lib_Guicom2:Underline($edOfP.Verband);


  SetStdAusFeld('edOfP.Kundennummer'  ,'Kunde');
  SetStdAusFeld('edOfP.Rechnungstyp'  ,'Typ');
  SetStdAusFeld('edOfP.Zahlungsbed'   ,'Zahlungsbed');
  SetStdAusFeld('edOfP.Lieferbed'     ,'Lieferbed');
  SetStdAusFeld('edOfP.Waehrung'      ,'Waehrung');
  SetStdAusFeld('edOfP.Vertreter'     ,'Vertreter');
  SetStdAusFeld('edOfP.Verband'       ,'Verband');

  RunAFX('OfP.Init.Pre',aint(aEvt:Obj));
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
  vTmp  : int;
  Erx   : int;
end;
begin


  // Mahnungen anzeigen
  $Lb.Mahnung1  -> wpCaption # CnvAd(Ofp.Mahndatum1);
  $Lb.Mahnung2  -> wpCaption # CnvAd(Ofp.Mahndatum2);
  $Lb.Mahnung3  -> wpCaption # CnvAd(Ofp.Mahndatum3);


  // Betragslabels Refreshen
  $Lb.OfP.Zahlungen -> wpCaption # ANum(OfP.Zahlungen,2);
  $Lb.ZahlungenW1   -> wpCaption # ANum(OfP.ZahlungenW1,2);
  $Lb.OfP.Rest      -> wpCaption # ANum(OfP.Rest,2);
  $Lb.RestW1        -> wpCaption # ANum(OfP.RestW1,2);

  //  Restforderung ermitteln und Darstellen ST 2019-03-25 Projekt 1968/7
  $Lb.OfP.RestForderung -> wpCaption  # ANum(OfP.Rest + OfP.Zinsen + "OfP.Mahngebühr",2);
  $Lb.RestForderungW1 -> wpCaption  # ANum(OfP.RestW1 + OfP.ZinsenW1 + "OfP.MahngebührW1",2);


  if (aName = '') then begin

    // Hauswährung setzen
    $lb.HW1 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW2 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW3 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW4 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW5 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW6 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW7 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW8 -> wpcaption # "Set.Hauswährung.Kurz";
    $lb.HW9 -> wpcaption # "Set.Hauswährung.Kurz";
  end;


  if (aName='') or (aName='edOfP.Kundennummer') then begin
    Erx # RecLink(100,460,4,0);
    if (Erx<=_rLocked) and (Ofp.Kundennummer<>0) then begin
      $Lb.Stichwort->wpcaption# Adr.Stichwort;
      $Lb.Name->wpcaption     # Adr.Name;
      $Lb.Strasse->wpcaption  # "Adr.Straße";
      $Lb.Ort->wpcaption      # Adr.Ort;
      $Lb.Telefon->wpcaption  # Adr.Telefon1;
      $Lb.RefNr->wpcaption    # AInt(Adr.LieferantenNr);
//      "OfP.Währung"           # "Adr.VK.Währung";
//      RefreshIfm('edOfP.Währung');
      end
    else begin
      $Lb.Stichwort->wpcaption # '';
      $Lb.Name->wpcaption      # '';
      $Lb.Strasse->wpcaption   # '';
      $Lb.Ort->wpcaption       # '';
      $Lb.Telefon->wpcaption   # '';
      $Lb.RefNr->wpcaption     # '';
    end;
  end;

  if (aName='') or (aName='edOfP.Rechnungstyp') then begin
    Erx # RecLink(853,460,11,0);
    if (Erx<=_rLocked) then
      $lb.Typ->wpcaption # RTy.Bezeichnung
    else
      $lb.Typ->wpcaption # '';
  end;

  if (aName='') or (aName='edOfP.Zahlungsbed') then begin
    Erx # RecLink(816,460,8,0);
    if (Erx<=_rLocked) then begin
      $Lb.Zahlungsbed->wpCaption # ZaB.Bezeichnung1.L1;
      $Lb.Zahlungsbed2->wpCaption # ZaB.Bezeichnung2.L1;
      end
    else begin
      $Lb.Zahlungsbed->wpCaption # '';
      $Lb.Zahlungsbed2->wpCaption # '';
    end;
  end;

  if (aName='') or (aName='edOfP.Lieferbed') then begin
    Erx # RecLink(815,460,9,0);
    if (Erx<=_rLocked) then begin
      $Lb.Lieferbed->wpCaption # LiB.Bezeichnung.L1;
      end
    else begin
      $Lb.Lieferbed->wpCaption # '';
    end;
  end;

  /* Auswaehrung() */

  if (aName='') or (aName='edOfP.Waehrung') then begin
    Erx # RecLink(814,460,7,0);
    if (Erx<=_rLocked) then begin
      $edOfP.Waehrung->wpCaptionInt # "OfP.Währung";
      $Lb.Waehrung->wpCaption       # "Wae.Kürzel";
//      "Ofp.Währungskurs"            # "Wae.VK.Kurs";
    end else begin
      $Lb.Waehrung->wpcaption # '';
    end;

    $lb.Wae1->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae2->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae3->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae4->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae5->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae6->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae7->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae8->wpCaption     # $Lb.Waehrung->wpcaption;
    $lb.Wae9->wpCaption     # $Lb.Waehrung->wpcaption;
  end;

  if (aName='') or (aName='edOfP.Vertreter') then begin
    Erx # RecLink(110,460,5,0);
    if (Erx<=_rLocked) then begin
      $Lb.Vertreter->wpCaption # Ver.Stichwort;
      end
    else begin
      $Lb.Vertreter->wpCaption # '';
    end;
  end;

  if (aName='') or (aName='edOfP.Verband') then begin
    Erx # RecLink(110,460,6,0);
    if (Erx<=_rLocked) then begin
      $Lb.Verband->wpCaption # Ver.Stichwort;
      end
    else begin
      $Lb.Verband->wpCaption # '';
    end;
  end;

  if (aName='') or (aName='edOfP.Projektnr') then begin
    Erx # RecLink(120,460,10,0); // Projekt holen
    if (Erx<=_rLocked) and (Erl.Projektnr<>0) then
      $lb.Projekt->wpcaption # Prj.Stichwort
    else
      $lb.Projekt->wpcaption # '';
  end;

  // Hauswährungsfelder berechenen, Wenn eine seperate Währung eingetragen wird
  if ("OfP.Währungskurs" <> 0.0) then begin
    if ($lb.HW1 -> wpCaption = '') then begin
      // Leere Felder anzeigen, wenn keine HW gefunden wurde
      $Lb.NettoW1     -> WpCaption  # '';
      $Lb.SteuerW1    -> WpCaption  # '';
      $Lb.BruttoW1    -> WpCaption  # '';
      $Lb.SkontoW1    -> WpCaption  # '';
      $Lb.MahnW1      -> WpCaption  # '';
      $Lb.ZinsenW1    -> WpCaption  # '';
      $Lb.ZahlungenW1 -> WpCaption  # '';
      $Lb.RestW1      -> WpCaption  # '';
      $Lb.RestForderungW1  -> WpCaption  # '';
    end else begin
      // Werte errechnen
      if (Mode=c_modeedit) or (Mode=c_modenew) then begin
        OfP.NettoW1         # Rnd(OfP.Netto        / "OfP.Währungskurs",2);
        OfP.SteuerW1        # Rnd(OfP.Steuer       / "OfP.Währungskurs",2);
        OfP.BruttoW1        # Rnd(OfP.Brutto       / "OfP.Währungskurs",2);
        OfP.SkontoW1        # Rnd(OfP.Skonto       / "OfP.Währungskurs",2);
        "OfP.MahngebührW1"  # Rnd("OfP.Mahngebühr" / "OfP.Währungskurs",2);
        OfP.ZinsenW1        # Rnd(OfP.Zinsen       / "OfP.Währungskurs",2);
        OfP.ZahlungenW1     # Rnd(OfP.Zahlungen    / "OfP.Währungskurs",2);
        OfP.RestW1          # Rnd(OfP.Rest         / "OfP.Währungskurs",2);
      end;
      // Werte an die Labels übergeben
      $Lb.NettoW1     -> WpCaption  # ANum(OfP.NettoW1,2);
      $Lb.SteuerW1    -> WpCaption  # ANum(OfP.SteuerW1,2);
      $Lb.BruttoW1    -> WpCaption  # ANum(OfP.BruttoW1,2);
      $Lb.SkontoW1    -> WpCaption  # ANum(OfP.SkontoW1,2);
      $Lb.MahnW1      -> WpCaption  # ANum("OfP.MahngebührW1",2);
      $Lb.ZinsenW1    -> WpCaption  # ANum(OfP.ZinsenW1,2);
      $Lb.ZahlungenW1 -> WpCaption  # ANum(OfP.ZahlungenW1,2);
      $Lb.RestW1      -> WpCaption  # ANum(OfP.RestW1,2);
    end;

  end;


  // Veränderte Felder in Objekte schreiben
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
  // Focus setzen auf Feld:
  $edOfP.Rechnungsnr->WinFocusSet(true);

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

  // Kunde
  if ("OfP.Kundennummer"<>0) then begin
    Erx # RecLink(100,460,4,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Kunde'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edOfP.Kundennummer->WinFocusSet(true);
      RETURN false;
    end;
  end else begin
    Msg(001200,Translate('Kunde'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page2';
    $edOfP.Kundennummer->WinFocusSet(true);
    RETURN false;
  end;


  // Auftragsnr
  /*
  if ("OfP.Auftragsnr"<>0) then begin
    Erx # RecLink(xxx,460,x,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Auftrag'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edOfP.Auftragsnr->WinFocusSet(true);
      RETURN false;
    end;
  end;
  */

  // Vertreter
  if ("OfP.Vertreter"<>0) then begin
    Erx # RecLink(110,460,5,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Vertreter'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edOfP.Vertreter->WinFocusSet(true);
      RETURN false;
    end;
  end;

  // Verband
  if ("OfP.Verband"<>0) then begin
    Erx # RecLink(110,460,6,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Verband'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edOfP.Verband->WinFocusSet(true);
      RETURN false;
    end;
  end;

  // Zab
  if ("OfP.Zahlungsbed"<>0) then begin
    Erx # RecLink(816,460,8,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Zahlungsbedingung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edOfP.Zahlungsbed->WinFocusSet(true);
      RETURN false;
    end;
  end else begin
    Msg(001200,Translate('Zahlungsbedingung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page2';
    $edOfP.Kundennummer->WinFocusSet(true);
    RETURN false;
  end;

  // Lbd
  if ("OfP.Lieferbed"<>0) then begin
    Erx # RecLink(815,460,9,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Lieferbedingung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edOfP.Lieferbed->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // 15.10.2012 AI:
  OFP.Zahlungen   # 0.0;
  OFP.ZahlungenW1 # 0.0;
  FOR Erx # RecLink(461,460,1,_recFirst)
  LOOP Erx # RecLink(461,460,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    OfP.Zahlungen   # Rnd(OfP.Zahlungen   + OfP.Z.Betrag + OfP.Z.Skontobetrag,2);
    OfP.ZahlungenW1 # Rnd(OfP.ZahlungenW1 + OfP.Z.BetragW1 + OfP.Z.SkontobetragW1,2);
  END;
  OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
  OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);


  // Wiedervorlage errechnen
  if (Ofp.Wiedervorlage=0.0.0) then
     OfP.Wiedervorlage # OfP_Data:BerechneWiedervorlage();



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
    OfP.Anlage.Datum  # Today;
    OfP.Anlage.Zeit   # Now;
    OfP.Anlage.User   # gUsername;
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
local begin
  vX  : float;
  Erx : int;
end;
begin

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  If (Recread(460,1,_RecLock) = _rOK) then begin
    TRANSON;

    if "OfP.Löschmarker" = '' then
      Erx # Ofp_Data:ReplaceMitLoeschmarker('*')
    else
      Erx # Ofp_Data:ReplaceMitLoeschmarker('');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;

    TRANSOFF;

    // Finanzdaten des Kunden aktualisieren
    if ( RecLink( 461, 460, 1, _recLast ) <= _rLocked ) then begin
      RecLink( 465, 461, 2, _recFirst ); // Zahlungseingang
      vX # CnvFI( CnvID( ZEi.Zahldatum ) - CnvID( OfP.Zieldatum ) )
      if ( RecLink( 100, 465, 2, _recFirst | _recLock ) = _rOk ) then begin
        if ( "OfP.Löschmarker" = '*' ) then begin
          vX # Adr.Fin.Vzg.Offset * CnvFI( Adr.Fin.Vzg.AnzZhlg ) + vX;
          Adr.Fin.Vzg.AnzZhlg # Adr.Fin.Vzg.AnzZhlg + 1;
          if (Adr.Fin.Vzg.AnzZhlg<>0) then
            Adr.Fin.Vzg.Offset  # vX / CnvFI( Adr.Fin.Vzg.AnzZhlg );
        end
        else begin
          vX # Adr.Fin.Vzg.Offset * CnvFI( Adr.Fin.Vzg.AnzZhlg ) - vX;
          Adr.Fin.Vzg.AnzZhlg # Adr.Fin.Vzg.AnzZhlg - 1;
          if ( Adr.Fin.Vzg.AnzZhlg = 0 ) then begin
            Adr.Fin.Vzg.Offset # 0.0;
          end
          else begin
            if (Adr.Fin.Vzg.AnzZhlg<>0) then
              Adr.Fin.Vzg.Offset # vX / CnvFI( Adr.Fin.Vzg.AnzZhlg );
          end;
        end;
        RekReplace( 100, _recUnlock, 'AUTO' );
      end;
    end;
  end
  else begin
    Msg(001000+Erx,gTitle,0,0,0);
  end;
  // RekDelete(gFile,0,'MAN');
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
local begin
  vA    : alpha;
end;

begin

  case aBereich of
    'Projekt' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjekt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

   'Kunde' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

   'Typ' : begin
      RecBufClear(853);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rty.Verwaltung',here+':AusTyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Zahlungsbed' : begin
      RecBufClear(816);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZaB.Verwaltung',here+':AusZahlungsbed');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Lieferbed' : begin
      RecBufClear(815);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LiB.Verwaltung',here+':AusLieferbed');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Waehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Vertreter' : begin
      RecBufClear(110);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusVertreter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Verband' : begin
      RecBufClear(110);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusVerband');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

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
    OfP.Projektnr # Prj.Nummer;
    gSelected # 0;
  end;

  // Focus auf Editfeld setzen:
  $edOfP.Projektnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edOfP.Projektnr');
end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);

    // Feldübernahme
    OfP.Kundennummer    # Adr.Kundennr;
    OfP.KundenStichwort # Adr.Stichwort;
    gSelected # 0;
  end;

  // Focus auf Editfeld setzen:
  $edOfP.Kundennummer->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edOfP.Kundennummer');
end;


//========================================================================
//  AusTyp
//
//========================================================================
sub AusTyp()
begin
  if (gSelected<>0) then begin
    RecRead(853,0,_RecId,gSelected);
    gSelected # 0;

    // Feldübernahme
    OfP.Rechnungstyp  # RTy.Nummer;
  end;

  // Focus auf Editfeld setzen:
  $edOfP.Rechnungstyp->Winfocusset(false);
end;


//========================================================================
//  AusZahlungsbed
//
//========================================================================
sub AusZahlungsbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(816,0,_RecId,gSelected);
    gSelected # 0;
    OfP.Zahlungsbed   # ZaB.Nummer;
    OfP_Data:BerechneZieldaten( today );
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edOfP.Zahlungsbed->Winfocusset(false);
  RefreshIfm('edOfP.Zahlungsbed');
end;


//========================================================================
//  AusLieferbed
//
//========================================================================
sub AusLieferbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(815,0,_RecId,gSelected);
    gSelected # 0;
    OfP.Lieferbed # LiB.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edOfP.Lieferbed->Winfocusset(false);
  RefreshIfm('edOfP.Lieferbed');
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    gSelected # 0;
    "OfP.Währung"  # Wae.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edOfP.Waehrung->Winfocusset(false);
  RefreshIfm('edOfp.Waehrung');
end;


//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    OfP.Vertreter # Ver.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edOfP.Vertreter->Winfocusset(false);
  RefreshIfm('edOfP.Vertreter');
end;


//========================================================================
//  AusVerband
//
//========================================================================
sub AusVerband()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    OfP.Verband # Ver.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edOfP.Verband->Winfocusset(false);
  RefreshIfm('edOfP.Verband');
end;


//========================================================================
//  AusZahlungen
//
//========================================================================
sub AusZahlungen()
begin
  gSelected # 0;
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  RefreshIfm();
RETURN;
/****
  RecRead(gFile, 1, _recLock);
  OfP.Zahlungen   # 0.0;
  OfP.ZahlungenW1 # 0.0;
  OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
  OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);
  Erx # RecLink(461,460,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    OfP.Zahlungen   # Rnd(OfP.Zahlungen   + OfP.Z.Betrag + OfP.Z.Skontobetrag,2);
    OfP.ZahlungenW1 # Rnd(OfP.ZahlungenW1 + OfP.Z.BetragW1 + OfP.Z.SkontobetragW1,2);
    OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
    OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);
    Erx # RecLink(461,460,1,_recNext);
  END;
  RekReplace(gFile,_recUnlock,'AUTO');

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);

  RefreshIfm();
****/
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_OfP_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Restore');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Abl_OfP_Restore]=n) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Zahlung');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_OffenepostenZAhl]=false));
  vHdl # gMenu->WinSearch('Mnu.Kontierung');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Erloeskonten]=false));

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
  Erx           : int;
  vHdl          : int;
  vMarked       : int;
  vFilter       : int;
  vMahnTree     : int;
  vMFile        : int;
  vMID          : Int;
  vItem         : int;
  vCurrentOfp   : int;
  vRest         : float;
  vNetto        : float;
  vTmp          : int;
  vDate         : date;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem -> wpName) of

    'Mnu.Filter.Start' : begin    // 02.02.2022 AH
      Ofp_Mark_Sel(false, '460.xml');
      RETURN true;
    end;

    
    'Mnu.DMS' : begin
      RecLink(100, 460, 4, _recFirst);   // Kunde holen
      DMS_ArcFlow:ShowAbm('RE', OfP.Rechnungsnr, Adr.Nummer);
    end;


    'Mnu.Mahndatum' : begin
      vMarked # gMarkList->CteRead(_CteFirst);
      if(vMarked = 0) then begin
        Msg(997006, '', 0, 0, 0);
        RETURN false;
      end;

      if(Dlg_Standard:Datum('Mahndatum', var vDate, today) = false) then
        RETURN false;

      TRANSON;
      FOR vMarked # gMarkList->CteRead(_CteFirst);
      LOOP vMarked # gMarkList->CteRead(_CteNext,vMarked);
      WHILE (vMarked > 0) DO BEGIN
        Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);

        if (vMFile <> 460) then // nur Ofp
          CYCLE;

        RecRead(460, 0, _RecId, vMID);

        if(Ofp_Data:SetMahndatum(vDate) = false) then begin
          TRANSBRK;
          ErrorOutput;
          RETURN false;
        end;

      END;

      TRANSOFF;

      gMdi -> Winupdate();
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);

      Msg(999998, '', 0, 0, 0);
    end;

    'Mnu.Summe' : begin
    
      // 2022-12-20  DS  Sonderlocke für Handke Wiros aus Ticket 2343/93
      vRest # Ofp_Data:BerechneSummeRest(var vNetto);
      
      RecRead(903, 1, _recFirst);  // Settings lesen
      if StrCnv(Set.Installname, _StrLower) = 'hwe' then
      begin
        // Erweiterte Meldung für Handke Wiros
        Msg(99, 'Die Summe offener Posten beträgt ' + cnvAF(vRest) + ' €' + cCrlf + 'Die Summe aller Nettos der Posten beträgt ' + cnvAF(vNetto) + ' €', _WinIcoInformation, 0, 0);
      end
      else
      begin
        // STD Meldung
        Msg(99, 'Die Summe offener Posten beträgt ' + cnvAF(vRest) + ' €', _WinIcoInformation, 0, 0);
      end
    end;


    'Mnu.Restore' : begin
      OfP_Abl_Data:RestoreAusAblage();
      RecRead(450,1,0);
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Mark.Sel' : begin
      Ofp_Mark_Sel();
    end;


    'Mnu.Rechnung' : begin
      RecBufClear(915);
      gDokTyp # 'RECH';

//      WinEvtProcessSet(_winevtinit,false);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dok.Verwaltung','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(915,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,450);

      Erx # RecLink(450,460,2,_recFirst); // Erlös holen, 08.11.2017 AH
      if (Erl.Rechnungstyp=c_Erl_SammelVK) then begin
        vFilter->RecFilterAdd(2,_FltAND,_FltEq,'SaRE');
        vFilter->RecFilterAdd(2,_FltOR,_FltEq,'SaREL');
      end
      else
        vFilter->RecFilterAdd(2,_FltAND,_FltEq,'RE');

      vFilter->RecFilterAdd(3,_FltAND,_FltScan, cnvai(Ofp.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8));
      gZLList->wpdbfilter # vFilter;
//      WinEvtProcessSet(_winevtinit,true);

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, OfP.Anlage.Datum, OfP.Anlage.Zeit, OfP.Anlage.User, "Ofp.Lösch.Datum", "Ofp.Lösch.Zeit", "Ofp.Lösch.User");
    end;


    'Mnu.Kontierung' : begin
      RecBufClear(451);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Erl.K.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
//      gZLList->WinFocusSet(true);
    end;


    'Mnu.Zahlung' : begin
      RecBufClear(461);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'OfP.Z.Verwaltung',here+':AusZahlungen',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
//      gZLList->WinFocusSet(true);
    end;


    'Mnu.Druck.Konto' : begin
      Lib_Dokumente:Printform(460,'Kontoauszug',true);
    end;


    'Mnu.Druck.Mahnungen' : begin
      // Mahnungsliste fürs Sortieren erstellen
      vMahnTree # CteOpen(_CteTreeCI);
      If (vMahnTree = 0) then RETURN false;

      vMarked # gMarkList->CteRead(_CteFirst);
      WHILE (vMarked > 0) DO BEGIN
        Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);
        if (vMFile=460) then begin
          RecRead(460,0,_RecId,vMID);

          // wurde dieser Kunde schon gemahnt?
          vItem # vMahnTree->CteRead(_CteFirst | _CteSearch, 0, AInt(OfP.Kundennummer));
          if (vItem=0) then begin // NEIN -> Merken und mahnen
            vItem # CteOpen(_CteItem);
            if (vItem<>0) then begin
              vItem->spName # AInt(OfP.Kundennummer);
              vItem->spID   # Ofp.Rechnungsnr;
              CteInsert(vMahnTree,vItem);
              // EINE Mahnung drucken
              Lib_Dokumente:Printform(460,'Mahnung',true);
            end;
          end;
        end;

        vMarked # gMarkList->CteRead(_CteNext,vMarked);
      END;

      /***************************************************/
      /***************** VERBUCHEN ***********************/
      /***************************************************/
      if (Msg(460001,'',1,2,1) = _WinIdOk) then begin

        vMarked # gMarkList->CteRead(_CteFirst);
        WHILE (vMarked > 0) DO BEGIN
          Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);
          if (vMFile=460) then begin

            Erx # RecRead(460,0,_RecId,vMID);
            if (Erx=_rOK) then begin

              RecRead(460,1,_recLock);

//              OfP.Wiedervorlage # Today;      // Alte Version ST 2009-02-06 geändert auf:

              Case OfP.Mahnstufe of
                0 : begin
                      OfP.Mahndatum1    # today;
                    end;
                1 : begin
                      OfP.Mahndatum2  # today;

                    end;
                2 : begin
                      OfP.Mahndatum3  # today;
                    end;
                3 : begin
                      OfP.Mahndatum3  # today;
                    end;
              End;
              Ofp.Mahnstufe   # Ofp.Mahnstufe + 1;
              if (Ofp.Mahnstufe > 3) then
                Ofp.Mahnstufe # 3;

              // Wiedervorlagedatum errechnen  ST 2009-02-06
              OfP.Wiedervorlage # OfP_Data:BerechneWiedervorlage();

              RekReplace(460,_RecUnlock,'AUTO');
//debug('inc :' +cnvai(ofp.rechnungsnr));
            end;

          end;

          vMarked # gMarkList->CteRead(_CteNext,vMarked);
        END;

      end;  // Verbuchen

      vMahnTree->CteClear(true);
      vMahnTree->CteClose();

    end;  // Mahnung

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
    'bt.Kunde'        :   Auswahl('Kunde');
    'bt.Typ'          :   Auswahl('Typ');
    'bt.Zahlungsbed'  :   Auswahl('Zahlungsbed');
    'bt.Lieferbed'    :   Auswahl('Lieferbed');
    'bt.Waehrung'     :   Auswahl('Waehrung');
    'bt.Projekt'      :   Auswahl('Projekt');
    'bt.Vertreter'    :   Auswahl('Vertreter');
    'bt.Verband'      :   Auswahl('Verband');
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
  vCol  : int;
  vDat  : date;
end;
begin

  if (aMark) then begin
    if (RunAFX('OfP.EvtLstDataInit','y')<0) then RETURN;
  end
  else if (RunAFX('OfP.EvtLstDataInit','n')<0) then RETURN;
  // Zeilenfarbe anpassen

  // Gelöschte Materialien einfärben
  if (aMark=n) then begin
    vCol # 0;
    if ("OfP.Löschmarker"='*') then
      vCol # Set.Col.RList.Deletd;

    if (vCol<>0) then begin
      Lib_GuiCom:ZLColorLine(gZLList,vCol);
      RETURN; // gelöschte Materialien bekommen keine weitere Farbmarkierung
    end;

  end;


  // Fällige Einträge für Wiedervorlage einfärben
  if (aMark=n) then begin
    vCol # 0;
    vDat # OfP.Wiedervorlage;

    if ("OfP.Löschmarker" <> '*') and (vDat < TODAY) and (vDat<>0.0.0) then
      vCol # _winColLightRed;

    if (vCol<>0) then
      Lib_GuiCom:ZLColorLine(gZLList,vCol);

  end;


  /// ---------------------------------
  // Jumplogik kennzeichnen
  Lib_GuiCom:ZLQuickJumpInfo($clmOfp.Kundenstichwort);
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
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  Erx : int;
end;
begin
  if (aName = StrCnv('clmOfp.KundenStichwort',_StrUpper)) then begin
    Adr.Kundennr # aBuf->Ofp.Kundennummer;
    Erx # RecRead(100,2,0);
    if (erx<=_rMultikey) then
      Adr_Main:Start(0, Adr.Nummer,y);
  end;

  if ((aName =^ 'edOfP.Kundennummer') AND (aBuf->OfP.Kundennummer<>0)) then begin
    RekLink(100,460,4,0);   // Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edOfP.Zahlungsbed') AND (aBuf->OfP.Zahlungsbed<>0)) then begin
    RekLink(816,460,8,0);   // Zahlungsbed. holen
    Lib_Guicom2:JumpToWindow('ZaB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edOfP.Lieferbed') AND (aBuf->OfP.Lieferbed<>0)) then begin
    RekLink(815,460,9,0);   // Lieferbed. holen
    Lib_Guicom2:JumpToWindow('LiB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edOfP.Rechnungstyp') AND (aBuf->OfP.Rechnungstyp<>0)) then begin
    RekLink(853,460,11,0);   // Rechnungstyp. holen
    Lib_Guicom2:JumpToWindow('Rty.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edOfP.Vertreter') AND (aBuf->OfP.Vertreter<>0)) then begin
    RekLink(110,460,5,0);   // Verrtreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edOfP.Verband') AND (aBuf->OfP.Verband<>0)) then begin
    RekLink(110,460,6,0);   // Verband holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
end;

//========================================================================

//========================================================================
//========================================================================
//========================================================================