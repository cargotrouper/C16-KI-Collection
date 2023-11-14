@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Ele_Auf
//                  OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  23.10.2012  AI  Erstellung der Prozedur
//  22.01.2013  ST  Fehlerkorrektur Argumentreihenfolge Seitenköpfe
//  10.04.2013  ST  Inhalte FS_C und FC_E werden jetzt dynamisch
//                  dargstellt -> wichtig für Seite > 2
//  15.08.2014  AH  Umbauten für Reverse-Charge
//
//  Subprozeduren
//  SUB elABErsteSeite(var aHdl : int; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int);
//  SUB elABFolgeSeite(var aHdl : int; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int);
//  SUB elSumme(var aHdl : int; aGesamtNetto : float; aMwStSatz1 : float; aMwStWert1 : float; aMwStSatz2 : float; aMwStWert2 : float; aGesamtBrutto : float);
//  SUB elABEnde(var aHdl : int; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int);
//  SUB elABUeberschrift(var aHdl  : int);
//  SUB elABPosMat1(var aHdl : int);
//  SUB elABPosMat2(var aHdl : int);
//  SUB elRechAktion(var aHdl : int; aCount : int);
//  SUB elFMAkt1(var aHdl : int; aCount : int);
//  SUB elFMAkt2(var aHdl : int; aCount : int);
//  SUB elFMAktFuss(var aHdl : int; aCount : int);
//  SUB elABAufpreisUS(var aHdl : int; aKopf : logic);
//  SUB elABAufpreis(var aHdl : int; aGesamtpreis : float);
//  SUB elABPosVpg(var aHdl : int);
//  SUB elABPosMech(var aHdl : int);
//  SUB elABPosAnalyse(var aHdl : int);
//  SUB elABPosArt1(var aHdl : int);
//  SUB elABPosArt2(var aHdl : int);
//  SUB elGelangenEnde(var aHdl    : int;  aBuf100Re   : int;  aBuf101We   : int;);
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form

define begin
//  ReplaceAll(a,b,c) : Str_ReplaceAll(a,b,c)
end;

//=======================================================================
//  elABErsteSeite
//=======================================================================
sub elABErsteSeite(
  var aHdl    : int;
  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int;
  );
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  vFont   : font;
  vI,vJ   : int;
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___ERSTESEITE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('ES_Absender')) then begin
      vFont # Form_StyleFont;
      vFont:Attributes # _WinFontAttrU;
      Form_styleFont # vFont;
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true, aBuf100Re, aBuf101WE, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerB')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerB', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('ES_A')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_B')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('ES_InhaltC');
      SetA(vInhalt);
      CRLF;
    end;
    vJ # pls_PosY;
    if (vI>vJ) then Pls_PosY # vI
    else pls_posY # vJ;

    vOK # y;
    if (Usestyle('ES_D')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_F')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', isVisible('ES_InhaltF')=false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      if (UseStyle('ES_InhaltF')) then
        SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);

    if (UseStyle('ES_G')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('ES_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_H')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('ES_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('ES_div_B')) then SetLine(1);

    if (UseStyle('ES_I')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('ES_InhaltI');
      SetA(vInhalt);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elABFolgeSeite
//=======================================================================
sub elABFolgeSeite(
  var aHdl    : int;
  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  vFont   : Font;
  vI,vJ   : int;
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___FOLGESEITE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('FS_Absender')) then begin
      vFont # Form_StyleFont;
      vFont:Attributes # _WinFontAttrU;
      Form_styleFont # vFont;
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_Absender', true, aBuf100Re, aBuf101WE, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerB')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerB', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('FS_A')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_B')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_C')) then begin;
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltC');
      DynA('ccc');
      CRLF;
    end;
    vJ # pls_PosY;
    if (vI>vJ) then Pls_PosY # vI
    else pls_posY # vJ;

    vOK # y;
    if (Usestyle('FS_D')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      DynA('eee');
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_F')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltF');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);

    if (UseStyle('FS_G')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_G', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('FS_H')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_H', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_B')) then SetLine(1);

    if (UseStyle('FS_I')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_I', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('FS_InhaltI');
      SetA(vInhalt);
      CRLF;
    end;

  end;  // Design


  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);

  if (isVisible('FS_C')) then begin
    if (Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2)>=0) then
      FillDynA('ccc',vInhalt);
  end;

  if (isVisible('FS_E')) then begin
    if (Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2)>=0) then
      FillDynA('eee',vLabels);
  end;


  EndPrint;
