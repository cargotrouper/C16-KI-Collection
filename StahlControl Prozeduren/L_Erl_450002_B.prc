@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450002
//
//  Info        Nachkalkulation Material
//
//
//  24.07.2007  AI  Erstellung der Prozedur
//  15.04.2010  AI  Beachtung des Datums bei Vorgängeraktionen
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_List

define begin
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
end;

declare StartList(aSort : int; aSortName : alpha);

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
          vA #  ZahlF(Auf.P.Dicke,  Set.Stellen.Dicke) + ' x '+
                ZahlF(Auf.P.Breite, Set.Stellen.Breite);
          if ("Auf.P.Länge"<>0.0) then
            vA # vA + ' x '+ZahlF("Auf.P.Länge", "Set.Stellen.Länge");
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
      if (Erl.K.BetragW1<0.0) then
        vA # 'Gutschrift';//Erl.K.Bemerkung
      else
        vA # 'Belastung';
      vKG # 0.0;
      Write(10,vA                                ,n, 0, 2.0);

      // Rücknahme??
      if (Erl.K.EKPReisSummeW1<>0.0) or (Erl.K.Gewicht<>0.0) or ("Erl.K.Stückzahl"<>0) then begin
        Write(13, ZahlF(Erl.K.Gewicht,Set.Stellen.Gewicht)    ,y , _LF_Num);
        Write(18, ZahlF(Erl.K.EKPreisSummeW1, 2)              ,y , _LF_Wae);
        AddSum(c_sumReKG,Erl.K.Gewicht);
        AddSum(c_SumReEK, Erl.K.EKPReisSummeW1);
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
      vKG # Auf.A.Gewicht;
      vP1 # Mat.A.Kosten2W1 * vKG/1000.0;
      vP2 # Mat.A.KostenW1  * vKG/1000.0;
      StartLine();
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

  Erg # RecRead(450,vSel,_RecFirst);    // Erlöse
  WHILE (Erg <= _rLocked) DO BEGIN

    if (List_mode<>'ReKopf') then begin
      List_mode # '';
      Print('ReKopf');
      List_mode # 'ReKopf';
    end;

    Print('Re');


    // Positions-Erlös loopen ****************************

    Erg # RecLink(451,450,1,_RecFirst);   // Konten loopen
    WHILE (erg<=_rLocked) do begin
      // keiner Position zugeordnet? -> Überspringen (am Ende drucken)
      if (Erl.K.RechnungsPos=0) then begin
        Erg # RecLink(451,450,1,_RecNext);
        CYCLE;
      end;

      if (List_Mode<>'ErlKopf') then begin
        List_mode # '';
        Print('ErlKopf');
        List_mode # 'ErlKopf';
      end;

      Erg # RecLink(401,451,8,_recFirst); // Aufpos holen
      if (erg>_rLocked) then begin
        Erg # RecLink(411,451,9,_recFirst); // Auf~pos holen
        if (erg>_rLocked) then RecBufClear(411);
        RecBufCopy(411,401);
      end;

      Print('Erl');

      // VK-Rückstellung vorhanden? ****************************
      RecBufClear(555);
      EKK.Datei # 450;
      EKK.ID1   # Erl.K.Rechnungsnr;
      EKK.ID2   # Erl.K.lfdNr;
      Erg # RecRead(555,1,0);
      WHILE (erg<=_rLastRec) and(EKK.Datei=450) and (EKK.ID1=Erl.K.Rechnungsnr) and (EKK.ID2=Erl.K.lfdNr) do begin
        Print('VK-RÜCK');
        Erg # RecRead(555,1,_RecNext);
      END;

      Erg # RecLink(451,450,1,_RecNext);
    END;  // Erlöse
    if (List_Mode='ErlKopf') then Print('ErlFuss');



    // Aktionen loopen ************************************
    Erg # RecLink(404,450,4,_recFirst); // Aktionen loopen
    WHILE (erg<=_rLocked) do begin

      if (Auf.A.Materialnr=0) then begin
        Erg # RecLink(404,450,4,_recNext);
        CYCLE;
      end;

      if (List_Mode<>'MatKopf') then begin
        List_mode # '';
        Print('MatKopf');
        list_mode # 'MatKopf';
      end;

      RecBufClear(200);
      Erg # RecLink(200,404,6,_RecFirst);   // Material holen
      if (erg<=_rLocked) then begin
        end
      else begin
        Erg # RecLink(210,404,8,_RecFirst); // ~Material holen
        if (erg>_rLocked) then RecBufClear(210);
        RecBufCopy(210,200);
      end;

      // Aktionsliste aufbauen ****************************
      vTEP # Mat.EK.Preis;
      vAktionTree # CteOpen(_CteList);
      vDat2 # today;
      REPEAT
        vDat1 # vDat2;
        vDat2 # Mat.Datum.Erzeugt;
        Erg # RecLink(204,200,14,_recFirst);
        WHILE (erg<=_rLocked) do begin
          if (Mat.A.Aktionsdatum<=vDat1) then begin
            if (Mat.A.Kosten2W1<>0.0) then begin
              vTEP # vTEP - Mat.A.Kosten2W1;
              Sort_ItemAdd(vAktionTree, 'x', 204, RecInfo(204,_RecId));
              end
            else if (Mat.A.KostenW1<>0.0) then begin
              Sort_ItemAdd(vAktionTree, 'x', 204, RecInfo(204,_RecId));
            end;
          end;
          Erg # RecLink(204,200,14,_recNext);
        END;

        If ("Mat.Vorgänger"<>0) then begin
          Erg # Mat_Data:Read("Mat.Vorgänger");
          if (erg=200) or (Erg=210) then CYCLE;
        end;

      UNTIL (1=1);

      RecBufClear(200);
      Erg # RecLink(200,404,6,_RecFirst);   // Material holen
      if (erg>_rLocked) then begin
        Erg # RecLink(210,404,8,_RecFirst); // ~Material holen
        if (erg>_rLocked) then RecBufClear(210);
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

      Erg # RecLink(404,450,4,_recNext);
    END;  // Aktionen/Material

    if (List_Mode='MatKopf') then begin
      Print('MatFuss');
    end;


    // Kopf-Erlös loopen *********************************
    Erg # RecLink(451,450,1,_RecFirst);   // Konten loopen
    WHILE (erg<=_rLocked) do begin
      // einer Position zugeordnet? -> Überspringen (schon am Anfang gedrucken)
      if (Erl.K.RechnungsPos<>0) then begin
        Erg # RecLink(451,450,1,_RecNext);
        CYCLE;
      end;

      if (List_Mode<>'ErlKopf') then begin
        List_mode # '';
        Print('ErlKopf');
        List_mode # 'ErlKopf';
      end;

      Erg # RecLink(401,451,8,_recFirst); // Aufpos holen
      if (erg>_rLocked) then begin
        Erg # RecLink(411,451,9,_recFirst); // Auf~pos holen
        if (erg>_rLocked) then RecBufClear(411);
        RecBufCopy(411,401);
      end;

      Print('Erl');

      Erg # RecLink(451,450,1,_RecNext);
    END;  // Erlöse


    // Gutschriften vorhanden? *********************************
    Erg # RecLink(451,450,9,_recFirst);
    WHILE (Erg<=_rLocked) do begin
      if (List_Mode<>'ErlKopf') then begin
        List_mode # '';
        Print('ErlKopf');
        List_mode # 'ErlKopf';
      end;

      Print('VK-GUTS');

      Erg # RecLink(451,450,9,_recNext);;
    END;

    if (List_Mode='ErlKopf') then Print('ErlFuss');


    List_Mode # 'ReKopf';
    Print('ReFuss');
    List_Mode # '';

    StartLine();
    EndLine();
    Erg # RecRead(450,vSel,_RecNext);
  END;


  SelClose(vSel);
  vSel # 0;
  SelDelete(450,vSelName);

  List_Mode # '';
  StartLine();
  EndLine();

  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);
end;

//========================================================================