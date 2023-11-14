@A+
//==== Business-Control ==================================================
//
//  Prozedur    Help_Main
//                    OHNE E_R_G
//  Info
//
//
//  08.02.2013  AI  Erstellung der Prozedur
//  24.11.2021  ST  "show" erlaubt erkennt http URLs
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    sub _ConvertUrlPart(aData : alpha) : alpha
//    sub ShowUrl(aBaseUrl : alpha(1000); aObjName : alpha)
//    sub Show(aObjname : alpha)
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
//    SUB AusLEER()
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
  cDialog     : 'Prh.Help.Verwaltung'
  cTitle      : 'Hilfedateien'
  cRecht      : Rgt_Einst_Help
  cMdiVar     : gMDIPara
  cFile       :  900
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Help'
  cZList      : $ZL.Hilfedateien
  cKey        : 1
  cListen     : ''
end;

declare Show(aObjName : alpha);


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aView   : logic) : logic;
begin
  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
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

    // Auswahlfelder setzen...
  //SetStdAusFeld(''        ,'');

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
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  vHdl  : int;
end;
begin
  //if (aName='') or (aName='edAdr.EK.Zahlungsbed') then begin
  //  Erx # RecLink(816,100,3,0);
  //  if (Erx<=_rLocked) then
  //    $Lb.EK.Zahlungsbed->wpcaption # ZaB.Bezeichnung1.L1
  //  else
  //    $Lb.EK.Zahlungsbed->wpcaption # '';
  //end;

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
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edHelp.Objektname->WinFocusSet(true);
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
  else begin
    erx # RekInsert(gFile,0,'MAN');
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
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    if (RekDelete(gFile,0,'MAN')=_rOK) then begin
      if (gZLList->wpDbSelection<>0) then begin
        SelRecDelete(gZLList->wpDbSelection,gFile);
        RecRead(gFile, gZLList->wpDbSelection, 0);
      end;
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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

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
    //'...' : begin
    //  RecBufClear(xxx);         // ZIELBUFFER LEEREN
    //  gMDI # Lib_GuiCom:AddChildWindow(gMDI, xxx.Verwaltung',here+':Aus...');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    //  Lib_GuiCom:RunChildWindow(gMDI);
    //end;
  end;  // ...case

end;


//========================================================================
//  Aus...
//
//========================================================================
/*
sub AusLEER(opt aPara : alpha)
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(xxx,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edxxx.xxxxx->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;
*/


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

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
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
    'bt.Datei' : begin
      Help.Dateiname # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', '');
      RefreshIfm('edHelp.Dateiname');
    end;

    'Help' : Show(gMDI->wpname);

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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//  sub _ConvertUrlPart(aData : alpha) : alpha
//  Konvertiert den übergebenen String für die lesbare Ausgabe einer URL
//========================================================================
sub _ConvertUrlPart(aData : alpha) : alpha
local begin
  vRet : alpha;
end;
begin
  vRet  # StrCnv(aData,_StrLetter);
  RETURN vRet;
end;

//========================================================================
//  sub ShowUrl(aBaseUrl : alpha(1000); aObjName : alpha)
//  Erstellt einen HilfeLink auf Basis der aktuell geöffneten Gui Struktur
//========================================================================
sub ShowUrl(aBaseUrl : alpha(1000); aObjName : alpha)
local begin
  vUrl          : alpha(1000);
  vHdl          : int;
  vGuiObjPath   : alpha(1000);
  vParentName   : alpha;
  vLastFocsName : alpha;
  vNodeBookName : alpha;
  vSep  :alpha;
end;
begin
  vSep  # '_';
 
  vUrl # aBaseUrl;
  Lib_Strings:Append(var vGuiObjPath,_ConvertUrlPart(aObjName),vSep);
  if (gMdi > 0) then begin
    if (w_Parent > 0) then
      vParentName # _ConvertUrlPart(w_Parent->wpName);

    if (w_LastFocus > 0) then begin
      vLastFocsName # _ConvertUrlPart(w_LastFocus->wpName);
         
      vHdl # w_LastFocus->WinInfo(_WinParent,0,_WinTypeNotebookPage);
      if (vHdl > 0) then
        vNodeBookName # _ConvertUrlPart(vHdl->wpName);
    end;
           
    Lib_Strings:Append(var vGuiObjPath,vParentName,   vSep);
    Lib_Strings:Append(var vGuiObjPath,vNodeBookName, vSep);
    Lib_Strings:Append(var vGuiObjPath,vLastFocsName, vSep);
    
    vGuiObjPath # StrCnv(vGuiObjPath,_StrToUri);
    Lib_Strings:Append(var vUrl,vGuiObjPath ,'?SCGuiObjPath=');
  end;

  SysExecute(vUrl , '', 0);
