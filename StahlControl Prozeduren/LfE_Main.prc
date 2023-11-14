@A+
//==== Business-Control ==================================================
//
//  Prozedur    LfE_Main
//                    OHNE E_R_G
//  Info
//
//
//  11.02.2014  AH  Erstellung der Prozedur
//  17.12.2014  AH  Erweiterung um Bestellnummer und Materialinfo
//  21.11.2016  AH  Betellnummer ist Pflichtfeld bei Einzelbestätigung
//  25.07.2022  HA  Quick jump
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aView   : logic) : logic;
//    SUB EvtInit(
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(
//    SUB EvtFocusTerm(
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant(opt aPara : alpha)
//    sub AusBestellung();
//    SUB RefreshMode(opt aNoRefresh : logic);
//    SUB EvtMenuCommand(
//    SUB EvtClicked(
//    SUB EvtPageSelect(
//    SUB EvtLstDataInit(
//    SUB EvtLstSelect(
//    SUB EvtClose(
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cDialog     : 'LfE.Verwaltung'
  cTitle      : 'Lieferantenerklärungen'
  cRecht      : Rgt_LfErklaerungen
  cMdiVar     : gMDIQS
  cFile       : 130
  cMenuName   : 'LfE.Bearbeiten'
  cPrefix     : 'LfE'
  cZList      : $ZL.LfE
  cKey        : 1
  cListen     : 'LfE'
end;

declare ShowMaterial();


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aView   : logic) : logic;
begin
  if (Rechte[Rgt_LfErklaerungen]=false) or
    (StrFind(Set.Module,'L',0)=0) then RETURN false;

  RETURN App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
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
  winsearchpath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;

Lib_Guicom2:Underline($edLfE.Lieferantennr);

  // Auswahlfelder setzen...
  SetStdAusFeld('edLfE.Lieferantennr'         ,'Lieferant');
  SetStdAusFeld('edLfE.Einkaufsnr'            ,'Bestellung');

  App_Main:EvtInit(aEvt);
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
  Lib_GuiCom:Pflichtfeld($edLfE.Lieferantennr);
  if (Lfe.Typ='E') then
    Lib_GuiCom:Pflichtfeld($edLfE.Einkaufsnr);

end;


//========================================================================
// RTFTextSave
//              Text abspeichern
//========================================================================
sub RTFTextSave()
local begin
  vTxtHdl             : int;          // Handle des Textes
end
begin
  // Text laden
  vTxtHdl # $LfE.RTF->wpdbTextBuf;
  $LfE.RTF->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);

  // Text speichern
  TxtWrite(vTxtHdl,'~130.'+cnvai(LfE.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), _TextUnlock);

END;


//========================================================================
// RTFTextRead
//              Text einlesen
//========================================================================
sub RTFTextRead()
local begin
  vTxtHdl             : int;          // Handle des Textes
  vName               : alpha;
end
begin

  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then RETURN

  vName # '~130.'+cnvai(LfE.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)
  // Text laden
  if ($Lfe.RTF->wpCustom=vName) then RETURN;

  vTxtHdl # $LfE.RTF->wpdbTextBuf;
  if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then
    TextClear(vTxtHdl);

  $LfE.RTF ->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
  $Lfe.RTF->wpcustom # vName;
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
  vHdl  : int;
end;
begin

  vHdl # $LfE.RTF->wpdbtextBuf;
  if (vHdl=0) then begin
    vHdl # TextOpen(32);
    $LfE.RTF->wpdbTextBuf # vHdl;
  end;
  if (aName='') then RTFTextRead();



