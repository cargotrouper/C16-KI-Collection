@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  04.11.2011  AI  EvtPosChanged
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  06.06.2013  AI  Intrastat als F9
//  19.06.2013  AH  Katalognummer nicht mehr eindeutig
//  27.06.2013  AH  Leerzeichen am ENDE der Art.Nummer werden entfernt
//  28.10.2013  AH  NEU: Filterfunktion
//  08.01.2015  AH  NEU: Recalc unter Inventur
//  18.05.2015  AH  Artikeltyp SET
//  30.07.2015  AH  Artikelgruppe in RecList
//  17.09.2015  ST  Erweiterung "Sub Start"
//  01.12.2015  AH  Neue Inventur
//  30.05.2016  AH  Bug: Beu Neuanlage werden bei Focusverlust die TExte gelöscht
//  16.06.2016  AH  Bug: Text wurde nicht beim dirketen Editieren geladen (F6)
//  30.08.2016  AH  Neu: Buttons für Bestand, Reserivert etc.
//  13.02.2018  AH  Neu: Bestell-Lieferverträge
//  31.08.2018  ST  Bug: Autodispo startet jetzt mit angegebenen Tag
//  24.08.2020  AH  Neu: Adress-Artikel
//  28.09.2020  AH  Neu: Artikelrecalc für markierte
//  27.07.2021  AH  ERX
//  07.10.2021  AH  Edit: Summierung vom Material in den Artikel per Mat.Status
//  23.02.2022  AH  Neu: Ausführungen
//  14.07.2022  HA Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusWarengruppe()
//    SUB AusArtikelgruppe()
//    SUB AusSLK()
//    SUB AusObf()
//    SUB AusEtikettentyp()
//    SUB AusEKText()
//    SUB AusVKText()
//    SUB AusPRDText()
//    SUB AusInfo()
//    SUB AusIntrastat();
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtKeyItem(aevt : event; aKey : int; aRecId : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic
///   SUB EvtLstRecControl...
//    SUB EvtLstDataInit(aevt : event; aRecid : int) : logic;
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB TxtRead()
//    SUB TxtSave()
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle           :   'Artikel'
  cFile            :   250
  cMenuName        :  'Art.Bearbeiten'
  cPrefix          :  'Art'
  cZList           :   $ZL.Artikel
  cKey             :   1
//  cGewStellen       : 3


  cDialog     : 'Art.Verwaltung'
  cRecht      : Rgt_Artikel
  cMdiVar     : gMDIArt

end;

declare TxtSave();
declare TxtRead();
Declare Update_FertData( aevt : event)



//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aArtNr   : alpha;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aArtNr<>'') then begin
    Art.Nummer # aArtNr;
    Erx # RecRead(250,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(250,_recID);
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
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  Filter_Art # y;

  $edArt.Bestand.Min->wpDecimals # Set.Stellen.Menge;
  $edArt.Bestand.Soll->wpDecimals # Set.Stellen.Menge;
  $edArt.Bestand.Inventur->wpDecimals # Set.Stellen.Menge;


Lib_Guicom2:Underline($edArt.Warengruppe);
Lib_Guicom2:Underline($edArt.Artikelgruppe);
Lib_Guicom2:Underline($edArt.Guete);
Lib_Guicom2:Underline($edArt.Oberflaeche);
Lib_Guicom2:Underline($edArt.Etikettentyp);
Lib_Guicom2:Underline($edArt.Stueckliste);
Lib_Guicom2:Underline($edArt.Intrastatnr);

  SetStdAusFeld('edArt.Stueckliste'       ,'SL');
  SetStdAusFeld('edArt.Warengruppe'       ,'Warengruppe');
  SetStdAusFeld('edArt.Artikelgruppe'     ,'Artikelgruppe');
  SetStdAusFeld('edArt.PEH'               ,'PEH');
  SetStdAusFeld('edArt.MEH'               ,'MEH');
  SetStdAusFeld('edArt.Bilddatei'         ,'Bilddatei');
  SetStdAusFeld('edArt.Typ'               ,'TYP');
  SetStdAusFeld('edArt.Guete'             ,'Guete');
  SetStdAusFeld('edArt.Oberflaeche'       ,'Oberfläche');
  SetStdAusFeld('edArt.Intrastatnr'       ,'Intrastat');
  SetStdAusFeld('edArt.Etikettentyp'      ,'Etikettentyp');
  SetStdAusFeld('edArt.AF.Oben'         ,'AF.Oben');
  SetStdAusFeld('edArt.AF.Unten'        ,'AF.Unten');

  // Ankerfunktion?
//  RunAFX('Art.Init',aint(aEvt:Obj));


//  if (Sel_Main:LoadXML2Captions(0,'250.xml')) then begin
//    Art_Mark_Sel:StartSel(y);
//  end;

  RunAFX('Art.Init.Pre',aint(aEvt:Obj));

  App_Main:EvtInit(aEvt);

  RunAFX('art.Init',aint(aEvt:Obj));

  $edArt.SpezGewicht->wpDecimals  # 4;
  $edArt.Gewicht->wpDecimals      # 4;
  $edArt.Gewichtm->wpDecimals     # 4;

end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Art;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edArt.Nummer);
  Lib_GuiCom:Pflichtfeld($edArt.Stichwort);
  Lib_GuiCom:Pflichtfeld($edArt.Typ);
  Lib_GuiCom:Pflichtfeld($edArt.Warengruppe);
  Lib_GuiCom:Pflichtfeld($edArt.Artikelgruppe);
  Lib_GuiCom:Pflichtfeld($edArt.PEH);
  Lib_GuiCom:Pflichtfeld($edArt.MEH);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx     : int;
  vTxtHdl : int;
  vHdl    : int;
end;
begin

  $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  
  if (aName='') then begin
    vTxtHdl # $Art.EKText1->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.EKText1->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.EKText2->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.EKText2->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.EKText3->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.EKText3->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.EKText4->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.EKText4->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.EKText5->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.EKText5->wpdbTextBuf # vTxtHdl;
    end;

    vTxtHdl # $Art.VKText1->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.VKText1->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.VKText2->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.VKText2->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.VKText3->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.VKText3->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.VKText4->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.VKText4->wpdbTextBuf # vTxtHdl;
    end;
    vTxtHdl # $Art.VKText5->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.VKText5->wpdbTextBuf # vTxtHdl;
    end;

    vTxtHdl # $Art.PRDText1->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Art.PRDText1->wpdbTextBuf # vTxtHdl;
    end;

    TxtRead();

    $Lb.needSLRefresh->wpvisible # "Art.SLRefreshNötigYN";

  end;


  if (aName='') or (aName='edArt.Nummer') then begin
    $Lb.Artikelnr->wpcaption # Art.Nummer;
  end;

  if (aName='') or (aName='edArt.MEH') then begin
    $Lb.MEH1->wpcaption   # Art.MEH;
    $Lb.MEH2->wpcaption   # Art.MEH;
    $Lb.MEH3->wpcaption   # Art.MEH;
    $Lb.MEH4->wpcaption   # Art.MEH;
    $Lb.MEH5->wpcaption   # Art.MEH;
    $Lb.MEH6->wpcaption   # Art.MEH;
    $Lb.MEH7->wpcaption   # Art.MEH;
    $Lb.MEH8->wpcaption   # Art.MEH;
    $Lb.MEH9->wpcaption   # Art.MEH;
    $Lb.MEH10->wpcaption  # Art.MEH;
  end;

  if (aName='') or (aName='edArt.Stueckliste') then begin
    if ((mode=c_ModeNew) or (mode=c_modeEdit)) then begin
      if ("Art.Stückliste"<>0) then
        Lib_GuiCom:Disable($edArt.Fert.Dauer);
      else
        Lib_GuiCom:Enable($edArt.Fert.Dauer)
    end;

    Erx # RecLink(255,250,22,_RecFirst);    // aktive Stückliste holen
    if (Erx<=_rLocked) then begin
      $Lb.Stueckliste->wpcaption # Art.SLK.Name;
      Art.Fert.Dauer    # Art.SLK.Fert.Dauer;
      $edArt.Fert.Dauer->winupdate();
      end
    else begin
      $Lb.Stueckliste->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edArt.Warengruppe') then begin
    Erx # RecLink(819,250,10,0);    // Warengruppe holen
    if (Erx<=_rLocked) then
      $Lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.Warengruppe->wpcaption # '';

    if ($edArt.Warengruppe->wpchanged) then begin
      if (Art.SpezGewicht = 0.0) and (Wgr_Data:GetDichte(Wgr.Nummer, 250) <> 0.0) then
        Art.SpezGewicht # Wgr_Data:GetDichte(Wgr.Nummer, 250);
      /*
      if (Wgr.Dateinummer=c_Wgr_ArtMatMix) then begin
        Art.MEH # 'kg';
        $edArt.MEH->winupdate();
        Lib_GuiCom:Disable($edArt.MEH);
        Lib_GuiCom:Disable($bt.MEH);
      end
      else
      */
      if ((mode = c_ModeNew) or (Art_Data:ArtAktionExist() = '')) then begin
        Lib_GuiCom:Enable($edArt.MEH);
        Lib_GuiCom:Enable($bt.MEH);
      end;
    end;
  end;



  if (aName='') or (aName='edArt.Artikelgruppe') then begin
    Erx # RecLink(826,250,11,0);
    if (Erx<=_rLocked) then
      $Lb.Artikelgruppe->wpcaption # Agr.Bezeichnung.L1
    else
      $Lb.Artikelgruppe->wpcaption # '';
  end;



  if (aName='') or (aName='edArt.Oberflaeche') then begin
    Erx # RecLink(841,250,16,0);
    if (Erx<=_rLocked) then
      $Lb.Oberflaeche->wpcaption # Obf.Bezeichnung.L1
    else
      $Lb.Oberflaeche->wpcaption # '';
  end;

  if (aName='') or (aName='edArt.Bilddatei') then begin
    $Picture1->wpcaption # '*'+Art.Bilddatei;
  end;


  if (aName='') or (aName='edArt.Etikettentyp') then begin
    Erx # RecLink(840,250,23,_recfirst);    // Etikettentyp holen
    if (Erx<=_rLocked) then
      $Lb.Etikettentyp->wpcaption # Eti.Bezeichnung
    else
      $Lb.Etikettentyp->wpcaption # '';
  end;


  if (aName='') then begin
    RecBufClear(252);
    if (Mode <> c_Modenew) then begin
      Art.C.ArtikelNr   # Art.Nummer;
      if (Art.Nummer <> '') then
        Art_Data:ReadCharge();
    end;
    w_Appendnr # 0;
    $Lb.Bestand->wpcaption    # ANum(Art.C.Bestand, Set.Stellen.Menge);
    $Lb.Reserviert->wpcaption # ANum(Art.C.Reserviert - Art.C.Kommissioniert, Set.Stellen.Menge);
