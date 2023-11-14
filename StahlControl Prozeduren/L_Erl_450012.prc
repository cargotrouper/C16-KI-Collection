@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450012
//                    OHNE E_R_G
//
//  Info        Finanzstatus: Gibt folgende Daten aus
//                Umsätze Steuer: innerhalb des angegebenen Zeitraums
//                Offene Posten: nicht gelöscht
//                Eingangsrechnungen Steuer: alle zugeordneten (EKK) innerhalb des Zeitraums
//                Eingangsrechnungen: alle zugeordneten (EKK), nicht gelöschten mit Restbetrag
//                Einkaufskontrolle Steuer: nur unzugeordnete
//                Einkaufskontrolle: nur unzugeordnete
//                Fixkosten: innerhalb des Zeitraums
//                Aufträge: nicht gelöschte
//                Bestellungen: nicht gelöschte
//
//  24.11.2008  PW  Erstellung der Prozedur
//  10.03.2014  AH  Controlling-Forecast eingebaut
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList ( aSort : int; aSortName : alpha );

define begin
  cCONMonate  : 3
end;


global Struct_FS_Item begin
  sFS_Datum   : date;
  sFS_Code    : alpha(15);
  sFS_Aktion  : alpha;
  sFS_AktionZ : alpha;
  sFS_Betrag  : float;
end;

local begin
  vDatVon     : date;
  vDatBis     : date;
  vZukunft    : logic;
  vDetailed   : logic;
  vDauerFrist : int;
  vKontostand : float;
  vUstTag     : int;
end;


//========================================================================
//  MAIN
//
//========================================================================
MAIN
local begin
  vHdl  : int;
end;
begin

  vDatVon   # today;
  vDatBis   # today;
  vZukunft  # true;
  vDetailed # true;

  vDatBis->vpDay     # 1;
  vDatBis->vmMonthModify( 1 );
  if ( vDatBis->vpMonth <  4 ) then
    vDatBis->vpMonth #  4;
  else if ( vDatBis->vpMonth <  7 ) then
    vDatBis->vpMonth #  7;
  else if ( vDatBis->vpMonth < 10 ) then
    vDatBis->vpMonth # 10;
  else begin
    vDatBis->vpMonth # 1;
    vDatBis->vpYear  # vDatBis->vpYear + 1;
  end;
  vDatBis->vmDayModify( -1 );

  // Selektion
  RecBufClear( 998 );
  "Sel.von.Datum"       # vDatVon;
  "Sel.bis.Datum"       # vDatBis;
  "Sel.Fin.nurMarkeYN"  # vDetailed; // Ausführliche Liste
  "Sel.Fin.GelöschteYN" # vZukunft;  // erfasste Aufträge und Bestellungen
  Sel.von.monat         # 15;
  Sel.Bis.monat         # 2;
  gMDI                  # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.450012', here + ':AusSel' );
  gMDI->wpCaption       # Lfm.Name;

  vHdl # Winsearch(gMDI, 'edSel.Von.Menge')
  if (vHdl<>0) then vHdl->wpDecimals # 2;
  vHdl # Winsearch(gMDI, 'edSel.Bis.Menge')
  if (vHdl<>0) then vHdl->wpDecimals # 0;

  Lib_GuiCom:RunChildWindow( gMDI );
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel ();
begin
  //vDatVon   # "Sel.von.Datum";
  vDatVon     # today;
  vDatBis     # "Sel.bis.Datum";
  vDetailed   # "Sel.Fin.nurMarkeYN";
  vZukunft    # "Sel.Fin.GelöschteYN";
  vUstTag     # Sel.Von.monat;
  vDauerfrist # Sel.Bis.monat;
  vKontostand # Sel.Von.Menge;
  StartList( 0, '' );
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf ( aSeite : int );
begin
  WriteTitel();
  List_Spacing[2] # 0.0;
  Write( 1, 'Finanzstatus vom ' + CnvAD( vDatVon ) + ' bis zum ' + CnvAD( vDatBis ), n, 0 );

  StartLine();
  EndLine();
  StartLine();
  EndLine();

  List_Spacing[1] #   0.0;
  List_Spacing[2] #  22.0;
  List_Spacing[5] # 120.0;
  List_Spacing[6] # 150.0;
  List_Spacing[7] # 190.0;

  StartLine( _LF_BOLD | _LF_UNDERLINE );
  Write( 1, 'Datum',     n, 0 );
  Write( 2, 'Aktion',    n, 0 );
  Write( 5, 'Vorgang €', y, 0, 3.0 );
  Write( 6, 'Summe €',   y, 0, 3.0 );
  EndLine();

  List_Spacing[1] #   0.0;
  List_Spacing[2] #  22.0;
  List_Spacing[3] #  37.0;
  List_Spacing[4] #  70.0;
  List_Spacing[5] # 120.0;
  List_Spacing[6] # 150.0;
  List_Spacing[7] # 190.0;
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  TreeAddItem
//
//========================================================================
sub TreeAddItem (
  aList          : int;
  aFS_Datum      : date;
  aFS_Code       : alpha(15);
  aFS_Aktion     : alpha;
  aFS_AktionZ    : alpha;
  aFS_Betrag     : float;
);
local begin
  vItem   : int;
  vStruct : int;
