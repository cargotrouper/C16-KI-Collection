@A+
//==== Business-Control ===================================================
//
//  Prozedur    Lib_Mobile
//                    OHNE E_R_G
//  Info
//        Prozeduren zur Aufbereitung von Daten für die mobile Anwendung
//        auf dem iPad bzw. iOS.
//        Eine Beispielimplementation eines Exports ist in der Subprozedur
//        JobserverMain angegeben.
//
//  06.06.2012  PW  Erstellung
//
//  Subprozeduren
//    sub ConvertAddress ( opt aAdrNr : int ) : handle
//    sub SaveAndAppendReport ( aContact : handle; aBasePath : alpha; aLfmNr : int )
//    sub SaveAndAppendPdf ( aContact : handle; aBasePath : alpha; aLfmNr : int )
//    sub JobserverMain ( aParameters : alpha ) : logic
//
//  Interne Subprozeduren
//    sub CreateContactXml () : handle
//    sub CreateContactAddressXml () : handle
//    sub CreateMainContactAddressXml () : handle
//    sub CreateContactPersonXml () : handle
//    sub CreateDocumentXml (aFile : alpha; aTitle : alpha; aType : alpha; opt aDate : date ) : handle
//    sub PrintListAsReport ( aReport : handle; aLfmNr : int )
//    sub PrintListAsPdf ( aPath : alpha(256); aLfmNr : int )
//=========================================================================
@I:Def_Global

//=========================================================================
// CreateContactXml
//        Konvertiere die aktuell geladene Adresse (einen Kontakt) in das
//        iOS-Format und gib den erstellten XML-Knoten zurück.
//   @return: Der erstellte XML-Knoten (`contact`).
//=========================================================================
sub CreateContactXml () : handle
local begin
  vContact : handle;
end
begin
  vContact # Lib_XML:CreateNode('contact');
  vContact->Lib_XML:AppendNode('contactNumber', AInt(Adr.Nummer));
  vContact->Lib_XML:AppendNode('keyword', Adr.Stichwort);

  if (Adr.KundenNr != 0) then
    vContact->Lib_XML:AppendNode('customerNumber', AInt(Adr.KundenNr));
  if (Adr.LieferantenNr != 0) then
    vContact->Lib_XML:AppendNode('supplierNumber', AInt(Adr.LieferantenNr));

  // Zusatzdaten
  if (Adr.Gruppe != '') then
    vContact->Lib_XML:AppendNode('contactGroup', Adr.Gruppe);

  if (Adr.Abc != '') then begin
    vContact->Lib_XML:AppendNode('abc', Adr.Abc);
    vContact->Lib_XML:AppendNode('ranking', AInt(Adr.Punktzahl));
  end;

  Ver.Nummer # Adr.Vertreter;
  if (Ver.Nummer != 0) and (RecRead(110, 1, 0) = _rOk) then
    vContact->Lib_XML:AppendNode('agent1', Ver.Stichwort);

  Ver.Nummer # Adr.Vertreter2;
  if (Ver.Nummer != 0) and (RecRead(110, 1, 0) = _rOk) then
    vContact->Lib_XML:AppendNode('agent2', Ver.Stichwort);

  Ver.Nummer # Adr.Verband;
  if (Ver.Nummer != 0) and (RecRead(110, 1, 0) = _rOk) then
    vContact->Lib_XML:AppendNode('association', Ver.Stichwort);

  if (Adr.VerbandRefNr != '') then
    vContact->Lib_XML:AppendNode('associationId', Adr.VerbandRefNr);

  if (Adr.Briefgruppe != '') then
    vContact->Lib_XML:AppendNode('mailgroup', Adr.Briefgruppe);

  if (Adr.Bemerkung != '') then
    vContact->Lib_XML:AppendNode('remark', Adr.Bemerkung);

  RETURN vContact;
end;


//=========================================================================
// CreateContactAddressXml
//        Konvertiere die aktuell geladene Adressanschrift in das
//        iOS-Format und gib den erstellten XML-Knoten zurück.
//   @return: Der erstellte XML-Knoten (`contactAddress`).
//=========================================================================
sub CreateContactAddressXml () : handle
local begin
  vContactAddress : handle;
  vAddress        : handle;
  vContactMethod  : handle;
