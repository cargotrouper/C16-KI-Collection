@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_LFS_CMR
//                      OHNE E_R_G
//  Info
//    Druckt einen CMR Frachtbrief aus
//
//
//  04.08.2009  TM  Erstellung der Prozedur
//  03:08:2012  st  eRWEITERUNG. aRG dATEINAME FÜR AUTO dATEIERSTELLUNG
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


  // CMR Feldpositionen

  cPosLF  : 160.0   // CMR-/Lieferscheinnummer
  cPos01  :  25.0   // Absender
  cPos02  :  25.0   // Empfänger
  cPos03  :  25.0   // Auslieferungsort
  cPos04  :  25.0   // Übernahmeort / -datum
  cPos05  :  25.0   // Beigefügte Dokumente
  cPos55  :  50.0   // Beigefügte Dokumente2
  cPos65  :  75.0   // Beigefügte Dokumente2

  cPos06  :  25.0   // Positionsfeld 1 (Kommission bzw. Kundenbestellnr)
  cPos07  :  51.0   // Positionsfeld 2 (Anzahl Packstücke pro Kommission)
  cPos08  :  65.0   // Positionsfeld 3 (Stückzahl pro Kommission)
  cPos09  :  85.0   // Positionsfeld 4 (Abmessung L x B x D bzw. B x D)
  cPos10  : 120.0   // Positionsfeld 5 (Qualität)
  cPos11  : 158.0   // Positionsfeld 6 (Netto kg pro Kommission und Gesamtsumme)
  cPos12  : 181.0   // Positionsfeld 7 (Brutto kg pro Kommission und Gesamtsumme)

  cPos13  :  25.0   // Anweisungen d. Absenders
  cPos14  :  25.0   // Frachtzahlung frei/unfrei
  cPos15  : 124.0   // ** Rückerstattung (nicht gefüllt)
  cPos16  : 124.0   // Frachtführer
  cPos17  : 124.0   // Nachfolgende Frachtführer
  cPos18  : 124.0   // Bemerkungen Frachtführer
  cPos19  : 124.0   // Besondere Vereinbarungen
  cPos20  : 124.0   // ** Zu zahlen (nicht gefüllt)
  cPos21  :  25.0   // Ausfertigungsort
  cPos211 :  25.0   // Ausfertigungsdatum
  cPos22  :  25.0   // Unterschrift/Stempel Absender
  cPos23  :  93.0   // Unterschrift/Stempel Frachtführer
  cPos24  : 153.0   // Unterschrift/Stempel Empfänger

end;
local begin
  gTree     : int;
  gSortKey  : alpha(1000);
  gItem     : int;
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
  RecRead(440,1,0);

  RecLink(100,440,2,0);    // Zieladresse lesen
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
  Erx       : int;
  vAbsAnrede    : alpha;
  vAbsName      : alpha;
  vAbsZusatz    : alpha;
  vAbsStrasse   : alpha;
  vAbsPLZ       : alpha;
  vAbsOrt       : alpha;
  vAbsLKZ       : alpha;
  vAbsLand      : alpha;
  vSpedAnrede   : alpha;
  vSpedName     : alpha;
  vSpedZusatz   : alpha;
  vSpedStrasse  : alpha;
  vSpedPLZ      : alpha;
  vSpedOrt      : alpha;
  vSpedLKZ      : alpha;
  vSpedLand     : alpha;
  vZielAnrede   : alpha;
  vZielName     : alpha;
  vZielZusatz   : alpha;
  vZielStrasse  : alpha;
  vZielPLZ      : alpha;
  vZielOrt      : alpha;
  vZielLKZ      : alpha;
  vZielLand     : alpha;
  vAbhAnrede    : alpha;
  vAbhName      : alpha;
  vAbhZusatz    : alpha;
  vAbhStrasse   : alpha;
  vAbhPLZ       : alpha;
  vAbhOrt       : alpha;
  vAbhLand      : alpha;

