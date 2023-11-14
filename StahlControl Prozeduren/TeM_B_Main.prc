@A+
//==== Business-Control ==================================================
//
//  Prozedur    TeM_B_Main
//                    OHNE E_R_G
//  Info
//
//
//  22.06.2005  AI  Erstellung der Prozedur
//  26.01.2015  AH  Für "neue" Verankerung umgebaut
//  28.05.2020  AH  Textauswahl per F9
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
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

define begin
  cTitle :    'Berichte'
  cFile :     982
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'TeM_B'
  cZList :    $ZL.TeM.Berichte
  cKey :      1
  cListen : '';
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
  w_Listen # cListen;
  // Auswahlfelder setzen...
  //SetStdAusFeld('', '');

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
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(  opt aName : alpha)
local begin
  vTxtHdl : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then
    Lib_guicom:Enable($RTFEdit1)
  else
    Lib_guicom:Disable($RTFEdit1);

  vTxtHdl # $RTFEdit1->wpdbtextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $RTFEdit1->wpdbTextBuf # vTxtHdl;
  end;
  if (aName='') then begin
    if (Mode=c_ModeView) then begin
      if (TextRead(vTxtHdl,'~982.'+CnvAI(TeM.B.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(TeM.B.Berichtsnr,_FmtNumLeadZero | _FmtNumNoGroup,0,3), _TextUnlock)>_rLocked) then
        TextClear(vTxtHdl);
      $RTFEdit1->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
    end;
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
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // Focus setzen auf Feld:
  Lib_guicom:Enable($RTFEdit1);
  $RtfEdit1->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vTxtHdl : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
/*
    "xxx.Änderung.Datum"  # Today;
    "xxx.Änderung.Zeit"   # Now;
    "xxx.Änderung.User"   # gUserName;
*/
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);

    vTxtHdl # $RTFEdit1->wpdbTextBuf;
    $RTFEdit1->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);
    // Text speichern
    TxtWrite(vTxtHdl,'~982.'+CnvAI(TeM.B.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(TeM.B.Berichtsnr,_FmtNumLeadZero | _FmtNumNoGroup,0,3), _TextUnlock);

  end
  else begin

    TeM.B.Anlage.Datum  # Today;
    TeM.B.Anlage.Zeit   # Now;
    TeM.B.Anlage.User   # gUserName;

    TeM.B.Nummer # TeM.Nummer;
    TeM.B.Berichtsnr # 0;
    REPEAT
      inc(TeM.B.Berichtsnr);
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (erx=_rOK);

    vTxtHdl # $RTFEdit1->wpdbTextBuf;
    $RTFEdit1->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);
    // Text speichern
    TxtWrite(vTxtHdl,'~982.'+CnvAI(TeM.B.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(TeM.B.Berichtsnr,_FmtNumLeadZero | _FmtNumNoGroup,0,3), _TextUnlock);

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
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
    TxtDelete('~982.'+CnvAI(TeM.B.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(TeM.B.Berichtsnr,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
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

 if (aevt:obj -> wpname ='RtfEdit1') then begin
   $TeM.B.ToolbarRTF -> wpdisabled # false;
   $TeM.B.ToolbarTXT -> wpdisabled # false;
 end
 else if ($TeM.B.ToolbarRTF->wpdisabled=false) then begin
   $TeM.B.ToolbarRTF -> winupdate(_Winupdon);
   $TeM.B.ToolbarRTF -> wpdisabled # true;
   $TeM.B.ToolbarTXT -> wpdisabled # true;
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
  aBereich : alpha;)
local begin
  vQ  : alpha;
end;
begin

  if (aBereich='Text') then begin
    RecBufClear(837);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vQ # '';
    Lib_Sel:QLogic(var vQ, 'Txt.RtfYN', true);
    Lib_Sel:QRecList(0, vQ);
    Lib_GuiCom:RunChildWindow(gMDI);
  end;
  
end;


//========================================================================
//  AusText
//
//========================================================================
sub AusText();
local begin
  Erx     : int;
  vTxtHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $RTFEdit1->wpdbtextBuf;
    Erx # TextRead(vTxtHdl, '~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.RTF' ,0);
    if (Erx>_rLocked) then
      TextClear(vTxtHdl);
   $RTFEdit1->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
  end;
  // Focus auf Editfeld setzen:
  $RTFEdit1->Winfocusset(false);
  // ggf. Labels refreshen
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

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_TeM_B_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_TeM_B_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_TeM_B_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_TeM_B_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_TeM_B_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_TeM_B_Loeschen]=n);

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

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
    end;


    'Mnu.Druck.Bericht' : begin
      Lib_Dokumente:Printform(982,'Bericht',true);
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
    'bt.Text' :   Auswahl('Text');
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
local begin
  Erx   : int;
  vText : alpha;
end;
begin
    vText # '';
    Erx # RecLink(981,980,1,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      if (vText<>'') then vText # vText + ', ';

      // 26.01.2015:
      if (TeM.A.ID1=0) and (TeM.A.Key<>'') then begin
        TeM.A.ID1 # cnvia(Str_Token(TeM.A.Key, StrChar(255),1));
        TeM.A.ID2 # cnvia(Str_Token(TeM.A.Key, Strchar(255),2));
      end;

      case (TeM.A.Datei) of
        100 : begin
          Adr.Nummer # TeM.A.ID1;
          RecRead(100,1,0);
          vText # vText + Adr.Stichwort;
        end;

        102 : begin
          Adr.P.Adressnr  # TeM.A.ID1;
          Adr.P.Nummer    # TeM.A.ID2;
          RecRead(102,1,0);
          vText # vText + Adr.P.Stichwort;
        end;

        120 : begin
          Prj.Nummer # TeM.A.ID1;
          RecRead(120,1,0);
          vText # vText + Prj.Stichwort;
        end;

        otherwise begin
          vText # vText + TeM.A.Code;
        end;
      end;

      Erx # RecLink(981,980,1,_RecNext);
    END;

  GV.ALpha.01 # vText;
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
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(aEvt                  : event;        // Ereignis
): logic
local begin
  vTxtHdl : int;
end;
begin
  vTxtHdl # $RTFEdit1->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================