end
begin
  vContactAddress # Lib_XML:CreateNode('contactAddress');
  vContactAddress->Lib_XML:AppendNode('keyword', Adr.A.Stichwort);

  vAddress # vContactAddress->Lib_XML:AppendNode('address');
  vAddress->Lib_XML:AppendNode('title', Adr.A.Anrede);
  vAddress->Lib_XML:AppendNode('name', Adr.A.Name);
  if (Adr.A.Zusatz != '') then
    vAddress->Lib_XML:AppendNode('detail', Adr.A.Zusatz);
  vAddress->Lib_XML:AppendNode('street', "Adr.A.Straße");
  vAddress->Lib_XML:AppendNode('postalCode', Adr.A.PLZ);
  vAddress->Lib_XML:AppendNode('town', Adr.A.Ort);
  vAddress->Lib_XML:AppendNode('country', Adr.A.LKZ);

  // Kontaktdaten
  if (Adr.A.Telefon != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.A.Telefon);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'tel');
  end;
  if (Adr.A.Telefax != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.A.Telefax);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'fax');
  end;
  if (Adr.A.EMail != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.A.EMail);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'email');
  end;

  RETURN vContactAddress;
end;


//=========================================================================
// CreateMainContactAddressXml
//        Konvertiere die Hauptanschrift der aktuell geladenen Adresse in
//        das iOS-Format und gib den erstellten XML-Knoten zurück.
//   @return: Der erstellte XML-Knoten (`contactAddress`).
//=========================================================================
sub CreateMainContactAddressXml () : handle
local begin
  vContactAddress : handle;
  vAddress        : handle;
  vContactMethod  : handle;
end;
begin
  vContactAddress # Lib_XML:CreateNode('contactAddress');
  vContactAddress->Lib_XML:AppendNode('keyword', Adr.Stichwort);

  vAddress # vContactAddress->Lib_XML:AppendNode('address');
  vAddress->Lib_XML:AppendNode('title', Adr.Anrede);
  vAddress->Lib_XML:AppendNode('name', Adr.Name);
  if (Adr.A.Zusatz != '') then
    vAddress->Lib_XML:AppendNode('detail', Adr.Zusatz);
  vAddress->Lib_XML:AppendNode('street', "Adr.Straße");
  vAddress->Lib_XML:AppendNode('postalCode', Adr.PLZ);
  vAddress->Lib_XML:AppendNode('town', Adr.Ort);
  vAddress->Lib_XML:AppendNode('country', Adr.LKZ);

  if (Adr.Postfach.PLZ != '') then begin
    vAddress->Lib_XML:AppendNode('pobPostalCode', Adr.Postfach.PLZ);
    vAddress->Lib_XML:AppendNode('pobNumber', Adr.Postfach);
  end;

  // Kontaktdaten
  if (Adr.Telefon1 != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.Telefon1);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'tel');
  end;
  if (Adr.Telefon2 != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.Telefon2);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'tel');
    if (Adr.Telefon1 != '') then
      vContactMethod->Lib_XML:AppendAttributeNode('label', 'Alternativ');
  end;
  if (Adr.Telefax != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.Telefax);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'fax');
  end;
  if (Adr.EMail != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.EMail);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'email');
  end;
  if (Adr.Website != '') then begin
    vContactMethod # vContactAddress->Lib_XML:AppendNode('contactMethod',  Adr.Website);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'web');
  end;

  RETURN vContactAddress;
end;


//=========================================================================
// CreateContactPersonXml
//        Konvertiere den aktuell geladenen Ansprechpartner in das
//        iOS-Format und gib den erstellten XML-Knoten zurück.
//   @return: Der erstellte XML-Knoten (`contactPerson`).
//=========================================================================
sub CreateContactPersonXml () : handle
local begin
  vContactPerson : handle;
  vPrivate       : handle;
  vAddress       : handle;
  vContactMethod : handle;
