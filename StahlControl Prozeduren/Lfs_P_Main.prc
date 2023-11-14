@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfs_P_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  02.02.2010  MS  Summen-Infofelder hinzugefuegt
//  04.11.2010  AI  Erweiterung für LFA-MultiLFS
//  05.05.2011  TM  neue Auswahlmethode 1326/75
//  06.02.2012  ST  Paketnummer hinzugefügt
//  30.08.2012  ST  Zgr/DataListInit: Materialnr und Artnr. in jeweils separater Spalte
//  07.09.2012  AI  Bug im "RecDel" bei Paketen
//  07.06.2013  AI  Setting "Set.LFS.MixAbholort" eingebaut
//  15.10.2013  AH  Bugfix: Lfs.P.Menge wird errechnet und nicht stumpf mit Gewicht belegt
//  25.11.2013  AH  Prüfen, ob Material bereits in anderer VLDAW drin ist
//  04.12.2013  AH  neue Spalte Lagerplatz
//  15.05.2014  AH  TransferMenge wird genutzt
//  06.11.2014  AH  Prüfen, ob Material bereits in anderer VLDAW drin ist nur wenn KEIN LFA
//  07.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  09.07.2015  AH  BugFix: Lfs.P.Einsatz.Menge wird wieder ordentlich berechnet
//  24.03.2016  AH  Lfs.P.Bemerkung in Maske
//  20.07.2016  ST  Feldsperrung Verwiegungsart bei Lohnfahraufträgen / Kommt aus Auftragspos
//  07.11.2016  AH  Pflichtfelder verändert für Netto/Brutto/Menge
//  26.02.2018  ST  Neu: Ankerfunktion "Lfs.P.RecInit.Post"
//  29.05.2018  ST  Afx "Lfs.P.Init", "Lfs.P.Init.Pre", "Lfs.P.EvtLstDataInit" hinzugefügt
//  28.09.2020  AH  Markierungen und Markierte löschen
//  22.02.2022  ST  Fix: EvtLstDataInit für Betriebsuser kennt keine Markierung
//  12.05.2022  AH  ERX
//  25.07.2022  HA  Quick Jump
//  2022-12-15  AH  Vorbelegung der Re-Menge verbessert (HWN)
//  2023-02-08  ST  Neu: Liefermengen werden nach Auwahl aus Materialkarte vorbelegt
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB SwitchMask();
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKopf()
//    SUB AusVerwiegungsart()
//    SUB AusKommission()
//    SUB AusMaterial()
//    SUB AusArtikel()
//    SUB AusCharge()
//    SUB EvtTimer(aEvt : event; aTimerId : int) : logic
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG

define begin
  cTitle :    'Lieferschein-Positionen'
  cFile :     441
  cMenuName : 'Lfs.P.Bearbeiten'
  cPrefix :   'Lfs_P'
  cZList :    $ZL.Lfs.Positionen
  cKey :      1
end;

declare Auswahl(aBereich : alpha;)
declare RefreshIfm(opt aName : alpha; opt aChanged : logic)

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  if (lfs.nummer<1000000000) then begin
    $lb.LFSNummer->wpcaption # cnvai(lfs.Nummer);
    $lb.LFSNummer2->wpcaption # cnvai(lfs.Nummer);
  end
  else begin
    $lb.LFSNummer->wpcaption # 'geplant';
    $lb.LFSNummer2->wpcaption # '';
  end;

Lib_Guicom2:Underline($edLfs.P.Kommission);
Lib_Guicom2:Underline($ed3Lfs.P.Artikelnr);
Lib_Guicom2:Underline($edLfs.P.Kommission);

  SetStdAusFeld('edLfs.P.Kommission'      ,'Kommission');
  SetStdAusFeld('ed3Lfs.P.Artikelnr'      ,'Artikel3');
  SetStdAusFeld('ed2Lfs.P.Art.Charge'     ,'Charge');
  SetStdAusFeld('ed3Lfs.P.Art.Charge'     ,'Charge3');
  SetStdAusFeld('ed1Lfs.P.Verwiegungsart' ,'Verwiegungsart');
  SetStdAusFeld('ed1Lfs.P.Materialnr'     ,'Material');

  RunAFX('Lfs.P.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Lfs.P.Init',aint(aEvt:Obj));
end;


//========================================================================
//  MarkSum
//========================================================================
sub MarkSum()
local begin
  Erx       : int;
  v441    : int;
  vNetto  : float;
  vBrutto : float;
  vStk    : int;
end;
begin

  v441 # RekSave(441);

  FOR Erx # RecLink(441, 440, 4, _recFirst)
  LOOP Erx # RecLink(441, 440, 4, _recNext)
  WHILE(Erx <= _rLocked) DO BEGIN
    if (Lib_Mark:IstMarkiert(441, RecInfo(441,_recID))) then begin
      vNetto  # vNetto + Lfs.P.Gewicht.Netto;
      vBrutto # vBrutto + Lfs.P.Gewicht.Brutto;
      vStk    # vStk + "Lfs.P.Stück";
    end;
  END;

  if ($lb.Mark.Netto<>0) then begin
    $lb.Mark.Netto->wpcaption   # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Mark.Brutto->wpcaption  # ANum(vBrutto, Set.Stellen.Gewicht);
    $lb.Mark.Stueck->wpcaption  # aInt(vStk);
    $lb.Mark.Stueck->wpcustom   # aInt(CteInfo(gMarkList,_cteCount));
  end;

  RekRestore(v441);

end;


//========================================================================
//  DeleteUnmarked()
//========================================================================
sub DeleteUnmarked()
local begin
  Erx       : int;
  vLastPos : int;
  vPaks : alpha(4000);

  vItem     : int;
  vMFile    : int;
  vMID      : int;
  
  v441  : int;
end;
begin

  if (Lfs.Nummer < 1000000000) then RETURN;

  Lfs.P.Nummer    # Lfs.Nummer;
  Lfs.P.Position  # 1;
  Erx # RecRead(441,1,0);
   
  APPOFF();

  // Prüflauf auf Teilpakete
  FOR   vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>441) then
      CYCLE;
    Erx # RecRead(441,0,_RecId,vMID);
    
    if (Lfs.P.Paketnr = 0) then
      CYCLE;

    if (StrFind(vPaks,';'+Aint(Lfs.P.Paketnr)+ ';',1) > 0) then
      CYCLE;

    v441  # RekSave(441);
    // Alle Positionen mit Paketnummer markieren
    FOR   Erx # RecLink(441,440,4,_RecFirst)
    LOOP  Erx # RecLink(441,440,4,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      if (Lfs.P.Paketnr = v441->Lfs.P.Paketnr) then begin
//debug('add KEY441 in Paket '+aint(lfs.p.paketnr));
        Lib_Mark:MarkAdd(441,true);
      end;
    END;
    RekRestore(v441);

    vPaks # vPaks + ';'+Aint(Lfs.P.Paketnr)+ ';';
  END;
  
  // Löschlauf
  Lfs.P.Nummer    # Lfs.Nummer;
  Lfs.P.Position  # 1;
  Erx # RecRead(441,1,0);
  WHILE (Erx < _rNoRec) AND (Lfs.P.Nummer = Lfs.Nummer) DO BEGIN
//debug('KEY441');
    if (Lib_Mark:istmarkiert(441,RecInfo(441,_RecId)) = false) then begin
//debug('del!');
      vLastPos  # Lfs.P.Position;
      RekDelete(441);
      LFs.P.Position # vLastPos;
      Erx # RecRead(441,1,0);
      CYCLE;
    end;
    
    Erx # RecRead(441,1,_RecNext);
  END;
    
  Lib_Mark:Reset(441);

  Refreshifm();
    
  cZList->WinUpdate( _winUpdOn, _winLstFromFirst);
  APPON();
  
  RETURN
end;


//========================================================================
// Switchmask
//
//========================================================================
sub SwitchMask();
begin
//debugx('Switch KEY441 '+aint(LFs.P.Materialtyp));
  if ((Lfs.P.Materialtyp=c_IO_VSB) or (Lfs.P.Materialtyp=c_IO_Mat) or (Lfs.P.Materialtyp=0)) and ($nb.untergruppen->wpcurrent<>'nb.Material') then begin
    $nb.Material->wpvisible     # true;
    $nb.untergruppen->wpcurrent # 'nb.Material';
    $nb.Artikel->wpvisible      # false;
    $nb.Verpackung->wpvisible   # false;
    $rb.Artikel->wpCheckState     # _WinStateChkUnChecked;
    $rb.Material->wpCheckState    # _WinStateChkChecked;
    $rb.Verpackung->wpCheckState  # _WinStateChkUnChecked;
  end;
  if ((Lfs.P.Materialtyp=c_IO_Art) or (Lfs.P.Materialtyp=1110)) and ($nb.untergruppen->wpcurrent<>'nb.Artikel') then begin
    $nb.Artikel->wpvisible      # true;
    $nb.untergruppen->wpcurrent # 'nb.Artikel';
    $nb.Material->wpvisible     # false;
    $nb.Verpackung->wpvisible   # false;
    $rb.Artikel->wpCheckState     # _WinStateChkChecked;
    $rb.Material->wpCheckState    # _WinStateChkUnChecked;
    $rb.Verpackung->wpCheckState  # _WinStateChkUnChecked;
  end;
  if ((Lfs.P.Materialtyp=c_IO_VPG)) and ($nb.untergruppen->wpcurrent<>'nb.Verpackung') then begin
    $nb.Verpackung->wpvisible   # true;
    $nb.untergruppen->wpcurrent # 'nb.Verpackung';
    $nb.Artikel->wpvisible      # false;
    $nb.Material->wpvisible     # false;
    $rb.Artikel->wpCheckState     # _WinStateChkUnChecked;
    $rb.Material->wpCheckState    # _WinStateChkUnChecked;
    $rb.Verpackung->wpCheckState  # _WinStateChkChecked;
  end;

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  if (Lfs.P.Materialtyp=c_IO_Mat) or (Lfs.P.Materialtyp=c_IO_VSB) then
    Lib_GuiCom:Pflichtfeld($ed1Lfs.P.Materialnr);

  Lib_GuiCom:Pflichtfeld($edLfs.P.Kommission);
  Lib_GuiCom:Pflichtfeld($ed1Lfs.P.Stck);
  // 07.11.2016
  if ($Lb1.UrBrutto->wpcaption<>'') then
    Lib_GuiCom:Pflichtfeld($ed1Lfs.P.Gewicht.Brutto);
  if ($Lb1.UrNetto->wpcaption<>'') then
    Lib_GuiCom:Pflichtfeld($ed1Lfs.P.Gewicht.Netto);
  Lib_GuiCom:Pflichtfeld($ed1Lfs.P.Menge);
  Lib_GuiCom:Pflichtfeld($ed2Lfs.P.Art.Charge);
