@A+
//===== Business-Control =================================================
//
//  Prozedur    Foem_Ele_Lfs
//                      OHNE E_R_G
//  Info
//    Druckt einen LFS
//
//
//  20.11.2012  AI  Erstellung der Prozedur
//  10.04.2013  ST  Inhalte FS_C und FC_E werden jetzt dynamisch
//                  dargstellt -> wichtig für Seite > 2
//
//  Subprozeduren
//  SUB elErsteSeite(var aHdl : int; aSpediAdr : int; aStartAS : int);
//  SUB elFolgeSeite(var aHdl : int; aSpediAdr : int; aStartAS : int);
//  SUB elEnde(var aHdl : int; aSpediAdr : int; aStartAS : int);
//  SUB elUeberschrift(var aHdl : int);
//  SUB elPosMat1(var aHdl : int);
//  SUB elPosMat2(var aHdl : int);
//  SUB elPosArt1(var aHdl : int);
//  SUB elPosArt2(var aHdl : int);
//  SUB elSumme(var aHdl : int);
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  elErsteSeite
//=======================================================================
sub elErsteSeite(
  var aHdl    : int;
  aSpediAdr   : int;
  aStartAS    : int;
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
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Absender', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerA')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerA', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_EmpfaengerB')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_EmpfaengerB', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('ES_A')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_B')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false, aSpediAdr, aStartAS);
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
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('ES_E')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', true, aSpediAdr, aStartAS);
      SetA(vLabels);
    end;
    if (vOK) then CRLF;

    if (UseStyle('ES_F')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', isVisible('ES_InhaltF')=false, aSpediAdr, aStartAS);
      SetA(vLabels);
      if (UseStyle('ES_InhaltF')) then
        SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);

    if (UseStyle('ES_G')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('ES_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_H')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('ES_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('ES_div_B')) then SetLine(1);

    if (UseStyle('ES_I')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', false, aSpediAdr, aStartAS);
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
  var aHdl    : int;
  aSpediAdr   : int;
  aStartAS    : int);
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
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_Absender', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerA')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerA', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('FS_EmpfaengerB')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_EmpfaengerB', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    vI # pls_PosY;
    pls_PosY # 0;

    if (UseStyle('FS_A')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('FS_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_B')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('FS_InhaltB');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('FS_C')) then begin;
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false, aSpediAdr, aStartAS);
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
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      vOK # y;
    end;
    if (Usestyle('FS_E')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true, aSpediAdr, aStartAS);
      DynA('eee');
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_F')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('FS_InhaltF');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);

    if (UseStyle('FS_G')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_G', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('FS_InhaltG');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('FS_H')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_H', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('FS_InhaltH');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;

    if (UseStyle('FS_div_B')) then SetLine(1);

    if (UseStyle('FS_I')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_I', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('FS_InhaltI');
      SetA(vInhalt);
      CRLF;
    end;

  end;  // Design


  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);

  if (isVisible('FS_C')) then begin
    if (Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', false, aSpediAdr, aStartAS)>=0) then
      FillDynA('ccc',vInhalt);
  end;

  if (isVisible('FS_E')) then begin
    if (Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E', true, aSpediAdr, aStartAS)>=0) then
      FillDynA('eee',vLabels);
  end;

  EndPrint;
end;


//=======================================================================
//  elEnde
//=======================================================================
sub elEnde(
  var aHdl    : int;
  aSpediAdr   : int;
  aStartAS    : int);
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
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', false, aSpediAdr, aStartAS);
      SetA(vLabels);
      UseStyle('Ende_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_B')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true, aSpediAdr, aStartAS);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_C')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true, aSpediAdr, aStartAS);
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
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_A', true, 0, 0);
      SetA(vLabels);
      // <<< MUSTER >>>
      // SetVLinieStartX(1) # Form_StyleX;
    end;
    if (UseStyle('US_B')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_B', true, 0, 0);
      SetA(vLabels);
    end;
    if (UseStyle('US_C')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_C', true, 0, 0);
      SetA(vLabels);
    end;
    if (UseStyle('US_D')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_D', true, 0, 0);
      SetA(vLabels);
    end;
    if (UseStyle('US_E')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_E', true, 0, 0);
      SetA(vLabels);
    end;
    if (UseStyle('US_F')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_F', true, 0, 0);
      SetA(vLabels);
    end;
    if (UseStyle('US_G')) then begin
      Form_Parse_Lfs:Parse440Multi(var vLabels, var vInhalt, var vZusatz, 'US_G', true, 0, 0);
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
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('PosMat_1B')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosMat_1C')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosMat_1D')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosMat_1E')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosMat_1F')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosMat_1G')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosMat_1H')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_1H', true);
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


  vJ # Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosMat_2A', false);

  // ggf. in Links/Rechts teilen?
  vSplit # vJ;
  if (IsVisible('PosMat_2D')) then vSplit # (vJ / 2) + (vJ % 2);

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
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1A', true);
    FillDynA('aaa',vLabels);
  end;
  if (isVisible('PosArt_1B')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1B', true);
    FillDynA('bbb',vLabels);
  end;
  if (isVisible('PosArt_1C')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1C', true);
    FillDynA('ccc',vLabels);
  end;
  if (isVisible('PosArt_1D')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1D', true);
    FillDynA('ddd',vLabels);
  end;
  if (isVisible('PosArt_1E')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1E', true);
    FillDynA('eee',vLabels);
  end;
  if (isVisible('PosArt_1F')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1F', true);
    FillDynA('fff',vLabels);
  end;
  if (isVisible('PosArt_1G')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1G', true);
    FillDynA('ggg',vLabels);
  end;
  if (isVisible('PosArt_1H')) then begin
    Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_1H', true);
    FillDynA('hhh',vLabels);
  end;
  EndPrint;
end;


//=======================================================================
//  elPostArt2
//=======================================================================
sub elPosArt2(
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


  vJ # Form_Parse_Lfs:Parse441multi(var vLabels, var vInhalt, var vZusatz, 'PosArt_2A', false);

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
//  elSumme
//=======================================================================
sub elSumme(
  var aHdl          : int);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vOK     : logic;
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    if (IsVisible('___SUMME')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    if (UseStyle('Summe_div_A')) then SetLine(0);
    if (UseStyle('Summe_div_B')) then SetLine(1);
    // Summen drucken

    vOk # n;
    if (UseStyle('Summe_A')) then begin
      vOK # y;
      if (Form_Parse_Lfs:Parse441Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_A', true)<0) then
        VarA('Summe_A')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_B')) then begin
      vOK # y;
      if (Form_Parse_Lfs:Parse441Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_B', true)<0) then
        VarA('Summe_B')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_C')) then begin
      vOK # y;
      if (Form_Parse_Lfs:Parse441Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_C', true)<0) then
        VarA('Summe_C')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_D')) then begin
      vOK # y;
      if (Form_Parse_Lfs:Parse441Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_D', true)<0) then
        VarA('Summe_D')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_E')) then begin
      vOK # y;
      if (Form_Parse_Lfs:Parse441Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_E', true)<0) then
        VarA('Summe_E')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_F')) then begin
      vOK # y;
      if (Form_Parse_Lfs:Parse441Multi(var vLabels, var vInhalt, var vZusatz, 'Summe_F', true)<0) then
        VarA('Summe_F')
      else
        SetA(vLabels);
    end;
    if (vOK) then CRLF;
    if (UseStyle('Summe_div_C')) then SetLine(2);
    if (UseStyle('Summe_div_D')) then SetLine(3);

  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  EndPrint;

end;


//=======================================================================
//=======================================================================