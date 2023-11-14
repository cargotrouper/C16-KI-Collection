@A+
//==== Business-Control ==================================================
//
//  Prozedur    VsP_Main
//                    OHNE E_R_G
//  Info
//
//
//  01.07.2009  AI  Erstellung der Prozedur
//  11.12.2012  AI  NEU: Serienmarkierung
//  08.09.2021  MR  NEU: AFX Evt.Init
//  04.10.2021  MR  Einbau von Gv.Aplpha06 & Gv.Int.01 Ticket(2166/42/1)
//  12.11.2021  AH  ERX
//  26.04.2022  AH  für Pakete
//  26.07.2022  HA  Quick Jump
//  2023-01-04  MR  Fix Bug beim löschen
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLEER()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle      : 'Versandpool'
  cFile       :  655
  cMenuName   : 'VsP.Bearbeiten'
  cPrefix     : 'VsP'
  cZList      : $ZL.Versandpool
  cKey        : 1
end;

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

Lib_Guicom2:Underline($edVsP.Spediteurnr);

  // Auswahlfelder setzen...
  SetStdAusFeld(  'edVsP.Spediteurnr' ,'Spediteur');

  RunAFX('VsP.Init.Pre',aint(aevt:obj));
  App_Main:EvtInit(aEvt);
  RunAFX('VsP.Init',aint(aEvt:Obj));
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
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  vTmp  : int;
  vA,vB : alpha(200);
  Erx : int;