end
begin
  vContactPerson # Lib_XML:CreateNode('contactPerson');
  vContactPerson->Lib_XML:AppendNode('keyword', Adr.P.Stichwort);

  if (Adr.P.Titel != '') then
    vContactPerson->Lib_XML:AppendNode('title', Adr.P.Titel);
  if (Adr.P.Vorname != '') then
    vContactPerson->Lib_XML:AppendNode('firstName', Adr.P.Vorname);
  vContactPerson->Lib_XML:AppendNode('lastName', Adr.P.Name);

  // Zusatzdaten
  if (Adr.P.Abteilung != '') then
    vContactPerson->Lib_XML:AppendNode('department', Adr.P.Abteilung);
  if (Adr.P.Funktion != '') then
    vContactPerson->Lib_XML:AppendNode('profession', Adr.P.Funktion);
  if (Adr.P.Vorgesetzter != '') then
    vContactPerson->Lib_XML:AppendNode('supervisor', Adr.P.Vorgesetzter);
  if (Adr.P.Briefanrede != '') then
    vContactPerson->Lib_XML:AppendNode('salutation', Adr.P.Briefanrede);
  if (Adr.P.Geburtsdatum != 0.0.0) then
    vContactPerson->Lib_XML:AppendNode('birthday',   CnvAd(Adr.P.Geburtsdatum));
  if (Adr.P.Familienstand != '') then
    vContactPerson->Lib_XML:AppendNode('familyStatus', Adr.P.Familienstand);

  // Kontaktdaten
  if (Adr.P.Telefon != '') then begin
    vContactMethod # vContactPerson->Lib_XML:AppendNode('contactMethod', Adr.P.Telefon);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'tel');
  end;
  if (Adr.P.Telefax != '') then begin
    vContactMethod # vContactPerson->Lib_XML:AppendNode('contactMethod', Adr.P.Telefax);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'fax');
  end;
  if (Adr.P.Mobil != '') then begin
    vContactMethod # vContactPerson->Lib_XML:AppendNode('contactMethod', Adr.P.Mobil);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'cell');
  end;
  if (Adr.P.EMail != '') then begin
    vContactMethod # vContactPerson->Lib_XML:AppendNode('contactMethod', Adr.P.Email);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'email');
  end;

  // Privatdaten
  vPrivate # Lib_XML:CreateNode('private');

  // Private Adresse
  if ("Adr.P.Priv.Straße" != '') and (Adr.P.Priv.Ort != '') then begin
    vAddress # vPrivate->Lib_XML:AppendNode('address');
    if (Adr.P.Vorname != '') then
      vAddress->Lib_XML:AppendNode('name', Adr.P.Vorname + ' ' + Adr.P.Name);
    else
      vAddress->Lib_XML:AppendNode('name', Adr.P.Name);

    vAddress->Lib_XML:AppendNode('street', "Adr.P.Priv.Straße");
    vAddress->Lib_XML:AppendNode('postalCode', Adr.P.Priv.PLZ);
    vAddress->Lib_XML:AppendNode('town', Adr.P.Priv.Ort);
    vAddress->Lib_XML:AppendNode('country', Adr.P.Priv.LKZ);
  end;

  // Private Kontaktdaten
  if (Adr.P.Priv.Telefon != '') then begin
    vContactMethod # vPrivate->Lib_XML:AppendNode('contactMethod', Adr.P.Priv.Telefon);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'tel');
  end;
  if (Adr.P.Priv.Mobil != '') then begin
    vContactMethod # vPrivate->Lib_XML:AppendNode('contactMethod', Adr.P.Priv.Mobil);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'cell');
  end;
  if (Adr.P.Priv.Telefax != '') then begin
    vContactMethod # vPrivate->Lib_XML:AppendNode('contactMethod', Adr.P.Priv.Telefax);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'fax');
  end;
  if (Adr.P.Priv.EMail != '') then begin
    vContactMethod # vPrivate->Lib_XML:AppendNode('contactMethod', Adr.P.Priv.Email);
    vContactMethod->Lib_XML:AppendAttributeNode('type', 'email');
  end;

  if (vPrivate->spChildCount > 0) then
    vContactPerson->Lib_XML:Append(vPrivate);

  RETURN vContactPerson;
