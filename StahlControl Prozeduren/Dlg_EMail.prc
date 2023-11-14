@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_EMail
//                    OHNE E_R_G
//  Info
//
//
//  02.04.2012  MS  Erstellung der Prozedur
//  10.04.2012  MS  Anhaenge hinzugefuegt
//  10.09.2013  ST  Textbausteine aus Textvorlagen "M" hinzugefügt
//  07.03.2014  AH  Email wird in Aktiivitäten vermekrt
//  06.05.2015  AH  Umbau für SMTP
//  12.05.2015  AH  "SendPDF"
//  28.03.2020  AH  Mailfenster (z.B: Rundbriefe) gehen über Outlook NICHT per SMTP
//  05.04.2022  AH  ERX
//  2023-05-02  AH  "SendMail" kann abgespeicherte HTMLs versenden
//  2023-06-01  AH  OAUTH implementiert
//
//
//  Subprozeduren
//    SUB SendPdf(aEMA : alpha(1000); aBetreff : alpha(1000); aPath : alpha(4000));
//    SUB ReplaceWildcards(var aTxt : int; aRecipient : int) : int;
//    SUB InsertMailToList(aMailList : int; aFile : int) : logic;
//    SUB GetEMailList(var aMailList : int; aFile : int) : int;
//    SUB SmtpMail(aTxtPlain : int; aTxtHTML : int; aTO : alpha(1000); aBetreff : alpha(4000); aAttachDL : int) : int;
//    SUB HTMLMail(aTxt : int; aTO : alpha; aBetreff : alpha(4000); aAttachDL : int) : int;
//
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtLstDataInit (aEvt : event; aID : int) : logic
//    SUB EvtKeyItem(aEvt : event;aKey : int; aID : int) : logic;
//    SUB EvtMouseItem (aEvt : event; aButton : int; aHitTest : int; aItem : int; aId : int) : logic
//    SUB InsertFileToDataList(aFilename : alpha(4000)) : logic;
//    SUB EvtDropEnter(aEvt : event; aDataObject  : int; aEffect  : int) : logic
//    SUB EvtDrop(aEvt : event;	aDataObject  : int;	aDataPlace   : int;	aEffect      : int;	aMouseBtn    : int) : logic
//    SUB EvtDragTerm(aEvt : event;	aDataObject : int; aEffect : int) : logic
//
//    sub Auswahl_EvtMouseItem ( aEvt : event; aButton : int; aHitTest : int; aItem : int; aId : int ) : logic
//    sub Auswahl_EvtKeyItem ( aEvt : event; aKey : int; aId : int ): logic
//
//========================================================================
@I:Def_Global

define begin
  _ComCall    ( aHdl, aName )         : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComCall( aName ); end;
  _ComCall2   ( aHdl, a,b)            : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComCall( a,b ); end;
  _ComPropSet ( aHdl, aName, aValue ) : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComPropSet( aName, aValue ); end;
  _ComPropGet ( aHdl, aName, aValue ) : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComPropGet( aName, aValue ); end;

  // OlItemType enumeration
  olMailItem :  0
end

local begin
  gCount      : int;
  gMailList   : int;
  gTextList   : int;
end;

declare InsertMailToList(aMailList : int; aFile : int) : logic;
declare GetEMailList(var aMailList : int; aFile : int) : int;
declare SendMail(aRecipient : int; opt aEMA : alpha(4000); opt aOutlook : logic) : logic;
declare InsertFileToDataList(aFilename : alpha(4000)) : logic;

// Drag and Drop
declare CreateName(aFile : int) : alpha;

//========================================================================
// MAIN
//
//========================================================================
MAIN(
  aFile         : int;
  opt aTxt      : int;
);
local begin
  vWin    : int;
  vCount  : Int;
  vHdl    : int;
end
begin
if (gfrmMain<>0) then gFrmMain->wpDisabled # true;  // 2023-04-06 AH

  if((Mode = c_ModeList) and (aFile <> 0)) then
    RecRead(aFile, 0, 0, gZLList->wpdbrecid); // focusierten Datensatz lesen

  gCount # GetEMailList(var gMailList, aFile);
  vWin # WinOpen('Dlg.Email', _WinOpenDialog);
  
  // 28.02.2019
  if (aTxt<>0) then begin
    vHdl # Winsearch(vWin, 'RTFEdit');

//      gEdText->WinUpdate(_WinUpdObj2Buf);
//      gEdRtf->WinRtfLoad(_WinStreamBufText, 0, gBufText);
    vHdl->WinRtfLoad(_WinStreamBufText, 0, aTxt);
  end;

  if (gUsername='AH') then begin
    vHdl # Winsearch(vWin, 'bt.SaveHtml');
    vHdl->wpVisible # true;
  end;
  
  WinDialogRun(vwin, _WinDialogcreatehidden | _WinDialogCenterScreen);
  WinClose(vWin);

  if (gFrmMain<>0) then gFrmMain->wpdisabled # false; // 2023-04-06 AH
  
end;


