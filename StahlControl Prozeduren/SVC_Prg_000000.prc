@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_Prg_000000
//                  OHNE E_R_G
//  Info
//    Stellt die Services für und Implementierungen bereit
//
//
//  14.09.2010  ST  Erstellung der Prozedur
//  27.09.2010  ST  Service: "keyinfo" mit Sortierung, Keyfile und File
//                  implmenentiert
//  01.10.2010  ST  Umstrukturierung
//
//  Subprozeduren
//    sub file_Api() : handle
//    sub file_Exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API


//=========================================================================
// sub file_Api() : handle
//
//  Definiert die API Beschreibung (Servicevertrag) für den implementierten
//  Service.
//
//  @Return
//    handle                      // Handle auf die XML Struktur
//
//=========================================================================
sub api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin

  // Standardapi erstellen
  vApi # apiCreateStd();

  // Speziele Api-Definition ab hier

  // Dateinummer
  vNode # vApi->apiAdd('Datei',_TypeInt,true,100,999);
  vNode->apiSetDesc('Dateinummer','844');

  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub file_Api() : handle



//=========================================================================
// sub file_Exec(....) : int
//
//  Führt den Service aus:
//    Gibt für die übergebene Datei Nummer alle Daten zurück
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//=========================================================================
sub exec(aArgs : handle; var aResponse : handle) : int
local begin
  vNode : handle;
  vRec : handle;

  vDatei : int;
  vFlag  : int;
  vTds    : int;
  vTdsCnt : int;
  vFld    : int;
  vFldCnt : int;
  vFldData   : alpha(4096);

  vFldName : alpha;

end
begin

  // Prüfen ob die Datei gewünschte Daten ausgegeben werden darf
  vDatei # CnvIA(GetValue(aArgs,'DATEI'),_FmtInternal);

  // Alles IO, dann Daten zusammenstellen
  vNode # aResponse->getNode('DATA');

  // Daten an Response anhängen

  vFlag # _RecFirst;
  WHILE (RecRead(vDatei,1,vFlag) <= _rLocked) DO BEGIN

    // Datensatz mit eindeutiger SatzID eröffnen
    vRec # vNode->Lib_XML:AppendNode(FileName(vDatei));
    vRec->Lib_XML:AppendAttributeNode('Recid',CnvAI(RecInfo(vDatei,_RecID),_FmtInternal));

    // Teildatensätze durchgehen
    vTdsCnt # FileInfo(vDatei,_FileSbrCount);
    FOR  vTds # 1;
    LOOP vTds # vTds + 1;
    WHILE (vTds <= vTdsCnt) DO BEGIN

      // Felder durchgehen
      vFldCnt # SbrInfo(vDatei,vTds,_SbrFldCount);
      FOR  vFld # 1;
      LOOP vFld # vFld + 1;
      WHILE (vFld <= vFldCnt) DO BEGIN

        CASE (FldInfo(vDatei,vTds,vFld,_FldType)) OF
          _TypeAlpha    : vFldData # FldAlpha(vDatei,vTds,vFld);
          _TypeBigInt   : vFldData # CnvAb(FldBigint(vDatei,vTds,vFld)  );
          _TypeByte     : vFldData # CnvAi(FldInt(vDatei,vTds,vFld)  );
          _TypeDate     : vFldData # CnvAd(FldDate(vDatei,vTds,vFld)  );
          _TypeDecimal  : vFldData # CnvAM(FldDecimal(vDatei,vTds,vFld)  );
          _TypeFloat    : vFldData # CnvAf(FldFloat(vDatei,vTds,vFld)  );
          _TypeInt      : vFldData # CnvAi(Fldint(vDatei,vTds,vFld)  );
          _TypeLogic    : vFldData # CnvAi(CnvIl(FldLogic(vDatei,vTds,vFld))  );
          _TypeTime     : vFldData # CnvAT(FldTime(vDatei,vTds,vFld)  );
          _TypeWord     : vFldData # CnvAi(FldWord(vDatei,vTds,vFld)  );
        END;

        // Datensatz ist gelesen
        vFldName # (FldName(vDatei,vTds,vFld));
        vRec->Lib_XML:AppendNode(vFldName,vFldData);

      END;

    END;

    vFlag # _RecNext;
  END;

  return _rOk;
end; // sub file_Exec(aArgs : handle; var aResponse : handle) : int



//=========================================================================
//=========================================================================
//=========================================================================