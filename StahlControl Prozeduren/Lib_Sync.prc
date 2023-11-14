@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Sync
//                    OHNE E_R_G
//  Info      Protokolliert Änderungen in PtD.Sync
//
//
//  12.05.2016  AH  Erstellung der Prozedur
//  18.03.2021  AH  Optimiert nur für <900 Datei
//  (BLOSS NICHT 07.07.2021  AH  alle 992 Operationen mit EARLYCOMMIT)
//  08.07.2021  AH  Transaktion-RAMList
//  12.05.2022  ST  "sub SyncInfoByRecId" hinzugefügt
//  25.05.2022  AH  Fix auch für 931 und 935
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  SetTimeStamp  : PtD.Sync.TimeStamp->vmServerTime()
  SetUser       : PtD.Sync.UserId # gUserID
end;



//========================================================================
//  sub SyncInfoByRecId()
//
//  Gibt Informationen zum ersten Sync Element der Queue aus, um
//  anhand der Daten den Fehler zu beheben, ohne die Applikation zu
//  verlassen
//========================================================================
sub SyncInfoByRecId()
local begin
  Erx   : int;
  vKey  : alpha;
  vMsg  : alpha(1000);
end
begin
 
  Erx # RecRead(992,1,_RecFirst);
  if (Erx = _rOK) then begin

    if (PtD.Sync.Datei < 1000) then begin
      
      //  Problem ist ein Datensatz
      Erx # RecRead(PtD.Sync.Datei,0,_RecID,PtD.Sync.RecId);
      if (Erx = _rOK) then begin
        vMsg  # 'Datei: ' + Aint(PtD.Sync.Datei) + '/'+  FileName(PtD.Sync.Datei) + StrChar(10) +
                'Key  : ' + Lib_Rec:MakeKey(PtD.Sync.Datei) + StrChar(10) +
                'RecId: ' + Aint(PtD.Sync.RecId) + StrChar(10) +
                'OP   : ' + PtD.Sync.Operation;
        MsgInfo(99,vMsg);
      end else begin
        MsgErr(99,'Kein Datensatz für RecID ('+Aint(PtD.Sync.RecId)+') gefunden');
      end;
          
    end else begin
    
      //  Problem ist ein Text oder ähnliches
        vMsg  # 'Datei: ' + Aint(PtD.Sync.Datei) + '/'+  FileName(PtD.Sync.Datei) + StrChar(10) +
                'Key  : ' + PtD.Sync.Para1 + ' ' + PtD.Sync.Para2 + StrChar(10) +
                'OP   : ' + PtD.Sync.Operation;
        MsgInfo(99,vMsg);
    
    end;

  end else begin
    
    if (Erx = _rNoRec) then
      MsgInfo(99,'Warteschelife ist leer. Kein Problem.');
  
  end;
  
  
end;


//========================================================================
sub TL_Insert992() : logic;
local begin
  vItem : int;
  v992  : int;
  vOK   : logic;
end;
begin
  // PTD kopieren
  v992 # RecBufCreate(992);
  RecBufCopy(992,v992);
  
  // Buffer im RAM speichern
  vItem # CteOpen(_cteItem);
  vItem->spname    # cnvab(PtD.Sync.TimeStamp);
  vItem->spId      # TransCount;
  vItem->spcustom  # aint(v992);
  vOK # gTransList->CteInsert(vItem,_CteLast);
//debugx('ins '+aint(vItem->spid)+' : '+aint(PtD.Sync.Datei)+':'+aint(PtD.Sync.RecId)+' : '+abool(vOK));

  RETURN true;
end;


//========================================================================
// Transcounter schon gemindert!
sub TL_Rollback() : logic;
local begin
  vItem   : int;
  vItem2  : int;
  v992    : int;
end;
begin
  vItem # gTransList->CteRead(_CteFirst);
  WHILE (vItem>0) do begin
    if (vItem->spId=TransCount+1) then begin
      vItem2 # gTransList->CteRead(_CteNext, vItem);
      v992 # cnvia(vItem->spcustom);
      CteDelete(gTranslist, vItem);
      CteClose(vItem);
      RecBufDestroy(v992);
      vItem # vItem2;
      CYCLE;
    end;
    vItem # gTransList->CteRead(_CteNext, vItem);
  END;
end;

//========================================================================
sub TL_Reset() : logic;
local begin
  vItem   : int;
  vItem2  : int;
  v992    : int;
