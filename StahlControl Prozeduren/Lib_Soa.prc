@A+
//==== Business-Control ===================================================
//
//  Prozedur    Lib_SOA
//                    OHNE E_R_G
//  Info
//        Hilfsfunktionen des Servicelayers für die Webserviceintegration
//
//  02.09.2010  ST  Erstellung der Prozedur
//  01.12.2016  ST  Fehlerrückgabe bei SOA_Init() hinzugefügt
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  21.09.2020  ST  Bugfix: Dbg wirft keinen eigenen Fehler
//  10.11.2021  ST  Edit: "sub Dbg" mit Fehlertoleranz bzgl. Schreibversuchen
//  2023-08-03  AH  "Init" startet nicht alle Events -> macht ohne GUI kein Sinn und Error bei 64bit
//
//  Subprozeduren
//  sub dbg ( aText : alpha(2000) )
//  sub dbgCte ( aMark : alpha; aCteList : handle ) : alpha;
//  sub dbgXML (aNode : handle );
//  sub dbgXMLsoa (aNode : handle );
//  sub dbgNode(aNode : handle)
//  sub getHttpStatus ( aCode : int ) : alpha
//  sub getRequestUrl ( aHttp : handle ) : alpha
//  sub setParam ( aCteList : handle; aName : alpha; opt aValue : alpha )
//  sub getParam ( aCteList : handle; aName : alpha ) : alpha
//  sub getValue ( aNode : handle; aName : alpha ) : alpha
//  sub setValue ( aNode : handle; aName : alpha ; aVal : alpha ) : logic
//  sub getNode ( aParentNode : handle; aName : alpha ) : handle
//  sub addErrNode(aElem : handle; aCode : int; opt aDesc : alpha) : handle
//  sub toUpper(aString : alpha(4096)) : alpha
//  sub isEmpty(aString : alpha(4096)) : logic
//  sub getScVersion() : float
//  sub strCnvXMLOut (aString : alpha) : alpha
//  sub getNodeType(aNode : handle) : alpha
//  sub debugAPIChecks(vChecks : handle)
//  sub addRecord(aParent : handle; aFile : int) : handle
//  sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(300) ) : handle
//  sub CreatePartSel(  aFile : int;  aKey  : int;  aProc : alpha;  aArgs : int;) : int
//  sub ClosePartSel(aPartSel : int);
//  Sub RunPartSel(  aPartSel  : int;  aMax      : int;  opt aRecId : int;) : int;
//  sub ReadNummer(  aName         : alpha;) : int
//  sub SaveNummer() : int
//  sub SelAlpha(aFld : alpha; aJN  : logic; aNot : alpha; aAus : alpha; aVon : alpha; aBis : alpha) : logic
//  sub SelFloat(aFld : float; aJN : logic; aNot : alpha; aAus : alpha; aVon : float; aBis : float) : logic
//  sub SelInt(aFld : int; aJN  : logic; aNot : alpha; aAus : alpha; aVon : int; aBis : int) : logic
//  sub SelDate(aFld : date; aJN  : logic; aNot : alpha; aAus : alpha; aVon : date; aBis : date) : logic
//  sub prepSelAlpha(aArgs : int; aFldName: alpha; var aJN : logic; var aFld : alpha; var aFldNot : alpha; var aFldVon : alpha; var aFldBis : alpha; var aFldAus : alpha)
//  sub prepSelInt(aArgs : int; aFldName: alpha; var aJN : logic; var aFld : int; var aFldNot : alpha; var aFldVon : int; var aFldBis : int; var aFldAus : alpha)
//  sub prepSelFloat(aArgs : int; aFldName: alpha; var aJN : logic; var aFld : float; var aFldNot : alpha; var aFldVon : float; var aFldBis : float; var aFldAus : alpha)
//  sub prepSelDate(aArgs : int; aFldName: alpha; var aJN : logic; var aFld : date;  var aFldNot : alpha; var aFldVon : date; var aFldBis : date; var aFldAus : alpha)
//  sub Allocate()
//  sub BuildErrorResponse(var aErrNode : handle)
//=========================================================================
@I:Def_Global
@I:Def_SOA
@I:Struct_SOA_PartSel


define begin
  //cDbgFile : 'c:\debug\SOAdebug.txt'
  //cDbgFile : 'D:\C16\C16\sc_soa\log\SOAdebug.txt'
  cDbgFile : Set.Soa.Path + 'log\SOAdebug.txt'
  cRN      : StrChar( 13 ) + StrChar( 10 )

  // Settings
  cTimeOut : 30000
  cUseGlobal : true
end;

local begin
  vDbgFileG : handle;
end;

declare Init() : alpha
declare Terminate();
declare ParseErrMsg( aMsg  : alpha(1000); aPara : alpha(1000);) : alpha

//=========================================================================
// dbg
//        SOA debug
//=========================================================================
sub dbg ( aText : alpha(4000) )
local begin
  vDbgFile : handle;
  vErr  : int;

  vTries    : int;
  vTry      : int;
  vSleepMs  : int;
  vOK       : logic;
end
begin
  vErr # ErrGet();
  
  aText # Lib_Debug:_ParseText(aText);    // 05.10.2020 AH
