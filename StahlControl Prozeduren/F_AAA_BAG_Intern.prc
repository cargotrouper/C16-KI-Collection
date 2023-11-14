@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_BAG_Intern
//                        OHNE E_R_G
//  Info
//    Druckt einen internen BA aus
//
//
//  27.11.2012  AI  Erstellung der Prozedur
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  26.06.2015  ST  WSP Tafel integriert, damit wir ein Tafelformular haben
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
  elSeitenkopf        : int;
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

  elFertZusatzUS      : int;
  elFertZusatz        : int;
  elFertZusatzFuss    : int;

  elVerpackungUS      : int;
  elVerpackung1       : int;
  elVerpackung2       : int;
  elVerpackungFuss    : int;

  elRaster            : int;

  elEnde1             : int;
  elEnde2             : int;
  elEnde3             : int;
  elLeerzeile         : int;

  // Variablen.........
  vKundenAdr          : int;

  gGesamtbreite       : float;
  gGesamtbreiteFert   : float;
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
    Form_Ele_BAG:elSeitenkopf(var elSeitenkopf, 0,0, vKundenAdr);
    end
  else begin
    Form_Ele_BAG:elSeitenkopf(var elSeitenkopf, 0,0, vKundenAdr);
  end;
  FreeElement(var elSeitenkopf);

  if (Form_Mode = 'EINSATZ') then begin
    Form_Ele_BAG:elEinsatzUS(var elEinsatzUS);
  end;

  if (Form_Mode = 'FERTIGUNG') then begin
    Form_Ele_BAG:elFertigungUS(var elFertigungUS);
  end;

  if (Form_Mode = 'FERTZUSATZ') then begin
    Form_Ele_BAG:elFertZusatzUS(var elFertZusatzUS);
  end;

  if (Form_Mode = 'VERPACKUNG') then begin
    Form_Ele_BAG:elVerpackungUS(var elVerpackungUS);
  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  if (Form_mode<>'') then begin
    PrintVLinie(1);
    PrintVLinie(2);
    PrintVLinie(3);
    PrintVLinie(4);
    PrintVLinie(5);
    PrintVLinie(6);
    PrintVLinie(7);
    PrintVLinie(8);
    PrintVLinie(9);
    PrintVLinie(10);
    PrintVLinie(11);
  end;
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
  Erx     : int;
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
  Form_Ele_BAG:elEinsatzUS(var aElUS);
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
      Mat.RAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRIDTlg(BAG.IO.Ist.In.GewN,BAG.IO.Ist.In.Stk,Mat.Breite,Mat.Dichte,BAG.F.RID,BAG.IO.Teilungen);
      Mat.KgMM # BAG.IO.Plan.Out.GewB / Mat.Breite;
      end
    else begin
      RecbufClear(200);
    end;

    Form_Ele_BAG:elEinsatz1(var aEl1, vLfdNr);
    vStk   # vStk   + BAG.IO.Plan.Out.Stk;
    vGewN  # vGewN  + BAG.IO.Plan.Out.GewN;
    vGewB  # vGewB  + BAG.IO.Plan.Out.GewB;
    if (vMEH='') then vMEH # BAG.IO.MEH.Out
    if (vMEH=BAG.IO.MEH.Out) then
      vM   # vM     + BAG.IO.Plan.Out.Meng;
    Form_Ele_BAG:elEinsatz2(var aEl2, vLfdNr);
  END;

  // Summen drucken
  RecBufClear(701);
  BAG.IO.Plan.Out.Stk   # vStk;
  BAG.IO.Plan.Out.GewN  # vGewN;
  BAG.IO.Plan.Out.GewB  # vGewB;
  BAG.IO.Plan.Out.Meng  # vM;
  BAG.IO.MEH.Out        # vMEH;
  Form_Ele_BAG:elEinsatzFuss(var aElFuss);
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
  Form_Ele_BAG:elFertigungUS(var aElUS);
  Form_Mode # 'FERTIGUNG';

  FOR Erx # RecLink(703,702,4,_recfirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // Verpackung holen
    Erx # RekLink(704,703,6,_recFirst);
    If ((BAG.Vpg.Nummer=0) or (Erx>_rLocked)) then RecBufClear(704);

    Form_Ele_BAG:elFertigung1(var aEl1);
    if (BAG.F.Fertigung<999) then begin
      vStk   # vStk   + "BAG.F.Stückzahl";
      vGewN  # vGewN  + BAG.F.Gewicht;
      vBreite # vBreite + (BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl));
      if (vMEH='') then vMEH # BAG.F.MEH;
      if (vMEH=BAG.F.MEH) then
        vM   # vM     + BAG.F.Menge;
    end;
    Form_Ele_BAG:elFertigung2(var aEl2);

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
  Form_Ele_BAG:elFertigungFuss(var aElFuss);
