@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Data
//                      OHNE E_R_G
//  Info
//
//
//  21.10.2004  AI  Erstellung der Prozedur
//  06.03.2015  AH  "Merge"
//  24.04.2015  AH  "Merge" deaktiviert, da besser in "BA1_P_Data:ImportBA"
//  22.02.2019  AH  "CheckLauf.Autoteilung"
//  27.03.2019  AH  "ErzeugeVorlageAusBA"
//  26.04.2019  AH  "BerechneMarker" ignoriert CUSTOM-Aktionen (z.B. GLPLAN)
//  25.03.2021  AH  "SetVsbMarker"
//  27.07.2021  AH  ERX
//  28.07.2021  AH  "CopyBA"
//  13.09.2021  ST  HFX BSC SFX_ESK_Cut:CopyEskToBag(...); Projekt 2298/17
//  11.11.2021  AH  "Repair_AllMarker"
//  05.05.2022  AH  "SetStatus"
//  07.07.2022  MR  Deadlockfix für Lib_Soa:ReadNummer in sub Insert()
//  12.07.2022  MR  Fix damit die BuchungsAlgoNr nicht auf 0 steht
//  2023-03-22  AH  RepairGluehen
//
//  Subprozeduren
//    SUB SetVsbMarker(aMark : alpha)
//    SUB BerechneMarker
//    SUB Merge(aBAG1 : int; aBAG2 : int) : logic;
//    SUB CheckLauf.Autoteilung
//    SUB ErzeugeVorlageAusBA(aVorlage : int) : int
//    SUB CopyBA(aVon : int; aMengenFakt : float) : int
//    SUB Repair_AllMarker()
//    SUB SetStatus(aStatus : alpha);
//    SUB RepairGluehen
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

declare SetStatus(aStatus : alpha);

//========================================================================
//  SetVsbMarker
//========================================================================
sub SetVsbMarker(aMark : alpha)
local begin
  Erx   : int;
  v702  : int;
end;
begin
  v702 # RekSave(702);
  FOR erx # RecLink(702,700,1,_recFirst)    // Positionen loopen
  LOOP erx # RecLink(702,700,1,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (BAG.P.Typ.VSBYN=n) then CYCLE;
    if ("BAG.P.Löschmarker"<>aMark) then begin
      RecRead(702,1,_recLock);
      "BAG.P.Löschmarker" # aMark;
      RekReplace(702);
    end;
  END;
  RekRestore(v702);
end;


//========================================================================
//  BerechneMarker  +ERR
//
//========================================================================
sub BerechneMarker() : logic;
local begin
  Erx   : int;
  vOK   : logic;
end;
begin

  if ("BAG.Löschmarker"<>'') then RETURN true;

  vOK # y;
  FOR erx # RecLink(702,700,1,_recFirst)    // Positionen loopen
  LOOP erx # RecLink(702,700,1,_recNext)
  WHILE (erx<=_rLocked) and (vOK) do begin
    if (BAG.P.Typ.VSBYN) then CYCLE;
//    if (BAG.P.Aktion<>c_BAG_Versand) and
    if (BAG.P.Aktion<>c_BAG_Custom) and ("BAG.P.Löschmarker"<>'*') then vOK # n;
  END;

  if (vOK) then begin

    RecRead(700,1,_recLock);
    BAG.Fertig.Datum  # today;
    BAG.Fertig.Zeit   # now;
    BAG.Fertig.User   # gUserName;
    "BAG.Löschmarker" # '*';
    "BAG.Lösch.Datum" # today;        // 0.0.0;
    "BAG.Lösch.Zeit"  # now;          // 0:0;
    "BAG.Lösch.User"  # gUsername;    //'';
    Erx # RekReplace(700,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      Error(702031,'');
      RETURN false;
    end;
    SetVsbMarker("BAG.Löschmarker");      // 25.03.2021 AH
  END;

  RETURN true;
end;


//========================================================================
//  Insert  +ERR
//
//========================================================================
sub Insert() : int
local begin
  Erx   : int;
  vNr   : int;
end;
begin
  //  [+] 07.07.2022 MR Deadlockfix
  Erx # Lib_Soa:ReadNummer('BETRIEBSAUFTRAG', var vNr);
  if(Erx <> _rOk) then begin
    Error(902002,'Betriebsauftrag'); // vA # 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
    RETURN -1;
  end
  if (vNr <> 0) then
    Lib_Soa:SaveNummer();
  else begin
    Error(902002,'Betriebsauftrag'); // vA # 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
    RETURN -1;
  end;

  Bag.Nummer    # vNr;
  BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
  erx # RekInsert(700,_recUnlock,'AUTO');
  if (erx <> _rOK) then begin
    Error(700011,'');
    RETURN -1;
  end;

  RETURN _rOK;
end;


