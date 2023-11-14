@A+
//==== Business-Control ===================================================
//
//  Prozedur    App_Betrieb_RsoPlan
//                  OHNE E_R_G
//  Info
//        Betrieb, Ressourcenplanung (Maschinenplanung)
//
//  10.12.2009  PW  Erstellung der Prozedur
//  18.09.2018  AH  AFX: "Betrieb.RsoPlan.Start"
//  25.10.2018  AH  Start-Endzeit anzeigen und Warnen beim Überschreiben
//  06.11.2018  AH  "AusFMKopf", Start-Endzeit setzt auch PLANZEIT??!
//  18.12.2018  AH  Suchfunktion
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    sub RefreshInformation ( aFile : int )
//    sub Start ()
//    sub ShowDialog(aSel : int; aSelName : alpha)
//    sub EvtClicked ( aEvt : event ) : logic
//    sub EvtClose ( aEvt : event ) : logic
//    sub EvtFocusInit ( aEvt : event; aFocusObject : int ) : logic
//    sub EvtInit ( aEvt : event ) : logic
//    sub EvtLstDataInit ( aEvt : event; aId : int )
//    sub EvtLstSelect ( aEvt : event; aId : int ) : logic
//    sub AusFMKopf();
//    sub AusSel ()
//=========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

define begin
  cZeitBemerkung  : '<ZEIT AUS TERMINLISTE>'
  cZeitTyp        : 10
end;

declare ShowDialog(aSel      : int;  aSelName  : alpha)
declare _SucheZeit(aLock : logic): logic

//=========================================================================
// RefreshInformation
//        Informationstexte aktualisieren
//=========================================================================
sub RefreshInformation ( aFile : int )
local begin
  Erx : int;
  vA  : Alpha(4000);
