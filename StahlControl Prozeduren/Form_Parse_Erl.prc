@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_Erl
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Formularen
//
//
//  12.09.2013  ST  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB Parse450(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int) : int;
//  SUB Parse450Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aBuf100Re : int; aBuf101We : int; aBuf110Ver1 : int; aBuf110Ver2 : int) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  Parse450
//=======================================================================
Sub Parse450(
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
  v812        : int;
end;
begin

  if Form_DokSprache = 'E' then begin
    vZeilen # Form_Parse_Erl_E:Parse450(var aLabels, var aInhalt, var aZusatz,aText,aKombi);
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
    'ERL.NUMMER'          :  vAdd # aint(Erl.Rechnungsnr);
    'ERL.RECHNUNGSDATUM'  :  vAdd # cnvad(Erl.Rechnungsdatum);
    'ERL.GEWICHT'         :  vAdd # anum(Erl.Gewicht, Set.Stellen.Gewicht);
    'ERL.NETTOBETRAG'     :  vAdd # anum(Erl.NettoW1, 2);

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
//  Parse450Multi
//=======================================================================
sub Parse450Multi(
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
    vZeilen # Form_Parse_Erl_E:Parse450Multi(var aLabels, var aInhalt, var aZusatz,aObjName,aKombi);
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
        vTmp # Parse450(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//=======================================================================
