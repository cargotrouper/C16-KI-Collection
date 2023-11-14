@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Lfs
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Formularen
//
//
//  20.11.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB Parse440(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aSpediAdr : int; aStartAS : int) : int;
//  SUB Parse440Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aSpediAdr : int; aStartAS : int) : int
//  SUB Parse441(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse441Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; opt aKombi : logic) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  Parse440
//=======================================================================
Sub Parse440(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic;

  aSpediAdr   : int;
  aStartAS    : int;
  ) : int;
local begin
  erx         : int;
  vTitel      : alpha(4096);
  vA,vA2,vA3  : alpha(4096);
  vPre        : alpha(4096);
  vPost       : alpha(4096);
  vI          : int;
  vZeilen     : int;
  vFeld       : alpha(4096);
  vAdd        : alpha(4096);
end;
begin



  // Sonderbefehl?
  if (StrCut(aText,1,2)='my') then begin
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      ErrTryCatch(_ErrNoSub,y);
      vZeilen # Call(FRM.Prozedur+':Parse',var aLabels, var aInhalt, var aZusatz, aText, aKombi);
      RETURN vZeilen;
    end;
  end;

  vFeld   # Str_Token(aText, '|', 1);
  vTitel  # Str_Token(aText, '|', 2);
  vPost   # Str_Token(aText, '|', 3);
  vPre    # Str_Token(aText, '|', 4);

