@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Lpl_844005
//                    OHNE E_R_G
//  Info        gibt Materialien aus, die nicht eingescannt wurden
//
//
//  18.02.2008  ST  Erstellung der Prozedur
//  05.08.2008  DS  QUERY
//  18.06.2010  ST  Keine Darstellung von Restkarten
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
@I:Def_Aktionen

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

    'Spacing' : begin

      StartLine();

      Write(1, ANum(  List_Spacing[ 1],0) ,n , 0);
      Write(2, ANum(  List_Spacing[ 2],2)            ,y , 0);
      Write(3, ANum(  List_Spacing[ 3],2)            ,y , 0);
      Write(4, ANum(  List_Spacing[ 4],2)            ,y , 0);
      Write(5, ANum(  List_Spacing[ 5],2)            ,y , 0);
      Write(6, ANum(  List_Spacing[ 6],2)            ,y , 0);
      Write(7, ANum(  List_Spacing[ 7],0)            ,n , 0);

      EndLine();
    end;

    'MaterialKopf' : begin
      StartLine(_LF_Bold + _LF_UnderLine);
      Write(1, 'Lagerplatz'       ,n , 0);
      Write(2, 'Material'         ,y , 0, 3.0);
      Write(3, 'Dicke'            ,y , 0, 3.0);
      Write(4, 'Breite'           ,y , 0, 3.0);
      Write(5, 'Länge'            ,y , 0, 3.0);
      Write(6, 'Gewicht'          ,y , 0, 3.0);
      Write(7, 'Bemerkung'        ,n , 0);
      EndLine();
    end;

    'Material' : begin
      StartLine();
      Write(1, Mat.Lagerplatz,n , 0);
      Write(2, AInt(Mat.Nummer)                 ,y , 0, 3.0);
      Write(3, ANum(Mat.Dicke,2)            ,y , 0, 3.0);
      Write(4, ANum(Mat.Breite,2)           ,y , 0, 3.0);
      Write(5, ANum("Mat.Länge",2)          ,y , 0, 3.0);
      Write(6, ANum(Mat.Bestand.Gew,0)                   ,y , 0, 3.0);
      Write(7, StrChar(95,35)                                   ,n , _LF_UnderLine);
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


  List_Spacing[  1]  #  0.0;                        // Lagerplatz
  List_Spacing[  2]  #  List_Spacing[  1] + 25.0;   // Materialnr
  List_Spacing[  3]  #  List_Spacing[  2] + 20.0;   // Dicke
  List_Spacing[  4]  #  List_Spacing[  3] + 20.0;   // Breite
  List_Spacing[  5]  #  List_Spacing[  4] + 15.0;   // Länge
  List_Spacing[  6]  #  List_Spacing[  5] + 20.0;   // Gewicht
  List_Spacing[  7]  #  List_Spacing[  6] + 20.0;   // Bemerkung


  //print('Spacing');

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
  v200        : handle;
end;
begin

  // Selektion aufbauen
  //vKey # 19;
  //vSelName # Sel_Build(vSel, 200, 'LST.844005',n, 0);

  vSel # SelCreate( 200, 0 );
  vSel->SelAddSortFld( 2, 12, _KeyFldAttrUpperCase);
  vSel->SelAddSortFld( 1, 16, _KeyFldAttrUpperCase);
  vSel->SelAddSortFld( 1, 23, _KeyFldAttrUpperCase);
  vSel->SelAddSortFld( 1, 30, _KeyFldAttrUpperCase);
  vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

  vSel # SelOpen();                       // Selektion öffnen
  vSel->selRead(200,_SelLock,vSelName);   // Selektion laden


  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);

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


      // Alle Materialien des Lagerplatzes lesen
      Mat.Lagerplatz # Lpl.Lagerplatz;

      vFlag # 0;
      Erx # RecRead(200,19,vFlag);
      WHILE (Mat.Lagerplatz = Lpl.Lagerplatz) AND (Erx <= _rMultiKey) DO BEGIN
        vFlag # _RecNext;

        if  ("Mat.Löschmarker" <> '') OR
            (Mat.Ausgangsdatum <> 0.0.0) then begin
          Erx # RecRead(200,19,vFlag);
          CYCLE;
        end;

        // Prüfen, ob das Material in der Inventurdatei vorhanden ist
        if (TextSearch(vInvTxtBuf,1,1,_TextSearchToken, CnvAi(Mat.Nummer, _FmtNumNoGroup | _FmtNumNoZero)) = 0) then begin

          // ST 2010-06-15: Projekt 1061/425:
          // Sollte das gescannte Material auf dem Lagerplatz in einem BA eingesetzt sein,
          // dann ist dieses gelöscht, hat aber eine aktive Restkarte, dann ist das Material
          // in der Inventur korrekt erfasst worden und muss nicht auf der Liste angezeigt werden
          if (Mat.Status >= c_Status_BAGInput) AND (Mat.Status < c_Status_BAGOutput) then begin
            Erx # RecRead(200,19,vFlag);
            CYCLE;
          end;

          SelRecInsert(vSel,200);
        end;

        Erx # RecRead(200,19,vFlag);
      END;

    end; // Lagerplatzmarkierung
    vItem # gMarkList->CteRead(_CteNext,vItem);

  END;



  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(n); // KEIN Landscape

  vFlag # _RecFirst;
  WHILE (RecRead(200,vSel,vFlag) <= _rLocked ) DO BEGIN
    Print('leer');

    if (vFlag=_RecFirst) then
      vFlag # _RecNext;

    if (vLpl <> Mat.Lagerplatz) AND (vLpl <> '') then
      Print('Lagerplatzwechsel');

    Print('Material');

    vLpl # Mat.Lagerplatz;
  END;  // Adress-Loop

  ListTerm();

  SelClose(vSel);             // Selektion schliessen
  SelDelete(200,vSelName);    // temp. Selektion löschen
  vSel  # 0;

end;

//========================================================================