end;
begin
  vItem # gTransList->CteRead(_CteFirst);
  WHILE (vItem>0) do begin
    vItem2 # gTransList->CteRead(_CteNext, vItem);
    v992 # cnvia(vItem->spcustom);
    CteDelete(gTranslist, vItem);
    CteClose(vItem);
    RecBufDestroy(v992);
    vItem # vItem2;
  END;
end;


//========================================================================
// Transcounter schon gemindert!
sub TL_Commit() : logic;
local begin
  vItem : int;
  v992  : int;
  Erx   : int;
end;
begin

  if (TransCount=0) then begin
//debugx('finales Commit!');
    vItem # gTransList->CteRead(_CteFirst);
    WHILE (vItem>0) do begin
      v992 # cnvia(vItem->spcustom);
//debugx('COMMIT '+aint(vItem->spid)+' : '+aint(v992->PtD.Sync.Datei)+':'+aint(v992->PtD.Sync.RecId));
      REPEAT
        Erx # RecInsert(v992,_RecEarlyCommit);
        if (Erx<>_rOK) then begin
          v992->PtD.Sync.TimeStamp # v992->PtD.Sync.TimeStamp + 1;
          CYCLE;
        end;
        BREAK;
      UNTIL (1=1)
      RecbufDestroy(v992);
      
      CteDelete(gTranslist, vItem);
      CteClose(vItem);
      vItem # gTransList->CteRead(_CteFirst);
    END;
  end;
  
  // "tiefere" Transaktionen heraufstufen
  vItem # gTransList->CteRead(_CteFirst);
  WHILE (vItem>0) do begin
//    v992 # cnvia(vItem->spcustom);
//debugx('lese '+aint(vItem->spid)+' : '+aint(v992->PtD.Sync.Datei)+':'+aint(v992->PtD.Sync.RecId));
    if (vItem->spId=TransCount+1) then begin
//debugx('remap '+aint(vItem->spid)+' auf '+aint(TransCount));
      vItem->spId # TransCount;     // Heraufstufen
    end;
    vItem # gTransList->CteRead(_CteNext, vItem)
  END;
end;


//========================================================================
//  Insert
//
//========================================================================
sub Insert(
  aDatei      : int;
  aRecID      : int) : logic;
begin
  if (gBlueMode) then RETURN true;
  
  PtD.Sync.Operation  # 'I';
  if (aDatei<1000) then
    PtD.Sync.Datei    # aDatei
  else
    PtD.Sync.Datei    # HdlInfo(aDatei,_HdlSubType);

  if (((PtD.Sync.Datei>=900) and (Ptd.Sync.Datei<>931) and (Ptd.Sync.Datei<>935)) or (PtD.Sync.Datei=0)) then RETURN true;
    
  PtD.Sync.RecID      # aRecID;
  PtD.Sync.Para1      # '';
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  
  RETURN true;
end;


//========================================================================
//  Update
//
//========================================================================
sub Update(
  aDatei    : int;
  aRecId    : int) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'U';
  if (aDatei<1000) then
    PtD.Sync.Datei    # aDatei
  else
    PtD.Sync.Datei    # HdlInfo(aDatei,_HdlSubType);
  if (((PtD.Sync.Datei>=900) and (Ptd.Sync.Datei<>931) and (Ptd.Sync.Datei<>935)) or (PtD.Sync.Datei=0)) then RETURN true;

  PtD.Sync.RecID      # aRecId;
  PtD.Sync.Para1      # '';
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aDatei  : int;
  aRecId  : int) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'D';
  if (aDatei<1000) then
    PtD.Sync.Datei    # aDatei
  else
    PtD.Sync.Datei    # HdlInfo(aDatei,_HdlSubType);
  if (((PtD.Sync.Datei>=900) and (Ptd.Sync.Datei<>931) and (Ptd.Sync.Datei<>935)) or (PtD.Sync.Datei=0)) then RETURN true;

  PtD.Sync.RecID      # aRecID;
  PtD.Sync.Para1      # '';
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
//  DeletaAll
//
//========================================================================
sub DeleteAll(aDatei : int) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'C';
  if (aDatei<1000) then
    PtD.Sync.Datei    # aDatei
  else
    PtD.Sync.Datei    # HdlInfo(aDatei,_HdlSubType);
  if (((PtD.Sync.Datei>=900) and (Ptd.Sync.Datei<>931) and (Ptd.Sync.Datei<>935)) or (PtD.Sync.Datei=0)) then RETURN true;

  PtD.Sync.RecID      # 0;
  PtD.Sync.Para1      # '';
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
//  InsertText
//
//========================================================================
sub InsertText(
  aName       : alpha;
  opt aName2  : alpha) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'I';
  PtD.Sync.Datei      # 1000;
  PtD.Sync.RecID      # 0;
  PtD.Sync.Para1      # aName;
  PtD.Sync.Para2      # aName2;
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
//  CreateText
//
//========================================================================
sub CreateText(aName : alpha) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'N';
  PtD.Sync.Datei      # 1000;
  PtD.Sync.RecID      # 0;
  PtD.Sync.Para1      # aName;
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
//  DeleteText
//
//========================================================================
sub DeleteText(aName : alpha) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'D';
  PtD.Sync.Datei      # 1000;
  PtD.Sync.RecID      # 0;
  PtD.Sync.Para1      # aName;
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
//  RenameText
//
//========================================================================
sub RenameText(
  aName   : alpha;
  aName2  : alpha) : logic;