end;
begin
  vItem           # CteOpen( _cteItem );
  vItem->spName   # CnvAI( CnvID( aFS_Datum ), _fmtNumLeadZero | _fmtNumNoGroup, 0, 10 ) + '||' + aFS_Code + '||' + aFS_Aktion + '||' + CnvAF( aFS_Betrag, _fmtNumNoGroup );
  vItem->spID     # 0;
  vItem->spCustom # CnvAD( aFS_Datum );

  vStruct         # VarAllocate( Struct_FS_Item );
  sFS_Datum       # aFS_Datum;
  sFS_Code        # aFS_Code;
  sFS_Aktion      # aFS_Aktion;
  sFS_AktionZ     # aFS_AktionZ;
  sFS_Betrag      # aFS_Betrag;

  HdlLink( vItem, vStruct );

  if ( !aList->CteInsert( vItem ) ) then
    vItem->CteClose();
end;


//========================================================================
//========================================================================
sub TreeAddIstItem(
  aTree : int;
  aDat  : date;
  aWert : float);
local begin
  vItem : int;
  vName : alpha;
end;
begin

  if (aDat=0.0.0) then RETURN;

  vName # aint(aDat->vpmonth)+'|'+aint(aDat->vpyear);
  vItem # CteRead(aTree, _CteFirst | _CteSearchCI,0, vName);
  if (vItem=0) then begin
    Lib_RamSort:Add( aTree, vName, 0, anum(aWert,2));
    RETURN;
  end;

  aWert # aWert + cnvfa(vItem->spcustom);
  vItem->spcustom # anum(aWert,2);
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList ( aSort : int; aSortName : alpha );
local begin
  Erx         : int;
  vTree       : int;
  vTreeSt     : int;
  vTreeIST    : int;
  vItem       : int;
  vSel        : int;
  vSelName    : alpha;
  vDialog     : int;
  vContinue   : logic;
  vDat        : date;
  vCONAbweich : float;

  vFS_Datum   : date;
  vFS_Code    : alpha(15);
  vFS_Aktion  : alpha;
  vFS_AktionZ : alpha;
  vFS_Betrag  : float;
  vSumIn      : float;
  vSumOut     : float;
  vSumLager   : float;
  vI          : int;
  vJ          : int;
  vX, vY, vZ  : float;
  vDatErl     : date;
  vCONSteuer  : float;
  vWert       : float;
