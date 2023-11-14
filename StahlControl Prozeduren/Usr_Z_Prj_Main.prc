@A+
//==== Business-Control ==================================================
//
//  Prozedur    Usr_Z_Prj_jMain
//                    OHNE E_R_G
//
//  Info
//
//
// 29.12.2022  ST  Erstellung der Prozedur
//
//  Subprozeduren
// todo
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  //cMenuName : 'Std.Bearbeiten'

  cDialog    : 'Mdi.Usr.Prj.Zeiten'
  cDialogHdl : $Mdi.Usr.Prj.Zeiten
  //cRecht    : Rgt_Usr_Zeiten
  cMDI      : gMdiMsl
  cTitle    :    'Benutzer-Zeiten'


  cPrefix :   'Usr_Z_Prj'

  cKey :      1


  cDLProjHdl   : $DL.Projektzeiten
  cDLAZeitHdl  : $DL.Arbeitzeiten


  cColPrj_RecId   :  1
  cColPrj_Sort    :  2
  cColPrj_Nr      :  3
  cColPrj_Pos     :  4
  cColPrj_Sub     :  5
  cColPrj_Kunde   :  6
  cColPrj_Titel   :  7
  cColPrj_Ticket  :  8
  cColPrj_Start   :  9
  cColPrj_Ende    : 10
  cColPrj_Dauer   : 11
  cColPrj_Text    : 12

  cColAbz_RecId   : 1
  cColAbz_Typ     : 2
  cColAbz_Von     : 3
  cColAbz_Bis     : 4
  cColAbz_Dauer   : 5
  cColAbz_Bemerk  : 6


  cStundenSchwelleRotProz : 80.0
end;



declare _FillDL_Arbeitszeit()
declare _CheckForAlerts()




/*

*/
sub _AddZeit(aTyp : alpha; opt aStart : time; opt aEnd : time)
local begin
  Erx   : int;
  vMin  : int;
end
begin

  RecBufClear(805);

  Usr.Z.User      # $lbUser->wpCaption;
  Usr.Z.Datum     # $edDatum->wpCaptionDate;
  Usr.Z.Typ       # aTyp;

  if (aStart = 0:0) then
    aStart # $edUsr.Z.ZeitStart->wpCaptionTime;
  Usr.Z.ZeitStart # aStart;

  if (aEnd = 0:0) then
    aEnd  # $edUsr.Z.ZeitEnde->wpCaptionTime;
  Usr.Z.ZeitEnde  # aEnd;

  Usr.Z.Bemerkung # $edUsr.Z.Bemerkung->wpCaption;

  vMin  # Lib_Berechnungen:MinutenZwischen(Usr.Z.Datum,Usr.Z.ZeitStart,Usr.Z.Datum,Usr.Z.ZeitEnde);
  Usr.Z.Dauer #  CnvFi(vMin) / 60.0;

  Usr.Z.Anlage.Datum  # today;
  Usr.Z.Anlage.Zeit   # now;
  Usr.Z.Anlage.User   # gUsername;

  Erx # RekInsert(805);

  _FillDL_Arbeitszeit();
end;


/*

*/
sub _WalkTicketsAddZeit()
local begin
  Erx   : int;
  vI    : int;

  vTimeStartCurrent : time;
  vTimeEndCurrent   : time;
end
begin

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(cDLProjHdl, _WinLstDatInfoCount)) do begin
    WinLstCellGet(cDLProjHdl, vTimeStartCurrent,  cColPrj_Start,  vI);
    WinLstCellGet(cDLProjHdl, vTimeEndCurrent,    cColPrj_Ende,   vI);
    _AddZeit('AZ',vTimeStartCurrent,vTimeEndCurrent);
  END;

end;


/*
Projektpuffer sind geladen
*/
sub _AddRowProjekt(aSortKey : alpha; var aSumZeitGesamt : float)
local begin
  vZeile : int;
