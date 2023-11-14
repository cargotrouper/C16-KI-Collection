@A+
//****************************************************************
//* C16_Info
//                    OHNE E_R_G
//*  Diese Prozedur beinhaltet Funktionen für das Infofenster.
//*
//*
//****************************************************************
//
//  Subprozeduren
//    SUB Init(aEvt : event)
//    SUB Refresh(aEvt : event) : logic
//    SUB EvtPageSelect(	aEvt : event; 	aPage : int; 	aSelecting : logic) : logic
//    SUB Abmelden(aEvt : event) : logic
//
//================================================================
@I:def_global

define begin
//  cVERSION  : '1.012'   // 1. + (Jahr-7) + Monat z.B. 1.012 = Dez.2007
end

//****************************************************************
//  Initialisierung
//
//****************************************************************
sub Init(
  aEvt : event
)
local begin
  Erx                 : int;
  SubRelease          : alpha;        // Unterrelease
  vUser               : int;
  vUserCount          : int;
  tText               : alpha;
  vMinuten            : int;
  vTxtHdl             : int;
  vVersion            : alpha(200);
  vA                  : alpha;
  vJob,vBetrieb,vSoa  : int;
end;
begin

//  if(KFG.lWinXpTheme) begin
    $nbInfo->wpStyleTab # _WinStyleTabTheme;
//  end;

  vTxtHdl # TextOpen(16);
  Erx # TextRead(vTxtHdl, '!VERSION',0);
  if (Erx<=_rLocked) then begin
    vVERSION # TextLineRead(vTxtHdl,1,0);
    // 21.10.2020 AH:
    if (Set.SQL.Database<>'') and (Set.SQL.Instance<>'') and (Set.SQL.PrintsrvURL<>'') then begin
      vA # Lib_DotNetServices:Version('');    // Versionsnr. in GV.Alpha.30
      vVersion # vVersion + ', PS '+GV.Alpha.30;
    end;
  end;
  Erx # TextRead(vTxtHdl, '!Lizenz-Info',0);
/** z.B.
SoaServer: 1
Betrieb: 4
JobServer: 2
User: 4
mit Workflow-Modul
mit Controlling-Modul
mit Lieferantenerklärung-Modul
***/
  if (Erx<=_rLocked) then begin
    Liz_Data:UserCount(var vUser, var vJob, var vBetrieb, var vSoa);
    $lb.LicInfo1->wpcaption # TextLineRead(vTxtHdl,1,0)+' ('+aint(vSoa)+')';
    $lb.LicInfo2->wpcaption # TextLineRead(vTxtHdl,2,0)+' ('+aint(vBetrieb)+')';
    $lb.LicInfo3->wpcaption # TextLineRead(vTxtHdl,3,0)+' ('+aint(vJob)+')';
    $lb.LicInfo4->wpcaption # TextLineRead(vTxtHdl,4,0)+' ('+aint(vUser)+')';
    $lb.LicInfo5->wpcaption # TextLineRead(vTxtHdl,5,0);
    // 10.09.2021 AH:
    $lb.LicInfo6->wpcaption # TextLineRead(vTxtHdl,6,0);
    $lb.LicInfo7->wpcaption # TextLineRead(vTxtHdl,7,0);
    $lb.LicInfo8->wpcaption # TextLineRead(vTxtHdl,8,0);
  end;
  TextClose(vTxtHdl);

  // Informationen über die Datenbank
  $lbDbaVersion->wpCaption # vVERSION;

//  $lbDbaName->wpCaption      # DbaName(_DbaAreaName);
//  $lbDbaSize->wpCaption      # CnvAI(DbaInfo(_DbaAreaSize))+' KB';
//  $lbDbaSizeEmpty->wpCaption # CnvAI(DbaInfo(_DbaAreaFree))+' KB'

  // Informationen über CONZEPT 16
  SubRelease # CnvAI(DbaInfo(_DbaClnRelRev));
  if (StrLen(SubRelease)=1) then
    SubRelease # '0'+SubRelease;
//  $lbDbaClient->wpCaption # CnvAI(DbaInfo(_DbaClnRelMaj))+'.'+
//                            CnvAI(DbaInfo(_DbaClnRelMin))+'.'+
//                            SubRelease;
  SubRelease # CnvAI(DbaInfo(_DbaSrvRelRev));
  if (StrLen(SubRelease)=1) then
    SubRelease # '0'+SubRelease;
//  $lbDbaServer->wpCaption # CnvAI(DbaInfo(_DbaSrvRelMaj))+'.'+
//                            CnvAI(DbaInfo(_DbaSrvRelMin))+'.'+
//                            SubRelease;
//  $lbDbaClientLizenz->wpCaption # DbaLicense(_DbaClnLicense);
//  $lbDbaServerLizenz->wpCaption # DbaLicense(_DbaSrvLicense);

