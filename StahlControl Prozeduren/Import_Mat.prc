@A+
//==== Business-Control ==================================================
//
//  Prozedur    Import_Mat
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2008  MS  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB Import_SC5();
//    SUB Import_CMC_C();
//    SUB Import_TSR();
//    SUB Import_FLK();
//    SUB Import_MTD()
//    SUB Import_OWF()
//    SUB Import_FMB()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  GetAlphaMAX(a,b)  : StrCut(FldAlphabyName('X_'+a),1,b)
  GetAlpha(a)       : FldAlphabyName('X_'+a);
  GetWord(a)        : FldWordbyName('X_'+a)
  GetInt(a)         : FldIntbyName('X_'+a);
  GetNum(a,b)       : Rnd(FldFloatbyName('X_'+a),b)
  GetDate(a)        : FldDatebyName('X_'+a);
  GetTime(a)        : FldTimebyName('X_'+a);

  xGetAlphaUp(a,b)  : a # strcnv(FldAlphabyName('X_'+b),_StrUpper);
  xGetAlpha(a,b)    : a # FldAlphabyName('X_'+b);
  xGetInt(a,b)      : a # FldIntbyName('X_'+b);
  xGetWord(a,b)     : a # FldWordbyName('X_'+b);
  xGetNum(a,b)      : a # FldFloatbyName('X_'+b);
  GetBool(a,b)      : a # FldLogicbyName('X_'+b);
  xGetDate(a,b)     : a # FldDatebyName('X_'+b);
  xGetTime(a,b)     : a # FldTimebyName('X_'+b);
end;




//========================================================================
//  Import_SC5
//            LICHGITTER??
//  xGetAlphaUp
//  xGetAlpha
//  GetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime
//========================================================================
sub Import_SC5()
local begin
  Erx             : int;
  Ansprechpartner : int;
end;
begin

  Erx # RecRead(200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Mat.Bestellt.Gew<=0.0) or (Mat.Status<>500) then begin
      if (Mat_Data:Delete(_rnolock,'AUTO')<>_rOK) then TODO('ERROR');
      Erx # RecRead(200,1,0);
      Erx # RecRead(200,1,0);
      end
    else begin
      Erx # RecRead(200,1,_recNext);
    end;

  END;

RETURN;


  Erx # DBAConnect(2,'X_','TCP:192.168.196.3','StahlControl','thomas','ares','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(200);
    RecBufClear(240);

    xGetWord(Mat.Status,'Mat.Status');
    xGetAlpha("Mat.Löschmarker",'Mat.Löschmarker');

    Mat.Lageranschrift # 1;
    "Mat.Vorgänger"    # 0;

    xGetWord(GV.Ints.01,'Mat.Oberfläche');    //Mat.AusführungOben

    case (GV.Ints.01) of
      1 : "Mat.AusführungOben"  # 'ungebeizt';
      3 : "Mat.AusführungOben"  # 'gebeizt , gefettet';
      2 : "Mat.AusführungOben"  # 'gebeizt , ungefettet';
      /**/
      4 : "Mat.AusführungOben"  # 'kaltgewalzt-gefettet';
      5 : "Mat.AusführungOben"  # 'kaltgewalzt-ungefettet';
      6 : "Mat.AusführungOben"  # 'verzinkt';
      7 : "Mat.AusführungOben"  # 'Aluminium';
      8 : "Mat.AusführungOben"  # 'Edelstahl';
      9 : "Mat.AusführungOben"  # 'sonstige';
      /**/
    end;


    xGetAlpha(GV.Alpha.48,'Mat.Ursprungsland');

    case GV.Alpha.48 of
      'Deutschland'         : Mat.Ursprungsland # 'D';
      'Italien'             : Mat.Ursprungsland # 'I';
      'Österreich'          : Mat.Ursprungsland # 'A';
      'Belgien'             : Mat.Ursprungsland # 'B';
      'Brasilien'           : Mat.Ursprungsland # 'BR';
      'Schweiz'             : Mat.Ursprungsland # 'CH';
      'Tschechien'          : Mat.Ursprungsland # 'CH';
      'Dänemark'            : Mat.Ursprungsland # 'DK';
      'Spanien'             : Mat.Ursprungsland # 'ESP';
      'Frankreich'          : Mat.Ursprungsland # 'F';
      'Griechenland'        : Mat.Ursprungsland # 'GR';
      'Niederlande'         : Mat.Ursprungsland # 'NL';
      'Polen'               : Mat.Ursprungsland # 'PL';
      'Südafrika'           : Mat.Ursprungsland # 'RS';
      'Russland'            : Mat.Ursprungsland # 'RU';
      'Vereinigten Staaten' : Mat.Ursprungsland # 'US';
    end;


    xGetInt(GV.Int.02,'Mat.Lagerort');
    // Umsetzen Lieferantennr->Adressnummer
    Adr.Lieferantennr # GV.Int.02;
    RecRead(100,3,0);   // Lieferanten holen
    Mat.Lageradresse # Adr.Nummer;


    xGetInt(Mat.Nummer,'Mat.Nummer');
    xGetInt(Mat.Ursprung,'Mat.Nummer');
    xGetInt(Mat.Bestand.Stk,'Mat.Bestand.Stk');
    xGetInt(Mat.Bestellt.Stk,'Mat.Bestellt.Stk');
    xGetInt(Mat.Reserviert.Stk,'Mat.Reserviert.Stk');
    xGetInt("Mat.Verfügbar.Stk",'Mat.Verfügbar.Stk');
//    GetInt(Mat.Paketnr,'Mat.Paketnummer');
    xGetInt(Mat.Erzeuger,'Mat.Erzeuger');
    xGetInt(Mat.Lieferant,'Mat.Lieferant');
//    GetInt(Mat.Analysenummer,'Mat.Analysenummer');
    xGetAlpha("Mat.Güte",'Mat.Qualität');
    xGetAlpha(Mat.Werkstoffnr,'Mat.Werkstoffnummer');
    xGetAlpha(Mat.Coilnummer,'Mat.Coilnummer');
    xGetAlpha(Mat.Ringnummer,'Mat.Tafelnummer');
    xGetAlpha(Mat.Chargennummer,'Mat.Chargennummer');
    xGetAlpha(Mat.Werksnummer,'Mat.Werksnummer');
    xGetAlpha(Mat.DickenTol,'Mat.Dickentoleranz');
    xGetAlpha(Mat.BreitenTol,'Mat.Breitentoleranz');
    xGetAlpha("Mat.LängenTol",'Mat.Längentoleranz');
    xGetAlpha(Mat.Zeugnisart,'Mat.Zeugnisart');
    xGetAlpha(Mat.Zeugnisakte,'Mat.Zeugnisakte')
    //xGetAlpha(Mat.Kommission,'Mat.Kommission');;
    xGetAlpha(Mat.Bemerkung1,'Mat.Bemerkung1');
    xGetAlpha(Mat.Bemerkung2,'Mat.Bemerkung2');
    xGetAlpha(Mat.Bestellnummer,'Mat.Bestellnummer');
    xGetAlpha(Mat.BestellABNr,'Mat.LiefBestnr');
    xGetAlpha(Mat.Lagerplatz,'Mat.Lagerplatz');
    xGetNum(Mat.Dicke,'Mat.Dicke');
    xGetNum(Mat.Dicke.Von,'Mat.ZehnerprobeVon');
    xGetNum(Mat.Dicke.Bis,'Mat.ZehnerprobeBis');
    xGetNum(Mat.Breite,'Mat.Breite');
  //  GetNum(Mat.Breite.Von,'Mat.Breite2');
  //  GetNum(Mat.Breite.Bis,'Mat.Breite3');
    xGetNum("Mat.Länge",'Mat.Länge');
    xGetNum(Mat.RID,'Mat.Innendurchm');
    xGetNum(Mat.RAD,'Mat.Außendurchm');
    xGetNum(Mat.Dichte,'Mat.Dichte');
    xGetNum(Mat.Kgmm,'Mat.Kgmm');
    xGetNum(Mat.Bestand.Gew,'Mat.Bestand.Gew');
    xGetNum(Mat.Bestellt.Gew,'Mat.Bestellt.Gew');
    xGetNum(Mat.Reserviert.Gew,'Mat.Reserviert.Gew');
    xGetNum("Mat.Verfügbar.Gew",'Mat.Verfügbar.Gew');
    xGetNum(Mat.EK.Preis,'Mat.EK-effektiv');
    //GetNum(Mat.EK.Preis,'Mat.EK-Preis');
    //GetNum(Mat.Kosten,'Mat.VK-Preis');
    //GetNum(Mat.EK.Effektiv,'Mat.EK-effektiv');
    xGetNum(Mat.Gewicht.Netto,'Mat.Gewicht.Netto');
    xGetNum(Mat.Gewicht.Brutto,'Mat.Gewicht.Brutto');
    xGetDate("Mat.Übernahmedatum",'Mat.Übernahmedatum');
    xGetDate(Mat.Bestelldatum,'Mat.Bestelldatum');
    xGetDate(Mat.BestellTermin,'Mat.Termin');
    xGetDate(Mat.Eingangsdatum,'Mat.Eingangsdatum');
    xGetDate(Mat.Ausgangsdatum,'Mat.Ausgangsdatum');
    xGetDate(Mat.Inventurdatum,'Mat.Inventurdatum');
    xGetWord(Mat.Warengruppe,'Mat.Warengruppe');
    GetBool(Mat.EigenmaterialYN,'Mat.Eigenmaterial');

    //==============Analyse=====================================
    xGetAlpha(GV.Alpha.01,'Mat.Gem.Streckgrenze');
    xGetAlpha(GV.Alpha.02,'Mat.Gem.Festigkeit');
    xGetAlpha(GV.Alpha.03,'Mat.Gem.Dehnung1');
    xGetAlpha(GV.Alpha.04,'Mat.Gem.Dehnung2');
    xGetAlpha(GV.Alpha.05,'Mat.Gem.Wert01'); //C
    xGetAlpha(GV.Alpha.06,'Mat.Gem.Wert02'); //Si
    xGetAlpha(GV.Alpha.07,'Mat.Gem.Wert03'); //Mn
    xGetAlpha(GV.Alpha.08,'Mat.Gem.Wert04'); //P
    xGetAlpha(GV.Alpha.09,'Mat.Gem.Wert05'); //S
    xGetAlpha(GV.Alpha.10,'Mat.Gem.Wert06'); //Al
    xGetAlpha(GV.Alpha.11,'Mat.Gem.Wert07'); //Cr
    xGetAlpha(GV.Alpha.12,'Mat.Gem.Wert08'); //V
    xGetAlpha(GV.Alpha.13,'Mat.Gem.Wert09'); //Nb
    xGetAlpha(GV.Alpha.14,'Mat.Gem.Wert10'); //Ti
    xGetAlpha(GV.Alpha.15,'Mat.Gem.Wert11'); //N
    xGetAlpha(GV.Alpha.16,'Mat.Gem.Wert12'); //Cu
    xGetAlpha(GV.Alpha.17,'Mat.Gem.Wert13'); //Ni
    xGetAlpha(GV.Alpha.18,'Mat.Gem.Wert14'); //Mo
    xGetAlpha(GV.Alpha.19,'Mat.Gem.Wert15'); //W
    xGetAlpha(GV.Alpha.20,'Mat.Gem.Wert16'); //Pb
    xGetAlpha(GV.Alpha.21,'Mat.Att.Streckgrenze');
    xGetAlpha(GV.Alpha.22,'Mat.Att.Festigkeit');
    xGetAlpha(GV.Alpha.23,'Mat.Att.Dehnung1');
    xGetAlpha(GV.Alpha.24,'Mat.Att.Dehnung2');
    xGetAlpha(GV.Alpha.25,'Mat.Att.Wert01'); //C
    xGetAlpha(GV.Alpha.26,'Mat.Att.Wert02'); //Si
    xGetAlpha(GV.Alpha.27,'Mat.Att.Wert03'); //Mn
    xGetAlpha(GV.Alpha.28,'Mat.Att.Wert04'); //P
    xGetAlpha(GV.Alpha.29,'Mat.Att.Wert05'); //S
    xGetAlpha(GV.Alpha.30,'Mat.Att.Wert06'); //Al
    xGetAlpha(GV.Alpha.31,'Mat.Att.Wert07'); //Cr
    xGetAlpha(GV.Alpha.32,'Mat.Att.Wert08'); //V
    xGetAlpha(GV.Alpha.33,'Mat.Att.Wert09'); //Nb
    xGetAlpha(GV.Alpha.34,'Mat.Att.Wert10'); //Ti
    xGetAlpha(GV.Alpha.35,'Mat.Att.Wert11'); //N
    xGetAlpha(GV.Alpha.36,'Mat.Att.Wert12'); //Cu
    xGetAlpha(GV.Alpha.37,'Mat.Att.Wert13'); //Ni
    xGetAlpha(GV.Alpha.38,'Mat.Att.Wert14'); //Mo
    xGetAlpha(GV.Alpha.39,'Mat.Att.Wert15'); //W
    xGetAlpha(GV.Alpha.40,'Mat.Att.Wert16'); //Pb

    xGetAlpha(GV.Alpha.41,'Mat.Gem.Dehngrenze02');
    xGetAlpha(GV.Alpha.42,'Mat.Gem.Dehngrenze10');
    xGetAlpha(GV.Alpha.43,'Mat.Gem.Korngröße');

    xGetAlpha(GV.Alpha.45,'Mat.Att.Dehngrenze02');
    xGetAlpha(GV.Alpha.46,'Mat.Att.Dehngrenze10');
    xGetAlpha(GV.Alpha.47,'Mat.Att.Korngröße');


    // Format-Konvertierungen...
    Mat.Streckgrenze1     # CnvFA(Gv.Alpha.01);
    Mat.Zugfestigkeit1    # CnvFA(Gv.Alpha.02);
    Mat.DehnungA1         # CnvFA(Gv.Alpha.03);
    Mat.DehnungB1         # CnvFA(Gv.Alpha.04);

    Mat.Chemie.C1         # CnvFA(Gv.Alpha.05);
    Mat.Chemie.Si1        # CnvFA(Gv.Alpha.06);
    Mat.Chemie.Mn1        # CnvFA(Gv.Alpha.07);
    Mat.Chemie.P1         # CnvFA(Gv.Alpha.08);
    Mat.Chemie.S1         # CnvFA(Gv.Alpha.09);
    Mat.Chemie.Al1        # CnvFA(Gv.Alpha.10);
    Mat.Chemie.Cr1        # CnvFA(Gv.Alpha.11);
    Mat.Chemie.V1         # CnvFA(Gv.Alpha.12);
    Mat.Chemie.Nb1        # CnvFA(Gv.Alpha.13);
    Mat.Chemie.Ti1        # CnvFA(Gv.Alpha.14);
    Mat.Chemie.N1         # CnvFA(Gv.Alpha.15); // Co
    Mat.Chemie.Cu1        # CnvFA(Gv.Alpha.16);
    Mat.Chemie.Ni1        # CnvFA(Gv.Alpha.17);
    Mat.Chemie.Mo1        # CnvFA(Gv.Alpha.18);
    Mat.Chemie.B1         # CnvFA(Gv.Alpha.19); // W
    Mat.Chemie.Frei1.1    # CnvFA(Gv.Alpha.20); // Pb

    Mat.Streckgrenze2     # CnvFA(Gv.Alpha.21);
    Mat.Zugfestigkeit2    # CnvFA(Gv.Alpha.22);
    Mat.DehnungA2         # CnvFA(Gv.Alpha.23);
    Mat.DehnungB2         # CnvFA(Gv.Alpha.24);

    Mat.Chemie.C2         # CnvFA(Gv.Alpha.25);
    Mat.Chemie.Si2        # CnvFA(Gv.Alpha.26);
    Mat.Chemie.Mn2        # CnvFA(Gv.Alpha.27);
    Mat.Chemie.P2         # CnvFA(Gv.Alpha.28);
    Mat.Chemie.S2         # CnvFA(Gv.Alpha.29);
    Mat.Chemie.Al2        # CnvFA(Gv.Alpha.30);
    Mat.Chemie.Cr2        # CnvFA(Gv.Alpha.31);
    Mat.Chemie.V2         # CnvFA(Gv.Alpha.32);
    Mat.Chemie.Nb2        # CnvFA(Gv.Alpha.33);
    Mat.Chemie.Ti2        # CnvFA(Gv.Alpha.34);
    Mat.Chemie.N2         # CnvFA(Gv.Alpha.35); // Co
    Mat.Chemie.Cu2        # CnvFA(Gv.Alpha.36);
    Mat.Chemie.Ni2        # CnvFA(Gv.Alpha.37);
    Mat.Chemie.Mo2        # CnvFA(Gv.Alpha.38);
    Mat.Chemie.B2         # CnvFA(Gv.Alpha.39); // W
    Mat.Chemie.Frei1.2    # CnvFA(Gv.Alpha.40); // Pb

    Mat.RP02_V1           # CnvFA(Gv.Alpha.41);
    Mat.RP10_V1           # CnvFA(Gv.Alpha.42);
    "Mat.Körnung1"        # CnvFA(Gv.Alpha.43);

    Mat.RP02_B1           # CnvFA(Gv.Alpha.45);
    Mat.RP10_B1           # CnvFA(Gv.Alpha.46);
    "Mat.Körnung2"        # CnvFA(Gv.Alpha.47);
    //==========================================================

    //GetInt(Mat.KommKundennr,'');
    //xGetInt(Mat.VK.Kundennr,'');
    //xGetInt(Mat.VK.Rechnr,'');
    //xGetInt(Mat.EK.RechNr,'');
    //xGetInt(Mat.Auftragsnr,'');
    //xGetInt(Mat.Einkaufsnr,'');
    //xGetAlpha(Mat.Gütenstufe,'');
    //xGetAlpha(Mat.AusführungUnten,'');
    //xGetAlpha(Mat.Strukturnr,'');
    //xGetAlpha(Mat.Intrastatnr,'');
    //xGetAlpha(Mat.KommKundenSWort,'');
    //xGetAlpha(Mat.LieferStichwort,'');
    //xGetAlpha(Mat.LagerStichwort,'');
    //xGetAlpha(Mat.QS.User,'');
    //xGetAlpha(Mat.Zwischenlage,'');
    //xGetAlpha(Mat.Unterlage,'');
    //GetNum(Mat.DickenTol.Von,'');
    //GetNum(Mat.DickenTol.Bis,'');
    //GetNum(Mat.BreitenTol.Von,'');
    //GetNum(Mat.BreitenTol.Bis,'');
    //GetNum(Mat.Länge.Von,'');
    //GetNum(Mat.Länge.Bis,'');
    //GetNum(Mat.LängenTol.Von,'');
    //GetNum(Mat.LängenTol.Bis,'');
    //GetNum(Mat.VK.Preis,'');
    //GetNum(Mat.VK.Gewicht,'');
    //GetNum(Mat.Nettoabzug,'');
    //GetNum(Mat.Stapelhöhe,'');
    //GetNum(Mat.Stapelhöhenabzug,'');
    //GetNum(Mat.Rechtwinkligkeit,'');
    //GetNum(Mat.Ebenheit,'');
    //GetNum(Mat.Säbeligkeit,'');
    //GetNum(Mat.Etk.Dicke,'');
    //GetNum(Mat.Etk.Breite,'');
    //GetNum(Mat.Etk.Länge,'');
    //GetDate(Mat.QS.Datum,'');
    //GetDate(Mat.VK.Rechdatum,'');
    //GetDate(Mat.EK.RechDatum,'');
    //GetWord(Mat.Auftragspos,'');
    //GetWord(Mat.Einkaufspos,'');
    //GetWord(Mat.QS.Status,'');
    //GetWord(Mat.Verwiegungsart,'');
    //GetWord(Mat.AbbindungL,'');
    //GetWord(Mat.AbbindungQ,'');
    //GetBool(Mat.DickenTolYN,'');
    //GetBool(Mat.BreitenTolYN,'');
    //GetBool(Mat.LängenTolYN,'');
    //GetBool(Mat.StehendYN,'');
    //GetBool(Mat.LiegendYN,'');
    //GetTime(Mat.QS.Zeit,'');


  if ("Mat.Löschmarker"<>'*') and
    ((Mat.Status=1) or (Mat.Status=404)) then begin
    Erx # Mat_Data:Insert(0,'AUTO',today);
    //debug(cnvAI(Erx)+'   '+cnvAI(Mat.Nummer));
  end;


  Erx # RecRead(2200,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Material wurde importiert!',0,0,0);
