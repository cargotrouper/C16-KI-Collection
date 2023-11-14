@A+
//==== Business-Control ==================================================
//
//  Prozedur    Msl_Data
//                  OHNE E_R_G
//  Info
//
//
//  26.03.2009  MS  Erstellung der Prozedur
//  17.08.2010  AI  Strukturberechnen eingebaut
//  16.10.2013  AH  Anfragenx
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB AddLyse2Q(var aQ : alpha; aFeld1 : alpha; aFeld2 : alpha; aVon : float; aBis : float) : logic;
//    SUB AddFloatVB2Q(var aQ : alpha; aFeld : alpha; aVon : float; aBis : float) : logic;
//    SUB AddIntVB2Q(var aQ : alpha; aFeld : alpha; aVon : int; aBis : int) : logic;
//    SUB CheckAF(aDatei : int) : logic
//    SUB StrukturBerechnen()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//========================================================================
//  AddLyse2Q
//
//========================================================================
sub AddLyse2Q(
  var aQ  : alpha;
  aFeld1  : alpha;
  aFeld2  : alpha;
  aVon    : float;
  aBis    : float;
  ) : logic;
local begin
  vQ  : alpha(1000);
end;
begin
  if (aVon=0.0) and (aBis=0.0) then RETURN true;

  if (aFeld1<>'') and (aFeld2<>'') then begin
    Lib_Sel:QVonBisF(var vQ, aFeld1, 0.0, aBis);
    Lib_Sel:QVonBisF(var vQ, aFeld2, aVon, 9999.0);

    if (aQ<>'') then aQ # aQ + ' AND ';
    aQ # aQ + '( ('+vQ+') OR (';
    vQ # '';
    Lib_Sel:QFloat(var vQ, aFeld2, '=', 0.0);
    Lib_Sel:QVonBisF(var vQ, aFeld1, aVon, aBis);
    aQ # aQ + vQ +'))';

    end
  else begin
    Lib_Sel:QVonBisF(var aQ, aFeld1, aVon, aBis);
  end;

end;


//========================================================================
//  AddFloatVB2Q
//
//========================================================================
sub AddFloatVB2Q(
  var aQ  : alpha;
  aFeld   : alpha;
  aVon    : float;
  aBis    : float;
  ) : logic;
begin
  if (aVon != 0.0) then begin
    if (aBis != 0.0) then
      Lib_Sel:QVonBisF(var aQ, aFeld, aVon, aBis);
    else
      Lib_Sel:QFloat(  var aQ, aFeld, '=', aVon);
  end;
end;


//========================================================================
//  AddIntVB2Q
//
//========================================================================
sub AddIntVB2Q(
  var aQ  : alpha;
  aFeld   : alpha;
  aVon    : int;
  aBis    : int;
  ) : logic;
begin
  if (aVon != 0) then begin
    if (aBis != 0) then
      Lib_Sel:QVonBisI(var aQ, aFeld, aVon, aBis);
    else
      Lib_Sel:QInt(  var aQ, aFeld, '=', aVon);
  end;
end;


//========================================================================
//  ChechAF
//
//========================================================================
sub CheckAF(aDatei : int) : logic
local begin
  Erx     : int;
  vDatei1 : int;
  vDatei2 : int;
  vLink   : int;
  vPrefix : alpha;
  vOK     : logic;
