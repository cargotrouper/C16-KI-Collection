@A+
//==== Business-Control ===================================================
//
//  Prozedur    Lib_COM
//                      OHNE E_R_G
//  Info
//        Component Object Model Schnittstelle
//        MSDN Dokumentationen:
//          Excel 2007:   http://msdn.microsoft.com/en-us/library/bb149081.aspx
//          Outlook 2007: http://msdn.microsoft.com/en-us/library/bb208225.aspx
//          Word 2007:    http://msdn.microsoft.com/en-us/library/bb244515.aspx
//
//  31.08.2009  PW  Erstellung der Prozedur
//  17.10.2013  AH  Fixkosten werden addiert
//  23.10.2013  ST  Fixkostenaddierung pro Monat
//  11.03.2015  AH  Daten-Export an Excel
//  24.03.2015  ST  Bugfix Datenexport
//  30.03.2016  ST  "sub MailAttachments" erlaubt 2. Anhangsdatei
//  07.06.2016  AH  Directory auf %temp%
//  27.06.2017  ST  Bugfix: ExcelExport / Worksheettitle max 30 Zeichen
//  23.02.2021  AH  "ExportAdr" kann mit ID und Marked
//  2022-10-27  AH  Onlinestatistik optional mit Gewicht
//
//  Subprozeduren
//    sub debugCOM ( opt aText : alpha )
//    sub ExcelX(aI : int) : alpha;
//    sub ChooseCalendar () : alpha
//    sub ExportTeM ()
//    sub ExportAdr ( aDatei : int )
//    sub ExportOSt
//    sub ExportOStMitMenge
//    sub DisplayOStGraph ( aName : alpha; aJahr : int; aBem : alpha, opt aFxK : logic )
//    sub DisplayOSt ( aName : alpha; aJahr : int; aBem : alpha, opt aFxK : logic )
//    sub CreateLetterToAdr ( aDatei : int )
//    SUB MailAttachement(aReceiver   : alpha; aSubject    : alpha; aFilename   : alpha(2000), aFilename2  : alpha(2000)) : logic;
//
//    sub demo ()
//
//    SUB ExportRecList(aTitle : alpha; aList : int; aFile : int; aKey : int; aProc : alpha) : logic;
//
//=========================================================================
//@I:Def_Global
@I:Def_COM_Outlook

declare ExportOStMitMenge(aName : alpha; aJahr : int; aBem : alpha; opt aFxK : logic );

//=========================================================================
// debugCOM
//        Prints out debug messages with COM Error information
//=========================================================================
sub debugCOM ( opt aText : alpha )
local begin
  vNone : handle;
end;
begin
  if ( aText != '' ) then
    aText # aText + cT
  debug( aText + vNone->ComInfo( _comInfoErrCode ) + cT + vNone->ComInfo( _comInfoErrText ) )
end;


//=========================================================================
//  ExcelX
//=========================================================================
sub ExcelX(aI : int) : alpha;
local begin
  vCharOffSet : int;
end;
begin
  vCharOffSet # 64;

  if (aI<1) then RETURN '';
  if (aI<=26) then RETURN StrChar(aI+vCharOffSet);
  RETURN Strchar((aI div 26)+vCharOffSet ) + Strchar((aI % 26)+vCharOffSet +1);
end;


//=========================================================================
// ChooseCalendar
//        Kalender Folder in Outlook auswählen
//=========================================================================
sub ChooseCalendar (
  var aStoreID1 : alpha;
  var aStoreID2 : alpha) : alpha
local begin
  vAppHdl : handle;
  vNsHdl  : handle;
  vFdHdl  : handle;
  vResult : int;
  vA      : alpha(2500);
end
begin
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Outlook.Application NOT found!',0,0,0);
    RETURN '';
  end;

  vNsHdl  # vAppHdl->ComCall( 'GetNamespace', 'MAPI' );
  vResult # Msg( 000099, 'Bitte wählen Sie im Outlook Dialog den zu verwendenden Kalender.', _winIcoInformation, _winDialogOkCancel, _winIdOk );

  WHILE ( vResult = _winIdOk ) DO BEGIN
    vFdHdl # vNsHdl->ComCall( 'PickFolder' );
//ClipboardWrite(vFdHdl->cpaEntryId);
    if ( vFdHdl != 0 ) and ( vFdHdl->cpiDefaultItemType = olAppointmentItem ) then begin
//ClipboardWrite(vFdHdl->cpaStoreId);
      vA # vFdHdl->cpaStoreId;
      aStoreID1 # StrCut(vA, 1, 250);
      aStoreID2 # '';
      if (StrLen(vA)>250) then
        aStoreID2 # StrCut(vA, 251, 250);
      RETURN vFdHdl->cpaEntryId;
    end;
    vResult # Msg( 000099, 'Bitte wählen Sie einen Kalender!', _winIcoInformation, _winDialogOkCancel, _winIdOk );
  END;

  RETURN '';
end;


//=========================================================================
// ExportTeM
//        Termin (TeM) in Aufgaben oder Kalender exportieren (Outlook)
//=========================================================================
sub ExportTeM ()
local begin
  Erx     : int;
  vAppHdl : handle;
  vNsHdl  : handle;
  vFdHdl  : handle;
  vHdl    : handle;

  vDate   : caltime;
  vMsg    : alpha;
  vText   : alpha;
end
begin
  if ( !Usr.OutlookYN ) then
    RETURN;

  /** initialization **/
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Outlook.Application NOT found!',0,0,0);
    RETURN;
  end;

  // Aufgabe
  if ( (Lib_Termine:GetBasisTyp(TeM.Typ)= 'AFG' )) then begin
    vMsg # 'Aufgabe erfolgreich nach Outlook exportiert.';
    vHdl # vAppHdl->ComCall( 'CreateItem', olTaskItem);
    vHdl->cpaSubject # TeM.Bezeichnung;
    vHdl->cpaBody    # Tem.Bemerkung;

    // Enddatum
    vDate->vpDate    # TeM.Ende.Von.Datum;
    vDate->vpTime    # TeM.Ende.Von.Zeit;
    vHdl->cpcDueDate # vDate;

    // Status
    if ( TeM.Erledigt.Datum != 0.0.0 ) then begin
      vDate->vpDate          # TeM.Erledigt.Datum;
      vDate->vpTime          # TeM.Erledigt.Zeit;
      vHdl->cpcDateCompleted # vDate;
      vHdl->cpiStatus        # olTaskComplete;
    end
    else if ( TeM.Start.Von.Datum >= today ) then
      vHdl->cpiStatus        # olTaskInProgress;
    else
      vHdl->cpiStatus        # olTaskNotStarted;
    _ComPropSet( vHdl, 'UnRead', true )
  end
  // Aufgabe mit Kontaktinformation
  else if ( Lib_Termine:GetBasisTyp(TeM.Typ) = 'TEL' or Lib_Termine:GetBasisTyp(TeM.Typ) = 'BRF' or Lib_Termine:GetBasisTyp(TeM.Typ) = 'FAX' or
    Lib_Termine:GetBasisTyp(TeM.Typ) = 'EMA' or Lib_Termine:GetBasisTyp(TeM.Typ) = 'SMS') then begin
    vMsg # 'Aufgabe erfolgreich nach Outlook exportiert.';
    vHdl # vAppHdl->ComCall( 'CreateItem', olTaskItem );
    vHdl->cpaSubject # Lib_Termine:GetTypeName( TeM.Typ ) + ': ' + TeM.Bezeichnung;
    vHdl->cpaBody    # Tem.Bemerkung;

    // Kontaktdaten aus Anker
    FOR  Erx # RecLink( 981, 980, 1, _recFirst );
    LOOP Erx # RecLink( 981, 980, 1, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( TeM.A.Datei = 100 ) then begin // ADR, Adresse
        Adr.Nummer # TeM.A.ID1;
        if ( RecRead( 100, 1, 0 ) < _rLocked ) then begin
          case (Lib_Termine:GetBasisTyp(TeM.Typ)) of
            'TEL' : vText # 'Telefon: ' + Adr.Telefon1;
            'BRF' : vText # 'Adresse:' + cN + Adr.Name + cN + "Adr.Straße" + cN + Adr.PLZ + ' ' + Adr.Ort;
            'FAX' : vText # 'Telefax: ' + Adr.Telefax;
            'EMA' : vText # 'E-Mail Adresse: ' + Adr.eMail;
            'SMS' : vText # 'Telefon: ' + Adr.Telefon1;
          end;
          vText # 'Kunde: ' + Adr.Stichwort + cN + vText
        end;
      end
      else if ( TeM.A.Datei = 102 ) then begin // ANP, Ansprechpartner
        Adr.P.Adressnr # TeM.A.ID1;
        Adr.P.Nummer   # TeM.A.ID2;
        if ( RecRead( 102, 1, 0 ) < _rLocked ) then begin
          case (Lib_Termine:GetBasisTyp(TeM.Typ)) of
            'TEL' : vText # 'Telefon: ' + Adr.P.Telefon;
            'BRF' : vText # 'Adresse:' + cN + Adr.P.Name + cN + "Adr.P.Priv.Straße" + cN + Adr.P.Priv.PLZ + ' ' + Adr.P.Priv.Ort;
            'FAX' : vText # 'Telefax: ' + Adr.P.Telefax;
            'EMA' : vText # 'E-Mail Adresse: ' + Adr.P.eMail;
            'SMS' : vText # 'Mobiltelefon: ' + Adr.P.Mobil;
          end;
          vText # 'Ansprechpartner: ' + Adr.P.Stichwort + cN + vText
        end;
      end;

      if ( vText != '' ) then begin
        vHdl->cpaBody # vHdl->cpaBody + cN + cN + vText;
        BREAK;
      end;
    end;

    // Enddatum
    vDate->vpDate    # TeM.Ende.Von.Datum;
    vDate->vpTime    # TeM.Ende.Von.Zeit;
    vHdl->cpcDueDate # vDate;

    // Status
    if ( TeM.Erledigt.Datum != 0.0.0 ) then begin
      vDate->vpDate          # TeM.Erledigt.Datum;
      vDate->vpTime          # TeM.Erledigt.Zeit;
      vHdl->cpcDateCompleted # vDate;
      vHdl->cpiStatus        # olTaskComplete;
    end
    else if ( TeM.Start.Von.Datum >= today ) then
      vHdl->cpiStatus        # olTaskInProgress;
    else
      vHdl->cpiStatus        # olTaskNotStarted;
    _ComPropSet( vHdl, 'UnRead', true )
  end;
  // Termin
  else begin
    vMsg     # 'Termin erfolgreich nach Outlook exportiert.';
    if ( Usr.OutlookCalendar != '' ) then begin
      vNsHdl # vAppHdl->ComCall( 'GetNamespace', 'MAPI' );
      vFdHdl # vNsHdl->ComCall( 'GetFolderFromId', Usr.OutlookCalendar );
    end
    if ( vFdHdl != 0 ) then
      vHdl   # vFdHdl->cphItems->ComCall( 'Add' );
    else
      vHdl   # vAppHdl->ComCall( 'CreateItem', olAppointmentItem );

    vHdl->cpaSubject    # Lib_Termine:GetTypeName( TeM.Typ ) + ': ' + TeM.Bezeichnung;
    vHdl->cpaBody       # Tem.Bemerkung;
    vHdl->cpiBusyStatus # olBusy;

    // Start Datum
    vDate->vpDate       # TeM.Start.Von.Datum;
    vDate->vpTime       # TeM.Start.Von.Zeit;
    vHdl->cpcStart      # vDate;

    // End Datum
    if ( TeM.Erledigt.Datum != 0.0.0 ) then begin
      vDate->vpDate     # TeM.Erledigt.Datum;
      vDate->vpTime     # TeM.Erledigt.Zeit;
    end
    else begin
      vDate->vpDate     # TeM.Ende.Von.Datum;
      vDate->vpTime     # TeM.Ende.Von.Zeit;
    end;
    vHdl->cpcEnd        # vDate;
  end;

  /** termination **/
  vHdl->ComCall( 'Save' );
  vAppHdl->ComClose();

  Msg( 000099, vMsg, _winIcoInformation, _winDialogOk, _winIdOk );
