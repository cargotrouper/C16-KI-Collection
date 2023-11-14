@A+
//===== Business-Control =================================================
//
//  Prozedur    L_OfP_460005
//                    OHNE E_R_G
//  Info        Offene Posten Kreditlimit
//
//
//  30.10.2008  MS  Erstellung der Prozedur
//  30.10.2008  MS  QUERY
//  03.02.2009  ST  Abstände zwischen Kundennummer und Risikonr. vergrößert
//  2022-06-28  AH  ERX
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
@I:Def_aktionen

define begin
end;

local begin
  gKunde        : alpha;
  gOrt          : alpha;
  gLKZ          : alpha;
  gKundenNr     : int;
  gRisikoNr     : alpha;
  gLimit        : float;
  gUnterdeckung : float;
  glfdNr        : int;
end;


declare StartList(aSort : int; aSortName : alpha);
declare AusSel();


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
  RecBufClear(998);
  /*
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.200518',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
  */
  StartList(vSort,vSortname);  // Liste generieren
end;



//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort : int;
  vSortName : alpha;
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
  vSum  : float;
  vSum2 : float;
  vAbmessung : alpha;

end;
begin

  case aName of

/*
      Write(, ZahlI()                         ,y ,_LF_INT);
      if (<>0.0.0) then
        Write(, DatS()                       ,y ,_LF_Date);
      Write(,ZahlF(,)          ,y ,_LF_Num);
      Write(,ZahlF(Erl.NettoW1,2)                            ,y ,_LF_Wae);
*/

    'MERKE' : begin
      gKunde    # OfP.KundenStichwort
      gOrt      # Adr.Ort
      gLKZ      # Adr.LKZ
      gKundenNr # OfP.Kundennummer
      gRisikoNr # Adr.K.Referenznr
      gLimit    # Adr.K.VersichertW1
    end;


    'POS' : begin
      gUnterdeckung # 0.0;

      StartLine();
      Write(1, ZahlI(glfdNr)      ,y ,_LF_Int);
      Write(2, ZahlI(gKundenNr)   ,y ,_LF_Int);
      Write(3, gRisikoNr          ,y ,0);
      Write(4, gKunde             ,n ,0, 3.0);
      Write(5, gLKZ               ,n ,0);
      Write(6, gOrt               ,n ,0);

      if(GetSum(1)<> 0.0) then
        Write(7, ZahlF(GetSum(1),0) ,y ,_LF_Num);  // Inland (D)

      if(GetSum(2)<> 0.0) then
        Write(8, ZahlF(GetSum(2),0) ,y ,_LF_Num);  // Ausland (!D)

      Write(9, ZahlF(gLimit,0)      ,y ,_LF_Num);

      if(GetSum(1) > gLimit) or (GetSum(2) > gLimit) then begin
        if(gLKZ = 'DE') or (gLKZ = 'D')then
          gUnterdeckung # GetSum(1) - gLimit;
        else
          gUnterdeckung # GetSum(2) - gLimit;
        Write(10, ZahlF(gUnterdeckung,0),y ,_LF_Num);
      end;

      AddSum(5,gUnterdeckung);

      EndLine();

      inc(glfdNr)
    end;

    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      Write(7, ZahlF(GetSum(3),0)  ,y, _LF_Num);  // Inland (D)
      Write(8, ZahlF(GetSum(4),0)  ,y, _LF_Num);  // Ausland (!D)
      Write(10, ZahlF(GetSum(5),0)  ,y, _LF_Num);
      EndLine();
     end; // Summe


    'Leer' : begin
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
  WriteTitel();
  StartLine();
  EndLine();
  if (aSeite=1) then begin
    StartLine();
    EndLine();
  end;

  List_FontSize # 7;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 5.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 15.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 19.0;    // ST: war vorher 15.0-> Überlappung
  List_Spacing[ 5]  # List_Spacing[ 4] + 40.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 10.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 28.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 17.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 17.0;
  List_Spacing[10]  # List_Spacing[ 9] + 17.0;
  List_Spacing[11]  # List_Spacing[10] + 25.0;

  StartLine(_LF_Bold);
  Write(1, 'lfd'            ,y ,0);
  Write(2, 'Kunden'         ,y ,0);
  Write(3, 'Risiko'         ,y ,0);
  Write(4, 'Kunde'          ,n ,0, 3.0);
  Write(5, 'LKZ'            ,n ,0);
  Write(6, 'Ort'            ,n ,0);
  Write(7, 'Obligo IL'      ,y ,0);
  Write(8, 'Obligo AL'      ,y ,0);
  Write(9, 'Limit'          ,y ,0);
  Write(10, 'Unterdeckung'   ,y ,0);
  EndLine();

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Nr.'           ,y ,0);
  Write(2, 'Nr.'           ,y ,0);
  Write(3, 'Nr.'           ,y ,0);
  Write(7, 'EUR'           ,y ,0);
  Write(8, 'EUR'           ,y ,0);
  Write(9, 'EUR'           ,y ,0);
  Write(10, 'EUR'           ,y ,0);
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
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vKey        : int;
  vMFile,vMID : int;
  vItem       : int;
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vPrinted    : logic;
  vFirst      : logic;
  vQ460       : alpha(4000);
  vQ103       : alpha(4000);
  vQ100       : alpha(4000);
  vZahlung    : float;
