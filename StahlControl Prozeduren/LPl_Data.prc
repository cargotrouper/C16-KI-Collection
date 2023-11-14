@A+
//==== Business-Control ==================================================
//
//  Prozedur    LPl_Data
//                    OHNE E_R_G
//  Info        Enthält Verbuchungsfunktionen, Inventurfunktionen etc.
//
//
//  25.06.2012  ST  Erstellung der Prozedur
//  25.06.2012  ST  Erweiterung Inventurfunktionen laut Projekt 1326/246
//  20.09.2012  ST  Verwendung von Lib_Strings umgestellt
//  12.06.2013  ST  Anker "Lpl.Data.InvUebernehmen" bei Inventurverbuchung hinzugefügt
//  26.06.2013  ST  Anker "Lpl.Data.InvUebernehmenAll" bei Inventurverbuchung hinzugefügt
//  26.09.2017  ST  Bugfix bei Protokollausgabe
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//  SUB EndProtokoll(opt aShowProtokoll : logic)
//  SUB InvGetTextName(  aLpl  : alpha;): alpha
//  SUB InvGtInfoFromText(  aLpl  : alpha;): alpha
//  SUB InvFileCheck(  aLpl  : alpha;): int
//  SUB InvFileLoad(  aLplDest  : alpha;  opt aFile : alpha): logic
//  SUB InvFileLoadAll(  aLplDest  : alpha;  opt aFile : alpha): logic
//  SUB InvFileDelete(  aLpl  : alpha;): logic
//  SUB InvFileDeleteAll(): logic
//  SUB _InvVerbuchen_MarkInfo(): alpha
//  SUB InvVerbuchen(): logic
//  SUB InvVerbuchenAll(): logic
//  SUB InvUebernehmen(): logic;
//  SUB InvUebernehmenAll(): int;
//  SUB InvLoadDataCPT711(): alpha
//  SUB InvPrepare(aTxtName : alpha;  aCheckType : alpha;  aClearType : alpha;  aCheckVal : alpha;): logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

declare InvFileCheck(aLpl  : alpha;): int;
declare InvFileLoad(aLplDest : alpha; opt  aFile : alpha;): logic;
declare InvFileLoadAll(aLplDest : alpha; opt  aFile : alpha;): logic;
declare InvFileDelete(aLpl : alpha;): logic;
declare InvFileDeleteAll(): logic;
declare InvGetTextName( aLpl  : alpha;): alpha;
declare InvGetInfoFromText( aLpl  : alpha;): alpha;
declare InvVerbuchen(): logic
declare InvVerbuchenAll(): logic
declare InvUebernehmen( ): logic;
declare InvUebernehmenAll( ): int;
declare InvLoadDataCPT711() : alpha;
declare InvPrepare(  aTxtName : alpha;  aCheckType : alpha;  aClearType : alpha;  aCheckVal : alpha;): logic;

define begin
  cProtokoll    : GV.Int.11
  Proto(a)      : if (cProtokoll > 0) then TextAddLine(cProtokoll, a);
end;


//========================================================================
// sub EndProtokoll(opt aShowProtokoll : logic)
//    Beendet die Protollierung und zeigt auf Wunsch einen Fehlertext an
//    Erweiterung laut Projekt 1326/246: Speicherung des Protokolls im Clientordner
//========================================================================
sub EndProtokoll(opt aShowProtokoll : logic; opt aSave : logic)
local begin
  vSavePath  : alpha(4096);
  vSaveErx : int;
end
begin
  TxtDelete(myTmpText,0);
  TxtWrite(cProtokoll,MyTmpText,0);
  if (aSave) then begin
    vSavePath # Lib_FileIO:StampFilename('inventur');
    vSavePath # vSavePath  +  gUsername + '.txt';
    vSaveErx  # TxtWrite(cProtokoll,vSavepath, _TextExtern | _TextOEM);
    if (vSaveErx <> 0) then
      Msg(844024,vSavePath ,_WinIcoError,_WinDialogOk,1);

  end;

  TextClose(cProtokoll);

  if (aShowProtokoll) then
    Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll','',gFrmMain);

  TxtDelete(myTmpText,0);