end;
begin

  case aDatei of
    200 : begin
      vDatei1 # 200;
      vDatei2 # 201;
      vLink   # 11;
      vPrefix # 'Mat';
    end;
    401 : begin
      vDatei1 # 401;
      vDatei2 # 402;
      vLink   # 11;
      vPrefix # 'Auf';
    end;
    501 : begin
      vDatei1 # 501;
      vDatei2 # 502;
      vLink   # 12;
      vPrefix # 'Ein';
    end
    otherwise RETURN false;
  end;

  vOk # true;
  FOR  Erx # RecLink(221, 220, 11, _recFirst);
  LOOP Erx # RecLink(221, 220, 11, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vOk # true;
    FOR  Erx # RecLink(vDatei2, vDatei1, vLink, _recFirst);
    LOOP Erx # RecLink(vDatei2, vDatei1, vLink, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN
      if (FldAlphaByName(vPrefix+'.AF.Seite') = MSL.AF.Seite) and (FldWordByName(vPrefix+'.AF.ObfNr') = MSL.AF.ObfNr) then begin
        BREAK;
      end;
    END;

    // MLS.AF.Zusatz.Von gesetzt, dann nicht: MSL.AF.Zusatz.Bis gesetzt und Mat.AF.Zusatz = Festwert "MSL.AF.Zusatz.Von" oder
    // Mat.AF.Zusatz liegt NICHT zwischen MSL.AF.Zusatz.Von und MSL.AF.Zusatz.Bis
    if ( Erx != _rOk ) or ( ( MSL.AF.Zusatz.Von != '' ) and !(
        	( MSL.AF.Zusatz.Bis = '' and MSL.AF.Zusatz.Von = FldAlphaByName(vPrefix+'.AF.Zusatz') ) or
        	( MSL.AF.Zusatz.Von <= FldAlphaByName(vPrefix+'.AF.Zusatz') and FldAlphaByName(vPrefix+'.AF.Zusatz') <= MSL.AF.Zusatz.Bis ) ) ) then begin
      vOk # false;
      BREAK;
    end;
  END;

  RETURN vOK;
end;


//========================================================================
// StrukturBerechnen
//          Selektiert entsprechend der Struktur und
//          berechnet die Summenfelder
//========================================================================
sub StrukturBerechnen()
local begin
  Erx         : int;
 vSelName   : alpha;
 vSel       : int;

 vStk       : int;
 vGewicht   : float;
 vWert      : float;
 vMinPreis  : float;
 vMaxPreis  : float;

 vP         : float;
 vM         : float;

 vQ         : alpha(2000);
 vQ1        : alpha(2000);

 vOk        : logic;
end
begin

  // Ankerfunktion:
  if (RunAFX('MSL.Berechnen','')<>0) then RETURN;

  /*
  if (MSL.von.Datum > today) or (MSL.bis.Datum < today) then begin
    Msg(001203, Translate('Heutiges Datum'), _winIcoInformation, _winDialogOk, 0);
    RETURN;
  end;
  */

  // Aktuellen Satz sperren
  RecRead(220, 1, _recLock);
  /*
  "MSL.Sum.Stückzahl" # 0;
  "MSL.Sum.Gewicht"   # 0.0;
  "MSL.Sum.Wert"      # 0.0;
  "MSL.Min.Preis"     # 0.0;
  "MSL.Max.Preis"     # 0.0;
  */

  // ------------------------------------------------------------------------
  // -- MATERIAL ------------------------------------------------------------
  // ------------------------------------------------------------------------
  if (MSL.MaterialYN) then begin
    vQ  # '';
    vQ1 # '';

    Lib_Sel:QAlpha(  var vQ, 'Mat.Löschmarker', '=', '');

    /* Subselection - OR */
    if ("MSL.Güte" != '') then
      Lib_Sel:QAlpha(var vQ1, 'Mat.Güte',        '=*', "MSL.Güte");
    if ("MSL.Gütenstufe" != '') then
      Lib_Sel:QAlpha(var vQ1, 'Mat.Gütenstufe',  '=', "MSL.Gütenstufe");
    if ("MSL.Lieferantennr" != 0) then
      Lib_Sel:QInt(  var vQ1, 'Mat.Lieferant',   '=', "MSL.Lieferantennr");
    if ("MSL.Kundennr" != 0) then