/*
  if ( cUseGlobal ) then begin
    if ( vDbgFileG <= 0 ) then
      vDbgFileG # FsiOpen( cDbgFile, _fsiAcsW | _fsiCreate | _fsiAppend );

    if ( vDbgFileG > 0 ) then
      vDbgFileG->FsiWrite( StrCnv( aText + cRN, _strToANSI ) );
  end;
*/
  vTries    # 10;
  vSleepMs  # 100;
  vOK       # false;
  
  FOR   vTry # 1
  LOOP  inc(vTry)
  WHILE vTry <= vTries+1 DO BEGIN

    vDbgFile # FsiOpen( cDbgFile, _fsiAcsW | _fsiDenyRW | _fsiCreate | _fsiAppend );
    if ( vDbgFile > 0 ) then begin
      vDbgFile->FsiWrite( StrCnv( aText + cRN, _strToANSI ) );
      vDbgFile->FsiClose();
      BREAK;
    end else begin
      WinSleep(vSleepMs);
    end;
    
    // Letzrer Versuch erstellt neues Debugfile mit timestamp
    if  (vTry > vTries) then begin
      vDbgFile # FsiOpen(cDbgFile+'_-27_'+Lib_Strings:Timestamp()+'.txt', _fsiAcsW | _fsiDenyRW | _fsiCreate | _fsiAppend );
      if ( vDbgFile > 0 ) then begin
        vDbgFile->FsiWrite( StrCnv( aText + cRN, _strToANSI ) );
        vDbgFile->FsiClose();
      end;
      BREAK;
    end;
  END;

  // ST 2020-09-21: Debug darf keine eigenen Fehler werfen
  ErrSet(vErr);
end; // sub dbg ( aText : alpha(2000) )


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
end; // sub dbgCte ( aMark : alpha; aCteList : handle ) : alpha;



//=========================================================================
// dbgXML
//        SOA debug for XML
//=========================================================================
sub dbgXML (aNode : handle );
local begin
  vText : alpha(3000);
//  vItem : handle;
  vNode : handle;
