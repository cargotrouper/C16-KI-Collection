@A+
/*===== Business-Control =================================================

Prozedur:   L_STD_LfsP0003

OHNE E_R_G

Info:
Listenart für Lieferscheinstatistik

Historie:
2022-09-14  SR  Erstellung der Prozedur auf Basis der Prozedur L_STD_LfsP0001

Subprozeduren:

AusSel
StartList

MAIN: Benutzungsbeispiele zum Testen

Tipp: CTRL + SHIFT + G ermöglicht es, per Dropdown Menu zu allen
      subs in einer Prozedur zu springen
========================================================================*/
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


/*========================================================================
Defines
========================================================================*/
define begin
  cName     : 'Wert der Konstante'  // Wozu dient dieses define?
  
  /*
  Alle in einer Prozedur verwendeten Dialoge sind als defines zu nennen und
  innerhalb der Prozedur über das define und nicht den Klarnamen anzusprechen.
  Bsp.: vDlg # Lib_GuiCom:AddChildWindow(gMDI, cDlgSearch, '');
  Vorteile:
  * Wenn ein Dialog umbenannt wird, muss man nur eine Stelle ändern.
  * Man kann leichter die Dialoge zum Prozedurcode finden und umgekehrt.
  */
  cDlgSearch : 'SFX.EcoDMS.Search'

end



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
  Erx         : int;
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
  vNode       : int;
  vItem       : int;
  vMFile      : Int;
  vMID        : Int;
end
begin
  vForm   # 'LfsP0003';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  if (Sel.Fin.nurMarkeYN) then begin
    vNode # vJSON->CteInsertNode('NurLieferscheine', _JsonNodeArray, NULL);

    FOR   vItem # gMarkList->CteRead(_CteFirst);      // erste Element holen
    LOOP  vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
    WHILE (vItem > 0) DO BEGIN
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile<>440) then CYCLE;
      Erx # RecRead(440,0,_RecID, vMID);
      if (Erx<=_rLocked) then
        vNode->CteInsertNode('', _JsonNodeNumber, Lfs.Nummer);
    END;

  end else begin

    AddJsonInt(   vJSON,  'VonLieferschein',        "Sel.Adr.Von.Verband");
    AddJsonInt(   vJSON,  'BisLieferschein',        "Sel.Adr.Bis.Verband");
    AddJsonInt(   vJSON,  'VonBetriebsauftrag',     "Sel.Adr.Von.Vertret");
    AddJsonInt(   vJSON,  'BisBetriebsauftrag',     "Sel.Adr.Bis.Vertret");
    AddJsonInt(   vJSON,  'NurKunde',               "Sel.Adr.Von.Kdnr");
    AddJsonDate(  vJSON,  'VonLieferdatum',         "Sel.von.Datum");
    AddJsonDate(  vJSON,  'BisLieferdatum',         "Sel.bis.Datum");
    AddJsonDate(  vJSON,  'VonRechnungsdatum',      "Sel.von.Datum3");
    AddJsonDate(  vJSON,  'BisRechnungsdatum',      "Sel.bis.Datum3");
    AddJsonDate(  vJSON,  'VonVerbuchungsdatum',    "Sel.von.Datum2");
    AddJsonDate(  vJSON,  'BisVerbuchungsdatum',    "Sel.bis.Datum2");
    AddJsonAlpha( vJSON,  'NurReferenznr',          "Sel.Adr.von.Sachbear");
    AddJsonInt(   vJSON,  'NurZieladresse',         "Sel.Mat.Lagerort");
    AddJsonInt(   vJSON,  'NurZielanschrift',       "Sel.Mat.Lageranschri");
    AddJsonInt(   vJSON,  'NurAuftragsnr',          "Sel.Auf.Von.Nummer");
    AddJsonAlpha( vJSON,  'NurArtikelnr',           "Sel.Art.Von.ArtNr");
    AddJsonInt(   vJSON,  'NurProjektnr',           "Sel.Auf.Von.Projekt");


  end;

  FinishList(vForm, vDesign, var vJSON);
end;


/*========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================*/
MAIN
begin
  RecBufClear(998);

  Sel.Adr.von.KdNr          # 0;
  Sel.bis.Datum             # today;
  Sel.bis.Datum2            # today;
  Sel.bis.Datum3            # today;

  Sel.Adr.bis.Verband       # 9999999;   // Lieferscheinnummer
  Sel.Adr.Bis.Vertret       # 9999999;   // Betriebsauftragsnummer


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.LfsP0003',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Lieferscheinnr',  'Lieferscheinnr',true);
  Sel_Main:AddSort(gMdi, 'Kundennummer',    'Kundennummer');
  Sel_Main:AddSort(gMDI, 'Kommission',      'Kommission');
  Sel_Main:AddSort(gMdi, 'Artikelnr',       'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Materialnr',      'Materialnr');
  Sel_Main:AddSort(gMdi, 'Abmessung',       'Abmessung');
  Sel_Main:AddSort(gMdi, 'Güte, Abmessung', 'Guete, Abmessung');
  Sel_Main:AddSort(gMdi, 'Bemerkung',       'Bemerkung');
  Sel_Main:AddSort(gMdi, 'Lieferdatum',     'Lieferdatum');
  Sel_Main:AddSort(gMdi, 'Verbuchungsdatum','Verbuchungsdatum');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;

// ========================================================================