end;


//========================================================================
//  Ref_Kommission
//
//========================================================================
sub Ref_Kommission(aChanged : logic);
local begin
  Erx       : int;
  vA      : alpha(250);
  vMenge  : float;
  vTmp    : int;
end;
begin
//debugx('ref KEY441 '+aint(LFs.P.Materialtyp));

  if (aChanged) then begin
    RecBufClear(401);
    Auf.P.Nummer # cnvia(Str_Token(Lfs.P.Kommission,'/',1));
    Auf.P.Position # cnvia(Str_Token(Lfs.P.Kommission,'/',2));
    Auf.SL.LfdNr  # cnvia(Str_Token(Lfs.P.Kommission,'/',3));
    Erx #  RecRead(401,1,0);
    if (Erx<>_rOk) then RecBufClear(401);
    Erx # RecLink(400,401,3,0);   // Auftragskopf holen
    if (Erx>_rLocked) or (Auf.LiefervertragYN) then begin   // 2022-07-06 AH : Verträge dürfen NICHT !!
      RecBufClear(401);
    end
    else begin
      if (Auf.SL.lfdNr<>0) then begin
        Auf.SL.Nummer   # Auf.P.Nummer;
        Auf.SL.Position # Auf.P.Position;
        Erx # RecRead(409,1,0);
        if (Erx<>_rOk) then RecBufClear(409);
      end;
    end;
    
    if (Lfs.Kundennummer=0) then begin  // Prüfung auf gleiche Anschriften
      Lfs.Kundennummer    # Auf.P.Kundennr;
      Lfs.Kundenstichwort # Auf.P.KundenSW;
      Lfs.Zieladresse     # Auf.Lieferadresse;
      Lfs.Zielanschrift   # Auf.Lieferanschrift;
    end
    else begin
      if (Auf.P.Nummer<>0) and
        ((Lfs.Kundennummer<>Auf.P.Kundennr) or
        (Lfs.Zieladresse<>Auf.Lieferadresse) or
        (Lfs.Zielanschrift<>Auf.Lieferanschrift)) then begin
        Lfs.P.Kommission # '';
        RecbufClear(400);
        RecbufClear(401);
        Msg(441006,gTitle,0,0,0);
        $edLfs.P.Kommission->winFocusset(false);
      end;
    end;

//debugx('ref KEY441 '+aint(LFs.P.Materialtyp));
    if (auf.p.nummer=0) then
      Lfs.P.Kommission # ''
    else if (Auf.SL.LfdNr=0) then
      Lfs.P.Kommission  # AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
    else
      Lfs.P.Kommission  # AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position)+'/'+AInt(Auf.SL.LfdNr);
    Lfs.P.Auftragsnr    # Auf.P.Nummer;
    Lfs.P.AuftragsPos   # Auf.P.Position;
    Lfs.P.Auftragspos2  # Auf.SL.LfdNr;
    Lfs.P.Kundennummer  # Auf.P.Kundennr;
    // 15.05.2014
    Lfs.P.MEH.einsatz   # Auf.P.MEH.Einsatz;
    Lfs.P.MEH           # Auf.P.MEH.Preis;
    $edlfs.p.kommission->WinUpdate(_WinUpdFld2Obj);

    // Artikel?
    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      Lfs.P.Materialtyp # c_IO_Art;
      Lfs.P.Artikelnr # Auf.P.Artikelnr;
      Erx # RecLink(250,441,3,0);   // Artikel holen
      if (Erx>_rLocked) then RecBufClear(250);
//      if (RecLinkInfo(252,250,4,_RecCount)>1) then begin
//  todo('Chargenauswahl der Artikel');
//      end;
      Lfs.P.MEH.Einsatz # Art.MEH;
      if (Mode=c_ModeEdit) or (mode=c_ModeNew) then begin
        if (Lfs.P.MEH.Einsatz='Stk') then
          Lib_guiCom:Disable($ed2Lfs.P.Stck)
        else
          Lib_guiCom:Disable($ed2Lfs.P.Stck)
      end;
    end;

    // Material?
    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
      Lfs.P.Materialtyp # c_IO_Mat;
      // 15.05.2014
      //Lfs.P.MEH.Einsatz # 'kg';
    end;
  end;  // changed

  if (Lfs.P.Auftragsnr<>0) then begin
    $Lb.Kommission->wpcaption # Auf.P.KundenSW
    vA # "Auf.P.Güte";
    vA # vA + '   '+ANum(Auf.P.Dicke,Set.Stellen.Dicke);
    vA # vA +' x '+ANum(Auf.P.Breite,Set.Stellen.Breite);
    if ("Auf.P.Länge"<>0.0) then vA # vA +' x '+ANum("Auf.P.Länge","Set.Stellen.Länge");
    vA # vA + '   ';
    if (Auf.P.AusfOben<>'') then vA # vA +'    O:'+Auf.P.AusfOben;
    if (Auf.P.AusfUnten<>'') then vA # vA +'   U:'+Auf.P.AusfUnten;

    $lb.Auftragsinfo->wpcaption   # vA;
    Erx # RecLink(818,401,9,_recFirst); // Verwiegungsart holen
    if (Erx<=_rLocked) then
      $lb1.AufVerwiegungsart->wpcaption   # VWa.Bezeichnung.L1
    else
      $lb1.AufVerwiegungsart->wpcaption   # '';
    $lb1.AufStueck->wpcaption     # AInt(Auf.P.Prd.Rest.Stk);
    if (VWa.NettoYN) then begin
      $lb1.AufNetto->wpcaption    # ANum(Auf.P.Prd.Rest.Gew,Set.Stellen.Gewicht);
      $lb1.AufBrutto->wpcaption   # '';
    end
    else begin
      $lb1.AufNetto->wpcaption    # '';
      $lb1.AufBrutto->wpcaption   # ANum(Auf.P.Prd.Rest.Gew,Set.Stellen.Gewicht);
    end;

    vMenge # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.Rest.Stk, Auf.P.Prd.Rest.Gew, Auf.P.Prd.Rest, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
    $lb1.AufMenge->wpcaption      # ANum(vMenge,Set.Stellen.Menge);
  end
  else begin
    $Lb.Kommission->wpcaption     # '';
    $lb.Auftragsinfo->wpcaption   # '';
    $lb1.AufStueck->wpcaption     # '';
    $lb1.AufNetto->wpcaption      # '';
    $lb1.AufBrutto->wpcaption     # '';
    $lb1.AufMenge->wpcaption      # '';
    $lb1.AufVerwiegungsart->wpcaption   # '';
  end;

//debugx('ref KEY441 '+aint(LFs.P.Materialtyp));

  if (Lfs.P.Materialtyp=c_IO_Art) and ($nb.untergruppen->wpcurrent<>'nb.Artikel') then begin
    vTmp # Winfocusget();
    $nb.Artikel->wpvisible        # true;
    $nb.untergruppen->wpcurrent   # 'nb.Artikel';
    $rb.Artikel->wpdisabled       # n;
    $rb.Artikel->wpCheckState     # _WinStateChkChecked;
    $rb.Material->wpCheckState    # _WinStateChkUnChecked;
    $rb.Material->wpdisabled      # (Lfs.P.Auftragsnr<>0);
    $rb.Verpackung->wpCheckState  # _WinStateChkUnChecked;
    $nb.Material->wpvisible       # false;
    $nb.Verpackung->wpvisible     # false;
    if (vTmp<>0) then vTmp->winfocusset();
  end
  else if (Lfs.P.Materialtyp=c_IO_Mat) and ($nb.untergruppen->wpcurrent<>'nb.Material')then begin
    vTmp # Winfocusget();
    $nb.Material->wpvisible       # true;
    $nb.untergruppen->wpcurrent   # 'nb.Material';
    $rb.Material->wpdisabled      # n;
    $rb.Material->wpCheckState    # _WinStateChkChecked;
    $rb.Artikel->wpCheckState     # _WinStateChkUnChecked;
    $rb.Artikel->wpdisabled       # (Lfs.P.Auftragsnr<>0);
    $rb.Verpackung->wpCheckState  # _WinStateChkUnChecked;
    $nb.Artikel->wpvisible        # false;
    $nb.Verpackung->wpvisible     # false;
    if (vTmp<>0) then vTmp->winfocusset();
  end
  else if (Lfs.P.Materialtyp=c_IO_VPG) and ($nb.untergruppen->wpcurrent<>'nb.Verpackung')then begin
    vTmp # Winfocusget();
    $nb.Material->wpvisible       # true;
    $nb.untergruppen->wpcurrent   # 'nb.Verpackung';
    $rb.Material->wpdisabled      # n;
    $rb.Material->wpCheckState    # _WinStateChkChecked;
    $rb.Artikel->wpdisabled       # false;
    $rb.Artikel->wpCheckState     # _WinStateChkUnChecked;
    $rb.Verpackung->wpCheckState  # _WinStateChkUnChecked;
    $nb.Artikel->wpvisible        # false;
    $nb.Verpackung->wpvisible     # false;
    if (vTmp<>0) then vTmp->winfocusset();
  end;

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx       : int;
  vA      : alpha(250);
  vMenge  : float;
  vUpMask : logic;

  vNetto  : float;
  vBrutto : float;
  vStk    : int;
  vTmp    : int;
