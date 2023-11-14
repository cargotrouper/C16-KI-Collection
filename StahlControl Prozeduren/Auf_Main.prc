@A+
//==== Business-Control ==================================================
//
//  Prozedur   Auf_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  25.04.2012  MS  Protokollrecht hinzugefuegt
//  19.07.2012  ST  Druck: DMS-Deckblatt hinzugefügt
//  25.09.2012  TM  AuftragsAnfrage eingesetzt
//  04.04.2022  AH  ERX
//  15.07.2022  HA  Quick Jump
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
//    SUB AusPosition()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtPageSelect2(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit_400(aEvt : Event; aRecId : int);
//    SUB EvtLstDataInit_401(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int) : logic
//    SUB EvtLstFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtLstKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;	aClientSize : point; aFlags  : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
//  cDialog     : $Auf.Verwaltung
  cTitle      : 'Aufträge'
  cFile       : 400
  cMenuName   : 'Auf.Bearbeiten'
  cPrefix     : 'Auf'
  cZList      : $ZL.Auftraege
  cKey        : 1
  cZLName     : 'ZL.Auftraege'

  cTitle2     : 'Auftragspositionen'
  cFile2      : 401
  cMenuName2  : 'Auf.P.Bearbeiten'
  cPrefix2    : 'Auf_P'
  cZList2     : $ZL.AufPositionen
  cKey2       : 1
  cZLName2    : 'ZL.AufPositionen'

end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl      : int;
  vFOnt     : font;
end;
begin

  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
//  App_Main:EvtInit(aEvt);

  vHdl # Winsearch(aEvt:Obj, 'ZL.Erfassung');
  Lib_GuiCom:RecallList(vHdl,'AUF.');

  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbAuf.P.Chemie.C1->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbAuf.P.Chemie.Si1->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbAuf.P.Chemie.Mn1->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbAuf.P.Chemie.P1->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbAuf.P.Chemie.S1->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbAuf.P.Chemie.Al1->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbAuf.P.Chemie.Cr1->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbAuf.P.Chemie.V1->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbAuf.P.Chemie.Nb1->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbAuf.P.Chemie.Ti1->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbAuf.P.Chemie.N1->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbAuf.P.Chemie.Cu1->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbAuf.P.Chemie.Ni1->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbAuf.P.Chemie.Mo1->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbAuf.P.Chemie.B1->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbAuf.P.Chemie.Frei1.1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    $lbAuf.P.Haerte1->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbauf.P.Koernung1->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbAuf.P.Mech.Sonstig1->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    $lbAuf.P.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    $lbAuf.P.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  // Verpackungstitel setzen
  if(Set.Vpg1.Titel <> '') then
    $lbAuf.P.VpgText1 -> wpcaption  # Set.Vpg1.Titel;
  if(Set.Vpg2.Titel <> '') then
    $lbAuf.P.VpgText2 -> wpcaption  # Set.Vpg2.Titel;
  if(Set.Vpg3.Titel <> '') then
    $lbAuf.P.VpgText3 -> wpcaption  # Set.Vpg3.Titel;
  if(Set.Vpg4.Titel <> '') then
    $lbAuf.P.VpgText4 -> wpcaption  # Set.Vpg4.Titel;
  if(Set.Vpg5.Titel <> '') then
    $lbAuf.P.VpgText5 -> wpcaption  # Set.Vpg5.Titel;
  if(Set.Vpg6.Titel <> '') then
    $lbAuf.P.VpgText6 -> wpcaption  # Set.Vpg6.Titel;

  // Feldberechtigungn...
  if (Rechte[Rgt_Auf_Preise]) then begin
    $clmGV.Num.01->wpvisible # true;   // Restwert
    $clmAuf.P.Grundpreis->wpvisible # true;
    //$edAuf.P.Kalkuliert->wpvisible # true;
    $edAuf.P.Grundpreis->wpvisible # true;
    $edRabatt1->wpvisible # true;
    $lb.Poswert->wpvisible # true;
    $lb.Kalkuliert->wpvisible # true;
    $edAuf.P.Kalkuliert_Mat->wpvisible # true;
    $edAuf.P.Grundpreis_Mat->wpvisible # true;
    $lb.Aufpreise->wpvisible # true;
    $lb.Rohgewinn->wpvisible # true;
    $lb.Aufpreise_Mat->wpvisible # true;
    $lb.P.Einzelpreis_Mat->wpvisible # true;
    $lb.Poswert_Mat->wpvisible # true;
    $clmAuf.P.Grundpreis_ERF->wpvisible # true;
    $clmGV.Num.01_ERF->wpvisible # true;
    $clmGV.Num.02_ERF->wpvisible # true;
  end;

