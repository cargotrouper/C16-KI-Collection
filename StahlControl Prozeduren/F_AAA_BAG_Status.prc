@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_BAG_Status
//                      OHNE E_R_G
//  Info
//    Druckt einen BA-Status aus
//
//
//  22.11.2012  AI  Erstellung der Prozedur
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB HoleEmpfaenger();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Form

define begin
//  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
end;

local begin
  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;

  elKopftext          : int;
  elFusstext          : int;

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

  elFMUS              : int;
  elFM1               : int;
  elFM2               : int;
  elFMFuss            : int;

  elBeistellUS        : int;
  elBeistell1         : int;
  elBeistell2         : int;
  elBeistellFuss      : int;

  elEnde1             : int;
  elEnde2             : int;
  elEnde3             : int;
  elLeerzeile         : int;

  // Variablen.........
  vStartAS            : int;
  vZielAS             : int;
  vKundenAdr          : int;

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
    Form_Ele_LohnBAG:elErsteSeite(var elErsteSeite, vStartAS, vZielAS, vKundenAdr);
    end
  else begin
    Form_Ele_LohnBAG:elFolgeSeite(var elFolgeSeite, vStartAS, vZielAS, vKundenAdr);
  end;

  if (Form_Mode = 'EINSATZ') then begin
    Form_Ele_LohnBAG:elEinsatzUS(var elEinsatzUS);
  end;

  if (Form_Mode = 'FERTIGUNG') then begin
    Form_Ele_LohnBAG:elFertigungUS(var elFertigungUS);
  end;

  if (Form_Mode = 'VERPACKUNG') then begin
    Form_Ele_LohnBAG:elVerpackungUS(var elVerpackungUS);
  end;

  if (Form_Mode = 'FERTIGMELDUNG') then begin
    Form_Ele_LohnBAG:elFMUS(var elFMUS);
  end;

  if (Form_Mode = 'BEISTELLUNG') then begin
    Form_Ele_LohnBAG:elBeistellUS(var elBeistellUS);
  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  form_Elemente:elSeitenFuss(var elSeitenFuss, true);
end;


//========================================================================
//========================================================================
Sub PrintEinsatz(
  var aElUS   : int;
  var aEl1    : int;
  var aEl2    : int;
  var aElFuss : int;
);
local begin
  Erx       : int;
  vLfdNr  : int;
  vMEH    : alpha;
  vM      : float;
  vStk    : int;
  vGewN   : float;
  vGewB   : float;
end;
begin

  // Fertigungskopf ausgeben und Modusfür Seitenwechsel
  Form_Mode # '';
  Form_Ele_LohnBAG:elEinsatzUS(var aElUS);
  Form_Mode # 'EINSATZ';            // Einsatzkop drucken
  vlfdNr  # 0;
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.BruderID<>0) then CYCLE;

    inc(vlfdNr);

    // Material lesen
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
      end
    else begin
      RecbufClear(200);
    end;

    Form_Ele_LohnBAG:elEinsatz1(var aEl1, vLfdNr);
    vStk   # vStk   + BAG.IO.Plan.Out.Stk;
    vGewN  # vGewN  + BAG.IO.Plan.Out.GewN;
    vGewB  # vGewB  + BAG.IO.Plan.Out.GewB;
    if (vMEH='') then vMEH # BAG.IO.MEH.Out
    if (vMEH=BAG.IO.MEH.Out) then
      vM   # vM     + BAG.IO.Plan.Out.Meng;
    Form_Ele_LohnBAG:elEinsatz2(var aEl2, vLfdNr);
  END;

  // Summen drucken
  RecBufClear(701);
  BAG.IO.Plan.Out.Stk   # vStk;
  BAG.IO.Plan.Out.GewN  # vGewN;
  BAG.IO.Plan.Out.GewB  # vGewB;
  BAG.IO.Plan.Out.Meng  # vM;
  BAG.IO.MEH.Out        # vMEH;
  Form_Ele_LohnBAG:elEinsatzFuss(var aElFuss);
end;


