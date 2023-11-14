@A+
//===== Business-Control =================================================
//
//  Prozedur    Mat_Mark_Sel
//                  OHNE E_R_G
//  Info        Selektierte Materialien ausgeben
//
//
//  11.07.2005  AI  Erstellung der Prozedur
//  08.08.2008  DS  QUERY
//  12.03.2009  ST  Selektionskriterium Gütenstufe hinzugefügt
//  28.03.2012  MS  Reset Button hinzugefuegt
//  14.04.2016  AH  Fix
//  13.10.2020  AH  AFX "Sel.Mark.Mat"
//  06.07.2021  AH  Mehrere Güten + Obfs
//  27.07.2021  AH  ERX
//  02.02.2022  ST  Bugfix Stichtagsselektion / Erzeugungsdatum Projekt 2376/3
//  31.05.2022  AH  Mehrerer Status
//  2023-01-09  AH  Paketnr selektierbar
//
//  Subprozeduren
//    SUB DefaultSelection()
//    SUB EvtClicked(aEvt : event;): logic;
//    SUB AusSel();
//
//========================================================================
@I:Def_Global

//========================================================================
//  DefaultSelection
//
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  Sel.Mat.von.Wgr         # 0;
  Sel.Mat.bis.WGr         # 9999;
  Sel.Mat.ObfNr2          # 999;
  Sel.Mat.bis.Status      # 999;
  Sel.Mat.bis.Dicke       # 999999.00;
  Sel.Mat.bis.Breite      # 999999.00;
  "Sel.Mat.bis.Länge"     # 999999.00;
  Sel.Mat.bis.RID         # 999999.00;
  Sel.Mat.bis.RAD         # 999999.00;
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
  
   RunAFX('Mat.Mark.Sel.Default','');
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(aEvt : event;): logic;
begin
  case (aEvt:Obj -> wpName) of
    'bt.Reset' : begin
      DefaultSelection();
      gMdi -> WinUpdate();
    end;

  end; // case
  return(true);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (
  opt aAbwertung  : logic;
  opt aSelName    : alpha);
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
end;
begin
  if (aAbwertung) then vA # 'Y' else vA # 'N';
  vA # vA + '|'+aSelName;
  if (RunAFX('Mat.Mark.Sel',vA)<>0) then RETURN;

  DefaultSelection();

  // ST 31.08.2009  Serienmarkierung für Abwertung hat eine separate Maske
  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Material2',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
  end
  else begin
    if (aAbwertung) then begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.MaterialAbwertung',here+':AusSel');
    end
    else begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Material2',here+':AusSel');
    end;
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
  Erx       : int;
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  vQ1       : alpha(4000);
  vQ2       : alpha(4000);
  vQ3       : alpha(4000);
  vPostFix  : alpha;
  vI,vJ     : int;
  vA        : alpha;
