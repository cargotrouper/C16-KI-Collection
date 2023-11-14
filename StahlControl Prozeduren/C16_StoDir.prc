// ********************************************************
// *                                                      *
// *  StoDir                                              *
//                    OHNE E_R_G
// *                                                      *
// *  Dialog: StoDir=C16.StoDir                           *
// *                                                      *
// *  Demonstration eines Dialogs zum Auslesen der Daten- *
// *  bankressourcen (auch Storage-Objekte genannt)       *
// *                                                      *
// ********************************************************
@A+
@C+

// ********************************************************
// Defines
define
{
  IsChecked(a)  : (a->wpCheckState = _WinStateChkChecked)
}

// ********************************************************
// Declares
declare FmtCalTime(aTime : caltime;) : alpha;
declare GetStoDirName() : alpha;
declare DlsFill(aHdlDls : int; aDirName : alpha;);
declare EvtInit(aEvt : event;) : logic;
declare EvtClicked(aEvt : event;) : logic;

// ********************************************************
// FmtCalTime - caltime in formatierten Datums-/Zeitwert
//              umwandeln
sub FmtCalTime
(
  aTime           : caltime   // umzuwandelnder Kalenderwert
)
  : alpha
{
  return CnvAI(aTime->vpYear   , _FmtNumNoGroup, 0, 4) + '-' +
         CnvAI(aTime->vpMonth  , _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + '-' +
         CnvAI(aTime->vpDay    , _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + ' ' +
         CnvAI(aTime->vpHours  , _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + ':' +
         CnvAI(aTime->vpMinutes, _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + ':' +
         CnvAI(aTime->vpSeconds, _FmtNumNoGroup | _FmtNumLeadZero, 0, 2);
}

// ********************************************************
// GetStoDirName - Ermitteln des Storage-Verzeichnis-Namens
sub GetStoDirName : alpha
{
  // Dialoge
  if (IsChecked($rbDirDialog))
    return 'Dialog';

  // Menüs
  if (IsChecked($rbDirMenu))
    return 'Menu';

  // PrintForms
  if (IsChecked($rbDirPrintForm))
    return 'PrintForm';

  // PrintFormList
  if (IsChecked($rbDirPrintFormList))
    return 'PrintFormList';

  // PrintDocument
  if (IsChecked($rbDirPrintDocument))
    return 'PrintDocument';

  // PrintDocTable
  if (IsChecked($rbDirPrintDocTable))
    return 'PrintDocTable';

  // Picture
  if (IsChecked($rbDirPicture))
    return 'Picture';

  // MetaPicture
  if (IsChecked($rbDirMetaPicture))
    return 'MetaPicture';

  // Unbekannt
  return '';
}

// ********************************************************
// DlsFill - Fülle DataList mit Objektinformationen
sub DlsFill
(
  aHdlDls           : int;    // Deskriptor der DataList
  aDirName          : alpha;  // Verzeichnisname
)
  local
  {
    tDirHdl         : int;    // Verzeichnis-Deskriptor
    tObjName        : alpha;  // Objektname
    tObjHdl         : int;    // Objektdeskriptor
    tLine           : int;    // Zeilen-Nummer
  }
{
  // Im Titel den Verzeichnis-Name ausgeben
  $C16.StoDir->wpCaption # aDirName;

  // DataList vorbereiten
  aHdlDls->wpAutoUpdate # false;
  aHdlDls->WinLstDatLineRemove(_WinLstDatLineAll);

  // Öffnen des Verzeichnisses
  tDirHdl # StoDirOpen(0, aDirName);

  if (tDirHdl != 0)
  {
    // Ersten Eintrag lesen
    tObjName # StoDirRead(tDirHdl, _StoFirst);

    // Solange Einträge vorhanden sind
    while (tObjName != '')
    {
      // Füge Eintrag zu Liste hinzu
      tLine # aHdlDls->WinLstDatLineAdd(tObjName, _WinLstDatLineLast);

      // Öffne Storage-Objekt für weitere Informationen
      tObjHdl # StoOpen(tDirHdl, tObjName);

      // Füge auch diese Informationen zur DataList hinzu
      if (tObjHdl != 0)
      {
        //ID
        aHdlDls->WinLstCellSet(tObjHdl->spID                  , 2, tLine);
        //Originialgröße
        aHdlDls->WinLstCellSet(tObjHdl->spSizeOrg             , 3, tLine);
        //Größe in der Datenbank
        aHdlDls->WinLstCellSet(tObjHdl->spSizeDba             , 4, tLine);
        //Erstellunsdatum
        aHdlDls->WinLstCellSet(FmtCalTime(tObjHdl->spCreated) , 5, tLine);
        //Bearbeitungsdatum
        aHdlDls->WinLstCellSet(FmtCalTime(tObjHdl->spModified), 6, tLine);
        //Erstellt von
        aHdlDls->WinLstCellSet(tObjHdl->spCreatedUser         , 7, tLine);
        //Bearbeitet von
        aHdlDls->WinLstCellSet(tObjHdl->spModifiedUser        , 8, tLine);
        tObjHdl->StoClose();
      }

      // Nächsten Verzeichnis-Eintrag lesen
      tObjName # StoDirRead(tDirHdl, _StoNext);
    }

    // Verzeichnis schliessen
    tDirHdl->StoClose();
  }

  // DataList-Ausgabe aktivieren
  aHdlDls->wpAutoUpdate # true;
}

// ********************************************************
// EvtInit - Initialisierung
sub EvtInit
(
	aEvt         : event     // Ereignis
) : logic
{
  // Fülle DataList
  DlsFill($dlsObj, GetStoDirName());
	return (true);
}

// ********************************************************
// EvtClicked - Checkbox wurde gedrückt
sub EvtClicked
(
	aEvt         : event     // Ereignis
) : logic
{
  // Fülle DataList
  DlsFill($dlsObj, GetStoDirName());
	return (true);
}

// ********************************************************
// main - Hauptprozedur
main ()
{
  WinDialog('C16.StoDir', _WinDialogCenter);
}