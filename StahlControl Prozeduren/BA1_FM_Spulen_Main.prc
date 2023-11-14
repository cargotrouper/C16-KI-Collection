@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_Spulen_Main
//                OHNE E_R_G
//  Info
//
//
//  06.10.2009  AI  Erstellung der Prozedur
//  22.12.2010  MS  Eigenes Menue
//  03.01.2012  AI  Obf.Gegenteil=9999 löscht alles
//  01.08.2014  ST  "RecSave" Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  20.05.2015  AH  Ausführungen wurden nicht angezeigt (wegen myTmpNummer)
//  27.07.2021  AH  ERX
//  20.07.2022  HA  Quick jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusArtikel()
//    SUB AusStruktur()
//    SUB Wiegedaten()
//    SUB AusVerwiegungsart()
//    SUB AusLagerplatz()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic;) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin
  cDialog :   $BA1.FM.Spulen.Maske
  cTitle :    'Fertigmeldung'
  cFile :     707
  cMenuName : 'BA1.FM.Spulen.Bearbeiten'
  cPrefix :   'BA1_FM_Spulen'
//  cZList :    0
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
local begin
  vHdl  : int;
  vM    : Float;
  vGew  : float;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # 0;//cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edBAG.FM.Artikelnr);
Lib_Guicom2:Underline($edBAG.FM.Verwiegungart);
Lib_Guicom2:Underline($edBAG.FM.Lagerplatz);

  SetStdAusFeld('edBAG.FM.Verwiegungart'  ,'Verwiegungsart');
  SetStdAusFeld('edBAG.FM.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edBAG.FM.Artikelnr'      ,'Struktur');
  SetStdAusFeld('edBAG.FM.AusfOben'       ,'AF.Oben');
  SetStdAusFeld('edBAG.FM.AusfUnten'      ,'AF.Unten');

  RETURN App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin

  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx : int;
  va  : alphA;
  vX  : int;

  vBB   : float;
  vBL   : float;
  vBGew : float;
  vBM   : float;
  vL    : float;
  vGew  : float;
  vM    : float;

  vInStk  : int;
  vInGew  : float;
  vInME   : float;
  vOutME  : float;
  vBuf701 : int;
  vBuf707 : int;
  vHdl    : handle;
  vTmp    : int;
  vItem   : handle;
end;
begin

  if (aName='') or (aName='edBAG.FM.Verwiegungart') then begin
    Erx # RecLink(818,707,6,_recfirst);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
    $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1;
  end;


  if (aName='') then begin

    // Einsatz anzeigen
    vHdl # Winsearch(gMDI,'hdl.Inputlist');
    vHdl # cnvia(vHdl->wpcustom);
    vItem # vHdl->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      BAG.IO.Nummer # BAG.P.Nummer;
      BAG.IO.ID     # cnvia(vItem->spName);
      Erx # RecRead(701,1,0);   // Einsatz holen
      if (Erx<=_rLocked) then begin
        vA      # vItem->spcustom;
        vInStk  # vInStk + cnvia(Str_Token(vA, '|', 1));
        vInGew  # vInGew + cnvfa(Str_Token(vA, '|', 2));
        vL # BAG.IO.Plan.Out.Meng / cnvfi(BAG.IO.PLan.Out.Stk) * cnvfa(Str_Token(vA, '|', 1));
        vInME # vInME + vL;
      end;
      vItem # vHdl->CteRead(_CteNext, vItem);
    END;

    BAG.IO.Plan.Out.GewB  # vInGew;
    BAG.IO.Plan.Out.Stk   # vInStk;

    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";
    $Lb.AusfOben.E->wpcaption   # BAG.IO.AusfOben;
    $Lb.AusfUnten.E->wpcaption  # BAG.IO.AusfUnten;
    $Lb.Struktur.E->wpcaption   # Mat.Strukturnr;
    $Lb.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke");
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite,"Set.Stellen.Breite");
    $Lb.Dickentol.E->wpcaption  # BAG.IO.Dickentol;
    $Lb.Breitentol.E->wpcaption # BAG.IO.Breitentol;

    $Lb.Stueck.E->wpcaption     # AInt(BAG.IO.Plan.Out.Stk);

