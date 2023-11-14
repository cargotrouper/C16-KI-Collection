@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Prj_SL_121002
//                    OHNE E_R_G
//  Info
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


  List_Spacing[ 1]  # 0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 20.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 60.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 30.0;


  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Artikel'                               ,n , 0);
  Write(2, 'Bezeichnung'                           ,n , 0);
  Write(3, 'kg/m'                                  ,n , 0);
  Write(4, 'Ges. Länge'                            ,n , 0, 2.0);
  Write(5, 'Ges. Gewicht'                          ,n , 0);
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
      Write(1, Art.Nummer                                 ,y , 0,3.0);
      Write(2, Art.Bezeichnung1                           ,n , 0);
      Write(3, ZahlF(GV.Num.01,2)                         ,y , _LF_NUM);
      Write(4, ZahlF(GV.Num.02,2)                         ,y , _LF_NUM);
      Write(5, ZahlF(GV.Num.03,2)                         ,y , _LF_NUM);
      EndLine();
      AddSum(11,GV.Num.02)
      AddSum(12,GV.Num.03);

    end;

    'EndSumme' : begin
      StartLine(_LF_Overline);
      Write(3, 'Endsumme:'                                ,y , 0);
      Write(4, ZahlF(GetSum(11),2)                        ,y , 0);
      Write(5, ZahlF(GetSum(12),2)                        ,y , 0);
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
  vTree     : int;
  vItem     : int;
end;
begin

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  Erx # RecLink(121,120,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Sort_ItemAdd(vTree, Prj.SL.Artikelnr, 121, RecInfo(121,_RecId));
    Erx # RecLink(121,120,2,_recNext);
  END;

  ListInit(n); // KEIN Landscape


  Erx # RecLink(100,120,1,_recFirsT);   // Adresse holen
  if (Erx>_rLocked) then RecBufClear(100);


  RecBufClear(250);
  gv.Num.02 # 0.0;
  gv.Num.03 # 0.0;

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    if (Prj.SL.Artikelnr<>Art.Nummer) and (Art.Nummer<>'') then begin
      if ("Art.GewichtProm"<>0.0) then
        Gv.Num.01 # "Art.GewichtProm"
      else if ("Art.GewichtProStk"<>0.0) and ("Art.Länge"<>0.0) then
        Gv.Num.01 # "Art.GewichtProStk" / "Art.Länge" * 1000.0
      else
        Gv.Num.01 # 0.0;
      print('Artikel');
           gv.Num.02 # 0.0;
      Gv.Num.03 # 0.0;
    end;

    RecLink(250,121,2,_recFirst);                   // Artikel holen
    "Prj.SL.Länge" # "Prj.SL.Länge" / 1000.0;
    Gv.Num.02 # Gv.Num.02 + (CnvfI("Prj.SL.Stückzahl") * "Prj.SL.Länge");
    Gv.Num.03 # Gv.Num.03 + Prj.SL.Gewicht;
  END;

  if ("Art.GewichtProm"<>0.0) then
    Gv.Num.01 # "Art.GewichtProm"
  else if ("Art.GewichtProStk"<>0.0) and ("Art.Länge"<>0.0) then
    Gv.Num.01 # "Art.GewichtProStk" / "Art.Länge" * 1000.0
  else
    Gv.Num.01 # 0.0;
  print('Artikel');

    Print('EndSumme');
    ListTerm();
  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================