end;
begin

  if (aName='') then begin
    Erx # RecLink(101,655,4,_recfirst);   // Startanschrift holen
    if (Erx>_rLockeD) then RecBufClear(101);
    $lb.Start1->wpcaption # Adr.A.Name;
    $lb.Start2->wpcaption # "Adr.A.Straße";
    $lb.Start3->wpcaption # Adr.A.LKZ+' '+Adr.A.PLZ+' '+Adr.A.Ort;
    Erx # RecLink(101,655,5,_recfirst);   // Zielanschrift holen
    if (Erx>_rLockeD) then RecBufClear(101);
    $lb.Ziel1->wpcaption # Adr.A.Name;
    $lb.Ziel2->wpcaption # "Adr.A.Straße";
    $lb.Ziel3->wpcaption # Adr.A.LKZ+' '+Adr.A.PLZ+' '+Adr.A.Ort;

    // 26.04.2022 AH: Paket?
    if (VsP.Paketnr <> 0) then begin
      $lb.Materialtitel->wpcaption  # Translate('Paket');//+' '+aint(VsP.Paketnr);
      vA # AInt(VsP.Paketnr);
      Pak.Nummer # VsP.Paketnr;
      Erx # RecRead(280,1,0);
      if (Erx>_rMultikey) then begin
        vA # ' '+Translate('NICHT GEFUNDEN');
      end
      else begin
        if (Pak.Dicke<>0.0) then begin
          vA # vA + '     ' + ANum(Pak.Dicke, Set.Stellen.Dicke);
          if (Pak.Breite<>0.0) then begin
            vA # vA + ' x ' + ANum(Pak.Breite, Set.Stellen.Breite);
            if ("Pak.Länge"<>0.0) then
              vA # vA + ' x ' + ANum("Pak.Länge", "Set.Stellen.Länge");
          end;
        end;
      end;
    end
    else begin
      // Materialinfos...
      if (VsP.Materialnr<>0) then begin
        // INFO 1
        $lb.Materialtitel->wpcaption  # Translate('Material');
        vA # AInt(VsP.Materialnr);
        Erx # RecLink(200,655,2,_recFirst);   // Material holen
        if (Erx>_rLocked) then begin
          vA # ' '+Translate('NICHT GEFUNDEN');
        end
        else begin
          vA # vA + '     ' + ANum(Mat.Dicke, Set.Stellen.Dicke);
          vA # vA + ' x ' + ANum(Mat.Breite, Set.Stellen.Breite);
          if ("Mat.Länge"<>0.0) then
            vA # vA + ' x ' + ANum("Mat.Länge", "Set.Stellen.Länge");
        end;
        vB # Translate('RID')+': '+anum(Mat.RID, Set.Stellen.Radien);
        vB # vB + '  '+Translate('RAD')+': '+anum(Mat.RAD, Set.Stellen.Radien);
        if (Mat.Strukturnr<>'') then
          vB # vB + '   '+Translate('Artikelnummer')+': '+Mat.Strukturnr;

      end
      // ARTIKELINFO...
      else if (VsP.Artikelnr<>'') then begin
        $lb.Materialtitel->wpcaption  # Translate('Artikel');
        vA # VsP.Artikelnr;
        Erx # RecLink(252,655,3,_recFirst);     // Charge holen
        if (Erx>_rLocked) then begin
          vA # ' '+Translate('NICHT GEFUNDEN');
        end
        else begin
          Erx # RecLink(250,252,1,_recFirst);   // Artikel holen
          if (Erx>_rLocked) then
            vA # ' '+Translate('NICHT GEFUNDEN')
          else
            vA # vA + '     ' + Art.Stichwort;
        end;
      end
      else if (VsP.Vorgangstyp=c_VSPTyp_BAG) then begin
        $lb.Materialtitel->wpcaption  # Translate('theor.Einsatz');
        vA # '';
        RecBufClear(701);
        BAG.IO.Nummer # VsP.Vorgangsnr;
        BAG.IO.ID     # VsP.VorgangsPos1;
        Erx # RecRead(701,1,0);     // BA-Input holen
        if (Erx>_rLocked) then begin
          vA # ' '+Translate('NICHT GEFUNDEN');
        end
        else begin
          vA # vA + '     ' + ANum(BAG.IO.Dicke, Set.Stellen.Dicke);
          vA # vA + ' x ' + ANum(BAG.IO.Breite, Set.Stellen.Breite);
          if ("BAG.IO.Länge"<>0.0) then
            vA # vA + ' x ' + ANum("BAG.IO.Länge", "Set.Stellen.Länge");
        end;
      end
      // THOERIEINFOS...
      else if (VsP.Vorgangstyp=c_VSPTyp_AUF) then begin
        $lb.Materialtitel->wpcaption  # Translate('theor.Einsatz');
        vA # '';
        RecBufClear(401);
        Auf.P.Nummer    # VsP.Vorgangsnr;
        Auf.P.Position  # VsP.VorgangsPos1;
        Erx # RecRead(401,1,0);     // AufPos holen
        if (Erx>_rLocked) then begin
          vA # ' '+Translate('NICHT GEFUNDEN');
        end
        else begin
          vA # vA + '     ' + ANum(Auf.P.Dicke, Set.Stellen.Dicke);
          vA # vA + ' x ' + ANum(Auf.P.Breite, Set.Stellen.Breite);
          if ("Auf.P.Länge"<>0.0) then
            vA # vA + ' x ' + ANum("Auf.P.Länge", "Set.Stellen.Länge");
        end;
      end;
    end;  // nicht Paket
    $lb.Materialinfo->wpcaption   # vA;
    $lb.materialinfo2->wpcaption  # vB;
  end;
  
  if (aName='edVsP.Spediteurnr') and ($edVsP.Spediteurnr->wpchanged) then begin
    Erx # RecLink(100,655,1,_recFirst);   // Spediteuer holen
    if (Erx>_rMultikey) or (VsP.Spediteurnr=0) then RecBufClear(100);
    VsP.Spediteurnr # Adr.Nummer;
    VsP.SpediteurSW # Adr.Stichwort;
  end;
  $lb.Spediteur->wpcaption # VsP.SpediteurSW;


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
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  if (Mode=c_ModeEdit) and (VsP.Vorgangstyp=c_VSPTyp_Auf) and (VsP.Materialnr=0) then begin
    Lib_GuiCom:Enable($edVsP.Menge.In.Soll);
    Lib_GuiCom:Enable($edVsP.Menge.Out.Soll);
    Lib_GuiCom:Enable($edVsP.Stck.Soll);
    Lib_GuiCom:Enable($edVsP.Gewicht.Soll);
  end;
  // Felder Disablen durch:
  // Focus setzen auf Feld:
  $edVsP.Bemerkung->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    VsP.Menge.In.Rest   # VsP.Menge.In.Rest - (ProtokollBuffer[655]->VsP.Menge.In.Soll) + VsP.Menge.In.Soll;
    VsP.Menge.Out.Rest  # VsP.Menge.In.Rest - (ProtokollBuffer[655]->VsP.Menge.In.Soll) + VsP.Menge.In.Soll;
    "VsP.Stück.Rest"    # "VsP.Stück.Rest" - (ProtokollBuffer[655]->"VsP.Stück.Soll") + "VsP.Stück.Soll";
    VsP.Gewicht.Rest    # VsP.Gewicht.Rest - (ProtokollBuffer[655]->VsP.Gewicht.Soll) + VsP.Gewicht.Soll;

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    VsP.Anlage.Datum  # Today;
    VsP.Anlage.Zeit   # Now;
    VsP.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
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
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx   : int;
end
begin

  case (VsP.Vorgangstyp) of

    c_VSPTyp_Auf : begin
      // Diesen Eintrag wirklich löschen?
      if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
      Erx # VsP_Data:Pool2Ablage('MAN',y);
      if (Erx<>_rOK) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;
    end;


    c_VSPTyp_BAG : begin
      // Diesen Eintrag wirklich löschen?
      if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
      Erx # VsP_Data:Pool2Ablage('MAN',y);
      if (Erx<>_rOK) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;
    end;
    
    
    c_VSPTyp_Mat : begin
      // Diesen Eintrag wirklich löschen?
      if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
      Erx # VsP_Data:Pool2Ablage('MAN',y);
      if (Erx<>_rOK) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;
    end;
    
     c_VSPTyp_Pak : begin
      // Diesen Eintrag wirklich löschen?
      if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
      Erx # VsP_Data:Pool2Ablage('MAN',y);
      if (Erx<>_rOK) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;
    end;
    
    c_VSPTyp_Ein : begin
      // Diesen Eintrag wirklich löschen?
      if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
      Erx # VsP_Data:Pool2Ablage('MAN',y);
      if (Erx<>_rOK) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;
    end;

  end;  // case

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
  vA    : alpha;
