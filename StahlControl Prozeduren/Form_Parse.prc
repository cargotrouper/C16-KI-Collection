@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den Formularen
//
//
//  07.11.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB _AddLIZ
//  SUB _AlphaMinMax
//  SUB _ParseAllgemein
//  SUB _ParseAllgemeinMulti
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  _AddLiz
//=======================================================================
sub _AddLIZ(
  var aLabel  : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aNewLabel   : alpha(4096);
  aNewInhalt  : alpha(4096);
  aPre        : alpha(4096);
  aPost       : alpha(4096);
  aKombi      : logic;
  opt aNewZusatz  : alpha(4096);
  );
begin

  if (aKombi) then begin
//    aLabel  # aLabel + aNewLabel;
    aLabel # aLabel + aNewLabel + aPre + aNewInhalt + aPost
    end
  else begin
    aLabel  # aLabel + aNewLabel;
    aInhalt # aInhalt + aPre + aNewInhalt + aPost;
  end;

  aZusatz # aZusatz + aNewZusatz;
end;


//=======================================================================
//  _AlphaMinMAx
//=======================================================================
sub _AlphaMinMax(
  aMin      : float;
  aMax      : float;
  aDeci     : int;
  aPostfix  : alpha;
  opt aNull : logic) : alpha
local begin
  vA        : alpha(4096);
end;
begin

  if (aMin=0.0) and (aMax=0.0) then begin
    if (aNull) then RETURN anum(0.0, aDeci);
    else RETURN '';
  end;

  if (aPostfix<>'') then aPostfix # ' ' +aPostfix;
  if (aMin<0.0) then aMin # 0.0;
  if (aMax<0.0) then aMax # 0.0;

  if (aMin=aMax) then
    vA # ANum(aMin,aDeci) + aPostfix
  else if (aMin<>0.0 and aMax<>0.0) then
    vA # ANum(aMin,aDeci) + aPostFix + ' - ' + ANum(aMax, aDeci) + aPostfix
  else if (aMin<>0.0) and (aMax=0.0) then
    vA # 'min. ' + ANum(aMin, aDeci) + aPostfix
  else
    vA # 'max. ' + ANum(aMax, aDeci) + aPostfix;

  RETURN vA;
end;

//=======================================================================
//  _ParseAllgemein
//=======================================================================
Sub _ParseAllgemein(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aFeld       : alpha;
  aTitel      : alpha;
  aPost       : alpha;
  aPre        : alpha;
  aKombi      : logic;
  var aZeilen : int;
  ) : logic
local begin
  vAdd    : alpha(4096);
  v100    : int;
end;
begin

  // Konstante?
  if (StrCut(aFeld,1,1)='_') then begin
    inc(aZeilen);
    _AddLIZ(var aLabels, var aInhalt, var aZusatz, aTitel, StrCut(aFeld,2,500), aPre, aPost, aKombi);
    RETURN true;
  end;

  case (StrCnv(aFeld, _StrUpper)) of

    'SEITE' :               vAdd # aint(form_Job->prtinfo(_PrtJobPageCount)+1);
    'SEITE+1' :             vAdd # aint(form_Job->prtinfo(_PrtJobPageCount)+2);
    'TODAY' :               vAdd #  cnvad(today);
    'ABSENDER' :            vAdd # Set.Absenderzeile;
    'MFGTEXT' :             vAdd # Set.Mfg.Text;
    'WAE' :                 vAdd # "Wae.Kürzel";
    'W1' :                  vAdd # "Set.Hauswährung.Kurz";
    'EIGEN.USIDENTNR' :     begin
                              vAdd # Lnd.UStIdentNr;
                              if (vAdd='') then begin
                                v100 # RecbufCreate(100);
                                v100->ADr.Nummer # Set.EigeneAdressnr;
                                if (RecRead(v100,1,0)<=_rLocked) then
                                  vAdd # v100->Adr.UsIdentNr;
                                RecBufDestroy(v100);
                              end;
                            end;
    'USER' :                begin
                              vAdd # Usr.Name;
                              if (Usr.Anrede<>'') then vAdd # Usr.Anrede + ' ' + vAdd;
                            end;
    'USER.ANREDE' :         vAdd # Usr.Anrede;
    'USER.NAME' :           vAdd # Usr.Name;
    'USER.VOLLERNAME' :     begin
                              vAdd # Usr.Name;
                              if (Usr.Vorname<>'') then vAdd # Usr.Vorname + ' ' + vAdd;
                              if (Usr.Anrede<>'') then vAdd # Usr.Anrede + ' ' + vAdd;
                            end;
    'USER.TELEFON' :        vAdd # Usr.Telefonnr;
    'USER.TELEFAX' :        vAdd # Usr.Telefaxnr;
    'USER.EMAIL' :          vAdd # Usr.EMail;
    'FELD' :                begin
                              aZeilen # -1;
                              RETURN true;
                            end;
    otherwise RETURN false;
  end;


  if (vAdd<>'') then begin
    inc(aZeilen);
    AddLIZ(var aLabels, var aInhalt, var aZusatz, aTitel, vAdd, aPre, aPost, aKombi);
  end;

  RETURN true;
end;


//=======================================================================
//  _ParseAllgemeinMulti
//=======================================================================
sub _ParseAllgemeinMulti(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  opt aKombi  : logic) : int
local begin
  vTitel      : alpha(4096);
  vPre        : alpha(4096);
  vPost       : alpha(4096);
  vFeld       : alpha(4096);
  vZeilen     : int;
  vCap        : alpha(4096);
  vRow        : alpha(4096);
  vToken      : alpha(4096);
  vI,vJ       : int;
  vK,vL       : int;
  vOK         : logic;
  vZ          : int;
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
    if (vL=0) then begin //and (vRow<>'') then begin
        _AddLiz(var aLabels, var aInhalt, var aZusatz, '', vRow, '','', aKombi);
      inc(vZ);
      end
    else begin
      FOR vK # 1 loop inc(vK) WHILE (vK<=vL) do begin
        vToken # Str_Token(vRow, '@', vK+1);

        vFeld   # Str_Token(vToken, '|', 1);
        vTitel  # Str_Token(vToken, '|', 2);
        vPost   # Str_Token(vToken, '|', 3);
        vPre    # Str_Token(vToken, '|', 4);

        if (_ParseAllgemein(var aLabels, var aInhalt, var aZusatz, vFeld, vTitel, vPost, vPre, aKombi, var vZ)) then begin
          if (vZ<0) then RETURN vZ;
        end;
//        vZ # vZ + Parse501(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
      END;
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