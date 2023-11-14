@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_ArtPrd_Main
//                    OHNE E_R_G
//  Info
//
//
//  03.09.2012  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKunde()
//    SUB AusKundenArtNr()
//    SUB AusKundenArtNr2()
//    SUB AusKommission()
//    SUB AusArtikel()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB RecalcRest(varaBB : float; varaBL : float; varaBGew : float; varaBM : float; varaL : float; varaGew : float; varaM : float; aMitRest : logic);
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDialog :   $BA1.F.Divers.Maske
  cTitle :    'Artikelproduktion Fertigung'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F_ArtPrd'
  cKey :      1
//  cZList1 :   $RL.BA1.Pos
//  cZList2 :   $RL.BA1.Input
//  cZList3 :   $RL.BA1.Fertigung
end;

declare RefreshIfm(opt aName : alpha; opt aChanged : logic)
declare RecalcRest(var aBB : float;var aBL : float;var aBGew : float;var aBM : float;var aL : float;var aGew : float;var aM : float; aMitRest : logic);

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
//  gZLList   # 0;//cZList;
  gKey      # cKey;

  SetStdAusFeld('edBAG.F.Kommission'     ,'Kommission');
  SetStdAusFeld('edBAG.F.KundenArtNr'    ,'Kundenartnr');
  SetStdAusFeld('edBAG.F.Artikelnummer'  ,'Artikel');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edBAG.F.Artikelnummer);
  Lib_GuiCom:Pflichtfeld($edBAG.F.Menge);
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
  Erx : int;
  va  : alphA;
  vX  : int;

  vBB   : float;
  vBL   : float;
  vL    : float;
  vGew  : float;
  vM    : float;
  vOk   : logic;
  vTmp  : int;
end;
begin

  Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
  if (Erx>_rLocked) then recbufClear(250);

  if (aName='edBAG.F.Artikelnr') and (($edBAG.F.Artikelnr->wpchanged) or (aChanged)) then begin
    BAG.F.MEH # Art.MEH;
  end;

  $lb.Menge.Ist->wpcaption # anum(BAG.F.Fertig.Menge, Set.Stellen.Menge);
  $lb.MEH1->wpcaption # BAG.F.MEH;
  $lb.MEH2->wpcaption # BAG.F.MEH;
  $lb.MEH3->wpcaption # BAG.F.MEH;
  $lb.Bezeichnung1->wpcaption # Art.Bezeichnung1;
  $lb.Bezeichnung2->wpcaption # Art.Bezeichnung2;
  $lb.Bezeichnung3->wpcaption # Art.Bezeichnung3;
  $lb.Stichwort->wpcaption # Art.Stichwort;

  if (
    (aName='edBAG.F.Kommission') and (($edBAG.F.Kommission->wpchanged) or (aChanged))) then begin
    // Kommission angegeben?
    BA1_F_Data:AusKommission(0 ,0, 0);
    BA1_F_Main:RefreshIfm();
    Refreshifm('edBAG.F.ReservFuerKunde');
    Refreshifm('edBAG.F.Warengruppe');
    Refreshifm('edBAG.F.Verpackung');
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
local begin
  vA : alpha;
  vTmp : int;
end;
begin

  if (Mode=c_ModeNew) then begin
    RecBufClear(703);
    BAG.F.Nummer    # BAG.P.Nummer;
    BAG.F.Position  # BAG.P.Position;

    if (w_AppendNr != 0) then begin
      BAG.F.Fertigung # w_AppendNr;
      RecRead( 703, 1, 0 );
      w_AppendNr # 0;
      end
    else begin
      BAG.F.Warengruppe     # 0;
      BAG.F.MEH             # 'Stk';
      "BAG.F.Güte"          # ''
      BAG.F.Streifenanzahl  # 1;
      BAG.F.Block           # ''
      "BAG.F.KostenträgerYN"  # Set.BA.F.KostenTrgYN;
    end;

    // allgem. Fertigung?
    BAG.F.Fertigung # 1;
    WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
      BAG.F.Fertigung # BAG.F.Fertigung + 1;
  end;

  // Ankerfunktion?
  RunAFX('BAG.F.RecInit','');

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('edBAG.F.Artikelnummer');
  vTmp->WinFocusSet(true);