//========================================================================
//  Merge +ERR    SIEHE BA1_P_Data:ImportBA 24.04.2015
//
//========================================================================
/***
sub Merge(
  aBAG1 : int;
  aBAG2 : int) : logic;
local begin
  v700a : int;
  v700b : int;
  vTxt  : int;
  vPos  : int;
  vID   : int;
  vID1  : int;
  vVPG  : int;
  vI,vJ : int;
  vA,vB : alpha;
  vAkt  : alpha;
  vErr  : alpha;
end;
begin

  APPOFF();

  v700a # RecBufCreate(700);
  v700b # RecBufCreate(700);

  v700a->BAG.Nummer    # aBAG1;
  Erx # RecRead(v700a,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);

    Error(700100,cnvai(aBAG1)); // todox('A nicht gefunden');
    RETURN false;
  end;
  v700b->BAG.Nummer    # aBAG2;
  Erx # RecRead(v700b,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700101,cnvai(aBAG1)); // todox('B nicht gefunden');
    RETURN false;
  end;


  // Prüfugen -------------------------
  if (v700a->BAG.VorlageYN<>v700b->BAG.VorlageYN) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);

    Error(700104,''); // todox('sind Unterschiedlicher Typ');
    RETURN false;
  end;
  if (RecLinkInfo(707,v700a,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700105,cnvai(aBAG1)); // todox('A schon verwogen');
    RETURN false;
  end;
  if (RecLinkInfo(707,v700b,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700106,cnvai(aBAG2)); // todox('B schon verwogen');
    RETURN false;
  end;
  // letzte ID bestimmen....
  Erx # RecLink(701,v700a,3,_recLast);
  if (Erx<=_rMultikey) then vID # BAG.IO.ID + 1
  else vID # 1;
  // letzte Pos bestimmen....
  Erx # RecLink(702,v700a,1,_recLast);
  if (Erx<=_rMultikey) then vPos # BAG.P.Position + 1
  else vPos # 1;
  // letzte Verpackung bestimmen....
  Erx # RecLink(704,v700a,2,_recLast);
  if (Erx<=_rMultikey) then vVpg # BAG.Vpg.Verpackung + 1
  else vVpg # 1;


  vTxt # Textopen(20);

  TRANSON;

  // Verpackungen transferieren...
  FOR Erx # RecLink(704,v700b,2,_recFirst | _recLock)
  LOOP Erx # RecLink(704,v700b,2,_recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    TextAddLine(vTxt, 'VPG_'+aint(BAG.Vpg.Verpackung)+':'+aint(vVpg));
    BAG.Vpg.Nummer      # aBAG1;
    BAG.Vpg.Verpackung  # vVpg;
    Erx # RekReplace(704,_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700107,''); // todox('Verpackungs Error');
      RETURN false;
    end;
    inc(vVpg);
  END;


  vID1 # vID;
  // Input/Output transferieren...
  FOR Erx # RecLink(701,v700b,3,_recFirst | _recLock)
  LOOP Erx # RecLink(701,v700b,3,_recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    TextAddLine(vTxt, 'ID_'+aint(BAG.IO.ID)+':'+aint(vID));

    // Text unbenennen
    BA1_IO_Data:Rename701Text(BAG.IO.Nummer, BAG.IO.ID, vID);

    if (BAG.IO.Materialnr<>0) then
      TextAddLine(vTxt, 'MATBB|'+aint(BAG.IO.Materialnr)+'|'+c_Akt_BA_Einsatz+'|'+aint(BAG.IO.Nummer)+'|'+aint(BAG.IO.ID)+'|'+c_Akt_BA);
    if (BAG.IO.NachBAG<>0) and (BAG.IO.VonBAG<>0) then begin
      Erx # RecLink(702, 701, 4, _recFirst);    // NachPosition holen
      if (Erx<=_rLocked) and (BAG.P.Typ.VSBYN) and (BAG.P.Auftragsnr<>0) then begin
        vAkt # aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos);
        Erx # RecLink(702, 701, 2, _recFirst);  // VonPosition holen
        if (Erx<=_rLocked) and ((BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand)) and (BAG.P.ZielVerkaufYN) then
          vAkt # vAkt + '|'+ c_Akt_BA_Plan_Fahr;
        else
          vAkt # vAkt + '|' + c_Akt_BA_Plan;
        TextAddLine(vTxt, 'AUFAKT|'+vAkt+'|'+aint(BAG.IO.VonBAG)+'|'+aint(BAG.IO.VonPosition)+'|'+aint(BAG.IO.ID));
      end;
    end;

    BAG.IO.Nummer     # aBAG1;
    BAG.IO.ID         # vID;
    Erx # RekReplace(701,_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700108,''); // todox('Input/Output Error');
      RETURN false;
    end;

    inc(vID);
  END;


  // Positionen transferieren...
  FOR Erx # RecLink(702,v700b,1,_recFirst | _recLock)
  LOOP Erx # RecLink(702,v700b,1,_recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    TextAddLine(vTxt, 'POS_'+aint(BAG.P.Position)+':'+aint(vPos));

    // Text unbenennen
    BA1_P_Data:Rename702Text(BAG.P.Nummer, BAG.P.Position, vPos);

    if (BAG.P.Auftragsnr<>0) and (BAG.P.Typ.VSBYN=False) then
      TextAddLine(vTxt, 'AUFAKT|'+aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos)+'|'+c_Akt_BA+'|'+aint(BAG.P.Nummer)+'|'+aint(BAG.P.Position)+'|0');

    BAG.P.Nummer      # aBAG1;
    BAG.P.Position    # vPos;
    Erx # BA1_P_Data:Replace(_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700109,''); // todox('Positions Error');
      RETURN false;
    end;
    inc(vPos);
  END;


  // Input/Output konvertieren...
  BAG.IO.Nummer # aBAG1;
  BAG.IO.ID     # vID1;
  FOR Erx # RecRead(701, 1, 0)
  LOOP Erx # RecLink(701, v700a ,3, _recNext)
  WHILE (Erx<=_rLocked) and (BAG.IO.ID>=vID1) do begin
    RecRead(701,1,_RecLock);

    if (BAG.IO.VonPosition<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.IO.VonPosition)+':');
      if (vI=0) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('IDPos Error');
        RETURN false;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.VonPosition  # cnvia(vA);
      BAG.IO.VonBAG       # aBAG1;
    end;

    if (BAG.IO.NachPosition<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.IO.NachPosition)+':');
      if (vI=0) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);

        Error(700110,'');// todox('IDPos Error');
        RETURN false;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)

      if (BAG.IO.Materialnr<>0) then begin
        TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(0)+'|'+c_Akt_BA_Einsatz+'|'+aint(BAG.IO.NachBAG)+'|'+aint(BAG.IO.NachPosition));
        TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(BAG.IO.MaterialRstNr)+'|'+c_Akt_BA_Rest+'|'+aint(BAG.IO.NachBAG)+'|'+aint(BAG.IO.NachPosition));
      end;


      BAG.IO.NachPosition # cnvia(vA);
      BAG.IO.NachBAG      # aBAG1;
    end;

    if (BAG.IO.VonID<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.VonID)+':');
      if (vI=0) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN false;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.VonID # cnvia(vA);
    end;
    if (BAG.IO.NachID<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.NachID)+':');
      if (vI=0) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN false;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.NachID # cnvia(vA);
    end;
    if (BAG.IO.UrsprungsID<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.UrsprungsID)+':');
      if (vI=0) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN false;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.UrsprungsID # cnvia(vA);
    end;
    Erx # RekReplace(701,_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN false;
    end;
  END;



  // Fertigungen loopen...
  FOR Erx # RecLink(703, v700b, 6, _recFirst | _recLock)
  LOOP Erx # RecLink(703, v700b, 6, _recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.F.Position)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700111,''); // todox('Fertigung Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);


    TextAddLine(vTxt, 'FERT_'+aint(BAG.F.Position)+'/'+aint(BAG.F.Fertigung)+':'+aint(vPos)+'/'+aint(BAG.F.Fertigung));

    // Text unbenennen
    BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, vJ, BAG.F.Fertigung);

    BAG.F.Nummer    # aBAG1;
    BAG.F.Position  # vJ;
    if (BAG.F.Verpackung<>0) then begin
      vJ # 0;
      vI # TextSearch(vTxt, 1, 1, 0,'VPG_'+aint(BAG.F.Verpackung)+':');
      if (vI<>0) then begin
        vA # TextLineRead(vTxt, vI, 0);
        vA # Str_Token(vA,':',2)
        vJ # cnvia(vA);
      end;
      BAG.F.Verpackung # vJ;
    end;
    Erx # RekReplace(703, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700111,''); // todox('Fertigungs Error');
      RETURN false;
    end;
  END;


  // Ausführungen loopen...
  FOR Erx # RecLink(705, v700b, 7, _recFirst | _recLock)
  LOOP Erx # RecLink(705, v700b, 7, _recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.AF.Position)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700112,''); // todox('Ausführung Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);
    BAG.AF.Nummer     # aBAG1;
    BAG.AF.Position   # vJ;
    Erx # RekReplace(705, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700112,''); // todox('Ausführungs Error');
      RETURN false;
    end;
  END;

  // Arbeitsschritte loopen...
  FOR Erx # RecLink(706, v700b, 8, _recFirst | _recLock)
  LOOP Erx # RecLink(706, v700b, 8, _recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.AS.Position)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700113,''); // todox('Arbeitsschritte Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);
    BAG.AS.Nummer     # aBAG1;
    BAG.AS.Position   # vJ;
    Erx # RekReplace(706, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700113,''); // todox('Arbeitsschritte Error');
      RETURN false;
    end;
  END;

  // Zeiten loopen...
  FOR Erx # RecLink(709, v700b, 9, _recFirst | _recLock)
  LOOP Erx # RecLink(709, v700b, 9, _recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.Z.Position)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700114,''); // todox('Zeiten Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);
    BAG.Z.Nummer     # aBAG1;
    BAG.Z.Position   # vJ;
    Erx # RekReplace(709, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700114,''); // todox('Zeiten Error');
      RETURN false;
    end;
  END;

  // Zusatz loopen...
  FOR Erx # RecLink(711, v700b, 10, _recFirst | _recLock)
  LOOP Erx # RecLink(711, v700b, 10, _recFirst | _recLock)
  WHILE (Erx<=_rLocked) do begin
    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.PZ.Position)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700115,''); // todox('Zusatz Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);
    BAG.PZ.Nummer     # aBAG1;
    BAG.PZ.Position   # vJ;
    Erx # RekReplace(711, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700115,''); // todox('Zusatz Error');
      RETURN false;
    end;
  END;

  // Kopf löschen...
  RecBufCopy(v700b, 700);
  RecRead(700,1,_recLock);
  BAG.Bemerkung     # Translate('exportiert nach BA')+' '+aint(v700a->BAG.Nummer);
  "BAG.Löschmarker" # '*';
  Erx # RekReplace(700,_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700116,cnvai(BAG.Nummer)) // ;todox('Kopf Error');
    RETURN false;
  end;


  // Protokolltext loopen und Aktionen etc. konvertieren...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=TextInfo(vTxt, _TextLines)) and (vErr='') do begin
    vA # TextLineRead(vTxt, vI, 0);

    if (StrFind(vA,'MATBB|',0)>0) then begin
      Mat.Nummer      # cnvia(Str_Token(vA,'|',2));
      vAkt # Str_Token(vA,'|',3);
      BAG.IO.Nummer   # cnvia(Str_Token(vA,'|',4));
      BAG.IO.Id       # cnvia(Str_Token(vA,'|',5));
      FOR Erx # RecLink(202, 200, 12, _recfirst)
      LOOP Erx # RecLink(202, 200, 12, _recNext)
      WHILE (Erx<=_rLocked) and (vErr='') do begin
        if ("Mat.B.Trägertyp"=vAkt) and
            ("Mat.B.TrägerNummer1"=BAG.IO.Nummer) and
            ("Mat.B.TrägerNummer2"=BAG.IO.ID) then begin

          vAkt # Str_Token(vA,'|',6);
          vJ # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.ID)+':');
          if (vJ=0) then begin
            vErr # 'MatBestandsbuch';
            BREAK;
          end;
          vA # TextLineRead(vTxt, vJ, 0);
          BAG.IO.Nummer    # aBAG1;
          BAG.IO.ID        # cnvia(Str_Token(vA,':',2));

          Erx # RecRead(202, 1, _recLock);
          "Mat.B.Trägernummer1" # BAG.IO.Nummer;
          "Mat.B.Trägernummer2" # BAG.IO.ID;
          Mat.B.Bemerkung       # vAkt+' '+AInt(BAG.IO.Nummer)+'/'+AInt(BAG.IO.ID);
          Erx # RekReplace(202);
          if (Erx<>_rOK) then vErr # 'MatBestandsbuch';
          BREAK;
        end;
      END;
    end
    else if (StrFind(vA,'MATAKT|',0)>0) then begin
      Mat.Nummer # cnvia(Str_Token(vA,'|',2));
      "Mat~Nummer" # cnvia(Str_Token(vA,'|',3));
      vAkt # Str_Token(vA,'|',4);
      BAG.P.Nummer # cnvia(Str_Token(vA,'|',5));
      BAG.P.Position # cnvia(Str_Token(vA,'|',6));

      // Mat-Aktion konvertieren...
      FOR Erx # RecLink(204,200,14,_recFirst)
      LOOP Erx # RecLink(204,200,14,_recNext)
      WHILE (Erx<=_rLocked) and (vErr='') do begin
        if (Mat.A.Entstanden="Mat~Nummer") and (Mat.A.Aktionstyp=vAkt) and
          (Mat.A.Aktionsnr=BAG.P.Nummer) and (Mat.A.Aktionspos=BAG.P.Position) and
          (Mat.A.Aktionspos2=0) then begin
          vJ # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.P.Position)+':');
          if (vJ=0) then begin
            vErr # 'MatAktion';
            BREAK;
          end;
          vA # TextLineRead(vTxt, vJ, 0);
          vA # Str_Token(vA,':',2)
          BAG.P.Nummer     # aBAG1;
          BAG.P.Position   # cnvia(vA);
          RecRead(204,1,_recLock);
          Mat.A.Aktionsnr   # BAG.P.Nummer;
          Mat.A.Aktionspos  # BAG.P.Position;
          Erx # RekReplace(204);
          if (erx<>_rOK) then vErr # 'MatAktions';
        end;
      END;

    end
    else if (StrFind(vA,'AUFAKT|',0)>0) then begin
      RecBufClear(404);
      Auf.A.Nummer      # cnvia(Str_Token(vA,'|',2));
      Auf.A.Position    # cnvia(Str_Token(vA,'|',3));
      Auf.A.Aktionstyp  # Str_Token(vA,'|',4);
      Auf.A.Aktionsnr   # cnvia(Str_Token(vA,'|',5));
      Auf.A.AktionsPos  # cnvia(Str_Token(vA,'|',6));
      Auf.A.AktionsPos2 # cnvia(Str_Token(vA,'|',7));
      Erx # RecRead(404,6,0);
      if (Erx<=_rMultikey) then begin
        vJ # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(Auf.A.AktionsPos)+':');
        if (vJ=0) then begin
          vErr # 'AufAktion';
          BREAK;
        end;
        vA # TextLineRead(vTxt, vJ, 0);
        BAG.P.Position   # cnvia(Str_Token(vA,':',2));
        BAG.P.Nummer     # aBAG1;
        RecRead(404,1,_recLock);
        Auf.A.Aktionsnr   # BAG.P.Nummer;
        Auf.A.Aktionspos  # BAG.P.Position;
        Erx # RekReplace(404);
        if (Erx<>_rOK) then vErr # 'AufAktion';
      end;
    end;

    if (vErr<>'') then BREAK;
  END;

  if (vErr<>'') then begin
    TRANSBRK;
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);


    Error(700117,vErr); // todox(vErr);
    RETURN false;
  end;


  TRANSOFF;

  APPON();

  RecBufCopy(v700a, 700);

//TextWrite(vTxt,'E:\debug\debug.txt',_TextExtern);
  Textclose(vTxt);

  RecBufDestroy(v700a);
  RecBufDestroy(v700b);
  RETURN true;
end;
***/


