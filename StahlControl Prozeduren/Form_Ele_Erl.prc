@A+
//===== Business-Control =================================================
//
//  Prozedur    Foem_Ele_Erl
//                      OHNE E_R_G
//  Info
//    Enthält Formatdefinitionen für Formulare aus den Erlösen
//
//
//  12.09.2013  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub elGelErsteSeite(    var aHdl : int;  );
//    sub elGelFolgeSeite(    var aHdl : int;  );
//    sub elGelUeberschrift(  var aHdl : int;  );
//    sub elGelRechnung(      var aHdl : int;  );
//    sub elGelEnde(          var aHdl : int;  );
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_Form


//=======================================================================
//  elGelErsteSeite
//=======================================================================
sub elGelErsteSeite( var aHdl    : int;  );
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

    if (Usestyle('ES_A')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_A', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_B')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_B', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_div_A')) then SetLine(0);
    // ===============================================================================================

    if (Usestyle('ES_C')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_C', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_D')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_D2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_D2', true);
      SetA(vLabels);
      CRLF;
    end;


    if (UseStyle('ES_div_B')) then SetLine(1);
    // ===============================================================================================

    if (Usestyle('ES_E1')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E1', true);
      SetA(vLabels);
    end;
    if (Usestyle('ES_E2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_E2', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_F')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_F', true);
      SetA(vLabels);
      CRLF;
    end;


    if (UseStyle('ES_div_C')) then SetLine(2);
    // ===============================================================================================


    if (Usestyle('ES_G')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_G', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_H')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_H', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_div_D')) then SetLine(3);
    // ---------------------------------------------------------------------------------------------

    if (Usestyle('ES_I')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_I', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_J')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_J', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_div_E')) then SetLine(4);
    // ---------------------------------------------------------------------------------------------


     if (Usestyle('ES_K')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_K', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_L')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_L', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_div_F')) then SetLine(5);
    // ---------------------------------------------------------------------------------------------


     if (Usestyle('ES_M')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_M', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_N')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_N', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_div_G')) then SetLine(6);
    // ---------------------------------------------------------------------------------------------


     if (Usestyle('ES_O')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_O', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_P')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_P', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('ES_div_H')) then SetLine(7);
    // ---------------------------------------------------------------------------------------------


    if (Usestyle('ES_Q')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_Q', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_R')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_R', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('ES_div_I')) then SetLine(8);
    // ---------------------------------------------------------------------------------------------

   if (Usestyle('ES_S')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_s', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('ES_T')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'ES_T', true);
      SetA(vLabels);
      CRLF;
    end;

  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  EndPrint;
end;



//=======================================================================
//  elGelFolgeSeite
//=======================================================================
sub elGelFolgeSeite(
  var aHdl    : int;
)
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
    if (Usestyle('FS_A')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_A', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('FS_B1')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B1', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('FS_B2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B2', true);
      DynA('aaa');
      CRLF;
    end;

    if (UseStyle('FS_div_A')) then SetLine(0);
    // ===============================================================================================


    if (Usestyle('FS_C')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_C', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('FS_D')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D', true);
      SetA(vLabels);
      CRLF;
    end;
    if (Usestyle('FS_D2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_D2', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('FS_div_B')) then SetLine(1);
    // ===============================================================================================

    if (Usestyle('FS_E1')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E1', true);
      SetA(vLabels);
    end;
    if (Usestyle('FS_E2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_E2', true);
      SetA(vLabels);
      CRLF;
    end;

    if (Usestyle('FS_F')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_F', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('FS_div_C')) then SetLine(2);
    // ===============================================================================================


  end;  // Design

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);

  if (isVisible('FS_B2')) then begin
    if (Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'FS_B2', false)>=0) then
      FillDynA('aaa',vInhalt);
  end;


  EndPrint;
end;



//=======================================================================
//  elGelUeberschrift
//=======================================================================
sub elGelUeberschrift(
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
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_A', true);
      SetA(vLabels);
      // <<< MUSTER >>>
      // SetVLinieStartX(1) # Form_StyleX;
    end;
    if (UseStyle('US_B')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_B', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_C')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_C', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_D')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_D', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_E')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_E', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_F')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_F', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_G')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_G', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_H')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_H', true);
      SetA(vLabels);
    end;
    CRLF;
    // ---------------------- Zweite Zeile

    if (UseStyle('US_A2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_A2', true);
      SetA(vLabels);
      // <<< MUSTER >>>
      // SetVLinieStartX(1) # Form_StyleX;
    end;
    if (UseStyle('US_B2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_B2', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_C2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_C2', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_D2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_D2', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_E2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_E2', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_F2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_F2', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_G2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_G2', true);
      SetA(vLabels);
    end;
    if (UseStyle('US_H2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'US_H2', true);
      SetA(vLabels);
    end;

/*
    if (UseStyle('US_Box')) then
      SetBox(form_StyleX, form_StyleXX, form_StyleBkg, form_StyleYY-Form_StyleY);
*/
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
//  elGelRechnung
//=======================================================================
sub elGelRechnung(
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
    if (IsVisible('___AKTION')=false) then RETURN;
    aHdl # Lib_PrintLine:Create();  // Init element
    CRLF;
    if (UseStyle('Re_A')) then
      DynA('aaa');
    if (UseStyle('Re_B')) then
      DynA('bbb');
    if (UseStyle('Re_C')) then
      DynA('ccc');
    if (UseStyle('Re_D')) then
      DynA('ddd');
    if (UseStyle('Re_E')) then
      DynA('eee');
    if (UseStyle('Re_F')) then
      DynA('fff');
    if (UseStyle('Re_G')) then
      DynA('ggg');
    if (UseStyle('Re_H')) then
      DynA('hhh');
    CRLF;

    if (UseStyle('Re_div_A')) then SetLine(0);
  end;  // ...DESIGN

  // PRINT --------------------------------------------------------------------
  StartPrint(aHdl);
  if (isVisible('Re_A')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_A', true);
    FillDynA('aaa',vLabels)
  end;

  if (isVisible('Re_B')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_B', true);
    FillDynA('bbb',vLabels)
  end;

  if (isVisible('Re_C')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_C', true);
    FillDynA('ccc',vLabels)
  end;

  if (isVisible('Re_D')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_D', true);
    FillDynA('ddd',vLabels)
  end;

  if (isVisible('Re_E')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_E', true);
    FillDynA('eee',vLabels)
  end;

  if (isVisible('Re_F')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_F', true);
    FillDynA('fff',vLabels)
  end;

  if (isVisible('Re_G')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_G', true);
    FillDynA('ggg',vLabels)
  end;

  if (isVisible('Re_H')) then begin
    Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Re_H', true);
    FillDynA('hhh',vLabels)
  end;

  EndPrint;
end;



//=======================================================================
//  elGelEnde
//=======================================================================
sub elGelEnde(
  var aHdl    : int;
)
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

    if (UseStyle('Ende_A1')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A1', true);
      SetA(vLabels);
    end;
    if (UseStyle('Ende_A2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A2', true);
      SetA(vLabels);
    end;
    if (UseStyle('Ende_A3')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A3', true);
      SetA(vLabels);
    end;
    if (UseStyle('Ende_A4')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A4', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_A5')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_A5', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_B')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_B', true);
      SetA(vLabels);
      CRLF;
    end;

    // ----------------------------------------------------------------------------
    if (UseStyle('Ende_div_B')) then SetLine(1);

    if (UseStyle('Ende_C')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_C', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_D')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_D', true);
      SetA(vLabels);
      CRLF;
    end;


    // ----------------------------------------------------------------------------
    if (UseStyle('Ende_div_C')) then SetLine(2);

    if (UseStyle('Ende_E')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_E', true);
      SetA(vLabels);
      CRLF;
    end;
    if (UseStyle('Ende_F')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_F', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_G')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_G', true);
      SetA(vLabels);
      CRLF;
    end;

    if (UseStyle('Ende_G2')) then begin
      Form_Parse_Erl:Parse450Multi(var vLabels, var vInhalt, var vZusatz, 'Ende_G2', true);
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