@A+
//==== Business-Control ==================================================
//
//  Prozedur    MQu2_Main
//                  OHNE E_R_G
//  Info
//    Steuert die Qualitätsverwaltung
//
//  25.01.2021  AH  Erstellung der Prozedur
//  18.02.2021  AH  Kombiexport/Import
//  2022-06-28  AH  ERX
//  25.07.2022  HA  Quick Jump
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
//    SUB AusGuetenstufe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Qualitäten'
  cFile :     832
  cMenuName : 'MQu.Bearbeiten'
  cPrefix :   'MQu2'
  cZList :    $ZL.Qualitaten
  cKey :      1
end;

declare Export();;
declare Import();

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

  Lib_MoreBufs:Init(832);

  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbMQu.ChemieVon.C->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbMQu.ChemieVon.Si->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbMQu.ChemieVon.Mn->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbMQu.ChemieVon.P->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbMQu.ChemieVon.S->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbMQu.ChemieVon.Al->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbMQu.ChemieVon.Cr->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbMQu.ChemieVon.V->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbMQu.ChemieVon.Nb->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbMQu.ChemieVon.Ti->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbMQu.ChemieVon.N->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbMQu.ChemieVon.Cu->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbMQu.ChemieVon.Ni->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbMQu.ChemieVon.Mo->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbMQu.ChemieVon.B->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbMQu.ChemieVon.Frei1->wpcaption # Set.Chemie.Titel.1;
  end;

Lib_Guicom2:Underline($edMQu.NurStufe);

  SetStdAusFeld('edMQu.NurStufe' ,'Guetenstufe');

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

  if (mode=c_ModeView) then begin
    Lib_MoreBufs:ReadAll(832);
    Lib_MoreBufs:GetBuf(231, '');
    Recbufcopy(231, gMDi->wpDbRecBuf(231));
  end;

  if (aName='') or (aName='edMQu.NurStufe') then begin
    Erx # RecLink(848,832,2,_reCFirst);   // Stufe holen
    if (Erx>=_rLocked) then RecBufClear(848);
    $lb.Guetenstufe->wpcaption # MQu.S.Name;
  end;

  if (aName='') or (aName='Lb.ID') then begin
    if (MQu.ID <> 0) then
      $Lb.ID->wpcaption # AInt(MQu.ID);
    else
      $Lb.ID->wpcaption # '';
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vID : int;
end;
begin

  if (Mode=c_ModeEdit) then begin
    Lib_MoreBufs:RecInit(832, false);
  end;
  if (Mode=c_ModeNew) then begin
    Lib_MoreBufs:RecInit(832, y, n);    // , new, copy
  end;
  
  Lib_MoreBufs:GetBuf(231, '');
  Recbufcopy(231, gMDi->wpDbRecBuf(231));

  
