@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450002
//                    OHNE E_R_G
//  Info        Nachkalkulation Material
//
//
//  24.07.2007  AI  Erstellung der Prozedur
//  15.04.2010  AI  Beachtung des Datums bei Vorgängeraktionen
//  22.10.2012  AI  Projekt 1326/310: auch Kosten nach Today einbeziehen
//  08.05.2013  ST  Abmessung laut Warengruppenmaterialtyp
//  12.02.2014  AH  Einsatzgewicht laut Mat.Verwieungsart
//  06.02.2017  AH  Listensumme
//  18.11.2020  AH  Fix für "Fahren dann Spalten" und Schrottnullung
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    sub _getAufAbmessung() : alpha
//
//========================================================================
@I:Def_Global
@I:Def_List
@I:Def_Aktionen

define begin
  Trim(a) : StrAdj(AInt(a),_Strbegin)
  TrimF(a,b) : StrAdj(cnvaf(a,_Fmtnumnogroup,0,b),_Strbegin)

  c_SumErlKG  : 1
  c_SumErlVK  : 2

  c_sumMatKG  : 11
  c_sumMatK1  : 12
  c_sumMatK2  : 13
  c_SumMatEK  : 14

  c_sumAktK1  : 21
  c_sumAktK2  : 22
  c_sumAktEK  : 23

  c_sumReKG   : 31
  c_sumReEK   : 32
  c_sumReVK   : 33

  c_ListKG    : 41
  c_ListVK    : 43
  c_ListEK    : 44
  c_ListDB    : 45
end;

declare StartList(aSort : int; aSortName : alpha);

local begin
// Handles für die Zeilenelemente
  g_Empty       : int;
  g_Sel1        : int;
  g_Sel2        : int;
  g_Sel3        : int;
  g_Header      : int;

  g_ReKopf      : int;
  g_Re          : int;
  g_ReFuss      : int;
  g_ErlKopf     : int;
  g_Erl         : int;
  g_ErlFuss     : int;
  g_VK_Rueck    : int;
  g_VK_GutS     : int;
  g_MatKopf     : int;
  g_Mat         : int;
  g_MatFuss     : int;
  g_Akt         : int;
  g_AktFuss     : int;
  g_Summe1      : int;
  g_Summe2      : int;

  vProgress : handle;
end;


//========================================================================
//  sub _getAufAbmessung() : alpha
//    Gibt die Abmessung für einen Auftrag zurück
//========================================================================
sub _getAufAbmessung() : alpha
local begin
  vA : alpha(1000);
end;
begin
  case (Wgr.Materialtyp) of
    // COIL
    c_WGRTyp_Coil : begin
        vA # vA + TrimF(Auf.P.Dicke,2)+' x '+TrimF(Auf.P.Breite,1);
    end;

    // Tafel
    c_WGRTyp_Tafel : begin
        vA # vA + TrimF(Auf.P.Dicke,2)+' x '+TrimF(Auf.P.Breite,1);
        vA # vA + ' x '+TrimF("Auf.P.Länge",1);
    end;

    // Stab
    c_WGRTyp_Stab : begin
        vA # vA + TrimF(Auf.P.RAD,2);
        vA # vA + ' x '+TrimF("Auf.P.Länge",1);
    end;

    // Rohr
    c_WGRTyp_Rohr : begin
        vA # vA + TrimF(Auf.P.RAD,2);
        vA # vA + ' x ' + TrimF(Auf.P.RID,2);
        vA # vA + ' x '+TrimF("Auf.P.Länge",1);
    end;

    // Profil
    c_WGRTyp_Profil : begin
        vA # vA + TrimF(Auf.P.Dicke,2)+' x '+TrimF(Auf.P.Breite,2);
        vA # vA + ' x ' + TrimF(Auf.P.RAD,2);
        vA # vA + ' x '+ TrimF("Auf.P.Länge",1);
    end;

    // unbekannter Typ
    otherwise
      vA # 'Unbekannter Materialtyp';

  end; // case (Wgr.Materialtyp) of

  RETURN vA;
end;


//========================================================================
//  Main
//
//========================================================================