//========================================================================
//  SendPDF
//========================================================================
Sub SendPDF(
  aEMA      : alpha(1000);
  aBetreff  : alpha(1000);
  aPath     : alpha(4000)
);
local begin
  vDlg      : int;
  vHdl      : int;
end;
begin

  vDlg # WinOpen('Dlg.Email', _WinOpenDialog);
  vHdl # vDlg->WinSearch('edEmpfaenger')
  if (vHdl<>0) then vHdl->wpcaption # aEMA;

  vHdl # vDlg->WinSearch('edBetreff')
  if (vHdl<>0) then vHdl->wpcaption # aBetreff;

  InsertFileToDataList(aPath);

  WinDialogRun(vDlg, _WinDialogcreatehidden | _WinDialogCenterScreen);
  WinClose(vDlg);
end;


//=========================================================================
//  ReplaceWildcards
//
//=========================================================================
sub ReplaceWildcards(
  var aTxt    : int;
  aRecipient  : int;
) : int;        // DATEI
local begin
  vTxt          : int;
  vBriefanrede  : alpha;
  vAnrede       : alpha;
  vName         : alpha;
  vZusatz       : alpha;
  vDatei        : int;
  vA            : alpha(4000);
  vI            : int;
  vFull         : alpha(4000);
end;
begin
  /*** Platzhalter ***
    @@BRIEFANREDE
    @@ANREDE
    @@NAME
    @@ZUSATZ
  ***/

  vBriefanrede # '';
  vAnrede      # '';
  vName        # '';
  vZusatz      # '';
  if (aRecipient <> 0) then begin
    if(RecRead(cnvIA(aRecipient -> spCustom), 0, 0, aRecipient->spID) <= _rLocked) then begin     // Empfaenger Adresse holen
      case (Lib_Strings:AlphaToInt(aRecipient -> spCustom)) of
        100 : begin // Adressen
          vBriefanrede  # Adr.Briefanrede;
          vAnrede       # Adr.Anrede;
          vName         # Adr.Name;
          vZusatz       # Adr.Zusatz;
          vDatei        # 100;
        end;

        102 : begin // Ansprechpartner
          vBriefanrede  # Adr.P.Briefanrede;
          vAnrede       # Adr.P.Titel;
          vName         # Adr.P.Name;
          vZusatz       # '';
          vDatei        # 102;
        end;
      end; // case
    end;
  end;

  if (vAnrede=*^'HERR*') then begin
    vFull # 'Sehr geehrter '+vAnrede+' '+vName+',';
  end
  else if (vAnrede=*^'FRAU*') then begin
    vFull # 'Sehr geehrte '+vAnrede+' '+vName+',';
  end;
  if (vFull='') then begin
    Msg(99,'Keine Anrede bei '+vName,0,0,0)
  end

  vTxt # TextOpen(20);

  FOR vI # TextInfo(aTxt,_textlines)
  LOOP dec(vI);
  WHILE (vI > 0) do begin
    vA # TextLineRead(aTxt, vI, 0);
    //vA # Str_ReplaceAll(vA, '@@@ANREDE','HALLO HERR WALTER');
    vA # Str_ReplaceAll(vA, '@@FULL', vFull);
    vA # Str_ReplaceAll(vA, '@@BRIEFANREDE', vBriefanrede);
    vA # Str_ReplaceAll(vA, '@@ANREDE'     , vAnrede);
    vA # Str_ReplaceAll(vA, '@@NAME'       , vName);
    vA # Str_ReplaceAll(vA, '@@ZUSATZ'     , vZusatz);
    TextLineWrite(vTxt, 1, vA, _TextLineInsert | _TextNoLinefeed);
  END;

  TextClose(aTxt);

  aTxt # vTxt;

  RETURN vDatei;
end;


//=========================================================================
// InsertMailToList
//
//=========================================================================
sub InsertMailToList(
  aMailList : int;
  aFile     : int) : logic;
local begin
  vEMail  : alpha;
  vName   : alpha;
  vItem   : handle;
end
begin
  vEMail # '';
  case (aFile) of
    100 :  begin
        vEMail  # Adr.EMail;    // Adressen
//vEMail # 'AH@stahl-control.de';
        vName   # Adr.Stichwort;
      end;
    102 :  begin
        vEMail  # Adr.P.EMail;  // Ansprechpartner
//vEMail # 'AH@stahl-control.de';
        vName   # Adr.P.Vorname;
        if (vName<>'') then vName # vName + ' ' +Adr.P.Name;
        else vName # Adr.P.Name;
        if (vName='') then vName # Adr.P.Stichwort;
      end;
  end; // case

  vItem # CteOpen( _cteItem );
  if (vItem = 0) then
    RETURN false;

  vItem->spName   # vEMail+'|'+vName;
  vItem->spCustom # cnvAI(aFile);
  vItem->spId     # RecInfo(aFile, _RecId);

  if (aMailList -> CteInsert(vItem)) then // Einsortieren
    RETURN true;
  else
    RETURN false;
end;


