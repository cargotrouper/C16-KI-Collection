@A+
//===== Business-Control ================================================2
//
//  Prozedur    F_STD_BAG_LKA
//                  OHNE E_R_G
//  Info
//    Druckt einen Lohnkantenauftrag aus
//
//
//  17.10.2006  AI  Erstellung der Prozedur
//  17.07.2007  ST  Designumstellung
//  25.03.2008  MS  Anpassung fuer die Lohnkantenbearbeitungsauftrag
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
@I:Def_Rights
@I:Def_BAG

define begin
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cPos0   :  10.0   // Linker Rand

  // Einsatzmaterial
  cE_Pos1   :  25.0   // Material               r
  cE_Pos2   :  35.0   // Abmessung & Qualität   l
  cE_Pos3   :  77.0   // Coil-/Tafelnummer      l
  cE_Pos6   : 145.0   // Rid          r
  cE_Pos7   : 153.0   // Tlg          r
  cE_Pos8   : 165.0   // Stückzahl    r
  cE_Pos9   : 182.0   // Netto KG     r

  // Fertigung
  cF_Pos1   :  20.0   // Pos          r
  cF_Pos2   :  35.0   // Anzahl       r
  cF_Pos3   :  55.0   // Breite       r
  cF_Pos4   :  60.0   // Br Toleranz  l
  cF_Pos5   : 105.0   // Länge        r
  cF_Pos6   : 110.0   // Lg Toleranz  l
  cF_Pos7   : 145.0   // VPG          r
  cF_Pos8   : 165.0   // Stückzahl    r
  cF_Pos9   : 182.0   // Netto Kg     r

  // Verpackung
  cV_Pos1   :  15.0   // Pos          r
  cV_Pos2   :  20.0   // Beschreibung l


  // Kopfdaten
  cPosKopf1 : 120.0
  cPosKopf2 : 155.0

  // Fussdaten
  cFD_Pos1  : 35.0    // Beschreibung


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
  RecLink(100,702,7,_recFirst);    // Lohnbetrieb lesen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Bag.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)+'.'+CnvAI(Bag.P.Position,_FmtNumNoGroup | _FmtNumLeadZero,0,3);      // Dokumentennummer
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
      RecLink(100,702,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,702,13,_recFirst);   // Lieferanschrift holen
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
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin
      RETURN;
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
  vTxtName  : alpha;
  vText     : alpha(250);
  vText2    : alpha(250);
