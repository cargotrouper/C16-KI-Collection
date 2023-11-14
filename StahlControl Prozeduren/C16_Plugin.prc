//---------------------------------------------------------------------------------------
//
//  Prozedur    C16_Plugin
//                    OHNE E_R_G
//
//---------------------------------------------------------------------------------------
@A+
@I:Def_Global
@I:C16_Plugin_Core_Inc
@I:C16_Plugin_Cnv_Inc
//@I:Plugin.Win.Cxs.Inc

//---------------------------------------------------------------------------------------
// Defines
//---------------------------------------------------------------------------------------
define begin
  _FileName         : -1
  _FldName          : -1
  _KeyName          : -1
  _KeySbrName       : -2
  _KeySbrNumber     : -3

  sPluginPort     : 1337 // STD4717    // Port to connect to designer. (port can be set as command line parameter)
  sPluginTimeout  : 10000    // Timeout to wait for connection.
  sPluginPassword : 'plugin'  // Plugin password / defined with user 'SU'.
  
  _s.Exists       : 1       // FileInfo() = FileExists

  mIntToString(a)      : CnvAI(a, _FmtInternal)

  sDirPathCaption         : 'Verzeichnis auswählen'
  sDirPathImpExpText      : 'Wählen Sie den Pfad des Git-Workspace aus.'
  
  sFrameSelectBranchText  : 'Auswählen'
  sFrameSelectBranchLabel : 'Branch: '
  
  sTmpDir                 : _Sys->spPathTemp + 'Plugin_' + DbaName(_DbaAreaAlias)

  sGitResOutputPath  : 'C:\Temp\'
  sGitDirStructure   : '\.git\refs\'
  
  sButtonTextAlign   : _WinJustLeft
end;


//---------------------------------------------------------------------------------------
// Send exit command to designer
//---------------------------------------------------------------------------------------
sub ExitDesigner(aInstance : int)
local begin
  vPluginCmd    : handle;
end
begin
  // Create plugin command.
  vPluginCmd # C16_Plugin_Cnv:CreateCmd(sPluginCmdKindCmd, 'Designer.Menu.File.Exit.Exec');
  if (vPluginCmd > 0) then begin
    // Send command to designer.
debugx('EXIT:'+aint(C16_Plugin_Cnv:SendCmd(aInstance, vPluginCmd)));

    // Delete command.
    vPluginCmd->C16_Plugin_Cnv:DeleteCmd();
  end;
end;


//---------------------------------------------------------------------------------------
// get designer version number.
//---------------------------------------------------------------------------------------
sub GetDesignerVersionNumber(
  aInstance         : int;    // Plugin instance.
  var aVers         : alpha;
) : int;                       // Result code (< 0) or version number (> 0).
local begin
  tPluginCmd : handle;
  tReplyCmd  : handle;
  tResult    : int;
end
begin
  // Create plugin command.
  tPluginCmd # C16_Plugin_Cnv:CreateCmd(sPluginCmdKindCmd,'Designer.GetInfo',C16_Plugin_Core:NextSerial());

  // Add command return arguments.
  tPluginCmd->C16_Plugin_Cnv:AddArgRet('Version');
  tPluginCmd->C16_Plugin_Cnv:AddArgRet('VersionNum');
  tPluginCmd->C16_Plugin_Cnv:AddExecResult();

  // Send command (sync).
  tReplyCmd   # C16_Plugin_Cnv:CreateCmd();
  tResult     # C16_Plugin_Cnv:SendCmd(aInstance,tPluginCmd,5000,tReplyCmd);
  tPluginCmd->C16_Plugin_Cnv:DeleteCmd();

  // Get execution result / requested object information.
  if (tResult = _ErrOK) then begin
    tResult # tReplyCmd->C16_Plugin_Cnv:GetExecResult();
    if (tResult = _ErrOK) then begin
      tResult # tReplyCmd->C16_Plugin_Cnv:GetArgStr('Version',var aVers,true);
      if (tResult = _ErrOK) then begin
        tReplyCmd->C16_Plugin_Cnv:GetArgInt('VersionNum',var tResult,true);
      end;
    end;
  end;

  tReplyCmd->C16_Plugin_Cnv:DeleteCmd();

  RETURN(tResult);
end;


//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
sub OpenProcedure(
  aInstance       : int;
  aName           : alpha;
)
local begin
  vPluginCmd    : handle;
