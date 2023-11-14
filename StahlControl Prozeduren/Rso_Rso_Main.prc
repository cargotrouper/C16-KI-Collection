@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Rso_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
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
//    SUB AusAdresse()
//    SUB AusGruppe()
//    SUB AusRessource()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecid : int);
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Pflichtfelder();
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Instandhaltungsressourcen'
  cFile :     169
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Rso_Rso'
  cZList :    $ZL.Rso.IHARessourcen
  cKey :      1
end;

declare Pflichtfelder();

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

    // Auswahlfelder setzen...
  SetStdAusFeld('edRso.Rso.Adressnr'     ,'ADRESSE');
  SetStdAusFeld('edRso.Rso.ZielGruppe'   ,'GRUPPE');
  SetStdAusFeld('edRso.Rso.ZielRes'      ,'RESSOURCE');

  $Lb.HW1->wpCaption # "Set.Hauswährung.Kurz";

  // Labels
  $Lb.Ressource       -> wpcaption  # AInt(Rso.Nummer);
  $Lb.Ressourcenname  -> wpcaption  # Rso.Bezeichnung1;
  $Lb.Ressource2      -> wpcaption  # AInt(Rso.Nummer);
  $Lb.Ressourcenname2 -> wpcaption  # Rso.Bezeichnung1;
  $Lb.Nummer          -> wpcaption  # AInt(Rso.IHA.Nummer);
  $Lb.Wartung         -> wpcaption  # AInt(Rso.IHA.Wartung);
  $Lb.Nummer2         -> wpcaption  # AInt(Rso.IHA.Nummer);
  $Lb.Wartung2        -> wpcaption  # AInt(Rso.IHA.Wartung);
  $Lb.Ursnummer     -> wpcaption    # AInt(Rso.Urs.Nummer);
  $Lb.Ursnummer2    -> wpcaption    # AInt(Rso.Urs.Nummer);
  $Lb.Masnummer     -> wpcaption    # AInt("Rso.Maß.Maßnahme");
  $Lb.Masnummer2     -> wpcaption   # AInt("Rso.Maß.Maßnahme");

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
  Erx   : int;
  vTmp  : int;
end;
begin

  // Felder
  $edRso.Rso.Adressnr     -> wpCaptionInt # Rso.Rso.Adressnr;
  $edRso.Rso.ZielGruppe   -> wpCaptionInt # Rso.Rso.ZielGruppe;
  $edRso.Rso.ZielRes      -> wpCaptionInt # Rso.Rso.ZielRes;

  if (aName='cbRso.Rso.ExternYN') then begin
    if (Rso.Rso.ExternYN) then begin
      Rso.Rso.Zielgruppe # 0;
      Rso.Rso.ZielRes # 0;
      Lib_GuiCom:Enable($edRso.Rso.Adressnr);
      Lib_GuiCom:Enable($edRso.Rso.Gesamtpreis);
      Lib_GuiCom:Disable($edRso.Rso.ZielGruppe);
      Lib_GuiCom:Disable($edRso.Rso.ZielRes);
    end
    else begin
      Rso.Rso.Adressnr # 0;
      Lib_GuiCom:Disable($edRso.Rso.Adressnr);
      Lib_GuiCom:Disable($edRso.Rso.Gesamtpreis);
      Lib_GuiCom:Enable($edRso.Rso.ZielGruppe);
      Lib_GuiCom:Enable($edRso.Rso.ZielRes);
   end;
  end;

  if (aName='') or (aName='Lb.Externer') then begin
    if ($cbRso.Rso.ExternYN -> wpCheckState = (_winStateChkChecked)) then begin
      Adr.Nummer  # Rso.Rso.Adressnr;

      Erx # RecRead(100,1,0);
      if (Erx<=_rLocked) then
        $Lb.Externer  -> wpCaption # Adr.Stichwort;
      else
        $Lb.Externer  -> wpCaption # '';
    end
    else
      $Lb.Externer    -> wpCaption # '';
  end;

  if (aName='') or (aName='LB.ZielGruppe') then begin
    Rso.Grp.Nummer # Rso.Rso.ZielGruppe;

    Erx # RecRead(822,1,0);
    if (Erx<=_rLocked) then
      $Lb.ZielGruppe -> wpcaption # Rso.Grp.Bezeichnung;
    else
      $Lb.ZielGruppe -> wpcaption # '';
  end;


  if (aName='') or (aName='LB.ZielRes') then begin
    If (Rso.Rso.ZielRes <> 0) then begin
      Rso.Gruppe    # Rso.Rso.ZielGruppe;
      Rso.Nummer    # Rso.Rso.ZielRes;
      RecRead(160,1,0);  // Lies Ressourcenbeschreibung

      Erx # RecRead(824,1,0);
      if (Erx<=_rLocked) then
        $Lb.ZielRes -> wpcaption # Rso.Bezeichnung1;
      else
        $Lb.ZielRes -> wpcaption # '';
    end
    else
        $Lb.ZielRes -> wpcaption # '';
  end;

  if (aName='') or (aName='LB.Ressource') or (aName='LB.Ressource2') then begin
    Rso.Gruppe    # Rso.Rso.Gruppe;
    Rso.Nummer    # Rso.Rso.Ressource;
    RecRead(160,1,0);  // Lies Ressourcenbeschreibung

    Erx # RecRead(824,1,0);
    if (Erx<=_rLocked) then begin
      $Lb.Ressourcenname  -> wpcaption # Rso.Bezeichnung1;
      $Lb.Ressourcenname2 -> wpcaption # Rso.Bezeichnung1;
    end
    else begin
      $Lb.Ressourcenname  -> wpcaption # '';
      $Lb.Ressourcenname2 -> wpcaption # '';
    end;
  end;

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
local begin
  vNr : int;
