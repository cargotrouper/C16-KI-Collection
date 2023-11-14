@A+
//===== Business-Control =================================================
//
//  Prozedur  App_Update_Data
//                  OHNE E_R_G
//  Info
//
//
//  21.01.2008  AI  Erstellung der Prozedur
//  05.09.2008  PW  Anpassung für neue Updateprozeduren (Changelog)
//  23.12.2009  AI  Artikeljournal
//  29.03.2010  AI  neue Zahlungsbedingungen
//  14.12.2011  AI  Protokoll aktiviert
//  08.05.2013  AI  neu: Alle Proezduren compileren
//  14.06.2013  ST  UrgentMsg für Kalkulationspositionen hinzugefügt
//  29.07.2014  AH  neu: "Erl.K.Artikelnummer"
//  13.05.2015  AH  neu: Adr.VK.ReAnschrift
//  24.08.2015  AH  Neu: Werstellungsdatum
//  08.09.2015  AH  Neu: Update-Log als Clipboard, SQL_SYNCONEs eingabeut
//  24.02.2016  AH  Neu: Konverter für Vorgabe-Texte
//  03.03.2016  AH  Neu: Upgrade57To58
//  04.03.2016  ST  Edit: Upgrade57To58 muss jetzt manuell ausgeführt werden
//  15.10.2018  ST  Neu: Updatemessage für Paketetikettendruck
//  29.11.2018  ST  Neu: Recht auf LFA Druck aus Lieferschein hinzugefügt
//  08.01.2019  AH  Neu: Update löscht ggf. alle AFX
//  23.03.2021  AH  Neu: AFX "Update.Create"
//  16.02.2022  DS  Integration von C16_DatenstrukturDif (automatisches Anzeigen von
//                  nötigen ALTER TABLE Befehlen), parallel zu bestehendem Mechanismus
//  24.02.2022  DS  (zunächst deaktiviert, aber Code ist vorhanden) Beim Erstellen
//                  des Updates wird ein automatisch ein "release-commit" auf dem
//                  jeweiligen master branch im git erzeugt, so dass immer klar ist,
//                  welche Änderungen Teil welchen Updates waren.
//  04.03.2022  DS  Automatische Git-Integration ("Auto-Git") aktiviert, siehe 24.02.2022
//  02.06.2022  AH  "!Version"-Text enthält Erstellungszeitpunkt
//  2022-11-04  DS  git wird nur noch aktiv, wenn unsere Lizenz verwendet wird, also
//                  in BCS' lokalem STD oder DEV (siehe "and..." Klausel an gitEnable)
//
//  Subprozeduren
//    SUB AblagenCheck(aFile1 : int; aFile2 : int) : alpha;
//    sub Upgrade57to58()
//    SUB CreateUpdate()
//    SUB CheckUpdate()
//    SUB InstallUpdate() : logic;
//    MAIN
//
//========================================================================
@I:Def_BAG
@I:Def_AKtionen

define begin
  cProt : y
  TextAddLine(a,b):  TextLineWrite(a,TextInfo(a,_TextLines)+1,cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+': '+b,_TextLineInsert)
  TextAddLineRaw(a,b):  TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
  Debugx(a) : Lib_Debug:Dbg_Debug(a+'   ['+__PROC__+':'+cnvai(__LINE__)+']')
  
  // 04.03.2022  DS
  gitEnable : true  // Automatisches Pushen von "release-commits" ein/ausschalten
  
  //2023-07-28 MR
  cMsgMdeVersioning           : '(Nur wenn MDE vorhanden) Aufgrund von Breaking Changes im STD ist ein Update des MDEs notwendig. '
  cMsgMdeVersioningAnleitung  : 'Hierzu Dienste (BC_AppHost & BC_MdeHost) stoppen + die Ordner MdeHost & AppHost im PS-Ordner v. Kunde m. Std austauschen.'
end;



//========================================================================
//========================================================================
sub Todo(
  aMeldung  : alpha(4000));
local begin
  vClp  : alpha(8096);
end;
begin
  vClp # ClipboardRead();
  vClp # vClp + aMeldung + StrChar(13) + StrChar(10);
  ClipboardWrite(vClp);
end;


//========================================================================
//========================================================================
sub UrgentMsg(
  aMeldung  : alpha(4000));
//a) : WHILE (WinDialogBox( 0, 'ACHTUNG', a+StrChar(13)+'Meldung verstanden?', _winIcoWarning, _WinDialogYesNo,2)<>_WinidYes) do CYCLE;
local begin
  vClp  : alpha(4000);
end;
begin
  Todo(aMeldung);
  WHILE (WinDialogBox( 0, 'ACHTUNG', aMeldung+StrChar(13)+'Meldung verstanden?', _winIcoWarning, _WinDialogYesNo,2)<>_WinidYes) do CYCLE;
end;

/***
//========================================================================
// ConvertSingleRecIDInt
//========================================================================
// Konvertiert eine RecID 5.7, die in einem int-Wert abgelegt ist nach 5.8
sub _ConvertSingleRecIDInt
(
  aRecID                : int;   // Datensatz-ID (Version 5.7)
  aTarTblIsSequential   : logic; // Zieldatei (auf die die RecIDs verweisen)
                                 // hat "sequentielles Einfügen" aktiviert?
) : int;                           // Datensatz-ID (Version 5.8)
begin
  if (aTarTblIsSequential) then begin
    if (aRecID & 0x80 != 0) then
      ErrSet(_ErrValueOverflow);
    else
      RETURN (
          (aRecID & 0xFF000000) >> 24 & 0xFF |
          (aRecID & 0x00FF0000) >> 8         |
          (aRecID & 0x0000FF00) << 8         |
          (aRecID & 0x000000FF) << 24
      );
  end
  else begin
    if (aRecID > 0) then
      ErrSet(_ErrValueOverflow);
    else
      RETURN -aRecID;
  end
end;

//========================================================================
// Call Lib_Rec:Upgrade57to58
//========================================================================
sub Upgrade57to58()
local begin
  vAlt  : int;
  vNeu  : int;
  vErg  : int;
end;
begin

  FOR vErg # RecRead(931,1,_recFirst)
  LOOP vErg # RecRead(931,1,_recNext)
  WHILE (vErg<=_rLocked) do begin
    vAlt # Cus.RecID;//RecInfo(931,_recID);
    vNeu # _ConvertSingleRecIDint(vAlt, TRUE);   // SEQUENTIELL
    RecRead(931,1,_recLock);
    Cus.RecId # vNeu;
    RecReplace(931,_RecUnlock);
//debug(Cus.Inhalt+' = '+aint(vAlt)+' wird '+aint(vNeu));
//debug(CnvAI(vAlt, _FmtNumHex | _FmtNumLeadZero, 0, 8)+' -> '+CnvAI(vNeu, _FmtNumHex | _FmtNumLeadZero, 0, 8));
  END;
end;
***/


//========================================================================
//  AblagenCheck
//
//========================================================================
sub AblagenCheck(aFile1 : int; aFile2 : int) : alpha;
local begin
  vText   : alpha(2000);
  vFldMax : int;
  vFld    : int;
  vTds    : int;
end;
begin

  FOR vTds # 1 loop inc(vTds) WHILE (vTds<=10) do begin
    if (SbrInfo(aFile1, vTds, _SbrExists)<>SbrInfo(aFile2, vTds, _SbrExists)) then begin
      vText # vText + 'SBR-Count-Error:'+Cnvai(aFile1)+'/'+cnvai(vTds)+StrChar(13);
      BREAK;
    end;
  END;

  if (vText='') then begin
    FOR vTds # 1 loop inc(vTds) WHILE (vTds<=100) do begin
      if (SbrInfo(aFile1, vTds, _SbrExists)>0) then begin
        vFldMax # SbrInfo(aFile1, vTds, _FileSbrCount);
        vFldMax # 200;
        FOR vFld # 1 loop inc(vFld) WHILE (vFld<=vFldMax) do begin
          if (FldInfo(aFile1, vTds, vFld, _FldExists)<>FldInfo(aFile2, vTds, vFld, _FldExists)) then begin
            vText # vText + 'FLD-Count-Error:'+Cnvai(aFile1)+'/'+cnvai(vTds)+'/'+cnvai(vfld)+StrChar(13);
          end;
          if (FldInfo(aFile1, vTds, vFld, _FldExists)>0) and (FldInfo(aFile2, vTds, vFld, _FldExists)>0) then begin
            if (FldInfo(aFile1, vTds, vFld, _FldType)<>FldInfo(aFile2, vTds, vFld, _FldType)) then begin
              vText # vText + 'TYPE-Error:'+Cnvai(aFile1)+'/'+cnvai(vTds)+'/'+cnvai(vfld)+StrChar(13);
              end
            else begin
              if (FldInfo(aFile1, vTds, vFld, _FldType)=_TypeAlpha) then begin
                if (FldInfo(aFile1, vTds, vFld, _FldLen)<>FldInfo(aFile2, vTds, vFld, _FldLen)) then begin
                  vText # vText + 'LEN-Error:'+Cnvai(aFile1)+'/'+cnvai(vTds)+'/'+cnvai(vfld)+StrChar(13);
                end;
              end;
            end;
          end;
        end;
      END;
    END;
  end;

  RETURN vText;
end;


//========================================================================
//  GetBcsText
//========================================================================
sub GetBcsText(aAdrNr : int) : int
local begin
  vErg  : int;
  vName : alpha;
  vTxt  : int;
end;
begin
  try begin
    ErrTryIgnore(_ErrValueRange, _ErrValueInvalid);
    DbaDisconnect(2);
  end;
  ErrSet(_ErrOK);

  vErg # DbaConnect(2, 'BCS', '192.168.0.16', '!BCS_2007', 'SU', 'VIB', '');
  if (vErg <>_ErrOK) then begin
    ErrSet(_ErrOK);
    RETURN 0;
  end;
  
  vTxt # TextOpen(20);
//  vName # '~100.00001254.002';
  vName # '~100.'+cnvai(aAdrNr, _Fmtnumleadzero|_FmtNumNoGroup,0,8)+'.002';
  vErg # TextRead(vTxt, vName, _TextDBA2);
  if (vErg>_rlocked) then begin
    TextClose(vTxt);
    vTxt # 0;
  end;
  
  try begin
    ErrTryIgnore(_ErrValueRange, _ErrValueInvalid);
    DbaDisconnect(2);
  end;
  ErrSet(_ErrOK);
  
  RETURN vTxt;
end;


//========================================================================
//
//========================================================================
sub BcsUpdateText(
  aAdrNr : int);
local begin
  vTxt  : int;
  vName : alpha;
end;
begin
  if (Set.Installname='') or (Set.Installname='STD') then RETURN;

  vTxt # GetBcsText(aAdrNr);
  if (vTxt=0) then RETURN;

  vName # 'c:\updates\'+Set.Installname+'.RTF';

  TextWrite(vTxt, vName, _textextern);
  SysExecute('*'+vName, '',0);

  TextClose(vTxt);
end;


//========================================================================
//  CreateUpdate
//
//========================================================================
sub CreateUpdate()
local begin
  vErrA       : alpha(200);
  vHdl        : int;
  vA          : alpha;
  vText       : alpha(2000);
  vI          : int;
  vStartDate  : date;
  vVersion    : alpha;
  vCT         : caltime;
end;
begin
//  WinDialogBox( 0, 'ERROR', 'Gesperrt bis AH fertig ist (SYNC)!', _winIcoError, _winDialogOk, 1 );
//RETURN;

  vText # AblagenCheck(400,410);
  if (vText<>'') then begin
//    WinDialogBox( gFrmMain, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
      WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;
  vText # AblagenCheck(401,411);
  if (vText<>'') then begin
    WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;
  vText # AblagenCheck(500,510);
  if (vText<>'') then begin
    WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;
  vText # AblagenCheck(501,511);
  if (vText<>'') then begin
    WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;
  vText # AblagenCheck(200,210);
  if (vText<>'') then begin
      WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;
  vText # AblagenCheck(655,656);
  if (vText<>'') then begin
    WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;
  vText # AblagenCheck(540,545);
  if (vText<>'') then begin
    WinDialogBox( 0, 'ERROR', vText, _winIcoError, _winDialogOk, 1 );
    RETURN;
  end;

  // 16.02.2022 DS
  // Beim Erstellen des Updates wird die Datenstruktur des Quell-Datenraums
  // (damit ist die Quelle des Updates gemeint) als .json in den Quell-Datenraum
  // serialisiert und wird Teil des Updates um Vergleiche mit der Datenstruktur des
  // Ziel-Datenraums der Update-Installation zu ermöglichen.
  // Dadurch können automatisch ALTER TABLE Hinweise bei Update-Installation
  // gegeben werden.
  RecRead(903, 1, _recFirst);  // Settings lesen
  if (Set.Installname='') or (Set.Installname='STD') then begin
    // Quell-Datenraum ist STD, benenne Text Datei in Datenraum entsprechend
    C16_DatenstrukturDif:saveJsonToDataspace(C16_DatenstrukturDif:DatastructureToJson(), '!Datenstruktur.STD');
  end
  else begin
    // Quell-Datenraum ist DEV (also BCS-seitiger, kundenspezifischer DEV Datenraum),
    // benenne Text Datei in Datenraum entsprechend
    C16_DatenstrukturDif:saveJsonToDataspace(C16_DatenstrukturDif:DatastructureToJson(), '!Datenstruktur.DEV');
  end;
  

  // Changelog exportieren...
  vStartDate # SysDate();
  vStartDate->vmMonthModify( -2 );
  Log_Main:ExportHistory(vStartDate);

  // Versionsnummer setzen...
  vHdl # TextOpen(10);
  TextRead(vHdl, '!Version',0);
  vA # TextLineRead(vHdl,1,0);
  if (Set.Installname='') or (Set.Installname='STD') then begin
    Dlg_Standard:Standard('Versionsnummer',var vA);
  end;
  if (vA='') then RETURN
  vVersion # vA;  // sichern für gitForCreateUpdate()
  TextLineWrite(vHdl, 1, vA, 0);
  vA # cnvai(DbaInfo(_DbaClnRelMaj))+'.'+cnvai(DbaInfo(_DbaClnRelMin))+'.'+cnvai(DbaInfo(_DbaClnRelrev),_FmtNumLeadZero,0,2);
  vI # DbaInfo(_DbaClnRelSub);
  if (vI<>0) then vA # vA + StrChar(vI);
  TextLineWrite(vHdl, 2, vA, 0);
  vCT->vmServerTime();
  vA # cnvad(vCT->vpDate)+' '+cnvat(vCT->vptime); // 31.12.2022 14:00
  //CnvAC(vCT, _FmtCaltimeISO | _FmtCaltimeDateBlank | _FmtCaltimeTimeHMS)
  TextLineWrite(vHdl, 3, vA, 0);    // 02.06.2022 AH
  TextWrite(vHdl, '!Version', 0);

  // 24.02.2022 DS
  // Beim Erstellen des Updates wird automatisch ein "release-commit" auf dem jeweiligen master branch im git erzeugt,
  // so dass immer klar ist, welche Änderungen Teil welchen Updates waren.
  // 2022-11-04 DS
  // git ist nur aktiv, wenn BCS' Lizenz verwendet wird, also in BCS' lokalem STD oder DEV.
  // Damit kann z.B. Herr Bartsch bei VogelBauer auch selbst Updates generieren, ohne dass git benötigt wird.
  if gitEnable and DbaLicense(_DbaSrvLicense)='CD152667MN/H' then
  begin
    Git_for_C16:gitForCreateUpdate(vVersion);
  end

  // 23.03.2021 AH
  Lib_SFX:Run_AFX('Update.Create','');