end;
begin

  if (aName='') then begin
    Ref_Kommission( w_Termproc='');
  end
  else if (aName='edLfs.P.Kommission') then begin
    Ref_Kommission( true );
  end;

  if (Mode=c_ModeList) then begin
    Erx # RecLink(441, 440, 4, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      vNetto # vNetto + Lfs.P.Gewicht.Netto;
      vBrutto # vBrutto + Lfs.P.Gewicht.Brutto;
      vStk   # vStk + "Lfs.P.Stück";
      Erx # RecLink(441, 440, 4, _recNext);
    END;

    $lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Sum.Netto->wpcaption    # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
    if ($lb.Sum.Brutto<>0) then
      $lb.Sum.Brutto->wpcaption    # ANum(vBrutto, Set.Stellen.Gewicht);
    MarkSum();
  end;


  // Verpackung?
  if ($nb.untergruppen->wpcurrent='nb.Verpackung') then begin
    if (aName='') or (aName='ed3Lfs.P.Artikelnr') then begin
      Erx # RecLink(250,441,3,_RecFirst);
      if (Erx>_rLocked) then begin
        $lb3.Bez1->wpcaption # '';
        $lb3.Bez2->wpcaption # '';
        $lb3.Bez3->wpcaption # '';
      end
      else begin
        $lb3.Bez1->wpcaption # Art.Bezeichnung1;
        $lb3.Bez2->wpcaption # Art.Bezeichnung2;
        $lb3.Bez3->wpcaption # Art.Bezeichnung3;
      end;
    end;
    Erx # RecLink(101,441,13,_RecFirst);    // Lagerort holen
    if (Erx>_rLocked) then RecBufClear(101);
//    $lb3.Lagerort->wpcaption # Adr.A.Stichwort;
  end;

  // Artikel?
  if ($nb.untergruppen->wpcurrent='nb.Artikel') then begin
    if (aName='') or (aName='edLfs.P.Kommission') then begin
      $lb2.Artikelnr->wpcaption # Lfs.P.Artikelnr;
      Erx # RecLink(250,441,3,_RecFirst);
      if (Erx>_rLocked) then begin
        $lb2.Bez1->wpcaption # '';
        $lb2.Bez2->wpcaption # '';
        $lb2.Bez3->wpcaption # '';
      end
      else begin
        $lb2.Bez1->wpcaption # Art.Bezeichnung1;
        $lb2.Bez2->wpcaption # Art.Bezeichnung2;
        $lb2.Bez3->wpcaption # Art.Bezeichnung3;
      end;
    end;
    Erx # RecLink(101,441,13,_RecFirst);    // Lagerort holen
    if (Erx>_rLocked) then RecBufClear(101);
//    $lb2.Lagerort->wpcaption # Adr.A.Stichwort;

    if (aName='') and
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew)) then begin
      if (Lfs.P.MEH.Einsatz='Stk') then
        Lib_guiCom:Disable($ed2Lfs.P.Stck)
      else
        Lib_guiCom:Disable($ed2Lfs.P.Stck)
    end;
  end;

  // Material?
  if ($nb.untergruppen->wpcurrent='nb.Material') then begin
    if (aName='') or (aName='ed1Lfs.P.Verwiegungsart') then begin
      Erx # RecLink(818,441,2,0);
      if (Erx<=_rLocked) then
        $Lb1.Verwiegungsart->wpcaption # Vwa.Bezeichnung.L1
      else
        $Lb1.Verwiegungsart->wpcaption # '';
    end;

    if (aName='') or (aName='ed1Lfs.P.Materialnr') then begin
      if (Lfs.P.Materialnr=0) then begin
        $lb1.Materialinfo->wpcaption  # '';
        $lb1.UrStueck->wpcaption  # '';
        $lb1.UrNetto->wpcaption   # '';
        $lb1.UrBrutto->wpcaption  # '';
        $lb1.UrMenge->wpcaption   # '';
        $lb1.UrVerwiegungsart->wpcaption   # '';
      end
      else begin
        Erx # RecLink(200,441,4,0);   // Material holen
        if (Erx<=_rLocked) then begin
          // VSB-Material
          if (Mat.Status=c_Status_EKVSB) then  Lfs.P.Materialtyp # c_IO_VSB;

          // 15.05.2014
//          Lfs.P.MEH.Einsatz # 'kg';
          Lfs.P.MEH             # Auf.P.MEH.Preis;
          Lfs.P.MEH.Einsatz     # Auf.P.MEH.Einsatz;

          if (Lfs.P.Kommission<>Mat.Kommission) and (Mat.Kommission<>'') then begin
            Lfs.P.Kommission    # Mat.Kommission;
            Lfs.P.Auftragsnr    # Mat.Auftragsnr;
            Lfs.P.AuftragsPos   # Mat.Auftragspos;
            Lfs.P.AuftragsPos2  # Mat.Auftragspos2;
            $ed1Lfs.P.Materialnr->winupdate(_WinUpdFld2Obj);
            Ref_Kommission(y);
          end;

          if (aName='ed1Lfs.P.Materialnr') and ($ed1Lfs.P.Materialnr->wpchanged) then begin
/*
            "Lfs.P.Stück"         # "Mat.Verfügbar.Stk";
            Lfs.P.Gewicht.Netto   # Mat.Gewicht.Netto;
            Lfs.P.Gewicht.Brutto  # Mat.Gewicht.Brutto;
            // 15.10.2013 AH
//            Lfs.P.Menge           # Mat.Gewicht.Brutto;
            Lfs.P.Menge # Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH);

            if ("Lfs.P.Stück"<0) then           "Lfs.P.Stück" # 0;
            if (Lfs.P.Gewicht.Netto<0.0) then   Lfs.P.Gewicht.Netto # 0.0;
            if (Lfs.P.Gewicht.Brutto<0.0) then  Lfs.P.Gewicht.Brutto # 0.0;
            if (Lfs.P.Menge<0.0) then           Lfs.P.Menge # 0.0;
*/
            Lib_Einheiten:TransferMengen('200>441,VLDAW');
          end;

          vA # "Mat.Güte";
          vA # vA + '   '+ANum(Mat.Dicke,Set.Stellen.Dicke);
          vA # vA +' x '+ANum(Mat.Breite,Set.Stellen.Breite);
          if ("Mat.Länge"<>0.0) then vA # vA +' x '+ANum("Mat.Länge","Set.Stellen.Länge")
          vA # vA + '   ';
          if ("Mat.AusführungOben"<>'') then vA # vA +'   O:'+"Mat.AusführungOben";
          if ("Mat.AusführungUnten"<>'') then vA # vA +'   U:'+"Mat.AusführungUnten";
          $lb1.MaterialInfo->wpcaption # vA;
          Erx # RecLink(818,200,10,_recFirst);    // Verwieungsart holen
          if (Erx<=_rLocked) then
            $lb1.UrVerwiegungsart->wpcaption  # Vwa.Bezeichnung.L1
          else
            $lb1.UrVerwiegungsart->wpcaption  # '';
          $lb1.UrStueck->wpcaption  # AInt(Mat.Bestand.Stk);
          $lb1.UrNetto->wpcaption   # Cnvaf(Mat.Gewicht.Netto,_fmtnumnogroup|_FmtNumNoZero,0,Set.Stellen.Gewicht)
          $lb1.UrBrutto->wpcaption  # Cnvaf(Mat.Gewicht.Brutto,_FmtNumNoZero|_fmtnumnogroup,0,Set.Stellen.Gewicht);

          // 15.10.2013 AH
          vMenge # Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH);
          $lb1.UrMenge->wpcaption      # ANum(vMenge,Set.Stellen.Menge);

          $ed1Lfs.P.Stck->winupdate(_WinUpdFld2Obj);
          $ed1Lfs.P.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
          $ed1Lfs.P.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
          $ed1Lfs.P.Menge->winupdate(_WinUpdFld2Obj);

        end
        else begin
          LFs.P.Materialnr # 0;
          $lb1.Materialinfo->wpcaption  # '';
          $lb1.UrStueck->wpcaption  # '';
          $lb1.UrNetto->wpcaption   # '';
          $lb1.UrBrutto->wpcaption  # '';
          $lb1.UrMenge->wpcaption   # '';
          $lb1.UrVerwiegungsart->wpcaption   # '';
        end;
      end;

    end;

  end;


  $Lb2.MEH.Einsatz->wpCaption # Lfs.P.MEH.Einsatz;
  $lb1.MEH1->wpcaption  # Lfs.P.MEH;
  $lb1.MEH2->wpcaption  # Lfs.P.MEH;
  $lb1.MEH3->wpcaption  # Lfs.P.MEH;
  $lb2.MEH->wpcaption   # Lfs.P.MEH;
  $lb3.MEH->wpcaption   # Lfs.P.MEH;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx       : int;
  vPos  : word;
  vKom  : alpha
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($edLfs.P.Position);

  // ST 2016-07-20: Bei Lohnfahraufträgen kommt die Verwiegungsart aus dem Auftrag
  if ($NB.Main->wpcustom='LFA') then
    Lib_GuiCom:Disable($ed1Lfs.P.Verwiegungsart);

  if (Mode=c_ModeNew) then begin
    Erx # RecLink(441,440,4,_RecLast);
    if (Erx>_rlocked) then begin
      vPos # 1;
    end
    else begin
      vPos # Lfs.P.Position + 1;
      vKom # Lfs.P.Kommission;
    end;
    RecBufClear(441);
    Lfs.P.Materialtyp # c_IO_Mat;
    Lfs.P.Nummer      # Lfs.Nummer;
    Lfs.P.Position    # vPos;
    Lfs.P.Kommission  # vKom;
    if (vKom<>'') then Ref_Kommission(y);

    $Lb.LFSNummer2->wpcaption # '';
    $Lb.P.Position->wpcaption # AInt(Lfs.P.Position);
  end;

  if (Mode=c_ModeEdit) then begin
    $Lb.LFSNummer2->wpcaption # AInt(Lfs.P.Nummer);
    $Lb.P.Position->wpcaption # AInt(Lfs.P.Position);
    if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) then begin
      Lib_guiCom:Disable($ed1Lfs.P.Materialnr)
      Lib_guiCom:Disable($bt1.Material);
    end;

    Lib_GuiCom:Disable($edLfs.P.Kommission);
    Lib_GuiCom:Disable($bt.Kommission);
    Lib_GuiCom:Disable($rb.Artikel);
    Lib_GuiCom:Disable($rb.Material);
    Lib_GuiCom:Disable($rb.Verpackung);

  end;

  SwitchMask();

  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then begin
    $edLfs.P.Kommission->WinFocusSet(true);
  end
  else begin
    if (Lfs.P.MaterialTyp=c_IO_Mat) or (Lfs.P.MaterialTyp=c_IO_VSB) then
      $edLfs.P.Bemerkung->WinFocusSet(true)
      //$ed1Lfs.P.Materialnr->WinFocusSet(true)
    else if (Lfs.P.MaterialTyp=c_IO_Art) then
      $ed2Lfs.P.Bemerkung->WinFocusSet(true)
      //$ed2Lfs.P.Art.Charge->WinFocusSet(true)
    else if (Lfs.P.MaterialTyp=c_IO_VPG) then
      $ed3Lfs.P.Bemerkung->WinFocusSet(true)
      //$ed3Lfs.P.Artikelnr->WinFocusSet(true)
  end;

  // Sonderfunktion:
  RunAFX('Lfs.P.RecInit.Post','');
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vBuf441 : int;
  vAdr    : int;
  vAns    : int;
  vKLim   : float;

  vPaket : logic;
  vErxPak,
  vErxMat : int;
  vOK     : logic;
  vKG     : float;
