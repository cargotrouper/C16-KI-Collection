@A+
//===== Business-Control =================================================
//
//  Prozedur    VsP_Msk_Main
//                  OHNE E_R_G
//  Info        Routinen für den Versandpooldialog
//
//
//  01.02.2010  AI  Erstellung der Prozedur
//  08.11.2021  AH  Gewichte eher Brutto
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB GetReference(aHdl : int; aUebernehmen : logic);
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB InnerRedrawInfo(aObj : int; aUebernehmen : logic)
//    SUB RedrawInfo(optaUebernehmen : logic);
//    SUB AusFeld()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObj : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtTerm(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  cMenuName : 'Sel.Dialog'
  cPrefix :   'VsP_Msk'
end;

LOCAL begin
  d_X         : int;
  d_text      : int;
  d_frame     : int;
  d_Button    : int;
  d_MenuItem  : int;
end;

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl : int;
end;
begin
  gZLList # 0;
  vHdl # w_lastfocus;
  Call('App_Main:EvtMdiActivate',aEvt);
  w_lastfocus # vHdl;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  Lib_GuiCom:Pflichtfeld($ed.Stueck);
  Lib_GuiCom:Pflichtfeld($ed.Gewicht);
  Lib_GuiCom:Pflichtfeld($edLagerort);
  Lib_GuiCom:Pflichtfeld($edLageranschrift);
  Lib_GuiCom:Pflichtfeld($edZielort);
  Lib_GuiCom:Pflichtfeld($edZielanschrift);
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich  : alpha;
)
local begin
  Erx     : int;
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  vFilter : int;
  vSel    : alpha;
  vName   : alpha(500);
  vQ      : alpha(4000);
end;

begin

  vHdl # w_lastFocus;

  case aBereich of

    'Lagerort' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusStartAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
      //VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      //Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Lageranschrift' : begin
      Adr.Nummer # $edLagerort->wpcaptionint;
      RecRead(100,1,0);
      RecLink(101,100,12,1);     // Lieferadresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusStartAnschrift');

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


    'Zielort' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusZielAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
      //VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      //Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Zielanschrift' : begin
      Adr.Nummer # $edLagerort->wpcaptionint;
      RecRead(100,1,0);
      RecLink(101,100,12,1);     // Lieferadresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusZielAnschrift');

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


    'Spediteur' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusSpediteur');
      Lib_GuiCom:RunChildWindow(gMDI);
      //VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      //Lib_GuiCom:ZLSetSort(gKey);
    end;

  end;

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic)
local begin
  Erx   : int;
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha(200);
end;
begin

  Erx # RecLink(101,655,4,_recFirst);   // Startanschrift holen
  if (Adr.A.Nummer=0) or (Erx>_rLocked) then RecBufClear(101);
  Erx # RecLink(100,101,1,_RecFirst);   // Adresse holen
  if (Adr.Nummer=0) or (Erx>_rLocked) then RecBufClear(100);
  vA # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
  $Lb.Lagerort->wpcaption # Adr.Stichwort;
  $Lb.Lageranschrift->wpcaption # vA;


  Erx # RecLink(101,655,5,_recFirst);   // Zielanschrift holen
  if (Adr.A.Nummer=0) or (Erx>_rLocked) then RecBufClear(101);
  Erx # RecLink(100,101,1,_RecFirst);   // Adresse holen
  if (Adr.Nummer=0) or (Erx>_rLocked) then RecBufClear(100);
  vA # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
  $Lb.Zielort->wpcaption # Adr.Stichwort;
  $Lb.Zielanschrift->wpcaption # vA;

  // Spediteur...
  Erx # RecLink(100,655,1,_RecFirst);   // Spediteur holen
  if (Erx>_rLocked) then RecBufClear(100);
  VsP.SpediteurSW # Adr.Stichwort;
  $Lb.Spediteur->winupdate(_WinUpdFld2Obj);
  //$Lb.Spediteur->wpcaption # Adr.Stichwort;


  // einfärben der Pflichtfelder
  Pflichtfelder();

end;


//========================================================================
//  AusStartAdresse
//
//========================================================================
sub AusStartAdresse()
local begin
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    VsP.Start.Adresse # Adr.Nummer;
    VsP.Start.Anschrift # 1;
    gSelected # 0;
    $edLageranschrift->WinUpdate(_WinUpdFld2Obj);
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
//    Pflichtferlder();
  end;
  $edLagerort->winfocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusStartAnschrift
