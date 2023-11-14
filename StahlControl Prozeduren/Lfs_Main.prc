@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfs_Main
//                  OHNE E_R_G
//  Info
//
//
//  15.03.2004  AI  Erstellung der Prozedur
//  05.05.2011  TM  neue Auswahlmethode 1326/75
//  03.02.2012  AI  TheorieFM mit Datum
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  21.06.2012  ST  Sub "Start" hinzugefügt, Basierend auf Adr_P_Main (Prj: 1381/76)
//  28.04.2014  AH  Neu: Zielort ändern
//  19.10.2015  AH  Rücklieferschein
//  08.06.2016  ST  DataList: Rücklieferscheinkennung in eigenem Feld, damit man
//                    über Lfs.Nummer wieder schnell sortieren kann
//  17.01.2018  ST  Verladeanweisung auch bei Fahraufträgen druckbar
//  29.11.2018  ST  Recht "Rgt_LFS_Druck_LFA" integriert
//  16.04.2021  AH  KLimit-Freigabe
//  04.11.2021  AH  ERX; GesamtFM für Versand
//  12.01.2022  AH  Neue Feld "Lfs.PosNettogewicht"
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB Start(  opt aRecId  : int;  opt aView   : logic) : logic;
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB EvtMdiActivate( aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSpediteur()
//    SUB AusPositionen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int;  aSelecting : logic;) : logic
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
  cTitle :    'Lieferscheine'
  cFile :     440
  cMenuName : 'Lfs.Bearbeiten'
  cPrefix :   'Lfs'
  cZList :    $ZL.Lieferscheine
  cKey :      1
end;

//========================================================================
//  Start
//      Startet das Fenster ein
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aView   : logic) : logic;
local begin
  vHdl  : int;
  vNew  : logic;
end;
begin

 if (Rechte[Rgt_Lieferschein]=false) then RETURN false;

  // bereits offen?
  if ( gMDILfs <> 0 ) then begin
    // komisches Fenster? -> ENDE
    if ( gMDILfs->wpName != 'Lfs.Verwaltung' ) then RETURN false;

    VarInstance( WindowBonus, CnvIA( gMDILfs->wpCustom ) );

    // komischer Modus? -> ENDE
    if ( Mode <> c_ModeList ) and ( Mode <> c_ModeView ) then begin
      if (gMDI<>0) then VarInstance( WindowBonus, CnvIA( gMDI->wpCustom ) );
      RETURN false;
    end;

    if (aRecID<>0) then begin
      // Eventuelle Selektion entfernen
      vHdl # gZLList->wpDbSelection;
      if ( w_SelName != '' and vHdl != 0 ) then begin
        gZLList->wpAutoUpdate  # false;
        gZLList->wpDbSelection # 0
        SelClose( vHdl );
        SelDelete( gFile, w_selName );
      end;
    end;
  end;

  if ( gMdiLfs = 0 ) then begin
    gMdiLfs # Lib_GuiCom:OpenMdi( gFrmMain, 'Lfs.Verwaltung', _winAddHidden );
    vNew    # true;
  end;

  VarInstance( WindowBonus, CnvIA( gMDILfs->wpCustom ) );

  if (aRecId<>0) then begin
    if (aView) then
      Mode       # c_ModeBald + c_ModeView
    else
      Mode       # c_ModeBald + c_ModeList;
    w_Command  # 'REPOS';
    w_Cmd_Para # aInt( aRecId );
  end;

  if ( vNew ) then begin
    gMdiLfs->WinUpdate( _winUpdOn )
    gMdiLfs->WinFocusSet( true );
  end
  else begin
    Lib_guiCom:ReOpenMDI(gMDILfs);
  end;
end;