MAIN
begin
  RecBufClear(998);
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.bis.Datum           # today;
//  Sel.Fin.von.Rechnung # 2524;
//  Sel.Fin.bis.Rechnung # 2524;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450002',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
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
  gSelected # 0;
  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  Erx             : int;
  vA              : alpha;
  vKG             : float;
  vP1,vP2,vP3,vP4 : float;
end;
begin
  case aName of

    'ReKopf' : begin
      StartLine(_LF_UnderLine + _LF_Bold);
      Write(1, 'Re.Nr.'                           ,y , 0);
      Write(2, 'Datum'                            ,y , 0);
      Write(3, 'Ku.Nr.'                           ,y , 0);
      Write(4, 'Kunde'                            ,n , 0,2.0);
      Write(18,'EK-Eff. '+"Set.Hauswährung.Kurz"  ,y , 0);
      Write(19,'Erlös '+"Set.Hauswährung.Kurz"    ,y , 0);
      Write(20,'Spanne '+"Set.Hauswährung.Kurz"   ,y , 0);
      Write(21,'%'                                ,y , 0);
      EndLine();
    end;
    'Re' : begin;
      // aNr; alpha; Rechts?; Format; maxXX;
      StartLine();
      Write(1, ZahlI(Erl.Rechnungsnr)           ,y , _LF_Int);
      Write(2, DATS(Erl.Rechnungsdatum)         ,y , _LF_Date);
      Write(3, ZahlI(Erl.Kundennummer)          ,y , _LF_Int);
      Write(4, Erl.Kundenstichwort              ,n , _LF_string, 2.0);
      EndLine();
    end;
    'ReFuss' : begin
      vKG # GetSum(c_sumReKG);
      vP1 # GetSum(c_sumReEK);
      vP2 # GetSum(c_sumReVK);
      vP3 # vP2-vP1;
      vP4 # Lib_Berechnungen:Prozent(vP3,vP2);
      StartLine(_LF_UnderLine | _LF_Bold);
      Write(2,'Re.Sum.'                          ,n , 0);
      Write(13,ZahlF(vKG,0)                      ,y , _LF_Int);
      Write(18,ZahlF(vP1,2)                      ,y , _LF_Wae);
      Write(19,ZahlF(vP2,2)                      ,y , _LF_Wae);
      Write(20,ZahlF(vP3,2)                      ,y , _LF_Wae);
      Write(21,ZahlF(vP4,1)+'%'                  ,y , 0);
      EndLine();
      ResetSum(c_sumReKG);
      ResetSum(c_sumReEK);
      ResetSum(c_sumReVK);
      AddSum(c_ListKG, vKG);
      AddSum(c_ListEK, vP1);
      AddSum(c_ListVK, vP2);
      AddSum(c_ListDB, vP3);
    end;

    'ErlKopf' : begin
      StartLine(_LF_Bold);
      Write(6,'Pos.'                              ,y , 0);
      Write(7,'Auftrag'                           ,n , 0, 2.0);
      Write(8,'Gewicht'                           ,y , 0);
      Write(9,'Qualität'                          ,n , 0, 2.0);
      Write(10,'Abmessung'                        ,n , 0, 2.0);
      EndLine();
    end;
    'Erl' : begin;
      StartLine();
      // Positionserlös?
      if (Erl.K.RechnungsPos<>0) then begin
        Write(6,ZahlI(Erl.K.Rechnungspos)      ,y, _LF_Int);
        Write(7,ZahlI(Erl.K.Auftragsnr)+'/'
          +ZahlI(Erl.K.AuftragsPos)             ,n, 0, 2.0);

        // Grundpreis?
        if (Erl.K.Bemerkung=Translate('Grundpreis')) then begin
          vKG # Erl.K.Gewicht;
          Write(8,ZahlF(vKG,Set.Stellen.Gewicht)   ,y, _LF_Num);
          Write(9,"Auf.P.Güte"                   ,n, 0, 2.0);
