@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Initialize
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  28.02.2014  AH  TAPI in Terminalsitzung erkennt ClientNamen
//
//  Subprozeduren
//    SUB ReadIni()
//    SUB SaveIni()
//========================================================================
@I:Def_Global

//========================================================================
//  ReadIni
//            Holt sich ggf. die Rechnereinsellungen
//========================================================================
sub ReadIni()
local begin
  vBuf  : int;
  vHdl  : int;
  vName : alpha;
  vX    : int;
  vA    : alpha;
  vB    : alpha;
  vComp : alpha(200);
end;

begin
  vName # 'INI';

  vComp # UserInfo(_UserSysName,CnvIA(UserInfo(_UserCurrent)));
  if (_Sys->spTerminalSession) then vCOmp # NetInfo(_NtiNameTSC);


  // Text anlegen, falls bisher nicht vorhanden
  TxtCreate(vName, 0);

  //Text laden
  vBuf # Textopen(10);
  vBuf->TextRead(vName, 0);

  // Block suchen
  vX # TextSearch(vBuf, 1, 1, _TextSearchtoken, '<Computer name='+vComp+'>');
  if (vX<>0) then begin
    vX # vX + 1;

    // TAPI
    vA # TextLineRead(vBuf, vX, 0);
    vB # StrCut(vA, StrFind(vA,'TAPI=',1)+5, 99);
    if (vB<>'') then
      Set.TAPI.Name # vB;
    vX # vX + 1;

    // TAPIPrefix
    vA # TextLineRead(vBuf, vX, 0);
    vB # StrCut(vA, StrFind(vA,'TAPIPrefix=',1)+11, 99);
    if (vB<>'') then
      Set.TAPI.Prefix # vB;
    vX # vX + 1;

    // Barcodescanner Port
    vA # TextLineRead(vBuf, vX, 0);
    vB # StrCut(vA, StrFind(vA,'BARCODESCANNERPORT=',1)+11, 99);
    if (vB<>'') then
      Set.BCScanner.Port # CnvIa(vB);
    vX # vX + 1;

  end;

  // Hauswährung holen
  RecRead(814,1,_RecFirst);
  "Set.Hauswährung.kurz" # "Wae.Kürzel";

  // Text beenden
  TextClose(vBuf);

end;


//========================================================================
//  SaveIni
//              Speichert die Rechnerdaten ab
//========================================================================
sub SaveIni()
local begin
  vBuf  : int;
  vHdl  : int;
  vName : alpha;
  vX    : int;
  vComp : alpha(200);
end;

begin
  vName # 'INI';

  vComp # UserInfo(_UserSysName,CnvIA(UserInfo(_UserCurrent)));
  if (_Sys->spTerminalSession) then vComp # NetInfo(_NtiNameTSC);

  // Text anlegen, falls bisher nicht vorhanden
  TxtCreate(vName, 0);

  //Text laden
  vBuf # Textopen(10);
  vBuf->TextRead(vName, 0);

  // alten Block löschen
  vX # TextSearch(vBuf, 1, 1, _TextSearchtoken, '<Computer name='+vComp+'>');
  if (vX<>0) then begin
    WHILE (TextLineRead(vBuf, vX, _TextLineDelete)<>'</Computer>') do begin
    END;
  end;

  //neuen Block anlegen
  TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, '<Computer name='+vComp+'>', _TextLineInsert);
  TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, 'TAPI='+Set.TAPI.Name, _TextLineInsert);
  TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, 'TAPIPrefix='+Set.TAPI.Prefix, _TextLineInsert);
  TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, 'BARCODESCANNERPORT='+CnvAi(Set.BCScanner.Port), _TextLineInsert);
  TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1,'</Computer>', _TextLineInsert);

  // Text sichern & beenden
  TxtWrite(vBuf, vName, _TextUnlock);
  TextClose(vBuf);
end;

//========================================================================