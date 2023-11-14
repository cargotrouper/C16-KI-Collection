@A+
//===== Business-Control =================================================
//
//  Prozedur    Art_Disposition2
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2018  AH  Erstellung der Prozedur
//  18.04.2018  AH  OHNE Weiterbearbeitungen
//  02.05.2018  AH  Fix AutoDispo
//  31.08.2018  ST  Autodispo mit SilentParameter + Progressbar
//  13.02.2020  AH  Ansicht für "Vormaterial"
//  18.02.2020  AH  "701" = Vormaterial zeigt NICHT für Fahren an, weil das ja "Res"erviert wäre
//  25.02.2020  AH  "Vormaterial" wird als PLUS angesehen
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//
//    Sub BuildTree(aTree : int; aBereiche : alpha);
//    Sub Redraw (aDlg : int; aDL : int; aName : alpha; aBereiche : alpha; aMitSumme : logic; aCharge : logic);
//    Sub Show (aName : alpha; aBereiche : alpha; aMitSumme : logic; aChargen : logic; opt aDlg : int;)
//    Sub BerechneEinenArtikel(var aNeedDat : date ; var aNeedMenge : float);
//    Sub AutoDispo
//    Sub DispoZum(aDat : date; aBereiche : alpha; var aStk  : int; var aM : float) : logic;//
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:def_BAG

local begin
//  vSum      : float;
//  vSumStk   : int;
//  vHdl2     : int;
end;

define begin
  GibtSchon(a,b) : TextSearch(a, 1,1, _TextSearchCI, b)>0
  Merke(a,b) : TextAddLine(a,b+'|')
  cIgnoreWeiterbearbeitung : true
  cSubPlanVomAuf : true
end;

declare Graph(aDL : int; aMin : float; aMax : float);

//========================================================================
// Eintrag
//
//========================================================================
Sub Eintrag(
  aDL           : int;
  aDat          : date;
  aName         : alpha;
  aSW           : alpha;
  aStk          : int;
  aM            : float;
  aCust         : alpha;
  var aSumStk   : int;
  var aSumM     : float;
  );
begin

  aSumStk # aSumStk + aStk;
  asumM   # aSumM + aM;

  aDL->WinLstDatLineAdd(aDat);
  aDL->WinLstCellSet(aName,2,_WinLstDatLineLast);
  aDL->WinLstCellSet(aSW,3,_WinLstDatLineLast);
  aDL->WinLstCellSet(aStk,4,_WinLstDatLineLast);
  aDL->WinLstCellSet(aM,5,_WinLstDatLineLast);
  aDL->WinLstCellSet(aSumStk,6,_WinLstDatLineLast);
  aDL->WinLstCellSet(aSumM,7,_WinLstDatLineLast);
  aDL->WinLstCellSet(aCust,8,_WinLstDatLineLast);
end;


//========================================================================
// _Bereich
//
//========================================================================
Sub _Bereich(
  aTree       : int;
  aBereich    : alpha;
  aCharge     : logic;
  aMerkTxt    : int);
local begin
  Erx         : int;
  vI          : int;
  vMax        : int;
  vBereich    : alpha;
  vX          : int;
  vSortKey    : alpha;      // "Sortierungsschlüssel" der Liste
  vMerkTxt    : int;
