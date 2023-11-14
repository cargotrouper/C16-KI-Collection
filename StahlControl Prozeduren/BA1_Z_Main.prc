@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Z_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.05.2009  TM  Erstellung der Prozedur
//  24.06.2009  ST  Zeitenberechnung anhand der Dauer
//  08.07.2009  TM  Weiterbearbeitung Zeitenberechnung, neue SUB FldChanged
//  22.11.2017  ST  Neuberrechnung der Dauer, auch wenn Dauer gefüllt ist P1725/35
//  08.05.2018  AH  Edit: Ändern von der Dauer verändert ggf. Start/Ende
//  01.10.2020  AH  "Rgt_BAG_Z_Kosten"
//  05.04.2022  AH  ERX
//  21.07.2ß22  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB FldChanged(aEvt : event): logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusZeitenTyp()
//    SUB AusFehlerTyp()
//    SUB AusResGruppe()
//    SUB AusRessource()
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
@I:Def_BAG

define begin
  cTitle      : 'Zeiten'
  cFile       : 709
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'BA1_Z'
  cZList      : $ZL.BAG.Z
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
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # 'BA1_Z';

  // Feldberechtigungen...
  if (Rechte[ Rgt_BAG_Z_Kosten]=false) then begin
    $lbBAG.Z.GesamtkostenW1->wpvisible  # false;
    $edBAG.Z.GesamtkostenW1->wpvisible  # false;
    $Lb.HW->wpvisible                   # false;
  end;

Lib_Guicom2:Underline($edBAG.Z.ZeitenTyp);
Lib_Guicom2:Underline($edBAG.Z.FehlerTyp);
Lib_Guicom2:Underline($edBAG.Z.Ressource);

  SetStdAusFeld('edBAG.Z.ZeitenTyp'  ,'ZeitenTyp');
  SetStdAusFeld('edBAG.Z.FehlerTyp'  ,'FehlerTyp');
  SetStdAusFeld('edBAG.Z.ResGruppe'  ,'ResGruppe');
  SetStdAusFeld('edBAG.Z.Ressource'  ,'Ressource');

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

  // !!! noch bestimmen !!!
  // Pflichtfelder
  // Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  TimeCalc
//          Zeitenberechnung
//========================================================================
sub TimeCalc () : logic
local begin
  vStd        : float;
  vZeitpunkt  : float;   // für Berechnung der Start/End-Zeiten
  vCT         : caltime;
end;
begin
  BA1_Z_Data:TimeCalc();

  // Datum zurückschreiben
  $edBAG.Z.StartDatum->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.StartZeit->WinUpdate(_WinUpdFld2Obj);

  $edBAG.Z.EndDatum->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.EndZeit->WinUpdate(_WinUpdFld2Obj);

  $edBAG.Z.GesamtkostenW1->WinUpdate(_WinUpdFld2Obj);

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
  Erx   : int;
