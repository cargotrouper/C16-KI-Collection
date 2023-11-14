@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOA_Data
//                    OHNE E_R_G
//  Info
//        Service Oriented Architecture - Einstiegspunkt
//
//  23.06.2010  PW  Erstellung
//
//  Subprozeduren
//    sub telnetEntry ( aObj : handle; aEvt: int; )
//=========================================================================
@I:Def_Global
@I:SOA_Data_Subs


//=========================================================================
// httpEntry
//        SOA HTTP Einstiegspunkt
//=========================================================================
sub httpEntry ( aTsk : handle; aEvtType : int )
local begin
  vSck : handle;
  vRsp : handle;
  vReq : handle;
  vMem : handle;

  vDoc  : handle;
  vRoot : handle;
  vNode : handle;
  vTmp  : handle;

  vItem : handle;
  vData : handle;
  vErg : int;
end;
begin
  vSck # aTsk->spSvcSckHandle;
  // SvcSessionControl

  /*
   * vReq->spMethod          HTTP method (GET, POST, PUSH, DELETE, ...)
   * vReq->spStatusCode      '123 abc'
   * vReq->spHostName        server host name (192.168.0.2:5050)
   * vReq->spURI             '/' + path + [ '?' + query ]
   * vReq->spHttpHeader      HTTP header
   * vReq->spHttpParameters  GET data
   */

  case aEvtType of
    _sckEvtConnect : begin
      vReq # HttpOpen( _httpRecvRequest, vSck );
      vRsp # HttpOpen( _httpSendResponse, vSck );
      vMem # MemAllocate( _memAutoSize );

      dbg( '// ' + vSck->SckInfo( _sckAddrPeer ) + ' - ' + vReq->spMethod + ' ' + vReq->spURI );

      dbgCte( 'h', vReq->spHttpHeader )
      //dbgCte( 'g', vReq->spHttpParameters )

      vDoc  # CteOpen( _cteNode );
      vDoc->spId # _xmlNodeDocument;
      vRoot # vDoc->Lib_XML:AppendNode( 'Request' );

      vRoot->Lib_XML:AppendNode( 'Method', vReq->spMethod );
      vRoot->Lib_XML:AppendNode( 'RequestURL', vReq->getRequestUrl() );
      vRoot->Lib_XML:AppendNode( 'FullURL', vReq->spURI );

      // Header auslesen
      vNode # vRoot->Lib_XML:AppendNode( 'Header' );
      FOR  vItem # vReq->spHttpHeader->CteRead( _cteFirst );
      LOOP vItem # vReq->spHttpHeader->CteRead( _cteNext, vItem );
      WHILE ( vItem != 0 ) DO BEGIN
        vNode->Lib_XML:AppendNode( vItem->spName, vItem->spCustom );
      END;

      // GET
      vNode # vRoot->Lib_XML:AppendNode( 'GET' );
      FOR  vItem # vReq->spHttpParameters->CteRead( _cteFirst );
      LOOP vItem # vReq->spHttpParameters->CteRead( _cteNext, vItem );
      WHILE ( vItem != 0 ) DO BEGIN
        vTmp # vNode->Lib_XML:AppendNode( 'param', vItem->spCustom );
        vTmp->Lib_XML:AppendAttributeNode( 'name', vItem->spName );
      END;


      // data
      /*
      vItem # FsiOpen( '\\server2009.bcs-dom.local\C16\SOAdebugXX.txt', _fsiAcsRW | _fsiDenyRW | _fsiCreate | _fsiTruncate  );
      vData # MemAllocate( _memAutoSize );
      vSck->SckInfo( _sckTimeOut, 1000 );
      vReq->HttpGetData( vData );
      vSck->SckInfo( _sckTimeOut, 30000 );

      vErg # vItem->FsiWriteMem( vData, 1, vData->spLen );
      dbg( CnvAI( vErg ) )
      */

      // POST
      vData # CteOpen( _cteList );
      vReq->HttpGetData( vData );

      vNode # vRoot->Lib_XML:AppendNode( 'POST' );
      FOR  vItem # vData->CteRead( _cteFirst );
      LOOP vItem # vData->CteRead( _cteNext, vItem );
      WHILE ( vItem != 0 ) DO BEGIN
        vTmp # vNode->Lib_XML:AppendNode( 'param', vItem->spCustom );
        vTmp->Lib_XML:AppendAttributeNode( 'name', vItem->spName );
      END;
      vData->CteClose();

      vDoc->XmlSave( null, _xmlSaveDefault, vMem );
      vRsp->spStatusCode # getHttpStatus( 200 );
      setParam( vRsp->spHttpHeader, 'Content-Type', 'text/xml' );
      setParam( vRsp->spHttpHeader, 'Content-Length', CnvAI( vMem->spLen, _fmtNumNoGroup ) );


      vReq->HttpClose( 0 );
      vRsp->HttpClose( 0, vMem );
      vData->MemFree();
      vMem->MemFree();
      vSck->SckClose();
    end;

    _sckEvtDisconnect : begin
      dbg( '// ' + vSck->SckInfo( _sckAddrPeer ) + ' DISCONNECT' );
    end;

    _sckEvtData : begin
      dbg( '// ' + vSck->SckInfo( _sckAddrPeer ) + ' DATA' );
    end;

    _sckEvtTimeout : begin
      dbg( '// ' + vSck->SckInfo( _sckAddrPeer ) + ' TIMEOUT' );
    end;

    otherwise begin
      dbg( '// ' + vSck->SckInfo( _sckAddrPeer ) + ' UNKNOWN:' + CnvAI( aEvtType ) );
    end;
  end;
end;


//=========================================================================
// telnetEntry
//        SOA Telnet Einstiegspunkt
//=========================================================================
sub telnetEntry ( aTsk : handle; aEvtType : int )
local begin
  vSck  : handle;
  vLine : alpha(250);
end;
begin
  vSck # aTsk->spSvcSckHandle;

  dbg( '// telnetEntry //' );
  dbg( 'IP Address: ' + vSck->SckInfo( _sckAddrPeer ) );

  case aEvtType of
    _sckEvtConnect : begin
      dbg( 'Socket connect' );

      FOR  vSck->SckRead( _sckLine, vLine );
      LOOP vSck->SckRead( _sckLine, vLine );
      WHILE ( vLine != 'exit' ) DO BEGIN
        dbg( '> ' + vLine + '' );

        if ( vLine = 'Hallo' ) then begin
          vSck->SckWrite( _sckLine, 'Hallo Welt' );
          dbg( '< Hallo Welt' );
        end;
      END;

      if ( ErrGet() = _errTimeOut ) then
        dbg( 'Timeout.' );

      vSck->SckClose();
      vSck->JobClose();
      aTsk->JobClose();
    end;

    _sckEvtDisconnect : begin
      dbg( 'Socket disconnect' );
    end;

    _sckEvtData : begin
      dbg( 'Socket data' );
    end;

    _sckEvtTimeout : begin
      dbg( 'Socket timeout' );
    end;

    otherwise begin
      dbg( 'Unknown event: ' + CnvAI( aEvtType ) );
    end;
  end;
end;


//=========================================================================
// MAIN
//        SOA Server Einstiegspunkt
//=========================================================================
MAIN ( aTsk : handle; aEvtType : int )
begin
  httpEntry( aTsk, aEvtType );
  //SOA_HttpServer:entry( aTsk, aEvtType );


  if ( vDbgFileG > 0 ) then
    vDbgFileG->FsiClose();
end;

//=========================================================================
//=========================================================================