//=========================================================================
// GetEMailList
//
//=========================================================================
sub GetEMailList(
  var aMailList : int;
  aFile         : int) : int;
local begin
  Erx       : int;
  vItem     : int;
  vTree     : int;
  vMFile    : int;
  vMID      : int;
end
begin
  if(aMailList = 0) then
    aMailList # CteOpen(_CteTreeCI);    // Rambaum anlegen

  if(aFile = 0) then
    RETURN 0;

  if(Lib_Mark:Count(aFile) != 0) then begin
    FOR vItem # gMarkList->CteRead(_CteFirst);
    LOOP vItem # gMarkList->CteRead(_CteNext, vItem);
    WHILE (vItem > 0) DO BEGIN
      Lib_Mark:TokenMark(vItem, var vMFile, var vMID);
      if (vMFile != aFile) then
        CYCLE;
      Erx # RecRead(aFile, 0, 0, vMID);  // Satz holen
      if (Erx >_rLocked) then
        RecBufClear(aFile);

      InsertMailToList(aMailList, aFile);
    END;
  end
  else
    InsertMailToList(aMailList, aFile);

  RETURN CteInfo(aMailList, _cteCount); // Anzahl der Mailadr.
end;


//========================================================================
//  SmtpMail
//
//========================================================================
sub SmtpMail(
  aTxtPlain   : int;
  aTxtHTML    : int;
  aTO         : alpha(1000);
  aBetreff    : alpha(4000);
  aAttachDL   : int;
) : int;
local begin
  vErr        : int;
  vFromEMA    : alpha;
  vFromName   : alpha;
  vToEMA      : alpha;
  vToName     : alpha;
  vTyp        : int;
  vServer     : alpha;
  vPort       : int;
  vAuth       : alpha;
  vAuthPW     : alpha;
  vTenantID   : alpha;
  vClientID   : alpha;
end;
begin
  // Typ, Server, Port, Auth, AuthPW, SenderEMA, Sendername
  if (Lib_Strings:Strings_Count(Set.Email.SMTP,'|')<6) then RETURN -1;

  // Empfänger benennen...
  if (StrFind(aTO,'|',0)>0) then begin
    vToEMA  # Str_token(aTO,'|',1);
    vToName # Str_token(aTO,'|',2);
  end
  else begin
    vToEMA  # aTO;
  end;

  // Typ bestimmen...
  case Strcnv(Str_Token(Set.Email.SMTP,'|',1), _Strupper) of
    'SMTP'    : vTyp # _Mailsmtp;
    'SMTPTLS' : vTyp # _MailsmtpTls;
    'SMTPS'   : vTyp # _MailsmtpS;
    'OAUTH'   : begin
      vTyp      # _MailsmtpTls;
      vTenantID # 'X';
    end;
    otherwise   vTyp # _Mailsmtp;
  end;
  vServer  # Str_Token(Set.Email.SMTP,'|',2);
  vPort    # cnvia(Str_Token(Set.Email.SMTP,'|',3));

  // ggf. Authentfifation setzen...
  vAuth     # Str_Token(Set.Email.SMTP,'|',4);
  vAuthPW   # Str_Token(Set.Email.SMTP,'|',5);

  // 2023-05-31 AH
  if (vTenantID<>'') then begin
    vTenantID       # Str_Token(Set.Email.SMTP,'|',5);
    vClientID       # Str_Token(Set.Email.SMTP,'|',6);
    vAuthPW         # '';
    // Sender benennen...
    vFromEMA  # Str_Token(Set.Email.SMTP,'|',7);
    vFromName # Str_Token(Set.Email.SMTP,'|',8);
  end
  else begin
    // Sender benennen...
    vFromEMA  # Str_Token(Set.Email.SMTP,'|',6);
    vFromName # Str_Token(Set.Email.SMTP,'|',7);
  end;

  
  if (vFromEMA='*') then begin
    vFromEMA # Usr.Email;
  end;
  if (vFromName='*') then begin
    vFromName # Usr.Vorname;
    if (vFromName<>'') then vFromName # vFromName + ' '+ Usr.Name
    else vFromName # Usr.Name;
  end;

//debugx(vServer+aint(vPort)+':'+vAuth+vAuthPW+' '+vFromEMA+'('+vFromName+') -> '+vToEMa+'('+vToName+')  '+aBetreff);

  if (vTenantID<>'') then begin
    vErr # Lib_SMTP:Mail.OAuth.Send(vTyp, vServer, vPort, vAuth, vTenantID, vClientID,
      vFromEMA, vFromName,
      vToEMA, vToName,
      aBetreff, aTxtPlain, aTxtHTML, aAttachDL);
    end
  else begin
    vErr # Lib_SMTP:Mail.Send(vTyp, vServer, vPort, vAuth, vAuthPW,
      vFromEMA, vFromName,
      vToEMA, vToName,
      aBetreff, aTxtPlain, aTxtHTML, aAttachDL);
  end;
  
  RETURN vErr;
end;


