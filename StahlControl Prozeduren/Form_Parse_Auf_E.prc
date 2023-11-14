@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Auf
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Formularen
//
//
//  07.11.2012  AI  Erstellung der Prozedur
//  18.03.2013  TM  RechnungsempfängerAdresse + RE.Ort
//  23.09.2013  AH  Neue "@RechTitel2"
//  29.04.2020  TM  BUG behoben Rechnungsempfänger/Anschrift + RE.Straße
//
//  Subprozeduren
//  SUB Parse400(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int) : int;
//  SUB Parse400Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int) : int
//  SUB Parse401(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse401Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; opt aKombi : logic) : int
//  SUB Parse403(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha;aText : alpha(4096); aKombi : logic; aGesamtpreis : float;) : int;
//  SUB Parse403Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aGesamtPreis : float;) : int
//  SUB Parse404(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aCount : int) : int;
//  SUB Parse404Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aCount : int) : int;
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  Parse400
//=======================================================================
Sub Parse400(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic;

  aBuf100Re   : int;
  aBuf101We   : int;
  aBuf110Ver1 : int;
  aBuf110Ver2 : int
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
  v812        : int;
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
    'ERL.NUMMER'          :  vAdd # aint(Erl.Rechnungsnr);
    'ERL.RECHNUNGSDATUM' :  if (Erl.Rechnungsdatum<>0.0.0) then
                              vAdd # cnvad(Erl.Rechnungsdatum);
    'AUFTRAG' :             vAdd # aint(Auf.Nummer);
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
                            vAdd # Lnd.Name.L2;

    'DATUM' :               if (Auf.Datum<>0.0.0) then
                              vAdd # cnvad(Auf.Datum);
    'KUNDENNR' :            vAdd # aint(Auf.Kundennr);
    'ADR.VK.REFERENZNR' :   vAdd # Adr.VK.Referenznr;
    'READR.USIDENTNR' :     vAdd # aBuf100re->Adr.UsIdentNr;
    'READR.STEUERNUMMER' :  vAdd # aBuf100Re->Adr.Steuernummer;
    'BEST.NUMMER' :         vAdd # Auf.Best.Nummer
    'BEST.DATUM' :          if (Auf.Best.Datum<>0.0.0) then
                              vAdd # cnvad(Auf.Best.Datum)
    'BEST.PARTNER' :          begin
                              vAdd # Auf.Best.Bearbeiter;
                              if ((vAdd <> '') AND (StrLen(vAdd) > 4)) then
                                  if (StrCut(vAdd,1,1) = '#') then
                                    vAdd # StrCut(vAdd, StrFind(vAdd, ':', 1) + 1,StrLen(vAdd) - StrFind(vAdd, ':', 1) + 1);
                            end;
    'VERTRETER1' :          if (aBuf110Ver1<>0) then
                              vAdd # aBuf110Ver1->Ver.Name;
    'VERTRETER2' :          if (aBuf110Ver2<>0) then
                              vAdd # aBuf110Ver2->Ver.Name;
    'ABTITEL'       :       begin
                              if (Auf.Vorgangstyp = c_AUF) then begin
                                if ("Auf.LiefervertragYN") and (!"Auf.AbrufYN") then
                                  vA # 'Rahmenvertrag-VK ' + AInt("Auf.P.Nummer")
                                else if ("Auf.AbrufYN") and (!"Auf.LiefervertragYN") then
                                  vA # 'Order confirmation ' + AInt("Auf.P.Nummer")+' aus Rahmenvertrag ' + AInt("Auf.P.AbrufAufNr")
                                else
                                  vA # 'Order confirmation' + ' ' + AInt(Auf.P.Nummer);
                                end
                              else if (Auf.Vorgangstyp = c_ANG) then begin
                                vA # 'Offer' + ' ' + AInt(Auf.P.Nummer);
                                if ("Auf.AbrufYN") and (!"Auf.LiefervertragYN") then begin
                                  vA # vA + ' aus Rahmenvertrag ' + AInt("Auf.P.AbrufAufNr");
                                end;
                              end;
                              if (vA<>'') and (Frm.Markierung<>'') then
                                vA # vA +'     '+Frm.Markierung;
                              vAdd # vA;
                            end;
    'RECHTITEL' :           begin
                              if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then
                                vA # 'Credit note'
                              else if (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then
                                vA # 'Debit note'
                              else
                                vA # 'Invoice';
                              vA # vA + ' ' + AInt(Erl.Rechnungsnr)
                              if (vA<>'') and (Frm.Markierung<>'') then
                                vA # vA +'     '+Frm.Markierung;
                              vAdd # vA;
                            end;
     'RECHTITEL2' :         begin
                              if (Auf.Vorgangstyp=c_BOGUT) then begin
                                vA # 'Bonusgutschrift ' + AInt(Erl.Rechnungsnr);
                                end
                              else if (Auf.Vorgangstyp=c_REKOR) then begin
                                vA # 'Rechnungskorrektur / Vergütung ' + AInt(Erl.Rechnungsnr);
                                if ("Auf.P.AbrufAufNr"<>0) then
                                  vA # vA + ' to invoice ' + AInt("Auf.P.AbrufAufNr")
                                end
                              else if (Auf.Vorgangstyp=c_GUT) then begin
                                vA # 'Credit note ' + AInt(Erl.Rechnungsnr);
                                end
                              else if (Auf.Vorgangstyp=c_BEL_KD) then begin
                                vA # 'Debit note ' + AInt(Erl.Rechnungsnr);
                                if ("Auf.P.AbrufAufNr"<>0) then
                                  vA # vA + ' to invoice ' + AInt("Auf.P.AbrufAufNr")
                                end
                              else if (Auf.Vorgangstyp=c_BEL_LF) then begin
                                vA # 'Debit note ' + AInt(Erl.Rechnungsnr);
                                end
                              else
                                vA # 'Invoice ' + AInt(Erl.Rechnungsnr);
                              if (vA<>'') and (Frm.Markierung<>'') then
                                vA # vA +'     '+Frm.Markierung;
                              vAdd # vA;
                            end;
    'TITELZUSATZ' :         begin
                              if ("Auf.GültigkeitVom"<>0.0.0) or ("Auf.GültigkeitBis"<>0.0.0) then begin
                                vA3 # ' (gültig ';
                                if ("Auf.GültigkeitVom"<>0.0.0) then
                                  vA3 # vA3 + ' from '+cnvad("Auf.GültigkeitVom");
                                if ("Auf.GültigkeitBis"<>0.0.0) then
                                  vA3 # vA3 + ' until '+cnvad("Auf.GültigkeitBis");
                                vA3 # vA3 + ')';
                              end;
                              If (Auf.Vorgangstyp = c_ANG) then begin
                                vA # 'Wir danken für Ihre Anfrage, die wir Ihnen zu unseren Allgemeinen Verkaufsbedingungen';
                                vA # vA + 'wie folg anbieten'+vA3+' können:';
                                end
                              else begin
//                          Adda('Wir danken für Ihren Auftrag, den wir zu unseren Allgemeinen Verkaufsbedingungen', var aLabels);
//                          AddA('(Stand 1.1.2010) gebucht haben. Anderen Bedingungen widersprechen wir ausdrücklich.', var aLabels);
                                vA2 # Auf.Best.Bearbeiter;
                                if ((Auf.Best.Bearbeiter <> '') AND (StrLen(Auf.Best.Bearbeiter) > 4)) then
                                  if (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then
                                    vA2 # StrCut(Auf.Best.Bearbeiter, StrFind(Auf.Best.Bearbeiter, ':', 1) + 1,StrLen(Auf.Best.Bearbeiter) - StrFind(Auf.Best.Bearbeiter, ':', 1) + 1);
                                if (vA2<>'') then vA2 # ' by '+vA2;
                                if (Auf.Best.Nummer<>'') then vA # ' '+Auf.Best.Nummer;
                                vA # vA + vA2;
                                if (Auf.Best.Datum<>0.0.0) then vA2 # ' dated '+cnvad(Auf.Best.Datum);
                                vA # vA + vA2;
                                vA # 'We confirm your order '+vA+' as follows:'+vA3;
                              end;
                              vAdd # vA;
                            end;

    'RE.ANREDE'                   : vAdd # aBuf100Re -> Adr.Anrede;
    'RE.NAME'                     : vAdd # aBuf100Re -> Adr.Name;
    'RE.ZUSATZ'                   : vAdd # aBuf100Re -> Adr.Zusatz;
    'RE.STRASSE'                  : vAdd # aBuf100Re -> "Adr.Straße";

    'RE.STRASSEWENNKEINPOSTFACH'  : if (aBuf100Re->Adr.Postfach='') then vAdd # aBuf100Re -> "Adr.Straße" ;
    'RE.PLZ'                      : vAdd # aBuf100Re -> Adr.PLZ;
    'RE.PLZWENNKEINPOSTFACH'      : if (aBuf100Re->Adr.Postfach='') then vAdd # aBuf100Re -> Adr.PLZ;
    'RE.ORT'                      : vAdd # aBuf100Re -> "Adr.Ort";
    'RE.LAND'                     :
                            if (aBuf100Re<>0) then begin
                              RekLinkB(v812, aBuf100Re, 10, _recFirsT);
                              vAdd # v812->Lnd.Name.L2;
                              RecBufDestroy(v812);
                            end;
    'RE.POSTFACH'                 : vAdd # aBuf100Re -> Adr.Postfach;
    'RE.POSTFACH.PLZ'             : vAdd # aBuf100Re -> Adr.Postfach.PLZ;

    'RECHNUNGSEMPFAENGER' :
                            
                            if (Auf.Kundennr <> aBuf100Re->Adr.Kundennr) then begin
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
                              vAdd # vA;
                            
                            end;
         

    'WARENEMPFAENGER' :  begin
                            if ((Adr.A.Adressnr <> Auf.Lieferadresse) or
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
                              vAdd # vA;
                            end;
                          end;

    'WARENANNAHME1'    : vA # StrAdj(aBuf101We->Adr.A.Warenannahme1,_StrBegin | _StrEnd);
    'WARENANNAHME2'    : vA # StrAdj(aBuf101We->Adr.A.Warenannahme2,_StrBegin | _StrEnd);
    'WARENANNAHME3'    : vA # StrAdj(aBuf101We->Adr.A.Warenannahme3,_StrBegin | _StrEnd);
    'WARENANNAHME4'    : vA # StrAdj(aBuf101We->Adr.A.Warenannahme4,_StrBegin | _StrEnd);
    'WARENANNAHME5'    : vA # StrAdj(aBuf101We->Adr.A.Warenannahme5,_StrBegin | _StrEnd);
    'BETRFERIEN'       : vA # StrAdj(aBuf101We->Adr.A.Betriebsferien,_StrBegin | _StrEnd);

    'LIB.BEZEICHNUNG'  :  vAdd # Lib.Bezeichnung.L2;
    'VSA.BEZEICHNUNG' :   vAdd # VsA.Bezeichnung.L2;
    'ZAB.BEZEICHNUNG' :   begin
                            vA # ZaB.Bezeichnung1.L2;
                            if (ZaB.Bezeichnung2.L2<>'') then vA # vA + ' ' +ZaB.Bezeichnung2.L2;
//                            vA # Ofp_data:BuildZabString(vA, 0.0.0,0.0.0);
                            vAdd # Ofp_data:BuildZabString(vA, Ofp.Skontodatum, Ofp.Zieldatum, OfP.Skontoprozent, OfP.Brutto);
//                            if (vA<>'') then begin
//                              inc(vZeilen);
//                              AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
//                              vTitel # '';
//                            end;
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
//  Parse400Multi
//=======================================================================
sub Parse400Multi(
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
        vTmp # Parse400(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aBuf100Re, aBuf101We, aBuf110Ver1, aBuf110Ver2);
        if (vTmp<0) then RETURN vTmp;
        vMax # Max(vTmp, vMax);   // früher Max(vTmp, vZ)
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
//  Parse401
//=======================================================================
sub Parse401(
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
    'AUFTRAG' :     vAdd # aint(Auf.P.Nummer);
    'POSITION' :    vAdd # aint(Auf.P.Position);
    'DICKE' :       if (Auf.P.Dicke<>0.0) then      vAdd # anum(Auf.P.Dicke,Set.Stellen.Dicke);
    'DICKENTOL' :   vAdd # Auf.P.Dickentol;
    'BREITE' :      if (Auf.P.Breite<>0.0) then     vAdd # aNum(Auf.P.Breite, Set.Stellen.Breite);
    'BREITENTOL' :  vAdd # Auf.P.Breitentol;
    'LÄNGE' :       if ("Auf.P.Länge"<>0.0) then    vAdd # aNum("Auf.P.Länge", "Set.Stellen.Länge");
    'LÄNGENTOL' :   vAdd # "Auf.P.Längentol";

    'POSABM' :     begin // Positions Abmessung
                        if (Auf.P.Dicke<>0.0) then vAdd # anum(Auf.P.Dicke, Set.Stellen.Dicke);
                        if (Auf.P.Breite<>0.0) then begin
                          if (vAdd<>'') then vAdd # vAdd + ' x ';
                          vAdd # vAdd + anum(Auf.P.Breite, Set.Stellen.Breite);
                          if ("Auf.P.Länge"<>0.0) then
                            vAdd # vAdd + ' x ' + anum("Auf.P.Länge", "Set.Stellen.Länge");
                        end;
                    end;


    'GÜTE' :        vAdd # "Auf.P.Güte";
    'GÜTENSTUFE' :  vAdd # "Auf.P.Gütenstufe";
    'WGR' :         vAdd # Wgr.Bezeichnung.L2;
    'STÜCK' :       if ("Auf.P.Stückzahl"<>0) then  vAdd # aint("Auf.P.Stückzahl");
    'MENGE' :       if ("Auf.P.Menge.Wunsch"<>0.0) then begin
                      if (Auf.P.MEH.Wunsch='kg') then
                        vAdd # anum("Auf.P.Menge.Wunsch", Set.Stellen.Gewicht)
                      else if (Auf.P.MEH.Wunsch='Stk') then
                        vAdd # anum("Auf.P.Menge.Wunsch", 0)
                      else
                        vAdd # anum("Auf.P.Menge.Wunsch", Set.Stellen.Menge);
                    end;
    'MENGE+MEH' :   if ("Auf.P.Menge.Wunsch"<>0.0) then begin
                      if (Auf.P.MEH.Wunsch='kg') then
                        vAdd # anum("Auf.P.Menge.Wunsch", Set.Stellen.Gewicht)+' '+Auf.P.MEH.Wunsch
                      else if (Auf.P.MEH.Wunsch='Stk') then
                        vAdd # anum("Auf.P.Menge.Wunsch", 0)+' '+'pcs'
                      else
                        vAdd # anum("Auf.P.Menge.Wunsch", Set.Stellen.Menge)+' '+Auf.P.MEH.Wunsch;
                    end;
    'MENGE2' :      if ("Auf.P.Menge"<>0.0) then begin
                      if (Auf.P.MEH.Einsatz='kg') then
                        vAdd # anum("Auf.P.Menge", Set.Stellen.Gewicht)
                      else if (Auf.P.MEH.Einsatz='Stk') then
                        vAdd # anum("Auf.P.Menge", 0)
                      else
                        vAdd # anum("Auf.P.Menge", Set.Stellen.Menge);
                    end;
    'MENGE2+MEH' :   if ("Auf.P.Menge"<>0.0) then begin
                      if (Auf.P.MEH.Einsatz='kg') then
                        vAdd # anum("Auf.P.Menge", Set.Stellen.Gewicht)+' '+Auf.P.MEH.Einsatz
                      else if (Auf.P.MEH.Einsatz='Stk') then
                        vAdd # anum("Auf.P.Menge", 0)+' '+'pcs'
                      else
                        vAdd # anum("Auf.P.Menge", Set.Stellen.Menge)+' '+Auf.P.MEH.Einsatz;
                    end;
    'GEWICHT' :     if ("Auf.P.Gewicht"<>0.0) then  vAdd # anum("Auf.P.Gewicht", Set.Stellen.Gewicht);
    'TERMIN' :      begin
                      if (Auf.P.Termin1W.Art = 'DA') then
                        vAdd # CnvAd(Auf.P.Termin1Wunsch)
                      else if (Auf.P.Termin1W.Art = 'KW') then
                        vAdd # 'week ' + CnvAi(Auf.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                                       CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'MO') then
                        vAdd # Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin1Wunsch) + ' ' +
                                 CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'QU') then
                        vAdd # CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. quarter ' +
                               CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'SE') then
                        vAdd # CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. semester ' +
                               CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'JA') then
                        vAdd # 'year ' +  CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup);
                    end;
    'ZUSAGETERMIN' :  if (Auf.P.TerminZusage<>0.0.0) then begin
                        if (Auf.P.Termin1W.Art = 'DA') then
                        vAdd # CnvAd(Auf.P.TerminZusage)
                      else if (Auf.P.Termin1W.Art = 'KW') then
                        vAdd # 'week ' + CnvAi(Auf.P.TerminZ.Zahl,_FmtNumLeadZero) + '/' +
                                      CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'MO') then
                        vAdd # Lib_Berechnungen:Monat_aus_datum(Auf.P.TerminZusage) + ' ' +
                                 CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'QU') then
                        vAdd # CnvAi(Auf.P.TerminZ.Zahl,_FmtNumNoZero) + '. quarter ' +
                             CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'SE') then
                        vAdd # CnvAi(Auf.P.TerminZ.Zahl,_FmtNumNoZero) + '. semester ' +
                             CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                      else if (Auf.P.Termin1W.Art = 'JA') then
                        vAdd # 'year ' +  CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup);
                    end;
    'TERMINZUSATZ': vAdd # Auf.P.Termin.zusatz;
    'AF_OS_KURZ' :  vAdd # Auf.P.AusfOben;
    'AF_US_KURZ' :  vAdd # Auf.P.AusfUnten;
    'AF_OS_LANG' :  begin
                    vA # '';
                    FOR vErg # RecLink(402,401,11,_recFirst)  // Ausführungen loopen
                    LOOP vErg # RecLink(402,401,11,_recNext)
                    WHILE (vErg<=_rLocked) do begin
                      if (Auf.AF.Seite<>'1') then CYCLE;
                      if vA <> '' then vA # vA + ', ';
                      vA # vA + Auf.AF.Bezeichnung;
                      if (Auf.AF.Zusatz<>'') then vA # vA + ' '+Auf.AF.Zusatz;
                      if (vZeilen>0) then begin
                        aInhalt # aInhalt + StrChar(10);
                        aLabels # aLabels + StrChar(10);
                        aZusatz # aZusatz + StrChar(10);
                      end;
                    END;
                    inc(vZeilen);
                    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    vPre # '';
                    end;

    'AF_US_LANG' :  begin
                    vA # '';
                    FOR vErg # RecLink(402,401,11,_recFirst)  // Ausführungen loopen
                    LOOP vErg # RecLink(402,401,11,_recNext)
                    WHILE (vErg<=_rLocked) do begin
                      if (Auf.AF.Seite<>'2') then CYCLE;
                      if vA <> '' then vA # vA + ', ';
                      vA # vA + Auf.AF.Bezeichnung;
                      if (Auf.AF.Zusatz<>'') then vA # vA + ' '+Auf.AF.Zusatz;
                      if (vZeilen>0) then begin
                        aInhalt # aInhalt + StrChar(10);
                        aLabels # aLabels + StrChar(10);
                        aZusatz # aZusatz + StrChar(10);
                      end;
                    END;
                    inc(vZeilen);
                    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                    vPre # '';
                    end;
    'AF_OS+US_KURZ' :  begin
                    vAdd # Auf.P.AusfOben;
                    if (Auf.P.AusfUnten <> '') then
                      vAdd # vAdd + ', ';
                    vAdd # vAdd +  Auf.P.AusfUnten;
                  end;

    'BEST.DATUM' :  if (Auf.Best.Datum<>0.0.0) then
                      vAdd # cnvad(Auf.Best.Datum)
    'BEST.NUMMER' : if (Auf.Best.Nummer<>Auf.P.Best.Nummer) and (Auf.P.Best.Nummer<>'') then
                      vAdd # Auf.P.Best.Nummer;
    'ZEUGNIS' :     vAdd # Auf.P.Zeugnisart;
    'RID' :         if (Auf.P.RID<>0.0) or (Auf.P.RIDmax<>0.0) then
                      vAdd # AlphaMinMax(Auf.P.RID, Auf.P.RIDmax, Set.Stellen.Radien, '');
    'RAD' :         if (Auf.P.RAD<>0.0) or (Auf.P.RADmax<>0.0) then
                      vAdd # AlphaMinMax(Auf.P.RAD, Auf.P.RADmax, Set.Stellen.Radien, '');
    // 'MEH' :         vAdd # Auf.P.MEH.Preis;
    'MEH' : begin           if (Auf.P.Meh.Preis != 'Stk') then vAdd # Auf.P.MEH.Preis
                            else vAdd # 'pcs';
                        end;

    'PEH' :         vAdd # aint(Auf.P.PEH);
    'EINZELPREIS' : vAdd # anum(Auf.P.Einzelpreis, 2);
    'GRUNDPREIS' :  vAdd # anum(Auf.P.Grundpreis, 2);
    'GESAMTPREIS' : vAdd # anum(Auf.P.GesamtPreis,2);
    'NETTOWERT' :   vAdd # aNum(Erl.Netto,2);
    'BRUTTOWERT' :  vAdd # aNum(Erl.Brutto,2);

    'RECHNUNGSBETRAG' :     if (Auf.Vorgangstyp=c_AUF) then vAdd # aNum(Erl.Brutto,2);
    'GUTSCHRIFTSBETRAG' :   if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then vAdd # aNum(Erl.Brutto,2);
    'BELASTUNGSBETRAG' :    if (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then vAdd # aNum(Erl.Brutto,2);

    'RECHNUNGSWAE'    :     if (Auf.Vorgangstyp=c_AUF) then vAdd # "Wae.Kürzel";
    'GUTSCHRIFTSWAE'    :   if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then vAdd # "Wae.Kürzel";
    'BELASTUNGSWAE'    :    if (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then vAdd # "Wae.Kürzel";

    'MWSTSATZ' :    vAdd # anum(Sts.Prozent,2);
    'MWST' :        vAdd # anum(Erl.Steuer,2);
    'MWSTNETTO' :   vAdd # anum(Erl.Netto,2);
    'ARTIKELNR' :   vAdd # Auf.P.Artikelnr;
    'ART.BEZ1' :    vAdd # Art.Bezeichnung1;
    'ART.BEZ2' :    vAdd # Art.Bezeichnung2;
    'ART.BEZ3' :    vAdd # Art.Bezeichnung3;
    'KUNDENARTNR' : vAdd # Auf.P.KundenArtNr;
    'INTRASTAT' :   vAdd # Auf.P.IntraStatNr;
    'BEMERKUNG' :   vAdd # Auf.P.Bemerkung;

    // Verpackung ------------------------------------------------------------
    'VPG' :         begin
                      if (Auf.P.StehendYN) then ADD_VERP('stehend','');
                      if (Auf.P.LiegendYN) then ADD_VERP('liegend','');
                      //Abbindung
                      if (Auf.P.AbbindungQ <> 0 or Auf.P.AbbindungL <> 0) then begin
                        //Quer
                        if(Auf.P.AbbindungQ<>0)then vA2 # 'Abbindung '+ AInt(Auf.P.AbbindungQ)+' x quer' ;
                        //Längs
                        if(Auf.P.AbbindungL<>0)then begin
                          if (vA2<>'')then
                            vA2 # vA2+'  '+AInt(Auf.P.AbbindungL)+ ' x längs';
                          else
                            vA2 # 'Abbindung ' + AInt(Auf.P.AbbindungL)+' x längs';
                        end;
                       ADD_VERP(vA2,'')
                       vA2 # '';
                      end;
                      if (Auf.P.Zwischenlage <> '') then ADD_VERP(Auf.P.Zwischenlage,'');
                      if (Auf.P.Unterlage <> '') then ADD_VERP(Auf.P.Unterlage,'');
                      if (Auf.P.Umverpackung<>'') then ADD_VERP(Auf.P.Umverpackung,'');
                      if (Auf.P.Nettoabzug > 0.0) then ADD_VERP('Nettoabzug: '+AInt(CnvIF(Auf.P.Nettoabzug))+' kg','');
                      if ("Auf.P.Stapelhöhe" > 0.0) then ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("Auf.P.Stapelhöhe"))+' mm');
                      if (Auf.P.StapelhAbzug > 0.0) then ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("Auf.P.StapelhAbzug"))+' mm');
                      if (Auf.P.RingKgVon + Auf.P.RingKgBis  <> 0.0) then begin
                        vA2 # 'Ringgew.: '+AlphaMinMax(Auf.P.RingkgVon, Auf.P.RingKGBis, 0, '');
                        vA2 # vA2+' kg';
                        ADD_VERP(vA2,'')
                      end;
                      if (Auf.P.KgmmVon + Auf.P.KgmmBis  <> 0.0) then begin
                        vA2 # 'Kg/mm: '+AlphaMinMax(Auf.P.KgmmVon, Auf.P.KgmmBis, 2, '');
                        ADD_VERP(vA2,'')
                        vA2 # '';
                      end;
                      if ("Auf.P.StückProVE" > 0) then ADD_VERP(AInt("Auf.P.StückProVE") + ' Stück pro VE', '');
                      if (Auf.P.VEkgMax > 0.0) then ADD_VERP('max. '+anum(Auf.P.VEkgMax,0)+' kg pro VE: ', '');
                      if (Auf.P.RechtwinkMax > 0.0) then ADD_VERP('max. Rechtwinkligkeit: ', ANum(Auf.P.RechtwinkMax,-1));
                      if (Auf.P.EbenheitMax > 0.0) then ADD_VERP('max. Ebenheit: ', ANum(Auf.P.EbenheitMax,-1));
                      if ("Auf.P.SäbeligkeitMax" > 0.0) then ADD_VERP('max. Säbeligkeit: ', ANum("Auf.P.SäbeligkeitMax",-1)+' pro '+anum("Auf.P.SäbelProM",2)+' m');
                      if (Auf.P.Wicklung<>'') then ADD_VERP('Wicklung: ', Auf.P.Wicklung);
                      vAdd # vA;
                    end;
    'VPG_TEXT1' :   vAdd # Auf.P.VpgText1;
    'VPG_TEXT2' :   vAdd # Auf.P.VpgText2;
    'VPG_TEXT3' :   vAdd # Auf.P.VpgText3;
    'VPG_TEXT4' :   vAdd # Auf.P.VpgText4;
    'VPG_TEXT5' :   vAdd # Auf.P.VpgText5;
    'VPG_TEXT6' :   vAdd # Auf.P.VpgText6;

    // Analyse ---------------------------------------------------------------
    'STRECK' :        vAdd # AlphaMinMax(Auf.P.Streckgrenze1, Auf.P.Streckgrenze2, -1, 'N/mm²');
    'ZUG' :           vAdd # AlphaMinMax(Auf.P.Zugfestigkeit1, Auf.P.Zugfestigkeit2, -1, 'N/mm²');
    'DEHNUNG' :       if (Abs(Auf.P.DehnungA1)+abs(Auf.P.DehnungA2)+Abs(Auf.P.DehnungB1)+Abs(Auf.P.DehnungB2)<>0.0) then
                        vAdd # ANum(Auf.P.DehnungA1,-1) + ' / ' + ANum(Auf.P.DehnungB1,-1) + '% - ' + ANum(Auf.P.DehnungA2,-1) + ' / ' + ANum(Auf.P.DehnungB2,-1) + '%';
    'RP02' :          vAdd # AlphaMinMax(Auf.P.DehngrenzeA1, Auf.P.DehngrenzeA2, -1, 'N/mm²');
    'RP10' :          vAdd # AlphaMinMax(Auf.P.DehngrenzeB1, Auf.P.DehngrenzeB2, -1, 'N/mm²');
    'KÖRNUNG' :       vAdd # AlphaMinMax("Auf.P.Körnung1", "Auf.P.Körnung2", -1, '');
    'HÄRTE' :         vAdd # AlphaMinMax("Auf.P.Härte1", "Auf.P.Härte2", -1, '');
    'RAU_OS' :        vAdd # AlphaMinMax(Auf.P.RauigkeitA1, Auf.P.RauigkeitA2, -1, '');
    'RAU_US' :        vAdd # AlphaMinMax(Auf.P.RauigkeitB1, Auf.P.RauigkeitB2, -1, '');
    'MECH_SONST' :    vAdd # Auf.P.Mech.Sonstig1;
    'CHEMIE_C'  :     vAdd # AlphaMinMax(Auf.P.Chemie.C1, Auf.P.Chemie.C2, -1, '');
    'CHEMIE_SI' :     vAdd # AlphaMinMax(Auf.P.Chemie.Si1, Auf.P.Chemie.Si2, -1, '');
    'CHEMIE_MN' :     vAdd # AlphaMinMax(Auf.P.Chemie.Mn1, Auf.P.Chemie.Mn2, -1, '');
    'CHEMIE_P'  :     vAdd # AlphaMinMax(Auf.P.Chemie.P1, Auf.P.Chemie.P2, -1, '');
    'CHEMIE_S'  :     vAdd # AlphaMinMax(Auf.P.Chemie.S1, Auf.P.Chemie.S2, -1, '');
    'CHEMIE_AL' :     vAdd # AlphaMinMax(Auf.P.Chemie.AL1, Auf.P.Chemie.AL2, -1, '');
    'CHEMIE_CR' :     vAdd # AlphaMinMax(Auf.P.Chemie.CR1, Auf.P.Chemie.CR2, -1, '');
    'CHEMIE_V'  :     vAdd # AlphaMinMax(Auf.P.Chemie.V1, Auf.P.Chemie.V2, -1, '');
    'CHEMIE_NB' :     vAdd # AlphaMinMax(Auf.P.Chemie.NB1, Auf.P.Chemie.NB2, -1, '');
    'CHEMIE_TI' :     vAdd # AlphaMinMax(Auf.P.Chemie.TI1, Auf.P.Chemie.TI2, -1, '');
    'CHEMIE_N'  :     vAdd # AlphaMinMax(Auf.P.Chemie.N1, Auf.P.Chemie.N2, -1, '');
    'CHEMIE_CU' :     vAdd # AlphaMinMax(Auf.P.Chemie.CU1, Auf.P.Chemie.CU2, -1, '');
    'CHEMIE_NI' :     vAdd # AlphaMinMax(Auf.P.Chemie.NI1, Auf.P.Chemie.NI2, -1, '');
    'CHEMIE_MO' :     vAdd # AlphaMinMax(Auf.P.Chemie.MO1, Auf.P.Chemie.MO2, -1, '');
    'CHEMIE_B'  :     vAdd # AlphaMinMax(Auf.P.Chemie.B1, Auf.P.Chemie.B2, -1, '');
    'CHEMIE_FREI1'  : vAdd # AlphaMinMax(Auf.P.Chemie.Frei1.1, Auf.P.Chemie.Frei1.2, -1, '');
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
//  Parse401Multi
//=======================================================================
sub Parse401Multi(
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
        vTmp # Parse401(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse403
//=======================================================================
sub Parse403(
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
  vAdd    : alpha(4096);

  vKey1 : alpha;
  vKey2 : alpha;
  vKey3 : alpha;
  vKey4 : alpha;

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
    'MENGE+MEH' :   if ("Auf.Z.Menge"<>0.0) then begin
                      if (Auf.Z.MEH<>'%') and (Auf.Z.MengenbezugYN) then RETURN 0;
                      if (Auf.Z.MEH='Stk') then
                        vAdd # anum("Auf.Z.Menge", 0)+' '+'pcs'
                      else if (Auf.Z.MEH='kg') then
                        vAdd # anum("Auf.Z.Menge", Set.Stellen.Gewicht)+' '+Auf.Z.MEH
                      else if (Auf.Z.MEH='%') then
                        vAdd # anum("Auf.Z.Menge", 2)+' '+Auf.Z.MEH
                      else
                        vAdd # anum("Auf.Z.Menge", Set.Stellen.Menge)+' '+Auf.Z.MEH;
                    end;
    'BEZEICHNUNG'  : begin

                      if("Auf.Z.Schlüssel" = '') then vAdd # Auf.Z.Bezeichnung
                      else begin
                        if (APL_Data:HoleAufpreis("Auf.Z.Schlüssel", today)=_rOK) then
                        vAdd #ApL.L.Bezeichnung.L2;
                      end;
                    end;
    'MEH' :         begin
                      if (Auf.Z.MengenbezugYN) then RETURN 0;
                      if (Auf.Z.MEH='%') then RETURN 0;
                      if (Auf.Z.MEH='Stk') then
                        vAdd # anum("Auf.Z.Menge", 0)+' '+'pcs'
                      else vAdd # Auf.Z.MEH;
                    end;
    'PEH' :         begin
                      if (Auf.Z.MEH='%') then RETURN 0;
                      vAdd # aint(Auf.Z.PEH);
                    end;
    'PREIS' :       begin
                      if (Auf.Z.MEH='%') then RETURN 0;
                      vAdd # anum(Auf.Z.Preis, 2);
                    end;
    'PREIS+WAE' :   begin
                      if (Auf.Z.MEH='%') then RETURN 0;
                      vAdd # anum(Auf.Z.Preis, 2)+' '+"Wae.Kürzel";
                    end;
    'GESAMTPREIS' : vAdd # anum(aGesamtpreis,2);

    'PEH+MEH' :
                    begin
                      if (Auf.Z.MEH='%') then RETURN 0;

                      vAdd # aint(Auf.Z.PEH) + ' ';

                    if (auf.p.meh.preis != 'Stk') then begin

                      if (Auf.Z.MengenbezugYN) then
                        vAdd # vAdd + Auf.P.MEH.Preis;
                      else begin
                        if auf.z.meh != 'Stk' then
                        vAdd # vAdd + Auf.Z.MEH
                        else
                        vAdd # vAdd + 'pcs';
                      end


                    end
                    else begin
                      if (Auf.Z.MengenbezugYN) then
                        vAdd # vAdd + 'pcs';
                      else begin
                        if auf.z.meh != 'Stk' then
                        vAdd # vAdd + Auf.Z.MEH
                        else
                        vAdd # vAdd + 'pcs';
                      end

                    end;
                    end;

    'PEH+MEH_Z' :
                    begin
                      if (Auf.Z.MEH='%') then RETURN 0;


                      if (Auf.Z.PEH <> 1)  then
                        vAdd # aint(Auf.Z.PEH) + ' ';

                      if (auf.z.meh != 'Stk') then
                      vAdd # vAdd + Auf.Z.MEH;
                      else
                      vAdd # vAdd + 'pcs';
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
//  Parse403Multi
//=======================================================================
sub Parse403Multi(
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
        vTmp # Parse403(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aGesamtpreis);
        if (vTmp<0) then RETURN vTmp;
        vMax # Max(vTmp, vmax);
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
//  Parse404
//=======================================================================
sub Parse404(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  aCount        : int) : int;
local begin
  vZeilen : int;
  vA      : alpha(4096);
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
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
    'COUNT' :           vAdd # aint(aCount);
    'NUMMER' :          if (Auf.A.Aktionsnr<>0) then
                          vAdd # aint(Auf.A.Aktionsnr);
    'TERMINENDE' :      if (Auf.A.TerminEnde<>0.0.0) then
                          vAdd # cnvad(Auf.A.TerminEnde);
    'STÜCK' :           if ("Auf.A.Stückzahl"<>0) then
                          vAdd # aint("Auf.A.Stückzahl");
    'PREISMENGE+MEH' :  if ("Auf.A.Menge.Preis"<>0.0) then begin
                          if (Auf.A.MEH.Preis='Stk') then
                            vAdd # anum("Auf.A.Menge.Preis", 0)+' '+Auf.A.MEH.Preis
                          else if (Auf.A.MEH.Preis='kg') then
                            vAdd # anum("Auf.A.Menge.Preis", Set.Stellen.Gewicht)+' '+Auf.A.MEH.Preis
                          else
                            vAdd # anum("Auf.A.Menge.Preis", Set.Stellen.Menge)+' '+Auf.A.MEH.Preis;
                        end;

    // --- 05.03.2013 TM ---
    'GÜTE' :            vAdd # "Auf.P.Güte" ;

    'MENGE+MEH' :       begin

                          if ("Auf.A.Menge"<>0.0) then begin
                            if (Auf.A.MEH='Stk') then
                              vAdd # anum("Auf.A.Menge", 0)+' '+Auf.A.MEH
                            else if (Auf.A.MEH='kg') then
                              vAdd # anum("Auf.A.Menge", Set.Stellen.Gewicht)+' '+Auf.A.MEH
                            else
                              vAdd # anum("Auf.A.Menge", Set.Stellen.Menge)+' '+Auf.A.MEH;
                            end;

                        end;

    // --- 05.03.2013 TM ---

    // --- 05.03.2013 TM - vorerst getauscht; funktionierte so nicht mit Fertigmeldung Extern!
    // 'MENGE+MEH' :       if ("Auf.A.Menge"<>0.0) and (Auf.A.MEH<>Auf.A.MEH.Preis) then begin
    //                       if (Auf.A.MEH='Stk') then
    //                         vAdd # anum("Auf.A.Menge", 0)+' '+Auf.A.MEH
    //                       else if (Auf.A.MEH='kg') then
    //                         vAdd # anum("Auf.A.Menge", Set.Stellen.Gewicht)+' '+Auf.A.MEH
    //                       else
    //                         vAdd # anum("Auf.A.Menge", Set.Stellen.Menge)+' '+Auf.A.MEH;
    //                      end;


    'LFS.KENNZEICHEN' : vAdd # Lfs.Kennzeichen;
    'MEH' : begin           if (Auf.A.Meh != 'Stk') then vAdd # Auf.A.MEH
                            else vAdd # 'pcs';
                        end;

    'PEH' :             vAdd # aint(Auf.P.PEH);
    'MATERIALNR' :      vAdd # aint(Auf.A.Materialnr);
    'ARTIKELNR' :       vAdd # Auf.A.Artikelnr;
    'INTERNECHARGE' :   vAdd # Auf.A.Charge;
    'DICKE' :           if (Auf.A.Dicke<>0.0) then
                          vAdd # anum(Auf.A.Dicke, Set.Stellen.Dicke);
    'BREITE':           if (Auf.A.Breite<>0.0) then
                          vAdd # anum(Auf.A.Breite, Set.Stellen.Breite);
    'LÄNGE' :           if ("Auf.A.Länge"<>0.0) then
                          vAdd # anum("Auf.A.Länge", "Set.Stellen.Länge");
    'COILNR' :          vAdd # Mat.Coilnummer;
    'CHARGENNR' :       vAdd # Mat.Chargennummer;
    'WERKSNR' :         vAdd # Mat.Werksnummer;
    'ABMESSUNG' :     begin
                        if (Auf.A.Dicke<>0.0) then vAdd # anum(Auf.A.Dicke, Set.Stellen.Dicke);
                        if (Auf.A.Breite<>0.0) then begin
                          if (vAdd<>'') then vAdd # vAdd + ' x ';
                          vAdd # vAdd + anum(Auf.A.Breite, Set.Stellen.Breite);
                          if ("Auf.A.Länge"<>0.0) then
                            vAdd # vAdd + ' x ' + anum("Auf.A.Länge", "Set.Stellen.Länge");
                        end;
                    end;

    'GEWICHT.NETTO'   : vAdd  # anum(Mat.Gewicht.Netto, Set.Stellen.Gewicht);
    'GEWICHT.BRUTTO'  : vAdd  # anum(Mat.Gewicht.Brutto, Set.Stellen.Gewicht);

    'AUFTRAG'  :        vAdd # aint(Auf.A.Nummer);
    'POSITION' :        vAdd # aint(Auf.A.Position);
    'BEST.NUMMER' :     vAdd # Auf.Best.Nummer
    'GÜTE' :            vAdd # "Auf.P.Güte";
    'RECHNUNGSNR' :     vAdd # Aint(Auf.A.Rechnungsnr);
    'WGRBEZEICHNUNG' :  vAdd # Wgr.Bezeichnung.L2;


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
//  Parse404Multi
//=======================================================================
sub Parse404Multi(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aObjName      : alpha;
  aKombi        : logic;
  aCount        : int) : int;
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
        vTmp # Parse404(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aCount);
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
