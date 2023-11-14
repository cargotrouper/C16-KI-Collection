@A+
//===== Business-Control =================================================
//
//  Prozedur  Repair_Kal_P
//                OHNE E_R_G
//  Info
//
//
//  14.06.2013  ST  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB Del_KalP_ohne_Kal
//
//========================================================================
@I:Def_Global

//========================================================================
//  Del_KalP_ohne_Kal
//  Löscht Kalkulationspositionen ohne Kopf
//
//  call Repair_kal_p:Del_KalP_ohne_Kal
//========================================================================
SUB Del_KalP_ohne_Kal
local begin
  Erx         : int;
  vNrAbfrage  :  alpha;
end;
begin

  TRANSON;

  FOR   Erx # RecRead(831,1,_RecFirst)
  LOOP  Erx # RecRead(831,1,_RecNext)
  WHILE Erx = _rOK do begin
    // Postition geladen

    Kal.Nummer # Kal.P.Nummer;
    if (RecRead(830,1,0) <> _rOK) then begin

      vNrAbfrage # Aint(Kal.P.Nummer) + '/' + Aint(Kal.P.lfdNr);
      // Kopf nicht vorhanden, dann Position löschen
      if (RekDelete(831,0,'MAN') <> _rOK) then begin
        TRANSBRK;
        Msg(99,'Fehler beim Löschen der Position "'+vNrAbfrage+'". Vorgang abgebrochen.',_WinIcoError,_WinDialogOk,1);
        RETURN;
      end;

      Erx # RecRead(831,1,_RecPrev);
    end;

  END;

  TRANSOFF;

  Msg(99,'Kalkulationen erfolgreich repariert.',0,0,0);
end;


//========================================================================