end;


//========================================================================
// InvGetTextName
//          generiert den internen Textnamen für einen Lagerplatz
//========================================================================
sub InvGetTextName(
  aLpl  : alpha;
): alpha
local begin
  vTxtName : alpha;
end;
begin
  vTxtName # '~844.'+ StrCnv(StrAdj(aLpl,_StrAll),_StrUpper);
  vTxtName # Str_ReplaceAll(vTxtName,',','');

  if (StrLen(vTxtName) > 20) then begin
    // ST 2012-06-25: Längenabfrage
    // 844022 :  vA # 'E:Lagerplatz (%1%) konnte nicht gelesen werden! Der Name ist länger als 15 Zeichen.';
    Msg(844022,aLpl,_WinIcoError,_WinDialogOk,1);
    return '';
  end;

  return vTxtName;
end;


//========================================================================
// InvGetInfoFromText
//          generiert den internen Textnamen für einen Lagerplatz
//========================================================================
sub InvGetInfoFromText(
  aLpl  : alpha;
): alpha
local begin
  Erx     : int;
  vTxtName : alpha;
  vTxtBuf  : int;
  vReturnVal : alpha
end;
begin
  vReturnVal # '';
  vTxtName # InvGetTextName(aLpl);

  // Puffer erstellen
  vTxtBuf # TextOpen(10);
  Erx # TextRead(vTxtBuf,vTxtName,_TextNoContents);
  if (Erx = _rOK) then begin
    // Erstellungs Datum des Textes
    vReturnVal # CnvAd(TextInfoDate(vTxtBuf,_TextCreated));
    vReturnVal # vReturnVal + ' ';

    // Erstellungszeitpunkt des Textes
    vReturnVal # vReturnVal + CnvAt(TextInfoTime(vTxtBuf,_TextCreated));
  end;

  return vReturnVal;
end;


//========================================================================
// InvFileCheck
//          Überprüft, ob eine Inventurdatei schon exisiert
//========================================================================
sub InvFileCheck(
  aLpl  : alpha;
): int
local begin
  Erx       : int;
  vTxtBuf   : int;
  vTxtName  : alpha;
end;
begin

  // Puffer erstellen
  vTxtBuf # TextOpen(10);

  // Textnamen generieren
  vTxtName # InvGetTextName(aLpl);

  if (StrLen(vTxtName) <= 20) then begin

    // Prüfen ob File existiert
    Erx # TextRead(vTxtBuf,vTxtName,_TextNoContents);
    if (Erx = _rOK)  then
      RETURN 1    // Text vorhanden
    else
      RETURN 0;   // Text nicht vorhanden

  end else
      RETURN 2; // Name zu lang

end;

//========================================================================
// InvFileLoad
//          Läd eine Inventurdatei ein und speichert Sie als internen Text
//========================================================================
sub InvFileLoad(
  aLplDest  : alpha;
  opt aFile : alpha
): logic
local begin
  Erx     : int;
  vTmp    : int;
  vFile   : alpha;

  vTxtBuf  : int;
  vTxtName : alpha;
end;
begin

  // Wenn eine Datei angegeben wurde, dann keinen Auswahldialog anzeigen
  if (aFile = '') then begin

    // Dateidialog
    vTmp # WinOpen(_WinComFileopen,_WinOpenDialog);
    if (vTmp<>0) then begin
      vTmp->wpFileFilter # 'Inventurdatei|*.txt';
      if (vTmp->WinDialogRun(_WinDialogCenter) = _rOK) then begin
        vFile # StrAdj(vTmp->wpPathname+ vTmp->wpFileName,_StrEnd)
        WinClose(vTmp);
      end else begin
        WinClose(vTmp);
        return false;
      end;

    end;

  end else begin

    // Übergebene Datei als Quelle nehmen
    vFile # aFile;

  end;



  if (vFile<>'') then begin
    // Einlesen und Speichern

    // Puffer erstellen
    vTxtBuf # TextOpen(10);

    // Textnamen aufbauen
    vTxtName # InvGetTextName(aLplDest);

    Erx # TextRead(vTxtBuf,vFile,_TextExtern);
    if (Erx = _rOK)  then begin

      Erx # TxtWrite(vTxtBuf,vTxtName,0);
      if (Erx <> _rOK)  then
        RETURN false;

    end else
      RETURN false;

  end;


  // alles korrekt gelaufen
  RETURN true;
