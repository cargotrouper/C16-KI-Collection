@A+
//@C+
//===== Business-Control =================================================
//
//  Prozedur  C16_SysSOAPInc
//                    OHNE E_R_G
//  Info
//
//
//  06.02.2013  AI  Installation
//
//  Subprozeduren
//
//========================================================================

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Optionen                                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

define // public
{
  _SOAP.Version1.1          : 0x00000001
  _SOAP.Version1.2          : 0x00000002

  _SOAP.UseLiteral          : 0x00000100
  _SOAP.UseEncoded          : 0x00000200
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Fehler                                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

define // public
{
  _Err.SOAPFault             : -10101   // SOAP-Fehler

  _Err.SOAPHTTPStatus        : -10201   // HTTP-Status ungültig
  _Err.SOAPHTTPContentLength : -10202   // HTTP-Content-Length (Datengröße) ungültig
  _Err.SOAPHTTPContentType   : -10203   // HTTP-Content-Type (Datentyp) ungültig
}