end;
begin
  // dynamische Pflichtfelder  berpr fen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Pr fung
  if (Lfs.P.Kommission='') then begin
    Msg(001200,Translate('Kommission'),0,0,0);
    $edLfs.P.Kommission->WinFocusSet(true);
    RETURN false;
  end;

  Auf.P.Nummer    # cnvia(Str_Token(Lfs.P.Kommission,'/',1));
  Auf.P.Position  # cnvia(Str_Token(Lfs.P.Kommission,'/',2));
  Auf.SL.LfdNr    # cnvia(Str_Token(Lfs.P.Kommission,'/',3));
  Erx # RecRead(401,1,_RecTest);
  if (Erx<=_rLocked) and (Auf.SL.lfdNr<>0) then begin
    Auf.SL.Nummer   # Auf.P.Nummer;
    Auf.SL.Position # Auf.P.Position;
    Erx # RecRead(409,1,0);
  end;
  if (Erx>_rLocked) then begin
    Lfs.P.Kommission    # '';
    Lfs.P.Auftragsnr    # 0;
    Lfs.P.Auftragspos   # 0;
    Msg(001201,Translate('Kommission'),0,0,0);
    $edLfs.P.Kommission->WinFocusSet(true);
    RETURN false;
  end;
  Lfs.P.Auftragsnr    # Auf.P.Nummer;
  Lfs.P.Auftragspos   # Auf.P.Position;

  if (Mode=c_modeList) then begin   // alle LFS-Positionen sichern
    Auswahl('Kopfdaten');
    RETURN false;
  end;


  // Artikel ?---------------------------------------------------------------------
  if (Lfs.P.Materialtyp=c_IO_Art) then begin
    if (Lfs.P.Art.Charge='') then begin
      Msg(001200,Translate('Charge'),0,0,0);
      $ed2Lfs.P.Art.Charge->WinFocusSet(true);
      RETURN false;
    end;
  end;  // Artikel

  // Verpackung -------------------------------------------------------------------
  if (Lfs.P.Materialtyp=c_IO_VPG) then begin
    if (Lfs.P.Art.Charge='') then begin
      Msg(001200,Translate('Charge'),0,0,0);
      $ed3Lfs.P.Art.Charge->WinFocusSet(true);
      RETURN false;
    end;
  end;  // Verpackung

  // Material? ------------------------------------------------------------------
  if (Lfs.P.Materialtyp=c_IO_Mat) or (Lfs.P.Materialtyp=c_IO_VSB) then begin
    if (Lfs.P.Materialnr=0) then begin
      Msg(001200,Translate('Materialnummer'),0,0,0);
      $ed1Lfs.P.Materialnr->WinFocusSet(true);
      RETURN false;
    end;
    if ("Lfs.P.Stück"<=0) then begin
      Msg(001200,Translate('St ckzahl'),0,0,0);
      $ed1Lfs.P.Stck->WinFocusSet(true);
      RETURN false;
    end;
    if ($Lb1.UrNetto->wpcaption<>'') and
      (Lfs.P.Gewicht.Netto<=0.0) then begin
      Msg(001200,Translate('Nettogewicht'),0,0,0);
      $ed1Lfs.P.Gewicht.Netto->WinFocusSet(true);
      RETURN false;
    end;
    if ($Lb1.UrBrutto->wpcaption<>'') and
      (Lfs.P.Gewicht.Brutto<=0.0) then begin
      Msg(001200,Translate('Bruttogewicht'),0,0,0);
      $ed1Lfs.P.Gewicht.Brutto->WinFocusSet(true);
      RETURN false;
    end;
    if (Lfs.P.Menge<=0.0) then begin
      Msg(001200,Translate('Menge'),0,0,0);
      $ed1Lfs.P.Menge->WinFocusSet(true);
      RETURN false;
    end;

    Erx # RecLink(200,441,4,0); // Material holen
    if (Erx>_rLocked) then begin
      Msg(001201,Translate('Material'),0,0,0);
      $ed1Lfs.P.Materialnr->WinFocusSet(true);
      RETURN false;
    end;



    if (Mode=c_ModeNew) then begin
      if ("Mat.Löschmarker"<>'') or
        ((Lfs.P.MaterialTyp=c_IO_Mat) and (Mat.Status>c_Status_bisFrei) and (Mat.Status<>c_Status_VSB) and (Mat.Status<>c_Status_VSBKonsi)) or
        ((Lfs.P.MaterialTyp=c_IO_VSB) and (Mat.Status<>c_Status_EKVSB)) then begin
        Msg(441002,'',0,0,0);
        $ed1Lfs.P.Materialnr->WinFocusSet(true);
        RETURN false;
      end;

      // für echten Lieferschein???
      if ($NB.Main->wpcustom<>'LFA') then begin
        if (RecLinkInfo(203,200,13,_recCount)>1) then begin
          Msg(441009,'',0,0,0);
          $ed1Lfs.P.Materialnr->WinFocusSet(true);
          RETURN false;
        end;
        if (RecLinkInfo(203,200,13,_recCount)=1) then begin
          RecLink(203,200,13,_recFirst);    // Reservierung holen
          if (Mat.R.Auftragsnr<>Lfs.P.Auftragsnr) or (Mat.R.Auftragspos<>Lfs.P.AuftragsPos) then begin
            Msg(441009,'',0,0,0);
            $ed1Lfs.P.Materialnr->WinFocusSet(true);
            RETURN false;
          end;
        end;
      end;

      // Lagerorte prüfen...
      if (RecLinkInfo(441,440,4,_recCount)>0) then begin
        vBuf441 # RecBufCreate(441);
        Erx # RecLink(vBuf441,440,4,_recFirst);
        WHILE (Erx<=_rLocked) do begin
          if (vBuf441->Lfs.P.Materialtyp=c_IO_Mat) or (vBuf441->Lfs.P.Materialtyp=c_IO_VSB) then begin
            Erx # RecLink(200,vBuf441,4,0); // Material holen
            if (Erx<=_rLocked) then begin
              vAdr # Mat.Lageradresse;
              vAns # Mat.Lageranschrift;
              BREAK;
            end;
          end;
          Erx # RecLink(vBuf441,440,4,_recNext);
        END;
        RecBufDestroy(vBuf441);
        if (vAdr<>0) then begin
          Erx # RecLink(200,441,4,0);     // Material holen
          if (vAdr<>Mat.Lageradresse) or (vAns<>Mat.Lageranschrift) then begin
            if (Msg(441003,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinIdYes) then begin
              $ed1Lfs.P.Materialnr->WinFocusSet(true);
              RETURN false;
            end;
          end;
        end;
      end;  // Lagerortspr fung

      // ST 2012-02-13: Paketlieferung
      // bei Paketnummer dann Informieren, dass das ganze Paket eingef gt wird
      vPaket # false;

      if (Mat.Paketnr <> 0) then begin
        if (Msg(441012,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinIdYes) then begin
          $ed1Lfs.P.Materialnr->WinFocusSet(true);
          RETURN false;
        end;
        vPaket # true;
      end;
    end;  // NEUANLAGE
  end;  // Material


  // Nummernvergabe
  // Satz zur ckspeichern & protokolieren

  Erx # RecLink(818,401,9,_recFirst); // Verwiegungsart Auftrag holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  if (Lfs.P.MaterialTyp=c_IO_VPG) then Lfs.P.Menge.Einsatz # Lfs.P.Menge;

  if (Lfs.P.MaterialTyp=c_IO_Mat) or (Lfs.P.MaterialTyp=c_IO_VSB) then begin

    if (VWA.NettoYN) then
      vKG # Lfs.P.Gewicht.Netto
    else
      vKG # Lfs.P.Gewicht.Brutto;

//    Lfs.P.MEH.Einsatz   # 'kg';  15.05.2014
    // 09.07.2015:
    if (LFs.P.MEH.Einsatz='kg') then
      Lfs.P.Menge.Einsatz # vKG
    else if (Lfs.P.MEH.Einsatz='t') then
      Lfs.P.Menge.Einsatz # Rnd(vKG / 1000.0, Set.Stellen.Menge);
    else if (Lfs.P.MEH.Einsatz='Stk') then
      Lfs.P.Menge.Einsatz # cnvfi("Lfs.P.Stück")
    else begin
      Lfs.P.Menge.Einsatz # Lib_Einheiten:WandleMEH(401, "Lfs.P.Stück", Lfs.P.Gewicht.Netto, Lfs.P.Menge, Lfs.P.MEH, Lfs.P.MEH.Einsatz);
    end;

    Lfs.P.UrsprungsmatNr # Lfs.P.Materialnr;
  end;




  if (Mode=c_ModeEdit) then begin // EDIT *********************

    TRANSON;
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) then begin
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n,ProtokollBuffer[441])=false) then begin;
        TRANSBRK;
        ErrorOutput;
        RETURN false;
      end;
    end;

    PtD_Main:Compare(gFile);

    if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) then begin
      if (Lfs.P.Auftragsnr<>0) then begin
        Erx # RecLink(401,441,5,_RecFirst);  // Auftragspos holen
        Auf_A_Data:RecalcAll(n);
      end;
    end;
    TRANSOFF;

  end
  else begin    // NEUANLAGE *********************

    if (vPaket = false) then begin

      // Kreditlimit pr fen...
      if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) and ("Set.KLP.LFS-Druck"<>'') and
        (Lfs.P.Auftragsnr <> 0) and (Lfs.P.AuftragsPos <> 0) then begin
        Erx # RecLink(401,441,5,_RecFirst);     // Auftragspos holen
        if (Erx>_rLocked) then RETURN false;
        Erx # RecLink(400,401,3,0);             // Auftragskopf holen
        if (Erx>_rLocked) then RETURN false;
        Erx # RecLink(100,400,1,_RecFirst);     // Kunde holen
        if (Adr.SperrKundeYN) then begin
          Msg(100005,Adr.Stichwort,0,0,0);
          RETURN false;
        end;
        Erx # RecLink(100,400,4,_recFirst);     // Rechnungsempf nger holen
        if (Adr.SperrKundeYN) then begin
          Msg(100005,Adr.Stichwort,0,0,0);
          RETURN false;
        end;
        if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFS-Druck",n, var vKLim,0,Auf.Nummer)=false) then RETURN false;
      end;


      // bereits in anderen VLDAWs?
      if (Lfs.P.Materialnr<>0) then begin
        vOK # y;
        vBuf441 # RecBufCreate(441);
        vBuf441->Lfs.P.Materialnr # Lfs.P.Materialnr;
        Erx # RecRead(vBuf441,3,0);     // bereits in VLDAW?
        WHILE (Erx<=_rMultikey) and (vBuf441->Lfs.P.Materialnr=Lfs.P.Materialnr) and (vOK) do begin
          // schon verbucht oder in LFA? (mehrfach Fahren pro Karte erleubt!!)
          // offener LFS?
          if (vBuf441->Lfs.P.zuBA.Nummer=0) and (vBuf441->Lfs.P.Datum.Verbucht=0.0.0) then VOK # false;
          Erx # RecRead(vBuf441,3,_RecNext);
        END;
        RecbufDestroy(vBuf441);
        if (vOK=False) then begin
          Msg(441010,'',0,0,0);
          RETURN false;
        end;
      end;

      TRANSON;

      Lfs.P.Anlage.Datum  # today;
      Lfs.P.Anlage.Zeit   # now;
      Lfs.P.Anlage.User   # gUsername;
      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;

      if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) then begin
        if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n)=false) then begin
          TRANSBRK;
          ErrorOutput;
          RETURN false;
        end;
      end;

      TRANSOFF;

    end
    else begin    // PAKET

      // Paket hinzuf gen
      Pak.Nummer  # Mat.Paketnr;
      Erx # RecRead(280,1,0);
      if (Erx <> _rOK) then begin
        // Das Paket konnte nicht gelesen werden
        Msg(441013,Aint(Mat.Paketnr),0,0,0);
        RETURN false;
      end;

      // Alle Paketpositionen lesen
      FOR   vErxPak # RecLink(281,280,1,_RecFirst);
      LOOP  vErxPak # RecLink(281,280,1,_RecNext);
      WHILE vErxPak = _rOK DO BEGIN

          // Material zum Paket lesen
          Mat.Nummer # Pak.P.MaterialNr;
          vErxMat # RecRead(200,1,0);
          if (vErxMat <> _rOK) OR (Mat.Paketnr <> Pak.P.Nummer) then begin
            //'Das Material x kann nicht dem Paket y zugeordnet werden');
            Msg(441014,Aint(Pak.P.Materialnr)+'|'+Aint(Mat.Paketnr),0,0,0);
            RETURN false;
          end;

          Lfs.P.UrsprungsmatNr  # Mat.Nummer;
          Lfs.P.Materialnr      # Mat.Nummer;
          Erx # RecLink(818,401,9,_recFirst); // Verwiegungsart Auftrag holen
          if (Erx>_rLocked) then begin
            RecBufClear(818);
            VwA.NettoYN # y;
          end;
          "Lfs.P.Verwiegungsart"  # Mat.Verwiegungsart;
          "Lfs.P.Paketnr"         # Pak.P.Nummer;

          // 15.05.2014
          if (Lib_Einheiten:TransferMengen('200>441,VLDAW')=false) then begin
            Msg(441014,Aint(Pak.P.Materialnr)+'|'+Aint(Mat.Paketnr),0,0,0);
            RETURN false;
          end;
