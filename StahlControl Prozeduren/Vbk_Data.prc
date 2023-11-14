@A+
//===== Business-Control =================================================
//
//  Prozedur    Vbk_Data
//                      OHNE E_R_G
//  Info
//
//
//  01.06.2005  AI  Erstellung der Prozedur
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB Update(aDatei : word) : logic;
//
//========================================================================
@I:Def_Global

//========================================================================
//  Update
//
//========================================================================
sub Update(aDatei : word) : logic;
local begin
  Erx : int;
end;
begin

  // Eingangsrechung verbuchen?
  if (aDatei=560) then begin

    Erx # RecLink(550,560,2,_recFirst);   // Verbindlichkeit holen
    if (Erx<=_rLocked) then begin
      if (ERe.InOrdnung=n) then begin
        RekDelete(550,0,'MAN');
      end;
      RETURN true;
    end;

    if (ERe.InOrdnung=n) then RETURN true;


    RecBufClear(550);
    Vbk.Nummer          # ERe.Nummer;
    Vbk.Rechnungsdatum  # ERe.Rechnungsdatum;
    Vbk.Rechnungstyp    # ERe.Rechnungstyp;
    Vbk.Lieferant       # ERe.Lieferant;
    Vbk.LieferStichwort # ERe.LieferStichwort;
    Vbk.Adr.Steuerschl  # ERe.Adr.Steuerschl;
    "Vbk.Währung"       # "ERe.Währung";
    "Vbk.Währungskurs"  # "ERe.Währungskurs";
    "Vbk.Stückzahl"     # "ERe.Stückzahl";
    Vbk.Gewicht         # ERe.Gewicht;
    Vbk.Einkaufsnr      # ERe.Einkaufsnr;
    Vbk.Bemerkung       # ERe.Bemerkung;
    Vbk.Netto           # ERe.Netto;
    Vbk.NettoW1         # ERe.NettoW1;
    Vbk.Steuer          # ERe.Steuer;
    Vbk.SteuerW1        # ERe.SteuerW1;
    Vbk.Brutto          # ERe.Brutto;
    Vbk.BruttoW1        # ERe.BruttoW1;
    Vbk.Anlage.Datum    # today;
    Vbk.Anlage.Zeit     # Now;
    Vbk.Anlage.User     # gUserName;
    Erx # RekInsert(550,0,'AUTO');
    if (erx<>_rOk) then RETURN false;

  end;

  RETURN true;
end;

//========================================================================