end;


//=========================================================================
// CreateDocumentXml
//        Erstelle einen Knoten für ein angehängtes Dokument.
//   aTitle: Titel des Dokuments.
//   aType: Typ des Dokuments (`pdf`, `report`).
//   aDate: Datum der Erstellung, standardmäßig das aktuelle Datum.
//   @return: Der erstellte XML-Knoten (`document`).
//=========================================================================
sub CreateDocumentXml (
  aFile       : alpha;
  aTitle      : alpha;
  aType       : alpha;
  opt aDate   : date
) : handle
local begin
  vDocument : handle;
end
begin
  vDocument # Lib_XML:CreateNode('document');
  vDocument->Lib_XML:AppendAttributeNode('file', aFile);
  vDocument->Lib_XML:AppendAttributeNode('type', StrCnv(aType, _strLower));
  vDocument->Lib_XML:AppendTextNode(aTitle);

  if (aDate != 0.0.0) then
    vDocument->Lib_XML:AppendAttributeNode('date', CnvAD(aDate, _fmtDateLongYear));
  else
    vDocument->Lib_XML:AppendAttributeNode('date', CnvAD(today, _fmtDateLongYear));

  RETURN vDocument;
end;


//=========================================================================
// ConvertAddress
//        Konvertiere eine Adresse (einen Kontakt) vollständig in das
//        iOS-Format, inklusive Anschriften und Ansprechpartnern, und gib
//        den erstellten XML-Knoten zurück.
//   aAdrNr: Adressnummer der zu ladenden Adresse, oder `0` falls die
//        aktuell geladene Adresse genommen werden soll.
//   @return: Der erstellte XML-Knoten (`contact`).
//=========================================================================
sub ConvertAddress ( opt aAdrNr : int ) : handle
local begin
  vErg     : int;
  vContact : handle;
end
begin
  if (aAdrNr != 0) then begin
    RecBufClear(100);
    Adr.Nummer # aAdrNr;
    if (RecRead(100, 1, 0) > _rLocked) then
      RETURN null;
  end;

  vContact # CreateContactXml();
  if (vContact = 0) then
    RETURN null;

  // Hauptanschrift
  RecLink(101, 100, 12, _recFirst);
  vContact->Lib_XML:Append(CreateMainContactAddressXml());

  // Anschriften
  FOR  vErg # RecLink(101, 100, 12, _recNext);
  LOOP vErg # RecLink(101, 100, 12, _recNext);
  WHILE (vErg <= _rLocked) DO BEGIN
    vContact->Lib_XML:Append(CreateContactAddressXml());
  END;

  // Ansprechpartner
  FOR  vErg # RecLink(102, 100, 13, _recFirst);
  LOOP vErg # RecLink(102, 100, 13, _recNext);
  WHILE (vErg <= _rLocked) DO BEGIN
    vContact->Lib_XML:Append(CreateContactPersonXml());
  END;

  RETURN vContact;
end;


//=========================================================================
// PrintListAsReport
//        Drucke das angebene Listenformat als XML Report und hänge das
//        Ergebnis im übergebenen Knoten an.
//   aReport: Übergeordneter Knoten.
//   aLfmNr: Nummer des zu druckenden Listenformats.
//=========================================================================
sub PrintListAsReport ( aReport : handle; aLfmNr : int )
begin
  // Listenformat laden
  RecBufCleaR(910);
  Lfm.Nummer # aLfmNr;
  if (RecRead(910, 1, 0) > _rLocked) then
    RETURN;

  // Datenbereich zurücksetzen
  if (VarInfo(Class_List) != 0) then
    VarFree(Class_List);
  VarAllocate(Class_List);

  // Listendruck
  Lfm.Ausgabeart # 'X';
  list_XML       # true;
  list_FileName  # null;
  list_FileHdl   # aReport;
  list_MDI       # gMDI;
  Call(Lfm.Prozedur);
end;