//if (vCustom=false) then
//case vCode of
//    case StrCut(StrCnv(vCode, _StrUpper),2,50) of


  case (StrCnv(vFeld, _StrUpper)) of
    'LIEFERSCHEIN' :        vAdd # aint(Lfs.Nummer);
    'DATUM' :               if (Lfs.LieferDatum<>0.0.0) then vAdd # cnvad(Lfs.Lieferdatum);
    'BAG' :                 if (Lfs.zuBA.Nummer<>0) then vAdd # aint(Lfs.zuBA.Nummer)+'/'+aint(Lfs.zuBA.Position);
    'KENNZEICHEN' :         vAdd # Lfs.Kennzeichen;
    'FAHRER' :              vAdd # Lfs.Fahrer;
    'LFS.REFERENZNR' :      vAdd # Lfs.Referenznr;

    // Startanschrift
    'START.NAME'    :       if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Name;
    'START.ANREDE'  :       if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Anrede;
    'START.ZUSATZ'  :       if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Zusatz;
    'START.STRASSE' :       if (aStartAS<>0) then vAdd # aStartAS->"Adr.A.Straße";
    'START.ORT'  :          if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Ort
    'START.PLZ'  :          if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Plz;
    'START.ANNAHME1' :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme1;
    'START.ANNAHME2' :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme3;
    'START.ANNAHME3' :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme3;
    'START.ANNAHME4' :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme4;
    'START.ANNAHME5' :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme5;
    'START.FERIEN'   :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Betriebsferien;

    // Zielanschrift
    'ZIEL.NAME'    :        vAdd # Adr.A.Name;
    'ZIEL.ANREDE'  :        vAdd # Adr.A.Anrede;
    'ZIEL.ZUSATZ'  :        vAdd # Adr.A.Zusatz;
    'ZIEL.STRASSE' :        vAdd # "Adr.A.Straße";
    'ZIEL.ORT'  :           vAdd # Adr.A.Ort
    'ZIEL.PLZ'  :           vAdd # Adr.A.Plz;
    'ZIEL.ANNAHME1' :       vAdd # Adr.A.Warenannahme1;
    'ZIEL.ANNAHME2' :       vAdd # Adr.A.Warenannahme3;
    'ZIEL.ANNAHME3' :       vAdd # Adr.A.Warenannahme3;
    'ZIEL.ANNAHME4' :       vAdd # Adr.A.Warenannahme4;
    'ZIEL.ANNAHME5' :       vAdd # Adr.A.Warenannahme5;
    'ZIEL.FERIEN'   :       vAdd # Adr.A.Betriebsferien;
    'ZIEL.LAND' :           begin
                            Erx # RecLink(812,101,2,0);
                            vAdd # Lnd.Name.L2;
    end;

    // Kunde
    'KUNDE' :               if (Adr.Nummer <> Adr.A.Adressnr) and (Adr.Nummer<>0) then begin
                              vA  # StrAdj(Adr.Anrede,_StrBegin | _StrEnd)  + ' ' +
                                      StrAdj(Adr.Name,_StrBegin | _StrEnd)    + ' ' +
                                      StrAdj(Adr.Zusatz,_StrBegin | _StrEnd);
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                              vTitel # '';
                              aInhalt # aInhalt + StrChar(10);
                              aLabels # aLabels + StrChar(10);
                              aZusatz # aZusatz + StrChar(10);

                              vA #  StrAdj(Adr.PLZ,_StrBegin | _StrEnd) + ' ' +
                                    StrAdj(Adr.Ort,_StrBegin | _StrEnd)  + ', ' +
                                    StrAdj("Adr.Straße",_StrBegin | _StrEnd);
                              vAdd # vA;
                            end;
    'ADR.ANREDE' :          vAdd # Adr.Anrede;
    'ADR.NAME' :            vAdd # Adr.Name;
    'ADR.ZUSATZ' :          vAdd # Adr.Zusatz;
    'ADR.STRASSE' :         vAdd # "Adr.Straße";
    'ADR.PLZ' :             vAdd # Adr.PLZ;
    'ADR.ORT' :             vAdd # Adr.Ort;
    'KUNDENNR' :            if (Adr.Kundennr<>0) then vAdd # aint(Adr.Kundennr);
    'ADR.VK.REFERENZNR' :   vAdd # Adr.VK.Referenznr;
    'ADR.USIDENTNR' :       vAdd # Adr.UsIdentNr;

    // Spediteur
    'SPEDITEUR' :           if (aSpediAdr<>0) then begin
                              vA  # StrAdj(aSpediAdr->Adr.Anrede,_StrBegin | _StrEnd)  + ' ' +
                                      StrAdj(aSpediAdr->Adr.Name,_StrBegin | _StrEnd)    + ' ' +
                                      StrAdj(aSpediAdr->Adr.Zusatz,_StrBegin | _StrEnd);
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                              vTitel # '';
                              aInhalt # aInhalt + StrChar(10);
                              aLabels # aLabels + StrChar(10);
                              aZusatz # aZusatz + StrChar(10);

                              vA #  StrAdj(aSpediAdr->Adr.PLZ,_StrBegin | _StrEnd) + ' ' +
                                    StrAdj(aSpediAdr->Adr.Ort,_StrBegin | _StrEnd)  + ', ' +
                                    StrAdj(aSpediAdr->"Adr.Straße",_StrBegin | _StrEnd);
                              vAdd # vA;
                              end
                            else begin
                              vAdd # LFs.Spediteur;
                            end;

    otherwise           begin
                          // Allgemeiner Befehl?
                          if (ParseAllgemein(var aLabels, var aInhalt, var aZusatz, vFeld, vTitel, vPost, vPre, aKombi, var vZeilen)) then RETURN vZeilen;

                          // unbekannt?
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, '?'+vTitel, '?'+vFeld, vPre, vPost, aKombi);
                        end;
  end;

  if (vAdd<>'') then begin
    inc(vZeilen);
    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
  end;

  RETURN vZeilen;
end;


//=======================================================================
//  Parse440Multi
//=======================================================================
sub Parse440Multi(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  aKombi      : logic;

  aSpediAdr   : int;
  aStartAS    : int;
  ) : int
local begin
  vCap        : alpha(4096);
  vRow        : alpha(4096);
  vToken      : alpha(4096);
  vA          : alpha(4096);
  vPre,vPost  : alpha(4096);
  vI,vJ       : int;
  vK,vL       : int;
  vOK         : logic;
  vZ          : int;
  vZeilen     : int;
  vTmp,vMax   : int;
