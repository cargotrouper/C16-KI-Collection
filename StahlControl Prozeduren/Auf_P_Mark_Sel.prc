@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_P_Mark_Sel
//                OHNE E_R_G
//  Info        Selektierte Auftragspositionen ausgeben
//              Serienmarkierung
//
//
//  10.02.2009  AI  Erstellung der Prozedur
//  29.11.2010  HB  Filter des Sachbearbeiter angepasst
//  28.03.2012  MS  Reset Button hinzugefuegt
//  20.08.2012  ST  OffeneYN -> nicht gelöschte Aufträge hinzugefügt (P.1381/97)
//  16.01.2018  AH  Selektion nach Rahmen möglich
//  08.03.2021  ST  Inmethack in "sub StartSel"
//  07.09.2021  AH  ERX, Mehrere Güten + Obfs
//  2023-03-28  AH  RID,RAD
//
//  Subprozeduren
//    SUB DefaultSelection()
//    SUB EvtClicked(aEvt : event;): logic;
//    SUB AusSel();
//========================================================================
@I:Def_Global


//========================================================================
//  DefaultSelection
//
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  Sel.Auf.ObfNr2         # 999;
  Sel.Auf.bis.Nummer     # 99999999;
  Sel.Auf.bis.Datum      # today;
  Sel.Auf.bis.WTermin    # 31.12.2099;
  Sel.Auf.bis.AufArt     # 9999;
  Sel.Auf.bis.WGr        # 9999;
  Sel.Auf.bis.DruckDat   # 31.12.2099;
  Sel.Auf.bis.LiefDat    # 31.12.2099;
  Sel.Auf.bis.ZTermin    # 31.12.2099;
  Sel.Auf.bis.Projekt    # 99999999;
  Sel.Auf.bis.Kostenst   # 99999999;
  Sel.Auf.bis.Dicke      # 999999.00;
  Sel.Auf.bis.Breite     # 999999.00;
  Sel.Auf.bis.RID        # 999999.00;
  Sel.Auf.bis.RAD        # 999999.00;
  "Sel.Auf.bis.Länge"    # 999999.00;
  Sel.Auf.von.Obfzusat   # 'zzzzz';
  "Sel.Mat.bis.Zugfest"  # 9999.0;
  Sel.Auf.RahmenYN       # y;
  Sel.Auf.AbrufYN        # y;
  Sel.Auf.NormalYN       # y;
  Sel.Auf.BerechenbYN    # y;
  "Sel.Auf.!BerechenbYN" # y;
  Sel.Auf.Vorgangstyp    # '';
  Sel.Auf.OffeneYN       # y;
  
   RunAFX('Auf.P.Mark.Sel.Default','');
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
MAIN(
  opt aSelName  : alpha);
local begin
  vHdl  : int;
end;
begin
  if (RunAFX('Auf.P.Mark.Sel',aSelName)<>0) then RETURN;

  DefaultSelection();

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Auftrag2',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
  end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Auftrag2',here+':AusSel');
  end;

//  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  Sachbearbeiter
//
//========================================================================
SUB FISA() : logic;
begin
  if (StrFind(StrCnv(Auf.Sachbearbeiter, _StrUmlaut), StrCnv(Sel.Auf.Sachbearbeit, _StrUmlaut), 1, _StrCaseIgnore) > 0) then
    RETURN true
  else
    RETURN false;
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(
  aFilterName : alpha);
local begin
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  vQ2       : alpha(4000);
  vQ3       : alpha(4000);
  vQRahmen  : alpha(4000);
  tErx      : int;
  vPostFix  : alpha;
  vI,vJ     : int;
  vA        : alpha;
