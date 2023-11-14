@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_AUF_Gelangen  (auf Basis von Rechnungsformular)
//                          OHNE E_R_G
//  Info
//    Druckt eine Gelangensbestätigung
//
//
//  11.03.2013  ST  Erstellung der Prozedur
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

  elAktion            : int;

  elEinsatzUS         : int;
  elEinsatz1          : int;
  elEinsatz2          : int;
  elEinsatzFuss       : int;

  elFertigungUS       : int;
  elFertigung1        : int;
  elFertigung2        : int;
  elFertigungFuss     : int;

  elEnde              : int;
  elSumme             : int;
  elLeerzeile         : int;

  /// -----------------------------

  // Variablen...
  vBuf101WeLand       : int;
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
  vPosMengeLFS        : float;

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
end;
begin
  vBuf100 # RekSave(100);
  RecLink(100,450,8,_RecFirst);   // Rechnungsempfänger holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN cnvAI(Erl.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  Erx       : int;
  vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

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
      Erx # RecLink(110,100,16,_recFirst);  // Vertreter holen
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
      Erx # RecLink(110,100,16,_recFirst);  // Verband holen
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
  vTitel      : alpha(4096);
  vA,vA2,vA3  : alpha(4096);
  vPre        : alpha(4096);
  vPost       : alpha(4096);
  vI          : int;
  vZeilen     : int;
  vFeld       : alpha(4096);
  vAdd        : alpha(4096);
  v812        : int;
end
begin

  vFeld   # Str_Token(aText, '|', 1);
  vTitel  # Str_Token(aText, '|', 2);
  vPost   # Str_Token(aText, '|', 3);
  vPre    # Str_Token(aText, '|', 4);


  case (StrCnv(vFeld, _StrUpper)) of
     'MYWARENEMPFAENGER' :  begin
                            vA  # StrAdj(vBuf101We->Adr.A.Anrede,_StrBegin | _StrEnd)  + ' ' +
                                    StrAdj(vBuf101We->Adr.A.Name,_StrBegin | _StrEnd)    + ' ' +
                                    StrAdj(vBuf101We->Adr.A.Zusatz,_StrBegin | _StrEnd);
                            inc(vZeilen);
                            AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                            vTitel # '';
                            aInhalt # aInhalt + StrChar(10);
                            aLabels # aLabels + StrChar(10);
                            aZusatz # aZusatz + StrChar(10);

                            vA #  StrAdj(vBuf101We->"Adr.A.Straße",_StrBegin | _StrEnd) + ', ' +
                                  StrAdj(vBuf101We->Adr.A.PLZ,_StrBegin | _StrEnd) + ' ' +
                                  StrAdj(vBuf101We->Adr.A.Ort,_StrBegin | _StrEnd)  + ', ' +
                                  StrAdj(vBuf101WeLand->Lnd.Name.L1,_StrBegin | _StrEnd);

                            vAdd # vA;
                        end;

    'MYWARENEMPFAENGERORT' :  begin
                            vA #  StrAdj(vBuf101We->Adr.A.PLZ,_StrBegin | _StrEnd) + ' ' +
                                  StrAdj(vBuf101We->Adr.A.Ort,_StrBegin | _StrEnd)  + ', ' +
                                  StrAdj(vBuf101WeLand->Lnd.Name.L1,_StrBegin | _StrEnd);
                            vAdd # vA;

                        end;

    'MYLIEFERDATUM' : begin
                            vAdd # CnvAd(Gv.Datum.01);
                      end;

  end;


  if (vAdd<>'') then begin
    inc(vZeilen);
    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
  end;


  RETURN vZeilen;
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
    form_Ele_Auf:elABErsteSeite(var elErsteSeite, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);
    form_Elemente:elKopfText(var elKopfText,'~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K');
    end
  else begin
    form_Ele_Auf:elABFolgeSeite(var elFolgeSeite, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);
  end;


  if (Form_Mode='POS') then begin
    form_Ele_Auf:elABUeberschrift(var elUeberschrift);
  end;

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
//========================================================================
sub PrintAktionen(aTree  : int);
local begin
  vItem   : int;
  vCount  : int;
end;
begin

  FOR vItem # CteRead(aTree, _ctefirst)
  LOOP vItem # CteRead(aTree, _cteNext, vItem)
  WHILE (vItem<>0) do begin

    // Aktion holen
    RecRead(404,0,_recId, vItem->spid);

    inc(vCount);

    "Auf.A.Stückzahl" # cnvia(Str_Token(vItem->spcustom,'|',1));
    Auf.A.Gewicht     # cnvfa(Str_Token(vItem->spcustom,'|',2));
    Auf.A.Menge       # cnvfa(Str_Token(vItem->spcustom,'|',3));
    Auf.A.Menge.Preis # cnvfa(Str_Token(vItem->spcustom,'|',4));
    RecBufClear(440);
    if (Auf.A.Aktionstyp=c_AKT_LFS) then
      RekLink(440,404,11,_recFirsT);  // LFS holen

    RekLink(401,404,1,0); //  Auftragsposition lesen
    RekLink(819,401,1,0); //  Warengruppendext lesen

    Form_Ele_Auf:elRechAktion(var elAktion, vCount);

  END;

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
  vBisLiefDatum : date;
  vTree         : int;
  vItem         : int;
  vStk          : int;
  vSortKey      : alpha;
  vGew,vM,vMP   : float;
  vOK           : logic;
  vVPG          : alpha(1000);
  vVPGCount     : int;
  vSubStyle     : alpha;
