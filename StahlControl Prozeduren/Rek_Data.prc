@A+
/*===== Business-Control =================================================

Prozedur:   Rek_Data

OHNE E_R_G

Info:
Funktionen für Rekalamationen

Historie:
2023-05-19  AH  Erstellung der Prozedur

Subprozeduren:
  SUB Rek_data:FixKdLfNr
  
========================================================================*/
@I:Def_Global

/*========================================================================
Defines
========================================================================*/
define begin
end

/*========================================================================
2023-05-19  AH                                              Proj. 2466/17
  repariert in den Rek.Pos. die Kd/LfNumer aus dem Kopf
  
call Rek_data:FixKdLfNr
========================================================================*/
sub FixKdLfNr()
local begin
  Erx         : int;
end
begin
  // Rek-Köpfe loopen...
  FOR Erx # RecRead(300,1,_recFirst)
  LOOP Erx # RecRead(300,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
if (Rek.Kundennr=0) and (Rek.Lieferantennr=0) then begin
Msg(99,'Rek'+aint(Rek.Nummer)+' hat GAR keine Adresse!',0,0,0);
CYCLE;
end;

    // Positionen loopen...
    FOR Erx # RecLink(301,300,1,_recFirst)
    LOOP Erx # RecLink(301,300,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Rek.P.Kundennr<>Rek.Kundennr) or (Rek.P.Lieferantennr<>Rek.Lieferantennr) then begin
        RecRead(301,1,_recLock);
        Rek.P.Kundennr      # Rek.Kundennr;
        Rek.P.Lieferantennr # Rek.Lieferantennr;
        Rek.P.Stichwort     # Rek.Stichwort;
        RekReplace(301);
      end
    END;
    
  END;
  
end


//========================================================================