end;


//========================================================================
//  Import_CMC_C
//
//  xGetAlphaUp
//  xGetAlpha
//  xGetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime
//========================================================================
sub Import_CMC_C()
local begin
  Erx : int;
  Ansprechpartner : int;
end;
begin
/*  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!CMC','thomas','','');*/
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    RecLink(2814,2200,2,0);
    //debug(GV.Alpha.52);
    RecBufClear(200);
    RecBufClear(240);

    xGetWord(Mat.Status,'Mat.Status');
    xGetAlpha("Mat.Löschmarker",'Mat.Löschmarker');

    Mat.Lageranschrift # 1;
    "Mat.Vorgänger"    # 0;


    xGetAlpha(GV.Alpha.48,'Mat.Ursprungsland');

    case GV.Alpha.48 of
      'Deutschland'         : Mat.Ursprungsland # 'D';
      'Italien'             : Mat.Ursprungsland # 'I';
      'Österreich'          : Mat.Ursprungsland # 'A';
      'Belgien'             : Mat.Ursprungsland # 'B';
      'Brasilien'           : Mat.Ursprungsland # 'BR';
      'Schweiz'             : Mat.Ursprungsland # 'CH';
      'Tschechien'          : Mat.Ursprungsland # 'CH';
      'Dänemark'            : Mat.Ursprungsland # 'DK';
      'Spanien'             : Mat.Ursprungsland # 'ESP';
      'Frankreich'          : Mat.Ursprungsland # 'F';
      'Griechenland'        : Mat.Ursprungsland # 'GR';
      'Niederlande'         : Mat.Ursprungsland # 'NL';
      'Polen'               : Mat.Ursprungsland # 'PL';
      'Südafrika'           : Mat.Ursprungsland # 'RS';
      'Russland'            : Mat.Ursprungsland # 'RU';
      'Vereinigten Staaten' : Mat.Ursprungsland # 'US';
    end;


    xGetInt(GV.Int.02,'Mat.Lagerort');
    // Umsetzen Lieferantennr->Adressnummer
    Adr.Lieferantennr # GV.Int.02;
    RecRead(100,3,0);   // Lieferanten holen
    Mat.Lageradresse # Adr.Nummer;


    xGetInt(Mat.Nummer,'Mat.Nummer');
    xGetInt(Mat.Ursprung,'Mat.Nummer');
    xGetInt(Mat.Bestand.Stk,'Mat.Bestand.Stk');
    xGetInt(Mat.Bestellt.Stk,'Mat.Bestellt.Stk');
    xGetInt(Mat.Reserviert.Stk,'Mat.Reserviert.Stk');
    xGetInt("Mat.Verfügbar.Stk",'Mat.Verfügbar.Stk');
//    xGetInt(Mat.Paketnr,'Mat.Paketnummer');
    xGetInt(Mat.Erzeuger,'Mat.Erzeuger');
    xGetInt(Mat.Lieferant,'Mat.Lieferant');
//    xGetInt(Mat.Analysenummer,'Mat.Analysenummer');
    xGetAlpha("Mat.Güte",'Mat.Qualität');
    xGetAlpha(Mat.Werkstoffnr,'Mat.Werkstoffnummer');
    xGetAlpha(Mat.Coilnummer,'Mat.Coilnummer');
    xGetAlpha(Mat.Ringnummer,'Mat.Tafelnummer');
    xGetAlpha(Mat.Chargennummer,'Mat.Chargennummer');
    xGetAlpha(Mat.Werksnummer,'Mat.Werksnummer');
    xGetAlpha(Mat.DickenTol,'Mat.Dickentoleranz');
    xGetAlpha(Mat.BreitenTol,'Mat.Breitentoleranz');
    xGetAlpha("Mat.LängenTol",'Mat.Längentoleranz');
    xGetAlpha(GV.Alpha.55,'Mat.Kommission');
    xGetAlpha(GV.Alpha.54,'Mat.Bezeichnung3');
    Mat.Strukturnr # StrCut(GV.Alpha.54,1,20);
    xGetAlpha(Mat.Zeugnisart,'Mat.Zeugnisart');
    xGetAlpha(Mat.Zeugnisakte,'Mat.Zeugnisakte');
    //xGetAlpha(Mat.Kommission,'Mat.Kommission');
    xGetAlpha(Mat.Bemerkung1,'Mat.Bemerkung1');
    xGetAlpha(Mat.Bemerkung2,'Mat.Bemerkung2');
    if (GV.Alpha.55 <> '') then
      Mat.Bemerkung2 # Mat.Bemerkung2 + ' Kom.: ' + StrCut(GV.Alpha.55,1,20);
    xGetAlpha(Mat.Bestellnummer,'Mat.Bestellnummer');
    xGetAlpha(Mat.BestellABNr,'Mat.LiefBestnr');
    xGetAlpha(Mat.Lagerplatz,'Mat.Lagerplatz');
    xGetNum(Mat.Dicke,'Mat.Dicke');
    xGetNum(Mat.Dicke.Von,'Mat.ZehnerprobeVon');
    xGetNum(Mat.Dicke.Bis,'Mat.ZehnerprobeBis');
    xGetNum(Mat.Breite,'Mat.Breite');
  //  GetNum(Mat.Breite.Von,'Mat.Breite2');
  //  GetNum(Mat.Breite.Bis,'Mat.Breite3');
    xGetNum("Mat.Länge",'Mat.Länge');
    xGetNum(Mat.RID,'Mat.Innendurchm');
    xGetNum(Mat.RAD,'Mat.Außendurchm');
    xGetNum(Mat.Dichte,'Mat.Dichte');
    xGetNum(Mat.Kgmm,'Mat.Kgmm');
    xGetNum(Mat.Bestand.Gew,'Mat.Bestand.Gew');
    xGetNum(Mat.Bestellt.Gew,'Mat.Bestellt.Gew');
    xGetNum(Mat.Reserviert.Gew,'Mat.Reserviert.Gew');
    xGetNum("Mat.Verfügbar.Gew",'Mat.Verfügbar.Gew');
    xGetNum(Mat.EK.Preis,'Mat.EK-effektiv');
    //GetNum(Mat.EK.Preis,'Mat.EK-Preis');
    //GetNum(Mat.Kosten,'Mat.VK-Preis');
    //GetNum(Mat.EK.Effektiv,'Mat.EK-effektiv');
    xGetNum(Mat.Gewicht.Netto,'Mat.Gewicht.Netto');
    xGetNum(Mat.Gewicht.Brutto,'Mat.Gewicht.Brutto');
    xGetDate("Mat.Übernahmedatum",'Mat.Übernahmedatum');
    xGetDate(Mat.Bestelldatum,'Mat.Bestelldatum');
    xGetDate(Mat.BestellTermin,'Mat.Termin');
    xGetDate(Mat.Eingangsdatum,'Mat.Eingangsdatum');
    xGetDate(Mat.Ausgangsdatum,'Mat.Ausgangsdatum');
    xGetDate(Mat.Inventurdatum,'Mat.Inventurdatum');
    xGetWord(Mat.Warengruppe,'Mat.Warengruppe');
    GetBool(Mat.EigenmaterialYN,'Mat.Eigenmaterial');

    //==============Analyse=====================================
    xGetAlpha(GV.Alpha.01,'Mat.Gem.Streckgrenze');
    xGetAlpha(GV.Alpha.02,'Mat.Gem.Festigkeit');
    xGetAlpha(GV.Alpha.03,'Mat.Gem.Dehnung1');
    xGetAlpha(GV.Alpha.04,'Mat.Gem.Dehnung2');
    xGetAlpha(GV.Alpha.05,'Mat.Gem.Wert01'); //C
    xGetAlpha(GV.Alpha.06,'Mat.Gem.Wert02'); //Si
    xGetAlpha(GV.Alpha.07,'Mat.Gem.Wert03'); //Mn
    xGetAlpha(GV.Alpha.08,'Mat.Gem.Wert04'); //P
    xGetAlpha(GV.Alpha.09,'Mat.Gem.Wert05'); //S
    xGetAlpha(GV.Alpha.10,'Mat.Gem.Wert07'); //Al
    xGetAlpha(GV.Alpha.11,'Mat.Gem.Wert08'); //Cr
    xGetAlpha(GV.Alpha.12,'Mat.Gem.Wert11'); //V
    xGetAlpha(GV.Alpha.13,'Mat.Gem.Wert13'); //Nb
    xGetAlpha(GV.Alpha.14,'Mat.Gem.Wert12'); //Ti
    xGetAlpha(GV.Alpha.15,'Mat.Gem.Wert14'); //N
    xGetAlpha(GV.Alpha.16,'Mat.Gem.Wert06'); //Cu
    xGetAlpha(GV.Alpha.17,'Mat.Gem.Wert10'); //Ni
    xGetAlpha(GV.Alpha.18,'Mat.Gem.Wert09'); //Mo
    xGetAlpha(GV.Alpha.19,'Mat.Gem.Wert15'); //W
    xGetAlpha(GV.Alpha.20,'Mat.Gem.Wert16'); //Pb
    xGetAlpha(GV.Alpha.21,'Mat.Att.Streckgrenze');
    xGetAlpha(GV.Alpha.22,'Mat.Att.Festigkeit');
    xGetAlpha(GV.Alpha.23,'Mat.Att.Dehnung1');
    xGetAlpha(GV.Alpha.24,'Mat.Att.Dehnung2');
    xGetAlpha(GV.Alpha.25,'Mat.Att.Wert01'); //C
    xGetAlpha(GV.Alpha.26,'Mat.Att.Wert02'); //Si
    xGetAlpha(GV.Alpha.27,'Mat.Att.Wert03'); //Mn
    xGetAlpha(GV.Alpha.28,'Mat.Att.Wert04'); //P
    xGetAlpha(GV.Alpha.29,'Mat.Att.Wert05'); //S
    xGetAlpha(GV.Alpha.30,'Mat.Att.Wert07'); //Al
    xGetAlpha(GV.Alpha.31,'Mat.Att.Wert08'); //Cr
    xGetAlpha(GV.Alpha.32,'Mat.Att.Wert11'); //V
    xGetAlpha(GV.Alpha.33,'Mat.Att.Wert13'); //Nb
    xGetAlpha(GV.Alpha.34,'Mat.Att.Wert12'); //Ti
    xGetAlpha(GV.Alpha.35,'Mat.Att.Wert14'); //N
    xGetAlpha(GV.Alpha.36,'Mat.Att.Wert06'); //Cu
    xGetAlpha(GV.Alpha.37,'Mat.Att.Wert10'); //Ni
    xGetAlpha(GV.Alpha.38,'Mat.Att.Wert09'); //Mo
    xGetAlpha(GV.Alpha.39,'Mat.Att.Wert15'); //W
    xGetAlpha(GV.Alpha.40,'Mat.Att.Wert16'); //Pb

    xGetAlpha(GV.Alpha.41,'Mat.Gem.Dehngrenze02');
    xGetAlpha(GV.Alpha.42,'Mat.Gem.Dehngrenze10');
    xGetAlpha(GV.Alpha.43,'Mat.Gem.Korngröße');

    xGetAlpha(GV.Alpha.45,'Mat.Att.Dehngrenze02');
    xGetAlpha(GV.Alpha.46,'Mat.Att.Dehngrenze10');
    xGetAlpha(GV.Alpha.47,'Mat.Att.Korngröße');


    // Format-Konvertierungen...
    Mat.Streckgrenze1     # CnvFA(Gv.Alpha.01);
    Mat.Zugfestigkeit1    # CnvFA(Gv.Alpha.02);
    Mat.DehnungA1         # CnvFA(Gv.Alpha.03);
    Mat.DehnungB1         # CnvFA(Gv.Alpha.04);

    Mat.Chemie.C1         # CnvFA(Gv.Alpha.05);
    Mat.Chemie.Si1        # CnvFA(Gv.Alpha.06);
    Mat.Chemie.Mn1        # CnvFA(Gv.Alpha.07);
    Mat.Chemie.P1         # CnvFA(Gv.Alpha.08);
    Mat.Chemie.S1         # CnvFA(Gv.Alpha.09);
    Mat.Chemie.Al1        # CnvFA(Gv.Alpha.10);
    Mat.Chemie.Cr1        # CnvFA(Gv.Alpha.11);
    Mat.Chemie.V1         # CnvFA(Gv.Alpha.12);
    Mat.Chemie.Nb1        # CnvFA(Gv.Alpha.13);
    Mat.Chemie.Ti1        # CnvFA(Gv.Alpha.14);
    Mat.Chemie.N1         # CnvFA(Gv.Alpha.15); // Co
    Mat.Chemie.Cu1        # CnvFA(Gv.Alpha.16);
    Mat.Chemie.Ni1        # CnvFA(Gv.Alpha.17);
    Mat.Chemie.Mo1        # CnvFA(Gv.Alpha.18);
    Mat.Chemie.B1         # CnvFA(Gv.Alpha.19); // W
    Mat.Chemie.Frei1.1    # CnvFA(Gv.Alpha.20); // Pb

    Mat.Streckgrenze2     # CnvFA(Gv.Alpha.21);
    Mat.Zugfestigkeit2    # CnvFA(Gv.Alpha.22);
    Mat.DehnungA2         # CnvFA(Gv.Alpha.23);
    Mat.DehnungB2         # CnvFA(Gv.Alpha.24);

    Mat.Chemie.C2         # CnvFA(Gv.Alpha.25);
    Mat.Chemie.Si2        # CnvFA(Gv.Alpha.26);
    Mat.Chemie.Mn2        # CnvFA(Gv.Alpha.27);
    Mat.Chemie.P2         # CnvFA(Gv.Alpha.28);
    Mat.Chemie.S2         # CnvFA(Gv.Alpha.29);
    Mat.Chemie.Al2        # CnvFA(Gv.Alpha.30);
    Mat.Chemie.Cr2        # CnvFA(Gv.Alpha.31);
    Mat.Chemie.V2         # CnvFA(Gv.Alpha.32);
    Mat.Chemie.Nb2        # CnvFA(Gv.Alpha.33);
    Mat.Chemie.Ti2        # CnvFA(Gv.Alpha.34);
    Mat.Chemie.N2         # CnvFA(Gv.Alpha.35); // Co
    Mat.Chemie.Cu2        # CnvFA(Gv.Alpha.36);
    Mat.Chemie.Ni2        # CnvFA(Gv.Alpha.37);
    Mat.Chemie.Mo2        # CnvFA(Gv.Alpha.38);
    Mat.Chemie.B2         # CnvFA(Gv.Alpha.39); // W
    Mat.Chemie.Frei1.2    # CnvFA(Gv.Alpha.40); // Pb

    Mat.RP02_V1           # CnvFA(Gv.Alpha.41);
    Mat.RP10_V1           # CnvFA(Gv.Alpha.42);
    "Mat.Körnung1"        # CnvFA(Gv.Alpha.43);

    Mat.RP02_B1           # CnvFA(Gv.Alpha.45);
    Mat.RP10_B1           # CnvFA(Gv.Alpha.46);
    "Mat.Körnung2"        # CnvFA(Gv.Alpha.47);
    //==========================================================

    //xGetInt(Mat.KommKundennr,'');
    //xGetInt(Mat.VK.Kundennr,'');
    //xGetInt(Mat.VK.Rechnr,'');
    //xGetInt(Mat.EK.RechNr,'');
    //xGetInt(Mat.Auftragsnr,'');
    //xGetInt(Mat.Einkaufsnr,'');
    //xGetAlpha(Mat.Gütenstufe,'');
    //xGetAlpha(Mat.AusführungUnten,'');

    //xGetAlpha(Mat.Intrastatnr,'');
    //xGetAlpha(Mat.KommKundenSWort,'');
    //xGetAlpha(Mat.LieferStichwort,'');
    //xGetAlpha(Mat.LagerStichwort,'');
    //xGetAlpha(Mat.QS.User,'');
    //xGetAlpha(Mat.Zwischenlage,'');
    //xGetAlpha(Mat.Unterlage,'');
    //GetNum(Mat.DickenTol.Von,'');
    //GetNum(Mat.DickenTol.Bis,'');
    //GetNum(Mat.BreitenTol.Von,'');
    //GetNum(Mat.BreitenTol.Bis,'');
    //GetNum(Mat.Länge.Von,'');
    //GetNum(Mat.Länge.Bis,'');
    //GetNum(Mat.LängenTol.Von,'');
    //GetNum(Mat.LängenTol.Bis,'');
    //GetNum(Mat.VK.Preis,'');
    //GetNum(Mat.VK.Gewicht,'');
    //GetNum(Mat.Nettoabzug,'');
    //GetNum(Mat.Stapelhöhe,'');
    //GetNum(Mat.Stapelhöhenabzug,'');
    //GetNum(Mat.Rechtwinkligkeit,'');
    //GetNum(Mat.Ebenheit,'');
    //GetNum(Mat.Säbeligkeit,'');
    //GetNum(Mat.Etk.Dicke,'');
    //GetNum(Mat.Etk.Breite,'');
    //GetNum(Mat.Etk.Länge,'');
    //GetDate(Mat.QS.Datum,'');
    //GetDate(Mat.VK.Rechdatum,'');
    //GetDate(Mat.EK.RechDatum,'');
    //GetWord(Mat.Auftragspos,'');
    //GetWord(Mat.Einkaufspos,'');
    //GetWord(Mat.QS.Status,'');
    //GetWord(Mat.Verwiegungsart,'');
    //GetWord(Mat.AbbindungL,'');
    //GetWord(Mat.AbbindungQ,'');
    //GetBool(Mat.DickenTolYN,'');
    //GetBool(Mat.BreitenTolYN,'');
    //GetBool(Mat.LängenTolYN,'');
    //GetBool(Mat.StehendYN,'');
    //GetBool(Mat.LiegendYN,'');
    //GetTime(Mat.QS.Zeit,'');


    // im BA?
    if (Mat.Status>=700) and (Mat.Status<=749) then begin
      Mat.Status        # 1;
      Mat.Eingangsdatum # "Mat.Übernahmedatum";
    end;


    // Karte NICHT gelöscht und Status=1 verfügbar??
    if("Mat.Löschmarker"='*') or (Mat.Status<>1)then begin
      Erx # RecRead(2200,1,_recNext);
      CYCLE;
    end;


    // Oberflächen holen...
    RecBufClear(201);
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.Seite        # '1';
    Mat.AF.lfdNr        # 1;

    xGetAlpha(GV.Alpha.52,'Obf.Bezeichnung');
    Erx # StrFind(GV.Alpha.52,'ungebeizt',0,_StrCaseIgnore);
    if (Erx>0) then begin
      Mat.AF.ObfNr # 1;
      Erx # RecLink(841,201,1,0); // Oberfläche holen
      if (Erx<=_rLocked) then begin
        Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
        "Mat.AF.Kürzel"     # "Obf.Kürzel";
      end
      RekInsert(201,0,'AUTO');
      Mat.AF.lfdNr # Mat.AF.lfdNr + 1;
      end
    else begin
      Erx # StrFind(GV.Alpha.52,'gebeizt',0,_StrCaseIgnore);
      if (Erx>0) then begin
        Mat.AF.ObfNr # 2;
        Erx # RecLink(841,201,1,0); // Oberfläche holen
        if (Erx<=_rLocked) then begin
          Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
          "Mat.AF.Kürzel"     # "Obf.Kürzel";
        end
        RekInsert(201,0,'AUTO');
        Mat.AF.lfdNr # Mat.AF.lfdNr + 1;
      end;
    end;

    Erx # StrFind(GV.Alpha.52,'gefettet',0,_StrFindToken);
    if (Erx>0) then begin
      Mat.AF.ObfNr # 3;
      Erx # RecLink(841,201,1,0); // Oberfläche holen
      if (Erx<=_rLocked) then begin
        Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
        "Mat.AF.Kürzel"     # "Obf.Kürzel";
      end
      RekInsert(201,0,'AUTO');
      Mat.AF.lfdNr # Mat.AF.lfdNr + 1;
      end
    else begin
      Erx # StrFind(GV.Alpha.52,'ungefettet',0,_StrFindToken);
      if (Erx>0) then begin
        Mat.AF.ObfNr # 4;
        Erx # RecLink(841,201,1,0); // Oberfläche holen
        if (Erx<=_rLocked) then begin
          Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
          "Mat.AF.Kürzel"     # "Obf.Kürzel";
        end
        RekInsert(201,0,'AUTO');
        Mat.AF.lfdNr # Mat.AF.lfdNr + 1;
      end;
    end;

    "Mat.AusführungOben" #  Obf_Data:BildeAFString(200,'1');

    // Karte anlegen...
      Mat_Data:Insert(0,'AUTO',today);


    Erx # RecRead(2200,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Material wurde importiert!',0,0,0);