end;
begin
  w_AppendNr # aFile;

  case ( aFile ) of
    702 : begin

      Gv.Alpha.10 # 'Informationen';
      Gv.Alpha.11 # 'Arbeitsgang ' + AInt( BAG.P.Nummer ) + '/' + AInt( BAG.P.Position );
      Gv.Alpha.12 # '';
      Gv.Alpha.13 # '';
      Gv.Alpha.14 # '';
      Gv.Alpha.15 # '';

      if ( BAG.P.AuftragsNr != 0 ) then begin
        Auf.P.Nummer   # BAG.P.AuftragsNr;
        Auf.P.Position # BAG.P.AuftragsPos;
        if ( RecRead( 401, 1, 0 ) <= _rLocked ) then
          Gv.Alpha.12 # 'Für Auftrag ' + AInt( BAG.P.AuftragsNr ) + '/' + AInt( BAG.P.AuftragsPos ) + ' ' + Auf.P.KundenSW;
      end;

      // 25.10.2018
      if (_SucheZeit(false)) then begin
        GV.Alpha.15 # Lib_Berechnungen:KurzDatum_aus_Datum(BAG.Z.StartDatum)+' '+cnvat(BAG.Z.Startzeit) + ' - ';
        if (BAG.Z.EndDatum>0.0.0) then GV.Alpha.15 # GV.ALpha.15 + Lib_Berechnungen:KurzDatum_aus_Datum(BAG.Z.EndDatum)+' '+cnvat(BAG.Z.Endzeit);
      end;
      
      // 13.12.2018
      if (BAG.P.Aktion2='GLPLAN') then begin
        FOR Erx # RecLink(706,702,9,_recFirst)  // Arbeitsschritte loopen
        LOOP Erx # RecLink(706,702,9,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (vA<>'') then vA # vA + ', ';
          vA # StrCut(vA + BAG.AS.Zusatz,1,1000);
        END;
        vA # 'Zum Fertigmelden: '+vA;
        GV.Alpha.12 # StrCut(vA, 1,50);
        GV.Alpha.13 # StrCut(vA, 51,50);
        GV.Alpha.14 # StrCut(vA, 101,50);
        GV.Alpha.15 # StrCut(vA, 151,50);
      end;

    end;

    701 : begin
      Gv.Alpha.10 # 'Einsatzinformationen';
      Gv.Alpha.11 # '';
      Gv.Alpha.12 # '';
      Gv.Alpha.13 # '';
      Gv.Alpha.14 # '';

      case ( BAG.IO.Materialtyp ) of
        c_IO_Mat, c_IO_VSB : begin // echtes Material
          Gv.Alpha.11 # 'Material ' + AInt( BAG.IO.MaterialNr );

          Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
          if ( Erx>=200 ) and ( Mat.Reserviert.Gew > 0.0 ) then
            Gv.Alpha.15 # 'Reservierungen vorhanden';
        end;

        c_IO_Art : begin // Artikel
          Gv.Alpha.11 # 'Artikel ' + BAG.IO.ArtikelNr;
        end;

        c_IO_Beistell : begin // Beistellungsartikel
          Gv.Alpha.11 # 'Beistellungsartikel ' + BAG.IO.ArtikelNr;
        end;

        c_IO_Theo : begin // theoretisches Material
          Gv.Alpha.11 # 'theoretischer Einsatz';
        end;

        c_IO_BAG : begin // Weiterbearbeitung
          Gv.Alpha.11 # 'Weiterbearbeitung aus ' + AInt( BAG.IO.VonBAG ) + '/' + AInt( BAG.IO.VonPosition );
          if ( BAG.IO.VonFertigung > 0 ) and ( BAG.IO.VonFertigung < 999 ) then
            Gv.Alpha.11 # Gv.Alpha.11 + '/' + AInt( BAG.IO.VonFertigung );

          if ( BAG.IO.UrsprungsID != 0 ) then
            Gv.Alpha.14 # 'Ursprungseinsatz ' + AInt( BAG.IO.UrsprungsID );
        end;
      end;
    end;

    703 : begin
      Gv.Alpha.10 # 'Fertigungsinformation';
      Gv.Alpha.11 # '';
      Gv.Alpha.12 # '';
      Gv.Alpha.13 # '';
      Gv.Alpha.14 # '';
    end;
  end;

  if ( BAG.P.Nummer = 999 ) then begin
    Gv.Alpha.11 # '';
    Gv.Alpha.12 # '';
    Gv.Alpha.13 # '';
    Gv.Alpha.14 # '';
    Gv.Alpha.15 # '';
  end;

  $lbInformation->WinUpdate( _winUpdFld2Obj );
  $lbInfo1->WinUpdate( _winUpdFld2Obj );
  $lbInfo2->WinUpdate( _winUpdFld2Obj );
  $lbInfo3->WinUpdate( _winUpdFld2Obj );
  $lbInfo4->WinUpdate( _winUpdFld2Obj );
  $lbInfo5->WinUpdate( _winUpdFld2Obj );
end;


//=========================================================================
// Start
//        Ressourcenplanung mit Selektion starten
//=========================================================================
sub Start ()
begin
  if (RunAFX('Betrieb.RsoPlan.Start','')<>0) then RETURN;

  Sel.BAG.Res.Gruppe # 0;
  Sel.BAG.Res.Nummer # 0;
  Sel.von.Datum      # today;
  Sel.bis.Datum      # today;
  Sel.BAG.MitUngeplant  # n;

  RecBufClear(702);
//  gMDI # Lib_GuiCom:AddChildWindow( gFrmMain, 'Sel.Betrieb.RsoPlan', here + ':AusSel' );
  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.Betrieb.RsoPlan', here + ':AusSel' );
  Lib_GuiCom:RunChildWindow( gMDI );
end;


//=========================================================================
//=========================================================================
sub _SucheZeit(aLock : logic): logic
local begin
  Erx : int;
end;
begin
  // Zeiten loopen...
  FOR Erx # RecLink(709,702,6,_recFirst)
  LOOP Erx # RecLink(709,702,6,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.Z.Bemerkung = cZeitBemerkung) then begin
      if (aLock) then
        RecRead(709,1,_RecLock);
      RETURN true;
    end;
  END;
  
