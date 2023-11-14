@A+
//==== Business-Control ==================================================
//
//  Prozedur    F_STD_OfP_Mahnung_E
//                      OHNE E_R_G
//  Info
//
//
//  01.07.2009  MS  Erstellung der Prozedur
//  25.08.2009  MS  Anpassung auf ENGLISCH
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
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
  cPos0   :  10.0 // Anschrift
  cPos1   :  10.0 // ReNr
  cPos2   :  40.0 // ReDatum
  cPos3   :  60.0 // Stufe
  cPos4   :  80.0 // überfällig
  cPos5   : 105.0 // Gebühren
  cPos6   : 135.0 // Rechnungsbetrag
  cPos7   : 160.0 // gezahlt
  cPos8   : 180.0 // offen
  cPos9   : 140.0

    // Position (Content)
  cPosCL   : 10.0            // Linker Rand
  cPosC0   : 20.0            //  'Re.-Nr.'
  cPosC1   : cPosC0  + 8.0   //  'Re.-Datum'
  cPosC2   : cPosC1  + 20.0  //  'Fälligkeit'
  cPosC3   : cPosC2  + 23.0  //  'Stufe'
  cPosC4   : cPosC3  + 8.0  //  'Nachfrist'
  cPosC5   : cPosC4  + 33.0  //  'Re.Betrag'
  cPosC6   : cPosC5  + 20.0  //  'Gebühren'
  cPosC7   : cPosC6  + 20.0  //  'Zinsen'
  cPosC8   : cPosC7  + 25.0  //  'offener  Betrag '
  cPosC9   : cPosC8  + 20.0  //
  cPosC10  : cPosC9  + 15.0  //
  cPosC11  : cPosC10 + 30.0  //
  cPosC12  : cPosC11 + 10.0  //
  cPosC13  : cPosC12 + 20.0  //
  cPosC14  : cPosC13 + 20.0
  cPosC15  : cPosC14 + 20.0
  cPosC16  : cPosC15 + 20.0

  // Kopfdaten extra
  cPosXH0 : 10.0            // Bezeichnung
  cPosXH1 : cPosXH0 + 25.0 // :
  cPosXH2 : cPosXH1 + 4.0 // Inhalt
  cPosXH3 : cPosXH2 + 60.0 // Bezeichnung
  cPosXH4 : cPosXH3 + 28.0 // :
  cPosXH5 : cPosXH4 + 4.0 // Inhalt
  cPosXH6 : cPosXH5 + 5.0
  cPosXH7 : cPosXH6 + 5.0
  cPosXH8 : cPosXH7 + 5.0


  // Fuss (Bottom)
  cPosB0  : 10.0
  cPosB1  : cPosB0 + 20.0    // :
  cPosB2  : cPosB1 + 5.0
  cPosB3  : cPosB2 + 20.0
  cPosB4  : cPosB3 + 20.0
  cPosB5  : cPosB4 + 20.0
  cPosB6  : cPosB5 + 20.0
  cPosB7  : cPosB6 + 20.0
  cPosB8  : cPosB7 + 20.0
  cPosB9  : cPosB8 + 20.0

  // Kopf (Head)
  cPosH0  : 10.0
  cPosH1  : cPosH0 + 110.0
  cPosH2  : cPosH1 + 30.0
  cPosH3  : cPosH2 + 3.0
  cPosH4  : cPosH3 + 20.0
end;

local begin
  gGesOffenerBetrag : float;
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
  RecLink(100,460,4,0);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN  CnvAI(Ofp.Kundennummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)  // Dokumentennummer
                + CnvAd(Sysdate());                                              // Mahndatum
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx         : int;
  vTextnr     : int;        // Mahntextnr
  vTxtName    : alpha;