/**
          Lfs.P.MEH.Einsatz   # 'kg';

          if (VWA.NettoYN) then
            Lfs.P.Menge.Einsatz # Lfs.P.Gewicht.Netto
          else
            Lfs.P.Menge.Einsatz # Lfs.P.Gewicht.Brutto;
          "Lfs.P.Stück"           # Mat.Bestand.Stk;
          "Lfs.P.Gewicht.Netto"   # Mat.Gewicht.Netto;
          "Lfs.P.Gewicht.Brutto"  # Mat.Gewicht.Brutto;
          if (Lfs.P.MEH = 'kg') then
            "Lfs.P.Menge"           # Mat.Gewicht.Brutto;
          if ("Lfs.P.Stück" = 0) then
            "Lfs.P.Stück" # 1;
***/
          // Lieferscheinposition speichern
          // Kreditlimit prüfen...
          if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) and ("Set.KLP.LFS-Druck"<>'') and
            (Lfs.P.Auftragsnr <> 0) and (Lfs.P.AuftragsPos <> 0) then begin
            Erx # RecLink(401,441,5,_RecFirst);     // Auftragspos holen
            if (Erx>_rLocked) then RETURN false;
            Erx # RecLink(400,401,3,0);             // Auftragskopf holen
            if (Erx>_rLocked) then RETURN false;
            Erx # RecLink(100,400,1,_RecFirst);     // Kunde holen
            if (Adr.SperrKundeYN) then begin
              Msg(100005,Adr.Stichwort,0,0,0);
              RETURN false;
            end;
            Erx # RecLink(100,400,4,_recFirst);     // Rechnungsempf nger holen
            if (Adr.SperrKundeYN) then begin
              Msg(100005,Adr.Stichwort,0,0,0);
              RETURN false;
            end;
            if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFS-Druck",n, var vKLim,0,Auf.Nummer)=false) then RETURN false;
          end;

          TRANSON;

          Lfs.P.Anlage.Datum  # today;
          Lfs.P.Anlage.Zeit   # now;
          Lfs.P.Anlage.User   # gUsername;
          Erx # RekInsert(gFile,0,'MAN');
          if (Erx<>_rOk) then begin
            TRANSBRK;
            Msg(001000+Erx,gTitle,0,0,0);
            RETURN False;
          end;

          if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<1000000000) then begin
            if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n)=false) then begin
              TRANSBRK;
              ErrorOutput;
              RETURN false;
            end;
          end;

          TRANSOFF;

          Lfs.P.Position # Lfs.P.Position + 1;
        // nächstes Paket
      END;

    end; // EO Paket hinzuf gen

  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx       : int;
  vPaket : int;
  vErx   : int;
