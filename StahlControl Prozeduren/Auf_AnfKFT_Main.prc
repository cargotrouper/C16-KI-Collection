@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_AnfKFT_Main
//                  OHNE E_R_G
//  Info        Routinen zure Kopf-& Fusstexteingabe für die
//              MaterialAnfrage aus Auftragspos. sowie Start
//              der Druckausgabe (Formular)
//
//  29.08.2012  TM  Kopie erstellt aus BDF_AnfKFT_Main und angepasst
//  25.09.2012  TM  Übertrag in Entwicklungsdatenraum
//
// Subprozeduren
// SUB EvtInit(aEvt : event;): logic
// SUB xxEvtMdiActivate(aEvt : event;) : logic
// SUB RefreshMode(opt aNoRefresh : logic);
// SUB Auswahl(aBereich  : alpha;)
// SUB AusLieferant()
// SUB AusKopftext()
// SUB AusFusstext()
// SUB EvtFocusInit (aEvt : event; aFocusObject : int) : logic
// SUB EvtFocusTerm (aEvt : event; aFocusObj : int) : logic
// SUB EvtClicked (aEvt : event) : logic
// SUB EvtClose(aEvt : event): logic
// SUB EvtMenuCommand (aEvt : event; aMenuItem : int) : logic
// SUB EvtTerm(aEvt : event;): logic
//
//========================================================================
@I:Def_Global

LOCAL begin
  xd_X         : int;
  d_text      : int;
  d_frame     : int;
  d_Button    : int;
  d_MenuItem  : int;
end;

define begin
  cTitle      : 'Anfrage'
  cFile       :  401
  cMenuName   : 'Auf.AnfKFT.Bearbeiten'
  cPrefix     : 'Auf_AnfKFT'
  cZList      : 0
  cKey        : 0
end;

declare RedrawInfo(opt aUebernehmen : logic);
declare GetReference(aHdl : int; aUebernehmen : logic);


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl    : int;
  vTxtHdl : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  winsearchpath(aEvt:Obj);

  gMDI  # aEvt:obj;
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  // Sprachenüberschriften setzen
  vHdl # gMdi->Winsearch('NB.Page1');
  vHdl -> wpCaption # Set.Sprache1;
  vHdl # gMdi->Winsearch('NB.Page2');
  vHdl -> wpCaption # Set.Sprache2;
  vHdl # gMdi->Winsearch('NB.Page3');
  vHdl -> wpCaption # Set.Sprache3;
  vHdl # gMdi->Winsearch('NB.Page4');
  vHdl -> wpCaption # Set.Sprache4;
  vHdl # gMdi->Winsearch('NB.Page5');
  vHdl -> wpCaption # Set.Sprache5;

  //  Mode # c_ModeOther;
  // Textpuffer prüfen und ggf. anlegen
  vTxtHdl # $edTxt_lang1_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang1_head->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang1_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang1_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang2_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang2_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang2_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang2_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang3_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang3_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang3_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang3_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang4_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang4_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang4_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang4_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang5_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang5_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang5_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang5_foot->wpdbTextBuf # vTxtHdl;
  end;

//  WinSearchPath(aEvt:Obj);
//  aEvt:Obj->wpcustom # cnvai(VarInfo(WindowBonus));
//  Lib_GuiCom:TranslateObject(aEvt:Obj);
//  RETURN true;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  xxEvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub xxEvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl    : int;
  vTxtHdl : int;