//    $lb.Reserviert->wpHelpTip # ANum(Art.C.Kommissioniert, Set.Stellen.Menge)+' '+Art.MEH+' '+translate('kommissioniert');
    $lb.Kommissioniert->wpCaption # ANum(Art.C.Kommissioniert, Set.Stellen.Menge);
    $lb.Vormaterial->wpCaption # ANum(Art.C.Fremd, Set.Stellen.Menge);
    
    $Lb.Bestellt->wpcaption   # ANum(Art.C.Bestellt, Set.Stellen.Menge);
    $Lb.Verfuegbar->wpcaption # ANum("Art.C.Verfügbar", Set.Stellen.Menge);
    $Lb.AufRest->wpcaption    # ANum("Art.C.OffeneAuf", Set.Stellen.Menge);
  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

  Pflichtfelder();

  // dynamische Pflichtfelder einfaerben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

  if (aName='edArt.Guete') and ($edArt.Guete->wpchanged) then begin
    Art.Werkstoffnr # '';
    if (MQu_Data:Autokorrektur(var "Art.Güte")) then Art.Werkstoffnr # MQu.Werkstoffnr;
    $edArt.Werkstoffnr->Winupdate(_WinUpdFld2Obj);
    $edArt.Guete->Winupdate();
  end;

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx : int;
end;
begin

  if ("Art.ChargenführungYN"=y) then begin
    Lib_GuiCom:Enable($cbArt.SeriennrYN);
    end
  else begin
    Art.SeriennummerYN # false;
    $cbArt.SeriennrYN->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Disable($cbArt.SeriennrYN);
  end;

  if ("Art.AutoBestellYN") then begin
    Lib_GuiCom:Enable($edArt.Dispotage);
    end
  else begin
    Lib_GuiCom:Disable($edArt.Dispotage);
  end;

  // Focus setzen auf Feld:
  if (Mode=c_ModeEdit) then
    $edArt.Bezeichnung1->WinFocusSet(true)
  else
    $edArt.Nummer->WinFocusSet(true);


  if (Mode=c_ModeNew) then begin

    // Atikel kopieren...
    if (w_AppendNr<>0) then begin
      Art.ID # w_AppendNr;
      RecRead(250,12,0);
      Refreshifm();
      Art.ID                  # 0;
      "Art.SLRefreshNötigYN"  # n;
      "Art.Stückliste"        # 0;

      Art.Bestand.Inventur    # 0.0;

      // Ausführungen kopieren ********************
      Erx # RecLink(257,250,27,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        Art.AF.ArtikelID # myTmpNummer;
        RekInsert(257,0,'AUTO');

        Art.AF.ArtikelID # Art.ID;
        Erx # RecLink(257,250,27,_RecNext);
      END;

      
    end
    else begin
      Art.Warengruppe   # Set.Art.Warengruppe;
      Art.Artikelgruppe # Set.Art.Artikelgrupp;
      Art.PEH           # Set.Art.PEH;
      Art.MEH           # Set.Art.MEH;
      Art.Typ           # Set.Art.Typ;

      if ($Art.EKText1->wpdbTextBuf<>0) then begin
        TextClear($Art.EKText1->wpdbTextBuf);
        TextClear($Art.EKText2->wpdbTextBuf);
        TextClear($Art.EKText3->wpdbTextBuf);
        TextClear($Art.EKText4->wpdbTextBuf);
        TextClear($Art.EKText5->wpdbTextBuf);
        TextClear($Art.VKText1->wpdbTextBuf);
        TextClear($Art.VKText2->wpdbTextBuf);
        TextClear($Art.VKText3->wpdbTextBuf);
        TextClear($Art.VKText4->wpdbTextBuf);
        TextClear($Art.VKText5->wpdbTextBuf);
        TextClear($Art.PrdText1->wpdbTextBuf);
        // 30,05.2016:
        $Art.EKText1->WinUpdate(_WinUpdBuf2Obj)
        $Art.EKText2->WinUpdate(_WinUpdBuf2Obj)
        $Art.EKText3->WinUpdate(_WinUpdBuf2Obj)
        $Art.EKText4->WinUpdate(_WinUpdBuf2Obj)
        $Art.EKText5->WinUpdate(_WinUpdBuf2Obj)
        $Art.VKText1->WinUpdate(_WinUpdBuf2Obj)
        $Art.VKText2->WinUpdate(_WinUpdBuf2Obj)
        $Art.VKText3->WinUpdate(_WinUpdBuf2Obj)
        $Art.VKText4->WinUpdate(_WinUpdBuf2Obj)
        $Art.VKText5->WinUpdate(_WinUpdBuf2Obj)
        $Art.PrdText1->WinUpdate(_WinUpdBuf2Obj)

      end;
    end;
    Art.ID            # myTmpNummer;
  end
  else if (Mode=c_ModeEdit) then begin
    // 14.08.2015
    if (Rechte[Rgt_Art_Aendern_Fuehrung]=false) then begin
      Lib_GuiCom:Disable($cbArt.ChargenfuehrungYN);
      Lib_GuiCom:Disable($cbArt.LagerjournalYN);
      Lib_GuiCom:Disable($cbArt.SeriennrYN);
      Lib_GuiCom:Disable($edArt.PEH);
    end;
  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vOk   : logic;
  vBuf  : Int;
  vNr   : int;