end;


//========================================================================
// InvFileLoadAll
//         Lädt eine Inventurdatei ein und speichert sie
//         pro Lagerplatz als separaten internen Text
//========================================================================
sub InvFileLoadAll(
  aLplDest  : alpha;
  opt aFile : alpha
): logic
local begin
  Erx   : int;
  vTmp : int;
  vFile : alpha;

  vTxtBuf1  : int;
  vTxtBuf2  : int;

  vTxtName   : alpha;
  vTxtName2  : alpha;

  i         : int;
  vLine     : alpha;
  vTyp      : alpha;
  vWert     : alpha;

end;
begin

  // Wenn eine Datei angegeben wurde, dann keinen Auswahldialog anzeigen
  if (aFile = '') then begin

    // Dateidialog
    vTmp # WinOpen(_WinComFileopen,_WinOpenDialog);
    if (vTmp<>0) then begin
      vTmp->wpFileFilter # 'Inventurdatei|*.txt';
      if (vTmp->WinDialogRun(_WinDialogCenter) = _rOK) then begin
        vFile # StrAdj(vTmp->wpPathname+ vTmp->wpFileName,_StrEnd)
        WinClose(vTmp);
      end else begin
        WinClose(vTmp);
        return false;
      end;


    end;

  end else begin

    // Übergebene Datei als Quelle nehmen
    vFile # aFile;

  end;



  if (vFile<>'') then begin
    // Einlesen und Speichern
    // Gesamten Text als internen Text übernehmen

    vTxtBuf1 # TextOpen(1);
    vTxtBuf2 # TextOpen(2);
    vTxtName # 'Inv';

    Erx # TextRead(vTxtBuf1,vFile,_TextExtern); // Externen Text einlesen

    if (Erx = _rOK)  then begin
      Erx # TxtWrite(vTxtBuf1,vTxtName,0);
      if (Erx <> _rOK)  then
        RETURN false;
      end
    else begin
      RETURN false;
    end;


    i # 1;
    WHILE (i <=  TextInfo(vTxtBuf1,_TextLines)) do begin
//debug('00_'+cnvai(i));

      vLine   # TextLineRead(vTxtBuf1,i,0);

      vTyp  # Lib_Strings:Strings_Token(vLine,'_',1);
      vWert # Lib_Strings:Strings_Token(vLine,'_',2);

      If (vTyp = 'ILP') then begin

//debug('01_'+ vTxtName2);

        if (i >1)  then begin

          Erx # TxtWrite(vTxtBuf2,vTxtName2,_TextUnlock);
          TextClear(vTxtBuf2);

        end;

        Lpl.Lagerplatz # vWert;
        Erx # RecRead(844,1,0);

        If (Erx <= _rLocked) then begin

          vTxtName2 # InvGetTextName(Lpl.Lagerplatz);
//debug('02_'+vTxtName2);

          Erx # TextRead(vTxtBuf2,vTxtName2,0);
          If (Erx <> _rOK) then begin
            TxtCreate(vTxtName2,0);
            Erx # TextRead(vTxtBuf2,vTxtName2,_TextLock);
          End;
        End;

      End else if (vTyp = 'IMT') then begin

        // Inventursätze werden angehängt!!
        TextLineWrite(vTxtBuf2,TextInfo(vTxtBuf2,_TextLines),vWert,_TextLineInsert);
      End;
      i # i +1;

    END;

    TextLineWrite(vTxtBuf2,TextInfo(vTxtBuf2,_TextLines),vWert,_TextLineInsert);
    Erx # TxtWrite(vTxtBuf2,vTxtName2,_TextUnlock);
  end;

  TextClose(vTxtBuf1);
  TextClose(vTxtBuf2);


  if Erx = _rOK then
    Msg(844001 ,'',_WinIcoInformation,_WinDialogOk,1)
  else
    Msg(844002 ,'',_WinIcoError,_WinDialogOk,1);



  // alles korrekt gelaufen
  RETURN true;
