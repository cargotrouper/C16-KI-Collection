@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Kas
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Kassen Formularen
//
//
//  07.01.2013  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB Parse573(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse573Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form


//=======================================================================
//  Parse573
//=======================================================================
sub Parse573(
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
    'ADR.NAME'    :   vAdd  # Adr.Name;
    'ADR.ANREDE'  :   vAdd  # Adr.Anrede;
    'ADR.ZUSATZ'  :   vAdd  # Adr.Zusatz;
    'ADR.STRASSE'  :  vAdd  # "Adr.Straße";
    'ADR.ORT'  :      vAdd  # Adr.Ort
    'ADR.PLZ'  :      vAdd  # Adr.Plz;
    'ADR.LAND' :      vAdd  # Lnd.Name.L1;
    'BEZEICHNUNG' :   vAdd # Kas.B.Bezeichnung;
    'ZEITRAUM' :    begin
                      if (Kas.B.Start.Datum<>0.0.0) then  vAdd # cnvad(Kas.B.Start.Datum)+' ';
                      if (Kas.B.Ende.Datum<>0.0.0) then   vAdd # vAdd + translate('bis')+' '+cnvad(Kas.B.Ende.Datum);
                    end;
    'BELEGDATUM' :    if (Kas.B.P.Belegdatum<>0.0.0) then vAdd # cnvad(Kas.B.P.Belegdatum);
    'BEMERKUNG' :     vAdd # Kas.B.P.Bemerkung;
    'GEGENKONTO' :    if (Kas.B.P.Gegenkonto<>0) then     vAdd  # aint(Kas.B.P.Gegenkonto);
    'GEGENKONTONAME' :  vAdd  # GKo.Bezeichnung;
    'AUSGANG'  :      vAdd  # anum(Kas.B.P.Ausgang,2);
    'EINGANG'  :      vAdd  # anum(Kas.B.P.Eingang,2);
    'STEUER'   :      if (Kas.B.P.Steuer <>0.0) then      vAdd  # anum(Kas.B.P.Steuer,2);
    'STEUER1' :     if (GV.Num.01>0.0) then begin
                      vAdd    # anum(GV.Num.02,2)+' '+"Set.Hauswährung.kurz";
                      vTitel  # vTitel + ' '+anum(Gv.num.01,2)+'%';
                    end;
    'STEUER2' :     if (GV.Num.03>0.0) then begin
                      vAdd    # anum(GV.Num.04,2)+' '+"Set.Hauswährung.kurz";
                      vTitel  # vTitel + ' '+anum(Gv.num.03,2)+'%';
                    end;

    'SALDO' :         vAdd  # anum(Kas.B.P.Saldo,2);
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
//  Parse573Multi
//=======================================================================
sub Parse573Multi(
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
        vTmp # Parse573(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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