@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Adr_100503
//                    OHNE E_R_G
//  Info        Ansprechpartner
//
//
//  01.12.2008  PW  Erstellung der Prozedur
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vHdlWin   : int;
  vHdlLst   : int;
  vSort     : int;
  vSortName : alpha;
end;
begin
  gSelected # 0;
  vHdlWin  # WinOpen( 'Lfm.Sortierung', _winOpenDialog );
  vHdlLst # vHdlWin->WinSearch( 'Dl.Sort' );
  vHdlLst->WinLstDatLineAdd( 'Name' );
  vHdlLst->WinLstDatLineAdd( 'Stichwort' );
  vHdlLst->wpCurrentInt # 1;
  vHdlWin->WinDialogRun( _winDialogCenter, gMdi );
  vHdlLst->WinLstCellGet( vSortname, 1, _winLstDatLineCurrent );
  vHdlWin->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
  vSort     # gSelected;
  gSelected # 0;

  StartList( vSort, vSortName );
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf ( aSeite : int );
begin
  WriteTitel();
  StartLine();
  EndLine();

  List_Spacing[1] # 0.0;
  List_Spacing[2] # List_Spacing[1] + 30.0; // Name
  List_Spacing[3] # List_Spacing[2] + 30.0; // Vorname
  List_Spacing[4] # List_Spacing[3] + 45.0; // Stichwort
  List_Spacing[5] # List_Spacing[4] + 40.0; // Telefon
  List_Spacing[6] # List_Spacing[5] + 40.0; // Telefax
  List_Spacing[7] # List_Spacing[6] + 40.0; // Mobil
  List_Spacing[8] # List_Spacing[7] + 45.0; // E-Mail

  StartLine( _LF_BOLD | _LF_UNDERLINE );
  Write( 1, 'Name',      n, 0 );
  Write( 2, 'Vorname',   n, 0 );
  Write( 3, 'Stichwort', n, 0 );
  Write( 4, 'Telefon',   n, 0 );
  Write( 5, 'Telefax',   n, 0 );
  Write( 6, 'E-Mail',    n, 0 );
  Write( 7, 'Briefanrede',    n, 0 );
  EndLine();
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss ( aSeite : int );
begin
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList ( aSort : int; aSortName : alpha );
local begin
  Erx       : int;
  vTree     : int;
  vItem     : int;
  vSortKey  : alpha;
  vMFile    : int;
  vMID      : int;
end;
begin
  ListInit( y );



  vItem # gMarkList->CteRead(_CteFirst);
  if vItem =0 then begin

    vTree # CteOpen( _cteTreeCI );

    FOR  Erx # RecRead( 102, 1, _recFirst );
    LOOP Erx # RecRead( 102, 1, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( aSort = 1 ) then
        vSortKey # Adr.P.Name + '_' + Adr.P.Vorname + '_' + Adr.P.Stichwort + '_';
      else
        vSortKey # Adr.P.Stichwort + '_' + Adr.P.Name + '_' + Adr.P.Vorname + '_';
      Sort_ItemAdd( vTree, vSortKey, 102, RecInfo( 102, _recId ) );
    END;

    /* Listenausgabe */
    gFrmMain->WinFocusSet();
    FOR  vItem # Sort_ItemFirst( vTree );
    LOOP vItem # Sort_ItemNext( vTree, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );
      RecLink( 100, 102, 1, _recFirst );

      if ( Adr.P.Telefon = '' ) then
        Adr.P.Telefon # Adr.Telefon1;

      StartLine();
      Write( 1, Adr.P.Name,    n, 0 );
      Write( 2, Adr.P.Vorname, n, 0 );
      Write( 3, Adr.Stichwort, n, 0 );
      Write( 4, Adr.P.Telefon, n, 0 );
      Write( 5, Adr.P.Telefax, n, 0 );
      Write( 6, Adr.P.eMail,   n, 0 );
      Write( 7, Adr.P.BriefAnrede,   n, 0 );
      EndLine();
    END;

  end else begin
    vTree # CteOpen( _cteTreeCI );
    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 102) then begin
        RecRead(102,0,_RecId,vMID);
        //SelRecInsert(vTree,460);
        if ( aSort = 1 ) then
          vSortKey # Adr.P.Name + '_' + Adr.P.Vorname + '_' + Adr.P.Stichwort + '_';
        else
          vSortKey # Adr.P.Stichwort + '_' + Adr.P.Name + '_' + Adr.P.Vorname + '_';
        Sort_ItemAdd( vTree, vSortKey, 102, RecInfo( 102, _recId ) );
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

    /* Listenausgabe */
    gFrmMain->WinFocusSet();
    FOR  vItem # Sort_ItemFirst( vTree );
    LOOP vItem # Sort_ItemNext( vTree, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );
      RecLink( 100, 102, 1, _recFirst );

      if ( Adr.P.Telefon = '' ) then
        Adr.P.Telefon # Adr.Telefon1;

      StartLine();
      Write( 1, Adr.P.Name,    n, 0 );
      Write( 2, Adr.P.Vorname, n, 0 );
      Write( 3, Adr.Stichwort, n, 0 );
      Write( 4, Adr.P.Telefon, n, 0 );
      Write( 5, Adr.P.Telefax, n, 0 );
      Write( 6, Adr.P.eMail,   n, 0 );
      Write( 7, Adr.P.BriefAnrede,   n, 0 );
      EndLine();
    END;



  end;










  ListTerm();
End;

//========================================================================