end;


//========================================================================
//  Import_TSR
//
//========================================================================
sub Import_TSR()
local begin
  Erx   : int;
  vI    : int;
  vJ    : int;
  vN    : float;
  vA    : alpha;
end;
begin

// Auftrag: KEINE VPG, KEINE Analyse
// Einkauf: NUR VPG, KEINE Analyse

//DBADisconnect(2);

  Lib_rec:ClearFile(200,'TEXTE');
  Lib_rec:ClearFile(201,'TEXTE');
  Lib_rec:ClearFile(202,'TEXTE');
  Lib_rec:ClearFile(203,'TEXTE');
  Lib_rec:ClearFile(204,'TEXTE');
  Lib_rec:ClearFile(205,'TEXTE');
  Lib_rec:ClearFile(240,'TEXTE');

//  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(200);
    RecBufClear(240);

    xGetWord(Mat.Status,'Mat.Status');
    xGetAlpha("Mat.Löschmarker",'Mat.Löschmarker');

    Mat.Lageranschrift # 1;
    "Mat.Vorgänger"    # 0;

    xGetAlpha(GV.Alpha.48,'Mat.Ursprungsland');

    case GV.Alpha.48 of
      'Deutschland'         : Mat.Ursprungsland # 'D';
      'Italien'             : Mat.Ursprungsland # 'I';
      'Österreich'          : Mat.Ursprungsland # 'A';
      'Belgien'             : Mat.Ursprungsland # 'B';
      'Brasilien'           : Mat.Ursprungsland # 'BR';
      'Schweiz'             : Mat.Ursprungsland # 'CH';
      'Tschechien'          : Mat.Ursprungsland # 'CH';
      'Dänemark'            : Mat.Ursprungsland # 'DK';
      'Spanien'             : Mat.Ursprungsland # 'ESP';
      'Frankreich'          : Mat.Ursprungsland # 'F';
      'Griechenland'        : Mat.Ursprungsland # 'GR';
      'Niederlande'         : Mat.Ursprungsland # 'NL';
      'Polen'               : Mat.Ursprungsland # 'PL';
      'Südafrika'           : Mat.Ursprungsland # 'RS';
      'Russland'            : Mat.Ursprungsland # 'RU';
      'Vereinigten Staaten' : Mat.Ursprungsland # 'US';

      otherwise begin
        Mat.Ursprungsland # GetAlphaMAX('Mat.Ursprungsland',3);
      end;

    end


    xGetWord(GV.Ints.01,'Mat.Oberfläche');    //Mat.AusführungOben
    xGetInt(GV.Int.02,'Mat.Lagerort');

    // Umsetzen Lieferantennr->Adressnummer
    Adr.Lieferantennr # GV.Int.02;
    RecRead(100,3,0);   // Lieferanten holen
    Mat.Lageradresse # Adr.Nummer;


    xGetInt(Mat.Nummer,'Mat.Nummer');
    xGetInt(Mat.Ursprung,'Mat.Ursprung');
    xGetInt("Mat.Vorgänger",'Mat.Vorgänger');

    xGetInt(Mat.Bestand.Stk,'Mat.Bestand.Stk');
    xGetInt(Mat.Bestellt.Stk,'Mat.Bestellt.Stk');
    xGetInt(Mat.Reserviert.Stk,'Mat.Reserviert.Stk');
    xGetInt("Mat.Verfügbar.Stk",'Mat.Verfügbar.Stk');
//    xGetInt(Mat.Paketnr,'Mat.Paketnummer');
    xGetInt(Mat.Erzeuger,'Mat.Erzeuger');
    xGetInt(Mat.Lieferant,'Mat.Lieferant');
