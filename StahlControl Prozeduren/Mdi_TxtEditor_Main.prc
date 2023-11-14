@A+
//===== Business-Control =================================================
//
//  Prozedur      Mdi_TxtEditor_Main
//                  OHNE E_R_G
//  Info
//
//
//  13.12.2010  AI  Erstellung der Prozedur
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//
//    SUB Start(aTextname : alpha; aMitEdit  : logic; aTitel    : alpha; opt aProc : alpha);
//    SUB TextLoad()
//    SUB TextSave()
//    SUB Action(aMode : alpha);
//    SUB PrintTXT()
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMdiActivate(aEvt : event) : logic;
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic;
//    SUB EvtMenuCommand (aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked (aEvt : event;) : logic
//    SUB AusKopftext();
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:def_Global

define begin
  cTitle      : 'Texteditor'
  cFile       : 0
  cMenuName   : Lib_GuiCom:GetAlternativeName('Mdi.TxtEditor')
  cPrefix     : 'Mdi_TxtEditor'
  cZList      : 0//$RecList1
  cKey        : 0
end;

declare Refreshmode(opt aNoRefresh : logic);

//========================================================================
//  Start
//
//========================================================================
sub Start(
  aTextname     : alpha;
  aMitEdit      : logic;
  aTitel        : alpha;
  opt aProc     : alpha;
  opt aMDI      : int);
local begin
  vHdl : int;
  vTmp : int;
end;
begin
  Gv.Alpha.01 # Lib_GuiCom:GetAlternativeName('Mdi.TXTEDITOR');
  GV.Alpha.02 # aTextName;
  Gv.Alpha.03 # '';
  if (aMitEdit) then GV.ALpha.03 # 'TRUE';
  if (aMDI=0) then aMDI # gMDI;
  gMDI # Lib_GuiCom:AddChildWindow(aMDI,Lib_GuiCom:GetAlternativeName('Mdi.TxtEditor'),aProc);
  //vTmp # Winsearch(gMDI,'rtf.FrameClient1');
  //vTmp->wpcustom # aTitel;
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  gTitle # aTitel;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// PrintTXT
//              Druckt einen TXT-Text
//========================================================================
sub PrintTXT()
local begin
  vPrt                : int;        // Descriptor für Ausgabe Elemende
  vHdl                : int;
  vTxtName            : alpha;
  vPL                 : int;
  vHeader             : int;
  vFooter             : int;
end
begin
  // universelle PrintLine generieren
  vPL # Lib_PrintLine:Create();
  vHeader # 0;
  vFooter # 0;
  // Job Öffnen + Page generieren
//  Lib_Print:FrmJobOpen('tmp'+AInt(gUserID),vHeader , vFooter, n, n, n, '', 'FALSE');
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter, n , n, n, '', 'FALSE') < 0) then begin
    if (vPL <> 0) then Lib_Printline:Destroy(vPL);
    RETURN;
  end;


  if(form_Job->prtinfo(_PrtJobPageCount) = 0) then begin
    Lib_PrintLine:PrintLine();
    Lib_PrintLine:PrintLine();
    Lib_PrintLine:PrintLine();
  end;

  vTxtName # $TXT.TXTEditor->wpcustom;
  Lib_Print:Print_Textbaustein(vTxtName);

  // -------- Druck beenden ----------------------------------------------------------------
  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(true);

  // Objekte entladen
  if (vPL<>0) then
    Lib_PrintLine:Destroy(vPL);
  if (vHeader<>0) then
    vHeader->PrtFormClose();
  if (vFooter<>0) then
    vFooter->PrtFormClose();
end;


//========================================================================
// TextSave
//              Text abspeichern
//========================================================================
sub TextSave()
local begin
  vTxtHdl             : int;          // Handle des Textes
end
begin
  // Text laden
  vTxtHdl # $TXT.TXTEditor->wpdbTextBuf;
  $TXT.TXTEditor->WinUpdate(_WinUpdObj2Buf);
//  $TXT.TXTEditor->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);
  // Text speichern
  TxtWrite(vTxtHdl, $TXT.TXTEditor->wpcustom, _TextUnlock);

  // AFX
  RunAFX(Lib_GuiCom:GetAlternativeName('Mdi.TXT.TextSave'),$TXT.TXTEditor->wpcustom)
END;


//========================================================================
// TextLoad
//              Text lesen
//========================================================================
sub TextLoad()
local begin
  vTxtHdl             : int;          // Handle des Textes
end
begin
  // Text laden
  vTxtHdl # $TXT.TXTEditor->wpdbTextBuf;
  if (TextRead(vTxtHdl, $TXT.TXTEditor->wpcustom, _TextUnlock)>_rLocked) then
    TextClear(vTxtHdl);
  $TXT.TXTEditor->WinUpdate(_WinUpdBuf2Obj);
//  $TXT.TXTEditor->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
end;


