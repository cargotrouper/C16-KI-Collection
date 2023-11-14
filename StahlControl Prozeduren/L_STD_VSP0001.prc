@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_VSP0001
//                    OHNE E_R_G
//  Info
//
//  08.10.2021 Erstelleung der Prozedur ST
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

//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.VsP.BisTermin # 31.12.2099;
  
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.VSP0001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Termin Min.',             'TerminMin',true);
  Sel_Main:AddSort(gMdi, 'Termin Max.',             'TerminMax');
  Sel_Main:AddSort(gMdi, 'Spediteurstw',          'SpediteurSW');
  Sel_Main:AddSort(gMdi, 'Auftragsnr',            'Auftragsnr');
  Sel_Main:AddSort(gMdi, 'Materialnr',            'Materialnr');
  Sel_Main:AddSort(gMdi, 'Artikelnr',             'Artikelnr');
  Sel_Main:AddSort(gMDI, 'Startanschrift',        'Startanschrift');
  Sel_Main:AddSort(gMDI, 'Zielanschrift',         'Zielanschrift');
  Sel_Main:AddSort(gMdi, 'Lagerplatz',            'Lagerplatz');
  
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
  
  vNode       : int;
  vMarked     : int;
  vMarkedItem   : int;          // Descriptor für markierten Eintrag
  vMFile        : int;  // Markierungen
  vMID          : int;  // Markierungen
end
begin
  vForm   # 'VSP0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'NurKundenNr',  "Sel.Auf.Kundennr");
  AddJsonDate(  vJSON,  'VonTermin',    "Sel.VsP.VonTermin");
  AddJsonDate(  vJSON,  'BisTermin',    "Sel.VsP.BisTermin");
  AddJsonInt(   vJSON,  'NurAbholadresse',    Sel.VsP.VonAdresse);
  AddJsonInt(   vJSON,  'NurAbholanschrift',  Sel.VsP.VonAnschrift);
  AddJsonInt(   vJSON,  'NurZieladresse',    Sel.VsP.NachAdresse);
  AddJsonInt(   vJSON,  'NurZielanschrift',  Sel.VsP.NachAnschrif);
  AddJsonBool(  vJSON,  'MitTheorie',       "Sel.VsP.MitTheorie");
  
  if ("Sel.Fin.NurMarkeYN") then begin
    
    if (Lib_Mark:Count(655) = 0) then begin
      Msg(001013,'',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;

    vNode # vJSON->CteInsertNode('Markierte',  _JsonNodeArray, NULL);

    FOR  vMarked # gMarkList->CteRead(_CteFirst);
    LOOP vMarked # gMarkList->CteRead(_CteNext,vMarked);
    WHILE (vMarked > 0) DO BEGIN
      Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);
      if (vMFile <> 655) then
        CYCLE;
      RecRead(655,0,_RecId,vMID);
      vNode->CteInsertNode('Nummer', _JsonNodeNumber, VsP.Nummer);
    END;

  end;

  
  
  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================
