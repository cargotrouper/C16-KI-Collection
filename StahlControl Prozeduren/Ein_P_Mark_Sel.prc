@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_P_Mark_Sel
//                OHNE E_R_G
//  Info        Selektierte Bestellpositionen ausgeben
//
//
//  10.02.2009  AI  Erstellung der Prozedur
//  29.11.2010  HB  Filter des Sachbearbeiter angepasst
//  28.03.2012  MS  Reset Button hinzugefuegt
//  20.08.2012  ST  OffeneYN -> nicht gelöschte Bestellungen hinzugefügt (P.1381/97)
//  16.10.2013  AH  Anfragen
//  07.09.2021  AH  ERX, Mehrere Güten + Obfs
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
//2023-04-12  MR Hinzufügen bis Rad+Rid 2465/115
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.Auf.bis.WTermin   # 1.1.2099;
  Sel.Auf.bis.AufArt    # 9999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.bis.DruckDat  # 1.1.2099;
  Sel.Auf.bis.LiefDat   # 1.1.2099;
  Sel.Auf.bis.ZTermin   # 1.1.2099;
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Kostenst  # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;
  Sel.Auf.bis.RID        # 999999.00;
  Sel.Auf.bis.RAD        # 999999.00;
  Sel.Auf.von.Obfzusat  # 'zzzzz';
  Sel.Auf.RahmenYN      # y;
  Sel.Auf.AbrufYN       # y;
  Sel.Auf.NormalYN      # y;
  Sel.Auf.OffeneYN      # y;
  Sel.Auf.AnfragenYN    # n;
  
  
  RunAFX('Ein.P.Mark.Sel.Default','');
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
  opt aSelname : alpha)
local begin
  vHdl  : int;