end;
begin

  Erx # RecRead(440,1,0);
  Erx # RecLink(702,440,7,0);
  // Kopfdaten zusatmmenstellen
  // Absenderadresse lesen

  // Absender
  Adr.Nummer # Set.EigeneAdressnr;
  RecRead(100,1,0);                 // Adresse lesen
  RecLink(101,100,12,_recFirst);    // Anschrift lesen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;
  vAbsAnrede   # Adr.A.Anrede;
  vAbsName     # Adr.A.Name;
  vAbsZusatz   # Adr.A.Zusatz;
  vAbsStrasse  # "Adr.A.Straße";
  vAbsPLZ      # Adr.A.PLZ;
  vAbsOrt      # Adr.A.Ort;

  "Lnd.Kürzel" # Adr.A.Lkz;
  Erx # RecRead(812,1,0);
  If (Erx <= _rLocked) then vAbsLand # Lnd.Name.L1;

  // Frachtführer
  RecLink(100,702,7,_recFirst);     // Adresse lesen
  RecLink(101,100,12,_recFirst);    // Anschrift lesen;

  vSpedName     # Adr.A.Name;
  vSpedZusatz   # Adr.A.Zusatz;
  vSpedStrasse  # "Adr.A.Straße";
  vSpedPLZ      # Adr.A.PLZ;
  vSpedOrt      # Adr.A.Ort;

  "Lnd.Kürzel" # Adr.A.Lkz;
  Erx # RecRead(812,1,0);
  If (Erx <= _rLocked) then vZielLand # Lnd.Name.L1;

  // Ziel
  RecLink(100,702,12,_recFirst);    // Adresse lesen
  RecLink(101,702,13,_recFirst);    // Anschrift lesen

  RecLink(100,440,2,_recFirst);    // Adresse lesen
  RecLink(101,440,3,_recFirst);    // Anschrift lesen

  vZielName     # Adr.A.Name;
  vZielZusatz   # Adr.A.Zusatz;
  vZielStrasse  # "Adr.A.Straße";
  vZielPLZ      # Adr.A.PLZ;
  vZielOrt      # Adr.A.Ort;

  "Lnd.Kürzel" # Adr.A.Lkz;
  Erx # RecRead(812,1,0);
  If (Erx <= _rLocked) then vZielLand # Lnd.Name.L1;

  debug('ZielOrt : ' +vZielName + ' ' + vZielZusatz + ' ' + vZielStrasse + ' ' + vZielPLZ + ' ' + vZielOrt + ' ' + vZielLand);



  // Abholort
  RecLink(100,200,5,_recFirst);    // Adresse lesen
  RecLink(101,200,6,_recFirst);    // Anschrift lesen
  vAbhAnrede   # Adr.A.Anrede;
  vAbhName     # Adr.A.Name;
  vAbhZusatz   # Adr.A.Zusatz;
  vAbhStrasse  # "Adr.A.Straße";
  vAbhPLZ      # Adr.A.PLZ;
  vAbhOrt      # Adr.A.Ort;



  "Lnd.Kürzel" # Adr.A.Lkz;
  Erx # RecRead(812,1,0);
  If (Erx <= _rLocked) then vAbhLand # Lnd.Name.L1;

  debug('AbholOrt: ' + vAbhName + ' ' + vAbhZusatz + ' ' + vAbhStrasse + ' ' + vAbhPLZ + ' ' + vAbhOrt + ' ' + vAbhLand);

  // Absender und CMR Nummer

  pls_Fontattr # 0;
  Pls_fontSize # 8;

  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  PL_Print(vAbsName     , cPos01);
  PL_Print(AInt(BAG.P.Nummer) + '/' + AInt(BAG.P.Position) , cPosLf);
  PL_PrintLine;

  PL_Print(vAbsZusatz   , cPos01);
  PL_PrintLine;

  PL_Print(vAbsStrasse , cPos01);
  PL_PrintLine;

  PL_Print(StrAdj(vAbsLKZ + ' ' + vAbsPLZ + ' ' + vAbsOrt,_StrBegin), cPos01);
  PL_PrintLine;

  // Empfänger und Frachtführer

  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 8;
  PL_Print(vZielAnrede    , cPos02);
  PL_Print(vSpedAnrede    , cPos16);
  PL_PrintLine;

  PL_Print(vZielName      , cPos02);
  PL_Print(vSpedName      , cPos16);
  PL_PrintLine;

  PL_Print(vZielZusatz     , cPos02);
  PL_Print(vSpedZusatz    , cPos16);
  PL_PrintLine;

  PL_Print(vZielStrasse   , cPos02);
  PL_Print(vSpedStrasse   , cPos16);
  PL_PrintLine;

  PL_Print(StrAdj(vZielLKZ + ' ' + vZielPLZ + ' ' + vZielOrt,_StrBegin), cPos02);
  PL_Print(StrAdj(vSpedLKZ + ' ' + vSpedPLZ + ' ' + vSpedOrt,_StrBegin), cPos16);
  PL_PrintLine;

  // Auslieferungsort und -land
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  // Zielanschrift !!!
  PL_Print(vZielOrt + '   ' + vZielLand , cPos03);
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  // Zielanschrift !!!

  PL_Print(vAbhOrt + '   ' + vAbhLand + '   ' + cnvad(TODAY), cPos04);

  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  PL_Print('Lfs ' + cnvai(Lfs.Nummer,_FmtNumNoGroup)    , cPos05);
  PL_Print(''     , cPos55);
  PL_Print(''     , cPos65);
  PL_PrintLine;

  PL_Print(''     , cPos05);
  PL_Print(''     , cPos55);
  PL_Print(''     , cPos65);
  PL_PrintLine;

  PL_Print(''     , cPos05);
  PL_Print(''     , cPos55);
  PL_Print(''     , cPos65);
  PL_PrintLine;

  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  PL_Print('Kommission' , cPos06);
  PL_Print('Packst.'    , cPos07);
  PL_Print('Stückzahl'  , cPos08);
  PL_Print('Abmessung'  , cPos09);
  PL_Print('Qualität'   , cPos10);
  PL_Print('Gewicht'    , cPos11);
  PL_PrintLine;

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
  vKommission         : alpha;      // Kontrollvariable für Ausgabe
  vPosKommission      : alpha;
  vPosBestellung      : alpha;
  vPosAnzahl          : int;
  vPosStueck          : int;
  vPosLaenge          : alpha;
  vPosBreite          : alpha;
  vPosDicke           : alpha;
  vPosGuete           : alpha;
  vPosGewichtN        : float;
  vPosGewichtB        : float;
  vAbhlOrt            : alpha;
  vAbhlDat            : alpha;
  vAbsAnrede          : alpha;
  vAbsName            : alpha;
  vAbsZusatz          : alpha;
  vAbsStrasse         : alpha;
  vAbsLKZ             : alpha;
  vAbsPLZ             : alpha;
  vAbsOrt             : alpha;
  vLines              : int;
  // CMR spezifische Seitenränder
  vRandOben           : int;
  vRandUnten          : int;
  vLinemax            : int;
  vLoop               : int;
  vMatVorher          : int;
