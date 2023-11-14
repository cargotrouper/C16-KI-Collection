@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Ele_LohnBAG
//                      OHNE E_R_G
//  Info
//    Druckelemente für Lohn-BA
//
//
//  13.11.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB elErsteSeite(var aHdl : int; opt aStartAS : int; opt aZielAS : int; opt aKundenAdr : int);
//  SUB elFolgeSeite(var aHdl : int; opt aStartAS : int; opt aZielAS : int; opt aKundenAdr : int);
//  SUB elEnde1(var aHdl : int; opt aStartAS : int; opt aZielAS : int; opt aKundenAdr : int);
//  SUB elEnde2(var aHdl : int; opt aStartAS : int; opt aZielAS : int; opt aKundenAdr : int);
//  SUB elEnde3(var aHdl : int; opt aStartAS : int; opt aZielAS : int; opt aKundenAdr : int);
//  SUB elEinsatzUS(var aHdl : int;);
//  SUB elEinsatz1(var aHdl : int; aLfdNr : int);
//  SUB elEinsatz2(var aHdl : int; aLfdNr : int);
//  SUB elEinsatzFuss(var aHdl : int);
//  SUB elFertigungUS(var aHdl : int);
//  SUB elFertigung1(var aHdl : int);
//  SUB elFertigung2(var aHdl : int);
//  SUB elFertigungFuss(var aHdl : int);
//  SUB elVerpackungUS(var aHdl : int);
//  SUB elVerpackung1(var aHdl : int);
//  SUB elVerpackung2(var aHdl : int);
//  SUB elVerpackungFuss(var aHdl : int);
//  SUB elFMUS(var aHdl : int);
//  SUB elFM1(var aHdl : int);
//  SUB elFM2(var aHdl : int);
//  SUB elFMFuss(var aHdl : int);
//  SUB elBeistellUS(var aHdl : int);
//  SUB elBeistell1(var aHdl : int);
//  SUB elBeistell2(var aHdl : int);
//  SUB elBeistellFuss(var aHdl : int);
//  SUB
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form

//=======================================================================
//  elErsteSeite
//=======================================================================
sub elErsteSeite(
  var aHdl        : int;
  opt aStartAS    : int;
  opt aZielAS     : int;
  opt aKundenAdr  : int;
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
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerB')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerB', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('ES_A')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_B')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false, aStartAS, aZielAs, aKundenAdr);
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
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_F')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', isVisible('ES_InhaltF')=false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      if (UseStyle('ES_InhaltF')) then
        SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);

    if (UseStyle('ES_G')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_H')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('ES_div_B')) then SetLine(1);

    if (UseStyle('ES_I')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', false, aStartAS, aZielAs, aKundenAdr);
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
  var aHdl        : int;
  opt aStartAS    : int;
  opt aZielAS     : int;
  opt aKundenAdr  : int;
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
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_Absender', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerB')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerB', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('FS_A')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_B')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('FS_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_C')) then begin;
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false, aStartAS, aZielAs, aKundenAdr);
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
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_F')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('FS_InhaltF');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);

    if (UseStyle('FS_G')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_G', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('FS_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('FS_H')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_H', false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      UseStyle('FS_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_B')) then SetLine(1);

    if (UseStyle('FS_I')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'FS_I', false, aStartAS, aZielAs, aKundenAdr);
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
//  elEnde1
//=======================================================================
sub elEnde1(
  var aHdl        : int;
  opt aStartAS    : int;
  opt aZielAS     : int;
  opt aKundenAdr  : int;
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
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', isVisible('Ende_InhaltA')=false, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      if (UseStyle('Ende_InhaltA')) then
        SetA(vInhalt);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elEnde2
//=======================================================================
sub elEnde2(
  var aHdl        : int;
  opt aStartAS    : int;
  opt aZielAS     : int;
  opt aKundenAdr  : int;
 );
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vI,vJ   : int;
end;
begin

  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___ENDE')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Ende_B')) then
      DynA('aaa');
    if (UseStyle('Ende_InhaltB')) then
      DynA('bbb');

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);

  if (IsVisible('Ende_B')=false) then RETURN;

  vJ # Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', false, aStartAS, aZielAS, aKundenAdr);

  // ggf. in Links/Rechts teilen?
  FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    EndPrint;
  END;

  EndPrint;
