@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_AUF_Rechnung
//                      OHNE E_R_G
//  Info
//    Druckt eine Rechnung
//
//
//  06.12.2010  AI  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  31.08.2015  ST  Neue Meldung bei Verbuchungsdifferenz
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName() : alpha;
//    SUB HoleEmpfaenger();
//    SUB SeitenKopf(aSeite : int)
//
//    MAIN (opt aFilename : alpha(4096))
//
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_Aktionen

define begin
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;
  cPos0   :  10.0   // Anschrift
  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Bez.
  cPos2a  :  50.0   // Materialwerte
  cPos2b  :  77.0
  cPos2c  :  70.0   // Dimensions Toleranzen
  cPos2d  :  80.0
  cPos2f  :  55.0   //Stückzahl
  cPos2g  :  60.0
  cPos3   :  90.0   // Menge1
  cPos3a  :  90.0
  cPos3b  :  92.0
  cPos3c  : 105.0
  cPos4   : 110.0   // Menge2
  cPos4a  : 110.0
  cPos4b  : 112.0
  cPos5   : 143.0   // Einzelpreis
  cPos5a  : 130.0
  cPos5b  : 143.0
  cPos5c  : 144.0
  cPos6   : 165.0   // Rabatt
  cPos7   : 182.0   // Gesamt

  cPos8   : 161.0   // Gesamt
  cPos9   : 182.0   // Gesamt

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 37.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...

end;

local begin
  vBuf100Re : int;
end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
local begin
  vBuf100 : int;
