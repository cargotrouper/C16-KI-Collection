@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_LFS_Avis
//                      OHNE E_R_G
//  Info
//    Druckt eine VSB Meldung aus
//
//
//  31.05.2011  AI  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB HoleEmpfaenger();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cPos0   :  10.0

  cPos1   :  15.0 // Pos
  cPos1a  :  30.0
  cPos2   :  40.0 //
  cPos3   :  50.0 // Menge1
  cPos4   :  70.0 // Menge2
  cPos5   :  90.0 // Einzelpreis
  cPos6   : 120.0 // Rabatt
  cPos7   : 140.0 // Gesamt
  cPos8   : 161.0 // Gesamt
  cPos9   : 182.0 // Gesamt
  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cFussSign1 : 10.0  // Unterschriften
  cFussSign2 : 70.0  //  Unterschriften
  cFussSign3 :130.0  //Unterschriften

  cPosBX00 : 1.0
  cPosBX01 : 4.7
  cPosBX02 : 8.7
  cPosBX03 : 13.7

  cPosBY00 : 28.0
  cPosBY01 : 28.3
  cPosBY02 : 28.6
  cPosBY03 : 28.95
  cPosBY04 : 29.25
  cPosBY05 : 29.55


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
  RecLink(100,440,2,_recFirst);    // Zieladresse lesen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Lfs.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,440,2,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,440,3,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
        RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
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
       RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
        RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
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