// LFA-Update vInMeng # BAG.IO.Plan.Out.Meng;
    vBuf701 # RekSave(701);
    BA1_F_Data:SumInput(BAG.F.MEH);
//    vInME # BAG.IO.Plan.Out.Meng;
    RekRestore(vBuf701);

    if (BAG.IO.MEH.Out=BAG.F.MEH) then begin
      vOutME # BAG.IO.Ist.Out.Menge;
    end
    else begin
      vBuf707 # RekSave(707);
      Erx # RecLink(707,703,10,_RecFirst);    // Fertigmeldungen loopen
      WHILE (Erx<=_rLocked) do begin
        vOutME # vOutME + BAG.FM.Menge;
        Erx # RecLink(707,703,10,_recNext);
      END;
      RekRestore(vBuf707);
    end;

    // SCHOPF??
    if (BAG.F.AutomatischYN) and (BAG.F.Fertigung=999) then begin
      vInGew  # BAG.IO.Plan.In.GewB   - BAG.IO.Plan.Out.GewB;
      vInME   # BAG.IO.Plan.In.Menge  - BAG.IO.Plan.Out.Meng;
    end;
    $Lb.Stueck.E->wpcaption     # AInt(vInStk);
    $Lb.Gewicht.E->wpcaption    # ANum(vInGew,"Set.Stellen.Gewicht");
    $Lb.Menge.E->wpcaption      # ANum(vInME,"Set.Stellen.Menge");


    // geplant anzeigen
    $Lb.Guete.F->wpcaption      # "BAG.F.Güte";
    $Lb.GuetenStufe.F->wpcaption # "BAG.F.Gütenstufe";
    $Lb.AusfOben.F->wpcaption   # BAG.F.AusfOben;
    $Lb.AusfUnten.F->wpcaption  # BAG.F.AusfUnten;
    $Lb.Struktur.F->wpcaption   # BAG.F.ARtikelnummer;
    $Lb.Dicke.F->wpcaption      # ANum(BAG.F.Dicke,"Set.Stellen.Dicke");
    $Lb.Breite.F->wpcaption     # ANum(BAG.F.Breite,"Set.Stellen.Breite");
    $Lb.Dickentol.F->wpcaption  # BAG.F.Dickentol;
    $Lb.Breitentol.F->wpcaption # BAG.F.Breitentol;
    $Lb.Stueck.F->wpcaption     # AInt("BAG.F.Stückzahl");
    $Lb.Gewicht.F->wpcaption    # ANum(BAG.F.Gewicht,"Set.Stellen.Gewicht");
    $Lb.Menge.F->wpcaption      # ANum(BAG.F.Menge,"Set.Stellen.Menge");

    $lb.MEH_E->wpcaption    # BAG.F.MEH;
    $lb.MEH_F->wpcaption    # BAG.F.MEH;
    $lb.MEH_FM->wpcaption   # BAG.F.MEH;
    $lb.MEH_FIst->wpcaption # BAG.F.MEH;

    $Lb.Stueck.FIst->wpcaption   # AInt("BAG.F.Fertig.Stk");
    $Lb.Gewicht.FIst->wpcaption  # ANum(BAG.F.Fertig.Gew,"Set.Stellen.Gewicht");
    $Lb.Menge.FIst->wpcaption    # ANum(BAG.F.Fertig.Menge,"Set.Stellen.Menge");

    if (BAG.F.AuftragsNummer<>0) then begin
      $lb.Kommission->wpcaption # BAG.F.Kommission;
    end;

    // Warengruppe anzeigen
    $lb.Warengruppe->wpcaption # AInt(BAG.F.Warengruppe);
    Erx # RecLink(819,703,5,0);
    if (Erx<=_rLocked) then
      $Lb.WgrText->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.WgrText->wpcaption # '';

    // Kunde anzeigen
    Erx # _rOK;
    if ("BAG.F.ReservFürKunde"<>0) then
      Erx # RecLink(100,703,7,0);
    else
      RecBufClear(100);
    if (Erx<=_rLocked) then
      $Lb.Kunde->wpcaption # Adr.Stichwort
    else
      $Lb.Kunde->wpcaption # '';

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
  Erx     : int;
  vTmp    : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);


  // ********************  Rechtecheck *********************************
  // Je nach Berechtigung können z.B. die Abmessungen eingegeben werden
  // oder nicht.
  begin
    if (Rechte[Rgt_BAG_FM_Brutto]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Gewicht.Brutt);

    if (Rechte[Rgt_BAG_FM_Netto]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Gewicht.Netto);

    if (Rechte[Rgt_BAG_FM_AF]=n) then begin
      Lib_GuiCom:Disable($edBAG.FM.AusfOben);
      Lib_GuiCom:Disable($edBAG.FM.AusfUnten);
    end;

    if (Rechte[Rgt_BAG_FM_ABM_D]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Dicke);

    if (Rechte[Rgt_BAG_FM_ABM_B]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Breite);

    if(Rechte[Rgt_BAG_FM_Tara] = false) then
      Lib_GuiCom:Disable($edTara);
  end; // Rechtecheck



  If (BAG.P.Aktion <> c_BAG_AbLaeng) then begin
    // $edBAG.FM.Menge->wpdisabled # y;
    Lib_GuiCom:disable($edBAG.FM.Menge);
  End;

  // je nach Aktion Felder freischalten
  if (Mode=c_ModeNew) then begin
    //Vorbelegen();04.04.2016 AH
    BA1_FM_Data:Vorbelegen();
  end;


  // Nachkommastellen setzen

  $edBAG.FM.Dicke.1->wpDecimals # "Set.Stellen.Dicke";
  $edBAG.FM.Dicke.2->wpDecimals # "Set.Stellen.Dicke";
  $edBAG.FM.Dicke.3->wpDecimals # "Set.Stellen.Dicke";
  $edBAG.FM.Breite.1->wpDecimals # "Set.Stellen.Breite";
  $edBAG.FM.Breite.2->wpDecimals # "Set.Stellen.Breite";
  $edBAG.FM.Breite.3->wpDecimals # "Set.Stellen.Breite";
  $edBAG.FM.Lnge.1->wpDecimals # "Set.Stellen.Länge";
  $edBAG.FM.Lnge.2->wpDecimals # "Set.Stellen.Länge";
  $edBAG.FM.Lnge.3->wpDecimals # "Set.Stellen.Länge";
