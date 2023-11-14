@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_AUF_Anfrage  (Basierend auf Auftragsbestätigung)
//                        OHNE E_R_G
//  Info
//    Druckt eine Anfrage aus mehreren markierten Auftragspositionen
//    an ALLE markierten Lieferanten(Adressen)
//
//
//  21.08.2012  TM  Erstellung der Prozedur aus F_Std_Auf_AufBest
//  25.09.2012  TM  Fertiggestellte Prozedur in Entwicklungssystem übertragen
//  19.02.2013  ST  Umstellung auf Styles
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  24.06.2015  AH  BugFix: Dokumentnummer mus ANFRAGENR sei und nicht AB-Nummer
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//
//
//    MAIN (opt aFilename : alpha(4096))
//
//========================================================================
@I:Def_Global
@I:Def_Form
@I:Def_Aktionen

local begin
  gAnfrageNr          : int;

  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;
  elKopfText          : int;
  elFussText          : int;
  elUeberschrift      : int;
  elPosText           : int;
  elPosMat1           : int;
  elPosMat2           : int;
  elPosVpg            : int;
  elPosMech           : int;
  elPosAnalyse        : int;
  elPosArt1           : int;
  elPosArt2           : int;
  elEinsatzUS         : int;
  elEinsatz1          : int;
  elEinsatz2          : int;
  elEinsatzFuss       : int;
  elFertigungUS       : int;
  elFertigung1        : int;
  elFertigung2        : int;
  elFertigungFuss     : int;
  elVerpackungUS      : int;
  elVerpackung1       : int;
  elVerpackung2       : int;
  elVerpackungFuss    : int;
  elEnde              : int;
  elSumme             : int;
  elLeerzeile         : int;

  /// -----------------------------

  // Variablen...
  vBuf101Lief         : int;
  vAnfrageNr          : int;
  vAnfragePos         : int;

  vBuf100Re           : int;
  vBuf101We           : int;
  vBuf110Ver1         : int;
  vBuf110Ver2         : int;
  vAdrNr              : int;


  vMwstSatz1          : float;
  vMwstWert1          : float;
  vMwstSatz2          : float;
  vMwstWert2          : float;
  vPosMwSt            : float;

  vPosMenge           : float;
  vPosGewicht         : float;
  vPosStk             : int;
  vPosCount           : int;
  vPosNetto           : float;
  vPosNettoRabbar     : float;

  vGesamtNetto        : float;
  vGesamtNettoRabBar  : float;
  vGesamtMwSt         : float;
  vGesamtBrutto       : float;
  vGesamtStk          : int;
  vGesamtGew          : float;
  vGesamtMEH          : alpha;
  vGesamtM            : float;
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
end
begin
  vBuf100 # RekSave(100);
  RecLink(100,400,1,_RecFirst);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);

