@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_P_LFA_Main
//                        OHNE E_R_G
//  Info
//
//
//  20.08.2006  AI  Erstellung der Prozedur
//  22.04.2013  AI  MatMEH
//  07.02.2020  AH  Kann aus intern über Ressource gemacht werden
//  10.05.2022  AH  ERX
//  20.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKopftext();
//    SUB AusFusstext();
//    SUB AusLieferant()
//    SUB AusZieladresse()
//    SUB AusZielanschrift()
//    SUB AusPositionen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB SaveText()
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtTimer(aEvt : event, aTimerId : int): logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDialog :   $BA1.P.LFA.Maske
  cTitle :    'Fahrauftrag'
  cFile :     702
  cMenuName : 'Lfs.Bearbeiten'
  cPrefix :   'BA1_P_LFA'
  cZList :    0
  cKey :      1
end;

declare Auswahl(aBereich : alpha)
declare SaveText()

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  Erx     : int;
  vHdl    : int;
end
begin

  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edBAG.P.Zieladresse);
  Lib_Guicom2:Underline($edBAG.P.Zielanschrift);
  Lib_Guicom2:Underline($edBAG.P.ExterneLiefNr);
  Lib_Guicom2:Underline($edBAG.P.ExterneLiefAns);
  Lib_Guicom2:Underline($edBAG.P.Ressource.Grp);
  Lib_Guicom2:Underline($edBAG.P.Ressource);

  SetStdAusFeld('edBAG.P.ExterneLiefNr'   ,'Lieferant');
  SetStdAusFeld('edBAG.P.ExterneLiefAns'  ,'LieferantAns');
  SetStdAusFeld('edBAG.P.Kosten.MEH'     ,'MEH');
  SetStdAusFeld('edBAG.P.Ressource'      ,'Ressource');
  SetStdAusFeld('edBAG.P.Ressource.Grp'  ,'ResGruppe');
  SetStdAusFeld('edBAG.P.Zieladresse'    ,'Zieladresse');
  SetStdAusFeld('edBAG.P.Zielanschrift'  ,'Zielanschrift');

  App_Main:EvtInit(aEvt);
  $edBAG.P.ExterneLiefNr->WinFocusSet(true);

  ArG.Aktion2           # c_BAG_Fahr;
  Erx # RecRead(828,1,0);
  if (Erx>_rLocked) then RecBufClear(828);

  RecBufClear(702);         // BA-Position anlegen
  BAG.P.Nummer            # myTmpNummer;
  BAG.P.Position          # 1;
  BAG.P.Aktion            # ArG.Aktion;
  BAG.P.Aktion2           # ArG.Aktion2;
  "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
  "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
  "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
  "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
  BAG.P.Bezeichnung       # ArG.Bezeichnung
  BAG.P.ExternYN          # y;
  BAG.P.ExterneLiefNr     # 0;
//  BAG.P.Auftragsnr        # Auf.P.Nummer;
//  BAG.P.AuftragsPos       # Auf.P.Position;
//  BAG.P.Kommission        # AInt(BAG.P.Auftragsnr)+'/'+AInt(BAG.P.AuftragsPos);
  BAG.P.Zieladresse       # Auf.Lieferadresse;
  BAG.P.Zielanschrift     # Auf.Lieferanschrift;
  Erx # RecLink(101,702,13,_RecFirst);  // Zielanschrift holen
  if (Erx>_rLocked) then RecBufClear(101);
  BAG.P.Zielstichwort     # Adr.A.Stichwort;
  BAG.P.ZielVerkaufYN     # y;

  BAG.P.Kosten.Wae        # 1;
  BAG.P.Kosten.PEH        # 1000;
  BAG.P.Kosten.MEH        # 'kg';

  BAG.P.Anlage.Datum  # Today;
  BAG.P.Anlage.Zeit   # Now;
  BAG.P.Anlage.User   # gUserName;

  Mode # c_ModeNew;

  Lib_GuiCom:Disable($edBAG.P.Ressource.Grp);
  Lib_GuiCom:Disable($edBAG.P.Ressource);
  Lib_GuiCom:Disable($bt.ResGruppe);
  Lib_GuiCom:Disable($bt.Ressource);

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx     : int;
  vA      : alpha;
  vX      : int;
  vTxtHdl : int;
  vTmp    : int;
