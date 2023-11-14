@A+
//==== Business-Control ==================================================
//
//  Prozedur    Kas_B_P_Main
//                  OHNE E_R_G
//  Info
//
//
//  03.01.2013  AI  Erstellung der Prozedur
//  23.07.2013  ST  Button für Gegenkonto korrigiert
//  09.06.2022  AH  ERX
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aView   : logic) : logic;
//    SUB EvtInit(
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(
//    SUB EvtFocusTerm(
//    SUB Auswahl(aBereich : alpha)
//    SUB AusGegenkonto()
//    SUB RefreshMode(opt aNoRefresh : logic);
//    SUB EvtMenuCommand(
//    SUB EvtClicked(
//    SUB EvtPageSelect(
//    SUB EvtLstDataInit(
//    SUB EvtLstSelect(
//    SUB EvtClose(
//    sub EvtPosChanged(
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cDialog     : 'Kas.B.Verwaltung'
  cTitle      : 'Kassenbuchpositionen'
  cRecht      : Rgt_Kassenbuch
  cMdiVar     : gMDIPara
  cFile       :  572
  cMenuName   : 'Kas.B.P.Bearbeiten'
  cPrefix     : 'Kas_B_P'
  cZList      : $ZL.Kassenbuchpositionen
  cKey        : 1
  cListen     : 'Kassenbuchpositionen'
end;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aView   : logic) : logic;
begin
  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
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
  winsearchpath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;

Lib_Guicom2:Underline($edKas.B.P.Gegenkonto);

    // Auswahlfelder setzen...
  SetStdAusFeld('edKas.B.P.Gegenkonto','Gegenkonto');

  $lb.EingangWert->wpcaption      # anum(Kas.B.Summe.Eingang,2);
  $lb.AusgangWert->wpcaption      # anum(Kas.B.Summe.Ausgang,2);
  $lb.SaldoWert->wpcaption        # anum(Kas.B.Ende.Saldo,2);
  $lb.Start.SaldoWert->wpcaption  # anum(Kas.B.Start.Saldo,2);

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
  Lib_GuiCom:Pflichtfeld($edKas.B.P.Belegdatum  );
  Lib_GuiCom:Pflichtfeld($edKas.B.P.Gegenkonto);
  Lib_GuiCom:Pflichtfeld($edKas.B.P.Ausgang);
  Lib_GuiCom:Pflichtfeld($edKas.B.P.Eingang);
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
  vHdl  : int;