end;
begin


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    RecLink(100,702,7,_recFirst);    // Lohnbetrieb lesen
    RecLink(101,100,12,_recFirst);   // erste Anschrift lesen
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
    PL_Print(StrAdj("Adr.A.LKZ" + ' ' + Adr.A.PLZ,_StrBegin) + ' ' + Adr.A.Ort , cPos0);
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
    PL_Print('Lohnkantenbearbeitungsauftrag'+' '+AInt(Bag.P.Nummer)+ '/' + AInt(Bag.P.Position)   ,cPos0 );
    pl_PrintLine;

    pls_Fontattr # _WinFontAttrNormal;

    if(BAG.P.Aktion2<>'')then begin
      RecLink(828,702,8,0)
      PL_Print(ArG.Bezeichnung,cPos0);
      pl_PrintLine;
    end;

    Pls_FontSize # 9;
    pls_Fontattr # 0;
    PL_PrintLine;

    // Kopftext drucken
    vTxtName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K';
    Lib_Print:Print_Text(vTxtName,1, cPos0);
    PL_PrintLine;

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
    PL_Print('Lohnkantenbearbeitungsauftrag'+' '+AInt(Bag.P.Nummer)+ '/' + AInt(Bag.P.Position)   ,cPos0 );
    pl_PrintLine;

    pls_Fontattr # _WinFontAttrNormal;

    if(BAG.P.Aktion2<>'')then begin
      RecLink(828,702,8,0)
      PL_Print(ArG.Bezeichnung,cPos0);
      pl_PrintLine;
    end;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

  end;

  if (Form_Mode = 'EINSATZ') then begin
    pls_FontSize  # 9;
    pls_Fontattr # _WinFontAttrBold;
    PL_Print('Einsatzmaterial',cPos0);
    PL_PrintLine;
    pls_Fontattr # 0;

    pls_Inverted  # Y;
    PL_Print_R( 'Mat.Nr.'       ,cE_Pos1);
    PL_Print(   'Abmessung / Qualität',cE_Pos2);
    PL_Print(   'Coil-/Tafelnr.'    ,cE_Pos3);
    PL_Print_R( 'Stück'         ,cE_Pos8);
    PL_Print_R( 'Gewicht'      ,cE_Pos9);
    PL_Drawbox(cPos0-1.0,cE_Pos9+1.0,_WinColblack, 4.5);
    PL_PrintLine;
    pls_Fontattr # 0;
    pls_Inverted  # N;
  end;

  if (Form_Mode = 'FERTIGUNG') then begin
    pls_FontSize  # 9;
    pls_FontAttr # _WinFontAttrBold;
    PL_Print('Einteilung',cPos0);
    PL_PrintLine;
    pls_FontAttr # 0;

    pls_Inverted  # Y;
    PL_Print_R( 'Anz'         ,cF_Pos1);
    PL_Print(   'Abmessung',cF_Pos2);
    PL_Print_R( 'Stück'      ,cF_Pos8);
    PL_Print_R( 'Gewicht'    ,cF_Pos9);
    PL_Drawbox(cPos0-1.0,cE_Pos8+1.0,_WinColblack, 4.5);
    PL_PrintLine;
    pls_Fontattr # 0;
    pls_Inverted  # N;
  end;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vText               : alpha(1000);
  vTxtName            : alpha;

  vVerp               : alpha(1000);
  vMerker             : alpha(1000);


  vPos                : int;        // Druckpositionszähler

  vGesamtStueck       : int;        // Summen
  vGesamtGewichtN     : float;
  vGesamtGewichtB     : float;
  vGesamtBreite       : float;
  vBreite             : float;

  vVpg                : alpha;      // benutzte Verpackungen
  vI                   : int;        // Zähler für Verpackungsdruck
  vLoop               : int;        // Anzahl der Verpackungsloops

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
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------

  Form_Mode # 'EINSATZ';            // Einsatzkop drucken
  Lib_Print:Print_Seitenkopf();

  Pls_fontSize # 9;
  Pls_fontAttr # 0;

// ------- EINSATZMATERIAL -----------------------------------------------------------------
  vFlag # _RecFirst;
  vPos # 0;
  vGesamtStueck       # 0;
  vGesamtGewichtN     # 0.0;
  vGesamtGewichtB     # 0.0;

  WHILE (RecLink(701,702,2,vFlag) <> _rNoRec) DO BEGIN
    vFlag # _RecNext;
    vPos # vPos + 1;

    // Leerzeile zwischen den Positionen
    if (vPos>1) then PL_PrintLine;

    // Material lesen
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
      end
    else begin
      RecbufClear(200);
    end;


    // Materialnr
    if (Mat.Nummer > 0) then
      PL_PrintI(Mat.Nummer,cE_Pos1);


    // Abmessung
    vText # ANum(BAG.IO.Dicke,Set.Stellen.Dicke) + ' x ' +
            ANum(BAG.IO.Breite,Set.Stellen.Breite);
    if ("BAG.IO.Länge" <> 0.0) then
      vText # vText + ' x ' +
                   ANum("BAG.IO.Länge","Set.Stellen.Länge");
    PL_Print(vText,cE_Pos2);


    // Coilnummer
    PL_Print(Mat.Coilnummer,cE_Pos3);


    // Stk
    PL_PrintI(BAG.IO.Plan.In.Stk,cE_Pos8);

    // Gewicht
    PL_PrintF(BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht, cE_Pos9);

    PL_Printline;


    // Qualität
    vText # StrAdj("BAG.IO.Güte",_StrEnd);
    if ("Mat.Gütenstufe" <> '') then
      vText # vText +  ' / ' +
                  StrAdj("Mat.Gütenstufe",_StrEnd);
    PL_Print(vText,cE_Pos2);

    PL_Print(Mat.Ringnummer,cE_Pos3);
    PL_Printline;

    // Summierung
    vGesamtStueck       # vGesamtStueck   + BAG.IO.Plan.In.Stk;
    vGesamtGewichtN     # vGesamtGewichtN + BAG.IO.Plan.In.GewN;

  END;

  // Summen drucken
  Lib_Print:Print_LinieEinzeln();
  pls_Fontattr # _WinFontAttrBold;
  PL_PrintI(vGesamtStueck,cE_Pos8);
  PL_PrintF(vGesamtGewichtN,Set.Stellen.Gewicht,cE_Pos9);
  PL_Printline;
  pls_Fontattr # 0;
  PL_Printline;