//========================================================================
//========================================================================
sub PrintFertigung(
  var aElUS   : int;
  var aEl1    : int;
  var aEl2    : int;
  var aElFuss : int;
  var aVPG    : alpha);
local begin
  Erx       : int;
  vMEH    : alpha;
  vM      : float;
  vStk    : int;
  vGewN   : float;
  vGewB   : float;
  vBreite : float;
end;
begin
  // Fertigungskopf ausgeben und Modusfür Seitenwechsel
  Form_Mode # '';
  Form_Ele_LohnBAG:elFertigungUS(var aElUS);
  Form_Mode # 'FERTIGUNG';

  FOR Erx # RecLink(703,702,4,_recfirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.F.WirdEigenYN) then CYCLE;

    Form_Ele_LohnBAG:elFertigung1(var aEl1);
    if (BAG.F.Fertigung<999) then begin
      vStk   # vStk   + "BAG.F.Stückzahl";
      vGewN  # vGewN  + BAG.F.Gewicht;
      vBreite # vBreite + (BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl));
      if (vMEH='') then vMEH # BAG.F.MEH;
      if (vMEH=BAG.F.MEH) then
        vM   # vM     + BAG.F.Menge;
    end;
    Form_Ele_LohnBAG:elFertigung2(var aEl2);

    if (BAG.F.Verpackung<>0) then begin
      if (StrFind(aVpg,AInt(Bag.F.Verpackung)+'|',0) = 0) then
        aVpg # aVpg + AInt(Bag.F.Verpackung)+'|';
    end;

  END;

  // Summen drucken
  RecBufClear(703);
  "BAG.F.Stückzahl" # vStk;
  BAG.F.Gewicht     # vGewN;
  BAG.F.Breite      # vBreite;
  BAG.F.Menge       # vM;
  BAG.F.MEH         # vMEH;
  Form_Ele_LohnBAG:elFertigungFuss(var aElFuss);
end;


//========================================================================
//========================================================================
sub PrintVerpackung(
  var aElUS     : int;
  var aEl1      : int;
  var aEl2      : int;
  var aElFuss   : int;
  aVPG          : alpha(1000));
local begin
  Erx       : int;
  vI      : int;
  vCount  : int;
end;
begin

  if (aVpg = '') then RETURN;
  vCount  # Lib_Strings:Strings_Count(aVpg,'|');

  Form_Mode # '';
  // Verpackunkopf ausgeben und Modusfür Seitenwechsel
  Form_Ele_LohnBAG:elVerpackungUS(var aElUS);
  Form_Mode # 'VERPACKUNG';

  BAG.Vpg.Nummer # BAG.Nummer;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vCount) DO BEGIN
    Bag.Vpg.Verpackung #  CnvIa(Lib_Strings:Strings_Token(aVpg,'|',vI));
    Erx # RecRead(704,1,0);
    if (Erx > _rLocked) then CYCLE;
    Form_Ele_LohnBAG:elVerpackung1(var aEl1);
    Form_Ele_LohnBAG:elVerpackung2(var aEl2);
  END;

  Form_Ele_LohnBAG:elVerpackungFuss(var aElFuss);
end;


//========================================================================
//========================================================================
Sub PrintFertigmeldung(
  var aElUS   : int;
  var aEl1    : int;
  var aEl2    : int;
  var aElFuss : int;
);
local begin
  Erx       : int;
  vLfdNr  : int;
  vMEH    : alpha;
  vM      : float;
  vStk    : int;
  vGewN   : float;
  vGewB   : float;