end;
begin

  aLabels # '';
  aInhalt # '';
  aZusatz # '';

  vCap # GetCaption(aObjName);

  vJ # 1 + Lib_Strings:Strings_Count(vCap, StrChar(13)+StrChar(10));
  FOR vI # 1 loop inc(vI) WHILE (vI<=vJ) do begin
    vRow # Str_Token(vCap, StrChar(13)+StrChar(10), vI);
    vOK # n;
    vL # Lib_Strings:Strings_Count(vRow, '@');

    vZ # 0;
    if (vL=0) then begin//and (vRow<>'') then begin
        AddLIZ(var aLabels, var aInhalt, var aZusatz, '', vRow, '','', aKombi);
      inc(vZ);
      end
    else begin
      vMax # 0;
      FOR vK # 1 loop inc(vK) WHILE (vK<=vL) do begin
        vToken # Str_Token(vRow, '@', vK+1);
        vTmp # Parse440(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aSpediAdr, aStartAS);
        if (vTmp<0) then RETURN vTmp;
        vMax # Max(vTmp, vMax);
      END;
      vZ # vZ + vMax;
    end;
    if (vZ>0) then begin
      aInhalt # aInhalt + StrChar(10);
      aLabels # aLabels + StrChar(10);
      aZusatz # aZusatz + StrChar(10);
      vZeilen # vZeilen + vZ;
    end;
  END;

  RETURN vZeilen;

end;


//=======================================================================
//  Parse441
//=======================================================================
sub Parse441(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic) : int;
local begin
  vA      : alpha(4096);
  vA2     : alpha(4096);
  vAdd    : alpha(4096);
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vZeilen : int;
  vErg    : int;
