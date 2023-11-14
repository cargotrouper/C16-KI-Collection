@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_MoreBufs
//                      OHNE E_R_G
//  Info
//
//
//  17.01.2018  AH  Erstellung der Prozedur
//  02.01.2019  AH  "CopyNew" kann auch Replace
//  12.08.2019  AH  BufFix: "CopyNew" (darf nicht Rekdel auf Buffer)
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//  SUB Init(aTrDatei : int);
//  SUB CopyNew(aDatei : int; aName : alpha; aTrDatei : int; aTrDatei2 : int; opt aRep : logic) : logic
//  SUB ReadAll(aTrDatei : int);
//  SUB ReadBuf(aTrDatei  : int; aBuf : int;  aName : alpha) : logic;
//  SUB RecInit(aTrDatei : int; aNew : logic; opt aCopy : logic) : logic
//  SUB Lock(opt aDatei  : int; opt aName : alpha) : int;
//  SUB Unlock(opt aDatei : int; opt aName : alpha) : int;
//  SUB SaveAll(aTrDatei  : int) : int
//  SUB DeleteAll(aTrDatei : int) : int;
//
//  SUB GetBuf(aDatei : int; aName : alpha) : int;
//  SUB CreateBuf(aDatei : int; aName : alpha) : int;
//  SUB Close()
//
//========================================================================
@I:Def_Global
declare _SetPrimary(aTrDatei : int; aBuf : int; aName : alpha; aInsert : logic) : logic;
declare Lock(opt aDatei : int; opt aName : alpha) : int;
declare CreateBuf(aDatei : int; aName : alpha) : int;
declare Unlock(opt aDatei : int; opt aName   : alpha) : int;
declare ReadMoreBuf(aTrDatei : int; aBuf : int; aName : alpha) : logic
declare ReadAll(aTrDatei : int;);
/***
//========================================================================
sub _Dump();
local begin
  vItem : int;
end;
begin
  FOR vItem # CteRead(w_MoreBufs, _CteFirst,  0)
  LOOP vItem # CteRead(w_MoreBufs, _CteNext, vItem)
  WHILE (vItem<>0) do begin
debug('DUMP: '+vItem->spname+':'+vItem->spCustom);
  END;
end;
***/

//========================================================================
// Init
//    Normalerweise im INIT, um verbundene Bufs vorzubereiten
//========================================================================
sub Init(aTrDatei : int);
begin

  // leere weitere Buffer erzeugen
  case aTrDatei of

    105 : begin
      CreateBuf(231, '');
    end;

    401 : begin
      CreateBuf(231, '');
    end;

    501 : begin
      CreateBuf(231, '');
    end;

    832 : begin
      CreateBuf(231, '');
      //CreateBuf(231, 'BIS');
    end;

    833 : begin
      CreateBuf(231, '');
    end;
  end;

end;


//========================================================================
//  CopyNew
//      Kopiert einen Satz von einem Träger als NEU zu einem anderen
//========================================================================
SUB CopyNew(
  aDatei    : int;
  aName     : alpha;
  aTrDatei  : int;
  aTrDatei2 : int;
  opt aRep  : logic) : logic
local begin
  Erx       : int;
  vBuf      : int;
  vBuf2     : int;
end;
begin

  // Lesen...
  vBuf # RecBufDefault(aDatei);
  if (ReadMoreBuf(aTrDatei, vBuf, aName)=false) then begin
    RETURN false;
  end;

  // Key mit NEUEN Werten füllen
  if(_SetPrimary(aTrDatei2, vBuf, aName, y)=false) then begin
    RETURN false;
  end;

  if (aRep) then begin
    vBuf2 # RekSave(aDatei);
    if (RecRead(aDatei,1,0)<=_rLocked) then
      RekDelete(aDatei);
    RekRestore(vBuf2);
  end;
      
  Erx # RekInsert(aDatei);

  RETURN Erx=_rOK;
end;


//========================================================================
//========================================================================
sub _SetPrimary(
  aTrDatei  : int;
  aBuf      : int;
  aName     : alpha;
  aInsert   : logic) : logic;
begin

  case aTrDatei of

    105 : begin
      aBuf->"Lys.Trägerdatei"     # aTrDatei;
      aBuf->"Lys.Trägernummer1"   # Adr.V.AdressNr;
      aBuf->"Lys.Trägernummer2"   # Adr.V.LfdNr;
      aBuf->"Lys.Trägernummer3"   # 0;
