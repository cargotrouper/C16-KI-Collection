@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Lpl_844004
//                    OHNE E_R_G
//  Info        zeigt Einträge aus der Inventurliste, die nicht gefunden
//              werden konnten
//
//
//  18.02.2008  ST  Erstellung der Prozedur
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
Sub Print(aName : alpha; opt aMat : alpha);
begin

  case aName of

    'MaterialKopf' : begin
      StartLine(_LF_Bold + _LF_UnderLine);
      Write(1, 'LP Inventur'      ,n , 0);
      Write(2, 'Material'         ,y , 0,3.0);
      Write(3, 'Bemerkung'        ,n , 0);
      EndLine();
    end;

    'Material' : begin
      StartLine();
      Write(1, Lpl.Lagerplatz       ,n , 0);
      Write(2, aMat           ,y , 0, 3.0);
      Write(3, StrChar(95,50) ,n , _LF_UnderLine);
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
  List_Spacing[  2]  #  30.0;                       // Material im Scanner
  List_Spacing[  3]  #  List_Spacing[  2] + 20.0;   // Bemerkung


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



      // Ausgabe der Einträge
      if (vPrinted) then
        Print('Lagerplatzwechsel');

      // Material aus der Inventurdatei zeilenweise in Selektion schreiben
      FOR vI # 1; loop inc(vI) while (vI<=TextInfo(vInvTxtBuf, _TextLines,0)) DO BEGIN
        vLine # TextLineRead(vInvTxtBuf,vI,0);

        if (CnvIa(vLine) = 0) then
          CYCLE;

        // Pro Zeile Material lesen
        Mat.Nummer #  CnvIa(vLine);
        Erx # RecRead(200,1,0,0,0);
        if (Erx <> _rOK) then begin
          vPrinted # true;
          Print('leer');
          Print('Material',vLine);
        end;

      END;


    end; // Lagerplatzmarkierung
    vItem # gMarkList->CteRead(_CteNext,vItem);

  END;


  ListTerm();



end;

//========================================================================