end;
begin
  // Artikel-Ist-Bestand mit einbeziehen?
  if (aBereich='250') then begin
    vSortKey # '000000';
    Sort_ItemAdd(aTree,vSortKey,250,RecInfo(250,_RecId));
  end;

  // Chargen-Ist-Bestand mit einbeziehen?
  if (aBereich='252') then begin
    vSortKey # '000000';
    Sort_ItemAdd(aTree,vSortKey,252,RecInfo(252,_RecId));
  end;


  // Aufträge mit einbeziehen?
  if (aBereich='401') or (aBereich='401-Res') then begin
    if (aBereich='401-Res') then vX # 1000;

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
          Sort_ItemAdd(aTree,vSortKey,vX+401,RecInfo(401,_RecId))
        end;
      end;
      Erx # RecLink(401,250,3,_RecNext);
    END;
  end;

  // Auftragsaktionen mit einbeziehen?
  if (aBereich='404') then begin
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


  // Reservierungen von Vormaterial (d.h. andere AufArtikelnr) mit einbeziehen?
  if (aBereich='VORMAT') then begin

    // Aufträge loopen...
    FOR Erx # RecLink(401,250,3,_RecFirst)
    LOOP Erx # RecLink(401,250,3,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      // AufRes loopen...
      FOR Erx # RecLink(203,401,18,_recFirst)
      LOOP Erx # RecLink(203,401,18,_recNext)
      WHILE (Erx<=_rLocked) do begin
        Erx # RecLink(200,203,1,_recFirst);   // Material holen
        if (Erx<=_rLocked) and (Mat.Strukturnr<>'') and (Mat.Strukturnr<>Art.Nummer) then begin
          vSortKey # CnvAI(Cnvid(today),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
          Sort_ItemAdd(aTree,vSortKey,203,RecInfo(203,_RecId));
        end;
      END;
      
      // 25.02.2020
      if (Auf.P.Prd.Plan>0.0) then begin
        vSortKey # CnvAI(Cnvid(today),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
        Sort_ItemAdd(aTree,vSortKey,401,RecInfo(401,_RecId));
      end;

    END;
  end;


  // Reservierungen mit einbeziehen? ---------------------------------
  if (aBereich='RES') or (aBereich='-RES') then begin
    if (aBereich='-RES') then vX # 1000;

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
          // nur direkte LFS OHNE LFA!
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


    // 05.02.2018 AH:
    if (Wgr_Data:IstMix()) then begin
      FOR Erx # RecLink(200,250,8,_recFirst)  // Material loopen
      LOOP Erx # RecLink(200,250,8,_recNext)
      WHILE (Erx<=_rLocked) do begin

        if ("Mat.Löschmarker"<>'') then CYCLE;
        if (aMerkTxt<>0) then begin
          if (GibtSchon(aMerkTxt, 'MAT'+aint(Mat.Nummer))) then CYCLE;
          Merke(aMerkTxt, 'MAT'+aint(Mat.Nummer));
        end;

        FOR Erx # RecLink(203,200,13,_recFirst)  // MatRes loopen
        LOOP Erx # RecLink(203,200,13,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Mat_Rsv_Data:IstInMatSummierbar()=false) then CYCLE;
          vSortKey # CnvAI(Cnvid(today),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
          Sort_ItemAdd(aTree,vSortKey,203,RecInfo(203,_RecId));
        END;
      END;
    end;
  end;


  // AuftragsStückliste mit einbeziehen? -------------------------------------
  if (aBereich='409') then begin
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
            Sort_ItemAdd(aTree,vSortKey,vX+409,RecInfo(409,_RecId));
          end;
        end;

      end;
      Erx # RecLink(409,250,7,_RecNext);
    END;
  end;


  // Bestellungen mit einbeziehen? --------------------------------------
  if (aBereich='501') then begin
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

    // ArtMatMix?? Dann auch VSB-Karten einbeziehen!
    if (Wgr_Data:IstMix()) and (Set.Art.Vrfgb.VsbEK=false) then begin
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


  // Betriebsauftrag mit einbeziehen? -----------------------------------------
  if (aBereich='701') or (aBereich='-701') or (aBereich='+701') then begin

    if (Wgr_Data:IstMix()) then begin  // für Material ............................
      FOR Erx # RecLink(701,250,17,_RecFirst)   // BA-IOs loopen
      LOOP Erx # RecLink(701,250,17,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        if (BAG.IO.BruderID<>0) then CYCLE;
        Erx # RecLink(700,701,1,_recfirst); // BA Kopf holen
        if (Erx>_rLocked) or (BAG.VorlageYN) then CYCLE;

        // Input?
        if (BAG.IO.NachPosition<>0) then begin
          Erx # RecLink(702,701,4,_RecFirst);   // Nach-Position holen
          if (Erx<=_rLocked) and ("BAG.P.Löschmarker"='') then begin

            // 18.02.2020
            if (BAG.P.Aktion=c_BAG_Fahr09) or (BAG.P.Aktion=c_BAG_Umlager) then begin
              // wird ja schon RESERVIERT
              CYCLE;
            end;
            
            if (BAG.P.Typ.VSBYN=false) then begin   // nicht nach VSB => also EINSATZ
              if (aBereich<>'701') and (aBereich<>'-701') then CYCLE;

              // 18.04.2018 AH: Weiterbearbeitungen ignorieren
              if (cIgnoreWeiterbearbeitung) and (BAG.IO.Materialtyp=c_IO_BAG) then CYCLE;