/* Unbekannte Dezimalstellen
  $edBAG.FM.Rechtwinklig->wpDecimals # ;
  $edBAG.FM.Ebenheit->wpDecimals # ;
  $edBAG.FM.Sbeligkeit->wpDecimals # ;
*/

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('edBAG.FM.Stck');
  vTmp->WinFocusSet(true);
  w_LastFocus # vTmp;
  Erx # gMdi->winsearch('DUMMYNEW');
  Erx->wpcustom # AInt(vTmp);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf703     : int;
  vErx        : int;
  vHdl        : int;
  vTmp        : int;
  vI,vJ       : int;
  vAnz        : int;
  vInputList  : handle;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if (Lib_Faktura:Abschlusstest(BAG.FM.Datum) = false) then begin
    Msg(001400 ,Translate('Fertigmeldungsdatum') + '|'+ CnvAd(BAG.FM.Datum),0,0,0);

    vHdl # gMdi->winsearch('edBAG.FM.Datum');
    if (vHdl > 0) then begin
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl->WinFocusSet(true);
    end;

    RETURN false;
  end;

  // logische Prüfung
  if (BAG.FM.Menge<=0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.FM.Menge->WinFocusSet(true);
    RETURN false;
  end;

  // Messwerterfassung prüfen
  case (Set.BA.FM.MWert.Chk) of
    // Bestimmte Felder müssen ausgefüllt sein
    'PFLICHT': begin
      todo('Pflichtfelder für die Überprüfung müssen noch irgendwo definiert werden können');
    end;

    // Die Maske der MEsserwerte muss zumindest angesehen worden sein
    'INFO':  begin
      if ($NB.Page2->wpCustom <> 'SEEN') then begin
        Msg(707006,'',0,0,0);
        RETURN false;
      end;
    end;

    // Keine Behandlung bei leerem Setting
    '': begin
    end

  end;

  // fehlende Gewichte errechnen
  if ("Set.BA.FM.!CalcGewYN"=false) then begin
    if (BAG.FM.Gewicht.Brutt = 0.0) AND (BAG.FM.Gewicht.Netto <> 0.0) then
      BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto;

    if (BAG.FM.Gewicht.Brutt <> 0.0) AND (BAG.FM.Gewicht.Netto = 0.0) then
      BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt;
  end;

  // Ankerfunktion
  if (RunAFX('BAG.FM.Recsave','Spulen')<>0) then begin
    if (AfxRes=111) then RETURN true;
    if (AfxRes<>_rOK) then RETURN false;
  end;


  // Nummernvergabe...
  // Fertigmeldung verbuchen
  vTmp # Winsearch(gMDI,'hdl.Inputlist');
  vInputList # Cnvia(vTmp->wpcustom);
  if (BA1_Fertigmelden:VerbuchenSpulen(0, vInputList, true)=false) then begin
    Error(707002,'');
    ErrorOutput;
    RETURN false;
  end;

  if (vInputList<>0) then begin
    vInputList->CteClear(true);
    Cteclose(vInputList);
  end;

  Msg(707001,'',0,0,0);

  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');


  gSelected # 1;
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  Erx : int;
end;
begin

  Erx # RecLink(710,707,10,_recFirst);    // Fehler loopen
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(710,0,'MAN');
    Erx # RecLink(710,707,10,_recFirst);
  END;

  Erx # RecLink(708,707,12,_recFirst);    // Bewegungen loopen
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(708,0,'MAN');
    Erx # RecLink(708,707,12,_recFirst);
  END;

  Erx # RecLink(705,707,13,_recFirst);    // Ausführungen loopen
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(705,0,'MAN');
    Erx # RecLink(705,707,13,_recFirst);
  END;

  // ALLE Positionen verwerfen
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
local begin
  vHdl : int;
end;

begin

  if (aEvt:obj->wpname='jump') then begin

    case (aEvt:Obj->wpcustom) of

      'Start' : begin
        $edBAG.FM.AusfOben->winfocusset(false);
      end;

      'Ende' : begin
        $edBAG.FM.Bemerkung->winfocusset(false);
      end;

    end;

    RETURN true;
  end;


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
  vS  : int;
  vL  : float;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);


  if (aEvt:Obj=0) then RETURN true;

  vS # WinInfo(aEvt:Obj,_Wintype);
  if ((vS=_WinTypeEdit) or (vS=_WinTypeFloatEdit) or (vS=_WinTypeIntEdit)) then
    if (aEvt:obj->wpchanged) then begin

    Erx # RecLink(818,707,6,_recfirst);     // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;

    case (aEvt:Obj->wpname) of

      'edTara' : begin
        if (VWa.NettoYN=VWa.BruttoYN) and (VWa.NettoYN=false) then begin
          if (BAG.FM.Gewicht.Brutt=0.0) then
            BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + aEvt:Obj->wpcaptionfloat
          else
            BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - aEvt:Obj->wpcaptionfloat;
        end
        else if (VWa.NettoYN) then begin
          BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + aEvt:Obj->wpcaptionfloat
        end if (VWa.BruttoYN) then begin
          BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - aEvt:Obj->wpcaptionfloat
        end;

        $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
      end;


      'edBAG.FM.Stck' : begin
        Erx # RecLink(818,707,6,_recfirst);
        if (Erx>_rLocked) then begin
          RecBufClear(818);
          VWa.NettoYN # Y;
        end;
        RecLink(819,703,5,_recFirst);   // Warengruppe holen
        if ("Set.BA.FM.!CalcGewYN"=false) then begin
          if (BAG.FM.Gewicht.Netto=0.0) and (VWa.BruttoYN=false) then begin
            BAG.FM.Gewicht.Netto # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.FM.Stück", BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
            $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
          end;
          if (BAG.FM.Gewicht.Brutt=0.0) and (VWa.NettoYN=false) then begin
            BAG.FM.Gewicht.Brutt # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.FM.Stück", BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
            $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
          end;
        end;
      end;


      'edBAG.FM.Gewicht.Netto' : begin
        if ("BAG.FM.Stück"=0) then begin
          RecLink(819,703,5,_recFirst);   // Warengruppe holen
          "BAG.FM.Stück" # Lib_Berechnungen:Stk_aus_kgDBLDichte2(BAG.FM.Gewicht.Netto, BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
          vS # "BAG.FM.Stück";
          $edBAG.FM.Stck->winupdate(_WinUpdFld2Obj);
        end;
      end;

    end;  // case