Lib_Guicom2:Underline($edAuf.Kundennr);
Lib_Guicom2:Underline($edAuf.Lieferadresse);
Lib_Guicom2:Underline($edAuf.Lieferanschrift);
Lib_Guicom2:Underline($edAuf.Verbraucher);
Lib_Guicom2:Underline($edAuf.Rechnungsempf);
Lib_Guicom2:Underline($edAuf.Rechnungsanschr);
Lib_Guicom2:Underline($edAuf.Best.Bearbeiter);
Lib_Guicom2:Underline($edAuf.BDSNummer);
Lib_Guicom2:Underline($edAuf.Waehrung);
Lib_Guicom2:Underline($edAuf.Lieferbed);
Lib_Guicom2:Underline($edAuf.Zahlungsbed);
Lib_Guicom2:Underline($edAuf.Versandart);
Lib_Guicom2:Underline($edAuf.Sprache);
Lib_Guicom2:Underline($edAuf.Vertreter1);
Lib_Guicom2:Underline($edAuf.Land);
Lib_Guicom2:Underline($edAuf.Steuerschluessel);
Lib_Guicom2:Underline($edAuf.Sachbearbeiter);
Lib_Guicom2:Underline($edAuf.Vertreter2);


  // Auswahlfelder...
  SetStdAusFeld('edAuf.Vorgangstyp'           ,'Vorgangstyp');
  SetStdAusFeld('edAuf.Kundennr'              ,'Kunde');
  SetStdAusFeld('edAuf.Lieferadresse'         ,'Lieferadresse');
  SetStdAusFeld('edAuf.Lieferanschrift'       ,'Lieferanschrift');
  SetStdAusFeld('edAuf.Verbraucher'           ,'Verbraucher');
  SetStdAusFeld('edAuf.Rechnungsempf'         ,'Rechnungsempf');
  SetStdAusFeld('edAuf.Rechnungsanschr'       ,'Rechnungsanschr');
  SetStdAusFeld('edAuf.Best.Bearbeiter'       ,'Ansprechpartner');
  SetStdAusFeld('edAuf.BDSNummer'             ,'BDSNummer');
  SetStdAusFeld('edAuf.Land'                  ,'Land');
  SetStdAusFeld('edAuf.Waehrung'              ,'Waehrung');
  SetStdAusFeld('edAuf.Lieferbed'             ,'Lieferbed');
  SetStdAusFeld('edAuf.Zahlungsbed'           ,'Zahlungsbed');
  SetStdAusFeld('edAuf.Steuerschluessel'      ,'Steuerschluessel');
  SetStdAusFeld('edAuf.Versandart'            ,'Versandart');
  SetStdAusFeld('edAuf.Sprache'               ,'Sprache');
  SetStdAusFeld('edAuf.AbmessungsEH'          ,'AbmessungsEH');
  SetStdAusFeld('edAuf.GewichtsEH'            ,'GewichtsEH');
  SetStdAusFeld('edAuf.Sachbearbeiter'        ,'Sachbearbeiter');
  SetStdAusFeld('edAuf.Vertreter1'            ,'Vertreter1');
  SetStdAusFeld('edAuf.Vertreter2'            ,'Vertreter2');
  SetStdAusFeld('edAuf.P.Auftragsart'         ,'Auftragsart');
  SetStdAusFeld('edAuf.P.Warengruppe'         ,'Warengruppe');
  SetStdAusFeld('edAuf.P.AbrufAufNr'          ,'Abruf');
  SetSpeziAusFeld('edAuf.P.AbrufAufPos'         ,'AbrufPos');
  SetStdAusFeld('edAuf.P.Artikelnr'           ,'Artikelnummer');
  SetStdAusFeld('edAuf.P.KundenArtNr_Mat'     ,'KundenArtNr');
  SetStdAusFeld('edAuf.P.Projektnummer'       ,'Projekt');
  SetStdAusFeld('edAuf.P.MEH.Wunsch'          ,'MEH');
  SetStdAusFeld('edAuf.P.Termin1W.Art'        ,'Terminart');
  SetStdAusFeld('edAuf.P.MEH.Preis'           ,'PreisMEH');
  SetSpeziAusFeld('edAuf.P.Grundpreis'          ,'Preis');
  SetStdAusFeld('edAuf.P.Auftragsart_Mat'     ,'Auftragsart');
  SetStdAusFeld('edAuf.P.Warengruppe_Mat'     ,'Warengruppe');
  SetStdAusFeld('edAuf.P.AbrufAufNr_Mat'      ,'Abruf');
  SetSpeziAusFeld('edAuf.P.AbrufAufPos_Mat'     ,'AbrufPos');
  SetStdAusFeld('edAuf.P.Artikelnr_Mat'       ,'Artikelnummer_Mat');
  SetStdAusFeld('edAuf.P.Guete_Mat'           ,'Guete');
  SetStdAusFeld('edAuf.P.Guetenstufe_Mat'     ,'Guetenstufe');
  SetStdAusFeld('edAuf.P.AusfOben_Mat'        ,'AusfOben');
  SetStdAusFeld('edAuf.P.AusfUnten_Mat'       ,'AusfUnten');
  SetSpeziAusFeld('edAuf.P.KundenMatArtNr_Mat'  ,'KundenMatArtNr');
  SetStdAusFeld('edAuf.P.Termin1W.Art_Mat'    ,'Terminart');
  SetStdAusFeld('edAuf.P.Zeugnisart_Mat'      ,'Zeugnis');
  SetStdAusFeld('edAuf.P.Projektnummer_Mat'   ,'Projekt');
  SetStdAusFeld('edAuf.P.Erzeuger_Mat'        ,'Erzeuger');
  SetStdAusFeld('edAuf.P.Intrastatnr_Mat'     ,'Intrastat');
  SetStdAusFeld('edAuf.P.MEH.Preis_Mat'       ,'PreisMEH');
  SetStdAusFeld('edAuf.P.Kalkuliert_Mat'      ,'Kalkulation');
  SetStdAusFeld('edAuf.P.Grundpreis_Mat'      ,'Preis');
  SetStdAusFeld('edAuf.P.Skizzennummer'       ,'Skizze');
  SetStdAusFeld('edAuf.P.Verpacknr'           ,'Verpackung');
  SetStdAusFeld('edAuf.P.TextNr2'             ,'Text');
  SetStdAusFeld('edAuf.P.TextNr2b'            ,'Text2');
  SetStdAusFeld('edAuf.P.Zwischenlage'        ,'Zwischenlage');
  SetStdAusFeld('edAuf.P.Unterlage'           ,'Unterlage');
  SetStdAusFeld('edAuf.P.Umverpackung'        ,'Umverpackung');
  SetStdAusFeld('edAuf.P.Verwiegungsart'      ,'Verwiegungsart');
  SetStdAusFeld('edAuf.P.Etikettentyp'        ,'Etikett');
  SetStdAusFeld('edAuf.P.Etikettentyp2'       ,'Etikett2');


  // Ankerfunktion?