/***
    RecRead(832,1,_recLast);
    vID # MQu.ID + 1;
    RecBufClear(832);
    MQu.Id # vID;
  end;
  */
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:

  $edMQu.Gte1->WinFocusSet(true);
  RefreshIfm('Lb.ID');
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vBuf  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // Analyse setzen
  vBuf # Lib_MoreBufs:GetBuf(231, '');
  RecBufCopy(gMDI->wpDbRecBuf(231), vBuf);
  vBuf->Lys.Anlage.Datum  # Today;
  vBuf->Lys.Anlage.Zeit   # Now;
  vBuf->Lys.Anlage.User   # gUsername;
  
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
    MQu.ID # Lib_Nummern:ReadNummer('Qualitäten');    // Nummer lesen
    Lib_Nummern:SaveNummer();

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  // Analyse speichern
  Erx # Lib_MoreBufs:SaveAll(832, true);
  if (Erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
/***
  if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then begin
    Lib_MoreBufs:Unlock();
  end
  else begin
    if (Lib_MoreBufs:DeleteAll(832)<>_rOK) then begin
//      TRANSBRK;
      RETURN false;
    end;
  end;
  ***/
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  TRANSON;

  if (Lib_MoreBufs:DeleteAll(832)<>_rOK) then begin
    TRANSBRK;
    RETURN;
  end;

  FOR Erx # recLink(833,832,1,_recFirst)
  LOOP Erx # recLink(833,832,1,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(833,0,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;
    if (Lib_MoreBufs:DeleteAll(833)<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;
  END;

  RekDelete(gFile,0,'MAN');

  TRANSOFF;

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

  // 22.02.2017 AH...
  "MQU.Güte1" # StrAdj("MQu.Güte1",_StrEnd);
  "MQU.Güte2" # StrAdj("MQu.Güte2",_StrEnd);
  "MQU.ErsetzenDurch" # StrAdj("MQu.ErsetzenDurch",_StrEnd);
  "MQU.nachNorm" # StrAdj("MQu.nachNorm",_StrEnd);
  "MQU.Werkstoffnr" # StrAdj("MQu.Werkstoffnr",_StrEnd);

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

  case aBereich of
    'Guetenstufe' : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Mqu.Nurstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edMQu.NurStufe->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl        : int;
  vTmp        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  if (gMenu<>0) then begin
    vTmp # gMenu->winsearch('Mnu.Excel.Import');
    if (vTmp<>0) then
      vTmp->wpname # 'Mnu.XExcel.Import';
    vTmp # gMenu->winsearch('Mnu.Daten.Export');
    if (vTmp<>0) then
      vTmp->wpname # 'Mnu.XDaten.Export';
  end;

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.XDaten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.XExcel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);

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

    'Mnu.XDaten.Export' : Export();
    'Mnu.XExcel.Import' : Import();

    'Mnu.Mechaniken' : begin
      RecBufClear(833);         // ZIELBUFFER LEEREN
      "MQu.M.GütenID" # MQu.ID;
      if (Set.LyseErweitertYN) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.M.Verwaltung2','',y)
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.M.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
      $NB.Main->WinFocusSet(true);
    end;


    'Mnu.Mark.Sel' : begin
      // Serienmarkierung; Selektionsdialog [17.12.2009/PW]
      Gv.Alpha.11 # ''; // WerkstoffNr von/gleich
      GV.Alpha.12 # ''; // WerkstoffNr bis
      Gv.Alpha.13 # ''; // Gütenstufe von/gleich
      GV.Alpha.14 # ''; // Gütenstufe bis

      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.Mark.MQu', here + ':AusSerienMark' );
      Lib_GuiCom:RunChildWindow( gMDI );
    end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField( gFile );
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    
    end;
    
    'Mnu.Kopie' : begin
      Mqu_Data:Copy_Guete();
    
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
    'bt.Guetenstufe'      : Auswahl('Guetenstufe');
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
//  AusSerienMark [17.12.2009/PW]
//
//========================================================================
sub AusSerienMark ()
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(500);
end;
begin
  gZlList->wpDisabled # false;
  Lib_GuiCom:SetWindowState( gMDI, true );

  /* Selektion */
  if ( Gv.Alpha.11 != '' ) then begin // WerkstoffNr
    if ( GV.Alpha.12 != '' ) then // von/bis
      Lib_Sel:QVonBisA( var vQ, 'MQu.WerkstoffNr', Gv.Alpha.11, GV.Alpha.12 );
    else
      Lib_Sel:QAlpha( var vQ, 'MQu.WerkstoffNr', '=', Gv.Alpha.11 );
  end;
  if ( GV.Alpha.13 != '' ) then begin // Gütenstufe
    if ( GV.Alpha.14 != '' ) then // von/bis
      Lib_Sel:QVonBisA( var vQ, 'MQu.NurStufe', GV.Alpha.13, GV.Alpha.14 );
    else
      Lib_Sel:QAlpha( var vQ, 'MQu.NurStufe', '=', GV.Alpha.13 );
  end;

  // Selektion durchführen
  vSel # SelCreate( 832, 1 );
  vSel->SelDefQuery( '', vQ );
  Lib_Sel:QError( vSel );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Ergebnisse markieren
  FOR  Erx # RecRead( 832, vSel, _recFirst );
  LOOP Erx # RecRead( 832, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Lib_Mark:MarkAdd( 832, true, true );
  END;

  // Selektion entfernen
  SelClose( vSel );
  SelDelete( 832, vSelName );

  gZlList->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );
end;


//========================================================================
Sub Export()
local begin
  Erx       : int;
  vList     : int;
  vName     : alpha(4000);