end;


//=======================================================================
//  elSumme
//=======================================================================
sub elSumme(
  var aHdl      : int;
  aGesamtNetto  : float;
  aMwStSatz1    : float;
  aMwStWert1    : float;
  aMwStSatz2    : float;
  aMwStWert2    : float;
  aGesamtBrutto : float;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  v450    : int;
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin

    if (IsVisible('___SUMME')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Summe_div_A')) then SetLine(0);
    if (UseStyle('Summe_div_B')) then SetLine(1);

    // Summen drucken
    v450 # RekSave(450);
    Erl.Netto           # aGesamtNetto;
    Erl.Brutto          # aGesamtBrutto;

    vOk # n;
    if (UseStyle('Summe_A')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_A', true)<0) then
        VarA('Summe_A')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_B')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_B', true)<0) then
        VarA('Summe_B')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_C')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_C', true)<0) then
        VarA('Summe_C')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_D')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_D', true)<0) then
        VarA('Summe_D')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_E')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_E', true)<0) then
        VarA('Summe_E')
      else
        SetA(vLabels);
    end;
    if (vOK) then CRLF;
    vOK # n;


    if (aMwStSatz1>0.0) then begin
      Erl.Steuer  # aMwStWert1;
      Sts.Prozent # aMwStSatz1;
      if (UseStyle('Summe_MwStSatz')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwStSatz', true)<0) then
          VarA('Summe_MwStSatz')
        else
          SetA(vLabels);
  //      SetA(ANum(aMwstSatz1,1) + '% MwSt. '+ "Wae.Kürzel");
        vOK # y;
      end;
      if (UseStyle('Summe_MwSt')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwSt', true)<0) then
          VarA('Summe_MwSt')
        else
          SetA(vLabels);
  //      SetA(anum(aMwStWert1,2));
        vOK # y;
      end;
      if (vOK) then CRLF;
      vOK # n;
    end;

    if (aMwStSatz2>0.0) then begin
      Erl.Steuer  # aMwStWert2;
      Sts.Prozent # aMwStSatz2;

      if (UseStyle('Summe_MwStSatz')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwStSatz', true)<0) then
          VarA('SummeMwStSatz')
        else
          SetA(vLabels);
//        SetA(ANum(aMwstSatz2,1) + '% MwSt. '+ "Wae.Kürzel");
        vOK # y;
      end;
      if (UseStyle('Summe_MwSt')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwSt', true)<0) then
          VarA('Summe_MwSt')
        else
          SetA(vLabels);
//        SetA(anum(aMwStWert2,2));
        vOK # y;
      end;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('Summe_div_C')) then SetLine(2);
    if (UseStyle('Summe_div_D')) then SetLine(3);

    if (UseStyle('Summe_F')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_F', true)<0) then
        VarA('Summe_F')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_G')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_G', true)<0) then
        VarA('Summe_G')
      else
        SetA(vLabels);
    end;
    if (vOK) then CRLF;
    vOK # n;

    RekRestore(v450);

    if (UseStyle('Summe_div_E')) then SetLine(4);
    if (UseStyle('Summe_div_F')) then SetLine(5);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  EndPrint;

end;


//=======================================================================
//  elSummeExt
//=======================================================================
sub elSummeExt(
  var aHdl      : int;
  aGesamtNetto  : float;
  aMwStSatz1    : float;
  aMwStNetto1   : float;
  aMwStWert1    : float;
  aMwStSatz2    : float;
  aMwStNetto2   : float;
  aMwStWert2    : float;
  aGesamtBrutto : float;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  v450    : int;
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin

    if (IsVisible('___SUMME')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Summe_div_A')) then SetLine(0);
    if (UseStyle('Summe_div_B')) then SetLine(1);

    // Summen drucken
    v450 # RekSave(450);
    Erl.Netto           # aGesamtNetto;
    Erl.Brutto          # aGesamtBrutto;

    vOk # n;
    if (UseStyle('Summe_A')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_A', true)<0) then
        VarA('Summe_A')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_B')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_B', true)<0) then
        VarA('Summe_B')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_C')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_C', true)<0) then
        VarA('Summe_C')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_D')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_D', true)<0) then
        VarA('Summe_D')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_E')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_E', true)<0) then
        VarA('Summe_E')
      else
        SetA(vLabels);
    end;
    if (vOK) then CRLF;
    vOK # n;


    if (aMwStNetto1>0.0) then begin
      Erl.Steuer  # aMwStWert1;
      Erl.Netto   # aMwStNetto1;
      Sts.Prozent # aMwStSatz1;

      if (UseStyle('Summe_MwStTitel')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwStTitel', true)<0) then
          VarA('Summe_MwStTitel')
        else
          SetA(vLabels);
          vOK # y;
      end;
      if (UseStyle('Summe_MwStSatz')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwStSatz', true)<0) then
          VarA('Summe_MwStSatz')
        else
          SetA(vLabels);
  //      SetA(ANum(aMwstSatz1,1) + '% MwSt. '+ "Wae.Kürzel");
        vOK # y;
      end;
      if (UseStyle('Summe_MwSt')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwSt', true)<0) then
          VarA('Summe_MwSt')
        else
          SetA(vLabels);
  //      SetA(anum(aMwStWert1,2));
        vOK # y;
      end;
      if (vOK) then CRLF;
      vOK # n;
    end;

    if (aMwStNetto2>0.0) then begin
      Erl.Steuer  # aMwStWert2;
      Erl.Netto   # aMwStNetto2;
      Sts.Prozent # aMwStSatz2;

      if (UseStyle('Summe_MwStTitel')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwStTitel', true)<0) then
          VarA('Summe_MwStTitel')
        else
          SetA(vLabels);
          vOK # y;
      end;
      if (UseStyle('Summe_MwStSatz')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwStSatz', true)<0) then
          VarA('SummeMwStSatz')
        else
          SetA(vLabels);
//        SetA(ANum(aMwstSatz2,1) + '% MwSt. '+ "Wae.Kürzel");
        vOK # y;
      end;
      if (UseStyle('Summe_MwSt')) then begin
        if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_MwSt', true)<0) then
          VarA('Summe_MwSt')
        else
          SetA(vLabels);
//        SetA(anum(aMwStWert2,2));
        vOK # y;
      end;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('Summe_div_C')) then SetLine(2);
    if (UseStyle('Summe_div_D')) then SetLine(3);

    if (UseStyle('Summe_F')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_F', true)<0) then
        VarA('Summe_F')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_G')) then begin
      vOK # y;
      if (Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_G', true)<0) then
        VarA('Summe_G')
      else
        SetA(vLabels);
    end;
    if (vOK) then CRLF;
    vOK # n;

    RekRestore(v450);

    if (UseStyle('Summe_div_E')) then SetLine(4);
    if (UseStyle('Summe_div_F')) then SetLine(5);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  EndPrint;

end;


//=======================================================================
//  elABEnde
//=======================================================================
sub elABEnde(
  var aHdl    : int;
  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___ENDE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Ende_div_A')) then SetLine(0);
    if (UseStyle('Ende_A')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', false, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      UseStyle('Ende_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_B')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_C')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elABUeberschrift
//=======================================================================
sub elABUeberschrift(
  var aHdl  : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin
  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___UEBERSCHRIFT')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('US_div_A')) then SetLine(0);

    if (UseStyle('US_A')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_A', true, 0,0,0,0);
      SetA(vLabels);
      // <<< MUSTER >>>
      // SetVLinieStartX(1) # Form_StyleX;
    end;
    if (UseStyle('US_B')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_B', true, 0,0,0,0);
      SetA(vLabels);
    end;
    if (UseStyle('US_C')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_C', true, 0,0,0,0);
      SetA(vLabels);
    end;
    if (UseStyle('US_D')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_D', true, 0,0,0,0);
      SetA(vLabels);
    end;
    if (UseStyle('US_E')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_E', true, 0,0,0,0);
      SetA(vLabels);
    end;
    if (UseStyle('US_F')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_F', true, 0,0,0,0);
      SetA(vLabels);
    end;
    if (UseStyle('US_G')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'US_G', true, 0,0,0,0);
      SetA(vLabels);
    end;

    if (UseStyle('US_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY);
    CRLF;

    if (UseStyle('US_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  // <<< MUSTER >>>
  //SetVLinieStartY(1);
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elABPosMat1
//=======================================================================
sub elABPosMat1(
  var aHdl  : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin

    if (IsVisible('___MATERIALPOS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosMat_1A')) then
      DynA('aaa');
    if (UseStyle('PosMat_1B')) then
      DynA('bbb');
    if (UseStyle('PosMat_1C')) then
      DynA('ccc');
    if (UseStyle('PosMat_1D')) then
      DynA('ddd');
    if (UseStyle('PosMat_1E')) then
      DynA('eee');
    if (UseStyle('PosMat_1F')) then
      DynA('fff');
    if (UseStyle('PosMat_1G')) then
      DynA('ggg');
    if (UseStyle('PosMat_1H')) then
      DynA('hhh');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('PosMat_1A')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('PosMat_1B')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosMat_1C')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosMat_1D')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosMat_1E')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosMat_1F')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosMat_1G')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosMat_1H')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1H', true);
    FillDynA('hhh',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elABPosMat2
//=======================================================================
sub elABPosMat2(
  var aHdl  : int;
);
local begin
  vFont       : Font;
  vI,vJ       : int;
  vA          : alpha(4096);
  vSplit      : int;
  vLabels     : alpha(4096);
  vInhalt     : alpha(4096);
  vZusatz     : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___MATERIALPOS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosMat_2A')) then
      DynA('aaa');
    if (UseStyle('PosMat_2B')) then
      DynA('bbb');
    if (UseStyle('PosMat_2C')) then
      DynA('ccc');
    if (UseStyle('PosMat_2D')) then
      DynA('ddd');
    if (UseStyle('PosMat_2E')) then
      DynA('eee');
//    if (UseStyle('PosMat_2F')) then
//      DynA('fff');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  vJ # Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_2A', false);
  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('PosMat_2D')) then vSplit # (vJ / 2) + (vJ % 2);

//  FOR vI # 1 loop inc(vI) while (vI<=(vJ - vSplit)) do begin
  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    FillDynA('ccc',Str_Token(vZusatz,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ddd',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('eee',Str_Token(vInhalt,Strchar(10), vI + vSplit));
//      FillDynA('fff',Str_Token(vZusatz,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elRechAktion
//=======================================================================
sub elRechAktion(
  var aHdl  : int;
  aCount    : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___AKTION')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Akt_A')) then
      DynA('aaa');
    if (UseStyle('Akt_B')) then
      DynA('bbb');
    if (UseStyle('Akt_C')) then
      DynA('ccc');
    if (UseStyle('Akt_D')) then
      DynA('ddd');
    if (UseStyle('Akt_E')) then
      DynA('eee');
    if (UseStyle('Akt_F')) then
      DynA('fff');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('Akt_A')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_A', true, aCount);
    if (aCount=1) then
      FillDynA('aaa',vLabels)
    else
      FillDynA('aaa','');
  end;
  if (isVisible('Akt_B')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_B', true, aCount);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Akt_C')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_C', true, aCount);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Akt_D')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_D', true, aCount);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Akt_E')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_E', true, aCount);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Akt_F')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_F', true, aCount);
    FillDynA('fff',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elFMAkt1
//=======================================================================
sub elFMAkt1(
  var aHdl  : int;
  aCount    : int);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___AKTION')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Akt_1A')) then
      DynA('aaa');
    if (UseStyle('Akt_1B')) then
      DynA('bbb');
    if (UseStyle('Akt_1C')) then
      DynA('ccc');
    if (UseStyle('Akt_1D')) then
      DynA('ddd');
    if (UseStyle('Akt_1E')) then
      DynA('eee');
    if (UseStyle('Akt_1F')) then
      DynA('fff');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('Akt_1A')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1A', true, aCount);
    FillDynA('aaa',vLabels)
  end;
  if (isVisible('Akt_1B')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1B', true, aCount);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Akt_1C')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1C', true, aCount);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Akt_1D')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1D', true, aCount);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Akt_1E')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1E', true, aCount);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Akt_1F')) then begin
    Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1F', true, aCount);
    FillDynA('fff',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elFMAkt2
//=======================================================================
sub elFMAkt2(
  var aHdl  : int;
  aCount    : int;
);
local begin
  vFont       : Font;
  vI,vJ       : int;
  vA          : alpha(4096);
  vSplit      : int;
  vLabels     : alpha(4096);
  vInhalt     : alpha(4096);
  vZusatz     : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___AKTION')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Akt_2A')) then
      DynA('aaa');
    if (UseStyle('Akt_2B')) then
      DynA('bbb');
    if (UseStyle('Akt_2C')) then
      DynA('ccc');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  vJ # Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_2A', false, aCount);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    FillDynA('ccc',Str_Token(vZusatz,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ddd',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('eee',Str_Token(vInhalt,Strchar(10), vI + vSplit));
//      FillDynA('fff',Str_Token(vZusatz,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elFMAktFuss
//=======================================================================
sub elFMAktFuss(
  var aHdl  : int;
  aCount    : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin
  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___AKTIONFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('AktFuss_div_A')) then SetLine(0);

    if (UseStyle('AktFuss_A')) then begin
      Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_A', true, aCount);
      SetA(vLabels);
    end;
    if (UseStyle('AktFuss_B')) then begin
      Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_B', true, aCount);
      SetA(vLabels);
    end;
    if (UseStyle('AktFuss_C')) then begin
      Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_C', true, aCount);
      SetA(vLabels);
    end;
    if (UseStyle('AktFuss_D')) then begin
      Form_Parse_Auf:Parse404Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_D', true, aCount);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elABAufPreisUS
//=======================================================================
sub elABAufpreisUS(
  var aHdl  : int;
  aKopf     : logic;
);
local begin
  vA        : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___AUFPREIS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    CRLF;
    if (UseStyle('AufpreisUS_div_A')) then SetLine(0);
    if (UseStyle('AufpreisUS')) then begin
      DynA('aaa');
      CRLF;
    end
    if (UseStyle('AufpreisUS_div_B')) then SetLine(1);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  if (aKopf) then
    vA # Str_Token(GetCaption('AufpreisUS'),Strchar(10), 2)
  else
    vA # Str_Token(GetCaption('AufpreisUS'),Strchar(10), 1);
  if (vA='') then RETURN;

  StartPrint(aHdl);
  if (isVisible('AufpreisUS')) then
    FillDynA('aaa',vA);
  EndPrint;
end;


//=======================================================================
//  elABAufpreis
//=======================================================================
sub elABAufpreis(
  var aHdl      : int;
  aGesamtpreis  : float;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin
  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___AUFPREIS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Aufpreis_A')) then
      DynA('aaa');
    if (UseStyle('Aufpreis_B')) then
      DynA('bbb');
    if (UseStyle('Aufpreis_C')) then
      DynA('ccc');
    if (UseStyle('Aufpreis_D')) then
      DynA('ddd');
    if (UseStyle('Aufpreis_E')) then
      DynA('eee');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (IsVisible('Aufpreis_A')) then begin
    Form_Parse_Auf:Parse403Multi(var vLabels, var vInhalt, var vZusatz, 'Aufpreis_A', true, aGesamtpreis);
    FillDynA('aaa',vLabels);
  end;
  if (IsVisible('Aufpreis_B')) then begin
    Form_Parse_Auf:Parse403Multi(var vLabels, var vInhalt, var vZusatz, 'Aufpreis_B', true, aGesamtpreis);
    FillDynA('bbb',vLabels);
  end;
  if (IsVisible('Aufpreis_C')) then begin
    Form_Parse_Auf:Parse403Multi(var vLabels, var vInhalt, var vZusatz, 'Aufpreis_C', true, aGesamtpreis);
    FillDynA('ccc',vLabels);
  end;
  if (IsVisible('Aufpreis_D')) then begin
    Form_Parse_Auf:Parse403Multi(var vLabels, var vInhalt, var vZusatz, 'Aufpreis_D', true, aGesamtpreis);
    FillDynA('ddd',vLabels);
  end;
  if (IsVisible('Aufpreis_E')) then begin
    Form_Parse_Auf:Parse403Multi(var vLabels, var vInhalt, var vZusatz, 'Aufpreis_E', true, aGesamtpreis);
    FillDynA('eee',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elABPosVPG
//=======================================================================
sub elABPosVpg(
  var aHdl  : int;
);
local begin
  vI, vJ    : int;
  vOK       : logic;
  vLabels   : alpha(4096);
  vInhalt   : alpha(4096);
  vZusatz   : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___VERPACKUNG')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosVpg_Titel')) then begin
      DynA('Titel');
      vOK # y;
    end;
    if (UseStyle('PosVpg_A')) then begin
      DynA('aaa');
      vOK # y;
      if (UseStyle('PosVpg_InhaltA')) then
        DynA('bbb');
    end;
    if (vOK) then CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  if (isVisible('PosVpg_A')) then begin
    vJ # Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosVpg_A', false);
    FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
      StartPrint(aHdl);

      // Titel?
      if (isVisible('PosVpg_Titel')) then begin
        if (vI=1) then
          FillDynA('Titel',GetCaption('PosVpg_Titel'))
        else
          FillDynA('Titel','');
      end;

      FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
      FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
      EndPrint;
    END;
  end;

end;


//=======================================================================
//  elABPosMech
//=======================================================================
sub elABPosMech(
  var aHdl  : int;
);
local begin
  vI, vJ    : int;
  vOK       : logic;
  vLabels   : alpha(4096);
  vInhalt   : alpha(4096);
  vZusatz   : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___MECHANIK')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosMech_Titel')) then begin
      DynA('Titel');
      vOK # y;
    end;
    if (UseStyle('PosMech_A')) then begin
      DynA('aaa');
      vOK # y;
      if (UseStyle('PosMech_InhaltA')) then
        DynA('bbb');
    end;
    if (vOK) then CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  if (isVisible('PosMech_A')) then begin
    vJ # Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosMech_A', false);
    if (vJ=0) then RETURN;
    FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
      StartPrint(aHdl);
      // Titel?
      if (isVisible('PosMech_Titel')) then begin
        if (vI=1) then
          FillDynA('Titel',GetCaption('PosMech_Titel'))
        else
          FillDynA('Titel','');
      end;
      FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
      FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
      EndPrint;
    END;
  end;

end;


//=======================================================================
//  elABPosAnalyse
//=======================================================================
sub elABPosAnalyse(
  var aHdl  : int;
);
local begin
  vI,vJ           : int;
  vMaxCol         : int;
  vSplit          : int;
  vA1,vA2,vA3,vA4 : alphA(4096);
  vLabels         : alpha(4096);
  vInhalt         : alpha(4096);
  vZusatz         : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___ANALYSE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosAnalyse_Titel')) then
      DynA('Titel');
    if (UseStyle('PosAnalyse_A')) then begin
      DynA('aaa');
      UseStyle('PosAnalyse_InhaltA');
      DynA('aaa2');
    end;
    if (UseStyle('PosAnalyse_B')) then begin
      DynA('bbb');
      UseStyle('PosAnalyse_InhaltB');
      DynA('bbb2');
    end;
    if (UseStyle('PosAnalyse_C')) then begin
      DynA('ccc');
      UseStyle('PosAnalyse_InhaltC');
      DynA('ccc2');
    end;
    if (UseStyle('PosAnalyse_D')) then begin
      DynA('ddd');
      UseStyle('PosAnalyse_InhaltD');
      DynA('ddd2');
    end;
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  vJ # Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosAnalyse_A', false);
  if (vJ=0) then RETURN;

  vMaxCol # 1;
  if (UseStyle('PosAnalyse_B')) then inc(vMaxCol);
  if (UseStyle('PosAnalyse_C')) then inc(vMaxCol);
  if (UseStyle('PosAnalyse_D')) then inc(vMaxCol);

  vSplit # (vJ / vMaxCol);
  if (vJ % vMaxCol<>0) then vSplit # vSplit + 1;

  FOR vI # 0 loop inc(vI) while (vI<vSplit) do begin
    StartPrint(aHdl);

    // Titel?
    if (isVisible('PosMech_Titel')) then begin
      if (vI=0) then
        FillDynA('Titel',GetCaption('PosAnalyse_Titel'))
      else
        FillDynA('Titel','')
    end;

    FillDynA('aaa',Str_Token(vLabels,Strchar(10), (vI*vMaxCol) + 1));
    FillDynA('aaa2',Str_Token(vInhalt,Strchar(10), (vI*vMaxCol) + 1));
    if (vMaxCol>1) then begin
      FillDynA('bbb',Str_Token(vLabels,Strchar(10), (vI*vMaxCol) + 2));
      FillDynA('bbb2',Str_Token(vInhalt,Strchar(10), (vI*vMaxCol) + 2));
    end;
    if (vMaxCol>2) then begin
      FillDynA('ccc',Str_Token(vLabels,Strchar(10), (vI*vMaxCol) + 3));
      FillDynA('ccc2',Str_Token(vInhalt,Strchar(10), (vI*vMaxCol) + 3));
    end;
    if (vMaxCol>3) then begin
      FillDynA('ddd',Str_Token(vLabels,Strchar(10), (vI*vMaxCol) + 4));
      FillDynA('ddd2',Str_Token(vInhalt,Strchar(10), (vI*vMaxCol) + 4));
    end;

    EndPrint;
  END;

end;


//=======================================================================
//  elABPosArt1
//=======================================================================
sub elABPosArt1(
  var aHdl  : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___ARTIKELPOS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosArt_1A')) then
      DynA('aaa');
    if (UseStyle('PosArt_1B')) then
      DynA('bbb');
    if (UseStyle('PosArt_1C')) then
      DynA('ccc');
    if (UseStyle('PosArt_1D')) then
      DynA('ddd');
    if (UseStyle('PosArt_1E')) then
      DynA('eee');
    if (UseStyle('PosArt_1F')) then
      DynA('fff');
    if (UseStyle('PosArt_1G')) then
      DynA('ggg');
    if (UseStyle('PosArt_1H')) then
      DynA('hhh');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('PosArt_1A')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('PosArt_1B')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosArt_1C')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosArt_1D')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosArt_1E')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosArt_1F')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosArt_1G')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosArt_1H')) then begin
    Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1H', true);
    FillDynA('hhh',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elABPosArt2
//=======================================================================
sub elABPosArt2(
  var aHdl  : int;
);
local begin
  vFont       : Font;
  vI,vJ       : int;
  vA          : alpha(4096);
  vSplit      : int;
  vLabels     : alpha(4096);
  vInhalt     : alpha(4096);
  vZusatz     : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___ARTIKELPOS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('PosArt_2A')) then
      DynA('aaa');
    if (UseStyle('PosArt_2B')) then
      DynA('bbb');
    if (UseStyle('PosArt_2C')) then
      DynA('ccc');
    if (UseStyle('PosArt_2D')) then
      DynA('ddd');
    if (UseStyle('PosArt_2E')) then
      DynA('eee');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  vJ # Form_Parse_Auf:Parse401Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_2A', false);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('PosArt_2D')) then vSplit # (vJ / 2) + (vJ % 2);

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    FillDynA('ccc',Str_Token(vZusatz,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ddd',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('eee',Str_Token(vInhalt,Strchar(10), vI + vSplit));
//      FillDynA('fff',Str_Token(vZusatz,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elGelangenEnde
//=======================================================================
sub elGelangenEnde(
  var aHdl    : int;
  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___ENDE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Ende_div_Aktion')) then SetLine(0);

//----
    if (UseStyle('Ende_A')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_div_A')) then SetLine(1);
    if (Usestyle('Ende_A_Desc')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A_Desc', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
//----
    if (UseStyle('Ende_B')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_div_B')) then SetLine(2);
    if (Usestyle('Ende_B_Desc')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B_Desc', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
//----
    if (UseStyle('Ende_C')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_div_C')) then SetLine(3);
    if (Usestyle('Ende_C_Desc')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C_Desc', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;
//----
    if (UseStyle('Ende_D')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_D', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_div_D')) then SetLine(4);
    if (Usestyle('Ende_D_Desc')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_D_Desc', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;



// ------------
    if (UseStyle('Ende_div_E')) then SetLine(5);
    if (Usestyle('Ende_E_Desc')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_E_Desc', true, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
      SetA(vLabels);
      CRLF;
    end;

// ------------
    if (UseStyle('Ende_F')) then begin
      Form_Parse_Auf:Parse400Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_F', true, 0, 0, 0, 0);
      SetA(vLabels);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//=======================================================================