//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  RecRead(440,1,_recLast);    // ans Ende springen

  // Aus Auftragsdatei??? -> Schnellieferschein...
  if (w_Parent<>0) then begin
    if (w_Parent->wpname=GetDialogname('Auf.P.Verwaltung')) or (w_Parent->wpname=GetDialogname('Auf.Verwaltung')) then begin
      RecBufClear(440);
      Lfs.Nummer          # myTmpNummer;
      Lfs.Anlage.Datum    # today;
      Lfs.Kundennummer    # Auf.P.Kundennr;
      Lfs.Kundenstichwort # Auf.P.KundenSW;
      Lfs.Zieladresse     # Auf.Lieferadresse;
      Lfs.Zielanschrift   # Auf.Lieferanschrift;
      Lfs.Kosten.PEH      # 1000;
      Lfs.Kosten.MEH      # 'kg';
      Erx # RecLink(441,440,4,_recFirst);   // 1. Pos holen
      if (Erx<=_rLocked) then begin
        if (Lfs.P.Materialtyp=c_IO_Art) then begin
          Erx # RecLink(250,441,3,0);   // Artikel holen
          Lfs.Kosten.PEH      # Art.PEH;
          Lfs.Kosten.MEH      # Art.MEH;
        end;
      end;
    end;
  end;

  Lib_Guicom2:Underline($edLfs.Spediteurnr);
  Lib_Guicom2:Underline($edLfs.Kundennummer);
  Lib_Guicom2:Underline($edLfs.Zieladresse);
  Lib_Guicom2:Underline($edLfs.Zielanschrift);

  SetStdAusFeld('edAdr.Sprache'        ,'Sprache');
  SetStdAusFeld('edLfs.Spediteurnr'    ,'Spediteur');
  SetStdAusFeld('edLfs.Kundennummer'   ,'Kunde');
  SetStdAusFeld('edLfs.Zieladresse'    ,'Lieferadresse');
  SetStdAusFeld('edLfs.Zielanschrift'  ,'Lieferanschrift');
  SetStdAusFeld('edLfs.Kosten.MEH'     ,'MEH');

  RunAFX('Lfs.Init.Pre',aint(aEvt:Obj));

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  if (Lfs.zuBA.Nummer=0) then
    Lib_GuiCom:Pflichtfeld($edLfs.Kundennummer);
  Lib_GuiCom:Pflichtfeld($edLfs.Zieladresse);
  Lib_GuiCom:Pflichtfeld($edLfs.Zielanschrift);
  Lib_GuiCom:Pflichtfeld($edLfs.Kosten.PEH);
  Lib_GuiCom:Pflichtfeld($edLfs.Kosten.MEH);
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl  : int;
end;
begin
  App_Main:EvtMdiActivate(aEvt);
  vHdl # Winsearch(aEvt:obj, 'Mnu.Filter.Geloescht');
  if (vHdl<>0) then vHdl->wpMenuCheck # Filter_VSD;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx : int;
  vTmp  : int;
  v702 : int;
end;
begin

  if (aName='') then begin

    $bt.Text->wpdisabled # (Mode<>c_ModeView);

    $Lb.Wiegung1.Datum->wpcaption # cnvad(LFs.Wiegung1.Datum);
    $Lb.Wiegung2.Datum->wpcaption # cnvad(LFs.Wiegung2.Datum);
    $Lb.Wiegung1.Zeit->wpcaption # cnvat(LFs.Wiegung1.Zeit);
    $Lb.Wiegung2.Zeit->wpcaption # cnvat(LFs.Wiegung2.Zeit);

    $lb.Positionsgewicht->wpcaption    # ANum(Lfs.Positionsgewicht, Set.Stellen.Gewicht);
    if (Mode=c_ModeNew) or (mode=c_ModeEdit) then begin
      if (Lfs.SpediteurNr<>0) then
        Lib_GuiCom:Disable($edLfs.Spediteur)
      else
        Lib_GuiCom:Enable($edLfs.Spediteur);
    end;

    if (Lfs.zuBA.Nummer<>0) then begin
      $Lb.BAGNummer->wpcaption    # AInt(Lfs.zuBA.Nummer);
      $Lb.BAGPosition->wpcaption  # AInt(Lfs.zuBA.Position);

      if (Mode=c_ModeNew) or (mode=c_ModeEdit) then begin

        // Bei Umlagerungen keine Preise zulassen
        v702 # RecBufCreate(702);
        v702->Bag.P.Nummer   # Lfs.zuBA.Nummer;
        v702->Bag.P.Position # Lfs.zuBA.Position;
        Recread(v702,1,0);
        Lib_GuiCom:Able($edLfs.Kosten.Pro,  (v702->BAG.P.Aktion<>c_BAG_Umlager));
        Lib_GuiCom:Able($edLfs.Kosten.PEH,  (v702->BAG.P.Aktion<>c_BAG_Umlager));
        Lib_GuiCom:Able($edLfs.Kosten.MEH,  (v702->BAG.P.Aktion<>c_BAG_Umlager));
        Lib_GuiCom:Able($bt.MEH,  (v702->BAG.P.Aktion<>c_BAG_Umlager));
        RecBufDestroy(v702);
      end;

    end
    else begin
      $Lb.BAGNummer->wpcaption  # '';
      $Lb.BAGPosition->wpcaption  # '';
    end;
    if (LFs.Nummer<100000000) then
      $Lb.Nummer->wpcaption # AInt(Lfs.Nummer)
    else
      $Lb.Nummer->wpcaption # '';
    $Lb.Datum->wpcaption # CnvAD(Lfs.Anlage.Datum);
    $Lb.Datum.Verbucht->wpcaption # CnvAD(Lfs.Datum.Verbucht);
