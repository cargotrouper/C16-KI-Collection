@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_BAG_Coilbereit
//                    OHNE E_R_G
//  Info
//    Gibt eine
//
//
//  16.05.2008  ST  Erstellung der Prozedur
//  03.08.2012  ST  Erwelteru
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  24.10.2014  TM  Sortierung umgestellt von BA Nummer auf Startzeitpunkt
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB PrintFertigung1(aTyp : alpha);
//    SUB PrintFertigung2(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin

  cLH       : 4.3   // Höhe einer vertikalen Linie (quasi Zeilenhöhe)

  cPosFuss1 : 10.0
  cPosFuss2 : 35.0

  cPosKopf1 : 2.0
  cPosKopf2 : cPosKopf1 + 50.0
  cPosKopf3 : 280.0

  cPos0   : 2.0           //
  cPos1   : cPos0 + 25.0  // Betriebsauftrag
  cPos2   : cPos1 +  3.0  // BA Barcode
  cPos3   : cPos2 + 37.0  // Prodzeit
  cPos4   : cPos3 + 15.0  // Coilnummer
  cPos5   : cPos4 + 25.0  // Quali
  cPos6   : cPos5 + 30.0  // Abmessung
  cPos7   : cPos6 + 40.0  // Lieferant/Kunde
  cPos8   : cPos7 + 40.0  // Lagerplatz
  cPos9   : cPos8 + 30.0  // Einsatz
  cPos10  : cPos9 - 10.0  // Eiunsatz Barcode
  cPos11  : cPos2 + 0.0   // Bemerkung

  cPos12  : 280.0         // Rechtes Ende der Liste

  cPosFP   : 2.0          //Pos
  cPosF0   : 10.0         //
end;

local begin
  vZeilenZahl     : int;
  vCoord          : float;
