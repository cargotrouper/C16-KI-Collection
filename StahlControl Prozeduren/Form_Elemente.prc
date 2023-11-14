@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Elemente
//                  OHNE E_R_G
//  Info
//    allgemeine Druckelemente
//
//
//  23.10.2012  AI  Erstellung der Prozedur
//  27.05.2013  ST  Schlüsselwerte in Texten hinzugefügt
//  30.01.2014  AH  FooterHöhe wird mit Buffer ermittelt
//  01.02.2018  TM  Mehrsprachigkeit für Texte
//
//  Subprozeduren
//    SUB elKopfText(var aHdl : int; aName : alpha);
//    SUB elFussText(var aHdl : int; aName : alpha);
//    SUB elPosText(var aHdl : int; aTextName : alpha);
//    SUB elSumme(var aHdl : int; opt aGesamtNetto : float;opt aMwStSatz1 : float;opt aMwStWert1 : float; opt aMwStSatz2 : float; opt aMwStWert2 : float; opt aGesamtBrutto : float);
//    SUB elSeitenFuss(var aHdl : int; aPrint : logic;opt aSum1 : float;opt aSum2 : float;opt aSum3 : float;);
//    SUB elLeerZeile(var aHdl : int);
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form

//=======================================================================
//  elKopfText
//=======================================================================
sub elKopfText(
  var aHdl  : int;
  aName     : alpha;
  opt aKeyWordStart : alpha;
  opt aKeyWordEnd   : alpha;
  opt aBadWordStart : alpha;
  opt aBadWordEnd   : alpha;
  );
  local begin
    vSprache : int;
  end;

  begin


  case Adr.Sprache of
    Set.Sprache1.Kurz : vSprache  # 1;
    Set.Sprache2.Kurz : vSprache  # 2;
    Set.Sprache3.Kurz : vSprache  # 3;
    Set.Sprache4.Kurz : vSprache  # 4;
    Set.Sprache5.Kurz : vSprache  # 5;
    otherwise vSprache    # 1;
  end;

  if (UseStyle('ES_Kopftext')) then begin
    if (aKeyWordStart <> '') then
      // Print_TextByKeyWords(vTxtName, '$$RE', 'RE$$', cPosCL, cPosCR, '$$AB;$$LFS', 'AB$$;LFS$$', true); // Rechnungstext
      Lib_Print:Print_TextByKeyWordsStyle(aName,vSprache,aKeyWordStart,aKeyWordEnd,true,aBadWordStart,aBadWordEnd);
    else
      PrintText(aName,1);
  end;
end;


//=======================================================================
//  elFussText
//=======================================================================
sub elFussText(
  var aHdl  : int;
  aName     : alpha;
  opt aKeyWordStart : alpha;
  opt aKeyWordEnd   : alpha;
  opt aBadWordStart : alpha;
  opt aBadWordEnd   : alpha;
);
local begin
  vSprache : int;
end;

begin
  
  vSprache  # 1;
  // if (1 = 2) then begin
  //   case Adr.Sprache of
  //     Set.Sprache1.Kurz : vSprache  # 1;
  //     Set.Sprache2.Kurz : vSprache  # 2;
  //     Set.Sprache3.Kurz : vSprache  # 3;
  //     Set.Sprache4.Kurz : vSprache  # 4;
  //     Set.Sprache5.Kurz : vSprache  # 5;
  //     otherwise vSprache    # 1;
  //   end;
  // end;
  if (UseStyle('Ende_Fusstext')) then begin
    if (aKeyWordStart <> '') then
      // Print_TextByKeyWords(vTxtName, '$$RE', 'RE$$', cPosCL, cPosCR, '$$AB;$$LFS', 'AB$$;LFS$$', true); // Rechnungstext
      Lib_Print:Print_TextByKeyWordsStyle(aName,1,aKeyWordStart,aKeyWordEnd,true,aBadWordStart,aBadWordEnd);
    else
      PrintText(aName,1);
  end;
end;


//=======================================================================
//  elPosText
//=======================================================================
sub elPosText(
  var aHdl  : int;
  aTextName : alpha;
  opt aKeyWordStart : alpha;
  opt aKeyWordEnd   : alpha;
  opt aBadWordStart : alpha;
  opt aBadWordEnd   : alpha;
  );

local begin
  vSprache : int;
end;

begin

  case Adr.Sprache of
    Set.Sprache1.Kurz : vSprache  # 1;
    Set.Sprache2.Kurz : vSprache  # 2;
    Set.Sprache3.Kurz : vSprache  # 3;
    Set.Sprache4.Kurz : vSprache  # 4;
    Set.Sprache5.Kurz : vSprache  # 5;
    otherwise vSprache    # 1;
  end;

  if StrCut(aTextName,2,3) != '837' then
    vSprache #1;
  
  if (UseStyle('PosText')) then begin

    if (aKeyWordStart <> '') then
      // Print_TextByKeyWords(vTxtName, '$$RE', 'RE$$', cPosCL, cPosCR, '$$AB;$$LFS', 'AB$$;LFS$$', true); // Rechnungstext
      Lib_Print:Print_TextByKeyWordsStyle(aTextname,vSprache,aKeyWordStart,aKeyWordEnd,true,aBadWordStart,aBadWordEnd);
    else
      PrintText(aTextName,vSprache);
  end;
end;