//    debug(cnvAI(Mat.Lieferant));
//    xGetInt(Mat.Analysenummer,'Mat.Analysenummer');
    xGetAlpha("Mat.Güte",'Mat.Qualität');
    xGetAlpha(GV.Alpha.50,'Mat.Werkstoffnummer');
    Mat.Werkstoffnr # strcut(GV.Alpha.50,0,8);
    if (Mat.Werkstoffnr='') then begin
      MQu_Data:Autokorrektur(var "Mat.Güte");
      Mat.Werkstoffnr # MQU.Werkstoffnr;
    end;
    xGetAlpha(Mat.Coilnummer,'Mat.Coilnummer');
    xGetAlpha(Mat.Ringnummer,'Mat.Tafelnummer');
    xGetAlpha(Mat.Chargennummer,'Mat.Chargennummer');
    xGetAlpha(Mat.Werksnummer,'Mat.Werksnummer');
    xGetAlpha(Mat.DickenTol,'Mat.Dickentoleranz');
    xGetAlpha(Mat.BreitenTol,'Mat.Breitentoleranz');
    xGetAlpha("Mat.LängenTol",'Mat.Längentoleranz');
    xGetAlpha(Mat.Zeugnisart,'Mat.Zeugnisart');
    //xGetAlpha(Mat.Zeugnisakte,'Mat.Zeugnisakte')
    //xGetAlpha(Mat.Kommission,'Mat.Kommission');;
    xGetAlpha(Mat.Bemerkung1,'Mat.Bemerkung1');
    xGetAlpha(Mat.Bemerkung2,'Mat.Bemerkung2');
    xGetAlpha(Mat.Bestellnummer,'Mat.Bestellnummer');
    xGetAlpha(Mat.BestellABNr,'Mat.LiefBestnr');
    Mat.Lagerplatz # GetAlphaMAX('Mat.Lagerplatz',20);
    xGetNum(Mat.Dicke,'Mat.Dicke');
    xGetNum(Mat.Dicke.Von,'Mat.ZehnerprobeVon');
    xGetNum(Mat.Dicke.Bis,'Mat.ZehnerprobeBis');
    xGetNum(Mat.Breite,'Mat.Breite');
  //  GetNum(Mat.Breite.Von,'Mat.Breite2');
  //  GetNum(Mat.Breite.Bis,'Mat.Breite3');
    xGetNum("Mat.Länge",'Mat.Länge');
    xGetNum(Mat.RID,'Mat.Innendurchm');
    xGetNum(Mat.RAD,'Mat.Außendurchm');
    xGetNum(Mat.Dichte,'Mat.Dichte');
    xGetNum(Mat.Kgmm,'Mat.Kgmm');
    xGetNum(Mat.Bestand.Gew,'Mat.Bestand.Gew');
    xGetNum(Mat.Bestellt.Gew,'Mat.Bestellt.Gew');
    xGetNum(Mat.Reserviert.Gew,'Mat.Reserviert.Gew');
    xGetNum("Mat.Verfügbar.Gew",'Mat.Verfügbar.Gew');
    xGetNum(Mat.EK.Preis,'Mat.EK-effektiv');
    //GetNum(Mat.EK.Preis,'Mat.EK-Preis');
    //GetNum(Mat.Kosten,'Mat.VK-Preis');
    //GetNum(Mat.EK.Effektiv,'Mat.EK-effektiv');
    xGetNum(Mat.Gewicht.Netto,'Mat.Gewicht.Netto');
    xGetNum(Mat.Gewicht.Brutto,'Mat.Gewicht.Brutto');
    xGetDate("Mat.Übernahmedatum",'Mat.Übernahmedatum');
    xGetDate(Mat.Bestelldatum,'Mat.Bestelldatum');
    xGetDate(Mat.BestellTermin,'Mat.Termin');
    xGetDate(Mat.Eingangsdatum,'Mat.Eingangsdatum');
    xGetDate(Mat.Ausgangsdatum,'Mat.Ausgangsdatum');
    xGetDate(Mat.Inventurdatum,'Mat.Inventurdatum');
    xGetWord(Mat.Warengruppe,'Mat.Warengruppe');
    GetBool(Mat.EigenmaterialYN,'Mat.Eigenmaterial');

    Mat.Strukturnr # GetAlphaMAX('Mat.Bezeichnung3',20);

    if ("Mat.Löschmarker"='') then
      Mat.Zeugnisakte # cnvai(Mat.Ursprung,_FmtNumNoGroup);

    RecBufClear(201);
    MAT.AF.ObfNr          # GetWord('Mat.Oberfläche');
    if (MAT.AF.ObfNr>0) then begin
      Mat.AF.Nummer       # Mat.Nummer;
      Mat.AF.Seite        # '1';
      Mat.AF.lfdNr        # 1;
      RecLink(841,201,1,_recFirst);   // Obf holen
      Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Mat.AF.Kürzel"     # "Obf.Kürzel";
      RekInsert(201,0,'MAN');
    end;
    "Mat.AusführungOben"  # Mat.AF.Bezeichnung;


    //==============Analyse=====================================
    xGetAlpha(GV.Alpha.01,'Mat.Gem.Streckgrenze');
    xGetAlpha(GV.Alpha.02,'Mat.Gem.Festigkeit');
    xGetAlpha(GV.Alpha.03,'Mat.Gem.Dehnung1');
    xGetAlpha(GV.Alpha.04,'Mat.Gem.Dehnung2');
    xGetAlpha(GV.Alpha.05,'Mat.Gem.Wert01'); //C
    xGetAlpha(GV.Alpha.06,'Mat.Gem.Wert02'); //Si
    xGetAlpha(GV.Alpha.07,'Mat.Gem.Wert03'); //Mn
    xGetAlpha(GV.Alpha.08,'Mat.Gem.Wert04'); //P
    xGetAlpha(GV.Alpha.09,'Mat.Gem.Wert05'); //S
    xGetAlpha(GV.Alpha.10,'Mat.Gem.Wert06'); //Al
    xGetAlpha(GV.Alpha.11,'Mat.Gem.Wert07'); //Cr
    xGetAlpha(GV.Alpha.12,'Mat.Gem.Wert08'); //V
    xGetAlpha(GV.Alpha.13,'Mat.Gem.Wert09'); //Nb
    xGetAlpha(GV.Alpha.14,'Mat.Gem.Wert10'); //Ti
    xGetAlpha(GV.Alpha.15,'Mat.Gem.Wert11'); //N
    xGetAlpha(GV.Alpha.16,'Mat.Gem.Wert12'); //Cu
    xGetAlpha(GV.Alpha.17,'Mat.Gem.Wert13'); //W
    xGetAlpha(GV.Alpha.18,'Mat.Gem.Wert14'); //Mo
    xGetAlpha(GV.Alpha.19,'Mat.Gem.Wert15'); //B
    xGetAlpha(GV.Alpha.20,'Mat.Gem.Wert16'); //Ni
    xGetAlpha(GV.Alpha.21,'Mat.Att.Streckgrenze');
    xGetAlpha(GV.Alpha.22,'Mat.Att.Festigkeit');
    xGetAlpha(GV.Alpha.23,'Mat.Att.Dehnung1');
    xGetAlpha(GV.Alpha.24,'Mat.Att.Dehnung2');

    xGetAlpha(GV.Alpha.25,'Mat.Att.Wert01'); //C
    xGetAlpha(GV.Alpha.26,'Mat.Att.Wert02'); //Si
    xGetAlpha(GV.Alpha.27,'Mat.Att.Wert03'); //Mn
    xGetAlpha(GV.Alpha.28,'Mat.Att.Wert04'); //P
    xGetAlpha(GV.Alpha.29,'Mat.Att.Wert05'); //S
    xGetAlpha(GV.Alpha.30,'Mat.Att.Wert06'); //Al
    xGetAlpha(GV.Alpha.31,'Mat.Att.Wert07'); //Cr
    xGetAlpha(GV.Alpha.32,'Mat.Att.Wert08'); //V
    xGetAlpha(GV.Alpha.33,'Mat.Att.Wert09'); //Nb
    xGetAlpha(GV.Alpha.34,'Mat.Att.Wert10'); //Ti
    xGetAlpha(GV.Alpha.35,'Mat.Att.Wert11'); //N
    xGetAlpha(GV.Alpha.36,'Mat.Att.Wert12'); //Cu
    xGetAlpha(GV.Alpha.37,'Mat.Att.Wert13'); //W
    xGetAlpha(GV.Alpha.38,'Mat.Att.Wert14'); //Mo
    xGetAlpha(GV.Alpha.39,'Mat.Att.Wert15'); //B
    xGetAlpha(GV.Alpha.40,'Mat.Att.Wert16'); //Ni

    xGetAlpha(GV.Alpha.41,'Mat.Gem.Dehngrenze02');
    xGetAlpha(GV.Alpha.42,'Mat.Gem.Dehngrenze10');
    xGetAlpha(GV.Alpha.43,'Mat.Gem.Korngröße');

    xGetAlpha(GV.Alpha.45,'Mat.Att.Dehngrenze02');
    xGetAlpha(GV.Alpha.46,'Mat.Att.Dehngrenze10');
    xGetAlpha(GV.Alpha.47,'Mat.Att.Korngröße');


    // Format-Konvertierungen...
    Mat.Streckgrenze1     # CnvFA(Gv.Alpha.01);
    Mat.Zugfestigkeit1    # CnvFA(Gv.Alpha.02);
    Mat.DehnungA1         # CnvFA(Gv.Alpha.03);
    Mat.DehnungB1         # CnvFA(Gv.Alpha.04);

    Mat.Chemie.C1         # CnvFA(Gv.Alpha.05);
    Mat.Chemie.Si1        # CnvFA(Gv.Alpha.06);
    Mat.Chemie.Mn1        # CnvFA(Gv.Alpha.07);
    Mat.Chemie.P1         # CnvFA(Gv.Alpha.08);
    Mat.Chemie.S1         # CnvFA(Gv.Alpha.09);
    Mat.Chemie.Al1        # CnvFA(Gv.Alpha.10);
    Mat.Chemie.Cr1        # CnvFA(Gv.Alpha.11);
    Mat.Chemie.V1         # CnvFA(Gv.Alpha.12);
    Mat.Chemie.Nb1        # CnvFA(Gv.Alpha.13);
    Mat.Chemie.Ti1        # CnvFA(Gv.Alpha.14);
    Mat.Chemie.N1         # CnvFA(Gv.Alpha.15);
    Mat.Chemie.Cu1        # CnvFA(Gv.Alpha.16);
    Mat.Chemie.Ni1        # CnvFA(Gv.Alpha.17);
    Mat.Chemie.Mo1        # CnvFA(GV.Alpha.18);
    Mat.Chemie.B1         # CnvFA(Gv.Alpha.19);
    Mat.Chemie.Frei1.1    # CnvFA(GV.Alpha.20); // Ni

    Mat.Streckgrenze2     # CnvFA(Gv.Alpha.21);
    Mat.Zugfestigkeit2    # CnvFA(Gv.Alpha.22);
    Mat.DehnungA2         # CnvFA(Gv.Alpha.23);
    Mat.DehnungB2         # CnvFA(Gv.Alpha.24);

    Mat.Chemie.C2         # CnvFA(Gv.Alpha.25);
    Mat.Chemie.Si2        # CnvFA(Gv.Alpha.26);
    Mat.Chemie.Mn2        # CnvFA(Gv.Alpha.27);
    Mat.Chemie.P2         # CnvFA(Gv.Alpha.28);
    Mat.Chemie.S2         # CnvFA(Gv.Alpha.29);
    Mat.Chemie.Al2        # CnvFA(Gv.Alpha.30);
    Mat.Chemie.Cr2        # CnvFA(Gv.Alpha.31);
    Mat.Chemie.V2         # CnvFA(Gv.Alpha.32);
    Mat.Chemie.Nb2        # CnvFA(Gv.Alpha.33);
    Mat.Chemie.Ti2        # CnvFA(Gv.Alpha.34);
    Mat.Chemie.N2         # CnvFA(Gv.Alpha.35);
    Mat.Chemie.Cu2        # CnvFA(Gv.Alpha.36);
    Mat.Chemie.Ni2        # CnvFA(Gv.Alpha.37);
    Mat.Chemie.Mo2        # CnvFA(GV.Alpha.38);
    Mat.Chemie.B2         # CnvFA(Gv.Alpha.39);
    Mat.Chemie.Frei1.2    # CnvFA(Gv.Alpha.40);


    Mat.RP02_V1           # CnvFA(Gv.Alpha.41);
    Mat.RP10_V1           # CnvFA(Gv.Alpha.42);
    "Mat.Körnung1"        # CnvFA(Gv.Alpha.43);

    Mat.RP02_B1           # CnvFA(Gv.Alpha.45);
    Mat.RP10_B1           # CnvFA(Gv.Alpha.46);
    "Mat.Körnung2"        # CnvFA(Gv.Alpha.47);
    //==========================================================

    //xGetInt(Mat.KommKundennr,'');
    //xGetInt(Mat.VK.Kundennr,'');
    //xGetInt(Mat.VK.Rechnr,'');
    //xGetInt(Mat.EK.RechNr,'');
    //xGetInt(Mat.Auftragsnr,'');
    //xGetInt(Mat.Einkaufsnr,'');
    //xGetAlpha(Mat.Gütenstufe,'');
    //xGetAlpha(Mat.AusführungUnten,'');
    //xGetAlpha(Mat.Strukturnr,'');
    //xGetAlpha(Mat.Intrastatnr,'');
    //xGetAlpha(Mat.KommKundenSWort,'');
    //xGetAlpha(Mat.LieferStichwort,'');
    //xGetAlpha(Mat.LagerStichwort,'');
    //xGetAlpha(Mat.QS.User,'');
    //xGetAlpha(Mat.Zwischenlage,'');
    //xGetAlpha(Mat.Unterlage,'');
    //GetNum(Mat.DickenTol.Von,'');
    //GetNum(Mat.DickenTol.Bis,'');
    //GetNum(Mat.BreitenTol.Von,'');
    //GetNum(Mat.BreitenTol.Bis,'');
    //GetNum(Mat.Länge.Von,'');
    //GetNum(Mat.Länge.Bis,'');
    //GetNum(Mat.LängenTol.Von,'');
    //GetNum(Mat.LängenTol.Bis,'');
    //GetNum(Mat.VK.Preis,'');
    //GetNum(Mat.VK.Gewicht,'');
    //GetNum(Mat.Nettoabzug,'');
    //GetNum(Mat.Stapelhöhe,'');
    //GetNum(Mat.Stapelhöhenabzug,'');
    //GetNum(Mat.Rechtwinkligkeit,'');
    //GetNum(Mat.Ebenheit,'');
    //GetNum(Mat.Säbeligkeit,'');
    //GetNum(Mat.Etk.Dicke,'');
    //GetNum(Mat.Etk.Breite,'');
    //GetNum(Mat.Etk.Länge,'');
    //GetDate(Mat.QS.Datum,'');
    //GetDate(Mat.VK.Rechdatum,'');
    //GetDate(Mat.EK.RechDatum,'');
    //GetWord(Mat.Auftragspos,'');
    //GetWord(Mat.Einkaufspos,'');
    //GetWord(Mat.QS.Status,'');
    //GetWord(Mat.Verwiegungsart,'');
    //GetWord(Mat.AbbindungL,'');
    //GetWord(Mat.AbbindungQ,'');
    //GetBool(Mat.DickenTolYN,'');
    //GetBool(Mat.BreitenTolYN,'');
    //GetBool(Mat.LängenTolYN,'');
    //GetBool(Mat.StehendYN,'');
    //GetBool(Mat.LiegendYN,'');
    //GetTime(Mat.QS.Zeit,'');


//  if ("Mat.Löschmarker"<>'*') and
//    ((Mat.Status=1) or (Mat.Status=404)) then begin
    If (Mat.Strukturnr<>'') then begin
      Erx # RecLink(250,200,26,_recFirst);  // ARtikel holenm
      if (Erx<>_rOK) then begin
debug('artikel fehlt:'+mat.strukturnr);
         Erx # RecRead(2200,1,_recNext);
         CYCLE;
      end;
    end;
    Erx # Mat_Data:Insert(0,'AUTO',today);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,'MAT:'+cnvai(mat.nummer)+gTitle,0,0,0);
      RETURN;
    end;


    if (1=1) then begin

      Erx # RecLink(2201,2200,8,_recfirst);   // Aktionen loopen
      WHILE (Erx<=_rLocked) do begin
        RecBufClear(204);
        Mat.A.Materialnr      # GetInt('Mat.A.Materialnr');
        Mat.A.Aktion          # Getword('Mat.A.Nummer');
        Mat.A.Aktionsmat      # GetInt('Mat.A.Aktionsmat');
        Mat.A.Entstanden      # GetInt('Mat.A.Entstanden');
        Mat.A.Aktionstyp      # GetAlpha('Mat.A.Aktionstyp');
        Mat.A.Aktionsnr       # GetInt('Mat.A.Aktionsnr');
        Mat.A.Aktionspos      # GetWord('Mat.A.Aktionspos');
        Mat.A.Aktionspos2     # 0;
        Mat.A.Aktionspos3     # 0;
        Mat.A.Aktionsdatum    # GetDate('Mat.A.Aktionsdatum');
        Mat.A.TerminStart     # GetDate('Mat.A.Aktionstermin');
        Mat.A.TerminEnde      # GetDate('Mat.A.Aktionsende');
        "Mat.A.Stückzahl"     # 0;
        Mat.A.Gewicht         # 0.0;
        Mat.A.Nettogewicht    # 0.0;
        Mat.A.Bemerkung       # GetAlpha('Mat.A.Bemerkung');
        Mat.A.KostenW1        # GetNum('Mat.A.Kosten',2);

        // 10.04.2013 VORLÄUFIG:
        Mat.A.KostenW1ProMEH  # 0.0;
        if (Mat.A.KostenW1<>0.0) and (Mat.Bestand.Menge + Mat.Bestellt.Menge<>0.0) then
          Mat.A.KostenW1ProMEH # Rnd( (Mat.A.KostenW1 * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) / (Mat.Bestand.Menge / Mat.Bestellt.Menge) ,2);

        Mat.A.Kosten2W1       # 0.0;
        Mat.A.kosten2W1ProME  # 0.0;
        Mat.A.Kostenstelle    # GetWord('Mat.A.Kostenstelle');
        Mat.A.Anlage.Datum    # GetDate('Mat.A.Datum');
        Mat.A.Anlage.Zeit     # GetTime('Mat.A.Uhrzeit');
        Mat.A.Anlage.User     # GetAlpha('Mat.A.User');
        Erx # RekInsert(204,0,'AUTO');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(001000+Erx,'AKTION'+gTitle,0,0,0);
          RETURN;
        end;

        Erx # RecLink(2201,2200,8,_recNext);
      END;

      //debug(cnvAI(Erx)+'   '+cnvAI(Mat.Nummer));
    end;


    Erx # RecRead(2200,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Material wurde importiert!',0,0,0);
end;


//========================================================================
//  Import_FLK
//
//========================================================================
sub Import_FLK()
local begin
  Erx     : int;
  Ansprechpartner : int;
end;
begin

  Lib_rec:ClearFile(200,'TEXTE');
  Lib_rec:ClearFile(201,'TEXTE');
  Lib_rec:ClearFile(202,'TEXTE');
  Lib_rec:ClearFile(203,'TEXTE');
  Lib_rec:ClearFile(204,'TEXTE');
  Lib_rec:ClearFile(205,'TEXTE');
  Lib_rec:ClearFile(240,'TEXTE');

  Erx # DBAConnect(2,'X_','TCP:192.168.0.11','StahlControl','thomas','ares','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(200);
    RecBufClear(240);

    xGetWord(Mat.Status,'Mat.Status');
    xGetAlpha("Mat.Löschmarker",'Mat.Löschmarker');

    Mat.Lageranschrift # 1;
    "Mat.Vorgänger"    # 0;

    xGetWord(GV.Ints.01,'Mat.Oberfläche');    //Mat.AusführungOben

    Erx # RecLink(2814,2200,2,_recFirst);   // Obf holen
    xGetAlpha("Mat.AusführungOben", 'Obf.Bezeichnung');
//    "Mat.AusführungOben"  # 'sonstige';


    xGetAlpha(GV.Alpha.48,'Mat.Ursprungsland');

    case GV.Alpha.48 of
      'Deutschland'         : Mat.Ursprungsland # 'D';
      'Italien'             : Mat.Ursprungsland # 'I';
      'Österreich'          : Mat.Ursprungsland # 'A';
      'Belgien'             : Mat.Ursprungsland # 'B';
      'Brasilien'           : Mat.Ursprungsland # 'BR';
      'Schweiz'             : Mat.Ursprungsland # 'CH';
      'Tschechien'          : Mat.Ursprungsland # 'CH';
      'Dänemark'            : Mat.Ursprungsland # 'DK';
      'Spanien'             : Mat.Ursprungsland # 'ESP';
      'Frankreich'          : Mat.Ursprungsland # 'F';
      'Griechenland'        : Mat.Ursprungsland # 'GR';
      'Niederlande'         : Mat.Ursprungsland # 'NL';
      'Polen'               : Mat.Ursprungsland # 'PL';
      'Südafrika'           : Mat.Ursprungsland # 'RS';
      'Russland'            : Mat.Ursprungsland # 'RU';
      'Vereinigten Staaten' : Mat.Ursprungsland # 'US';
    end;


    xGetInt(GV.Int.02,'Mat.Lagerort');
    // Umsetzen Lieferantennr->Adressnummer
    Adr.Lieferantennr # GV.Int.02;
    RecRead(100,3,0);   // Lieferanten holen
    Mat.Lageradresse # Adr.Nummer;


    xGetInt(Mat.Nummer,'Mat.Nummer');
    xGetInt(Mat.Ursprung,'Mat.Nummer');
    xGetInt(Mat.Bestand.Stk,'Mat.Bestand.Stk');
    xGetInt(Mat.Bestellt.Stk,'Mat.Bestellt.Stk');
    xGetInt(Mat.Reserviert.Stk,'Mat.Reserviert.Stk');
    xGetInt("Mat.Verfügbar.Stk",'Mat.Verfügbar.Stk');
//    GetInt(Mat.Paketnr,'Mat.Paketnummer');
    xGetInt(Mat.Erzeuger,'Mat.Erzeuger');
    xGetInt(Mat.Lieferant,'Mat.Lieferant');