//========================================================================
// Call BA1_Data:CheckLauf.Autoteilung
// prüft bei alle offenen BA-Positionen, ob Autoteilungszahl stimmt
//========================================================================
SUB CheckLauf.Autoteilung()
local begin
  Erx     : int;
  vProto  : int;
  vKGMM1  : float;
  vKGMM2  : float;
  vTLG    : int;
end;
begin

  vProto # TextOpen(20);
  TextAddLine(vProto,'[LAUF START]');

  FOR Erx # RecRead(702,1,_recFirst)
  LOOP Erx # RecRead(702,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("BAG.P.Löschmarker"<>'') then CYCLE;
    Erx # RecLink(700,702,1,_recFirst);   // Kopf holen
    if (Erx>_rLocked) or (BAG.VorlageYN) then CYCLE;

    FOR Erx # RecLink(701,702,2,_recFirst)    // Inputs loopen
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.VonFertigmeld<>0) then CYCLE;
      if (BAG.IO.AutoTeilungYN=false) then CYCLE;

      vKGMM1 # 0.0;
      vKGMM2 # 0.0;
      // kgmm-Testen...
      if (BA1_IO_Data:KGMMMinMaxBestimmen(var vKGMM1, var vKGMM2)=false) then begin
        TextAddLine(vProto,'Input '+aint(BAG.IO.Nummer)+'/'+aint(BAG.IO.NachPosition)+'/'+aint(BAG.IO.ID)+' : KgMM-Bestimmung fehlgeschlagen');
      end
      else begin
        vTLG # BA1_IO_Data:TeilungVonBis(vKGMM1, vKGMM2);
        if (vTLG<0) then begin
          TextAddLine(vProto,'Input '+aint(BAG.IO.Nummer)+'/'+aint(BAG.IO.NachPosition)+'/'+aint(BAG.IO.ID)+' : Teilung erriecht KgMM-Vorgabe nicht');
        end
        else if (vTlg<>BAG.IO.Teilungen) then begin
          TextAddLine(vProto,'Input '+aint(BAG.IO.Nummer)+'/'+aint(BAG.IO.NachPosition)+'/'+aint(BAG.IO.ID)+' : Sollte '+aint(vTlg)+' mal teilen; ist aber '+aint(BAG.IO.Teilungen));
        end;
      end

    END;

  END;

  TextAddLine(vProto,'[LAUF ENDE]');

  // Ausgabe des Protokolls...
  TextDelete(myTmpText,0);
  TextWrite(vProto,MyTmpText,0);
  TextClose(vProto);
  Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll');
  TextDelete(myTmpText,0);