// ------- FERTIGUNGEN ---------------------------------------------------------------------

  // Fertigungskopf ausgeben und Modusfür Seitenwechsel
  Form_Mode # 'FERTIGUNG';

  pls_FontSize  # 9;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print('Fertigung',cPos0);
  PL_PrintLine;

  pls_FontAttr # 0;
  pls_Inverted  # y;
  PL_Print_R( 'Anz'         ,cF_Pos1);
  PL_Print('Abmessung'  ,cF_Pos2);
  PL_Print_R( 'Stück'      ,cF_Pos8);
  PL_Print_R( 'Gewicht'    ,cF_Pos9);
  PL_Drawbox(cPos0-1.0,cE_Pos9+1.0,_WinColblack, 4.5);
  PL_PrintLine;
  pls_Fontattr # 0;
  pls_Inverted # N;

  vGesamtStueck       # 0;
  vGesamtGewichtN     # 0.0;
  vPos                # 0;
  vFlag # _RecFirst;
  WHILE (RecLink(703,702,4,vFlag) <> _rNoRec) DO BEGIN
    vFlag # _RecNext;

    vPos # vPos + 1;

    // Leerzeile zwischen den Positionen
    if (vPos>1) then PL_PrintLine;

    // Position
    PL_PrintI(vPos,cF_Pos1);
    /*
    // Oben/Vorderseite
    if (BAG.F.AusfOben <> '') then begin
        //Kürzel nach Bezeichnung auflösen
        vFlag # _RecFirst;
        WHILE (RecLink(705,703,8,vFlag) <= _rLocked ) DO BEGIN
          vFlag # _RecNext;
          if (BAG.AF.Seite = '1') then begin
            if (vVerp = '') then
              vVerp #  BAG.AF.Bezeichnung;
            else
              vVerp # vVerp + ' , ' + BAG.AF.Bezeichnung;
          end;
        END;
        PL_Print(vVerp,cF_Pos2);
    end;
    */

    // Abmessung
    vText # ANum(BAG.F.Dicke,Set.Stellen.Dicke) + ' x ' +
            ANum(BAG.F.Breite,Set.Stellen.Breite);
    if ("BAG.IO.Länge" <> 0.0) then
      vText # vText + ' x ' +
                   ANum("BAG.F.Länge","Set.Stellen.Länge");
    PL_Print(vText,cF_Pos2);

    // Stückzahl
    PL_PrintI("BAG.F.Stückzahl",cF_Pos8);

    // Gewicht
    PL_PrintF(BAG.F.Gewicht,0,cF_Pos9);

    PL_PrintLine;

    // Unten/Rückseite
    if (BAG.F.AusfUnten <> '') then begin
      //Kürzel nach Bezeichnung auflösen
      Erx # RecLink(705,703,8,_recFirst);
      WHILE (Erx <= _rLocked ) DO BEGIN
        vFlag # _RecNext;
        if(BAG.AF.Seite = '2') then
          if(vMerker='')then
            vMerker # BAG.AF.Bezeichnung;
          else
            vMerker # vMerker + ' , ' + BAG.AF.Bezeichnung;
        Erx # RecLink(705,703,8,_recNext);
      END;

      PL_Print(vMerker,cF_Pos2);
      PL_PrintLine;
    end;


    // Summierung
    vGesamtStueck       # vGesamtStueck   + "BAG.F.Stückzahl";
    vGesamtGewichtN     # vGesamtGewichtN + BAG.F.Gewicht;
  END;

  // ---------------------------------
  // Summen drucken
  Lib_Print:Print_LinieEinzeln();
  pls_Fontattr # _WinFontAttrBold;

  //GEsamtstückzahl
  PL_PrintI(vGesamtStueck,cF_Pos8);

  // Gesamtgewicht
  PL_PrintF(vGesamtGewichtN,Set.Stellen.Gewicht,cF_Pos9);
  PL_Printline;
  pls_Fontattr # 0;
  PL_Printline;


  PL_PrintLine;   // Leerzeile






