@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_E_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  01.12.2011  AI  Lageradresse wird erst durch den Haken gesetzt 1323/52
//  29.03.2012  MS  Datumsfelder bei Neuanlage deaktiviert Prj. 1161/395
//  26.06.2012  AI  gelöschte Position kann nicht bebucht werden
//  14.10.2013  AH  RecSave: Weitere Eingabe, nur wenn Pos. nicht schon erfüllt ist
//  10.02.2014  AH  RecSave: Ausfall und Löschabfragen
//  01.08.2014  ST  RecSave: Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  25.02.2015  AH  automatischer Ausfall bei "Rest", löscht EingangYN und Eingang_Datum
//  05.05.2015  AH  Erfüllungsprozent auf "Ein.P.Menge" NICHT "Ein.P.Menge.Wunsch"
//  02.09.2015  AH  Abschlussdatumprüfung nur bei gesetzen Haken
//  17.12.2015  AH  Neu: Set.Ein.WE.Weitere
//  07.03.2016  AH  Edit: Löschen nur bei unverbuchter EKK
//  10.05.2022  AH  ERX
//  21.07.2022  HA  Quick Jump
//  2023-02-22  AH  AFX "Ein.E.Init.Pre", "Ein.E.EvtLstDatainit"
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
//    SUB AusLagerplatz()
//    SUB AusLageradresse()
//    SUB AusLageranschrift()
//    SUB AusZustand()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Wareneingänge'
  cFile :     506
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Ein_E'
  cZList :    $ZL.Ein.Eingang
  cKey :      1
end;

declare EvtChanged(aEvt : event): logic

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  WinSearchPath(aEvt:obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  $clmEin.E.PreisW1->wpcaption # Translate('Preis')+' '+"Set.Hauswährung.Kurz";

  Lib_Guicom2:Underline($edEin.E.Lageradresse);
  Lib_Guicom2:Underline($edEin.E.Lageranschrift);
  Lib_Guicom2:Underline($edEin.E.Lagerplatz);
  Lib_Guicom2:Underline($edEin.E.Art.Zustand);

  SetStdAusFeld('edEin.E.Lageradresse'    ,'Lageradresse');
  SetStdAusFeld('edEin.E.Lageranschrift'  ,'Lageranschrift');
  SetStdAusFeld('edEin.E.Lagerplatz'      ,'Lagerplatz');
  SetStdAusFeld('edEin.E.Art.Zustand'     ,'Zustand');

  RunAFX('Ein.E.Init.Pre',aint(aEvt:Obj));    // 2023-02-22 AH

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
local begin
  vMEHstring : alpha;
end;
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edEin.E.Lageradresse);
  Lib_GuiCom:Pflichtfeld($edEin.E.Lageranschrift);
  Lib_GuiCom:Pflichtfeld($edEin.E.VSB_Datum);
  Lib_GuiCom:Pflichtfeld($edEin.E.Eingang_Datum);
  Lib_GuiCom:Pflichtfeld($edEin.E.Ausfall_Datum);

  if (StrCnv(Ein.E.MEH,_Strupper)<>'STK') and (strCnv(Ein.E.MEH,_Strupper)<>'KG') or
    (StrCnv(Ein.E.MEH,_Strupper)<>'T') then
    Lib_GuiCom:Pflichtfeld($edEin.E.Menge);

/****
  vMEHString # StrCnv(Ein.P.MEH.Wunsch+'|'+Ein.P.MEH.Preis+'|'+Ein.P.MEH,_StrUpper);

  if (Strfind(vMEHString,'KH',0)<>0) or
    (Strfind(vMEHString,'T',0)<>0) then
    Lib_GuiCom:Pflichtfeld($edEin.E.Gewicht);
  if (Strfind(vMEHString,'STK',0)<>0) then
    Lib_GuiCom:Pflichtfeld($edEin.E.Stueckzahl);
****/

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
  vTmp    : int;