end
begin
  // Create plugin command.
  vPluginCmd # C16_plugin_Cnv:CreateCmd(sPluginCmdKindCmd, 'Designer.Editor.Open');
  if (vPluginCmd > 0) then begin
    // Add procedure name and type as arguments.
    vPluginCmd->C16_Plugin_Cnv:AddArgStr('Name', aName, sPluginArgStrC16);
    vPluginCmd->C16_Plugin_Cnv:AddArgInt('Type', 0);

    // Send command to designer.
    C16_Plugin_Cnv:SendCmd(aInstance, vPluginCmd);

    // Delete command.
    vPluginCmd->C16_Plugin_Cnv:DeleteCmd();
  end;
end;


//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
sub Form.Export(
  aInstance       : int;
  aFormName       : alpha;
  aFormType       : int;
  aFileName       : alpha(4000);
  aAlsXML         : logic;
) : logic
local begin
  vPluginCmd    : handle;
end
begin
  // Create plugin command.
  vPluginCmd # C16_plugin_Cnv:CreateCmd(sPluginCmdKindCmd, 'Designer.Forms.Export');
  if (vPluginCmd <= 0) then RETURN false;
  
  // Add procedure name and type as arguments.
  vPluginCmd->C16_Plugin_Cnv:AddArgStr('FormName', aFormName, sPluginArgStrC16);
  vPluginCmd->C16_Plugin_Cnv:AddArgInt('Type', aFormType);
  vPluginCmd->C16_Plugin_Cnv:AddArgStr('FileName', aFileName, sPluginArgStrC16);
  if (aAlsXML) then
    vPluginCmd->C16_Plugin_Cnv:AddArgStr('FileFormat', 'xml', sPluginArgStrC16);

  // Send command to designer.
C16_Plugin_Cnv:SendCmd(aInstance, vPluginCmd);

  // Delete command.
  vPluginCmd->C16_Plugin_Cnv:DeleteCmd();

  RETURN true;
end;


//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
sub Form.Open(
  aInstance       : int;
  aFormName       : alpha;
  aFormType       : int;
) : logic
local begin
  vPluginCmd    : handle;
end
begin
  // Create plugin command.
  vPluginCmd # C16_plugin_Cnv:CreateCmd(sPluginCmdKindCmd, 'Designer.Forms.Open');
  if (vPluginCmd <= 0) then RETURN false;
  
  // Add procedure name and type as arguments.
  vPluginCmd->C16_Plugin_Cnv:AddArgStr('Name', aFormName, sPluginArgStrC16);
  vPluginCmd->C16_Plugin_Cnv:AddArgLogic('ReadOnly', true);;
  vPluginCmd->C16_Plugin_Cnv:AddArgInt('Type', aFormType);

  // Send command to designer.
  C16_Plugin_Cnv:SendCmd(aInstance, vPluginCmd);

  // Delete command.
  vPluginCmd->C16_Plugin_Cnv:DeleteCmd();

  RETURN true;
end;


//---------------------------------------------------------------------------------------
// Close ALL Forms
//---------------------------------------------------------------------------------------
sub Form.CloseAll(aInstance : int)
local begin
  vPluginCmd    : handle;
end
begin
  // Create plugin command.
  vPluginCmd # C16_Plugin_Cnv:CreateCmd(sPluginCmdKindCmd, 'Designer.Menu.File.CloseAll.Exec');
  if (vPluginCmd > 0) then begin
    // Send command to designer.
    C16_Plugin_Cnv:SendCmd(aInstance, vPluginCmd);
    // Delete command.
    vPluginCmd->C16_Plugin_Cnv:DeleteCmd();
  end;
end;


//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
sub Term(var aInstance : int)
begin
  // Global data already freed.
//  if (VarInfo(gPrivate_PluginLibWinGlobalData) = 0)
//    return;
  // Close the plugin instance.
  if (aInstance > 0) then begin
debugx('exitdesigner...');
    ExitDesigner(aInstance);
winsleep(1000);
debugx('close Inst....');
    C16_Plugin_Core:InstanceClose(aInstance);
    //C16_Plugin_Core:InstanceCloseAll();
debugx('done');
    aInstance # 0;
  end;
end;


