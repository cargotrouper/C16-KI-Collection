@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Ele_Ofp
//                      OHNE E_R_G
//  Info
//    Druckelemente für Offene Posten
//
//
//  06.05.2013  ST  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB elMahnErsteSeite(var aHdl : int);
//  SUB elMahnFolgeSeite(var aHdl : int);

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
//  elMahnErsteSeite
//=======================================================================
sub elMahnErsteSeite(
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
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true);
      SetA(vLabels);
      vOK # y;
    end;

    if (UseStyle('ES_A')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then
    vOK # n;

    if (UseStyle('ES_B')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false);
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
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_F')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', isVisible('ES_InhaltF')=false);
      SetA(vLabels);
      if (UseStyle('ES_InhaltF')) then
        SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);

    if (UseStyle('ES_G')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', false);
      SetA(vLabels);
      UseStyle('ES_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_H')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', false);
      SetA(vLabels);
      UseStyle('ES_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('ES_div_B')) then SetLine(1);

    if (UseStyle('ES_I')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', false);
      SetA(vLabels);
      UseStyle('ES_InhaltI');
      SetA(vInhalt);
      CRLF;
    end;
  end;
  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;



//=======================================================================
//  elMahnFolgeSeite
//=======================================================================
sub elMahnFolgeSeite(  var aHdl    : int)
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
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerB')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerB', true);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('FS_A')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_B')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B', false);
      SetA(vLabels);
      UseStyle('FS_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_C')) then begin;
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false);
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
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true);
      DynA('eee');
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_F')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', false);
      SetA(vLabels);
      UseStyle('FS_InhaltF');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);

    if (UseStyle('FS_G')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_G', false);
      SetA(vLabels);
      UseStyle('FS_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('FS_H')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_H', false);
      SetA(vLabels);
      UseStyle('FS_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_B')) then SetLine(1);

    if (UseStyle('FS_I')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_I', false);
      SetA(vLabels);
      UseStyle('FS_InhaltI');
      SetA(vInhalt);
      CRLF;
    end;

  end;  // Design


  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);

  if (isVisible('FS_C')) then begin
    if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false)>=0) then
      FillDynA('ccc',vInhalt);
  end;

  if (isVisible('FS_E')) then begin
    if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true)>=0) then
      FillDynA('eee',vLabels);
  end;


  EndPrint;
end;





//=======================================================================
//  elMahnPostenUS
//=======================================================================
sub elMahnPostenUS(
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
    if (UseStyle('US_div_A')) then SetLine(0);

    if (UseStyle('US_A')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_A', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_B')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_C')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_D')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_E')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_F')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_G')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_G', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_H')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_H', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_I')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'US_I', true);
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
//  elMahnPosten
//=======================================================================
sub elMahnPosten(
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
    if (UseStyle('PosOFP_1A')) then
      DynA('aaa');
    if (UseStyle('PosOFP_1B')) then
      DynA('bbb');
    if (UseStyle('PosOFP_1C')) then
      DynA('ccc');
    if (UseStyle('PosOFP_1D')) then
      DynA('ddd');
    if (UseStyle('PosOFP_1E')) then
      DynA('eee');
    if (UseStyle('PosOFP_1F')) then
      DynA('fff');
    if (UseStyle('PosOFP_1G')) then
      DynA('ggg');
    if (UseStyle('PosOFP_1H')) then
      DynA('hhh');
    if (UseStyle('PosOFP_1I')) then
      DynA('iii');


    CRLF;

  end;  // Design

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  if (isVisible('PosOFP_1A')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1A', true);
    FillDynA('aaa',vLabels);
  end;

  if (isVisible('PosOFP_1B')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosOFP_1C')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosOFP_1D')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosOFP_1E')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosOFP_1F')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosOFP_1G')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosOFP_1H')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1H', true);
    FillDynA('hhh',vLabels);
  end;
  if (isVisible('PosOFP_1I')) then begin
    Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'PosOFP_1I', true);
    FillDynA('iii',vLabels);
  end;
  EndPrint;

end;




//=======================================================================
//  elSumme
//=======================================================================
sub elSumme(
  var aHdl      : int;
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

    vOk # n;
    if (UseStyle('Summe_A')) then begin
      vOK # y;
      if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_A', true)<0) then
        VarA('Summe_A')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_B')) then begin
      vOK # y;
      if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_B', true)<0) then
        VarA('Summe_B')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_C')) then begin
      vOK # y;
      if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_C', true)<0) then
        VarA('Summe_C')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_D')) then begin
      vOK # y;
      if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_D', true)<0) then
        VarA('Summe_D')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_E')) then begin
      vOK # y;
      if (Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_E', true)<0) then
        VarA('Summe_E')
      else
        SetA(vLabels);
    end;
    if (vOK) then CRLF;
    vOK # n;

  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  EndPrint;

end;



//=======================================================================
//  elMahnEnde
//=======================================================================
sub elMahnEnde(
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
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', true);
      SetA(vLabels);
/*
      UseStyle('Ende_InhaltA');
      SetA(vInhalt);
*/
      CRLF;
    end;

    if (UseStyle('Ende_B')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true);
      SetA(vLabels);
/*
      UseStyle('Ende_InhaltB');
      SetA(vInhalt);
*/
      CRLF;
    end;

    if (UseStyle('Ende_C')) then begin
      Form_Parse_Ofp:Parse460Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true);
      SetA(vLabels);
/*
      UseStyle('Ende_InhaltC');
      SetA(vInhalt);
*/
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
/*
  PrintVLinie(1);
  PrintVLinie(2);
  PrintVLinie(3);
  PrintVLinie(4);
  PrintVLinie(5);
  PrintVLinie(6);
  PrintVLinie(7);
  PrintVLinie(8);
  PrintVLinie(9);
*/
  StartPrint(aHdl);
  EndPrint;

end;







//=======================================================================
//=======================================================================