end;
begin
  gFrmMain->WinFocusSet();
  ListInit( n );

  vTree     # CteOpen( _cteTreeCI );
  vTreeSt   # CteOpen( _cteTreeCI );
  vTreeIst  # CteOpen( _cteTreeCI );

  vContinue # true;
  vDialog   # WinOpen( 'Dlg.Progress', _winOpenDialog );
  if ( vDialog != 0 ) then begin
    vItem # WinSearch( vDialog, 'Label1' );
    vItem->wpCaption # Translate( 'Berechne...' );
    $Progress->wpProgressPos #  0;
    $Progress->wpProgressMax # 10;
    vDialog->WinDialogRun( _winDialogAsync | _winDialogCenter );
  end;


  /* Eintrag: Kontostand */
  TreeAddItem( vTree, today, '', 'KONTOSTAND am ' + CnvAD( today ), '', vKontostand );

  /* Eintrag: Umsätze */
  vDatErl # DateMake(1,vDatVon->vpmonth,vDatVon->vpyear-1900);
  vDatErl->vmMonthModify(-vDauerFrist);

  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  RecBufClear( 450 );
  Erl.Rechnungsdatum # vDatErl;
  FOR  Erx # RecRead( 450, 4, 0 );
  LOOP Erx # RecRead( 450, 4, _recNext );
  WHILE ( Erx <= _rLastRec ) AND ( Erl.Rechnungsdatum >= vDatErl and Erl.Rechnungsdatum <= vDatBis ) DO BEGIN
    if ( Erl.SteuerW1 = 0.0 ) then
      CYCLE;
    TreeAddItem( vTreeSt, Erl.Rechnungsdatum, '[ST] Erl', CnvAI( Erl.Rechnungsnr ), 'Steuer', -Erl.SteuerW1 );
  END;



  /* Eintrag: Offene Posten */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  FOR  Erx # RecRead( 460, 1, _recFirst );
  LOOP Erx # RecRead( 460, 1, _recNext );
  WHILE ( Erx < _rLocked ) DO BEGIN
    if ( "OfP.Löschmarker" != '' ) then
      CYCLE;

    RecLink( 100, 460,  4, _recFirst );
    RecLink( 103, 100, 14, _recFirst );

    // Zahlungsmoral
    if ( Adr.Fin.Vzg.FixTag != 0 ) then begin
      if ( OfP.Zieldatum->vpDay > Adr.Fin.Vzg.FixTag ) then
        OfP.Zieldatum->vmMonthModify(1);
      OfP.Zieldatum->vpDay # Adr.Fin.Vzg.FixTag;
    end
    else if ( Adr.Fin.Vzg.Offset != 0.0 ) then begin
      OfP.Zieldatum->vmDayModify( CnvIF( Adr.Fin.Vzg.Offset ) );
    end;

    TreeAddItem( vTree, OfP.Zieldatum, 'OfP', CnvAI( OfP.Rechnungsnr ), OfP.KundenStichwort, OfP.RestW1 );

