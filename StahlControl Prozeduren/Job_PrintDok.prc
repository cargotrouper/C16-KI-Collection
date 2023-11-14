@A+
//==== Business-Control ==================================================
//
//  Prozedur    Job_PrintDok
//                OHNE E_R_G
//  Info
//    Startet eine Prozedur, welches Dokument im übergebenen Parameter ausdruckt
//
//
//  26.04.2010  HB  Erstellung der Prozedur
//  14.03.2022  AH  ERX
//
//
//  Subprozeduren
//
//========================================================================

@I:Def_Global

//========================================================================
//  PrintJobServer
//                  legt im Jobserver ein Job an, welches ein Dokument
//                  ausdrucken soll
//========================================================================
Sub PrintJobServer() : Logic;
local begin
  Erx       : int;
  vBelegNR  : alpha;
  vHdl      : int;
end;
begin
  // Kein direktdruck ->  also lokal drucken
/*
  if (Scr.B.2.DirektDrckYN = n) or (Scr.B.2.Drucker = '') then begin
    // Script ausdrucken
    Lib_Script:Cmd_Print();
    RETURN true;
  end;
*/
  case Scr.Name of
    '100/Eigentumsvorbehalt'  : vBelegnr # '100;' + Aint(Adr.Nummer);
    '200/Werkszeugnis'        : vBelegnr # '200;' + Aint(Mat.Nummer)   + ';' + AInt(Mat.Bestand.Stk) + ';' + ANum(Mat.Bestand.Gew,2);
    '400/Angebot'             : vBelegnr # '401;' + AInt(Auf.P.Nummer) + ';' + Aint(Auf.P.Position);
    '400/Auftragsbest'        : vBelegNr # '401;' + AInt(Auf.P.Nummer) + ';' + Aint(Auf.P.Position);
    '400/Vorablieferschein'   : vBelegNr # '401;' + AInt(Auf.P.Nummer) + ';' + Aint(Auf.P.Position);
    '440/Lieferschein'        : vBelegNr # '440;' + AInt(Lfs.Nummer);
    '450/Rechnung'            : vBelegnr # '450;' + Aint(Erl.Rechnungsnr) + '; ;401;' + AInt(Auf.P.Nummer) + ';' + Aint(Auf.P.Position);
    '500/Bestellung'          : vBelegnr # '501;' + Aint(Ein.P.Nummer) + ';' + Aint(Ein.P.Position);
    '650/Frachtbrief'         : vBelegnr # '650;' + Aint(Vsd.Nummer);
    '700/Deckblatt'           : vBelegnr # '700;' + Aint(BAG.Nummer);
    '700/Betriebsauftrag'     : begin
                                  vBelegnr # '702;' + Aint(BAG.P.Nummer) + ';' + Aint(BAG.P.Position);
                                  // Prüfen ob nur eine BA-Position ausgedruckt werden soll
                                  vHdl # $RL.Info.Pos->wpdbrecId;
                                  if (vHdl <> 0) then
                                    vBelegnr # vBelegnr + ';' + CnvAI($Rl.Info.Pos->wpDbRecId);
                                end;
    otherwise
      // Ansonsten Dokument lokal ausdrucken!
      begin
      Lib_Script:Cmd_Print();
      RETURN true;
    end;
  end;

  begin
    RecBufClear(905);                 // Job-Server-Job leeren
    Job.Aktion          # 'Job_PrintDok';
    Job.Parameter       # Aint(Scr.B.Nummer) + ';' + AInt(Scr.B.lfdNr) + ';' + vBelegNr;
    Job.Beschreibung    # 'Druckausgabe';
    Job.Start.Datum     # Today;
    Job.Start.Zeit      # Now;
    //Job.Resheduling
    //Job.LetzterLaufDatum
    //Job.LetzterLaufZeit
    //Job.LetzterLaufOKYN
    Job.Nummer # 100;
    REPEAT
      Job.Nummer # Job.Nummer + 1;
      Erx # RecRead(905,1,_RecTest);
    UNTIL (Erx>_rLocked);
    RekInsert(905,0,'MAN');
  end;

  RETURN true;
end;


//========================================================================
//  Main
//
//========================================================================
Main (aJobParameter : alpha;) : Logic;
local begin
  vToken         : alpha;
  vAnzahlStrings : int;
  i              : int;                  // Zähler

  vDatei1 : int;
  vNr1    : int;
  vPos1   : int;
  vDatei2 : int;
  vNr2    : int;
  vPos2   : int;
  vParameter : alpha;
end;
begin
  RecBufClear(920);
  RecBufClear(921);

  // Ermitteln wieviel Lieferschein geprüft werden müssen
  vAnzahlStrings # Lib_Strings:Strings_Count(aJobParameter,';') + 1;

  FOR i # 1 LOOP inc(i) WHILE (i <= vAnzahlStrings) DO BEGIN
    case i of
      1 : Scr.B.Nummer # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      2 : Scr.B.LfdNr  # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      3 : vDatei1      # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      4 : vNr1         # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      5 : vPos1        # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      6 : vDatei2      # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      7 : vNr2         # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      8 : vPos2        # CnvIA(Lib_Strings:Strings_Token(aJobParameter,';',i));
      9 : vParameter   # Lib_Strings:Strings_Token(aJobParameter,';',i);
    end;
  end;

  // Datei lesen
  case vDatei1 of
    // Adressstamm
    100 : begin
            Adr.Nummer # vNr1;
            RecRead(100,1,0);
          end;

    // Materialkarte
    200 : begin
            Mat.Nummer      # vNr1;
            RecRead(200,1,0);

            Mat.Bestand.Stk # vPos1;
            Mat.Bestand.Gew # CnvFI(vDatei2);
          end;

    // Auftrag lesen
    401 : begin
          Auf.Nummer     # vNr1;
          RecRead(400,1,0);

          Auf.P.Nummer   # vNr1;
          Auf.P.Position # vPos1;
          RecRead(401,1, 0);
        end;

    // Lieferscheine
    440 : begin
          Lfs.Nummer # vNr1;
          RecRead(440,1,0);
        end;

    // Erlöse
    450 : begin
          Erl.Rechnungsnr # vNr1;
          RecRead(450,1,0);

          Auf.P.Nummer   # vNr2;
          Auf.P.Position # vPos2;
          RecRead(401,1, 0);
        end;

    // Bestellung lesen
    501 : begin
          Ein.Nummer     # vNr1;
          RecRead(500,1,0);

          Ein.P.Nummer   # vNr1;
          Ein.P.Position # vPos1;
          RecRead(501,1, 0);
        end;

    // Versand / Frachtbrief
    650 : begin
          Vsd.Nummer # vNr1;
          RecRead(650,1, 0);
        end;

    // Betriebsauftrag
    700 : begin
          BAG.Nummer # vNr1;
          RecRead(700,1,0);
        end;

    // Betriebsauftrag Position
    702 : begin
          if (vDatei2 <> 0) then begin
            RecRead(702,0,_recid, vDatei2);
            GV.Alpha.20 # 'VBS BA EINZELDRUCK';
            GV.Int.01   # vDatei2;
          end
          else begin
            BAG.P.Nummer   # vNr1;
            BAG.P.Position # vPos1;
            RecRead(702,1,0);
          end;

          BAG.Nummer # vNr1;
          RecRead(700,1,0);
        end;

     otherwise RETURN true;
  end;

  RecRead(921,1,0); // Script lesen
  // Script ausdrucken
  Lib_Script:Cmd_Print();

  RETURN true;
end;

//========================================================================