//debugx(aint(bag.io.materialnr)+'/'+aint(bag.io.materialrstnr));
              if (aMerkTxt<>0) then begin
                if (BAG.IO.Materialnr<>0) then begin
                  if (GibtSchon(aMerkTxt, 'MAT'+aint(BAG.Io.Materialnr))) then CYCLE;
                  Merke(aMerkTxt, 'MAT'+aint(BAG.IO.Materialnr));
                end;
                if (BAG.IO.MaterialRstNr<>0) and (BAG.Io.MaterialRstNr<>BAG.IO.Materialnr) then begin
                  if (GibtSchon(aMerkTxt, 'MAT'+aint(BAG.Io.MaterialRstnr))) then CYCLE;
                  Merke(aMerkTxt, 'MAT'+aint(BAG.IO.MaterialRstnr));
                end;
              end;

              if (BAG.P.Plan.StartDat=0.0.0) then BAG.P.PLan.StartDat # today;
              vSortKey # CnvAI(Cnvid(BAG.P.Plan.StartDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
              Sort_ItemAdd(aTree,vSortKey,701,RecInfo(701,_RecId));
            end
            else begin  // doch nach VSB => also OUTPUT
              if (aBereich<>'701') and (aBereich<>'+701') then CYCLE;

              Erx # RecLink(702,701,2,_RecFirst);   // Von-Position holen
              if (Erx<=_rLocked) and ("BAG.P.Löschmarker"='') then begin
                if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.PLan.EndDat # BAG.P.Plan.StartDat;
                if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.PLan.EndDat # today;
                vSortKey # CnvAI(Cnvid(BAG.P.Plan.EndDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
//              if (BAG.P.Plan.StartDat=0.0.0) then BAG.P.PLan.StartDat # today;
//              vSortKey # CnvAI(Cnvid(BAG.P.Plan.StartDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
                Sort_ItemAdd(aTree,vSortKey,2701,RecInfo(701,_RecId));
              end;
            end;
          end;
        end;
      END;
      RETURN;
    end; // BA bei Material

    // für Artikel...........................................................
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
          if (aBereich<>'701') and (aBereich<>'-701') then CYCLE;
          if (BAG.P.Typ.VSBYN=false) then begin
            if (BAG.P.Plan.StartDat=0.0.0) then BAG.P.PLan.StartDat # today;
            vSortKey # CnvAI(Cnvid(BAG.P.Plan.StartDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
            Sort_ItemAdd(aTree,vSortKey,701,RecInfo(701,_RecId));
          end;
        end;
        CYCLE;
      end;

      // Output?
      if (BAG.IO.VonPosition<>0) then begin
        Erx # RecLink(702,701,2,_RecFirst);   // Von-Position holen
        if (Erx<=_rLocked) and ("BAG.P.Löschmarker"='') and (BAG.P.Typ.VSBYN=false) then begin
//        if (BAG.IO.Materialtyp=c_IO_Art) or
//            (BAG.IO.Materialtyp=c_IO_Beistell) then begin
//        RecLink(702,701,2,_RecFirst);   // Position holen
          if (aBereich<>'701') and (aBereich<>'+701') then CYCLE;
          if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.PLan.EndDat # BAG.P.Plan.StartDat;
          if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.PLan.EndDat # today;
          vSortKey # CnvAI(Cnvid(BAG.P.Plan.EndDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
          Sort_ItemAdd(aTree,vSortKey,1701,RecInfo(701,_RecId));
        end;
      end;
    END;
  end;

  RETURN;
end;


//========================================================================
// BuildTree
//
//========================================================================
Sub BuildTree(
  aTree         : int;
  aBereiche     : alpha;
  aCharge       : logic;
  opt aUnikate  : logic);