end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # 'D';

  RETURN CnvAI(BAG.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;

//========================================================================
//  Print(aTyp : alpha)
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vText : alpha;

end;
begin

  case aTyp of
    'Coil' : begin
      PL_PrintLine;

      pls_FontSize  # 9;

      // BA Nummer
      vText # StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                    StrAdj(CnvAi(BAG.P.Position,_FmtNumNoZero | _FmtNumNoGroup,0,2),_StrAll);
      Pl_Print_R(vText,cPos1);



      // BA Nummer als Barcode
      vText # 'Code39N'+vText;
      lib_PrintLine:BarCode_C39(vText,cPos2,35.0,7.0);

      // Produktionszeit
      Pl_Print(CnvAT(BAG.P.Plan.StartZeit),cPos3);

      // Coilnummer
      Pl_Print( Mat.Coilnummer,cPos4);


      // Qualität
      Pl_Print("Mat.Güte",cPos5);

      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke)  + ' x '  +
              ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");
      Pl_Print(vText,cPos6);

      // Lieferant
      Pl_Print(Adr.Stichwort,cPos7);

      // Lagerplatz
      Pl_Print(Mat.Lagerplatz,cPos8);


      // Einsatz

      // Materialnummer
      Pl_PrintI(Mat.Nummer,cPos9);


      PL_PrintLine;
      PL_PrintLine;
      vText # 'EID-'+ StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                      StrAdj(CnvAi(BAG.IO.ID,   _FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll);
      Pl_Print(vText,cPos9);

      PL_PrintLine;

      PL_PrintLine;
      Pl_Print('Bemerkung:',cPos0);

      pls_FontSize  # 0;
      // MateriaLnummer als Barcodes
      // vText # 'Code39N'+StrAdj(CnvAi(Mat.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll);

      // Bag Nummer und Graph-Kante als Barcode
      vText # 'Code39N'+  StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                          StrAdj(CnvAi(BAG.IO.ID,   _FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll);

      lib_PrintLine:BarCode_C39(vText,cPos10,35.0,7.0);
      PL_PrintLine;


      PL_PrintLine;
      pls_FontSize  # 9;
      // Bemerkung
      //Pl_Print('Bermerkung: ',cPos11);
      PL_Drawbox(cPosFP, cPos12,_WinColblack, 0.25);

      PL_PrintLine;

    end; // Case 'COIL'




    'Theo' : begin
      PL_PrintLine;

      pls_FontSize  # 9;

      // BA Nummer
      vText # StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                    StrAdj(CnvAi(BAG.P.Position,_FmtNumNoZero | _FmtNumNoGroup,0,2),_StrAll);
      Pl_Print_R(vText,cPos1);


      // BA Nummer als Barcode
      vText # 'Code39N'+vText;
      lib_PrintLine:BarCode_C39(vText,cPos2,35.0,7.0);

      // Produktionszeit
      Pl_Print(CnvAT(BAG.P.Plan.StartZeit),cPos3);

      // Coilnummer
      Pl_Print( 'theoretisch',cPos4);
      // Pl_Print( Mat.Coilnummer,cPos4); // gibts bei Theo Material nicht

      // Qualität
      Pl_Print("BAG.IO.Güte",cPos5);

      // Abmessung
      vText # ANum(BAG.IO.Dicke,Set.Stellen.Dicke)  + ' x '  +
              ANum(BAG.IO.Breite,Set.Stellen.Breite);
      if ("BAG.IO.Länge" <> 0.0) then
        vText # vText + ' x ' + ANum("BAG.IO.Länge","Set.Stellen.Länge");
      Pl_Print(vText,cPos6);

      // Lieferant
      Pl_Print(Adr.Stichwort,cPos7);

      // Lagerplatz
      // Pl_Print(Mat.Lagerplatz,cPos8);  // gibts bei Theo Material nicht

      // Materialnummer
      //Pl_PrintI(Mat.Nummer,cPos9);     // gibts bei Theo Material nicht

      PL_PrintLine;
      PL_PrintLine;
      vText # 'EID-'+ StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                      StrAdj(CnvAi(BAG.IO.ID,   _FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll);
      Pl_Print(vText,cPos9);

      PL_PrintLine;

      PL_PrintLine;
      Pl_Print('Bemerkung:',cPos0);

      pls_FontSize  # 0;
      // Bag Nummer und Graph-Kante als Barcode
      vText # 'Code39N'+  StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                          StrAdj(CnvAi(BAG.IO.ID,   _FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll);
      lib_PrintLine:BarCode_C39(vText,cPos10,35.0,7.0);
      PL_PrintLine;


      PL_PrintLine;
      pls_FontSize  # 9;
      // Bemerkung
      //Pl_Print('Bermerkung: ',cPos11);
      PL_Drawbox(cPosFP, cPos12,_WinColblack, 0.25);

      PL_PrintLine;

    end; // Case 'Einsatz'

  end;      // Case


end;  // Sub


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vTxtName  : alpha;
  vText     : alpha(250);
  vText2    : alpha(250);
end;
begin

  Pls_fontSize # 10;
  pls_Fontattr # _WinFontAttrBold;

  PL_PrintLine;
  PL_PrintLine;

  // Resource aus Selektion lesen
  Pls_FontSize # 14 ;
  PL_Print('Coilbereitstellung ',cPosKopf1);
  PL_PrintLine;

  Pls_FontSize # 9;
  PL_Print  ('Produktionstag:',cPosKopf1);
  PL_Print  (CnvAD(Sel.Von.Datum),cPosKopf2);
  PL_Print_R('Seite:'+AInt(aSeite),cPosKopf3);
  PL_PrintLine;
  PL_Print  ('Resource:',cPosKopf1);
  PL_Print  (StrAdj(Rso.Stichwort,_StrAll),cPosKopf2);
  PL_PrintLine;
  Pls_FontSize # 0;

  PL_PrintLine;
  PL_PrintLine;

  PL_Print_R('Betriebsauftrag', cPos1);
  // PL_Print('BA Barcode',        cPos2);  kein BA Barcode mehr, steht schon in dem Einsatzbarcode
  PL_Print('Prodzeit',          cPos3);
  PL_Print('Coilnummer',        cPos4);
  PL_Print('Güte',              cPos5);
  PL_Print('Abmessung',         cPos6);
  PL_Print('Lieferant',         cPos7);
  PL_Print('Lagerplatz',        cPos8);
  PL_Print_R('Einsatz',         cPos9+1.0);
  PL_PrintLine;
  PL_Drawbox(cPosFP, cPos12,_WinColblack, 0.5);
  PL_PrintLine;
  pls_Inverted  # n;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vFirst              : logic;
  vText               : alpha(250);

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vTxtHdl             : int;
  vVpg                : logic[100]; // Merker für Verpackungen
  i                   : int;        // für FOR-Schleife

  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vFlag2      : int;        // Datensatzlese option
  vSelName    : alpha;
  vQ          : alpha(4000);
  vSortkey : alpha(4000);
  vTree : int;
  vItem : int;
