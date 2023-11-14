@A+
//===== Business-Control =================================================
//
//  Prozedur    Form_Parse_BAG
//                      OHNE E_R_G
//  Info
//    parst die @-Kommandos in den BAG Formularen
//
//
//  13.11.2012  AI  Erstellung der Prozedur
//  16.05.2013  TM  Auflaufhöhenberechnung ausgetauscht
//  17.08.2016  TM  Termin aus Kommission mit eingefügt / leer wenn ohne Kom.
//
//  Subprozeduren
//  SUB Parse701(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aLfdNr : int) : int;
//  SUB Parse701Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aLfdNr : int) : int
//  SUB Parse702(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; aStartAS : int; aZielAS : int; aKundenAdr : int) : int;
//  SUB Parse702Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic; aStartAS : int; aZielAS : int; aKundenAdr : int) : int
//  SUB Parse703(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse703Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//  SUB Parse704(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse704Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//  SUB Parse707(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic) : int;
//  SUB Parse707Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//  SUB Parse708(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aText : alpha(4096); aKombi : logic; ) : int;
//  SUB Parse708Multi(var aLabels : alpha; var aInhalt : alpha; var aZusatz : alpha; aObjName : alpha; aKombi : logic) : int
//
//========================================================================
@I:Def_Global
@I:Def_Form

//=======================================================================
//  Parse701  = Einsatz
//=======================================================================
sub Parse701(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  aLfdNr        : int;
  ) : int;