end
begin

  cDLProjHdl->WinLstDatLineAdd(RecInfo(123,_recId)); // NEUE ZEILE
  vZeile # _WinLstDatLineLast;
  cDLProjHdl->WinLstCellSet(aSortKey  ,           cColPrj_Sort,     vZeile,_WinLstDatModeSortInfo);
  cDLProjHdl->WinLstCellSet(Prj.Z.Nummer  ,       cColPrj_Nr,     vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Z.Position  ,     cColPrj_Pos,    vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Z.SubPosition ,   cColPrj_Sub,    vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Adressstichwort,  cColPrj_Kunde,  vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Stichwort,        cColPrj_Titel,  vZeile);
  cDLProjHdl->WinLstCellSet(Prj.P.Bezeichnung,    cColPrj_Ticket, vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Z.Start.Zeit,     cColPrj_Start,  vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Z.End.Zeit,       cColPrj_Ende,   vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Z.Dauer,          cColPrj_Dauer,  vZeile);
  cDLProjHdl->WinLstCellSet(Prj.Z.Bemerkung,      cColPrj_Text,   vZeile);

  // Summerung
  aSumZeitGesamt # aSumZeitGesamt + Prj.Z.Dauer;
end;


/*
Userzeiten sind geladen
*/
sub _AddRowArbeitszeit(var aSumZeitAZ : float; var aSumZeitPZ : float)
local begin
  vZeile : int;
end
begin

  cDLAZeitHdl->WinLstDatLineAdd(RecInfo(805,_recId)); // NEUE ZEILE
  vZeile # _WinLstDatLineLast;
  cDLAZeitHdl->WinLstCellSet(Usr.Z.Typ,       cColAbz_Typ,     vZeile);
  cDLAZeitHdl->WinLstCellSet(Usr.Z.ZeitStart, cColAbz_Von,     vZeile);
  cDLAZeitHdl->WinLstCellSet(Usr.Z.ZeitEnde,  cColAbz_Bis,     vZeile);
  cDLAZeitHdl->WinLstCellSet(Usr.Z.Dauer,     cColAbz_Dauer,   vZeile);
  cDLAZeitHdl->WinLstCellSet(Usr.Z.Bemerkung, cColAbz_Bemerk,  vZeile);

  // Summerung
  case Usr.Z.Typ of
    'AZ' : aSumZeitAZ # aSumZeitAZ + Usr.Z.Dauer;
    'PZ' : aSumZeitPZ # aSumZeitPZ + Usr.Z.Dauer;
  end;

end;



//========================================================================
// sub ShowDayTimeItems_Data(var aSortTreeHandle : int;)
//      Ermittelt die darzustellenden Datensätze
//========================================================================
sub _SelectPrjZeiten(aDate : date)
local begin
  vPrg        : int;
  vQ          : alpha(4096);

  vSel        : int;
  vSelName    : alpha;
  vSelCnt     : int;
  vCurrent    : int;
  vTree       : int;
  vSortKey    : alpha;
  vItem       : int;

  // ----
  vSumZeitGesamt : float;
  vZeile   :   int
end;
begin
  cDLProjHdl->wpCustom # CnvAd(aDate);

  vSumZeitGesamt  # 0.0;

//  vPrg # Lib_Progress:Init('Datenermittlung - Projektzeiten');

  vQ # '';
  Lib_Sel:QAlpha(   var vQ, 'Prj.Z.User', '=', $lbUser->wpCaption);
  Lib_Sel:QvonbisD( var vQ, 'Prj.Z.End.Datum' , aDate, aDate);

  vSel # SelCreate(123, 1);
  Erg # vSel->SelDefQuery('', vQ);
  if (Erg <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun( var vSel, 0);
  vSelCnt  # vSel->SelInfo(_SelCount);

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  FOR   Erg # RecRead(123,vSel,_RecFirst)
  LOOP  Erg # RecRead(123,vSel,_RecNext)
  WHILE Erg <= _rLocked DO BEGIN
    inc(vCurrent);
/*
    vPrg->Lib_Progress:SetLabel('Sortierung ' + Aint(vCurrent) + '/' + Aint(vSelCnt))
    if (vPrg->Lib_Progress:Step() = false) then begin
      break;
    end;
*/
    // Sortierungsschlüssel definieren
    vSortKey # cnvAI(cnvID(Prj.Z.Start.Datum),_FmtNumLeadZero,0,10)
             + cnvAI(cnvID(Prj.Z.End.Datum),_FmtNumLeadZero,0,10)
             + cnvAT(Prj.Z.Start.Zeit)
             + cnvAT(Prj.Z.End.Zeit)
             + aint(Prj.Z.nummeR)+'/'+aint(Prj.Z.Position)+'/'+aint(Prj.Z.SubPosition)+'/'+aint(Prj.Z.lfdNr);


    Sort_ItemAdd(vTree,vSortKey,123,RecInfo(123,_RecId));
  END;


  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) DO BEGIN
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen
    RekLink(122,123,1,0); // Pos
    RekLink(120,123,2,0); // Kopf
    _AddRowProjekt(vSortKey, var vSumZeitGesamt);
  END;

  // Beenden