//    GetInt(Mat.Analysenummer,'Mat.Analysenummer');
    xGetAlpha("Mat.Güte",'Mat.Qualität');
    xGetAlpha(Mat.Werkstoffnr,'Mat.Werkstoffnummer');
    xGetAlpha(Mat.Coilnummer,'Mat.Coilnummer');
    xGetAlpha(Mat.Ringnummer,'Mat.Tafelnummer');
    xGetAlpha(Mat.Chargennummer,'Mat.Chargennummer');
    xGetAlpha(Mat.Werksnummer,'Mat.Werksnummer');
    xGetAlpha(Mat.DickenTol,'Mat.Dickentoleranz');
    xGetAlpha(Mat.BreitenTol,'Mat.Breitentoleranz');
    xGetAlpha("Mat.LängenTol",'Mat.Längentoleranz');
    xGetAlpha(Mat.Zeugnisart,'Mat.Zeugnisart');
    xGetAlpha(Mat.Zeugnisakte,'Mat.Zeugnisakte')
    //xGetAlpha(Mat.Kommission,'Mat.Kommission');;
    xGetAlpha(Mat.Bemerkung1,'Mat.Bemerkung1');
    xGetAlpha(Mat.Bemerkung2,'Mat.Bemerkung2');
    xGetAlpha(Mat.Bestellnummer,'Mat.Bestellnummer');
    xGetAlpha(Mat.BestellABNr,'Mat.LiefBestnr');
    xGetAlpha(Mat.Lagerplatz,'Mat.Lagerplatz');
    xGetNum(Mat.Dicke,'Mat.Dicke');
    xGetNum(Mat.Dicke.Von,'Mat.ZehnerprobeVon');
    xGetNum(Mat.Dicke.Bis,'Mat.ZehnerprobeBis');
    xGetNum(Mat.Breite,'Mat.Breite');
  //  GetNum(Mat.Breite.Von,'Mat.Breite2');
  //  GetNum(Mat.Breite.Bis,'Mat.Breite3');
    xGetNum("Mat.Länge",'Mat.Länge');
    xGetNum(Mat.RID,'Mat.Innendurchm');
    xGetNum(Mat.RAD,'Mat.Außendurchm');
    xGetNum(Mat.Dichte,'Mat.Dichte');
    xGetNum(Mat.Kgmm,'Mat.Kgmm');
    xGetNum(Mat.Bestand.Gew,'Mat.Bestand.Gew');
    xGetNum(Mat.Bestellt.Gew,'Mat.Bestellt.Gew');
    xGetNum(Mat.Reserviert.Gew,'Mat.Reserviert.Gew');
    xGetNum("Mat.Verfügbar.Gew",'Mat.Verfügbar.Gew');
    xGetNum(Mat.EK.Preis,'Mat.EK-effektiv');
    //GetNum(Mat.EK.Preis,'Mat.EK-Preis');
    //GetNum(Mat.Kosten,'Mat.VK-Preis');
    //GetNum(Mat.EK.Effektiv,'Mat.EK-effektiv');
    xGetNum(Mat.Gewicht.Netto,'Mat.Gewicht.Netto');
    xGetNum(Mat.Gewicht.Brutto,'Mat.Gewicht.Brutto');
    xGetDate("Mat.Übernahmedatum",'Mat.Übernahmedatum');
    xGetDate(Mat.Bestelldatum,'Mat.Bestelldatum');
    xGetDate(Mat.BestellTermin,'Mat.Termin');
    xGetDate(Mat.Eingangsdatum,'Mat.Eingangsdatum');
    xGetDate(Mat.Ausgangsdatum,'Mat.Ausgangsdatum');
    xGetDate(Mat.Inventurdatum,'Mat.Inventurdatum');
    xGetWord(Mat.Warengruppe,'Mat.Warengruppe');
    GetBool(Mat.EigenmaterialYN,'Mat.Eigenmaterial');

    //==============Analyse=====================================
    xGetAlpha(GV.Alpha.01,'Mat.Gem.Streckgrenze');
    xGetAlpha(GV.Alpha.02,'Mat.Gem.Festigkeit');
    xGetAlpha(GV.Alpha.03,'Mat.Gem.Dehnung1');
    xGetAlpha(GV.Alpha.04,'Mat.Gem.Dehnung2');
    xGetAlpha(GV.Alpha.05,'Mat.Gem.Wert01'); //C
    xGetAlpha(GV.Alpha.06,'Mat.Gem.Wert02'); //Si
    xGetAlpha(GV.Alpha.07,'Mat.Gem.Wert03'); //Mn
    xGetAlpha(GV.Alpha.08,'Mat.Gem.Wert04'); //P
    xGetAlpha(GV.Alpha.09,'Mat.Gem.Wert05'); //S
    xGetAlpha(GV.Alpha.10,'Mat.Gem.Wert07'); //Al
    xGetAlpha(GV.Alpha.11,'Mat.Gem.Wert08'); //Cr
    xGetAlpha(GV.Alpha.12,'Mat.Gem.Wert11'); //V
    xGetAlpha(GV.Alpha.13,'Mat.Gem.Wert13'); //Nb
    xGetAlpha(GV.Alpha.14,'Mat.Gem.Wert12'); //Ti
    xGetAlpha(GV.Alpha.15,'Mat.Gem.Wert14'); //N
    xGetAlpha(GV.Alpha.16,'Mat.Gem.Wert06'); //Cu
    xGetAlpha(GV.Alpha.17,'Mat.Gem.Wert10'); //Ni
    xGetAlpha(GV.Alpha.18,'Mat.Gem.Wert09'); //Mo
    xGetAlpha(GV.Alpha.19,'Mat.Gem.Wert15'); //W
    xGetAlpha(GV.Alpha.20,'Mat.Gem.Wert16'); //Pb
    xGetAlpha(GV.Alpha.21,'Mat.Att.Streckgrenze');
    xGetAlpha(GV.Alpha.22,'Mat.Att.Festigkeit');
    xGetAlpha(GV.Alpha.23,'Mat.Att.Dehnung1');
    xGetAlpha(GV.Alpha.24,'Mat.Att.Dehnung2');
    xGetAlpha(GV.Alpha.25,'Mat.Att.Wert01'); //C
    xGetAlpha(GV.Alpha.26,'Mat.Att.Wert02'); //Si
    xGetAlpha(GV.Alpha.27,'Mat.Att.Wert03'); //Mn
    xGetAlpha(GV.Alpha.28,'Mat.Att.Wert04'); //P
    xGetAlpha(GV.Alpha.29,'Mat.Att.Wert05'); //S
    xGetAlpha(GV.Alpha.30,'Mat.Att.Wert07'); //Al
    xGetAlpha(GV.Alpha.31,'Mat.Att.Wert08'); //Cr
    xGetAlpha(GV.Alpha.32,'Mat.Att.Wert11'); //V
    xGetAlpha(GV.Alpha.33,'Mat.Att.Wert13'); //Nb
    xGetAlpha(GV.Alpha.34,'Mat.Att.Wert12'); //Ti
    xGetAlpha(GV.Alpha.35,'Mat.Att.Wert14'); //N
    xGetAlpha(GV.Alpha.36,'Mat.Att.Wert06'); //Cu
    xGetAlpha(GV.Alpha.37,'Mat.Att.Wert10'); //Ni
    xGetAlpha(GV.Alpha.38,'Mat.Att.Wert09'); //Mo
    xGetAlpha(GV.Alpha.39,'Mat.Att.Wert15'); //W
    xGetAlpha(GV.Alpha.40,'Mat.Att.Wert16'); //Pb

    xGetAlpha(GV.Alpha.41,'Mat.Gem.Dehngrenze02');
    xGetAlpha(GV.Alpha.42,'Mat.Gem.Dehngrenze10');
    xGetAlpha(GV.Alpha.43,'Mat.Gem.Korngröße');

    xGetAlpha(GV.Alpha.45,'Mat.Att.Dehngrenze02');
    xGetAlpha(GV.Alpha.46,'Mat.Att.Dehngrenze10');
    xGetAlpha(GV.Alpha.47,'Mat.Att.Korngröße');


    // Format-Konvertierungen...
    Mat.Streckgrenze1     # CnvFA(Gv.Alpha.01);
    Mat.Zugfestigkeit1    # CnvFA(Gv.Alpha.02);
    Mat.DehnungA1         # CnvFA(Gv.Alpha.03);
    Mat.DehnungB1         # CnvFA(Gv.Alpha.04);

    Mat.Chemie.C1         # CnvFA(Gv.Alpha.05);
    Mat.Chemie.Si1        # CnvFA(Gv.Alpha.06);
    Mat.Chemie.Mn1        # CnvFA(Gv.Alpha.07);
    Mat.Chemie.P1         # CnvFA(Gv.Alpha.08);
    Mat.Chemie.S1         # CnvFA(Gv.Alpha.09);
    Mat.Chemie.Al1        # CnvFA(Gv.Alpha.10);
    Mat.Chemie.Cr1        # CnvFA(Gv.Alpha.11);
    Mat.Chemie.V1         # CnvFA(Gv.Alpha.12);
    Mat.Chemie.Nb1        # CnvFA(Gv.Alpha.13);
    Mat.Chemie.Ti1        # CnvFA(Gv.Alpha.14);
    Mat.Chemie.N1         # CnvFA(Gv.Alpha.15); // Co
    Mat.Chemie.Cu1        # CnvFA(Gv.Alpha.16);
    Mat.Chemie.Ni1        # CnvFA(Gv.Alpha.17);
    Mat.Chemie.Mo1        # CnvFA(Gv.Alpha.18);
    Mat.Chemie.B1         # CnvFA(Gv.Alpha.19); // W
    Mat.Chemie.Frei1.1    # CnvFA(Gv.Alpha.20); // Pb

    Mat.Streckgrenze2     # CnvFA(Gv.Alpha.21);
    Mat.Zugfestigkeit2    # CnvFA(Gv.Alpha.22);
    Mat.DehnungA2         # CnvFA(Gv.Alpha.23);
    Mat.DehnungB2         # CnvFA(Gv.Alpha.24);

    Mat.Chemie.C2         # CnvFA(Gv.Alpha.25);
    Mat.Chemie.Si2        # CnvFA(Gv.Alpha.26);
    Mat.Chemie.Mn2        # CnvFA(Gv.Alpha.27);
    Mat.Chemie.P2         # CnvFA(Gv.Alpha.28);
    Mat.Chemie.S2         # CnvFA(Gv.Alpha.29);
    Mat.Chemie.Al2        # CnvFA(Gv.Alpha.30);
    Mat.Chemie.Cr2        # CnvFA(Gv.Alpha.31);
    Mat.Chemie.V2         # CnvFA(Gv.Alpha.32);
    Mat.Chemie.Nb2        # CnvFA(Gv.Alpha.33);
    Mat.Chemie.Ti2        # CnvFA(Gv.Alpha.34);
    Mat.Chemie.N2         # CnvFA(Gv.Alpha.35); // Co
    Mat.Chemie.Cu2        # CnvFA(Gv.Alpha.36);
    Mat.Chemie.Ni2        # CnvFA(Gv.Alpha.37);
    Mat.Chemie.Mo2        # CnvFA(Gv.Alpha.38);
    Mat.Chemie.B2         # CnvFA(Gv.Alpha.39); // W
    Mat.Chemie.Frei1.2    # CnvFA(Gv.Alpha.40); // Pb

    Mat.RP02_V1           # CnvFA(Gv.Alpha.41);
    Mat.RP10_V1           # CnvFA(Gv.Alpha.42);
    "Mat.Körnung1"        # CnvFA(Gv.Alpha.43);

    Mat.RP02_B1           # CnvFA(Gv.Alpha.45);
    Mat.RP10_B1           # CnvFA(Gv.Alpha.46);
    "Mat.Körnung2"        # CnvFA(Gv.Alpha.47);
    //==========================================================

    //GetInt(Mat.KommKundennr,'');
    //xGetInt(Mat.VK.Kundennr,'');
    //xGetInt(Mat.VK.Rechnr,'');
    //xGetInt(Mat.EK.RechNr,'');
    //xGetInt(Mat.Auftragsnr,'');
    //xGetInt(Mat.Einkaufsnr,'');
    //xGetAlpha(Mat.Gütenstufe,'');
    //xGetAlpha(Mat.AusführungUnten,'');
    //xGetAlpha(Mat.Strukturnr,'');
    //xGetAlpha(Mat.Intrastatnr,'');
    //xGetAlpha(Mat.KommKundenSWort,'');
    //xGetAlpha(Mat.LieferStichwort,'');
    //xGetAlpha(Mat.LagerStichwort,'');
    //xGetAlpha(Mat.QS.User,'');
    //xGetAlpha(Mat.Zwischenlage,'');
    //xGetAlpha(Mat.Unterlage,'');
    //GetNum(Mat.DickenTol.Von,'');
    //GetNum(Mat.DickenTol.Bis,'');
    //GetNum(Mat.BreitenTol.Von,'');
    //GetNum(Mat.BreitenTol.Bis,'');
    //GetNum(Mat.Länge.Von,'');
    //GetNum(Mat.Länge.Bis,'');
    //GetNum(Mat.LängenTol.Von,'');
    //GetNum(Mat.LängenTol.Bis,'');
    //GetNum(Mat.VK.Preis,'');
    //GetNum(Mat.VK.Gewicht,'');
    //GetNum(Mat.Nettoabzug,'');
    //GetNum(Mat.Stapelhöhe,'');
    //GetNum(Mat.Stapelhöhenabzug,'');
    //GetNum(Mat.Rechtwinkligkeit,'');
    //GetNum(Mat.Ebenheit,'');
    //GetNum(Mat.Säbeligkeit,'');
    //GetNum(Mat.Etk.Dicke,'');
    //GetNum(Mat.Etk.Breite,'');
    //GetNum(Mat.Etk.Länge,'');
    //GetDate(Mat.QS.Datum,'');
    //GetDate(Mat.VK.Rechdatum,'');
    //GetDate(Mat.EK.RechDatum,'');
    //GetWord(Mat.Auftragspos,'');
    //GetWord(Mat.Einkaufspos,'');
    //GetWord(Mat.QS.Status,'');
    //GetWord(Mat.Verwiegungsart,'');
    //GetWord(Mat.AbbindungL,'');
    //GetWord(Mat.AbbindungQ,'');
    //GetBool(Mat.DickenTolYN,'');
    //GetBool(Mat.BreitenTolYN,'');
    //GetBool(Mat.LängenTolYN,'');
    //GetBool(Mat.StehendYN,'');
    //GetBool(Mat.LiegendYN,'');
    //GetTime(Mat.QS.Zeit,'');


  if ("Mat.Löschmarker"<>'*') and
    ((Mat.Status=1) or (Mat.Status=404)) then begin
    Erx # Mat_Data:Insert(0,'AUTO',today);
    //debug(cnvAI(Erx)+'   '+cnvAI(Mat.Nummer));
  end;


  Erx # RecRead(2200,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Material wurde importiert!',0,0,0);
end;


//========================================================================

//========================================================================
//  Import_SFL
//
//========================================================================
sub Import_SFL()
local begin
  vNr   : int;
  vFile : int;
  vMax  : int;
  vPos  : int;
  vA    : alpha(4000);
  vName : alpha;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);
    WHILE (vPos<vMax) do begin

      RecBufClear(200);
      RecBufClear(240);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Mat.Werksnummer # StrCut(vA,0,16);                                                            /*1 Werksnummer*/
      FSIRead(vFile, vA);
      "Mat.Güte" # vA;                                                                              /*2 Güte*/
      FSIRead(vFile, vA);
      Mat.Breite # cnvFA(vA);                                                                       /*3 Breite*/
      FSIRead(vFile, vA);
      Mat.Dicke # cnvFA(vA);                                                                        /*4 Dicke*/
      FSIRead(vFile, vA);
      Mat.Zugfestigkeit1 # cnvFA(vA);                                                               /*5 Festigkeit untere Grenze*/
      FSIRead(vFile, vA);
      Mat.Zugfestigkeit2 # cnvFA(vA);                                                               /*6 Festigkeit obere Grenze*/
      FSIRead(vFile, vA);
      Mat.BreitenTol.Bis # cnvFA(vA); // +                                                          /*7 Breitentol +*/
      FSIRead(vFile, vA);
      Mat.BreitenTol.Von # cnvFA(vA); // -                                                          /*8 Breitentol -*/
      vA # '+'+cnvAF(Mat.BreitenTol.Bis)+'/'+'-'+cnvAF(Mat.BreitenTol.Von);
      Mat.Breitentol # StrCut(vA,0,16);
      FSIRead(vFile, vA);
      Mat.Warengruppe   # cnvIA(vA);                                                                /*9 Warengruppe*/
      FSIRead(vFile, vA);
      GV.Alpha.01 # vA;                                                                             /*10 Erlöscode*/
      FSIRead(vFile, vA);
      Mat.Lagerplatz # vA;                                                                          /*11 Stellplatz in Lagerplatz*/
      FSIRead(vFile, vA);
      Mat.Bestand.Gew # cnvFA(vA);                                                                  /*12 Bestand*/
      FSIRead(vFile, vA);
      GV.Alpha.02 # vA;                                                                             /*13 Einheit*/
      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      Mat.EK.Preis # cnvFA(vA);                                                                     /*14 EK*/
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      vNr # Lib_Nummern:ReadNummer('Material');
      if (vNr<>0) then Lib_Nummern:SaveNummer();


      Mat.Status          # 1;
      Mat.Nummer          # vNr;
      "Mat.Vorgänger"     # 0;
      Mat.Ursprung        # vNr;
      Mat.Bestand.Stk     # 1;
      Mat.Lieferant       # 1;
      Mat.Lageradresse    # 1;
      Mat.Lageranschrift  # 1;

      Mat_Data:Insert(_recunlock,'AUTO',today);

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

  end;


end;

//========================================================================

//========================================================================
//  Import_JSN
//
//========================================================================
sub Import_JSN()
local begin
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);

    Dlg_Standard:Anzahl('Lagerort ',var vAdresse,0);

    WHILE (vPos<vMax) do begin

      RecBufClear(200);
      RecBufClear(240);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      "Mat.Güte" # (vA);                                                                            /*  1 Werksnummer   */
      FSIRead(vFile, vA);
      Mat.Coilnummer # StrCut(vA,0,16);                                                             /*  2 Coilnummer    */
      FSIRead(vFile, vA);
      Mat.Ringnummer # StrCut(vA,0,16);                                                             /*  3 Ringnummer    */
      FSIRead(vFile, vA);
      Mat.Chargennummer # StrCut(vA,0,16);                                                          /*  4 Chargennummer */
      FSIRead(vFile, vA);
      Mat.Chargennummer # StrCut(vA,0,16);                                                          /*  5 Werksnummer   */
      FSIRead(vFile, vA);
      Mat.Dicke # cnvFA(vA);                                                                        /*  6 Dicke         */
      FSIRead(vFile, vA);
      Mat.Breite # cnvFA(vA);                                                                       /*  7 Breite        */
      FSIRead(vFile, vA);
      "Mat.Länge" # cnvFA(vA);                                                                      /*  8 Breite        */
      FSIRead(vFile, vA);
      Mat.Bestand.Stk # cnvIA(vA);                                                                  /* 9 Stückzahl      */
      FSIRead(vFile, vA);
      Mat.Bestand.Gew # cnvFA(vA);                                                                  /*10 Gewicht        */
      FSIRead(vFile, vA);
      Mat.Bemerkung1  # (vA);                                                                       /*11 Bemerkung 1    */

      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      Mat.Bemerkung2 # (vA);                                                                        /*12 Bemerkung 2    */
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      vNr # Lib_Nummern:ReadNummer('Material');
      if (vNr<>0) then Lib_Nummern:SaveNummer();


      Mat.Status          # 1;
      Mat.Nummer          # vNr;
      "Mat.Vorgänger"     # 0;
      Mat.Ursprung        # vNr;
      Mat.Lieferant       # 5172;
      Mat.Lageradresse    # (vAdresse);
      Mat.Lageranschrift  # 1;

      Mat_Data:Insert(_recunlock,'AUTO',today);

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

  end;


end;

