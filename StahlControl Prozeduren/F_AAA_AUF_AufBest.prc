@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_AUF_AufBest
//                        OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  23.10.2012  AI  Erstellung der Prozedur
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
@I:Def_Aktionen

local begin
  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;

  elKopfText          : int;
  elFussText          : int;

  elUeberschrift      : int;

  elPosText             : int;

  elPosMat1           : int;
  elPosMat2           : int;

  elAufpreisUS        : int;
  elAufpreis          : int;

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
  RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  vflag   : int;
  Erx     : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then begin
      form_FaxNummer  # Adr.Telefax;
      Form_EMA        # Adr.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      Adr.P.Adressnr # Adr.Nummer;
      Adr.P.Nummer   # cnvia(StrCut(Auf.Best.Bearbeiter,2,3));
      Erx # RecRead(102,1,_recFirst);   // Ansprechpartner holen
      if (Erx>_rLocked) then RETURN;
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,400,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,400,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RecLink(100,400,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,400,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      Erx # RecLink(110,400,20,_recFirst);  // Vertreter holen
      if (Erx>_rLocked) then RETURN;
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

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      Erx # RecLink(110,400,21,_recFirst);  // Verband holen
      if (Erx>_rLocked) then RETURN;
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

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
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
      // fixe Adresse testen...
      if (RecLink(102,921,3,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(102,921,3,_recfirst);   // Partner holen
      RecLink(100,102,1,_recFirsT);   // seine Adresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
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
//  RecLink(100,400,1,_RecFirst);   // Kunde holen
//  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
//  if (aSeite=1) then begin
//    form_FaxNummer  # Adr.A.Telefax;
//    Form_EMA        # Adr.A.EMail;
//  end;

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();

  // ERSTE SEITE??
  if (aSeite=1) then begin
    form_Ele_Auf:elABErsteSeite(var elErsteSeite, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);
    form_Elemente:elKopfText(var elKopfText,'~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K');
    end
  else begin
    form_Ele_Auf:elABFolgeSeite(var elFolgeSeite, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);
  end;

  if (Form_Mode='POS') then
    form_Ele_Auf:elABUeberschrift(var elUeberschrift)
  else if (Form_Mode = 'EINSATZ') then
    Form_Ele_LohnBAG:elEinsatzUS(var elEinsatzUS)
  else if (Form_Mode = 'FERTIGUNG') then
    Form_Ele_LohnBAG:elFertigungUS(var elFertigungUS)
  else if (Form_Mode = 'VERPACKUNG') then
    Form_Ele_LohnBAG:elVerpackungUS(var elVerpackungUS);


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
  Erx         : int;
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
  FOR Erx # RecLink(403,401,6,_RecFirst)  // Aufpreise loopen
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if /*("Auf.Z.Schlüssel" <> '*RAB1') and ("Auf.Z.Schlüssel" <> '*RAB2') and*/
      ((Auf.Z.MengenbezugYN) and (Auf.Z.MEH=Auf.P.MEH.Preis)) then begin

      if (vFirst) then begin
        form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Auf.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // Aufpreise MEH ------------------------------------


  // Aufpreise: fremd MEH-Bezogen
  FOR Erx # RecLink(403,401,6,_RecFirst)
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Auf.Z.MengenbezugYN) and
      ((Auf.Z.MEH<>'%') and (Auf.Z.MEH<>Auf.P.MEH.Preis)) then begin

      if (vFirst) then begin
        form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Auf.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end
  END;
  // Aufpreise fremd --------------------------------


  // Aufpreise: NICHT MEH-Bezogen =FIX
  FOR Erx # RecLink(403,401,6,_Recfirst)
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Auf.Z.MEH<>'%') and (Auf.Z.MengenbezugYN=n) and (Auf.Z.Rechnungsnr=0) then begin

      if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,401);

      if (vFirst) then begin
        form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Auf.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // Aufpreise FIX  ---------------------------------------


  // Aufpreise: MEH-%
  //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise
  FOR Erx # RecLink(403,401,6,_RecFirst)
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if /*("Auf.Z.Schlüssel" <> '*RAB1') and ("Auf.Z.Schlüssel" <> '*RAB2') and*/
      (Auf.Z.MEH='%') then begin

      if (vFirst) then begin
        form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      if ("Auf.Z.Schlüssel" = '*RAB1') or ("Auf.Z.Schlüssel" = '*RAB2') then
        Auf.Z.Bezeichnung # 'Rabatt';
      Auf.Z.Preis # vPosNettoRabbar;
      Auf.Z.PEH   # 100;
      vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);
      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Auf.Z.RabattierbarYN) then begin
        vGesamtNettoRabBar  # vGesamtNettoRabBar + vPreis;
        vPosNettoRabbar     # vPosNettoRabBar + vPreis;
      end;
    end;
  END;
  // Aufpreise % ------------------------------------


  // KopfAufpreise: MEH-Bezogen
  FOR Erx # RecLink(403,400,13,_RecFirst)
  LOOP Erx # RecLink(403,400,13,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    IF (Auf.Z.Position<>0) then BREAK;

    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') and (Auf.Z.Position=0) AND (Auf.Z.Nummer = Auf.Nummer)then begin

      if (vFirst) then begin
        form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, false);
        vFirst # n;
      end;

      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vPreis #  Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);

      vGesamtNetto # vGesamtNetto + vPreis;
      vPosNetto    # vPosNetto    + vPreis;
      if (Auf.Z.RabattierbarYN) then begin
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
  Erx     : int;
  vFirst  : logic;
  vPreis  : float;