end;
begin

  vList # gZLList;

  // BESTAND-Selektion
  vQ  # '';
  vQ1 # '';
  vQ2 # '';
  vQ3 # '';

  if ("Sel.Mat.von.Dicke"  != 0.0) or ("Sel.Mat.bis.Dicke"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke");
  if ("Sel.Mat.von.Breite" != 0.0) or ("Sel.Mat.bis.Breite" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite");
  if ("Sel.Mat.von.Länge"  != 0.0) or ("Sel.Mat.bis.Länge"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge");
  if ("Sel.Mat.von.ÜDatum" != 0.0.0) or ("Sel.Mat.bis.ÜDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Übernahmedatum"', "Sel.Mat.von.ÜDatum", "Sel.Mat.bis.ÜDatum");
  if ("Sel.Mat.von.EDatum" != 0.0.0) or ("Sel.Mat.bis.EDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Eingangsdatum"', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum");
  if ("Sel.Mat.von.ADatum" != 0.0.0) or ("Sel.Mat.bis.ADatum" != today) then
      Lib_Sel:QVonBisD(var vQ, '"Mat.Ausgangsdatum"', "Sel.Mat.von.ADatum", "Sel.Mat.bis.ADatum");
//  if ("Sel.Mat.von.Status" != 0) or ("Sel.Mat.bis.Status" != 999) then
//    Lib_Sel:QVonBisI(var vQ, '"Mat.Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status");
  if ("Sel.Mat.von.WGr"    != 0) or ("Sel.Mat.bis.WGr"    != 9999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat.Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr");
  if ("Sel.Art.von.ArtNr"  != '') or ("Sel.Art.bis.ArtNr"  != 'zzzzz') then
    Lib_Sel:QVonBisA(var vQ, '"Mat.Strukturnr"',    "Sel.Art.von.ArtNr",  "Sel.Art.bis.ArtNr");
  if (!"Sel.Mat.mit.gelöscht") then
    Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');

  // 31.05.2022 AH
  if ("Sel.Mat.von.Status" != 0) or ("Sel.Mat.bis.Status" != 999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat.Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status")
  else if (Sel.Mat.Status<>'') then begin
    if (vQ='') then
      vQ # '('
    else
      vQ # vQ + ' AND (';
    vI # 1+Str_Count("Sel.Mat.Status",';');
    WHILE (vI>0) do begin
      vA # Str_Token("Sel.Mat.Status",';',vI);
      dec(vI);
      vQ # vQ + '"Mat.Status"='+vA;
      if vI>0 then vQ # vQ + ' OR ';
    END;
    vQ # vQ + ')';
  end;

  
  if ("Sel.Mat.Güte" != '') then begin
    if (StrFind("Sel.Mat.Güte",';',1)=0) then begin
      Lib_Sel:QAlpha(var vQ, '"Mat.Güte"', '=*', "Sel.Mat.Güte");
    end
    else begin
      if (vQ='') then
        vQ # '('
      else
        vQ # vQ + ' AND (';
      vI # 1+Str_Count("Sel.Mat.Güte",';');
      WHILE (vI>0) do begin
        vA # Str_Token("Sel.Mat.Güte",';',vI);
        dec(vI);
        vQ # vQ + '"Mat.Güte"=*'''+vA+'''';
        if vI>0 then vQ # vQ + ' OR ';
      END;
      vQ # vQ + ')';
    end;
  end;

  if ("Sel.Mat.Gütenstufe" != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");
  if (Sel.Mat.Strukturnr != '') then
    Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr', '=', Sel.Mat.Strukturnr);
  if (Sel.Mat.Lieferant != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lieferant', '=', Sel.Mat.Lieferant);
  if (Sel.Mat.Lagerort != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagertExtern) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '<>', Set.eigeneAdressnr);
  if (Sel.Mat.LagerAnschri != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageranschrift', '=', Sel.Mat.LagerAnschri);
  if(Sel.Auf.von.Nummer <> 0) then  // Bestellnummer
    Lib_Sel:QInt(var vQ, 'Mat.Einkaufsnr', '=', Sel.Auf.von.Nummer);
  if (Sel.Mat.PaketNr != 0) then    // 2023-01-09 AH
    Lib_Sel:QInt(var vQ, 'Mat.PaketNr', '=', Sel.Mat.PaketNr);
  if (Sel.Mat.von.RID != 0.0) or (Sel.Mat.bis.RID != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Mat.RID', Sel.Mat.von.RID, Sel.Mat.bis.RID);
  if (Sel.Mat.von.RAD != 0.0) or (Sel.Mat.bis.RAD != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Mat.RAD', Sel.Mat.von.RAD, Sel.Mat.bis.RAD);

  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2!=999) or (Sel.Mat.Obfs!='') then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'LinkCount(Ausf) > 0';
  end;
  if ("Sel.Mat.EigenYN") AND (!"Sel.Mat.!EigenYN") then begin
    Lib_Sel:QLogic(var vQ, 'Mat.EigenmaterialYN', y);
    //if (vQ<>'') then vQ # vQ + ' AND ';
    //vQ # vQ + 'Mat.EigenmaterialYN';
    end
  else if (!"Sel.Mat.EigenYN") AND ("Sel.Mat.!EigenYN") then begin
    Lib_Sel:QLogic(var vQ, 'Mat.EigenmaterialYN', n);
    //if (vQ<>'') then vQ # vQ + ' AND ';
    //vQ # vQ + ' AND Mat.EigenmaterialYN=false';
  end;

  if ("Sel.Mat.BestelltYN") and (!"Sel.Mat.!BestelltYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Bestellt.Gew > 0';
    end
  else if (!"Sel.Mat.BestelltYN") and ("Sel.Mat.!BestelltYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Bestellt.Gew = 0';
  end;

  if ("Sel.Mat.ReservYN") and (!"Sel.Mat.!ReservYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Reserviert.Gew > 0';
    end
  else if (!"Sel.Mat.ReservYN") and ("Sel.Mat.!ReservYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Reserviert.Gew = 0';
  end;
  if ("Sel.Mat.KommissionYN") and (!"Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Auftragsnr > 0';
    end
  else if (!"Sel.Mat.KommissionYN") and ("Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Auftragsnr = 0';
  end;

  if ("Sel.Mat.von.ZugFest"<>0.0) or ("Sel.Mat.bis.ZugFest"<>9999.0) then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + '(Mat.Zugfestigkeit1 = 0 OR Mat.Zugfestigkeit1 between[' + CnvAF(Sel.Mat.von.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + ',' + CnvAF(Sel.Mat.bis.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + '])';
  end;

  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ1, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2)
  else  if (Sel.Mat.Obfs!='') then begin
    vI # 1+Str_Count("Sel.Mat.Obfs",';');
    WHILE (vI>0) do begin
      vA # Str_Token("Sel.Mat.Obfs",';',vI);
      dec(vI);
      Lib_Berechnungen:Int1AusAlpha(vA, var vJ);
      if (vJ>0) then vQ1 # vQ1 + '"Mat.AF.ObfNr"='+aint(vJ)
      else vQ1 # vQ1 + '"Mat.AF.Kürzel"='''+vA+'''';
      if vI>0 then vQ1 # vQ1 + ' OR ';
    END;
  end;

  if(Sel.Auf.von.Projekt <> 0) then begin
    Lib_Sel:QInt(var vQ, 'Mat.EK.Projektnr', '=', Sel.Auf.von.Projekt);
/***
    if(vQ <> '') then
      vQ # vQ + ' AND ';
    vQ # vQ + '(LinkCount(EinPos) > 0 OR LinkCount(EinPosAbl) > 0)';
    Lib_Sel:QInt(var vQ2, 'Ein.P.Projektnummer', '=', Sel.Auf.von.Projekt);
    Lib_Sel:QInt(var vQ3, 'Ein~P.Projektnummer', '=', Sel.Auf.von.Projekt);
***/
  end;

  // Stichtagselektion
  begin
    // ST 2009-08-31:
    // "Sel.von.Datum" wird für die Stichtagseingabe benutzt und deaktiviert
    // alle Materialselektionen, bis auf die Warengruppe von
    //
    // !!!!! ACHTUNG !!!
    // neue Materialselektionen  MÜSSEN oberhalb dieses Blocks geschehen, da sonst
    // wichtige Funktionen z.B. Materialabwertung nicht mehr korrekt funktionieren
    if (Sel.von.Datum<>0.0.0) then begin
      vQ  # '( Mat.Ausgangsdatum >= ' + CnvAd( Sel.von.Datum, _fmtInternal ) + ' OR Mat.Ausgangsdatum = 0.0.0 )';
      vQ  # vQ + ' AND ( Mat.Eingangsdatum < ' + CnvAd( Sel.von.Datum, _fmtInternal ) + ' AND Mat.Eingangsdatum > 0.0.0 )';
      vQ  # vQ + ' AND ( "Mat.Datum.Erzeugt" < ' + CnvAd( Sel.von.Datum, _fmtInternal ) +')';  // Fix: ST 2022-02-02 2376/3

      if ("Sel.Mat.von.WGr"    != 0) then
        Lib_Sel:QVonBisI(var vQ, '"Mat.Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.von.WGr");
      if ("Sel.Mat.Güte" != '') then
        Lib_Sel:QAlpha(var vQ, '"Mat.Güte"', '=*', "Sel.Mat.Güte");
      if ("Sel.Mat.Gütenstufe" != '') then
        Lib_Sel:QAlpha(var vQ, '"Mat.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");
    end;
  end; // Stichtagselektion



  vSel # SelCreate(200, gKey);
  if (vQ1<>'') then
    vSel->SelAddLink('', 201, 200, 11, 'Ausf');
  if (vQ2<>'') then
    vSel->SelAddLink('', 501, 200, 18, 'EinPos');
  if (vQ3<>'') then
    vSel->SelAddLink('', 511, 200, 19, 'EinPosAbl');

  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  if (vQ1<>'') then begin
    Erx # vSel->SelDefQuery('Ausf', vQ1);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
  end;
  if (vQ2<>'') then begin
    Erx # vSel->SelDefQuery('EinPos', vQ2);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
  end;
  if (vQ3<>'') then begin
    Erx # vSel->SelDefQuery('EinPosAbl', vQ3);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
  end;

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
  end
  else begin  // Markierung...

    Erx # RecRead(200,vSel,_recFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      Lib_Mark:MarkAdd(200,y,y);
      Erx # RecRead(200,vSel,_recNext);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(200,vSelName);   // Selektion zu Debugzwecken nicht löschen
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
  if (Filter_Mat) then Mat_Main:ToggleDelFilter();

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