//ShowUpdateText(1254);

  // ggf. ODBC beenden
  Lib_ODBC:Term();

  // ggf. andere Threads beenden
  Lib_Jobber:Term();

  // Update erstellen...
  if ( OemSave( 'VOLLUPDATE', 'VIB', 0, var vErrA ) != _errOk ) then
//    WinDialogBox( gFrmMain, 'ERROR', vErrA, _winIcoError, _winDialogOk, 1 );
    WinDialogBox( 0, 'ERROR', vErrA, _winIcoError, _winDialogOk, 1 );

end;


//========================================================================
//  CheckUpdate
//
//========================================================================
sub CheckUpdate()
begin
  // Lib_FTP();   // Umstellung auf HTTP am 19.06.2009
//  Lib_HTTP();
  SysExecute('*https://stahl-control.de/#aktuelles','',0);

end;


//========================================================================
// ImportHistory
//          History aus Text !AUTO:CHANGELOG importieren
//========================================================================
sub ImportHistory(aStand : alpha)
local begin
  vStartDate : date;
  vTxt       : int;
  vLines     : int;
  vI         : int;
  vLine      : alpha(250);
  vSel       : int;
  vSelName   : alpha;
end;
begin
  // Texthandle
  vTxt # TextOpen( 512 );
  vTxt->TextRead( '!AUTO:CHANGELOG', 0 );
  vLines # vTxt->TextInfo( _textLines );

  // Datenimporteintrag erstellen
  RecBufClear( 995 );
  Log.Datum      # SysDate()
  Log.Zeit       # Systime( _timeSec | _timeServer );
  Log.StandardYN # y;
  Log.Bereich    # '!UPDATE!';
  Log.Bemerkung  # '----------------------------------------'+aStand;
  Log.Installationsdat # SysDate();
  RecInsert(995, 0);

  FOR  vI # 1;
  LOOP vI # vI + 1;
  WHILE ( vI <= vLines ) DO BEGIN
    vLine # vTxt->TextLineRead( vI, 0 );

    if (StrLen(vLine)>18) then begin
      RecBufClear( 995 );
      Log.Datum      # CnvDA( strCut( vLine,  1, 10 ), _fmtInternal );
      Log.Zeit       # CnvTA( strCut( vLine, 11,  8 ), _fmtInternal );
      Log.StandardYN # CnvLI( CnvIA( strCut( vLine, 19, 1 ) ) );

      if ( RecRead( 995, 1, _recTest ) <= _rMultiKey ) then
        CYCLE;

      Log.Bereich    # strCut( vLine, 20, strFind( vLine, '|||', 20 ) - 20 );
      Log.Bemerkung  # strCut( vLine, strFind( vLine, '|||', 20 ) + 3, 128 );
      Log.Installationsdat # SysDate()
      RecInsert( 995, 0);
    end;
  END;

  vTxt->TextClose();
end;


//========================================================================
//  InstallUpdate
//    Liest ein Update ein (PRE-UPDATE-Schritt, POST-UPDATE-Schritt ist
//    die MAIN Methode von App_Update_Data).
//    InstallUpdate() wird aufgerufen aus kompilierten Liz* Prozeduren.
//========================================================================
sub InstallUpdate() : logic;
LOCAL begin
  vTmp  : int;
  vFile : alpha(200);
  vErrA : alpha(200);
  vHDL  : int;
  vVersionVor : float;
  vA,vB : alpha(4096);
  vErg  : int;
  vTxt  : int;
  vCteDatastructureB : handle;
end;
begin

  // 13.03.2015
  vTxt # TextOpen(20);
  vErg # TextRead(vTxt, '!KUNDENINFO',0);
  if (vErg<=_rLocked) then begin
    vHdl # Winopen('Frame.Text',_winopenDialog);
    vTmp # Winsearch(vHdl, 'Txt.TxtEditor');
    vTmp->wpcaption # '!KUNDENINFO';
    WinDialogRun(vHdl,_WinDialogAlwaysOnTop);
    if  (WinDialogBox( 0, 'Update', 'Fortfahren?', _winIcoQuestion, _winDialogYesNo, 2 )<>_Winidyes) then RETURN false;
  end;
  TextClose(vTxt);


  RecRead(903,1,0);   // Lies Settings
  
  // 16.02.2022 DS
  // Beim Installieren des Updates wird die Datenstruktur des Quell-Datenraums
  // (damit ist die Quelle des Updates gemeint) mit der des Ziel-Datenraums
  // (in dem das Update installiert wird) verglichen, und auf Grundlage dieses
  // Vergleichs werden ALTER TABLE Hinweise gegeben, wo erforderlich.
  //
  // Damit dabei der _richtige_ Stand des Ziel-Datenraums zum Vergleich herangezogen
  // wird, muss dieser _vor_ Installation des Updates als json in den Datenraum
  // geschrieben werden, also innerhalb dieses PRE-UPDATE Schrittes InstallUpdate().
  if (App_Main:Entwicklerversion()) then begin
    // Wenn die Lizenz-Nummer der aktiven C16 Installation die von BCS ist, muss der
    // Ziel-Datenraum in dem installiert wird die BCS-interne, kundenspezifische DEV Umgebung sein.
    // Wir befinden uns also im Szenario des Updates von STD nach DEV.
    
    // DEV Datenstruktur in Datenraum speichern
    vCteDatastructureB # C16_DatenstrukturDif:DatastructureToJson();
    C16_DatenstrukturDif:saveJsonToDataspace(vCteDatastructureB, '!Datenstruktur.DEV');
    Lib_Json:CloseJSON(var vCteDatastructureB);
    
  end
  else begin
    // Wenn die Lizenz-Nummer der aktiven C16 Installation NICHT die von BCS ist, muss der
    // Ziel-Datenraum in dem installiert wird beim Kunden liegen und daher eine seiner LIVE Umgebungen sein.
    // Wir befinden uns also im Szenario des Updates von DEV nach LIVE.
    
    // LIVE Datenstruktur in Datenraum speichern
    vCteDatastructureB # C16_DatenstrukturDif:DatastructureToJson();
    C16_DatenstrukturDif:saveJsonToDataspace(vCteDatastructureB, '!Datenstruktur.LIVE');
    Lib_Json:CloseJSON(var vCteDatastructureB);
    
  end
  

//  if (Set.SQL.Instance<>'') then begin
//    if (WinDialogBox( 0, 'ACHTUNG', 'Datenbank ist mit einer SQL gesynct und MUSS nach dem Update ggf. manuell gesynct werden!'+StrChar(13)+'Soll gestoppt werden?', _winIcoWarning, _WinDialogYesNo, 1 )=_winidyes) then RETURN false;
//  end;

  if (DbaInfo(_DBaReadOnly)>0) then begin
    WinDialogBox( 0, 'FEHLER', 'Datenbank ist im BACKUPMODUS!!!', _winIcoError, _winDialogOk, 1 )
    RETURN false;
  end;

//  if ( WinDialogBox( gFrmMain, 'ACHTUNG', 'Haben Sie ein BACKUP VON ' + DbaName( _dbaAreaAlias ) + ' gemacht?', _winIcoWarning, _winDialogYesNo, 2 ) != _winIdYes ) then
  if ( WinDialogBox( 0, 'ACHTUNG', 'Haben Sie ein BACKUP VON ' + DbaName( _dbaAreaAlias ) + ' gemacht?', _winIcoWarning, _winDialogYesNo, 2 ) != _winIdYes ) then
    RETURN false;

  // 08.01.2019
  if (DbaLicense(_DbaSrvLicense)<>'CD152667MN/H') then begin
    REPEAT
      vErg # WinDialogBox(
        0,
        'ACHTUNG',
        'Update der Ankerfunktionen (AFX-Settings) gewünscht?' +
        StrChar(10) +  StrChar(10) +
        'Sollen die AFX-Settings im Ziel-System überschrieben werden mit den im Quell-System konfigurierten AFX-Settings?',
        _winIcoWarning,
        _WinDialogYesNoCancel,
        3
      );
    UNTIL (vErg<>_WinIdCancel);
    if (vErg = _winIdYes ) then begin
      RecDeleteAll(923);
    end;
  end;
  

  vTmp # WinOpen( _winComFileOpen, _winOpenDialog );
  if ( vTmp != 0 ) then begin
    vTmp->wpFileFilter # 'Updatedatei|*.D01';
    if ( vTmp->WinDialogRun( _winDialogCenterScreen ) = _rOK ) then
      vFile # StrAdj( vTmp->wpPathName + vTmp->wpFileName, _strEnd );
    vTmp->WinClose();

    if ( vFile != '' ) then begin

      vHdl # TextOpen(10);
      TextRead(vHdl, '!Version',0);
      vA # TextLineRead(vHdl,1,0);
      TextClose(vHdl);
      RecRead(903,1,_recLock);
      vVersionVor # Set.Version.vorherig;
      Set.Version.vorherig # cnvfa(vA,_FmtNumPoint);
      RecReplace(903,0);

      // 13.03.2015: Listen merken
      TextDelete('!UPDATE_RECS',0);
      vTxt # TextOpen(20);
      FOR vErg # RecRead(910,1,_recFirst)
      LOOP vErg # RecRead(910,1,_recNext)
      WHILE (vErg<=_rLocked) do begin
//        TextAddLine(vTxt, '910|'+cnvai(Recinfo(910,_recID),_FmtNumNoGroup));
        TextAddLineRaw(vTxt, '910|'+"Lfm.Kuerzel"+'|'+cnvai(Lfm.Nummer,_FmtNumNoGroup,0,8)+'|');
      END;
      TextWrite(vTxt, '!UPDATE_RECS', 0);
      TextClose(vTxt);


      if ( OemLoad( vFile, 'App_Update_Data', var vErrA ) != _ErrOK) then begin
//        WinDialogBox( gFrmMain, 'ERROR', vErrA, _winIcoError, _winDialogOk, 1 );
        WinDialogBox( 0, 'ERROR', vErrA, _winIcoError, _winDialogOk, 1 );
        RecRead(903,1,_recLock);
        Set.Version.vorherig # vVersionVor;
        RecReplace(903,0);
        RETURN false;
      end;
      //WindialogBox(gFrmMain,'install',vFile,_WinIcoError,_WinDialogOk,1);
      RETURN true;
    end;
  end;

  RETURN false;
end;


//========================================================================
//========================================================================
sub Insert857(
  aTyp  : alpha;
  aName : alpha);
begin
  TTy.Typ        # aTyp;
  TTy.Typ2       # aTyp;
  TTy.Bezeichnung # aName;
  RecInsert(857,0);
end;


//========================================================================
//  MAIN
//    Die main Methode ist der POST-UPDATE-Schritt der Update-Installation.
//    Der PRE-UPDATE-Schritt ist InstallUpdate() in dieser Prozedur.
//    Zwischen den PRE- und POST-UPDATE-Schritten wird per OemLoad()
//    das Update mit den C16 Bordmitteln eingespielt.
//========================================================================
MAIN
local begin
  vErg        : int;
  vOK         : logic;
  vHDL        : int;
  vA,vB       : alpha(4096);
  vStand      : alpha;
  vVersionNeu : float;
  vN          : float;
  vRelNeu     : alpha;
  vI,vj       : int;
  vProt       : int;
  vTxt        : int;
  v903        : int;
  vF,vF2      : float;
  vM          : float;
  vBuf        : int;
  vVonNach    : alpha;
  vCT         : caltime;
