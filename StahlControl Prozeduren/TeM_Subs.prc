@A+
//===== Business-Control =================================================
//
//  Prozedur  TeM_Subs
//                  OHNE E_R_G
//  Info
//
//
//  26.02.2009  AI  Erstellung der Prozedur
//  27.08.2009  MS  Um neue Datein erweitert, alte geprüft
//  30.10.2013  ST  Sub Start(..): Dateinummer als Selektionspostfix angehängt,
//                  damit 2 Selektionen einer Datei möglich sind
//  04.11.2013  ST  ShowTem(...) hinzugefügt Projekt  1326/333
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//      sub Start(aDatei : int);
//      sub ShowTeM(aUser : alpha; opt aDatumVon : date; opt aDatumBis : date; opt aTypen : alpha; opt aTypenIgnore : alpha);
//
//
//========================================================================
@I:Def_Global

//========================================================================
sub GetIDs(
  aDatei      : int;
  var aID1    : int;
  var aID2    : int;
  var aID3    : word;
  var aCode   : alpha;
  var aKey    : alpha;
//  var aOrNull : logic;
  ) : logic
local begin
end;
begin

  aID2 # -1;

  case (aDatei) of
    100 : begin
      aID1    # Adr.Nummer;
//      vCode   # 'ADR';
      RETURN true;
    end;


    102 : begin
      aID1    # Adr.P.Adressnr;
      aID2    # Adr.P.Nummer;
//      vCode   # 'ANP';
      RETURN true;
    end;


    120 : begin
      aID1    # TeM.A.ID1;
//      vCode   # 'PRJ';
      RETURN true;
    end;


    122 : begin
      aID1    # Prj.P.Nummer;
      aID2    # Prj.P.Position;
      aID3    # Prj.P.SubPosition;
//      aCode   # 'PRJ_P';
      RETURN true;
    end;


    401 : begin
      aID1    # Auf.P.Nummer;
      aID2    # Auf.P.Position;
//      vCode   # 'AUF';
      aCode # 'AUF' + StrFmt(CnvAi(aID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin)
      aCode # aCode + '/' + StrFmt(CnvAi(aID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin);
      aKey # CnvAI(aID1)+StrChar(255,1)+CnvAI(aID2)+StrChar(255,1);
//      aOrNull # y;
/*
      vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND'
      vQ # vQ + ' ((TeM.A.Code = '''+
                        vCode+StrFmt(CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin) +
                       '/' + StrFmt(CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin)+''') OR';
      vQ # vQ + ' (TeM.A.Code = '''+
                        vCode+StrFmt(CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin) +'/  0'') )';
*/
      RETURN true;
    end;


    500 : begin
      aID1    # Ein.P.Nummer
      aID2    # 0;
//      vCode   # 'EIN';
//      aOrNull # y;
      RETURN true;
    end;

    
    501 : begin
      aID1    # Ein.P.Nummer
      aID2    # Ein.P.Position;
//      vCode   # 'EIN';
//      aOrNull # y;
      RETURN true;
    end;


    540 : begin
      aID1    # Bdf.Nummer
      aID2    # 0;
//      vCode   # 'EIN';
//      aOrNull # y;
      RETURN true;
    end;


    800 : begin
      aCode # Usr.Username;
      RETURN true;
    end;


    200 : begin
//      vCode # 'MAT';
      aID1  # Mat.Nummer;
      RETURN true;
    end;


    702 : begin
//      vCode # 'BAG_P';
      aID1  # BAG.P.Nummer;
      aID2  # BAG.P.Position;
      RETURN true;
    end;
    
    916 : begin
//      vID1    # Anh
//      vID2    # E0
//      vOrNull # y;
      aCode # cnvab(Anh.ID);
      RETURN true;
    end;

  end;

  RETURN false;
end;


//========================================================================
//  Start
//
//========================================================================
sub Start(aDatei : int);
local begin
  Erx     : int;
  vCode   : alpha;
  vKey    : alpha;
  vID1    : int;
  vID2    : int;
  vID3    : word;
  vQ      : alpha(1000);
  vHdl    : int;
