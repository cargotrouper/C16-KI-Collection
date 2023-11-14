@A+
//===== Business-Control =================================================
//
//  Prozedur    Con_Mark_Sel
//                    OHNE E_R_G
//  Info        Selektierte Controllingeinträge ausgeben
//
//
//  25.03.2010  ST  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB EvtChanged (aEvt: event): logic
//    SUB EvtInit(aEvt : event): logic
//    SUB _setState(aTargetMode : alpha; aType : alpha)
//    SUB _emptyButWith(aField : alpha; opt aValue : alpha) : alpha
//
//========================================================================
@I:Def_Global

define begin
  cKunde    : Gv.Logic.01
  cArtikel  : Gv.Logic.02
  cMaterial : Gv.Logic.03
end;


declare _setState(aTargetMode : alpha; aType : alpha)
declare _emptyButWith(aField : alpha; opt aValue : alpha; opt aStern : alpha) : alpha
declare _SelectFromFileInit(aFile : int; var aSelName : alpha; aQ : alpha) : handle
declare _SelectFromFileTerm(aSel : int; aFile : int; aSelName : alpha)

//========================================================================
//  Main
//
//========================================================================
MAIN ()
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
end;
begin
  RecBufClear(998);

  cKunde   # false;
  cArtikel # false;
  cMaterial   # false;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Controlling','Con_Mark_Sel:AusSel');

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  Erx       : int;
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vTree     : handle;
  vItem     : handle;

  vQcon     : alpha(4000);
  vQAdr     : alpha(4000);
  vTmp      : alpha(4000)