local begin
  Erx         : int;
  vI          : int;
  vMax        : int;
  vMerkTxt    : int;
end;
begin

  if (Lib_SFX:Check_AFX('Art.Disposition:BuildTree')) then begin
    Call(AFX.Prozedur, aTree, aBereiche, aCharge, aUnikate);
    RETURN;
  end;


  if (aUnikate) then
    vMerkTxt # TextOpen(16);

  RecRead(250,1,0);
  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,0);    // Warengruppe holen

  vMax # 1 + Lib_Strings:Strings_Count(aBereiche, '_');
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    _Bereich(aTree, Str_Token(aBereiche,'_',vI), aCharge, vMerkTxt);
  END;

  if (vMerkTxt<>0) then
    TextClose(vMerkTxt)

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
  vHdl      : int;
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

    203 : begin   // Materialreservierung
      aA    # 'Reservierung '+aint(Mat.R.Reservierungnr)+' Mat '+aint(Mat.R.Materialnr);
      if (Mat.R.Kommission<>'') then
        aA    # 'Res. AUF  '+Mat.R.Kommission;
      aI    # -"Mat.R.Stückzahl";
      aM    # -Mat.R.Gewicht;
      
      vHdl # gMDI->WinSearch('Lb.Artikelnr');
      if (vHdl<>0) and (Str_Token(vHdl->wpCustom,'|',2)='VORMAT') then begin
        aA    # 'VorMat.Res. AUF  '+Mat.R.Kommission;
        aI    # "Mat.R.Stückzahl";
        aM    # Mat.R.Gewicht;
      end;
     
      aDat  # today;
      aB    # Mat.R.KundenSW;
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

    1401,401 : begin   // Auftrag
      aA # 'AUF '+AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
      vHdl # gMDI->WinSearch('Lb.Artikelnr');
      if (vHdl<>0) and (Str_Token(vHdl->wpCustom,'|',2)='VORMAT') then begin
        aI # Auf.P.Prd.Plan.Stk;
        aM # Auf.P.Prd.Plan;
      end
      else begin
        if (aTyp=401) then begin
          aI # 0-  (Auf.P.Prd.Rest.Stk - Auf.P.Prd.VSB.Stk);// 01.02.2018 AH Dispotest
          aM #  0.0 - (Auf.P.Prd.Rest - Auf.P.Prd.VSB);// 01.02.2018 AH Dispotest
          
          if (Set.Art.AufRst.Rsrv) then begin   // 02.04.2020
            aI # aI + Auf.P.Prd.Reserv.Stk;
            aM # aM + Auf.P.Prd.Reserv;
          end;

        end
        else if (aTyp=1401) then begin
          aI # 0 - (Auf.P.Prd.Rest.Stk - Auf.P.Prd.VSB.Stk - Auf.P.Prd.Reserv.Stk);
          aM #  0.0 - (Auf.P.Prd.Rest - Auf.P.Prd.VSB - Auf.P.Prd.Reserv.Gew);
        end;
        if (cSubPlanVomAuf) then begin
          aI # aI + Auf.P.Prd.Plan.Stk; // BSP
          aM # aM + Auf.P.Prd.Plan;
        end;
      end;

      RecLink(400,401,3,_RecFirsT); // Kopf holen
      if (Set.Art.AufRst.Rsrv=false) or (Auf.LiefervertragYN=false) then begin  // 2022-08-17 AH : Überreservierung im Rahmen beachten!
        if (aI>0) then aI # 0;
        if (aM>0.0) then aM # 0.0;
      end;
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
      aM # 0.0 - (Auf.SL.Menge - Auf.SL.Prd.Plan- Auf.SL.Prd.VSB - Auf.SL.Prd.LFS);//- Auf.SL.Prd.VSAuf);

      if (aM>0.0) then aM # 0.0;
      if (aI>0) then aI # 0;
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
      Erx # RecLink(500,501,3,_RecFirst);   // Kopf holen
      if (Ein.LiefervertragYN) then
        aA # 'LiVe EIN '+AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position)
      else
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

