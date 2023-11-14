@A+
//==== Business-Control ===================================================
//
//  Prozedur    F_STD_ADR_Kundenakte
//
//  Info
//        Formular: Adressen / Kundenakte
//
//  07.12.2010  TM  Erstellung
//
//  Subprozeduren
//    sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
//    sub SeitenKopf ( aSeite : int );
//    sub PrintForm ();
//=========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  cPos0   :  10.0   // Standardeinzug links
  cTab1   :  42.0
  cTab1b  :  50.0
  cTab1c  :  72.0
  cTab2   :  95.0
  cTab2b  : 125.0
  cTab3   : 127.0
  cTab3b  : 157.0
  cTab4   : 150.0


  cPos0r  : 180.0   // Standardeinzug rechts
end;

local begin
  vTopMargin  : float;
  vSubTitle   : logic;
  vNum        : int;
  vName       : alpha;
end;

//=========================================================================
// GetDokName
//        Bestimmt den Namen eines Dokuments
//=========================================================================
sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
begin
  aSprache # ''
  aAdresse # Adr.V.AdressNr;

  RETURN CnvAI( Adr.V.Adressnr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + '/' + CnvAI( Adr.V.lfdNr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 4 );
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vX : logic;
end;
begin
  Case Form_Mode of
    'PARTNER' : begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print( 'Ansprechpartner',cPos0);
      PL_PrintLine;
      PL_PrintLine;

      pls_fontSize # 9;
      pls_fontAttr # 0;
      Form_Mode # '';
    end;

    'ANSCHRIFT' : begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print( 'Lieferanschriften',cPos0);
      PL_PrintLine;
      PL_PrintLine;

      pls_fontSize # 9;
      pls_fontAttr # 0;
      Form_Mode # '';
    end;
  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf des Formulars
//=========================================================================
sub SeitenKopf ( aSeite : int );
local begin
  vText : alpha;
end;
begin
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.Telefax;
    Form_EMA        # Adr.EMail;
  end;

  pls_fontSize # 9;

  /* Header */
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Kunden-/Lieferantenakte',cPos0);
  PL_Print_R( 'Seite ' + cnvai(aSeite),cPos0r);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  pls_fontAttr # 0;
  PL_Print( 'Kundennummer:',cPos0);
  PL_Print(cnvai(Adr.Kundennr),cTab1);
  PL_Print('Stichwort:',cTab2);
  PL_Print( Adr.Stichwort,cTab3);
  PL_PrintLine;

  PL_Print( 'Lieferantennr.:',cPos0);
  PL_Print( cnvai(Adr.Lieferantennr),cTab1);
  PL_Print( 'Sachbearbeiter:',cTab2);
  PL_Print( Adr.Sachbearbeiter,cTab3);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  Erg # RecLink(110,100,15,0);
  If (Erg > _rLocked) then RecBufClear(110);

  PL_Print( 'Gruppe:',cPos0);
  PL_Print( Adr.Gruppe,cTab1);
  PL_Print( 'Vertreter:',cTab2);
  PL_Print( Ver.Stichwort,cTab3);
  PL_PrintLine;

  PL_Print( '',cPos0);
  PL_Print( '',cTab1);
  PL_Print( 'ABC / Punkte:',cTab2);
  PL_Print( Adr.ABC + ' / ' + cnvai(Adr.Punktzahl),cTab3);
  PL_PrintLine;

  pls_fontAttr # _winFontAttrN;
  Lib_Print:Print_LinieEinzeln(cPos0,cPos0r);
  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  if (Form_Mode='PARTNER') then     Print('Partner');
  if (Form_Mode='ANSCHRIFT') then   Print('Anschrift');

end;


//=========================================================================
// PrintSubTitle
//        Subtitel drucken
//=========================================================================
sub PrintSubTitle ( aText : alpha; opt checkGlobal : logic )
begin
  if ( checkGlobal and vSubTitle ) then
    RETURN;

  PL_PrintLine;
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( aText, cPos0 );
  pls_fontAttr # _winFontAttrN;
  pls_fontSize # 9;
  PL_PrintLine;

  if ( checkGlobal ) then
    vSubTitle # true;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
local begin
  vPrintLine  : int;

  vNotFirst   : logic;
  vFirst      : logic;

  vTxtHdl     : handle;
  vLines      : int;
  vLine       : int;
  vFilter     : handle;

  vUmsatzYN   : logic;
end;
begin

  RecRead( 100, 1, 0 );

  PL_Create( vPrintLine );
//  Lib_Print:FrmJobOpen( 'tmp' + AInt( gUserID ), 0, 0, false, false, false );
  Lib_Print:FrmJobOpen( y, 0, 0, false, false, false );
  Form_DokName  # GetDokName( var Form_DokSprache, var Form_DokAdr);

  vTopMargin    # form_RandOben;
  form_RandOben # 56693.0; // 10mm
  Lib_Print:Print_Seitenkopf();

  /* Hausanschrift / Postanschrift */
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Hausanschrift',cPos0);
  PL_Print( 'Postanschrift',cTab2);
  PL_PrintLine;
  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  pls_fontAttr # 0;
  PL_Print( Adr.Anrede,cPos0);
  If (Adr.Postfach <> '') then PL_Print( Adr.Anrede,cTab2);
  PL_PrintLine;

  PL_Print( Adr.Name,cPos0);
  If (Adr.Postfach <> '') then PL_Print( Adr.Name,cTab2);
  PL_PrintLine;

  PL_Print( Adr.Zusatz,cPos0);
  If (Adr.Postfach <> '') then PL_Print( Adr.Zusatz,cTab2);
  PL_PrintLine;

  PL_Print( "Adr.Straße",cPos0);
  If (Adr.Postfach <> '') then PL_Print( Adr.Postfach,cTab2);
  PL_PrintLine;

  if (Adr.PLZ <> '') then
    PL_Print( Adr.PLZ + ' ' + Adr.Ort,cPos0)
  else
    PL_Print( Adr.Ort,cPos0);

  If (Adr.Postfach <> '') then begin
    if (Adr.Postfach.PLZ <> '') then
      PL_Print( Adr.Postfach.PLZ + ' ' + Adr.Ort,cTab2);
    else
      PL_Print( Adr.Ort,cTab2);
  End;

  PL_PrintLine;

  Erg # RecLink(812,100,10,0);
  If (Erg > _rLocked) then RecBufClear(812);
  PL_Print( Lnd.Name.L1,cPos0);
  PL_Print( Lnd.Name.L1,cTab2);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  PL_Print( 'Telefon 1:',cPos0);
  PL_Print( Adr.Telefon1,cTab1);
  PL_Print( 'Telefon 2:',cTab2);
  PL_Print( Adr.Telefon2,cTab3);
  PL_PrintLine;

  PL_Print( 'Telefax:',cPos0);
  PL_Print( Adr.Telefax,cTab1);
  PL_Print( '',cTab2);
  PL_Print( '',cTab3);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  PL_Print( 'e-Mail:',cPos0);
  PL_Print( Adr.eMail,cTab1);
  PL_PrintLine;

  PL_Print( 'Homepage:',cPos0);
  PL_Print( Adr.Website,cTab1);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  PL_Print( 'Briefanrede:',cPos0);
  PL_Print( Adr.Briefanrede,cTab1);
  PL_PrintLine;

  PL_Print( 'Briefgruppe:',cPos0);
  PL_Print( Adr.Briefgruppe,cTab1);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;


  // Bankdaten
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Bankverbindung 1',cPos0);
  PL_Print( 'Bankverbindung 2',cTab2);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  pls_fontAttr # 0;
  PL_Print( 'Bank:',cPos0);
  PL_Print( Adr.Bank1.Name,cTab1);
  PL_Print( 'Bank:',cTab2);
  PL_Print( Adr.Bank2.Name,cTab3);
  PL_PrintLine;

  PL_Print( 'BLZ:',cPos0);
  PL_Print( Adr.Bank1.BLZ,cTab1);
  PL_Print( 'BLZ:',cTab2);
  PL_Print( Adr.Bank2.BLZ,cTab3);
  PL_PrintLine;

  PL_Print( 'Konto:',cPos0);
  PL_Print( Adr.Bank1.Kontonr,cTab1);
  PL_Print( 'Konto:',cTab2);
  PL_Print( Adr.Bank2.Kontonr,cTab3);
  PL_PrintLine;

  PL_Print( 'IBAN:',cPos0);
  PL_Print( Adr.Bank1.IBAN,cTab1);
  PL_Print( 'IBAN:',cTab2);
  PL_Print( Adr.Bank2.IBAN,cTab3);
  PL_PrintLine;

  PL_Print( 'BIC SWIFT:',cPos0);
  PL_Print( Adr.Bank1.BIC.SWIFT,cTab1);
  PL_Print( 'BIC SWIFT:',cTab2);
  PL_Print( Adr.Bank2.BIC.SWIFT,cTab3);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  // Kreditversicherungf
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Kreditversicherungsdaten',cPos0);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  Erg # RecLink(103,100,14,0);
  If (Erg > _rLocked) then RecBufClear(103);
  Erg # RecLink(814,103,2,0);
  If (Erg > _rLocked) then RecBufClear(814);

  pls_fontAttr # 0;
  PL_Print( 'Währung:',cPos0);
  PL_Print("Wae.Kürzel" + ' / ' + Wae.Bezeichnung,cTab1b);

  PL_Print( 'Kreditlimit kurzz.:',cTab2);

  If (Adr.K.KurzLimitFW > 0.0) then
    PL_Print(cnvaf(Adr.K.KurzLimitFW,0,0,2) + ' bis ' + cnvad(Adr.K.KurzLimit.Dat,_FmtDateLongYear),cTab3)
  else
    PL_Print(cnvaf(Adr.K.KurzLimitW1,0,0,2) + ' bis ' + cnvad(Adr.K.KurzLimit.Dat,_FmtDateLongYear),cTab3);

  PL_PrintLine;

  PL_Print( 'Kreditversicherung:',cPos0);

  If (Adr.K.VersichertFW > 0.0) then
    PL_Print(cnvaf(Adr.K.VersichertFW,0,0,2),cTab1b)
  else
    PL_Print(cnvaf(Adr.K.VersichertW1,0,0,2),cTab1b);

  PL_Print( 'Kreditversicherer:',cTab2);
  PL_Print( Adr.K.Versicherer,cTab3);

  PL_PrintLine;

  PL_Print( 'Kreditlimit:',cPos0);
  PL_Print(cnvaf(Adr.K.InternLimit,0,0,2),cTab1b);

  PL_Print( 'Referenznummer:',cTab2);
  PL_Print( Adr.K.Referenznr,cTab3);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;
  // Liefer- / Zahlungsbedingungen

  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Liefer- und Zahlungsbedingungen',cPos0);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;


  pls_fontAttr # 0;

  Erg # RecLink(815,100,6,0);
  If (Erg < _rLocked) then RecBufClear(816);
  PL_Print( 'VK Lieferbedingung:',cPos0);
  PL_Print( LiB.Bezeichnung.L1,cTab1b);
  PL_PrintLine;

  Erg # RecLink(816,100,7,0);
  If (Erg > _rLocked) then RecBufClear(816);
  PL_Print( 'Zahlungsbedingung:',cPos0);
  PL_Print( ZaB.Bezeichnung1.L1,cTab1b);
  PL_PrintLine;
  If (ZaB.Bezeichnung2.L1 <> '') then
  PL_Print( ZaB.Bezeichnung2.L1,cTab1b);
  PL_PrintLine;


  Erg # RecLink(817,100,8,0);
  If (Erg > _rLocked) then RecBufClear(817);
  PL_Print( 'Versandart:',cPos0);
  PL_Print( VsA.Bezeichnung.L1,cTab1b);
  PL_PrintLine;

  PL_Print( 'Lieferantennr. bei Kd.:',cPos0);
  PL_Print( Adr.VK.Referenznr,cTab1b);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  Erg # RecLink(815,100,2,0);
  If (Erg > _rLocked) then RecBufClear(816);
  PL_Print( 'EK Lieferbedingung:',cPos0);
  PL_Print( LiB.Bezeichnung.L1,cTab1b);
  PL_PrintLine;

  Erg # RecLink(816,100,3,0);

  If (Erg > _rLocked) then RecBufClear(816);
  PL_Print( 'Zahlungsbedingung:',cPos0);
  PL_Print( ZaB.Bezeichnung1.L1,cTab1b);
  PL_PrintLine;
  If (ZaB.Bezeichnung2.L1 <> '') then
  PL_Print( ZaB.Bezeichnung2.L1,cTab1b);
  PL_PrintLine;

  Erg # RecLink(817,100,4,0);
  If (Erg > _rLocked) then RecBufClear(817);
  PL_Print( 'Versandart:',cPos0);
  PL_Print( VsA.Bezeichnung.L1,cTab1b);
  PL_PrintLine;

  PL_Print( 'Kundennr. bei Lief.:',cPos0);
  PL_Print( Adr.EK.Referenznr,cTab1b);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  Erg # RecLink(814,100,5,0)
  PL_Print( 'Abrechnung in:',cPos0);
  PL_Print("Wae.Kürzel" + ' / ' + Wae.Bezeichnung,cTab1b);
  PL_PrintLine;

  Erg # RecLink(814,100,5,0)
  PL_Print( 'Zahlung in:',cPos0);
  PL_Print("Wae.Kürzel" + ' / ' + Wae.Bezeichnung,cTab1b);
  PL_PrintLine;

  Erg # RecLink(814,100,5,0)
  PL_Print( 'USt-Ident-Nr.:',cPos0);
  PL_Print(Adr.USIdentNr,cTab1b);
  PL_PrintLine;

  Erg # RecLink(813,100,11,0);
  PL_Print( 'Steuerschlüssel:',cPos0);
  PL_Print( cnvaf(StS.Prozent,0,0,2) + ' % ' + StS.Bezeichnung,cTab1b);
  PL_PrintLine;

  Erg # RecLink(814,100,5,0)
  PL_Print( 'Steuernummer:',cPos0);
  PL_Print(Adr.Steuernummer,cTab1b);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;


  // >> **** OPTIONAL: Umsatzdaten **** >>

  if (Msg(100013,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    pls_fontSize # 10;
    pls_fontAttr # _winFontAttrB;
    PL_Print( 'Finanzen',cPos0);
    PL_PrintLine;

    pls_fontSize # 6;
    PL_PrintLine;
    pls_fontSize # 9;


    pls_fontAttr # 0;

    Call('Adr_Data:BerechneFinanzen');

    PL_Print( 'Auftragsrest:',cPos0);
    PL_Print_R( cnvaf(Adr.Fin.SummeAB,0,0,2),cTab1c -1.0);
    PL_Print( 'Offene Posten:',cTab2);
    PL_Print_R( cnvaf(Adr.Fin.SummeOP,0,0,2),cTab4 -1.0);
    PL_PrintLine;

    PL_Print( 'Reservierungen:',cPos0);
    PL_Print_R( cnvaf(Adr.Fin.SummeRes,0,0,2),cTab1c -1.0);
    PL_Print( 'Fremd-OP:',cTab2);
    PL_Print_R( cnvaf(Adr.Fin.SummeOP.Ext,0,0,2),cTab4 -1.0);
    PL_PrintLine;

    PL_Print( 'Lfd. Liefermenge:',cPos0);
    PL_Print_R( cnvaf(Adr.Fin.SummeLFS,0,0,2),cTab1c -1.0);
    PL_Print( 'akt. Kreditlimit:',cTab2);
    PL_Print_R( cnvaf(Adr.Fin.SummePlan,0,0,2),cTab4 -1.0);
    PL_PrintLine;

    PL_Print( 'zu berechnende Auf.:',cPos0);
    PL_Print_R( cnvaf(Adr.Fin.SummeABBere,0,0,2),cTab1c -1.0);
    PL_Print( 'STAND VOM:',cTab2);
    PL_Print_R( cnvad(Adr.Fin.RefreshDatum),cTab4 -1.0);
    PL_PrintLine;

    pls_fontSize # 6;
    PL_PrintLine;
    pls_fontSize # 9;

  End;

  // << **** OPTIONAL: Umsatzdaten **** <<


  // Ansprechpartner
  Erg # RecLink(102,100,13,_recFirst);
  If (Erg <= _rMultiKey) then begin
    Form_Mode # 'PARTNER';
    pls_fontSize # 10;
    pls_fontAttr # _winFontAttrB;
    PL_Print( 'Ansprechpartner',cPos0);
    PL_PrintLine;
    PL_PrintLine;

    pls_fontSize # 9;
    pls_fontAttr # 0;


    WHILE (Erg <= _rMultiKey) DO BEGIN
      vName # '';

      If (Adr.P.Vorname <> '')      then vName # vName + Adr.P.Vorname + ' ';
      If (Adr.P.Name <> '')         then vName # vName + Adr.P.Name + ' ';

      PL_Print(vName,cPos0);
      PL_Print(Adr.P.Funktion,cTab1c);
      PL_Print(Adr.P.Telefon,cTab2b);
      PL_Print(Adr.P.eMail,cTab3b);
      PL_PrintLine;
      Erg # RecLink(102,100,13,_recNext);
    End;
    Form_Mode # '';
    pls_fontSize # 6;
    PL_PrintLine;
    pls_fontSize # 9;

  end;

  // Lieferanschriften
  Erg # RecLink(101,100,12,_recFirst);
  If (Erg <= _rMultiKey) then begin
    Form_Mode # 'ANSCHRIFT';
    pls_fontSize # 10;
    pls_fontAttr # _winFontAttrB;
    PL_Print( 'Lieferanschriften',cPos0);
    PL_PrintLine;
    PL_PrintLine;

    pls_fontSize # 9;
    pls_fontAttr # 0;
  end;

  WHILE (Erg <= _rMultiKey) DO BEGIN
    vName # '';

    PL_Print(Adr.A.Name,cPos0);
    PL_Print(Adr.A.Warenannahme1,cTab2);
    PL_PrintLine;

    PL_Print(Adr.A.Zusatz,cPos0);
    PL_Print(Adr.A.Warenannahme2,cTab2);
    PL_PrintLine;

    PL_Print("Adr.A.Straße",cPos0);
    PL_Print(Adr.A.Warenannahme3,cTab2);
    PL_PrintLine;

    PL_Print(Adr.A.PLZ + ' ' + Adr.A.Ort,cPos0);
    PL_Print(Adr.A.Warenannahme4,cTab2);
    PL_PrintLine;
    Erg # RecLink(812,101,2,0);
    If (Erg > _rLocked) then RecBufClear(812);
    PL_Print(lnd.Name.L1,cPos0);
    PL_Print(Adr.A.Warenannahme5,cTab2);
    PL_PrintLine;
    PL_PrintLine;


    Erg # RecLink(101,100,12,_recNext);
  End;
  Form_Mode # '';


  /* Druck beenden */
  Usr.Username # UserInfo( _userName, CnvIA( UserInfo( _userCurrent ) ) );
  RecRead( 800, 1, 0 );
  Lib_Print:FrmJobClose( !"Frm.DirektdruckYN" );

  if ( vPrintLine != 0 ) then
    PL_Destroy( vPrintLine );

end;

//=========================================================================
//=========================================================================