end;

begin

  case aBereich of
    'Spediteur' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusSpediteur');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusSpediteur
//
//========================================================================
sub AusSpediteur()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    VsP.Spediteurnr # Adr.Lieferantennr;
    VsP.SpediteurSW # Adr.Stichwort;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edVsP.SpediteurNr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
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

  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (VsP.Paketnr=0);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_VsP_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_VsP_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsp_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VsP_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VsP_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VsP_Loeschen]=n);

  // Rechte hinzugefügt 2166/61
  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_VsP_Excel_Export]=false;
  
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_VsP_Excel_Import]=false;

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
  vHdl  : int;
  vTmp  : int;
  vQ    : alpha;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  
  case (aMenuItem->wpName) of

    'Mnu.Pak.Material' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(998);
      Lib_Sel:Qint( var vQ, 'Mat.Paketnr', '=', VsP.Paketnr);
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN true;
    end;
    
    'Mnu.Filter.Start' : begin
      Vsp_Mark_Sel('655.xml');
      RETURN true;
    end;

    'Mnu.Mark.Sel' : begin
      Vsp_Mark_Sel();
      RETURN true;
    end;
    
    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Vsp.Anlage.Datum, VsP.Anlage.Zeit, VsP.Anlage.User);
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
    'bt.Spediteur' :   Auswahl('Spediteur');
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
// 04.10.2021 MR Einbau von Gv.Aplpha06 & Gv.Int.01 Ticket(2166/42/1)
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  Erx   : int;
  vCol  : int;