//
//========================================================================
sub AusStartAnschrift()
local begin
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    VsP.Start.Adresse # Adr.A.Adressnr;
    VsP.Start.Anschrift # Adr.A.Nummer;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edLageranschrift->winfocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusZielAdresse
//
//========================================================================
sub AusZielAdresse()
local begin
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    VsP.Ziel.Adresse # Adr.Nummer;
    VsP.Ziel.Anschrift # 1;
    $edZielanschrift->WinUpdate(_WinUpdFld2Obj);
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
//debug('BINDA');
  $edZielort->winfocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusZielAnschrift
//
//========================================================================
sub AusZielAnschrift()
local begin
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    VsP.Ziel.Adresse # Adr.A.Adressnr;
    VsP.Ziel.Anschrift # Adr.A.Nummer;
    gSelected # 0;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edZielanschrift->winfocusset(true);
  gSelected # 0;
  RefreshIfm();
end;


//========================================================================
//  AusSpediteur
//
//========================================================================
sub AusSpediteur()
local begin
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    VsP.Spediteurnr # Adr.Nummer;
    VsP.SpediteurSW # Adr.Stichwort;
    gSelected # 0;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edVsP.Spediteurnr->winfocusset(false);
//  RefreshIfm();
end;


//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  // Ermitteln des Frames
  d_Frame # aEvt:Obj->WinInfo(_WinFrame);
  if (d_Frame = 0) then RETURN TRUE;

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable( aEvt:obj );
  else
    Lib_GuiCom:AuswahlDisable( aEvt:obj );

  RefreshIfm();
  RETURN true;
end;


//========================================================================
//  EvtFocusTerm
//                Fokus wechselt hier weg
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObj             : int           // nächstes Objekt
) : logic
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl    : int;
  vHdl2   : int;
  vName   : alpha(500);
end;
begin

  case (aEvt:Obj->wpName) of

    'Bt.OK' : begin
      gSelected # 1;
    end;


    'Bt.Abbruch' : begin
      gSelected # 0;
    end


    otherwise begin
      vHdl # gMDI->Winsearch(aEvt:Obj->wpcustom);
      w_LastFocus # vHdl;
      case aEvt:Obj->wpname of
        'bt.Lagerort'         : Auswahl('Lagerort');
        'bt.Lageranschrift'   : Auswahl('Lageranschrift');
        'bt.Zielort'          : Auswahl('Zielort');
        'bt.Zielanschrift'    : Auswahl('Zielanschrift');
        'bt.Spediteur'        : Auswahl('Spediteur');
      end;
    end;

  end;

  RETURN true;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vA  : alpha;