//========================================================================
//  SmtpMail2
//
//========================================================================
sub SmtpMail2(
  aFromEma    : alpha(4000);
  aFromName   : alpha(4000);
  aTxtPlain   : int;
  aTxtHTML    : int;
  aTO         : alpha(1000);
  aBetreff    : alpha(4000);
  aAttachDL   : int;
  aBCC        : alpha(4000);
  opt aCC     : alpha(4000)) : int;
local begin
  vErr        : int;
  vFromEMA    : alpha;
  vFromName   : alpha;
  vToEMA      : alpha;
  vToName     : alpha;
  vTyp        : int;
  vServer     : alpha;
  vPort       : int;
  vAuth       : alpha(200);
  vAuthPW     : alpha;
  vTenantID   : alpha;
  vClientID   : alpha;
end;
begin
  // Typ, Server, Port, Auth, AuthPW, SenderEMA, Sendername
  if (Lib_Strings:Strings_Count(Set.Email.SMTP,'|')<6) then RETURN -1;

  // Empfänger benennen...
  if (StrFind(aTO,'|',0)>0) then begin
    vToEMA  # Str_token(aTO,'|',1);
    vToName # Str_token(aTO,'|',2);
  end
  else begin
    vToEMA  # aTO;
  end;

  // Typ bestimmen...
  case Strcnv(Str_Token(Set.Email.SMTP,'|',1), _Strupper) of
    'SMTP'    : vTyp # _Mailsmtp;
    'SMTPTLS' : vTyp # _MailsmtpTls;
    'SMTPS'   : vTyp # _MailsmtpS;
    'OAUTH'   : begin
      vTyp      # _MailsmtpTls;
      vTenantID # 'X';
    end;
    otherwise   vTyp # _Mailsmtp;
  end;
  vServer  # Str_Token(Set.Email.SMTP,'|',2);
  vPort    # cnvia(Str_Token(Set.Email.SMTP,'|',3));

  // ggf. Authentfifation setzen...
  vAuth     # Str_Token(Set.Email.SMTP,'|',4);
  vAuthPW   # Str_Token(Set.Email.SMTP,'|',5);

  // Sender benennen...
  vFromEMA  # aFromEma;
  vFromName # aFromName;
//debugx(vFromEma+'+'+vFromName+' -> '+vToEma+'+'+vToName+' -> '+aBcc);

  // 2023-05-31 AH
  if (vTenantID<>'') then begin
    vTenantID       # Str_Token(Set.Email.SMTP,'|',5);
    vClientID       # Str_Token(Set.Email.SMTP,'|',6);
    vAuthPW         # '';
  end;

  if (vTenantID<>'') then begin
    vErr # Lib_SMTP:Mail.OAuth.Send(vTyp, vServer, vPort, vAuth, vTenantID, vClientID,
      vFromEMA, vFromName,
      vToEMA, vToName,
      aBetreff, aTxtPlain, aTxtHTML, aAttachDL, aBcc, aCC);
  end
  else begin
    vErr # Lib_SMTP:Mail.Send(vTyp, vServer, vPort, vAuth, vAuthPW,
      vFromEMA, vFromName,
      vToEMA, vToName,
      aBetreff, aTxtPlain, aTxtHTML, aAttachDL, aBcc, aCC);
  end;

  RETURN vErr;
end;


//=========================================================================
// HTMLMail
//
//=========================================================================
sub HTMLMail (
  aTxt        : int;
  aTO         : alpha(1000);
  aBetreff    : alpha(4000);
  aAttachDL   : int) : int;
local begin
  vAppHdl       : handle;
  vMail         : handle;
  vHdl          : int;
  vA            : alpha(4000);
  vTxt          : int;
  vI            : int;
  vSig          : int;
//  vBetreff      : alpha;
//  vBriefanrede  : alpha;
//  vAnrede       : alpha;
//  vName         : alpha;
//  vZusatz       : alpha;
//  vDatei        : int;
  vFilename     : alpha;
end
begin

  if (StrFind(aTO,'|',0)>0) then
    aTO # Str_Token(aTO,'|',1);

  vAppHdl # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( vAppHdl = 0 ) then RETURN -1;

  vMail # vAppHdl->ComCall( 'CreateItem', olMailItem );

  _ComPropGet(vMail,'GetInspector',vSig);

  vMail->cpaTo  # aTO;    // Empfäenger EMA


//  if($Dlg.Email->WinSearch('edBetreff') <> 0) then // Betreff uebergeben
//    vBetreff # $edBetreff -> wpCaption;
  vMail->cpaSubject # aBetreff;

  vTxt # TextOpen(30);
  vMail->ComPropGetText('HTMLBody', vTxt);

  /*** Platzhalter ***
    @@BRIEFANREDE
    @@ANREDE
    @@NAME
    @@ZUSATZ
  ***/
