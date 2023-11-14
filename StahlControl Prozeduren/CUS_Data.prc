@A+
//==== Business-Control ==================================================
//
//  Prozedur    CUS_Data
//                    OHNE E_R_G
//  Info
//
//
//  02.02.2011  MS  Erstellung der Prozedur
//  04.02.2011  ST  "Replace" hinzugefügt
//  06.02.2013  AI  NEU: "Copy"
//  15.11.2017  ST  "Foreach" hinzugefügt
//  17.06.2019  AH  "Read" mit aLast
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//  SUB Insert(aDatei : int; aRecID : int; aFeldNr : int; aInhalt : alpha; opt aInsertIfEmpty : logic;) : logic;
//  SUB alt_Read(aDatei : int; aRecID : int; alfdNr : int; aFeldNr : int;) : int;
//  SUB Read(aDatei : int; aRecID : int; aFeldNr : int;opt aLfdNr, opt aLast : logic) : int;
//  SUB Replace(aDatei : int;  aRecID : int;  aInhalt : alpha; opt aLfnNr: int;) : logic;
//  SUB MoveAll(aStartDatei : int; aZielDatei : int) : logic;
//  SUB FindTheOne(aDatei  : int; aFeld   : int; aInhalt : alpha) : int;
//  SUB Foreach(aDatei : int; aFeld : int; aFunc : alpha;opt aPara : alpha) : int;
//
//========================================================================
@I:Def_Global

//========================================================================
//  Insert
//    Speichert ein Customfeld zu einem Datensatz
//========================================================================
sub Insert(
  aDatei             : int;
  aRecID             : int;
  aFeldNr            : int;
  aInhalt            : alpha(250);
  opt aInsertIfEmpty : logic;
) : logic;
local begin
  vErg : int;
end;
begin

  if(aInsertIfEmpty = false) and (aInhalt = '') then // Customfld. anlegen obwohl Inhalt leer ist
    RETURN false;

  CUS.Datei      # aDatei;
  CUS.RecID      # aRecID;
  CUS.lfdNr      # 1;
  CUS.FeldNummer # aFeldNr;
  CUS.Inhalt     # StrCut(aInhalt,1,128);

  REPEAT
    vErg # RekInsert(931, 0, 'AUTO');
    CUS.lfdNr # CUS.lfdNr + 1;
  UNTIL (vErg = _rOK);

  RETURN true;
end;

//========================================================================
//  Replace
//    Ändert den Wert von einem Customfeld zu einem Datensatz
//========================================================================
sub Replace(
  aDatei             : int;
  aRecID             : int;
  aInhalt            : alpha(128);
  opt aLfnNr         : int;
) : logic;
local begin
  vRet : logic;
  vErg : int;
end;
begin
  vRet # false;
  if (aLfnNr = 0) then
    aLfnNr # 1;

  CUS.Datei      # aDatei;
  CUS.RecID      # aRecID;
  CUS.lfdNr      # aLfnNr;
  if (RecRead(931,1,_RecLock) = _rOK) then begin
    //CUS.FeldNummer # aFeldNr;
    CUS.Inhalt     # aInhalt;
    vErg # RekReplace(931,_RecUnlock,'AUTO');
    if (vErg = _rOK) then
      vRet # true;
  end;

  return vRet;

end;

//========================================================================
//  alt_Read
//    Liest das erste passende Customfeld
//========================================================================
sub alt_Read(
  aDatei             : int;
  aRecID             : int;
  alfdNr             : int;
  aFeldNr            : int;
) : int;
local begin
  vErg : int;
end;
begin

  CUS.Datei      # aDatei;
  CUS.RecID      # aRecID;
  CUS.lfdNr      # alfdNr;

  vErg # RecRead(931, 1, 0);
  WHILE(vErg <= _rNoKey) DO BEGIN
    if((CUS.Datei <> aDatei) or (CUS.RecID <> aRecID)) then begin
      vErg # _rNoRec;
      BREAK;
    end;

    if((CUS.FeldNummer = aFeldNr)) then begin
      vErg # _rOK;
      BREAK;
    end;

    vErg # RecRead(931, 1, _recNext);
  END;

  if(vErg <> _rOK) then
    RecBufClear(931);

  RETURN vErg;
end;


//========================================================================
//  Read
//    Liest das erste passende Customfeld
//========================================================================
sub Read(
  aDatei            : int;
  aRecID            : int;
  aFeldNr           : int;
  opt alfdNr        : int;
  opt aLast         : logic;
) : int;
local begin
  vCount  : int;
  vErg    : int;
  vFilter : int;
