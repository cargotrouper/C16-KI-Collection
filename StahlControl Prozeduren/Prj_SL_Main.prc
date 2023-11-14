@A+
//==== Business-Control ==================================================
//
//  Prozedur    Prj_SL_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  16.03.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB Etikettendaten();
//    SUB Skizzendaten();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSkizze();
//    SUB AusEtikettentyp()
//    SUB AusArtikelnummer()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Projekt-Stückliste'
  cFile :     121
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Prj_SL'
  cZList :    $ZL.Prj.SL
  cKey :      1
end;

declare RefreshIfm(opt aName : alpha)

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

  $lb.Projekt->wpcaption # AInt(Prj.Nummer);

  // Verpackungstitel setzen
  if(Set.Vpg1.Titel <> '') then
    $lbPrj.SL.VpgText1 -> wpcaption  # Set.Vpg1.Titel;
  if(Set.Vpg2.Titel <> '') then
    $lbPrj.SL.VpgText2 -> wpcaption  # Set.Vpg2.Titel;
  if(Set.Vpg3.Titel <> '') then
    $lbPrj.SL.VpgText3 -> wpcaption  # Set.Vpg3.Titel;
  if(Set.Vpg4.Titel <> '') then
    $lbPrj.SL.VpgText4 -> wpcaption  # Set.Vpg4.Titel;
  if(Set.Vpg5.Titel <> '') then
    $lbPrj.SL.VpgText5 -> wpcaption  # Set.Vpg5.Titel;
  if(Set.Vpg6.Titel <> '') then
    $lbPrj.SL.VpgText6 -> wpcaption  # Set.Vpg6.Titel;

Lib_Guicom2:Underline($edPrj.SL.Artikelnummer);
Lib_Guicom2:Underline($edPrj.SL.Etikettentyp);
Lib_Guicom2:Underline($edPrj.SL.Skizzennummer);

  // Auswahlfelder setzen...
  SetStdAusFeld('edPrj.SL.Artikelnummer', 'Artikel');
  SetStdAusFeld('edPrj.SL.Etikettentyp' , 'Etikett');
  SetStdAusFeld('edPrj.SL.Skizzennummer', 'Skizze');


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
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  Etikettendaten
//
//========================================================================
sub Etikettendaten();
local begin
  vA1,vA2 : alpha;
end;
begin
  RETURN;

  // SPEZI
  gMDI->wpdisabled # y;
  Dlg_Standard:Standard('Artikelnummer',var vA1);
  Dlg_Standard:Standard('Abmessung',var vA2);
  gMDI->wpdisabled # n;
  $edPrj.SL.Etikettentyp->Winfocusset(false);
  Prj.SL.VpgText1 # vA1;
  Prj.SL.VpgText2 # vA2;
  $edPrj.SL.VpgText1->winupdate(_WinUpdFld2Obj);
  $edPrj.SL.VpgText2->winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  Skizzendaten
//
//========================================================================
sub Skizzendaten();
local begin
  vZ : int;
  vA : alpha;
  vX : int;
  vUmfang : float;
  vA3,vA4,vA5 : alpha;
end;
begin
  // SPEZI
  gMDI->wpdisabled # y;
  FOR vX # 1 loop inc(vX) WHILE (vX<=Skz.Anzahl.Variablen) do begin
    vA # StrChar(64+vX);
    Dlg_Standard:Anzahl(Translate('Variable')+' '+vA,var vZ,0,300,200);
    vUmfang # vUmfang + cnvfi(vZ);
    case (vX%3) of
      0 : if (vA5='') then
            vA5 # vA + '='+cnvai(vZ)
          else
            vA5 # vA5 +',  '+ vA + '='+cnvai(vZ);
      1 : if (vA3='') then
            vA3 # vA + '='+cnvai(vZ)
          else
            vA3 # vA3 +',  '+ vA + '='+cnvai(vZ);
      2 : if (vA4='') then
            vA4 # vA + '='+cnvai(vZ)
          else
            vA4 # vA4 +',  '+ vA + '='+cnvai(vZ);
    end;
  END;

  gMDI->wpdisabled # n;

  $edPrj.SL.Skizzennummer->Winfocusset(false);
  Prj.SL.VpgText4 # vA3;
  Prj.SL.VpgText5 # vA4;
  Prj.SL.VpgText6 # vA5;
  $edPrj.SL.VpgText4->winupdate(_WinUpdFld2Obj);
  $edPrj.SL.VpgText5->winupdate(_WinUpdFld2Obj);
  $edPrj.SL.VpgText6->winupdate(_WinUpdFld2Obj);

  "Prj.SL.Länge" # vUmfang;// * cnvfi("Prj.SL.Stückzahl");
  $edPrj.SL.Laenge->winupdate(_WinUpdFld2Obj);
  Refreshifm('edPrj.SL.Laenge');

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp  : int;
  Erx   : int;
