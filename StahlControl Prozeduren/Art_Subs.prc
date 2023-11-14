@A+
//===== Business-Control =================================================
//
//  Prozedur  Art_Subs
//                OHNE E_R_G
//  Info
//
//
//  03.08.2011  AI  Erstellung der Prozedur
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//  SUB _VerbucheSL(aMenge : Float; aGrund : alpha; var aKosten : float) : logic;
//  SUB Produziere() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG

define begin
end;

//========================================================================
//  _VerbucheSL
//
//========================================================================
sub _VerbucheSL(
  aMenge      : Float;
  aGrund      : alpha;
  var aKosten : float;
) : logic;
local begin
  Erx     : int;
  vBuf250 : int;
  vMenge  : float;
  vPreis  : float;
  vPreisPEH : int;
end;
begin
  vBuf250 # RekSave(250);

  // Stückliste loopen...
  Erx # RecLink(256,255,2,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Art.SL.Menge=0.0) then begin
      Erx # RecLink(256,255,2,_RecNext);
      CYCLE;
    end;

    // EINSATZARTIKEL ???
    if (Art.SL.Typ=250) then begin
      Erx # RecLink(250,256,2,_recFirst);   // Einsatzartikel holen
      if (Erx>_rLocked) then begin
        RekRestore(vBuf250);
        RETURN false;
      end;

      vMenge # (aMenge * Art.SL.Menge);

      RecBufClear(252);
      Art.C.Charge.Intern # '';
      Art.C.ArtikelNr     # Art.Nummer;
      Art.C.Lieferantennr # 0;
      Art.C.AdressNr      # Set.eigeneAdressnr;
      Art.C.AnschriftNr   # 1;
      Art.C.Zustand       # 0;
      Art.C.Dicke         # Art.Dicke;
      Art.C.Breite        # Art.Breite;
      "Art.C.Länge"       # "Art.Länge";
      Art.C.RID           # Art.InnenDmesser;
      Art.C.RAD           # Art.AussenDmesser;
      Art.C.Lagerplatz    # '';
      Art.C.Charge.Extern # '';
      Art.C.Bezeichnung   # '';
      Art.C.Bestellnummer # '';

      RecBufClear(253);
      Art.J.Datum           # today;
      Art.J.Bemerkung       # aGrund;
      Art.J.Menge           # -vMenge;
      "Art.J.Trägertyp"     # '';
      "Art.J.Trägernummer1" # 0;
      "Art.J.Trägernummer2" # 0;
      "Art.J.Trägernummer3" # 0;

      // Buchen...
      if (Art_Data:Bewegung(0.0, 0.0)=false) then begin
        RekRestore(vBuf250);
        RETURN false;
      end;

      aKosten # aKosten + Rnd( (Art.C.EKDurchschnitt * vMenge / cnvfi(Art.PEH)) ,2);
//debug('entnehme '+art.nummer+' '+art.c.charge.intern);
    end;


    //  ARBEITSGANG ???
    if (Art.SL.Typ=828) then begin
      vPreis    # Art.SL.Kosten.FixW1;
      vPreisPEH # 0;
      if (Art.SL.Kosten.VarW1<>0.0) then begin
        vPreis    # Art.SL.Kosten.VarW1;
        vPreisPEH # Art.SL.Kosten.PEH;
      end;
      if (vPreisPEH=0) then
        aKosten # aKosten + Rnd(vPreis,2)
      else
        aKosten # aKosten + Rnd(vPreis * Art.SL.Menge / cnvfi(vPreisPEH),2);;
    end;


    // RESSOURACE ???
    if (Art.SL.Typ=160) then begin
      vPreis    # Art.SL.Kosten.FixW1;
      vPreisPEH # 0;
      if (Art.SL.Kosten.VarW1<>0.0) then begin
        vPreis    # Art.SL.Kosten.VarW1;
        vPreisPEH # Art.SL.Kosten.PEH;
      end;
      if (vPreisPEH=0) then
        aKosten # aKosten + Rnd(vPreis,2)
      else
        aKosten # aKosten + Rnd(vPreis * Art.SL.Menge / cnvfi(vPreisPEH),2);;
    end;


    Erx # RecLink(256,255,2,_RecNext);
  END;


  RekRestore(vBuf250);
  RETURN true;
end


//========================================================================
//  Produziere
//
//========================================================================
sub Produziere() : logic;
local begin
  Erx     : int;
  vMenge  : float;
  vOK     : logic;
  vKosten : float;
  vBuf250 : int;
  vA      : alpha;
end;
begin

  // nur Produktionsartikel!
  if (Art.Typ<>c_Art_Prd) then RETURN false;

  Erx # RecLink(255,250,22,_recFirst);    // aktive SL holen
  if (Erx>_rLocked) then begin
    Msg(250011,'',0,0,0);
    RETURN false;
  end;

  // Menge abfragen
  if (Dlg_Standard:Menge(Translate('Menge')+' '+Art.MEH, var vMenge, 0.0)=false) then RETURN false;
  if (vMenge=0.0) then RETURN false;


  vA # Translate('man.Prod.');


  TRANSON;

  // Stückliste verbuchen...
  vOk # _VerbucheSL(vMenge, vA+' '+Art.Nummer, var vKosten);
  if (vOK=false) then begin
    TRANSBRK;
    ERROROUTPUT;
    Msg(250012,'',0,0,0);
    RETURN false;
  end;


  // Kosten umrechnen...
  vKosten # Rnd( (vKosten / vMenge) * cnvfi(Art.PEH) ,2);


  // PRD-Artikel zubuchen...
  RecBufClear(252);
  Art.C.Charge.Intern # '';
  Art.C.ArtikelNr     # Art.Nummer;
  Art.C.Lieferantennr # 0;
  Art.C.AdressNr      # Set.eigeneAdressnr;
  Art.C.AnschriftNr   # 1;
  Art.C.Zustand       # 0;
  Art.C.Dicke         # Art.Dicke;
  Art.C.Breite        # Art.Breite;
  "Art.C.Länge"       # "Art.Länge";
  Art.C.RID           # Art.InnenDmesser;
  Art.C.RAD           # Art.AussenDmesser;
  Art.C.Lagerplatz    # '';
  Art.C.Charge.Extern # '';
  Art.C.Bezeichnung   # '';
  Art.C.Bestellnummer # '';

  RecBufClear(253);
  Art.J.Datum           # today;
  Art.J.Bemerkung       # vA;
//  "Art.J.Stückzahl"     # vMenge);
  Art.J.Menge           # vMenge;
  "Art.J.Trägertyp"     # '';
  "Art.J.Trägernummer1" # 0;
  "Art.J.Trägernummer2" # 0;
  "Art.J.Trägernummer3" # 0;

  // Buchen...
  vOK # Art_Data:Bewegung(vKosten, 0.0);
  if (vOK=false) then begin
    TRANSBRK;
    Msg(001000,gTitle,0,0,0);
    RETURN false;
  end;

  TRANSOFF;

  Msg(999998,'',0,0,0);

end;

//========================================================================