end;
begin
  vList # gZllist;
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  // Selektionskriterien werden ja nach Auswahl erstellt
  vQcon # '';
  vQAdr # '';

  // Kundenselektion
  if (cKunde) then begin

    // alle Kunden ??
    if (Sel.Adr.nurMarkeYN) then begin
      vQcon  # vQcon + _emptyButWith('Con.Adressnummer');
    end
    else begin
      // Selektion nach Auswahl

      // -----------------
      // Vertreter
      if (Sel.Adr.von.Vertret <> 0) then begin
        vQcon  # vQcon + _emptyButWith('Con.Vertreternr',Aint(Sel.Adr.von.Vertret));
      end
      else
      // -----------------
      // Verband
      if (Sel.Adr.von.Verband <> 0) then begin
        vQcon  # vQcon + _emptyButWith('Con.Adressnummer'); // Adressen werden abgefragt
        // Adressen Selektieren
        Lib_Sel:QInt(var vQAdr, 'Adr.Verband', '=', Sel.Adr.von.Verband);
        vSel # _SelectFromFileInit(100, var vSelName, vQAdr);
        vTmp # '';
        vFlag # _RecFirst;
        WHILE (RecRead(100,vSel,vFlag) <= _rLocked) DO BEGIN
          vFlag # _RecNext;
          if(vTmp <> '') then
            vTmp # vTmp + 'OR ';
          vTmp # vTmp  + '(Con.Adressnummer = ' + Aint(Adr.Nummer) + ')';
        END;
        _SelectFromFileTerm(vSel,100, vSelname);

        // GGf. Vertreterstring anhängen
        if (vTmp <> '') then
          vQcon # vQcon + ' AND ('+ vTmp+')';
        else
          vQcon # '';

      end
      else

      // -----------------
      // Postleitzahl
      if ((Sel.Adr.von.PLZ <> '') or (Sel.Adr.bis.PLZ <> '')) then begin
        vQcon  # vQcon + _emptyButWith('Con.Adressnummer'); // Adressen werden abgefragt
        // Adressen Selektieren
        Lib_Sel:QVonBisA(var vQAdr, '"Adr.PLZ"', "Sel.Adr.von.PLZ",    "Sel.Adr.bis.PLZ");
        vSel # _SelectFromFileInit(100, var vSelName, vQAdr);
        vTmp # '';
        vFlag # _RecFirst;
        WHILE (RecRead(100,vSel,vFlag) <= _rLocked) DO BEGIN
          vFlag # _RecNext;
          if(vTmp <> '') then
            vTmp # vTmp + 'OR ';
          vTmp # vTmp  + '(Con.Adressnummer = ' + Aint(Adr.Nummer) + ')';
        END;

        // GGf. Vertreterstring anhängen
        if (vTmp <> '') then
          vQcon # vQcon + ' AND ('+ vTmp+')';
        else
          vQcon # '';

        _SelectFromFileTerm(vSel,100, vSelname);
      end
      else
      // -----------------
      // Gruppe
      if (Sel.Adr.von.Gruppe <> '') then begin
        vQcon  # vQcon + _emptyButWith('Con.Adressnummer'); // Adressen werden abgefragt
        // Adressen Selektieren
        Lib_Sel:QAlpha(var vQAdr, '"Adr.Gruppe"', '=', "Sel.Adr.von.Gruppe");
        vSel # _SelectFromFileInit(100, var vSelName, vQAdr);
        vTmp # '';
        vFlag # _RecFirst;
        WHILE (RecRead(100,vSel,vFlag) <= _rLocked) DO BEGIN
          vFlag # _RecNext;
          if(vTmp <> '') then
            vTmp # vTmp + 'OR ';
          vTmp # vTmp  + '(Con.Adressnummer = ' + Aint(Adr.Nummer) + ')';
        END;
        // GGf. Vertreterstring anhängen
        if (vTmp <> '') then
          vQcon # vQcon + ' AND ('+ vTmp+')';
        else
          vQcon # '';
        _SelectFromFileTerm(vSel,100, vSelname);
      end;

    end;

  end; // Kundenselektion


  // Artikelselektion
  if (cArtikel) then begin
    Lib_Sel:QInt(var vQcon, '"Con.Dateinr"', '=', 250);

    // alle Artikel ??
    if (Sel.Art.nurMarkeYN) then begin
      vQcon  # vQcon + _emptyButWith('Con.Artikelnummer');
    end
    else begin
      // Selektion nach Auswahl

      // -----------------
      // Artikelgruppe
      if (Sel.Art.von.ArtGr <> 0) then begin
        vQcon  # vQcon + _emptyButWith('Con.Artikelgruppe',Aint(Sel.Art.von.ArtGr));
      end
      else
      // -----------------
      // Warengruppe
      if  (Sel.Art.von.WGr <> 0) then begin
        vQcon  # vQcon + _emptyButWith('Con.Warengruppe',Aint(Sel.Art.von.WGr));
      end
      else
      // -----------------
      // Artikelnummer
      if (Sel.Art.von.ArtNr <> '') then begin
        vQcon  # vQcon + _emptyButWith('Con.Artikelnummer',Sel.Art.von.ArtNr,'*');
      end;

    end;

  end; // Artikelselektion



  //Materialselektion
  if (cMaterial) then begin
    Lib_Sel:QInt(var vQcon, '"Con.Dateinr"', '=', 200);

    // alle Güten ??
    if ("Sel.Mat.!EigenYN") then begin
      vQcon  # vQcon + _emptyButWith('Con.Artikelnummer');

    end
    else begin
      // Selektion nach Auswahl

      // -----------------
      // Güte
      if ("Sel.Mat.Güte" <> '') then begin
        vQcon  # vQcon + _emptyButWith('Con.Artikelnummer',"Sel.Mat.Güte",'*');
        Lib_Sel:QInt(var vQcon, '"Con.Dateinr"', '=', 200);
      end
      else
      // -----------------
      // Warengruppe
      if  (Sel.Mat.von.WGr <> 0) then begin
        vQcon  # vQcon + _emptyButWith('Con.Warengruppe',Aint(Sel.Mat.von.WGr));
      end;

    end;
  end; // Materialselektion

  // Jahr Selektieren
  Lib_Sel:QVonBisI(var vQcon, '"Con.Jahr"',"Sel.Von.Jahr","Sel.Bis.Jahr");

  Lib_Sel:QAlpha(var vqCon, 'Con.Typ', '=', Sel.Sortierung);

  // Selektion über Controlling einträge fahren
  vSel # SelCreate(950,1);
  Erx # vSel->SelDefQuery('', vQcon);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Selektion durchgehen und Markierung setzen
  vFlag # _RecFirst;
  WHILE (RecRead(950,vSel,vFlag) <= _rLocked) DO BEGIN
    vFlag # _RecNext;
    
    Lib_Mark:MarkAdd(950,y,y);
  END;

  // Selektion schließen und löschen, Daten sind im Raumbaum
  SelClose(vSel);
  SelDelete(950, vSelName);
  vSel # 0;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);

  // Aufruf des "Konstruktors"
  Sel_Main:EvtInit(aEvt);

  cKunde   # false;
  cArtikel # false;
  cMaterial   # false;

  _setState('disable','K');
  _setState('disable','A');
  _setState('disable','Q');

  aEvt:Obj->WinUpdate();
