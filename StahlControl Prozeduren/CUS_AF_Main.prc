@A+
//==== Business-Control ==================================================
//
//  Prozedur    CUS_AF_Main
//                    OHNE E_R_G
//
//  27.01.2021  AH  >>>>>>>>>>>>>>>>>> GEHT NACH CUS2_AF_Main
//
//  Info
//
//
//  03.06.2009  MS  Erstellung der Prozedur
//  12.04.2016  AH  "PopUp" mit optionalem Fontgröße (für VBS)
//  13.10.2017  AH  Es können auch Integer-Felder benutzt werden
//  25.01.2018  ST  Bei Auswahl ohne Feldangabe wird nur Caption geändert
//  22.12.2020  ST  "TagAuswahl" per "+" Markierung für Alpha Datenbankfelder
//                  hingezugefügt
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit() : logic;
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
//    SUB Popup(aBereich : alpha; aObj : int; aFile : int; aTds : int; aPos : int) : alpha;
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Customauswahlfelder'
  cFile       : 932
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'CUS_AF'
  cZList      : $ZL.CUS.AF
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
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  App_Main:EvtInit(aEvt);
  Mode # c_modeEdList;
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
end;
begin

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
sub RecInit() : logic;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
//  $...->WinFocusSet(true);
  RETURN true;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
/***
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    end
  else begin
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;
***/

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
    //  gMDI # Lib_GuiCom:AddChildWindow(gMDI, xxx.Verwaltung','xxx_Main:Aus...');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    //  Lib_GuiCom:RunChildWindow(gMDI);
    //end;
  end;

end;


//========================================================================
//  Aus...
//
//========================================================================
/*
sub AusLEER()
begin
  if (gSelected<>0) then begin
    RecRead(xxx,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
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
  d_MenuItem : int;
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
/**
  vHdl # gMDI->WinSearch('Save');
  if (vHdl <> 0) then
    vHdl->wpDisabled # mode<>c_ModeEdListEdit;
  vHdl # gMenu->WinSearch('Mnu.Save');
  if (vHdl <> 0) then
    vHdl->wpDisabled # mode<>c_ModeEdListEdit;
**/
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
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
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


