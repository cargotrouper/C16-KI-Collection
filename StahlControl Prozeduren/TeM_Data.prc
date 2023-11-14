@A+
//===== Business-Control =================================================
//
//  Prozedur  TeM_Data
//              OHNE E_R_G
//  Info
//
//
//  14.01.2014  AH  Erstellung der Prozedur
//  21.10.2015  AH  Neue "Delete"
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//  SUB CalcDauer();
//  SUB Delete() : logic;
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
// CalcDauer();
//
//========================================================================
sub CalcDauer();
local begin
  vTmp  : int;
end;
begin
  TeM.Dauer # 0.0;
  if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
    vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp);
    vTmp # (CnvID(TeM.Ende.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Ende.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp) - TeM.Dauer;
  end;
end;


//========================================================================
//  Delete
//========================================================================
sub Delete() : logic;
begin
  Lib_Sync_Outlook:StartSyncJob(981,n,y);

  TRANSON;

  // Zugehörige Anker
  WHILE (RecLink(981,980,1,_RecFirst) < _rNoRec ) DO BEGIN
    if (Tem_A_Data:Delete(0,'MAN')<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
  END;
  if (RekDelete(980,0,'MAN')<>_rok) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//========================================================================
sub Check(aDatei : int) : int
local begin
  Erx     : int;
  vFilter : int;
  vCode   : alpha;
  vKey    : alpha;
  vID1    : int;
  vID2    : int;
  vID3    : word;
end;
begin

  if (aDatei=0) then RETURN _rNoRec;

//    vQ # '(TeM.A.Datei = '+cnvai(aDatei)+') AND ((TeM.A.Code = '''+vCode+''') OR (TeM.A.Key = '''+vKey+'''))';
  if (TeM_Subs:GetIDs(aDatei, var vID1, var vID2, var vID3, var vCode, var vKey)=false) then RETURN -100;

  vFilter # RecFilterCreate(981,4);
  vFilter->RecFilterAdd(1,_fltAnd,_FltEq, aDatei);
  vFilter->RecFilterAdd(2,_Fltand,_FltEq, StrCut(vKey,1,48));
  // TODO check über Code??
  Erx # RecRead(981,4,_recFirst|_RecTest, vFilter);
  vFilter->RecFilterDestroy();

  RETURN Erx;
end;


//========================================================================