end;


//========================================================================
// InvFileDelete
//          Löscht eine Inventurdatei
//========================================================================
Sub InvFileDelete(
  aLpl  : alpha;
): logic
local begin
  Erx   : int;
  vTmp  : int;
  vFile : alpha;
  vTxtBuf  : int;
  vTxtName : alpha;
end;
begin


  // Textnamen aufbauen
  vTxtName # InvGetTextName(aLpl);

  // Text Löschen
  Erx # TxtDelete(vTxtName,0);

  // alles korrekt gelaufen?
  if (Erx <> _rOK) then
    RETURN false;
  else
    RETURN true;

end;


//========================================================================
// InvFileDeleteAll
//          Löscht alle Inventurdateien
//========================================================================
sub InvFileDeleteAll(): logic
local begin
  vTmp : int;
  vFile : alpha;

  vTxtBuf  : int;
  vTxtName : alpha;
  vErr     : int;

  vErx : int;
end;
begin

/* ST 2012-06-25: alte Version
  vErr # 7;
  Erx # RecRead(844,1,_recFirst);
  WHILE (Erx <= _rLocked) do begin

    // Textnamen aufbauen
    vTxtName # InvGetTextName(Lpl.Lagerplatz);


    If (strlen(vTxtName) <= 20) then
      // Text Löschen
      Erx # TxtDelete(vTxtName,0)
    Else
//debug(vTxtName);
      vErr # 0;

    // alles korrekt gelaufen?
//  if (Erx <> _rOK) then
//     RETURN false;
//    else
//      RETURN true;

    Erx # RecRead(844,1,_recNext);
  END;

  if vErr <> _rOK then // kein Fehler aufgetreten?
   Msg(844018 ,'',_WinIcoInformation,_WinDialogOk,1)
  else
    Msg(844004 ,'',_WinIcoError,_WinDialogOk,1);

*/

  // ST 2012-06-25: Neue Version
  cProtokoll # TextOpen(20);
  FOR vErx # RecRead(844,1,_recFirst);
  LOOP vErx # RecRead(844,1,_recNext);
  WHILE (vErx <= _rLocked) DO BEGIN

     // Text vorhanden?
    if (InvFileCheck(Lpl.Lagerplatz) = 0) then
      CYCLE;

     // Textnamen aufbauen
    if (!InvFileDelete(Lpl.Lagerplatz)) then begin
      proto('FEHLER: Inventurdaten für den Lagerplatz "'+Lpl.Lagerplatz+'" konnten nicht gelöscht werden.');
      inc(vErr);
    end;
  END;

  if (vErr = 0) then begin
    EndProtokoll();
    Msg(844018,'',_WinIcoInformation,_WinDialogOk,1);
  end else begin
    EndProtokoll(true);
  end;

end;


//========================================================================
// sub _InvVerbuchen_MarkInfo(): alpha
//    Sammelt Informationen über die markierten Lagerplätze und gibt
//    einen formatierten String zurück
//========================================================================
sub _InvVerbuchen_MarkInfo(): alpha
local begin
  vRet : alpha(4096);

  vItem       : int;
  vMFile      : int;
  vMID        : int;

  vInfo : alpha;
end;
begin

  vRet # '';

  // Ermittelt das erste Element der Liste (oder des Baumes)
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile = 844) then
      RecRead(844,0,_RecId,vMID);
    else
      CYCLE;

    vInfo # InvGetInfoFromText(Lpl.Lagerplatz);
    if (vInfo = '') then
      vInfo # ', keine Daten'
    else
      vInfo # ' vom ' + vInfo;

    vRet # vRet + Lpl.Lagerplatz + vInfo + '%CR%';
  END;

  return vRet;
end;


//========================================================================
// InvVerbuchen
//    Fragt den User ob die Inventur verbucht werden soll und
//    startet diese Aktion bei positiver Bestätigung
//========================================================================
sub InvVerbuchen(): logic
local begin
  vOK : logic;
  vMsgText : alpha(4096);
