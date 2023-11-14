@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Sound
//                      OHNE E_R_G
//  Info
//
//
//  26.08.2009  AI  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB Initialize()
//    SUB Terminate()
//    SUB Play(aFIle : alpha);
//
//========================================================================
@I:Def_Global

define begin
  cSoundpath : 'sound\'
end;

//========================================================================
//  Initialize
//
//========================================================================
sub Initialize ()
begin
RETURN; // 2023-04-06 AH

  if ( gDLL_Sound != 0 )
    then RETURN;

  gDLL_Sound # DllLoad( FsiPath() + '\' + cSoundPath + 'C16Sound.dll' );

  if ( gDLL_Sound < 0 ) then
    gDLL_Sound # 0;
end;


//========================================================================
//  Terminate
//
//========================================================================
sub Terminate ()
begin
  if ( gDLL_Sound != 0 ) then begin
    gDLL_Sound->DllUnload();
    gDLL_Sound # 0;
  end;
end;


//========================================================================
//  Play
//
//========================================================================
sub Play ( aFile : alpha(200) );
begin
  if ( gDLL_Sound != 0 ) then begin
    gDLL_Sound->DllCall( FsiPath() + '\'+ cSoundPath + aFile );
  end;
end;


//========================================================================
//  Say
//
//========================================================================
sub Say ( aText : alpha );
local begin
  vHdl : handle;
end;
begin
  vHdl # FSIOpen( cSoundpath + 'test.txt', _fsiAcsRW | _fsiDenyRW | _fsiCreate | _fsiTruncate );
  if ( vHdl > 0 ) then begin
    FsiWrite( vHdl, aText );
    FsiClose( vHdl);
  end;
  SysExecute( cSoundpath + 'Say.Bat', '', _execMinimized );
end;

//========================================================================