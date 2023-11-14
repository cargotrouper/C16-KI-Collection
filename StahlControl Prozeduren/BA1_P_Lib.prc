@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_P_Lib
//                OHNE E_R_G
//  Info
//
//
//  12.01.2009  AI  Erstellung der Prozedur
//  14.05.2020  TM  Formular: LohnAblängen
//  31.03.2022  AH  ERX
//  18.05.2022  AH  "StatusInAnfrage", "StatusFreiZurProduktion"
//
//  Subprozeduren
//  SUB Print_Lohnformular(aBAGNr  : int; aBAGPos : int);
//  SUB StatusInAnfrage() : logic
//  SUB StatusFreiZurProduktion() : logic
//
//========================================================================
@I:Def_global
@I:Def_BAG

//========================================================================
//  Print_Lohnformular
//
//========================================================================
sub Print_Lohnformular(
  aBAGNr  : int;
  aBAGPos : int);
local begin
  Erx : int;
end;
begin

  BAG.Nummer #  aBAGNr;
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then RETURN;

  BAG.P.Nummer    #  aBAGNr;
  BAG.P.Position  #  aBAGPos;
  Erx # RecRead(702,1,0);
  if (Erx>_rLocked) then RETURN;

 
  
  if (BAG.P.ExternYN = false) then RETURN;
  
  case (Bag.P.Aktion) of

    (c_BAG_Spalt) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnspaltauftrag',true);
    end;

  (c_BAG_Ablaeng) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnablängauftrag',true);
    end;

    (c_BAG_ABCOIL),
    (c_BAG_Tafel) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohntafelauftrag',true);
    end;

    (c_BAG_Fahr) : begin
      // Speditionn lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnfahrauftrag',true);
    end;

    c_BAG_Obf, c_BAG_Gluehen : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnobfauftrag',true);
    end;

    (c_BAG_Kant) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnkantauftrag',true);
    end;

  end; // case

end;


//========================================================================
//  StatusInAnfrage
//========================================================================
sub StatusInAnfrage() : logic
local begin
  Erx : int;
end;
begin
  if (RunAFX('BAG.P.StatusIst',c_BagStatus_Anfrage)<>0) then
    RETURN (AfxRes=_rOK);

  RETURN (BAG.P.Status=c_BagStatus_Anfrage);
end;


//========================================================================
//  StatusFreiZurProduktion
//========================================================================
sub StatusFreiZurProduktion() : logic
begin
  if (RunAFX('BAG.P.StatusIst',c_BagStatus_Offen)<>0) then
    RETURN (AfxRes=_rOK);

  RETURN (BAG.P.Status=c_BagStatus_Offen);
end;


//========================================================================