@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_Rohr_Main
//                  OHNE E_R_G
//  Info
//
//
//  09.04.2013  AI  Erstellung der Prozedur
//  17.10.2014  AH  MatSofortInAblage
//  03.12.2014  AH  Neuanlage aus Artikel belegt vor
//  10.12.2014  AH  Kontextmenü zum BErechnen der Mengen
//  13.03.2015  AH  Manuelle Anlage bei MatMix setzt bei Preis=0 diesen auf Durchschnittspreis
//  09.06.2015  AH  BAG.Tafeln
//  20.05.2016  AH  Vorbelegung mit "kg"
//  27.04.2016  AH  Material-Umkommissionieren nur bei richtigem Status
//  07.06.2016  AH  Directory auf %temp%
//  25.10.2016  AH  bei Neuanlage "KG" statt "T"
//  08.08.2017  ST  Kommissionierung prüft auf Auftragsangaben
//  17.08.2017  AH  Neu: Feld "Mat.Inventur.DruckYN"
//  18.12.2017  ST  Bugfix: ErrOutput bei Kommissionierung
//  01.09.2020  AH  Kurzinfo
//  29.09.2020  AH  "Set.Mat.LyseCheck"
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB CheckAnalyse (aObjName : alpha; aFieldName : alpha);
//    SUB RefreshIfm(opt aName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel(opt aSilent : logic; opt aNullen : logic)
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusEinzelObfOben()
//    SUB AusEinzelObfUnten()
//    SUB AusKommission()
//    SUB AusKommissionMark()
//    SUB AusInfo()
//    SUB AusIntrastat()
//    SUB AusStruktur()
//    SUB AusArtikel()
//    SUB AusAktion()
//    SUB AusWarengruppe()
//    SUB AusStatus()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusAFOben()
//    SUB AusAFUnten()
//    SUB AusErzeuger()
//    SUB AusUrsprungsland()
//    SUB AusLieferant()
//    SUB AusLieferStichwort()
//    SUB AusLageradresse()
//    SUB AusLageranschrift()
//    SUB AusLagerStichwort()
//    SUB AusLagerStichwort2()
//    SUB AusVerwiegungsart()
//    SUB AusEtikettentyp()
//    SUB AusZwischenlage()
//    SUB AusUnterlage()
//    SUB AusUmverpackung()
//    SUB AusAnalyse()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstRecControl(aEvt : event; aRecid : int) : logic;
//    SUB AFUntenRecCtrl(aEvt : event; aRecId : int) : logic;
//    SUB AFObenRecCtrl(aEvt : event; aRecId : int) : logic;
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG
define begin
  cTitle :    'Material'
  cFile :     200
  cMenuName : 'Mat.Bearbeiten'
  cPrefix :   'Mat_Rohr'
  cZList :    $ZL.Material.Rohr
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
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  Filter_Mat # y;

  If (Rechte[Rgt_Mat_EigenJN]=n) then begin
    $cbMat.EigenmaterialYN1->wpcustom # '_N';
  End;

  // MatSofortInAblage
  if (Set.Mat.Del.SofortYN) then begin
    gZLList->WinEvtProcNameSet(_WinEvtLstRecControl, '');
  end;

  $edMat.Bestand->wpDecimals # Set.Stellen.Menge;

  // Feldberechtigungn...
  if (Rechte[Rgt_Mat_EKPreise]) then begin
    $lbMat.EK.Preis->wpvisible        # true;
    $edMat.EK.Preis->wpvisible        # true;
    $lbMat.Kosten->wpvisible          # true;
    $Lb.Mat.Kosten->wpvisible         # true;
    $lbMat.EK.Effektiv->wpvisible     # true;
    $Lb.Mat.EK.Effektiv->wpvisible    # true;
    $Lb.HW5->wpvisible                # true;
    $clmMat.EK.Preis->wpvisible       # true;
    $clmMat.EK.Preispro->wpvisible    # true;
    $clmMat.EK.Effektiv->wpvisible    # true;

    $lbMat.EK.PreisGes->wpvisible     # true;
    $lb.Mat.EK.PreisGes->wpvisible    # true;
    $lbMat.KostenGes->wpvisible       # true;
    $Lb.Mat.KostenGes->wpvisible      # true;
    $lbMat.EK.EffektivGes->wpvisible  # true;
    $Lb.Mat.EK.EffektivGes->wpvisible # true;
    $Lb.HW5Ges->wpvisible             # true;
  end;

  if(Rechte[Rgt_Mat_Lieferant]) then begin
    $clmMat.LieferStichwort->wpVisible  # true;
    $edMat.LieferStichwort->wpVisible   # true;
    $lbMat.LieferStichwort->wpVisible   # true;
    $edMat.Lieferant->wpVisible         # true;
    $lbMat.Lieferant->wpVisible         # true;
    $bt.Lieferant->wpVisible            # true;
    $bt.LieferStichwort->wpVisible      # true;
    $Lb.Lieferant2->wpVisible           # true;
  end;

  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbMat.Chemie.C1->wpcaption # Set.Chemie.Titel.C;
    $lbMat.Chemie.C2->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbMat.Chemie.Si1->wpcaption # Set.Chemie.Titel.Si;
    $lbMat.Chemie.Si2->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbMat.Chemie.Mn1->wpcaption # Set.Chemie.Titel.Mn;
    $lbMat.Chemie.Mn2->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbMat.Chemie.P1->wpcaption # Set.Chemie.Titel.P;
    $lbMat.Chemie.P2->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbMat.Chemie.S1->wpcaption # Set.Chemie.Titel.S;
    $lbMat.Chemie.S2->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbMat.Chemie.Al1->wpcaption # Set.Chemie.Titel.Al;
    $lbMat.Chemie.Al2->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbMat.Chemie.Cr1->wpcaption # Set.Chemie.Titel.Cr;
    $lbMat.Chemie.Cr2->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbMat.Chemie.V1->wpcaption # Set.Chemie.Titel.V;
    $lbMat.Chemie.V2->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbMat.Chemie.Nb1->wpcaption # Set.Chemie.Titel.Nb;
    $lbMat.Chemie.Nb2->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbMat.Chemie.Ti1->wpcaption # Set.Chemie.Titel.Ti;
    $lbMat.Chemie.Ti2->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbMat.Chemie.N1->wpcaption # Set.Chemie.Titel.N;
    $lbMat.Chemie.N2->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbMat.Chemie.Cu1->wpcaption # Set.Chemie.Titel.Cu;
    $lbMat.Chemie.Cu2->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbMat.Chemie.Ni1->wpcaption # Set.Chemie.Titel.Ni;
    $lbMat.Chemie.Ni2->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbMat.Chemie.Mo1->wpcaption # Set.Chemie.Titel.Mo;
    $lbMat.Chemie.Mo2->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbMat.Chemie.B1->wpcaption # Set.Chemie.Titel.B;
    $lbMat.Chemie.B2->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbMat.Chemie.Frei1.1->wpcaption # Set.Chemie.Titel.1;
    $lbMat.Chemie.Frei1.2->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    $lbMat.HrteA1->wpcaption # "Set.Mech.Titel.Härte";
    $lbMat.HrteA2->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbMat.Krnung1->wpcaption # "Set.Mech.Titel.Körn";
    $lbMat.Krnung2->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbMat.Mech.Sonstiges1->wpcaption # "Set.Mech.Titel.Sonst";
    $lbMat.Mech.Sonstiges2->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    $lbMat.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
    $lbMat.RauigkeitA2->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    $lbMat.RauigkeitC1->wpcaption # "Set.Mech.Titel.Rau2";
    $lbMat.RauigkeitC2->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  if (Set.Mech.Dehnung.Wie<>1) then begin
    $lbMat.DehnungC1->wpvisible # false;
    $lbMat.DehnungC2->wpvisible # false;
  end;

  // Auswahlfelder setzen...
  SetStdAusFeld('edMat.Bilddatei'       ,'Bild');
  SetStdAusFeld('edMat.Warengruppe'     ,'Warengruppe');
  SetStdAusFeld('edMat.Status'          ,'Status');
  SetStdAusFeld('edMat.Intrastatnr'     ,'Intrastat');
  SetStdAusFeld('edMat.Strukturnr'      ,'Struktur');
  SetStdAusFeld('edMat.Guete'           ,'Guete');
  SetStdAusFeld('edMat.Guetenstufe'     ,'Guetenstufe');
  SetStdAusFeld('edMat.Verwiegungsart'  ,'Verwiegungsart');
  SetStdAusFeld('edMat.Unterlage'       ,'Unterlage');
  SetStdAusFeld('edMat.Umverpackung'    ,'Umverpackung');
  SetStdAusFeld('edMat.Zwischenlage'    ,'Zwischenlage');
  SetStdAusFeld('edMat.Erzeuger'        ,'Erzeuger');
  SetStdAusFeld('edMat.Ursprungsland'   ,'Ursprungsland');
  SetStdAusFeld('edMat.Lieferant'       ,'Lieferant');
  SetStdAusFeld('edMat.Lageradresse'    ,'Lageradresse');
  SetStdAusFeld('edMat.Lageranschrift'  ,'Lageranschrift');
  SetStdAusFeld('edMat.Lagerplatz'      ,'Lagerplatz');
  SetStdAusFeld('edMat.AF.Oben'         ,'AF.Oben');
  SetStdAusFeld('edMat.AF.Unten'        ,'AF.Unten');
  SetStdAusFeld('edMat.LieferStichwort' ,'LieferStichwort');
  SetStdAusFeld('edMat.LagerStichwort'  ,'LagerStichwort');
  SetStdAusFeld('edMat.Analysenr'       ,'Analyse');
  SetStdAusFeld('edMat.Zeugnisart'      ,'Zeugnis');
  SetStdAusFeld('edMat.Etikettentyp'    ,'Etikettentyp');

  // Ankerfunktion?
//  RunAFX('Mat.Init',aint(aEvT:Obj));
/***
  if (Sel_Main:LoadXML2Captions(0,'200.xml')) then
    Mat_Mark_Sel:StartSel(y);
***/
//  RETURN App_Main:EvtInit(aEvt);

  RunAFX('Mat.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Mat.Init',aint(aEvt:Obj));
  RETURN true;

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

  // MatSofortInAblage
  gTMP # Winsearch(gMenu, 'Mnu.Filter.Geloescht');
  if (gTMP<>0) then gTMP->wpMenuCheck # Filter_Mat;
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
  Lib_GuiCom:Pflichtfeld($edMat.Warengruppe);
  Lib_GuiCom:Pflichtfeld($edMat.Guete);
  Lib_GuiCom:Pflichtfeld($edMat.Lieferant);
  Lib_GuiCom:Pflichtfeld($edMat.Lageradresse);
  Lib_GuiCom:Pflichtfeld($edMat.Bestand.Stk);
  Lib_GuiCom:Pflichtfeld($edMat.Bestand.Gew);
  Lib_GuiCom:Pflichtfeld($edMat.Bestand);

  $edMat.LieferStichwort->wpreadonly # false;
  $edMat.LagerStichwort->wpreadonly # false;
  Lib_GuiCom:Pflichtfeld($edMat.LieferStichwort);
  Lib_GuiCom:Pflichtfeld($edMat.LagerStichwort);
  $edMat.LieferStichwort->wpreadonly # true;
  $edMat.LagerStichwort->wpreadonly # true;

//  Lib_GuiCom:Pflichtfeld($edMat.Dicke);
end;


//========================================================================
//  ToggleDelFilter
//
//========================================================================
sub ToggleDelFilter();
local begin
  vHdl  : int;
end;
begin
  Filter_Mat # !(Filter_MAt);
  vHdl # Winsearch(gMenu, 'Mnu.Filter.Geloescht');
  if (vHdl<>0)  then vHdl->wpMenuCheck # Filter_Mat;
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
end


//========================================================================
//  CheckAnalyse
//
//========================================================================
sub CheckAnalyse (aObjName : alpha; aFieldName : alpha);
local begin
  vHdl  : int;
  vVon  : float;
  vBis  : float;
  vOK   : logic;
end;
begin
  vHdl # gMdi->WinSearch(aObjName);
  if (vHdl=0) then RETURN;

  vhdl->winupdate(_WinUpdFld2Obj);
  if (vHdl != 0) and (vHdl->WinInfo(_winType) = _winTypeFloatEdit) and (true or vHdl->wpHelpTip = '' or vHdl->wpChanged or Mode = c_ModeView) then begin
    vHdl->wpHelpTipSysFont # true;
    vHdl->wpHelpTip        # MQU_Data:BildeVorgabe(aFieldName, 200, "Mat.Güte", "Mat.Dicke", var vVon, var vBis);
//debug(aFieldname+':'+vHdl->wpHelpTip);

    vOk # y;
    if ((vVon != 0.0) or (vBis != 0.0)) then begin
      if (vHdl->wpCaptionFloat < vVon) then vOK # n;
      if (vHdl->wpCaptionFloat > vBis) and (vBis<>0.0) then vOK # n;
    end;

    if (vOK=false) then
      vHdl->wpColBkg # _winColLightRed
    else if (vHdl->wpReadOnly) then
      vHdl->wpColBkg # ((((225 << 8) + 225) << 8) + 225)
    else
      vHdl->wpColBkg # _winColWindow;

    vHdl->WinUpdate(_winUpdObj2Fld);
  end;
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
  Erx   : int;
  vHdl  : int;
  vName : alpha;
  vA    : alpha;
  vNewM : logic;
  vMEH  : alpha;
end;
begin


  if (Mat.MEH='kg') then begin
    $edMat.EK.Preis->wpCaptionFloat # Mat.EK.Preis;
  end
  else begin
    $edMat.EK.Preis->wpCaptionFloat # Mat.EK.PreisProMEH;
  end;


  $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  if (Mat.Abrufdatum<>0.0.0) then
    $lb.Datum.Abruf->wpcaption # cnvad(Mat.Abrufdatum)
  else
    $lb.Datum.Abruf->wpcaption # '';

  if (Mat.Datum.Erzeugt<>0.0.0) then
    $lb.Datum.Erzeugt->wpcaption # cnvad(Mat.Datum.Erzeugt)
  else
    $lb.Datum.Erzeugt->wpcaption # '';

  if (Mat.Datum.VSBMeldung<>0.0.0) then
    $lb.Datum.VSBMeldung->wpcaption # cnvad(Mat.Datum.vSBMeldung)
  else
    $lb.Datum.VSBMeldung->wpcaption # '';

  if (Mat.Datum.Lagergeld<>0.0.0) then
    $lb.Datum.Lagergeld->wpcaption # cnvad(Mat.Datum.Lagergeld)
  else
    $lb.Datum.Lagergeld->wpcaption # '';
  if (Mat.Datum.Zinsen<>0.0.0) then
    $lb.Datum.Zinsen->wpcaption # cnvad(Mat.Datum.Zinsen)
  else
    $lb.Datum.Zinsen->wpcaption # '';

  if ($NB.Main->wpcurrent='NB.Page2') then begin
    RecbufClear(813);
    RecbufClear(501);
    if (Mat.Einkaufsnr<>0) then begin
      Erx # RecLink(500,200,30,_recFirst);        // Bestellung holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(510,200,31,_recFirst);      // ~Bestellung holen
        if (Erx>_rLocked) then begin
          recBufClear(510);
          recBufClear(511);
        end
        else begin
          Erx # RecLink(511,200,19,_recFirst);    // ~BestellPos holen
        end;
        RecbufCopy(510,500);
        RecBufCopy(511,501);
      end
      else begin
        Erx # RecLink(501,200,18,_recFirst);      // BestellPos holen
      end;

      Erx # RecLink(813,500,17,_recfirst);        // Steuerschlüssel holen
      if (Erx>_rLocked) then RecbufClear(813);
    end;

    if (StS.Nummer>0) then begin
      $lb.EKSteuer->wpcaption   # AInt(Sts.Nummer);
      $lb.EKSteuer2->wpcaption  # StS.Bezeichnung;
    end
    else begin
      $lb.EKSteuer->wpcaption   # '';
      $lb.EKSteuer2->wpcaption  # '';
    end;
  end;


  if ($NB.Main->wpcurrent='NB.Bild') then begin
