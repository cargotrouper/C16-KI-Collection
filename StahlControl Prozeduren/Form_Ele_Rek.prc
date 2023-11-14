@A+
//===== Business-Control =================================================
//
//  Prozedur    Foem_Ale_Auf
//                      OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  23.10.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB elErsteSeite(var aHdl : int);
//  SUB elFolgeSeite(var aHdl : int);
//  SUB elEnde(var aHdl : int);
//  SUB elUeberschrift(var aHdl  : int);
//  SUB elPosTextUS(var aHdl  : int);
//  SUB elPosMat1(var aHdl : int);
//  SUB elPosMat2(var aHdl : int);
//  SUB elPosArt1(var aHdl : int);
//  SUB elPosArt2(var aHdl : int);
//  SUB elAktionUS(var aHdl  : int);
//  SUB elAktion1(var aHdl  : int);
//  SUB elAktion2(var aHdl  : int);
//  SUB elAktionFuss(var aHdl  : int);
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
//  elErsteSeite
//=======================================================================
sub elErsteSeite(
  var aHdl    : int);
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
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerB')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerB', true);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('ES_A')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_B')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false);
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
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_F')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', isVisible('ES_InhaltF')=false);
      SetA(vLabels);
      if (UseStyle('ES_InhaltF')) then
        SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);

    if (UseStyle('ES_G')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', false);
      SetA(vLabels);
      UseStyle('ES_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_H')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', false);
      SetA(vLabels);
      UseStyle('ES_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('ES_div_B')) then SetLine(1);

    if (UseStyle('ES_I')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', false)
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
//  elFolgeSeite
//=======================================================================
sub elFolgeSeite(
  var aHdl    : int);
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
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_Absender', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerB')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerB', true);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('FS_A')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_B')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B', false);
      SetA(vLabels);
      UseStyle('FS_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_C')) then begin;
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false);
      SetA(vLabels);
      UseStyle('FS_InhaltC');
      SetA(vInhalt);
      CRLF;
    end;
    vJ # pls_PosY;
    if (vI>vJ) then Pls_PosY # vI
    else pls_posY # vJ;

    vOK # y;
    if (Usestyle('FS_D')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_F')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', false);
      SetA(vLabels);
      UseStyle('FS_InhaltF');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);

    if (UseStyle('FS_G')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_G', false);
      SetA(vLabels);
      UseStyle('FS_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('FS_H')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_H', false);
      SetA(vLabels);
      UseStyle('FS_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_B')) then SetLine(1);

    if (UseStyle('FS_I')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'FS_I', false);
      SetA(vLabels);
      UseStyle('FS_InhaltI');
      SetA(vInhalt);
      CRLF;
    end;

  end;  // Design


  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elEnde
//=======================================================================
sub elEnde(
  var aHdl    : int);
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
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', false);
      SetA(vLabels);
      UseStyle('Ende_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_B')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_C')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true);
      SetA(vLabels);
      CRLF;
    end;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elUeberschrift
//=======================================================================
sub elUeberschrift(
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
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_A', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_B')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_C')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_D')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_E')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_F')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_G')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'US_G', true);
      SetA(vLabels);
    end;

    if (UseStyle('US_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY);
    CRLF;

    if (UseStyle('US_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elPosTextUS
//=======================================================================
sub elPosTextUS(
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

    if (IsVisible('___POSTEXT')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('PosText')) then begin
      Form_Parse_Rek:Parse300Multi(var vLabels, var vInhalt, var vZusatz, 'PosText', true);
      SetA(vLabels);
    end;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elPosMat1
//=======================================================================
sub elPosMat1(
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
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('PosMat_1B')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosMat_1C')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosMat_1D')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosMat_1E')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosMat_1F')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosMat_1G')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosMat_1H')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1H', true);
    FillDynA('hhh',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elPosMat2
//=======================================================================
sub elPosMat2(
  var aHdl  : int;
);
local begin
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


  vJ # Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_2A', false);
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
//  elPosArt1
//=======================================================================
sub elPosArt1(
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
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('PosArt_1B')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosArt_1C')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosArt_1D')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosArt_1E')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosArt_1F')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosArt_1G')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosArt_1H')) then begin
    Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1H', true);
    FillDynA('hhh',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elPosArt2
//=======================================================================
sub elPosArt2(
  var aHdl  : int;
);
local begin
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


  vJ # Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_2A', false);

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
//  elAktionUS
//=======================================================================
sub elAktionUS(
  var aHdl  : int;
);
local begin
  vLabels     : alpha(4096);
  vInhalt     : alpha(4096);
  vZusatz     : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___AKTIONUS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    CRLF;
    if (UseStyle('AktUS_div_A')) then SetLine(0);
    if (UseStyle('AktUS')) then begin
      DynA('aaa');
      CRLF;
    end
    if (UseStyle('AktUS_div_B')) then SetLine(1);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  if (isVisible('AktUS')) then begin
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'AktUS', true, 0);
    FillDynA('aaa',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elAktion1
//=======================================================================
sub elAktion1(
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
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1A', true, aCount);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('Akt_1B')) then begin
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1B', true, aCount);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Akt_1C')) then begin
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1C', true, aCount);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Akt_1D')) then begin
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1D', true, aCount);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Akt_1E')) then begin
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1E', true, aCount);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Akt_1F')) then begin
    Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_1F', true, aCount);
    FillDynA('fff',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elAktion2
//=======================================================================
sub elAktion2(
  var aHdl  : int;
  aCount    : int;
);
local begin
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

  if (IsVisible('Akt_2A')=false) then RETURN;

  vJ # Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'Akt_2A', false, aCount);

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
//  elAktionFuss
//=======================================================================
sub elAktionFuss(
  var aHdl  : int;
  aCount    : int);
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
      Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_A', true, aCount);
      SetA(vLabels);
    end;
    if (UseStyle('AktFuss_B')) then begin
      Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_B', true, aCount);
      SetA(vLabels);
    end;
    if (UseStyle('AktFuss_C')) then begin
      Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_C', true, aCount);
      SetA(vLabels);
    end;
    if (UseStyle('AktFuss_D')) then begin
      Form_Parse_Rek:Parse302Multi(var vLabels, var vInhalt, var vZusatz, 'AktFuss_D', true, aCount);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elSumme
//=======================================================================
sub elSumme(
  var aHdl  : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
end;
begin
  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___SUMME')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Summe_div_A')) then SetLine(0);
    if (UseStyle('Summe_div_B')) then SetLine(1);
    if (UseStyle('Summe_1A')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_1A', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_1B')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_1B', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_1C')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_1C', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_1D')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_1D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_1E')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_1E', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;
    if (UseStyle('Summe_2A')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_2A', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_2B')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_2B', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_2C')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_2C', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_2D')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_2D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('Summe_2E')) then begin
      Form_Parse_Rek:Parse301Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_2E', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (vOK) then CRLF;
    if (UseStyle('Summe_div_C')) then SetLine(2);
    if (UseStyle('Summe_div_D')) then SetLine(3);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;

//=======================================================================
//=======================================================================