//---------------------------------------------------------------------------------------
// TEST
//---------------------------------------------------------------------------------------
sub Test()
local begin
  aPort             : int;
  vPluginCmd        : handle;
  vPluginWinFrame   : int;
  vInstance         : int;
  
  vResult     : int;
  vSerial     : int64;
  vUser       : alpha;
  vPassword   : alpha;
  vPluginName : alpha;
  vA          : alpha;
  vVer        : int;
  
  vStoDir     : int;
  vStoObj     : alpha;
  vName       : alpha;
end
begin
  aPort # 1337;//4717;
  vPluginWinFrame # 0;
/***
    if (SysClone(_CloneAdvanced,'','/C16PluginPort=' + CnvAI(tPort, _FmtInternal),tUser,tPassword) < 0)
      WinDialogBox(0,'Designer starten', 'Designer konnte nicht gestartet werden',_WinIcoError,
                   _WinDialogOk,1);
    else
    {
      _App->wpTileTheme # _WinTileThemeModern;
      SysSleep(3000);
      InitPlugin('Procedure-Manager', tPort);
      StartPlugin();
      TermPlugin();
    }
***/
  if (SysClone(_CloneAdvanced|_CloneMinimized,'','/C16PluginPort=' + CnvAI(aPort, _FmtInternal),'AH','') < 0) then begin
    Msg(99,'Designer konnte nicht gestartet werden',_WinIcoError,_WinDialogOk,1);
    RETURN;
  end;

  // Create plug-in instance.
  vInstance # C16_Plugin_Core:InstanceNew(aPort,sPluginTimeout,vPluginWinFrame);

  if (vInstance <= 0) then begin
    Msg(99, 'Instanz konnte nicht erstellt werden. Fehler ' + mIntToAlphaDec(vInstance),0,0,0);
    RETURN;
  end;

  // Plug-in password for authentication with designer.
  vPassword # sPluginPassword;
  // Plugin name is shown in designer logfile.
  vPluginName # 'Dialog-Manager - ' + mIntToAlphaDec(vInstance);

  // Authentication --------------
  vResult # C16_Plugin_Cnv:ReceiveAuth(_ReceiverByInstanceID, vInstance,var vSerial,var vUser, sPluginTimeout);

  if (vResult = _ErrOK) then begin
    vResult # C16_Plugin_Cnv:ReplyAuth(vInstance, vSerial, vPluginName, vPassword, sPluginTimeout);
  end;
  if (vResult <> _ErrOK) then begin
    Term(var vInstance);
    Msg(99,'Anmeldung fehlgeschlagen. Fehler ' + mIntToAlphaDec(vResult),0,0,0);
    RETURN;
  end;
//debugx('Auth accept');
//msg(99,'bin drin...',0,0,0);
winsleep(1000);
  // Prozedur -----------------------------------
//  OpenProcedure(vInstance, 'asdsad');
//msg(99,'Proc offen!',0,0,0);
  
// Version ---------------------------------
  vVer # GetDesignerVersionNumber(vInstance, var vA);
  //if (vVer >= 0x05080301)
//  Msg(99,'Version :'+cnvab(vVer)+' '+vA,_WinIcoError,_WinDialogOk,1);

  // Form ---------------------------------------
  Form.CloseAll(vInstance);
  
  vStoDir # StoDirOpen( 0, 'Dialog' );
  FOR  vStoObj # vStoDir->StoDirRead( _stoFirst );
  LOOP vStoObj # vStoDir->StoDirRead( _stoNext, vStoObj );
  WHILE ( vStoObj != '' ) DO BEGIN
  if (StrCnv(vStoOBj,_StrUpper)>'B') then BREAK;
debugstamp(vStoObj);
vName # Str_ReplaceAll(vStoObj, '.','_');
vName # 'd:\\debug\\export\\'+vName;
    Form.Open(vInstance, vStoObj, 0);
winsleep(50);
    Form.Export(vInstance, vStoObj, 0, vName+'.xml', true);
winsleep(400);
    Form.Export(vInstance, vStoObj, 0, vName+'.rsx', false);
winsleep(400);
    Form.CloseAll(vInstance);
winsleep(50);
  END;
  vStoDir->StoClose();
  
//  Form.Open(vInstance, 'Adr.Verwaltung', 0);
//  Form.ExportXML(vInstance, 'Adr.Verwaltung', 0, 'd:\\debug\\Adr_Verwaltung.xml');
//  Form.CloseAll(vInstance);
//winsleep(1000);

winsleep(1000);
  Term(var vInstance);

end;

//---------------------------------------------------------------------------------------