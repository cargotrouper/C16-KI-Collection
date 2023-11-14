@A+
//==== Business-Control ==================================================
//
//  Prozedur    Prj_P_Main
//                      OHNE E_R_G
//  Info
//
//
//  18.09.2007  MS  Erstellung der Prozedur
//  20.11.2008  ST  Adressstichwort wird mit in die Optionen übernommen
//  03.02.2009  ST  Eingabe und Lesen von "Resultiert aus" hinzugefügt
//  06.02.2009  ST  Eingabe der Projektnummer für "Resultiert aus" hinzugefügt
//  27.07.2009  ST  DBA Connect für Export über Settings einstellbar
//  13.10.2009  MS  Anker Prj.P.RecInit hinzugefuegt
//  22.02.2012  AI  letzte Aktion(Zeit) wird in RecList angezeigt
//  22.04.2013  AI  Txtread nur im Ansichtsmodus
//  19.02.2014  AH  PosVerschieben schiebt auch Anhänge
//  27.03.2014  AH  Statusänderungen vermerken
//  16.09.2019  ST  Datenexport und -import aktiviert
//  16.03.2022  AH  ERX
//  27.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB Start(opt aRecId : int; opt aPrjNr : int; opt aPrjPos : int; opt aView : logic) : logic;
//    SUB EvtInit(aEvt : event) : logic
//    SUB PosVerschieben()
//    SUB PosUebergabe()
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    sub AusWiedervorlage()
//    sub AusStatus()
//    SUB AusZeiten()
//    SUB AusPrjPText()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB TxtRead()
//    SUB PosVerschieben()
//    SUB Notify(aEmpfaenger : alpha): logic
//    sub AusWiedervorlageCustom ()
//    sub AusSerienMark ()
//    sub AusSerienEdit ()
//    SUB JumpTo(aName : alpha; aBuf  : int);
//
//========================================================================
@I:Def_List
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle      : 'Projekt - Position'
  cFile       :  122
  cMenuName   : 'Prj.P.Bearbeiten'
  cPrefix     : 'Prj_P'
  cZList      : $ZL.Prj.P
  cKey        : 1

  cDialog     : 'Prj.P.Verwaltung'
  cMdiVar     : gMDIPrj
  cRecht      : Rgt_Projekte

  GetWord(a,b)    : a # FldWordbyName('X_'+b);
end;

declare TxtSave();
declare TxtRead();
declare Notify(aNeu : alpha; opt aAlt : alpha): logic;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aPrjNr  : int;
  opt aPrjPos : int;
  opt aPrjSub : int;
  opt aView   : logic) : logic;
local begin
  Erx   : int;
  vQ    : alpha(4000);
end
begin
  if (aRecId=0) and (aPrjNr<>0) then begin
    Prj.P.Nummer      # aPrjNr;
    Prj.P.Position    # aPrjPos;
    Prj.P.SubPosition # aPrjSub;
    Erx # RecRead(122,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(122,_recID);
  end;

  if (App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView)=false) then RETURN false;

  gzllist->wpdbLinkfileno # 0;
  gzllist->wpdbKeyno      # 1;
  gzllist->wpdbfileno     # 122;
  vQ # '';