/***

  ALLE VORHER SCHON GEMACHT

  vBriefanrede # '';
  vAnrede      # '';
  vName        # '';
  vZusatz      # '';
  if(aRecipient <> 0) then begin
    if(RecRead(cnvIA(aRecipient -> spCustom), 0, 0, aRecipient->spID) <= _rLocked) then begin     // Empfaenger Adresse holen
      case (Lib_Strings:AlphaToInt(aRecipient -> spCustom)) of
        100 : begin // Adressen
          vBriefanrede  # Adr.Briefanrede;
          vAnrede       # Adr.Anrede;
          vName         # Adr.Name;
          vZusatz       # Adr.Zusatz;
          vDatei        # 100;
        end;

        102 : begin // Ansprechpartner
          vBriefanrede  # Adr.P.Briefanrede;
          vAnrede       # Adr.P.Titel;
          vName         # Adr.P.Name;
          vZusatz       # '';
          vDatei        # 102;
        end;
      end; // case
    end;
  end;

  FOR vI # TextInfo(aTxt,_textlines)
  LOOP dec(vI);
  WHILE (vI > 0) do begin
    vA # TextLineRead(aTxt, vI, 0);
    //vA # Str_ReplaceAll(vA, '@@@ANREDE','HALLO HERR WALTER');
    vA # Str_ReplaceAll(vA, '@@BRIEFANREDE', vBriefanrede);
    vA # Str_ReplaceAll(vA, '@@ANREDE'     , vAnrede);
    vA # Str_ReplaceAll(vA, '@@NAME'       , vName);
    vA # Str_ReplaceAll(vA, '@@ZUSATZ'     , vZusatz);
    TextLineWrite(vTxt, 1, vA, _TextLineInsert | _TextNoLinefeed);
  END;
***/

  vMail->ComPropSetText('HTMLBody', aTxt);

  if (aAttachDL<>0) then begin
    FOR vI # 1 // Anhang aus Data-List loopen
    LOOP inc(vI)
    WHILE (vI <= WinLstDatLineInfo(aAttachDL, _WinLstDatInfoCount)) do begin
      WinLstCellGet(aAttachDL, vFilename, 2, vI);    // Zeile lesen
      _ComCall2(vMail, 'Attachments.Add', vFilename); // Datei anhaengen!
    END;
  end;

  if($cb.VorschauYN -> wpCheckState = _WinStateChkChecked) then // Vorschau?
    _ComCall(vMail, 'Display');
  else // KEINE VORSCHAU!
    _ComCall(vMail, 'Send');

  vAppHdl->ComClose();

  TextClose(vTxt);

/*** ALLE SPÄTER
  // 07.03.2014 AH: Aktivität eintragen
  Lib_Notifier:NewTermin('EMA', vBetreff, vBetreff, true);

  // Add User to TEM
  Usr_data:RecReadThisUser();
  //TeM_A_Data:New(800,'MAN', 0, true);
  TeM_A_Data:Anker(800, 'MAN', true);
//  if (vDatei=100) then TeM_A_Data:New(vDatei,'MAN', RecInfo(vDatei,_recID));
//  if (vDatei=102) then TeM_A_Data:New(vDatei,'MAN', RecInfo(vDatei,_recID));
  if (vDatei=100) then TeM_A_Data:Anker(vDatei, 'MAN', false, RecInfo(vDatei,_recID));
  if (vDatei=102) then TeM_A_Data:Anker(vDatei,'MAN', false, RecInfo(vDatei,_recID));
***/

  RETURN 0;
end;


//=========================================================================
// SendMail
//
//=========================================================================
sub SendMail(
  aRecipient      : int;
  opt aEMA        : alpha(4000);
  opt aOutlook    : logic;
  ) : logic;
local begin
  vEMail    : alpha;
  vItem     : handle;
  vTxtHTML  : int;
  vTxtPlain : int;
  vBetreff  : alpha(4000);
  vDatei    : int;
  vErr      : int;
  vEMA      : alpha(4000);
  vMem      : handle;
  vFile     : int;
  vI, vJ    : int;