//========================================================================
//========================================================================
//  Import_VSH
//
//========================================================================
sub Import_VSH()
local begin
  erx       : int;
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);

    // Dlg_Standard:Anzahl('Lagerort ',var vAdresse,0);

      // Titel überspringen!
      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

    WHILE (vPos<vMax) do begin

      RecBufClear(200);
      RecBufClear(240);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Mat.Strukturnr # vA;                                                                        /*  1 Artikelnummer   */
      FSIRead(vFile, vA);
      Mat.Coilnummer # StrCut(vA,0,16);                                                             /*  2 Coilnummer (= Kistennummer) */
      FSIRead(vFile, vA);
      "Mat.Güte" # StrCut(vA,0,16);                                                                 /*  3 Güte            */
      FSIRead(vFile, vA);
      Mat.Chargennummer # StrCut(vA,0,16);                                                          /*  4 Chargennummer */
      FSIRead(vFile, vA);
      Mat.Dicke # cnvFA(vA);                                                                        /*  6 Dicke         */
      FSIRead(vFile, vA);
      Mat.Bestand.Gew # cnvFA(vA);                                                                  /*10 Gewicht        */
      Mat.Gewicht.Netto # CnvFA(vA);


      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      Mat.Gewicht.Brutto # cnvFA(vA);                                                                        /*12 Bemerkung 2    */
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      vNr # Lib_Nummern:ReadNummer('Material');
      if (vNr<>0) then Lib_Nummern:SaveNummer();
      Erx # RecLink(250,200,26,0);
      Mat.Warengruppe # Art.Warengruppe;


      Mat.EigenmaterialYN # Y;
      "Mat.Übernahmedatum" # TODAY;
      Mat.Bestand.Stk     # 1;
      Mat.Status          # 1;
      Mat.Nummer          # vNr;
      "Mat.Vorgänger"     # 0;
      Mat.Ursprung        # vNr;
      Erx # RecLink(250,200,26,0);
      Mat.Lieferant       # 1;
      Mat.Lageradresse    # 14;
      Mat.Lageranschrift  # 2;

      Mat_Data:Insert(_recunlock,'AUTO',today);

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

  end;


end;

//========================================================================

//========================================================================
//  Import_Venus
//
//========================================================================
sub Import_Venus()
local begin
  erx       : int;
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);


    WHILE (vPos<vMax) do begin

      RecBufClear(200);
      RecBufClear(240);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Mat.Warengruppe # cnvIA(vA);                                                                  /*  1 Warengruppe        */
      FSIRead(vFile, vA);
      Mat.Strukturnr # StrCut(vA,0,20);                                                             /*  2 Artikelnummer      */
      FSIRead(vFile, vA);
      Mat.Bestand.Stk # cnvIA(vA);                                                                  /*  3 Bestand Stk        */
      FSIRead(vFile, vA);
      Mat.Coilnummer # StrCut(vA,0,16);                                                             /*  4 Coilnummer         */
      FSIRead(vFile, vA);
      Erx # StrFind(vA,'/',1);
      //Mat.Werkstoffnr # StrCut(vA,1,Erx-1);                                                         /*  5 Werkstoffnr        */
      //"Mat.Güte" # StrCut(vA,Erx+1,StrLen(vA));                                                     /*  5 Güte               */
      "Mat.Güte" # vA;                                                                                /*  5 Güte               */
      FSIRead(vFile, vA);
      Mat.Chargennummer # StrCut(vA,1,16);                                                          /*  6 Chargennummer      */
      FSIRead(vFile, vA);
      Mat.Dicke # cnvFA(vA);                                                                        /*  7 Dicke              */
      FSIRead(vFile, vA);
      Mat.Bestand.Gew # cnvFA(vA);                                                                  /*  7 Bestand Gewicht    */
      Mat.Gewicht.Netto # cnvFA(vA);                                                                /*  7 Gewicht Netto      */
      FSIRead(vFile, vA);
      Mat.Gewicht.Brutto # cnvFA(vA);                                                               /*  8 Gewicht Brutto     */
      FSIRead(vFile, vA);
      Mat.EK.Preis # cnvFA(vA);                                                                     /*  9 EK/t               */
      FSIRead(vFile, vA);                                                                           /*  9 Lieferant          */
      case vA of
        'Venus Wire' : begin
          Mat.Lieferant # 1;
        end;
        'Precision' : begin
          Mat.Lieferant # 2;
        end;
      end;

      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);                                                                           /* 10 Lagerort      */
      case vA of
        'Atege' : begin
          Mat.Lageradresse # 14;
        end;
        'Capilla' : begin
          Mat.Lageradresse # 455;
        end;
      end;
      //letzter
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      vNr # Lib_Nummern:ReadNummer('Material');
      if (vNr<>0) then
        Lib_Nummern:SaveNummer();

      Mat.EigenmaterialYN  # true;
      "Mat.Übernahmedatum" # today;
      Mat.Eingangsdatum    # today
      Mat.Status           # 1;
      Mat.Nummer           # vNr;
      "Mat.Vorgänger"      # 0;
      Mat.Ursprung         # vNr;
      Mat.Lageranschrift   # 1;

      Mat_Data:Insert(_recunlock,'AUTO',today);

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

  end;

end;

//========================================================================
//  call Import_Mat:Import_MTD
//
//========================================================================
sub Import_MTD()
local begin
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
  vAFOben   : alpha;
  vAFUnten  : alpha;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);


    WHILE (vPos<vMax) do begin
      TRANSON;

      RecBufClear(200);
      RecBufClear(240);

      FSIMark(vFile, 59); /* ; */
      FSIRead(vFile, vA); /* Eingangsdatum */
      Mat.Eingangsdatum    # cnvDA(vA);

      FSIRead(vFile, vA); /* WGr. */
      Mat.Warengruppe # cnvIA(vA);

      FSIRead(vFile, vA); /* Qualität */
      "Mat.Güte" # vA;

      FSIRead(vFile, vA); /* Dicke */
      Mat.Dicke # cnvFA(vA);

      FSIRead(vFile, vA); /* Breite */
      Mat.Breite # cnvFA(vA);

      FSIRead(vFile, vA); /* Länge */
      "Mat.Länge" # cnvFA(vA);

      FSIRead(vFile, vA); /* Stk */
      Mat.Bestand.Stk # cnvIA(vA);

      FSIRead(vFile, vA); /* Bestand kg */
      Mat.Bestand.Gew # cnvFA(vA);

      FSIRead(vFile, vA); /* AF oben */
      vAFOben # vA;

      FSIRead(vFile, vA); /* alte BestellNr */
      Mat.Bestellnummer # vA;

      FSIRead(vFile, vA); /* EK €/t */
      Mat.EK.Preis # cnvFA(vA);

      FSIRead(vFile, vA); /* Lieferant */
      Mat.Lieferant # cnvIA(vA);

      FSIRead(vFile, vA); /* Erzeuger */
      Mat.Erzeuger  # cnvIA(vA);

      FSIRead(vFile, vA); /* Ursprungsland */
      Mat.Ursprungsland # vA;

      FSIRead(vFile, vA); /* EK Steuerschl. */
      GV.Alpha.50 # vA;

      FSIRead(vFile, vA); /* Lagerort */
      Mat.Lageradresse # cnvIA(vA);

      FSIRead(vFile, vA); /* Adresse */
      Mat.Lageranschrift # cnvIA(vA);

      FSIRead(vFile, vA); /* Lagerplatz */
      Mat.Lagerplatz # vA;

      FSIRead(vFile, vA); /* Zeugnisart */
      Mat.Zeugnisart # vA;

      FSIRead(vFile, vA); /* AF unten */
      vAFUnten # vA;

      FSIRead(vFile, vA); /* Bemerkung 1 */
      Mat.Bemerkung1  # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 72);

      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA); /* Bemerkung 2 */
      Mat.Bemerkung2  # Str_ReplaceAll((StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 72)), ';', '');
      //letzter

      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      vNr # Lib_Nummern:ReadNummer('Material');
      if (vNr<>0) then
        Lib_Nummern:SaveNummer();

      Mat.EigenmaterialYN  # true;
      "Mat.Übernahmedatum" # today;
      Mat.Datum.Erzeugt    # today;
      Mat.Status           # 1;
      Mat.Nummer           # vNr;
      "Mat.Vorgänger"      # 0;
      Mat.Ursprung         # vNr;
      Mat.Lageranschrift   # 1;

      if(Import_Mat:InsertAF(vAFOben, '1', ',') = false) then begin
        TRANSBRK;
        vPos # FsiSeek(vFile);
        CYCLE;
      end
      "Mat.AusführungOben" #   Obf_Data:BildeAFString(200,'1');

      if(Import_Mat:InsertAF(vAFUnten,'2', ',') = false) then begin
        TRANSBRK;
        vPos # FsiSeek(vFile);
        CYCLE;
      end;
      "Mat.AusführungUnten" #   Obf_Data:BildeAFString(200,'2');

      Mat_Data:Insert(_recunlock,'AUTO',today);

      vPos # FsiSeek(vFile);

      TRANSOFF;
    END;

    FSIClose(vFile);

  end;


end;

//========================================================================

//========================================================================
//  call Import_Mat:Import_OWF
//
//  xGetAlphaUp
//  xGetAlpha
//  GetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime3
//========================================================================
sub Import_OWF()
local begin
  Erx       : int;
  Ansprechpartner : int;
end;
begin


  Erx # RecRead(200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Mat.Bestellt.Gew<=0.0) or (Mat.Status<>500) then begin
      if (Mat_Data:Delete(_rnolock,'AUTO')<>_rOK) then TODO('ERROR');
      Erx # RecRead(200,1,0);
      Erx # RecRead(200,1,0);
      end
    else begin
      Erx # RecRead(200,1,_recNext);
    end;

  END;

  //RETURN;



  Erx # DBAConnect(2, 'X_', 'TCP:130.100.100.186', 'StahlControl', 'thomas', 'ares', '');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  FOR Erx # RecRead(2200,1,_recFirst);
  LOOP Erx # RecRead(2200,1,_recNext);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(200);
    RecBufClear(240);


    xGetWord(Mat.Status,'Mat.Status');
    if ((Mat.Status < 1) or (Mat.Status > 5)) then // NUR STATUS 1 - 5
      CYCLE;

    xGetAlpha("Mat.Löschmarker", 'Mat.Löschmarker'); // kein gelöschtes Mat.
    if ("Mat.Löschmarker" = '*') then
      CYCLE;

    Mat.Lageranschrift # 1;
    "Mat.Vorgänger"    # 0;

    xGetAlpha(GV.Alpha.48,'Mat.Ursprungsland');

    case GV.Alpha.48 of
      'Deutschland'         : Mat.Ursprungsland # 'D';
      'Italien'             : Mat.Ursprungsland # 'I';
      'Österreich'          : Mat.Ursprungsland # 'A';
      'Belgien'             : Mat.Ursprungsland # 'B';
      'Brasilien'           : Mat.Ursprungsland # 'BR';
      'Schweiz'             : Mat.Ursprungsland # 'CH';
      'Tschechien'          : Mat.Ursprungsland # 'CH';
      'Dänemark'            : Mat.Ursprungsland # 'DK';
      'Spanien'             : Mat.Ursprungsland # 'ESP';
      'Frankreich'          : Mat.Ursprungsland # 'F';
      'Griechenland'        : Mat.Ursprungsland # 'GR';
      'Niederlande'         : Mat.Ursprungsland # 'NL';
      'Polen'               : Mat.Ursprungsland # 'PL';
      'Südafrika'           : Mat.Ursprungsland # 'RS';
      'Russland'            : Mat.Ursprungsland # 'RU';
      'Vereinigten Staaten' : Mat.Ursprungsland # 'US';
    end;


    xGetInt(GV.Int.02, 'Mat.Lagerort');
    // Umsetzen Lieferantennr->Adressnummer
    Adr.Lieferantennr # GV.Int.02;
    Erx # RecRead(100, 3, 0);   // Lieferanten holen
    if(Erx > _rMultiKey) then
      RecBufClear(100);

    Mat.Lageradresse # Adr.Nummer;

    xGetInt(Mat.Nummer,'Mat.Nummer');
    xGetInt(Mat.Ursprung,'Mat.Nummer');
    xGetInt(Mat.Bestand.Stk,'Mat.Bestand.Stk');
    xGetInt(Mat.Bestellt.Stk,'Mat.Bestellt.Stk');
    xGetInt(Mat.Reserviert.Stk,'Mat.Reserviert.Stk');
    xGetInt("Mat.Verfügbar.Stk",'Mat.Verfügbar.Stk');
//    GetInt(Mat.Paketnr,'Mat.Paketnummer');
    xGetInt(Mat.Erzeuger,'Mat.Erzeuger');
    xGetInt(Mat.Lieferant,'Mat.Lieferant');
