@A+
//===== Business-Control =================================================
//
//  Prozedur  Adr_P_Subs
//                    OHNE E_R_G
//
//  Info
//
//
//  24.03.2010  ST  Erstellung der Prozedur
//  23.02.2021  AH  neu: "OutlookExport"
//  01.02.2022  ST  E r g --> Erx
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
end;


//========================================================================
//  andereAdresse(aAdresse : int, aPartner : int)
//    Ändert die Adresse des übe rgebenen Ansprechpartners
//========================================================================
sub andereAdresse(aAdresse : int; aPartner : int) : logic;
local begin
  Erx : int;
  vKundeNeu : int;
  vAnspNeu  : int;
  vText     : alpha;
  vAnsprech : int;
end;
begin

  // Sicherheitabfrage für falschen internen Aufruf
  if (aAdresse = 0) OR (aPartner = 0) then
    RETURN false;

  // Prüfen ob es den Ansprechpartner gibt
  Adr.P.Adressnr # aAdresse;
  Adr.P.Nummer   # aPartner;
  Erx # RecRead(101,1,0);
  if (Erx >= _rLocked) then begin
    return false;
  end;


  // Auswahl des Kunden
  if (Dlg_Standard:Standard(translate('Neue Adressnummer'), var vText)) then begin
    vKundeNeu # CnvIA(vText);

    // Keine Korrekte Nummer eingegeben?
    if (vKundeNeu = 0) then
        return false;

    // Prüfen ob die Adresse existiert
    Adr.Nummer # vKundeNeu;
    Erx # RecRead(100,1,0);
    if (Erx >= _rLocked) then
      return false;


    // bis hierhin alles io, dann Ansprechpartnerbuffer sichern
    vAnsprech # RekSave(102);

    // dann letzte Ansprechpartnernummer lesen
    vAnspNeu # 1;
    if (RecLink(102,100,13,_RecLast) <= _rLocked) then
      vAnspNeu # Adr.P.Nummer + 1;

    // Alten Ansprechpartner restoren
    RekRestore(vAnsprech);

    TRANSON;

    // Neuen Datensatz anlegen
    Adr.P.Adressnr # vKundeNeu;
    Adr.P.Nummer   # vAnspNeu;
    Erx # RekInsert(102,0,'MAN');
    if (Erx <> _rOK) then begin
      TRANSBRK;
      return false;
    end;

    // Alten Datensatz löschen
    Adr.P.Adressnr # aAdresse;
    Adr.P.Nummer   # aPartner;
    Erx # RecRead(101,1,0);
    if (Erx >= _rLocked) then begin
      TRANSBRK;
      return false;
    end;

    Erx # RekDelete(102,0,'MAN');
    if (Erx <> _rOK) then begin
      TRANSBRK;
      return false;
    end;

    // Alles IO bis hierhin
    TRANSOFF;

    // Ausgangsadresse neu lesen
    Adr.Nummer # aAdresse;
    Erx # RecRead(100,1,0);

    // Ausgangsadresse neu lesen
    Adr.P.Adressnr # aAdresse;
    Adr.P.Nummer   # 1;
    Erx # RecRead(101,1,0);

    return true;
  end;

end;


//========================================================================
//  OutlookExport
//========================================================================
sub OutlookExport()
local begin
  vI      : int;
  vErr    : alpha;
  v102    : int;
end;
begin
  vI # lib_Mark:Count(102);
  if (vI=0) then begin
    Lib_COM:ExportAdr( 102, false );
    RETURN;
  end;

  if (Msg(102002,aint(vI),_WinIcoQuestion,_WinDialogYesNo,1)<>_winidyes) then RETURN;
  
  v102 # RekSave(102);
  APPOFF();

  vErr # Lib_COM:ExportAdr( 102, false, true);
  
  APPON();
  RekRestore(v102);
  
  if (vErr<>'') then msg(99,vErr,0,0,0)
  else Msg(999998,'',0,0,0);
  
end;

//========================================================================