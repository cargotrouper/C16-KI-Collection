@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Ele_Mat
//                      OHNE E_R_G
//  Info
//    Druckelemente für Kasse
//
//
//  07.01.2013  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB elBuchErsteSeite(var aHdl : int);
//  SUB elBuchFolgeSeite(var aHdl : int);
//  SUB elBuchEnde(var aHdl : int);
//  SUB elBuchPostenUS(var aHdl : int);
//  SUB elBuchPostene(var aHdl : int);
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form

//=======================================================================
//  elBuchErsteSeite
//=======================================================================
sub elBuchErsteSeite(
  var aHdl    : int;
  );
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  vFont   : font;
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___ERSTESEITE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true);
      SetA(vLabels);
      vOK # y;
    end;

    if (UseStyle('ES_A')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (Usestyle('ES_D')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_div_A')) then SetLine(0);

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elBuchFoleSeite
//=======================================================================
sub elBuchFolgeSeite(
  var aHdl    : int;
  );
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
  vFont   : Font;
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___FOLGESEITE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true);
      SetA(vLabels);
      vOK # y;
    end;

    if (UseStyle('FS_A')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (Usestyle('FS_D')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_A')) then SetLine(0);

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elBuchEnde
//=======================================================================
sub elBuchEnde(
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
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', false);
      SetA(vLabels);
      UseStyle('Ende_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('Ende_div_B')) then SetLine(1);

  end;  // Design

  // PRINT --------------------------------------------------------------------

  PrintVLinie(1);
  PrintVLinie(2);
  PrintVLinie(3);
  PrintVLinie(4);
  PrintVLinie(5);
  PrintVLinie(6);
  PrintVLinie(7);
  PrintVLinie(8);
  PrintVLinie(9);

  StartPrint(aHdl);
  EndPrint;

end;


//=======================================================================
//  elBuchPostenUS
//=======================================================================
sub elBuchPostenUS(
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

    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------

    SetVLineX( 1,'Posten_div_V1');
    SetVLineX( 2,'Posten_div_V2');
    SetVLineX( 3,'Posten_div_V3');
    SetVLineX( 4,'Posten_div_V4');
    SetVLineX( 5,'Posten_div_V5');
    SetVLineX( 6,'Posten_div_V6');
    SetVLineX( 7,'Posten_div_V7');
    SetVLineX( 8,'Posten_div_V8');
    SetVLineX( 9,'Posten_div_V9');

    vOK # n;
    if (UseStyle('PostenUS_A')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_A', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_B')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_B', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_C')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_C', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_D')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_E')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_E', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_F')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_F', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_G')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_G', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('PostenUS_H')) then begin
      Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'PostenUS_H', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('PostenUS_div_A')) then SetLine(0);

  end;  // Design

  // PRINT --------------------------------------------------------------------

  SetVLineStartY(1);
  SetVLineStartY(2);
  SetVLineStartY(3);
  SetVLineStartY(4);
  SetVLineStartY(5);
  SetVLineStartY(6);
  SetVLineStartY(7);
  SetVLineStartY(8);
  SetVLineStartY(9);

  StartPrint(aHdl);
  EndPrint;

end;



//=======================================================================
//  elBuchPosten
//=======================================================================
sub elBuchPosten(
  var aHdl    : int);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // initializing?
  if (aHdl=0) then begin

    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Posten_A')) then
      DynA('aaa');
    if (UseStyle('Posten_B')) then
      DynA('bbb');
    if (UseStyle('Posten_C')) then
      DynA('ccc');
    if (UseStyle('Posten_D')) then
      DynA('ddd');
    if (UseStyle('Posten_E')) then
      DynA('eee');
    if (UseStyle('Posten_F')) then
      DynA('fff');
    if (UseStyle('Posten_G')) then
      DynA('ggg');
    if (UseStyle('Posten_H')) then
      DynA('hhh');

    CRLF;

  end;  // Design

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  if (isVisible('Posten_A')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('Posten_B')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Posten_C')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Posten_D')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Posten_E')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Posten_F')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('Posten_G')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('Posten_H')) then begin
    Form_Parse_Kas:Parse573Multi(var vLabels, var vInhalt, var vZusatz, 'Posten_H', true);
    FillDynA('hhh',vLabels);
  end;
  EndPrint;

end;


//=======================================================================
//=======================================================================