// BIS 18.04.2018 AH:
//        aI  # BAG.IO.Ist.In.Stk - BAG.IO.Ist.Out.Stk;//BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk;
//        aM  # BAG.IO.Ist.In.Menge - BAG.IO.Ist.Out.Menge;//BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge;
//        vKG # BAG.IO.Ist.In.GewN - BAG.IO.Ist.Out.GewN;//BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN;
// DANN NEU (BSP);
        aI  # BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk;
        aM  # BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge;
        vKG # BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN;

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

    2701 : begin   // VSB (Output)
      Erx # RecLink(702,701,4,_recFirst);   // NachPosition holen
      if (Erx<=_rLocked) then begin
        aA  # 'BAG '+AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'/'+AInt(BAG.IO.Vonfertigung)+' Ausbringung';
        aI  # BAG.IO.Plan.In.Stk - BAG.IO.ist.In.Stk;
        aM  # BAG.IO.Plan.In.Menge - BAG.IO.Ist.In.Menge;
        vKG # BAG.IO.Plan.In.GewN - BAG.IO.Ist.In.GewN
        //vM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Menge, BAG.IO.MEH.In, Art.MEH);
//          vM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, vM, BAG.IO.MEH.In, Art.MEH);
        aM # Lib_Einheiten:WandleMEH(701, aI, vKG, aM, BAG.IO.MEH.In, Art.MEH);
        aDat  # BAG.P.Plan.StartDat;
        aB    # '';//BAG.P.Bezeichnung;
//          Eintrag(BAG.P.Plan.Startdat, vA, BAG.P.Bezeichnung,vI,vM);

        if (BAG.P.Auftragsnr<>0) then begin
          aA  # 'BAG '+AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'/'+AInt(BAG.IO.Vonfertigung)+' VSB '+BAG.P.Kommission;
          Erx # Auf_Data:Read(BAG.P.Auftragsnr, BAG.P.Auftragspos, n);
          if (Erx>=400) then
            aB # Auf.P.KundenSW;
        end;
        Erx # RecLink(702,701,2,_recFirst);   // VonPosition holen
        if (Erx<=_rLocked) then
          aDat  # BAG.P.Plan.EndDat;


        RETURN true;
      end;
    end;

  end;  // CASE


  RETURN false;
end;


//========================================================================
//  Redraw
//
//========================================================================
Sub Redraw (
  aDlg      : int;
  aDL       : int;
  aName     : alpha;
  aBereiche : alpha;
  aMitSumme : logic;
  aCharge   : logic;
);
local begin
  vHdl2     : int;
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
  vSumStk     : int;
  vSumM       : float;
end;

begin

  if (Lib_SFX:Check_AFX('Art.Disposition:Redraw')) then begin
    Call(AFX.Prozedur, aDlg, aDL, aName, aBereiche, aMitSumme, aCharge);
    RETURN;
  end;

  aDL->WinLstDatLineRemove(_WinLstDatLineAll);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN;

  BuildTree(vTree, aBereiche, aCharge, (aName='Reservierungen')); // 05.02.2018 AH: Mat.karten ggf. nur einmal aufnehmen? (Unikate)

  if (aMitSumme=n) then begin
    vHdl2 # aDL->WinSearch('ClmSumme');
    vHdl2->wpvisible # false;
    vHdl2 # aDL->WinSearch('ClmSummeStk');
    vHdl2->wpvisible # false;
    vHdl2 # aDL->WinSearch('ClmVorgang');
    vHdl2-> wpclmStretch # true;
  end;
  if (Art.MEH='Stk') then begin
    vHdl2 # aDL->WinSearch('ClmStueck');
    vHdl2->wpvisible # false;
    vHdl2 # aDL->WinSearch('ClmSummeStk');
    vHdl2->wpvisible # false;
  end;


  vHdl3  # aDL->WinSearch('ClmMenge');
  vHdl3->wpCaption # vHdl3->wpCaption+' '+Art.MEH;
  vHdl3->wpFmtPostComma # Set.Stellen.Menge;
  vHdl3->wpClmColBkg # _WinCol3DLight;

  vHdl3  # aDL->WinSearch('ClmSumme');
  vHdl3->wpCaption # vHdl3->wpCaption+' '+Art.MEH;
  vHdl3->wpFmtPostComma # Set.Stellen.Menge;

  vHdl3 # aDL->WinSearch('ClmStueck');
  vHdl3->wpClmColBkg # _WinCol3DLight;

  vMin  #   0.0;
  vMax  # - 10000.0;
  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    vX # CnvIA(vItem->spCustom);
    RecRead(vX % 1000,0,0,vItem->spID);

    vA # '';
    vB # '';
    vI # 0;
    vM # 0.0;
    if (_ParseItem(vX, var vDat, var vA, var vB, var vI, var vM)) then begin
      Eintrag(aDL, vDat, vA, vB, vI,vM, vItem->spCustom+'|'+aint(vItem->spId), var vSumStk, var vSumM);

      if (vSumM<vMin) then vMin # vSumM;
      if (vSumM>vMax) then vMax # vSumM;
    end;

  END;  // nächste Dispo-Position

  Graph(aDL, vMin, vMax);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Anzeigen
  aDL->wpCurrentInt # 1;
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
  vDlg      : int;
  vA        : alpha;
  vDL       : int;