end;
begin

  // logische Prüfung
  if(Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() = false) then
    RETURN false;

  if (Mode=c_ModeNew) then Art.Nummer # StrAdj(Art.Nummer, _StrEnd);

  If (Art.Nummer='') then begin
    Msg(001200,Translate('Artikelnummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Nummer->WinFocusSet(true);
    RETURN false;
  end;
  If (Art.Stichwort='') then begin
    Msg(001200,Translate('Stichwort'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Stichwort->WinFocusSet(true);
    RETURN false;
  end;
  If (Art.Typ='') then begin
    Msg(001200,Translate('Typ'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Typ->WinFocusSet(true);
    RETURN false;
  end;

  If (Art.Warengruppe=0) then begin
    Msg(001200,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(819,250,10,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;

  If (Art.Artikelgruppe=0) then begin
    Msg(001200,Translate('Artikelgruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Artikelgruppe->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(826,250,11,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Artikelgruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Artikelgruppe->WinFocusSet(true);
    RETURN false;
  end;

  If (Art.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.PEH->WinFocusSet(true);
    RETURN false;
  end;
  If (Art.MEH='') then begin
    Msg(001200,Translate('Mengeneinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.MEH->WinFocusSet(true);
    RETURN false;
  end;
  If (Lib_Einheiten:CheckMEH(var Art.MEH)=false) then begin
    Msg(001201,Translate('Mengeineinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.MEH->WinFocusSet(true);
    RETURN false;
  end;


  If (Art.Typ<>c_Art_PRD) and (Art.Typ<>c_Art_HDL) and (Art.Typ<>c_art_BGR) and (Art.Typ<>c_art_SET) and
    (Art.Typ<>c_art_VPG) and (Art.Typ<>c_art_CUT) and (Art.Typ<>c_Art_EXP) then begin
    Msg(001201,Translate('Artikeltyp'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.Typ->WinFocusSet(true);
    RETURN false;
  end;

  vOk # y;
  if (Art.Nummer<>'') then begin
    Erx # RecRead(250,1,_Rectest);
    if (Erx<=_rMultikey) then begin
      vBuf # RecBufCreate(250);
      RecBufCopy(250,vBuf);
      RecRead(250,1,0);
      vOk # ((vBuf->Art.Nummer)=Art.Nummer);
      RecBufCopy(vBuf,250);
      RecBufDestroy(vBuf);
    end;
    if (vOk=n) then begin
      Msg(250000,'',0,0,0);
      RETURN false;
    end;
  end;

/*
  if (Art.SachNummer<>'') then begin
    Erx # RecRead(250,3,_Rectest);
    if (Erx<=_rMultikey) then begin
      vBuf # RecBufCreate(250);
      RecBufCopy(250,vBuf);
      RecRead(250,3,0);
      vOk # ((vBuf->Art.Nummer)=Art.Nummer);
      RecBufCopy(vBuf,250);
      RecBufDestroy(vBuf);
    end;
    if (vOk=n) then begin
      Msg(250001,'',0,0,0);
      RETURN false;
    end;
  end;
*/
/** 19.06.2013
  if (Art.KatalogNr<>'') then begin
    Erx # RecRead(250,5,_Rectest);
    if (Erx<=_rMultikey) then begin
      vBuf # RecBufCreate(250);
      RecBufCopy(250,vBuf);
      RecRead(250,5,0);
      vOk # ((vBuf->Art.Nummer)=Art.Nummer);
      RecBufCopy(vBuf,250);
      RecBufDestroy(vBuf);
    end;
    if (vOk=n) then begin
      Msg(250002,'',0,0,0);
      RETURN false;
    end;
  end;
**/

  if ("ARt.Oberfläche"<>0) then begin
    Erx # RecLink(841,250,16,0);    // Oberfläche holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Oberfläche'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edArt.Oberflaeche->WinFocusSet(true);
      RETURN false;
    end;
  end;
/***
  if ("Art.Länge"<>0.0) then begin
    if ("Art.GewichtProm"=0.0) then
      "Art.GewichtProm" # "Art.GewichtProStk" / "Art.Länge" * 1000.0;
    if ("Art.GewichtProStk"=0.0) then
      "Art.GewichtProStk" # "Art.GewichtProm" * "Art.Länge" / 1000.0;
  end;
***/
  if ("Art.GewichtProm"=0.0) then Art_Data:CalcGewichtProM();
  if ("Art.GewichtProStk"=0.0) then Art_Data:CalcGewichtProStk();
  
  
  // Nummernvergabe

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    if (Protokollbuffer[250]->"Art.Stückliste"<>"Art.Stückliste") then
      "Art.SLRefreshNötigYN"  # y;

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TxtSave();

    PtD_Main:Compare(gFile);

  end
  else begin

    TRANSON;
    
    vNr # Lib_Nummern:ReadNummer('Artikel');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN false;
    end;

    // Ausführungen kopieren
    Art.ID # myTmpNummer;
    WHILE (RecLink(257,250,27,_RecFirst)=_rOk) do begin
      RecRead(257,1,_recLock);
      Art.AF.ArtikelID # vNr;
      Erx # RekReplace(257,_recUnlock,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN false;
      end;
    END;

    Art.ID            # vNr;
    Art.Anlage.Datum  # SysDate();
    Art.Anlage.Zeit   # now;
    Art.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;
    
    TxtSave();
  end;

  // Artikel-Summen-Charge anlegen
  RecBufClear(252);
  Art.C.ArtikelNr   # Art.Nummer;
  Art_Data:OpenCharge(y);
  Art.C.Dicke           # Art.Dicke;
  Art.C.Breite          # Art.Breite;
  "Art.C.Länge"         # "Art.Länge";
  Erx # Art_data:WriteCharge(n);

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  $Art.EKText1->wpcustom # '';

  // Ausführungen löschen
  if (Mode=c_ModeNew) then begin
    WHILE (RecLink(257,250,27,_RecFirst)<=_rLocked) do begin
      RekDelete(257,0,'MAN');
    END;
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  vExist : alpha;
end
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001, '', _WinIcoQuestion, _WinDialogYesNo, 2)= _WinIdNo) then
    RETURN;

  vExist # Art_Data:ArtAktionExist();
  if(vExist <> '') then begin
    Msg(001006, vExist, 0, 0, 0);
    RETURN;
  end;

  TRANSON;
  
  if (RekDelete(gFile, 0, 'MAN')=_rOK) then begin
    // Ausführungen löschen
    WHILE (RecLink(257,250,27,_RecFirst)<=_rLocked) do begin
      RekDelete(257,0,'MAN');
    END;

    if (gZLList->wpDbSelection<>0) then begin
      SelRecDelete(gZLList->wpDbSelection,gFile);
      RecRead(gFile, gZLList->wpDbSelection, 0);
    end;
  end;

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

  if (aEvt:obj->wpname='edArt.AF.Oben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','250|1');
  if (aEvt:obj->wpname='edArt.AF.Unten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','250|2');

  
  // logische Prüfung von Verknüpfungen
  case (aevt:obj -> wpname) of
    'edArt.DickenTol' : if (Art.Dicke<>0.0) then begin
      "Art.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("Art.Dickentol",Set.Stellen.Dicke);
      $edArt.Dickentol->Winupdate();
    end;


    'edArt.BreitenTol' : if (Art.Breite<>0.0) then begin
      "Art.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("Art.Breitentol",Set.Stellen.Breite);
      $edArt.Breitentol->Winupdate();
    end;


    'edArt.LngenTol' : if ("Art.Länge"<>0.0) then begin
      "Art.Längentol" # Lib_Berechnungen:Toleranzkorrektur("Art.Längentol","Set.Stellen.Länge");
      $edArt.LngenTol->Winupdate();
    end;


    'edArt.Stueckliste' :
      if (aFocusObject<>0) then
        if (aFocusObject->wpname='edArt.Ferf.Dauer') and ("Art.Stückliste"<>0) then begin
          Lib_GuiCom:Disable($edArt.Fert.Dauer);
          RETURN false;
        end;


    'edArt.Gewicht' : if ($edArt.Gewicht->wpchanged) and ("Art.Länge"<>0.0) then begin
//      "Art.GewichtProm" # "Art.GewichtProStk" / "Art.Länge" * 1000.0;
      Art_Data:CalcGewichtProM();
      $edArt.Gewichtm->winupdate(_WinUpdFld2Obj);
      end;


    'edArt.Gewichtm' : if ($edArt.Gewichtm->wpchanged) and ("Art.Länge"<>0.0) then begin
//      "Art.GewichtProStk" # "Art.GewichtProm" * "Art.Länge" / 1000.0;
      Art_Data:CalcGewichtProStk();
      $edArt.Gewicht->winupdate(_WinUpdFld2Obj);
      end;

    /***
    'edArt.Sachnummer' : begin
      if (mode =  c_modenew) and (Art.Sachnummer<>'') then begin
        Erx # recread(250,3,_rectest);
        if (Erx < _rnokey) then begin
          Msg(250001,'',0,0,0);
          $NB.Main->wpcurrent # 'NB.Page1';
          RETURN false;
        end;
      end;
    end;
    ***/

  end; // end case

  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
local begin
   tMode    : int;
   tSpez    : float;
   tFlaeche,
   tVol     : float;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  tVol # 0.0;
  tFlaeche # 0.0;
  if (aEvt:Obj->wpname='cbArt.ChargenfuehrungYN') then begin
    if ("Art.ChargenführungYN"=y) then begin
      Lib_GuiCom:Enable($cbArt.SeriennrYN);
      end
    else begin
      Art.SeriennummerYN # false;
      $cbArt.SeriennrYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($cbArt.SeriennrYN);
    end;
  end;

  if (aEvt:Obj->wpname='cbArt.AutoBestellYN') then begin
    if ("Art.AutoBestellYN") then begin
      Lib_GuiCom:Enable($edArt.Dispotage);
      end
    else begin
      Lib_GuiCom:Disable($edArt.Dispotage);
    end;
  end;

  if (aEvt:Obj->wpname='edArt.Sachnummer') then begin
    $edArt.Sachnummer->winupdate(_WinUpdObj2Fld);
    Art.Nummer # Art.Sachnummer;
    $lb.Artikelnr->wpcaption # Art.Nummer;
  end;

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
  Erx         : int;
  vA          : alpha;
  vHdl,vHdl2  : int;
  vFilter     : int;
  vSel        : int;
  vQ          : alpha(4000);
  vSelName    : alpha;
  vTmp        : int;
end;
begin

  case aBereich of

    'AF.Oben'        : begin
      vFilter # RecFilterCreate(257,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.ID);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(257,250,27,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end
      RecBufClear(257);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.AF.Verwaltung',here+':AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(257,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.ID);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Unten'       : begin
      vFilter # RecFilterCreate(257,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.ID);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(257,250,27,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end;
      RecBufClear(257);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.AF.Verwaltung',here+':AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(257,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.ID);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
      gZLlist->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    
    'SL'  : begin
      RecBufClear(255);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.SLK.Verwaltung',here+':AusSLK');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gzllist->wpdbLinkfileno # 255;
      gzllist->wpdbKeyno      # 1;
      gzllist->wpdbfileno     # 250;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edArt.MEH,250,1,13);
    end;


    'TYP' : begin
      Lib_Einheiten:Popup('ARTIKELTYP',$edArt.Typ,250,1,9);
    end;


    'EKText' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusEKText');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'L';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VKText' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusVKText');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'L';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'PRDText' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusPRDText');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'B';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Warengruppe' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '<>', Wgr_Data:WertHuB());
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '<>', Wgr_Data:WertMaterial());
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikelgruppe' : begin
      RecBufClear(826);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Agr.Verwaltung',here+':AusArtikelgruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Bilddatei' : begin
      Art.Bilddatei # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, Adr.Pfad.Bild, 'Bilddateien|*.bmp;*.jpg;*.gif');
      $edArt.Bilddatei->winupdate(_WinUpdFld2Obj);
      RefreshIfm('edArt.Bilddatei');
    end;


    'Guete'          : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Oberfläche' : begin
      RecBufClear(841);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusObf');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Etikettentyp' : begin
      RecBufClear(840);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettentyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

/***
    'Reservierungen' : begin
      RecBufClear( 251 );
      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Art.R.Verwaltung', '', y );
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      //vHdl # Winsearch(gMDI,'ZL.Art.Reservierungen');
      gZLLIst->wpdbkeyno  # 19;
      gZLLIst->wpdbfileno # 250;
//      vQ # '';
//      Lib_Sel:QAlpha(var vQ, 'Art.R.Artikelnr', '=', Art.Nummer);
//      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
***/

    'Intrastat' : begin
/*
      if (Msg(220001,'',0,_WinDialogYesNo,1)=_WinIdYes) then begin
*/

      RecBufClear(220);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      // Selektion
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'MSL.Strukturtyp', '=', 'INTRA');
      Lib_Sel:QAlpha(var vQ, 'MSL.Intrastatnr', '>', '');

      vSel # SelCreate(220, gKey);
      Erx # vSel->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      gZLList->wpDbSelection # vSel;
      w_SelName # vSelName;

      Lib_GuiCom:RunChildWindow(gMDI);

    end;

  end;

end;


//========================================================================
//  AusEinzelObfOben
//
//========================================================================
sub AusEinzelObfOben()
local begin
  vFilter : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(257);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.AF.Verwaltung',here+':AusAFOben');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(257,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.ID);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '1';

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:';
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;

    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusEinzelObfUnten
//
//========================================================================
sub AusEinzelObfUnten()
local begin
  vFilter : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(257);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.AF.Verwaltung',here+':AusAFUnten');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(257,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.ID);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '2';

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:';
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;

    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
local begin
  vTmp  : int;
  vA    : alpha;
end;
begin
  gSelected # 0;

  vA # Obf_Data:BildeAFString(250,'1');
  if (vA<>"Art.AusführungOben") then RunAFX('Obf.Changed','250|1');
  "Art.AusführungOben" # vA;

  // Focus auf Editfeld setzen:
  $edArt.AF.Oben->Winfocusset(true);

  vTmp # WinFocusget();   // LastFocus-Feld refreshen
  if (vTmp <> 0) then
    vTmp->Winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
local begin
  vTmp  : int;
  vA    : alpha;
end;
begin
  gSelected # 0;

  vA # Obf_Data:BildeAFString(250,'2');
  if (vA<>"Mat.AusführungUnten") then RunAFX('Obf.Changed','250|2');
  "Art.AusführungUnten" # vA;

  // Focus auf Editfeld setzen:
  $edArt.AF.Unten->Winfocusset(true);

  vTmp # WinFocusget();   // LastFocus-Feld refreshen
  if (vTmp <> 0) then
    vTmp->Winupdate(_WinUpdFld2Obj);

end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Art.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Art.Güte" # "MQu.Güte1"
    else
      "Art.Güte" # "MQu.Güte2";
    Art.Werkstoffnr # MQu.Werkstoffnr;
    $edArt.Werkstoffnr->Winupdate(_WinUpdFld2Obj);
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edArt.Guete->Winfocusset(false);
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819, 0, _RecId, gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.Warengruppe # Wgr.Nummer;
    if (Art.SpezGewicht=0.0) and (Wgr_Data:GetDichte(Wgr.Nummer, 250) <> 0.0) then begin
      Art.SpezGewicht # Wgr_Data:GetDichte(Wgr.Nummer, 250);
      $edArt.SpezGewicht->winupdate();  // 2023-08-23 AH
    end;
    /*
    if (Wgr.Dateinummer=c_Wgr_ArtMatMix) then begin
      Art.MEH # 'kg';
      $edArt.MEH->winupdate();
      Lib_GuiCom:Disable($edArt.MEH);
      Lib_GuiCom:Disable($bt.MEH);
    end
    else
    */
    if ((mode=c_ModeNew) or (Art_Data:ArtAktionExist() = ''))then begin
      Lib_GuiCom:Enable($edArt.MEH);
      Lib_GuiCom:Enable($bt.MEH);
    end;

    vHdl # WinFocusget();   // LastFocus-Feld refreshen

    if (vHdl<>0) then
      vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edArt.Warengruppe');
end;


//========================================================================
//  AusArtikelgruppe
//
//========================================================================
sub AusArtikelgruppe()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(826,0,_RecId,gSelected);
    // Feldübernahme
    Art.Artikelgruppe # Agr.Nummer;
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then
      vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Artikelgruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.Artikelgruppe');
end;


//========================================================================
//  AusSLK
//
//========================================================================
sub AusSLK()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(255,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Art.Stückliste"  # Art.SLK.Nummer;
    Art.Fert.Dauer    # Art.SLK.Fert.Dauer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then
      vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Stueckliste->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.Stueckliste');
end;


//========================================================================
//  AusMenuSLK
//
//========================================================================
sub AusMenuSLK()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    if (mode=c_modeview) then begin
      gMDI->winupdate();
      Refreshifm();
    end;
  end;
end;


//========================================================================
//  AusObf
//
//========================================================================
sub AusObf()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(841,0,_RecId,gSelected);
    // Feldübernahme
    "Art.Oberfläche" # Obf.Nummer;
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Oberflaeche->Winfocusset(false);
end;


//========================================================================
//  AusEtikettentyp
//
//========================================================================
sub AusEtikettentyp()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(840,0,_RecId,gSelected);
    // Feldübernahme
    Art.Etikettentyp # Eti.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus setzen:
  $edArt.Etikettentyp->Winfocusset(false);
  RefreshIfm('edArt.Etikettentyp');
end;


//========================================================================
//  AusEKText
//
//========================================================================
sub AusEKText()
local begin
  vL1,vL2,vL3,vL4,vL5 : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    vL1 # $Art.EKText1->wpdbTextBuf;
    vL2 # $Art.EKText2->wpdbTextBuf;
    vL3 # $Art.EKText3->wpdbTextBuf;
    vL4 # $Art.EKText4->wpdbTextBuf;
    vL5 # $Art.EKText5->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
      vL1, vL2, vL3, vL4, vL5);
    $Art.EKText1->WinUpdate(_WinUpdBuf2Obj);
    $Art.EKText2->WinUpdate(_WinUpdBuf2Obj);
    $Art.EKText3->WinUpdate(_WinUpdBuf2Obj);
    $Art.EKText4->WinUpdate(_WinUpdBuf2Obj);
    $Art.EKText5->WinUpdate(_WinUpdBuf2Obj);
  end;
  gSelected # 0;
end;


//========================================================================
//  AusVKText
//
//========================================================================
sub AusVKText()
local begin
  vL1,vL2,vL3,vL4,vL5 : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    vL1 # $Art.VKText1->wpdbTextBuf;
    vL2 # $Art.VKText2->wpdbTextBuf;
    vL3 # $Art.VKText3->wpdbTextBuf;
    vL4 # $Art.VKText4->wpdbTextBuf;
    vL5 # $Art.VKText5->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
      vL1, vL2, vL3, vL4, vL5);
    $Art.VKText1->WinUpdate(_WinUpdBuf2Obj);
    $Art.VKText2->WinUpdate(_WinUpdBuf2Obj);
    $Art.VKText3->WinUpdate(_WinUpdBuf2Obj);
    $Art.VKText4->WinUpdate(_WinUpdBuf2Obj);
    $Art.VKText5->WinUpdate(_WinUpdBuf2Obj);
  end;
  gSelected # 0;
end;


//========================================================================
//  AusPRDText
//
//========================================================================
sub AusPRDText()
local begin
  vL1 : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    vL1 # $Art.PRDText1->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
      vL1, 0 ,0, 0, 0);
    // Textpuffer an Felderübergeben
    $Art.PRDText1->WinUpdate(_WinUpdBuf2Obj);
  end;
  gSelected # 0;
end;


//========================================================================
//  AusInfo
//
//========================================================================
sub AusInfo()
begin
  gSelected # 0;
  // Focus auf Editfeld setzen:
  if (Mode=c_ModeList) then
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  if (Mode=c_ModeView) then
    Refreshifm();
end;


//========================================================================
//  AusIntrastat
//
//========================================================================
sub AusIntrastat()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    Art.Intrastatnr # MSL.Intrastatnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edArt.Intrastatnr->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx   : int;
  vHdl  : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  Erx # RecLink(819,250,10,0);    // Warengruppe holen
  if (Erx>_rLocked) then
    RecBufClear(819);

  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMenu->WinSearch('Mnu.Preise');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Art_Preise]=false));

  vHdl # gMenu->WinSearch('Mnu.ChargenDetail');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or
      (Rechte[Rgt_Art_Chargen]=false));

  vHdl # gMenu->WinSearch('Mnu.Journal');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Wgr_data:IstMix() or
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Art_Journal]=false));

  vHdl # gMenu->WinSearch('Mnu.Mark.SetField');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_SerienEdit]=false;
  vHdl # gMenu->WinSearch('Mnu.Mark.SetVK1');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_SerienEdit]=false;
  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Import]=false;

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Anlegen]=n);
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Autodispo');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Art_AutoDispo]=false));

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Art_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Inventur');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeLisT) and (Mode<>c_ModeView)) or //Wgr_data:IstMix() or
                      (Rechte[Rgt_Art_Inventur]=n);

  vHdl # gMenu->WinSearch('Mnu.Inv.Leeren');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or //Wgr_data:IstMix() or
                      (Rechte[Rgt_Art_Inv_Uebernahme]=n);
  vHdl # gMenu->WinSearch('Mnu.Inv.Mengenermittlung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or //Wgr_data:IstMix() or
                      (Rechte[Rgt_Art_Inv_Uebernahme]=n);
  vHdl # gMenu->WinSearch('Mnu.Inv.EinArtikel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or //Wgr_data:IstMix() or
                      (Rechte[Rgt_Art_Inv_Uebernahme]=n);
  vHdl # gMenu->WinSearch('Mnu.Inv.AlleArtikel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Art_Inv_Uebernahme]=n);
  vHdl # gMenu->WinSearch('Mnu.Inv.DelohneInv');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Art_Inv_Uebernahme]=n);
  vHdl # gMenu->WinSearch('Mnu.Recalc');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Art_Recalc]=n);


  vHdl # gMenu->WinSearch('Mnu.SL.Refresh');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Art_SL_Recalc]=n);


  vHdl # gMenu->WinSearch('Mnu.Extras.Produktion');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Art.Typ<>c_Art_Prd) or
                      (Rechte[Rgt_Art_manuellePRD]=n);

  vHdl # gMenu->WinSearch('Mnu.Extras.Wareneingang');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Art_manuellerWE]=n);




  /*if (Wgr.Dateinummer <> c_Wgr_ArtMatMix) and*/
    if(Mode<>c_ModeList) and (Mode<>c_ModeView) and (Art_Data:ArtAktionExist() = '') then begin
    vHdl # gMdi->WinSearch('bt.MEH');
    if (vHdl <> 0) then
      Lib_GuiCom:Enable($bt.MEH);

    vHdl # gMdi->WinSearch('edArt.MEH');
    if (vHdl <> 0) then
      Lib_GuiCom:Enable($edArt.MEH);
  end;

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;


