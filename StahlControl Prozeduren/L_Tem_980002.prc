@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Tem_980002
//                  OHNE E_R_G
//  Info
//        Liste: Telfonatübnerischt
//
//  03.02.2014  ST  Erstellung der Prozedur
//  04.12.2014  ST  Erweiterung um In/Out Filter und Hitliste Kundentel.
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    sub Element ( aName : alpha; aPrint : logic );
//    sub SeitenKopf ( aSeite : int );
//    sub SeitenFuss ( aSeite : int );
//    sub StartList ( aSort : int; aSortName : alpha );
//=========================================================================
@I:Def_Global
@I:Def_List2
declare StartList ( aSort : int; aSortName : alpha );

define begin
  cSumGesamtDauer       : 1
  cSumGesamtAnzahl      : 2
  cSumUserDauer         : 3
  cSumUserAnzahl        : 4
  cSumTagDauer          : 5
  cSumTagAnzahl         : 6

  cSumProjGesamtDauer   : 10
  cSumProjGesamtAnzahl  : 20
  cSumProjUserDauer     : 30
  cSumProjUserAnzahl    : 40
  cSumProjTagDauer      : 50
  cSumProjTagAnzahl     : 60


  cSelEingehend : GV.Logic.11
  cSelAusgehend : GV.Logic.12
end

local begin
  lf_Empty        : handle;
  lf_Header       : handle;
  lf_Sel          : handle;
  lf_Line         : handle;
  lf_SumUser      : handle;
  lf_SumDay       : handle;
  lf_SumComplete  : handle;

  lf_AdrKopf      : handle;
  lf_Ans          : handle;
  lf_AdrSum       : handle;

  lf_AdrHighscoreKopfA : handle;
  lf_AdrHighscoreKopfB : handle;
  lf_AdrHighscore   : handle;

  vMode           : alpha;

  vAnkerDaten     : alpha(4096);
  vIstZuProjekt   : logic;

  vCteAdrTree     : int;
  vCteNodeKunde   : int;
  vCteNodeAns     : int;

  gHighscoreHeader  : alpha;
  gHighscoreType  : alpha;
  gHighscorePos   : int;
  gHighscoreValue : float;

end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Adr.von.Sachbear    # gUsername;

  Sel.Adr.von.KdNr        # 0;
  Sel.Von.KW              # 0;

  Sel.von.Datum           # today;
  Sel.bis.Datum           # today;

  Gv.Logic.11            # true;
  Gv.Logic.12            # true;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.980002',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

//  StartList( 0, '' );
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

  if (Sel.Adr.von.Sachbear <> '') then begin
    // WEnn nur ein User ausgewählt ist, dann immer nach Datum Sortieren
    vSort # 2;
  end else
  if (Sel.von.Datum = Sel.bis.Datum) then begin
    // WEnn nur ein Tag ausgewählt ist, dann ist Sortierung nach User
    vSort # 1;
  end
  else begin
    gSelected # 0;
    vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
    vHdl2 # vHdl->WinSearch('Dl.Sort');
    vHdl2->WinLstDatLineAdd(Translate('User'));
    vHdl2->WinLstDatLineAdd(Translate('Datum'));
    vHdl2->wpcurrentint#1;
    vHdl->WinDialogRun(_WindialogCenter,gMdi);
    vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
    vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end
    vSort # gSelected;
    gSelected # 0;
  end;

  StartList(vSort,vSortname);  // Liste generieren

end;

