@A+
/*===== Business-Control =================================================

Prozedur:   L_STD_Sta0001

OHNE E_R_G

Info:
Erster Versuch für die neue Selektion

Historie:
2022-09-23  SR  Erstellung der Prozedur

Subprozeduren:

prozedurnameInCamelCase
_privateProzedur
AFX.eineAnkerfunktion
SFX.eineSonderfunktion

MAIN: Benutzungsbeispiele zum Testen

Tipp: CTRL + SHIFT + G ermöglicht es, per Dropdown Menu zu allen
      subs in einer Prozedur zu springen
========================================================================*/
@I:Def_Global


/*========================================================================
Defines
========================================================================*/
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



/*========================================================================
AusSel
========================================================================*/
sub AusSel();
begin
  gSelected # 0;
  StartList(Sel.Sortierung);
end;

/*========================================================================
StartList
========================================================================*/

sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin
  vForm   # 'Sta0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'NurKundenNr',          "Sel.Adr.Von.Kdnr");
  AddJsonInt(   vJSON,  'VonRechnungsnummer',   "Sel.Fin.von.Rechnung");
  AddJsonInt(   vJSON,  'BisRechnungsnummer',   "Sel.Fin.bis.Rechnung");
  AddJsonDate(  vJSON,  'VonRechnungsdatum',    "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',    "Sel.bis.Datum");
  AddJsonInt(   vJSON,  'NurVertreterNr',       "Sel.Adr.von.Vertret");
  AddJsonInt(   vJSON,  'NurVerbandNr',         "Sel.Adr.von.Verband");
  AddJsonInt(   vJSON,  'VonVorgangsart',       "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'BisVorgangsart',       "Sel.Auf.bis.AufArt");
  AddJsonAlpha( vJSON,  'NurGuete',             "Sel.Auf.Güte");
  AddJsonFloat( vJSON,  'VonDicke',             "Sel.Auf.von.Dicke");
  AddJsonFloat( vJSON,  'BisDicke',             "Sel.Auf.bis.Dicke");
  AddJsonFloat( vJSON,  'VonBreite',            "Sel.Auf.von.Breite");
  AddJsonFloat( vJSON,  'BisBreite',            "Sel.Auf.bis.Breite");

  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitGeloeschten',       "Sel.Fin.StornosYN");
  AddJsonBool(  vJSON,  'MitGutBel',            "Sel.Fin.GutschriftYN");
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

/*========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================*/
MAIN
begin
  RecBufClear(998);
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.bis.Datum           # today;
  //Sel.Fin.StornosYN
  //Sel.Fin.GutschriftYN

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Sta0001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Kundennummer',          'Kundennr');
  Sel_Main:AddSort(gMdi, 'Kundenstichwort',       'KundenSW');
  Sel_Main:AddSort(gMDI, 'Rechnungsnr.',          'Rechnungsnr', true);
  Sel_Main:AddSort(gMdi, 'Rechnungsdatum',        'Rechnungsdatum');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;

// ========================================================================