//  vPrg->Lib_Progress:Term();
  SelDelete(123, vSelName);

  // Summierung
  todo('BCS Sonderlocke');
  /*
  $lbSumTicketGesamt->wpCaption # Anum(vSumZeitGesamt,2) + ' / ' + CnvAf(SFX_BCS_App:SollWert(aDate),0);
*/

end;

//========================================================================
// sub ShowDayTimeItems_Data(var aSortTreeHandle : int;)
//      Ermittelt die darzustellenden Datensätze
//========================================================================
sub _SelectAbzZeiten(aDate : date)
local begin
  vPrg        : int;
  vQ          : alpha(4096);

  vSel        : int;
  vSelName    : alpha;
  vSelCnt     : int;
  vCurrent    : int;
  vTree       : int;
  vSortKey    : alpha;
  vItem       : int;

  // ----
  vSumZeitAZ     : float;
  vSumZeitPZ     : float;
  vZeile      :   int;

  Erx       : int;
end;
begin
  cDLAZeitHdl->wpCustom # CnvAd(aDate);

  vSumZeitAZ    # 0.0;
  vSumZeitPZ    # 0.0;

  RecbufClear(805);
  Usr.Z.User  # $lbUser->wpCaption;
  Usr.Z.Datum # aDate;
  FOR  Erx # RecRead(805,1,0);
  LOOP Erx # RecRead(805,1,_RecNExt)
  WHILE (Erx < _rNoRec) AND (Usr.Z.User = $lbUser->wpCaption) AND (Usr.Z.datum = aDate) DO BEGIN
    _AddRowArbeitszeit(var vSumZeitAZ, var vSumZeitPZ);
  END;

  // Summierung
  $lbSumArzGesamt->wpCaption # Anum(vSumZeitAZ + vSumZeitPZ,2);
  $lbSumArzGesamtAZ->wpCaption # Anum(vSumZeitAZ,2);
  $lbSumArzGesamtPZ->wpCaption # Anum(vSumZeitPZ,2);



end;


sub _FillDL_Arbeitszeit()
begin
  // Arbeitszeiten
  cDLAZeitHdl->wpAutoUpdate # false;
  cDLAZeitHdl->WinLstDatLineRemove(_WinLstDatLineAll);
  _SelectAbzZeiten($edDatum->wpCaptionDate);
  cDLAZeitHdl->wpAutoUpdate # true;
end


sub _FillDL()
local begin
  vSel  : handle;
end;
begin
  // Projektzeiten
  cDLProjHdl->wpAutoUpdate # false;
  cDLProjHdl->WinLstDatLineRemove(_WinLstDatLineAll);
  _SelectPrjZeiten($edDatum->wpCaptionDate);
  cDLProjHdl->wpAutoUpdate # true;

  _FillDL_Arbeitszeit();

  _CheckForAlerts();
end;


sub _CheckForAlerts()
local begin
  Erx : int;
  vMoment     : caltime;
  vInfo       : alpha(1000);
  v805  : int;

  vVortagStartDate : date;
  vVortagStartZeit : time;

  vRuhezeitMin     : int;
  vRuhezeitH       : float;
  vHeuteDate       : date;
  vHeuteStartZeit : time;

  vHeuteAZ    : float;
  vHeutePZ    : float;
  vPauseMin   : int;

  vTickIst  :   float;
  vTickSoll :   float;
  vTickSchwell : float;