/*
          vA #  ZahlF(Auf.P.Dicke,  Set.Stellen.Dicke) + ' x '+
                ZahlF(Auf.P.Breite, Set.Stellen.Breite);
          if ("Auf.P.Länge"<>0.0) then
            vA # vA + ' x '+ZahlF("Auf.P.Länge", "Set.Stellen.Länge");
*/
          // ST 2013-05-08: Abmessung laut Materialtyp
          vA # _getAufAbmessung();
          end
        else begin  // sonst Aufpreis
          vKG # 0.0;
          Write(9,'Aufpreis'                     ,n, 0, 2.0);
          vA # Erl.K.Bemerkung;
        end;
        end
      else begin  // sonst Kopfaufpreis
        Write(7,ZahlI(Erl.K.Auftragsnr)          ,n, 0, 2.0);
        Write(9,'Kopfaufpreis'                   ,n, 0, 2.0);
        vA # Erl.K.Bemerkung;
        vKG # 0.0;
      end;
      Write(10,vA                                ,n, 0, 2.0);
      Write(19,ZahlF(Erl.K.BetragW1,2)            ,y, _LF_Num);
      EndLine();
      AddSum(c_SumErlKG, vKG);
      AddSum(c_SumErlVK,Erl.K.BetragW1);

    end;
    'ErlFuss' : begin
      vKG # GetSum(c_SumErlKG);
      vP1 # GetSum(c_SumErlVK);
      StartLine(_LF_Bold);
//      Write(8,ZahlF(vKG,Set.Stellen.Gewicht)   ,y, _LF_Num);
      Write(19,ZahlF(vP1,2)                     ,y, _LF_Num);
      EndLine();

      AddSum(c_SumReKG, vKG);
      AddSum(c_SumReVK, vP1);

      ResetSum(c_SumErlKG);
      ResetSum(c_SumErlVK);
    end;

    'VK-RÜCK' : begin;
      StartLine();
      Write(6,ZahlI(Erl.K.Rechnungspos)      ,y, _LF_Int);
      Write(7,ZahlI(Erl.K.Auftragsnr)+'/'
        +ZahlI(Erl.K.AuftragsPos)              ,n, 0, 2.0);
      Write(9,''                   ,n, 0, 2.0);
      vA # 'Rückstellung';//;EKK.Bemerkung;
      vKG # 0.0;
      Write(10,vA                                ,n, 0, 2.0);
      Write(19,ZahlF(0.0-EKK.PreisW1,2)              ,y, _LF_Num);
      EndLine();
      AddSum(c_SumErlKG, vKG);
      AddSum(c_SumErlVK,0.0-EKK.PreisW1);
    end;

    'VK-GUTS' : begin;

      StartLine();
      // Positionserlös?
      Write(7,ZahlI(Erl.K.Auftragsnr)          ,n, 0, 2.0);
      Write(9,''                     ,n, 0, 2.0);
      if (Erl.K.BetragW1<0.0) then begin
        vA # 'Gutschrift';//Erl.K.Bemerkung
        end
      else begin
        vA # 'Belastung';