//      Lib_Sel:QInt(  var vQ1, 'Mat.VK.Kundennr', '=', "MSL.Kundennr");
      Lib_Sel:QInt(  var vQ1, 'Mat.KommKundennr', '=', "MSL.Kundennr");

    AddIntVB2Q(var vQ1, 'Mat.Warengruppe', "MSL.Von.Warengruppe", "MSL.bis.Warengruppe");
    AddIntVB2Q(var vQ1, 'Mat.Status', "MSL.Von.Status", "MSL.bis.Status");
    AddFloatVB2Q(var vQ1, 'Mat.Dicke', MSL.Von.Dicke, MSL.bis.Dicke);
    AddFloatVB2Q(var vQ1, 'Mat.Breite', MSL.Von.Breite, MSL.bis.Breite);
    AddFloatVB2Q(var vQ1, 'Mat.Länge', "MSL.Von.Länge", "MSL.bis.Länge");
    AddFloatVB2Q(var vQ1, 'Mat.Bestand.Gew', MSL.Von.Gewicht, MSL.bis.Gewicht);
    AddIntVB2Q(var vQ1, 'Mat.Bestand.Stk', "MSL.Von.Stückzahl", "MSL.bis.Stückzahl");
    AddLyse2Q(var vQ1, 'Mat.Streckgrenze1','Mat.StreckgrenzeB1', MSL.Streckgrenze1, MSL.Streckgrenze2);
    AddLyse2Q(var vQ1, 'Mat.Zugfestigkeit1','Mat.ZugfestigkeitB1', MSL.Zugfestigkeit1, MSL.Zugfestigkeit2);
    if ("MSL.DehnungA1" != 0.0) then
      AddLyse2Q(var vQ1, 'Mat.DehnungA1','', MSL.DehnungA1, MSL.DehnungA1);
