@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Bdf_Anfrage
//                    OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  10.09.2004  AI Erstellung der Prozedur
//  15.06.2012  TM Anpassung an EDV
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  Ah  ERX
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

cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  24.0   // Bez.
  // cPos2a  :  50.0   // Materialwerte
  // cPos2b  :  77.0
  // cPos2c  :  70.0   // Dimensions Toleranzen
  // cPos2d  :  80.0
  // cPos2f  :  55.0   //60 Stückzahl
  // cPos2g  :  60.0
  cPos3   :  160.0   // Menge1
  cPos3a  :  174.0
  cPos3b  :  182.0


  cPos4   : 182.0   // Gesamt


  cPos8   : 161.0   // Gesamt
  cPos9   : 182.0   // Gesamt

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 35.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...

end;

local begin
// Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  // Für Textbausteine in richtiger sprache
  vTxtHdlTmp1         : int;
  vTxtHdlTmp2         : int;
  vTxtHdlTmp3         : int;
  vTxtHdlTmp4         : int;
  vTxtHdlTmp5         : int;
  vTxtHdlName         : alpha;
  vTxtHdlTmpRTF       : int;
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
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RETURN CnvAI(Bdf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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
      RecLink(100,540,4,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,540,5,_recFirst);   // Lieferanschrift holen
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
  end ;
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
  RecRead(100,1,0);
  //RecLink(100,500,1,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0);

  //  Pls_fontSize # 9;
  //  PL_Print('Auftragsnummer:',cPosKopf1);
  //  PL_PrintI_L(Ein.Nummer,cPosKopf2);

  PL_PrintLine;

  PL_Print(Adr.A.Name     , cPos0);

  Pls_fontSize # 9;
  //PL_Print('Auftragsdatum:',cPosKopf1);
  //PL_PrintD_L(Ein.Datum,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Lieferantennr.:',cPosKopf1);
  PL_PrintI_L(Adr.lieferantennr,cPosKopf2);
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


  Pl_Print('Anfrage'+' '+AInt(BDF.A.AnfrageNr)   ,cPos0 );
  pl_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # 0;

  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('Hiermit fragen wir zu unseren Ihnen bekannten Einkaufsbedingungen wie folgt an:',cPos0);
    PL_PrintLine;
    // Kopftext drucken
    PL_PrintLine;
    vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
    vTxtHdlTmp1 # $edTxt_lang1_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache2.Kurz) then vTxtHdlTmp1 # $edTxt_lang2_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache3.Kurz) then vTxtHdlTmp1 # $edTxt_lang3_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache4.Kurz) then vTxtHdlTmp1 # $edTxt_lang4_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache5.Kurz) then vTxtHdlTmp1 # $edTxt_lang5_head->wpdbTextBuf;
    Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF);
    vTxtHdlName # '~TMP.K541.' + UserInfo(_UserCurrent);
    TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
    TextClose(vTxtHdlTmpRTF);
    if (TextInfo(vTxtHdlTmp1,_TextLines) > 0) then
      Lib_Print:Print_Textbaustein(vTxtHdlName,cPos0,cPos4);
    TxtDelete(vTxtHdlName,0);
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
      // vText   # StrAdj(vText, _StrBegin | _StrEnd);

      // PL_Print('Lieferanschrift:',cPos0);
      // PL_Print(vText,cPosKopf3,cPosKopf3+150.0);
      // PL_PrintLine;
      PL_PrintLine;
    end;

  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # false;
    pls_FontSize  # 10;
    PL_Print('Pos.',cPos1);
    PL_Print('Beschreibung',cPos2);
    PL_Print_R('Menge',cPos3b);
    //PL_Print_R('E-Preis '+"Wae.Kürzel",cPos5);
    //PL_Print_R('Gesamt',cPos7);
    PL_Drawbox(cPos0-1.0,cPos4+1.0,_WinColBlack, 5.0);
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
  vAbstand            : int;
  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers
  vPreisGesamt        : float;      // Summe aller Positionen
  vStkGesamt          : float;      // Stückzahl Summe
  vTxtName            : alpha;
  vTxtHdl             : int;        // Handle des Textes

  // Für Aktionssummen
  vPos                : int;
  vNr                 : int;
  vMenge              : float;
  vStk                : int;
  vGew                : float;
  vEnd                : logic;



  // Druckspezifische Variablen
  vPrt                : int;        // Descriptor für Ausgabe Elemende
  //vHeader             : int;
  //vFooter             : int;
  vHdl                : int;        // Descriptor für Textfelder d. Ausgabe Elementes

  vLang               : alpha;      // Sprachindikator
  vNummer             : int;        // Dokumentennummer
  vFlag               : int;        // Datensatzlese option
  i                   : int;        // Schleifenvar
  vErx                : int;

  vItem : int;
  vMFile,vMID     : int;
  vPosCount : int;
  vPosMenge : float;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------

  PL_Create(vPL);

  if (Lib_Print:FrmJobOpen(y, vHeader ,vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);


// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();



  // ------- Aktionslisteneinträge auf Position kmumulieren -------------------------------------

  // Hier herausfinden, welche Aktion zu lesen ist
  Bdf.A.Anfragenr   # Bdf.A.Anfragenr;   // wurde in BDF_DATA_vorbelegt
  Bdf.A.Anfragepos  # 1;

  vNr     # Bdf.A.Anfragenr;
  vMenge  # 0.0;
  vStk    # 0;
  vGew    # 0.0;
  i       # 0;

  vFlag # _RecFirst;

  // Markierte Bedarfe durchlaufen
  vItem # gMarkList->CteRead(_CteFirst);

  if(vItem > 0) then begin
    FOR vItem # gMarkList->CteRead(_CteFirst);
    LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 540) then
        RecRead(540, 0, _RecId, vMID);

      Erx # RecLink(819,540,6,0);   // Warengruppe holen
      if (Erx > _rLocked) then begin
        CYCLE;
      end;

      RecBufClear(250);
      if (Wgr_Data:IstArt()) then begin
        // Artikel lesen
        Erx # RecLink(250,540,7,_RecFirst);
        If (Erx = _rNoRec) then
          CYCLE;
      end
      else
        if (Wgr_Data:IstMat()=false) and (Wgr_Data:IstMix()=false) then CYCLE;

      Inc(vPosCount);
      vPosMenge # Bdf.Menge;

      // ARTIKEL DRUCKEN
      if (Wgr_Data:IstArt()) then begin
        PL_Print(AInt(vPosCount),cPos1);
        PL_Print(Art.Nummer,cPos2);
        PL_PrintF(Bdf.Menge,2,cPos3a);
        PL_Print_R(Bdf.MEH,cPos3b);

        PL_PrintLine;
      end;

      PLs_FontSize # 9;

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

      if(Bdf.Bemerkung <> '') then begin
        PL_Print(Bdf.Bemerkung, cPos2);
        PL_PrintLine;
      end;

      Lib_Print:Print_Text('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),1, cPos2,cPos3);


    end;  // ARTIKELDRUCK

    // <==== NEU AUS BESTELLUNG ====

  END;

// ------- FUßDATEN --------------------------------------------------------------------------

  Lib_Print:Print_LinieDoppelt(cPos0-1.0,cPos4+1.0);

  // Fussftext drucken
  PL_PrintLine;
  vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
  vTxtHdlTmp1 # $edTxt_lang1_foot->wpdbTextBuf;
  if (Adr.Sprache=Set.Sprache2.Kurz) then vTxtHdlTmp1 # $edTxt_lang2_foot->wpdbTextBuf;
  if (Adr.Sprache=Set.Sprache3.Kurz) then vTxtHdlTmp1 # $edTxt_lang3_foot->wpdbTextBuf;
  if (Adr.Sprache=Set.Sprache4.Kurz) then vTxtHdlTmp1 # $edTxt_lang4_foot->wpdbTextBuf;
  if (Adr.Sprache=Set.Sprache5.Kurz) then vTxtHdlTmp1 # $edTxt_lang5_foot->wpdbTextBuf;
  Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF);
  vTxtHdlName # '~TMP.F541.' + UserInfo(_UserCurrent);
  TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
  TextClose(vTxtHdlTmpRTF);
  if (TextInfo(vTxtHdlTmp1,_TextLines) > 0) then
    Lib_Print:Print_Textbaustein(vTxtHdlName,cPos0,cPos4);
  TxtDelete(vTxtHdlName,0);
  PL_PrintLine;

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
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;


//========================================================================