end;
begin

  CUS.Datei      # aDatei;
  CUS.RecID      # aRecID;
  CUS.FeldNummer # aFeldNr

  if (aLast) then begin
    vFilter # RecFilterCreate(931,3);
    vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aDatei);
    vFilter->RecFilterAdd(2,_FltAnd, _FltEq, aRecID);
    vFilter->RecFilterAdd(3,_FltAnd, _FltEq, aFeldNr);
    vErg # RecRead(931, 3, _recLast, vFilter); // LETZTES Feld lesen
    RecFilterDestroy(vFilter);
    if (vErg<=_rMultikey) and
      (Cus.Datei=aDatei) and (Cus.RecId=aRecID) and (CUS.FeldNummer = aFeldNr) then begin
      vErg # _rOK;
    end
    else begin
      vErg # _rNoRec;
    end;
    if (vErg <> _rOK) then
      RecBufClear(931);
    RETURN vErg;
  end;

  vCount # 1;
  FOR vErg # RecRead(931, 3, 0); // 1. Feld lesen
  LOOP vErg # RecRead(931, 3, _recNext); // ggf. naechste Felder lesen
  WHILE(vErg <= _rMultiKey) DO BEGIN
    if( (CUS.Datei <> aDatei) or (CUS.RecID <> aRecID) or ((vCount > alfdNr) and (alfdNr > 0)) ) then begin
      vErg # _rNoRec;
      BREAK;
    end;

    if( (CUS.FeldNummer = aFeldNr) and ((alfdNr = 0) or (alfdNr = vCount)) ) then begin
      vErg # _rOK;
      BREAK;
    end;

    vCount # vCount + 1;
  END;

  if(vErg <> _rOK) then
    RecBufClear(931);

  RETURN vErg;
end;


//========================================================================
//  MoveAll
//
//========================================================================
SUB MoveAll(
  aStartDatei : int;
  aZielDatei  : int) : logic;
local begin
  Erx   : int;
  vID1  : int;
  vID2  : int;
  vErg  : int;
end;
begin

  vErg # Erg;

  vID1 # RecInfo(aStartDatei, _recID);
  vID2 # RecInfo(aZielDatei, _recID);

  TRANSON;

  RecBufClear(931);
  CUS.Datei # aStartDatei;
  CUS.RecID # vID1;
  Erx # RecRead(931, 1, 0);
  WHILE (Erx<=_rNoKey) and
        (CUS.Datei=aStartDatei) and
        (CUS.RecID=vID1) do begin
    RecRead(931,1,_recLock);
    CUS.Datei # aZielDatei;
    CUS.RecID # vID2;
    Erx # RekReplace(931,_Recunlock, 'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Erg # vErg;
      RETURN false;
    end;

    RecBufClear(931);
    CUS.Datei # aStartDatei;
    CUS.RecID # vID1;
    Erx # RecRead(931, 1, 0);
  END;

  TRANSOFF;

  Erg # vErg; // TODOERX
  RETURN true;
end;


/*
//========================================================================
//  CopyTo
//    Kopiert ein Customfeld welches sich um Puffer befindet
//    zu einem anderen Datensatz
//========================================================================
sub CopyTo(
  aDatei             : int;
  aRecID             : int;
  aFeldNr            : int;
) : int;
begin

  vErg # RecRead(931, 1, 0);
  WHILE(vErg <= _rMultiKey) DO BEGIN
    if((CUS.Datei <> aDatei) or (CUS.RecID <> aRecID)) then begin
      vErg # _rNoRec;
      BREAK;
    end;

    if((CUS.FeldNummer = aFeldNr)) then begin
      vErg # _rOK;
      BREAK;
    end;

    vErg # RecRead(931, 1, _recNext);
  END;

  if(vErg <> _rOK) then
    RecBufClear(931);

  RETURN vErg;
end;
*/

//========================================================================
//  FindTheOne
//        Lies den einen bzw. ersten passenden Custom-Satz
//========================================================================
Sub FindTheOne(
  aDatei  : int;
  aFeld   : int;
  aInhalt : alpha;
) : int;
local begin
  Erx       : int;
  vSel      : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
  vI        : int;
end;
begin
  // Selektion aufbauen...
  vQ # '';
  Lib_Sel:QInt(var vQ, 'CUS.Datei'  , '=', aDatei);
  Lib_Sel:QInt(var vQ, 'CUS.FeldNummer', '=', aFeld);
  Lib_Sel:QAlpha(var vQ, 'CUS.Inhalt', '=', aInhalt);
  vSel # SelCreate(931, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  // speichern, starten und Name merken...
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vI # RecInfo(931,_RecCount, vSel);
  if (vI=0) then begin
    SelClose(vSel);
    SelDelete(200, vSelName);
    RETURN _rNoRec;
  end;

  RecRead(931,vSel, _recFirst);
  SelClose(vSel);
  SelDelete(200, vSelName);

  if (vI=1) then RETURN _rOK;

  RETURN _rMultikey;

end;


//========================================================================
//  Foreach                         ST 2017-11-15
//    Iteriert über alle Customfelder mit der selben Feldnummer
//========================================================================
sub Foreach(aDatei : int; aFeld : int; aFunc : alpha;opt aPara : alpha) : int;
local begin
  Erx       : int;
  vSel      : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
  vErr      : int;
end;
begin

  // Selektion aufbauen...
  vQ # '';
  Lib_Sel:QInt(var vQ, 'CUS.Datei'  , '=', aDatei);
  Lib_Sel:QInt(var vQ, 'CUS.RecID'  , '=', RecInfo(aDatei,_RecId));
  Lib_Sel:QInt(var vQ, 'CUS.FeldNummer', '=', aFeld);

  vSel # SelCreate(931, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  // speichern, starten und Name merken...
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR   Erx # RecRead(931, vSel, _recFirst);
  LOOP  Erx # RecRead(931, vSel, _recNext);
  WHILE (Erx <= _rLocked) AND (vErr = 0) DO BEGIN
    vErr # Call(aFunc,aPara);
  END;

  SelClose(vSel);
  SelDelete(931, vSelName);

  RETURN vErr;
end;


//========================================================================