end;
begin

  $lb.EingangWert->wpcaption      # anum(Kas.B.Summe.Eingang,2);
  $lb.AusgangWert->wpcaption      # anum(Kas.B.Summe.Ausgang,2);
  $lb.SaldoWert->wpcaption        # anum(Kas.B.Ende.Saldo,2);
  $lb.Start.SaldoWert->wpcaption  # anum(Kas.B.Start.Saldo,2);

  if (aName='') or (aName='edKas.B.P.Gegenkonto') then begin
    Erx # RecLink(854,572,1,_recfirst); // Gegenkonto holen
    if (Erx<=_rLocked) and (Kas.B.P.Gegenkonto>0) then begin
      $lb.Gegenkonto ->wpcaption # GKo.Bezeichnung;
      Kas.B.P.Steuerschl  # "GKo.Steuerschlüssel";
      end
    else begin
      $lb.Gegenkonto ->wpcaption # '';
      Kas.B.P.Steuerschl  # 0;
    end;
    $edKas.B.P.Steuerschl->WinUpdate(_WinUpdFld2Obj);

    Erx # RecLink(813,572,2,_recfirst); // Steuerschlüssel holen
    if (Erx<=_rLocked) and ("Kas.B.P.Steuerschl">0) then
      $lb.steuerschluessel->wpcaption # Sts.Bezeichnung
    else
      $lb.steuerschluessel->wpcaption # '';
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
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  Kas.B.P.Kassennr  # Kas.B.Kassennr;
  Kas.B.P.Buchnr    # Kas.B.Nummer;
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edKas.B.P.Belegdatum->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  v572  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (Kas.B.P.Belegdatum=0.0.0) then begin
    Msg(001200,Translate('Belegdatum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKas.B.P.Belegdatum->WinFocusSet(true);
    RETURN false;
  end;

  If (Kas.B.P.Gegenkonto=0) then begin
    Msg(001200,Translate('Gegenkonto'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKas.B.P.Gegenkonto->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(854,572,1,_recFirst);   // Gegenkonto holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Gegenkonto'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKas.B.P.Gegenkonto->WinFocusSet(true);
    RETURN false;
  end;

  If (Kas.B.P.Ausgang=0.0) and (Kas.B.P.Eingang=0.0) then begin
    Msg(001200,Translate('Betrag'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKas.B.P.Ausgang->WinFocusSet(true);
    RETURN false;
  end;


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
    v572 # RecBufCreate(572);
    Erx # RecLink(v572,571,2,_recLast);
    if (Erx<=_rLocked) then Kas.B.P.lfdnr # v572->Kas.B.P.lfdNr + 1
    else Kas.B.P.lfdNr # 1;
    RecBufDestroy(v572);

    Kas.B.P.Anlage.Datum  # Today;
    Kas.B.P.Anlage.Zeit   # Now;
    Kas.B.P.Anlage.User   # gUserName;
    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOK) then Kas.B.P.LfdNr # Kas.B.P.LfdNr + 1;
    UNTIL (Erx=_rOK);
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  Kas_Data:RecalcBuch();

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

  if (Kas.B.Ende.Datum<>0.0.0) then RETURN;

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
local begin
  Erx   : int;
  v100  : int;
end;
begin

  // Steuerbetrag errechnen ueber den Steuerschluessel des Lieferanten
  if (Kas.B.P.Steuer = 0.0) then begin

    if ((aEvt:Obj->wpname='edKas.B.P.Eingang') and ($edKas.B.P.Eingang->wpchanged)) then begin

      v100 # RecBufCreate(100);
      v100->Adr.Nummer # Set.EigeneAdressnr;
      RecRead(v100,1,0);
      StS.Nummer # ("Kas.B.P.Steuerschl" * 100) + v100->"Adr.Steuerschlüssel";
      Erx # RecRead(813,1,0);   // Steuerschluessel holen
      if (Erx > _rLocked) then RecBufClear(813);

      Kas.B.P.Steuer # Rnd( (Kas.B.P.Eingang / (100.0 + StS.Prozent)) * StS.Prozent ,2);
      $edKas.B.P.Steuer->Winupdate(_WinUpdFld2Obj);
    end;

    if ((aEvt:Obj->wpname='edKas.B.P.Ausgang') and ($edKas.B.P.Ausgang->wpchanged)) then begin
      v100 # RecBufCreate(100);
      v100->Adr.Nummer # Set.EigeneAdressnr;
      RecRead(v100,1,0);
      StS.Nummer # ("Kas.B.P.Steuerschl" * 100) + v100->"Adr.Steuerschlüssel";
      Erx # RecRead(813,1,0);   // Steuerschluessel holen
      if (Erx > _rLocked) then RecBufClear(813);
      Kas.B.P.Steuer # -Rnd( (Kas.B.P.Ausgang / (100.0 + StS.Prozent)) * StS.Prozent ,2);
      $edKas.B.P.Steuer->Winupdate(_WinUpdFld2Obj);
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
  vA    : alpha;
end;

begin

  case aBereich of

    'Gegenkonto' : begin
      RecBufClear(854);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'GKo.Verwaltung',here+':AusGegenkonto');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;  // ...case

end;


//========================================================================
//  AusGegenkonto
//
//========================================================================
sub AusGegenkonto()
begin

  if (gSelected<>0) then begin
    RecRead(854,0,_RecId,gSelected);
    gSelected # 0;
    Kas.B.P.Gegenkonto  # Gko.Nummer;
    Kas.B.P.Steuerschl  # "GKo.Steuerschlüssel";
    $edKas.B.P.Steuerschl->WinUpdate(_WinUpdFld2Obj);
  end;
  $edKas.B.P.Gegenkonto->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kas_B_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kas_B_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kas_B_Aendern]=n) or
    (Kas.B.Ende.Datum<>0.0.0);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kas_B_Aendern]=n) or
    (Kas.B.Ende.Datum<>0.0.0);


  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kas_B_Loeschen]=n) or
    (Kas.B.Ende.Datum<>0.0.0);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kas_B_Loeschen]=n) or
    (Kas.B.Ende.Datum<>0.0.0);

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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Druck.Kassenbuch' : begin
      If (Kas.B.Ende.Datum=0.0.0) then begin
        Kas_Data:DruckNeuesBuch();
        $lb.EingangWert->wpcaption      # anum(Kas.B.Summe.Eingang,2);
        $lb.AusgangWert->wpcaption      # anum(Kas.B.Summe.Ausgang,2);
        $lb.SaldoWert->wpcaption        # anum(Kas.B.Ende.Saldo,2);
        $lb.Start.SaldoWert->wpcaption  # anum(Kas.B.Start.Saldo,2);
        end
      else begin
        Lib_Dokumente:Printform(570,'Kassenbuch',true);
      end;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Kas.B.P.Anlage.Datum, Kas.B.P.Anlage.Zeit, Kas.B.Anlage.User);
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
    'bt.Gegenkonto' :   Auswahl('Gegenkonto');
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
begin

  if (Kas.B.P.Saldo<0.0) then
    $clmKas.B.P.Saldo->wpClmColBkg # _WinColLightRed
  else
    $clmKas.B.P.Saldo->wpClmColBkg # _WinColParent;

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
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged (aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
local begin
  vRect : rect;
  vHdl  : int;
  vI    : int;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if ( aFlags & _winPosSized != 0 ) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right  - aRect:left - 4;
    vRect:bottom    # aRect:bottom - aRect:top - 28 - 64;
//    vRect:bottom    # aRect:bottom - aRect:top - 15 - cnvif(13.0 * w_ZoomY);
    gZLList->wpArea # vRect;

    vI # ($lb.Ausgang->wpareaBottom-$lb.Ausgang->wpareatop) + 3;

    Lib_GuiCom:ObjSetPos( $lb.Eingang, 0, vRect:bottom + 8  );
    Lib_GuiCom:ObjSetPos( $lb.Eingangwert, 0, vRect:bottom + 8);
    Lib_GuiCom:ObjSetPos( $lb.HW.Eingang, 0, vRect:bottom + 8);

    Lib_GuiCom:ObjSetPos( $lb.Ausgang, 0, vRect:bottom + 8 + vI);
    Lib_GuiCom:ObjSetPos( $lb.Ausgangwert, 0, vRect:bottom + 8 + vI);
    Lib_GuiCom:ObjSetPos( $lb.HW.Ausgang, 0, vRect:bottom + 8 + vI);

    Lib_GuiCom:ObjSetPos( $lb.Start.Saldo, 0, vRect:bottom + 8  );
    Lib_GuiCom:ObjSetPos( $lb.Start.Saldowert, 0, vRect:bottom + 8 );
    Lib_GuiCom:ObjSetPos( $lb.HW.Start.Saldo, 0, vRect:bottom + 8);

    Lib_GuiCom:ObjSetPos( $lb.Saldo, 0, vRect:bottom + 8 + vI);
    Lib_GuiCom:ObjSetPos( $lb.Saldowert, 0, vRect:bottom + 8 + vI);
    Lib_GuiCom:ObjSetPos( $lb.HW.Saldo, 0, vRect:bottom + 8 + vI);
  end;

	RETURN true;
end;

sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edKas.B.P.Gegenkonto') AND (aBuf->Kas.B.P.Gegenkonto<>0)) then begin
    RekLink(854,572,1,0);   // Gegenkonto holen
    Lib_Guicom2:JumpToWindow('GKo.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================