end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpName = 'cbErl') AND ($cbErl->wpCheckState = _WinStateChkchecked) then begin
    $cbAuf->wpCheckState        # _WinStateChkUnchecked;
    $cbBest->wpCheckState       # _WinStateChkUnchecked;
    $cbAng->wpCheckState        # _WinStateChkUnchecked;
    Sel.Sortierung # '';
  end;
  if (aEvt:Obj->wpName = 'cbAuf') AND ($cbAuf->wpCheckState = _WinStateChkchecked) then begin
    $cbErl->wpCheckState        # _WinStateChkUnchecked;
    $cbBest->wpCheckState       # _WinStateChkUnchecked;
    $cbAng->wpCheckState        # _WinStateChkUnchecked;
    Sel.Sortierung # 'A';
  end;
  if (aEvt:Obj->wpName = 'cbBest') AND ($cbBest->wpCheckState = _WinStateChkchecked) then begin
    $cbAuf->wpCheckState        # _WinStateChkUnchecked;
    $cbErl->wpCheckState        # _WinStateChkUnchecked;
    $cbAng->wpCheckState        # _WinStateChkUnchecked;
    Sel.Sortierung # 'B';
  end;
  if (aEvt:Obj->wpName = 'cbAng') AND ($cbAng->wpCheckState = _WinStateChkchecked) then begin
    $cbAuf->wpCheckState        # _WinStateChkUnchecked;
    $cbBest->wpCheckState       # _WinStateChkUnchecked;
    $cbErl->wpCheckState        # _WinStateChkUnchecked;
    Sel.Sortierung # 'G';
  end;
  if ($cbErl->wpCheckState = _WinStateChkUnchecked) and
    ($cbAuf->wpCheckState = _WinStateChkUnchecked) and
    ($cbBest->wpCheckState = _WinStateChkUnchecked) and
    ($cbAng->wpCheckState = _WinStateChkUnchecked) then aEvt:obj->wpCheckState # _WinStateChkChecked;


  if (aEvt:Obj->wpName = 'Cb.Kunde')or ((aEvt:Obj->wpName = 'Cb.KundenAlle')) then begin
    $Cb.Kunde->wpCheckState   # _WinStateChkchecked;
    $Cb.Artikel->wpCheckState # _WinStateChkUnchecked;
    $Cb.Qualit->wpCheckState  # _WinStateChkUnchecked;
    cKunde # true;

    _setState('enable','K');
    _setState('disable','A');
    _setState('disable','Q');

   if (aEvt:Obj->wpName = 'Cb.KundenAlle') and (aEvt:Obj->wpCheckState = _WinStateChkChecked) then
      _setState('disable','KA');
    else
      _setState('enable','KA');
  end;

  if (aEvt:Obj->wpName = 'Cb.Artikel') or ((aEvt:Obj->wpName = 'Cb.ArtikelAlle'))  then begin
    $Cb.Kunde->wpCheckState   # _WinStateChkUnchecked;
    $Cb.Artikel->wpCheckState # _WinStateChkchecked;
    $Cb.Qualit->wpCheckState  # _WinStateChkUnchecked;
    cArtikel # true;

    _setState('disable','K');
    _setState('enable','A');
    _setState('disable','Q');

    if (aEvt:Obj->wpName = 'Cb.ArtikelAlle') and (aEvt:Obj->wpCheckState = _WinStateChkChecked) then
      _setState('disable','AA');
    else
      _setState('enable','AA');

  end;

  if (aEvt:Obj->wpName = 'Cb.Qualit') or ((aEvt:Obj->wpName = 'Cb.QualitAlle'))then begin
    $Cb.Kunde->wpCheckState   # _WinStateChkUnchecked;
    $Cb.Artikel->wpCheckState # _WinStateChkUnchecked;
    $Cb.Qualit->wpCheckState  # _WinStateChkchecked;
    cMaterial # true;

    _setState('disable','K');
    _setState('disable','A');
    _setState('enable','Q');

    if (aEvt:Obj->wpName = 'Cb.QualitAlle') and (aEvt:Obj->wpCheckState = _WinStateChkChecked) then
        _setState('disable','QA');
      else
        _setState('enable','QA');

  end;


  RETURN true;