// vName # 'C:\mat_'+ cnvai(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
    vName # Mat.Bilddatei;
    vA # StrCnv(Str_Token(vName,'.',2), _StrUpper);
    if (vA<>'PDF') then begin
      $pdf.Materialpic->wpvisible   # false;
      $pdf.Materialpic->wpdisabled  # true;
      $pic.Materialpic->wpvisible   # true;
      $pic.Materialpic->wpdisabled  # false;
      $pic.Materialpic->wpcaption   # '*'+vName;//+'.jpg';
    end
    else begin
      $pic.Materialpic->wpvisible   # false;
      $pic.Materialpic->wpdisabled  # true;
      $pdf.Materialpic->wpvisible   # true;
      $pdf.Materialpic->wpdisabled  # false;
      $pdf.Materialpic->wpfilename # '*'+vName;
    end;
  end;

  // kg errechnen
  if (Mat.Bestand.Stk<>0) and (Mat.Bestand.Gew=0.0) and
    (Mat.Dicke<>0.0) and (Mat.Breite<>0.0) and ("Mat.Länge"<>0.0) and (
    ($edMat.Dicke->wpchanged) or
    ($edMat.Breite->wpchanged) or
    ($edMat.Laenge->wpchanged) or
    ($edMat.Bestand.Stk->wpchanged)) then begin
    Mat.Bestand.Gew # Lib_Berechnungen:kg_aus_StkDBLDichte2(Mat.Bestand.Stk, Mat.Dicke, Mat.Breite, "Mat.Länge", Mat.Dichte, "Wgr.TränenKgProQM");
  end;

  // kg/mm errechnen
  if (Mat.Bestand.Stk<>0) and (Mat.Bestand.Gew<>0.0) and (
    ((aName='edMat.Breite') and ($edMat.Breite->wpchanged)) or
    ((aName='edMat.Bestand.Stk') and ($edMat.Bestand.Stk->wpchanged)) or
    ((aName='edMat.Bestand.Gew') and ($edMat.Bestand.Gew->wpchanged)))  then begin
    Mat.Kgmm # Lib_Berechnungen:kgmm_aus_KgStkB(Mat.Bestand.Gew, Mat.Bestand.Stk , Mat.Breite);
  end;
  if (Mat.Bestellt.Stk<>0) and (Mat.Bestellt.Gew<>0.0) and
    ((aName='edMat.Breite') and ($edMat.Breite->wpchanged)) then begin
//    ((aName='edMat.Bestellt.Stk') and ($edMat.Bestellt.Stk->wpchanged)) or
//    ((aName='edMat.Bestellt.Gew') and ($edMat.Bestellt.Gew->wpchanged)) or
    Mat.Kgmm # Lib_Berechnungen:kgmm_aus_KgStkB(Mat.Bestellt.Gew, Mat.Bestellt.Stk , Mat.Breite);
  end;


  if (aName='edMat.DickenTol') and (Mat.Dicke<>0.0) then begin
    "Mat.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("Mat.Dickentol",Set.Stellen.Dicke);
    $edMat.Dickentol->Winupdate();
  end;

  if (aName='edMat.BreitenTol') and (Mat.Breite<>0.0) then begin
    "Mat.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("Mat.Breitentol",Set.Stellen.Breite);
    $edMat.Breitentol->Winupdate();
  end;

  if (aName='edMat.LaengenTol') and ("Mat.Länge"<>0.0) then begin
    "Mat.Längentol" # Lib_Berechnungen:Toleranzkorrektur("Mat.Längentol","Set.Stellen.Länge");
    $edMat.Laengentol->Winupdate();
  end;

  if (aName='edMat.Guete') and ($edMat.Guete->wpchanged) then begin
    MQu_Data:Autokorrektur(var "Mat.Güte");
    Mat.Werkstoffnr # MQU.Werkstoffnr;
    Mat.Dichte      # Wgr_Data:GetDichte(Wgr.Nummer, 200);
    $Lb.Mat.Dichte->wpcaption # ANum(Mat.Dichte,5);
    $edMat.Guete->Winupdate();
  end;

//  if (mode=c_modeNew) and (aName='edMat.EK.Preis') then begin
//    DivOrNull(Mat.EK.Preis, Mat.EK.preisProMEH * (Mat.Bestand.Menge + Mat.Bestellt.Menge), ((Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) ,2);
//  end;

  if (aName='') or (aName='edMat.Bestand.Stk') or (aName='edMat.Bestellt.Stk') then begin
    "Mat.Verfügbar.Stk" # Mat.Bestand.Stk + Mat.Bestellt.Stk - Mat.Reserviert.Stk;
    if ("Mat.Verfügbar.Stk"<>0) then
      $lb.VerfuegbarStk->wpcaption # AInt("Mat.Verfügbar.Stk");
    else
      $lb.VerfuegbarStk->wpcaption # '';
    if (Mode=c_ModeNew) and (Mat.MEH='Stk') then begin
      Mat.Bestand.Menge # cnvfi(Mat.Bestand.Stk);
      vNewM # true;
    end;
  end;

  if (aName='') or (aName='edMat.Bestand.Gew') or (aName='edMat.Bestellt.Gew') then begin
    "Mat.Verfügbar.Gew" # Mat.Bestand.Gew + Mat.Bestellt.Gew - Mat.Reserviert.Gew;
    if ("Mat.Verfügbar.Gew"<>0.0) then
      $lb.VerfuegbarGew->wpcaption # ANum("Mat.Verfügbar.Gew",Set.Stellen.Gewicht);
    else
      $lb.VerfuegbarGew->wpcaption # '';
    if (Mode=c_ModeNew) then begin
      if (Mat.MEH='kg') then begin
        Mat.Bestand.Menge# Mat.Bestand.Gew;
        vNewM # true;
      end
      else if (Mat.MEH='t') then begin
        Mat.Bestand.Menge # Rnd(Mat.Bestand.Gew / 1000.0, Set.Stellen.Menge);
        vNewM # true;
      end;
    end;
  end;

  if (vNewM) then begin
    $edMat.Bestand->wpcaptionfloat # Mat.Bestand.Menge;
  end;

  if (vNewM) or (aName='') or (aName='edMat.Bestand') then begin
    "Mat.Verfügbar.Menge" # Mat.Bestand.Menge + Mat.Bestellt.Menge - Mat.Reserviert.Menge;
    if ("Mat.Verfügbar.Menge"<>0.0) then
      $lb.Verfuegbar->wpcaption # ANum("Mat.Verfügbar.Menge", Set.Stellen.Menge);
    else
      $lb.Verfuegbar->wpcaption # '';
  end;


  if (aName='') or (aName='edMat.Warengruppe') then begin
    Mat.Dichte # 0.0;
    Erx # RecLink(819,200,1,0);
    if (Erx<=_rLocked) then begin
      $Lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1;
      Mat.Dichte # Wgr_Data:GetDichte(Wgr.Nummer, 200);
    end
    else begin
      $Lb.Warengruppe->wpcaption # '';
    end;
    $Lb.Mat.Dichte->wpcaption # ANum(Mat.Dichte,5);

    $Lb.Mat.Warengruppe2->wpcaption # AInt(Mat.Warengruppe);
    $Lb.Mat.Warengruppe3->wpcaption # $Lb.Mat.Warengruppe2->wpcaption;
    $Lb.Mat.Warengruppe4->wpcaption # $Lb.Mat.Warengruppe2->wpcaption;
    $Lb.Warengruppe2->wpcaption # $Lb.Warengruppe->wpcaption;
    $Lb.Warengruppe3->wpcaption # $Lb.Warengruppe->wpcaption;
    $Lb.Warengruppe4->wpcaption # $Lb.Warengruppe->wpcaption;

    if (Wgr_Data:IstMix()) then
      $lbMat.Strukturnr->wpcaption # Translate('Artikelnr.')
    else
      $lbMat.Strukturnr->wpcaption # Translate('Strukturnr.');
  end;

// qqq
  if (Mode=c_ModeNew) then
    Lib_GuiCom:Able($edMat.Bestand, (Mat.MEH<>'t') and (Mat.MEH<>'kg') and (Mat.MEH<>'Stk'));

  if (Wgr_Data:IstMix()) and
    (aName='edMat.Strukturnr') and (($edMat.Strukturnr->wpchanged) or (aChanged)) then begin
    Erx # RecLink(250,200,26,_recFirst);    // Artikel holen
    if (Erx>_rLocked) then begin
      Mat.Strukturnr  # '';
    end
    else begin
      if (Mat.MEH<>Art.MEH) then begin
        if (Mode=c_modenew) then begin
          Mat.MEH             # Art.MEH;
          $Lb.MEH->winupdate(_WinUpdFld2Obj);
          Mat.EK.PreisProMEH  # 0.0;
          Mat.Bestand.Menge   # 0.0;
          $edMat.Bestand->winupdate(_WinUpdFld2Obj);
          $edMat.EK.Preis->winupdate(_WinUpdFld2Obj);
          Refreshifm('');
        end
        else begin
          Mat.Strukturnr # ProtokollBuffer[200]->Mat.Strukturnr;
          $edMat.Strukturnr->winupdate(_WinUpdFld2Obj);
          Msg(200025,Art.MEh+'|'+Mat.MEH,0,0,0);
        end;
      end;
    end;
  end;

  // bei KG trotzdem T anzeigen
  vMEH # Mat.MEH;
  if (Mat.MEH='kg') then vMEH # 't';
  if (Mat.Bewertung.Laut='D') then
    $lbMat.EK.Preis->wpcaption # Translate('Ur-Preis')+'/'+vMEH
  else
    $lbMat.EK.Preis->wpcaption # Translate('Preis')+'/'+vMEH;


  if (aName='') or (aName='edMat.EK.Preis') or (aName='edMat.Bestand') or (vNewM) then begin
    Mat.EK.EffektivProME # Mat.EK.PreisProMEH + Mat.KostenProMEH;
    if (Mat.MEH<>'kg') then begin
      $lb.Mat.Kosten->wpcaption         # ANum(Mat.KostenProMEH,2);
      $lb.Mat.EK.Effektiv->wpcaption    # ANum(Mat.EK.EffektivProME,2);
      $lb.Mat.EK.PreisGes->wpcaption    # ANum(Mat.EK.PreisProMEH * Mat.Bestand.Menge,2);
      $lb.Mat.KostenGes->wpcaption      # ANum(Mat.KostenProMEH * Mat.Bestand.Menge,2);
      $lb.Mat.EK.EffektivGes->wpcaption # ANum(Mat.EK.EffektivProME * Mat.Bestand.Menge,2);
    end
    else begin
      $lb.Mat.Kosten->wpcaption         # ANum(Mat.Kosten,2);
      $lb.Mat.EK.Effektiv->wpcaption    # ANum(Mat.EK.Effektiv,2);
      $lb.Mat.EK.PreisGes->wpcaption    # ANum(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
      $lb.Mat.KostenGes->wpcaption      # ANum(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);
      $lb.Mat.EK.EffektivGes->wpcaption # ANum(Mat.EK.Effektiv * Mat.Bestand.Gew / 1000.0,2);
    end;

  end;


  if (aName='') or (aName='edMat.Status') then begin
    Erx # RecLink(820,200,9,0);
    if (Erx<=_rLocked) then
      $Lb.Status->wpcaption # Mat.Sta.Bezeichnung
    else
      $Lb.Status->wpcaption # '';
    if ("Mat.Löschmarker"<>'') then begin
      $Lb.Status->wpColBkg # _WinColParent;
    end
    else if (Lib_Cache:Read820(Mat.Status)=_rOK) and (Mat.Sta.Color<>0) and (Mat.Sta.Color<>_Wincolparent) then begin    // 2022-09-28 AH
      $Lb.Status->wpColBkg # Mat.Sta.Color;
    end
    else begin
      if (Mat.Status<=c_status_Frei) then begin
        if (Mat.EigenmaterialYN) then
          $Lb.Status->wpColBkg # Set.Mat.Col.Frei
        else
          $Lb.Status->wpColBkg # Set.Mat.Col.Fremd;
      end;
      //if (Mat.Status>c_status_Frei) and (Mat.Status<c_Status_bestellt) then
      if (Mat.Kommission<>'') then
        $Lb.Status->wpColBkg # Set.Mat.Col.Kommissi
      else if (Mat.Status=c_Status_EKVSB) then
        $Lb.Status->wpColBkg # Set.Mat.Col.EKVSB
      else if (Mat.Status>=c_Status_bestellt) and (Mat.Status<=c_Status_bisEK) then
        $Lb.Status->wpColBkg # Set.Mat.Col.Bestellt
      else if (Mat.Status>c_Status_BisEK) and (Mat.Status<c_Status_gesperrt) then
        $Lb.Status->wpColBkg # Set.Mat.Col.inBAG
      else if (Mat.Status>=c_Status_gesperrt) then
        $Lb.Status->wpColBkg # Set.Mat.Col.Gesperrt;


    end;
  end;

  if (aName='') or (aName='edMat.Ursprungsland') then begin
    Erx # RecLink(812,200,2,0);
    if (Erx<=_rLocked) then
      $Lb.Land->wpcaption # Lnd.Name.L1
    else
      $Lb.Land->wpcaption # '';
  end;

  if (aName='') or (aName='edMat.Erzeuger') then begin
    Erx # RecLink(100,200,3,0);
    if (Erx<=_rLocked) and (Mat.Erzeuger<>0) then
      $Lb.Erzeuger->wpcaption # Adr.Stichwort
    else
      $Lb.Erzeuger->wpcaption # '';
  end;

  if (aName='') or (aName='edMat.Lieferant') or (aName='edMat.LieferStichwort') then begin
    Erx # RecLink(100,200,4,0);
    if (Erx<=_rLocked) and (Mat.Lieferant<>0) then begin
      $Lb.Lieferant2->wpcaption # Adr.Stichwort;
      Mat.LieferStichwort # Adr.Stichwort;
//      $edMat.LieferStichwort->wpcaption # Adr.Stichwort;
    end
    else begin
      Mat.LieferStichwort # '';
      Mat.Lieferant # 0;
      $Lb.Lieferant2->wpcaption # '';
      $edMat.LieferStichwort->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edMat.Lageradresse') or (aName='edMat.Lageranschrift') or (aName='edMat.LagerStichwort') then begin
    Erx # RecLink(101,200,6,0);
    if (Erx<=_rLocked) and (Mat.Lageradresse<>0) then begin
      $Lb.Lagerort2->wpcaption # Adr.A.Stichwort
      Mat.LagerStichwort # Adr.A.Stichwort;