//debugx('setPrim '+aint(aTrDatei)+'/'+aint(Adr.V.Adressnr)+'/'+aint(Adr.V.lfdNr));
/***
      if (aInsert) then begin
        Lys.AnalyseNr # Lib_Nummern:ReadNummer('Analysen.Erweitert');
        if (Lys.AnalyseNr<=0) then begin
          Lib_Nummern:FreeNummer();
          RETURN false;
        end;
        Lib_Nummern:SaveNummer();
      end;
***/
      RETURN true;
    end;

    401 : begin
      aBuf->"Lys.Trägerdatei"     # aTrDatei;
      aBuf->"Lys.Trägernummer1"   # Auf.P.Nummer;
      aBuf->"Lys.Trägernummer2"   # Auf.P.Position;
      aBuf->"Lys.Trägernummer3"   # 0;
      RETURN true;
    end;

    501 : begin
      aBuf->"Lys.Trägerdatei"     # aTrDatei;
      aBuf->"Lys.Trägernummer1"   # Ein.P.Nummer;
      aBuf->"Lys.Trägernummer2"   # Ein.P.Position;
      aBuf->"Lys.Trägernummer3"   # 0;
      RETURN true;
    end;

    832 : begin
      aBuf->"Lys.Trägerdatei"     # aTrDatei;
      aBuf->"Lys.Trägernummer1"   # MQU.ID;
      aBuf->"Lys.Trägernummer2"   # 0;
      aBuf->"Lys.Trägernummer3"   # 0;
      RETURN true;
    end;

    833 : begin
      aBuf->"Lys.Trägerdatei"     # aTrDatei;
      aBuf->"Lys.Trägernummer1"   # "MQu.M.GütenID";
      aBuf->"Lys.Trägernummer2"   # "MQu.M.lfdNr";
      aBuf->"Lys.Trägernummer3"   # 0;
      RETURN true;
    end;

  end;

  RETURN false;
end;


//========================================================================
//  RecInit
//      Beim Editieren Sätze sperren - bei Neuanlage leeren
//========================================================================
Sub RecInit(
  aTrDatei  : int;
  aNew      : logic;
  opt aCopy : logic) : logic
local begin
  vItem   : int;
  vName   : alpha;
  vBuf    : int;
end;
begin

  if (w_MoreBufs=0) then RETURN true;

  if (aNew=false) then begin        // EDITIEREN
    ReadAll(aTrDatei);
    if (Lock()<>_rOK) then begin
      RETURN false;
    end;
  end
  else begin                        // NEUANLAGE

    FOR vItem # CteRead(w_MoreBufs, _CteFirst,  0)
    LOOP vItem # CteRead(w_MoreBufs, _CteNext, vItem)
    WHILE (vItem<>0) do begin
      vBuf    # vItem->spID;
      vName   # StrCut(vItem->spName, 5,20);

      if (aCopy) then begin
        ReadAll(aTrDatei);
        vItem->spCustom # 'NEW';
        CYCLE;
      end;

      RecBufClear(vBuf);
      vItem->spCustom # 'NEW';
//debugx('recint NEW');
    END;
  end;

  RETURN true;
end;


//========================================================================
//  ReadAll
//      Alle Sätze lesen oder leer vorbereiten
//========================================================================
Sub ReadAll(aTrDatei : int);
local begin
  vItem   : int;
  vName   : alpha;
  vBuf    : int;
end;
begin

  if (w_moreBufs=0) then RETURN;

  Unlock();

  FOR vItem # CteRead(w_MoreBufs, _CteFirst,  0)
  LOOP vItem # CteRead(w_MoreBufs, _CteNext, vItem)
  WHILE (vItem<>0) do begin
    vBuf    # vItem->spID;
    vName   # StrCut(vItem->spName, 5,20);
    if (ReadMoreBuf(aTrDatei, vBuf, vName)=false) then begin
      vItem->spCustom # 'NEW';
    end
    else begin
      vItem->spCustom # '';
    end;
  END;

end;


//========================================================================
//  ReadMoreBuf
//    Liest einen angehängten Satz in aBuf zu Datei aTrDatei
//========================================================================
sub ReadMoreBuf(
  aTrDatei  : int;
  aBuf      : int;
  aName     : alpha) : logic;
local begin
  Erx : int;
end;
begin

  _SetPrimary(aTrDatei, aBuf, aName, false);
  Erx # RecRead(aBuf, 1, 0);
  if (Erx<=_rLocked) then RETURN true;

  RecBufClear(aBuf);
  _SetPrimary(aTrDatei, aBuf, aName, false);
  RETURN false;
end;


//========================================================================
//  GetBuf
//      Holt einen Buffer und kopiert ihn in den DEFAULT-Feldbuffer
//========================================================================
sub GetBuf(
  aDatei    : int;
  aName     : alpha) : int;
local begin
  vItem     : int;