//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
begin
  case aName of

    'sel' : begin
      if ( aPrint ) then RETURN;

      List_Spacing[ 1] #  200.0;  // "User"
      List_Spacing[ 2] #  0.1;  //  Benutzer
      Lib_List2:ConvertWidthsToSpacings( 2 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Italic);
      LF_Set( 1, 'User: ' + Sel.Adr.von.Sachbear + ', Datumsbereich: ' + CnvAd(Sel.von.Datum) + ' bis ' + CnvAd(Sel.bis.Datum) ,n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then RETURN;

      List_Spacing[ 1] #  15.0;  // Terminnummer
      List_Spacing[ 2] #  15.0;  // User
      List_Spacing[ 3] #  20.0;  // Datum
      List_Spacing[ 4] #  15.0;  // Startzeit
      List_Spacing[ 5] #  15.0;  // Endezeit
      List_Spacing[ 6] #  22.0;  // Dauer
      List_Spacing[ 7] #  22.0;  // Projektdauer
      List_Spacing[ 8] #  15.0;  // Projekt
      List_Spacing[ 9] #  50.0;  // Adr.Stichwort
      List_Spacing[10] #  40.0;  // Ansprechpartner
      List_Spacing[11] #  40.0;  // Bemerkung
      List_Spacing[12] #   0.1;  // -- ende


      Lib_List2:ConvertWidthsToSpacings( 12 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',                 y, 0 );
      LF_Set( 2, 'User',                n, 0 );
      LF_Set( 3, 'Datum',               n, 0 );
      LF_Set( 4, 'Start',               n, 0 );
      LF_Set( 5, 'Ende',                n, 0 );
      LF_Set( 6, 'Dauer/ Min.',         y, 0 );
      LF_Set( 7, 'Projekt Dauer/Min.',  y, 0 );
      LF_Set( 8,  'Projekt',            n, 0 );
      LF_Set( 9,  'Adresse',            n, 0 );
      LF_Set( 10, 'Ansprechpartner',    n, 0 );
      LF_Set( 11, 'Bemerkung',          n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin

        if (Tem.Dauer > 0.0) then begin

          if (vIstZuProjekt) then begin
            Lf_Text(6,'');
            Lf_Text(7,ZahlF(Tem.Dauer,2));
          end else begin
            Lf_Text(6,ZahlF(Tem.Dauer,2));
            Lf_Text(7,'');
          end;
        end
        else begin
          Lf_Text(6,'');
          Lf_Text(7,'');
        end;

        if (Prj.P.nummer <> 0) then
          LF_Text(8,Aint(Prj.P.nummer) + '/' + Aint(Prj.P.position));
        else
          LF_Text(8,'');

        LF_Text(10,Adr.P.Vorname + ' '+ Adr.P.Name);
        RETURN;
      end;

      List_Spacing[ 1] #  15.0;  // Terminnummer
      List_Spacing[ 2] #  15.0;  // User
      List_Spacing[ 3] #  20.0;  // Datum
      List_Spacing[ 4] #  15.0;  // Startzeit
      List_Spacing[ 5] #  15.0;  // Endezeit
      List_Spacing[ 6] #  22.0;  // Dauer
      List_Spacing[ 7] #  22.0;  // Projektdauer
      List_Spacing[ 8] #  15.0;  // Projekt
      List_Spacing[ 9] #  50.0;  // Adr.Stichwort
      List_Spacing[10] #  40.0;  // Ansprechpartner
      List_Spacing[11] #  40.0;  // Bemerkung
      List_Spacing[12] #   0.1;  // -- ende

      Lib_List2:ConvertWidthsToSpacings( 12 ); // Spaltenbreiten konvertieren

      LF_Set( 1, '@TeM.Nummer',         y, 0 );
      LF_Set( 2, '@TeM.Anlage.User',    n, 0 );
      LF_Set( 3, '@TeM.Anlage.Datum',   n, 0 );
      LF_Set( 4, '@TeM.Start.Von.Zeit', n, 0 );
      LF_Set( 5, '@TeM.Ende.Von.Zeit',  n, 0 );
      LF_Set( 6, '#DauerNormal',        y, 0 );
      LF_Set( 7, '#DauerProjek',        y, 0 );
      LF_Set( 8, '#Projektnr',          n, 0 );
      LF_Set( 9, '@Adr.Stichwort',      n, 0 );
      LF_Set(10, '#Ansprechpartn',      n, 0 );
      LF_Set(11, '@TeM.Bezeichnung',    n, 0 );
    end;


    'sumUser' : begin
      if ( aPrint ) then begin

        Lf_Text(1,'');
        Lf_Text(2,'');
        Lf_Text(3,'');

        if (GetSum(cSumUserAnzahl) > 0.0) then
          LF_Text(1, 'Anzahl User: ' + ZahlF(GetSum(cSumUserAnzahl), 0));

        if (GetSum(cSumUserDauer) > 0.0) then
          LF_Text(2, ZahlF(GetSum(cSumUserDauer)/60.0, 2) + ' h');

        if (GetSum(cSumProjUserDauer) > 0.0) then
          LF_Text(3, ZahlF(GetSum(cSumProjUserDauer)/60.0, 2) + ' h');
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[ 1] #  80.0;  // Anzahl
      List_Spacing[ 2] #  25.0;  // Dauer
      List_Spacing[ 3] #  22.0;  // Projektdauer

      List_Spacing[ 4] # 120.0;  // Zusatzinfo 1 -> Telefonat in
      List_Spacing[ 5] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 5); // Spaltenbreiten konvertieren

      LF_Format(_LF_Overline);
      LF_Set(1, ''  ,y );
      LF_Set(2, ''  ,y , _LF_Int, 2);
      LF_Set(3, ''  ,y , _LF_NUM, 2);
    end;


    'sumDay' : begin
      if ( aPrint ) then begin

        Lf_Text(1,'');
        Lf_Text(2,'');
        Lf_Text(3,'');


        if (GetSum(cSumTagAnzahl) > 0.0) then
          LF_Text(1, 'Anzahl Tag: ' + ZahlF(GetSum(cSumTagAnzahl), 0));
        if (GetSum(cSumTagDauer) > 0.0) then
          LF_Text(2, ZahlF(GetSum(cSumTagDauer)/60.0, 2) + ' h');
        if (GetSum(cSumProjTagDauer) > 0.0) then
          LF_Text(3, ZahlF(GetSum(cSumProjTagDauer)/60.0, 2) + ' h');
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[ 1] #  80.0;  // Anzahl
      List_Spacing[ 2] #  25.0;  // Dauer
      List_Spacing[ 3] #  22.0;  // Projektdauer

      List_Spacing[ 4] # 120.0;  // Zusatzinfo 1 -> Telefonat in
      List_Spacing[ 5] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 5); // Spaltenbreiten konvertieren

      LF_Format(_LF_Overline);
      LF_Set(1, ''  ,y );
      LF_Set(2, ''  ,y , _LF_Int, 2);
      LF_Set(3, ''  ,y , _LF_NUM, 2);
    end;

    'sumComplete' : begin
      if ( aPrint ) then begin
        Lf_Text(1,'');
        Lf_Text(2,'');
        Lf_Text(3,'');



        if (GetSum(cSumGesamtAnzahl) > 0.0) then
          LF_Text(1, 'Anzahl Gesamt: ' + ZahlF(GetSum(cSumGesamtAnzahl), 0));

        if (GetSum(cSumGesamtDauer) > 0.0) then
          LF_Text(2, ZahlF(GetSum(cSumGesamtDauer)/60.0, 2) + ' h');

        if (GetSum(cSumProjGesamtDauer) > 0.0) then
          LF_Text(3, ZahlF(GetSum(cSumProjGesamtDauer)/60.0, 2) + ' h');
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[ 1] #  80.0;  // Anzahl
      List_Spacing[ 2] #  25.0;  // Dauer
      List_Spacing[ 3] #  22.0;  // Projektdauer

      List_Spacing[ 4] # 120.0;  // Zusatzinfo 1 -> Telefonat in
      List_Spacing[ 5] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 5); // Spaltenbreiten konvertieren

      LF_Format(_LF_Overline);
      LF_Set(1, ''  ,y );
      LF_Set(2, ''  ,y , _LF_Int, 2);
      LF_Set(3, ''  ,y , _LF_NUM, 2);
    end;


    // -------------------------------------------------------------------------------

    'AdrKopf' : begin
      if ( aPrint ) then RETURN;

      List_Spacing[ 1] #  50.0;  // Adr.Stichwort
      List_Spacing[ 2] #  50.0;  // Name
      List_Spacing[ 3] #  30.0;  // Anrufe
      List_Spacing[ 4] #  30.0;  // Dauer
      List_Spacing[ 5] #  50.0;  // ANzahl Projekt
      List_Spacing[ 6] #  30.0;  // Dauer / Projekt
      List_Spacing[ 7] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 7 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, '',   n, 0 );
      LF_Set( 2, '',   n, 0 );
      LF_Set( 3, 'Anzahl',            y, 0 );
      LF_Set( 4, 'Dauer/h',           y, 0 );
      LF_Set( 5, 'Anzahl Projekt',    y, 0 );
      LF_Set( 6, 'Projekt/h',         y, 0 );
    end;

    'Ans' : begin
      if ( aPrint ) then begin

        Lf_Text(1,'');
        Lf_Text(2,'');
        Lf_Text(3,'');
        Lf_Text(4,'');
        Lf_Text(5,'');
        Lf_Text(6,'');

        Lf_Text(1,  Adr.Stichwort);
        Lf_Text(2,  StrAdj(Adr.P.Titel + ' ' + Adr.P.Vorname + ' ' + Adr.P.Name,_StrBegin));

        if (GetSum(cSumUserAnzahl) > 0.0) then
          LF_Text(3,  ZahlF(GetSum(cSumUserAnzahl), 0));

        if (GetSum(cSumUserDauer) > 0.0) then
          LF_Text(4,  ZahlF(GetSum(cSumUserDauer)/60.0, 2));

        if (GetSum(cSumProjUserAnzahl) > 0.0) then
          LF_Text(5,  ZahlF(GetSum(cSumProjUserAnzahl), 0));

        if (GetSum(cSumProjUserDauer) > 0.0) then
          LF_Text(6,  ZahlF(GetSum(cSumProjUserDauer)/60.0, 2));
        RETURN;
      end;

      List_Spacing[ 1] #  50.0;  // Kundenstw
      List_Spacing[ 2] #  50.0;  // Name
      List_Spacing[ 3] #  30.0;  // Anrufe
      List_Spacing[ 4] #  30.0;  // Dauer
      List_Spacing[ 5] #  50.0;  // ANzahl Projekt
      List_Spacing[ 6] #  30.0;  // Dauer / Projekt
      List_Spacing[ 7] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 8 ); // Spaltenbreiten konvertieren

      LF_Set( 1, '',   n, 0 );
      LF_Set( 2, '',   n, 0 );
      LF_Set( 3, '',   y, 0 );
      LF_Set( 4, '',   y, 0 );
      LF_Set( 5, '',   y, 0 );
      LF_Set( 6, '',   y, 0 );
    end;

    'AdrSum' : begin
      if ( aPrint ) then begin
        Lf_Text(1,'');
        Lf_Text(2,'');
        Lf_Text(3,'');
        Lf_Text(4,'');
        Lf_Text(5,'');
        Lf_Text(6,'');

        LF_Text(1, Adr.Stichwort);
        if (GetSum(cSumGesamtAnzahl) > 0.0) then
          LF_Text(2, ZahlF(GetSum(cSumGesamtAnzahl), 0));
        if (GetSum(cSumGesamtDauer) > 0.0) then
          LF_Text(3, ZahlF(GetSum(cSumGesamtDauer)/60.0, 2));
        if (GetSum(cSumProjGesamtAnzahl) > 0.0) then
          LF_Text(4, ZahlF(GetSum(cSumProjGesamtAnzahl), 0));
        if (GetSum(cSumProjGesamtDauer) > 0.0) then
          LF_Text(5, ZahlF(GetSum(cSumProjGesamtDauer)/60.0, 2));
        RETURN;
      end;

      List_Spacing[ 1] #  100.0;  // Name
      List_Spacing[ 2] #  30.0;  // Anrufe
      List_Spacing[ 3] #  30.0;  // Dauer
      List_Spacing[ 4] #  50.0;  // ANzahl Projekt
      List_Spacing[ 5] #  30.0;  // Dauer / Projekt
      List_Spacing[ 6] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 6 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Overline | _LF_Bold );
      LF_Set( 1, '',   n, 0 );
      LF_Set( 2, '',            y, 0 );
      LF_Set( 3, '',           y, 0 );
      LF_Set( 4, '',    y, 0 );
      LF_Set( 5, '',         y, 0 );
    end;


    'AdrHighscoreKopfA' : begin
      if ( aPrint ) then RETURN;

      List_Spacing[ 1] #  100.0;  // Bezeichnung
      List_Spacing[ 2] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 2 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Bold );
      LF_Set( 1, gHighscoreHeader,  n, 0 );
    end;

    'AdrHighscoreKopfB' : begin
      if ( aPrint ) then RETURN;

      List_Spacing[ 1] #  10.0;  // Position
      List_Spacing[ 2] #  50.0; // Name
      List_Spacing[ 3] #  30.0;  // Anrufe
      List_Spacing[ 4] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 4 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Overline | _LF_Bold );
      LF_Set( 1, 'Pos',   y, 0 );
      LF_Set( 2, 'Kunde',   n, 0 );
      LF_Set( 3, gHighscoreType,   y, 0 );
    end;

    'AdrHighscore' : begin
      if ( aPrint ) then begin
        Lf_Text(1,'');
        Lf_Text(2,'');
        Lf_Text(3,'');

        LF_Text(1, Aint(gHighscorePos));
        LF_Text(2, Adr.Stichwort);
        LF_Text(3, Anum(gHighscoreValue,2));
        RETURN;
      end;

      List_Spacing[ 1] #  10.0;  // Position
      List_Spacing[ 2] #  50.0; // Name
      List_Spacing[ 3] #  30.0;  // Anrufe
      List_Spacing[ 4] #   0.1;  // -- ende
      Lib_List2:ConvertWidthsToSpacings( 4 ); // Spaltenbreiten konvertieren

      //LF_Format( _LF_Overline | _LF_Bold );
      LF_Set( 1, '',   y, 0 );
      LF_Set( 2, '',   n, 0 );
      LF_Set( 3, '',   y, 0 );
    end;

  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  WriteTitel();

  LF_Print( lf_Empty );
  LF_Print( lf_Sel );

  LF_Print( lf_Empty );

  case (vMode) of
    'EINZEL','' :  LF_Print( lf_Header );
    'KUNDE'     :  LF_Print( lf_AdrKopf );
  end;


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
  Erx         : int;
  vQ          : alpha(4000);
  vQ1         : alpha(4000);
  vProgress   : handle;
  vTree       : int;
  vSel        : int;
  vSelName    : alpha;
  vSortKey    : alpha(250);

  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;

  vChangeUser : alpha;
  vChangeDay  : date;

  vAdr        : int;
  vAnspr      : int;
  vZeitPrefix : alpha;

  vTmpItem  : int;
  vPrinted    : logic;

  vKundenCnt  : int;

  vOk         : logic;

  vKndHighscoreCnt : int;
  vTmpA : alpha;
  vTmpI : int;
