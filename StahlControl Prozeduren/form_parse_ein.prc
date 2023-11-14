@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Ein
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Bestell-Formularen
//
//
//  07.11.2012  AI  Erstellung der Prozedur
//  18.10.2013  AH  Anfragen
//
//  Subprozeduren
//  SUB Parse500(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int) : int;
//  SUB Parse500Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int) : int
//  SUB Parse501(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse501Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; opt aKombi : logic) : int
//  SUB Parse503(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aGesamtpreis : float) : int;
//  SUB Parse503Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aGesamtPreis : float) : int
//  SUB AnalyseBereich(aWert : float; aMin : float; aMax : float) : alpha;
//  SUB Parse839(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse839Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  Parse500
//=======================================================================
Sub Parse500(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic;

  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int;
  ) : int;
local begin
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

  if Form_DokSprache = 'E' then begin
    vzeilen # Form_Parse_Ein_E:Parse500(var aLabels, var aInhalt, var aZusatz,aText,aKombi,aBuf100Re,aBuf101We,aBuf110Ver1,aBuf110Ver2);
    RETURN(vZeilen);
  end;

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
    'ADR.ANREDE','ADR.A.ANREDE' :
                            vAdd # Adr.Anrede;
    'ADR.NAME', 'ADR.A.NAME' :
                            vAdd # Adr.Name;
    'ADR.ZUSATZ', 'ADR.A.ZUSATZ' :
                            vAdd # Adr.Zusatz;
    'ADR.STRASSE', 'ADR.A.STRASSE' :
                            vAdd # "Adr.Straße";
    'ADR.STRASSEWENNKEINPOSTFACH' :
                            if (Adr.Postfach='') then vAdd # "Adr.Straße";
    'ADR.PLZ', 'ADR.A.PLZ' :
                            vAdd # Adr.PLZ;
    'ADR.PLZWENNKEINPOSTFACH' :
                            if (Adr.Postfach='') then vAdd # Adr.PLZ;
    'ADR.ORT','ADR.A.ORT' :
                            vAdd # Adr.Ort;
    'ADR.POSTFACH' :        vAdd # Adr.Postfach;
    'ADR.POSTFACH.PLZ' :    vAdd # Adr.Postfach.PLZ;
    'ADR.LAND','ADR.A.LAND' :
                            vAdd # Lnd.Name.L1;

    'DATUM' :               if (Ein.Datum<>0.0.0) then        vAdd # cnvad(Ein.Datum);
    'LIEFERANTENNR' :       vAdd # aint(Ein.Lieferantennr);
    'ADR.EK.REFERENZNR' :   vAdd # Adr.EK.Referenznr;
    'ADR.USIDENTNR' :       vAdd # Adr.USidentNr;
    'READR.USIDENTNR' :     if (aBuf100re->Adr.UsIdentNr<>'') then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aBuf100Re->Adr.UsIdentNr, vPre, vPost, aKombi);
                            end;
    'READR.STEUERNUMMER' :  if (aBuf100Re->Adr.Steuernummer<>'') then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aBuf100Re->Adr.Steuernummer, vPre, vPost, aKombi);
                            end;
    'AB.NUMMER' :           if (Ein.AB.Nummer<>'') then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.AB.Nummer, vPre, vPost, aKombi);
                            end;
    'AB.DATUM' :            if (Ein.AB.Datum<>0.0.0) then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, cnvad(Ein.AB.Datum), vPre, vPost, aKombi);
                            end;
    'BEST.PARTNER' :        begin
                              vAdd # EIN.AB.Bearbeiter;
                              if ((vAdd <> '') AND (StrLen(vAdd) > 4)) then
                                  if (StrCut(vAdd,1,1) = '#') then
                                    vAdd # StrCut(vAdd, StrFind(vAdd, ':', 1) + 1,StrLen(vAdd) - StrFind(vAdd, ':', 1) + 1);
                            end;
    'VERTRETER1' :          if (aBuf110Ver1<>0) then
                            if (aBuf110Ver1->Ver.Name<>'') then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aBuf110Ver1->Ver.Name, vPre, vPost, aKombi);
                            end;
    'VERTRETER2' :          if (aBuf110Ver2<>0) then
                            if (aBuf110Ver2->Ver.Name<>'') then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aBuf110Ver2->Ver.Name, vPre, vPost, aKombi);
                            end;
    'TITEL'       : begin
                      if (Ein.Vorgangstyp=c_Anfrage) then
                        vA # 'Anfrage ' + ' ' + AInt(Ein.P.Nummer)
                      else if ("Ein.LiefervertragYN") and (!"Ein.AbrufYN") then
                        vA # 'Rahmenvertrag-EK ' + AInt("Ein.P.Nummer")
                      else if ("Ein.AbrufYN") and (!"Ein.LiefervertragYN") then
                        vA # 'Bestellung ' + AInt("Ein.P.Nummer")+' aus Rahmenvertrag ' + AInt("Ein.P.AbrufAufNr")
                      else
                        vA # 'Bestellung' + ' ' + AInt(Ein.P.Nummer);
                      if (vA<>'') and (Frm.Markierung<>'') then
                        vA # vA +'     '+Frm.Markierung;
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end
                    end;

    'TITELZUSATZ' : begin
                      if ("Ein.GültigkeitVom"<>0.0.0) or ("Ein.GültigkeitBis"<>0.0.0) then begin
                        vA3 # ' (gültig ';
                        if ("Ein.GültigkeitVom"<>0.0.0) then
                          vA3 # vA3 + ' ab '+cnvad("Ein.GültigkeitVom");
                        if ("Ein.GültigkeitBis"<>0.0.0) then
                          vA3 # vA3 + ' bis '+cnvad("Ein.GültigkeitBis");
                        vA3 # vA3 + ')';
                      end;
                      vA # 'Hiermit bestellen wir wie folgt:'+vA3;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
    'RECHNUNGSEMPFAENGER' :
                    if (Ein.Lieferantennr <> aBuf100Re->Adr.Lieferantennr) and
                      (aBuf100Re->Adr.Lieferantennr<>0)then begin
                      // Firmenbezeichnung in erste Zeile
                      vA #  StrAdj(aBuf100Re -> Adr.Anrede,_StrBegin | _StrEnd)  + ' ' +
                            StrAdj(aBuf100Re -> Adr.Name,_StrBegin | _StrEnd)    + ' ' +
                            StrAdj(aBuf100Re -> Adr.Zusatz,_StrBegin | _StrEnd);
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                      vTitel # '';
                      aInhalt # aInhalt + StrChar(10);
                      aLabels # aLabels + StrChar(10);
                      aZusatz # aZusatz + StrChar(10);
                      // Adresse in zweite Zeile
                      vA # '';
                      // Post zum Postfach?
                      if (aBuf100Re->Adr.Postfach <> '') then begin
                        vA # 'Postfach ' +
                              StrAdj(aBuf100Re -> Adr.Postfach,_StrBegin | _StrEnd)    + ', '+
                              StrAdj(aBuf100Re -> Adr.Postfach.PLZ,_StrBegin | _StrEnd)+ ' ' +
                              StrAdj(aBuf100Re -> Adr.Ort,_StrBegin | _StrEnd);
                        end
                      else begin
                        vA #  StrAdj(aBuf100Re -> Adr.PLZ,_StrBegin | _StrEnd)      + ' ' +
                              StrAdj(aBuf100Re -> Adr.Ort,_StrBegin | _StrEnd)      + ', ';
                              StrAdj(aBuf100Re -> "Adr.Straße",_StrBegin | _StrEnd);
