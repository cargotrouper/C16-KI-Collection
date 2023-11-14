@A+
//==== Business-Control ===================================================
//
//  Prozedur    Lib_Progress
//                OHNE E_R_G
//  Info
//        Bibliotheksfunktionen für die Anzeige von Fortschrittsbalken.
//        Siehe Beispielverwendung in dem MAIN Block.
//
//  13.04.2010  PW  Erstellung der Prozedur
//  18.10.2010  AI  Workaround für glboale Variablen von WindowBoonus
//  11.07.2012  MS  Anzeige der Progressbar _WinDialogAlwaysOnTop
//  05.11.2012  ST  Fix bei Start ohne gFrmMain gesetzt zu haben
//  07.11.2013  AH  Progressbar nicht im Vordergund
//  24.04.2014  AH  Captionfelder auf 4000 verlängert
//  28.02.2018  ST  Winsleep 1 bei Step durch Jobserver
//
//  Subprozeduren
//    sub Init ( opt aCaption : alpha; opt aMax : int ) : handle
//    sub SetMax ( aDlg : handle; aMax : int )
//    sub Reset ( aDlg : handle; opt aCaption : alpha; opt aMax : int )
//    sub Step ( aDlg : handle; opt aCount : int ) : logic
//    sub Term ( aDlg : handle )
//    sub SetLabel ( aDlg : handle; opt aCaption : alpha )
//=========================================================================
@I:Def_Global

declare SetMax(aDlg  : handle; aMax  : int)

//=========================================================================
// Init
//        Fortschrittsanzeige initialisieren
//=========================================================================
sub Init (
  opt aCaption  : alpha(4000);
  opt aMax      : int;
  opt aNoCancel : logic) : handle
local begin
  vDlg  : handle;
  vLbl  : handle;
  vOpt  : int;
end;
begin
  // 26.10.2021 AH
  if ( gUsername = 'SOA_SYNC' ) then RETURN 0;
  if ( gUsername = 'SOA_JOB' ) then RETURN 0;

  //if ( gUsername = 'PW' ) then
  //  _app->wpWaitCursor # false;

  vDlg # WinOpen( 'Dlg.Progress', _winOpenDialog );

  if ( vDlg = 0 ) then
    RETURN vDlg;

  if (aNoCancel) then begin
    vLbl # vDlg->WinSearch( 'Bt.Abbruch' );
    vLbl->wpvisible # false;
    vLbl->wpDisabled # true;
  end;

  // Caption
  if ( aCaption = '' ) then
    aCaption # Translate( 'Fortschritt...' );

  vLbl # vDlg->WinSearch( 'Label1' );
  vLbl->wpCaption # aCaption;

  // Progress bar
  if ( aMax = 0 ) then
    aMax # 100;

  if (aMax=-1) then begin
    vLbl # Winsearch(vDlg,'Progress');
    vLbl->wpvisible # false;
    vLbl # Winsearch(vDlg,'Bt.Abbruch');
    vLbl->wpvisible # false;
  end;

  SetMax(vDlg, aMax);

  // Dialog anzeigen


  //Probleme, wenn Druckauswahldialog genutz wird, dann APPOFF und hier APPON
  if (winfocusget()=0) and (Set.DruckVS.imHGrund) then begin
    vOpt # _winDialogAsync | _WinDialogNoActivate | _winDialogCenter;
//debugx(aint(winfocusget() ));
  end
  else begin
    vOpt # _winDialogAsync | _winDialogCenter;// | _WinDialogAlwaysOnTop;
//debugx(aint(winfocusget() ));
  end;

  // ST 2012-11-05 Fix  gFrmMain KANN 0 sein, da die kritische Prozedurausführung vor allem anderen aufgerufen wird.
  if (gFrmMain > 0) then
    vDlg->WinDialogRun(vOpt, gFrmMain);
  else
    vDlg->WinDialogRun(vOpt);


  RETURN vDlg;
end;


//=========================================================================
// SetMax
//        Fortschrittsanzeige Max setzen
//=========================================================================
sub SetMax(
  aDlg  : handle;
  aMax  : int)
local begin
end;
begin
  if ( aDlg = 0 ) then
    RETURN;

  // Progress bar
  if ( aMax = 0 ) then
    aMax # 100;

  $Progress->wpProgressPos # 0;
  $Progress->wpProgressMax # aMax;
end;


//=========================================================================
// Reset
//        Fortschrittsanzeige mit neuem Label zurücksetzen
//=========================================================================
sub Reset (
  aDlg          : handle;
  opt aCaption  : alpha(4000);
  opt aMax      : int)
local begin
  vLbl : handle;
end;
begin
  if ( aDlg = 0 ) then
    RETURN;

  // Caption
  if ( aCaption = '' ) then
    aCaption # Translate( 'Fortschritt...' );

  vLbl # aDlg->WinSearch( 'Label1' );
  vLbl->wpCaption # aCaption;

  // Progress bar
  if ( aMax = 0 ) then
    aMax # 100;

  SetMax(aDlg, aMax);
