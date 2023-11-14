@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Rek
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Formularen
//
//
//  16.01.2013  AI  Erstellung der Prozedur
//  21.07.2014  TM  Korrektur EinAB.Nummer
//
//  Subprozeduren
//  SUB Parse300(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse300Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//  SUB Parse301(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse301Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; opt aKombi : logic) : int
//  SUB Parse302(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse302Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; opt aKombi : logic) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  Parse300
//=======================================================================
Sub Parse300(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic;
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
  vErg        : int;
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
    'REKLAMATION' :     vAdd # aint(Rek.Nummer);
    'ADR.ANREDE' :      vAdd # Adr.Anrede;
    'ADR.NAME' :        vAdd # Adr.Name;
    'ADR.ZUSATZ' :      vAdd # Adr.Zusatz;
    'ADR.STRASSE' :     vAdd # "Adr.Straße";
    'ADR.STRASSEWENNKEINPOSTFACH' :
                        if (Adr.Postfach='') then
                          vAdd # "Adr.Straße";
    'ADR.PLZ' :         vAdd # Adr.PLZ;
    'ADR.PLZWENNKEINPOSTFACH' :
                        if (Adr.Postfach='') then
                          vAdd # Adr.PLZ;
    'ADR.ORT' :         vAdd # Adr.Ort;
    'ADR.POSTFACH' :    vAdd # Adr.Postfach;
    'ADR.POSTFACH.PLZ' :
                        vAdd # Adr.Postfach.PLZ;
    'ADR.LAND' :        vAdd # Lnd.Name.L1;
    'USIDENTNR' :       vAdd # Adr.UsIdentNr;
    'STEUERNUMMER' :    vAdd # Adr.Steuernummer;
    'KOMMISSION' :      vAdd # Rek.Kommission;
    'BESTELLUNG' :      vAdd # Rek.Kommission;
    'DATUM' :           if (Rek.Datum<>0.0.0) then
                          vAdd # cnvad(Rek.Datum);
    'KUNDENNR' :        vAdd # aint(Rek.Kundennr);
    'LIEFERANTENNR' :   vAdd # aint(Rek.Lieferantennr);
    'ADR.VK.REFERENZNR' :
                        vAdd # Adr.VK.Referenznr;
    'ADR.EK.REFERENZNR' :
                        vAdd # Adr.EK.Referenznr;
    'SACHBEARBEITER' :  vAdd # Rek.Sachbearbeiter;

    'ART.BEZ1' :        vAdd # Art.Bezeichnung1;
    'ART.BEZ2' :        vAdd # Art.Bezeichnung2;
    'ART.BEZ3' :        vAdd # Art.Bezeichnung3;


    'AUFNUMMER' :       vAdd # aint(Auf.P.Nummer);
    'AUFPOSITION' :     vAdd # aint(Auf.P.Position);
    'AUFTRAGSDATUM' :   if (Auf.Datum<>0.0.0) then
                          vAdd # cnvad(Auf.Datum);
    'AUFDICKE' :        if (Auf.P.Dicke<>0.0) then
                          vAdd # anum(Auf.P.Dicke,Set.Stellen.Dicke);
    'AUFDICKENTOL' :    vAdd # Auf.P.Dickentol;
    'AUFBREITE' :       if (Auf.P.Breite<>0.0) then
                          vAdd # aNum(Auf.P.Breite, Set.Stellen.Breite);
    'AUFBREITENTOL' :   vAdd # Auf.P.Breitentol;
    'AUFLÄNGE' :        if ("Auf.P.Länge"<>0.0) then
                          vAdd # aNum("Auf.P.Länge", "Set.Stellen.Länge");
    'AUFLÄNGENTOL' :    vAdd # "Auf.P.Längentol";
    'AUFGÜTE' :         vAdd # "Auf.P.Güte";
    'AUFWGR' :          vAdd # Wgr.Bezeichnung.L1;
    'AUFRID' :          if (Auf.P.RID<>0.0) or (Auf.P.RIDmax<>0.0) then
                          vAdd # AlphaMinMax(Auf.P.RID, Auf.P.RIDmax, Set.Stellen.Radien, '');
    'AUFRAD' :          if (Auf.P.RAD<>0.0) or (Auf.P.RADmax<>0.0) then
                          vAdd # AlphaMinMax(Auf.P.RAD, Auf.P.RADmax, Set.Stellen.Radien, '');
    'AUFTERMIN' :       begin
                          if (Auf.P.Termin1W.Art = 'DA') then
                            vAdd # CnvAd(Auf.P.Termin1Wunsch)
                          else if (Auf.P.Termin1W.Art = 'KW') then
                            vAdd # 'KW ' + CnvAi(Auf.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                                           CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'MO') then
                            vAdd # Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin1Wunsch) + ' ' +
                                     CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'QU') then
                            vAdd # CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
                                   CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'SE') then
                            vAdd # CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
                                   CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'JA') then
                            vAdd # 'Jahr ' +  CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup);
                        end;
    'AUFZUSAGETERMIN' : if (Auf.P.TerminZusage<>0.0.0) then begin
                          if (Auf.P.Termin1W.Art = 'DA') then
                            vAdd # CnvAd(Auf.P.TerminZusage)
                          else if (Auf.P.Termin1W.Art = 'KW') then
                            vAdd # 'KW ' + CnvAi(Auf.P.TerminZ.Zahl,_FmtNumLeadZero) + '/' +
                                          CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'MO') then
                            vAdd # Lib_Berechnungen:Monat_aus_datum(Auf.P.TerminZusage) + ' ' +
                                     CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'QU') then
                            vAdd # CnvAi(Auf.P.TerminZ.Zahl,_FmtNumNoZero) + '. Quartal ' +
                                 CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'SE') then
                            vAdd # CnvAi(Auf.P.TerminZ.Zahl,_FmtNumNoZero) + '. Semester ' +
                                 CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Auf.P.Termin1W.Art = 'JA') then
                            vAdd # 'Jahr ' +  CnvAi(Auf.P.TerminZ.Jahr,_FmtNumNoGroup);
                        end;
    'AUFTERMINZUSATZ' : vAdd # Auf.P.Termin.zusatz;
    'AUFBEST.NUMMER' :  if (Auf.Best.Nummer<>Auf.P.Best.Nummer) and (Auf.P.Best.Nummer<>'') then
                          vAdd # Auf.P.Best.Nummer;
    'AUFZEUGNIS' :      vAdd # Auf.P.Zeugnisart;
    'AUFMEH' :          vAdd # Auf.P.MEH.Preis;
    'AUFPEH' :          vAdd # aint(Auf.P.PEH);


    'AUFARTIKELNR' :    vAdd # Auf.P.Artikelnr;
    'AUFKUNDENARTNR' :  vAdd # Auf.P.KundenArtNr;
    'AUFINTRASTAT' :    vAdd # Auf.P.IntraStatNr;
    'AUFBEMERKUNG' :    vAdd # Auf.P.Bemerkung;

    'AUFAF_OS_KUEZ' :   vAdd # Auf.P.AusfOben;
    'AUFAF_US_KURZ' :   vAdd # Auf.P.AusfUnten;
    'AUFAF_OS_LANG' :   FOR vErg # RecLink(402,401,11,_recFirst)  // Ausführungen loopen
                        LOOP vErg # RecLink(402,401,11,_recNext)
                        WHILE (vErg<=_rLocked) do begin
                          if (Auf.AF.Seite<>'1') then CYCLE;
                          vA # Auf.AF.Bezeichnung;
                          if (Auf.AF.Zusatz<>'') then vA # vA + ' '+Auf.AF.Zusatz;
                          if (vZeilen>0) then begin
                            aInhalt # aInhalt + StrChar(10);
                            aLabels # aLabels + StrChar(10);
                            aZusatz # aZusatz + StrChar(10);
                          end;
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                          vPre # '';
                        END;
    'AUFAF_US_LANG' :   FOR vErg # RecLink(402,401,11,_recFirst)  // Ausführungen loopen
                        LOOP vErg # RecLink(402,401,11,_recNext)
                        WHILE (vErg<=_rLocked) do begin
                          if (Auf.AF.Seite<>'2') then CYCLE;
                          vA # Auf.AF.Bezeichnung;
                          if (Auf.AF.Zusatz<>'') then vA # vA + ' '+Auf.AF.Zusatz;
                          if (vZeilen>0) then begin
                            aInhalt # aInhalt + StrChar(10);
                            aLabels # aLabels + StrChar(10);
                            aZusatz # aZusatz + StrChar(10);
                          end;
                          inc(vZeilen);
                          AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vA, vPre, vPost, aKombi);
                          vPre # '';
                        END;

    // Bestellung
    'EINNUMMER' :       vAdd # aint(Ein.P.Nummer);
    'EINPOSITION' :     vAdd # aint(Ein.P.Position);
    'BESTELLDATUM' :   if (Ein.Datum<>0.0.0) then
                          vAdd # cnvad(Ein.Datum);
    'EINDICKE' :        if (Ein.P.Dicke<>0.0) then
                          vAdd # anum(Ein.P.Dicke,Set.Stellen.Dicke);
    'EINDICKENTOL' :    vAdd # Ein.P.Dickentol;
    'EINBREITE' :       if (Ein.P.Breite<>0.0) then
                          vAdd # aNum(Ein.P.Breite, Set.Stellen.Breite);
    'EINBREITENTOL' :   vAdd # Ein.P.Breitentol;
    'EINLÄNGE' :        if ("Ein.P.Länge"<>0.0) then
                          vAdd # aNum("Ein.P.Länge", "Set.Stellen.Länge");
    'EINLÄNGENTOL' :    vAdd # "Ein.P.Längentol";
    'EINGÜTE' :         vAdd # "Ein.P.Güte";
    'EINWGR' :          vAdd # Wgr.Bezeichnung.L1;
    'EINRID' :          if (Ein.P.RID<>0.0) or (Ein.P.RIDmax<>0.0) then
                          vAdd # AlphaMinMax(Ein.P.RID, Ein.P.RIDmax, Set.Stellen.Radien, '');
    'EINRAD' :          if (Ein.P.RAD<>0.0) or (Ein.P.RADmax<>0.0) then
                          vAdd # AlphaMinMax(Ein.P.RAD, Ein.P.RADmax, Set.Stellen.Radien, '');
    'EINTERMIN' :       begin
                          if (Ein.P.Termin1W.Art = 'DA') then
                            vAdd # CnvAd(Ein.P.Termin1Wunsch)
                          else if (Ein.P.Termin1W.Art = 'KW') then
                            vAdd # 'KW ' + CnvAi(Ein.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                                           CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'MO') then
                            vAdd # Lib_Berechnungen:Monat_aus_datum(Ein.P.Termin1Wunsch) + ' ' +
                                     CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'QU') then
                            vAdd # CnvAi(Ein.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
                                   CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'SE') then
                            vAdd # CnvAi(Ein.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
                                   CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'JA') then
                            vAdd # 'Jahr ' +  CnvAi(Ein.P.Termin1W.Jahr,_FmtNumNoGroup);
                        end;
    'EINZUSAGETERMIN' : if (Ein.P.TerminZusage<>0.0.0) then begin
                          if (Ein.P.Termin1W.Art = 'DA') then
                            vAdd # CnvAd(Ein.P.TerminZusage)
                          else if (Ein.P.Termin1W.Art = 'KW') then
                            vAdd # 'KW ' + CnvAi(Ein.P.TerminZ.Zahl,_FmtNumLeadZero) + '/' +
                                          CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'MO') then
                            vAdd # Lib_Berechnungen:Monat_aus_datum(Ein.P.TerminZusage) + ' ' +
                                     CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'QU') then
                            vAdd # CnvAi(Ein.P.TerminZ.Zahl,_FmtNumNoZero) + '. Quartal ' +
                                 CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'SE') then
                            vAdd # CnvAi(Ein.P.TerminZ.Zahl,_FmtNumNoZero) + '. Semester ' +
                                 CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup)
                          else if (Ein.P.Termin1W.Art = 'JA') then
                            vAdd # 'Jahr ' +  CnvAi(Ein.P.TerminZ.Jahr,_FmtNumNoGroup);
                        end;