end;



//========================================================================
// _setState()
//          aktiviert bzw. deaktiviert Felder
//========================================================================
sub _setState(aTargetMode : alpha; aType : alpha) begin
  case (aTargetMode) of
    'enable' : begin

      case aType of
        'K', 'KA' : begin
                if (aType = 'K') then
                  Lib_GuiCom:Enable($Cb.KundenAlle);
                Lib_GuiCom:Enable($edVertreter);
                Lib_GuiCom:Enable($bt.Vertreter);
                Lib_GuiCom:Enable($edVerband);
                Lib_GuiCom:Enable($bt.Verband);
                Lib_GuiCom:Enable($edAdr.PLZvon);
                Lib_GuiCom:Enable($edAdr.PLZbis);
                Lib_GuiCom:Enable($edAdr.Gruppe);
                Lib_GuiCom:Enable($bt.Gruppe);
              end;
        'A','AA' : begin
                if (aType = 'A') then
                  Lib_GuiCom:Enable($Cb.ArtikelAlle);
                Lib_GuiCom:Enable($edAgr);
                Lib_GuiCom:Enable($bt.Agr);
                Lib_GuiCom:Enable($edWgr);
                Lib_GuiCom:Enable($bt.Wgr);
                Lib_GuiCom:Enable($edArtikel);
                Lib_GuiCom:Enable($bt.Artikel2);
              end;
        'Q','QA' : begin
                if (aType = 'Q') then
                  Lib_GuiCom:Enable($Cb.QualitAlle);
                Lib_GuiCom:Enable($edGuete);
                Lib_GuiCom:Enable($bt.Guete);
                Lib_GuiCom:Enable($edWgrVon);
                Lib_GuiCom:Enable($bt.WgrQ);
              end;
      end;

    end;

    'disable' : begin
      case aType of
        'K','KA' : begin
                if (aType = 'K') then
                  Lib_GuiCom:Disable($Cb.KundenAlle);
                Lib_GuiCom:Disable($edVertreter);
                Lib_GuiCom:Disable($bt.Vertreter);
                Lib_GuiCom:Disable($edVerband);
                Lib_GuiCom:Disable($bt.Verband);
                Lib_GuiCom:Disable($edAdr.PLZvon);
                Lib_GuiCom:Disable($edAdr.PLZbis);
                Lib_GuiCom:Disable($edAdr.Gruppe);
                Lib_GuiCom:Disable($bt.Gruppe);
              end;
        'A','AA' : begin
                if (aType = 'A') then
                  Lib_GuiCom:Disable($Cb.ArtikelAlle);
                Lib_GuiCom:Disable($edAgr);
                Lib_GuiCom:Disable($bt.Agr);
                Lib_GuiCom:Disable($edWgr);
                Lib_GuiCom:Disable($bt.Wgr);
                Lib_GuiCom:Disable($edArtikel);
                Lib_GuiCom:Disable($bt.Artikel2);
              end;
        'Q','QA' : begin
                if (aType = 'Q') then
                  Lib_GuiCom:Disable($Cb.QualitAlle);
                Lib_GuiCom:Disable($edGuete);
                Lib_GuiCom:Disable($bt.Guete);
                Lib_GuiCom:Disable($edWgrVon);
                Lib_GuiCom:Disable($bt.WgrQ);
              end;
      end;
    end;
  end;
