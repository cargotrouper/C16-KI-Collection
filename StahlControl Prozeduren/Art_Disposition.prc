@A+
//===== Business-Control =================================================
//
//  Prozedur    Art_Disposition
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  04.09.2012  AI  BA ArtPrd eingebaut
//  16.10.2013  AH  Anfragen
//  28.11.2014  AH  VSB-Material wird für Bestelldispo angezogen
//  04.03.2015  AH  "Show" um aDlg erweitert, damit in einem anderen Fenster geangezeigt werden kann
//  21.06.2016  AH  "DispoZum"
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//
//    Sub BuildTree(aTree : int; aBereiche : alpha);
//    Sub Show (aName : alpha; aBereiche : alpha; aMitSumme : logic; aChargen : logic; opt aDlg : int;)
//    Sub EvtLstDataInit
//    Sub BerechneEinenArtikel(var aNeedDat : date ; var aNeedMenge : float);
//    Sub AutoDispo
//    Sub DispoZum(aDat : date; aBereiche : alpha; var aStk  : int; var aM : float) : logic;//
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:def_BAG

local begin
  vSum      : float;
  vSumStk   : int;
  vHdl2     : int;
end;

declare Graph(aDL : int; aMin : float; aMax : float);

//========================================================================
// Eintrag
//
//========================================================================
Sub Eintrag(
  aDat  : date;
  aName : alpha;
  aSW   : alpha;
  aStk  : int;
  aM    : float);
begin
  vSumStk # vSumStk + aStk;
  vSum    # vSum + aM;

  vHDL2->WinLstDatLineAdd(aDat);
  vHDL2->WinLstCellSet(aName,2,_WinLstDatLineLast);
  vHDL2->WinLstCellSet(aSW,3,_WinLstDatLineLast);
  vHDL2->WinLstCellSet(aStk,4,_WinLstDatLineLast);
  vHDL2->WinLstCellSet(aM,5,_WinLstDatLineLast);
  vHDL2->WinLstCellSet(vSumStk,6,_WinLstDatLineLast);
  vHDL2->WinLstCellSet(vSum,7,_WinLstDatLineLast);
end;


//========================================================================
// BuildTree
//
//========================================================================
Sub BuildTree(aTree : int; aBereiche : alpha; aCharge : logic);
local begin
  Erx       : int;
  vX        : int;
  vSortKey  : alpha;      // "Sortierungsschlüssel" der Liste
end;
begin


  RecRead(250,1,0);
  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,0);    // Warengruppe holen


  // Artikel-Ist-Bestand mit einbeziehen?
  if (StrFind(aBereiche,'250',0)<>0) then begin
    vSortKey # '000000';
    Sort_ItemAdd(aTree,vSortKey,250,RecInfo(250,_RecId));
  end;
  // Chargen-Ist-Bestand mit einbeziehen?
  if (StrFind(aBereiche,'252',0)<>0) then begin
    vSortKey # '000000';
    Sort_ItemAdd(aTree,vSortKey,252,RecInfo(252,_RecId));
  end;

  // Aufträge mit einbeziehen?
  if (StrFind(aBereiche,'401',0)<>0) then begin
    Erx # RecLink(401,250,3,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      RecLink(400,401,3,_RecFirsT);         // AufKopf holen
      if ("Auf.P.Löschmarker"='') and (Auf.Vorgangstyp=c_AUF) then begin// and (Auf.P.Wgr.Dateinr<>c_WGR_ArtMatMix) then begin
        Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
        if (Erx>_rLocked) then RecBufClear(835);
        if (AAr.ReservierePosYN) then begin
          if (Auf.LiefervertragYN) then begin
            Auf.P.Termin1Wunsch # "Auf.GültigkeitBis";
          end;
          if (Auf.P.Termin1Wunsch=0.0.0) then Auf.P.Termin1Wunsch # Auf.P.TerminZusage;

          vSortKey # CnvAI(Cnvid(Auf.P.Termin1Wunsch),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
          Sort_ItemAdd(aTree,vSortKey,401,RecInfo(401,_RecId));
        end;
      end;
      Erx # RecLink(401,250,3,_RecNext);
    END;
  end;

  // Auftragsaktionen mit einbeziehen?
  if (StrFind(aBereiche,'404',0)<>0) then begin
    if (aCharge=n) then begin
      Erx # RecLink(404,250,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        vSortKey # CnvAI(Cnvid(Auf.A.Aktionsdatum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
        Sort_ItemAdd(aTree,vSortKey,404,RecInfo(404,_RecId));
        Erx # RecLink(404,250,13,_RecNext);
      END;
      end
    else begin
      Erx # RecLink(404,252,2,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        vSortKey # CnvAI(Cnvid(Auf.A.Aktionsdatum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
        Sort_ItemAdd(aTree,vSortKey,404,RecInfo(404,_RecId));
        Erx # RecLink(404,252,2,_RecNext);
      END;
    end;
  end;

  // Reservierungen mit einbeziehen?
  if (StrFind(aBereiche,'RES',0)<>0) or
    (StrFind(aBereiche,'-RES',0)<>0) then begin
    if (StrFind(aBereiche,'-RES',0)<>0) then vX # 1000
    else vX # 0;
