@A+
//==== Business-Control ==================================================
//
//  Prozedur    TeM_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  21.06.2012  ST  "Vorgang öffnen" / Lieferschein öffnen überarbeitet
//  04.11.2013  ST  - Vorhandene Anker werden ermittelt und in Zgr angezeigt
//                  - Hinzufügen von Ankern in die Maske integriert
//  17.02.2014  ST  "Vorgang öffnen" -> BA hinkzugefügt
//  16.06.2016  AH  "ZeigeGraph"
//  07.08.2019  AH  ZumVorgang ruft auch die WOF-Prozedur auf
//  04.02.2022  AH  ERX
//  25.04.2022  ST  Projektposition als Sprungziel hinzugefügt
//  27.07.2022  HA  Quick Jump
//  2023-04-24  AH  Bedarf als Vorgang
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aNummer : int; opt aView   : logic) : logic;
//    SUB EvtInit(aEvt : event) : logic
//    SUB GehtUserAn(aUser : alpha) : logic;
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
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
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int) : logic;
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle      : 'Aktivitäten'
  cFile       : 980
  cMenuName   :'TeM.Bearbeiten'
  cPrefix     : 'TeM'
  cZList      : $ZL.Tem.Termine
  cKey        : 1
  cListen     : 'Termine'
  cDialog     : 'TeM.Verwaltung'
  cMdiVar     : gMDITermine
  cRecht      : Rgt_Termine

end;

//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aNr     : int;
  opt aView   : logic) : logic;
local begin
  Erx   : int;
end;
begin
  if (aRecId=0) and (aNr<>0) then begin
    TeM.Nummer # aNr;
    Erx # RecRead(980,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(980,_recID);
  end;
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
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen # cListen;
  
  Lib_Guicom2:Underline($edTeM.Typ);
  
// Auswahlfelder setzen...
  SetStdAusFeld('edTeM.Typ', 'TEMTYP');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  GehtUserAn
//
//========================================================================
sub GehtUserAn(aUser : alpha) : logic;
local begin
  Erx : int;
end;
begin

  if (TeM.Anlage.User=aUser) then RETURN true;

  Erx # RecLink(981,980,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (TeM.A.Datei=800) and (TeM.A.Code=gUserName) then RETURN true;
    Erx # RecLink(981,980,1,_recNext);
  END;

  RETURN false;
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
)
local begin
  vok   : logic;
  vTmp  : int;
end;
begin

  $bt.WOF->wpdisabled # !(Mode=c_ModeView) or (Tem.Typ<>'WOF');

  vOk # y;
  if (TeM.PrivatYN) then begin
    vOk # GehtUserAn(gUsername);
  end;
  if (vOK=n) then begin
    TeM.Bemerkung # Translate('<PRIVAT>');
    TeM.Bezeichnung # TeM.Bemerkung;
  end;

  if (aName='') or (aName='edTeM.Typ') then
    $LB.Typ->wpCaption # Lib_Termine:GetTypeName( TeM.Typ );

  if (aName='') then begin
    if (TeM.Wof.Nummer<>0) then
      $LB.WOF->wpCaption # Translate('Workflow')+' '+aint(Tem.Wof.Nummer)
    else
      $LB.WOF->wpCaption # '';
  end;

  $bt.Chat->wpvisible   # (Tem.Typ='DSK');
  $bt.Chat->wpdisabled  # (Mode<>c_ModeView);

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

  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);


  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vCode     : alpha;
  vDatei    : int;
  vID1,vID2 : int;
  vCode2    : alpha;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    TeM.SichtbarPlanerYN # y;
    TeM.Nummer # myTMPNummer;


    if (gZLList->wpcustom<>'') then begin
//  vHDL->wpcustom # cnvai(aDatei,_FmtNumNoGroup,0,3)+CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero,0,8) + CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero,0,3) + vCode;
      vCode # gZLList->wpcustom;

      vDatei  # cnvia(Strcut(vCode,1,3));
      vID1    # cnvia(Strcut(vCode,4,8));
      vID2    # cnvia(Strcut(vCode,12,3));
      vCode   # StrCut(vCode,15,20);
      vCode2  # vCode;
//todox('auto Anker');
      TeM_A_Data:Anker(vDatei, 'AUTO');

/*** 26.11.2014
      if (vID1<>0) OR (vID2<>0) then
        vCode2       # vCode + StrFmt(CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin) +
                     '/' + StrFmt(CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin);

      RecBufClear(981);
      TeM.A.Nummer      # Tem.Nummer;
      TeM.A.Code        # vCode2;
      TeM.A.Datei       # vDatei;
      if (vID1<0) then vID1 # 0;
      TeM.A.ID1         # vID1;
      if (vID2<0) then vID2 # 0;
      TeM.A.ID2         # vID2;
      Tem.A.lfdNr       # 1;
      TeM.A.Start.Datum # TeM.Start.Von.Datum
      TeM.A.Start.Zeit  # TeM.Start.Von.Zeit;
      REPEAT
        Erx # TeM_A_Data:Insert(0,'AUTO');
        if (erx<>_rOK) then inc(TeM.A.lfdNr);
      UNTIl (Erx=_rOK);
***/
    end;

//    TeM_A_Data:New(vDatei,'MAN');

  end;

  if (TeM.NichtInOrdnungYN) or (TeM.InOrdnungYN) then begin
    Lib_GuiCom:Disable($cbTeM.InOrdnungYN);
    Lib_GuiCom:Disable($cbTeM.NichtInOrdnungYN);
  end;
  // Aktueller User kann fertigmelden
