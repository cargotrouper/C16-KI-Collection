@A+
//===== Business-Control =================================================
//
//  Prozedur
//                  OHNE E_R_G
//  Info        Mdi_RtfEditor_Main
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  20.08.2012  AI  EvtFocusInit setzt nicht mehr auf EDIT, damit man Copy&PAste benutzen kann
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  06.09.2017  AH  Bug: Button Edit beim Start fokusieren
//  28.09.2021  ST  RTF Textauswahl hinzugefügt
//
//  Subprozeduren
//
//    SUB Start(aTextname : alpha; aMitEdit  : logic; aTitel    : alpha; opt aProc : alpha);
//    SUB TextLoad()
//    SUB TextSave()
//    SUB RefreshIfm(aName : alpha);
//    SUB Action(aMode : alpha);
//    SUB Auswahl(aName : alpha);
//    SUB AusText();
//    SUB AusTextAdd();
//    SUB PrintRTF()
//    SUB EvtInit
//    SUB RefreshMode(opt aNoRefresh : logic);
//    SUB EvtMdiActivate
//    SUB EvtFocusInit
//    SUB EvtMenuCommand
//    SUB EvtClicked
//    SUB EvtClose
//
//========================================================================
@I:def_Global

define begin
  cTitle      : 'Texteditor'
  cFile       : 0
  cMenuName   : Lib_GuiCom:GetAlternativeName('Mdi.RtfEditor')
  cPrefix     : 'Mdi_RTFEditor'
  cZList      : 0//$RecList1
  cKey        : 0
end;

declare Refreshmode(opt aNoRefresh : logic);

//========================================================================
//  Start
//
//========================================================================
sub Start(
  aTextname : alpha;
  aMitEdit  : logic;
  aTitel    : alpha;
  opt aProc : alpha);
local begin
  vHdl :  int;
end;
begin
  Gv.Alpha.01 # Lib_GuiCom:GetAlternativeName('Mdi.RTFEDITOR');
  GV.Alpha.02 # aTextName;
  Gv.Alpha.03 # '';
  if (aMitEdit) then GV.ALpha.03 # 'TRUE';
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,Lib_GuiCom:GetAlternativeName('Mdi.RtfEditor'),aProc);
  //vTmp # Winsearch(gMDI,'rtf.FrameClient1');
  //vTmp->wpcustom # aTitel;
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  gTitle # aTitel;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// PrintRTF
//              Druckt einen RTF-Text
//========================================================================
sub PrintRTF()
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
//  Lib_Print:FrmJobOpen('tmp'+AInt(gUserID),vHeader , vFooter, n , n, n, '', 'FALSE');
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter, n , n, n, '', 'FALSE') < 0) then begin
    if (vPL <> 0) then Lib_Printline:Destroy(vPL);
    RETURN;
  end;


  if(form_Job->prtinfo(_PrtJobPageCount) = 0) then begin
    Lib_PrintLine:PrintLine();
    Lib_PrintLine:PrintLine();
    Lib_PrintLine:PrintLine();
  end;

  vTxtName # $rtf.RtfEditor->wpcustom;
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
  vTxtHdl # $rtf.RtfEditor->wpdbTextBuf;
  $rtf.RtfEditor->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);
  // Text speichern
  TxtWrite(vTxtHdl, $rtf.RtfEditor->wpcustom, _TextUnlock);
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
  vTxtHdl # $rtf.RtfEditor->wpdbTextBuf;
  if (TextRead(vTxtHdl, $rtf.RtfEditor->wpcustom, _TextUnlock)>_rLocked) then
    TextClear(vTxtHdl);
  $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin
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
        $bt.Text->wpdisabled # n;
        Mode # c_ModeEdit;
        RefreshMode();
        $rtf.RtfEditor->winfocusset(false);
        RETURN;
      end;
    end;


    // Editiermodus aktiv ??????????????????????????????????????????????????????
    c_ModeEdit  : begin
      if (aMode=c_ModeCancel) then begin
        //Änderungen verwerfen?
        if (Msg(000003,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
          $bt.Text->wpdisabled # y;
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
//  Auswahl
//
//========================================================================
sub Auswahl(aName : alpha);
begin

  case aName of
    'Text' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Text.Add' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusTextAdd');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusText
//
//========================================================================
sub AusText();
local begin
  vTxtHdl   : int;
  vRtfHdl   : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    vTxtHdl   # TextOpen(20);
    if (Txt.RtfYN) then begin
      vTxtHdl->TextRead('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.RTF',0);
      $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
    end else begin
      vRtfHdl   # $rtf.RtfEditor->wpdbTextBuf;
      Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, '');
      Lib_Texte:Txt2Rtf(vTxtHdl, vRtfHdl);
      $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,0,vRtfHdl);
    end;
    TextClose(vTxtHdl);
    
  end;
  // Focus auf Editfeld setzen:
  $rtf.RtfEditor->Winfocusset(false);
