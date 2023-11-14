@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rek_P_C_Main
//                  OHNE E_R_G
//  Info
//
//
//  10.07.2014  AH  Erstellung der Prozedur
//  04.04.2017  AH  "MatExists" kommt mit MatMix klar
//  16.03.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
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
//    SUB MatExists( aMat : int; aArt : alpha; aCharge : alpha) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cDialog     : 'Rek.P.C.Verwaltung'
  cTitle      : 'weitere Reklamations-Chargen'
  cRecht      : Rgt_Rek_Positionen
  cMdiVar     : gMDIqs
  cFile       : 303
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Rek_P_C'
  cZList      : $ZL.Rek.P.Chargen
  cKey        : 1
  cListen     : 'Reklamationen'
end;

declare MatExists( aMat : int; aArt : alpha; aCharge : alpha) : logic;


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

Lib_Guicom2:Underline($edRek.P.C.Materialnr);
Lib_Guicom2:Underline($edRek.P.C.Art.C.Intern);

    // Auswahlfelder setzen...
  SetStdAusFeld('edRek.P.C.Art.C.Intern'        ,'Material');
  SetStdAusFeld('edRek.P.C.Materialnr'          ,'Material');

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

  $edRek.P.C.Materialnr->wpreadonly   # true;
  $edRek.P.C.Art.C.Intern->Wpreadonly # true;

  if (Rek.Nummer<1000000000) then
    Rek.P.C.Nummer  # Rek.Nummer;
  Rek.P.C.Position  # Rek.P.Position;
  Rek.P.C.LfdNr     # 1;

  // Focus setzen auf Feld:
  if (Wgr.Dateinummer=250) then begin
    $edRek.P.C.Art.C.Intern->Winfocusset(false);
  end
  else begin
    $edRek.P.C.Materialnr->Winfocusset(false);
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
  If (Rek.P.C.Materialnr=0) and (Rek.P.C.Art.C.Intern='') then begin
    Lib_Guicom2:InhaltFehlt('Material', 'NB.Page1', '$edRek.P.C.Materialnr');
    RETURN false;
  end;
  if (MatExists(Rek.P.C.Materialnr, Rek.P.C.Artikelnr, Rek.P.C.Art.C.Intern)) then begin
    Msg(001006,Translate('Material'),0,0,0);
    RETURN false;
  end;

  // Nummernvergabe
  Rek.P.C.Nummer    # Rek.Nummer;

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
    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (erx<>_rOK) then
        Rek.P.C.Lfdnr # Rek.P.C.lfdnr + 1;
    UNTIL (Erx=_rOK);
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
  Erx   : int;
  vQ    : alpha(4000);
  vA    : alpha;
  vHdl  : int;
end;

begin

  case aBereich of

    'Material' : begin
      if (Rek.ZuDatei = 400) then begin         // Aktionen
        RecBufClear(404);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.A.Verwaltung',here+':AusAufAktion');

        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        Lib_Sel:QInt(var vQ, 'Auf.A.Nummer'  , '=', Auf.P.Nummer);
        Lib_Sel:QInt(var vQ, 'Auf.A.Position' , '=', Auf.P.Position);
        Lib_Sel:QRecList(0, vQ);

        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else if (Rek.ZuDatei = 500) then begin    // Wareneingänge
        RecBufClear(506);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Mat.Verwaltung',here+':AusWareneingang');
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else if (Rek.ZuDatei = 701) then begin    // Einsatz
        Erx # RekLink(702,300,12,_recFirst);    // BA-Pos holen
        if (Erx<=_rLocked) then begin
          Erx # RekLink(700,702,1,_recFirst);   // BA-Kopf holen
          RecBufClear(707);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.IO.Input.Lohn.Verwaltung',here+':AusBAInput');

          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

          vHdl # Winsearch(gMDI, 'Lb.IO.Nummer');
          if (vHdl<>0) then vHdl->wpcustom # '';

          gZLList->wpDbFileNo       # 701;
          gZLList->wpDbKeyNo        # 1;
          gKey # 1;
          gZLList->wpDbLinkFileNo   # 0;
          Lib_Sel:QInt(var vQ, 'BAG.IO.Nummer'  , '=', BAG.P.Nummer);
          Lib_Sel:QInt(var vQ, 'BAG.IO.NachPosition'  , '=', BAG.P.Nummer);
          Lib_Sel:QInt(var vQ, 'BAG.IO.BruderID'  , '=', 0);
          Lib_Sel:QInt(var vQ, 'BAG.IO.Materialnr'  , '>', 0);
          Lib_Sel:QRecList(0, vQ);

          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end
      else if (Rek.ZuDatei=707) then begin      // Verwiegungen
        Erx # RekLink(702,300,12,_recFirst);    // BA-Pos holen
        if (Erx<=_rLocked) then begin
          BA1_FM_Main:Start(BAG.P.Nummer, BAG.P.Position, 0, 0, here+':AusBAFM', false);
