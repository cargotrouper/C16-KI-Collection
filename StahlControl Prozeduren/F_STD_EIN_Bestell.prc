@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Ein_Bestell
//                OHNE E_R_G
//  Info
//    Druckt eine Betellung
//
//
//  01.03.2006  AI  Erstellung der Prozedur als Auftragsbestätigung
//  06.10.2006  ST  Anpassung
//  09.01.2007  NH  Umgeändert als Bestellung
//  13.08.2009  ST  Artikelausgabe überarbeitet, Material/Artikelmix hinzugefügt
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  22.08.2012  TM  Druck Positionsaufpreise korrekt eingerichtet
//  16.10.2013  AH  Anfragen
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB HoleEmpfaenger();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Bez.
  cPos2a  :  50.0   // Materialwerte
  cPos2b  :  77.0
  cPos2c  :  70.0   // Dimensions Toleranzen
  cPos2d  :  80.0
  cPos2f  :  55.0   //60 Stückzahl
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
  cPosKopf3 : 35.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...

end;

//========================================================================
//   AddChem
//            Fügt eine Zeile chemischer Analyse zum Formular hinzu
//            Wird nur benötigt für MaterialDruck()
//            Argumente:
//                aName    Name des Elements
//                aName2   alternativer Name des Elements
//                pMin     1. Wert
//                pMax     2. Wert
//========================================================================
sub AddChem(
  aName   : alpha;
  aName2  : alpha;
  pMin    : float;
  pMax    : float;);
begin
  if (aName2<>'') then aName # aName2;

  //GV.Int.01 ist die Aktuelle Spalte
  if(pMin<>0.0 or pMax<>0.0) then begin
    PL_Print(aName,CnvFI(GV.Int.01*30)+cpos2a);
    if (GV.Logic.01<>true) then begin PL_Print('Chem. Analyse:',cPos2);GV.Logic.01#true;end;
    if (pMin<>0.0 and pMax<>0.0) then
      PL_Print(CnvAF(pMin) + ' - ' + CnvAF(pMax),CnvFI(GV.Int.01*30)+cpos2a+5.0)
    if (pMin<>0.0 and pMax=0.0) then
      PL_Print('min. ' + CnvAF(pMin),CnvFI(GV.Int.01*30)+cpos2a+5.0)
    if (pMin=0.0 and pMax<>0.0) then
      PL_Print('max. ' + CnvAF(pMax),CnvFI(GV.Int.01*30)+cpos2a+5.0)

    GV.Int.01 # GV.Int.01 + 1
    if (GV.Int.01=4) then begin
      GV.Int.01#0;
      PL_Printline;
    end;
  end;
  //if (Name='B' and GV.Logic.01=true) then PL_PrintLine;
end;