end;


//========================================================================
//========================================================================
sub PrintFertZusatz(
  var aElUS   : int;
  var aEl     : int;
  var aElFuss : int);
local begin
  Erx       : int;
  vMEH    : alpha;
  vM      : float;
  vStk    : int;
  vGewN   : float;
  vGewB   : float;
  vBreite : float;
  vText   : alpha;
  vTxtBuf : int;
  vOK     : logic;
end;
begin

  vTxtBuf # TextOpen(10);

  // Fertigungskopf ausgeben und Modusfür Seitenwechsel
  Form_Mode # '';

  FOR Erx # RecLink(703,702,4,_recfirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin


    vText # '~703.'+CnvAI(BAG.F.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
      CnvAI(BAG.F.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+
      CnvAI(BAG.F.Fertigung,_FmtNumLeadZero | _FmtNumNoGroup,0,4);
    if (TextRead(vTxtBuf, vText, _TextUnlock)>_rLocked) then CYCLE;

    // ggf. ÜS drucken
    if (vOK=false) then begin
      Form_Ele_BAG:elFertZusatzUS(var aElUS);
      Form_Mode # 'FERTZUSATZ';
      vOK # y;
    end;

    Form_Ele_BAG:elFertZusatz(var aEl, vText);
    if (BAG.F.Fertigung<999) then begin
      vStk   # vStk   + "BAG.F.Stückzahl";
      vGewN  # vGewN  + BAG.F.Gewicht;
      vBreite # vBreite + (BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl));
      if (vMEH='') then vMEH # BAG.F.MEH;
      if (vMEH=BAG.F.MEH) then
        vM   # vM     + BAG.F.Menge;
    end;
  END;

  if (vOK) then begin
    // Summen drucken
    RecBufClear(703);
    "BAG.F.Stückzahl" # vStk;
    BAG.F.Gewicht     # vGewN;
    BAG.F.Breite      # vBreite;
    BAG.F.Menge       # vM;
    BAG.F.MEH         # vMEH;
    Form_Ele_BAG:elFertZusatzFuss(var aElFuss);
  end;

  TextClose(vTxtBuf);
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
  Form_Ele_BAG:elVerpackungUS(var aElUS);
  Form_Mode # 'VERPACKUNG';

  BAG.Vpg.Nummer # BAG.Nummer;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vCount) DO BEGIN
    Bag.Vpg.Verpackung #  CnvIa(Lib_Strings:Strings_Token(aVpg,'|',vI));
    Erx # RecRead(704,1,0);
    if (Erx > _rLocked) then CYCLE;
    Form_Ele_BAG:elVerpackung1(var aEl1);
    Form_Ele_BAG:elVerpackung2(var aEl2);
  END;

  Form_Ele_BAG:elVerpackungFuss(var aElFuss);
end;


//========================================================================
//========================================================================
sub PrintRasterEinsatz();
local begin
  Erx       : int;
  vLfdNr    : int;
  vOutCount : int;
  v200      : int;
end;
begin
  Form_Mode # '';

  RecbufClear(210);

  vlfdNr  # 0;
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.BruderID<>0) then CYCLE;

    inc(vlfdNr);


    v200 # RekSave(200);

    // Material lesen
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
      end
    else begin
      RecbufClear(200);
    end;

    inc(vOutCount);
    if (vOutCount=1) then begin
      RecBufDestroy(v200);
    end;
    if (vOutCount=2) then begin
      RecbufCopy(200,210);    // in Ablage schieben
      RekRestore(v200);
      form_Ele_BAG:elRasterEinsatz(var elRaster);
      vOutCount # 0;
      RecbufClear(210);
    end;

  END;

  if (vOutCount=1) then begin
    form_Ele_BAG:elRasterEinsatz(var elRaster);
  end;