end;


//=========================================================================
// _ExportAdrInner
//=========================================================================
sub _ExportAdrInner (
  aAppHdl : int;
  aDatei  : int) : alpha;
local begin
  vNsHdl  : handle;
  vFdHdl  : handle;
  vHdl    : handle;

  vDate   : caltime;
  vMsg    : alpha;
  vText   : alpha;
  vRecBuf : int;
  vNS     : int;
  vCO     : int;
  vFilter : alpha;
  vCOs    : int;
  vX1,vX2 : int;
  vID     : alpha;

  vMarked : int;
  vMFile  : int;
  vMID    : int;
end
begin
  if ( aDatei = 100 ) then begin
    vID # aint(Adr.Nummer);
  end
  else if ( aDatei = 102 ) then begin
    vID # aint(Adr.P.Adressnr)+'_'+aint(Adr.P.Nummer);
  end;
  
  // schon vorhanden???
  vNS # aAppHdl->ComCall('GetNamespace','MAPI');
  if (vNS<>0) then begin
//debugx('NS');
    vCo # vNS->ComCall('GetDefaultFolder',olFolderContacts);
    if (vCO<>0) then begin
//      vFilter # '[FirstName]=''Julia'''; // & sFirstName & "' and [LastName]='" & sLastName & "'"
      vFilter # '[CustomerID]='''+vID+'''';
//debugx(vFilter);
      vX1 # vCo->Comcall('Items');// Items.Restrict(sFilter)
      if (vX1<>0) then begin
//debugx('');
        vX2 # vX1->Comcall('Restrict',vFilter);
        if (vX2<>0) then begin
//debugx('');
          vX1 # vX2->Comcall('Count');
          if (vX1<>0) then begin
//debugx(aint(vX1));
            vHdl # vX2->ComCall('Item', 1);
            if (vHdl<>0) then begin
//debugx(vHdl->cpaFullname);
            end;
          end;
        end;
//    Debug.Print oFilterContacts.Count & " appointments found."
      end;
    end;
  end;

  // NEU?
  if (vHdl=0) then
    vHdl    # aAppHdl->ComCall( 'CreateItem', olContactItem );

  vHdl->cpaCustomerID                # vID;

  if ( aDatei = 100 ) then begin
    vHdl->cpaFileAs                    # Adr.Stichwort;
    vHdl->cpaFullName                  # Adr.Name;
    vHdl->cpaTitle                     # Adr.Anrede;
    vHdl->cpaCategories                # Adr.Gruppe;
    vHdl->cpaBody                      # Adr.Bemerkung;

    if ( RecLink( 812, 100, 10, _recFirst ) > _rLocked ) then // Land
      RecBufClear( 812 );
    vHdl->cpaBusinessAddressStreet     # "Adr.Straße";
    vHdl->cpaBusinessAddressPostalCode # Adr.PLZ;
    vHdl->cpaBusinessAddressCity       # Adr.Ort;
    vHdl->cpaBusinessAddressCountry    # Lnd.Name.L1;

    vHdl->cpaBusinessTelephoneNumber   # Adr.Telefon1;
    vHdl->cpaBusiness2TelephoneNumber  # Adr.Telefon2;
    vHdl->cpaBusinessFaxNumber         # Adr.Telefax;
    vHdl->cpaEmail1Address             # Adr.eMail;
    vHdl->cpaWebPage                   # Adr.Website;
  end
  else if ( aDatei = 102 ) then begin

    vHdl->cpaFileAs                    # Adr.P.Stichwort;
    vHdl->cpaTitle                     # Adr.P.Titel;
    vHdl->cpaFirstName                 # Adr.P.Vorname;
    vHdl->cpaLastName                  # Adr.P.Name;

    vHdl->cpaBusinessTelephoneNumber   # Adr.P.Telefon;
    vHdl->cpaMobileTelephoneNumber     # Adr.P.Mobil;
    vHdl->cpaBusinessFaxNumber         # Adr.P.Telefax;
    vHdl->cpaEmail1Address             # Adr.P.eMail;
    vHdl->cpaDepartment                # Adr.P.Abteilung;
    vHdl->cpaJobTitle                  # Adr.P.Funktion;
    vHdl->cpaManagerName               # Adr.P.Vorgesetzter;

    // Land
    "Lnd.Kürzel"                       # Adr.P.Priv.LKZ;
    if ( RecRead( 812, 1, 0 ) > _rLocked ) then
      RecBufClear( 812 );

    vHdl->cpaHomeAddressStreet         # "Adr.P.Priv.Straße"
    vHdl->cpaHomeAddressPostalCode     # Adr.P.Priv.PLZ
    vHdl->cpaHomeAddressCity           # Adr.P.Priv.Ort
    vHdl->cpaHomeAddressCountry        # Lnd.Name.L1;
    vHdl->cpaHomeTelephoneNumber       # Adr.P.Priv.Telefon;
    vHdl->cpaHome2TelephoneNumber      # Adr.P.Priv.Mobil;
    vHdl->cpaHomeFaxNumber             # Adr.P.Priv.Telefax;
    vHdl->cpaEmail2Address             # Adr.P.Priv.eMail;

    if ( Adr.P.Geburtsdatum != 0.0.0 ) then begin
      vDate->vpDate                      # Adr.P.Geburtsdatum;
      vHdl->cpcBirthday                  # vDate;
    end;
    if ( Adr.P.Hochzeitstag != 0.0.0 ) then begin
      vDate->vpDate                      # Adr.P.Hochzeitstag;
      vHdl->cpcAnniversary               # vDate;
    end;
    vHdl->cpaSpouse                    # Adr.P.Partner.Name;

    // Kinder
    vText # '';
    if ( Adr.P.Kind1.Name != '' ) then
      vText # vText + Adr.P.Kind1.Name + ', ';
    if ( Adr.P.Kind2.Name != '' ) then
      vText # vText + Adr.P.Kind2.Name + ', ';
    if ( Adr.P.Kind3.Name != '' ) then
      vText # vText + Adr.P.Kind3.Name + ', ';
    if ( Adr.P.Kind4.Name != '' ) then
      vText # vText + Adr.P.Kind4.Name + ', ';
    vHdl->cpaChildren                  # StrCut( vText, 1, StrLen( vText ) - 2 );

    // Business Adresse
    vRecBuf # RecBufCreate( 100 );
    if ( RecLink( vRecBuf, 102, 1, _recFirst ) > _rLocked ) then // Adresse
      RecBufClear( vRecBuf );
    if ( RecLink( 812, 100, 10, _recFirst ) > _rLocked ) then // Land
      RecBufClear( 812 );
    vHdl->cpaBusinessAddressStreet     # "Adr.Straße";
    vHdl->cpaBusinessAddressPostalCode # Adr.PLZ;
    vHdl->cpaBusinessAddressCity       # Adr.Ort;
    vHdl->cpaBusinessAddressCountry    # Lnd.Name.L1;
    vRecBuf->RecBufDestroy();
  end;

  // termination
  vHdl->ComCall( 'Save' );

  RETURN '';
end;


//=========================================================================
// ExportAdr
//        Adresse (Adr) in das lokale Adressbuch exportieren (Outlook)
//=========================================================================
sub ExportAdr (
  aDatei      : int;
  opt aHidden : logic;
  opt aMarked : logic) : alpha;
local begin
  Erx     : int;
  vAppHdl : handle;
  vErr    : alpha;
  vMarked : int;
  vMFile  : int;
  vMID    : int;
end
begin
  if ( !Usr.OutlookYN ) then
    RETURN 'User nicht berechtigt';

  // initialization
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    if (aHidden=false) then Msg(99,'Outlook.Application NOT found!',0,0,0);
    RETURN 'Outlook.Application NOT found!';
  end;

  if (aMarked) then begin
    // Markierung loopen
    FOR vMarked # gMarkList->CteRead(_CteFirst);
    LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
    WHILE (vMarked > 0) DO BEGIN

      Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
      if (vMFile <> aDatei) then CYCLE;
      Erx # RecRead(aDatei, 0, _recId, vMID);
      vErr # _ExportAdrInner(vAppHdl, aDatei);
    END;
  end
  else begin
    vErr # _ExportAdrInner(vAppHdl, aDatei);
  end;
  
//  if (aHidden) then begin
//    vAppHdl->ComClose();
//    RETURN;
//  end;;
//  vHdl->ComCall( 'Display' );
  vAppHdl->ComClose();
  if (aHidden=false) then Msg(99,'Kontakt an Outlook übertragen!',_winIcoInformation, _winDialogOk, _winIdOk );
  RETURN '';
  //Msg( 000099, vMsg, _winIcoInformation, _winDialogOk, _winIdOk );
end;


//=========================================================================
// ExportOStMitMenge
//        OnlineStatistik (OSt) tabellarisch anzeigen (Excel)
//=========================================================================
sub ExportOStMitMenge (
  aName     : alpha;
  aJahr     : int;
  aBem      : alpha;
  opt aFxK  : logic )
local begin
  vAppHdl   : handle;
  vWbkHdl   : handle;
  vWshHdl   : handle;
  vChtHdl   : handle;
  vHdl      : handle;
  vI,vJ     : int;
  vA        : alpha;
  Erx       : int;
  v558      : int;
  v558VJ    : int;
  vZeile    : int;
end
begin
  /** COM initialization **/
  vAppHdl # ComOpen( 'Excel.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Excel.Application NOT found!',0,0,0);
    RETURN;
  end;

  vAppHdl->cplVisible # true;
  vWbkHdl # vAppHdl->ComCall( 'Workbooks.Add' );

  FOR  vI # vWbkHdl->cphWorksheets->cpiCount;
  LOOP vI # vI - 1;
  WHILE ( vI > 1 ) DO BEGIN
    vHdl # vWbkHdl->cphWorksheets( vI )
    vHdl->ComCall( 'Delete' );
  END;

  /** Worksheet 1 : Daten **/
  vWshHdl # vWbkHdl->cphWorksheets(1);
  vWshHdl->cpaName # 'Daten';