//  $EdTeM.Erledigt.User->wpCaption # gUserName;
//  TeM.Erledigt.User # gUsername;

  // Schlüssel und Anlagedaten sperren
//  Lib_GuiCom:Disable($edTeM.Erledigt.User);
//  Lib_GuiCom:Disable($edTeM.Nummer);
  Lib_GuiCom:Disable($edTeM.Anlage.Datum);
  Lib_GuiCom:Disable($edTeM.Anlage.Zeit);
  Lib_GuiCom:Disable($edTeM.Anlage.User);

  // Schon fertiggemeldete Aktivitäten nicht nochmal fertigmeldbar
/*
  if (TeM.Erledigt.Datum <> 00.00.00) AND (TeM.Erledigt.Zeit <> 00:00) then begin
    Lib_GuiCom:Disable($edTeM.Erledigt.Datum);
    Lib_GuiCom:Disable($edTeM.Erledigt.Zeit);
  end;
*/

  // Focus setzen auf Feld:
  $edTeM.Typ->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vCode     : alpha;
  vCode2    : alpha;
  vID1      : int;
  vID2      : int;
  vDatei    : int;
  vTmp      : int;
  vKillTodo : logic;
  vNummer   : int;
  v800      : int;
  v981      : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  // Dauer errechnen
  TeM_Data:CalcDauer();
  $edTeM.Dauer->winupdate(_WinUpdFld2Obj);

  if (TeM.Dauer<0.0) then begin
    Lib_Guicom2:InhaltFalsch('Dauer', 'NB.Page1', 'edTem.Ende.Von.Datum');
    RETURN false;
  end;
  
  if (Lib_Termine:GetTypeName(Tem.Typ)='') then begin
    Lib_Guicom2:InhaltFalsch('Typ', 'NB.Page1', 'edTem.Typ');
    RETURN false;
  end;

  if (Tem.Typ='TEM') and (Tem.Start.Von.Datum=0.0.0) then begin
    Lib_Guicom2:InhaltFehlt('Termin', 'NB.Page1', 'edTem.Start.Von.Datum');
    RETURN false;
  end;

  // Anker updaten...
  FOR Erx # RecLink(981,980,1,_RecFirst)
  LOOP Erx # RecLink(981,980,1,_RecNext)
  WHILE (Erx <=_rLocked) DO BEGIN

    If (TeM.Erledigt.Datum <> 00.00.00)  then begin
      // Wurde Anker schon einzeln fertiggemeldet?
      if (TeM.A.Erledigt.Datum = 00.00.0000) then begin
        RecRead(981,1,_recLock);

        // Wurde noch nicht fertiggemeldet, also machen wir das jetzt
        TeM.A.Erledigt.Datum  # TeM.Erledigt.Datum;
        TeM.A.Erledigt.Zeit   # TeM.Erledigt.Zeit;
        TeM.A.Erledigt.User   # TeM.Erledigt.User;

        // Satz zurückspeichern & protokolieren
        erx # RekReplace(981,_RecUnlock,'MAN');
        if (Erx<>_rOk) then begin
          Msg(001000+Erx,Translate('Anker'),0,0,0);
          RETURN False;
        end;
      end;
    end
    else if (TeM.Start.Von.Datum<>TeM.A.Start.Datum) or (TeM.Start.Von.Zeit<>TeM.A.Start.Zeit) then begin
      RecRead(981,1,_recLock);
      TeM.A.Start.Datum # TeM.Start.Von.Datum;
      TeM.A.Start.Zeit  # TeM.Start.Von.Zeit;
      Erx # RekReplace(981);
    end;
  END;

  // Nummernvergabe

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Workflow?
    if (TeM.Typ='WOF') then begin
//    and (TeM.WoF.SchemaNr<>0) then begin 29.03.2020 AH
      if (ProtokollBuffer[980]->TeM.inOrdnungYN=false) and (TeM.InOrdnungYN) then begin
        Lib_Workflow:NextWOF('Y');
        vKillTodo # y;
      end;
      if (ProtokollBuffer[980]->TeM.NichtinOrdnungYN=false) and (TeM.NichtInOrdnungYN) then begin
        Lib_Workflow:NextWOF('N');
        vKillTodo # y;
      end;
    end
    else begin
      if (ProtokollBuffer[980]->TeM.inOrdnungYN=false) and (TeM.InOrdnungYN) or
         (ProtokollBuffer[980]->TeM.NichtinOrdnungYN=false) and (TeM.NichtInOrdnungYN) then vKillTODO # y;
    end;
    if (vKillTodo) then begin
      Lib_Notifier:RemoveAllEvents('980/'+AInt(TeM.Nummer), 0);
      Lib_Notifier:RemoveAllEvents('980',TeM.Nummer);
    end;

    PtD_Main:Compare(gFile);

    Lib_Sync_Outlook:StartSyncJob(980,n,n);

  end
  else begin

    TRANSON;

    // Nummernvergabe
    vNummer # Lib_Nummern:ReadNummer('Termin');     // Nummer lesen
    Lib_Nummern:SaveNummer();                       // Nummernkreis aktuallisiern

    // Anker umkopieren
    WHILE (RecLink(981,980,1,_recFirst)=_rOk) do begin