end;




//========================================================================
// _emptyButWith(aField : alpha) : alpha
//   Gibt einen Selektionsstring für die Controllingeinträge zurück, der
//   nur Fälle mit einem gefüllten Wert selektiert
//========================================================================
sub _emptyButWith(aField : alpha; opt aValue : alpha; opt aStern : alpha) : alpha
local begin
  vQ  : alpha(4000)
end
begin

  vQ # '';
  if (aField <> 'Con.Adressnummer') then
    Lib_Sel:QInt(var vQ, 'Con.Adressnummer', '=', 0);
  else if (aValue <> '') then begin
    Lib_Sel:QInt(var vQ, 'Con.Adressnummer', '=', CnvIa(aValue));
  end else
    Lib_Sel:QInt(var vQ, 'Con.Adressnummer', '<>', 0);

  if (aField <> 'Con.Vertreternr') then
    Lib_Sel:QInt(var vQ, 'Con.Vertreternr', '=', 0);
  else if (aValue <> '') then begin
    Lib_Sel:QInt(var vQ, 'Con.Vertreternr', '=', CnvIa(aValue));
    Lib_Sel:QInt(var vQ, 'Con.Vertreternr', '<>',0);
  end;

  if (aField <> 'Con.Warengruppe') then
    Lib_Sel:QInt(var vQ, 'Con.Warengruppe', '=', 0);
  else if (aValue <> '') then begin
    Lib_Sel:QInt(var vQ, 'Con.Warengruppe', '=', CnvIa(aValue));
    Lib_Sel:QInt(var vQ, 'Con.Warengruppe', '<>',0);
  end;

  if (aField <> 'Con.Artikelgruppe') then
    Lib_Sel:QInt(var vQ, 'Con.Artikelgruppe', '=', 0);
  else if (aValue <> '') then begin
    Lib_Sel:QInt(var vQ, 'Con.Artikelgruppe', '=', CnvIa(aValue));
    Lib_Sel:QInt(var vQ, 'Con.Artikelgruppe', '<>', 0);
  end;

  if (aField <> 'Con.Artikelnummer') then
    Lib_Sel:QAlpha(var vQ, 'Con.Artikelnummer', '=', '');
  else if (aValue <> '') then begin
      if (aStern <> '') then
        Lib_Sel:QAlpha(var vQ, 'Con.Artikelnummer', '=*', aValue);
      else
        Lib_Sel:QAlpha(var vQ, 'Con.Artikelnummer', '=', aValue);
      Lib_Sel:QAlpha(var vQ, 'Con.Artikelnummer', '<>', '');
  end;

  if (aField <> 'Con.Kostenstelle') then
    Lib_Sel:QInt(var vQ, 'Con.Kostenstelle', '=', 0);
  else if (aValue <> '') then begin
    Lib_Sel:QInt(var vQ, 'Con.Kostenstelle', '=', CnvIa(aValue));
    Lib_Sel:QInt(var vQ, 'Con.Kostenstelle', '<>',0);
  end;

  return vQ;
end;


//========================================================================
// _SelectFromFileInit
//   Initialisiert eine Selektion für eine Datei
//========================================================================
sub _SelectFromFileInit(aFile : int; var aSelName : alpha; aQ : alpha) : handle
local begin
  Erx       : int;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
end
begin
  vSel # SelCreate(aFile,1);
  Erx # vSel->SelDefQuery('', aQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  aSelName # Lib_Sel:SaveRun(var vSel, 0);
  return vSel;
end;


//========================================================================
// _SelectFromFileTerm
//   Cleared eine Selektion für eine Datei
//========================================================================
sub _SelectFromFileTerm(aSel : int; aFile : int; aSelName : alpha)
local begin
  vQ  : alpha(4000);
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
end
begin
    // Selektion schließen und löschen, Daten sind im Raumbaum
    SelClose(aSel);
    SelDelete(aFile, aSelName);
end;


//========================================================================