@A+
//===== Business-Control =================================================
//
//  Prozedur  Kas_Data
//                    OHNE E_R_G
//  Info
//
//
//  04.01.2013  AI  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//  sub RecalcBuch()
//  sub NeuesBuch(aNr : int; aBez : alpha; opt aVon : date; opt aBis : date; opt aStartSaldo : float) : logic;
//  sub DruckNeuesBuch();
//  sub Storno(aBuch : int) : logic
//
//========================================================================
@I:Def_Global

//========================================================================
//  RecalcBuch
//
//========================================================================
sub RecalcBuch()
local begin
  Erx     : int;
  v572    : int;
  vSaldo  : float;
  vEin    : float;
  vAus    : float;
end;
begin

  v572 # RekSave(572);

  vSaldo # Kas.B.Start.Saldo;

  FOR Erx # RecLink(572,571,2,_recFirst|_recLock)
  LOOP Erx # RecLink(572,571,2,_recNext|_RecLock)
  WHILE (Erx<=_rLocked) do begin
//    RecRead(572,1,_recLock);
    vSaldo  # vSaldo + Kas.B.P.Eingang - Kas.B.P.Ausgang;
    vEin    # vEin + Kas.B.P.Eingang;
    vAus    # vAus + Kas.B.P.Ausgang;
    Kas.B.P.Saldo # vSaldo;
    RekReplace(572,_recUnlock,'AUTO');
  END;

//  if (Kas.B.Ende.Datum=0.0.0) and
  if ((vSaldo<>Kas.B.Ende.Saldo) or
    (vEin<>Kas.B.Summe.Eingang) or
    (vAus<>Kas.B.Summe.Ausgang)) then begin
    RecRead(571,1,_recLock);
    Kas.B.Ende.Saldo # vSaldo;
    Kas.B.Summe.Eingang # vEin;
    Kas.B.Summe.Ausgang # vAus;
    RekReplace(571,_recunlock, 'AUTO');
  end;

  RekRestore(v572);

end;


//========================================================================
//  NeuesBuch
//
//========================================================================
sub NeuesBuch(
  aNr             : int;
  aBez            : alpha;
  opt aVon        : date;
  opt aBis        : date;
  opt aStartSaldo : float;
) : logic;
local begin
  Erx   : int;
  vAuto : logic;
end;
begin

  if (aNr=0) then begin
    vAuto # y;
    Erx # RecLink(571,570,1,_recLast);    // letztes Buch holen
    if (Erx>_rLocked) then aNr # 2
    else aNr # Kas.B.Nummer + 1;
  end;

  RecBufClear(571);
  Kas.B.Kassennr      # Kas.Nummer;
  Kas.B.Nummer        # aNr;
  Kas.B.Bezeichnung   # aBez;
  Kas.B.Start.Datum   # aVon;
  Kas.B.Ende.Datum    # aBis;
  Kas.B.Start.Saldo   # aStartSaldo;

  Kas.B.Anlage.Datum  # Today;
  Kas.b.Anlage.Zeit   # Now;
  Kas.b.Anlage.User   # gUserName;
  REPEAT
    Erx # RekInsert(571,1,'AUTO');
    if (vAuto) and (Erx<>_ROK) then begin
      Kas.B.Nummer # Kas.B.Nummer + 1;
    end;
  UNTIL (vAuto=n) or (Erx=_rOK);

  RETURN (Erx=_rOK);
end;


//========================================================================
//  DruckNeuesBuch
//
//========================================================================
sub DruckNeuesBuch();
local begin
  Erx     : int;
  vName   : alpha;
  vBis    : date;
  vVon    : date;
  vStartS : float;
  vSaldo  : float;
  v571    : int;
  vOK     : logic;
  vBuch   : int;
  vPos    : int;