//========================================================================
//  Action
//
//========================================================================
Sub Action(aMode : alpha);
begin

  case Mode of

    // Ansichtsmodus aktiv ?????????????????????????????????????????????????????
    c_ModeView  : begin
      if (aMode=c_ModeCancel) then begin
        Mode # c_ModeCancel;
        gMdi->Winclose();
        RETURN;
      end;

      if (aMode=c_ModeEdit) then begin
        Mode # c_ModeEdit;
        RefreshMode();
        $TXT.TXTEditor->winfocusset(false);
        RETURN;
      end;
    end;


    // Editiermodus aktiv ??????????????????????????????????????????????????????
    c_ModeEdit  : begin
      if (aMode=c_ModeCancel) then begin
        //Änderungen verwerfen?
        if (Msg(000003,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
          Mode # c_ModeView;
          RefreshMode();
          TextLoad();
        end;
        RETURN;
      end;

      if (aMode=c_ModeSave) then begin
        Mode # c_ModeView;
        RefreshMode();
        TextSave();
        RETURN;
      end;
    end;

  end;

end;


//========================================================================
//  EvtInit
//
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vTxtHdl : int;
end;
begin
  WinSearchPath(aEvt:Obj);

  vTxtHdl # $TXT.TXTEditor->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $TXT.TXTEditor->wpdbTextBuf # vTxtHdl;
  end;

  // Übergebene Daten aufnehmen....
  if (Gv.Alpha.01=Lib_GuiCom:GetAlternativeName('Mdi.TXTEDITOR')) then begin
    $TXT.TXTEditor->wpcustom    # GV.Alpha.02;
    if (GV.Alpha.03<>'TRUE') then
      $Edit2->wpvisible # false;
    Gv.Alpha.01 # '';
    Gv.Alpha.02 # '';
    Gv.Alpha.03 # '';
  end;

  mode      # c_modeView;

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_NoList  # true;

  TextLoad();

  RETURN App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
begin
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vMitEdit    : logic;
end;
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMDI->WinSearch('Edit2');
  if (vHdl <> 0) then
    vMitEdit # vHdl->wpvisible;
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_modeView) or (vMitEdit=false);
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_modeView) or (vMitEdit=false);
  vHdl # gMDI->WinSearch('Save2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_modeEdit);
  vHdl # gMenu->WinSearch('Mnu.Save2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_modeEdit);

  vHdl # gMDI->WinSearch('Cancel2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;
  vHdl # gMenu->WinSearch('Mnu.Cancel2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;

  $TXT.TXTEditor->wpreadonly  # (Mode<>c_ModeEdit);

  case Mode of
    c_ModeView: begin
      gMdi->wpcaption # gTitle+' '+Translate('Ansicht');
    end;

    c_ModeEdit: begin
      gMdi->wpcaption # gTitle+' '+Translate('bearbeiten');
    end;
  end;
  gMdi->Winupdate(_Winupdon);

  if (mode=c_modeView) then begin
    if (vMitEdit) then $Edit2->winfocusset(true)
    else $Edit2Ersatz->winfocusset(true);
  end;

end;


//========================================================================
//  EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  App_Main:EvtMdiActivate(aEvt);
  Refreshmode();
end;


//========================================================================
//  EvtFocusInit
//
//========================================================================
sub EvtFocusInit(
  aEvt                 : event;    // Ereignis
  aFocusObject         : int;      // Objekt, das den Fokus zuvor hatte
) : logic;
local begin
  vHdl      : int;
  vMitEdit  : logic;
end;
begin
  vHdl # gMDI->WinSearch('Edit2');
  if (vHdl <> 0) then
    vMitEdit # vHdl->wpvisible;
  if (mode=c_modeView) then begin
    if (vMitEdit) then $Edit2->winfocusset(true)
    else $Edit2Ersatz->winfocusset(true);
  end;
  return(true);
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

    'tbnPrint' : begin
      PrintTXT();
    end;

    'Mnu.Edit2' : begin
      Action(c_ModeEdit);
    end;

    'Mnu.Cancel2' : begin
      Action(c_ModeCancel);
    end;

    'Mnu.Save2' : begin
      Action(c_ModeSave);
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

  case (aEvt:Obj->wpName) of

    'bt.Kopftext' :
    if (mode=c_modeedit) then begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusKopftext');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Save2'   :   Action(c_ModeSave);
    'Cancel2' :   Action(c_ModeCancel);
    'Edit2'   :   Action(c_ModeEdit);
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
    vTxtHdl # $TXT.TxtEditor->wpdbTextBuf;
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,Auf.Sprache);
    $TXT.TxtEditor->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $TXT.TxtEditor->Winfocusset(false);
  // ggf. Labels refreshen
end;



//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTxtHdl : int;
end;
begin
  if ($TXT.TXTEditor -> wpreadonly = false) then
    TextSave();

  vTxtHdl # $TXT.TXTEditor->wpdbTextBuf;
  if (vTxtHdl <> 0) then
    TextClose(vTxtHdl);

  RETURN true;
end;


//========================================================================
// EvtClose2
//          Schliessen eines Fensters
//========================================================================
sub EvtClose2(
  aEvt                  : event;        // Ereignis
): logic
begin

  if (Mode <> c_ModeEdit) and (Mode <> c_ModeNew) then
    RETURN App_Main:EvtClose(aEvt);

  Action(c_modeCancel);
  RETURN false;

end;

//========================================================================