end;


//========================================================================
//  AusTextAdd
//
//========================================================================
sub AusTextAdd();
local begin
  vTxtHdl   : int;
  vRtfHdl   : int;
  vI        : int;
  vA        : alpha(250);
end;
begin

 if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
      
    vTxtHdl   # TextOpen(20);
    if (Txt.RtfYN) then begin
      vTxtHdl->TextRead('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.RTF',0);
      $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,_WinRtfLoadInsert,vTxtHdl);
    end else begin
      vRtfHdl   # TextOpen(20);
      Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, '');
      Lib_Texte:Txt2Rtf(vTxtHdl, vRtfHdl);
      $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,_WinRtfLoadInsert,vRtfHdl);
      TextClose(vRtfHdl);
    end;
    TextClose(vTxtHdl);
  end;
  // Focus auf Editfeld setzen:
  $rtf.RtfEditor->Winfocusset(false);


/**
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    $rtf.RtfEditor->WinUpdate(_WinUpdObj2Buf);
    vRtfHdl # $rtf.RtfEditor->wpdbTextBuf;

    vTxtHdl  # TextOpen(16);
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, '');
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl,_TextLines)) do begin
//      TextLineWrite(vRtfHdl, TextInfo(vRtfHdl,_textLines)+1, TextLineRead(vTxtHdl,vI,0), _TextLineInsert);
      TextLineWrite(vRtfHdl, TextInfo(vRtfHdl,_textLines)+1, TextLineRead(vTxtHdl,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl);
    $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,0,vRtfHdl);
  end;
  // Focus auf Editfeld setzen:
  $rtf.rtfEditor->Winfocusset(false);
  // ggf. Labels refreshen
**/
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

  vTxtHdl # $rtf.RtfEditor->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $rtf.RtfEditor->wpdbTextBuf # vTxtHdl;
  end;

  // Übergebene Daten aufnehmen....
  if (Gv.Alpha.01=Lib_GuiCom:GetAlternativeName('Mdi.RTFEDITOR')) then begin
    $rtf.RtfEditor->wpcustom    # GV.Alpha.02;
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

  // 06.09.2017: "Weiterspringen" nach Button "Edit"
  if ($Edit2->wpvisible) then
    $fc.Main->wpcustom # 'INIT';

  RETURN App_Main:EvtInit(aEvt);
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

  $rtf.RtfEditor->wpreadonly  # (Mode<>c_ModeEdit);

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
  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  // 06.09.2017 AH: Umspringen...
  if ($fc.Main->wpcustom='INIT') then begin
    $fc.Main->wpcustom # '';
    $Edit2->winfocusset(false);
  end;

  RETURN true;  // 20.08.2012
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
      PrintRTF();
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
    'Save2'       : Action(c_ModeSave);
    'Cancel2'     : Action(c_ModeCancel);
    'Edit2'       : Action(c_ModeEdit);
    'bt.Text'     : Auswahl('Text');
    'bt.Text.Add' : Auswahl('Text.Add');
  end;

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

  if ($rtf.RtfEditor->wpreadonly=n) then TextSave();
  vTxtHdl # $rtf.RtfEditor->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);

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

  if (Mode<>c_ModeEdit) and (Mode<>c_ModeNew) then RETURN App_Main:EvtClose(aEvt);

  Action(c_modeCancel);
  RETURN false;

end;

//========================================================================