end;
begin

  If (Mode=c_ModeNew) then begin
    /*RecLink(169,167,2,_RecLast);
    vNr # Rso.Rso.Nummer + 1;
    RecBufClear(169);*/

    vNr # Lib_Nummern:ReadNummer('Ressourcen');
    if (vNr <> 0) then Lib_Nummern:SaveNummer();
    else Debug('Reservierung fehlgeschlagen');

    Rso.Rso.Nummer  # vNr;
    Rso.Rso.ZielRes # 0;

    Rso.Rso.Datum     #   Rso.IHA.Termin; // Zeit: Von IHA
    Rso.Rso.User      #   Usr.Username;
  end;

  "Rso.Rso.Gruppe"    # "Rso.Maß.Gruppe";
  "Rso.Rso.Ressource" # "Rso.Maß.Ressource";
  "Rso.Rso.WartungYN" # "Rso.Maß.WartungYN";
  "Rso.Rso.IHA"       # "Rso.Maß.IHA";
  "Rso.Rso.Ursache"   # "Rso.Maß.Ursache";
  "Rso.Rso.Maßnahme"  # "Rso.Maß.Nummer";

  //Rso.Rso.Datum     #   SysDate();    // Zeit: Jetzt
  //Rso.Rso.Zeit      #   Now;

  RefreshIfm();

  if (Rso.Rso.ExternYN) then begin
    Lib_GuiCom:Enable($edRso.Rso.Adressnr);
    Lib_GuiCom:Enable($edRso.Rso.Gesamtpreis);
    Lib_GuiCom:Disable($edRso.Rso.ZielGruppe);
    Lib_GuiCom:Disable($edRso.Rso.ZielRes);
    end
  else begin
    Lib_GuiCom:Disable($edRso.Rso.Adressnr);
    Lib_GuiCom:Disable($edRso.Rso.Gesamtpreis);
    Lib_GuiCom:Enable($edRso.Rso.ZielGruppe);
    Lib_GuiCom:Enable($edRso.Rso.ZielRes);
 end;

  $cbRso.Rso.ExternYN->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (Rso.Rso.ExternYN = false) then begin  // Unterscheidung nach externen/internen Ressourcen

    if (Rso.Rso.ZielGruppe=0) then begin
      Msg(001200,Translate('Zielgruppe'),0,0,0);
      vTmp # gMdi->winsearch('edRso.Rso.ZielGruppe');
      if (vTmp<>0) then vTmp->winFocusSet();
      RETURN false;
    end;

    if (Rso.Rso.ZielRes=0) then begin
      Msg(001200,Translate('Zielressource'),0,0,0);
      vTmp # gMdi->winsearch('edRso.Rso.ZielRes');
      if (vTmp<>0) then vTmp->winFocusSet();
      RETURN false;
    end;

    if (Rso.Rso.ZielGruppe<>0) then begin
      Rso.Grp.Nummer # Rso.Rso.ZielGruppe;
      Erx # RecRead(822,1,0);
      If (Erx>_rLocked) then begin
        Msg(001201,Translate('ZielGruppe'),0,0,0);
        vTmp # gMdi->winsearch('edRso.Rso.ZielGruppe');
        if (vTmp<>0) then vTmp->winFocusSet();
        RETURN false;
      end;
    end;

    if (Rso.Rso.ZielRes<>0) and (Rso.Rso.ZielGruppe<>0) then begin
      Erx # RecLink(160,169,1,0);
      If (Erx>_rLocked) then begin
        Msg(001201,Translate('Zielressource'),0,0,0);
        vTmp # gMdi->winsearch('edRso.Rso.ZielRes');
        if (vTmp<>0) then vTmp->winFocusSet();
        RETURN false;
      end;
    end;

  end
  else begin // externe Ressource

    if (Rso.Rso.Adressnr=0) then begin
      Msg(001200,Translate('Adressnummer'),0,0,0);
      vTmp # gMdi->winsearch('edRso.Rso.Adressnr');
      if (vTmp<>0) then vTmp->winFocusSet();
      RETURN false;
    end;

    if (Rso.Rso.Adressnr<>0) then begin
      Erx # RecLink(100,169,2,0);
      If (Erx>_rLocked) then begin
        Msg(001201,Translate('Adressnummer'),0,0,0);
        vTmp # gMdi->winsearch('edRso.Rso.Adressnr');
        if (vTmp<>0) then vTmp->winFocusSet();
        RETURN false;
      end;
    end;

  end;

  if (Rso.Rso.ExternYN=n) then begin
    Rso.Rso.Gesamtpreis # 0.0;
    Erx # RecLink(160,169,1,0);
    if (Erx<=_rLocked) then begin
      Rso.Rso.Gesamtpreis # Rso.PreisProH * Rso.Rso.Dauer / 60.0;
    end;
    Rso.Gruppe    # Rso.Rso.Gruppe;
    Rso.Nummer    # Rso.Rso.Ressource;
    RecRead(160,1,0);  // Lies Ressourcenbeschreibung
  end;
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
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
  RecRead(169,1,1); // Für Zugriffsliste
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
  RefreshIfm();

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
  vFilter : int;