end;
begin

  // Sonderbefehl?
  if (StrCut(aText,1,2)='my') then begin
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      ErrTryCatch(_ErrNoSub,y);
      vZeilen # Call(FRM.Prozedur+':Parse',var aLabels, var aInhalt, var aZusatz, aText, aKombi);
      RETURN vZeilen;
    end;
  end;

  vFeld   # Str_Token(aText, '|', 1);
  vTitel  # Str_Token(aText, '|', 2);
  vPost   # Str_Token(aText, '|', 3);
  vPre    # Str_Token(aText, '|', 4);

  case (StrCnv(vFeld, _StrUpper)) of
    'POSITION' :        vAdd # aint(Lfs.P.Position);
    'WGR' :             vAdd # Wgr.Bezeichnung.L1;
    'KOMMISSION' :      vAdd # Lfs.P.Kommission;

    'MATERIALNR' :      vAdd # aint(Lfs.P.Materialnr);
    'COILNR'  :         vAdd # Mat.Coilnummer;
    'WERKSNR' :         vAdd # Mat.Werksnummer;
    'CHARGENNR' :       vAdd # Mat.Chargennummer;
    'RINGNR' :          vAdd # Mat.Ringnummer;
    'ABMESSUNG' :       begin
                          if (Mat.Dicke<>0.0) then vAdd # anum(Mat.Dicke, Set.Stellen.Dicke);
                          if (Mat.Breite<>0.0) then begin
                            if (vAdd<>'') then vAdd # vAdd + ' x ';
                            vAdd # vAdd + anum(Mat.Breite, Set.Stellen.Breite);
                            if ("Mat.Länge"<>0.0) then
                              vAdd # vAdd + ' x ' + anum("Mat.Länge", "Set.Stellen.Länge");
                          end;
                        end;

    'DICKE' :           if (Mat.Dicke<>0.0) then
                          vAdd # anum(Mat.Dicke,Set.Stellen.Dicke);
    'DICKENTOL' :       vAdd # Mat.Dickentol;
    'BREITE' :          if (Mat.Breite<>0.0) then
                          vAdd # aNum(Mat.Breite, Set.Stellen.Breite);
    'BREITENTOL' :      vAdd # Mat.Breitentol;
    'LÄNGE' :           if ("Mat.Länge"<>0.0) then
                          vAdd # aNum("Mat.Länge", "Set.Stellen.Länge");
    'LÄNGENNTOL' :      vAdd # "Mat.Längentol";
    'GÜTE' :            vAdd # "Mat.Güte";
    'AF_OS_KUEZ' :      vAdd # "Mat.AusführungOben";
    'AF_US_KURZ' :      vAdd # "Mat.AusführungUnten";
    'AF_OS_LANG' :      FOR vErg # RecLink(201,200,11,_recFirst)  // Ausführungen loopen
                        LOOP vErg # RecLink(201,200,11,_recNext)
                        WHILE (vErg<=_rLocked) do begin
                          if (Mat.AF.Seite<>'1') then CYCLE;
                          vA # Mat.AF.Bezeichnung;
                          if (Mat.AF.Zusatz<>'') then vA # vA + ' '+Mat.AF.Zusatz;
                          if (vZeilen>0) then begin
                            aInhalt # aInhalt + StrChar(10);
                            aLabels # aLabels + StrChar(10);
                            aZusatz # aZusatz + StrChar(10);
                          end;
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                          vPre # '';
                        END;
    'AF_US_LANG' :      FOR vErg # RecLink(201,200,11,_recFirst)  // Ausführungen loopen
                        LOOP vErg # RecLink(201,200,11,_recNext)
                        WHILE (vErg<=_rLocked) do begin
                          if (Mat.AF.Seite<>'2') then CYCLE;
                          vA # Mat.AF.Bezeichnung;
                          if (Mat.AF.Zusatz<>'') then vA # vA + ' '+Mat.AF.Zusatz;
                          if (vZeilen>0) then begin
                            aInhalt # aInhalt + StrChar(10);
                            aLabels # aLabels + StrChar(10);
                            aZusatz # aZusatz + StrChar(10);
                          end;
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                          vPre # '';
                        END;


    'ART.DICKE' :       if (Art.C.Dicke<>0.0) then
                          vAdd # anum(Art.C.Dicke,Set.Stellen.Dicke);
    'ART.BREITE' :      if (Art.Breite<>0.0) then
                          vAdd # aNum(Art.C.Breite, Set.Stellen.Breite);
    'ART.LÄNGE' :       if ("Art.Länge"<>0.0) then
                          vAdd # aNum("Art.C.Länge", "Set.Stellen.Länge");
    'ARTIKELNR' :       vAdd # Lfs.P.Artikelnr;
    'ART.BEZ1' :        vAdd # Art.Bezeichnung1;
    'ART.BEZ2' :        vAdd # Art.Bezeichnung2;
    'ART.BEZ3' :        vAdd # Art.Bezeichnung3;
    'ART.SACHNUMMER' :  vAdd # Art.Sachnummer;


    'STÜCK' :         if ("Lfs.P.Stück"<>0) then
                        vAdd # aint("Lfs.P.Stück");
    'MENGE' :         if (Lfs.P.MEH='kg') or (lfs.P.MEH='t') then begin
                        // Stück ausgeben
                        if ("Lfs.P.Stück"<>0) then
                          vAdd # aint("Lfs.P.Stück");
                        end
                      else if ("Lfs.P.Menge"<>0.0) then begin
                        if (Lfs.P.MEH='Stk') then
                          vAdd # anum("Lfs.P.Menge", 0)
                        else
                          vAdd # anum("Lfs.P.Menge", Set.Stellen.Menge);
                      end;
    'MENGE+MEH' :     if (Lfs.P.MEH='kg') or (lfs.P.MEH='t') then begin
                        // Stück ausgeben
                        if ("Lfs.P.Stück"<>0) then
                          vAdd # aint("Lfs.P.Stück")+' Stk';;
                        end
                      else if ("Lfs.P.Menge"<>0.0) then begin
                        if (Lfs.P.MEH='Stk') then
                          vAdd # anum("Lfs.P.Menge", 0)+' '+Lfs.P.MEH
                        else
                          vAdd # anum("Lfs.P.Menge", Set.Stellen.Menge)+' '+Lfs.P.MEH;
                      end;
    'GGFSTÜCK' :     if ("Lfs.P.Stück"<>0) and (Lfs.P.MEH<>'Stk') and (Lfs.P.Meh<>'kg') and(Lfs.P.Meh<>'t') then
                        vAdd # aint("Lfs.P.Stück");

    'GEWICHT.NETTO' : if ("Lfs.P.Gewicht.Netto"<>0.0) then
                        vAdd # anum("Lfs.P.Gewicht.Netto", Set.Stellen.Gewicht);
    'GEWICHT.NETTO.WENNNETTO' : if ("Lfs.P.Gewicht.Netto"<>0.0) and (VWa.NettoYN) then
                                  vAdd # anum("Lfs.P.Gewicht.Netto", Set.Stellen.Gewicht);
    'GEWICHT.BRUTTO' :  if ("Lfs.P.Gewicht.Brutto"<>0.0) then
                          vAdd # anum("Lfs.P.Gewicht.Brutto", Set.Stellen.Gewicht);

    'BEST.NUMMER' :   vAdd # Auf.P.Best.Nummer;
    'RID' :           if (Mat.RID<>0.0) then
                        vAdd # anum(Mat.RID, Set.Stellen.Radien);
    'RAD' :           if (Mat.RAD<>0.0) then
                        vAdd # anum(Mat.RAD, Set.Stellen.Radien);
    'MEH' :         vAdd # Lfs.P.MEH;
    'KUNDENARTNR' : vAdd # Auf.P.KundenArtNr;
    'INTRASTAT' :   vAdd # Auf.P.IntraStatNr;
    'BEMERKUNG' :   vAdd # Lfs.P.Bemerkung;

    otherwise           begin
                          // Allgemeiner Befehl?
                          if (ParseAllgemein(var aLabels, var aInhalt, var aZusatz, vFeld, vTitel, vPost, vPre, aKombi, var vZeilen)) then RETURN vZeilen;

                          // unbekannt?
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, '?'+vTitel, '?'+vFeld, vPre, vPost, aKombi);
                        end;
  end;  // case

  if (vAdd<>'') then begin
    inc(vZeilen);
    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
  end;


  RETURN vZeilen;
