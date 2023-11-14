@A+
//==== Business-Control ===================================================
//
//  Prozedur    SVC_000048
//  Service     IPAD_FILE
//                  OHNE E_R_G
//  Info
//        Liefert eine Binärdatei über den HTTP-Service für die mobile
//        Anwendung zurück.
//
//  30.05.2012  PW  Erstellung
//
//  Subprozeduren
//    sub api() : handle
//    sub exec ( aArgs : handle; var aResponse : handle ) : int
//    sub execMemory ( aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
//=========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

//=========================================================================
// api
//        Definiert die API-Beschreibung für den implementierten Service.
//=========================================================================
sub api() : handle
local begin
  vApi  : handle;
  vNode : handle;
end;
begin
  vApi  # apiCreateStd();

  // Parameter: name
  vNode # vApi->apiAdd('name', _typeAlpha, true);
  vNode->apiSetDesc('Interner Name der Datei', 'example');

  // Parameter: type
  vNode # vApi->apiAdd('type', _typeAlpha, false);
  vNode->apiSetDesc('Dateityp', 'pdf');

  RETURN vApi;
end;


//=========================================================================
// exec
//        Führt den Service aus.
//        Gibt den MemoryExec Fehlercode zurück, um die Ausführung der
//        `execMemory`-Prozedur zu bewirken.
//=========================================================================
sub exec ( aArgs : handle; var aResponse : handle ) : int
begin
  RETURN errSVL_ExecMemory;
end;


//=========================================================================
// execMemory
//        Führt den Service mit einer direkten Binärausgabe aus.
//        Bla.
//=========================================================================
sub execMemory ( aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
local begin
  vSender   : alpha;
  vFileName : alpha;
  vFileType : alpha;
  vFilePath : alpha;
  vFileHdl  : handle;
end
begin
  Lib_Soa:Allocate();
  vSender   # Str_ReplaceAll(aArgs->getValue('SENDER'), '/', '_');
  vSender   # Lib_Strings:Strings_ReplaceEachToken(vSender, '<>:"/\|?*^');
  vFileName # Lib_Strings:Strings_ReplaceEachToken(aArgs->getValue('name'), '<>:"/\|?*^');
  vFileType # Lib_Strings:Strings_ReplaceEachToken(StrCnv(aArgs->getValue('type'), _strLower), '<>:"/\|?*^');
  vFilePath # Set.Soa.Path + 'ipad\' + vSender + '-' + vFileName;

  case (vFileType) of
    'pdf'    : begin
      vFilePath    # vFilePath + '.pdf';
      aContentType # 'application/pdf';
    end;
    'report' : begin
      vFilePath    # vFilePath + '.xml';
      aContentType # 'text/xml';
    end;
    'png' : begin
      vFilePath    # vFilePath + '.png';
      aContentType # 'image/png';
    end;
    otherwise
      aContentType # 'text/plain';
  end;

  vFileHdl # FsiOpen(vFilePath, _fsiAcsR);
  if (vFileHdl < 0) then begin
    aMem->MemWriteStr(1, 'Requested file was not found or is not accessible.');
    RETURN 404;
  end;

  vFileHdl->FsiReadMem(aMem, 1, vFileHdl->FsiSize());
  vFileHdl->FsiClose();
  RETURN 200;
end;

//=========================================================================
//=========================================================================