//      Lib_Sel:QFloat(  var vQ1, 'Mat.DehnungA1', '=', "MSL.DehnungA1");
    AddLyse2Q(var vQ1, 'Mat.DehnungB1','', MSL.DehnungB1, MSL.DehnungB2);

    if ("MSL.EigenYN") AND (!"MSL.NichtEigenYN") then
      vQ1 # vQ1 + ' AND Mat.EigenmaterialYN';
    else if (!"MSL.EigenYN") AND ("MSL.NichtEigenYN") then
      vQ1 # vQ1 + ' AND !Mat.EigenmaterialYN';

    if ("MSL.BestelltYN") AND (!"MSL.NichtBestelltYN") then
      Lib_Sel:QFloat(var vQ1, 'Mat.Bestellt.Gew', '>', 0.0);
    else if (!"MSL.BestelltYN") AND ("MSL.NichtBestelltYN") then
      Lib_Sel:QFloat(var vQ1, 'Mat.Bestellt.Gew', '=', 0.0);

    if ("MSL.ReservYN") AND (!"MSL.NichtReservYN") then
      Lib_Sel:QFloat(var vQ1, 'Mat.Reserviert.Gew', '>', 0.0);
    else if (!"MSL.ReservYN") AND ("MSL.NichtReservYN") then
      Lib_Sel:QFloat(var vQ1, 'Mat.Reserviert.Gew', '=', 0.0);

    if (MSL.Strukturnr != '') then begin
      Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr',  '=', MSL.Strukturnr, 'AND (' );
      if (vQ1 != '') then
        vQ # vQ + ' OR ( ' + vQ1 + ' )'
      vQ # vQ + ' )'
    end;
    else if (vQ1 != '') then
      vQ # vQ + ' AND (' + vQ1 + ')';

    vSel # SelCreate(200, 1);

    Erx # vSel->SelDefQuery('',     vQ);
    if (Erx<>0) then Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);


    FOR  Erx # RecRead(200, vSel, _recFirst);
    LOOP Erx # RecRead(200, vSel, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN

      if (CheckAF(200)=false) then CYCLE;

      vStk     # vStk     + Mat.Bestand.Stk;
      vGewicht # vGewicht + Mat.Bestand.Gew;
      vWert    # vWert    + (Mat.EK.Effektiv * Mat.Bestand.Gew / 1000.0);

      if (vMinPreis > Mat.EK.Effektiv) then
        vMinPreis # Mat.EK.Effektiv;

      if (vMaxPreis < Mat.EK.Effektiv) then
        vMaxPreis # Mat.EK.Effektiv;
    END;
    vSel->SelClose();
    SelDelete(200, vSelName);
  end;


  // ------------------------------------------------------------------------
  // -- VERKAUF -------------------------------------------------------------
  // ------------------------------------------------------------------------
  if (MSL.VerkaufYN) then begin

    // Struktur gefüllt...
    if (MSL.Strukturnr<>'') then begin
      FOR  Erx # RecLink(401, 220, 8, _recFirst);
      LOOP Erx # RecLink(401, 220, 8, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        if ("Auf.P.Löschmarker" != '') then
          CYCLE;

        // Kopfdaten lesen
        RecLink(400, 401, 3, _recFirst); // Auftragskopf
        vP # Lib_Einheiten:WandleMEH(401, 0, 1000.0, 1000.0, 'kg', Auf.P.MEH.Preis);
        vP # vP / CnvFI(Auf.P.PEH) * Auf.P.Grundpreis;
        Wae_Umrechnen(vP, "Auf.Währung", var vP, 1);

        // Summierung
        vStk     # vStk     + Auf.P.Prd.Rest.Stk;
        vGewicht # vGewicht + Auf.P.Prd.Rest.Gew;
        vWert    # vWert    + (vP * Auf.P.Prd.Rest.Gew / 1000.0);

        if (vMinPreis > vP) then
          vMinPreis # vP;

        if (vMaxPreis < vP) then
          vMaxPreis # vP;
      END;
      end

    // über Kriterien selektieren...
    else begin

      /* Subselection - OR */
      if ("MSL.Güte" != '') then
        Lib_Sel:QAlpha(var vQ, 'Auf.P.Güte',        '=*', "MSL.Güte");
      if ("MSL.Gütenstufe" != '') then
        Lib_Sel:QAlpha(var vQ, 'Auf.P.Gütenstufe',  '=', "MSL.Gütenstufe");
  //    if ("MSL.Lieferantennr" != 0) then
  //      Lib_Sel:QInt(  var vQ1, 'Auf.P.Lieferant',   '=', "MSL.Lieferantennr");
      if ("MSL.Kundennr" != 0) then
        Lib_Sel:QInt(  var vQ, 'Auf.P.Kundennr', '=', "MSL.Kundennr");

      Lib_Sel:QAlpha(  var vQ, 'Auf.P.Löschmarker', '=', '');

      if (MSL.von.Datum<>0.0.0) then
        Lib_Sel:QVonBisD(var vQ, 'Auf.P.Termin1Wunsch', MSL.von.Datum, MSL.bis.Datum);
      AddIntVB2Q(var vQ, 'Auf.P.Warengruppe', "MSL.Von.Warengruppe", "MSL.bis.Warengruppe");
      AddFloatVB2Q(var vQ, 'Auf.P.Dicke', MSL.Von.Dicke, MSL.bis.Dicke);
      AddFloatVB2Q(var vQ, 'Auf.P.Breite', MSL.Von.Breite, MSL.bis.Breite);
      AddFloatVB2Q(var vQ, 'Auf.P.Länge', "MSL.Von.Länge", "MSL.bis.Länge");
      AddIntVB2Q(var vQ, 'Auf.P.Stückzahl', "MSL.Von.Stückzahl", "MSL.bis.Stückzahl");
      AddFloatVB2Q(var vQ, 'Auf.P.Gewicht', MSL.Von.Gewicht, MSL.bis.Gewicht);

      AddLyse2Q(var vQ, 'Auf.P.Streckgrenze1','Auf.P.Streckgrenze2', MSL.Streckgrenze1, MSL.Streckgrenze2);
      AddLyse2Q(var vQ, 'Auf.P.Zugfestigkeit1','Auf.P.Zugfestigkeit2', MSL.Zugfestigkeit1, MSL.Zugfestigkeit2);
      if ("MSL.DehnungA1" != 0.0) then
        AddLyse2Q(var vQ, 'Auf.P.DehnungA1','', MSL.DehnungA1, MSL.DehnungA1);
      AddLyse2Q(var vQ, 'Auf.P.DehnungB1','Auf.P.DehnungB2', MSL.DehnungB1, MSL.DehnungB2);
  //    AddLyse2Q(var vQ, 'Auf.P.DehnungB1','', MSL.DehnungB1, MSL.DehnungB2);

      vSel # SelCreate(401, 1);
      Erx # vSel->SelDefQuery('',     vQ);
      if (Erx<>0) then Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      FOR  Erx # RecRead(401, vSel, _recFirst);
      LOOP Erx # RecRead(401, vSel, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN

        if (CheckAF(401)=false) then CYCLE;

        // Kopfdaten lesen
        RecLink(400, 401, 3, _recFirst); // Auftragskopf
        vP # Lib_Einheiten:WandleMEH(401, 0, 1000.0, 1000.0, 'kg', Auf.P.MEH.Preis);
        vP # vP / CnvFI(Auf.P.PEH) * Auf.P.Grundpreis;
        Wae_Umrechnen(vP, "Auf.Währung", var vP, 1);

        // Summierung
        vStk     # vStk     + Auf.P.Prd.Rest.Stk;
        vGewicht # vGewicht + Auf.P.Prd.Rest.Gew;
        vWert    # vWert    + (vP * Auf.P.Prd.Rest.Gew / 1000.0);

        if (vMinPreis > vP) then
          vMinPreis # vP;

        if (vMaxPreis < vP) then
          vMaxPreis # vP;
      END;
      vSel->SelClose();
      SelDelete(401, vSelName);
    end;  //... über Selektion

  end;


  // ------------------------------------------------------------------------
  // -- EINKAUF -------------------------------------------------------------
  // ------------------------------------------------------------------------
  if (MSL.EinkaufYN) then begin


    // Struktur gefüllt...
    if (MSL.Strukturnr<>'') then begin
      FOR  Erx # RecLink(501, 220, 9, _recFirst);
      LOOP Erx # RecLink(501, 220, 9, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        if ("Ein.P.Löschmarker" != '') then CYCLE;

        RekLink(500,501,3,_recFirst); // Kopf holen
        if (Ein.Vorgangstyp<>c_Bestellung) then CYCLE;

        vM # 0.0
        if (Ein.P.MEH = 'kg') then
          vM # Ein.P.FM.Rest;
        if (Ein.P.MEH = 't') then
          vM # Ein.P.FM.Rest * 1000.0;

        vP # Lib_Einheiten:WandleMEH(501, 0, 1000.0, 1000.0, 'kg', Ein.P.MEH.Preis);
        vP # vP / CnvFI(Ein.P.PEH) * Ein.P.Grundpreis;
        Wae_Umrechnen(vP, "Auf.Währung", var vP, 1);

        vStk     # vStk     + Ein.P.FM.Rest.Stk;
        vGewicht # vGewicht + vM;
        vWert    # vWert    + (vP * vM / 1000.0);

        if (vMinPreis > vP) then
          vMinPreis # vP;

        if (vMaxPreis < vP) then
          vMaxPreis # vP;
      END;
      end
    // über Kritierien selektieren...
    else begin

      /* Subselection - OR */
      if ("MSL.Güte" != '') then
        Lib_Sel:QAlpha(var vQ, 'Ein.P.Güte',        '=*', "MSL.Güte");
      if ("MSL.Gütenstufe" != '') then
        Lib_Sel:QAlpha(var vQ, 'Ein.P.Gütenstufe',  '=', "MSL.Gütenstufe");
      if ("MSL.Lieferantennr" != 0) then
        Lib_Sel:QInt(  var vQ1, 'Ein.P.Lieferantennr', '=', "MSL.Lieferantennr");