end;
begin

  // Settings lesen
  RecRead(903,1,_recFirst);

  vHdl # TextOpen(10);
  TextRead(vHdl, '!Version',0);
  vA # TextLineRead(vHdl,1,0);
  vVersionNeu # cnvfa(vA,_FmtNumPoint);
  vRelNeu # TextLineRead(vHdl,2,0);
  vStand # 'V'+vRelNeu + ', '+TextLineRead(vHdl,3,0);
  TextClose(vHdl);


  if (cProt) then begin
    vProt # TextOpen(10);
    TextAddLine(vProt,'Update gestartet...');
  end;


  if (vProt<>0) then
    TextAddLine(vProt, 'Schlüssel reorganiseren...');

  // alle leeren Schlüssel reorganisieren
  DbaKeyRebuild( 0, 0, _keyOnlyEmpty | _keyWait );

  // Changelog importieren
  ImportHistory(vStand);

  // 20.10.2008 - neue Datensätze...
  RecbufClear(820);
  Mat.Sta.Nummer        # 598;
  Mat.Sta.neueNummer    # 598;
  Mat.Sta.Bezeichnung   # 'EK-Storno';
  RecInsert(820,0);
  Mat.Sta.Nummer        # 599;
  Mat.Sta.neueNummer    # 599;
  Mat.Sta.Bezeichnung   # 'EK-Ausfall';
  RecInsert(820,0);

  // 26.11.2008 - neue Datensätze...
  RecbufClear(853);
  RTy.Nummer            # 400;
  RTy.Bezeichnung       # 'VK-Rechnung';
  RecDelete(853,0);
  RecInsert(853,0);
  RTy.Nummer            # 401;
  RTy.Bezeichnung       # 'VK-Sammelrechnung';
  RecDelete(853,0);
  RecInsert(853,0);
  RTy.Nummer            # 409;
  RTy.Bezeichnung       # 'VK-Stornorechnung';
  RecDelete(853,0);
  RecInsert(853,0);
  RTy.Nummer            # 410;
  RTy.Bezeichnung       # 'Gutschrift';
  RecDelete(853,0);
  RecInsert(853,0);
  RTy.Nummer            # 419;
  RTy.Bezeichnung       # 'Stornogutschrift';
  RecDelete(853,0);
  RecInsert(853,0);
  RTy.Nummer            # 420;
  RTy.Bezeichnung       # 'Belastung';
  RecDelete(853,0);
  RecInsert(853,0);
  RTy.Nummer            # 429;
  RTy.Bezeichnung       # 'Stornobelastung';
  RecDelete(853,0);
  RecInsert(853,0);

  ClipboardWrite('');


  if (vProt<>0) then
    TextAddLine(vProt, 'von Version : '+cnvaf(set.version.vorherig, _fmtNumnogroup, 0,5));

  if (Set.Installname='') then begin
    UrgentMsg('INSTALLNAME in den Settings muss gefüllt werden!');
  end;
  vVonNach # cnvaf(set.version.vorherig, _FmtNumLeadZero|_fmtNumnogroup, 0,5,8)+'|'+cnvaf(vVersionNeu, _FmtNumLeadZero|_fmtNumnogroup, 0,5,8);

  // ------------------------------------------------
  if (Set.Version.Vorherig<1.1010) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf A');

    // 25.11.2008 - ERL.Rechnungstypen
    vOK # n;    // "alte" 499 suchen; wenn vorhanden, dann alles konvertieren...
    vErg # RecRead(450,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if (Erl.Rechnungstyp=499) then vOK # Y;
      vErg # RecRead(450,1,_recNext);
    END;

    if (vOK) then begin
      vErg # RecRead(450,1,_recFirst);
      WHILE (vErg<=_rLocked) do begin

        RecRead(450,1,_RecLock);

        if (Erl.Rechnungstyp=499) then Erl.Rechnungstyp # 409
        else if (Erl.Rechnungstyp=409) then Erl.Rechnungstyp # 401;

        if (Erl.Rechnungstyp=400) or (Erl.Rechnungstyp=409) then begin
          vErg # RecLink(451,450,1,_RecFirst);    // Konten loopen
          WHILE (vErg<=_rLocked) and (Erl.K.Auftragsnr=0) do
            vErg # RecLink(451,450,1,_RecNext);
          if (vErg<=_rLocked) and (Erl.K.Auftragsnr<>0) then begin
            Auf.Nummer # Erl.K.Auftragsnr;
            vErg # Recread(400,1,0);  // Auftrag holen
            if (vErg>_rLocked) then begin
              "Auf~Nummer" # Erl.K.Auftragsnr;
              vErg # Recread(410,1,0);  // ~Auftrag holen
              if (vErg>_rLocked) then RecBufClear(410);
              recBufCopy(410,400);
            end;
            if (Auf.Vorgangstyp='GUT') or (Auf.Vorgangstyp='GUT-KD') or (Auf.Vorgangstyp='GUT-LF') then begin
              if (Erl.Rechnungstyp=400) then Erl.Rechnungstyp  # 410
              else Erl.Rechnungstyp  # 419;
            end;
            if (Auf.Vorgangstyp='BEL') or (Auf.Vorgangstyp='BEL-KD') or (Auf.Vorgangstyp='BEL-LF') then begin
              if (Erl.Rechnungstyp=400) then Erl.Rechnungstyp  # 420
              else Erl.Rechnungstyp  # 429;
            end;
          end;
        end;

        RecReplace(450,_RecUnlock);

        vErg # RecRead(450,1,_recNext);
      END;
    end;
    // ------------------------------------------------


    // ------------------------------------------------
    // 26.11.2008 - Auftragsarten:
    vErg # RecRead(400,1,_recfirst);
    WHILE (verg<=_rLockeD) do begin
      if (Auf.Vorgangstyp='GUT') or (Auf.Vorgangstyp='BEL') then begin
        recread(400,1,_recLock);
        if (Auf.Vorgangstyp='GUT') then Auf.Vorgangstyp # 'GUT-KD';
        if (Auf.Vorgangstyp='BEL') then Auf.Vorgangstyp # 'BEL-KD';
        RecReplace(400,_RecUnlock);
      end;
      vErg # RecRead(400,1,_recNext);
    END;
    vErg # RecRead(410,1,_recfirst);
    WHILE (verg<=_rLockeD) do begin
      if ("Auf~Vorgangstyp"='GUT') or ("Auf~Vorgangstyp"='BEL') then begin
        recread(410,1,_recLock);
        if ("Auf~Vorgangstyp"='GUT') then "Auf~Vorgangstyp" # 'GUT-KD';
        if ("Auf~Vorgangstyp"='BEL') then "Auf~Vorgangstyp" # 'BEL-KD';
        RecReplace(410,_RecUnlock);
      end;
      vErg # RecRead(410,1,_recNext);
    END;

    vErg # RecRead(899,1,_recfirst);
    WHILE (vErg<=_rLockeD) do begin
      if (Sta.Auf.Vorgangstyp='GUT') or (Sta.Auf.Vorgangstyp='BEL') then begin
        recread(899,1,_recLock);
        if (Sta.Auf.Vorgangstyp='GUT') then Sta.Auf.Vorgangstyp # 'GUT-KD';
        if (Sta.Auf.Vorgangstyp='BEL') then Sta.Auf.Vorgangstyp # 'BEL-KD';
        RecReplace(899,_recUnlock);
      end;
      vErg # RecRead(899,1,_recNext);
    END;
    // ------------------------------------------------


    // ------------------------------------------------
    // 09.02.2009 - neue Datensätze...
    RecbufClear(820);
    Mat.Sta.Nummer        # 503;
    Mat.Sta.neueNummer    # 503;
    Mat.Sta.Bezeichnung   # 'VSB-EK-Konsi';
    RecInsert(820,0);
    // ------------------------------------------------


    // ------------------------------------------------
    // 20.07.2009 - neue Datensätze...
    RecbufClear(820);
    Mat.Sta.Nummer        # 712;
    Mat.Sta.neueNummer    # 712;
    Mat.Sta.Bezeichnung   # 'zum Versand';
    RecInsert(820,0);

    RecbufClear(828);
    "ArG.Typ.1In-1OutYN"  # y;
    ArG.Aktion            # 'VERSND';
    ArG.Aktion2           # 'VERSND';
    ArG.Bezeichnung       # 'Versand';
    RecInsert(828,0);
    // ------------------------------------------------


    // ------------------------------------------------
    // 06.11.2009 - neues Feld: Mat.Datum.Erzeugt
    vErg # RecRead(200,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if (MAt.Datum.Erzeugt=0.0.0) then begin
        vErg # RecRead(200,1,_recLock);
        Mat.Datum.Erzeugt # Mat.Eingangsdatum;
        if (Mat.Datum.Erzeugt=0.0.0) then Mat.Datum.Erzeugt # Mat.Anlage.Datum;
        RecReplace(200,_recUnlock);
      end;
      vErg # RecRead(200,1,_recNext);
    END;
    vErg # RecRead(210,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if ("MAt~Datum.Erzeugt"=0.0.0) then begin
        vErg # RecRead(210,1,_recLock);
        "Mat~Datum.Erzeugt" # "Mat~Eingangsdatum";
        if ("Mat~Datum.Erzeugt"=0.0.0) then "Mat~Datum.Erzeugt" # "Mat~Anlage.Datum";
        RecReplace(210,_recUnlock);
      end;
      vErg # RecRead(210,1,_recNext);
    END;
    // ------------------------------------------------


    // ------------------------------------------------
    // 23.12.2009 - neue Artikeljournalsortierung
    RecBufClear(253);
    vErg # RecRead(253,3,_recFirst);
    WHILE (verg<=_rLocked) and (Art.J.Anlage.Datum=0.0.0) do begin

      RecRead(253,1,_recLock);
      Art.J.Anlage.Datum # Art.J.Datum;
      RecReplace(253,_recUnlock);

      vErg # RecRead(253,3,_recFirst);
    END;
    // ------------------------------------------------


    // ------------------------------------------------
    // 08.02.2010 - neues Feld: ZAB.Kurzbezeichnung
    vErg # RecRead(816,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if (ZaB.Kurzbezeichnung='') then begin
        vErg # RecRead(816,1,_recLock);
        Zab.Kurzbezeichnung # StrCut(ZaB.Bezeichnung1.L1+' '+ZaB.Bezeichnung2.L1,1,64);
        RecReplace(816,_recUnlock);
      end;
      vErg # RecRead(816,1,_recNext);
    END;
    // ------------------------------------------------


    // ------------------------------------------------
    // 18.02.2010 - neue Datensätze...
    RecbufClear(853);
    RTy.Nummer            # 415;
    RTy.Bezeichnung       # 'LF-Gutschrift';
    RecDelete(853,0);
    RecInsert(853,0);
    RTy.Nummer            # 418;
    RTy.Bezeichnung       # 'LF-Stornogutschrift';
    RecDelete(853,0);
    RecInsert(853,0);
    RTy.Nummer            # 425;
    RTy.Bezeichnung       # 'LF-Belastung';
    RecDelete(853,0);
    RecInsert(853,0);
    RTy.Nummer            # 428;
    RTy.Bezeichnung       # 'LF-Stornobelastung';
    RecDelete(853,0);
    RecInsert(853,0);
    // ------------------------------------------------

    // ------------------------------------------------
    // 15.03.2010 MS - User-Zoomfaktor vorbelegen
    FOR vErg # RecRead(800, 1, _recFirst);
    LOOP vErg # RecRead(800, 1, _recNext);
    WHILE(vErg <= _rLocked) DO BEGIN
      if(Usr.Zoomfaktor <> 0) then // Zoomfaktor bereits belegt
        CYCLE;
      else begin
        vErg # RecRead(800, 1, _recLock);
        Usr.Zoomfaktor # 100; // falls nicht vorbelegt, STANDARD = 100
        vErg # RecReplace(800, _recUnlock);
      end;
    END;
    // ------------------------------------------------


    // ------------------------------------------------
    // 29.03.2010 - neue Felder: ZAB.Fälligkeit2
    vErg # RecRead(816,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin

      if (("ZaB.Fällig2.Zieltage"=0) or ("ZaB.Fällig2.Fixtag"=0) or ("ZaB.Fällig2.FixMonat"=0)) and
        ((ZaB.Sknt2.VonTag<>0) or (ZaB.Sknt2.BisTag<>0)) then begin
        vErg # RecRead(816,1,_recLock);
        "ZaB.Fällig2.ZielTage"  # "ZaB.Fällig1.ZielTage";
        "ZaB.Fällig2.FixTag"    # "ZaB.Fällig1.FixTag";
        "ZaB.Fällig2.FixMonat"  # "ZaB.Fällig1.FixMonat";
        RecReplace(816,_recUnlock);
      end;

      vErg # RecRead(816,1,_recNext);
    END;
    // ------------------------------------------------


    // ------------------------------------------------
    // 12.04.2010 - Spediteure über Adr.Nummer verknüpfen...
    if (Set.Version.Vorherig<1.1014) then begin

      if (vProt<>0) then
        TextAddLine(vProt, 'Lauf B');

      // Versand
      vERG # RecRead(650,1, _RecFirst);
      WHILE (vERG = _rOk) do begin
        if (Vsd.Spediteurnr <> 0) then begin
          vERG # RecRead(650,1, _recLock);
          if (vERG = _rOk) then begin
            Adr.LieferantenNr # Vsd.Spediteurnr;
            vERG # RecRead(100,3,0);                 // Lieferant lesen
            if (vERG <= _rMultiKey) then
              Vsd.Spediteurnr # Adr.Nummer;
            RecReplace(650, _RecUnlock);
          end;
        end;
        verg # RecRead(650,1, _RecNext);
      END;

      // VersandPool
      vERG # RecRead(655,1, _RecFirst);
      WHILE (vERG = _rOk) do begin
        if (VsP.Spediteurnr <> 0) then begin
          vERG # RecRead(655,1, _recLock);
          if (vERG = _rOk) then begin
            Adr.LieferantenNr # VsP.Spediteurnr;
            vERG # RecRead(100,3,0);                 // Lieferant lesen
            if (vERG <= _rMultiKey) then
              VsP.Spediteurnr # Adr.Nummer;
            RecReplace(655, _RecUnlock);
          end;
        end;
        verg # RecRead(655,1, _RecNext);
      END;

      // VersandPool-ABLAGE
      vERG # RecRead(656,1, _RecFirst);
      WHILE (vERG = _rOk) do begin
        if ("VsP~Spediteurnr" <> 0) then begin
          vERG # RecRead(656,1, _recLock);
          if (vERG = _rOk) then begin
            Adr.LieferantenNr # "VsP~Spediteurnr";
            vERG # RecRead(100,3,0);                 // Lieferant lesen
            if (vERG <= _rMultiKey) then
              "VsP~Spediteurnr" # Adr.Nummer;
            RecReplace(656, _RecUnlock);
          end;
        end;
        verg # RecRead(656,1, _RecNext);
      END;

    end;
    // ------------------------------------------------


    // ------------------------------------------------
    // 18.04.2010 - speziel Maske beim BA-FM für Betrieb
    RecBufClear(906);
    Dia.Bereich # 'BA1.FM.Maske_Betrieb';
    Dia.Name    # 'BA1.FM.Maske';
    RecInsert(906,0);
    // ------------------------------------------------


    // ------------------------------------------------
    // 20.04.2010 - neue Datensätze...
    RecbufClear(820);
    Mat.Sta.Nummer        # 650;
    Mat.Sta.neueNummer    # 650;
    Mat.Sta.Bezeichnung   # 'im Versand';
    Mat.Sta.Bemerkung     # 'im Versandpool';
    RecInsert(820,0);
    Mat.Sta.Nummer        # 651;
    Mat.Sta.neueNummer    # 651;
    Mat.Sta.Bezeichnung   # 'aus Versand entfernt';
    Mat.Sta.Bemerkung     # 'wieder aus dem Versandpool entfernt';
    RecInsert(820,0);
    // ------------------------------------------------
  end;


  /*
  // ------------------------------------------------
  // 03.05.2010 - neues Feld: Berechenbare Mengen im Auftrag
  if (Set.Version.Vorherig<1.1018) then begin
    vErg # RecRead(401,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if ("Auf.P.Löschmarker"='') and (Auf.P.Aktionsmarker='$') then begin
        Auf_A_Data:RecalcAll();
      end;
      vErg # RecRead(401,1,_recNext);
    END;
  end;
  // ------------------------------------------------
  */


  // 02.07.2010 - BAG-Inputs-Weiterbearbeitungen haben KEINE Materialnummer!!
  if (Set.Version.Vorherig<1.1026) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf C');

    // BA-Input
    vERG # RecRead(701,1, _RecFirst);
    WHILE (vERG = _rOk) do begin
      if (BAG.IO.Materialtyp=703) and (BAG.IO.Materialnr<>0) then begin
        vERG # RecRead(701,1, _recLock);
        BAG.IO.Materialnr # 0;
        RecReplace(701, _RecUnlock);
      end;
      verg # RecRead(701,1, _RecNext);
    END;
  end;
  // ------------------------------------------------


  // ------------------------------------------------
  // 16.08.2010 - Lfs.Positionsgewichte summieren
  if (Set.Version.Vorherig<1.1033) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf D');

    vErg # RecRead(440,1,_recFirst);
    WHILE (vErg<=_rLockeD) do begin   // LFS loopen

      vN # 0.0;
      vErg # RecLink(441, 440, 4, _recFirst);
      WHILE(vErg <= _rLocked) DO BEGIN
        vN # vN + Lfs.P.Gewicht.Brutto;
        vErg # RecLink(441, 440, 4, _recNext);
      END;

      RecRead(440,1,_recLock);
      Lfs.Positionsgewicht  # vN;
      RecReplace(440,_recUnlock);

      vErg # RecRead(440,1,_recNext);
    END;
  end;
  // ------------------------------------------------


  // ------------------------------------------------
  // 26.10.2010 - manuelles Löschen von Mat. legt Schrottkarte an
  if (Set.Version.Vorherig<1.1043) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf E');

    RecbufClear(820);
    Mat.Sta.Nummer        # 299;
    Mat.Sta.neueNummer    # 299;
    Mat.Sta.Bezeichnung   # 'verschrottet';
    Mat.Sta.Bemerkung     # 'manueller Schrott';
    RecInsert(820,0);
  end;
  // ------------------------------------------------


  // -- 24.11.2010 -------------------------------------------
  // Projektaustausch: Austauschprojekte aktualisieren
  if ( Set.Version.Vorherig < 1.1047 ) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf F');

    FOR  vErg # RecRead( 120, 1, _recFirst );
    LOOP vErg # RecRead( 120, 1, _recNext );
    WHILE ( vErg <= _rLocked ) DO BEGIN
      // Austauschprojekt
      if ( Prj.AustauschPrjNr = 0 ) and ( Prj.Nummer > 1000000 ) then begin
        RecRead( 120, 1, _recLock );
        Prj.AustauschPrjNr # Prj.Nummer - 1000000;
        Prj.AustauschYN    # false;
        RecReplace( 120, _recUnlock );
      end

      vOk # false;
      FOR  vErg # RecLink( 122, 120, 4, _recFirst );
      LOOP vErg # RecLink( 122, 120, 4, _recNext );
      WHILE ( vErg <= _rLocked ) DO BEGIN
        if ( StrCut( Prj.P.Referenznr, 1, 3 ) = 'AP:' ) then begin
          vOk # true; // ist Austauschprojekt oder Originalprojekt
          vI  # StrFind( Prj.P.Referenznr, ':', 4 );

          // Projektposition aktualisieren
          RecRead( 122, 1, _recLock );
          Prj.P.AustauschId  # -1;
          Prj.P.AustauschPos # CnvIA( StrCut( Prj.P.Referenznr, 4, vI - 4 ) );
          Prj.P.Referenznr   # StrDel( Prj.P.Referenznr, 1, vI );
          RecReplace( 122, _recUnlock );
        end;
      END;

      // Originalprojekt
      if ( vOk ) and ( Prj.Nummer < 1000000 ) then begin
        RecRead( 120, 1, _recLock );
        Prj.AustauschYN # true;
        RecReplace( 120, _recUnlock );
      end;
    END;
  end;
  // ---------------------------------------------------------


  // -- 17.01.2011 -------------------------------------------
  // EK-Projektnummer aus WE in Material kopieren...
  if ( Set.Version.Vorherig < 1.1103 ) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf G');

    FOR vErg # RecRead(200,1,_recFirst);
    LOOP vErg # RecRead(200,1,_recNext);
    WHILE (vErg<=_rLocked) do begin
      if(Mat.EK.Projektnr <> 0) then
        CYCLE;

      if (Mat.Einkaufsnr<>0) then begin
        vErg # RecLink(500,200,30,_recFirst);        // Bestellung holen
        if (vErg>_rLocked) then begin
          vErg # RecLink(510,200,31,_recFirst);      // ~Bestellung holen
          if (vErg>_rLocked) then begin
            recBufClear(510);
            recBufClear(511);
            end
          else begin
            vErg # RecLink(511,200,19,_recFirst);    // ~BestellPos holen
          end;
          RecbufCopy(510,500);
          RecBufCopy(511,501);
          end
        else begin
          vErg # RecLink(501,200,18,_recFirst);      // BestellPos holen
        end;
        vErg # RecRead(200,1,_recLock);
        Mat.EK.Projektnr    # Ein.P.Projektnummer;
        RecReplace(200,_recUnlock);
      end;
    END;

    FOR vErg # RecRead(210,1,_recFirst);
    LOOP vErg # RecRead(210,1,_recNext);
    WHILE (vErg<=_rLocked) do begin
      if("Mat~EK.Projektnr" <> 0) then
        CYCLE;

      RecBufCopy(210,200);
      if (Mat.Einkaufsnr<>0) then begin
        vErg # RecLink(500,200,30,_recFirst);        // Bestellung holen
        if (vErg>_rLocked) then begin
          vErg # RecLink(510,200,31,_recFirst);      // ~Bestellung holen
          if (vErg>_rLocked) then begin
            recBufClear(510);
            recBufClear(511);
            end
          else begin
            vErg # RecLink(511,200,19,_recFirst);    // ~BestellPos holen
          end;
          RecbufCopy(510,500);
          RecBufCopy(511,501);
          end
        else begin
          vErg # RecLink(501,200,18,_recFirst);      // BestellPos holen
        end;
        vErg # RecRead(210,1,_recLock);
        "Mat~EK.Projektnr"    # Ein.P.Projektnummer;
        RecReplace(210,_recUnlock);
      end;

    END;
  end;
  // ---------------------------------------------------------


  // -- 10.03.2011 -------------------------------------------
  // Projekttexte: Positionsnummer auf 4 Stellen erweitern
