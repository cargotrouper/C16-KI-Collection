@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_PasswordMgr
//                      OHNE E_R_G
//  Info        Enthät Funktionen zur Anbindung eines Passwortmanagers
//
//      todo:
//  - Textformatierung auf
//       <fett>TYP</fett>
//            Strich
//         Key  : Value
//         Key  : Value
//            Leerzeile
//
//  - ArcFlowZugangsdaten
//  - Eintragen/Ändern der Werte aus Adressverwaltung
//
//  - 2. Datenbank für Admins integrieren
//  - Passworteingabe
//  - Kommentierung und Doku
//
//  01.03.2022  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    todo
//
//========================================================================
@I:Def_global


define begin
  cTitleType_C16Serv_Win      : 'C16Server_Windows'
  cTitleType_C16Serv_Remote   : 'C16Server_Remote_AnyDesk'
  cTitleType_SQLServ_Win      : 'SQLServer_Windows'
  cTitleType_SQLServ_Remote   : 'SQLServer_Remote_AnyDesk'
  cTitleType_SQLDatabase      : 'SQLDatabase'
  cTitleType_DmsServ_Win      : 'DmsServer_Windows'
  cTitleType_DmsServ_Remote   : 'DmsServer_Remote_AnyDesk'
  cTitleType_DmsServ_Admin    : 'DmsServer_Admin'
  cTitleType_FullyKiosk       : 'FullyKioskPin'
    
  cField_Title  : '-Field:Title'
  cField_User   : '-Field:UserName'
  cField_Pw     : '-Field:Password'
  cField_Notes  : '-Field:Notes'
  
  cCommand_GetEntryString : '-c:GetEntryString'
  cCommand_AddEntryString : '-c:AddEntry'
  
  cKdbxDataBaseName : 'bcs_db_clientdata'
end;

local begin
  gPassword   : alpha;
end;



//========================================================================
//
//
//========================================================================
sub PathKeePass() : alpha
begin
  RETURN Set.Client.Pfad + '\dlls\KeePass-2.5\';
end;

//========================================================================
//
//
//========================================================================
sub PathToScriptExe() : alpha
begin
  RETURN PathKeePass() + 'KPScript';
end;

//========================================================================
//
//
//========================================================================
sub PathToPassDB(aDatabasename : alpha) : alpha
begin
  RETURN PathKeePass() + aDatabasename+ '.kdbx';
end;


//========================================================================
//
//
//========================================================================
sub Password() : alpha
local begin
  vPassword   : alpha;
end
begin
  if (gUsername = 'S T') then begin
    if (gPAssword = '') then begin
      if (Dlg_Standard:Standard('Passwort', var vPassword, true) = false) then
        RETURN '';
      else
        gPAssword # vPassword;
    end;
    RETURN gPAssword;
  end;
  
  RETURN 'IWasMade4LovingYouBäbä';
end;


//========================================================================
//
//
//========================================================================
sub FileAppend(aFilepath : alpha(1000); aText : alpha)
local begin
  vHdl : int;
end
begin
  vHdl  # FsiOpen(aFilePath, _FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
  if (vHdl > 0) then begin
    aText # aText+StrChar(13)+Strchar(10);
    FsiWrite(vHdl,aText);
  end;
  vHdl->FsiClose();
end;

//========================================================================
//
//
//========================================================================
sub BuildRunCommandGet(
  aDbName     : alpha;
  aPw         : alpha;
  aTitleType  : alpha;
  aDest       : alpha;
  aField      : alpha;
  ) : logic
local begin
  Erx       : int;
  vCommand  : alpha(1000);
  v2Exec    : alpha(2000);
end
begin
  FileAppend(aDest,aField+':');

  vCommand  # cCommand_GetEntryString + ' "'+PathToPassDB(aDbName)+'"' +
              ' -pw:' + aPw + ' ' +
              aField +
              ' -ref-Title:"'+aTitleType+'"'+
              ' >> ' + aDest;
              
  // C16 benötigt "/c" ist für die Ausführung des Commands
  v2Exec    #  '/c' + PathToScriptExe() + ' ' + vCommand;
debug(vCommand);

  Erx # SysExecute('cmd',v2Exec, _ExecWait  | _ExecHidden);
  if (Erx <> 0) then begin
    ERROR(99,'Fehler bei Befehlsausgabe "'+cCommand_GetEntryString+'"');
    RETURN false;
  end;
  
  RETURN true;
