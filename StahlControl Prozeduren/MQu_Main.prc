@A+
//==== Business-Control ==================================================
//
//  Prozedur    MQu_Main
//                  OHNE E_R_G
//  Info
//    Steuert die Qualitätsverwaltung
//
//  06.10.2003  ST  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  25.07.2016  AH  Löschen mit Mechanik
//  25.01.2018  AH  AnalyseErweitert
//  2022-06-28  AH  ERX
//  25.07.2022  HA  Quick jump
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
  cPrefix :   'MQu'
  cZList :    $ZL.Qualitaten
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
  gKey      # cKey;

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
  /*
  if (Mode=c_ModeNew) then begin
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
    MQu.ID # Lib_Nummern:ReadNummer('Qualitäten');    // Nummer lesen
    Lib_Nummern:SaveNummer();

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
local begin
  Erx : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  TRANSON;

  FOR Erx # recLink(833,832,1,_recFirst)
  LOOP Erx # recLink(833,832,1,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(833,0,'MAN');
    if (Erx<>_rOK) then begin
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
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

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

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
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
//========================================================================