end;
begin

  if (Mode=c_modeEdit) or (Mode=c_ModeNew) then begin

    if (aName='edPrj.SL.Stckzahl') or
     (aName='edPrj.SL.Laenge') or
     (aName='edPrj.SL.Breite') then begin
      Erx # RecLink(250,121,2,_recFirst);   // Artikel holen
      if (Erx>_rLockeD) then RecBufClear(250);

      Prj.SL.Gewicht # 0.0;
      if ("Art.Länge"<>0.0) and ("Art.Breite"<>0.0) and ("Prj.SL.Länge"<>0.0) and ("Prj.SL.Breite"<>0.0) then
        Prj.SL.Gewicht # "Art.GewichtProStk" / "Art.Breite" / "Art.Länge" * "Prj.SL.Länge" * "Prj.SL.Breite" * Cnvfi("Prj.SL.Stückzahl");;
      if (Prj.SL.Gewicht=0.0) and ("Prj.SL.Länge"<>0.0) and ("Art.GewichtProm"<>0.0) then
        Prj.SL.Gewicht # "Art.GewichtProm" * "Prj.SL.Länge" / 1000.0 * Cnvfi("Prj.SL.Stückzahl");
      if (Prj.SL.Gewicht=0.0) then
        Prj.SL.Gewicht # "Art.GewichtProStk" * Cnvfi("Prj.SL.Stückzahl");
      Prj.SL.Gewicht # Rnd(Prj.SL.Gewicht,1);

      if (Prj.SL.MEH='Stk') then  Prj.SL.Menge # cnvfi("Prj.SL.Stückzahl");
      if (Prj.SL.MEH='kg') then   Prj.SL.Menge # Prj.SL.Gewicht;
      if (Prj.SL.MEH='t') then    Prj.SL.Menge # Prj.SL.Gewicht / 1000.0;
      if (Prj.SL.MEH='m') or (Prj.SL.MEH='lfdm') then Prj.SL.Menge # Cnvfi("Prj.SL.Stückzahl") * "Prj.SL.Länge" / 1000.0;
      if (Prj.SL.MEH='m²') or (Prj.SL.MEH='qm') then  Prj.SL.Menge # Cnvfi("Prj.SL.Stückzahl") * "Prj.SL.Länge" / 1000.0 * "Prj.SL.Breite" / 1000.0;
      $edPrj.SL.Menge->winupdate(_WinUpdFld2Obj);
    end;


    if (aName='edPrj.SL.Artikelnummer') and ($edPrj.SL.Artikelnummer->wpchanged) then begin
      Art.Nummer # Prj.SL.Artikelnr;
      Erx # RecRead(250,1,0);
      if (Erx>_rLocked) then RecBufClear(250);
      // Feldübernahme
      Prj.SL.Artikelnr      # Art.Nummer ;
      Prj.SL.Dicke          # Art.Dicke;
      Prj.SL.Breite         # Art.Breite;
      Prj.SL.Gewicht        # "Art.GewichtProStk";
      Prj.SL.Gewicht # Rnd(Prj.SL.Gewicht);
      "Prj.SL.Länge"        # "Art.Länge";
      Prj.SL.MEH            # Art.MEH;
      gMdi->Winupdate();

//      Erx # RecLink(250,121,2,_recFirst);   // Artikel holen
//      if (Erx>_rLockeD) then RecBufClear(250);
      if (Art.MEH='qm') or (Art.MEH='kg') then begin
        Lib_GuiCom:Enable($edPrj.SL.Breite);
        Lib_GuiCom:Enable($edPrj.SL.Laenge);
      end
      else
      if (Art.MEH='m') or (Art.MEH='mm') then begin
        Lib_GuiCom:Disable($edPrj.SL.Breite);
        Lib_GuiCom:Enable($edPrj.SL.Laenge);
      end
      else begin
        Lib_GuiCom:Disable($edPrj.SL.Breite);
        Lib_GuiCom:Disable($edPrj.SL.Laenge);
      end;
    end;
  end;

  $lb.Gewicht->wpcaption # ANum(Prj.SL.Gewicht,2);

  if (aName='') or (aName='edPrj.SL.Etikettentyp') then begin
    Erx # RecLink(840,121,3,0);
    if (Erx<=_rLocked) then
      $Lb.Etikettentyp->wpcaption # Eti.Bezeichnung
    else
      $Lb.Etikettentyp->wpcaption # '';
  end;


  if (aName='') or
    ((aName='edPrj.SL.Skizzennummer') and ($edPrj.SL.Skizzennummer->wpchanged)) then begin
    Erx # RecLink(829,121,4,_recFirst);          // Skizze holen
    if (Erx<>_rOK) then begin
      $Picture2->wpcaption # '';
    end
    else begin
      $Picture2->wpcaption # '*'+Skz.Dateiname;
      $Picture2->Winupdate();
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
sub RecInit()
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
      RecBufClear(121);
      Prj.SL.Nummer # Prj.Nummer;
      Prj.SL.Etikettentyp # 1;
  end;

  // Focus setzen auf Feld:
  $edPrj.SL.Referenznr->WinFocusSet(true);
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
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
//    ".Änderung.Datum"  # Today;
  //  "xxx.Änderung.Zeit"   # Now;
    //"xxx.Änderung.User"   # gUserName;
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
//    xxx.Anlage.Datum  # Today;
  //  xxx.Anlage.Zeit   # Now;
    //xxx.Anlage.User   # gUserName;
    Prj.SL.lfdNr # 0;
    REPEAT
      Prj.SL.lfdNr # Prj.SL.lfdNr + 1;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (erx=_rOK);
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RekDelete(gFile,0,'MAN');
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