end;


//========================================================================
//
//
//========================================================================
sub BuildRunCommandAdd(
  aDbName     : alpha;
  aPw         : alpha;
  aAdrNr      : int;
  aGruppe     : alpha;
  aTitle      : alpha;
  aUser       : alpha;
  aPass       : alpha;
  aNote       : alpha;

  ) : logic
local begin
  Erx       : int;
  vCommand  : alpha(1000);
  v2Exec    : alpha(2000);
end
begin
  //FileAppend(aDest,aField+':');

  vCommand  # cCommand_AddEntryString + ' "'+PathToPassDB(aDbName)+'"' +
              ' -pw:' + aPw + ' ' +
//              aField +
              ' -Title:"'+Aint(aAdrNr)+'-'+aTitle+'" '+
              ' -GroupName:"'+aGruppe+'" ' +
              ' -Notes:"'  + aNote + '"' +
              ' -UserName:'+aUser+ '  ' +
              ' -Password:'+aPAss;
              
  // C16 benötigt "/c" ist für die Ausführung des Commands
  v2Exec    #  '/c' + PathToScriptExe() + ' ' + vCommand;
  
  Erx # SysExecute('cmd',v2Exec, _ExecWait  | _ExecHidden);
  if (Erx <> 0) then begin
    ERROR(99,'Fehler bei Befehlsausgabe "'+cCommand_AddEntryString+'"');
    RETURN false;
  end;
  
  RETURN true;
end;



//========================================================================
//
//
//========================================================================
sub GetInfoUserPwNotes(
  aPathToTempText : alpha(1000);
  aDatabasename   : alpha;
  aPassword       : alpha;
  aProgress       : int;
  aTitleType      : alpha;
) : logic
local begin
end
begin
  FileAppend(aPathToTempText,'<' + aTitleType+'>');
    
  // KeyPass Abfragen
  if (BuildRunCommandGet(aDatabasename, aPassword, aTitleType, aPathToTempText, cField_User) = false) then RETURN false;
  if (BuildRunCommandGet(aDatabasename, aPassword, aTitleType, aPathToTempText, cField_Pw)= false) then RETURN false;
  if (BuildRunCommandGet(aDatabasename, aPassword, aTitleType, aPathToTempText, cField_Notes)= false) then RETURN false;
  FileAppend(aPathToTempText,'</' + aTitleType + '>\n');
  
  if (aProgress > 0) then
    aProgress->Lib_Progress:Step();
    
  RETURN true;
end;




//========================================================================
//
//
//========================================================================
sub TidyText(aText : int; aAdressnr : int)
local begin
  vLines : int;
  vLine  : int;
  vData : alpha;
  
  vResultText   : int;
  vResLines     : int;
  vTmp          : alpha;
  vRtfFormat    : alpha;
  
  vIsNoticeBlock  : logic;
  vKey            : alpha;