end;
begin
  vBuf100 # RekSave(100);
  RecLink(100,450,8,_RecFirst);   // Rechnungsempfänger holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN cnvAI(Erl.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  Erx       : int;
  vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      Adr.P.Adressnr # Adr.Nummer;
      Adr.P.Nummer   # cnvia(StrCut(Auf.Best.Bearbeiter,2,3));
      Erx # RecRead(102,1,_recFirst);   // Ansprechpartner holen
      if (Erx>_rLocked) then RETURN;
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,400,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,400,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RecLink(100,400,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,400,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      Erx # RecLink(110,100,16,_recFirst);  // Vertreter holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      Erx # RecLink(110,100,16,_recFirst);  // Verband holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then RETURN;

    end // Daten aus Auf.

  else begin  // FIXE DATEN !!!

    if (Scr.B.2.anKuLfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Kunde/Lieferant holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) then begin
      // fixe Adresse testen...
      if (RecLink(102,921,3,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(102,921,3,_recfirst);   // Partner holen
      RecLink(100,102,1,_recFirsT);   // seine Adresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Lieferort holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Anschrift holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Empfänger holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen

      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Vertreter  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Verband  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin;
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Lagerort holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

  end;

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx       : int;
  vBuf100     : int;
  vBuf101     : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin
  if (aSeite=1) then HoleEmpfaenger();

  vBuf100 # RekSave(100);
  vBuf101 # RekSave(101);
  //RecLink(100,400,1,_RecFirst);   // Kunde holen
  RecLink(100,400,4,_RecFirst);   // Rechnungsempfänger holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  vBesteller # '';
  if ((Auf.Best.Bearbeiter <> '') AND (StrLen(Auf.Best.Bearbeiter) > 4)) then begin
    if (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      vBesteller # StrCut(Auf.Best.Bearbeiter,4,StrLen(Auf.Best.Bearbeiter)-4);
    end;
  end;


  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(vBuf100Re -> Adr.Anrede   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Auftragsnummer:',cPosKopf1);
  PL_PrintI_L(Auf.Nummer,cPosKopf2);
  PL_PrintLine;

  PL_Print(vBuf100Re -> Adr.Name     , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Kundennr.:',cPosKopf1);
  PL_PrintI_L(Auf.Kundennr,cPosKopf2);
  PL_PrintLine;


  PL_Print(vBuf100Re -> Adr.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Unsere Lf.Nr.:',cPosKopf1);
  PL_Print(Adr.VK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(vBuf100Re -> "Adr.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre USt.Id-Nr.:',cPosKopf1);
  PL_Print(vBuf100Re -> Adr.USIdentNr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(vBuf100Re -> Adr.Plz + ' ' + vBuf100Re -> Adr.Ort, cPos0);
  Pls_fontSize # 9;
  Adr.Nummer # Set.eigeneAdressNr;    // eigene Adresse holen
  RecRead(100,1,0);
  PL_Print('Unsere Steuernr.:',cPosKopf1);
  PL_Print(Adr.Steuernummer,cPosKopf2);
  RecLink(100,400,4,_RecFirst);   // Rechnungsempfänger holen
  PL_PrintLine;

  Adr.A.LKZ # vBuf100Re -> Adr.LKZ;
  RecLink(812,101,2,_recFirst);   // Land holen
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Steuernr.:',cPosKopf1);
  PL_Print(vBuf100Re -> Adr.Steuernummer,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print('Bestellnummer:',cPosKopf1);
  PL_Print(Auf.Best.Nummer,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print('Bestelldatum:',cPosKopf1);
  PL_PrintD_L(Auf.Best.Datum,cPosKopf2);
  PL_PrintLine;

  PL_Print('Datum:',cPosKopf1);
  PL_PrintD_L(Erl.Rechnungsdatum,cPosKopf2);
  PL_PrintLine;

  PL_Print('Seite:',cPosKopf1);
  PL_PrintI_L(aSeite,cPosKopf2);
  PL_PrintLine;


  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  if (Auf.Vorgangstyp=c_BOGUT) then
    Pl_Print(translate('Bonusgutschrift') + ' ' + AInt(Erl.Rechnungsnr),cPos0)
  else if (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then
    Pl_Print(translate('Gutschrift') + ' ' + AInt(Erl.Rechnungsnr),cPos0)
  else if (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then
    PL_Print(translate('Belastung') + ' ' + AInt(Erl.Rechnungsnr) ,cPos0)
  else
    Pl_Print(translate('Rechnung') + ' ' + AInt(Erl.Rechnungsnr) ,cPos0);

  pl_PrintLine;

  Pls_FontSize # 7;
  pls_Fontattr # 0;
  Pl_Print(translate('Rechnungsdatum ist Leistungsdatum')+translate(', soweit in Position nicht anders angegeben') ,cPos0);
  pl_PrintLine;


  Pls_FontSize # 9;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;

    if (Auf.Sachbearbeiter <> '') then begin
      Usr.Username # Auf.Sachbearbeiter;
      Erx # RecRead(800, 1, 0); // Benutzer holen
      if (Erx > _rLocked) then RecBufClear(800);

      PL_Print('Sachbearbeiter: ' + Usr.Anrede + ' ' + Usr.Name+', Tel.: '+Usr.Telefonnr+', E-Mail: ' + Usr.EMail , cPos0);
      PL_PrintLine;
      PL_PrintLine;
    end;

    //  Warenempfänger bei Abweichung
    RecLink(101,400,2,_RecFirst);   // Lieferanschrift holen
    if (y) then begin
      //(Auf.Lieferadresse <> 0) and
      //((Adr.Nummer <> Auf.Lieferadresse) or
      //((Adr.Nummer = Auf.Lieferadresse) and (Auf.Lieferanschrift > 1))) then begin

      RecLink(812,101,2,_recFirst);   // Land holen

      vText #  StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Name,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.Name,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ', ' + StrAdj("Adr.A.Straße",_StrBegin | _StrEnd)
      else vText # StrAdj("Adr.A.Straße",_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ', ' + StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Ort,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ', ' + StrAdj(Lnd.Name.L1,_StrBegin | _StrEnd)
      else vText # StrAdj(Lnd.Name.L1,_StrBegin | _StrEnd);

      // Leerzeichen am Anfang entfernen
      vText   # StrAdj(vText, _StrBegin | _StrEnd);

      PL_Print('Lieferanschrift:',cPos0);
      PL_Print(vText,cPosKopf3,cPosKopf3+150.0);
      PL_PrintLine;
      PL_PrintLine;
    end;

    // Kopftext drucken
    vTxtName # '~401.'+cnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
    Lib_Print:Print_Text(vTxtName,1, cPos0);
  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('Pos.',cPos1);
    PL_Print('Beschreibung',cPos2);
    PL_Print_R('Menge',cPos3);
    PL_Print_R('E-Preis '+"Wae.Kürzel",cPos5);
    PL_Print_R('Gesamt '+"Wae.Kürzel",cPos7);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;

  RekRestore(vBuf100);
  RekRestore(vBuf101);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vBisLiefDatum       : date;
  vLfsDatum           : date;
  vLfsChk             : int;

  // Datenspezifische Variablen
  vAdresse            : int;      // Nummer des Empfängers
  vAnschrift          : int;      // Anschrift des Empfängers
  vHead_info1         : alpha;
  vHead_text1         : alpha;
  vHead_info2         : alpha;
  vHead_text2         : alpha;
  vHead_info3         : alpha;
  vHead_text3         : alpha;
  vHead_info4         : alpha;
  vHead_text4         : alpha;
  vHead_info5         : alpha;
  vHead_text5         : alpha;
  vHead_info6         : alpha;
  vHead_text6         : alpha;
  vHeadertext         : alpha;
  vTxtName            : alpha;

  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers

  // Für Verpackungsdruck
  vVerpackung         : alpha(720);
  vVerp               : alpha(1000);
  // Für Mehrwertsteuer
  vMwstSatz1          : float;
  vMwstWert1          : float;
  vMwstSatz2          : float;
  vMwstWert2          : float;
  vMwstText           : alpha;

  // Für Preise
  vGesamtNettoRabBar  : float;
  vGesamtNetto        : float;
  vGesamtMwSt         : float;
  vGesamtBrutto       : float;

  vPosNettoRabBar     : float;
  vPosNetto           : float;
  vPosMwSt            : float;

  vPosCount           : int;
  vPosStk             : int;
  vPosGewicht         : float;
  vPosMenge           : float;
  vPosMengeLFS        : float;
  vPosAnzahlAkt       : int;
  vMenge              : float;
  vPreis              : float;
  vOk                 : logic;

  vGibtsPosZ          : logic;
  vGibtsAufZ          : logic;
  vRb1                : alpha;

  // für Verpckungen als Aufpreise
  vVPGPreis           : float;
  vVPGPEH             : int;
  vVPGMEH             : alpha;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  vNummer             : int;        // Dokumentennummer
  vFlag               : int;        // Datensatzlese option
  vA                  : alpha;
end;
begin
  gFrmMain->wpdisabled # true;

  // ------ Druck vorbereiten ----------------------------------------------------------------
  vBisLiefDatum # Gv.Datum.01; // Lieferdatum übernehmen

  Erx # RecLink(100, 400, 4, _RecFirst);   // Rechnungsempf. lesen
  if(Erx > _rLocked) then
    RecBufClear(100);

  Erx # RecLink(814, 400, 8, _RecFirst);   // Währung holen
  if(Erx > _rLocked) then
   RecBufClear(814);

  vBuf100Re # Adr_Data:HoleBufferAdrOderAnschrift(Auf.Rechnungsempf, Auf.Rechnungsanschr);

  PL_Create(vPLFooter);   // Seitenfuss zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  vFooter # pls_Prt;
  PL_Print('ÜBERTRAG',cPos2);
  Gv.Alpha.01 # 'xxxxxxxxxxxx';   // Platz für Summe schaffen
  pls_hdl->ppdbfieldname # 'Gv.Alpha.01';
  PL_Print_R('[SUM1]',cPos7);
  PL_Create(vPL); // universelle PrintLine generieren


  if (Lib_Print:FrmJobOpen(true, vHeader , vFooter, false, true, false) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);


  // ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

  vAdresse    # Adr.Nummer;

  Erx # RecLink(100,400,4,_RecFirst);   // Rechnungsempf. lesen
  if(Erx > _rLocked) then
    RecBufClear(100);

  vMwstSatz1 # -1.0;
  vMwstSatz2 # -1.0;

// ------- POSITIONEN --------------------------------------------------------------------------
  Erx # RecLink(401,400,9, _recFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN

    // Vorschau?
    if (Erl.Rechnungsnr=0) then begin
      if ("Auf.P.Löschmarker"='*') then begin
        Erx # RecLink(401,400,9, _recNext);
        CYCLE;
      end;
    end;

    // Positionstyp bestimmen
    Erx # RecLink(819,401,1,0);   // Warengruppe holen
    if (Erx > _rLocked) then begin
      Erx # RecLink(401,400,9, _recNext);
      CYCLE;
    end;
    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      // Artikel lesen
      Erx # RecLink(250,401,2,_RecFirst);
      if (Erx = _rNoRec) then begin
        Erx # RecLink(401,400,9, _recNext);
        CYCLE;
      end;
    end
    else
    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.DAteinr)=false) then begin
      Erx # RecLink(401,400,9, _recNext);
      CYCLE;
    end;

    vPosMenge       # 0.0;
    vPosMengeLFS    # 0.0;
    vPosStk         # 0;
    vPosGewicht     # 0.0;
    vPosMwSt        # 0.0;
    Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart holen
    if(Erx > _rLocked) then
      RecBufClear(818);

    // Stückzahl, Menge und Gewicht aus Aktionen bestimmen
    vOk # n;  // keine Aktionen bisher
    Erx # RecLink(404,401,12,_RecFirst);
    WHILE (Erx<=_rLocked) do begin

      // Vorschau?
      if (Erl.Rechnungsnr=0) then begin
        if ("Auf.A.Löschmarker"='*') or (Auf.A.Rechnungsmark<>'$') or (Auf.A.TerminEnde>vBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or (Auf.A.Rechnungsdatum<>0.0.0) then begin
          Erx # RecLink(404,401,12,_RecNext);
          CYCLE;
        end;
        end
      else begin
        if (Auf.A.Rechnungsnr<>Erl.Rechnungsnr) then begin
          Erx # RecLink(404,401,12,_RecNext);
          CYCLE;
        end;
      end;

      vOk # y;  // Aktion gefunden

      if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin
        // MINUS, DA GUTSCHRIFT !!!
        vPosMenge     # vPosMenge - Lib_Faktura:RE_HoleReMenge();
        if (Auf.A.MEH.Preis=Auf.P.MEH.Preis) and
          ((Auf.P.MEH.Preis='kg') or (Auf.P.MEH.Preis='t')) then Auf.A.Menge # vPosMenge;
        vPosMengeLFS  # vPosMengeLFS  - Auf.A.Menge;
        vPosStk       # vPosStk - "Auf.A.Stückzahl";
        vPosGewicht   # vPosGewicht - Auf.A.Gewicht;
        end
      else begin
        vPosMenge     # vPosMenge + Lib_Faktura:RE_HoleReMenge();
        if (Auf.A.MEH.Preis=Auf.P.MEH.Preis) and
          ((Auf.P.MEH.Preis='kg') or (Auf.P.MEH.Preis='t')) then Auf.A.Menge # vPosMenge;
        vPosMengeLFS  # vPosMengeLFS + Auf.A.Menge;
        vPosStk       # vPosStk + "Auf.A.Stückzahl";
        vPosGewicht   # vPosGewicht + Auf.A.Gewicht;
      end;
      vPosAnzahlAkt # vPosAnzahlAkt + 1;

      Erx # RecLink(404,401,12,_RecNext);
    END;

    if (vOK=n) then begin // diese Position bringt nichts
      Erx # RecLink(401,400,9, _recNext);
      CYCLE;
    end;

    // Position ausgeben.....
    Inc(vPosCount);


    // Positionsrabatte suchen (*RAB1 und *RAB2)
    vGibtsPosZ  # n;
    Erx # RecLink(403,401,6,_RecFirst);
    if (Erx<=_rLocked) then vGibtsPosZ # y;


    // Position zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // ARTIKEL:
    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis+Auf.P.Aufpreis) *  vPosMenge / CnvFI(Auf.P.PEH) ,2);
      PL_Print(AInt(Auf.P.Position),cPos1);
      PL_Print(Art.Nummer,cPos2);
      PL_PrintF(vPosMengeLFS,2,cPos3a);
      PL_Print(Auf.P.MEH.Wunsch,cPos3b);

      if (Auf.P.MEH.Wunsch<>Auf.P.MEH.Preis) then begin
        if (Auf.P.MEH.Preis='m') or (Auf.P.MEH.Preis='qm') then
          PL_PrintF(vPosMenge,Set.Stellen.Menge,cPos4a)
        else if (Auf.P.MEH.Preis='t') then
          PL_PrintF(vPosMenge,3,cPos4a)
        else
          PL_PrintF(vPosMenge,0,cPos4a)
        PL_Print(Auf.P.MEH.Preis,cPos4b);
      end;

      PL_PrintF(Auf.P.Grundpreis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Auf.P.PEH,cPos5b);
      PL_Print(Auf.P.MEH.Preis,cPos5c);
      PL_Print_R(vRb1,cPos6,cPos5c+7.0);
      PL_PrintF(Auf.P.Gesamtpreis,2,cPos7);
      PL_PrintLine;
      Gv.Alpha.01     # ANum(vGesamtNetto+Auf.P.Gesamtpreis,2);

      PLs_FontSize # 8;

      if (Art.Bezeichnung1 <> '') then begin
        PL_Print(Art.Bezeichnung1,cPos2);
        PL_PrintLine;
      end;
      if (Art.Bezeichnung2 <> '') then begin
        PL_Print(Art.Bezeichnung2,cPos2);
        PL_PrintLine;
      end;
      if (Art.Bezeichnung3 <> '') then begin
        PL_Print(Art.Bezeichnung3,cPos2);
        PL_PrintLine;
      end;
      if (Auf.P.Bemerkung <> '') then begin
        PL_Print(Auf.P.Bemerkung,cPos2);
        PL_PrintLine;
      end;

      if (Auf.P.AbmessString <> '') then begin
        PL_Print(Auf.P.AbmessString,cPos2);
        PL_PrintLine;
      end;

      Lib_Print:Print_Text('~250.VK.'+cnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),1, cPos2,cPos8);
    end;

    // MATERIAL:
    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
      F_STD_AUF_AufBest:Druck_Material(vRb1,vPosMengeLFS, vPosMenge, vPosStk);
/***/
      if (Auf.Vorgangstyp = 'AUF') then begin
        Erx # RecLink(404,401,12,_RecFirst);
        WHILE (Erx<=_rLocked) do begin
          if (Erl.Rechnungsnr = 0) then begin
            // Summierungsbedingung Vorschau
            if ("Auf.A.Löschmarker" <> '') OR ("Auf.A.Rechnungsmark" <> '$') OR
               /*("Auf.A.Aktionstyp" <> 'LFS') OR*/ (Auf.A.TerminEnde>vBisLiefDatum) OR
               (Auf.A.Rechnungsdatum <> 0.0.0) then begin
               Erx # RecLink(404,401,12,_RecNext);     // Nächster Eintrag
               CYCLE;
            end;
          end else begin
            // Summierungsbedingung Rechnung
            if /*("Auf.A.Aktionstyp" <> 'LFS') OR*/ (Auf.A.TerminEnde > vBisLiefDatum) OR
               (Auf.A.Rechnungsnr <> Erl.Rechnungsnr) then begin
                  Erx # RecLink(404,401,12,_RecNext);     // Nächster Eintrag
                CYCLE;
            end;
          end;

          if (Mat_Data:Read(Auf.A.Materialnr)>=200) then begin // Materiakarte lesen

            if (vLfsChk=0) then
              PL_Print('Lieferung:', cPos2);

            // Nächstes Element
            vLfsChk   # "Auf.A.Aktionsnr";      //  aktueller Lieferschein
            vLfsDatum # "Auf.A.TerminEnde";

            PL_Print(cnvai(Auf.A.Materialnr,_FmtNumNoGroup) + ' vom ' + cnvad(vLfsDatum), cPos2a);
            PL_Print(CnvAi("Auf.A.Stückzahl")+' Stk.', cPos3);
            PL_Print(anum(auf.a.Gewicht, Set.Stellen.Gewicht)+' kg', cPos3c);
//            PL_PrintF(Auf.A.Gewicht, Set.Stellen.Gewicht,cPos3a);
            PL_PrintLine;
          end;

          Erx # RecLink(404,401,12,_RecNext);     // Nächster Eintrag
        END;  // Ende Aktionen
      end;
/***/
    end;


    vPosNettoRabBar # Auf.P.Gesamtpreis;
    vPosNetto       # Auf.P.Gesamtpreis;

    // Positionstext ausgeben
    vTxtName # '';
    PLs_FontSize # 8;
    if (Auf.P.TextNr1=400) then // anderer Positionstext
      vTxtName # '~401.'+cnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+cnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Auf.P.TextNr1=0) and (Auf.P.TextNr2 != 0) then   // Standardtext
      vTxtName # '~837.'+cnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    if (Auf.P.TextNr1=401) then // Individuell
      vTxtName # '~401.'+cnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+cnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (vTxtName != '') then
      Lib_Print:Print_Text(vTxtName,1,cPos2, cPos7);  // drucken


    // Aufpreise: MEH-Bezogen
    // Aufpreise: MEH-Bezogen
    //MEH-Bezogene Aufpreise bei ARTIKEL neben Artikelbeschreibung
/*
    if (Auf.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisArtikel) then begin
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN) and
        ((Auf.Z.MEH='%') or (Auf.Z.MEH=Auf.P.MEH.Preis)) then begin
          if (vRb1='') then begin

            // ST 2009-08-14 laut Projekt 1061/286
            if ("Auf.Z.Schlüssel" = '*RAB1') or ("Auf.Z.Schlüssel" = '*RAB2') then
              Auf.Z.Bezeichnung # 'Rabatt';
            // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            PL_Print_R(Auf.Z.Bezeichnung + ' ' + cnvAF(Auf.Z.Menge) + ' %',cPos5);
            PL_PrintLine;
          end;
          vRb1 # '';
        end;
        Erx # RecLink(403,401,6,_RecNext);
      END;
    end;
*/

    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) and
      (Auf.P.Projektnummer=0) THEN BEGIN
      // Stückliste Drucken
      Erx # RecLink(409,401,15,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.P.Artikelnr=Auf.SL.Artikelnr) then begin
          PL_Print(AInt("Auf.SL.Stückzahl")+' a',cPos2+5.0);
          PL_Print_R(cnvAF("Auf.SL.Länge",0,0,0,6) + ' mm',cPos2+30.0);
          end
        else begin
          if ("Auf.SL.Länge"<>0.0) then begin
            PL_Print(AInt("Auf.SL.Stückzahl")+' Stk. von '+Auf.SL.ArtikelNr+' a '+cnvAF("Auf.SL.Länge",0,0,0,6) + ' mm',cPos2+5.0);
            end
          else begin
            PL_Print(AInt("Auf.SL.Stückzahl")+' Stk. von '+Auf.SL.ArtikelNr,cPos2+5.0);
          end;
        end;
        PL_PrintLine;
        Erx # RecLink(409,401,15,_RecNext);
      END;
    end;

    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      // Verpackungen anhand der Auftragsaufpreise lesen
      Auf.Z.Position  # 0;
      Auf.Z.Position  # 0;
      Erx # RecLink(403,400,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        // Artikelaufpreis ?
        If (Auf.Z.Vpg.Artikelnr <> '') then begin
          Art.Nummer # Auf.Z.Vpg.Artikelnr;
          If (RecRead(250,1,0) <> _rNoRec) then begin       // Artikel lesen

            // Verpackungsartikel?
            If (Art.Artikelgruppe = 999) then begin
              // Standardpreis Preis hinterlegt?
              Erx # RecLink(254,250,6,_RecFirst);
              WHILE (Erx <= _rLocked) do begin
                // Standardpreis?
                if (Art.P.Adressnr = 0) then begin
                  vVPGPreis # Art.P.Preis;
                  vVPGPEH   # Art.P.PEH;
                  vVPGMEH   # Art.P.MEH;
                end;

                Erx # RecLink(254,250,6,_RecNext);
              END;

              // Preis für Kunden hinterlegt?
              Erx # RecLink(254,250,6,_RecFirst);
              WHILE (Erx <> _rNoRec) do begin
                if (Art.P.Adressnr = vAdresse) then begin
                  vVPGPreis # Art.P.Preis;
                  vVPGPEH   # Art.P.PEH;
                  vVPGMEH   # Art.P.MEH;
                end;
                Erx # RecLink(254,250,6,_RecNext);
              END;

            end;  // Verapckungsartikel

          end;  // Artikel lesen

        end;  // Artikelaufpreis?
        Erx # RecLink(403,400,13,_RecNext);
      END;  // Verpackung

    end;    // Auftragsaufpreise loop

    RecBufClear(403);

    // Drucken Start
    Auf.Z.PEH # vVPGPEH;
    Auf.Z.MEH # vVPGMEH;
    if (Auf.Z.Preis = 0.0) then
      Auf.Z.Preis # vVPGPreis;

    if (Auf.Z.Menge <> 0.0) AND (Auf.Z.PEH <> 0) then begin
      vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      // Verpackung zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PL_Print(Auf.Z.Bezeichnung,cPos2);
      if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
        PL_PrintF(Auf.Z.Menge,2,cPos3a)
      else if (Auf.Z.MEH='t') then
        PL_PrintF(Auf.Z.Menge,3,cPos3a)
      else
        PL_PrintF(Auf.Z.Menge,0,cPos3a)
      PL_Print(Auf.Z.MEH,cPos3b);
      PL_PrintF(Auf.Z.Preis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Auf.Z.PEH,cPos5b);
      PL_Print(Auf.Z.MEH,cPos5c);
      PL_PrintF(vPreis,2,cPos7);
      PL_Print(Auf.Z.MEH,cPos3b);
      PL_PrintLine;

      vPosNetto # vPosNetto + vPreis;
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabbar # vPosNettoRabBar + vPreis;
    end;

    //========================================================================
    // Aufpreise
    //    Reihenfolge:
    //      1. Grundpreis
    //      2. + mengenbezogene Positionsaufpreise
    //      3. + pauschale (nicht mengenbezogen) Positionsaufpreise
    //      4. + prozentuale Positionsaufpreise
    //      5. + mengenbezogene Kopfaufpreise
    //      -> Positionssumme
    //      6. + pauschale Kopfaufpreise
    //      7. + prozentuale Kopfaufpreise
    //      -> Endsumme
    //
    //========================================================================

    // prüfen ob Aufpr. vorhanden sind, falls ja: Aufpreiskopf drucken
    if (vGibtsPosZ) then begin

      PL_PrintLine;
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Positionsaufpreise und Rabatte',cPos2);
      pls_FontAttr # 0;
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPos2,cPos7);


      //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
        Erx # RecLink(403,401,6,_RecFirst);
        WHILE (Erx<=_rLocked) do begin
          if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH=Auf.P.MEH.Preis) then begin
//            Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
            Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
            vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
            PL_Print(Auf.Z.Bezeichnung,cPos2);
            PL_PrintF(vPreis,2,cPos7);
            PL_PrintLine;
            vPosNetto # vPosNetto + vPreis;
            Gv.Alpha.01 # ANum(vGesamtNetto+vPosNetto,2);
            if (Auf.Z.RabattierbarYN) then
             vPosNettoRabBar # vPosNettoRabBar + vPreis;
          end;
          Erx # RecLink(403,401,6,_RecNext);
        END;
      end;

      // Aufpreise: fremd MEH-Bezogen
      // Aufpreise: fremd MEH-Bezogen
      // Aufpreise: fremd MEH-Bezogen
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN) and
        ((Auf.Z.MEH<>'%') and (Auf.Z.MEH<>Auf.P.MEH.Preis)) then begin
//          Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
          Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Auf.Z.Bezeichnung,cPos2);
          if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
            PL_PrintF(Auf.Z.Menge,2,cPos3a)
          else if (Auf.Z.MEH='t') then
            PL_PrintF(Auf.Z.Menge,3,cPos3a)
          else
          PL_PrintF(Auf.Z.Menge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintF(Auf.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Auf.Z.PEH,cPos5b);
          PL_Print(Auf.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintLine;
          vPosNetto # vPosNetto + vPreis;
          Gv.Alpha.01 # ANum(vGesamtNetto+vPosNetto,2);
          if (Auf.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;
        end

        Erx # RecLink(403,401,6,_RecNext);
      END;


      // Aufpreise: NICHT MEH-Bezogen =FIX
      // Aufpreise: NICHT MEH-Bezogen =FIX
      // Aufpreise: NICHT MEH-Bezogen =FIX
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN=n) and (Auf.Z.Rechnungsnr=Erl.Rechnungsnr) then begin

          if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,401);

          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Auf.Z.Bezeichnung,cPos2);
          if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
            PL_PrintF(Auf.Z.Menge,2,cPos3a)
          else if (Auf.Z.MEH='t') then
            PL_PrintF(Auf.Z.Menge,3,cPos3a)
          else
            PL_PrintF(Auf.Z.Menge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintF(Auf.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Auf.Z.PEH,cPos5b);
          PL_Print(Auf.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintLine;

          vPosNetto # vPosNetto + vPreis;
          Gv.Alpha.01 # ANum(vGesamtNetto+vPosNetto,2);
          if (Auf.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;
        end;

        Erx # RecLink(403,401,6,_RecNext);
      END;


      //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise
      //if (Auf.P.Wgr.Dateinr>=c_Wgr_Material) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisMaterial) then begin
        /*
        PL_PrintLine;
        pls_FontAttr # _WinFontAttrBold;
        PL_Print('Zu-/Abschläge',cPos2);
        pls_FontAttr # 0;
        PL_PrintLine;
        Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
        */
        Erx # RecLink(403,401,6,_RecFirst);
        WHILE (Erx<=_rLocked) do begin
          if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
            vPreis # Rnd(Auf.Z.Menge * vPosNettoRabbar / 100.0, 2);
            Auf.Z.PEH   # 100;
            if ("Auf.Z.Schlüssel" = '*RAB1') or ("Auf.Z.Schlüssel" = '*RAB2') then
              Auf.Z.Bezeichnung # 'Rabatt';

            PL_Print(Auf.Z.Bezeichnung,cPos2);
            PL_PrintF(Auf.Z.Menge,2,cPos3a);
            PL_Print('%',cPos3b);
            PL_PrintF(vPreis,2,cPos7);
            PL_PrintLine;

            vPosNetto # vPosNetto + vPreis;
            Gv.Alpha.01 # ANum(vGesamtNetto+vPosNetto,2);
            if (Auf.Z.RabattierbarYN) then
             vPosNettoRabBar # vPosNettoRabBar + vPreis;
          end;
          Erx # RecLink(403,401,6,_RecNext);
        END;
      //end;
    end;


    // KopfAufpreise: MEH-bezogen
    // KopfAufpreise: MEH-Bezogen
    // KopfAufpreise: MEH-Bezogen
    Erx # RecLink(403,400,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      IF (Auf.Z.Position>0) then BREAK;
      IF (Auf.Z.Vpg.ArtikelNr <> '') then begin
        Auf.Z.Position # 0;
        Erx # RecLink(403,400,13,_RecNext);
        CYCLE;
      end;

      if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') then begin
        // PosMEH in AufpreisMEH umwandeln
        //vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
        vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH);
        vPreis #  Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
        // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        PL_Print(Auf.Z.Bezeichnung,cPos2);

        if (Auf.Z.MEH<>Auf.P.MEH.Preis) then begin
          PL_PrintF(vMenge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
        end;
        PL_PrintF(Auf.Z.Preis,2,cPos5a);
        PL_Print('jxe',cPos5a+0.8);
        PL_PrintI(Auf.Z.PEH,cPos5b);
        PL_Print(Auf.Z.MEH,cPos5c);
        PL_PrintF(vPreis,2,cPos7);
        PL_PrintLine;

        vPosNetto # vPosNetto + vPreis;
        Gv.Alpha.01 # ANum(vGesamtNetto+vPosNetto,2);
        if (Auf.Z.RabattierbarYN) then
         vPosNettoRabBar # vPosNettoRabBar + vPreis;

      end;
      Erx # RecLink(403,400,13,_RecNext);
    END;

    //= POSAUFPREISE ENDE ===================================================


    // Mehrwertsteuersätze
    RecLink(819,401,1,_RecFirst); // Warengrupppe lesen


//    Erx # RecLink(250,401,2,_recFirst);
    //if (Erx>_rLocked) then ABBRUCH(400099,463);
    StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
    Erx # RecRead(813,1,0);
    //if (Erx>_rLocked) then ABBRUCH(400098,0);
    vPosMwst # StS.Prozent;

    if (vMwstSatz1=-1.0) then begin
      vMwstSatz1 # vPosMwSt;
      vMwstWert1 # vPosNetto;
      end
    else if (vMwstSatz1=vPosMwst) then begin
      vMwstWert1 # vMwstWert1 + vPosNetto;
      end
    else if (vMwstSatz2=-1.0) then begin
      vMwstSatz2 # vPosMwSt;
      vMwstWert2 # vPosNetto;
      end
    else if (vMwstSatz2=vPosMwst) then begin
      vMwstWert2 # vMwstWert2 + vPosNetto;
      end;
/*    else
      ABBRUCH(4000099,0);
  */

    // Positionszusatz ausgeben
    if (Auf.P.Bemerkung <> '') then begin
      PL_PrintLine;
      PL_Print(Auf.P.Bemerkung,cPos2);
      PL_PrintLine;
    end;

    vGesamtNettoRabBar  # vGesamtNettoRabBar + vPosNettoRabBar;
    vGesamtNetto        # vGesamtNetto + vPosNetto;

    // Leerzeile zwischen den Positionen
    PL_PrintLine;

    Erx # RecLink(401,400,9, _recNext);
  END; // WHILE: Positionen ************************************************

  // prüfen ob Aufpr. vorhanden sind, falls ja: Aufpreiskopf drucken
  vGibtsAufZ # false;
  Erx # RecLink(403,400,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.Nummer <> Auf.Nummer) then break;

    if (Auf.Z.Position=0) then begin

      if (Auf.Z.MengenbezugYN=n) and (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then
        Call(Auf.Z.FormelFunktion,400);

      if (((Auf.Z.MengenbezugYN=n) and (Auf.Z.Menge<>0.0)) or (Auf.Z.MengenbezugYN))then begin
        vGibtsAufZ # true;
        break;
      end;
    end;
    Erx # RecLink(403,400,13,_RecNext);
  END;

  if (vGibtsAufZ) then begin
    PL_PrintLine;
    pls_FontAttr # _WinFontAttrBold;
    PL_Print('zusätzliche Auftragsaufpreise und Rabatte',cPos2);
    pls_FontAttr # 0;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
  end;



  // KopfAufpreise: NICHT MEH-Bezogen =FIX
  // KopfAufpreise: NICHT MEH-Bezogen =FIX
  // KopfAufpreise: NICHT MEH-Bezogen =FIX
  Auf.Z.Position  # 0;
  Erx # RecLink(403,400,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    IF (Auf.Z.Position>0) then BREAK;
    IF (Auf.Z.Vpg.ArtikelNr <> '') then begin
      Auf.Z.Position # 0;
      Erx # RecLink(403,400,13,_RecNext);
      CYCLE;
    end;


    if (Auf.Z.MengenbezugYN=n) and
      (Auf.Z.Rechnungsnr=Erl.Rechnungsnr) then begin

      if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,400);
      if (Auf.Z.Menge<>0.0) then begin

        vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

        // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        PL_Print(Auf.Z.Bezeichnung,cPos2);
        if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
          PL_PrintF(Auf.Z.Menge,2,cPos3a)
        else if (Auf.Z.MEH='t') then
          PL_PrintF(Auf.Z.Menge,3,cPos3a)
        else
          PL_PrintF(Auf.Z.Menge,0,cPos3a)
        PL_Print(Auf.Z.MEH,cPos3b);
        PL_PrintF(Auf.Z.Preis,2,cPos5a);
        PL_Print('je',cPos5a+0.8);
        PL_PrintI(Auf.Z.PEH,cPos5b);
        PL_Print(Auf.Z.MEH,cPos5c);
        PL_PrintF(vPreis,2,cPos7);
        PL_Print(Auf.Z.MEH,cPos3b);
        PL_PrintLine;

        vGesamtNetto # vGesamtNetto + vPreis;
        vMwstWert1 # vMwstWert1 + vPreis;

        if (Auf.Z.RabattierbarYN) then
          vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;
      end;
    end;

    Erx # RecLink(403,400,13,_RecNext);
  END;


  // KopfAufpreise: %
  // KopfAufpreise: %
  // KopfAufpreise: %
  Auf.Z.Position  # 0;
  Erx # RecLink(403,400,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    IF (Auf.Z.Position>0) then BREAK;
    IF (Auf.Z.Vpg.ArtikelNr <> '') then begin
      Auf.Z.Position # 0;
      Erx # RecLink(403,400,13,_RecNext);
      CYCLE;
    end;

    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      Auf.Z.Preis # vGesamtNettoRabBar;
      //Auf.Z.Preis # vGesamtNetto;
      Auf.Z.PEH   # 100;

      vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

      // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PL_Print(Auf.Z.Bezeichnung,cPos2);
      PL_PrintF(Auf.Z.Menge,0,cPos3a)
      PL_Print(Auf.Z.MEH,cPos3b);
      PL_PrintF(vPreis,2,cPos7);
      PL_Print(Auf.Z.MEH,cPos3b);
      PL_PrintLine;

      vGesamtNetto # vGesamtNetto + vPreis;
      vMwstWert1 # vMwstWert1 + vPreis;

      if (Auf.Z.RabattierbarYN) then
        vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;

    end;
    Erx # RecLink(403, 400, 13, _recNext);
  END;


  // ------- FUßDATEN --------------------------------------------------------------------------
  form_footer # 0;
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(100.0,_PrtUnitMillimetres)) do
    PL_PrintLine;

  Lib_Print:Print_LinieDoppelt();

  // Mehrwertstuern errechnen
  if (vMwStSatz1<>0.0) then vMwStWert1 # Rnd(vMwstWert1 * (vMwstSatz1/100.0),2)
  else vMwStWert1 # 0.0;
  if (vMwStSatz2>0.0) then vMwStWert2 # Rnd(vMwstWert2 * (vMwstSatz2/100.0),2)
  else vMwStWert2 # 0.0;
  vGesamtBrutto # Rnd(vGesamtNetto + vMwstWert1 + vMwstWert2,2);
  // Summen drucken
  pls_Fontsize # 9;
  PL_Print_R('Warenwert '+"Wae.Kürzel",cPos7-25.0);
  PL_PrintF(vGesamtNetto,2,cPos7);
  PL_PrintLine;

  pls_Fontsize # 9;
  PL_Print_R(cnvAF(vMwstSatz1) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
  PL_PrintF(vMwstWert1,2,cPos7);
  PL_PrintLine;

  if (vMwstSatz2>0.0) then begin
    pls_Fontsize # 9;
    PL_Print_R(cnvAF(vMwstSatz2) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
    PL_PrintF(vMwstWert2,2,cPos7);
    PL_PrintLine;
  end;

  Lib_Print:Print_LinieEinzeln(cPos7-20.0,cPos7);

  pls_Fontsize # 9;
  pls_FontAttr # _WinFontAttrBold ;
  PL_Print_R('Rech.Betrag '+"Wae.Kürzel",cPos7-25.0);
//  pls_FontAttr # _WinFontAttrBold | _WinFontAttrUnderline;
  PL_PrintF(vGesamtBrutto,2,cPos7);
  pls_FontAttr # 0;
  PL_PrintLine;
  Lib_Print:Print_LinieDoppelt(cPos7-20.0,cPos7);

  PL_PrintLine;

  F_STD_Auf_AufBest:Print('LB');
  F_STD_Auf_AufBest:Print('VA');
  F_STD_Auf_AufBest:Print('Warenempfänger');
//  F_STD_Auf_AufBest:Print('ZB');

  PL_Print('Zahlung:',cPos1);
  if (Erl.Rechnungsnr=0) then OfP.Brutto # vGesamtBrutto;
  vA # Ofp_data:BuildZabString(Zab.Bezeichnung1.L1, Ofp.Skontodatum, Ofp.Zieldatum, OfP.Skontoprozent, OfP.Brutto);
  PL_Print(vA,cPosFuss2);
  PL_PrintLine;
  if (ZaB.Bezeichnung2.L1<>'') then begin
    vA # Ofp_data:BuildZabString(Zab.Bezeichnung2.L1, Ofp.Skontodatum, Ofp.Zieldatum, OfP.Skontoprozent, OfP.Brutto);
    PL_Print(vA,cPosFuss2);
    PL_PrintLine;
  end;

  PL_PrintLine;


  // Fusstext drucken
  vTxtName # '~401.'+cnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  Lib_Print:Print_Text(vTxtName, 1, cPos1, cPos7);


  // ggf. hier Texte für Auslandsgeschäfte etc. Drucken
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------

  if(HdlInfo(vBuf100Re, _HdlExists) > 0) then
    RecBufDestroy(vBuf100Re);

  // Beträge merken für Kontrolle
  vGesamtMwSt # vMwstWert1 + vMwstWert2;
  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin
    vGesamtNetto  # (-1.0) * vGesamtNetto;
    vGesamtMwst   # (-1.0) * vGesamtMwst;
  end;

  vGesamtNetto  # Rnd(vGesamtNetto,2);
  vGesamtMwSt   # Rnd(vGesamtMWst,2);
  vOK # ((Erl.Netto=vGesamtNetto) and (Erl.Steuer=vGesamtMwSt)) or (Erl.Rechnungsnr=0);

  gFrmMain->wpdisabled # false;

  // letzte Seite & Job schließen, ggf. mit Vorschau
//vOK # !vOK;
  if (vOK) then
//    Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", (Erl.Rechnungsnr=0))
    Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", (Erl.Rechnungsnr=0), n, aFilename);
  else
    Lib_Print:FrmJobCancel();

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

  // Dokument in die Ablage eintragen
//  if (Erl.Rechnungsnr<>0) and (vOK) then
//    Lib_Dokumente:InsertDok(Frm.Bereich,Frm.Name,vDokName,vDokSprache);
//  else
//    if (vOK) then Lib_Dokumente:KillDok(Frm.Bereich,Frm.Name,vDokName, vDokSprache);

  // Passt der ausgedruckte Preis zum verbuchten? oder DIFFERENZ?
  if (vOK=n) then begin
    while Msg(400100,cnvAF(vGesamtNetto+vGesamtMwSt)+'|'+cnvAF(Erl.Netto+Erl.Steuer)+'|'+Aint(Erl.Rechnungsnr),_winicoerror,_windialogokcancel,1)=_winidOk do begin end;
  end;

end;

//========================================================================