// ------- FUßDATEN --------------------------------------------------------------------------
  form_Mode # 'FUSS';

  pls_Fontattr # 0;

  // Fusstext drucken
  vTxtName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
  Lib_Print:Print_Text(vTxtName,1, cPos0);


  // Starttermin
  vText # '';
  if (BAG.P.Plan.StartDat<>0.0.0) then begin
    vText # cnvad(BAG.P.Plan.StartDat);
    if (BAG.P.Plan.StartZeit<>0:0) then
      vText # vText + ' um '+cnvat(BAG.P.Plan.StartZeit);
    vText # vText + ' '+BAG.P.Plan.StartInfo;
  end;
  if (vText<>'') then begin
    PL_Print('Anlieferung: ',cPos0);
    PL_Print(vText,cFD_Pos1);
    PL_PrintLine;
  end;

  // Endtermin
  vText # '';
  if (BAG.P.Plan.EndDat<>0.0.0) then begin
    vText # cnvad(BAG.P.Plan.EndDat);
    if (BAG.P.Plan.EndZeit<>0:0) then
      vText # vText + ' um '+cnvat(BAG.P.Plan.EndZeit);
    vText # vText + ' '+BAG.P.Plan.EndInfo;
  end;
  if (vText<>'') then begin
    PL_Print('Fertigstellung: ',cPos0);
    PL_Print(vText,cFD_Pos1);
    PL_PrintLine;
  end;


  vText # '';
  // Kosten nur ausgeben, wenn diese angegeben sind
  if (BAG.P.Kosten.Fix <> 0.0) or (BAG.P.Kosten.Pro <> 0.0)  then begin
    PL_Print('Preis: ',cPos0);

    if (BAG.P.Kosten.Fix <> 0.0) then begin
      // Währung lesen
      Wae.Nummer # Bag.P.Kosten.Wae;
      if (RecRead(814,702,_RecFirst) = _rNoRec) then RecBufClear(814);
      vText  #  'Pauschal ' + ANum(BAG.P.Kosten.Fix,2) +' '  +  "Wae.Kürzel";
    end;

    if (BAG.P.Kosten.Pro <> 0.0) then begin
      // Währung lesen
      Wae.Nummer # Bag.P.Kosten.Wae;

      if (RecRead(814,1,_RecFirst) = _rNoRec) then RecBufClear(814);

      if (vText = '') then
        vText # ANum(BAG.P.Kosten.Pro,2) + ' ' +  "Wae.Kürzel" + ' pro ' +
                AInt(Bag.P.Kosten.PEH) + ' ' + Bag.P.Kosten.MEH;
      else
        vText # vText + ', ' +
                ANum(BAG.P.Kosten.Pro,2) + ' ' +  "Wae.Kürzel" + ' pro ' +
                AInt(Bag.P.Kosten.PEH) + ' ' + Bag.P.Kosten.MEH;
    end;

    if (vText <> '') then begin
      PL_Print(vText,cFD_Pos1);
      PL_PrintLine;
    end;
  end;

  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Mit freundlichen Grüßen',cPos0);
  PL_PrintLine;
  PL_Print(Set.mfg.Text,cPos0);
  PL_PrintLine;


  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden -----------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================