end;
begin

  if (aName='') or (aName='edEin.E.Lageradresse') then begin
    Erx # RecLink(100,506,6,_recFirst);   // Lagerandresse holen
    if (Erx<=_rLocked) then
      $lb.Adresse->wpcaption # Adr.Stichwort
    else
      $lb.Adresse->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Lageranschrift') then begin
    Erx # RecLink(101,506,7,_recFirst);   // Lageranschrift holen
    if (Erx<=_rLocked) then
      $lb.Anschrift->wpcaption # Adr.A.Stichwort
    else
      $lb.Anschrift->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Art.Zustand') then begin
    Erx # RecLink(856,506,17,_recFirst);   // Zustand holen
    if (Erx<=_rLocked) then
      $lb.Zustand->wpcaption # Art.ZSt.Name
    else
      $lb.Zustand->wpcaption # '';
  end;


  if (aName='') then begin
    $lb.Nummer->wpcaption     # AInt(Ein.E.Nummer);
    $lb.Position->wpcaption   # AInt(Ein.E.Position);
    if (Ein.E.Eingangsnr<>0) then
      $lb.lfdNr->wpcaption      # AInt(Ein.E.Eingangsnr)
    else
      $lb.lfdNr->wpcaption      # '';
    $lb.MEH->wpcaption        # Ein.E.MEH;
    RecLink(100,506,3,_recFirst);   // Lieferant holen
    $lb.Stichwort->wpcaption  # Adr.Stichwort;

    // Artikeleingang
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
      RecLink(250,506,5,_RecFirst); // Artikel holen
      $lb.Artikelnr->wpcaption  # Ein.E.Artikelnr;
      $lb.ArtStichwort->wpcaption  # Art.Stichwort;
      $lb.Bez1->wpcaption       # Art.Bezeichnung1;
      $lb.Bez2->wpcaption       # Art.Bezeichnung2;
      $lb.Bez3->wpcaption       # Art.Bezeichnung3;
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
  Erx         : int;
  vMEH        : alpha;
  vMEHString  : alpha;
end;
begin

  if (Mode=c_ModeNew) then begin
    // 08.09.2016 AH: falls pauschaler Aufpreis existiert, warnen!
    FOR Erx # RecLink(503,500,13,_RecFirst) // Aufpreise loopen
    LOOP Erx # RecLink(503,500,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (Ein.Z.Position<>0) and (Ein.Z.Position<>Ein.P.Position) then CYCLE;
      if (Ein.Z.MengenbezugYN=false) and ((Ein.Z.Menge * Ein.Z.Preis )<>0.0) then begin
        Msg(506021,'',0,0,0);
        BREAK;
      end;
    END;
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // Ankerfunktion?
  if (aBehalten) then begin
    if (RunAFX('Ein.E.RecInit', '1') < 0) then
      RETURN;
  end
  else begin
    if (RunAFX('Ein.E.RecInit', '0') < 0) then
      RETURN;
  end;


  // Focus setzen auf Feld:
  $cbEin.E.VSBYN->WinFocusSet(true);

  // Neuanlage?
  if (Mode=c_ModeNew) then begin
    Lib_GuiCom:Disable($edEin.E.VSB_Datum);
    Lib_GuiCom:Disable($edEin.E.Eingang_Datum);
    Lib_GuiCom:Disable($edEin.E.Ausfall_Datum);

    vMEHString # StrCnv(Ein.P.MEH.Wunsch+'|'+Ein.P.MEH.Preis+'|'+Ein.P.MEH,_Strupper);
    // eine MEH<>Stk und <>Gewicht finden...
    if (StrCnv(Ein.P.MEH.Wunsch,_Strupper)<>'STK') and
      (StrCnv(Ein.P.MEH.Wunsch,_Strupper)<>'KG') and
      (StrCnv(Ein.P.MEH.Wunsch,_Strupper)<>'T') then vMEH # Ein.P.MEH.Wunsch
    else if (StrCnv(Ein.P.MEH.Preis,_Strupper)<>'STK') and
      (StrCnv(Ein.P.MEH.Preis,_Strupper)<>'KG') and
      (StrCnv(Ein.P.MEH.Preis,_Strupper)<>'T') then vMEH # Ein.P.MEH.Preis
    else
      vMEH # Ein.P.MEH;

//    if (StrCnv(Ein.P.MEH,_Strupper)<>'STK') and
//      (StrCnv(Ein.P.MEH,_Strupper)<>'KG') and
//      (StrCnv(Ein.P.MEH,_Strupper)<>'T') then vMEH # Ein.P.MEH
//    else vMEH # 'Stk';

    if (aBehalten = false) then begin
      Ein.E.Nummer          # Ein.P.Nummer;
      Ein.E.Position        # Ein.P.Position;
      Ein.E.Lieferantennr   # Ein.P.Lieferantennr;