end;
begin

  if (w_MoreBufs=0) then RETURN 0;

  if (aName='') then aName # 'MAIN';
  aName # aint(aDatei)+'|'+aName;
  vItem # CteRead(w_MoreBufs, _CteFirst | _CteSearch, 0, aName)
  if (vItem=0) then RETURN 0;
  RecBufCopy(vITem->spID, aDatei);

  RETURN vItem->spID;
end;


//========================================================================
//  CreateBuf
//      Erzeugt einen neuen Buffer bzw. leer ihn
//========================================================================
sub CreateBuf(
  aDatei          : int;
  aName           : alpha) : int;
local begin
  vItem : int;
  vBuf  : int;
end;
begin
  if (w_MoreBufs=0) then
    w_MoreBufs # CteOpen(_CteTree);

  if (aName='') then aName # 'MAIN';
  aName # aint(aDatei)+'|'+aName;

  vItem # CteRead(w_MoreBufs, _CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then begin
    // NEU?
    vBuf # RecBufCreate(aDatei);
    vItem # CteInsertItem(w_Morebufs, aName, vBuf, '');
  end
  else begin
    vBuf # vItem->spID;
    vItem->spCustom # '';
  end;

  RETURN vBuf;
end;


//========================================================================
//  Lock
//      Sperrt einen oder alle Sätze
//========================================================================
sub Lock(
  opt aDatei  : int;
  opt aName   : alpha) : int;
local begin
  Erx         : int;
  vItem       : int;
  vBuf        : int;
end;
begin
  if (w_MoreBufs=0) then RETURN _rOK;

  if (aName='') then aName # 'MAIN';

  // ALLE sperren?
  if (aDatei=0) then begin
    FOR vItem # CteRead(w_MoreBufs, _CteFirst | _CteSearch, 0)
    LOOP vItem # CteRead(w_MoreBufs, _CteNext | _CteSearch, vItem)
    WHILE (vItem<>0) do begin

      vBuf # vItem->spID;
      if (vItem->spCustom<>'') then CYCLE;

      // sperren
      Erx # RecRead(vBuf, 1, _reclock);
      if (Erx<>_rOK) then begin
        Erg # Erx;    // TODOERX
        RETURN Erx;
      end;

      vItem->spCustom # 'LOCK';
    END;
    Erg # _rOK;  // TODOERX
    RETURN _rOK;
  end;


  // EINEN sperren...
  aName # aint(aDatei)+'|'+aName;

  vItem # CteRead(w_MoreBufs, _CteFirst | _CteSearch, 0, aName);
  if (vItem<>0) then begin
    vBuf # vItem->spID;
    if (vItem->spCustom='LOCK') then begin
      RecRead(vBuf, 1, _recUnlock);
    end;
    CteDelete(w_MoreBufs, vItem, 0);
  end
  else begin
    vBuf # RecBufCreate(aDatei);
    vItem # CteOpen(_CteItem);
    vItem->spName # aName;
    vItem->spID   # vBuf;
  end;

  // Satz sperren....
  RecBufCopy(aDatei, vBuf);
  Erx # RecRead(vBuf, 1, _recLock);
  // schon gepserrn? -> ERROR
  if (Erx=_rLocked) then begin
    RecBufDestroy(vBuf);
    CteClose(vItem);
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;
  // alles ok?
  if (Erx=_rOK) then begin
    vItem->spCustom # 'LOCK';
    CteInsert(w_Morebufs, vItem,0);
    Erg # _rOK;  // TODOERX
    RETURN _rOK;
  end;

  // Satz fehlt? -> leer erzeugen
  RecBufCopy(aDatei, vBuf);

  vItem->spCustom # 'NEW';
  CteInsert(w_Morebufs, vItem,0);

  Erg # _rOK;  // TODOERX
  RETURN _rOK;
end;


//========================================================================
//  Unlock
//      Entsperrt alle oder einen Satz
//========================================================================
sub Unlock(
  opt aDatei  : int;
  opt aName   : alpha) : int;
local begin
  Erx         : int;
  vItem       : int;
  vBuf        : int;