end;
begin

  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $te.BA.Pos.Kopf->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $te.BA.Pos.Fuss->wpdbTextBuf # vTxtHdl;
  end;

  if (aName='') then begin
    $Lb.Nummer->wpcaption     # '';
    $lb.Position->wpcaption   # '';
    $lb.Kommission->wpcaption # BAG.P.Kommission;

    if (BAG.P.Auftragsnr<>0) then begin
      Auf.Nummer    # BAG.P.Auftragsnr;
      Erx # RecRead(400,1,0);
      if (Erx<=_rLockeD) then begin
        $lb.Kunde->wpcaption # Auf.KundenStichwort;
        end
      else begin
        $lb.Kunde->wpcaption # '';
      end
      end
    else begin
        $lb.Kunde->wpcaption # '';
    end;
  end;


  if (aName='') or (aName='edBAG.P.Zieladresse') or (aName='edBAG.P.Zielanschrift') then begin
    Erx # RecLink(101,702,13,_recfirst);    // Anschrift holen
    if (Erx<=_rLocked) then begin
      $lb.Zieladresse->wpcaption # Adr.A.Stichwort+', '+Adr.A.Ort;
      end
    else begin
      $lb.Zieladresse->wpcaption # '';
    end;
  end;


  if (aName='') or (aName='edBAG.P.Ressource') or (aName='edBAG.P.Ressource.Grp') then begin
    Erx # RecLink(822,702,10,_RecFirst);
    if (Erx<=_rLocked) then begin
      $lb.ResGruppe->wpcaption # Rso.Grp.Bezeichnung;
      Erx # RecLink(160,702,11,_RecFirst);
      if (Erx<=_rLocked) then begin
        $lb.Ressource->wpcaption # Rso.Stichwort;
      end
      else begin
        $lb.Ressource->wpcaption # ''
      end;

      $lb.Ressource->wpcaption # Rso.Stichwort;
    end
    else begin
      $lb.ResGruppe->wpcaption # ''
      $lb.Ressource->wpcaption # ''
    end;

    if (aChanged) or ($edBAG.P.Ressource->wpchanged) or ($edBAG.P.Ressource.Grp->wpchanged) then begin
      RunAFX('BAG.P.Auswahl.Ressource',aName);
    end;
  end;


  if (aName='') or (aName='edBAG.P.ExterneLiefNr') or (aName='edBAG.P.ExterneLiefAns') then begin
    vA # '';
    if (BAG.P.ExterneLiefNr<>0) then begin
      Erx # RecLink(100,702,7,0);   // Adresse holen
      if (BAG.P.ExterneLiefAns=0) then begin
        if (Erx<=_rLocked) then vA # Adr.Stichwort;
      end
      else begin
        Adr.A.Adressnr # Adr.Nummer;
        Adr.A.Nummer # BAG.P.ExterneLiefAns;
        Erx # RecRead(101,1,0);
        if (Erx<=_rLocked) then begin
          vA # Adr.A.Stichwort;
        end;
      end;
    end;
    
    $Lb.Lieferant->wpcaption # vA;
  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vNr     : int;
  vPos    : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  // logische Prüfung
  // Nummernvergabe

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    end

  else begin  // Neuanlage

    // BAG zum Lieferschein generieren
    TRANSON;
    APPOFF(true);
    if (BA1_P_Data:ErzeugeBAGausLFS()=false) then begin
      APPON();
      TRANSBRK;
      Error(440700,'');
      ErrorOutput;
      RETURN false;
    end;
    APPON();
    TRANSOFF;

    SaveText();

  end;  // Neuanlage

  Mode # c_modeCancel;  // sofort alles beenden!
  gSelected # 1;

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
    RecBufClear(440);
    Lfs.Nummer # BAG.P.Nummer;
    WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do begin
      RekDelete(441,0,'MAN');
    END;
  end;

  gSelected # 0;
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RekDelete(gFile,0,'MAN');
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged
(
  aEvt                  : event;        // Ereignis
): logic
begin
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbBAG.P.ExternYN') then begin
    if (BAG.P.ExternYN) then begin
      BAG.P.Ressource.Grp # 0;
      BAG.P.Ressource     # 0;
      $lb.ResGruppe->wpcaption # '';
      $lb.Ressource->wpcaption # '';
      $edBAG.P.Ressource.Grp->winupdate(_WinUpdFld2Obj);
      $edBAG.P.Ressource->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edBAG.P.Ressource.Grp);
      Lib_GuiCom:Disable($edBAG.P.Ressource);
      Lib_GuiCom:Disable($bt.ResGruppe);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Enable($bt.Lieferant);
      Lib_GuiCom:Enable($edBAG.P.ExterneLiefNr);
      Lib_GuiCom:Enable($edBAG.P.ExterneLiefAns);
    end
    else begin
      BAG.P.ExterneLiefNr   # 0;
      BAG.P.ExterneLiefAns  # 0;
      $lb.Lieferant->wpcaption # '';
      $edBAG.P.ExterneLiefNr->winupdate(_WinUpdFld2Obj);
      if ($edBAG.P.ExterneLiefAns<>0) then $edBAG.P.ExterneLiefAns->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Enable($edBAG.P.Ressource.Grp);
      Lib_GuiCom:Enable($edBAG.P.Ressource);
      Lib_GuiCom:Enable($bt.ResGruppe);
      Lib_GuiCom:Enable($bt.Ressource);
      Lib_GuiCom:Disable($bt.Lieferant);
      Lib_GuiCom:Disable($edBAG.P.ExterneLiefNr);
      Lib_GuiCom:Disable($edBAG.P.ExterneLiefAns);
    end;
  end;

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

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);


  //if ($NB.Main->wpcustom='->POS') then begin
  if (w_Command='->POS') then begin
    w_Command # '';