end;
begin
  vName # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'CSV-Dateien|*.csv');
  if (vName='') then RETURN;
  if (StrCnv(StrCut(vName,strlen(vName)-3,4),_StrUpper) <>'.CSV') then vName # vName + '.csv';
  Erx # Msg(998003,vName,_WinIcoQuestion,_WinDialogYesNoCancel,2);
  if (Erx=_WinIdCancel) then RETURN;
//  if (Erx=_winIdYes) then begin
//  Lib_excel:KombiListFeld(var vList, '', 231,1,11);
  Lib_Excel:KombiListFeld(var vList, 'MQu.ID');
  Lib_Excel:KombiListFeld(var vList, 'MQu.Güte1');
  Lib_Excel:KombiListFeld(var vList, 'MQu.M.BeiGütenstufe');
  Lib_Excel:KombiListFeld(var vList, 'MQu.M.bisDicke');
  Lib_Excel:KombiListFeld(var vList, 'MQu.M.ZusatzKriteriu');

  Lib_Excel:KombiListFeld(var vList, 'MQu.M.lfdNr');
  
  Lib_Excel:KombiListFeld(var vList, 'MQu.Güte2');
  Lib_Excel:KombiListFeld(var vList, 'MQu.Werkstoffnr');
  Lib_Excel:KombiListFeld(var vList, 'MQu.ErsetzenDurch');
  Lib_Excel:KombiListFeld(var vList, 'MQu.Klasse');
  Lib_Excel:KombiListFeld(var vList, 'MQu.nachNorm');
  Lib_Excel:KombiListFeld(var vList, 'MQu.NurStufe');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.C');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.C2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Si');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Si2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Mn');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Mn2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.P');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.P2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.S');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.S2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Al');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Al2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Cr');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Cr2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.V');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.V2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Nb');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Nb2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Ti');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Ti2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.N');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.N2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Cu');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Cu2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Ni');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Ni2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Mo');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Mo2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.B');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.B2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Sn');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Sn2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Pb');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Pb2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.NbTiV');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.SiP');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.CEV');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.Si25P');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Chemie.CrMoNi');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Mech.Sonstiges');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Mech.Sonstiges2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Mech.Sonstiges3');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Mech.Sonstiges4');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Mech.Sonstiges5');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Mech.Sonstiges6');

  Lib_Excel:KombiListFeld(var vList, 'Lys.StreckgrenzeTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Streckgrenze');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Streckgrenze2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.StreckgrenzeQTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.StreckgrenzeQ1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.StreckgrenzeQ2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.ZugFestTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Zugfestigkeit');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Zugfestigkeit2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.ZugFestQTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.ZugfestigkeitQ1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.ZugfestigkeitQ2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.DehnungA');
  Lib_Excel:KombiListFeld(var vList, 'Lys.DehnungB');
  Lib_Excel:KombiListFeld(var vList, 'Lys.DehnungC');
  Lib_Excel:KombiListFeld(var vList, 'Lys.DehnungQA');
  Lib_Excel:KombiListFeld(var vList, 'Lys.DehnungQB');
  Lib_Excel:KombiListFeld(var vList, 'Lys.DehnungQC');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Rp02Typ');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RP02_1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RP02_2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.SGVerhaeltnisTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.SGVerhaeltnis1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.GleichmassDehn');
  Lib_Excel:KombiListFeld(var vList, 'Lys.GleichmassDehnQ');
  Lib_Excel:KombiListFeld(var vList, 'Lys.HaerteTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Härte1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Härte2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.HC');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitATyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitA1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitA2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitBTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitB1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitB2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitCTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitC1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RauigkeitC2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.rWert');
  Lib_Excel:KombiListFeld(var vList, 'Lys.nWert');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Parallelitaet');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Kantenwinkel');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Saebeligkeit');
  Lib_Excel:KombiListFeld(var vList, 'Lys.SaebelProM');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Ebenheit');
  Lib_Excel:KombiListFeld(var vList, 'Lys.EbenheitProM');
  Lib_Excel:KombiListFeld(var vList, 'Lys.EbenheitQ');
  Lib_Excel:KombiListFeld(var vList, 'Lys.RandentkohlTyp');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Randentkohl');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Kantenradius');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Kantenradius2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.CG1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.CG2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.FA1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.FA2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.PA1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.PA2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.CN1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.CN2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.CZ1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.CZ2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.ZE1');
  Lib_Excel:KombiListFeld(var vList, 'Lys.ZE2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Körnung');
  Lib_Excel:KombiListFeld(var vList, 'Lys.Körnung2');
  Lib_Excel:KombiListFeld(var vList, 'Lys.SS');
  Lib_Excel:KombiListFeld(var vList, 'Lys.OA');
  Lib_Excel:KombiListFeld(var vList, 'Lys.OS');
  Lib_Excel:KombiListFeld(var vList, 'Lys.OG');

  Lib_excel:SchreibeKombi('Qualitäten+Mechaniken', vList, vName, RecInfo(832,_recCount), here+':ExportProc');
  Lib_excel:KombiListClose(var vList);
