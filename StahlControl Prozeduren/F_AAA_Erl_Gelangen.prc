@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_Erl_Gelangen
//                        OHNE E_R_G
//  Info
//    Druckt eine Sammelgelangensbestätigung
//
//
//  11.09.2013  ST  Erstellung der Prozedur
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
  elRechnung          : int;

  elEnde              : int;
  elLeerzeile         : int;

  /// -----------------------------

  // Variablen...
  gAbnehmer         : alpha(4000);
  gAbnehmerUstIdent : alpha;
  gRechnungsnr      : int;
  gRechnungsDatum   : date;
  gAuftragsnr       : int;
  gGewicht          : float;
  gRechnungsbetrag  : float;
  gMitgliedsstaat   : alpha;
  gGelangensort     : alpha;

  gSumGewicht       : float;
  gSumBetrag        : float;

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

  // Dokument ist prinzipiell eine Liste und wird immer neu erstellt
  RETURN Lib_Strings:TimestampFullYearMs();      // Dokumentennummer
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
    'MYABNEHMER'    : vAdd # gAbnehmer;
    'MYUSTIDENT'    : vAdd # gAbnehmerUstIdent;
    'MYAUFTRAGSNR'  : vAdd # Aint(gAuftragsnr);
    'MYSTAAT'       : vAdd # gMitgliedsstaat;
    'MYORT'         : vAdd # gGelangensort;
    'MYSUMGEWICHT'  : vAdd # Anum(gSumGewicht, Set.Stellen.Gewicht);
    'MYSUMBETRAG'   : vAdd # Anum(gSumBetrag, 2);
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

  // ERSTE SEITE??
  if (aSeite=1) then begin
    form_Ele_Erl:elGelErsteSeite(var elErsteSeite);
    end
  else begin
    form_Ele_Erl:elGelFolgeSeite(var elFolgeSeite);
  end;

  if (Form_Mode='POS') then begin
    form_Ele_Erl:elGelUeberschrift(var elUeberschrift);
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
//========================================================================
sub PrintAktionen(aTree  : int);
local begin
  vItem   : int;
  vCount  : int;
end;
begin
  gSumGewicht    # 0.0;
  gSumBetrag     # 0.0;

  FOR vItem # CteRead(aTree, _ctefirst)
  LOOP vItem # CteRead(aTree, _cteNext, vItem)
  WHILE (vItem<>0) do begin

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    RecLink(451,450,1,_RecFirst); // Erstes Erlöskonto für die Auftragsnummer lesen

    // Daten lesen (Gelangensort und Staat)
    Auf_Data:Read(Erl.K.Auftragsnr,Erl.K.Auftragspos,true);

    gAuftragsnr       # Auf.P.Nummer;
    gMitgliedsstaat # '';
    gGelangensort   # '';

    RekLink(101,400,2,0);     // Lieferanschrift
    RekLink(100,400,3,0);     // Verbraucher lesen

    //  Lieferanschrift = Eignene Lieferadresse?
    //   --> Dann Gelangensort aus Verbraucher
    if (Auf.Lieferadresse = Set.eigeneAdressnr) then begin
      gMitgliedsstaat # Adr.LKZ;
      gGelangensort   # Adr.Ort;
    end else begin
      gMitgliedsstaat # Adr.A.LKZ;
      gGelangensort   # Adr.A.Ort;
    end;

    Form_Ele_Erl:elGelRechnung(var elRechnung);


    gSumGewicht # gSumGewicht +   Erl.Gewicht;
    gSumBetrag  # gSumBetrag  +   Erl.NettoW1;

  END;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
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

  // Keine Rechnungen?
  if (gFormParaHdl = 0) then
    RETURN;

  if (CteInfo(gFormParaHdl,_CteCount) <= 0) then
    RETURN;

  // Kundenadresse ist geladen -> ADR
  gAbnehmer          # StrAdj(Adr.Name + ' ' +Adr.Zusatz,_StrBegin | _StrEnd) + ', ' +
                          "Adr.Straße" + ' ' + Adr.LKZ + '-' + Adr.PLZ + ' ' + Adr.Ort;
  gAbnehmerUstIdent  # Adr.USIdentNr;


  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  if (Sel.Fin.LiefGutBelYN)  then
    Frm.Style # Frm.Style + '_EN'
  else
  if (Sel.Fin.nurMarkeYN)  then
    Frm.Style # Frm.Style + '_FR';

  Lib_Form:LoadStyleDef(Frm.Style);

  form_RandOben   # cnvfi(PrtUnitLog(20.0,_PrtUnitMillimetres));   // Rand setzen
  form_RandUnten  # PrtUnitLog(4.0,_PrtUnitMillimetres);          // Rand setzen

  // Seitenfuss vorbereiten
  form_Elemente:elSeitenFuss(var elSeitenFuss, false);


  // ------- KOPFDATEN -----------------------------------------------------------------------
  Form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;
  Form_Betreff    # 'Gelangensbestätigung-' + Adr.Stichwort;
  Lib_Print:Print_Seitenkopf();


  // ------- POSITIONEN --------------------------------------------------------------------------
//  form_Elemente:elLeerzeile(var elLeerzeile);

  form_Ele_Erl:elGelUeberschrift(var elUeberschrift);
  Form_Mode # 'POS';

  PrintAktionen(gFormParaHdl);

  // ------- FUßDATEN ----------------------------------------------------------------------
  Form_Mode # 'FUSS';

  form_Ele_Erl:elGelEnde(var elEnde);


  // -------- Druck beenden ----------------------------------------------------------------
  gFrmMain->wpdisabled # false;

  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", true, n, aFilename)

  // Objekte entladen
  FreeElement(var elErsteSeite  );
  FreeElement(var elFolgeSeite  );
  FreeElement(var elSeitenFuss  );
  FreeElement(var elUeberschrift);
  FreeElement(var elRechnung    );
  FreeElement(var elEnde        );
  FreeElement(var elLeerzeile   );
end;


//=======================================================================