end
begin

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  APPOFF();
  TRANSON;

  vPaket # Lfs.P.Paketnr;

  if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<100000000) then begin
    // bisherige VLDAW stornieren
    if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
      APPON();
      TRANSBRK;
      ErrorOutput;
      RETURN;
    end;

  end;

  Erx # RekDelete(gFile,0,'MAN');
  if (Erx<>_rOK) then begin
    APPON();
    TRANSBRK;
    Msg(441000,AInt(Lfs.P.Position),0,0,0);
    RETURN;
  end;


  // ggf. andere Positionen von diesem Paket löschen
  if (vPaket <> 0) then begin

    vErx # RecLink(441,440,4,_RecFirst);
    WHILE vErx = _rOK DO BEGIN

        if (Lfs.P.PaketNr <> vPaket) then begin
          vErx # RecLink(441,440,4,_RecNext);
          CYCLE;
        end;

      // bisherige VLDAW stornieren
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
        APPON();
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;

      Erx # RekDelete(gFile,0,'MAN');
      if (Erx<>_rOK) then begin
        APPON();
        TRANSBRK;
        Msg(441000,AInt(Lfs.P.Position),0,0,0);
        RETURN;
      end;

      vErx # RecLink(441,440,4,_RecFirst);
    END;     // LFS Loop
  end;

  APPON();
  TRANSOFF;

  RefreshIfm();
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  Erx     : int;
  vM      : float;
  vUr     : float;
  vBasis  : float;
  vTeil   : float;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (aEvt:Obj->wpname='jump') then begin
    if (aEvt:Obj->wpcustom='Detail') then
      if ($ed1Lfs.P.Materialnr->wpreadonly) then
        $ed1Lfs.P.Stck->winFocusset(false)
      else
        $ed1Lfs.P.Materialnr->winFocusset(false);
    if (aEvt:Obj->wpcustom='Kommission') then
      $edLfs.P.Kommission->winFocusset(false);
    RETURN true;
  end;

  // 2022-12-15 AH Umbau:
  if (aEvt:Obj->wpname='ed1Lfs.P.Menge') and (Lfs.P.Menge=0.0) then begin
    Erx # RekLink(818,401,9,_recFirst); // Verwiegungsart holen
    if (Erx<=_rLocked) then VWa.NettoYN # true;
    if (Lfs.P.MEH='kg') then begin
      if (VWa.NettoYN) then begin
        vM # Lfs.P.Gewicht.Netto;
      end
      else if (VWa.NettoYN=false) then begin
        vM # Lfs.P.Gewicht.Brutto;
      end;
    end
    else if (Lfs.P.MEH='Stk') then begin
      vM # cnvfi("Lfs.P.Stück");
    end
    else begin    // Dreisatz?
      vUr     # cnvfa($Lb1.UrMenge->wpcaption);
      // per STK?
      vBasis  # cnvfa($Lb1.UrStueck->wpcaption);
      vTeil   # cnvfi("Lfs.P.Stück");
      if (vBasis=0.0) or (vTeil=0.0) then begin
        // per Gewicht
        if (VWa.NettoYN) then begin
          vBasis  # cnvfa($Lb1.UrNetto->wpcaption);
          vTeil   # "Lfs.P.Gewicht.Netto";
        end
        else begin
          vBasis  # cnvfa($Lb1.UrBrutto->wpcaption);
          vTeil   # "Lfs.P.Gewicht.Brutto";
        end;
      end;

      if (vBasis<>0.0) and (vTeil<>0.0) then begin
        vM # Lib_berechnungen:Dreisatz(vUr, vBasis, vTeil);
      end

    end;
    Lfs.P.Menge # vM;
    $ed1Lfs.P.Menge->winupdate(_WinUpdOn | _WinUpdFld2Obj);
    $ed1Lfs.P.Menge->wpcaptionfloat # Lfs.P.Menge;
  end;


  // Auswahlfelder aktivieren
 if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
local begin
  Erx : int;
end;
begin
/***
  if (aEvt:Obj->wpname='edLfs.P.Kommission') and (Lfs.P.Kommission<>'') then begin
    RecBufClear(401);
    Auf.P.Nummer # cnvia(Str_Token(Lfs.P.Kommission,'/',1));
    Auf.P.Position # cnvia(Str_Token(Lfs.P.Kommission,'/',2));
    Erx # RecRead(401,1,_RecTest);
    if (Erx>_rLocked) then begin
      Lfs.P.Kommission    # '';
      Lfs.P.Auftragsnr    # 0;
      Lfs.P.Auftragspos   # 0;
      RecBufClear(401);
      Ref_Kommission(y);
      RETURN false;
    end;
    Lfs.P.Auftragsnr    # Auf.P.Nummer;
    Lfs.P.Auftragspos   # Auf.P.Position;
//    Ref_Kommission(y);
  end;
***/

// 15.05.2014
/*
  if (aEvt:Obj->wpname='ed1Lfs.P.Materialnr') and ($ed1Lfs.P.Materialnr->wpchanged) then begin
    if (Lfs.P.Materialnr=0) then RETURN false;
    Erx # RecLink(200,441,4,0);
    if (Erx>_rLocked) then RETURN false;
    Lfs.P.Materialtyp # c_IO_Mat;
    // VSB-Material
    if (Mat.Status=c_Status_EKVSB) then Lfs.P.Materialtyp # c_IO_VSB;
    Lfs.P.MEH.Einsatz # 'kg';
    "Lfs.P.Stück"         # "Mat.Verfügbar.Stk";
    Lfs.P.Gewicht.Netto   # Mat.Gewicht.Netto;
    Lfs.P.Gewicht.Brutto  # Mat.Gewicht.Brutto;
    Lfs.P.Menge           # Mat.Gewicht.Brutto;
    if ("Lfs.P.Stück"<0) then           "Lfs.P.Stück" # 0;
    if (Lfs.P.Gewicht.Netto<0.0) then   Lfs.P.Gewicht.Netto # 0.0;
    if (Lfs.P.Gewicht.Brutto<0.0) then  Lfs.P.Gewicht.Brutto # 0.0;
    if (Lfs.P.Menge<0.0) then           Lfs.P.Menge # 0.0;
    $ed1Lfs.P.Stck->winupdate(_WinUpdFld2Obj);
    $ed1Lfs.P.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
    $ed1Lfs.P.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
    $ed1Lfs.P.Menge->winupdate(_WinUpdFld2Obj);
  end;
*/

  // Verpackung??
  if (aEvt:Obj->wpname='ed3Lfs.P.Artikelnr') and (Lfs.P.Artikelnr<>'')
    and ($ed3LFs.P.Artikelnr->wpchanged) then begin
    Erx # RecLink(250,441,3,_RecFirst);
    if (Erx>_rLocked) then begin
      $ed3Lfs.P.Artikelnr->WinFocusSet(true);
      RETURN false;
    end;
    Lfs.P.Materialtyp   # c_IO_VPG;
    Lfs.P.MEH.Einsatz   # Art.MEH;
    Lfs.P.MEH           # Art.MEH;
  end;

  if (aEvt:Obj->wpname='ed2Lfs.P.Menge.Einsatz') and (Lfs.P.MEH.Einsatz='Stk') then begin
    "Lfs.P.Stück"  # cnvif(Lfs.P.Menge.Einsatz);
    $ed2Lfs.P.Stck->winupdate(_WinUpdOn | _WinUpdFld2Obj);
    $ed2Lfs.P.Stck->wpcaptionint # "Lfs.P.Stück";
  end;

  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx       : int;
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  vSel    : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vQ2     : alpha(4000);
end;

begin

  case aBereich of

    'Kopfdaten' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.Maske',here+':AusKopf');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vHdl2 # WinSearch(gMDI,'edLfs.Spediteurnr');
      vHdl  # WinSearch(gMDI,'DUMMYNEW');
      vHdl->wpcustom # cnvai(Erx);

      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain,_WinAddHidden);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      gMdi->WinUpdate(_WinUpdOn);
      vHdl2->winfocusset(true);
    end;


    'Kommission' : begin
      RecBufClear(401);
      WinEvtProcessSet(_WinEvtFocusTerm,n);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');

      if (Lfs.Kundennummer<>0) then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vQ # 'Auf.P.KundenNr = '+AInt(Lfs.Kundennummer)+' AND "Auf.P.Löschmarker"=''''';
        Lib_Sel:QRecList(0,vQ);
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Material' : begin
      Erx # RecLink(100,440,1,0);   // Kunde holen
      if (Erx>_rLocked) then RecBufClear(100);

      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      vQ # vQ + ' "Mat.Löschmarker" = '''' AND';
      vQ # vQ + ' ( (Mat.Status>=400 AND Mat.Status<=499) OR Mat.Status<100 OR Mat.Status=502 )';
      vQ # vQ + ' AND ( ( Mat.Auftragsnr=0 AND ( Mat.EigenmaterialYN OR (Mat.EigenMaterialYN=false AND Mat.Lieferant='+Cnvai(Adr.Lieferantennr,_FmtNumNoGroup)+') ) )'+
                         'OR LinkCount(Aufpos)>0 )';
      vQ2 # ' Auf.P.Kundennr = '+AInt(Lfs.Kundennummer);

      vHdl # SelCreate(200, gKey);
      vHdl->SelAddLink('',401, 200,16, 'Aufpos');
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
        Erx # vHdl->SelDefQuery('Aufpos', vQ2);
        if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);

    end;


    'Artikel3' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel3');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha( var vQ, 'Art.Typ', '=', 'VPG');
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Charge' : begin
      RecBufClear(252);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusCharge');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Lfs.P.Artikelnr);
      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '=', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Charge3' : begin
      Erx # RecLink(250,441,3,0);   // Artikel holen
      if (Erx>_rLocked) then RETURN;

        // mehre Chargen vorhanden?
        if (RecLinkInfo(252,250,4,_recCount)<=1) then RETURN;
        RecBufClear(252);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusCharge3');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

        vQ # '';
        Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
        Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
        Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
        Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);

        vHdl # SelCreate(252, gKey);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;
        Lib_GuiCom:RunChildWindow(gMDI);
      end;

    'Verwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VwA.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusKopf
