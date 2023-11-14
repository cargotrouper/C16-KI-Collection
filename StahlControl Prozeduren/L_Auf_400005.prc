@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400005
//                    OHNE E_R_G
//  Info        Rohgewinn eines Auftrages
//
//
//  13.08.2004  AI  Erstellung der Prozedur
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
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]   #  0.0;
  List_Spacing[ 2]   # List_Spacing[ 1] + 10.0;
  List_Spacing[ 3]   # List_Spacing[ 2] + 40.0;
  List_Spacing[ 4]   # List_Spacing[ 3] + 30.0;
  List_Spacing[ 5]   # List_Spacing[ 4] + 30.0;
  List_Spacing[ 6]   # List_Spacing[ 5] + 30.0;
  List_Spacing[ 7]   # List_Spacing[ 6] + 30.0;


  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Ps'                     ,n , 0);
  Write(2,  'Artikel'                ,n , 0);
  Write(3,  'Menge MEH'              ,n , 0);
  Write(4,  'EK-Wert'                ,n , 0);
  Write(5,  'VK-Wert'                ,n , 0);
  Write(6,  'Rohgewinn'              ,n , 0);
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
  Erx   : int;
  vSelName : alpha;
  vSel : int;
  vEK : float;
  vVK : float;
  vMenge : float;
end;
begin

  Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
  Erx # RecLink(100,400,4,_recFirsT);   // Kunde holen
  ListInit(n); // KEIN Landscape

  Erx # RecLink(401,400,9,_recFirst);
  WHILE (Erx<=_rLocked ) DO BEGIN

    RecLink(250,401,2,_recFirst);                 // Artikel holen

    // EK-finden
    vEK # 0.0;
    Erx # RecLink(254,250,6,_RecFirst);           // Preise loopen
    WHILE (Erx<=_rLocked) do begin
      if (Art.P.PreisTyp='EK') and (Art.P.MEH=Auf.P.MEH.Einsatz) then begin
        vEK # Art.P.Preis;
        Lib_Berechnungen:Waehrung_Umrechnen(Art.P.Preis, "Art.P.Währung", var vEK, 1);
        BREAK;
      end;
      Erx # RecLink(254,250,6,_RecNext);
    END;
    if (Art.P.PEH=0) then Art.P.PEH # 1;
    Gv.Num.01 # vEK / CnvFI(Art.P.PEH) * Auf.P.Menge;

    // VK errechnen
    vMenge # Lib_einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
    Lib_Berechnungen:Waehrung_Umrechnen(Auf.P.Einzelpreis, "Auf.Währung", var vVK, 1);
    if (Auf.P.PEH=0) then Auf.P.PEH # 1;
    Gv.Num.02 # vMenge / cnvfi(Auf.P.PEH) * vVK;
    Gv.Num.03 # Gv.Num.02 - Gv.Num.01;

    StartLine();
    Write(1, ZahlI(Auf.P.Position)                                  ,n , _LF_INT);
    Write(2, Auf.P.Artikelnr                                       ,n , 0);
    Write(3, ZahlF(Auf.P.Menge,2) +' '+  Auf.P.MEH.Einsatz                    ,n , 0);
    Write(4, ZahlF(GV.Num.01,2)                       ,n , _LF_NUM);
    Write(5, ZahlF(GV.Num.02,2)                       ,n , _LF_NUM);
    Write(6, ZahlF(GV.Num.03,2)                       ,n , _LF_NUM);
    EndLine();
    AddSum(1,GV.Num.01)
    AddSum(2,GV.Num.02);
    AddSum(3,GV.Num.03);

    Erx # RecLink(401,400,9,_RecNext);
  END;
  List_Spacing[ 3]   # 20.0;
  List_Spacing[ 4]   # 70.0;
  List_Spacing[ 5]   # 90.0;
  List_Spacing[ 6]   #110.0;
  List_Spacing[ 7]   #130.0;
  StartLine();
  Write(3, 'Auftragsgesamtsumme:'                       ,n , 0);
  Write(4, ZahlF(GetSum(1),2)                       ,n , _LF_NUM);
  Write(5, ZahlF(GetSum(2),2)                       ,n , _LF_NUM);
  Write(6, ZahlF(GetSum(3),2)                       ,n , _LF_NUM);
  EndLine();
  ListTerm();

end;

//========================================================================