end;
begin

  if (aDLG=0) then
    vDlg # WinOpen('Art.Dispoliste',_WinOpenDialog)
  else
    vDlg # aDLG;
  vDlg->wpCaption # ' '+Translate(aName);

  vHdl # vDlg->WinSearch('Lb.Artikelnr');
  vHdl->wpCaption # Art.Nummer;

  // Parameter sichern
  if (aMitSumme) then vA # 'Y' else vA # 'N';
  if (aCharge) then vA # vA + '|Y' else vA # vA + '|N';
  vHdl->wpCustom # aName+'|'+aBereiche+'|'+vA;

  vHdl # vDlg->WinSearch('Lb.ArtikelSW');
  vHdl->wpCaption # Art.Stichwort;

  vA # ANum(Art.Dicke,Set.Stellen.Dicke)+' x '+ANum(Art.Breite,Set.Stellen.Breite);
  if ("Art.Länge"<>0.0) then vA # vA + ' x '+ANum("Art.Länge","Set.Stellen.Länge");
  vHdl # vDlg->WinSearch('Lb.Abmessung');
  vHdl->wpCaption # vA;

  vHdl # vDlg->WinSearch('Lb.WSt');
  vHdl->wpCaption # Art.Werkstoffnr;

  vHdl # vDlg->WinSearch('Lb.StkGew');
  vHdl->wpCaption # ANum("Art.GewichtProStk",Set.Stellen.Gewicht);

  vDL # vDlg->WinSearch('DL.Dispoliste');
  Redraw(vDlg, vDL, aName, aBereiche, aMitSumme, aCharge);

  if (aDLG<>0) then RETURN;

  vDlg->WinDialogRun(_WinDialogCenter,gMdi);    // ANZEIGEN

  // Beenden
  vDlg->WinClose();
end;


//========================================================================
// BerechneEinenArtikel
//    errechnet im Dipozeitraum die Bedarfsmenge und das Datum aus
//========================================================================
Sub BerechneEinenArtikel(
  aTage           : int;
  var aNeedDat    : date ;
  var aNeedMenge  : float;
  var aNeedStk    : int);
local begin
  vTree       : int;
  vItem       : int;
  vDatei      : int;
  vDat        : date;
  vMaxDat     : date;
  vTheoMenge  : float;
  vMenge      : float;
  vStk        : int;
  vKG         : float;
end;
begin

  if (Art.AutoBestellYN=n) or (aTage=0) then RETURN;

  // Sortierte Dispo generieren
  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN;
  BuildTree(vTree, '250_401_501_701',n);
//BuildTree(vTree,'250_401_-RES_409_501_701',n);

  // Zieldatum der Dispo ermitteln
  vMaxDat # today;
  vMaxDat->vmDayModify(aTage);

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    vDat # cnvdi(CnvIA(StrCut(vItem->spName,1,6)));
    if (vDat<=vMaxDat) then begin
      // Datensatz holen
      vDatei # CnvIA(vItem->spCustom);
      RecRead(vDatei % 1000,0,0,vItem->spID);

      vMenge # 0.0;
      case vDatei of

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
          vMenge #  - (Auf.P.Prd.Rest-Auf.P.Prd.VSB);  // 01.02.2018 AH Dispotest
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


        701 : begin           // BA-Input