/*
//========================================================================
//  PopUp
//        Popup eine Auswahlliste auf und übernimmt ggf. den Inhalt
// MUSTER:  CUS_AF_Main:Popup('Grund',$edAdr.Sachbearbeiter,100,1,8);
//========================================================================
sub Popup(
  aBereich : alpha;
  aObj     : int;
  opt aFile    : int;
  opt aTds     : int;
  opt aPos     : int;
  opt aGegenpruefen : alpha;
  opt aFontSize : int;
  ) : alpha;
local begin
  vA        : alpha(250);
  vB        : alpha;
  vHdl      : int;
  vHdl2     : int;
  vI        : int;
  vX,vY     : int;
  vXX       : int;
  vTmp      : int;
  vFldName  : alpha;
  vFont     : font;
end;
begin
  if (aObj<>0) then begin
    vX # aObj->wpAreaLeft;
    vY # aObj->wpAreatop;
    vXX # aObj->wpArearight - vX + 20;
    end
  else begin
    vX # 500;
    vY # 200;
    vXX # 200;
  end;
/*
  if (gMDI<>0) then begin
    vX # vX + gMDI->wpAreaLeft;
    vY # vY + gMDI->wpAreaTop;
  end;
  if (gFrmMain<>0) then begin
    vX # vX + gFrmMain->wpAreaLeft;
    vY # vY + gFrmMain->wpAreaTop;
  end;
*/

  gSelected # 0;

  vHdl # Lib_Einheiten:_OpenPopUp(aObj, Translate('Bitte'), 150, n, var vHdl2);
  if (aFontSize<>0) then begin
    vFont # vHdl2->wpFont;
    vFont:Size # aFontSize*10;
    vHdl2->wpFont # vFont;
  end;


  RecBufClear(932);
  CUS.AWF.Bereich # aBereich;
  Erx # RecRead(932,2,0);
  WHILE (Erx<_rLastRec) and (StrCnv(CUS.AWF.Bereich,_StrUpper)=aBereich) do begin
    if (aGegenpruefen = '') or ("CUS.AWF.GegenPrüfen" = '') or
       ((aGegenpruefen <> '') and (StrFind(aGegenpruefen, "CUS.AWF.GegenPrüfen", 1, _StrCaseIgnore) > 0)) then begin
      vHdl2->WinLstDatLineAdd(CUS.AWF.Begriff);
      vHdl2->wpcurrentint # 1;
    end;
    Erx # RecRead(932,2,_recNext);
  END;
  vHdl->windialogrun(0,gMdi);

  // ÜBERNAHME...
  if (gSelected<>0) then begin
    vHdl2->WinLstCellGet(vA,1,gSelected);
    if (aFile=0) then begin
      vFldName # aObj->wpDbFieldName;
      if (vFldName<>'') then begin
        vI # FldInfobyName(vFldName,_fldType);
        if (vI=_TypeAlpha) then begin
          vI # FldInfobyName(vFldName,_fldLen);
          FldDefByName(vFldName,StrCut(vA,1,vI));
          aObj->wpcaption # vA;
        end
        else if (vI=_TypeInt) or (vI=_TypeWord) then begin
          FldDefByName(vFldName,cnvia(vA));
          aObj->wpcaptionInt # cnvia(vA);
        end;
      end else begin
        // ST 2018-01-25
        /// Kein Feld eingetragen -> Dann als Alpha für Customfeld
        aObj->wpcaption # vA;
      end;
    end
    else begin
      vI # FldInfo(aFile,aTds,aPos,_fldType);
      if (vI=_TypeAlpha) then begin
        vI # FldInfo(aFile,aTds,aPos,_fldLen);
        flddef(aFile,aTds,aPos,StrCut(vA,1,vI));
        aObj->wpcaption # vA;
      end
      else if (vI=_TypeInt) or (vI=_TypeWord) then begin
        flddef(aFile,aTds,aPos, cnvia(vA));
        aObj->wpcaptionInt # cnvia(vA);
      end;
    end;
  end;

  vHdl->WinClose();

  gSelected # 0;
  aObj->WinUpdate(_WinUpdFld2Obj);
  aObj->winFocusSet(true);

  RETURN vA;
end;
*/
//========================================================================
//  PopUp
//        Popup eine Auswahlliste auf und übernimmt ggf. den Inhalt
// MUSTER:  CUS_AF_Main:Popup('Grund',$edAdr.Sachbearbeiter,100,1,8);
//========================================================================
sub Popup(
  aBereich : alpha;
  aObj     : int;
  opt aFile    : int;
  opt aTds     : int;
  opt aPos     : int;
  opt aGegenpruefen : alpha;
  opt aFontSize : int;
  ) : alpha;
local begin
  Erx       : int;
  vA        : alpha(250);
  vB        : alpha;
  vHdl      : int;
  vHdl2     : int;
  vI        : int;
  vX,vY     : int;
  vXX       : int;
  vTmp      : int;
  vFldName  : alpha;
  vFont     : font;
  
  vContentOld : alpha(250)
  
end;
begin

  // 27.01.2021 AH
  RETURN CUS2_AF_Main:POPUP(aBereich, aObj, aFile, aTds, aPos, aGegenpruefen, aFontSize);
 
  
  if (aObj<>0) then begin
    vX # aObj->wpAreaLeft;
    vY # aObj->wpAreatop;
    vXX # aObj->wpArearight - vX + 20;
    end
  else begin
    vX # 500;
    vY # 200;
    vXX # 200;
  end;
