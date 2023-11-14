@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Ofp
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Offenenposten Formularen
//
//
//  06.05.2013  ST  Erstellung der Prozedur
//  10.12.2013  ST  "Adr.Fax" hinzugefügt
//
//  Subprozeduren
//  SUB Parse460(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse460Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form


//=======================================================================
//  Parse460
//=======================================================================
sub Parse460(
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

  vNachfrist : date;
end;
begin
  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Ofp_E:Parse460(var aLabels, var aInhalt, var aZusatz,aText,aKombi);
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
    'ADR.NAME'            : vAdd  # Adr.Name;
    'ADR.ANREDE'          : vAdd  # Adr.Anrede;
    'ADR.ZUSATZ'          : vAdd  # Adr.Zusatz;
    'ADR.STRASSE'         : vAdd  # "Adr.Straße";
    'ADR.ORT'             : vAdd  # Adr.Ort
    'ADR.PLZ'             : vAdd  # Adr.Plz;
    'ADR.LAND'            : vAdd  # Lnd.Name.L1;
    'ADR.FAX'             : vAdd  # Adr.Telefax;

    'MAHNTITEL'           : vAdd  # 'Mahnung';
    'ADR.KUNDENNR'        : vAdd  # Aint(Adr.Kundennr);
    'ADR.VK.REFERENZNR'   : vAdd  # Adr.VK.Referenznr;
    'READR.USIDENTNR'     : vAdd  # Adr.USIdentNr;
    'READR.STEUERNUMMER'  : vAdd  # Adr.Steuernummer;


    'RENUMMER'            : vAdd # Aint(OfP.Rechnungsnr);
    'REDATUM'             : vAdd # CnvAd(OfP.Rechnungsdatum,_FmtInternal);
    'DATFÄLLIGKEIT'       : vAdd # CnvAd(OfP.Zieldatum);
    'MAHNSTUFE'           : vAdd # Aint(OfP.Mahnstufe);
    'NACHFRIST'           : begin

                              vNachfrist # today;
                              case (Ofp.Mahnstufe) of
                                0 : begin
                                  vNachfrist -> vmDayModify(Set.Fin.MahnTage1);
                                end;

                                1, 2 : begin
                                  vNachfrist -> vmDayModify(Set.Fin.MahnTage2);
                                end;
                              end;
                              vAdd # CnvAd(vNachfrist);

                            end;
    'BRUTTO+WAE'          : vAdd # Anum(OfP.Brutto,2) + ' ' + "Wae.Kürzel";
    'GEBÜHR+WAE'          : vAdd # Anum("OfP.Mahngebühr",2) + ' ' + "Wae.Kürzel";
    'ZINSEN+WAE'          : vAdd # Anum("OfP.Zinsen",2) + ' ' + "Wae.Kürzel";
    'REST+WAE'            : begin
                              vAdd # Anum(OfP.Rest,2) + ' ' + "Wae.Kürzel";

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
//  Parse460Multi
//=======================================================================
sub Parse460Multi(
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
    vZeilen # Form_Parse_Ofp_E:Parse460Multi(var aLabels, var aInhalt, var aZusatz,aObjName,aKombi);
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
        vTmp # Parse460(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