//========================================================================
//========================================================================
sub Cmd_ChargenDetail(opt aSumNr : int) : logic;
local begin
  Erx     : int;
  vHdl    : int;
  vQ      : alpha(4000);
  vStatus : alpha(4000);
end;
begin
  Erx # RekLink(819,250,10,0);    // Warengruppe holen

  // MATERIALCHARGE?
  if (Wgr_data:IstMix()) then begin
    RecBufClear(200);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung','',y);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    RecBufClear(998);
    Sel.Art.von.ArtNr # Art.Nummer;
    vQ # '';
    Lib_Sel:QAlpha( var vQ, 'Mat.Strukturnr', '=', Sel.Art.von.ArtNr);

    // 07.10.2021 AH
    if (aSumNr>0) then begin
      vStatus # Art_Data:MatStatusQuery(aSumNr);
      if (vStatus<>'') then
        vQ # vQ + ' AND ('+vStatus+')';
    end;

    Lib_Sel:QRecList(0,vQ);
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  RecBufClear(252);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung','',y);
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  vQ # '';
  Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
  Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
  Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
  Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
  vHdl # SelCreate(252, gKey);
  Erx # vHdl->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vHdl);
  // speichern, starten und Name merken...
  w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;

  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN true;
end;


//========================================================================
//========================================================================
sub Cmd_Kommissioniert() : logic;
begin
// TODO 07.10.2021 AH
end;