end
begin

  vTxtHTML  # TextOpen(30);


  if (gUsername='AH') then begin
    if (Msg(99,'Unbenannt.htm nutzen?',_WinIcoQuestion, _WinDialogYesNo,2)=_winidyes) then begin
      // 2023-05-02 AH SPIELWIESE:
      vMem # MemAllocate(_MemAutoSize);
      vMem->spCharset # _CharsetC16_1252;
      vFile # FsiOpen('D:\DEBUG\Unbenannt.htm', _FsiStdRead);
      vI # vFile->FsiSize();
      vMem->spLen # 0;
      vJ # vFile->FsiReadMem(vMem, 1, vI);
      Fsiclose(vFile);
      Lib_texte:Mem_Win2Dos(var vMem);
      Lib_texte:ReadFromMem(vTxtHtml, vMem, 1, -1);
      MemFree(vMem);
      vDatei # ReplaceWildcards(var vTxtHTML, aRecipient);
    end;
  end;

  if (vFile=0) then begin
    Lib_Strings:RTFsaveHTML($RTFEdit, vTxtHTML);
    vDatei # ReplaceWildcards(var vTxtHTML, aRecipient);

    // HTML-Anfang schreiben
    vTxtHTML->TextLineWrite(1, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">', _TextLineInsert);
    vTxtHTML->TextLineWrite(2, '<HTML>', _TextLineInsert);
    vTxtHTML->TextLineWrite(3, '<BODY>', _TextLineInsert);

    // HTML-Ende schreiben
    vTxtHTML->TextLineWrite(vTxtHTML->TextInfo(_TextLines) + 1, '</BODY>', _TextLineInsert);
    vTxtHTML->TextLineWrite(vTxtHTML->TextInfo(_TextLines) + 1, '</HTML>', _TextLineInsert);
  end;
  
  vBetreff # $edBetreff->wpCaption;

  if (aRecipient<>0) then
    vEMA # aRecipient->spName
  else
    vEMA # aEMA;

  if (aOutlook=false) and (Set.Email.SMTP<>'') then begin
    vTxtPlain # TextOpen(30);
    $RTFEdit->WinRTFSave(_WinStreamBufText, _WinRTFSaveASCII, vTxtPlain);
    vErr # SmtpMail(vTxtPlain, vTxtHTML, vEMA, vBetreff, $DL.Anhang);
    TextClose(vTxtPlain);
  end
  else begin
    vErr # HTMLMail(vTxtHTML, vEMA, vBetreff, $DL.Anhang);
  end;
//debugx('');

  TextClose(vTxtHTML);


  if (vErr<>0) then begin
    WinDialogBox($Dlg.Email, 'Send E-Mail an '+vEMA, 'Error : ' + CnvAI(vErr, _FmtInternal), _WinIcoError,  _WinDialogOK, 1);
    RETURN false;
  end;


  // 07.03.2014 AH: Aktivität eintragen
  Lib_Notifier:NewTermin('EMA', vBetreff, vBetreff, true);

  // Add User to TEM
  Usr_data:RecReadThisUser();

  //TeM_A_Data:New(800,'MAN', 0, true);
  TeM_A_Data:Anker(800, 'MAN', true);
//  if (vDatei=100) then TeM_A_Data:New(vDatei,'MAN', RecInfo(vDatei,_recID));
//  if (vDatei=102) then TeM_A_Data:New(vDatei,'MAN', RecInfo(vDatei,_recID));
  if (vDatei=100) then TeM_A_Data:Anker(vDatei, 'MAN', false, RecInfo(vDatei,_recID));
  if (vDatei=102) then TeM_A_Data:Anker(vDatei,'MAN', false, RecInfo(vDatei,_recID));
//debugx('FERTIG');

  RETURN true;
end;


//========================================================================
// EvtInit
//
//========================================================================
Sub EvtInit(
  aEvt  : event;
) : logic
local begin
  Erx   : int;
  vItem : int;
  vHdl  : int;
  vA    : alpha;
end;
begin
  vHdl # $Dlg.Email->WinSearch('edEmpfaenger')
  if(vHdl <> 0) then
    vHdl -> wpCustom # cnvAI(gMailList);  // Handel der Liste im Custom merken

  RunAFX('Dlg.EMail.Init', '');

  if (gMailList<>0) then begin
    gCount #  CteInfo(gMailList, _cteCount); // Anzahl der Empfaenger in der Liste
    if(gCount > 1) then
      $edEmpfaenger -> wpCaption # AInt(gCount) + ' '+Translate('Empfänger');
    else if(gMailList <> 0) then begin
      vItem # Sort_ItemFirst(gMailList)
      if (vItem <> 0) then begin
        $edEmpfaenger -> wpCaption # Str_Token(vItem -> spName, '|',1);
      end;
    end;
  end;

  // ST 2013-09-06: Mögliche Texte einmalig ermitteln
  gTextList # CteOpen(_CteTreeCi);
  if (RecInfo(837,_RecCount) < 1000) then begin
    gTextList  # CteOpen(_CteTree);
    FOR   Erx # RecRead(837,1,_RecFirst);
    LOOP  Erx # RecRead(837,1,_RecNext);
    WHILE Erx <= _rLocked DO BEGIN
      if (StrFind(Txt.Bereichstring,'M',1) > 0) then
        gTextList->CteInsertItem(Txt.Bezeichnung, Txt.Nummer,Aint(Txt.Nummer));
    END;
  end;

end;



//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
	aEvt         : event;    // Ereignis
	aMenuItem    : int       // Auslösender Menüpunkt / Toolbar-Button
) : logic
local begin
  vHdl      : int;
  vTxt      : int;
  vPicPath  : alpha(256);
  vQ        : alpha;
  vTxtName  : alpha;
end;
begin

  case (aMenuItem->wpName) of