end;
begin

  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    RecLink(100,440,2,_recFirst);    // Zieladresse lesen
    RecLink(101,440,3,_recFirst);    // Zielanschrift lesen
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;

    Pls_fontSize # 6
    pls_Fontattr # _WinFontAttrU;
    PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

    pls_Fontattr # 0;
    Pls_fontSize # 10;
    PL_Print(Adr.A.Anrede   , cPos0); PL_PrintLine;
    PL_Print(Adr.A.Name     , cPos0); PL_PrintLine;

    PL_Print(Adr.A.Zusatz   , cPos0);
    Pls_fontSize # 9;
    PL_Print('Unsere Knd.Nr.:',cPosKopf1);
    PL_Print(Adr.VK.Referenznr,cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print("Adr.A.Straße" , cPos0);
    Pls_fontSize # 9;
    PL_Print('Sachbearbeiter:',cPosKopf1);
    PL_Print(Usr_Data:Sachbearbeiter(gUsername),cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print(StrAdj(Adr.A.LKZ + ' ' + Adr.A.PLZ + ' ' + Adr.A.Ort,_StrBegin), cPos0);
    Pls_fontSize # 9;
    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvad(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Lieferavisierung '+AInt(Lfs.Nummer),cPos0 );
    pl_PrintLine;
    pl_PrintLine;
    pls_Fontattr # _WinFontAttrNormal;
    PL_Print('Hiermit stellen wir für Sie auf Basis (Incoterms 2000) wie folgt frei:',cPos0);
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

    PL_PrintLine;

    if (Lfs.Bemerkung <> '') then begin
      PL_Print(Lfs.Bemerkung,cPos0);
      PL_PrintLine;
      PL_PrintLine;
    end;

    end       // 1. Seite
  else begin  // weitere Seiten
    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvad(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Lieferavisierung '+AInt(Lfs.Nummer),cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

  end;

  if (form_mode <> 'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    PL_Print('Pos ',cPos0);
    PL_Print_R('MatNr.',cPos1a);
    PL_Print('Qualität / Abmessung',cPos2);
    PL_Print('Coil-/Tafelnr.',cPos5)
    PL_Print_R('Stück',cPos7);
    PL_Print_R('Brutto kg',cPos8);
    PL_Print_R('Netto kg',cPos9);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 4.5);
    PL_PrintLine;
  end;


end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  // Formularspezifische Variablen
  vText               : alpha(250);    // Variable zur angepassten Textgenerierung
  vMatBeschr          : alpha(250);
  vGesamtStueck       : int;      // Summe Stückzahl
  vGesamtGewichtN     : float;    // Summe Nettogewicht
  vGesamtGewichtB     : float;    // Summe Bruttogewicht
  vFusstexttyp        : int;      // Textinikator für z.B. EG Verbringungsnachweis etc.

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------
  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------

  RecLink(441,440,4,_RecFirst);     // Erste Position lesen, um an die MEH zu kommen

  form_Mode # '';
  Lib_Print:Print_Seitenkopf();

// ------- POSITIONSDATEN ------------------------------------------------------------------

  vFlag # _RecFirst;
  WHILE (RecLink(441,440,4,vFlag) <= _rLocked) DO BEGIN
    vFlag # _RecNext;

    // -------------Material liefern---------------
    if (Lfs.P.Materialtyp = c_IO_VSB) then begin

      // Materialkarte lesen
      if (RecLink(200,441,4,_RecFirst) > _rOK) then
        CYCLE;

      // Positionsnummerierung
      PL_Print(CnvAi(Lfs.P.Position,_FmtNumNoGroup,0,2)       ,cPos0);


      // MAterialnummmer
      PL_Print_R(CnvAi(Lfs.P.Materialnr,_FmtNumNoGroup,0,8)   ,cPos1a);

      PL_Print("Mat.Güte",cPos2);

      if(Mat.Coilnummer<>'') then
        PL_Print(Mat.Coilnummer,cPos5);

      // Stückzahl
      PL_Print_R(CnvAi("Lfs.P.Stück",_FmtNumNoZero | _FmtNumNoGroup),cPos7);

      // Gewicht Brutto
      //PL_Print_R(CnvAf("Lfs.P.Gewicht.Brutto",_FmtNumNoZero,0, Set.Stellen.Gewicht)+ ' kg',cPos8);
      PL_Printf("Lfs.P.Gewicht.Brutto",0,cPos8);

      // Gewicht Netto
      PL_Printf("Lfs.P.Gewicht.Netto",0,cPos9);

      PL_PrintLine;


      // Abmessung
      vMatBeschr # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
                   ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vMatBeschr # vMatBeschr + ' x ' +
                     ANum("Mat.Länge","Set.Stellen.Länge");

      PL_Print(vMatBeschr,cPos2);

      if(Mat.Ringnummer<>'')then begin
        PL_Print(Mat.Ringnummer,cPos5);
      end;

      PL_Printline;

      if(Mat.Strukturnr<>'')then begin
        PL_Print('WO: ' + Mat.Strukturnr,cPos5);
        PL_Printline;
      end;

      // Summierung
      vGesamtStueck   #  vGesamtStueck   + "Lfs.P.Stück";
      vGesamtGewichtN #  vGesamtGewichtN + "Lfs.P.Gewicht.Netto";
      vGesamtGewichtB #  vGesamtGewichtB + "Lfs.P.Gewicht.Brutto"

    end else
    // -----------VSB-------------
    if (Lfs.P.Materialtyp = c_IO_Mat) then begin

      // Materialkarte lesen
      if (RecLink(200,441,4,_RecFirst) > _rOK) then
        CYCLE;


    // Positionsnummerierung
    PL_Print(CnvAi(Lfs.P.Position,_FmtNumNoGroup,0,2)       ,cPos1-2.0);



    PL_PrintI(Mat.Nummer,cPos1a);

    PL_Print("Mat.Güte",cPos2);

    if(Mat.Coilnummer<>'') then
     PL_Print(Mat.Coilnummer,cPos5);


    PL_Print_R(AInt(Mat.Bestand.Stk),cPos7);

    PL_Print_R(ANum(Mat.Gewicht.Brutto,Set.Stellen.Gewicht),cPos8);
    PL_Print_R(ANum(Mat.Gewicht.Netto,Set.Stellen.Gewicht),cPos9);


    PL_PrintLine;


    // Abmessung
    vMatBeschr # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
                 ANum(Mat.Breite,Set.Stellen.Breite);
    if ("Mat.Länge" <> 0.0) then
      vMatBeschr # vMatBeschr + ' x ' +
                   ANum("Mat.Länge","Set.Stellen.Länge");

    PL_Print(vMatBeschr,cPos2);

    if(Mat.Ringnummer<>'')then begin
      PL_Print(Mat.Ringnummer,cPos5);
    end;

    PL_Printline;

    if(Mat.Strukturnr<>'')then begin
      PL_Print('WO: ' + Mat.Strukturnr,cPos5);
      PL_Printline;
    end;

      // Summierung
      vGesamtStueck   #  vGesamtStueck   + "Mat.Bestand.Stk";
      vGesamtGewichtN #  vGesamtGewichtN + "Mat.Gewicht.Netto";
      vGesamtGewichtB #  vGesamtGewichtB + "Mat.Gewicht.Brutto"

    end;

    PL_Printline;     // Leerzeichen zwischen den Positionen

  END;

// ------- FUßDATEN ------------------------------------------------------------------------
  form_Mode # 'FUSS';
  Lib_Print:Print_LinieEinzeln();
  pls_Fontattr # 0;

  //Abholadresse
  RecLink(101,200,6,0)
  vText # StrAdj(Adr.A.Name,_StrBegin | _StrEnd) + ' ' +
        StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd) + ', ' +
        StrAdj("Adr.A.Straße",_StrBegin | _StrEnd) + ', ' +
        StrAdj(StrAdj(Adr.A.LKZ,_StrBegin | _StrEnd) + ' ' +
        StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd),_StrBegin) + ' ' +
        StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
  if (Adr.LKZ <> 'D') then begin
    RecLink(812,101,2,_RecFirst);
    vText # vText + ', '+ Lnd.Name.L1;
  end;

  // Summen ausgeben
  PL_Print('Gesamt:',cPos5);
  PL_Print_R(AInt(vGesamtStueck),cPos7);
  PL_Printf(vGesamtGewichtB,0,cPos8);                                    // Gewicht Brutto
  PL_Printf(vGesamtGewichtN,0,cPos9);                                    // Gewicht Netto
  PL_Printline;
  PL_Printline;
  PL_PrintLine;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Abholadresse:',cPos0);
  PL_Print(vText,cPos2);
  PL_PrintLine;


  if (Lfs.Spediteurnr<>0) then begin
    Erx # RecLink(100,440,6,_recFirst);  // Sepediteur holen
    if (Erx<=_rLocked) then begin
      PL_PrintLine;
      pls_Fontattr # _WinFontAttrBold;
      vText # StrAdj(Adr.Name,_StrBegin | _StrEnd) + ' ' +
            StrAdj(Adr.Zusatz,_StrBegin | _StrEnd);
      PL_Print('Spediteuer:',cPos0);
      PL_Print(vText,cPos2);
      PL_PrintLine;
    end;
  end;

  pls_Fontattr # _WinFontAttrNormal;
  PL_PrintLine;
  PL_Print('Wir bitten Sie, sich spätestens 48 Stunden vor Abholung zwecks',cPos0);
  PL_PrintLine;
  PL_Print('Terminabstimmung mit o.a. Lagerhalter in Verbingung zu setzen.',cPos0);
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Mit freundlichen Grüßen',cPos0);
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Wir bitten Sie, die Ihnen freigestellte Menge innerhalb der lagergeldfreien Zeit von 14 Tagen abzuholen.',cPos0);
  PL_PrintLine;
  PL_Print('Danach berechnen wir Lagergeld in Höhe von 2€/to je angefangene KW an Sie.',cPos0);
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Diese VSB-Meldung gilt als Vertragsgemäße Lieferung. Gefahren und Risiken ',cPos0);
  PL_PrintLine;
  PL_Print('gehen mit dem heutigen Datum auf den Käufer über.',cPos0);
  PL_PrintLine;



// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================