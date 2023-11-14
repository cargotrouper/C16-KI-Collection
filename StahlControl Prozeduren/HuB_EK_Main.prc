
@A+
//==== Business-Control ==================================================
//
//  Prozedur    HuB_EK_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  28.10.2013  ST  Setzen udn Endfernen des Löschmarkers hinzugefügt (Projekt 1455/45)
//  08.06.2016  AH  Ansprechparnter nur dieses Lieferanten
//  09.06.2022  AH  ERX
//  22.07.2022  HA  Quick Jump
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
//    SUB AusSachbearbeiter()
//    SUB AusLieferant()
//    SUB AusAnsprechpartner()
//    SUB AusWaehrung()
//    SUB AusLieferbed()
//    SUB AusZahlungsbed()
//    SUB AusVersandart()
//    SUB AusPositionen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Lib_Nummern

define begin
  cTitle :    'Einkauf: Hilfs- und Betriebsstoffe'
  cFile :     190
  cMenuName : 'HuB.EK.Bearbeiten'
  cPrefix :   'HuB_EK'
  cZList :    $ZL.HuB.EK
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

Lib_Guicom2:Underline($edHuB.EK.Sachbearb);
Lib_Guicom2:Underline($edHuB.EK.Lieferant);
Lib_Guicom2:Underline($edHuB.EK.LieferSachb);
Lib_Guicom2:Underline($edHuB.EK.Waehrung);
Lib_Guicom2:Underline($edHuB.EK.Lieferbed);
Lib_Guicom2:Underline($edHuB.EK.Zahlungsbed);
Lib_Guicom2:Underline($edHuB.EK.Versandart);


  SetStdAusFeld('edHuB.EK.Sachbearb'   ,'Sachbearbeiter');
  SetStdAusFeld('edHuB.EK.LieferSachb' ,'Ansprechpartner');
  SetStdAusFeld('edHuB.EK.Lieferant'   ,'Lieferant');
  SetStdAusFeld('edHuB.EK.Lieferbed'   ,'Lieferbed');
  SetStdAusFeld('edHuB.EK.Zahlungsbed' ,'Zahlungsbed');
  SetStdAusFeld('edHuB.EK.Versandart'  ,'Versandart');
  SetStdAusFeld('edHuB.EK.Sprache'     ,'Sprache');
  SetStdAusFeld('edHuB.EK.Waehrung'    ,'Waehrung');

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
  vHdl  : int;
end;
begin

  if (aName='edHuB.EK.Lieferant') and ($edHuB.EK.Lieferant->wpchanged) then begin
    Erx # RecLink(100,190,2,0);
    if (Erx<=_rLocked) and (HuB.Ek.Lieferant<>0) then begin
      HuB.EK.LieferStichw # Adr.Stichwort;
      "HuB.EK.Währung" # "Adr.EK.Währung";
      HuB.EK.Lieferbed # Adr.EK.Lieferbed;
      HuB.EK.Zahlungsbed # Adr.EK.ZAhlungsbed;
      HUB.EK.Versandart # Adr.EK.Versandart;
      HUB.EK.Sprache # Adr.Sprache;
      HUB.EK.LieferSachb # '';
      end
    else begin
      HuB.EK.LieferStichw # '';
      "HuB.EK.Währung" # 0;
      "HuB.EK.Währungskurs" # 0.0;
      HuB.EK.Lieferbed # 0;
      HuB.EK.Zahlungsbed # 0;
      HUB.EK.Versandart # 0;
      HUB.EK.Sprache # '';
      HUB.EK.LieferSachb # '';
    end;
    RefreshIfm('edHuB.EK.Waehrung');
    RefreshIfm('edHuB.EK.Lieferbed');
    RefreshIfm('edHuB.EK.Zahlungsbed');
    RefreshIfm('edHuB.EK.Versandart');
    RefreshIfm('edHuB.EK.Sprache');
    RefreshIfm('edHuB.EK.LieferSachb');
  end;

  if (aName='') or (aName='edHuB.EK.Lieferant') then begin
    Erx # RecLink(100,190,2,0);
    if (Erx<=_rLocked) and (HuB.Ek.Lieferant<>0) then begin
      $Lb.Lieferant->wpcaption # HuB.EK.LieferStichw;
