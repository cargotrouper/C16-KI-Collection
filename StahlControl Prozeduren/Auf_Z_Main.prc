@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_Z_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  FR  Erstellung der Prozedur (Aus Ein_Z_Main)
//  13.12.2012  AI  FormelFunktion
//  11.11.2013  ST  Bugfix: MEH Auswahl (Projekt 1326/375)
//  15.08.2014  AH  Reverse-Charge: Warengruppe muss bei fixen Kopfaufpreisen angegeben werden
//  05.02.2015  AH  Neu: Verpackungsartikelnr. aus Vorgabedatei
//  16.01.2018  AH  Wenn nur eine Aufpreisliste existiert, dann Kopfabfrage sparen
//  04.04.2022  AH  ERX
//  18.07.2022  HA  Quick Jump
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
//    SUB AusArtikel()
//    SUB AusSchluessel()
//    SUB AusSchluessel2()
//    SUB AusWarengruppe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked
//    SUN EvtChanged
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Auftragskopf-Aufpreise'
  cTitle2 :    'Auftragspositions-Aufpreise'
  cFile :     403
  cMenuName : 'Auf.Z.Bearbeiten'
  cPrefix :   'Auf_Z'
  cZList :    $ZL.Auf.Aufpreise
  cKey :      1
end;

declare Auswahl(aBereich : alpha);

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  if (Auf.P.Position=0) then
    gTitle  # Translate(cTitle)
  else
    gTitle  # Translate(cTitle2);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edAuf.Z.Schluessel);
Lib_Guicom2:Underline($edAuf.Z.Warengruppe);
Lib_Guicom2:Underline($edAuf.Z.Vpg.ArtikelNr);

  SetStdAusFeld('edAuf.Z.Schluessel'     ,'Schluessel');
  SetStdAusFeld('edAuf.Z.Vpg.ArtikelNr'  ,'Artikel');
  SetStdAusFeld('edAuf.Z.MEH'            ,'MEH');
  SetStdAusFeld('edAuf.Z.Warengruppe'    ,'Warengruppe');

  App_Main:EvtInit(aEvt);
end;