//TEST        Erl.K.Gewicht # Erl.K.Gewicht + 10.0;
//        Erl.K.EKPreisSummeW1 # Erl.K.EKPreisSummeW1 + 10.0;
//        Erl.K.InterneKostW1 # Erl.K.InterneKostW1 + 10.0;
//        Erl.K.BetragW1 # Erl.K.BetragW1 + 10.0;
      end;
      vKG # 0.0;
      Write(10,vA                                ,n, 0, 2.0);

      // Rücknahme??
      if (Erl.K.EKPReisSummeW1<>0.0) or (Erl.K.Gewicht<>0.0) or ("Erl.K.Stückzahl"<>0) then begin
        Write(13, ZahlF(Erl.K.Gewicht,Set.Stellen.Gewicht)    ,y , _LF_Num);
        Write(18, ZahlF(Erl.K.EKPreisSummeW1 + Erl.K.InterneKostW1, 2)              ,y , _LF_Wae);
        AddSum(c_sumReKG,Erl.K.Gewicht);
        AddSum(c_SumReEK, Erl.K.EKPReisSummeW1 + Erl.K.InterneKostW1);
      end;

      Write(19,ZahlF(Erl.K.BetragW1,2)            ,y, _LF_Num);
      EndLine();
      AddSum(c_SumErlKG, vKG);
      AddSum(c_SumErlVK,Erl.K.BetragW1);
    end;


    'MatKopf' : begin
      StartLine(_LF_Bold);
      Write(12, 'Mat.Nr.'                         ,y , 0);
      Write(13, 'Gewicht'                         ,y , 0);
      Write(14, 'Aktion'                          ,n , 0, 2.0);
      Write(15, 'Kost1 '+"Set.Hauswährung.Kurz"   ,y , 0);
      Write(16, 'Kost2 '+"Set.Hauswährung.Kurz"   ,y , 0);
      EndLine();
    end;


    'Mat' : begin
      Erx # RekLink(818,200,10,_recfirst);    // Verwiegungsart Mat. holen
      if (Erx>_rLocked) then VwA.NettoYN # y;
      if (VwA.NettoYN) then
        vKG # Auf.A.Nettogewicht
      else
        vKG # Auf.A.Gewicht;

      vP1 # Mat.EK.Preis * vKG/1000.0;
      vP2 # 0.0;
      StartLine();
      Write(12, ZahlI(Mat.Nummer)                 ,y , _LF_Int);
      Write(13, ZahlF(vKG,Set.Stellen.Gewicht)    ,y , _LF_Num);
      Write(14, 'TEP'                             ,n , 0, 2.0);
      Write(15, ZahlF(vP1, 2)                     ,y , _LF_Wae);
      Write(16, ZahlF(vP2, 2)                     ,y , _LF_Wae);
      EndLine();
      AddSum(c_sumMatKG,vKG);
      AddSum(c_sumMatK1,vP1);
      AddSum(c_sumMatK2,vP2);
      AddSum(c_SumMatEK,vP1 + vP2);

      AddSum(c_sumAktK1,vP1);
      AddSum(c_sumAktK2,vP2);
      AddSum(c_sumAktEK,vP1 + vP2);
    end;
    'MatFuss' : begin
      vKG # GetSum(c_sumMatKG);
      vP1 # GetSum(c_sumMatK1);
      vP2 # GetSum(c_sumMatK2);
      vP3 # GetSum(c_sumMatEK);
      StartLine(_LF_Bold);
//      Write(12, ''                                ,n , 0);
//      Write(13, ZahlF(vKG,Set.Stellen.Gewicht)    ,y , _LF_Num);
      Write(15, ZahlF(vP1, 2)                     ,y , _LF_Wae);
      Write(16, ZahlF(vP2, 2)                     ,y , _LF_Wae);
      Write(18, ZahlF(vP3, 2)                     ,y , _LF_Wae);
      EndLine();

      AddSum(c_SumReEK, vP3);

      ResetSum(c_sumMatKG);
      ResetSum(c_sumMatK1);
      ResetSum(c_sumMatK2);
      ResetSum(c_sumMatEK);
    end;

    'Akt' : begin