end;
begin

  // Fertigungskopf ausgeben und Modus für Seitenwechsel
  Form_Mode # '';
  Form_Ele_LohnBAG:elFMUS(var aElUS);
  Form_Mode # 'FERTIGMELDUNG';            // Einsatzkop drucken
  vlfdNr  # 0;
  FOR Erx # RecLink(707,702,5,_recFirst)
  LOOP Erx # RecLink(707,702,5,_recNext)
  WHILE (Erx<=_rLocked) do begin

    inc(vlfdNr);

    // Material lesen
    if (BAG.FM.Materialtyp=c_IO_Mat) then begin
      Mat_Data:Read(BAG.FM.Materialnr);
      end
    else begin
      RecbufClear(200);
    end;

    Form_Ele_LohnBAG:elFM1(var aEl1);
    vStk   # vStk   + "BAG.FM.Stück";
    vGewN  # vGewN  + BAG.FM.Gewicht.Netto;
    vGewB  # vGewB  + BAG.FM.Gewicht.Brutt;
    if (vMEH='') then vMEH # BAG.FM.MEH;
    if (vMEH=BAG.FM.MEH) then
      vM   # vM     + BAG.FM.Menge;
    Form_Ele_LohnBAG:elFM2(var aEl2);
  END;

  // Summen drucken
  RecBufClear(707);
  "BAG.FM.STück"    # vStk;
  BAG.FM.Gewicht.Netto  # vGewN;
  BAG.FM.Gewicht.Brutt  # vGewB;
  BAG.FM.Menge          # vM;
  BAG.FM.MEH            # vMEH;
  BAG.FM.Fertigmeldung  # vLfdNr;
  Form_Ele_LohnBAG:elFMFuss(var aElFuss);
end;


//========================================================================
//========================================================================
Sub PrintBeistellung(
  var aElUS   : int;
  var aEl1    : int;
  var aEl2    : int;
  var aElFuss : int;
);
local begin
  Erx       : int;
  vLfdNr  : int;
end;
begin

  // Fertigungskopf ausgeben und Modusfür Seitenwechsel
  Form_Mode # '';
  Form_Ele_LohnBAG:elBeistellUS(var aElUS);
  Form_Mode # 'BEISTELLUNG';            // Einsatzkop drucken
  vlfdNr  # 0;
  FOR Erx # RecLink(708,702,19,_recFirst)
  LOOP Erx # RecLink(708,702,19,_recNext)
  WHILE (Erx<=_rLocked) do begin

    inc(vlfdNr);

    Erx # RekLink(250,708,1,_RecFirst);     // Artikel holen
    Erx # RekLink(252,708,2,_RecFirst);     // Artikelcharge holen

    Form_Ele_LohnBAG:elBeistell1(var aEl1);
    Form_Ele_LohnBAG:elBeistell2(var aEl2);
  END;

  Form_Ele_LohnBAG:elBeistellFuss(var aElFuss);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx         : int;
  vVPG        : alpha(1000);
  vVPGCount   : int;
end;
begin

  // LOOP **********************************************************
  Erx # RecLink(702,700,1,_recFirst);       // Positionen loopen
/***
  WHILE (Erx<=_rLocked) do begin


    if (BAG.P.Aktion=c_BAG_VSB) then begin  // VSBs überspringen
      Erx # RecLink(702,700,1,_recNext);
      CYCLE;
    end;
***/

// ------ Druck vorbereiten ----------------------------------------------------------------
  RecBufClear(100);
  RecBufClear(101);
  RecbufClear(812);
  if (BAG.P.ExterneLiefNr<>0) then begin
    Erx # RekLink(100,702,7,_recFirst);                 // Lohnbetrieb lesen
    if (Erx<=_rLocked) then begin
      Erx # RekLink(101,100,12,_recFirst);                  // erste Anschrift lesen
      Erx # RekLink(812,101,2,_recFirst);               // Land holen
      if ("Lnd.kürzel"='D') or ("Lnd.kürzel"='DE') then
        RecbufClear(812);
    end;
  end;
  // LohnKunde holen...
  if (BAG.P.Auftragsnr<>0) then begin
    if (Auf_Data:Read(BAG.P.Auftragsnr, BAG.P.Auftragspos, n)>=400) then begin
      Erx # ReKLinkB(vKundenAdr, 401,4,_recFirst);
    end;
  end;

  vStartAS # RecBufCreate(101);
  vZielAS  # RecBufCreate(101);
  if (BAG.P.Zieladresse<>0) then
    Erx # RekLink(vZielAS,702,13,_recFirst);    // Zielanschrift holen

  FOR Erx # RecLink(701,702,2,_recFirst)            // 1. Einsatz suchen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID<>0) then CYCLE;
    if (BAG.IO.Lageradresse=0) then CYCLE;
    Erx # RekLink(vStartAS, 701, 6, _recfirst); // Startanschrift holen
    if (Erx<=_rLocked) then BREAK;
    RecBufClear(vStartAS);
  END;


  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
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

  // Kopftext drucken
  Form_Elemente:elKopftext(var elKopftext, '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K');

