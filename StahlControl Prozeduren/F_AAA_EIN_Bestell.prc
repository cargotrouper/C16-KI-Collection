@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_EIN_Bestell
//                      OHNE E_R_G
//  Info
//    Druckt eine Bestellung
//
//
//  08.11.2012  AI  Erstellung der Prozedur
//  16.10.2013  AH  Anfragen
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB HoleEmpfaenger();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB PrintPosAufpreise();
//    SUB PrintKopfAufpreise();
//
//    MAIN (opt aFilename : alpha(4096))
//
//========================================================================
@I:Def_Global
@I:Def_Form

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
end;

local begin
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

  elAufpreisUS        : int;
  elAufpreis          : int;

  elPosVpg            : int;
  elPosMech           : int;
  elPosAnalyse        : int;

  elPosArt1           : int;
  elPosArt2           : int;

  elEnde              : int;
  elSumme             : int;
  elLeerzeile         : int;

  /// -----------------------------

  // Variablen...
  vBuf100Re           : int;
  vBuf101We           : int;

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
begin
  RecLink(100,500,1,_RecFirst);   // Lieferant holen
  aAdr      # Adr.Nummer;
  aSprache  # Ein.Sprache;
  RETURN CnvAI(Ein.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,500,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,500,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RecLink(100,500,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,500,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
        RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then RETURN;

    end // Daten aus Ein.

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
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Empfänger holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen

      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Vertreter  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Verband  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
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

  end;

end;


/***
//========================================================================
//  Parse
//
//========================================================================
sub Parse(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aCode : alpha(4096);
  ) : logic
begin
  if (aCode='400_TITEL') then begin
    AddA('test', var aLabels);
    RETURN true;
  end;
end;
***/


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
end;
begin
//  vBuf100 # RekSave(100);
//  vBuf101 # RekSave(101);
//  RecLink(100,500,1,_RecFirst);   // Lieferant holen
//  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
//  if (aSeite=1) then begin
//    form_FaxNummer  # Adr.A.Telefax;
//    Form_EMA        # Adr.A.EMail;
//  end;

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();

  // ERSTE SEITE??
  if (aSeite=1) then begin
    form_Ele_Ein:elBestErsteSeite(var elErsteSeite, vBuf100Re, vBuf101We, 0 , 0, aSeite);
    form_Elemente:elKopfText(var elKopfText, '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K');
    end
  else begin
    form_Ele_Ein:elBestFolgeSeite(var elFolgeSeite, vBuf100Re, vBuf101We, 0 , 0);
  end;


  if (Form_Mode='POS') then begin
    form_Ele_Ein:elBestUeberschrift(var elUeberschrift);
  end;

//  RekRestore(vBuf100);
//  RekRestore(vBuf101);
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
//  PrintPosAufpreise
//
//========================================================================
sub PrintPosAufpreise();
local begin
  Erx       : int;
  vFirst      : logic;
  vPreis      : float;
  vMenge      : float;
end;
begin
/*
  Print('Aufpreise MEH');
  Print('Aufpreise fremd');
  Print('Aufpreise FIX');
  Print('Aufpreise %');
  Print('AufpreisKopf MEH');
*/
  vFirst # y;

  // Aufpreise: MEH-Bezogen
  //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise
  FOR Erx # RecLink(503,501,7,_RecFirst)  // Aufpreise loopen
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if /*("Ein.Z.Schlüssel" <> '*RAB1') and ("Ein.Z.Schlüssel" <> '*RAB2') and*/
      ((Ein.Z.MengenbezugYN) and (Ein.Z.MEH=Ein.P.MEH.Preis)) then begin

      if (vFirst) then begin
        form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      Ein.Z.Menge # Lib_Einheiten:WandleMEH(503, vPosStk, vPosGewicht, vPosMenge, Ein.P.MEH.Wunsch, Ein.Z.MEH)
      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Ein.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // Aufpreise MEH ------------------------------------


  // Aufpreise: fremd MEH-Bezogen
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.MengenbezugYN) and
      ((Ein.Z.MEH<>'%') and (Ein.Z.MEH<>Ein.P.MEH.Preis)) then begin

      if (vFirst) then begin
        form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      Ein.Z.Menge # Lib_Einheiten:WandleMEH(503, vPosStk, vPosGewicht, vPosMenge, Ein.P.MEH.Wunsch, Ein.Z.MEH)
      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Ein.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end
  END;
  // Aufpreise fremd --------------------------------


  // Aufpreise: NICHT MEH-Bezogen =FIX
  FOR Erx # RecLink(503,501,7,_Recfirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.MEH<>'%') and (Ein.Z.MengenbezugYN=n) then begin

      if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,501);

      if (vFirst) then begin
        form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Ein.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // Aufpreise FIX  ---------------------------------------


  // Aufpreise: MEH-%
  //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if /*("Ein.Z.Schlüssel" <> '*RAB1') and ("Ein.Z.Schlüssel" <> '*RAB2') and*/
      (Ein.Z.MEH='%') then begin

      if (vFirst) then begin
        form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      if ("Ein.Z.Schlüssel" = '*RAB1') or ("Ein.Z.Schlüssel" = '*RAB2') then
        Ein.Z.Bezeichnung # 'Rabatt';
      Ein.Z.Preis # vPosNettoRabbar;
      Ein.Z.PEH   # 100;
      vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Ein.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // Aufpreise % ------------------------------------


  // KopfAufpreise: MEH-Bezogen
  FOR Erx # RecLink(503,500,13,_RecFirst)
  LOOP Erx # RecLink(503,500,13,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    IF (Ein.Z.Position<>0) then BREAK;

    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') and (Ein.Z.Position=0) AND (Ein.Z.Nummer = Ein.Nummer)then begin

      if (vFirst) then begin
        form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(503, vPosStk, vPosGewicht, vPosMenge, Ein.P.MEH.Wunsch, Ein.Z.MEH)
      vPreis #  Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);
      form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);

      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Ein.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // AufpriesKopf MEH ----------------------------------