end;


//========================================================================
//========================================================================
SUB ErzeugeVorlageAusBA(aNr : int) : int
local begin
  Erx         : int;
  vVorlage    : int;
  vTheoID     : int;
  vName       : alpha;
  vName2      : alpha;
  vKGMM_Kaputt  : logic;
  vFirst      : logic;
end;
begin

  BAG.Nummer # aNr;
  Erx # RecRead(700,1,0);   // BA holen
  if (Erx>_rLocked) or (BAG.VorlageYN) then begin
    Msg(700017,'',0,0,0);
    RETURN 0;
  end;

  TRANSON;

  vVorlage # Lib_Nummern:ReadNummer('Betriebsauftrag-Vorlage')
  if (vVorlage<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN 0;
  end;

  RecBufClear(700);
  BAG.Nummer        # vVorlage;
  BAG.Bemerkung     # Translate('Vorlage-BA aus')+' '+aint(aNr);
  BAG.VorlageYN     # true;

//  RunAFX('BA1.LohnSubs.BAGVorlageDaten',Aint(aAufNr) + '/'+Aint(aAufPos));
  BAG.Anlage.Datum  # Today;
  BAG.Anlage.Zeit   # Now;
  BAG.Anlage.User   # gUserName;
  Erx # RekInsert(700,0,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RETURN 0;
  end;

  BAG.Nummer # aNr;

  FOR Erx # RecLink(704,700,2,_RecFirst)   // Verpackungen loopen
  LOOP Erx # RecLink(704,700,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    BAG.Vpg.Nummer # vVorlage;
    Erx # RekInsert(704,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.vpg.Nummer # aNr;
    RecRead(704,1,0);
  END;


  // Positionen kopieren.......
  FOR Erx # RecLink(702,700,1,_recFirst)     // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Typ.VSBYN) and (BAG.P.Kommission<>'') then begin
      BAG.P.Kommission    # '';
      BAG.P.Auftragsnr    # 0;
      BAG.P.AuftragsPos   # 0;
      BAG.P.Auftragspos2  # 0;
      Erx # RecLink(828,702,8,_recFirst);  // Arbeitsgang holen
      BAG.P.Bezeichnung   # ArG.Bezeichnung
    end;

    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    vName2  # '~702.'+CnvAI(vVorlage,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    TxtCopy(vName,vName2,0);
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    vName2  # '~702.'+CnvAI(vVorlage,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    TxtCopy(vName,vName2,0);

    BAG.P.Nummer          # vVorlage;
    BAG.P.Fertig.Dat      # 0.0.0;
    BAG.P.Fertig.User     # '';
    BAG.P.Fertig.Zeit     # 0:0;
    BAG.P.Fenster.MaxDat  # 0.0.0;
    BAG.P.Fenster.MaxZei  # 0:0;
    BAG.P.Fenster.MinDat  # 0.0.0;
    BAG.P.Fenster.MinZei  # 0:0;
    BAG.P.Plan.StartDat   # 0.0.0;
    BAG.P.Plan.StartZeit  # 0:0;
    BAG.P.Plan.EndDat     # 0.0.0;
    BAG.P.Plan.EndZeit    # 0:0;
    BAG.P.Auftragsnr      # 0;
    BAG.P.AuftragsPos     # 0;
    BAG.P.Auftragspos2    # 0;
    if (BAG.P.Kommission<>'') then
      BAG.P.Kommission    # '#';
    "BAG.P.Löschmarker"   # '';
    SetStatus(c_BagStatus_Offen);

    if (Set.Installname = 'BSC') then begin
      // ST 2021-09-13 Projekt 2298/17
       Call('SFX_ESK_Cut:CopyEskToBag',aNr, BAG.P.Position,true);
    end;

    Erx # BA1_P_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.P.Nummer # aNr;


    FOR Erx # RecLink(706,702,9,_RecFirst)   // Arbeitsschritte loopen
    LOOP Erx # RecLink(706,702,9,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      BAG.AS.Nummer # vVorlage;
      BAG.AS.Termin # 0.0.0;
      BAG.AS.Zeit   # 0:0;
      Erx # RekInsert(706,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN 0;
      end;
      BAG.AS.Nummer # aNr;
      RecRead(706,1,0);
    END;

  END;  // Positionen


  FOR Erx # RecLink(701,700,3,_recFirst)    // InOut loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.VonFertigmeld<>0) then CYCLE;

    BAG.IO.Nummer   # vVorlage;
    if (BAG.IO.VonBAG=aNr) then
      BAG.IO.VonBAG  # vVorlage;
    if (BAG.IO.NachBAG=aNr) then
      BAG.IO.NachBAG  # vVorlage;

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      BAG.IO.Materialtyp    # c_IO_Theo;
      BAG.IO.Materialnr     # 0;
      BAG.IO.MaterialRstNr  # 0;
      BAG.IO.Versandpoolnr  # 0;
      BAG.IO.Ist.In.GewB    # 0.0;
      BAG.IO.Ist.In.GewN    # 0.0;
      BAG.IO.Ist.In.Menge   # 0.0;
      BAG.IO.Ist.In.Stk     # 0;
      BAG.IO.Ist.Out.GewB   # 0.0;
      BAG.IO.Ist.Out.GewN   # 0.0;
      BAG.IO.Ist.Out.Menge  # 0.0;
      BAG.IO.Ist.Out.Stk    # 0;
    end;
    BAG.IO.Auftragsfert   # 0;
    BAG.IO.Auftragsnr     # 0;
    BAG.IO.Auftragspos    # 0;
    BAG.IO.GesamtKostW1   # 0.0;

    BAG.IO.Anlage.Datum  # Today;
    BAG.IO.Anlage.Zeit   # Now;
    BAG.IO.Anlage.User   # gUserName;
    Erx # BA1_IO_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.IO.Nummer # aNr;
  END;


  FOR Erx # RecLink(703,700,6,_recFirst)    // Fertigungen loopen
  LOOP Erx # RecLink(703,700,6,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 20.06.2016 AH:
    FOR Erx # RecLink(705,703,8,_RecFirst)  // Ausführungen kopieren
    LOOP Erx # RecLink(705,703,8,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      BAG.AF.Nummer # vVorlage;
      Erx # RekInsert(705,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN 0;
      end;
      BAG.AF.Nummer # aNr;
    END;


    BAG.F.Nummer # vVorlage;
    if (BAG.F.Kommission<>'') then begin
      BAG.F.Kommission # '#';
    end;
    BAG.F.Auftragsnummer    # 0;
    BAG.F.Auftragspos       # 0;
    BAG.F.AuftragsFertig    # 0;
    BAG.F.KundenArtNr       # '';
    "BAG.F.ReservFürKunde"  # 0;
    BAG.F.Fertig.Gew        # 0.0;
    BAG.F.Fertig.Menge      # 0.0;
    BAG.F.Fertig.Stk        # 0;
    BAG.F.zuVersand         # 0;
    BAG.F.zuVersand.Pos     # 0;

    BAG.F.Anlage.Datum      # Today;
    BAG.F.Anlage.Zeit       # Now;
    BAG.F.Anlage.User       # gUserName;

    Erx # RekInsert(703,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;

    BAG.F.Nummer # aNr;
  END;

  BAG.Nummer # vVorlage;
  RecRead(700,1,0);

  Erx # RecLink(702,700,4,_recFirst);     // Positionen loopen
  if (Erx<=_rLocked) then begin
    FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (vFirst=false) then begin
        if (BA1_IO_Data:Autoteilung(var vKGMM_Kaputt)=false) then begin
//debugx('aua');
        end;
        vFirst # true;
      end;

      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      end;
    END;
  end;


  FOR Erx # RecLink(701,700,3,_recFirst)  // IO loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) and (vTheoID>=0) do begin
    if (BAG.IO.Materialtyp=c_IO_Theo) and (BAG.IO.NachPosition<>0) then begin
      if (vTheoID=0) then vTheoID # BAG.IO.ID;
      else vTheoID # -1;
    end;
  END;

  RecLink(702,700,1,_recFirsT); // 1. Position holen
  if (vTheoID<0) then begin
    BAG.P.Position # 0;
    vTheoID # 0;
  end;

  TRANSOFF;

  RETURN vVorlage;
end;


//========================================================================
//  CopyBA    +ERR
//========================================================================
SUB CopyBA(
  aVon        : int;
  aMengenFakt : float) : int
local begin
  Erx               : int;
  v700              : int;
  vNeueNr           : int;

  vTheoID           : int;
  vName             : alpha;
  vName2            : alpha;
  vKGMM_Kaputt      : logic;
  vFirst            : logic;

  vNeuePos          : int;
  vNeueFert         : int;
  vNeueID           : int;

  vOK               : logic;
  vI                : int;
  vA                : alpha;
  vBinNS            : logic;
  vStartPos         : int;
  vTmpBuchungsAlgNr : int;
end;
begin

  BAG.Nummer # aVon;
  Erx # RecRead(700,1,0);   // BA holen
  vTmpBuchungsAlgNr # BAG.BuchungsAlgoNr; //[+] MR 12.07.22 Fix damit die BuchungsAlgoNr nicht auf 0 steht
  if (Erx>_rLocked)  then begin
    Error(99,'Falscher BA-Typ');
    RETURN 0;
  end;

  // Prüfungen ------------------------------------------
  FOR Erx # RecLink(701,700,3,_recFirst)    // InOut loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialtyp<>c_IO_Mat) and
      (BAG.IO.Materialtyp<>c_IO_Theo) and (BAG.IO.Materialtyp<>c_IO_Beistell) and (BAG.IO.Materialtyp<>c_IO_BAG) then begin
      Error(99,'Falscher Inputtyp '+aint(BAG.IO.Materialtyp));
      RETURN 0;
    end;
  END;

  TRANSON;

  if (BAG.VorlageYN) then
    vNeueNr # Lib_Nummern:ReadNummer('Betriebsauftrag-Vorlage')
  else
    vNeueNr # Lib_Nummern:ReadNummer('Betriebsauftrag');
  if (vNeueNr<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN 0;
  end;

  v700 # RekSave(700);
  RecBufClear(700);
  BAG.Nummer          # vNeueNr;
  BAG.BuchungsAlgoNr  # vTmpBuchungsAlgNr; // [+] MR 12.07.22 Fix damit die BuchungsAlgoNr nicht auf 0 steht
  BAG.Bemerkung       # v700->BAG.Bemerkung;
  BAG.VorlageYN       # v700->BAG.VorlageYN;
  RecBufDestroy(v700);

  "BAG.Lösch.Datum" # 0.0.0;
  "BAG.Lösch.User"  # '';
  "BAG.Lösch.Zeit"  # 0:0;
  "BAG.Löschmarker" # '';
  BAG.Fertig.Datum  # 0.0.0;
  BAG.Fertig.User   # '';
  BAG.Fertig.Zeit   # 0:0;
  BAG.Anlage.Datum  # Today;
  BAG.Anlage.Zeit   # Now;
  BAG.Anlage.User   # gUserName;
  Erx # RekInsert(700,0,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RETURN 0;
  end;

  BAG.Nummer # aVon;

  // Verpackungen kopieren
  FOR Erx # RecLink(704,700,2,_RecFirst)   // Verpackungen loopen
  LOOP Erx # RecLink(704,700,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    BAG.Vpg.Nummer # vNeueNr;
    BAG.Vpg.Verpackung  # BAG.Vpg.Verpackung;
    Erx # RekInsert(704,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.vpg.Nummer # aVon;
    BAG.Vpg.Verpackung  # BAG.Vpg.Verpackung;
    RecRead(704,1,0);
  END;


  // POSITIONEN kopieren -----------------------------------------------
  vNeuePos # 0;
  FOR Erx # RecLink(702,700,1,_recFirst)     // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    vNeuePos # BAG.P.Position;

    // Texte kopieren 20.01.2016:
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    vName2  # '~702.'+CnvAI(vNeueNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    TxtCopy(vName,vName2,0);
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    vName2  # '~702.'+CnvAI(vNeueNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    TxtCopy(vName,vName2,0);

    BAG.P.Nummer    # vNeueNr;
    BAG.P.Position  # BAG.P.Position;
// 08.04.2022 AH
//    if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
//      SetStatus(c_BagStatus_Offen);
//    if ("BAG.P.Löschmarker"<>'') then
//      SetStatus(c_BagStatus_fertig);
    "BAG.P.Löschmarker" # '';
    SetStatus(c_BagStatus_Offen);
    BAG.P.Fertig.Dat    # 0.0.0;
    BAG.P.Fertig.User   # '';
    BAG.P.Fertig.Zeit   # 0:0;

    if (Set.Installname = 'BSC') then begin
      // ST 2021-09-13 Projekt 2298/17
      Call('SFX_ESK_Cut:CopyEskToBag', aVon, BAG.P.Position,true);
    end;

    Erx # BA1_P_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.P.Nummer    # aVon;
    BAG.P.Position  # BAG.P.Position;


    FOR Erx # RecLink(706,702,9,_RecFirst)   // Arbeitsschritte loopen
    LOOP Erx # RecLink(706,702,9,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      BAG.AS.Nummer # vNeueNr;
      BAG.AS.Position # BAG.AS.Position;
      Erx # RekInsert(706,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN 0;
      end;
      BAG.AS.Nummer   # aVon;
      BAG.AS.Position # BAG.AS.Position;
      RecRead(706,1,0);
    END;


    // FERTIGUNGEN ------------------------------------------------------
    FOR Erx # RecLink(703,702,4,_recFirst)    // Fertigungen loopen
    LOOP Erx # RecLink(703,702,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      vOK # BA1_Vorlage:_CopyBAFert(vNeueNr, vNeuePos, BAG.F.Fertigung, 0,0, BAG.F.Streifenanzahl, BAG.F.Breite, true );
      if (vOK=false) then begin
        TRANSBRK;
        RETURN 0;
      end;
    END;  // Fertigungen

  END;  // Positionen


  FOR Erx # RecLink(701,700,3,_recFirst)    // InOut loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 08.04.2022 AH : echte FMs auslassen
    if (BAG.IO.VonFertigmeld<>0) then CYCLE;
    
    BAG.IO.Nummer   # vNeueNr;
    BAG.IO.ID       # BAG.IO.ID;

    if (BAG.IO.VonBAG=aVon) then begin
      BAG.IO.VonBAG       # vNeueNr;
      BAG.IO.VonPosition  # BAG.IO.VonPosition;
      if (BAG.IO.VonID<>0) then
        BAG.IO.VonID # BAG.IO.VonID;
    end;
    if (BAG.IO.NachBAG=aVon) then begin
      BAG.IO.NachBAG        # vNeueNr;
      BAG.IO.NachPosition   # BAG.IO.NachPosition;
      if (BAG.IO.NachID<>0) then
        BAG.IO.NachID         # BAG.IO.NachID;
    end;
    if (BAG.IO.UrsprungsID<>0) then
      BAG.IO.UrsprungsID # BAG.IO.UrsprungsID;
    if (BAG.IO.BruderID<>0) then
      BAG.IO.BruderID # BAG.IO.BruderID;


    BAG.IO.Anlage.Datum  # Today;
    BAG.IO.Anlage.Zeit   # Now;
    BAG.IO.Anlage.User   # gUserName;
    
    // 08.04.2022 AH: Reset
    if (BAG.IO.Materialnr<>0) then begin
      BAG.IO.Materialnr     # 0;
      BAG.IO.MaterialRstNr  # 0;
      BAG.IO.Materialtyp    # c_IO_Theo;
    end;
    
    BAG.IO.Ist.In.GewB    # 0.0;
    BAG.IO.Ist.In.GewN    # 0.0;
    BAG.IO.Ist.In.Menge   # 0.0;
    BAG.IO.Ist.In.Stk     # 0;
    BAG.IO.Ist.Out.GewB   # 0.0;
    BAG.IO.Ist.Out.GewN   # 0.0;
    BAG.IO.Ist.Out.Menge  # 0.0;
    BAG.IO.Ist.Out.Stk    # 0;

    // Entnahmen hochrechnen
    if (BAG.IO.VonBAG=0) then begin
      vStartPos # BAG.IO.NachPosition;
      if (BAG.IO.Materialtyp=c_IO_Theo) or (BAG.IO.Materialtyp=c_IO_Beistell) then begin
//        BAG.IO.Breite         # (aAnzVS * aBVS) + (aRestAnzVS * aRestBVS);
        BAG.IO.Plan.In.GewB   # Rnd(BAG.IO.Plan.In.GewB * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.In.GewN   # Rnd(BAG.IO.Plan.In.GewN * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.In.Menge  # Rnd(BAG.IO.Plan.In.Menge * aMengenFakt, Set.Stellen.Menge);
        BAG.IO.Plan.Out.GewB  # Rnd(BAG.IO.Plan.Out.GewB * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.Out.GewN  # Rnd(BAG.IO.Plan.Out.GewN * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.Out.Meng  # Rnd(BAG.IO.Plan.Out.Meng * aMengenFakt, Set.Stellen.Menge);
        if (BAG.IO.Materialtyp=c_IO_Beistell) then begin
          BAG.IO.Plan.In.Stk  # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.In.Stk) * aMengenFakt));
          BAG.IO.Plan.Out.Stk # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.Out.Stk) * aMengenFakt));
        end;
        if (BAG.IO.MEH.In='Stk') then
          BAG.IO.Plan.In.Menge  # cnvfi(BAG.IO.Plan.In.Stk);
        if (BAG.IO.MEH.Out='Stk') then
          BAG.IO.Plan.Out.Meng  # cnvfi(BAG.IO.Plan.Out.Stk);
      end;
    end;
    Erx # BA1_IO_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;

    vNeueID # BAG.IO.ID;

    BAG.IO.Nummer   # aVon;
    BAG.IO.ID       # BAG.IO.ID;
  END;

  BAG.Nummer # vNeueNr;
  RecRead(700,1,0);

  BAG.P.Nummer    # vNeueNr;
  BAG.P.Position  # vStartPos;
  Erx # RecRead(702,1,0);
  if (Erx<=_rLocked) then begin
    FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (vFirst=false) then begin
        if (BA1_IO_Data:Autoteilung(var vKGMM_Kaputt)=false) then begin
//debugx('aua');
        end;
        vFirst # true;
      end;
      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      end;
    END;
  end;


  FOR Erx # RecLink(701,700,3,_recFirst)  // IO loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) and (vTheoID>=0) do begin
    if (BAG.IO.Materialtyp=c_IO_Theo) and (BAG.IO.NachPosition<>0) then begin
      if (vTheoID=0) then vTheoID # BAG.IO.ID;
      else vTheoID # -1;
    end;
  END;

  RecLink(702,700,1,_recFirsT); // 1. Position holen
  if (vTheoID<0) then begin
    BAG.P.Position # 0;
    vTheoID # 0;
  end;

  FOR Erx # RecLink(702,700,1,_recFirst)     // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(702,1,_recLock);
    if (BA1_Laufzeit:Automatisch(y)) then begin
      BA1_P_Data:Replace(_recUnlock,'MAN');
      BA1_P_Data:UpdateAufAktion(n);
    end
    else begin
      RecRead(702,1,_recUnlock);
    end;
  END;

  TRANSOFF;

  RETURN vNeueNr;
end;


//========================================================================
//  Call BA1_Data:Repair_AllMarker
//========================================================================
Sub Repair_AllMarker()
local begin
  Erx : int;
end;
begin

  // alle BAs loopen
  FOR Erx # RecRead(700,1,_recFirst)
  LOOP Erx # RecRead(700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    BA1_Data:BerechneMarker();
  END;
  
  Msg(999998,'',0,0,0);
end;


//========================================================================
//  SetStatus
//========================================================================
SUB SetStatus(aStatus : alpha);
begin
  if (RunAFX('BAG.P.SetStatus',aStatus)=0) then
    BAG.P.Status # aStatus;
end;


/*========================================================================
2023-03-22  AH
  Call BA1_Data:RepairGluehen
  Stellt ALLE BAG.P. mit Glühen von "OBF" auf "GLUEH"
========================================================================*/
sub RepairGluehen
local begin
  Erx : int;
end;
begin
  FOR Erx # RecRead(702,1,_recFirst)
  LOOP Erx # RecRead(702,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.P.Aktion2='GLÜHEN') and (BAG.P.Aktion<>c_BAG_Gluehen) then begin
      RecRead(702,1,_recLock);
      BAG.P.Aktion # c_BAG_Gluehen;
      RekReplace(702);
    end;
  END;
  Msg(999998,'',0,0,0);
end;


//========================================================================
//========================================================================