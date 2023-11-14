@A+
//==== Business-Control ==================================================
//
//  Prozedur    F_STD_OfP_Konto
//                    OHNE E_R_G
//  Info        Kontoauszug eines Kunden (OP Liste)
//
//
//  08.01.2008  DS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB HoleEmpfaenger();
//    SUB SeitenKopf();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
  cPos0   :  10.0 // Anschrift Seitenkopf
  cPos1   :  10.0 // ReNr
  cPos2   :  60.0 // ReDatum
  cPos4   :  95.0 // überfällig
  cPos6   : 135.0 // Rechnungsbetrag
  cPos8   : 180.0 // offen
  cPosKopf1 : 120.0 //Seitenkopf
  cPosKopf2 : 155.0 //Seitenkopf
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
                + CnvAD(Sysdate());                                              // Mahndatum
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
begin

//...setzt Fax und Mailadresse!

  Form_FaxNummer  # Adr.Telefax;
  Form_EMA        # Adr.eMail;
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  Pls_fontSize # 6;
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.Anrede   , cPos0);
  PL_PrintLine;

  PL_Print(Adr.Name     , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Kundennr.:',cPosKopf1);
  PL_PrintI_L(Adr.KundenNr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Unsere Lf.Nr.:',cPosKopf1);
  PL_Print(Adr.VK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre USt.Id-Nr.:',cPosKopf1);
  PL_Print(Adr.USIdentNr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.Plz+' '+Adr.Ort, cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Steuernr.:',cPosKopf1);
  PL_Print(Adr.Steuernummer,cPosKopf2);
  PL_PrintLine;

  RecLink(812,100,10,_recFirst);   // Land holen
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  Pls_fontSize # 9;
  PL_Print('Datum:',cPosKopf1);
  PL_PrintD_L(today,cPosKopf2);
  PL_PrintLine;

  PL_Print('Seite:',cPosKopf1);
  PL_PrintI_L(aSeite,cPosKopf2);
  PL_PrintLine;

  PL_PrintLine;
  PL_PrintLine;

  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  Pl_Print('Kontoauszug Stand'+ ' '+ CnvAD(TODAY)  ,cPos0 );
  pl_PrintLine;

  //Pls_FontSize # 9;
  pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('Bitte gleichen Sie nachstehende Beträge mit Ihrer Buchhaltung ab.',cPos0);
    PL_PrintLine;
    PL_PrintLine;

  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('Re.Nr',cPos1);
    PL_Print_R('Re.Datum',cPos2);
    PL_Print_R('Fälligkeit',cPos4);
    PL_Print_R('Re.Betrag '+"Set.Hauswährung.Kurz",cPos6);
    PL_Print_R('off.Betrag '+"Set.Hauswährung.Kurz",cPos8);
    PL_Drawbox(cPos0-1.0,cPos8+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx             : int;
  // Druckspezifische Variablen
  vHeader         : int;
  vFooter         : int;
  vPLHeader       : int;
  vPLFooter       : int;
  vPL             : int;

  vFlag           : int;

  // für Summierungen
  vBetragGesamt   : float;
  vBetragFaellig  : float;
end;

begin

  // nur aktuellen Ofp.Kunden mahnen
  Erx # RecLink(100,460,4,_recFirst); // Kunde holen
  if (Erx>_rLocked) then RETURN;

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y ,vHeader, vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);


// ------- KOPFDATEN -----------------------------------------------------------------------
  form_FaxNummer  # Adr.Telefax;
  Form_EMA        # Adr.EMail;
  Lib_Print:Print_Seitenkopf();

// ------- POSITIONEN --------------------------------------------------------------------------

  Form_Mode # 'POS';
  vFlag # _RecFirst;
  Pls_Fontattr # 0;
  Pls_fontSize # 10;
  vBetragGesamt # 0.00;
  vBetragFaellig # 0.00;
  WHILE (RecLink(460,100,26,vFlag) <= _rLocked ) DO BEGIN         // alle offenen Posten des Kunden
    vFlag # _RecNext;

    if ("OFP.Löschmarker"='*') then CYCLE;

    vBetragGesamt # vBetragGesamt + OFP.RestW1;
    if (OFP.Zieldatum <= TODAY) then
      vBetragFaellig # vBetragFaellig + OFP.RestW1;
    PL_PrintI_L(OFP.Rechnungsnr,  cPos1);
    PL_PrintD(OFP.Rechnungsdatum, cPos2);
    PL_PrintD(OFP.Zieldatum,      cPos4);
    PL_PrintF(OFP.BruttoW1,2,     cPos6);
    PL_PrintF(OFP.RestW1,  2,     cPos8);
    PL_PrintLine;
  END;

  Lib_Print:Print_LinieDoppelt();

  // Summierungen ausdrucken
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Gesamt:',cPos4);
  PL_PrintF(vBetragGesamt,2,cPos8);
  PL_PrintLine;
  PL_Print('Fällig:',cPos4);
  PL_PrintF(vBetragFaellig,2,cPos8);
  PL_PrintLine;
  pls_Fontattr # 0;

  Form_Mode # 'FUSS';

  //Leerzeilen
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  PL_Print('Mit freundlichen Grüßen',cPos0);
  PL_PrintLine;
  PL_PrintLine;
  PL_Print(Set.mfg.Text, cPos0);
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

end;

//========================================================================