end;
begin
  if (w_MoreBufs=0) then RETURN _rOK;

  if (aName='') then aName # 'MAIN';

  // ALLE unlock?
  if (aDatei=0) then begin

    aName # '*|'+aName;
    FOR vItem # CteRead(w_MoreBufs, _CteFirst | _CteSearch, 0, aName)
    LOOP vItem # CteRead(w_MoreBufs, _CteNext | _CteSearch, vItem, aName)
    WHILE (vItem<>0) do begin

      vBuf # vItem->spID;
      if (vItem->spCustom<>'LOCK') then CYCLE;

      // alten Satz freigeben
      RecRead(vBuf, 1, _recUnlock);

      CteDelete(w_MoreBufs, vItem, 0);
      vItem->spCustom # '';
      RecBufCopy(HdlInfo(vBuf, _HdlSubType), vBuf);
      Erx # RecRead(vBuf, 1, 0);
      if (Erx>_rLocked) then
        vItem->spCustom # 'NEW';
      CteInsert(w_Morebufs, vItem,0);
    END
    RETURN _rOK;
  end;

  // EIN Satz unlock
  aName # aint(aDatei)+'|'+aName;

  vItem # CteRead(w_MoreBufs, _CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN _rOK;

  vBuf # vItem->spID;
  // alten Satz freigeben
  if (vItem->spCustom='LOCK') then begin
    RecRead(vBuf, 1, _recUnlock);
  end;

  vItem->spCustom # '';
  RecBufCopy(aDatei, vBuf);
  Erx # RecRead(vBuf, 1, 0);
  if (Erx>_rLocked) then
    vItem->spCustom # 'NEW';
  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Close
//      Normalerweise biem EVTCLOSE, räumt auf
//========================================================================
sub Close()
local begin
  vItem : int;
end;
begin
  if (w_MoreBufs=0) then RETURN;

  // ALLE Sperren entfernen
  Unlock(0,'');

  FOR vItem # w_MoreBufs->CteRead(_CteFirst);
  LOOP  vItem # w_MoreBufs->CteRead(_CteNext, vItem);
  WHILE (vItem != 0) do begin
    RecBufDestroy(vItem->spID);
  END;

  CteClear(w_MoreBufs,y);
  CteClose(w_MoreBufs);
  w_MoreBufs # 0;
end;


//========================================================================
//  SaveAll
//      Speichert alle Buffer - also Replace oder Insert
//========================================================================
sub SaveAll(
  aTrDatei    : int;
  opt aProto  : logic) : int
local begin
  Erx     : int;
  vItem   : int;
  vBuf    : int;
  vDatei  : int;
  vName   : alpha;
  vBuf2   : int;
end;
begin

  if (w_MoreBufs=0) then RETURN _rOK;

  FOR vItem # w_MoreBufs->CteRead(_CteFirst);
  LOOP  vItem # w_MoreBufs->CteRead(_CteNext, vItem);
  WHILE (vItem != 0) do begin
    if (vItem->spCustom='') then CYCLE;

    vBuf    # vItem->spId;
    vName   # StrCut(vItem->spName, 5,20);
    vDatei  # HdlInfo(vBuf, _HdlSubType);

    RecBufCopy(vBuf, vDatei);
    vBuf2 # RecBufDefault(vDatei);

    if (vItem->spCustom='LOCK') then begin

        // Protokoll: 16.09.2019
        RecRead(vDatei,1,0);
        PtD_Main:Memorize(vDatei);
        RecBufCopy(vBuf, vDatei);
        PtD_Main:Compare(vDatei, aTrDatei);

      _SetPrimary(aTrDatei, vBuf2, vName, true);
      Erx # RekReplace(vDatei);
    end
    else if (vItem->spCustom='NEW') then begin
      _SetPrimary(aTrDatei, vBuf2, vName, false);
      Erx # RekInsert(vDatei);
//debugx(aint(vDatei)+' ('+aint("Lys.Trägerdatei")+aint("Lys.Trägernummer1")+') insert Erx '+anum(Lys.Chemie.C,3));
    end;
    if (Erx<>_rOK) then begin
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    vItem->spCustom # '';
  END;

  Erg # _rOK;  // TODOERX
  RETURN _rOK;
end;


//========================================================================
//  DeleteAll
//      Löscht alle zugehörigen Sätze
//========================================================================
Sub DeleteAll(
  aTrDatei      : int;
  opt aNixEgal  : logic) : int;
local begin
  Erx     : int;
  vItem   : int;
  vName   : alpha;
  vBuf    : int;
  vDatei  : int;
end;
begin

  if (w_MoreBufs=0) then RETURN _rOK;

  FOR vItem # CteRead(w_MoreBufs, _CteFirst,  0)
  LOOP vItem # CteRead(w_MoreBufs, _CteNext, vItem)
  WHILE (vItem<>0) do begin
    vBuf    # vItem->spID;
    vName   # StrCut(vItem->spName, 5,20);

    vDatei  # HdlInfo(vBuf, _HdlSubType);
    vBuf    # RecBufDefault(vDatei);
    _SetPrimary(aTrDatei, vBuf, vName, false);
    Erx # RekDelete(vDatei);

    if (Erx=_rNoKey) and (aNixEgal) then begin
      vItem->spCustom # '';
      CYCLE;
    end;
    
    if (erx<>_rOK) then begin
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    vItem->spCustom # '';
  END;
  Erg # _ROK;   // TODOERX
  RETURN _rOK;
end;

//========================================================================