@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400006
//                    OHNE E_R_G
//  Info        Sägeliste
//
//
//  24.02.2006  AI  Erstellung der Prozedur
//  31.07.2008  DS  QUERY
//  13.06.2022  AH  ERX
//
//  Subprozeduren
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
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  StartList(0,'');  // Liste generieren
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
  if (aSeite=1) then begin
    StartLine();
    EndLine();
    startline();
    List_Spacing[ 1]   #  0.0;
    List_Spacing[ 2]   # 120.0;
    Write(1, 'Kunde    :' +  ZahlI(Auf.P.Kundennr)   +' ' + Auf.P.KundenSW ,n,0);
    endline();
    startline();
    Write(1, 'Auftrag :' +  ZahlI(Auf.Nummer)     ,n, _LF_INT);
    endline()
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]   #  0.0;
  List_Spacing[ 2]   # 20.0;
  List_Spacing[ 3]   # 50.0;
  List_Spacing[ 4]   #150.0;



  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Artikel-Nr'                      ,n , 0);
  Write(2,  'Vorrat              Anz.       Länge'                ,n , 0);
  Write(3,  'schneiden zu'                      ,n , 0);
  EndLine();
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
  Erx       : int;
  vSelName  : alpha;
  vSel      : int;
  vArt      : alpha;
  vCharge   : alpha;
  vQ        : alpha(4000);
end;
begin

  Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
  Erx # RecLink(100,400,4,_recFirsT);   // Kunde holen


  // Selektionsquery für 404
  vQ # '';
  Lib_Sel:QInt( var vQ, 'Auf.A.Nummer', '=', Auf.Nummer );
  Lib_Sel:QAlpha( var vQ, 'Auf.A.Aktionstyp', '=', 'PR S' );

  // Selektion starten...
  vSel # SelCreate( 404, 0 );
  vSel->SelAddSortFld(2,1,_KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2,4,_KeyFldAttrUpperCase);
  vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  //vSelName # Sel_Build(vSel, 404, 'LST.400006',y,0);
  ListInit(n); // KEIN Landscape

  // Reservierungen loopen
  Erx # RecRead(404,vSel,_recFirst);
  WHILE (Erx<=_rLocked ) DO BEGIN

    if (Auf.A.ArtikelNr='') /*or (Auf.A.Charge='')*/ then begin
      Erx # RecRead(404,vSel,_RecNext);
      CYCLE;
    end;

    RecLink(250,404,3,_recFirst);         // Artikel holen
    RecLink(252,404,4,_recFirst);         // Charge holen

    if (vArt<>Art.C.ArtikelNr) or (vCharge<>Art.C.Charge.Intern) then begin
      if (vArt<>'') then begin
        startline();
        write(1,Art.C.ArtikelNr ,n,0);
        write(2,ZahlI(Art.C.Bestand.Stk) +'     ' + ZahlF("Art.C.Länge",2) ,n ,0);
        endline();

      end;

      startline();
      write(3, GV.Alpha.01 ,n,0);
      endline();
      Gv.Alpha.01 # '';
    end;
    vArt    # Art.C.ArtikelNr;
    vCharge # Art.C.Charge.Intern;
    "Auf.A.Stückzahl" # "Auf.A.Stückzahl" div Art.C.Bestand.Stk;

    if (Gv.Alpha.01<>'') then Gv.Alpha.01 # Gv.ALpha.01 + ' + ';
    Gv.alpha.01 # Gv.Alpha.01 + cnvai("Auf.A.Stückzahl",0,0,2) + ' x '+cnvaf("Auf.A.Länge",0,0,0,6);

    Erx # RecRead(404,vSel,_RecNext);
  END;

  if (vArt<>'') then begin
  startline();
        write(1,Art.C.ArtikelNr ,n,0);
        write(2,ZahlI(Art.C.Bestand.Stk) +'     ' + ZahlF("Art.C.Länge",2) ,n ,0);
        endline();
  end;

  ListTerm();

  SelClose(vSel);
  SelDelete(404,vSelName);


end;

//========================================================================