//========================================================================
//   AddMech
//            Fügt eine Zeile mechanischer Analyse zum Formular hinzu
//            Wird nur benötigt für MaterialDruck()
//            Argumente:
//                Name    Name der Größe
//                pMin     1. Wert
//                pMax     2. Wert
//                Einheit Bezeichnung der Einheit
//========================================================================
sub AddMech(Name : alpha; pMin : float; pMax : float; Einheit : alpha;);
begin
  Einheit # ' ' + Einheit;
  if(pMin<>0.0 or pMax<>0.0)then begin
    if (GV.Logic.01<>true) then begin PL_Print('Mech. Analyse:',cPos2);GV.Logic.01#true;end;
    PL_Print(Name,cpos2a);
    if(pMin<>0.0 and pMax<>0.0)then begin
      PL_Print(CnvAF(pMin) + Einheit + ' - ' + CnvAF(pMax) + Einheit,75.0);end;
    if(pMin<>0.0)then begin
      if (pMax=0.0) then
        PL_Print(Name,cpos2a);PL_Print('min. ' + CnvAF(pMin) + Einheit,75.0);
    end;
    if(pMin=0.0)then begin
      if (pMax<>0.0) then
        PL_Print(Name,cpos2a);PL_Print('max. ' + CnvAF(pMax) + Einheit,75.0);
    end;
    if(pMin=pMax)then
      PL_Print(Name,cpos2a);PL_Print(CnvAF(pMin) + Einheit,75.0);
    PL_PrintLine;
  end;
  //if (Name='Härte' and GV.Logic.01=true) then PL_PrintLine;
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
begin
  RecLink(100,500,1,_RecFirst);   // Lieferant holen
  aAdr      # Adr.Nummer;
  aSprache  # Ein.Sprache;
  RETURN CnvAI(Ein.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,500,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,500,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RecLink(100,500,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,500,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
        RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
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
  vBuf100     : int;
  vBuf101     : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin
  vBuf100 # RekSave(100);
  vBuf101 # RekSave(101);
  RecLink(100,500,1,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0);
//  Pls_fontSize # 9;
//  PL_Print('Auftragsnummer:',cPosKopf1);
//  PL_PrintI_L(Ein.Nummer,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Name     , cPos0);

  Pls_fontSize # 9;
  PL_Print('Auftragsdatum:',cPosKopf1);
  PL_PrintD_L(Ein.Datum,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Lieferantennr.:',cPosKopf1);
  PL_PrintI_L(Ein.lieferantennr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Unsere Kundennr.:',cPosKopf1);
  PL_Print(Adr.EK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre USt.Id-Nr.:',cPosKopf1);
  PL_Print(Adr.USIdentNr,cPosKopf2);
  PL_PrintLine;

  RecLink(812,101,2,_recFirst);   // Land holen
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  if(Adr.Steuernummer <> '') then begin
    Pls_fontSize # 9;
    PL_Print('Ihre Steuernr.:',cPosKopf1);
    PL_Print(Adr.Steuernummer,cPosKopf2);
    PL_PrintLine;
  end;

  PL_Print('Datum:',cPosKopf1);
  PL_PrintD_L(today,cPosKopf2);
  PL_PrintLine;

  PL_Print('Seite:',cPosKopf1);
  PL_PrintI_L(aSeite,cPosKopf2);
  PL_PrintLine;


  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  if (Ein.LiefervertragYN) then PL_Print('Rahmenbestellung '+AInt(Ein.P.Nummer)   ,cPos0 )
  else if (Ein.AbrufYN) then PL_Print('Bestellabruf '+AInt(Ein.P.Nummer)   ,cPos0 )
  else Pl_Print('Bestellung'+' '+AInt(Ein.P.Nummer)   ,cPos0 );
  pl_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('Hiermit bestellen wir zu unseren Ihnen bekannten Einkaufsbedingungen:',cPos0);
    PL_PrintLine;
    PL_PrintLine;

    //  Warenempfänger bei Abweichung
    RecLink(101,500,2,_RecFirst);   // Lieferanschrift holen
    if (y) then begin
      //(Ein.Lieferadresse <> 0) and
      //((Adr.Nummer <> Ein.Lieferadresse) or
      //((Adr.Nummer = Ein.Lieferadresse) and (Ein.Lieferanschrift > 1))) then begin

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
    vTxtName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
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
    PL_Print_R('Gesamt',cPos7);
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
  // Datenspezifische Variablen
  vAdresse            : int;      // Nummer des Empfängers
  vAnschrift          : int;      // Anschrift des Empfängers
  vTxtName            : alpha;

  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers

  // Für Verpackungsdruck
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
  vKopfaufpreis       : float;
  vPosStk             : int;
  vPosGewicht         : float;
  vPosMenge           : float;
  vPosAnzahlAkt       : int;
  vMenge              : float;
  vPreis              : float;

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
  vTxtHdl             : int;
  vA                  : alpha;
  vMerker             : alpha;

  vFirst : logic;
end;
begin

    if (Ein.Vorgangstyp<>c_Bestellung) then RETURN;

  // ------ Druck vorbereiten ----------------------------------------------------------------

  RecLink(100,500,1,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  RecLink(814,500,8,_RecFirst);   // Währung holen

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
//  Lib_Print:FrmJobOpen('tmp'+AInt(gUserID),vHeader , vFooter,y,y,n);
  if (Lib_Print:FrmJobOpen(y, vHeader ,vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);

  // ARCFLOW
//  DMS_ArcFlow:SetDokName('!SC\Einkauf','Best',Ein.P.Nummer);

// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

  vAdresse    # Adr.Nummer;
  vMwstSatz1 # -1.0;
  vMwstSatz2 # -1.0;
// ------- POSITIONEN --------------------------------------------------------------------------

  vFlag # _RecFirst;
  WHILE (RecLink(501,500,9,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    if ("Ein.P.Löschmarker"='*') then CYCLE;

    // Positionstyp bestimmen
    Erx # RecLink(819,501,1,0);   // Warengruppe holen
    if (Erx > _rLocked) then CYCLE;

    RecBufClear(250);
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) then begin
      // Artikel lesen
      Erx # RecLink(250,501,2,_RecFirst);
      If (Erx = _rNoRec) then
        CYCLE;
    end
    else
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)=false) then CYCLE;

    // Position ausgeben.....
    Inc(vPosCount);

    if (Ein.P.MEH.Wunsch = Ein.P.MEH.Preis) then begin
      vPosMenge # Ein.P.Menge.Wunsch;
      end
    else begin
      vPosMenge # Lib_Einheiten:WandleMEH(501, 0, Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis);
    end;

    Ein.P.Gesamtpreis # Rnd((Ein.P.Grundpreis+Ein.P.Aufpreis) *  vPosMenge / CnvFI(Ein.P.PEH) ,2);

    // Position zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // ARTIKEL DRUCKEN
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) then begin
      // Zeile 1
      // Mengen und Preise
      begin
        PL_Print(AInt(Ein.P.Position),cPos1);
        PL_Print(Art.Nummer,cPos2);
        PL_PrintF(Ein.P.Menge.Wunsch,2,cPos3a);
        PL_Print(Ein.P.MEH.Wunsch,cPos3b);
        if (Ein.P.MEH.Wunsch<>Ein.P.MEH.Preis) then begin
          if (Ein.P.MEH.Preis='m') or (Ein.P.MEH.Preis='qm') then
            PL_PrintF(vPosMenge,2,cPos4a)
          else if (Ein.P.MEH.Preis='t') then
            PL_PrintF(vPosMenge,3,cPos4a)
          else
            PL_PrintF(vPosMenge,0,cPos4a)
          PL_Print(Ein.P.MEH.Preis,cPos4b);
        end;
        PL_PrintF(Ein.P.Grundpreis,2,cPos5a);
        PL_Print('je',cPos5a+0.8);
        PL_PrintI(Ein.P.PEH,cPos5b);
        PL_Print(Ein.P.MEH.Preis,cPos5c);
        PL_Print_R(vRb1,cPos6,cPos5c+7.0);
        PL_PrintF(Ein.P.Gesamtpreis,2,cPos7);
        PL_PrintLine;
      end; // Zeile 1, Mengen und Preise


      // Zeile 2 und folgende
      // Artikelbezeichnungen
      begin
        PLs_FontSize # 8;

        // Bezeichnungen
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

        if(Ein.P.Bemerkung <> '') then begin
          PL_Print(Ein.P.Bemerkung, cPos2);
          PL_PrintLine;
        end;

        // Artikel Abmessung
        if (Ein.P.AbmessString <> '') then begin
          PL_Print(Ein.P.AbmessString,cPos2);
          PL_PrintLine;
        end;

        // Bestell-Artikeltext drucken
        Lib_Print:Print_Text('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),1, cPos2,cPos7);
      end; // Artikelbezeichnungen


      // Bild ausgeben
      if (Art.Bilddatei<>'') and (Art.Bild.DruckenYN) then begin
        Lib_PrintLine:PrintPic(cPos2,cPos2+50.0,50.0,'*' + Art.Bilddatei);
      end;
    end;  // ARTIKELDRUCK

    //Material
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
      Ein.P.Gesamtpreis # Rnd((Ein.P.Grundpreis) *  vPosMenge / CnvFI(Ein.P.PEH) ,2);

      // -- Positionsdaten --
      PL_Print(AInt(Ein.P.Position),cPos1);
      PL_Print(Wgr.Bezeichnung.L1,cPos2);
      if ("Ein.P.Stückzahl" > 0) then
        PL_Print(AInt("Ein.P.Stückzahl") + ' Stk.',cPos2f);
      PL_PrintF(Ein.P.Menge.Wunsch,2,cPos3a);
      PL_Print(Ein.P.MEH.Wunsch,cPos3b);
      if (Ein.P.MEH.Wunsch<>Ein.P.MEH.Preis) then begin
        if (Ein.P.MEH.Preis='m') or (Ein.P.MEH.Preis='qm') then
          PL_PrintF(vPosMenge,2,cPos4a)
        else if (Ein.P.MEH.Preis='t') then
          PL_PrintF(vPosMenge,3,cPos4a)
        else
          PL_PrintF(vPosMenge,0,cPos4a)
        PL_Print(Ein.P.MEH.Preis,cPos4b);
      end;
      PL_PrintF(Ein.P.Grundpreis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Ein.P.PEH,cPos5b);
      PL_Print(Ein.P.MEH.Preis,cPos5c);
      PL_Print_R(vRb1,cPos6,cPos5c+7.0);
      PL_PrintF(Ein.P.Gesamtpreis,2,cPos7);
      PL_PrintLine;
      PL_Print('',cpos2)
      PL_PrintLine;

      // Falls es sich um einen Material/Artikelmix handelt, dann auch die
      // Artikelnummer und Texte mitdrucken
      if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin

        // Artikel lesen
        Erx # RecLink(250,501,2,_RecFirst);
        If (Erx > _rLocked) then
          RecBufClear(250);

        // Artikelnummer
        PL_Print(Art.Nummer,cPos2);
        PL_PrintLine;

        // Bezeichnungen
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

        // Artikel Abmessung
        if (Ein.P.AbmessString <> '') then begin
          PL_Print(Ein.P.AbmessString,cPos2);
          PL_PrintLine;
        end;


      end;

      // Projektnummer
      if (Ein.P.Projektnummer <> 0) then begin
        PL_Print('Projektnr.:',cPos2);
        PL_Print(StrAdj(AInt(Ein.P.Projektnummer),_StrBegin),cPos2a);
        PL_PrintLine;
      end;

      // Abrufbestnr
      if (Ein.P.AbrufAufNr <> 0) then begin
        PL_Print('Best.Abruf:',cPos2);

        if (Ein.P.AbrufAufPos <> 0) then
          PL_Print(AInt(Ein.P.AbrufAufNr)+ '/' +
                   AInt(Ein.P.AbrufAufPos),cPos2a);
        else
          PL_Print(AInt(Ein.P.AbrufAufNr),cPos2a);

        PL_PrintLine;
      end;

      // AB-Nummer
      if (Ein.P.AB.Nummer <> '') then begin
        PL_Print('AB-Nummer:',cPos2);
        PL_Print(Ein.P.AB.Nummer,cPos2a);
        PL_PrintLine;
      end;

      // Lieferantenartikelnummer
      if (Ein.P.LieferArtNr <> '') then begin
        PL_Print('Lf.-Artikelnr.:',cPos2);
        PL_Print(Ein.P.LieferArtNr,cPos2a);
        PL_PrintLine;
      end;

      // Qualität
      if ("Ein.P.Güte"<>'') then begin
        PL_Print('Qualität:',cPos2);
        PL_Print("Ein.P.Güte" + ' / '+ "Ein.P.Gütenstufe",cPos2a);
        PL_PrintLine;
      end;

      //Ausführung
      if (Ein.P.AusfOben <> '') or (Ein.P.AusfUnten <> '') then begin
        vVerp # '';
        vMerker # '';
        PL_Print('Ausführung:',cPos2);
        // Oben/Vorderseite
        if (Ein.P.AusfOben <> '') then begin

          Erx # RecLink(502, 501, 12, _recFirst);
          WHILE (Erx <= _rLocked) DO BEGIN
            if(Ein.AF.Seite = '1') then begin
               if(vVerp = '') then
                 vVerp # 'Vorderseite: ' + Ein.AF.Bezeichnung;
               else
                vVerp # vVerp + ', ' + Ein.AF.Bezeichnung
            end;
            Erx # RecLink(502, 501, 12, _recNext);
          END;
        end;
        // Unten/Rückseite
        if (Ein.P.AusfUnten <> '') then begin
          Erx # RecLink(502, 501, 12, _recFirst);
          WHILE (Erx <= _rLocked) DO BEGIN
            if(Ein.AF.Seite = '2') then begin
              if(vMerker = '') then
                vMerker # Ein.AF.Bezeichnung;
              else
                vMerker  # vMerker  + ', ' + Ein.AF.Bezeichnung
            end;
            Erx # RecLink(502, 501, 12, _recNext);
          END;
          if (vVerp <> '') then
            vVerp # vVerp + '    Rückseite: ' + vMerker;
          else
            vVerp # 'Rückseite: ' + vMerker;
        end;
        PL_Print(vVerp,cpos2a);
        PL_PrintLine;
      end;

      //Dicke
      if (Ein.P.Dicke<>0.0) then begin
        PL_Print('Dicke ' + Ein.AbmessungsEH + ':',cpos2);
        PL_PrintF_L(Ein.P.Dicke,Set.Stellen.Dicke,cpos2a);

        if (Ein.P.Dickentol<>'') then begin
          PL_Print('Tol.:',cpos2c);
          PL_Print(Ein.P.Dickentol,cpos2d)
        end;

        PL_PrintLine;
      end;

      //Breite
      if (Ein.P.Breite<>0.0) then begin
        PL_Print('Breite ' + Ein.AbmessungsEH + ':',cpos2);
        PL_PrintF_L(Ein.P.Breite,Set.Stellen.Breite,cpos2a);

        if (Ein.P.Breitentol <> '') then begin
          PL_Print('Tol.:',cPos2c);
          PL_Print(Ein.P.Breitentol,cPos2d);
        end;

        PL_PrintLine;
      end;

      //Länge
      if ("Ein.P.Länge"<>0.0)then begin
        PL_Print('Länge ' + Ein.AbmessungsEH + ':', cpos2);
        PL_PrintF_L("Ein.P.Länge","Set.Stellen.Länge",cpos2a)

        if ("Ein.P.Längentol" <> '') then begin
          PL_Print('Tol.:',cPos2c);
          PL_Print("Ein.P.Längentol",cPos2d);
        end;

        PL_PrintLine;
      end;

      // Ringinnendurchmesser
      if ((Ein.P.RID <> 0.0) AND (Ein.P.RIDMAX = 0.0)) then begin
        PL_Print('RID ' + Ein.AbmessungsEH + ':',cpos2);
        PL_Printf_L(Ein.P.RID,4,cPos2a);
        PL_PrintLine;
      end else
      if ((Ein.P.RID <> 0.0) AND (Ein.P.RIDMAX <> 0.0)) then begin
        PL_Print('RID ' + Ein.AbmessungsEH + ':',cpos2);
        PL_Printf_L(Ein.P.RID,Set.Stellen.Radien,cPos2a);
        PL_Print(' - ', cPos2a + 12.0);
        PL_Printf_L(Ein.P.RIDMAX,Set.Stellen.Radien,cPos2a + 20.0);
        PL_PrintLine;
      end else
      if ((Ein.P.RID = 0.0) AND (Ein.P.RIDMAX <> 0.0)) then begin
        PL_Print('RID ' + Ein.AbmessungsEH + ':',cpos2);
        PL_Print('max. ' + CnvAf(Ein.P.RIDMAX),cPos2a);
        PL_PrintLine;
      end;

      // Ringaußendurchmesser
      if ((Ein.P.RAD <> 0.0) AND (Ein.P.RADMAX = 0.0)) then begin
        PL_Print('RAD ' + Ein.AbmessungsEH + ':',cpos2);
        PL_Printf_L(Ein.P.RAD,4,cPos2a);
        PL_PrintLine;
      end else
      if ((Ein.P.RAD <> 0.0) AND (Ein.P.RADMAX <> 0.0)) then begin
        PL_Print('RAD ' + Ein.AbmessungsEH + ':',cpos2);
        PL_Print(CnvAf(Ein.P.RAD) + ' - ' + CnvAf(Ein.P.RADMAX)  ,cPos2a);
        PL_PrintLine;
      end else
      if ((Ein.P.RAD = 0.0) AND (Ein.P.RADMAX <> 0.0)) then begin
        PL_Print('RAD ' + Ein.AbmessungsEH + ':',cpos2);
        PL_Print('max. ' + CnvAf(Ein.P.RADMAX),cPos2a);
        PL_PrintLine;
      end;

      // Zeugnis
      if (Ein.P.Zeugnisart <> '') then begin
        PL_Print('Zeugnis:',cPos2);
        PL_Print(Ein.P.Zeugnisart,cPos2a);
        PL_PrintLine;
      end;

      // Intrastat
      if (Ein.P.Intrastatnr <> '') then begin
        PL_Print('Intrastat.:',cPos2);
        PL_Print(Ein.P.Intrastatnr,cPos2a);
        PL_PrintLine;
      end;

      // Erzeuger
      if (Ein.P.Erzeuger <> 0) then begin
        Erx # RecLink(100,501,11,_RecFirst);
        if (Erx <> _rNoRec) then begin
          PL_Print('Erzeuger:',cPos2);
          PL_Print(Adr.Anrede + ' ' +
                   Adr.Name + ' ' +
                   Adr.Zusatz ,cPos2a);
          PL_PrintLine;
        end;
      end;

      // Positionstext
      if (Ein.P.Bemerkung <> '') then begin
        PL_Print('Bemerkung:',cpos2);
        PL_Print(Ein.P.Bemerkung,cPos2a);
        PL_PrintLine;
      end;

      // Liefertermin & Lieferterminzusatz
      // Liefertermin
      PL_Print('Liefertermin:',cPos2);
      if (Ein.P.Termin1W.Art = 'DA') then begin
        PL_Print(CnvAd(Ein.P.Termin1Wunsch),cPos2a);
      end else
      if (Ein.P.Termin1W.Art = 'KW') then begin
        PL_Print('KW ' + CnvAi(Ein.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                         CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
      end else
      if (Ein.P.Termin1W.Art = 'MO') then begin
        PL_Print(Lib_Berechnungen:Monat_aus_datum(Ein.P.Termin1Wunsch) + ' ' +
                 CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
      end else
      if (Ein.P.Termin1W.Art = 'QU') then begin
        PL_Print(CnvAi(Ein.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
                 CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
      end else
      if (Ein.P.Termin1W.Art = 'SE') then begin
        PL_Print(CnvAi(Ein.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
                 CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
      end else
      if (Ein.P.Termin1W.Art = 'JA') then begin
        PL_Print('Jahr ' +  CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
      end;
      PL_PrintLine;  // Liefertermin und Zusatz ausgeben

        //Etikettierung
      if (Ein.P.Etikettentyp<>0)then begin
        vFlag # _RecFirst;
        WHILE (RecRead(840,1,vFlag) <= _rLocked ) DO BEGIN
          vFlag # _RecNext;
          if (Eti.Nummer = Ein.P.Etikettentyp) then begin
            PL_Print('Etikettierung:',cpos2);
            PL_Print(Eti.Bezeichnung,cpos2a);
            PL_Printline;
          end;
        END;
      end;

      //------Verpackung---------
      vVerp # '';

      if (Ein.P.StehendYN) then
        ADD_VERP('stehend','');

      if (Ein.P.LiegendYN) then
        ADD_VERP('liegend','');

      //Abbindung
      if (Ein.P.AbbindungQ <> 0 or Ein.P.AbbindungL <> 0) then begin
        //Quer
        if(Ein.P.AbbindungQ<>0)then vMerker # 'Abbindung '+ AInt(Ein.P.AbbindungQ)+' x quer' ;
        //Längs
        if(Ein.P.AbbindungL<>0)then begin
          if (vMerker<>'')then
            vMerker # vMerker+'  '+AInt(Ein.P.AbbindungL)+ ' x längs';
          else
            vMerker # 'Abbindung ' + AInt(Ein.P.AbbindungL)+' x längs';
        end;
       ADD_VERP(vMerker,'')
      end;

      if (Ein.P.Zwischenlage <> '') then
        //'Zwischenlage: ',
        ADD_VERP(Ein.P.Zwischenlage,'');

      if (Ein.P.Unterlage <> '') then
        //'Unterlage: ',
        ADD_VERP(Ein.P.Unterlage,'');

      if (Ein.P.Nettoabzug > 0.0) then
        ADD_VERP('Nettoabzug: '+AInt(CnvIF(Ein.P.Nettoabzug))+' kg','');

      if ("Ein.P.Stapelhöhe" > 0.0) then
        ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("Ein.P.Stapelhöhe"))+' mm');

      if (Ein.P.StapelhAbzug > 0.0) then
        ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("Ein.P.StapelhAbzug"))+' mm');
      //Ringgewicht
      if (Ein.P.RingKgVon + Ein.P.RingKgBis  <> 0.0) then begin
        if (Ein.P.RingKgVon <> 0.0 and Ein.P.RingKgBis <> 0.0) then
          vMerker # 'Ringgew.: min. ' + AInt(CnvIF(Ein.P.RingKgVon)) + ' kg  max. ' + AInt(CnvIF(Ein.P.RingKgBis));
        if (Ein.P.RingKgVon <> 0.0 and Ein.P.RingKgBis = 0.0) then
          vMerker # 'Ringgew.: ' + AInt(CnvIF(Ein.P.RingKgVon));
        if (Ein.P.RingKgVon = 0.0 and Ein.P.RingKgBis <> 0.0) then
          vMerker # 'Ringgew.: max. ' + AInt(CnvIF(Ein.P.RingKgBis));
        if (Ein.P.RingKgVon = Ein.P.RingKgBis) then
          vMerker # 'Ringgew.: ' + AInt(CnvIF(Ein.P.RingKgBis));
        vMerker#vMerker+' kg';
        ADD_VERP(vMerker,'')
      end;

      //kg/mm
      if (Ein.P.KgmmVon + Ein.P.KgmmBis  <> 0.0) then begin
        if (Ein.P.KgmmVon <> 0.0 and Ein.P.KgmmBis <> 0.0) then
          vMerker # 'Kg/mm: min. ' + CnvAF(Ein.P.KgmmVon) + ' max. ' + CnvAF(Ein.P.KgmmBis)
        if (Ein.P.KgmmVon <> 0.0 and Ein.P.KgmmBis = 0.0) then
          vMerker # 'Kg/mm: min. ' + CnvAF(Ein.P.KgmmVon)
        if (Ein.P.KgmmVon = 0.0 and Ein.P.KgmmBis <> 0.0) then
          vMerker # 'Kg/mm: max. ' + CnvAF(Ein.P.KgmmBis)
        if (Ein.P.KgmmVon = Ein.P.KgmmBis) then
          vMerker # 'Kg/mm: ' + CnvAF(Ein.P.KgmmBis)
        ADD_VERP(vMerker,'')
      end;

      if ("Ein.P.StückProVE" > 0) then
        ADD_VERP(AInt("Ein.P.StückProVE") + ' Stück pro VE', '');

      if (Ein.P.VEkgMax > 0.0) then
        ADD_VERP('max. kg pro VE: ',AInt(CnvIF(Ein.P.VEkgMax)));

      if (Ein.P.RechtwinkMax > 0.0) then
        ADD_VERP('max. Rechtwinkligkeit: ', CnvAf(Ein.P.RechtwinkMax));

      if (Ein.P.EbenheitMax > 0.0) then
        ADD_VERP('max. Ebenheit: ', CnvAf(Ein.P.EbenheitMax));

      if ("Ein.P.SäbeligkeitMax" > 0.0) then
        ADD_VERP('max. Säbeligkeit: ', CnvAf("Ein.P.SäbeligkeitMax"));

      if (vVerp <> '') then begin
        PL_Print('Verpackung:',cpos2);
        PL_Print(vVerp,cPos2a,cPos7);
        PL_Printline;
      end;

      if (Ein.P.VpgText1 <> '') then begin
        PL_Print(Ein.P.VpgText1,cPos2a);
        PL_Printline;
      end;
      if (Ein.P.VpgText2 <> '') then begin
        PL_Print(Ein.P.VpgText2,cPos2a);
        PL_Printline;
      end;
      if (Ein.P.VpgText3 <> '') then begin
        PL_Print(Ein.P.VpgText3,cPos2a);
        PL_Printline;
      end;
      if (Ein.P.VpgText4 <> '') then begin
        PL_Print(Ein.P.VpgText4,cPos2a);
        PL_Printline;
      end;
      if (Ein.P.VpgText5 <> '') then begin
        PL_Print(Ein.P.VpgText5,cPos2a);
        PL_Printline;
      end;
      if (Ein.P.VpgText6 <> '') then begin
        PL_Print(Ein.P.VpgText6,cPos2a);
        PL_Printline;
      end;

      //mech Analyse
      GV.Logic.01#false;//=Noch kein Element gelistet (für 'Mech. Analyse:')
      AddMech('Streckgrenze',Ein.P.Streckgrenze1 , Ein.P.Streckgrenze2,'N/mm²');
      AddMech('Zugfestigkeit',Ein.P.Zugfestigkeit1 , Ein.P.Zugfestigkeit2,'N/mm²');
      if (Ein.P.DehnungA1+Ein.P.DehnungA2+Ein.P.DehnungB1+Ein.P.DehnungB2<>0.0)then begin
        if (GV.Logic.01=false)then begin GV.Logic.01#true;PL_Print('Mech. Analyse:',cPos2); end;
        PL_Print('Dehnung',cPos2a);
        PL_Print(CnvAF(Ein.P.DehnungA1) + ' / ' + CnvAF(Ein.P.DehnungB1) + '% - ' + CnvAF(Ein.P.DehnungA2) + ' / ' + CnvAF(Ein.P.DehnungB2) + '%',75.0);
        PL_PrintLine;
      end;
      AddMech('Rp 0,2',Ein.P.DehngrenzeA1 , Ein.P.DehngrenzeA2,'N/mm²');
      AddMech('Rp 10',Ein.P.DehngrenzeB1 , Ein.P.DehngrenzeB2,'N/mm²');
      if ("Set.Mech.Titel.Körn" <> '') then AddMech("Set.Mech.Titel.Körn","Ein.P.Körnung1", "Ein.P.Körnung2",'')
      else AddMech('Körnung',"Ein.P.Körnung1", "Ein.P.Körnung2",'');
      if ("Set.Mech.Titel.Härte" <> '') then AddMech("Set.Mech.Titel.Härte","Ein.P.Härte1" , "Ein.P.Härte2",'')
      else AddMech('Härte',"Ein.P.Härte1" , "Ein.P.Härte2",'');
      //AddMech('Körnung',"Ein.P.Körnung1", "Ein.P.Körnung2",'');
      //AddMech('Härte',"Ein.P.Härte1" , "Ein.P.Härte2",'');
      // Sonstiges
      if ("Ein.P.Mech.Sonstig1" <> '') then begin
        if ("Set.Mech.Titel.Sonst" <> '') then begin
          PL_Print("Set.Mech.Titel.Sonst",cpos2a);
          PL_Print("Ein.P.Mech.Sonstig1",75.0);
        end
        else begin
          PL_Print('Sonstiges',cpos2a);
          PL_Print("Ein.P.Mech.Sonstig1",75.0);
        end;
        PL_PrintLine;
      end;

      //chemische Analyse
      GV.Logic.01#false;  //=Noch kein Element gelistet (für 'Chem. Analyse:')
      GV.Int.01#0;    //Akt. Spalte
      AddChem('C' ,Set.Chemie.Titel.C   ,Ein.P.Chemie.C1,Ein.P.Chemie.C2);
      AddChem('Si',Set.Chemie.Titel.Si  ,Ein.P.Chemie.Si1,Ein.P.Chemie.Si2);
      AddChem('Mn',Set.Chemie.Titel.Mn  ,Ein.P.Chemie.Mn1,Ein.P.Chemie.Mn2);
      AddChem('P' ,Set.Chemie.Titel.P   ,Ein.P.Chemie.P1,Ein.P.Chemie.P2);
      AddChem('S' ,Set.Chemie.Titel.S   ,Ein.P.Chemie.S1,Ein.P.Chemie.S2);
      AddChem('Al',Set.Chemie.Titel.Al  ,Ein.P.Chemie.Al1,Ein.P.Chemie.Al2);
      AddChem('Cr',Set.Chemie.Titel.Cr  ,Ein.P.Chemie.Cr1,Ein.P.Chemie.Cr2);
      AddChem('V' ,Set.Chemie.Titel.V   ,Ein.P.Chemie.V1,Ein.P.Chemie.V2);
      AddChem('Nb',Set.Chemie.Titel.Nb  ,Ein.P.Chemie.Nb1,Ein.P.Chemie.Nb2);
      AddChem('Ti',Set.Chemie.Titel.Ti  ,Ein.P.Chemie.Ti1,Ein.P.Chemie.Ti2);
      AddChem('N' ,Set.Chemie.Titel.N   ,Ein.P.Chemie.N1,Ein.P.Chemie.N2);
      AddChem('Cu',Set.Chemie.Titel.Cu  ,Ein.P.Chemie.Cu1,Ein.P.Chemie.Cu2);
      AddChem('Ni',Set.Chemie.Titel.Ni  ,Ein.P.Chemie.Ni1,Ein.P.Chemie.Ni2);
      AddChem('Mo',Set.Chemie.Titel.Mo  ,Ein.P.Chemie.Mo1,Ein.P.Chemie.Mo2);
      AddChem('B' ,Set.Chemie.Titel.B   ,Ein.P.Chemie.B1,Ein.P.Chemie.B2);
      AddChem(''  ,Set.Chemie.Titel.1   ,Ein.P.Chemie.Frei1.1,Ein.P.Chemie.Frei1.2);
      PL_Printline;
    end;  //sub MaterialDruck

    // Positionstext ausgeben
    vTxtName # '';
    PLs_FontSize # 8;
    if (Ein.P.TextNr1=500) then // anderer Positionstext
      vTxtName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Ein.P.TextNr1=0) and (Ein.P.TextNr2 != 0) then   // Standardtext
      vTxtName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    if (Ein.P.TextNr1=501) then // Individuell
      vTxtName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (vTxtName != '') then begin
      PL_Printline;

//      Lib_Print:Print_Text(vTxtName,1,cPos2,cPos7);  // drucken
      Lib_Print:Print_Text(vTxtName,1,cPos2);  // drucken
    end;

    vPosMwSt        # 0.0;
    vPosAnzahlAkt   # 0;
    vPosGewicht     # Ein.P.Gewicht;
    vPosStk         # "Ein.P.Stückzahl";
    vPosNettoRabBar # Ein.P.Gesamtpreis;
    vPosNetto       # Ein.P.Gesamtpreis;


    // Aufpreise: MEH-Bezogen
    // Aufpreise: MEH-Bezogen
    // Aufpreise: MEH-Bezogen


    // ***** Aufpreisdruck alt: Erx # RecLink(503,501,7,_RecFirst);
    // ***** Aufpreisdruck alt: WHILE (Erx<=_rLocked) do begin
    // ***** Aufpreisdruck alt:   if (Ein.Z.MengenbezugYN) and
    // ***** Aufpreisdruck alt:   ((Ein.Z.MEH='%') or (Ein.Z.MEH=Ein.P.MEH.Preis)) then begin
    // ***** Aufpreisdruck alt:     if (vRb1='') then begin
    // ***** Aufpreisdruck alt:       if ("Ein.Z.Schlüssel" = '*RAB1') or ("Ein.Z.Schlüssel" = '*RAB2') then
    // ***** Aufpreisdruck alt:         Ein.Z.Bezeichnung # CnvAF(-Ein.Z.Menge) + ' %';
    // ***** Aufpreisdruck alt:       // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // ***** Aufpreisdruck alt:       PL_Print_R(Ein.Z.Bezeichnung,cPos6,cPos5c+7.0);
    // ***** Aufpreisdruck alt:       PL_PrintLine;
    // ***** Aufpreisdruck alt:     end;
    // ***** Aufpreisdruck alt:     vRb1 # '';
    // ***** Aufpreisdruck alt:   end;
    // ***** Aufpreisdruck alt:   Erx # RecLink(503,501,7,_RecNext);
    // ***** Aufpreisdruck alt: END;
    // ***** Aufpreisdruck alt:
    // ***** Aufpreisdruck alt: RecBufClear(503);

    // >>>> übernommen aus Auftragsbest. und angepasst
    vFirst # true;
    Erx # RecLink(503,501,7,_RecFirst);   // Aufpreise loopn
        WHILE (Erx<=_rLocked) do begin
          if /*("Auf.Z.Schlüssel" <> '*RAB1') and ("Auf.Z.Schlüssel" <> '*RAB2') and*/
            ((Ein.Z.MengenbezugYN) and (Ein.Z.MEH=Ein.P.MEH.Preis)) then begin
            if (vFirst) then begin
              PL_PrintLine;
              pls_FontAttr # _WinFontAttrBold;
              //PL_Print('mengenbezogene Positionsaufpreise',cPos2);
              PL_Print('Positionsaufpreise',cPos2);
              pls_FontAttr # 0;
              PL_PrintLine;
              Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
              vFirst # n;
            end;

            Ein.Z.Menge # Lib_Einheiten:WandleMEH(503, vPosStk, vPosGewicht, vPosMenge, Ein.P.MEH.Wunsch, Ein.Z.MEH)
            vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
            PL_Print(Ein.Z.Bezeichnung,cPos2);
            PL_PrintF(Ein.Z.Preis,2,cPos5a);
            PL_Print('je',cPos5a+0.8);
            PL_PrintI(Ein.Z.PEH,cPos5b);
            PL_Print(Ein.Z.MEH,cPos5c);
            PL_PrintF(vPreis,2,cPos7);
            PL_PrintLine;

            vPosNetto    # vPosNetto    + vPreis;
            if (Ein.Z.RabattierbarYN) then
              vPosNettoRabbar # vPosNettoRabBar + vPreis;
          end;
          Erx # RecLink(503,501,7,_RecNext);
        END;
      // <<<< übernommen aus Auftragsbest. und angepasst
































    // Drucken Start
    Ein.Z.PEH # vVPGPEH;
    Ein.Z.MEH # vVPGMEH;
    if (Ein.Z.Preis = 0.0) then
      Ein.Z.Preis # vVPGPreis;

    if (Ein.Z.Menge <> 0.0) AND (Ein.Z.PEH <> 0) then begin
      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      // Verpackung zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PL_Print(Ein.Z.Bezeichnung,cPos2);
      if (Ein.Z.MEH='m') or (Ein.Z.MEH='qm') then
        PL_PrintF(Ein.Z.Menge,2,cPos3a)
      else if (Ein.Z.MEH='t') then
        PL_PrintF(Ein.Z.Menge,3,cPos3a)
      else
        PL_PrintF(Ein.Z.Menge,0,cPos3a)
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintF(Ein.Z.Preis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Ein.Z.PEH,cPos5b);
      PL_Print(Ein.Z.MEH,cPos5c);
      PL_PrintF(vPreis,2,cPos7);
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintLine;

      vPosNetto # vPosNetto + vPreis;
      if (Ein.Z.RabattierbarYN) then
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
      PL_Print('zusätzliche Positionsaufpreise',cPos2);
      pls_FontAttr # 0;
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPos2,cPos7);


      // Aufpreise: fremd MEH-Bezogen
      // Aufpreise: fremd MEH-Bezogen
      // Aufpreise: fremd MEH-Bezogen
      Erx # RecLink(503,501,7,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Ein.Z.MengenbezugYN) and
        ((Ein.Z.MEH<>'%') and (Ein.Z.MEH<>Ein.P.MEH.Preis)) then begin
          Ein.Z.Menge # Lib_Einheiten:WandleMEH(503, vPosStk, vPosGewicht, vPosMenge, Ein.P.MEH.Wunsch, Ein.Z.MEH)
          vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Ein.Z.Bezeichnung,cPos2);
          if (Ein.Z.MEH='m') or (Ein.Z.MEH='qm') then
            PL_PrintF(Ein.Z.Menge,2,cPos3a)
          else if (Ein.Z.MEH='t') then
            PL_PrintF(Ein.Z.Menge,3,cPos3a)
          else
            PL_PrintF(Ein.Z.Menge,0,cPos3a)
          PL_Print(Ein.Z.MEH,cPos3b);
          PL_PrintF(Ein.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Ein.Z.PEH,cPos5b);
          PL_Print(Ein.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Ein.Z.MEH,cPos3b);
          PL_PrintLine;

          vPosNetto # vPosNetto + vPreis;
          if (Ein.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;
        end

        Erx # RecLink(503,501,7,_RecNext);
      END;

      // Aufpreise: NICHT MEH-Bezogen =FIX
      // Aufpreise: NICHT MEH-Bezogen =FIX
      // Aufpreise: NICHT MEH-Bezogen =FIX
      Erx # RecLink(503,501,7,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Ein.Z.MengenbezugYN=n) then begin

          if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,501);

          vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Ein.Z.Bezeichnung,cPos2);
          if (Ein.Z.MEH='m') or (Ein.Z.MEH='qm') then
            PL_PrintF(Ein.Z.Menge,2,cPos3a)
          else if (Ein.Z.MEH='t') then
            PL_PrintF(Ein.Z.Menge,3,cPos3a)
          else
          PL_PrintF(Ein.Z.Menge,0,cPos3a)
          PL_Print(Ein.Z.MEH,cPos3b);
          PL_PrintF(Ein.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Ein.Z.PEH,cPos5b);
          PL_Print(Ein.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Ein.Z.MEH,cPos3b);
          PL_PrintLine;

          vPosNetto # vPosNetto + vPreis;
          if (Ein.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;
        end;
        Erx # RecLink(503,501,7,_RecNext);
      END;

    end;

    //= POSAUFPREISE ENDE ===================================================



    // Mehrwertsteuersätze
    RecLink(819,501,1,_RecFirst); // Warengrupppe lesen

    Erx # RecLink(250,501,2,_recFirst);
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
    vGesamtNettoRabBar  # vGesamtNettoRabBar + vPosNettoRabBar;
    vGesamtNetto        # vGesamtNetto + vPosNetto;

    // Leerzeile zwischen den Positionen
    PL_PrintLine;

  END; // WHILE: Positionen ************************************************




  // prüfen ob Aufpr. vorhanden sind, falls ja: Aufpreiskopf drucken
  vGibtsAufZ # false;
  Erx # RecLink(503,500,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.Nummer <> Ein.Nummer) then break;

    if (Ein.Z.Position=0)
    and (((Ein.Z.MengenbezugYN=n) and (Ein.Z.Menge<>0.0)) or (Ein.Z.MengenbezugYN))then begin
      vGibtsAufZ # true;
      break;
    end;
    Erx # RecLink(503,500,13,_RecNext);
  END;

  if (vGibtsAufZ) then begin
    PL_PrintLine;
    pls_FontAttr # _WinFontAttrBold;
    PL_Print('zusätzliche Auftragsaufpreise',cPos2);
    pls_FontAttr # 0;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
  end;

  // KopfAufpreise: NICHT MEH-Bezogen =FIX
  // KopfAufpreise: NICHT MEH-Bezogen =FIX
  // KopfAufpreise: NICHT MEH-Bezogen =FIX
  Ein.Z.Position  # 0;
  vKopfAufpreis # vGesamtNetto;
  Erx # RecLink(503,500,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.Position=0) AND (Ein.Z.Nummer = Ein.Nummer)and (Ein.Z.MengenbezugYN=n) and
      (Ein.Z.Menge<>0.0) then begin

      if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,500);

      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

      // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PL_Print(Ein.Z.Bezeichnung,cPos2);
      if (Ein.Z.MEH='m') or (Ein.Z.MEH='qm') then
        PL_PrintF(Ein.Z.Menge,2,cPos3a)
      else if (Ein.Z.MEH='t') then
        PL_PrintF(Ein.Z.Menge,3,cPos3a)
      else
        PL_PrintF(Ein.Z.Menge,0,cPos3a)
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintF(Ein.Z.Preis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Ein.Z.PEH,cPos5b);
      PL_Print(Ein.Z.MEH,cPos5c);
      PL_PrintF(vPreis,2,cPos7);
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintLine;

      vGesamtNetto # vGesamtNetto + vPreis;
      vMwstWert1 # vMwstWert1 + vPreis;

      if (Ein.Z.RabattierbarYN) then
        vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;

    end;

    Erx # RecLink(503,500,13,_RecNext);
  END;


  // KopfAufpreise: %
  // KopfAufpreise: %
  // KopfAufpreise: %
  RecBufClear(503);
  Ein.Z.Nummer    # Ein.Nummer;
  Ein.Z.Position  # 0;
  Erx # RecLink(503,500,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') AND (Ein.Z.Position = 0) AND (Ein.Z.Nummer = Ein.Nummer)then begin
      Ein.Z.Preis # vGesamtNetto;
      Ein.Z.PEH   # 100;
      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

      // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PL_Print(Ein.Z.Bezeichnung,cPos2);
      if (Ein.Z.MEH='m') or (Ein.Z.MEH='qm') then
        PL_PrintF(Ein.Z.Menge,2,cPos3a)
      else if (Ein.Z.MEH='t') then
        PL_PrintF(Ein.Z.Menge,3,cPos3a)
      else
        PL_PrintF(Ein.Z.Menge,0,cPos3a)
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintF(Ein.Z.Preis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Ein.Z.PEH,cPos5b);
      PL_Print(Ein.Z.MEH,cPos5c);
      PL_PrintF(vPreis,2,cPos7);
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintLine;

      vGesamtNetto # vGesamtNetto + vPreis;
      vMwstWert1 # vMwstWert1 + vPreis;

      if (Ein.Z.RabattierbarYN) then
        vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;

    end;

    Erx # RecLink(503,500,13,_RecNext);
  END;

  vKopfAufpreis # vGesamtNetto - vKopfAufpreis;


  // KopfAufpreise: MEH-bezogen
  // KopfAufpreise: MEH-Bezogen
  // KopfAufpreise: MEH-Bezogen
  Ein.Z.Position  # 0;
  Erx # RecLink(503,500,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') and (Ein.Z.Position=0) AND (Ein.Z.Nummer = Ein.Nummer)then begin
      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(503, vPosStk, vPosGewicht, vPosMenge, Ein.P.MEH.Wunsch, Ein.Z.MEH)
      vPreis #  Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);

      // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      PL_Print(Ein.Z.Bezeichnung,cPos2);
      if (Ein.Z.MEH='m') or (Ein.Z.MEH='qm') then
        PL_PrintF(Ein.Z.Menge,2,cPos3a)
      else if (Ein.Z.MEH='t') then
        PL_PrintF(Ein.Z.Menge,3,cPos3a)
      else
        PL_PrintF(Ein.Z.Menge,0,cPos3a)
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintF(Ein.Z.Preis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Ein.Z.PEH,cPos5b);
      PL_Print(Ein.Z.MEH,cPos5c);
      PL_PrintF(vPreis,2,cPos7);
      PL_Print(Ein.Z.MEH,cPos3b);
      PL_PrintLine;

      vPosNetto # vPosNetto + vPreis;
      vMwstWert1 # vMwstWert1 + vPreis;

      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vPreis;

    end;
    Erx # RecLink(503,500,13,_RecNext);
  END;




  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(100.0,_PrtUnitMillimetres)) do
  PL_PrintLine;
  Lib_Print:Print_LinieDoppelt();
  Lib_Print:Print_Textzeile('');

  // Lieferbedinungen und Co drucken
  Erx # RecLink(815,500,5,_RecFirst);   // Lieferbedingung lesen
  if(Erx > _rLocked) then
    RecBufClear(815);
  Erx # RecLink(816,500,6,_RecFirst);   // Zahlungsbedingung lesen
  if(Erx > _rLocked) then
    RecBufClear(816);
  Erx # RecLink(817,500,7,_RecFirst);   // Versandart lesen
  if(Erx > _rLocked) then
    RecBufClear(817);
  PLs_FontSize # 10
  PL_Print('Lieferung:',cPos1);
  PL_Print(Lib.Bezeichnung.L1,cPosFuss2);
  PL_PrintLine;

  PL_Print('Zahlung:',cPos1);
  vA # Ofp_data:BuildZabString(Zab.Bezeichnung1.L1, 0.0.0,0.0.0);
  PL_Print(vA,cPosFuss2);
  PL_PrintLine;
  if (ZaB.Bezeichnung2.L2<>'') then begin
    PL_Print(Zab.Bezeichnung2.L2,cPosFuss2);
    PL_PrintLine;
  end;
  PL_Print('Versandart:',cPos1);
  PL_Print(Vsa.Bezeichnung.L1,cPosFuss2);
  PL_PrintLine;


  //  Rechungsempfänger bei Abweichung
  if (Ein.Lieferantennr <> Ein.Rechnungsempf) and (Ein.Rechnungsempf <> 0) then begin

    // RE Empänger lesen
    RecLink(100,500,4,_RecFirst);
    // Firmenbezeichnung in erste Zeile
    vRechnungsempf #  StrAdj(Adr.Anrede,_StrBegin | _StrEnd)  + ' ' +
                      StrAdj(Adr.Name,_StrBegin | _StrEnd)    + ' ' +
                      StrAdj(Adr.Zusatz,_StrBegin | _StrEnd);
    // Adresse in zweite Zeile
    // Post zum Postfach?
    if (Adr.Postfach <> '') then begin
      vRechnungsempf #  vRechnungsempf                              + ', Postfach ' +
                        StrAdj(Adr.Postfach,_StrBegin | _StrEnd)    + ', '+
                        StrAdj(Adr.Postfach.PLZ,_StrBegin | _StrEnd)+ ' ' +
                        StrAdj(Adr.Ort,_StrBegin | _StrEnd);
      end
    else begin
      vRechnungsempf #  vRechnungsempf                            + ', '+
                        StrAdj("Adr.Straße",_StrBegin | _StrEnd)  + ', '+
                        StrAdj(Adr.LKZ,_StrBegin | _StrEnd)       + '-' +
                        StrAdj(Adr.PLZ,_StrBegin | _StrEnd)       + ' ' +
                        StrAdj(Adr.Ort,_StrBegin | _StrEnd);
    end;
    PLs_FontSize # 10
    PL_Print('Rechnungsempfänger:',cPos1);
    PL_Print(vRechnungsempf,cPosFuss2,cPos7);
    PL_PrintLine;
  end;


  //  Warenempfänger bei Abweichung
  //  Bestellungkunde lesen um auf Adressnummer zu vergleichen
  Erx # RecLink(100,500,1,_RecFirst);   // Lieferant holen

  if (Ein.Lieferadresse <> 0) and ((Adr.Nummer <> Ein.Lieferadresse) or
    ((Adr.Nummer = Ein.Lieferadresse) and (Ein.Lieferanschrift > 1))) then begin

    // Lieferadresse lesen
    RecLink(100,500,12,_RecFirst);
    vWarenempf #  StrAdj(Adr.Anrede,_StrBegin | _StrEnd)    + ' ' +
                  StrAdj(Adr.Name,_StrBegin | _StrEnd)      + ' ' +
                  StrAdj(Adr.Zusatz,_StrBegin | _StrEnd)    + ', '+
                  StrAdj("Adr.Straße",_StrBegin | _StrEnd)  + ', '+
                  StrAdj(Adr.LKZ,_StrBegin | _StrEnd)       + '-' +
                  StrAdj(Adr.PLZ,_StrBegin | _StrEnd)       + ' ' +
                  StrAdj(Adr.Ort,_StrBegin | _StrEnd);
    // ggf. Anschrift lesen
    if (Ein.Lieferanschrift <> 0) then begin
      Adr.A.Adressnr  # Ein.Lieferadresse;
      Adr.A.Nummer    # Ein.Lieferanschrift;
      RecRead(101,1,0);
      vWarenempf  # StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd)  + ' ' +
                    StrAdj(Adr.A.Name,_StrBegin | _StrEnd)    + ' ' +
                    StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)  + ', '+
                    StrAdj("Adr.A.Straße",_StrBegin | _StrEnd)+ ', '+
                    StrAdj(Adr.A.LKZ,_StrBegin | _StrEnd)     + '-' +
                    StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd)     + ' ' +
                    StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
    end;

    // Leerzeichen am Anfang entfernen
    vWarenempf # StrAdj(vWarenempf, _StrBegin | _StrEnd);
    PLs_FontSize # 10
    PL_Print('Warenempfänger:',cPos1);
    PL_Print(vWarenempf,cPosFuss2,cPos7);
    PL_PrintLine;
  end;

  Lib_Print:Print_Textzeile('');

  // Fusstext drucken
  vTxtName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  Lib_Print:Print_Text(vTxtName,1, cPos1);


  // ggf. hier Texte für Auslandsgeschäfte etc. Drucken


  PL_PrintLine;
  PL_PrintLine;
  PL_Print('mit freundlichen Grüßen',cPos1);
  PL_PrintLine;


  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;



//========================================================================