//
//========================================================================
sub AusKopf()
begin
  if (Lfs.P.Nummer=0) then begin
    gTimer2 # SysTimerCreate(500,1,gMDI);    // ENDE!!!
    RETURN;
  end;

  gZLList->wpdisabled # false;
  Lib_GuiCom:SetWindowState(gMDI,true);

end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    Lfs.P.Verwiegungsart # VwA.Nummer;
  end;
  gSelected # 0;
  $ed1Lfs.P.Verwiegungsart->Winfocusset(false);
  RefreshIfm('ed1Lfs.P.Verwiegungsart',y);
end;


//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    RecLink(400,401,3,0);   // Auftragskopf holen
    Lfs.P.Kommission  # AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
  end;
  $edLfs.P.Kommission->Winfocusset(false);
  Ref_Kommission(y);
//  RefreshIfm('edLfs.P.Kommission',y);

  WinEvtProcessSet(_WinEvtFocusTerm,y);
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
begin

  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;

    Lfs.P.Materialnr  # Mat.Nummer;
    Lfs.P.Materialtyp # c_IO_Mat;
    
    
    // ST 2023-02-08 Proj. 2427/501 START
    // Liefermengenangabe aus Material übernehmen
    "Lfs.P.Stück"         # Mat.Bestand.Stk;
    Lfs.P.Gewicht.Netto   # Mat.Gewicht.Netto;
    Lfs.P.Gewicht.Brutto  # Mat.Gewicht.Brutto;
          
    if (Mat.Kommission <> '') then begin
      RekLink(401,200,16,0);
      Lfs.P.Verwiegungsart  # Auf.P.Verwiegungsart;
      RekLink(818,401,9,0); // Verwiegungsart lesen
    
      if (Auf.P.MEH.Wunsch =^  'kg') then begin
        if (VwA.NettoYN) then
          Lfs.P.Menge # Lfs.P.Gewicht.Netto;
        else if (VwA.BruttoYN) then
          Lfs.P.Menge # Lfs.P.Gewicht.Brutto;
      end else if (Auf.P.MEH.Wunsch =^ 'stk') then begin
        Lfs.P.Menge # CnvFi("Lfs.P.Stück");
      end else
        Lfs.P.Menge # Mat.Bestand.Menge;
        
    end;
    // 2023-02-08 Proj. 2427/501 ENDE
    
    
  end;
  // Focus auf Editfeld setzen:
  $ed1Lfs.P.Materialnr->Winfocusset(true);
  RefreshIfm('ed1Lfs.P.Materialnr',y);
end;


//========================================================================
//  AusArtikel3
//
//========================================================================
sub AusArtikel3()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;

    Lfs.P.Artikelnr   # Art.Nummer;
    Lfs.P.Art.Adresse # 0;
    Lfs.P.Art.Anschrift # 0;
    Lfs.P.Art.Charge  # '';
    Lfs.P.Materialtyp # c_IO_VPG;
    Lfs.P.MEH.Einsatz # Art.MEH;
    Lfs.P.MEH         # Art.MEH;
    $Lb2.MEH.Einsatz->wpCaption # LFs.P.MEH.Einsatz;
    $lb2.MEH->wpcaption # Lfs.P.MEH;
  end;
  // Focus auf Editfeld setzen:
  $ed3Lfs.P.Artikelnr->Winfocusset(true);
  RefreshIfm('ed1Lfs.P.Artikelnr',y);
end;


//========================================================================
//  AusCharge
//
//========================================================================
sub AusCharge()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    // Feldübernahme
    Lfs.P.Art.Charge    # Art.C.Charge.Intern;
    Lfs.P.Art.Adresse   # Art.C.Adressnr;
    Lfs.P.Art.Anschrift # Art.C.Anschriftnr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $ed2Lfs.P.Art.Charge->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm();
end;


//========================================================================
//  AusCharge3
//
//========================================================================
sub AusCharge3()
begin
  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    // Feldübernahme
    Lfs.P.Art.Charge    # Art.C.Charge.Intern;
    Lfs.P.Art.Adresse   # Art.C.Adressnr;
    Lfs.P.Art.Anschrift # Art.C.Anschriftnr;
//    $ed3Lfs.P.Art.Adresse->winupdate(_WinUpdFld2Obj);
//    $ed3Lfs.P.Art.Anschrift->winupdate(_WinUpdFld2Obj);
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $ed3Lfs.P.Art.Charge->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm();
end;


//========================================================================
//  EvtTimer
//
//========================================================================
sub EvtTimer (
  aEvt : event;
  aTimerId : int;
) : logic
begin

  // wenn aus Auftragsdatei, dann sofort ENDE
  if (w_Parent<>0) then begin
    if (w_Parent->wpname=GetDialogname('Auf.P.Verwaltung')) or (w_Parent->wpname=GetDialogname('Auf.Verwaltung')) then begin
//      Lfs_Data:Druck_LFS();
  //    Lfs_Data:Verbuchen(Lfs.Nummer, Today);
    end;
  end;

  Mode # c_modeCancel;  // sofort alles beenden!
  gMdi->winclose();

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx       : int;
  d_MenuItem  : int;
  vHdl        : int;
  vTransLFS   : logic;
  vNetto      : float;
  vBrutto     : float;
  vStk        : int;
end
begin

  if (Mode=c_ModeList) and ($lb.Sum.Netto->wpcustom = '') then begin
    Erx # RecLink(441, 440, 4, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      vNetto  # vNetto + Lfs.P.Gewicht.Netto;
      vBrutto # vBrutto + Lfs.P.Gewicht.Brutto;
      vStk    # vStk + "Lfs.P.Stück";
      Erx # RecLink(441, 440, 4, _recNext);
    END;

    //$lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Sum.Netto->wpcaption    # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
    $lb.Sum.Brutto->wpcaption    # ANum(vBrutto, Set.Stellen.Gewicht);
    MarkSum();
  end;

  gMenu # gFrmMain->WinInfo(_WinMenu);

  if (w_parent<>0) then begin
    if (w_Parent->wpname<>GetDialogname('Lfs.Maske')) and
      ((Lfs.Nummer=0) or (Lfs.Nummer=MyTmpNummer)) then begin
/*
      vHdl # gMdi->WinSearch('Save');
      if (vHdl <> 0) then vHdl->wpdisabled # n;
      vHdl # gMdi->WinSearch('Mnu.Save');
      if (vHdl <> 0) then vHdl->wpdisabled # n;
*/
    end;
  end;



  if (LFS.zuBA.Nummer<>0) then begin
    Erx # RecLink(702,441, 9,_recFirst);    // BA-Position holen
    if (Erx<=_rLocked) and (BAG.P.ZielVerkaufYN=false) then vTransLFS # Y;
  end;


  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0) or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0) or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0)or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0)or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0)or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0)or (lfs.zuBA.Nummer<>0) or
                       (Rechte[Rgt_Lfs_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Ins.Alles');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vTransLFS) or
                        (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0) or (Mode<>c_ModeNew) or
                       (Rechte[Rgt_Lfs_anlegen]=n);


  vHdl # gMenu->WinSearch('Mnu.Del.NotMark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (lfs.nummer<1000000000) or (vHdl->wpDisabled) or (Lfs.Datum.Verbucht<>0.0.0)or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Aendern]=n);

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Del.NotMark' : begin
      DeleteUnmarked();
    end;

    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='ed1Lfs.P.Stck') then Lfs_Subs:Calc_Stk($ed1Lfs.P.Stck);
      if (aEvt:Obj->wpname='ed1Lfs.P.Gewicht.Netto') then Lfs_Subs:Calc_Gew($ed1Lfs.P.Gewicht.Netto, var Lfs.P.Gewicht.Netto);
      if (aEvt:Obj->wpname='ed1Lfs.P.Gewicht.Brutto') then Lfs_Subs:Calc_Gew($ed1Lfs.P.Gewicht.Brutto, var Lfs.P.Gewicht.Brutto);
      //if (aEvt:Obj->wpname='ed1Lfs.P.Menge') then MTo_Data:BildeVorgabe(441,'Länge');
    end;


    'Mnu.Ins.Alles' : begin
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Lfs.P.Anlage.Datum, Lfs.P.Anlage.Zeit, Lfs.P.Anlage.User );
    end;

  end; // case


end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  Erx : int;
end;
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Kommission'       :   Auswahl('Kommission');
    'bt3.Artikel'         :   Auswahl('Artikel3');
    'bt1.Material'        :   Auswahl('Material');
    'bt2.Charge'          :   Auswahl('Charge');
    'bt3.Charge'          :   Auswahl('Charge3');
    'bt1.Verwiegungsart'  :   Auswahl('Verwiegungsart');

    'rb.Material' : begin
      Erx #  RecLink(401,441,5,_RecFirst);  // Auftrag holen
      // Material?
