@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rek_A_Main
//                  OHNE E_R_G
//  Info
//
//
//  11.06.2008  DS  Erstellung der Prozedur
//  20.07.2015  ST  Aktionstyp bei Neuanlage vorbelegt; Felder nicht änderbar
//  16.03.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB UpdateAnerkennung();
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKostenstelle()
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
  cTitle      : 'Aktionen'
  cFile       :  302
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Rek_A'
  cZList      : $ZL.Rek.Aktionen
  cKey        : 1
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

Lib_Guicom2:Underline($edRek.A.Kostenstelle);

  SetStdAusFeld('edRek.A.Kostenstelle'  ,'Kostenstelle');
  SetStdAusFeld('edRek.A.MEH'           ,'MEH');

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
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  $lb.Einheit->wpcaption # Rek.A.MEH;

  if (aName='') or (aName='edRek.A.Kostenstelle') then begin
    Erx # RecLink(846,302,2,0);
    if (Erx<=_rLocked) then
      $Lb.Kostenstelle->wpcaption # KSt.Bezeichnung
    else
      $Lb.Kostenstelle->wpcaption # '';
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
//  UpdateAnerkennung
//
//========================================================================
sub UpdateAnerkennung() : logic;
local begin
  Erx       : int;
  vStk     : int;
  vGewicht : float;
  vMenge   : float;
  vWert    : float;
  vRek_Nummer : int;
  vRek_Position : int;
  vRek_Aktion : int;
end;
begin
  vRek_Nummer # Rek.A.Nummer;
  vRek_Position # Rek.A.Position;
  vRek_Aktion # Rek.A.Aktion;

  // Alle Anerkannten summieren
  Erx # RecLink(302,301,2,_recFirst);
  While (Erx<=_rLocked) do begin
    if (Rek.A.AnerkennungYN) then begin
      vStk     # vStk + "Rek.A.Stückzahl";
      vGewicht # vGewicht + Rek.A.Gewicht;
      vMenge   # vMenge + Rek.A.Menge;
      //if (Rek.A.MEH = 'kg') then
      //  vWert    # vWert + ((Rek.A.Gewicht * Rek.A.Kosten) / cnvFI(Rek.A.PEH));
      vWert # vWert + ((Rek.A.Menge * Rek.A.Kosten) / cnvFI(Rek.A.PEH));
    end;
      Erx # RecLink(302,301,2,_recNext);
  END;  // Ende Schleife

  Rek.A.Nummer # vRek_Nummer;
  Rek.A.Position # vRek_Position;
  Rek.A.Aktion # vRek_Aktion;
  Erx # RecRead(302,1,0);
  if (Erx<=_rLocked) then begin
    // Update Rek.Positionen
    RecLink(301,302,1,_recFirst|_recLock);
    Rek.P.Aner.Stk    # vStk;
    Rek.P.Aner.Gew    # vGewicht;
    Rek.P.Aner.Menge  # vMenge;
    Rek.P.Aner.Wert   # vWert;
    Wae_Umrechnen(Rek.P.Aner.Wert,"Rek.Währung",var Rek.P.Aner.WertW1,1);
    Erx # RekReplace(301,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end else begin
    // Update Rek.Positionen
    //RecLink(301,302,1,_recFirst|_recLock);
    Rek.P.Nummer      # vRek_Nummer;
    Rek.P.Position    # vRek_Position;
    RecRead(301,1,0|_recLock);
    Rek.P.Aner.Stk    # 0;
    Rek.P.Aner.Gew    # 0.0;
    Rek.P.Aner.Menge  # 0.0;
    Rek.P.Aner.Wert   # 0.0;
    Rek.P.Aner.WertW1 # 0.0;
    Erx # RekReplace(301,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;
  Return True;    //Speichern erfolgreich
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
  $edRek.A.Aktionsdatum->WinFocusSet(true);

  Lib_GuiCom:Disable($edRek.A.Aktionstyp);
  Lib_GuiCom:Disable($edRek.A.Aktionsnr);
  Lib_GuiCom:Disable($edRek.A.Aktionspos);

  if (Mode=c_ModeNew) then begin
    Rek.A.Nummer        # Rek.P.Nummer;
    Rek.A.Position      # Rek.P.Position;
    Rek.A.Aktion        # 1;
    Rek.A.TerminStart   # today;
    Rek.A.TerminEnde    # today;
    Rek.A.Aktionsdatum  # today;
    Rek.A.MEH           # Rek.P.MEH;
    Rek.A.PEH           # 1000;
    Rek.A.Aktionstyp    # 'MAN';

    $Lb.Einheit->wpcaption # Rek.P.MEH;
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
  If (Rek.A.MEH='') then begin
    Msg(001200,Translate('Mengeneinheit'),0,0,0);
    $edRek.A.MEH->WinFocusSet(true);
     RETURN false;
  end;

  If (Rek.A.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $edRek.A.PEH->WinFocusSet(true);
     RETURN false;
  end;

  //Umrechnen auf Hauswährung
  Wae_Umrechnen(Rek.A.Kosten,"Rek.Währung",var Rek.A.KostenW1,1);
  // Satz zurückspeichern & protokolieren
  // Update
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);

    if (UpdateAnerkennung()= False) then Return False;
  end

  // Insert
  else begin
    Rek.A.Anlage.Datum  # Today;
    Rek.A.Anlage.Zeit   # Now;
    Rek.A.Anlage.User   # gUserName;
    // Nummernbestimmung Rek.A.Position
    Rek.A.Aktion        # 1;
    WHILE (RecRead(302,1,_RecTest)<=_rLocked) do
      Rek.A.Aktion # Rek.A.Aktion + 1;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (UpdateAnerkennung()= False) then Return False;
  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  RecRead(301,1,0 | _recUnlock);
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
    UpdateAnerkennung();
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
  vFocus : alpha;
end;
begin
  vFocus # aEvt:Obj->wpname;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (vFocus='edRek.A.Stckzahl') and ($edRek.A.MEH->wpcaption = 'Stk') then begin
    Rek.A.Menge # cnvFI("Rek.A.Stückzahl");
  end;
  if (vFocus='edRek.A.Gewicht') and ($edRek.A.MEH->wpcaption = 'kg') then begin
    Rek.A.Menge # Rek.A.Gewicht;
  end;
  if(vFocus='edRek.A.MEH') then begin
    $lb.Einheit->wpcaption # Rek.A.MEH;
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
    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edRek.A.MEH,302,1,14);
    end;

    'Kostenstelle' : begin
        RecBufClear(846);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'KSt.Verwaltung',here+':AusKostenstelle');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom))
        Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;
end;

//========================================================================
//  AusKostenstelle
//
//========================================================================

sub AusKostenstelle()
begin
  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    Rek.A.Kostenstelle # Kst.Nummer;
    gSelected # 0;
    // Feldübernahme
  end;
  // Focus auf Editfeld setzen:
  $edRek.A.Kostenstelle->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.A.Kostenstelle');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_A_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_A_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_A_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_A_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_A_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_A_Loeschen]=n);

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

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Rek.A.Anlage.Datum, Rek.A.Anlage.Zeit, Rek.A.Anlage.User);
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
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Kostenstelle' :   Auswahl('Kostenstelle');
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
  //RefreshMode(y);   // falls Menüs gesetzte werden sollen
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
  Rek_P_Main:RefreshIfm('NB.Page1');

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

  if ((aName =^ 'edRek.A.Kostenstelle') AND (aBuf->Rek.A.Kostenstelle<>0)) then begin
    RekLink(846,302,2,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('KSt.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================