end;


//========================================================================
//========================================================================
sub PrintRasterfertigung();
local begin
  Erx     : int;
  vList   : int;
  vA      : alpha;
end;
begin
  Form_Mode # '';

  vList # CteOpen(_CteList);

  // Einsätze loopen...
  FOR Erx # RecLink(703,702,4,_recfirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.F.Fertigung<999) then begin
      vA # aint(BAG.F.Fertigung)+' / '+anum(BAG.F.Breite, Set.Stellen.Breite);
      vList->CteInsertItem('Fert'+aint(BAG.F.Fertigung),BAG.F.Fertigung,vA);
    end;

  END;

  form_Ele_BAG:elRasterFertigung(var elRaster, vList);

  Lib_ramSort:KillList(vList);

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx           : int;
  vVPG          : alpha(1000);
  vVPGCount     : int;
  vFirst        : logic;
end;
begin

  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, true) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);
  form_RandOben   # cnvfi(PrtUnitLog(4.0,_PrtUnitMillimetres));   // Rand setzen
  form_RandUnten  # PrtUnitLog(4.0,_PrtUnitMillimetres);          // Rand setzen

  // Seitenfuss vorbereiten
  form_Elemente:elSeitenFuss(var elSeitenFuss, false);


  // LOOP **********************************************************
  FOR Erx # RecLink(702,700,1,_recFirst)      // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Aktion=c_BAG_VSB) then CYCLE;
    if (BAG.P.ExternYN) then CYCLE;

    begin // von WSP übernommen für unterschiedlichen Formulardruck
      Lib_Form:UnloadSubStyleDef();
      Lib_Form:UnloadStyleDef();

      if (BAG.P.Aktion=c_BAG_Tafel) then
        Lib_Form:LoadStyleDef('STYLE_STD_BAG_TAFEL')
      else
        Lib_Form:LoadStyleDef('STYLE_STD_BAG_SPALT');
    end;


  // ------ Druck vorbereiten ----------------------------------------------------------------
    RecbufClear(100);                                 // Lohnbetrieb leeren
    RecbufClear(101)                                  // erste Anschrift leeren
    RecbufClear(812);
    Erx # RekLink(160,702,11,_recFirst);              // Ressource holen
    Erx # RekLink(828,702,8,_RecFirst);               // Arbeitsgang holen
    RekBufKill(vKundenAdr);
    // LohnKunde holen...
    if (BAG.P.Auftragsnr<>0) then begin
      if (Auf_Data:Read(BAG.P.Auftragsnr, BAG.P.Auftragspos, n)>=400) then begin
        Erx # RekLinkB(vKundenAdr, 401,4,_recFirst);
      end;
    end;


  // ------- KOPFDATEN -----------------------------------------------------------------------
    if (vFirst=n) then begin
      vFirst # y;
      Lib_Print:Print_Seitenkopf();
      end
    else begin
      Lib_Print:Print_FF();     // Seitenvorschub auf folgenden Seiten
    end;

    // Kopftext drucken
    Form_Elemente:elKopftext(var elKopftext, '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K');

  // ------- EINSATZMATERIAL -----------------------------------------------------------------

    form_Elemente:elLeerzeile(var elLeerzeile);
    FreeElement(var elEinsatzUS);
    PrintEinsatz(var elEinsatzUS, var elEinsatz1, var elEinsatz2, var elEinsatzFuss);

  // ------- FERTIGUNGEN ---------------------------------------------------------------------

    form_Elemente:elLeerzeile(var elLeerzeile);
    FreeElement(var elFertigungUS);
    PrintFertigung(var elFertigungUS, var elFertigung1, var elFertigung2, var elFertigungFuss, var vVPG);

  // ------- FERTIGUNGEN ---------------------------------------------------------------------

    form_Elemente:elLeerzeile(var elLeerzeile);
    FreeElement(var elFertZusatzUS);
    PrintFertZusatz(var elFertZusatzUS, var elFertZusatz, var elFertZusatzFuss);

  // ------- VERPACKUNGEN ----------------------------------------------------------------------

    form_Elemente:elLeerzeile(var elLeerzeile);
    FreeElement(var elVerpackungUS);
    PrintVerpackung(var elVerpackungUS, var elVerpackung1, var elVerpackung2, var elVerpackungFuss, vVpg);

  // ------- FUßDATEN --------------------------------------------------------------------------
    form_Mode # 'FUSS';

    form_Elemente:elLeerzeile(var elLeerzeile);

    // Fusstext drucken
    Form_Elemente:elFusstext(var elFusstext, '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F');

    form_Ele_BAG:elEnde1(var elEnde1, 0,0, vKundenAdr);
    form_Ele_BAG:elEnde2(var elEnde2, 0,0, vKundenAdr);
    form_Ele_BAG:elEnde3(var elEnde3, 0,0, vKundenAdr);

    PrintRasterEinsatz();
    form_Elemente:elLeerzeile(var elLeerzeile);
    PrintRasterFertigung();

  END;  // BA-Position


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  RekBufKill(vKundenAdr);

  // Objekte entladen
  FreeElement(var elSeitenkopf        );
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

  FreeElement(var elFertZusatzUS      );
  FreeElement(var elFertZusatz        );
  FreeElement(var elFertZusatzFuss    );

  FreeElement(var elVerpackungUS      );
  FreeElement(var elVerpackung1       );
  FreeElement(var elVerpackung2       );
  FreeElement(var elVerpackungFuss    );

  FreeElement(var elRaster            );

  FreeElement(var elEnde1             );
  FreeElement(var elEnde2             );
  FreeElement(var elEnde3             );
  FreeElement(var elLeerzeile         );