/*
    'Mnu.Ktx.InsertPic' : begin
      vPicPath # Lib_FileIO:FileIO(_WinComFileOpen, $Dlg.EMail, '', 'Bild-Dateien |*.bmp;*.gif;*.jpg;*.tif;*.png');
      if (vPicPath = '') then
        RETURN false;
      aEvt:Obj -> WinRtfPicInsertName('*' + vPicPath);
    end;
*/
    'Mnu.Ktx.Workbench.Del' : begin
      if ($DL.Anhang->wpcurrentint <> 0) then begin
        $DL.Anhang->WinLstDatLineRemove(_WinLstDatLineCurrent);
      end;
      RETURN true;
    end;

    'Mnu.Ktx.Workbench.DelAll' : begin
      $DL.Anhang->WinLstDatLineRemove(_WinLstDatLineAll);
      RETURN true;
    end;

    'Mnu.Ktx.Briefanrede', 'Mnu.Ktx.Anrede', 'Mnu.Ktx.Name', 'Mnu.Ktx.Zusatz' : begin
      vTxt # TextOpen(20);
      TextLineWrite(vTxt, 1, StrAdj(aMenuItem -> wpCaption, _StrBegin), _TextLineInsert | _TextNoLinefeed);
      aEvt:Obj->WinRtfLoad(_WinStreamBufText, _WinRtfLoadInsert, vTxt);
      TextClose(vTxt);
    end;


    otherwise begin

      // Textkonserve ausgewählt?
      if (StrFind(aMenuItem->wpName,'TXT_',1) > 0) then begin

        // Text Lesen
        vTxt # TextOpen(20);
        vTxtName # '~837.'+CnvAI(Lib_Strings:AlphaToInt(aMenuItem->wpName),_FmtNumLeadZero | _FmtNumNoGroup,0,8);

        // Text in Mailfenster schreiben
        if (Lib_Texte:TxtLoadLangBuf(vTxtName, vTxt, 'D')) then
          aEvt:Obj->WinRtfLoad(_WinStreamBufText, _WinRtfLoadInsert, vTxt);

        TextClose(vTxt);
      end;
    end;

  end; // case

	RETURN true;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt          : event;        // Ereignis
  aFocusObject  : int           // vorheriges Objekt
) : logic
local begin
  vTmp  : int;
end;
begin
  if (aEvt:Obj->Wininfo(_WinType)=_WinTypeCheckbox) then
    aEvt:Obj->wpColBkg # Set.Col.Field.Cursor
  else
    aEvt:Obj->wpColFocusBkg # Set.Col.Field.Cursor;

end;


//========================================================================
//  EvtFocusTerm
//            Fokus von Objekt wegnehmen
//========================================================================
sub EvtFocusTerm (
  aEvt          : event;        // Ereignis
  aFocusObject  : int           // nachfolgendes Objekt
) : logic
begin
  aEvt:Obj->wpColBkg # _WinColParent;
  RETURN true;
end;


//========================================================================
// EvtClicked
//
//========================================================================
Sub EvtClicked(
  aEvt        : event;
) : logic
local begin
  vHdl        : int;
  vWin        : int;
  vTxt        : int;
  vRecipient  : int;
  vOK         : logic;
end;
begin
  vWin # aEvt:Obj->WinInfo(_WinFrame);

  case (aEvt:Obj->wpName) of

    'bt.SaveHtml' : begin
      vHdl # TextOpen(20);
      Lib_Strings:RTFSaveHtml($RTFEdit,vHdl);
      TextWrite(vHdl, '', _TextClipboard);
      TextClose(vHdl);
      Msg(99,'Ist in der Zwischenablage!',0,0,0);
    end;

    'bt.Send' :  begin
      if (gMailList <> 0) then begin
        FOR   vRecipient # Sort_ItemFirst(gMailList)
        LOOP  vRecipient # Sort_ItemNext(gMailList, vRecipient)
        WHILE (vRecipient != 0) DO BEGIN
          vOK # SendMail(vRecipient, '', true);
//debug(vRecipient->spName);
        END;
      end
      else begin
        vOK # SendMail(0,$edEmpfaenger->wpcaption);
      end;
      if (vOK) then begin
        if (gCount<>0) then
          if(Msg(100014, AInt(gCount), _WinIcoInformation, _WinDialogYesNo, 2) <> _WinIdYes) then RETURN true;// Erfolgreich!
         Winclose($Dlg.Email);
       end;
    end;

    'bt.Attachment' :  begin
      InsertFileToDataList(Lib_FileIO:FileIO(_WinComFileOpen, vWin, '', ''));
    end;
  end; //case

  RETURN true;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt        : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  RETURN true;
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt      : event;        // Ereignis
): logic
begin
  Sort_KillList(gMailList); // Loeschen der Liste
  if (gTextList > 0) then
    gTextList->CteClose();
  RETURN true;
end;


