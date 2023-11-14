@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Ele_BAG
//                      OHNE E_R_G
//  Info
//    Druckelemente für Lohn-BA
//
//
//  13.11.2012  AI  Erstellung der Prozedur
//  03.02.2014  AH  "elEinsatzFuss" und "elFertigungFuss" jetzt dynamisch
//
//  Subprozeduren
//  SUB elSeitenkopf(var aHdl : int; aStartAS : int; aZielAS : int; aKundenAdr : int);
//  SUB elEnde1(var aHdl : int; aStartAS : int; aZielAS : int; aKundenAdr : int);
//  SUB elEnde2(var aHdl : int; aStartAS : int; aZielAS : int; aKundenAdr : int);
//  SUB elEnde3(var aHdl : int; aStartAS : int; aZielAS : int; aKundenAdr : int);
//  SUB elEinsatzUS(var aHdl : int);
//  SUB elEinsatz1(var aHdl : int; aLfdNr : int);
//  SUB elEinsatz2(var aHdl : int; aLfdNr : int);
//  SUB elEinsatzFuss(var aHdl : int);
//  SUB elFertigungUS(var aHdl : int);
//  SUB elFertigung1(var aHdl : int);
//  SUB elFertigung2(var aHdl : int);
//  SUB elFertigungFuss(var aHdl : int);
//  SUB elFertZusatzUS(var aHdl : int;);
//  SUB elFertZusatz(var aHdl : int; aTextName : alpha);
//  SUB elFertZusatzFuss(var aHdl : int);
//  SUB elVerpackungUS(var aHdl : int);
//  SUB elVerpackung1(var aHdl : int);
//  SUB elVerpackung2(var aHdl : int);
//  SUB elVerpackungFuss(var aHdl : int);
//  SUB _Raster(
//  SUB elRasterEinsatz(var aHdl : int);
//  SUB elRasterFertigung(var aHdl : int; aList : int);
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form

define begin
  cLineAbstand : 8000
end;

//=======================================================================
//  elSeitenKopf
//=======================================================================
sub elSeitenkopf(
  var aHdl    : int;
  aStartAS    : int;
  aZielAS     : int;
  aKundenAdr  : int;
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

    if (IsVisible('___ERSTESEITE')=false) then RETURN;
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('ES_A')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', false, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltA');
      SetA(vInhalt);
      CRLF;
    end;

    if (UseStyle('ES_Barcode')) then
      Lib_Form:Barcode_C39(StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                           StrAdj(CnvAi(BAG.P.Position,_FmtNumNoZero | _FmtNumNoGroup,0,2),_StrAll));

    if (UseStyle('ES_B')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', false, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltB');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_C')) then begin;
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', false, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltC');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOk # n;

    if (UseStyle('ES_D')) then begin;
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', false, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltD');
      SetA(vInhalt);
      vOK # y;
    end;
    if (UseStyle('ES_E')) then begin;
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E', false, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      UseStyle('ES_InhaltE');
      SetA(vInhalt);
      vOK # y;
    end;
    if (vOK) then CRLF;
    vOk # n;

    if (UseStyle('ES_div_A')) then SetLine(0);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;