//    $NB.Main->wpcustom # '';
    gTimer2 # SysTimerCreate(300,1,gMdi);
    RETURN false;
  end;

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

  // logische Prüfung von Verknüpfungen
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
  Erx   : int;
  vA    : alpha;
  vQ    : alpha(4000);
  vTmp  : int;
  vHdl  : int;
end;
begin

  case aBereich of
    'Positionen' : begin
      RecBufClear(441);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.P.Verwaltung',here+':AusPositionen',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # 'LFA';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edBAG.P.Kosten.MEH,702,3,5);
      end;


    'Zieladresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusZieladresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zielanschrift' : begin
      RecLink(100,702,12,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusZielanschrift');

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


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kopftext' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusKopftext');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Fusstext' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstext');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ResGruppe', 'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LieferantAns' : begin
      if (BAG.P.ExterneLiefNr=0) then RETURN;
      Erx # RecLink(100,702,7,0);   // Adresse holen
      if (Erx>_rLocked) then RETURN;
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLieferantAns');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0, 'Adr.A.Adressnr = '+aint(Adr.nummer));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusKopftext
//
//========================================================================
sub AusKopftext();
local begin
  vTxtHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,0,0,0,0);
    $te.BA.Pos.Kopf->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $te.BA.Pos.Kopf->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusFusstext
//
//========================================================================
sub AusFusstext();
local begin
  vTxtHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,0,0,0,0);
    $te.BA.Pos.Fuss->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $te.BA.Pos.Fuss->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.ExterneLiefNr   # Adr.LieferantenNr
    BAG.P.ExterneLiefAns  # 1;
    if ($edBAG.P.ExterneLiefAns<>0) then $edBAG.P.ExterneLiefAns->winupdate(_WinUpdFld2Obj);
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.ExterneLiefNr->Winfocusset(false);
end;


//========================================================================
//  AusLieferantAns
//
//========================================================================
sub AusLieferantAns()
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.ExterneLiefAns  # Adr.A.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.ExterneLiefAns->Winfocusset(false);
end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.Ressource.Grp # Rso.Gruppe;
    BAG.P.Ressource     # Rso.Nummer;
    $edBAG.P.Ressource->WinUpdate();
    $edBAG.P.Ressource.Grp->WinUpdate();
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Ressource->Winfocusset(false);
  if (gSelected<>0) then begin
    gSelected # 0;
    RefreshIfm('edBAG.P.Ressource', y);
  end;
end;



//========================================================================
//  AusZieladresse
//
//========================================================================
sub AusZieladresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.Zieladresse   # Adr.Nummer;
    BAG.P.Zielanschrift # 1;
    BAG.P.Zielstichwort # Adr.Stichwort;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Zieladresse->Winfocusset(false);
end;


//========================================================================
//  AusZielanschrift
//
//========================================================================
sub AusZielanschrift()
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.Zieladresse   # Adr.A.Adressnr;
    BAG.P.Zielanschrift # Adr.A.nummer;
    BAG.P.Zielstichwort # Adr.A.Stichwort;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Zielanschrift->Winfocusset(false);
end;


//========================================================================
//  AusPositionen
//
//========================================================================
sub AusPositionen()
local begin
  Erx   : int;
  vOK   : logic;