/*
  if (gMDI<>0) then begin
    vX # vX + gMDI->wpAreaLeft;
    vY # vY + gMDI->wpAreaTop;
  end;
  if (gFrmMain<>0) then begin
    vX # vX + gFrmMain->wpAreaLeft;
    vY # vY + gFrmMain->wpAreaTop;
  end;
*/

  gSelected # 0;

  vHdl # Lib_Einheiten:_OpenPopUp(aObj, Translate('Bitte'), 150, n, var vHdl2);
  if (aFontSize<>0) then begin
    vFont # vHdl2->wpFont;
    vFont:Size # aFontSize*10;
    vHdl2->wpFont # vFont;
  end;


  RecBufClear(932);
  CUS.AWF.Bereich # aBereich;
  Erx # RecRead(932,2,0);
   
  WHILE (Erx<_rLastRec) and (StrCnv(CUS.AWF.Bereich,_StrUpper)=aBereich) do begin
    if (aGegenpruefen = '') or ("CUS.AWF.GegenPrüfen" = '') or
       ((aGegenpruefen <> '') and (StrFind(aGegenpruefen, "CUS.AWF.GegenPrüfen", 1, _StrCaseIgnore) > 0)) then begin
      
      // ST 2020-12-22: Sollte das Customfeld ein "Tag" Feld sein, dann schon vorhandene Tags nicht anzeigen
      if (StrCut(CUS.AWF.Bereich,1,1) = '+') then begin
        vA # FldAlphaByName(aObj->wpDbFieldName);
        if (StrFind(vA,CUS.AWF.Begriff,1,_StrCaseIgnore | _StrFindToken) = 0) then begin
          vHdl2->WinLstDatLineAdd(CUS.AWF.Begriff);
          vHdl2->WinLstCellSet('+',2,_WinLstDatLineLast);
        end;
      end else begin
        // Normale Zeile
        vHdl2->WinLstDatLineAdd(CUS.AWF.Begriff);
      end
      
      vHdl2->wpcurrentint # 1;
           
    end;
    Erx # RecRead(932,2,_recNext);
  END;
  vHdl->windialogrun(0,gMdi);

  // ÜBERNAHME...
  if (gSelected<>0) then begin
    vHdl2->WinLstCellGet(vA,1,gSelected);
    vHdl2->WinLstCellGet(vB,2,gSelected);
    if (aFile=0) then begin
      vFldName # aObj->wpDbFieldName;
      if (vFldName<>'') then begin
        vI # FldInfobyName(vFldName,_fldType);
        if (vI=_TypeAlpha) then begin
          vI # FldInfobyName(vFldName,_fldLen);
                    
          if (vB = '+') then begin
            // ST 2020-12-22: Zusätzliches Tag übernehmen
            vContentOld # FldAlphaByName(aObj->wpDbFieldName);
            FldDefByName(vFldName,StrCut(StrAdj(vContentOld + ' ' + vA,_StrBegin|_StrEnd),1,vI));
            aObj->wpcaption # aObj->wpcaption + ' ' + vA;
          end else begin
            FldDefByName(vFldName,StrCut(vA,1,vI));
            aObj->wpcaption # vA;
          end;
            
        end
        else if (vI=_TypeInt) or (vI=_TypeWord) then begin
          FldDefByName(vFldName,cnvia(vA));
          aObj->wpcaptionInt # cnvia(vA);
        end;
      end else begin
        // ST 2018-01-25
        /// Kein Feld eingetragen -> Dann als Alpha für Customfeld
        aObj->wpcaption # vA;
      end;
    end
    else begin
      vI # FldInfo(aFile,aTds,aPos,_fldType);
      if (vI=_TypeAlpha) then begin
        vI # FldInfo(aFile,aTds,aPos,_fldLen);
        flddef(aFile,aTds,aPos,StrCut(vA,1,vI));
        aObj->wpcaption # vA;
      end
      else if (vI=_TypeInt) or (vI=_TypeWord) then begin
        flddef(aFile,aTds,aPos, cnvia(vA));
        aObj->wpcaptionInt # cnvia(vA);
      end;
    end;
  end;

  vHdl->WinClose();

  gSelected # 0;
  aObj->WinUpdate(_WinUpdFld2Obj);
  aObj->winFocusSet(true);

  RETURN vA;
end;

//========================================================================
//========================================================================
//========================================================================
