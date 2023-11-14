@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Ele_Mat
//                      OHNE E_R_G
//  Info
//    Druckelemente für Material
//
//
//  23.10.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB elMatWZErsteSeite(var aHdl : int);
//  SUB elMatWZFolgeSeite(var aHdl : int);
//  SUB elMatWZEnde(var aHdl : int);
//  SUB elMatWZTabelleUS(var aHdl : int; aName : alpha);
//  SUB elMatWZTabelle(var aHdl : int; aName : alpha; opt aTest : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form

//=======================================================================
//  elMatWZErsteSeite
//=======================================================================
sub elMatWZErsteSeite(
  var aHdl    : int;
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
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerB')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerB', true);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('ES_A')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_B')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false);
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
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_F')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', isVisible('ES_InhaltF')=false);
      SetA(vLabels);
      if (UseStyle('ES_InhaltF')) then
        SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);

    if (UseStyle('ES_G')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', false);
      SetA(vLabels);
      UseStyle('ES_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_H')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', false);
      SetA(vLabels);
      UseStyle('ES_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('ES_div_B')) then SetLine(1);

    if (UseStyle('ES_I')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', false);
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
//  elMatWZFolgeSeite
//=======================================================================
sub elMatWZFolgeSeite(
  var aHdl    : int;
  );
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
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_Absender', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerB')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerB', true);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('FS_A')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_B')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B', false);
      SetA(vLabels);
      UseStyle('FS_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_C')) then begin;
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false);
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
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_F')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', false);
      SetA(vLabels);
      UseStyle('FS_InhaltF');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);

    if (UseStyle('FS_G')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_G', false);
      SetA(vLabels);
      UseStyle('FS_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('FS_H')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_H', false);
      SetA(vLabels);
      UseStyle('FS_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_B')) then SetLine(1);

    if (UseStyle('FS_I')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'FS_I', false);
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
//  elMatWZEnde
//=======================================================================
sub elMatWZEnde(
  var aHdl    : int;
 );
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
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', false);
      SetA(vLabels);
      UseStyle('Ende_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_B')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_C')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true);
      SetA(vLabels);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elMatWZTAbelleUS
//=======================================================================
sub elMatWZTabelleUS(
  var aHdl    : int;
  aName       : alpha;
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

    if (IsVisible('___TABELLE1')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle(aName+'_Titel')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'_Titel', true);
      SetA(vLabels);
      CRLF;
    end;


    SetVLineX( 1,aName+'_div_V1');
    SetVLineX( 2,aName+'_div_V2');
    SetVLineX( 3,aName+'_div_V3');
    SetVLineX( 4,aName+'_div_V4');
    SetVLineX( 5,aName+'_div_V5');
    SetVLineX( 6,aName+'_div_V6');
    SetVLineX( 7,aName+'_div_V7');
    SetVLineX( 8,aName+'_div_V8');
    SetVLineX(10,aName+'_div_V9');

    vOK # n;
    if (UseStyle(aName+'US_A')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_A', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle(aName+'US_B')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_B', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle(aName+'US_C')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_C', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle(aName+'US_D')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle(aName+'US_E')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_E', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle(aName+'US_F')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_F', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle(aName+'US_G')) then begin
      Form_Parse_Mat:Parse200Multi(var vLabels, var vInhalt, var vZusatz, aName+'US_G', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle(aName+'_div_A')) then SetLine(0);

  end;  // Design

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  EndPrint;

  SetVLineStartY(1);
  SetVLineStartY(2);
  SetVLineStartY(3);
  SetVLineStartY(4);
  SetVLineStartY(5);
  SetVLineStartY(6);
  SetVLineStartY(7);
  SetVLineStartY(8);
  SetVLineStartY(9);
end;



//=======================================================================
//  elMatWZTabelle
//=======================================================================
sub elMatWZTabelle(
  var aHdl    : int;
  aName       : alpha;
  opt aTest   : alpha;
  );
local begin
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  vI,vJ   : int;
  vA1,vA2,vA3,vA4,vA5,vA6,vA7 : alpha(4096);
  vB1,vB2,vB3,vB4,vB5,vB6,vB7 : alpha(100);
  vC1,vC2,vC3,vC4,vC5,vC6,vC7 : alpha(4096);
  vMax    : int;
end;
begin

  // initializing?
  if (aHdl=0) then begin

    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA1, var vInhalt, var vZusatz, aName+'_A', true));
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA2, var vInhalt, var vZusatz, aName+'_B', true));
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA3, var vInhalt, var vZusatz, aName+'_C', true));
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA4, var vInhalt, var vZusatz, aName+'_D', true));
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA5, var vInhalt, var vZusatz, aName+'_E', true));
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA6, var vInhalt, var vZusatz, aName+'_F', true));
    vMax # Max(vMax, Form_Parse_Mat:Parse200Multi(var vA7, var vInhalt, var vZusatz, aName+'_G', true));

    FOR vI # 1 loop inc(vI) while (vI<=vMax) do begin
      vB1 # Str_Token(vA1,Strchar(10), vI);
      vB2 # Str_Token(vA2,Strchar(10), vI);
      vB3 # Str_Token(vA3,Strchar(10), vI);
      vB4 # Str_Token(vA4,Strchar(10), vI);
      vB5 # Str_Token(vA5,Strchar(10), vI);
      vB6 # Str_Token(vA6,Strchar(10), vI);
      vB7 # Str_Token(vA7,Strchar(10), vI);

      // keine Min/Max? -> Dann überspringen
      if (aTest='SPALTE4+5') then begin
        if (StrAdj(vB4+vB5, _strall)='') then CYCLE;
        end
      // keine Ist-Wert? -> Dann überspringen
      else if (aTest='SPALTE6') then begin
        if (StrAdj(vB6, _strall)='') then CYCLE;
      end;
      vC1 # vC1 + vB1 + StrChar(10);
      vC2 # vC2 + vB2 + StrChar(10);
      vC3 # vC3 + vB3 + StrChar(10);
      vC4 # vC4 + vB4 + StrChar(10);
      vC5 # vC5 + vB5 + StrChar(10);
      vC6 # vC6 + vB6 + StrChar(10);
      vC7 # vC7 + vB7 + StrChar(10);
    END;
    if (UseStyle(aName+'_A')) then
      SetA(vC1);
    if (UseStyle(aName+'_B')) then
      SetA(vC2);
    if (UseStyle(aName+'_C')) then
      SetA(vC3);
    if (UseStyle(aName+'_D')) then
      SetA(vC4);
    if (UseStyle(aName+'_E')) then
      SetA(vC5);
    if (UseStyle(aName+'_F')) then
      SetA(vC6);
    if (UseStyle(aName+'_G')) then
      SetA(vC7);

    CRLF;

    if (UseStyle(aName+'_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  EndPrint;

  PrintVLinie(1);
  PrintVLinie(2);
  PrintVLinie(3);
  PrintVLinie(4);
  PrintVLinie(5);
  PrintVLinie(6);
  PrintVLinie(7);
  PrintVLinie(8);
  PrintVLinie(9);
end;


// --- ALLGEMEIN --------------------------------------------------------------------------



//=======================================================================
//=======================================================================