/*
  vHdl # gZLList->wpDbSelection;
  if ( w_SelName != '' and vHdl != 0 ) then begin
    gZLList->wpAutoUpdate  # false;
    gZLList->wpDbSelection # 0
    SelClose( vHdl );
    SelDelete( gFile, w_selName );
  end;
*/

  Lib_Sel:QInt( var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
  Lib_Sel:QRecList(0,vQ);

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

Lib_Guicom2:Underline($edPrj.P.Status);
Lib_Guicom2:Underline($edPrj.P.WiedervorlUser);

  // Auswahlfelder setzen...
  SetStdAusFeld('edPrj.P.WiedervorlUser' ,'Wiedervorlage');
  SetStdAusFeld('edPrj.P.Status'         ,'Status');
  SetStdAusFeld('edPrj.P.zuProjekt'      ,'ResultiertAusProjekt');


  if (Rechte[Rgt_Prj_Admin]=n) then begin
    $lbPrj.P.Dauer->wpVisible # false;
    $edPrj.P.Dauer->wpVisible # false;
    $lbH2->wpVisible # false;
    $lbPrj.P.Dauer.Intern->wpVisible # false;
    $edPrj.P.Dauer.Intern->wpVisible # false;
    $lbH3->wpVisible # false;
    $lbPrj.P.Dauer.Extern->wpVisible # false;
    $edPrd.P.Dauer.Extern->wpVisible # false;
    $lbH4->wpVisible # false;
    $lbPrj.P.ZusKosten->wpVisible # false;
    $edPrj.P.ZusKosten->wpVisible # false;
    $lbWae1->wpVisible # false;
  end
  else begin
    $clmPrj.P.Dauer->wpVisible # true;
    $clmPrj.P.Dauer.Intern->wpVisible # true;
    $clmPrj.P.Dauer.Extern->wpVisible # true;
  end;
  
  

  RunAFX('Prj.P.Init.Pre',aint(aEvt:Obj));

  RETURN App_Main:EvtInit(aEvt);
end;


//========================================================================
//  PosVerschieben
//              Position in anderes Projekt verschieben
//========================================================================
sub PosVerschieben()
local begin
  Erx             : int;
  vProjektNr_old  : int;
  vProjektPos_old : int;
  vProjektSub_old : int;

  vProjektNr_new  : int;
  vProjektPos_new : word;
  vProjektSub_new : word;

  vTxtBuf         : int;
  vTxtName_old    : alpha;
  vTxtName_new    : alpha;
  v122            : int;
end;
begin

  // Aus gelöschten Projekten nichts verschieben
  if ("Prj.P.Lösch.Datum" <> 0.0.0) then begin
    Msg(120007,AInt(vProjektNr_old),0,0,0);  //  Projekt nicht gefunden oder gelöscht
    RETURN;
  end;

  vProjektNr_old  # Prj.P.Nummer;
  vProjektPos_old # Prj.P.Position;
  vProjektSub_old # Prj.P.SubPosition;

  // Eingabe der neuen Projektnummer
//  if (Dlg_Standard:Anzahl('Projektnummer',var vProjektNr_new) = true) then begin
  if (Dlg_Standard:NrPosPos('Zielprojektposition',var vProjektNr_new, var vProjektPos_new, var vProjektSub_new, vProjektNr_New) = false) then RETURN;


  Prj.Nummer # vProjektNr_new;
  // Neues Projekt darf nicht gelöscht sein
  if (RecRead(120,1,0) = _rOK) AND ("Prj.Löschmarker" = '') then begin

    // Warnung, wenn in dem Zielprojekt Stücklisten vorhanden sind
    if(RecLinkInfo(121,120,2,_recCount)>0) then begin
      if (Msg(120008   ,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then
        RETURN;          // Abbruch
    end;

    TransOn;

    // Neue Positionsnr herausfinden (Neues Projekt ist schon im Puffer)
    if (vProjektPos_new=0) then begin
      Erx # RecLink(122,120,4,_RecLast);
      if (Erx<=_rLocked) then
        vProjektPos_new  # Prj.P.Position + 1
      else
        vProjektpos_new # 1;
    end;

    // ---------- ZEITEN --------------
    Prj.P.Nummer      # vProjektNr_old;
    Prj.P.Position    # vProjektPos_old;
    Prj.P.SubPosition # vProjektSub_old;
    Erx # RecRead(122,1,0);               // Alte Position lesen
    if (Erx <> _rOK) then begin
      TransBrk;
      Msg(120009,AInt(vProjektNr_old),0,0,0);  //  Position nicht lesebar
      RETURN;
    end;

    // Zeiten verschieben
    WHILE (RecLink(123,122,1,_RecFirst) = _rOK) DO BEGIN

      // Sperren
      if (RecRead(123,1,_RecLock) <> _rOK) then begin
        TransBrk;
        Msg(120010,AInt(vProjektNr_old),0,0,0);  //  Zeit nicht sperrbar
        RETURN;
      end;

      // Puffer anpassen
      Prj.Z.Nummer      # vProjektNr_new;
      Prj.Z.Position    # vProjektPos_new;
      Prj.Z.SubPosition # vProjektSub_new;

      // Sichern
      Erx # RekReplace(123,_recUnlock,'AUTO');
      if (Erx <> _rOk) then begin
        TransBrk;
        Msg(120011,AInt(Prj.Z.lfdNr),0,0,0);  //  Zeit nicht verschoben
        RETURN;
      end;

    END;


    // ---------- Texte umbenennen --------------
    vTxtBuf # TextOpen(16);

    // Text 1
    vTxtName_old # Lib_Texte:GetTextName( 122, vProjektNr_old, vProjektPos_old, '1', vProjektSub_old );
    vTxtName_new # Lib_Texte:GetTextName( 122, vProjektNr_new, vProjektPos_new, '1', vProjektSub_New );
    // alten Text
    if (TextRead(vTxtBuf,vTxtName_old,0) = _rOK) then begin
      // unter neuem Namen speichern und alten löschen
      if (TxtWrite(vTxtBuf,vTxtName_new,0) <> _rOK) then begin
          TransBrk;
          Msg(120013,vTxtName_old,0,0,0);  //  Text nicht da
          RETURN;
      end;
      TxtDelete(vTxtName_old,0);
    end;

    // Text 2
    vTxtName_old # Lib_Texte:GetTextName( 122, vProjektNr_old, vProjektPos_old, '2', vProjektSub_old );
    vTxtName_new # Lib_Texte:GetTextName( 122, vProjektNr_new, vProjektPos_new, '2', vProjektSub_new );

    // alten Text
    if (TextRead(vTxtBuf,vTxtName_old,0) = _rOK) then begin
      // unter neuem Namen speichern und alten löschen
      if (TxtWrite(vTxtBuf,vTxtName_new,0) <> _rOK) then begin
          TransBrk;
          Msg(120013,vTxtName_old,0,0,0);  //  Text nicht da
          RETURN;
      end;
      TxtDelete(vTxtName_old,0);
    end;

    // Position verschieben
    Prj.P.Nummer      # vProjektNr_old;
    Prj.P.Position    # vProjektPos_old;
    Prj.P.SubPosition # vProjektSub_old;
    // Lesen & Sperren
    if (RecRead(122,1,_RecLock) <> _rOK) then begin
      TransBrk;
      Msg(120014,'',0,0,0);  //  Position nicht sperrbar
      RETURN;
    end;
    v122 # RekSave(122);

    // Puffer anpassen
    Prj.P.Nummer      # vProjektNr_new;
    Prj.P.Position    # vProjektPos_new;
    Prj.P.SubPosition # vProjektSub_new;

    // Sichern
    Erx # RekReplace(122,_recUnlock,'AUTO');
    if (Erx <> _rOk) then begin
      RekRestore(v122);
      TRANSBRK;
      Msg(120015,'',0,0,0);  //  Position nicht gesichert
      RETURN;
    end;


    if (Anh_Data:CopyAll(v122, 122, y, n)=false) then begin
      RekRestore(v122);
      TRANSBRK;
      Msg(916001,'',0,0,0);
      RETURN;
    end;

    TRANSOFF;

    Notify(Prj.P.WiedervorlUser);

    RecBufDestroy(v122);

    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  end
  else
    Msg(120007,AInt(vProjektNr_new),0,0,0);  // Projekt nicht gefunden oder gelöscht


  Prj.Nummer # vProjektNr_old;
  RecRead(120,1,0)
end;


//========================================================================
// Positionsübergabe extern
//             exportiert markierte Prjpositionen in eine andere Datenbank
//========================================================================
sub PosUebergabe()
local begin
  vPrj         : int;
  vPrjHere     : int;
  vPosHere     : int;
  vBuf2122     : int;
  vBuf2120     : int;
  vMFIle       : int;
  vMID         : int;
  vItem        : int;
  vTxtHdl      : int;
end;
begin
Msg(99,'NICHT MEHR SUPPORTET!',0,0,0);
RETURN;
/****
  if (Dlg_Standard:Anzahl('Projekt-Nummer',var vPrj ,Prj.P.Nummer)) then begin

    Erx # DBAConnect(2,'X_',
                     'TCP:'+StrAdj(Set.DBA.Prj.Srv,_StrBegin | _StrEnd),
                     StrAdj(Set.DBA.Prj.Db,_StrBegin | _StrEnd),
                     gUsername,'','');

    if (Erx<>_rOK) then begin
      TODO('DB-Fehler!');
      RETURN;
    end;

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);

    vBuf2122 # RecBufCreate(122);
    vBuf2120 # RecBufCreate(120);

    TRANSON;

    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 122) then begin
        RecRead(122,0,_RecId,vMID);

        vPrjHere # Prj.P.Nummer;
        vPosHere # Prj.P.Position;

        vBuf2120->Prj.Nummer # vPrj;
        RecBufCopy(vBuf2120,2000 + 120);
        RecRead(2120,1,0);             // Projekt lesen
        RecLink(2122,2120,4,_recLast); // letzte Position holen
        if(Erx>_rLocked) then
          Prj.P.Position # 1;
        else begin
          GetWord(Prj.P.Position,'Prj.P.Position');
          Prj.P.Position # Prj.P.Position + 1;
        end;

        vBuf2122->Prj.P.Nummer           #       vPrj
        vBuf2122->Prj.P.Position         #       Prj.P.Position
        vBuf2122->Prj.P.Bezeichnung      #       Prj.P.Bezeichnung
        vBuf2122->Prj.P.Dauer            #       Prj.P.Dauer
        vBuf2122->Prj.P.Dauer.Intern     #       Prj.P.Dauer.Intern
        vBuf2122->Prj.P.Dauer.Extern     #       Prj.P.Dauer.Extern
        vBuf2122->"Prj.P.Priorität"      #       "Prj.P.Priorität"
        vBuf2122->Prj.P.WiedervorlUser   #       Prj.P.WiedervorlUser
        vBuf2122->Prj.P.Dauer.Angebot    #       Prj.P.Dauer.Angebot
        vBuf2122->Prj.P.Datum.Start      #       Prj.P.Datum.Start
        vBuf2122->Prj.P.Datum.Ende       #       Prj.P.Datum.Ende
        vBuf2122->Prj.P.Status           #       Prj.P.Status
        vBuf2122->Prj.P.Anlage.Datum     #       Prj.P.Anlage.Datum
        vBuf2122->Prj.P.Anlage.Zeit      #       Prj.P.Anlage.Zeit
        vBuf2122->Prj.P.Anlage.User      #       Prj.P.Anlage.User

        vTxtHdl # TextOpen(32);
        TextRead( vTxtHdl,Lib_Texte:GetTextName( 122, vPrjHere, vPosHere, '1' ),0);
        TxtWrite(vTxtHdl,Lib_Texte:GetTextName( 122, vPrj, Prj.P.Position, '1' ),_TextDBA2);
        TextRead( vTxtHdl,Lib_Texte:GetTextName( 122, vPrjHere, vPosHere, '2' ),0);
        TxtWrite(vTxtHdl,Lib_Texte:GetTextName( 122, vPrj, Prj.P.Position, '2' ),_TextDBA2);
        TextClose(vTxtHdl);

        RecBufCopy(vBuf2122,2000 + 122);
        Erx # RekInsert(2122,0,'AUTO');
        if (Erx<>_rOK) then begin
          RecBufDestroy(vBuf2122);
          RecBufDestroy(vBuf2120);
          DBADisconnect(2)
          TRANSBRK;
          Msg(999999,'Pos. nicht anlegbar',0,0,0);
          RETURN;
        end;

        vItem # gMarkList->CteRead(_CteNext,vItem);

      end;
    END;

    TRANSOFF;

    RecBufDestroy(vBuf2120);
    RecBufDestroy(vBuf2122);
    DBADisconnect(2);

    Msg(99,'Position(en) wurden angelegt',0,0,0);

  end;
***/
end;


//========================================================================
//========================================================================
sub SubPosition()
local begin
  vNr : int;
end;
begin
  if (Dlg_standard:Anzahl(Translate('Unterposition'),var vNr)=false) then RETURN;
  if (vNr<=0) or (vNr>=10000) then RETURN;

  w_AppendNr # (Prj.P.Position * 10000) + vNr;
  App_Main:Action(c_ModeNew);
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
  Erx       : int;
  vTxtHdl   : int;
  vIstDauer : int;
  vHdl      : int;
  vTmp      : int;
end;
begin

  if (aName='') then begin
    $edPrj.P.Status->wpHelptip # '';
    if (Prj.P.Status.Datum<>0.0.0) then
      $edPrj.P.Status->wpHelptip # Translate('seit')+' '+cnvad(Prj.P.Status.Datum)+' '+cnvat(Prj.P.Status.Zeit)+' '+Prj.P.Status.User;
  end;

  //if (aName='') or (aName='edAdr.EK.Zahlungsbed') then begin
  if (aName='') or (aName='edPrj.P.Status') then begin
    Erx # RecLink(850,122,3,0);
    if (Erx<=_rLocked) then
      $Lb.Status->wpcaption # Stt.Bezeichnung
    else
      $Lb.Status->wpcaption # '';
  end;

  // Austauschprojekt [21.01.2010/PW]
  if ( Prj.AustauschYN ) then
    $lbPrj.P.BeschreibungText1->wpCaption # 'Zusätzliche Info';

  // Kundenstichwort anzeigen
  $lb.KdStichwort->wpcaption # Prj.Adressstichwort;


  // ST 2009-02-02   "Resultiert aus" Anzeigen
  $lb.ResPosBezeichnung->wpCaption # '';

  if (Prj.P.zuProjekt > 0) AND (Prj.P.zuPosition > 0) then begin

    // Buffer für "fremde" Position anlegen, damit
    // der aktuelle Puffer nicht überschrieben wird
    vHdl # RecBufCreate(122);

    // Resultierende Position übergeben...
    vHdl->Prj.P.Nummer      # Prj.P.zuProjekt;
    vHdl->Prj.P.Position    # Prj.P.zuPosition;
    vHdl->Prj.P.SubPosition # Prj.P.zuSubPosition;

    // ... und in den Buffer lesen
    if (RecRead(vHdl,1,0) <= _rLocked) then

      //  Bezeichnung aus dem neuen Puffer an den Dialog weitergeben
      $lb.ResPosBezeichnung->wpCaption # vHdl->Prj.P.Bezeichnung;

    // RecBuffer wieder löschen
    RecBufDestroy(vHdl);

  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;


  if (aName='') then begin
    vTxtHdl # $Prj.P.Text1->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Prj.P.Text1->wpdbTextBuf # vTxtHdl;
    end;

    vTxtHdl # $Prj.P.Text2->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Prj.P.Text2->wpdbTextBuf # vTxtHdl;
    end;

    if (mode=c_Modeview) then TxtRead();
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Lib_GuiCom:Pflichtfeld($edPrj.P.WiedervorlUser);
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
  Erx   : int;
  vPos  : int;
  v980  : int;
  vHdl  : int;
  vFoc  : int;
end;
begin

  if (RunAFX('Prj.P.RecInit','') < 0) then RETURN;

  vFoc # $edPrj.P.Status;

  // Neuanlage?
  if (Mode=c_ModeNew) then begin
    Erx # RecLink(122,120,4,_recLast); // letzte Position holen
    if (Erx>_rLocked) then vPos # 1    // keine gefunden, dann mit 1 starten
    else vPos # Prj.P.Position + 1;    // sonst um 1 erhöhen

    RecBufClear(122);
    Prj.P.Nummer        # Prj.Nummer;
    Prj.P.Position      # vPos;

    // Anhängen???
    if (w_AppendNr<>0) then begin
      Prj.P.Position      # w_appendNr div 10000;
      Prj.P.SubPosition   # w_appendNr % 10000;
      w_appendnr # 0;
    end;
  
    vHdl # $Prj.P.Text1->wpdbTextBuf;
    if (vHdl<>0) then TextClear(vHdl);
    $Prj.P.Text1->WinUpdate(_WinUpdBuf2Obj);

    vHdl # $Prj.P.Text2->wpdbTextBuf;
    if (vHdl<>0) then TextClear(vHdl);
    $Prj.P.Text2->WinUpdate(_WinUpdBuf2Obj);


    if (w_Command='AUS_TEM') then begin
      v980 # RecBufCreate(980);
      RecRead(v980,0,_recId, cnvia(w_Cmd_Para));
      Prj.P.Bezeichnung     # v980->Tem.Bemerkung;
      Prj.P.Status          # 110;
      Prj.P.WiedervorlUser  # gUsername;

      vHdl # $Prj.P.Text1->wpDbTextBuf;
      if (vHdl=0) then begin
        vHdl # TextOpen(32);
        $Prj.P.Text1->wpdbTextBuf # vHdl;
      end;

      TextLineWrite(vHdl,1, v980->Tem.Bemerkung, _TextLineInsert);
      $Prj.P.Text1->WinUpdate(_WinUpdBuf2Obj);
      RecbufDestroy(v980);
      vFoc # $Prj.P.Text1;
    end;
  end;


  if (RecLinkInfo(123,122,1,_recCount)>0) then begin
    Lib_GuiCom:Disable($edPrj.P.Dauer.Intern);
    Lib_GuiCom:Disable($edPrj.P.ZusKosten);
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  vFoc->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  v980  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (Prj.P.WiedervorlUser='') then begin
    Msg(001200,Translate('Wiedervorlage'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edPrj.P.WiedervorlUser->WinFocusSet(true);
    RETURN false;
  end;

  // Sonderfunktion:
  if (RunAFX('Prj.P.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then begin
      RETURN False;
    end;
  end;


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    // Statusänderungen vermerken
    if (ProtokollBuffer[122]->"Prj.P.Status"<>"Prj.P.Status") then begin
      Prj.P.Status.Datum  # today;
      Prj.P.Status.Zeit   # now;
      Prj.P.Status.User   # gUsername;
    end;

   //"Prj.P.Änderung.Datum"  # Today;
   //"Prj.P.Änderung.Zeit"   # Now;
   //"Prj.P.Änderung.User"   # gUserName;
    Erx # RekReplace(gFile, _recUnlock, 'MAN', gZLList->wpdbSelection);
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Bei Änderung an der Wiedervorlage, Message schreiben
    if (Prj.VorlageYN=false) then
      Notify(Prj.P.WiedervorlUser, ProtokollBuffer[122]->Prj.P.WiedervorlUser);


    if (ProtokollBuffer[122]->"Prj.P.Priorität"<>"Prj.P.Priorität") then
      "Prj.P.PrioritätDatum" # today;

    PtD_Main:Compare(gFile);
  end
  else begin  // NEUANALGE
    If (Prj.P.Position<0) or (Prj.P.Position>9999) then begin
      Msg(001200,Translate('Position'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edPrj.P.Position->WinFocusSet(true);
      RETURN false;
    end;

    Prj.P.Anlage.Datum      # Today;
    Prj.P.Anlage.Zeit       # Now;
    Prj.P.Anlage.User       # gUserName;
    "Prj.P.PrioritätDatum"  # today;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Message bei neuer Position erstellen
    if (Prj.VorlageYN=false) then
      Notify(Prj.P.WiedervorlUser);
  end;

  TxtSave();

  if (w_Command='AUS_TEM') then begin
    w_Command   # '';
    w_Cmd_para  # '';

    v980 # RecBufCreate(980);
    Erx # RecRead(v980,0,_recId, cnvia(w_Cmd_Para));
    if (Erx<=_rLocked) then
      TeM_A_Data:Anker(122,'MAN');
      //TeM_A_Data:New(122,'MAN');
    RecBufDestroy(v980);

  end;

  // Sonderfunktion:
  RunAFX('Prj.P.RecSave.Post','');

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
  Erx           : int;
  vA            : alpha;
  vHdl          : int;
  vTxtHdl_L1    : int;
end;
begin
  // Satz bisher nicht gelöscht??
  if ("Prj.P.Lösch.Datum"=0.0.0) then begin

    // Löschmarker umsetzen?
    if (Msg(000008,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

    if (Dlg_standard:Standard(Translate('Löschgrund'), var vA, false, 32)=true) then begin

      if (vA='') then begin
        Msg(001200,Translate('Löschgrund'),0,0,0);
        RETURN;
      end;

      // Löschdaten speichern
      RecRead(122,1,_recLock);
      "Prj.P.Lösch.Grund" # vA;
      "Prj.P.Lösch.User"  # gUserName;
      "Prj.P.Lösch.Datum" # Today;
      Erx # RekReplace(122,_recUnlock,'MAN');
      if (Erx<>_rOK) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;

      vA # AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position);
      if (Prj.P.SubPosition>0) then
        vA # vA + '/'+aint(Prj.P.SubPosition);
      Lib_Notifier:RemoveAllEvents('122>800/'+vA,0);
    end;

    RETURN;
  end;

  // Satz bereits gelöscht!
  if ("Prj.Löschmarker"='*') then begin
    Msg(120005,'',0,0,0);
    RETURN;
  end;

  // Löschmarker umsetzen?
  if (Msg(000008,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RecRead(122,1,_recLock);
  "Prj.P.Lösch.Grund" # '';
  "Prj.P.Lösch.User"  # '';
  "Prj.P.Lösch.Datum" # 0.0.0;
  if (Set.Installname='BCS') then begin
    if (FldInfoByName('Prj.P.Cust.ArchivDat',_FldExists)=1) then
      FldDefByName('Prj.P.Cust.ArchivDat',0.0.0);
  end;
  Erx# RekReplace(122,_recUnlock,'MAN');
  if (erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
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
  vA    : alpha;

  vSel  :   int;

end;

begin

  case aBereich of
    'Wiedervorlage' : begin
      RecBufClear(800);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusWiedervorlage');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Status' : begin
      RecBufClear(850);        //  Zielbuffer  leeren
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VgSt.Verwaltung',here+':AusStatus');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ResultiertAusProjekt' : begin
      RecBufClear(120);        //  Zielbuffer  leeren
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Prj.Verwaltung',here+':AusResultiertAusProjekt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    // Dialog: Serienmarkierung und Serienänderung [13.10.2009/PW]
    'WiedervorlageCustom' : begin
      RecBufClear( 800 ); // Zielbuffer leeren
      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Usr.Verwaltung', here + ':AusWiedervorlageCustom' );
      Lib_GuiCom:RunChildWindow( gMDI );
    end;
  end;

end;


//========================================================================
//  AusWiedervorlage
//
//========================================================================
sub AusWiedervorlage()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    Prj.P.WiedervorlUser    # Usr.Username;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();

  $edPrj.P.WiedervorlUser->Winfocusset();
end;


//========================================================================
//  AusStatus
//
//========================================================================
sub AusStatus()
begin
  if (gSelected<>0) then begin
    RecRead(850,0,_RecId,gSelected);
    Prj.P.Status    # Stt.Nummer;
  end;
  $edPrj.P.Status->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edPrj.P.Status');
end;


//========================================================================
//  AusResultiertAusProjekt
//
//========================================================================
sub AusResultiertAusProjekt()
begin
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    Prj.P.zuProjekt  # Prj.Nummer;
  end;
  $edPrj.P.zuProjekt->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edPrj.P.zuProjekt');
end;


//========================================================================
//  AusZeiten
//
//========================================================================
sub AusZeiten()
begin
  gSelected # 0;
  RecRead(122,1,0);
  $edPrj.P.Dauer->WinUpdate(_WinUpdFld2Obj);
  $edPrj.P.Dauer.Intern->WinUpdate(_WinUpdFld2Obj);
  $edPrj.P.ZusKosten->WinUpdate(_WinUpdFld2Obj);
  $edPrj.P.ZusKosten.Plan->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vOK         : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  if (Prj.P.Nummer<>0) and (Mode<>c_ModeNew) and (mode<>c_ModeNew2) and (Mode<>c_modeedit) then
    RecLink(120,122,2,_RecFirst);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or /*(gZLList->wpdbselection<>0) or*/ (Rechte[Rgt_Prj_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or /*(gZLList->wpdbselection<>0) or*/ (Rechte[Rgt_Prj_P_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_P_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_P_Aendern]=n);

  vOK # ((Mode=c_ModeList) and (w_Auswahlmode=n)) or (Mode=c_ModeNew2) or (Mode=c_ModeEdList) or (Mode=c_ModeView);
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (!vOk) or (Rechte[Rgt_Prj_P_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (!vOK) or (Rechte[Rgt_Prj_P_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Zeit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_PrjZeiten]=n) or (Mode=c_ModeEdit) or (Mode=c_ModeNew)


  vHdl # gMenu->WinSearch('Mnu.Aktivitaeten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Termine]=false);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Mat_Excel_Export]=false;

  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Mat_Excel_Import]=false;

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
  vDat  : date;
  vA    : alpha;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Ktx.Stamp' : begin
      aEvt:obj->WinUpdate(_WinUpdObj2Buf);
      vHdl # aEvt:OBj->wpDbTextBuf;
      if (vHdl<>0) then begin
        vDat # today;
        vA # cnvai(vDat->vpyear, _FmtNumNoGroup)+'-'+cnvai(vDat->vpmonth,_FmtNumLeadZero,0,2)+'-'+cnvai(vDat->vpday, _FmtNumLeadZero,0,2);
        vA # vA + ' '+gUsername+': ';

        if (aEvt:Obj->wpName='Prj.P.Text2') then begin
          if (Set.Installname='BCS') and (TextSearch(vHdl, 1,1, _TextSearchCI, '!!! ACHTUNG - HOTLINEVERTRAG :')=0) then
            TextLineWrite(vHdl,1,vA, _TextLineInsert)
          else
            TextLineWrite(vHdl,2,vA, _TextLineInsert);
        end
        else
          TextLineWrite(vHdl, TextInfo(vHdl,_textLines)+1,vA, _TextLineInsert);

        aEvt:obj->WinUpdate(_WinUpdBuf2Obj);
      end;
    end;


    'Mnu.PosVerschieben' : begin
      PosVerschieben();
    end;


    'Mnu.PosUebergabe' : begin
      PosUebergabe();
    end;


    'Mnu.PosAppend' : begin
      SubPosition();
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(122);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Prj.P.Anlage.Datum, Prj.P.Anlage.Zeit, Prj.P.Anlage.User, "Prj.P.Lösch.Datum", "Prj.P.Lösch.Zeit", "Prj.P.Lösch.User", "Prj.P.Lösch.Grund");
    end;


    'Mnu.NextPage' : begin
      vHdl # gMdi->Winsearch('NB.Main');
      if (Mode=c_ModeView) then begin
        vTmp # gMdi->winsearch('Edit');
        if (vTmp->wpdisabled) then
          if (gMdi->winsearch('EditErsatz')<>0) then
            vTmp # gMdi->winsearch('EditErsatz');
        vTmp->WinFocusSet(false);
      end;
    end;


    'Mnu.PrevPage' : begin
      vHdl # gMdi->Winsearch('NB.Main');
      if (Mode=c_ModeView) then begin
        vTmp # gMdi->winsearch('Edit');
        if (vTmp->wpdisabled) then
          if (gMdi->winsearch('EditErsatz')<>0) then
            vTmp # gMdi->winsearch('EditErsatz');
        vTmp->WinFocusSet(false);
      end;
    end;


    'Mnu.Mark.Sel' : begin
      // Serienmarkierung; Selektionsdialog [13.10.2009/PW]
      GV.Ints.01  # 0;     // Status
      GV.Ints.02  # 0;     // Priorität von
      GV.Ints.03  # 99;    // Priorität bis
      GV.Alpha.02 # '';    // Wiedervorlage
      GV.Alpha.03 # '';    // Bezeichnung
      GV.Logic.01 # true;  // aktuelle Selektion berücksichtigen
      GV.Logic.02 # false; // gelöschte Projektpunkte

      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.Mark.PrjP', here + ':AusSerienMark' );
      Lib_GuiCom:RunChildWindow( gMDI );
    end;


    'Mnu.Mark.SetField' : begin
      // Serienänderung; Änderungsdialog [13.10.2009/PW]
      GV.Int.01   # -1; // Status
      GV.Int.02   # -1; // Priorität
      GV.Alpha.02 # ''; // Wiedervorlage
      GV.Alpha.03 # ''; // Bezeichnungssuffix
      GV.Alpha.04 # ''; // Interne Info

      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Prj.P.EditMaske', here + ':AusSerienEdit' );
      Lib_GuiCom:RunChildWindow( gMDI );
    end;


    'Mnu.Zeit' : begin
      RecBufClear(123);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Prj.Z.Verwaltung',here+':AusZeiten',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    // Projektblatt [28.05.2010/PW]
    'Mnu.Druck.PrjBlatt' : begin
      vHdl # RekSave( 122 );
      Lib_Dokumente:PrintForm(122, 'Projektblatt', false);
      RekRestore( vHdl );
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
    'bt.Wiedervorlage'        : Auswahl('Wiedervorlage');
    'bt.Status'               : Auswahl('Status');
    'bt.ResultiertAusProjekt' : Auswahl('ResultiertAusProjekt');

    // Dialog: Serienmarkierung und Serienänderung [13.10.2009/PW]
    'btPrj.P.Wiedervorlage'   : Auswahl('WiedervorlageCustom');
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
  vI  : int;
end;
begin

  // letzte Zeit holen
  Erx # RecLink(123,122,1,_recLast);
  if (Erx<>_rOK) then RecBufClear(123);


  if (aMark=n) then begin
    if ("Prj.P.Lösch.Datum">0.0.0) then begin
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
    end
    else begin
      Erx # RecLink(850, 122, 3, _recFirst); // Status holen
      if(Erx <= _rLocked) then
        Lib_GuiCom:ZLColorLine(gZLList, Stt.Color);
    end;
  end;

  begin // ST 2010-04-23: Farbanpassung des Datums

    // Beide Termine ausgefüllt -> Bearbeitungszeitraum
    if (Prj.P.Datum.Start != 0.0.0) AND (Prj.P.Datum.Ende != 0.0.0) then begin
      // Ende wurde überschritten
      if (Prj.P.Datum.Ende < SysDate()) then
        $clmPrj.P.Termin.Bis->wpClmColBkg # RGB(250,0,0);

    end;

    // Nur Ende gefüllt: Stichtag
    if (Prj.P.Datum.Start = 0.0.0)AND (Prj.P.Datum.Ende != 0.0.0) then begin
      // Stichtag wurde überschritten
      if (Prj.P.Datum.Ende < SysDate()) then
        $clmPrj.P.Termin.Von->wpClmColBkg # RGB(250,0,0);
    end;

    // Nur Anfang gefüllt: Starttermin
    // Beide Termine ausgefüllt -> Bearbeitungszeitraum
    if (Prj.P.Datum.Start != 0.0.0)AND (Prj.P.Datum.Ende = 0.0.0) then begin
      // Start wurde überschritten
      if (Prj.P.Datum.Start < SysDate()) then
        $clmPrj.P.Termin.Von->wpClmColBkg # RGB(250,0,0);
    end;
  end;

  vI # "Prj.P.Priorität";
  if (vI<0) then vI # 0;
  if (vI>12) then vI # 12;
  $clmPrj.P.Prioritt->wpClmColBkg # RGB(250,250-(20*vI),250-(20*vI));
  RecLink(120,122,2,_recFirst); // Projekt holen

  Gv.ALpha.01 # aint(Prj.P.Status);
  if (Prj.P.Status.Datum<>0.0.0) then
    Gv.ALpha.01 # Gv.Alpha.01 + '   '+cnvad(Prj.P.Status.Datum);
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

// AI  RecRead(gFile,0,_recid,aRecID);

end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTxtHdl : int;
end;
begin
  vTxtHdl # $Prj.P.Text1->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);

  vTxtHdl # $Prj.P.Text2->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);

  RETURN true;
end;


//========================================================================
// TxtRead
//              Texte auslesen
//========================================================================
sub TxtRead()
local begin
  vTxtHdl_L1             : int;         // Handle des Textes
  vTxtHdl_L2             : int;         // Handle des Textes
  vTxtHdl_L3             : int;         // Handle des Textes
  vTxtHdl_L4             : int;         // Handle des Textes
  vTxtHdl_L5             : int;         // Handle des Textes
end
begin

  if (Mode=c_ModeEdit) then RETURN

  // Prj.P-Text1(Beschreibung) laden
  vTxtHdl_L1 # $Prj.P.Text1->wpdbTextBuf;
  Lib_Texte:TxtLoad5Buf(Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1', Prj.P.SubPosition ), vTxtHdl_L1, 0 ,0, 0, 0);

  // Textpuffer an Felderübergeben
  $Prj.P.Text1->wpdbTextBuf # vTxtHdl_L1;
  $Prj.P.Text1->WinUpdate(_WinUpdBuf2Obj);

  // Prj.P-Text2(Interne Info) laden
  vTxtHdl_L1 # $Prj.P.Text2->wpdbTextBuf;
  Lib_Texte:TxtLoad5Buf(Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2', Prj.P.SubPosition ), vTxtHdl_L1, 0 ,0, 0, 0);

  // Textpuffer an Felderübergeben
  $Prj.P.Text2->wpdbTextBuf # vTxtHdl_L1;
  $Prj.P.Text2->WinUpdate(_WinUpdBuf2Obj);


end;


//========================================================================
// TxtSave
//              Text abspeichern
//========================================================================
sub TxtSave()
local begin
  vTxtHdl_L1             : int;         // Handle des Textes
  vTxtHdl_L2             : int;         // Handle des Textes
  vTxtHdl_L3             : int;         // Handle des Textes
  vTxtHdl_L4             : int;         // Handle des Textes
  vTxtHdl_L5             : int;         // Handle des Textes
end
begin

  vTxtHdl_L1 # $Prj.P.Text1->wpdbTextBuf;
  $Prj.P.Text1->WinUpdate(_WinUpdObj2Buf);
  Lib_Texte:TxtSave5Buf(Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1', Prj.P.SubPosition ), vTxtHdl_L1, 0,0,0,0);

  vTxtHdl_L1 # $Prj.P.Text2->wpdbTextBuf;
  $Prj.P.Text2->WinUpdate(_WinUpdObj2Buf);
  Lib_Texte:TxtSave5Buf(Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2', Prj.P.SubPosition ), vTxtHdl_L1, 0,0,0,0);

END;


//========================================================================
// Notify
//              Erstellt eine Notifiermessage zur aktuellen Position
//========================================================================
sub Notify(
  aNeu        : alpha;
  opt aAlt    : alpha;
  ): logic
local begin
  Erx         : int;
  vMax        : int;
  i           : int;
  vUsr        : alpha;
  vPrio       : word;
  vA          : alpha;
end
begin
  // alle möglichen Tokens bereinigen
  aNeu # Str_ReplaceAll( aNeu, '/', '|' );
  aNeu # Str_ReplaceAll( aNeu, ',', '|' );
  aNeu # Str_ReplaceAll( aNeu, ' ', '|' );
  aNeu # Str_ReplaceAll( aNeu, ';', '|' );
  // |AH|UB|
  if (aNeu<>'') then aNeu # '|'+aNeu+'|';


  aAlt # Str_ReplaceAll( aAlt, '/', '|' );
  aAlt # Str_ReplaceAll( aAlt, ',', '|' );
  aAlt # Str_ReplaceAll( aAlt, ' ', '|' );
  aAlt # Str_ReplaceAll( aAlt, ';', '|' );
  // |AH|UB|
  if (aAlt<>'') then aAlt # '|'+aAlt+'|';


  // Anzahl der ALT-Tokens bestimmen und falls nicht auch neu dann austragen...
  vMax # Lib_Strings:Strings_Count( aAlt, '|' ) - 1;
  FOR  i # 1
  LOOP inc(i);
  WHILE ( i <= vMax ) DO BEGIN
    vUsr # StrCnv( Lib_Strings:Strings_Token( aAlt, '|', i+1 ), _strUpper );
//debug('suche |'+vUsr+'|   in neu '+aNeu);
    if (StrFind(aNeu,'|'+vUsr+'|',0)>0) then CYCLE;
//debug('REMOVE');
    vA # AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position);
    if (Prj.P.SubPosition>0) then
      vA # vA + '/'+aint(Prj.P.SubPosition);
    Lib_Notifier:RemoveOneEvent('122>800/'+vA, 0, vUsr);
  END;


  // Anzahl der NEU-Tokens bestimmen und NEUE eintragen...
  vMax # Lib_Strings:Strings_Count( aNeu, '|' ) - 1;
  FOR  i # 1
  LOOP inc(i);
  WHILE ( i <= vMax ) DO BEGIN
    vUsr # StrCnv( Lib_Strings:Strings_Token( aNeu, '|', i+1 ), _strUpper );
//debug('suche |'+vUsr+'|   in alt '+aAlt);
    if (StrFind(aAlt,'|'+vUsr+'|',0)>0) then CYCLE;
//debug('NOTIFY');
    // prüfen ob User existiert
    Usr.Username # vUsr;
    Erx # RecRead( 800, 1, 0 );
    if ( Erx <= _rLocked ) then begin
      RekLink( 120, 122, 2, 0 );  // Projektkopfdaten holen
      if (Prj.P.Status=1) then vPrio # 1;

      vA # AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position);
      if (Prj.P.SubPosition>0) then
        vA # vA + '/'+aint(Prj.P.SubPosition);
      Lib_Notifier:NewEvent(vUsr, '122>800/'+vA, vA+' '+Prj.Adressstichwort + ':'+Prj.P.Bezeichnung, 0, today, now,vPrio);
    end;
  END;

/***
  vWarDabei # Lib_Notifier:Exists('122>800/'+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position), 0, gUsername);
  if (vWarDabei) and (vSollDabei) then begin
    Lib_Notifier:RemoveAllEvents('122>800/'+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position), 0, gUsername);
  end
  else begin
    Lib_Notifier:RemoveAllEvents('122>800/'+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position), 0);
  end;

  FOR  i # 1
  LOOP i # i + 1
  WHILE ( i <= vMax ) DO BEGIN
    vUsr # StrCnv( Lib_Strings:Strings_Token( aEmpfaenger, '|', i ), _strUpper );

    // sich selbst keine Message schicken
    //if ( vUsr = gUsername) then CYCLE;
    if ( vUsr = gUsername) and (vWarDabei) then CYCLE;

    // prüfen ob User existiert
    Usr.Username # vUsr;
    Erx # RecRead( 800, 1, 0 );
    if ( Erx <= _rLocked ) then begin
      // Projektkopfdaten lesen
      if ( RecLink( 120, 122, 2, 0 ) > _rLocked ) then
        RecBufClear( 120 );

      // Notifier
      //Lib_Notifier:NewPrjNote( vUsr, Prj.P.Nummer, Prj.P.Position );
      // interner Notifier...
      if (Prj.P.Status=1) then vPrio # 1;

//      Lib_Notifier:NewEvent(vUsr,
//                            '122>800/'+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position),
//                            'Prj.'+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position)+' '+Prj.Adressstichwort + ':'+Prj.P.Bezeichnung, 0, today, now,vPrio);
      Lib_Notifier:NewEvent(vUsr,
                            '122>800/'+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position),
                            ''+AInt(Prj.P.Nummer)+'/'+AInt(Prj.P.Position)+' '+Prj.Adressstichwort + ':'+Prj.P.Bezeichnung, 0, today, now,vPrio);
    end;

  END;
***/
  Usr.Username # gUsername;
  RecRead( 800, 1, 0 );

  RETURN true;

end;


//========================================================================
//  AusWiedervorlageCustom [13.10.2009/PW]
//
//========================================================================
sub AusWiedervorlageCustom ()
begin
  if ( gSelected != 0 ) then begin
    RecRead( 800, 0, _recId, gSelected );
    $edPrj.P.Wiedervorlage->wpCaption # Usr.Username;
    $edPrj.P.Wiedervorlage->WinUpdate( _winUpdObj2Fld );

    Usr.Username # gUsername;
    RecRead( 800, 1, 0 );
    gSelected # 0;
  end;
  $edPrj.P.Wiedervorlage->WinFocusSet();
end;


//========================================================================
//  AusSerienMark [13.10.2009/PW]
//
//========================================================================
sub AusSerienMark ()
local begin
  Erx       : int;
  vSel     : int;
  vSelName : alpha;
  vQ       : alpha(500);
  vQ2      : alpha(500);

  vListHdl : handle;
  vA : alpha;
  vB : alpha;
  vI : int;
end;
begin
  vListHdl # gZlList;
  vListHdl->wpDisabled # false;
  Lib_GuiCom:SetWindowState( gMDI, true );

  /* Selektion */
  if ( GV.Ints.01 != 0 ) then // Status
    Lib_Sel:QInt( var vQ, 'Prj.P.Status', '=', GV.Ints.01 );
  if ( GV.Ints.02 != 0 ) or ( GV.Ints.03 != 99 ) then // Priorität von/bis
    Lib_Sel:QVonBisI( var vQ, 'Prj.P.Priorität', GV.Ints.02, GV.Ints.03 );
  if ( !GV.Logic.02 ) then // (nicht) gelöschte Projektpunkte
    Lib_Sel:QDate( var vQ, 'Prj.P.Lösch.Datum', '=', 0.0.0 );
  if ( GV.Alpha.03 != '' ) then begin // Bezeichnung
    Lib_Sel:QAlpha( var vQ, 'Prj.P.Bezeichnung', '=*', GV.Alpha.03 );
  end;

  // Wiedervorlage
  if ( GV.Alpha.02 != '' ) then begin
    if ( StrFind( GV.Alpha.02, ',', 1 ) > 0 ) then begin
      vA # GV.Alpha.02;
      vI # StrFind( vA, ',', 1 );

      WHILE ( vI > 0 ) DO BEGIN
        vB # StrAdj( StrCut( vA, 1, vI - 1 ), _strAll );
        vA # StrAdj( StrDel( vA, 1, vI ), _strAll );
        vI # StrFind( vA, ',', 1 );

        Lib_Sel:QenthaeltA( var vQ2, 'Prj.P.WiedervorlUser', vB, 'OR' );
      END;
      Lib_Sel:QenthaeltA( var vQ2, 'Prj.P.WiedervorlUser', vA, 'OR' );
    end
    else if ( StrFind( GV.Alpha.03, ' ', 1 ) > 0 ) then begin
      vA # GV.Alpha.02;
      vI # StrFind( vA, ' ', 1 );

      WHILE ( vI > 0 ) DO BEGIN
        vB # StrAdj( StrCut( vA, 1, vI - 1 ), _strAll );
        vA # StrAdj( StrDel( vA, 1, vI ), _strAll );
        vI # StrFind( vA, ' ', 1 );

        Lib_Sel:QenthaeltA( var vQ2, 'Prj.P.WiedervorlUser', vB, 'OR' );
      END;
      Lib_Sel:QenthaeltA( var vQ2, 'Prj.P.WiedervorlUser', vA, 'OR' );
    end
    else
      Lib_Sel:QenthaeltA( var vQ2, 'Prj.P.WiedervorlUser', GV.Alpha.02 );
    vQ # vQ + ' AND ( ' + vQ2 + ' )'
  end;

  // Selektion durchführen
  vSel # SelCreate( 122, 1 );
  vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // aktuelle Selektion berücksichtigen
  if ( vListHdl->wpDbSelection != 0 ) and ( GV.Logic.01 ) then
    vSel->SelRun( _selDisplay | _selServer | _selServerAutoFld | _selInter, SelInfoAlpha( vListHdl->wpDbSelection, _selName ) );

  // Ergebnisse markieren
  FOR  Erx # RecRead( 122, vSel, _recFirst );
  LOOP Erx # RecRead( 122, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Lib_Mark:MarkAdd( 122, true, true );
  END;

  // Selektion entfernen
  SelClose( vSel );
  SelDelete( 122, vSelName );

  vListHdl->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );
end;


//========================================================================
//  AusSerienEdit [13.10.2009/PW]
//
//========================================================================
sub AusSerienEdit ()
local begin
  erx       : int;
  vItem     : handle;
  vTextHdl  : handle;
  vText     : alpha;
  vMFile    : int;
  vMId      : int;
  vCount    : int;
end;
begin
  TRANSON;
  vCount # 0;

  FOR  vItem # gMarkList->CteRead( _cteFirst );
  LOOP vItem # gMarkList->CteRead( _cteNext, vItem );
  WHILE ( vItem > 0 ) DO BEGIN
    Lib_Mark:TokenMark( vItem, var vMFile, var vMID );
    if ( vMFile != 122 ) then
      CYCLE;

    Erx # RecRead( 122, 0, _recLock, vMID );
    PtD_Main:Memorize( 122 );

    if ( Erx = _rOK ) then begin
      if ( GV.Int.01 != -1 ) then // Status
        "Prj.P.Status" # GV.Int.01;
      if ( GV.Int.02 != -1 ) then // Priorität
        "Prj.P.Priorität" # GV.Int.02;
      if ( GV.Alpha.02 != '' ) then // Wiedervorlage
        "Prj.P.WiedervorlUser" # GV.Alpha.02;
      if ( GV.Alpha.03 != '' ) then // Bezeichnungssuffix
        "Prj.P.Bezeichnung" # "Prj.P.Bezeichnung" + GV.Alpha.03;

      // Interne Info hinzufügen
      if ( GV.Alpha.04 != '' ) then begin
        vTextHdl # TextOpen( 32 );
        vText    # Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2', Prj.P.SubPosition );
        Lib_Texte:TxtLoad5Buf( vText, vTextHdl, 0, 0, 0, 0 );
        vTextHdl->TextLineWrite( 1, GV.Alpha.04, _textLineInsert );
        Lib_Texte:TxtSave5Buf( vText, vTextHdl, 0, 0, 0, 0 );
        vTextHdl->TextClose();
      end;

      // Änderungen speichern
      Erx # RekReplace( 122, _recUnlock,'AUTO' );
      if ( Erx != _rOk ) then begin
        PtD_main:Forget( 122 );
        BREAK;
      end
      PtD_Main:Compare( 122 );
    end;
    vCount # vCount + 1;
  END;

  if ( vCount = 0 ) then begin
    TRANSBRK;
    Msg( 997006, '', 0, 0, 0 );
  end
  else if ( Erx != _rOk ) then begin
    TRANSBRK;
    Msg( 997004, '', 0, 0, 0 );
  end
  else begin
    TRANSOFF;
    Msg( 997003, '', 0, 0, 0 );
  end;

  if ( gZLList != 0 ) then begin
    gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecID | _winLstRecDoSelect );
  end;
end;

//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vHdl      : int;
  vRect     : rect;
  vSize     : int;
  vH        : int;
  vNorm     : int;
end
begin

  APP_MAIN:BugFix(__FUNC__, aEvt:Obj);

  if (gMDI->wpname<>w_Name) then RETURN false;

  //Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

  if (aFlags & _WinPosSized != 0) then begin
    if (gZLList<>0) then vHdl # gZLList;
    else if (gDataList<>0) then vHdl # gDataList
    else RETURN true;

    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28 - w_QBHeight;
    vHdl->wparea # vRect;
  end;

// Prj.P.
  vNorm # 645;
  vH # aRect:bottom-aRect:Top- w_QBHeight;    // Norm = 685
  if (vH<vNorm) then vH # vNorm;
  
  // Prj.P.Text2 H134
  vHdl # $Prj.P.Text2;
  vRect           # vHdl->wpArea;
  vRect:bottom    # vRect:Top + vH - vNorm + 134;
  vHdl->wparea # vRect;
  
  // auf 551
  vHdl # $Divider9;
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 551;
  vRect:bottom    # vRect:Top + 2;
  vHdl->wparea # vRect;
	
  // auf 560
  vHdl # $edPrj.P.Lsch.Datum;
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 560;
  vRect:bottom    # vRect:Top + 25;
  vHdl->wparea # vRect;
  vHdl # $lbPrj.P.Lsch.Datum
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 560;
  vRect:bottom    # vRect:Top + 25;
  vHdl->wparea # vRect;
  vHdl # $lbPrj.P.Lsch.User
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 560;
  vRect:bottom    # vRect:Top + 25;
  vHdl->wparea # vRect;
  vHdl # $edPrj.P.Lsch.User;
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 560;
  vRect:bottom    # vRect:Top + 25;
  vHdl->wparea # vRect;

  if (Set.Installname='BCS') then begin
    vHdl # $lbArcFlowDatum;
    if (vHdl<>0) then begin
      vRect           # vHdl->wpArea;
      vRect:Top       # vH - vNorm + 560;
      vRect:bottom    # vRect:Top + 25;
      vHdl->wparea # vRect;
    end;
    vHdl # $lbArcFlowDatum2;
    if (vHdl<>0) then begin
      vRect           # vHdl->wpArea;
      vRect:Top       # vH - vNorm + 560;
      vRect:bottom    # vRect:Top + 25;
      vHdl->wparea # vRect;
    end;
  end;
  
  // 588
  vHdl # $lbPrj.P.Lsch.Grund
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 588;
  vRect:bottom    # vRect:Top + 25;
  vHdl->wparea # vRect;
  vHdl # $edPrj.P.Lsch.Grund
  vRect           # vHdl->wpArea;
  vRect:Top       # vH - vNorm + 588;
  vRect:bottom    # vRect:Top + 25;
  vHdl->wparea # vRect;
  
	RETURN (true);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  Erx   : int;
  vBuf  : int;
end;
begin

  if (aName='CLMPRJ.ADRESSSTICHWORT') then begin
//    vBuf # RecBufCreate(120);
    Erx # RekLinkB(vBuf, aBuf, 2,_recfirst);
    if (Erx<=_rLocked) then
      if (vBuf->Prj.Adressnummer<>0) then  Adr_Main:Start(0, vBuf->Prj.Adressnummer,y);
    RecBufDestroy(vBuf);
  end;
  
   if ((aName =^ 'edPrj.P.Status') AND (aBuf->Prj.P.Status<>0)) then begin
    RekLink(850,122,3,0);   // Status holen
    Lib_Guicom2:JumpToWindow('VgSt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPrj.P.WiedervorlUser') AND (aBuf->Prj.P.WiedervorlUser<>'')) then begin
    Usr.VertretungUser # Prj.P.WiedervorlUser;
    RecRead(800,4,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================