//      vKG # Auf.A.Gewicht;
      Erx # RekLink(818,200,10,_recfirst);    // Verwiegungsart Mat. holen
      if (Erx>_rLocked) then VwA.NettoYN # y;
      if (VwA.NettoYN) then
        vKG # Auf.A.Nettogewicht
      else
        vKG # Auf.A.Gewicht;

      vP1 # Mat.A.Kosten2W1 * vKG/1000.0;
      vP2 # Mat.A.KostenW1  * vKG/1000.0;
      StartLine();
      if (Mat.A.Aktionstyp = 'LFS') then
        Mat.A.Bemerkung # 'Transportkosten';
      Write(14, Mat.A.Bemerkung                   ,n , 0, 2.0);
      Write(15, ZahlF(vP1, 2)                     ,y , _LF_Wae);
      Write(16, ZahlF(vP2, 2)                     ,y , _LF_Wae);
      EndLine();
      AddSum(c_sumMatK1,vP1);
      AddSum(c_sumMatK2,vP2);
      AddSum(c_sumMatEK,vP1 + vP2);
      AddSum(c_sumAktK1,vP1);
      AddSum(c_sumAktK2,vP2);
      AddSum(c_sumAktEK,vP1 + vP2);
    end;
    'AktFuss' : begin
      vP1 # GetSum(c_sumAktK1);
      vP2 # GetSum(c_sumAktK2);
      vP3 # GetSum(c_sumAktEK);
      StartLine();
      Write(13, ''                                ,n , 0);
      Write(15, ZahlF(vP1, 2)                     ,y , _LF_Wae | _LF_Bold);
      Write(16, ZahlF(vP2, 2)                     ,y , _LF_Wae | _LF_Bold);
      Write(18, ZahlF(vP3, 2)                     ,y , _LF_Wae);
      EndLine();
      ResetSum(c_sumAktK1);
      ResetSum(c_sumAktK2);
      ResetSum(c_sumAktEK);
    end;

    'ListenFuss' : begin;
      StartLine(_LF_OverLine | _LF_Underline| _LF_Bold);
      // Positionserlös?
      Write(2,'GESAMT'                                      ,n , 0);
      Write(8,ZahlF(GetSum(c_ListKG),Set.Stellen.Gewicht)   ,y, _LF_Num);
      Write(18,ZahlF(GetSum(c_ListEK),2)                    ,y, _LF_Wae);
      Write(19,ZahlF(GetSum(c_ListVK),2)                    ,y, _LF_Wae);
      Write(20,ZahlF(GetSum(c_ListDB),2)                    ,y, _LF_Wae);
      vP4 # Lib_Berechnungen:Prozent(GetSum(c_ListDB),GetSum(c_ListVK));
      Write(21,ZahlF(vP4,1)+'%'                             ,y , 0);
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
  if (aSeite=1) then begin
    StartLine();
    EndLine();
    StartLine();
    Write(1 ,'Rechnung    ' + AInt(Sel.Fin.von.Rechnung) + '  bis  ' + AInt(Sel.Fin.bis.Rechnung),n);
    EndLine();
    StartLine();
    Write(1 ,'Zeitraum    ' + CnvAD(Sel.von.Datum) + '  bis  ' + CnvAd(Sel.bis.Datum),n);
    EndLine();
    StartLine();
    EndLine();
  end;

  case (List_mode) of
    'ReKopf'  :  Print('ReKopf');
    'ErlKopf' :  Print('ErlKopf');
    'MatKopf' :  Print('MatKopf');
    'AktKopf' :  Print('AktKopf');
  end;

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
  Erx         : int;
  vFlag       : int;        // Datensatzlese option
  vSel        : int;
  vSelName    : alpha;
  vI          : int;
  vDatei      : int;
  vTEP        : float;
  vAktionTree : int;
  vItem       : int;
  vQ          : alpha(4000);
  vMFile,vMID : int;
  vTree       : int;
  vDat1,vDat2 : date;
  vFirst      : logic;
