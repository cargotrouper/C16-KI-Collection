@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Qck_Tafeln_Data
//                    OHNE E_R_G
//  Info
//
//
//  09.06.2015  AH  Erstellung der Prozedur
//  01.07.2015  AH  für 4 Fertigungen
//  26.07.2016  AH  für 6 Fertigungen
//  05.04.2022  AH  ERX
//  2022-12-19  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    sub Verbuchen() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_aktionen

define begin
  cAktion               : 'TAFEL'
  cVerwiegungsart       : 1
end;

//========================================================================
//  Verbuchen
//      +ERR
//========================================================================
sub Verbuchen(
  aEinsatzMat     : int;
  aEinsatzStk     : int;
  aEinsatzGew     : float;

  aKommi1         : alpha;
  aArtikel1       : alpha;
  aFertigStk1     : int;
  aFertigD1       : float;
  aFertigB1       : float;
  aFertigL1       : float;
  aFertigGew1     : float;

  aKommi2         : alpha;
  aArtikel2       : alpha;
  aFertigStk2     : int;
  aFertigD2       : float;
  aFertigB2       : float;
  aFertigL2       : float;
  aFertigGew2     : float;

  aKommi3         : alpha;
  aArtikel3       : alpha;
  aFertigStk3     : int;
  aFertigD3       : float;
  aFertigB3       : float;
  aFertigL3       : float;
  aFertigGew3     : float;

  aKommi4         : alpha;
  aArtikel4       : alpha;
  aFertigStk4     : int;
  aFertigD4       : float;
  aFertigB4       : float;
  aFertigL4       : float;
  aFertigGew4     : float;

  aKommi5         : alpha;
  aArtikel5       : alpha;
  aFertigStk5     : int;
  aFertigD5       : float;
  aFertigB5       : float;
  aFertigL5       : float;
  aFertigGew5     : float;

  aKommi6         : alpha;
  aArtikel6       : alpha;
  aFertigStk6     : int;
  aFertigD6       : float;
  aFertigB6       : float;
  aFertigL6       : float;
  aFertigGew6     : float;

  aMitEtiketten   : logic;
) : logic;
local begin
  Erx         : int;
  vMatNr      : int;
  vNeuesMat   : int;
  vNetto      : float;
  vBrutto     : float;
  vM          : float;
  vI,vJ       : int;
  vFertigung  : int;
  vInputID    : int;
  vOutputID   : int;
  vMitRestEtk : logic;
  vRestMat    : int;
end;
begin


  Mat.Nummer # aEinsatzMat;
  Erx # RecRead(200,1,0);   // Material holen
  if (Erx>_rLocked) then begin
    Error(701039, aint(Mat.Nummer));
    RETURN false;
  end;
  if ((Mat.Status<c_Status_Frei) or (Mat.Status>c_Status_bisFrei)) or ("Mat.Löschmarker"<>'') then begin
    Error(441002,'');
    RETURN false;
  end;
  if (Mat.Bestand.Stk<aEinsatzStk) then begin
    Error(701040, '');
    RETURN false;
  end;


  if (aMitEtiketten) and (aEinsatzGew < Mat.Bestand.Gew) then
    vMitRestEtk # Msg(700012,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes;


  TRANSON;

  vNeuesMat # Mat.Nummer;

  // neues Einsatzmaterial bei Teilentnahme
  if (aEinsatzGew < Mat.Bestand.Gew) then begin
    // Dreisatz!
    vNetto  # Rnd(Lib_Berechnungen:Dreisatz(Mat.Gewicht.Netto, Mat.Bestand.Gew, aEinsatzGew), Set.Stellen.Gewicht);
    vBrutto # Rnd(Lib_Berechnungen:Dreisatz(Mat.Gewicht.Brutto, Mat.Bestand.Gew, aEinsatzGew), Set.Stellen.Gewicht);
    vM      # Rnd(Lib_Berechnungen:Dreisatz(Mat.Bestand.Menge, Mat.Bestand.Gew, aEinsatzGew), Set.Stellen.Menge);
    if (Mat_Data:Splitten(aEinsatzStk, vNetto, vBrutto, vM, today, now, var vNeuesMat)=false) then begin
      TRANSBRK;
      Error(010005, '1|'+AInt(Mat.Nummer));
      RETURN false;
    end;
