@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Update
//                      OHNE E_R_G
//  Info      Stellt die Verarbeitungslogik für den Download und Installation
//            von StahlControl Updates zur Verfügung
//
//
//  04.03.2009  ST  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cServer           : '217.86.132.27'           //'www.stahl-Control.eu'
  cServerPort       : 8080                //'8080 für Http,
  cUpdateFile       : 'update.txt'
  cDestinationPath  : '.\update\'
  CRLF              : strchar(13)+strchar(10)
end;



//========================================================================


//========================================================================
//  sub UpdateAvailable(  aConnectionType : alpha) : logic
//      Prüft ob ein Update zum Herunterladen vorliegt
//========================================================================
sub UpdateAvailable(
  aConnectionType : alpha;
  opt aDia   : int
) : logic
local begin
  vSocketConnection : int;   // Deskriptor zum Verbunden Socket
  vSckData          : int;   // Deskriptor der Daten-Verbindung

  vProgress         : int
end
begin



  if (aDia<>0) then begin
    vProgress # Winsearch(aDia,'Progress');
    vProgress->wpProgressPos # 0;
//    vProgress->wpProgressMax # aSize;
  end;

  // -----------------------------------------------------
  // Je nach Verbindungstyp die Updatedatei herunterladen
  // -----------------------------------------------------
  case aConnectionType of
    'HTTP': begin
      // Verbindung herstellen
      vSocketConnection # Lib_HTTP:Connect(cServer,cServerPort);
      if (vSocketConnection < 0) then begin
        aDia->WinClose();
        RETURN false;
      end;


      return true;
     end;


    'FTP' : begin   return true;  end
  end;

  // -----------------------------------------------------
  // Update.txt ist hier gelesen und kann entsprechend geparsed werden


  return true;

end;


//========================================================================
//  sub GetFiles(  aConnectionType : alpha) : logic
//      Lädt alle Dateien eines Updates herunter
//========================================================================
sub DownloadFiles(
  aConnectionType : alpha;
  aPath           : alpha;
  opt aDia        : int
) : logic
begin


  // Je nach Verbindungstyp alle Dateien herunterladen
  case aConnectionType of
    'HTTP': begin   return true;  end;
    'FTP' : begin   return true;  end
  end;

  // Alle Dateien sind unten, oder nicht
  if (true) then
    return true
  else
    return false;

end;




//========================================================================
//  main
//    Steuert die Updatedatelogik
//========================================================================
main
local begin
  vConnectionType   : alpha;   // Verbindungstyp

  vDia              : int;    // Deskriptor für den ProgressBar
  vHdl,vHdl2        : int;    // Universaldesktiptoren
end
begin

  if Rechte[Rgt_Db_Updates] then begin

    vConnectionType # 'HTTP';   // Type der Verbindung entweder 'HTTP' oder 'FTP'


    // Anmeldedaten lesen



    // -----------------------------------------------------
    // Progressbar für die Updateprüfung
    // -----------------------------------------------------
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
    if (vDia=0) then RETURN;

    vHdl  # Winsearch(vDia,'Label1');
    vHdl2 # Winsearch(vDia,'Progress');
    vHdl2->wpProgressPos # 0;
    vHdl2->wpProgressMax # 100;
    vHdl->wpcaption # 'Suche nach neuen Updates...';
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);

    // -----------------------------------------------------
    // Updateprüfung und Download
    // -----------------------------------------------------
    if (UpdateAvailable(vConnectionType,vDia)) then begin

      // Falls Ja, dann Update herunterladen
      if (DownloadFiles(vConnectionType,cDestinationPath,vDia)) then begin

        // Wenn fertig, dann fertig zum installieren


      end;

    end;

  end;
  // Updatevorgang erfolgreich abgeschlossen


end;

//========================================================================