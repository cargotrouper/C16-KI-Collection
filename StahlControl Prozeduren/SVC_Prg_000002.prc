@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_Prg_000002
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
//    sub treeAdd(aTree : handle; vDatei : int; aType : alpha)
//    sub keyfile_Api() : handle
//    sub keyfile_Exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API


//=========================================================================
// sub keyfile_Api() : handle
//
//  Definiert die API Beschreibung (Servicevertrag) für den implementierten
//  Service.
//
//  @Return
//    handle                      // Handle auf die XML Struktur
//
//=========================================================================
sub keyfile_Api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin

  // Standardapi erstellen
  vApi # apiCreateStd();

  // Speziele Api-Definition ab hier

  // Dateinummer
  vNode # vApi->apiAdd('Datei',_TypeInt,true,810,856);
  vNode->apiSetDesc('Dateinummer der Schlüsseldatei; Verfügbare Schlüsseldateien '+
                    'sind über den Service KEYINFO abzufragen','844');

  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub keyinfo_Api() : handle



//=========================================================================
// sub keyfile_Exec(aArgs : handle; var aResponse : handle) : int
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
sub keyfile_Exec(aArgs : handle; var aResponse : handle) : int
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
  if (vDatei = 827) or (vDatei = 831) or (vDatei = 837) or
    ((vDatei >= 843) AND (vDatei <= 845)) then begin

    aResponse->addErrNode(errSVC_argGeneral,'Die angegebene Datei kann nicht gefunden werden');
    return errPrevent;
  end;

  // Alles IO, dann Daten zusammenstellen
  vNode # aResponse->getNode('DATA');

  // Daten an Response anhängen

  vFlag # _RecFirst;
  WHILE (RecRead(vDatei,1,vFlag) <= _rLocked) DO BEGIN

    // Datensatz mit eindeutiger SatzID eröffnen
    vRec # vNode->Lib_SOA:AppendNode(FileName(vDatei)); // oder Record
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
          _TypeByte     : vFldData # AInt(FldInt(vDatei,vTds,vFld)  );
          _TypeDate     : vFldData # CnvAd(FldDate(vDatei,vTds,vFld)  );
          _TypeDecimal  : vFldData # CnvAM(FldDecimal(vDatei,vTds,vFld),_FmtNumPoint);
          _TypeFloat    : vFldData # CnvAf(FldFloat(vDatei,vTds,vFld),_FmtNumPoint);
          _TypeInt      : vFldData # AInt(Fldint(vDatei,vTds,vFld)  );
          _TypeLogic    : vFldData # CnvAi(CnvIl(FldLogic(vDatei,vTds,vFld))  );
          _TypeTime     : vFldData # CnvAT(FldTime(vDatei,vTds,vFld)  );
          _TypeWord     : vFldData # AInt(FldWord(vDatei,vTds,vFld)  );
        END;

        // Datensatz ist gelesen
        vFldName # (FldName(vDatei,vTds,vFld));
        vRec->Lib_SOA:AppendNode(vFldName,vFldData);

      END;

    END;

    vFlag # _RecNext;
  END;

  return _rOk;
end; // sub keyfile_Exec(aArgs : handle; var aResponse : handle) : int




//=========================================================================
//=========================================================================
//=========================================================================