//vI # vWshHdl->cphVBProject;
//debugx(aint(vI));
//  _ComPropGet(vWbkHdl,'VBProject',vHdl);
//debugx(aint(vHdl));
//  _ComPropGet(vWbkHdl,'VBProject.Name',vA);
//debugx(vA);

  /* Titel & Überschriften */
  vHdl # vWshHdl->cphRange( 'A1:P1' );
  vHdl->ComCall( 'Merge' );
  vHdl->cpaValue               # 'Onlinestatistik: ' + aBem
  vHdl->cpiHorizontalAlignment # xlCenter;
  vHdl                         # vHdl->cphFont;
  vHdl->cpiSize                # 14;
  vHdl->cplBold                # true;

  vHdl # vWshHdl->cphRange( 'B2:K2' )
  vHdl->ComCall( 'Merge' );
  vHdl->cpaValue               # 'Jahr ' + AInt( aJahr + 1900 );
  vHdl->cpiHorizontalAlignment # xlCenter;
  vHdl                         # vHdl->cphFont;
  vHdl->cpiSize                # 12;
  vHdl->cplBold                # true;

  vHdl # vWshHdl->cphRange( 'L2:P2' )
  vHdl->ComCall( 'Merge' );
  vHdl->cpaValue               # 'Jahr ' + AInt( aJahr + 1899 );
  vHdl->cpiHorizontalAlignment # xlCenter;
  vHdl                         # vHdl->cphFont;
  vHdl->cpiSize                # 12;
  vHdl->cplBold                # true;

  /* Beschriftungen */
  vHdl # vWshHdl->cphRange( 'A2:A20' )
  ComPropSet( vHdl->cphColumns, 'ColumnWidth', 18.0 );
  vHdl->cpaItem(  3 ) # 'Januar';
  vHdl->cpaItem(  4 ) # 'Februar';
  vHdl->cpaItem(  5 ) # 'März';
  vHdl->cpaItem(  6 ) # '1. Quartal';
  vHdl->cpaItem(  7 ) # 'April';
  vHdl->cpaItem(  8 ) #  'Mai';
  vHdl->cpaItem(  9 ) # 'Juni';
  vHdl->cpaItem( 10 ) # '2. Quartal';
  vHdl->cpaItem( 11 ) # 'Juli';
  vHdl->cpaItem( 12 ) # 'August';
  vHdl->cpaItem( 13 ) # 'September';
  vHdl->cpaItem( 14 ) # '3. Quartal';
  vHdl->cpaItem( 15 ) # 'Oktober';
  vHdl->cpaItem( 16 ) # 'November';
  vHdl->cpaItem( 17 ) # 'Dezember';
  vHdl->cpaItem( 18 ) # '4. Quartal';
  vHdl->cpaItem( 19 ) # 'Gesamt';
  vHdl                # vHdl->cphBorders( xlEdgeRight );
  vHdl->cpiLineStyle  # xlContinuous;
  vHdl->cpiWeight     # xlMedium;

  vHdl # vWshHdl->cphRange( 'A3:P3' )
  vHdl->cpaItem(  1 ) # 'Monat';
  vHdl->cpaItem(  2 ) # 'Einkauf';
  vHdl->cpaItem(  3 ) # '%';
  vHdl->cpaItem(  4 ) # 'Interne Kosten';
  vHdl->cpaItem(  5 ) # '%';
  vHdl->cpaItem(  6 ) # 'VK kg';
  vHdl->cpaItem(  7 ) # '%';
  vHdl->cpaItem(  8 ) # 'Verkauf';
  vHdl->cpaItem(  9 ) # '%';
  vHdl->cpaItem( 10 ) # 'Deckbeitrag1';
  vHdl->cpaItem( 11 ) # '%';
  vHdl->cpaItem( 12 ) # 'Einkauf';        // Vorjahr
  vHdl->cpaItem( 13 ) # 'Interne Kosten'; // Vorjahr
  vHdl->cpaItem( 14 ) # 'VK kg';          // Vorjahr
  vHdl->cpaItem( 15 ) # 'Verkauf';        // Vorjahr
  vHdl->cpaItem( 16 ) # 'Deckbeitrag1';   // Vorjahr
  vHdl                # vHdl->cphBorders( xlEdgeBottom );
  vHdl->cpiLineStyle  # xlContinuous;
  vHdl->cpiWeight     # xlMedium;
  vHdl                # vHdl->cphParent->cphFont;
  vHdl->cplBold       # true;

  // Daten
  if (Set.Installname='BCS') and (aName='UNTERNEHMEN') then begin
    RecBufClear( 558 ); // Fixkosten leeren
    v558 # RecBufCreate(558);
    v558VJ # RecBufCreate(558);
    FxK.Jahr  # 1900 + aJahr;
    FxK.lfdNr # 1;
    FOR Erx # RecRead( 558, 1, 0 )
    LOOP Erx # RecRead(558,1,_recNext)
    WHILE (erx<_rNoRec) and (FxK.Jahr=1900 + aJahr) do begin
      // addieren
      FOR vJ # 6 LOOP inc (vJ) while (vJ<=17) do begin
        FldDef(v558, 1, vJ, (FldFloat( v558, 1, vJ) + FldFloat( 558, 1, vJ) ));
      END;
    END;
    FxK.Jahr  # 1900 + aJahr - 1;
    FxK.lfdNr # 1;
    FOR Erx # RecRead( 558, 1, 0 )
    LOOP Erx # RecRead(558,1,_recNext)
    WHILE (erx<_rNoRec) and (FxK.Jahr=1900 + aJahr -1) do begin
      // addieren
      FOR vJ # 6 LOOP inc (vJ) while (vJ<=17) do begin
        FldDef(v558VJ, 1, vJ, (FldFloat( v558VJ, 1, vJ) + FldFloat( 558, 1, vJ) ));
      END;
    END;
  end;

  // Format
  ComCall( vWshHdl->cphRange( 'B7:K7; B10:K10; B13:K13' ), 'Insert', xlShiftDown );
// B  C  D  E  F  G  H  I  J  K
// EK IK kg VK DB EK IK kg VK DB
  ComCall( vWshHdl->cphRange( 'C4:C18; D4:D18; F4:F18; G4:G18' ), 'Insert', xlShiftToRight );

  vHdl # vWshHdl->cphRange( 'A4:P20' )->cphBorders( xlInsideHorizontal );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlHairline;

  // vertikale Linien...
  vHdl # vWshHdl->cphRange( 'B3:C20; D3:E20; F3:G20; H3:I20; J3:K20' )->cphBorders( xlEdgeRight );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;
  vHdl # vHdl->cphParent->cphBorders( xlInsideVertical );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlHairline;

  vHdl # vWshHdl->cphRange( 'L3:P20' )->cphBorders( xlEdgeLeft );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlMedium;
  vHdl # vHdl->cphParent->cphBorders( xlInsideVertical );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;

  vHdl # vWshHdl->cphRange( 'A7:P7; A11:P11; A15:P15; A19:P19' )->cphFont;
  vHdl->cplBold      # true;
  vHdl # vHdl->cphParent->cphBorders( xlEdgeTop );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;
  vHdl # vHdl->cphParent->cphBorders( xlEdgeBottom );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;

  vHdl # vWshHdl->cphRange( 'A20:P20' )->cphFont;
  vHdl->cplBold      # true;
  vHdl # vHdl->cphParent->cphBorders( xlEdgeTop );
  vHdl->cpiLineStyle # xlDouble;
  vHdl->cpiWeight    # xlThick;
  vHdl # vHdl->cphParent->cphInterior;
  vHdl->cpiColor     # xlRGB( 0x99CCFF );
  vHdl->cpiPattern   # 1; // xlPatternSolid

  ComCall( vWshHdl->cphRange( 'A2:P20' ), 'BorderAround', xlContinuous, xlMedium );


  // Formeln PROZENT
  vHdl # vWshHdl->cphRange( 'C4:C20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC12=0, 0, ( RC2 / RC12 * 100 ) - 100 )';
  vHdl # vWshHdl->cphRange( 'E4:E20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC13=0, 0, ( RC4 / RC13 * 100 ) - 100 )';
  vHdl # vWshHdl->cphRange( 'G4:G20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC14=0, 0, ( RC6 / RC14 * 100 ) - 100 )';
  vHdl # vWshHdl->cphRange( 'I4:I20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC15=0, 0, ( RC8 / RC15 * 100 ) - 100 )';
  vHdl # vWshHdl->cphRange( 'K4:K20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC16=0, 0, ( RC10/ RC16 * 100 ) - 100 )';

  // Quartalssummen
  vHdl # vWshHdl->cphRange( 'B7;B11;B15;B19; D7;D11;D15;D19; F7;F11;F15;F19; H7;H11;H15;H19; J7;J11;J15;J19; L11:P11;L15:P15;L19:P19;L7:P7' );
  vHdl->cpaFormulaR1C1 # '=SUM( R[-3]C:R[-1]C )';
  vHdl # vHdl->cphFont;
  vHdl->cplBold  # true;

  // Jahressummen
  vHdl # vWshHdl->cphRange( 'B20; D20; F20; H20; J20; K20:P20' );
  vHdl->cpaFormulaR1C1 # '=SUM( R[-16]C:R[-14]C, R[-12]C:R[-10]C, R[-8]C:R[-6]C, R[-4]C:R[-2]C )';


  // Daten einfüllen...
  vHdl # vWshHdl->cphRange( 'A1:P18' )
  vZeile # 4;
  FOR  vI # 1;
  LOOP vI # vI + 1;
  WHILE ( vI <= 12 ) DO BEGIN
    OSt.Name  # aName;
    OSt.Monat # vI;
    OSt.Jahr  # aJahr;
    if ( RecRead( 890, 1, 0 ) != _rOK ) then
      RecBufClear( 890 );

    if (v558<>0) then begin
      Ost.EK.Wert       # 0.0;
      OSt.interneKosten # FldFloat(v558, 1, 5+vI);
      OSt.DeckBeitrag1  # OSt.VK.Wert - OSt.interneKosten;
    end;

    vHdl->cpfItem( vZeile, 2 ) # OSt.EK.Wert;
    vHdl->cpfItem( vZeile, 4 ) # OSt.interneKosten;
    vHdl->cpfItem( vZeile, 6 ) # OSt.VK.Gewicht;
    vHdl->cpfItem( vZeile, 8 ) # OSt.VK.Wert;
    vHdl->cpfItem( vZeile, 10) # OSt.DeckBeitrag1;

    // Vorjahr
    OSt.Name  # aName;
    OSt.Monat # vI;
    OSt.Jahr  # aJahr - 1;
    if ( RecRead( 890, 1, 0 ) != _rOK ) then
      RecBufClear( 890 );
    if (v558VJ<>0) then begin
      Ost.EK.Wert       # 0.0;
      OSt.interneKosten # FldFloat(v558VJ, 1, 5+vI);
      OSt.DeckBeitrag1  # OSt.VK.Wert - OSt.interneKosten;
    end;

    vHdl->cpfItem( vZeile, 12) # OSt.EK.Wert;
    vHdl->cpfItem( vZeile, 13) # OSt.interneKosten;
    vHdl->cpfItem( vZeile, 14) # OSt.VK.Gewicht;
    vHdl->cpfItem( vZeile, 15) # OSt.VK.Wert;
    vHdl->cpfItem( vZeile, 16) # OSt.DeckBeitrag1;
    vZeile # vZeile + 1;
    // Summenzeilen überspringen
    if (vZeile=7) or (vZeile=11) or (vZeile=15) or (vZeile=19) then vZeile # vZeile + 1;
  END;
  if (v558<>0) then RecbufDestroy(v558);
  if (v558VJ<>0) then RecbufDestroy(v558VJ);

  // Format
  ComPropSet( vWshHdl->cphRange( 'B4:O20' ), 'NumberFormat', '#.##0,00;[Rot]-#.##0,00' )
  ComCall( vWshHdl->cphColumns( 'B:O' ), 'Autofit' )


  /** Worksheet 2 : Jahresübersicht (Chart) **/
  /*
  vChtHdl # vWbkHdl->ComCall( 'Charts.Add' );
  vChtHdl->cpiChartType # xlLineMarkers;
  vChtHdl->cplHasTitle  # true;

  ComPropSet( vChtHdl->cphChartTitle, 'Text', 'Onlinestatistik: ' + aBem + ' (' + AInt( aJahr + 1900 ) + ')' );
  vChtHdl->ComCall( 'Location', 1, 'Jahr ' + AInt( aJahr + 1900 ) );

  vHdl # ComCall( vChtHdl->cphSeriesCollection, 'NewSeries' );
  vHdl->cpaXValues # '=(Daten!A4:A6;Daten!A8:A10;Daten!A12:A14;Daten!A16:A18)';
  vHdl->cphValues  # '=(Daten!B4:B6;Daten!B8:B10;Daten!B12:B14;Daten!B16:B18)';
  vHdl->cpaName    # '=Daten!B3';

  vHdl # vChtHdl->ComCall( 'SeriesCollection.NewSeries' );
  vHdl->cpaValues  # '=(Daten!D4:D6;Daten!D8:D10;Daten!D12:D14;Daten!D16:D18)';
  vHdl->cpaName    # '=Daten!D3';

  vHdl # vChtHdl->ComCall( 'SeriesCollection.NewSeries' );
  vHdl->cpaValues  # '=(Daten!F4:F6;Daten!F8:F10;Daten!F12:F14;Daten!F16:F18)';
  vHdl->cpaName    # '=Daten!F3';

  vHdl # vChtHdl->ComCall( 'SeriesCollection.NewSeries' );
  vHdl->cpaValues  # '=(Daten!H4:H6;Daten!H8:H10;Daten!H12:H14;Daten!H16:H18)';
  vHdl->cpaName    # '=Daten!H3';
  */

  /** COM termination **/
  gFrmMain->WinDialogBox( 'Warten...', 'Klicken um Excel zu beenden', _winIcoInformation, _winDialogOK, 0 );

  // will raise an exception if the workbook was already closed, so use the try/except-setter
  _ComPropSet( vWbkHdl, 'Saved', true );
  vAppHdl->ComCall( 'Quit' );
  vAppHdl->ComClose();
