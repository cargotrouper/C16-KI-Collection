@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Prj_SL_121001
//                    OHNE E_R_G
//  Info        Restmengen der Aufträge ausgeben
//
//
//  13.08.2004  AI  Erstellung der Prozedur
//  2022-06-28  AH  ERX
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
  StartList(0,'');  // Liste generieren
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin


  WriteTitel();
  StartLine();
  EndLine();
      StartLine();
    EndLine();


  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # 20.0;
  List_Spacing[ 3]  # 45.0;
  List_Spacing[ 4]  # 70.0;
  List_Spacing[ 5]  # 95.0;
  List_Spacing[ 6]  #120.0;
  List_Spacing[ 7]  #145.0;
  List_Spacing[ 8]  #170.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Pos.'                  ,n , 0);
  Write(2, 'Artikel'                      ,n , 0);
  Write(3, 'Stück'                           ,n , 0);
  Write(4, 'Länge'                           ,n , 0);
  Write(5, 'kg/m'                          ,n , 0);
  Write(6, 'Ges. Länge'                            ,n , 0, 2.0);
  Write(7, 'Ges. Gewicht'                ,n , 0);
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
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'Artikel' : begin
      StartLine();
      Write(1, Prj.SL.Referenznr                       ,n , 0);
      Write(2, Art.Nummer                    ,n , 0);
      Write(3, ZahlI("Prj.SL.Stückzahl")           ,n , _LF_INT);
      Write(4, ZahlF("Prj.SL.Länge",2)         ,n , _LF_NUM);
      Write(5, ZahlF(GV.Num.01,2)                  ,n , _LF_NUM);
      Write(6, ZahlF(GV.Num.02,2)                         ,n , _LF_NUM);
      Write(7, ZahlF(Prj.SL.Gewicht,2)                         ,n , _LF_NUM);
      EndLine();
      AddSum(11,GV.Num.02)
      AddSum(12,Prj.SL.Gewicht);

    end;

    'EndSumme' : begin
      StartLine(_LF_Overline);
      Write(5, 'Endsumme:'                        ,n , 0);
      Write(6, ZahlF(GetSum(11),2)                ,n , 0);
      Write(7, ZahlF(GetSum(12),2)                ,n , 0);
      EndLine();
      ResetSum(11);
      ResetSum(12);

      StartLine();
      EndLine();
    end;


  end; // CASE
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
  vFlag     : int;
end;
begin
   ListInit(n); // KEIN Landscape


  Erx # RecLink(100,120,1,_recFirsT);   // Adresse holen
  if (Erx>_rLocked) then RecBufClear(100);

  vFlag # _RecFirst;
  WHILE (RecLink(121,120,3,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    RecLink(250,121,2,_recFirst);                   // Artikel holen
    "Prj.SL.Länge" # "Prj.SL.Länge" / 1000.0;
    if ("Art.GewichtProm"<>0.0) then
      Gv.Num.01 # "Art.GewichtProm"
    else if ("Art.GewichtProStk"<>0.0) and ("Art.Länge"<>0.0) then
      Gv.Num.01 # "Art.GewichtProStk" / "Art.Länge" * 1000.0
    else
      Gv.Num.01 # 0.0;
    Gv.Num.02 # CnvfI("Prj.SL.Stückzahl") * "Prj.SL.Länge";
    print('Artikel');

  END;
    Print('EndSumme');
    ListTerm();


end;

//========================================================================