//      $Lb.Lieferant->wpcaption # Adr.Stichwort;
      $Lb.Lieferant2->wpcaption # Adr.Name+', '+Adr.Ort;
      end
    else begin
      $Lb.Lieferant->wpcaption # '';
      $Lb.Lieferant2->wpcaption # '';
    end;
  end;


  if (aName='') or (aName='edHuB.EK.Zahlungsbed') then begin
    Erx # RecLink(816,190,4,0);
    if (Erx<=_rLocked) then
      $Lb.Zahlungsbed->wpcaption # ZaB.Kurzbezeichnung
    else
      $Lb.Zahlungsbed->wpcaption # '';
  end;
  if (aName='') or (aName='edHuB.EK.Lieferbed') then begin
    Erx # RecLink(815,190,5,0);
    if (Erx<=_rLocked) then
      $Lb.Lieferbed->wpcaption # Lib.Bezeichnung.L1
    else
      $Lb.Lieferbed->wpcaption # '';
  end;
  if (aName='') or (aName='edHuB.EK.Versandart') then begin
    Erx # RecLink(817,190,6,0);
    if (Erx<=_rLocked) then
      $Lb.Versandart->wpcaption # Vsa.Bezeichnung.L1
    else
      $Lb.Versandart->wpcaption # '';
  end;
  if (aName='') or (aName='edHuB.EK.Waehrung') then begin
    Erx # RecLink(814,190,3,0);
    if (Erx<=_rLocked) then
      $Lb.Waehrung->wpcaption # Wae.Bezeichnung
    else
      $Lb.Waehrung->wpcaption # '';
  end;
  if (aName='edHuB.EK.Waehrung') and ($edHub.EK.Waehrung->wpchanged) then begin
    Erx # RecLink(814,190,3,0);
    if (Erx<=_rLocked) and ("HuB.EK.WährungFixYN"=y) then
      "HuB.EK.Währungskurs" # Wae.EK.Kurs;
    else
      "HuB.EK.Währungskurs" # 0.0;
    RefreshIfm('edHuB.EK.Waehrungskurs');
  end;

  if (aName='') then begin
    $lb.Nummer->wpcaption # AInt(HuB.EK.Nummer);
    $lb.Datum->wpcaption # CnvAD(HuB.EK.Datum);
  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
//  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
//    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
//   Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  HuB.EK.Sachbearb # Userinfo(_Username, cnvIA(UserInfo(_UserCurrent)));
  HuB.EK.Datum # sysdate();
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edHuB.EK.Lieferant->WinFocusSet(true);

  if ("HuB.EK.WährungFixYN") then begin
    Lib_GuiCom:Enable($edHuB.EK.Waehrungskurs);
    end
  else begin
    Lib_GuiCom:Disable($edHuB.EK.Waehrungskurs);
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

  // logische Prüfung
  // Nummernvergabe
  if (Mode=c_ModeNew) then begin
    TRANSON;
    HuB.EK.Nummer # ReadNummer('HuB-Bestellung');
    SaveNummer();
  end;

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
    Hub.EK.Anlage.Datum  # Today;
    Hub.EK.Anlage.Zeit   # Now;
    Hub.EK.Anlage.User   # gUsername;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;
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
//  RekDelete(gFile,0,'MAN');
  if ("HuB.EK.Löschmarker"='') then begin

    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      TRANSON;
      RecRead(190,1,_recLock);
      "HuB.EK.Löschmarker" # '*';
      Erx # RekReplace(190,_recUnlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,Translate(gTitle),0,0,0);
        RETURN;
      end;
      TRANSOFF;
    end;

    end
  else begin

    if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      TRANSON;
      RecRead(190,1,_recLock);
      "HuB.EK.Löschmarker" # '';
      Erx # RekReplace(190,_recUnlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,Translate(gTitle),0,0,0);
        RETURN;
      end;
      TRANSOFF;
    end;

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

  if (aEvt:Obj->wpName='cbHuB.EK.WaehrungFixYN') then begin
    if ("HuB.EK.WährungFixYN"=n) then begin
      "HuB.EK.Währungskurs" # 0.0;
