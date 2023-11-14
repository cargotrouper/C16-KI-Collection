@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_Rek_EinBest
//                    OHNE E_R_G
//  Info
//    Druckt eine Recklamationseingangsbestätigung
//
//
//  16.01.2013  AI  Erstellung der Prozedur
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

  elUeberschrift      : int;

  elPosTextUS         : int;
  elPosText           : int;

  elPosMat1           : int;
  elPosMat2           : int;

  elPosArt1           : int;
  elPosArt2           : int;

  elAktUS             : int;
  elAkt1              : int;
  elAkt2              : int;
  elAktFuss           : int;

  elEnde              : int;
  elSumme             : int;
  elLeerzeile         : int;

  /// -----------------------------

  // Variablen...
  vPosCount   : int;
  vGesMEH     : alpha;
  vGesMenge   : float;
  vGesStk     : int;
  vGesGew     : float;
  vGesWert    : float;
  vGesWertW1  : float;
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

  if (Rek.Kundennr=0) then RETURN '';
  vBuf100 # RekSave(100);
  RecLink(100,300,9,_RecFirst);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Rek.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
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

    if (Scr.B.2.anPartnerYN) then RETURN;

    if (Scr.B.2.anLiefAdrYN) then begin
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

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();

  // ERSTE SEITE??
  if (aSeite=1) then begin
    form_Ele_Rek:elErsteSeite(var elErsteSeite);
    end
  else begin
    form_Ele_Rek:elFolgeSeite(var elFolgeSeite);
  end;


  if (Form_Mode='POS') then begin
    form_Ele_Rek:elUeberschrift(var elUeberschrift);
  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  form_Elemente:elSeitenFuss(var elSeitenFuss, true, 0.0);
end;


//========================================================================
//  PrintAktionen
//
//========================================================================
sub PrintAktionen();
local begin
  Erx       : int;
  vM        : float;
  vStk      : int;
  vGew      : float;
  vKost     : float;
  vCount    : int;
end;
begin

  form_Ele_Rek:elAktionUS(var elAktUS);

  FOR Erx # RecLink(302,301,2,_recFirst)
  LOOP Erx # RecLink(302,301,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    inc(vCount);

    form_Ele_Rek:elAktion1(var elAkt1, vCount);
    vStk  # vStk + "Rek.A.Stückzahl";
    vGew  # vGew + Rek.A.Gewicht;
    vKost # vKost + Rek.A.Kosten;
    form_Ele_Rek:elAktion2(var elAkt2, vCount);

  END;

  RecBufClear(302);
  "Rek.A.Stückzahl" # vStk;
  Rek.A.Gewicht     # vGew;
  Rek.A.Kosten      # vKost;

  form_Ele_Rek:elAktionFuss(var elAktFuss, vCount);
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
  vVPG          : alpha(1000);
  vVPGCount     : int;
  vSubStyle     : alpha;
end;
begin

  RekLink(300,301,1,_recFirst)    // Kopf holen
  RekLink(814,300,8,_RecFirst);   // Währung holen
  Auf_Data:Read(Rek.Auftragsnr, Rek.Auftragspos,y); // Auftrag holen
  Erx # RekLink(819,401,1,0);                       // Warengruppe holen
  RekLink(100,300,9,_RecFirst);   // Kunde holen
  RekLink(101,100,12,_recFirst);  // Hauptanschrift holen
  Erx # RekLink(812,100,10,_recFirst);       // Land holen
  if ("Lnd.kürzel"='D') or ("Lnd.kürzel"='DE') then
    RecbufClear(812);

  RekLink(814,300,8,_RecFirst);   // Währung holen

  Usr.Username # Auf.Sachbearbeiter;
  Erx # RecRead(800, 1, 0); // Benutzer holen
  if (Erx > _rLocked) then RecBufClear(800);

  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss vorbereiten
  form_Elemente:elSeitenFuss(var elSeitenFuss, false);

// ------- KOPFDATEN -----------------------------------------------------------------------
  form_FaxNummer  # Adr.Telefax;
  Form_EMA        # Adr.EMail;
  Lib_Print:Print_Seitenkopf();