end;
begin

  vBisLiefDatum # Gv.Datum.01; // Lieferdatum übernehmen


  vBuf100Re # Adr_Data:HoleBufferAdrOderAnschrift(Auf.Rechnungsempf, Auf.Rechnungsanschr);
  RekLinkB(vBuf101We, 400, 2, _recFirst);   // Warenempfänger holen

  RekLinkB(vBuf101WeLand, 101, 2, _recFirst);   // Land des Warenempfängers holen


  RekLink(814,400,8,_recFirst);             // Währung holen
  RekLinkB(vBuf110Ver1,400,20,_recFirst);   // Vertreter 1 holen
  RekLinkB(vBuf110Ver2,400,21,_recFirst);   // Vertreter 2 holen
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

  // Baum für die Aktionen/LFS
  vTree # CteOpen(_CteTreeCI);


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss vorbereiten
  form_Elemente:elSeitenFuss(var elSeitenFuss, false);


// ------- KOPFDATEN -----------------------------------------------------------------------
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;
  Lib_Print:Print_Seitenkopf();
  vAdrNr      # Adr.Nummer;

// ------- POSITIONEN --------------------------------------------------------------------------
  form_Elemente:elLeerzeile(var elLeerzeile);
    form_Elemente:elLeerzeile(var elLeerzeile);

  form_Ele_Auf:elABUeberschrift(var elUeberschrift);
  Form_Mode # 'POS';


  vTree->CteClear(y);


  // Stückzahl, Menge und Gewicht aus Aktionen bestimmen
  FOR Erx # RecLink(404,401,12,_RecFirst)
  LOOP Erx # RecLink(404,401,12,_Recnext)
  WHILE (Erx<=_rLocked) do begin


   if ("Auf.A.Löschmarker"='*') or (Auf.A.Rechnungsnr = 0) or
        (Auf.A.TerminEnde>vBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or
        (Auf.A.Rechnungsdatum = 0.0.0) then
        CYCLE;


    if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then
      CYCLE;

    // LFS bereits aufgenommen?
    vSortkey # aint(Auf.A.Aktionsnr);
    if (auf.A.TerminEnde<>0.0.0) then vSortKey # vSortkey + '|'+cnvad(Auf.A.Terminende);
    vItem # vTree->CteRead(_CteFirst | _CteSearch, 0, vSortkey);
    if (vItem=0) then begin     // NEIN -> Merken und drucken...
      vItem # CteOpen(_CteItem);
      if (vItem<>0) then begin

        vStk  # "Auf.A.Stückzahl";
        vGew  # Auf.A.Gewicht;
        vM    # Auf.A.Menge;
        vMP   # Auf.A.Menge.Preis;

        vItem->spName   # vSortKey;
        vItem->spID     # recinfo(404,_recID);
        CteInsert(vTree,vItem); // in Baum speichern
      end;
      end
    else begin  // gibt's schon -> summieren
      vStk  # cnvia(Str_Token(vItem->spcustom,'|',1)) + "Auf.A.Stückzahl";
      vGew  # cnvfa(Str_Token(vItem->spcustom,'|',2)) + Auf.A.Gewicht;
      vM    # cnvfa(Str_Token(vItem->spcustom,'|',3)) + Auf.A.Menge;
      vMP   # cnvfa(Str_Token(vItem->spcustom,'|',4)) + Auf.A.Menge.Preis;
    end;
    vItem->spcustom # aint(vStk)+'|'+anum(vGew, Set.Stellen.Gewicht)+'|'+anum(vM,Set.Stellen.Menge)+'|'+anum(vMP,Set.Stellen.Menge);

  END;

  if (CteInfo(vTree,_CteCount) > 0) then begin
    // Lieferungsaktionen ausgeben
    PrintAktionen(vTree);
  end;

  // Leerzeile zwischen den Positionen
  form_Elemente:elLeerzeile(var elLeerzeile);


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  form_Ele_Auf:elGelangenEnde(var elEnde, vBuf100Re, vBuf101We, vBuf110Ver1, vBuf110Ver2);


// -------- Druck beenden ----------------------------------------------------------------

  gFrmMain->wpdisabled # false;

  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", true, n, aFilename)

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

  FreeElement(var elAktion            );

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

  FreeElement(var elSumme             );
  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile           );


end;


//=======================================================================