//  RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
  RETURN CnvAI(gAnfrageNr,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
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

  vTxtHdlTmp1         : int;
  vTxtHdlTmp2         : int;
  vTxtHdlTmp3         : int;
  vTxtHdlTmp4         : int;
  vTxtHdlTmp5         : int;
  vTxtHdlName         : alpha;
  vTxtHdlTmpRTF       : int;
end;
begin

  // SCRIPTLOGIK
  //if (Scr.B.Nummer<>0) then HoleEmpfaenger();

  // ERSTE SEITE??
  if (aSeite=1) then begin
    form_Ele_Auf:elABErsteSeite(var elErsteSeite, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);

    // >>>> AnfrageKopftext holen und ausgeben
    vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
    vTxtHdlTmp1 # $edTxt_lang1_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache2.Kurz) then vTxtHdlTmp1 # $edTxt_lang2_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache3.Kurz) then vTxtHdlTmp1 # $edTxt_lang3_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache4.Kurz) then vTxtHdlTmp1 # $edTxt_lang4_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache5.Kurz) then vTxtHdlTmp1 # $edTxt_lang5_head->wpdbTextBuf;
    //Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF); // Eingegebener Text ist kein RTF
    vTxtHdlTmpRTF # vTxtHdlTmp1;
    vTxtHdlName # '~TMP.F541.' + UserInfo(_UserCurrent);
    TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
    if (TextInfo(vTxtHdlTmpRTF,_TextLines) > 0) then
      form_Elemente:elKopfText(var elKopfText,vTxtHdlName);
    TxtDelete(vTxtHdlName,0);
    // AnfrageFußtext holen und ausgeben <<<<

    end
  else begin
    form_Ele_Auf:elABFolgeSeite(var elFolgeSeite, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);
  end;

  if (Form_Mode='POS') then begin
    form_Ele_Auf:elABUeberschrift(var elUeberschrift);
  end;

end;

//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  form_Elemente:elSeitenFuss(var elSeitenFuss, true, vGesamtNetto);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx                 : int;
  vMeta               : int;
  vTxtName            : alpha;
  vTxtNameLast        : alpha;
  vVPG                : alpha(1000);
  vVPGCount           : int;
  vSubStyle           : alpha;

  vItem               : int;      // für Markierungsbaum
  vItemLief           : int;
  vItemAufp           : int;
  vMFile              : int;
  vMID                : int;

  vCnt                : int;  // Zähler für Lieferantenmarkierungen

  vTxtHdlTmp1         : int;
  vTxtHdlTmp2         : int;
  vTxtHdlTmp3         : int;
  vTxtHdlTmp4         : int;
  vTxtHdlTmp5         : int;
  vTxtHdlName         : alpha;
  vTxtHdlTmpRTF       : int;
  vOK                 : logic;
  vEinLieferant       : logic;
end;
begin

  // ------ Druck vorbereiten ----------------------------------------------------------------

  if (Lib_Mark:Count(100)=0) then
    vEinLieferant # true;

  // Markierte Lieferanten durchlaufen
  FOR    vItemLief # gMarkList->CteRead(_CteFirst);
  LOOP   vItemLief # gMarkList->CteRead(_CteNext, vItemLief);
  WHILE (vItemLief > 0) or (vEinLieferant) do begin

    if (vEinLieferant=false) then begin
      // Datensatz lesen
      Lib_Mark:TokenMark(vItemLief,var vMFile,var vMID);
      if (vMFile <> 100) then
        CYCLE;
      RecRead(100,0,_RecId,vMID);
    end;

    // ------------------------------------
    // Formular start
    vAnfrageNr # Lib_Nummern:ReadNummer('Anfrage');
    if (vAnfrageNr<>0) then
      Lib_Nummern:SaveNummer()
    else
      RETURN;
    gAnfrageNr # vAnfrageNr;


    RekLinkB(vBuf101Lief, 100,12,_recFirst);  // Anschrift des Lieferanten holen

    vBuf100Re # Adr_Data:HoleBufferAdrOderAnschrift(Auf.Rechnungsempf, Auf.Rechnungsanschr);
    RekLinkB(vBuf101We, 400, 2, _recFirst);   // Warenempfänger holen
    RekLink(814,400,8,_recFirst);             // Währung holen
    RekLinkB(vBuf110Ver1,400,20,_recFirst);   // Vertreter 1 holen
    RekLinkB(vBuf110Ver2,400,21,_recFirst);   // Vertreter 2 holen
    RecBufClear(460);                         // Offenen Posten leeren (wegen Zahlungsbed. berechnung bei Rechnug)
    Erx # RekLink(816,400,6,_RecFirst);       // Zahlungsbedingung lesen
    Erx # RekLink(815,400,5,_RecFirst);       // Lieferbedingung lesen
    Erx # RekLink(817,400,7,_RecFirst);       // Versandart lesen

//  Erx # RekLink(100,400,1,_RecFirst);       // Kunde holen
//  Erx # RekLink(101,100,12,_recFirst);      // Hauptanschrift holen

    Erx # RekLink(812,101,2,_recFirst);       // Land holen
    if ("Lnd.kürzel"='D') or ("Lnd.kürzel"='DE') then
      RecbufClear(812);

    Usr.Username # Auf.Sachbearbeiter;
    Erx # RecRead(800, 1, 0); // Benutzer holen
    if (Erx > _rLocked) then RecBufClear(800);

    if (Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
      RETURN;
    end;

    Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
    Lib_Form:LoadStyleDef(Frm.Style);

    // Seitenfuss vorbereiten
    form_Elemente:elSeitenFuss(var elSeitenFuss, false);

  // ------- KOPFDATEN -----------------------------------------------------------------------
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
    Lib_Print:Print_Seitenkopf();
    vAdrNr      # Adr.Nummer;
    vMwstSatz1  # -1.0;
    vMwstSatz2  # -1.0;

  // ------- POSITIONEN --------------------------------------------------------------------------
    form_Ele_Auf:elABUeberschrift(var elUeberschrift);
    Form_Mode # 'POS';

    vAnfragePos # 1;

    FOR    vItemAufp # gMarkList->CteRead(_CteFirst);
    LOOP   vItemAufp # gMarkList->CteRead(_CteNext, vItemAufp);
    WHILE (vItemAufp > 0) DO BEGIN

      // Datensatz lesen
      Lib_Mark:TokenMark(vItemAufp,var vMFile,var vMID);
      if vMFile <> 401 then
        CYCLE;
      RecRead(401,0,_RecId,vMID);

      if ("Auf.P.Löschmarker"='*') then CYCLE;

      if ((Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr))) then begin

        // Artikelmix zählt auf AB als Artikel
        Erx # RekLink(250,401,2,_RecFirst); // Artikel holen
      end
      else
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) then begin
        RecBufClear(250);
      end
      else
        CYCLE;

      // Position ok und ausgeben.....
      Inc(vPosCount);

      // Positionstyp bestimmen
      RekLink(818,401,9,_recFirst); // Verwiegungsart holen
      RekLink(819,401,1,_recFirst); // Warengruppe holen
      RekLink(835,401,5,_recFirst); // Auftragsart holen
      vPosMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
      vPosMwSt        # 0.0;
      vPosGewicht     # Auf.P.Gewicht;
      vPosStk         # "Auf.P.Stückzahl";
      Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis) *  vPosMenge / CnvFI(Auf.P.PEH) ,2);
      vPosNettoRabBar # Auf.P.Gesamtpreis;
      vPosNetto       # Auf.P.Gesamtpreis;

      // Positionstext ausgeben
      vTxtName # '';
      if (Auf.P.TextNr1=400) then // anderer Positionstext
        vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      if (Auf.P.TextNr1=0) and (Auf.P.TextNr2 != 0) then   // Standardtext
        vTxtName # '~837.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
      if (Auf.P.TextNr1=401) then // Individuell
        vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      if (vTxtName != '') and (vTxtNameLast<>vTxtName) then begin
        form_Elemente:elPosText(var elPosText, vTxtName);
        vTxtNameLast # vTxtName;
      end;

      // Artikel Handel --------------------------------------------------------
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
        form_Ele_Auf:elABPosArt1(var elPosArt1);
        vGesamtNettoRabBar  # vGesamtNettoRabBar + Auf.P.Gesamtpreis;
        vGesamtNetto        # vGesamtNetto + Auf.P.GesamtPreis;
        vGesamtStk          # vGesamtStk + "Auf.P.Stückzahl";
        vGesamtGew          # vGesamtGew + Auf.P.Gewicht;
        if (vGesamtMEH='') then vGesamtMEH # Auf.P.MEH.Wunsch;
        if (vGesamtMEH=Auf.P.MEH.Wunsch) then vGesamtM # vGesamtM + Auf.P.Menge.Wunsch;
        form_Ele_Auf:elABPosArt2(var elPosArt2);
      end;

      // Material ausgeben
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) then begin

        form_Ele_Auf:elABPosMat1(var elPosMat1);
        vGesamtNettoRabBar  # vGesamtNettoRabBar + Auf.P.Gesamtpreis;
        vGesamtNetto        # vGesamtNetto + Auf.P.GesamtPreis;
        vGesamtStk          # vGesamtStk + "Auf.P.Stückzahl";
        vGesamtGew          # vGesamtGew + Auf.P.Gewicht;
        if (vGesamtMEH='') then vGesamtMEH # Auf.P.MEH.Wunsch;
        if (vGesamtMEH=Auf.P.MEH.Wunsch) then vGesamtM # vGesamtM + Auf.P.Menge.Wunsch;
        form_Ele_Auf:elABPosMat2(var elPosMat2);

        // LOHN? -
        if (AAr.Berechnungsart>=700) then begin

          // BA suchen...
          if (Auf_Data:ReadLohnBA()) then begin
            RekLink(828,835,1,_recFirsT);   // Arbeitsgang holen
            vSubStyle # GetCaption('PosLohn_'+ArG.Aktion);
  //        aWMenge # Auf.A.Menge;
            vVPG      # '';
            vVPGCount # 0;
            LoadSubStyleDef(vSubStyle);//'Style_Std_BAG_Lohn_Spalt');

            form_Elemente:elLeerzeile(var elLeerzeile);
            F_AAA_BAG_Lohn:PrintEinsatz(var elEinsatzUS, var elEinsatz1, var elEinsatz2, var elEinsatzFuss);

            form_Elemente:elLeerzeile(var elLeerzeile);
            F_AAA_BAG_Lohn:PrintFertigung(var elFertigungUS, var elFertigung1, var elFertigung2, var elFertigungFuss, var vVPG);

            form_Elemente:elLeerzeile(var elLeerzeile);
            F_AAA_BAG_Lohn:PrintVerpackung(var elVerpackungUS, var elVerpackung1, var elVerpackung2, var elVerpackungFuss, vVpg);

            UnLoadSubStyleDef();

            form_Elemente:elLeerzeile(var elLeerzeile);
          end;

        end;  // Lohn

      end;  // Material

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
      //========================================================================
      //PrintPosAufpreise();      // Keine Aufpreise für Anfragen


      // Print Verpackung:
      form_Ele_Auf:elABPosVpg(var elPosVpg);

      // Print Mechanik
      form_Ele_Auf:elABPosMech(var elPosMech);

      // Print Analyse
      form_Ele_Auf:elABPosAnalyse(var elPosAnalyse);

      // Leerzeile zwischen den Positionen
      form_Elemente:elLeerzeile(var elLeerzeile);


      // >>>> Anfrage in AuftragsAktionen hinterlegen
      // Pos. bereits in Anfrage enthalten?
      vOk # false;
      Erx # RecLink(404,401,12,_RecLast);
      WHILE (Erx<=_rLocked) do begin          // Aktionen durchlaufen
        if (Auf.A.Aktionstyp = c_Akt_Anfrage) and (Auf.A.Aktionsnr=vAnfrageNr) then vOk # true; // c_Anf anlegen mit Inhalt 'ANF'
        Erx # RecLink(404,401,12,_RecPrev);
      END;

      if (vOK = false) then begin
        // Aktion vermerken
        RecBufClear(404);
        Auf.A.Nummer          # Auf.P.Nummer;
        Auf.A.Position        # Auf.P.Position;
        Auf.A.Position2       # 0;
        Auf.A.Aktion          # 0;
        Auf.A.Aktionstyp      # c_akt_Anfrage;
        Auf.A.Aktionsnr       # vAnfrageNr;
        Auf.A.Aktionspos      # vAnfragePos;
        Auf.A.Aktionsdatum    # today;
        Auf.A.Adressnummer    # Adr.Nummer;
        Auf.A.Bemerkung       # 'ANFRAGE ' + Adr.Stichwort;
        Auf.A.Anlage.Datum    # today;
        Auf.A.Anlage.Zeit     # now;
        Auf.A.Anlage.User     # gUserName;

        REPEAT
          Auf.A.Aktion         # Auf.A.Aktion + 1;
          Erx # RekInsert(404,0,'AUTO');
        UNTIL (Erx=_rOK);

      end;
      inc(vAnfragePos);
      // Anfrage in AuftragsAktionen hinterlegen <<<<

    END; // WHILE: Positionen ************************************************



    // ------- FUßDATEN --------------------------------------------------------------------------
    Form_Mode # 'FUSS';


    // Mehrwertstuern errechnen
    if (vMwStSatz1<>0.0) then vMwStWert1 # Rnd(vMwstWert1 * (vMwstSatz1/100.0),2)
    else vMwStWert1 # 0.0;
    if (vMwStSatz2>0.0) then vMwStWert2 # Rnd(vMwstWert2 * (vMwstSatz2/100.0),2)
    else vMwStWert2 # 0.0;
    vGesamtBrutto # Rnd(vGesamtNetto + vMwstWert1 + vMwstWert2,2);

    // Summe vorbelegen
    Auf.P.Gewicht       # vGesamtGew;
    "Auf.P.Stückzahl"   # vGesamtStk;
    Auf.P.MEH.Wunsch    # vGesamtMEH;
    Auf.P.Menge.Wunsch  # vGesamtM;
    form_Ele_Auf:elSumme(var elSumme, vGesamtNetto, vMwStSatz1, vMwStWert1, vMwStSatz2, vMwStWert2, vGesamtBrutto);

    // >>>> AnfrageFußtext holen und ausgeben
    vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
    vTxtHdlTmp1 # $edTxt_lang1_foot->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache2.Kurz) then vTxtHdlTmp1 # $edTxt_lang2_foot->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache3.Kurz) then vTxtHdlTmp1 # $edTxt_lang3_foot->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache4.Kurz) then vTxtHdlTmp1 # $edTxt_lang4_foot->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache5.Kurz) then vTxtHdlTmp1 # $edTxt_lang5_foot->wpdbTextBuf;
    //Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF); // Eingegebener Text ist kein RTF
    vTxtHdlTmpRTF # vTxtHdlTmp1;
    vTxtHdlName # '~TMP.F541.' + UserInfo(_UserCurrent);
    TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
    if (TextInfo(vTxtHdlTmpRTF,_TextLines) > 0) then
      form_Elemente:elFussText(var elFussText,vTxtHdlName);
    TxtDelete(vTxtHdlName,0);
    // AnfrageFußtext holen und ausgeben <<<<

    form_Ele_Auf:elABEnde(var elEnde, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);


  // -------- Druck beenden ----------------------------------------------------------------

    // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
    Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

    // Objekte entladen
    FreeElement(var elErsteSeite    );
    FreeElement(var elFolgeSeite    );
    FreeElement(var elSeitenFuss    );
    FreeElement(var elKopfText      );
    FreeElement(var elFussText      );
    FreeElement(var elUeberschrift  );
    FreeElement(var elPosText       );
    FreeElement(var elPosMat1       );
    FreeElement(var elPosMat2       );
    FreeElement(var elPosVpg        );
    FreeElement(var elPosMech       );
    FreeElement(var elPosAnalyse    );
    FreeElement(var elPosArt1       );
    FreeElement(var elPosArt2       );
    FreeElement(var elEinsatzUS     );
    FreeElement(var elEinsatz1      );
    FreeElement(var elEinsatz2      );
    FreeElement(var elEinsatzFuss   );
    FreeElement(var elFertigungUS   );
    FreeElement(var elFertigung1    );
    FreeElement(var elFertigung2    );
    FreeElement(var elFertigungFuss );
    FreeElement(var elVerpackungUS  );
    FreeElement(var elVerpackung1   );
    FreeElement(var elVerpackung2   );
    FreeElement(var elVerpackungFuss);
    FreeElement(var elSumme         );
    FreeElement(var elEnde          );
    FreeElement(var elLeerzeile     );

    if (vEinLieferant) then BREAK;

  END; // Nächster Lieferant

end;

//=======================================================================