//  RunAFX('Auf.P.Init','');

/*
  cZList2->wpdbKeyno # "Set.Auf.Kopf<>PosRel";
  vHdl # winsearch(cZList2,'clmAuf.P.Nummer');
  vHdl->wpvisible # false;
  vHdl # winsearch(cZList2,'clmAuf.P.KundenSW');
  vHdl->wpvisible # false;
  vHdl # winsearch(cZList2,'clmAuf.Vorgangstyp');
  vHdl->wpvisible # false;
*/

  Lib_GuiCom:RecallList(cZList2);     // Usersettings holen
  vHdl # cZList2;
  if (Usr.Font.Size<>0) then begin
    vFont # vHDL->wpfont;
    vFont:Size # Usr.Font.Size * 10;
    vHDL->wpfont # vFont;
  end;
  vHDL->wpColFocusBkg    # Set.Col.RList.Cursor;
  vHDL->wpColFocusOffBkg # "Set.Col.RList.CurOff";

//  RETURN App_Main:EvtInit(aEvt);

  App_Main:EvtInit(aEvt);
  RunAFX('Auf.P.Init',aint(aEvt:Obj));
  RETURN true;
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
  opt aChanged : logic;
)
begin
  Auf_P_Main:RefreshIfm(aName, achanged);
  RETURN;
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  //$...->WinFocusSet(true);
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
    Auf.Anlage.Datum  # Today;
    Auf.Anlage.Zeit   # Now;
    Auf.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
