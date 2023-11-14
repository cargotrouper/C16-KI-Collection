@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_Inv_Main
//                  OHNE E_R_G
//  Info
//
//
//  12.01.2010  AI  Erstellung der Prozedur
//  11.11.2015  AH  Erweitung für Materialinventur
//  16.12.2015  ST  Materialgewichteingabe in KG
//  14.08.2017  AH  Menü für "nur Material-Inventur"
//  13.10.2017  AH  Mengen sind nicht Pflicht (d.h. Sätze OHNE Menge werden nicht übernommen und als nicht existent angesehen)
//  25.10.2017  AH  AFX: "Art.Inv.RefreshIfm.Post"
//  03.01.2018  AH  AFX: "Art.Inv.EvtLstDataInit"
//  24.04.2019  ST  "cListen" und "w_list" hinzufefügt
//  13.05.2019  ST  Import/Export freigeschaltet
//  04.04.2022  AH  ERX
//  13.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAdresse()
//    SUB AusAnschrift()
//    SUB AusArtikel()
//    SUB AusCharge()
//    SUB AusMaterial()
//    SUB AusLagerplatz()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB _Uebernahme_Charge();
//    SUB Uebernahme_Einzel(aDat : date);
//    SUB Uebernahme_Alle(aDat : date);
//    SUB Loesche_Alle(aDat : date)
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Inventur'
  cFile       :  259
  cMenuName   : 'Art.Inv.Bearbeiten'
  cPrefix     : 'Art_Inv'
  cZList      : $ZL.Art.Inventur
  cKey        : 1
  cListen     : 'Inventur'
end;


local begin
  vAllgemein  : logic;    // Übergabe von START and EVTINIT
end;

//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(aAllgemein : logic) : logic;
local begin
  vHdl  : int;
end;
begin

  vAllgemein # aAllgemein;

  if (aAllgemein) then begin
    if (gMdiArt<>0) then RETURN false;
    RecBufClear(259);
