
@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfs_RP_Main
//                      OHNE E_R_G
//  Info
//
//
//  19.10.2015  AH  Erstellung der Prozedur
//  12.05.2022  AH  ERX
//  25.07.2022  HA  Quick Jump
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
//    SUB AusAufAktion()
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
  cTitle :    'Rücklieferschein-Positionen'
  cFile :     441
  cMenuName : 'Lfs.P.Bearbeiten'
  cPrefix :   'Lfs_RP'
  cZList :    $ZL.Lfs.Positionen
  cKey :      1
end;

declare Auswahl(aBereich : alpha;)

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
Lib_Guicom2:Underline($ed1Lfs.P.Materialnr);
Lib_Guicom2:Underline($ed1Lfs.P.Verwiegungsart);

  SetStdAusFeld('edLfs.P.Kommission'      ,'Kommission');
  SetStdAusFeld('ed2Lfs.P.Art.Charge'     ,'Aktion');
  SetStdAusFeld('ed1Lfs.P.Verwiegungsart' ,'Verwiegungsart');
  SetStdAusFeld('ed1Lfs.P.Materialnr'     ,'Aktion');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Switchmask
//
//========================================================================
sub SwitchMask();
begin
  if ((Lfs.P.Materialtyp=c_IO_VSB) or (Lfs.P.Materialtyp=c_IO_Mat) or (Lfs.P.Materialtyp=0)) and ($nb.untergruppen->wpcurrent<>'nb.Material') then begin
    $nb.Material->wpvisible     # true;
    $nb.untergruppen->wpcurrent # 'nb.Material';
    $nb.Artikel->wpvisible      # false;
    $nb.Verpackung->wpvisible   # false;
  end;
  if ((Lfs.P.Materialtyp=c_IO_Art) or (Lfs.P.Materialtyp=1110)) and ($nb.untergruppen->wpcurrent<>'nb.Artikel') then begin
    $nb.Artikel->wpvisible      # true;
    $nb.untergruppen->wpcurrent # 'nb.Artikel';
    $nb.Material->wpvisible     # false;
    $nb.Verpackung->wpvisible   # false;
  end;
  if ((Lfs.P.Materialtyp=c_IO_VPG)) and ($nb.untergruppen->wpcurrent<>'nb.Verpackung') then begin
    $nb.Verpackung->wpvisible   # true;
    $nb.untergruppen->wpcurrent # 'nb.Verpackung';
    $nb.Artikel->wpvisible      # false;
    $nb.Material->wpvisible     # false;
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
  Lib_GuiCom:Pflichtfeld($ed1Lfs.P.Gewicht.Brutto);
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

  if (aChanged) then begin
    RecBufClear(401);
    Auf.P.Nummer    # cnvia(Str_Token(Lfs.P.Kommission,'/',1));
    Auf.P.Position  # cnvia(Str_Token(Lfs.P.Kommission,'/',2));
    Auf.SL.LfdNr    # cnvia(Str_Token(Lfs.P.Kommission,'/',3));
    Erx #  RecRead(401,1,0);
    if (Erx<>_rOk) then RecBufClear(401);
    Erx # RecLink(400,401,3,0);   // Auftragskopf holen
    if (Erx<>_rOk) then RecBufClear(400);
    if (Auf.SL.lfdNr<>0) then begin
      Auf.SL.Nummer   # Auf.P.Nummer;
      Auf.SL.Position # Auf.P.Position;
      Erx # RecRead(409,1,0);
      if (Erx<>_rOk) then RecBufClear(409);
    end;

    if (Lfs.Kundennummer=0) then begin  // Prüfung auf gleiche Anschriften
      Lfs.Kundennummer    # Auf.P.Kundennr;
      Lfs.Kundenstichwort # Auf.P.KundenSW;
      Lfs.Zieladresse     # Auf.Lieferadresse;
      Lfs.Zielanschrift   # Auf.Lieferanschrift;
    end
    else begin
      if (Auf.P.Nummer<>0) and
        (Lfs.Kundennummer<>Auf.P.Kundennr) then begin
        Lfs.P.Kommission # '';
        RecbufClear(400);
        RecbufClear(401);
        Msg(441006,gTitle,0,0,0);
        $edLfs.P.Kommission->winFocusset(false);
      end;
    end;

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
    Lfs.P.MEH.einsatz   # Auf.P.MEH.Einsatz;
    Lfs.P.MEH           # Auf.P.MEH.Preis;
    $edlfs.p.kommission->WinUpdate(_WinUpdFld2Obj);

    // Artikel?
    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      Lfs.P.Materialtyp # c_IO_Art;
      Lfs.P.Artikelnr # Auf.P.Artikelnr;
      Erx # RecLink(250,441,3,0);   // Artikel holen
      if (Erx>_rLocked) then RecBufClear(250);
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
    end;
  end;  // changed

  if (Lfs.P.Auftragsnr<>0) then begin
    $Lb.Kommission->wpcaption # Auf.P.KundenSW;
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

    $lb1.AufStueck->wpcaption     # AInt("Auf.P.Stückzahl");
    $lb2.AufStueck->wpcaption     # AInt("Auf.P.Stückzahl");
    if (VWa.NettoYN) then begin
      $lb1.AufNetto->wpcaption    # ANum(Auf.P.Gewicht,Set.Stellen.Gewicht);
      $lb1.AufBrutto->wpcaption   # '';
    end
    else begin
      $lb1.AufNetto->wpcaption    # '';
      $lb1.AufBrutto->wpcaption   # ANum(Auf.P.Gewicht,Set.Stellen.Gewicht);
    end;

    vMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
    $lb1.AufMenge->wpcaption      # ANum(vMenge,Set.Stellen.Menge);
    $lb2.AufMenge->wpcaption      # ANum(vMenge,Set.Stellen.Menge);
    $lb2.AufEinsatz->wpcaption    # ANum(Auf.P.Menge,Set.Stellen.Menge);
  end
  else begin
    $Lb.Kommission->wpcaption     # '';
    $lb.Auftragsinfo->wpcaption   # '';
    $lb1.AufStueck->wpcaption     # '';
    $lb2.AufStueck->wpcaption     # '';
    $lb1.AufNetto->wpcaption      # '';
    $lb1.AufBrutto->wpcaption     # '';
    $lb1.AufMenge->wpcaption      # '';
    $lb2.AufMenge->wpcaption      # '';
    $lb1.AufVerwiegungsart->wpcaption   # '';
  end;


  if (Lfs.P.Materialtyp=c_IO_Art) and ($nb.untergruppen->wpcurrent<>'nb.Artikel') then begin
    vTmp # Winfocusget();
    $nb.Artikel->wpvisible        # true;
    $nb.untergruppen->wpcurrent   # 'nb.Artikel';
    $nb.Material->wpvisible       # false;
    $nb.Verpackung->wpvisible     # false;
    if (vTmp<>0) then vTmp->winfocusset();
  end
  else if (Lfs.P.Materialtyp=c_IO_Mat) and ($nb.untergruppen->wpcurrent<>'nb.Material')then begin
    vTmp # Winfocusget();
    $nb.Material->wpvisible       # true;
    $nb.untergruppen->wpcurrent   # 'nb.Material';
    $nb.Artikel->wpvisible        # false;
    $nb.Verpackung->wpvisible     # false;
    if (vTmp<>0) then vTmp->winfocusset();
  end
  else if (Lfs.P.Materialtyp=c_IO_VPG) and ($nb.untergruppen->wpcurrent<>'nb.Verpackung')then begin
    vTmp # Winfocusget();
    $nb.Material->wpvisible       # true;
    $nb.untergruppen->wpcurrent   # 'nb.Verpackung';
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
  vStk    : int;
  vTmp    : int;