//      RecRead(981,1,_RecLock);
      v981 # RekSave(981);
      TeM.A.Nummer # vNummer;
      Erx # TeM_A_Data:Anker(981,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(981002,'',0,0,0);
        RETURN False;
      end;

      RekRestore(v981);
      RecRead(981,1,0);
      RekDelete(981,0,'AUTO');
//debugx('del Erx');
    END;

    TeM.Nummer        # vNummer;
    Tem.Anlage.Datum  # Today;
    TEm.Anlage.Zeit   # Now;
    Tem.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    if ($ZL.TeM.Termine->wpDbSelection<>0) then begin
      SelRecInsert($ZL.TeM.Termine->wpDbSelection,gFile);
    end;

    // automatisch Anker erzeugen?
    if (false) and (gZLList->wpcustom<>'') then begin
//  vHDL->wpcustom # cnvai(aDatei,_FmtNumNoGroup,0,3)+CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero,0,8) + CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero,0,3) + vCode;

      vCode # gZLList->wpcustom;
      vDatei  # cnvia(Strcut(vCode,1,3));
      vID1    # cnvia(Strcut(vCode,4,8));
      vID2    # cnvia(Strcut(vCode,12,3));
      vCode   # StrCut(vCode,15,20);
      vCode2  # vCode;
//todox('auto Anker');
      TeM_A_Data:Anker(vDatei, 'AUTO');
      
/** 26.11.2014
      if (vID1<>0) OR (vID2<>0) then
        vCode2       # vCode + StrFmt(CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin) +
                     '/' + StrFmt(CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin);

      RecBufClear(981);
      TeM.A.Nummer      # Tem.Nummer;
      TeM.A.Code        # vCode2;
      TeM.A.Datei       # vDatei;
      if (vID1<0) then vID1 # 0;
      TeM.A.ID1         # vID1;
      if (vID2<0) then vID2 # 0;
      TeM.A.ID2         # vID2;
      Tem.A.lfdNr       # 1;
      TeM.A.Start.Datum # TeM.Start.Von.Datum
      TeM.A.Start.Zeit  # TeM.Start.Von.Zeit;
      REPEAT
        Erx # TeM_A_Data:Insert(0,'AUTO');
        if (erx<>_rOK) then inc(TeM.A.lfdNr);
      UNTIl (Erx=_rOK);
***/
    end;

    TRANSOFF;

    Lib_Sync_Outlook:StartSyncJob(980,y,n);

  end;  // Neu

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  // Anker löschen
  if (Tem.Nummer=0) or (TeM.Nummer=myTmpNummer) then begin
    WHILE (RecLink(981,980,1,_RecFirst)=_rOk) do
      Tem_A_Data:Delete(0,'MAN');
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  tLinkFlag : int;
end;
begin

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    TeM_Data:Delete();
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
local begin
  vTmp  : int;
end;
begin

  case (aEvt:obj->wpname) of
    'edTeM.Start.Von.Datum' : begin
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum=0.0.0) then begin
        TeM.Ende.Von.Datum # TeM.Start.Von.Datum;
        $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
      end;
    end;


    'edTeM.Dauer' : begin
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum=0.0.0) then begin
        TeM.Ende.Von.Datum # TeM.Start.Von.Datum;
        $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
      end;
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
        vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
        vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
        vTmp # vTmp + Cnvif(TeM.Dauer);
        TeM.Ende.Von.Datum  # CnvdI( (vTmp / 1440) + cnvid(1.1.2000));
        TeM.Ende.Von.Zeit   # cnvti( (vTmp % 1440) * 60000);
        $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
        $edTeM.Ende.Von.Zeit->winupdate(_WinUpdFld2Obj);
      end;
    end;


    'edTeM.Start.Von.Datum', 'edTeM.Start.Von.Zeit', 'edTeM.Ende.Von.Datum', 'edTeM.Ende.Von.Zeit' : begin
      TeM_Data:CalcDauer();
      $edTeM.Dauer->winupdate(_WinUpdFld2Obj);
    end;

  end;

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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
  vHdl  : int;
  vHdl2 : int;
  vi    : int;
  vText : alpha;
  vSelected : int;
end;

begin

  case aBereich of

    'TEMTYP' : begin
      RecBufClear(857);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TTy.Verwaltung',here+':AusTTy');
      Lib_GuiCom:RunChildWindow(gMDI);
/***
      Lib_Einheiten:Popup('Termintyp',$edTeM.Typ,980,1,2);
      $Lb.Typ->wpCaption # Lib_Termine:GetTypeName(Tem.Typ);
      $edTeM.Typ->WinUpdate(_WinUpdFld2Obj);
      $Lb.Typ->WinUpdate(_WinUpdFld2Obj);
      $edTeM.Typ->winFocusSet(true);
***/
    end;


   'Auftrag' : begin
      RecBufClear(401);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Bestellung' : begin
      RecBufClear(501);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusBestellung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Adresse' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Partner' : begin
      RecBufClear(102);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung',here+':AusPartner');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Projekte' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjekt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Projektpos' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjektPos1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'User' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusUser');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'BAG_P' : begin
      RecBufClear(700);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Verwaltung',here+':AusBAG_P');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Material' : begin
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusTTy
//
//========================================================================
sub AusTTy()
local begin
  Erx   : int;
  vPos  : int;
end;
begin
  if (gSelected<>0) then begin
    Erx # RecRead(857,0,_RecId,gSelected);
    gSelected # 0;
    TeM.Typ # TTY.Typ2;
    $Lb.Typ->wpCaption # Lib_Termine:GetTypeName(Tem.Typ);