//    $Lb.Kundennr->wpcaption # AInt(Lfs.Kundennummer);
//    $Lb.Zieladresse->wpcaption # AInt(Lfs.Zieladresse);
//    $Lb.Zielanschrift->wpcaption # AInt(Lfs.Zielanschrift);
//    $Lb.Kunde->wpcaption # Lfs.Kundenstichwort;
//    Erx # RecLink(100,440,1,0);
//    if (Erx<=_rLocked) then
//      $Lb.Kunde->wpcaption # Adr.Stichwort
//    else
//      $Lb.Kunde->wpcaption # '';
/*
    Erx # RecLink(101,440,3,0);
    if (Erx<=_rLocked) then begin
      $Lb.Ziel->wpcaption # Adr.A.Stichwort;
      $Lb.Ziel2->wpcaption # Adr.A.Ort;
    end
    else begin
      $Lb.Ziel->wpcaption # '';
      $Lb.Ziel2->wpcaption # '';
    end;
*/
  end;

  if (aName='') or (aName='edLfs.Kundennummer') then begin
    Erx # RecLink(100,440,1,0);   // Kunde holen
    if (Erx>_rLocked) or (Lfs.Kundennummer=0) then
      RecBufClear(100);
    Lfs.Kundenstichwort # Adr.Stichwort
    $Lb.Kunde->wpcaption # Lfs.Kundenstichwort;
  end;

  if (aName='') or (aName='edLfs.Zieladresse') or (aName='edLfs.Zielanschrift') then begin
    Erx # RecLink(101,440,3,_RecFirst);   // Anschrift holen
    if (Erx<=_rLocked) and (Lfs.Zieladresse<>0) then begin
      $Lb.Zieladresse->wpcaption # Adr.A.Stichwort+', '+Adr.A.LKZ+', '+Adr.A.Ort;
      $Lb.Zielanschrift->wpcaption # Adr.A.Name+', '+"Adr.A.Straße";
    end
    else begin
      $Lb.Zieladresse->wpcaption # '';
      $Lb.Zielanschrift->wpcaption # '';
    end;
  end;

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
  vHdl      : int;
  vMode     : alpha;
  vParent   : int;
  vAufMode  : logic;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // ********************  Rechtecheck *********************************
  begin
    if (Rechte[Rgt_LFS_InterneKosten] = false) then begin
      Lib_GuiCom:Disable($edLfs.Kosten.Pro);
      Lib_GuiCom:Disable($edLfs.Kosten.PEH);
      Lib_GuiCom:Disable($edLfs.Kosten.MEH);
      Lib_GuiCom:Disable($bt.MEH);
    end;
  end; // Rechtecheck



  if (Mode=c_ModeNew) then begin
    RecBufClear(440);
    Lfs.Nummer        # myTmpNummer;
    Lfs.Anlage.Datum  # today;
    Lfs.Lieferdatum   # today;
    Lfs.Kosten.PEH    # 1000;
    Lfs.Kosten.MEH    # 'kg';


    $Lb.Nummer->wpcaption # '';

    // Aus Auftragsdatei??? -> Schnellieferschein...
    if (w_Parent<>0) then begin
      if (w_Parent->wpname=GetDialogname('Auf.P.Verwaltung')) or (w_Parent->wpname=GetDialogname('Auf.Verwaltung')) then begin
        Lfs.Kundennummer  # Auf.P.Kundennr;
        Lfs.Kundenstichwort # Auf.P.KundenSW;
        Lfs.Zieladresse   # Auf.Lieferadresse;
        Lfs.Zielanschrift # Auf.Lieferanschrift;
        vAufMode # y;
        $edLfs.Spediteurnr->wpcustom # 'inPos';
      end;
    end;

    // Focus setzen auf Feld:
    if ($cbLfs.RuecknahmeYN->wpdisabled) then
      $edLfs.Kundennummer->WinFocusSet(true)
    else
      $cbLfs.RuecknahmeYN->WinFocusSet(true);

  end
  else begin

    // Focus setzen auf Feld:
    if (Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*') then begin
      Lib_GuiCom:Disable($edLfs.Spediteurnr);
//      Lib_GuiCom:Disable($edLfs.Fahrer);      27.01.2021 AH wegen GEW 2231/9
//      Lib_GuiCom:Disable($edLfs.Kennzeichen); "
      Lib_GuiCom:Disable($edLfs.Lieferdatum);
      $edLfs.Kosten.Pro->WinFocusSet(true);
    end
    else begin
      $edLfs.Spediteurnr->WinFocusSet(true);
    end;
  end;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
  vNr : int;
  vPos : word;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (Lfs.zuBA.Nummer=0) then begin
    if (Lfs.Kundennummer=0) then begin
      Msg(001200,Translate('Kunde'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edLfs.Kundennummer->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(100,440,1,_RecFirst);   // Kunde holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Kunde'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edLfs.Kundennummer->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Lfs.Zieladresse=0) then begin
    Msg(001200,Translate('Zieladresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edLfs.Zieladresse->WinFocusSet(true);
    RETURN false;
  end;
  if (Lfs.Zielanschrift=0) then begin
    Msg(001200,Translate('Zielanschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edLfs.Zielanschrift->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(101,440,3,_RecFirst);   // Anschrift holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Anschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edLfs.Zieladresse->WinFocusSet(true);
    RETURN false;
  end;

  if (Lfs.Kosten.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edLfs.Kosten.PEH->WinFocusSet(true);
    RETURN false;
  end;
  if (Lfs.Kosten.MEH='') then begin
    Msg(001200,Translate('Mengeneinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edLfs.Kosten.MEH->WinFocusSet(true);
    RETURN false;
  end;
  If (Lfs.Kosten.MEH<>'Stk') and (Lfs.Kosten.MEH<>'kg') and
    (Lfs.Kosten.MEH<>'t') and (Lfs.Kosten.MEH<>'mm') and (Lfs.Kosten.MEH<>'lfm') and (Lfs.Kosten.MEH<>'m') and
    (Lfs.Kosten.MEH<>Translate('pauschal')) then begin
    Msg(001201,Translate('Mengeneinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edLfs.Kosten.MEH->WinFocusSet(true);
    RETURN false;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
//    "xxx.Änderung.Datum"  # SysDate();
  //  "xxx.Änderung.Zeit"   # Now;
    //"xxx.Änderung.User"   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);


    if (Lfs.zuBA.Nummer<>0) then begin
      Erx # RecLink(702,440,7,_recFirst); // BA-Pos holen
      if (Erx=_rOK) then begin
        RecRead(702,1,_recLock);

        // Kosten vom LFS übernehmen...
        if (Lfs.Kosten.PEH=1) and (Lfs.Kosten.MEH=Translate('pauschal')) then begin
          BAG.P.Kosten.Pro  # 0.0;
          BAG.P.Kosten.PEH  # 1;
          BAG.P.Kosten.MEH  # 'kg';
          if (BAG.P.Kosten.Wae=0) then BAG.P.Kosten.Wae  # 1;
          Wae_Umrechnen(Lfs.Kosten.Pro, 1, var BAg.P.Kosten.Fix, BAG.P.Kosten.Wae);
        end
        else begin
          BAG.P.Kosten.Pro  # Lfs.Kosten.Pro;
          BAG.P.Kosten.PEH  # Lfs.Kosten.PEH;
          BAG.P.Kosten.MEH  # Lfs.Kosten.MEH;
          BAG.P.Kosten.Fix  # 0.0;
        end;


        Erx # RecLink(100,440,6,_RecFirst);   // Spediteur holen
        if (Erx>_rLocked) then RecBufClear(100);
        BAG.P.ExterneLiefNr # Adr.Lieferantennr;
        BAG.P.ExternYN      # (Lfs.Spediteurnr<>0);
        BAG.P.Bemerkung     # Lfs.Bemerkung;
        BA1_P_Data:Replace(_recUnlock,'AUTO');
      end;
    end;

  end
  else begin  // Neuanlage

    if (Lfs_Data:SaveLFS()=false) then begin
      ErrorOutput;
      RETURN false;
    end;

    // wenn aus Auftragsdatei, dann sofort ENDE
    if (w_Parent<>0) then begin
      if (w_Parent->wpname=GetDialogname('Auf.P.Verwaltung')) or (w_Parent->wpname=GetDialogname('Auf.Verwaltung')) then begin
        Mode # c_modeCancel;
        RETURN true;
      end;
    end
    else begin
      w_Command # '->POS';
    end;
  end;


  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  // ALLE Positionen verwerfen
  if (Mode=c_ModeNew) then begin

    if (Lfs.Nummer<mytmpNummer) and (Lfs.Nummer<>0) then begin
      TODO('PANIK !!! Sie versuchen einen echten Lieferschein '+aint(lfs.nummer)+' abzubrechen!!');
      RETURN false;
    end;

//todo('clean von '+AInt(lfs.nummer));
    WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do begin
      RekDelete(441,0,'MAN');
    END;

  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin

  // ist schon gelöscht?
  if ("Lfs.Löschmarker"='*') then RETURN;

  // keine Positionen mehr da?
  if (RecLinkInfo(441,440,4,_RecCount)>0) then begin
    Msg(440001,'',0,0,0);
    RETURN;
  end;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;
  RecRead(440,1,_recLock);
  "Lfs.Löschmarker" # '*';
  RekReplace(440,_recUnlock,'MAN');
//  RekDelete(gFile,0,'MAN');
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
  if (aEvt:obj->wpname='edLfs.Spediteurnr') and
    ($edLfs.Spediteurnr->wpcustom='inPos') then begin
    $edLfs.Spediteurnr->wpcustom # '';
    gMdi->wpvisible # true;
    gMdi->wpdisabled #false;
    gMdi->winupdate(_Winupdon);
    Lfs_Main:Auswahl('Spediteurxxx');
//    Lfs_Main:Auswahl('Positionen');
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

  if (aEvt:Obj->wpname='edLfs.Spediteurnr') and ($edLfs.Spediteurnr->wpchanged) then begin
    Erx # RecLink(100,440,6,_RecFirst);
    if (Erx=_rOK) then
      Lfs.Spediteur # Adr.Stichwort
    else
      Lfs.Spediteur # ''
    $edLfs.Spediteur->Winupdate(_WinUpdFld2Obj);
  end;


  if (aEvt:Obj->wpname='edLfs.Kosten.MEH') and ($edLfs.Kosten.MEH->wpchanged) then begin
    if (Lfs.Kosten.MEH=Translate('pauschal')) then begin
      Lfs.Kosten.PEH # 1;
      $edLfs.Kosten.PEH->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edLfs.Kosten.PEH);
      if (aFocusObject=$edLfs.Kosten.PEH) then $edLfs.Kosten.Pro->Winfocusset(false);
    end
    else begin
      Lib_GuiCom:Enable($edLfs.Kosten.PEH);
    end;
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  if (aEvt:Obj->wpname='cbLfs.RuecknahmeYN') then begin
    if ("Lfs.RücknahmeYN") then begin
      Lfs.Zieladresse     # Set.eigeneAdressnr;
      Lfs.Zielanschrift   # 1;
      Refreshifm('edLfs.Zieladresse');
      Refreshifm('edLfs.Zielanschrift');
    end;
    RETURN true;
  end;



  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (Mode=c_ModeNew) or (mode=c_ModeEdit) then begin
    $edLfs.Spediteurnr->winupdate(_WinUpdObj2Fld);
    if (Lfs.SpediteurNr<>0) then
      Lib_GuiCom:Disable($edLfs.Spediteur)
    else
      Lib_GuiCom:Enable($edLfs.Spediteur);
  end;
  RETURN(true);
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx   : int;
  vA    : alpha;
  vQ    : alpha;
  vHdl  : int;
end;
begin

  case aBereich of

    'MEH' : begin
      Lib_Einheiten:Popup('MEH-TRANSPORT',$edLfs.Kosten.MEH, 440,1,18);
      if (Lfs.Kosten.MEH='PAU') then begin
        Lfs.Kosten.PEH # 1;
        $edLfs.Kosten.PEH->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edLfs.Kosten.PEH);
      end
      else begin
        Lib_GuiCom:Enable($edLfs.Kosten.PEH);
      end;
    end;


    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.KundenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferadresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferadresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferanschrift' : begin
      RecLink(100,440,2,0);     // Lieferadresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLieferanschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Spediteur' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','Lfs_Main:AusSpediteur');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Positionen' : begin
      RecBufClear(441);
      if (LFS.zuBA.Nummer<>0) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.P.LFA.Verwaltung',here+':AusPositionen',y)
      else if ("Lfs.RücknahmeYN") then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.RP.Verwaltung',here+':AusPositionen',y)
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.P.Verwaltung',here+':AusPositionen',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lfs.Kundennummer    # Adr.Kundennr;
    Lfs.KundenStichwort # Adr.Stichwort;
    if ("Lfs.RücknahmeYN"=false) then begin
      Lfs.Zieladresse     # Adr.Nummer;
      Lfs.Zielanschrift   # 1;
    end;
  end;
  // Focus auf Editfeld setzen:
  $edLfs.Kundennummer->Winfocusset(false);
  RefreshIfm('edLfs.Zieladresse');
end;


//========================================================================
//  AusLieferadresse
//
//========================================================================
sub AusLieferadresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lfs.Zieladresse   # Adr.Nummer;
    Lfs.Zielanschrift # 1;
  end;
  // Focus setzen:
  $edLfs.Zieladresse->Winfocusset(false);
  RefreshIfm('edLfs.Zieladresse');
end;


//========================================================================
//  AusLieferanschrift
//
//========================================================================
sub AusLieferanschrift()
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lfs.Zielanschrift # Adr.A.Nummer;
  end;
  // Focus setzen:
  $edLfs.Zielanschrift->Winfocusset(false);
  RefreshIfm('edLfs.Zielanschrift');
end;


//========================================================================
//  AusSpediteur
//
//========================================================================
sub AusSpediteur()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Lfs.Spediteur # Adr.Stichwort;
    Lfs.SpediteurNr # Adr.Nummer;
    $edLfs.Spediteur->Winupdate(_WinUpdFld2Obj);
    gSelected # 0;
    if (Lfs.SpediteurNr<>0) then
      Lib_GuiCom:Disable($edLfs.Spediteur)
    else
      Lib_GuiCom:Enable($edLfs.Spediteur);
  end;
  // Focus auf Editfeld setzen:
  $edLfs.Spediteurnr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusPositionen
//
//========================================================================
sub AusPositionen()
local begin
  Erx   : int;
  vGew  : float;
  vNGew : float;
end;
begin

  gSelected # 0;
  // Aus Auftragsdatei??? -> Schnellieferschein...
  if (w_Parent<>0) then begin
    if (w_Parent->wpname=GetDialogname('Auf.P.Verwaltung')) or (w_Parent->wpname=GetDialogname('Auf.Verwaltung')) then begin
      RecBufClear(440);
      Lfs.Nummer        # myTmpNummer;
      Lfs.Anlage.Datum  # today;
      Lfs.Kundennummer  # Auf.P.Kundennr;
      Lfs.Kundenstichwort # Auf.P.KundenSW;
      Lfs.Zieladresse   # Auf.Lieferadresse;
      Lfs.Zielanschrift # Auf.Lieferanschrift;
    end;
  end;

  Erx # RecLink(441, 440, 4, _recFirst);
  WHILE(Erx <= _rLocked) DO BEGIN
    vGew # vGew + Lfs.P.Gewicht.Brutto;
    vNGew # vNGew + Lfs.P.Gewicht.Netto;
    Erx # RecLink(441, 440, 4, _recNext);
  END;
  if (Mode=c_ModeView) or (Mode=c_ModeList) then begin
    RecRead(440,1,_recLock);
    Lfs.Positionsgewicht  # vGew;
    Lfs.PosNettogewicht   # vNGew;
    RekReplace(440,_recUnlock,'AUTO');
  end
  else begin
    Lfs.Positionsgewicht # vGew;
    Lfs.PosNettogewicht   # vNGew;
    $lb.Positionsgewicht->wpcaption    # ANum(Lfs.Positionsgewicht, Set.Stellen.Gewicht);
  end;

  //  $editErsatz->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
end
begin

  // ggf. sofort in Position springen...
  if (w_Command='->POS') then begin
    w_Command # '';
    Auswahl('Positionen');
    RETURN;
  end;


  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (mode<>c_modeView)) OR
// 2023-01-03 AH    (vHdl->wpDisabled) or
    (Rechte[Rgt_Lfs_Aendern]=n) or
      //(Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*') or
      ((Lfs.zuBA.Nummer<>0) and ((Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*'))) or
      ((lfs.zuBA.Nummer<>0) and (Rechte[rgt_BAG_Aendern]=n));
  
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (mode<>c_modeview)) OR
// 2023-01-03 AH    (vHdl->wpDisabled) or
    (Rechte[Rgt_Lfs_Aendern]=n) or
      //(Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*') or
      ((Lfs.zuBA.Nummer<>0) and ((Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*'))) or
      ((lfs.zuBA.Nummer<>0) and (Rechte[rgt_BAG_Aendern]=n));


  d_MenuItem # gMenu->WinSearch('Mnu.Change.Ziel');
  if (d_MenuItem != 0) then
    d_MenuItem->wpDisabled # ((Mode = c_ModeEdit) or (Mode = c_ModeNew) or (Rechte[Rgt_Lfs_Change_Ziel] = false));

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) or (w_Auswahlmode)) or
                 (Rechte[Rgt_Lfs_Loeschen]=n) or (lfs.zuBA.Nummer<>0) or ("LFs.Löschmarker"='*');
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) or (w_Auswahlmode)) or
                 (Rechte[Rgt_Lfs_Loeschen]=n) or (lfs.zuBA.Nummer<>0) or ("LFs.Löschmarker"='*');


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Lfs_Daten_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Lfs_Daten_Import]=false;


  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode=c_ModeNew) or (mode=c_ModeEdit);

  vHdl # gMenu->WinSearch('Mnu.Druck.VLDAW');
  // ST 2018-01-17: Verladeanweisung auch bei Lohnfahraufträgen druckbar
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_modeView) and (mode<>c_ModeList)) /*or (lfs.zuBA.Nummer<>0)*/ or (Rechte[Rgt_Lfs_Druck_VLDAW]=n );

  vHdl # gMenu->WinSearch('Mnu.Druck.LFA');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_modeView) and (mode<>c_ModeList)) or (lfs.zuBA.Nummer=0) or (Rechte[Rgt_Lfs_Druck_LFA]=n );

  vHdl # gMenu->WinSearch('Mnu.Druck.Avis');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_Avis]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.LFS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_LFS]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.LfE');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_LfE]=n) or (StrFind(Set.Module,'L',0)=0);


  vHdl # gMenu->WinSearch('Mnu.Druck.Freistellung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_Freistell]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.Liefernachweis');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_LNW]=n)

  vHdl # gMenu->WinSearch('Mnu.Druck.VSB');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_VSB]=n)

  vHdl # gMenu->WinSearch('Mnu.Druck.WZ');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_WZ]=n)

  vHdl # gMenu->WinSearch('Mnu.Verbuchen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      (Lfs.Datum.Verbucht<>0.0.0) or (lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Verbuchen]=n);

  vHdl # gMenu->WinSearch('Mnu.Stornieren');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      (Lfs.Datum.Verbucht=0.0.0) or
                      (Rechte[Rgt_Lfs_Stornieren]=n);

  vHdl # gMenu->WinSearch('Mnu.LFA.Theoretisch');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Lfs.Datum.Verbucht<>0.0.0) or
      (lfs.zuBA.Nummer=0) or
      ((Lfs.zuBA.Nummer<>0) and (Rechte[Rgt_BA_Abschluss]=n)) or
      ((mode<>c_ModeList) and (mode<>c_modeView));

  vHdl # gMenu->WinSearch('Mnu.LFA.Abschluss');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Lfs.Datum.Verbucht<>0.0.0) or
      (lfs.zuBA.Nummer=0) or
      ((Lfs.zuBA.Nummer<>0) and (Rechte[Rgt_BA_Abschluss]=n)) or
      ((mode<>c_ModeList) and (mode<>c_modeView));

  vHdl # gMenu->WinSearch('Mnu.KLimit.Freigabe');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*') or
      (Rechte[Rgt_Lfs_Freigabe]=n) or
      (("Set.KLP.LFS-Druck" <> 'L') and ("Set.KLP.LFA-Druck" <> 'L')) or
      ((mode<>c_ModeList) and (mode<>c_modeView));

  if (Mode<>c_ModeOther) and (aNoRefresh=n) then RefreshIfm();

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
  Erx     : int;
  vHdl    : int;
  vDat    : date;
  vQ      : alpha(4000);
  vTmp    : int;
  vTim    : time;
  vI      : int;
  vOK     : logic;
end;
begin

  if (aMenuItem->wpName='Mnu.KLimit.Freigabe') and (Rechte[Rgt_Lfs_Freigabe]) and
    (("Set.KLP.LFS-Druck" = 'L') or ("Set.KLP.LFA-Druck" = 'L')) then begin
    Lfs_Subs:KLimit.Freigabe();
    RETURN true;
  end;

  if (aMenuItem->wpName='Mnu.Mark.Sel') then begin
    Lfs_Mark_Sel();
    RETURN true;
  end;

  if (aMenuItem->wpName='Mnu.Change.Ziel') then begin
    Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
    Lfs_subs:ChangeZiel();
    RETURN true;
  end;


  if (aMenuItem->wpName='Mnu.Filter.Geloescht') then begin
    Filter_VSD # !(Filter_VSD);
    $Mnu.Filter.Geloescht->wpMenuCheck # Filter_VSD;

    if (gZLList->wpdbselection<>0) then begin
      vHdl # gZLList->wpdbselection;
      gZLList->wpDbSelection # 0;
      SelClose(vHdl);
      SelDelete(gFile,w_selName);
      w_SelName # '';
      if (gZLList->wpDbRecId=0) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect)
      else
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
      RETURN true;
    end;
    vQ # '';
    Lib_Sel:QDate( var vQ, 'LFS.Datum.Verbucht', '=', 0.0.0);
    Lib_Sel:QAlpha( var vQ, '"Lfs.Löschmarker"', '=', '');
    Lib_Sel:QRecList(0,vQ);

    if (gZLList->wpDbRecId=0) then
      gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect)
    else
      gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
    App_Main:Refreshmode();
    RETURN true;
  end;


  if (Mode=c_ModeList) then begin
    Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
    if (Erx<>_rOK) then RETURN false;
  end;
  case (aMenuItem->wpName) of

    'Mnu.Kosten' : begin
      Lfs_Data:Recalc();
    end;

    
    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Lfs.Anlage.Datum, Lfs.Anlage.Zeit, Lfs.Anlage.User);
    end;


    'Mnu.LFA.Theoretisch' : begin
      if (Msg(702443,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;

      if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var vDat, today)=false) then RETURN false;
      // 04.11.2021 AH  HWE
      vI # 0;
      if (Lfs.zuBA.Nummer<>0) then begin
        vI # Lfs_LFA_Data:IstNurAusVersandNr();
        if (vI>0) then begin
          Erx # Msg(440010,aint(vI)+'|'+aint(Lfs.zuBA.Nummer),_WinIcoQuestion, _WinDialogYesNoCancel,0);
          if (Erx=_WinIdCancel) then RETURN false;
          if (Erx=_winidyes) then begin
            Erx # Msg(440011,'',_WinIcoQuestion, _WinDialogYesNoCancel,0);
            if (Erx=_WinIdCancel) then RETURN false;
            vOK # Vsd_Data:FmAlleLfs(vI, vDat, '', Erx=_Winidyes);    // Versand FM
          end
          else begin
            vI # 0;
          end;
        end;
      end;
      if (vI<=0) then begin
        vOK # Lfs_LFA_Data:GesamtFM(vDat);                  // einen LFS FM
      end;

      if (vOK=false) then begin
        ErrorOutput;
      end
      else begin
        Msg(999998,'',0,0,0);
      end;
      RecRead(440,1,0);
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.LFA.Abschluss' : begin
      if (Lfs.zuBA.Nummer=0) then RETURN true;
      vDat # today;
      //if (gUsernamE='AH') then  31.03.2021 AH: SSW 2200/12 bzw. BFS 2190/11
      vDat # Max(Lfs.Lieferdatum, today);
      if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var vDat, vDat)=false) then RETURN false;
      APPOFF();   // 05.02.2021
      Erx # RecLink(702,440,7,_recFirst);   // BA-Position prüfen
      if (Erx>_rLocked) then begin
        APPON();
        Msg(702440,'',0,0,0);
        RETURN true;
      end;
      Lfs_LFA_Data:Abschluss(vDat);
      APPON();
      ErrorOutput;
/*** 24.10.2019
      else begin
        // LFS-Kopf verbuchen...
        RecRead(440,1,_recLock);
        Lfs.Datum.Verbucht # vDat;
        Erx # RekReplace(440,_recUnlock,'AUTO');
        if (erx<>_rOK) then begin
          Msg(702440,'',0,0,0);
        end;
      end;
***/
      RecRead(440,1,0);
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.LfE' : begin
      Lfs_Subs:Druck_LFE();
    end;


    'Mnu.Druck.LFS' : begin
      if (Rechte[Rgt_Lfs_Druck_LFS]) then begin

        if (Lfs_Data:Druck_LFS()) and (Set.LFS.Verbuchen='A') and
          ((Mode=c_ModeList) or (Mode=c_ModeView)) and
          (Lfs.Datum.Verbucht=0.0.0) and
          (lfs.zuBA.Nummer=0) and
          (Rechte[Rgt_Lfs_Verbuchen]) then begin
          if (Msg(440007,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winIdyes) then begin
            if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var vDat, today)=false) then RETURN false;
            if (vDat=today) then vTim # now;
            Lfs_Data:Verbuchen(Lfs.Nummer, vDat, vTim);
            ErrorOutput;
          end;
        end;
      end;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.Avis' : begin
      if (Rechte[Rgt_Lfs_Druck_Avis]) then
        Lfs_Data:Druck_Avis();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.VLDAW' : begin
      if (Rechte[Rgt_Lfs_Druck_VLDAW]) then
        Lfs_VLDAW_Data:Druck_VLDAW();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.LFA' : begin
      if (Rechte[Rgt_Lfs_Druck_LFA]) then
        Lfs_VLDAW_Data:Druck_LFA();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.Freistellung' : begin
      if (Rechte[Rgt_Lfs_Druck_Freistell]) then
        Lfs_Data:Druck_Freistellung();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.CMR' : begin
      if (Rechte[Rgt_Lfs_Druck_LFS]) then
        Lfs_Data:Druck_CMR();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.Liefernachweis' : begin
      if (Rechte[Rgt_Lfs_Druck_LNW]) then
        Lfs_Data:Druck_Nachweiss();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.VSB' : begin
      if (Rechte[Rgt_Lfs_Druck_VSB]) then
        Lfs_Data:Druck_VSB();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.WZ' : begin
      if (Rechte[Rgt_Lfs_Druck_WZ]) then begin
        Lfs_Data:Druck_Werkszeugnis();
      end;
    end;


    'Mnu.Verbuchen' : begin
      if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var vDat, today)=false) then RETURN false;
      if (vDat=today) then vTim # now;
      Lfs_Data:Verbuchen(Lfs.Nummer, vDat, vTim);
      ErrorOutput;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Stornieren' : begin