end;
begin

  if (aName='') or (aName='edLfs.P.Kommission') then begin
    Ref_Kommission( true );
  end;

  if (Mode=c_ModeList) then begin
    Erx # RecLink(441, 440, 4, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      vNetto # vNetto + Lfs.P.Gewicht.Netto;
      vStk   # vStk + "Lfs.P.Stück";
      Erx # RecLink(441, 440, 4, _recNext);
    END;

    $lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Sum.Netto->wpcaption    # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
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
    $lb2.Lagerort->wpcaption # Adr.A.Stichwort;

    if (aName='') and
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew)) then begin
      if (Lfs.P.MEH.Einsatz='Stk') then
        Lib_guiCom:Disable($ed2Lfs.P.Stck)
      else
        Lib_guiCom:Disable($ed2Lfs.P.Stck)
    end;

    if (aName='') or (aName='ed2Lfs.P.Art.Charge') then begin
      $lb2.Art.Adresse->wpCaption # aint(Lfs.P.Art.Adresse);
      $lb2.Art.Anschr->wpCaption  # aint(Lfs.P.Art.Anschrift);

      if (Lfs.P.Art.Charge='') then begin
        $lb2.UrStueck->wpcaption    # '';
        $lb2.UrEinsatz->wpcaption   # '';
        $lb2.UrMenge->wpcaption     # '';
      end
      else begin
        Erx # RecLink(404,441,16,_recFirst);    // Art.Charge holen = AUF.AKTION holen
        if (Erx<=_rLocked) and ("Lfs.P.Rück.Aktion"<>0) then begin

          Lfs.P.MEH             # Auf.P.MEH.Preis;
          Lfs.P.MEH.Einsatz     # Auf.P.MEH.Einsatz;

          $lb2.UrStueck->wpcaption    # AInt("Auf.A.Stückzahl");
          $lb2.UrEinsatz->wpcaption   # ANum(Auf.A.Menge, Set.Stellen.Menge);
          $lb2.UrMenge->wpcaption     # ANum(Auf.A.Menge.Preis,Set.Stellen.Menge);

          $ed2Lfs.P.Stck->winupdate(_WinUpdFld2Obj);
          $ed2Lfs.P.Menge.Einsatz->winupdate(_WinUpdFld2Obj);
          $ed2Lfs.P.Menge->winupdate(_WinUpdFld2Obj);
        end
        else begin
          Lfs.P.Art.Charge    # '';
          Lfs.P.Art.Adresse   # 0;
          Lfs.P.Art.Anschrift # 0;
          $lb2.UrStueck->wpcaption    # '';
          $lb2.UrEinsatz->wpcaption   # '';
          $lb2.UrMenge->wpcaption     # '';
        end;
      end;
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
//        Erx # RecLink(200,441,4,0);   // Material holen
//        if (Erx<=_rLocked) then begin
        // 06.04.2017 AH: mit RESTORE
        if (Mat_Data:Read(Lfs.P.Materialnr)>=200) then begin
          // VSB-Material
          if (Mat.Status=c_Status_EKVSB) then  Lfs.P.Materialtyp # c_IO_VSB;

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

          if ("Lfs.P.Rück.Aktion"<>0) then begin
            Erx # RecLink(404,441,16,_recFirst);  // ursprüngliche LFS-Aktion holen
            if (Erx<=_rLocked) then
              vMenge # Auf.A.Menge.Preis;
          end
          else begin
            vMenge # Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH);
          end;
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


  $Lb2.MEH.Einsatz->wpCaption   # Lfs.P.MEH.Einsatz;
  $Lb2.MEH.Einsatz2->wpCaption  # Lfs.P.MEH.Einsatz;
  $Lb2.MEH.Einsatz3->wpCaption  # Lfs.P.MEH.Einsatz;
  $lb1.MEH1->wpcaption  # Lfs.P.MEH;
  $lb1.MEH2->wpcaption  # Lfs.P.MEH;
  $lb1.MEH3->wpcaption  # Lfs.P.MEH;
  $lb2.MEH->wpcaption   # Lfs.P.MEH;
  $lb2.MEH2->wpcaption  # Lfs.P.MEH;
  $lb2.MEH3->wpcaption  # Lfs.P.MEH;
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
  vPos : word;