/***
      $Lb.Typ->wpCaption # Lib_Termine:GetTypeName(Tem.Typ);
      $edTeM.Typ->WinUpdate(_WinUpdFld2Obj);
      $Lb.Typ->WinUpdate(_WinUpdFld2Obj);
      $edTeM.Typ->winFocusSet(true);
***/
  end;
//  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $edTeM.Typ->winFocusSet(false);

end;


//========================================================================
//  ChoosePos
//
//========================================================================
sub ChoosePos() : int;
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin
  vHdl # WinOpen('BA1.P.Auswahl',_WinOpenDialog);

  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.Nummer)+' '+BAG.Bemerkung;
  vTmp # Winsearch(vHdl,'LB.Info3');
  vTmp->wpcaption # Translate('Arbeitsgang wählen:');

  vHdl->WinDialogRun(_WinDialogCenter,gMDI);
  WinClose(vHdl);
  if (gSelected=0) then RETURN 0;
  RecRead(702,0,_RecId,gSelected);
  gSelected # 0;

  RETURN BAG.P.Position;
end;


//========================================================================
//  AusBAG_P
//
//========================================================================
sub AusBAG_P()
local begin
  Erx   : int;
  vPos  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(700,0,_RecId,gSelected);
    gSelected # 0;

    // Position wählen
    vPos # ChoosePos();

    BAG.P.Nummer # BAG.Nummer;
    BAG.P.Position # BAG.P.Position;
    Erx # RecRead(702, 1, 0); // BAG.Pos lesen
    if(Erx > _rLocked) then
      RecBufClear(702);
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;


