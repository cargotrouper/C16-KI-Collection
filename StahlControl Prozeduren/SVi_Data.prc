@A+
//===== Business-Control =================================================
//
//  Prozedur  SVi_Data
//                OHNE E_R_G
//  Info
//    Enthält Funktionen, die auf die auf die Daten von Services zurückgreift
//
//  01.10.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub ApiExport()
//    sub ApiExportCsv(aApi : handle; aFilename : alpha(4096))
//    sub writeApiCSVrek(aParent : handle; aRec : int; aFile : handle)
//    sub csvOut(aFile : handle; aRec : int)
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Lib_SOA

global rec begin
  rKey        : alpha;
  rTyp        : alpha;
  rPflicht    : alpha;
  rWertVon    : alpha;
  rWertBis    : alpha;
  rWertAus    : alpha;
  rStd        : alpha;
  rBeispiel   : alpha;
  rBesch      : alpha(4096);
  rIntern     : alpha;
end;



//========================================================================
//  sub csvOut(aFile : handle; aRec : int)
//
//========================================================================
sub csvOut(aFile : handle; aRec : int)
begin
  VarInstance(rec, aRec);
  if (!isEmpty(rKey+rTyp+rPflicht+rWertVon+rWertBis+rWertAus+rStd+rBeispiel+rBesch)) then begin
    aFile->FsiWrite( '"' +StrCnv(rKey,_StrToANSI)      + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rTyp,_StrToANSI)      + '"' + StrChar(59));
    aFile->FsiWrite( ''  +StrCnv(rPflicht,_StrToANSI)  + ''  + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rWertVon,_StrToANSI)  + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rWertBis,_StrToANSI)  + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rWertAus,_StrToANSI)  + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rStd,_StrToANSI)      + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rBeispiel,_StrToANSI) + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rBesch,_StrToANSI)    + '"' + StrChar(59));
    aFile->FsiWrite( '"' +StrCnv(rIntern,_StrToANSI)    + '"' + StrChar(59));
    aFile->FsiWrite( StrChar( 13 ) + StrChar( 10 ) );
  end;

  rKey        # '';
  rTyp        # '';
  rPflicht    # '';
  rWertVon    # '';
  rWertBis    # '';
  rWertAus    # '';
  rStd        # '';
  rBeispiel   # '';
  rBesch      # '';
  rIntern     # '';
end;



//========================================================================
//  sub writeApiCSVrek(aParent : handle; aRec : int; aFile : handle)
//
//========================================================================
sub writeApiCSVrek(aParent : handle; aRec : int; aFile : handle)
local begin
  vNode   : handle;   // Iterationshandle
  vCheck  : handle;   // Handle auf "Check" Knoten
  vKey    : handle;   // Knotenpunkt der Checks für diesen Schlüssel
  vAttrib : handle;   // Attributiterationshandle
  vItem   : handle;   // Checklisteneintrag