end;
begin

  $ed1Lfs.P.Materialnr->wpreadonly # true;
  $ed2Lfs.P.Art.Charge->wpreadonly # true;

  if (Mode=c_ModeNew) then begin
    Erx # RecLink(441,440,4,_RecLast);
    if (Erx>_rlocked) then
      vPos # 1
    else
      vPos # Lfs.P.Position + 1;
    RecBufClear(441);
    Lfs.P.Materialtyp # c_IO_Mat;
    Lfs.P.Nummer      # Lfs.Nummer;
    Lfs.P.Position    # vPos;
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
  end;

  SwitchMask();

  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then begin
    $edLfs.P.Kommission->WinFocusSet(true);
  end
  else begin
    if (Lfs.P.MaterialTyp=c_IO_Mat) or (Lfs.P.MaterialTyp=c_IO_VSB) then
      $ed1Lfs.P.Stck->WinFocusSet(true)
    else if (Lfs.P.MaterialTyp=c_IO_Art) then
      $ed2Lfs.P.Menge.Einsatz->WinFocusSet(true)
    else if (Lfs.P.MaterialTyp=c_IO_VPG) then
      $ed3Lfs.P.Stck->WinFocusSet(true);

  end;

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


  if ("Lfs.P.Stück"=0) then begin
    Msg(001200,Translate('St ckzahl'),0,0,0);
    $ed1Lfs.P.Stck->WinFocusSet(true);
    RETURN false;
  end;
  if (Lfs.P.Menge=0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $ed1Lfs.P.Menge->WinFocusSet(true);
    RETURN false;
  end;


  // Artikel?---------------------------------------------------------------------
  if (Lfs.P.Materialtyp=c_IO_Art) then begin
    if (Lfs.P.Art.Charge='') then begin
      Msg(001200,Translate('Charge'),0,0,0);
      $ed2Lfs.P.Art.Charge->WinFocusSet(true);
      RETURN false;
    end;
  end;  // ARTIKEL -----------------------------------------------------------------

  // Material? ------------------------------------------------------------------
  if (Lfs.P.Materialtyp=c_IO_Mat) or (Lfs.P.Materialtyp=c_IO_VSB) then begin
    if (Lfs.P.Materialnr=0) then begin
      Msg(001200,Translate('Materialnummer'),0,0,0);
      $ed1Lfs.P.Materialnr->WinFocusSet(true);
      RETURN false;
    end;

    //Erx # RecLink(200,441,4,0); // Material holen
    Erx # Mat_Data:Read(Lfs.P.Materialnr);
    if (Erx<>200) and (Erx<>210) then begin
      Msg(001201,Translate('Material'),0,0,0);
      $ed1Lfs.P.Materialnr->WinFocusSet(true);
      RETURN false;
    end;

    if (Lfs.P.Gewicht.Netto=0.0) then begin
      Msg(001200,Translate('Nettogewicht'),0,0,0);
      $ed1Lfs.P.Gewicht.Netto->WinFocusSet(true);
      RETURN false;
    end;
    if (Lfs.P.Gewicht.Brutto=0.0) then begin
      Msg(001200,Translate('Bruttogewicht'),0,0,0);
      $ed1Lfs.P.Gewicht.Brutto->WinFocusSet(true);
      RETURN false;
    end;

    if (Mode=c_ModeNew) then begin

/*** TODO MATPRÜFUNG
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
***/
      // Lagerorte prüfen...
      if (RecLinkInfo(441,440,4,_recCount)>0) then begin
        vBuf441 # RecBufCreate(441);
        Erx # RecLink(vBuf441,440,4,_recFirst);
        WHILE (Erx<=_rLocked) do begin
          if (vBuf441->Lfs.P.Materialtyp=c_IO_Mat) or (vBuf441->Lfs.P.Materialtyp=c_IO_VSB) then begin
            //Erx # RecLink(200,vBuf441,4,0); // Material holen
            //if (Erx<=_rLocked) then begin
            Erx # Mat_Data:Read(vBuf441->Lfs.P.Materialnr);
            if (Erx>=200) then begin
              vAdr # Mat.Lageradresse;
              vAns # Mat.Lageranschrift;
              BREAK;
            end;
          end;
          Erx # RecLink(vBuf441,440,4,_recNext);
        END;
        RecBufDestroy(vBuf441);
        if (vAdr<>0) then begin
//          Erx # RecLink(200,441,4,0);     // Material holen
          Erx # Mat_Data:Read(Lfs.P.Materialnr);
          if (vAdr<>Mat.Lageradresse) or (vAns<>Mat.Lageranschrift) then begin
            if (Msg(441003,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinIdYes) then begin
              $ed1Lfs.P.Materialnr->WinFocusSet(true);
              RETURN false;
            end;
          end;
        end;
      end;  // Lagerortsprüfung

      // Paketlieferung...
      // bei Paketnummer dann Informieren, dass das ganze Paket eingef gt wird
      vPaket # false;
// 14.03.2022 AH
//      if (Mat.Paketnr <> 0) then begin
//        if (Msg(441012,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinIdYes) then begin
//          $ed1Lfs.P.Materialnr->WinFocusSet(true);
//          RETURN false;
//        end
//        else begin
//          vPaket # true;
//        end;
//      end;

    end;  // NEUANLAGE

  end;  // Logik-Material -------------------------------------------------------

  // Nummernvergabe
  // Satz zur ckspeichern & protokolieren

  // Mengen negieren
  "Lfs.P.Stück"         # - Abs("Lfs.P.Stück");
  Lfs.P.Gewicht.Netto   # - Abs(Lfs.P.Gewicht.Netto);
  Lfs.P.Gewicht.Brutto  # - Abs(Lfs.P.Gewicht.Brutto);
  Lfs.P.Menge           # - Abs(Lfs.P.Menge);
  Lfs.P.Menge.Einsatz   # - Abs(Lfs.P.Menge.Einsatz);


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
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (aEvt:Obj->wpname='jump') then begin
    if (aEvt:Obj->wpcustom='Detail') then begin
      if (Lfs.P.Materialtyp=c_IO_Art) then begin
        if (Mode=c_ModeEdit) then
          $ed2Lfs.P.Menge.Einsatz->winFocusset(false);
        else
          $ed2Lfs.P.Art.Charge->winFocusset(false);
      end
      else begin
        if (Mode=c_ModeEdit) then
          $ed1Lfs.P.Stck->winFocusset(false);
        else
          $ed1Lfs.P.Materialnr->winFocusset(false);
        end;
    end;

    if (aEvt:Obj->wpcustom='Kommission') then
      $edLfs.P.Kommission->winFocusset(false);
    RETURN true;
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
begin

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
        vQ # 'Auf.P.KundenNr = '+AInt(Lfs.Kundennummer);
        vQ # vQ + ' AND LinkCount(AufKopf)>0';

        Lib_Sel:QAlpha(var vQ2, 'Auf.Vorgangstyp', '=', c_AUF);

//        Lib_Sel:QRecList(0,vQ);
        vHdl # SelCreate(401, gKey);
        vHdl->SelAddLink('',400, 401,3, 'AufKopf');
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);
        Erx # vHdl->SelDefQuery('AufKopf', vQ2);
        if (Erx != 0) then Lib_Sel:QError(vHdl);

        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Aktion' : begin
      Erx # RecLink(100,440,1,0);   // Kunde holen
      if (Erx>_rLocked) then RecBufClear(100);

      Erx #  RecLink(401,441,5,_RecFirst);  // Auftrag holen
      if (Erx>_rLocked) then RETURN;

      RecBufClear(404);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.A.Verwaltung',here+':AusAufAktion');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ,    'Auf.A.Nummer', '=', Lfs.P.Auftragsnr);
      Lib_Sel:QInt(var vQ,    'Auf.A.Position', '=', Lfs.P.AuftragsPos);

      Lib_Sel:QAlpha(var vQ,  'Auf.A.Aktionstyp', '=', C_Akt_LFS,'AND (');
      Lib_Sel:QAlpha(var vQ,  'Auf.A.Aktionstyp', '=', C_Akt_DFAKT, 'OR');
      vQ # vQ + ')';
      Lib_Sel:QAlpha(var vQ,  'Auf.A.Löschmarker', '=', '');

      vHdl # SelCreate(404, gKey);
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

  WinEvtProcessSet(_WinEvtFocusTerm,y);
end;


//========================================================================
//  AusAufAktion
//
//========================================================================
sub AusAufAktion()
begin

  if (gSelected=0) then RETURN;

  RecRead(404,0,_RecId,gSelected);
  gSelected # 0;

  "Lfs.P.Rück.Aktion" # Auf.A.Aktion;

  if (Auf.A.Materialnr<>0) then begin
    Lfs.P.Materialtyp   # c_IO_Mat;
    Lfs.P.Materialnr    # Auf.A.Materialnr;
    Lfs.P.Artikelnr     # '';
    Lfs.P.MEH.Einsatz   # Auf.A.MEH;
    Lfs.P.MEH           # Auf.A.MEH;
    Lfs.P.Art.Charge    # '';
    LFs.P.Art.Adresse   # 0;
    LFs.P.Art.Anschrift # 0;
  end
  else begin
    Lfs.P.Materialtyp   # c_IO_Art;
    Lfs.P.Materialnr    # 0;
    Lfs.P.Artikelnr     # Auf.A.Artikelnr;
    Lfs.P.MEH.Einsatz   # Auf.A.MEH;
    Lfs.P.MEH           # Auf.A.MEH;

    Lfs.P.Art.Charge    # Auf.A.Charge;
    LFs.P.Art.Adresse   # Auf.A.Charge.Adresse;
    LFs.P.Art.Anschrift # Auf.A.Charge.Anschr;
  end;
  $Lb2.MEH.Einsatz->wpCaption   # LFs.P.MEH.Einsatz;
  $Lb2.MEH.Einsatz2->wpCaption  # LFs.P.MEH.Einsatz;
  $Lb2.MEH.Einsatz3->wpCaption  # LFs.P.MEH.Einsatz;
  $lb2.MEH->wpcaption           # Lfs.P.MEH;
  $lb2.MEH2->wpcaption          # Lfs.P.MEH;
  $lb2.MEH3->wpcaption          # Lfs.P.MEH;


  // Focus auf Editfeld setzen:
  if (Lfs.P.Materialtyp=c_IO_Art) then begin
    $ed2Lfs.P.Art.Charge->Winfocusset(true);
    RefreshIfm('ed2Lfs.P.Art.Charge',y);
  end
  else begin
    $ed1Lfs.P.Materialnr->Winfocusset(true);
    RefreshIfm('ed1Lfs.P.Materialnr',y);
  end;
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
  vStk        : int;
end
begin

  if (Mode=c_ModeList) and ($lb.Sum.Netto->wpcustom = '') then begin
    Erx # RecLink(441, 440, 4, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      vNetto # vNetto + Lfs.P.Gewicht.Netto;
      vStk   # vStk + "Lfs.P.Stück";
      Erx # RecLink(441, 440, 4, _recNext);
    END;

    $lb.Sum.Netto->wpcaption    # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
  end;

  gMenu # gFrmMain->WinInfo(_WinMenu);

  if (w_parent<>0) then begin
    if (w_Parent->wpname<>GetDialogname('Lfs.Maske')) and
      ((Lfs.Nummer=0) or (Lfs.Nummer=MyTmpNummer)) then begin
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
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Kommission'       :   Auswahl('Kommission');
    'bt1.Material'        :   Auswahl('Aktion');
    'bt2.Charge'          :   Auswahl('Aktion');
    'bt1.Verwiegungsart'  :   Auswahl('Verwiegungsart');
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
  vStatus : int;
end;
begin
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
  if (LFs.P.Materialtyp=c_IO_VSB) or (Lfs.P.Materialtyp=c_IO_Mat) then begin
//    Erx # RecLink(200,441,4,_recFirst);     // Material holen
//    if (Erx>_rLocked) then begin
//      Erx # RecLink(210,441,12,_recFirst);  // ~Material holen
//      if (Erx<=_rLocked) then RecBufCopy(210,200);
//    end;
    Erx # Mat_Data:Read(Lfs.P.Materialnr);
    if (Erx>=200) then begin
      Gv.Alpha.03 # ANum(Mat.Dicke,Set.Stellen.Dicke)+' x '+ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge"<>0.0) then Gv.Alpha.03 # Gv.ALpha.03 + ' x '+ANum("Mat.Länge","Set.Stellen.Länge");
      Gv.Alpha.04 # Mat.Coilnummer;
      Gv.ALpha.05 # Mat.Werksnummer;

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
  Erx       : int;
  vAdr  : int;
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
        //Erx # RecLink(200,441,4,0); // Material holen
        //if (Erx<=_rLocked) then begin
        Erx # Mat_Data:Read(Lfs.P.Materialnr);
        if (Erx>=200) then begin
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
  
  if ((aName =^ 'ed1Lfs.P.Materialnr') AND (aBuf->Lfs.P.Materialnr<>0)) then begin
    RekLink(210,441,12,0);   // Materialnumemr holen
    Lib_Guicom2:JumpToWindow('Auf.A.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'ed1Lfs.P.Verwiegungsart') AND (aBuf->Lfs.P.Verwiegungsart<>0)) then begin
    RekLink(818,441,2,0);   // Verweigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
   
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================