end;
begin

  RecBufClear(100);
  RecBufClear(200);
  RecBufClear(701);
  RecBufClear(702);

// ------ Druck vorbereiten ----------------------------------------------------------------

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,n,n,y) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;



  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  Form_DokSprache # 'D';
  Form_DokName    # GetDokName(var Form_DokSprache, var Form_DokAdr);
  form_RandOben   # 0.0;      // Rand oben setzen

  Lib_Print:Print_Seitenkopf();

  // ehemals Selektion 702 LST.702003
  vQ # '';
  Lib_Sel:QDate( var vQ, 'BAG.P.Plan.StartDat', '=', Sel.von.Datum);
  if (Sel.BAG.Res.Gruppe != 0) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe);
  if (Sel.BAG.Res.Nummer != 0) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 702, 1 );
  Erx # vSel->SelDefQuery( '', vQ );

  // vSelName # Lib_Sel:SaveRun( var vSel, 0 ); // umgestellt auf Startpunkt = Startdatum + -zeit
  vSelName # Lib_Sel:SaveRun( var vSel, 1 );




  // RAMBaum für Sortierung verwenden!
  vFlag # _RecFirst;
  vFlag2 # _RecFirst;
  WHILE (RecRead(702,vSel,vFlag) <= _rLocked) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if (BAG.P.Reihenfolge =0) then BAG.P.Reihenfolge # 65535;
    vSortkey # cnvai(BAG.P.Reihenfolge,_FmtNumNoGroup|_FmtNumLeadZero,0,5) + '|'
             + cnvai(cnvid(BAG.P.Plan.StartDat),_FmtNumNoGroup|_FmtNumLeadZero,0,8) +'|' +  cnvai(cnvit(BAG.P.Plan.StartZeit),_FmtNumNoGroup|_FmtNumLeadZero,0,8)
             + cnvai(BAG.P.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8) + '|'+cnvai(BAG.P.Position,_FmtNumNoGroup|_FmtNumLeadZero,0,5);

    Sort_ItemAdd(vTree,vSortKey,702,RecInfo(702,_RecId));
  END;

  SelClose(vSel);
  SelDelete(702, vSelName);
  vSel # 0;
  debug('');




  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Echte Einsätze für die gefunden Ba Position ausgeben
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    FOR   Erx # RecLink(701,702,2,_recFirst)
    loop  Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx <= _rLocked) do begin

      if (Bag.IO.Materialtyp = c_IO_Mat) then begin

        // Material lesen
        if (RecLink(200,701,9,0) > _rLocked) then
          CYCLE;  // Material nicht gefunden

        // Lieferant lesen
        if (RecLink(100,200,4,0) > _rLocked) then
          RecBufClear(100);

        Print('Coil');    // Echtes Material ausgeben

      end
      else if(Bag.IO.Materialtyp = c_IO_Theo) then
        Print('Theo');    // Theo Material und Weiterverarbeitungen ausgeben

    END;


  END;

  Sort_KillList(vTree);


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================