end
begin
  $lbWarnung->wpCaption # '';
  vInfo #  '';

  // -------------------------------------------------------------------
  //  Ticketauswertung
  vTickIst  # CnvFa(Str_Token($lbSumTicketGesamt->wpCaption, '/',1));
  vTickSoll # CnvFa(Str_Token($lbSumTicketGesamt->wpCaption, '/',2)); // <-- kommt schon aus Vorgabe
  vTickSchwell  # (vTickSoll / 100.0 * cStundenSchwelleRotProz);

  $lbSumTicketGesamt->wpColFg #  _WinColBlack;

  if (vTickSoll > 0.0) then begin
    if  (vTickIst < vTickSchwell) then begin
      $lbSumTicketGesamt->wpColFg # _WinColLightRed;
    end else
      $lbSumTicketGesamt->wpColFg # _WinColGreen;
  end;

  // -------------------------------------------------------------------
  //  Zeitenauswertung

  // nur berechnen, wenn AZ eingetragen sind
  // Erste Startzeit ermitteln
  vHeuteDate # $edDatum->wpCaptionDate;
  WinLstCellGet(cDLAZeitHdl, vHeuteStartZeit  , cColAbz_Von, 1);

  if (vHeuteStartZeit <> 24:00) AND (WinLstDatLineInfo(cDLAZeitHdl, _WinLstDatInfoCount) > 0)  then begin

    // Ende des Vortages ermitteln
    v805 # RekSave(805);

    Usr.Z.User  # $lbUser->wpCaption;
    vMoment->vpDate # $edDatum->wpCaptionDate;
    vMoment->vmDayModify(-1);
    Usr.Z.Datum # vMoment->vpDate;
    FOR  Erx # RecRead(805,1,0);
    LOOP Erx # RecRead(805,1,_RecNext)
    WHILE (Erx < _rNoRec) AND (Usr.Z.User = $lbUser->wpCaption) AND (Usr.Z.datum = vMoment->vpDate) DO BEGIN
      vVortagStartDate # Usr.Z.Datum;
      vVortagStartZeit # Usr.Z.ZeitEnde;
    END;
    RekRestore(v805);


    // Ruhezeiten zum Vortag prüfen
    if ((vVortagStartDate <> 0.0.0)) then begin
      vRuhezeitMin  # Lib_Berechnungen:MinutenZwischen(vVortagStartDate,vVortagStartZeit,
                                                       vHeuteDate,vHeuteStartZeit);
      vRuhezeitH    #  CnvFi(vRuhezeitMin) / 60.0;

      // 11 Stunden Ruhezeit zum Vortag
      if (vRuhezeitH < 11.0) then
        vInfo # vInfo + 'Du hast nur ' + ANum(vRuhezeitH,2) + ' Stunden Ruhezeit zum Vortag (min 11h)' + StrChar(13);
    end;


    // Heutige Arbeitszeiten auswerten
    vHeuteAZ  # CnvFa($lbSumArzGesamtAZ->wpCaption);
    vHeutePZ  # CnvFa($lbSumArzGesamtPZ->wpCaption);
    vPauseMin # CnvIf(60.0*vHeutePZ);

    if (vHeuteAZ > 10.0) then begin

      // nicht mehr als 10 Stunden
      vInfo # vInfo + 'Du hast zuviel gearbeitet! Ab auf die Schaukel!' + StrChar(10);

    end else begin

      if (vHeuteAZ > 9.0) then begin

        // Pause 0,75 Stunden bei 9 Stunden Arbeiten
        if (vPauseMin  < 45) then
          vInfo # vInfo + 'Du hast nur ' + Aint(vPauseMin ) + ' Minuten Pause gemacht. Bitte min. 45 Minunten';

      end else begin

        // Pause 0,5 Stunden Pause bei 6 Stunden Arbeit
        if (vHeuteAZ > 6.0) AND  (vPauseMin < 30) then
          vInfo # vInfo + 'Du hast nur ' + Aint(vPauseMin ) + ' Minuten Pause gemacht. Bitte min. 30 Minunten';

      end;

    end;

    if (vInfo <> '') then
      $lbWarnung->wpColFg # ColorRgbMake(255, 128, 0);    //  Orange

  end;

  $lbWarnung->wpCaption # vInfo;


  if (vInfo = '' ) AND ($lbSumTicketGesamt->wpColFg  = _WinColGreen) then begin
    $lbWarnung->wpColFg # _WinColGreen;
    vInfo  # 'Alles super heute!';
  end;


end;




//========================================================================
//  Start
//      Startet das Fenster ein
//========================================================================
sub Start(
  opt aUser       : alpha;
  opt aTag        : date;) : logic;
local begin
  vHdl : int;

end
begin

// Dialog starten...
  cMDI # Lib_GuiCom:OpenMdi(gFrmMain, cDialog   , _WinAddHidden);
  VarInstance(WindowBonus,cnvIA(cMDI->wpcustom));


  // PLANUNG FÜLLEN-------------------------------------------------
  if (aTag = 0.0.0) then
    aTag # today;

  if (aUser = '') then
    aUser # gUserName;

  $lbUser->wpCaption      # aUser;
  $edDatum->wpCaptionDate # aTag;
  $lbWarnung->wpCaption   # '';

  _FillDL();