end;
begin
  // veränderte Felder in Objekte schreiben

  If BAG.Z.Fertigmeldung <>0 then begin
    $lbIDNummer->wpcaption # AInt(BAG.Z.Nummer)+'/'+AInt(BAG.Z.Position)+'/'+AInt(BAG.Z.Fertigung)+'/'+AInt(BAG.Z.Fertigmeldung)+ '/'+AInt(BAG.Z.LfdNr);
  End
  else if BAG.Z.Fertigung <>0 then begin
    $lbIDNummer->wpcaption # AInt(BAG.Z.Nummer)+'/'+AInt(BAG.Z.Position)+'/'+AInt(BAG.Z.Fertigung)+'/'+ AInt(BAG.Z.LfdNr);
  End
  else begin
    $lbIDNummer->wpcaption # AInt(BAG.Z.Nummer)+'/'+AInt(BAG.Z.Position)+'/'+AInt(BAG.Z.LfdNr);
  End;

  Erx # RecLink(855,709,6,0);
  If Erx <= _rLocked then
    $lbZeitenTypBez->wpcaption # ZTy.Bezeichnung
  else
    $lbZeitenTypBez->wpcaption # '';

  Erx # RecLink(851,709,7,0);
  If Erx <= _rLocked then
    $lbFehlerTypBez->wpcaption # FhC.Bezeichnung
  else
    $lbFehlerTypBez->wpcaption # '';


  Erx # RecLink(160,709,5,0);

  If Erx <= _rLocked then begin
    $lbRessourceBez->wpcaption    # Rso.Stichwort
    Erx # RecLink(822,160,3,0);

    If Erx <= _rLocked then begin
      $lbResGruppeBez->wpcaption  # Rso.Grp.Bezeichnung;
    end
    else begin
      $lbResGruppeBez->wpcaption  # '';
    end;
  end
  else begin
    $lbRessourceBez->wpcaption    # '';
    $lbResGruppeBez->wpcaption  # '';
  end;


  // automatische Füllung der Dauer
  If "BAG.Z.Dauer" = 0.0 then begin
    if (Mode=c_ModeNew) then begin
      Erx # RecLink(100,401,4,_Recfirst);   // Kunde holen...
    End;
  End;

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
sub RecInit(opt aBehalten : logic);
local begin
  Erx : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);


  // Focus setzen auf Feld:
  $edBAG.Z.Startdatum->WinFocusSet(true);

  if (Mode=c_ModeNew) then begin

    Erx # RecLink(709,702,6,_RecLast);    // lette Zeit der Pos. holen

    If (Erx <= _rLocked) then BAG.Z.LfdNr # BAG.Z.LfdNr +1;
    else BAG.Z.lfdNr         # 1;

    BAG.Z.Nummer        # BAG.P.Nummer;
    BAG.Z.Position      # BAG.P.Position;
    BAG.Z.ResGruppe     # BAG.P.Ressource.Grp;
    BAG.Z.Ressource     # BAG.P.Ressource;
    BAG.Z.Fertigung     # 0;
    BAG.Z.Fertigmeldung # 0;

    if(aBehalten = false) then begin
      BAG.Z.Startdatum    # Today;
      BAG.Z.Startzeit     # now;
    end
    else begin
      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);
      BAG.Z.Startdatum    # BAG.Z.EndDatum;
      BAG.Z.Startzeit     # BAG.Z.EndZeit;
    end;

    BAG.Z.Zeitentyp     # 0;
    BAG.Z.Fehlertyp     # 0;
    BAG.Z.EndDatum      # 0.0.0;
    BAG.Z.EndZeit       # 00:00:00;
    BAG.Z.Dauer         # 0.0;
    BAG.Z.Faktor        # 1.0;

    BAG.Z.Bemerkung     # '';

    If BAG.Z.Fertigmeldung <>0 then begin
      $lbIDNummer->wpcaption # AInt(BAG.Z.Nummer)+'/'+AInt(BAG.Z.Position)+'/'+AInt(BAG.Z.Fertigung)+'/'+AInt(BAG.Z.Fertigmeldung)+ '/'+AInt(BAG.Z.LfdNr);
    End
    else if BAG.Z.Fertigung <>0 then begin
      $lbIDNummer->wpcaption # AInt(BAG.Z.Nummer)+'/'+AInt(BAG.Z.Position)+'/'+AInt(BAG.Z.Fertigung)+'/'+ AInt(BAG.Z.LfdNr);
    End
    else begin
      $lbIDNummer->wpcaption # AInt(BAG.Z.Nummer)+'/'+AInt(BAG.Z.Position)+'/'+AInt(BAG.Z.LfdNr);
    End;

    $edBAG.Z.StartDatum->WinUpdate(_WinUpdFld2Obj);
    $edBAG.Z.StartZeit->WinUpdate(_WinUpdFld2Obj);
    $edBAG.Z.EndDatum->WinUpdate(_WinUpdFld2Obj);
    $edBAG.Z.EndZeit->WinUpdate(_WinUpdFld2Obj);

    gMdi -> WinUpdate(); // Fenster refreshen
  end;

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

    Timecalc();

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    PtD_Main:Compare(gFile);

  end
  else begin
    Timecalc();
    BAG.Z.Anlage.Datum  # Today;
    BAG.Z.Anlage.Zeit   # Now;
    BAG.Z.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  // Weitermachen mit eingeben?
  if (Mode=c_ModeNew) then begin
    if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
      RecInit(y);
      RETURN false;
    end
    else begin
      RETURN true;
    end;
  end; // Weitermachen mit eingeben?

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  if (Mode=c_ModeEdit) then begin
  end
  else
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

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

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

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
local begin
  vStd        : float;
  vZeitpunkt  : float;   // für Berechnung der Start/End-Zeiten
  vCT         : caltime;
