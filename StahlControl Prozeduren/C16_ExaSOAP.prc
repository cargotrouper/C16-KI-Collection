@A+
@C+
//===== Business-Control =================================================
//
//  Prozedur  C16_ExaSOAP
//                    OHNE E_R_G
//  Info
//
//
//  06.02.2013  AI  Installation
//
//  Subprozeduren
//
//========================================================================
@I:C16_SysSOAPInc

define
{
  sCRLF                 : StrChar(0x0D) + StrChar(0x0A)
}

sub SOAP_Test
()

  local
  {
    tSOAP               : handle;
    tSOAPBody           : handle;
    tSOAPElement        : handle;
    tBezeichnung        : alpha(200);
    tBIC                : alpha;
    tOrt                : alpha(100);
    tPLZ                : alpha;
    tErr                : int;
  }

{
  try
  {
    // Initialisierung: SOAP-Client-Instanz anlegen
    tSOAP # C16_SysSOAP:Init(
      'http://www.thomas-bayer.com/axis2/services/BLZService', // Serveradresse
      'http://thomas-bayer.com/blz/' // Namensraum
    );

    // Anfragekörper ermitteln
    tSOAPBody # tSOAP->C16_SysSOAP:RqsBody();
    // Wert hinzufügen
    tSOAPBody->C16_SysSOAP:ValueAddInt('blz', 10070000);
    // Anfrage versenden und Antwort empfangen
    tSOAP->C16_SysSOAP:Request('getBank', '""');
    // Antwortkörper ermitteln
    tSOAPBody # tSOAP->C16_SysSOAP:RspBody();
    // Element ermitteln
    tSOAPElement # tSOAPBody->C16_SysSOAP:ElementGet('details');
    if (tSOAPElement > 0)
    {
      // Werte ermitteln
      tSOAPElement->C16_SysSOAP:ValueGetString('bezeichnung', var tBezeichnung);
      tSOAPElement->C16_SysSOAP:ValueGetString('bic', var tBIC);
      tSOAPElement->C16_SysSOAP:ValueGetString('ort', var tOrt);
      tSOAPElement->C16_SysSOAP:ValueGetString('plz', var tPLZ);
    }
  }

  // Fehler ermitteln
  tErr # ErrGet();
  // Kein Fehler aufgetreten
  if (tErr = _ErrOK)
  {
    // Werte ausgeben
    WinDialogBox(0, 'getBank()',
      'Bezeichnung: ' + tBezeichnung + sCRLF +
      'BIC: ' + tBIC + sCRLF +
      'Ort: ' + tOrt + sCRLF +
      'PLZ: ' + tPLZ,
      _WinIcoInformation, _WinDialogOK, 1
    );
  }
  // Fehler aufgetreten
  else
  {
    // SOAP-Fehler
    if (tErr = _Err.SOAPFault)
    {
      // SOAP-Fehler ausgeben
      WinDialogBox(0, 'getBank()',
        'SOAP-Fehler: ' + tSOAP->C16_SysSOAP:RspFaultCode() + sCRLF +
        tSOAP->C16_SysSOAP:RspFaultReason(),
        _WinIcoError, _WinDialogOK, 1
      );
    }
    // Allgemeiner Fehler
    else
    {
      // Fehler ausgeben
      WinDialogBox(0, '', 'Fehler: ' + CnvAI(tErr),
        _WinIcoError, _WinDialogOK, 1
      );
    }
  }

  // Terminierung: SOAP-Client-Instanz freigeben
  if (tSOAP > 0)
    tSOAP->C16_SysSOAP:Term();
}

main
{
  SOAP_Test();
}