end;
begin

  ListInit(y);    // Querdruck

  List_Spacing[ 1]  #   0.0;
  List_Spacing[ 2]  #  15.0;
  List_Spacing[ 3]  #  30.0;
  List_Spacing[ 4]  #  45.0;
  List_Spacing[ 5]  # 100.0;

  List_Spacing[ 6]  # 15.0;                     // RePos.
  List_Spacing[ 7]  # List_Spacing[ 6] + 10.0;  // Auftrag
  List_Spacing[ 8]  # List_Spacing[ 7] + 20.0;  // Gewicht
  List_Spacing[ 9]  # List_Spacing[ 8] + 20.0;  // Güte
  List_Spacing[10]  # List_Spacing[ 9] + 20.0;  // Abmessung
  List_Spacing[11]  # List_Spacing[10] + 95.0;

  List_Spacing[12]  # List_Spacing[ 7] + 0.0;   // Mat.Nummer
  List_Spacing[13]  # List_Spacing[12] + 20.0;  // Gewicht
  List_Spacing[14]  # List_Spacing[13] + 20.0;  // Aktion

  List_Spacing[22]  # 277.0;
  List_Spacing[21]  # List_Spacing[22] - 20.0;  // Prozent
  List_Spacing[20]  # List_Spacing[21] - 25.0;  // Spanne
  List_Spacing[19]  # List_Spacing[20] - 25.0;  // Erlös
  List_Spacing[18]  # List_Spacing[19] - 25.0;  // EK-Eff
  List_Spacing[17]  # List_Spacing[18] - 0.0;
  List_Spacing[16]  # List_Spacing[17] - 25.0;  // Kost2
  List_Spacing[15]  # List_Spacing[16] - 25.0;  // Kost1

  // Selektionsquery
  vQ # '';
  if (Sel.Fin.von.Rechnung != 0) or (Sel.Fin.bis.Rechnung != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Erl.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung);
  if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'Erl.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.Adr.von.Kdnr != 0) then
    Lib_Sel:QInt(var vQ, 'Erl.Kundennummer', '=', Sel.Adr.von.Kdnr);
  if (Sel.Adr.von.Vertret != 0) then
    Lib_Sel:QInt(var vQ, 'Erl.Vertreter', '=', Sel.Adr.von.Vertret);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ, 'Erl.Verband', '=', Sel.Adr.von.Verband);
  if (Sel.Fin.StornosYN=n) then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + '(Erl.StornoRechNr = 0)';
  end;

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  If (Sel.Fin.nurMarkeYN) then begin

    // Selektion starten...
    vSel # SelCreate(450, 1);
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(450,_SelLock,vSelName);   // Selektion laden

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 450) then begin
        RecRead(450,0,_RecId,vMID);
        SelRecInsert(vSel,450);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

  end else begin

    // Selektion starten...
    vSel # SelCreate(450, 1);
    vSel->SelDefQuery('', vQ);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);

  end;

  //vSel # 0;
  //vSelName # Sel_Build(vSel, 450, 'LST.450002' ,y ,0);

  Erx # RecRead(450,vSel,_RecFirst);    // Erlöse
  WHILE (Erx <= _rLocked) DO BEGIN

    if (List_mode<>'ReKopf') then begin
      List_mode # '';
      Print('ReKopf');
      List_mode # 'ReKopf';
    end;

    Print('Re');


    // Positions-Erlös loopen ****************************
    Erx # RecLink(451,450,1,_RecFirst);   // Konten loopen
    WHILE (Erx<=_rLocked) do begin
      // keiner Position zugeordnet? -> Überspringen (am Ende drucken)
      if (Erl.K.RechnungsPos=0) or
        (Erl.K.Steuerschl=0) then begin   // 05.08.2016 AH: Holzrichters "Sonderkonten" überspringen
        Erx # RecLink(451,450,1,_RecNext);
        CYCLE;
      end;

      if (List_Mode<>'ErlKopf') then begin
        List_mode # '';
        Print('ErlKopf');
        List_mode # 'ErlKopf';
      end;

      Erx # RecLink(401,451,8,_recFirst); // Aufpos holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(411,451,9,_recFirst); // Auf~pos holen
        if (Erx>_rLocked) then RecBufClear(411);
        RecBufCopy(411,401);
      end;

      // ST 2013-05-08: Warengruppe für Materialtyp lesen
      RekLink(819,401,1,0);

      Print('Erl');

      // VK-Rückstellung vorhanden? ****************************
      RecBufClear(555);
      EKK.Datei # 450;
      EKK.ID1   # Erl.K.Rechnungsnr;
      EKK.ID2   # Erl.K.lfdNr;
      Erx # RecRead(555,1,0);
      WHILE (Erx<=_rLastRec) and(EKK.Datei=450) and (EKK.ID1=Erl.K.Rechnungsnr) and (EKK.ID2=Erl.K.lfdNr) do begin
        Print('VK-RÜCK');
        Erx # RecRead(555,1,_RecNext);
      END;

      Erx # RecLink(451,450,1,_RecNext);
    END;  // Erlöse
    if (List_Mode='ErlKopf') then Print('ErlFuss');



    // Aktionen loopen ************************************
    Erx # RecLink(404,450,4,_recFirst); // Aktionen loopen
    WHILE (Erx<=_rLocked) do begin

      if (Auf.A.Materialnr=0) then begin
        Erx # RecLink(404,450,4,_recNext);
        CYCLE;
      end;

      if (List_Mode<>'MatKopf') then begin
        List_mode # '';
        Print('MatKopf');
        list_mode # 'MatKopf';
      end;

      RecBufClear(200);
      Erx # RecLink(200,404,6,_RecFirst);   // Material holen
      if (Erx<=_rLocked) then begin
        end
      else begin
        Erx # RecLink(210,404,8,_RecFirst); // ~Material holen
        if (Erx>_rLocked) then RecBufClear(210);
        RecBufCopy(210,200);
      end;

      // Aktionsliste aufbauen ****************************
      vTEP # Mat.EK.Preis;
      vAktionTree # CteOpen(_CteList);
      // 22.10.2012 AI
      vDat2 # 31.12.2099;//today;
      vFirst # true;
      REPEAT
        vDat1 # vDat2;
        vDat2 # Mat.Datum.Erzeugt;
        FOR Erx # RecLink(204,200,14,_recFirst)
        LOOP Erx # RecLink(204,200,14,_recNext)
        WHILE (Erx<=_rLocked) do begin

          if (Mat.A.Aktionsdatum=vDat1) and
           ((Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_Mat_Umlage)) then CYCLE;

          if (vFirst=false) and (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) then CYCLE;  // 18.11.2020 AH: Workaround wenn Fahren, dann Spalten

          if (Mat.A.Aktionsdatum<=vDat1) then begin