end;


//=========================================================================
// Term
//        Fortschrittsanzeige terminieren
//=========================================================================
sub Term ( aDlg : handle )
local begin
  vMurx : logic;
end;
begin

  // ST 2012-11-05 Fix, gFrmMain KANN null sein
  if (gFrmMain > 0) then begin

    if (Winfocusget()<>0) then begin
//debugx('');
      // WORKAROUND, damit andere App nicht den Fokus bekommt (bei Listen)
      if (gFrmMain->wpdisabled) then begin
    //    gFrmMain->wpdisabled # false;
    // Frame in den Vordergrund holen
//debugx('');
        gFrmMain->WinUpdate(_WinUpdActivate);
        vMurx # y;
      end;
    end;
  end;

  if ( aDlg != 0 ) and ( HdlInfo( aDlg, _hdlExists ) = 1 ) then
    aDlg->WinClose();

//  if (vMurx) then begin
//    gFrmMain->wpdisabled # true;
//  end;

  // WORKAROUND: Async Dialoge schliessen versprint die globalen Variablen!
  if (gMDI<>0) then
    if (gMDI->wpcustom<>'') and (gMDI->wpcustom<>cnvai(VarInfo(WindowBonus))) then
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

end;


//=========================================================================
// Step
//        Fortschritt erhöhen; gibt Fortsetzungsstatus zurück
//=========================================================================
sub Step (
  aDlg        : handle;
  opt aCount  : int ) : logic
local begin
  vBtn : handle;
end;
begin
  if ( aDlg = 0 ) then
    RETURN true;

  if ( aCount = 0 ) then
    aCount # 1;

  try begin
    vBtn # aDlg->WinSearch( 'Bt.Abbruch' );
    vBtn->wpVisible          # !_app->wpWaitCursor;
    $Progress->wpProgressPos # $Progress->wpProgressPos + aCount;
  end;
  // 27.08.2019 AH mit try
  if (errget() <> _rOk) then begin
    ErrSet(_rOK);
    RETURN true;
  end;


  if (gUsergroup = 'JOB-SERVER') then
    Winsleep(1);

  if ( aDlg->WinDialogResult() != _winIdCancel ) then begin
    RETURN true;
  end
  else begin
    aDlg->Term();
    RETURN false;
  end;
end;


//=========================================================================
// StepTo
//        Fortschritt auf festen Wert erhöhen
//=========================================================================
sub StepTo (
  aDlg    : handle;
  aValue  : int ) : logic
begin
  if ( aDlg = 0 ) then
    RETURN true;

  $Progress->wpProgressPos # aValue;
  $Bt.Abbruch->wpVisible   # !_app->wpWaitCursor;

  if (gUsergroup = 'JOB-SERVER') then
    Winsleep(1);

  if ( aDlg->WinDialogResult() != _winIdCancel ) then
    RETURN true;
  else begin
    aDlg->Term();
    RETURN false;
  end;
end;


//=========================================================================
// SetLabel
//        Fortschrittsanzeige mit neuem Label zurücksetzen
//=========================================================================
sub SetLabel (
  aDlg          : handle;
  opt aCaption  : alpha(4000))
local begin
  vLbl : handle;
end;
begin
  if ( aDlg = 0 ) then
    RETURN;

  // Caption
  if ( aCaption = '' ) then
    aCaption # Translate( 'Fortschritt...' );

  vLbl # aDlg->WinSearch( 'Label1' );
  vLbl->wpCaption # aCaption;
end;


//=========================================================================
// MAIN
//        Demoaufruf
//=========================================================================
MAIN
local begin
  vProgress : handle;
  vI        : int;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  // ...und setzen
  gUserName # 'ME';


  // Einfache Verwendung
  _app->wpWaitCursor # false;
  vProgress # Lib_Progress:Init();

  FOR  vI # 0;
  LOOP vI # vI + 1;
  WHILE ( vI <= 100 ) and ( vProgress->Lib_Progress:Step() ) DO BEGIN
    SysSleep( 200 );
  END;

  vProgress->Lib_Progress:Term();
  _app->wpWaitCursor # false;


  // Komplexere Verwendung
  vProgress # Lib_Progress:Init( 'Schritt 1/2...', 300 );

  FOR  vI # 0;
  LOOP vI # vI + 1;
  WHILE ( vI <= 300 ) and ( vProgress->Lib_Progress:Step() ) DO BEGIN
    SysSleep( 50 );
  END;

  vProgress->Lib_Progress:Reset( 'Schritt 2/2...', 100 );

  FOR  vI # 0;
  LOOP vI # vI + 1;
  WHILE ( vI <= 100 ) and ( vProgress->Lib_Progress:Step() ) DO BEGIN
    SysSleep( 200 );
  END;

  vProgress->Lib_Progress:Term();
end;

//=========================================================================
