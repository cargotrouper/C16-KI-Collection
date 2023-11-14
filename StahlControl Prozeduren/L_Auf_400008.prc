@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400008
//                    OHNE E_R_G
//  Info        Bestandsliste
//
//
//  05.03.2007  AI  Erstellung der Prozedur
//  31.07.2008  DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile : 411
  cSel  : 'LST.400008'
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.Auf.bis.WTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.AufArt    # 999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.bis.DruckDat  # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.LiefDat   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.ZTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Kostenst  # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;
  Sel.Auf.von.Obfzusat  # 'zzzzz';
  "Sel.Mat.bis.Zugfest" # 9999.0;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Lst.400008',here+':AusSel');
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
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd(Translate('Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Auftragsnr.'));
  vHdl2->WinLstDatLineAdd(Translate('Bestellnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Kunden-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Qualität * Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Wunschtermin'));
  vHdl2->WinLstDatLineAdd(Translate('Zusagetermin'));
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
  vSort # gSelected;
  gSelected # 0;

  StartList(vSort,vSortname);  // Liste generieren
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

    List_Spacing[ 1]  # 0.0;
    List_Spacing[ 2]  # List_Spacing[ 1]  +  20.0;
    List_Spacing[ 3]  # List_Spacing[ 2]  +  2.0;
    List_Spacing[ 4]  # List_Spacing[ 3]  +  8.0;
    List_Spacing[ 5]  # List_Spacing[ 4]  +  25.0;
    List_Spacing[ 6]  # List_Spacing[ 5]  +  7.0;
    List_Spacing[ 7]  # List_Spacing[ 6]  +  25.0;
    List_Spacing[ 8]  # List_Spacing[ 7]  +  20.0;
    List_Spacing[ 9]  # List_Spacing[ 8]  +   2.0;
    List_Spacing[10]  # List_Spacing[ 9]  +   8.0;
    List_Spacing[11]  # List_Spacing[ 10] +  25.0;
    List_Spacing[12]  # List_Spacing[ 11] +   7.0;
    List_Spacing[13]  # List_Spacing[ 12] +   25.0;
    List_Spacing[14]  # List_Spacing[ 13] +   20.0;
    List_Spacing[15]  # List_Spacing[ 14] +   2.0;
    List_Spacing[16]  # List_Spacing[ 15] +   8.0;
    List_Spacing[17]  # List_Spacing[ 16] +  25.0;
    List_Spacing[18]  # List_Spacing[ 17] +  7.0;
    List_Spacing[19]  # List_Spacing[ 18] +  25.0;
    StartLine();
    Write( 1, 'AuftragsNr'                                       ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlI(Sel.Auf.von.Nummer)                          ,Y , _LF_INT, 3.0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlI(Sel.Auf.bis.Nummer)                          ,y , _LF_INT, 3.0);
    Write(7, 'Datum'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, Cnvad(Sel.Auf.von.Datum)                           ,n , 0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  cnvad(Sel.Auf.bis.Datum)                          ,y , 0, 3.0);
    Write(13, 'Wunsch'                                           ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, Cnvad(Sel.Auf.von.WTermin)                         ,n , 0);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, cnvad(Sel.Auf.bis.WTermin)                         ,y , 0, 3.0);
    EndLine();
    StartLine();
    Write( 1, 'AufArt'                                           ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlI(Sel.Auf.von.AufArt)                          ,y , _LF_INT, 3.0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlI(Sel.Auf.bis.AufArt)                          ,y , _LF_INT, 3.0);
    Write(7, 'Wgr'                                               ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, ZahlI(Sel.Auf.von.Wgr)                             ,y , _LF_INT, 3.0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  ZahlI(Sel.Auf.bis.Wgr)                            ,y , _LF_INT, 3.0);
    Write(13, 'Kundennr'                                         ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(16, ZahlI(Sel.Auf.Kundennr)                            ,y , _LF_INT, 3.0);

    EndLine();
    StartLine();
    Write( 1, 'Artikelnr'                                        ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(4, Sel.Auf.Artikelnr                                   ,n , 0);
    Write(7, 'Sachbear.'                                         ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(10, Sel.Auf.Sachbearbeit                               ,n , 0);
    Write(13, 'Vertreternr'                                      ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(16, ZahlI(Sel.Auf.Vertreternr)                         ,y , _LF_INT, 3.0);
    EndLine();
    StartLine();
    Write( 1, 'DruckDat'                                         ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  Cnvad(Sel.Auf.von.DruckDat)                        ,n , 0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  cnvad(Sel.Auf.bis.DruckDat)                        ,y , 0, 3.0);
    Write(7, 'LiefDat'                                           ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, Cnvad(Sel.Auf.von.LiefDat)                         ,n , 0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  cnvad(Sel.Auf.bis.LiefDat)                        ,y , 0, 3.0);
    Write(13, 'Projekt'                                          ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, ZahlI(Sel.Auf.von.Projekt)                         ,y , _LF_INT, 3.0);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, ZahlI(Sel.Auf.bis.Projekt)                         ,y , _LF_INT, 3.0);
    EndLine();
    StartLine();
    Write( 1, 'Kostenst'                                         ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlI(Sel.Auf.von.Kostenst)                        ,Y , _LF_INT, 3.0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlI(Sel.Auf.bis.Kostenst)                        ,y , _LF_INT, 3.0);
    Write(7, 'Dicke'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, ZahlF(Sel.Auf.von.Dicke,2)                         ,y , _LF_NUM, 3.0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  ZahlF(Sel.Auf.bis.Dicke,2)                        ,y , _LF_NUM, 3.0);
    Write(13, 'Breite'                                           ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, ZahlF(Sel.Auf.von.Breite,2)                        ,Y , _LF_NUM, 3.0);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, ZahlF(Sel.Auf.bis.Breite,2)                        ,y , _LF_NUM, 3.0);
    EndLine();
    StartLine();
    Write( 1, 'Länge'                                            ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlF("Sel.Auf.von.Länge",2)                       ,Y , _LF_NUM, 3.0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlF("Sel.Auf.bis.Länge",2)                       ,y , _LF_NUM, 3.0);
    Write(7, 'Güte'                                              ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(10, "Sel.Auf.Güte"                                     ,n , 0);
    Write(13, 'ObfNr'                                            ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, ZahlI(Sel.Auf.ObfNr)                               ,Y , _LF_INT, 3.0);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, ZahlI(Sel.Auf.ObfNr2)                               ,Y , _LF_INT, 3.0);
    EndLine();
    StartLine();
    Write( 1, 'ObfZusat'                                         ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  Sel.Auf.von.ObfZusat                               ,n , 0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  Sel.Auf.bis.ObfZusat                               ,y , 0, 3.0);
    Write(7, 'Zusage Termin'                                     ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, Cnvad(Sel.Auf.von.ZTermin)                         ,n , 0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12, cnvad(Sel.Auf.bis.ZTermin)                         ,y , 0, 3.0);
    EndLine();
    StartLine();
    EndLine();
    StartLine();
    EndLine();
  end;


  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 22.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 25.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 11.4;
  List_Spacing[ 5]  # List_Spacing[ 4] + 20.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 17.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 19.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 15.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 14.0;

  List_Spacing[10]  # List_Spacing[ 9] + 45.0; // 25
  List_Spacing[11]  # List_Spacing[ 10] + 25.0;
  List_Spacing[12]  # List_Spacing[ 11] + 22.0;
  List_Spacing[13]  # List_Spacing[ 12] + 20.0; // 20

  List_Spacing[14]  # List_Spacing[ 13] + 26.0; // 27 // 50 // 45

  List_Spacing[15]  # List_Spacing[ 14] + 18.0; // 20 //18 // 10
  List_Spacing[16]  # List_Spacing[ 15] + 10.0;
  List_Spacing[17]  # List_Spacing[ 16] + 0.0;  // 20
  List_Spacing[18]  # List_Spacing[ 17] + 10.0;
  List_Spacing[19]  # List_Spacing[ 18] + 10.0;
  List_Spacing[20]  # List_Spacing[ 19] + 10.0;
  List_Spacing[21]  # List_Spacing[ 11] + 10.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Auftrgsnr.'                               ,n , 0);
  Write(2,  'Stichwort'                                ,n , 0);
  Write(3,  'Wgr.'                                     ,y , 0, 2.0);
  Write(4,  'Qualität'                                 ,n , 0);
  Write(5,  'Dicke'                                    ,y , 0, 2.0);
  Write(6,  'Breite'                                   ,y , 0, 2.0);
  Write(7,  'Länge'                                    ,y , 0, 2.0);
  Write(8,  'Stück'                                    ,y , 0, 2.0);

  if (list_xml=true) then begin
    Write(9,  'VSB'                                      ,y , 0);
    Write(10, 'In Ausl.'                                 ,y , 0);
    Write(11, 'Geliefert'                                ,y , 0);
    Write(12, 'Berechnet'                                ,y , 0);
    Write(13, 'Strukt.-/Artnr'                           ,n , 0); // y
    Write(14, 'Aufmng kg'                                ,y , 0);
    Write(15, 'E-Preis '+ "Set.Hauswährung.Kurz"         ,y , 0);
    Write(16, 'Preisst.'                                 ,y , 0);
    // Write(17, 'Gesamt '+ "Set.Hauswährung.Kurz"          ,y , 0);
    Write(18, 'Termin'                                   ,y , 0);
  end else begin
    Write(9,  'Strukt.-/Artnr'                             ,n , 0); //y
    Write(10, 'Aufmng kg'                              ,y , 0);
    Write(11, 'E-Preis '+ "Set.Hauswährung.Kurz"         ,y , 0);
    Write(12, 'Preisst.'                                 ,y , 0);
    //Write(13, 'Gesamt '+ "Set.Hauswährung.Kurz"          ,y , 0, 7.0);
    Write(13, 'Termin'                                   ,y , 0,2.0);
  end;


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
local begin
  Erx       : int;
  vEinzel   : float;
  vGesamt   : float;
  vMenge    : float;
end;
begin

  case aName of

    'Position' : begin
      Erx # RecLink(410,411,3,_recFirst);   // Kopf holen
      Erx # RecLink(814,410,8,_recFirst);   // Währung holen
      if ("Auf~WährungFixYN") then Wae.VK.Kurs # "Auf~Währungskurs";

      vMenge  # Lib_Einheiten:WandleMEH(411, "Auf~P.Stückzahl", "Auf~P.Gewicht", "Auf~P.Gewicht", 'kg'/*Auf.P.MEH.Wunsch*/, Auf.P.MEH.Preis);
//Rest?      vMenge  # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.Rest.Stk, Auf.P.Prd.Rest.Gew, Auf.P.Prd.Rest, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis);
      vGesamt # Rnd(("Auf~P.Grundpreis"+"Auf~P.Aufpreis") *  vMenge / CnvFI("Auf~P.PEH") ,2);
      vEinzel # "Auf~P.Einzelpreis";

      vEinzel # Rnd(vEinzel / "Wae.VK.Kurs",2)
      vGesamt # Rnd(vGesamt / "Wae.VK.Kurs",2)

      StartLine();
      Write(1, ZahlI("Auf~P.Nummer") +'/ '+ ZahlI("Auf~P.Position")   ,n , 0);
      Write(2, StrCut("Auf~P.KundenSW",0,10)                                     ,n , 0);
      Write(3, ZahlI("Auf~P.Warengruppe")                           ,y , _LF_INT, 2.0);
      Write(4, "Auf~P.Güte"                                       ,n , 0);
      Write(5, ZahlF("Auf~P.Dicke",Set.Stellen.Dicke)               ,y , _LF_NUM, 2.0);
      Write(6, ZahlF("Auf~P.Breite",Set.Stellen.Breite)             ,y , _LF_NUM, 2.0);
      Write(7, ZahlF("Auf~P.Länge","Set.Stellen.Länge")           ,y , _LF_NUM, 2.0);
      Write(8, ZahlI("Auf~P.Stückzahl")                           ,y , _LF_INT, 2.0);

      if (list_xml=true) then begin
        Write(9,ZahlF("Auf~P.Prd.VSB.Gew",0)                            ,y , _LF_INT);
        Write(10,ZahlF("Auf~P.Prd.VSAuf.Gew",0)                         ,y , _LF_INT, 2.0);
        Write(11,ZahlF("Auf~P.Prd.LFS.Gew",0)                           ,y , _LF_INT);
        Write(12,ZahlF("Auf~P.Prd.Rech.Gew",0)                          ,y , _LF_INT, 2.0);

        /* mögliche:
        Auf.P.Prd.Plan.Gew
        Auf.P.Prd.VSB.Gew
        Auf.P.Prd.VSAuf.Gew
        Auf.P.Prd.LFS.Gew
        Auf.P.Prd.Rech.Gew
        Auf.P.Prd.Rest.Gew
        */

        // Write(13, ZahlF("Auf~P.Prd.Rest.Gew",0)                       ,y , _LF_NUM, 2.0);

        If "Auf~P.Artikelnr" <> '' then
        Write(13, "Auf~P.Artikelnr"                       ,n)
        Else
        Write(13, "Auf~P.Strukturnr"                      ,n);


        Write(14, ZahlF("Auf~P.Gewicht",0)                       ,y , _LF_NUM, 2.0);
        Write(15, ZahlF(vEinzel,2)                                  ,y , _LF_WAE, 2.0);
        if ("Auf~P.PEH"=1) then
          Write(16, "Auf~P.MEH.Preis"                                 ,y , 0, 2.0);
        else
          Write(16, AInt("Auf~P.PEH") + ' ' + "Auf~P.MEH.Preis"        ,y , 0, 2.0);
        Write(17,ZahlF(vGesamt,2)                                   ,y , _LF_WAE, 7.0);
        Write(18, cnvad("Auf~P.Termin1Wunsch")                        ,y , 0, 2.0);

        end
      else begin

        If "Auf~P.Artikelnr" <> '' then
        Write(9, "Auf~P.Artikelnr"                       ,n)
        Else
        Write(9, "Auf~P.Strukturnr"                      ,n);

        // Write(9, ZahlF("Auf~P.Prd.Rest.Gew",0)                       ,y , _LF_NUM);
        Write(10, ZahlF("Auf~P.Gewicht",0)                       ,y , _LF_NUM);
        Write(11, ZahlF(vEinzel,2)                                  ,y , _LF_WAE);
        if ("Auf~P.PEH"=1) then
          Write(12, "Auf~P.MEH.Preis"                                 ,y , 0);
        else
          Write(12, AInt("Auf~P.PEH") + ' ' + "Auf~P.MEH.Preis"        ,y , 0);
          //Write(13,ANum(vGesamt,2)                                   ,y , _LF_WAE, 7.0);
        Write(13, cnvad("Auf~P.Termin1Wunsch")                        ,y , 0,2.0);
      end;

      EndLine();

      // AddSum(1,"Auf~P.Prd.Rest.Gew");
      AddSum(2,"Auf~P.Gewicht");

      // AddSum(3,vGesamt);

    end;


  'Summe' : begin
    StartLine(_LF_Overline);
    if (list_xml=true) then begin
      // Write(13, ZahlF(GetSum(1),0)                       ,y , _LF_NUM, 2.0);
      Write(14, ZahlF(GetSum(2),0)                       ,y , _LF_NUM, 2.0);
      // Write(17, ZahlF(GetSum(3),2)                       ,y , _LF_WAE, 7.0);
    end
    else begin
      // Write(9, ZahlF(GetSum(1),0)                       ,y , _LF_NUM);
      Write(10, ZahlF(GetSum(2),0)                       ,y , _LF_NUM);
      // Write(13, ZahlF(GetSum(3),2)                      ,y , _LF_WAE,7.0);
    end;
    EndLine();

  end;


  end; // CASE

end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  tErx        : int;
end;
begin

  // Sortierung setzen ------------------------------------------------------
  if (aSort=1) then   vKey # 5;   // Abmessung
  if (aSort=2) then   vKey # 1;   // Auftragsnr.
  if (aSort=3) then   vKey # 9;   // Bestellnr
  if (aSort=4) then   vKey # 3;   // Kunden-SW
  if (aSort=5) then   vKey # 4;   // Quali+Abm
  if (aSort=6) then   vKey # 8;   // Wunschterm
  if (aSort=7) then   vKey # 10;  // Zusageterm

  // BESTAND-Selektion öffnen
  // Selektionsquery für 411


  vQ # '';
  Lib_Sel:QInt( var vQ, '"Auf~P.Nummer"', '<', 1000000000 );

  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Auf~P.Nummer"', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );

  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != DateMake(31,12,DateYear(today)) ) then
    Lib_Sel:QVonBisD( var vQ, '"Auf~P.TerminZusage"', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );

  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != DateMake(31,12,DateYear(today))) then
    Lib_Sel:QVonBisD( var vQ, '"Auf~P.Termin1Wunsch"', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );

  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ, '"Auf~P.Kundennr"', '=', Sel.Auf.Kundennr );

  if ( "Sel.Auf.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Auf~P.Güte"', '=*', "Sel.Auf.Güte" );

  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Auf~P.Dicke"', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );

  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Auf~P.Breite"', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );

  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Auf~P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );

  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );

  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Auf~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );

  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );


  if ( Sel.Auf.Artikelnr != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Auf~P.Artikelnr"', '=', StrCnv(Sel.Auf.Artikelnr,_StrUpper));


  //If "Auf~P.Artikelnr" = '' and "Auf~P.Strukturnr" <> '' then
  //  Lib_Sel:QAlpha( var vQ, '"Auf~P.Strukturnr"', '=', Sel.Auf.Artikelnr );



  Lib_Sel:QInt( var vQ, '"Auf~P.Wgr.Dateinr"', '>=', 200 );
  Lib_Sel:QInt( var vQ, '"Auf~P.Wgr.Dateinr"', '<=', 209 );
  //Lib_Sel:QAlpha( var vQ, '"Auf~P.Löschmarker"', '=', '' );

  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( ( "Auf~P.Zugfestigkeit1" <= Sel.Mat.bis.Zugfest AND "Auf~P.Zugfestigkeit2" >= Sel.Mat.von.Zugfest ) '+
            ' OR  ( "Auf~P.Zugfestigkeit1" = 0.0 AND "Auf~P.Zugfestigkeit2" = 0.0 ) ) '

  // Haken für Positionen
  // Berechenbar
  if ("Sel.Auf.BerechenbYN") then
    Lib_Sel:QAlpha( var vQ, '"Auf~P.Aktionsmarker"', '=', '$' );
  if ("Sel.Auf.!BerechenbYN") then
    Lib_Sel:QAlpha( var vQ, '"Auf~P.Aktionsmarker"', '=', '' );

  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;

  if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 410
  vQ2 # '';
  vQ2 # '("Auf~Vorgangstyp"=''' + c_AUF + ''')';
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ2, '"Auf~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ2, '"Auf~Vertreter"', '=', Sel.Auf.Vertreternr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ2, '"Auf~Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );


  // Haken für Kopfdaten
  // Rahmenauftrag
  if ("Sel.Auf.RahmenYN") then
   vQ2 # vQ2 + ' AND "Auf~LiefervertragYN"';
  // Abrufauftrag
  if ("Sel.Auf.AbrufYN") then
    vQ2 # vQ2 + ' AND "Auf~AbrufYN"';
  // "Normale Aufträge" -> weder Liefer- noch Rahmenauftrag
  if ("Sel.Auf.NormalYN") then
    vQ2 # vQ2 + 'AND NOT("Auf~LiefervertragYN")  AND NOT("Auf~AbrufYN")';


  // Selektionsquery für 402
  vQ3 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
    Lib_Sel:QVonBisI( var vQ3, '"Auf.AF.ObfNr"', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );



  // dynamische Sortierung? -> RAMBAUM aufbauen
  if (vKey=0) then begin
    vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
    // Selektion starten...
    vSel # SelCreate( 411, 1 );
    vSel->SelAddLink('', 410, 411, 3, 'Kopf');
    vSel->SelAddLink('', 402, 411, 11, 'Ausf');
    tErx # vSel->SelDefQuery('', vQ );
    if (tErx <> 0) then
      Lib_Sel:QError(vSel);
    tErx # vSel->SelDefQuery('Kopf', vQ2 );
    if (tErx <> 0) then
      Lib_Sel:QError(vSel);
    tErx # vSel->SelDefQuery('Ausf', vQ3 );
    if (tErx <> 0) then
      Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun( var vSel, 0);

    // Selektion öffnen
    //vSelName # Sel_Build(vSel, cFile, cSel,y,0);

    vFlag # _RecFirst;
    WHILE (RecRead(cFile,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      //debug("Auf~P.Artikelnr");
      if (aSort=1) then vSortKey # 'XXXXXXXXXXXX';
      Sort_ItemAdd(vTree,vSortKey,cFIle,RecInfo(cFile,_RecId));
    END;
    end

  else begin    // Schlüssel vorhanden...
    If (Sel.Art.nurMarkeYN) and (N) then begin
      // Selektion starten...
      vSel # SelCreate( 411, vKey );
      vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

      vSel # SelOpen();                       // Selektion öffnen
      vSel->selRead(411,_SelLock,vSelName);   // Selektion laden

      // vSelName # Sel_Build(vSel, cFile, cSel,n,vKey);
      // Ermittelt das erste Element der Liste (oder des Baumes)
      vItem # gMarkList->CteRead(_CteFirst);
      // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
      WHILE (vItem > 0) do begin
        Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
        if (vMFile = cFile) then begin
          RecRead(cFile,0,_RecId,vMID);
          SelRecInsert(vSel,cFile);
        end;
        vItem # gMarkList->CteRead(_CteNext,vItem);
      END;
    end else begin
      // Selektion starten...
      vSel # SelCreate( 411, vKey );
      vSel->SelAddLink('', 410, 411, 3, 'Kopf');
      vSel->SelAddLink('', 402, 411, 11, 'Ausf');
      tErx # vSel->SelDefQuery('', vQ );
      if(tErx <> 0) then
        Lib_Sel:QError(vSel);
      tErx # vSel->SelDefQuery('Kopf', vQ2 );
      if(tErx <> 0) then
        Lib_Sel:QError(vSel);
      tErx # vSel->SelDefQuery('Ausf', vQ3 );
      if(tErx <> 0) then
        Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun( var vSel, 0);

      //vSelName # Sel_Build(vSel, cFile, cSel,y,vKey);
    end;
  end;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Ausgabe ----------------------------------------------------------------

  ListInit(y);    // starte Landscape

  // Schlüssel vorhanden?
  if (vKey<>0) then begin
    vFlag # _RecFirst;

    WHILE (RecRead(cFile,vSel,vFlag) <= _rLocked ) DO BEGIN

      if (vFlag=_RecFirst) then vFlag # _RecNext;

      Print('Position');
    END;

    end

  else begin  // RAMBAUM
    //debug('C '+cnvai("Auf~P.Nummer")+'/'+cnvai("Auf~P.Position"));
    // Durchlaufen und löschen
    FOR   vItem # Sort_ItemFirst(vTree)
    loop  vItem # Sort_ItemNext(vTree,vItem)
    WHILE (vItem != 0) do begin
      // Datensatz holen
      RecRead(cFile,0,0,vItem->spID);

      Print('Position');
    END;
    // Löschen der Liste
    Sort_KillList(vTree);
  end;

  Print('Summe');

  ListTerm();
  SelDelete(cFile, vSelName);

end;

//========================================================================