//          vStk    # -(BAG.IO.Ist.In.Stk - BAG.IO.Ist.Out.Stk);
//          vMenge  # -(BAG.IO.Ist.In.Menge - BAG.IO.Ist.Out.Menge);
//          vKG     # -(BAG.IO.Ist.In.GewN - BAG.IO.Ist.Out.GewN)
//          vMenge  # Lib_Einheiten:WandleMEH(701, vStk, vKG, vMenge, BAG.IO.MEH.Out, Art.MEH);
          vStk    # -(BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk);
          vMenge  # -(BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge);
          vKG     # -(BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN);
          vMenge  # Lib_Einheiten:WandleMEH(701, vStk, vKG, vMenge, BAG.IO.MEH.In, Art.MEH);
//debug(aNum(vMenge,2)+Art.MEH+'   '+aint(vStk)+'stk   '+anum(vKg,2)+'kg');
        end;
        
        
        1701,2701 : begin     // BA-Output
          vStk    # BAG.IO.Plan.In.Stk - BAG.IO.ist.In.Stk;
          vMenge  # BAG.IO.Plan.In.Menge - BAG.IO.Ist.In.Menge;
          vKG     # BAG.IO.Plan.In.GewN - BAG.IO.Ist.In.GewN
          vMenge  # Lib_Einheiten:WandleMEH(701, vStk, vKG, vMenge, BAG.IO.MEH.In, Art.MEH);
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
Sub Autodispo(opt aDat : date; opt aSilent : logic);
local begin
  Erx       : int;
  v100      : int;
  vTage     : int;
  vProgress : int;
end;
begin

  if (aDat<>0.0.0) then
    vTage # cnvid(aDat) - cnvid(Today);

  APPOFF();

  vProgress # Lib_Progress:Init('Autodisposition', RecInfo(250,_RecCount),true);
  
  v100 # RekSave(100);
  Erx # RecRead(250,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    vProgress->Lib_Progress:Step();

    if (Art.AutoBestellYN) then begin
      if (aDat=0.0.0) then
        vTage # Art.DispoTage;
      if (Bdf_Data:ArtikelAutoDispo(vTage)=false) then begin
        APPON();
        RekRestore(v100);
        if (aSilent) then
          Error(99,'ERROR');
        else
          Msg(99,'ERROR',0,0,0);
        
        RETURN;
      end;
    end;

    Erx # RecRead(250,1,_RecNext);
  END;
  vProgress->Lib_Progress:Term();

  APPON();
  RekRestore(v100);

  // Erfolg!!!
  if (aSilent = false) then
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
  
  vColDat       : int;
  vColM         : int;
end;
begin

  vColDat # Lib_GuiCom2:FindColumn(aDL, 'ClmTermin');
  vColM   # Lib_GuiCom2:FindColumn(aDL, 'ClmMenge');
  if (vColDat=0) or (vColM=0) then RETURN;

  vMaxX     # 1000;
  vMaxY     # 200;
  vDayRange # Max(Min(60, Art.Dispotage), 7);



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
    aDL->WinLstCellGet(vDat, vColDat, vI);
    aDL->WinLstCellGet(vM, vColM, vI);      // Delta
    vBestand  # vM;
    vDat2 # vDat;
    vMaxDat # vDat;
    vMaxDat->vmDayModify(vDayRange-1);

    WHILE (vI<vMax) do begin
      inc(vI);
      aDL->WinLstCellGet(vDat, vColDat, vI);
      aDL->WinLstCellGet(vM, vColM, vI);    // Delta
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
        aDL->WinLstCellGet(vDat, vColDat, vI);
        aDL->WinLstCellGet(vM, vColM, vI);    // Delta
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
x      aDL->WinLstCellGet(vDat, 1, vI);
x      aDL->WinLstCellGet(vM, 7, vI);

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