end



//========================================================================
//  Show
//
//========================================================================
sub Show(aObjname : alpha)
local begin
  Erx   : int;
  vA    : alpha(1000);
  vHdl  : int;
end;
begin

  RecBufClear(900);
  Help.Objektname # StrCnv(aObjname,_Strupper);
  Erx # RecRead(900,1,0);
  if (Erx>_rLocked) then RETURN;
 
  vA # '*'+Help.Dateiname;

  // ST 2021-11-24 2296/17: Hilfeseiten auf httpservern
  if (Str_Contains(Help.Dateiname,'http')) then begin
    ShowUrl(vA,aObjname);
    RETURN;
  end;
    

  if ( gMDIMath = 0 ) then begin
    gMDIMath # Lib_GuiCom:OpenMdi( gFrmMain, 'Mdi.Help', _winAddHidden );
  end;

  VarInstance( WindowBonus, CnvIA( gMDIMath->wpCustom ) );

  vHdl # Winsearch(gMDIMath, 'CtxOffice');
  vHdl->wpfilename # vA;
//  vHdl # Winsearch(gMDIMath, 'RtfEdit1');
//  vHdl->wpfilename # vA;
  Lib_GuiCom:RunChildWindow(gMDIMath)

  gMDIMath->WinUpdate( _winUpdOn )
  gMDIMath->WinFocusSet( true );
//  Lib_guiCom:ReOpenMDI(aMDIVar);

end;


//========================================================================
//========================================================================
sub _HelpExists(aObjname : alpha) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(900);
  Help.Objektname # StrCnv(aObjname,_Strupper);
  Erx # RecRead(900,1,_recTest);
  RETURN (Erx=_rOK);
end;


//========================================================================
//  AddButton
//
//========================================================================
sub AddButton(
  aObjname  : alpha;
  aMDI      : int);
local begin
  vHdl      : int;
  vObj      : int;
  vI        : int;
  vFont     : font;
  vBuf      : int;
end;
begin

  if (_HelpExists(aObjName)=false) then RETURN;

  vHDL # Winsearch(aMDI, 'Std.Windowsbar');
  if (vHdl=0) then RETURN;

  vObj # Winsearch(vHdl, 'Aktivitaeten');
  if (vObj=0) or ((vObj<>0) and (vOBj->wpvisible=false)) then begin
    vObj # Winsearch(vHdl, 'Attachment');
    if (vObj=0) then RETURN;
  end;

  vHdl # Wincreate(_Wintypebutton,'Help','Hilfe',vHdl);
  vHdl->wparea        # vObj->wparea;
  vHdl->wpareabottom  # vHdl->wpareabottom + 50;
  vHdl->wpareatop     # vHdl->wpareatop + 50;
  vHdl->WinEvtProcNameSet(_WinEvtClicked, here+':EvtClicked');
  vHdl->wpImageTileUser # 52;
  vHdl->wpImageOption   # _WinImgTextIgnore;
  vHdl->wpHelpTip       # Translate('Hilfe');

  vHdl->wpcustom        # aObjName;

  vFont # vObj->wpfont;
  vHdl->wpfont # vFont;

end;


//========================================================================
//  AddMenu
//
//========================================================================
sub AddMenu(aMenu : int);
local begin
  vHdl      : int;
end;
begin

  if (aMenu=0) then RETURN;
  if (gMDI=0) then RETURN;
  vHdl # Winsearch(gMDI, 'Help');
  if (vHdl=0) then RETURN;

//  vHdl # Winsearch(aMenu, 'Datensatz');
//  if (vHdl<>0) then begin
    vHdl # aMenu->WinMenuItemAdd('Mnu.Help',Translate('Hilfe'));
    vHdl->wpMenuKey # _WinKeyF1;
//  end;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================