end;


//========================================================================
sub ExportReadLyse()
local begin
  vErx  : int;
  v231  : int;
  v231C : int;
end;
begin
  RecBufClear(231);

  v231 # RecBufCreate(231);
  v231->"Lys.Trägerdatei"     # 832;
  v231->"Lys.Trägernummer1"   # MQU.ID;
  vErx # RecRead(v231,2,0);
  if (vErx<=_rMultikey) then begin
    SbrCopy(v231,4, 231,4);   // CHEMIE kopieren
    Lys.Chemie.C      # v231->Lys.Chemie.C;
    Lys.Chemie.Si     # v231->Lys.Chemie.Si;
    Lys.Chemie.Mn     # v231->Lys.Chemie.Mn;
    Lys.Chemie.P      # v231->Lys.Chemie.P;
    Lys.Chemie.S      # v231->Lys.Chemie.S;
    Lys.Chemie.Al     # v231->Lys.Chemie.Al;
    Lys.Chemie.Cr     # v231->Lys.Chemie.Cr;
    Lys.Chemie.V      # v231->Lys.Chemie.V;
    Lys.Chemie.Nb     # v231->Lys.Chemie.Nb;
    Lys.Chemie.Ti     # v231->Lys.Chemie.Ti;
    Lys.Chemie.N      # v231->Lys.Chemie.N;
    Lys.Chemie.Cu     # v231->Lys.Chemie.Cu;
    Lys.Chemie.Ni     # v231->Lys.Chemie.Ni;
    Lys.Chemie.Mo     # v231->Lys.Chemie.Mo;
    Lys.Chemie.B      # v231->Lys.Chemie.B;
    Lys.Chemie.Frei1  # v231->Lys.Chemie.Frei1;
    Lys.Mech.Sonstiges  # v231->Lys.Mech.Sonstiges;
    Lys.Mech.Sonstiges2 # v231->Lys.Mech.Sonstiges2;
    Lys.Mech.Sonstiges3 # v231->Lys.Mech.Sonstiges3;
    Lys.Mech.Sonstiges4 # v231->Lys.Mech.Sonstiges4;
    Lys.Mech.Sonstiges5 # v231->Lys.Mech.Sonstiges5;
    Lys.Mech.Sonstiges6 # v231->Lys.Mech.Sonstiges6;
    v231C # RecBufCreate(231);
    RecBufCopy(231,v231C);
  end;
  
  RecBufClear(v231);
  if ("MQu.M.GütenID"<>0) then begin
    v231->"Lys.Trägerdatei"     # 833;
    v231->"Lys.Trägernummer1"   # "MQu.M.GütenID";
    v231->"Lys.Trägernummer2"   # "MQu.M.lfdNr";
    vErx # RecRead(v231,2,0);
    if (vErx<=_rMultikey) then begin
      SbrCopy(v231,3, 231,3);   // MECHANIK kopieren
      Lys.Streckgrenze    # v231->Lys.Streckgrenze;
      Lys.Zugfestigkeit   # v231->Lys.Zugfestigkeit;
      Lys.DehnungA        # v231->Lys.DehnungA;
      Lys.DehnungB        # v231->Lys.DehnungB;
      Lys.RP02_1          # v231->Lys.RP02_1;
      Lys.RP10_1          # v231->Lys.RP10_1;
      "Lys.Körnung"       # v231->"Lys.Körnung";
      "Lys.Härte1"        # v231->"Lys.Härte1";
      Lys.Mech.Sonstiges  # v231->Lys.Mech.Sonstiges;
      "Lys.Härte2"        # v231->"Lys.Härte2";
      Lys.RauigkeitA1     # v231->Lys.RauigkeitA1;
      Lys.RauigkeitA2     # v231->Lys.RauigkeitA2;
      Lys.RauigkeitB1     # v231->Lys.RauigkeitB1;
      Lys.RauigkeitB2     # v231->Lys.RauigkeitB2;
      Lys.Streckgrenze2   # v231->Lys.Streckgrenze2;
      Lys.Zugfestigkeit2  # v231->Lys.Zugfestigkeit2;
      Lys.RP02_2          # v231->Lys.RP02_2;
      Lys.RP10_2          # v231->Lys.RP10_2;
      "Lys.Körnung2"      # v231->"Lys.Körnung2";
      "Lys.DehnungC"      # v231->"Lys.DehnungC";
      if (v231C<>0) then begin
        Lys.Mech.Sonstiges  # v231c->Lys.Mech.Sonstiges;   // Nochmal da im anderen TDS
        Lys.Mech.Sonstiges2 # v231c->Lys.Mech.Sonstiges2;
        Lys.Mech.Sonstiges3 # v231c->Lys.Mech.Sonstiges3;
        Lys.Mech.Sonstiges4 # v231c->Lys.Mech.Sonstiges4;
        Lys.Mech.Sonstiges5 # v231c->Lys.Mech.Sonstiges5;
        Lys.Mech.Sonstiges6 # v231c->Lys.Mech.Sonstiges6;
      end;
    end;
  end;

  RecBufDestroy(v231);
  if (v231C<>0) then RecBufDestroy(v231c);