//  if (aLock) then RETURN false;
  
  RecBufClear(709);
  Erx # RecLink(709,702,6,_RecLast);    // lette Zeit der Pos. holen
  If (Erx <= _rLocked) then BAG.Z.LfdNr # BAG.Z.LfdNr + 1;
  else BAG.Z.lfdNr         # 1;
  BAG.Z.Nummer        # BAG.P.Nummer;
  BAG.Z.Position      # BAG.P.Position;
  BAG.Z.ResGruppe     # BAG.P.Ressource.Grp;
  BAG.Z.Ressource     # BAG.P.Ressource;
  BAG.Z.Fertigung     # 0;
  BAG.Z.Fertigmeldung # 0;
  
  BAG.Z.Zeitentyp     # cZeitTyp;
  BAG.Z.Bemerkung     # cZeitBemerkung;
  
  RETURN false;
end


//=========================================================================
//=========================================================================
sub SetStartPunkt()
local begin
  vNeu  : logic;
end;
begin
  vNeu # !_SucheZeit(true);
  if (vNeu=false) and (BAG.Z.StartDatum<>0.0.0) then begin
    if (Msg(99,'Soll die bereits vorhandene Zeit überschrieben werden?',_WinIcoQuestion,_WinDialogYesNo, 2)<>_Winidyes) then begin
      RecRead(709,1,_recunlock);
      RETURN;
    end;
  end;
  BAG.Z.Startdatum  # today;
  BAG.Z.Startzeit   # now;
  BAG.Z.Dauer       # 0.0;
  if (vNeu) then
    BA1_Z_Data:Insert()
  else
    RekReplace(709);
/***
  // 06.11.2018 : BSP??
  RecRead(702,1,_RecLock);
  BAG.P.Plan.StartDat   # BAG.Z.Startdatum;
  BAG.P.Plan.StartZeit  # BAG.Z.Startzeit;
  BA1_P_Data:Replace(_RecUnlock,'MAN');
***/
  Msg(999998,'',0,0,0);
  RefreshInformation( 702 );

        // Prüfen ob schon eine Zeit angegeben worden ist
//            if  (Bag.P.Position = BAG.Z.Position) AND
//                (BAG.Z.Bemerkung = '<ZEIT AUS TERMINLISTE>') then begin
//        if (gUsergroup = 'BETRIEB') then begin
//                Bag.Z.Art       # 'Prod';
end;


//=========================================================================
//=========================================================================
sub SetEndPunkt()
local begin
  vNeu  : logic;
end;
begin
  vNeu # !_SucheZeit(true);
  if (vNeu=false) and (BAG.Z.EndDatum<>0.0.0) then begin
    if (Msg(99,'Soll die bereits vorhandene Zeit überschrieben werden?',_WinIcoQuestion,_WinDialogYesNo, 2)<>_Winidyes) then begin
      RecRead(709,1,_recunlock);
      RETURN;
    end;
  end;
  BAG.Z.EndDatum  # today;
  BAG.Z.Endzeit   # now;
  BAG.Z.Dauer     # 0.0;
 
  if (vNeu) then begin
    BA1_Z_Data:Insert();
  end
  else begin
    BA1_Z_Data:Timecalc();
    RekReplace(709);
  end;
/***
  // 06.11.2018 : BSP??
  RecRead(702,1,_RecLock);
  BAG.P.Plan.EndDat   # BAG.Z.Enddatum;
  BAG.P.Plan.EndZeit  # BAG.Z.Endzeit;
  BA1_P_Data:Replace(_RecUnlock,'MAN');
***/
  Msg(999998,'',0,0,0);
  RefreshInformation( 702 );
end;


//=========================================================================
//=========================================================================
sub Suche();
local begin
  Erx     : int;
  vA,vB   : alpha;
  vBA     : int;
  vPos    : int;
  vHdl    : int;
  vSel    : int;