end
begin
  // Druckelemente
  lf_Empty          # LF_NewLine( '' );
  lf_Header         # LF_NewLine( 'header' );
  lf_Sel            # LF_NewLine( 'sel');
  lf_Line           # LF_NewLine( 'line' );
  lf_SumUser        # LF_NewLine( 'sumUser' );
  lf_SumDay         # LF_NewLine( 'sumDay' );
  lf_SumComplete    # LF_NewLine( 'sumComplete' );
  lf_AdrKopf        # LF_NewLine( 'AdrKopf');
  lf_Ans            # LF_NewLine( 'Ans');
  lf_AdrSum         # LF_NewLine( 'AdrSum');

  lf_AdrHighscore   # LF_NewLine( 'AdrHighscore');



  // Listenanzeige
  gFrmMain->WinFocusSet();
  LF_Init( true );

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen


  // ----------------------------------------
  // Selektion und Sortierung
  vQ  # '';
  Lib_Sel:QAlpha(var vQ, '"TeM.Typ"', '=', 'TEL');
  if (Sel.Adr.von.Sachbear <> '') then
    Lib_Sel:QAlpha(var vQ, '"TeM.Anlage.User"', '=', Sel.Adr.von.Sachbear);
  Lib_Sel:QVonBisD(var vQ, '"TeM.Anlage.Datum"', "Sel.von.Datum", "Sel.bis.Datum");

  Lib_Sel:QDate(var vQ, '"TeM.Ende.Von.Datum"','<>',0.0.0);
  Lib_Sel:QInt(var vQ,  '"TeM.Dauer"', '>=', Sel.Von.KW);


  vSel # SelCreate(980, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 980, _recCount, vSel ) );

  FOR Erx # RecRead(980,vSel, _recFirst);
  LOOP Erx # RecRead(980,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(980, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (Tem.Nummer < 6922) then begin

      debug('');
    end;


    // Eingehende / Ausgehende Telefonate berückrichtigen
    if (StrLen(TeM.Bezeichnung) >= 4) then begin
      if (cSelEingehend = false) AND (StrCut(Tem.Bezeichnung,1,3) = 'In:') then
        CYCLE;

      if (cSelAusgehend = false) AND (StrCut(Tem.Bezeichnung,1,4) = 'Out:') then
        CYCLE;

    end;



    // Kundenselektion berücksichtigen
    if (Sel.Adr.von.KdNr <> 0) then begin

      vOk # false;

      FOR   Erx # RecLink(981,980,1,_RecFirst);
      LOOP  Erx # RecLink(981,980,1,_RecNext);
      WHILE Erx = _rOK DO BEGIN
        if (TeM.A.Datei = 800) then   // Interne Userangaben sind uninteressant
          CYCLE;

        if (Tem.A.Datei = 120) OR (Tem.A.Datei = 122) then begin
          Erx # Lib_Rec:ReadByKey(122,Tem.A.Key);
          CYCLE;
        end;

        // Adresse lesen (Aktion ohne Ansprechpartner)
        if (TeM.A.Datei = 100) then begin
          Erx # Lib_Rec:ReadByKey(100,Tem.A.Key);
          if (Erx <> _rOK) then
            CYCLE;

          if (Adr.KundenNr = Sel.Adr.von.KdNr) then begin
            vOk # true;
            BREAK;
          end;

        end;


        // Ansprechpartner verlinkt
        if (TeM.A.Datei = 102) then begin
          // Ansprechpartner lesen
          Erx # Lib_Rec:ReadByKey(102,Tem.A.Key);
          if (Erx <> _rOK) then
            CYCLE;

          // Adresse lesen
          RekLink(100,102,1,0);

          if (Adr.KundenNr = Sel.Adr.von.KdNr) then begin
            vOk # true;
            BREAK;
          end;

        end;

      END;

      if (vOk = false) then
        CYCLE;
    end;


    if (aSort=1) then   vSortKey # TeM.Anlage.User + ';' + Lib_Strings:TimestampFullYearMs(TeM.Anlage.Datum,TeM.Start.Von.Zeit);
    if (aSort=2) then   vSortKey # Lib_Strings:TimestampFullYearMs(TeM.Anlage.Datum,TeM.Start.Von.Zeit) +';' +TeM.Anlage.User;


    Sort_ItemAdd(vTree,vSortKey,980,RecInfo(980,_RecId));
  END;
  SelClose(vSel);
  SelDelete(980, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Reset('Druckausgabe Teil 1/3');



  // -------------------------------------------
  // 1. Struktur schaffen
  // -------------------------------------------
  //  o Root    vCteAdrTree
  //     o Kunde 1
  //        o Ansprechpartner A
  //            o Zeit 1
  //            o Zeit 2
  //        o Ansprechpartner B
  //        o Zeit 3
  //        o Zeit 4
  //     o Kunde 2
  //        o Ansprechpartner C
  //        o Ansprechpartner D

  vCteAdrTree   # CteOpen(_CteNode, _CteChildTree);

  vMode # 'EINZEL';

  // ----------------------------------------
  // Ausgabe Einzelauflistung
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) DO BEGIN
    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    // -------------------------------------------
    // Je nach Sortierung den Gruppenwechsel steuern
    if (aSort = 1) then begin
      if (vChangeUser <> TeM.Anlage.User) AND (vChangeUser <> '') then begin
        LF_Print( lf_sumUser);
        LF_Print( lf_Empty );
        ResetSum(cSumUserDauer);
        ResetSum(cSumUserAnzahl);
        ResetSum(cSumProjUserDauer);
        ResetSum(cSumProjUserAnzahl);
      end;
    end;

    if (aSort = 2) then begin
      if (vChangeDay <> TeM.Anlage.Datum) AND (vChangeDay <> 0.0.0)  then begin
        LF_Print(lf_sumDay);
        LF_Print( lf_Empty );
        ResetSum(cSumTagDauer);
        ResetSum(cSumTagAnzahl);
        ResetSum(cSumProjTagDauer );
        ResetSum(cSumProjTagAnzahl);
      end;
    end;

    // -------------------------------------------
    // Ankerdaten auswerten
    vIstZuProjekt  # false;
    vZeitPrefix    # '';
    vAnkerDaten    # '';

    RecBufClear(100);
    RecBufClear(102);
    RecBufClear(120);
    RecBufClear(122);

    FOR   Erx # RecLink(981,980,1,_RecFirst);
    LOOP  Erx # RecLink(981,980,1,_RecNext);
    WHILE Erx = _rOK DO BEGIN

      if (TeM.A.Datei = 800) then   // Interne Userangaben sind uninteressant
        CYCLE;

      if (Tem.A.Datei = 120) OR (Tem.A.Datei = 122) then begin
        vIstZuProjekt   # true;
        vZeitPrefix     # 'P';
        Erx # Lib_Rec:ReadByKey(122,Tem.A.Key);
        CYCLE;
      end;

      // Adresse lesen (Aktion ohne Ansprechpartner)
      if (TeM.A.Datei = 100) then begin
        Erx # Lib_Rec:ReadByKey(100,Tem.A.Key);
        if (Erx <> _rOK) then
          CYCLE;
      end;


      // Ansprechpartner verlinkt
      if (TeM.A.Datei = 102) then begin
        // Ansprechpartner lesen
        Erx # Lib_Rec:ReadByKey(102,Tem.A.Key);
        if (Erx <> _rOK) then
          CYCLE;

        // Adresse lesen
        RekLink(100,102,1,0);

        // Dauer in Struktur updaten oder erstellen
        if (vAnkerDaten <> '') then
          vAnkerDaten # vAnkerDaten + ', ';
        vAnkerDaten # vAnkerDaten + Adr.Stichwort + ' ' + Adr.P.Vorname + ' '+ Adr.P.Name;
      end;


    END;



    // -------------------------------------------
    // Summierung
    if (vIstZuProjekt) then begin
      // Projektzeiten werden gesondert Summiert
      AddSum(cSumProjUserAnzahl,    cnvfi(1));
      AddSum(cSumProjUserDauer,     TeM.Dauer);

      AddSum(cSumProjTagAnzahl,     cnvfi(1));
      AddSum(cSumProjTagDauer,      TeM.Dauer);

      AddSum(cSumProjGesamtAnzahl,  cnvfi(1));
      AddSum(cSumProjGesamtDauer,   TeM.Dauer);

    end else begin
      // Reguläre Zeit
      AddSum(cSumUserAnzahl,    cnvfi(1));
      AddSum(cSumUserDauer,     TeM.Dauer);

      AddSum(cSumTagAnzahl,     cnvfi(1));
      AddSum(cSumTagDauer,      TeM.Dauer);

      AddSum(cSumGesamtAnzahl,  cnvfi(1));
      AddSum(cSumGesamtDauer,   TeM.Dauer);
    end;


    // Zeit hinterlegen für Kundenauswertung hinterlegen
    if (Adr.Nummer <> 0) then begin

      // Adresse lesen oder erstellen
      vCteNodeKunde # vCteAdrTree->CteRead(_CteFirst | _CteSearch,Adr.Nummer,Adr.Stichwort);
      if (vCteNodeKunde <= 0) then begin
        vCteNodeKunde # vCteAdrTree->CteInsertItem(Adr.Stichwort,Adr.Nummer,Aint(Adr.Nummer));
        inc(vKundenCnt);
      end;
      // Zeit an Kunden hinterlegen
      vCteNodeKunde->CteInsertItem(Aint(Tem.Nummer),Tem.Nummer,vZeitPrefix  +ANum(Tem.Dauer,2));


      if (Adr.P.Adressnr <> 0) then begin
        // Ansprechpartner lesenoder erstellen
        vCteNodeAns # vCteNodeKunde->CteRead(_CteFirst | _CteSearch,0,'ANS/'+Aint(Adr.Nummer) + '/' + Aint(Adr.P.Nummer));
        if (vCteNodeAns <= 0) then begin
          vCteNodeAns # vCteNodeKunde->CteInsertItem('ANS/'+Aint(Adr.Nummer) + '/' + Aint(Adr.P.Nummer),Adr.Nummer * 10000000 + Adr.P.Nummer,Aint(Adr.P.Nummer));
        end;
        vCteNodeAns->CteInsertItem(Aint(Tem.Nummer),Tem.Nummer,vZeitPrefix  +ANum(Tem.Dauer,2));
      end;

    end;


    // Ausgabe
    LF_Print( lf_Line );
    vChangeUser   # TeM.Anlage.User;
    vChangeDay    # TeM.Anlage.Datum;
  END;
  if (aSort = 1) then
    LF_Print(lf_sumUser);

  if (aSort = 2) then
    LF_Print(lf_sumDay);

  LF_Print( lf_Empty );
  LF_Print( lf_sumComplete );
  vMode # 'KUNDE';


  vProgress->Lib_Progress:Reset('Druckausgabe Teil 2/3', vKundenCnt);

  LF_Print( lf_Empty );
  LF_Print( lf_Empty );

  // ------------------------------------------------------------------------------------------------------------------
  // Ausgabe Kundenstatistik

  vKndHighscoreCnt #  CteOpen(_CteTreeCI);    // Rambaum anlegen


  FOR  vCteNodeKunde # vCteAdrTree->CteRead(_CteFirst);
  LOOP vCteNodeKunde # vCteAdrTree->CteRead(_CteNext, vCteNodeKunde);
  WHILE (vCteNodeKunde <> 0) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      vCteAdrTree->CteClose();
      Sort_KillList(vTree); // Löschen der Liste
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Kundeneintrag gelesen
    if (vPrinted = false) then begin
      LF_Print( lf_AdrKopf );
      vPrinted  # true;
    end;


    // Kundenkinder lesen
    ResetSum(cSumGesamtDauer);
    ResetSum(cSumGesamtAnzahl);
    ResetSum(cSumProjGesamtDauer);
    ResetSum(cSumProjGesamtAnzahl);

    ResetSum(cSumUserDauer);
    ResetSum(cSumUserAnzahl);
    ResetSum(cSumProjUserDauer);
    ResetSum(cSumProjUserAnzahl);


    Adr.Nummer # CnvIA(vCteNodeKunde->spCustom);
    RecRead(100,1,0);


    // Kundenelemente Loopen (können Andprechpartner oder Zeiten sein
    FOR  vTmpItem # vCteNodeKunde->CteRead(_CteFirst);
    LOOP vTmpItem # vCteNodeKunde->CteRead(_CteNext, vTmpItem);
    WHILE (vTmpItem <> 0) DO BEGIN
      // Ansprechpartnernode gefunden, dann Zeiten Summieren

      if (StrFind(vTmpItem->spName,'ANS/',1) > 0) then begin

        // Ansprechpartnernode gefunden, dann Zeiten Summieren
        ResetSum(cSumUserDauer);
        ResetSum(cSumUserAnzahl);
        ResetSum(cSumProjUserDauer);
        ResetSum(cSumProjUserAnzahl);

        FOR  vCteNodeAns # vTmpItem->CteRead(_CteFirst);
        LOOP vCteNodeAns # vTmpItem->CteRead(_CteNext, vCteNodeAns);
        WHILE (vCteNodeAns <> 0) DO BEGIN

          // Ist Projektzeit?
          if (Strfind(vCteNodeAns->spCustom,'P',1) > 0) then begin
            vCteNodeAns->spCustom # Lib_Strings:Strings_ReplaceAll(vCteNodeAns->spCustom, 'P','');
            AddSum(cSumProjUserDauer, CnvFa(vCteNodeAns->spCustom));
            AddSum(cSumProjUserAnzahl, CnvFi(1));
          end else begin
            AddSum(cSumUserDauer, CnvFa(vCteNodeAns->spCustom));
            AddSum(cSumUserAnzahl, CnvFi(1));
          end;

        END;

        // Ansprechpartner ausgeben
        Adr.P.Adressnr  # CnvIa(Str_Token(vTmpItem->spName,'/',2));
        Adr.P.Nummer    # CnvIa(Str_Token(vTmpItem->spName,'/',3));
        RecRead(102,1,0);

        LF_Print( lf_Ans );

      end else begin

        // Kundensumme
        // Ist Projektzeit?
        if (Strfind(vTmpItem->spCustom,'P',1) > 0) then begin
          vTmpItem->spCustom # Lib_Strings:Strings_ReplaceAll(vTmpItem->spCustom, 'P','');
          AddSum(cSumProjGesamtDauer, CnvFa(vTmpItem->spCustom));
          AddSum(cSumProjGesamtAnzahl, CnvFi(1));
        end else begin
          AddSum(cSumGesamtDauer, CnvFa(vTmpItem->spCustom));
          AddSum(cSumGesamtAnzahl, CnvFi(1));
        end;

      end;

      // Nächster Kundeneintrag
    END;



    vSortKey #  ANum(10000000.0 - (GetSum(cSumGesamtAnzahl) + GetSum(cSumProjGesamtAnzahl)) ,0);
    Sort_ItemAdd(vKndHighscoreCnt,vSortKey ,100, Adr.Nummer);


