@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_P_Main
//                  OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  05.01.2010  AI  Positionsauswahl nur noch OHNE VSB/Versand
//  19.01.2010  TM  Druck Lohnformular erweitert: Spulen und Walzen
//  12.10.2010  AI  LFS wird immer refreshed beim Speichern
//  19.10.2010  AI  VSB und Versand wird in der RecControl unterdrückt zum Abschliessen
//  04.11.2010  AI  Erweiterung für LFA-MultiLFS
//  13.01.2011  AI  Änderung speichern updated die LFS-Köpfe
//  04.07.2012  AI  Walzen mit mehreren Schritten
//  24.09.2012  AI  ArtPrd eingebaut
//  12.12.2012  ST  RID nach mehreren Walzstichen abfragen
//  04.06.2013  ST  "Druck Lohnformulare" läuft jetzt wie in BA1_Main über zentrale Prozedur
//  01.04.2014  AH  AFX: BAG.P.Auswahl.Ressource
//  23.01.2015  AH  Menü "Walzschritte"
//  20.02.2015  AH  D&D für Arbeitsgänge
//  09.03.2015  AH  "Merge"
//  05.11.2015  AH  "#" in BAG.P.Position erlaubt
//  17.03.2016  AH  Neu: Feld "BAG.P.Status"
//  30.11.2016  AH  TextAdd
//  17.01.2018  ST  Arbeitsgang "Umlagern" hinzugefügt
//  18.01.2019  AH  Edit: Manuelles Ändern der Dauer/Pufferzeit setzt Haken "Plan.ManuellYN"
//  21.01.2019  AH  Edit: Manuelle Anlage nimmt nächste höhere Posnr. und nicht die Lücken
//  23.01.2019  AH  Edit: bei stornierten Weiterbearbeitungen Position NICHT rot färben
//  08.05.2019  AH  Neu: BAG.P.ExterneLiefAns
//  11.05.2020  AH  Neu: ZwischenDraengeln
//  19.06.2020  AH  Set.BA.Ziel.AktivJN
//  04.08.2020  AH  Plausi auf ExterneLfNr
//  02.09.2020  ST  Edit: Walzen/Recsave Sonderlocke Mawe  ST 2020-09-02 2106/3/2
//  23.11.2020  AH  Neu: AFX "BAG.P.RecSave.VorSave"
//  29.09.2021  AH  ERX
//  25.01.2022  AH  Neu: direktes neue Pos. Einbinden
//  28.02.2022  AH  Menü: Andere Vorlage importieren
//  2022-08-30  AH  Umwandlung von Dauer
//  2022-11-24  AH  Einfach-Nachspalten
//  2022-12-19  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha;opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave(opt aMode : alpha) : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKommission()
//    SUB AusKopftext()
//    SUB AusFusstext()
//    SUB AusLieferant()
//    SUB Ausarbeitsgang()
//    SUB AusRessource()
//    SUB AusZieladresse()
//    SUB AusZielanschrift()
//    SUB AusEinzeldicken();
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB TextLoad()
//    SUB TextSave()
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstRecControl(aEvt : event; aRecID : int) : logic;
//    SUB AuswahlEvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB AuswahlEvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Auswahl_EvtInit(aEvt : event) : logic
//    SUB Auswahl_EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDialog :   $BA1.Combo.Verwaltung
  cTitle :    'Betriebsauftragspositionen'
  cFile :     702
  cMenuName : 'BA1.P.Bearbeiten'
  cPrefix :   'BA1_P'
  cZList :    $RL.BA1.Pos
  cKey :      1

  cZList1 :   $RL.BA1.Pos
  cZList2 :   $RL.BA1.Input
  cZList3 :   $RL.BA1.Fertigung

end;
declare TextLoad()
declare TextSave()