//debug(aEvt:Obj->wpname);

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

  if ((aEvt:obj->wpname='edPrj.SL.Skizzennummer') and ($edPrj.SL.Skizzennummer->wpchanged)) then begin
    Skizzendaten();
    RETURN false;
  end;

  if ((aEvT:obj->wpname='edPrj.SL.Etikettentyp') and ($edPrj.SL.Etikettentyp->wpchanged)) then begin
    Etikettendaten();
    $edPrj.SL.Etikettentyp->Winfocusset(true);
    RETURN false;
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
  vA    : alpha;
end;

begin

  case aBereich of

    'Skizze' : begin
      RecBufClear(829);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Skz.Verwaltung',here+':AusSkizze');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Etikett' : begin
      RecBufClear(840);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettentyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelnummer');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 1;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusSkizze
//
//========================================================================
sub AusSkizze();
local begin
  vTxtHdl : int;
  vDoIt   : logic;
end;
begin
  if (gSelected<>0) then begin
    RecRead(829,0,_RecId,gSelected);
    Prj.SL.Skizzennummer # Skz.Nummer;
    $edPrj.SL.Skizzennummer->winupdatE(_WinUpdFld2Obj);
    vDoIt # y;
  end;
  gSelected # 0;
  // Focus auf Editfeld setzen:
  $edPrj.SL.Skizzennummer->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edAuf.P.Skizzennummer');
  if (vDoIt) then begin
    $Picture2->wpcaption # '*'+Skz.Dateiname;
    $Picture2->Winupdate();
    Skizzendaten();
  end;

end;


//========================================================================
//  AusEtikettentyp
//
//========================================================================
sub AusEtikettentyp()
begin
  if (gSelected<>0) then begin
    RecRead(840,0,_RecId,gSelected);
    // Feld∑bernahme
    Prj.SL.Etikettentyp # Eti.Nummer;
    gSelected # 0;
    Etikettendaten();
  end;
  // Focus auf Editfeld setzen:
  $edPrj.SL.Etikettentyp->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusArtikelnummer
//
//========================================================================
sub AusArtikelnummer()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    // Feld∑bernahme
    Prj.SL.Artikelnr      # Art.Nummer;
    Prj.SL.Dicke          # Art.Dicke;
    Prj.SL.Breite         # Art.Breite;
    "Prj.SL.Länge"        # "Art.Länge";
    Prj.SL.MEH            # Art.MEH;
    gSelected # 0;
  end;
  gMdi->winupdate();
  // Focus auf Editfeld setzen:
  $edPrj.SL.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_SL_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_SL_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Prj_SL_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Prj_SL_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Prj_SL_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Prj_SL_Loeschen]=n);

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
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
    'bt.Artikel'      :   Auswahl('Artikel');
    'bt.Etikettentyp' :   Auswahl('Etikett');
    'bt.Skizze'       :   Auswahl('Skizze');
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
begin
//  Refreshmode();
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

  if ((aName =^ 'edPrj.SL.Artikelnummer') AND (aBuf->Prj.SL.Artikelnr<>'')) then begin
    RekLink(250,121,2,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPrj.SL.Etikettentyp') AND (aBuf->Prj.SL.Etikettentyp<>0)) then begin
    RekLink(840,121,3,0);   // Etikettentyp holen
    Lib_Guicom2:JumpToWindow('Eti.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edPrj.SL.Skizzennummer') AND (aBuf->Prj.SL.Skizzennummer<>0)) then begin
    RekLink(829,121,4,0);   // Skizzenummer holen
    Lib_Guicom2:JumpToWindow('Skz.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