//      Ein.E.Lageradresse    # Ein.Lieferadresse;
//      Ein.E.Lageranschrift  # Ein.Lieferanschrift;

      Ein.E.Warengruppe # Ein.P.Warengruppe;
      Ein.E.MEH         # vMEH;

      if ("Set.Ein.WE.Stückzahl">1) then begin
        "Ein.E.Stückzahl"     # Ein.P.FM.Rest.Stk;
        Ein.E.Menge           # Ein.P.FM.Rest;
      end
      else begin
        "Ein.E.Stückzahl"     # "Set.Ein.WE.Stückzahl";
      end;

      Ein.E.Preis         # Ein.P.GrundPreis;
      "Ein.E.Währung"     # "Ein.Währung";
      //Ein.E.ArtikelID   # Ein.P.ArtikelID;
      Ein.E.Artikelnr   # Ein.P.Artikelnr;
      Ein.E.Dicke       # Ein.P.Dicke;
      Ein.E.Breite      # Ein.P.Breite;
      "Ein.E.Länge"     # "Ein.P.Länge";
      Ein.E.RID         # Ein.P.RID;
      Ein.E.RAD         # Ein.P.RAD;
      RunAFX('Ein.E.RecInit.Post', '0');
    end
    else begin
      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);

      // Focus von den "spannenden" Feldern weg, damit diese autom. refreshen
      $cbEin.E.AusfallYN->WinFocusSet(true);

      Ein.E.Charge        # '';
      Ein.E.Menge           # 0.0;
      "Ein.E.Stückzahl"     # 0;
      Ein.E.Gewicht         # 0.0;
      Ein.E.Gewicht.Netto   # 0.0;
      Ein.E.Gewicht.Brutto  # 0.0;
      Ein.E.Materialnr      # 0;
      RunAFX('Ein.E.RecInit.Post', '1');
    end;

  end
  else begin  // Edit...
    if (Ein.E.VSBYN) then begin
      Lib_GuiCom:Disable($edEin.E.Eingang_Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall_Datum);
    end;
    if (Ein.E.EingangYN) then begin
      Lib_GuiCom:Disable($edEin.E.VSB_Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall_Datum);
    end;
    if (Ein.E.AusfallYN) then begin
      Lib_GuiCom:Disable($edEin.E.VSB_Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang_Datum);
    end;
  end;


  if (StrCnv(Ein.E.MEH,_Strupper)='STK') or (StrCnv(Ein.E.MEH,_Strupper)='KG') or
    (StrCnv(Ein.E.MEH,_Strupper)='T') or (Mode=c_ModeEdit) then
    Lib_GuiCom:Disable($edEin.E.Menge)
  else
    Lib_GuiCom:Enable($edEin.E.Menge);