//========================================================================
//  AusUser
//
//========================================================================
sub AusUser()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(800, 'MAN');

  end;
  Usr_data:RecReadThisUser();
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(200, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  Ausauftrag
//
//========================================================================
sub AusAuftrag()
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(401, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellung()
begin
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(501, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(100, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusPartner
//
//========================================================================
sub AusPartner()
begin
  if (gSelected<>0) then begin
    RecRead(102,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(102, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusProjekt
//
//========================================================================
sub AusProjekt()
begin
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(120, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusProjektPos1
//
//========================================================================
sub AusProjektPos1()
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vHdl  : int;
end;
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;

    RecBufClear(122);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.P.Verwaltung',here+':AusProjektPos2');

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

    vQ # '';
    Lib_Sel:QInt(var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
    vHdl # SelCreate(122, 1);
    Erx # vHdl->SelDefQuery('', vQ);
    if (Erx <> 0) then Lib_Sel:QError(vHdl);
    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
    // Liste selektieren...
    gZLList->wpDbSelection # vHdl;

    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;

  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusProjektPos2
//
//========================================================================
sub AusProjektPos2()
begin
  if (gSelected<>0) then begin
    RecRead(122,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(122, 'MAN');
  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusNeuePrjPos
//
//========================================================================
sub AusNeuePrjPos()
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vHdl  : int;
end;
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;

    RecBufClear(122);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.P.Verwaltung','');

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vQ # '';
    Lib_Sel:QInt(var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
    vHdl # SelCreate(122, 1);
    Erx # vHdl->SelDefQuery('', vQ);
    if (Erx <> 0) then Lib_Sel:QError(vHdl);
    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
    // Liste selektieren...
    gZLList->wpDbSelection # vHdl;

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'AUS_TEM';
    w_cmd_para  # aint(Recinfo(980,_recID));

    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;

  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
  vOK : logic;
end
begin

  vOk # y;
  if (TeM.PrivatYN) then begin
    vOk # GehtUserAn(gUsername);
  end;

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Tem_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Tem_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_modeview)) or (w_Auswahlmode) or (Rechte[Rgt_tem_Aendern]=n) or (vOK=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_modeview)) or (w_AuswahlMode) or (Rechte[Rgt_tem_Aendern]=n) or (vOK=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList)) or (w_AuswahlMode) or (Rechte[Rgt_tem_Loeschen]=n) or (vOK=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList)) or (w_AuswahlMode) or (Rechte[Rgt_tem_Loeschen]=n) or (vOK=n);

  vHdl # gMenu->WinSearch('Mnu.Anker');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_modeview)) or (Rechte[Rgt_Termine_Anker]=n) or (vOK=n);
  vHdl # gMenu->WinSearch('Mnu.Berichte');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_modeview)) or (Rechte[Rgt_Termine_Berichte]=n) or (vOK=n);

  vHdl # gMenu->WinSearch('Mnu.Graph');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_modeview)) or (Tem.Wof.Nummer=0);

  $bt.OutlookExport->wpDisabled # (!Usr.OutlookYN);

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
  Erx   : int;
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then begin
    Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
    if (Erx>_rLocked) then RETURN false;
  end;

  case (aMenuItem->wpName) of

    'Mnu.Graph' : begin
      Wof_Data:ZeigeGraph(Tem.Wof.Nummer);
    end;


    'Mnu.PrjPosErzeugen' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusNeuePrjPos');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Tem.Anlage.Datum, Tem.Anlage.Zeit, Tem.Anlage.User);
    end;


    'Mnu.Anker' : begin
      RecBufClear(981);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.A.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Berichte' : begin
      if (TeM.Nummer<>0) and (TeM.Nummer<>myTmpNummer) then begin
        RecBufClear(982);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.B.Verwaltung','',y);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
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
local begin
  Erx   : int;
  vTmp  : int;
  vID   : int;
  vQ    : alpha(4000);
  vHdl  : int;
end;
begin

  if ( aEvt:obj->wpName = 'bt.Chat' ) then begin
    Dlg_Chat:Start(TeM.Bezeichnung, '~980.' + CnvAI(Tem.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 )+'.DSK');
    RETURN true;
  end;


  // Outlook Export
  if ( aEvt:obj->wpName = 'bt.OutlookExport' ) then
    Lib_COM:ExportTeM();


  if (aEvT:OBj->wpname='bt.Start.Now') then begin
    TeM.Start.Von.Datum # today;
    TeM.Start.Von.Zeit  # now;
    $edTeM.Start.Von.Datum->winupdate(_WinUpdFld2Obj);
    $edTeM.Start.Von.Zeit->winupdate(_WinUpdFld2Obj);
    TeM_Data:CalcDauer();
    $edTeM.Dauer->winupdate(_WinUpdFld2Obj);
  end;
  if (aEvT:OBj->wpname='bt.Ende.Now') then begin
    TeM.Ende.Von.Datum # today;
    TeM.Ende.Von.Zeit  # now;
    $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
    $edTeM.Ende.Von.Zeit->winupdate(_WinUpdFld2Obj);
    TeM_Data:CalcDauer();
    $edTeM.Dauer->winupdate(_WinUpdFld2Obj);
  end;


  if (aEvT:OBj->wpname='bt.WOF') then begin

    // 07.08.2019 AH: evtl. Prozedur starten
    WoF.Akt.Nummer    # TeM.WoF.SchemaNr;// WoF.Sch.Nummer;   18.05.2022 AH FIX
    WoF.Akt.Kontext   # TeM.WoF.Kontext;
    WoF.Akt.Position  # TeM.WoF.Position;
    Erx # RecRead(941,1,0);   // Aktivität holen
    if (Erx<=_rLocked) and (WoF.Akt.Prozedur<>'') then begin
      try begin
        ErrTryIgnore(_rlocked,_rNoRec);
        ErrTryCatch(_ErrNoProcInfo,y);
        Erx # _rNoRec;
        Call(Wof.Akt.Prozedur,'SHOW');
        // 04.02.2022 AH wegen ERX TODOERX      muss über AFXRES laufen !!!!
        //if (Erx=_rOK) then RETURN true;
        if (AfxRes=_rOK) then RETURN true;
      end;
    end;

    // Projekt
    if (TeM.Wof.Datei=120) then begin
      if (Rechte[Rgt_Projekte]=false) then RETURN false;

      Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key);

      if (gMdiPrj = 0) then begin
        gMdiPrj # Lib_GuiCom:OpenMdi(gFrmMain, 'Prj.Verwaltung', _WinAddHidden);
        VarInstance(WindowBonus,cnvIA(gMDIPrj->wpcustom));
        w_Command  # 'REPOS';
        w_Cmd_Para # AInt( RecInfo( 120, _recId ) );
        gMdiPrj->WinUpdate(_WinUpdOn);
        $NB.Main->WinFocusSet(true);
      end
      else begin
        Lib_GuiCom:RePos(var gMDIPrj, 'Prj.Verwaltung', RecInfo(120,_recId),n);
        Lib_guiCom:ReOpenMDI(gMDIPrj);
      end;
    end;
    
    // Projekt Position
    if (TeM.Wof.Datei=122) then begin
      if (Rechte[Rgt_Projekte]=false) then RETURN false;
      Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key);
      Prj_P_Main:Start(0, Prj.P.Nummer, Prj.P.Position, Prj.P.SubPosition, y);
    end;
        
        
        
    //Adresse
    if (TeM.Wof.Datei=100) then begin
      if (Rechte[Rgt_Material]=false) then RETURN false;

      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then begin
        if (gMdiMat = 0) then begin
          gMdiMat # Lib_GuiCom:OpenMdi(gFrmMain, 'Adr.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIMat->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( RecInfo( 100, _recId ) );
          gMdiMat->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIMat, 'Adr.Verwaltung', RecInfo(100,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIMat);
        end;
      end;
    end;

    // Material
    if (TeM.Wof.Datei=200) then begin
      if (Rechte[Rgt_Material]=false) then RETURN false;

      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then begin
        if (gMdiMat = 0) then begin
          gMdiMat # Lib_GuiCom:OpenMdi(gFrmMain, 'Mat.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIMat->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( RecInfo( 200, _recId ) );
          gMdiMat->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIMat, 'Mat.Verwaltung', RecInfo(200,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIMat);
        end;
      end;
    end;


    // Auftrag
    if (TeM.Wof.Datei=400) then begin
      if (Rechte[Rgt_Auftrag]=false) then RETURN false;

      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then begin
        RecLink(401,400,9,_recFirst);
        if (gMdiAuf = 0) then begin
          //gFrmMain->wpDisabled # true;
          gMdiAuf # Lib_GuiCom:OpenMdi(gFrmMain, 'Auf.P.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( RecInfo( 401, _recId ) );
          gMdiAuf->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIauf, 'Auf.P.Verwaltung', RecInfo(401,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIAuf);
        end;
      end;
    end;
    // Auftragsposition
    if (TeM.Wof.Datei=401) then begin
      if (Rechte[Rgt_Auftrag]=false) then RETURN false;

      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLockeD) then begin

        vID # RecInfo( 401, _recId);
        if (gMdiAuf = 0) then begin
          //gFrmMain->wpDisabled # true;
          gMdiAuf # Lib_GuiCom:OpenMdi(gFrmMain, 'Auf.P.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( vID);//RecInfo( 401, _recId ) );
          gMdiAuf->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIauf, 'Auf.P.Verwaltung', RecInfo(401,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIAuf);
        end;
      end;
    end;


    // Lieferschein
    if (TeM.Wof.Datei=440) then begin
      if (Rechte[Rgt_Lieferschein]=false) then RETURN false;

      Erx # Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key);
      // ST 2012-06-21: Umbau auf Startmethode
      if (Erx <= _rLocked) then
        Lfs_Main:Start(RecInfo(440,_recId),y);
      else
        Msg(001000+Erx,gTitle,0,0,0);
    end;

    // Bedarf   2023-04-24  AH Proj. 2430/67
    if (TeM.Wof.Datei=540) then begin
      if (Rechte[Rgt_Bedarf]=false) then RETURN false;

      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then begin
        if (gMdiBdf = 0) then begin
          gMdiBdf # Lib_GuiCom:OpenMdi(gFrmMain, 'Bdf.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIBdf->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( RecInfo( 540, _recId ) );
          gMdiBdf->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIBdf, 'Bdf.Verwaltung', RecInfo(540,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIBdf);
        end;
      end;
    end;


    // Betriebsaufträge
    if (TeM.Wof.Datei=700) then begin
      if (Rechte[Rgt_BAG]=false) then RETURN false;
      Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key);
      if (gMdiBag = 0) then begin
        //gFrmMain->wpDisabled # true;
        gMdiBag # Lib_GuiCom:OpenMdi(gFrmMain, 'Ba1.Verwaltung', _WinAddHidden);
        VarInstance(WindowBonus,cnvIA(gMdiBag->wpcustom));
        w_Command  # 'REPOS';
        w_Cmd_Para # AInt( RecInfo( 700, _recId ) );
        gMdiBag->WinUpdate(_WinUpdOn);
        $NB.Main->WinFocusSet(true);
      end
      else begin
        Lib_GuiCom:RePos(var gMdiBag, 'Ba1.Verwaltung', RecInfo(700,_recId),n);
        Lib_guiCom:ReOpenMDI(gMdiBag);
      end;
    end;
    if (TeM.Wof.Datei=702) then begin
      if (Rechte[Rgt_BAG]=false) then RETURN false;
      Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key);
      if (gMdiBag = 0) then begin
        Erx # RecLink(700,702,1,_RecFirst); // BA-Kopf holen
        gMdiBag # Lib_GuiCom:OpenMdi(gFrmMain, 'Ba1.Verwaltung', _WinAddHidden);
        VarInstance(WindowBonus,cnvIA(gMdiBag->wpcustom));
        w_Command  # 'REPOS';
        w_Cmd_Para # AInt( RecInfo( 700, _recId ) );
        gMdiBag->WinUpdate(_WinUpdOn);
        $NB.Main->WinFocusSet(true);
      end
      else begin
        Lib_GuiCom:RePos(var gMdiBag, 'Ba1.Verwaltung', RecInfo(700,_recId),n);
        Lib_guiCom:ReOpenMDI(gMdiBag);
      end;
    end;




    // Bestellung
    if (TeM.Wof.Datei=500) then begin
      if (Rechte[Rgt_einkauf]=false) then RETURN false;

      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then begin
        RecLink(501,500,9,_recFirst);
        if (gMdiEin = 0) then begin
          //gFrmMain->wpDisabled # true;
          gMdiEin # Lib_GuiCom:OpenMdi(gFrmMain, 'Ein.P.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIEin->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( RecInfo( 501, _recId ) );
          gMdiEin->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIEin, 'Ein.P.Verwaltung', RecInfo(501,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIEin);
        end;
      end;
    end;
    // Bestellposition
    if (TeM.Wof.Datei=501) then begin
      if (Rechte[Rgt_Einkauf]=false) then RETURN false;
      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLockeD) then begin

        vID # RecInfo( 501, _recId);
        if (gMdiEin = 0) then begin
          gMdiEin # Lib_GuiCom:OpenMdi(gFrmMain, 'Ein.P.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIEin->wpcustom));
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( vID);
          gMdiein->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIEin, 'Ein.P.Verwaltung', RecInfo(501,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIEin);
        end;
      end;
    end;

    // Anhang
    if (TeM.Wof.Datei=916) then begin
      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)<=_rLocked) then begin
        if (gMdiPara = 0) then begin
          gMdiPara # Lib_GuiCom:OpenMdi(gFrmMain, 'Anh.Verwaltung', _WinAddHidden);
          VarInstance(WindowBonus,cnvIA(gMDIPara->wpcustom));
          
          vQ # '';
          Lib_Sel:QInt(var vQ, 'Anh.Datei', '=', Anh.Datei);
          Lib_Sel:QAlpha(var vQ, 'Anh.Key', '=', Anh.Key);

          vHdl # SelCreate(916, 4);   // 26.03.2020
          Erx  # vHdl -> SelDefQuery('', vQ);
          if (Erx != 0) then
            Lib_Sel:QError(vHdl);

          // speichern, starten und Name merken...
          w_SelName # Lib_Sel:SaveRun(var vHdl, 0, false);
          // Liste selektieren...
          gZLList->wpDbSelection # vHdl;

          vHdl # gMDIPara->winsearch('lb.key1');
          vHdl->wpcustom # cnvai(Anh.Datei);
          vHdl # gMDIPara->winsearch('lb.key2');
          vHdl->wpcustom # Anh.Key;

          
          w_Command  # 'REPOS';
          w_Cmd_Para # AInt( RecInfo( 916, _recId ) );
          gMdiPara->WinUpdate(_WinUpdOn);
          $NB.Main->WinFocusSet(true);
        end
        else begin
          Lib_GuiCom:RePos(var gMDIPara, 'Anh.Verwaltung', RecInfo(916,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIPara);
        end;
      end;
    end;

  end;  // bt.Wof


  if (Rechte[Rgt_tem_Aendern]) then begin
    case (aEvt:Obj->wpName) of

      'bt.Anker.New' : begin
        vTmp # WinDialog('TeM.Anker.Auswahl',_WinDialogCenter,gMDI);
        IF !(vTmp = _WinIdClose) and (gSelected<>0) then begin
          gMDI->winfocusset(true);
          vTmp # gSelected;
          gSelected # 0;
          // Liste je nach Auswahl aufrufen
          // Zu verankernde Position auswählen
          CASE (vTmp) OF
            100 : Auswahl('Adresse');
            401 : Auswahl('Auftrag');
            501 : Auswahl('Bestellung');
            102 : Auswahl('Partner');
            120 : Auswahl('Projekte');
            122 : Auswahl('Projektpos');
            800 : Auswahl('User');
            200 : Auswahl('Material');
            702 : Auswahl('BAG_P');
          END;
          RETURN true;
        end;
      end;


      'bt.Anker.Del' : begin
        Erx # RecRead(981,0,0,$rl.Tem2.anker->wpdbRecId);
        if (Erx=_rOk) then begin

          Lib_Sync_Outlook:StartSyncJob(981,n,Y);

          Tem_A_Data:Delete(0,'MAN');
        end;
        $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      end;
    end;
  end;



  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.TemTyp'        : Auswahl('TEMTYP');
  end;

end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTmp  : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  aEvt:Obj->winupdate(_WinUpdObj2Fld);

  if (aEvt:Obj->wpname='cbTeM.InOrdnungYN') and (TeM.InOrdnungYN) then begin
    TeM.Erledigt.User   # gUserName;
    TeM.Erledigt.Zeit   # now;
    TeM.Erledigt.Datum  # today;
    TeM.NichtInOrdnungYN # !(TeM.InOrdnungYN);
    vTmp # gMdi->winsearch('cbTeM.NichtInOrdnungYN');
    if (vTmp<>0) then
      vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='cbTeM.NichtInOrdnungYN') and (TeM.NichtInOrdnungYN) then begin
    TeM.Erledigt.User   # gUserName;
    TeM.Erledigt.Zeit   # now;
    TeM.Erledigt.Datum  # today;
    TeM.InOrdnungYN # !(TeM.NichtInOrdnungYN);
    vTmp # gMdi->winsearch('cbTeM.InOrdnungYN');
    if (vTmp<>0) then
      vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (TeM.NichtInOrdnungYN=falsE) and (TeM.InOrdnungYN=false) then begin
    TeM.Erledigt.User   # '';
    TeM.Erledigt.Zeit   # 0:0;
    TeM.Erledigt.Datum  # 0.0.0;
  end;

  $edTeM.Erledigt.Datum->winUpdate(_WinUpdFld2Obj);
  $edTeM.Erledigt.Zeit->winUpdate(_WinUpdFld2Obj);
  $edTeM.Erledigt.User->winUpdate(_WinUpdFld2Obj);

