@A+
//===== Business-Control =================================================
//
//  Prozedur    WoF_Dlg_Main
//                        OHNE E_R_G
//  Info        Routinen für die Workflowzuordung
//
//
//  08.12.2009  AI  Erstellung der Prozedur
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB GetReference(aHdl : int; aUebernehmen : logic);
//    SUB InnerRedrawInfo(aObj : int; aUebernehmen : logic)
//    SUB RedrawInfo(optaUebernehmen : logic);
//    SUB AusFeld()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObj : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtTerm(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cMenuName : 'Sel.Dialog'
  cPrefix :   'WoF_Dlg'
end;

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl : int;
end;
begin

  gZLList # 0;
  vHdl # w_lastfocus;
  App_Main:EvtMdiActivate(aEvt);
  w_lastfocus # vHdl;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich  : alpha;
)
local begin
  Erx   : int;
  vHdl  : int;
  vQ    : alpha(4000);
end;

begin

  vHdl # w_lastFocus;

  case aBereich of

    'Workflow' : begin
      RecBufClear(940);
      vHdl # gMDI->winsearch('lb.Bereich');
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'WoF.Sch.Verwaltung',here+':AusWoF');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'WoF.Sch.Datei'  , '=', cnvia(vHdl->wpcustom));
      vHdl # SelCreate(940, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusWoF
//
//========================================================================
sub AusWoF()
begin
  if (gSelected<>0) then begin
    RecRead(940,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    $edWorkflow->wpcaptionint # WoF.Sch.Nummer;
  end;
  // Focus auf Editfeld setzen:

  $edWorkflow->Winfocusset(false);
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
  Erx : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  WoF.Sch.Nummer # $edWorkflow->wpcaptionint;
  Erx # RecRead(940,1,0);
  if (Erx>_rLocked) then RecBufClear(940);
  $Lb.Workflow->winupdate(_WinUpdFld2Obj);

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
local begin
  Erx : int;
  vHdl :int;
end;
begin

  WoF.Sch.Nummer # $edWorkflow->wpcaptionint;
  Erx # RecRead(940,1,0);
  if (Erx>_rLocked) then RecBufClear(940);
  if (WoF.Sch.Datei<>203) then RecBufClear(940);
  $edWorkflow->wpcaptionint # WoF.Sch.Nummer;
  $Lb.Workflow->winupdate(_WinUpdFld2Obj);


  if (aEvt:Obj->wpname='edWorkflow') then begin
    aEvt:Obj->wpColFocusBkg # _WinColParent;
  end;

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
  vHdl    : int;
  vHdl2   : int;
  vName   : alpha(500);
end;
begin

  case (aEvt:Obj->wpName) of

    'Bt.OK','Bt.Abbruch' : begin
      gSelected # CnvIA(aEvt:Obj->wpCustom)
    end;

    'bt.Workflow' : begin
      Auswahl('Workflow');
    end;
  end;

  RETURN true;
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
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gSelected # 0;

  // Auswahlfelder setzen...
  //SetStdAusFeld('', '');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vParent : int;
  vName   : alpha;
  vTmp    : int;
end;
begin

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
    VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
    w_Child # 0;
    if (gZLList<>0) then gZLList->wpdisabled # false;
    VarInstance(WindowBonus,vTmp);
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
  vHdl  : int;
  vHdl2 : int;
end;
begin

  case (aMenuItem->wpName) of

    'Mnu.SelAuswahl' : begin
      vHdl # WinFocusGet();
      if vHdl<>0 then begin
         case vHdl->wpname of
          'edWorkflow'        :   Auswahl('Workflow');
        end;
      end;
    end;


    'Mnu.SelSave' : begin
        gSelected # 1;
        gMDI->Winclose();
      end;


    'Mnu.SelCancel' : begin
        gSelected # 0;
        gMDI->Winclose();
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
  vDatei    : int;
  vFld      : alpha;
  vWof      : int;
end;
begin
  if (aEvt:obj->wpcustom<>'') then VarInstance(WindowBonus,cnvIA(aEvt:Obj->wpcustom));

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    if (w_parent<>0) then begin
      WinSearchPath(w_Parent);
      VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    end;
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
  end;


  // SPEICHERN...
  if (gSelected=1) then begin
    vHdl # aEvt:Obj->winsearch('lb.Bereich');
    vDatei # cnvia(vHdl->wpcustom);
    vHdl # aEvt:Obj->winsearch('edWorkflow');
    vWof # vHdl->wpcaptionint;
    vFld # vHdl->wpcustom;
    RecRead(vDatei,1,_recLock);
    FldDefByName(vFld, vWof);
    RekReplace(vDatei,0,'MAN');
  end;


  RETURN true;
end;


//========================================================================
//  Dialog
//
//========================================================================
sub Dialog(aDatei : int);
local begin
  vHdl  : handle;
  vName : alpha;
  vFld  : alpha;
  vWof  : int;
end;
begin

  if (StrFind(Set.Module,'W',0)=0) then RETURN;
  if (Rechte[Rgt_Workflow]=false) then RETURN;

  case aDatei of
    203 : begin
      vName # Translate('Reservierung');
      vFld  # 'Mat.R.Workflow';
      vWof  # Mat.R.Workflow;
    end;
    otherwise RETURN;
  end;

  vName # vName + ' '+Lib_rec:MakeKey(aDatei,y );

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'WoF.Dialog','');//here+':AusWoF');
  vHdl # gMDI->winsearch('lb.Bereich');
  vHdl->wpcaption # vName;
  vHdl->wpcustom # AInt(aDatei);
  vHdl # gMDI->winsearch('edWorkflow');
  vHdl->wpcaptionint  # vWoF;
  vHdl->wpcustom      # vFld;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================