/***/
    if (aCharge=n) then
      Erx # RecLink(404,250,13,_RecFirst)
    else
      Erx # RecLink(404,252,2,_RecFirst);

    WHILE (Erx<=_rLocked) do begin

      if (Auf.A.Menge<>0.0) and ("Auf.A.Löschmarker"<>'*') and
        ((Auf.A.Aktionstyp=c_Akt_VLDAW)) then begin
        Lfs.P.Nummer    # Auf.A.Aktionsnr;
        LFs.P.Position  # Auf.A.Aktionspos;
        Erx # RecRead(441,1,0);
        if (Erx<=_rLocked) then begin
          if (Lfs.P.zuBA.Nummer=0) then begin
            vSortKey # CnvAI(Cnvid(Auf.A.Aktionsdatum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
            Sort_ItemAdd(aTree,vSortKey,vx+404,RecInfo(404,_RecId));
          end;
        end;
      end;

      if (Auf.A.Menge<>0.0) and ("Auf.A.Löschmarker"<>'*') and
        ((Auf.A.Aktionstyp=c_Akt_VSB) or (Auf.A.Aktionstyp=c_Akt_BA_plan) or (Auf.A.Aktionstyp=c_Akt_PRD_Plan)) then begin
        vSortKey # CnvAI(Cnvid(Auf.A.Aktionsdatum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
        Sort_ItemAdd(aTree,vSortKey,vx+404,RecInfo(404,_RecId));
      end;

      if (aCharge=n) then
        Erx # RecLink(404,250,13,_RecNext)
      else
        Erx # RecLink(404,252,2,_RecNext);
    END;
/***/
/*
    Erx # RecLink(251,250,19,_recFirst);      // Reservierungen loopen
    WHILE (Erx<=_rLocked) do begin
      if ("Art.R.Trägertyp"=c_Akt_BAInput) then begin
        Erx # RecLink(701,251,5,_recFirst);   // BAG-Input holen
        if (Erx<=_rLocked) then begin
          Erx # RecLink(702,701,4,_recFirst); // BAG-NachPos holen
          if (Erx<=_rLocked) then begin
            if (BAG.P.Plan.StartDat=0.0.0) then BAG.P.Plan.StartDat # today;
            vSortKey # CnvAI(Cnvid(BAG.P.Plan.StartDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
            Sort_ItemAdd(aTree,vSortKey,vx+404,RecInfo(404,_RecId));
          end;
        end;
      end;
      Erx # RecLink(251,250,19,_recNext);
    END;
*/
  end;


  // AuftragsStückliste mit einbeziehen?
  if (StrFind(aBereiche,'409',0)<>0) then begin
    Erx # RecLink(409,250,7,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RecLink(400,409,1,_recFirsT);     // Kopf holen
      if (Erx<=_rLocked) and (Auf.Vorgangstyp=c_AUF) then begin
        Erx # RecLink(401,409,2,_recFirsT);     // Position holen
        //if (Erx<=_rLocked) and ((Auf.P.Artikeltyp='PRD') or (Auf.P.Wgr.Dateinr=c_WGR_ArtMatMix)) and ("Auf.P.Löschmarker"='') then begin
        if (Erx<=_rLocked) and ("Auf.P.Löschmarker"='') and (Auf.Vorgangstyp=c_AUF) then begin
          Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
          if (Erx>_rLocked) then RecBufClear(835);
          if (AAr.ReserviereSLYN) then begin
            if (Auf.LiefervertragYN) then begin
              Auf.P.Termin1Wunsch # "Auf.GültigkeitBis";
            end;
            if (Auf.P.Termin1Wunsch=0.0.0) then Auf.P.Termin1Wunsch # Auf.P.TerminZusage;
            vSortKey # CnvAI(Cnvid(Auf.P.Termin1Wunsch),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
            Sort_ItemAdd(aTree,vSortKey,409,RecInfo(409,_RecId));
          end;
        end;

      end;
      Erx # RecLink(409,250,7,_RecNext);
    END;
  end;

  // Bestellungen mit einbeziehen?
  if (StrFind(aBereiche,'501',0)<>0) then begin
    FOR Erx # RecLink(501,250,12,_RecFirst)
    LOOP Erx # RecLink(501,250,12,_recNext)
    WHILE (Erx<=_rLocked) do begin

      RekLink(500,501,3,_recFirst); // Kopf holen
      if (EIn.Vorgangstyp<>c_Bestellung) then CYCLE;

      if ("Ein.P.Löschmarker"='') then begin
        if (Ein.P.Termin1Wunsch=0.0.0) then Ein.P.Termin1Wunsch # Ein.P.TerminZusage;
        vSortKey # CnvAI(Cnvid(ein.P.Termin1Wunsch),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
        Sort_ItemAdd(aTree,vSortKey,501,RecInfo(501,_RecId));
      end;

    END;

    // ArtMatMix?? Dann acuh VSB-Karten einbeziehen!
    if (Wgr_Data:IstMix()) then begin
      FOR Erx # RecLink(200,250,8,_recFirst)  // Material loopen
      LOOP Erx # RecLink(200,250,8,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if ("Mat.Löschmarker"='') and
          (Mat.Status=c_status_EKVSB) then begin
          vSortKey # '000000';
          Sort_ItemAdd(aTree,vSortKey,200,RecInfo(200,_RecId));
        end;
      END;
    end;
  end;


  // Betriebsauftrag mit einbeziehen?
  if (StrFind(aBereiche,'701',0)<>0) then begin

    FOR Erx # RecLink(701,250,17,_RecFirst)   // BA-IOs loopen
    LOOP Erx # RecLink(701,250,17,_RecNext)
    WHILE (Erx<=_rLocked) do begin