//=======================================================================
// elEnde1
//=======================================================================
sub elEnde1(
  var aHdl    : int;
  aStartAS    : int;
  aZielAS     : int;
  aKundenAdr  : int;
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
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Ende_div_A')) then SetLine(0);
    if (UseStyle('Ende_A')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A', isVisible('Ende_InhaltA')=false, aStartAS, aZielAS, aKundenAdr);
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
  var aHdl    : int;
  aStartAS    : int;
  aZielAS     : int;
  aKundenAdr  : int;
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
    aHdl # CreatePL();  // Init element

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
  var aHdl    : int;
  aStartAS    : int;
  aZielAS     : int;
  aKundenAdr  : int;
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
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_C')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true, aStartAS, aZielAS, aKundenAdr);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_D')) then begin
      Form_Parse_BAG:Parse702Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_D', true, aStartAS, aZielAS, aKundenAdr);
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
    aHdl # CreatePL();  // Init element

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
    if (UseStyle('EinsatzUS_K')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_K', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_L')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_L', true,0);
      SetA(vLabels);
    end;
    if (UseStyle('EinsatzUS_M')) then begin
      Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzUS_M', true,0);
      SetA(vLabels);
    end;

    if (UseStyle('EinsatzUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('EinsatzUS_div_B')) then SetLine(1);

    SetVLineX(1,  'Einsatz_div_V1');
    SetVLineX(2,  'Einsatz_div_V2');
    SetVLineX(3,  'Einsatz_div_V3');
    SetVLineX(4,  'Einsatz_div_V4');
    SetVLineX(5,  'Einsatz_div_V5');
    SetVLineX(6,  'Einsatz_div_V6');
    SetVLineX(7,  'Einsatz_div_V7');
    SetVLineX(8,  'Einsatz_div_V8');
    SetVLineX(9,  'Einsatz_div_V9');
    SetVLineX(10, 'Einsatz_div_V10');
    SetVLineX(11, 'Einsatz_div_V11');
    SetVLineX(12, 'Einsatz_div_V12');
    SetVLineX(13, 'Einsatz_div_V13');
    SetVLineX(14, 'Einsatz_div_V14');
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
  SetVLineStartY(10);
  SetVLineStartY(11);
  SetVLineStartY(12);
  SetVLineStartY(13);
  SetVLineStartY(14);

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
    aHdl # CreatePL();  // Init element

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
    if (UseStyle('Einsatz_1K')) then
      DynA('kkk');
    if (UseStyle('Einsatz_1L')) then
      DynA('lll');
    if (UseStyle('Einsatz_1M')) then
      DynA('mmm');
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
  if (isVisible('Einsatz_1K')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1K', true, aLfdNr);
    FillDynA('kkk',vLabels);
  end;
  if (isVisible('Einsatz_1L')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1L', true, aLfdNr);
    FillDynA('lll',vLabels);
  end;
  if (isVisible('Einsatz_1M')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'Einsatz_1M', true, aLfdNr);
    FillDynA('mmm',vLabels);
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
    aHdl # CreatePL();  // Init element

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
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('EinsatzFuss_div_A')) then SetLine(0);

    if (UseStyle('EinsatzFuss_A')) then
      DynA('aaa');
    if (UseStyle('EinsatzFuss_B')) then
      DynA('bbb');
    if (UseStyle('EinsatzFuss_C')) then
      DynA('ccc');
    if (UseStyle('EinsatzFuss_D')) then
      DynA('ddd');
    CRLF;

    if (UseStyle('EinsatzFuss_div_A')) then SetLine(1);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  if (UseStyle('EinsatzFuss_A')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_A', true,0);
    FillDynA('aaa',vLabels);
  end;
  if (UseStyle('EinsatzFuss_B')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_B', true,0);
    FillDynA('bbb',vLabels);
  end;
  if (UseStyle('EinsatzFuss_C')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_C', true,0);
    FillDynA('ccc',vLabels);
  end;
  if (UseStyle('EinsatzFuss_D')) then begin
    Form_Parse_BAG:Parse701Multi(var vLabels, var vInhalt, var vZusatz, 'EinsatzFuss_D', true,0);
    FillDynA('ddd',vLabels);
  end;
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
  PrintVLinie(10);
  PrintVLinie(11);
  PrintVLinie(12);
  PrintVLinie(13);
  PrintVLinie(14);
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
    aHdl # CreatePL();  // Init element

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
    if (UseStyle('FertigungUS_K')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_K', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_L')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_L', true);
      SetA(vLabels);
    end;
    if (UseStyle('FertigungUS_M')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungUS_M', true);
      SetA(vLabels);
    end;

    if (UseStyle('FertigungUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('FertigungUS_div_B')) then SetLine(1);

    SetVLineX(1,  'Fertigung_div_V1');
    SetVLineX(2,  'Fertigung_div_V2');
    SetVLineX(3,  'Fertigung_div_V3');
    SetVLineX(4,  'Fertigung_div_V4');
    SetVLineX(5,  'Fertigung_div_V5');
    SetVLineX(6,  'Fertigung_div_V6');
    SetVLineX(7,  'Fertigung_div_V7');
    SetVLineX(8,  'Fertigung_div_V8');
    SetVLineX(9,  'Fertigung_div_V9');
    SetVLineX(10, 'Fertigung_div_V10');
    SetVLineX(11, 'Fertigung_div_V11');
    SetVLineX(12, 'Fertigung_div_V12');
    SetVLineX(13, 'Fertigung_div_V13');
    SetVLineX(14, 'Fertigung_div_V14');
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
  SetVLineStartY(10);
  SetVLineStartY(11);
  SetVLineStartY(12);
  SetVLineStartY(13);
  SetVLineStartY(14);
end;


//=======================================================================
//  Fertigung1
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
    aHdl # CreatePL();  // Init element

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
    if (UseStyle('Fertigung_1K')) then
      DynA('kkk');
    if (UseStyle('Fertigung_1L')) then
      DynA('lll');
    if (UseStyle('Fertigung_1M')) then
      DynA('mmm');
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
  if (isVisible('Fertigung_1K')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1K', true);
    FillDynA('kkk',vLabels);
  end;
  if (isVisible('Fertigung_1L')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1L', true);
    FillDynA('lll',vLabels);
  end;
  if (isVisible('Fertigung_1M')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertigung_1M', true);
    FillDynA('mmm',vLabels);
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
    aHdl # CreatePL();  // Init element

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
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('FertigungFuss_div_A')) then SetLine(0);

    if (UseStyle('FertigungFuss_A')) then
      DynA('aaa');
    if (UseStyle('FertigungFuss_B')) then
      DynA('bbb');
    if (UseStyle('FertigungFuss_C')) then
      DynA('ccc');
    if (UseStyle('FertigungFuss_D')) then
      DynA('ddd');

    CRLF;

    if (UseStyle('FertigungFuss_div_A')) then SetLine(1);
  end;  // Design


  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (UseStyle('FertigungFuss_A')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_A', true);
    FillDynA('aaa',vLabels);
  end;
  if (UseStyle('FertigungFuss_B')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_B', true);
    FillDynA('bbb',vLabels);
  end;
  if (UseStyle('FertigungFuss_C')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_C', true);
    FillDynA('ccc',vLabels);
  end;
  if (UseStyle('FertigungFuss_D')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertigungFuss_D', true);
    FillDynA('ddd',vLabels);
  end;
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
  PrintVLinie(10);
  PrintVLinie(11);
  PrintVLinie(12);
  PrintVLinie(13);
  PrintVLinie(14);
end;



//=======================================================================
//  elFertZusatzUS
//=======================================================================
sub elFertZusatzUS(
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

    if (IsVisible('___FERTZUSATZUS')=false) then RETURN;
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------

    if (UseStyle('FertZusatz_Titel')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertzusatz_Titel', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('FertZusatzUS_div_A')) then SetLine(0);

    if (UseStyle('FertZusatzUS_A')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertZusatzUS_A', true)
      SetA(vLabels);
    end;
    if (UseStyle('FertZusatzUS_B')) then begin
      Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'FertZusatzUS_B', true);
      SetA(vLabels);
    end;

    if (UseStyle('FertZusatzUS_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY-3000);
    CRLF;

    if (UseStyle('FertZusatzUS_div_B')) then SetLine(1);

    SetVLineX(1,  'FertZusatz_div_V1');
    SetVLineX(2,  'FertZusatz_div_V2');
    SetVLineX(3,  'FertZusatz_div_V3');
  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
  SetVLineStartY(1);
  SetVLineStartY(2);
  SetVLineStartY(3);
end;


//=======================================================================
//  elFertZusatz
//=======================================================================
sub elFertZusatz(
  var aHdl  : int;
  aTextName : alpha;
);
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
end;
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin

    if (IsVisible('___FERTZUSATZ')=false) then RETURN;
    aHdl # CreatePL();  // Init element

    if (UseStyle('FertZusatz_1A')) then
      DynA('aaa');
//    if (UseStyle('FertZusatz_1B')) then
//      DynA('bbb');

    CRLF;
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  if (isVisible('FertZusatz_1A')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Fertzusatz_1A', true);
    FillDynA('aaa',vLabels);
  end;
  EndPrint;

  if (UseStyle('FertZusatz_1B')) then
    Lib_Print:Print_Textbaustein(aTextName, 0.0, 0.0, Form_StyleX, Form_StyleXX);

end;


//=======================================================================
//  elFertZusatzFuss
//=======================================================================
sub elFertZusatzFuss(
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

    if (IsVisible('___FERTZUSATZFUSS')=false) then RETURN;
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('FertZusatzFuss_div_A')) then SetLine(0);
  end;  // Design

  // PRINT --------------------------------------------------------------------
  PrintVLinie(1);
  PrintVLinie(2);
  PrintVLinie(3);
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
    aHdl # CreatePL();  // Init element

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

    SetVLineX(1,'VPG_div_V1');
    SetVLineX(2,'VPG_div_V2');
    SetVLineX(3,'VPG_div_V3');
    SetVLineX(4,'VPG_div_V4');
    SetVLineX(5,'VPG_div_V5');
    SetVLineX(6,'VPG_div_V6');
    SetVLineX(7,'VPG_div_V7');
    SetVLineX(8,'VPG_div_V8');
    SetVLineX(9,'VPG_div_V9');
    SetVLineX(10,'VPG_div_V10');
    SetVLineX(11,'VPG_div_V11');

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
  SetVLineStartY(10);
  SetVLineStartY(11);

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
    aHdl # CreatePL();  // Init element

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
    aHdl # CreatePL();  // Init element

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
  vOk     : logic;
end;
begin
  // initializing?
  if (aHdl=0) then begin

    if (IsVisible('___VPGFUSS')=false) then RETURN;
    aHdl # CreatePL();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('VPGFuss_div_A')) then SetLine(0);

    if (UseStyle('VPGFuss_A')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_A', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('VPGFuss_B')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_B', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('VPGFuss_C')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_C', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (UseStyle('VPGFuss_D')) then begin
      Form_Parse_BAG:Parse704Multi(var vLabels, var vInhalt, var vZusatz, 'VPGFuss_D', true);
      SetA(vLabels);
      vOK # y;
    end;
    if (vOK) then begin
      CRLF;
      vOK # n;
      if (UseStyle('VPGFuss_div_A')) then SetLine(1);
    end;

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
  PrintVLinie(10);
  PrintVLinie(11);
  StartPrint(aHdl);
  EndPrint;

end;


//=======================================================================
//  _Raster
//=======================================================================
sub _Raster(
  aName : alpha;
  aRow  : int;
  aLine : int) : logic;
local begin
  vLabels : alpha(4096);
  vInhalt : alpha(4096);
  vZusatz : alpha(4096);
  vA      : alpha(4096);
  vToken1 : alpha(4096);
  vToken2 : alpha(4096);
  vVLinie : logic;
end;
begin
  vA # Str_Token(GetCaption(aName), StrChar(13)+StrChar(10), aRow);
  UseStyle(aName);
  if (vA<>'') then begin
    vVLinie # strFind(vA,'|',1)>0;
    if (vVLinie) then
      vA # Str_ReplaceAll(vA, '|', '');
    if (Lib_strings:Strings_Count(vA,'@')>0) then begin
      vToken1 # Str_Token(vA, '@', 1);
      vToken2 # Str_Token(vA, '@', 2);
      Form_Parse_BAG:Parse701(var vLabels, var vInhalt, var vZusatz, vToken2, true, 0);
      vA # vToken1 + vLabels;
    end;
    SetA(vA);
    Form_VLine[aLine]:X # Form_StyleX - cLineAbstand;
  end;

  if (vVLinie) then Form_VLine[aLine]:Y # Pls_PosY + form_Page->ppBoundAdd:y;

  RETURN vVLinie;
end;


//=======================================================================
//  elRasterEinsatz
//=======================================================================
sub elRasterEinsatz(
  var aHdl  : int;
);
local begin
  vA,vB,vRow  : alpha(4096);
  vI,vJ       : int;
  vHdl        : int;
  vMinX,vMaxX : int;
  vLineCount  : int;
  vRowCount   : int;
end;
begin

  FreeElement(var aHdl);
  FOR vI # 1 loop inc(vI) while (vI<=20) do begin
    Form_VLine[vI]:x # -1;
    Form_VLine[vI]:y # -1;
  END;

  if (IsVisible('___RASTEREINSATZ')=false) then RETURN;

  aHdl # CreatePL('Combo');  // Init element

  vMinX # 100000;
  if (UseStyle('Raster1_A')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_B')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_C')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_D')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_E')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_F')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_G')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_H')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_I')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster1_J')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  vMinX # vMinX - cLineAbstand;


  SetLine(0, vMinX, vMaxX);

  // VLinien Y merken...
//  FOR vI # 1 loop inc(vI) while (vI<=11) do
//    Form_VLine[vI]:Y   # Pls_PosY + form_Page->ppBoundAdd:y;

  vLineCount  # 0;
  vRowCount   # 0;
  vA # GetCaption('Raster1_A');
  vJ # 1 + Lib_Strings:Strings_Count(vA, StrChar(13)+StrChar(10));
  FOR vI # 1 loop inc(vI) WHILE (vI<=vJ) do begin

    vA # GetCaption('Raster1_A');
    vRow # Str_Token(vA, StrChar(13)+StrChar(10), vI);
    UseStyle('Raster1_A');
    if (vRow<>'---') then begin
      if (vRow='') then vRow # strchar(255);
      SetA(vRow);
      Form_VLine[1]:X # Form_StyleX - cLineAbstand;
      inc(vRowCount);
      _Raster('Raster1_B',vRowCount, 2);
      _Raster('Raster1_C',vRowCount, 3);
      _Raster('Raster1_D',vRowCount, 4);
      _Raster('Raster1_E',vRowCount, 5);
      _Raster('Raster1_F',vRowCount, 6);
      _Raster('Raster1_G',vRowCount, 7);
      _Raster('Raster1_H',vRowCount, 8);
      _Raster('Raster1_I',vRowCount, 9);
      _Raster('Raster1_J',vRowCount,10);
      _Raster('Raster1_K',vRowCount,11);
      CRLF;
      end
    else begin
      inc(vLineCount);
      SetLine(vLineCount, vMinx, vMaxX);
    end;

  END;


  // PRINT --------------------------------------------------------------------
  // ist genug Platz vorhanden?
  Lib_Print:FFifNoSpace(pls_Prt);
  FOR vI # 1 loop inc(vI) while (vI<=20) do
    if (Form_VLine[vI]:X>=0) then SetVLineStartY(vI);

  StartPrint(aHdl);
  EndPrint;

  FOR vI # 1 loop inc(vI) while (vI<=11) do begin
    PrintVLinie(vI);
  END;

  FreeElement(var aHdl);

end;


//=======================================================================
//  elRasterFertigung
//=======================================================================
sub elRasterFertigung(
  var aHdl  : int;
  aList     : int;
);
local begin
  vLabels     : alpha(4096);
  vInhalt     : alpha(4096);
  vZusatz     : alpha(4096);
  vI          : int;
  vItem       : int;
  vMinX,vMaxX : int;
end;
begin

  FreeElement(var aHdl);
  FOR vI # 1 loop inc(vI) while (vI<=20) do begin
    Form_VLine[vI]:x # -1;
    Form_VLine[vI]:y # -1;
  END;

  if (IsVisible('___RASTEREINSATZ')=false) then RETURN;

  aHdl # CreatePL('Combo_20Div');  // Init element

  vMinX # 100000;
  if (UseStyle('Raster2_A')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster2_B')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  if (UseStyle('Raster2_C')) then begin
    vMinX # Min(vMinX, Form_StyleX);
    vMaxX # Max(vMaxX, Form_StyleXX);
  end;
  vMinX # vMinX - cLineAbstand;

  SetLine(0, vMinX, vMaxX);

  if (UseStyle('Raster2_A')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Raster2_A', y);
    SetA(vLabels);
    Form_VLine[1]:X # Form_StyleX - cLineAbstand;
  end;
  if (UseStyle('Raster2_B')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Raster2_B', y);
    SetA(vLabels);
    Form_VLine[2]:X # Form_StyleX - cLineAbstand;
  end;
  if (UseStyle('Raster2_C')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Raster2_C', y);
    SetA(vLabels);
    Form_VLine[3]:X # Form_StyleX - cLineAbstand;
  end;
  if (UseStyle('Raster2_D')) then begin
    Form_Parse_BAG:Parse703Multi(var vLabels, var vInhalt, var vZusatz, 'Raster2_D', y);
    SetA(vLabels);
    Form_VLine[4]:X # Form_StyleX - cLineAbstand;
  end;

  // VLinien Y merken...
//  FOR vI # 1 loop inc(vI) while (vI<=20) do
//    if (Form_VLine[vI]:X>=0) then Form_VLine[vI]:Y # 0;
//    if (Form_VLine[vI]:X>=0) then SetVLineStartY(vI);

  CRLF;

  SetLine(1, vMinX, vMaxX);

  if (UseStyle('Raster2_A')) then begin
    vI # 1;
    FOR vItem # CteRead(aList, _CteFirst)
    loop vItem # CteRead(aList, _cteNext, vItem)
    WHILE (vItem<>0) do begin
      SetA(vItem->spcustom);
      CRLF;
      SetA(' ');
      CRLF;
      SetLine(vI, vMinX, vMaxX);
      inc(vI);
    END;
  end;

  // PRINT --------------------------------------------------------------------

  // ist genug Platz vorhanden?
  Lib_Print:FFifNoSpace(pls_Prt);
  FOR vI # 1 loop inc(vI) while (vI<=20) do
    if (Form_VLine[vI]:X>=0) then SetVLineStartY(vI);

  StartPrint(aHdl);
  EndPrint;

  FOR vI # 1 loop inc(vI) while (vI<=11) do begin
    PrintVLinie(vI);
  END;

  FreeElement(var aHdl);

end;


//=======================================================================
//=======================================================================