//========================================================================
//========================================================================
sub Cmd_Bestellungen(opt aTyp : alpha) : logic;
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vQ2   : alpha(4000);
  vHdl  : int;
end;
begin
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ein.P.Verwaltung',here+':AusInfo',y,n,'-INFO');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  vQ # '';
  Lib_Sel:QAlpha(var vQ, 'Ein.P.ArtikelNr'      , '=', Art.Nummer);
  if (aTyp='Rahmen') then begin
    vQ # vQ + ' AND LinkCount(Kopf) > 0 ';
    vQ2 # '"Ein.LiefervertragYN"';
  end
  else if (aTyp='Abruf') then begin
    vQ # vQ + ' AND LinkCount(Kopf) > 0 ';
    vQ2 # '"Ein.AbrufYN"';
  end;

  vHdl # SelCreate(501, gKey);
  if (vQ2<>'') then
    vHdl->SelAddLink('',500, 501, 3, 'Kopf');
  Erx # vHdl->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vHdl)
  else if (vQ2<>'') then begin
    Erx # vHdl->SelDefQuery('Kopf', vQ2);
    if (Erx != 0) then Lib_Sel:QError(vHdl);
  end;

  // speichern, starten und Name merken...
  w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN true;
end;


//========================================================================
//========================================================================
sub Cmd_Dispo() : logic;
begin
  // Sonderfunktion:
  if (RunAFX('Art.Dispoliste','250_401_-RES_409_501_701')<>0) then begin
    RETURN true;
  end;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung',here+':AusInfo',y,n);
  Art_Disposition2:Show('Dispoliste','250_401-Res_-RES_409_501_701',y,n, gMDI);
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;


//========================================================================
//========================================================================
sub Cmd_Dispo_Verfuegbar() : logic;
local begin
  vA  : alpha;
end;
begin

  vA # '250_-701_RES';
  if (Set.Art.Vrfgb.AufRst) then begin
    vA # vA + '_401_409';
  end;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung',here+':AusInfo',y,n);
  Art_Disposition2:Show('Verfügbar', vA,y,n, gMDI);
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;


//========================================================================
//========================================================================
sub Cmd_Dispo_Res() : logic;
begin

  // REINER ARtikel?
  if (Wgr_data:IstMix()=false) then begin
    RecBufClear( 251 );
    gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Art.R.Verwaltung', '', y );
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    gZLLIst->wpdbkeyno  # 19;
    gZLLIst->wpdbfileno # 250;
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung',here+':AusInfo',y,n);
  Art_Disposition2:Show('Reservierungen','-701_RES',n,n, gMDI); // RES_701
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN true;
end;


//========================================================================
//========================================================================
sub Cmd_Dispo_Vormaterial() : logic;
begin

  // REINER ARtikel?
  if (Wgr_data:IstMix()=false) then RETURN false;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung',here+':AusInfo',y,n);
  Art_Disposition2:Show('Vormaterial','VORMAT',n,n, gMDI);
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN true;
end;


//========================================================================
//========================================================================
sub Cmd_Dispo_AufRest() : logic;
begin
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung',here+':AusInfo',y,n);
  Art_Disposition2:Show('offene Aufträge','401_409',n,n, gMDI)
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN true;
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
  vFilter : int;
  iRoot   : int;
  vSel    : alpha;
  vQ      : alpha(4000);
  vDat    : date;
  vA      : alpha;
  vText   : alpha;
  vOK     : logic;
  vRef    : int;
end;
begin

  iRoot # wininfo(aevt:obj,_winframe);
  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Filter.Start' : begin
      Art_Mark_Sel('250.xml');
      RETURN true;
    end;


    'Mnu.SL.Refresh.All' : begin
      if (Rechte[Rgt_Art_SL_Recalc]) then begin
        Erx # Msg(250010,'',_WinIcoQuestion,_WinDialogYesNo,1);
        if (Erx=_Winidyes) then Art_SL_Data:RecalcStruct(y,'');
      end;
    end;
    'Mnu.SL.Refresh.This' : begin
      if (Rechte[Rgt_Art_SL_Recalc]) then begin
        Erx # Msg(250013,'',_WinIcoQuestion,_WinDialogYesNo,1);
        if (Erx=_Winidyes) then Art_SL_Data:RecalcStruct(n,Art.Nummer);
      end;
    end;
    'Mnu.SL.Refresh.Need' : begin
      if (Rechte[Rgt_Art_SL_Recalc]) then begin
        Erx # Msg(250014,'',_WinIcoQuestion,_WinDialogYesNo,1);
        if (Erx=_Winidyes) then Art_SL_Data:RecalcStruct(n,'');
      end;
    end;


    'Mnu.Inventur' : begin
      //if (Rechte[Rgt_Art_Inventur]) then Dlg_Art_Inventur:Starten();
