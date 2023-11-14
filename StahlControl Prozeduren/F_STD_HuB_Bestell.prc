@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_HuB_Bestell
//                      OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  01.03.2006  AI  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
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

  cPos1   :  10.0 // Pos
  cPos2   :  20.0 // Bez.
  cPos3   :  90.0 // Menge1
  cPos3a  :  90.0
  cPos3b  :  92.0
  cPos4   : 110.0 // Menge2
  cPos4a  : 110.0
  cPos4b  : 112.0
  cPos5   : 143.0 // Einzelpreis
  cPos5a  : 130.0
  cPos5b  : 143.0
  cPos5c  : 144.0
  cPos6   : 165.0 // Rabatt
  cPos7   : 182.0 // Gesamt
  cPosFuss2 : 50.0
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
  RecLink(100,190,2,_RecFirst);   // Lieferant holen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(HuB.EK.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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
  // Daten aus Bestellung holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,190,2,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
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
begin
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
  vHead_info1         : alpha;
  vHead_text1         : alpha;
  vHead_info2         : alpha;
  vHead_text2         : alpha;
  vHead_info3         : alpha;
  vHead_text3         : alpha;
  vHead_info4         : alpha;
  vHead_text4         : alpha;
  vHead_info5         : alpha;
  vHead_text5         : alpha;
  vHead_info6         : alpha;
  vHead_text6         : alpha;
  vHeadertext         : alpha;
  vTxtName            : alpha;

  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers

  // Für Verpackungsdruck
  vVerpackung         : alpha(720);

  // Für Mehrwertsteuer
  vMwstSatz1          : float;
  vMwstWert1          : float;
  vMwstSatz2          : float;
  vMwstWert2          : float;
  vMwstText           : alpha;

  // Für Preise
  vGesamtNettoRabBar  : float;
  vGesamtNetto        : float;
  vGesamtMwSt         : float;
  vGesamtBrutto       : float;

  vPosNettoRabBar     : float;
  vPosNetto           : float;
  vPosMwSt            : float;

  vPosCount           : int;
  vKopfaufpreis       : float;
  vPosStk             : int;
  vPosGewicht         : float;
  vPosMenge           : float;
  vPosAnzahlAkt       : int;
  vMenge              : float;
  vPreis              : float;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  vNummer             : int;        // Dokumentennummer
  vFlag               : int;        // Datensatzlese option
end;
begin

  // ------ Druck vorbereiten ----------------------------------------------------------------
  RecLink(100,190,2,_RecFirst);   // Lieferant holen
  RecLink(814,190,3,_RecFirst);   // Währung holen


  // Seitenkopf zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  PL_Create(vPLHeader);
  vHeader   # pls_Prt;
  pls_FontSize # 10;
  PL_Print('Pos.',cPos1);
  PL_Print('Beschreibung',cPos2);
  PL_Print_R('Menge',cPos3);
  PL_Print_R('E-Preis '+"Wae.Kürzel",cPos5);
  PL_Print_R('Gesamt',cPos7);

  vFooter # 0;

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();


  vAdresse    # Adr.Nummer;
  vHead_info1 # translate('Bestellnummer');
  vHead_text1 # AInt(HuB.EK.Nummer);
  vHead_info2 # translate('Bestelldatum');
  vHead_text2 # CnvAd(HuB.EK.Datum);
  vHead_info3 # translate('Lieferantenummer');
  vHead_text3 # AInt(Hub.EK.Lieferant);
  vHead_info4 # translate('Uns. Kunden.-Nr');
  vHead_text4 # Adr.EK.Referenznr;

  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  // Anschrift setzen
  //Lib_Print:Print_AnschriftEx(2.0, 6.0, 12.5, 7.6,vHead_info1,vHead_text1,vHead_info2,vHead_text2,vHead_info3,vHead_text3,vHead_info4,vHead_text4,vHead_info5,vHead_text5);

  Lib_Print:Print_Betreff(translate('Bestellung ') + AInt(HuB.EK.Nummer));

  // Kopftext drucken
//  vTxtName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
//  Lib_Print:Print_Text(vTxtName,1);

  // Kopf einmal drucken
  Lib_Print:LfPrint(vHeader,y);
  Lib_Print:Print_LinieDoppelt();


  vMwstSatz1 # -1.0;
  vMwstSatz2 # -1.0;