//  if (aName='') or (aName='edLfE.Lieferantennr') then begin
//    if (LfE.Lieferantennr<>0) then begin
//      Erx # RekLink(100,130,2,0); // Lieferant holen
//      $Lb.LfStichwort->wpcaption # Adr.Stichwort;
//    end;
//  end;


  if (aName='') or (aName='Typ') then begin
    if (LfE.Typ='E') then begin
      $cbLfE.Einzel->wpCheckState # _WinStateChkChecked;
      $cbLfE.Langzeit->wpCheckState # _WinStateChkUnchecked;
      end
    else begin
      $cbLfE.Einzel->wpCheckState # _WinStateChkUnChecked;
      $cbLfE.Langzeit->wpCheckState # _WinStateChkchecked;
    end;
    $cbLfE.Einzel->Winupdate();
    $cbLfE.Langzeit->Winupdate();
  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
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
local begin
  vHdl  : int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('LfE.RecInit','')<0) then RETURN;

  vHdl # $LfE.RTF->wpdbTextBuf;
  if (vHdl<>0) then begin
    TextClear(vHdl);
    $LFE.RTF->WinUpdate(_WinUpdBuf2Obj);
  end;


  if (mode=c_modeNew) then
    LfE.Typ # 'E';
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edLfE.Lieferantennr->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (LfE.Lieferantennr=0) then begin
    Lib_Guicom2:InhaltFehlt('Lieferant', 'NB.Page1', 'edLfE.Lieferantennr');
    RETURN false;
  end;
  Erx # RecLink(100,130,2,_RecTest);
  If (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Lieferant', 'NB.Page1', 'edLfE.Lieferantennr');
    RETURN false;
  end;
  if (LfE.Typ<>'E') and (LfE.Typ<>'L') then begin
    Lib_Guicom2:InhaltFalsch('Lieferant', 'NB.Page1', 'cbLfE.Einzel');
    RETURN false;
  end;

  if (Lfe.Typ='E') then begin
    if (LfE.Einkaufsnr=0) then begin
      Lib_Guicom2:InhaltFehlt('Bestellung', 'NB.Page1', 'edLfE.EinkaufsNr');
      RETURN false;
    end;
  end;


  // Nummernvfabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin

    LfE.Nummer # Lib_Nummern:ReadNummer('Lieferantenerklaerung');
    if (LfE.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;

    LfE.Anlage.Datum  # Today;
    LfE.Anlage.Zeit   # Now;
    LfE.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;


  // Text aktualisieren
  RTFTextSave();


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
  Erx : int;
end;
begin

  // Prüfung
  Erx # RecLinkInfo(200,130,7,_recCount) + RecLinkInfo(210,130,8,_recCount);
  if (Erx>0) then begin
    Msg(130200,'',0,0,0);
    RETURN;
  end;


  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    TRANSON;

    // Strukturen löschen
    FOR Erx # RecLink(131,130,1,_recfirst)
    LOOP Erx # RecLink(131,130,1,_recfirst)
    WHILE (Erx<=_rLocked) do begin
      if (Erx=_rLocked) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RekDelete(131,0,'AUTO');
    END;

    if (RekDelete(gFile,0,'MAN')<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;

    TRANSOFF;


    if (gZLList->wpDbSelection<>0) then begin
      SelRecDelete(gZLList->wpDbSelection,gFile);
      RecRead(gFile, gZLList->wpDbSelection, 0);
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

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);


   if (aEvt:obj -> wpname ='LfE.RTF') then begin
     $Lfe.ToolbarRTF -> wpdisabled # false;
     $Lfe.ToolbarTXT -> wpdisabled # false;
     end
   else if ($Lfe.ToolbarRTF->wpdisabled=false) then begin
     $Lfe.ToolbarRTF -> winupdate(_Winupdon);
     $Lfe.ToolbarRTF -> wpdisabled # true;
     $Lfe.ToolbarTXT -> wpdisabled # true;
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
local begin
  Erx : int;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);
  if (aEvt:Obj->wpname='edLfE.Lieferantennr') then begin
    Erx # RecLink(100,130,2,_RecFIrst);
    if (LfE.Lieferantennr=0) or  (erx>_rLockeD) then RecBufClear(100);
    LfE.LieferantenSW # Adr.Stichwort;
    $Lb.LfStichwort->wpcaption # LfE.LieferantenSW;
  end;

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
  vQ    : alpha(4000);
end;

begin

  case aBereich of

    'Bestellung' : begin
      RecBufClear(501);
      RecBufClear(500);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusBestellung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      if (LfE.Lieferantennr != 0) then begin
        vQ # '';
        Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', LfE.Lieferantennr);
        Lib_Sel:QRecList(0,vQ);
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt( var vQ, 'Adr.Lieferantennr', '>', 0);
      Lib_Sel:QRecList(0,vQ);

      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;  // ...case

end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lfe.Lieferantennr # Adr.Lieferantennr;
    LfE.LieferantenSW # Adr.Stichwort;

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    $Lb.LfStichwort->wpcaption # LfE.LieferantenSW;
  end;

  $edLfE.Lieferantennr->WinFocusSet(false);
end;


//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellung()
local begin
  Erx : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(501,0,_RecId,gSelected);
  gSelected # 0;
  Erx # RekLink(500,501,3,_recFirst);   // Kopf holen
  // Feldübernahme
  LfE.Einkaufsnr    # Ein.P.Nummer;
  LfE.Einkaufspos   # Ein.P.Position;
  Lfe.Lieferantennr # Ein.P.Lieferantennr;

  $edLfE.Einkaufspos->Winupdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edLfE.Einkaufsnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edLfE.Lieferantennr',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl    : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfe_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfe_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfe_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LfE_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfe_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfe_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Intrastatnr');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