//  w_LastFocus # vTmp;
//  Erx # gMdi->winsearch('DUMMYNEW');
//  Erx->wpcustom # AInt(vTmp);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vBuf703 : int;
  vTmp    : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  vTmp # gMdi->Winsearch('NB.Main');

  If (BAG.F.Artikelnummer='') then begin
    Msg(001200,Translate('Artikelnummer'),0,0,0);
    $edBAG.F.Artikelnummer->WinFocusSet(true);
    RETURN false;
  end;
  If (BAG.F.Menge<=0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $edBAG.F.Menge->WinFocusSet(true);
    RETURN false;
  end;

  if (BAG.F.Kommission <> '') then begin
    Erx # RecLinkInfo(401, 703, 9, _recCount);
    if(Erx = 0) then begin
      Msg(001201,BAG.F.Kommission  + ' ' + Translate('Kommission'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Kommission->WinFocusSet(true);
      RETURN false;
    end;
  end;

  // Gegenbuchung?
  if ($lb.GegenID->wpcustom<>'') then begin
    if (BA1_F_Main:Splitten()=true) then begin
      Mode # c_modeCancel;  // sofort alles beenden!
      gSelected # 1;
      RETURN true;
      end
    else begin
      RETURN false;
    end;
  end;


  TRANSON;

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # BA1_F_Data:Replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    BAG.F.Anlage.Datum  # Today;
    BAG.F.Anlage.Zeit   # Now;
    BAG.F.Anlage.User   # gUserName;

    BAG.F.Fertigung # 1;
    WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
      BAG.F.Fertigung # BAG.F.Fertigung + 1;

    Erx # BA1_F_Data:Insert(0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Stückliste kopieren
    if (BA1_F_ArtPrd_Data:CopySLToInput()=false) then begin
      TRANSBRK;
      ErrorOutput;
      RETURN false;
    end;
  end;


  // Fertigmaterial updaten
  if (BA1_F_Data:UpdateOutput(703,n)=false) then begin
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    Msg(701010,gTitle,0,0,0);
    RETURN true;
  end;

  TRANSOFF;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  BA1_F_Main:RecCleanUp();
  RETURN true;
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
  vS  : int;
end;
begin

  if (aEvt:obj->wpname='edBAG.F.AusfOben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|1');
  if (aEvt:obj->wpname='edBAG.F.AusfUnten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|2');


  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  case (aEvt:Obj->wpname) of

    'edBAG.F.Menge' :
      if (aEvt:obj->wpchanged) then begin
        $lb.Menge.Fehl->wpcaption # anum(BAG.F.Menge - BAG.F.Fertig.Menge, Set.Stellen.Menge);
      end;

  end;  // case

  if (StrCnv(BAG.F.MEH,_StrUpper)='KG') then  BAG.F.Gewicht # Rnd(BAG.F.Menge, Set.Stellen.Gewicht);
  if (StrCnv(BAG.F.MEH,_StrUpper)='T') then   BAG.F.Gewicht # Rnd(BAG.F.Menge * 1000.0, Set.Stellen.Gewicht);
  if (StrCnv(BAG.F.MEH,_StrUpper)='STK') then "BAG.F.Stückzahl" # CnvIf("BAG.F.Menge");

//    RecalcRest();

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
  vA      : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
end;

begin

  case aBereich of

    'Kommission'  : begin
      //RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kundenartnr' : begin
      RecLink(100,703,7,_recFirst);   // Kunde holen
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKundenartnr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'Kundenartnr2' : begin
      RecBufClear(105);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusKundenartnr2');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
      vQ # vQ + ' AND Adr.V.VerkaufYN'; // 21.07.2015
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    "BAG.F.ReservFürKunde" # Adr.Kundennr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.ReservFuerKunde->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusKundenArtnr
//
//========================================================================
sub AusKundenArtNr()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
//    "BAG.F.ReservFürKunde" # Adr.Kundennr;
    Auswahl('Kundenartnr2');
    end
  else begin
    // Focus auf Editfeld setzen:
    $edBAG.F.KundenArtNr->Winfocusset(false);
  end;
end;


//========================================================================
//  AusKundenArtnr2
//
//========================================================================
sub AusKundenArtNr2()
local begin
  vTmp : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BA1_F_Data:AusKundenArtNr();
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    gMDI->Winupdate();
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.KundenArtNr->Winfocusset(false);
end;


//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
local begin
  vTmp : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.F.Kommission        # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
    "BAG.F.KostenträgerYN"  # y;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  //$edBAG.F.Kommission->Winfocusset(false);
  $edBAG.F.Stueckzahl->Winfocusset(false);

  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  Refreshifm('edBAG.F.Kommission',y);

end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.F.Artikelnummer   # Art.Nummer;
    BAG.F.MEH             # Art.MEH;
  end;
  // Focus setzen:
  $edBAG.F.Artikelnummer->Winfocusset(false);

  // ggf. Labels refreshen
  Refreshifm('edBAG.F.Artikelnummer',y);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);

  // ST 2012-08-30: Edit für 999 aktiviert 1326/284
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);


  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

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

    'Mnu.Ktx.Errechnen' : begin
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, BAG.F.Anlage.Datum, BAG.F.Anlage.Zeit, BAG.F.Anlage.User );
    end;

    otherwise begin
      RETURN BA1_F_Main:EvtMenuCommand(aEvt, aMenuItem);
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
    'bt.Kommission'   :   Auswahl('Kommission');
    'bt.Kundenartnr'  :   Auswahl('Kundenartnr');
    'bt.Artikel'      :   Auswahl('Artikel');
    'bt.Kunde'        :   Auswahl('Kunde');
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
//  Refreshmode(y);
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
  gSelected # RecInfo(gFile, _recid);
  RETURN true;
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================