//      $edMat.LagerStichwort->wpcaption # Adr.A.Stichwort;
    end
    else begin
      Mat.LagerStichwort # '';
      Mat.Lageradresse # 0;
      Mat.Lageranschrift # 0;
      $Lb.Lagerort2->wpcaption # '';
      $edMat.LagerStichwort->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edMat.VK.Kundennr') then begin
    Erx # RecLink(100,200,8,0);
    if (Erx<=_rLocked) and (Mat.VK.Kundennr<>0) then
      $Lb.VKKunde->wpcaption # Adr.Stichwort
    else
      $Lb.VKKunde->wpcaption # '';
  end;

/*  if (aName='') and (Mat.Auftragsnr<>0) then begin
    $Lb.KommKunde->wpcaption #
    end
  else begin
    $Lb.KommKunde->wpcaption # '';
  end;
*/
  if (aName='') or (aName='edMat.Verwiegungsart') then begin
    Erx # RecLink(818,200,10,0);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    $Lb.Verwiegungsart->wpcaption # VwA.Bezeichnung.L1
    if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then begin
      if (Erx<=_rLocked) then begin
        if (VWa.NettoYN) then begin
          Lib_GuiCom:Disable($edMat.Gewicht.Netto);
          Lib_GuiCom:Enable($edMat.Gewicht.Brutto);
        end
        else if (VWa.BruttoYN) then begin
          Lib_GuiCom:Disable($edMat.Gewicht.Brutto);
          Lib_GuiCom:Enable($edMat.Gewicht.Netto);
        end
        else begin
          Lib_GuiCom:Enable($edMat.Gewicht.Netto);
          Lib_GuiCom:Enable($edMat.Gewicht.Brutto);
        end;
      end
      else begin
        Mat.Gewicht.Netto   # Mat.Bestand.Gew;
        Mat.Gewicht.Brutto  # Mat.Bestand.Gew;
        $edMat.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edMat.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edMat.Gewicht.Netto);
        Lib_GuiCom:Disable($edMat.Gewicht.Brutto);
      end;
    end;

  end;

  if (aName='') or (aName='edMat.Etikettentyp') then begin
    Erx # RecLink(840,200,33,_recfirst);    // Etikettentyp holen
    if (Erx<=_rLocked) then
      $Lb.Etikettentyp->wpcaption # Eti.Bezeichnung
    else
      $Lb.Etikettentyp->wpcaption # '';
  end;

  if (aName='') or (aName='edMat.Guete') then begin
    $Lb.Mat.Guete2->wpcaption # "Mat.Güte";
    $Lb.Mat.Guete3->wpcaption # $Lb.Mat.Guete2->wpcaption;
    $Lb.Mat.Guete4->wpcaption # $Lb.Mat.Guete2->wpcaption;
    $Lb.Werkstoff->wpcaption  # Mat.Werkstoffnr;
    $Lb.Werkstoff2->wpcaption # $Lb.Werkstoff->wpcaption;
    $Lb.Werkstoff3->wpcaption # $Lb.Werkstoff->wpcaption;
    $Lb.Werkstoff4->wpcaption # $Lb.Werkstoff->wpcaption;
  end;

  if (aName='') or (aName='edMat.Guetenstufe') then begin
    $Lb.Mat.Guetenstufe2->wpcaption # "Mat.Gütenstufe";
    $Lb.Mat.Guetenstufe3->wpcaption # $Lb.Mat.Guetenstufe2->wpcaption;
    $Lb.Mat.Guetenstufe4->wpcaption # $Lb.Mat.Guetenstufe2->wpcaption;
  end;

  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
    if (aName='') or (aName='cbMat.EigenmaterialYN1') then
      if (Mat.EigenmaterialYN=n) then
        Lib_GuiCom:Disable($edMat.Uebernahmedatum)
      else
        Lib_GuiCom:Enable($edMat.Uebernahmedatum);
/***
    if (aName='') or (aName='cbMat.DickenTolYN') then
      if (Mat.DickenTolYN=n) then
        Lib_GuiCom:Disable($edMat.DickenTol)
      else
        Lib_GuiCom:Enable($edMat.DickenTol);

    if (aName='') or (aName='cbMat.BreitenTolYN') then
      if (Mat.BreitenTolYN=n) then
        Lib_GuiCom:Disable($edMat.BreitenTol)
      else
        Lib_GuiCom:Enable($edMat.BreitenTol);

    if (aName='') or (aName='cbMat.LaengenTolYN') then
      if ("Mat.LängenTolYN"=n) then
        Lib_GuiCom:Disable($edMat.LaengenTol)
      else
        Lib_GuiCom:Enable($edMat.LaengenTol);
***/
  end;

  if (aName='') then begin

    vHdl # Winsearch(gMDI, 'Lb.Mat.LfE');
    if (vHdl>0) then begin
      if (Mat.LfENr=-1) then
        vHdl->wpcaption # Translate('fehlt')
      else if (Mat.LfENr>0) then
        vHdl->wpcaption # aint(Mat.LfeNr)
      else
        vHdl->wpcaption # Translate('ohne');
    end;

    $lb.geloescht->wpvisible # ("Mat.Löschmarker"<>'');

    $Lb.Mat.Nummer->wpcaption # '';
    if (Mat.Nummer<1000000000) then
      $Lb.Mat.Nummer->wpcaption # AInt(Mat.Nummer);

    $Lb.Mat.Vorgaenger->wpcaption # '';
    if ("Mat.Vorgänger"<>0) then
      $Lb.Mat.Vorgaenger->wpcaption # AInt("Mat.Vorgänger");

    $Lb.Mat.Ursprung->wpcaption # '';
    if ("Mat.Ursprung"<>0) then
      $Lb.Mat.Ursprung->wpcaption # AInt("Mat.Ursprung");

    $Lb.Mat.Nummer2->wpcaption # $Lb.Mat.Nummer->wpcaption;
    $Lb.Mat.Nummer3->wpcaption # $Lb.Mat.Nummer->wpcaption;
    $Lb.Mat.Nummer4->wpcaption # $Lb.Mat.Nummer->wpcaption;
    $Lb.Mat.Vorgaenger2->wpcaption # $Lb.Mat.Vorgaenger->wpcaption;
    $Lb.Mat.Vorgaenger3->wpcaption # $Lb.Mat.Vorgaenger->wpcaption;
    $Lb.Mat.Vorgaenger4->wpcaption # $Lb.Mat.Vorgaenger->wpcaption;
    $Lb.Mat.Ursprung2->wpcaption # $Lb.Mat.Ursprung->wpcaption;
    $Lb.Mat.Ursprung3->wpcaption # $Lb.Mat.Ursprung->wpcaption;
    $Lb.Mat.Ursprung4->wpcaption # $Lb.Mat.Ursprung->wpcaption;

    $Lb.Mat.Kommission->wpcaption # Mat.Kommission;

    $Lb.Mat.Dichte->wpcaption # ANum(Mat.Dichte,5);

    if (Mat.Reserviert.Stk>0) then
      $lb.ReserviertStk->wpcaption # AInt("Mat.Reserviert.Stk")
    else
      $lb.ReserviertStk->wpcaption # '';
    if (Mat.Reserviert.Gew<>0.0) then
      $lb.ReserviertGew->wpcaption # ANum("Mat.Reserviert.Gew",Set.Stellen.Gewicht)
    else
      $lb.ReserviertGew->wpcaption # '';
    if (Mat.Reserviert.Menge<>0.0) then
      $lb.Reserviert->wpcaption # ANum("Mat.Reserviert.Menge",Set.Stellen.Menge)
    else
      $lb.Reserviert->wpcaption # '';

    if (Mat.Bestellt.Stk<>0) then
      $lb.BestelltStk->wpcaption # AInt("Mat.Bestellt.Stk")
    else
      $lb.BestelltStk->wpcaption # '';
    if (Mat.Bestellt.Gew<>0.0) then
      $lb.BestelltGew->wpcaption # ANum("Mat.Bestellt.Gew",Set.Stellen.Gewicht)
    else
      $lb.BestelltGew->wpcaption # '';
    if (Mat.Bestellt.Menge<>0.0) then
      $lb.Bestellt->wpcaption # ANum("Mat.Bestellt.Menge",Set.Stellen.Menge)
    else
      $lb.Bestellt->wpcaption # '';
  end;

/*  02.04.2013
  Mat.KgMM # 0.0;
  If (Mat.Breite<>0.0) and (Mat.Bestand.Stk+Mat.Bestellt.Stk<>0) then
    Mat.KgMM # (Mat.Bestand.Gew+Mat.Bestellt.Gew) / CnvFI(Mat.Bestand.Stk+Mat.Bestellt.Stk) / Mat.Breite;
  If (Mat.Breite<>0.0) and (Mat.Bestand.Stk+Mat.Bestellt.Stk=0) then
    Mat.KgMM # (Mat.Bestand.Gew+Mat.Bestellt.Gew) / Mat.Breite;
*/
  if (Mat.MEH='m') then begin
    $lbMat.Kgmm->wpcaption # 'kg/m';
    $Lb.Mat.KgMM->wpcaption # ANum(Mat.KgMM * 1000.0,5)
  end
  else begin
    $lbMat.Kgmm->wpcaption # 'kg/mm';
    $Lb.Mat.KgMM->wpcaption # ANum(Mat.KgMM,5)
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfaerben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

/***
  // Analyse Check
  if (aName != '') then begin
    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.Streckgrenze')    then CheckAnalyse(aName, 'Streckgrenze');
    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.Zugfestigkeit')   then CheckAnalyse(aName, 'Zugfestigkeit');

    if (Set.Mech.Dehnung.Wie=1) then begin
      if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungA')        then CheckAnalyse(aName, 'DehnungA');
      if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungB')        then CheckAnalyse(aName, 'DehnungB');
    end;
    if (Set.Mech.Dehnung.Wie=2) then begin
      if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungA')        then CheckAnalyse(aName, 'DehnungB');
      if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungB')        then CheckAnalyse(aName, 'DehnungA');
    end;
    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungC')        then CheckAnalyse(aName, 'DehnungB');

    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungsgrenzeA') then CheckAnalyse(aName, 'DehngrenzeA');
    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.DehnungsgrenzeB') then CheckAnalyse(aName, 'DehngrenzeB');
    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.Krnung')          then CheckAnalyse(aName, 'Koernung');
    if (StrCut(aName, 1, StrLen(aName) - 1) = 'edMat.HaerteA')          then  CheckAnalyse(aName, 'Haerte');
    if (StrCut(aName, 1, 13) = 'edMat.Chemie.') then CheckAnalyse(aName, StrCut(aName, 14, StrLen(aName) - 14));
  end
  else begin
    CheckAnalyse('edMat.Streckgrenze1',    'Streckgrenze');
    CheckAnalyse('edMat.Zugfestigkeit1',   'Zugfestigkeit');

    CheckAnalyse('edMat.DehnungC1',        'DehnungB');
    if (Set.Mech.Dehnung.Wie=1) then begin
      CheckAnalyse('edMat.DehnungA1',        'DehnungA');
      CheckAnalyse('edMat.DehnungB1',        'DehnungB');
    end;
    if (Set.Mech.Dehnung.Wie=2) then begin
      CheckAnalyse('edMat.DehnungA1',        'DehnungB');
      CheckAnalyse('edMat.DehnungB1',        'DehnungA');
    end;
***/
  if (Set.Mat.LyseCheck='1') and (Mat_Data:HatAnalyse(1)=false) then begin
  end
  else begin
    Mat_Main:CheckAnalyse2(aName, $lbMat.Streckgrenze1, 'Streckgrenze', $edMat.Streckgrenze1, $edMat.StreckgrenzeB1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.Zugfestigkeit1, 'Zugfestigkeit', $edMat.Zugfestigkeit1, $edMat.ZugfestigkeitB1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungA1, 'DehnungA', $edMat.DehnungA1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungA1, 'DehnungB', $edMat.DehnungB1, $edMat.DehnungC1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungsgrenzeA1, 'DehngrenzeA', $edMat.DehnungsgrenzeA1, $edMat.RP02_B1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungsgrenzeB1, 'DehngrenzeB', $edMat.DehnungsgrenzeB1, $edMat.RP10_B1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.Krnung1, 'Koernung', $edMat.Krnung1, $edMat.KrnungB1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.HrteA1, 'Haerte', $edMat.HaerteA1, $edMat.HaerteB1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.RauigkeitA1, 'RauigkeitA', $edMat.RauigkeitA1, $edMat.RauigkeitB1);
    Mat_Main:CheckAnalyse2(aName, $lbMat.RauigkeitC1, 'RauigkeitB', $edMat.RauigkeitC1, $edMat.RauigkeitD1);

    CheckAnalyse('edMat.DehnungsgrenzeA1', 'DehngrenzeA');
    CheckAnalyse('edMat.DehnungsgrenzeB1', 'DehngrenzeB');
    CheckAnalyse('edMat.Krnung1',          'Koernung');
    CheckAnalyse('edMat.HaerteA1',         'Haerte');
    CheckAnalyse('edMat.Chemie.C1',        'C');
    CheckAnalyse('edMat.Chemie.Si1',       'Si');
    CheckAnalyse('edMat.Chemie.Mn1',       'Mn');
    CheckAnalyse('edMat.Chemie.P1',        'P');
    CheckAnalyse('edMat.Chemie.S1',        'S');
    CheckAnalyse('edMat.Chemie.Al1',       'Al');
    CheckAnalyse('edMat.Chemie.Cr1',       'Cr');
    CheckAnalyse('edMat.Chemie.V1',        'V');
    CheckAnalyse('edMat.Chemie.Nb1',       'Nb');
    CheckAnalyse('edMat.Chemie.Ti1',       'Ti');
    CheckAnalyse('edMat.Chemie.N1',        'N');
    CheckAnalyse('edMat.Chemie.Cu1',       'Cu');
    CheckAnalyse('edMat.Chemie.Ni1',       'Ni');
    CheckAnalyse('edMat.Chemie.Mo1',       'Mo');
    CheckAnalyse('edMat.Chemie.B1',        'B');
    CheckAnalyse('edMat.Chemie.Frei1.1',   'Frei1');