//debugx('check:  KEY701   '+aint(bag.io.bruderid)+' '+aint(bag.io.nachposition));

      if (BAG.IO.BruderID<>0) then CYCLE;
      Erx # RecLink(700,701,1,_recfirst); // BA Kopf holen
      if (Erx>_rLocked) or (BAG.VorlageYN) then CYCLE;

      // Input?
      if (BAG.IO.NachPosition<>0) then begin
        Erx # RecLink(702,701,4,_RecFirst);   // Nach-Position holen
        if (Erx<=_rLocked) and ("BAG.P.Löschmarker"='') then begin
          if (BAG.P.Typ.VSBYN=false) then begin
            if (BAG.P.Plan.StartDat=0.0.0) then BAG.P.PLan.StartDat # today;
            vSortKey # CnvAI(Cnvid(BAG.P.Plan.StartDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
            Sort_ItemAdd(aTree,vSortKey,701,RecInfo(701,_RecId));
          end;
        end;
      end;

      // Output?
      if (BAG.IO.VonPosition<>0) then begin
        Erx # RecLink(702,701,2,_RecFirst);   // Von-Position holen
        if (Erx<=_rLocked) and ("BAG.P.Löschmarker"='') and (BAG.P.Typ.VSBYN=false) then begin
//        if (BAG.IO.Materialtyp=c_IO_Art) or
//            (BAG.IO.Materialtyp=c_IO_Beistell) then begin
//        RecLink(702,701,2,_RecFirst);   // Position holen
          if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.PLan.EndDat # BAG.P.Plan.StartDat;
          if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.PLan.EndDat # today;
          vSortKey # CnvAI(Cnvid(BAG.P.Plan.EndDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
          Sort_ItemAdd(aTree,vSortKey,1701,RecInfo(701,_RecId));
        end;
      end;

    END;

  end;
end;


//========================================================================
//========================================================================
sub _ParseItem(
  aTyp      : int;
  var aDat  : date;
  var aA    : alpha;
  var aB    : alpha;
  var aI    : int;
  var aM    : float;
) : logic;
local begin
  Erx       : int;
  vKG       : float;
end;
begin


  case aTyp of
    200 : begin   // Materialkarte
      aA    # 'VSB-Material '+aint(Mat.Nummer);
      aI    # Mat.Bestand.Stk;
      aM    # Mat.Bestand.Menge;
      aDat  # today;
//        Eintrag(today, vA,'', vI, vM);
      RETURN true;
    end;

    250 : begin   // Artikel
      RecBufClear(252);
      Art.C.ArtikelNr   # Art.Nummer;
      Art_Data:ReadCharge();
      aA    # 'IST-Bestand';
      aI    # Art.C.Bestand.Stk;
      aM    # Art.C.Bestand;
      aDat  # today;
//        Eintrag(today, vA,'', vI, vM);
      RETURN true;
    end;

    252 : begin   // Artikel-Charge
      aA  # 'IST-Bestand';
      aI  # Art.C.Bestand.Stk;
      aM  # Art.C.Bestand;
      aDat  # today;
//        Eintrag(today, vA,'', vI, vM);
      RETURN true;
    end;

    401 : begin   // Auftrag
      aA # 'AUF '+AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
      aI # 0-(Auf.P.Prd.Rest.Stk-Auf.P.Prd.VSB.Stk);//-Auf.P.Prd.VSAuf.Stk);
      if (aI>0) then aI # 0;
      aM #  0.0 - (Auf.P.Prd.Rest-Auf.P.Prd.VSB);//-Auf.P.Prd.VSAuf);
      if (aM>0.0) then aM # 0.0;

      RecLink(400,401,3,_RecFirsT); // Kopf holen
      if (Auf.LiefervertragYN) then begin
        Auf.P.Termin1Wunsch # "Auf.GültigkeitBis";
        aA # 'LiVe '+AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
      end;
      if (Auf.P.Termin1Wunsch=0.0.0) then Auf.P.Termin1Wunsch # Auf.P.TerminZusage;
      aDat  # Auf.P.Termin1Wunsch;
      aB    # Auf.P.KundenSW;
//        Eintrag(Auf.P.Termin1Wunsch, vA, Auf.P.KundenSW, vI, vM);
      RETURN true;
    end;

    404 : begin   // Auftragsaktion
      aA # 'AUF '+AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position)+' '+Auf.A.Aktionstyp;
      if (Auf.A.Aktionsnr<>0) then aA # aA +' '+AInt(Auf.A.Aktionsnr);
      if (Auf.A.Aktionspos<>0) then aA # aA + '/'+AInt(Auf.A.Aktionspos);
      if (Auf.A.Aktionspos2<>0) then aA # aA + '/'+AInt(Auf.A.Aktionspos2);
      Erx # RecLink(100,404,2,_recFirst);
      if (Erx>=_rLocked) then RecBufClear(100);
      aI # 0-"Auf.A.Stückzahl";
      aM # 0.0 - Auf.A.Menge;
      aDat  # Auf.A.Aktionsdatum;
      aB    # Adr.Stichwort;
