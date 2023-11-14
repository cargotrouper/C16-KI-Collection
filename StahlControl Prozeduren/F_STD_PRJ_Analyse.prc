@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_PRJ_Analyse
//                      OHNE E_R_G
//  Info
//
//
//  13.12.2007  AI  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================

@I:Def_Global
@I:Def_PrintLine
define begin
  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Bez.
  cPos3   : 160.0   // Menge
  cPos4   : 182.0   // Stunden

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  xcPosKopf3 : 35.0  // Feld Lieferanschrift
end;

//========================================================================
//  GetDokName
//
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(Prj.Nummer ,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vText : alphA(1000);
end;
begin

  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  // SCRIPTLOGIK
//  if (Scr.B.Nummer<>0) then HoleEmpfaenger();


  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0);
  PL_PrintLine;
  PL_Print(Adr.A.Name     , cPos0);
  PL_PrintLine;
  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Kundennr.:',cPosKopf1);
  PL_PrintI_L(Adr.Kundennr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Unsere Lf.Nr.:',cPosKopf1);
  PL_Print(Adr.VK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
  PL_PrintLine;

  RecLink(812,101,2,_recFirst);   // Land holen
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print('Datum:',cPosKopf1);
  PL_PrintD_L(today,cPosKopf2);
  PL_PrintLine;

  PL_Print('Seite:',cPosKopf1);
  PL_PrintI_L(aSeite,cPosKopf2);
  PL_PrintLine;


  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  Pl_Print('Aufwandsanalyse zu Projekt '+' '+AInt(Prj.Nummer)   ,cPos0 );
  pl_PrintLine;

  if (Prj.Bemerkung<>'') then begin
    Pl_Print(Prj.bemerkung  ,cPos0 );
    pl_PrintLine;
  end;

  Pls_FontSize # 9;
  pls_Fontattr # 0;

  vText # '';
  if (Prj.Termin.Start<>0.0.0) then
    vText # cnvad(Prj.Termin.Start)+' ';
  if (Prj.Termin.Ende<>0.0.0) then
    vText # 'bis '+cnvad(Prj.Termin.Ende);
  if (vText<>'') then begin
    pl_PrintLine;
    Pl_Print('ca.Zeitraum : '+vText+' u.V.' ,cPos0 );
    pl_PrintLine;
  end;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    pls_FontSize  # 9;
    PL_PrintLine;
    PL_Print('Wir danken für Ihre Anfrage, die wir gemäss unserer Ihnen bekannten allgemeinen Verkaufsbedingungen',cPos0);
    PL_PrintLine;
    PL_Print('wie folgt anbieten:',cPos0);
    PL_PrintLine;
    PL_PrintLine;

  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Fontattr # _WinFontAttrBold;
    pls_Inverted  # false;

    pls_Hdl->ppColBkg # _WinColLightGray;
    PL_Print_R('Pos.',cPos2-2.0);

    pls_Hdl->ppColBkg # _WinColLightGray;
    PL_Print('Beschreibung',cPos2);

    pls_Hdl->ppColBkg # _WinColLightGray;
    PL_Print_R('Menge',cPos3);

    pls_Hdl->ppColBkg # _WinColLightGray;
    PL_Print_R('Preis/€',cPos4);

    PL_Drawbox(cPos0-1.0,cPos4+1.0,_WinColLightGray, 5.0);
    PL_PrintLine;

    pls_Fontattr # _WinFontAttrNormal;
  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx         : int;
  vNummer     : int;        // Dokumentennummer
  vPL         : int;        // Printline

  vHdl        : int;        // Elementdescriptor

  vHeader     : int;
  vFooter     : int;

//  vSum        : float;
  vTxtName    : alpha;

  vMFile,vMID : int;
  vItem       : handle;
  vSelName    : alpha;
  vSel        : int;

  vWartung    : alpha;

  vPosPreis   : float;
  vErg        : int;

  vZusatzPrinted  : logic;
  vSumMenge   : float;
  vSumPreise  : float;
  vSumZusatz  : float;
end;
begin

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Header und Footer EINMALIG vorher laden
  vHeader # 0;//PrtFormOpen(_PrtTypePrintForm,'FRM.PRJ.MitBild.Kopf');
  vFooter # 0;//PrtFormOpen(_PrtTypePrintForm,'');

  // Job Öffnen + Page srstellen
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  // Dokumentendialog initialisieren
  Lib_Print:FrmPrintDialog(form_Dokname);

  // Adresse lesen
  RecLink(100,120,1,_RecFirst);

  // Verband lesen um Wartungsinfo zu bekommen
  vWartung # '';
  if (RecLink(110,100,16,0) <= _rLocked) then begin
    if (Ver.Name <> '') then
      vWartung # ' / '+Ver.Name;
  end;



  // Seitenkopf drucken
  Lib_Print:Print_Seitenkopf();

// -------- Druck starten ----------------------------------------------------------------


  // Positionen drucken
  // Selektion erstellen und später füllen
  vSel # SelCreate(122,1);
  // Selektion starten...
  vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen
  vSel # SelOpen();                       // Selektion öffnen
  vSel->selRead(122,_SelLock,vSelName);   // Selektion laden

  // Markierte Positionen in Selektion rein, um nach Position zu sortieren
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
    if (vMFile = 122) then begin
      RecRead(122,0,_RecId,vMID);
      if (Prj.P.Nummer = Prj.Nummer) then
        Erx # SelRecInsert(vSel,122);
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;


  // Daten aus Selektion ausgeben
  Erx # RecRead(122,vSel,_RecFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN

    // nur Positionen mit Angebotsdauer drucken !!!
    if (Prj.P.Dauer.Angebot<>0.0) then begin

      // Kopfdaten lesen
      RecLink(120,122,2,0);

      vPosPreis # Prj.P.Dauer.Angebot * Prj.Cust.Wert1;

      if (Prj.P.Dauer.Angebot = 0.01) then begin
        Prj.P.Dauer.Angebot #  0.0;
        vPosPreis           # 0.0;
      end;

      PL_PrintLine;

      pls_FontSize  # 9;
      PL_PrintI(Prj.P.Position, cPos2-2.0);
      PL_Print(Prj.P.Bezeichnung, cPos2);

      PL_PrintF(Prj.P.Dauer.Angebot, 1, cPos3);
      PL_Print('h', cPos3+1.0);

      PL_PrintF(vPosPreis, 2, cPos4);
      PL_Printline;

      // Nach "Zusatzkosten" suchen
      vZusatzPrinted  # false;
      FOR  vErg # RecLink(123,122,1, _recFirst);
      LOOP vErg # RecLink(123,122,1, _recNext);
      WHILE (vErg <= _rLocked) DO BEGIN
        if (Prj.Z.ZusKosten <> 0.0) then begin
          pls_FontSize  # 9;

          PL_Print(Prj.Z.Bemerkung, cPos2);
          PL_PrintF(Prj.Z.ZusKosten, 2, cPos4);
          PL_Printline;
          vSumPreise      # vSumPreise + Prj.Z.ZusKosten;
          vSumZusatz      # vSumZusatz + Prj.Z.ZusKosten
          vZusatzPrinted  # true;
        end;
      END;

      if (vZusatzPrinted) then begin
          pls_FontSize  # 2;
          PL_PrintLine;
          pls_FontSize  # 9;
      end;

      // Text drucken
      vTxtName # Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' );
      Lib_Print:Print_Text(vTxtName,1, cPos2 , cPos3-10.0);

      if(Prj.P.Dauer.Angebot<999.0) then begin
        vSumMenge # vSumMenge + Prj.P.Dauer.Angebot;
        vSumPreise  # vSumPreise + vPosPreis;
      end;
    end;

    Erx # RecRead(122,vSel,_RecNext);
  END;


  // Selektion schließen und löschen
  SelClose(vSel);
  SelDelete(122, vSelName);
  vSel # 0;


  Lib_Print:Print_LinieEinzeln(cPos0,cPos4+1.0);
  Pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;

  PL_PrintF(vSumMenge, 1, cPos3);
  PL_PrintF(vSumPreise, 2, cPos4);

  PL_PrintLine;

  form_Mode # 'FUSS';

  PL_PrintLine;
  PL_PrintLine;
  pls_FontSize  # 9;
  pls_Fontattr # _WinFontAttrNormal;
  PL_Print('Es handelt sich um eine Aufwandsschätzung. Berechnung nach tatsächlichem Stundenaufwand, sofern',cPos0);
  PL_PrintLine;
  PL_Print('nicht anders vermerkt. Es gelten unsere Allgemeinen Geschäftsbedingungen.',cPos0);
  PL_PrintLine;
  PL_PrintLine;

  if (vSumMenge > 0.0) then begin
    PL_Print('Stundensatz: ' + ANum(Prj.Cust.Wert1,2) + ' EUR' + vWartung,cPos0);
    PL_PrintLine;
    PL_Print('Aufwand: ' + ANum(vSumMenge,2) + ' Stunden = ' +ANum(vSumMenge*Prj.Cust.Wert1,2)+ ' EUR' ,cPos0);
    PL_PrintLine;
  end;

  if (vSumZusatz > 0.0) then begin
    PL_Print('Zusatzkosten: ' + ANum(vSumZusatz,2) + ' EUR' ,cPos0);
    PL_PrintLine;
  end;

  PL_Print('Gesamtpreis ca: ' + ANum(vSumPreise,2) + ' EUR zzgl. Mwst.',cPos0);
  PL_PrintLine;
  PL_PrintLine;

  Pls_fontSize # 9;
  // Fusstext drucken
  vTxtName # '~120.'+CnvAI(Prj.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'';
  Lib_Print:Print_Text(vTxtName,1, cPos0 , cPos4);

  // -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================