//    TreeAddIstItem(vTreeIst, OfP.Zieldatum, OfP.RestW1 );
  END;


  /* Eintrag: Eingangsrechnungen */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  FOR  Erx # RecRead( 560, 1, _recFirst );
  LOOP Erx # RecRead( 560, 1, _recNext );
  WHILE ( Erx < _rLocked ) DO BEGIN
    if ( RecLinkInfo( 555, 560, 4, _recCount ) < 1 ) then
      CYCLE;

    if ( ERe.Rechnungsdatum >= vDatErl and ERe.Rechnungsdatum <= vDatBis ) and ( ERe.SteuerW1 != 0.0 ) then
      TreeAddItem( vTreeSt, ERe.Rechnungsdatum, '[ST] ERe', ERe.Rechnungsnr, 'Steuer', -ERe.SteuerW1 );

    if (( ERe.RestW1 < 0.9 ) and ( ERe.RestW1 > -0.9 )) or ( "ERe.Löschmarker" = '*' ) then
      CYCLE;

    TreeAddItem( vTree, ERe.Zieldatum, 'ERe', CnvAI( ERe.Nummer ), ERe.LieferStichwort, -ERe.RestW1 );
  END;


  /* Eintrag: Einkaufskontrolle */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  FOR  Erx # RecRead( 555, 1, _recFirst );
  LOOP Erx # RecRead( 555, 1, _recNext );
  WHILE ( Erx < _rLocked ) DO BEGIN
    if ( EKK.EingangsReNr != 0 ) then
      CYCLE;

    vFS_Code   # 'EKK';
    vFS_Aktion # CnvAI( EKK.ID1 ) + '/' + CnvAI( EKK.ID2 );
    if ( EKK.ID3 != 0 ) then
      vFS_Aktion # vFS_Aktion + '/' + CnvAI( EKK.ID3 );
    if ( EKK.ID4 != 0 ) then
      vFS_Aktion # vFS_Aktion + '/' + CnvAI( EKK.ID4 );
    vFS_Datum  # EKK.Datum;
    vFS_Betrag # -EKK.PreisW1;

    case EKK.Datei of
      702 : begin // Betriebsauftrag
        RecBufClear( 702 );
        BAG.P.Nummer   # EKK.ID1;
        BAG.P.Position # EKK.ID2;
        RecRead( 702, 1, 0 );
        vFS_Code # BAG.P.Aktion;
      end;

      406 : vFS_Code # 'VK-Rück'; // Erl.Rechnungsnr
      450 : vFS_Code # 'Re-Rück'; // Ausgangsrechnungsrückstellung (451->405)
      501 : vFS_Code # 'EK'; // Einkauf Divers
      505 : vFS_Code # 'Rück'; // Einkauf Kalkulation
      506 : vFS_Code # 'WE'; // Einkauf Wareneingang
    end;

    if ( vFS_Datum < today ) then
      vFS_Datum # today;

    if ( RecLink( 100, 555, 4, _recFirst ) < _rLocked ) then begin
      RecLink( 816, 100,  3, _recFirst );
      RecLink( 813, 100, 11, _recFirst );
      OfP_Data:BerechneZieldaten( vFS_Datum, true );

      // Zahlungsmoral
      if ( Adr.Fin.Vzg.FixTag != 0 ) then begin
        if ( OfP.Zieldatum->vpDay > Adr.Fin.Vzg.FixTag ) then
          OfP.Zieldatum->vmDayModify( 1);
        OfP.Zieldatum->vpDay # Adr.Fin.Vzg.FixTag;
      end
      else if ( Adr.Fin.Vzg.Offset != 0.0 ) then begin
        OfP.Zieldatum->vmDayModify( CnvIF( Adr.Fin.Vzg.Offset ) );
      end;

      if ( vFS_Betrag * StS.Prozent / 100.0 != 0.0 ) then
        TreeAddItem( vTreeSt, today, '[ST] ' + vFS_Code, CnvAI( EKK.Datei ) + ':' + vFS_Aktion , 'Steuer', vFS_Betrag * StS.Prozent / 100.0 );

      TreeAddItem( vTree, OfP.Zieldatum, vFS_Code, vFS_Aktion, EKK.LieferStichwort, vFS_Betrag * ( StS.Prozent + 100.0 ) / 100.0 );
    end
  END;


  /* Eintrag: Fixkosten */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  FOR  vJ # vDatVon->vpYear;
  LOOP vJ # vJ + 1;
  WHILE ( vJ <= vDatBis->vpYear ) DO BEGIn
    FxK.Jahr  # vJ;
    FxK.lfdNr # 1;
    FOR  Erx # RecRead( 558, 1, 0 );
    LOOP Erx # RecRead( 558, 1, _recNext );
    WHILE ( Erx < _rLocked ) and ( FxK.Jahr = vJ ) DO BEGIN
      if ( FxK.Zahltag = 0 ) then
        FxK.Zahltag # 1;
      vFS_Datum          # 0.0.0;
      vFS_Datum->vpYear  # vJ;

      FOR  vFS_Datum->vpMonth # 1;
      LOOP vFS_Datum->vmMonthModify( 1 )
      WHILE ( vFS_Datum->vpYear = vJ ) DO BEGIN
        vFS_Datum->vpDay   # FxK.Zahltag;

        if ( vFS_Datum >= vDatVon ) and (vFS_datum<=vDatBis) and
          ( fldFloat( 558, 1, 5 + vFS_Datum->vpMonth ) > 0.0 ) then
          TreeAddItem( vTree, vFS_Datum, 'Fix', FxK.Text1 + ' ' + FxK.Text2, '', -fldFloat( 558, 1, 5 + vFS_Datum->vpMonth ) );
      END;
    END;
  END;


  /* Eintrag: Aufträge */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  if ( vZukunft ) then begin
    FOR  Erx # RecRead( 401, 1, _recFirst );
    LOOP Erx # RecRead( 401, 1, _recNext );
    WHILE ( Erx < _rLocked ) DO BEGIN
      if ( "Auf.P.Löschmarker" != '' ) or ( Auf.P.Nummer > 10000000 ) then
        CYCLE;

      RecLink( 400, 401,  3, _recFirst ); // Kopf
      RecLink( 100, 400,  1, _recFirst ); // Kunde
      RecLink( 816, 400,  6, _recFirst ); // ZaB
      RecLink( 813, 100, 11, _recFirst ); // StS
      OfP_Data:BerechneZieldaten( Auf.P.Termin1Wunsch, true );

      // Zahlungsmoral
      if (Ofp.Zieldatum<>0.0.0) then begin
        if ( Adr.Fin.Vzg.FixTag != 0 ) then begin
          if ( OfP.Zieldatum->vpDay > Adr.Fin.Vzg.FixTag ) then
            OfP.Zieldatum->vmMonthModify( 1);
          OfP.Zieldatum->vpDay # Adr.Fin.Vzg.FixTag;
        end
        else if ( Adr.Fin.Vzg.Offset != 0.0 ) and (Abs(Adr.Fin.Vzg.Offset)<1000.0) then begin
          OfP.Zieldatum->vmDayModify( CnvIF( Adr.Fin.Vzg.Offset ) );
        end;
      end;

      vFS_Betrag # Lib_Einheiten:WandleMEH( 401, "Auf.P.Stückzahl" - Auf.P.Prd.Rest.Stk, Auf.P.Gewicht - Auf.P.Prd.Rest.Gew, Auf.P.Menge - Auf.P.Prd.Rest, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis );
      vFS_Betrag # vFS_Betrag * Auf.P.Einzelpreis / CnvFI( Auf.P.PEH );

      if ( vFS_Betrag * StS.Prozent / 100.0 != 0.0 ) then
        TreeAddItem( vTreeSt, Auf.P.Termin1Wunsch, '[ST] _Auf', CnvAI( Auf.P.Nummer ) + '/' + CnvAI( Auf.P.Position ), 'Steuer', -vFS_Betrag * StS.Prozent / 100.0 );

      TreeAddItem( vTree, OfP.Zieldatum, '_Auf', CnvAI( Auf.P.Nummer ) + '/' + CnvAI( Auf.P.Position ), Auf.P.KundenSW, vFS_Betrag * ( StS.Prozent + 100.0 ) / 100.0 );

      TreeAddIstItem(vTreeIst, OfP.Zieldatum, vFS_Betrag * ( StS.Prozent + 100.0 ) / 100.0);
    END;
  end;


  /* Eintrag: Bestellungen */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  if ( vZukunft ) then begin
    FOR  Erx # RecRead( 501, 1, _recFirst );
    LOOP Erx # RecRead( 501, 1, _recNext );
    WHILE ( Erx < _rLocked ) DO BEGIN
      if ( "Ein.P.Löschmarker" != '' ) or ( Ein.P.Nummer > 10000000 ) then
        CYCLE;

      if ( Ein.P.Termin1Wunsch = 0.0.0 ) then begin
        debug( 'Ungueltige Bestellung. ' + AInt( Ein.P.Nummer ) + '/' + AInt( Ein.P.Position ) );
        CYCLE;
      end

      RecLink( 500, 501,  3, _recFirst ); // Kopf
      RecLink( 100, 500,  1, _recFirst ); // Lieferant
      RecLink( 816, 500,  6, _recFirst ); // ZaB
      RecLink( 813, 100, 11, _recFirst ); // StS
      OfP_Data:BerechneZieldaten( Ein.P.Termin1Wunsch, true );

      // Zahlungsmoral
      if ( Adr.Fin.Vzg.FixTag != 0 ) then begin
        if ( OfP.Zieldatum->vpDay > Adr.Fin.Vzg.FixTag ) then
          OfP.Zieldatum->vmDayModify( 1 );
        OfP.Zieldatum->vpDay # Adr.Fin.Vzg.FixTag;
      end
      else if ( Adr.Fin.Vzg.Offset != 0.0 ) then begin
        OfP.Zieldatum->vmDayModify( CnvIF( Adr.Fin.Vzg.Offset ) );
      end;

      vFS_Betrag # Ein.P.FM.Rest + Ein.P.FM.VSB; //Lib_Einheiten:WandleMEH( 401, "Auf.P.Stückzahl" - Auf.P.Prd.Rest.Stk, Auf.P.Gewicht - Auf.P.Prd.Rest.Gew, Auf.P.Menge - Auf.P.Prd.Rest, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis );
      vFS_Betrag # vFS_Betrag * Ein.P.Einzelpreis / CnvFI( Ein.P.PEH );

      if ( vFS_Betrag * StS.Prozent / 100.0 != 0.0 ) then
        TreeAddItem( vTreeSt, Ein.P.Termin1Wunsch, '[ST] _Ein', CnvAI( Auf.P.Nummer ) + '/' + CnvAI( Auf.P.Position ), 'Steuer', vFS_Betrag * StS.Prozent / 100.0 );

      TreeAddItem( vTree, OfP.Zieldatum, '_Ein', CnvAI( Ein.P.Nummer ) + '/' + CnvAI( Ein.P.Position ), Ein.P.LieferantenSW, -vFS_Betrag * ( StS.Prozent + 100.0 ) / 100.0 );
    END;
  end;




  /* Eintrag: Controlling */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  if ( vZukunft ) and (StrFind(Set.Module,'C',0)<>0) then begin

    // heutige (!) Abweichung Ist<->Soll errechnen
    vDat        # today;
    vCONAbweich # 0.0;

    // größte Steuerprozent suchen...
    FOR Erx # RecRead(813,1,_recFirst)
    LOOP Erx # RecRead(813,1,_recnext)
    WHILE (Erx<=_rLocked) do begin
      if (StS.Prozent>vConSteuer) then vCONSteuer # StS.Prozent;
    END;
    vZ  # Rnd((100.0-Sel.Bis.Menge) * vCONSteuer / 100.0, 2);


    FOR vJ # 1 loop inc(vJ) while (vJ<=cCONMOnate) do begin
      vDat->vmMonthmodify(-1);
      vCONAbweich # vCONAbweich + Con_Data:AbweichungIstSoll(vDat, 'DB', '');
    END;
    vCONAbweich # vCONAbweich / cnvfi(cCONMonate);


    RecBufClear(950);
    Con.Typ   # '';
    Con.Jahr  # vDatVon->vpYear;

    FOR  Erx # RecRead( 950, 1, 0 );
    LOOP Erx # RecRead( 950, 1, _recNext );
    WHILE ( Erx < _rLocked ) and
        (Con.Typ='') and (Con.Jahr<=vDatBis->vpYear) do begin
        if (Con.Adressnummer<>0) or (Con.Vertreternr<>0) or (Con.Artikelnummer<>'') or
        (Con.Warengruppe<>0) or (Con.Artikelgruppe<>0) or (Con.Auftragsart<>0) then CYCLE;

      FOR vI # 1 loop inc(vI) while (vI<=12) do begin
        vDat # Lib_Berechnungen:LetzterTagImMonat(vI, Con.Jahr);
        if (vDat<vDatVon) or (vDat>vDatBis) then CYCLE;

        // Controlling um Echtwerte korrigieren
        vWert # FldFloat(950, 11, vI);
        vItem # CteRead(vTreeIst, _CteFirst | _CteSearchCI,0, aint(vDat->vpmonth)+'|'+aint(vDat->vpyear));
        if (vItem<>0) then
          vWert # vWert - cnvfa(vItem->spcustom);
        if (vWert<=0.0) then CYCLE;


        vX # vWert * vCONAbweich / 100.0 ;
        vY # Rnd(vX * vZ / 100.0 ,2);

        TreeAddItem( vTree, vDat, 'Con', '', '', vX + vY);
        TreeAddItem( vTreeSt, vDat, '[ST] Con', '...', '...', -vY);
      END;
    END;
  end;




  /* Steuerberechnung */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  vFS_Datum  # 0.0.0;
  vFS_Betrag # 0.0;
  FOR  vItem # Sort_ItemFirst( vTreeSt )
  LOOP vItem # Sort_ItemNext( vTreeSt, vItem )
  WHILE ( vItem != 0 ) and ( CnvDA( vItem->spCustom ) <= vDatBis ) DO BEGIN
    VarInstance( Struct_FS_Item, HdlLink( vItem ) );

    if (vFS_Datum=0.0.0) then vFS_Datum # sFS_Datum;

    if ( sFS_Datum->vpMonth = vFS_Datum->vpMonth ) and ( sFS_Datum->vpYear = vFS_Datum->vpYear ) then begin
      vFS_Betrag # vFS_Betrag + sFS_Betrag;
      VarFree( Struct_FS_Item );
      end
    else begin
      vFS_AktionZ      # '(' + cnvai( vFS_Datum->vpMonth, _FmtNumLeadZero,0,2) + '/' + aint( vFS_Datum->vpYear ) + ')';
      vFS_Datum->vmMonthModify( vDauerFrist );
      vFS_Datum->vpDay # vUstTag;
      if (vFS_Datum>=vDatVon) then
        TreeAddItem( vTree, vFS_Datum, '', '*** Umsatzsteuer ***', vFS_AktionZ, vFS_Betrag );
      VarInstance( Struct_FS_Item, HdlLink( vItem ) );
      vFS_Betrag       # sFS_Betrag;
      vFS_Datum        # sFS_Datum;
      VarFree( Struct_FS_Item );
    end;
  END;


  vFS_AktionZ      # '(' + cnvai( vFS_Datum->vpMonth, _FmtNumLeadZero,0,2) + '/' + aint( vFS_Datum->vpYear ) + ')';
  if (vFS_Datum<>0.0.0) then begin
    vFS_Datum->vmMonthModify( vDauerFrist );
    vFS_Datum->vpDay # vUstTag;
    if (vFS_Datum>=vDatVon) then
      TreeAddItem( vTree, vFS_Datum, '', '*** Umsatzsteuer ***', vFS_AktionZ, vFS_Betrag );
  end;



  /* Material */
  if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
  vSel # SelCreate( 200, 0 );
  vSel->SelDefQuery( '', '"Mat.EigenmaterialYN" and "Mat.Übernahmedatum" != 0.0.0 and "Mat.Löschmarker" = ''''' );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  FOR  Erx # RecRead( 200, vSel, _recFirst );
  LOOP Erx # RecRead( 200, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    vSumLager # vSumLager + ( Mat.Bestand.Gew * Mat.EK.Effektiv / 1000.0 );
  END;

  vSel->SelClose();
  SelDelete( 200, vSelName );




  /* Listenausgabe */
  if ( vDialog != 0 ) then begin
    $Progress->wpProgressPos # 10;
    vItem # WinSearch( vDialog, 'Label1' );
    vItem->wpCaption # Translate( 'Generiere Liste...' );
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # vTree->CteInfo( _cteCount ) + 3;
  end;

  vFS_Betrag # 0.0;
  FOR  vItem # Sort_ItemFirst( vTree )
  LOOP vItem # Sort_ItemNext( vTree, vItem )
  WHILE ( vItem != 0 ) AND ( vContinue ) DO BEGIN
    if ( vDialog != 0 ) then begin
      $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
      vContinue # vDialog->WinDialogResult() != _winIdCancel;
    end;

    VarInstance( Struct_FS_Item, HdlLink( vItem ) );
    vFS_Betrag # vFS_Betrag + sFS_Betrag;

    if ( sFS_Betrag > 0.0 ) then
      vSumIn  # vSumIn  + sFS_Betrag;
    else
      vSumOut # vSumOut - sFS_Betrag;

    if ( !vDetailed ) then
      CYCLE;

    StartLine();
    Write( 1, vItem->spCustom,       n, 0 );
    if ( sFS_Code = '' ) then begin
      List_Spacing[3] #   0.0;
      Write( 2, sFS_Aktion,          n, 0 );
      List_Spacing[3] #  37.0;
    end
    else begin
      Write( 2, sFS_Code,            n, 0 );
      Write( 3, sFS_Aktion,          n, 0 );
    end;
    Write( 4, sFS_AktionZ,           n, 0 );
    Write( 5, ANum( sFS_Betrag, 2 ), y, 0, 3.0 );
    Write( 6, ANum( vFS_Betrag, 2 ), y, 0, 3.0 );
    EndLine();
  END;

  StartLine( _LF_BOLD | _LF_OVERLINE );
  Write( 6, ANum( vFS_Betrag, 2 ),   y, 0, 3.0 );
  EndLine();

  if ( vContinue ) then begin
    // Summen
    if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
    List_Spacing[1] #   0.0;
    List_Spacing[2] #  80.0;
    List_Spacing[3] # 150.0;
    List_Spacing[4] # 250.0;

    StartLine();
    Write( 1, 'Summe Eingänge:', n, 0 );
    Write( 2, ANum( vSumIn, 2 ), y, 0, 3.0 );
    EndLine();

    StartLine();
    Write( 1, 'Summe Ausgänge:', n, 0 );
    Write( 2, ANum( vSumOut, 2 ), y, 0, 3.0 );
    EndLine();

    StartLine();
    Write( 1, 'Lagerwert vom ' + CnvAD( today ) + ':', n, 0 );
    Write( 2, ANum( vSumLager, 2 ), y, 0, 3.0 );
    Write( 3, '(netto)', n, 0 );
    EndLine();

    StartLine( _LF_UNDERLINE );
    EndLine();

    // Informationen
    if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
    List_Spacing[1] #   0.0;
    List_Spacing[2] #  35.0;
    List_Spacing[3] # 190.0;
    StartLine();
    EndLine();

    StartLine();
    Write( 1, 'Enthalten sind:', n, 0 );
    Write( 2, '- Offene Posten', n, 0 );
    EndLine();

    StartLine();
    Write( 2, '- Fixkosten ab Tagesdatum', n, 0 );
    EndLine();

    StartLine();
    Write( 2, '- zugeordnete offene Eingangsrechnungen', n, 0 );
    EndLine();

    StartLine();
    Write( 2, '- unzugeordnete Einkaufskontrolleinträge', n, 0 );
    EndLine();

    if ( vZukunft ) then begin
      StartLine();
      Write( 2, '- offene Aufträge und Bestellungen', n, 0 );
      EndLine();

      if (StrFind(Set.Module,'C',0)<>0) then begin
        StartLine();
        Write( 2, '- erwartete Gewinne laut Controlling (korrigiert auf '+anum(vCONAbweich,2)+'%) zzgl. '+anum(vCONSteuer,2)+'% USt. bei '+anum(100.0-Sel.Bis.Menge,0)+'% Inlandsgeschäften)', n, 0 );
        EndLine();
      end;

    end;

    StartLine();
    EndLine();
    List_Spacing[2] #   0.0;
    StartLine();
    Write( 1, 'Alle Beiträge verstehen sich inklusive der gültigen Umsatzsteuer.', n, 0 );
    EndLine();

    // Legende
    if ( vDialog != 0 ) then $Progress->wpProgressPos # $Progress->wpProgressPos + 1;
    List_Spacing[1] #   0.0;
    List_Spacing[2] #  15.0;
    List_Spacing[3] #  65.0;
    List_Spacing[4] #  80.0;
    List_Spacing[5] # 130.0;
    List_Spacing[6] # 145.0;
    List_Spacing[7] # 190.0;
    StartLine();
    EndLine();

    StartLine();
    Write( 1, 'OfP:',                n, 0 );
    Write( 2, 'Offener Posten',      n, 0 );
    Write( 3, 'WE:',                 n, 0 );
    Write( 4, 'Wareneingang',        n, 0 );
    Write( 5, '_Auf:',               n, 0 );
    Write( 6, 'Auftrag',             n, 0 );
    EndLine();

    StartLine();
    Write( 1, 'ERe:',                n, 0 );
    Write( 2, 'Eingangsrechnung',    n, 0 );
    Write( 3, 'EK:',                 n, 0 );
    Write( 4, 'Einkauf Divers',      n, 0 );
    Write( 5, '_Ein:',               n, 0 );
    Write( 6, 'Einkauf',             n, 0 );
    EndLine();

    StartLine();
    Write( 1, 'Fix:',                n, 0 );
    Write( 2, 'Fixkosten',           n, 0 );
    Write( 3, 'Rück:',               n, 0 );
    Write( 4, 'Einkauf Kalkulation', n, 0 );
    Write( 5, 'sonst:',              n, 0 );
    Write( 6, 'Betriebsauftrag',     n, 0 );
    EndLine();

    if ( vZukunft ) and (StrFind(Set.Module,'C',0)<>0) then begin
      StartLine();
      Write( 1, 'Con:',                n, 0 );
      Write( 2, 'Controlling-Forecast',n, 0 );
      EndLine();
    end;
  end;

  /* Listenausgabe beenden */
  if ( vDialog != 0 ) then
    vDialog->WinClose();

  Sort_KillList( vTree );
  Sort_KillList( vTreeSt );
  Sort_KillList( vTreeIST );
  ListTerm();

end;

//========================================================================
//========================================================================