//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edAuf.Z.PEH);
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

  if (Mode=c_modeNew) or (Mode=c_ModeEdit) then begin
    if (Auf.Z.PerFormelYN) then begin
      Lib_GuiCom:Enable($edAuf.Z.FormelFunktion);
    end
    else begin
      Lib_GuiCom:Disable($edAuf.Z.FormelFunktion);
    end;
  end;

  if (aName='') then begin
    $lb.Nummer->wpcaption # AInt(Auf.Z.Nummer);
    $lb.Position->wpcaption # AInt(Auf.Z.Position);
    $lb.Lieferant->wpcaption # Auf.P.KundenSW;
    RecLink(814,400,8,0);     // Währung holen
    $lb.WAE->wpcaption # "Wae.Kürzel";
  end;

  if (aName='') or (aName='edAuf.Z.Warengruppe') then begin
    Erx # RecLink(819,403,1,0);
    if (Erx<=_rLocked) then
      $lb.Wgr->wpcaption # Wgr.Bezeichnung.L1
    else
      $lb.Wgr->wpcaption # '';
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
  if (Mode=c_ModeNew) then begin
    Auf.Z.Nummer # Auf.P.Nummer;
    Auf.Z.Position # Auf.P.Position;
    Auf.Z.MEH # 'kg';
    Auf.Z.PEH # 1000;
    Auf.Z.MengenbezugYN # y;
  end;

  $edAuf.Z.Schluessel->WinFocusSet(true);
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
  if (Auf.Z.PEH=0) then begin
    Msg(001200,Translate('PEH'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.Z.PEH->WinFocusSet(true);
    RETURN false;
  end;

  // für Reverse-Charge:
  if (Auf.Z.MengenbezugYN=false) and (Auf.Z.Position=0) and (Auf.Z.MEH<>'%') and (Auf.Z.Warengruppe=0) then begin
    Lib_Guicom2:InhaltFehlt('Warengruppe', 'NB.Page1', 'edAuf.Z.Warengruppe');
    RETURN false;
  end;
  if (Auf.Z.Warengruppe<>0) then begin
    Erx # RekLink(819,403,1,_recFirsT); // Warengruppe holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Warengruppe', 'NB.Page1', 'edAuf.Z.Warengruppe');
      RETURN false;
    end;
  end;
  if (Auf.Z.MEH='%') and (Auf.Z.RabattierbarYN=false) then begin
    Lib_Guicom2:InhaltFehlt('Rabbatierbar', 'NB.Page1', 'cbAuf.Z.RabattierbarYN');
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
    Auf.Z.Anlage.Datum  # Today;
    Auf.Z.Anlage.Zeit   # Now;
    Auf.Z.Anlage.User   # gUsername;

    Auf.Z.lfdNr         # 1;

    repeat
      Erx # RekInsert(gFile,0,'MAN');
      Auf.Z.lfdNr # Auf.Z.lfdNr + 1;
    until (Erx = _rOk);

    /*if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;*/

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
  if (Auf.Z.Rechnungsnr<>0) then RETURN;    // 2022-09-20 AH

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
  vA    : alpha;
  vSel  : alpha;
  vHdl  : int;
  vQ    : alpha(4000);
end;
begin

  case aBereich of
    'Schluessel' : begin

      // Ankerfunktion
      if (RunAFX('APL.Auswahl','403')<0) then RETURN;

      // 16.01.2018 AH: Wenn nur eine Liste?
      if (RecInfo(842,_recCount)=1) then begin
        Erx # RecRead(842,1,_recFirst);
        Auswahl('Schluessel2');
        RETURN;
      end;

      RecBufClear(842);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.Verwaltung',here+':AusSchluessel');

      // Selektion
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList( 0, 'ApL.VerkaufYN' );

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Schluessel2' : begin
      RecBufClear(843);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.L.Verwaltung',here+':AusSchluessel2');
      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'ApL.L.Key1 = ' + cnvAI(ApL.Key1);
      vQ # vQ + ' AND ApL.L.Key2 = ' + cnvAI(ApL.Key2) ;
      vQ # vQ + ' AND ApL.L.Key3 = ' + cnvAI(ApL.Key3);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha( var vQ, 'Art.Typ', '=', 'VPG');
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('AufpreisEH',$edAuf.Z.MEH,403,1,6);
    end;


    'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',Here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    Auf.Z.Vpg.Artikelnr   # Art.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.Z.Vpg.Artikelnr->Winfocusset(true);
end;


//========================================================================
//  AusSchluessel
//
//========================================================================
sub AusSchluessel()
begin
  if (gSelected<>0) then begin
    RecRead(842,0,_RecId,gSelected);
    $edAuf.Z.Schluessel->wpCustom # 'xx';//cnvai(gselected);

    // Event für Anschriftsauswahl starten
    Auswahl('Schluessel2');

    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.Z.Schluessel->Winfocusset(true);
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    Auf.Z.Warengruppe # Wgr.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.Z.Warengruppe->Winfocusset(false);
end;


//========================================================================
//  AusSchluessel2
//
//========================================================================
sub AusSchluessel2()
begin
  // Zugriffliste wieder aktivieren
  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(843,0,_RecId,gSelected);
    //Auf.Z.Schluessel #
    gSelected # 0;
    Auf.Z.Nummer          # Auf.P.Nummer;
    Auf.Z.Position        # Auf.P.Position;
    // 12 !!! 1+3+1+3+1+3
    // Auf.Z. Ein.Z. Erl.K. Vbk.K.
    "Auf.Z.Schlüssel"     # '#'+Cnvai(ApL.L.Key2,_fmtnumleadzero,0,3)+'.'+CnvAI(ApL.L.Key3,_fmtnumleadzero,0,3)+'.'+cnvai(ApL.L.Key4,_fmtnumleadzero,0,3);
    Auf.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
    Auf.Z.Menge           # ApL.L.Menge;
    Auf.Z.MEH             # ApL.L.MEH;
    Auf.Z.PEH             # ApL.L.PEH;
    Auf.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
    Auf.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
    Auf.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
    Auf.Z.ProRechnungYN   # ApL.L.ProRechnungYN;;
    Auf.Z.PerFormelYN     # ApL.L.PerFormelYN;
    Auf.Z.FormelFunktion  # ApL.L.FormelFunktion;
    Auf.Z.Vpg.Artikelnr   # ApL.L.Vpg.Artikelnr;

    Auf.Z.Preis           # ApL.L.Preis;
    Auf.Z.Warengruppe     # ApL.L.Warengruppe;
    RefreshIfm();
    gMDI->winupdate();
  end;
  // Focus auf Editfeld setzen:
  $edAuf.Z.Schluessel->Winfocusset(true);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Z_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Z_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Z_Aendern]=n) or (StrFind("Auf.Z.Schlüssel",'*RAB',0)<>0);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Z_Aendern]=n) or (StrFind("Auf.Z.Schlüssel",'*RAB',0)<>0);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Z_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Z_Loeschen]=n);

  RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // MenüAuftrag
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

    'Mnu.Auto' : begin
      if (Msg(842000,gTitle,_WinIcoQuestion,_WinDialogYesNo,1)=_WinidYes) then begin
        ApL_Data:AutoGenerieren(401);
        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      end;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Auf.Z.Anlage.Datum, Auf.Z.Anlage.Zeit, Auf.Z.Anlage.User );
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
    'bt.Schluessel'   :   Auswahl('Schluessel');
    'bt.Artikel'      :   Auswahl('Artikel');
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Wgr'          :   Auswahl('Warengruppe');
  end;