//  $Lb.UserMax->wpCaption # CnvAi(DbaInfo(_DbaUserLimit));
//  $Lb.UserIST->wpCaption # CnvAi(DbaInfo(_DbaUserCount));

  // Informationen über die Umgebung
  $lbSysOs->wpCaption # SysOs();
  $lbDbaUserProtocol->wpCaption # UserInfo(_UserProtocol, CnvIA(UserInfo(_UserCurrent)));
  $lbDbaUserAddress->wpCaption  # UserInfo(_UserAddress,  CnvIA(UserInfo(_UserCurrent)));
  $lbDbaUserSysName->wpCaption  # UserInfo(_UserSysName,  CnvIA(UserInfo(_UserCurrent)));
  $lbDbaWinScreen->wpCaption    # CnvAI(WinInfo(0,_WinScreenWidth))+
                                  ' x '+
                                  CnvAI(WinInfo(0,_WinScreenHeight));

  // Information über angemeldete Benutzer

  // Benutzerliste füllen

      $DL.Benutzer -> WinSearch('DL.Benutzer');


      vUser         # CnvIa(UserInfo(_UserNextId));
      vUserCount    # DbaInfo(_DbaUserCount);

      // Auswahlliste füllen
      FOR   vUser # CnvIa(UserInfo(_UserNextId))
      LOOP  vUser # CnvIa(UserInfo(_UserNextId,vUser))
      WHILE (vUser > 0) DO BEGIN


        // USersternchen setzen
        if (gUserId = vUser) then
          tText # '*' else tText # '';
        if ($DL.Benutzer->WinLstDatLineAdd(tText,_WinLstDatLineLast) <= 0) then begin
          // Fehlerbehandlung
        end;

        // Zeile erstellen
        tText # UserInfo(_UserName);
        // 29.01.2019 AH:
        if (Liz_data:IstThread(vUser)) then tText # '(SERVICEJOB '+tText+')';
        if ($DL.Benutzer->WinLstCellSet(tText,2,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // UserNummer Spalte Setzen
        tText # UserInfo(_UserNumber);
        if ($DL.Benutzer->WinLstCellSet(tText,3,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // ID Spalte Setzen
        tText # cnvai(vUser);
        if ($DL.Benutzer->WinLstCellSet(tText,4,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;


        // Login Spalte Setzen
        tText # UserInfo(_UserLoginDate) + ' / ' + UserInfo(_UserLoginTime) ;
        if ($DL.Benutzer->WinLstCellSet(tText,5,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // Letzte Anfrage
        tText # UserInfo(_UserLastReqDate) + ' / ' + UserInfo(_UserLastReqTime);
        if ($DL.Benutzer->WinLstCellSet(tText,6,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;


        // Idle seit
        vMinuten # CnvIa(UserInfo(_UserLastReq)) / 60;
        tText # CnvAi(vMinuten);

        if ($DL.Benutzer->WinLstCellSet(tText,7,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // Gruppe
        tText # UserInfo(_UserGroup);
        if ($DL.Benutzer->WinLstCellSet(tText,8,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // Windowslogin
        tText # UserInfo(_UserSysAccount);
        if ($DL.Benutzer->WinLstCellSet(tText,9,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // Rechnername
        tText # UserInfo(_UserSysName);
        if ($DL.Benutzer->WinLstCellSet(tText,10,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

        // Rechner IP
        tText # UserInfo(_UserAddress);
        if ($DL.Benutzer->WinLstCellSet(tText,11,_WinLstDatLineLast) = false) then begin
          // Fehlerbehandlung
        end;

      END;


  //

  // Schriftart des Fensters setzen
//  Gui_Com:FontSet(gFrmInfo);
end;

//****************************************************************
//  Refresh
//
//****************************************************************
sub Refresh(
  aEvt                  : event;        // Ereignis
) : logic

begin
  $DL.Benutzer->WinLstDatLineRemove(_WinLstDatLineAll);
  Call('C16_Info:Init',aEvt);
end;


//****************************************************************
//  EvtPageSelect
//
//****************************************************************
sub EvtPageSelect(
	aEvt         : event;    // Ereignis
	aPage        : int;      // Notebook-Seite
	aSelecting   : logic     // Seite aktiviert / deaktiviert
) : logic
local begin
  vTmp  : int;
end;
begin

  if (aPage->wpname='nbpCONZEPT16') and (aSelecting) then begin
    vTmp # WinOpen(_winc16info);//,_WinOpenDialog);
    if (vTmp>0) then begin
      vTmp->Windialogrun(_WinDialogCenter,gFrmMain);
      vTmp->WinClose();
    end;
    RETURN false;
  end;

	RETURN (true);
end;




//****************************************************************
//  Abmelden
//
//****************************************************************
sub Abmelden(
 aEvt                  : event;        // Ereignis
) : logic
local begin
  vID : alpha;
  vNr : alpha;
  vPW : alpha;
end;
begin
  if ($DL.Benutzer->WinLstCellGet(vID,4,_WinLstDatLineCurrent)) AND
     ($DL.Benutzer->WinLstCellGet(vNr,3,_WinLstDatLineCurrent)) then begin

    Dlg_Standard:Standard('Kennwort', var vPW, y);
    UserClear(cnvia(vID), cnvia(vNr),vPW);

    $DL.Benutzer->WinLstDatLineRemove(_WinLstDatLineAll);
    Call('C16_Info:Init',aEvt);

  end;

end;

//****************************************************************
//  MAIN
//
//****************************************************************
main begin
//  vTmp # WinOpen(_winc16info);//,_WinOpenDialog);
/*
  if (vTmp>0) then begin
    vTmp->Windialogrun(_WinDialogCenter,gFrmMain);
    vTmp->WinClose();
  end;
*/
  WinDialog('c16.Info',_WinDialogCenter,gFrmMain);
end;