// ------- POSITIONEN --------------------------------------------------------------------------
  form_Ele_Rek:elUeberschrift(var elUeberschrift);
  Form_Mode # 'POS';


  FOR Erx # RecLink(301,300,11,_recFirst)
  LOOP Erx # RecLink(301,300,11,_recnext)
  WHILE (Erx<=_rLocked) DO BEGIN

    if ("Rek.P.Löschmarker"='*') then CYCLE;

    Erx # RekLink(441,301,6,_recFirst);               // LFS holen
  //Rechnungsnummer, -datum

    RecBufClear(450);
    if (Rek.P.Rechnungsnr<>0) then begin
      Erx # RekLink(450,301,14,_recFirst);            // Erlös holen
//      PL_Print('Rechnung:', cPos2);
//      PL_Print(AInt(Rek.P.Rechnungsnr)+' vom '+cnvAD(Erl.Rechnungsdatum,_FmtInternal), cPos2a);
    end;

    RecBufClear(200);
    RecBufClear(250);
    RecBufClear(252);
    // Artikel ausgeben
    if (Wgr_Data:IstArt()) then begin
      Erx # RekLink(250,401,2,_RecFirst); // Artikel holen
      form_Ele_Rek:elPosArt1(var elPosArt1);
    end;
    // Material ausgeben
    if (Wgr_Data:IstMat()) or (Wgr_Data:IstMix()) then begin
      Mat_Data:Read(Rek.P.Materialnr);    // Material holen
      form_Ele_Rek:elPosMat1(var elPosMat1);
    end;

    if (vGesMEH='') then vGesMEH # Rek.P.MEH;
    if (vGesMEH=Rek.P.MEH) then
      vGesMenge # vGesMenge + Rek.P.Menge;
    vGesStk     # vGesStk + "Rek.P.Stückzahl";
    vGesGew     # vGesGew + Rek.P.Gewicht;
    vGesWert    # vGesWert + Rek.P.Wert;
    vGesWertW1  # vGesWertW1 + Rek.P.Wert.W1;

    // Artikel ausgeben
    if (Wgr_Data:IstArt()) then
      form_Ele_Rek:elPosArt2(var elPosArt2);
    // Material ausgeben
    if (Wgr_Data:IstMix()) or (Wgr_Data:IstMat()) then
      form_Ele_Rek:elPosMat2(var elPosMat2);


    // Text ausgeben...
    form_Elemente:elLeerzeile(var elLeerzeile);
    vTxtName # '~301.'+CnvAI(Rek.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Rek.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.1';
    //form_Ele_Rek:elPosTextUS(var elPosTextUS);
    form_Elemente:elPosText(var elPosText, vTxtName);

    PrintAktionen();

  END; // WHILE: Positionen ************************************************


  RecBufClear(301);
  Rek.P.Menge       # vGesMenge;
  Rek.P.MEH         # vGesMEH;
  "Rek.P.Stückzahl" # vGesStk;
  Rek.P.Gewicht     # vGesGew;
  Rek.P.Wert        # vGesWert;
  Rek.P.Wert.W1     # vGesWertW1;

  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  // 110 MM Rand unten lassen für den Fuss
//  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
//    form_Elemente:Leerzeile(var elLeerzeile);

  // Summe vorbelegen
//  form_Ele_Auf:elSumme(var elSumme);

  form_Ele_Rek:elEnde(var elEnde);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  FreeElement(var elErsteSeite        );
  FreeElement(var elFolgeSeite        );
  FreeElement(var elSeitenFuss        );

  FreeElement(var elUeberschrift      );

  FreeElement(var elPosTextUS         );
  FreeElement(var elPosText           );

  FreeElement(var elPosMat1           );
  FreeElement(var elPosMat2           );

  FreeElement(var elPosArt1           );
  FreeElement(var elPosArt2           );

  FreeElement(var elAktUS             );
  FreeElement(var elAkt1              );
  FreeElement(var elAkt2              );
  FreeElement(var elAktFuss           );

  FreeElement(var elSumme             );
  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile           );
end;


//=======================================================================