//    'EINTERMINZUSATZ' : vAdd # Ein.P.Termin.zusatz;

    'EINAB.NUMMER' :  if (Ein.AB.Nummer<>Ein.P.AB.Nummer) and (Ein.P.AB.Nummer<>'') then
                          vAdd # Ein.P.AB.Nummer; // aus BestellPos. wenn vorhanden...
                      else
                        vAdd # Ein.AB.Nummer;     // ... sonst aus BestellKopf - vervpollständigt 2014-07-21 TM


    'EINZEUGNIS' :      vAdd # Ein.P.Zeugnisart;
    'EINMEH' :          vAdd # Ein.P.MEH.Preis;
    'EINPEH' :          vAdd # aint(Ein.P.PEH);


    'EINARTIKELNR' :    vAdd # Ein.P.Artikelnr;
    'EINLIEFERANTENARTNR' :
                        vAdd # Ein.P.LieferArtNr;
    'EININTRASTAT' :    vAdd # Ein.P.IntraStatNr;
    'EINBEMERKUNG' :    vAdd # Ein.P.Bemerkung;

    'EINAF_OS_KUEZ' :   vAdd # Ein.P.AusfOben;
    'EINAF_US_KURZ' :   vAdd # Ein.P.AusfUnten;
    'EINAF_OS_LANG' :   FOR vErg # RecLink(502,501,12,_recFirst)  // Ausführungen loopen
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
    'EINAF_US_LANG' :   FOR vErg # RecLink(502,501,12,_recFirst)  // Ausführungen loopen
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
//  Parse300Multi
//=======================================================================
sub Parse300Multi(
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
        vTmp # Parse300(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse301
//=======================================================================
sub Parse301(
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
  v819    : int;
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
    'POSITION' :        vAdd # aint(Rek.P.Position);
    'STATUS' :          vAdd # Stt.Bezeichnung;
    'FEHLER' :          vAdd # FhC.Bezeichnung;
    'VERURSACHER' :     begin
                          if (Rek.P.Verursacher=1) then  vAdd # Rek.P.VerursacherSW
                          else if (Rek.P.Verursacher=2) then  vAdd # Rek.P.VerursacherSW
                          else if (Rek.P.Verursacher=3) then  vAdd # Translate('Person')
                          else vAdd # Translate('unbekannt');
                        end;
    'MATDICKE' :        if (Mat.Dicke<>0.0) then
                          vAdd # anum(Mat.Dicke,Set.Stellen.Dicke);
    'MATDICKENTOL' :    vAdd # Mat.Dickentol;
    'MATBREITE' :       if (Mat.Breite<>0.0) then
                          vAdd # aNum(Mat.Breite, Set.Stellen.Breite);
    'MATBREITENTOL' :   vAdd # Mat.Breitentol;
    'MATLÄNGE' :        if ("Mat.Länge"<>0.0) then
                          vAdd # aNum("Mat.Länge", "Set.Stellen.Länge");
    'MATLÄNGENTOL' :    vAdd # "Mat.Längentol";
    'MATGÜTE' :         vAdd # "Mat.Güte";
    'MATWGR' :          begin
                          RekLinkB(v819,200,1,_recFirst);
                          vAdd # v819->Wgr.Bezeichnung.L1;
                          RecBufDestroy(v819);
                        end;
    'MATRID' :          if (Mat.RID<>0.0) then
                          vAdd # anum(Mat.RID, Set.Stellen.Radien);
    'MATRAD' :          if (Mat.RAD<>0.0) then
                          vAdd # aNum(Mat.RAD, Set.Stellen.Radien);
    'MATAF_OS_KUEZ' :   vAdd # "Mat.AusführungOben";
    'MATAF_US_KURZ' :   vAdd # "Mat.AusführungUnten";
    'MATAF_OS_LANG' :   FOR vErg # RecLink(201,200,11,_recFirst)  // Ausführungen loopen
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
    'MATAF_US_LANG' :   FOR vErg # RecLink(201,200,11,_recFirst)  // Ausführungen loopen
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

    'WERT'  :           if ("Rek.P.Wert"<>0.0) then
                          vAdd # anum(Rek.P.Wert,2);
    'WERT_W1'  :        if ("Rek.P.Wert.W1"<>0.0) then
                          vAdd # anum(Rek.P.Wert.W1,2);
    'STÜCK' :           if ("Rek.P.Stückzahl"<>0) then
                          vAdd # aint("Rek.P.Stückzahl");
    'GEWICHT' :         if ("Rek.P.Gewicht"<>0.0) then
                          vAdd # anum("Rek.P.Gewicht", Set.Stellen.Gewicht);
    'MENGE' :           if ("Rek.P.Menge"<>0.0) then begin
                          if (Rek.P.MEH='kg') then
                            vAdd # anum("Rek.P.Menge", Set.Stellen.Gewicht)
                          else if (Rek.P.MEH='Stk') then
                            vAdd # anum("Rek.P.Menge", 0)
                          else
                            vAdd # anum("Rek.P.Menge", Set.Stellen.Menge);
                        end;
    'MENGE+MEH' :       if ("Rek.P.Menge"<>0.0) then begin
                          if (Rek.P.MEH='kg') then
                            vAdd # anum("Rek.P.Menge", Set.Stellen.Gewicht)+' '+Rek.P.MEH
                          else if (Rek.P.MEH='Stk') then
                            vAdd # anum("Rek.P.Menge", 0)+' '+Rek.P.MEH
                          else
                            vAdd # anum("Rek.P.Menge", Set.Stellen.Menge)+' '+Rek.P.MEH;
                        end;

    'ANERKANNTWERT' :   if ("Rek.P.Aner.Wert"<>0.0) then
                          vAdd # anum(Rek.P.Aner.Wert,2);
    'ANERKANNTWERT_W1' :
                        if ("Rek.P.Aner.WertW1"<>0.0) then
                          vAdd # anum(Rek.P.Aner.WertW1,2);
    'ANERKANNTSTÜCK' :  if ("Rek.P.Aner.Stk"<>0) then
                          vAdd # aint("Rek.P.Aner.Stk");
    'ANERKANNTGEWICHT' :
                        if ("Rek.P.Aner.Gew"<>0.0) then
                          vAdd # anum("Rek.P.Aner.Gew", Set.Stellen.Gewicht);
    'ANERKANNTMENGE' :  if ("Rek.P.Aner.Menge"<>0.0) then begin
                          if (Rek.P.MEH='kg') then
                            vAdd # anum("Rek.P.Aner.Menge", Set.Stellen.Gewicht)
                          else if (Rek.P.MEH='Stk') then
                            vAdd # anum("Rek.P.Aner.Menge", 0)
                          else
                            vAdd # anum("Rek.P.Aner.Menge", Set.Stellen.Menge);
                        end;
    'ANERKANNTMENGE+MEH' :
                        if ("Rek.P.Aner.Menge"<>0.0) then begin
                          if (Rek.P.MEH='kg') then
                            vAdd # anum("Rek.P.Aner.Menge", Set.Stellen.Gewicht)+' '+Rek.P.MEH
                          else if (Rek.P.MEH='Stk') then
                            vAdd # anum("Rek.P.Aner.Menge", 0)+' '+Rek.P.MEH
                          else
                            vAdd # anum("Rek.P.Aner.Menge", Set.Stellen.Menge)+' '+Rek.P.MEH;
                        end;

    'MATERIALNR' :      vAdd # aint(Rek.P.Materialnr);
    'COILNR'  :         vAdd # Mat.Coilnummer;
    'WERKSNR' :         vAdd # Mat.Werksnummer;
    'CHARGENNR' :       vAdd # Mat.Chargennummer;
    'RINGNR' :          vAdd # Mat.Ringnummer;

    'RECHNUNG' :        if (Erl.Rechnungsnr<>0) then
                          vAdd # aint(Erl.Rechnungsnr);
    'RECHNUNGSDATUM' :  if (Erl.RechnungsDatum<>0.0.0) then
                          vAdd # cnvad(Erl.Rechnungsdatum);
    'LIEFERSCHEIN' :    if (Lfs.P.Nummer<>0) then
                          vAdd # aint(Lfs.P.Nummer);
    'LIEFERSCHEINDATUM' :
                        if (LFs.P.Datum.Verbucht<>0.0.0) then
                          vAdd # cnvad(LFs.P.Datum.Verbucht);

    otherwise           begin
                          // Allgemeiner Befehl?
                          if (ParseAllgemein(var aLabels, var aInhalt, var aZusatz, vFeld, vTitel, vPost, vPre, aKombi, var vZeilen)) then RETURN vZeilen;
                          // als Kopf parsen?
                          vZeilen # Parse300(var aLabels, var aInhalt, var aZusatz, aText, aKombi);
                        end;
  end;  // case

  if (vAdd<>'') then begin
    inc(vZeilen);
    AddLIZ(var aLabels, var aInhalt, var aZusatz, vTitel, vAdd, vPre, vPost, aKombi);
  end;


  RETURN vZeilen;
end;


//=======================================================================
//  Parse301Multi
//=======================================================================
sub Parse301Multi(
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
        vTmp # Parse301(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse302
//=======================================================================
Sub Parse302(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aText       : alpha(4096);
  aKombi      : logic;
  aCount      : int;
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
    'NUMMER' :          if (Rek.A.Aktionsnr<>0) then
                          vAdd # aint(Rek.A.Aktionsnr);
    'BEMERKUNG' :       vAdd # Rek.A.Bemerkung;
    'TERMINENDE' :      if (Rek.A.TerminEnde<>0.0.0) then
                          vAdd # cnvad(Rek.A.TerminEnde);
    'KOSTEN' :          if ("Rek.A.Kosten"<>0.0) then
                          vAdd # anum(Rek.A.Kosten,2);
    'KOSTEN_W1' :       if ("Rek.A.KostenW1"<>0.0) then
                          vAdd # anum(Rek.A.KostenW1,2);
    'STÜCK' :           if ("Rek.A.Stückzahl"<>0) then
                          vAdd # aint("Rek.A.Stückzahl");
    'GEWICHT' :         if ("Rek.A.Gewicht"<>0.0) then
                          vAdd # anum(Rek.A.Gewicht,Set.Stellen.Gewicht);
    'MENGE+MEH' :       if ("Rek.A.Menge"<>0.0) then begin
                          if (Rek.A.MEH='Stk') then
                            vAdd # anum("Rek.A.Menge", 0)+' '+Rek.A.MEH
                          else if (Rek.A.MEH='kg') then
                            vAdd # anum("Rek.A.Menge", Set.Stellen.Gewicht)+' '+Rek.A.MEH
                          else
                            vAdd # anum("Rek.A.Menge", Set.Stellen.Menge)+' '+Rek.A.MEH;
                        end;
    'MEH' :             vAdd # Rek.A.MEH;
    'PEH' :             vAdd # aint(Rek.A.PEH);

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
//  Parse302Multi
//=======================================================================
sub Parse302Multi(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  aKombi      : logic;
  aCount      : int;
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
        vTmp # Parse302(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aCount);
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