/***
    CheckAnalyse('edMat.Streckgrenze2',    'Streckgrenze');
    CheckAnalyse('edMat.Zugfestigkeit2',   'Zugfestigkeit');
    CheckAnalyse('edMat.DehnungA2',        'DehnungA');
    CheckAnalyse('edMat.DehnungB2',        'DehnungB');
    CheckAnalyse('edMat.DehnungsgrenzeA2', 'DehngrenzeA');
    CheckAnalyse('edMat.DehnungsgrenzeB2', 'DehngrenzeB');
    CheckAnalyse('edMat.Krnung2',          'Koernung');
    CheckAnalyse('edMat.HaerteA2',         'Haerte');
***/
  end;
  
  
  if (Set.Mat.LyseCheck<>'') and (Mat_Data:HatAnalyse(2)=false) then begin
  end
  else begin
    Mat_Main:CheckAnalyse2(aName, $lbMat.Streckgrenze2, 'Streckgrenze', $edMat.Streckgrenze2, $edMat.StreckgrenzeB2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.Zugfestigkeit2, 'Zugfestigkeit', $edMat.Zugfestigkeit2, $edMat.ZugfestigkeitB2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungA2, 'DehnungA', $edMat.DehnungA2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungA2, 'DehnungB', $edMat.DehnungB2, $edMat.DehnungC2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehnungsgrenzeA2, 'DehngrenzeA', $edMat.DehnungsgrenzeA2, $edMat.RP02_B2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.DehungsgrenzeB2, 'DehngrenzeB', $edMat.DehnungsgrenzeB2, $edMat.RP10_B2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.Krnung2, 'Koernung', $edMat.Krnung2, $edMat.KrnungB2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.HrteA2, 'Haerte', $edMat.HaerteA2, $edMat.HaerteB2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.RauigkeitA2, 'RauigkeitA', $edMat.RauigkeitA2, $edMat.RauigkeitB2);
    Mat_Main:CheckAnalyse2(aName, $lbMat.RauigkeitC2, 'RauigkeitB', $edMat.RauigkeitC2, $edMat.RauigkeitD2);

    CheckAnalyse('edMat.Chemie.C2',        'C');
    CheckAnalyse('edMat.Chemie.Si2',       'Si');
    CheckAnalyse('edMat.Chemie.Mn2',       'Mn');
    CheckAnalyse('edMat.Chemie.P2',        'P');
    CheckAnalyse('edMat.Chemie.S2',        'S');
    CheckAnalyse('edMat.Chemie.Al2',       'Al');
    CheckAnalyse('edMat.Chemie.Cr2',       'Cr');
    CheckAnalyse('edMat.Chemie.V2',        'V');
    CheckAnalyse('edMat.Chemie.Nb2',       'Nb');
    CheckAnalyse('edMat.Chemie.Ti2',       'Ti');
    CheckAnalyse('edMat.Chemie.N2',        'N');
    CheckAnalyse('edMat.Chemie.Cu2',       'Cu');
    CheckAnalyse('edMat.Chemie.Ni2',       'Ni');
    CheckAnalyse('edMat.Chemie.Mo2',       'Mo');
    CheckAnalyse('edMat.Chemie.B2',        'B');
    CheckAnalyse('edMat.Chemie.Frei1.2',   'Frei1');
  end;


  RunAFX('Mat.RefreshIfm.Post',aName);

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx   : int;
  vHdl  : int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('Mat.RecInit','')<0) then RETURN;


/*** Projekt 1381/93
  if ((Mat.Kommission<>'') and (Mat.Status<>750)) then begin
    Lib_GuiCom:Disable($edMat.Status);
    Lib_GuiCom:Disable($bt.Status);
  end
  else begin
    Lib_GuiCom:Enable($edMat.Status);
    Lib_GuiCom:Enable($bt.Status);
  end;
***/

//  $edMat.Status->wpdisabled # (Mat.Kommission<>'') and (Mat.Status<>750);
//  $bt.Status->wpdisabled    # (Mat.Kommission<>'') and (Mat.Status<>750);

  if (Mode=c_ModeEdit) then begin
    Ein.P.Materialnr # Mat.Nummer;
    Erx # RecRead(501,8,_rectest);
    if (Erx>_rMultikey) then begin
      Ein.E.Materialnr # Mat.Nummer;
      Erx # RecRead(506,2,_rectest);
    end;
    if (Erx<=_rMultikey) then begin
      Msg(200004,'',_WinIcoWarning,0,0);
    end;


    Erx # RecLink(819,200,1,0);   // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);

    if (Wgr_Data:IstMix()) then begin
      //Lib_GuiCom:Disable($edMat.Strukturnr);
      //Lib_GuiCom:Disable($bt.Struktur);
    end
    else begin
//      Lib_GuiCom:Disable($edMat.Strukturnr);
//      Lib_GuiCom:Disable($bt.Struktur);
    end;

  end;

  if (Mode=c_ModeNew) then begin

    Mat.Lageradresse    # Set.Mat.Lageradresse;
    Mat.Lageranschrift  # Set.Mat.Lageranschr;
//    Mat.MEH             # 't';
Mat.MEH             # 'kg';

    if (w_AppendNr<>0) then begin
      Mat.Nummer # w_AppendNr;
      RecRead(200,1,0);
      w_AppendNr        # 0;
      Mat.Ursprung      # 0;
      "Mat.Vorgänger"   # 0;
      Mat.Paketnr       # 0;
      Mat.Ausgangsdatum     # 0.0.0;
      Mat.Inventurdatum     # 0.0.0;
      Mat.Datum.Lagergeld   # 0.0.0;
      Mat.Abrufdatum        # 0.0.0;
      Mat.Datum.Zinsen      # 0.0.0;
      Mat.Datum.Erzeugt     # 0.0.0;
      Mat.Datum.VSBMeldung  # 0.0.0;
      Mat.VK.Korrektur      # 0.0;
      Mat.Inventur.DruckYN  # n;

      Mat.Status          # 1;
      "Mat.Löschmarker"   # '';
      Mat.Kosten          # 0.0;
      Mat.Reserviert.Gew  # 0.0;
      Mat.Reserviert.Stk  # 0;
      Mat.Reserviert2.Gew # 0.0;
      Mat.Reserviert2.Stk # 0;
      Mat.Reserviert2.Meng  # 0.0;
      Mat.Reserviert.Menge  # 0.0;
      "Mat.Verfügbar.Stk" # Mat.Bestand.Stk + Mat.Bestellt.Stk - Mat.Reserviert.Stk;
      "Mat.Verfügbar.Gew" # Mat.Bestand.Gew + Mat.Bestellt.Gew - Mat.Reserviert.Gew;
      Mat.Kommission      # '';
      Mat.Auftragsnr      # 0;
      Mat.Auftragspos     # 0;
      Mat.Auftragspos2    # 0;
      Mat.KommKundennr    # 0;
      Mat.KommKundenSWort # '';
      Mat.Bestellnummer   # '';
      Mat.Einkaufsnr      # 0;
      Mat.Einkaufspos     # 0;
      Mat.BestellABNr     # '';
      Mat.Bestelldatum    # 0.0.0;
      Mat.BestellTermin   # 0.0.0;
      Mat.VK.Kundennr     # 0;
      Mat.VK.Rechnr       # 0;
      Mat.VK.Rechdatum    # 0.0.0;
      Mat.VK.Preis        # 0.0;
      Mat.VK.Gewicht      # 0.0;
      Mat.EK.RechNr       # 0;
      Mat.EK.RechDatum    # 0.0.0;

      // Ausführungen kopieren ********************
      Erx # RecLink(201,200,11,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        Mat.AF.Nummer # myTmpNummer;
        RekInsert(201,0,'AUTO');

        Mat.AF.Nummer # Mat.Nummer;
        Erx # RecLink(201,200,11,_RecNext);
      END;
    end
    else begin
      // 03.12.2014
      if (w_parent<>0) then begin
        vHdl # 0;
        if ( w_Parent->wpName = GetDialogName('Art.Verwaltung') ) then begin // aus Artikelcharge?
          vHdl # w_parent->wpdbrecbuf(250);
        end
        if ( w_Parent->wpName =^ GetDialogName('Auf.P.Verwaltung') ) then begin // aus Auftrag?
          if (Auf.P.Artikelnr<>'') then begin
            vHdl # RecBufCreate(250);
            Erx # RecLink(vHdl, 401, 2, _recFirst);     // Artikel holen
            if (Erx>_rLocked) then begin
              recbufClear(vHdl);
              vHdl # 0;
            end;
          end;
        end
        if (vHdl<>0) then begin
          Mat.Strukturnr  # vHdl->Art.Nummer;
          Mat.MEH         # vHdl->Art.MEH;
          Mat.Warengruppe # vHdl->Art.Warengruppe;
          "Mat.Güte"      # vHdl->"Art.Güte";
          Mat.Dicke       # vHdl->Art.Dicke;
          Mat.Breite      # VHdl->Art.Breite;
          "Mat.Länge"     # vHdl->"Art.Länge";
          Mat.Dickentol   # vHdl->Art.DickenTol;
          Mat.Breitentol  # VHdl->Art.BreitenTol;
          "Mat.Längentol" # vHdl->"Art.LängenTol";
          Mat.RID         # vHdl->Art.Innendmesser;
          Mat.RAD         # vHdl->Art.Aussendmesser;
          Mat.KgMM        # vHdl->Art.GewichtProM / 1000.0;   // 2022-11-30 AH
          // 2022-08-15 AH : Ausführungen kopieren
          FOR Erx # recLink(257,vHdl,27,_recFirst)
          LOOP Erx # recLink(257,vHdl,27,_recNext)
          WHILE (Erx<=_rLocked) do begin
            Mat.AF.Nummer       # myTmpNummer;
            Mat.AF.Seite        # Art.AF.Seite;
            Mat.AF.lfdNr        # Art.AF.lfdNr;
            Mat.AF.ObfNr        # Art.AF.ObfNr;
            Mat.AF.Bezeichnung  # Art.AF.Bezeichnung;
            Mat.AF.Zusatz       # Art.AF.Zusatz;
            Mat.AF.Bemerkung    # Art.AF.Bemerkung;
            "Mat.AF.Kürzel"     # "Art.AF.Kürzel";
            Erx # RekInsert(201);
          END;
          "Mat.AusführungOben"  # vHdl->"Art.AusführungOben";
          "Mat.AusführungUnten" # vHdl->"Art.AusführungUnten";
        end;
      end;
    end;

    Mat.Nummer        # myTmpNummer;
    Mat.Status        # 1;
    Mat.Eingangsdatum # today;
    Mat.Datum.Erzeugt # Mat.Eingangsdatum;
  end;

  // Felder Disablen durch:
  Lib_GuiCom:Disable($edMat.VK.Rechnr);
  Lib_GuiCom:Disable($edMat.VK.Rechdatum);
  Lib_GuiCom:Disable($edMat.VK.Kundennr);
  Lib_GuiCom:Disable($edMat.EK.RechNr);
  Lib_GuiCom:Disable($edMat.EK.RechDatum);

  Refreshifm();
  
  // Focus setzen auf Feld:
  $edMat.Warengruppe->WinFocusSet(true);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vNr       : int;
end;
begin

  if (Mode=c_ModeEdit) and (Mat.MEH='') then
