@A+
//==== Business-Control ==================================================
//
//  Prozedur    MSt_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  05.10.2021  AH  "Fix04102021"
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
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
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Fix04102021()
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Materialstatus'
  cFile :     820
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'MSt'
  cZList :    $ZL.Materialstatus
  cListen   : 'Materialstatus'
  cKey :      1
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
  w_Listen  # cListen
  gKey      # cKey;

  SetStdAusFeld('edxxxxxx'        ,'xxxxxx');

  if (Set.Art.Sum1.Name<>'') then begin
    $cbArtSum1->wpVisible # true;
    $cbArtSum1->wpCaption # Set.Art.Sum1.Name;
  end;
  if (Set.Art.Sum2.Name<>'') then begin
    $cbArtSum2->wpVisible # true;
    $cbArtSum2->wpCaption # Set.Art.Sum2.Name;
  end;
  if (Set.Art.Sum3.Name<>'') then begin
    $cbArtSum3->wpVisible # true;
    $cbArtSum3->wpCaption # Set.Art.Sum3.Name;
  end;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

  if (Mode=c_modeView) then begin
    Lib_Guicom2:SetCheckBox($cbArtSumBestand, Mat.Sta.ArtSumFormel=*'*IST0*');
    Lib_Guicom2:SetCheckBox($cbArtSumBestellt, Mat.Sta.ArtSumFormel=*'*BEST*');
//    Lib_Guicom2:SetCheckBox($cbArtSumKommi, Mat.Sta.ArtSumFormel=*'*KOMM*');
    Lib_Guicom2:SetCheckBox($cbArtSumVerf, Mat.Sta.ArtSumFormel=*'*VERF*');
    Lib_Guicom2:SetCheckBox($cbArtSumRes, Mat.Sta.ArtSumFormel=*'*RES*');
    Lib_Guicom2:SetCheckBox($cbArtSum1, Mat.Sta.ArtSumFormel=*'*SUM1*');
    Lib_Guicom2:SetCheckBox($cbArtSum2, Mat.Sta.ArtSumFormel=*'*SUM2*');
    Lib_Guicom2:SetCheckBox($cbArtSum3, Mat.Sta.ArtSumFormel=*'*SUM3*');

    if (Mat.Sta.Color=_Wincolblack) then Mat.Sta.Color # _WinColParent;
    $coMat.Sta.Color->wpCaptionColor   # Mat.Sta.Color;
  end;
  
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then Mat.Sta.ArtSumFormel # 'IST0;VERF;';
  // Focus setzen auf Feld:
  $edMSt.Nummer->WinFocusSet(true);

  if (Mat.Sta.Color=_Wincolblack) then Mat.Sta.Color # _WinColParent;

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
  Mat.Sta.ARtSumFormel # '';
  if ($cbArtSumBestand->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'IST0;';
  if ($cbArtSumBestellt->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'BEST;';
  if ($cbArtSumRes->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'RES;';
//  if ($cbArtSumKommi->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'KOMM;';
  if ($cbArtSumVerf->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'VERF;';
  if ($cbArtSum1->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'SUM1;';
  if ($cbArtSum2->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'SUM2;';
  if ($cbArtSum3->wpCheckState=_WinStateChkChecked) then Mat.Sta.ArtSumFormel # Mat.Sta.ArtSumFormel + 'SUM3;';

  if (Mat.Sta.Color=_Wincolblack) then Mat.Sta.Color # _WinColParent;

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
  if (Mat.Sta.Color=_Wincolblack) then Mat.Sta.Color # _WinColParent;
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
begin
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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
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

  if Mode=c_ModeView then RETURN true;

  case (aEvt:Obj->wpName) of

    'coMat.Sta.Color' : begin
      Mat.Sta.Color # $coMat.Sta.Color->wpCaptionColor;
      gMDI->winupdate(_WinUpdFld2Obj);
    end;

  end;

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
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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
  RETURn true;
end;


//========================================================================
//  call Mst_Main:Fix04102021
//========================================================================
sub Fix04102021()
local begin
  Erx : int;
end;
begin
  FOR Erx # RecRead(820,1,_recFirst)
  LOOP Erx # RecRead(820,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(820,1,_RecLock);
    if (Mat.Sta.Nummer=c_Status_BAGZumFahren) or (Mat.Sta.Nummer=c_Status_BAGBereitgestellt) then
      Mat.Sta.ArtSumFormel # 'IST0;VERF;'
    else if ((Mat.Sta.Nummer>=c_Status_BAGInput) and (Mat.Sta.Nummer<c_Status_BAGOutput) and (Mat.Sta.Nummer<>c_Status_BAGZumFahren)) then
      Mat.Sta.ArtSumFormel # 'IST0;VERF;RES;'
    else if ((Mat.Sta.Nummer>=400) and (Mat.Sta.Nummer<=404)) then  // kommissioniert!
      Mat.Sta.ArtSumFormel # 'IST0;VERF'
    else if (Mat.Sta.Nummer=500) or (Mat.Sta.Nummer=597) then       // Bestellt
      Mat.Sta.ArtSumFormel # 'BEST;'
    else
      Mat.Sta.ArtSumFormel # 'IST0;VERF;';
    RekReplace(820);
  END;
  Msg(999998,'',0,0,0);
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================