//      if (Auf.P.Wgr.Dateinr=c_Wgr_Material) or (Lfs.P.MaterialTyp=c_IO_VSB) then begin
      $nb.Material->wpvisible     # true;
      $nb.Untergruppen->wpcurrent # 'nb.Material';
      $nb.Artikel->wpvisible      # false;
      $nb.Verpackung->wpvisible   # false;
      Lfs.P.Artikelnr   # '';
      Lfs.P.MaterialNr  # 0;
      Lfs.P.Paketnr     # 0;
      Lfs.P.Art.Charge  # '';
//      end;
    end;

    'rb.Artikel' : begin
      Lfs.P.Artikelnr   # '';
      Lfs.P.MaterialNr  # 0;
      Lfs.P.Paketnr     # 0;
      Lfs.P.Art.Charge  # '';

      Erx #  RecLink(401,441,5,_RecFirst);
      RecLink(819,401,1,0);     // Warengruppe holen
      // Artikel?
//      if (Auf.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisArtikel) then begin
      Lfs.P.Artikelnr   # Auf.P.Artikelnr;
      Lfs.P.MaterialTyp # c_IO_Art;
      $nb.Artikel->wpvisible      # true;
      $nb.Untergruppen->wpcurrent # 'nb.Artikel';
      $nb.Material->wpvisible     # false;
      $nb.Verpackung->wpvisible   # false;
//      end;
    end;

    'rb.Verpackung'     : begin
      Lfs.P.Artikelnr   # '';
      Lfs.P.MaterialNr  # 0;
      Lfs.P.Paketnr     # 0;
      Lfs.P.Art.Charge  # '';
      Lfs.P.MaterialTyp # c_IO_VPG;

      $nb.Verpackung->wpvisible   # true;
      $nb.Untergruppen->wpcurrent # 'nb.Verpackung';
      $nb.Artikel->wpvisible      # false;
      $nb.Material->wpvisible     # false;
    end;
  end;

end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  Erx       : int;
  vStatus   : int;
  vHdl      : int;
end;
begin

  if ($lb.Mark.Stueck > 0) then begin  // ST 2022-02-22: Hotfix, ggf. ist Element "LbMark.Stueck" nicht für Betriebsuser vorhanden
    if (cnvia($lb.Mark.Stueck->wpcustom)<>CteInfo(gMarkList,_cteCount)) then begin
      MarkSum();
    end;
  end;
  
  if (aMark) then begin
    if (RunAFX('Lfs.P.EvtLstDataInit','y' + aEvt:obj->wpName)<0) then RETURN;
  end
  else if (RunAFX('Lfs.P.EvtLstDataInit','n' + aEvt:obj->wpName)<0) then RETURN;
  
  if (Lfs.P.MaterialTyp=c_IO_Art) then begin
    RecBufClear(200);
    RekLink(252,441,14,_recFirst);    // Charge holen
    Mat.Lagerplatz # Art.C.Lagerplatz;
  end
  else if (Lfs.P.MaterialTyp=c_IO_Theo) then begin
    gv.alpha.02 # '';
  end
  else begin
    Gv.Alpha.02 # AInt(Lfs.P.Materialnr);
    if (LFs.P.Materialtyp=c_IO_VSB) then
      Gv.Alpha.02 # c_Akt_VSB+' '+Gv.ALpha.02;
    Erx # Mat_data:read(Lfs.P.Materialnr)
    if (Erx<200) then RecBufClear(200);
  end;


  Gv.Alpha.03 # '';
  Gv.Alpha.04 # '';
  Gv.Alpha.05 # '';
  Gv.Alpha.06 # '';
  Gv.Alpha.07 # '';
  if (LFs.P.Materialtyp=c_IO_VSB) or (Lfs.P.Materialtyp=c_IO_Mat) then begin
    Erx # RecLink(200,441,4,_recFirst);     // Material holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,441,12,_recFirst);  // ~Material holen
      if (Erx<=_rLocked) then RecBufCopy(210,200);
    end;
    if (Mat.Nummer<>0) then begin
      Gv.Alpha.03 # ANum(Mat.Dicke,Set.Stellen.Dicke)+' x '+ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge"<>0.0) then Gv.Alpha.03 # Gv.ALpha.03 + ' x '+ANum("Mat.Länge","Set.Stellen.Länge");
      Gv.Alpha.04 # Mat.Coilnummer;
      Gv.ALpha.05 # Mat.Werksnummer;
      Gv.ALpha.07 # Mat.Chargennummer;

      Gv.Alpha.06 # Aint(Mat.Paketnr);

      // ST 2012-08-30: Artikelnr bie 209er Mat anzeigen
      RekLink(819,200,1,0);
      if (Wgr_Data:IstMix()) then
        Lfs.P.Artikelnr # Mat.Strukturnr;

      vStatus # Mat.Status;
    end;
  end;


  if (aMark=n) then begin
    if (Lfs.P.Datum.Verbucht<>0.0.0) then
        Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
    else if (vStatus>=c_Status_bestellt) and (vStatus<=c_Status_bisEK) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Bestellt)
  end;
//  Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
  SwitchMAsk();
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx     : int;
  vAdr    : int;
  vAns  : int;
  vErr  : int;
  vPar  : alpha;
end;
begin

  if (Lfs.P.Nummer=0) or (Lfs.P.Nummer>1000000000) then begin

    if (W_Parent<>0) then begin
      if (w_Parent->wpname=GetDialogname('Lfs.Maske')) then vPar # 'LFS';
      if (w_Parent->wpname=GetDialogname('BA1.P.LFA.Maske')) then vPar # 'LFA';
    end;

    // Lagerorte prüfen...
    vErr # 0;
    Erx # RecLink(441,440,4,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (Lfs.P.Materialtyp=c_IO_Mat) or (Lfs.P.Materialtyp=c_IO_VSB) then begin
        Erx # RecLink(200,441,4,0); // Material holen
        if (Erx<=_rLocked) then begin
          if (vAdr=0) then begin
            vAdr # Mat.Lageradresse;
            vAns # Mat.Lageranschrift;
          end;
          if (vAdr<>Mat.Lageradresse) or (vAns<>Mat.Lageranschrift) then
            vErr # 1;
        end;
      end;

      if (vPar='LFS') and (Lfs.P.Materialtyp=c_IO_VSB) then vErr # 2;

      Erx # RecLink(441,440,4,_recNext);
    END;
    if (vErr=1) then begin
      if (Set.LFS.MixAbholort='I') then begin
      end
      else if (Set.LFS.MixAbholort='S') then begin
        Msg(441004,'',_WinIcoError,_WinDialogok,1);
        RETURN false;
      end
      else begin
        Msg(441004,'',_WinIcoError,_WinDialogok,1);
      end;
    end;
    if (vErr=2) then begin
      Msg(441005,'',_WinIcoWarning,_WinDialogok,1);
      RETURN false;
    end;


    if (vPar='LFS') or (vPar='LFA') then begin
      RETURN true;
    end;


    if (RecLinkInfo(441,440,4,_reccount)<>0) then begin
      if (Msg(440000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
      WHILE (RecLink(441,440,4,_recFirst)<=_rLocked) do begin

        if (Lfs.P.Nummer<mytmpNummer) and (Lfs.P.Nummer<>0) then begin
          TODO('PANIK !!! Sie versuchen einen echten Lieferschein abzubrechen!!');
          RETURN false;
        end;

        Erx # RekDelete(441,0,'AUTO');
        if (Erx<>_rOK) then RETURN false;
      END;
    end;
  end;

  RETURN true;
end;



//========================================================================
//  MyEvtKeyItem
//            Keyboard in RecList/DataList
//========================================================================
sub MyEvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aRecID                : int;          // RecID
) : logic
local begin
  Erx       : int;
  vMark : logic;
  v441  : int;
  vPak  : int;
end;
begin
  if (aKey=_WinKeyReturn) and (Mode=c_ModeList) then RETURN true;

  // 31.01.2020
  if (akey=_WinKeyInsert) and (Mode=c_ModeList) then begin
    if (gFile<>0) and (gZLList->wpdbrecid<>0) then begin
      RecRead(gFile,0,0,gZLList->wpdbrecid);
      App_Main:Mark();

      vPak # Lfs.P.Paketnr;
      if (vPak<>0) then begin
        vMark  # Lib_Mark:IstMarkiert( gFile, RecInfo( gFile, _recId ));
        v441 # RekSave(441);
        // Positionen loopen
        FOR Erx # RecLink(441,440,4,_recFirst)
        LOOP Erx # RecLink(441,440,4,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Lfs.P.Paketnr<>vPak) then CYCLE;
          Lib_Mark:MarkSet(gFile, vMark, true);
        END;
        RekRestore(v441);
        RefreshList(gZLList, _WinLstRecFromRecid | _WinLstRecDoSelect);
      end;

      RETURN true;
    end;
  end;

  RETURN App_Main:EvtKeyItem(aEvt, aKey, aRecID);
end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edLfs.P.Kommission') AND (aBuf->Lfs.P.Kommission<>'')) then begin
    Auf.P.Nummer # BAG.F.Auftragsnummer;
    Auf.P.Position # BAG.F.Auftragspos;
    RecRead(401,1,0);
    Lib_Guicom2:JumpToWindow('Auf.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'ed3Lfs.P.Artikelnr') AND (aBuf->Lfs.P.Artikelnr<>'')) then begin
    RekLink(250,441,3,0);   // Artikelnumemr holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
  end;
  
  if ((aName =^ 'ed3Lfs.P.Art.Charge') AND (aBuf->Lfs.P.Art.Charge<>'')) then begin
    RekLink(252,441,14,0);   // Interne Charge holen
    Lib_Guicom2:JumpToWindow('Art.C.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================