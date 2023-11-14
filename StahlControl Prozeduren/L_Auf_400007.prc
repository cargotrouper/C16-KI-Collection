@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400007
//                    OHNE E_R_G
//  Info        Vorkalkulation eines Auftrages
//
//
//  21.08.2007  AI  Erstellung der Prozedur
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Print(aName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);

define begin
  cSumPos     : 1
  cSumAuf     : 2
  cSumZPos    : 3
  cSumKPos    : 4

  cSumVK      : 5

  cPosRabBar  : 6
  cAufRabBar  : 7
end

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  StartList(0,'');  // Liste generieren
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
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aName : alpha);
local begin
  vA          : alpha;
  vMenge      : float;
  vWert       : float;
  vWarenEmpf  : alpha;
end;
begin
  case (aName) of

    'Titel' : begin
      RecLink(816,400,6,_recFirst);   // Zahlungsbed holen
      vWarenempf # '';
      if (Auf.Lieferadresse <> 0) and ((Adr.Nummer <> Auf.Lieferadresse) or
        ((Adr.Nummer = Auf.Lieferadresse) and (Auf.Lieferanschrift > 1))) then begin

        // Lieferadresse lesen
        RecLink(100,400,12,_RecFirst);
        vWarenempf #  StrAdj(Adr.Anrede,_StrBegin | _StrEnd)    + ' ' +
                      StrAdj(Adr.Name,_StrBegin | _StrEnd)      + ' ' +
                      StrAdj(Adr.Zusatz,_StrBegin | _StrEnd)    + ', '+
                      StrAdj("Adr.Straße",_StrBegin | _StrEnd)  + ', '+
                      StrAdj(Adr.LKZ,_StrBegin | _StrEnd)       + '-' +
                      StrAdj(Adr.PLZ,_StrBegin | _StrEnd)       + ' ' +
                      StrAdj(Adr.Ort,_StrBegin | _StrEnd);
        // ggf. Anschrift lesen
        if (Auf.Lieferanschrift <> 0) then begin
          Adr.A.Adressnr  # Auf.Lieferadresse;
          Adr.A.Nummer    # Auf.Lieferanschrift;
          RecRead(101,1,0);
          vWarenempf  # StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd)  + ' ' +
                        StrAdj(Adr.A.Name,_StrBegin | _StrEnd)    + ' ' +
                        StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)  + ', '+
                        StrAdj("Adr.A.Straße",_StrBegin | _StrEnd)+ ', '+
                        StrAdj(Adr.A.LKZ,_StrBegin | _StrEnd)     + '-' +
                        StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd)     + ' ' +
                        StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
        end;

        // Leerzeichen am Anfang entfernen
        vWarenempf # StrAdj(vWarenempf, _StrBegin | _StrEnd);
      end;

      StartLine(_LF_Bold);
      Write(1 ,'Auftrag: '+AInt(Auf.Nummer)   ,n,0);
      EndLine();
      StartLine();
      Write(1 ,'Kunde: '+Auf.P.KundenSW     ,n,0);
      EndLine();
      StartLine();
      Write(1 ,'Lieferung: '+vWarenempf   ,n,0);
      EndLine();
      StartLine();
      Write(1 ,'Zahlung: '+ZaB.Bezeichnung1.L1+' '+ZaB.Bezeichnung2.L1 ,n,0);
      EndLine();
      StartLine();
      EndLine();
    end;  // Titel

    'Header' : begin
      StartLine(_LF_Bold + _LF_UnderLine);
      Write(1,'Güte/Artikel'                      ,n,0);
      Write(2,'Bezeichnung'                       ,n,0);
      Write(3,'Menge'                             ,y,0);
      Write(4,'E-Preis '+"Set.Hauswährung.Kurz"   ,y,0);
      Write(5,'PEH'                               ,y,0);
      Write(6,'Summe '+"Set.Hauswährung.Kurz"     ,y,0);
      EndLine();
    end;  // Header

    'Pos' : begin
      StartLine();
      Write(1,'Pos.'+ZahlI(Auf.P.Position)        ,n,0);
      EndLine();

      // Material?
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin

        vMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis);
        vWert #  Rnd(Auf.P.Grundpreis * vMenge / CnvFI(Auf.P.PEH),2);

        vA # '';
        if (Auf.P.Dicke<>0.0) then begin
          vA # vA + ANum(Auf.P.Dicke,Set.Stellen.Dicke);
          if (Auf.P.Breite<>0.0) then begin
            vA # vA + ' x '+ANum(Auf.P.Breite,Set.Stellen.Breite);
            if ("Auf.P.Länge"<>0.0) then vA # vA + ' x ' + ANum("Auf.P.Länge","Set.Stellen.Länge");
          end;
          vA # vA + ' mm';
        end;

        StartLine();
        Write(1,"Auf.P.Güte"                                          ,n,0);
        Write(2,vA                                                    ,n,0);
        Write(3,ZahlF(vMenge,Set.Stellen.Menge)+' '+Auf.P.MEH.Wunsch  ,y,0);
        Write(4,ZahlF(Auf.P.GrundPreis,2)                             ,y,0);
        Write(5,ZahlI(Auf.P.PEH)+' '+Auf.P.MEH.Preis                  ,y,0);
        Write(6,ZahlF(vWert,2)                                        ,y,0);
        EndLine();

        AddSum(cSumZPos,vWert);
        AddSum(cPosRabBar,vWert);
        AddSum(cAufRabBar,vWert);
      end;  // Material
    end;  // Pos

    'PosZ' : begin
      vMenge # Auf.Z.Menge;
      if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%')  then begin
        vMenge # Lib_Einheiten:WandleMEH(403, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.Z.MEH);
      end;
      if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
        if (Auf.Z.Position=0) then
          Auf.Z.Preis # Getsum(cAufRabbar)
        else
          Auf.Z.Preis # Getsum(cPosRabbar);
      end;
      vWert  #  Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      StartLine();
      if (Auf.Z.Position=0) then
        Write(1,'Kopfaufpreis'                                ,n,0)
      else
        Write(1,'Aufpreis'                                    ,n,0);
      Write(2,Auf.Z.Bezeichnung                               ,n,0);
      Write(3,ZahlF(vMenge,Set.Stellen.Menge)+' '+Auf.Z.MEH   ,y,0);
      Write(4,ZahlF(Auf.Z.Preis     ,2)                       ,y,0);
      Write(5,ZahlI(Auf.Z.PEH)+' '+Auf.Z.MEH                  ,y,0);
      Write(6,ZahlF(vWert,2)                                  ,y,0);
      EndLine();

      AddSum(cSumZPos,vWert);
      if (Auf.Z.RabattierbarYN) then begin
        AddSum(cPosRabbar, vWert);
        AddSum(cAufRabbar, vWert);
      end;
    end;  // PosZ

    'ZSum' : begin
      vWert # GetSum(cSumZPos);
      ResetSum(cSumZPos);
      StartLine();
      Write(1,'Sum.Aufpreise'                               ,n,0);
      Write(6,ZahlF(vWert,2)                                ,y,0);
      EndLine();
      StartLine();
      EndLine();
      AddSum(cSumPos,vWert);
      AddSum(cSumVK ,vWert);
    end;  // PosSum


    'PosK' : begin
      vMenge # Auf.K.Menge;
      if (Auf.K.MengenbezugYN) and (Auf.K.MEH<>'%')  then begin
        vMenge # Lib_Einheiten:WandleMEH(403, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.K.MEH);
      end;
      if (Auf.K.MengenbezugYN) and (Auf.K.MEH='%') then begin
        Auf.K.Preis # GetSum(cSumPos);
      end;
      vWert  #  Rnd(Auf.K.Preis * vMenge / CnvFI(Auf.K.PEH),2);
      StartLine();
      Write(1,'Kalkulation'                                   ,n,0)
      Write(2,Auf.K.Bezeichnung                               ,n,0);
      Write(3,ZahlF(vMenge,Set.Stellen.Menge)+' '+Auf.K.MEH   ,y,0);
      Write(4,ZahlF(Auf.K.Preis     ,2)                       ,y,0);
      Write(5,ZahlI(Auf.K.PEH)+' '+Auf.K.MEH                  ,y,0);
      Write(6,ZahlF(vWert,2)                                  ,y,0);
      AddSum(cSumKPos,vWert);
      EndLine();
    end;  // PosK

    'KSum' : begin
      vWert # GetSum(cSumKPos);
      ResetSum(cSumKPos);
      StartLine();
      Write(1,'Sum.Kalk.'                                   ,n,0);
      Write(6,ZahlF(vWert,2)                                ,y,0);
      EndLine();
      StartLine();
      EndLine();

      AddSum(cSumPos,-1.0 * vWert);
    end;  // PosSum



    'PosSum' : begin
      vWert # GetSum(cSumPos);
      ResetSum(cSumPos);
      StartLine();
      Write(1,'Sum.Pos.'                                    ,n,0);
      Write(6,ZahlF(vWert,2)                                ,y,0);
      EndLine();
      StartLine();
      EndLine();

      AddSum(cSumAuf,vWert);
    end;  // PosSum


    'Skonto' : begin
      vMenge  # GetSum(cSumVK);
      OfP.Skontoprozent # -1.0 * OfP.Skontoprozent;
      vWert   # vMenge * OfP.Skontoprozent / 100.0;
      StartLine();
      Write(1,'Skonto'                                        ,n,0);
      Write(3,ZahlF(OfP.Skontoprozent,2)+' %'                 ,y,0);
      Write(4,ZahlF(vMenge ,2)                                ,y,0);
      Write(5,'100 %'                                         ,y,0);
      Write(6,ZahlF(vWert,2)                                  ,y,0);
      EndLine();
      StartLine();
      EndLine();

      AddSum(cSumAuf,vWert);
    end;  // PosSum


    'AufSum' : begin
      vWert # GetSum(2);
      StartLine();
      Write(1,'Auftrag Gesamt'                              ,n,0);
      Write(6,ZahlF(vWert,2)                                ,y,0);
      EndLine();
    end;  // AufSum

  end;  // case

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
    List_Spacing[ 1]  # 0.0;
    List_Spacing[ 2]  # 180.0;
    Print('Titel');
    List_Spacing[ 1]  # 0.0;
    List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;  // Güte
    List_Spacing[ 3]  # List_Spacing[ 2] + 60.0;  // Bezeichnung
    List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;  // Menge
    List_Spacing[ 5]  # List_Spacing[ 4] + 25.0;  // E-Preis
    List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;  // PEH
    List_Spacing[ 7]  # List_Spacing[ 6] + 30.0;  // Summe
  end;

  Print('Header');
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
end;
begin

  RecLink(400,401,3,_recfirst)    // Kopf holen

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);    // starte Landscape

  Erx # RecLink(401,400,9,_recFirst);     // Positionen loopen
  WHILE (Erx <= _rLocked ) DO BEGIN

    Print('Pos');

