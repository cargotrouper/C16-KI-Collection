@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_P_Subs
//                OHNE E_R_G
//  Info
//
//
//  12.01.2009  AI  Erstellung der Prozedur
//  19.01.2010  TM  Druck Lohnformular erweitert: Spulen und Walzen
//  21.02.2014  AH  Formular: LohnQTauftrag
//  09.03.2015  AH  "Merge"
//  14.05.2020  TM  Formular: LohnAblängen
//  13.01.2022  ST  Neu: Print_LohnFahrauftag() : logic
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//  SUB Print_Lohnformular(aBAGNr  : int; aBAGPos : int);
//  SUB Print_LohnFahrauftag() : logic
//  SUB Merge(aBAG : int; aPos : int) : logic;
//
//========================================================================
@I:Def_global
@I:Def_BAG
@I:Def_Rights

declare Print_LohnFahrauftag() : logic

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

    (c_BAG_QTeil) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'LohnQTauftrag',true);
    end;

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
      //Lib_Dokumente:Printform(700,'Lohnfahrauftrag',true);
      Print_LohnFahrauftag();
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

    c_BAG_Spulen, c_BAG_SpaltSpulen, c_BAG_WalzSpulen : begin
      // Speditionn lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnspulauftrag',true);
    end;

    (c_BAG_Walz) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohnwalzauftrag',true);
    end;

    (c_BAG_Divers) : begin
      // Lohnbetrieb lesen um die Sprache herauszubekommen
      RecLink(100,702,7,_RecFirst);
      Lib_Dokumente:Printform(700,'Lohndiversauftrag',true);
    end;


  end; // case

end;



//========================================================================
//  Print_LohnFahrauftag() : logic  ST 2022-01-13 2220/34
//
//  Druck die Lohnfahraufträge für die gelesen Betriebsauftragsposition
//========================================================================
sub Print_LohnFahrauftag() : logic
local begin
  Erx : int;
end;
begin
  if (BAG.P.Aktion<>c_BAG_Fahr) then RETURN true;
  if (Rechte[Rgt_Lfs_Druck_LFA]=false) then
    RETURN false;

  FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
  LOOP Erx # RecLink(440,702,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Lfs_VLDAW_Data:Druck_LFA();
  END;

  RETURN true;
end;


//========================================================================
//  Merge
//
//========================================================================
SUB Merge(
  aBAG  : int;
  aPos  : int;  // ZIEL
  ) : logic;
local begin
  vPos  : int;
  Erx   : int;
end;
begin
  BAG.Nummer # aBAG;
  Erx # RecRead(700,1,0);
  if (Erx<>_rOK) then begin
    Msg(700002,aint(aBAG),0,0,0);
    RETURN false;
  end;

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (Erx<>_rOK) then begin
    Msg(700002,aint(aBAG)+'/'+aint(aPos),0,0,0);
    RETURN false;
  end;

  if ("BAG.Löschmarker"<>'') or ("BAG.P.Löschmarker"<>'') or (BAG.P.Fertig.Dat<>0.0.0) then begin
    Msg(702009,'',0,0,0);
    RETURN false;
  end;

  if (Dlg_standard:Anzahl(Translate('von')+' '+Translate('Position'),var vPos)=false) then RETURN false;

  if (BA1_P_Data:Merge(aBAG, aPos, vPos)=false) then begin
    ErrorOutput;
    RETURN false;
  end;

  Msg(999998,'',0,0,0);

  RETURN true;
end;


//========================================================================