//  vOrNull : logic;
end;
begin

  if (GetIDs(aDatei, var vID1, var vID2, var vID3, var vCode, var vKey)=false) then RETURN;

  RecBufClear(981);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'TeM.Verwaltung','',y);
  VarInstance(WindowBonus,cnvIA(gMdi->wpcustom));

  if (vQ='') then begin
//    vCode2 # vCode;
//    if (vID1<>0) OR (vID2<>0) then
//      vCode2       # vCode + StrFmt(CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin) +
//                       '/' + StrFmt(CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin);
//      vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND (TeM.A.Code = '''+vCode2+''')'

    if (vCode='') then begin
      vCode # cnvai(vID1) + StrChar(255,1);
      if (vID2<>-1) then vCode # vCode +  cnvai(vID2) + StrChar(255,1);
    end;
    if (vKey='') then vKey # vCode;
//    vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND (TeM.A.Key = '''+vCode+''')'
//    vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND (TeM.A.Code = '''+vCode+''')'
//    vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND ((TeM.A.Code = '''+vCode+''') OR (TeM.A.Key = '''+vKey+'''))';
    vQ # 'TeM.A.Datei = '+cnvai(aDatei)+' AND (TeM.A.Key = '''+vKey+''' OR TeM.A.Code = '''+vCode+''')';
//vQ # '(TeM.A.Datei = '+cnvai(aDatei)+')';
  end;

//debug(vQ);

  // Selektion aufbauen...
  vHdl # SelCreate(980, gKey, 981);
  vHdl->SelAddLink('', 980, 981, 1, 'Kopf',_SelResultSet);
  Erx # vHdl->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vHdl);

  // speichern, starten und Name merken...
  // ST 2013-10-30: Dateinummer als Postfix angehängt, damit 2 Selektionen einer Datei möglich sind
  //w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
  w_SelName # Lib_Sel:SaveRun(var vHdl,0,n, Aint(aDatei));

  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;

  vHdl # Winsearch(gMDI,'ZL.TeM.Termine');
  vHDL->wpcustom # cnvai(aDatei,_FmtNumNoGroup,0,3)+CnvAi(vID1,_FmtNumNoGroup | _FmtNumLeadZero,0,8) + CnvAi(vID2,_FmtNumNoGroup | _FmtNumLeadZero,0,3) + vCode;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  sub ShowTeM(aUser : alpha; opt aDatumVon : date; opt aDatumBis : date; opt aTypen : alpha);
//
//========================================================================
sub ShowTeM(
  aUser             : alpha;
  opt aDatumVon     : date;
  opt aDatumBis     : date;
  opt aTypen        : alpha;
  opt aTypenIgnore  : alpha);
local begin
  Erx     : int;
  vCode   : alpha;
  vQ      : alpha(1000);
  vQ2     : alpha(1000);
  vHdl    : int;
  i       : int;
  vCnt    : int;
  vTmp    : alpha;

  vMdivorher : int;