end
begin
  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    Usr.Username # gUsername;
    Erx # RecRead(800, 1, 0); // Benutzer holen
    if(Erx > _rLocked) then
      RecBufClear(800);

    Pls_fontSize # 6
    pls_Fontattr # _WinFontAttrU;
    PL_Print(Set.Absenderzeile, cPosH0);
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;

    pls_Fontattr # 0;
    Pls_fontSize # 10;
    PL_Print(Adr.A.Anrede   , cPosH0);
    PL_PrintLine;

    PL_Print(Adr.A.Name     , cPosH0);
    PL_PrintLine;

    PL_Print(Adr.A.Zusatz   , cPosH0);
    PL_PrintLine;

    PL_Print("Adr.A.Straße" , cPosH0);
    PL_PrintLine;

    PL_Print(Adr.A.Plz + ' ' + Adr.A.Ort, cPosH0);
    PL_PrintLine;

    Erx # RecLink(812,101,2,_recFirst);   // Land holen
    if(Erx > _rLocked) then
      RecBufClear(812);
    Pls_fontSize # 10;
    if ("Lnd.kürzel"<>'D') then
      PL_Print(Lnd.Name.L1, cPosH0);
    PL_PrintLine;
    PL_PrintLine;
    //Lib_Print:Print_LinieEinzeln(cPosH1, 188.0);

    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Reminder' ,cPos0);
    PL_Print(cnvAD(today, _FmtInternal), cPosH1);
    PL_Print_R('Page: '+cnvAI(aSeite,_FmtInternal), 188.0);
    PL_PrintLine;
    Pls_FontSize # 9;
    pls_Fontattr # 0;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPos0, 188.0);
    PL_PrintLine;
    PL_Print('Customer number:', cPosXH0);
    PL_Print(':', cPosXH1);
    PL_PrintI_L(Adr.Kundennr, cPosXH2);
    PL_Print('Our reference', cPosXH3);
    PL_Print(':', cPosXH4);
    PL_Print(Usr.Anrede + ' ' + Usr.Name, cPosXH5);
    PL_PrintLine;
    PL_Print('VAT-NO.', cPosXH0);
    PL_Print(':', cPosXH1);
    PL_Print(Adr.USIdentNr, cPosXH2);
    PL_PrintLine;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPos0, 188.0);
    PL_PrintLine;
    PL_PrintLine;

    Erx # RecRead(837, 1, _recFirst);
    WHILE (Erx <= _rLocked) DO BEGIN

      if (Txt.Bezeichnung = '@Mahntext-' + cnvAI(OfP.Mahnstufe + 1)) then
        vTextNr # Txt.Nummer;

      Erx # RecRead(837, 1, _recNext);
    END;

    vTxtName # '~837.'+CnvAI(vTextnr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    if(vTxtName <> '') then begin
      Lib_Print:Print_Text(vTxtName,1, cPos0);
      PL_PrintLine;
    end;
    PL_PrintLine;
    PL_PrintLine;

    end       // 1. Seite
  else begin  // weitere Seiten
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Reminder', cPos0);
    PL_Print(cnvAD(today, _FmtInternal), cPosH1);
    PL_Print_R('Page: '+cnvAI(aSeite,_FmtInternal), 188.0);
    PL_PrintLine;
    Pls_FontSize # 9;
    pls_Fontattr # 0;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
  end;

  if (form_mode <> 'FUSS') then begin
    pls_FontSize  # 8;
    PL_Print_R('Invoice No.'                              , cPosC0);
    PL_Print('Date'                              , cPosC1);
    PL_Print('Due Date'                             , cPosC2);
    PL_Print_R('Level'                                  , cPosC3);
    PL_Print('Respite'                              , cPosC4);
    PL_Print_R('Invoice amount'                            , cPosC5);
    PL_Print_R('Dues'                             , cPosC6);
    PL_Print_R('Interest'                               , cPosC7);
    PL_Print_R('open amount'                     , cPosC8);
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPosCL,cPosC8);
  end;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx         : int;
  vHdl        : int;        // allgemeiner Handlingsdescriptor
  vPrt        : int;        // Despriptor für eigene Druckelemente

  vPrinted            : logic;

  vNummer     : int;        // Dokumentennummer
  vFlag       : int;        // Datensatzlese option

  vMarked     : int;        // Descriptor für den Marierungsbaum
  vMarkedItem : int;        // Descriptor für markierten Eintrag

  vMahnTree    : int;       // Descriptor für die Sortierungsliste
  vMahnSortKey : alpha;     // "Sortierungsschlüssel" der Liste
  vMahnItem    : int;       // Descriptor für einen Offenen Posten

  vKunde       : int;       // Merker für Kundenwechsel
  vUeberfaellig : int;      // Differenz zwischen heutigem Tag und Zieldatum
  vAdresse     : int;       // Merker für Kundenanschrift

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  // Markierungen
  vMFile        : int;
  vMID          : Int;

  vNachfrist          : date;