//    GetInt(Mat.Analysenummer,'Mat.Analysenummer');
    xGetAlpha("Mat.Güte",'Mat.Qualität');
    xGetAlpha(Mat.Werkstoffnr,'Mat.Werkstoffnummer');
    xGetAlpha(Mat.Coilnummer,'Mat.Coilnummer');
    xGetAlpha(Mat.Ringnummer,'Mat.Tafelnummer');
    xGetAlpha(Mat.Chargennummer,'Mat.Chargennummer');
    xGetAlpha(Mat.Werksnummer,'Mat.Werksnummer');
    xGetAlpha(Mat.DickenTol,'Mat.Dickentoleranz');
    xGetAlpha(Mat.BreitenTol,'Mat.Breitentoleranz');
    xGetAlpha("Mat.LängenTol",'Mat.Längentoleranz');
    xGetAlpha(Mat.Zeugnisart,'Mat.Zeugnisart');
    xGetAlpha(Mat.Zeugnisakte,'Mat.Zeugnisakte')
    //xGetAlpha(Mat.Kommission,'Mat.Kommission');;
    xGetAlpha(Mat.Bemerkung1,'Mat.Bemerkung1');
    xGetAlpha(Mat.Bemerkung2,'Mat.Bemerkung2');
    xGetAlpha(Mat.Bestellnummer,'Mat.Bestellnummer');
    xGetAlpha(Mat.BestellABNr,'Mat.LiefBestnr');
    xGetAlpha(Mat.Lagerplatz,'Mat.Lagerplatz');
    xGetNum(Mat.Dicke,'Mat.Dicke');
    xGetNum(Mat.Dicke.Von,'Mat.ZehnerprobeVon');
    xGetNum(Mat.Dicke.Bis,'Mat.ZehnerprobeBis');
    xGetNum(Mat.Breite,'Mat.Breite');
  //  GetNum(Mat.Breite.Von,'Mat.Breite2');
  //  GetNum(Mat.Breite.Bis,'Mat.Breite3');
    xGetNum("Mat.Länge",'Mat.Länge');
    xGetNum(Mat.RID,'Mat.Innendurchm');
    xGetNum(Mat.RAD,'Mat.Außendurchm');
    xGetNum(Mat.Dichte,'Mat.Dichte');
    xGetNum(Mat.Kgmm,'Mat.Kgmm');
    xGetNum(Mat.Bestand.Gew,'Mat.Bestand.Gew');
    xGetNum(Mat.Bestellt.Gew,'Mat.Bestellt.Gew');
    xGetNum(Mat.Reserviert.Gew,'Mat.Reserviert.Gew');
    xGetNum("Mat.Verfügbar.Gew",'Mat.Verfügbar.Gew');
    xGetNum(Mat.EK.Preis,'Mat.EK-effektiv');
    //GetNum(Mat.EK.Preis,'Mat.EK-Preis');
    //GetNum(Mat.Kosten,'Mat.VK-Preis');
    //GetNum(Mat.EK.Effektiv,'Mat.EK-effektiv');
    //xGetNum(Mat.Gewicht.Netto,'Mat.Gewicht.Netto');
    xGetNum(Mat.Gewicht.Brutto,'Mat.Gewicht.Brutto');
    xGetDate("Mat.Übernahmedatum",'Mat.Übernahmedatum');
    xGetDate(Mat.Bestelldatum,'Mat.Bestelldatum');
    xGetDate(Mat.BestellTermin,'Mat.Termin');
    xGetDate(Mat.Eingangsdatum,'Mat.Eingangsdatum');
    xGetDate(Mat.Ausgangsdatum,'Mat.Ausgangsdatum');
    xGetDate(Mat.Inventurdatum,'Mat.Inventurdatum');
    xGetWord(Mat.Warengruppe,'Mat.Warengruppe');
    GetBool(Mat.EigenmaterialYN,'Mat.Eigenmaterial');

    //==============Analyse=====================================
    xGetAlpha(GV.Alpha.01,'Mat.Gem.Streckgrenze');
    xGetAlpha(GV.Alpha.02,'Mat.Gem.Festigkeit');
    xGetAlpha(GV.Alpha.03,'Mat.Gem.Dehnung1');
    xGetAlpha(GV.Alpha.04,'Mat.Gem.Dehnung2');
    xGetAlpha(GV.Alpha.05,'Mat.Gem.Wert01'); //C
    xGetAlpha(GV.Alpha.06,'Mat.Gem.Wert02'); //Si
    xGetAlpha(GV.Alpha.07,'Mat.Gem.Wert03'); //Mn
    xGetAlpha(GV.Alpha.08,'Mat.Gem.Wert04'); //P
    xGetAlpha(GV.Alpha.09,'Mat.Gem.Wert05'); //S
    xGetAlpha(GV.Alpha.10,'Mat.Gem.Wert06'); //Al
    xGetAlpha(GV.Alpha.11,'Mat.Gem.Wert07'); //Cr
    xGetAlpha(GV.Alpha.12,'Mat.Gem.Wert08'); //V
    xGetAlpha(GV.Alpha.13,'Mat.Gem.Wert09'); //Nb
    xGetAlpha(GV.Alpha.14,'Mat.Gem.Wert10'); //Ti
    xGetAlpha(GV.Alpha.15,'Mat.Gem.Wert11'); //N
    xGetAlpha(GV.Alpha.16,'Mat.Gem.Wert12'); //Cu
    xGetAlpha(GV.Alpha.17,'Mat.Gem.Wert13'); //Ni
    xGetAlpha(GV.Alpha.18,'Mat.Gem.Wert14'); //Mo
    xGetAlpha(GV.Alpha.19,'Mat.Gem.Wert15'); //W
    xGetAlpha(GV.Alpha.20,'Mat.Gem.Wert16'); //Pb
    xGetAlpha(GV.Alpha.21,'Mat.Att.Streckgrenze');
    xGetAlpha(GV.Alpha.22,'Mat.Att.Festigkeit');
    xGetAlpha(GV.Alpha.23,'Mat.Att.Dehnung1');
    xGetAlpha(GV.Alpha.24,'Mat.Att.Dehnung2');
    xGetAlpha(GV.Alpha.25,'Mat.Att.Wert01'); //C
    xGetAlpha(GV.Alpha.26,'Mat.Att.Wert02'); //Si
    xGetAlpha(GV.Alpha.27,'Mat.Att.Wert03'); //Mn
    xGetAlpha(GV.Alpha.28,'Mat.Att.Wert04'); //P
    xGetAlpha(GV.Alpha.29,'Mat.Att.Wert05'); //S
    xGetAlpha(GV.Alpha.30,'Mat.Att.Wert06'); //Al
    xGetAlpha(GV.Alpha.31,'Mat.Att.Wert07'); //Cr
    xGetAlpha(GV.Alpha.32,'Mat.Att.Wert08'); //V
    xGetAlpha(GV.Alpha.33,'Mat.Att.Wert09'); //Nb
    xGetAlpha(GV.Alpha.34,'Mat.Att.Wert10'); //Ti
    xGetAlpha(GV.Alpha.35,'Mat.Att.Wert11'); //N
    xGetAlpha(GV.Alpha.36,'Mat.Att.Wert12'); //Cu
    xGetAlpha(GV.Alpha.37,'Mat.Att.Wert13'); //Ni
    xGetAlpha(GV.Alpha.38,'Mat.Att.Wert14'); //Mo
    xGetAlpha(GV.Alpha.39,'Mat.Att.Wert15'); //W
    xGetAlpha(GV.Alpha.40,'Mat.Att.Wert16'); //Pb

    xGetAlpha(GV.Alpha.41,'Mat.Gem.Dehngrenze02');
    xGetAlpha(GV.Alpha.42,'Mat.Gem.Dehngrenze10');
    xGetAlpha(GV.Alpha.43,'Mat.Gem.Korngröße');

    xGetAlpha(GV.Alpha.45,'Mat.Att.Dehngrenze02');
    xGetAlpha(GV.Alpha.46,'Mat.Att.Dehngrenze10');
    xGetAlpha(GV.Alpha.47,'Mat.Att.Korngröße');

    xGetAlpha(Mat.Mech.Sonstiges1, 'Mat.Gem.Zusatz');
    xGetAlpha(Mat.Mech.Sonstiges2, 'Mat.Att.Zusatz');

    // Format-Konvertierungen...
    Mat.Streckgrenze1     # CnvFA(Gv.Alpha.01);
    Mat.Zugfestigkeit1    # CnvFA(Gv.Alpha.02);
    Mat.DehnungA1         # CnvFA(Gv.Alpha.03);
    Mat.DehnungB1         # CnvFA(Gv.Alpha.04);

    Mat.Chemie.C1         # CnvFA(Gv.Alpha.05);
    Mat.Chemie.Si1        # CnvFA(Gv.Alpha.06);
    Mat.Chemie.Mn1        # CnvFA(Gv.Alpha.07);
    Mat.Chemie.P1         # CnvFA(Gv.Alpha.08);
    Mat.Chemie.S1         # CnvFA(Gv.Alpha.09);
    Mat.Chemie.Al1        # CnvFA(Gv.Alpha.10);
    Mat.Chemie.Cr1        # CnvFA(Gv.Alpha.11);
    Mat.Chemie.V1         # CnvFA(Gv.Alpha.12);
    Mat.Chemie.Nb1        # CnvFA(Gv.Alpha.13);
    Mat.Chemie.Ti1        # CnvFA(Gv.Alpha.14);
    Mat.Chemie.N1         # CnvFA(Gv.Alpha.15); // Co
    Mat.Chemie.Cu1        # CnvFA(Gv.Alpha.16);
    Mat.Chemie.Ni1        # CnvFA(Gv.Alpha.17);
    Mat.Chemie.Mo1        # CnvFA(Gv.Alpha.18);
    Mat.Chemie.B1         # CnvFA(Gv.Alpha.19); // W
    Mat.Chemie.Frei1.1    # CnvFA(Gv.Alpha.20); // Pb

    Mat.Streckgrenze2     # CnvFA(Gv.Alpha.21);
    Mat.Zugfestigkeit2    # CnvFA(Gv.Alpha.22);
    Mat.DehnungA2         # CnvFA(Gv.Alpha.23);
    Mat.DehnungB2         # CnvFA(Gv.Alpha.24);

    Mat.Chemie.C2         # CnvFA(Gv.Alpha.25);
    Mat.Chemie.Si2        # CnvFA(Gv.Alpha.26);
    Mat.Chemie.Mn2        # CnvFA(Gv.Alpha.27);
    Mat.Chemie.P2         # CnvFA(Gv.Alpha.28);
    Mat.Chemie.S2         # CnvFA(Gv.Alpha.29);
    Mat.Chemie.Al2        # CnvFA(Gv.Alpha.30);
    Mat.Chemie.Cr2        # CnvFA(Gv.Alpha.31);
    Mat.Chemie.V2         # CnvFA(Gv.Alpha.32);
    Mat.Chemie.Nb2        # CnvFA(Gv.Alpha.33);
    Mat.Chemie.Ti2        # CnvFA(Gv.Alpha.34);
    Mat.Chemie.N2         # CnvFA(Gv.Alpha.35); // Co
    Mat.Chemie.Cu2        # CnvFA(Gv.Alpha.36);
    Mat.Chemie.Ni2        # CnvFA(Gv.Alpha.37);
    Mat.Chemie.Mo2        # CnvFA(Gv.Alpha.38);
    Mat.Chemie.B2         # CnvFA(Gv.Alpha.39); // W
    Mat.Chemie.Frei1.2    # CnvFA(Gv.Alpha.40); // Pb

    Mat.RP02_V1           # CnvFA(Gv.Alpha.41);
    Mat.RP10_V1           # CnvFA(Gv.Alpha.42);
    "Mat.Körnung1"        # CnvFA(Gv.Alpha.43);

    Mat.RP02_V2           # CnvFA(Gv.Alpha.45);
    Mat.RP10_V2           # CnvFA(Gv.Alpha.46);
    "Mat.Körnung2"        # CnvFA(Gv.Alpha.47);
    //==========================================================

    //GetInt(Mat.KommKundennr,'');
    //xGetInt(Mat.VK.Kundennr,'');
    //xGetInt(Mat.VK.Rechnr,'');
    //xGetInt(Mat.EK.RechNr,'');
    //xGetInt(Mat.Auftragsnr,'');
    //xGetInt(Mat.Einkaufsnr,'');
    //xGetAlpha(Mat.Gütenstufe,'');
    //xGetAlpha(Mat.AusführungUnten,'');
    //xGetAlpha(Mat.Strukturnr,'');
    //xGetAlpha(Mat.Intrastatnr,'');
    //xGetAlpha(Mat.KommKundenSWort,'');
    //xGetAlpha(Mat.LieferStichwort,'');
    //xGetAlpha(Mat.LagerStichwort,'');
    //xGetAlpha(Mat.QS.User,'');
    //xGetAlpha(Mat.Zwischenlage,'');
    //xGetAlpha(Mat.Unterlage,'');
    //GetNum(Mat.DickenTol.Von,'');
    //GetNum(Mat.DickenTol.Bis,'');
    //GetNum(Mat.BreitenTol.Von,'');
    //GetNum(Mat.BreitenTol.Bis,'');
    //GetNum(Mat.Länge.Von,'');
    //GetNum(Mat.Länge.Bis,'');
    //GetNum(Mat.LängenTol.Von,'');
    //GetNum(Mat.LängenTol.Bis,'');
    //GetNum(Mat.VK.Preis,'');
    //GetNum(Mat.VK.Gewicht,'');
    //GetNum(Mat.Nettoabzug,'');
    //GetNum(Mat.Stapelhöhe,'');
    //GetNum(Mat.Stapelhöhenabzug,'');
    //GetNum(Mat.Rechtwinkligkeit,'');
    //GetNum(Mat.Ebenheit,'');
    //GetNum(Mat.Säbeligkeit,'');
    //GetNum(Mat.Etk.Dicke,'');
    //GetNum(Mat.Etk.Breite,'');
    //GetNum(Mat.Etk.Länge,'');
    //GetDate(Mat.QS.Datum,'');
    //GetDate(Mat.VK.Rechdatum,'');
    //GetDate(Mat.EK.RechDatum,'');
    //GetWord(Mat.Auftragspos,'');
    //GetWord(Mat.Einkaufspos,'');
    //GetWord(Mat.QS.Status,'');
    //GetWord(Mat.Verwiegungsart,'');
    //GetWord(Mat.AbbindungL,'');
    //GetWord(Mat.AbbindungQ,'');
    //GetBool(Mat.DickenTolYN,'');
    //GetBool(Mat.BreitenTolYN,'');
    //GetBool(Mat.LängenTolYN,'');
    //GetBool(Mat.StehendYN,'');
    //GetBool(Mat.LiegendYN,'');
    //GetTime(Mat.QS.Zeit,'');

    Mat.Gewicht.Netto # Mat.Gewicht.Brutto; // laut Prj. 1270/49

    xGetWord(GV.Ints.01,'Mat.Oberfläche');    //Mat.AusführungOben

    Import_Mat:InsertAFByNumber(GV.Ints.01, '1');
    "Mat.AusführungOben" # Obf_Data:BildeAFString(200, '1');

    if ("Mat.Löschmarker" <> '*') and
      ((Mat.Status >=1) or (Mat.Status <= 5)) then begin
      Erx # Mat_Data:Insert(0, 'AUTO', today);
      //debug(cnvAI(Erx)+'   '+cnvAI(Mat.Nummer));
    end;

  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Material wurde importiert!',0,0,0);
end;

//========================================================================
//  call Import_Mat:Import_FMB
//
//  xGetAlphaUp
//  xGetAlpha
//  GetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime3
//========================================================================
sub Import_FMB()
local begin
  erx   : int;
  Ansprechpartner : int;
  vObf            : int;
  vNr             : int;
end;
begin

  /* bestehendes Material nicht loeschen fuer ECHTIMPORT
  Erx # RecRead(200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (true) or (Mat.Bestellt.Gew<=0.0) or (Mat.Status<>500) then begin
      if (Mat_Data:Delete(_rnolock,'AUTO')<>_rOK) then TODO('ERROR');
      Erx # RecRead(200,1,0);
      Erx # RecRead(200,1,0);
      end
    else begin
      Erx # RecRead(200,1,_recNext);
    end;
  END;
  */
  //RETURN;

  Erx # DBAConnect(2, 'X_', 'TCP:192.168.0.2', 'Ferro_Alt', 'thomas', '', '');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  FOR Erx # RecRead(2200,1,_recFirst);
  LOOP Erx # RecRead(2200,1,_recNext);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(200);
    RecBufClear(240);

    xGetWord(Mat.Status,'Mat.Status');
    if ((Mat.Status < 1) or (Mat.Status > 5)) then // NUR STATUS 1 - 5
      CYCLE;

    xGetAlpha("Mat.Löschmarker", 'Mat.Löschmarker'); // kein gelöschtes Mat.
    if ("Mat.Löschmarker" = '*') then
      CYCLE;

    if(Mat.Status = 5) then // Status 5 immer auf 1 umsetzen
      Mat.Status # 1;

    Mat.Lageranschrift # 1;
    "Mat.Vorgänger"    # 0;

    xGetAlpha(GV.Alpha.48,'Mat.Ursprungsland');

    case GV.Alpha.48 of
      'Deutschland'         : Mat.Ursprungsland # 'D';
      'Italien'             : Mat.Ursprungsland # 'I';
      'Österreich'          : Mat.Ursprungsland # 'A';
      'Belgien'             : Mat.Ursprungsland # 'B';
      'Brasilien'           : Mat.Ursprungsland # 'BR';
      'Schweiz'             : Mat.Ursprungsland # 'CH';
      'Tschechien'          : Mat.Ursprungsland # 'CH';
      'Dänemark'            : Mat.Ursprungsland # 'DK';
      'Spanien'             : Mat.Ursprungsland # 'ESP';
      'Frankreich'          : Mat.Ursprungsland # 'F';
      'Griechenland'        : Mat.Ursprungsland # 'GR';
      'Niederlande'         : Mat.Ursprungsland # 'NL';
      'Polen'               : Mat.Ursprungsland # 'PL';
      'Südafrika'           : Mat.Ursprungsland # 'RS';
      'Russland'            : Mat.Ursprungsland # 'RU';
      'Vereinigten Staaten' : Mat.Ursprungsland # 'US';
    end;


    xGetInt(GV.Int.02, 'Mat.Lagerort');
    // Umsetzen Lieferantennr->Adressnummer
    Adr.Lieferantennr # GV.Int.02;
    Erx # RecRead(100, 3, 0);   // Lieferanten holen
    if(Erx > _rMultiKey) then
      RecBufClear(100);

    Mat.Lageradresse # Adr.Nummer;

    Mat.EK.Projektnr # cnvIA(GetAlphaMAX('Mat.Bezeichnung3', 20)); // Bezeichnung 3 = Prj.Nr im Altsys

    xGetInt(Mat.Nummer,'Mat.Nummer');
    xGetInt(Mat.Ursprung,'Mat.Nummer');
    xGetInt(Mat.Bestand.Stk,'Mat.Bestand.Stk');
    xGetInt(Mat.Bestellt.Stk,'Mat.Bestellt.Stk');
    xGetInt(Mat.Reserviert.Stk,'Mat.Reserviert.Stk');
    xGetInt("Mat.Verfügbar.Stk",'Mat.Verfügbar.Stk');
//    GetInt(Mat.Paketnr,'Mat.Paketnummer');
    xGetInt(Mat.Erzeuger,'Mat.Erzeuger');
    xGetInt(Mat.Lieferant,'Mat.Lieferant');