//  RefreshIfm();

  RETURN true;
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
) : logic;
local begin
  Erx       : int;
  vOK       : logic;
  vA1, vA2  : alpha;
end;
begin

  vOk # y;
  if (TeM.PrivatYN) then begin
    vOk # GehtUserAn(gUsername);
  end;
  if (vOK=n) then begin
    TeM.Bemerkung # Translate('<PRIVAT>');
    TeM.Bezeichnung # TeM.Bemerkung;
  end;


  // Anker anzeigen, wenn vorhanden
  Gv.Alpha.01 # '';
  FOR   Erx # Reclink(981,980,1,_RecFirst)
  LOOP  Erx # Reclink(981,980,1,_RecNext)
  WHILE Erx <= _rLocked DO BEGIN

//    if (TeM.A.Code = '') then
//      CYCLE;

    if (Gv.Alpha.01 <> '') then
      Gv.Alpha.01 # GV.Alpha.01 + ', ';

    TeM_A_Data:Code2Text(var vA1,var vA2);

    Gv.Alpha.01 # GV.Alpha.01 + vA1 + ' ' + vA2;
  END;


  if (Tem.Erledigt.Datum<>0.0.0) then //(Tem.InOrdnungYN) or (Tem.InOrdnungYN) thenthen
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)


  RETURN true;