end;


//=======================================================================
//  elEnde3
//=======================================================================
sub elEnde3(
  var aHdl        : int;
  opt aStartAS    : int;
  opt aZielAS     : int;
  opt aKundenAdr  : int;
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
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_C')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_D')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_D', true, aStartAS, aZielAs, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elEinsatzUS
//=======================================================================
sub elEinsatzUS(
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

    if (IsVisible('___EINSATZUS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------

    if (UseStyle('Einsatz_Titel')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_Titel', true,0);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('EinsatzUS_div_A')) then SetLine(0);

    if (UseStyle('EinsatzUS_A')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_A', true,0)
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_B')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_B', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_C')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_C', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_D')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_D', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_E')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_E', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_F')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_F', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_G')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_G', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_H')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_H', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_I')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_I', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_J')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_J', true,0);
      SetA(vLabels);
    end;

    if (UseStyle('EinsatzUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('EinsatzUS_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elEinsatz1
//=======================================================================
sub elEinsatz1(
  var aHdl  : int;
  aLfdNr    : int;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin

    if (IsVisible('___EINSATZ')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Einsatz_1A')) then
      DynA('aaa');
    if (UseStyle('Einsatz_1B')) then
      DynA('bbb');
    if (UseStyle('Einsatz_1C')) then
      DynA('ccc');
    if (UseStyle('Einsatz_1D')) then
      DynA('ddd');
    if (UseStyle('Einsatz_1E')) then
      DynA('eee');
    if (UseStyle('Einsatz_1F')) then
      DynA('fff');
    if (UseStyle('Einsatz_1G')) then
      DynA('ggg');
    if (UseStyle('Einsatz_1H')) then
      DynA('hhh');
    if (UseStyle('Einsatz_1I')) then
      DynA('iii');
    if (UseStyle('Einsatz_1J')) then
      DynA('jjj');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('Einsatz_1A')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1A', true, aLfdNr);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('Einsatz_1B')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1B', true, aLfdNr);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Einsatz_1C')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1C', true, aLfdNr);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Einsatz_1D')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1D', true, aLfdNr);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Einsatz_1E')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1E', true, aLfdNr);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Einsatz_1F')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1F', true, aLfdNr);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('Einsatz_1G')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1G', true, aLfdNr);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('Einsatz_1H')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1H', true, aLfdNr);
    FillDynA('hhh',vLabels);
  end;
  if (isVisible('Einsatz_1I')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1I', true, aLfdNr);
    FillDynA('iii',vLabels);
  end;
  if (isVisible('Einsatz_1J')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1J', true, aLfdNr);
    FillDynA('jjj',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elEinsatz2
//=======================================================================
sub elEinsatz2(
  var aHdl  : int;
  aLfdNr    : int;
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

    if (IsVisible('___EINSATZ')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Einsatz_2A')) then
      DynA('aaa');
    if (UseStyle('Einsatz_Inhalt2A')) then
      DynA('bbb');
    if (UseStyle('Einsatz_2B')) then
      DynA('ccc');
    if (UseStyle('Einsatz_Inhalt2B')) then
      DynA('ddd');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  if (IsVisible('Einsatz_2A')=false) then RETURN;

  vJ # Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_2A', false, aLfdNr);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('Einsatz_2B')) then vSplit # (vJ / 2) + (vJ % 2);

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ccc',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('ddd',Str_Token(vInhalt,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elEinsatzFuss
//=======================================================================
sub elEinsatzFuss(
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

    if (IsVisible('___EINSATZFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('EinsatzFuss_div_A')) then SetLine(0);

    if (UseStyle('EinsatzFuss_A')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_A', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzFuss_B')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_B', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzFuss_C')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_C', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzFuss_D')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_D', true,0);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elFertigungUS
//=======================================================================
sub elFertigungUS(
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

    if (IsVisible('___FERTIGUNGUS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------

    if (UseStyle('Fertigung_Titel')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_Titel', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('FertigungUS_div_A')) then SetLine(0);

    if (UseStyle('FertigungUS_A')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_A', true)
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_B')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_C')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_D')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_E')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_F')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_G')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_G', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_H')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_H', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_I')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_I', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_J')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_J', true);
      SetA(vLabels);
    end;

    if (UseStyle('FertigungUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('FertigungUS_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elFertigung1
//=======================================================================
sub elFertigung1(
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

    if (IsVisible('___FERTIGUNG')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Fertigung_1A')) then
      DynA('aaa');
    if (UseStyle('Fertigung_1B')) then
      DynA('bbb');
    if (UseStyle('Fertigung_1C')) then
      DynA('ccc');
    if (UseStyle('Fertigung_1D')) then
      DynA('ddd');
    if (UseStyle('Fertigung_1E')) then
      DynA('eee');
    if (UseStyle('Fertigung_1F')) then
      DynA('fff');
    if (UseStyle('Fertigung_1G')) then
      DynA('ggg');
    if (UseStyle('Fertigung_1H')) then
      DynA('hhh');
    if (UseStyle('Fertigung_1I')) then
      DynA('iii');
    if (UseStyle('Fertigung_1J')) then
      DynA('jjj');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('Fertigung_1A')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('Fertigung_1B')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Fertigung_1C')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Fertigung_1D')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Fertigung_1E')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Fertigung_1F')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('Fertigung_1G')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('Fertigung_1H')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1H', true);
    FillDynA('hhh',vLabels);
  end;
  if (isVisible('Fertigung_1I')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1I', true);
    FillDynA('iii',vLabels);
  end;
  if (isVisible('Fertigung_1J')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1J', true);
    FillDynA('jjj',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elFertigung2
//=======================================================================
sub elFertigung2(
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

    if (IsVisible('___FERTIGUNG')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Fertigung_2A')) then
      DynA('aaa');
    if (UseStyle('Fertigung_Inhalt2A')) then
      DynA('bbb');
    if (UseStyle('Fertigung_2B')) then
      DynA('ccc');
    if (UseStyle('Fertigung_Inhalt2B')) then
      DynA('ddd');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  if (IsVisible('Fertigung_2A')=false) then RETURN;

  vJ # Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_2A', false);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('Fertigung_2B')) then vSplit # (vJ / 2) + (vJ % 2);

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ccc',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('ddd',Str_Token(vInhalt,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elFertigungFuss
//=======================================================================
sub elFertigungFuss(
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

    if (IsVisible('___FERTIGUNGFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('FertigungFuss_div_A')) then SetLine(0);

    if (UseStyle('FertigungFuss_A')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_A', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungFuss_B')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungFuss_C')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungFuss_D')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_D', true);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elVerpackungUS
//=======================================================================
sub elVerpackungUS(
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

    if (IsVisible('___VPGUS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------

    if (UseStyle('VPG_Titel')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_Titel', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('VPGUS_div_A')) then SetLine(0);

    if (UseStyle('VPGUS_A')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_A', true)
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_B')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_C')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_D')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_E')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_F')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_G')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_G', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_H')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_H', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_I')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_I', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGUS_J')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGUS_J', true);
      SetA(vLabels);
    end;

    if (UseStyle('VPGUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('VPGUS_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elVerpackung1
//=======================================================================
sub elVerpackung1(
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

    if (IsVisible('___VPG')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('VPG_1A')) then
      DynA('aaa');
    if (UseStyle('VPG_1B')) then
      DynA('bbb');
    if (UseStyle('VPG_1C')) then
      DynA('ccc');
    if (UseStyle('VPG_1D')) then
      DynA('ddd');
    if (UseStyle('VPG_1E')) then
      DynA('eee');
    if (UseStyle('VPG_1F')) then
      DynA('fff');
    if (UseStyle('VPG_1G')) then
      DynA('ggg');
    if (UseStyle('VPG_1H')) then
      DynA('hhh');
    if (UseStyle('VPG_1I')) then
      DynA('iii');
    if (UseStyle('VPG_1J')) then
      DynA('jjj');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('VPG_1A')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('VPG_1B')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('VPG_1C')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('VPG_1D')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('VPG_1E')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('VPG_1F')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('VPG_1G')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('VPG_1H')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1H', true);
    FillDynA('hhh',vLabels);
  end;
  if (isVisible('VPG_1I')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1I', true);
    FillDynA('iii',vLabels);
  end;
  if (isVisible('VPG_1J')) then begin
    Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_1J', true);
    FillDynA('jjj',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elVerpackung2
//=======================================================================
sub elVerpackung2(
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

    if (IsVisible('___VPG')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('VPG_2A')) then
      DynA('aaa');
    if (UseStyle('VPG_Inhalt2A')) then
      DynA('bbb');
    if (UseStyle('VPG_2B')) then
      DynA('ccc');
    if (UseStyle('VPG_Inhalt2B')) then
      DynA('ddd');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  if (IsVisible('VPG_2A')=false) then RETURN;

  vJ # Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPG_2A', IsVisible('VPG_Inhalt2A')=false);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('VPG_2B')) then vSplit # (vJ / 2) + (vJ % 2);

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    if (IsVisible('VPG_Inhalt2A')) then
      FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ccc',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('ddd',Str_Token(vInhalt,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elVerpackungFuss
//=======================================================================
sub elVerpackungFuss(
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

    if (IsVisible('___VPGFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('VPGFuss_div_A')) then SetLine(0);

    if (UseStyle('VPGFuss_A')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_A', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGFuss_B')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGFuss_C')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('VPGFuss_D')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_D', true);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elFMUS
//=======================================================================
sub elFMUS(
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

    if (IsVisible('___FMUS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------

    if (UseStyle('FM_Titel')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_Titel', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('FMUS_div_A')) then SetLine(0);

    if (UseStyle('FMUS_A')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_A', true)
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_B')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_C')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_D')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_E')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_F')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_G')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_G', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_H')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_H', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_I')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_I', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMUS_J')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMUS_J', true);
      SetA(vLabels);
    end;

    if (UseStyle('FMUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('FMUS_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elFM1
//=======================================================================
sub elFM1(
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

    if (IsVisible('___FM')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('FM_1A')) then
      DynA('aaa');
    if (UseStyle('FM_1B')) then
      DynA('bbb');
    if (UseStyle('FM_1C')) then
      DynA('ccc');
    if (UseStyle('FM_1D')) then
      DynA('ddd');
    if (UseStyle('FM_1E')) then
      DynA('eee');
    if (UseStyle('FM_1F')) then
      DynA('fff');
    if (UseStyle('FM_1G')) then
      DynA('ggg');
    if (UseStyle('FM_1H')) then
      DynA('hhh');
    if (UseStyle('FM_1I')) then
      DynA('iii');
    if (UseStyle('FM_1J')) then
      DynA('jjj');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('FM_1A')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('FM_1B')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('FM_1C')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('FM_1D')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('FM_1E')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('FM_1F')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('FM_1G')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('FM_1H')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1H', true);
    FillDynA('hhh',vLabels);
  end;
  if (isVisible('FM_1I')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1I', true);
    FillDynA('iii',vLabels);
  end;
  if (isVisible('FM_1J')) then begin
    Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_1J', true);
    FillDynA('jjj',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elFM2
//=======================================================================
sub elFM2(
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

    if (IsVisible('___FM')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('FM_2A')) then
      DynA('aaa');
    if (UseStyle('FM_Inhalt2A')) then
      DynA('bbb');
    if (UseStyle('FM_2B')) then
      DynA('ccc');
    if (UseStyle('FM_Inhalt2B')) then
      DynA('ddd');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  if (IsVisible('FM_2A')=false) then RETURN;

  vJ # Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FM_2A', IsVisible('FM_Inhalt2A')=false);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('FM_2B')) then vSplit # (vJ / 2) + (vJ % 2);

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    if (IsVisible('FM_Inhalt2A')) then
      FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ccc',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('ddd',Str_Token(vInhalt,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elFMFuss
//=======================================================================
sub elFMFuss(
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

    if (IsVisible('___FMFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('FMFuss_div_A')) then SetLine(0);

    if (UseStyle('FMFuss_A')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMFuss_A', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMFuss_B')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMFuss_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMFuss_C')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMFuss_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMFuss_D')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMFuss_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMFuss_E')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMFuss_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('FMFuss_F')) then begin
      Form_Parse_BAG:Parse707Multi(var vLabels, var vInhalt, var vZusatz, 'FMFuss_F', true);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elBeistellUS
//=======================================================================
sub elBeistellUS(
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

    if (IsVisible('___BEISTELLUS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------

    if (UseStyle('Beistell_Titel')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_Titel', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('BeistellUS_div_A')) then SetLine(0);

    if (UseStyle('BeistellUS_A')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_A', true)
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_B')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_C')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_D')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_E')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_F')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_G')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_G', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_H')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_H', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_I')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_I', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellUS_J')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellUS_J', true);
      SetA(vLabels);
    end;

    if (UseStyle('BeistellUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('BeistellUS_div_B')) then SetLine(1);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
//  elBeistell1
//=======================================================================
sub elBeistell1(
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

    if (IsVisible('___BEISTELL')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Beistell_1A')) then
      DynA('aaa');
    if (UseStyle('Beistell_1B')) then
      DynA('bbb');
    if (UseStyle('Beistell_1C')) then
      DynA('ccc');
    if (UseStyle('Beistell_1D')) then
      DynA('ddd');
    if (UseStyle('Beistell_1E')) then
      DynA('eee');
    if (UseStyle('Beistell_1F')) then
      DynA('fff');
    if (UseStyle('Beistell_1G')) then
      DynA('ggg');
    if (UseStyle('Beistell_1H')) then
      DynA('hhh');
    if (UseStyle('Beistell_1I')) then
      DynA('iii');
    if (UseStyle('Beistell_1J')) then
      DynA('jjj');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('Beistell_1A')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('Beistell_1B')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('Beistell_1C')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('Beistell_1D')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('Beistell_1E')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('Beistell_1F')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('Beistell_1G')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('Beistell_1H')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1H', true);
    FillDynA('hhh',vLabels);
  end;
  if (isVisible('Beistell_1I')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1I', true);
    FillDynA('iii',vLabels);
  end;
  if (isVisible('Beistell_1J')) then begin
    Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_1J', true);
    FillDynA('jjj',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elBeistell2
//=======================================================================
sub elBeistell2(
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

    if (IsVisible('___BEISTELL')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Beistell_2A')) then
      DynA('aaa');
    if (UseStyle('Beistell_Inhalt2A')) then
      DynA('bbb');
    if (UseStyle('Beistell_2B')) then
      DynA('ccc');
    if (UseStyle('Beistell_Inhalt2B')) then
      DynA('ddd');
    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------


  if (IsVisible('Beistell_2A')=false) then RETURN;

  vJ # Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'Beistell_2A', IsVisible('Beistell_Inhalt2A')=false);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('Beistell_2B')) then vSplit # (vJ / 2) + (vJ % 2);

  FOR vI # 1 loop inc(vI) while (vI<=vSplit) do begin
    StartPrint(aHdl);
    FillDynA('aaa',Str_Token(vLabels,Strchar(10), vI));
    if (IsVisible('Beistell_Inhalt2A')) then
      FillDynA('bbb',Str_Token(vInhalt,Strchar(10), vI));
    if (vSplit<>vJ) then begin
      FillDynA('ccc',Str_Token(vLabels,Strchar(10), vI + vSplit));
      FillDynA('ddd',Str_Token(vInhalt,Strchar(10), vI + vSplit));
    end;
    EndPrint;
  END;

end;


//=======================================================================
//  elBeistellFuss
//=======================================================================
sub elBeistellFuss(
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

    if (IsVisible('___BEISTELLFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('BeistellFuss_div_A')) then SetLine(0);

    if (UseStyle('BeistellFuss_A')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellFuss_A', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellFuss_B')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellFuss_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellFuss_C')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'BeistellFuss_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('BeistellFuss_D')) then begin
      Form_Parse_BAG:Parse708Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_D', true);
      SetA(vLabels);
    end;
    CRLF;
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;



//=======================================================================
//=======================================================================