end;
begin
  if (aDatumVon = 0.0.0) then
    aDatumVon # today;

  if (aDatumBis = 0.0.0) then
    aDatumBis # today;

  vCode # aUser;

  // Alle Anker für User und Termine im Datumsbereich selektieren
  gMDI # Lib_GuiCom:AddChildWindow(gFrmMain, 'TeM.Verwaltung','',y);
  VarInstance(WindowBonus,cnvIA(gMdi->wpcustom));

  vQ # '';
  Lib_Sel:QVonBisD ( var vQ, 'TeM.Start.Von.Datum', aDatumVon, aDatumBis);

  // für jeden Typen ein Selektionskriterium erstellen
  if (aTypen <> '') then begin
    aTypen # aTypen + ';';
    aTypen # Lib_Strings:Strings_ReplaceEachToken(aTypen,' ,;|',';');
    vCnt # Lib_Strings:Strings_Count(aTypen,';');

    vQ # vQ + ' AND ('
    FOR   i # 1
    LOOP  inc(i)
    WHILE i<=vCnt DO BEGIN
      vTmp # Str_Token(aTypen,';',i);
      if (i > 1) then
        vQ # vQ + ' OR ';

      Lib_Sel:QAlpha (var vQ , 'TeM.Typ', '=', StrCnv(vTmp,_StrUpper), ' ');
    END;
    vQ # vQ + ')';
  end;

  // Ausschlusstypen selektieren
  if (aTypenIgnore <> '') then begin
    aTypenIgnore # aTypenIgnore + ';';
    aTypenIgnore # Lib_Strings:Strings_ReplaceEachToken(aTypenIgnore,' ,;|',';');
    vCnt # Lib_Strings:Strings_Count(aTypenIgnore,';');

    vQ # vQ + ' AND ('
    FOR   i # 1
    LOOP  inc(i)
    WHILE i<=vCnt DO BEGIN
      vTmp # Str_Token(aTypenIgnore,';',i);

      if (i > 1) then
        vQ # vQ + ' AND ';

      Lib_Sel:QAlpha (var vQ , 'TeM.Typ', '<>', StrCnv(vTmp,_StrUpper), ' ');
    END;
    vQ # vQ + ')';
  end;

  // Anker für User selektieren
  vQ  # vQ + 'AND LinkCount(Anker) > 0';
  vQ2 # '';
  Lib_Sel:QEnthaeltA( var vQ2, 'TeM.A.Code', vCode );

  vHdl # SelCreate(980, 0);   // gKEy
  vHdl->SelAddLink('', 981, 980, 1, 'Anker',_SelResultSet);
  Erx # vHdl->SelDefQuery('', vQ);

  if (Erx != 0) then Lib_Sel:QError(vHdl);
  Erx # vHdl->SelDefQuery('Anker', vQ2);
  if (Erx != 0) then Lib_Sel:QError(vHdl);
  // speichern, starten und Name merken...

  w_SelName # Lib_Sel:SaveRun(var vHdl,3,n);    // Nach Starttermin selektieren

  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;

  vHdl # Winsearch(gMDI,'ZL.TeM.Termine');
  vHDL->wpcustom # vCode;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//========================================================================
sub ExistsTeM(aDatei : int) : logic
local begin
  vCode   : alpha;
  vKey    : alpha;
  vID1    : int;
  vID2    : int;
  vID3    : word;
  v981    : int;
  vErg    : int;
end;
begin
  if (aDatei<=0) or (aDatei>999) then RETURN false;
  
  if (GetIDs(aDatei, var vID1, var vID2, var vID3, var vCode, var vKey)=false) then RETURN false;
  if (vKey='') then vKey # vCode;
  
  v981 # RecBufCreate(981);
  v981->Tem.A.Datei # aDatei;
  v981->Tem.A.Key   # vKey;
//debug('suche:'+aint(aDatei)+'/'+vKey);
//    if (vCode='') then begin
//      vCode # cnvai(vID1) + StrChar(255,1);
//      if (vID2<>-1) then vCode # vCode +  cnvai(vID2) + StrChar(255,1);
//    end;
//    vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND ((TeM.A.Code = '''+vCode+''') OR (TeM.A.Key = '''+vKey+'''))';
  vErg # RecRead(v981, 4, 0);
  RecBufDestroy(v981);
//debug('->'+aint(vErg)+' KEY401');
  RETURN (vErg<=_rMultikey);
end;
// 401/100.821 1 

//========================================================================
//  sub TEST_ShowTeM()
//  call TeM_Subs:TEST_ShowTeM()
//========================================================================
sub TEST_ShowTeM()
begin

  //    User       von       bis      alle  ohne
/*
  ShowTeM('ST',01.01.2013, 31.12.2013, '', 'SMS');
  ShowTeM('ST',01.01.2013, 31.12.2013, '', 'TEL;SMS');
  ShowTeM('ST',01.01.2013, 31.12.2013, 'TEL;SMS');
*/
  ShowTeM('ST',01.01.2013, 31.12.2013);

end;

//========================================================================