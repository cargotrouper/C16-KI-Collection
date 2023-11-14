//                    OHNE E_R_G
// logic debug
sub dbgL ( dbgFile : handle; x : logic )
begin
  if ( x ) then
    dbgFile->FsiWrite( 'True' );
  else
    dbgFile->FsiWrite( 'False' );
  dbgFile->FsiWrite( StrChar( 13 ) + StrChar( 10 ) );
end;

// XML test
MAIN
local begin
  vDbg  : handle;
  vDoc  : handle;
  vRoot : handle;
  vNode : handle;
end
begin
  vDbg # FsiOpen( 'c:\debug\debug.txt', _fsiStdWrite );
  if ( vDbg <= 0 ) then
    RETURN;

  /*************/
  /* Schreiben */
  /*************/
  vDoc # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;
  vRoot # vDoc->CteInsertNode( 'root', _xmlNodeElement, null );

  // 'äöüß' mit C16-interner Kodierung
  vRoot->CteInsertNode( null, _xmlNodeText, 'äöüß' );

  // testweise wieder lesen
  vNode # vRoot->CteRead( _cteChildList | _cteFirst )
  dbgL( vDbg, 'äöüß' = vNode->spValueAlpha ) // True

  // XML Datei mit UTF8 Kodierung speichern
  vDoc->XmlSave( 'C:\debug\beispiel.xml', _xmlSaveDefault, 0, _charsetUTF8 );

  vDoc->CteClear( true );
  vDoc->CteClose();

  /*************/
  /* Lesen     */
  /*************/
  vDoc # CteOpen( _cteNode );

  // XML Datei lesen, dabei keine Information über dessen UTF8 Kodierung.
  // Der XML-Header (<?xml encoding="utf-8"?>) wird auch nicht berücksichtigt.
  vDoc->XmlLoad( 'C:\debug\beispiel.xml' );

  vRoot # vDoc->CteRead( _cteChildList | _cteFirst );
  vNode # vRoot->CteRead( _cteChildList | _cteFirst );

  // Text testen
  dbgL( vDbg, 'äöüß' = vNode->spValueAlpha ); // False
  dbgL( vDbg, 'äöüß' = StrCnv( vNode->spValueAlpha, _strFromUTF8 ) ); // True

  vDoc->CteClear( true );
  vDoc->CteClose();

  vDbg->FsiClose();
end;