end;
begin

  if (w_Child=0) then begin
    // Datei spezifische Vorgaben
    gFrmMain->wpMenuname # 'Auf.AnfKFT.Bearbeiten';    // Menü setzen
    gPrefix # 'Auf_AnfKFT';
    gMenu # gFrmMain->WinInfo(_WinMenu);
  end;

  gMdi # aEvt:Obj;

  // Sprachenüberschriften setzen
  vHdl # gMdi->Winsearch('NB.Page1');
  vHdl -> wpCaption # Set.Sprache1;

  vHdl # gMdi->Winsearch('NB.Page2');
  vHdl -> wpCaption # Set.Sprache2;

  vHdl # gMdi->Winsearch('NB.Page3');
  vHdl -> wpCaption # Set.Sprache3;

  vHdl # gMdi->Winsearch('NB.Page4');
  vHdl -> wpCaption # Set.Sprache4;

  vHdl # gMdi->Winsearch('NB.Page5');
  vHdl -> wpCaption # Set.Sprache5;


  Mode # c_ModeOther;
  Call('App_Main:EvtMdiActivate',aEvt);

  // Textpuffer prüfen und ggf. anlegen
  vTxtHdl # $edTxt_lang1_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang1_head->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang1_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang1_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang2_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang2_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang2_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang2_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang3_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang3_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang3_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang3_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang4_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang4_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang4_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang4_foot->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $edTxt_lang5_head->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang5_head->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $edTxt_lang5_foot->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang5_foot->wpdbTextBuf # vTxtHdl;
  end;

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  // if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich  : alpha;
)
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  vFilter : int;
  vSel    : alpha;
end;

begin

  case aBereich of

    'Kopftext' : begin
      RecBufClear(837);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung','Auf_AnfKFT_Main:AusKopftext');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Fusstext' : begin
      RecBufClear(837);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung','Auf_AnfKFT_Main:AusFusstext');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Lieferant' : begin
      if (Msg(400025,'',_WinIcoInformation,_WinDialogOkCancel,1)<>_WinIdOk) then begin
       RETURN;
     end;

      // ggf. mehrere Lieferanten markieren! / übernehmen aus voriger Prozedur
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');  // hier Selektion
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  vTxtHdl      : int;
end
begin
//todo('sel:'+AInt(gselected));

  Lib_GuiCom:SetWindowState($Auf.P.Verwaltung,true);
  if (gSelected<>0) then begin

    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    $edTxt_lang1_head->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang2_head->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang3_head->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang4_head->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang5_head->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang1_foot->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang2_foot->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang3_foot->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang4_foot->winUpdate(_WinUpdObj2Buf);
    $edTxt_lang5_foot->winUpdate(_WinUpdObj2Buf);

    if (Lib_Dokumente:Printform(540,'AuftragsAnfrage',true)) /*and (Set.Auf.DruckInAktYN)*/ then begin
    end;

    if (Msg(400026,'',_WinIcoInformation,_WinDialogOk,1)<>_WinIdOk) then begin
      RETURN;
    end;

  end;

end;


//========================================================================
//  AusKopftext
//
//========================================================================
sub AusKopftext()
local begin
  vTxtHdl_L1             : int;         // Handle des Textes
  vTxtHdl_L2             : int;         // Handle des Textes
  vTxtHdl_L3             : int;         // Handle des Textes
  vTxtHdl_L4             : int;         // Handle des Textes
  vTxtHdl_L5             : int;         // Handle des Textes
end
begin

  Lib_GuiCom:SetWindowState($Auf.AnfKFT.Dialog.Sel,true);
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl_L1 # $edTxt_lang1_head->wpdbTextBuf;
    vTxtHdl_L2 # $edTxt_lang2_head->wpdbTextBuf;
    vTxtHdl_L3 # $edTxt_lang3_head->wpdbTextBuf;
    vTxtHdl_L4 # $edTxt_lang4_head->wpdbTextBuf;
    vTxtHdl_L5 # $edTxt_lang5_head->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),vTxtHdl_L1,vTxtHdl_L2,vTxtHdl_L3,vTxtHdl_L4,vTxtHdl_L5);
    $edTxt_lang1_head->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang2_head->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang3_head->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang4_head->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang5_head->WinUpdate(_WinUpdBuf2Obj);
  end;

end;


//========================================================================
//  AusFusstext
//
//========================================================================
sub AusFusstext()
local begin
  vTxtHdl_all            : int;         // Textpuffer für alle Sprachen
  vTxtHdl_L1             : int;         // Handle des Textes
  vTxtHdl_L2             : int;         // Handle des Textes
  vTxtHdl_L3             : int;         // Handle des Textes
  vTxtHdl_L4             : int;         // Handle des Textes
  vTxtHdl_L5             : int;         // Handle des Textes
end
begin