//  _CheckForAlerts();

  // Anzeigen
  cMDI->WinUpdate(_WinUpdOn);
  cMDI->Winfocusset(true);
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
//  gFile     # cFile;
//  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gKey      # cKey;
  gSelected # 0;




  App_Main:EvtInit(aEvt);
end;



//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl : int;

  tObj : int;
end;
begin

  gZLList # 0;
  vHdl # w_lastfocus;
  Call('App_Main:EvtMdiActivate',aEvt);

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
  Erx : int;
end
begin



  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
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
  aFocusObject          : int           // zu verlassendes Objekt
) : logic
local begin
  Erx : int;
end
begin
  // logische Prüfung von Verknüpfungen
  if (aEvt:Obj = $edDatum) then begin
    if ( CnvAd($edDatum->wpCaptionDate) <> cDLProjHdl->wpCustom) then
      _FillDL();
  end;

  RefreshIfm(aEvt:Obj->wpName);
  RETURN true;
end;


//=========================================================================
// EvtMenuCommand
//
//=========================================================================
sub EvtMenuCommand(
  aEvt      : event;
  aMenuItem : handle;
) : logic
local begin
  vSelected : int;
  vRecId    : int;
  vFile     : int;
  vName     : alpha;
  vPref     : alpha;
end;
begin

  // Kontextmenüauswertung
  case (aMenuItem->wpName) of

    'Mnu.Ktx.Workbench' : begin

    end;


    'Grp.Cancel' : begin
      gSelected # 0;
      gMDI->Winclose();
    end;

  end;

  RETURN true;
end;



//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vMoment : caltime;
  vTime : time;
end;
begin

  case (aEvt:Obj->wpName) of
    'btDayBefore' : begin
      vMoment->vpDate # $edDatum->wpCaptionDate;
      vMoment->vmDayModify(-1);
      $edDatum->wpCaptionDate # vMoment->vpDate;
      _FillDL();
    end;

    'btDayNext' : begin
      vMoment->vpDate # $edDatum->wpCaptionDate;
      vMoment->vmDayModify(1);
      $edDatum->wpCaptionDate # vMoment->vpDate;
      _FillDL();
    end;

    'btDayReload' : begin
      _FillDL();
    end;

    'btTimeClear' : begin
      $edUsr.Z.ZeitStart->wpCaptionTime # 24:00:00;
      $edUsr.Z.ZeitEnde->wpCaptionTime # 24:00:00;
    end;

    'btTimeAdd' : begin
      _AddZeit('AZ');
      _CheckForAlerts();
    end;

    'btTimeAddPause' : begin
      _AddZeit('PZ');
      _CheckForAlerts();
    end;


    'btTimeNowFrom' : begin
      $edUsr.Z.ZeitStart->wpCaptionTime # now;
    end;

    'btTimeNowTo' : begin
      $edUsr.Z.ZeitEnde->wpCaptionTime # now;
    end;

    'btTimeAdd30' : begin
      if ($edUsr.Z.ZeitStart->wpCaptionTime = 24:00:00) then
        RETURN true;

      vMoment->vpDate # $edDatum->wpCaptionDate;
      vMoment->vpTime # $edUsr.Z.ZeitStart->wpCaptionTime;
      vMoment->vmSecondsModify(60*30);
      $edUsr.Z.ZeitEnde->wpCaptionTime # vMoment->vpTime;
    end;


    'btTimeGrab' : begin
      WinLstCellGet(cDLProjHdl, vTime  , cColPrj_Start, 1);
      $edUsr.Z.ZeitStart->wpCaptionTime # vTime;

      WinLstCellGet(cDLProjHdl, vTime  , cColPrj_Ende, _WinLstDatLineLast )
      $edUsr.Z.ZeitEnde->wpCaptionTime # vTime;
    end;

    'btTimeGrabInklPause' : begin
      _WalkTicketsAddZeit();
      _CheckForAlerts();
    end;



  end;


end;


//========================================================================
//  EvtLstDataInit
//========================================================================
sub EvtKeyItem(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView
) : logic
local begin
  Erx : int;
  vRecId : bigint;
end
begin

  if (aEvt:Obj = cDLAZeitHdl) then begin

    if (aKey = _WinKeyDelete) then begin

      WinLstCellGet(cDLAZeitHdl, vRecId , cColAbz_RecId, aID);
      Erx # RecRead(805,0,_RecId,vRecId);
      if (Erx = _rOK) then begin
        RekDelete(805);
        _FillDL_Arbeitszeit();
      end;

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
  vCol : int;

  vCell : int;
  vEven : logic;
  vFixed : int;