//=======================================================================
//  elSumme
//=======================================================================
sub elSumme(
  var aHdl          : int;
  opt aGesamtNetto  : float;
  opt aMwStSatz1    : float;
  opt aMwStWert1    : float;
  opt aMwStSatz2    : float;
  opt aMwStWert2    : float;
  opt aGesamtBrutto : float;
);
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
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Summe_A', true)<0) then
        VarA('Summe_A')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_B')) then begin
      vOK # y;
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Summe_B', true)<0) then
        VarA('Summe_B')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_C')) then begin
      vOK # y;
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Summe_C', true)<0) then
        VarA('Summe_C')
      else
        SetA(vLabels);
    end;
    if (UseStyle('Summe_NettoTitel')) then begin
      vOK # y;
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Summe_NettoTitel', true)<0) then
        VarA('Summe_Nettotitel')
      else
        SetA(vLabels);
    end;

    if (UseStyle('Summe_Netto')) then begin
      vOK # y;
      DynA('GesamtNetto');
    end;
    if (vOK) then CRLF;
    vOK # n;

    if (UseStyle('Summe_MwStSatz')) then begin
      DynA('MwStSatz1');
      UseStyle('Summe_MwSt');
      DynA('MwstWert1');
      CRLF;

      if (aMwStSatz2>-1.0) then begin
        UseStyle('Summe_MwSt');
        DynA('MwStSatz2');
        UseStyle('Summe_MwSt');
        DynA('MwStWert2');
        CRLF;
      end;
    end;

    if (UseStyle('Summe_div_C')) then SetLine(2);
    if (UseStyle('Summe_div_D')) then SetLine(3);

    if (UseStyle('Summe_BruttoTitel')) then begin

      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Summe_BruttoTitel', true)<0) then
        VarA('Summe_BruttoTitel')
      else
        SetA(vLabels);
      UseStyle('Summe_Brutto');
      DynA('GesamtBrutto');
      CRLF;
    end;

    if (UseStyle('Summe_div_E')) then SetLine(4);
    if (UseStyle('Summe_div_F')) then SetLine(5);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------

  StartPrint(aHdl);
  if (IsVisible('Summe_Netto')) then
    FillDynA('GesamtNetto',anum(aGesamtNetto,2));

  if (IsVisible('Summe_MwStSatz')) then
    FillDynA('MwStSatz1',ANum(aMwstSatz1,1) + '% MwSt. '+ "Wae.Kürzel");

  if (IsVisible('Summe_MwSt')) then
    FillDynA('MwstWert1',anum(aMwStWert1,2));
  if (aMwStSatz2>-1.0) then begin
    if (IsVisible('Summe_MwStSatz')) then
      FillDynA('MwStSatz2',ANum(aMwstSatz2,1) + '% MwSt. '+ "Wae.Kürzel");
    if (IsVisible('Summe_MwSt')) then
      FillDynA('MwstWert2',anum(aMwStWert2,2));
  end;

  if (IsVisible('Summe_Brutto')) then
    FillDynA('GesamtBrutto',anum(aGesamtBrutto,2));

  EndPrint;

end;


//=======================================================================
//  elSeitenFuss
//=======================================================================
sub elSeitenFuss(
  var aHdl      : int;
  aPrint        : logic;
  opt aSum1     : float;
  opt aSum2     : float;
  opt aSum3     : float;
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

    if (IsVisible('___SEITENFUSS')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element

    // DESIGN -----------------------------------------------------------------
    if (UseStyle('SeitenFuss_div_A')) then SetLine(0);

    if (UseStyle('Seitenfuss_A')) then begin
      vOK # y;
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Seitenfuss_A', true)<0) then
        VarA('Seutenfuss_A')
      else
        DynA('aaa');
    end;
    if (UseStyle('Seitenfuss_B')) then begin
      vOK # y;
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Seitenfuss_B', true)<0) then
        VarA('Seutenfuss_B')
      else
        DynA('bbb');
    end;
    if (UseStyle('Seitenfuss_C')) then begin
      vOK # y;
      if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Seitenfuss_C', true)<0) then
        VarA('Seutenfuss_C')
      else
        DynA('ccc');
    end;
    if (Usestyle('Seitenfuss_Sum1')) then begin
      vOK # y;
      DynA('sum1');
    end;
    if (vOK) then CRLF;

    if (UseStyle('SeitenFuss_div_B')) then SetLine(1);

    // Höhe merken
    Form_FooterH # cnvif(cnvfi(pls_Posy) * 1.2);  // +20% "Buffer" AH 30.01.2014

  end;  // Design
  if (aPrint=false) then RETURN;

  // PRINT --------------------------------------------------------------------
  // <<< MUSTER >>>
  //PrintVLinie(1);

  StartPrint(aHdl);
  if (isVisible('Seitenfuss_A')) then
    if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Seitenfuss_A', true)>=0) then
      FillDynA('aaa',vLabels);
  if (isVisible('Seitenfuss_B')) then
    if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Seitenfuss_B', true)>=0) then
      FillDynA('bbb',vLabels);
  if (isVisible('Seitenfuss_C')) then
    if (ParseAllgemeinMulti(var vLabels, var vInhalt, var vZusatz, 'Seitenfuss_C', true)>=0) then
      FillDynA('ccc',vLabels);

  if (isVisible('Seitenfuss_Sum1')) then begin
    FillDynA('sum1', anum(aSum1,2));
  end;
  EndPrint;
end;


//=======================================================================
//  elLeerZeile
//=======================================================================
sub elLeerZeile(
  var aHdl  : int;
);
begin

  // DESIGN -----------------------------------------------------------------
  if (aHdl=0) then begin
    aHdl # Lib_PrintLine:Create();  // Init element
    Form_StyleX # 0;
    Form_StyleXX # 1;
    Form_STyleBkg # _WinColTransparent;
    Form_STyleCol # _WinColTransparent;
    SetA(' ');
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;



//=======================================================================
//=======================================================================