//      RecBufClear(259);
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Inv.Verwaltung','',y);
//      Lib_GuiCom:RunChildWindow(gMDI);
    Art_Inv_Main:Start(false);

    end;


    'Mnu.InventurpreisAlsDurchschnittsEK' : begin
      vText # Art_Data:InventurpreisAlsDurchschnittsEK();
      if(vText <> '') then begin
        if(vText = 'NOMARK') then
          Msg(997006, '', 0, 0, 0)
        else if(StrFind(vText, '_INVEK', 0) > 0) then
          Msg(001003, Art.Nummer + ' INVEK', 0, 0, 0);
        else if(StrFind(vText, '_Ø-EK', 0) > 0) then
          Msg(001003, Art.Nummer + ' Ø-EK', 0, 0, 0);
        else if(StrFind(vText, '_LOCK', 0) > 0) then
          Msg(001001, vText, 0, 0, 0);
        else if(StrFind(vText, '_ULOCK', 0) > 0) then
          Msg(999999, vText, 0, 0, 0);
      end
      else
        Msg(997003, '', 0, 0, 0);
    end;


    // ST 2011-12-28 laut Projekt 1326/194
    'Mnu.Inv.Mengenermittlung' : begin
      If (Msg(250015,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      if (Art_Data:InventurmengenErmittlung()) then begin
        Msg(999998,'',0,0,0);
      end
      else begin
        Msg(999999,'',0,0,0);
        ErrorOutput;
      end;
    end;


    'Mnu.Inv.Leeren' : begin
      If (Msg(250016,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      Lib_Rec:ClearFile(259);
      Art_Data:InventurmengenErmittlung();
      Msg(999998,'',0,0,0);
    end;


    'Mnu.Inv.EinArtikel' : begin
      If (Msg(250007,ARt.Nummer,_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      if (Dlg_Standard:Datum(Translate('Inventurdatum'),var vDat, today)=false) then RETURN false;
      vOK # Art_Inv_Subs:Uebernehme_Einzel(vDat)
//      Art_Data:InventurmengenErmittlung();
      if (vOK) then begin
        Msg(999998,'',0,0,0);
      end
      else begin
        Msg(999999,'',0,0,0);
        ErrorOutput;
      end;
    end;


    'Mnu.Inv.AlleArtikel' : begin
      If (Msg(250008,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      if (Dlg_Standard:Datum(Translate('Inventurdatum'),var vDat, today)=false) then RETURN false;
//      Art_Data:InventurmengenErmittlung();
      if (Art_Inv_Subs:Uebernehme_Alle(vDat)) then begin
        Msg(999998,'',0,0,0);
      end
      else begin
        Msg(999999,'',0,0,0);
        ErrorOutput;
      end;
    end;


    'Mnu.Inv.DelohneInv' : begin
      If (Msg(250009,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      if (Dlg_Standard:Datum(Translate('Inventurdatum'),var vDat, today)=false) then RETURN false;
      if (Art_Inv_Subs:Loesche_Verlorene(vDat)) then begin
        Msg(999998,'',0,0,0);
      end
      else begin
        Msg(999999,'',0,0,0);
        ErrorOutput;
      end;
    end;


    'Mnu.Recalc' : begin
      if (Rechte[Rgt_Art_Recalc]=n) then RETURN true;
      Erx # Msg(250017,'',_WinIcoQuestion, _WinDialogYesNoCancel, 1); // nur EIN Artikel?
      if (Erx=_WinIdCancel) then RETURN true;
      if (Erx=_winidyes) then Art_Data:ReCalcAll(Art.Nummer)
      else Art_Data:ReCalcAll();
    end;


    'Mnu.Recalc.Mark' : begin
      if (Rechte[Rgt_Art_Recalc]=n) then RETURN true;
      if (Msg(250018, aint(Lib_mark:Count(250)) ,_WinIcoQuestion, _WinDialogYesNo, 2)<>_winidyes) then RETURN true;
      Art_Data:ReCalcAll('',n,y);
    end;


    'Mnu.Filter.Geloescht' : begin
      Filter_Art # !(Filter_Art);
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Art;
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      RETURN true;
/***
      Filter_Art # !Filter_Art;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Art;
xxx
      if ( gZLList->wpDbSelection != 0 ) then begin
        vHdl # gZLList->wpDbSelection;
        if (SelInfo(vHdl, _SelCount) > 0) then
          vRef # _WinLstRecFromRecId
        else
          vRef # _WinLstFromFirst;
        gZLlist->wpDbSelection # 0;
        SelClose( vHdl );
        SelDelete( gFile, w_selName );
        w_selName # '';
        gZLList->WinUpdate( _winUpdOn, vRef | _winLstRecDoSelect );
        App_Main:Refreshmode();
        RETURN true;
      end;
      Lib_Sel:QRecList( 0, 'Art.GesperrtYN = false' );
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
*/
      RETURN true;
    end;


    'Mnu.Stichwort' : begin
      Dlg_Stichwort(Art.Stichwort,'Art.Stichwort',Translate('Stichwort'));
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Sachnummer' : begin
/*
      if (Dlg_Standard:Standard(Translate('Sachnummer'),var vA,n,20)) then begin
        // Artikel ändern
        RecRead(250,1,_RecLock);
        Art.Sachnummer # vA;
        if (RekReplace(250,_RecUnlock,'AUTO') <> _rOk) then
          Msg(999999,'Der Artikel konnte nicht gespeichert werden.',0,0,0);
      end;
*/
      Dlg_Stichwort(Art.Sachnummer,'Art.Sachnummer',Translate('Sachnummer'));
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Katalognummer' : begin
/*
      if (Dlg_Standard:Standard(Translate('Katalognummer'),var vA,n,20)) then begin
        // Artikel ändern
        RecRead(250,1,_RecLock);
        Art.Katalognr # vA;
        if (RekReplace(250,_RecUnlock,'AUTO') <> _rOk) then
          Msg(999999,'Der Artikel konnte nicht gespeichert werden.',0,0,0);
      end;
*/
      Dlg_Stichwort(Art.Katalognr,'Art.Katalognr',Translate('Katalognummer'));
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.OSt' : begin
      if (Rechte[Rgt_OSt_Artikel]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt( 'ART:' + StrCnv( Art.Nummer, _strUpper ), -1, 'Artikel ' + Art.Nummer + ', ' + Art.Stichwort );
    end;


    'Mnu.SL' : begin
      RecBufClear(255);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.SLK.Verwaltung',here+':AusMenuSLK',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gzllist->wpdbLinkfileno # 255;
      gzllist->wpdbKeyno      # 1;
      gzllist->wpdbfileno     # 250;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Mark.SetVK1' : begin
      Lib_Mark:SetPreis('VK');
    end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;


    'Mnu.Mark.Sel' : begin
      Art_Mark_Sel();
    end;


    'Mnu.WE' : begin
      RecBufClear(506);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Verwaltung','',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gzllist->wpdbLinkfileno # 0;
      gzllist->wpdbKeyno      # 1;
      gzllist->wpdbfileno     # 506;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      vQ # '';
      Lib_Sel:QAlpha( var vQ, 'Ein.E.Artikelnr', '=', Art.Nummer);
      Lib_Sel:QDate( var vQ, 'Ein.E.Eingang_Datum', '>', 01.01.2000);
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Copy' : begin
      w_AppendNr # Art.ID;
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Mnu.Extras.Produktion' : begin
      if (Rechte[Rgt_Art_manuellePRD]=false) then RETURN true;
      Art_Subs:Produziere();
    end;


    'Mnu.Extras.Wareneingang' : begin
      if (Rechte[Rgt_Art_manuellerWE]=false) then RETURN true;

      // bei Material, neue Karte erfassen:
      if (Wgr_data:IstMix()) then begin
        RecBufClear(200);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung','',y);
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        mode # c_ModeBald + c_modeNew;
        RecBufClear(998);
        Sel.Art.von.ArtNr # Art.Nummer;
        vQ # '';
        Lib_Sel:QAlpha( var vQ, 'Mat.Strukturnr', '=', Sel.Art.von.ArtNr);
        Lib_Sel:QRecList(0,vQ);
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN true;
      end;


      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.J.Wareneingang',here+':AusInfo');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeNew;
      Lib_GuiCom:RunChildWindow(gMDI);
/***
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain,_WinaddHidden);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      gMdi->WinUpdate(_WinUpdOn);
      Art_J_WE_Main:RecInit();
      gMdi->WinUpdate();
***/
    end;


    'Mnu.Ktx.Gewicht' : begin
//      "Art.GewichtProStk" # Rnd(Art.Dicke / 100.0 * Art.Breite / 100.0 * "Art.Länge" / 100.0 * Art.SpezGewicht, cGewStellen);
      Art_Data:CalcGewichtProStk();
      $edArt.Gewicht->winupdate(_WinUpdFld2Obj);
    end;


    'Mnu.Autodispo' : begin
      if (Msg(250541,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        if (Dlg_Standard:Datum(Translate('bis Datum (leer = laut Artikelstamm)'), var vDat)) then
          Art_Disposition2:AutoDispo(vDat);
      end;
    end;


    'Mnu.ChargenDetail' : begin
      Cmd_ChargenDetail();
    end;


    'Mnu.Journal' : begin
      RecBufClear(253);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.J.Verwaltung',here+':AusInfo',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.KundenAuftrag' : begin
      RecBufClear(501);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung','',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdbkeyno        # 12;
      gZLList->wpdblinkfileno   # 501;
      gZLList->wpdbfileno       # 250;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Preise' : begin
      RecBufClear(254);
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'Art.P.Verwaltung','',y);
      Art_P_Main:Selektieren(gMDI, Art.Nummer, 0, 2);
/***
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QAlpha( var vQ, '"Art.P.ArtikelNr"', '=', Art.Nummer);
      Lib_Sel:QRecList(0,vQ);
/**
      gZLList->wpdbKeyNo      # 6;
      gZLList->wpDbLinkFileNo # 254;
      gZLList->wpDbFileNo     # 250;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
**/

      // ehemals Selektion 843 ARTIKELPREISE
      $lb.aufpreise->wpvisible # true;
      $ZL.Art.APL.L->wpvisible # true;
      vHdl # Winsearch(gMDI,'ZL.Art.APL.L');
      Lib_Sel:QRecList(vHdl,'');
      vHdl # $ZL.Art.APL.L->wpdbselection;
      SelClear(vHdl);
      ApL_Data:AutoGenerieren(250, n, vHdl);
***/
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Reserv' : begin
//      Auswahl('Reservierungen');
      Cmd_Dispo_Res();
    end;


    'Mnu.Bestellungen' : begin
      Cmd_Bestellungen();
    end;


    'Mnu.Bestellungen.Rahmen' : begin
      Cmd_Bestellungen('Rahmen');
    end;


    'Mnu.BestellungenABL' : begin
      RecBufclear(511);
      RecLink(511,250,18,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Ablage',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno      # 250;
      gZLList->wpDbKeyNo       # 18;
      gZLList->wpDbLinkFileno  # 511;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Dispoliste' : begin
      Cmd_Dispo();
    end;

/***
    'Mnu.Reservierungen' : begin
      Cmd_Dispo_Res();
    end;
***/

    'Mnu.offeneAuf' : begin
      Cmd_Dispo_AufRest();
    end;


    'Mnu.AufAktionen' : begin
      RecBufClear(404);
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'Auf.A.Verwaltung','',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      gZLList->wpdbKeyNo      # 13;
//      gZLList->wpDbLinkFileNo # 404;
//      gZLList->wpDbFileNo     # 250;
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Auf.A.ArtikelNr'  , '=', Art.Nummer);
      vHdl # SelCreate(404, gkey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
     end;

    
    'Mnu.AdrArtikel' : begin
      RecBufClear(105);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung','',y,n, 'Art');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha( var vQ, 'Adr.V.Strukturnr', '=', Art.Nummer);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Art.Anlage.Datum, Art.Anlage.Zeit, Art.Anlage.User);
    end;

  end; // case

end;


//========================================================================
// EvtKeyItem
//
//========================================================================
sub EvtKeyItem (
  aevt    : event;
  aKey    : int;
  aRecId  : int
) : logic;
begin
  RETURN(true)
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (Mode=c_ModeView) then begin
    case (aEvt:Obj->wpName) of
      'bt.Bestand'                  :   Cmd_Chargendetail();
      'bt.Reserviert'               :   Cmd_Dispo_Res();
      'bt.Vormaterial'              :   Cmd_Dispo_VorMaterial();
      'bt.Verfuegbar'               :   Cmd_Dispo_Verfuegbar();
      'bt.AufRest'                  :   Cmd_Dispo_AufRest();
      'bt.Bestellt'                 :   Cmd_Bestellungen();
      'bt.Kommissioniert'           :   Cmd_Kommissioniert();
    end;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.AFOben'             :   Auswahl('AF.Oben');
    'bt.AFUnten'            :   Auswahl('AF.Unten');
    'bt.SL'                 :   Auswahl('SL');
    'bt.Warengruppe'        :   Auswahl('Warengruppe');
    'bt.Artikelgruppe'      :   Auswahl('Artikelgruppe');
    'bt.PEH'                :   Auswahl('PEH');
    'bt.MEH'                :   Auswahl('MEH');
    'bt.Bilddatei'          :   Auswahl('Bilddatei');
    'bt.Typ'                :   Auswahl('TYP');
    'bt.EKText'             :   auswahl('EKText');
    'bt.VKText'             :   auswahl('VKText');
    'bt.PRDText'            :   auswahl('PRDText');
    'bt.Guete'              :   Auswahl('Guete');
    'bt.Obf'                :   Auswahl('Oberfläche');
    'bt.Etikettentyp'       :   Auswahl('Etikettentyp');
    'bt.Intrastat'          :   Auswahl('Intrastat');
  end;

end;


//========================================================================
//  EvtLstRecControl
//
//========================================================================
sub EvtLstRecControl(
  opt aEvt      : event;
  opt aRecid    : int;
) : logic;
begin
  if (Art.GesperrtYN) and (Filter_Art) then RETURN false;
  RETURN true;
end;


//========================================================================
// AFObenRecCtrl
//              Popuplist Auflage Oben Filter
//========================================================================
sub AFObenRecCtrl(
  aEvt : event;
  aRecId : int;
) : logic;
begin
  Art.AF.Bezeichnung # StrCut(Art.AF.Bezeichnung + ':'+Art.AF.Zusatz, 1, 32);
  RETURN Art.AF.Seite='1';
end;


//========================================================================
// AFUntenRecCtrl
//              Popuplist Auflage Unten Filter
//========================================================================
sub AFUntenRecCtrl(
  aEvt : event;
  aRecId : int;
) : logic;
begin
  Art.AF.Bezeichnung # StrCut(Art.AF.Bezeichnung + ':'+Art.AF.Zusatz, 1, 32);
  RETURN Art.AF.Seite='2';
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
): logic;
local begin
  Erx : int;
end;
begin
  // Sonderfunktion:
  if (aMark) then begin
    if (RunAFX('Art.EvtLstDataInit','y')<0) then RETURN true;
  end
  else begin
    if (RunAFX('Art.EvtLstDataInit','n')<0) then RETURN true;
  end;

  
  RecBufClear(841);
  if ("Art.Oberfläche"<>0) then begin
    Erx # RecLink(841,250,16,_recFirst);    // Oberfläche holen
    if (Erx>=_rLockeD) then RecBufClear(841);
  end;

  Erx # RekLink(826,250,11,0);              // Artikelgruppe holen


  RecBufClear(252);
  Art.C.ArtikelNr   # Art.Nummer;
  if (Art.Nummer<>'') then Art_Data:ReadCharge();

  Art.P.ArtikelNr # Art.Nummer;
  Art.P.Adressnr  # 0;
  Art.P.Preistyp  # 'VK';
  Erx # RecRead(254,4,0);
  if (Erx>_rMultikey) then begin
    GV.Alpha.10 # '';
    end
  else begin
    GV.Alpha.10 # ANum(Art.P.PreisW1,2) + ' pro ' + AInt(Art.P.PEH) + ' ' + Art.P.MEH;
  end;

  GV.Alpha.11 # '';
  if(Art_P_Data:LiesPreis('Ø-EK', 0) = true) then  // Durchschnitts-EK lesen
    GV.Alpha.11 # ANum(Art.P.PreisW1, 2) + ' pro ' + AInt(Art.P.PEH) + ' ' + Art.P.MEH;


  GV.Alpha.12 # ANum("Art.GewichtProm", Set.Stellen.Gewicht);

  if (aMark=n) then begin
    if (Art.GesperrtYN) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
  end;

  RETURN true
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
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);   // falls Menüs gesetzte werden sollen

  // Ankerfunktion:
  if (RunAFX('Art.EvtLstSelect','')<0) then RETURN true;

  $lb.Art.Info1->wpcaption # Translate('Verfügbar')+' 1:  '+anum(Art.C.Bestand - Art.C.Reserviert - Art.C.offeneAuf, set.Stellen.Menge)+' '+Art.MEH;
  $lb.Art.Info2->wpcaption # Translate('Verfügbar')+' 2:  '+anum(Art.C.Bestand - Art.C.Reserviert - Art.C.offeneAuf + Art.C.Bestellt, set.Stellen.Menge)+' '+Art.MEH;

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

  vTxtHdl # $Art.EKText1->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.EKText2->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.EKText3->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.EKText4->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.EKText5->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);

  vTxtHdl # $Art.VKText1->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.VKText2->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.VKText3->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.VKText4->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);
  vTxtHdl # $Art.VKText5->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);

  vTxtHdl # $Art.PRDText1->wpdbTextBuf;
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

//  if (Mode=c_ModeEdit) then RETURN
//  if (Mode=c_ModeNew) then RETURN
  if ($art.EKText1->wpcustom=aint(Art.ID)) then RETURN;
  $Art.EKText1->wpcustom # aint(Art.ID);


  // EK-Text laden
  vTxtHdl_L1 # $Art.EKText1->wpdbTextBuf;
  vTxtHdl_L2 # $Art.EKText2->wpdbTextBuf;
  vTxtHdl_L3 # $Art.EKText3->wpdbTextBuf;
  vTxtHdl_L4 # $Art.EKText4->wpdbTextBuf;
  vTxtHdl_L5 # $Art.EKText5->wpdbTextBuf;
  if (Art.Id<>0) and (Art.ID<>myTmpNummer) then begin
    Lib_Texte:TxtLoad5Buf('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
    vTxtHdl_L1, vTxtHdl_L2, vTxtHdl_L3, vTxtHdl_L4, vTxtHdl_L5);
  end;

  // Textpuffer an Felderübergeben
  $Art.EKText1->wpdbTextBuf # vTxtHdl_L1;
  $Art.EKText1->WinUpdate(_WinUpdBuf2Obj);
  $Art.EKText2->wpdbTextBuf # vTxtHdl_L2;
  $Art.EKText2->WinUpdate(_WinUpdBuf2Obj);
  $Art.EKText3->wpdbTextBuf # vTxtHdl_L3;
  $Art.EKText3->WinUpdate(_WinUpdBuf2Obj);
  $Art.EKText4->wpdbTextBuf # vTxtHdl_L4;
  $Art.EKText4->WinUpdate(_WinUpdBuf2Obj);
  $Art.EKText5->wpdbTextBuf # vTxtHdl_L5;
  $Art.EKText5->WinUpdate(_WinUpdBuf2Obj);


  // VK-Text laden
  vTxtHdl_L1 # $Art.VKText1->wpdbTextBuf;
  vTxtHdl_L2 # $Art.VKText2->wpdbTextBuf;
  vTxtHdl_L3 # $Art.VKText3->wpdbTextBuf;
  vTxtHdl_L4 # $Art.VKText4->wpdbTextBuf;
  vTxtHdl_L5 # $Art.VKText5->wpdbTextBuf;
  if (Art.Id<>0) and (Art.ID<>myTmpNummer) then begin
    Lib_Texte:TxtLoad5Buf('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
    vTxtHdl_L1, vTxtHdl_L2, vTxtHdl_L3, vTxtHdl_L4, vTxtHdl_L5);
  end;

  // Textpuffer an Felderübergeben
  $Art.VKText1->wpdbTextBuf # vTxtHdl_L1;
  $Art.VKText1->WinUpdate(_WinUpdBuf2Obj);
  $Art.VKText2->wpdbTextBuf # vTxtHdl_L2;
  $Art.VKText2->WinUpdate(_WinUpdBuf2Obj);
  $Art.VKText3->wpdbTextBuf # vTxtHdl_L3;
  $Art.VKText3->WinUpdate(_WinUpdBuf2Obj);
  $Art.VKText4->wpdbTextBuf # vTxtHdl_L4;
  $Art.VKText4->WinUpdate(_WinUpdBuf2Obj);
  $Art.VKText5->wpdbTextBuf # vTxtHdl_L5;
  $Art.VKText5->WinUpdate(_WinUpdBuf2Obj);


  // PRD-Text laden
  vTxtHdl_L1 # $Art.PRDText1->wpdbTextBuf;
  if (Art.Id<>0) and (Art.ID<>MyTmpNummer) then begin
    Lib_Texte:TxtLoad5Buf('~250.PRD.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
    vTxtHdl_L1, 0 ,0, 0, 0);
  end;

  // Textpuffer an Felderübergeben
  $Art.PRDText1->wpdbTextBuf # vTxtHdl_L1;
  $Art.PRDText1->WinUpdate(_WinUpdBuf2Obj);

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
  if (Art.ID=0) then RETURN;
  
  vTxtHdl_L1 # $Art.EKText1->wpdbTextBuf;
  $Art.EKText1->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L2 # $Art.EKText2->wpdbTextBuf;
  $Art.EKText2->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L3 # $Art.EKText3->wpdbTextBuf;
  $Art.EKText3->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L4 # $Art.EKText4->wpdbTextBuf;
  $Art.EKText4->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L5 # $Art.EKText5->wpdbTextBuf;
  $Art.EKText5->WinUpdate(_WinUpdObj2Buf);
  Lib_Texte:TxtSave5Buf('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
    vTxtHdl_L1, vTxtHdl_L2, vTxtHdl_L3, vTxtHdl_L4, vTxtHdl_L5);

  vTxtHdl_L1 # $Art.VKText1->wpdbTextBuf;
  $Art.VKText1->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L2 # $Art.VKText2->wpdbTextBuf;
  $Art.VKText2->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L3 # $Art.VKText3->wpdbTextBuf;
  $Art.VKText3->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L4 # $Art.VKText4->wpdbTextBuf;
  $Art.VKText4->WinUpdate(_WinUpdObj2Buf);
  vTxtHdl_L5 # $Art.VKText5->wpdbTextBuf;
  $Art.VKText5->WinUpdate(_WinUpdObj2Buf);
  Lib_Texte:TxtSave5Buf('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
    vTxtHdl_L1, vTxtHdl_L2, vTxtHdl_L3, vTxtHdl_L4, vTxtHdl_L5);


  vTxtHdl_L1 # $Art.PRDText1->wpdbTextBuf;
  $Art.PRDText1->WinUpdate(_WinUpdObj2Buf);
  Lib_Texte:TxtSave5Buf('~250.PRD.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
    vTxtHdl_L1, 0,0,0,0);

END;


//========================================================================
//  EvtDtopEnter
//
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
begin
  if (Mode=c_ModeNew) or (mode=c_Modeedit) then
    aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink;
  RETURN(true);
end;


//========================================================================
//  EvtDorp
//
//========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vDataFormat : int;
  vFileList   : int;
  vListObj    : int;
  vFilename   : alpha(2000);
  vNr         : int;
end;
begin

    if (aDataObject->wpFormatEnum(_WinDropDataFile)) then begin
// FOCUS HOLEN
      gFrmMain->WinUpdate(_WinUpdActivate);
      // Dateipfad und -name wurde übergeben
      // Format-Objekt ermitteln
      vDataFormat # aDataObject->wpData(_WinDropDataFile);
      vFileList # vDataFormat->wpData;
      // alle übertragenen Dateinamen auswerten
      FOR vListObj # vFileList->CteRead(_CteFirst);
      LOOP vListObj # vFileList->CteRead(_CteNext,vListObj);
      WHILE (vListObj > 0) do begin
        vFileName # vListObj->spName;

        Art.Bilddatei # vFileName;
        $edArt.Bilddatei->winUpdate(_WinUpdFld2Obj);
      end;
    end;

  RETURN(true);// Ermitteln der vorhandenen Daten

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
  vRect     : rect;
  vHdl      : int;
end
begin

  // WORKAROUND
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
    vRect           # gZLList->wpArea;
//    vRect:right     # aRect:right-61;
//    vRect:bottom    # aRect:bottom-200;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-40 - w_QBHeight;
    gZLList->wparea # vRect;

    Lib_GUiCom:ObjSetPos($lb.Art.Info1, 0, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Art.Info2, 300, vRect:bottom+8);//+28);
  end;

	RETURN (true);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edArt.Warengruppe') AND (aBuf->Art.Warengruppe<>0)) then begin
    RekLink(819,250,10,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Artikelgruppe') AND (aBuf->Art.Artikelgruppe<>0)) then begin
    RekLink(826,250,11,0);   // Artikelgruppe holen
    Lib_Guicom2:JumpToWindow('Agr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Guete') AND ("Art.Güte"<>'')) then begin
     "MQu.Güte1"  # "Art.Güte";
     RecRead(832,2,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Oberflaeche') AND (aBuf->"Art.Oberfläche"<>0)) then begin
    RekLink(841,250,16,0);   // Oberfläche holen
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edArt.Etikettentyp') AND (aBuf->Art.Etikettentyp<>0)) then begin
    RekLink(840,250,23,0);   // Etikettentyp holen
    Lib_Guicom2:JumpToWindow('Eti.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Stueckliste') AND (aBuf->"Art.Stückliste"<>0)) then begin
    RekLink(409,250,7,0);   // aktive Stückliste holen
    Lib_Guicom2:JumpToWindow('Art.SLK.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Intrastatnr') AND (aBuf->Art.Intrastatnr<>'')) then begin
   todo('Intrastat')
    //RekLink(409,250,7,0);   // Intrastat-Nr. holen
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================