end;


//========================================================================
//
//
//========================================================================
sub PrintKopfAufpreise();
local begin
  Erx       : int;
  vFirst  : logic;
  vPreis  : float;
end;
begin

    vFirst # y;

    // KopfAufpreise: NICHT MEH-Bezogen =FIX
    FOR Erx # RecLink(503,500,13,_RecFirst)
    LOOP Erx # RecLink(503,500,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if (Ein.Z.Position<>0) then BREAK;

      if (Ein.Z.MengenbezugYN=n) and
        (Ein.Z.MEH<>'%') then begin

        if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,500);

        if (Ein.Z.Menge<>0.0) then begin

          if (vFirst) then begin
            form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, true);
            vFirst # n;
          end;

          vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
          form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);
          vGesamtNetto # vGesamtNetto + vPreis;
          vMwstWert1 # vMwstWert1 + vPreis;
          if (Ein.Z.RabattierbarYN) then
            vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;
        end;
      end;
    END;
    // AufpreisKopf FIX ---------------------------


    // KopfAufpreise: %
    FOR Erx # RecLink(503,500,13,_RecFirst)
    LOOP Erx # RecLink(503,500,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      IF (Ein.Z.Position<>0) then BREAK;

      if (Ein.Z.MEH='%') AND (Ein.Z.Position = 0) AND (Ein.Z.Nummer = Ein.Nummer)then begin

        if (vFirst) then begin
          form_Ele_Ein:elBestAufpreisUS(var elAufpreisUS, true);
          vFirst # n;
        end;
        Ein.Z.Preis # vGesamtNettoRabBar;
        Ein.Z.PEH   # 100;
        vPreis # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
        form_Ele_Ein:elBestAufpreis(var elAufpreis, vPreis);
        vGesamtNetto # vGesamtNetto + vPreis;
        vMwstWert1 # vMwstWert1 + vPreis;
        if (Ein.Z.RabattierbarYN) then
          vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;
      end;
    END;
    // AufpreisKopf %

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vTxtName      : alpha;
  vTxtNameLast  : alpha;