end;


//========================================================================
Sub ExportProc(aTyp : int) : int
local begin
  Erx : int;
end;
begin

  // ERSTER
  if (aTyp=_RecFirst) then begin
    Erx # RecRead(832, 1, _recFirst);
    if (Erx<=_rLocked) then begin
      if (RecLink(833, 832, 1, _recFirst)>_rLocked) then RecbufClear(833);    // Mechanik holen
    end;
    ExportReadLyse();
    RETURN Erx;
  end;

  if ("MQu.M.GütenID"<>0) then begin
    Erx # RecLink(833, 832, 1, _recNext);    // Mechanik holen
    if (Erx<=_rLocked) then RETURN _rOK;
  end;
  Erx # RecRead(832, 1, _recNext);
  if (Erx<=_rLocked) then begin
    if (RecLink(833, 832, 1, _recFirst)>_rLocked) then RecbufClear(833);    // Mechanik holen
  end;
  ExportReadLyse();
  
  RETURN Erx;
end;


//========================================================================
Sub ImportProc() : logic;
local begin
  vErx  : int;
  v231  : int;
end;
begin
  v231 # Recbufcreate(231);
  RecBufCopy(231,v231);
  
  vErx # RekInsert(832,0);      // Güte anlegen

  RecBufClear(231);
  "Lys.Trägerdatei"     # 832;
  "Lys.Trägernummer1"   # MQU.ID;
  SbrCopy(v231,4, 231,4);       // LYS.CHEMIE kopieren
  Lys.Chemie.C      # v231->Lys.Chemie.C;
  Lys.Chemie.Si     # v231->Lys.Chemie.Si;
  Lys.Chemie.Mn     # v231->Lys.Chemie.Mn;
  Lys.Chemie.P      # v231->Lys.Chemie.P;
  Lys.Chemie.S      # v231->Lys.Chemie.S;
  Lys.Chemie.Al     # v231->Lys.Chemie.Al;
  Lys.Chemie.Cr     # v231->Lys.Chemie.Cr;
  Lys.Chemie.V      # v231->Lys.Chemie.V;
  Lys.Chemie.Nb     # v231->Lys.Chemie.Nb;
  Lys.Chemie.Ti     # v231->Lys.Chemie.Ti;
  Lys.Chemie.N      # v231->Lys.Chemie.N;
  Lys.Chemie.Cu     # v231->Lys.Chemie.Cu;
  Lys.Chemie.Ni     # v231->Lys.Chemie.Ni;
  Lys.Chemie.Mo     # v231->Lys.Chemie.Mo;
  Lys.Chemie.B      # v231->Lys.Chemie.B;
  Lys.Chemie.Frei1  # v231->Lys.Chemie.Frei1;
  Lys.Mech.Sonstiges  # v231->Lys.Mech.Sonstiges;
  Lys.Mech.Sonstiges2 # v231->Lys.Mech.Sonstiges2;
  Lys.Mech.Sonstiges3 # v231->Lys.Mech.Sonstiges3;
  Lys.Mech.Sonstiges4 # v231->Lys.Mech.Sonstiges4;
  Lys.Mech.Sonstiges5 # v231->Lys.Mech.Sonstiges5;
  Lys.Mech.Sonstiges6 # v231->Lys.Mech.Sonstiges6;
  RekDelete(231);
  vErx # RekInsert(231,0);      // LYS.CHEMIE anlegen

  if (MQU.M.lfdNr<>0) then begin
    "MQu.M.GütenID"  # MQU.ID;
    vErx # RekInsert(833,0);    // Mechanik anlegen

    RecBufClear(231);
    "Lys.Trägerdatei"     # 833;
    "Lys.Trägernummer1"   # "MQu.M.GütenID";
    "Lys.Trägernummer2"   # "MQu.M.lfdNr";
    SbrCopy(v231,3, 231,3);       // LYS.MECHANIK kopieren
    Lys.Streckgrenze    # v231->Lys.Streckgrenze;
    Lys.Zugfestigkeit   # v231->Lys.Zugfestigkeit;
    Lys.DehnungA        # v231->Lys.DehnungA;
    Lys.DehnungB        # v231->Lys.DehnungB;
    Lys.RP02_1          # v231->Lys.RP02_1;
    Lys.RP10_1          # v231->Lys.RP10_1;
    "Lys.Körnung"       # v231->"Lys.Körnung";
    "Lys.Härte1"        # v231->"Lys.Härte1";
    Lys.Mech.Sonstiges  # v231->Lys.Mech.Sonstiges;
    "Lys.Härte2"        # v231->"Lys.Härte2";
    Lys.RauigkeitA1     # v231->Lys.RauigkeitA1;
    Lys.RauigkeitA2     # v231->Lys.RauigkeitA2;
    Lys.RauigkeitB1     # v231->Lys.RauigkeitB1;
    Lys.RauigkeitB2     # v231->Lys.RauigkeitB2;
    Lys.Streckgrenze2   # v231->Lys.Streckgrenze2;
    Lys.Zugfestigkeit2  # v231->Lys.Zugfestigkeit2;
    Lys.RP02_2          # v231->Lys.RP02_2;
    Lys.RP10_2          # v231->Lys.RP10_2;
    "Lys.Körnung2"      # v231->"Lys.Körnung2";
    "Lys.DehnungC"      # v231->"Lys.DehnungC";
    Lys.Mech.Sonstiges  # '';   // ist bei CHEMIE
    Lys.Mech.Sonstiges2 # '';
    Lys.Mech.Sonstiges3 # '';
    Lys.Mech.Sonstiges4 # '';
    Lys.Mech.Sonstiges5 # '';
    Lys.Mech.Sonstiges6 # '';
    RekDelete(231);
    vErx # RekInsert(231,0);      // LYS.MECHANIK anlegen
  end;
  RecBufDestroy(v231);
//  GV.Alpha.01 # 'x';
  
  RETURN true;
end;


//========================================================================
Sub Import()
local begin
  vName     : alpha(4000);
end;
begin
  vName # Lib_FileIO:FileIO(_WinComFileOpen, gMdi, '', 'CSV-Dateien|*.csv');
  if (vName='') then RETURN;
  If (Msg(998005,vName,_WinIcoQuestion,_WinDialogYesNo,2)=_WinidYes) then begin
//Lib_debug:StartBluemode();
  RekDeleteAll(832);
  RekDeleteAll(833);
    Lib_excel:LiesKombi('Qualitäten+Mechaniken', vName, here+':ImportProc', true);    // leere Felder importieren!!!
  end;

end;

sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin
  if ((aName =^ 'edMQu.NurStufe') AND (aBuf->MQu.NurStufe<>'')) then begin
    RekLink(848,832,2,0);   // Gütenstufe holen
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================