//    RecLink(819,701,7,_recFirst);   // Warengruppe holen
    Erx # RecLink(819,703,5,0);   // Warengruppe holen
    vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM");

    If (BAG.P.Aktion <> c_BAG_AbLaeng) or (BAG.FM.Menge =0.0) then begin
      if (BAG.FM.MEH='qm') then
        BAG.FM.Menge # BAG.F.Breite * Cnvfi("BAG.FM.Stück") * vL / 1000000.0;
      if (BAG.FM.MEH='Stk') then
        BAG.FM.Menge # cnvfi("BAG.FM.Stück");
      if (BAG.FM.MEH='kg') then
        BAG.FM.Menge # Bag.FM.Gewicht.Netto;
      if (BAG.FM.MEH='t') then
        BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0;
      if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
        BAG.FM.Menge # /*cnvfi("BAG.FM.Stück") * */ vL / 1000.0;
    end;

    $edBAG.FM.Menge->winupdate(_WinUpdFld2Obj);

    // Netto und Bruttoangaben dürfen nicht abweichen
    if  (BAG.FM.Verwiegungart = 2) AND
        (BAG.FM.Gewicht.Netto <> 0.0) AND
        ((BAG.FM.Gewicht.Brutt = BAG.FM.Gewicht.Netto) OR (BAG.FM.Gewicht.Brutt = 0.0))
        then begin
      Msg(707005,'',0,0,0);
