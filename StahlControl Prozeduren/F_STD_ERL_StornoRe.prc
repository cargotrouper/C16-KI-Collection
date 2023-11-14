@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_ERL_StornoRe
//                        OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  22.06.2007  NH  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  22.05.2019  TM  Kopftext deaktiviert
//  06.08.2021  SY  Bugfix: Ausgabe von Netto anstatt NettoW1
//  15.12.2021  SR  Brutto statt BruttoW1
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
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;
  cPos0   :  10.0   // Anschrift
  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  21.0   // Bez.
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
  cPosKopf3 : 35.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...

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
  RecLink(100,450,8,_RecFirst);   // Rechnungsempf. holen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Erl.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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
       RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,450,8,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      Erx # RecLink(110,450,7,_recFirst);  // Vertreter holen
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
      Erx # RecLink(110,450,6,_recFirst);  // Verband holen
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
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
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
  vBuf100 # RekSave(100);
  vBuf101 # RekSave(101);
  //RecLink(100,450,5,_RecFirst);   // Kunde holen
  RecLink(100,450,8,_RecFirst);   // Rechnungsempfänger holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;

  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Auftragsnummer:',cPosKopf1);
  PL_PrintI_L(Auf.Nummer,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Name     , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Kundennr.:',cPosKopf1);
  PL_PrintI_L(Auf.Kundennr,cPosKopf2);
  PL_PrintLine;


  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Unsere Lf.Nr.:',cPosKopf1);
  PL_Print(Adr.VK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  Pls_fontSize # 9;

  Adr.Nummer # Set.eigeneAdressNr;    // eigene Adresse holen
  RecRead(100,1,0);
  PL_Print('Unsere Steuernr.:',cPosKopf1);
  PL_Print(Adr.Steuernummer,cPosKopf2);
  RecLink(100,450,5,_RecFirst);   // Kunde holen
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
  Pls_fontSize # 9;
  PL_Print('Ihre Steuernr.:',cPosKopf1);
  PL_Print(Adr.Steuernummer,cPosKopf2);
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


  if (Erl.Rechnungstyp = 418 or Erl.Rechnungstyp = 428) then begin
    // Storno LieferantenGutschrift/Belastung
    Erx # RecRead(560,1,_recLast);
    WHILE (Erx <= _rLocked) DO BEGIN

      If (ERe.Rechnungsnr = 'GUT-LF ' + CnvAI(Erl.StornoRechNr,_FmtNumNoGroup) + ' STORNO')
      or (ERe.Rechnungsnr = 'BEL-LF ' + CnvAI(Erl.StornoRechNr,_FmtNumNoGroup) + ' STORNO')
      then begin
        BREAK;
      end;

      Erx # RecRead(560,1,_recPrev);
    END;
    if (Erx > _rLocked) then begin
      RecBufClear(560);
    end
    else begin // ERE Daten nur übernehmen bei vorhandener GUT/BEL LF
      "Erl.Stückzahl" # "ERe.Stückzahl";
      Erl.Gewicht     # ERe.Gewicht;
      Erl.Netto       # ERe.Netto;
      Erl.NettoW1     # ERe.NettoW1;
      Erl.Steuer      # ERe.Steuer;
      Erl.SteuerW1    # ERe.SteuerW1;
      Erl.Brutto      # ERe.Brutto;
      Erl.BruttoW1    # ERe.BruttoW1;
    end;

  end;



  Pl_Print(translate('Stornorechnung') + ' ' + AInt(Erl.Rechnungsnr) ,cPos1);
  PL_PrintLine;PL_PrintLine;
  Pls_FontSize # 7;
  Pl_Print(translate('Stornierung der Rechnung') + ' ' + AInt(Erl.StornoRechNr) ,cPos1);
  pl_PrintLine;


  Pls_FontSize # 7;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;

    // Kopftext drucken
    // vTxtName # '~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
    // Lib_Print:Print_Text(vTxtName,1, cPos1);
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
    PL_Drawbox(cPos1-1.0,cPos9+1.0,_WinColblack, 5.0);
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
  vKopfaufpreis       : float;
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

  // ------ Druck vorbereiten ----------------------------------------------------------------
  // Lieferdatum übernehmen
  vBisLiefDatum # Gv.Datum.01;


  RecLink(100,450,8,_RecFirst);   // Rechnungsempf. lesen
  RecLink(814,450,3,_RecFirst);   // Währung holen


  // Seitenfuss zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  PL_Create(vPLFooter);
  vFooter # pls_Prt;
  PL_Print('ÜBERTRAG',cPos2);
  pls_hdl->ppdbfieldname # 'Gv.Alpha.01';
  PL_Print_R('[SUM1]',cPos7);

//  vFooter # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Seitenende');

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,n,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();


  vAdresse    # Adr.Nummer;
  RecLink(100,450,8,_RecFirst);   // Rechnungsempf. lesen
  vMwstSatz1 # -1.0;
  vMwstSatz2 # -1.0;

// ------- POSITIONEN --------------------------------------------------------------------------
  pls_Fontsize # 8;
  PL_Print('1',cpos1)
  PL_Print('Stornierung der Rechnung ' + AInt(Erl.StornoRechNr),cpos2)
  vGesamtNetto       # Erl.Netto;

  PL_Print(ANum(Erl.Netto,2),cpos6);

   RecLink(819,401,1,_RecFirst); // Warengrupppe lesen

    Erx # RecLink(250,401,2,_recFirst);
    StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
    Erx # RecRead(813,1,0);
    vPosMwst # StS.Prozent;
  vMwstSatz1 # vPosMwSt;
// ------- FUßDATEN --------------------------------------------------------------------------
  form_footer # 0;
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(100.0,_PrtUnitMillimetres)) do
    PL_PrintLine;

  Lib_Print:Print_LinieDoppelt();

  // Mehrwertstuern errechnen

  // Summen drucken
  pls_Fontsize # 10;
  PL_Print_R('Warenwert '+"Wae.Kürzel",cPos7-25.0);
  PL_PrintF(vGesamtNetto,2,cPos7);
  PL_PrintLine;

  pls_Fontsize # 10;
  if ( Erl.Netto<>0.0) then
    PL_Print_R(ANum((Erl.Brutto/Erl.Netto-1.0)*100.0,2) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
  else
    PL_Print_R('MwSt. '+ "Wae.Kürzel",cPos7-25.0);
  PL_PrintF(Erl.Steuer,2,cPos7);
  PL_PrintLine;

  Lib_Print:Print_LinieEinzeln(cPos7-20.0,cPos7);

  pls_Fontsize # 10;
  pls_FontAttr # _WinFontAttrBold ;
  PL_Print_R('Rech.Betrag '+"Wae.Kürzel",cPos7-25.0);
//  pls_FontAttr # _WinFontAttrBold | _WinFontAttrUnderline;
  PL_PrintF(Erl.Brutto,2,cPos7);
  pls_FontAttr # 0;
  PL_PrintLine;
  Lib_Print:Print_LinieDoppelt(cPos7-20.0,cPos7);

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", (Erl.Rechnungsnr=0));
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", (Erl.Rechnungsnr=0), n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

  // Dokument in die Ablage eintragen
//  if (Erl.Rechnungsnr<>0) then
//    Lib_Dokumente:InsertDok(Frm.Bereich,Frm.Name,vDokName,vDokSprache)
//  else
//    Lib_Dokumente:KillDok(Frm.Bereich,Frm.Name,vDokName,vDokSprache);

end;

//========================================================================