end
begin

  Erx # RecLink(651,655,6,_recFirsT);
  if (erx>_rMultikey) then RecBufClear(651);

  
  Gv.Alpha.01 # VsP.VorgangsTyp+' '+AInt(VsP.Vorgangsnr);
  if (VsP.VorgangsPos1<>0) then
    Gv.Alpha.01 # Gv.Alpha.01 +'/'+AInt(VsP.VorgangsPos1);
  if (VsP.VorgangsPos2<>0) then
    Gv.Alpha.01 # Gv.Alpha.01 +'/'+AInt(VsP.Vorgangspos2);

  Erx # RecLink(101,655,4,_recfirst);   // Startanschrift holen
  if (Erx>_rLockeD) then RecBufClear(101);
  GV.Alpha.02 # Adr.A.PLZ+' '+Adr.A.Ort +', '+Adr.A.Name;
  Erx # RecLink(101,655,5,_recfirst);   // Zielanschrift holen
  if (Erx>_rLockeD) then RecBufClear(101);
  GV.Alpha.03 # Adr.A.PLZ+' '+Adr.A.Ort + ', '+ Adr.A.Name;

  Gv.Alpha.04 # '';
  if (VsP.Auftragsnr<>0) then
    Gv.Alpha.04 # AInt(VsP.Auftragsnr);
  if (VsP.AuftragsPos<>0) then
    Gv.Alpha.04 # Gv.Alpha.04 +'/'+AInt(VsP.AuftragsPos);
  if (VsP.AuftragsPos2<>0) then
    Gv.Alpha.04 # Gv.Alpha.04 +'/'+AInt(VsP.Auftragspos2);

  GV.Alpha.05 # '';
  // 26.04.2022 AH: Paket?
  if (VsP.Paketnr <> 0) then begin
    GV.Alpha.05 # Translate('Paket')+' '+aint(VsP.Paketnr);
  end
  else begin
    if (VsP.Materialnr <> 0) then begin
      Erx # RecLink(200,655,2,_recFirst);   // Material holen
      if (Erx>_rlocked) then RecBufClear(200);
      if (Mat.Dicke<>0.0) or (Mat.Breite<>0.0) or ("MAt.Länge"<>0.0) then begin
        Lib_Strings:Append(var GV.Alpha.05, ANum("Mat.Dicke", Set.Stellen.Dicke), ' x ');
        Lib_Strings:Append(var GV.Alpha.05, ANum("Mat.Breite", Set.Stellen.Breite), ' x ');
        if("Mat.Länge" <> 0.0) then
          Lib_Strings:Append(var GV.Alpha.05, ANum("Mat.Länge", "Set.Stellen.Länge"), ' x ');
      end;
    end
    else if(VsP.Vorgangstyp = c_VSPTyp_BAG) then begin
      BAG.IO.Nummer # VsP.Vorgangsnr;
      BAG.IO.ID     # VsP.VorgangsPos1;
      Erx # RecRead(701,1,0);     // BA-Input holen
      if (Erx>_rlocked) then RecBufClear(701);
      if (BAG.IO.Dicke<>0.0) or (BAG.IO.Breite<>0.0) or ("BAG.IO.Länge"<>0.0) then begin
        Lib_Strings:Append(var GV.Alpha.05, ANum("BAG.IO.Dicke", Set.Stellen.Dicke), ' x ');
        Lib_Strings:Append(var GV.Alpha.05, ANum("BAG.IO.Breite", Set.Stellen.Breite), ' x ');
        if("BAG.IO.Länge" <> 0.0) then
          Lib_Strings:Append(var GV.Alpha.05, ANum("BAG.IO.Länge", "Set.Stellen.Länge"), ' x ');
      end;
    end
    else if(VsP.Vorgangstyp = c_VSPTyp_AUF) then begin
      Auf.P.Nummer    # VsP.Vorgangsnr;
      Auf.P.Position  # VsP.VorgangsPos1;
      Erx # RecRead(401,1,0);     // AufPos holen
      if (Erx>_rlocked) then RecBufClear(401);
      if (Auf.P.Dicke<>0.0) or (Auf.P.Breite<>0.0) or ("Auf.P.Länge"<>0.0) then begin
        Lib_Strings:Append(var GV.Alpha.05, ANum("Auf.P.Dicke", Set.Stellen.Dicke), ' x ');
        Lib_Strings:Append(var GV.Alpha.05, ANum("Auf.P.Breite", Set.Stellen.Breite), ' x ');
        if("Auf.P.Länge" <> 0.0)then
          Lib_Strings:Append(var GV.Alpha.05, ANum("Auf.P.Länge", "Set.Stellen.Länge"), ' x ');
      end;
    end;
  end;  // nicht Paket
  
/*** 27.01.2022 AH neue Felder
  //04.10.2021  MR  (2166/42/1)
 Erx # RecLink(401, 655, 10, _recFirst); // Erzeuger holen
  if(Erx > _rLocked) then
    RecBufClear(401);
    if((Auf.P.Kundennr <>0)or (Auf.P.KundenSW <> '')) then begin
//      GV.Alpha.06 # Auf.P.KundenSW;
//      GV.Int.01 # Auf.P.Kundennr;
    end;
****/

  if (aMark=n) then begin
    if (VsP.Paketnr<>0) then
      vCol # RGB(255,140,0);
    if (VsP.Materialnr=0) and (vCol=0) then
      vCol # Set.Mat.Col.Bestellt;
    if (vCol<>0) then Lib_GuiCom:ZLColorLine(gZLList, vCol);
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
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edVsP.Spediteurnr') AND (aBuf->VsP.Spediteurnr<>0)) then begin
    RekLink(100,655,1,0);   // Spediteurnr holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================