end;
begin

  if (EIn.Vorgangstyp<>c_Bestellung) then RETURN;

  RekLinkB(vBuf100Re,500,4,_recFirst);      // Rechnungsempf. holen
  RekLinkB(vBuf101We, 500, 2, _recFirst);   // Warenempfänger holen
  RekLink(814,500,8,_recFirst);             // Währung holen
  Erx # RekLink(816,500,6,_RecFirst);       // Zahlungsbedingung lesen
  Erx # RekLink(815,500,5,_RecFirst);       // Lieferbedingung lesen
  Erx # RekLink(817,500,7,_RecFirst);       // Versandart lesen
  Erx # RekLink(100,500,1,_RecFirst);       // Lieferant holen
  Erx # RekLink(101,100,12,_recFirst);      // Hauptanschrift holen
  Erx # RekLink(812,101,2,_recFirst);       // Land holen
  if ("Lnd.kürzel"='D') or ("Lnd.kürzel"='DE') then
    RecbufClear(812);

  Usr.Username # Ein.Sachbearbeiter;
  Erx # RecRead(800, 1, 0); // Benutzer holen
  if (Erx > _rLocked) then RecBufClear(800);

  if (Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss generieren
  form_Elemente:elSeitenFuss(var elSeitenFuss, false);

// ------- KOPFDATEN -----------------------------------------------------------------------
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;
  Lib_Print:Print_Seitenkopf();
  vMwstSatz1  # -1.0;
  vMwstSatz2  # -1.0;

// ------- POSITIONEN --------------------------------------------------------------------------
  form_Ele_Ein:elBestUeberschrift(var elUeberschrift);
  Form_Mode # 'POS';


  FOR Erx # RekLink(501,500,9,_RecFirst)
  LOOP Erx # RekLink(501,500,9,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Ein.P.Löschmarker"='*') then CYCLE;

    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) then begin
      Erx # RekLink(250,501,2,_RecFirst); // Artikel holen
    end
    else if ((Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr))) then begin
      RecBufClear(250);
    end
    else
      CYCLE;


    // Position ok und ausgeben.....
    Inc(vPosCount);


    // Positionstyp bestimmen
    RekLink(819,501,1,_recFirst); // Warengruppe holen
    RekLink(835,501,5,_recFirst); // Auftragsart holen
    vPosMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, Ein.P.MEH.Preis);
    vPosMwSt        # 0.0;
    vPosGewicht     # Ein.P.Gewicht;
    vPosStk         # "Ein.P.Stückzahl";
    Ein.P.Gesamtpreis # Rnd((Ein.P.Grundpreis) *  vPosMenge / CnvFI(Ein.P.PEH) ,2);
    vPosNettoRabBar # Ein.P.Gesamtpreis;
    vPosNetto       # Ein.P.Gesamtpreis;

    // Positionstext ausgeben
    vTxtName # '';
    if (Ein.P.TextNr1=500) then // anderer Positionstext
      vTxtName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Ein.P.TextNr1=0) and (Ein.P.TextNr2 != 0) then   // Standardtext
      vTxtName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    if (Ein.P.TextNr1=501) then // Individuell
      vTxtName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (vTxtName != '') and (vTxtNameLast<>vTxtName) then begin
      form_Elemente:elPosText(var elPosText, vTxtName);
      vTxtNameLast # vTxtName;
    end;


    // Artikel ausgeben
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) then begin
      form_Ele_Ein:elBestPosArt1(var elPosArt1);
      vGesamtNettoRabBar  # vGesamtNettoRabBar + Ein.P.Gesamtpreis;
      vGesamtNetto        # vGesamtNetto + Ein.P.GesamtPreis;
      vGesamtStk          # vGesamtStk + "Ein.P.Stückzahl";
      vGesamtGew          # vGesamtGew + Ein.P.Gewicht;
      if (vGesamtMEH='') then vGesamtMEH # Ein.P.MEH;
      if (vGesamtMEH=Ein.P.MEH) then vGesamtM # vGesamtM + Ein.P.Menge;
      form_Ele_Ein:elBestPosArt2(var elPosArt2);
    end;

    // Material ausgeben
    if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) then begin
      form_Ele_Ein:elBestPosMat1(var elPosMat1);
      vGesamtNettoRabBar  # vGesamtNettoRabBar + Ein.P.Gesamtpreis;
      vGesamtNetto        # vGesamtNetto + Ein.P.GesamtPreis;
      vGesamtStk          # vGesamtStk + "Ein.P.Stückzahl";
      vGesamtGew          # vGesamtGew + Ein.P.Gewicht;
      if (vGesamtMEH='') then vGesamtMEH # Ein.P.MEH;
      if (vGesamtMEH=Ein.P.MEH) then vGesamtM # vGesamtM + Ein.P.Menge;
      form_Ele_Ein:elBestPosMat2(var elPosMat2);
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
    PrintPosAufpreise();


    // Print Verpackung:
    form_Ele_Ein:elBestPosVpg(var elPosVpg);

    // Print Mechanik
    form_Ele_Ein:elBestPosMech(var elPosMech);

    // Print Analyse
    form_Ele_Ein:elBestPosAnalyse(var elPosAnalyse);

    // Mehrwertsteuersätze
    StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Ein.Steuerschlüssel";
    Erx # RecRead(813,1,0);
    if (Erx>_rLocked) then RecBufClear(813);
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

    // Leerzeile zwischen den Positionen
    form_Elemente:elLeerzeile(var elLeerzeile);

  END; // WHILE: Positionen ************************************************

  // Kopfaufpreise drucken...
  PrintKopfAufpreise();

  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  // 110 MM Rand unten lassen für den Fuss