//      BAG.FM.Gewicht.Brutt # 0.0;
      $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
      $edBAG.FM.Gewicht.Brutt->WinFocusSet();
    end;

  end;


  if (BAG.FM.Gewicht.Netto<>0.0) and (BAG.FM.Gewicht.Brutt<>0.0) then
    $edTara->wpcaptionfloat # BAG.FM.Gewicht.Brutt - BAG.FM.Gewicht.Netto;

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
  vA      : alpha;
  vFilter : int;
  vTmp    : int;
end;

begin

  case aBereich of


    'AF.Oben'        : begin
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung',here+':AusAFOben');

      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, myTmpNummer);// BAG.FM.Nummer); 20.05.2015
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.FM.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.FM.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, BAG.FM.Fertigmeldung);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '1');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung) + '|' + AInt(BAG.FM.Fertigmeldung) + '|1';

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'AF.Unten'       : begin
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung',here+':AusAFUnten');

      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, myTmpNummer);// BAG.FM.Nummer); 20.05.2015
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.FM.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.FM.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, BAG.FM.Fertigmeldung);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '2');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung) + '|' + AInt(BAG.FM.Fertigmeldung) + '|2';

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Struktur' : begin
      Erx # RecLink(819,703,5,0);   // Warengruppe holen
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

    'Verwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VwA.Verwaltung',Here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Lagerplatz' : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',Here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;

//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
begin

  // gesamtes Fenster aktivieren
  //Lib_GuiCom:SetWindowState(cDialog,true);
  gSelected # 0;

  BAG.FM.AusfOben # Obf_Data:BildeAFString(707,'1');

  // Focus auf Editfeld setzen:
  $edBAG.FM.AusfOben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