//    gMdiArt # Lib_GuiCom:AddChildWindow(gFrmMain,'Art.Inv.Verwaltung','',true);
//    Lib_GuiCom:RunChildWindow(gMdiArt);
    gMdiArt # Lib_GuiCom:OpenMDI(gFrmMain,'Art.Inv.Verwaltung', _WinAddHidden);
    gMdiArt->WinUpdate(_WinUpdOn);
  end
  else begin
    RecBufClear(259);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Inv.Verwaltung','',false);
    Lib_GuiCom:RunChildWindow(gMDI);
  end;

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
  gTitle      # Translate(cTitle);
  gFile       # cFile;
  gMenuName   # cMenuName;
  gPrefix     # cPrefix;
  gZLList     # cZList;
  gKey        # cKey;
  w_NoClrList # true;   // Neuanlage leert nicht die Felder!!!
  w_Listen    # cListen;

  Lib_Guicom2:Underline($edArt.Inv.Adressnr);
  Lib_Guicom2:Underline($edArt.Inv.Anschrift);
  Lib_Guicom2:Underline($edArt.Inv.Artikelnr);
  Lib_Guicom2:Underline($edArt.Inv.Charge.Int);
  Lib_Guicom2:Underline($edArt.Inv.Materialnr);
  Lib_Guicom2:Underline($edArt.Inv.Lagerplatz);


  SetStdAusFeld('edArt.Inv.Charge.Int','Charge');
  SetStdAusFeld('edArt.Inv.Artikelnr','Artikel');
  SetStdAusFeld('edArt.Inv.Materialnr','Material');
  SetStdAusFeld('edArt.Inv.Lagerplatz','Lagerplatz');
  SetStdAusFeld('edArt.Inv.Adressnr','Adresse');
  SetStdAusFeld('edArt.Inv.Anschrift','Anschrift');

  if (vAllgemein) then begin
  end
  else begin
    gZLList->wpDbLinkfileno         # 259;
    gZLList->wpDbKeyNo              # 21;
    gZLList->wpDbFileNo             # 250;
    $edArt.Inv.Artikelnr->wpCustom  # '_N';
  end;

  RunAFX('Art.Inv.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
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
  Lib_GuiCom:Pflichtfeld($edArt.Inv.Adressnr);
  Lib_GuiCom:Pflichtfeld($edArt.Inv.Anschrift);
// 13.10.2017 A
//  Lib_GuiCom:Pflichtfeld($edArt.Inv.Stckzahl);
//  Lib_GuiCom:Pflichtfeld($edArt.Inv.Menge);
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
  Erx     : int;
  vHdl    : int;
  vA      : alpha(200);
  vIstArt : logic;
end;
begin

  if (Mode<>c_ModeNew) and ((Art.Inv.Materialnr<>0) or (Art.Inv.Charge.Int<>'')) then begin
    $edArt.Inv.Materialnr->wpcustom # '_E';
    $bt.Material->wpcustom # '_E';
    $edArt.Inv.Charge.Int->wpcustom # '_E';
    $bt.Charge->wpcustom # '_E';
  end
  else begin
    $edArt.Inv.Materialnr->wpcustom # '';
    $bt.Material->wpcustom # '';
    $edArt.Inv.Charge.Int->wpcustom # '';
    $bt.Charge->wpcustom # '';
  end;


  // ÜBERNAHMEN ----------------------------------------------------------
  if (aName='edArt.Inv.Adressnr') and ((aChanged) or ($edArt.Inv.Adressnr->wpchanged)) then begin
    Art.Inv.Anschrift   # 1;
    $edArt.Inv.Anschrift->WinUpdate(_WinUpdFld2Obj);
  end
  else if (aName='edArt.Inv.Artikelnr') and ((aChanged) or ($edArt.Inv.Artikelnr->wpchanged)) then begin
    Erx # Reklink(250,259,1,_recFirst);     // Artikel holen
    Art.Inv.Charge.Int  # '';
    Art.Inv.Materialnr  # 0;
    Art.Inv.MEH         # Art.MEH;
    $edArt.Inv.Charge.Int->WinUpdate(_WinUpdFld2Obj);
    $edArt.Inv.Materialnr->WinUpdate(_WinUpdFld2Obj);
    $lb.MEH->WinUpdate(_WinUpdFld2Obj);
  end
  else if (aName='edArt.Inv.Charge.Int') and ((aChanged) or ($edArt.Inv.Charge.Int->wpchanged)) then begin
    Erx # RekLink(252,259,2,_recFirst);     // Charge holen
    Art.Inv.Materialnr  # 0;
    Art.Inv.Adressnr    # Art.C.Adressnr;
    Art.Inv.Anschrift   # Art.C.Anschriftnr;
    $edArt.Inv.Materialnr->WinUpdate(_WinUpdFld2Obj);
    $edArt.Inv.Adressnr->WinUpdate(_WinUpdFld2Obj);
    $edArt.Inv.Anschrift->WinUpdate(_WinUpdFld2Obj);
  end
  else if (aName='edArt.Inv.Materialnr') and ((aChanged) or ($edArt.Inv.Materialnr->wpchanged)) then begin
    Art.Inv.Charge.Int  # '';
    RecBufClear(200);
    if (Art.Inv.Materialnr<>0) then begin
      Erx # Mat_Data:Read(Art.Inv.Materialnr);  // Material holen
    end;
    Art.Inv.Adressnr    # Mat.Lageradresse;
    Art.Inv.Anschrift   # Mat.Lageranschrift;
    Art.Inv.MEH         # Mat.MEH;
    Art.Inv.MEH         # 'kg';       // ST 2015-12-16

    Erx # RecLink(819,200,1,0);                 // Warengruppe holen
    if (Wgr_Data:IstMix()) then begin
      Art.Inv.Artikelnr # Mat.Strukturnr;
      aName # '';
    end;
    $edArt.Inv.Artikelnr->WinUpdate(_WinUpdFld2Obj);
    $edArt.Inv.Adressnr->WinUpdate(_WinUpdFld2Obj);
    $edArt.Inv.Anschrift->WinUpdate(_WinUpdFld2Obj);
    $lb.MEH->WinUpdate(_WinUpdFld2Obj);
  end;


  // ANZEIGEN -----------------------------------------------------------
  if (aName='') or (aName='edArt.Inv.Adressnr') or (aName='edArt.Inv.Anschrift') then begin
    RecBufClear(101);
    Erx # RecLink(100,259,4,_RecFirst);     // Adresse holen
    if (Erx>_rLocked) or (Art.Inv.Adressnr=0) then RecBufClear(100)
    else begin
      Erx # RecLink(101,259,3,_RecFirst);   // Anschrift holen
      if (Erx>_rLocked) then RecBufClear(101);
    end;
    $Lb.Lagerort->wpcaption       # Adr.Stichwort;
    $Lb.Lageranschrift->wpcaption # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
    $lb.MEH->WinUpdate(_WinUpdFld2Obj);
  end;
  if (aName='') or ((aName='edArt.Inv.Artikelnr') and ((aChanged) or ($edArt.Inv.Artikelnr->wpchanged))) then begin
    Erx # Reklink(250,259,1,_recFirst);   // Artikel holen
    Erx # Reklink(819,250,10,_RecFirst);  // Warengruppe holen
    vIstArt # Wgr_Data:IstArt();
    if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then begin
      Lib_GuiCom:Able($edArt.Inv.Charge.Int, vIstArt and (Wgr.OhneBestandYN=false));
      Lib_GuiCom:Able($bt.Charge, vIstArt and (Wgr.OhneBestandYN=false));
      Lib_GuiCom:Able($edArt.Inv.Materialnr, (vIstArt=false) and (Wgr.OhneBestandYN=false));
      Lib_GuiCom:Able($bt.Material, (vIstArt=false) and (Wgr.OhneBestandYN=false));
    end;
    $lb.Artikel->wpCaption # Art.Stichwort;
  end;
  if (aName='') or (aName='edArt.Inv.Artikelnr') or (aName='edArt.Inv.Charge.Int') or (aName='edArt.Inv.Materialnr') then begin
    if (Art.Inv.Materialnr<>0) then begin
      Erx # Mat_Data:Read(Art.Inv.Materialnr);
      if (Erx>=200) then begin
        vA # "Mat.Güte";
        vA # vA + ', ' + ANum(Mat.Dicke, Set.Stellen.Dicke);
        vA # vA + ' x ' + ANum(Mat.Breite, Set.Stellen.Breite);
        if ("Mat.Länge"<>0.0) then
          vA # vA + ' x ' + ANum("Mat.Länge", "Set.Stellen.Länge");
      end;
    end
    else if(Art.Inv.Charge.int<>'') then begin
      Erx # RecLink(252,259,2,_recFirst);   // Charge holen
      if (Erx<=_rLocked) then begin
        vA # ANum(Art.C.Dicke, Set.Stellen.Dicke);
        vA # vA + ' x ' + ANum(Art.C.Breite, Set.Stellen.Breite);
        if ("Art.C.Länge"<>0.0) then
          vA # vA + ' x ' + ANum("Art.C.Länge", "Set.Stellen.Länge");
      end;
    end
    else if (Art.Inv.Artikelnr<>'') then begin
      Erx # Reklink(250,259,1,_recFirst);   // Artikel holen
      if (Erx<=_rLockeD) then begin
        vA # ANum(Art.Dicke, Set.Stellen.Dicke);
        vA # vA + ' x ' + ANum(Art.Breite, Set.Stellen.Breite);
        if ("Art.Länge"<>0.0) then
          vA # vA + ' x ' + ANum("Art.Länge", "Set.Stellen.Länge");
      end;
    end;

    $lb.Abmessung->wpcaption # vA;
  end;



  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

  if (aChanged) then
    RunAFX('Art.Inv.RefreshIfm.Post','Y|'+aName)
  else
    RunAFX('Art.Inv.RefreshIfm.Post','N|'+aName)
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vAdr  : int;
  vAns  : int;
end;
begin

  $edArt.Inv.Charge.Int->wpreadonly # y;
  $edArt.Inv.Materialnr->wpreadonly # y;

  if (Mode=c_ModeNew) then begin
    vAdr # Art.Inv.Adressnr;
    vAns # Art.Inv.Anschrift;
    // Vorbelegung
//    if (gZLList->wpdbRecid<>0) then begin
//    end;
    RecBufClear(259);
    Art.Inv.Adressnr  # vAdr;
    Art.Inv.Anschrift # vAns;


    // aus Artikel?
    if (gZLList->wpDbLinkFileNo=259) then begin
      Art.Inv.Artikelnr # Art.Nummer;
      Art.Inv.MEH       # Art.MEH;
      // Focus setzen auf Feld:
      $edArt.Inv.Charge.Int->WinFocusSet(true);
    end
    else begin
      Art.Inv.MEH       # 'kg';
      $edArt.Inv.Artikelnr->WinFocusSet(true);
    end;
  end
  else begin  // Edit
    if (Art.Inv.Materialnr<>0) or (Art.Inv.Charge.Int<>'') then begin
//      Lib_GuiCom:Disable($edArt.Inv.Charge.Int);
  //    Lib_GuiCom:Disable($bt.Charge);
    //  Lib_GuiCom:Disable($edArt.Inv.Materialnr);
      //Lib_GuiCom:Disable($bt.Material);
    end;

    $edArt.Inv.Stckzahl->WinFocusSet(true);
  end;

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


  // Pflichtfelder
  If (Art.Inv.Adressnr=0) then begin
    Lib_Guicom2:InhaltFehlt('Lageradresse', 'NB.Page1', 'edArt.Inv.Adressnr');
    RETURN false;
  end;
  Erx # RecLink(100,259,4,_RecFirst);     // Adresse holen
  if (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Lageradresse', 'NB.Page1', 'edArt.Inv.Adressnr');
    RETURN false;
  end;

  If (Art.Inv.Anschrift=0) then begin
    Lib_Guicom2:InhaltFehlt('Lageradresse', 'NB.Page1', 'edArt.Inv.Anschrift');
    RETURN false;
  end;
  Erx # RecLink(101,259,3,_recFirst);   // Anschrift holen
  if (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Lageradresse', 'NB.Page1', 'edArt.Inv.Anschrift');
    RETURN false;
  end;


  // Material-Inventur?
  if (Art.Inv.Artikelnr='') then begin
    if (Art.Inv.Materialnr=0) then begin
      Lib_Guicom2:InhaltFehlt('Material', 'NB.Page1', 'edArt.Inv.Materialnr');
      RETURN false;
    end;
    Erx # Mat_Data:read(Art.Inv.Materialnr);    // Material holen
    if (Erx<200) then begin
      Lib_Guicom2:InhaltFalsch('Material', 'NB.Page1', 'edArt.Inv.Materialnr');
      RETURN false;
    end;
  end
  else begin  // sonst Artikel-Inventur
    Erx # RecLink(250,259,1,_recFirst);   // Artikel holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Artikel', 'NB.Page1', 'edArt.Inv.Artikelnr');
      RETURN false;
    end;

    // Charge angegeben?
    if (Art.Inv.Charge.Int<>'') then begin
      Erx # RecLink(252,259,2,_recFirst);   // Charge holen
      if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Charge', 'NB.Page1', 'edArt.Inv.Charge.Int');
        RETURN false;
      end;
    end
    // oder Material angegeben=
    else if (Art.Inv.Materialnr<>0) then begin
      Erx # Mat_Data:read(Art.Inv.Materialnr);    // Material holen
      if (Erx<200) or (Mat.Strukturnr<>Art.Inv.Artikelnr) then begin
        Lib_Guicom2:InhaltFalsch('Material', 'NB.Page1', 'edArt.Inv.Material');
        RETURN false;
      end;

    end;
  end;
/** 13.10.2017 AH
  if ("Art.Inv.Stückzahl"=0) then begin
    Lib_Guicom2:InhaltFehlt('Stückzahl', 'NB.Page1', 'edArt.Inv.Stckzahl');
    RETURN false;
  end;

  if (Art.Inv.Menge=0.0) then begin
    Lib_Guicom2:InhaltFehlt('Menge', 'NB.Page1', 'edArt.Inv.Menge');
    RETURN false;
  end;
***/

//  if (Art.Inv.Charge.int='') then begin
//    Art.Inv.Adressnr  # Set.EigeneAdressnr;
//    Art.Inv.Anschrift # 1;
//  end;


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
    Art.Inv.Anlage.Datum  # Today;
    Art.Inv.Anlage.Zeit   # Now;
    Art.Inv.Anlage.User   # gUserName;

    Art.Inv.Nummer        # Lib_Nummern:ReadNummer('INVENTUR');
    if (Art.Inv.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;
    RekInsert(gFile,0,'MAN');
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
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
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
  Erx : int;
end;
begin

  if (aEvt:Obj=$edArt.Inv.Artikelnr) and (Art.Inv.Artikelnr<>'') then begin
    Erx # RecLink(250,259,1,_recFirst);   // Artikel holen
    if (Erx>_rLocked) then RETURN false;
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
  vFilter : int;
  vHdl    : int;
  vQ      : alpha(4000);
end;
begin

  case aBereich of

    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Anschrift' : begin
      Erx # RecLink(100,259,4,_RecFirst);     // Adresse holen
      if (Erx>_rLocked) then RETURN;
      RecBufClear(101);                     // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusAnschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Art.Inv.Adressnr);
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


    'Artikel' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Charge' : begin
      RecBufClear(252);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusCharge');

      Erx # Reclink(250,259,1,_recFirst);   // Artikel holen
      if (Erx>_rLocked) then RETURN;

      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
      if (Art.Inv.Adressnr=0) then begin
        Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      end
      else begin
        Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '=', Art.Inv.Adressnr);
      end;
      if (Art.Inv.Anschrift<>0) then begin
        Lib_Sel:QInt(var vQ, 'Art.C.Anschriftnr'      , '=', Art.Inv.Anschrift);
      end;

      // Echte Charge auswählen?
      if ("Art.ChargenführungYN") then begin
      end
      else begin  // nur Lagerortchargen...
        Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
        //Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
// ST 2011-12-19: Auch interne Chargen auswählbar lassen Laut Knappstein 1354/45
//        Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '=', '');
      end;

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      //Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;


      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Material' : begin
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');

      vQ # '';
      if (Art.Inv.Artikelnr<>'') then
        Lib_Sel:QAlpha( var vQ, 'Mat.Strukturnr', '=', Art.Inv.Artikelnr);

      if (Art.Inv.Adressnr=0) then begin
      end
      else begin
        Lib_Sel:QInt(var vQ, 'Mat.Lageradresse'       , '=', Art.Inv.Adressnr);
      end;
      if (Art.Inv.Anschrift<>0) then begin
        Lib_Sel:QInt(var vQ, 'Mat.Lageranschrift'     , '=', Art.Inv.Anschrift);
      end;
      if (vQ<>'') then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vHdl # SelCreate(200, gKey);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        gZLList->wpDbSelection # vHdl;
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lagerplatz' : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;  // ...case

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.Inv.Adressnr  # Adr.Nummer;
//    Art.Inv.Anschrift # 1;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl <> 0) then
      vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edArt.Inv.Adressnr->Winfocusset(false);
//  RefreshIfm('edAuf.Lieferadresse');
//  $edArt.Inv.Anschrift->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edArt.Inv.Adressnr', true);
end;


//========================================================================
//  AusAnschrift
//
//========================================================================
sub AusAnschrift()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.Inv.Anschrift # Adr.A.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edArt.Inv.Anschrift->Winfocusset(false);
//  RefreshIfm('edAuf.Lieferanschrift');
  RefreshIfm('edArt.Inv.Anschrif', true);
end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.Inv.Artikelnr # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Inv.Artikelnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.Inv.Artikelnr', true);
end;


//========================================================================
//  AusCharge
//
//========================================================================
sub AusCharge()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
//    Art.Inv.Materialnr  # 0;
    Art.Inv.Charge.Int  # Art.C.Charge.Intern;
//    Art.Inv.Adressnr    # Art.C.Adressnr;
//    Art.Inv.Anschrift   # Art.C.Anschriftnr;
//    RecLink(100,259,4,_RecFirst);   // Adresse holen
//    RecLink(101,259,3,_RecFirst);   // Anschrift holen
//    $Lb.Lagerort->wpcaption       # Adr.Stichwort;
//    $Lb.Lageranschrift->wpcaption # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
//    $LbLageradresse->wpcaption    # AInt(Art.Inv.Adressnr);
//    $LbLageranschr->wpcaption     # AINt(Art.Inv.Anschrift);
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);

    $edArt.Inv.Stckzahl->Winfocusset(false);
    RefreshIfm('edArt.Inv.Charge.Int', true);
  end
  else begin
    $edArt.Inv.Charge.Int->Winfocusset(false);
  end;
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.Inv.Materialnr  # Mat.Nummer;
//    Art.Inv.Adressnr    # Mat.Lageradresse;
//    Art.Inv.Anschrift   # Mat.Lageranschrift;
//    Art.Inv.Charge.Int  # '';
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Inv.Materialnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.Inv.Materialnr', true);
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.Inv.Lagerplatz  # Lpl.Lagerplatz;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.Inv.Lagerplatz->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl    : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Inv_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Inv_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Inv_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Inv_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Inv_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Inv_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Inventur');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView));// or
    //                  (Rechte[Rgt_Mat_Inventur]=n);
  vHdl # gMenu->WinSearch('Mnu.Inv.DelohneInv');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView));
//                      (Rechte[Rgt_Art_Inv_Uebernahme]=n);


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);
    
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
  vMenge  : float;
  vStk    : int;
  vGew    : float;
  vDat    : date;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Inv.Material' : begin
      If (Msg(200028,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      if (Dlg_Standard:Datum(Translate('Inventurdatum'),var vDat, today)=false) then RETURN false;
      if (Art_Inv_Subs:Uebernehme_PuresMat(vDat)) then begin
        Msg(999998,'',0,0,0);
      end
      else begin
        Msg(999999,'',0,0,0);
        ErrorOutput;
      end;
    end;


    'Mnu.Inv.DelohneInv' : begin
      If (Msg(200029,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinIdYes) then RETURN false;
      if (Dlg_Standard:Datum(Translate('Inventurdatum'),var vDat, today)=false) then RETURN false;
      if (Art_Inv_Subs:Loesche_Verlorene_PuresMat(vDat)) then begin
        Msg(999998,'',0,0,0);
      end
      else begin
        Msg(999999,'',0,0,0);
        ErrorOutput;
      end;
    end;


    'Mnu.Ktx.Errechnen' : begin
      Erx # RecLink(252,259,2,_recFirst);   // Charge holen
      if (Erx>_rLocked) then RETURN false;

      vMenge  # Art.Inv.Menge;
      vStk    # "Art.Inv.Stückzahl";
      vGew    # 0.0;
      //vGew # Lib_Einheiten:WandleMEH(252, vStk, 0.0, vMenge, Art.MEH, 'kg');
      if (aEvt:Obj->wpname='edArt.Inv.Stckzahl') then begin
        vStk    # cnvif(Lib_Einheiten:WandleMEH(252, 0, vGew, vMenge, Art.MEH, 'Stk'));
        vHdl    # $edArt.Inv.Stckzahl;
      end;
      if (aEvt:Obj->wpname='edArt.Inv.Menge') then begin
        vMenge  # Lib_Einheiten:WandleMEH(252, vStk, vGew, 0.0, '', Art.MEH);
        vHdl    # $edArt.Inv.Menge;
      end;
      Art.Inv.Menge       # vMenge;
      "Art.Inv.Stückzahl" # vStk;
      $edArt.Inv.Menge->winupdate(_WinUpdFld2Obj);
      $edArt.Inv.Stckzahl->winupdate( _WinUpdFld2Obj);
      if (vHdl<>0) then Winfocusset(vHdl, true);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Art.Inv.Anlage.Datum, Art.Inv.Anlage.Zeit, Art.Inv.Anlage.User);
    end;

  end; // ...case


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
    'bt.Adresse' :      Auswahl('Adresse');
    'bt.Anschrift' :    Auswahl('Anschrift');
    'bt.Artikel' :      Auswahl('Artikel');
    'bt.Charge' :       Auswahl('Charge');
    'bt.Material' :     Auswahl('Material');
    'bt.Lagerplatz' :   Auswahl('Lagerplatz');
  end;  // ...case

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
  Erx       : int;
  vTyp      : alpha;
  vCell     : int;
  vCol      : int;
end;
begin

  // Sonderfunktion:
  if (aMark) then begin
    if (RunAFX('Art.Inv.EvtLstDataInit','y')<0) then RETURN;
  end
  else begin
    if (RunAFX('Art.Inv.EvtLstDataInit','n')<0) then RETURN;
  end;


  Erx # RekLink(101,259,3,_recFirst);   // Anschrift holen
  vCol # RGB(255,128,128);

  if (Art.Inv.Charge.Int='') and (Art.Inv.Materialnr=0) then begin

    if (Art.Inv.Artikelnr='') then vTyp # 'MAT'
    else begin
      Erx # Reklink(250,259,1,_recFirst);   // Artikel holen
      Erx # Reklink(819,250,10,_RecFirst);  // Warengruppe holen
      if (Wgr_Data:IstArt()) then begin
        if (Wgr.OhneBestandYN) then vTyp # ''
        else vTyp # 'CHARGE';
      end
      else begin
        vTyp # 'MAT';
      end;
    end;

    if (vTyp='MAT') then          vCell # $clmArt.Inv.Materialnr
    else if (vTyp='CHARGE') then  vCell # $clmArt.Inv.Charge.Int;

    if (vCell<>0) then begin
      vCell->wpClmColBkg         # vCol;
      vCell->wpClmColFocusBkg    # vCol;
      vCell->wpClmColFocusOffBkg # vCol;
    end;
  end;


  // wenn Mengen fehlen:
  if ("Art.Inv.Stückzahl"=0) and (Art.Inv.Menge=0.0) then begin
    vCell  # $clmArt.Inv.Stckzahl;
    vCell->wpClmColBkg         # vCol;
    vCell->wpClmColFocusBkg    # vCol;
    vCell->wpClmColFocusOffBkg # vCol;
    vCell  # $clmArt.Inv.Menge;
    vCell->wpClmColBkg         # vCol;
    vCell->wpClmColFocusBkg    # vCol;
    vCell->wpClmColFocusOffBkg # vCol;
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//  EvtChanged
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vOK   : logic;
end;
begin

  $edArt.Inv.Artikelnr->Winupdate(_WinUpdObj2Fld);
  Refreshifm('');
//  Refreshifm('edArt.Inv.Artikelnr',true);
/***
  vOK # true;
  if (aEvt:Obj=$edArt.Inv.Artikelnr) and (Art.Inv.Artikelnr<>'') then begin
    Erx # RecLink(250,259,1,_recFirst);   // Artikel holen
    if (Erx>_rLocked) then RETURN false;
    if (vObj<>0) then begin
      Erx # ReKlink(819,250,10,_RecFirst);  // Warengruppe holen
      if (aFocusObject->wpname='edArt.Inv.Charge.Int') and (Wgr_Data:IstArt()=false) then begin
        $edArt.Inv.Materialnr->winfocusset(false);
        vOK # false;
      end
      else if (aFocusObject->wpname='edArt.Inv.Materialnr') and (Wgr_Data:IstArt()) then begin
        $edArt.Inv.Charge.Int->winfocusset(false);
        vOK # false;
      end;
    end;
  end;
***/

  RETURN(true);
end;

sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edArt.Inv.Adressnr') AND (aBuf->Art.Inv.Adressnr<>0)) then begin
    RekLink(100,259,4,0);   // Lageradresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Inv.Anschrift') AND (aBuf->Art.Inv.Anschrift<>1)) then begin
  //  RecLink(101,259,4,0);
    Adr.A.Adressnr # Art.Inv.Adressnr;
    Adr.A.Nummer # Art.Inv.Anschrift;
    RecRead(101,1,0);
    
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Art.Inv.Adressnr);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edArt.Inv.Artikelnr') AND (aBuf->Art.Inv.Artikelnr<>'')) then begin
    RekLink(250,259,1,0);   // Artikel holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edArt.Inv.Charge.Int') AND (aBuf->Art.Inv.Charge.Int<>'')) then begin
    RekLink(252,259,2,0);   // int.Charge holen
    Lib_Guicom2:JumpToWindow('Art.C.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edArt.Inv.Materialnr') AND (aBuf->Art.Inv.Materialnr<>0)) then begin
    RekLink(200,259,5,0);   // Materialnr. holen
    Lib_Guicom2:JumpToWindow('Mat.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edArt.Inv.Lagerplatz') AND (aBuf->Art.Inv.Lagerplatz<>'')) then begin
    RekLink(844,259,7,0);   // Lagerplatz holen
    Lib_Guicom2:JumpToWindow('Mat.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================