//        Eintrag(Auf.A.Aktionsdatum,vA, Adr.Stichwort,vI,vM);
      RETURN true;
    end;
    1404 : begin   // Auftragsaktion
      aA # 'AUF '+AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position)+' '+Auf.A.Aktionstyp;
      if (Auf.A.Aktionsnr<>0) then aA # aA +' '+AInt(Auf.A.Aktionsnr);
      if (Auf.A.Aktionspos<>0) then aA # aA + '/'+AInt(Auf.A.Aktionspos);
      if (Auf.A.Aktionspos2<>0) then aA # aA + '/'+AInt(Auf.A.Aktionspos2);
      Erx # RecLink(100,404,2,_recFirst);
      if (Erx>=_rLocked) then RecBufClear(100);
      aI # 0-"Auf.A.Stückzahl";
      aM # 0.0 - Auf.A.Menge;
      aDat  # Auf.A.Aktionsdatum;
      aB    # Adr.Stichwort;
//        Eintrag(Auf.A.Aktionsdatum,vA, Adr.Stichwort,vI,vM);
      RETURN true;
    end;

    409 : begin   // Auftragsstückliste
      RecLink(401,409,2,_recFirsT);     // Position holen
      aA # 'AUF '+AInt(Auf.SL.Nummer)+'/'+AInt(Auf.SL.Position)+'/'+AInt(Auf.SL.lfdNr);
      aI # 0 - ("Auf.SL.Stückzahl" - Auf.SL.Prd.Plan.Stk - Auf.SL.Prd.VSB.Stk - Auf.SL.Prd.LFS.Stk);// - Auf.SL.Prd.VSAuf.Stk);
      if (aI>0) then aI # 0;
      aM # 0.0 - (Auf.SL.Menge - Auf.SL.Prd.Plan- Auf.SL.Prd.VSB - Auf.SL.Prd.LFS);//- Auf.SL.Prd.VSAuf);
      if (aM>0.0) then aM # 0.0;
      RecLink(400,401,3,_RecFirsT); // Kopf holen
      if (Auf.LiefervertragYN) then begin
        Auf.P.Termin1Wunsch # "Auf.GültigkeitBis";
        aA # 'LiVe '+AInt(Auf.SL.Nummer)+'/'+AInt(Auf.SL.Position)+'/'+AInt(Auf.SL.lfdNr);
      end;
      if (Auf.P.Termin1Wunsch=0.0.0) then Auf.P.Termin1Wunsch # Auf.P.TerminZusage;
      aDat  # Auf.P.Termin1Wunsch;
      aB    # Auf.P.KundenSW;
//        Eintrag(Auf.P.Termin1Wunsch, vA, Auf.P.KundenSW,vI,vM);
      RETURN true;
    end;

    501 : begin   // Bestellung
      aA # 'EIN '+AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position);
      aI # Ein.P.FM.Rest.Stk;
      if (Ein.P.MEH=Art.MEH) then
        aM # Ein.P.FM.Rest
      else
        aM # Rnd(Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, Art.MEH) ,Set.Stellen.Menge);

      if (Ein.P.Termin1Wunsch=0.0.0) then Ein.P.Termin1Wunsch # Ein.P.TerminZusage;
      aDat  # Ein.P.Termin1Wunsch;
      aB    # Ein.P.LieferantenSW;
//        Eintrag(Ein.P.Termin1Wunsch, vA, Ein.P.LieferantenSW,vI,vM);
      RETURN true;
    end;

    701 : begin   // BAG INPUT
      // Gesamte BA-Einsatzmenge einbeziehen, denn ein Absatz wird über Fertigung999=Rest wieder addiert!!
      Erx # RecLink(702,701,4,_recFirst);   // NachPosition holen
      if (Erx<=_rLocked) then begin
        aA  # 'BAG '+AInt(BAG.IO.NachBAG)+'/'+AInt(BAG.IO.NachPosition)+' Einsatz';
        aI  # BAG.IO.Ist.In.Stk - BAG.IO.Ist.Out.Stk;//BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk;
        aM  # BAG.IO.Ist.In.Menge - BAG.IO.Ist.Out.Menge;//BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge;
        vKG # BAG.IO.Ist.In.GewN - BAG.IO.Ist.Out.GewN;//BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN;
//debugx('einsatz:'+aint(vI)+'stk '+anum(vM,2)+'mg '+anum(vKG,2)+'kg');
        //vM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Menge, BAG.IO.MEH.In, Art.MEH);
        //vM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, vM, BAG.IO.MEH.In, Art.MEH);
        aM # Lib_Einheiten:WandleMEH(701, aI, vKG, aM, BAG.IO.MEH.In, Art.MEH);
        aDat  # BAG.P.Plan.StartDat;
        aB    # BAG.P.Bezeichnung;
        aI    # -aI;
        aM    # -aM;