end;
begin
  WinSearchPath(aEvt:Obj);
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  Mode      # c_ModeNew;
  gSelected # 0;

  // Auswahlfelder setzen...
  SetStdAusFeld('edLagerort'        ,'Lagerort');
  SetStdAusFeld('edLageranschrift'  ,'Lageranschrift');
  SetStdAusFeld('edZielort'         ,'Lagerort');
  SetStdAusFeld('edZielanschrift'   ,'Lageranschrift');
  SetStdAusFeld('edVsP.Spediteurnr' ,'Spediteuer');

  if (VsP.Vorgangstyp=c_VSPTyp_Ein) then begin
    VsP.Start.Adresse     # Mat.Lageradresse;
    VsP.Start.Anschrift   # Mat.Lageranschrift;
    VsP.Materialnr        # Mat.Nummer;
    VsP.Gewicht.Soll      # Mat.Gewicht.Brutto;//Mat.Bestand.Gew; 08.11.2021 AH
    if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll # Mat.Bestand.Gew;
    "VsP.Stück.Soll"      # Mat.Bestand.Stk;

    $lb.Vorgang->wpcaption # Translate('Bestellung');
    $lb.Kommission->wpcaption # aint(Ein.P.Nummer)+'/'+aint(Ein.p.position);
    $Lb1.AufStueck->wpcaption # AInt(Mat.Bestand.Stk);
    $Lb1.AufGewicht->wpcaption # ANum(Mat.Bestand.Gew, Set.Stellen.Gewicht);
    $Lb.KundenSW->wpcaption   # Ein.P.LieferantenSW;

    vA # "Mat.Güte";
    vA # vA + '   '+ANum(Mat.Dicke,Set.Stellen.Dicke);
    vA # vA +' x '+ANum(Mat.Breite,Set.Stellen.Breite);
    if ("Auf.P.Länge"<>0.0) then vA # vA +' x '+ANum("Mat.Länge","Set.Stellen.Länge");
    vA # vA + '   ';
    if ("Mat.AusführungOben"<>'') then vA # vA +'    O:'+"Mat.AusführungOben";
    if ("Mat.AusführungUnten"<>'') then vA # vA +'   U:'+"Mat.AusführungUnten";
    $lb.Auftragsinfo->wpcaption # vA;

    Lib_GuiCom:Disable($edLagerOrt);
    Lib_GuiCom:Disable($edLagerAnschrift);
    Lib_GuiCom:Disable($bt.LagerOrt);
    Lib_GuiCom:Disable($bt.LagerAnschrift);
    Lib_GuiCom:Disable($ed.Stueck);
    Lib_GuiCom:Disable($ed.Gewicht);
  end;

  if (VsP.Vorgangstyp=c_VSPTyp_Mat) then begin
    VsP.Start.Adresse     # Mat.Lageradresse;
    VsP.Start.Anschrift   # Mat.Lageranschrift;
    VsP.Materialnr        # Mat.Nummer;
    VsP.Gewicht.Soll      # Mat.Gewicht.Brutto;// Mat.Bestand.Gew; 08.11.2021 AH
    if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll # Mat.Bestand.Gew;
    "VsP.Stück.Soll"      # Mat.Bestand.Stk;

    $lb.Vorgang->wpcaption # Translate('Material');
    $lb.Kommission->wpcaption # aint(Mat.Nummer);
    $Lb1.AufStueck->wpcaption # AInt(Mat.Bestand.Stk);
    $Lb1.AufGewicht->wpcaption # ANum(Mat.Bestand.Gew, Set.Stellen.Gewicht);
    $Lb.KundenSW->wpcaption   # '';

    vA # "Mat.Güte";
    vA # vA + '   '+ANum(Mat.Dicke,Set.Stellen.Dicke);
    vA # vA +' x '+ANum(Mat.Breite,Set.Stellen.Breite);
    if ("Auf.P.Länge"<>0.0) then vA # vA +' x '+ANum("Mat.Länge","Set.Stellen.Länge");
    vA # vA + '   ';
    if ("Mat.AusführungOben"<>'') then vA # vA +'    O:'+"Mat.AusführungOben";
    if ("Mat.AusführungUnten"<>'') then vA # vA +'   U:'+"Mat.AusführungUnten";
    $lb.Auftragsinfo->wpcaption # vA;

    Lib_GuiCom:Disable($edLagerOrt);
    Lib_GuiCom:Disable($edLagerAnschrift);
    Lib_GuiCom:Disable($bt.LagerOrt);
    Lib_GuiCom:Disable($bt.LagerAnschrift);
    Lib_GuiCom:Disable($ed.Stueck);
    Lib_GuiCom:Disable($ed.Gewicht);
  end;

  if (VsP.Vorgangstyp=c_VSPTyp_Auf) then begin
    RecLink(400,401,3,_RecFirst);   // Kopf holen
    VsP.Ziel.Adresse      # Auf.Lieferadresse;
    VsP.Ziel.Anschrift    # Auf.Lieferanschrift;

    $lb.Vorgang->wpcaption # Translate('Kommission');
    $lb.Kommission->wpcaption # aint(Auf.P.Nummer)+'/'+aint(auf.p.position);
    $Lb1.AufStueck->wpcaption # AInt(Auf.P.Prd.Rest.Stk);
    $Lb1.AufGewicht->wpcaption # ANum(Auf.P.Prd.Rest.Gew,Set.Stellen.Gewicht);
    $Lb.KundenSW->wpcaption   # Auf.P.KundenSW

    vA # "Auf.P.Güte";
    vA # vA + '   '+ANum(Auf.P.Dicke,Set.Stellen.Dicke);
    vA # vA +' x '+ANum(Auf.P.Breite,Set.Stellen.Breite);
    if ("Auf.P.Länge"<>0.0) then vA # vA +' x '+ANum("Auf.P.Länge","Set.Stellen.Länge");
    vA # vA + '   ';
    if (Auf.P.AusfOben<>'') then vA # vA +'    O:'+Auf.P.AusfOben;
    if (Auf.P.AusfUnten<>'') then vA # vA +'   U:'+Auf.P.AusfUnten;
    $lb.Auftragsinfo->wpcaption # vA;

    Lib_GuiCom:Disable($edZielOrt);
    Lib_GuiCom:Disable($edZielAnschrift);
    Lib_GuiCom:Disable($bt.ZielOrt);
    Lib_GuiCom:Disable($bt.ZielAnschrift);
  end;

  // Auswahlfelder setzen...
  //SetStdAusFeld('', '');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vParent : int;
  vName   : alpha;
  vHdl    : int;
  vTmp    : int;