/***
          Erx # RekLink(700,702,1,_recFirst);   // BA-Kopf holen
          RecBufClear(707);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1xx.FM.Verwaltung',here+':AusBAFM');

          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

          $ZL.BA1.FM->wpDbFileNo      # 707;
          $ZL.BA1.FM->wpDbKeyNo       # 1;
          gKey # 1;
          $ZL.BA1.FM->wpDbLinkFileNo  # 0;

          // Selektion aufbauen...
          Lib_Sel:QInt(var vQ, 'BAG.FM.Nummer', '=', BAG.P.Nummer);
          Lib_Sel:QInt(var vQ, 'BAG.FM.Position', '=', BAG.P.Position);
          Lib_Sel:QRecList(0, vQ);

          Lib_GuiCom:RunChildWindow(gMDI);
***/
        end;
      end;
    end;
  end;  // ...case

end;


//========================================================================
//  AusAufAktion
//
//========================================================================
sub AusAufAktion()
local begin
  Erx : int;
end;
begin

  if (gSelected=0) then RETURN;

  Erx # RecRead(404,0,_RecId,gSelected);
  gSelected # 0;
  if (Erx<=_rLocked) then begin
    // Feldübernahme
    Rek.P.C.Materialnr    # Auf.A.Materialnr;
    Rek.P.C.ArtikelNr     # Auf.A.Artikelnr;
    Rek.P.C.Art.C.Intern  # Auf.A.Charge;
    Rek.P.C.Aktion        # Auf.A.Position2;
    Rek.P.C.Aktion2       # Auf.A.Aktion;
  end;

  // Focus auf Editfeld setzen:
  if (Wgr.Dateinummer=250) then begin
    $edRek.P.C.Art.C.Intern->Winfocusset(false);
    RefreshIfm('Rek.P.C.Art.C.Intern',y);
  end
  else begin
    $edRek.P.C.Materialnr->Winfocusset(false);
    RefreshIfm('Rek.P.C.Materialnr',y);
  end;

end;


//========================================================================
//  AusWareneingang
//
//========================================================================
sub AusWareneingang()
local begin
  Erx : int;
end;
begin

  if (gSelected=0) then RETURN;

  Erx # RecRead(506,0,_RecId,gSelected);
  gSelected # 0;
  if (Erx<=_rLocked) then begin
    // Feldübernahme
    Rek.P.C.Materialnr    # Ein.E.Materialnr;
    Rek.P.C.ArtikelNr     # Ein.E.Artikelnr;
    Rek.P.C.Art.C.Intern  # Ein.E.Charge;
    Rek.P.C.Aktion        # Ein.E.eingangsnr;
    Rek.P.C.Aktion2       # 0;
  end;

  // Focus auf Editfeld setzen:
  if (Wgr.Dateinummer=250) then begin
    $edRek.P.C.Art.C.Intern->Winfocusset(false);
    RefreshIfm('Rek.P.C.Art.C.Intern',y);
  end
  else begin
    $edRek.P.C.Materialnr->Winfocusset(false);
    RefreshIfm('Rek.P.C.Materialnr',y);
  end;

end;


//========================================================================
//  AusBAFM
//
//========================================================================
sub AusBAFM()
local begin
  Erx : int;
end;
begin

  if (gSelected=0) then RETURN;

  Erx # RecRead(707,0,_RecId,gSelected);
  gSelected # 0;
  If (Erx<_rLocked) then begin
    // Feldübernahme
    Rek.P.C.Materialnr  # BAG.FM.Materialnr;
