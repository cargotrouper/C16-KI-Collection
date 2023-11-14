@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Kal_Main
//                      OHNE E_R_G
//  Info        Ressourcengruppen Kalender
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  28.06.2013  AH  Neu: Mnu.CopyX
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
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
//    SUB AusKalTage()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Pflichtfelder();
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Ressourcen Kalender'
  cFile :     163
  cMenuName : 'Rso.Kal.Bearbeiten'
  cPrefix :   'Rso_Kal'
  cZList :    $ZL.Rso.Kal
  cKey :      1
end;

declare Pflichtfelder

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

Lib_Guicom2:Underline($edRso.Kal.Tagtyp);

    // Auswahlfelder setzen...
  SetStdAusFeld('edRso.Kal.Tagtyp' ,'Rso.Kal.Tagtyp');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
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
  $edRso.Kal.Datum->WinFocusSet(true);
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

  // Plausibilitätsprüfungen
  If ( cnvAD(Rso.Kal.Datum)='') then begin
    Msg(001200,Translate('Datum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edRso.Kal.Datum->WinFocusSet(true);
    RETURN false;
  end;

  If (Rso.Kal.Tagtyp='') then begin
    Msg(001200,Translate('Typ'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edRso.Kal.Tagtyp->WinFocusSet(true);
    RETURN false;
  end;

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
     Rso.Kal.Gruppe  # Rso.Gruppe;
     Rso.Kal.Datum   # $edRso.Kal.Datum -> wpcaptiondate;
     Erx # RekInsert(gFile,0,'MAN');
     if (erx = _rok) Then begin
         cZlist -> winupdate(_winupdon,_winlstfromlast | _winlstrecdoselect);
     end
     else begin
      Msg(001000+Erx,gTitle,0,0,0);
     return(false);
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
local begin
  vA    : alpha;
end;

begin

  case aBereich of
     'Rso.Kal.Tagtyp' : begin
       RecBufClear(164);         // ZIELBUFFER LEEREN
       gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.KalTage.Verwaltung',here+':AusKalTage');
       Lib_GuiCom:RunChildWindow(gMDI);
       gMdi->WinUpdate(_WinUpdOn);
     end;
  end;

end;


//========================================================================
//  AusKalTage
//
//========================================================================
sub AusKalTage()
begin
  if (gSelected<>0) then begin
    RecRead(164,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Kal.Tagtyp  # Rso.Kal.Tag.Typ
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edRso.Kal.Tagtyp->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Loeschen]=n);


  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or (Rechte[Rgt_Rso_KalTag_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.CopyX');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or (Rechte[Rgt_Rso_KalTag_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


  if (Mode<>c_ModeOther) then RefreshIfm();

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
  Erx     : int;
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vDatMax : date;
  vTmp    : int;
  vCount  : int;
  vRep    : int;
  vDat    : date;
  v163    : int;
  v163B   : int;
  vI,vJ   : int;
  vIntervall  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.CopyX' : begin
      if (Dlg_Standard:Anzahl(Translate('Anzahl der Einträge'), var vCount)=false) then RETURN true;
      if (vCount<=0) then RETURN true;

      if (Dlg_Standard:Anzahl(Translate('Wiederholungen'),var vRep)=false) then RETURN true;
      if (vRep<=0) then RETURN true;

      if (Dlg_Standard:Anzahl(Translate('Intervall'),var vIntervall, 7)=false) then RETURN true;
      if (vIntervall<=1) then RETURN true;

      v163 # RekSave(163);

      vDat # Rso.Kal.Datum;
      Erx # RecRead(163,1,0);

      FOR vI # 1;
      LOOP begin inc(vI); Erx # RecRead(163,1,_recnext); end;
      WHILE ((vI<=vCount) and (Erx<=_rLocked)) do begin

        v163b # RekSave(163);
        FOR vJ # 1 loop inc(vJ) while (vJ<=vRep) do begin
          Rso.Kal.Datum->vmdaymodify(vIntervall);
          RekDelete(163,0,'AUTO');
          RekInsert(163,0,'AUTO');
        END;
        RecBufCopy(v163b,163);
        RecRead(163,1,0);
      END;

      RecBufDestroy(v163b);

      RekRestore(v163);
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
    end;


    'Mnu.Copy' : begin
      Erx # RecRead(gFile,1,0);
      if (Erx>_rLocked) then begin
        RecBufClear(gFile);
        RETURN false;
      end;
      if (Dlg_Standard:Datum(Translate('bis Datum'),var vDatMax)=false) then RETURN true;
      if (vDatMax=0.0.0) then RETURN true;

      v163 # RekSave(163);

      Rso.Kal.Datum->vmdaymodify(7);
      WHILE (Rso.Kal.Datum<=vDatMax) do begin
        RekDelete(163,0,'AUTO');
        RekInsert(163,0,'AUTO');
        Rso.Kal.Datum->vmdaymodify(7);
      END;

      RekRestore(v163);
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

  end; // case


end;
//=======================================================================
// EvtKeyItem ()
//
//
//=======================================================================
sub EvtKeyItem (
  aEvt        : event;
  aKey        : int;
  aRecID      : int;
) : logic;
local begin
   ierr : int;
end

Begin
   case (aevt:obj -> wpname) of
   'ZL.Rso.Kal' :
   Begin
         if (aKey = _winkeyinsert) then
         begin
            recbufclear(163);
            Rso.Kal.Gruppe  # Rso.Gruppe;
            Rso.Kal.Datum   # sysdate();
            ierr # rekinsert(163,0,'MAN');
            if (ierr = _rok) Then begin
               aevt:obj -> winupdate(_winupdon,_winlstfromlast | _winlstrecdoselect);
            end
            else begin
              Msg(001000+Ierr,gTitle,0,0,0);
            end;

         end;

   end
  end; // case
   return(true);
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
    'bt.Rso.Kal.Tagtyp' :   Auswahl('Rso.Kal.Tagtyp');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;
  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edRso.Kal.Datum);
  Lib_GuiCom:Pflichtfeld($edRso.Kal.Tagtyp);

end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRso.Kal.Tagtyp') AND (aBuf->Rso.Kal.Tagtyp<>'')) then begin
    RekLink(164,163,1,0);   // Kalender Typ holen
    Lib_Guicom2:JumpToWindow('Rso.KalTage.Verwaltung');
    RETURN;
  end;

end;
//========================================================================
//========================================================================
//========================================================================