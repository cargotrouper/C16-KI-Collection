@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_Kontakte
//                    OHNE E_R_G
//  Info        globale Variabeln/Makrodefinition für die Kontaktverwaltung
//
//
//  11.07.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

define begin
  c_KTD_TYP_TEL         : 't'
  c_KTD_TYP_FAX         : 'f'
  c_KTD_TYP_EMAIL       : 'm'
  c_KTD_TYP_URL         : 'u'

  c_KTD_TYP_TEL_SONST   : 'T'
  c_KTD_TYP_FAX_SONST   : 'F'
  c_KTD_TYP_EMAIL_SONST : 'M'
  c_KTD_TYP_URL_SONST   : 'U'

  // ---

  c_KTD_TEL         : 'Telefon'
  c_KTD_TEL_PRIV    : 'Telefon privat'

  c_KTD_TEL2        : 'Telefon2'
  c_KTD_TEL2_PRIV   : 'Telefon2 privat'

  c_KTD_FAX         : 'FAX'
  c_KTD_FAX_PRIV    : 'FAX privat'

  c_KTD_MOBIL       : 'Mobil'
  c_KTD_MOBIL_PRIV  : 'Mobil privat'

  c_KTD_INTERN      : 'Interne Rufnummer'

//  c_KTD_PAGER       : 'Pager'

  c_KTD_HOMEPAGE    : 'Homepage'

  c_KTD_EMAIL       : 'Email'
  c_KTD_EMAIL_PRIV  : 'Email privat'

  c_KTD_SONST_TEL   : 'sonstige Telefonnr.'
  c_KTD_SONST_FAX   : 'sonstige Faxnr.'
  c_KTD_SONST_EMAIL : 'sonstige Emailadresse'
  c_KTD_SONST_URL   : 'sonstige Webseite'

end;

//========================================================================