end;
begin
  if (Dlg_Standard:Standard(translate('Betriebsauftrag'),var vA)=false) then RETURN;
  if (vA='') then RETURN;
  vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

  vB # Str_Token(vA,'/',1);
  vBA # cnvia(vB);
  vB # Str_Token(vA,'/',2);
  vPos # cnvia(vB);

  vHdl # Winsearch(gMDI, 'rlBAG');
  if (vHdl=0) then RETURN;
  
  vSel # vHdl->wpDbSelection;
  FOR Erx # RecRead(702,vSel,_RecFirst)
  LOOP Erx # RecRead(702,vSel,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.P.Nummer=vBA) and
      ((BAG.P.Position=vPos) or (vPos=0)) then begin
      RefreshList(vHdl, _WinLstRecFromRecid | _WinLstRecDoSelect);
      RETURN;
    end;
  END;

  RefreshList(vHdl, _WinLstRecFromRecid | _WinLstRecDoSelect);
  Msg(99,'Nicht gefunden!',0,0,0);
end;

 
//=========================================================================
//=========================================================================
sub Refresh();
local begin
  vHdl  : int;
  v702  : int;
end;
begin
  v702 # Reksave(702);

  vHdl # Winsearch(gMDI, 'rlBAG');
  if (vHdl=0) then RETURN;
  SelRun( vHdl->wpDbSelection, 0 );
//  RecBufClear( 702 );
  if (BAG.P.Nummer=0) then
    $rlBAG->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect )
  else
    $rlBAG->WinUpdate( _winUpdOn, _WinLstFromTop | _WinLstRecFromBuffer );
  
  if ( RecInfo( 702, _recCount, $rlBAG->wpDbSelection ) = 0 ) then begin
    $rlEinsatz->wpDbFileNo       # 999;
    $rlEinsatz->wpDbKeyNo        # 1;
    $rlEinsatz->wpDbLinkFileNo   # 0;
    $rlFertigung->wpDbFileNo     # 999;
    $rlFertigung->wpDbKeyNo      # 1;
    $rlFertigung->wpDbLinkFileNo # 0;
  end
  else begin
    $rlEinsatz->wpDbFileNo       # 702;
    $rlEinsatz->wpDbKeyNo        # 2;
    $rlEinsatz->wpDbLinkFileNo   # 701;
    $rlFertigung->wpDbFileNo     # 702;
    $rlFertigung->wpDbKeyNo      # 4;
    $rlFertigung->wpDbLinkFileNo # 703;
  end;
  RekRestore(v702);
  
end;


//=========================================================================
// EvtClicked
//        Button Klick
//=========================================================================
sub EvtClicked ( aEvt : event ) : logic
local begin
  vChangePos  : int;
  vHdl        : int;