/** machte irgendwie Ärger
  if ( Set.Version.Vorherig < 1.1110 ) then begin
    vHdl # TextOpen( 16 );
    if ( vHdl->TextRead( '~122', _textNoContents ) = _rNoKey ) then begin
      vA # vHdl->TextInfoAlpha( _textName );
      REPEAT BEGIN
        vErg # vHdl->TextRead( vA, _textNext | _textNoContents );
        if ( StrCut( vA, 1, 4 ) != '~122' ) then
          BREAK;

        TextRename( vA, StrCut( vA, 1, 14 ) + '0' + StrCut( vA, 15, 5 ), 0 );
        vA # vHdl->TextInfoAlpha( _textName );
      END
      UNTIL ( vErg > _rLastRec );
    end;
    vHdl->TextClose();
  end;
**/
  // ---------------------------------------------------------



  // -- 24.03.2011 -------------------------------------------
  // Kreditlimit im Auftrag
  if ( Set.Version.Vorherig < 1.1113 ) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf H');

    vErg # RecRead(400,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if (Auf.Freigabe.WertW1=0.0) and (Auf.Vorgangstyp='AUF') then begin
        RecRead(400,1,_recLock);
        Auf.Freigabe.WertW1 # 1.0;
        Auf.Freigabe.DAtum # 1.1.1900;
        RecReplace(400,_recUnlock);
      end;
      vErg # RecRead(400,1,_recNext);
    END;
    vErg # RecRead(410,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if ("Auf~Freigabe.WertW1"=0.0) and ("Auf~Vorgangstyp"='AUF') then begin
        RecRead(410,1,_recLock);
        "Auf~Freigabe.WertW1" # 1.0;
        "Auf~Freigabe.DAtum" # 1.1.1900;
        RecReplace(410,_recUnlock);
      end;
      vErg # RecRead(410,1,_recNext);
    END;

  end;



  // --- 15.08.2011 ------------------------------------------
  // Einzelrechnungspreis in Aktionslisten schreiben...

  if ( Set.Version.Vorherig < 1.1133 ) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf I');

    vErg # RecRead(404,1,_recfirst);
    WHILE (verg<=_rLocked) do begin

      if (Auf.A.Rechnungsnr<>0) and
        (Auf.A.RechpreisW1<>0.0)  and (Auf.A.Menge.Preis<>0.0) then begin

        // passene AufPos holen...
        vErg # RecLink(401,404,1,_recFirst);     // AufPosition holen
        if (verg<=_rLocked) then begin
          vErg # RecLink(400,401,3,_recFirst);   // AufKopf holen
          end
        else begin
          vErg # RecLink(411,404,7,_recFirst);     // AufPosition Ablage holen
          if (verg<=_rLocked) then begin
            vErg # RecLink(410,411,3,_recFirst);   // AufKopf Ablage holen
            end
          else begin
            RecBufClear(400);
            RecBufClear(401);
          end;
          RecbufCopy(410,400);
          RecbufCopy(411,401);
        end;

        if (Auf.P.Nummer<>0) then begin
          vErg # RecLink(450,404,9,_recFirst);   // Rechnung holen
          if (vErg>_rLocked) then "Erl.Währungskurs" # "Auf.Währungskurs";
          if ("Erl.Währungskurs"=0.0) then "Erl.Währungskurs" # 1.0;

          RecRead(404,1,_recLock);
          Auf.A.RechPEH         # Auf.P.PEH;
          Auf.A.RechGrundPrsW1  # Rnd(Auf.P.Grundpreis/ "Erl.Währungskurs",2)
          RecReplace(404,_recUnlock);
        end;

      end;

      vErg # RecRead(404,1,_recNext);
    END;
  end;
  // ---------------------------------------------------------


  // -- 16.08.2011 -------------------------------------------
  // Sperre im Einkuaf
  if ( Set.Version.Vorherig < 1.1133 ) then begin

    if (vProt<>0) then
      TextAddLine(vProt, 'Lauf J');

    vErg # RecRead(500,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if (Ein.Freigabe.WertW1=0.0) then begin
        RecRead(500,1,_recLock);
        Ein.Freigabe.WertW1 # 1.0;
        Ein.Freigabe.DAtum # 1.1.1900;
        RecReplace(500,_recUnlock);
      end;
      vErg # RecRead(500,1,_recNext);
    END;
    vErg # RecRead(510,1,_recFirst);
    WHILE (vErg<=_rLocked) do begin
      if ("Ein~Freigabe.WertW1"=0.0) then begin
        RecRead(510,1,_recLock);
        "Ein~Freigabe.WertW1" # 1.0;
        "Ein~Freigabe.DAtum" # 1.1.1900;
        RecReplace(510,_recUnlock);
      end;
      vErg # RecRead(510,1,_recNext);
    END;
  end;
  // ---------------------------------------------------------


  // -- 07.09.2011 -------------------------------------------
  // anderes Setting
//  if ( Set.Version.Vorherig < 1.1137 ) then begin
//    RecRead(903,1,_recFirst);
//    if (Set.Auf.MatNr.Ablauf=0) then begin
//      RecRead(903,1,_reclock);
//      if (Set.Auf._____ReserYN) then Set.Auf.MatNr.Ablauf # 2
//      else Set.Auf.MatNr.Ablauf # 3;
//      RecReplace(903,_recUnlock);
//    end;
//  end;
  // ---------------------------------------------------------

  // --- 13.03.2012 ------------------------------------------
  // neuer Status
  if ( Set.Version.Vorherig < 1.1211 ) then begin
    RecbufClear(820);
    Mat.Sta.Nummer        # 951;
    Mat.Sta.neueNummer    # 951;
    Mat.Sta.Bezeichnung   # 'Gesperrt WE Betrieb';
    Mat.Sta.Bemerkung     # 'durch allgemeinen WE im Betrieb';
    RecInsert(820,0);
  end;


  // --- 30.05.2012 ------------------------------------------
  // Rechnungsanschrift im Auftrag
  if ( Set.Version.Vorherig < 1.1222 ) then begin
    vErg # RecRead(400,1,_recfirst);
    WHILE (verg<=_rLockeD) do begin
      if (Auf.Rechnungsanschr=0) then begin
        Recread(400,1,_recLock);
        Auf.Rechnungsanschr # 1;
        RecReplace(400,_RecUnlock);
      end;
      vErg # RecRead(400,1,_recNext);
    END;
    vErg # RecRead(410,1,_recfirst);
    WHILE (verg<=_rLockeD) do begin
      if ("Auf~Rechnungsanschr"=0) then begin
        Recread(410,1,_recLock);
        "Auf~Rechnungsanschr" # 1;
        RecReplace(410,_RecUnlock);
      end;
      vErg # RecRead(410,1,_recNext);
    END;
  end;


  // --- 04.06.2012 ------------------------------------------
  // SOQ-PFad
  if ( Set.Version.Vorherig < 1.1223 ) then begin
    UrgentMsg('Bitte ggf. SOA-Pfad überprüfen! (Struktur sollte so sein ..\SC_SOA\LOG)');
