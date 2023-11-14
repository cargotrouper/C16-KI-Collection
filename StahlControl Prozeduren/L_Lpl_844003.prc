@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Lpl_844003
//                    OHNE E_R_G
//  Info         Mat liegt am Lagerplatz sollte aber woanders sein
//
//
//  18.02.2008  ST  Erstellung der Prozedur
//  05.08.2008  DS  QUERY
//  25.06.2012  ST  Lpl_Main in Lpl_Data umgezogen
//  13.06.2022  AH  ERX
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
declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  // Keine Selektion
  StartList(0,'');  // Liste generieren
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort       : int;
  vSortName   : alpha;
end;
begin

 // Keine Sortierungsmöglichkeit
  // StartList...
end;

//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'MaterialKopf' : begin
      StartLine(_LF_Bold + _LF_UnderLine);
      Write(1, 'LP Inventur'      ,n , 0);
      Write(2, 'LP SC'            ,n , 0);
      Write(3, 'Material'         ,y , 0, 3.0);
      Write(4, 'Dicke'            ,y , 0, 3.0);
      Write(5, 'Breite'           ,y , 0, 3.0);
      Write(6, 'Länge'            ,y , 0, 3.0);
      Write(7, 'Gewicht'          ,y , 0, 3.0);
      Write(8, 'Bemerkung'        ,n , 0, 3.0);
      EndLine();
    end;

    'Material' : begin
      StartLine();
      Write(1, Lpl.Lagerplatz,n , 0);
      Write(2, Mat.Lagerplatz,n , 0);
      Write(3, AInt(Mat.Nummer)                 ,y , 0, 3.0);
      Write(4, ANum(Mat.Dicke,2)            ,y , 0, 3.0);
      Write(5, ANum(Mat.Breite,2)           ,y , 0, 3.0);
      Write(6, ANum("Mat.Länge",2)          ,y , 0, 3.0);
      Write(7, ANum(Mat.Bestand.Gew,0)                   ,y , 0, 3.0);
      Write(8, StrChar(95,20)                                   ,n , _LF_UnderLine);
      EndLine();
    end;

    'Lagerplatzwechsel': begin
      StartLine(_LF_Overline);
      EndLine();

      Print('leer');
    end;

    'leer' : begin
        StartLine();
        EndLine();
    end;

  end; // CASE
end;
//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift
  StartLine();
  EndLine();


  List_Spacing[  1]  #  0.0;                        // Lagerplatz INV
  List_Spacing[  2]  #  30.0;                       // Lagerplatz SC
  List_Spacing[  3]  #  List_Spacing[  2] + 25.0;   // Materialnr
  List_Spacing[  4]  #  List_Spacing[  3] + 20.0;   // Dicke
  List_Spacing[  5]  #  List_Spacing[  4] + 20.0;   // Breite
  List_Spacing[  6]  #  List_Spacing[  5] + 15.0;   // Länge
  List_Spacing[  7]  #  List_Spacing[  6] + 20.0;   // Gewicht
  List_Spacing[  8]  #  List_Spacing[  7] + 20.0;   // Bemerkung


  Print('MaterialKopf');

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
Sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  vName       : alpha;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile      : int;
  vMID        : int;
  vInvTxtBuf  : int;
  vInvTxtName : alpha;
  vI          : int;
  vLine       : alpha;
  vLpl        : alpha;
  vPrinted    : logic;
end;
begin


  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(n); // KEIN Landscape

  vPrinted # false;
  // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile = 844) then begin
      RecRead(844,0,_RecId,vMID);
      // markierter Lageplatz ist gelesen

      // Inventurdatei vorhanden?
      if (Lpl_Data:InvFileCheck(Lpl.Lagerplatz) <> 1) then begin
         vItem # gMarkList->CteRead(_CteNext,vItem); // Nächsten Lagerplatz
        CYCLE;
      end;

      // Text öffenen
      vInvTxtBuf # TextOpen(16);
      vInvTxtName # Lpl_Data:InvGetTextName(Lpl.Lagerplatz);  // Namen generieren
      Erx # TextRead(vInvTxtBuf,vInvTxtName,0);
      if (Erx <> _rOK)  then begin
        vItem # gMarkList->CteRead(_CteNext,vItem); // Nächsten Lagerplatz
        CYCLE;
      end;


      // Selektion aufbauen
      //vSelName # Sel_Build(vSel, 200, 'LST.844003',n, 0);

      vSel # SelCreate( 200, 0 );
      vSel->SelAddSortFld( 1, 16, _KeyFldAttrUpperCase);
      vSel->SelAddSortFld( 1, 23, _KeyFldAttrUpperCase);
      vSel->SelAddSortFld( 1, 30, _KeyFldAttrUpperCase);
      vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

      vSel # SelOpen();                       // Selektion öffnen
      vSel->selRead(200,_SelLock,vSelName);   // Selektion laden

      // Material aus der Inventurdatei zeilenweise in Selektion schreiben
      FOR vI # 1; loop inc(vI) while (vI<=TextInfo(vInvTxtBuf, _TextLines,0)) DO BEGIN
        vLine # TextLineRead(vInvTxtBuf,vI,0);

        if (CnvIa(vLine) = 0) then
          CYCLE;

        // Pro Zeile Material lesen
        Mat.Nummer #  CnvIa(vLine);
        Erx # RecRead(200,1,0,0,0);
        if ((Erx = _rOK) AND (Mat.Lagerplatz <> Lpl.Lagerplatz)) then
          // Material in Selektion schreiben
          SelRecInsert(vSel,200);

      END;


      // Ausgabe der Einträge
      if (vPrinted) then
        Print('Lagerplatzwechsel');

      vFlag # _RecFirst;
      WHILE (RecRead(200,vSel,vFlag) <= _rLocked ) DO BEGIN
        vPrinted # true;
        Print('leer');

        if (vFlag=_RecFirst) then
          vFlag # _RecNext;

        Print('Material');

      END;  // Material-Loop
      SelClose(vSel);             // Selektion schliessen
      SelDelete(200,vSelName);    // temp. Selektion löschen
      vSel  # 0;


    end; // Lagerplatzmarkierung
    vItem # gMarkList->CteRead(_CteNext,vItem);

  END;


  ListTerm();



end;

//========================================================================