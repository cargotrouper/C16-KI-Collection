@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200008
//                    OHNE E_R_G
//  Info        Ausgabe der Lagegeldberechnung-KUNDE
//
//
//  11.11.2009  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
@I:Def_aktionen

@I:Struct_Lagergeld

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort : int;
  vSortName : alpha;
end;
begin
  StartList(vSort,vSortname);  // Liste generieren
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

  if (aSeite=1) then begin
    Adr.Lieferantennr # Sel.Mat.Lieferant;
    Recread(100,3,0);                 // Lieferant holen

    List_Spacing[ 1] #  0.0;
    List_Spacing[ 2] # List_Spacing[ 1] + 325.0;
    StartLine();
    Write(1, 'für Kunde/Lieferant: '+Adr.Anrede+' '+Adr.Name+' '+Adr.Zusatz+', '+Adr.Ort+', '+"Adr.Straße", n, 0);
    EndLine();
    StartLine();
    Write(1, 'Zeitraum: '+dats(Sel.Mat.von.EDatum)+' bis '+Dats(Sel.Mat.bis.EDatum), n, 0);
    EndLine();
    StartLine();
    Write(1, 'Preis pro TonnenTage : '+ANum(GV.Num.01,2)+"Set.HausWährung.Kurz",  n, 0);
    EndLine();
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1] #  0.0;
  List_Spacing[ 2] # List_Spacing[ 1] + 25.0;
  List_Spacing[ 3] # List_Spacing[ 2] + 25.0;
  List_Spacing[ 4] # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5] # List_Spacing[ 4] + 25.0;
  List_Spacing[ 6] # List_Spacing[ 5] + 25.0;
  List_Spacing[ 7] # List_Spacing[ 6] + 25.0;
  List_Spacing[ 8] # List_Spacing[ 7] + 25.0;
  List_Spacing[ 9] # List_Spacing[ 8] + 25.0;
  List_Spacing[10] # List_Spacing[ 9] + 25.0;

  StartLine(_LF_BOLD | _LF_UNDERLINE);
  Write(1, 'MatNr.',      y, 0);
  Write(2, 'Von Datum',   y, 0);
  Write(3, 'bis Datum',   y, 0);
  Write(4, 'Tage',        y, 0);
  Write(5, 'Gewicht',     y, 0);
  Write(6, 'TonnenTage',  y, 0);
  Write(7, 'Betrag '+"Set.Hauswährung.Kurz",      y, 0);
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
Sub StartList(aSort : int; aSortName : alpha);
local begin
  vTree     : int;
  vItem     : int;
  vBasis    : float;
  vX        : float;
end;
begin
  ListInit(n);    // Portrait

  vTree   # GV.Int.01;
  vBasis  # GV.Num.01;

  FOR  vItem # Sort_ItemFirst(vTree);
  loop vItem # Sort_ItemNext(vTree, vItem);
  WHILE (vItem != 0) DO BEGIN

    // Structure holen...
    VarInstance(struct_Lagergeld, vItem->spID);

    vX # Rnd(vBasis * s_TTage,2);
    StartLine();
    Write(1, ZahlI(s_MatNr),                  y, _LF_Int);
    Write(2, Dats(s_VonDat),                  y, _LF_Date);
    Write(3, Dats(s_BisDat),                  y, _LF_Date);
    Write(4, ZahlI(s_Tage),                   y, _LF_Int);
    Write(5, ZahlI(Cnvif(s_Gewicht)),         y, _LF_Int);
    Write(6, ZahlF(s_TTage,2),                y, _LF_Num);
    Write(7, ZahlF(vX     ,2),                y, _LF_Num);
    EndLine();
    AddSum(4, cnvfi(s_Tage));
    AddSum(5, s_Gewicht);
    AddSum(6, s_TTage);
    Addsum(7, vX);
  END;

  StartLine(_LF_OVERLINE);
  Write(4, ZahlI(cnvif(getsum(4))),         y, _LF_Int);
  Write(5, ZahlI(cnvif(GetSum(5))),         y, _LF_Int);
  Write(6, ZahlF(GetSum(6),2),              y, _LF_Num);
  Write(7, ZahlF(GetSum(7),2),              y, _LF_Num);
  EndLine();

  ListTerm();
end;

//========================================================================