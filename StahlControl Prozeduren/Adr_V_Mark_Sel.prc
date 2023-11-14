@A+
//===== Business-Control =================================================
//
//  Prozedur    Adr_V_Mark_Sel
//                  OHNE E_R_G
//  Info        Selektierte Materialien ausgeben
//
//  04.07.2011  TM  Erstellung der Prozedur (Kopie aus Mat_Mark_Sel)
//
//  Subprozeduren
//    SUB AusSel();
//
//========================================================================
@I:Def_Global

//========================================================================
//  Main
//
//========================================================================
MAIN (
  opt aSelName    : alpha);
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
end;
begin

  RecBufClear(998);
  Sel.Mat.von.Wgr         # 0;
  Sel.Mat.bis.WGr         # 9999;
  Sel.Mat.bis.Status      # 999;
  Sel.Mat.bis.Dicke       # 999999.00;
  Sel.Mat.bis.Breite      # 999999.00;
  "Sel.Mat.bis.Länge"     # 999999.00;
  "Sel.Mat.bis.ÜDatum"    # today;
  "Sel.Mat.bis.EDatum"    # today;
  "Sel.Mat.bis.ADatum"    # today;
  "Sel.von.Datum"         # 0.0.0;
  "Sel.Mat.EigenYN"       # y;
  "Sel.Mat.ReservYN"      # y;
  "Sel.Mat.BestelltYN"    # y;
  "Sel.Mat.!EigenYN"      # y;
  "Sel.Mat.!ReservYN"     # y;
  "Sel.Mat.!BestelltYN"   # y;
  "Sel.Mat.KommissionYN"  # y;
  "Sel.MAt.!KommissioYN"  # y;
  Sel.Mat.von.Obfzusat    # 'zzzzz';
  "Sel.Mat.bis.ZugFest"   # 9999.0;
  "Sel.Art.bis.ArtNr"     # 'zzzzz';
  "Sel.Mat.Mit.Gelöscht"  # !Filter_Mat;

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Adr.Verpackung',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Adr.Verpackung',here+':AusSel');
  end;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(
  aFilter   : logic;
);
local begin
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  vQ1       : alpha(4000);
  vQ2       : alpha(4000);
  vQ3       : alpha(4000);
  Erx       : int;
  vPostFix  : alpha;
end;
begin
  vList # gZLList;

  // BESTAND-Selektion
  vQ  # '';
  vQ1 # '';
  vQ2 # '';
  vQ3 # '';

  // Nur für aktuelle Adresse
  Erx # RecRead(100,1,0);
  Lib_Sel:QVonBisI(var vQ, '"Adr.V.AdressNr"',         "Adr.Nummer", "Adr.Nummer");

  // Variable Selektionsdaten
  if ("Sel.Mat.von.Dicke"  != 0.0) or ("Sel.Mat.bis.Dicke"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Adr.V.Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke");
  if ("Sel.Mat.von.Breite" != 0.0) or ("Sel.Mat.bis.Breite" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Adr.V.Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite");
  if ("Sel.Mat.von.Länge"  != 0.0) or ("Sel.Mat.bis.Länge"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Adr.V.Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge");

  if ("Sel.Mat.von.WGr"    != 0) or ("Sel.Mat.bis.WGr"    != 9999) then
    Lib_Sel:QVonBisI(var vQ, '"Adr.V.Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr");
  if ("Sel.Mat.Güte" != '') then
    Lib_Sel:QAlpha(var vQ, '"Adr.V.Güte"', '=*', "Sel.Mat.Güte");
  if ("Sel.Mat.Gütenstufe" != '') then
    Lib_Sel:QAlpha(var vQ, '"Adr.V.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");

  if (Sel.Mat.ObfNr != 0) then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'LinkCount(Ausf) > 0';
  end;

  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ1, 'Adr.V.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2);


  vSel # SelCreate(105, 1);
  vSel->SelAddLink('', 106, 105, 1, 'Ausf');


  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ1);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
  end
  else begin  // Markierung...

    Erx # RecRead(105,vSel,_recFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      Lib_Mark:MarkAdd(105,y,y);
      Erx # RecRead(105,vSel,_recNext);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(105,vSelName);   // Selektion zu Debugzwecken nicht löschen
    vSel # 0;
  end;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:refreshmode();
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel(opt aFilter   : logic);
begin
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  StartSel(aFilter);
end;


//========================================================================
//  AusSelFilter
//
//========================================================================
sub AusSelFilter();
begin
  AusSel(y);
end;


//========================================================================