/*
        LF_Text(1, Adr.Stichwort);
        if (GetSum(cSumGesamtAnzahl) > 0.0) then
          LF_Text(2, ZahlF(GetSum(cSumGesamtAnzahl), 0));
        if (GetSum(cSumGesamtDauer) > 0.0) then
          LF_Text(3, ZahlF(GetSum(cSumGesamtDauer)/60.0, 2));
        if (GetSum(cSumProjGesamtAnzahl) > 0.0) then
          LF_Text(4, ZahlF(GetSum(cSumProjGesamtAnzahl), 0));
        if (GetSum(cSumProjGesamtDauer) > 0.0) then
          LF_Text(5, ZahlF(GetSum(cSumProjGesamtDauer)/60.0, 2));

*/

    LF_Print( lf_AdrSum );
    LF_Print( lf_Empty );

    // Nächster Kunde
  END;

  vCteAdrTree->CteClose();

  LF_Print( lf_Empty );
  LF_Print( lf_Empty );

  vProgress->Lib_Progress:Reset('Druckausgabe Teil 3/3', CteInfo(vKndHighscoreCnt,_CteCount));

  // ------------------------------------------------------------------------------------------------------------------
  // Ausgabe Highscore
  gHighscoreHeader # 'Hitliste - Anzahl Anrufe mit und ohne Projekt ';
  lf_AdrHighscoreKopfA # LF_NewLine( 'AdrHighscoreKopfA' );
  LF_Print( lf_AdrHighscoreKopfA);
  LF_Print( lf_Empty );

  gHighscoreType  # 'Anzahl';
  gHighscorePos   # 0;
  gHighscoreValue # 0.0;
  lf_AdrHighscoreKopfB # LF_NewLine( 'AdrHighscoreKopfB' );

  LF_Print( lf_AdrHighscoreKopfB );
  FOR   vItem # Sort_ItemFirst(vKndHighscoreCnt) // RAMBAUM
  loop  vItem # Sort_ItemNext(vKndHighscoreCnt,vItem)
  WHILE (vItem != 0) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then
      BREAK;


    vTmpA # StrCut(vItem->spName,1,StrLen(vItem->spName)-8);
    gHighscoreValue # 10000000.0 - CnvFa(vTmpA);
    if (gHighscoreValue = 0.0)  then
      CYCLE;

    // Kunden holen
    Adr.Nummer # vItem->spID;
    RecRead(100,1,0);

    inc(gHighscorePos);

    LF_Print( lf_AdrHighscore );
  END;
  Sort_KillList(vKndHighscoreCnt); // Löschen der Liste





  /* Cleanup */
  Sort_KillList(vTree); // Löschen der Liste
  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel);
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_SumUser);
  LF_FreeLine( lf_SumDay);
  LF_FreeLine( lf_SumComplete);

  LF_FreeLine( lf_AdrKopf  );
  LF_FreeLine( lf_Ans      );
  LF_FreeLine( lf_AdrSum   );
  LF_FreeLine(lf_AdrHighscoreKopfA );
  LF_FreeLine(lf_AdrHighscoreKopfB );
  LF_FreeLine(lf_AdrHighscore  );

end;

//=========================================================================
//=========================================================================