//  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
//    form_Ele_Ein:elLeerzeile(var elLeerzeile);

  // Mehrwertstuern errechnen
  if (vMwStSatz1<>0.0) then vMwStWert1 # Rnd(vMwstWert1 * (vMwstSatz1/100.0),2)
  else vMwStWert1 # 0.0;
  if (vMwStSatz2>0.0) then vMwStWert2 # Rnd(vMwstWert2 * (vMwstSatz2/100.0),2)
  else vMwStWert2 # 0.0;
  vGesamtBrutto # Rnd(vGesamtNetto + vMwstWert1 + vMwstWert2,2);

  // Summe vorbelegen
  Ein.P.Gewicht       # vGesamtGew;
  "Ein.P.Stückzahl"   # vGesamtStk;
  Ein.P.MEH           # vGesamtMEH;
  Ein.P.Menge         # vGesamtM;
  form_Ele_Ein:elSumme(var elSumme, vGesamtNetto, vMwStSatz1, vMwStWert1, vMwStSatz2, vMwStWert2, vGesamtBrutto);

  form_Elemente:elFussText(var elFussText, '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F');

  form_Ele_Ein:elBestEnde(var elEnde, vBuf100Re, vBuf101We, 0, 0);


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  FreeElement(var elErsteSeite        );
  FreeElement(var elFolgeSeite        );
  FreeElement(var elSeitenFuss        );

  FreeElement(var elKopfText          );
  FreeElement(var elFussText          );

  FreeElement(var elUeberschrift      );

  FreeElement(var elPosText           );

  FreeElement(var elPosMat1           );
  FreeElement(var elPosMat2           );

  FreeElement(var elAufpreisUS        );
  FreeElement(var elAufpreis          );

  FreeElement(var elPosVpg            );
  FreeElement(var elPosMech           );
  FreeElement(var elPosAnalyse        );

  FreeElement(var elPosArt1           );
  FreeElement(var elPosArt2           );

  FreeElement(var elSumme             );
  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile         );
end;


//=======================================================================