//  vHdl # gMenu->WinSearch('Mnu.Info.Material');
// if (vHdl <> 0) then
//    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfe_Loeschen]=n);

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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Info.Material' : begin
      ShowMaterial();
    end;


    'Mnu.Intrastatnr' : begin
      RecBufClear(131);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'LfE.S.Verwaltung','', true);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Lfe.Anlage.Datum, Lfe.Anlage.Zeit, Lfe.Anlage.User);
    end;

  end; // ...case


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
    'bt.Lieferant'  :   Auswahl('Lieferant');
    'bt.Bestellung' :   Auswahl('Bestellung');
  end;  // ...case

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
//  Erx # RekLink(100,130,2,0); // Lieferant holen
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
//  EvtChanged
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:obj=$cbLfE.Einzel) then begin
    if ($cbLfE.Einzel->wpCheckState=_WinStateChkChecked) then LfE.Typ # 'E';
  end;

  if (aEvt:obj=$cbLfE.Langzeit) then begin
    if ($cbLfE.Langzeit->wpCheckState=_WinStateChkChecked) then LfE.Typ # 'L';
  end;

  RefreshIfm('Typ');

  RETURN(true);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
end;
begin

  vHdl # $LfE.RTF->wpdbTextBuf;
  if (vHdl<>0) then TextClose(vHdl);

  RETURN true;
end;


//========================================================================
//========================================================================
sub ShowMAterial();
local begin
  i         : int;
  vFeld     : alpha[100];
  vTyp      : int[100];
  vQInfo    : Alpha(1000);
  vSumStr   : alpha;
end
begin

  i # 1;
  vFeld[i] # 'Materialnr.';    vTyp[i]  # _TypeDate;   inc(i);
  vFeld[i] # 'Qualität';       vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Dicke';          vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Breite';         vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Länge';          vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Kommission';     vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Gewicht';        vTyp[i]  # _TypeFloat;  /*vSumStr # vSumStr + aint(I) + ',';*/ inc(i);

  vQInfo  # 'Material mit LfE:' + aint(LfE.Nummer);
  Lib_QuickInfo:Show(vQInfo, var vFeld,var vTyp, here+':_ShowMaterial_Data', false, vSumStr);
end;


//========================================================================
// sub _ShowMaterial_Data(var aSortTreeHandle : int)
//      Ermittelt die darzustellenden Datensätze
//========================================================================
sub _ShowMaterial_Data(var aSortTreeHandle : int)
local begin
  Erx         : int;
  vPrg        : int;
  vMax        : int;
  vCurrent    : int;
  vSortKey    : alpha;