end;
begin

  Crit_Prozedur:Manage();

  if (RunAFX('Betrieb.RsoPlan.EvtClicked',aint(aEvt:Obj))<0) then RETURN true;

  case ( aEvt:obj->wpName ) of
    'btnSuche'  : Suche();
    'btnStart'  : SetStartPunkt();
    'btnStop'   : begin
      SetEndPunkt();
      vHdl # Winsearch(gMDI, 'rlBAG');
      if (vHdl<>0) then
        RefreshList(vHdl, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;
    
    'btnPrev' : if ( BAG.P.Nummer != 0 ) then vChangePos # _recPrev;
    'btnNext' : if ( BAG.P.Nummer != 0 ) then vChangePos # _recNext;

    'btnRefresh' : Refresh();

    'btnFertigmelden' : begin
      if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
      
      if (BAG.P.Aktion2='GLPLAN') then begin
        Msg(99,'Bitte die BAs manuell fertigmelden anhand der obigen Nummern!',0,0,0);
        RETURN true;
      end;

      RecBufClear( 707 );
      BAG.FM.Nummer   # BAG.P.Nummer;
      BAG.FM.Position # BAG.P.Position;

      // Einsatz vorbelegen, wenn markiert
      if ( $rlEinsatz->wpDbRecId != 0 ) then begin
        // Fertigung vorbelegen, wenn markiert
        if ( $rlFertigung->wpDbRecId != 0 ) then begin
          // ...
        end;
      end;

      // Fertigmelden
      BA1_Fertigmelden:FMKopf(here+':AusFMKopf');
      ErrorOutput;
// VERSPRINGT BUFFER      Refresh(); 06.11.2018
    end;
  end;

  // Aktuelles Element wechseln
  if ( vChangePos != 0 ) then begin
    case w_AppendNr of
      702 : begin
        RecRead( 702, $rlBAG->wpDbSelection, vChangePos );
        $rlBAG->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
      end;

      701 : begin
        RecLink( 701, 702, 2, vChangePos );
        $rlEinsatz->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
      end;

      703 : begin
        RecLink( 703, 702, 4, vChangePos );
        $rlFertigung->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
      end;
    end;
  end;

  RETURN true;
end;


//=========================================================================
// EvtClose
//        Schließen des Fensters
//=========================================================================
sub EvtClose ( aEvt : event ) : logic
begin
  RETURN App_Main:EvtClose( aEvt );
end;


//=========================================================================
// EvtFocusInit
//        Objektfokus
//=========================================================================
sub EvtFocusInit ( aEvt : event; aFocusObject : int ) : logic
local begin
  vHdl : handle;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  case ( aEvt:obj ) of
    $rlBAG       : RefreshInformation( 702 );
    $rlEinsatz   : RefreshInformation( 701 );
    $rlFertigung : RefreshInformation( 703 );
  end;
end;


//=========================================================================
// EvtInit
//        Initialisierung des Frames
//=========================================================================
sub EvtInit ( aEvt : event ) : logic
begin
  gZLList    # $rlBAG;
  w_AppendNr # 0;//-3; // Init Hack

  RecBufClear( 702 );
  RecBufClear( 701 );
  RecBufClear( 703 );
  RecBufClear( 706 );

  // Ressourcenbezeichnung
  Rso.Gruppe # Sel.BAG.Res.Gruppe;
  Rso.Nummer # Sel.BAG.Res.Nummer;
  if ( RecRead( 160, 1, 0 ) > _rLocked ) then
    RecBufClear( 160 );
  $lbTitle->wpCaption # 'Maschine ' + CnvAI( Rso.Gruppe ) + '/' + CnvAI( Rso.Nummer ) + ': ' + Rso.Stichwort;

  RETURN App_Main:EvtInit( aEvt );
end;


//=========================================================================
//=========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  gMDI # aEvt:Obj;
  RETURN(true);
end;


//=========================================================================
// EvtLstDataInit
//        Datenanzeige im RecList
//=========================================================================
sub EvtLstDataInit ( aEvt : event; aId : int )
local begin
  Erx : int;
end;
begin
  
  if (RunAFX('Betrieb.RsoPlan.EvtLstDataInit',aint(aEvt:Obj)+'|'+aint(aID))<0) then RETURN;

  case ( aEvt:obj ) of
    $rlBAG : begin
      Gv.Alpha.01 # CnvAI( BAG.P.Nummer ) + '/' + CnvAI( BAG.P.Position );
      if ( BAG.P.Level > 1 ) then
        Gv.Alpha.02 # StrChar( 32, ( BAG.P.Level * 3 ) - 3 ) + BAG.P.Bezeichnung;
      else
        Gv.Alpha.02 # BAG.P.Bezeichnung;

        // 03.12.2018 AH:
        if (_SucheZeit(false)) then begin
          if (BAG.Z.EndDatum<>0.0.0) then begin
            Lib_GuiCom:ZLColorLine(aEvt:Obj, _WinColLightGreen);
          end;
        end;
    end;

    $rlEinsatz : begin
      Gv.Alpha.01 # '...'; // Einsatztyp
      Gv.Alpha.02 # '...'; // MatNr
      Gv.Alpha.03 # '...'; // Güte
      Gv.Alpha.04 # '...'; // Abmessungen
      Gv.Alpha.05 # ANum( BAG.IO.Ist.In.Menge, Set.Stellen.Menge ) + ' ' + BAG.IO.MEH.In; // Ist Menge

      case ( BAG.IO.Materialtyp ) of
        c_IO_Mat, c_IO_VSB : begin // echtes Material
          if ( BAG.IO.Materialtyp = c_IO_VSB ) then
            Gv.Alpha.01 # 'VSB Mat';
          else
            Gv.Alpha.01 # 'Mat';
          Gv.Alpha.02 # AInt( BAG.IO.MaterialNr );

          // Material laden
          Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

          Gv.Alpha.03 # "Mat.Güte";
          Gv.Alpha.04 # ANum( Mat.Dicke, Set.Stellen.Dicke ) + ' x ' + ANum( Mat.Breite, Set.Stellen.Breite );
          if ( "Mat.Länge" != 0.0 ) then
            Gv.Alpha.04 # Gv.Alpha.04 + ' x ' + ANum( "Mat.Länge", "Set.Stellen.Länge" );
        end;

        c_IO_Art, c_IO_Beistell : begin // Artikel
          Gv.Alpha.01 # 'Art';
          Gv.Alpha.02 # BAG.IO.Artikelnr;

          if ( RecLink( 250, 701, 8, _recFirst ) <= _rLocked ) then begin
            Gv.Alpha.03 # Art.Stichwort;
            Gv.Alpha.04 # Art.Bezeichnung1;
          end;
        end;

        c_IO_Theo : begin // theoretisches Material
          Gv.Alpha.01 # 'theor. Mat';
          Gv.Alpha.02 # '';
          Gv.Alpha.03 # "BAG.IO.Güte";
          Gv.Alpha.04 # ANum( BAG.IO.Dicke, Set.Stellen.Dicke ) + ' x ' + ANum( BAG.IO.Breite, Set.Stellen.Breite );
          if ( "BAG.IO.Länge" != 0.0 ) then
            Gv.Alpha.04 # Gv.Alpha.04 + ' x ' + ANum( "BAG.IO.Länge", "Set.Stellen.Länge" );
        end;

        c_IO_BAG : begin // Weiterbearbeitung
          if ( BAG.IO.VonID != 0 ) then begin
            if ( BAG.IO.VonBAG = BAG.IO.Nummer ) then begin
              Gv.Alpha.01 # 'Teil Pos.';
              Gv.Alpha.02 # AInt( BAG.IO.VonPosition );
            end
            else begin
              Gv.Alpha.01 # 'Teil BA';
              Gv.Alpha.02 # AInt( BAG.IO.VonBAG ) + '/' + AInt( BAG.IO.VonPosition );
            end;

            Gv.Alpha.03 # "BAG.IO.Güte";
            Gv.Alpha.04 # ANum( BAG.IO.Dicke, Set.Stellen.Dicke ) + ' x ' + ANum( BAG.IO.Breite, Set.Stellen.Breite );
            if ( "BAG.IO.Länge" != 0.0 ) then
              Gv.Alpha.04 # Gv.Alpha.04 + ' x ' + ANum( "BAG.IO.Länge", "Set.Stellen.Länge" );
          end
          else begin
            if ( BAG.IO.VonBAG = BAG.IO.Nummer ) then begin
              Gv.Alpha.01 # 'Fertigung';
              Gv.Alpha.02 # AInt( BAG.IO.VonPosition ) + '/' + AInt( BAG.IO.VonFertigung );
            end
            else begin
              Gv.Alpha.01 # c_Akt_BA;
              Gv.Alpha.02 # AInt( BAG.IO.VonBAG ) + '/' + AInt( BAG.IO.VonPosition ) + '/' + AInt( BAG.IO.VonFertigung );
            end;

            BAG.F.Nummer    # BAG.IO.VonBAG;
            BAG.F.Position  # BAG.IO.VonPosition;
            BAG.F.Fertigung # BAG.IO.VonFertigung;
            if ( RecRead( 703, 1, 0) <= _rLocked ) then begin
              Gv.Alpha.03 # "BAG.F.Güte";
              Gv.Alpha.04 # ANum( BAG.F.Dicke, Set.Stellen.Dicke ) + ' x ' + ANum( BAG.F.Breite, Set.Stellen.Breite );
              if ( "BAG.F.Länge" != 0.0 ) then
                Gv.Alpha.04 # Gv.Alpha.04 + ' x ' + ANum( "BAG.F.Länge", "Set.Stellen.Länge" );
            end;
          end;
        end;
      end;
    end;

    $rlFertigung : begin
      Gv.Alpha.01 # ANum( BAG.F.Dicke, Set.Stellen.Dicke ) + ' x ' + ANum( BAG.F.Breite, Set.Stellen.Breite );
      if ( "BAG.F.Länge" != 0.0 ) then
        Gv.Alpha.01 # Gv.Alpha.01 + ' x ' + ANum( "BAG.F.Länge", "Set.Stellen.Länge" );

      if ( BAG.F.AusfOben != '' and BAG.F.AusfUnten != '' ) then
        Gv.Alpha.02 # BAG.F.AusfOben + ' / ' + BAG.F.AusfUnten;
      else if ( BAG.F.AusfOben = '' ) then
        Gv.Alpha.02 # BAG.F.AusfUnten;
      else if ( BAG.F.AusfUnten = '' ) then
        Gv.Alpha.02 # BAG.F.AusfOben;
    end;
  end;
end;


//=========================================================================
// EvtLstSelect
//        Zeilenauswahl im RecList
//=========================================================================
sub EvtLstSelect ( aEvt : event; aId : int ) : logic
local begin
  vHdl  : int;
end;
begin

  case ( aEvt:obj ) of
    $rlBAG : begin
      RecRead( 702, 0, _recId, aId );
/*** 05.08.2019      **/
      vHdl # Winsearch(gMDI,'ZL.Walzstiche');
      if (vHdl<>0) then begin
        $gt.rechts->wpVisible # (BAG.P.Aktion=c_bag_Walz);
        vHdl->wpVisible # (BAG.P.Aktion=c_bag_Walz);
        if (vHdl->wpVisible) then begin
          RecBufClear(706);
          vHdl->wpLstFlags # vHdl->wpLstFlags & ~_WinLstLockRefresh;
          vHdl->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecEvtSkip);
          RecBufClear(706);
        end;
      end;
