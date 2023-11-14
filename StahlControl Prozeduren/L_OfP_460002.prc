@A+
//===== Business-Control =================================================
//
//  Prozedur    L_OfP_460002
//                        OHNE E_R_G
//  Info        Factoring OffenePosten
//
//
//  29.11.2007  MS  Erstellung der Prozedur
//  23.07.2008  DS  QUERY
//  01.06.2017  TM  Anpassungen gem. Prj 1326/532
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

define begin
  cSel : 'LST.460002'
end;


declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  //StartList(0,'');  // Liste generieren
  RecBufClear(999);
  Sel.Adr.bis.KdNr     # 9999999;
  Sel.Adr.von.KdNr     # 0;
  Sel.Fin.von.Rechnung # 0;
  Sel.Fin.bis.Rechnung # 9999999;
  Sel.Adr.von.Verband  # 0;
  Sel.bis.Datum        # today;
  Sel.von.Datum        # 0.0.0;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.460002',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort : int;
  vSortName : alpha;
end;
begin

  gSelected # 0;
  /**
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Auftragsnummer');
  vHdl2->WinLstDatLineAdd('Kundenstichwort');
  vHdl2->WinLstDatLineAdd('Wunschtermin');
  vHdl2->WinLstDatLineAdd('Zusagetermin');
  vHdl2->wpcurrentint#1
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
  gSelected # 0;
  **/
  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aName : alpha);
local begin
  Erx : int;
end;
begin

  case aName of

    '460' : begin
      StartLine();
      Write(1,  ''                                                       ,n , 0);
      Write(2,  ZahlI(OfP.Kundennummer)                       ,y , _LF_Int, 3.0);
      Write(3,  OfP.KundenStichwort                                      ,n , 0);
      if (OfP.Netto < 0.0) then
        Write(4,  'DG'                                                   ,n , 0);
      else
        Write(4,  'DR'                                                   ,n , 0);

      Write(5,  ZahlI(OfP.Rechnungsnr)                             ,y , _LF_Int,3.0);
      if (OfP.Rechnungsdatum <> 0.0.0) then
        Write(6,  DatS(OfP.Rechnungsdatum)                        ,n , _LF_Date);

      if (OfP.Zieldatum <> 0.0.0) then
        Write(7,  DatS(OfP.Zieldatum)                             ,n , _LF_Date);

      Write(8,  ZahlF(OfP.RestW1, 2)                           ,y , _LF_Num, 3.0);
      Erx # RecLink(814,460,7,0);     // Waehrung holen
      if (Erx<=_rLocked) then
        if(Wae.Bezeichnung = 'Euro') then
          Write(9, 'EUR'    ,n , 0);
        else
          Write(9, Wae.Bezeichnung                                     ,n , 0);

      Write(10, ''                                                      ,n , 0);
      Endline();

    end // 460
  end; // case
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
  WriteTitel();     // Drucke grosse Überschrift

  StartLine();
  EndLine();

  if (aSeite=1) then begin

    List_Spacing[ 1] #  0.0;
    List_Spacing[ 2] # List_Spacing[ 1] + 0.0;
    List_Spacing[ 3] # List_Spacing[ 2] + 25.0;
    List_Spacing[ 4] # List_Spacing[ 3] + 45.0;
    List_Spacing[ 5] # List_Spacing[ 4] + 18.0;
    List_Spacing[ 6] # List_Spacing[ 5] + 20.0;
    List_Spacing[ 7] # List_Spacing[ 6] + 20.0;
    List_Spacing[ 8] # List_Spacing[ 7] + 20.0;
    List_Spacing[ 9] # List_Spacing[ 8] + 20.0;
    List_Spacing[10] # List_Spacing[ 9] + 35.0;
    List_Spacing[11] # List_Spacing[10] + 20.0;
    List_Spacing[12] # List_Spacing[11] + 35.0;
    List_Spacing[13] # List_Spacing[12] + 20.0;
    List_Spacing[14] # List_Spacing[13] + 20.0;
    List_Spacing[15] # List_Spacing[14] + 20.0;


    StartLine(_LF_UnderLine + _LF_Bold);
    Write(1,  ''            ,n , 0);
    Write(2,  'Kunden-Nr.'  ,y , 0, 3.0);
    Write(3,  'Stichwort'   ,n , 0);
    Write(4,  'Belegart'    ,n , 0);
    Write(5,  'Nummer'      ,y , 0,3.0);
    Write(6,  'Datum'       ,n , 0);
    Write(7,  'Fälligkeit'  ,n , 0);
    Write(8,  'Betrag'      ,y , 0, 3.0);
    Write(9,  'Währung'     ,n , 0);

    Endline();

  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
local begin
  vSelName  : alpha;
  vSel      : int;
  vFlag     : int;
  vQ        : alpha(4000);
  tErx      : int;
end;
begin

  // Selektionsquery
  vQ # '';
  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ, 'OfP.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if ( Sel.Fin.von.Rechnung != 0) or  ( Sel.Fin.bis.Rechnung != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'OfP.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung );
  if ( Sel.Adr.von.KdNr != 0) or  ( Sel.Adr.bis.KdNr != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'OfP.Kundennummer', Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr );
  if ( Sel.Adr.von.Verband != 0 ) then
    Lib_Sel:QInt( var vQ, 'OfP.Verband', '=', Sel.Adr.von.Verband );
    //Lib_Sel:QgleichI( var vQ, 'OfP.Verband', Sel.Adr.von.Verband );
  Lib_Sel:QAlpha( var vQ, '"OfP.Löschmarker"', '!=','*' );

  // Selektion starten...
  vSel # SelCreate( 460, 1 );
  tErx # vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 460, cSel,y,0); // Selektion oeffnen

  //RecRead(460,1,_RecFirst);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // ListInit(y);    // starte Landscape
  ListInit(n);    // starte Portrait
  vFlag # _RecFirst;
  WHILE (RecRead(460,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Print('460');

  END;

  ListTerm(); // Ende der Liste

  // Selektion loeschen
  SelClose(vSel);
  SelDelete(460, vSelName);
  vSel # 0;

end;

//========================================================================