/***
  if ((Strfind(vMEHString,'KG',0)<>0) or
    (Strfind(vMEHString,'T',0)<>0)) and (Mode<>c_ModeEdit) then
    Lib_GuiCom:Enable($edEin.E.Gewicht)
  else
    Lib_GuiCom:Disable($edEin.E.Gewicht);

  if (Strfind(vMEHString,'STK',0)<>0) and (Mode<>c_ModeEdit) then
    Lib_GuiCom:Enable($edEin.E.Stueckzahl)
  else
    Lib_GuiCom:Disable($edEin.E.Stueckzahl);
***/

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vBuf506   : int;
  vDel      : logic;
  vKillRest : logic;
  vProz     : float;
  vNr       : int;
  vlfd      : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if ((Ein.E.VSBYN = false) and (Ein.E.EingangYN = false) and (Ein.E.AusfallYN = false)) or
    ((Ein.E.VSB_Datum = 0.0.0) and (Ein.E.Eingang_Datum = 0.0.0) and (Ein.E.Ausfall_Datum = 0.0.0)) then begin
    Msg(506002,'',0,0,0);
    $cbEin.E.VSBYN->WinFocusSet(true);
    RETURN false;
  end;

  if ((Ein.E.VSBYN) and (Ein.E.VSBYN = true) and (Ein.E.VSB_Datum = 0.0.0)) then begin
    Msg(001200,Translate('VSB-Datum'),0,0,0);
    $edEin.E.VSB_Datum->WinFocusSet(true);
    RETURN false;
  end;
  if ((Ein.E.EingangYN) and (Ein.E.EingangYN = true) and (Ein.E.Eingang_Datum = 0.0.0)) then begin
    Msg(001200,Translate('Eingangsdatum'),0,0,0);
    $edEin.E.Eingang_Datum->WinFocusSet(true);
    RETURN false;
  end;
  if ((Ein.E.AusfallYN) and (Ein.E.AusfallYN = true) and (Ein.E.Ausfall_Datum = 0.0.0)) then begin
    Msg(001200,Translate('Ausfalldatum'),0,0,0);
    $edEin.E.Ausfall_Datum->WinFocusSet(true);
    RETURN false;
  end;

  // Prüfung auf Abschlussdatum
  if (Ein.E.VSB_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.VSB_Datum) = false) then begin
    Msg(001400 ,Translate('VSB Datum') + '|'+ CnvAd(Ein.E.VSB_Datum),0,0,0);
    $edEin.E.VSB_Datum->WinFocusSet(true);
    RETURN false;
  end;
  if (Ein.E.Eingang_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.Eingang_Datum) = false) then begin
    Msg(001400 ,Translate('Eingangsdatum') + '|'+ CnvAd(Ein.E.Eingang_Datum),0,0,0);
    $edEin.E.Eingang_Datum->WinFocusSet(true);
    RETURN false;
  end;
  if (Ein.E.Ausfall_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.Ausfall_Datum) = false) then begin
    Msg(001400 ,Translate('Ausfalldatum') + '|'+ CnvAd(Ein.E.Ausfall_Datum),0,0,0);
    $edEin.E.Ausfall_Datum->WinFocusSet(true);
    RETURN false;
  end;



  // Negativ-Kontrolllogik von Ein_E_Mat_Main [PW/22.09.09]
  if ("Ein.E.Stückzahl"<0) then begin
    Msg(001205,Translate('Stückzahl'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Stueckzahl->WinFocusSet(true);
    RETURN false;
  end
  if (Ein.E.Gewicht<0.0) then begin
    Msg(001205,Translate('Gewicht'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Gewicht->WinFocusSet(true);
    RETURN false;
  end;

  // Adress- und Anschriftsprüfung
  If (Ein.E.Lageradresse=0) then begin
    Msg(001200,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(100,506,6,0);   // Lageradresse holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;
  If (Ein.E.Lageranschrift=0) then begin
    Msg(001200,Translate('Lageranschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageranschrift->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(101,506,7,0);   // Lageranschrift holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lageranschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageranschrift->WinFocusSet(true);
    RETURN false;
  end;
  /* ------ */

  if (Ein.E.Art.Zustand<>0) then begin
    Erx # RecLink(856,506,17,_recFirst);  // Zustand holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Zustand'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edEin.E.Art.Zustand->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Ein.E.Menge<=0.0) then begin
    if (Ein.E.Menge=0.0) then
      Msg(001200,Translate('Menge'),0,0,0);
    else
      Msg(001205,Translate('Menge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Menge->WinFocusSet(true);
    RETURN false;
  end;


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren

  Wae_Umrechnen(Ein.E.Preis, "Ein.E.Währung", var Ein.E.PreisW1, 1);

  TRANSON;

  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Vorgang buchen
    if (Ein_E_Data:Verbuchen(n)=false) then begin
      TRANSBRK;
      Msg(506001,'',0,0,0);
      RETURN false;
    end;

    PtD_Main:Compare(gFile);

  end
  else begin        // Neuanlage

    Ein.E.Eingangsnr    # 0;
    Ein.E.Anlage.User   # gUserName;
    REPEAT
      Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
      Ein.E.Anlage.Datum  # Today;
      Ein.E.Anlage.Zeit   # Now;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (erx=_rOK);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Vorgang buchen
    if (Ein_E_Data:Verbuchen(y)=false) then begin
      TRANSBRK;
      Msg(506001,'',0,0,0);
      RETURN false;
    end;

  end;


  TRANSOFF;

  if (Mode=c_ModeNew) then begin
    if (Set.Ein.WE.Weitere='') and ("Ein.P.Löschmarker"='') then begin
      if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        RecInit(true);
        RETURN false;
      end
      else begin
//        RETURN true;
      end;
    end;
  end; // Weitermachen mit eingeben?



  // 21.08.2012 AI
  // Rest als Ausfall? ...........................
  vDel # y;
  if (Mode=c_ModeNew) and ($lb.GegenVSB->wpcustom='') and (Ein.p.FM.Rest>0.0) then begin
// 05.05.2015    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.VSB + Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge.Wunsch);
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.VSB + Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
//todo('das sind %:'+anum(vProz,2));
    if (vProz>="Set.Ein.WEDelEin%") then begin
      vKillRest # y;
      if (Set.Ein.WEDelEinAuto=2) then vKillRest # false;   // 12.03.2020 AH
      if (Set.Ein.WEDelEinAuto=1) then
        if (Msg(506018, anum(Ein.P.FM.Rest, Set.Stellen.Menge)+'|'+Ein.P.MEH.Wunsch,_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then begin
          vKillRest # n;
          vDel      # n;
        end;
    end
    else begin
      vDel # n;
      if (Set.Ein.WE.RstAsflYN) then
        if (Msg(506018, anum(Ein.P.FM.Rest, Set.Stellen.Menge)+'|'+Ein.P.MEH.Wunsch,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
          vKillRest # y;
          vDel      # y;
        end;
    end;
  end;
  if (vKillRest) then begin
    vBuf506 # RekSave(506);
    RecInit(n);
    Ein.E.AusfallYN     # y;
    Ein.E.Ausfall_Datum # today;
    Ein.E.EingangYN     # n;
    Ein.E.Eingang_Datum # 0.0.0;

    "Ein.E.Stückzahl"   # Ein.P.FM.Rest.Stk;
    if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
      Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    end;
    if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
      Ein.E.Menge # Ein.E.Gewicht;
    end;
    if (Ein.E.Gewicht.Brutto=0.0) then
      Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
    if (Ein.E.Gewicht.Netto=0.0) then
      Ein.E.Gewicht.Netto # Ein.E.Gewicht;

    // Ausführungen kopieren
    vNr               # Ein.E.Eingangsnr;
    Ein.E.Nummer      # myTmpNummer;
    Ein.E.Eingangsnr  # vlfd;
    WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
      RecRead(507,1,_RecLock);
      Ein.E.AF.Nummer  # Ein.P.Nummer;
      Ein.E.AF.Eingang # vNr;
      RekReplace(507,_recUnlock,'AUTO');
    END;
    Ein.E.Nummer      # Ein.P.Nummer;
    Ein.E.Eingangsnr  # vNr;


    Ein.E.Nummer        # Ein.P.Nummer;
    Ein.E.Anlage.User   # gUserName;
    vLfd                # Ein.E.Eingangsnr;
    REPEAT
      Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
      Ein.E.Anlage.Datum  # Today;
      Ein.E.Anlage.Zeit   # Now;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (Erx=_rOK);

    if (Ein_E_Data:Verbuchen(y)=false) then begin
      RekRestore(vBuf506);
      Error(506001,'');
      ErrorOutput;
      RETURN true;
    end;
    RekRestore(vBuf506);
  end;    // ... Rest als Ausfall



  // Pos Löschen?
  if (vDel) and (Mode=c_ModeNew) and ("Ein.P.Löschmarker"='') then begin
    vBuf506 # RekSave(506);
    Erx # RecLink(506,501,14,_recFirst);  // WE loopen
    WHILE (Erx<=_rLocked) and (vDel) do begin
      if (Ein.E.VSBYN) and ("Ein.E.Löschmarker"='') then begin
        vDel # n;
        BREAK;
      end;
      Erx # RecLink(506,501,14,_recNext);
    END;
    RekRestore(vBuf506);
  end;

  // dürfte löschen?
  if (vDel) then begin

// 05.05.2015   vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge.Wunsch);
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
    vDel # (vProz>="Set.Ein.WEDelEin%");


    // 19.07.2017 AH:
    if (vDel) and (vKillRest=false) and (Ein.P.Materialnr<>0) then begin
      Erx # RecLink(200,501,13,_recFirst);  // Material holen
      if (Erx<=_rLocked) then begin
        if (RecLinkInfo(203,200,13,_reccount)>0) then begin
          Msg(506022,'',0,0,0);
          vDel # false;
        end;
      end;
    end;


    // ...% erreicht?
    if (vDel) and (vKillRest=false) then begin
      if (Set.Ein.WEDelEinAuto=1) then
        vDel # (Msg(506019,anum(vProz,2), _WinIcoQuestion, _WinDialogYesNo, 1)=_winidyes);
    end;

    // Position löschen?
    if (vDel) then
      if (Ein_P_Subs:ToggleLoeschmarker(n)) then
        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then
          Ein_Data:UpdateMaterial();
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

  if ("Ein.E.Löschmarker"='*') then RETURN;
  
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    TRANSON;
    RecRead(506,1,_recLock);
    PtD_Main:Memorize(506);
    "Ein.E.Löschmarker" # '*';
    Erx # RekReplace(506,_recUnlock,'MAN');
    if (Erx<>_rOK) then begin
      Ptd_Main:Forget(506);
      TRANSBRK;
      RETURN;
    end;
    if (Ein_E_Data:Verbuchen(n)=false) then begin
      Ptd_Main:Forget(506);
      TRANSBRK;
      ErrorOutput;
      RETURN;
    end;
    PtD_Main:Compare(506);
    TRANSOFF;
    RETURN
  end;

//  RekDelete(gFile,0,'MAN');
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
  // automatische Berechnungen
  if ( aEvt:obj->wpName = 'edEin.E.Gewicht' ) or ( aEvt:obj->wpName = 'edEin.E.Stueckzahl' ) or ( aEvt:obj->wpName = 'edEin.E.Menge' ) then begin
    $edEin.E.Stueckzahl->WinUpdate( _winUpdObj2Fld );
    $edEin.E.Gewicht->WinUpdate( _winUpdObj2Fld );
    $edEin.E.Stueckzahl->WinUpdate( _winUpdObj2Fld );

    case aEvt:obj->wpName of
      'edEin.E.Stueckzahl' : begin
        if ( "Ein.E.Stückzahl" != 0 ) then begin
          if ( Ein.E.Gewicht = 0.0 ) then
            Ein.E.Gewicht # Lib_Einheiten:WandleMEH( 506, "Ein.E.Stückzahl", 0.0, Ein.E.Menge, Ein.E.MEH, 'kg' );
          if ( Ein.E.Menge = 0.0 ) then
            Ein.E.Menge # Lib_Einheiten:WandleMEH( 506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0, '', Ein.E.MEH );

          $edEin.E.Gewicht->WinUpdate( _winUpdFld2Obj );
          $edEin.E.Menge->WinUpdate( _winUpdFld2Obj );
        end;
      end;

      'edEin.E.Gewicht' : begin
        if ( "Ein.E.Gewicht" != 0.0 ) then begin
          if ( "Ein.E.Stückzahl" = 0 ) then
            "Ein.E.Stückzahl" # CnvIF( Lib_Einheiten:WandleMEH( 506, 0, Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, 'Stk' ) );
          if ( Ein.E.Menge = 0.0 ) then
            Ein.E.Menge # Lib_Einheiten:WandleMEH( 506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0, '', Ein.E.MEH );

          $edEin.E.Stueckzahl->WinUpdate( _winUpdFld2Obj );
          $edEin.E.Menge->WinUpdate( _winUpdFld2Obj );
        end;
      end;

      'edEin.E.Menge' : begin
        if ( Ein.E.Menge != 0.0 ) then begin
          if ( Ein.E.Gewicht = 0.0 ) then
            Ein.E.Gewicht # Lib_Einheiten:WandleMEH( 506, "Ein.E.Stückzahl", 0.0, Ein.E.Menge, Ein.E.MEH, 'kg' );
          if ( "Ein.E.Stückzahl" = 0 ) then
            "Ein.E.Stückzahl" # CnvIF( Lib_Einheiten:WandleMEH( 506, 0, Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, 'Stk' ) );

          $edEin.E.Gewicht->WinUpdate( _winUpdFld2Obj );
          $edEin.E.Stueckzahl->WinUpdate( _winUpdFld2Obj );
        end;
      end;
    end;
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aEVT:Obj->wpname='edEin.E.Menge') then begin
    if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
      Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    end;
    if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
      Ein.E.Menge # Ein.E.Gewicht;
    end;
    if (StrCnv(Ein.E.MEH,_Strupper)='T') then begin
      Ein.E.Menge # Rnd(Ein.E.Gewicht / 1000.0, Set.Stellen.Gewicht);
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
  Erx   : int;
  vA    : alpha;
  vHdl  : int;
  vQ    : alpha;
end;

begin

  case aBereich of

    'Lageradresse' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLageradresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      Erx # RecLink(100,506,6,_recFirst);   // Lageradresse holen
      if (Erx>_rLocked) then RETURN;
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


    'Lagerplatz' : begin
      RecBufClear(844);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung','Ein_E_Main:AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zustand' : begin
      RecBufClear(856);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Zst.Verwaltung',here+':AusZustand');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

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
    Ein.E.Lagerplatz # Lpl.Lagerplatz;
    // Feldübernahme
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Lagerplatz->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusLageradresse
//
//========================================================================
sub AusLageradresse()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Lageradresse # Adr.Nummer;
    Ein.E.Lageranschrift # 1;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  Refreshifm('');
end;


//========================================================================
//  AusLageranschrift
//
//========================================================================
sub AusLageranschrift()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Lageradresse    # Adr.A.Adressnr;
    Ein.E.Lageranschrift  # Adr.A.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  Refreshifm('');
end;


//========================================================================
//  AusZustand
//
//========================================================================
sub AusZustand()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(856,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Art.Zustand # Art.Zst.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Art.Zustand->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx         : int;
  vHdl        : int;
  vOK         : logic;
  vVerbucht   : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vHdl->wpDisabled) or (Rechte[Rgt_EK_E_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vHdl->wpDisabled) or (Rechte[Rgt_EK_E_Anlegen]=n);

  // schon in EKK verbucht? -> Nicht änderbar!
  vVerbucht # EKK_Data:BereitsVerbuchtYN(506);

  // wenn schon Reservierungen auf dem Material liegen, darf es nicht verändert werden
  if (Ein.E.MaterialNr<>0) then begin
    Erx # RecLink(200,506,8,_recFirst);
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,506,9,_recFirst);
      if (Erx<=_rLocked) then RecBufCopy(210,200);
    end;
    if (Erx>_rLocked) then begin
      vOK # n;
    end
    else begin
      if (Mat.Reserviert.Stk<>0) or (Mat.Reserviert.Gew<>0.0) then vOK # n;
    end;
  end;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Aendern]=n) or (vOK);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Aendern]=n) or (vOK);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vVerbucht) or (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vVerbucht) or (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Loeschen]=n);

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

    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edEin.E.Gewicht') then begin
        //Ein.E.Gewicht # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.E.Stückzahl", Ein.E.Dicke, Ein.E.Breite, "Ein.E.länge", Ein.E.Warengruppe, Ein.E.Artikelnr);
        Ein.E.Gewicht # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", 0.0, Ein.E.Menge, Ein.E.MEH, 'kg');
        $edEin.E.Gewicht->winupdate(_WinUpdFld2Obj);
        $edEin.E.Gewicht->winFocusset(true);
        EvtChanged(aEvt);
      end;
      if (aEvt:Obj->wpname='edEin.E.Stueckzahl') then begin
        //"Ein.E.Stückzahl" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Ein.E.Gewicht, Ein.E.Dicke, Ein.E.Breite, "Ein.E.länge", Ein.E.Warengruppe, Ein.E.Artikelnr);
        "Ein.E.Stückzahl" # cnvif(Lib_Einheiten:WandleMEH(506, 0, Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, 'Stk'));
        $edEin.E.Stueckzahl->winupdate(_WinUpdFld2Obj);
        $edEin.E.Stueckzahl->winFocusset(true);
        EvtChanged(aEvt);
      end;
      if (aEvt:Obj->wpname='edEin.E.Menge') then begin
        Ein.E.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0, '', Ein.E.MEH);
        $edEin.E.Menge->winupdate(_WinUpdFld2Obj);
        $edEin.E.Menge->winFocusset(true);
        EvtChanged(aEvt);
      end;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Ein.E.Anlage.Datum, Ein.E.Anlage.Zeit, Ein.E.Anlage.User);
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
    'bt.Adresse'    :   Auswahl('Lageradresse');
    'bt.Anschrift'  :   Auswahl('Lageranschrift');
    'bt.Lagerplatz' :   Auswahl('Lagerplatz');
    'bt.Zustand'    :   Auswahl('Zustand');
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

  if (aEvt:Obj->wpname='edEin.E.Stueckzahl') and (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    $edEin.E.Stueckzahl->Winupdate(_WinUpdObj2Fld);
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    $edEin.E.Menge->Winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='edEin.E.Gewicht') and (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    $edEin.E.Gewicht->Winupdate(_WinUpdObj2Fld);
    Ein.E.Menge # Ein.E.Gewicht;
    $edEin.E.Menge->Winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='cbEin.E.VSBYN') and (Ein.E.VSBYN) then begin

    if (Ein.E.Lageradresse = 0) then begin
      // Adressnummer des Lieferanten lesen
      if (RecLink(100,500,1,0) <= _rLocked) then begin
        Ein.E.Lageradresse    # Adr.Nummer;
        Ein.E.Lageranschrift  # 1;
        $edEin.E.Lageradresse->winupdate(_WinUpdFld2Obj);
        $edEin.E.Lageranschrift->winupdate(_WinUpdFld2Obj);
        App_Main:EvtFocusTerm(aEvt, $edEin.E.Lageradresse);
        $edEin.E.Lageradresse->winfocusset();
        RefreshIfm();
       end;
    end;

    Ein.E.EingangYN # n;
    Ein.E.AusfallYN # n;
    Ein.E.VSB_Datum # today;
    if (Mode=c_ModeNew) then begin
      Ein.E.Eingang_Datum # 0.0.0;
      Ein.E.Ausfall_Datum # 0.0.0;
    end;

    $cbEin.E.EingangYN->winupdate(_WinUpdFld2Obj);
    $cbEin.E.AusfallYN->winupdate(_WinUpdFld2Obj);
    $edEin.E.VSB_Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Eingang_Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Ausfall_Datum->winupdate(_WinUpdFld2Obj);


    if (Mode=c_ModeNew) then begin
      Lib_GuiCom:Enable($edEin.E.VSB_Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang_Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall_Datum);
    end;

  end;

  if (aEvt:Obj->wpname='cbEin.E.EingangYN') and (Ein.E.EingangYN) then begin

    if (Ein.E.Lageradresse = 0) then begin
      // Adressnummer des Lieferanten lesen
      if (RecLink(100,500,1,0) <= _rLocked) then begin
        Ein.E.Lageradresse    # Ein.Lieferadresse;
        Ein.E.Lageranschrift  # Ein.Lieferanschrift;
        $edEin.E.Lageradresse->winupdate(_WinUpdFld2Obj);
        $edEin.E.Lageranschrift->winupdate(_WinUpdFld2Obj);
        App_Main:EvtFocusTerm(aEvt, $edEin.E.Lageradresse);
        $edEin.E.Lageradresse->winfocusset();
        RefreshIfm();
       end;
    end;

    Ein.E.VSBYN # n;
    Ein.E.AusfallYN # n;
    Ein.E.Eingang_Datum # today;
    if (Mode=c_ModeNew) then begin
      Ein.E.VSB_Datum     # 0.0.0;
      Ein.E.Ausfall_Datum # 0.0.0;
    end;
    $cbEin.E.VSBYN->winupdate(_WinUpdFld2Obj);
    $cbEin.E.AusfallYN->winupdate(_WinUpdFld2Obj);
    $edEin.E.VSB_Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Eingang_Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Ausfall_Datum->winupdate(_WinUpdFld2Obj);


    if (Mode=c_ModeNew) then begin
      Lib_GuiCom:Enable($edEin.E.Eingang_Datum);
      Lib_GuiCom:Disable($edEin.E.VSB_Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall_Datum);
    end;
  end;

  if (aEvt:Obj->wpname='cbEin.E.AusfallYN') and (Ein.E.AusfallYN) then begin
    Ein.E.EingangYN # n;
    Ein.E.VSBYN # n;
    Ein.E.Ausfall_Datum # today;
    if (Mode=c_ModeNew) then begin
      Ein.E.VSB_Datum     # 0.0.0;
      Ein.E.Eingang_Datum # 0.0.0;
    end;
    $cbEin.E.EingangYN->winupdate(_WinUpdFld2Obj);
    $cbEin.E.VSBYN->winupdate(_WinUpdFld2Obj);
    $edEin.E.VSB_Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Eingang_Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Ausfall_Datum->winupdate(_WinUpdFld2Obj);


    if (Mode=c_ModeNew) then begin
      Lib_GuiCom:Enable($edEin.E.Ausfall_Datum);
      Lib_GuiCom:Disable($edEin.E.VSB_Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang_Datum);
    end;
  end;

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
  Erx : int;
end;
begin

  // AFX  2023-02-22  AH
  if (aMark) then begin
    if (RunAFX('Ein.E.EvtLstDataInit','y')<0) then RETURN;
  end
  else if (RunAFX('Ein.E.EvtLstDataInit','n')<0) then RETURN;

  GV.Num.01 # Ein.E.Preisw1 * Ein.E.Menge / cnvfi(Ein.P.PEH); // 2023-02-22 AH

  if (Ein.P.Position<>ein.E.Position) or (Ein.E.Nummer<>Ein.P.Nummer) then begin
    Erx # RecLink(501,506,1,_recFirst);   // Position holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(511,506,11,_recFirst);   // Positionsablage holen
      RecBufCopy(511,501);
    end;
  end;

  if (aMark=n) then begin
    if ("Ein.E.Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else if (Ein.E.VSBYN) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Bestellt)
    else if (Ein.E.AusfallYN) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Reserv);
  end;
  Refreshmode();  // 2022-11-03 AH
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
  Erx : int;
end;
begin
  RecRead(gFile,0,_recid,aRecID);
  if (Ein.E.Nummer<>0) then begin
    Erx # RecLink(501,506,1,_recFirst);   // Position holen
    if (Erx<>_rOK) then begin
      Erx # RecLink(511,506,11,_recFirst);   // Positionsablage holen
      if (Erx<>_rOK) then RecBufClear(511);
      RecBufCopy(511,501);
    end;
  end;
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
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edEin.E.Lageradresse') AND (aBuf->Ein.E.Lageradresse<>0)) then begin
    RekLink(100,506,6,0);   // Lageradresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.E.Lageranschrift') AND (aBuf->Ein.E.Lageranschrift<>0)) then begin
    RekLink(101,506,7,0);   // Anschrift holen
    Adr.A.Adressnr # Ein.E.Lageradresse;
    Adr.A.Nummer # Ein.E.Lageranschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Ein.E.Lageradresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
   if ((aName =^ 'edEin.E.Lagerplatz') AND (aBuf->Ein.E.Lagerplatz<>'')) then begin
    LPl.Lagerplatz # Ein.E.Lagerplatz;
    recRead(844,1,0)
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Art.Zustand') AND (aBuf->Ein.E.Art.Zustand<>0)) then begin
    RekLink(856,506,17,0);   // Zustand holen
    Lib_Guicom2:JumpToWindow('Art.Zst.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