//      $edHuB.EK.Waehrungskurs->wpCaptionFloat # 0.0;
      Refreshifm('edHuB.EK.Waehrungskurs')
    end;
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
  vHdl      : int;
  vHdl2     : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
end;

begin

  case aBereich of
    'Lieferant' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','HuB_EK_Main:AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Sachbearbeiter' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung','HuB_EK_Main:AusSachbearbeiter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Ansprechpartner' : begin
      Erx # RekLink(100,190,2,0);   // Lieferant holen
      RecBufClear(102);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung','HuB_EK_Main:AusAnsprechpartner');

      if (Adr.Nummer<>0) then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        // Selektion aufbauen...
        vQ # '';
        Lib_Sel:QInt(var vQ, 'Adr.P.Adressnr'  , '=', Adr.Nummer);
        vHdl # SelCreate(102, gKey);
        Erx  # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);

        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Waehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung','HuB_EK_Main:AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferbed' : begin
      RecBufClear(815);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LiB.Verwaltung','HuB_EK_Main:AusLieferbed');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zahlungsbed' : begin
      RecBufClear(816);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zab.Verwaltung','HuB_EK_Main:AusZahlungsbed');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Versandart' : begin
      RecBufClear(817);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VsA.Verwaltung','HuB_EK_Main:AusVersandart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Sprache' : begin
      Lib_Einheiten:Popup('Sprache',$edHuB.EK.Sprache,190,1,15);
    end;

  end;

end;


//========================================================================
//  AusSachbearbeiter
//
//========================================================================
sub AusSachbearbeiter()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    HuB.EK.Sachbearb # Usr.Username;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();
  // Focus auf Editfeld setzen:
  $edHuB.EK.Sachbearb->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
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
    HuB.EK.Lieferant # Adr.Lieferantennr;
    HuB.EK.LieferStichw # Adr.Stichwort;
    "HuB.EK.Währung" # "Adr.EK.Währung";
    HuB.EK.Lieferbed # Adr.EK.Lieferbed;
    HuB.EK.Zahlungsbed # Adr.EK.ZAhlungsbed;
    HUB.EK.Versandart # Adr.EK.Versandart;
    HUB.EK.Sprache # Adr.Sprache;
    HUB.EK.LieferSachb # '';
    gSelected # 0;

    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.Lieferant->Winfocusset(false);
  // ggf. Labels refreshen
//  RefreshIfm('edHuB.EK.Lieferant');
end;


//========================================================================
//  AusAnsprechpartner
//
//========================================================================
sub AusAnsprechpartner()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(102,0,_RecId,gSelected);
    // Feldübernahme
    HuB.EK.LieferSachb # StrAdj(Adr.P.Vorname+' '+Adr.P.Name,_Strbegin);
    gSelected # 0;

    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.LieferSachb->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edHuB.EK.LieferSachb');
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    // Feldübernahme
    "HuB.EK.Währung" # Wae.Nummer;
//    "HuB.EK.Währungskurs" # Wae.EK.Kurs;
    gSelected # 0;

    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.Waehrung->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edHuB.EK.Waehrung');
end;


//========================================================================
//  AusLieferbed
//
//========================================================================
sub AusLieferbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(815,0,_RecId,gSelected);
    // Feldübernahme
    HuB.EK.Lieferbed # LiB.Nummer;
    gSelected # 0;

    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.Lieferbed->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edHuB.EK.Lieferbed');
end;


//========================================================================
//  AusZahlungsbed
//
//========================================================================
sub AusZahlungsbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(816,0,_RecId,gSelected);
    // Feldübernahme
    HuB.EK.Zahlungsbed # ZaB.Nummer;
    gSelected # 0;

    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.Zahlungsbed->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edHuB.EK.Zahlungsbed');
end;