//                                StrAdj(aBuf100Re -> Adr.LKZ,_StrBegin | _StrEnd)       + '-' +
                      end;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                    end;
    'WARENEMPFAENGER' :
                      if ((Adr.A.Adressnr <> Ein.Lieferadresse) or
                        (aBuf101We->Adr.A.Nummer > 1)) then begin
                      vA  # StrAdj(aBuf101We->Adr.A.Anrede,_StrBegin | _StrEnd)  + ' ' +
                              StrAdj(aBuf101We->Adr.A.Name,_StrBegin | _StrEnd)    + ' ' +
                              StrAdj(aBuf101We->Adr.A.Zusatz,_StrBegin | _StrEnd);
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                      vTitel # '';
                      aInhalt # aInhalt + StrChar(10);
                      aLabels # aLabels + StrChar(10);
                      aZusatz # aZusatz + StrChar(10);

                      vA #  StrAdj(aBuf101We->Adr.A.PLZ,_StrBegin | _StrEnd) + ' ' +
                            StrAdj(aBuf101We->Adr.A.Ort,_StrBegin | _StrEnd)  + ', ' +
//                              StrAdj(aBuf101We->Adr.A.LKZ,_StrBegin | _StrEnd)    + '-' +
                            StrAdj(aBuf101We->"Adr.A.Straße",_StrBegin | _StrEnd);
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, StrAdj(vA,_Strbegin), vPre, vPost, aKombi);
                    end;

    'WARENANNAHME1'   : begin
                          vA # StrAdj(aBuf101We->Adr.A.Warenannahme1,_StrBegin | _StrEnd);
                          vAdd # vA;
                        end;
    'WARENANNAHME2'   : begin
                          vA # StrAdj(aBuf101We->Adr.A.Warenannahme2,_StrBegin | _StrEnd);
                          vAdd # vA;
                        end;
    'WARENANNAHME3'   : begin
                          vA # StrAdj(aBuf101We->Adr.A.Warenannahme3,_StrBegin | _StrEnd);
                          vAdd # vA;
                        end;
    'WARENANNAHME4'   : begin
                          vA # StrAdj(aBuf101We->Adr.A.Warenannahme4,_StrBegin | _StrEnd);
                          vAdd # vA;
                        end;
    'WARENANNAHME5'   : begin
                          vA # StrAdj(aBuf101We->Adr.A.Warenannahme5,_StrBegin | _StrEnd);
                          vAdd # vA;
                        end;
    'BETRFERIEN'   :    begin
                          vA # StrAdj(aBuf101We->Adr.A.Betriebsferien,_StrBegin | _StrEnd);
                          vAdd # vA;
                        end;


    'LIB.BEZEICHNUNG'  :  if (Lib.Bezeichnung.L1<>'') then begin
                            inc(vZeilen);
                            AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Lib.Bezeichnung.L1, vPre, vPost, aKombi);
                          end;
    'VSA.BEZEICHNUNG' :   if (VsA.Bezeichnung.L1<>'') then begin
                            inc(vZeilen);
                            AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, VSa.Bezeichnung.L1, vPre, vPost, aKombi);
                          end;
    'ZAB.BEZEICHNUNG' :   begin
                            vA # ZaB.Bezeichnung1.L1;
                            if (ZaB.Bezeichnung2.L2<>'') then vA # vA + ' ' +ZaB.Bezeichnung2.L1;
                            vA # Ofp_data:BuildZabString(vA, 0.0.0,0.0.0);
                            if (vA<>'') then begin
                              inc(vZeilen);
                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                              vTitel # '';
                            end;
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
//  Parse500Multi
//=======================================================================
sub Parse500Multi(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  aKombi      : logic;

  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int;
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

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse500Multi(var aLabels, var aInhalt, var aZusatz,aObjName,aKombi,aBuf100Re,aBuf101We,aBuf110Ver1,aBuf110Ver2);
    RETURN(vZeilen);
  end;

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
        vTmp # Parse500(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
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
//  Parse501
//=======================================================================
sub Parse501(
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

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse501(var aLabels, var aInhalt, var aZusatz,aText,aKombi);
    RETURN(vZeilen);
  end;

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
    'POSITION' :    begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aint(Ein.P.Position), vPre, vPost, aKombi);
                    end;
    'DICKE' :       if (Ein.P.Dicke<>0.0) then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(Ein.P.Dicke,Set.Stellen.Dicke), vPre, vPost, aKombi, Ein.P.Dickentol);
                    end;
    'DICKENTOL' :   if (Ein.P.Dickentol<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Dickentol, vPre, vPost, aKombi);
                    end;
    'BREITE' :      if (Ein.P.Breite<>0.0) then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aNum(Ein.P.Breite, Set.Stellen.Breite), vPre, vPost, aKombi, Ein.P.Breitentol);
                    end;
    'BREITENTOL' :  if (Ein.P.Breitentol<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Breitentol, vPre, vPost, aKombi);
                    end;
    'LÄNGE' :       if ("Ein.P.Länge"<>0.0) then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aNum("Ein.P.Länge", "Set.Stellen.Länge"), vPre, vPost, aKombi, "Ein.P.Längentol");
                    end;
    'LÄNGENTOL' :   if ("Ein.P.Längentol"<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, "Ein.P.Längentol", vPre, vPost, aKombi);
                    end;
    'GÜTE' :        if ("Ein.P.Güte"<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, "Ein.P.Güte", vPre, vPost, aKombi);
                    end;
    'WGR' :         if (Wgr.Bezeichnung.L1<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, "Wgr.Bezeichnung.L1", vPre, vPost, aKombi);
                    end;
    'STÜCK' :       if ("Ein.P.Stückzahl"<>0) then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aint("Ein.P.Stückzahl"), vPre, vPost, aKombi);
                    end;
    'MENGE' :       if ("Ein.P.Menge.Wunsch"<>0.0) then begin
                      inc(vZeilen);
                      if (Ein.P.MEH.Wunsch='kg') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge.Wunsch", Set.Stellen.Gewicht), vPre, vPost, aKombi)
                      else if (Ein.P.MEH.Wunsch='Stk') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge.Wunsch", 0), vPre, vPost, aKombi)
                      else
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge.Wunsch", Set.Stellen.Menge), vPre, vPost, aKombi);
                    end;
    'MENGE+MEH' :   if ("Ein.P.Menge.Wunsch"<>0.0) then begin
                      inc(vZeilen);
                      if (Ein.P.MEH.Wunsch='kg') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge.Wunsch", Set.Stellen.Gewicht)+' '+Ein.P.MEH.Wunsch, vPre, vPost, aKombi)
                      else if (Ein.P.MEH.Wunsch='Stk') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge.Wunsch", 0)+' '+Ein.P.MEH.Wunsch, vPre, vPost, aKombi)
                      else
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge.Wunsch", Set.Stellen.Menge)+' '+Ein.P.MEH.Wunsch, vPre, vPost, aKombi);
                    end;
    'MENGE2' :      if ("Ein.P.Menge"<>0.0) then begin
                      inc(vZeilen);
                      if (Ein.P.MEH='kg') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge", Set.Stellen.Gewicht), vPre, vPost, aKombi)
                      else if (Ein.P.MEH='Stk') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge", 0), vPre, vPost, aKombi)
                      else
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge", Set.Stellen.Menge), vPre, vPost, aKombi);
                    end;
    'MENGE2+MEH' :   if ("Ein.P.Menge"<>0.0) then begin
                      inc(vZeilen);
                      if (Ein.P.MEH='kg') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge", Set.Stellen.Gewicht)+' '+Ein.P.MEH, vPre, vPost, aKombi)
                      else if (Ein.P.MEH='Stk') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge", 0)+' '+Ein.P.MEH, vPre, vPost, aKombi)
                      else
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Menge", Set.Stellen.Menge)+' '+Ein.P.MEH, vPre, vPost, aKombi);
                    end;
    'GEWICHT' :    if ("Ein.P.Gewicht"<>0.0) then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.P.Gewicht", Set.Stellen.Gewicht), vPre, vPost, aKombi);
                    end;
    'TERMIN' :      begin
                      inc(vZeilen);
                      if (Ein.P.Termin1W.Art = 'DA') then begin
                        vA # CnvAd(Ein.P.Termin1Wunsch);
                        end
                      else if (Ein.P.Termin1W.Art = 'KW') then begin
                        vA # 'KW ' + CnvAi(Ein.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                                     CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'MO') then begin
                        vA # Lib_Berechnungen:Monat_aus_datum(Ein.P.Termin1Wunsch) + ' ' +
                                 CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'QU') then begin
                        vA # CnvAi(Ein.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
                             CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'SE') then begin
                        vA # CnvAi(Ein.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
                             CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'JA') then begin
                        vA # 'Jahr ' +  CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup);
                      end;
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
    'ZUSAGETERMIN' :  if (Ein.P.TerminZusage<>0.0.0) then begin
                      inc(vZeilen);
                      if (Ein.P.Termin1W.Art = 'DA') then begin
                        vA # CnvAd(Ein.P.TerminZusage);
                        end
                      else if (Ein.P.Termin1W.Art = 'KW') then begin
                        vA # 'KW ' + CnvAi(Ein.P.TerminZ.Zahl,_FmtNumLeadZero) + '/' +
                                     CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'MO') then begin
                        vA # Lib_Berechnungen:Monat_aus_datum(Ein.P.TerminZusage) + ' ' +
                                 CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'QU') then begin
                        vA # CnvAi(Ein.P.TerminZ.Zahl,_FmtNumNoZero) + '. Quartal ' +
                             CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'SE') then begin
                        vA # CnvAi(Ein.P.TerminZ.Zahl,_FmtNumNoZero) + '. Semester ' +
                             CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup);
                        end
                      else if (Ein.P.Termin1W.Art = 'JA') then begin
                        vA # 'Jahr ' +  CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup);
                      end;
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
//    'TERMINZUSATZ' : if (Ein.P.Termin.Zusatz<>'') then begin
//                      inc(vZeilen);
//                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Termin.zusatz, vTitel, vPost, aKombi);
//                    end;
    'AF_OS_KUEZ' :  if (Ein.P.AusfOben<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.AusFOben, vPre, vPost, aKombi);
                    end;
    'AF_US_KURZ' :  if (Ein.P.AusfUnten<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.AusFUnten, vPre, vPost, aKombi);
                    end;
    'AF_OS+US_KURZ' :  begin
                    vAdd # Ein.P.AusfOben;
                    if (Ein.P.AusfUnten <> '') then
                      vAdd # vAdd + ', ';
                    vAdd # vAdd +  Auf.P.AusfUnten;
                    end;
    'AF_OS_LANG' :  FOR vErg # RecLink(502,501,12,_recFirst)  // Ausführungen loopen
                    LOOP vErg # RecLink(502,501,12,_recNext)
                    WHILE (vErg<=_rLocked) do begin
                      if (Ein.AF.Seite<>'1') then CYCLE;
                      vA # Ein.AF.Bezeichnung;
                      if (Ein.AF.Zusatz<>'') then vA # vA + ' '+Ein.AF.Zusatz;
                      if (vZeilen>0) then begin
                        aInhalt # aInhalt + StrChar(10);
                        aLabels # aLabels + StrChar(10);
                        aZusatz # aZusatz + StrChar(10);
                      end;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      vPre # '';
                    END;
    'AF_US_LANG' :  FOR vErg # RecLink(502,501,12,_recFirst)  // Ausführungen loopen
                    LOOP vErg # RecLink(502,501,12,_recNext)
                    WHILE (vErg<=_rLocked) do begin
                      if (Ein.AF.Seite<>'2') then CYCLE;
                      vA # Ein.AF.Bezeichnung;
                      if (Ein.AF.Zusatz<>'') then vA # vA + ' '+Ein.AF.Zusatz;
                      if (vZeilen>0) then begin
                        aInhalt # aInhalt + StrChar(10);
                        aLabels # aLabels + StrChar(10);
                        aZusatz # aZusatz + StrChar(10);
                      end;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      vPre # '';
                    END;
    'AB.NUMMER' :   if (Ein.AB.Nummer<>Ein.P.AB.Nummer) and (Ein.P.AB.Nummer<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.AB.Nummer, vPre, vPost, aKombi);
                    end;
    'ZEUGNIS' :     if (Ein.P.Zeugnisart<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Zeugnisart, vPre, vPost, aKombi);
                    end;
    'RID' :         if (Ein.P.RID<>0.0) or (Ein.P.RIDmax<>0.0) then begin
                      inc(vZeilen);
                      vA # AlphaMinMax(Ein.P.RID, Ein.P.RIDmax, Set.Stellen.Radien, '');
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
    'RAD' :         if (Ein.P.RAD<>0.0) or (Ein.P.RADmax<>0.0) then begin
                      inc(vZeilen);
                      vA # AlphaMinMax(Ein.P.RAD, Ein.P.RADmax, Set.Stellen.Radien, '');
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
    'MEH' :         begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.MEH.Preis, vPre, vPost, aKombi);
                    end;
    'PEH' :         begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aint(Ein.P.PEH), vPre, vPost, aKombi);
                    end;
    'EINZELPREIS' : begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(Ein.P.Einzelpreis, 2), vPre, vPost, aKombi);
                    end;
    'GRUNDPREIS' :  begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(Ein.P.Grundpreis, 2), vPre, vPost, aKombi);
                    end;
    'GESAMTPREIS' : begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(Ein.P.GesamtPreis,2), vPre, vPost, aKombi);
                    end;
    'NETTOWERT' :   vAdd # aNum(Vbk.Netto,2);
    'BRUTTOWERT' :  vAdd # aNum(Vbk.Brutto,2);
    'MWSTSATZ' :    vAdd # anum(Sts.Prozent,2);
    'MWSTNETTO' :   vAdd # anum(Vbk.Netto,2);
    'MWST' :        vAdd # anum(Vbk.Steuer,2);

    'ARTIKELNR' :   if (Ein.P.Artikelnr<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Artikelnr, vPre, vPost, aKombi);
                    end;
    'ART.BEZ1' :    if (Art.Bezeichnung1<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Art.Bezeichnung1, vPre, vPost, aKombi);
                    end;
    'ART.BEZ2' :    if (Art.Bezeichnung2<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Art.Bezeichnung2, vPre, vPost, aKombi);
                    end;
    'ART.BEZ3' :    if (Art.Bezeichnung3<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Art.Bezeichnung3, vPre, vPost, aKombi);
                    end;
    'LIEFERANTENARTNR' : if (Ein.P.LieferArtNr<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.LieferArtNr, vPre, vPost, aKombi);
                    end;
    'INTRASTAT' :   if (Ein.P.IntraStatNr<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Intrastatnr, vPre, vPost, aKombi);
                    end;
    'BEMERKUNG' :   if (Ein.P.Bemerkung<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Bemerkung, vPre, vPost, aKombi);
                    end;

    // Verpackung ------------------------------------------------------------
    'VPG' :         begin
                      if (Ein.P.StehendYN) then ADD_VERP('stehend','');
                      if (Ein.P.LiegendYN) then ADD_VERP('liegend','');
                      //Abbindung
                      if (Ein.P.AbbindungQ <> 0 or Ein.P.AbbindungL <> 0) then begin
                        //Quer
                        if(Ein.P.AbbindungQ<>0)then vA2 # 'Abbindung '+ AInt(Ein.P.AbbindungQ)+' x quer' ;
                        //Längs
                        if(Ein.P.AbbindungL<>0)then begin
                          if (vA2<>'')then
                            vA2 # vA2+'  '+AInt(Ein.P.AbbindungL)+ ' x längs';
                          else
                            vA2 # 'Abbindung ' + AInt(Ein.P.AbbindungL)+' x längs';
                        end;
                       ADD_VERP(vA2,'')
                       vA2 # '';
                      end;
                      if (Ein.P.Zwischenlage <> '') then ADD_VERP(Ein.P.Zwischenlage,'');
                      if (Ein.P.Unterlage <> '') then ADD_VERP(Ein.P.Unterlage,'');
                      if (Ein.P.Umverpackung<>'') then ADD_VERP(Ein.P.Umverpackung,'');
                      if (Ein.P.Nettoabzug > 0.0) then ADD_VERP('Nettoabzug: '+AInt(CnvIF(Ein.P.Nettoabzug))+' kg','');
                      if ("Ein.P.Stapelhöhe" > 0.0) then ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("Ein.P.Stapelhöhe"))+' mm');
                      if (Ein.P.StapelhAbzug > 0.0) then ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("Ein.P.StapelhAbzug"))+' mm');
                      if (Ein.P.RingKgVon + Ein.P.RingKgBis  <> 0.0) then begin
                        vA2 # 'Ringgew.: '+AlphaMinMax(Ein.P.RingkgVon, Ein.P.RingKGBis, 0, '');
                        vA2 # vA2+' kg';
                        ADD_VERP(vA2,'')
                      end;
                      if (Ein.P.KgmmVon + Ein.P.KgmmBis  <> 0.0) then begin
                        vA2 # 'Kg/mm: '+AlphaMinMax(Ein.P.KgmmVon, Ein.P.KgmmBis, 2, '');
                        ADD_VERP(vA2,'')
                        vA2 # '';
                      end;
                      if ("Ein.P.StückProVE" > 0) then ADD_VERP(AInt("Ein.P.StückProVE") + ' Stück pro VE', '');
                      if (Ein.P.VEkgMax > 0.0) then ADD_VERP('max. kg pro VE: ',AInt(CnvIF(Ein.P.VEkgMax)));
                      if (Ein.P.RechtwinkMax > 0.0) then ADD_VERP('max. Rechtwinkligkeit: ', ANum(Ein.P.RechtwinkMax,-1));
                      if (Ein.P.EbenheitMax > 0.0) then ADD_VERP('max. Ebenheit: ', ANum(Ein.P.EbenheitMax,-1));
                      if ("Ein.P.SäbeligkeitMax" > 0.0) then ADD_VERP('max. Säbeligkeit: ', ANum("Ein.P.SäbeligkeitMax",-1)+' pro '+anum("Ein.P.SäbelProM",2)+' m');
                      if (Ein.P.Wicklung<>'') then ADD_VERP('Wicklung: ', Ein.P.Wicklung);
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'VPG_TEXT1' :   if (Ein.P.VpgText1<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.VpgText1, vPre, vPost, aKombi);
                    end;
    'VPG_TEXT2' :   if (Ein.P.VpgText2<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.VpgText2, vPre, vPost, aKombi);
                    end;
    'VPG_TEXT3' :   if (Ein.P.VpgText3<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.VpgText3, vPre, vPost, aKombi);
                    end;
    'VPG_TEXT4' :   if (Ein.P.VpgText4<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.VpgText4, vPre, vPost, aKombi);
                    end;
    'VPG_TEXT5' :   if (Ein.P.VpgText5<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.VpgText5, vPre, vPost, aKombi);
                    end;
    'VPG_TEXT6' :   if (Ein.P.VpgText6<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.VpgText6, vPre, vPost, aKombi);
                    end;
    // Analyse ---------------------------------------------------------------
    'STRECK' :      begin
                      vA # AlphaMinMax(Ein.P.Streckgrenze1, Ein.P.Streckgrenze2, -1, 'N/mm²');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'ZUG' :         begin
                      vA # AlphaMinMax(Ein.P.Zugfestigkeit1, Ein.P.Zugfestigkeit2, -1, 'N/mm²');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;

    'DEHNUNG' :     if (Abs(Ein.P.DehnungA1)+abs(Ein.P.DehnungA2)+Abs(Ein.P.DehnungB1)+Abs(Ein.P.DehnungB2)<>0.0) then begin
                      inc(vZeilen);
                      vA # ANum(Ein.P.DehnungA1,-1) + ' / ' + ANum(Ein.P.DehnungB1,-1) + '% - ' + ANum(Ein.P.DehnungA2,-1) + ' / ' + ANum(Ein.P.DehnungB2,-1) + '%';
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
    'RP02' :        begin
                      vA # AlphaMinMax(Ein.P.DehngrenzeA1, Ein.P.DehngrenzeA2, -1, 'N/mm²');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'RP10' :        begin
                      vA # AlphaMinMax(Ein.P.DehngrenzeB1, Ein.P.DehngrenzeB2, -1, 'N/mm²');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'KÖRNUNG' :     begin
                      vA # AlphaMinMax("Ein.P.Körnung1", "Ein.P.Körnung2", -1, '');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'HÄRTE' :       begin
                      vA # AlphaMinMax("Ein.P.Härte1", "Ein.P.Härte2", -1, '');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'RAU_OS' :      begin
                      vA # AlphaMinMax(Ein.P.RauigkeitA1, Ein.P.RauigkeitA2, -1, '');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'RAU_US' :      begin
                      vA # AlphaMinMax(Ein.P.RauigkeitB1, Ein.P.RauigkeitB2, -1, '');
                      if (vA<>'') then begin
                        inc(vZeilen);
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                      end;
                    end;
    'MECH_SONST' :  if (Ein.P.Mech.Sonstig1<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.P.Mech.Sonstig1, vPre, vPost, aKombi)
                    end;
    'CHEMIE_C'  :   vAdd # AlphaMinMax(Ein.P.Chemie.C1, Ein.P.Chemie.C2, -1, '');
    'CHEMIE_SI' :   vAdd # AlphaMinMax(Ein.P.Chemie.Si1, Ein.P.Chemie.Si2, -1, '');
    'CHEMIE_MN' :   vAdd # AlphaMinMax(Ein.P.Chemie.Mn1, Ein.P.Chemie.Mn2, -1, '');
    'CHEMIE_P'  :   vAdd # AlphaMinMax(Ein.P.Chemie.P1, Ein.P.Chemie.P2, -1, '');
    'CHEMIE_S'  :   vAdd # AlphaMinMax(Ein.P.Chemie.S1, Ein.P.Chemie.S2, -1, '');
    'CHEMIE_AL' :   vAdd # AlphaMinMax(Ein.P.Chemie.AL1, Ein.P.Chemie.AL2, -1, '');
    'CHEMIE_CR' :   vAdd # AlphaMinMax(Ein.P.Chemie.CR1, Ein.P.Chemie.CR2, -1, '');
    'CHEMIE_V'  :   vAdd # AlphaMinMax(Ein.P.Chemie.V1, Ein.P.Chemie.V2, -1, '');
    'CHEMIE_NB' :   vAdd # AlphaMinMax(Ein.P.Chemie.NB1, Ein.P.Chemie.NB2, -1, '');
    'CHEMIE_TI' :   vAdd # AlphaMinMax(Ein.P.Chemie.TI1, Ein.P.Chemie.TI2, -1, '');
    'CHEMIE_N'  :   vAdd # AlphaMinMax(Ein.P.Chemie.N1, Ein.P.Chemie.N2, -1, '');
    'CHEMIE_CU' :   vAdd # AlphaMinMax(Ein.P.Chemie.CU1, Ein.P.Chemie.CU2, -1, '');
    'CHEMIE_NI' :   vAdd # AlphaMinMax(Ein.P.Chemie.NI1, Ein.P.Chemie.NI2, -1, '');
    'CHEMIE_MO' :   vAdd # AlphaMinMax(Ein.P.Chemie.MO1, Ein.P.Chemie.MO2, -1, '');
    'CHEMIE_B'  :   vAdd # AlphaMinMax(Ein.P.Chemie.B1, Ein.P.Chemie.B2, -1, '');
    'CHEMIE_FREI1'  : vAdd # AlphaMinMax(Ein.P.Chemie.Frei1.1, Ein.P.Chemie.Frei1.2, -1, '');

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
//  Parse601Multi
//=======================================================================
sub Parse501Multi(
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

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse501Multi(var aLabels, var aInhalt, var aZusatz,aObjName,aKombi);
    RETURN(vZeilen);
  end;



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
        vTmp # Parse501(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse503
//=======================================================================
sub Parse503(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;

  aGesamtpreis  : float;) : int;
local begin
  vZeilen : int;
  vA      : alpha(4096);
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
end;
begin

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse503(var aLabels, var aInhalt, var aZusatz,aText,aKombi,aGesamtpreis);
    RETURN(vZeilen);
  end;


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
    'MENGE+MEH' :   if ("Ein.Z.Menge"<>0.0) then begin
                      if (Ein.Z.MEH<>'%') and (Ein.Z.MengenbezugYN) then RETURN 0;
                      inc(vZeilen);
                      if (Ein.Z.MEH='Stk') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.Z.Menge", 0)+' '+Ein.Z.MEH, vPre, vPost, aKombi)
                      else if (Ein.Z.MEH='kg') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.Z.Menge", Set.Stellen.Gewicht)+' '+Ein.Z.MEH, vPre, vPost, aKombi)
                      else if (Ein.Z.MEH='%') then
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.Z.Menge", 2)+' '+Ein.Z.MEH, vPre, vPost, aKombi)
                      else
                        AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum("Ein.Z.Menge", Set.Stellen.Menge)+' '+Ein.Z.MEH, vPre, vPost, aKombi);
                    end;
    'BEZEICHNUNG'  : if (Ein.Z.Bezeichnung<>'') then begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.Z.Bezeichnung, vPre, vPost, aKombi);
                    end;
    'MEH' :         begin
                      if (Ein.Z.MengenbezugYN) then RETURN 0;
                      if (Ein.Z.MEH='%') then RETURN 0;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, Ein.Z.MEH, vPre, vPost, aKombi);
                    end;
    'PEH' :         begin
                      if (Ein.Z.MEH='%') then RETURN 0;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, aint(Ein.Z.PEH), vPre, vPost, aKombi);
                    end;
    'PREIS' :       begin
                      if (Ein.Z.MEH='%') then RETURN 0;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(Ein.Z.Preis, 2), vPre, vPost, aKombi);
                    end;
    'PREIS+WAE' :   begin
                      if (Ein.Z.MEH='%') then RETURN 0;
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(Ein.Z.Preis, 2)+' '+"Wae.Kürzel", vPre, vPost, aKombi);
                    end;
    'GESAMTPREIS' : begin
                      inc(vZeilen);
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, anum(aGesamtpreis,2), vPre, vPost, aKombi);
                    end;
    'PEH+MEH' :
                    begin
                      if (Ein.Z.MEH='%') then RETURN 0;

                      vA # aint(Ein.Z.PEH) + ' ';
                      if (Ein.Z.MengenbezugYN) then
                        vA # vA + Ein.P.MEH.Preis;
                      else
                        vA # vA + Ein.Z.MEH;
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;
    'PEH+MEH_Z' :
                    begin
                      if (Ein.Z.MEH='%') then RETURN 0;
                      if (Ein.Z.PEH <> 1)  then
                         vA   # aint(Ein.Z.PEH) + ' ';

                      vA   # vA   + Ein.Z.MEH;
                      AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    end;

    otherwise           begin
                          // Allgemeiner Befehl?
                          if (ParseAllgemein(var aLabels, var aInhalt, var aZusatz, vFeld, vTitel, vPost, vPre, aKombi, var vZeilen)) then RETURN vZeilen;

                          // unbekannt?
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, '?'+vTitel, '?'+vFeld, vPre, vPost, aKombi);
                        end;
  end;

  RETURN vZeilen;