end;


//=======================================================================
//  Parse441Multi
//=======================================================================
sub Parse441Multi(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  opt aKombi  : logic) : int
local begin
  vCap        : alpha(4096);
  vRow        : alpha(4096);
  vToken      : alpha(4096);
  vA          : alpha(4096);
  vI,vJ       : int;
  vK,vL       : int;
  vOK         : logic;
  vZ          : int;
  vZeilen     : int;
  vTmp,vMax   : int;
end;
begin
// @Dicke|pre|post@Breite|pre|post@Länge|pre|post
// @Dicke mm
// je @Breite

  aLabels # '';
  aInhalt # '';
  aZusatz # '';

  vCap # GetCaption(aObjName);

  vJ # 1 + Lib_Strings:Strings_Count(vCap, StrChar(13)+StrChar(10));
  FOR vI # 1 loop inc(vI) WHILE (vI<=vJ) do begin
    vRow # Str_Token(vCap, StrChar(13)+StrChar(10), vI);
    vOK # n;
    vL # Lib_Strings:Strings_Count(vRow, '@');

    vZ # 0;
    if (vL=0) then begin //and (vRow<>'') then begin
        AddLIZ(var aLabels, var aInhalt, var aZusatz, '', vRow, '','', aKombi);
      inc(vZ);
      end
    else begin
      vMax # 0;
      FOR vK # 1 loop inc(vK) WHILE (vK<=vL) do begin
        vToken # Str_Token(vRow, '@', vK+1);
        vTmp # Parse441(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
        if (vTmp<0) then RETURN vTmp;
        vMax # Max(vTmp, vMax);
      END;
      vZ # vZ + vMax;
    end;
    if (vZ>0) then begin
      aInhalt # aInhalt + StrChar(10);
      aLabels # aLabels + StrChar(10);
      aZusatz # aZusatz + StrChar(10);
      vZeilen # vZeilen + vZ;
    end;
  END;

  RETURN vZeilen;

end;


//=======================================================================
//=======================================================================