end
begin

  // Zeitraum abfragen...
  if (Dlg_Standard:Datum(Translate('Enddatum'),var vBis)=false) then RETURN;

  vName # Lib_Berechnungen:Monat_aus_Datum(vBis)+' '+aint(vBis->vpyear);
  if (Dlg_Standard:Standard(Translate('Bezeichnung'),var vName)=false) then RETURN;
  vName # StrCut(vName, 1,64);
  if (vName='') then RETURN;



  v571 # RekSave(571);

  Kas.B.Kassennr  # Kas.Nummer;
  Kas.B.Nummer    # Kas.LetztesBuch;
  Erx # RecRead(571,1,0);
  if (Erx<=_rLocked) and (Kas.LetztesBuch>0) then begin
    vStartS # Kas.B.Ende.Saldo;
    vVon    # Kas.B.Ende.Datum;
    vVon->vmDayModify(1);
  end;

  RekRestore(v571);


  vSaldo # vSaldo + vStartS;
  FOR Erx # RecLink(572,571,2,_recFirst)
  LOOP Erx # RecLink(572,571,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Kas.B.P.Belegdatum<=vBis) then begin
      vOK # y;
      vSaldo # vSaldo + Kas.B.P.Eingang - Kas.B.P.Ausgang;
    end;
  END;

  if (vOK=false) then begin
    Msg(99,'nix gefunden!',0,0,0)
    RETURN;
  end;
  if (vSaldo<0.0) then begin
    Msg(99,'Der Saldo ist NEGATIV!!!',0,0,0)
    RETURN;
  end;

  TRANSON;

  v571 # RekSave(571);

  if (NeuesBuch(0, vName, vVon, vBis, vStartS)=false) then begin
    TRANSBRK;
    RekRestore(v571);
    Msg(99,'kein neues buch anlegbar !',0,0,0);
    RETURN;
  end;

  vBuch # Kas.B.Nummer;
  RekRestore(v571);

  vPos    # 1;
  vSaldo  # vStartS;
  Erx # RecLink(572,571,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Kas.B.P.Belegdatum<=vBis) then begin
      vSaldo # vSaldo + Kas.B.P.Eingang - Kas.B.P.Ausgang;
      RecRead(572,1,_recLock);
      Kas.B.P.Buchnr  # vBuch;
      Kas.B.P.LfdNr   # vPos;
      Erx # RekReplace(572,_recunlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(99,'copy failed!',0,0,0);
        RETURN;
      end;
      inc(vPos);
      Erx # RecLink(572,571,2,_recFirst);
      CYCLE;
    end;

    Erx # RecLink(572,571,2,_recNext);
  END;


  // aktuelles Buch anpassen
  RecRead(571,1,_recLock);
  Kas.B.Start.Saldo # vSaldo;
  Erx # RekReplace(571,_recunlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(99,'Buch nicht änderbar',0,0,0);
    RETURN;
  end;

  // Kasse anpassen...
  RecRead(570,1,_recLock);
  Kas.LetztesBuch # vBuch;
  Erx # RekReplace(570,_Recunlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(99,'Kasse nicht speicherbar!',0,0,0);
    RETURN;
  end;

  TRANSOFF;

  RecalcBuch();

  App_Main:Refresh();

  v571 # RekSave(571);
  Kas.B.Nummer # vBuch;
  RecRead(571,1,0);
  RecalcBuch();
  Lib_Dokumente:Printform(570,'Kassenbuch',false);
  RekRestore(v571);

end;


//========================================================================
//  Storno
//
//========================================================================
sub Storno(aBuch : int) : logic
local begin
  Erx   : int;
  vPos  : int;
  v571  : int;
end;
begin
  if (Kas.B.Ende.Datum=0.0.0) then RETURN true;
  if (Kas.B.Nummer<>Kas.LetztesBuch) then RETURN true;

  TRANSON;

  v571 # RekSave(571);
  Kas.B.Nummer # 1;
  Erx # RecLink(572,571,2,_recLast);
  if (Erx<=_rLocked) then vPos  # Kas.B.P.lfdNr + 1
  else vPos # 1;
  RekRestore(v571);

  // Posten loopen...
  WHILE (RecLink(572,571,2,_recFirst | _RecLock)<=_rLocked) do begin

    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(99,'copy failed!',0,0,0);
      RETURN false;
    end;

    Kas.B.P.Buchnr  # 1;
    REPEAT
      Kas.B.P.LfdNr   # vPos;
      Erx # RekReplace(572,_recunlock,'AUTO');
      if (erx<>_rOK) then vPos # vPos +1;
    UNTIL (Erx=_rOK);

  END;

  // Buch löschen...
  Erx # Rekdelete(571,_recunlock,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(1000+Erx,'',0,0,0);
    RETURN false;
  end;

  // Kopf anpassen...
  RecRead(570,1,_recLock);
  Kas.LetztesBuch # Kas.LetztesBuch - 1;
  if (Kas.LetztesBuch=1) then Kas.LetztesBuch # 0;
  Erx # RekReplace(570,_recunlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(1000+Erx,'',0,0,0);
    RETURN false;
  end;

  TRANSOFF;

  Kas.B.Nummer # 1;
  RecalcBuch();

  RefreshList(gZLList,_WinLstFromFirst);

  Msg(999998,'',0,0,0);
end;


//========================================================================