end;
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState(cDialog,true);
//  gSelected # 0;

  vOK # y;
  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (Lfs.P.Menge.Einsatz<>Lfs.P.Menge) or
      (Lfs.P.MEH<>Lfs.P.MEH.Einsatz) then vOK # false;
  END;

//  if (vOK=false) then begin
//    Msg(99,'MATMEH xxaayy mix geht so nicht!',0,0,0);
//  end;

  // Focus auf Editfeld setzen:
  SetFocus($edBAG.P.ExterneLiefNr, false);

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

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Graphnotebook richtig setzen
  vHdl # gMdi->WinSearch('NB.Graph');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_modeEdit) or (Mode=c_modeNew);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

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
  vHdl : int;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Positionen' : begin
//      RecBufClear(440);
//      Lfs.Nummer # BAG.P.Nummer;
      Auswahl('Positionen');
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, BAG.P.Anlage.Datum, BAG.P.Anlage.Zeit, BAG.P.Anlage.User );
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
    'bt.Lieferant'    :   Auswahl('Lieferant');
    'bt.LieferantAns' :   Auswahl('LieferantAns');
    'bt.ResGruppe'    :   Auswahl('ResGruppe');
    'bt.Ressource'    :   Auswahl('Ressource')
    'bt.Zieladresse'  :   Auswahl('Zieladresse');
    'bt.Zielanschrift' :  Auswahl('Zielanschrift');
    'bt.ResGruppe'    :   Auswahl('ResGruppe');
    'bt.Ressource'    :   Auswahl('Ressource')
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Kopftext'     :   Auswahl('Kopftext');
    'bt.Fusstext'     :   Auswahl('Fusstext');
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
  RETURN BA1_Combo_Main:EvtPageSelect(aEvt, aPage, aSelecting);
end;


//========================================================================
// SaveText
//
//========================================================================
sub SaveText()
local begin
  vTxtHdl   : int;          // Handle des Textes
  vName     : alpha;
end;
begin

  // KopfTextBuffer holen
  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
  $te.BA.Pos.Kopf->WinUpdate(_WinUpdObj2Buf);
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
  // Kopftext speichern
  if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
    TxtDelete(vName,0)
  else
    TxtWrite(vTxtHdl,vName, _TextUnlock);


  // FussTextBuffer holen
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
  $te.BA.Pos.Fuss->WinUpdate(_WinUpdObj2Buf);
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
  // Kopftext speichern
  if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
    TxtDelete(vName,0)
  else
    TxtWrite(vTxtHdl,vName, _TextUnlock);

END;


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

  if (BAG.P.Aktion=c_BAG_VSB) and (BAG.P.Auftragsnr<>0) then
    BAG.P.Bezeichnung # 'VSB Auf.'+AInt(BAG.P.Auftragsnr)+'/'+AInt(BAG.P.Auftragspos);

  if (BAG.P.Level>1) then
    BAG.P.Bezeichnung # StrChar(32,(BAG.P.Level*3)-3)+BAG.P.Bezeichnung;

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
end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if (y) then begin
      Auswahl('Positionen');
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
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
  vTxtHdl : int;
end;
begin
  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
  end;
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
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
local begin
  vQ        :  alpha(1000);
end
begin

  if ((aName =^ 'edBAG.P.Zieladresse') AND (aBuf->BAG.P.Zieladresse<>0)) then begin
    RekLink(100,702,12,0);   // Zieladresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.P.Zielanschrift') AND (aBuf->BAG.P.Zielanschrift<>0)) then begin
    RekLink(101,702,13,0);   // Zielanschrift holen
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.P.ExterneLiefNr') AND (aBuf->BAG.P.ExterneLiefNr<>0)) then begin
    RekLink(100,702,7,0);   // externer. Lief holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.P.ExterneLiefAns') AND (aBuf->BAG.P.ExterneLiefAns<>0)) then begin
    Adr.A.Adressnr # BAG.P.ExterneLiefNr;
    Adr.A.Nummer # BAG.P.ExterneLiefAns;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', BAG.P.ExterneLiefNr);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.P.Ressource.Grp') AND (aBuf->BAG.P.Ressource.Grp<>0)) then begin
    RekLink(822,702,10,0);   // Ressource Grp holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.P.Ressource') AND (aBuf->BAG.P.Ressource<>0)) then begin
    RekLink(160,702,11,0);   // Ressourece holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
