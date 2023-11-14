@A+
//===== Business-Control =================================================
//
//  Prozedur    Job_STD
//                  OHNE E_R_G
//  Info
//
//
//  23.03.2017  AH  Erstellung der Prozedur
//  24.08.2018  AH  "Sql_Init"
//  28.08.2018  AH  "EDI_AufAbrufImport"
//  14.03.2022  AH  ERX
//
//  Subprozeduren
//  job ERe_RealeKosten(aPara : alpha) : logic;
//
//========================================================================
@I:Def_Global

define begin
  dPath_Korrekt : 'Korrekt\'
  dPath_Defekt  : 'Fehlerhaft\'
end;


//========================================================================
sub JobError(
  aAktion : alpha;
  aText   : alpha(1000));
begin
  RecBufClear(908);
  Job.Err.Datum   # today;
  Job.Err.Zeit    # now;
  Job.Err.Aktion  # aAktion;
  Job.Err.Text    # StrCut(aText,1,64);
  RekInsert(908,0,'AUTO');
end;


//========================================================================
//  ERe_RealeKosten
//
//========================================================================
sub ERe_RealeKosten(opt aPara : alpha) : logic;
local begin
  Erx : int;
end;
begin

  RecBufClear(560);
  ERe.JobAusstehendJN # y;
  Erx # RecRead(560,7,0);
  WHILE (Erx<=_rMultikey) and (ERe.JobAusstehendJN) do begin

    if ("ERe.Löschmarker"='') and (ERe.InOrdnung) then begin    // 2022-07-18 AH nur aktive
       if (ERe_Data:RealeKostenVererben()=false) then begin
        JobError(ThisLine,'Kosten nicht vererbbar: ERe'+aint(Ere.Nummer));
        RETURN false;
      end;
      RecRead(560,1,_RecLock);
      ERe.JobAusstehendJN # false;
      if (RekReplace(560)<>_rOK) then RETURN false;

      RecBufClear(560);
      ERe.JobAusstehendJN # y;
      Erx # RecRead(560,7,0);
      CYCLE
    end;

    RecRead(560,7,_recNext);
  END;

  RETURN true;
end;


//========================================================================
//  SQL_Init
//========================================================================
sub SQL_Init(opt aPara : alpha) : logic;
begin

  // SILENT
  if ( Lib_Odbc:FirstScript(true)) then begin
    if (Lib_Odbc:FirstSync(true)) then begin
      RecDeleteAll(997);
      RecbufClear(997);
      RecDeleteAll(992);
    end;
  end;

  RETURN true;
  
end;


//========================================================================
//  Job_STD:EDI_AufAbrufImport
//========================================================================
sub EDI_AufAbrufImport(
  aPara   : alpha
) : logic;
local begin
  vHdl        : int;
  vFilename   : alpha(1000);
end;
begin

  if (StrCut(aPara,StrLen(aPara),1)<>'\') then aPara # aPara + '\';

  // Lesen aller .xml-Dateien im aktuellen Verzeichnis
  vHdl # FsiDirOpen(aPara+'*.xml',_FsiAttrHidden);
  vFileName # vHdl->FsiDirRead(); // erste Datei
  WHILE (vFileName<>'') do begin

    // Datei Impoprtieren
    if (EDI_AufAbrufe:ProcessFile(aPara+vFileName)) then begin
      // alles i.O.
      if (dPath_Korrekt='') then
        FsiDelete(aPara + vFileName)
      else
        Lib_FileIO:FsiCopy(aPara + vFileName, aPara + dPath_Korrekt + vFileName, y);    // MOVE
    end
    else begin
      // Fehler
      Lib_FileIO:FsiCopy(aPara + vFileName, aPara + dPath_defekt + vFileName, y);       // MOVE
    end;
    vFileName # vHdl->FsiDirRead();
  END;
  vHdl->FsiDirClose();

  RETURN true;
end;


//========================================================================