//    RekDelete(gFile,0,'MAN');
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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

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
//    'Positionen' : begin
//      RecBufClear(401);         // ZIELBUFFER LEEREN
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Auf.P.Verwaltung','Auf_Main:AusPosition',y);
//      //ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      Lib_GuiCom:RunChildWindow(gMDI);
//    end;
  end;

end;


//========================================================================
//  AusPosition
//
//========================================================================
sub AusPosition()
begin
  if (gSelected<>0) then begin
//    RecRead(xxx,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
  end;
  Auf_data:BerechneMarker()
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);

  // Focus auf Editfeld setzen:
//  $edxxx.xxxxx->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl    : int;
  Erx     : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);
/* 11.11
  $NB.Kopf->wpdisabled      # y;
  $NB.Page1->wpdisabled     # y;
  $NB.Page2->wpdisabled     # y;
  $NB.Page3->wpdisabled     # y;
  $NB.Page4->wpdisabled     # y;
  $NB.Page5->wpdisabled     # y;
  $NB.Kopftext->wpdisabled  # y;
  $NB.Fusstext->wpdisabled  # y;
*/


  // Button & Menüs sperren
  d_MenuItem # gMenu->WinSearch('Mnu.Kundennr');
  if (d_MenuItem != 0) then
    d_MenuItem->wpDisabled # ( ( Mode = c_ModeEdit ) or ( Mode = c_ModeNew ) or ( Rechte[Rgt_Auf_Change_Kundennr] = false ) );

  d_MenuItem # gMenu->WinSearch('Mnu.Rechnungsempf');
  if (d_MenuItem != 0) then
    d_MenuItem->wpDisabled # ( ( Mode = c_ModeEdit ) or ( Mode = c_ModeNew ) or ( Rechte[Rgt_Auf_Change_Rechnungsempf] = false ) );

  vHdl # gMdi->WinSearch('New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_Auf_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_Auf_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_Auf_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_Auf_Loeschen]=n);


  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(Mode<>c_ModeList);


  // KOPIE AUS POSITIONEN: ----------------------------------------------------
  Erx # RecLink(835,401,5,_RecFirst);     // Auftragsart holen
  if (Erx>_rlocked) then RecBufClear(835);

  vHdl # gMenu->WinSearch('Mnu.Druck.AB');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or (Auf.Vorgangstyp<>c_AUF) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_AB]=n);
  end;

  // ---- AuftragsAnfrage ----
  vHdl # gMenu->WinSearch('Mnu.Druck.Anf');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or (Auf.Vorgangstyp<>c_AUF) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_AB]=n);
  end;

  vHdl # gMenu->WinSearch('Mnu.Druck.Angebot');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or (Auf.Vorgangstyp<>c_ANG) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_Angebot]=n);
  end;

  vHdl # gMenu->WinSearch('Mnu.Druck.Avis');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or (Auf.Vorgangstyp<>c_AUF) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_AB]=n);
  end;

  vHdl # gMenu->WinSearch('Mnu.Druck.Gut');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or ((Auf.Vorgangstyp<>c_BOGUT) and (Auf.Vorgangstyp<>c_REKOR) and (Auf.Vorgangstyp<>c_GUT)) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_Gut]=n);
  vHdl # gMenu->WinSearch('Mnu.Druck.Gut.VS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or ((Auf.Vorgangstyp<>c_BOGUT) and (Auf.Vorgangstyp<>c_REKOR) and (Auf.Vorgangstyp<>c_GUT)) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_Gut]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.Bel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or ((Auf.Vorgangstyp<>c_BEL_KD) and (Auf.Vorgangstyp<>c_BEL_LF)) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_Bel]=n);
  vHdl # gMenu->WinSearch('Mnu.Druck.Bel.VS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or ((Auf.Vorgangstyp<>c_BEL_KD) and (Auf.Vorgangstyp<>c_BEL_LF)) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_Bel]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.RE');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Auf.P.Aktionsmarker<>'$') or
      (Auf.Vorgangstyp<>c_AUF) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_RE]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.RE.VS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Auf.P.Aktionsmarker<>'$') or
      (Auf.Vorgangstyp<>c_AUF) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_RE]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.FM');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
      or (Auf.Vorgangstyp<>c_AUF) or
      (w_Auswahlmode) or (Rechte[Rgt_Auf_Druck_FM]=n);
  end;

  vHdl # gMenu->WinSearch('Mnu.Druck.BA');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # (AAr.Berechnungsart<700) or (AAr.Berechnungsart>799) or ((Mode<>c_modeList) and (Mode<>c_modeView));
  end;

  vHdl # gMenu->WinSearch('Mnu.Protokoll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_Protokoll]=n);


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
  vHdl      : int;
  vSelName  : alpha;
  vSel      : int;
  vNumNeu   : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.New2' : begin
      cZList2->winfocusset(true);
      w_AppendNr # 0;
      App_Main:Action(c_ModeNew);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Auf.Anlage.Datum, Auf.Anlage.Zeit, Auf.Anlage.User);
    end;


    'Mnu.Kundennr' : begin
      Auf_Subs:ChangeKundennr();
    end;


    'Mnu.Rechnungsempf' : begin
      Auf_Subs:ChangeRechnungsempf();
    end;

    otherwise begin
      RETURN Auf_P_Main:EvtMenuCommand(aEvt, aMenuItem);
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
    'New' : begin