end
begin
  if (aText <= 0) then
    RETURN;
  
  // Erfolgsmeldungen raus
  TextSearch(aText,1,1,_TextSearchToken,'-'+Aint(aAdressnr),'');
  TextSearch(aText,1,1,_TextSearchToken,'OK: Operation completed successfully.','');
  TextSearch(aText,1,1,_TextSearchToken,'.'+StrChar(13)+StrChar(10),'');
  
  TextSearch(aText,1,1,_TextSearchToken,cField_User , 'Benutzer');
  TextSearch(aText,1,1,_TextSearchToken,cField_Pw   , 'Passwort');
  TextSearch(aText,1,1,_TextSearchToken,cField_Notes, 'Notizen');

  vResultText # TextOpen(10);
  
  // Titel Fett machen
  vLines # TextInfo(aText,_TextLines);
  FOR  vLine # 1
  LOOP inc(vLine)
  WHILE vLine <= vLines DO BEGIN
    vData # TextLineRead(aText,vLine,0);
    vData # Str_ReplaceAll(vData,StrChar(13),'#13#');
    vData # Str_ReplaceAll(vData,StrChar(10),'#10#');
    vData # StrAdj(vData,_StrBegin | _StrEnd);
    if (vData =  '') then
      CYCLE;

    // Ende eines Blockes
    if (Str_StartsWith(vData,'</') AND (Str_EndsWith(vData,'>\n'))) then begin
      
      vRtfFormat # '\f0\fs16 ';
      inc(vResLines);
      TextLineWrite(vResultText,vResLines, vRtfFormat + '------------------------------------------------------------------', _TextLineInsert);
  
      // Status Reset
      vIsNoticeBlock # false;
      CYCLE;
    end;
    
    // Anfang eines Blockes
    if (Str_StartsWith(vData,'<') AND (Str_EndsWith(vData,'>'))) then begin
      vTmp # Str_Token(vData,'-',2);
      vTmp # StrCut(vTmp,1,StrLEn(vTmp)-1);   // > abschneiden
      vRtfFormat # '\b\f0\fs24 ';
      
      inc(vResLines);
      TextLineWrite(vResultText,vResLines, vRtfFormat +  vTmp   ,_TextLineInsert);
      CYCLE;
    end;

    // Wert vcm "Key Blöck" Puffern und mit Value als Zeile übernehmen
    if (Str_EndsWith(vData,':')) then begin
      vKey # vData;
            
      if (Str_Contains(vData,'Notizen')) then
        vIsNoticeBlock # true;
      CYCLE;
    end;

    // "Normaler" KEy Value Block
    if (vKey <> '') OR (vIsNoticeBlock) then begin
      if (vIsNoticeBlock) then
        vKey # '\tab';
      vTmp  # vKey + '\tab ' + vData;
      vData # vTmp;
      vKey  # '';
    end;
    vRtfFormat # '\f0\fs16 ';
    inc(vResLines);
    TextLineWrite(vResultText,vResLines, vRtfFormat +  vData  ,_TextLineInsert);
  END;
 
 
  // Resultattext zurückschreiben
  TextClear(aText);

  vLines # TextInfo(vResultText,_TextLines);
  FOR  vLine # 1
  LOOP inc(vLine)
  WHILE vLine <= vLines DO BEGIN
    vData # TextLineRead(vResultText,vLine,0);
    vTmp  # TextLineRead(vResultText,vLine+1,0);

    // Header ohne Nutzinhalte ignorieren
    //if !(Str_Contains(vData,'fs24') AND Str_Contains(vTmp,'--------------')) then
      TextLineWrite(aText,vLine,vData,_TextLineInsert);
  END

  vResultText->TextClose();

end;




//========================================================================
//
//
//========================================================================
sub ProcessList(
  aList         : int;
  aPathToTemp   : alpha;
  aPass         : alpha;
  aProgress     : int)
local begin
  vItem : int;
end
begin
  FOR   vItem # CteRead(aList,_CteFirst)
  LOOP  vItem # CteRead(aList,_CteNExt, vItem)
  WHILE vItem <> 0 DO BEGIN
    if (GetInfoUserPwNotes(aPathToTemp, vItem->spCustom, aPass,aProgress, vItem->spName) = false) then
      RETURN;
  END;
end;
  


//========================================================================
//
//
//========================================================================
sub GetKundeninfo(aAdressnr : int) : alpha
local begin
  Erx             : int;
  vText           : int;
  vTextRtf        : int;
  vPathToTempText : alpha(1000);
  vErr            : alpha(4000);
  vProgress       : int;
  
  vDB             : alpha;
  vPass               : alpha;
  
  vTypeList           : int;
  vPwdTypeToCheckText : alpha;
  vTxtHdlRtf          : int;
  vTxtHdl             : int;
  
  vTxtLineCNt         : int;
  vLine               : int;
  vLineData           : alpha(250);

  vDict             : int;
  vVal              : alpha;