//=========================================================================
// PrintListAsPdf
//        Drucke das angebene Listenformat und speichere es als PDF.
//   aPath: Dateipfad an dem das Dokument erstellt werden soll.
//   aLfmNr: Nummer des zu druckenden Listenformats.
//=========================================================================
sub PrintListAsPdf ( aPath : alpha(256); aLfmNr : int )
begin
  // Listenformat laden
  RecBufCleaR(910);
  Lfm.Nummer # aLfmNr;
  if (RecRead(910, 1, 0) > _rLocked) then
    RETURN;

  // Datenbereich zurücksetzen
  if (VarInfo(Class_List) != 0) then
    VarFree(Class_List);
  VarAllocate(Class_List);

  // Listendruck
  Lfm.Ausgabeart # '';
  list_PdfPath   # aPath;
  list_MDI       # gMDI;
  Call(Lfm.Prozedur + ':AutoGenerate');
end;


//=========================================================================
// SaveAndAppendReport
//        Drucke das angebene Listenformat als XML Report, speichere es als
//        Datei, und hänge einen Dokument-Knoten an den übergebenen
//        Kontakt-Knoten an.
//   aContact: Kontakt-Knoten (`contact`).
//   aBasePath: Basispfad, unter dem der Report gespeichert werden soll.
//   aLfmNr: Nummer des zu druckenden Listenformats.
//   @remarks: Das Dokument wird als `<Basispfad>-r<Id>.xml` angelegt.
//=========================================================================
sub SaveAndAppendReport ( aContact : handle; aBasePath : alpha; aLfmNr : int )
local begin
  vIdentifier : alpha;
  vReport     : handle;
end
begin
  vIdentifier # CnvAF(Rnd(1000.0 * Random() * CnvFI(aLfmNr)));

  vReport # CteOpen(_cteNode);
  vReport->spId # _xmlNodeDocument;
  PrintListAsReport(vReport, aLfmNr);
  vReport->XmlSave(aBasePath + '-r' + vIdentifier + '.xml', _xmlSaveDefault, 0, _charsetUtf8);
  aContact->Lib_XML:Append(CreateDocumentXml('r' + vIdentifier, Lfm.Name, 'report'));
end;


//=========================================================================
// SaveAndAppendPdf
//        Drucke das angebene Listenformat, speichere es als PDF-Datei, und
//        hänge einen Dokument-Knoten an den übergebenen Kontakt-Knoten an.
//   aContact: Kontakt-Knoten (`contact`).
//   aBasePath: Basispfad, unter dem der Report gespeichert werden soll.
//   aLfmNr: Nummer des zu druckenden Listenformats.
//   aFormNrAndName: Nummer und Name eines Formulares, getrennt mit '/'
//   @remarks: Das Dokument wird als `<Basispfad>-l<Id>.pdf` angelegt.
//=========================================================================
sub SaveAndAppendPdf (
    aContact : handle;
    aBasePath : alpha;
    aLfmNr : int;
    opt aFormName : alpha;
    opt aIdentifier : alpha)
local begin
  vIdentifier : alpha;
  vDate     : date;
  vTime     : time;
end
begin

  // Liste oder Formular?
  if (aLfmNr <> 0) AND (aFormName = '') then begin
    // PDF wird aus Liste erstellt
    vIdentifier # CnvAF(Rnd(1000.0 * Random() * CnvFI(aLfmNr)), _fmtInternal);
    PrintListAsPdf(aBasePath + '-l' + vIdentifier + '.pdf', aLfmNr);
    aContact->Lib_XML:Append(CreateDocumentXml('l' + vIdentifier, Lfm.Name, 'pdf'));
  end else
  if (aLfmNr <> 0) AND (aFormName <> '') then begin
    // PDF aus Formular
    vIdentifier # CnvAd(today,_FmtInternal) + CnvAt(now,_FmtInternal);
    vIdentifier # Str_ReplaceAll(vIdentifier,':','');
    vIdentifier # Str_ReplaceAll(vIdentifier,'.','');
    Lib_Dokumente:Printform(aLfmNr, aFormName, false, aBasepath + '-f' + vIdentifier + '.pdf');
    if (aIdentifier <> '') then
      aFormname # aFormname + ' ' + aIdentifier;
    aContact->Lib_XML:Append(CreateDocumentXml('f' + vIdentifier, aFormName, 'pdf'));
  end;