end
begin
  if (aNode = 0) then begin
    debug('return');
    return ;
  end;

  FOR  vNode # aNode->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aNode->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE ( vNode > 0 ) DO BEGIN

    debug(' Node:' + CnvAi(vNode));
    case (aNode->spID) of
      _XmlNodeElement : begin
         debug('  spID = _XmlNodeElement' + ' # Kinder:' + CnvAi(vNode->spChildCount));
         debug('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
         debug('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
      end;

      _XmlNodeText    : begin
         debug('  spID = _XmlNodetext');
         debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
         debug('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
      end;

      _XmlNodeDocument : begin
         debug('  spID = _XmlNodeDocument');
      end;

      _XmlNodeAttribute : begin
         debug('  spID = _XmlNodeAttribute');
         debug('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
         debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
         debug('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
      end;

      _XmlNodeComment : begin
         debug('  spID = _XmlNodeComment');
         debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
      end;

    end;

     // Rekursiver aufruf
    if (vNode->spChildCount > 0) then
      dbgXML(vNode);

  END;
  debug('');

end; // sub dbgXML (aNode : handle );


//=========================================================================
// dbgXML
//        SOA debug for XML
//=========================================================================
sub dbgXMLsoa (aNode : handle );
local begin
  vText : alpha(3000);
//  vItem : handle;
  vNode : handle;
end
begin
  if (aNode = 0) then begin
    dbg('return');
    return ;
  end;

  FOR  vNode # aNode->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aNode->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE ( vNode > 0 ) DO BEGIN

    dbg(' Node:' + CnvAi(vNode));
    case (vNode->spID) of
      _XmlNodeElement : begin
         dbg('  spID = _XmlNodeElement' + ' # Kinder:' + CnvAi(vNode->spChildCount));
         dbg('  spName = ' + StrCnv(vNode->spName,_StrFromUTF8));
         dbg('  spCustom = ' + StrCnv(vNode->spCustom,_StrFromUTF8));
      end;

      _XmlNodeText    : begin
         dbg('  spID = _XmlNodetext');
         dbg('  spValueAlpha = ' + StrCnv(vNode->spValueAlpha,_StrFromUTF8));
         dbg('  spCustom = ' + StrCnv(vNode->spCustom,_StrFromUTF8));
      end;

      _XmlNodeDocument : begin
         dbg('  spID = _XmlNodeDocument');
      end;

      _XmlNodeAttribute : begin
         dbg('  spID = _XmlNodeAttribute');
         dbg('  spName = ' + StrCnv(vNode->spName,_StrFromUTF8));
         dbg('  spValueAlpha = ' + StrCnv(vNode->spValueAlpha,_StrFromUTF8));
         dbg('  spCustom = ' + StrCnv(vNode->spCustom,_StrFromUTF8));
      end;

      _XmlNodeComment : begin
         dbg('  spID = _XmlNodeComment');
         dbg('  spValueAlpha = ' + StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      end;


    end;

     // Rekursiver aufruf
    if (vNode->spChildCount > 0) then
      dbgXMLSoa(vNode);

  END;
  dbg('');

end; // sub dbgXMLsoa (aNode : handle );


//========================================================================
//  sub DebugNode(aNode : handle)
//    gibt den Inhalt und Typ eines XML Nodes aus
//========================================================================
sub dbgNode(aNode : handle)
begin
  dbg('  ------------------------------------------------------------------');
  dbg('  Node Handle:' + CnvAi(aNode));
  if (aNode = 0) then
    return;

  case (aNode->spID) of
    _XmlNodeElement : begin
       dbg('  spID = _XmlNodeElement');
       dbg('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
       dbg('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
    end;
    _XmlNodeText    : begin
       dbg('  spID = _XmlNodetext');
       dbg('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
       dbg('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
    end;

    _XmlNodeDocument : begin
       dbg('  spID = _XmlNodeDocument');
    end;

    _XmlNodeAttribute : begin
       dbg('  spID = _XmlNodeAttribute');
       dbg('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
       dbg('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
       dbg('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
    end;

    _XmlNodeComment : begin
       dbg('  spID = _XmlNodeComment');
       dbg('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
    end;

    otherwise begin
      dbg('  umbekannter Notetyp');
    end;

  end;
  debug('  ------------------------------------------------------------------');

end; // sub dbgNode(aNode : handle)




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
end; // sub getHttpStatus ( aCode : int ) : alpha


//=========================================================================
// getRequestUrl
//        HTTP
//=========================================================================
sub getRequestUrl ( aHttp : handle ) : alpha
local begin
  vPos : int;
end;
begin
  if (aHttp = 0) then return '';
  vPos # StrFind( aHttp->spURI, '?', 1 );
  if ( vPos > 0 ) then
    RETURN StrCut( aHttp->spURI, 1, vPos - 1 );
  else
    RETURN aHttp->spURI;
end; // sub getRequestUrl ( aHttp : handle ) : alpha


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
end; // sub setParam ( aCteList : handle; aName : alpha; opt aValue : alpha )




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
end; // sub getParam ( aCteList : handle; aName : alpha ) : alpha


//=========================================================================
// getValue ( aNode : handle; aName : alpha ) : alpha
//     Wert eines NodeElementes auslesen
//
//=========================================================================
sub getValue ( aNode : handle; aName : alpha ) : alpha
local begin
  vRet : alpha;
  vElem : handle;
  vNode : handle;
end;
begin

 if (aNode <> 0) then begin
    // Element suchen
    aName # strCnv(aName,_StrUmlaut);
    vElem # aNode->CteRead(_CteSearchCi | _CteFirst |_CteChildList ,0 , aName);
    if (vElem <> 0) then begin
      // TextNode innerhalb des Elementes lesen
      vNode # vElem->CteRead(_CteFirst  | _CteChildList)
      if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
        // vRet # StrCnv(vNode->spValueAlpha,_StrFromUTF8);
        vRet # StrCnv(vNode->spValueAlpha,0);
      end;
    end;
  end;

  return vRet;
end; // sub getValue ( aNode : handle; aName : alpha ) : alpha



//=========================================================================
// sub setValue ( aNode : handle; aName : alpha ; aVal : alpha ) : alpha
//     Setzt den Wert eines NodeElementes
//
//=========================================================================
sub setValue ( aNode : handle; aName : alpha ; aVal : alpha ) : logic
local begin
  vRet : alpha;
  vElem : handle;
  vNode : handle;
end;
begin

 if (aNode <> 0) then begin
    // Element suchen
    aName # strCnv(aName,_StrUmlaut);
    vElem # aNode->CteRead(_CteSearchCi | _CteFirst |_CteChildList ,0 , aName);
    if (vElem <> 0) then begin
      if (Lib_XML:AppendTextNode(vElem,aVal) > 0) then
        return true;
    end;
  end;

  return false;
end; // sub setValue ( aNode : handle; aName : alpha ; aVal : alpha ) : logic


//=========================================================================
// sub getNode ( aParentNode : handle; aName : alpha ) : handle
//     Liest einen Knoten eines Baumes
//
//=========================================================================
sub getNode ( aParentNode : handle; aName : alpha ) : handle
begin
 if (aParentNode <> 0) then begin
    return aParentNode->CteRead(_CteSearch | _CteFirst |_CteChildList ,0 , aName);
 end else
  return 0;
end; // sub getNode ( aParentNode : handle; aName : alpha ) : handle

//=========================================================================
// sub addErrNode(aElem : handle; aCode : int; opt aDesc : alpha) : handle
//     Fügt einen Fehlerknoten hinzu und gibt das Handle für weitere
//     Füllung zurück
//
//=========================================================================
sub addErrNode(aElem : handle; aCode : int; opt aDesc : alpha; opt aMsgPara : alpha) : handle
local begin
  vErrNode : handle;
  vErrCode : int;
  vNode : handle;
end;
begin
  vErrNode # aElem->getNode('ERRORS');
  if (vErrNode <> 0) AND (aCode <> 0) then begin

    vNode # vErrNode->Lib_XML:AppendNode('ERROR');
    vNode->Lib_XML:AppendNode('CODE',CnvAi(aCode,_FmtInternal));
    if (aMsgPara = '') then
      vNode->Lib_XML:AppendNode('TEXT',errMsg(aCode));
    else
      vNode->Lib_XML:AppendNode('TEXT',ParseErrMsg(Lib_Messages:Fehlertext(aCode), aMsgPara)); //errMsgPara(aCode,aMsgPara));

    if (aDesc <> '') then
      vNode->Lib_XML:AppendNode('DESC',aDesc);
  end;

  return vErrNode;
end; // sub addErrNode(aElem : handle; aCode : int; opt aDesc : alpha) : handle


//=========================================================================
// sub toUpper(aString : alpha(4096)) : alpha
//     Wandelt einen String in Großbuchstaben um
//
//=========================================================================
sub toUpper(aString : alpha(4096)) : alpha
begin
  return StrCnv(aString,_StrUpper);
end;


//=========================================================================
// sub sub isEmpty(aString : alpha(4096)) : logic
//     Prüft ob ein String leer ist
//
//=========================================================================
sub isEmpty(aString : alpha(4096)) : logic
begin
  if (StrAdj(aString,_StrAll) = '') then
    return true
  else
    return false;
end; // sub isEmpty(aString : alpha(4096)) : logic

//=========================================================================
// sub getScVersion() : float
//     Liest die aktuelle Stahl Control Version aus und gibt diese zurück
//
//=========================================================================
sub getScVersion() : float
local begin
  vTxtHdl       : int;
  vErg          : int;
  vVersionCur   : alpha;
end;
begin
  vTxtHdl # TextOpen(16);
  if (TextRead(vTxtHdl, '!VERSION',0) <= _rLocked) then begin
    vVersionCur # TextLineRead(vTxtHdl,1,0);
  end;
  return CnvFA(vVersionCur);
end; // sub getScVersion() : float


//=========================================================================
// sub sub strCnvXMLOut (aString : alpha) : alpha
//     Convertiert einen String in "xmlfähige" Ausgabe
//      ACHTUNG SEHR LAHM
//=========================================================================
sub strCnvXMLOut (aString : alpha) : alpha
local begin
  vTmp  : alpha(4096);
  vTmp2 : alpha(4096);
end;
begin
  vTmp # StrCnv(aString,_StrUmlaut);
  vTmp # Str_ReplaceAll(vTmp,'$','');
  vTmp # Str_ReplaceAll(vTmp,'%','');
  return vTmp;
end; // sub strCnvXMLOut (aString : alpha) : alpha







//========================================================================
//  sub DebugNode(aNode : handle)
//    gibt den Inhalt und Typ eines XML Nodes zurück
//========================================================================
sub getNodeType(aNode : handle) : alpha
begin
  case (aNode->spID) of
    _XmlNodeElement   : return '_XmlNodeElement';
    _XmlNodeText      : return '_XmlNodeText';
    _XmlNodeDocument  : return '_XmlNodeDocument';
    _XmlNodeAttribute : return '_XmlNodeAttribute';
    _XmlNodeComment   : return '_XmlNodeComment';
    otherwise           return 'other';
  end;

end; // sub getNodeType(aNode : handle) : alpha



//========================================================================
//  sub debugAPIChecks(vChecks : handle)
//    gibt alle Apiprüfvprgaben zum debuggen aus
//========================================================================
sub debugAPIChecks(vChecks : handle)
local begin
  vNode, vTmp : handle;
end
begin
// Debug
  FOR  vNode # vChecks->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # vChecks->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin
    dbg('-------------------');
    dbg(vNode->spName);
    dbg(vNode->spCustom);

    FOR  vtmp # vNode->CteRead(_CteFirst | _CteChildList)
    LOOP vtmp # vNode->CteRead(_CteNext  | _CteChildList, vtmp)
    WHILE (vtmp > 0) do begin
      dbg('    ' + vtmp->spName);
      dbg('    ' + vtmp->spCustom);
      dbg('---');
    END;

  END;
end; // sub debugAPIChecks(vChecks : handle)



//========================================================================
//  sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(300) ) : handle
//    Fügt einem Node einen unterknoten mit übergenenem Namen und Text an
//========================================================================
sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(300) ) : handle
begin
  return Lib_XML:AppendNode(aParent, StrCnv(aName,_StrUmlaut), aText);
end; // sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(300) ) : handle



//========================================================================
//  sub addRecord(aParent : handle; aFile : int) : handle
//    Eröffnet einen Node für eine Stahl Control datei, inkl. RecID
//========================================================================
sub addRecord(aParent : handle; aFile : int) : handle
local begin
  vRetNode : handle;
end;
begin
  vRetNode # aParent->AppendNode(FileName(aFile));
  vRetNode->Lib_XML:AppendAttributeNode('Recid',CnvAI(RecInfo(aFile,_RecID),_FmtInternal ));
  return vRetNode;
end; // sub addRecord(aParent : handle; aFile : int) : handle




//========================================================================
//  sub CreatePartSel(  aFile : int;  aKey  : int;  aProc : alpha;  aArgs : int;) : int
//    Erstellt eine Teilweise Selektion für Paginierung
//========================================================================
sub CreatePartSel(
  aFile : int;
  aKey  : int;
  aProc : alpha;
  aArgs : int;
) : int
local begin
  vHdl  : int;
end;
begin
  vHdl # VarAllocate(SOAPartSel);
  SOA_PartSel_File  # aFile;
  SOA_PartSel_Key   # aKey;
  SOA_PartSel_Proc  # aProc;

  SOA_PartSel_Sel # SelCreate(aFile, aKey);
  SOA_PartSel_SelName # Lib_Sel:Save(SOA_PartSel_Sel,'PART');   // speichern mit temp. Namen
  SOA_PartSel_Sel # SelOpen();                       // Selektion öffnen
  SOA_PartSel_Sel->selRead(aFile,_SelLock,SOA_PartSel_SelName); // Selektion laden

  SOA_PartSel_Buf # RecBufCreate(aFile);
  SOA_PartSel_Args  # aArgs;

  RETURN VarInfo(SOAPartSel);
end; // sub CreatePartSel(  aFile : int;  aKey  : int;  aProc : alpha;  aArgs : int;) : int



//========================================================================
//  sub ClosePartSel(aPartSel : int);
//    Terminiert eine Partitielle Selektion
//
//========================================================================
sub ClosePartSel(aPartSel : int);
begin
  VarInstance(SOAPartSel, aPartSel);

  SelClose(SOA_PartSel_Sel);
  SelDelete(SOA_PartSel_File,SOA_PartSel_selName);

  RecBufDestroy(SOA_partSel_Buf);
  VarFree(SOAPartSel);
end; // sub ClosePartSel(aPartSel : int);



//========================================================================
//  Sub RunPartSel(  aPartSel  : int;  aMax      : int;  opt aRecId : int;) : int;
//    Führt eine Partitielle Selektion aus und füllt diese mit Datensätzen
//
//========================================================================
Sub RunPartSel(
  aPartSel  : int;
  aMax      : int;
  opt aRecId : int;
) : int;
local begin
  vCount    : int;
  vOK       : logic;
  vFlag     : int;
  vErg      : int;
end;
begin

  // Struktur für Paginierung holen
  VarInstance(SOAPartSel, aPartSel);

  if (aRecId=0) then
    // Wenn keine RecId angegeben, dann den ersten Satz lesen
    vErg # RecRead(SOA_PartSel_File, SOA_PartSel_Key, _recFirst);
  else begin

    // !!! RecId angegeben, dann diesen Satz lesen
    vErg # RecRead(SOA_PartSel_File,0, _RecId, aRecId);

    // Danach den nächsten DS lesen, damit der Datensatz
    // mit der übergebenen RecId nicht erneut übergeben wird
    vErg # RecRead(SOA_PartSel_File, SOA_PartSel_Key, _recNext);
  end;

  // Sollten Keine Daten mehr gelesen worden sein, dann
  // nicht weiterlesen
  if (vErg>_rMultikey) then begin
    RecBufClear(SOA_PartSel_Buf);
    RETURN 0;
  end;


  // Sollte keine Anzahl von Datensätzen übergeben werden,
  // dann die maximalen DS setzen
  if (aMax = 0) then
    aMax # 2147483647; // Maximalwert für 32bit Integer laut C16 Doku


  // Gewünschte Datei durchlaufen
  vFlag # _recNext;
  WHILE (vErg<=_rMultikey) and (aMax>0) do begin
    vOK # Call(SOA_PartSel_Proc);
    if (vOK) then begin
      Dec(aMax);
      inc(vCount);
      vErg # SelRecInsert(SOA_PartSel_Sel, SOA_PartSel_File);
    end;
    if (aMax>0) then
      vErg # RecRead(SOA_PartSel_File, SOA_PartSel_Key, vFlag);

  END;

  RecbufCopy(SOA_partSel_File, SOA_PartSel_Buf);

  RETURN vCount;
end; // Sub RunPartSel(  aPartSel  : int;  aMax      : int;  opt aRecId : int;) : int;



//========================================================================
// sub ReadNummer(  aName         : alpha;) : int
//  Liest eine Vorgangsnummer
//  [+] 07.07.22 MR Änderung nach Deadlockfix
//========================================================================o
sub ReadNummer(
  aName         : alpha;
  var aNr       : int;
) : int
local begin
  Erx     : int;
  vCount  : int;
end;
begin
  aNr # 0;
  vCount # 0;
  REPEAT
    vCount # vCount + 1;
    Erx # Lib_Nummern:ReadNummerOnce(aName,var aNr);
    if (aNr=0) then break;
  UNTIL (aNr<>0) or (vCount=10);

  RETURN Erx;
end; // sub ReadNummer(  aName         : alpha;) : int


//========================================================================
// sub SaveNummer() : int
//  Speichert die gelesene Vorgangsnummer und erhöht diese im Bestand
//========================================================================
sub SaveNummer() : int
begin
  RecRead(902,1,_RecLock);
  Inc(Prg.Nr.Nummer);
  RETURN RekReplace(902,_RecUnlock,'AUTO');
end; // sub SaveNummer() : int



//=========================================================================
// sub SelFloat(
//            aFld : float;
//            aJN  : logic;
//            aNot : alpha;
//            aAus : alpha;
//            aVon : float;
//            aBis : float) : logic
//
//  Prüft einen Fließkommawert auf die Selektionsbedingungen.
//  Gibt TRUE zurück, wenn der Datensatz NICHT zur Bedingung passt.
//
//=========================================================================
sub SelFloat(
  aFld : float;
  aJN : logic;
  aNot : alpha;
  aAus : alpha;
  aVon : float;
  aBis : float) : logic
local begin
  Tmp  : alpha
end
begin
  if (aJN) then begin
    if (aAus <> '') then begin
      // OR als | Verkettung
      Tmp # '|'+CnvAF(aFld,_FmtNumPoint)+'|';
      if (StrFind(aAus,tmp,0) = 0) then
        return true;
    end else
    if (aNot <> '') then begin
      // NICHT OR als | Verkettung
      Tmp # '|'+CnvAF(aFld,_FmtNumPoint)+'|';
      if (StrFind(aNot,tmp,0) <> 0) then
        return true;
    end else
      if (aFld < aVon) OR (aFld > aBis) then // Wertebereich
        return true ;
  end;
  return false;
end;

//=========================================================================
// sub SelInt(
//            aFld : int;
//            aJN : logic;
//            aNot : alpha;
//            aAus : alpha;
//            aVon : int;
//            aBis : int) : logic
//
//  Prüft einen Integerwert auf die Selektionsbedingungen.
//  Gibt TRUE zurück, wenn der Datensatz NICHT zur Bedingung passt.
//
//=========================================================================
sub SelInt(
  aFld : int;
  aJN  : logic;
  aNot : alpha;
  aAus : alpha;
  aVon : int;
  aBis : int) : logic
local begin
  Tmp  : alpha
end
begin
  if (aJN) then begin
    if (aAus <> '') then begin
      // OR als | Verkettung
      Tmp # '|'+CnvAI(aFld,_FmtNumNoGroup | _FmtNumNoZero)+'|';
      if (StrFind(aAus,tmp,0) = 0) then
        return true;
    end else
    if (aNot <> '') then begin
      // NICHT OR als | Verkettung
      Tmp # '|'+CnvAI(aFld,_FmtNumNoGroup | _FmtNumNoZero)+'|';
      if (StrFind(aNot,tmp,0) <> 0) then
        return true;
    end else
      if (aFld < aVon) OR (aFld > aBis) then // Wertebereich
        return true ;
  end;
  return false;
end;


//=========================================================================
// sub SelAlpha(
//            aFld : alpha;
//            aJN : logic;
//            aNot : alpha;
//            aAus : alpha;
//            aVon : alpha;
//            aBis : alpha) : logic
//
//  Prüft einen Alphawert auf die Selektionsbedingungen.
//  Gibt TRUE zurück, wenn der Datensatz NICHT zur Bedingung passt.
//
//=========================================================================
sub SelAlpha(
  aFld : alpha;
  aJN  : logic;
  aNot : alpha;
  aAus : alpha;
  aVon : alpha;
  aBis : alpha) : logic
local begin
  Tmp  : alpha
end
begin
  if (aJN) then begin
    if (aAus <> '') then begin
      // OR als | Verkettung
      Tmp # '|'+StrCnv(aFld,_StrAll)+'|';
      if (StrFind(aAus,tmp,0) = 0) then
        return true;
    end else
    if (aNot <> '') then begin
      // NICHT OR als | Verkettung
      Tmp # '|'+StrCnv(aFld,_StrAll)+'|';
      if (StrFind(aNot,tmp,0) <> 0) then
        return true;
    end else
      if (aFld < aVon) OR (aFld > aBis) then // Wertebereich
        return true ;
  end;
  return false;
end;

//=========================================================================
// sub SelDate(
//            aFld : date;
//            aJN : logic;
//            aNot : alpha;
//            aAus : alpha;
//            aVon : date;
//            aBis : date) : logic
//
//  Prüft einen Datumswert auf die Selektionsbedingungen.
//  Gibt TRUE zurück, wenn der Datensatz NICHT zur Bedingung passt.
//
//=========================================================================
sub SelDate(
  aFld : date;
  aJN  : logic;
  aNot : alpha;
  aAus : alpha;
  aVon : date;
  aBis : date) : logic
local begin
  Tmp  : alpha
end
begin
  if (aJN) then begin
    if (aAus <> '') then begin
      // OR als | Verkettung
      Tmp # '|'+StrCnv(CnvAD(aFld),_StrAll)+'|';
      if (StrFind(aAus,tmp,0) = 0) then
        return true;
    end else
    if (aNot <> '') then begin
      // NICHT OR als | Verkettung
      Tmp # '|'+StrCnv(CnvAD(aFld),_StrAll)+'|';
      if (StrFind(aNot,tmp,0) <> 0) then
        return true;
    end else
      if (aFld < aVon) OR (aFld > aBis) then // Wertebereich
        return true ;
  end;
  return false;
end;

//=========================================================================
// sub prepSelFloat(
//                    aArgs       : int;
//                    aFldName    : alpha;
//                    var aJN     : logic;
//                    var aFld    : float;
//                    var aFldNot : alpha;
//                    var aFldVon : float;
//                    var aFldBis : float;
//                    var aFldAus : alpha)
//
//  Bereitet einen Wertebereich für die Selektion vor
//
//=========================================================================
sub prepSelFloat(
  aArgs       : int;
  aFldName    : alpha;
  var aJN     : logic;
  var aFld    : float;
  var aFldNot : alpha;
  var aFldVon : float;
  var aFldBis : float;
  var aFldAus : alpha)
begin
  aFld    # CnvFA(aArgs->getValue('sel_'+aFldName)     ,_FmtNumPoint);
  aFldVon # CnvFA(aArgs->getValue('sel_von_'+aFldName) ,_FmtNumPoint);
  aFldNot #       aArgs->getValue('sel_not_'+aFldName);
  aFldBis # CnvFA(aArgs->getValue('sel_bis_'+aFldName) ,_FmtNumPoint);
  aFldAus #       aArgs->getValue('sel_aus_'+aFldName);
  aJN     # false;

  if (aFld <> 0.0) then begin    // Genau ein Wert
    aFldVon  # aFld;
    aFldBis  # aFld;
    aFldAus  # '';
    aFld     # 0.0;
  end else
  if (aFldNot <> '') then begin // Keinen Wert aus vorgegebener Menge
    aFldVon  # 0.0;
    aFldBis  # 0.0;
    aFld     # 0.0;
    aFldAus  # '';
    aFldNot  # '|'+ aFldNot + '|';  // abschließendes Pipe hinzufügen
    aFldNot  # Str_ReplaceAll(aFldNot,' ',''); // Leerzeichen entfernen
    aFldNot  # Str_ReplaceAll(aFldNot,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldAus <> '') then begin  // Wert aus einer vorgegbenen Menge
    aFldVon  # 0.0;
    aFldBis  # 0.0;
    aFld     # 0.0;
    aFldNot  # '';
    aFldAus  # '|'+aFldAus + '|';   // abschließendes Pipe hinzufügen
    aFldAus  # Str_ReplaceAll(aFldAus,' ',''); // Leerzeichen entfernen
    aFldAus  # Str_ReplaceAll(aFldAus,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldVon <> 0.0) and        // Minimalwert
      (aFldBis = 0.0) then begin
    aFld     # 0.0;
    aFldBis  # 99999999.99;
    aFldAus  # '';
  end else begin                      // Maximalwert und Wertebereich
    aFld     # 0.0;
    aFldAus  # '';
  end;
  if (aFldVon <> 0.0) OR (aFldBis <> 0.0) OR (aFldAus <> '') OR (aFldNot <> '') then
    aJN  # true;

end;


//=========================================================================
// sub prepSelInt(
//                    aArgs       : int;
//                    aFldName    : alpha;
//                    var aJN     : logic;
//                    var aFld    : int;
//                    var aFldNot : alpha;
//                    var aFldVon : int;
//                    var aFldBis : int;
//                    var aFldAus : alpha)
//
//  Bereitet einen Wertebereich für die Selektion vor
//
//=========================================================================
sub prepSelInt(
  aArgs       : int;
  aFldName    : alpha;
  var aJN     : logic;
  var aFld    : int;
  var aFldNot : alpha;
  var aFldVon : int;
  var aFldBis : int;
  var aFldAus : alpha)
begin
  aFld    # CnvIA(aArgs->getValue('sel_'+aFldName)     ,_FmtNumNoZero | _FmtNumNoGroup);
  aFldVon # CnvIA(aArgs->getValue('sel_von_'+aFldName) ,_FmtNumNoZero | _FmtNumNoGroup);
  aFldNot #       aArgs->getValue('sel_not_'+aFldName);
  aFldBis # CnvIA(aArgs->getValue('sel_bis_'+aFldName) ,_FmtNumNoZero | _FmtNumNoGroup);
  aFldAus #       aArgs->getValue('sel_aus_'+aFldName);
  aJN     # false;

  if (aFld <> 0) then begin    // Genau ein Wert
    aFldVon  # aFld;
    aFldBis  # aFld;
    aFldAus  # '';
    aFld     # 0;
  end else
  if (aFldNot <> '') then begin // Keinen Wert aus vorgegebener Menge
    aFldVon  # 0;
    aFldBis  # 0;
    aFld     # 0;
    aFldAus  # '';
    aFldNot  # '|'+aFldNot + '|';  // abschließendes Pipe hinzufügen
    aFldNot  # Str_ReplaceAll(aFldNot,' ',''); // Leerzeichen entfernen
    aFldNot  # Str_ReplaceAll(aFldNot,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldAus <> '') then begin  // Wert aus einer vorgegbenen Menge
    aFldVon  # 0;
    aFldBis  # 0;
    aFld     # 0;
    aFldNot  # '';
    aFldAus  # '|'+aFldAus + '|';   // abschließendes Pipe hinzufügen
    aFldAus  # Str_ReplaceAll(aFldAus,' ',''); // Leerzeichen entfernen
    aFldAus  # Str_ReplaceAll(aFldAus,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldVon <> 0) and        // Minimalwert
      (aFldBis = 0) then begin
    aFld     # 0;
    aFldBis  # 999999;
    aFldAus  # '';
  end else begin                      // Maximalwert und Wertebereich
    aFld     # 0;
    aFldAus  # '';
  end;
  if (aFldVon <> 0) OR (aFldBis <> 0) OR (aFldAus <> '') OR (aFldNot <> '') then
    aJN  # true;

end;

//=========================================================================
// sub prepSelAlpha(
//                    aArgs       : int;
//                    aFldName    : alpha;
//                    var aJN     : logic;
//                    var aFld    : alpha;
//                    var aFldNot : alpha;
//                    var aFldVon : alpha;
//                    var aFldBis : alpha;
//                    var aFldAus : alpha)
//
//  Bereitet einen Wertebereich für die Selektion vor
//
//=========================================================================
sub prepSelAlpha(
  aArgs       : int;
  aFldName    : alpha;
  var aJN     : logic;
  var aFld    : alpha;
  var aFldNot : alpha;
  var aFldVon : alpha;
  var aFldBis : alpha;
  var aFldAus : alpha)
begin
  aFld    # aArgs->getValue('sel_'+aFldName);
  aFldVon # aArgs->getValue('sel_von_'+aFldName);
  aFldNot # aArgs->getValue('sel_not_'+aFldName);
  aFldBis # aArgs->getValue('sel_bis_'+aFldName);
  aFldAus # aArgs->getValue('sel_aus_'+aFldName);
  aJN     # false;

  if (aFld <> '') then begin    // Genau ein Wert
    aFldVon  # aFld;
    aFldBis  # aFld;
    aFldAus  # '';
    aFld     # '';
  end else
  if (aFldNot <> '') then begin // Keinen Wert aus vorgegebener Menge
    aFldVon  # '';
    aFldBis  # '';
    aFld     # '';
    aFldAus  # '';
    aFldNot  # '|'+aFldNot + '|';  // abschließendes Pipe hinzufügen
    aFldNot  # Str_ReplaceAll(aFldNot,' ',''); // Leerzeichen entfernen
    aFldNot  # Str_ReplaceAll(aFldNot,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldAus <> '') then begin  // Wert aus einer vorgegbenen Menge
    aFldVon  # '';
    aFldBis  # '';
    aFld     # '';
    aFldNot  # '';
    aFldAus  # '|'+aFldAus + '|';   // abschließendes Pipe hinzufügen
    aFldAus  # Str_ReplaceAll(aFldAus,' ',''); // Leerzeichen entfernen
    aFldAus  # Str_ReplaceAll(aFldAus,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldVon <> '') and        // Minimalwert
      (aFldBis = '') then begin
    aFld     # '';
    aFldBis  # 'ZZZZZZZZZZZZZZZZZZZZZZZZZZ';
    aFldAus  # '';
  end else begin                      // Maximalwert und Wertebereich
    aFld     # '';
    aFldAus  # '';
  end;
  if (aFldVon <> '') OR (aFldBis <> '') OR (aFldAus <> '') OR (aFldNot <> '') then
    aJN  # true;

end;


//=========================================================================
// sub prepSelDate(
//                      aArgs       : int;
//                      aFldName    : alpha;
//                      var aJN     : logic;
//                      var aFld    : date;
//                      var aFldNot : alpha;
//                      var aFldVon : date;
//                      var aFldBis : date;
//                      var aFldAus : alpha)
//
//  Bereitet einen Wertebereich für die Selektion vor
//
//=========================================================================
sub prepSelDate(
  aArgs       : int;
  aFldName    : alpha;
  var aJN     : logic;
  var aFld    : date;
  var aFldNot : alpha;
  var aFldVon : date;
  var aFldBis : date;
  var aFldAus : alpha)
begin
  aFld    # CnvDA(aArgs->getValue('sel_'+aFldName));
  aFldVon # CnvDA(aArgs->getValue('sel_von_'+aFldName));
  aFldNot # aArgs->getValue('sel_not_'+aFldName);
  aFldBis # CnvDA(aArgs->getValue('sel_bis_'+aFldName));
  aFldAus # aArgs->getValue('sel_aus_'+aFldName);
  aJN     # false;

  if (aFld <> 0.0.0) then begin    // Genau ein Wert
    aFldVon  # aFld;
    aFldBis  # aFld;
    aFldAus  # '';
    aFldNot  # '';
    aFld     # 0.0.0;
  end else
  if (aFldNot <> '') then begin // Keinen Wert aus vorgegebener Menge
    aFldVon  # 0.0.0;
    aFldBis  # 0.0.0;
    aFld     # 0.0.0;
    aFldAus  # '';
    aFldNot  # '|'+aFldNot + '|';  // abschließendes Pipe hinzufügen
    aFldNot  # Str_ReplaceAll(aFldNot,' ',''); // Leerzeichen entfernen
    aFldNot  # Str_ReplaceAll(aFldNot,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldAus <> '') then begin  // Wert aus einer vorgegbenen Menge
    aFldVon  # 0.0.0;;
    aFldBis  # 0.0.0;;
    aFld     # 0.0.0;;
    aFldNot  # '';
    aFldAus  # '|'+aFldAus + '|';   // abschließendes Pipe hinzufügen
    aFldAus  # Str_ReplaceAll(aFldAus,' ',''); // Leerzeichen entfernen
    aFldAus  # Str_ReplaceAll(aFldAus,'||','|'); // ggf. Doppelpipes entfernen
  end else
  if (aFldVon <> 0.0.0) and        // Minimalwert
      (aFldBis = 0.0.0) then begin
    aFld     # 0.0.0;
    aFldBis  # 31.12.2100;
    aFldAus  # '';
  end else begin                      // Maximalwert und Wertebereich
    aFld     # 0.0.0;
    aFldAus  # '';
  end;
  if (aFldVon <> 0.0.0) OR (aFldBis <> 0.0.0) OR (aFldAus <> '') OR (aFldNot <> '') then
    aJN  # true;

end;


//========================================================================
// sub Init() : alpha
//  Allokiert alle Globalen Datenbereiche, die für Verbuchungen etc.
//  benötigt werden
//========================================================================
sub Init() : alpha
begin

  // ALLE EVENTS ERLAUBEN:
// 2023-08-03 AH   darf nicht bei 64bit  WinEvtProcessSet(_WinEvtAll,true);

  // Uhrzeit vom Server holen
  DbaControl(_DbaTimeSync);

  VarAllocate(VarSysPublic);   // public Variable allokieren
  gCodepage # _Sys->spCodepageOS;

  // Initialisieren
  if (Liz_Data:InitSoa()=false) then RETURN 'LICENSE ERROR';

  VarAllocate(WindowBonus);
  gUserGroup # 'SOA_SERVER';    // Globale Daten Vorbelegen
  gUserName  # UserInfo(_Username); //'SOA_SYNC';      // Vorlegung Standarduser, kann vom Request umgeschrieben werden
  
  Lib_SFX:InitAFX();            // AFX initialisieren
  
  RETURN Lib_ODBC:Init();       // ODBC initalizieren
end; // sub Init


//========================================================================
// sub Terminate()
//  Schließt alle Verbindungen und Bereinigt den Speicher
//========================================================================
sub Terminate()
begin

  // AFX beenden
  Lib_SFX:TermAFX();

  // vom Organigramm abmelden
  Org_Data:Killme();

  // ODBC beenden
  Lib_ODBC:Term();

  // Debugger beenden
  Lib_Debug:TermDebug();

  varfree(WindowBonus);
  varfree(VarSysPublic);
  VarFree(VarSys);
end; //sub Terminate()


//========================================================================
// sub Allocate()
//  Allokiert alle Globalen Datenbereiche, die für Verbuchungen etc.
//  benötigt werden
//========================================================================
sub Allocate()
begin
  Init();
end; // sub Allocate()



//========================================================================
//  Msg
//      Gibt eine Meldung aus
//      Sonderzeichen
//      '%x%': X=1,2,3,4,5 = Platzhalter für Token
//      '%CR$': Carriage Return
//
//========================================================================
sub ParseErrMsg(
  aMsg  : alpha(1000);
  aPara : alpha(1000);
) : alpha
local begin
  vA,vB   : alpha(1000);
  vText   : alpha(300);
  vX      : int;
  vA1     : alpha(1000);
  vA2     : alpha(1000);
  vA3     : alpha(1000);
  vA4     : alpha(1000);
  vA5     : alpha(1000);
end;
begin

  vA # aMsg;

  // Symbol ermitteln
  if (StrCut(vA,2,1)=':') then begin
    vA # StrCut(vA,3,999);
  end;

  vA1 # Str_Token(aPara,'|',1);
  vA2 # Str_Token(aPara,'|',2);
  vA3 # Str_Token(aPara,'|',3);
  vA4 # Str_Token(aPara,'|',4);
  vA5 # Str_Token(aPara,'|',5);

  vX # strfind(vA,'%1%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA1+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%2%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA2+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%3%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA3+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%4%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA4+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%5%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA5+StrCut(vA,vX+3,999);

  // alle _CR_zu CR umwanden
  REPEAT
    vX # strfind(vA,'%CR%',0);
    if vX<>0 then
      vA # StrCut(vA,1,vX-1)+StrChar(13)+StrCut(vA,vX+4,999);
  UNTIL (vX=0);

  vA # Lib_Strings:Strings_ReplaceAll(vA,'#','');


  RETURN vA;

end;


//========================================================================
//  sub BuildErrorResponse(var aErrNode : handle)
//    Setztt die Fehlerliste in einen Node um
//========================================================================
sub BuildErrorResponse(var aErrNode : handle)
local begin
  vItem : int;
end;
begin
  if (ErrList=0) then
    RETURN;

  FOR vItem # ErrList->CteRead(_CteFirst)
  LOOP vItem # ErrList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    aErrNode->addErrNode(vItem->spID,vItem->spName, vItem->spCustom);
  END;

  Lib_Error:_Flush();
end;



//=========================================================================
//=========================================================================
