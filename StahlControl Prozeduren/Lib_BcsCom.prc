@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_BcsCom
//                  OHNE E_R_G
//  Info
//
//
//  04.04.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB LoadDLL() : logic;
//  SUB UnloadDLL() : logic;
//  SUB NeedVersion(aVer : float) : logic;
//  SUB SerialInit(aSettingsFile : alpha(1000)) : alpha;
//  SUB SerialTerm() : alpha;
//  SUB SerialWrite(aText : alpha) : alpha;;
//  SUB SerialRead(var aText : alpha) : alpha;;
//  SUB SerialFlush() : alpha;;
//  SUB Init_DataLogic(aSettingsFile : alpha(1000)) : logic;
//  SUB ScanSettings() : logic;
//  SUB StartScan() : alpha;
//
//  SUB ExcelToCsv(aSource : alpha; aDest : alpha) : logic
//
//========================================================================
@I:Def_Global
define begin
  xcCheckstring : aint(Hub.Ek.Nummer)//anum(BAG.IO.Plan.In.Menge,0)+BAG.IO.MEH.In+'  i:'+anum(BAG.IO.Ist.Out.Menge,0)+BAG.IO.MEH.Out
  xcCheckLine : //if (gZllist<>0) then vA # vA + gzLList->wpname+' '+aint(gZLList->wpdbselection)

  TryComCall(a,b) : vErr # 0; Try begin ErrTryCatch(_ErrAll, y); gBCSDLL->ComCall b end; vErr # errGet(); ErrSet(0); if (vErr<0) then WindialogBox(0,'Error','COM-Error @ '+a+' '+cnvai(vErr),_WinicoError,0,0);
  cCR         : Strchar(13)

  ARGB(a, r, g, b ) : ( b + ( g << 8 ) + ( r << 16 ) + ( a << 24 ))
end;


//========================================================================
//  LoadDLL
//========================================================================
sub LoadDLL() : logic;
begin

//"&%windir%\\Microsoft.NET\\Framework\\V4.0.30319\\regasm -tlb -codebase bcs_com.dll

  if (gBCSDLL<>0) then RETURN true;

  gBCSDLL # ComOpen( 'BCS_COM', _comAppCreate );
  if ( gBCSDLL = 0 ) then begin
    Lib_FileIO:StartRegasm('-tlb -codebase '+Set.Client.Pfad+'\dlls\bcs_com.dll');
    gBCSDLL # ComOpen( 'BCS_COM', _comAppCreate );
    if ( gBCSDLL = 0 ) then begin
      WindialogBox(0,'Error','BCS_COM.DLL fehlt!! Bitte genau JETZT nachinstalliert durch Start von "Dlls\InstallBcsCom.exe" und dann OK drücken...',0,0,0);
      gBCSDLL # ComOpen( 'BCS_COM', _comAppCreate );
      if ( gBCSDLL = 0 ) then begin
        WindialogBox(0,'Error','keine BCS_COM.DLL gefunden!',0,0,0);
        RETURN false;
      end;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  UnloadDLL
//========================================================================
sub UnloadDLL() : logic;
begin

  if (gBCSDLL=0) then RETURN true;
  gBCSDLL->ComClose();
  gBCSDLL # 0;
  RETURN true;
end;


//========================================================================
//  NeedVersion
//========================================================================
sub NeedVersion(aVer : float) : logic;
local begin
  vVer  : float;
end;
begin
  vVer # gBCSDLL->cpfVersion;
  if (vVer<aVer) then begin
    WindialogBox(0,'Error','BCS_COM.DLL benötigt mind. Stand '+anum(aVer,2)+'! Bitte updaten...',0,0,0);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  SerialInit
//
//========================================================================
sub SerialInit(aSettingsFile : alpha(1000)) : alpha;
local begin
  vX        : float;
  vI,vJ     : int;
  vHdl2     : handle;
  vA,vB     : alpha(4000);
  vRect     : rect;
  vFont     : font;
  vDia      : int;
  vMsg      : int;
  vProgress : int;
  vHdl      : handle;
  vTxt      : int;
  vTree     : int;
  vCount    : int;
  vSplash   : int;
  vWinBonus : int;

  vErr      : int;
  vOK       : logic;
end;
begin

/*
  TryComCall('eine unbekannten Prozedur', ('Bums', '123',123) );
  if (vErr<>0) then begin
//    vCOM->ComClose();
//    RETURN;
  end;
  TryComCall('Start ScanSetting', ('OpenScanSettingsDialog', Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.xml'));
  TryComCall('Start Scan', ('StartScan', Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.xml', Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.tif'));
*/

  TryComCall('init COM', ('InitSerialPort', aSettingsFile) );
  if (vErr<>0) then RETURN 'COM-Port nicht öffenbar!';
end;


//========================================================================
// SerialTerm
//========================================================================
sub SerialTerm() : alpha;
local begin
  vErr      : int;
end;
begin
  TryComCall('term COM', ('TermSerialPort') );
  if (vErr<>0) then RETURN 'COM-Port nicht schließbar!';
end;


//========================================================================
// SerialWrite
//========================================================================
sub SerialWrite(aText : alpha) : alpha;;
local begin
  vErr      : int;
end;
begin
  TryComCall('write COM', ('WriteSerialPort', aText)); //'$+$!'+Strchar(13)) );
  if (vErr<>0) then RETURN 'COM-Port nicht beschreibbar!';
end;


//========================================================================
// SerialRead
//========================================================================
sub SerialRead(var aText : alpha) : alpha;;
local begin
  vErr      : int;
  vLen      : int;