end;


//=========================================================================
// JobserverMain
//        Beispielimplementation des Exports für die mobile Verwendung.
//        Exportiere für jeden Vertreter eine Liste von verknüpften
//        Adressen, mit all deren Kontaktdaten und der Liste 400001.
//=========================================================================
sub JobserverMain ( aParameters : alpha ) : logic
local begin
  vXmlDocument  : handle;
  vContacts     : handle;
  vContact      : handle;
  vBasePath     : alpha;
  vBuf100       : int;
  vBuf110       : int;
  vErg          : int;

  vErgPrj       : int;
  vErgPrjP      : int;
end
begin
  Set.SOA.Path # Str_ReplaceAll(Set.SOA.Path, 'D:\C16\C16\', 'Z:\C16\');

  vBasePath # Set.SOA.Path + 'ipad\';
  FsiPathCreate(vBasePath);
  Lib_FileIO:EmptyDir(vBasePath);

  // Vertreter
  FOR  vErg # RecRead(110, 1, _recFirst);
  LOOP vErg # RecRead(110, 1, _recNext);
  WHILE (vErg <= _rLocked) DO BEGIN

    vBuf110   # RekSave(110);
    vBasePath # Set.SOA.Path + 'ipad\V' + AInt(Ver.Nummer);

    // XML-Dokument anlegen
    vXmlDocument # CteOpen(_cteNode);
    vXmlDocument->spId # _xmlNodeDocument;
    vContacts # vXmlDocument->Lib_XML:AppendNode('contacts');
    vContacts->Lib_XML:AppendAttributeNode('xmlns', 'http://stahl-control.de/xml/ios');

    // Eigene Adresse hinzufügen
    vContact # vContacts->Lib_XML:Append(ConvertAddress(Set.EigeneAdressNr));
    vContact->SaveAndAppendPdf(vBasePath, 200001);
    vBuf110->RecBufCopy(110);


    // Adressen
    FOR  vErg # RecLink(100, 110, 4, _recFirst);
    LOOP vErg # RecLink(100, 110, 4, _recNext);
    WHILE (vErg <= _rLocked ) DO BEGIN
      vBuf100  # RekSave(100);
      vContact # vContacts->Lib_XML:Append(ConvertAddress());

      // bsp. Listenausgabe
      vContact->SaveAndAppendPdf(vBasePath, 400001);
      vBuf100->RecBufCopy(100);
      vBuf110->RecBufCopy(110);

      // bsp. Formularausgabe:
      //      Alle nicht gelöschten Projekte
      Prj.Adressstichwort # vBuf100->Adr.Stichwort;
      Prj.Nummer  # 0;
      FOR   vErgPrj # RecRead(120,4,0);
      LOOP  vErgPrj # RecRead(120,4,_RecNext);
      WHILE (vErgPrj < _rNoRec) AND (Prj.Adressnummer = vBuf100->Adr.Nummer) DO BEGIN

        if ("Prj.Löschmarker" = '') then begin

          // Projektpunkt auf offene Positionen prüfen
          FOR   vErgPrjP # RecLink(122,120,4,_RecFirst);
          LOOP  vErgPrjP # RecLink(122,120,4,_RecNext);
          WHILE (vErgPrjP <= _rLocked) DO BEGIN

            if ("Prj.P.Lösch.User" = '') then begin
              vContact->SaveAndAppendPdf(vBasePath, 100, 'iPad Offene Kundenprojekte');
              break; // Projektblatt druckt alle Positionen
            end;
          END;

        end; // Projekt ist nicht gelöscht


      END; // Projekte
      vBuf100->RecBufCopy(100);
      vBuf110->RecBufCopy(110);


    END; // Adressen

    // XML-Dokument speichern
    vXmlDocument->XmlSave(vBasePath + '.xml', _xmlSaveDefault, 0, _charsetUtf8);
  END;

  RETURN true;
end;


//=========================================================================
//  Testläufe
//=========================================================================
main
begin
  JobserverMain ('');
end;

//=========================================================================
//=========================================================================
//=========================================================================