// ------- POSITIONEN --------------------------------------------------------------------------

  vFlag # _RecFirst;
  WHILE (RecLink(191,190,1,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    if ("HUB.EK.P.Löschmarker"='*') then CYCLE;

    // HuB-Artikel lesen
    Erx # RecLink(180,191,2,_RecFirst);
    If (Erx = _rNoRec) then CYCLE;

    // Position ausgeben.....
    Inc(vPosCount);


    vPosMenge # HuB.EK.P.Menge.Best;
    vPreis # Rnd(HuB.EK.P.Preis *  vPosMenge / CnvFI(HuB.EK.P.PEH) ,2);


    // Position zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    PL_Print(AInt(HuB.EK.P.Nummer),cPos1);
    PL_Print(HuB.Bezeichnung1,cPos2);
    PL_PrintF(vPosMenge,2,cPos3a);
    PL_Print(HuB.EK.P.MEH,cPos3b);
    PL_PrintF(HuB.EK.P.Preis,2,cPos5a);
    PL_Print('je',cPos5a+0.8);
    PL_PrintI(HuB.EK.P.PEH,cPos5b);
    PL_Print(HuB.EK.P.MEH,cPos5c);
    PL_PrintF(vPreis,2,cPos7);
    PL_PrintLine;


    vPosMwSt        # 0.0;
    vPosAnzahlAkt   # 0;
    vPosGewicht     # 0.0;
    vPosStk         # 0;
    vPosNettoRabBar # vPreis;
    vPosNetto       # vPreis;



    // Mehrwertsteuersätze
    Erx #RecLink(819, 180, 3, _recFirst); // Warengrupppe lesen
    if(Erx > _rLocked) then
      RecBufClear(819);

    StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
    Erx # RecRead(813,1,0);
    //if (Erx>_rLocked) then ABBRUCH(400098,0);
    vPosMwst # StS.Prozent;

    if (vMwstSatz1=-1.0) then begin
      vMwstSatz1 # vPosMwSt;
      vMwstWert1 # vPosNetto;
      end
    else if (vMwstSatz1=vPosMwst) then begin
      vMwstWert1 # vMwstWert1 + vPosNetto;
      end
    else if (vMwstSatz2=-1.0) then begin
      vMwstSatz2 # vPosMwSt;
      vMwstWert2 # vPosNetto;
      end
    else if (vMwstSatz2=vPosMwst) then begin
      vMwstWert2 # vMwstWert2 + vPosNetto;
      end;
/*    else
      ABBRUCH(4000099,0);
  */

    // Positionszusatz ausgeben
    if (HuB.EK.P.Bemerkung <> '') then begin
      PL_PrintLine;
      PL_Print(HuB.EK.P.Bemerkung,cPos2);
      PL_PrintLine;
    end;

    vGesamtNettoRabBar  # vGesamtNettoRabBar + vPosNettoRabBar;
    vGesamtNetto        # vGesamtNetto + vPosNetto;

    // Leerzeile zwischen den Positionen
    PL_PrintLine;


  END; // WHILE: Positionen ************************************************



  // ------- FUßDATEN --------------------------------------------------------------------------
  Lib_Print:Print_LinieDoppelt();

  // Mehrwertstuern errechnen
  if (vMwStSatz1<>0.0) then vMwStWert1 # Rnd(vMwstWert1 * (vMwstSatz1/100.0),2)
  else vMwStWert1 # 0.0;
  if (vMwStSatz2>0.0) then vMwStWert2 # Rnd(vMwstWert2 * (vMwstSatz2/100.0),2)
  else vMwStWert2 # 0.0;
  vGesamtBrutto # Rnd(vGesamtNetto + vMwstWert1 + vMwstWert2,2);

  // Summen drucken
  pls_Fontsize # 10;
  PL_Print_R('Summe '+"Wae.Kürzel",cPos7-25.0);
  PL_PrintF(vGesamtNetto,2,cPos7);
  PL_PrintLine;

  pls_Fontsize # 10;
  PL_Print_R(CnvAF(vMwstSatz1) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
  PL_PrintF(vMwstWert1,2,cPos7);
  PL_PrintLine;

  if (vMwstSatz2>0.0) then begin
    pls_Fontsize # 10;
    PL_Print_R(CnvAF(vMwstSatz2) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
    PL_PrintF(vMwstWert2,2,cPos7);
    PL_PrintLine;
  end;

  pls_Fontsize # 10;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print_R('Brutto '+"Wae.Kürzel",cPos7-25.0);
  PL_PrintF(vGesamtBrutto,2,cPos7);
  pls_FontAttr # 0;
  PL_PrintLine;


  PL_PrintLine;

  // Lieferbedinungen und Co drucken
  Erx # RecLink(815,190,5,_RecFirst);   // Lieferbedingung lesen
  Erx # RecLink(816,190,4,_RecFirst);   // Zahlungsbedingung lesen
  Erx # RecLink(817,190,6,_RecFirst);   // Versandart lesen

  PL_Print('Lieferung:',cPos1);
  PL_Print(Lib.Bezeichnung.L1,cPosFuss2);
  PL_PrintLine;
  PL_Print('Zahlung:',cPos1);
  PL_Print(Zab.Bezeichnung1.L1,cPosFuss2);
  PL_PrintLine;
  if (ZaB.Bezeichnung2.L1<>'') then begin
    PL_Print(Zab.Bezeichnung2.L1,cPosFuss2);
    PL_PrintLine;
  end;
  PL_Print('Versandart:',cPos1);
  PL_Print(Vsa.Bezeichnung.L1,cPosFuss2);
  PL_PrintLine;

  PL_PrintLine;

  // Fusstext drucken
//  vTxtName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
//  Lib_Print:Print_Text(vTxtName,1);


  // ggf. hier Texte für Auslandsgeschäfte etc. Drucken

  PL_PrintLine;
  PL_PrintLine;
  PL_Print('mit freudlichen Grüßen',cPos1);
  PL_PrintLine;


  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------


  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================