//debugx(cnvad(mat.a.aktionsdatum)+' <= '+cnvad(vDat1)+'  KEY204');
            if (Mat.A.Kosten2W1<>0.0) then begin
              vTEP # vTEP - Mat.A.Kosten2W1;
              Sort_ItemAdd(vAktionTree, 'x', 204, RecInfo(204,_RecId));
              end
            else if (Mat.A.KostenW1<>0.0) then begin
              Sort_ItemAdd(vAktionTree, 'x', 204, RecInfo(204,_RecId));
            end;
          end
          else begin
          end;
        END;

        If ("Mat.Vorgänger"<>0) then begin
          vFirst # false;
          Erx # Mat_Data:Read("Mat.Vorgänger");
          if (Erx=200) or (Erx=210) then CYCLE;

        end;
      UNTIL (1=1);

      RecBufClear(200);
      Erx # RecLink(200,404,6,_RecFirst);   // Material holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(210,404,8,_RecFirst); // ~Material holen
        if (Erx>_rLocked) then RecBufClear(210);
        RecBufCopy(210,200);
      end;
      Mat.EK.Preis # vTEP;

      Print('Mat');


      // Durchlaufen und löschen
      FOR   vItem # Sort_ItemFirst(vAktionTree)
      loop  vItem # Sort_ItemNext(vAktionTree,vItem)
      WHILE (vItem != 0) do begin
        // Datensatz holen
        vDatei # CnvIA(vItem->spCustom);
        RecRead(vDatei,0,0,vItem->spID);
        if (vDatei=204) then RecBufCopy(204,200);

        Print('Akt');
      END;

      vAktionTree->CteClear(True);
      vAktionTree->CteClose();

      Print('AktFuss');

      Erx # RecLink(404,450,4,_recNext);
    END;  // Aktionen/Material

    if (List_Mode='MatKopf') then begin
      Print('MatFuss');
    end;


    // Kopf-Erlös loopen *********************************
    Erx # RecLink(451,450,1,_RecFirst);   // Konten loopen
    WHILE (Erx<=_rLocked) do begin
      // einer Position zugeordnet? -> Überspringen (schon am Anfang gedrucken)
      if (Erl.K.RechnungsPos<>0) or
        (Erl.K.Steuerschl=0) then begin   // 05.08.2016 AH: Holzrichters "Sonderkonten" überspringen
        Erx # RecLink(451,450,1,_RecNext);
        CYCLE;
      end;

      if (List_Mode<>'ErlKopf') then begin
        List_mode # '';
        Print('ErlKopf');
        List_mode # 'ErlKopf';
      end;

      Erx # RecLink(401,451,8,_recFirst); // Aufpos holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(411,451,9,_recFirst); // Auf~pos holen
        if (Erx>_rLocked) then RecBufClear(411);
        RecBufCopy(411,401);
      end;

      // ST 2013-05-08: Warengruppe für Materialtyp lesen
      RekLink(819,401,1,0);
      Print('Erl');

      Erx # RecLink(451,450,1,_RecNext);
    END;  // Erlöse


    // Gutschriften vorhanden? *********************************
    Erx # RecLink(451,450,9,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (List_Mode<>'ErlKopf') then begin
        List_mode # '';
        Print('ErlKopf');
        List_mode # 'ErlKopf';
      end;

      Print('VK-GUTS');

      Erx # RecLink(451,450,9,_recNext);;
    END;

    if (List_Mode='ErlKopf') then Print('ErlFuss');


    List_Mode # 'ReKopf';
    Print('ReFuss');
    List_Mode # '';

    StartLine();
    EndLine();
    Erx # RecRead(450,vSel,_RecNext);
  END;


  SelClose(vSel);
  vSel # 0;
  SelDelete(450,vSelName);

  Print('ListenFuss');

  List_Mode # '';
  StartLine();
  EndLine();

  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);
end;

//========================================================================