end;
begin

  vRandOben   # Set.Druck.Rand.Oben;
  vRandUnten  # Set.Druck.Rand.Unten;

  Set.Druck.Rand.Oben   # 0;
  Set.Druck.Rand.Unten  # 0;

  // ------ Druck vorbereiten ----------------------------------------------------------------

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,n,n) < 0) then begin
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
  Erx # (RecLink(441,440,4,vFlag));
  If Erx <= _rLocked then
  vKommission # Lfs.P.Kommission;

  // Titel fett mit Underline!!
  PL_Print('Artikel'    ,cPos06);
  PL_Print(''           ,cPos07);
  PL_Print(''           ,cPos08);
  PL_Print(''           ,cPos09);
  PL_Print(''           ,cPos10);
  PL_Print_R('Netto kg' ,cPos11);
  PL_Print_R('Brutto kg',cPos12);
  PL_PrintLine;

  gTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  Erx # RecLink(702,440,7,0);
  Erx # RecLink(701,702,2, _recFirst);

  WHILE (Erx <= _rLocked) DO BEGIN
    gSortKey # cnvAI(BAG.IO.Lageradresse, _FmtNumNoGroup |  _FmtNumLeadZero,0,10) + cnvAI(BAG.IO.Lageranschr, _FmtNumNoGroup |  _FmtNumLeadZero,0,10);
    Sort_ItemAdd(gTree,gSortKey,701,RecInfo(701,_RecId));

    Erx # RecLink(702,440,7,_recNext);
    If (Erx <= _rLocked) then
    Erx # RecLink(701,702,2, _recNext);

  END;

  vLines # 0;
  FOR   gItem # Sort_ItemFirst(gTree)
  loop  gItem # Sort_ItemNext(gTree,gItem)
  WHILE (gItem != 0) do begin
    vLoop # vLoop +1;

    If vLines < 22 then BEGIN

      // -------------Material liefern---------------
      if (Lfs.P.Materialtyp = c_IO_Mat) then begin
        debug('MATERIAL IO');
        // Materialkarte lesen

        Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
        If (Mat.Nummer <> vMatVorher) then begin

          Erx # RecLink(441,701,13,_RecFirst);  // Lfs.Position holen
          if(Erx > _rLocked) then
            RecBufClear(441);

          If (vKommission = '') then vKommission # Mat.Kommission;

          // Pro Kommission werden Druckdaten gemerkt und Stück, Gewichte und Packstücke aufaddiert
          If (Mat.Kommission = vKommission) then begin
            vPosKommission  # Lfs.P.Kommission;
            vPosBestellung  # Auf.P.Best.Nummer;
            vPosAnzahl      # vPosAnzahl +1;
            vPosStueck      # vPosStueck + Mat.bestand.Stk;

            If "Mat.Länge" >0.0 then
              vPosLaenge    # ANum("Mat.Länge","Set.Stellen.Länge");

            vPosBreite      # ANum(Mat.Breite,Set.Stellen.Breite);
            vPosDicke       # ANum(Mat.Dicke,Set.Stellen.Dicke);
            vPosGuete       # "Mat.Güte" + '/' + "Mat.Gütenstufe";
            vPosGewichtN    # vPosGewichtN + Mat.Gewicht.Netto;
            vPosGewichtB    # vPosGewichtB + Mat.Gewicht.Brutto;
            vMatVorher # Mat.Nummer;
            CYCLE;

          End;

        End;
      end else
      // -----------VSB-------------

      if (BAG.IO.Materialtyp = c_IO_VSB) then begin
        Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

        If (Mat.Nummer <> vMatVorher) then begin

          Erx # RecLink(441,701,13,_RecFirst);  // Lfs.Position holen
          if(Erx > _rLocked) then
            RecBufClear(441);

          // Materialkarte lesen

          Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

          Erx # RecLink(441,701,13,_RecFirst);  // Lfs.Position holen
          if(Erx > _rLocked) then
            RecBufClear(441);
          If (vKommission = '') then vKommission # Mat.Kommission;
          /// Pro Kommission werden Druckdaten gemerkt und Stück, Gewichte und Packstücke aufaddiert

          If (Mat.Kommission = vKommission) then begin
            vPosKommission  # Lfs.P.Kommission;
            vPosBestellung  # Auf.P.Best.Nummer;
            vPosAnzahl      # vPosAnzahl +1;
            vPosStueck      # vPosStueck + Mat.Bestand.Stk;

            If "Mat.Länge" >0.0 then
              vPosLaenge    # ANum("Mat.Länge","Set.Stellen.Länge");

            vPosBreite      # ANum(Mat.Breite,Set.Stellen.Breite);
            vPosDicke       # ANum(Mat.Dicke,Set.Stellen.Dicke);
            vPosGuete       # "Mat.Güte" + '/' + "Mat.Gütenstufe";
            vPosGewichtN    # vPosGewichtN + Mat.Gewicht.Netto;
            vPosGewichtB    # vPosGewichtB + Mat.Gewicht.Brutto;
            vMatVorher # Mat.Nummer;
            CYCLE;

          End;

        End;

        If (vPosGewichtN <> 0.0 ) or (vPosGewichtB <> 0.0 ) then begin

          PL_Print(vPosKommission,cPos05);
          PL_Print(AInt(vPosAnzahl),cPos07);
          PL_Print(AInt(vPosStueck),cPos08);
          If (vPosLaenge > '') then
            PL_Print(vPosDicke + ' x ' + vPosBreite + ' x ' + vPosLaenge  ,cPos09);
          Else
            PL_Print(vPosDicke + ' x ' + vPosBreite   ,cPos09);

          PL_Print(vPosGuete ,cPos10);

          PL_Print_R(ANum(vPosGewichtN,0) ,cPos11);
          PL_Print_R(ANum(vPosGewichtB,0) ,cPos12);
          PL_PrintLine;

          PL_Print(vPosBestellung,cPos06);
          PL_PrintLine;

          // Summierung
          vGesamtStueck   #  vGesamtStueck   + vPosStueck;
          vGesamtGewichtN #  vGesamtGewichtN + vPosGewichtN;
          vGesamtGewichtB #  vGesamtGewichtB + vPosGewichtB;
          vPosGewichtN # 0.0;
          vPosGewichtB # 0.0;
        End;

        end else begin

          PL_PrintLine;
          PL_PrintLine;

        end;

        vLines # vLines +2;

    END;

  END;

  PL_Print(vPosKommission,cPos05);
  PL_Print(AInt(vPosAnzahl),cPos07);
  PL_Print(AInt(vPosStueck),cPos08);
  If (vPosLaenge > '') then
    PL_Print(vPosDicke + ' x ' + vPosBreite + ' x ' + vPosLaenge  ,cPos09);
  Else
    PL_Print(vPosDicke + ' x ' + vPosBreite   ,cPos09);

  PL_Print(vPosGuete ,cPos10);

  PL_Print_R(ANum(vPosGewichtN,0) ,cPos11);
  PL_Print_R(ANum(vPosGewichtB,0) ,cPos12);
  PL_PrintLine;

  PL_Print(vPosBestellung,cPos06);
  PL_PrintLine;

  // Summierung
  vGesamtStueck   #  vGesamtStueck   + vPosStueck;
  vGesamtGewichtN #  vGesamtGewichtN + vPosGewichtN;
  vGesamtGewichtB #  vGesamtGewichtB + vPosGewichtB;
  vPosGewichtN # 0.0;
  vPosGewichtB # 0.0;

  // ------- FUßDATEN ------------------------------------------------------------------------

  form_Mode # 'FUSS';
  lib_Print:Print_LinieEinzeln();
  pls_Fontattr # 0;

  // Summen ausgeben
  pL_Print('Gesamt:',cPos09);
  pL_Print_R(CnvAi(vGesamtStueck,_FmtNumNoZero | _FmtNumNoGroup),cPos10); // Stückzahl
  pL_Printf(vGesamtGewichtB,0,cPos11);                                    // Gewicht Brutto
  pL_Printf(vGesamtGewichtN,0,cPos12);                                    // Gewicht Netto
  pL_Printline;  PL_Printline;  PL_Printline;

  pL_Printline;
  pL_PrintLine;

  // Lib_Print:Print_LinieDoppelt();

  vFusstexttyp # 0; // deaktiviert, muss auf Anfrage angepasst

  PL_PrintLine; // 10x

  // PL_Print(LiB.Bezeichnung.L1,cPos14);
  PL_Print('Lieferbedingung',cPos14);
  PL_PrintLine;

  fOR   vLinemax # 1
  loop  vLinemax # 23
  wHILE vLinemax <=22 DO PL_PrintLine;

  pL_Print(vAbhlOrt,cPos21);
  pL_Print(vAbhlDat,cPos211);
  pL_PrintLine;
  pL_PrintLine;

  // "Stempel" des Absenders
  pls_Fontattr # 0;
  pls_fontSize # 8;

  // Absender
  Adr.Nummer # Set.EigeneAdressnr;
  RecRead(100,1,0);                 // Adresse lesen
  RecLink(101,100,12,_recFirst);    // Anschrift lesen
  vAbsAnrede   # Adr.A.Anrede;
  vAbsName     # Adr.A.Name;
  vAbsZusatz   # Adr.A.Zusatz;
  vAbsStrasse  # "Adr.A.Straße";
  vAbsLKZ      # Adr.A.LKZ;
  vAbsPLZ      # Adr.A.PLZ;
  vAbsOrt      # Adr.A.Ort;

  PL_Print(vAbsName     , cPos01);
  PL_PrintLine;

  PL_Print(vAbsZusatz   , cPos01);
  PL_PrintLine;

  PL_Print(vAbsStrasse , cPos01);
  PL_PrintLine;

  PL_Print(StrAdj(vAbsLKZ + ' ' + vAbsPLZ + ' ' + vAbsOrt,_StrBegin), cPos01);
  PL_PrintLine;

  // -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();


  Set.Druck.Rand.Oben   # vRandOben;
  Set.Druck.Rand.Unten  # vRandUnten;

end;

//========================================================================