end;
begin

    vFirst # y;

    // KopfAufpreise: NICHT MEH-Bezogen =FIX
    FOR Erx # RecLink(403,400,13,_RecFirst)
    LOOP Erx # RecLink(403,400,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if (Auf.Z.Position<>0) then BREAK;

      if (Auf.Z.MengenbezugYN=n) and
        (Auf.Z.MEH<>'%') and
        (Auf.Z.Rechnungsnr=0) then begin

        if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,400);

        if (Auf.Z.Menge<>0.0) then begin

          if (vFirst) then begin
            form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, true);
            vFirst # n;
          end;

          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
          form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);
          vGesamtNetto # vGesamtNetto + vPreis;
          vMwstWert1 # vMwstWert1 + vPreis;
          if (Auf.Z.RabattierbarYN) then
            vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;
        end;
      end;
    END;
    // AufpreisKopf FIX ---------------------------


    // KopfAufpreise: %
    FOR Erx # RecLink(403,400,13,_RecFirst)
    LOOP Erx # RecLink(403,400,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      IF (Auf.Z.Position<>0) then BREAK;

      if (Auf.Z.MEH='%') AND (Auf.Z.Position = 0) AND (Auf.Z.Nummer = Auf.Nummer)then begin

        if (vFirst) then begin
          form_Ele_Auf:elABAufpreisUS(var elAufpreisUS, true);
          vFirst # n;
        end;
        Auf.Z.Preis # vGesamtNettoRabBar;
        Auf.Z.PEH   # 100;
        vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
        form_Ele_Auf:elABAufpreis(var elAufpreis, vPreis);
        vGesamtNetto # vGesamtNetto + vPreis;
        vMwstWert1 # vMwstWert1 + vPreis;
        if (Auf.Z.RabattierbarYN) then
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
  Erx           : int;
  vMeta         : int;
  vTxtName      : alpha;
  vTxtNameLast  : alpha;
  vVPG          : alpha(1000);
  vVPGCount     : int;
  vSubStyle     : alpha;
