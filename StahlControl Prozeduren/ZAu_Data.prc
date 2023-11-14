@A+
//===== Business-Control =================================================
//
//  Prozedur  ZAu_Data
//                    OHNE E_R_G
//  Info
//
//
//  08.10.2012  AI  Erstellung der Prozedur
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//  SUB ConvertAltNachNeu()
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//  ConvertAltNachNeu
//
//========================================================================
sub ConvertAltNachNeu()
local begin
  Erx : int;
  vZ1 : int;
  vZ2 : int;
  vZ3 : int;
end;
begin

  Dlg_Standard:Anzahl('neue Nummer für "1=Bar"',var vZ1);
  if (vZ1=0) then begin
    Msg(99,'Abbruch!!!',0,0,0);
    RETURN;
  end;
  Dlg_Standard:Anzahl('neue Nummer für "2=Scheck"',var vZ2);
  if (vZ2=0) then begin
    Msg(99,'Abbruch!!!',0,0,0);
    RETURN;
  end;
  Dlg_Standard:Anzahl('neue Nummer für "3=Überweisung"',var vZ3);
  if (vZ3=0) then begin
    Msg(99,'Abbruch!!!',0,0,0);
    RETURN;
  end;

  if (vZ1=1) and (vZ2=2) and (vZ3=3) then begin
    Msg(99,'Keine Konvertierung nötig!',_WinIcoInformation,0,0);
    RETURN;
  end;

  FOR Erx # RecRead(565,1,_recFirst)
  LOOP Erx # RecRead(565,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (ZAu.Zahlungsart=1) or
      (ZAu.Zahlungsart=2) or
      (ZAu.Zahlungsart=3) then begin
      RecRead(565,1,_RecLock);
      if (ZAu.Zahlungsart=1) then ZAu.Zahlungsart # vZ1
      else
      if (ZAu.Zahlungsart=2) then ZAu.Zahlungsart # vZ2
      else
      if (ZAu.Zahlungsart=3) then ZAu.Zahlungsart # vZ3;
      Erx # RekReplace(565,_RecUnlock,'AUTO');
    end;
  END;

  Msg(99,'Konvertierung erfolgt!',_WinIcoInformation,0,0);
end;


//========================================================================