end;
begin
  if (RunAFX('Ein.P.Mark.Sel',aSelName)<>0) then RETURN;

  DefaultSelection();

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Bestellung2',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Bestellung2',here+':AusSel');
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
  if (StrFind(StrCnv(Ein.Sachbearbeiter, _StrUmlaut), StrCnv(Sel.Auf.Sachbearbeit, _StrUmlaut), 1, _StrCaseIgnore) > 0) then
    RETURN true
  else
    RETURN false;
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(
  aFilterName : alpha;
  opt aVorSel : alpha);
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
  // Selektionsquery für 501
  vQ # '';
  Lib_Sel:QInt( var vQ, 'Ein.P.Nummer', '<', 1000000000 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != 01.01.2010 ) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != 01.01.2010 ) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.von.Kostenst != 0 ) or ( Sel.Auf.bis.Kostenst != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Kostenstelle', Sel.Auf.von.Kostenst, Sel.Auf.bis.Kostenst );
  if ( Sel.Auf.Artikelnr != '' ) then
    Lib_Sel:QAlpha( var vQ, 'Ein.P.Artikelnr', '=', Sel.Auf.Artikelnr );
  if (Sel.Auf.von.RID != 0.0) or (Sel.Auf.bis.RID != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Ein.P.RID', Sel.Auf.von.RID, Sel.Auf.bis.RID);
  if (Sel.Auf.von.RAD != 0.0) or (Sel.Auf.bis.RAD != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Ein.P.RAD', Sel.Auf.von.RAD, Sel.Auf.bis.RAD);

  if ("Sel.Auf.Güte" != '') then begin
    if (StrFind("Sel.Auf.Güte",';',1)=0) then begin
      Lib_Sel:QAlpha(var vQ, '"Ein.P.Güte"', '=*', "Sel.Auf.Güte");
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
        vQ # vQ + '"Ein.P.Güte"=*'''+vA+'''';
        if vI>0 then vQ # vQ + ' OR ';
      END;
      vQ # vQ + ')';
    end;
  end;

  if (Sel.Auf.NurRahmen<>0) then begin
    if (Sel.Auf.NurRahmenPos=0) then begin
      vQRahmen # '( Ein.P.Nummer = '+aint(Sel.Auf.NurRahmen)+' OR Ein.P.AbrufAufNr = '+aint(Sel.Auf.NurRahmen)+')';
    end
    else begin
      vQRahmen # '(( Ein.P.Nummer = '+aint(Sel.Auf.NurRahmen)+' AND Ein.P.Position = '+aint(Sel.Auf.NurRahmenPos)+') OR (Ein.P.AbrufAufNr = '+aint(Sel.Auf.NurRahmen)+' AND Ein.P.AbrufAufPos = '+aint(Sel.Auf.NurRahmenpos)+'))';
    end;
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + vQRahmen;
  end;

  // 20.08.2012 ST Löschmarkerselektion Y/N  (1381/97):
  if (Sel.Auf.OffeneYN) then
   Lib_Sel:QAlpha(var vQ, '"Ein.P.Löschmarker"', '=', '');



  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) or (Sel.Auf.Obfs!='') then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 500
  vQ2 # '';
  if (Sel.Auf.Sachbearbeit != '' ) then
vQ2 # '(Sel.Auf.Sachbearbeit=Sel.Auf.Sachbearbeit)';
//    vQ2 # '(Sel.Auf.Sachbearbeiter='''+Sel.Auf.Sachbearbeit+''')';
//  if ( Sel.Auf.Sachbearbeit != '') then
//    Lib_Sel:QAlpha( var vQ2, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  //if ( Sel.Auf.Lieferantnr != 0) then
  //  Lib_Sel:QInt( var vQ2, 'Ein.Lieferantennr', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );

  //Bug Fix MR  24.09.2021   Abfrage nach leerem string führt zu doppelten AND und damit zur Fehlfunktion //Edit MR 19.08.2022 jetzt ist es gefixt
  if (Sel.Auf.AnfragenYN and Sel.Auf.NormalYN ) then begin
      if(vQ <> '') then vQ2 # vQ2 + ' AND '
        vQ2 # vQ2 + '("Ein.Vorgangstyp"='+''''+c_Anfrage+''' OR "Ein.Vorgangstyp"='''+c_Bestellung+''')';
  end
  else if (Sel.Auf.AnfragenYN) then begin
    Lib_Sel:QAlpha(var vQ2, '"Ein.Vorgangstyp"', '=', c_Anfrage);
  end
  else begin
    Lib_Sel:QAlpha(var vQ2, '"Ein.Vorgangstyp"', '=', c_Bestellung);
  end;

  // Rahmen/Abruf/Normal?
  if (Sel.Auf.RahmenYN<>y) or (Sel.Auf.AbrufYN<>y) or (Sel.Auf.NormalYN<>y) then begin
    if (vQ2<>'') then vQ2 # vQ2 + ' AND ';
    if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=y) then
      vQ2 # vQ2 + 'Ein.LiefervertragYN=N AND Ein.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + 'Ein.LiefervertragYN=N AND Ein.AbrufYN=Y'
    else if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=Y) then
      vQ2 # vQ2 + 'Ein.LiefervertragYN=N';
    
    
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + 'Ein.LiefervertragYN=Y AND Ein.AbrufYN=N' // funktioniert nicht in Kombi mit "Nur Lieferant"
    
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=y) then
      vQ2 # vQ2 + 'Ein.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + '(Ein.LiefervertragYN=Y OR Ein.AbrufYN=Y)'
    else
      vQ2 # 'Ein.AbrufYN<>Ein.AbrufYN';
  end;

  //Selektionsquery für 502
  vQ3 # '';
  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ3, 'Ein.Af.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2)
  else  if (Sel.Auf.Obfs!='') then begin
    vI # 1+Str_Count("Sel.Auf.Obfs",';');
    WHILE (vI>0) do begin
      vA # Str_Token("Sel.Auf.Obfs",';',vI);
      dec(vI);
      Lib_Berechnungen:Int1AusAlpha(vA, var vJ);
      if (vJ>0) then vQ3 # vQ3 + '"Ein.AF.ObfNr"='+aint(vJ)
      else vQ3 # vQ3 + '"Ein.AF.Kürzel"='''+vA+'''';
      if vI>0 then vQ3 # vQ3 + ' OR ';
    END;
  end;


  // Selektion starten...
  vSel # SelCreate( 501, gKey);
  vSel->SelAddLink('', 500, 501, 3, 'Kopf');
  vSel->SelAddlink('', 502, 501, 12, 'Ausf');
  vSel->SelDefQuery('', vQ );
  if ( Sel.Auf.Sachbearbeit != '' ) then
    vSel->SelDefQuery('Kopf', vQ2, here+':FISA')
  else
    vSel->SelDefQuery('Kopf', vQ2 );
  vSel->SelDefQuery('Ausf', vQ3 );

  if (aFiltername<>'') then vPostFix # '.SEL';
  
  vSelName # Lib_Sel:SaveRun(var vSel, 0,n,vPostFix, aVorSel);
  if (tErx != 0) then Lib_Sel:QError(vSel);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFiltername<>'') then begin
    gZLList->wpdbselection # vSel;
    if (aVorSel='') then
      w_Selname # vSelName
    else
      w_Sel2name # vSelName;
    w_AktiverFilter # aFilterName;
  end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(501,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(501,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(501,vSelName);
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