//    GetInt(Mat.Analysenummer,'Mat.Analysenummer');
    xGetAlpha("Mat.Güte",'Mat.Qualität');
    xGetAlpha(Mat.Werkstoffnr,'Mat.Werkstoffnummer');
    xGetAlpha(Mat.Coilnummer,'Mat.Coilnummer');
    xGetAlpha(Mat.Ringnummer,'Mat.Tafelnummer');
    xGetAlpha(Mat.Chargennummer,'Mat.Chargennummer');
    xGetAlpha(Mat.Werksnummer,'Mat.Werksnummer');
    xGetAlpha(Mat.DickenTol,'Mat.Dickentoleranz');
    xGetAlpha(Mat.BreitenTol,'Mat.Breitentoleranz');
    xGetAlpha("Mat.LängenTol",'Mat.Längentoleranz');
    xGetAlpha(Mat.Zeugnisart,'Mat.Zeugnisart');
    xGetAlpha(Mat.Zeugnisakte,'Mat.Zeugnisakte')
    //xGetAlpha(Mat.Kommission,'Mat.Kommission');;
    xGetAlpha(Mat.Bemerkung1,'Mat.Bemerkung1');
    xGetAlpha(Mat.Bemerkung2,'Mat.Bemerkung2');
    xGetAlpha(Mat.Bestellnummer,'Mat.Bestellnummer');
    xGetAlpha(Mat.BestellABNr,'Mat.LiefBestnr');
    xGetAlpha(Mat.Lagerplatz,'Mat.Lagerplatz');
    xGetNum(Mat.Dicke,'Mat.Dicke');
    xGetNum(Mat.Dicke.Von,'Mat.ZehnerprobeVon');
    xGetNum(Mat.Dicke.Bis,'Mat.ZehnerprobeBis');
    xGetNum(Mat.Breite,'Mat.Breite');
  //  GetNum(Mat.Breite.Von,'Mat.Breite2');
  //  GetNum(Mat.Breite.Bis,'Mat.Breite3');
    xGetNum("Mat.Länge",'Mat.Länge');
    xGetNum(Mat.RID,'Mat.Innendurchm');
    xGetNum(Mat.RAD,'Mat.Außendurchm');
    xGetNum(Mat.Dichte,'Mat.Dichte');
    xGetNum(Mat.Kgmm,'Mat.Kgmm');
    xGetNum(Mat.Bestand.Gew,'Mat.Bestand.Gew');
    xGetNum(Mat.Bestellt.Gew,'Mat.Bestellt.Gew');
    xGetNum(Mat.Reserviert.Gew,'Mat.Reserviert.Gew');
    xGetNum("Mat.Verfügbar.Gew",'Mat.Verfügbar.Gew');
    xGetNum(Mat.EK.Preis,'Mat.EK-effektiv');
    //GetNum(Mat.EK.Preis,'Mat.EK-Preis');
    //GetNum(Mat.Kosten,'Mat.VK-Preis');
    //GetNum(Mat.EK.Effektiv,'Mat.EK-effektiv');
    xGetNum(Mat.Gewicht.Netto,'Mat.Gewicht.Netto');
    xGetNum(Mat.Gewicht.Brutto,'Mat.Gewicht.Brutto');
    xGetDate("Mat.Übernahmedatum",'Mat.Übernahmedatum');
    xGetDate(Mat.Bestelldatum,'Mat.Bestelldatum');
    xGetDate(Mat.BestellTermin,'Mat.Termin');
    xGetDate(Mat.Eingangsdatum,'Mat.Eingangsdatum');
    xGetDate(Mat.Ausgangsdatum,'Mat.Ausgangsdatum');
    xGetDate(Mat.Inventurdatum,'Mat.Inventurdatum');
    xGetWord(Mat.Warengruppe,'Mat.Warengruppe');
    GetBool(Mat.EigenmaterialYN,'Mat.Eigenmaterial');

    //==============Analyse=====================================
    xGetAlpha(GV.Alpha.01,'Mat.Gem.Streckgrenze');
    xGetAlpha(GV.Alpha.02,'Mat.Gem.Festigkeit');
    xGetAlpha(GV.Alpha.03,'Mat.Gem.Dehnung1');
    xGetAlpha(GV.Alpha.04,'Mat.Gem.Dehnung2');
    xGetAlpha(GV.Alpha.05,'Mat.Gem.Wert01'); //C
    xGetAlpha(GV.Alpha.06,'Mat.Gem.Wert02'); //Si
    xGetAlpha(GV.Alpha.07,'Mat.Gem.Wert03'); //Mn
    xGetAlpha(GV.Alpha.08,'Mat.Gem.Wert04'); //P
    xGetAlpha(GV.Alpha.09,'Mat.Gem.Wert05'); //S
    xGetAlpha(GV.Alpha.10,'Mat.Gem.Wert06'); //Al
    xGetAlpha(GV.Alpha.11,'Mat.Gem.Wert07'); //Cr
    xGetAlpha(GV.Alpha.12,'Mat.Gem.Wert08'); //V
    xGetAlpha(GV.Alpha.13,'Mat.Gem.Wert09'); //Nb
    xGetAlpha(GV.Alpha.14,'Mat.Gem.Wert10'); //Ti
    xGetAlpha(GV.Alpha.15,'Mat.Gem.Wert11'); //N
    xGetAlpha(GV.Alpha.16,'Mat.Gem.Wert12'); //Cu
    xGetAlpha(GV.Alpha.17,'Mat.Gem.Wert13'); //Ni
    xGetAlpha(GV.Alpha.18,'Mat.Gem.Wert14'); //Mo
    xGetAlpha(GV.Alpha.19,'Mat.Gem.Wert15'); //W
    xGetAlpha(GV.Alpha.20,'Mat.Gem.Wert16'); //Pb
    xGetAlpha(GV.Alpha.21,'Mat.Att.Streckgrenze');
    xGetAlpha(GV.Alpha.22,'Mat.Att.Festigkeit');
    xGetAlpha(GV.Alpha.23,'Mat.Att.Dehnung1');
    xGetAlpha(GV.Alpha.24,'Mat.Att.Dehnung2');
    xGetAlpha(GV.Alpha.25,'Mat.Att.Wert01'); //C
    xGetAlpha(GV.Alpha.26,'Mat.Att.Wert02'); //Si
    xGetAlpha(GV.Alpha.27,'Mat.Att.Wert03'); //Mn
    xGetAlpha(GV.Alpha.28,'Mat.Att.Wert04'); //P
    xGetAlpha(GV.Alpha.29,'Mat.Att.Wert05'); //S
    xGetAlpha(GV.Alpha.30,'Mat.Att.Wert06'); //Al
    xGetAlpha(GV.Alpha.31,'Mat.Att.Wert07'); //Cr
    xGetAlpha(GV.Alpha.32,'Mat.Att.Wert08'); //V
    xGetAlpha(GV.Alpha.33,'Mat.Att.Wert09'); //Nb
    xGetAlpha(GV.Alpha.34,'Mat.Att.Wert10'); //Ti
    xGetAlpha(GV.Alpha.35,'Mat.Att.Wert11'); //N
    xGetAlpha(GV.Alpha.36,'Mat.Att.Wert12'); //Cu
    xGetAlpha(GV.Alpha.37,'Mat.Att.Wert13'); //Ni
    xGetAlpha(GV.Alpha.38,'Mat.Att.Wert14'); //Mo
    xGetAlpha(GV.Alpha.39,'Mat.Att.Wert15'); //W
    xGetAlpha(GV.Alpha.40,'Mat.Att.Wert16'); //Pb

    xGetAlpha(GV.Alpha.41,'Mat.Gem.Dehngrenze02');
    xGetAlpha(GV.Alpha.42,'Mat.Gem.Dehngrenze10');
    xGetAlpha(GV.Alpha.43,'Mat.Gem.Korngröße');

    xGetAlpha(GV.Alpha.45,'Mat.Att.Dehngrenze02');
    xGetAlpha(GV.Alpha.46,'Mat.Att.Dehngrenze10');
    xGetAlpha(GV.Alpha.47,'Mat.Att.Korngröße');

    xGetAlpha(Mat.Mech.Sonstiges1, 'Mat.Gem.Zusatz');
    xGetAlpha(Mat.Mech.Sonstiges2, 'Mat.Att.Zusatz');

    // Format-Konvertierungen...
    Mat.Streckgrenze1     # CnvFA(Gv.Alpha.01);
    Mat.Zugfestigkeit1    # CnvFA(Gv.Alpha.02);
    Mat.DehnungA1         # CnvFA(Gv.Alpha.03);
    Mat.DehnungB1         # CnvFA(Gv.Alpha.04);

    Mat.Chemie.C1         # CnvFA(Gv.Alpha.05);
    Mat.Chemie.Si1        # CnvFA(Gv.Alpha.06);
    Mat.Chemie.Mn1        # CnvFA(Gv.Alpha.07);
    Mat.Chemie.P1         # CnvFA(Gv.Alpha.08);
    Mat.Chemie.S1         # CnvFA(Gv.Alpha.09);
    Mat.Chemie.Al1        # CnvFA(Gv.Alpha.10);
    Mat.Chemie.Cr1        # CnvFA(Gv.Alpha.11);
    Mat.Chemie.V1         # CnvFA(Gv.Alpha.12);
    Mat.Chemie.Nb1        # CnvFA(Gv.Alpha.13);
    Mat.Chemie.Ti1        # CnvFA(Gv.Alpha.14);
    Mat.Chemie.N1         # CnvFA(Gv.Alpha.15); // Co
    Mat.Chemie.Cu1        # CnvFA(Gv.Alpha.16);
    Mat.Chemie.Ni1        # CnvFA(Gv.Alpha.17);
    Mat.Chemie.Mo1        # CnvFA(Gv.Alpha.18);
    Mat.Chemie.B1         # CnvFA(Gv.Alpha.19); // W
    Mat.Chemie.Frei1.1    # CnvFA(Gv.Alpha.20); // Pb

    Mat.Streckgrenze2     # CnvFA(Gv.Alpha.21);
    Mat.Zugfestigkeit2    # CnvFA(Gv.Alpha.22);
    Mat.DehnungA2         # CnvFA(Gv.Alpha.23);
    Mat.DehnungB2         # CnvFA(Gv.Alpha.24);

    Mat.Chemie.C2         # CnvFA(Gv.Alpha.25);
    Mat.Chemie.Si2        # CnvFA(Gv.Alpha.26);
    Mat.Chemie.Mn2        # CnvFA(Gv.Alpha.27);
    Mat.Chemie.P2         # CnvFA(Gv.Alpha.28);
    Mat.Chemie.S2         # CnvFA(Gv.Alpha.29);
    Mat.Chemie.Al2        # CnvFA(Gv.Alpha.30);
    Mat.Chemie.Cr2        # CnvFA(Gv.Alpha.31);
    Mat.Chemie.V2         # CnvFA(Gv.Alpha.32);
    Mat.Chemie.Nb2        # CnvFA(Gv.Alpha.33);
    Mat.Chemie.Ti2        # CnvFA(Gv.Alpha.34);
    Mat.Chemie.N2         # CnvFA(Gv.Alpha.35); // Co
    Mat.Chemie.Cu2        # CnvFA(Gv.Alpha.36);
    Mat.Chemie.Ni2        # CnvFA(Gv.Alpha.37);
    Mat.Chemie.Mo2        # CnvFA(Gv.Alpha.38);
    Mat.Chemie.B2         # CnvFA(Gv.Alpha.39); // W
    Mat.Chemie.Frei1.2    # CnvFA(Gv.Alpha.40); // Pb

    Mat.RP02_V1           # CnvFA(Gv.Alpha.41);
    Mat.RP10_V1           # CnvFA(Gv.Alpha.42);
    "Mat.Körnung1"        # CnvFA(Gv.Alpha.43);

    Mat.RP02_V2           # CnvFA(Gv.Alpha.45);
    Mat.RP10_V2           # CnvFA(Gv.Alpha.46);
    "Mat.Körnung2"        # CnvFA(Gv.Alpha.47);
    //==========================================================

    //GetInt(Mat.KommKundennr,'');
    //xGetInt(Mat.VK.Kundennr,'');
    //xGetInt(Mat.VK.Rechnr,'');
    //xGetInt(Mat.EK.RechNr,'');
    //xGetInt(Mat.Auftragsnr,'');
    //xGetInt(Mat.Einkaufsnr,'');
    //xGetAlpha(Mat.Gütenstufe,'');
    //xGetAlpha(Mat.AusführungUnten,'');
    //xGetAlpha(Mat.Strukturnr,'');
    //xGetAlpha(Mat.Intrastatnr,'');
    //xGetAlpha(Mat.KommKundenSWort,'');
    //xGetAlpha(Mat.LieferStichwort,'');
    //xGetAlpha(Mat.LagerStichwort,'');
    //xGetAlpha(Mat.QS.User,'');
    //xGetAlpha(Mat.Zwischenlage,'');
    //xGetAlpha(Mat.Unterlage,'');
    //GetNum(Mat.DickenTol.Von,'');
    //GetNum(Mat.DickenTol.Bis,'');
    //GetNum(Mat.BreitenTol.Von,'');
    //GetNum(Mat.BreitenTol.Bis,'');
    //GetNum(Mat.Länge.Von,'');
    //GetNum(Mat.Länge.Bis,'');
    //GetNum(Mat.LängenTol.Von,'');
    //GetNum(Mat.LängenTol.Bis,'');
    //GetNum(Mat.VK.Preis,'');
    //GetNum(Mat.VK.Gewicht,'');
    //GetNum(Mat.Nettoabzug,'');
    //GetNum(Mat.Stapelhöhe,'');
    //GetNum(Mat.Stapelhöhenabzug,'');
    //GetNum(Mat.Rechtwinkligkeit,'');
    //GetNum(Mat.Ebenheit,'');
    //GetNum(Mat.Säbeligkeit,'');
    //GetNum(Mat.Etk.Dicke,'');
    //GetNum(Mat.Etk.Breite,'');
    //GetNum(Mat.Etk.Länge,'');
    //GetDate(Mat.QS.Datum,'');
    //GetDate(Mat.VK.Rechdatum,'');
    //GetDate(Mat.EK.RechDatum,'');
    //GetWord(Mat.Auftragspos,'');
    //GetWord(Mat.Einkaufspos,'');
    //GetWord(Mat.QS.Status,'');
    //GetWord(Mat.Verwiegungsart,'');
    //GetWord(Mat.AbbindungL,'');
    //GetWord(Mat.AbbindungQ,'');
    //GetBool(Mat.DickenTolYN,'');
    //GetBool(Mat.BreitenTolYN,'');
    //GetBool(Mat.LängenTolYN,'');
    //GetBool(Mat.StehendYN,'');
    //GetBool(Mat.LiegendYN,'');
    //GetTime(Mat.QS.Zeit,'');

    xGetWord(GV.Ints.01,'Mat.Oberfläche');    //Mat.AusführungOben

    vObf  # 0;
    case GV.Ints.01 of // Oberflaeche auf neue umsetzen
      1 : begin   // schwarz
        vObf  # 2;
      end;        //
      2 : begin   // MA
        vObf  # 0;
      end;        //
      3 : begin   // MB
        vObf  # 0;
      end;        //
      4 : begin   // MC
        vObf  # 0;
      end;        //
      5 : begin   // geblaeut gewachst
        vObf  # 0;
      end;        //
      6 : begin   // matt
        vObf  # 0;
      end;        //
      7 : begin   // gefettet
        vObf  # 0;
      end;        //
      8 : begin   // beidseitig gestrahlt
        vObf  # 0;
      end;        //
      9 : begin   // gesandstrahlt
        vObf  # 6;
      end;        //
      10 : begin  // walzblau
        vObf  # 0;
      end;        //
      11 : begin  // chromatiert
        vObf  # 0;
      end;        //
      12 : begin  // LaserCut
        vObf  # 0;
      end;        //
      13 : begin  // elo verz.
        vObf  # 0;
      end;        //
      14 : begin  // gesandstrahlt + geprimert
        vObf  # 8;
      end;        //
      100 : begin // kaltgewalzt
        vObf  # 0;
      end;        //
      200 : begin // gebeizt gefettet
        vObf  # 6;
      end;        //
      300 : begin // verzinkt
        vObf  # 0;
      end;        //
      304 : begin // NA-C
        vObf  # 0;
      end;        //
      307 : begin // MA-C
        vObf  # 0;
      end;
    end;


    vNr # Lib_Nummern:ReadNummer('Material');
    if (vNr<>0) then
      Lib_Nummern:SaveNummer();
    Mat.Nummer           # vNr;
    Mat.Ursprung         # vNr;

    if(vObf <> 0) then // Obf. im neuen System
      Import_Mat:InsertAFByNumber(vObf, '1');

    "Mat.AusführungOben" # Obf_Data:BildeAFString(200, '1');

    if ("Mat.Löschmarker" <> '*') and
      ((Mat.Status >=1) or (Mat.Status <= 5)) then begin
      Erx # Mat_Data:Insert(0, 'AUTO', today);
      //debug(cnvAI(Erx)+'   '+cnvAI(Mat.Nummer));
    end;

  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Material wurde importiert!',0,0,0);
end;


//========================================================================
//  InsertAF
//
//========================================================================
sub InsertAF(aAF : alpha; aSeite : alpha; aSep : alpha) : logic
local begin
  Erx   : int;
  vCurrentAF : alpha;
  vOK        : logic;
end;
begin
  aAF # StrAdj(aAF, _StrEnd);

  vCurrentAF # '';
  Mat.AF.lfdNr # 0;

  Erx # StrFind(aAF, aSep, 1);
  WHILE((Erx > 0) or (aAF <> '')) DO BEGIN

    if(Erx > 0) then begin // Seperator noch vorhanden
      vCurrentAF # StrCut(aAF, 1, Erx - 1);
      aAF # StrDel(aAF, 1,  Erx);
    end
    else begin // kein Seperator mehr jedoch noch txt vorhanden
      vCurrentAF # aAF;
      aAF # '';
    end;

    vOK # false;
    RecBufClear(841);
    if(vCurrentAF <> '') then begin
      Erx # RecRead(841, 1, _recFirst);
      WHILE(Erx <= _rLocked) DO BEGIN
        if(vCurrentAF = "Obf.Kürzel") then begin
          vOK # true;
          BREAK;
        end;
        Erx # RecRead(841, 1, _recNext);
      END;
    end;

    if(vOK = true) then begin // eine passende AF gefunden?
      Mat.AF.Nummer       # Mat.Nummer;
      Mat.AF.ObfNr        # Obf.Nummer;
      Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Mat.AF.Kürzel"     # "Obf.Kürzel";
      Mat.AF.lfdNr        # Mat.AF.lfdNr + 1;
      Mat.AF.Seite        # aSeite;
      Erx # RekInsert(201, 0, 'AUTO');
      if(Erx <> _rOK) then
        RETURN false;
    end;

    Erx # StrFind(aAF, aSep, 1);
  END;

  RETURN true;
end;

//========================================================================
//  InsertAFByNumber
//
//========================================================================
sub InsertAFByNumber(aAF : int; aSeite : alpha) : logic
local begin
  Erx   : int;
  vLastLfdNr : int;
  vOK        : logic;
end;
begin
  vOK # false;

  Erx # RecLink(201, 200, 11, _recFirst); // AF zu Mat lesen
  if(Erx > _rLocked) then
    RecBufClear(201);

  vLastLfdNr # Mat.AF.lfdNr;
  RecBufClear(201);

  RecBufClear(841);
  Obf.Nummer # aAF;
  Erx # RecRead(841, 1, 0); // Obf lesen
  if(Erx > _rLocked) then
    RecBufClear(841);
  else
    vOK # true;

  if(vOK = true) then begin // eine passende AF gefunden?
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.ObfNr        # Obf.Nummer;
    Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
    "Mat.AF.Kürzel"     # "Obf.Kürzel";
    Mat.AF.lfdNr        # Mat.AF.lfdNr + 1;
    Mat.AF.Seite        # aSeite;
    Erx # RekInsert(201, 0, 'AUTO');
    if(Erx <> _rOK) then
      RETURN false;
  end;

  RETURN true;
end;

//========================================================================//========================================================================