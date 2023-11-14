//                    OHNE E_R_G
// _NETAPI.HtmlMail
@A+
@C+
@I:Def_Global
@I:_NETAPI.Include

/**
SUB EmailHandleError
(
  aDll    : handle;
  aResult : int;
  aRange  : alpha(4096);
)
local
{
  tText : alpha(4096);
}
{
  if (aResult <> 0)
  {
    _NETAPI:GetErrorException(aDll,var tText);
    WinDialogBox(0,'Email-Error',
                 'Funktion : '+aRange+StrChar(13)+
                 'Fehlercode : '+CnvAI(aResult)+StrChar(13)+
                 'Fehlertext : ' + tText,_WinIcoError,_WinDialogOK | _WinDialogAlwaysOnTop,0);
  }
}
SUB EmailData
(
  aDll           : handle;
  aName          : alpha(4096);
  opt aValue     : alpha(4096);
  opt aOption    : alpha(4096)
)
: int;

local
{
  tResult : int;
}
{
  tResult # aDll->_NETAPI:EmailData(aName,aValue,aOption);
  aDll->EmailHandleError(tResult,aName);
  ErrSet(tResult);
}
**/

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + EmailData - DLL Funktion und einfache Fehlerbehandlung                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SUB EmailData(
  aDll            : handle;
  aName           : alpha(4096);
  opt aValue      : alpha(4096);
  opt aOption     : alpha(4096);
  opt aNoError    : logic;
)
: int;
local
{
  tResult : int;
  tText : alpha(4096);
}
{
  tResult # aDll->_NETAPI:EmailData(aName,aValue,aOption);

  if ((tResult <> 0) and (aNoError=false))
  {
    _NETAPI:GetErrorException(aDll,var tText);
    WinDialogBox(0,'Email-Error',
                 'Funktion : '+aName+StrChar(13)+
                 'Fehlercode : '+CnvAI(tResult)+StrChar(13)+
                 'Fehlertext : ' + tText,_WinIcoError,_WinDialogOK | _WinDialogAlwaysOnTop,0);
  }
  ErrSet(tResult);
}


//=========================================================================
//
//
//=========================================================================
sub HTMLMail();
local
{
  vDll : handle;
  vSendResult : int;
  vError : alpha(4096);
}
{
  vDll # _NETAPI:Init();
  if (vDll > 0)
  {
    try
    {
      // allgemeine globale Angaben
//      tDll->EmailData(sEmailSmtpServer,'192.168.1.1');
//      tDll->EmailData(sEmailSmtpPort,'25');
//      tDll->EmailData(sEmailSmtpTimeout,'30000');

/*!!!SSL!!!
      tDll->EmailData(sEmailSmtpPort,'587');
      tDll->EmailData(sEmailSmtpUseSSL,'true');
      tDll->EmailData(sEmailSmtpIgnoreSslCertificateError,'true');
      tDll->EmailData(sEmailSmtpCredentialUser,<benutzer>);
      tDll->EmailData(sEmailSmtpCredentialPassword,<kennwort);
*/

      // Aufbau einer neuen Email
      vDll->EmailData(sEmailClear);
//      vDll->EmailData(sEmailFrom,'ai@stahl-control.de','Alex');
      vDll->EmailData(sEmailTo,'ai@stahl-control.de','Michael');

      // --- Standard-Signatur von Outlook dranhängen --------------
      vDll->EmailData(sEmailOutlookSignature,sEmailSignatureDefault);

//      vDll->EmailData(sEmailTo,aRecipient,'Michael');
      vDll->EmailData(sEmailSubject,'Alle Umlaute äöüß');
//      vDll->EmailData(sEmailPriority,sEmailPriorityHigh);
      vDll->EmailData(sEmailbodyasciistring,'hallo du!');

//      tDll->EmailData(sEmailBodyRtfFile,'c:\test.rtf');
      //tDll->EmailData(sEmailAttachment,'c:\test.zip');

      // Email per SMTP versenden und EML speichern
      //tDll->EmailData(sEmailSave,'c:\test.eml');
      //tDll->EmailData(sEmailSend);

      // Email per Outlook versenden und als .MSG speichern
//      tDll->EmailData(sEmailSaveOutlook,'c:\test.msg');
      vDll->EmailData(sEmailSendOutlook);
    }

    if (ErrGet() = 0)
    {
      WinDialogBox(0,'HTML-Mail verschicken',
                 'Das Verschicken der HTML-Email war erfolgreich!',
                 _WinIcoInformation,_WinDialogOK | _WinDialogAlwaysOnTop,0);
    }
    else
    {
      WinDialogBox(0,'ERROR',
                 'ERROR '+cnvai(errGet()),
                 _WinIcoError,_WinDialogOK | _WinDialogAlwaysOnTop,0);
    }

    vDll->_NETAPI:Term();
  }
}