end;
begin
  
  // Init
  Lib_Dict:Add(var vDict, cTitleType_C16Serv_Win   );
  Lib_Dict:Add(var vDict, cTitleType_C16Serv_Remote);
  Lib_Dict:Add(var vDict, cTitleType_SQLServ_Win   );
  Lib_Dict:Add(var vDict, cTitleType_SQLServ_Remote);
  Lib_Dict:Add(var vDict, cTitleType_SQLDatabase   );
  Lib_Dict:Add(var vDict, cTitleType_DmsServ_Win   );
  Lib_Dict:Add(var vDict, cTitleType_DmsServ_Remote);
  Lib_Dict:Add(var vDict, cTitleType_DmsServ_Admin );
  Lib_Dict:Add(var vDict, cTitleType_FullyKiosk    );


  // Ausgabeziel für Antwort von KeyPath Skript Plugin
  vPathToTempText # Lib_FileIO:GetTempPath() + Aint(gUserId) + '.txt';
  FsiDelete(vPathToTempText);
  
  vPass # Password();
  if (vPass = '') then
    RETURN '';
    
  vDB  #  cKdbxDataBaseName;
      
  Adr.Nummer # aAdressnr;
  Erx # RecRead(100,1,0);
  if  (Erx > _rLocked) then
    RETURN '';
  
  vTypeList # CteOpen(_CteList);

  
  // ggf. Festgelegte Kundenpassworttypen aus Tet 5 extrahieren
  vTxtHdlRtf  # TextOpen(5);
  vTxtHdl     # TextOpen(5);
  vPwdTypeToCheckText # '~100.' + CnvAI( Adr.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8)+ '.004';
  if (vTxtHdlRtf->TextRead(vPwdTypeToCheckText, _textNoContents ) <= _rLocked ) then begin
                 
    TextRead(vTxtHdlRtf, vPwdTypeToCheckText,0);
    Lib_Texte:Rtf2Txt(vTxtHdlRtf,vTxtHdl);

    vTxtLineCNt # TextInfo(vTxtHdl, _TextLines);
    FOR   vLine # 1;
    LOOP  inc(vLine)
    WHILE vLine <= vTxtLineCNt DO BEGIN
      vLineData # StrAdj(TextLineRead(vTxtHdl,vLine,0),_StrAll);
      if (vLineData = '') then
        CYCLE;
      
      if (Lib_Dict:Read(var vDict,vLineData, var vVal)) then
        vTypeList->CteInsertItem( Aint(aAdressnr) +'-'+ vLineData, 1, vDB  );
    END;
           
  end else begin
    
    // Alle möglichen Daten abfragen
    FOR   vLine # CteRead(vDict, _CteFirst)
    LOOP  vLine # CteRead(vDict, _CteNext, vLine)
    WHILE vLine <> 0 DO
      vTypeList->CteInsertItem( Aint(aAdressnr) +'-'+ vLine->spName     , 1, vDB);
      
  end;
      
  vTxtHdlRtf->TextClose();
  vTxtHdl->TextClose();

  vProgress # Lib_Progress:Init('Lese Daten aus Passwortspeicher für ' + Adr.Stichwort,CteInfo(vTypeList,_CteCount));

  ProcessList(vTypeList,vPathToTempText,vPass,vProgress);
  
  vProgress->Lib_Progress:Term();
  vTypeList->CteCLose();
  
  if (Errlist <> 0) then begin
    Lib_Error:OutputToText(var vErr);
    MsgErr(99,'Fehler bei Entschlüsselung');
    RETURN '';
  end;
      
  // Antworttext Formatieren und Anzeigen
  vText    # TextOpen(10);
  vTextRtf # TextOpen(10);
  Erx # vText->TextRead(vPathToTempText,_TextExtern);
  
  TidyText(vText, aAdressNr);
  Lib_Texte:Txt2Rtf(vText,vTextRtf);
  Dlg_Standard:TooltipRTF(vTextRtf,'Zugangsdaten');
  
  // Aufräumen
  vText->TextClose();
  vTextRtf->TextClose();
  FsiDelete(vPathToTempText);
  
  
end;


//========================================================================
//
//
//========================================================================
sub AddKundeninfo(aAdressnr : int; opt aType : alpha) : alpha
local begin
  Erx             : int;
  vText           : int;
  vTextRtf        : int;
  vPathToTempText : alpha(1000);
  vErr            : alpha(4000);
  vProgress       : int;
  
  vDB             : alpha;
  vPass           : alpha;
/*
  vTypeList           : int;
  vPwdTypeToCheckText : alpha;
  vTxtHdlRtf          : int;
  vTxtHdl             : int;
  
  vTxtLineCNt         : int;
  vLine               : int;
  vLineData           : alpha(250);

  vDict             : int;
*/
  vVal1              : alpha;
  vVal2              : alpha;
  vVal3              : alpha;