//          Eintrag(BAG.P.Plan.Startdat, vA, BAG.P.Bezeichnung, -vI, -vM);
        RETURN true;
      end;
    end;

    1701 : begin   // ArtPRD (Output)
      Erx # RecLink(702,701,2,_recFirst);   // VonPosition holen
      if (Erx<=_rLocked) then begin
        aA  # 'BAG '+AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'/'+AInt(BAG.IO.Vonfertigung)+' Ausbringung';
        aI  # BAG.IO.Plan.In.Stk - BAG.IO.ist.In.Stk;
        aM  # BAG.IO.Plan.In.Menge - BAG.IO.Ist.In.Menge;
        vKG # BAG.IO.Plan.In.GewN - BAG.IO.Ist.In.GewN
        //vM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Menge, BAG.IO.MEH.In, Art.MEH);
//          vM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, vM, BAG.IO.MEH.In, Art.MEH);
        aM # Lib_Einheiten:WandleMEH(701, aI, vKG, aM, BAG.IO.MEH.In, Art.MEH);
        aDat  # BAG.P.Plan.StartDat;
        aB    # BAG.P.Bezeichnung;
//          Eintrag(BAG.P.Plan.Startdat, vA, BAG.P.Bezeichnung,vI,vM);
        RETURN true;
      end;
    end;

  end;  // CASE


  RETURN false;
end;


//========================================================================
//  Show
//    Baut eine Dispoliste auf und zeigt diese an
//========================================================================
Sub Show (
  aName     : alpha;
  aBereiche : alpha;
  aMitSumme : logic;
  aCharge   : logic;
  opt aDLG  : int;
);
local begin
  vHdl      : int;
  vHdl3     : int;

  vTree     : int;        // Descriptor für die Sortierungsliste
  vSortKey  : alpha;      // "Sortierungsschlüssel" der Liste
  vItem     : int;        // Descriptor für einen Eintrag
  vMarked   : int;
  vEReItem  : int;
  VEReTree  : int;

  vDat      : date;
  vX        : int;
  vA,vB     : alpha;
  vI        : int;
  vM        : float;
  vKG       : float;

  vMin, vMax  : float;
end;

begin

  vSum # 0.0;

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN;
  BuildTree(vTree, aBereiche, aCharge);

  // Dataliste anpacken
  if (aDLG=0) then
    vHdl # WinOpen('Art.Dispoliste',_WinOpenDialog)
  else
    vHDL # aDlg;
  vHdl->wpCaption # Translate(aName);

  vHdl2 # vHdl->WinSearch('Lb.Artikelnr');
  vHdl2->wpCaption # Art.Nummer;

  vHdl2 # vHdl->WinSearch('Lb.ArtikelSW');
  vHdl2->wpCaption # Art.Stichwort;

  vA # ANum(Art.Dicke,Set.Stellen.Dicke)+' x '+ANum(Art.Breite,Set.Stellen.Breite);
  if ("Art.Länge"<>0.0) then vA # vA + ' x '+ANum("Art.Länge","Set.Stellen.Länge");
  vHdl2 # vHdl->WinSearch('Lb.Abmessung');
  vHdl2->wpCaption # vA;

  vHdl2 # vHdl->WinSearch('Lb.WSt');
  vHdl2->wpCaption # Art.Werkstoffnr;

  vHdl2 # vHdl->WinSearch('Lb.StkGew');
  vHdl2->wpCaption # ANum("Art.GewichtProStk",Set.Stellen.Gewicht);

  if (aMitSumme=n) then begin
    vHdl2 # vHdl->WinSearch('ClmSumme');
    vHdl2->wpvisible # false;
    vHdl2 # vHdl->WinSearch('ClmSummeStk');
    vHdl2->wpvisible # false;
    vHdl2 # vHdl->WinSearch('ClmVorgang');
    vHdl2-> wpclmStretch # true;
  end;
//  if (aCharge=n) then begin
  if (Art.MEH='Stk') then begin
    vHdl2 # vHdl->WinSearch('ClmStueck');
    vHdl2->wpvisible # false;
    vHdl2 # vHdl->WinSearch('ClmSummeStk');
    vHdl2->wpvisible # false;
  end;

  vHdl2 # vHdl->WinSearch('DL.Dispoliste');
  vHdl3  # vHdl2->WinSearch('ClmMenge');
  vHdl3->wpCaption # vHdl3->wpCaption+' '+Art.MEH;
  vHdl3->wpFmtPostComma # Set.Stellen.Menge;
  vHdl3->wpClmColBkg # _WinCol3DLight;

  vHdl3  # vHdl2->WinSearch('ClmSumme');
  vHdl3->wpCaption # vHdl3->wpCaption+' '+Art.MEH;
  vHdl3->wpFmtPostComma # Set.Stellen.Menge;

  vHdl3 # vHdl2->WinSearch('ClmStueck');
  vHdl3->wpClmColBkg # _WinCol3DLight;

  vMin  #   0.0;
  vMax  # - 10000.0;
  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    vX # CnvIA(vItem->spCustom);
    if (vx>1000) then
      RecRead(vX-1000,0,0,vItem->spID)
    else
      RecRead(vX,0,0,vItem->spID);

    vA # '';
    vB # '';
    vI # 0;
    vM # 0.0;
    if (_ParseItem(vX, var vDat, var vA, var vB, var vI, var vM)) then begin
      Eintrag(vDat, vA, vB, vI,vM);
      if (vSum<vMin) then vMin # vSum;
      if (vSum>vMax) then vMax # vSum;
    end;

  END;  // nächste Dispo-Position