end;
begin
  vList # gZLList;

  // BESTAND-Selektion öffnen
  // Selektionsquery für 401
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Auf.P.Nummer', '<', 1000000000);
  if (Sel.Auf.von.Nummer != 0) or (Sel.Auf.bis.Nummer != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);
  if (Sel.Auf.von.ZTermin != 0.0.0) or (Sel.Auf.bis.ZTermin != 01.01.2010) then
    Lib_Sel:QVonBisD(var vQ, 'Auf.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin);
  if (Sel.Auf.von.WTermin != 0.0.0) or (Sel.Auf.bis.WTermin != 1.1.2010) then
    Lib_Sel:QVonBisD(var vQ, 'Auf.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin);
  if (Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt(var vQ, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr);
  if ("Sel.Auf.Gütenstufe" != '') then // Gütenstufe [22.10.2009/PW]
    Lib_Sel:QAlpha(var vQ, '"Auf.P.Gütenstufe"', '=*', "Sel.Auf.Gütenstufe");
  if (Sel.Auf.von.Dicke != 0.0) or (Sel.Auf.bis.Dicke != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke);
  if (Sel.Auf.von.Breite != 0.0) or (Sel.Auf.bis.Breite != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite);
  if ("Sel.Auf.von.Länge" != 0.0) or ("Sel.Auf.bis.Länge" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Auf.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge");
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
  if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
  if (Sel.Auf.Artikelnr != '') then
    Lib_Sel:QAlpha(var vQ, 'Auf.P.Artikelnr', '=', Sel.Auf.Artikelnr);
  if (Sel.Auf.von.RID != 0.0) or (Sel.Auf.bis.RID != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.RID', Sel.Auf.von.RID, Sel.Auf.bis.RID);
  if (Sel.Auf.von.RAD != 0.0) or (Sel.Auf.bis.RAD != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.RAD', Sel.Auf.von.RAD, Sel.Auf.bis.RAD);

  if ("Sel.Auf.Güte" != '') then begin
    if (StrFind("Sel.Auf.Güte",';',1)=0) then begin
      Lib_Sel:QAlpha(var vQ, '"Auf.P.Güte"', '=*', "Sel.Auf.Güte");
    end
    else begin
      if (vQ='') then
        vQ # '('
      else
        vQ # vQ + ' AND (';
      vI # 1+Str_Count("Sel.Auf.Güte",';');
      WHILE (vI>0) do begin
        vA # Str_Token("Sel.Auf.Güte",';',vI);
        dec(vI);
        vQ # vQ + '"Auf.P.Güte"=*'''+vA+'''';
        if vI>0 then vQ # vQ + ' OR ';
      END;
      vQ # vQ + ')';
    end;
  end;


  if (Sel.Auf.NurRahmen<>0) then begin
    if (Sel.Auf.NurRahmenPos=0) then begin
      vQRahmen # '( Auf.P.Nummer = '+aint(Sel.Auf.NurRahmen)+' OR Auf.P.AbrufAufNr = '+aint(Sel.Auf.NurRahmen)+')';
    end
    else begin
      vQRahmen # '(( Auf.P.Nummer = '+aint(Sel.Auf.NurRahmen)+' AND Auf.P.Position = '+aint(Sel.Auf.NurRahmenPos)+') OR (Auf.P.AbrufAufNr = '+aint(Sel.Auf.NurRahmen)+' AND Auf.P.AbrufAufPos = '+aint(Sel.Auf.NurRahmenpos)+'))';
    end;
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + vQRahmen;
  end;

//  Lib_Sel:QInt(var vQ, 'Auf.P.Wgr.Dateinr', '>=', 200);
//  Lib_Sel:QInt(var vQ, 'Auf.P.Wgr.Dateinr', '<=', 209);
//  Lib_Sel:QAlpha(var vQ, '"Auf.P.Löschmarker"', '=', '');
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ((Auf.P.Zugfestigkeit1 <= Sel.Mat.bis.Zugfest AND Auf.P.Zugfestigkeit2 >= Sel.Mat.von.Zugfest) '+
            ' OR  (Auf.P.Zugfestigkeit1 = 0.0 AND Auf.P.Zugfestigkeit2 = 0.0)) '

  // 20.08.2012 ST Löschmarkerselektion Y/N  (1381/97):
  if (Sel.Auf.OffeneYN) then
   Lib_Sel:QAlpha(var vQ, '"Auf.P.Löschmarker"', '=', '');

  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) or (Sel.Auf.Obfs!='') then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 400
  vQ2 # '';
  if (Sel.Auf.Sachbearbeit != '' ) then
    vQ2 # '(Sel.Auf.Sachbearbeit=Sel.Auf.Sachbearbeit)';
//    vQ2 # '(Sel.Auf.Sachbearbeit=Sel.Auf.Sachbearbeit)';
//    vQ2 # '(Auf.Sachbearbeiter='''+Sel.Auf.Sachbearbeit+''')';
    
//  if (Sel.Auf.Sachbearbeit != '') then
//    Lib_Sel:QAlpha(var vQ2, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);
  if (Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt(var vQ2, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr);
  if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ2, 'Auf.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);
  if (Sel.Auf.Vorgangstyp != '') then
    Lib_Sel:QAlpha(var vQ2, 'Auf.Vorgangstyp', '=', Sel.Auf.Vorgangstyp);

  // Rahmen/Abruf/Normal?
  if (Sel.Auf.RahmenYN<>y) or (Sel.Auf.AbrufYN<>y) or (Sel.Auf.NormalYN<>y) then begin
    if (vQ2<>'') then vQ2 # vQ2 + ' AND ';
    if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=y) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=N AND Auf.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=N AND Auf.AbrufYN=Y'
    else if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=Y) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=N';
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=Y AND Auf.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=y) then
      vQ2 # vQ2 + 'Auf.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + '(Auf.LiefervertragYN=Y OR Auf.AbrufYN=Y)'
    else
      vQ2 # 'Auf.AbrufYN<>Auf.AbrufYN';
  end;

  // 15.10.2009 MS Berechnungsmarker hinzugefuegt
  if((Sel.Auf.BerechenbYN = true) and ("Sel.Auf.!BerechenbYN" = false))
  or ((Sel.Auf.BerechenbYN = false) and ("Sel.Auf.!BerechenbYN" = true)) then begin
    if(Sel.Auf.BerechenbYN = true) and ("Sel.Auf.!BerechenbYN" = false) then
      Lib_Sel:QAlpha(var vQ2, 'Auf.P.Aktionsmarker', '=', '$');
    else if (Sel.Auf.BerechenbYN = false) and ("Sel.Auf.!BerechenbYN" = true) then
      Lib_Sel:QAlpha(var vQ2, 'Auf.P.Aktionsmarker', '!=', '$');
  end;

  // Selektionsquery für 402
  vQ3 # '';
  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ3, 'Auf.Af.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2)
  else  if (Sel.Auf.Obfs!='') then begin
    vI # 1+Str_Count("Sel.Auf.Obfs",';');
    WHILE (vI>0) do begin
      vA # Str_Token("Sel.Auf.Obfs",';',vI);
      dec(vI);
      Lib_Berechnungen:Int1AusAlpha(vA, var vJ);
      if (vJ>0) then vQ3 # vQ3 + '"Auf.AF.ObfNr"='+aint(vJ)
      else vQ3 # vQ3 + '"Auf.AF.Kürzel"='''+vA+'''';
      if vI>0 then vQ3 # vQ3 + ' OR ';
    END;
  end;

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate(401, gKey);
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  vSel->SelAddLink('', 402, 401, 11, 'Ausf');
  tErx # vSel->SelDefQuery('', vQ);
  if (tErx != 0) then Lib_Sel:QError(vSel);
  if ( Sel.Auf.Sachbearbeit != '' ) then
    tErx # vSel->SelDefQuery('Kopf', vQ2, here+':FISA')
  else
    tErx # vSel->SelDefQuery('Kopf', vQ2);
  if (tErx != 0) then Lib_Sel:QError(vSel);
  tErx # vSel->SelDefQuery('Ausf', vQ3);
  if (tErx != 0) then Lib_Sel:QError(vSel);

  if (aFiltername<>'') then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0,n,vPostFix);
  if (tErx != 0) then Lib_Sel:QError(vSel);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFiltername<>'') then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    w_AktiverFilter # aFilterName;
  end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(401,vSel,vFlag) <= _rLocked) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(401,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(401,vSelName);
  end;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  
  // ST/AH 2021-03-08:
  // Sonderlocke Inmet: Inmet hat einen Standardselektion, die
  // in der EvtInit gelöst wird.
  // Für späteren Fix:
  //  in Lib_GiuCom:AddAddChildWindow bei vor vMDI # WinOpen(vName); Mit C16 Temp DAten zusatzparas wegspeichern
  
  if (Set.Installname = 'ISB') then
    RETURN;
  
  
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

  if (aFilter) then
    StartSel('Filter')
  else
    StartSel('');
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