//    if (Mat.Bestand.Stk > 0) then
    vRestMat # Mat.Nummer;

    Mat.Nummer # vNeuesMat;
    Erx # RecRead(200,1,0);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(701031,aint(vNeuesMat));
      RETURN false;
    end;

  end;


  // BA-Kopf anlegen *************************
  if (BA1_Subs:CreateBAG()=0) then begin
    TRANSBRK;
    Error(700011,'');
    RETURN false;
  end;


  // Position anlegen ************************
  if (BA1_P_Data:Erzeuge702(1, cAktion, 0,0)=false) then begin
    TRANSBRK;
    Error(702041,'');
    RETURN false;
  end;


  // Input anlegen ***************************
  if (BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, vNeuesMat)=false) then begin
    TRANSBRK;
    Error(701031, AInt(Mat.Nummer));
    RETURN false;
  end;
  vInputID # BAG.IO.ID;


  // Fertigungen anlegen *********************
  FOR vI # 1 loop inc (vI) while (vI<=6) do begin

    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Fertigung         # vFertigung;
    BAG.F.AutomatischYN     # n;
    BAG.F.MEH               # 'kg'; // 2022-12-19 AH Fallback, sonst Artikel ! BA1_P_Data:ErmittleMEH();
    BAG.F.Warengruppe       # Mat.Warengruppe;

    if (vI=1) then begin
      BAG.F.Kommission        # aKommi1;
      BAG.F.Artikelnummer     # aArtikel1;
      "BAG.F.Stückzahl"       # aFertigStk1;
      BAG.F.Gewicht           # aFertigGew1;
      BAG.F.Dicke             # aFertigD1;
      BAG.F.Breite            # aFertigB1;
      "BAG.F.Länge"           # aFertigL1;
    end
    else if (vI=2) then begin
      BAG.F.Kommission        # aKommi2;
      BAG.F.Artikelnummer     # aArtikel2;
      "BAG.F.Stückzahl"       # aFertigStk2;
      BAG.F.Gewicht           # aFertigGew2;
      BAG.F.Dicke             # aFertigD2;
      BAG.F.Breite            # aFertigB2;
      "BAG.F.Länge"           # aFertigL2;
    end
    else if (vI=3) then begin
      BAG.F.Kommission        # aKommi3;
      BAG.F.Artikelnummer     # aArtikel3;
      "BAG.F.Stückzahl"       # aFertigStk3;
      BAG.F.Gewicht           # aFertigGew3;
      BAG.F.Dicke             # aFertigD3;
      BAG.F.Breite            # aFertigB3;
      "BAG.F.Länge"           # aFertigL3;
    end
    else if (vI=4) then begin
      BAG.F.Kommission        # aKommi4;
      BAG.F.Artikelnummer     # aArtikel4;
      "BAG.F.Stückzahl"       # aFertigStk4;
      BAG.F.Gewicht           # aFertigGew4;
      BAG.F.Dicke             # aFertigD4;
      BAG.F.Breite            # aFertigB4;
      "BAG.F.Länge"           # aFertigL4;
    end
    else if (vI=5) then begin
      BAG.F.Kommission        # aKommi5;
      BAG.F.Artikelnummer     # aArtikel5;
      "BAG.F.Stückzahl"       # aFertigStk5;
      BAG.F.Gewicht           # aFertigGew5;
      BAG.F.Dicke             # aFertigD5;
      BAG.F.Breite            # aFertigB5;
      "BAG.F.Länge"           # aFertigL5;
    end
    else if (vI=6) then begin
      BAG.F.Kommission        # aKommi6;
      BAG.F.Artikelnummer     # aArtikel6;
      "BAG.F.Stückzahl"       # aFertigStk6;
      BAG.F.Gewicht           # aFertigGew6;
      BAG.F.Dicke             # aFertigD6;
      BAG.F.Breite            # aFertigB6;
      "BAG.F.Länge"           # aFertigL6;
    end;

    if (BAG.F.Kommission='') then  begin
      "BAG.F.KostenträgerYN"  # n;
    end
    else if (BAG.F.Kommission='KOSTEN') then begin
      BAG.F.Kommission        # '';
      "BAG.F.KostenträgerYN"  # Y;
    end
    else
      "BAG.F.KostenträgerYN"  # Y;

    BAG.F.Streifenanzahl      # "BAG.F.Stückzahl";

    if (BAG.F.Artikelnummer<>'') then begin
      Erx # RekLink(250,703,13,_recfirst);   // Artikel holen
      if (Erx<=_rLocked) then begin
        BAG.F.Warengruppe # Art.Warengruppe;
        BAG.F.MEH         # Art.MEH;      // 2022-12-19 AH
      end;
    end;


    // KEINE FERTIGUNG? -> Überspringen
    if ("BAG.F.Stückzahl"=0) then CYCLE;

    inc(vFertigung);

    if (BAG.F.MEH='m') then
      BAG.F.Menge # Rnd(cnvfi("BAG.F.Stückzahl") * "BAG.F.Länge" / 1000.0, Set.Stellen.Menge)

    BAG.F.Anlage.Datum  # Today;
    BAG.F.Anlage.Zeit   # Now;
    BAG.F.Anlage.User   # gUserName;
    Erx # BA1_F_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Error(703008,'');
      RETURN false;
    end;


    // Fertigmaterial updaten...
    BAG.IO.Nummer # BAG.P.Nummer;
    BAG.IO.ID     # vInputID;
    RecRead(701,1,0);
    if (BA1_F_Data:UpdateOutput(703,n)=false) then begin
      TRANSBRK;
      Error(703008,'');
      RETURN false;
    end;


    // VSBs anlegen ****************************
    if (BA1_P_Data:AutoVSB()=false) then begin
      TRANSBRK;
      Error(702007,'');
      RETURN false;
    end;


    // Fertigmelden ****************************
    Erx # RecLink(701,702,3,_recFirst);     // Output holen
    WHILE (Erx<=_rLocked) and (BAG.IO.VonFertigung<>BAG.F.Fertigung) do begin
      Erx # RecLink(701,702,3,_recNext);    // Output holen
    END;
    if (Erx>_rLocked) then begin
      TRANSBRK;
      Error(700011,'');
      RETURN false;
    end;
    vOutputID # BAG.IO.ID;

    BAG.IO.Nummer # BAG.Nummer;
    BAG.IO.ID     # vInputID;
    Recread(701,1,0);
    Erx # RecLink(200,701,11,_recFirst);  // Restkarte holen
    if (Erx>_rLocked) then begin
      Error(701039, aint(BAG.IO.MaterialRstNr));
      BREAK;
    end;

    // fertigmeldung füllen...
    RecBufClear(707);

    BA1_FM_Data:Vorbelegen();

    BAG.FM.Nummer         # myTmpNummer;
    BAG.FM.Position       # BAG.P.Position;
    BAG.FM.Fertigung      # BAG.F.Fertigung;
    BAG.FM.InputBAG       # BAG.P.Nummer;
    BAG.FM.InputID        # BAG.IO.ID;
    BAG.FM.Werksnummer    # Mat.Werksnummer;
    BAG.FM.BruderID       # vOutputID;
