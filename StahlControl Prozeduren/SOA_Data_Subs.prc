@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOA_Data_Subs
//                  OHNE E_R_G
//  Info
//        Service Oriented Architecture - Hilfsfunktionen
//
//  23.06.2010  PW  Erstellung
//
//  Subprozeduren
//    sub dbg ( aText : alpha(2000) )
//    sub getHttpStatus ( aCode : int ) : alpha
//    sub setParam ( aCteList : handle; aName : alpha; opt aValue : alpha ) : logic
//    sub getParam ( aCteList : handle; aName : alpha ) : alpha
//=========================================================================
@I:Def_Global

define begin
  cDbgFile : '\\server2009.bcs-dom.local\C16\SOAdebug.txt'
  cRN      : StrChar( 13 ) + StrChar( 10 )

  // Settings
  cTimeOut : 30000
  cUseGlobal : false
end;

local begin
  vDbgFileG : handle;
end;

//=========================================================================
// dbg
//        SOA debug
//=========================================================================
sub dbg ( aText : alpha(2000) )
local begin
  vDbgFile : handle;
end
begin
  if ( cUseGlobal ) then begin
    if ( vDbgFileG <= 0 ) then
      vDbgFileG # FsiOpen( cDbgFile, _fsiAcsW | _fsiCreate | _fsiAppend );

    if ( vDbgFileG > 0 ) then
      vDbgFileG->FsiWrite( StrCnv( aText + cRN, _strToANSI ) );
  end;

  vDbgFile # FsiOpen( cDbgFile, _fsiAcsW | _fsiDenyRW | _fsiCreate | _fsiAppend );
  if ( vDbgFile > 0 ) then begin
    vDbgFile->FsiWrite( StrCnv( aText + cRN, _strToANSI ) );
    vDbgFile->FsiClose();
  end
  else
    debug( CnvAI( vDbgFile ) );
end;


//=========================================================================
// dbgCte
//        SOA debug for CTE lists
//=========================================================================
sub dbgCte ( aMark : alpha; aCteList : handle ) : alpha;
local begin
  vText : alpha(3000);
  vItem : handle;
end
begin
  FOR  vItem # aCteList->CteRead( _cteFirst );
  LOOP vItem # aCteList->CteRead( _cteNext, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    vText # vText + aMark + ' / ' + vItem->spName + ' = ' + vItem->spCustom + cRN;
    dbg( aMark + ' / ' + vItem->spName + ' = ' + vItem->spCustom );
  END;

  RETURN vText
end;


//=========================================================================
// getHttpStatus
//        HTTP
//=========================================================================
sub getHttpStatus ( aCode : int ) : alpha
begin
  case aCode of
    100 : RETURN '100 Continue';
    200 : RETURN '200 OK';
    201 : RETURN '201 Created';
    202 : RETURN '202 Accepted';
    204 : RETURN '204 No Content';
    300 : RETURN '300 Multiple Choices';
    301 : RETURN '301 Moved Permanently';
    302 : RETURN '302 Found';
    304 : RETURN '304 Not Modified';
    307 : RETURN '307 Temporary Redirect';
    400 : RETURN '400 Bad Request';
    401 : RETURN '401 Unauthorized';
    403 : RETURN '403 Forbidden';
    404 : RETURN '404 Not Found';
    405 : RETURN '405 Method Not Allowed';
    406 : RETURN '406 Not Acceptable';
    408 : RETURN '408 Request Timeout';
    500 : RETURN '500 Internal Server Error';
    501 : RETURN '501 Not Implemented';
    502 : RETURN '502 Bad Gateway';
    503 : RETURN '503 Service Unavailable';
    504 : RETURN '504 Gateway Timeout';

    otherwise
      RETURN '400 Bad Request';
  end;
end;


//=========================================================================
// getRequestUrl
//        HTTP
//=========================================================================
sub getRequestUrl ( aHttp : handle ) : alpha
local begin
  vPos : int;
end;
begin
  vPos # StrFind( aHttp->spURI, '?', 1 );
  if ( vPos > 0 ) then
    RETURN StrCut( aHttp->spURI, 1, vPos - 1 );
  else
    RETURN aHttp->spURI;
end;


//=========================================================================
// setParam
//        Parameter in Parameterliste hinzufügen
//=========================================================================
sub setParam ( aCteList : handle; aName : alpha; opt aValue : alpha )
local begin
  vItem : handle;
end;
begin
  vItem # aCteList->CteRead( _cteFirst | _cteSearch, null, aName );
  if ( vItem != 0 ) then
    vItem->spCustom # aValue;
  else
    aCteList->CteInsertItem( aName, 0, aValue );
end;


//=========================================================================
// getParam
//        Parameter in Parameterliste auslesen
//=========================================================================
sub getParam ( aCteList : handle; aName : alpha ) : alpha
local begin
  vItem : handle;
end;
begin
  vItem # aCteList->CteRead( _cteFirst | _cteSearch, null, aName );
  if ( vItem != 0 ) then
    RETURN vItem->spCustom;
end;

//=========================================================================
//=========================================================================