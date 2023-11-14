@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Adr_100006
//                    OHNE E_R_G
//  Info
//        Liste: Adressen / markierte Adressen für Briefe
//
//  25.08.2011  TM  Erstellung
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    sub Element ( aName : alpha; aPrint : logic );
//    sub SeitenKopf ( aSeite : int );
//    sub SeitenFuss ( aSeite : int );
//    sub StartList ( aSort : int; aSortName : alpha );
//
//=========================================================================
@I:Def_Global
@I:Def_List2
declare StartList ( aSort : int; aSortName : alpha );

local begin
  lf_Empty  : handle;
  lf_Header : handle;
  lf_Line   : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
//  StartList(0,'');  // Liste generieren

  RecBufClear(998);
  Sel.Adr.bis.KdNr # 9999999;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.100007',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

end;

//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2 : int;
  vSort      : int;
  vSortName  : alpha;
end;
begin
  gSelected # 0;
  if (Sel.Adr.Von.KdNr =0) then begin
    vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
    vHdl2 # vHdl->WinSearch('Dl.Sort');
    vHdl2->WinLstDatLineAdd('Kundennummer');
    vHdl2->WinLstDatLineAdd('Kundenstichwort');
    vHdl2->wpcurrentint#1
    vHdl->WinDialogRun(_WindialogCenter,gMdi);
    vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
    vHdl->WinClose();
      if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
    vSort # gSelected;
    gSelected # 0;
  End else vSort # 1;

  StartList(vSort, vSortname);
end;

//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  vPrefix : alpha;
end;
begin
  case aName of
    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[1]   # 0.0;
      list_Spacing[2]   # list_Spacing[1] + 20.0;
      list_Spacing[3]   # list_Spacing[2] + 30.0;
      list_Spacing[4]   # list_Spacing[3] + 25.0;
      list_Spacing[5]   # list_Spacing[4] + 15.0;
      list_Spacing[6]   # list_Spacing[5] + 25.0;
      list_Spacing[7]   # list_Spacing[6] + 25.0;
      list_Spacing[8]   # list_Spacing[7] + 25.0;
      list_Spacing[9]   # list_Spacing[8] + 25.0;
      list_Spacing[10]  # list_Spacing[9] + 25.0;
      list_Spacing[11]  # list_Spacing[10] + 20.0;
      list_Spacing[12]  # list_Spacing[11] + 50.0;
      // Lib_List2:ConvertWidthsToSpacings( 7, 277.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Kundennr.',     n, 0 );
      LF_Set( 2, 'Stichwort',     n, 0 );
      LF_Set( 3, 'Referenznr.',   n, 0 );
      LF_Set( 4, 'Währg.',       n, 0 );
      LF_Set( 5, 'Kred.Limit',    y, 0 );
      LF_Set( 6, 'Kurzlimit',     y, 0 );
      LF_Set( 7, 'bis',           n, 0 );
      LF_Set( 8, 'Int.Limit',     y, 0 );
      LF_Set( 9, 'Int.Kurzlimit', y, 0 );
      LF_Set(10, 'bis',           n, 0 );
      LF_Set(11, 'Bemerkung',     n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin

        RETURN;
      end;

      LF_Set( 1, '@Adr.Kundennr'          ,n,0 );
      LF_Set( 2, '@Adr.Stichwort'         ,n,0 );
      LF_Set( 3, '@Adr.K.Referenznr'      ,n,0 );
      LF_Set( 4, '@Wae.Kürzel'            ,n,0 );
      LF_Set( 5, '@Adr.K.VersichertFW'    ,y,0 );
      LF_Set( 6, '@Adr.K.KurzLimitFW'     ,y,0 );
      LF_Set( 7, '@Adr.K.KurzLimit.Dat'   ,n,0 );
      LF_Set( 8, '@Adr.K.InternLimit'     ,y,0 );
      LF_Set( 9, '@Adr.K.InternKurz'      ,y,0 );
      LF_Set(10, '@Adr.K.InternKurz.Dat'  ,n,0 );
      LF_Set(11, '@Adr.K.Bemerkung'       ,n,0 );


    end;
  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  if ( !list_XML ) then begin
    WriteTitel();
    LF_Print( lf_Empty );
  end;

  LF_Print( lf_Header );
end;


//=========================================================================
// SeitenFuss
//        Seitenfuß der Liste
//=========================================================================
sub SeitenFuss ( aSeite : int );
begin
end;


//=========================================================================
// StartList
//        Listenstart
//=========================================================================
sub StartList ( aSort : int; aSortName : alpha );
local begin
  Erx     : int;
  vPrgr    : handle;
  vSel     : int;
  vSelName : alpha;
  vQ : alpha;
  vFlag : int;
  vKey : int;
end;
begin


  // Sortierung setzen
  if (aSort=1) then vKey # 2; // Kundennummer
  if (aSort=2) then vKey # 4; // Kundenstichwort


  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );



  // Selektionsquery
  vQ # '';
  if (Sel.Adr.von.KdNr != 0) then
    Lib_Sel:QVonBisI(var vQ, 'Adr.Kundennr', Sel.Adr.von.KdNr, Sel.Adr.von.KdNr);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ, 'Adr.Verband', '=', Sel.Adr.von.Verband);

  // Selektion starten...
  vSel # SelCreate(100, vKey);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  //vSelName # Sel_Build(vSel, 100, cSel,y,0); // Selektion oeffnen

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  LF_Init( true );

  vFlag # _RecFirst;
  WHILE (RecRead(100, vSel, vFlag) <= _rLocked) DO BEGIN
    vFlag # _RecNext;
    Erx # RecLink(103,100,14,0);
    If (Erx <= _rLocked) then begin
      Erx # RecLink(814,103,2,0);
    End else begin
      RecBufClear(103);
      RecBufClear(814);
    End;

    LF_Print( lf_Line );
  END;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  vSel->SelClose();
  SelDelete( 100, vSelName );

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================