end;
begin

  vBuf100Re # Adr_Data:HoleBufferAdrOderAnschrift(Auf.Rechnungsempf, Auf.Rechnungsanschr);
  RekLinkB(vBuf101We, 400, 2, _recFirst);   // Warenempfänger holen
  RekLink(814,400,8,_recFirst);             // Währung holen
  RekLinkB(vBuf110Ver1,400,20,_recFirst);   // Vertreter 1 holen
  RekLinkB(vBuf110Ver2,400,21,_recFirst);   // Vertreter 2 holen
  RecBufClear(460);                         // Offenen Posten leeren (wegen Zahlungsbed. berechnung bei Rechnug)
  Erx # RekLink(816,400,6,_RecFirst);       // Zahlungsbedingung lesen
  Erx # RekLink(815,400,5,_RecFirst);       // Lieferbedingung lesen
  Erx # RekLink(817,400,7,_RecFirst);       // Versandart lesen
  Erx # RekLink(100,400,1,_RecFirst);       // Kunde holen
  Erx # RekLink(101,100,12,_recFirst);      // Hauptanschrift holen
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


/*** <<MUSTER>> */
//  DMS_ArcFlow:SetDokName('AB',Auf.Nummer, Adr.Nummer);
//  vMeta # DMS_ArcFlow:CreateMetadata('AB_'+cnvai(Auf.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
//  DMS_ArcFlow:WriteMetaData(vMeta, 'Adressen\1386\Verkauf');
//  DMS_ArcFlow:WriteMetaData(vMeta, 'Adressen\1397\Verkauf');
//  DMS_ArcFlow:CloseMetaData(vMeta);
/***/


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


  FOR Erx # RekLink(401,400,9,_RecFirst)
  LOOP Erx # RekLink(401,400,9,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.P.Löschmarker"='*') then CYCLE;

    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
      // Artikelmix zählt auf AB als Artikel
      Erx # RekLink(250,401,2,_RecFirst); // Artikel holen
    end
    else if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) then begin
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

    // reines Material ausgeben
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
//          aWMenge # Auf.A.Menge;
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
    PrintPosAufpreise();


    // Print Verpackung:
    form_Ele_Auf:elABPosVpg(var elPosVpg);

    // Print Mechanik
    form_Ele_Auf:elABPosMech(var elPosMech);

    // Print Analyse
    form_Ele_Auf:elABPosAnalyse(var elPosAnalyse);


/***
    // Lohngeschäft...
    if (AAr.Berechnungsart>=700) then begin

      RecBufClear(700);
      Erx # RecLink(404,401,12,_RecFirst);
      WHILE (Erx <= _rLocked) do begin   // Aktionen loopen
        if (Auf.A.Aktionstyp=c_Akt_BA) then begin

          BAG.Nummer # Auf.A.Aktionsnr;
          Erx # RecRead(700,1,0);

          // Betriebsauftragsdaten ausgeben
          if (Erx <=_rLocked) then begin
            Druck_BAG();
          end;
        end;
        Erx # RecLink(404,401,12,_RecNext);
      END;

    end;    // Lohn
***/

    // Mehrwertsteuersätze
    StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
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

/***
  // Falls ein BA gedruckt wurde, dann einmalig die Verpackung drucken
  if (vBAGPrinted) then begin
    // -------- Verpackung --------
    PrintLohnBA('BAG-Verpackungskopf');
    vGedrucktePos # 0;
    Erx # RecLink(704,700,2,_RecFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      vVerpCheck # CnvAI(BAG.Vpg.Verpackung,_FmtNumNoGroup | _FmtNumLeadZero,0,5)+';';
      if (StrFind(vVerpUsed,vVerpCheck,0) > 0) then
        PrintLohnBA('BAG-Verpackungsposition');

      vGedrucktePos # vGedrucktePos + 1;
      Erx # RecLink(704,700,2,_RecNext);
    END;

    if (vGedrucktePos > 1) then
      PrintLohnBA('BAG-Verpackungsfuss');
    PL_Printline;
  end;
***/

  // Kopfaufpreise drucken...
  PrintKopfAufpreise();


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  // 110 MM Rand unten lassen für den Fuss
//  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
//    form_Ele_Auf:elLeerzeile(var elLeerzeile);

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

  form_Elemente:elFussText(var elFussText,'~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F');

  form_Ele_Auf:elABEnde(var elEnde, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);


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

  FreeElement(var elSumme             );
  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile           );
end;


//=======================================================================