//      if (gMDI=cDialog) then begin  // neuer Auftrag?
      cZList2->winfocusset(true);
      if (StrFind(gMDI->wpname,'Auf.Verwaltung',0)<>0) then begin  // neuer Auftrag?
        w_AppendNr # 0;
        App_Main:Action(c_ModeNew);
        end
      else begin
        w_AppendNr # Auf.Nummer;    // neue Positionen?
        App_Main:Action(c_ModeNew);
      end;
    end;

    'bt.xxxxx' :   Auswahl('...');

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

//  if (aPage<>0) then begin
//    Auf_P_Main:Refreshifm(aPage->wpname);
//  end;

  RETURN true;
end;


//========================================================================
//  EvtPageSelect2
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect2(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin

  if (aSelecting=n) then RETURN true;

  if (aPage->wpname='NB.List') then begin
    RETURN App_Main:EvtPageSelect(aEvt,aPage,aSelecting);
  end;

  App_Main:Action(c_ModeList);
//  App_Main:Action(c_Modeother);
//  Mode # c_modeList;
//  Auswahl('Positionen');
//  gMDI->wpdisabled # y;
  gTimer2 # SysTimerCreate(1500,1,gMdiAuf);

  RETURN false;
end;


//========================================================================
//  EvtLstDataInit_400
//
//========================================================================
sub EvtLstDataInit_400(
  aEvt      : Event;
  aRecId    : int;
);
local begin
  vCol  : int;
  vMark : logic;
end;
begin

//  if (Lib_Mark:IstMarkiert(cFile,RecInfo(cFile,_RecId))) then begin
  // Markiert?
  if ( Lib_Mark:IstMarkiert(400, RecInfo(400, _recId ) ) ) then
    vMark # !Lib_GuiCom:ZLColorLine( aEvt:Obj, Set.Col.RList.Marke, true );
  else
    vMark # false;

  if (vMark=n) then begin
    vCol # _WinColParent;
    if (Auf.Vorgangstyp=c_ANG) then vCol # Set.Auf.Col.Ang;
    if ("Auf.Löschmarker"='*') then vCol # Set.Col.RList.Deletd;
    if (vCol<>0) then Lib_GuiCom:ZLColorLine(cZList,vCol);
  end;

  Gv.Alpha.20 # Auf.Aktionsmarker;
  if (Gv.Alpha.20='') then
    if (RecLinkInfo(404,400,15,_RecCount)>0) then Gv.Alpha.20 # '!';
  Gv.Alpha.20 # "Auf.Löschmarker" + Gv.alpha.20;

  Gv.int.01 # RecLinkInfo(401,400,9,_recCount);

//  RecLink(401,400,9,_recFirst);   // 1. Position holen
  RecLink(101,400,2,_recFirst);   // Lieferanschrift holen
  RecLink(100,400,1,_recFirst ); // Kunde

end;


//========================================================================
//  EvtLstDataInit_401
//
//========================================================================
sub EvtLstDataInit_401(
  aEvt    : event;
  aRecId  : int;
) : logic
local begin
  vMark : logic;
  vHdl  : handle;
  vTmp  : int;
end;
begin
  // wenn die RecList durch ein anderes Fenster refrehed wurde, müssen die globlaen
  // Variablen für diese Prozedur richtig ggesetzt werden...
  vHdl # WinInfo(aEvt:Obj, _Winframe);
  if (vHdl<>0) then begin
    if (vHdl->wpcustom<>'') and
      (vHdl->wpcustom<>cnvai(VarInfo(WindowBonus))) then begin
      VarInstance(WindowBonus,cnvIA(vHdl->wpcustom));
      end;
  end;


  vTmp # gMdi->winSearch('ed.Suche');
  if (vTmp<>0) then
    if (vTmp->wpcustom='AUSWAHL') then begin
      vTmp->wpcustom # '';
      vTmp->winfocusset();
    end;

  if (gFile<>0) then begin
    // Markiert?
    if ( Lib_Mark:IstMarkiert(401, RecInfo(401, _recId ) ) ) then
      vMark # !Lib_GuiCom:ZLColorLine( aEvt:Obj, Set.Col.RList.Marke, true );
    else
      vMark # false;
  end;

  try begin
    ErrTryIgnore(_rlocked,_rNoRec);
    ErrTryCatch(_ErrNoProcInfo,y);
    ErrTryCatch(_ErrNoSub,y);
    if (gPrefix<>'') then begin
      Call(strcnv('Auf_P_Main:EvtLstDataInit',_strupper),aEvt,aRecId,vMark);
    end;
  end;

  RETURN true;
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

  RecRead(400,0,_recid,aRecID);
  RecLink(401,400,9,_recFirst);   // 1. Position holen
  cZList2->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  RefreshMode(y);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  Lib_GuiCom:RememberList(cZList2);
  RETURN true;
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

    Auswahl('Positionen');
    end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;
  RETURN true;
end;


//========================================================================
//  EvtLstFocusInit
//
//========================================================================
sub EvtLstFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vHdl : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

//  if (gMDI<>cDialog) then RETURN true;
  if (StrFind(gMDI->wpname,'Auf.Verwaltung',0)=0) then RETURN true;

  if (Auf.P.Nummer=0) then begin
    cZList->winfocusset(true);
    cZList->WinUpdate(_WinUpdOn, _WinLstRecDoSelect | _WinLstFromFirst);
    RETURN true;
  end;

  // Kopfliste:
  if (aEvt:Obj->wpname=cZLName) then begin
    gTitle    # Translate(cTitle);
    gFile     # cFile;
    gMenuName # cMenuName;
    gPrefix   # cPrefix;
    gZLList   # cZList;
    gKey      # cKey;

    vHdl # gMDI->WinSearch('lb.Sort');
    if (vHdl<>0) then vHdl->wpvisible # true;
    vHdl # gMDI->WinSearch('lb.Suche');
    if (vHdl<>0) then vHdl->wpvisible # true;
    vHdl # gMDI->WinSearch('ed.Sort');
    if (vHdl<>0) then vHdl->wpvisible # true;
    vHdl # gMDI->WinSearch('ed.Suche');
    if (vHdl<>0) then vHdl->wpvisible # true;
  end;

  // Positionsliste:
  if (aEvt:Obj->wpname=cZLName2) then begin

    $NB.Kopf->wpdisabled      # n;
    $NB.Page1->wpdisabled     # n;
    $NB.Page2->wpdisabled     # n;
    $NB.Page3->wpdisabled     # n;
    $NB.Page4->wpdisabled     # n;
    $NB.Page5->wpdisabled     # n;
    $NB.Kopftext->wpdisabled  # n;
    $NB.Fusstext->wpdisabled  # n;

    gTitle    # Translate(cTitle2);
    gFile     # cFile2;
    gMenuName # cMenuName2;
    gPrefix   # cPrefix2;
    gZLList   # cZList2;
    gKey      # cKey2;

    vHdl # gMDI->WinSearch('lb.Sort');
    if (vHdl<>0) then vHdl->wpvisible # false;
    vHdl # gMDI->WinSearch('lb.Suche');
    if (vHdl<>0) then vHdl->wpvisible # false;
    vHdl # gMDI->WinSearch('ed.Sort');
    if (vHdl<>0) then vHdl->wpvisible # false;
    vHdl # gMDI->WinSearch('ed.Suche');
    if (vHdl<>0) then vHdl->wpvisible # false;
  end;

  gFrmMain->wpMenuname # gMenuName;    // Menü setzen
  if (gPrefix<>'') then begin
    vHdl # gFrmMain->WinInfo(_WinMenu);
    Lib_SFX:CreateMenu(vHdl, gPrefix);
  end;
  App_Main:Refreshmode();

end;


//========================================================================
//  EvtLstKeyItem
//            Keyboard in RecList/DataList
//========================================================================
sub EvtLstKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aRecID                : int;          // RecID
) : logic
local begin
  vHdl : int;
