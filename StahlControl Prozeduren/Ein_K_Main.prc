@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_K_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  10.05.2022  AH  ERX
//  21.07.2022  HA  Quick Jump
//  2023-01-24  AH  Kalkulationen immer in W1
//  2023-03-17  AH  Kalkulation Change zu HWN
//  2023-06-20  AH  Nachtrags-Kalkulationen-löschen entfernt Mat-Aktion
//  2023-06-22  AH  Korrektur für "%" MEH
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit() : logic;
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Bestell-Kalkulation'
  cFile :     505
  cMenuName : 'Ein.K.Bearbeiten'
  cPrefix :   'Ein_K'
  cZList :    $ZL.Ein.Kalkulation
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
// 2023-02-06 AH  w_ListQuickEdit # y;

  Lib_Guicom2:Underline($edEin.K.LieferantenNr);

  SetStdAusFeld('edEin.K.LieferantenNr'  ,'Lieferant');
  SetStdAusFeld('edEin.K.MEH'            ,'MEH');
  SetStdAusFeld('edEin.K.Termin.Art'     ,'Terminart');

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
  Lib_GuiCom:Pflichtfeld($edEin.K.PEH);
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
  vBuf505 : int;
  vFlag   : int;
  vSumme  : float;
  vSumme2 : float;
  vTmp    : int;
  vX      : float;
  vMenge  : float;