end;
begin

  // nur aktuellen Ofp.Kunden mahnen
  vKunde # Ofp.Kundennummer;
  Erx # RecLink(100,460,4,_recFirst); // Kunde holen
  if (Erx > _rLocked) then
    RETURN;

  // Mahnungsliste fürs Sortieren erstellen
  vMahnTree # CteOpen(_CteTreeCI);
  if (vMahnTree = 0) then
    RETURN;

  /* Markierungen sortiert in eigene Liste schreiben */
  vMarked # gMarkList->CteRead(_CteFirst);
  WHILE (vMarked > 0) DO BEGIN
    Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);

    if (vMFile=460) then begin
      RecRead(460,0,_RecId,vMID);
      if (OFp.Kundennummer=vKunde) then begin
        // gelesenen Eintrag in eigene Liste übergeben
        vMahnSortKey # CnvAi(Ofp.Kundennummer, _FmtNumNoGroup | _FmtNumLeadZero,0,10) +
                       CnvAi(100 - OfP.Mahnstufe, _FmtNumNoGroup | _FmtNumLeadZero,0,3);
        Sort_ItemAdd(vMahnTree,vMahnSortKey,460,vMID);
      end;
    end;

    vMarked # gMarkList->CteRead(_CteNext,vMarked);
  END;

  // 1. Satz holen
  vMahnItem # Sort_ItemFirst(vMahntree)
  if (vMahnItem=0) then begin
    // Löschen der Liste
    Sort_KillList(vMahnTree);
    RETURN;
  end;

  RecRead(460,0,_RecId, vMahnItem->spID);


  // ------ Druck vorbereiten ----------------------------------------------------------------
  // Seitenkopf zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  PL_Create(vPLHeader);

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader , vFooter, y, y) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Form_Lang # 'E';

  // ------- KOPFDATEN -----------------------------------------------------------------------
  Erx # RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if(Erx > _rLocked) then
    RecBufClear(101);
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;

  form_Mode # '';
  Lib_Print:Print_Seitenkopf();

  pls_FontSize  # 8;

  FOR   vMahnItem # Sort_ItemFirst(vMahntree)
  loop  vMahnItem # Sort_ItemNext(vMahntree, vMahnItem)
  WHILE (vMahnItem <> 0) DO BEGIN

    RecRead(460,0,_RecId, vMahnItem->spID);

    if (Ofp.Mahnstufe = 0) then begin
      "OfP.MahngebührW1"  # 0.0;
      "OfP.Mahngebühr"    # 0.0;
    end;

    vNachfrist # today;
    case (Ofp.Mahnstufe) of
      0 : begin
        vNachfrist -> vmDayModify(Set.Fin.MahnTage1);
      end;

      1, 2 : begin
        vNachfrist -> vmDayModify(Set.Fin.MahnTage2);
      end;
    end;

    // Position zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    PL_PrintI(Ofp.Rechnungsnr       , cPosC0);  //  'Re.-Nr.'
    PL_PrintD_L(Ofp.Rechnungsdatum  , cPosC1);  //  'Re.-Datum'
    PL_PrintD_L(Ofp.Zieldatum       , cPosC2);  //  'Fälligkeit'
    PL_PrintI(Ofp.Mahnstufe + 1     , cPosC3);  //  'Stufe'
    PL_PrintD_L(vNachfrist          , cPosC4);  //  'Nachfrist'
    PL_PrintF(OfP.BruttoW1, 2       , cPosC5);  //  'Re.Betrag'
    PL_PrintF("OfP.MahngebührW1", 2 , cPosC6);  //  'Gebühren'
    PL_PrintF(OfP.ZinsenW1, 2       , cPosC7);  //  'Zinsen'
    PL_PrintF(OfP.RestW1, 2         , cPosC8);  //  'offener  Betrag '
    PL_PrintLine;

    gGesOffenerBetrag # gGesOffenerBetrag + OfP.RestW1;
  END;

  //Lib_Print:Print_LinieDoppelt();


  // Gesamtsummierung-------------------------------------------------------------
  Lib_Print:Print_LinieDoppelt(cPosCL,cPosC8);
  PL_Print_R('Gesamt:', cPosC7);
  PL_PrintF(gGesOffenerBetrag, 2, cPosC8);
  PL_PrintLine;

//-----------------------------------------------------------------------------------

  pls_FontSize # 10;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Sollte Ihre Zahlung bereits erfolgt sein, betrachten Sie dieses Schreiben als gegenstandslos.',cPos1);
  PL_PrintLine;

  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Mit freundlichen Grüßen',cPos1);
  PL_PrintLine;
  PL_Print(Set.mfg.Text,cPos1);
  PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

  /***************************************************/
  /***************** ENDE DES DRUCKES ****************/
  /***************************************************/

  // Löschen der Liste
  Sort_KillList(vMahnTree);

end;

//========================================================================