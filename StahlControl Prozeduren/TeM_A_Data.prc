@A+
//===== Business-Control =================================================
//
//  Prozedur    TeM_A_Data
//                  OHNE E_R_G
//  Info
//
//
//  20.08.2009  AI  Erstellung der Prozedur
//  12.11.2014  AH  WoF ohne "WOF" im Event
//  18.04.2019  AH  WoF per Email
//  27.07.2021  AH  ERX
//  2023-08-22  AH  Fix für Anker in Daten in Ablage
//
//  Subprozeduren
//    SUB Insert(aLock : int; aGrund : alpha) : int;
//    SUB Code2Text(var aTyp : alpha; var aName : alpha)
//    SUB RepairBefore070214();
//
//========================================================================
@I:Def_Global

define begin
end;


//========================================================================
//========================================================================
sub Update(opt aMustNotify : logic)
begin
  if (TeM.A.Datei=800) and (TEM.A.Nummer<>0) and (TeM.A.Nummer<>MyTmpnummer) then begin
    // 12.11.2014 AH
    if (Lib_Termine:GetBasisTyp(TeM.Typ)<>'WOF') then begin
      if (aMustNotify) then begin
        Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Typ+' '+TeM.Bezeichnung, TeM.A.Nummer ,today, now, 0);
      end;
    end
    else begin
      // 26.05.2020 AH: nur wenn Frist und Dauer eingetragen sind:
      if (Tem.Ende.Bis.Datum<>0.0.0) and (Tem.Ende.Bis.Datum<>Tem.Start.Von.Datum) then
        Lib_Notifier:NewEvent(TeM.A.Code, '980', strCut(TeM.Bezeichnung,1,55) + ' '+Lib_Berechnungen:KurzDatum_Aus_Datum(Tem.Ende.Bis.Datum), TeM.A.Nummer ,today, now, 0);
      else
        Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Bezeichnung, TeM.A.Nummer ,today, now, 0);
    end;
  end;
end;


//========================================================================
//========================================================================
Sub Anker(
  aDatei      : int;
  aGrund      : alpha;
  opt aNoNoti : logic;
  opt aRecID  : int;
) : int
local begin
  Erx       : int;
  vFilter   : int;
  vI        : int;
  vBuf      : int;
  vErg      : int;
  v981      : int;
end;
begin
  if (aDatei=981) then v981 # RekSave(981);

  vFilter # RecFilterCreate(981,1);
  vFilter->RecFilterAdd(1,_FltAND,_FltEq, TeM.Nummer);
  vFilter->RecFilterAdd(2,_FltAND,_FltEq, 0);
  Erx # RecRead(981,1,_recLast, vFilter);
  if (ERx>_rLocked) then vI # 1
  else vI # TeM.A.lfdNr + 1;
  RecFilterDestroy(vFilter);

  RecBufClear(981);
  if (v981<>0) then begin
    RekRestore(v981);
  end
  else begin
    if (aDatei=800) then TeM.A.Code    # Usr.Username;
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.lfdNr   # vI;
    TeM.A.Datei   # aDatei;
  end;
  REPEAT
    if (Tem.A.Datei>0) and (Tem.A.Datei<=999) then begin
      if (aRecID<>0) then begin
        vBuf # RecBufCreate(Tem.A.Datei);
        RecRead(vBuf, 0, _recId, aRecID);
        TeM.A.Key # Lib_Rec:MakeKey(vBuf, n);
        RecBufDestroy(vBuf);
      end
      else begin
        TeM.A.Key  # Lib_Rec:MakeKey(Tem.A.Datei, n);
      end;
    end;

    // 02.06.2020 AH:
    TeM.A.Start.Datum # TeM.Start.Von.Datum;
    TeM.A.Start.Zeit  # TeM.Start.Von.Zeit;
    TeM.A.EventErzeugtYN # (aNoNoti=false); // 01.07.2020
    vErg # RekInsert(981, _recunlock, aGrund);
    if (vErg=_rOK) and (aNoNoti=false) then begin
      Update();
    end;
    if (vErg<>_rOK) then begin
      inc(TeM.A.lfdNr);
      if (Tem.A.LfdNr=32000) then begin
// 27.07.2021 ???        vErg # Erx;
        RETURN vErg;
      end;
    end;
  UNTIl (vErg=_rOK);

  if (Tem.Nummer<>0) and (TeM.Nummer<>myTmpNummer) then
    Lib_Sync_Outlook:StartSyncJob(981,y,n);

// 27.07.2021  Erx # vErg;
  RETURN vErg;
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aLock   : int;
  aGrund  : alpha) : int;