//      if ("MSL.Kundennr" != 0) then
//        Lib_Sel:QInt(  var vQ, 'Auf.P.Kundennr', '=', "MSL.Kundennr");

      Lib_Sel:QAlpha(  var vQ, 'Ein.P.Löschmarker', '=', '');

      if (MSL.von.Datum<>0.0.0) then
        Lib_Sel:QVonBisD(var vQ, 'Ein.P.Termin1Wunsch', MSL.von.Datum, MSL.bis.Datum);
      AddIntVB2Q(var vQ, 'Ein.P.Warengruppe', "MSL.Von.Warengruppe", "MSL.bis.Warengruppe");
      AddFloatVB2Q(var vQ, 'Ein.P.Dicke', MSL.Von.Dicke, MSL.bis.Dicke);
      AddFloatVB2Q(var vQ, 'Ein.P.Breite', MSL.Von.Breite, MSL.bis.Breite);
      AddFloatVB2Q(var vQ, 'Ein.P.Länge', "MSL.Von.Länge", "MSL.bis.Länge");
      AddIntVB2Q(var vQ, 'Ein.P.Stückzahl', "MSL.Von.Stückzahl", "MSL.bis.Stückzahl");
      AddFloatVB2Q(var vQ, 'Ein.P.Gewicht', MSL.Von.Gewicht, MSL.bis.Gewicht);

      AddLyse2Q(var vQ, 'Ein.P.Streckgrenze1','Ein.P.Streckgrenze2', MSL.Streckgrenze1, MSL.Streckgrenze2);
      AddLyse2Q(var vQ, 'Ein.P.Zugfestigkeit1','Ein.P.Zugfestigkeit2', MSL.Zugfestigkeit1, MSL.Zugfestigkeit2);
      if ("MSL.DehnungA1" != 0.0) then
        AddLyse2Q(var vQ, 'Ein.P.DehnungA1','', MSL.DehnungA1, MSL.DehnungA1);
      AddLyse2Q(var vQ, 'Ein.P.DehnungB1','Ein.P.DehnungB2', MSL.DehnungB1, MSL.DehnungB2);

      vSel # SelCreate(501, 1);
      Erx # vSel->SelDefQuery('',     vQ);
      if (Erx<>0) then Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      FOR  Erx # RecRead(501, vSel, _recFirst);
      LOOP Erx # RecRead(501, vSel, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN

        if (CheckAF(501)=false) then CYCLE;

        RekLink(500,501,3,_recFirst); // Kopf holen
        if (Ein.Vorgangstyp<>c_Bestellung) then CYCLE;

        vM # 0.0
        if (Ein.P.MEH = 'kg') then
          vM # Ein.P.FM.Rest;
        if (Ein.P.MEH = 't') then
          vM # Ein.P.FM.Rest * 1000.0;

        vP # Lib_Einheiten:WandleMEH(501, 0, 1000.0, 1000.0, 'kg', Ein.P.MEH.Preis);
        vP # vP / CnvFI(Ein.P.PEH) * Ein.P.Grundpreis;
        Wae_Umrechnen(vP, "Auf.Währung", var vP, 1);

        vStk     # vStk     + Ein.P.FM.Rest.Stk;
        vGewicht # vGewicht + vM;
        vWert    # vWert    + (vP * vM / 1000.0);

        if (vMinPreis > vP) then
          vMinPreis # vP;

        if (vMaxPreis < vP) then
          vMaxPreis # vP;
      END;
      vSel->SelClose();
      SelDelete(501, vSelName);
    end;  //... über Selektion

  end;

  // Summen speichern
  "MSL.Sum.Stückzahl" # vStk;
  "MSL.Sum.Gewicht"   # vGewicht;
  "MSL.Sum.Wert"      # Rnd(vWert, 2);
  "MSL.Min.Preis"     # vMinPreis;
  "MSL.Max.Preis"     # vMaxPreis;

  RekReplace(220, _recUnlock, 'AUTO');
end;


//========================================================================