end;

begin

  case aBereich of
    'ADRESSE' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','Rso_Rso_Main:AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
      gMdi->WinUpdate(_WinUpdOn);
    end;

    'GRUPPE' : begin
      RecBufClear(822);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Grp.Verwaltung','Rso_Rso_Main:AusGruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'RESSOURCE' : begin
      RecBufClear(160);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung','Rso_Rso_Main:AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end

  end;

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Rso.Adressnr  # Adr.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edRso.Rso.Adressnr->Winfocusset(true);
  // ggf. Labels refreshen
  RefreshIfm();
end;


//========================================================================
//  AusGruppe
//
//========================================================================
sub AusGruppe()
begin
  if (gSelected<>0) then begin
    RecRead(822,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Rso.ZielGruppe # Rso.Grp.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edRso.Rso.ZielGruppe->Winfocusset(true);
  // ggf. Labels refreshen
  RefreshIfm();
end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Rso.ZielRes # Rso.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edRso.Rso.ZielRes->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm();
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Rso_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Rso_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Rso_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Rso_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Rso_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Rso_Loeschen]=n);

  RefreshIfm();
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

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Adresse'   :   Auswahl('ADRESSE');
    'bt.Gruppe'    :   Auswahl('GRUPPE');
    'bt.Ressource' :   Auswahl('RESSOURCE');
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
  App_Main:Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//
//========================================================================
sub EvtLstSelect(
                        aEvt      : event;
                        aRecid    : int;
                   );
begin
  RecRead(169,1,0);
  App_Main:Refreshmode();    // Aktivieren/Deaktivieren von Datansatzabhängigen Menüpunkten
end;

//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbRso.Rso.ExternYN') then begin
    if (Rso.Rso.ExternYN) then begin
      Lib_GuiCom:Enable($edRso.Rso.Adressnr);
      Lib_GuiCom:Enable($edRso.Rso.Gesamtpreis);
      Lib_GuiCom:Disable($edRso.Rso.ZielGruppe);
      Lib_GuiCom:Disable($edRso.Rso.ZielRes);
      end
    else begin
      Lib_GuiCom:Disable($edRso.Rso.Adressnr);
      Lib_GuiCom:Disable($edRso.Rso.Gesamtpreis);
      Lib_GuiCom:Enable($edRso.Rso.ZielGruppe);
      Lib_GuiCom:Enable($edRso.Rso.ZielRes);
    end;
  end;
  Pflichtfelder();
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
begin
  RETURN true;
end;

//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  if ($cbRso.Rso.ExternYN->wpCheckState = _WinStateChkChecked) then begin
    Lib_GuiCom:Pflichtfeld($edRso.Rso.Adressnr);
  end
  else begin
    Lib_GuiCom:Pflichtfeld($edRso.Rso.ZielGruppe);
    Lib_GuiCom:Pflichtfeld($edRso.Rso.ZielRes);
  end;
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================