Graph(vHdl2, vMin, vMax);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Anzeigen
  $DL.Dispoliste  ->wpCurrentInt # 1;

  if (aDLG<>0) then RETURN;

  vHdl->WinDialogRun(_WinDialogCenter,gMdi);

  // Beenden
  vHdl->WinClose();
end;


//========================================================================
// EvtLstDataInit
//
//========================================================================
Sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
)
local begin
  vMenge  : float;
end;
begin

//DUMBO BSP
  if (gDataList<>0) then begin
    if ( Lib_Mark:IstMarkiert(gDataList,  aRecId)) then begin
      Lib_GuiCom:ZLColorLine( aEvt:OBj, Set.Col.RList.Marke, true);
    end;
  end;


  aEvt:obj->WinLstCellGet(vMenge,7,aRecID);
  if (vMenge<Art.Bestand.Min) then
    $ClmSumme->WpclmColBkg # _WinCollightred
  else if (vMenge>Art.Bestand.Soll) and (Art.Bestand.Soll<>0.0) then
    $ClmSumme->WpclmColBkg # _WinColLightBlue;;
end;


//========================================================================
// BerechneEinenArtikel
//    errechnet im Dipozeitraum die Bedarfsmenge und das Datum aus
//========================================================================
Sub BerechneEinenArtikel(
  var aNeedDat    : date ;
  var aNeedMenge  : float;
  var aNeedStk    : int);
local begin
  vTree : int;
  vItem : int;
  vDat  : date;
  vMaxDat : date;
  vTheoMenge : float;
  vMenge : float;
end;
begin

  if (Art.AutoBestellYN=n) or (Art.DispoTage=0) then RETURN;

  // Sortierte Dispo generieren
  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN;
  BuildTree(vTree, '250_401_501_701',n);
//BuildTree(vTree,'250_401_-RES_409_501_701',n);

  // Zieldatum der Dispo ermitteln
  vMaxDat # today;
  vMaxDat->vmDayModify(Art.Dispotage);

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    vDat # cnvdi(CnvIA(StrCut(vItem->spName,1,6)));
    if (vDat<=vMaxDat) then begin
      // Datensatz holen
      RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

      vMenge # 0.0;
      case CnvIA(vItem->spCustom) of

200 : todox('Matkarte');

        250 : begin     // Artikel
          RecBufClear(252);
          Art.C.ArtikelNr   # Art.Nummer;
          Art_Data:ReadCharge();
          vMenge # Art.C.Bestand;
//          vMenge # "Art.C.Verfügbar" + Art.C.Bestellt;
        end;


        401 : begin     // Auftrag
//          vMenge # Auf.P.Prd.Rest * (-1.0);
          vMenge #  - (Auf.P.Prd.Rest-Auf.P.Prd.VSB);
          if (vMenge>0.0) then vMenge # 0.0;
        end;


        404 : begin     // Auftragsaktion
          vMenge # Auf.A.Menge * (-1.0);
        end;


        501 : begin     // Bestellung
        if (Ein.P.MEH=Art.MEH) then
          vMenge # Ein.P.FM.Rest
        else
          vMenge # Rnd(Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, Art.MEH) ,Set.Stellen.Menge);
        end;


        701 : begin     // BA
          //vMenge # BAG.IO.Plan.In.Menge;
//          vMenge # -(BAG.IO.Plan.In.Menge - BAG.IO.Ist.In.Menge);
// 24.07.2017 AH:
          vMenge # -(BAG.IO.Ist.In.Menge - BAG.IO.Ist.Out.Menge);
        end;

      end;

      vTheoMenge # vTheoMenge + vMenge;
//debug(Art.Nummer+' '+cnvad(vdat)+'  '+vItem->spCustom+' :'+anum(vMenge,0)+' = '+anum(vTheomenge,0));

      // Unterdeckung?
      if (vTheoMenge<Art.Bestand.Min) then begin
        if (aNeedDat=0.0.0) then aNeedDat # vDat;
        // Fehlmenge
        vMenge # Art.Bestand.Soll - vTheoMenge;
        vTheoMenge # vTheoMenge + vMenge;
        aNeedMenge # aNeedMenge + vMenge;
        BREAK;
      end;

    end;

  END;

  // Löschen der Liste
  Sort_KillList(vTree);

  if (Art.MEH='Stk') then aNeedStk # CnvIF(aNeedMenge);

//  Msg(123123,'Artikel: '+art.nummer+'   Brauchen am '+cnvad(aNeedDat)+' '+cnvaf(aNeedMenge),0,0,0);
end;


//========================================================================
// Autodispo
//
//========================================================================
Sub Autodispo();
local begin
  Erx   : int;
  v100  : int;
end;
begin

  APPOFF();

  v100 # RekSave(100);
  Erx # RecRead(250,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Art.AutoBestellYN=y) and (Art.DispoTage<>0) then begin
      if (Bdf_Data:ArtikelAutoDispo(Art.DispoTage)=false) then begin
        APPON();
        RekRestore(v100);
        Msg(99,'ERROR',0,0,0);
        RETURN;
      end;
    end;

    Erx # RecRead(250,1,_RecNext);
  END;

  APPON();
  RekRestore(v100);

  // Erfolg!!!
  Msg(250542,'',0,0,0);