end;


//=======================================================================
//  Parse603Multi
//=======================================================================
sub Parse503Multi(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aObjName      : alpha;
  aKombi        : logic;

  aGesamtPreis  : float;) : int
local begin
  vCap        : alpha(4096);
  vRow        : alpha(4096);
  vToken      : alpha(4096);
  vA          : alpha(4096);
  vPre,vPost  : alpha(4096);
  vI,vJ       : int;
  vK,vL       : int;
  vZ          : int;
  vZeilen     : int;
  vTmp,vMax   : int;
end;
begin

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse503Multi(var aLabels, var aInhalt, var aZusatz,aObjName,aKombi,aGesamtpreis);
    RETURN(vZeilen);
  end;


  aLabels # '';
  aInhalt # '';
  aZusatz # '';

  vCap # GetCaption(aObjName);

  vJ # 1 + Lib_Strings:Strings_Count(vCap, StrChar(13)+StrChar(10));
  FOR vI # 1 loop inc(vI) WHILE (vI<=vJ) do begin
    vRow # Str_Token(vCap, StrChar(13)+StrChar(10), vI);

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
        vTmp # Parse503(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aGesamtpreis);
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
//  AnalyseBereich
//=======================================================================
sub AnalyseBereich(
  aWert   : float;
  aMin    : float;
  aMax    : float) : alpha;