Mat.MEH             # 'kg';
//      Mat.MEH             # 't';

  // logische Prüfung
  if(Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() = false) then
    RETURN false;

  If (Mat.Warengruppe=0) then begin
    Msg(001200,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(819,200,1,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;

  If (Mat.MEH='') then begin
    Msg(001200,Translate('Mengeneinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Strukturnr->WinFocusSet(true);
    RETURN false;
  end;


  If ("Mat.Güte"='') then begin
    Msg(001200,Translate('Güte'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Guete->WinFocusSet(true);
    RETURN false;
  end;

  If (Mat.Lieferant=0) then begin
    Msg(001200,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.LieferStichwort->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(100,200,4,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.LieferStichwort->WinFocusSet(true);
    RETURN false;
  end;

  If (Mat.Lageradresse=0) then begin
    Msg(001200,Translate('Lagerort'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.LagerStichwort->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(101,200,6,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lagerort'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.LagerStichwort->WinFocusSet(true);
    RETURN false;
  end;

/*
  If (Mat.Dicke=0.0) then begin
    Msg(001200,Translate('Dicke'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Dicke->WinFocusSet(true);
    RETURN false;
  end;
*/

  If (Mat.Status=0) then begin
    Msg(001200,Translate('Status'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Status->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(820,200,9,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Status'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Status->WinFocusSet(true);
    RETURN false;
  end;

  if (Mode=c_ModeNew) then begin
    If (Mat.Bestand.Stk=0) then begin
      Msg(001200,Translate('Stückzahl'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edMat.Bestand.Stk->WinFocusSet(true);
      RETURN false;
    end;
    If (Mat.Bestand.Gew=0.0) then begin
      Msg(001200,Translate('Gewicht'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edMat.Bestand.Gew->WinFocusSet(true);
      RETURN false;
    end;
    If (Mat.Bestand.Menge=0.0) then begin
      Msg(001200,Translate('Menge'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edMat.Bestand->WinFocusSet(true);
      RETURN false;
    end;
    if (Mat.MEH<>'kg') then
      DivOrNull(Mat.EK.Preis, Mat.EK.preisProMEH * (Mat.Bestand.Menge + Mat.Bestellt.Menge), ((Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) ,2);
  end;

  if (Mat.Erzeuger<>0) then begin
    Erx # RecLink(100,200,3,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Erzeuger'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edMat.Erzeuger->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Mat.UrsprungsLand<>'') then begin
    Erx # RecLink(812,200,2,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Ursprungsland'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edMat.Ursprungsland->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Mat.Verwiegungsart<>0) then begin
    Erx # RecLink(818,200,10,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Verwiegungsart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page4';
      $edMat.Verwiegungsart->WinFocusSet(true);
      RETURN false;
    end;
  end;

  // 30.11.2017 AH:
  if (Mat.Gewicht.Brutto<>0.0) and (Mat.Gewicht.Netto<>0.0) then begin
    if (Mat.Gewicht.Netto > Mat.Gewicht.Brutto) then begin
      Msg(001206,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page4';
      $edMat.Gewicht.Netto->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // Zusammenhänge prüfen
/*
  if ((Mat.EigenmaterialYN) and ("Mat.Übernahmedatum"=0.0.0)) or
    (Mat.EigenmaterialYN=n) and ("Mat.Übernahmedatum"<>0.0.0) then begin
    Msg(200000,'',0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $cbMat.EigenmaterialYN1->WinFocusSet(true);
    RETURN false;
  end;
*/
  if (mode=c_ModeNew) and ("Mat.Übernahmedatum">Mat.Eingangsdatum) then begin
    Msg(200001,'',0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $cbMat.EigenmaterialYN1->WinFocusSet(true);
    RETURN false;
  end;
  if ("Mat.Ausgangsdatum"<Mat.Eingangsdatum) and (Mat.Ausgangsdatum<>0.0.0) then begin
    Msg(200002,'',0,0,0);
    $NB.Main->wpcurrent # 'NB.Page2';
    $edMat.Eingangsdatum->WinFocusSet(true);
    RETURN false;
  end;
  if ("Mat.Löschmarker"<>'') and (Mat.Ausgangsdatum=0.0.0) and (Mat.eingangsdatum<>0.0.0) then begin
    Msg(200003,'',0,0,0);
    $NB.Main->wpcurrent # 'NB.Page2';
    $edMat.Ausgangsdatum->WinFocusSet(true);
    RETURN false;
  end;
  if ((Mat.Status=c_Status_VSB) or (Mat.Status=c_Status_VsbPuffer) or (Mat.Status=c_Status_VsbRahmen) or (Mat.Status=c_Status_VsbKonsiRahmen) or
    (Mat.Status=c_Status_VSBKonsi)) and (Mat.Kommission='') then begin
    Msg(200005,'',_WinIcoError,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.Status->WinFocusSet(true);
    RETURN false;
  end;

  // 13.03.2015:
  if (Mat.Strukturnr<>'') and (Mode=c_ModeNew) and (Mat.EK.Preis=0.0) then begin
    Erx # RecLink(819,200,1,0);                 // Warengruppe holen
    if (Erx<=_rLocked) then begin
      if (Wgr_Data:IstMix(Wgr.Dateinummer)) then begin
        Erx # RecLink(250,200,26,_RecFirst);    // Artikel holen
        if (Erx<=_rLocked) then begin
          Mat.Bewertung.Laut  # 'D';
          Mat_Data:SetAktuellenEKPreis(false);  // nach Druchschnitt bewerten
          Mat.Bewertung.Laut  # 'D';
        end;
      end;
    end;
  end;

  // Hier erweiterte Meldungen bei falschen Daten
  if (RunAFX('Mat.RecSave.Pre','')<0) then
    RETURN false;


  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    // Wurde Artikel verändert???
/*
    if (Protokollbuffer[200]->Mat.Strukturnr<>'') and (Mat.Strukturnr<>Protokollbuffer[200]->Mat.Strukturnr) then begin
      Erx # RecLink(819,ProtokollBuffer[200],1,_recfirst);   // ALTE Warengruppe holen
      if (Wgr.Dateinummer=c_Wgr_ArtMatMix) then begin
      end;
    end;
*/
    Erx # Mat_Data:Replace(_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    PtD_Main:Compare(gFile);
  end // Edit
  else begin

    vNr # Lib_Nummern:ReadNummer('Material');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;

    TRANSON;

    // Ausführungen kopieren
    WHILE (RecLink(201,200,11,_RecFirst)=_rOk) do begin
      RecRead(201,1,_recLock);
      Mat.AF.Nummer # vNr;
      Erx # RekReplace(201,_recUnlock,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN false;
      end;
    END;

    Mat.Nummer    # vNr;
    Mat.Ursprung  # vNr;
    Erx # Mat_Data:Insert(_RecUnlock,'MAN', Mat.Eingangsdatum, Mat.InventurDatum);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;
  end;  // Insert


  RunAFX('Mat.RecSave.Post','');


  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  // Ausführungen löschen
  if (Mode=c_ModeNew) then begin
    WHILE (RecLink(201,200,11,_RecFirst)<=_rLocked) do begin
      RekDelete(201,0,'MAN');
    END;
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel(
  opt aSilent : logic;
  opt aNullen : logic)
begin

  Mat_Subs:RecDel(aSilent, aNullen)

//gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect | _WinLstPosMiddle)
//  gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst);
//winsleep(1000);
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vFocus : alpha;
end
begin

  vFocus # aEvt:Obj->wpname;

  if (vFocus='jump') then begin

    case (aEvt:Obj->wpcustom) of
      'MainStart' : begin
        $edMat.Warengruppe->winfocusset(false);
      end;
      'vorMain' : begin
        $edMat.Warengruppe->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page4';
        $cbMat.QS.FehlerYN->winfocusset(false);
      end;
      'nachMain' : begin
        $edMat.Bemerkung2->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page2';
        $edMat.EK.Projektnr->winfocusset(false);
      end;


      'BewegungsdatenStart' : begin
        $edMat.EK.Projektnr->winfocusset(false);
      end;
      'vorBewegungsdaten' : begin
        $edMat.EK.Projektnr->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $edMat.Bemerkung2->winfocusset(false);
      end;
      'nachBewegungsdaten' : begin
        $edMat.Ursprungsland->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page3';
        $edMat.Mech.Sonstiges1->winfocusset(false);
      end;


      'AnalyseStart' : begin
        $edMat.Mech.Sonstiges1->winfocusset(false);
      end;
      'vorAnalyse' : begin
        $edMat.Mech.Sonstiges1->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page2';
        $edMat.Ursprungsland->winfocusset(false);
      end;
      'nachAnalyse' : begin
        $edMat.Chemie.Frei1.2->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page4';
        $edMat.Verwiegungsart->winfocusset(false);
      end;


      'SonstigesStart' : begin
        $edMat.Verwiegungsart->winfocusset(false);
      end;
      'vorSonstiges' : begin
        $edMat.Verwiegungsart->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page3';
        $edMat.Chemie.Frei1.2->winfocusset(false);
      end;
      'nachSonstiges' : begin
        $cbMat.QS.FehlerYN->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $edMat.Warengruppe->winfocusset(false);
      end;

    end;  // EO Case

    Refreshifm();
    RETURN true;
  end;

  $edMat.LieferStichwort->wpreadonly # true;
  $edMat.LagerStichwort->wpreadonly # true;
  $edMat.Lageradresse->wpreadonly # true;
  $edMat.Lageranschrift->wpreadonly # true;

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
  Erx : int;
end;
begin

  if (aEvt:obj->wpname='edMat.AF.Oben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','200|1');
  if (aEvt:obj->wpname='edMat.AF.Unten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','200|2');

  if (Mode=c_modenew) and (aEvt:Obj->wpname='edMat.Eingangsdatum') and ($edMat.Eingangsdatum->wpchanged) then begin
    Mat.Datum.Erzeugt # Mat.Eingangsdatum;
  end;

  // 2022-11-28 AH  vorher nur bei MODENEW
  if (aEvt:Obj->wpname='edMat.EK.Preis') and ($edMat.EK.Preis->wpchanged) then begin
//debugx(anum($edMat.EK.Preis->wpCaptionFloat,2)+' zu '+anum(Mat.EK.Preis,2)+' '+mat.Meh);
    if (Mat.MEH='kg') then begin
      Mat.EK.Preis        # $edMat.EK.Preis->wpCaptionFloat;
      Mat.EK.PreisProMEH  # Rnd(Mat.EK.Preis / 1000.0,2);
    end
    else if (Mat.MEH='t') then begin
      Mat.EK.Preis        # $edMat.EK.Preis->wpCaptionFloat;
      Mat.EK.PreisProMEH  # Mat.EK.Preis;
    end
    else begin
      Mat.EK.PreisProMEH  # $edMat.EK.Preis->wpCaptionFloat;
    end;
  end;

  if (aEvt:Obj->wpname='edMat.Status') then begin
    if (Mat.Kommission='') and ((Mat.Status=c_Status_VSB) or (Mat.Status=c_Status_VsbPuffer) or
      (Mat.Status=c_Status_VsbRahmen) or (Mat.Status=c_Status_VsbKonsiRahmen) or (Mat.Status=c_Status_VSBKonsi)) then begin
      Msg(200005,'',_WinIcoError,0,0);
      Mat.Status # 0;
      RETURN false;
    end;
  end;


  if ((aEvt:Obj->wpname='edMat.Verwiegungsart') and ($edMat.Verwiegungsart->wpchanged)) or
    (aEvt:Obj->wpname='edMat.Bestand.Gew') and ($edMat.Bestand.Gew->wpchanged) then begin
    Erx # RecLink(818,200,10,0);
    if (Erx<=_rLocked) then begin
      $Lb.Verwiegungsart->wpcaption # VwA.Bezeichnung.L1
      if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then begin
        if (VWa.NettoYN) then begin
          Mat.Gewicht.Netto # Mat.Bestand.Gew;
          $edMat.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
          Lib_GuiCom:Disable($edMat.Gewicht.Netto);
          Lib_GuiCom:Enable($edMat.Gewicht.Brutto);
          if (aFocusobject<>0) then
            if (aFocusObject->wpname='edMat.Gewicht.Netto') then
              $edMat.Gewicht.Brutto->winfocusset(false);
        end
        else if (VWa.BruttoYN) then begin
          Mat.Gewicht.Brutto # Mat.Bestand.Gew;
          $edMat.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
          Lib_GuiCom:Disable($edMat.Gewicht.Brutto);
          Lib_GuiCom:Enable($edMat.Gewicht.Netto);
          if (aFocusobject<>0) then
            if (aFocusObject->wpname='edMat.Gewicht.Brutto') then
              $edMat.Gewicht.Netto->winfocusset(false);
        end
        else begin
          Lib_GuiCom:Enable($edMat.Gewicht.Netto);
          Lib_GuiCom:Enable($edMat.Gewicht.Brutto);
          if (aFocusobject<>0) then
            if (aFocusObject->wpname='edMat.Gewicht.Brutto') then
              $edMat.Gewicht.Netto->winfocusset(false);
        end;
      end;
    end
    else begin
      Mat.Gewicht.Netto   # Mat.Bestand.Gew;
      Mat.Gewicht.Brutto  # Mat.Bestand.Gew;
      $edMat.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
      $edMat.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edMat.Gewicht.Netto);
      Lib_GuiCom:Disable($edMat.Gewicht.Brutto);
    end;
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
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

  if (aEvt:Obj->wpname='cbMat.StehendYN') and (Mat.StehendYN) then begin
    Mat.LiegendYN # n;
    $cbMat.LiegendYN->winupdate(_WinUpdFld2Obj);
  end;
  if (aEvt:Obj->wpname='cbMat.LiegendYN') and (Mat.LiegendYN) then begin
    Mat.StehendYN # n;
    $cbMat.StehendYN->winupdate(_WinUpdFld2Obj);
  end;

  case (aEvt:Obj->wpName) of
    'cbMat.EigenmaterialYN1' : begin
        if (Mat.EigenmaterialYN) and ("Mat.Übernahmedatum"=0.0.0) then begin
          "Mat.Übernahmedatum" # today;
          $edMat.Uebernahmedatum->winupdate();
          RefreshIfm(aEvt:Obj->wpname);
        end;
      end;
/*
    'cbMat.DickenTolYN'     : RefreshIfm(aEvt:Obj->wpname);
    'cbMat.BreitenTolYN'    : RefreshIfm(aEvt:Obj->wpname);
    'cbMat.LaengenTolYN'    : RefreshIfm(aEvt:Obj->wpname)
*/
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
  Erx       : int;
  vA        : alpha;
  vFilter   : int;
  vSelName  : alpha;
  vSel      : int;
  vQ        : alpha(4000);
  tErx      : int;
  vTmp      : int;
  vHdl      : int;
end;
begin

  case aBereich of

    'Bild' : begin
      Mat.Bilddatei # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, Mat.Bilddatei, 'Bilddateien|*.tif;*.pdf;*.bmp;*.jpg;*.gif');
      $edMat.Bilddatei->winupdate(_WinUpdFld2Obj);
      RefreshIfm('edMat.Bilddatei');
    end;


    'Kommission' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'KommissionMark' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommissionMark');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Analyse' : begin
      RecBufClear(230);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung',here+':AusAnalyse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Etikettentyp' : begin
      RecBufClear(840);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettentyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Intrastat' : begin
      if (Msg(220001,'',0,_WinDialogYesNo,1)=_WinIdYes) then begin

        //vSelName # Sel_Build(vSel, 220, 'INTRASTAT_MATERIAL',y,0);
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

        // Selektion
        vQ # '';
        Lib_Sel:QAlpha(var vQ, 'MSL.Strukturtyp', '=', 'INTRA');
        Lib_Sel:QAlpha(var vQ, 'MSL.Intrastatnr', '>', '');
        Lib_Sel:QInt(var vQ, 'MSL.von.Warengruppe', '<=', Mat.Warengruppe);
        Lib_Sel:QInt(var vQ, 'MSL.bis.Warengruppe', '>=', Mat.Warengruppe);
        vQ # vQ + ' AND (MSL.bis.Status = 0 OR Mat.Status = 0 OR (MSL.von.Status <= Mat.Status AND MSL.bis.Status >= Mat.Status)) ';
        vQ # vQ + ' AND ("MSL.Güte" = "Mat.Güte" OR "MSL.Güte" = '''' OR "Mat.Güte" = '''') ';
        vQ # vQ + ' AND ("MSL.Gütenstufe" = "Mat.Gütenstufe" OR "MSL.Gütenstufe" = '''' OR "Mat.Gütenstufe" = '''') ';
        vQ # vQ + ' AND (Mat.Dicke = 0.0 OR (MSL.von.Dicke <= Mat.Dicke AND MSL.bis.Dicke >= Mat.Dicke)) ';
        vQ # vQ + ' AND (Mat.Breite = 0.0 OR (MSL.von.Breite <= Mat.Breite AND MSL.bis.Breite >= Mat.Breite)) ';
        vQ # vQ + ' AND ("Mat.Länge" = 0.0 OR ("MSL.von.Länge" <= "Mat.Länge" AND "MSL.bis.Länge" >= "Mat.Länge")) ';

        vSel # SelCreate(220, gKey);
        tErx # vSel->SelDefQuery('', vQ);
        if (tErx != 0) then Lib_Sel:QError(vSel);
        vSelName # Lib_Sel:SaveRun(var vSel, 0);

        gZLList->wpDbSelection # vSel;
        w_SelName # vSelName;
      end
      else begin
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Struktur' : begin
      Erx # RecLink(819,200,1,0);   // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);
      if (Wgr_Data:IstMix()) then begin
        RecBufClear(250);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else begin
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusStruktur');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


   'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '=', 200);
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '=', 209, 'OR');
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Status'         : begin
      RecBufClear(820);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mst.Verwaltung',here+':AusStatus');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete'          : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "Mat.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guetenstufe'          : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VWa.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zwischenlage' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusZwischenlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=2';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Unterlage' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUnterlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=1';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Umverpackung' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUmverpackung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=3';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zeugnis' : begin
      RecBufClear(839);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zeu.Verwaltung',here+':AusZeugnis');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Erzeuger'       : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Ursprungsland'  : begin
      RecBufClear(812);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lnd.Verwaltung',here+':AusUrsprungsland');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant'      : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageradresse'   : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLageradresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      RecLink(100,200,5,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLageranschrift');

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


    'Lagerplatz'   : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Oben'        : begin
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(201,200,11,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Unten'       : begin
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(201,200,11,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end;
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
      gZLlist->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LieferStichwort' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferStichwort');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LagerStichwort' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLagerStichwort');
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

    RecBufClear(201);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFOben');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(201,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
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

    RecBufClear(201);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFUnten');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(201,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
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
//  AusKommission
//
//========================================================================
sub AusKommission()
local begin
  Erx   : int;
  vX    : int;
  vTmp  : int;
  vA    : alpha(1000);
end;
begin

  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    RecLink(400,401,3,_recFirst);   // Kopf holen
    if ("Auf.P.Löschmarker"='*') or
      (Auf.Vorgangstyp<>c_AUF) or
      ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false)) then begin
      Msg(200400,'',0,0,0);
      RETURN;
    end;


    // ST 2017-08-08: Prüfung auf Passenden Auftrag
    Erx # Auf_Data:PasstAuf2Mat(0,false,true);
    if (erx<0) then RETURN;
    if (Erx=0) then begin
      if (Rechte[Rgt_Auf_MATZ_Konf_Abm]) then
        vA # aint(Mat.Nummer);
      else begin
        Msg(401016,aint(Mat.Nummer),_WinIcoError,_WinDialogOk,1);
        RETURN;
      end;
    end;
    if (vA<>'') then begin
      if (Msg(401015,vA,_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then
        RETURN;
    end;


    // Reservierung prüfen
    if (RecLinkInfo(203,200,13,_recCount)>1) then begin
      Msg(200009,'',0,0,0);
      RETURN;
    end;
    if (RecLinkInfo(203,200,13,_recCount)=1) then begin
      Erx # RecLink(203,200,13,_recFirst);     // Reservierung holen

      // LFA???
      if ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
        BAG.IO.Nummer   # "Mat.R.TrägerNummer1";
        BAG.IO.ID       # "Mat.R.TrägerNummer2";
        Erx # RecRead(701,1,0);
        if (Erx<=_rLocked) and (BAG.IO.NachPosition<>0) then begin
          Erx # RecLink(702,701,4,_recFirst);   // Nach-Position holen
          if (Erx<=_rLocked) then begin         // ist das KEIN Umlagern???
            if (BAG.P.Aktion<>c_BAG_Fahr) or (BAG.P.ZielVerkaufYN) then begin
              Msg(200009,'',0,0,0);
              RETURN;
            end;
          end;
        end;
      end
      else begin
        if (Mat.R.Auftragsnr<>Auf.P.Nummer) or (Mat.R.Auftragspos<>Auf.P.Position) then begin
          Msg(200009,'',0,0,0);
          RETURN;
        end;
      end;
    end;

    vX # Mat_data:SetKommission(Mat.Nummer, Auf.P.Nummer, Auf.P.Position,0, 'MAN');
    if (vX=0) then begin
      // AFX
      RunAFX('Mat.SetKommission','');
      Msg(200401,'',0,0,0);
    end
    else begin
      Msg(200402,AInt(vX),0,0,0);
      ErrorOutput;      // ST 2017-12-18
    end;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
    if (Mode=c_modeView) then begin
      Refreshifm();
      gMdi->winupdate();
    end;

  end;
end;


//========================================================================
//  AusKommissionMark
//
//========================================================================
sub AusKommissionMark()
local begin
  Erx         : int;
  vX          : int;
  vTmp        : int;
  vBuf200     : int;
  vMarked     : int;
  vMFile      : int;
  vMID        : int;
end;
begin

  if (gSelected=0) then RETURN;

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;

  RecLink(400,401,3,_recFirst);   // Kopf holen
  if ("Auf.P.Löschmarker"='*') or
    (Auf.Vorgangstyp<>c_AUF) or
    ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false)) then begin
    Msg(200400,'',0,0,0);
    RETURN;
  end;


  vBuf200 # RekSave(200);

//  TRANSON;

  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN
    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
    if (vMFile=200) then begin
      Erx # RecRead(200, 0, _recId, vMID);

      // Reservierung prüfen
      if (RecLinkInfo(203,200,13,_recCount)>1) then begin
//        TRANSBRK;
        RekRestore(vBuf200);
        Msg(200009,'',0,0,0);
        RETURN;
      end;
      if (RecLinkInfo(203,200,13,_recCount)=1) then begin
        Erx # RecLink(203,200,13,_recFirst);     // Reservierung holen
        if (Mat.R.Auftragsnr<>Auf.P.Nummer) or (Mat.R.Auftragspos<>Auf.P.Position) then begin
//          TRANSBRK;
          RekRestore(vBuf200);
          Msg(200009,'',0,0,0);
          RETURN;
        end;
      end;


      vX # Mat_data:SetKommission(Mat.Nummer, Auf.P.Nummer, Auf.P.Position,0, 'MAN');
      if (vX=0) then begin
        // AFX
        RunAFX('Mat.SetKommission','');
      end
      else begin
//        TRANSBRK;
        RekRestore(vBuf200);
        Msg(200402,AInt(vX),0,0,0);
        ErrorOutput;      // ST 2017-12-18
        RETURN;
      end;
    end;

  END;

//  TRANSOFF;
  RekRestore(vBuf200);

  Msg(200401,'',0,0,0);

  vTmp # WinFocusget();   // LastFocus-Feld refreshen
  if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
  if (Mode=c_modeView) then begin
    Refreshifm();
    gMdi->winupdate();
  end;

end;


//========================================================================
//  AusZeugnis
//
//========================================================================
sub AusZeugnis()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(839,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Zeugnisart # Zeu.Bezeichnung;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus auf Editfeld setzen:
  $edMat.Zeugnisart->Winfocusset(true);
end;


//========================================================================
//  AusInfo
//
//========================================================================
sub AusInfo()
begin
  gSelected # 0;
  // Focus auf Editfeld setzen:
  if (Mode=c_ModeList) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
  end
  else begin
    RecRead(200,1,0);
    Refreshifm();
  end;
  // ggf. Labels refreshen
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
    Mat.Intrastatnr # MSL.Intrastatnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Intrastatnr->Winfocusset(false);
end;


//========================================================================
//  AusStruktur
//
//========================================================================
sub AusStruktur()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Strukturnr # MSL.Strukturnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then
      vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Strukturnr->Winfocusset(false);
end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Strukturnr # Art.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  RefreshIfm('edMat.Strukturnr', y);
  // Focus setzen:
  $edMat.Strukturnr->Winfocusset(false);
end;


//========================================================================
//  AusAktion
//
//========================================================================
sub AusAktion()
local begin
  vTmp  : int;
end;
begin
  if (Mode=c_ModeView) then begin
    RecRead(200,1,0);
    RefreshIfm();
  end;
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Warengruppe # Wgr.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Warengruppe->Winfocusset(false);
  RefreshIfm('edMat.Warengruppe');
end;


//========================================================================
//  AusStatus
//
//========================================================================
sub AusStatus()
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    Erx # RecRead(820,0,_RecId,gSelected);


    // Feldübernahme
    Mat.Status # Mat.Sta.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen



    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Status->Winfocusset(false);
  RefreshIfm('edMat.Status');
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Mat.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Mat.Güte" # "MQu.Güte1"
    else
      "Mat.Güte" # "MQu.Güte2";
    Mat.Werkstoffnr # MQu.Werkstoffnr;
    Mat.Dichte      # Wgr_Data:GetDichte(Wgr.Nummer, 200);
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Guete->Winfocusset(false);
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Mat.Gütenstufe" # MQu.S.Stufe;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edMat.Guetenstufe->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
local begin
  vTmp  : int;
end;
begin
  gSelected # 0;

  "Mat.AusführungOben" # Obf_Data:BildeAFString(200,'1');

  // Focus auf Editfeld setzen:
  $edMat.AF.Oben->Winfocusset(true);

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
end;
begin
  gSelected # 0;

  "Mat.AusführungUnten" # Obf_Data:BildeAFString(200,'2');

  // Focus auf Editfeld setzen:
  $edMat.AF.Unten->Winfocusset(true);

  vTmp # WinFocusget();   // LastFocus-Feld refreshen
  if (vTmp <> 0) then
    vTmp->Winupdate(_WinUpdFld2Obj);

end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub AusErzeuger()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Erzeuger # Adr.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Erzeuger->Winfocusset(false);
  RefreshIfm('edMat.Erzeuger');
end;


//========================================================================
//  AusUrsprungsland
//
//========================================================================
sub AusUrsprungsland()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Ursprungsland # "Lnd.Kürzel";
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Ursprungsland->Winfocusset(false);
  RefreshIfm('edMat.Ursprungsland');
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lieferant # Adr.Lieferantennr;
    Mat.LieferStichwort # Adr.Stichwort;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Lieferant->Winfocusset(false);
  RefreshIfm('edMat.Lieferant');
end;


//========================================================================
//  AusLieferStichwort
//
//========================================================================
sub AusLieferStichwort()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lieferant # Adr.Lieferantennr;
    Mat.LieferStichwort # Adr.Stichwort;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.LieferStichwort->Winfocusset(false);
  RefreshIfm('edMat.LieferStichwort');
end;


//========================================================================
//  AusLageradresse
//
//========================================================================
sub AusLageradresse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Mat.Lageradresse # Adr.Nummer;
    Mat.LagerStichwort # Adr.Stichwort;
    Mat.Lageranschrift # 1;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Lageradresse->Winfocusset(false);
  RefreshIfm('edMat.Lageradresse');
end;


//========================================================================
//  AusLageranschrift
//
//========================================================================
sub AusLageranschrift()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lageradresse # Adr.A.Adressnr;
    Mat.Lageranschrift # Adr.A.Nummer;
    Mat.LagerStichwort # Adr.A.Stichwort;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Lageranschrift->Winfocusset(false);
  RefreshIfm('edMat.Lageranschrift');
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lagerplatz # Lpl.Lagerplatz;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Lagerplatz->Winfocusset(false);
  RefreshIfm('edMat.Lagerplatz');
end;


//========================================================================
//  AusLagerStichwort
//
//========================================================================
sub AusLagerStichwort()
local begin
  Erx   : int;
  vTmp  : int;
  vQ    : alpha;
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lageradresse   # Adr.Nummer;
    Mat.LagerStichwort # Adr.Stichwort;
    Mat.Lageranschrift # 1;

    //Mat.Lageradresse   # Adr.A.Adressnr;
    //Mat.Lageranschrift # Adr.A.Anschriftnr;
    //Mat.LagerStichwort # Adr.A.Stichwort;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

    // Focus setzen:

    $edMat.LagerStichwort->Winfocusset(false);
    RefreshIfm('edMat.LagerStichwort');

    vTmp # RecLinkInfo(101,100,12,_recCount); // Mehr als eine Anschrift vorhanden?
    if (vTmp > 1) then begin
      // Event für Anschriftsauswahl starten
//    $edMat.LagerStichwort->wpcustom # 'next';
//      gTimer2 # SysTimerCreate(500,1,gMdi);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLagerStichwort2');

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
      RETURN;

    end
    else begin
      Erx # RecLink(101,100,12,_recFirst); // Wenn nur 1, diese holen
      if(Erx > _rLocked) then RecBufClear(101);
      Mat.Lageradresse   # Adr.A.Adressnr;
      Mat.Lageranschrift # Adr.A.Nummer;
      Mat.LagerStichwort # Adr.A.Stichwort;
      $edMat.Lageradresse->Winupdate(_WinUpdFld2Obj);
      $edMat.Lageranschrift->Winupdate(_WinUpdFld2Obj);
      //RefreshIfm('edMat.LagerStichwort');
    end;
  end;
end;


//========================================================================
//  AusLagerStichwort2
//
//========================================================================
sub AusLagerStichwort2()
local begin
  vParent : int;
  vA      : alpha;
  vMode   : alpha;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lageradresse   # Adr.A.Adressnr;
    Mat.Lageranschrift # Adr.A.Nummer;
    Mat.LagerStichwort # Adr.A.Stichwort;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $edMat.Lageradresse->Winupdate(_WinUpdFld2Obj);
    $edMat.Lageranschrift->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.LagerStichwort->Winfocusset(false);
  RefreshIfm('edMat.LagerStichwort');
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Verwiegungsart # VwA.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus setzen:
  $edMat.Verwiegungsart->Winfocusset(false);
  RefreshIfm('edMat.Verwiegungsart');
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
    Mat.Etikettentyp # Eti.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus setzen:
  $edMat.Etikettentyp->Winfocusset(false);
  RefreshIfm('edMat.Etikettentyp');
end;


//========================================================================
//  AusZwischenlage
//
//========================================================================
sub AusZwischenlage()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Zwischenlage # ULa.Bezeichnung;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edMat.Zwischenlage->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUnterlage
//
//========================================================================
sub AusUnterlage()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Unterlage # ULa.Bezeichnung;
    "Mat.StapelhöhenAbzug" # "ULa.Höhenabzug";
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $edMat.StapelhoehenAbzug->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edMat.Unterlage->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUmverpackung
//
//========================================================================
sub AusUmverpackung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Umverpackung # ULa.Bezeichnung;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edMat.Umverpackung->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusAnalyse
//
//========================================================================
sub AusAnalyse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(230,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Mat.Analysenummer # Lys.K.Analysenr;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edMat.Analysenr->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx         : int;
  d_MenuItem  : int;
  vHdl        : int;
  vA          : Alpha;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // MatSofortInAblage
  if (Set.Mat.Del.SofortYN) then begin
    gTMP # Winsearch(gMenu, 'Mnu.Filter.Geloescht');
    if (gTMP<>0) then begin
      gTMP->WinMenuItemRemove();
      gTMP # Winsearch(gMenu, 'Filter.seperator');
      if (gTMP<>0) then gTMP->WinMenuItemRemove();
    end;
  end;

  if ((Mat.Kommission<>'') and (Mat.Status<>750)) then begin
    Lib_GuiCom:Disable($bt.Reserviert);
    end
  else begin
    Lib_GuiCom:Enable($bt.Reserviert);
  end;

//  $bt.Reserviert->wpdisabled # (Mode<>c_ModeView);
  $NB.Bild->wpDisabled # (Mode = c_ModeNew);


  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMenu->WinSearch('Mnu.Bestand');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      ((Mat.Status>c_Status_BisFrei) and (Mat.Status<>c_status_VSB) and (Mat.Status<>c_status_VSBKonsiRahmen) and
                      (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen)) or
                      (Rechte[Rgt_Mat_Best_Aendern]=n) ;

  vHdl # gMenu->WinSearch('Mnu.NeuBewerten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      ((Rechte[Rgt_Mat_NeuBewerten]=n));

  vHdl # gMenu->WinSearch('Mnu.Splitten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Mat_Splitten]=n);

  vHdl # gMenu->WinSearch('Mnu.Kommission');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Mat_Kommission]=n);

  vHdl # gMenu->WinSearch('Mnu.Kombi');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Mat_Kombinieren]=n);

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Mat_Anlegen]=n);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then begin
    RecLink(820,200,9,0);
    vHdl->wpDisabled # ((mode<>c_modeList) and (mode<>c_modeView)) OR (Rechte[Rgt_Mat_Aendern]=n) or (Mat.Sta.GesperrtYN = y);
  end;
  vHdl # gMenu->WinSearch('Mnu.Edit');

  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((mode<>c_modeList) and (mode<>c_modeView)) OR (Rechte[Rgt_Mat_Aendern]=n) or (Mat.Sta.GesperrtYN = y);
  end;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Restore');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Abl_Mat_Restore]=n) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Status'); // TM
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      ((Rechte[Rgt_Materialstatus]=n));


  Erx # RecLink(819,200,1,0); // Warengruppe holen
  vHdl # gMenu->WinSearch('Mnu.Disposition');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_modeView) and (mode<>c_modeList)) or
      (Wgr_Data:IstMix()=false);

  vHdl # gMenu->WinSearch('Mnu.Bestellung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mat.Einkaufsnr=0) or
                      ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      ((Rechte[Rgt_Mnu_Einkauf]=n));

  vHdl # gMenu->WinSearch('Mnu.Versandpool');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                       ((Mat.Status>c_status_bisfrei) and (Mat.Status<>c_Status_VSB) and
                       (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen) and (Mat.Status<>c_Status_VsbKonsiRahmen)) or
                       ("Mat.Löschmarker"<>'') or (Mat.Eingangsdatum=0.0.0) or
                      (Rechte[Rgt_Mat_Versandpool]=n);

  vHdl # gMenu->WinSearch('Mnu.BAG.Saegen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                       ((Mat.Status>c_status_bisfrei) and (Mat.Status<>c_Status_VSB) and
                       (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen) and (Mat.Status<>c_Status_VsbKonsiRahmen)) or
                       ("Mat.Löschmarker"<>'')/* or (Mat.Eingangsdatum=0.0.0)*/ or
                       (Mat.EigenmaterialYN=false) or
                      (Rechte[Rgt_BAG_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.BAG.Tafel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                       ((Mat.Status>c_status_bisfrei) and (Mat.Status<>c_Status_VSB) and
                       (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen) and (Mat.Status<>c_Status_VsbKonsiRahmen)) or
                       ("Mat.Löschmarker"<>'')/* or (Mat.Eingangsdatum=0.0.0)*/ or
                       (Mat.EigenmaterialYN=false) or
                      (Rechte[Rgt_BAG_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Create.Auftrag');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                       ((Mat.Status>c_status_bisfrei) and (Mat.Status<>c_Status_VSB) and
                        (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen) and (Mat.Status<>c_Status_VsbKonsiRahmen)) or
                       ("Mat.Löschmarker"<>'')/* or (Mat.Eingangsdatum=0.0.0)*/ or
                       (Mat.EigenmaterialYN) or
                      (Rechte[Rgt_Auf_P_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Mat_Excel_Export]=false;

  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Mat_Excel_Import]=false;

  vHdl # gMenu->WinSearch('Mnu.Inv.ToggleFlag');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Mat.Löschmarker"<>'') or (Rechte[Rgt_Mat_ToggleInvFlag]=false);

/****
  if (gZLList->wpdbselection<>0) then begin
    if (StrFind(w_selName,'.SEL',0)<>0) then vA # 'SEL'
    else if (StrFind(w_selName,'.MARK',0)<>0) then vA # 'MARK';
  end;

  vHdl # gMenu->WinSearch('Mnu.Filter.Stop');
  if (vHdl<> 0) then vHdl->wpDisabled # (vA='MARK');
  vHdl # gMenu->WinSearch('Mnu.Filter.Start');
  if (vHdl<> 0) then vHdl->wpMenucheck # (vA='SEL');
  if (vHdl<> 0) then vHdl->wpDisabled # (vA='MARK');
  vHdl # gMenu->WinSearch('Mnu.Mark.Filter');
  if (vHdl<> 0) then vHdl->wpDisabled # (vA='SEL');
***/

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
  Erx         : int;
  vHdl        : int;
  vSel        : alpha;
  vI,vJ       : int;
  vX,vY       : float;
  vStk        : int;
  vGew        : float;
  vA          : alpha;
  vBAG        : int;
  vBuf200     : int;
  vBildName   : alpha(1000);
  vTextName   : alpha(1000);
  vDateBegin  : date;
  vDateEnd    : date;
  vMarked     : int;
  vMFile      : int;
  vMID        : int;
  vOK         : logic;
  vTmp        : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.AlsKurzinfo' :
      Lib_Workbench:OpenKurzInfo(200, RecInfo(200,_recID));

    'Mnu.Inv.ToggleFlag' : begin  // 17.08.2017 AH
      if (("Mat.Löschmarker"<>'') or (Rechte[Rgt_Mat_ToggleInvFlag]=false)) THEN RETURN true;
      RecRead(200,1,_recLock);
      Mat.Inventur.DruckYN # !Mat.Inventur.DruckYN;
      RekReplace(200);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
      if (Mode=c_modeView) then begin
        Refreshifm();
        gMdi->winupdate();
      end;
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Filter.Paket' : begin
      Mat_Subs:SelPaket();
    end;

    
    'Mnu.Filter.Start' : begin
/**
      Gv.alpha.01 # '';
      Lib_Sel:QInt( var GV.alpha.01, 'Mat.Nummer', '>', 3222);
      Lib_Sel:QRecList(0,GV.alpha.01,'.SEL');
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      App_Main:Refreshmode();
***/
      Mat_Mark_Sel(false, '200.xml');
      RETURN true;
    end;


    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edMat.Bestand.Stk') then begin
        Erx # RecLink(819,200,1,0); // Warengruppe holen
        Mat.Bestand.Stk # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Mat.Bestand.Gew, Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, "Mat.Güte", Mat.Strukturnr);
        $edMat.Bestand.Stk->winupdate(_WinUpdFld2Obj);
        "Mat.Verfügbar.Stk" # Mat.Bestand.Stk + Mat.Bestellt.Stk - Mat.Reserviert.Stk;
        $lb.VerfuegbarStk->wpcaption # Aint("Mat.Verfügbar.Stk");
      end;
      if (aEvt:Obj->wpname='edMat.Bestand') then begin
        Erx # RecLink(819,200,1,0); // Warengruppe holen
        Mat.Bestand.Menge # Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, 0.0, '', Mat.MEH);
        $edMat.Bestand->winupdate(_WinUpdFld2Obj);
        "Mat.Verfügbar.Menge" # Mat.Bestand.Menge + Mat.Bestellt.Menge - Mat.Reserviert.Menge;
        $lb.Verfuegbar->wpcaption # ANum("Mat.Verfügbar.Menge",Set.Stellen.Menge);
      end;
      if (aEvt:Obj->wpname='edMat.Bestand.Gew') then begin
        Erx # RecLink(819,200,1,0); // Warengruppe holen
        Mat.Bestand.Gew # Lib_Berechnungen:KG_aus_StkDBLWgrArt(Mat.Bestand.Stk, Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, "Mat.Güte", Mat.Strukturnr);
        $edMat.Bestand.Gew->winupdate(_WinUpdFld2Obj);
        "Mat.Verfügbar.Gew" # Mat.Bestand.Gew + Mat.Bestellt.Gew - Mat.Reserviert.Gew;
        $lb.VerfuegbarGew->wpcaption # ANum("Mat.Verfügbar.Gew",Set.Stellen.Gewicht);
      end;
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(200);
    end;


    'Mnu.Auftrag' : begin
      if (Mat.Auftragsnr = 0) or (Rechte[Rgt_Mnu_Auftrag]=n) then RETURN true;
      Erx # RecLink(401, 200, 16, _recFirst);  // Bestellung holen
      if (Erx <= _rLocked) then begin
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung', '', true);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Mnu.Bestellung' : begin
      if (Mat.Einkaufsnr = 0) or (Rechte[Rgt_Mnu_Einkauf]=n) then RETURN true;

      Erx # RecLink(501,200,18,_recFirst);  // Bestellung holen
      if (Erx<=_rLocked) then begin
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung','',y);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Mnu.BAG.Graph' : begin

      // bin ich selber Einsatz???
      Erx # RecLink(701,200,29,_recFirst);    // BA-Input loopen
      WHILE (Erx<=_rLocked) and (vBAG=0) do begin
        if (BAG.IO.vonBAG=0) and (BAG.IO.Materialtyp=c_IO_Mat) then begin
          vBAG # BAG.IO.Nummer;
          BREAK;
        end;
        Erx # RecLink(701,200,29,_recNext);
      END;

      // Vorgänger ansehen...
      if (vBAG=0) and ("Mat.Vorgänger"<>0) then begin
        vBuf200 # RecBufCreate(200);
        vBuf200->Mat.Nummer # "Mat.Vorgänger";
        if (RecRead(vBuf200,1,0)<=_rLocked) then begin
          Erx # RecLink(204,vBuf200,14,_recFirst);  // Aktionen loopen
          WHILE (Erx<=_rLocked) and (vBAG=0) do begin
            // bin Rest...
            if (Mat.A.Aktionstyp=c_Akt_BA_Rest) and (Mat.A.Entstanden=Mat.Nummer) then vBAG # Mat.A.Aktionsnr;
            // bin FM
            if (Mat.A.Aktionstyp=c_Akt_BA_Fertig) and (Mat.A.Entstanden=Mat.Nummer) then vBAG # Mat.A.Aktionsnr;
            Erx # RecLink(204,vBuf200,14,_recNext);
          END;
        end;
        RecBufDestroy(vBuf200);
      end;

      if (vBAG<>0) then begin
        BAG.Nummer # vBAG;
        Erx # Recread(700,1,0);   // BAG holen
        if (Erx<=_rLocked) then begin
          FsiPathCreate(_Sys->spPathTemp+'StahlControl');
          FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
          vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
          vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';
          // Graphtext erzeugen
          BA1_Graph:BuildText(vTextName);
          // Graph erstellen
          SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
          // externes Bild anzeigen
          Dlg_Bild('*'+vBildName);
        end;
      end;
    end;


    'Mnu.DMS' : begin
      //DMS_ArcFlow:ShowAbm('MAT',Mat.Nummer,0);
      DMS_ArcFlow:SearchDok(Mat.Chargennummer, Mat.Bestelldatum, today);
    end;


    'Mnu.Restore' : begin
      Mat_Abl_Data:RestoreAusAblage();
      RecRead(200,1,0);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Disposition' : begin
      Erx # RecLink(250,200,26,_RecFirst); // Artikel holen
      // Sonderfunktion:
      if (RunAFX('Art.Dispoliste','250_401_-RES_409_501_701')<>0) then begin
        RETURN true;
      end;
// 2022-11-03 AH ALT      Art_Disposition2:Show('Dispoliste','250_401_-RES_409_501_701',y,n);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung',here+':AusInfo',y,n);
      Art_Disposition2:Show('Dispoliste','250_401-Res_-RES_409_501_701',y,n, gMDI);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Vererben' : begin
      // NUR Analyse vererben
      if (Mat_Data:VererbeDaten(n,y)) then Msg(999998,'',0,0,0);
    end;


    'Mnu.Vererben2' : begin
      if (Mat_Data:VererbeDaten(n,n,y)) then Msg(999998,'',0,0,0);
    end;


    'Mnu.Bestand' : begin
      if ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      ((Mat.Status>c_Status_BisFrei) and (Mat.Status<>c_status_VSB) and
                      (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen) and (Mat.Status<>c_Status_VsbKonsiRahmen)) or
                      (Rechte[Rgt_Mat_Best_Aendern]=n) then RETURN true;

      Ein.P.Materialnr # Mat.Nummer;
      Erx # RecRead(501,8,_rectest);
      if (Erx>_rMultikey) then begin
        Ein.E.Materialnr # Mat.Nummer;
        Erx # RecRead(506,2,_rectest);
      end;
      if (Erx<=_rMultikey) then begin
        Msg(200004,'',_WinIcoWarning,0,0);
      end;

      Mat_B_Main:Bestandsaenderung();
      App_Main:Refresh();   // 19.10.2020 AH
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
      if (Mode=c_ModeView) then begin
        gMDI->Winupdate();
        Refreshifm();
      end;

      RETURN true;
    end;


    'Mnu.Analyse2Mat' : begin
      if (Rechte[Rgt_Mat_Aendern]) and (Mat.Analysenummer<>0) then begin
        Mat_Data:CopyAnalyse2Mat();
        gMdi->winupdate();
      end;
      RETURN true;
    end;


    'Mnu.Werkszeugnis' : begin
      if (Rechte[Rgt_Mat_Druck_WZ]) then begin
        Mat_Subs:Werkszeugnis();
      end;
      RETURN true;
    end;


    'Mnu.Stammbaum' : begin
      Mat_Stammbaum:Stammbaum();
      RETURN true;
    end;


    'Mnu.Entstehung' : begin
      Mat_Entstehung:Entstehung(Mat.Nummer);
      gMenuName # cMenuName;
      RETURN true;
    end;


    'Mnu.Etikett' : begin

      vI # Lib_Mark:Count(200);
      if (vI>0) then begin
        if (Msg(997007,aint(vI),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
          Mat_Etikett:Etikett(0,n,1,y);
          RETURN true;
        end;
      end;

      Mat_Etikett:Etikett();
      RETURN true;
    end;


    'Mnu.Materialkarte' : begin
      Lib_Dokumente:Printform(200,'Materialkarte',true);
    End;


    'Mnu.Fehlerprotokoll' : begin
      Mat_Subs:Fehlerprotokoll();
      RETURN true;
    end;


    'Mnu.Kommission' : begin
      if (Rechte[Rgt_Mat_Kommission]=false) then RETURN false;

      vI # Lib_Mark:Count(200);
      if (vI>0) then begin
        vI # Msg(997007,aint(vI),_WinIcoQuestion,_WinDialogYesNoCancel,1);
        if (vI=_WinIdCancel) then RETURN true;
        if (vI=_WinIdNo) then vI # 0;
      end;

      // nur aktuelles Material ändern
      if (vI=0) then begin
        if ("Mat.Löschmarker"='*') then begin
          Msg(200006,'',0,0,0);
          RETURN true;
        end;

        if (Mat.Status>c_Status_BisFrei) and (Mat.Status<>c_Status_EKVSB) and (Mat.Kommission='') then begin
          Msg(200027,aint(Mat.Nummer),0,0,0);
          RETURN true;
        end
        else if (Mat.Status<>c_Status_VsbPuffer) and (Mat.Status<>c_Status_VsbRahmen) and (Mat.Status<>c_Status_VSB) and
          (Mat.Status<>c_Status_VSBKonsiRahmen) and (Mat.Status<>c_Status_VSBKonsi) and (Mat.Status<>c_Status_EKVSB) and (Mat.Kommission<>'') then begin
          Msg(200027,aint(Mat.Nummer),0,0,0);
          RETURN true;
        end;

        // neue Kommission setzen
        if (Mat.Kommission='') then begin

          if (RecLinkInfo(203,200,13,_recCount)>1) then begin
            Msg(200009,'',0,0,0);
            RETURN true;
          end;
          if (RecLinkInfo(203,200,13,_recCount)=1) then begin
            Erx # RecLink(203,200,13,_recFirst);     // Reservierung holen
            // LFA???
            if ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
              BAG.IO.Nummer   # "Mat.R.TrägerNummer1";
              BAG.IO.ID       # "Mat.R.TrägerNummer2";
              Erx # RecRead(701,1,0);
              if (Erx<=_rLocked) and (BAG.IO.NachPosition<>0) then begin
                Erx # RecLink(702,701,4,_recFirst);   // Nach-Position holen
                if (Erx<=_rLocked) then begin         // ist das KEIN Umlagern???
                  if (BAG.P.Aktion<>c_BAG_Fahr) or (BAG.P.ZielVerkaufYN) then begin
                    Msg(200009,'',0,0,0);
                    RETURN true;
                  end;
                end;
              end;
            end
            else begin
              Msg(200009,'',0,0,0);
              RETURN true;
            end;
          end;

          if (Msg(200008,'',0, _WinDialogYesNo,1)<>_WinIdYes) then RETURN true;

          Auswahl('Kommission');    // neue Kommission wählen...
          RETURN true;
        end;


        // bisherige Kommission entfernen
        if (Mat.Kommission<>'') then begin
          if (Msg(200007,'',0, _WinDialogYesNo,1)<>_WinIdYes) then RETURN true;

          vI # Mat_Data:SetKommission(Mat.Nummer, 0,0,0 ,'MAN');
          if (vI=0) then begin
            // AFX
            RunAFX('Mat.SetKommission','');
            Msg(200401,'',0,0,0);
          end
          else begin
            Msg(200402,AInt(vI),0,0,0);
            ErrorOutput;
          end;
        end;
      end
      // Markierte?
      else begin

        vBuf200 # RekSave(200);
        vOk # n;
        FOR vMarked # gMarkList->CteRead(_CteFirst);
        LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
        WHILE (vMarked > 0) DO BEGIN
          Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
          if (vMFile=200) then begin
            Erx # RecRead(200, 0, _recId, vMID);
            if ("Mat.Löschmarker"='*') then begin
              RekRestore(vBuf200);
              Msg(200006,'',0,0,0);
              RETURN true;
            end;

            if (Mat.Kommission='') then begin
              if (Mat.Reserviert.Gew>0.0) then begin
                RekRestore(vBuf200);
                Msg(200009,'',0,0,0);
                RETURN true;
              end;
            end
            else begin
              vOK # y;    // Kommission leeren
            end;
          end;
        END;

        RekRestore(vBuf200);

        // leeren
        if (vOK) then begin
          if (Msg(200023,'',0, _WinDialogYesNo,1)<>_WinIdYes) then RETURN true;

//          TRANSON;

          vBuf200 # RekSave(200);
          vOk # n;
          FOR vMarked # gMarkList->CteRead(_CteFirst);
          LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
          WHILE (vMarked > 0) DO BEGIN
            Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
            if (vMFile=200) then begin
              Erx # RecRead(200, 0, _recId, vMID);

              if (Mat.Kommission<>'') then begin
                vI # Mat_Data:SetKommission(Mat.Nummer, 0,0,0 ,'MAN');
                if (vI=0) then begin
                  // AFX
                  RunAFX('Mat.SetKommission','');
                end
                else begin
//                  TRANSBRK;
                  RekRestore(vBuf200);
                  Msg(200402,AInt(vI),0,0,0);
                  ErrorOutput;
                  RETURN false;
                end;
              end;
            end;
          END;

//          TRANSOFF;
          RekRestore(vBuf200);

          Msg(200401,'',0,0,0);
        end
        // setzen
        else begin
          Auswahl('KommissionMark');    // neue Kommission wählen...
        end;

      end;  // markierte


      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
      if (Mode=c_modeView) then begin
        Refreshifm();
        gMdi->winupdate();
      end;
      RETURN true;
    end;


    'Mnu.Status' : begin // TM
      If (Rechte[Rgt_Materialstatus]) then begin
        Erx # RecRead(200,1,_recLock);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mst.Verwaltung',here+':StatusSetzen');
        Lib_GuiCom:RunChildWindow(gMDI);
        $edMat.Status->Winupdate(_WinUpdFld2Obj);
      end;
    end;


    'Mnu.Filter.Geloescht' : begin
      ToggleDelFilter();
      RETURN true;
    end;


    'Mnu.Copy' : begin
      w_AppendNr # Mat.Nummer;
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Mnu.NeuBewerten' : begin
      Mat_Subs:NeuBewertung();
    end;


    'Mnu.Kombi' : begin
      Mat_Subs:Kombi(today, now);
    end;


    'Mnu.Versandpool' : begin
      Mat_Subs:Versand();
    end;


    'Mnu.BAG.Saegen' : begin
      BA1_Qck_Saegen_Main:Start(Mat.Nummer);
    end;


    'Mnu.BAG.Tafeln' : begin
      BA1_Qck_Tafeln_Main:Start(Mat.Nummer);
    end;


    'Mnu.Create.Auftrag' : begin
      if (gMdiAuf = 0) then begin
        gMdiAuf # Lib_GuiCom:OpenMdi(gFrmMain, 'Auf.P.Verwaltung', _WinAddHidden);

        VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
        w_Command # 'NimmMatFuerBA';
        Mode # c_modeBald + c_modeNew;
        w_cmd_para  # aint(RecInfo(200,_recID));
        gMdiAuf->WinUpdate(_WinUpdOn);
        $NB.Main->WinFocusSet(true);

      end
      else begin

        vHdl # VarInfo(Windowbonus);
        VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
        if (Mode=c_modeList) then begin
//          Lib_GuiCom:RePos(var gMDIauf, 'Auf.P.Verwaltung', RecInfo(401,_recId),n);
          Lib_guiCom:ReOpenMDI(gMDIAuf);

        VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
        w_Command # 'NimmMatFuerBA';
//        Mode # c_modeBald + c_modeNew;
        w_cmd_para  # aint(RecInfo(200,_recID));
        gMdiAuf->WinUpdate(_WinUpdOn);
        $NB.Main->WinFocusSet(true);
        App_Main:Action(c_ModeNew);
        end;
      end;


      RETURN true;
    end;


    'Mnu.Splitten' : begin
      Mat_Subs:Aufteilen();
    end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;


    'Mnu.Mark.Sel' : begin
      Mat_Mark_Sel(false);  // Aufruf für Selektionsmaske "ohne Abwertung"
    end;


    'Mnu.Mark.SelAbw' : begin
      Mat_Mark_Sel(true);  // Aufruf für Selektionsmaske "mit Abwertung"
    end;


    'Mnu.Aktion' : begin
      RecBufClear(204);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.A.Verwaltung',here+':AusAktion',y);
      Mat_A_Data:BuildFullAktionsliste();
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Mat.Reservierung' : begin
      RecBufClear(203);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Verwaltung',here+':AusInfo',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # 'MAT';
      gZLList->wpdbfileno     # 200;
      gZLList->wpdbkeyno      # 13;
      gZLList->wpdbLinkFileNo # 203;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Mat.Bestandsbuch' : begin
      RecBufClear(202);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.B.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Mat.Lagerprotokoll' : begin
      RecBufClear(205);
      Lib_GuiCom:AddChildWindow(gMDI,'Mat.O.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Mat.Anlage.Datum, Mat.Anlage.Zeit, Mat.Anlage.User, "Mat.Lösch.Datum", "Mat.Lösch.Zeit", "Mat.Lösch.User", "Mat.Lösch.Grund");
    end;

  end; // case

end;


//========================================================================
//  IsPageActive
//========================================================================
Sub IsPageActive(aName : alpha) : logic;
begin
  RETURN aName<>'NB.Page5';
end


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vName : alpha;
  vTmp  : int;
end;
begin

  if (aEvt:Obj->wpName='bt.Reserviert') and (Mode=c_modeView) then begin
    RecBufClear(203);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Verwaltung',here+':AusInfo',y);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # 'MAT';
    gZLList->wpdbfileno     # 200;
    gZLList->WPdbKeyNo      # 13;
    gZLList->wpdbLinkFileNo # 203;
    // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
    gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;


  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.Scan'           : begin
      $pic.Materialpic->wpcaption # '';
      $doc.Materialpic->wpfilename # '';
      vName # 'C:\mat_'+cnvai(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      Lib_Twain:Scan(vname+'.bmp',24,72.0);
      Winsleep(2000);
      $pic.Materialpic->wpcaption # '*'+vName+'.jpg';
      $doc.Materialpic->wpfilename # '*'+vName+'.jpg';
//      $pic.Materialpic->Winupdate();
    end;

    'bt.Zeugnisart'       :   Auswahl('Zeugnis');
    'bt.Bild'             :   Auswahl('Bild');
    'bt.Warengruppe'      :   Auswahl('Warengruppe');
    'bt.Status'           :   Auswahl('Status');
    'bt.Intrastat'        :   Auswahl('Intrastat');
    'bt.Struktur'         :   Auswahl('Struktur');
    'bt.Guete'            :   Auswahl('Guete');
    'bt.Guetenstufe'      :   Auswahl('Guetenstufe');
    'bt.Verwiegungsart'   :   Auswahl('Verwiegungsart');
    'bt.Unterlage'        :   Auswahl('Unterlage');
    'bt.Umverpackung'     :   Auswahl('Umverpackung');
    'bt.Zwischenlage'     :   Auswahl('Zwischenlage');
    'bt.Erzeuger'         :   Auswahl('Erzeuger');
    'bt.Ursprungsland'    :   Auswahl('Ursprungsland');
    'bt.Lieferant'        :   Auswahl('Lieferant');
    'bt.Lageradresse'     :   Auswahl('Lageradresse');
    'bt.Lageranschrift'   :   Auswahl('Lageranschrift');
    'bt.Lagerplatz'       :   Auswahl('Lagerplatz');
    'bt.AFOben'           :   Auswahl('AF.Oben');
    'bt.AFUnten'          :   Auswahl('AF.Unten');
    'bt.LieferStichwort'  :   Auswahl('LieferStichwort');
    'bt.LagerStichwort'   :   Auswahl('LagerStichwort');
    'bt.Analyse'          :   Auswahl('Analyse');
    'bt.Etikettentyp'     :   Auswahl('Etikettentyp');

    //'...' : begin // simuliere Menücommand
    //  EvtMenuCommand(null,aEvt:Obj);
    //end;

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
  if ("Mat.Löschmarker"='*') and (Filter_Mat) then RETURN false;
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
  Mat.AF.Bezeichnung # StrCut(Mat.AF.Bezeichnung + ':'+Mat.AF.Zusatz, 1, 32);
  RETURN Mat.AF.Seite='1';
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
  Mat.AF.Bezeichnung # StrCut(Mat.AF.Bezeichnung + ':'+Mat.AF.Zusatz, 1, 32);
  RETURN Mat.AF.Seite='2';
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
end;
begin

  Lib_GuiCom:ZLQuickJumpInfo($clmMat.Nummer);

  // Sonderfunktion:
 if (aMark) then begin
    if (RunAFX('Mat.EvtLstDataInit','y')<0) then RETURN;
  end
    else if (RunAFX('Mat.EvtLstDataInit','n')<0) then RETURN;
/***/
  if (aMark=n) then begin
    if ("Mat.Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else if (Lib_Cache:Read820(Mat.Status)=_rOK) and (Mat.Sta.Color<>0) and (Mat.Sta.Color<>_Wincolparent) then    // 2022-09-28 AH
      Lib_GuiCom:ZLColorLine(gZLList, Mat.Sta.Color)
    else if (Mat.Status>c_Status_bisEK) and (Mat.Status<c_Status_BAGOutput) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.inBAG);
    else if (Mat.Status>=c_Status_gesperrt) or (RecLinkInfo(401,200,22,_reccount)>0) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Gesperrt)
    else if (Mat.Status=c_Status_EKVSB) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.EKVSB)
    else if (Mat.Status>=c_Status_bestellt) and (Mat.Status<=c_Status_bisEK) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Bestellt)
    else if (Mat.Kommission<>'') then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Kommissi)
    else if (Mat.Reserviert.Gew > 0.0) and ("Mat.Verfügbar.Gew" <= 0.0) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Reserv);
    else if (Mat.Reserviert.Gew > 0.0) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.TeilRes)
    else if (Mat.EigenmaterialYN) then
          Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.frei)
        else
        Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.fremd);
  end;

  Erx # RecLink(100, 200, 3, _recFirst); // Erzeuger holen
  if(Erx > _rLocked) then
    RecBufClear(100);

  GV.Alpha.07 # '';
  if (Mat.BestellTermin<>0.0.0) then Gv.ALpha.07 # cnvad(Mat.BestellTermin);

  GV.Alpha.01 # Adr.Stichwort;

  GV.Num.01 # Mat.Bestand.Gew + Mat.Bestellt.Gew - Mat.Reserviert2.Gew;


  GV.Alpha.02 # anum(Mat.Bestand.Menge, Set.Stellen.Menge)+' '+Mat.MEH;
  GV.Alpha.03 # anum(Mat.Bestellt.Menge, Set.Stellen.Menge)+' '+Mat.MEH;
  GV.Alpha.04 # anum(Mat.Reserviert.Menge, Set.Stellen.Menge)+' '+Mat.MEH;
  GV.Alpha.05 # anum("Mat.Verfügbar.Menge", Set.Stellen.Menge)+' '+Mat.MEH;

  if (Mat.LfENr=-1) then
    Gv.Alpha.06 # Translate('fehlt')
  else if (Mat.LfENr>0) then
    Gv.Alpha.06 # aint(Mat.LfeNr)
  else
    Gv.Alpha.06 # Translate('ohne');

end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  Erx   : int;
  vA    : alpha(200);
end;
begin

  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);   // falls Menüs gesetzte werden sollen

  // Ankerfunktion:
  if (RunAFX('Mat.EvtLstSelect','')<0) then RETURN true;


  if ("Mat.Löschmarker"='*') then
    vA # Translate('gelöscht')
  else if (Mat.Status=c_Status_bestellt) then
    va # Translate('bestellt')
  else if (Mat.Status=c_Status_EKVSB) then
    vA # Translate('VSB-Einkauf')
  else if (Mat.Kommission<>'') then
    vA # Translate('kommissioniert')
  else if (Mat.Reserviert.Gew>0.0) then
    vA # Translate('reserviert')
  else
    vA # '';

  Erx # RecLink(820,200,9,0); // Status holen
  Erx # RecLink(819,200,1,0); // Warengruppe holen
  vA # vA + ', ' + AInt(Mat.Status) + ', ' + Mat.Sta.Bezeichnung + ', '
       + AInt(Mat.Warengruppe) + ' ' + Wgr.Bezeichnung.L1;

  $lb.Mat.Info1->wpcaption # Mat.Bemerkung1;
  $lb.Mat.Info2->wpcaption # vA;

  if (Mat.EigenmaterialYN=n) then
    $lb.Mat.Info3->wpcaption # Translate('Fremdmaterial')
  else
    $lb.Mat.Info3->wpcaption # '';

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

  if (gZLList->wpDbSelection<>0) then begin // Filter deaktivieren
/***
    SelClose(gZLList->wpDbselection);
    gZLList->wpDbselection # 0;
    Seldelete(200,myTmpSel);
      SelDelete(gFile,SelektionTmp[gFile]);
      SelektionTmp[gFile] # '';
***/
//    $Mnu.Filter.Lieferant->wpMenuCheck # false;
//    $Mnu.Filter.Lieferant->wpcaption # Translate('&Lieferant');
  end;

  RETURN true;
end;

/***
//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer
(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if ($edMat.LagerStichwort->wpcustom='next') then begin
      $edMat.LagerStichwort->wpcustom # '';
      Erx # RecLink(100,200,5,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLagerStichwort2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
end;
***/

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
end
begin

  // Workaround JEPSEN pennt....
//  if (DbaLicense(_DbaSrvLicense)='CE105655MU') then Winsleep(100);


  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  vSize # $lb.Mat.Info1->wpFont:Size;

  // Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

  if (gZLList<>0) and (aFlags & _WinPosSized != 0) then begin
//debug(aint(gZLList));
//debug(gZLList->wpname);
    vRect           # gZLList->wpArea;
//    vRect:right     # aRect:right-61;
//    vRect:bottom    # aRect:bottom-200;
    vRect:right     # aRect:right-aRect:left-4;
    //vRect:bottom    # aRect:bottom-aRect:Top-28-w_QBHeight - 60;
    vRect:bottom    # aRect:bottom-aRect:Top-28-w_QBHeight - (vSize /  2);
    gZLList->wparea # vRect;


    Lib_GUiCom:ObjSetPos($lb.Mat.Info1, 0, vRect:bottom+8);
//    Lib_GUiCom:ObjSetPos($lb.Mat.Info2, 0, vRect:bottom+8+28);
    Lib_GUiCom:ObjSetPos($lb.Mat.Info2, 0, vRect:bottom+8+ (vSize / 5) + 4);


    Lib_GUiCom:ObjSetPos($lb.Mat.Info3, 720, vRect:bottom+8);

    //$lb.Mat.Info1->wpautoupdate # false;
    //$lb.Mat.Info1->wpcolBkg # RGB(cnvif(random()*250.0),0,0);
    //vRect           # $lb.Mat.Info1->wpArea;
    //vRect:right     # aRect:right-aRect:left-4;
    //vRect:bottom    # aRect:bottom-aRect:Top-28-60;
    //$lb.Mat.Info1->wparea # vRect;
  end;

//  gZLList->wpAreaRight  # gMDI->wpAreaRight-58;
//  gZLList->wpAreaBottom # gMDI->wpAreabottom-142;
//debug(cnvai(gZLList->wpAreaBottom));
//  gZLList->winupdate(_WinUpdActivate);
	RETURN (true);
end;


//========================================================================
//  StatusSetzen
//
//========================================================================
sub StatusSetzen()
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    Erx # RecRead(820,0,_RecId,gSelected);

    PtD_Main:Memorize(200);

    RecRead(200,1,_recLock);
    // Feldübernahme
    Mat.Status # Mat.Sta.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    Erx # Mat_data:Replace(_RecUnlock,'MAN');
    PtD_Main:Compare(200);

    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);


  end;
  // Focus setzen:
  $edMat.Status->Winfocusset(false);
  RefreshIfm('edMat.Status');

end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vBuf,vBuf2  : int;
end;
begin

  if (aName = StrCnv('clmMat.Nummer',_StrUpper) AND (aBuf->Mat.Nummer<>0)) then begin
    Lib_Workbench:OpenKurzInfo(200, RecInfo(aBuf,_recID));
  end;
end;

//========================================================================
//========================================================================