//  Lib_GuiCom:SetWindowState($Bdf.AnfKFT.Dialog.Sel,true);
  if (gSelected<>0) then begin

    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl_L1 # $edTxt_lang1_foot->wpdbTextBuf;
    vTxtHdl_L2 # $edTxt_lang2_foot->wpdbTextBuf;
    vTxtHdl_L3 # $edTxt_lang3_foot->wpdbTextBuf;
    vTxtHdl_L4 # $edTxt_lang4_foot->wpdbTextBuf;
    vTxtHdl_L5 # $edTxt_lang5_foot->wpdbTextBuf;

    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),vTxtHdl_L1,vTxtHdl_L2,vTxtHdl_L3,vTxtHdl_L4,vTxtHdl_L5);

    $edTxt_lang1_foot->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang2_foot->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang3_foot->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang4_foot->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang5_foot->WinUpdate(_WinUpdBuf2Obj);

  end;

end;


//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable( aEvt:obj );
  else
    Lib_GuiCom:AuswahlDisable( aEvt:obj );

  RETURN true;

end;


//========================================================================
//  EvtFocusTerm
//                Fokus wechselt hier weg
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObj             : int           // nächstes Objekt
) : logic
begin
  RETURN true;
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl : int;
  vHdl2 : int;
end;
begin

  case (aEvt:Obj->wpName) of
    'Bt.OK','Bt.Abbruch'  : gSelected # CnvIA(aEvt:Obj->wpCustom)
    'bt.Kopftext'         : Auswahl('Kopftext');
    'bt.Fusstext'         : Auswahl('Fusstext');
    'bt.Drucken'          : Auswahl('Lieferant');
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
  vParent : int;
  vName   : alpha;
  vTxtHdl : int;
  vTmp    : int;
end;
begin

  // Texte nach Verlassen wieder löschen
  vTxtHdl # $edTxt_lang1_head->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);
  vTxtHdl # $edTxt_lang1_foot->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);

  vTxtHdl # $edTxt_lang2_head->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);
  vTxtHdl # $edTxt_lang2_foot->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);

  vTxtHdl # $edTxt_lang3_head->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);
  vTxtHdl # $edTxt_lang3_foot->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);

  vTxtHdl # $edTxt_lang4_head->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);
  vTxtHdl # $edTxt_lang4_foot->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);

  vTxtHdl # $edTxt_lang5_head->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);
  vTxtHdl # $edTxt_lang5_foot->wpdbTextBuf;
  if (vTxtHdl<>0) then  TextClose(vTxtHdl);


   if (gFrmMain <> $AppFrameFM) then   // Beim Appframe FM wird kein Tree geöffnet
     if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
       RETURN false;

  // Parentfenster koennen nicht geschlossen werden
  if (w_Child<>0) then RETURN false;

  gFile   # 0;
  gPrefix # '';
  gZLList # 0;

  // Elternbeziehung aufheben?
  if (w_Parent<>0) then begin
    vTmp # VarInfo(Windowbonus);
    if (w_parent->wpcustom<>'') then begin
      VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
      w_Child # 0;
      VarInstance(WindowBonus,vTmp);
    end;
    w_Parent->wpdisabled # n;
    w_Parent->WinUpdate(_WinUpdActivate);
  end;

  RETURN true;
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
  vHdl2 : int;
  vPArent : int;
  vName : alpha;
end;
begin

  case (aMenuItem->wpName) of

    'Mnu.SelAuswahl' : begin
      vHdl # WinFocusGet();     // Feld
      vHdl2 # gMdi->winsearch('LastFocus');
      vHdl2->wpcustom # vHdl->wpname;
      case (vHdl->wpcustom) of
        'Kunde'        : Auswahl('Kunde');
        'Lieferant'    : Auswahl('Lieferant');
        'Vertreter'    : Auswahl('Vertreter');
        'Verband'      : Auswahl('Verband');
        'Wgr'          : Auswahl('Wgr');
        'Agr'          : Auswahl('Agr');
        'Artikeltyp'   : Auswahl('Artikeltyp');
        'Vorgangsart'  : Auswahl('Vorgangsart');
        'Artikelnr'    : Auswahl('Artikelnr');
        'User'         : Auswahl('User');
      end;
    end;

  end;
end;


//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTermProc : alpha;
  vHdl      : int;
end;
begin

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermProc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    WinSearchPath(w_Parent);
    VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
  end;

  RETURN true;
end;

//========================================================================