//      if (lfs.zuBA.Nummer=0) then begin
      Lfs_Data:Stornieren(Lfs.Nummer, Today);
      ErrorOutput;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Positionen' : begin
      Auswahl('Positionen');
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

  if (aEvt:Obj->wpname='bt.Text') then
    Mdi_TXTEditor_Main:Start('~440.'+CnvAI(LFs.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.001', Rechte[Rgt_Lfs_Aendern], Translate('Zusatztext'));

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Spediteur'      :   Auswahl('Spediteur');
    'bt.Kunde'          :   Auswahl('Kunde');
    'bt.Zieladresse'    :   Auswahl('Lieferadresse');
    'bt.Zielanschrift'  :   Auswahl('Lieferanschrift');
    'bt.MEH'            :   Auswahl('MEH');
  end;

end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin
  RETURN true;
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
begin

  // ST 2016-06-08: Rücklieferscheinkennung in eigenem Feld, damit man über Lfs.Nummer wieder schnell sortieren kann
/*
  Gv.Alpha.01 # aint(Lfs.Nummer);
  if ("Lfs.RücknahmeYN") then Gv.Alpha.01 # 'R'+Gv.Alpha.01;
*/
  Gv.Alpha.01 # '';
  if ("Lfs.RücknahmeYN") then Gv.Alpha.01 # 'R';


  if (aMark) then begin
    if (RunAFX('Lfs.EvtLstDataInit','y' + aEvt:obj->wpName)<0) then RETURN;
  end
  else if (RunAFX('Lfs.EvtLstDataInit','n' + aEvt:obj->wpName)<0) then RETURN;


  if (Lfs.Datum.Verbucht<>0.0.0) or ("Lfs.Löschmarker"='*') then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
  else if ("Lfs.RücknahmeYN") then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Auf.Col.Frei1);

  if (RecLink(101,440,3,_RecFirst)>_rLocked) then   // Zieanschrift holen
    RecBufClear(101);
  if (RecLink(441,440,4,_recFirst)>_rLocked) then   // 1. Position holen
    RecBufClear(441);
//lfs.kundenstichwort # "Lfs.löschmarker" + lfs.kundenstichwort;
//  Refreshmode(y);
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

  if ($NB.Main->wpcustom=c_ModeBald+c_ModeNew) then begin
    $NB.Main->wpcustom # '';
    App_Main:Action(c_ModeNew);
    RETURN false;
  end;

  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);

end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edLfs.Spediteurnr') AND (aBuf->Lfs.Spediteurnr<>0)) then begin
    RekLink(100,440,6,0);   // Spediteur holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edLfs.Kundennummer') AND (aBuf->Lfs.Kundennummer<>0)) then begin
    RekLink(100,440,1,0);   // Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edLfs.Zieladresse') AND (aBuf->Lfs.Zieladresse<>0)) then begin
    RekLink(100,440,2,0);   // Zieladresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edLfs.Zielanschrift') AND (aBuf->Lfs.Zielanschrift<>0)) then begin
    RekLink(101,440,3,0);   // Zielanschrift holen
    Adr.A.Adressnr # Lfs.Zieladresse;
    Adr.Nummer # Lfs.Zielanschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Lfs.Zieladresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;

end;

//========================================================================