// ------- EINSATZMATERIAL -----------------------------------------------------------------

  form_Elemente:elLeerzeile(var elLeerzeile);
  PrintEinsatz(var elEinsatzUS, var elEinsatz1, var elEinsatz2, var elEinsatzFuss);

// ------- FERTIGUNGEN ---------------------------------------------------------------------

  form_Elemente:elLeerzeile(var elLeerzeile);
  PrintFertigung(var elFertigungUS, var elFertigung1, var elFertigung2, var elFertigungFuss, var vVPG);

// ------- VERPACKUNGEN ----------------------------------------------------------------------

  form_Elemente:elLeerzeile(var elLeerzeile);
  PrintVerpackung(var elVerpackungUS, var elVerpackung1, var elVerpackung2, var elVerpackungFuss, vVpg);

// ------- FERTIGMELDUNGEN -------------------------------------------------------------------

  form_Elemente:elLeerzeile(var elLeerzeile);
  PrintFertigmeldung(var elFMUS, var elFM1, var elFM2, var elFMFuss);

// ------- BEISTELLUNGEN ---------------------------------------------------------------------

  form_Elemente:elLeerzeile(var elLeerzeile);
  PrintBeistellung(var elBeistellUS, var elBeistell1, var elBeistell2, var elBeistellFuss);


// ------- FUßDATEN --------------------------------------------------------------------------
  form_Mode # 'FUSS';

  form_Elemente:elLeerzeile(var elLeerzeile);

  // Fusstext drucken
  Form_Elemente:elFusstext(var elFusstext, '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F');

  form_Ele_LohnBAG:elEnde1(var elEnde1, vStartAS, vZielAS, vKundenAdr);
  form_Ele_LohnBAG:elEnde2(var elEnde2, vStartAS, vZielAS, vKundenAdr);
  form_Ele_LohnBAG:elEnde3(var elEnde3, vStartAS, vZielAS, vKundenAdr);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  if (vKundenAdr<>0) then RecBufDestroy(vKundenAdr);
  RecBufDestroy(vStartAS);
  RecBufDestroy(vZielAS);

  // Objekte entladen
  FreeElement(var elErsteSeite        );
  FreeElement(var elFolgeSeite        );
  FreeElement(var elSeitenFuss        );

  FreeElement(var elKopftext          );
  FreeElement(var elFusstext          );

  FreeElement(var elEinsatzUS         );
  FreeElement(var elEinsatz1          );
  FreeElement(var elEinsatz2          );
  FreeElement(var elEinsatzFuss       );
  FreeElement(var elFertigungUS       );
  FreeElement(var elFertigung1        );
  FreeElement(var elFertigung2        );
  FreeElement(var elFertigungFuss     );
  FreeElement(var elVerpackungUS      );
  FreeElement(var elVerpackung1       );
  FreeElement(var elVerpackung2       );
  FreeElement(var elVerpackungFuss    );
  FreeElement(var elFMUS              );
  FreeElement(var elFM1               );
  FreeElement(var elFM2               );
  FreeElement(var elFMFuss            );
  FreeElement(var elBeistellUS        );
  FreeElement(var elBeistell1         );
  FreeElement(var elBeistell2         );
  FreeElement(var elBeistellFuss      );

  FreeElement(var elEnde1             );
  FreeElement(var elEnde2             );
  FreeElement(var elEnde3             );
  FreeElement(var elLeerzeile         );

end;

//========================================================================