end;
begin
  
  // Init
  /*
  Lib_Dict:Add(var vDict, cTitleType_C16Serv_Win   );
  Lib_Dict:Add(var vDict, cTitleType_C16Serv_Remote);
  Lib_Dict:Add(var vDict, cTitleType_SQLServ_Win   );
  Lib_Dict:Add(var vDict, cTitleType_SQLServ_Remote);
  Lib_Dict:Add(var vDict, cTitleType_SQLDatabase   );
  Lib_Dict:Add(var vDict, cTitleType_DmsServ_Win   );
  Lib_Dict:Add(var vDict, cTitleType_DmsServ_Remote);
  Lib_Dict:Add(var vDict, cTitleType_DmsServ_Admin );
  Lib_Dict:Add(var vDict, cTitleType_FullyKiosk    );
*/
  // Ausgabeziel für Antwort von KeyPath Skript Plugin
  vPathToTempText # Lib_FileIO:GetTempPath() + Aint(gUserId) + '.txt';
  FsiDelete(vPathToTempText);
  
  vPass # Password();
  if (vPass = '') then
    RETURN '';
    
  vDB  #  cKdbxDataBaseName;
      
  Adr.Nummer # aAdressnr;
  Erx # RecRead(100,1,0);
  if  (Erx > _rLocked) then
    RETURN '';
  
/*
  vTypeList # CteOpen(_CteList);
  
  // ggf. Festgelegte Kundenpassworttypen aus Tet 5 extrahieren
  vTxtHdlRtf  # TextOpen(5);
  vTxtHdl     # TextOpen(5);
  vPwdTypeToCheckText # '~100.' + CnvAI( Adr.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8)+ '.005';
  if (vTxtHdlRtf->TextRead(vPwdTypeToCheckText, _textNoContents ) <= _rLocked ) then begin
                 
    TextRead(vTxtHdlRtf, vPwdTypeToCheckText,0);
    Lib_Texte:Rtf2Txt(vTxtHdlRtf,vTxtHdl);

    vTxtLineCNt # TextInfo(vTxtHdl, _TextLines);
    FOR   vLine # 1;
    LOOP  inc(vLine)
    WHILE vLine <= vTxtLineCNt DO BEGIN
      vLineData # StrAdj(TextLineRead(vTxtHdl,vLine,0),_StrAll);
      if (vLineData = '') then
        CYCLE;
      
      if (Lib_Dict:Read(var vDict,vLineData, var vVal)) then
        vTypeList->CteInsertItem( Aint(aAdressnr) +'-'+ vLineData, 1, vDB  );
    END;
           
  end else begin
    
    // Alle möglichen Daten abfragen
    FOR   vLine # CteRead(vDict, _CteFirst)
    LOOP  vLine # CteRead(vDict, _CteNext, vLine)
    WHILE vLine <> 0 DO
      vTypeList->CteInsertItem( Aint(aAdressnr) +'-'+ vLine->spName     , 1, vDB);
      
  end;
      
  vTxtHdlRtf->TextClose();
  vTxtHdl->TextClose();

  vProgress # Lib_Progress:Init('Lese Daten aus Passwortspeicher für ' + Adr.Stichwort,CteInfo(vTypeList,_CteCount));
*/
  
  
  Dlg_Standard:Standard(aType + ' Benutzername', var vVal1);
  Dlg_Standard:Standard(aType + ' Passwort', var vVal2);
  Dlg_Standard:Standard(aType + ' Notizen', var vVal3);
    
                
  BuildRunCommandAdd(vDB, vPass, Adr.Nummer, Adr.Stichwort, aType, vVal1,vVal2,vVal3 );

  
  //ProcessList(vTypeList,vPathToTempText,vPass,vProgress);
  
/*
  vProgress->Lib_Progress:Term();
  vTypeList->CteCLose();
  
  if (Errlist <> 0) then begin
    Lib_Error:OutputToText(var vErr);
    MsgErr(99,'Fehler bei Entschlüsselung');
    RETURN '';
  end;
    
  // Antworttext Formatieren und Anzeigen
  vText    # TextOpen(10);
  vTextRtf # TextOpen(10);
  Erx # vText->TextRead(vPathToTempText,_TextExtern);
  
  TidyText(vText, aAdressNr);
  Lib_Texte:Txt2Rtf(vText,vTextRtf);
  Dlg_Standard:TooltipRTF(vTextRtf,'Zugangsdaten');
  
  // Aufräumen
  vText->TextClose();
  vTextRtf->TextClose();
*/
  FsiDelete(vPathToTempText);
end;


//========================================================================
//
//
//========================================================================
sub Test()
begin
  GetKundeninfo(1397);
end;


//========================================================================
//
//
//========================================================================
sub TestInsert()
begin
  AddKundeninfo(1397,cTitleType_DmsServ_Win);
end;



 
//=======================================================================