end;


//=========================================================================
// ExportOSt
//        OnlineStatistik (OSt) tabellarisch anzeigen (Excel)
//=========================================================================
sub ExportOSt(
  aName     : alpha;
  aJahr     : int;
  aBem      : alpha;
  opt aFxK  : logic )
local begin
  vAppHdl   : handle;
  vWbkHdl   : handle;
  vWshHdl   : handle;
  vChtHdl   : handle;
  vHdl      : handle;
  vI,vJ     : int;
  vA        : alpha;
  Erx       : int;
  v558      : int;
  v558VJ    : int;
end
begin
  // 2022-09-29 AH
  if (Set.Installname='BFS') then begin
    ExportOstMitMenge(aName, aJahr, aBem, aFxK);
    RETURN;
  end;
  

  /** COM initialization **/
  vAppHdl # ComOpen( 'Excel.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Excel.Application NOT found!',0,0,0);
    RETURN;
  end;

  vAppHdl->cplVisible # true;
  vWbkHdl # vAppHdl->ComCall( 'Workbooks.Add' );

  FOR  vI # vWbkHdl->cphWorksheets->cpiCount;
  LOOP vI # vI - 1;
  WHILE ( vI > 1 ) DO BEGIN
    vHdl # vWbkHdl->cphWorksheets( vI )
    vHdl->ComCall( 'Delete' );
  END;

  /** Worksheet 1 : Daten **/
  vWshHdl # vWbkHdl->cphWorksheets(1);
  vWshHdl->cpaName # 'Daten';
//vI # vWshHdl->cphVBProject;
//debugx(aint(vI));
//  _ComPropGet(vWbkHdl,'VBProject',vHdl);
//debugx(aint(vHdl));
//  _ComPropGet(vWbkHdl,'VBProject.Name',vA);
//debugx(vA);

  /* Titel & Überschriften */
  vHdl # vWshHdl->cphRange( 'A1:M1' );
  vHdl->ComCall( 'Merge' );
  vHdl->cpaValue               # 'Onlinestatistik: ' + aBem
  vHdl->cpiHorizontalAlignment # xlCenter;
  vHdl                         # vHdl->cphFont;
  vHdl->cpiSize                # 14;
  vHdl->cplBold                # true;

  vHdl # vWshHdl->cphRange( 'B2:I2' )
  vHdl->ComCall( 'Merge' );
  vHdl->cpaValue               # 'Jahr ' + AInt( aJahr + 1900 );
  vHdl->cpiHorizontalAlignment # xlCenter;
  vHdl                         # vHdl->cphFont;
  vHdl->cpiSize                # 12;
  vHdl->cplBold                # true;

  vHdl # vWshHdl->cphRange( 'J2:M2' )
  vHdl->ComCall( 'Merge' );
  vHdl->cpaValue               # 'Jahr ' + AInt( aJahr + 1899 );
  vHdl->cpiHorizontalAlignment # xlCenter;
  vHdl                         # vHdl->cphFont;
  vHdl->cpiSize                # 12;
  vHdl->cplBold                # true;

  /* Beschriftungen */
  vHdl # vWshHdl->cphRange( 'A2:A20' )
  ComPropSet( vHdl->cphColumns, 'ColumnWidth', 18.0 );
  vHdl->cpaItem(  3 ) # 'Januar';
  vHdl->cpaItem(  4 ) # 'Februar';
  vHdl->cpaItem(  5 ) # 'März';
  vHdl->cpaItem(  6 ) # '1. Quartal';
  vHdl->cpaItem(  7 ) # 'April';
  vHdl->cpaItem(  8 ) #  'Mai';
  vHdl->cpaItem(  9 ) # 'Juni';
  vHdl->cpaItem( 10 ) # '2. Quartal';
  vHdl->cpaItem( 11 ) # 'Juli';
  vHdl->cpaItem( 12 ) # 'August';
  vHdl->cpaItem( 13 ) # 'September';
  vHdl->cpaItem( 14 ) # '3. Quartal';
  vHdl->cpaItem( 15 ) # 'Oktober';
  vHdl->cpaItem( 16 ) # 'November';
  vHdl->cpaItem( 17 ) # 'Dezember';
  vHdl->cpaItem( 18 ) # '4. Quartal';
  vHdl->cpaItem( 19 ) # 'Gesamt';
  vHdl                # vHdl->cphBorders( xlEdgeRight );
  vHdl->cpiLineStyle  # xlContinuous;
  vHdl->cpiWeight     # xlMedium;

  vHdl # vWshHdl->cphRange( 'A3:M3' )
  vHdl->cpaItem(  1 ) # 'Monat';
  vHdl->cpaItem(  2 ) # 'Einkauf';
  vHdl->cpaItem(  3 ) # '%';
  vHdl->cpaItem(  4 ) # 'Interne Kosten';
  vHdl->cpaItem(  5 ) # '%';
  vHdl->cpaItem(  6 ) # 'Verkauf';
  vHdl->cpaItem(  7 ) # '%';
  vHdl->cpaItem(  8 ) # 'Deckbeitrag1';
  vHdl->cpaItem(  9 ) # '%';
  vHdl->cpaItem( 10 ) # 'Einkauf';        // Vorjahr
  vHdl->cpaItem( 11 ) # 'Interne Kosten'; // Vorjahr
  vHdl->cpaItem( 12 ) # 'Verkauf';        // Vorjahr
  vHdl->cpaItem( 13 ) # 'Deckbeitrag1';   // Vorjahr
  vHdl                # vHdl->cphBorders( xlEdgeBottom );
  vHdl->cpiLineStyle  # xlContinuous;
  vHdl->cpiWeight     # xlMedium;
  vHdl                # vHdl->cphParent->cphFont;
  vHdl->cplBold       # true;

  // Daten
  if (Set.Installname='BCS') and (aName='UNTERNEHMEN') then begin
    RecBufClear( 558 ); // Fixkosten leeren
    v558 # RecBufCreate(558);
    v558VJ # RecBufCreate(558);
    FxK.Jahr  # 1900 + aJahr;
    FxK.lfdNr # 1;
    FOR Erx # RecRead( 558, 1, 0 )
    LOOP Erx # RecRead(558,1,_recNext)
    WHILE (erx<_rNoRec) and (FxK.Jahr=1900 + aJahr) do begin
      // addieren
      FOR vJ # 6 LOOP inc (vJ) while (vJ<=17) do begin
        FldDef(v558, 1, vJ, (FldFloat( v558, 1, vJ) + FldFloat( 558, 1, vJ) ));
      END;
    END;
    FxK.Jahr  # 1900 + aJahr - 1;
    FxK.lfdNr # 1;
    FOR Erx # RecRead( 558, 1, 0 )
    LOOP Erx # RecRead(558,1,_recNext)
    WHILE (erx<_rNoRec) and (FxK.Jahr=1900 + aJahr -1) do begin
      // addieren
      FOR vJ # 6 LOOP inc (vJ) while (vJ<=17) do begin
        FldDef(v558VJ, 1, vJ, (FldFloat( v558VJ, 1, vJ) + FldFloat( 558, 1, vJ) ));
      END;
    END;
  end;
  
  vHdl # vWshHdl->cphRange( 'B4:I15' )
  FOR  vI # 1;
  LOOP vI # vI + 1;
  WHILE ( vI <= 12 ) DO BEGIN
    OSt.Name  # aName;
    OSt.Monat # vI;
    OSt.Jahr  # aJahr;
    if ( RecRead( 890, 1, 0 ) != _rOK ) then
      RecBufClear( 890 );

//Ost.Internekosten # 52345.6;
    if (v558<>0) then begin
      Ost.EK.Wert       # 0.0;
      OSt.interneKosten # FldFloat(v558, 1, 5+vI);
      OSt.DeckBeitrag1  # OSt.VK.Wert - OSt.interneKosten;
    end;
    vHdl->cpfItem( vI, 1 ) # OSt.EK.Wert;
    vHdl->cpfItem( vI, 2 ) # OSt.interneKosten;
    vHdl->cpfItem( vI, 3 ) # OSt.VK.Wert;
    vHdl->cpfItem( vI, 4 ) # OSt.DeckBeitrag1;

    // Vorjahr
    OSt.Name  # aName;
    OSt.Monat # vI;
    OSt.Jahr  # aJahr - 1;
    if ( RecRead( 890, 1, 0 ) != _rOK ) then
      RecBufClear( 890 );
