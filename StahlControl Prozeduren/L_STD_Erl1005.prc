@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Erl1005
//                    OHNE E_R_G
//  Info  Finanzstatus
//
//
//  14.09.2021 SR SQL-Umänderung (Kopie von L_STD_Erl0005)
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
define begin
  OpenJSON      : Lib_JSON:OpenJson
  AddJSONInt    : Lib_JSON:AddJSONInt
  AddJSONAlpha  : Lib_JSON:AddJSONAlpha
  AddJSONDate   : Lib_JSON:AddJSONDate
  AddJSONFloat  : Lib_JSON:AddJSONFloat
  AddJSONBool   : Lib_JSON:AddJSONBool
  SaveXLS       : F_SQL:SaveXLS
  Print         : F_SQL:Print
  FinishList    : F_SQL:FinishList
end;

declare StartList(aSort : alpha);

local begin
  vDatVon     : date;
  vDatBis     : date;
  vZukunft    : logic;
  vDetailed   : logic;
  vDauerFrist : int;
  vKontostand : float;
  vUstTag     : int;
end;



//========================================================================
//
//
//========================================================================
MAIN
begin

  TODO('Work in Progress');
  RecBufClear(998);

  vDatVon   # today;
  vDatBis   # today;

  vDatBis->vpDay     # 1;
  vDatBis->vmMonthModify( 1 );
  if ( vDatBis->vpMonth <  4 ) then
    vDatBis->vpMonth #  4;
  else if ( vDatBis->vpMonth <  7 ) then
    vDatBis->vpMonth #  7;
  else if ( vDatBis->vpMonth < 10 ) then
    vDatBis->vpMonth # 10;
  else begin
    vDatBis->vpMonth # 1;
    vDatBis->vpYear  # vDatBis->vpYear + 1;
  end;
  vDatBis->vmDayModify( -1 );

  Sel.von.Datum # vDatVon;
  Sel.bis.Datum # vDatBis;
  "Sel.Fin.nurMarkeYN"  # true; // Ausführliche Liste
  "Sel.Fin.GelöschteYN" # true;  // erfasste Aufträge und Bestellungen
  Sel.von.monat         # 15;
  Sel.Bis.monat         # 2;


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Erl1005',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Datum',          'Datum',true);
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
begin
  gSelected # 0;
  StartList(Sel.Sortierung);
end;


//========================================================================
//
//========================================================================
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJsonDate(  vJSON,  'DatumVon',       "Sel.von.Datum");
  AddJsonDate(  vJSON,  'DatumBis',       "Sel.bis.Datum");
  AddJsonFloat( vJSON,  'Kontostand',     "Sel.von.Menge");
  AddJsonInt(   vJSON,  'UStZahltag',     "Sel.von.Monat");
  AddJsonInt(   vJSON,  'UStFristverl',   "Sel.bis.Monat");
  AddJsonFloat( vJSON,  'SteuerfreieDB',  "Sel.bis.Menge");
  AddJsonBool(  vJSON,  'MitDetail',      "Sel.Fin.nurMarkeYN");
  AddJsonBool(  vJSON,  'MitAufUndEin',   "Sel.Fin.GelöschteYN");

  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================