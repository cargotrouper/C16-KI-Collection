//                    OHNE E_R_G
// _NETAPI.Include
@A+
@C+

// ---------------------------------------------------------------------------------------------------
// Define
// ---------------------------------------------------------------------------------------------------
define
{
  sCmdErrorException        :  0
  sCmdPDFDocumentInfo       : 13
  sCmdEmailData             : 17

  sErrInvalidArgCount       : -100000
  sErrInvalidArgType        : -100001
  sErrInvalidCommand        : -100002
  sErrUnknownCommand        : -100003
  sErrInvalidCommandArgs    : -100004

  sErrException             : -100005

  sErrFileNameInvalid       : -110001
  sErrPrinterNotFound       : -110002

  sErrPDFInputFile          : -120001
  sErrPDFOutputFile         : -120002
  sErrPDFImport             : -120003

  sEmailSmtpServer                    : 'SmtpServer'
  sEmailSmtpPort                      : 'SmtpPort'
  sEmailSmtpTimeout                   : 'SmtpTimeout'
  sEmailSmtpCredentialUser            : 'SmtpCredentialUser'
  sEmailSmtpCredentialPassword        : 'SmtpCredentialPassword'
  sEmailSmtpUseSSL                    : 'SmtpUseSSL'
  sEmailSmtpIgnoreSslCertificateError : 'SmtpIgnoreSslCertificateError'

  sEmailClear                  : 'Clear'
  sEmailFrom                   : 'From'
  sEmailReplyTo                : 'ReplyTo'
  sEmailTo                     : 'To'
  sEmailCc                     : 'Cc'
  sEmailBcc                    : 'Bcc'
  sEmailSubject                : 'Subject'
  sEmailPriority               : 'Priority'
  sEmailBodyAsciiString        : 'BodyAsciiString'
  sEmailBodyAsciiFile          : 'BodyAsciiFile'
  sEmailBodyRtfFile            : 'BodyRtfFile'
  sEmailAttachment             : 'Attachment'
  sEmailOutlookSignature       : 'OutlookSignature'

  sEmailSend                   : 'Send'
  sEmailSendOutlook            : 'SendOutlook'
  sEmailSave                   : 'Save'
  sEmailSaveOutlook            : 'SaveOutlook'

  sEmailPriorityNormal         : '0'
  sEmailPriorityLow            : '1'
  sEmailPriorityHigh           : '2'

  sEmailSignatureNone          : ''
  sEmailSignatureDefault       : 'default'

}

// ------------------------------------------------------------------------------------------------
// Declare : Vorausladen der Sub-Prozeduren
// ------------------------------------------------------------------------------------------------
declare _NETAPI:VerifyNetFramework4() : logic;
declare _NETAPI:Init() : handle;
declare _NETAPI:Term(aDll : handle);
declare _NETAPI:GetErrorException(aDll : handle;var aText : alpha;) : int;

declare _NETAPI:EmailData(aDll           : handle;
                          aName          : alpha(4096);
                          opt aValue     : alpha(4096);
                          opt aOption    : alpha(4096)) : int;