//ost.vk.wert # ost.vk.wert * 123456.7;
//ost.EK.wert # ost.vk.wert;
//ost.internekosten # ost.vk.wert;
//ost.deckbeitrag1 # ost.vk.wert;
    if (v558VJ<>0) then begin
      Ost.EK.Wert       # 0.0;
      OSt.interneKosten # FldFloat(v558VJ, 1, 5+vI);
      OSt.DeckBeitrag1  # OSt.VK.Wert - OSt.interneKosten;
    end;

    vHdl->cpfItem( vI, 5 ) # OSt.EK.Wert;
    vHdl->cpfItem( vI, 6 ) # OSt.interneKosten;
    vHdl->cpfItem( vI, 7 ) # OSt.VK.Wert;
    vHdl->cpfItem( vI, 8 ) # OSt.DeckBeitrag1;
  END;
  if (v558<>0) then RecbufDestroy(v558);
  if (v558VJ<>0) then RecbufDestroy(v558VJ);

  /* Format */
  ComCall( vWshHdl->cphRange( 'B7:I7; B10:I10; B13:I13' ), 'Insert', xlShiftDown );
  ComCall( vWshHdl->cphRange( 'C4:C18; D4:D18; E4:E18; F4:F18' ), 'Insert', xlShiftToRight );

  vHdl # vWshHdl->cphRange( 'A4:M20' )->cphBorders( xlInsideHorizontal );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlHairline;

  vHdl # vWshHdl->cphRange( 'B3:C20; D3:E20; F3:G20; H3:I20' )->cphBorders( xlEdgeRight );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;
  vHdl # vHdl->cphParent->cphBorders( xlInsideVertical );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlHairline;

  vHdl # vWshHdl->cphRange( 'J3:M20' )->cphBorders( xlEdgeLeft );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlMedium;
  vHdl # vHdl->cphParent->cphBorders( xlInsideVertical );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;

  vHdl # vWshHdl->cphRange( 'A7:M7; A11:M11; A15:M15; A19:M19' )->cphFont;
  vHdl->cplBold      # true;
  vHdl # vHdl->cphParent->cphBorders( xlEdgeTop );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;
  vHdl # vHdl->cphParent->cphBorders( xlEdgeBottom );
  vHdl->cpiLineStyle # xlContinuous;
  vHdl->cpiWeight    # xlThin;

  vHdl # vWshHdl->cphRange( 'A20:M20' )->cphFont;
  vHdl->cplBold      # true;
  vHdl # vHdl->cphParent->cphBorders( xlEdgeTop );
  vHdl->cpiLineStyle # xlDouble;
  vHdl->cpiWeight    # xlThick;
  vHdl # vHdl->cphParent->cphInterior;
  vHdl->cpiColor     # xlRGB( 0x99CCFF );
  vHdl->cpiPattern   # 1; // xlPatternSolid

  ComCall( vWshHdl->cphRange( 'A2:M20' ), 'BorderAround', xlContinuous, xlMedium );

  /* Formeln */
  vHdl # vWshHdl->cphRange( 'C4:C20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC10=0, 0, ( RC2 / RC10 * 100 ) - 100 )';

  vHdl # vWshHdl->cphRange( 'E4:E20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC11=0, 0, ( RC4 / RC11 * 100 ) - 100 )';

  vHdl # vWshHdl->cphRange( 'G4:G20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC12=0, 0, ( RC6 / RC12 * 100 ) - 100 )';

  vHdl # vWshHdl->cphRange( 'I4:I20' );
  vHdl->cpaFormulaR1C1 # '=IF( RC13=0, 0, ( RC8 / RC13 * 100 ) - 100 )';

  vHdl # vWshHdl->cphRange( 'B7;B11;B15;B19; D7;D11;D15;D19; F7;F11;F15;F19; H7;H11;H15;H19; J11:M11;J15:M15;J19:M19;J7:M7' );
  vHdl->cpaFormulaR1C1 # '=SUM( R[-3]C:R[-1]C )';
  vHdl # vHdl->cphFont;
  vHdl->cplBold  # true;

  vHdl # vWshHdl->cphRange( 'B20; D20; F20; H20; J20:M20' );
  vHdl->cpaFormulaR1C1 # '=SUM( R[-16]C:R[-14]C, R[-12]C:R[-10]C, R[-8]C:R[-6]C, R[-4]C:R[-2]C )';

  // Format
  ComPropSet( vWshHdl->cphRange( 'B4:M20' ), 'NumberFormat', '#.##0,00;[Rot]-#.##0,00' )
  ComCall( vWshHdl->cphColumns( 'B:M' ), 'Autofit' )

  /** Worksheet 2 : Jahresübersicht (Chart) **/
  /*
  vChtHdl # vWbkHdl->ComCall( 'Charts.Add' );
  vChtHdl->cpiChartType # xlLineMarkers;
  vChtHdl->cplHasTitle  # true;

  ComPropSet( vChtHdl->cphChartTitle, 'Text', 'Onlinestatistik: ' + aBem + ' (' + AInt( aJahr + 1900 ) + ')' );
  vChtHdl->ComCall( 'Location', 1, 'Jahr ' + AInt( aJahr + 1900 ) );

  vHdl # ComCall( vChtHdl->cphSeriesCollection, 'NewSeries' );
  vHdl->cpaXValues # '=(Daten!A4:A6;Daten!A8:A10;Daten!A12:A14;Daten!A16:A18)';
  vHdl->cphValues  # '=(Daten!B4:B6;Daten!B8:B10;Daten!B12:B14;Daten!B16:B18)';
  vHdl->cpaName    # '=Daten!B3';

  vHdl # vChtHdl->ComCall( 'SeriesCollection.NewSeries' );
  vHdl->cpaValues  # '=(Daten!D4:D6;Daten!D8:D10;Daten!D12:D14;Daten!D16:D18)';
  vHdl->cpaName    # '=Daten!D3';

  vHdl # vChtHdl->ComCall( 'SeriesCollection.NewSeries' );
  vHdl->cpaValues  # '=(Daten!F4:F6;Daten!F8:F10;Daten!F12:F14;Daten!F16:F18)';
  vHdl->cpaName    # '=Daten!F3';

  vHdl # vChtHdl->ComCall( 'SeriesCollection.NewSeries' );
  vHdl->cpaValues  # '=(Daten!H4:H6;Daten!H8:H10;Daten!H12:H14;Daten!H16:H18)';
  vHdl->cpaName    # '=Daten!H3';
  */

  /** COM termination **/
  gFrmMain->WinDialogBox( 'Warten...', 'Klicken um Excel zu beenden', _winIcoInformation, _winDialogOK, 0 );

  // will raise an exception if the workbook was already closed, so use the try/except-setter
  _ComPropSet( vWbkHdl, 'Saved', true );
  vAppHdl->ComCall( 'Quit' );
  vAppHdl->ComClose();
end;

//=========================================================================
// DisplayOStGraph
//        OnlineStatistik (OSt) grafisch anzeigen (GLE)
//=========================================================================
sub DisplayOStGraph (
  aName     : alpha;
  aJahr     : int;
  aBem      : alpha;
  opt aFxK  : logic) : logic;
local begin
  Erx         : int;
  vFileHdl    : handle;
  vFileTxt    : alpha;
  vFileGle    : alpha;
  vFileEps    : alpha;
  vFileJpg    : alpha;
  vScaleText  : alpha;
  vScale      : float;
  vI,vJ       : int;
  vA          : alpha(200);

  vChart      : handle;
  vChartData  : handle;
  vCol        : color;

  vWert1      : float[24];
  vWert2      : float[24];
  vWert3      : float[24];

  v558        : int;
end
begin

  /* Wertskalierung */
  RecBufClear( 558 ); // Fixkosten leeren
  v558 # RecBufCreate(558);

  aJahr  # aJahr - 1;
  vScale # 0.0;

  // Daten zusammenstellen  ===============================================
  FOR  vI # 0;
  LOOP vI # vI + 1;
  WHILE ( vI < 24 ) DO BEGIN
    // ST 2013-10-23 Projekt 1483/5
    RecBufClear(v558 ); // Fixkosten pro Monat betrachten

    OSt.Name  # aName;
    OSt.Monat # ( vI % 12 ) + 1;
    OSt.Jahr  # aJahr;
    if ( RecRead( 890, 1, 0 ) != _rOK ) then
      RecBufClear( 890 );

    if ( aFxK ) then begin // Fixkosten
      FxK.Jahr  # 1900 + aJahr;
      FxK.lfdNr # 1;
      Erx # RecRead( 558, 1, 0 );
      WHILE (erx<_rNoRec) and (FxK.Jahr=1900 + aJahr) do begin
        // addieren
        FOR vJ # 6 LOOP inc (vJ) while (vJ<=17) do begin
          FldDef(v558, 1, vJ, (FldFloat( v558, 1, vJ) + FldFloat( 558, 1, vJ) ));
        END;
        Erx # RecRead(558,1,_recNext);
      END;

    end;

    vScale # max( vScale, abs( OSt.VK.Wert ) );
    vScale # max( vScale, abs( OSt.DeckBeitrag1 ) );
    vScale # max( vScale, abs( FldFloat( 558, 1, 6 + ( vI % 12 ) ) ) ); // Fixkosten

    vWert1[vI+1] # FldFloat( v558, 1, 6 + ( vI % 12 ) );
    vWert2[vI+1] # OSt.Deckbeitrag1;
    vWert3[vI+1] # OSt.VK.Wert;
    // für BCS: wenn Umsatz, dann DB aus Fixkosten errechnen
    if (Set.Installname='BCS') and (aName='UNTERNEHMEN') and (vWert3[vI+1]<>0.0) then begin
      vWert2[vI+1] # vWert3[vI+1] - vWert1[vI+1];
    end;
    if ( vI = 11 ) then
      aJahr # aJahr + 1;
  END;

  RecBufDestroy(v558);


  // Skalieren =================================================
  if ( vScale > 10000000.0 ) then begin
    vScaleText # Translate('in zehntausend Euro');
    vScale     # 0.0001;
    end
  else if ( vScale > 10000.0 ) then begin
    vScaleText # Translate('in tausend Euro');
    vScale     # 0.001;
  end
  else if ( vScale > 1000.0 ) then begin
    vScaleText # Translate('in hundert Euro');
    vScale     # 0.01;
  end
  else begin
    vScaleText # Translate('Euro');
    vScale     # 1.0;
  end;
  FOR  vI # 1;
  LOOP vI # vI + 1;
  WHILE ( vI <= 24 ) DO BEGIN
    vWert1[vI] # Rnd(vWert1[vI] * vScale,1);
    vWert2[vI] # Rnd(vWert2[vI] * vScale,1);
    vWert3[vI] # Rnd(vWert3[vI] * vScale,1);
  END;



  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
  vFileJpg # _Sys->spPathTemp+'StahlControl\Visualizer\' + gUserName + '.jpg';

  vChart # ChartOpen(_ChartXY, 1024, 700, aName+' '+aint(aJahr+1900), _ChartOptLegendVertical);
  if (vChart <= 0) then RETURN false;

  // Titel der X-Achse des Koordinatendiagramms
  vChart->spChartXYTitleX       # Translate('Monat');
  // Titel der Y-Achse des Koordinatendiagramms
  vChart->spChartXYTitleY       # vScaleText;
  vChart->spChartXYLabelAngleX  # 0.0;


  // Diagrammbereich des Graphen
  vChart->spChartArea         # RectMake(50+20, 50, 1024-50, 700-75-25);
  vChart->spChartBorderWidth  # 2;
  // Titelbereich
  vChart->spChartTitleArea    # RectMake(40, 5, 1024-50+20, 0);

  vChart->spChartLegendColBkg     # ColorMake(ColorRgbMake(255, 255, 255), 0);
  vChart->spChartLegendColBorder  # ColorMake(ColorRgbMake(255,255,255), 255);
  vChart->spChartLegendKeyGap     # 3;
  vChart->spChartLegendKeySize    # PointMake(6,6);
//  vChart->spChartLegendPos        # PointMake(100,50);
  vChart->spChartLegendPos        # PointMake(0,620);

  // Balkenschattierung des Koordinatendiagramms
  vChart->spChartXYBarShading # _ChartXYBarShadingGradientBottom;

  // Hintergrundfarbe des Diagramms
  vChart->spChartColBkg       # ColorMake(ColorRgbMake(255, 255, 255), 0);  // weiss
  // Hintergrundfarbe des Titels
  vChart->spChartTitleColBkg  # ColorMake(ColorRgbMake(0, 32, 192), 128);   //
  // Vordergrundfarbe des Titels
  vChart->spChartTitleColFg   # ColorMake(ColorRgbMake(255, 255, 255), 0);  //
  // Hintergrundfarbe des Koordinatendiagramms
  vChart->spChartXYColBkg     # ColorMake(ColorRgbMake(255, 255, 255), 0);  //
  // Alternative Hintergrundfarbe des Koordinatendiagramms
  vChart->spChartXYColBkgAlt  # ColorMake(ColorRgbMake(255, 255, 255), 0);  //


  // Rahmenfarbe des Koordinatendiagramms (pro Datenreihe)
  vChart->spChartXYColBorder  # ColorMake(ColorRgbMake(255, 255, 255), 160);
  // Datenfarbe des Koordinatendiagramms (pro Datenreihe)
  vChart->spChartXYColData    # ColorMake(ColorRgbMake(0, 32, 192), 128);


  // 1. EBENE = FIXKOSTEN =========================================================================
  // Datenstil des Koordinatendiagramms (pro Datenreihe)
  vChart->spChartXYLegendText # Translate('Fixkosten');
  vChart->spChartXYStyleData  # _ChartXYStyleDataLine;
  vChart->spChartXYLineWidth  # 2;
  vChart->spChartXYDepth      # 0;
  vChart->spChartXYDepthGap   # 0;
  vChart->spChartXYColData    # ColorMake(ColorRgbMake(255,0,0), 0);

  // Datenreihe für Werte und Beschriftungen öffnen
  vChartData # vChart->ChartDataOpen(12+12,
    _ChartDataValue | _ChartDataLabel | _ChartDataColor);
  if (vChartData > 0) then begin

    FOR  vI # 0;
    LOOP vI # vI + 1;
    WHILE ( vI < 24 ) DO BEGIN
//      vA # StrCut(Lib_Berechnungen:Monat_aus_datum(datemake(1, 1 + (vI % 12), aJahr)) ,1,3);
      vA # aint((vI % 12) + 1)+'/'+aint(aJahr - 101 + (vI div 12));
      vA # vA + StrChar(10);
      vA # vA + StrChar(10) + anum(vWert1[vI+1],1);
      vA # vA + StrChar(10) + anum(vWert2[vI+1],1);
      vA # vA + StrChar(10) + anum(vWert3[vI+1],1);

      // Beschriftung
      vChartData->ChartDataAdd(vA, _ChartDataLabel);
      // Farbe
      vCol # ColorMake(ColorRgbMake(255,  0, 0), 0);
      vChartData->ChartDataAdd(vCol, _ChartDataColor);
      // Wert
      vChartData->ChartDataAdd( vWert1[vI+1], _ChartDataValue);
    END;

    // Datenreihe schließen
    vChartData->ChartDataClose();
  end;


  // 2. EBENE = GEWINN  ===========================================================================
  vChart->spChartXYLegendText # Translate('DBeitrag');
  vChart->spChartXYStyleData  # _ChartXYStyleDataBar;
  vChart->spChartXYDepth      # 7;
  vChart->spChartXYDepthGap   # 0;
  vChart->spChartXYBarGap     # 0.40;

  // Datenreihe für Werte und Beschriftungen öffnen
  vChartData # vChart->ChartDataOpen(12+12,
    _ChartDataValue  | _ChartDataColor);
  if (vChartData > 0) then begin

    FOR  vI # 0;
    LOOP vI # vI + 1;
    WHILE ( vI < 24 ) DO BEGIN
      // Farbe