end;
begin

  vPrg # Lib_Progress:Init('Datenermittlung');

  vMax # RecLinkInfo(200,130,7,_RecCount) + RecLinkInfo(210,130,8,_RecCount);

  // Materialbestand
  FOR   Erx # RecLink(200,130,7,_RecFirst)
  LOOP  Erx # RecLink(200,130,7,_RecNext)
  WHILE Erx <= _rLocked DO BEGIN
    inc(vCurrent);
    if (vCurrent > 1000) then
      BREAK;

    vPrg->Lib_Progress:SetLabel('Sortierung ' + Aint(vCurrent) + '/' + Aint(vMax))
    if (vPrg->Lib_Progress:Step() = false) then BREAK;

    // Sortierungsschlüssel definieren
    vSortKey # cnvAI(Mat.Nummer,_FmtNumLeadZero|_fmtNumNoGroup,0,10);

    Sort_ItemAdd(aSortTreeHandle,vSortKey,200,RecInfo(200,_RecId));
  END;


  // Materialablage
  FOR   Erx # RecLink(210,130,8,_RecFirst)
  LOOP  Erx # RecLink(210,130,8,_RecNext)
  WHILE Erx <= _rLocked DO BEGIN
    inc(vCurrent);
    if (vCurrent > 1000) then
      BREAK;

    vPrg->Lib_Progress:SetLabel('Sortierung ' + Aint(vCurrent) + '/' + Aint(vMax))
    if (vPrg->Lib_Progress:Step() = false) then BREAK;

    // Sortierungsschlüssel definieren
    vSortKey # cnvAI("Mat~Nummer",_FmtNumLeadZero|_fmtNumNoGroup,0,10);

    Sort_ItemAdd(aSortTreeHandle,vSortKey,210,RecInfo(210,_RecId));
  END;


  vPrg->Lib_Progress:Term();
end;


//========================================================================
// sub _ShowMaterial_Data_Pos(aSortItem : int; var aRecord : alpha[];)
//      Weist dem Zeilenarray die gewünschten Daten zu
//========================================================================
sub _ShowMaterial_Data_Pos(aSortItem : int; var aRecord : alpha[];)
local begin
  i : int;
  vEKPreis : float;
end;
begin

  RecRead(cnvIA(aSortItem->spCustom), 0, 0, aSortItem->spID); // Datensatz holen

  // Ablage in Bestand kopieren
  if (cnvIA(aSortItem->spCustom) = 210) then begin
    RecbufCopy(210,200);
  end;

  // Zeile zusammenstellen
  i # 1;
  aRecord[i] # aint(Mat.Nummer);                            inc(i);
  aRecord[i] # "Mat.Güte";                                  inc(i);
  aRecord[i] # ANum(Mat.Dicke,  Set.Stellen.Dicke);         inc(i);
  aRecord[i] # ANum(Mat.Breite, Set.Stellen.Breite);        inc(i);
  aRecord[i] # ANum("Mat.Länge", "Set.Stellen.Länge");      inc(i);
  aRecord[i] # Mat.Kommission;                              inc(i);
  aRecord[i] # ANum(Mat.Bestand.Gew, Set.Stellen.Gewicht);  inc(i);

end;

//========================================================================
// sub _ShowMaterial_Data_Pos(aSortItem : int; var aRecord : alpha[];)
//      Weist dem Zeilenarray die gewünschten Daten zu
//========================================================================
sub _ShowMaterial_Data_Sort(aRowIndex : int) : alpha
begin
  case (aRowIndex) of
    1 : begin RETURN Lib_Strings:IntForSort(Mat.Nummer);            end;
    2 : begin RETURN                          "Mat.Güte";           end;
    3 : begin RETURN Lib_Strings:NumForSort(  Mat.Dicke);           end;
    4 : begin RETURN Lib_Strings:NumForSort(  Mat.Breite);          end;
    5 : begin RETURN Lib_Strings:NumForSort(  "Mat.Länge");         end;
    6 : begin RETURN                          "Mat.Kommission";     end;
    7 : begin RETURN Lib_Strings:NumForSort(  Mat.Bestand.Gew);     end;
  end;
end;


//========================================================================
//  Call LFE_Main:FillLieferantenSW
//========================================================================
sub FillLieferantenSW()
local begin
  Erx : int;
end;
begin

  FOR Erx # RecRead(130,1,_recFirst)
  LOOP Erx # RecRead(130,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(130,1,_RecLock);
    RecBufClear(100);
    if (LfE.Lieferantennr<>0) then begin
      Erx # RekLink(100,130,2,0); // Lieferant holen
      if (Erx>_rlocked) then RecBufClear(100);
    end;
    LfE.LieferantenSW # Adr.Stichwort;
    Rekreplace(130);
  END;
  
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edLfE.Lieferantennr') AND (aBuf->LfE.Lieferantennr<>0)) then begin
    RekLink(100,130,2,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