end;
begin
  TryComCall('read COM', ('ReadSerialPort', var vLen));
  if (vErr<>0) then RETURN 'COM-Port nicht lesbar!';
  aText # gBCSDLL->cpaLastSerialPortString;
end;

//========================================================================
// SerialFlush
//========================================================================
sub SerialFlush() : alpha;;
local begin
  vErr      : int;
end;
begin
  TryComCall('flush', ('FlushSerialPort') );
  if (vErr<>0) then RETURN 'COM-Port kann nicht geleert werden!';
end;


//========================================================================
// Init_DataLogic
//========================================================================
sub Init_DataLogic(aSettingsFile : alpha(1000)) : logic;
local begin
  vErr      : alpha(4000);
  vI,vJ     : int;
  vA        : alpha(4000);
end;
begin

  if (gBCSDLL=0) then LoadDLL();
  if (gBCSDLL=0) then RETURN false;

  vErr # SerialInit(aSettingsFile);
  if (vErr<>'') then begin
    WindialogBox(0,'Error',vErr,0,0,0);
    RETURN false;
  end;

  vErr # SerialFlush();
  if (vErr<>'') then begin
    SerialTerm();
    WindialogBox(0,'Scanner',vErr,0,0,0);
    RETURN false;
  end;

  Winsleep(100);

  // ReleaseStand abfragen
  vErr # SerialWrite('$+$!'+cCR);
  if (vErr<>'') then begin
    SerialTerm();
    WindialogBox(0,'Scanner',vErr,0,0,0);
    RETURN false;
  end;

  vI # 0;
  REPEAT
//    gBCSDLL->ComCall('ReadSerialPort', var vI);
    vErr # SerialRead(var vA);
    Winsleep(10);
    inc(vI);
  UNTIL (vA<>'') or (vI>150);

  if (vA='') then begin
    SerialTerm();
    WindialogBox(0,'Scanner','Scanner "Datalogic" nicht gefunden!',0,0,0);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// ScanSettings
//========================================================================
Sub ScanSettings() : logic;
local begin
  vErr      : int;
  vBonus    : int;
  vA        : alpha;
end;
begin

  if (LoadDLL()=false) then RETURN false;

  vBonus # VarInfo(Windowbonus);
  TryComCall('test', ('Test', 'Abc'));
  if (vErr=0) then begin
    ComCallResult(gBCSDLL, vA);
  end;

  TryComCall('Start ScanSetting', ('OpenScanSettingsDialog', Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.xml'));

  UnloadDLL();

  if (vBonus<>0) then Varinstance(Windowbonus, vBonus);

  RETURN true;
end;


//========================================================================
// SrartScan
//========================================================================
Sub StartScan() : alpha;
local begin
  vErr      : int;
  vName     : alpha(4000);
  vBonus    : int;
end;
begin

  vName # Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.tif';

  if (LoadDLL()=false) then RETURN '';

  vBonus # VarInfo(Windowbonus);
//todo('Config:' + Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.xml');
//todo('Output:' + vName);
  TryComCall('Start Scan', ('StartScan', Set.Client.Pfad+'\settings\'+gUsername+'_SCAN.xml', vName));
//todo('Nach TryComCall');

  UnloadDLL();

  if (vBonus<>0) then Varinstance(Windowbonus, vBonus);

  if (Lib_FileIO:FileExists(vName)=false) then RETURN '';

  RETURN vName;
end;


//========================================================================
// ExcelToCsv
//========================================================================
SUB ExcelToCsv(
  aSource : alpha;
  aDest   : alpha) : logic;
local begin
  vErr      : int;
end;
begin
  if (LoadDLL()=false) then RETURN false;

  TryComCall('Start Converter', ('ConvertExcelToCsv',aSource, aDest));
//  TryComCall('Start Converter', ('Test',aSource));

  UnloadDLL();

  RETURN true;
end;


//========================================================================
// TEST
//========================================================================
SUB TEST() : logic;
local begin
  vErr      : int;
  vHdl      : handle;
//  vCoords   : int[50];
  vI, vJ    : int;
end;
begin
  if (LoadDLL()=false) then RETURN false;

  TryComCall('Create Bitmap', ('BitmapCreate',500, 500));
  if (vErr<>0) then begin
    UnloadDLL();
    RETURN false;
  end;

  ComCallResult(gBCSDLL, vHdl);

//  vcoords[1] # 10;
//  vcoords[2] # 10;
//  vcoords[3] # 160;
//  vcoords[4] # 160;
//  vcoords[5] # 100;
//  vcoords[6] # 10;
//  vcoords[7] # 150;
//  vcoords[8] # 190;
//  vcoords[9] # 400;
// comcall
//  TryComCall('Draw', ('LineArrayDraw', vHdl, 2, var vcoords));

  // b g r a
  vJ # ( 0 + ( 255 << 8 ) + ( 0 << 16 ) + ( 255 << 24 ));

  FOR vI # 0 loop vI # vI + 1 while (vI<250) do begin
    TryComCall('Draw', ('LineDraw', vHdl, ARGB(255, 255, 0, 0),        1, 0, 0, vI, 500));
    TryComCall('Draw', ('LineDraw', vHdl, ARGB(255, 0, 255, 0),        1, 0, 500, 500, 500-vI));
    TryComCall('Draw', ('LineDraw', vHdl, ARGB(255, 0, 0, 250),        1, 500, 500, 500-vI, 0));
  END;

  TryComCall('Save Bitmap', ('BitmapSave', vHdl, 'E:\test.png'));

  UnloadDLL();

  RETURN true;
end;

//========================================================================