//      if (vWert2[vI+1]>=vWert1[vI+1]) then
      if (vWert2[vI+1]>=0.0) then
        vCol # ColorMake(ColorRgbMake(000, 255, 000), 100)
      else
        vCol # ColorMake(ColorRgbMake(255, 80 ,  80), 100);
      vChartData->ChartDataAdd(vCol, _ChartDataColor);
      // Wert
      vChartData->ChartDataAdd( vWert2[vI+1], _ChartDataValue);
    END;

    // Datenreihe schließen
    vChartData->ChartDataClose();
  end;


  // 3. EBENE = UMSATZ  ===========================================================================
  vChart->spChartXYLegendText # Translate('Umsatz');
  vChart->spChartXYStyleData  # _ChartXYStyleDataBar;
  vChart->spChartXYDepth      # 7;
  vChart->spChartXYDepthGap   # 0;
  vChart->spChartXYBarGap     # 0.40;

  // Datenreihe für Werte und Beschriftungen öffnen
  vChartData # vChart->ChartDataOpen(12+12,
    _ChartDataValue  | _ChartDataColor);
  if (vChartData > 0) then begin

    FOR  vI # 0;
    LOOP vI # vI + 1;
    WHILE ( vI < 24 ) DO BEGIN
      // Farbe
      vCol # ColorMake(ColorRgbMake(000, 000, 255), 100);
      vChartData->ChartDataAdd(vCol, _ChartDataColor);
      // Wert
      vChartData->ChartDataAdd( vWert3[vI+1], _ChartDataValue);
    END;

    // Datenreihe schließen
    vChartData->ChartDataClose();
  end;



  // Diagramm speichern
  vChart->ChartSave(vFileJpg, _ChartFormatAuto);

  // Diagramm schließen
  vChart->ChartClose();


  // Grafik anzeigen
  Dlg_Bild( '*' + vFileJpg );

  // Abschluss
  FsiDelete( vFileJpg );
//  WinEvtProcessSet( _winEvtTimer, true );

  RETURN true;
end;

/***
  vFileTxt # Set.Graph.Workpfad + gUserName + '.txt';
  vFileGle # Set.Graph.Workpfad + 'scripts\' + gUserName + '.gle';
  vFileEps # Set.Graph.Workpfad + 'scripts\' + gUserName + '.eps';
  vFileJpg # Set.Graph.Workpfad + 'pics\' + gUserName + '.jpg';
  vFileHdl # FsiOpen( vFileTxt, _fsiAcsW | _fsiCreate | _fsiTruncate );
  if ( vFileHdl <= 0 ) then begin
    RETURN false;
  end;


  /* Daten */
  aJahr # aJahr - 1;

  FOR  vI # 0;
  LOOP vI # vI + 1;
  WHILE ( vI < 24 ) DO BEGIN
    OSt.Name  # aName;
    OSt.Monat # ( vI % 12 ) + 1;
    OSt.Jahr  # aJahr;
    if ( RecRead( 890, 1, 0 ) != _rOK ) then
      RecBufClear( 890 );

    vA # StrCut( AInt( 1900 + aJahr ), 3, 2 );
    case ( vI % 12 ) of
       0 : vFileHdl->FsiWrite( '"Jan' + vA + '"' );
       1 : vFileHdl->FsiWrite( '"Feb"' );
       2 : vFileHdl->FsiWrite( '"Mrz"' );
       3 : vFileHdl->FsiWrite( '"Apr"' );
       4 : vFileHdl->FsiWrite( '"Mai"' );
       5 : vFileHdl->FsiWrite( '"Jun"' );
       6 : vFileHdl->FsiWrite( '"Jul"' );
       7 : vFileHdl->FsiWrite( '"Aug"' );
       8 : vFileHdl->FsiWrite( '"Sep"' );
       9 : vFileHdl->FsiWrite( '"Okt"' );
      10 : vFileHdl->FsiWrite( '"Nov"' );
      11 : vFileHdl->FsiWrite( '"Dez' + vA + '"' );
    end;

    vFileHdl->FsiWrite( ',' + CnvAF( OSt.EK.Wert * vScale, _fmtNumNoGroup | _fmtNumPoint ) );
    vFileHdl->FsiWrite( ',' + CnvAF( OSt.VK.Wert * vScale, _fmtNumNoGroup | _fmtNumPoint ) );
    vFileHdl->FsiWrite( ',' + CnvAF( OSt.DeckBeitrag1 * vScale, _fmtNumNoGroup | _fmtNumPoint ) );

    if ( aFxK ) then begin // Fixkosten
      FxK.Jahr  # 1900 + aJahr;
      FxK.lfdNr # 1;
x      if ( RecRead( 558, 1, 0 ) > _rLocked ) then
        RecBufClear( 558 );

      vFileHdl->FsiWrite( ',' + CnvAF( FldFloat( 558, 1, 6 + ( vI % 12 ) ) * vScale, _fmtNumNoGroup | _fmtNumPoint ) );
    end;

    vFileHdl->FsiWrite( cR + cN );

    if ( vI = 11 ) then
      aJahr # aJahr + 1;
  END;

  /* Script ausführen */
  vFileHdl->FsiClose();
  WinEvtProcessSet( _winEvtTimer, false );

  // Script kopieren und Ausgabe generieren
  // '-d jpg -r 300 '
  vA # vFileGle + ' ' + aName + ' "' + vScaleText + '"' + ' ' + vFileTxt + ' Verkauf Einkauf DeckBeitrag1';

  if ( aFxK ) then begin
    SysExecute( 'cmd', '/c copy ' + Set.Graph.Workpfad + 'scripts\OSt_Fix.gle ' + vFileGle, _execMinimized | _execWait );
    SysExecute( Set.Graph.Workpfad + 'gle\bin\gle', vA + ' Fixkosten', _execMinimized | _execWait );
  end
  else begin
    SysExecute( 'cmd', '/c copy ' + Set.Graph.Workpfad + 'scripts\on.gle ' + vFileGle, _execMinimized | _execWait );
    SysExecute( Set.Graph.Workpfad + 'gle\bin\gle', vA, _execMinimized | _execWait );
  end;

  vA # '-dBATCH -dNOPAUSE -dDEVICEWIDTHPOINTS=1000 -dDEVICEHEIGHTPOINTS=550 -r300 -sDEVICE=jpeg -sOUTPUTFILE=' + vFileJpg + ' ' + vFileEps;
  SysExecute( Set.Graph.Workpfad + 'GScript\bin\gswin32', '-I' + Set.Graph.Workpfad + 'gscript ' + vA, _execMinimized | _execWait );

  // Grafik anzeigen
  Dlg_Bild( '*' + vFileJpg );

  // Abschluss
  FsiDelete( vFileTxt );
  FsiDelete( vFileGle );
  FsiDelete( vFileEps );
  FsiDelete( vFileJpg );
  WinEvtProcessSet( _winEvtTimer, true );

  RETURN true;
end;
**/


//=========================================================================
// DisplayOSt
//        OnlineStatistik (OSt) tabellarisch anzeigen (Excel) und
//        grafische Statistik generieren (GLE)
//=========================================================================
sub DisplayOSt (
  aName     : alpha;
  aJahr     : int;
  aBem      : alpha;
  opt aFxK  : logic )
local begin
  vA  : alpha(1000);