/***/
      $rlEinsatz->wpLstFlags # $rlEinsatz->wpLstFlags & ~_WinLstLockRefresh;
      $rlEinsatz->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecEvtSkip );
      $rlFertigung->wpLstFlags # $rlFertigung->wpLstFlags & ~_WinLstLockRefresh;
      $rlFertigung->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecEvtSkip );
     
      RefreshInformation( 702 );
    end;

    $rlEinsatz : begin
      RecRead( 701, 0, _recId, aId );
      RefreshInformation( 701 );
    end;

    $rlFertigung : begin
      RecRead( 703, 0, _recId, aId );
      RefreshInformation( 703 );
    end;
  end;

  // Init Hack um Markierung im Startzustand zu verhinden
  if ( w_AppendNr < 0 ) then begin
    inc( w_AppendNr );
    if ( w_AppendNr >= 0 ) then
      $rlBAG->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );
  end;
end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
begin
  RETURN true;
end;


//=========================================================================
//=========================================================================
sub AusFMKopf();
begin
  Refresh();
end;


//=========================================================================
// AusSel
//        Selektion auswerten
//=========================================================================
sub AusSel ()
local begin
  vQ       : alpha(1000);
  vSel     : int;
  vSelName : alpha;
end
begin
  /* Selektion */
  Lib_Sel:QAlpha( var vQ, 'BAG.P.Aktion', '!=', c_Akt_VSB );
  Lib_Sel:QDate( var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0 );
  if ( Sel.BAG.Res.Gruppe != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
  if ( Sel.BAG.Res.Nummer != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );
  Lib_Sel:QVonBisD( var vQ, 'BAG.P.Plan.StartDat', Sel.von.Datum, Sel.bis.Datum, 'AND (' );

  if ( Sel.BAG.mitUngeplant ) then begin
    Lib_Sel:QDate( var vQ, 'BAG.P.Plan.StartDat', '>', 0.0.0, 'OR (' );
    Lib_Sel:QDate( var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0, 'AND' );
    vQ # vQ + ')';
  end;

  vQ # vQ + ' ) AND ( !BAG.P.ExternYN ) AND ( LinkCount( Kopf ) > 0 AND ( LinkCount( Input ) > 0 ))';

  vSel # SelCreate( 702, 0 );
  vSel->SelAddLink( '', 700, 702, 1, 'Kopf' );
  vSel->SelAddLink( '', 701, 702, 2, 'Input' );   // 25.10.2018 AH

  vSel->SelAddSortFld( FldInfoByName( 'BAG.P.Plan.StartDat', _fldSbrNumber ), FldInfoByName( 'BAG.P.Plan.StartDat', _fldNumber ) );
  vSel->SelAddSortFld( FldInfoByName( 'BAG.P.Plan.StartZeit', _fldSbrNumber ), FldInfoByName( 'BAG.P.Plan.StartZeit', _fldNumber ) );
  vSel->SelDefQuery( '', vQ );
  Lib_Sel:QError( vSel );
  vSel->SelDefQuery( 'Kopf', '"BAG.Löschmarker" = '''' AND BAG.VorlageYN=false' );    // 20.05.2021 AH: keine Vorlagen!!
  Lib_Sel:QError( vSel );
  vSelName # Lib_Sel:SaveRun( var vSel, 0, false );
  
  ShowDialog(vSel, vSelName);
end;


//=========================================================================
// startet den Dialog mit der vorgegebenen Selektion
//=========================================================================
sub ShowDialog(
  aSel      : int;
  aSelName  : alpha;
)
begin
  /* Fenster anzeigen */
  gMdi # gFrmMain->WinAddByName(Lib_GuiCom:GetAlternativeName('Mdi.RsoPlan'));
  $rlBAG->wpDbSelection # aSel;

  if ( RecInfo( 702, _recCount, $rlBAG->wpDbSelection ) = 0 ) then begin
    $rlEinsatz->wpDbFileNo       # 999;
    $rlEinsatz->wpDbKeyNo        # 1;
    $rlEinsatz->wpDbLinkFileNo   # 0;
    $rlFertigung->wpDbFileNo     # 999;
    $rlFertigung->wpDbKeyNo      # 1;
    $rlFertigung->wpDbLinkFileNo # 0;
  end
  else begin
    $rlEinsatz->wpDbFileNo       # 702;
    $rlEinsatz->wpDbKeyNo        # 2;
    $rlEinsatz->wpDbLinkFileNo   # 701;
    $rlFertigung->wpDbFileNo     # 702;
    $rlFertigung->wpDbKeyNo      # 4;
    $rlFertigung->wpDbLinkFileNo # 703;
  end;

  w_SelName # aSelName;
  Mode      # c_ModeList;
  gMenuName # 'RsoPlan.Bearbeiten';
  gFrmMain->wpMenuName # gMenuName;

  /* Frame
  vFrm # WinOpen( 'Frame.RsoPlan', _winOpenDialog );
  $rlBAG->wpDbSelection # vSel;
  vFrm->WinDialogRun( _winDialogCenter, gFrmMain );
  vFrm->WinClose();
  vSel->SelClose();
  SelDelete( 702, vSelName );
  */
end;


//=========================================================================
//=========================================================================