end;
begin
  vMsgText  # _InvVerbuchen_MarkInfo();

  if (Msg(844005,  vMsgText,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    // ST 2012-06-25 1326/246 : ggf. Protokollierung starten
    cProtokoll # TextOpen(20);

    TRANSON;

    vOK # InvUebernehmen();
    if (vOK) then begin
      TRANSOFF;
      EndProtokoll(false,true);
      Msg(844006 ,'',_WinIcoInformation,_WinDialogOk,1);
      return true;
    end
    else begin
      TRANSBRK;
      EndProtokoll(true,true);
//      Msg(844007 ,'',_WinIcoError,_WinDialogOk,1);
      return false;
    end;


  end;

end;


//========================================================================
// InvVerbuchenAll
//    Fragt den User ob die komplette Inventur verbucht werden soll und
//    startet diese Aktion bei positiver Bestätigung
//========================================================================
sub InvVerbuchenAll(): logic
local begin
  vErrTxt : int;
  vText   : alpha;
end;
begin


  if (Msg(844020 ,  '',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    // ST 2012-06-25 1326/246 : ggf. Protokollierung starten
    cProtokoll # TextOpen(20);


    vErrTxt # InvUebernehmenAll();
    if (vErrTxt=0) then begin
      EndProtokoll(false,true);
      Msg(844006 ,'',_WinIcoInformation,_WinDialogOk,1);
      RETURN true;
    end else begin

      // Errorprotokoll anzeigen....
      EndProtokoll(true,true);
      RETURN false;
      /*
      vText # '~844.ERR.'+UserInfo(_UserCurrent);
      TxtWrite(vErrTxt,vText,_Textunlock);
      TextClose(vErrTxt);
      Mdi_RtfEditor_Main:Start(vText, n, Translate('Protokoll'), here+':ausErrorLog');
      Msg(844007 ,'',_WinIcoError,_WinDialogOk,1);
      */
    end;

  end;
end;

/*
//========================================================================
//  AusErrorLog
//
//========================================================================
sub AusErrorLog();
begin
  gSelected # 0;
  TxtDelete('~844.ERR.'+UserInfo(_UserCurrent),0);
end;
*/

//========================================================================
// InvUebernehmen
//          Übernimmt die aktuellen Lagerplätze in die Materialien
//========================================================================
sub InvUebernehmen(): logic;
local begin
  erx         : int;
  vFile       : alpha;
  vTmp        : int;
  vHdl        : int;
  vType       : alpha(4);
  vWert       : alpha(20);
  vLpl        : alpha(20);
  vCRLF       : alpha(4);
  vMax        : int;
  vPos        : int;

  vItem       : int;
  vMFile      : int;
  vMID        : int;
  vInvTxtBuf  : int;
  vInvTxtName : alpha;
  vI          : int;
  vLine       : alpha;

  vErrCnt     : int;
  vMatErx     : int;

  vMat  : int;
end;
begin

  if (RunAFX('Lpl.Data.InvUebernehmen','')<>0) then begin
     RETURN (AfxRes = _rOK);
  end;


  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);

  // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile = 844) then begin
      RecRead(844,0,_RecId,vMID);
      // markierter Lageplatz ist gelesen

      // Inventurdatei vorhanden?
      if (InvFileCheck(Lpl.Lagerplatz) <> 1) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem); // Nächsten Lagerplatz
        Proto('INFO: Keine Inventurdaten für Lagerplatz vorhanden für "' +Lpl.Lagerplatz + '"');
        CYCLE;
      end;

      // Text öffenen
      vInvTxtBuf # TextOpen(16);
      vInvTxtName # InvGetTextName(Lpl.Lagerplatz);  // Namen generieren
      Erx # TextRead(vInvTxtBuf,vInvTxtName,0);
      if (Erx <> _rOK)  then begin
        Proto('FEHLER: Inventurdaten für Lagerplatz vorhanden für "' +Lpl.Lagerplatz + '" konnten nicht gelesen werden');
        vItem # gMarkList->CteRead(_CteNext,vItem); // Nächsten Lagerplatz
        CYCLE;
      end;

      // Material aus der Inventurdatei zeilenweise in Selektion schreiben
      vErrCnt # 0;
      FOR vI # 1; loop inc(vI) while (vI<=TextInfo(vInvTxtBuf, _TextLines,0)) DO BEGIN
        vLine # TextLineRead(vInvTxtBuf,vI,0);

        if (CnvIa(vLine) = 0) then
          CYCLE;


        // Pro Zeile Material lesen
        Mat.Nummer #  CnvIa(vLine);
        vMat   # Mat.Nummer;

        // Material lesen
        vMatErx # RecRead(200,1,0);
        if (vMatErx <> _rOK) then begin
          Proto('FEHLER: Material "'+Aint(vMat)+'" konnte nicht gelesen werden ('  + aint(vMatErx) +')');
          inc(vErrCnt);
          CYCLE;
        end;
        if ("Mat.Löschmarker" = '*') then begin
          Proto('INFO: Material "'+Aint(vMat)+'" besitzt Löschmarker');
          inc(vErrCnt);
        end;

        if (!Mat_Data:SetInventur(Mat.Nummer,Lpl.Lagerplatz,Sysdate(), false)) then begin
          Proto('FEHLER: Inventur für Materialnummer "'+Aint(vMat)+'" konnte nicht verbucht werden');
          inc(vErrCnt);
          CYCLE;
        end;

      END;

    end; // Lagerplatzmarkierung
    vItem # gMarkList->CteRead(_CteNext,vItem);

  END;


  if (vErrCnt > 0) then
    return false;

  // alles geklappt
  return true;

end;


//========================================================================
// InvUebernehmenAll
//          Übernimmt alle aktuellen Lagerplätze in die Materialien
//========================================================================
sub InvUebernehmenAll(): int;
local begin
  Erx         : int;
  vFile       : alpha;
  vTmp        : int;
  vHdl        : int;
  vType       : alpha(4);
  vWert       : alpha(20);
  vLpl        : alpha(20);
  vCRLF       : alpha(4);
  vMax        : int;
  vPos        : int;
  vItem       : int;
  vMFile      : int;
  vMID        : int;
  vInvTxtBuf  : int;
  vInvTxtName : alpha;
  vI          : int;
  vLine       : alpha;

  vErrTxt     : int;
  vMatErx     : int;
  vMat  :  int;
end;
begin

  if (RunAFX('Lpl.Data.InvUebernehmenAll','')<>0) then begin
     RETURN (AfxRes);
  end;


  Erx # RecRead(844,1,_recFirst);     // ersten Lagerplatz lesen ...
  WHILE (Erx <= _rLocked) do begin    // ... dann alle durchlaufen

      vInvTxtBuf  # TextOpen(16);
      vInvTxtName # InvGetTextName(Lpl.Lagerplatz);

      Erx # TextRead(vInvTxtBuf,vInvTxtName,0);
      if (Erx <> _rOK)  then begin                    // Text nicht OK? ...
        Erx # RecRead(844,1,_recNext);                // ... dann nächster Lagerplatz
        Proto('INFO: keine Inventurdaten für Lagerplatz "'+Lpl.Lagerplatz+'"');
        CYCLE;
      end;

      // Inventurdatei pro Lagerplatz durchlaufen
      FOR vI # 1; loop inc(vI) while (vI<=TextInfo(vInvTxtBuf, _TextLines,0)) DO BEGIN
        vLine # TextLineRead(vInvTxtBuf,vI,0);

        if (CnvIa(vLine) = 0) then
          CYCLE;

        // Pro Zeile Material lesen
        Mat.Nummer #  CnvIa(vLine);
        vMat    # Mat.Nummer;

        // Material lesen
        vMatErx # RecRead(200,1,0);
        if (vMatErx <> _rOK) then begin
          Proto('FEHLER: Material "'+Aint(vMat)+'" konnte nicht gelesen werden ('  + aint(vMatErx) +')');
          inc(vErrTxt);
          CYCLE;
        end;
        if ("Mat.Löschmarker" = '*') then begin
          Proto('INFO: Material "'+Aint(vMat)+'" besitzt Löschmarker');
          inc(vErrTxt);
        end;

        if (!Mat_Data:SetInventur(Mat.Nummer,Lpl.Lagerplatz, today, false)) then begin
          Proto('FEHLER: Inventur für Materialnummer "'+Aint(vMat)+'" konnte nicht verbucht werden');
          inc(vErrTxt);
        end;

      END;

    Erx # RecRead(844,1,_recNext);   // nächster Lagerplatz
  END // While


  // alles geklappt
  RETURN vErrTxt;

end;


//========================================================================
// InvLoadDataCPT711
//   Startet die Datenübergabe vom CPT711 -> Datenpfad
//========================================================================
sub InvLoadDataCPT711(): alpha
local begin
  vPathEXE  : alpha;
  vPathData : alpha;
  vFlags    : alpha;
  vRet      : alpha;
  vTxt      : int;
end;
begin


  // 'Z:\c16\client.52\BC_Scan\Data_Read.exe';
  vPathEXE  # Set.BcsScanner.Pfad + 'Data_Read.Exe';

  // Daten in Datenverzeichnis mit Username ablegen
  vPathData # Set.BcsScanner.Pfad + 'Data\'+UserInfo(_UserName,UserID(_UserCurrent))+'.txt';

  // Vor dem Einlesen löschen
  FsiDelete(vPathData);

  // Flagstring für "Data_read.exe"
  vFlags  # vPathData+',1,'+CnvAi(Set.BCScanner.Port)+',1,1,1,1,1,0,0,0,2,2';

  if (SysExecute('*'+vPathEXE,vFlags,_ExecWait) = _ErrOK) then begin
    vRet # vPathData;

    // Prüfen, ob die Datei gelesen wurde und Daten enthält
    vTxt # FsiOpen(vPathData,_FsiStdRead);
    if (vTxt > 0) then
      FsiClose(vTxt)
    else begin
      //  Datei wurde nicht erstellt
      vRet # '';
    end;


  end else
    vRet # '';


  return vRet;
end;


//========================================================================
// InvPrepare
//   Bereitet den Inventurtext nach dem Einlesen für SC vor
//========================================================================
sub InvPrepare(
  aTxtName : alpha;
  aCheckType : alpha;
  aClearType : alpha;
  aCheckVal : alpha;
): logic
local begin
  Erx       : int;
  vTxtBuf : int;
  vLine   : alpha;
  vLineIndex : int;
  vDone : logic;
  vCheckOK : logic;
  vRetVal : logic;
  vTmp  : alpha;
end;
begin
    vRetVal # true;

    // Text öffnen
    vTxtBuf # TextOpen(10);
    Erx # TextRead(vTxtBuf,aTxtName,0);
    if (Erx = _rOK)  then begin

      // Zeilenweise prüfen
      vLineIndex # 0;
      vCheckOK # false;
      repeat
        vLineIndex # vLineIndex +1;
        vLine # TextLineRead(vTxtBuf,vLineIndex,0);
        if (vLine = '') then
          break;

        if (!vCheckOK)  then begin
          // Prüfen, ob die Datei den Richtigen Lagerplatz enthält
          if (StrCut(vLine,1,4) = aCheckType) then begin
            if (StrCut(vLine,5,StrLen(aCheckVal)) = aCheckVal) then begin
              vCheckOK # true;
              vLine # TextLineRead(vTxtBuf,vLineIndex,_TextLineDelete);
              vLineindex # 0;
              cycle;
            end;
          end;

        end else begin
          // Daten verarbeiten

          // gehört aktueller Satz zu den Gewünschten Werten?
          if (StrCut(vLine,1,4) <> aClearType) then begin
             // Nein -> aus Text entfernen
             vLine # TextLineRead(vTxtBuf,vLineIndex,_TextLineDelete);
             vLineIndex # vLineIndex - 1;
             cycle;
          end;
        end;

        if (1 = 2) then
          vDone # true;

      until (vDone);

      // Alle Cleartypes entfernen
      if (vCheckOK) then begin
        TextSearch(vTxtBuf,1,1,_TextSearchCount,aClearType,'',0)
        // Text sichern
        TxtWrite(vTxtBuf,aTxtName,0);
      end else begin
        vRetVal # false;
        TextClose(vTxtBuf);
      end;

    end;


    return vRetVal;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================