end;
begin

  If ((aEvt:Obj->wpname = 'edBAG.Z.Startzeit') or (aEvt:Obj->wpname = 'edBAG.Z.Endzeit')) then begin

    If ((aEvt:Obj->wpname = 'edBAG.Z.Startzeit') and (aEvt:Obj->wpcaptiontime > 23:59:59.00)) then begin
      BAG.Z.StartZeit # 0:0:0;
      $edBAG.Z.StartDatum->WinUpdate(_WinUpdFld2Obj);
    end;

    If ((aEvt:Obj->wpname = 'edBAG.Z.Endzeit') and (aEvt:Obj->wpcaptiontime > 23:59:59.00)) then begin
      BAG.Z.EndZeit # 0:0:0;
      $edBAG.Z.EndZeit->WinUpdate(_WinUpdFld2Obj);
    end;

  End;

  If ((aEvt:Obj->wpname = 'edBAG.Z.Startdatum') or (aEvt:Obj->wpname = 'edBAG.Z.Enddatum')) then begin
    If ((aEvt:Obj->wpname = 'edBAG.Z.Startdatum') and (aEvt:Obj->wpcaptiondate = 1.1.1900)) then begin
      BAG.Z.Startdatum # 0.0.0;
      $edBAG.Z.StartDatum->WinUpdate(_WinUpdFld2Obj);
    end;

    If ((aEvt:Obj->wpname = 'edBAG.Z.Enddatum') and (aEvt:Obj->wpcaptiondate = 1.1.1900)) then begin
      BAG.Z.Enddatum # 0.0.0;
      $edBAG.Z.EndDatum->WinUpdate(_WinUpdFld2Obj);
    end;
  End;

  // 09.05.2018 AH: Dauer verändert ggf. Start/Ende
  If ((aEvt:Obj->wpname = 'edBAG.Z.Dauer') and ($edBAG.Z.Dauer->wpChanged)) then begin
    if (BAG.Z.StartDatum>0.0.0) then begin
      vCT->vpDate # BAG.Z.StartDatum;
      vCT->vpTIme # BAG.Z.Startzeit;
      vCT->vmSecondsModify(cnvif(60.0 * BAG.Z.Dauer));
      BAG.Z.EndDatum  # vCT->vpDate;
      BAG.Z.Endzeit   # vCT->vpTime;
    end
    else if (BAG.Z.EndDatum>0.0.0) then begin
      vCT->vpDate # BAG.Z.EndDatum;
      vCT->vpTIme # BAG.Z.Endzeit;
      vCT->vmSecondsModify(- cnvif(60.0 * BAG.Z.Dauer));
      BAG.Z.StartDatum  # vCT->vpDate;
      BAG.Z.Startzeit   # vCT->vpTime;
    end;
  end;

  Timecalc();

  $edBAG.Z.StartDatum->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.StartZeit->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.EndDatum->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.EndZeit->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.Dauer->WinUpdate(_WinUpdFld2Obj);
  $edBAG.Z.GesamtkostenW1->WinUpdate(_WinUpdFld2Obj);

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

    'ZeitenTyp' : begin
      RecBufClear(855);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZTy.Verwaltung',here+':AusZeitenTyp');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'FehlerTyp' : begin
      RecBufClear(855);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'FhC.Verwaltung',here+':AusFehlerTyp');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung',here+':AusRessource');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusZeitenTyp
//
//========================================================================
sub AusZeitenTyp()
local begin
  vTmp : int;
end;
begin


  // cnvai(vTmp) + '   ' + cnvai(gSelected) + '   ');

  // Feldübernahme

  if (gSelected<>0) then begin
    RecRead(855,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Z.ZeitenTyp # ZTy.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    $edBAG.Z.ZeitenTyp->Winfocusset(false);


  end;
  if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edBAG.Z.ZeitenTyp->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edBAG.Z.ZeitenTyp',y);

end;


//========================================================================
//  AusFehlerTyp
//
//========================================================================

sub AusFehlerTyp()
local begin
  vTmp : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(851,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Z.FehlerTyp # FhC.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    $edBAG.Z.FehlerTyp->Winfocusset(false);

    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.Z.FehlerTyp->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edBAG.Z.FehlerTyp',y);
end;

//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
local begin
  vTmp : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Z.Ressource # RSO.Nummer;
    BAG.Z.ResGruppe # RSO.Gruppe;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $edBAG.Z.Ressource->Winfocusset(false);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.Z.Ressource->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('EdBAG.Z.Ressource',y);
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

  // Button & Menüs sperren

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Z_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Z_Anlegen]=n);


  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Z_Edit]=n);

  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Z_Edit]=n);


  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Z_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Z_Loeschen]=n);

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
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,BAG.Z.Anlage.Datum, BAG.Z.Anlage.Zeit, BAG.Z.Anlage.User);
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
    'bt.ZeitenTyp'  :   Auswahl('ZeitenTyp');
    'bt.FehlerTyp'  :   Auswahl('FehlerTyp');
    'bt.ResGruppe'  :   Auswahl('ResGruppe');
    'bt.Ressource'  :   Auswahl('Ressource');
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
  Erx : int;
end;
begin
  Erx # RecLink(855,709,6,_recFirst);   // Zeittyp holen
  if (Erx>_rLocked) then RecBufClear(855);
  
  Erx # _rNoRec;
  if (BAG.Z.Ressource<>0) then
    Erx # RecLink(160,709,5,_recFirst);
  if (Erx>_rLocked) then
    RecbufClear(160);

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
  RETURN true;
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edBAG.Z.ZeitenTyp') AND (aBuf->BAG.Z.Zeitentyp<>0)) then begin
    RekLink(855,709,6,0);   // Zeitzentyp holen
    Lib_Guicom2:JumpToWindow('ZTy.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.Z.FehlerTyp') AND (aBuf->BAG.Z.Fehlertyp<>0)) then begin
    RekLink(851,709,7,0);   // Fehlertyp holen
    Lib_Guicom2:JumpToWindow('FhC.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.Z.Ressource') AND (aBuf->BAG.Z.Ressource<>0)) then begin
    RekLink( 160,709,5,0);   // Ressource holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================