//      BAG.FM.Lagerplatz # 'KOM.-PLATZ SÄGE';

    BAG.FM.Verwiegungart  # cVerwiegungsart;
    BAG.FM.MaterialTyp    # c_IO_Mat;
    BAG.FM.Status         # 1;
    BAG.FM.Datum          # today;

    "BAG.FM.Länge"        # "BAG.F.Länge";
    "BAG.FM.Stück"        # "BAG.F.Stückzahl";
    BAG.FM.Gewicht.Netto  # BAG.F.Gewicht;
    BAG.FM.Gewicht.Brutt  # BAG.F.Gewicht;
    BAG.FM.MEH            # BAG.F.MEH;//'m';
    BAG.FM.Menge          # "BAG.F.Menge";//;cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" / 1000.0;

    // FERTIGMELDEN................................................
    //    MAT: RESTKARTE
    //    BAG-IO: INPUT
    if (BA1_Fertigmelden:Verbuchen(false)=false) then begin // OHNE ETIKETT
      TRANSBRK;
      Error(707002,'');
      RETURN false;
    end;

  END;


  // sofort Abschließen...
  if (BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, today, now, true)=falsE) then begin
    TRANSBRK;
    RETURN false;
  end;


  TRANSOFF;


  if (aMitEtiketten) then begin

    if (vMitRestEtk) and (vRestMat > 0) then begin          // Restmaterial
      Mat_Data:Read(vRestMat);
      if (Mat.Nummer > 0) then
        Mat_Etikett:Init(Set.Ein.WE.Etikett);
    end;

    // Fertigmaterialien
    FOR   Erx # RecLink(707,700,5,_RecFirst)
    LOOP  Erx # RecLink(707,700,5,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      Mat_Data:Read(BAG.FM.Materialnr);
      if (Mat.Nummer > 0) then begin
        Mat_Etikett:Init(Mat.Etikettentyp);
      end;

    END;

  end;

  RETURN true;
end;


//========================================================================