end;


//========================================================================
//  DispoZum
//
//========================================================================
Sub DispoZum(
  aDat      : date;
  aBereiche : alpha;
  var aStk  : int;
  var aM    : float) : logic;
local begin
  vTree     : int;        // Descriptor für die Sortierungsliste
  vItem     : int;        // Descriptor für einen Eintrag
  vDat      : date;
  vDat2     : date;
  vX        : int;
  vA,vB     : alpha;
  vI        : int;
  vM        : float;
end;
begin

  aM    # 0.0;
  aStk  # 0;
  if (aBereiche='') then
    aBereiche # '250_401_-RES_409_501_701';

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN false;
  BuildTree(vTree, aBereiche, false);

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    vX # CnvIA(vItem->spCustom);
    if (vx>1000) then
      RecRead(vX-1000,0,0,vItem->spID)
    else
      RecRead(vX,0,0,vItem->spID);

    vI # cnvia(StrCut(vItem->spName,1,StrLen(vItem->spName)-8));
    if (vI=0) then vDat2 # 0.0.0
    else vDat2 # cnvdi(vI);

    vA # '';
    vB # '';
    vI # 0;
    vM # 0.0;
    if (_ParseItem(vX, var vDat, var vA, var vB, var vI, var vM)) then begin
      if (vDat2<=aDat) then begin
        aStk # aStk + vI;
        aM   # aM + vM;
      end;
    end;

  END;  // nächste Dispo-Position

  // Löschen der Liste
  Sort_KillList(vTree);

  RETURN true;
end;


//========================================================================
//========================================================================
sub _Draw(
  aChartData  : int;
  aDat        : date;
  aM          : float;
  aMitLabel   : logic;
);
begin
  aChartData->ChartDataAdd(aM);

  if (aM<Art.Bestand.Min) then
    aChartData->ChartDataAdd( _WinColLightRed , _ChartDataColor)
  else if (aM>Art.Bestand.Soll) and (Art.Bestand.Soll<>0.0) then
    aChartData->ChartDataAdd(  _WinColLightBlue, _ChartDataColor);
  else
    aChartData->ChartDataAdd(  _WinColLightGreen, _ChartDataColor);

  if (aMitLabel) then
    aChartData->ChartDataAdd(aint(aDat->vpDay)+'.'+aint(aDat->vpMonth), _ChartDataLabel);
  else
    aChartData->ChartDataAdd(' ', _ChartDataLabel);

end;


//========================================================================
//========================================================================
Sub Graph(
  aDL   : int;
  aMin  : float;
  aMax  : float);
local begin
  vMaxX, vMaxY  : int;
  vChart        : handle;
  vChartData    : handle;
  vMem          : handle;
  vMax          : int;
  vI,vJ         : int;
  vM            : float;
  vDat,vDat2    : date;
  vDayRange     : int;
  vMaxDat       : date;
  vBestand      : float;
  vBisher       : float;
end;
begin

  vMaxX     # 1000;
  vMaxY     # 200;
  vDayRange # 60;


  vChart # ChartOpen(_ChartXY, vMaxX, vMaxY, '', _ChartOptDefault);
  if (vChart <= 0) then RETURN;

  vChart->spChartArea              # RectMake(50, 10, vMaxX-5, vMaxY-50);
  vChart->spChartBorderWidth       # -1;
  vChart->spChartColBkg            # ColorMake(ColorRgbMake(240, 240, 255), 0);
//  vChart->spChartTitleArea         # RectMake(5, 5, 445, 0);
//  vChart->spChartTitleColBkg       # ColorMake(ColorRgbMake(96, 0, 96), 128);
//  vChart->spChartTitleColFg        # ColorMake(ColorRgbMake(255, 255, 255), 0);
  vChart->spChartXYAxisTitleAlignY # _ChartAlignLeft;
  vChart->spChartXYBarShading      # _ChartXYBarShadingGradientTop;
  vChart->spChartXYColBkg          # ColorMake(ColorRgbMake(232, 232, 255), 0);
  vChart->spChartXYColBkgAlt       # ColorMake(ColorRgbMake(216, 216, 255), 0);
  vChart->spChartXYColBorder       # ColorMake(ColorRgbMake(128, 0, 128), 0);
  vChart->spChartXYColData         # ColorMake(ColorRgbMake(128, 0, 128), 64);
  vChart->spChartXYDepth           # 0;
  vChart->spChartXYDepthGap        # 0;
  vChart->spChartXYLabelColData    # ColorMake(ColorRgbMake(0, 0, 0), 0);
  vChart->spChartXYLabelColSum     # ColorMake(ColorRgbMake(0, 0, 0), 0);