//========================================================================
//  AusVersandart
//
//========================================================================
sub AusVersandart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(817,0,_RecId,gSelected);
    // Feldübernahme
    HuB.EK.Versandart # Vsa.Nummer;
    gSelected # 0;

    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.Versandart->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edHuB.EK.Versandart');
end;


//========================================================================
//  AusPositionen
//
//========================================================================
sub AusPositionen()
begin
  gSelected # 0;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
//  gZLList->WinFocusset(true);

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
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_Aendern]=n) OR ("HuB.EK.Löschmarker" = '*');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_Aendern]=n) OR ("HuB.EK.Löschmarker" = '*');

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_Loeschen]=n);


  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then begin
    Erx # RecRead(190,1,_RecTest);
    vHdl->wpDisabled # (Rechte[Rgt_HuB_EK_Positionen]=n) or (Mode=c_Modeedit) or (Mode=c_ModeNew) or (Erx<>_rOk);
  end;

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
  vHdl    : int;
  vFilter : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Positionen' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.EK.P.Verwaltung',here+':AusPositionen',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(191);
      gZLList->wpDbFileNo     # 190;
      gZLList->wpDbLinkFileNo # 191;
      gZLList->wpDbKeyNo      # 1;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
    //  vFilter # RecFilterCreate(191,1);
  //    vFilter->RecFilterAdd(1,_FltAND,_FltEq,HuB.EK.Nummer);
//      $ZL.HuB.EK.P->wpDbFilter # vFilter;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.DruckBestellung' : begin
      Lib_Dokumente:Printform(190,'Bestellung',true);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Hub.EK.Anlage.Datum, Hub.EK.Anlage.Zeit, Hub.EK.Anlage.User );
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
    'bt.Sachbearbeiter'     :   Auswahl('Sachbearbeiter');
    'bt.Ansprechpartner'    :   Auswahl('Ansprechpartner');
    'bt.Lieferant'          :   Auswahl('Lieferant');
    'bt.Lieferbed'          :   Auswahl('Lieferbed');
    'bt.Zahlungsbed'        :   Auswahl('Zahlungsbed');
    'bt.Versandart'         :   Auswahl('Versandart');
    'bt.Sprache'            :   Auswahl('Sprache');
    'bt.Waehrung'           :   Auswahl('Waehrung');
  end;

end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbHuB.EK.WaehrungFixYN') then begin

    if ("HuB.EK.WährungFixYN") then begin
      Lib_GuiCom:Enable($edHuB.EK.Waehrungskurs);
      end
    else begin
      Lib_GuiCom:Disable($edHuB.EK.Waehrungskurs);
    end;
  end;

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
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
                   );
begin
  if ("HuB.EK.Löschmarker"='*') then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
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
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edHuB.EK.Sachbearb') AND (aBuf->HuB.EK.Sachbearb<>'')) then begin
    todo('Sachbearbeiter')
    //RekLink(819,200,1,0);   // Sacharbeiter holen
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.Lieferant') AND (aBuf->HuB.EK.Lieferant<>0)) then begin
    RekLink(100,190,2,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.LieferSachb') AND (aBuf->HuB.EK.LieferSachb<>'')) then begin
    todo('Ansprechpartner')
    //RekLink(100,190,2,0);   // Ansprechpartner holen
    Lib_Guicom2:JumpToWindow('Adr.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.Waehrung') AND (aBuf->"HuB.EK.Währung"<>0)) then begin
    RekLink(814,190,3,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.Lieferbed') AND (aBuf->HuB.EK.Lieferbed<>0)) then begin
    RekLink(815,190,5,0);   // Lieferbed. holen
    Lib_Guicom2:JumpToWindow('LiB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.Zahlungsbed') AND (aBuf->HuB.EK.Zahlungsbed<>0)) then begin
    RekLink(816,190,4,0);   // Zahlungsbed. holen
    Lib_Guicom2:JumpToWindow('Zab.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.Versandart') AND (aBuf->HuB.EK.Versandart<>0)) then begin
    RekLink(817,190,6,0);   // Versandart holen
    Lib_Guicom2:JumpToWindow('VsA.Verwaltung');
    RETURN;
  end;
 
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================