//    WinDialogBox( 0, 'ACHTUNG', 'Bitte ggf. SOA-Pfad überprüfen! (Struktur sollte so sein ..\SC_SOA\LOG', _winIcoWarning, _WinDialogOk, 1 );
  end;


  // --- 21.06.2012 ------------------------------------------
  // Steuerschlüssel in Hauptanschrift
  if ( Set.Version.Vorherig < 1.1225 ) then begin
    vErg # RecRead(100,1,_recfirst);
    WHILE (verg<=_rLockeD) do begin
      vErg # RecLink(101,100,12,_RecFirsT);
      if (vErg<=_rLocked) and (Adr.A.Nummer=1) then begin
        RecRead(101,1,_recLock);
        "Adr.A.Steuerschlüsse"  # "Adr.Steuerschlüssel";
        RecReplace(101,_RecUnlock);
      end;
      vErg # RecRead(100,1,_recNext);
    END;
  end;


  // --- 31.07.2012 ------------------------------------------
  // neues Kontaktesystem
  if ( Set.Version.Vorherig < 1.1231 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Adr_Ktd_Data:Rebuild" starten!');
  end;

  // --- 08.10.2012 ------------------------------------------
  // neue Zahlungsarten
  if ( Set.Version.Vorherig < 1.1241 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL ZAu_Data:ConvertAltNachNeu" starten!');
  end;

  // --- 20.03.2013 ------------------------------------------
  // Mat-DFAKT mit Artikelnummer füllen
  if ( Set.Version.Vorherig < 1.1312 ) then begin
    FOR vErg # RecRead(404,1,_recFirst)
    LOOP vErg # RecRead(404,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (Auf.A.Aktionstyp<>'DFAKT') then CYCLE;
      if (Auf.A.Materialnr=0) then CYCLE;
      if (Auf.A.Artikelnr<>'') then CYCLE;

      // passene AufPos holen...
      vErg # RecLink(401,404,1,_recFirst);     // AufPosition holen
      if (verg<=_rLocked) then begin
        vErg # RecLink(400,401,3,_recFirst);   // AufKopf holen
        end
      else begin
        vErg # RecLink(411,404,7,_recFirst);     // AufPosition Ablage holen
        if (verg<=_rLocked) then begin
          vErg # RecLink(410,411,3,_recFirst);   // AufKopf Ablage holen
          end
        else begin
          RecBufClear(400);
          RecBufClear(401);
        end;
        RecbufCopy(410,400);
        RecbufCopy(411,401);
      end;

      if (Auf.P.Wgr.Dateinr=209) then begin  // ggf. Artikelnummer für 209er übernehmen
        Mat.Nummer # Auf.A.Materialnr;
        vErg # RecRead(200,1,0);
        if (vErg>_rLocked) then begin
          "Mat~Nummer" # Auf.A.Materialnr;
          vErg # RecRead(210,1,0);
          if (vErg>_rLocked) then CYCLE;
          RecbufCopy(210,200);
        end;
        RecRead(404,1,_recLock);
        Auf.A.ArtikelNr # Mat.Strukturnr;
        RecReplace(404,_recunlock);
      end;

    END;
  end;

  // --- 26.04.2013 ------------------------------------------
  // MatMEH aktivieren
  if ( Set.Version.Vorherig < 1.1317 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Repair_Mat:MehAktivieren" starten!');
  end;


  // --- 14.06.2013 / ST ------------------------------------------
  //  Löschen von Kalkulationen ohne Kopfdaten
  if ( Set.Version.Vorherig < 1.1323 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Repair_KAL_P:Del_KalP_ohne_Kal" starten!');
  end;


  // --- 20.09.2013 / AH ------------------------------------------
  //  Andere Bergriffe für Gutschrift/Rechnungskorrektur
  if ( Set.Version.Vorherig < 1.1338 ) then begin

    RecDeleteAll(997);    // SYNC ERZWINGEN

    FOR vErg # RecRead(400,1,_recFirst)
    LOOP vErg # RecRead(400,1,_recNext)
    WHILE (verg<=_rLocked) DO begin
      vA # '';
      if (Auf.Vorgangstyp='GUT-KD') then vA # 'REKOR';
      if (Auf.Vorgangstyp='GUT-LF') then vA # 'GUT';
      if (vA<>'') then begin
        RecRead(400,1,_recLock);
        Auf.Vorgangstyp # vA;
        RecReplace(400,_recunlock);
      end;
    END;
    FOR vErg # RecRead(410,1,_recFirst)
    LOOP vErg # RecRead(410,1,_recNext)
    WHILE (verg<=_rLocked) DO begin
      vA # '';
      if ("Auf~Vorgangstyp"='GUT-KD') then vA # 'REKOR'
      if ("Auf~Vorgangstyp"='GUT-LF') then vA # 'GUT';
      if (vA<>'') then begin
        RecRead(410,1,_recLock);
        "Auf~Vorgangstyp" # vA;
        RecReplace(410,_recunlock);
      end;
    END;
    FOR vErg # RecRead(899,1,_recFirst)
    LOOP vErg # RecRead(899,1,_recNext)
    WHILE (verg<=_rLocked) DO begin
      vA # '';
      if (Sta.Auf.Vorgangstyp='GUT-KD') then vA # 'REKOR';
      if (Sta.Auf.Vorgangstyp='GUT-LF') then vA # 'GUT';
      if (vA<>'') then begin
        RecRead(899,1,_recLock);
        Sta.Auf.Vorgangstyp # vA;
        RecReplace(899,_recunlock);
      end;
    END;
  end;


  // --- 08.10.2013 / AH ------------------------------------------
  //  Arbeitsgänge mit MEH
  if ( Set.Version.Vorherig < 1.1341 ) then begin
    RecDeleteAll(997);    // SYNC ERZWINGEN
    FOR vErg # RecRead(828,1,_recFirst)
    LOOP vErg # RecRead(828,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (ArG.MEH='') then begin
        RecRead(828,1,_recLock);
        if (ArG.Aktion=c_BAG_Tafel) or (Arg.Aktion=c_BAG_ABCOIL) then
          ArG.MEH # 'qm'
        else if (ArG.Aktion=c_BAG_abLaeng) or (ArG.Aktion=c_BAG_Saegen) then
          ArG.MEH # 'm'
        else
          ArG.MEH # 'kg';
        RecReplace(828,_recunlock);
      end;
    END;
  end;


  // --- 18.10.2013 / AH ------------------------------------------
  //  Bestellungen als Anfragen
  if ( Set.Version.Vorherig < 1.1344 ) then begin
    RecDeleteAll(997);    // SYNC ERZWINGEN
    FOR vErg # RecRead(500,1,_recFirst)
    LOOP vErg # RecRead(500,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (Ein.Vorgangstyp='') then begin
        RecRead(500,1,_recLock);
        Ein.Vorgangstyp # 'BEST';
        RecReplace(500,_recunlock);
      end;
    END;
    FOR vErg # RecRead(510,1,_recFirst)
    LOOP vErg # RecRead(510,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if ("Ein~Vorgangstyp"='') then begin
        RecRead(510,1,_recLock);
        "Ein~Vorgangstyp" # 'BEST';
        RecReplace(510,_recunlock);
      end;
    END;
  end;

  // --- 20.12.2013 ------------------------------------------
  // neues Feld Dehnung-Bis und das Setting dafür
  if (Set.Mech.Dehnung.Wie=0) then begin
    UrgentMsg('Bitte UNBEDINGT das Chemie-Setting für Dehnungslängenfeld setzen!');
  end;



  // --- 21.02.2014 ------------------------------------------
  // TeM.Anker neues Schlüsselfeld
  if ( Set.Version.Vorherig < 1.1409 ) then begin
    FOR vErg # RecRead(981,1,_recFirst)
    LOOP vErg # RecRead(981,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (Tem.A.Key='') then begin
        if (Tem.A.Datei=800) then CYCLE;

        vI # -1;
        vJ # -1;
        vA # StrCut(Tem.A.Code, 3,100);

        vI # cnvia(Lib_Strings:Strings_Token(vA,'/',1));
        case Tem.A.Datei of
          102,401,122,501,702 : vJ # cnvia(Lib_Strings:Strings_Token(vA,'/',2));
        end;

        if (vI<>-1) then begin
          RecRead(981,1,_recLock);
          Tem.A.Key # CnvAI(vI) + StrChar(255,1);
          if (vJ<>-1) then Tem.A.Key # Tem.A.Key + CnvAI(vJ) + StrChar(255,1);
          RecReplace(981,0);
        end;
      end;
    END;
  end;


  // --- 07.08.2014 ------------------------------------------
  // BRUCH IN DER VERSIONSNUMMERLOGIK: fürher 1.14xx JETZT 1.4xx
  // ---------------------------------------------------------


  // --- 07.08.2014 ------------------------------------------
  // neues Setting "Set.OSt.Wie"
  if ( Set.Version.Vorherig < 1.434 ) then begin
    v903 # RecBufCreate(903);
    RecRead(v903,1,_recFirst);
    RecRead(v903,1,_recLock);
//    v903->Set.Ost.Wie # 'M';
    if (v903->Set.Crit.Prozedur<>'Crit_OST') then begin
      v903->Set.Crit.Prozedur     # 'Crit_OST';
      v903->Set.Crit.Start.datum  # SysDate();
    end;
    vErg # RecReplace(v903,0);
    RecBufDestroy(v903);
    UrgentMsg('Das Setting Finanzen->Onlinestatistik->Ermitteln wurde auf MANUELL gestellt!');
    UrgentMsg('Bitte Statistik manuell aufbauen per "Call Ost_Data:Initialize"');
  end;


  // --- 08.08.2014 ------------------------------------------
  // neues Feld "Erl.K.Artikelnummer" + "Erl.K.Güte"
  if ( Set.Version.Vorherig < 1.432 ) then begin
    FOR vErg # RecRead(451,1,_recFirst)
    LOOP vErg # RecRead(451,1,_recnext)
    WHILE (vErg<=_rLocked) do begin

      if (Erl.K.AuftragsPos<>0) then begin
        Auf.P.Nummer    # Erl.K.Auftragsnr;
        Auf.P.Position  # Erl.K.Auftragspos;
        vErg # RecRead(401,1,0);       // Auftragsposition holen
        if (vErg>_rLocked) then begin
          "Auf~P.Nummer"    # Erl.K.Auftragsnr;
          "Auf~P.Position"  # Erl.K.Auftragspos;
          vErg # RecRead(411,1,0);       // Ablageposition holen
          if (vErg>_rLocked) then CYCLE;
          RecBufCopy(411,401);
        end;
        // Problem: Aufpreis nicht auffindbar! also DIRTY
        if (Auf.P.Artikelnr<>'') or ("Auf.P.Güte"<>'') then begin
          RecRead(451,1,_recLock);
          Erl.K.Artikelnummer # Auf.P.Artikelnr;
          "Erl.K.Güte"        # "Auf.P.Güte";
          RecReplace(451,_recunlock);
        end;
      end;

    END;

  end;


  // --- 19.11.2014 ------------------------------------------
  // Mat.Bestandsbuch hatte SPLITTEN falsch protokolliert
  if ( Set.Version.Vorherig < 1.447 ) then begin
    FOR vErg # RecRead(202,1,_recFirst)
    LOOP vErg # RecRead(202,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (Mat.B.Bemerkung=c_Akt_SPLIT) then begin
        if (("Mat.B.Stückzahl"<0) or (Mat.B.Gewicht<0.0)) and (Mat.B.Menge>0.0) then begin
          RecRead(202,1,_reCLock);
          Mat.B.Menge # - Mat.B.Menge;
          RecReplace(202,_recunlock);
        end;
      end;
    END;
  end;


  // --- 02.02.2015 ------------------------------------------
  // Lib_Faktura hat Auf.A.RechnungsPreis falsch summiert
  // KORREKTUR 31.3.2015 s.u.

  // --- 11.02.2015 ------------------------------------------
  // Std.Lieferanschriften in Adressen
  // Tooltipzähler in INIs falsch
  if ( Set.Version.Vorherig < 1.5073) then begin
    // Adressen loopen und ggf. 99 als Lieferanschrift eintragen
    FOR vErg # RecRead(100,1,_recfirst)
    LOOP vErg # RecRead(100,1,_recNext)
    WHILE (vErg<=_rLocked) do begin

      RecRead(100,1,_recLock);
      Adr.VK.Std.Lieferadr # Adr.Nummer;
      Adr.VK.Std.Lieferans # 1;

      RecBufClear(101);
      Adr.A.Adressnr  # Adr.Nummer;
      Adr.A.Nummer    # 99;
      vErg # RecRead(101,1,0);
      if (vErg<=_rLocked) then
        Adr.VK.Std.Lieferans # 99;
      RecReplace(100,_Recunlock);
    END;

    // INIs loopen
    vBuf # TextOpen(16);
    FOR vErg # TextRead(vBuf,'INI.',0)
    LOOP vErg # TextRead(vBuf,vA,_TextNext)
    WHILE (vErg<=_rNoKey) do begin
      vA # TextInfoAlpha(vBuf,_TextName);
      if (vA>'INI.ZZZZZZ') then BREAK;
      vI # TextSearch(vBuf, 1, 1, 0, 'Tooltip=');
      if (vI>0) then begin
        vB # TextLineRead(vBuf, vI, 0);
        if (cnvia(Strcut(vB, 9,5))>3) then begin
          TextLineWrite(vBuf, vI, 'Tooltip=3', 0);
          TextWrite(vBuf, vA, 0);
        end;
      end;
    END;
    vBuf->TextClose();

  end;


  // --- 01.03.2015 ------------------------------------------
  // MatMix hatte bei Faktura Materialkarten nicht auf "Verkauft" gesetzt:
  if ( Set.Version.Vorherig < 1.511) then begin
    UrgentMsg('Bitte UNBEDINGT das Kommando "CALL TeM_A_Data:RepairBefore010315" starten!');
  end;


  // --- 26.03.2015 ------------------------------------------
  // MatMix hatte bei Faktura Materialkarten nicht auf "Verkauft" gesetzt:
  if ( Set.Version.Vorherig < 1.512) then begin
    UrgentMsg('Bitte UNBEDINGT das Kommando "CALL Repair_Mat:RebuildErlInfo" starten!');
  end;


  // --- 31.03.2015 ------------------------------------------
  // Lib_Faktura hat Auf.A.RechnungsPreis falsch summiert
  if ( Set.Version.Vorherig < 1.514 ) then begin
    Auf.A.Aktionsdatum # 1.8.2014;
    vErg # RecRead(404,11,0);
    vErg # RecRead(404,11,0);
    WHILE (Auf.A.Aktionsdatum>=1.8.2014) and (vErg<_rnorec) do begin
      if (Auf.A.Rechnungsnr<>0) and (Auf.A.Rechnungsdatum>=1.8.2014) then begin
        vErg # RecLink(450,404,9,_recFirst);    // Erlös holen
        if (vErg<=_rLocked) then begin
          vF  # 0.0;
          vF2 # 0.0;
          vM  # 0.0;
          vOK # false;
          FOR vErg # RecLink(451,450,1,_recFirst)
          LOOP vErg # RecLink(451,450,1,_recNext)
          WHILE (vErg<=_rLocked) do begin
            if (Erl.K.Auftragsnr=Auf.A.Nummer) and (Erl.K.Auftragspos=Auf.A.Position) then begin
              if (vOK=false) then vM  # Erl.K.Menge;
              vOK # true;
              vF  # vF + Erl.K.Betrag;
              vF2 # vF2 + Erl.K.BetragW1;
            end;
          END;
          if (vOK) then begin
            if (vM<>0.0) then begin
              vF  # Rnd((Auf.A.Menge.Preis / vM) * vF, 2);
              vF2 # Rnd((Auf.A.Menge.Preis / vM) * vF2, 2);
            end;
            if (vF<>Auf.A.Rechnungspreis) or (vF2<>Auf.A.RechPreisW1) then begin
              RecRead(404,1,_recLock);
              Auf.A.RechnungsPreis  # vF;
              Auf.A.RechPreisW1     # vF2;
              RecReplace(404,0);
            end;
          end;
        end;
      end;
      vErg # RecRead(404,11,_recNext);
    END;
  end;


  // --- 14.04.2015 ------------------------------------------ (24.02.2016)
  // Vorgabetexte mit CR/LF speichern (ST hatte Konvertierung vergessen!)
  if ( Set.Version.Vorherig < 1.515 ) then begin
    vTxt # TextOpen(16);
    vErg # TextRead(vTxt,'~837.',_TextNoContents);
    vA # TextInfoAlpha(vTxt,_TextName);
    WHILE (vA>'~837.') and (vA<='~837.99999999') and (vErg<4) do begin

      TextClear(vTxt);
      vErg # TextRead(vTxt,vA,0);
      vJ # TextInfo(vTxt, _TextLines);
      FOR vI # 1
      LOOP inc(vI)
      WHILE (vI<=vJ) do begin
        vB # TextLineread(vTxt, vI, 0);
        TextLineWrite(vTxt, vI, vB, 0);
      END;
      TextDelete(vA,0);
      TextWrite(vTxt, vA, 0);

      vErg # TextRead(vTxt,vA,_TextNoContents | _TextNext);
      vA # TextInfoAlpha(vTxt,_TextName);
    END;
    TextClose(vTxt);
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 1000');
    end;
  end;


  // --- 13.05.2015 ------------------------------------------
  // Rechnungsanschrift in Adressen
  if ( Set.Version.Vorherig < 1.520 ) then begin
    vErg # RecRead(100,1,_recfirst);
    WHILE (verg<=_rLocked) do begin
      if ("Adr.VK.ReEmpfänger"<>0) then begin
        RecRead(100,1,_recLock);
        Adr.VK.ReAnschrift  # 1;
        RecReplace(100,_RecUnlock);
      end;
      vErg # RecRead(100,1,_recNext);
    END;
  end;


  // --- 21.07.2015 ------------------------------------------
  // Flag in Adress-Verpackung: Einkauf, Verkauf
  // UND Textname verändet
  if ( Set.Version.Vorherig < 1.530 ) then begin
    FOR vErg # RecRead(105,1,_recFirst)
    LOOP vErg # RecRead(105,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (Adr.V.EinkaufYN=false) and (Adr.V.VerkaufYN=false) then begin
        RecRead(105,1,_reCLock);
        Adr.V.EinkaufYN # true;
        Adr.V.VerkaufYN # true;
        RecReplace(105,_recunlock);
      end;
      vA # '~105.'+CnvAI(Adr.V.AdressNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Adr.V.LfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
      vB # '~105.'+CnvAI(Adr.V.AdressNr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAI(Adr.V.LfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01';
      TextRename(vA, vB, 0);
      vA # '~105.'+CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      vB # '~105.'+CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4);
      TextRename(vA, vB, 0);
    END;

    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 1002');
      UrgentMsg('Sql_SyncOne 105');
      UrgentMsg('Sql_SyncOne 401');
      UrgentMsg('Sql_SyncOne 409');
      UrgentMsg('Sql_SyncOne 837');
      UrgentMsg('Sql_SyncOne 100');
      UrgentMsg('Sql_SyncOne 200');
      UrgentMsg('Sql_SyncOne 899');
    end;
  end;


  // --- 24.08.2015 ------------------------------------------
  // Werstellungsdatum in ERe
  if ( Set.Version.Vorherig < 1.535 ) then begin
    vErg # RecRead(560,1,_recfirst);
    WHILE (verg<=_rLocked) do begin
      if (Ere.Wertstellungsdat=0.0.0) then begin
        RecRead(560,1,_recLock);
        ERe.Wertstellungsdat # ERe.Rechnungsdatum;
        RecReplace(560,_RecUnlock);
      end;
      vErg # RecRead(560,1,_recNext);
    END;
  end;


  // --- 08.09.2015 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.537 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 560');
      UrgentMsg('Sql_SyncOne 835');
    end;
  end;

  // --- 29.10.2015 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.543 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 441');
    end;
  end;

  // --- 18.11.2015 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.547 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 259');
      UrgentMsg('Sql_SyncOne 230');
    end;
  end;


  // --- 03.03.2016 ------------------------------------------
  // UPGRADE 5.8  (INMEt HAT SCHON)
  if (DbaLicense(_DbaSrvLicense)<>'CE150892MN') and ( Set.Version.Vorherig < 1.609 ) then begin
    UrgentMsg('Bitte UNBEDINGT das Kommando "CALL Lib_Rec:Upgrade57to58" starten!');
    //Upgrade57to58();
  end;


  // --- 17.03.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.611 ) then begin

    v903 # RecBufCreate(903);
    RecRead(v903,1,_recFirst);
    RecRead(v903,1,_recLock);
    v903->Set.ERe.Prueftyp # 'B';
    vErg # RecReplace(v903,0);
    RecBufDestroy(v903);

    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 702');
      UrgentMsg('Sql_SyncOne 828');
      UrgentMsg('Sql_SyncOne 816');
      UrgentMsg('Sql_SyncOne 580');
      UrgentMsg('Sql_SyncOne 581');
    end;

    UrgentMsg('Bitte UNBEDINGT das Kommando "CALL BA1_P_Data:RepairStatus" starten!');
  end;


  // --- 25.04.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.617 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 120');
    end;
  end;

  // --- 09.05.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.618 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 800');
    end;
  end;

  // --- 09.05.2016 ------------------------------------------
  // Adresse: Buchungsnummern jetzt Alphanumerisch
  if ( Set.Version.Vorherig < 1.622 ) then begin
    FOR vERG # RecRead(100,1, _RecFirst)
    LOOP vERG # RecRead(100,1, _RecNext)
    WHILE (vERG = _rOk) do begin
      RecRead(100,1,_recLock);
      Adr.KundenFibuNr      # cnvai(Adr._KundenBuchNr, _FmtNumNogroup | _FmtNumNoZero);
      Adr.LieferantFibuNr   # cnvai(Adr._LieferantBuchNr, _FmtNumNogroup | _FmtNumNoZero);
      Adr._KundenBuchNr     # 0;
      Adr._LieferantBuchNr  # 0;
      RecReplace(100,0);
    END;
    // Dateien zum Syncen
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 100');
    end;
  end;

  // --- 20.05.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.625 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 122');
    end;
  end;


  // --- 14.07.2016 ------------------------------------------
  // Bug im Kontaktesystem
  if ( Set.Version.Vorherig < 1.628 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 107');
    end;
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Adr_Ktd_Data:Rebuild" starten!');
  end;


  // --- 11.08.2016 ------------------------------------------
  // Änderung der SFXen
  if ( Set.Version.Vorherig < 1.632 ) then begin
    FOR vERG # RecRead(922,1, _RecFirst)
    LOOP vERG # RecRead(922,1, _RecNext)
    WHILE (vERG = _rOk) do begin
      if (SFX.Hauptmenuname<>'') then begin
        RecRead(922,1, _RecLock);
        SFX.Hauptmenuname # '';
        RecReplace(922,0);
      end;
    END;
  end;


  // --- 20.05.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.633 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 450');
      UrgentMsg('Sql_SyncOne 451');
      UrgentMsg('Sql_SyncOne 404');
      UrgentMsg('Sql_SyncOne 200');
      UrgentMsg('Sql_SyncOne 899');
    end;
  end;

  // --- 23.08.2016 ------------------------------------------
  // neues Setting
  if ( Set.Version.Vorherig < 1.634 ) then begin
    v903 # RecBufCreate(903);
    RecRead(v903,1,_recFirst);
    RecRead(v903,1,_recLock);
    v903->Set.ERe.TestAbsch # true;
    vErg # RecReplace(v903,0);
    RecBufDestroy(v903);
  end;

  // --- 30.08.2016 ------------------------------------------
  // MatMix hat Mat.VK.REchdaten nicht gesetzt
  if ( Set.Version.Vorherig < 1.635 ) then begin
    vOK # false;
    RecBufClear(404);
    Auf.A.Rechnungsnr # 1;
    FOR vErg # RecRead(404,4,0)   // Auf-Aktionen loopen
    LOOP vErg # RecRead(404,4,_recNext)
    WHILE (vErg<_rNoRec) and (Auf.A.Rechnungsnr<>0) do begin
      if (Auf.A.Materialnr=0) then CYCLE;

      Erl.Rechnungsnr # Auf.A.Rechnungsnr;
      vErg # RecRead(450,1,0);                // Erlös holen
      if (vErg>_rLocked) then CYCLE;


      vErg # RecLink(200,404,6,_recFirst);    // Material suchen
      if (vErg<=_rLocked) then begin

        if (Mat.VK.Rechnr<>0) then CYCLE;

        vErg # RecLink(818,200,10,_recFirst); // Verwiegungsart holen
        if (vErg>_rLocked) then begin
          RecBufClear(818);
          VwA.NettoYN # y;
        end;
        RecRead(200,1,_recLock);
        Mat.VK.Kundennr   # Erl.Kundennummer;
        Mat.VK.Rechnr     # Erl.Rechnungsnr;
        Mat.VK.Rechdatum  # Erl.Rechnungsdatum;
        if (VwA.NettoYN) then
          Mat.VK.Gewicht  # Auf.A.Nettogewicht
        else
          Mat.VK.Gewicht  # Auf.A.Gewicht;
        Mat.VK.Preis      # Auf.A.RechPreisW1;
        if (Mat.Bestand.Gew<>0.0) then
          Mat.VK.Preis      # Rnd(Mat.VK.Preis / Mat.Bestand.Gew *1000.0,2);
        RecReplace(200,_recUnlock);
        vOK # y;
        CYCLE;
      end;  // Bestand

      vErg # RecLink(210,404,8,_recFirst);    // Materialablage suchen
      if (vErg<=_rLocked) then begin

        if ("Mat~VK.Rechnr"<>0) then CYCLE;

        vErg # RecLink(818,210,10,_recFirst); // Verwiegungsart holen
        if (vErg>_rLocked) then begin
          RecBufClear(818);
          VwA.NettoYN # y;
        end;
        RecRead(210,1,_recLock);
        "Mat~VK.Kundennr"   # Erl.Kundennummer;
        "Mat~VK.Rechnr"     # Erl.Rechnungsnr;
        "Mat~VK.Rechdatum"  # Erl.Rechnungsdatum;
        if (VwA.NettoYN) then
          "Mat~VK.Gewicht"  # Auf.A.Nettogewicht
        else
          "Mat~VK.Gewicht"  # Auf.A.Gewicht;
        "Mat~VK.Preis"      # Auf.A.RechPreisW1;
        if ("Mat~Bestand.Gew"<>0.0) then
          "Mat~VK.Preis"    # Rnd("Mat~VK.Preis" / "Mat~Bestand.Gew" *1000.0,2);
        RecReplace(210,_recUnlock);
        vOK # y;
      end;  // Ablage

    END;

    if (vOK) and (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 200');
    end;

  end;

  // --- 06.10.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.640 ) then begin
    RTy.Nummer      # 416;
    RTy.Bezeichnung # 'Bonusgutschrift'
    RecInsert(853,0);
    RTy.Nummer      # 417;
    RTy.Bezeichnung # 'Storno-Bonusgutschrift'
    RecInsert(853,0);
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 853');
    end;
  end;


  // --- 08.11.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.645 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 400');
    end;
  end;


  // --- 17.11.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.646 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 204');
    end;
  end;

  // --- 21.11.2016 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.647 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 107');
      UrgentMsg('Sql_AlterTable 130');
      UrgentMsg('Aufbau der Liefernatenerklärungs-FRX prüfen!');
    end;

    v903 # RecBufCreate(903);
    RecRead(v903,1,_recFirst);
    RecRead(v903,1,_recLock);
    if (v903->Set.Mat.Col.EKVSB=0) then begin
      v903->Set.Mat.Col.EKVSB     # v903->Set.Mat.Col.Bestellt;
    end;
    vErg # RecReplace(v903,0);
    RecBufDestroy(v903);

    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Adr_Ktd_Data:Rebuild" starten!');

    // 30.11.2016 - neue Datensätze...
    RecbufClear(820);
    Mat.Sta.Nummer        # 402;
    Mat.Sta.neueNummer    # 402;
    Mat.Sta.Bezeichnung   # 'VSB-Puffer';
    RecInsert(820,0);
  end;

  // --- 09.02.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.706 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 833');
    end;
  end;


  // --- 27.02.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.709 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 931');
    end;
  end;

  // --- 13.03.2017 ------------------------------------------
  if ( Set.Version.Vorherig < 1.710 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "Call Ost_Data:Repair892" starten!');
  end;

  // --- 23.03.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.712 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 560');
    end;
  end;


  // --- 12.06.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.724 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 1003');
    end;
  end;

  // --- 26.06.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.726 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 555');
    end;
  end;

  // --- 16.08.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.733 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 200');
      UrgentMsg('Sql_AlterTable 899');
    end;
  end;

  // --- 29.08.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.735 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 1000');
      UrgentMsg('Sql_AlterTable 250');
    end;
  end;

  // --- 20.09.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.738 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 200');
    end;
  end;

  // --- 09.10.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.740 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 259');
    end;
  end;

  // --- 17.10.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.742 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 200');
    end;
  end;

  // --- 23.10.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.743 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 105');
    end;
  end;

  // --- 23.10.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.748 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 200 (Holz:SYNC)');
    end;
  end;

  // --- 06.12.2017 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.749 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 800');
    end;
    UrgentMsg('call Usr_DatA:Fix06122017');
  end;

  // --- 02.01.2018 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.800 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_AlterTable 122');
      UrgentMsg('Sql_AlterTable 621');
    end;
  end;

  // --- 17.01.2018 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.802 ) then begin
    UrgentMsg('call _Utilities:ModSFX_1.802');
  end;

  // --- 22.01.2018 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.803 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('Sql_SyncOne 231');
      UrgentMsg('Sql_AlterTable 833');
      UrgentMsg('Sql_AlterTable 200');
      UrgentMsg('Sql_AlterTable 506');
      UrgentMsg('Sql_AlterTable 621');
    end;
  end;

  // --- 31.01.2018 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.805 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_AlterTable 230');
      UrgentMsg('SQL_SyncOne 231');
    end;
  end;


  // --- 13.02.2018 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.806 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_AlterTable 254');
    end;
  end;

  // --- 19.02.2018 ------------------------------------------
  // Dateien zum Syncen
  if ( Set.Version.Vorherig < 1.808 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_Syncone 191');
      UrgentMsg('SQL_Syncone 192');
      UrgentMsg('SQL_Syncone 710');
      UrgentMsg('SQL_AlterTable 9999 >>> KEINE anderen "ALTERTABLE" dieser Liste erforderlich!!!');
//      UrgentMsg('SQL_Syncone 931');
      UrgentMsg('SQL_Syncone 1000');
      UrgentMsg('SQL_Syncone 1001');
      UrgentMsg('SQL_Syncone 1002');
      UrgentMsg('SQL_Syncone 1003');
    end;
  end;

  // --- 21.02.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.809 ) then begin
    UrgentMsg('call Rso_rsv_data:init');
    UrgentMsg('FRX dürfen KEINE "static dictionary" in FUNC haben!');
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_AlterTable 832');
    end;
  end;

  // --- 27.03.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.815 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_Syncone 170');
      UrgentMsg('SQL_Syncone 171');
      UrgentMsg('SQL_AlterTable 250');
      UrgentMsg('SQL_AlterTable 703');
      UrgentMsg('SQL_AlterTable 840');
    end;
  end;

  // --- 24.04.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.816 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 100');
      UrgentMsg('SQL_SYNCONE 303');
    end;
  end;

  // --- 29.05.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.822 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 501');
    end;
  end;

  // --- 07.06.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.823 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 170');
      UrgentMsg('SQL_altertable 702');
      UrgentMsg('SQL_altertable 703');
    end;
  end;

  // --- 26.06.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.826 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 702');
    end;
  end;

  // --- 09.07.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.827 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_SYNCONE 231');
    end;
  end;

  // --- 09.07.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.830 ) then begin
    // neuer Status
    RecbufClear(820);
    Mat.Sta.Nummer        # 403;
    Mat.Sta.neueNummer    # 403;
    Mat.Sta.Bezeichnung   # 'VSB-Verkauf-Rahmen';
    Mat.Sta.Bemerkung     # 'gefertigt auf Rahmenauftrag';
    RecInsert(820,0);
  end;

  // --- 31.07.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.831 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 560');
    end;
  end;

  // --- 24.08.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.834 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 105');
    end;
  end;

  // --- 20.09.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.838 ) then begin
    // neuer Status
    RecbufClear(820);
    Mat.Sta.Nummer        # 404;
    Mat.Sta.neueNummer    # 404;
    Mat.Sta.Bezeichnung   # 'VSB-Verkauf-KonsRahm';
    Mat.Sta.Bemerkung     # 'fertigt für KonsiRahmenauftrag';
    RecInsert(820,0);
  end;

  // --- 27.09.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.838 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 701');
      UrgentMsg('SQL_altertable 702');
    end;
  end;

  // --- 12.10.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.841 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 707');
    end;
  end;

  // --- 15.10.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.842 ) then begin
    UrgentMsg('Bitte prüfen, ob der Kunde Paketetiketten druckt! Etikettendruck über Anker "Pak.Verbuchen.Post" lösen!');
    // --- 17.10.2018 ------------------------------------------
    // neuer Status
    RecbufClear(820);
    Mat.Sta.Nummer        # 758;
    Mat.Sta.neueNummer    # 758;
    Mat.Sta.Bezeichnung   # 'fertig, unklar';
    Mat.Sta.Bemerkung     # 'nach BA-FM, wenn weder gesperrt noch freigegeben';
    RecInsert(820,0);
  end;

  // --- 07.11.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.844 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 828');
      UrgentMsg('SQL_altertable 706');
    end;
  end;

  // --- 22.11.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.847 ) then begin
    if (Set.SQL.Instance<>'') then begin
    end;
  end;

  // --- 29.11.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.848 ) then begin
    UrgentMsg('Neues Recht "Lieferschein: Druck Lohnfahrauftrag" mit Kunden klären!');
  end;

  // --- 12.12.2018 ------------------------------------------
  if ( Set.Version.Vorherig < 1.849 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 280');
    end;
  end;

  // --- 14.02.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.906 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_Syncone 837');
    end;
  enD;
  
  // --- 18.03.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.911 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_Syncone 280');
    end;
  end;
  
  // --- 08.05.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.919 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 702');
    end;
  end;

  // --- 29.05.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.922 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 122');
      UrgentMsg('SQL_syncone 123');
    end;
  end;

  // --- 24.06.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.925 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 122');
    end;
  end;

  // --- 24.06.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.928 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 843');
    end;
  end;

  // --- 23.07.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.929 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 100');
      UrgentMsg('SQL_altertable 103');
      UrgentMsg('SQL_altertable 401');
    end;
  end;

  // --- 14.10.2019 ------------------------------------------
  if ( Set.Version.Vorherig < 1.941 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 501');
      UrgentMsg('SQL_altertable 701');
    end;
  end;
  if ( Set.Version.Vorherig < 1.942 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 501');
    end;
  end;

  if ( Set.Version.Vorherig < 1.944 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 301');
    end;
  end;

  if ( Set.Version.Vorherig < 2.001 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 1002');
    end;
  end;

  if ( Set.Version.Vorherig < 2.002 ) then begin
    FOR vErg # RecRead(843,1,_recFirst)
    LOOP vErg # RecRead(843,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (ApL.L.Adresse=0) then CYCLE;
      if (RecLink(100,843,2,_recFirst)<=_rLocked) then begin  // Adresse holen
        RecRead(843,1,_recLock);
        ApL.L.AdressSW # Adr.Stichwort;
        RecReplace(843,_recUnLock);
      end;
    END;

    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 843');
    end;
  end;

  if ( Set.Version.Vorherig < 2.003 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 403');
      UrgentMsg('SQL_syncone 503');
      UrgentMsg('SQL_syncone 451');
      UrgentMsg('SQL_syncone 551');
    end;
  end;

  if ( Set.Version.Vorherig < 2.005 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 252');
    end;
    UrgentMsg('Artikelrecalc');
  end;

  if ( Set.Version.Vorherig < 2.011 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Anh_Data:LaufSetID" starten!');
  end;

  if ( Set.Version.Vorherig < 2.015 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 816');
    end;
  end;

  if ( Set.Version.Vorherig < 2.020 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 700');
      UrgentMsg('SQL_altertable 707');
      UrgentMsg('SQL_altertable 202');
      UrgentMsg('SQL_altertable 204');
    end;
  end;

  if ( Set.Version.Vorherig < 2.022 ) or (RecInfo(857,_recCount)=0) then begin
    Insert857('WVL','Wiedervorlage');
    Insert857('TER','Termin');
    Insert857('AFG','Aufgabe');
    Insert857('TEL','Telefonat');
    Insert857('BRF','Brief');
    Insert857('FAX','Fax');
    Insert857('EMA','EMail');
    Insert857('SMS','SMS');
    Insert857('GSV','Geschenkversand');
    Insert857('BSP','Besprechung');
    Insert857('INF','Info');
    Insert857('WOF','Workflow');
    Insert857('DSK','Diskussion');
  end;

  
  if ( Set.Version.Vorherig < 2.023) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 100');
      UrgentMsg('SQL_altertable 837');
    end;
  end;

  if ( Set.Version.Vorherig < 2.025) then begin
    if (DbaLicense(_DbaSrvLicense)='CD152667MN/H') then begin
      UrgentMsg('Bitte in die Updatedefinition des Kunden die User "SOA_SYNC" und "SOA_JOB" aufnehmen!');
    end;
    if (Set.SQL.SoaYN) then begin
      UrgentMsg('Bitte als SQL-Sync-User "SOA_SYNC" benutzen!');
    end;
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 506');
    end;
  end;

  if ( Set.Version.Vorherig < 2.036) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 800');
    end;
  end;
  
  if ( Set.Version.Vorherig < 2.037) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 800');
    end;
  end;
  
  if ( Set.Version.Vorherig < 2.040) then begin
    FOR vErg # RecRead(450,1,_recFirst)
    LOOP vErg # RecRead(450,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      FOR vErg # RecLink(451,450,1,_recFirst)
      LOOP vErg # RecLink(451,450,1,_recNext)
      WHILE (vErg<=_rLocked) do begin
        if (Erl.K.Auftragsnr<>0) then begin
          RecRead(450,1,_RecLock);
          Erl.Auftragsnr # Erl.K.Auftragsnr;
          RecReplace(450,_recUnlock);
          BREAK;
        end;
      END;
    END;
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 450');
    end;
  end;

  if ( Set.Version.Vorherig < 2.041) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 838');
    end;
  end;


  if (DbaLicense(_DbaSrvLicense)='CD152667MN/H') then begin
    if ( Set.Version.Vorherig < 2.042) then begin
      if (Set.SQL.Instance<>'') then begin
        UrgentMsg('ALLE Services (PrintPDF, Desigern, XML-Liste, JIT/ASAP...) bitte testen, da neuer PS!!!');
      end;
    end;
  end;


  if ( Set.Version.Vorherig < 2.0421) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 450');
      UrgentMsg('SQL_altertable 460');
    end;
  end;

  if ( Set.Version.Vorherig < 2.049) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 700');
    end;
  end;

  if ( Set.Version.Vorherig < 2.050) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 700');
    end;
  end;

  if ( Set.Version.Vorherig < 2.051) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 1002');
    end;
  end;

  if ( Set.Version.Vorherig < 2.052) then begin
    if (Set.Auf.GutBelLFNull=false) and ("Set.Wie.GutBel#SepYN") then begin
      UrgentMsg('Bitte den Nummernkreis "Gutschrift/Belastung-LF" deaktivieren (Wert < 0) um weiterhin in den normalen Gs/Bel-Kreis zu buchen!');
    end;
  end;

  // 2021 --------------------------------------
  if ( Set.Version.Vorherig < 2.101) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 843');
      UrgentMsg('SQL_syncone 403');
      UrgentMsg('SQL_syncone 503');
    end;
  end;
  if ( Set.Version.Vorherig < 2.102) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_syncone 105');
      UrgentMsg('SQL_syncone 250');
      UrgentMsg('SQL_altertable 401');
      UrgentMsg('SQL_altertable 501');
    end;
  end;
  if ( Set.Version.Vorherig < 2.104) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 231');
    end;
  end;

// Artikelnr 40 Stellig::
// 105,121,123,168,180,181,182,191,192,200,220 x 2, 250,251 ,252 ,253 x 2, 254 , 255 , 256 x 2, 259 , 281 ,
// 301 ,303 ,401 x 2, 403 ,404 ,409 ,441 ,451 ,501 x 2,504 ,506 ,540 ,555 ,621 ,655 ,701 ,703 ,707 ,708 ,819 ,838 ,843 x 2,891 ,899 x 3,899 ,950 ,

// Gütenstufe 10 stellig:
// 105,200,210,220,401,411,501,506,511,600,621,701,703,834,998

  if ( Set.Version.Vorherig < 2.1052) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 130');
      UrgentMsg('SQL_altertable 160');
      UrgentMsg('SQL_altertable 200');
      UrgentMsg('SQL_altertable 204');
      UrgentMsg('SQL_altertable 401');
      UrgentMsg('SQL_altertable 450');
      UrgentMsg('SQL_altertable 451');
      UrgentMsg('SQL_altertable 501');
      UrgentMsg('SQL_altertable 506');
      UrgentMsg('SQL_altertable 621');
      UrgentMsg('SQL_altertable 702');
      UrgentMsg('SQL_altertable 826');
      UrgentMsg('SQL_altertable 832');
      UrgentMsg('SQL_altertable 833');
      UrgentMsg('SQL_altertable 834');
    end;
    UrgentMsg('Call LFE_Main:FillLieferantenSW');
  end;

  if ( Set.Version.Vorherig > 2.104) and ( Set.Version.Vorherig < 2.106) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_SYNCONE 702');
    end;
  end;

  if ( Set.Version.Vorherig < 2.108) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 200');
//      UrgentMsg('SQL_SYNCONE 231');
    end;
  end;
  
  if ( Set.Version.Vorherig < 2.109) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 833');
      UrgentMsg('SQL_ALTERTABLE 834');
    end;
  end;

  if ( Set.Version.Vorherig < 2.113) then begin
    v903 # RecBufCreate(903);
    RecRead(v903,1,_recFirst);
    RecRead(v903,1,_recLock);
    v903->Set.Auf.AutoDelRahme # 1;
    vErg # RecReplace(v903,0);
    RecBufDestroy(v903);
  end;

  if ( Set.Version.Vorherig < 2.114) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 501');
      UrgentMsg('SQL_ALTERTABLE 843');
    end;
  end;

  if ( Set.Version.Vorherig < 2.117 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 832');
    end;
  end;

  if ( Set.Version.Vorherig < 2.118 ) then begin
    UrgentMsg('Bitte UNBEDINGT Kommando "CALL Lys_Data:Lauf_V2118" starten!');
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 230');
    end;
  end;

  if ( Set.Version.Vorherig < 2.127 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 832');
    end;
  end;

  if ( Set.Version.Vorherig < 2.129 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 200');
      UrgentMsg('SQL_altertable 702');
    end;
  end;

  if ( Set.Version.Vorherig < 2.130 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 191');
    end;
  end;
  
  if ( Set.Version.Vorherig < 2.140 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 820');
      UrgentMsg('SQL_altertable 252');
    end;
    UrgentMsg('call Mst_Main:Fix04102021');
  end;

  if ( Set.Version.Vorherig < 2.141 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 843');
    end;
  end;

  if ( Set.Version.Vorherig < 2.202 ) then begin
    UrgentMsg('Call Lfs_Data:SumAlleLFS');
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 231');
      UrgentMsg('SQL_altertable 440');
    end;
  end;


  if ( Set.Version.Vorherig < 2.204 ) then begin
    FOR vErg # RecRead(655,1,_recFirst)
    LOOP vErg # RecRead(655,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (VsP.Auftragsnr=0) then CYCLE;
      Auf.Nummer # VsP.Auftragsnr;
      vErg # RecRead(400,1,0);
      if (vErg>_rLocked) then begin
        "Auf~Nummer" # VsP.Auftragsnr;
        vErg # RecRead(410,1,0);
        if (vErg>_rLocked) then RecBufClear(410);
        RecBufCopy(410,400);
      end;
      RecRead(655,1,_recLock);
      VsP.AuftragsKundennr  # Auf.Kundennr;
      VsP.AuftragsKdSW      # Auf.KundenStichwort;
      RecReplace(655,_recUnLock);
    END;
    
    FOR vErg # RecRead(656,1,_recFirst)
    LOOP vErg # RecRead(656,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if ("VsP~Auftragsnr"=0) then CYCLE;
      Auf.Nummer # "VsP~Auftragsnr";
      vErg # RecRead(400,1,0);
      if (vErg>_rLocked) then begin
        "Auf~Nummer" # "VsP~Auftragsnr";
        vErg # RecRead(410,1,0);
        if (vErg>_rLocked) then RecBufClear(410);
        RecBufCopy(410,400);
      end;
      
      RecRead(656,1,_recLock);
      "VsP~AuftragsKundennr"  # Auf.Kundennr;
      "VsP~AuftragsKdSW"      # Auf.KundenStichwort;
      RecReplace(656,_recUnLock);
    END;
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_altertable 655');
    end;
  end;


  if ( Set.Version.Vorherig < 2.207 ) then begin
    if (DbaLicense(_DbaSrvLicense)='CD152667MN/H') then begin
      UrgentMsg('Bitte UNBEDINGT das DEV-Update "Vollupdate" um den Text "!Datenstruktur.DEV" erweitern!');
    end;
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 700');
      UrgentMsg('SQL_SYNCONE 257');
      UrgentMsg('SQL_ALTERTABLE 250');
    end;
  end;

  if ( Set.Version.Vorherig < 2.212 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 200');
    end;
  end;

  if ( Set.Version.Vorherig < 2.213 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 838');
      UrgentMsg('SQL_ALTERTABLE 839');
      UrgentMsg('SQL_ALTERTABLE 840');
      UrgentMsg('SQL_ALTERTABLE 848');
    end;
  end;

  if ( Set.Version.Vorherig < 2.214 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 409');
      UrgentMsg('Bitte optimalerweise das neue Setting "LFS->Mat.Res. bei FM" setzen!');
    end;
  end;


  if ( Set.Version.Vorherig < 2.217 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 280');
      UrgentMsg('SQL_ALTERTABLE 655');
    end;
  end;


  if ( Set.Version.Vorherig < 2.228 ) then begin
    if (Set.SQL.Instance<>'') then begin
      UrgentMsg('SQL_ALTERTABLE 9999');
    end;
  end;

  if ( Set.Version.Vorherig < 2.324 ) then
  begin
    UrgentMsg('Bitte UNBEDINGT "call Rek_data:FixKdLfNr" ausführen (das ist ein Lauf der Altdaten in Reklamationen fixt)');
  end;


   //2023-07-28 MR Versionsverwaltung für MDE zum abgreifen von Breaking Changes
  if ( Set.Version.Vorherig < 2.325 ) then begin
    UrgentMsg(cMsgMdeVersioning + cMsgMdeVersioningAnleitung);
  end

  // ---------------------------------------------------------
  // ---------------------------------------------------------
  // ---------------------------------------------------------
  
  // Automatische Meldungen zu SQL_ALTERTABLE und SQL_SYNCONE
  
  UrgentMsg(
    StrChar(13) + StrChar(10) +
    StrChar(13) + StrChar(10) +
    'Bitte die folgenden Ergebnisse des automatischen Datenstruktur-Vergleichs im Clipboard abgleichen mit den vorherigen und DS bescheidgeben oder Inhalt an DS schicken:' +
    StrChar(13) + StrChar(10) +
    StrChar(13) + StrChar(10)
  )

  // 28.02.2022 DS
  // Innerhalb dieses POST-Update Schrittes wird die Datenstruktur des Quell-Datenraums
  // (damit ist die Quelle des Updates gemeint) mit der des Ziel-Datenraums (in dem das
  // Update installiert wurde, dessen Original-Datenstruktur wurde im PRE-Update Schritt
  // in den Datenraum geschrieben) verglichen, und auf Grundlage dieses Vergleichs werden
  // ALTER TABLE Hinweise gegeben, wo erforderlich.
  //
  // Dieser Vergleich findet hier statt, wobei unterschieden wird, ob ein Update in den
  // DEV oder LIVE Datenraum des Kunden eingespielt wird:
  if (App_Main:Entwicklerversion()) then begin
    // Wenn die Lizenz-Nummer der aktiven C16 Installation die von BCS ist, muss der
    // Ziel-Datenraum in dem installiert wird die BCS-interne, kundenspezifische DEV Umgebung sein.
    // Wir befinden uns also im Szenario des Updates von STD nach DEV.
    
    C16_DatenstrukturDif:ComparisonDuringUpdate('STD->DEV');
    
  end
  else
  begin
    // Wenn die Lizenz-Nummer der aktiven C16 Installation NICHT die von BCS ist, muss der
    // Ziel-Datenraum in dem installiert wird beim Kunden liegen und daher eine seiner LIVE Umgebungen sein.
    // Wir befinden uns also im Szenario des Updates von DEV nach LIVE.
    
    C16_DatenstrukturDif:ComparisonDuringUpdate('DEV->LIVE');
    
  end
  
  Todo(StrChar(13) + StrChar(10) + StrChar(13) + StrChar(10) +'Ende der Ergebnisse des automatischen Datenstruktur-Vergleichs.' + StrChar(13) + StrChar(10) + StrChar(13) + StrChar(10));
  
  
  // ---------------------------------------------------------
  // ---------------------------------------------------------
  // ---------------------------------------------------------

  RecRead(903,1,_recLock);
  Set.Version.Vorherig  # Set.Version.Aktuell;
  Set.Version.Aktuell   # vVersionNeu;
  RecReplace(903,0);

  if (ClipBoardRead()<>'') then begin
    WinDialogBox( 0, 'ACHTUNG', 'Die Zwischenablage ist mit allen manuell durchzuführenden Schritten gefüllt! Bitte abarbeiten!', _winIcoWarning, _WinDialogok,1);
  end;


  if (vRelNeu<>'') then begin
    vA # cnvai(DbaInfo(_DbaClnRelMaj))+'.'+cnvai(DbaInfo(_DbaClnRelMin))+'.'+cnvai(DbaInfo(_DbaClnRelrev),_FmtNumLeadZero,0,2);
    vI # DbaInfo(_DbaClnRelSub);
    if (vI<>0) then vA # vA + StrChar(vI);
    if (vRelNeu<>vA) then begin
      if (vProt<>0) then
        TextAddLine(vProt, 'falscher Client! Aktuell '+vA+'   Ziel:'+vRelNeu);
      UrgentMsg('Das Update ist für den C16-Client '+vRelNeu+StrChar(13)+'BITTE UPDATEN!!!');
    end;
  end;


  // 13.03.2015 Listen prüfen
  vTxt # TextOpen(20);
  vErg # TextRead(vTxt, '!UPDATE_RECS',0);
//TextAddLine(vProt, 'Lese Text: '+cnvai(vErg));
  
  if (vErg<=_rLocked) then begin
    // ALT oder NEU?
    vA # TextLineRead(vTxt, 1, 0);
    vOK # Lib_Strings:Strings_Count(vA,'|')>2;

    FOR vErg # RecRead(910,1,_recFirst)
    LOOP vErg # RecRead(910,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (vOK) then     // NEU
        vA # '910|'+"Lfm.Kuerzel"+'|'+cnvai(Lfm.Nummer,_FmtNumNoGroup,0,8)+'|'
      else              // ALT
        vA # '910|'+cnvai(Recinfo(910,_recID),_FmtNumNoGroup);
        
//TextAddLine(vProt, 'suche '+vA);
      if (TextSearch(vTxt, 1, 1, _TextSearchCI, vA)=0) then begin // NEUE LISTE???
//TextAddLine(vProt, 'NEU!!!');
        RecRead(910,1,_recLock);
        Lfm.InaktivYN # y;
        Lfm.NeuYN     # Y;
        RecReplace(910,_recUnlock);
      end
      else if (LFm.NeuYN) then begin
//TextAddLine(vProt, 'MOD!!!');
        RecRead(910,1,_recLock);
        Lfm.NeuYN     # n;
        RecReplace(910,_recUnlock);
      end
      else begin
//TextAddLine(vProt, 'ALT!!!');
      end;
    END;
    TextDelete('!UPDATE_RECS', 0);
  end;
  TextClose(vTxt);


  // ALLE Prozeduren compilieren
/*** 19.02.2014 AH raus, weil manchmal zu langsam oder ohne Erfolg
  vTxt  # TextOpen(10);
  FOR vErg # Textread(vTxt,'', _TextFirst|_TextNoContents|_TextProc)
  LOOP vErg # Textread(vTxt,vA, _TextNext|_TextNoContents|_TextProc)
  WHILE (vErg<>_rNoRec) do begin
    vA # TextInfoalpha(vTxt, _textName);
    if (StrCut(vA,1,1)='!') then CYCLE;
    if (StrCut(vA,1,1)='_') then CYCLE;
    if (StrCut(vA,1,4)='old_') then CYCLE;
    if (StrCut(vA,1,4)='Liz_') then CYCLE;
    ProcCompile(vA);
  END;
  TextClose(vTxt);
***/


  // Ankerfunktion?
  AFX.Name # 'Update.Post';
  vErg # RecRead(923,1,0);    // AFX holen
  if (vErg<=_rLocked) and (AFX.Prozedur<>'') then begin
    Call(AFX.Prozedur, vVonNach);
  end;


  if (vProt<>0) then begin
    TextWrite(vProt,'!Updateprotokoll',0);
    TextClose(vProt);
  end;

  // Herstellerlizenz?
  if (DbaLicense(_DbaSrvLicense)='CD152667MN/H') then
//    WinDialogBox( gFrmMain, 'ACHTUNG', 'Im Kundendatenraum müssen nun ALLE Prozeduren manuell kompiliert werden!!!', _winIcoWarning, _WinDialogOk, 1 );
    WinDialogBox( 0, 'ACHTUNG', 'Im Kundendatenraum (' + DbaName(_dbaAreaAlias ) + ') müssen nun ALLE Prozeduren manuell kompiliert werden!!!', _winIcoWarning, _WinDialogOk, 1 );

end;


//========================================================================