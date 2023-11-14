@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_ZAu_Avis
//                      OHNE E_R_G
//  Info
//    Druckt eine Zahlungsavis
//
//
//  01.08.2008  MS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  18.02.2013  TM  MFG-Text geprüft und Setting eingesetzt
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB Print(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG
@I:Def_Aktionen

declare Print(aTyp : alpha);

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPos0   :  10.0
  cPos1   :  12.0
  cPos2   :  30.0
  cPos2a  :  50.0
  cPos2b  :  77.0
  cPos2c  :  70.0
  cPos2d  :  80.0
  cPos2f  :  55.0
  cPos2g  :  60.0
  cPos3   :  70.0
  cPos3a  :  90.0
  cPos3b  :  92.0
  cPos3c  : 105.0
  cPos4   : 110.0
  cPos4a  : 110.0
  cPos4b  : 112.0
  cPos5   : 125.0
  cPos5a  : 130.0
  cPos5b  : 143.0
  cPos5c  : 144.0
  cPos6   : 150.0
  cPos7   : 182.0

  cPos8   : 161.0
  cPos9   : 182.0

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 100.0
  cPosKopf4 : 120.0
  cPosKopf5 : 155.0
  cPosKopf6 : 175.0


  cPosFuss1 : 10.0
  cPosFuss2 : 53.0
end;

local begin
  vZeilenZahl         : int;
  vCoord              : float;
  vSumStk             : int;
  vSumGewichtN        : float;
  vSumGewichtB        : float;
  vSumBreite          : float;
  vSumLaenge          : float;

  vAdresse            : int;      // Nummer des Empfängers
  vPreis              : float;
  vFirst              : logic;
  vA                  : alpha;
  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers

  // Für Mehrwertsteuer
  vMwstSatz1          : float;
  vMwstWert1          : float;
  vMwstSatz2          : float;
  vMwstWert2          : float;
  vMwstText           : alpha;
  vPosMwSt            : float;

  // Für Preise
  vGesamtNetto        : float;
  vGesamtNettoRabBar  : float;
  vGesamtMwSt         : float;
  vGesamtBrutto       : float;

  vPosCount           : int;
  vPosAnzahlAkt       : int;

  vMenge              : float;
  vPosMenge           : float;
  vPosGewicht         : float;
  vPosStk             : int;
  vPosNetto           : float;
  vPosNettoRabbar     : float;
  vRB1                : alpha;
  vKopfAufpreis       : float;


  // für Verpckungen als Aufpreise
  vVPGPreis           : float;
  vVPGPEH             : int;
  vVPGMEH             : alpha;

  vWtrverb        : alpha;

  // Lohnbearbeitung
  vGedrucktePos       : int;
  vVerpCheck          : alpha;
  vVerpUsed          : alpha;
  vBAGPrinted       : logic;

  vGesSkonto  : float;
  vGesBetrag  : float;

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
  RecLink(100,565,2,_RecFirst);   // Lieferant holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(ZAu.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx         : int;
  vBuf100     : int;
  vBuf101     : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin

  RecLink(100,565,2,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;


  // Waerung holen
  Wae.Nummer # "ZAu.Währung";
  Erx # RecRead(814,1,0);
  if(Erx > _rLocked) then
    RecBufClear(814);

  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;


  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0);
//  Pls_fontSize # 9;
//  PL_Print('Auftragsnummer:',cPosKopf1);
//  PL_PrintI_L(Auf.Nummer,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Name     , cPos0);
  PL_PrintLine;

  PL_Print(Adr.A.Zusatz   , cPos0);
  PL_PrintLine;

  PL_Print("Adr.A.Straße" , cPos0);
  PL_PrintLine;

  PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
  PL_PrintLine;

  Erx # RecLink(812,101,2,_recFirst);
  if(Erx > _rLocked) then
    RecBufClear(812);

  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;





  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  Pl_Print('Zahlungsavis'+' '+AInt(ZAu.Nummer)   ,cPos0 );
  PL_Print('Datum:',cPosKopf3);
  PL_Print(cnvad(today),cPosKopf4);
  PL_Print('Seite:',cPosKopf5);
  PL_PrintI_L(aSeite,cPosKopf6);
  PL_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    PL_PrintLine;
    PL_Print('Sehr geehrte Damen und Herren,',cPos0);
    PL_PrintLine;
    PL_Print('nachstehende Zahlung über '+ ANum(ZAu.Betrag,2) + ' ' + "Wae.Kürzel" +  ' buchen Sie bitte wie folgt:',cPos0);
    PL_PrintLine;
    PL_PrintLine;
  end; // 1.Seite



  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('ReNr',cPos1);
    PL_Print('ReDatum',cPos2);
    PL_Print_R('ReBetrag',cPos3);
    PL_Print_R('bisherige Zahlungen',cPos4)
    PL_Print_R('Skonto',cPos5);
    PL_Print_R('Zahlbetrag',cPos6);
    PL_Print_R('Offener Betrag',cPos7);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;


end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vText     : alpha;
  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;
  vPoint    : point;
  vName     : alpha;
  vBuf      : int;


  vRestbetrag : float;
  vbisher     : float;

end;
begin

  case aTyp of

    'POS' : begin
      vRestbetrag # ERe.Brutto-ERe.Zahlungen;
      vbisher     # ERe.Zahlungen-ERe.Z.Betrag;
      //vRestbetrag # vRestbetrag  - ERe.Z.Betrag;

      PL_Print(ERe.Rechnungsnr,cPos1);
      PL_Print(cnvAD(ERe.Rechnungsdatum),cPos2);
      PL_Print_R(ANum(ERe.Brutto,2)+' '+"Wae.Kürzel",cPos3);
      PL_Print_R(ANum(vbisher,2)+' '+"Wae.Kürzel",cPos4);
      PL_Print_R(ANum(ERe.Z.Skontobetrag,2)+' '+"Wae.Kürzel",cPos5);
      PL_Print_R(ANum(ERe.Z.Betrag,2)+' '+"Wae.Kürzel",cPos6);
      PL_Print_R(ANum(vRestbetrag,2)+' '+"Wae.Kürzel",cPos7);
      PL_PrintLine;


    end;

    'SUMME' : begin
      PL_Print('Summe:', cPos1);
      PL_Print_R(ANum(vGesSkonto,2)+' '+"Wae.Kürzel",cPos5);
      PL_Print_R(ANum(vGesBetrag,2)+' '+"Wae.Kürzel",cPos6);
      PL_PrintLine;
    end;

  end;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx                 : int;

  // Datenspezifische Variablen
  vTxtName            : alpha;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
end;
begin
  // ------ Druck vorbereiten ----------------------------------------------------------------

  RecLink(100,565,2,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
/*
  RecLink(814,400,8,_RecFirst);   // Währung holen
*/

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

  vAdresse    # Adr.Nummer;
  vMwstSatz1 # -1.0;
  vMwstSatz2 # -1.0;

// ------- POSITIONEN --------------------------------------------------------------------------



  vFlag # _RecFirst;
  WHILE (RecLink(561,565,1,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    // Eingangsrechnung holen
    Erx # RecLink(560,561,1,0);
    if(Erx > _rLocked) then
      RecBufClear(560);

    Print('POS');

    vGesSkonto #  vGesSkonto + ERe.Z.Skontobetrag;
    vGesBetrag #  vGesBetrag + ERe.Z.Betrag;

    // Leerzeile zwischen den Positionen
    PL_PrintLine;

  END; // WHILE: Positionen ************************************************



  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
    PL_PrintLine;
  Lib_Print:Print_LinieDoppelt();
  PRINT('SUMME');
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Mit freundlichen Grüßen',cPos1);
  PL_PrintLine;
  PL_Print(Set.mfg.Text,cPos1);



// -------- Druck beenden ----------------------------------------------------------------

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;


//=======================================================================