local begin
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
  vF      : float;
  vRAD    : float;
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
    'MATERIALNR' :      if (Mat.Nummer<>0) then     vAdd # aint(Mat.Nummer);
    'MATERIALNR2' :     if ("Mat~Nummer"<>0) then   vAdd # aint("Mat~Nummer");
    'AUSBA' :           if ( BAG.IO.VonBAG<>0) then vAdd # aint(BAG.IO.VonBAG)+'/'+aint(BAG.IO.VonPosition);
    'CHARGENNR' :       vAdd  # Mat.Chargennummer;
    'COILNR'  :         vAdd  # Mat.Coilnummer;
    'COILNR2' :         vAdd  # "Mat~Coilnummer";
    'WERKSNR' :         vAdd  # Mat.Werksnummer;
    'WERKSNR2' :        vAdd  # "Mat~Werksnummer";
    'RINGNR' :          vAdd  # Mat.Ringnummer;
    'WERKSTOFFNR' :     vAdd  # Mat.Werkstoffnr;
    'RID' :             if (Mat.RID<>0.0) then  vAdd # anum(Mat.RID, Set.Stellen.Radien);
    'RAD' :             if (Mat.RAD<>0.0) then  vAdd # anum(Mat.RAD, Set.Stellen.Radien);
    'KGMM' :            if (Mat.kgmm<>0.0) then vAdd # anum(Mat.KGMM, 4);
    'GÜTE' :            vAdd  # "BAG.IO.Güte";
    'BEMERKUNG' :       vAdd  # BAG.IO.Bemerkung;
    'LAGERPLATZ' :      vAdd  # Mat.Lagerplatz;
    'DICKE' :           if (BAG.IO.Dicke<>0.0) then   vAdd # anum(BAG.IO.Dicke, Set.Stellen.Dicke);
    'BREITE' :          if (BAG.IO.Breite<>0.0) then  vAdd # anum(BAG.IO.Breite, Set.Stellen.Breite);
    'LÄNGE' :           if ("BAG.IO.Länge"<>0.0) then vAdd # anum("BAG.IO.Länge", "Set.Stellen.Länge");
    'STÜCK' :           vAdd  # aint(BAG.IO.Plan.Out.Stk);
    'MENGE' :           vAdd  # anum(BAG.IO.Plan.Out.Meng, Set.Stellen.Gewicht);
    'GEWICHT.NETTO' :   vAdd  # anum(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht);
    'GEWICHT.BRUTTO' :  vAdd  # anum(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht);
    'LFDNR' :           vAdd  # aint(aLfdNr);
    'TEILUNGEN' :       vAdd  # aint(BAG.IO.Teilungen);

    // 'AUFLAUFHÖHE' :     begin
    //                       vF # Lib_Berechnungen:Auflaufh_aus_RIDRAD(Mat.RID, Mat.RAD);
    //                       if (vF<>0.0) then vAdd # anum(vF, 0);
    //                     end;


    'AUFLAUFHÖHE' :     begin

                          // vRAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRIDTlg(BAG.IO.Plan.In.Menge,BAG.IO.Plan.In.Stk,BAG.IO.Breite,7.85,Mat.RID,BAG.IO.Teilungen);

                          if (BAG.IO.Ist.In.Menge =0.0) then
                          vRAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRIDTlg(BAG.IO.Plan.In.Menge,BAG.IO.Plan.In.Stk,BAG.IO.Breite,Wgr_Data:GetDichte(Wgr.Nummer, 701),BAG.F.RID,BAG.IO.Teilungen);
                          else
                          vRAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRIDTlg(BAG.IO.Ist.In.Menge,BAG.IO.Ist.In.Stk,BAG.IO.Breite,Wgr_Data:GetDichte(Wgr.Nummer, 701),BAG.F.RID,BAG.IO.Teilungen);


                          vF # Lib_Berechnungen:Auflaufh_aus_RIDRAD(BAG.F.RID, vRAD);
                          if (vF<>0.0) then vAdd # anum(vF, 0);
                        end;







    'AF_OS_KURZ' :      vAdd  # BAG.IO.AusfOben;
    'AF_US_KURZ' :      vAdd  # BAG.IO.AusfUnten;

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
//  Parse701Multi
//=======================================================================
sub Parse701Multi(
  var aLabels : alpha;
  var aInhalt : alpha;
  var aZusatz : alpha;
  aObjName    : alpha;
  aKombi      : logic;
  aLfdNr      : int;
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
        vTmp # Parse701(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aLfdNr);
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
//  Parse702  ? Position
//=======================================================================
sub Parse702(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  aStartAS      : int;
  aZielAS       : int;
  aKundenAdr    : int) : int;
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

    'RESSOURCE' :       vAdd # Rso.Stichwort;
    'ARBEITSGANG' :     vAdd # ArG.Bezeichnung;
    'START.NAME'    :   if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Name;
    'START.ANREDE'  :   if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Anrede;
    'START.ZUSATZ'  :   if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Zusatz;
    'START.STRASSE' :   if (aStartAS<>0) then vAdd # aStartAS->"Adr.A.Straße";
    'START.ORT'  :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Ort
    'START.PLZ'  :      if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Plz;
    'START.ANNAHME1' :  if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme1;
    'START.ANNAHME2' :  if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme3;
    'START.ANNAHME3' :  if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme3;
    'START.ANNAHME4' :  if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme4;
    'START.ANNAHME5' :  if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Warenannahme5;
    'START.FERIEN'   :  if (aStartAS<>0) then vAdd # aStartAS->Adr.A.Betriebsferien;

    'ZIEL.NAME'    :    if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Name;
    'ZIEL.ANREDE'  :    if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Anrede;
    'ZIEL.ZUSATZ'  :    if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Zusatz;
    'ZIEL.STRASSE' :    if (aZielAS<>0) then vAdd # aZielAS->"Adr.A.Straße";
    'ZIEL.ORT'  :       if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Ort
    'ZIEL.PLZ'  :       if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Plz;
    'ZIEL.ANNAHME1' :   if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Warenannahme1;
    'ZIEL.ANNAHME2' :   if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Warenannahme3;
    'ZIEL.ANNAHME3' :   if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Warenannahme3;
    'ZIEL.ANNAHME4' :   if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Warenannahme4;
    'ZIEL.ANNAHME5' :   if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Warenannahme5;
    'ZIEL.FERIEN'   :   if (aZielAS<>0) then vAdd # aZielAS->Adr.A.Betriebsferien;
    'KUNDE.NR'      :   if (aKundenAdr<>0) then vAdd  # aint(aKundenAdr->Adr.Kundennr);
    'KUNDE.NAME'    :   if (aKundenAdr<>0) then vAdd  # aKundenAdr->Adr.Name;
    'KUNDE.ANREDE'  :   if (aKundenAdr<>0) then vAdd  # aKundenAdr->Adr.Anrede;
    'KUNDE.ZUSATZ'  :   if (aKundenAdr<>0) then vAdd  # aKundenAdr->Adr.Zusatz;
    'KUNDE.STRASSE'  :  if (aKundenAdr<>0) then vAdd  # aKundenAdr->"Adr.Straße";
    'KUNDE.ORT'  :      if (aKundenAdr<>0) then vAdd  # aKundenAdr->Adr.Ort
    'KUNDE.PLZ'  :      if (aKundenAdr<>0) then vAdd  # aKundenAdr->Adr.Plz;
    'ADR.NAME'    :     vAdd  # Adr.Name;
    'ADR.ANREDE'  :     vAdd  # Adr.Anrede;
    'ADR.ZUSATZ'  :     vAdd  # Adr.Zusatz;
    'ADR.STRASSE'  :    vAdd  # "Adr.Straße";
    'ADR.ORT'  :        vAdd  # Adr.Ort
    'ADR.PLZ'  :        vAdd  # Adr.Plz;
    'ADR.LAND' :        vAdd  # Lnd.Name.L1;
    'NUMMER' :          vAdd  # aint(BAG.P.Nummer);
    'POSITION' :        vAdd  # aint(BAG.P.Position);
    'ADR.EK.REFERENZNR' :   vAdd   # Adr.EK.Referenznr;
    'PREISPRO' :        if (BAG.P.Kosten.Pro<>0.0) then
                          vAdd # anum(BAG.P.Kosten.Pro, 2)+' '+"Wae.Kürzel"+' pro '+aint(BAG.P.Kosten.PEH)+' '+BAG.P.Kosten.MEH;
    'PREISFIX' :        if (BAG.P.Kosten.Fix<>0.0) then
                          vAdd # anum(BAG.P.Kosten.Fix,2)+' '+"Wae.Kürzel";
    'TERMIN.START' :    if (BAG.P.Plan.StartDat<>0.0.0) then  vAdd # cnvad(BAG.P.PLan.StartDat);
    'ZUSATZ.START' :    vAdd # BAG.P.Plan.StartInfo;
    'ZEIT.START'   :    if (BAG.P.Plan.StartZeit<>0:0) then   vAdd # cnvat(BAG.P.Plan.StartZeit);
    'TERMIN.ENDE' :     if (BAG.P.Plan.EndDat<>0.0.0) then    vAdd # cnvad(BAG.P.PLan.EndDat);
    'ZUSATZ.ENDE'  :    vAdd # BAG.P.Plan.EndInfo;
    'ZEIT.ENDE'    :    if (BAG.P.Plan.EndZeit<>0:0) then   vAdd # cnvat(BAG.P.Plan.endZeit);

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
//  Parse702Multi
//=======================================================================
sub Parse702Multi(
  var aLabels     : alpha;
  var aInhalt     : alpha;
  var aZusatz     : alpha;
  aObjName        : alpha;
  aKombi          : logic;
  aStartAS        : int;
  aZielAS         : int;
  aKundenAdr      : int;
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
        vTmp # Parse702(var aLabels, var aInhalt, var aZusatz, vToken, aKombi, aStartAS, aZielAS, aKundenAdr);
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
//  Parse703  = Fertigung
//=======================================================================
sub Parse703(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  ) : int;
local begin
  Erx     : int;
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
  v701    : int;
  v702    : int;
  v160    : int;
  vAusKg   : float; // Ausbringungssumme kg
  vAusStk  : int;   // Ausbringungssumme Stk

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

  Erx # RecLink(401,703,9,0);
  if (Erx > _rLocked) then begin
    Erx # RecLink(401,703,9,0);
    if (Erx <= _rLocked) then RecBufCopy(411,401)
    else RecBufClear(401);
  end;


  vFeld   # Str_Token(aText, '|', 1);
  vTitel  # Str_Token(aText, '|', 2);
  vPost   # Str_Token(aText, '|', 3);
  vPre    # Str_Token(aText, '|', 4);

  case (StrCnv(vFeld, _StrUpper)) of
    'NACHRESSOURCE' :   begin
                          Erx # RekLinkB(v701, 703, 4, _recFirst);      // OUTPUT lesen
                          if (Erx<=_rLocked) then begin
                            Erx # ReKLinkB(v702, v701, 4, _recFirst);   // naechsten AG lesen
                            if (Erx<=_rLocked) then begin
                              Erx # RekLinkB(v160,v702,11,_recFirst);   // Ressource holen
                              vAdd # v160->Rso.Stichwort;
                              RecBufDestroy(v160);
                            end;
                            RecBufDestroy(v702);
                          end;
                          RecBufDestroy(v701);
                        end;
    'FERTIGUNG_ODER_REST' : begin
                              if (BAG.F.Fertigung<999) then
                                vAdd # aint(BAG.F.Fertigung)
                              else
                                vAdd # 'Rest';
                            end;
    'STÜCK' :           vAdd # aint("BAG.F.Stückzahl");
    'ANZAHL' :          vAdd # aint(BAG.F.StreifenAnzahl);
    'DICKE' :           if (BAG.F.Dicke<>0.0) then
                          vAdd # anum(BAG.F.Dicke, Set.Stellen.Dicke);
    'BREITE' :          if (BAG.F.Breite<>0.0) then
                          vAdd # anum(BAG.F.Breite, Set.Stellen.Breite);
    'LÄNGE' :           if ("BAG.F.Länge"<>0.0) then
                          vAdd # anum("BAG.F.Länge", "Set.Stellen.Länge");
    'BREITEMULTI' :     vAdd # anum(cnvfi(BAG.F.Streifenanzahl) * BAG.F.Breite, Set.Stellen.Breite);
    'DICKENTOL' :       vAdd # BAG.F.DickenTol;
    'BREITENTOL' :      vAdd # BAG.F.BreitenTol;
    'LÄNGENTOL' :       vAdd # "BAG.F.LängenTol";
    'GEWICHT' :         vAdd # anum(BAG.F.Gewicht, Set.Stellen.Gewicht);
    'VPGNR' :           if (BAG.F.Verpackung<>0) then vAdd # aint(BAG.F.Verpackung);
    'KOMMISSION' :      vAdd # BAG.F.Kommission;
    'KOMTERMIN' :       if (Auf.P.Termin1W.Art)= 'DA' then vAdd # cnvad(Auf.P.Termin1Wunsch)
                        else vAdd # Auf.P.Termin1W.Art + ' ' + aint(Auf.P.Termin1W.Zahl) + '/' + aint(Auf.P.Termin1W.Jahr);
    'GÜTE' :            vAdd # "BAG.F.Güte";
    'RID' :             if (BAG.F.RID<>0.0) then    vAdd # anum(BAG.F.RID, Set.Stellen.Radien);
    'RADMAX' :          if (BAG.F.RADMax<>0.0) then vAdd # anum(BAG.F.RADMax, Set.Stellen.Radien);

    'RADMINMAX' :       begin
                            if (BAG.F.RAD=0.0) and (BAG.F.RADMax<>0.0)then begin
                              vAdd # anum(BAG.F.RADMax, Set.Stellen.Radien)
                            end
                            else if (BAG.F.RAD<>0.0) and (BAG.F.RADMax=0.0)then begin
                              vAdd # anum(BAG.F.RAD, Set.Stellen.Radien)
                            end
                            else if (BAG.F.RAD<>0.0) and (BAG.F.RADMax<>0.0)then begin
                              vAdd # anum(BAG.F.RAD, Set.Stellen.Radien) + ' - ' + anum(BAG.F.RADMax, Set.Stellen.Radien)
                            end;
                        end;

    'RINGGEWICHTMAX' :  if (BAG.VPG.RingKgBis<>0.0) then vAdd # anum(BAG.VPG.RingKgBis, 0);
    'BEMERKUNG' :       vAdd # BAG.F.Bemerkung;
    'KUNDENARTNR' :     vAdd # BAG.F.KundenArtNr;
    'WIRDEIGEN'   :     if (BAG.F.WirdEigenYN) then vAdd # vTitel;
    'VPGTEXT1' :        vAdd # BAG.VPG.VpgText1;
    'VPGTEXT2' :        vAdd # BAG.VPG.VpgText2;
    'VPGTEXT3' :        vAdd # BAG.VPG.VpgText3;
    'VPGTEXT4' :        vAdd # BAG.VPG.VpgText4;
    'VPGTEXT5' :        vAdd # BAG.VPG.VpgText5;
    'VPGTEXT6' :        vAdd # BAG.VPG.VpgText6;
    'AUSBRINGUNGKG' : begin
                        FOR   Erx # RecLink(707,703,10,_recFirst)
                        LOOP  Erx # RecLink(707,703,10,_recNext)
                        WHILE (Erx <= _rLocked) DO BEGIN


                          vAusKg # vAusKg + BAG.FM.Menge
                        END;
                        vAdd # anum(vAusKg,Set.Stellen.Gewicht);
                      end;

    'AUSBRINGUNGSTK' : begin
                        // FOR   Erx # RecLink(701,703,4,_recFirst)
                        // LOOP  Erx # RecLink(701,703,4,_recNext)
                        // WHILE (Erx <= _rLocked) DO BEGIN
                        //   vAusStk # vAusStk + BAG.IO.Ist.Out.Stk;
                        // END;
                        // vAdd # cnvaI(vAusStk);
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
//  Parse703Multi
//=======================================================================
sub Parse703Multi(
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
        vTmp # Parse703(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse704  = Verpackung
//=======================================================================
sub Parse704(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  ) : int;
local begin
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
  vA,vA2  : alphA(4096);
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
    'VERPACKUNG' :  vAdd # aint(BAG.Vpg.Verpackung);
    'VPG' :         begin
                      if (BAG.VPG.StehendYN) then ADD_VERP('stehend','');
                      if (BAG.VPG.LiegendYN) then ADD_VERP('liegend','');
                      //Abbindung
                      if (BAG.VPG.AbbindungQ <> 0 or BAG.VPG.AbbindungL <> 0) then begin
                        //Quer
                        if(BAG.VPG.AbbindungQ<>0)then vA2 # 'Abbindung '+ AInt(BAG.VPG.AbbindungQ)+' x quer' ;
                        //Längs
                        if(BAG.VPG.AbbindungL<>0)then begin
                          if (vA2<>'')then
                            vA2 # vA2+'  '+AInt(BAG.VPG.AbbindungL)+ ' x längs';
                          else
                            vA2 # 'Abbindung ' + AInt(BAG.VPG.AbbindungL)+' x längs';
                        end;
                       ADD_VERP(vA2,'')
                       vA2 # '';
                      end;
                      if (BAG.VPG.Zwischenlage <> '') then ADD_VERP(BAG.VPG.Zwischenlage,'');
                      if (BAG.VPG.Unterlage <> '') then ADD_VERP(BAG.VPG.Unterlage,'');
                      if (BAG.VPG.Umverpackung<>'') then ADD_VERP(BAG.VPG.Umverpackung,'');
                      if (BAG.VPG.Nettoabzug > 0.0) then ADD_VERP('Nettoabzug: '+AInt(CnvIF(BAG.VPG.Nettoabzug))+' kg','');
                      if ("BAG.VPG.Stapelhöhe" > 0.0) then ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("BAG.VPG.Stapelhöhe"))+' mm');
                      if (BAG.VPG.StapelhAbzug > 0.0) then ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("BAG.VPG.StapelhAbzug"))+' mm');
                      if (BAG.VPG.RingKgVon + BAG.VPG.RingKgBis  <> 0.0) then begin
                        vA2 # 'Ringgew.: '+AlphaMinMax(BAG.VPG.RingkgVon, BAG.VPG.RingKGBis, 0, '');
                        vA2 # vA2+' kg';
                        ADD_VERP(vA2,'')
                      end;
                      if (BAG.VPG.KgmmVon + BAG.VPG.KgmmBis  <> 0.0) then begin
                        vA2 # 'Kg/mm: '+AlphaMinMax(BAG.VPG.KgmmVon, BAG.VPG.KgmmBis, 2, '');
                        ADD_VERP(vA2,'')
                        vA2 # '';
                      end;
                      if ("BAG.VPG.StückProVE" > 0) then ADD_VERP(AInt("BAG.VPG.StückProVE") + ' Stück pro VE', '');
                      if (BAG.VPG.VEkgMax > 0.0) then ADD_VERP('max. '+anum(BAG.VPG.VEkgMax,2)+' kg pro VE: ', '');
                      if (BAG.VPG.RechtwinkMax > 0.0) then ADD_VERP('max. Rechtwinkligkeit: ', ANum(BAG.VPG.RechtwinkMax,-1));
                      if (BAG.VPG.EbenheitMax > 0.0) then ADD_VERP('max. Ebenheit: ', ANum(BAG.VPG.EbenheitMax,-1));
                      if ("BAG.VPG.SäbeligMax" > 0.0) then ADD_VERP('max. Säbeligkeit: ', ANum("BAG.VPG.SäbeligMax",-1)+' pro '+anum("BAG.VPG.SäbelProM",2)+' m');
                      if (BAG.VPG.Wicklung<>'') then ADD_VERP('Wicklung: ', BAG.VPG.Wicklung);
                      vAdd # vA;
                    end;
    'TEXT1' :       vAdd # BAG.VPG.VpgText1;
    'TEXT2' :       vAdd # BAG.VPG.VpgText2;
    'TEXT3' :       vAdd # BAG.VPG.VpgText3;
    'TEXT4' :       vAdd # BAG.VPG.VpgText4;
    'TEXT5' :       vAdd # BAG.VPG.VpgText5;
    'TEXT6' :       vAdd # BAG.VPG.VpgText6;

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
//  Parse704Multi = Verpackung
//=======================================================================
sub Parse704Multi(
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
        vTmp # Parse704(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse707  = Fertigmeldung
//=======================================================================
sub Parse707(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  ) : int;
local begin
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
  vA,vA2  : alphA(4096);
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
    'FM' :              vAdd # aint(BAG.FM.Fertigmeldung);
    'FERTIGUNG' :       vAdd # aint(BAG.FM.Fertigung);
    'MATERIALNR' :      if (BAG.FM.Materialnr<>0) then      vAdd # aint(BAG.FM.Materialnr);
    'STÜCK' :           if ("BAG.FM.Stück"<>0) then         vAdd # aint("BAG.FM.Stück");
    'MENGE+MEH' :       if (BAG.FM.Menge<>0.0) then begin
                          if (BAG.FM.MEH='kg') then
                            vAdd # anum(BAG.FM.Menge, Set.Stellen.Gewicht)
                          else if (BAG.FM.MEH='Stk') then
                            vAdd # anum(BAG.FM.Menge, 0)
                          else
                            vAdd # anum(BAG.FM.Menge, Set.Stellen.Menge);
                          vAdd # vAdd + ' '+BAG.FM.MEH;
                        end;
    'GEWICHT.NETTO' :   if (BAG.FM.Gewicht.Netto<>0.0) then vAdd # anum(BAG.FM.Gewicht.Netto, Set.Stellen.Gewicht);
    'GEWICHT.BRUTTO' :  if (BAG.FM.Gewicht.Brutt<>0.0) then vAdd # anum(BAG.FM.Gewicht.Brutt, Set.Stellen.Gewicht);
    'DICKE' :           if (BAG.FM.Dicke<>0.0) then         vAdd # anum(BAG.FM.Dicke, Set.Stellen.Dicke);
    'BREITE' :          if (BAG.FM.Breite<>0.0) then        vAdd # anum(BAG.FM.Breite, Set.Stellen.Breite);
    'LÄNGE' :           if ("BAG.FM.Länge"<>0.0) then       vAdd # anum("BAG.FM.Länge", "Set.Stellen.Länge");
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
//  Parse707Multi = Fertigmeldung
//=======================================================================
sub Parse707Multi(
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
        vTmp # Parse707(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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
//  Parse708  = Beistellungen
//=======================================================================
sub Parse708(
  var aLabels   : alpha;
  var aInhalt   : alpha;
  var aZusatz   : alpha;
  aText         : alpha(4096);
  aKombi        : logic;
  ) : int;
local begin
  vZeilen : int;
  vFeld   : alpha(4096);
  vTitel  : alpha(4096);
  vPre    : alpha(4096);
  vPost   : alpha(4096);
  vAdd    : alpha(4096);
  vA,vA2  : alphA(4096);
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
    'FM' :              vAdd # aint(BAG.FM.B.Fertigmeld);
    'FERTIGUNG' :       vAdd # aint(BAG.FM.B.Fertigung);
    'ARTIKELNR' :       vAdd # BAG.FM.B.Artikelnr;
    'ART.STICHWORT' :   vAdd # Art.Stichwort;
    'ART.BEZ1' :        vAdd # Art.Bezeichnung1;
    'ART.BEZ2' :        vAdd # Art.Bezeichnung2;
    'ART.BEZ3' :        vAdd # Art.Bezeichnung3;
    'MENGE+MEH' :       if (BAG.FM.B.Menge<>0.0) then begin
                          if (BAG.FM.B.MEH='kg') then
                            vAdd # anum(BAG.FM.B.Menge, Set.Stellen.Gewicht)
                          else if (BAG.FM.B.MEH='Stk') then
                            vAdd # anum(BAG.FM.B.Menge, 0)
                          else
                            vAdd # anum(BAG.FM.B.Menge, Set.Stellen.Menge);
                          vAdd # vAdd + ' '+BAG.FM.B.MEH;
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
//  Parse708Multi = Beistellungen
//=======================================================================
sub Parse708Multi(
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
        vTmp # Parse708(var aLabels, var aInhalt, var aZusatz, vToken, aKombi);
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