//  vChart->spChartXYLineSymbol      # _ChartSymbolDiamond;
  vChart->spChartXYStyleData        # _ChartXYStyleDataBar;//_ChartXYStyleDataLine;
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDefault;
  vChart->spChartXYLabelAngleX      # 90.0;
  vChart->spChartXYTitleAlignY      # _ChartAlignLeft;
  vChart->spChartXYBarGap           # 0.05;
  //vChart->spChartXYTitleX          # 'X-Achse';
  //vChart->spChartXYTitleY          # 'Y-Achse';


  vMax # WinLstDatLineInfo(aDL, _WinLstDatInfoCount);

  vChartData # vChart->ChartDataOpen(vDayRange, _ChartDataLabel | _ChartDataColor);
  if (vChartData > 0) then begin
    // TODAY....
    vI # 1;
    aDL->WinLstCellGet(vDat, 1, vI);
    aDL->WinLstCellGet(vM, 5, vI);      // Delta
    vBestand  # vM;
    vDat2 # vDat;
    vMaxDat # vDat;
    vMaxDat->vmDayModify(vDayRange-1);

    WHILE (vI<vMax) do begin
      inc(vI);
      aDL->WinLstCellGet(vDat, 1, vI);
      aDL->WinLstCellGet(vM, 5, vI);    // Delta
      if (vDat>vDat2) then begin
        dec(vI);
        BREAK;
      end;
      vBestand # vBestand + vM
    END;
    _Draw(vChartData, vDat2, vBestand, true);  // TODAY zeichnen
    vBisher # vBestand;

    WHILE (vDat2<vMaxDat) do begin
      vDat2->vmDayModify(1);
//debug(cnvad(vDat2)+' : '+aint(vI)+'/'+aint(vMAx));
      WHILE (vI<vMax) do begin
        inc(vI);
        aDL->WinLstCellGet(vDat, 1, vI);
        aDL->WinLstCellGet(vM, 5, vI);    // Delta
        if (vDat>vDat2) then begin
          Dec(vI);
          BREAK;
        end;
        vBestand # vBestand + vM
      END;
      _Draw(vChartData, vDat2, vBestand, vBisher<>vBestand);  // DAY zeichnen
      vBisher # vBestand;
    END;
    vChartData->ChartDataClose();
  end;

/***
  vChartData # vChart->ChartDataOpen(vMax, _ChartDataLabel | _ChartDataColor);
  if (vChartData > 0) then begin
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=vMax) do begin
      aDL->WinLstCellGet(vDat, 1, vI);
      aDL->WinLstCellGet(vM, 7, vI);

      if (vI>1) then begin
      end;

      vChartData->ChartDataAdd(vM);

//      vChartData->ChartDataAdd(cnvad(vDat), _ChartDataLabel);
      if (vM<Art.Bestand.Min) then
        vChartData->ChartDataAdd( _WinColLightRed , _ChartDataColor)
      else if (vM>Art.Bestand.Soll) and (Art.Bestand.Soll<>0.0) then
        vChartData->ChartDataAdd(  _WinColLightBlue, _ChartDataColor);
      else
        vChartData->ChartDataAdd(  _WinColLightGreen, _ChartDataColor);

    END;
    vChartData->ChartDataClose();
  end;
***
  // SOLL-BESTAND -----------------------------------------------------------
  vChart->spChartXYStyleData  # _ChartXYStyleDataArea | _ChartXYStyleDataPercent;
  vChart->spChartXYLineWidth  # 1;
  vChart->spChartXYDepth      # 0;
  vChart->spChartXYDepthGap   # 0;

  vChartData # vChart->ChartDataOpen(vMax, _ChartDataValue | _ChartDataColor);
  if (vChartData > 0) then begin
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=vMax) do begin
      vChartData->ChartDataAdd(Art.Bestand.Min);
      vChartData->ChartDataAdd(ColorMake(ColorRgbMake(255,0,0), 220), _ChartDataColor);
    END;
    vChartData->ChartDataClose();
  end;


  // MAX-BESTAND ------------------------------------------------------------
  if (Art.Bestand.Soll>0.0) then begin
    vM # aMax-Art.Bestand.Soll;
vM # 3000.0;
    vChartData # vChart->ChartDataOpen(vMax, _ChartDataValue | _ChartDataColor);
    if (vChartData > 0) then begin
      FOR vI # 1
      LOOP inc(VI)
      WHILE (vI<=vMax) do begin
        vChartData->ChartDataAdd(vM);
        vChartData->ChartDataAdd(ColorMake(ColorRgbMake(255,255,0), 220), _ChartDataColor);
      END;
      vChartData->ChartDataClose();
    end;

    vM # aMax;
    vChartData # vChart->ChartDataOpen(vMax, _ChartDataValue | _ChartDataColor);
    if (vChartData > 0) then begin
      FOR vI # 1
      LOOP inc(VI)
      WHILE (vI<=vMax) do begin
        vChartData->ChartDataAdd(vM);
        vChartData->ChartDataAdd(ColorMake(ColorRgbMake(0,255,0), 220), _ChartDataColor);
      END;
      vChartData->ChartDataClose();
    end;

  end;
***/

  // Diagramm unter "Eigene Bilder" speichern
//  tChart->ChartSave(_Sys->spPathMyPictures + '\Chart.png', _ChartFormatPNG);
//  vChart->ChartSave('C:\debug\Chart.png', _ChartFormatPNG);

  vMem # MemAllocate(_MemAutoSize);
  vChart->ChartSave('', _ChartFormatBmp, vMem);
  $Picture1->wpMemObjHandle # vMem;

  vChart->ChartClose();

end;

//========================================================================