begin
  if (gBlueMode) then RETURN true;

  PtD.Sync.Operation  # 'R';
  PtD.Sync.Datei      # 1000;
  PtD.Sync.RecID      # 0;
  PtD.Sync.Para1      # aName;
  PtD.Sync.Para2      # aName2;
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then RETURN TL_Insert992();
  UNTIL (RecInsert(992,0)=_rOK);
  RETURN true;
end;


//========================================================================
sub _Resync(aDatei : int)
begin
  
  PtD.Sync.Operation  # 'X';
  PtD.Sync.Datei    # aDatei
  if (((PtD.Sync.Datei>=900) and (Ptd.Sync.Datei<>931) and (Ptd.Sync.Datei<>935)) or (PtD.Sync.Datei=0)) then RETURN;
  
  PtD.Sync.RecID      # RecInfo(aDatei,_RecID)
  PtD.Sync.Para1      # '';
  PtD.Sync.Para2      # '';
  SetUser;
  REPEAT
    SetTimeStamp;
    if (gTransList>0) and (TransCount>0) then begin
      TL_Insert992();
      RETURN;
    end;
  UNTIL (RecInsert(992,0)=_rOK);
  
  RETURN;
end;


//========================================================================
// call Lib_Sync:Resync100
//========================================================================
sub Resync100(
  opt aGrenzNr  : int;)
local begin
  Erx : int;
end;
begin

  RecBufClear(100);
  Adr.Nummer # aGrenzNr;
  RecRead(100,1,0);
  FOR Erx # RecRead(100,1,0)
  LOOP Erx # RecRead(100,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Adr.Nummer<aGrenzNr) then CYCLE;
    
    _Resync(100);
  END;
  
end;


//========================================================================
sub Resync440(
  aGrenzNr  : int;
  aGrenzDat : date;)
local begin
  Erx : int;
end;
begin
  RecBufClear(440);
  Lfs.Nummer # aGrenzNr;
  RecRead(440,1,0);
  FOR Erx # RecRead(440,1,0)
  LOOP Erx # RecRead(440,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lfs.Nummer<aGrenzNr) then CYCLE;
    // OR
    if (Lfs.Anlage.Datum<aGrenzDat) and (Lfs.Datum.Verbucht<aGrenzDat) and (Lfs.Lieferdatum<aGrenzDat) then CYCLE;
    
    _Resync(440);
  END;
  
end;

//========================================================================
sub Resync130(
  aGrenzNr  : int;
  aGrenzDat : date;)
local begin
  Erx : int;
end;
begin

  RecBufClear(130);
  Lfe.Nummer # aGrenzNr;
  RecRead(130,1,0);
  FOR Erx # RecRead(130,1,0)
  LOOP Erx # RecRead(130,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lfe.Nummer<aGrenzNr) then CYCLE;
    // OR
    if (Lfe.Anlage.Datum<aGrenzDat) then CYCLE;
    
    _Resync(130);

    // Pos.
    FOR Erx # RecLink(131,130,1,_recFirst)
    LOOP Erx # RecLink(131,130,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(131);
    END;
  END;
  
end;


//========================================================================
sub Resync200(
  aGrenzNr  : int;
  aGrenzDat : date;)
local begin
  Erx : int;