end;
begin
  if (aEvt:obj=cZList) and (aKey=_winkeyreturn) then begin
    RecRead(400,0,_RecID,aRecId);
    RecLink(401,400,9,_recFirst);   // 1. Position holen
    vHdl # RecInfo(401,_RecID);
    cZList2->winfocusset(true);
    cZList2->wpdbrecid # vHdl;
    cZList2->WinUpdate(_WinUpdOn, _WinLstRecDoSelect);
    RETURN true;
  end;

  if (aEvt:obj=cZList2) and (aKey=_winkeyEsc) then begin
    vHdl # RecInfo(400,_RecID);
    cZList->winfocusset(true);
    cZList->wpdbrecid # vHdl;
    cZList->WinUpdate(_WinUpdOn, _WinLstRecDoSelect | _WinLstFromSelected);
    RETURN false;
  end;

  RETURN App_Main:EvtkeyItem(aEvt,aKey,aRecID);
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
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) and (gZLList<>0) then begin
    vRect           # $Groupsplit1->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28;
    $GroupSplit1->wparea # vRect;
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
local begin
  vQ    :  alpha(1000);
end
begin
  
  if ((aName =^ 'edAuf.Kundennr') AND (Auf.Kundennr<>0)) then begin
    RekLink(100,400,1,0);   // Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edAuf.Lieferadresse') AND (Auf.Lieferadresse<>0)) then begin
    RekLink(100,400,12,0);   // Lieferadresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Lieferanschrift') AND (Auf.Lieferanschrift<>0)) then begin
    RekLink(101,400,2,0);   // Anschrift holen
    Adr.A.Adressnr # Auf.Lieferadresse;
    Adr.A.Nummer # Auf.Lieferanschrift;
    RecRead(101,1,0);
    
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Auf.Lieferadresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Verbraucher') AND (Auf.Verbraucher<>0)) then begin
     RekLink(100,400,3,0);   // Verbraucher holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Rechnungsempf') AND (Auf.Rechnungsempf<>0)) then begin
     RekLink(100,400,4,0);   // Rechn.Empf. holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Rechnungsanschr') AND (Auf.Rechnungsanschr<>0)) then begin
    Adr.A.Adressnr # Auf.Rechnungsempf;
    Adr.A.Nummer # Auf.Rechnungsanschr;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Auf.Rechnungsempf);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Best.Bearbeiter') AND (Auf.Best.Bearbeiter<>'')) then begin
    // RekLink(819,200,1,0);   // Ansprechpartner holen
    Lib_Guicom2:JumpToWindow('Adr.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.BDSNummer') AND (Auf.BDSNummer<>0)) then begin
    RekLink(836,400,11,0);   // Anschrift holen
    Lib_Guicom2:JumpToWindow('BDS.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Waehrung') AND ("Auf.Währung"<>0)) then begin
    RekLink(814,400,8,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Lieferbed') AND (Auf.Lieferbed<>0)) then begin
    RekLink(815,400,5,0);   // Lieferbed holen
    Lib_Guicom2:JumpToWindow('LiB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Zahlungsbed') AND (Auf.Zahlungsbed<>0)) then begin
    RekLink(816,400,6,0);   // Zahlungsbed holen
    Lib_Guicom2:JumpToWindow('Zab.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Versandart') AND (Auf.Versandart<>0)) then begin
    RekLink(817,400,7,0);   // Versandart holen
    Lib_Guicom2:JumpToWindow('VsA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Sprache') AND (Auf.Sprache<>'')) then begin
   todo('Sprache')
    // RekLink(819,200,1,0);   // Sprache holen
    Lib_Guicom2:JumpToWindow('');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Vertreter1') AND (Auf.Vertreter<>0)) then begin
    RekLink(110,400,20,0);   // Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Land') AND (Auf.Land<>'')) then begin
    RekLink(812,400,10,0);   // Eintrittsland holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Steuerschluessel') AND ("Auf.Steuerschlüssel"<>0)) then begin
    RekLink(813,400,19,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('StS.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Sachbearbeiter') AND (Auf.Sachbearbeiter<>'')) then begin
    // RekLink(819,200,1,0);   // Sacharbeiter holen
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.Vertreter2') AND (Auf.Vertreter2<>0)) then begin
    RekLink(110,400,21,0);   // Verband holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;


end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