end;
begin

  // Liste starten
  ListInit(n);  // kein Landscape

  // Selektionsquery
  vQ460 # '';
  vQ103 # '';
  vQ100 # '';

  vQ100 # 'LinkCount(Kreditlimit) > 0';

  Lib_Sel:QAlpha(var vQ103, 'Adr.K.Versicherer', '!=' , '');

  Lib_Sel:QFloat(var vQ460, 'OfP.NettoW1', '!=' , 0.0);
  Lib_Sel:QAlpha(var vQ460, '"OfP.Löschmarker"', '!=', '*');
  vQ460 # vQ460 + ' AND LinkCount(Kunde) > 0';

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(460, 1);
  vSel->SelAddLink('',100,460,4,'Kunde');
  vSel->SelAddLink('Kunde',103,100,14,'Kreditlimit');
  Erx # vSel->SelDefQuery('', vQ460);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kunde', vQ100);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kreditlimit', vQ103);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);


  Erx # RecRead(460,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN // Material loopen

    vSortKey # OfP.KundenStichwort
               + cnvAI(OfP.Kundennummer,_FmtNumLeadZero,0,10);

    Sort_ItemAdd(vTree,vSortKey,460,RecInfo(460,_RecId));
    Erx # RecRead(460,vSel,_recNext);
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(460, vSelName);

  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # y ;
  glfdNr # 1;

  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    List_FontSize # 7;

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    RecLink(100,460,4,0); // Kunde holen
    RecLink(103,100,14,0);// Kreditlimit holen

    if (vFirst = y) then begin
      Print('MERKE');             // Kundendaten merken
      vFirst # n;
    end;


    // KundenNr nicht gleich dann printen
    if (gKundenNr <> OfP.Kundennummer) then begin
      Print('POS');
      ResetSum(1);
      ResetSum(2);
    end


    // Teilzahlungen berücksichtigen
    vZahlung # 0.0;
    Erx # RecLink(450,460,2,0);
    If (Erx <= _rLocked) then begin
      Erx # RecLink(813,450,10,0);
      If Erx > _rLocked then RecBufClear(813);
    End;

    Erx # RecLink(461,460,1,_recFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      vZahlung # (vZahlung + (OfP.Z.BetragW1 / (100.0 + StS.Prozent) * 100.0));
      Erx # RecLink(461,460,1,_recNext);
    END;

    OfP.NettoW1 # (OfP.NettoW1 - vZahlung);

    // Summierung

    // Selbe Pos
    if(Adr.LKZ = 'DE')or (Adr.LKZ = 'D') then
      AddSum(1,OfP.NettoW1);  // Inland (D)
    else
      AddSum(2,OfP.NettoW1);  // Ausland (!D)

    // Gesamt
    if(Adr.LKZ = 'DE') or (Adr.LKZ = 'D')then
      AddSum(3,OfP.NettoW1);  // Inland (D)
    else
      AddSum(4,OfP.NettoW1); // Ausland (!D)



    //Print('200') // zum debuggen

    Print('MERKE');

  END;  // loop

  Print('POS');
  Print('Leer');
  Print('GesamtSumme');



  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================