local begin
  Erx     : int;
end;
begin
  Erx # RekDelete(981,aLock,aGrund);

//    Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Typ+' '+TeM.Bezeichnung, TeM.Nummer ,today, now, 0);
  if (TeM.A.Datei=800) then begin
    if (Lib_Notifier:Exists('980', TeM.A.Nummer, TeM.A.Code)) then begin
      Lib_Notifier:RemoveOneEvent('980', TeM.A.Nummer, TeM.A.Code);
    end;
  end;

  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


//========================================================================
//  RemoveAll
//
//========================================================================
Sub RemoveAll(aDatei : int) : logic;
local begin
  Erx   : int;
  vKey  : alpha;
end;
begin

  vKey # Lib_Rec:MakeKey(aDatei, n);
  Tem.A.Datei # aDatei;
  Tem.A.Key   # vKey;
  Erx # RecRead(981,4,0);
  WHILE (erx<=_rMultikey) and (Tem.A.Datei=aDatei) and (Tem.A.Key=vKey) do begin
    Erx # Delete(_rNoLock,'');
    if (erx<>_rOK) then RETURN false;
    Erx # RecRead(981,4,0);
  END;

  RETURN true;
end;


/***
//========================================================================
//  Insert
//
//========================================================================
sub XXXInsert(
  aLock       : int;
  aGrund      : alpha;
  opt aRecId  : int;
  opt aNoNoti : logic;
) : int;
local begin
  vBereich  : alpha;
  vA        : alpha;
  vBuf      : int;
  vErg      : int;
end;
begin

  case TeM.A.Datei of
    100 :             vBereich  # 'ADR';
    101 :             vBereich  # 'ANS';
    102 :             vBereich  # 'ANP';
    110 :             vBereich  # 'VER';
    120 :             vBereich  # 'PRJ';
    122 :             vBereich  # 'PRJ_P';
    200 : begin
                      vBereich  # 'MAT';
//                      TeM.A.ID1 # Mat.Nummer;
      end;
    401 : vBereich  # 'AUF';
    501 : vBereich  # 'EIN';
    800 : vBereich  # '';//'USR';
    702 : vBereich  # 'BAG_P';
    otherwise
          vBereich  # '???';
  end


  if (vBereich<>'') and (Tem.A.ID1<>0) then begin
    vA # vBereich + StrFmt(CnvAi(TeM.A.ID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin)
    if (Tem.A.Id2<>0) then vA # vA + '/' + StrFmt(CnvAi(TeM.A.ID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin);
    Tem.A.Code # vA;
  end


  if (Tem.A.Datei>0) and (Tem.A.Datei<=999) then begin
    if (aRecID<>0) then begin
      vBuf # RecBufCreate(Tem.A.Datei);
      RecRead(vBuf, 0, _recId, aRecID);
      TeM.A.Key # Lib_Rec:MakeKey(vBuf, n);
      RecBufDestroy(vBuf);
    end
    else begin
      TeM.A.Key  # Lib_Rec:MakeKey(Tem.A.Datei, n);
    end;
  end;


  // KEY prüfen
//  Erx # RecRead(981,2,_recTest);
//  if (Erx<=_rMultikey) then RETURN _rExists;

  vErg # RekInsert(981,aLock,aGrund);
  if (aNoNoti=false) and (vErg=_rOK) and (TeM.A.Datei=800) and (TEM.A.Nummer<>0) and (TeM.A.Nummer<>MyTmpnummer) then begin
    // 12.11.2014 AH
    if (Tem.Typ<>'WOF') then
      Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Typ+' '+TeM.Bezeichnung, TeM.Nummer ,today, now, 0)
    else
      Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Bezeichnung, TeM.Nummer ,today, now, 0);
  end;

  RETURN vERG;
end;
***/

/*========================================================================
2023-08-22  AH
========================================================================*/
sub _SucheAblage(
  aDatei1 : int;
  aDatei2 : int;
) : int;
local begin
  vBuf  : int;
  Erx   : int;
end;
begin

  vBuf # RekSave(aDatei2);
  Erx # Lib_Rec:ReadByKey(aDatei2, TeM.A.Key);
  RecBufCopy(aDatei2, aDatei1);
  RekRestore(vBuf);
  
  RETURN Erx;
end;


//========================================================================
//  Code2Text
//
//========================================================================
SUB Code2Text(
  var aTyp  : alpha;
  var aName : alpha)
local begin
  vBuf      : handle;
  Erx       : int;