//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vTmp    : int;
end;
begin

  if (w_Child=0) then begin

    // Datei spezifische Vorgaben
    gTitle  # Translate(cTitle);
    gFile   # cFile;
    gFrmMain->wpMenuname # cMenuName;    // Menü setzen
    gPrefix # cPrefix;
    gZLList # cZList;
    gKey    # cKey;

    gMenu # gFrmMain->WinInfo(_WinMenu);

    // gelinkter Datensatz? -> dann Sort/Suche abschalten
    if (gZLList->wpDbLinkFileNo<>0) or (gZLList->wpdbfilter<>0) then begin
      vTmp # cDialog->WinSearch('lb.Sort');
      vTmp->wpvisible # false;
      vTmp # cDialog->WinSearch('lb.Suche');
      vTmp->wpvisible # false;
      vTmp # cDialog->WinSearch('ed.Sort');
      vTmp->wpvisible # false;
      vTmp # cDialog->WinSearch('ed.Suche');
      vTmp->wpvisible # false;
    end;
  end;

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  gZLList->WinFocusSet(false);

  Call('App_Main:EvtMdiActivate',aEvt);

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder

  Lib_GuiCom:Pflichtfeld($edBAG.P.Aktion);

  // Pflichtfelder
  if (BAG.P.Aktion = c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (BAg.P.Aktion=c_BAG_ArtPrd) or (BAG.P.Aktion=c_BAG_Umlager) then begin
    Lib_GuiCom:Pflichtfeld($edBAG.P.Zieladresse);
    Lib_GuiCom:Pflichtfeld($edBAG.P.Zielanschrift);
  end;
  
  $edBAG.P.Status->wpreadonly # true;

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx     : int;
  vA      : alpha;
  vX      : int;
  vTxtHdl : int;
  vTmp    : int;
  vHdl    : int;
  vItem   : int;
end;
begin

  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $te.BA.Pos.Kopf->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $te.BA.Pos.Fuss->wpdbTextBuf # vTxtHdl;
  end;

  if (aName='') then TextLoad();

  if (aName='') or (aName='edBAG.P.Kommission') then begin
    // Kommission angegeben?
    BAG.P.Auftragsnr  # 0;
    BAG.P.AuftragsPos # 0;
    if (BAG.P.Kommission<>'') and (Bag.P.Kommission<>'#') then begin
      vA # StrCut(BAG.P.Kommission,1,1);
      vX # StrFind(BAG.P.Kommission,'/',0);
      if (vA>='0') and (vA<='9') and (vx<>0) then begin
        vA # Str_Token(BAG.P.Kommission,'/',1);
        BAG.P.Auftragsnr # CnvIa(va);
        vA # Str_Token(BAG.P.Kommission,'/',2);
        BAG.P.Auftragspos # CnvIa(va);
      end
      else begin
        BAG.P.Kommission # '';
      end;
    end;
    if (BAG.P.Auftragsnr<>0) then begin
      Auf.P.Nummer    # BAG.P.Auftragsnr;
      Auf.P.Position  # BAG.P.AuftragsPos;
      Erx # RecRead(401,1,0);
      if (Erx<=_rLockeD) then begin
        $lb.Kommission->wpcaption # Auf.P.KundenSW;
      end
      else begin
        $lb.Kommission->wpcaption # '';
        BAG.P.Auftragsnr # 0;
        BAG.P.AuftragsPos # 0;
        BAG.P.Kommission # '';
      end
    end
    else begin
      if (Bag.P.Kommission<>'#') then
        $lb.Kommission->wpcaption # '';
    end;
    $edBAG.P.Kommission->winupdate(_WinUpdFld2Obj);
  end;


  if (aName='') or (aName='edBAG.P.Ressource') or (aName='edBAG.P.Ressource.Grp') then begin
    Erx # RecLink(822,702,10,_RecFirst);
    if (Erx<=_rLocked) then begin
      $lb.ResGruppe->wpcaption # Rso.Grp.Bezeichnung;
      Erx # RecLink(160,702,11,_RecFirst);
      if (Erx<=_rLocked) then begin
        $lb.Ressource->wpcaption # Rso.Stichwort;
      end
      else begin
        $lb.Ressource->wpcaption # ''
      end;

      $lb.Ressource->wpcaption # Rso.Stichwort;
    end
    else begin
      $lb.ResGruppe->wpcaption # ''
      $lb.Ressource->wpcaption # ''
    end;

    if (aChanged) or ($edBAG.P.Ressource->wpchanged) or ($edBAG.P.Ressource.Grp->wpchanged) then begin
      RunAFX('BAG.P.Auswahl.Ressource',aName);
    end;

  end;


  if (aName='') or (aName='edBAG.P.ExterneLiefNr') or (aName='edBAG.P.ExterneLiefAns') then begin
    vA # '';
    if (BAG.P.ExterneLiefNr<>0) then begin
      Erx # RecLink(100,702,7,0);   // Adresse holen
      if (Erx>_rLocked) then RecBufClear(100);
      vA # Adr.Stichwort;
      if (BAG.P.ExterneLiefAns<>0) then begin
        vA # '';
        Adr.A.Adressnr # Adr.Nummer;
        Adr.A.Nummer # BAG.P.ExterneLiefAns;
        Erx # RecRead(101,1,0);
        if (Erx<=_rLocked) then begin
          vA # Adr.A.Stichwort;
        end;
      end;
    end;
    
    $Lb.Lieferant->wpcaption # vA;
  end;

  if (aName='edBAG.P.Zieladresse') or (aName='edBAG.P.Zielanschrift') then begin
    BAG.P.Zielstichwort # '';
    If (BAG.P.Zieladresse <>0) then begin
      Erx # RekLink(100,702,12,_recFirst);
      BAG.P.Zielstichwort # Adr.Stichwort;
      if (BAG.P.Zielanschrift<>0) then begin
        Erx # RekLink(101,702,13,_recFirst);    // Anschrift holen
        BAG.P.Zielstichwort # Adr.A.Stichwort;
      end;
    end;
    $lb.Zieladresse->Winupdate(_WinUpdFld2Obj);
  end;

  if (aName='edBAG.P.Aktion') and ($edBAG.P.Aktion->wpchanged) then begin
    Erx # RecLink(828,702,8,0);
    if (Erx>_rLocked) then RecBufClear(828);
    BAG.P.Aktion  # ArG.Aktion;
    BAG.P.Aktion2 # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN" # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN" # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN" # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"      # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung # ArG.Bezeichnung
    $Lb.Bezeichnung->WinUpdate(_WinUpdFld2Obj);


    Lib_GuiCom:Able($edBAG.P.Kosten.Pro,  (BAG.P.Aktion<>c_BAG_Umlager));
    Lib_GuiCom:Able($edBAG.P.Kosten.PEH,  (BAG.P.Aktion<>c_BAG_Umlager));
    Lib_GuiCom:Able($edBAG.P.Kosten.MEH,  (BAG.P.Aktion<>c_BAG_Umlager));
    Lib_GuiCom:Able($bt.MEH,              (BAG.P.Aktion<>c_BAG_Umlager));
    Lib_GuiCom:Able($edBAG.P.Kosten.Fix,  (BAG.P.Aktion<>c_BAG_Umlager));

    if (BAG.P.Aktion=c_BAG_Versand) then begin        // 29.09.2021 : aus Kundenauftrag?
      vHdl # WinSearch(gMDI, 'lb.zuAuftragsList');
      if (vHdl<>0) and (cnvia(vHdl->wpcustom)<>0) then begin
        vHdl # cnvia(vHdl->wpcustom);
        if (vHdl<>0) then begin
          vItem # vHdl->CteRead( _cteFirst );
          vA # Str_Token(vItem->spname,'/',1);
          Auf.Nummer # cnvia(vA);
          Erx # RecRead(400,1,0);   // Aufpos holen
          if (erx<=_rLocked) then begin
            BAG.P.Zieladresse   # Auf.Lieferadresse;
            BAG.P.Zielanschrift # Auf.Lieferanschrift;
            BAG.P.ZielVerkaufYN   # n;
            Erx # RecLink(101,702,13,_recFirst);    // Anschrift holen
            if (erx>_rLockeD) then RecbufClear(101);
            BAG.P.Zielstichwort # Adr.A.Stichwort;
            $edBAG.P.Zielanschrift->Winupdate(_WinUpdFld2Obj);
            $edBAG.P.Zieladresse->Winupdate(_WinUpdFld2Obj);
            $lb.Zieladresse->Winupdate(_WinUpdFld2Obj);
            $cbBAG.P.ZielVerkaufYN->Winupdate(_WinUpdFld2Obj);
          end;
        end;
      end;
    end;

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

  RunAFX('BAG.P.RefreshIfm.Post',aName);
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  vTmp # gMdi->winsearch('NB.Main');
  vTmp->wpCurrent # 'NB.Position';
//  $NB.Main->wpcurrent # 'NB.Position';
  if (Mode=c_ModeNew) then begin
    BAG.P.Nummer # BAG.Nummer;
    BAG.P.Kosten.Wae  # 1;
    BAG.P.Kosten.PEH  # 1000;
    BAG.P.Kosten.MEH  # 'kg';
    BA1_Data:SetStatus(c_BagStatus_Offen);
  end;

  if (BAG.P.ExternYN) then begin
    $lb.ResGruppe->wpcaption # '';
    $lb.Ressource->wpcaption # '';
    $edBAG.P.Ressource.Grp->winupdate(_WinUpdFld2Obj);
    $edBAG.P.Ressource->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Disable($edBAG.P.Ressource.Grp);
    Lib_GuiCom:Disable($edBAG.P.Ressource);
    Lib_GuiCom:Disable($bt.ResGruppe);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Enable($bt.Lieferant);
    Lib_GuiCom:Enable($edBAG.P.ExterneLiefNr);
    Lib_GuiCom:Enable($edBAG.P.ExterneLiefAns);
  end
  else begin
    $lb.Lieferant->wpcaption # '';
    $edBAG.P.ExterneLiefNr->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Enable($edBAG.P.Ressource.Grp);
    Lib_GuiCom:Enable($edBAG.P.Ressource);
    Lib_GuiCom:Enable($bt.ResGruppe);
    Lib_GuiCom:Enable($bt.Ressource);
    Lib_GuiCom:Disable($bt.Lieferant);
    Lib_GuiCom:Disable($edBAG.P.ExterneLiefNr);
    Lib_GuiCom:Disable($edBAG.P.ExterneLiefAns);
  end;


  Lib_GuiCom:Able($edBAG.P.Kosten.Pro,  (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($edBAG.P.Kosten.PEH,  (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($edBAG.P.Kosten.MEH,  (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($bt.MEH,              (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($edBAG.P.Kosten.Fix,  (BAG.P.Aktion<>c_BAG_Umlager));


  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then begin
    // KopfText laden
    TextLoad();
//      TextClear(vTxtHdl);
//      $te.BA.Pos.Kopf->wpcustom # vName;
//      $te.BA.Pos.Kopf->WinUpdate(_WinUpdBuf2Obj);
//    end;
    $edBAG.P.Aktion->WinFocusSet(true)
  end

  else begin              // Edit
    if (BAG.P.Aktion<>c_BAG_FAHR) and (BAG.P.Aktion<>c_BAG_Versand) and
        (BAG.P.Aktion<>c_BAG_ArtPrd) and (BAG.P.Aktion <> c_BAG_Umlager) and (Set.BA.Ziel.AktivJN=false) then begin
      BAG.P.Zieladresse     # 0;
      BAG.P.Zielanschrift   # 0;
      BAG.P.Zielstichwort   # '';
      BAG.P.ZielVerkaufYN   # n;
      Lib_GuiCom:Disable($edBAG.P.Zieladresse);
      Lib_GuiCom:Disable($bt.Zieladresse);
      Lib_GuiCom:Disable($edBAG.P.Zielanschrift);
      Lib_GuiCom:Disable($bt.Zielanschrift);
      $cbBAG.P.ExternYN->WinFocusSet(true);
    end
    else begin  // FAHREN...
      Lib_GuiCom:Disable($bt.Kommission);
      Lib_GuiCom:Disable($edBAG.P.Kommission);
      // 25.08.2020 AH: Ziel editierbar solange noch NICHT fertiggemeldet!
      if (Mode=c_Modenew) or (RecLinkInfo(707,702,5,_recCount)=0) then begin
        Lib_GuiCom:Enable($edBAG.P.Zieladresse);
        Lib_GuiCom:Enable($bt.Zieladresse);
        Lib_GuiCom:Enable($edBAG.P.Zielanschrift);
        Lib_GuiCom:Enable($bt.Zielanschrift);
        $cbBAG.P.ExternYN->WinFocusSet(true)
      end
      else begin
        $cbBAG.P.ExternYN->WinFocusSet(true);
      end;
    end;

  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave(opt aMode : alpha) : logic;
local begin
  Erx       : int;
  vA        : alpha;
  vX        : int;
  vAufAlt   : int;
  vPosAlt   : word;
  vAufNeu   : int;
  vPosNeu   : word;
  vOK       : logic;
  vHdl      : int;
  vList     : int;
  vAutoLaufzeit : logic;
  v702      : int;
  v703      : int;
  vPos      : int;
  v703RecId : int;
end;
begin
  if (aMode='') then aMode # Mode;

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // Ankerfunktion...
  if (RunAFX('BAG.P.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then RETURN False;
  end;

  // logische Prüfung
  if (BAG.P.Aktion='') then begin
    Msg(001200,Translate('Aktion'),0,0,0);
    $edBAG.P.Aktion->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(828,702,8,_RecFirst);     // Aktion holen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Aktion'),0,0,0);
    $edBAG.P.Aktion->WinFocusSet(true);
    RETURN false;
  end;
  
  // 25.01.2022 AH:
  if (w_Command=*'Ktx.InsertNeuePosNachFert*') then begin
    // 2022-11-24 AH    einfach-Nachspalten
    vOK # false;
    if (BAG.P.Aktion=c_BAG_Spalt) then begin
      v703 # RecBufCreate(703);
      Erx # RecRead(v703, 0, _recId, cnvia(StrCut(w_command,25,20)));      // Fertigung holen
      v702 # RecBufCreate(702);
      Erx # RecLink(v702,v703,2,_recFirst);   // VonPos holen
      if (v702->BAG.P.Aktion=BAG.P.Aktion) then begin
        v703RecId # cnvia(StrCut(w_command,25,20));
      end;
      RecbufDestroy(v703);
      RecbufDestroy(v702);
    end;
    if (v703RecId=0) then begin
      if (BA1_P_Data:Muss1AutoFertigungHaben()=false) then begin
        Msg(702054,BAG.P.Aktion,0,0,0);
        $edBAG.P.Aktion->WinFocusSet(true);
        RETURN false;
      end;
    end;
  end;
  

  if (BAG.P.ExternYN=false) and (BA1_P_Lib:StatusInAnfrage()) then begin
    Msg(702044,'',0,0,0);
    $edBAG.P.Status->WinFocusSet(true);
    RETURN false;
  end;
  if (BAG.P.ExternYN) and (BAG.P.ExterneLiefNr=0) and (BA1_P_Lib:StatusInAnfrage()) then begin
    Lib_Guicom2:InhaltFehlt('Lieferant', 'NB.Page1', 'edBAG.P.ExterneLiefNr');
    RETURN false;
  end;

  if (BAG.P.ExternYN) then begin
    if (BAG.P.ExterneLiefNr<>0) then begin
      Erx # RecLink(100,702,7,_recFirst);   // Adresse holen
      if (Erx>_rLocked) then begin
        Lib_Guicom2:InhaltFalsch('Lieferant', 'NB.Main', 'edBAG.P.ExterneLiefNr');
        RETURN false;
      end;
      if (BAG.P.ExterneLiefAns<>0) then begin
        Adr.A.Adressnr # Adr.Nummer;
        Adr.A.Nummer # BAG.P.ExterneLiefAns;
        Erx # RecRead(101,1,0);
        if (Erx>_rLocked) then begin
          Lib_Guicom2:InhaltFalsch('Lieferant', 'NB.Main', 'edBAG.P.ExterneLiefNr');
          RETURN false;
        end;
      end;
    end;
  end;
    
  // Versandmodul aktiv?
  if (BAG.P.Aktion = c_BAG_Versand) and (Set.LFS.mitVersandYN=false) then begin
    Msg(702021,'',0,0,0);
    $edBAG.P.Aktion->WinFocusSet(true);
    RETURN false;
  end;

  // 09.12.2021 AH : Vorlage muss nicht
  if (BAG.VorlageYN=false) and
    (BAG.P.Aktion = c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (BAG.P.Aktion=c_BAG_ArtPrd) or (BAG.P.Aktion=c_BAG_Umlager) then begin
    // ----------------------------
    // Zieladresse
    // ...ausgefüllt?
    If (BAG.P.Zieladresse = 0) then begin
      Msg(001200,Translate('Zieladresse'),0,0,0);
      $edBAG.P.Zieladresse->WinFocusSet(true);
      RETURN false;
    end;

    // ----------------------------
    // Zielanschrift
    // ...ausgefüllt?
    If (BAG.P.Zielanschrift = 0) then begin
      Msg(001200,Translate('Zielanschrift'),0,0,0);
      $edBAG.P.Zielanschrift->WinFocusSet(true);
      RETURN false;
    end;
    // auch mit richtigen Werten?
  end; //   if (BAG.P.Aktion = c_BAG_FAHR)

  // 19.06.2020 AH
  if (BAG.P.Zieladresse<>0) then begin
    // auch mit richtigen Werten?
    Erx # RecLink(100,702,12,_recTest);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Zieladresse'),0,0,0);
      $edBAG.P.Zieladresse->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(101,702,13,_recTest);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Zielanschrift'),0,0,0);
      $edBAG.P.Zielanschrift->WinFocusSet(true);
      RETURN false;
    end;
  end;

  BAG.P.Auftragsnr # 0;
  BAG.P.AuftragsPos # 0;
  if (BAG.P.Kommission<>'') and (BAG.P.Kommission<>'#') then begin
    vA # StrCut(BAG.P.Kommission,1,1);
     vX # StrFind(BAG.P.Kommission,'/',0);
     if (vA>='0') and (vA<='9') and (vx<>0) then begin
      vA # Str_Token(BAG.P.Kommission,'/',1);
      BAG.P.Auftragsnr # CnvIa(va);
      vA # Str_Token(BAG.P.Kommission,'/',2);
      BAG.P.Auftragspos # CnvIa(va);
    end;
  end;

  // 16.08.2018 AH
  if (BAG.P.AuftragsNr<>0) then begin
    Erx # RecLink(401,702,16,_recFirst);  // AufPos holen
    if (Erx>_rLocked) or ("Auf.P.Löschmarker"<>'') then begin
      if (mode=c_modeNew) or ((Mode=c_ModeEdit) and (ProtokollBuffer[702]->BAG.P.Kommission<>BAG.P.Kommission)) then begin
        Msg(404101, BAG.P.Kommission,_WinIcoError, _WinDialogOk, 1);
        $edBAG.P.Kommission->WinFocusSet(true);
        RETURN false;
      end;
    end;
  end;

  // 03.01.2019 AH:
  vAutoLaufzeit # y;
  if (Set.Installname='BSP') then begin
    REPEAT
      Erx # Msg(99,'Laufzeit neu errechnen?',_WinIcoQuestion,_WinDialogYesNoCancel,3);
    UNTIL (Erx<>_WinIdCancel);
    vAutoLaufzeit # Erx = _winidyes;
  end;


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (aMode=c_ModeEdit) then begin

    TRANSON;

    if (RunAFX('BAG.P.RecSave.VorSave',aMode)<>0) then begin
      if (AfxRes<>_rOk) then begin
        TRANSBRK;
        ERROROUTPUT;
        RETURN False;
      end;
    end;

    // Laufzeitermittlung
    if (vAutoLaufzeit) then
      BA1_Laufzeit:Automatisch(y);

//    RekReplace(gFile,_recUnlock,'MAN');
    Erx # BA1_P_Data:Replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;


    // 05.11.2018
    RecRead(702,1,0);
    App_Main:Refresh();

    // Verbuchen
    vAufAlt # ProtokollBuffer[gFile]->BAG.P.Auftragsnr;
    vPosAlt # ProtokollBuffer[gFile]->BAG.P.Auftragspos;

    // NEU 15.6.2011 AI : nur unverbuchte buchen...
    if ("BAG.P.Löschmarker"='') and (BAG.P.Fertig.Dat=0.0.0) and
      (vAufAlt<>0) and
      ((BAG.P.Auftragsnr<>vAufAlt)  or
      (BAG.P.AuftragsPos<>vPosAlt)) then begin
      vAufNeu # BAG.P.Auftragsnr;
      vPosNeu # BAG.P.AuftragsPos;
      RecRead(702,1,_recLock);
      BAG.P.Auftragsnr  # vAufAlt;
      BAG.P.AuftragsPos # vPosAlt;
      BA1_P_Data:Replace(_recUnlock,'AUTO');
      if (BA1_F_Data:UpdateOutput(702,y)<>y) then begin
        TRANSBRK;
        Msg(702004,gTitle,0,0,0);
        RETURN False;
      end;
      RecRead(702,1,_recLock);
      BAG.P.Auftragsnr  # vAufNeu;
      BAG.P.AuftragsPos # vPosNeu;
      BA1_P_Data:Replace(_recUnlock,'AUTO');
    end;

    if (BAG.P.Auftragsnr<>0) then begin
      if ("BAG.P.Löschmarker"='') and (BAG.P.Fertig.Dat=0.0.0) then begin
        if (BA1_F_Data:UpdateOutput(702)<>y) then begin
          TRANSBRK;
          Error(702004,'');
          Erroroutput;
          RETURN False;
        end;
        vOK # y;
      end
      else begin      // Pos bereits gelöscht?
      end;
    end;


    // ggf. nur LFS-Kopfdaten updaten...
    if (vOK=n) then begin
      if (Lfs_LFA_Data:UpdateLFSKopfzuLFA()=false) then begin
        TRANSBRK;
        Error(702004,'');
        Erroroutput;
        RETURN False;
      end;
    end;

    TextSave();

    TRANSOFF;

    PtD_Main:Compare(gFile);
  end

  else begin    // Neuanlage----------------------------------


    // 04.07.2012 AI  Walzschritte
    if (BAG.P.Aktion=c_BAG_Walz) then begin

      // 23.01.2015 : aus Kundenauftrag?
      vHdl # WinSearch(gMDI, 'lb.zuAuftragsList');
      if (vHdl<>0) OR (Set.Installname='MWH') then begin    // ST 2020-09-02 2106/3/2
        if (cnvia(vHdl->wpcustom)<>0) OR (Set.Installname='MWH') then begin
          if (msg(702039,'',_WinIcoQuestion, _WinDialogYesNo, 1)=_WinIdYes) then begin
            // Eingabetabelle aufrufen...
            gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.F.Walzen.Einzeldicken',here+':AusEinzeldicken',y);
            Lib_GuiCom:RunChildWindow(gMDI);
            RETURN false;
          end;
        end;
      end;
    end;

    // Laufzeitermittlung
    if (vAutoLaufzeit) then
      BA1_Laufzeit:Automatisch(y);

    BAG.P.Position      # 1;
    BAG.P.Anlage.Datum  # Today;
    BAG.P.Anlage.Zeit   # Now;
    BAG.P.Anlage.User   # gUserName;

    TRANSON;

    if (RunAFX('BAG.P.RecSave.VorSave',aMode)<>0) then begin
      if (AfxRes<>_rOk) then begin
        TRANSBRK;
        ERROROUTPUT;
        RETURN False;
      end;
    end;

//  21.01.2019 AH
//    WHILE (RecRead(702,1,_RecTest)<=_rLocked) do
//      BAG.P.Position # BAG.P.Position + 1;
    REPEAT
      if (w_AppendNr<0) then begin  // 11.05.2020 AH
        BAG.P.Position      # -w_AppendNr;
        v702 # RekSave(702);
        vPos # BA1_P_Data:Aufruecken(BAG.P.Nummer, BAG.P.Position);;
        RekRestore(v702);
        if (vPos<0) then begin
          TRANSBRK;
          ErrorOutput;
          RETURN false;
        end;
        w_AppendNr # 0;
        BAG.P.Position # vPos;
      end
      else begin
        v702 # RecBufCreate(702);
        Erx # RecLink(v702,700,1,_recLast);
        if (Erx>=_rNoRec) then begin
          BAG.P.Position # 1;
        end
        else begin
          WHILE (Erx<=_rLocked) and (v702->BAG.P.Position>=100) do begin
            Erx # RecLink(v702,700,1,_recPrev);
          END;
          BAG.P.Position # v702->BAG.P.Position;
        end;
        RecBufDestroy(v702);
      end;
      
      WHILE (RecRead(702,1,_RecTest)<=_rLocked) do
        BAG.P.Position # BAG.P.Position + 1;
     
      Erx # BA1_P_Data:Insert(_recUnlock,'MAN');
    UNTIL (erx=_rOK);
    
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    TextSave();

    // 1 zu 1 Arbeitsgang?
    if (BA1_P_Data:Muss1AutoFertigungHaben()) then begin

      RecBufClear(703);
      // 2022-11-24 AH    Einfach-Nachspalten
      if (v703RecId<>0) then begin
        Recread(703,0,_recId,v703RecId);
        BAG.F.Nummer            # BAG.P.Nummer;
        BAG.F.Position          # BAG.P.Position;
        BAG.F.Fertigung         # 1;
        BAG.F.Streifenanzahl    # 1;
      end
      else begin
        BAG.F.Nummer            # BAG.P.Nummer;
        BAG.F.Position          # BAG.P.Position;
        BAG.F.Fertigung         # 1;
        BAG.F.AutomatischYN     # y;
        "BAG.F.KostenträgerYN"  # y;
        BAG.F.MEH               # 'kg';

        Erx # RecLink(828,702,8,0); // Arbeitsgang holen    18.08.2015
// 2022-12-19  AH        if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
        if ("BAG.P.Typ.xIn-yOutYN"=false) then begin
          BAG.F.MEH # '';
        end
        else begin
          if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
        end;

        BAG.F.Streifenanzahl    # 1;
        BAG.F.Artikelnummer     # ''
        BAG.F.Menge             # 0.0;
/*
      if (BAG.F.MEH='Stk') then
        "BAG.F.Stückzahl"     # cnvif(vMenge)
      else if (BAG.F.MEH='kg') then
        BAG.F.Gewicht # Rnd(vMenge, Set.Stellen.Gewicht);
      else if (BAG.F.MEH='t') then
        BAG.F.Gewicht # Rnd(vMenge / 1000.0, Set.Stellen.Gewicht);

      BAG.F.Dicke             # BAG.IO.Dicke;
      BAG.F.Dickentol         # BAG.IO.Dickentol;
      BAG.F.Breite            # BAG.IO.Breite;
      BAG.F.Breitentol        # BAG.IO.Breitentol;
      "BAG.F.Länge"           # "BAG.IO.Länge";
      "BAG.F.Längentol"       # "BAG.IO.Längentol";
      "BAG.F.Gütenstufe"      # "BAG.IO.Gütenstufe";
      "BAG.F.Güte"            # "BAG.IO.Güte";
  */
      end;
      Erx # BA1_F_Data:Insert(0,'AUTO');
    end;


    if (BAG.P.Aktion=c_BAG_Saegen) then begin // autom. 998. Fertigung anlegen
      RecBufClear(703);
      BAG.F.Nummer            # BAG.P.Nummer;
      BAG.F.Position          # BAG.P.Position;
      BAG.F.Fertigung         # 998;
      BAG.F.AutomatischYN     # y;
      "BAG.F.KostenträgerYN"  # n;
      BAG.F.PlanSchrottYN     # y;
      BAG.F.MEH               # 'kg';   //  2022-12-19  AH  BA1_P_Data:ErmittleMEH();
      if (Set.Installname='HWN') then begin
        BAG.F.PlanSchrottYN     # n;
      end;
      Erx # BA1_F_Data:Insert(0,'AUTO');
      if (BA1_F_Data:UpdateOutput(703,n)=false) then begin
      end;
    end;

    TRANSOFF;   // 2023-07-19 AH s.u.
    
    // ggf. sofort Einsatz anziehen
    vHdl # WinSearch(gMDI, 'lb.zuAuftragsList');
    if (vHdl<>0) then vList # cnvia(vHdl->wpcustom);
    if (vList<>0) then begin
      if (BAG.P.Position=1) then begin
        BA1_Subs:EinsatzLautAuftragsliste(vList, false);
      end
      else begin
        BA1_Subs:WeiterBearbeitungVonPos(BAG.P.Position - 1);
      end;
    end;

// 2023-07-19 AH    TRANSOFF;   muss früher

    // 25.01.2022 AH: dirketes Einbinden
    if (w_Command=*'Ktx.InsertNeuePosNachFert*') then begin
      Erx # RecRead(703, 0, _recId, cnvia(StrCut(w_command,25,20)));      // Fertigung holen
      w_Command # '';
      if (Erx>_rLocked) then RETURN true;
      vOK # BA1_F_Subs:WeiterDurchPos(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, BAG.P.Position);
      cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      ErrorOutput;
      if (vOK) then Msg(999998,'',0,0,0);
      RETURN true;
    end;

  end;  // Neuanlage

//  gZLList->WinUpdate(_Winupdon);
  RefreshList(gZllist, _WinLstRecFromRecid | _WinLstRecDoSelect);


  if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
    w_Command # 'NEW_ARTPRD';
    RETURN true;
  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  if (Mode = c_ModeNew) then RecBufClear(702);

  // 25.01.2022 AH:
  if (w_Command=*'Ktx.InsertNeuePosNachFert*') then begin
    w_COmmand # '';
  end;
  
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx     : int;
  vName : alpha;
  vOK   : logic;
end;
begin


  // bereits gelöscht?
  if ("BAG.P.Löschmarker"<>'') then begin
    Msg(702001,gTitle,0,0,0);
    RETURN;
  end;

  // bereits fertiggemeldet?
  if (BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) or
    (RecLinkInfo(709,702,6,_RecCount)>0) then begin
    Msg(702002,gTitle,0,0,0);
    RETURN;
  end;

  // Input checken
  if (BA1_P_Data:EinsatzVorhanden() = true) then begin
    Msg(702013,gTitle,0,0,0);
    RETURN;
  end;

   // Fertigungen prüfen
  vOK # y;
  FOR Erx # RecLink(703,702,4,_RecFirst)
  LOOP Erx # RecLink(703,702,4,_RecNext)
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (BAG.F.AutomatischYN) then CYCLE;  // 2023-01-30 AH
    if (RecLinkInfo(701,703,4,_recCount)>0) then vOK # n;
  END
  if (vOK=n) then begin
    Msg(702003,gTitle,0,0,0);
    RETURN;
  END;

//  Mode # c_ModeDelete;
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  TRANSON;

  if (BA1_P_Data:Delete(vOK)=false) then begin
    TRANSBRK;
    Erroroutput;
    RETURN;
  end;

  TRANSOFF;

  RecLink(702,700,1,_RecFirst);
  cZList1->Winupdate(_WinUpdOn, _WinLstfromfirst);
  cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst);
  cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst);

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

  // 18.01.2019 AH:
  if (aEvt:Obj->wpchanged) and
    ((aEvt:Obj->wpname='edBAG.P.Plan.Dauer') or  (aEvt:Obj->wpname='edBAG.P.Plan.DauerPost')) then begin
    BAG.P.Plan.ManuellYN # true;
    $cbBAG.P.Plan.ManuellYN->winupdate(_WinupdFld2Obj);
    RETURN true;
  end;

  if (aEvt:Obj->wpchanged) and
    (aEvt:Obj->wpname='edBAG.P.Aktion') then begin
    if (BAG.P.Aktion=c_BAG_Versand) then begin   // 08.11.2021 AH
      BAG.P.ZielVerkaufYN # y;
      $cbBAG.P.ZielVerkaufYN->winupdate();
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
  Erx     : int;
  vA    : alpha;
  vQ    : alpha(4000);
  vHdl  : int;
end;

begin

  case aBereich of
    'Vorlage' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Verwaltung',here+':AusImportVorlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vHdl # gZLList;
      Lib_Sel:QRecList(vHdl,'BAG.VorlageYN=true');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Status' : begin
      Lib_Einheiten:Popup('BAG-STATUS',$edBAG.P.Status,702,1,25);
    end;


    'Kommission' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kopftext' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusKopftext');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Fusstext' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstext');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'KopftextAdd' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusKopftextAdd');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'FusstextAdd' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstextAdd');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edBAG.P.Kosten.MEH,702,3,5);
    end;


    'Zieladresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusZieladresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zielanschrift' : begin
      RecLink(100,702,12,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusZielanschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ResGruppe', 'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0 AND Adr.SperrLieferantYN = false');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LieferantAns' : begin
      if (BAG.P.ExterneLiefNr=0) then RETURN;
      Erx # RecLink(100,702,7,0);   // Adresse holen
      if (Erx>_rLocked) then RETURN;
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLieferantAns');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0, 'Adr.A.Adressnr = '+aint(Adr.nummer));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Arbeitsgang' : begin
      RecBufClear(828);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Arg.Verwaltung',here+':AusArbeitsgang');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusImportVorlage
//
//========================================================================
sub AusImportVorlage()
local begin
  vBAG  : int;
  v700  : int;
end;
begin

  if (gSelected=0) then RETURN;
  v700 # RekSave(700);
  RecRead(700,0,_RecId,gSelected);
  gSelected # 0;
  vBAG # BAG.Nummer;
  RekRestore(v700);

  BA1_P_Data:ImportBA(BAG.Nummer, vBAG, 0,0,true);
  ErrorOutput;
end;


//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    RecLink(400,401,3,_recFirst);   // Kopf holen
    // Feldübernahme
    BAG.P.Auftragsnr    # Auf.P.Nummer;
    BAG.P.Auftragspos   # Auf.P.Position;
    BAG.P.Kommission    # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
//    BAG.P.Zieladresse   # Auf.Lieferadresse;    02.05.2022 AH
//    BAG.P.Zielanschrift # Auf.Lieferanschrift;
//    RecLink(101,702,13,_recFirst);    // Anschrift holen
//    BAG.P.Zielstichwort # Adr.A.Stichwort;
    BAG.P.ZielVerkaufYN # n;
    if (BAG.P.Aktion=c_BAG_Fahr) then begin
      BAG.P.ZielVerkaufYN # y;
      BAG.P.Zieladresse   # Auf.Lieferadresse;    // 02.05.2022 AH
      BAG.P.Zielanschrift # Auf.Lieferanschrift;
      RecLink(101,702,13,_recFirst);    // Anschrift holen
      BAG.P.Zielstichwort # Adr.A.Stichwort;
    end;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Kommission->Winfocusset(false);
  // ggf. Labels refreshen
  gMdi -> WinUpdate();
end;


//========================================================================
//  AusKopftext
//
//========================================================================
sub AusKopftext();
local begin
  vTxtHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,0,0,0,0);
    $te.BA.Pos.Kopf->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $te.BA.Pos.Kopf->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusFusstext
//
//========================================================================
sub AusFusstext();
local begin
  vTxtHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,0,0,0,0);
    $te.BA.Pos.Fuss->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $te.BA.Pos.Fuss->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusKopftextAdd
//
//========================================================================
sub AusKopftextAdd();
local begin
  vTxtHdl   : int;
  vTxtHdl2  : int;
  vI        : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    $te.BA.Pos.Kopf->WinUpdate(_WinUpdObj2Buf);
    vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
    vTxtHdl2 # TextOpen(16);
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl2, 0,0,0,0);
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl2,_TextLines)) do begin
      TextLineWrite(vTxtHdl, TextInfo(vTxtHdl,_textLines)+1, TextLineRead(vTxtHdl2,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl2);
    $te.BA.Pos.Kopf->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $te.BA.Pos.Kopf->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusfusstextAdd
//
//========================================================================
sub AusFusstextAdd();
local begin
  vTxtHdl   : int;
  vTxtHdl2  : int;
  vI        : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    $te.BA.Pos.Fuss->WinUpdate(_WinUpdObj2Buf);
    vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
    vTxtHdl2 # TextOpen(16);
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl2, 0,0,0,0);
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl2,_TextLines)) do begin
      TextLineWrite(vTxtHdl, TextInfo(vTxtHdl,_textLines)+1, TextLineRead(vTxtHdl2,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl2);
    $te.BA.Pos.fuss->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $te.BA.Pos.Fuss->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.ExterneLiefNr   # Adr.LieferantenNr
    BAG.P.ExterneLiefAns  # 1;
    if ($edBAG.P.ExterneLiefAns<>0) then $edBAG.P.ExterneLiefAns->winupdate(_WinUpdFld2Obj);
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.ExterneLiefNr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusLieferantAns
//
//========================================================================
sub AusLieferantAns()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.ExterneLiefAns  # Adr.A.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.ExterneLiefAns->Winfocusset(false);
end;


//========================================================================
//  AusArbeitsgang
//
//========================================================================
sub AusArbeitsgang()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(828,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.Aktion  # ArG.Aktion;
    BAG.P.Aktion2 # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN" # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN" # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN" # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"      # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung # ArG.Bezeichnung;
    gSelected # 0;
  end;

  if (BAG.P.Aktion=c_BAG_Versand) then begin   // 08.11.2021 AH
    BAG.P.ZielVerkaufYN # y;
    $cbBAG.P.ZielVerkaufYN->winupdate();
  end;
  
  if (BAG.P.Aktion<>c_BAG_FAHR) and (BAG.P.Aktion<>c_BAG_Versand) and
      (BAG.P.Aktion<>c_BAG_ArtPrd) and (Bag.P.Aktion <> c_BAG_Umlager) and (Set.BA.Ziel.AktivJN=false) then begin
    BAG.P.Zieladresse     # 0;
    BAG.P.Zielanschrift   # 0;
    BAG.P.Zielstichwort   # '';
    BAG.P.ZielVerkaufYN   # n;
//    Lib_GuiCom:Enable($bt.Kommission);      02.05.2022 AH
//    Lib_GuiCom:Enable($edBAG.P.Kommission);
    Lib_GuiCom:Disable($edBAG.P.Zieladresse);
    Lib_GuiCom:Disable($bt.Zieladresse);
    Lib_GuiCom:Disable($edBAG.P.Zielanschrift);
    Lib_GuiCom:Disable($bt.Zielanschrift);
  end
  else begin
//    Lib_GuiCom:Disable($bt.Kommission);     02.05.2022 AH
//    Lib_GuiCom:Disable($edBAG.P.Kommission);
    Lib_GuiCom:Enable($edBAG.P.Zieladresse);
    Lib_GuiCom:Enable($bt.Zieladresse);
    Lib_GuiCom:Enable($edBAG.P.Zielanschrift);
    Lib_GuiCom:Enable($bt.Zielanschrift);
  end;

  Lib_GuiCom:Able($edBAG.P.Kosten.Pro,  (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($edBAG.P.Kosten.PEH,  (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($edBAG.P.Kosten.MEH,  (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($bt.MEH,              (BAG.P.Aktion<>c_BAG_Umlager));
  Lib_GuiCom:Able($edBAG.P.Kosten.Fix,  (BAG.P.Aktion<>c_BAG_Umlager));


  // Focus auf Editfeld setzen:
  $edBAG.P.Aktion->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edxxx.xxxxxxx');

end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    // Feldübernahme
    BAG.P.Ressource.Grp # Rso.Gruppe;
    BAG.P.Ressource     # Rso.Nummer;
    $edBAG.P.Ressource->WinUpdate();
    $edBAG.P.Ressource.Grp->WinUpdate();
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Ressource->Winfocusset(false);
  if (gSelected<>0) then begin
    gSelected # 0;
    RefreshIfm('edBAG.P.Ressource', y);
  end;
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusZieladresse
//
//========================================================================
sub AusZieladresse()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.P.Zieladresse   # Adr.Nummer;
    BAG.P.Zielanschrift # 1;
    BAG.P.Zielstichwort # Adr.Stichwort;
    $edBAG.P.Zielanschrift->Winupdate(_WinUpdFld2Obj);
    $lb.Zieladresse->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Zieladresse->Winfocusset(false);
//  Auswahl('Zielanschrift');
  // ggf. Labels refreshen
   RefreshIfm('');
end;


//========================================================================
//  AusZielanschrift
//
//========================================================================
sub AusZielanschrift()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.P.Zieladresse   # Adr.A.Adressnr;
    BAG.P.Zielanschrift # Adr.A.nummer;
    BAG.P.Zielstichwort # Adr.A.Stichwort;
    $edBAG.P.Zieladresse->Winupdate(_WinUpdFld2Obj);
    $lb.Zieladresse->Winupdate(_WinUpdFld2Obj);
   end;
  // Focus auf Editfeld setzen:
  $edBAG.P.Zielanschrift->Winfocusset(false);
//  Auswahl('Zielanschrift');
  // ggf. Labels refreshen
  RefreshIfm('');
end;


//========================================================================
//  AusEinzeldicken
//
//========================================================================
sub AusEinzeldicken();
local begin
  Erx       : int;
  vAufList  : int;
  vHdl      : int;
  v703List  : int;
  vItem     : int;
  v703      : int;
  vErr      : int;
  v702      : int;
  vVorgPos  : int;
  vVorlageP : int;

  vSelectedtmp :  int;
  vRid      : float;
  vWgr      : int;
  vDlgResId : int;
  vTmp      : alpha;
end;
begin
  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected=0) then RETURN;

  // ggf. sofort Einsatz anziehen
  vHdl # WinSearch(gMDI, 'lb.zuAuftragsList');
  if (vHdl<>0) then vAufList # cnvia(vHdl->wpcustom);


  if (vAufList<>0) then begin
    // ST 2012-12-11: RID abfragen
    vSelectedtmp  #gSelected;
    vRid  # 0.0;
    vTmp # '508';
    if (Dlg_Standard:Standard('Fertigungs-RID', var vTmp) = false) then
      RETURN;
    vRid  # CnvFa(vTmp);
    gSelected # vSelectedtmp;
  end
  else begin
    vVorlageP # BAG.P.Position;
    // ST Bugfix für MWH
    //Erx # RecLink(702,701,4,_recFirst);   // 1. Fertigung der aktuellen Walzung holen
    Erx # RecLink(703,702,4,_recFirst);   // 1. Fertigung der aktuellen Walzung holen
    if (Erx<=_rLocked) then vRid # BAG.F.RID;
  end;


  TRANSON;

  v703List # gSelected;
  gSelected # 0;

  BAG.P.Position # 1;
  vItem # v703List->CteRead(_CteFirst)
  WHILE (vItem > 0) and (vErr=0) do begin

    // Position anlegen
    WHILE (RecRead(702,1,_RecTest)<=_rLocked) do
      BAG.P.Position # BAG.P.Position + 1;
//    RekInsert(gFile,0,'MAN');
    Erx # BA1_P_Data:Insert(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      vErr # 001000+Erx;
      CYCLE;
    end;
    TextSave();

    // jede Fertigung einzeln anlegen...
    RecBufCopy(vItem->spid, 703);
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Rid               # vRid;
    Erx # BA1_F_Data:Insert(0,'AUTO');


    // Erste Position?
    if (v702=0) then begin
      v702 # RekSave(702);

      if (vAufList=0) then begin
        BA1_Subs:WeiterBearbeitungVonPos(vVorlageP);
      end
      else begin  // aus Auftragsliste
        if (BAG.P.Position=1) then begin
          BA1_Subs:EinsatzLautAuftragsliste(vAufList, TRUE);  // 2023-07-19 AH : Silent, da in TRANSAKTION
        end
        else begin
          BA1_Subs:WeiterBearbeitungVonPos(BAG.P.Position - 1);
        end;
      end;

    end
    else begin
      BA1_Subs:WeiterBearbeitungVonPos(vVorgPos);
    end;

    vVorgPos # BAG.P.Position;

    BA1_P_Data:ErrechnePlanmengen();    // Fertigungen durchrechnen seit 23.01.2015

    vItem # v703List->CteRead(_CteNext,vItem);
  END;


  // Aufräumen
  vItem # v703List->CteRead(_CteFirst)
  WHILE (vItem > 0) do begin
    RecBufDestroy(vItem->spid);
    v703List->CteDelete(vItem);
    vItem->CteClose();
    vItem # v703List->CteRead(_CteFirst);
  END;
  CteClear(v703List,y);
  v703List->cteclose();


  // Fehler? -> Abbruch
  if (vErr<>0) then begin
    TRANSBRK;
    if (v702<>0) then RekRestore(v702);
    if (vErr=1000) then ErrorOutput
    else Msg(vErr,gTitle,0,0,0);
    RETURN;
  end;

  TRANSOFF;

  Mode # c_ModeCancel;
  Lib_GuiCom:SetMaskState(false);
  vHdl # gMdi->winsearch('NB.List');
  if (vHdl<>0) then vHdl->wpdisabled # false;
  vHdl # gMdi->winsearch('NB.Main');
  if (vHdl<>0) then vHdl->wpCurrent # 'NB.List';
  Mode # c_ModeList;

  if (v702<>0) then RekRestore(v702);
  App_Main:RefreshMode(); // Buttons & Menues anpassen

  BA1_P_Data:UpdateSort();

  gZLList->WinUpdate();
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Graphnotebook richtig setzen
  vHdl # gMdi->WinSearch('NB.Graph');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_modeEdit) or (Mode=c_modeNew);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ("BAG.Löschmarker"='*') or (Rechte[Rgt_BAG_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ("BAG.Löschmarker"='*') or (Rechte[Rgt_BAG_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Vorlage.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN=false) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMenu->WinSearch('Mnu.Messerbauplan');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion<>c_BAG_Spalt) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMenu->WinSearch('Mnu.Walzschritte');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion<>c_BAG_Walz) or (Rechte[Rgt_BAG_Anlegen]=n) or ("BAG.P.Löschmarker"<>'') or ("BAG.Löschmarker"<>'');

  vHdl # gMenu->WinSearch('Mnu.AutoVersandVSB.All');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Set.LFS.mitVersandYN=false) or (Rechte[Rgt_BAG_Anlegen]=n) or ("BAG.P.Löschmarker"<>'') or ("BAG.Löschmarker"<>'');

  vHdl # gMenu->WinSearch('Mnu.AutoVpgVersandVSB.All');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Set.LFS.mitVersandYN=false) or (Rechte[Rgt_BAG_Anlegen]=n) or ("BAG.P.Löschmarker"<>'') or ("BAG.Löschmarker"<>'');

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
  Erx     : int;
  vHdl    : int;
  vParent : int;
  vOK     : logic;
  vTmp    : int;
  vF      : float;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of
    'Ktx.StundeInMinuten' : vF # aEvt:Obj->wpcaptionfloat * 60.0;
    'Ktx.TageInMinuten' :   vF # aEvt:Obj->wpcaptionfloat * 60.0 * 24.0;

    'Mnu.Vorlage.Import' : begin    // 28.02.2022 AH
      if (BAG.VorlageYN) then begin
        Auswahl('Vorlage');
      end;
    end;


    'Mnu.Pos.ZwischenDraengeln' : begin   // 11.05.2020 AH
      w_AppendNr # -BAG.P.Position;
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;

    'Mnu.Pos.Merge' : begin
      BA1_P_Subs:Merge(BAG.P.Nummer, BAG.P.Position);
      cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Walzschritte'  : begin
      if (RecLinkInfo(701,702, 2, _reccount)=0) then begin // kein Input ?
        Msg(702042,'',0,0,0);
        RETURN true;
      end;

      FOR Erx # RecLink(701, 702, 3, _recFirst)
      LOOP Erx # RecLink(701, 702, 3, _recNext)
      WHILE (Erx<=_rLocked) do begin
        if (BAG.IO.NachBAG<>0) then begin
          Msg(702043,'',0,0,0);
          RETURN true;
        end;
      END;

      // Eingabetabelle aufrufen...
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.F.Walzen.Einzeldicken',here+':AusEinzeldicken',y);
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN false;
    end;


    'Mnu.Messerbauplan' : begin
      if (Rechte[Rgt_BAG_Aendern]) then
        BA1_PZ_Messerbau:Start(BAG.P.Nummer, BAG.P.Position);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(702,BAG.P.Anlage.Datum, BAG.P.Anlage.Zeit, BAG.P.Anlage.User);
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(702);
    end;


    'Mnu.Druck.Lohnformular' : begin
      if (BAG.P.ExternYN = true) then begin

        // Lohnbetrieb lesen um die Sprache herauszubekommen
        RecLink(100,702,7,_RecFirst);
        // ST 2013-06-14: Neue Version, Aufruf über Sub für alle Arbeitsgänge
        BA1_P_Subs:Print_Lohnformular(BAG.P.Nummer, BAG.P.Position);
      end;
    end;


    'Mnu.Arbeitsschritte': begin
      RecBufClear(706);
      if (BAG.P.Aktion=c_BAG_Walz) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.AS.Walz.Verwaltung','',y)
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.AS.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end


    'Mnu.Verpackungen' : begin
      RecBufClear(704);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.V.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end


    'Mnu.AutoVSB' : begin
      BA1_P_Data:CheckVSBzuAufREST();
      if (Msg(702005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        if (BA1_P_Data:AutoVSB()=y) then begin
          Msg(702006,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          cZList2->Winfocusset(true); // 2022-12-08 AH
          RETURN true;
        end
        else begin
          ErrorOutput;
          Msg(702007,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          RETURN true;
        end;
      end;
    end;


    'Mnu.AutoVpgVersandVSB.All' : begin
      if (Msg(702055,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        Erx # RecLink(702,700,1,_RecFirst);   // Arbeitsgänge loopen
        vOK # y;
        WHILE (Erx<=_rLocked) and (vOK) do begin
          vOK # BA1_P_Data:AutoVSB(true,true)
          Erx # RecLink(702,700,1,_RecNext);
        END;
        if (vOK) then begin
          Msg(999998,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          cZList2->Winfocusset(true); // 2022-12-08 AH
          RETURN true;
        end
        else begin
          ErrorOutput;
          Msg(999999,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          RETURN true;
        end;
      end;
    end;


    'Mnu.AutoVersandVSB.All' : begin
//      BA1_P_Data:CheckVSBzuAufREST(true);
      if (Msg(702053,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        Erx # RecLink(702,700,1,_RecFirst);   // Arbeitsgänge loopen
        vOK # y;
        WHILE (Erx<=_rLocked) and (vOK) do begin
          vOK # BA1_P_Data:AutoVSB(true)
          Erx # RecLink(702,700,1,_RecNext);
        END;
        if (vOK) then begin
          Msg(999998,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          cZList2->Winfocusset(true); // 2022-12-08 AH
          RETURN true;
        end
        else begin
          ErrorOutput;
          Msg(999999,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          RETURN true;
        end;
      end;
    end;
    
    
    'Mnu.AutoVSB.All' : begin
      BA1_P_Data:CheckVSBzuAufREST(true);
      if (Msg(702017,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        Erx # RecLink(702,700,1,_RecFirst);   // Arbeitsgänge loopen
        vOK # y;
        WHILE (Erx<=_rLocked) and (vOK) do begin
          vOK # BA1_P_Data:AutoVSB()
          Erx # RecLink(702,700,1,_RecNext);
        END;
        if (vOK) then begin
          Msg(702006,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          cZList2->Winfocusset(true); // 2022-12-08 AH
          RETURN true;
        end
        else begin
          ErrorOutput;
          Msg(702007,'',0,0,0);
          cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
          cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
          RETURN true;
        end;
      end;
    end;


    'Mnu.DelVSB.All' : begin
      if (Msg(702029, '', _WinIcoQuestion, _WinDialogYesNo, 1) = _WinIdYes) then begin
        if(BA1_P_Data:DelAllVSB() = false) then begin
          Error(702030,'');
          ErrorOutput;
        end;

        cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
        cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      end;
    end;


    'Mnu.Einsatz' : begin
      vParent # gMDI;
      RecBufClear(701);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.IO.I.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
      vParent->wpvisible # false;
    end;


    'Mnu.Fertigung' : begin
      vParent # gMDI;
      RecBufClear(703);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.F.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
      vParent->wpvisible # false;
    end;


    'Mnu.Zeiten' : begin
      RecBufClear(709);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.Z.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end; // case

  if (vF<>0.0) then begin
    aEvt:Obj->wpcaptionfloat # vF;
    Winupdate(aEvt:Obj,_WinUpdObj2Fld);
  end;

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
    'bt.Status'       :   Auswahl('Status');
    'bt.Arbeitsgang'  :   Auswahl('Arbeitsgang');
    'bt.Lieferant'    :   Auswahl('Lieferant');
    'bt.LieferantAns' :   Auswahl('LieferantAns');
    'bt.Zieladresse'  :   Auswahl('Zieladresse');
    'bt.Zielanschrift' :  Auswahl('Zielanschrift');
    'bt.Kommission'   :   Auswahl('Kommission');
    'bt.ResGruppe'    :   Auswahl('ResGruppe');
    'bt.Ressource'    :   Auswahl('Ressource')
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Kopftext'     :   Auswahl('Kopftext');
    'bt.Fusstext'     :   Auswahl('Fusstext');
    'bt.Kopftext.Add' :   Auswahl('KopftextAdd');
    'bt.Fusstext.Add' :   Auswahl('FusstextAdd');
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
  RETURN BA1_Combo_Main:EvtPageSelect(aEvt, aPage, aSelecting);
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbBAG.P.ExternYN') then begin
    if (BAG.P.ExternYN) then begin
      BAG.P.Ressource.Grp # 0;
      BAG.P.Ressource     # 0;
      $lb.ResGruppe->wpcaption # '';
      $lb.Ressource->wpcaption # '';
      $edBAG.P.Ressource.Grp->winupdate(_WinUpdFld2Obj);
      $edBAG.P.Ressource->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edBAG.P.Ressource.Grp);
      Lib_GuiCom:Disable($edBAG.P.Ressource);
      Lib_GuiCom:Disable($bt.ResGruppe);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Enable($bt.Lieferant);
      Lib_GuiCom:Enable($edBAG.P.ExterneLiefNr);
      Lib_GuiCom:Enable($edBAG.P.ExterneLiefAns);
    end
    else begin
      BAG.P.ExterneLiefNr   # 0;
      BAG.P.ExterneLiefAns  # 0;
      $lb.Lieferant->wpcaption # '';
      $edBAG.P.ExterneLiefNr->winupdate(_WinUpdFld2Obj);
      if ($edBAG.P.ExterneLiefAns<>0) then $edBAG.P.ExterneLiefAns->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Enable($edBAG.P.Ressource.Grp);
      Lib_GuiCom:Enable($edBAG.P.Ressource);
      Lib_GuiCom:Enable($bt.ResGruppe);
      Lib_GuiCom:Enable($bt.Ressource);
      Lib_GuiCom:Disable($bt.Lieferant);
      Lib_GuiCom:Disable($edBAG.P.ExterneLiefNr);
      Lib_GuiCom:Disable($edBAG.P.ExterneLiefAns);
    end;
  end;

  if (aEvt:Obj->wpname='edBAG.P.Aktion') then begin
    $edBAG.P.Aktion->Winupdate(_WinUpdObj2Fld);
    Erx # RecLink(828,702,8,0);
    if (Erx>_rLocked) then RecBufClear(828);
    BAG.P.Aktion  # ArG.Aktion;
    BAG.P.Aktion2 # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN" # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN" # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN" # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"      # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung # ArG.Bezeichnung
    $Lb.Bezeichnung->WinUpdate(_WinUpdFld2Obj);

    Lib_GuiCom:Able($cbBAG.P.ZielVerkaufYN, (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand));

    if (BAG.P.Aktion<>c_BAG_Fahr) and (BAG.P.Aktion<>c_BAG_Versand) and
        (BAG.P.Aktion<>c_BAG_ArtPrd) and (BAG.P.Aktion<>c_BAG_Umlager) and (Set.BA.Ziel.AktivJN=false) then begin
      BAG.P.Zieladresse     # 0;
      BAG.P.Zielanschrift   # 0;
      BAG.P.Zielstichwort   # '';
      BAG.P.ZielVerkaufYN   # n;
//      Lib_GuiCom:Enable($bt.Kommission);
//      Lib_GuiCom:Enable($edBAG.P.Kommission);
      Lib_GuiCom:Disable($edBAG.P.Zieladresse);
      Lib_GuiCom:Disable($bt.Zieladresse);
      Lib_GuiCom:Disable($edBAG.P.Zielanschrift);
      Lib_GuiCom:Disable($bt.Zielanschrift);
    end
    else begin
      BAG.P.Zieladresse     # 0;
      BAG.P.Zielanschrift   # 0;
      BAG.P.Zielstichwort   # '';
      BAG.P.ZielVerkaufYN   # n;
//      Lib_GuiCom:Disable($bt.Kommission);
//      Lib_GuiCom:Disable($edBAG.P.Kommission);
      Lib_GuiCom:Enable($edBAG.P.Zieladresse);
      Lib_GuiCom:Enable($bt.Zieladresse);
      Lib_GuiCom:Enable($edBAG.P.Zielanschrift);
      Lib_GuiCom:Enable($bt.Zielanschrift);
    end;
    $edBAG.P.Zieladresse->Winupdate(_WinUpdFld2Obj);
    $edBAG.P.Zielanschrift->Winupdate(_WinUpdFld2Obj);
  end;
end;


//========================================================================
// TextSave
//
//========================================================================
sub TextSave()
local begin
  vTxtHdl   : int;          // Handle des Textes
  vName     : alpha;
end;
begin
//  if (BAG.P.Nummer>=100000000) or (BAG.P.Position>=100) then RETURN;

  // KopfTextBuffer holen
  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
  if (vTxtHdl=0) then RETURN;

  $te.BA.Pos.Kopf->WinUpdate(_WinUpdObj2Buf);
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
  // Kopftext speichern
//  if ($te.BA.Pos.Kopf->wpcustom=vName) then begin
    if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
      TxtDelete(vName,0)
    else
      TxtWrite(vTxtHdl,vName, _TextUnlock);
//  end;
  $te.BA.Pos.Kopf->wpcustom # '';


  // FussTextBuffer holen
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
  $te.BA.Pos.Fuss->WinUpdate(_WinUpdObj2Buf);
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
  // Kopftext speichern
//  if ($te.BA.Pos.Fuss->wpcustom=vName) then begin
    if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
      TxtDelete(vName,0)
    else
      TxtWrite(vTxtHdl,vName, _TextUnlock);
  $te.BA.Pos.Fuss->wpcustom # '';
//  end;

END;


//========================================================================
// TextLoad
//
//========================================================================
sub TextLoad()
local begin
  vTxtHdl     : int;          // Handle des Textes
  vName       : alpha;
end
begin

//  if (BAG.P.Nummer>=100000000) or (BAG.P.Position>=100) then RETURN;

  // KopfText laden
  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $te.BA.Pos.Kopf->wpdbTextBuf # vTxtHdl;
  end;
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
  if ($te.BA.Pos.Kopf->wpcustom<>vName) or (Mode=c_ModeView) then begin
    if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then
      TextClear(vTxtHdl);
    $te.BA.Pos.Kopf->wpcustom # vName;
    $te.BA.Pos.Kopf->WinUpdate(_WinUpdBuf2Obj);
  end;

  // FussText laden
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $te.BA.Pos.Kopf->wpdbTextBuf # vTxtHdl;
  end;
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
  if ($te.BA.Pos.Fuss->wpcustom<>vName) or (Mode=c_ModeView) then begin
    if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then
      TextClear(vTxtHdl);
    $te.BA.Pos.Fuss->wpcustom # vName;
    $te.BA.Pos.Fuss->WinUpdate(_WinUpdBuf2Obj);
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
local begin
  Erx     : int;
  vBuf701   : int;
  vBuf703   : int;
  vOffen    : logic;
end;
begin

  RunAFX('BAG.P.EvtLstDataInit',aint(aEvt:Obj)+'|'+aint(aRecId));

  // 21.03.2016 AH: Markierungen anzeigen
  aMark # Lib_Mark:IstMarkiert( gFile, RecInfo( gFile, _recId ));
  if (aMark) then
    Lib_GuiCom:ZLColorLine( gZLList, Set.Col.RList.Marke, true );

  
  if (w_Command='NEW_ARTPRD') then begin
    w_COmmand # '';
    if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.F.ArtPrd.Maske', '',y,y);
      Lib_guiCom:ObjSetPos(gMDI,10,0);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeNew;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    RETURN;
  end;


  GV.Alpha.04 # BAG.P.Bezeichnung;
  if (BAG.P.Aktion=c_BAG_Walz) then begin
    vBuf703 # RecBufCreate(703);
    Erx # RecLink(vBuf703,702,4,_recFirst);     // Fertigungen loopen
    if (Erx<=_rLocked) then
      GV.Alpha.04 # GV.Alpha.04 + ' '+anum(vBuf703->BAG.F.Dicke,Set.Stellen.Dicke);
    RecBufDestroy(vBuf703);
  end;
  if (BAG.P.Level>1) then
    Gv.Alpha.04 # StrChar(32,(BAG.P.Level*3)-3)+GV.Alpha.04;

  //if (gMDI->wpname<>'BA1.Combo.Verwaltung') then RETURN;
  // offene kommissionierte Enden?? dann Position ROT färben
  if (aMark=n) and (BAG.P.Typ.VSBYN=n) then begin
    vBuf701 # RekSave(701);
    vBuf703 # RekSave(703);
    vOffen # n;
    Erx # RecLink(703,702,4,_recFirst);     // Fertigungen loopen
    WHILE (Erx<=_rLocked) and (vOffen=n) do begin
      if (BAG.F.Kommission<>'') then begin
        Erx # RecLink(701,702,3,_recFirst); // Output loopen
        WHILE (Erx<=_rLocked) and (vOffen=n) do begin
          if (BAG.IO.NachBAG=0) then begin
            // aus stornierter FM? 23.01.2019 AH
            Erx # RecLink(707,701,18,_RecFirst);
            if (Erx<=_rLocked) then begin
              if (BAG.FM.Status<>1) then begin
                Erx # RecLink(701,702,3,_recNext);
                CYCLE;
              end;
            end;
            vOffen # y;
            BREAK;
          end;
          Erx # RecLink(701,702,3,_recNext);
        END;
      end
      Erx # RecLink(703,702,4,_recNext);
    END;
    RekRestore(vBuf701);
    RekRestore(vBuf703);
  end;
  if (vOffen) then begin
    Lib_GuiCom:ZLColorLine(aEvt:obj, RGB(250,0,0) );
  end;

//  else
//    Lib_GuiCom:ZLColorLine(gZLList, RGB(255,255,255));

//  Refreshmode();
end;


//========================================================================
//  EvtLstRecControl
//
//========================================================================
sub EvtLstRecControl(
  aEvt                 : event;    // Ereignis
  aRecID               : int;      // Record-ID des Datensatzes
) : logic;
begin
  // kein VSB, gelöscht und kein Versand anzeigen
  RETURN ("BAG.P.Typ.VSBYN"=false) and
//15.10.2021 AH  (BAG.P.Aktion <> c_BAG_Versand) and
            (Bag.P.Aktion <> c_BAG_Umlager) and ("BAG.P.Löschmarker"='');
end;


//========================================================================
//  AuswahlEvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub AuswahlEvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
begin
  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    $BA1.P.Auswahl->Winclose();
  end;
end;


//========================================================================
//  AuswahlEvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub AuswahlEvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin
  if (aButton=_WinMouseDouble | _WinMouseLeft) then begin
    gSelected # aID;
    $BA1.P.Auswahl->Winclose();
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
local begin
  vOK     : logic;
  vTxtHdl : int;
end;
begin
  if ($te.BA.Pos.Kopf=0) then RETURN false;  // 28.01.2021 AHGWS
  vTxtHdl # $te.BA.Pos.Kopf->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    $te.BA.Pos.Kopf->wpdbTextBuf # 0;;
    TextClose(vTxtHdl);
  end;
  vTxtHdl # $te.BA.Pos.Fuss->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    $te.BA.Pos.Fuss->wpdbTextBuf # 0;
    TextClose(vTxtHdl);
  end;

  RETURN Call(Lib_Guicom:GetAlternativeMain(gMDI, 'BA1_Combo_Main')+':EvtClose', aEvt);
end;


//========================================================================
// Auswahl_EvtInit
//
//========================================================================
sub Auswahl_EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  $ZL.BAG.P.Auswahl->wpcustom # cnvai(gZLList);
  gZLList   # $ZL.BAG.P.Auswahl;
end;


//========================================================================
// Auswahl_EvtClose
//
//========================================================================
sub Auswahl_EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  gZLList # cnvia($ZL.BAG.P.Auswahl->wpcustom);
  RETURN true;
end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vA      : alpha;
  vFile   : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if (vFile=828) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;
	
  RETURN false;
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  Erx     : int;
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vPos    : int;
  vNr     : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      828 : begin
        Erx # RecRead(vFile,0,_RecId,vID);    // Satz holen
        if (Erx<>_rOK) then begin
        	RETURN (false);
        end;

        // ZIEL Fenster aktiveren
        WinUpdate(WinInfo(aEvt:obj, _WinFrame), _WinUpdActivate );
        // globale Daten vom ZIEL holen
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));


        RecBufClear(702);
        BAG.P.Nummer      # BAG.Nummer;
        BAG.P.Kosten.Wae  # 1;
        BAG.P.Kosten.PEH  # 1000;
        BAG.P.Kosten.MEH  # 'kg';
        BAG.P.Aktion      # ArG.Aktion;
        BAG.P.Aktion2     # ArG.Aktion2;
        "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
        "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
        "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
        "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
        BAG.P.Bezeichnung       # ArG.Bezeichnung;

        // Speichern wie bei Neuanlage...
        RecSave(c_ModeNew);

        cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      end;

    end;

  end;

	RETURN (false);
end


/*========================================================================
2022-08-30  AH        Proj. 2429/513
========================================================================*/
sub EvtMenuInitPopup(
  aEvt                  : event;        // Ereignis
  aMenuItem             : handle;       // Auslösender Menüeintrag
) : logic;
local begin
  vMenu : int;
  vItem : int;
end;
begin

  // Kontext - Menü
  if (aMenuItem <> 0) then RETURN true;

  // Ermitteln des Kontextmenüs des Frame-Objektes.
  vMenu # aEvt:Obj->WinInfo(_WinContextMenu);
  if (vMenu = 0) then RETURN true;

  // ersten Eintrag löschen, wenn kein Titel angegeben ist
  vItem # vMenu->WinInfo(_WinFirst);
  if (vItem > 0 and vItem->wpCaption = '') then vItem->WinMenuItemRemove(FALSE);
  vItem # 0;
  
  vItem # vMenu->WinMenuItemAdd('Ktx.StundeInMinuten', Translate('Stunde in Minuten'),1);
  vItem # vMenu->WinMenuItemAdd('Ktx.TageInMinuten', Translate('Tage in Minuten'),2);
  vItem # vMenu->WinMenuItemAdd('','', 3);
  vItem->wpMenuseparator # true
  RETURN(true);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================