end;


//========================================================================
//  EvtLstDataInitAnk
//
//========================================================================
sub EvtLstDataInitAnk(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  vOK : logic;
  vA1 : alpha(200);
  vA2 : alpha(200);
end;
begin

  TeM_A_Data:Code2Text(var vA1,var vA2);
  Gv.Alpha.01 # vA1 + ' ' + vA2;

/***
  if (TeM.A.Datei=800) then begin
    Gv.Alpha.01 # TeM.A.Code;
    RETURN;
  end;

  if (TeM.A.Datei<>0) and (TeM.A.Key<>'') then begin
    vOK # (Lib_Rec:ReadByKey(TeM.A.Datei, TeM.A.Key) <= _rLocked);
  end;

  case (TeM.A.Datei) of
    100 : begin
      if (vOK=falsE) then begin
        Adr.Nummer # TeM.A.ID1;
        RecRead(100,1,0);
      end;
      Gv.Alpha.01 # Adr.Stichwort;
    end;


    102 : begin
      if (vOK=falsE) then begin
        Adr.P.Adressnr  # TeM.A.ID1;
        Adr.P.Nummer    # TeM.A.ID2;
        RecRead(102,1,0);
      end;
      Gv.Alpha.01 # Adr.P.Stichwort;
    end;


    120 : begin
      if (vOK=falsE) then begin
        Prj.Nummer # TeM.A.ID1;
        RecRead(120,1,0);
      end;
      Gv.Alpha.01 # Prj.Stichwort;
    end;


    122 : begin
      if (vOK=false) then begin
        RecBufClear(120);
        Prj.P.Nummer    # TeM.A.ID1;
        Prj.P.Position  # TeM.A.ID2;
        Erx # RecRead(122,1,0);
        if (Erx<=_rLocked) then begin
          Erx # RekLink(120,122,2,_recFirst);   // Projekt holen
        end;
      end;
      Gv.Alpha.01 # ''+Prj.P.Bezeichnung;
    end;


    800 : begin
      Gv.Alpha.01 # TeM.A.Code;
    end;


    otherwise begin
      Gv.Alpha.01 # TeM.A.Code;
    end;

  end;
***/

end;


//========================================================================
//  EvtDropEnterAnk
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnterAnk(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vFormat : int;
  vTxt    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
	RETURN (true);
end;


//========================================================================
//========================================================================
sub EvtDropAnk(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vPref     : alpha;
  vA        : alpha;
  vDatei    : int;
  vID       : int;
  vDetail   : logic;
  vZonelist : int;
  vBuf      : int;
end;
begin
  if (aEffect | _WinDropEffectCopy=0) or (aEffect | _WinDropEffectMove=0) then RETURN false;

  if (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpcustom<>'') then begin

    vA      # StrFmt(aDataObject->wpName,30,_strend);
    vDatei  # Cnvia(StrCut(vA,1,3));
    vID     # Cnvia(StrCut(vA,5,15));

    if (vDatei=0) then RETURN false;

    vBuf # RekSave(vDatei);
    if (RecRead(vDatei, 0, _recID, vID)>_rlocked) then begin
      RekRestore(vBuf);
      RETURN false;
    end;
/**
    case vDatei of
      100 : TeM_A_Data:New(100,'MAN');
      101 : TeM_A_Data:New(101,'MAN');
      102 : TeM_A_Data:New(102,'MAN');
      122 : TeM_A_Data:New(122,'MAN');
      200 : TeM_A_Data:New(200,'MAN');
      250 : TeM_A_Data:New(250,'MAN');
      401 : TeM_A_Data:New(401,'MAN');
      501 : TeM_A_Data:New(501,'MAN');
      800 : TeM_A_Data:New(800,'MAN');
    end;
**/
    TeM_A_Data:Anker(vDatei, 'MAN');

    RekRestore(vBuf);

    RefreshList(aEvt:Obj, _WinLstRecFromRecid | _WinLstRecDoSelect);

  end;

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
//  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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
//========================================================================
sub EvtMouseItemAnker(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : handle;   // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
begin

  // nur Doppelklick akzeptieren
  if ( aButton & _winMouseLeft = 0 ) or ( aButton & _winMouseDouble = 0 ) then
    RETURN true;

  if ( aItem = 0 ) or ( aId = 0 ) then
    RETURN true;

  if ( RecRead( 981, 0, _recId, aId ) > _rLocked ) then
    RETURN true;

  if (Tem.A.Datei=916) then RETURN true;
  
  if (TeM.A.ID1=0) and (TeM.A.Key<>'') then begin
    TeM.A.ID1 # cnvia(Str_Token(TeM.A.Key, StrChar(255),1));
    TeM.A.ID2 # cnvia(Str_Token(TeM.A.Key, Strchar(255),2));
    TeM.A.ID3 # cnvia(Str_Token(TeM.A.Key, Strchar(255),3));
  end;

  // Ankerdatei öffnen
  if (TeM.A.Datei=100) then Adr_Main:Start(0, TeM.A.ID1, y);
  if (TeM.A.Datei=101) then Adr_A_Main:Start(0, TeM.A.ID1, TeM.A.ID2,y);
  if (TeM.A.Datei=102) then Adr_P_Main:Start(0, TeM.A.ID1, TeM.A.ID2,y);
  if (TeM.A.Datei=110) then Ver_Main:Start(0, TeM.A.ID1,y);
//  if (TeM.A.Datei=120) then Prj_Main:Start(0, TeM.A.ID1, y);
  if (TeM.A.Datei=122) then Prj_P_Main:Start(0, TeM.A.ID1, TeM.A.Id2, TeM.A.ID3, y);

  RETURN(true);
end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edTeM.Typ') AND (aBuf->TeM.Typ<>'')) then begin
    todo('TEMTYP')
    //RekLink(819,200,1,0);   // Typ holen
    Lib_Guicom2:JumpToWindow('TTy.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================