end;
begin

  // Parentfenster koennen nicht geschlossen werden
  if (w_Child<>0) then RETURN false;

  if (gSelected<>0) then begin
    if ("VsP.Stück.Soll"=0) then begin
      Msg(001200,Translate('Stückzahl'),0,0,0);
      vHdl     # aEvT:Obj->Winsearch('ed.Stueck');
      vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (VsP.Gewicht.Soll<=0.0) then begin
      Msg(001200,Translate('Gewicht'),0,0,0);
      vHdl     # aEvT:Obj->Winsearch('ed.Gewicht');
      vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (VsP.Start.Adresse=0) then begin
      Msg(001200,Translate('Adresse'),0,0,0);
      vHdl     # aEvT:Obj->Winsearch('edLagerort');
      vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (VsP.Start.Anschrift=0) then begin
      Msg(001200,Translate('Anschrift'),0,0,0);
      vHdl     # aEvT:Obj->Winsearch('edLageranschrift');
      vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (VsP.Ziel.Adresse=0) then begin
      Msg(001200,Translate('Adresse'),0,0,0);
      vHdl     # aEvT:Obj->Winsearch('edZielort');
      vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (VsP.Ziel.Anschrift=0) then begin
      Msg(001200,Translate('Anschrift'),0,0,0);
      vHdl     # aEvT:Obj->Winsearch('edZielanschrift');
      vHdl->WinFocusSet(true);
      RETURN false;
    end;
  end;

  gFile   # 0;
  gPrefix # '';
  gZLList # 0;
  // Elternbeziehung aufheben?
  if (w_Parent<>0) then begin
    vTmp # VarInfo(Windowbonus);
    VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
    w_Child # 0;
    if (gZLList<>0) then gZLList->wpdisabled # false;
    VarInstance(WindowBonus,vTmp);
    w_Parent->wpdisabled # n;
    w_Parent->WinUpdate(_WinUpdActivate);
  end;

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
  vHdl  : handle;
  vHdl2 : handle;
  vA    : alpha;
end;
begin

// 6.2.2012 AI:
//  vA # WinEvtProcNameGet(gMDI, _WinEvtMenuCommand);
//  if (vA<>'') then RETURN Call(vA, aEvt, aMenuItem);

  case (aMenuItem->wpName) of

    'Mnu.SelAuswahl' : begin
      vHdl # WinFocusGet();     // Feld
      w_LastFocus # vHdl;
      case (vHdl->wpName) of
        'edLagerort'        : Auswahl('Lagerort');
        'edLageranschrift'  : Auswahl('Lageranschrift');
        'edZielort'         : Auswahl('Zielort');
        'edZielanschrift'   : Auswahl('Zielanschrift');
        'edVsP.Spediteurnr' : Auswahl('Spediteur');
      end;
    end;


    'Mnu.SelSave' : begin
      gSelected # 1;
      gMDI->Winclose();
    end;


    'Mnu.SelCancel' : begin
      gSelected # 0;
      gMDI->Winclose();
    end;

  end;

end;


//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTermProc : alpha;
  vHdl      : int;
end;
begin
  if (aEvt:obj->wpcustom<>'') then VarInstance(WindowBonus,cnvIA(aEvt:Obj->wpcustom));

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    if (w_parent<>0) then begin
      WinSearchPath(w_Parent);
      VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    end;
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
  end;

  RETURN true;
end;


//========================================================================