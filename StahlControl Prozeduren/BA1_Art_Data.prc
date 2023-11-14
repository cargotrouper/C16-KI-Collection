@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Art_Data
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB ArtEinsetzen() : logic;
//    SUB ArtFreigeben() : logic;
//    SUB ArtResUpdate(aStk : int; aMenge : float) : logic;
//
//========================================================================
@I:def_Global
@I:Def_Aktionen

//========================================================================
//  ArtEinsetzen
//
//========================================================================
sub ArtEinsetzen() : logic;
begin
//todo('+res:'+bag.io.artikelnr+' '+aint(bag.io.lageradresse)+'/'+aint(bag.io.lageranschr)+' '+bag.io.charge+' : '+anum(BAG.IO.Plan.In.Menge,2)+'  '+aint(BAG.IO.Plan.In.Stk));
  if (BAG.VorlageYN) then
    RETURN true;
  RETURN Art_Data:Reservierung(BAG.IO.Artikelnr, BAG.IO.LagerAdresse, BAG.IO.LagerAnschr, BAG.IO.Charge, BAG.IO.Art.Zustand, c_Akt_BAInput, BAG.IO.Nummer, BAG.IO.ID, 0, BAG.IO.Plan.In.Menge, BAG.IO.Plan.In.Stk, 0);
  //aArtikel : alpha; aAdresse : int; aAnschrift : word; aCharge : alpha; aTragTyp : alpha; aTragNr1 : int; aTragNr2 : word; aTragNr3 : word; aDifMenge : float; aDifStk : int; aResID : int) : logic
end;


//========================================================================
//  ArtFreigeben
//
//========================================================================
sub ArtFreigeben() : logic;
local begin
  vX    : float;
  vStk  : int;
end;
begin
  if (BAG.VorlageYN) then
    RETURN true;
//todo('p:'+anum(BAG.IO.Plan.In.Menge,0)+BAG.IO.MEH.In+'  i:'+anum(BAG.IO.Ist.Out.Menge,0)+BAG.IO.MEH.Out);
  vX # - (BAG.IO.Plan.In.Menge - BAG.IO.Ist.Out.Menge);
  vStk # - (BAG.IO.Plan.In.Stk - BAG.IO.Ist.Out.Stk);
//todo('-res:'+bag.io.artikelnr+' '+aint(bag.io.lageradresse)+'/'+aint(bag.io.lageranschr)+' '+bag.io.charge+'   M:'+anum(vX,2)+'  Stk:'+aint(vStk));
  RETURN Art_Data:Reservierung(BAG.IO.Artikelnr, BAG.IO.LagerAdresse, BAG.IO.LagerAnschr, BAG.IO.Charge, BAG.IO.Art.Zustand, c_Akt_BAInput, BAG.IO.Nummer, BAG.IO.ID, 0, vX, vStk,0);
end;


//========================================================================
//  ArtResUpdate
//
//========================================================================
sub ArtResUpdate(
  aStk    : int;
  aMenge  : float;
) : logic;
begin
  if (BAG.VorlageYN) then
    RETURN true;
//todo('-+UP:'+bag.io.artikelnr+' '+aint(bag.io.lageradresse)+'/'+aint(bag.io.lageranschr)+' '+bag.io.charge+'   M:'+anum(aMenge,2)+'  Stk:'+aint(aStk));
  RETURN Art_Data:Reservierung(BAG.IO.Artikelnr, BAG.IO.LagerAdresse, BAG.IO.LagerAnschr, BAG.IO.Charge, BAG.IO.ARt.Zustand, c_Akt_BAInput, BAG.IO.Nummer, BAG.IO.ID, 0, aMenge, aStk, 0);
end;

//========================================================================