end;

//========================================================================
//  Parse
//
//========================================================================
sub Parse(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic;
  ) : int;
local begin
  Erx       : int;
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
  vA,vA2  : alpha(4096);
  v401    : int;

  vPakete : float;
end;
begin

  vFeld   # Str_Token(aText, '|', 1);
  vTitel  # Str_Token(aText, '|', 2);
  vPost   # Str_Token(aText, '|', 3);
  vPre    # Str_Token(aText, '|', 4);

  case StrCnv(vFeld,_StrUpper) of

    'MYEINSATZBEM' : begin
                        vAdd # Mat.Bemerkung1;
                    end;

    'MYPAKETE' :  begin
                    Erx # RecLink(704,703,6,0);


                    if (BAG.VPG.VEkgMax=0.0) then begin
                      if ("BAG.VPG.StückProVE"=0) then
                        vAdd # '1';
                      else
                        vAdd # anum(Rnd((cnvFI("BAG.F.Stückzahl") / cnvfi("BAG.VPG.StückProVE"))),0);

                      end
                    else begin
                      vAdd # anum(Rnd((BAG.F.Gewicht / BAG.Vpg.VEkgMax)+0.4999) ,0);
                    end;

                  end;

    'MYKGPROTAFEL':  begin
                      if ("Bag.F.Stückzahl" = 0) then
                        "Bag.F.Stückzahl" # 1;
                      // vAdd # anum(Rnd(BAG.F.Gewicht / CnvFi("Bag.F.Stückzahl"),2),0);
                      vAdd # anum(Rnd(BAG.F.Gewicht / CnvFi("Bag.F.Stückzahl"),2),2);
                  end;


    'MYSTÜCKPROPAKET' : begin
                          Erx # RecLink(704,703,6,0);
                          vPakete # 0.0;
                          if ("BAG.Vpg.StückProVE" <> 0) then begin
                            vAdd # Aint("BAG.Vpg.StückProVE");
                          end else if (BAG.VPG.VEkgMax=0.0) then begin
                            vPakete # 1.0;
                            end
                          else begin
                            vPakete # Rnd((BAG.F.Gewicht / BAG.Vpg.VEkgMax)+0.4999);
                          end;

                          if (vPakete >0.0) then
                            vAdd # Anum(CnvFi("Bag.F.Stückzahl") / vPakete,0);



                    end;

    'MYPAKETGEWICHT' : begin
                            Erx # RecLink(704,703,6,0);

                            if (BAG.VPG.VEkgMax=0.0) then begin

                              if ("BAG.VPG.StückProVE"=0) then
                                vPakete # 1.0;
                              else
                                vPakete # Rnd((cnvFI("BAG.F.Stückzahl") / cnvfi("BAG.VPG.StückProVE")));


                              end
                            else begin


                              vPakete # Rnd((BAG.F.Gewicht / BAG.Vpg.VEkgMax)+0.4999);
                            end;

                            if (vPakete =0.0) then vPakete # 1.0;
                            vAdd # anum(Rnd(BAG.F.Gewicht / vPakete) ,0);

                        end;



    'MYVPGNR' : vAdd  # aint(BAG.F.Fertigung);
    'MYVPG2' :  begin
                      if (BAG.VPG.StehendYN) then ADD_VERP('stehend','');
                      if (BAG.VPG.LiegendYN) then ADD_VERP('liegend','');
                      //Abbindung
                      if (BAG.VPG.AbbindungQ <> 0 or BAG.VPG.AbbindungL <> 0) then begin
                        //Quer
                        if(BAG.VPG.AbbindungQ<>0)then vA2 # 'Abbindung '+ AInt(BAG.VPG.AbbindungQ)+' x quer' ;
                        //Längs
                        if(BAG.VPG.AbbindungL<>0)then begin
                          if (vA2<>'')then
                            vA2 # vA2+'  '+AInt(BAG.VPG.AbbindungL)+ ' x längs';
                          else
                            vA2 # 'Abbindung ' + AInt(BAG.VPG.AbbindungL)+' x längs';
                        end;
                       ADD_VERP(vA2,'')
                       vA2 # '';
                      end;
                      if (BAG.VPG.Zwischenlage <> '') then ADD_VERP(BAG.VPG.Zwischenlage,'');
                      if (BAG.VPG.Unterlage <> '') then ADD_VERP(BAG.VPG.Unterlage,'');
                      if (BAG.VPG.Umverpackung<>'') then ADD_VERP(BAG.VPG.Umverpackung,'');
                      if (BAG.VPG.Nettoabzug > 0.0) then ADD_VERP('Nettoabzug: '+AInt(CnvIF(BAG.VPG.Nettoabzug))+' kg','');
                      if ("BAG.VPG.Stapelhöhe" > 0.0) then ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("BAG.VPG.Stapelhöhe"))+' mm');
                      if (BAG.VPG.StapelhAbzug > 0.0) then ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("BAG.VPG.StapelhAbzug"))+' mm');
                      //if (BAG.VPG.RingKgVon + BAG.VPG.RingKgBis  <> 0.0) then begin
                      //  vA2 # 'Ringgew.: '+AlphaMinMax(BAG.VPG.RingkgVon, BAG.VPG.RingKGBis, 0, '');
                      //  vA2 # vA2+' kg';
                      //  ADD_VERP(vA2,'')
                      //end;
                      if (BAG.VPG.KgmmVon + BAG.VPG.KgmmBis  <> 0.0) then begin
                        vA2 # 'Kg/mm: '+AlphaMinMax(BAG.VPG.KgmmVon, BAG.VPG.KgmmBis, 2, '');
                        ADD_VERP(vA2,'')
                        vA2 # '';
                      end;
                      if ("BAG.VPG.StückProVE" > 0) then ADD_VERP(AInt("BAG.VPG.StückProVE") + ' Stück pro VE', '');
                      if (BAG.VPG.VEkgMax > 0.0) then ADD_VERP('max. '+anum(BAG.VPG.VEkgMax,0)+' kg pro VE: ', '');
                      if (BAG.VPG.RechtwinkMax > 0.0) then ADD_VERP('max. Rechtwinkligkeit: ', ANum(BAG.VPG.RechtwinkMax,-1));
                      if (BAG.VPG.EbenheitMax > 0.0) then ADD_VERP('max. Ebenheit: ', ANum(BAG.VPG.EbenheitMax,-1));
                      if ("BAG.VPG.SäbeligMax" > 0.0) then ADD_VERP('max. Säbeligkeit: ', ANum("BAG.VPG.SäbeligMax",-1)+' pro '+anum("BAG.VPG.SäbelProM",2)+' m');
                      if (BAG.VPG.Wicklung<>'') then ADD_VERP('Wicklung: ', BAG.VPG.Wicklung);
                      vAdd # vA;
                end;
    'MYGEWICHT' : begin
                  if ("BAG.F.Stückzahl"<>0) then
                    vAdd # vAdd + anum(BAG.F.Gewicht / cnvfi("BAG.F.Stückzahl"), Set.Stellen.Gewicht) + '/' +
                                  anum(BAG.F.Gewicht, Set.Stellen.Gewicht)
                  else
                    vAdd # vAdd + anum(BAG.F.Gewicht, Set.Stellen.Gewicht) + '/'+ anum(BAG.F.Gewicht, Set.Stellen.Gewicht)
                end;
    'MYVPG' :   begin
                  v401 # RekSave(401);
                  vAdd  # anum(BAG.F.Dicke, Set.Stellen.Dicke)+' x '+anum(BAG.F.Breite, Set.Stellen.Breite);
                  if ("BAG.F.Länge"<>0.0) then vAdd # vAdd + ' x '+anum("BAG.F.Länge", "Set.Stellen.Länge");

                  If (BAG.F.Auftragsnummer<>0) then begin
                    if (Auf_Data:Read(BAG.F.Auftragsnummer, BAG.F.Auftragspos, n)>=400) then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
                      aInhalt # aInhalt + StrChar(10);
                      aLabels # aLabels + StrChar(10);
                      aZusatz # aZusatz + StrChar(10);

                      vAdd # Auf.P.KundenSW+' '+aint(Auf.P.Nummer)+'/'+Aint(Auf.P.Position)+' '+"Auf.P.Güte";
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
                      aInhalt # aInhalt + StrChar(10);
                      aLabels # aLabels + StrChar(10);
                      aZusatz # aZusatz + StrChar(10);

                      RETURN Form_Parse_Auf:Parse401(var aLAbels, var aInhalt, var aZusatz, 'TERMIN', aKombi);
                    end;
                  end;
                  RekRestore(v401);
                end;

    'MYBAGFTEXT': begin
                  vAdd # Bag.F.Bemerkung;
                end;


    'MYGESAMTBREITE' : begin
                  if (BAG.P.Aktion = c_BAG_SPALT) then
                    vAdd # Anum(gGesamtbreite,Set.Stellen.Breite);
                end;

    'MYFERTBREITE'  : begin
                  if (Bag.F.Fertigung < 999) then
                    vAdd # Anum((BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl)),Set.Stellen.Breite);
                  end;
    'MYBREITE'  : begin
                  if (Bag.F.Fertigung < 999) then
                    vAdd # Anum((BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl)),Set.Stellen.Breite);
                  end;

    'MYBLOCK'   : begin
                    vAdd  # BAG.F.Block + ' ' + Aint(Bag.F.Streifenanzahl);
                  end;

  end;

  if (vAdd<>'') then begin
    inc(vZeilen);
    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
    RETURN vZeilen;
  end;


  RETURN 0;
end;


//========================================================================