end;
begin

  RecBufClear(200);
  Mat.Nummer # aGrenzNr;
  RecRead(200,1,0);
  FOR Erx # RecRead(200,1,0)
  LOOP Erx # RecRead(200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.Nummer<aGrenzNr) then CYCLE;
    // OR
    if (Mat.Anlage.Datum<aGrenzDat) and (Mat.Datum.Erzeugt<aGrenzDat) and (Mat.Eingangsdatum<aGrenzDat) and (Mat.Ausgangsdatum<aGrenzDat) and (Mat.VK.Rechdatum<aGrenzDat) and
      ("Mat.Lösch.Datum"<aGrenzDat) then CYCLE;

    _Resync(200);

    // AFs
    FOR Erx # RecLink(201,200,11,_recFirst)
    LOOP Erx # RecLink(201,200,11,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(201);
    END;
    
  END;

  // Mat-Aktionen
  FOR Erx # RecRead(204,1,_recFirst)
  LOOP Erx # RecRead(204,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Anlage.Datum<aGrenzDat) and (Mat.A.Aktionsdatum<aGrenzDat) and (Mat.A.TerminEnde<aGrenzDat) and (Mat.A.TerminStart<aGrenzDat) then CYCLE;
    
    _Resync(204);
  END;


  // Bestandsbuch
  FOR Erx # RecRead(202,1,_recFirst)
  LOOP Erx # RecRead(202,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.B.Anlage.Datum<aGrenzDat) and (Mat.B.Datum<aGrenzDat) then CYCLE;
    
    _Resync(202);
    Erx # RecLink(200,202,1,_recFirst);   // Mat holen
    if (erx<=_rLocked) then
      _Resync(200);
  END;

  // Reservierungen komplett
  Lib_Transfers:SYNC(203);

end;


//========================================================================
sub Resync230(
  aGrenzNr  : int;
  aGrenzDat : date;)
local begin
  Erx : int;
end;
begin

  RecBufClear(230);
  Lys.K.Analysenr # aGrenzNr;
  RecRead(230,1,0);
  FOR Erx # RecRead(230,1,0)
  LOOP Erx # RecRead(230,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lys.K.Analysenr<aGrenzNr) then CYCLE;
    // OR
    if (Lys.K.Anlage.Datum<aGrenzDat) then CYCLE;
    
    _Resync(230);

    // Pos.
    FOR Erx # RecLink(231,230,1,_recFirst)
    LOOP Erx # RecLink(231,230,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(231);
    END;
  END;
  
end;


//========================================================================
sub Resync280(
  aGrenzNr  : int;
  aGrenzDat : date;)
local begin
  Erx : int;
end;
begin

  RecBufClear(280);
  Pak.Nummer # aGrenzNr;
  RecRead(280,1,0);
  FOR Erx # RecRead(280,1,0)
  LOOP Erx # RecRead(280,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Pak.Nummer<aGrenzNr) then CYCLE;
    // OR
    if (Pak.Anlage.Datum<aGrenzDat) then CYCLE;
    
    _Resync(280);

    // Pos.
    FOR Erx # RecLink(281,280,1,_recFirst)
    LOOP Erx # RecLink(281,280,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(281);
    END;
  END;
  
end;


//========================================================================
sub Resync400(
  aGrenzNr  : int;
  aGrenzDat : date;)
local begin
  Erx : int;
end;
begin

  RecBufClear(400);
  Auf.Nummer # aGrenzNr;
  RecRead(400,1,0);
  FOR Erx # RecRead(400,1,0)
  LOOP Erx # RecRead(400,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Nummer<aGrenzNr) then CYCLE;
    // OR
    if (Auf.Anlage.Datum<aGrenzDat) then CYCLE;
    
    _Resync(400);

    // Pos.
    FOR Erx # RecLink(401,400,9,_recFirst)
    LOOP Erx # RecLink(401,400,9,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(401);
      // AF
      FOR Erx # RecLink(402,401,9,_recFirst)
      LOOP Erx # RecLink(402,401,9,_recNext)
      WHILE (Erx<=_rLocked) do begin
        _Resync(402);
      END;
    END;

    // Aufpreise
    FOR Erx # RecLink(403,400,13,_recFirst)
    LOOP Erx # RecLink(403,400,13,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(403);
    END;
    // Kalkulation
    FOR Erx # RecLink(405,400,14,_recFirst)
    LOOP Erx # RecLink(405,400,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
      _Resync(405);
    END;

  END; // Kopf

  
  // Aktionen
  FOR Erx # RecRead(404,1,_recFirst)
  LOOP Erx # RecRead(404,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.A.Anlage.Datum<aGrenzDat) and (Auf.A.Aktionsdatum<aGrenzDat) and (Auf.A.TerminStart<aGrenzDat) and (Auf.A.TerminEnde<aGrenzDat) then CYCLE;
    
    _Resync(404);
    Erx # RecLink(401,404,1,_recFirst);   // Pos holen
    if (erx<=_rLocked) then
      _Resync(401);
  END;

end;



//========================================================================