end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (Mode=c_ModeView) then RETURN true;

  if (aEvt:Obj->wpname='cbAuf.Z.MengenbezugYN') then begin
    if (Auf.Z.MengenBezugYN) then begin
      Auf.Z.PerFormelYN     # n;
      Auf.Z.FormelFunktion  # '';
      $edAuf.Z.FormelFunktion->winupdate(_WinUpdFld2Obj);
      $cbAuf.Z.PerFormelYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edAuf.Z.FormelFunktion);
    end;
  end;

  if (aEvt:Obj->wpname='cbAuf.Z.PerFormelYN') then begin
    if (Auf.Z.PerFormelYN) then begin
      Auf.Z.MengenbezugYN # n;
      $cbAuf.Z.MengenbezugYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Enable($edAuf.Z.FormelFunktion);
      end
    else begin
      Auf.Z.FormelFunktion # '';
      $edAuf.Z.FormelFunktion->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edAuf.Z.FormelFunktion);
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
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen Aufes Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);

local begin
  vToken : alpha;
  vBuf,vBuf2  : int;
end;

begin

  if ((aName =^ 'edAuf.Z.Schluessel') AND (aBuf->"Auf.Z.Schlüssel"<>'')) then begin
   
   //  1     2   3
   // #002.100.0007
   // Teilx = Lib_Strings:Strings_Token(x,y,z)
   //
   // CnvIA()
    RecBufClear(843);
   vToken # Lib_Strings:Strings_Token("Auf.Z.Schlüssel", '.', 1) ;
   ApL.Key1 # CnvIA(vToken);
   
   vToken # Lib_Strings:Strings_Token("Auf.Z.Schlüssel", '.', 2) ;
   ApL.Key2 # CnvIA(vToken);
   
   vToken # Lib_Strings:Strings_Token("Auf.Z.Schlüssel", '.', 3) ;
   ApL.Key3 # CnvIA(vToken);
   /*ApL.Key2 # "Auf.Z.Schlüssel";
   ApL.Key3 # "Auf.Z.Schlüssel";*/
   RecRead(843,1,0)
    Lib_Guicom2:JumpToWindow('Apl.L.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAuf.Z.Warengruppe') AND (aBuf->Auf.Z.Warengruppe<>0)) then begin
    RekLink(819,403,1,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAuf.Z.Vpg.ArtikelNr') AND (aBuf->Auf.Z.Vpg.ArtikelNr<>'')) then begin
    Art.Nummer # Auf.Z.Vpg.ArtikelNr;
    RecRead(250,1,0)
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;

end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================