begin
  if (aWert<aMin) or (aWert>aMax) then RETURN 'FEHLER'

  RETURN cnvaf(aWert, _FmtNumNoGroup);
/**
  if (aWert2=0.0) then begin
    if ((aWert < vVon) and (vVon<>0.0)) or ((aWert>vBis) and (vBis<>0.0)) then
      aObj->wpColBkg # _WinColLightRed
    else
      aObj->wpColBkg # _WinColparent;
    end
  else begin
    if ((aWert<vVon) or (aWert>vBis) or (aWert2<vVon) or (aWert2>vBis)) and
      ((vVon<>0.0) or (vBis<>0.0)) then
      aObj->wpColBkg # _WinColLightRed
    else
      aObj->wpColBkg # _WinColparent;
  end;
**/
end;

//=======================================================================
//  Parse839
//=======================================================================
sub Parse839(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic) : int;
local begin
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
end;
begin

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse839(var aLabels, var aInhalt, var aZusatz,aText,aKombi);
    RETURN(vZeilen);
  end;

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

    // Analyse ---------------------------------------------------------------
    'ZEUGNIS' :       vAdd  # Mat.Zeugnisart;
    'CHARGE'  :       vAdd  # Mat.Chargennummer;
    'KOMMISSION' :    vAdd  # Mat.Kommission;
    'WERKSTOFF' :     vAdd  # Mat.Werkstoffnr;
    'GÜTE' :          vAdd  # "Mat.Güte";
    'DICKE' :         begin
                        if (Mat.Dicke=0.0) then RETURN 0;
                        vAdd # anum(Mat.Dicke, Set.Stellen.Dicke);
                      end;
    'BREITE' :        begin
                        if (Mat.Breite=0.0) then RETURN 0;
                        vAdd # anum(Mat.Breite, Set.Stellen.Breite);
                      end;
    'LÄNGE' :         begin
                        if ("Mat.Länge"=0.0) then RETURN 0;
                        vAdd # anum("Mat.Länge", "Set.Stellen.Länge");
                      end;
    'GEWICHT' :       vAdd  # anum(Mat.Bestand.Gew, Set.Stellen.Gewicht);
    'STÜCK' :         vAdd  # aint(Mat.Bestand.Stk);


    'AUF.BEST.DATUM' :    if (Auf.Best.Datum<>0.0.0) then vAdd # cnvad(Auf.Best.Datum);
    'AUF.BEST.NUMMER' :   vAdd  # Auf.Best.Nummer;
    'AUF.P.KUNDENARTNR' : vAdd  # Auf.P.KundenArtnr;
    'AUF.P.GÜTE' :        vAdd  # "Auf.P.Güte";
    'AUF.P.WERKSTOFFNR' : vAdd  # Auf.P.Werkstoffnr;
    'NORM' :              vAdd # MQu.NachNorm;

    'MINSTRECK' :         if (MQu.M.Von.StreckG<>0.0) then    vAdd # cnvaf(MQu.M.Von.StreckG            ,_FmtNumnogroup);
    'MINZUG' :            if (MQu.M.Von.ZugFest<>0.0) then    vAdd # cnvaf(MQu.M.Von.Zugfest            ,_FmtNumnogroup);
    'MINDEHNUNG' :        if (MQu.M.Von.Dehnung<>0.0) then    vAdd # cnvaf(MQu.M.Von.Dehnung            ,_FmtNumnogroup);
    'MINRP02' :           if (MQu.M.Von.DehnGrenzA<>0.0) then vAdd # cnvaf(MQu.M.Von.DehnGrenzA         ,_FmtNumnogroup);
    'MINRP10' :           if (MQu.M.Von.DehnGrenzB<>0.0) then vAdd # cnvaf(MQu.M.Von.DehnGrenzB         ,_FmtNumnogroup);
    'MINKÖRNUNG' :        if ("MQu.M.Von.Körnung"<>0.0) then  vAdd # cnvaf("MQu.M.Von.Körnung"          ,_FmtNumnogroup);
    'MINHÄRTE' :          if ("MQu.M.Von.Härte"<>0.0) then    vAdd # cnvaf("MQu.M.Von.Härte"            ,_FmtNumnogroup);

    'MAXSTRECK' :         if (MQu.M.Bis.StreckG<>0.0) then    vAdd # cnvaf(MQu.M.Bis.StreckG            ,_FmtNumnogroup);
    'MAXZUG' :            if (MQu.M.Bis.ZugFest<>0.0) then    vAdd # cnvaf(MQu.M.Bis.Zugfest            ,_FmtNumnogroup);
    'MAXDEHNUNG' :        if (MQu.M.Bis.Dehnung<>0.0) then    vAdd # cnvaf(MQu.M.Bis.Dehnung            ,_FmtNumnogroup);
    'MAXRP02' :           if (MQu.M.Bis.DehnGrenzA<>0.0) then vAdd # cnvaf(MQu.M.Bis.DehnGrenzA         ,_FmtNumnogroup);
    'MAXRP10' :           if (MQu.M.Bis.DehnGrenzB<>0.0) then vAdd # cnvaf(MQu.M.Bis.DehnGrenzB         ,_FmtNumnogroup);
    'MAXKÖRNUNG' :        if ("MQu.M.Bis.Körnung"<>0.0) then  vAdd # cnvaf("MQu.M.Bis.Körnung"          ,_FmtNumnogroup);
    'MAXHÄRTE' :          if ("MQu.M.Bis.Härte"<>0.0) then    vAdd # cnvaf("MQu.M.Bis.Härte"            ,_FmtNumnogroup);

    'MINCHEMIE_C'  :      if (MQu.ChemieVon.C<>0.0) then      vAdd # Cnvaf(MQu.ChemieVon.C        ,_FmtNumnogroup);
    'MINCHEMIE_SI' :      if (MQu.ChemieVon.Si<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.Si       ,_FmtNumnogroup);
    'MINCHEMIE_MN' :      if (MQu.ChemieVon.Mn<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.Mn       ,_FmtNumnogroup);
    'MINCHEMIE_P'  :      if (MQu.ChemieVon.P<>0.0) then      vAdd # Cnvaf(MQu.ChemieVon.P        ,_FmtNumnogroup);
    'MINCHEMIE_S'  :      if (MQu.ChemieVon.S<>0.0) then      vAdd # Cnvaf(MQu.ChemieVon.S        ,_FmtNumnogroup);
    'MINCHEMIE_AL' :      if (MQu.ChemieVon.Al<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.AL       ,_FmtNumnogroup);
    'MINCHEMIE_CR' :      if (MQu.ChemieVon.CR<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.CR       ,_FmtNumnogroup);
    'MINCHEMIE_V'  :      if (MQu.ChemieVon.V<>0.0) then      vAdd # Cnvaf(MQu.ChemieVon.V        ,_FmtNumnogroup);
    'MINCHEMIE_NB' :      if (MQu.ChemieVon.Nb<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.NB       ,_FmtNumnogroup);
    'MINCHEMIE_TI' :      if (MQu.ChemieVon.Ti<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.TI       ,_FmtNumnogroup);
    'MINCHEMIE_N'  :      if (MQu.ChemieVon.N<>0.0) then      vAdd # Cnvaf(MQu.ChemieVon.N        ,_FmtNumnogroup);
    'MINCHEMIE_CU' :      if (MQu.ChemieVon.Cu<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.CU       ,_FmtNumnogroup);
    'MINCHEMIE_NI' :      if (MQu.ChemieVon.Ni<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.NI       ,_FmtNumnogroup);
    'MINCHEMIE_MO' :      if (MQu.ChemieVon.Mo<>0.0) then     vAdd # Cnvaf(MQu.ChemieVon.MO       ,_FmtNumnogroup);
    'MINCHEMIE_B'  :      if (MQu.ChemieVon.B<>0.0) then      vAdd # Cnvaf(MQu.ChemieVon.B        ,_FmtNumnogroup);
    'MINCHEMIE_FREI1'  :  if (MQu.ChemieVon.Frei1<>0.0) then  vAdd # Cnvaf(MQu.ChemieVon.Frei1    ,_FmtNumnogroup);

    'MAXCHEMIE_C'  :      if (MQu.ChemieBis.C<>0.0) then      vAdd # Cnvaf(MQu.ChemieBis.C        ,_FmtNumnogroup);
    'MAXCHEMIE_SI' :      if (MQu.ChemieBis.Si<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.Si       ,_FmtNumnogroup);
    'MAXCHEMIE_MN' :      if (MQu.ChemieBis.Mn<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.Mn       ,_FmtNumnogroup);
    'MAXCHEMIE_P'  :      if (MQu.ChemieBis.P<>0.0) then      vAdd # Cnvaf(MQu.ChemieBis.P        ,_FmtNumnogroup);
    'MAXCHEMIE_S'  :      if (MQu.ChemieBis.S<>0.0) then      vAdd # Cnvaf(MQu.ChemieBis.S        ,_FmtNumnogroup);
    'MAXCHEMIE_AL' :      if (MQu.ChemieBis.Al<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.AL       ,_FmtNumnogroup);
    'MAXCHEMIE_CR' :      if (MQu.ChemieBis.CR<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.CR       ,_FmtNumnogroup);
    'MAXCHEMIE_V'  :      if (MQu.ChemieBis.V<>0.0) then      vAdd # Cnvaf(MQu.ChemieBis.V        ,_FmtNumnogroup);
    'MAXCHEMIE_NB' :      if (MQu.ChemieBis.Nb<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.NB       ,_FmtNumnogroup);
    'MAXCHEMIE_TI' :      if (MQu.ChemieBis.Ti<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.TI       ,_FmtNumnogroup);
    'MAXCHEMIE_N'  :      if (MQu.ChemieBis.N<>0.0) then      vAdd # Cnvaf(MQu.ChemieBis.N        ,_FmtNumnogroup);
    'MAXCHEMIE_CU' :      if (MQu.ChemieBis.Cu<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.CU       ,_FmtNumnogroup);
    'MAXCHEMIE_NI' :      if (MQu.ChemieBis.Ni<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.NI       ,_FmtNumnogroup);
    'MAXCHEMIE_MO' :      if (MQu.ChemieBis.Mo<>0.0) then     vAdd # Cnvaf(MQu.ChemieBis.MO       ,_FmtNumnogroup);
    'MAXCHEMIE_B'  :      if (MQu.ChemieBis.B<>0.0) then      vAdd # Cnvaf(MQu.ChemieBis.B        ,_FmtNumnogroup);
    'MAXCHEMIE_FREI1'  :  if (MQu.ChemieBis.Frei1<>0.0) then  vAdd # Cnvaf(MQu.ChemieBis.Frei1    ,_FmtNumnogroup);

    'STRECK' :        vAdd # AlphaMinMax(Mat.Streckgrenze1,   Mat.Streckgrenze1, -1, 'N/mm²');
    'ZUG' :           vAdd # AlphaMinMax(Mat.Zugfestigkeit1,  Mat.Zugfestigkeit1, -1, 'N/mm²');
    'DEHNUNG' :       if (Abs(Mat.DehnungA1)+abs(Mat.DehnungB1)<>0.0) then
                        vAdd # ANum(Mat.DehnungA1,-1) + ' / ' + ANum(Mat.DehnungB1,-1) + '%';
    'RP02' :          vAdd # AlphaMinMax(Mat.RP02_V1,         Mat.RP02_V1, -1, 'N/mm²');
    'RP10' :          vAdd # AlphaMinMax(Mat.RP10_V1,         Mat.RP10_V1, -1, 'N/mm²');
    'KÖRNUNG' :       vAdd # AlphaMinMax("Mat.Körnung1",      "Mat.Körnung1", -1, '');
    'HÄRTE' :         vAdd # AlphaMinMax("Mat.HärteA1",       "Mat.HärteA1", -1, '');
    'RAU_OS' :        vAdd # AlphaMinMax(Mat.RauigkeitA1,     "Mat.RauigkeitA1", -1, '');
    'RAU_US' :        vAdd # AlphaMinMax(Mat.RauigkeitC1,     "Mat.RauigkeitC1", -1, '');
    'MECH_SONST' :    vAdd # Mat.Mech.Sonstiges1;
    'CHEMIE_C'  :     vAdd # AnalyseBereich(Mat.Chemie.C1,      MQu.ChemieVon.C     ,MQu.ChemieBis.C );
    'CHEMIE_SI' :     vAdd # AnalyseBereich(Mat.Chemie.Si1,     MQu.ChemieVon.Si    ,MQu.ChemieBis.Si);
    'CHEMIE_MN' :     vAdd # AnalyseBereich(Mat.Chemie.Mn1,     MQu.ChemieVon.Mn    ,MQu.ChemieBis.Mn);
    'CHEMIE_P'  :     vAdd # AnalyseBereich(Mat.Chemie.P1,      MQu.ChemieVon.P     ,MQu.ChemieBis.P );
    'CHEMIE_S'  :     vAdd # AnalyseBereich(Mat.Chemie.S1,      MQu.ChemieVon.S     ,MQu.ChemieBis.S );
    'CHEMIE_AL' :     vAdd # AnalyseBereich(Mat.Chemie.AL1,     MQu.ChemieVon.Al    ,MQu.ChemieBis.Al);
    'CHEMIE_CR' :     vAdd # AnalyseBereich(Mat.Chemie.CR1,     MQu.ChemieVon.Cr    ,MQu.ChemieBis.Cr);
    'CHEMIE_V'  :     vAdd # AnalyseBereich(Mat.Chemie.V1,      MQu.ChemieVon.V     ,MQu.ChemieBis.V );
    'CHEMIE_NB' :     vAdd # AnalyseBereich(Mat.Chemie.NB1,     MQu.ChemieVon.Nb    ,MQu.ChemieBis.Nb);
    'CHEMIE_TI' :     vAdd # AnalyseBereich(Mat.Chemie.TI1,     MQu.ChemieVon.Ti    ,MQu.ChemieBis.Ti);
    'CHEMIE_N'  :     vAdd # AnalyseBereich(Mat.Chemie.N1,      MQu.ChemieVon.N     ,MQu.ChemieBis.N );
    'CHEMIE_CU' :     vAdd # AnalyseBereich(Mat.Chemie.CU1,     MQu.ChemieVon.Cu    ,MQu.ChemieBis.Cu);
    'CHEMIE_NI' :     vAdd # AnalyseBereich(Mat.Chemie.NI1,     MQu.ChemieVon.Ni    ,MQu.ChemieBis.Ni);
    'CHEMIE_MO' :     vAdd # AnalyseBereich(Mat.Chemie.MO1,     MQu.ChemieVon.Mo    ,MQu.ChemieBis.Mo);
    'CHEMIE_B'  :     vAdd # AnalyseBereich(Mat.Chemie.B1,      MQu.ChemieVon.B     ,MQu.ChemieBis.B );
    'CHEMIE_FREI1'  : vAdd # AnalyseBereich(Mat.Chemie.Frei1.1, MQU.ChemieVon.Frei1 ,MQU.ChemieBis.Frei1);
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
//  Parse839Multi
//=======================================================================
sub Parse839Multi(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  aKombi      : logic;
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

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ein_E:Parse839Multi(var aLabels, var aInhalt, var aZusatz,aObjName,aKombi);
    RETURN(vZeilen);
  end;

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
        vTmp # Parse839(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