//========================================================================
//  EvtKeyItem
//
//========================================================================
sub EvtKeyItem(
  aEvt        : event;    // Ereignis
  aKey        : int;      // Taste
  aID         : int;      // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
begin
  RETURN(true);
end;

//=========================================================================
// EvtLstDataInit
//        Formatiert die Ausgabe der Meldungen.
//=========================================================================
sub EvtLstDataInit (aEvt : event; aID : int) : logic
local begin
  vClmD   : handle;
  vClmT   : handle;
  vColor  : int;
  vDate   : date;
  vHdl    : handle;
end;
begin

  RETURN true;
END;


//=========================================================================
// EvtMouseItem
//        Führt Aktion bei Doppelklick aus.
//=========================================================================
sub EvtMouseItem (
  aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aId       : int) : logic
begin
  if (aButton & _winMouseLeft = 0) or (aButton & _winMouseDouble = 0) then // nur Doppelklick akzeptieren
    RETURN true;

  if(aItem = 0) or (aId = 0) then
    RETURN true;

  if (aItem->wpName = 'clmGV.Int.01') then begin // Anhang löschen
    if ($DL.Anhang->wpcurrentint <> 0) then begin
      $DL.Anhang->WinLstDatLineRemove(_WinLstDatLineCurrent);
    end;
  end;

  RETURN true;
end;


//=========================================================================
// EvtMenuInitPopup
//  Wird beim Erstellen des Kontextmenüs aufgerufen
//=========================================================================
sub EvtMenuInitPopup(
  aEvt : event;         // Ereignis
  aMenuItem : handle;   // auslösender Menüeintrag
) : logic
local begin
  vMnuHdl : int;
  vHdl : int;
  vItem : int;
end
begin
  // bei Klick auf Menü
  if (aMenuItem <> 0) then
    RETURN true;

  vMnuHdl # aEvt:Obj->WinInfo(_WinContextMenu);

  if (vMnuHdl > 0) then begin

    if (CteInfo(gTextList,_CteCount) > 0) then begin
      vHdl # vMnuHdl->WinMenuItemAdd('Mnu.Ktx.Text','Texte',0);
      if (vHdl > 0) then begin
        // Texte aus Cache ins Menü integrieren
        FOR   vItem # gTextList->CteRead(_CteFirst);
        LOOP  vItem # gTextList->CteRead(_CteNext, vItem);
        WHILE vItem > 0 DO
          vHdl->WinMenuItemAdd('TXT_'+CnvAi(vItem->spId,_FmtNumNoGroup), vItem->spName,0);
      end;
    end;

  end;

end;


//========================================================================
//  InsertFileToDataList
//
//========================================================================
sub InsertFileToDataList(aFilename : alpha(4000)) : logic;
local begin
  vHdl : int;
end;
begin
  if (aFilename = '') then
    RETURN false;

  vHdl # $Dlg.EMail->WinSearch('DL.Anhang');
  if (vHdl <> 0) then begin
    vHdl->WinLstDatLineAdd(3); // Papierkorb
    vHdl->WinLstCellSet(aFilename, 2, _WinLstDatLineLast);
  end;
  RETURN true;
end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vFormat : int;
  vTxt    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
	RETURN (true);
end;

//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  vFormat : int;
  vA      : alpha;
  vFile   : int;
  vID     : int;

  vDataFormat : int;
  vFileList   : int;
  vListObj    : int;
  vFilename   : alpha(2000);
  vNr         : int;
end;
begin

  // nur DateText-Obj. aufnehmen und NUR wenn sie einen Text(Custom) haben
  // Workbench->Workbench geht somit nicht, da da kein Text übergeben wird
  if (aDataObject->wpFormatEnum(_WinDropDataFile)) then begin
      // Dateipfad und -name wurde übergeben
      // Format-Objekt ermitteln
      vDataFormat # aDataObject->wpData(_WinDropDataFile);
      vFileList # vDataFormat->wpData;
      // alle übertragenen Dateinamen auswerten
      FOR vListObj # vFileList->CteRead(_CteFirst);
      LOOP vListObj # vFileList->CteRead(_CteNext,vListObj);
      WHILE (vListObj > 0) do begin
        vFileName # vListObj->spName;
        InsertFileToDataList(vFileName);
        //debug(vFileName);
      END;
  end;

	RETURN (true);
end


//========================================================================
//  EvtDragTerm
//              D&D beenden
//========================================================================
sub EvtDragTerm(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt;Durchgeführte Dragoperation (_WinDropEffectNome = abgebrochen)
	aEffect      : int
) : logic
local begin
  vFormat : int;
  vTxtBuf : int;
  vHdl    : int;
end;
begin
end;


/*
//=========================================================================
// Auswahl_EvtMouseItem
//        Mausclick in der SFX Auswahl
//=========================================================================
sub Auswahl_EvtMouseItem ( aEvt : event; aButton : int; aHitTest : int; aItem : int; aId : int ) : logic
begin
  if ( ( aButton & _winMouseLeft > 0 ) and ( aButton & _winMouseDouble > 0 ) ) then begin
    $Dlg.Auswahl->WinDialogResult( aId );
    $Dlg.Auswahl->WinClose();
  end;
  RETURN true;
end;


//=========================================================================
// Auswahl_EvtKeyItem
//        Tastendruck in der SFX Auswahl
//=========================================================================
sub Auswahl_EvtKeyItem ( aEvt : event; aKey : int; aId : int ): logic
begin
  if ( aKey = _winKeyReturn ) then begin
    $Dlg.Auswahl->WinDialogResult( aId );
    $Dlg.Auswahl->WinClose();
  end;
  RETURN true;
end;
*/
//=========================================================================
//=========================================================================