@A+
//==== Business-Control ==================================================
//
//  Prozedur    Adr_V_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  12.10.2009  TM  Ankerfunktion VWW eingebaut: Adr.V.Auswahl.Strukt
//                  in SUB RefreshIfm
//  13.10.2009  MS  Verpackunsnummer wird jetzt mit der LETZTEN + 1 vorbelegt
//  03.03.2010  ST  Zusatztext hinzugefügt
//  29.10.2010  AI  NEU: PosText
//  25.03.2011  MS  Abfrage beim speichern einer Verpackungsvorschrift "weitere Verpackungsvorschriften erfassen"
//  04.07.2011  TM  Serienmarkierung eingefügt
//  02.01.2012  AI  Mnu.Copy
//  09.01.2012  AI  RAD/kgmm/Gewicht nur bei RAD <> 0 rechnen
//  22.03.2012  AI  NEU: Erzeuger
//  06.02.2013  AI  NEU: Set.Adr.RgGewKgmmYN
//  04.07.2013  ST  Quickbar für Quickbuttons hinzugefügt
//  06.08.2013  AH  Bugfix für Texte
//  19.08.2013  AH  NEU: AFX Adr.V.RecSave.Post
//  20.02.2014  AH  Neu: Intrastatnr
//  25.08.2014  TM  !! Excel Ex-/Import Verpackungsvorschriften aktiviert für Reverse Charge !!
//  21.07.2015  AH  Flag: Einkauf, Verkauf + TextName
//  25.10.2017  AH  RTF-Text
//  01.03.2018  ST  Neu: AFX Adr.V.Init.Pre, Adr.V.Init, Adr.V.EvtLstDataInit
//  22.06.2018  AH  Copy nimmt Erweiterte Analyse mit
//  21.01.2019  AH  Copy nimmt RTF-Text
//  12.07.2019  ST  Einsatzverpackung ist wieder editierbar
//  20.01.2020  AH  Aufpreise
//  27.07.2021  AH  ERX
//  31.01.2022  AH  NEU: Set.Adr.RgGewKgmmYN enkopplet auch kgMM
//  11.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit(opt aBehalten : logic);
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusIntrastat()
//    SUB AusEinzelObfOben()
//    SUB AusEinzelObfUnten()
//    SUB AusWgr()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusAFOben()
//    SUB AusAFUnten()
//    SUB AusZeugnisart()
//    SUB AusErzeuger()
//    SUB AusUnterlage()
//    SUB AusUmverpackung()
//    SUB AusZwischenlage()
//    SUB AusBAG()
//    SUB AusVerwiegungsart()
//    SUB AusEtikettentyp()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
//    SUB Skizzendaten();
//    SUB EvtTimer...
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Verpackungsvorschriften'
  cFile :     105
  cMenuName : 'Adr.V.Bearbeiten'
  cPrefix :   'Adr_V'
  cZList :    $ZL.Adr.Verpackungen
  cKey :      1
  cDialog     : 'Adr.V.Verwaltung'
  cRecht      : Rgt_Adr_Verpackungen
  cMdiVar     : gMDIAdr

  cTxtBst     : '~105.'+CnvAI(Adr.V.AdressNr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAI(Adr.V.LfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01'
  cTxtBstTmp  : myTmpText+'.105.01'

  cTxtRtf(a)  : '~105.'+CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAi(a,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.02'

  cTxtVpg     : '~105.'+CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)
  cTxtVpgTmp  : myTmpText+'.105'
end;

declare Skizzendaten();
declare TextLoad();
declare TextSave();

//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aAdrNr  : int;
  opt aLfdNr  : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
 
begin
  if (aRecId=0) and (aAdrNr<>0) then begin
    Adr.V.Adressnr  # aAdrNr;
    Adr.V.LfdNr     # alfdnr;
    Erx # RecRead(105,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(105,_recID);
    Erx # recLink(100,105,10,_recFirst);    // Adresse holen
  end;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView, true);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
  vPar  : int;
  vRect : Rect;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  $lb.Kunde1->wpcustom # aint(Adr.Nummer);

  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbAdr.V.Chemie.C1->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbAdr.V.Chemie.Si1->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbAdr.V.Chemie.Mn1->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbAdr.V.Chemie.P1->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbAdr.V.Chemie.S1->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbAdr.V.Chemie.Al1->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbAdr.V.Chemie.Cr1->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbAdr.V.Chemie.V1->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbAdr.V.Chemie.Nb1->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbAdr.V.Chemie.Ti1->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbAdr.V.Chemie.N1->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbAdr.V.Chemie.Cu1->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbAdr.V.Chemie.Ni1->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbAdr.V.Chemie.Mo1->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbAdr.V.Chemie.B1->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbAdr.V.Chemie.Frei1.1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    $lbAdr.V.Haerte1->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbAdr.V.Koernung1->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbAdr.V.Mech.Sonstig1->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    $lbAdr.V.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    $lbAdr.V.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  // Verpackungstitel setzen
  if(Set.Vpg1.Titel <> '') then
    $lbAdr.V.VpgText1 -> wpcaption  # Set.Vpg1.Titel;
  if(Set.Vpg2.Titel <> '') then
    $lbAdr.V.VpgText2 -> wpcaption  # Set.Vpg2.Titel;
  if(Set.Vpg3.Titel <> '') then
    $lbAdr.V.VpgText3 -> wpcaption  # Set.Vpg3.Titel;
  if(Set.Vpg4.Titel <> '') then
    $lbAdr.V.VpgText4 -> wpcaption  # Set.Vpg4.Titel;
  if(Set.Vpg5.Titel <> '') then
    $lbAdr.V.VpgText5 -> wpcaption  # Set.Vpg5.Titel;
  if(Set.Vpg6.Titel <> '') then
    $lbAdr.V.VpgText6 -> wpcaption  # Set.Vpg6.Titel;


  if (Set.Mech.Dehnung.Wie=1) then
    $edAdr.V.DehnungA2->wpcustom # '_N';
  if (Set.Mech.Dehnung.Wie=2) then
    $edAdr.V.DehnungB2->wpcustom # '_N';

  Lib_Guicom2:Underline($edAdr.V.Strukturnr);
  Lib_Guicom2:Underline($edAdr.V.Verwiegungsart);
  Lib_Guicom2:Underline($edAdr.V.Etikettentyp);
  Lib_Guicom2:Underline($edAdr.V.Zwischenlage);
  Lib_Guicom2:Underline($edAdr.V.Unterlage);
  Lib_Guicom2:Underline($edAdr.V.Umverpackung);
  Lib_Guicom2:Underline($edAdr.V.Warengruppe);
  Lib_Guicom2:Underline($edAdr.V.Guetenstufe);
  Lib_Guicom2:Underline($edAdr.V.Gte);
  Lib_Guicom2:Underline($edAdr.V.AusfOben);
  Lib_Guicom2:Underline($edAdr.V.AusfUnten);
  Lib_Guicom2:Underline($edAdr.V.Zeugnisart);
  Lib_Guicom2:Underline($edAdr.V.Erzeuger);
  Lib_Guicom2:Underline($edAdr.V.Intrastatnr);
  Lib_Guicom2:Underline($edAdr.V.EinsatzVPG.Adr);
  Lib_Guicom2:Underline($edAdr.V.EinsatzVPG.Nr);
  Lib_Guicom2:Underline($edAdr.V.VorlageBAG);
  Lib_Guicom2:Underline($edAdr.V.MEH);
  Lib_Guicom2:Underline($edAdr.V.Skizzennummer);
  Lib_Guicom2:Underline($edAdr.V.TextNr2);

  
  SetStdAusFeld('edAdr.V.Strukturnr'   ,'Struktur');
  SetStdAusFeld('edAdr.V.Warengruppe'  ,'Wgr');
  SetStdAusFeld('edAdr.V.Erzeuger'     ,'Erzeuger');
  SetStdAusFeld('edAdr.V.Gte'          ,'Guete');
  SetStdAusFeld('edAdr.V.Guetenstufe'  ,'Guetenstufe');
  SetStdAusFeld('edAdr.V.AusfOben'     ,'AFOben');
  SetStdAusFeld('edAdr.V.AusfUnten'    ,'AFUnten');
  SetStdAusFeld('edAdr.V.Zeugnisart'   ,'Zeugnisart');
  SetStdAusFeld('edAdr.V.Zwischenlage' ,'Zwischenlage');
  SetStdAusFeld('edAdr.V.Unterlage'    ,'Unterlage');
  SetStdAusFeld('edAdr.V.Umverpackung' ,'Umverpackung');
  SetStdAusFeld('edAdr.V.Intrastatnr'  ,'Intrastat');
  SetStdAusFeld('edAdr.V.EinsatzVPG.Adr','Einsatz');
  SetStdAusFeld('edAdr.V.EinsatzVPG.Nr','Einsatz');
  SetStdAusFeld('edAdr.V.VorlageBAG'   ,'BAG');
  SetStdAusFeld('edAdr.V.MEH'          ,'MEH');
  SetStdAusFeld('edAdr.V.Verwiegungsart','Verwiegungsart');
  SetStdAusFeld('edAdr.V.Etikettentyp' ,'Etikettentyp');
  SetStdAusFeld('edAdr.V.Skizzennummer','Skizze');
  SetStdAusFeld('edAdr.V.TextNr2'      ,'Text');


  if (Set.LyseErweitertYN) then begin
    vHdl # Winsearch(aEvt:Obj, 'lbAdr.V.SaebeligkeitMax');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edAdr.V.SaebeligkeitMax');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbAdr.V.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edAdr.V.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbSaebel');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vPar # Winsearch(aEvt:Obj, 'NB.Page4');
    vHdl # Winsearch(aEvt:Obj, 'bt.VpgKndText2');
    vHdl # Lib_GuiCom2:CreateObjFrom(vHdl, _WinTypeButton, vPar, 'bt.AnalyseErweitert', 'erweiterte Analyse anzeigen', _WinJustCenter, 152-8, 270, 70,25);
    vHdl->wpCustom  # '_I';
    Lib_GuiCom2:Hide(vPar, 'lbAnalyseStart', 'lbAnalyseEnde');
    Lib_MoreBufs:Init(gFile);
  end;

  RunAFX('Adr.V.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Adr.V.Init',aint(aEvt:Obj));
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
  Lib_GuiCom:Pflichtfeld($edAdr.V.lfdNr);
end;


//========================================================================
//========================================================================
sub RtfLoad();
begin

  if (Adr.V.RtfText1<>0) then begin
    Lib_Texte:RtfTextRead($Adr.V.RTF, cTxtRtf(Adr.V.RtfText1));
  end
  else begin
    Lib_Texte:RtfTextRead($Adr.V.RTF, cTxtRtf(Adr.V.LfdNr));
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
  Erx     : int;
  vTxtHdl : int;
  vTmp    : int;
  vBuf100 : int;
end;
begin
  $lb.Kunde1->wpcaption # Adr.Stichwort;
  $lb.Kunde2->wpcaption # Adr.Stichwort;
  $lb.Kunde3->wpcaption # Adr.Stichwort;
  $lb.Kunde4->wpcaption # Adr.Stichwort;
  $lb.Kunde5->wpcaption # Adr.Stichwort;
  $lb.Verpackungsnr->wpcaption # aint(Adr.V.lfdNr);
  $lb.Verpackungsnr2->wpcaption # aint(Adr.V.lfdNr);
  $lb.Verpackungsnr3->wpcaption # aint(Adr.V.lfdNr);
  $lb.Verpackungsnr4->wpcaption # aint(Adr.V.lfdNr);

  Erx # RecLink(819,105,2,_recFirst);     // Warengruppe holen
  if (Erx<=_rLocked) then
    $lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
  else
    $lb.Warengruppe->wpcaption # '';

  vBuf100 # RecBufCreate(100);
  Erx # RecLink(vBuf100,105,8,_recFirst);     // Erzeuger holen
  if (Erx<=_rLocked) then
    $lb.Erzeuger->wpcaption # vBuf100->Adr.Stichwort
  else
    $lb.Erzeuger->wpcaption # '';
  RecBufDestroy(vBuf100);

  Erx # RecLink(818,105,4,_recFirst);     // Verwiegungsart holen
  if (Erx<=_rLocked) then
    $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1
  else
    $lb.Verwiegungsart->wpcaption # '';

  Erx # RecLink(840,105,3,_recFirst);     // Etikettentyp holen
  if (Erx<=_rLocked) then
    $lb.Etikettentyp->wpcaption # Eti.Bezeichnung
  else
    $lb.Etikettentyp->wpcaption # '';

  if (aName='') or (aName='edAdr.V.Warengruppe') then begin
    Erx # RecLink(819,105,2,0);
    if (Erx<=_rLocked) and ((Wgr_Data:IstArt() or Wgr_Data:IstMix())) then
      $lbAdr.V.Strukturnr->wpcaption # Translate('Artikelnr.')
    else
      $lbAdr.V.Strukturnr->wpcaption # Translate('Strukturnr.');
  end;


  if (aName='') or (aName='edAdr.V.Skizzennummer') then begin
    Erx # RecLink(829, 105, 5, 0); // Skizze holen
    if (Erx<=_rLocked) then
     $picSkizze->wpcaption # '*' + Skz.Dateiname;
    else
     $picSkizze->wpcaption # '';
  end;

  if (aName='edAdr.V.Strukturnr') and (($edAdr.V.Strukturnr->wpchanged) or (aChanged)) then begin
    Erx # RecLink(220,105,6,_recFirst);   // Mat.Struktur holen
    if (Erx <= _rLocked) then begin
      // Ankerfunktion
      RunAFX('Adr.V.Auswahl.Strukt','');
    end;
  end;


  if (aName='edAdr.V.RtfText1') and (($edAdr.V.RtfText1->wpchanged) or (aChanged)) then begin
    if (Adr.V.RtfText1<>0) then
      RtfLoad();
  end;


  vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Adr.V.TextEditPos->wpdbTextBuf # vTxtHdl;
  end;
  TextLoad();

  vTxtHdl # $Adr.V.RTF->wpdbtextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Adr.V.RTF->wpdbTextBuf # vTxtHdl;
  end;
  if (Mode<>c_ModeEdit) and (aName='') then
    RtfLoad();


  if (aName='') or (aName='Text') then begin
    if (Adr.V.TextNr1=0) then begin
      $cb.Text2->wpCheckState # _WinStateChkChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
      if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
        Lib_GuiCom:Disable($Adr.v.TextEditPos);
        Lib_GuiCom:Enable($edAdr.V.TextNr2);
      end;
    end
    else begin
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;
      if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
        Lib_GuiCom:Enable($Adr.v.TextEditPos);
        Lib_GuiCom:Disable($edAdr.V.TextNr2);
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
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit(opt aBehalten : logic);
local begin
  Erx       : int;
  vNewLfdNr : int;
  vBuf105   : int;
  vTxtHdl   : int;
end;
begin

  Lib_MoreBufs:RecInit(gFile, Mode=c_ModeNew);

 // Ankerfunktion?
  if (aBehalten) then begin
    if (RunAFX('Adr.V.RecInit', '1') < 0) then
      RETURN;
  end
  else begin
    if (RunAFX('Adr.V.RecInit', '0') < 0) then
      RETURN;
  end;

  if (Mode=c_ModeNew) then begin

    vTxtHdl # $Adr.V.RTF->wpdbTextBuf;
    if (vTxtHdl<>0) then begin
      TextClear(vTxtHdl);
      $Adr.V.RTF->WinUpdate(_WinUpdBuf2Obj);
    end;

    if (aBehalten = false) then begin // 25.03.2011 MS Vogel Bauer (Prj. 1161/326)
      RecBufClear(105);
      Adr.V.EinkaufYN # true;
      Adr.V.VerkaufYN # true;

      if (w_AppendNr<>0) then begin
        RecRead(105,0,_recId,w_AppendNr);

        FOR Erx # RecLink(106,105,1,_recFirst)
        LOOP Erx # RecLink(106,105,1,_recNext)
        WHILE (Erx<=_rLocked) do begin
          Adr.V.AF.Verpacknr  # 32000;
          RekInsert(106,_recUnlock,'MAN');
          Adr.V.AF.Verpacknr  # Adr.V.lfdNr;
          RecRead(106,1,0);
        END;

        if (Set.LyseErweitertYN) then begin   // 22.06.2018 AH: Erweiterte Analyse auch vorbelegen
          Lib_MoreBufs:RecInit(105, y, y);
        end;
        
        // 21.01.2019 Zusatztext kopieren
        TxtCopy(cTxtVpg, cTxtVpgTmp,0);

        w_BinKopieVonDatei  # gFile;
        w_BinKopieVonRecID  # RecInfo(gFile, _recid);
        w_AppendNr          # 0;
      end;


    end
    else begin
      SelRecInsert(gZLList->wpDbSelection, 105);

      FOR Erx # RecLink(106,105,1,_recFirst)
      LOOP Erx # RecLink(106,105,1,_recNext)
      WHILE (Erx<=_rLocked) do begin
        Adr.V.AF.Verpacknr  # 32000;
        RekInsert(106,_recUnlock,'MAN');
        Adr.V.AF.Verpacknr  # Adr.V.lfdNr;
        RecRead(106,1,0);
      END;

      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);

      // 21.01.2019 Zusatztext kopieren
      TxtCopy(cTxtVpg, cTxtVpgTmp,0);
    end;

    // 13.10.2009 MS Wunsch Voelkel und Winkler (Prj. 1133/186)
    // letzte Verpackung der Adresse lesen
    vBuf105 #  RekSave(105);
    Erx # RecLink(105, 100, 33,_recLast);
    if(Erx > _rLocked) then
      RecBufClear(105);
    vNewLfdNr # Adr.V.lfdNr + 1;     // letzte Verpackungsnummer um 1 erhoehen
    RekRestore(vBuf105);


    // neuen Datensatz vorbelegen
    Adr.V.lfdNr # vNewLfdNr;
    Adr.V.Adressnr # Adr.Nummer;

    // Focus setzen auf Feld:
    $edAdr.V.lfdNr->WinFocusSet(true);
  end
  else begin
  
    // Focus setzen auf Feld:
    $edAdr.V.KundenArtNr->WinFocusSet(true);
  end;

  gMdi -> WinUpdate();
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vNr   : word
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (Adr.V.lfdnr=0) then begin
    Msg(001200,Translate('Verpackungsnummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.v.lfdNr->WinFocusSet(true);
    RETURN false;
  end;
  if (mode=c_ModeNew) then begin
    Erx # RecRead(gFile,1,_RecTest);
    if (Erx=_rOk) then begin
      Msg(105000,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edAdr.v.lfdNr->WinFocusSet(true);
      RETURN false;
    end;
  end;

  If (Adr.V.VorlageBAG<>0) then begin
    Erx # RecLink(700,105,7,_RecFirst);   // Vorlage BAG holen
    If (Erx>_rLocked) or (BAG.VorlageYN=false) or (BAG.VorlageSperreYN) then begin
      Msg(001201,Translate('Betreibsauftrag'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.v.VorlageBAG->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  TRANSON;
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);

    TextSave();
    Lib_Texte:RtfTextSave($Adr.V.RTF, cTxtRtf(Adr.V.LfdNr));
  end
  else begin
    // Ausführungen umnummerieren
    vNr # Adr.V.lfdNr;
    Adr.V.LfdNr # 32000;
    WHILE (RecLink(106,105,1,_recFirst)=_rOK) do begin
      RecRead(106,1,_RecLock);
      Adr.V.AF.Adressnr   # Adr.Nummer;
      Adr.V.AF.Verpacknr  # vNr;
      Erx # RekReplace(106,_recUnlock,'MAN');
      If (erx<>_Rok) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    END;
    Adr.V.lfdNr # vNr;

    Adr.V.Anlage.Datum  # Today;
    Adr.V.Anlage.Zeit   # Now;
    Adr.V.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TxtRename(cTxtVpgTmp, cTxtVpg, 0);

    TextSave();
    Lib_Texte:RtfTextSave($Adr.V.RTF, cTxtRtf(Adr.V.LfdNr));
  end;

  Erx # Lib_MoreBufs:SaveAll(gFile, true);
  if (erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  TRANSOFF;


  RunAFX('Adr.V.RecSave.Post','');

  // Weitermachen mit eingeben?
  if (w_NoList = false) and (Mode = c_ModeNew) then begin
    if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
      RecInit(true);
      RETURN false;
    end
    else begin
      RETURN true;
    end;
  end; // Weitermachen mit eingeben?

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  vNr : int;
end;
begin

  Lib_MoreBufs:Unlock();

  // Ausführungen löschen
  vNr # Adr.V.lfdNr;
  if (Mode=c_ModeNew) then begin
    Adr.V.LfdNr # 32000;

    WHILE (RecLink(106,105,1,_recFirst)=_rOK) do
      RekDelete(106,0,'MAN');

    TxtDelete(cTxtVpgTmp, 0);
  end;
  Adr.V.LfdNr # vNr;

  RunAFX('Adr.V.Cleanup.Post', '');

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx     : int;
  vBuf105 : int;
  vName   : alpha;
end;
begin

  // Prüfen, ob diese Verpackung wo anders als Einsatz-VPG dient....
  vBuf105 # RecBufCreate(105);
  vBuf105->Adr.V.EinsatzVPG.Adr # Adr.V.Adressnr;
  vBuf105->Adr.V.EinsatzVPG.Nr  # Adr.V.lfdNr;
  Erx # RecRead(vBuf105,5,0);
  if (Erx<=_rMultikey) then begin
    Msg(105002,aint(vBuf105->Adr.V.Adressnr)+'/'+aint(vBuf105->adr.V.lfdNr),_WinIcoError, _WinDialogOk,1);
    RecBufDestroy(vBuf105);
    RETURN;
  end;
  RecBufDestroy(vBuf105);

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    // Ausführungen löschen
    TRANSON;

    WHILE (RecLink(106,105,1,_recFirst)=_rOK) do
      Erx # RekDelete(106,0,'MAN');
      //RekDelete(106,0,'MAN');
    if (Erx=_rLocked) then begin
      TRANSBRK;
      msg(105001,'',0,0,0);
      RETURN;
    end;

    
    // Aufpreise löschen
    WHILE (RecLink(104,105,9,_recFirst)<=_rLocked) do begin
      Erx # RekDelete(104);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        msg(105001,'',0,0,0);
        RETURN;
      end;
    END;
    
    
    Erx # RekDelete(gFile,0,'MAN');
    if (Erx<>_rok) then begin
      TRANSBRK;
      msg(105001,'',0,0,0);
      RETURN;
    end;

    if (Lib_MoreBufs:DeleteAll(gFile,y)<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;

    vName # cTxtBst;
    TxtDelete(vName,0);
    vName # cTxtVpg;
    TxtDelete(vName,0);
    vName # cTxtRtf(Adr.V.LfdNr);
    TxtDelete(vName,0);


    if (gZLList->wpDbSelection<>0) then begin
      SelRecDelete(gZLList->wpDbSelection,gFile);
      RecRead(gFile, gZLList->wpDbSelection, 0);
    end;

    TRANSOFF;

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

  if (Adr.V.RtfText1=0) and
  ((Mode=c_modeedit) or (Mode=c_modenew)) and
   (Wininfo(aEvt:Obj, _WinType)=_WinTypeRtfEdit) then begin
    aEvt:Obj->wpReadOnly  # n;
//    aEvt:Obj->wpColBkgApp # _WinColWindow;
    $Adr.V.ToolbarRTF -> wpdisabled # false;
    $Adr.V.ToolbarTXT -> wpdisabled # false;
    $Adr.V.ToolbarRTF->wpObjLink # aEvt:Obj->WpName;
  end
  else begin
    if ($Adr.V.ToolbarRTF->wpdisabled=false) then begin
      $Adr.V.ToolbarRTF -> winupdate(_Winupdon);
      $Adr.V.ToolbarRTF -> wpdisabled # true;
      $Adr.V.ToolbarTXT -> wpdisabled # true;
    end;
    if (Wininfo(aEvt:Obj, _WinType)=_WinTypeRtfEdit) then begin
      aEvt:Obj->wpReadOnly  # y;
//      aEvt:Obj->wpColBkgApp # _WinCol3DLight;
    end;
  end;


/*
  ST 2019-07-12 Deaktiviert, damit man Einträge auch leeren kann (Pug HErr Rosenbaum)
  $edAdr.V.EinsatzVPG.Adr->wpreadonly # true;
  $edAdr.V.EinsatzVPG.Nr->wpreadonly # true;
*/

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

  if (aEvt:obj->wpname='edAdr.V.Gte') then
    MQU_Data:Autokorrektur(var "Adr.V.Güte");

  if (aEvt:obj->wpname='edAdr.V.DickenTol') /*and (Adr.V.Dicke<>0.0)*/ then
    "Adr.V.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("Adr.V.Dickentol",Set.Stellen.Dicke);

  if (aEvt:obj->wpname='edAdr.V.BreitenTol') /*and (Adr.V.Breite<>0.0)*/ then
    "Adr.V.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("Adr.V.Breitentol",Set.Stellen.Breite);

  if (aEvt:obj->wpname='edAdr.V.LaengenTol') /*and ("Adr.V.Länge"<>0.0)*/ then
    "Adr.V.Längentol" # Lib_Berechnungen:Toleranzkorrektur("Adr.V.Längentol","Set.Stellen.Länge");

  if ((aEvt:obj->wpname='edAdr.V.Skizzennummer') and ($edAdr.V.Skizzennummer->wpchanged)) then begin
    Skizzendaten();
    RETURN false;
  end;

  // 31.01.2022 AH
  if (Set.Adr.RgGewKgmmYN=false) then begin
    if ((aEvt:obj->wpname='edAdr.V.RingKgVon') and ($edAdr.V.RingKgVon->wpchanged)) then begin
      if (Adr.V.KgmmVon=0.0) and (Adr.V.Breite<>0.0) then Adr.V.KGmmVon # Rnd(Adr.V.RingKgVon / Adr.V.Breite,2);
      if (Adr.V.RAD=0.0) then begin
        Erx # RecLink(819,105,2,_recFirst);   // Warengruppe holen
        Adr.V.RAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRID(Adr.V.RingKgVon, 1, Adr.V.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 105), Adr.V.RID);
      end;
      $edAdr.V.KgmmVon->winupdate();
      $edAdr.V.RAD->winupdate();
    end;

    if ((aEvt:obj->wpname='edAdr.V.RingKgBis') and ($edAdr.V.RingKgBis->wpchanged)) then begin
      if (Adr.V.KgmmBis=0.0) and (Adr.V.Breite<>0.0) then Adr.V.KGmmBis # Rnd(Adr.V.RingKgBis / Adr.V.Breite,2);
      if (Adr.V.RADmax=0.0) then begin
        Erx # RecLink(819,105,2,_recFirst);   // Warengruppe holen
        Adr.V.RADmax # Lib_Berechnungen:RAD_aus_KgStkBDichteRID(Adr.V.RingKgBis, 1, Adr.V.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 105), Adr.V.RID);
      end;
      $edAdr.V.KgmmBis->winupdate();
      $edAdr.V.RADMax->winupdate();
    end;

    if ((aEvt:obj->wpname='edAdr.V.KgmmVon') and ($edAdr.V.KgmmVon->wpchanged)) then begin
      if (Adr.V.RingkgVon=0.0) and (Adr.V.Breite<>0.0) then Adr.V.RingKgVon # Rnd(Adr.V.kgmmVon * Adr.V.Breite,2);
      if (Adr.V.RAD=0.0) then begin
        Erx # RecLink(819,105,2,_recFirst);   // Warengruppe holen
        Adr.V.RAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRID(Adr.V.RingKgVon, 1, Adr.V.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 105), Adr.V.RID);
      end;
      $edAdr.V.RAD->winupdate();
      $edAdr.V.RingKgVon->winupdate();
    end;

    if ((aEvt:obj->wpname='edAdr.V.KgmmBis') and ($edAdr.V.KgmmBis->wpchanged)) then begin
      if (Adr.V.Ringkgbis=0.0) and (Adr.V.Breite<>0.0) then Adr.V.RingKgBis # Rnd(Adr.V.kgmmbis * Adr.V.Breite,2);
      if (Adr.V.RADmax=0.0) then begin
        Erx # RecLink(819,105,2,_recFirst);   // Warengruppe holen
        Adr.V.RADmax # Lib_Berechnungen:RAD_aus_KgStkBDichteRID(Adr.V.RingKgBis, 1, Adr.V.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 105), Adr.V.RID);
      end;
      $edAdr.V.RADMax->winupdate();
      $edAdr.V.RingKgBis->winupdate();
    end;

    if ((aEvt:obj->wpname='edAdr.V.RAD') and ($edAdr.V.RAD->wpchanged) and (Adr.V.RAD<>0.0)) then begin
      if (Adr.V.RingKgVon=0.0) then
        Adr.V.RingKgVon # Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD(1, Adr.V.Breite, Wgr_Data:GetDichte(Adr.V.Warengruppe, 105), Adr.V.RID, Adr.V.RAD);
      if (Adr.V.KgmmVon=0.0) and (Adr.V.Breite<>0.0) then Adr.V.KGmmVon # Rnd(Adr.V.RingKgVon / Adr.V.Breite,2);
      $edAdr.V.KgmmVon->winupdate();
      $edAdr.V.RingKgVon->winupdate();
    end;

    if ((aEvt:obj->wpname='edAdr.V.RADmax') and ($edAdr.V.RADmax->wpchanged) and (Adr.V.RADmax<>0.0)) then begin
      if (Adr.V.RingKgBis=0.0) then
        Adr.V.RingKgBis # Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD(1, Adr.V.Breite, Wgr_Data:GetDichte(Adr.V.Warengruppe, 105), Adr.V.RID, Adr.V.RADMax);
      if (Adr.V.KgmmBis=0.0) and (Adr.V.Breite<>0.0) then Adr.V.KGmmBis # Rnd(Adr.V.RingKgBis / Adr.V.Breite,2);
      $edAdr.V.KgmmBis->winupdate();
      $edAdr.V.RingKgBis->winupdate();
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
  Erx       : int;
  vA        : alpha;
  vFilter   : int;
  vQ        : alpha(4000);
  vNr       : int;
  vHdl      : int;
  vTmp      : int;
  vSel      : int;
  vSelName  : alpha;
end;

begin

  case aBereich of

    'AnalyseErweitert' : begin
      if (Mode=c_ModeNew) then
        Lys_Msk_Main:Start('', Mode=c_ModeEdit or Mode=c_ModeNew, 'neue Adress-Verpackung '+Adr.Stichwort, "Adr.V.Güte", "Adr.V.Gütenstufe", Adr.V.Dicke)
      else
        Lys_Msk_Main:Start('', Mode=c_ModeEdit or Mode=c_ModeNew, 'Adress-Verpackung '+aint(Adr.V.lfdNr)+' '+Adr.Stichwort, "Adr.V.Güte", "Adr.V.Gütenstufe", Adr.V.Dicke);
      RETURN;
    end;


    'RtfText1' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusRtfText1');
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'Adr.V.Adressnr = ' + aint(Adr.Nummer);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Intrastat' : begin
      if (Msg(220001,'',0,_WinDialogYesNo,1)=_WinIdYes) then begin

        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

        // Selektion
        vQ # '';
        Lib_Sel:QAlpha(var vQ, 'MSL.Strukturtyp', '=', 'INTRA');
        Lib_Sel:QAlpha(var vQ, 'MSL.Intrastatnr', '>', '');
        Lib_Sel:QInt(var vQ, 'MSL.von.Warengruppe', '<=', Adr.V.Warengruppe);
        Lib_Sel:QInt(var vQ, 'MSL.bis.Warengruppe', '>=', Adr.V.Warengruppe);
//        vQ # vQ + ' AND (MSL.bis.Status = 0 OR Mat.Status = 0 OR (MSL.von.Status <= Mat.Status AND MSL.bis.Status >= Mat.Status)) ';
        vQ # vQ + ' AND ("MSL.Güte" = "Adr.V.Güte" OR "MSL.Güte" = '''' OR "Adr.V.Güte" = '''') ';
        vQ # vQ + ' AND ("MSL.Gütenstufe" = "Adr.V.Gütenstufe" OR "MSL.Gütenstufe" = '''' OR "Adr.V.Gütenstufe" = '''') ';
        vQ # vQ + ' AND (Adr.V.Dicke = 0.0 OR (MSL.von.Dicke <= Adr.V.Dicke AND MSL.bis.Dicke >= Adr.V.Dicke)) ';
        vQ # vQ + ' AND (Adr.V.Breite = 0.0 OR (MSL.von.Breite <= Adr.V.Breite AND MSL.bis.Breite >= Adr.V.Breite)) ';
        vQ # vQ + ' AND ("Adr.V.Länge" = 0.0 OR ("MSL.von.Länge" <= "Adr.V.Länge" AND "MSL.bis.Länge" >= "Adr.V.Länge")) ';

        vSel # SelCreate(220, gKey);
        Erx # vSel->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vSel);
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


    'Struktur' : begin              // Struktur

      Erx # RecLink(819, 105, 2, _recFirst); // Warengruppe holen
      if (Erx > _rLocked) then
        RecBufClear(819);
        if (Wgr_Data:IstArt()) or (Wgr_Data:IstMix()) then begin
//      (Wgr.Dateinummer=c_Wgr_ArtMatMix) or ((Wgr.Dateinummer >= c_Wgr_Artikel) and (Wgr.Dateinummer <= c_Wgr_bisArtikel)) then begin
        RecBufClear(250);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelnummer');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        gKey # 1;

        vHdl # Winsearch(gMDI,'ZL.Artikel');
        Lib_Sel:QRecList(vHdl,'Art.Nummer>'''' AND NOT(Art.GesperrtYN)');
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else begin
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusStruktur');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Wgr' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Erzeuger' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete' : begin
      RecBufClear(832);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "Adr.V.Gütenstufe";
      //vQ # ' MQu.NurStufe = MQu.S.Stufe OR MQu.NurStufe = '''' OR MQu.S.Stufe = ''''';
      //Lib_Sel:QRecList(0, vQ);
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guetenstufe' : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AFOben' : begin
      vNr # Adr.V.LfdNr;
      if (Mode=c_ModeNew) then
        Adr.V.lfdNr # 32000;

      vFilter # RecFilterCreate(106,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Adr.V.Adressnr);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Adr.V.LfdNr);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(106,105,1,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        Adr.V.lfdNr # vNr;
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end

      RecBufClear(106);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.V.AF.Verwaltung', here+':AusAFOben', y);

      vTmp # gMDI->winsearch('lb.Adr.V.AF.Verpacknr');
      vTmp->wpcaption # cnvai(Adr.V.lfdNr);

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdbfileno     # 106;
      gZLList->wpdbKeyno      # 1;
      gZLList->wpdbLinkfileno # 0;
      vFilter # RecFilterCreate(106,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Adr.V.Adressnr);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Adr.V.lfdNr);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      Adr.V.lfdNr # vNr;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AFUnten' : begin
      vNr # Adr.V.LfdNr;
      if (Mode=c_ModeNew) then
        Adr.V.lfdNr # 32000;

      vFilter # RecFilterCreate(106,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Adr.V.Adressnr);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Adr.V.lfdnr);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(106,105,1,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        Adr.V.lfdNr # vNr;
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end

      RecBufClear(106);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.V.AF.Verwaltung', here+':AusAFUnten', y);

      vTmp # gMDI->winsearch('lb.Adr.V.AF.Verpacknr');
      vTmp->wpcaption # cnvai(Adr.V.lfdNr);

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdbfileno     # 106;
      gZLList->wpdbKeyno      # 1;
      gZLList->wpdbLinkfileno # 0;
      vFilter # RecFilterCreate(106,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Adr.V.Adressnr);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Adr.V.LfdNr);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '2');
      //VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFilter # vFilter;
      Adr.V.lfdNr # vNr;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zeugnisart' : begin
      RecBufClear(839);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zeu.Verwaltung',here+':AusZeugnisart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Unterlage' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'ULa.Verwaltung',here+':AusUnterlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=1';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Umverpackung' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'ULa.Verwaltung',here+':AusUmverpackung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=3';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zwischenlage' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'ULa.Verwaltung',here+':AusZwischenlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=2';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Einsatz' : begin
//      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusEinsatzAdr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Einsatz2' : begin
      Adr.Nummer # Adr.V.EinsatzVPG.Adr;
      RecRead(100,1,0);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusEinsatzNr');
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'Adr.V.Adressnr = ' + aint(Adr.V.EinsatzVPG.Adr);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edAdr.V.MEH,105,1,13)
    end;


    'BAG' : begin
      RecBufClear(700);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Verwaltung',here+':AusBAG');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vHdl # gZLList;
      Lib_Sel:QRecList(vHdl,'BAG.VorlageYN=true AND BAG.VorlageSperreYN=false');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verwiegungsart' : begin
      RecBufClear(818);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VWa.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Etikettentyp' : begin
      RecBufClear(840);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'Eti.Verwaltung',here+':AusEtikettentyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Skizze' : begin
      RecBufClear(829);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Skz.Verwaltung',here+':AusSkizze');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VpgKndText' : begin
      if (Mode=c_modenew) then
        Mdi_RtfEditor_Main:Start(cTxtVpgTmp, Rechte[Rgt_Adr_V_Aendern], 'Kundenartikelbeschreibung')
      else
        Mdi_RtfEditor_Main:Start(cTxtVpg, Rechte[Rgt_Adr_V_Aendern], 'Kundenartikelbeschreibung');
    end;


    'Text' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText');
//      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
//      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

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
    Adr.V.Intrastatnr # MSL.Intrastatnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edAdr.V.Intrastatnr->Winfocusset(false);
end;


//========================================================================
//  AusEinzelObfOben
//
//========================================================================
sub AusEinzelObfOben()
local begin
  vFilter : int;
  vTmp    : int;
  vNr     : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(106);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.V.AF.Verwaltung', here+':AusAFOben', y);

    vTmp # gMDI->winsearch('lb.Adr.V.AF.Verpacknr');
    if (Mode=c_ModeNew) then
      vNr # 32000
    else
      vNr # Adr.V.lfdNr;
    vTmp->wpcaption # cnvai(vNr);

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    gZLList->wpdbfileno     # 106;
    gZLList->wpdbKeyno      # 1;
    gZLList->wpdbLinkfileno # 0;
    vFilter # RecFilterCreate(106,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Adr.V.Adressnr);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, vNr);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, '1');
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
  vNr     : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(106);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.V.AF.Verwaltung', here+':AusAFUnten', y);

    vTmp # gMDI->winsearch('lb.Adr.V.AF.Verpacknr');
    if (Mode=c_ModeNew) then
      vNr # 32000
    else
      vNr # Adr.V.lfdNr;
    vTmp->wpcaption # cnvai(vNr);

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    gZLList->wpdbfileno     # 106;
    gZLList->wpdbKeyno      # 1;
    gZLList->wpdbLinkfileno # 0;
    vFilter # RecFilterCreate(106,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Adr.V.Adressnr);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, vNr);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, '2');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '2';
    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:'
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;
    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusEinsatzAdr
//
//========================================================================
sub AusEinsatzAdr()
local begin
  vBuf100 : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    vBuf100 # RecBufCreate(100);
    RecRead(vBuf100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.EinsatzVPG.Adr # vBuf100->Adr.Nummer;
    RecBufDestroy(vBuf100);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edAdr.V.EinsatzVPG.Adr->Winfocusset(false);
//  RefreshIfm('edMat.Lageradresse');
  Auswahl('Einsatz2');
end;


//========================================================================
//  AusEinsatzNr
//
//========================================================================
sub AusEinsatzNr()
local begin
  vBuf105 : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    vBuf105 # RecBufCreate(105);
    RecRead(vBuf105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.EinsatzVPG.Nr # vBuf105->Adr.v.lfdNr;
    RecBufDestroy(vBuf105);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  Adr.Nummer # cnvia($lb.Kunde1->wpcustom);
  RecRead(100,1,0);

  // Focus setzen:
  $edAdr.V.EinsatzVPG.Nr->Winfocusset(false);
//  RefreshIfm('edMat.Lageradresse');
end;


//========================================================================
//  AusRtfText1
//
//========================================================================
sub AusRtfText1()
local begin
  vBuf105 : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    vBuf105 # RecBufCreate(105);
    RecRead(vBuf105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.RtfText1 # vBuf105->Adr.v.lfdNr;
    RecBufDestroy(vBuf105);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  Adr.Nummer # cnvia($lb.Kunde1->wpcustom);
  RecRead(100,1,0);

  // Focus setzen:
  $edAdr.V.RtfText1->Winfocusset(false);
  RefreshIfm('edAdr.V.RtfText1',y);
end;


//========================================================================
//  AusSkizze
//
//========================================================================
sub AusSkizze()
local begin
  vDoIt   : logic;
  vTmp    : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(829,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.Skizzennummer # Skz.Nummer;
    $picSkizze->wpcaption # '*'+Skz.Dateiname;
    vDoIt # y;
    $edAdr.V.Skizzennummer->winupdate(_WinUpdFld2Obj);

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Skizzennummer->Winfocusset(false);
  if (vDoIt) then Skizzendaten();
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
    Adr.V.Strukturnr # MSL.Strukturnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  RefreshIfm('edAdr.V.Strukturnr',y)
  // Focus setzen:
  $edAdr.V.Strukturnr->Winfocusset(false);

end;


//========================================================================
//  AusArtikelnummer
//
//========================================================================
sub AusArtikelnummer()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.Strukturnr # Art.Nummer ;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  gMDI->Winupdate();

  // Focus setzen:
  $edAdr.V.Strukturnr->Winfocusset(false);
end;


//========================================================================
//  AusWGr
//
//========================================================================
sub AusWgr()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.Warengruppe # Wgr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus auf Editfeld setzen:
  $edAdr.V.Warengruppe->Winfocusset(false);
  RefreshIfm('edAdr.V.Warengruppe');
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
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
    gSelected # 0;
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Adr.V.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Adr.V.Güte" # "MQu.Güte1"
    else
      "Adr.V.Güte" # "MQu.Güte2";
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Gte->Winfocusset(false);
  // ggf. Labels refreshen
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
    "Adr.V.Gütenstufe" # MQu.S.Stufe;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Guetenstufe->Winfocusset(false);
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
local begin
  vNr : int;
end;
begin
  gSelected # 0;
  vNr # Adr.V.lfdNr;
  if (Mode=c_ModeNew) then Adr.V.lfdNr # 32000;
  Adr.V.AusfOben # Obf_Data:BildeAFString(105,'1');
  Adr.V.lfdNr # vNr;
  // Focus auf Editfeld setzen:
  $edAdr.V.AusfOben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
local begin
  vNr : int;
end;
begin
  gSelected # 0;
  vNr # Adr.V.lfdNr;
  if (Mode=c_ModeNew) then Adr.V.lfdNr # 32000;
  Adr.V.AusfUnten # Obf_Data:BildeAFString(105,'2');
  Adr.V.lfdNr # vNr;
  // Focus auf Editfeld setzen:
  $edAdr.V.AusfUnten->Winfocusset(false);
end;


//========================================================================
//  AusZeugnisart
//
//========================================================================
sub AusZeugnisart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(839,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.Zeugnisart # Zeu.Bezeichnung;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Zeugnisart->Winfocusset(false);
end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub AusErzeuger()
local begin
  vTmp    : int;
  vBuf100 : int;
end;
begin
  if (gSelected<>0) then begin
    vBuf100 # RecBufCreate(100);
    RecRead(vBuf100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.Erzeuger # vBuf100->Adr.Nummer;
    RecBufDestroy(vBuf100);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  Adr.Nummer # cnvia($lb.Kunde1->wpcustom);
  RecRead(100,1,0);

  // Focus auf Editfeld setzen:
  $edAdr.V.Erzeuger->Winfocusset(false);
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
    gSelected # 0;
    // Feldübernahme
    Adr.V.Unterlage # ULa.Bezeichnung;
    Adr.V.StapelhAbzug # "ULa.Höhenabzug";
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $edAdr.V.StapelhAbzug->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Unterlage->Winfocusset(false);
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
    gSelected # 0;
    // Feldübernahme
    Adr.V.Umverpackung # ULa.Bezeichnung;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Umverpackung->Winfocusset(false);
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
    gSelected # 0;
    // Feldübernahme
    Adr.V.Zwischenlage # ULa.Bezeichnung;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Zwischenlage->Winfocusset(false);
end;


//========================================================================
//  AusBAG
//
//========================================================================
sub AusBAG()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(700,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Adr.V.VorlageBAG # BAG.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.VorlageBAG->Winfocusset(false);
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
    gSelected # 0;
    // Feldübernahme
    Adr.V.Verwiegungsart # VWa.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Verwiegungsart->Winfocusset(false);
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
    gSelected # 0;
    // Feldübernahme
    Adr.V.Etikettentyp # Eti.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Etikettentyp->Winfocusset(false);
end;


//========================================================================
//  AusText
//
//========================================================================
sub AusText()
local begin
  vTxtHdl     : int;
  vTmp        : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,0,0,0,0);

    $Adr.V.TextEditPos->WinUpdate(_WinUpdBuf2Obj);

    // Ausgewählten Text in das Feld eintragen
    Adr.V.TextNr1 # 0;
    Adr.V.TextNr2 # Txt.Nummer;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

    Lib_GuiCOM:Disable($edAdr.V.TextNr2);
    Adr.V.TextNr2 # Txt.Nummer;

    // ggf. Labels refreshen
    $cb.Text2->wpCheckState # _WinStateChkChecked;
    $cb.Text3->wpCheckState # _WinStateChkUnchecked;

    // Focus auf Editfeld setzen:
    $cb.Text2->Winfocusset(true);
  end;
  gSelected # 0;

end;


//========================================================================
//  AusTextAdd
//
//========================================================================
sub AusTextAdd();
local begin
  vTxtHdl     : int;
  vTxtHdl2    : int;
  vTmp        : int;
  vI          : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;
/*
    Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,0,0,0,0);
*/
    vTxtHdl2 # TextOpen(16);
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl2, Auf.Sprache);
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl2,_TextLines)) do begin
      TextLineWrite(vTxtHdl, TextInfo(vTxtHdl,_textLines)+1, TextLineRead(vTxtHdl2,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl2);

    $Adr.V.TextEditPos->WinUpdate(_WinUpdBuf2Obj);

    // Ausgewählten Text in das Feld eintragen
    Adr.V.TextNr1 # 105;
    Adr.V.TextNr2 # 0;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

    Lib_GuiCOM:Disable($edAdr.V.TextNr2);
    Adr.V.TextNr2 # Txt.Nummer;

    // ggf. Labels refreshen
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;

    // Focus auf Editfeld setzen:
    $cb.Text2->Winfocusset(true);
  end;
  gSelected # 0;

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_context<>'') or (Rechte[Rgt_Adr_V_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_context<>'') or (Rechte[Rgt_Adr_V_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Adr_V_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Adr_V_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (w_Auswahlmode) or (Rechte[Rgt_Adr_V_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (w_Auswahlmode) or (Rechte[Rgt_Adr_V_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Aufpreise');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) and (Mode<>c_ModeView);

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Adr_V_Anlegen]=n);

//  $bt.VpgKndText->wpdisabled # (Mode=c_ModeNew);
//  $bt.VpgKndText2->wpdisabled # (Mode=c_ModeNew);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;

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
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
  
    'Mnu.Aufpreise' : begin
      vHdl # winsearch(gMDI, 'NB.Main');
//      vHdl->wpcustom # cnvai(Adr.V.Adressnr,_FmtNumNoGroup,0,5)+CnvAI(Winfocusget(),_FmtNumNogroup,0,10);
      RecBufClear(104);
      // MUSTER
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Z.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Copy' : begin
      w_AppendNr # RecInfo(gFile, _recId);
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Adr.V.Anlage.Datum, Adr.V.Anlage.Zeit, Adr.V.Anlage.User);
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Druck.Stammblatt' : begin
      lib_Dokumente:PrintForm(105,'Stammdatenblatt',n);
    end;


    // NEU: Serienmarkierung 2011-07-04 TM
    'Mnu.Mark.Sel' : begin
      Adr_V_Mark_Sel();  // Aufruf Selektionsdialog und -durchführung
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
  vQ : alpha;
end
begin

  case (aEvt:Obj->wpName) of
    'bt.AnalyseErweitert' : Auswahl('AnalyseErweitert');
    'bt.VpgKndText'       : Auswahl('VpgKndText');
    'bt.VpgKndText2'      : Auswahl('VpgKndText');
    
    'bt.Standardtext2.Add' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusTextAdd');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      
      Gv.Alpha.01 # '';
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    
    
  end;

  if (Mode=c_ModeView) then
    RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.RtfText1'       : Auswahl('RtfText1');
    'bt.Intrastat'      : Auswahl('Intrastat');
    'bt.Struktur'       : Auswahl('Struktur');
    'bt.Wgr'            : Auswahl('Wgr');
    'bt.Erzeuger'       : Auswahl('Erzeuger');
    'bt.Guete'          : Auswahl('Guete');
    'bt.Guetenstufe'    : Auswahl('Guetenstufe');
    'bt.AusfOben'       : Auswahl('AFOben');
    'bt.AusfUnten'      : Auswahl('AFUnten');
    'bt.Zeugnisart'     : Auswahl('Zeugnisart');
    'bt.Zwischenlage'   : Auswahl('Zwischenlage');
    'bt.Unterlage'      : Auswahl('Unterlage');
    'bt.Umverpackung'   : Auswahl('Umverpackung');
    'bt.Einsatz'        : Auswahl('Einsatz');
    'bt.BAG'            : Auswahl('BAG');
    'bt.MEH'            : Auswahl('MEH');
    'bt.Verwiegungsart' : Auswahl('Verwiegungsart');
    'bt.Etikettentyp'   : Auswahl('Etikettentyp');
    'bt.Skizze'         : Auswahl('Skizze');
    'bt.VpgKndText'     : Auswahl('VpgKndText');
    'bt.VpgKndText2'    : Auswahl('VpgKndText');
    'bt.Standardtext'   : Auswahl('Text');
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
  vName   : alpha;
  vTxtHdl : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbAdr.V.StehendYN') and (Adr.V.StehendYN) then begin
    Adr.V.LiegendYN # n;
    $cbAdr.V.LiegendYN->winupdate(_WinUpdFld2Obj);
  end;
  if (aEvt:Obj->wpname='cbAdr.V.LiegendYN') and (Adr.V.LiegendYN) then begin
    Adr.V.StehendYN # n;
    $cbAdr.V.StehendYN->winupdate(_WinUpdFld2Obj);
  end;


  if (aEvt:Obj->wpName='cb.Text2') then begin
    if ($cb.Text2->wpCheckState=_WinStateChkChecked) then begin
      $cb.Text3->wpcheckstate # _WinStateChkUnchecked;
      Adr.V.TextNr1 # 0;
      Adr.V.TextNr2 # 0;
      TextLoad();
      RefreshIfm('Text');
    end;
  end;
  if (aEvt:Obj->wpName='cb.Text3') then begin
    if ($cb.Text3->wpCheckState=_WinStateChkChecked) then begin
      $cb.Text2->wpcheckstate # _WinStateChkUnchecked;

      vName # '~837.'+CnvAI(Adr.V.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);

      Adr.V.TextNr1 # 105;
      Adr.V.TextNr2 # 0;

      vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;
//      Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl, Auf.Sprache);
      Lib_Texte:TxtLoad5Buf(vName, vTxtHdl,0,0,0,0);

      //if (Adr.V.AdressNr>1000000000) then
      if (Mode=c_ModeNew) then
        vName # cTxtBstTmp
      else
        vName # cTxtBst;
      $Adr.V.TextEditPos->wpcustom # vName;
      $Adr.V.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
      RefreshIfm('Text');
    end;
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
  if (aSelecting) and (aPage->wpname='NB.Page2') then begin
    $edAdr.V.VpgText1b->winupdate();
    $edAdr.V.VpgText2b->winupdate();
    $edAdr.V.VpgText3b->winupdate();
    $edAdr.V.VpgText4b->winupdate();
    $edAdr.V.VpgText5b->winupdate();
    $edAdr.V.VpgText6b->winupdate();
  end;
  if (aSelecting) and (aPage->wpname='NB.Page1') then begin
    $edAdr.V.VpgText1->winupdate();
    $edAdr.V.VpgText2->winupdate();
    $edAdr.V.VpgText3->winupdate();
    $edAdr.V.VpgText4->winupdate();
    $edAdr.V.VpgText5->winupdate();
    $edAdr.V.VpgText6->winupdate();
  end;

  // AnalyseErweitert
  if (aSelecting) and (aPage->wpName='NB.Page4') and (Set.LyseErweitertYN) then
    gTimer2 # SysTimerCreate(300,1,gMdi);

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
  Erx     : int;
  vBuf105 : int;
end;
begin
  if (w_context<>'') then RecLink(100,105,10,_recFirst);    // Adresse holen
  if (aMark) then begin
    if (RunAFX('Adr.V.EvtLstDataInit','y')<0) then RETURN;
  end else begin
    if (RunAFX('Adr.V.EvtLstDataInit','n')<0) then RETURN;
  end;

  Gv.Alpha.01 # '';

  if (Adr.V.EinsatzVPG.Adr<>0) and (Adr.V.EinsatzVPG.Nr<>0) then begin
    vBuf105 # RecBufCreate(105);
    vBuf105->Adr.v.Adressnr # Adr.V.EinsatzVPG.Adr;
    vBuf105->Adr.V.lfdNr    # Adr.V.EinsatzVPG.Nr;
    Erx # RecRead(vBuf105,1,0);
    if (erx<=_rMultikey) then begin
      GV.Alpha.01 # anum(vBuf105->Adr.V.Dicke,Set.Stellen.Dicke);
      if (vBuf105->Adr.V.Breite<>0.0) then
        GV.Alpha.01 # Gv.Alpha.01 + ' x '+anum(vBuf105->Adr.V.Breite,Set.Stellen.Breite);
      if (vBuf105->"Adr.V.Länge"<>0.0) then
        GV.Alpha.01 # Gv.Alpha.01 + ' x '+anum(vBuf105->"Adr.V.Länge","Set.Stellen.Länge");
    end;
    RecBufDestroy(vBuf105);
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
  if (w_context<>'') then RecLink(100,105,10,_recFirst);    // Adresse holen
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTxtHdl : int;
end;
begin
  vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
  end;

  vTxtHdl # $Adr.V.RTF->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  RETURN true;
end;


//========================================================================
// EvtPosChanged [15.03.2010/PW]
//
//========================================================================
sub EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
local begin
  vRect : rect;
  vHdl  : int;
end
begin

  if (gZLList=0) then RETURN true;    // WORKAROUND VogelBauer

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  // Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;
/*
  if ( aFlags & _winPosSized != 0 ) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right  - aRect:left - 4;
    vRect:bottom    # aRect:bottom - aRect:top - 28 - 60 - w_QBHeight;
    gZLList->wpArea # vRect;


    Lib_GuiCom:ObjSetPos( $lbAuf.P.Info1, 0, vRect:bottom + 8  );
    Lib_GuiCom:ObjSetPos( $lbAuf.P.Info2, 0, vRect:bottom + 8 + 28 );

    // RecList:
    vHdl # Winsearch(aEvt:Obj, 'ZL.Erfassung');
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28;
    vHdl->wparea # vRect;

  end;
*/
	RETURN true;
end;


//========================================================================
//  Skizzendaten
//
//========================================================================
sub Skizzendaten();
local begin
  vZ          : int;
  vA          : alpha;
  vWert       : alpha;
  vX          : int;
  vA3,vA4,vA5 : alpha(1000);
end;
begin

  // SPEZI
  gMDI->wpdisabled # y;
  FOR vX # 1 loop inc(vX) WHILE (vX<=Skz.Anzahl.Variablen) do begin
    vA # StrChar(64+vX);

    if (false) then begin
      Dlg_Standard:Anzahl('Variable '+vA,var vZ,0,300,400);
      case (vX%3) of
        0 : if (vA5='') then
              vA5 # vA + '='+AInt(vZ)
            else
              vA5 # vA5 +',  '+ vA + '='+AInt(vZ);
        1 : if (vA3='') then
              vA3 # vA + '='+AInt(vZ)
            else
              vA3 # vA3 +',  '+ vA + '='+AInt(vZ);
        2 : if (vA4='') then
              vA4 # vA + '='+AInt(vZ)
            else
              vA4 # vA4 +',  '+ vA + '='+AInt(vZ);
      end;  // case
    end;

    if (true) then begin
      Dlg_Standard:Standard('Variable '+vA,var vWert);
      case (vX%3) of
        0 : if (vA5='') then
              vA5 # vA + '='+vWert;
            else
              vA5 # vA5 +';  '+ vA + '='+vWert;
        1 : if (vA3='') then
              vA3 # vA + '='+vWert;
            else
              vA3 # vA3 +';  '+ vA + '='+vWert;
        2 : if (vA4='') then
              vA4 # vA + '='+vWert;
            else
              vA4 # vA4 +';  '+ vA + '='+vWert;
      end;  // case
    end;

  END;

  gMDI->wpdisabled # n;
  $edAdr.V.Skizzennummer->Winfocusset(false);
  Adr.V.VpgText4 # StrCut(vA3,1,64);
  Adr.V.VpgText5 # StrCut(vA4,1,64)
  Adr.V.VpgText6 # StrCut(vA5,1,64)
  $edAdr.V.VpgText4->WinUpdate(_WinUpdFld2Obj);
  $edAdr.V.VpgText5->WinUpdate(_WinUpdFld2Obj);
  $edAdr.V.VpgText6->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
// TextSave
//              Text abspeichern
//========================================================================
sub TextSave()
local begin
  vTxtHdl   : int;          // Handle des Textes
  vName     : alpha;
end;
begin

  vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;
  $Adr.V.TextEditPos->WinUpdate(_WinUpdObj2Buf);
  vName # cTxtBst;
  if (Adr.V.TextNr1=0) then begin // std Text
    TxtDelete(vName,0)
    vName # '';
  end;

  if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then begin
    TxtDelete(vName,0);
  end
  else begin
    TxtWrite(vTxtHdl,vName, _TextUnlock);
  end;
end;


//========================================================================
// TextLoad
//              Text laden
//========================================================================
sub TextLoad()
local begin
  vTxtHdl     : int;          // Handle des Textes
  vName       : alpha;
end
begin

  if (Adr.V.TextNr2 = 0) then RecBufClear(837);

  vTxtHdl # $Adr.V.TextEditPos->wpdbTextBuf;

//  if (Adr.V.Adressnr>1000000000) then begin
  if (Mode=c_ModeNew) then begin
    vName # cTxtBstTmp;
    if (Adr.V.TextNr1=0) then       // Standardtext
      vName # '~837.'+CnvAI(Adr.V.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  end
  else begin  // vorhandener Verpackung...

//    if ($cb.Text2->wpCheckState = _WinStateChkChecked) then begin
      if (Adr.V.TextNr1=0) then begin // Standardtext
        vName # '~837.'+CnvAI(Adr.V.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
      end;
//    end;

//    if ($cb.Text3->wpCheckState = _WinStateChkChecked) then begin
      if (Adr.V.TextNr1=105) then begin // Idividuell
        vName # cTxtBst;
      end;
//    end;

  end;


  if ($Adr.V.TextEditPos->wpcustom<>vName) or (Mode=c_ModeView) then begin
//todo('lade text '+vname);
    if (StrFind(vName,'~837',0)<>0) then begin
//      Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl, Auf.Sprache);
      Lib_Texte:TxtLoad5Buf(vName, vTxtHdl,0,0,0,0);
    end
    else begin
      if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then begin
        TextClear(vTxtHdl);
      end;
    end;
    $Adr.V.TextEditPos->wpcustom # vName;
    $Adr.V.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
  end;

end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
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
    if (y) then begin
      Auswahl('AnalyseErweitert');
    end;
  end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edAdr.V.Strukturnr') AND (aBuf->Adr.V.Strukturnr<>'')) then begin
    RekLink(220,105,6,0);   // Struktur Nr. holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edAdr.V.Verwiegungsart') AND (aBuf->Adr.V.Verwiegungsart<>0)) then begin
    RekLink(818,105,4,0);   // erweigerungsart holen
    Lib_Guicom2:JumpToWindow('VWa.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edAdr.V.Etikettentyp') AND (aBuf->Adr.V.Etikettentyp<>0)) then begin
    RekLink(840,105,3,0);   // Etikettentyp holen
    Lib_Guicom2:JumpToWindow('Eti.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edAdr.V.Zwischenlage') AND (aBuf->Adr.V.Zwischenlage<>'')) then begin
    ULa.Bezeichnung # Adr.V.Zwischenlage;
    RecRead(838,2,0)
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.Unterlage') AND (aBuf->Adr.V.Unterlage<>'')) then begin
    ULa.Bezeichnung # Adr.V.Unterlage;
    RecRead(838,2,0)
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.Umverpackung') AND (aBuf->Adr.V.Umverpackung<>'')) then begin
    ULa.Bezeichnung # Adr.V.Umverpackung;
    RecRead(838,2,0)
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.Warengruppe') AND (aBuf->Adr.V.Warengruppe<>0)) then begin
    RekLink(819,105,2,0);   // Warerngruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.Guetenstufe') AND (aBuf->"Adr.V.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "Adr.V.Gütenstufe";
    RecRead(838,1,0)
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.Gte') AND (aBuf->"Adr.V.Güte"<>'')) then begin
    "MQu.Güte1" # "Adr.V.Güte";
    RecRead(832,2,0)
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.AusfOben') AND (aBuf->Adr.V.AusfOben<>'')) then begin
    Obf.Bezeichnung.L1 # Adr.V.AusfOben;
    RecRead(841,2,0)
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.AusfUnten') AND (aBuf->Adr.V.AusfUnten<>'')) then begin
    Obf.Bezeichnung.L1 # Adr.V.AusfUnten;
    RecRead(841,2,0)
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.Zeugnisart') AND (aBuf->Adr.V.Zeugnisart<>'')) then begin
    Zeu.Bezeichnung # Adr.V.Zeugnisart;
    RecRead(839,2,0)
    Lib_Guicom2:JumpToWindow('Zeu.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.Erzeuger') AND (aBuf->Adr.V.Erzeuger<>0)) then begin
    RekLink(100,105,8,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.V.Intrastatnr') AND (aBuf->Adr.V.Intrastatnr<>'')) then begin
    MSL.Strukturnr # Adr.V.Intrastatnr;
    RecRead(220,3,0)
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.EinsatzVPG.Adr') AND (aBuf->Adr.V.EinsatzVPG.Adr<>0)) then begin
   // todo('Einsatz')  // ST-> Teschnische weise geht das nicht
   // RekLink(100,105,1,0);   // Einsatz holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.EinsatzVPG.Nr') AND (aBuf->Adr.V.EinsatzVPG.Nr<>0)) then begin
    Adr.Nummer # Adr.V.EinsatzVPG.Nr;
    RecRead(100,1,0)
    Lib_Guicom2:JumpToWindow('Adr.V.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.VorlageBAG') AND (aBuf->Adr.V.VorlageBAG<>0)) then begin
    RekLink(700,105,7,0);   // Vorlage-BAG holen
    Lib_Guicom2:JumpToWindow('BA1.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.Skizzennummer') AND (aBuf->Adr.V.Skizzennummer<>0)) then begin
    RekLink(829,105,5,0);   // Skizze Nr holen
    Lib_Guicom2:JumpToWindow('Skz.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.V.TextNr2') AND (aBuf->Adr.V.TextNr2<>0)) then begin
  todo('Text')
    //RekLink(xxx,xxx,1,0);   // Standard Text holen
    Lib_Guicom2:JumpToWindow('Txt.Verwaltung');
    RETURN;
  end;
  
   
  
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================