end;
begin

  if (aName='') then begin
    $lb.Nummer->wpcaption # AInt(Ein.K.Nummer);
    $lb.Position->wpcaption # AInt(Ein.K.Position);
    $lb.Lieferant->wpcaption # Ein.P.LieferantenSW;
  end;

  // ++++ Summenfeld ++++
  if (Mode=c_modeList) then begin
    vBuf505 # RekSave(505);
    vFlag # _recFirst;
    vSumme  # 0.0;
    vSumme2 # 0.0;
    WHILE (RecLink(505,501,8,vFlag) <= _rLocked) do begin

      if (Ein.K.MengenbezugYN) then begin
        //Ein.K.Menge # Ein.P.Menge;  2023-03-14  AH
        if (Ein.K.MEH=Ein.P.Meh.Wunsch) then
          Ein.K.Menge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.K.MEH)
        else if (ein.K.MEH<>'%') then // 2023-06-22 AH
          Ein.K.Menge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, Ein.K.MEH);
      end;
      
      If (Ein.K.MEH = Ein.P.MEH.Preis) then begin
        vSumme # vSumme + ((Ein.K.Menge /cnvfi(Ein.K.PEH))*Ein.K.Preis);
      End;
      
      vSumme2 # vSumme2 + ((Ein.K.Menge /cnvfi(Ein.K.PEH))*Ein.K.Preis);
      vFlag # _recNext;
    END;
    RekRestore(vBuf505);

    if (Ein.P.MEH.Preis=Ein.P.Meh.Wunsch) then
      vMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis)
    else
      vMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, Ein.P.MEH.Preis);
    DivOrNull(vSumme, vSumme * CnvFI(Ein.P.PEH), vMenge,2);

    // Ankerfunktion:
    Gv.Num.01 # vSumme;
    Gv.Num.02 # vSumme2;
    RunAFX('Ein.K.Summe','');

    $ed.Summe->wpCaption # ANum(Gv.Num.01,2);
    $ed.Summe2->wpCaption # ANum(Gv.Num.02,2);
  end;


  if (aName='') or (aName='edEin.K.LieferantenNr') then begin
    Erx # RecLink(100,505,1,0);     // Lieferant holen
    if (Erx>_rLocked) or (Ein.K.LieferantenNr=0) then
      $lb.LieferantKalk->wpcaption # ''
    else
      $lb.LieferantKalk->wpcaption # Adr.Stichwort;
  end;

  if ((aName='edEin.K.Termin.Zahl') or (aName='edEin.K.Termin.Jahr')) and
    (($edEin.K.Termin.Zahl->wpchanged) or ($edEin.K.Termin.Jahr->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.K.Termin.Art, var Ein.K.Termin.Zahl, var Ein.K.Termin.Jahr, var Ein.K.Termin);
    $edEin.K.Termin->winupdate(_WinUpdFld2Obj);
  end;
  if (aName='edEin.K.Termin') and
    ($edEin.K.Termin->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.K.Termin, Ein.K.Termin.Art, var Ein.K.Termin.Zahl,var Ein.K.Termin.Jahr);
    $edEin.K.Termin.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.K.Termin.Jahr->winupdate(_WinUpdFld2Obj);
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
sub RecInit() : logic;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    Ein.K.Nummer # Ein.P.Nummer;
    Ein.K.Position # Ein.P.Position;
    Ein.K.LfdNr # 1;
    Ein.K.MEH # 'kg';
    Ein.K.PEH # 1000;
    Ein.K.Termin.Art # 'KW';
    Ein.K.MengenbezugYN # y;
  end;

  $cbEin.K.RckstellungYN->WinFocusSet(true);

  RETURN true;
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
  if (Ein.K.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.K.PEH->WinFocusSet(true);
    RETURN false;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (mode=c_modeList) or (Mode=c_ModeEdListEdit) then RETURN true;

  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else if (Mode=c_ModeNew) then begin
    WHILE (Recread(gFile,1,_RecTest,0)<=_Rlocked) do
      Ein.K.LfdNr # Ein.K.Lfdnr + 1;

    TRANSON;

    Ein.K.Anlage.Datum  # Today;
    Ein.K.Anlage.Zeit   # Now;
    Ein.K.Anlage.User   # gUsername;
    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOK) then
        Ein.K.LfdNr # Ein.K.Lfdnr + 1;
    UNTIL (Erx=_rOK);

    // sofort verbuchen?
    if (Ein.K.NachtragYN) then begin
      if (Ein_E_Data:KalkNachtrag()=false) then begin
//      if (EKK_Data:Update(505)=false) then begin
        TRANSBRK;
        Msg(510505,'',0,0,0);
        RETURN false;
      end;
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
  Erx     : int;
  vOK     : logic;
end;
begin

  // Wareneingang loopen
  vOK # n;
  Erx # RecLink(506,501,14,_RecFirst);
  WHILE (Erx<=_rLocked) and (vOK=n) do begin
    vOK # EKK_Data:BereitsVerbuchtYN(505);
    Erx # RecLink(506,501,14,_Recnext);
  END;

  if (vOK=n) then begin
    // Diesen Eintrag wirklich löschen?
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;
    RekDelete(gFile,0,'MAN');

    TRANSON;    // 2023-06-20 AH
    if (Ein.K.NachtragYN) then begin
      "Ein.K.Löschmarker" # '*';
      if (Ein_E_Data:KalkNachtrag(true)=false) then begin
        TRANSBRK;
        Msg(510505,'',0,0,0);
        RETURN;
      end;
    end;
    Erx # RekDelete(gFile,0,'MAN');
    if (Erx=_rDeadLock) then begin
      Msg(510505,'',0,0,0);
      RETURN;
    end;
    TRANSOFF;
    RETURN;
  end;

  if (Msg(000008,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RecRead(gFile,1,_recLock);
  if ("Ein.K.Löschmarker"='*') then
    "Ein.K.Löschmarker" # ''
  else
    "Ein.K.Löschmarker" # '*';
  RekReplace(gFile,_recUnlock,'MAN');

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

    'Kalkulation' : begin

      // Ankerfunktion
      if (RunAFX('APL.Auswahl','505')<0) then RETURN;

      RecBufClear(842);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ApL.Verwaltung',here+':AusSchluessel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'MEH' : begin
      Lib_Einheiten:Popup('AufpreisEH',$edEin.K.MEH,505,1,11);
    end;

    'Terminart' : begin
      Lib_Einheiten:Popup('Datumstyp',$edEin.K.Termin.Art,505,1,6);
    end;

  end;

end;


//========================================================================
//  AusKalkulation
//
//========================================================================
sub AusKalkulation()
local begin
  Erx : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(830,0,_RecId,gSelected);
    gSelected # 0;

    // Kopieroutine....
    Erx # RecLink(831,830,1,_recFirst);   // Positionen loopen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(505);
      Ein.K.Nummer          # Ein.P.Nummer;
      Ein.K.Position        # Ein.P.Position;
      Ein.K.lfdNr           # 1;
      Ein.K.Bezeichnung     # Kal.P.Bezeichnung;
      Ein.K.Lieferantennr   # Kal.P.Lieferantennr;
      Ein.K.Termin.Art      # Kal.P.Termin.Art;
      Ein.K.Termin.Zahl     # Kal.P.Termin.Zahl
      Ein.K.Termin.Jahr     # Kal.P.Termin.Jahr
      Ein.K.Termin          # Kal.P.Termin
      Ein.K.Menge           # Kal.P.Menge
      Ein.K.MEH             # Kal.P.MEH
      Ein.K.PEH             # Kal.P.PEH
      Ein.K.MengenbezugYN   # Kal.P.MengenbezugYN
      Ein.K.Preis           # Kal.P.PreisW1
      "Ein.K.RückstellungYN"# "Kal.P.RückstellungYN"
      Ein.K.EinsatzmengeYN  # Kal.P.EinsatzmengeYN;


      Ein.K.Anlage.Datum  # today;
      Ein.K.Anlage.Zeit   # now;
      Ein.K.Anlage.User   # gUsername;
      REPEAT
        Erx # RekInsert(505,0,'AUTO');
        if (Erx<>_rOK) then begin
          Ein.K.lfdNr # Ein.K.lfdNr + 1;
          CYCLE;
        end;
      UNTIL (Erx=_rOK);

      Erx # RecLink(831,830,1,_recNext);
    END; // Kopierloop

  end;

end;

//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.K.Lieferantennr # Adr.Lieferantennr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edEin.K.Lieferantennr->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_K_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_K_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_K_Aendern]=n) or (Ein.K.NachtragYN);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_K_Aendern]=n) or (Ein.K.NachtragYN);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_K_Loeschen]=n);// or (Ein.K.NachtragYN);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_K_Loeschen]=n);// or (Ein.K.NachtragYN);

  vHdl # gMenu->WinSearch('Mnu.Vorlagen.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled #  (Mode<>c_Modelist) or (Rechte[Rgt_Kalkulationen]=n);
  RefreshIfm();

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

    'Mnu.Vorlagen.Import' : begin
      RecBufClear(830);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Kal.Verwaltung', here+':AusKalkulation');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Ein.K.Anlage.Datum, Ein.K.Anlage.Zeit, Ein.K.Anlage.User );
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
    'bt.Lieferant'    :   Auswahl('Lieferant');
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Terminart'    :   Auswahl('Terminart');
  end;

end;


//========================================================================
// EvtChanged
//            Feldveränderungen
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbEin.K.RckstellungYN') and ("Ein.K.RückstellungYN") then begin
    Ein.K.NachtragYN # false;
    $cbEin.K.NachtragYN->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Enable($cbEin.K.MengenbezugYN);
  end;

  if (aEvt:Obj->wpname='cbEin.K.NachtragYN') then begin
//    Lib_GuiCom:Enable($edAuf.Waehrungskurs);
    if (Ein.K.NachtragYN) then begin
      "Ein.K.RückstellungYN" # false;
      $cbEin.K.RckstellungYN->winupdate(_WinUpdFld2Obj);
      Ein.K.MengenbezugYN # n;
      $cbEin.K.MengenbezugYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($cbEin.K.MengenbezugYN);
      end
    else begin
      Lib_GuiCom:Enable($cbEin.K.MengenbezugYN);
    end;
//    $cbEin.K.RckstellungYN->wpCheckState) then begin
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
//  Refreshmode();
  if ("Ein.K.Löschmarker"='*') then
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
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-37;
    gZLList->wparea # vRect;
  end;

  Lib_GUiCom:ObjSetPos($lb.summe, 0, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($ed.Summe, 128, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($lb.WAE1, 224, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($lb.Summe2, 384, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($ed.Summe2, 512, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($lb.WAE2, 608, vRect:bottom+3);

	RETURN (true);
end;

sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edEin.K.LieferantenNr') AND (aBuf->Ein.K.LieferantenNr<>0)) then begin
    RekLink(100,505,1,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================