begin
  // gesamtes Fenster aktivieren
  //Lib_GuiCom:SetWindowState(cDialog,true);
  gSelected # 0;

  BAG.FM.AusfUnten # Obf_Data:BildeAFString(707,'2');

  // Focus auf Editfeld setzen:
  $edBAG.FM.AusfUnten->Winfocusset(true);
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
    BAG.FM.Artikelnr       # Art.Nummer;
  end;
  // Focus setzen:
  $edBAG.FM.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusStruktur
//
//========================================================================
sub AusStruktur()
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.FM.Artikelnr # MSL.Strukturnr;
  end;
  // Focus setzen:
  $edBAG.FM.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin

  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);

  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    BAG.FM.Verwiegungart # VWA.Nummer;
  end;

  // Focus auf Editfeld setzen:
  $edBAG.FM.Verwiegungart->Winfocusset(true);
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
begin

  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);

  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    gSelected # 0;
    BAG.FM.Lagerplatz # Lpl.Lagerplatz;
  end;

  // Focus auf Editfeld setzen:
  $edBAG.FM.Lagerplatz->Winfocusset(true);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

  vHdl # gMdi->WinSearch('bt.AusfOben');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF]=n);

  vHdl # gMdi->WinSearch('bt.AusfUnten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF]=n);

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
  end; // case

end;


//========================================================================
// IsPageActive
//========================================================================
Sub IsPageActive(aName : alpha) : logic;
begin
  RETURN aName<>'NB.Page3' and  aName<>'NB.Page4';
end


//========================================================================
//  Wiegedaten
//          Liest Wiegedaten aus Datei ein
//========================================================================
sub Wiegedaten()
local begin
end;
begin
  RunAFX('BAG.Waage','');
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
    'bt.Verwiegungsart' :   Auswahl('Verwiegungsart');
    'bt.Lagerplatz'     :   Auswahl('Lagerplatz');
    'bt.Struktur'       :   Auswahl('Struktur');
    'bt.AusfOben'       :   Auswahl('AF.Oben');
    'bt.AusfUnten'      :   Auswahl('AF.Unten');
    'bt.Waage'          :   Wiegedaten();
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
  // Merken, dass Page 2 angesehen wurde
  if (aPage->wpname='NB.Page2' ) then
    $NB.Page2->wpCustom # 'SEEN';
  RETURN true;
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

  if (aEvt:Obj->wpname='cb.gesperrt') and ($cb.gesperrt->wpCheckState=_WinStateChkChecked) then begin
    $cb.Ausfall->wpCheckState # _WinStateChkunChecked;
    BAG.FM.Status # c_Status_BAGfertSperre;
  end;
  if (aEvt:Obj->wpname='cb.Ausfall') and ($cb.Ausfall->wpCheckState=_WinStateChkChecked) then begin
    $cb.gesperrt->wpCheckState # _WinStateChkunChecked;
    BAG.FM.Status # c_Status_BAGAusfall;
  end;
  if ($cb.gesperrt->wpCheckState=_WinStateChkUnChecked) and
    ($cb.Ausfall->wpCheckState=_WinStateChkUnChecked) then begin
    BAG.FM.Status # c_Status_Frei;
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
  
   if ((aName =^ 'edBAG.FM.Artikelnr') AND (aBuf->BAG.FM.Artikelnr<>'')) then begin
    Art.Nummer # BAG.FM.Artikelnr;
    RecRead(250,1,0);
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edBAG.FM.Verwiegungart') AND (aBuf->BAG.FM.Verwiegungart<>0)) then begin
    RekLink(818,707,6,0);   //  Verweigungsart holen
    Lib_Guicom2:JumpToWindow('BA1.AF.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edBAG.FM.Lagerplatz') AND (aBuf->BAG.FM.Lagerplatz<>'')) then begin
    LPl.lagerplatz # BAG.FM.Lagerplatz
    RecRead(844,1,0);
    Lib_Guicom2:JumpToWindow('BA1.AF.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================