end;
begin

  if (aEvt:Obj= cDLProjHdl) then begin

  /*
    vCol # Set.Col.RList.Deletd;

    FOR  vCell # $DLRamBaum->WinInfo( _winFirst, 0, _winTypeListColumn );
    LOOP vCell # vCell->WinInfo( _winNext, 0, _winTypeListColumn );
    WHILE ( vCell != 0 ) DO BEGIN
      vCell->wpClmColBkg         # vCol;
      vCell->wpClmColFocusBkg    # vCol;
      vCell->wpClmColFocusOffBkg # vCol;
    END;

  */

  end
  else
  if (aEvt:Obj = cDLAZeitHdl) then begin


  end;


end;



//========================================================================
//  EvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  vCol : int;
  vSortOrder : alpha;

  i : int;
  vHdlClm : int;

  vTime  : time;
  vBem    : alpha;
end;
begin

  if ( aItem = 0 ) then
    RETURN false;

  if ( aEvt:obj = cDLProjHdl) and (aButton = _winMouseLeft | _WinMouseDouble) then begin
    if (aItem->wpName = 'colStart') then begin
      WinLstCellGet(cDLProjHdl, vTime, cColPrj_Start, aID);
      $edUsr.Z.ZeitStart->wpCaptionTime # vTime;
    end;

    if (aItem->wpName = 'colEnd') then begin
      WinLstCellGet(cDLProjHdl, vTime, cColPrj_Ende, aID);
      $edUsr.Z.ZeitEnde->wpCaptionTime # vTime;
    end;
  end;

  if ( aEvt:obj = cDLProjHdl) and (aButton = _winMouseLeft | _WinMouseDouble | _WinMouseCtrl) then begin

    if (aItem->wpName = 'colStart') then begin
      WinLstCellGet(cDLProjHdl, vTime, cColPrj_Start, aID);
      $edUsr.Z.ZeitEnde->wpCaptionTime # vTime;
    end;

    if (aItem->wpName = 'colEnd') then begin
      WinLstCellGet(cDLProjHdl, vTime, cColPrj_Ende, aID);
      $edUsr.Z.ZeitStart->wpCaptionTime # vTime;
    end;
  end;



  // Doppelklick auf
  if ( aEvt:obj = cDLAZeitHdl) and ( aButton = _winMouseLeft | _WinMouseDouble ) then begin

    if (aID > 0) then begin
      WinLstCellGet(cDLAZeitHdl, vTime, cColAbz_Von, aID);
      $edUsr.Z.ZeitStart->wpCaptionTime # vTime;

      WinLstCellGet(cDLAZeitHdl, vTime, cColAbz_Bis, aID);
      $edUsr.Z.ZeitEnde->wpCaptionTime # vTime;

      WinLstCellGet(cDLAZeitHdl, vBem, cColAbz_Bemerk, aID);
      $edUsr.Z.Bemerkung->wpCaption # vBem;
    end;

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
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vParent : int;
  vName   : alpha;
  vTmp    : int;
end;
begin

   if (gFrmMain <> $AppFrameFM) then   // Beim Appframe FM wird kein Tree geöffnet
     if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
       RETURN false;


  // Parentfenster koennen nicht geschlossen werden
  if (w_Child<>0) then RETURN false;

  // Sortierung nicht bei "Auswahl" merken !!!
  //Erx # Lib_GuiCom:FindWindowRelation(gMdi);

  gFile   # 0;
  gPrefix # '';
  gZLList # 0;

  // Elternbeziehung aufheben?
  if (w_Parent<>0) then begin
    vTmp # VarInfo(Windowbonus);
    VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
    w_Child # 0;
    if (gZLList<>0) then gZLList->wpdisabled # false;
    VarInstance(WindowBonus,vTmp);
    w_Parent->wpdisabled # n;
    w_Parent->WinUpdate(_WinUpdActivate);
  end;

  RETURN true;
end;



//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTermProc : alpha;
  vHdl      : int;
end;
begin
  if (aEvt:obj->wpcustom<>'') then VarInstance(WindowBonus,cnvIA(aEvt:Obj->wpcustom));

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    if (w_parent<>0) then begin
      WinSearchPath(w_Parent);
      VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    end;
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
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


end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