//    Reihenfolge:
//      1. Grundpreis
//      2. + mengenbezogene Positionsaufpreise
//      3. + pauschale (nicht mengenbezogen) Positionsaufpreise
//      4. + prozentuale Positionsaufpreise
//      5. + mengenbezogene Kopfaufpreise
//      -> Positionssumme
//      6. + pauschale Kopfaufpreise
//      7. + prozentuale Kopfaufpreise
//      -> Endsumme

    Erx # RecLink(403,401,6,_recFirst);   // Aufpreise loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.Z.MEH<>'%') then Print('PosZ');
      Erx # RecLink(403,401,6,_recNext);
    END;
    Erx # RecLink(403,401,6,_recFirst);   // %-Aufpreise loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.Z.MEH='%') then Print('PosZ');
      Erx # RecLink(403,401,6,_recNext);
    END;

    Erx # RecLink(403,400,13,_recFirst);   // allgem.KopfAufpreise loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.Z.MEH<>'%') and (Auf.Z.MengenbezugYN) and (Auf.Z.Position=0) then Print('PosZ');
      Erx # RecLink(403,400,13,_recNext);
    END;

    Print('ZSum');

    // Kalkulationen ****************
    Erx # RecLink(405,401, 7,_recFirst);  // Kalkulationen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.K.MEH<>'%') then Print('PosK');
      Erx # RecLink(405,401,7,_recNext);
    END;
    Erx # RecLink(405,401, 7,_recFirst);  // %-Kalkulationen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.K.MEH='%') then Print('PosK');
      Erx # RecLink(405,401,7,_recNext);
    END;
    Print('KSum');

    Print('PosSum');

    Erx # RecLink(401,400,9,_recNext);
  END;  // Positionen



  // Kopfaufpreise ****************
  Erx # RecLink(403,400,13,_recFirst);   // fixe KopfAufpreise loopen
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.MEH<>'%') and (Auf.Z.MengenbezugYN=n) and (Auf.Z.Position=0) then Print('PosZ');
    Erx # RecLink(403,400,13,_recNext);
  END;
  Erx # RecLink(403,400,13,_recFirst);   // % KopfAufpreise loopen
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.MEH='%') and (Auf.Z.Position=0) then Print('PosZ');
    Erx # RecLink(403,400,13,_recNext);
  END;

  // Zahlungsbedingungen berechnen
  Erx # RekLink(816,400,6,_recFirst);         // Zahlungsbed holen
  OfP_Data:BerechneZieldaten( today , true);  // Lieferdatum = heute
  if (OfP.Skontoprozent != 0.0) then begin
    Print('Skonto');
  end;

//  Addsum(cSumAuf, GetSum(cSumZPos));
  Print('AufSum');

  ListTerm(); // Ende der Liste
end;

//========================================================================