//TODO    Rek.P.C.Artikel     # BAG.FM.Artikelnr;
//    Rek.P.C.Charge      # BAG.FM.Charge;
    Rek.P.C.Aktion      # BAG.FM.Fertigung;
    Rek.P.C.Aktion2     # BAG.FM.Fertigmeldung;
  end;

  // Focus auf Editfeld setzen:
  if (Wgr.Dateinummer=250) then begin
    $edRek.P.C.Art.C.Intern->Winfocusset(false);
    RefreshIfm('Rek.P.C.Art.C.Intern',y);
  end
  else begin
    $edRek.P.C.Materialnr->Winfocusset(false);
    RefreshIfm('Rek.P.C.Materialnr',y);
  end;

end;


//========================================================================
//  AusBAInput
//
//========================================================================
sub AusBAInput()
local begin
  Erx : int;
end;
begin

  if (gSelected=0) then RETURN;

  Erx # RecRead(701,0,_RecId,gSelected);
  gSelected # 0;
  If (Erx<_rLocked) then begin
    // Feldübernahme
    Rek.P.C.Materialnr    # BAG.IO.Materialnr;
    Rek.P.C.Artikelnr     # BAG.IO.Artikelnr;
    Rek.P.C.Art.C.Intern  # BAG.IO.Charge;
    Rek.P.C.Aktion        # BAG.IO.ID;
    Rek.P.C.Aktion2       # 0;
  end;

  // Focus auf Editfeld setzen:
  if (Wgr.Dateinummer=250) then begin
    $edRek.P.C.Art.C.Intern->Winfocusset(false);
    RefreshIfm('Rek.P.C.Art.C.Intern',y);
  end
  else begin
    $edRek.P.C.Materialnr->Winfocusset(false);
    RefreshIfm('Rek.P.C.Materialnr',y);
  end;

end;


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

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Loeschen]=n);

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
    'bt.Material' :   Auswahl('Material');
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
//  MatExists
//========================================================================
sub MatExists(
  aMat    : int;
  aArt    : alpha;
  aCharge : alpha;
  ) : logic;
local begin
  Erx     : int;
  v303    : int;
  vIstMat : logic;
end;
begin

  if (Rek.zuDatei=500) then
    Erx # RekLink(819,501,1,_recFirst);   // WGr holen
  else if (Rek.zuDatei=400) then
    Erx # RekLink(819,401,1,_recFirst);   // WGr holen
  else if (Rek.zuDatei=701) then
    Erx # RekLink(819,703,5,_recFirst);   // WGr holen
  vIstMat # (Wgr_Data:IstMix()) or (Wgr_Data:IstMat());

  if (vIstMat) then begin
    if (Rek.P.Materialnr=aMat) then RETURN true;
  end
  else begin
    if (Rek.P.Artikel=aArt) and (Rek.P.Charge=aCharge) then RETURN true;
  end;

  v303 # RekSave(303);
  FOR Erx # RecLink(303,301,10,_recFirst)
  LOOP Erx # RecLink(303,301,10,_recnext)
  WHILE (Erx<=_rLocked) do begin

    // Material?
    if (vIstMat) then begin
      if (Rek.P.C.Materialnr=aMat) then begin
        RekRestore(v303);
        RETURN true;
      end;
    end;
    else begin  // Artikel?
      if ((Rek.P.C.ArtikelNr=aArt) and (Rek.P.C.Art.C.Intern=aCharge)) then begin
        RekRestore(v303);
        RETURN true;
      end;
    end;

  END;

  RekRestore(v303);

  RETURN false;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRek.P.C.Materialnr') AND (aBuf->Rek.P.C.Materialnr<>0)) then begin
   todo('Material')
    //RekLink(819,200,1,0);   // MaterialNr. holen
    Lib_Guicom2:JumpToWindow('Auf.A.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.P.C.Art.C.Intern') AND (aBuf->Rek.P.C.Art.C.Intern<>'')) then begin
   todo('Material')
    //RekLink(819,200,1,0);   // int.Charge holen
    Lib_Guicom2:JumpToWindow('Auf.A.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================