//=========================================================================
//
//
//=========================================================================
sub HTMLMail_Init() : int;
local
{
  vDll : handle;
  vSendResult : int;
  vError : alpha(4096);
}
{
  vDll # _NETAPI:Init();
  if (vDll > 0)
  {
    try
    {
      // allgemeine globale Angaben
//      tDll->EmailData(sEmailSmtpServer,'192.168.1.1');
//      tDll->EmailData(sEmailSmtpPort,'25');
//      tDll->EmailData(sEmailSmtpTimeout,'30000');

/*!!!SSL!!!
      tDll->EmailData(sEmailSmtpPort,'587');
      tDll->EmailData(sEmailSmtpUseSSL,'true');
      tDll->EmailData(sEmailSmtpIgnoreSslCertificateError,'true');
      tDll->EmailData(sEmailSmtpCredentialUser,<benutzer>);
      tDll->EmailData(sEmailSmtpCredentialPassword,<kennwort);
*/

      // Aufbau einer neuen Email
      vDll->EmailData(sEmailClear);
//      vDll->EmailData(sEmailFrom,'ai@stahl-control.de','Alex');
      vDll->EmailData(sEmailTo,'ai@stahl-control.de','Michael');
//      vDll->EmailData(sEmailTo,aRecipient,'Michael');
      vDll->EmailData(sEmailSubject,'Alle Umlaute äöüß');
//      vDll->EmailData(sEmailPriority,sEmailPriorityHigh);
      vDll->EmailData(sEmailbodyasciistring,'hallo du!');

//      tDll->EmailData(sEmailBodyRtfFile,'c:\test.rtf');
      //tDll->EmailData(sEmailAttachment,'c:\test.zip');

      // Email per SMTP versenden und EML speichern
      //tDll->EmailData(sEmailSave,'c:\test.eml');
      //tDll->EmailData(sEmailSend);

      // Email per Outlook versenden und als .MSG speichern
//      tDll->EmailData(sEmailSaveOutlook,'c:\test.msg');
      vDll->EmailData(sEmailSendOutlook);
    }

    if (ErrGet() = 0)
    {
      WinDialogBox(0,'HTML-Mail verschicken',
                 'Das Verschicken der HTML-Email war erfolgreich!',
                 _WinIcoInformation,_WinDialogOK | _WinDialogAlwaysOnTop,0);
    }
    else
    {
      WinDialogBox(0,'ERROR',
                 'ERROR '+cnvai(errGet()),
                 _WinIcoError,_WinDialogOK | _WinDialogAlwaysOnTop,0);
    }

    vDll->_NETAPI:Term();
  }
}


//=========================================================================
//
//
//=========================================================================
sub Attachfile(aDLL : int; aFilename : alpha(4096));
{
  aDll->EmailData(sEmailAttachment, aFilename);
}

//=========================================================================
//
//
//=========================================================================
sub NewMail(
  aDLL  : int;
  aSub  : alpha(4096);
  aRec  : alpha(4096));
{
  // Aufbau einer neuen Email
  aDll->EmailData(sEmailClear);
  //      vDll->EmailData(sEmailFrom,'ai@stahl-control.de','Alex');

  // --- Standard-Signatur von Outlook dranhängen --------------
  aDll->EmailData(sEmailOutlookSignature,sEmailSignatureDefault);

  aDll->EmailData(sEmailTo,aRec);

  aDll->EmailData(sEmailSubject,aSub);
  //      vDll->EmailData(sEmailPriority,sEmailPriorityHigh);
//  aDll->EmailData(sEmailbodyasciistring,'hallo du!');

  aDll->EmailData(sEmailBodyRtfFile,'e:\lala.rtf');
      //tDll->EmailData(sEmailAttachment,'c:\test.zip');
}


//=========================================================================
//
//
//=========================================================================
sub SendOutlook(aDLL : int);
{
  aDll->EmailData(sEmailSendOutlook,'','',n);
}

//=========================================================================