end;
begin

  VarInstance(rec, aRec);

   // alle Checkregeln in Api suchen
  FOR  vNode # aParent->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aParent->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    if (vNode->spID  = _XmlNodeElement) then begin

      if (toUpper(vNode->spName) <> 'CHECK')  AND
         (toUpper(vNode->spName) <> 'INFO')   AND
         (toUpper(vNode->spName) <> 'SCAPI')  AND
         (toUpper(vNode->spName) <> 'INTERN') then
      rKey # StrCnv(vNode->spName, _StrFromUTF8);

      // Hat Checkregel?
      vCheck # vNode->getNode('CHECK');
      if (vCheck <> 0) then begin
        // Feld als Knoten einbauen
        vKey # CteOpen(_CteNode);
        vKey->spName # vNode->spName;

        // Hat Checkregel, dann Attribute durchgehen
        FOR  vAttrib # vCheck->CteRead(_CteFirst | _CteAttribList)
        LOOP vAttrib # vCheck->CteRead(_CteNext  | _CteAttribList,vAttrib)
        WHILE (vAttrib > 0) do begin

          // Regeln zusammenstellen
          case (toUpper(vAttrib->spName)) of
              'DATENTYP'      : rTyp      # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
              'PFLICHT'       : rPflicht  # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
              'WERTAUS'       : rWertAus  # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
              'WERTVON'       : rWertVon  # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
              'WERTBIS'       : rWertBis  # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
              'STANDARDWERT'  : rStd      # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
          end;

        END;

      end;

      // Hat Infobereich?
      vCheck # vNode->getNode('INFO');
      if (vCheck <> 0) then begin
        // Feld als Knoten einbauen
        vKey # CteOpen(_CteNode);
        vKey->spName # vNode->spName;

        // Hat Checkregel, dann Attribute durchgehen
        FOR  vAttrib # vCheck->CteRead(_CteFirst | _CteAttribList)
        LOOP vAttrib # vCheck->CteRead(_CteNext  | _CteAttribList,vAttrib)
        WHILE (vAttrib > 0) do begin

          // Regeln zusammenstellen
          case (toUpper(vAttrib->spName)) of
              'BESCHREIBUNG' : rBesch      # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
              'BEISPIEL'     : rBeispiel   # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
          end;

        END;
      end;

      // Hat Infobereich?
      vCheck # vNode->getNode('INTERN');
      if (vCheck <> 0) then begin
        // Feld als Knoten einbauen
        vKey # CteOpen(_CteNode);
        vKey->spName # vNode->spName;

        // Hat Checkregel, dann Attribute durchgehen
        FOR  vAttrib # vCheck->CteRead(_CteFirst | _CteAttribList)
        LOOP vAttrib # vCheck->CteRead(_CteNext  | _CteAttribList,vAttrib)
        WHILE (vAttrib > 0) do begin

          // Regeln zusammenstellen
          case (toUpper(vAttrib->spName)) of
              'SCFLD' : rIntern     # StrCnv(vAttrib->spValueAlpha, _StrFromUTF8);
          end;

        END;
      end;

      // hat Kinder?
      if (vNode->spChildCount > 0) then
        writeApiCSVrek(vNode, aRec, aFile);

    end; // if (vNode->spID  = _XmlNodeElement)

    aFile->csvOut(aRec);


  END;

end; // sub writeApiCSVrek(aParent : handle; aRec : int; aFile : handle)


//========================================================================
//  sub ApiExportCsv(aApi : handle; aFilename : alpha(4096))
//
//========================================================================
sub ApiExportCsv(aApi : handle; aFilename : alpha(4096))
local begin
  vNode : handle;
  vFile : handle;
  vRec : handle;
end;
begin

  // Datei öffenen
  vFile # FsiOpen(aFilename, _FsiStdWrite | _FsiCreate);
  if (vFile < 0) then begin
    Msg( 000099, 'Datei nicht beschreibbar.', _winIcoError, _winDialogOk, _winIdOk );
    RETURN;
  end;

  // Struktur für Datensatz allokieren
  vRec # VarAllocate(rec);

  // Erste Zeile schreiben: Überschriften
  rKey        # 'Argument';
  rTyp        # 'Datentyp';
  rPflicht    # 'Pflichtfeld';
  rWertVon    # 'WertVon';
  rWertBis    # 'WertBis';
  rWertAus    # 'WertAuswahl';
  rStd        # 'Standardwert'
  rBeispiel   # 'Beispielwert';
  rBesch      # 'Beschreibung';
  rIntern     # 'SC Feldname';
  vFile->csvOut(vRec);

  writeApiCSVrek(aApi, vRec, vFile);

  // Datei schließen
  vFile->FsiClose();
  VarFree(rec);
end; // sub ApiExportCsv(aApi : handle; aFilename : alpha(4096))

//========================================================================
//  sub ApiExport()
//
//========================================================================
sub ApiExport()
local begin
  vFilename : alpha(4096);
  vFilter : alpha;
  vSaveTyp : alpha;

  vApi    : handle;
end;
begin


  vFilter # 'XML Datei (*.xml)|*.xml|CSV Datei (*.csv)|*.csv';
  vFilename # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', vFilter);
  if (vFilename<>'') then begin

    // Dateityp extrahieren
    vSaveTyp # StrCut(vFilename,StrLen(vFilename)-2,9999);

    // Api lesen
    vApi # Call(SOA.Inv.Prozedur + ':api');

    // Datei Schreiben
    if (StrCnv(vSaveTyp,_StrUpper) = 'CSV') then
      ApiExportCsv(vApi,vFilename);
    else
      // API als XML File Speichern
      XmlSave(vApi,vFilename,_XmlSaveDefault);
  end;

end; // sub ApiExport()


//========================================================================