end;
begin

  if (TeM.A.Datei=0) then begin
    aTyp # TeM.A.Code;
    RETURN;
  end;

  vBuf # RekSave(TeM.A.Datei);
  Erx # Lib_Rec:ReadByKey(TeM.A.Datei, TeM.A.Key);
  // 2023-08-22 AH  ABLAGEN???
  if (Erx>_rLocked) then begin
    Case Tem.A.Datei of
      200 : Erx # _SucheAblage(200,210);
      400 : Erx # _SucheAblage(400,410);
      401 : Erx # _SucheAblage(401,411);
      500 : Erx # _SucheAblage(500,510);
      501 : Erx # _SucheAblage(501,511);
      540 : Erx # _SucheAblage(540,545);
      655 : Erx # _SucheAblage(655,656);
    end;
    if (Erx>_rLocked) then begin
      RekRestore(vBuf);
      RETURN;
    end;
  end;

  case TeM.A.Datei of
    100 : begin
      aTyp  # 'Adr.';
      aName # Adr.Stichwort;
    end;


    101 : begin
      aTyp  # 'Ans.';
      aName # Adr.A.Stichwort;
    end;


    102 : begin
      aTyp  # 'Ansp.';
      aName # Adr.P.Stichwort;
    end;


    110 : begin
      aTyp  # 'Ver.';
      aName # Ver.Stichwort;
    end;


    120 : begin
      aTyp  # 'Prj.';
      aName # aint(Prj.Nummer);
    end;


    122 : begin
      aTyp  # 'Prj.';
      aName # aint(Prj.P.Nummer)+'/'+AInt(Prj.P.Position);
      if (Prj.P.SubPosition>0) then
        aName # aName + '/'+aint(Prj.P.SubPosition);
    end;


    200 : begin
      aTyp  # 'Mat.';
      aName # AInt(Mat.Nummer);
    end;


    401 : begin
      aTyp  # 'Auf.';
      aName # AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
    end;


    501 : begin
      aTyp  # 'Ein.';
      aName # AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position);
    end;

    
    540 : begin
      aTyp  # 'Bdf.';
      aName # AInt(Bdf.Nummer);
    end;


    800 : begin
      aTyp  # 'User';
//      aName # Usr.Name;
      aName # Tem.A.Code; // 21.12.2021 AH
    end;


    702 : begin
      aTyp # 'BAG_P';
      aName # AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
    end;
    
    916 : begin
      if (Anh.File<>'') then
        aTyp  # Translate('Anhang')
      else
        aTyp  # Translate('Kommentar');
    end;

  end;

  RekRestore(vBuf);

end;


//========================================================================
//  RepairBefore070214
//      VOR Installation Update 070214
//========================================================================
SUB RepairBefore070214();
local begin
  Erx   : int;
  vNr   : int;
  v981  : int;
end;
begin

  v981 # RecBufCreate(981);

  Erx # RecRead(981,1,_recfirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufCopy(981, v981);
    Erx # RecRead(981,1,_recNext);

    vNr # 100;

    // anderer Bericht? -> überspringen
    WHILE (TeM.A.Nummer = v981->TeM.A.Nummer) and
        (TeM.A.Berichtsnr = v981->TeM.A.Berichtsnr) and
        (TeM.A.lfdnr = v981->teM.A.lfdnr) do begin

      RecRead(981,1,_recLock);
      TeM.A.lfdnr # vNr;
      Erx # RecReplace(981,_recUnlock);
if (Erx<>_rOK) then todox('');
      vNr # vNr + 1;

      RecBufCopy(v981, 981);
      Erx # RecRead(981,1,0);
      Erx # RecRead(981,1,_recNext);

    END;


    Erx # RecRead(981,1,_recNext);
  END;

  RecBufDestroy(v981);

  Msg(999998,'',0,0,0);
end;


//========================================================================
// CALL TeM_A_Data:RepairBefore010315
//        setzt alte Useranker richtig
//========================================================================
SUB RepairBefore010315();
local begin
  Erx : int;
end;
begin

  APPOFF();

  FOR Erx # RecRead(981,1,_recfirst);
  LOOP Erx # RecRead(981,1,_recNext);
  WHILE (Erx<=_rLocked) do begin

    if (Tem.A.Key<>'') then CYCLE;
    if (Tem.A.Datei<>800) then CYCLE;

    Usr.Username # Tem.A.Code;
    RecRead(800,1,0);

    RecRead(981,1,_recLock);
    TeM.A.Key  # Lib_Rec:MakeKey(Tem.A.Datei, n);
    RekReplace(981);
  END;
  Usr_data:RecReadThisUser();

  APPON();

end;

//========================================================================