end;
begin

  // AFX funktion?
  vA # aName + '|' + aint(aJahr) + '|' + aBem + '|';
  if (aFxK) then vA # vA + 'Y'
  else vA # vA + 'N';
  if (RunAFX('OSt.Display',vA)<>0) then RETURN;


  // Jahr anpassen bzw. abfragen
  if ( aJahr = -1 ) then begin
    if ( Dlg_Standard:Anzahl( 'Jahr', var aJahr, DateYear( today ) + 1900 ) = false ) then
      RETURN;

    if ( aJahr < 50 ) then
      aJahr # aJahr + 100
    else if ( aJahr > 1900 ) then
      aJahr # aJahr - 1900;
    if ( aJahr < 0 ) or ( aJahr > 200 ) then
      RETURN;
  end;

  // Export nach Excel
  if (Msg(890002,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winIdYes) then
    ExportOSt( aName, aJahr, aBem );

  // Graph mit GLE anzeigen
  DisplayOStGraph( aName, aJahr, aBem, aFxK );
end;


//=========================================================================
// CreateLetterToAdr
//        Adresse (Adr) nutzen um Brief in Word zu schreiben
//=========================================================================
sub CreateLetterToAdr ( aDatei : int )
local begin
  Erx     : int;
  vAppHdl : handle;
  vDocHdl : handle;
  vSelHdl : handle;
  vHdl    : handle;
  vEndHdl : handle;
  vHdl2   : handle;
  vFont   : handle;
  vRange  : handle;
  vBorder : handle;
  vLine   : handle;

  vI,vJ   : int;
  vA      : alpha;
  vMonat  : int;
  vJahr   : int;
  vTonne  : float;
  vUms    : float;
  vABest  : float;
  vVSB    : float;
end
begin
  if ( Set.Template.Brief = '' ) then
    RETURN;
  if ( FsiAttributes( Set.Template.Brief ) = _errFsiNoFile ) then
    RETURN;
  WinEvtProcessSet( _winEvtTimer, false );

  /** initialization **/
  vAppHdl # ComOpen( 'Word.Application', _comAppCreate );
  if ( vAppHdl <= 0 ) then
    RETURN;

  /** COM initialization **/
  if (StrCut(Set.Template.Brief,1,1)='.') then begin
    vDocHdl # vAppHdl->ComCall( 'Documents.Add', gFsiClientPath+'\'+Set.Template.Brief );
  end
  else begin
    vDocHdl # vAppHdl->ComCall( 'Documents.Add', Set.Template.Brief );
  end;
  if (vDocHdl<=0) then begin
    vAppHdl->ComClose();
    RETURN;
  end;
  vSelHdl # vAppHdl->cphSelection;

  // Blöcke finden und gegebenfalls ersetzen
  FOR  vI # vDocHdl->cphFields->cpiCount;
  LOOP vI # vI - 1;
  WHILE ( vI > 0 ) DO BEGIN
    vHdl # vDocHdl->cphFields( vI )
    vHdl->ComCall( 'Select' );

//debugx(aint(vHdl->cpiType));

    case vHdl->cpiType of

      wdFieldMergeField : begin
        vHdl2 # vHdl->cphCode;
        vA # vHdl2->cpaText;
        vA # StrAdJ(Str_Token(vA,'MERGEFIELD',2) ,_StrBegin|_StrEnd);
//debugx('>'+vA+'<');
//debugx(vSelHdl->cpaText);
        case vA of
          '"Benutzer_1"' :  begin
            vSelHdl->ComCall( 'TypeText', '0237411111111');
          end;
          '"Benutzer_1"' :  begin
            vSelHdl->ComCall( 'TypeText', '0237411111111');
          end;
          'Telefon' :  begin
            vSelHdl->ComCall( 'TypeText', '0237411111111');
          end;
          '"Nachname"' :  begin
            vSelHdl->ComCall( 'TypeText', 'Xxxxxxx');
          end;
          '"Vorname"' :  begin
            vSelHdl->ComCall( 'TypeText', 'yyyyyyyyyyy');
          end;
          '"EMailAdresse"' :  begin
            vSelHdl->ComCall( 'TypeText', '@@@@');
          end;
          '"Journal"' : begin
//            vHdl2 # vHdl->cphResult;
//            vHdl2->cpaText # 'Kopfsalat';

// LINIE:
//vRange # vDocHdl->cphShapeS;
//vRange->ComCall('addline', 1, 1, 100, 100);

// FONT:
//vFont # vSelHdl->cphFont;
//vFont->cplBold # true;
//vFont->cpiSize # 12;

//vRange->cpiHighlightColorIndex # 4;

            vSelHdl->ComCall( 'TypeText', 'Zeitraum'+Strchar(9,2));
            vSelHdl->ComCall( 'TypeText', 'Absatz (t)'+Strchar(9));
            vSelHdl->ComCall( 'TypeText', 'Umsatz (€)'+Strchar(9));
            vSelHdl->ComCall( 'TypeText', 'Auftragsbestand aktuell (t)'+Strchar(9));
            vSelHdl->ComCall( 'TypeText', 'VSB-Ware (t)');
            vSelHdl->ComCall( 'TypeParagraph' );

            FOR vJahr # DateYear(today) + 1900 - 3
            LOOP Inc(vJahr)
            WHILE (vJahr<=DateYear(Today) + 1900) do begin
              vTonne  # 0.0;
              vUms    # 0.0;
              FOR vMonat # 1 loop Inc(vMOnat) while (vMonat<13) do begin
                Ost_data:Hole('KU:'+Cnvai(Adr.Kundennr), vMonat, vJahr);
                vTonne  # vTonne + OSt.VK.Gewicht;
                vUms    # vUms + OSt.VK.Wert;
              END;
              if (vJahr<DateYear(Today) + 1900) then begin
                vSelHdl->ComCall( 'TypeText', aInt(vJahr)+Strchar(9,3));
                vSelHdl->ComCall( 'TypeText', anum(vTonne/1000.0,0)+Strchar(9,2));
                vSelHdl->ComCall( 'TypeText', anum(vUms,0)+Strchar(9,2));
                vSelHdl->ComCall( 'TypeText', ''+Strchar(9,3));
                vSelHdl->ComCall( 'TypeText', '');
                vSelHdl->ComCall( 'TypeParagraph' );
              end
              else begin
                // Aufträge lopoen
                FOR Erx # RecLink(400,100,45,_recFirst)
                LOOP Erx # RecLink(400,100,45,_recNext)
                WHILE (erx<=_rLocked) do begin
                  if (Auf.Vorgangstyp<>c_Auf) then CYCLE;
                  // Auftragspos. loopen
                  FOR Erx # RecLink(401,400,9,_recFirst)
                  LOOP Erx # RecLink(401,400,9,_recNext)
                  WHILE (erx<=_rLocked) do begin
                    if ("Auf.P.Löschmarker"='*') then CYCLE;
                    vABest # vABest + Auf.P.Prd.Rest.Gew;
                    vVSB   # vVSB   + Auf.P.Prd.VSB.Gew;
                  END;
                END;
                vSelHdl->ComCall( 'TypeText', aInt(vJahr)+' - bisher'+Strchar(9,2));
                vSelHdl->ComCall( 'TypeText', anum(vTonne/ 1000.0,0)+Strchar(9,2));
                vSelHdl->ComCall( 'TypeText', anum(vUms / 1000.0,0)+Strchar(9,2));
                vSelHdl->ComCall( 'TypeText', anum(vABest / 1000.0,0)+Strchar(9,3));
                vSelHdl->ComCall( 'TypeText', anum(vVSB,0));
    //            vSelHdl->ComCall( 'TypeParagraph' );
              end;
            END;

vRange # vSelHdl->cphRange;
vJ # vRange->cpiInformation(10);

vSelHdl->ComCall('GoTo',3, 1, vJ);    // Line, Absolut
vSelHdl->ComCallResult(vLine);
vBorder # vLine->cphBorders(-3);  // Buttom
vBorder->cpiLinestyle # 8;        // Dreifach

vSelHdl->ComCall('GoTo',3, 1, vJ-4);    // Line, Absolut
vSelHdl->ComCallResult(vLine);
vBorder # vLine->cphBorders(-3);  // Buttom
vBorder->cpiLinestyle # 1;        // Dreifach

vRange # vSelHdl->cphRange;
vJ # vRange->cpiInformation(10);
vSelHdl->ComCall('GoTo',3, 1, vJ-1);    // Line, Absolut
vSelHdl->ComCallResult(vLine);
vBorder # vLine->cphBorders(-3);  // Buttom
vBorder->cpiLinestyle # 8;        // Dreifach

vSelHdl->ComCall('GoTo',3, 1, vJ+5);    // Line, Absolut
vSelHdl->ComCallResult(vLine);
            vSelHdl->ComCall( 'TypeParagraph' );

          end;
        end;
      end;


      wdFieldAddressBlock : begin // Anschriftenblock
        if ( Adr.Anrede != '' ) then begin
          vSelHdl->ComCall( 'TypeText', Adr.Anrede );
          vSelHdl->ComCall( 'TypeParagraph' );
        end;
        if ( Adr.Name != '' ) then begin
          vSelHdl->ComCall( 'TypeText', Adr.Name );
          vSelHdl->ComCall( 'TypeParagraph' );
        end;
        if ( Adr.Zusatz != '' ) then begin
          vSelHdl->ComCall( 'TypeText', Adr.Zusatz );
          vSelHdl->ComCall( 'TypeParagraph' );
        end;

        if ( aDatei = 102 ) then begin
          vA # Adr.P.Titel;
          if ( Adr.P.Vorname != '' and vA != '' ) then vA # vA + ' ';
          vA # vA + Adr.P.Vorname;
          if ( Adr.P.Name != '' and vA != '' ) then vA # vA + ' ';
          vA # vA + Adr.P.Name;
          vSelHdl->ComCall( 'TypeText', vA );
          vSelHdl->ComCall( 'TypeParagraph' );
        end;

        vSelHdl->ComCall( 'TypeText', "Adr.Straße" );
        vSelHdl->ComCall( 'TypeParagraph' );
        vSelHdl->ComCall( 'TypeText', "Adr.LKZ" + ' ' + Adr.PLZ + ' ' + Adr.Ort );
        vSelHdl->ComCall( 'TypeParagraph' );
      end;

      wdFieldGreetingLine : begin
        if ( aDatei = 102 ) and ( Adr.P.Briefanrede != '' ) then
          vSelHdl->ComCall( 'TypeText', Adr.P.Briefanrede );
        else if ( Adr.Briefanrede != '' ) then
          vSelHdl->ComCall( 'TypeText', Adr.Briefanrede );
        else
          vSelHdl->ComCall( 'TypeText', 'Sehr geehrte Damen und Herren' );
      end;

      wdFieldComments : begin
        vEndHdl # vHdl;
      end;
    end;  // case

  END;

  if ( vEndHdl != 0 ) then begin
    vEndHdl->ComCall( 'Select' );
    vSelHdl->cpaText # 'Text.';
  end
  else
    vSelHdl->ComCall( 'EndKey', wdStory );


  vAppHdl->cplVisible # true;


  vAppHdl->ComClose();
  WinEvtProcessSet( _winEvtTimer, true );
end;


//=========================================================================
// CreateEMail
//        E-Mail erstellen
//=========================================================================
sub CreateEMail (
  aTo       : alpha;
  aSubject  : alpha;
  aBody     : alpha(4096);
  opt aTxt  : int;)   // als HTTP
local begin
  vAppHdl : handle;
  vHdl    : handle;
  vMem    : int;
  vLen    : int;
end
begin
  if ( !Usr.OutlookYN ) then
    RETURN;

  /** initialization **/
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then
    RETURN;

  if (aTxt<>0) then begin
    vMem # MemAllocate(_Mem64K);
    vLen # Lib_Texte:WriteToMem(aTxt, vMem);
  end;
  
  vAppHdl->ComCall('ActiveExplorer');
  vHdl # vAppHdl->ComCall( 'CreateItem', olMailItem );
  vHdl->cpaTo         # aTo;
  vHdl->cpaSubject    # aSubject;
  if (vMem<>0) then begin
    vHdl->cpaHTMLBody       # MemReadStr(vMem, 1, vLen);
  end
  else begin
    vHdl->cpaBody       # aBody;
    vHdl->cpiBodyFormat # 3; // rich text format
  end;

  if (vMem<>0) then
    MemFree(vMem);

  /** termination **/
  _ComCall2( vHdl, 'Display', 1);
//  _ComCall( vHdl, 'Activate');
  vAppHdl->ComClose();
end;


//=========================================================================
// MailAttachement
//
//=========================================================================
sub MailAttachement(
  aReceiver   : alpha(1000);
  aSubject    : alpha(1000);
  aFilename   : alpha(2000);
  opt aFilename2   : alpha(2000);
) : logic;
local begin
  vAppHdl : handle;
  vMail   : handle;
  vAtt    : handle;
  vSig    : handle;
  vFile   : int;
  vA,vB   : alpha(4096);
  vText   : alpha(4096);
  vMax    : int;
  vMem    : int;
end
begin

  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Outlook.Application NOT found!',0,0,0);
    RETURN false;
  end;

  if ( vAppHdl < 0 ) then begin
    Msg(99,'Outlook.Application ERROR!',0,0,0);
    RETURN false;
  end;
  
  vMail # vAppHdl->ComCall( 'CreateItem', olMailItem );
  _ComPropGet(vMail,'GetInspector',vSig);

  vMail->cpaTo      # aReceiver;
  vMail->cpaSubject # aSubject;
//vMail->cpaBody    # 'sadfef'
  _ComCall2(vMail,'Attachments.Add',aFilename);
  if (aFilename2 <> '') then
  _ComCall2(vMail,'Attachments.Add',aFilename2);

  _ComCall( vMail, 'Display' );

  vAppHdl->ComClose();
  Winsleep(1000); // ST 2021-09-13 ggf. Bug SSW
end;


//=========================================================================
// demo
//        Demo subprocedure to test COM interface
//=========================================================================
sub demo () // call Lib_COM:demo
local begin
  vAppHdl : handle;
  vMail   : handle;
  vAtt    : handle;
  vSig    : handle;
  vFile   : int;
  vA,vB   : alpha(4096);
  vText   : alpha(4096);
  vMax    : int;
  vMem    : int;
end
begin
debug('Irgend ein Text zum TEsten für Anhänge...');
debug( 'Lib_COM:demo' );
  //////////////////////////////////////////////////
//  RETURN;

  /* EMAIL DEMO */
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Outlook.Application NOT found!',0,0,0);
    RETURN;
  end;

  vMail # vAppHdl->ComCall( 'CreateItem', olMailItem );
debugCom( 'CreateItem:Mail' );

_ComPropGet(vMail,'GetInspector',vSig);

//xvSig->ComCall('Add','c:\script.sql');

  vMail->cpaTo      # 'ai@stahl-control.de';
  vMail->cpaSubject # 'Test!'
//  vMail->cpaBody    # 'sadfef'

debugCom( 'getinspect' +aint(vSig));


  vFile # FSIOpen('C:\xUsers\ai.BCS2010\AppData\Roaming\Microsoft\Signatures\Standard_AI.txt', _FsiStdRead );
  if (vFile>0) then begin
    vMem # Memallocate(_Mem32k);
    vMem->spcharset # _CharSetUTF16;
    vMax # FSISize(vFile);
    FSIMark(vFile,13);
    WHILE (FsiSeek(vFile)<vMax) do begin
//      FSIRead(vFile,vA);
//vB # StrCnv(vA,_StrFromOEM);
//debug('1>'+vB+'<');
//      vText # vText + vA;
//      FSIRead(vFile, vMem);
      FSIReadMem(vFile, vMem, 1, vMax);
    END;
    FSIClose(vFile);

    vA # MemReadStr(vMem,1,2048,_CharsetC16_1252);
debug(vA);
  end;

//  vText # vText + 'asdasd';
//  vA #  vMail->cpaBody;
//  vA # 'Super Auto Text'+vA;
//  vMail->cpaBody    # vA;

  if (vMem<>0) then begin
//    vMail->cpaBody    # 'qweqwe';
    MemFree(vMem);
  end;


// So...
//  _ComPropGet(vMail,'Attachments', vAtt);
//  vAtt->ComCall('Add','c:\script.sql');
// ODER So...
//_ComCall2(vMail,'Attachments.Add','c:\script.sql');//,0,1,'Dingn');
_ComCall2(vMail,'Attachments.Add','c:\debug\debug.txt');//,0,1,'Dingn');
debugCom('Add attachment');

  //vAppHdl->ComCall( 'CreateItem', olMailItem );

  _ComCall( vMail, 'Display' );
//  _ComCall(vMail, 'Send');

  vAppHdl->ComClose();
  /* EMAIL DEMO */
end;


/*** AI
//=========================================================================
// TEST
//
//=========================================================================
sub TEST()
local begin
  vAppHdl : handle;
  vNsHdl  : handle;
  vFdHdl  : handle;
  vHdl    : handle;

  vDate   : caltime;
  vMsg    : alpha;
  vText   : alpha;
end
begin
  if ( !Usr.OutlookYN ) then
    RETURN;

  /** initialization **/
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then
    RETURN;

  vMsg # 'Aufgabe erfolgreich nach Outlook exportiert.';
  vHdl # vAppHdl->ComCall( 'CreateItem', olMailItem );
  vHdl->cpaSubject # TeM.Bezeichnung;
  vHdl->cpaBody    # Tem.Bemerkung;

  vHdl->cpcDueDate # vDate;
  vHdl->cpcDateCompleted # vDate;
  vHdl->cpiStatus        # olTaskComplete;
  _ComPropSet( vHdl, 'UnRead', true )

if (1=2) then begin
    vMsg     # 'Termin erfolgreich nach Outlook exportiert.';
    if ( Usr.OutlookCalendar != '' ) then begin
      vNsHdl # vAppHdl->ComCall( 'GetNamespace', 'MAPI' );
      vFdHdl # vNsHdl->ComCall( 'GetFolderFromId', Usr.OutlookCalendar );
    end
    if ( vFdHdl != 0 ) then
      vHdl   # vFdHdl->cphItems->ComCall( 'Add' );
    else
      vHdl   # vAppHdl->ComCall( 'CreateItem', olAppointmentItem );

    vHdl->cpaSubject    # Lib_Termine:GetTypeName( TeM.Typ ) + ': ' + TeM.Bezeichnung;
    vHdl->cpaBody       # Tem.Bemerkung;
    vHdl->cpiBusyStatus # olBusy;

    // Start Datum
    vDate->vpDate       # TeM.Start.Von.Datum;
    vDate->vpTime       # TeM.Start.Von.Zeit;
    vHdl->cpcStart      # vDate;

    // End Datum
    if ( TeM.Erledigt.Datum != 0.0.0 ) then begin
      vDate->vpDate     # TeM.Erledigt.Datum;
      vDate->vpTime     # TeM.Erledigt.Zeit;
    end
    else begin
      vDate->vpDate     # TeM.Ende.Von.Datum;
      vDate->vpTime     # TeM.Ende.Von.Zeit;
    end;
    vHdl->cpcEnd        # vDate;
  end;

  /** termination **/
  vHdl->ComCall( 'Save' );
  vAppHdl->ComClose();

  Msg( 000099, vMsg, _winIcoInformation, _winDialogOk, _winIdOk );
end;
***/


//=========================================================================
//=========================================================================
sub TobitMail() : logic;
local begin
  vAppHdl : handle;
  vMail   : handle;
  vAtt    : handle;
end
begin
/*
DavidAPIClass oApp;
Account oAcc;
Archive oArchive;
MailItem oMailItem;
Attachment oAttachment;

oApp = new DavidAPIClass();
oApp.LoginOptions = DvLoginOptions.DvLoginForceAsyncDuplicate;
oAcc = oApp.Logon("", "", "", "", "", "NOAUTH");
oArchive = oAcc.GetSpecialArchive(DvArchiveTypes.DvArchivePersonalOut);
oMailItem = (MailItem)oArchive.NewItem(DvItemTypes.DvEMailItem);
oMailItem.Recipients.Add("user@domain.com", "MAIL", "");

oMailItem.Subject = "HTML mail with inline Grafik";
oMailItem.BodyText.HTMLText = "<hmtl><body>That it is<br><img src='cid:myimgcid'></body></html>";
oMailItem.Options.UserHold = true;
oAttachment = oMailItem.Attachments.Add(@"c:\Images\logo.jpg", "cid:myimgcid");
oMailItem.Send(DBNull.Value, DBNull.Value);
oAcc.Logoff();
*/
/*
  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then RETURN false;

  vMail # vAppHdl->ComCall( 'CreateItem', olMailItem );
  _ComPropGet(vMail,'GetInspector',vSig);

  vMail->cpaTo      # aReceiver;
  vMail->cpaSubject # aSubject;
//  vMail->cpaBody    # 'sadfef'
  _ComCall2(vMail,'Attachments.Add',aFilename);
  _ComCall( vMail, 'Display' );

  vAppHdl->ComClose();
*/
end;


//=========================================================================
//=========================================================================
// Lizenz Subprozeduren
sub InitCom () begin end;
//=========================================================================
sub TermCom () begin end;
//=========================================================================


//=========================================================================
// ExportRecList
//
//=========================================================================
sub ExportRecList(
  aTitle  : alpha;
  aList   : int;
  aFile   : int;
  aProc   : alpha;
) : logic;
local begin
  Erx       : int;
  vAppHdl   : handle;
  vWbkHdl   : handle;
  vWshHdl   : handle;
  vChtHdl   : handle;
  vHdl      : handle;
  vCell     : handle;
  vCell2    : handle;
  vFont     : handle;
  vI,vJ     : int;
  vW,vH     : int;
  vA        : alpha(250);
  vEvt      : event;
  vKey      : int;
end
begin
  /** COM initialization **/
  vAppHdl # ComOpen( 'Excel.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then begin
    Msg(99,'Excel.Application NOT found!',0,0,0);
    RETURN false;
  end;

  vAppHdl->cplVisible # true;
  vWbkHdl # vAppHdl->ComCall( 'Workbooks.Add' );

  FOR  vI # vWbkHdl->cphWorksheets->cpiCount;
  LOOP vI # vI - 1;
  WHILE ( vI > 1 ) DO BEGIN
    vCell # vWbkHdl->cphWorksheets( vI )
    vCell->ComCall( 'Delete' );
  END;

  /** Worksheet 1 : Daten **/
  vWshHdl # vWbkHdl->cphWorksheets(1);
  vWshHdl->cpaName # StrCut(aTitle,1,30);   // ST 2017-06-27 Bugfix; Excel kann nur 30 Zeichen als Tabellenblatttitel

  /* Titel & Überschriften */
  vCell # vWshHdl->cphRange( 'A1:M1' )
  vCell->ComCall( 'Merge' );
  vCell->cpaValue               # 'Übersichtsliste ' + aTitle
  vCell->cpiHorizontalAlignment # xlCenter;
  vFont                         # vCell->cphFont;
  vFont->cpiSize                # 14;
  vFont->cplBold                # true;

  /* Beschriftungen */
//  vCell # vWshHdl->cphRange( 'A2:A'+aint(vCount+4) )
  vCell # vWshHdl->cphRange( 'A2:BZ1005');
//  ComPropSet(vCell->cphColumns, 'ColumnWidth', 18.0 );

  vA # '';
  vW # 0;
  FOR vHDL # aList->WinInfo( _winFirst)
  LOOP vHDL # vHDL->WinInfo( _winNext)
  WHILE (vHdl<>0) do begin
    inc(vW);

    vCell->cpaItem(1, vW) # vHdl->wpCaption;
    vCell2 # vWshHdl->cphRange( ExcelX(vW)+'2:'+ExcelX(vW)+'2');
    vFont           # vCell2->cphFont;
    vFont->cplBold  # true;

    vCell2 # vWshHdl->cphRange( ExcelX(vW)+'2:'+ExcelX(vW)+'1005');
    ComPropSet(vCell2->cphColumns, 'ColumnWidth', cnvfi(vHdl->wpClmwidth / 10) );

    vA # vHdl->wpdbFieldname;
    if (vA<>'') then begin
      case FldInfoByName(vA, _FldType) of
        _TypeWord, _TypeInt, _TypeFloat  : begin
//            ComPropSet( vCell2->cphColumns, 'NumberFormat', '#.##0,00;[Rot]-#.##0,00' )
            ComPropSet( vCell2->cphColumns, 'NumberFormat', '#.##0,00;[Rot]-#.##0,00' )
        end;
      end;
    end;

  END;


  // Daten...
//  vCell # vWshHdl->cphRange( 'A4:Z'+aint(vCount+4) )

  vEvt:obj # aList;
  vH      # 0;
  vKey # aList->wpDbKeyNo;
  if (aList->wpDbSelection<>0) then vKey # aList->wpDbSelection;
  FOR erx # RecRead(aFile, vKey, _recFirst)
  LOOP erx # RecRead(aFile, vKey, _recNext)
  WHILE (Erx<_rLocked) and (vH<=1000) do begin

    inc(vH);

    if (aProc<>'') then Call(aProc, vEvt, RecInfo(aFile, _recID));

    vJ # 1;
    vA # '';
    FOR vHDL # aList->WinInfo( _winFirst)
    LOOP vHDL # vHDL->WinInfo( _winNext)
    WHILE (vHdl<>0) do begin
      vA # vHdl->wpdbFieldname;
      if (vA<>'') then begin
        case FldInfoByName(vA, _FldType) of
          _TypeAlpha  : vA # FldAlphaByName(vA);
          _TypeWord   : vA # aint(FldWordByName(vA));
          _TypeInt    : vA # aint(FldIntByName(vA));
//          _TypeFloat  : vA # anum(FldFloatbyName(vA), vHdl->wpFmtPostComma);
          _TypeFloat  : vA # cnvaf(FldFloatbyName(vA), _FmtNumPoint, 0,  vHdl->wpFmtPostComma);
          _TypeDate   : vA # cnvad(FldDateByName(vA));
          _TypeTime   : vA # cnvat(FldTimeByName(vA));
          _TypeLogic  : if (FldLogicByName(vA)) then vA # 'J'; else vA # 'N';
          otherwise vA # '???';
        end; // case
      end;
      vCell->cpaItem( vH+1, vJ ) # vA;
      inc(vJ);
    END;  // Spalten
  END;    // Zeilen

  // Summen...
  vI # 1;
  FOR vHDL # aList->WinInfo( _winFirst)
  LOOP vHDL # vHDL->WinInfo( _winNext)
  WHILE (vHdl<>0) do begin
    vA # vHdl->wpdbFieldname;
    if (vA<>'') then begin
      case FldInfoByName(vA, _FldType) of
        _TypeWord, _TypeInt, _TypeFloat  : begin
          vCell # vWshHdl->cphRange( ExcelX(vI)+aint(vH+3)+':'+ExcelX(vI)+aint(vH+3));
          vCell->cpaFormulaR1C1 # '=SUM( R[-'+aint(vH)+']C:R[-1]C )';
          vFont # vCell->cphFont;
          vFont->cplBold  # true;
        end;
      end; // case
    end;
    inc(vI);
  END;


  /** COM termination **/
  if (vH>=1000) then
    gFrmMain->WinDialogBox( 'Warten...', 'ACHTUNG!'+Strchar(13)+'Es wurden nur 1000 Sätze übergeben!'+Strchar(13)+'Klicken um Excel zu beenden', _winIcoInformation, _winDialogOK, 0 );
  else
    gFrmMain->WinDialogBox( 'Warten...', 'Klicken um Excel zu beenden', _winIcoInformation, _winDialogOK, 0 );

  // will raise an exception if the workbook was already closed, so use the try/except-setter
  _ComPropSet( vWbkHdl, 'Saved', true );
  vAppHdl->ComCall( 'Quit' );
  vAppHdl->ComClose();

  Gv.int.01 # vH;

  RETURN true;
end;

//=========================================================================
//=========================================================================