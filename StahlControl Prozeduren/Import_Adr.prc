@A+
//===== Business-Control =================================================
//
//  Prozedur  Import_Adr
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2008  MS  Erstellung der Prozedur
//  23.05.2014  TM  Prüfung NEUMANN FUTURE
//
//  Subprozeduren
//    SUB ConvertLKZ(var aLKZ : alpha);
//    SUB Import_BCS()
//    SUB Import_SC5()
//    SUB Import_TSR()
//    SUB Import_FLK()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  GetAlphaUp(a,b)     : a # strcnv(FldAlphabyName('X_'+b),_StrUpper);
  GetAlphaMax(a,b,c)  : a # StrCut(FldAlphabyName('X_'+b),1,c);
  GetAlpha(a,b)   : a # FldAlphabyName('X_'+b);
  GetInt(a,b)     : a # FldIntbyName('X_'+b);
  GetWord(a,b)    : a # FldWordbyName('X_'+b);
  GetNum(a,b)     : a # FldFloatbyName('X_'+b);
  GetBool(a,b)    : a # FldLogicbyName('X_'+b);
  GetDate(a,b)    : a # FldDatebyName('X_'+b);
  GetTime(a,b)    : a # FldTimebyName('X_'+b);
end;


//========================================================================
//  Import_BCS
//
//========================================================================
sub ConvertLKZ(var aLKZ : alpha);
begin
  aLKZ # StrCnv(aLKZ,_StrUpper);
  if (aLKZ='D') then aLKZ # 'DE';
  if (aLKZ='E') then aLKZ # 'ES';
  if (aLKZ='I') then aLKZ # 'IT';

end;


//========================================================================
//  Import_BCS
//
//========================================================================
sub Import_BCS()
local begin
  Erx : int;
end;
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.0.10','Neumann 4.7','user','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!');
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
    GetInt(Adr.Verband,'Adr.Verband'); //**
    GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr'); //**
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');
//    GetAlpha(Adr.Postfach.PLZ,'Adr.');
//    GetAlpha(Adr.Postfach,'Adr.');
    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
//    Get(Adr.Kredit,'Adr.');
    GetBool(Adr.SperrKundeYN,'Adr.Sperrung');
    GetBool(Adr.SperrLieferantYN,'Adr.Sperrung');
    GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
    GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    GetAlpha(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr');
    GetAlpha(Adr.Bank2.Name,'Adr.Bank2.Name');
    GetAlpha(Adr.Bank2.BLZ,'Adr.Bank2.BLZ');
    GetAlpha(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr');

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
    GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');
    GetAlpha(Adr.EK.Referenznr,'Adr.KdNrbeiLieferant');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
    GetWord(Adr.VK.Versandart,'Adr.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
    GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
    GetBool(Adr.VK.SammelReYN,'Adr.SammelrechnungJN');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
//    GetAlpha(Adr.Steuernummer,'Adr.');
    GetWord("Adr.Steuerschlüssel",'Adr.Steuerart');
//    GetAlpha(Adr.Sprache,'Adr.');
//    GetAlpha(Adr.AbmessungEH,'Adr.');
//    GetAlpha(Adr.GewichtEH,'Adr.');


    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx>0) then begin
      TRANSBRK;
      Msg(100003,'',0,0,0);
      RETURN;
    end;
    if (Erx<0) then begin
      TRANSBRK;
      RETURN;
    end;

    if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;
    Erx # RekInsert(100,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;

/*
xxx
loop partner
*/

    Erx # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;


//========================================================================
//  Import_SC5
//
//========================================================================
sub Import_SC5()
local begin
Ansprechpartner : int;
end;
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!LICHTGITTER5.2','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
//    GetInt(Adr.Verband,'Adr.Verband');
//    GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr');
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');
//    GetAlpha(Adr.Postfach.PLZ,'Adr.');
//    GetAlpha(Adr.Postfach,'Adr.');
    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
//    Get(Adr.Kredit,'Adr.');
    GetBool(Adr.SperrKundeYN,'Adr.SperrungKunde');
    GetBool(Adr.SperrLieferantYN,'Adr.SperrungLiefernt');
    GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
//    GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    GetAlpha(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr');
    GetAlpha(Adr.Bank2.Name,'Adr.Bank2.Name');
    GetAlpha(Adr.Bank2.BLZ,'Adr.Bank2.BLZ');
    GetAlpha(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr');

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
    GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');
    GetAlpha(Adr.EK.Referenznr,'Adr.KdNrbeiLieferant');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
    GetWord(Adr.VK.Versandart,'Adr.VK.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
    GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
    GetBool(Adr.VK.SammelReYN,'Adr.SammelrechnungJN');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
    GetAlpha(Adr.Steuernummer,'Adr.Steuernummer');
    GetWord("Adr.Steuerschlüssel",'Adr.Steuerschlüssel');
    GetAlphaUP(Adr.Sprache,'Adr.Sprachkennung');
    GetAlpha(Adr.AbmessungEH,'Adr.AbmessungEH');
    GetAlpha(Adr.GewichtEH,'Adr.GewichtEH');


    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx>0) then begin
      TRANSBRK;
      Msg(100003,'',0,0,0);
      RETURN;
    end;
    if (Erx<0) then begin
      TRANSBRK;
      RETURN;
    end;

    if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;
    Erx # RekInsert(100,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;

    Erx # RecLink(2102,2100,11,_recFirst); // Ansprechpartner holen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(102);

      Adr.P.Adressnr # Adr.Nummer;
      GetWord(Adr.P.Nummer,'Adr.P.Nummer');


      GetAlpha(Adr.P.Vorname,'Adr.P.Vorname');
      GetAlpha(Adr.P.Name,'Adr.P.Nachname');
      GetAlpha(Adr.P.Titel,'Adr.P.Titel');
      GetAlpha(Adr.P.Telefon,'Adr.P.Telefon');
      GetAlpha(Adr.P.Telefax,'Adr.P.Telefax');
      GetAlpha(Adr.P.Mobil,'Adr.P.Mobiltelefon');
      GetAlpha(Adr.P.eMail,'Adr.P.eMail');

      GetAlpha(Adr.P.Abteilung,'Adr.P.Abteilung');
      GetAlpha(Adr.P.Funktion,'Adr.P.Funktion');
      GetAlpha(Adr.P.Vorgesetzter,'Adr.P.Vorgesetzter');
      GetAlpha(Adr.P.Briefanrede,'Adr.P.Briefanrede');
      GetAlpha(Adr.P.Priv.LKZ,'Adr.P.Priv.LKZ');
      GetAlpha(Adr.P.Priv.PLZ,'Adr.P.Priv.PLZ');
      GetAlpha("Adr.P.Priv.Straße",'Adr.P.Priv.Straße');
      GetAlpha(Adr.P.Priv.Ort,'Adr.P.Priv.Ort');
      GetAlpha(Adr.P.Priv.Telefon,'Adr.P.Priv.Telefon');
      GetAlpha(Adr.P.Priv.Telefax,'Adr.P.Priv.Telefax');
      GetAlpha(Adr.P.Priv.eMail,'Adr.P.Priv.eMail');
      GetAlpha(Adr.P.Priv.Mobil,'Adr.P.Priv.Mobil');

      GetAlpha(Adr.P.Familienstand,'Adr.P.Familienstand');
      GetAlpha(Adr.P.Hobbies,'Adr.P.Hobbies');
      GetAlpha(Adr.P.Vorlieben,'Adr.P.Vorlieben');
      GetAlpha(Adr.P.Auto,'Adr.P.Auto');
      GetAlpha(Adr.P.Religion,'Adr.P.Religion');
      GetAlpha(Adr.P.Partner.Name,'Adr.P.Partner');
      GetAlpha(Adr.P.Kind1.Name,'Adr.P.Kind1.Name');
      GetAlpha(Adr.P.Kind2.Name,'Adr.P.Kind2.Name');
      GetAlpha(Adr.P.Kind3.Name,'Adr.P.Kind3.Name');
      GetAlpha(Adr.P.Kind4.Name,'Adr.P.Kind4.Name');

      GetDate(Adr.P.Geburtsdatum,'Adr.P.Geburtsdatum');
      GetDate(Adr.P.Partner.GebTag,'Adr.P.PartnerGeb');
      GetDate(Adr.P.Hochzeitstag,'Adr.P.Hochzeitstag');
      GetDate(Adr.P.Kind1.GebTag,'Adr.P.Kind1.Geb');
      GetDate(Adr.P.Kind2.GebTag,'Adr.P.Kind2.Geb');
      GetDate(Adr.P.Kind3.GebTag,'Adr.P.Kind3.Geb');
      GetDate(Adr.P.Kind4.GebTag,'Adr.P.Kind4.Geb');

      GetBool(Adr.P.PrivGeschenkYN,'Adr.P.GeschPriv?');

      Erx # Erxsert(102,0,'MAN');

      Erx # RecLink(2102,2100,11,_recNext);
    END;



  Erx # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;


//========================================================================
//  Import_TSR
//
//========================================================================
sub Import_TSR()
local begin
  Ansprechpartner : int;
  vTxt            : int;
  vA              : alpha(100);
  vF              : float;
end;
begin

  // ALLE ADRESSEN LÖSCHEN...
  Lib_Rec:ClearFile(100,'TEXT');
  Lib_Rec:ClearFile(101);
  Lib_REc:ClearFile(102);
  lib_Rec:ClearFile(103);
  lib_Rec:ClearFile(105);
  lib_Rec:ClearFile(106);
  Lib_Rec:ClearFile(109);


  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
//  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache         # Set.Sprache1.Kurz;
    Adr.AbmessungEH     # 'mm';
    Adr.GewichtEH       # 'kg';
    Adr.VK.Verwiegeart  # 2;

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
//    GetInt(Adr.Verband,'Adr.Verband');
//    GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr');
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    ConvertLKZ(var Adr.LKZ);
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');

    GetAlpha(Adr.Postfach.PLZ,'Adr.Post.PLZ');
    GetAlpha(vA,'Adr.Post.Straße');
    vA # Str_ReplaceAll(vA,'Postfach','');
    Adr.Postfach # StrCut(StrAdj(vA,_strAll),1,10);

    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
    GetBool(Adr.SperrKundeYN,'Adr.Sperrung');
    GetBool(Adr.SperrLieferantYN,'Adr.Sperrung');
    GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
//    GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    //GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    //GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    //GetAlpha(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr');
    //GetAlpha(Adr.Bank2.Name,'Adr.Bank2.Name');
    //GetAlpha(Adr.Bank2.BLZ,'Adr.Bank2.BLZ');
    //GetAlpha(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr');

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
    //GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
    //GetWord(Adr.VK.Versandart,'Adr.VK.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
    //GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
    GetBool(Adr.VK.SammelReYN,'Adr.Sammelrechnung?');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
    //GetAlpha(Adr.Steuernummer,'Adr.Steuernummer');
    GetWord("Adr.Steuerschlüssel",'Adr.Steuerschlüssel');
    GetAlphaUP(Adr.Sprache,'Adr.DefiniertAlpha2');
    GetAlpha(Adr.VK.Referenznr,'Adr.DefiniertAlpha1');
    Getnum(vF,'Adr.DefiniertNum2');
    if (vF=999.0) then "Adr.BonusempfängerYN" # y;
    if (Adr.Sprache='') then Adr.Sprache # 'D';
    //GetAlpha(Adr.AbmessungEH,'Adr.AbmessungEH');
    //GetAlpha(Adr.GewichtEH,'Adr.GewichtEH');

    //if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;

    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx<>0) then begin
      TRANSBRK;
      DBADisconnect(2)
      Msg(999999,'Adr. nicht speicherbar',0,0,0);
      RETURN;
    end;

    Adr.Kreditnummer # Adr.Nummer;

    Adr.Anlage.Datum # today;
    Adr.Anlage.Zeit   # now;
    Adr.Anlage.User   # gUsername;
    Erx # Erxsert(100,0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      DBADisconnect(2)
      Msg(999999,'Adr. nicht anlegbar',0,0,0);
      RETURN;
    end;

    // 1. Anschrift
    Erx # RecLink(101,100,12,_recFirsT);
    if (Erx=_rOK) then begin
      RecRead(101,1,_recLock);
      Getnum(Adr.A.EntfernungKm,'Adr.DefiniertNum1');
      Erx # Erxace(101,_recUnlock,'AUTO');
    end;


    // Kreditlimitdaten...
    Erx # RecLink(2104,2100,17,_recFirst);
    if (Erx>_rLocked) then RecBufCleaR(2104);
    RecRead(103,1,_RecLock);
    GetAlphaMAX(Adr.K.Versicherer,  'Adr.K.Versicherer',20);
    GetAlpha(Adr.K.Referenznr,      'Adr.K.Referenznr');
    GetWord("Adr.K.Währung",        'Adr.K.Währung');
    if ("Adr.K.Währung"=0) then "Adr.K.Währung" # 1;
    GetNum(Adr.K.VersichertFW,      'Adr.K.Kreditvers');
    Wae_Umrechnen(Adr.K.VersichertFW, "Adr.K.Währung", var Adr.K.VersichertW1,1);
    GetNum(Adr.K.KurzLimitFW,       'Adr.K.Kurzlimit');
    Wae_Umrechnen(Adr.K.KurzlimitFW, "Adr.K.Währung", var Adr.K.KurzlimitW1,1);
    GetDate(Adr.K.KurzLimit.Dat,    'Adr.K.KurzlimitBis');
    GetNum(Adr.K.InternLimit,       'Adr.K.Kreditlimit');
    Adr.K.InternKurz      # 0.0;
    Adr.K.InternKurz.Dat  # 0.0.0;
    Adr.K.Stichwort       # Adr.Stichwort;
    Erx # Erxace(103,_recUnlock,'AUTO');

    vTxt # TextOpen(15);
    TextRead(vTxt,'~it.100.'+cnvai(Adr.Kundennr,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',_TextDba2);
    TextLineWrite(vTxt, 1,'{\rtf1\ansi\deff0{\fonttbl{\f0\fnil\fcharset0 Arial;}}',_texTLineInsert);
    TextLineWrite(vTxt, 2,'{\colortbl ;\red0\green0\blue0;}',_texTLineInsert);
    TextLineWrite(vTxt, 3,'{\*\generator Msftedit 5.41.15.1503;}\viewkind4\uc1\pard\cf1\lang1031\fs20 ',_texTLineInsert);
    TextLineWrite(vTxt, TextInfo(vTxt,_TextLines)+1,'\par}',_texTLineInsert);
    TxtWrite(vTxt,'~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8) ,0);
    TextClose(vTxt);


    Erx # RecLink(2102,2100,11,_recFirst); // Ansprechpartner holen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(102);

      Adr.P.Adressnr # Adr.Nummer;
      GetWord(Adr.P.Nummer,'Adr.P.Nummer');


      GetAlpha(Adr.P.Vorname,'Adr.P.Vorname');
      GetAlpha(Adr.P.Name,'Adr.P.Nachname');
      GetAlpha(Adr.P.Titel,'Adr.P.Titel');
      GetAlpha(Adr.P.Telefon,'Adr.P.Telefon');
      GetAlpha(Adr.P.Telefax,'Adr.P.Telefax');
      GetAlpha(Adr.P.Mobil,'Adr.P.Mobiltelefon');
      GetAlpha(Adr.P.eMail,'Adr.P.eMail');

      GetAlpha(Adr.P.Abteilung,'Adr.P.Abteilung');
      GetAlpha(Adr.P.Funktion,'Adr.P.Funktion');
      GetAlpha(Adr.P.Vorgesetzter,'Adr.P.Vorgesetzter');
      //GetAlpha(Adr.P.Briefanrede,'Adr.P.Briefanrede');
      GetAlpha(Adr.P.Priv.LKZ,'Adr.P.Priv.LKZ');
      ConvertLKZ(var Adr.P.Priv.LKZ);
      GetAlpha(Adr.P.Priv.PLZ,'Adr.P.Priv.PLZ');
      GetAlpha("Adr.P.Priv.Straße",'Adr.P.Priv.Straße');
      GetAlpha(Adr.P.Priv.Ort,'Adr.P.Priv.Ort');
      GetAlpha(Adr.P.Priv.Telefon,'Adr.P.Priv.Telefon');
      GetAlpha(Adr.P.Priv.Telefax,'Adr.P.Priv.Telefax');
      GetAlpha(Adr.P.Priv.eMail,'Adr.P.Priv.eMail');
      GetAlpha(Adr.P.Priv.Mobil,'Adr.P.Priv.Mobil');

      GetAlpha(Adr.P.Familienstand,'Adr.P.Familienstand');
      //GetAlpha(Adr.P.Hobbies,'Adr.P.Hobbies');
      GetAlpha(Adr.P.Vorlieben,'Adr.P.Vorlieben');
      GetAlpha(Adr.P.Auto,'Adr.P.Auto');
      GetAlpha(Adr.P.Religion,'Adr.P.Religion');
      GetAlpha(Adr.P.Partner.Name,'Adr.P.Partner');
      GetAlpha(Adr.P.Kind1.Name,'Adr.P.Kind1.Name');
      GetAlpha(Adr.P.Kind2.Name,'Adr.P.Kind2.Name');
      GetAlpha(Adr.P.Kind3.Name,'Adr.P.Kind3.Name');
      GetAlpha(Adr.P.Kind4.Name,'Adr.P.Kind4.Name');

      GetDate(Adr.P.Geburtsdatum,'Adr.P.Geburtsdatum');
      GetDate(Adr.P.Partner.GebTag,'Adr.P.PartnerGeb');
      GetDate(Adr.P.Hochzeitstag,'Adr.P.Hochzeitstag');
      GetDate(Adr.P.Kind1.GebTag,'Adr.P.Kind1.Geb');
      GetDate(Adr.P.Kind2.GebTag,'Adr.P.Kind2.Geb');
      GetDate(Adr.P.Kind3.GebTag,'Adr.P.Kind3.Geb');
      GetDate(Adr.P.Kind4.GebTag,'Adr.P.Kind4.Geb');

      GetBool(Adr.P.PrivGeschenkYN,'Adr.P.GeschPriv?');

      Adr.P.Stichwort # StrCnv(StrCut(Adr.P.Name,1,20),_strUpper);

      Erx # Erxsert(102,0,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        DBADisconnect(2)
        Msg(999999,'Adr.P. nicht speicherbar',0,0,0);
        RETURN;
      end;

      Erx # RecLink(2102,2100,11,_recNext);
    END;


    Erx # RecLink(2101,2100,10,_recFirst); // Anschriften holen
    WHILE (Erx<=_rLocked) do begin
      RecBufClear(101);
      Adr.A.Adressnr    # Adr.Nummer;
      GetWord(Adr.A.Nummer,       'Adr.A.Nummer');
      if (Adr.A.Nummer=0) then Adr.A.Nummer # 99;
      Adr.A.Nummer # Adr.A.Nummer + 1;
      Adr.A.Stichwort   # Adr.Stichwort;
      GetAlpha(Adr.A.Anrede,      'Adr.A.Anrede');
      GetAlpha(Adr.A.Name,        'Adr.A.Name');
      GetAlpha(Adr.A.Zusatz,      'Adr.A.Zusatz');
      GetAlpha("Adr.A.Straße",    'Adr.A.Straße');
      GetAlpha(Adr.A.LKZ,         'Adr.A.LKZ');
      ConvertLKZ(var Adr.A.LKZ);
      GetAlpha(Adr.A.PLZ,         'Adr.A.PLZ');
      GetAlpha(Adr.A.Ort,         'Adr.A.Ort');
      Adr.A.Telefon       # '';
      Adr.A.Telefax       # '';
      Adr.A.eMail         # '';
      Adr.A.Vertreter     # 0;
      Adr.A.Tour          # '';
      Adr.A.EntfernungKm  # 0.0;
      GetAlpha(Adr.A.Warenannahme1,'Adr.A.Annahmezeit1');
      GetAlpha(Adr.A.Warenannahme2,'Adr.A.Annahmezeit2');
      GetAlpha(Adr.A.Warenannahme3,'Adr.A.Annahmezeit3');
      GetAlpha(Adr.A.Warenannahme4,'Adr.A.Annahmezeit4');
      GetAlpha(Adr.A.Warenannahme5,'Adr.A.Annahmezeit5');
      Erx # Erxsert(101,0,'AUTO');
      if (Erx<>_rOK) then begin
        //TRANSBRK;
        Msg(999999,'Anschriftenfehler bei '+adr.stichwort,0,0,0);
        //RETURN;
      end;

      Erx # RecLink(2101,2100,10,_recnext); // Anschriften holen
    END;

    Erx # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;


//========================================================================
//  Import_FLK
//
//========================================================================
sub Import_FLK()
local begin
  Anprechpartner : int;
  vTxt          : int;
end;
begin


  // ALLE ADRESSEN LÖSCHEN...
  Lib_Rec:ClearFile(100,'TEXT');
  Lib_Rec:ClearFile(101);
  Lib_REc:ClearFile(102);
  lib_Rec:ClearFile(103);
  lib_Rec:ClearFile(105);
  lib_Rec:ClearFile(106);
  Lib_Rec:ClearFile(109);


  Erx # DBAConnect(2,'X_','TCP:192.168.0.11','StahlControl','thomas','ares','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
//    GetInt(Adr.Verband,'Adr.Verband');
//    GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr');
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');
//    GetAlpha(Adr.Postfach.PLZ,'Adr.');
//    GetAlpha(Adr.Postfach,'Adr.');
    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
//    Get(Adr.Kredit,'Adr.');
    GetBool(Adr.SperrKundeYN,'Adr.SperrungKunde');
    GetBool(Adr.SperrLieferantYN,'Adr.SperrungLiefernt');
    GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
//    GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    GetAlphaMax(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr',15);
    GetAlphaMax(Adr.Bank2.Name,'Adr.Bank2.Name',32);
    GetAlphaMax(Adr.Bank2.BLZ,'Adr.Bank2.BLZ',15);
    GetAlphaMax(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr',15);

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
    GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');
    GetAlpha(Adr.EK.Referenznr,'Adr.KdNrbeiLieferant');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
    GetWord(Adr.VK.Versandart,'Adr.VK.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
    GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
    GetBool(Adr.VK.SammelReYN,'Adr.SammelrechnungJN');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
    GetAlpha(Adr.Steuernummer,'Adr.Steuernummer');
    GetWord("Adr.Steuerschlüssel",'Adr.Steuerschlüssel');
    GetAlphaUP(Adr.Sprache,'Adr.Sprachkennung');
    GetAlpha(Adr.AbmessungEH,'Adr.AbmessungEH');
    GetAlpha(Adr.GewichtEH,'Adr.GewichtEH');


    // alle verbundenen Daten anlegen:
    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx<>0) then begin
      TRANSBRK;
      DBADisconnect(2)
      Msg(999999,'Adr. nicht speicherbar',0,0,0);
      RETURN;
    end;

    Adr.Kreditnummer # Adr.Nummer;

    Adr.Anlage.Datum # today;
    Adr.Anlage.Zeit   # now;
    Adr.Anlage.User   # gUsername;
    Erx # Erxsert(100,0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      DBADisconnect(2)
      Msg(999999,'Adr. nicht anlegbar',0,0,0);
      RETURN;
    end;

    // 1. Anschrift
    Erx # RecLink(101,100,12,_recFirsT);
    if (Erx=_rOK) then begin
      RecRead(101,1,_recLock);
      Getnum(Adr.A.EntfernungKm,'Adr.DefiniertNum1');
      Erx # Erxace(101,_recUnlock,'AUTO');
    end;


    // Kreditlimitdaten...
    Erx # RecLink(2104,2100,17,_recFirst);
    if (Erx>_rLocked) then RecBufCleaR(2104);
    RecRead(103,1,_RecLock);
    GetAlphaMAX(Adr.K.Versicherer,  'Adr.K.Versicherer',20);
    GetAlpha(Adr.K.Referenznr,      'Adr.K.Referenznr');
    GetWord("Adr.K.Währung",        'Adr.K.Währung');
    if ("Adr.K.Währung"=0) then "Adr.K.Währung" # 1;
    GetNum(Adr.K.VersichertFW,      'Adr.K.Kreditvers');
    Wae_Umrechnen(Adr.K.VersichertFW, "Adr.K.Währung", var Adr.K.VersichertW1,1);
    GetNum(Adr.K.KurzLimitFW,       'Adr.K.Kurzlimit');
    Wae_Umrechnen(Adr.K.KurzlimitFW, "Adr.K.Währung", var Adr.K.KurzlimitW1,1);
    GetDate(Adr.K.KurzLimit.Dat,    'Adr.K.KurzlimitBis');
    GetNum(Adr.K.InternLimit,       'Adr.K.Internlimit');
    Adr.K.InternKurz      # 0.0;
    Adr.K.InternKurz.Dat  # 0.0.0;
    Adr.K.Stichwort       # Adr.Stichwort;
    Erx # Erxace(103,_recUnlock,'AUTO');

    vTxt # TextOpen(15);
    TextRead(vTxt,'~it.100.'+cnvai(Adr.Kundennr,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',_TextDba2);
    TextLineWrite(vTxt, 1,'{\rtf1\ansi\deff0{\fonttbl{\f0\fnil\fcharset0 Arial;}}',_texTLineInsert);
    TextLineWrite(vTxt, 2,'{\colortbl ;\red0\green0\blue0;}',_texTLineInsert);
    TextLineWrite(vTxt, 3,'{\*\generator Msftedit 5.41.15.1503;}\viewkind4\uc1\pard\cf1\lang1031\fs20 ',_texTLineInsert);
    TextLineWrite(vTxt, TextInfo(vTxt,_TextLines)+1,'\par}',_texTLineInsert);
    TxtWrite(vTxt,'~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8) ,0);
    TextClose(vTxt);


    Erx # RecLink(2102,2100,11,_recFirst); // Ansprechpartner holen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(102);

      Adr.P.Adressnr  # Adr.Nummer;
      Adr.P.Nummer    # 1;
//      GetWord(Adr.P.Nummer,'Adr.P.Nummer');


      GetAlpha(Adr.P.Vorname,'Adr.P.Vorname');
      GetAlpha(Adr.P.Name,'Adr.P.Nachname');
      if (Adr.P.Name='') then
        GetAlpha(Adr.P.Name,'Adr.P.Name');

      GetAlpha(Adr.P.Titel,'Adr.P.Titel');
      GetAlpha(Adr.P.Telefon,'Adr.P.Telefon');
      GetAlpha(Adr.P.Telefax,'Adr.P.Telefax');
      GetAlpha(Adr.P.Mobil,'Adr.P.Mobiltelefon');
      GetAlpha(Adr.P.eMail,'Adr.P.eMail');

      GetAlpha(Adr.P.Abteilung,'Adr.P.Abteilung');
      GetAlpha(Adr.P.Funktion,'Adr.P.Funktion');
      GetAlpha(Adr.P.Vorgesetzter,'Adr.P.Vorgesetzter');
      //GetAlpha(Adr.P.Briefanrede,'Adr.P.Briefanrede');
      GetAlpha(Adr.P.Priv.LKZ,'Adr.P.Priv.LKZ');
      ConvertLKZ(var Adr.P.Priv.LKZ);
      GetAlpha(Adr.P.Priv.PLZ,'Adr.P.Priv.PLZ');
      GetAlpha("Adr.P.Priv.Straße",'Adr.P.Priv.Straße');
      GetAlpha(Adr.P.Priv.Ort,'Adr.P.Priv.Ort');
      GetAlpha(Adr.P.Priv.Telefon,'Adr.P.Priv.Telefon');
      GetAlpha(Adr.P.Priv.Telefax,'Adr.P.Priv.Telefax');
      GetAlpha(Adr.P.Priv.eMail,'Adr.P.Priv.eMail');
      GetAlpha(Adr.P.Priv.Mobil,'Adr.P.Priv.Mobil');

      GetAlpha(Adr.P.Familienstand,'Adr.P.Familienstand');
      //GetAlpha(Adr.P.Hobbies,'Adr.P.Hobbies');
      GetAlpha(Adr.P.Vorlieben,'Adr.P.Vorlieben');
      GetAlpha(Adr.P.Auto,'Adr.P.Auto');
      GetAlpha(Adr.P.Religion,'Adr.P.Religion');
      GetAlpha(Adr.P.Partner.Name,'Adr.P.Partner');
      GetAlpha(Adr.P.Kind1.Name,'Adr.P.Kind1.Name');
      GetAlpha(Adr.P.Kind2.Name,'Adr.P.Kind2.Name');
      GetAlpha(Adr.P.Kind3.Name,'Adr.P.Kind3.Name');
      GetAlpha(Adr.P.Kind4.Name,'Adr.P.Kind4.Name');

      GetDate(Adr.P.Geburtsdatum,'Adr.P.Geburtsdatum');
      GetDate(Adr.P.Partner.GebTag,'Adr.P.PartnerGeb');
      GetDate(Adr.P.Hochzeitstag,'Adr.P.Hochzeitstag');
      GetDate(Adr.P.Kind1.GebTag,'Adr.P.Kind1.Geb');
      GetDate(Adr.P.Kind2.GebTag,'Adr.P.Kind2.Geb');
      GetDate(Adr.P.Kind3.GebTag,'Adr.P.Kind3.Geb');
      GetDate(Adr.P.Kind4.GebTag,'Adr.P.Kind4.Geb');

      GetBool(Adr.P.PrivGeschenkYN,'Adr.P.GeschPriv?');

      Adr.P.Stichwort # StrCnv(StrCut(Adr.P.Name,1,20),_strUpper);


      REPEAT
        Erx # Erxsert(102,0,'MAN');
        if (erx<>_rOK) then Adr.P.Nummer # Adr.P.Nummer + 1;
      UNTIL (Erx=_rOK);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        DBADisconnect(2)
        Msg(999999,'Adr.P. nicht speicherbar',0,0,0);
        RETURN;
      end;

      Erx # RecLink(2102,2100,11,_recNext);
    END;


    Erx # RecLink(2101,2100,10,_recFirst); // Anschriften holen
    WHILE (Erx<=_rLocked) do begin
      RecBufClear(101);
      Adr.A.Adressnr    # Adr.Nummer;
      GetWord(Adr.A.Nummer,       'Adr.A.Nummer');
      if (Adr.A.Nummer=0) then Adr.A.Nummer # 99;
      Adr.A.Nummer # Adr.A.Nummer + 1;
      Adr.A.Stichwort   # Adr.Stichwort;
      GetAlpha(Adr.A.Anrede,      'Adr.A.Anrede');
      GetAlpha(Adr.A.Name,        'Adr.A.Name');
      GetAlpha(Adr.A.Zusatz,      'Adr.A.Zusatz');
      GetAlpha("Adr.A.Straße",    'Adr.A.Straße');
      GetAlpha(Adr.A.LKZ,         'Adr.A.LKZ');
      ConvertLKZ(var Adr.A.LKZ);
      GetAlpha(Adr.A.PLZ,         'Adr.A.PLZ');
      GetAlpha(Adr.A.Ort,         'Adr.A.Ort');
      Adr.A.Telefon       # '';
      Adr.A.Telefax       # '';
      Adr.A.eMail         # '';
      Adr.A.Vertreter     # 0;
      Adr.A.Tour          # '';
      Adr.A.EntfernungKm  # 0.0;
      GetAlpha(Adr.A.Warenannahme1,'Adr.A.Annahmezeit1');
      GetAlpha(Adr.A.Warenannahme2,'Adr.A.Annahmezeit2');
      GetAlpha(Adr.A.Warenannahme3,'Adr.A.Annahmezeit3');
      GetAlpha(Adr.A.Warenannahme4,'Adr.A.Annahmezeit4');
      GetAlpha(Adr.A.Warenannahme5,'Adr.A.Annahmezeit5');
      Erx # Erxsert(101,0,'AUTO');
      if (Erx<>_rOK) then begin
        //TRANSBRK;
        Msg(999999,'Anschriftenfehler bei '+adr.stichwort,0,0,0);
        //RETURN;
      end;

      Erx # RecLink(2101,2100,10,_recnext); // Anschriften holen
    END;


    Erx # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;


//========================================================================
//  Import JSN_Lief
//
//========================================================================
sub JSN_Lief()
local begin
  vDatei : alpha(250);
  vNr   : int;
  vFile : int;
  vMax  : int;
  vPos  : int;
  vA    : alpha(4000);
end;
begin

  vDatei # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');
  if(vDatei <> '') then begin

    vFile # FSIOpen(vDatei, _FsiStdRead );
    if (vFile<=0) then begin
      Gv.Alpha.01     # Translate('Datei nicht lesbar:')+' '+vDatei;
      todo('?')
      RETURN;
    end;
    vMax # FsiSize(vFile);

    vPos # FsiSeek(vFile);
    WHILE (vPos<vMax) do begin

      RecBufClear(100);
      RecBufClear(102);
      RecBufClear(103);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Adr.LieferantenNr # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Stichwort # Lib_Strings:Strings_WIN2DOS(vA);
      FSIRead(vFile, vA);
      Adr.Name # Lib_Strings:Strings_WIN2DOS(vA);
      FSIRead(vFile, vA);
      Adr.Zusatz # Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      GV.Alpha.50 # vA;
      FSIRead(vFile, vA);
      Adr.Postfach.PLZ # vA;
      FSIRead(vFile, vA);
      Adr.Postfach # StrCut(vA,1,10);
      FSIRead(vFile, vA);
      Adr.PLZ # StrCut(vA,1,8);
      FSIRead(vFile, vA);
      "Adr.Straße" # Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      Adr.Ort # Lib_Strings:Strings_WIN2DOS(vA);
      FSIRead(vFile, vA);
      Adr.Telefon1 # vA; // tel1
      FSIRead(vFile, vA);
      Adr.Telefon2 # vA; // tel2
      FSIRead(vFile, vA);
      Adr.Telefax # vA; // fax
      FSIRead(vFile, vA);
      Adr.Website # StrCut(vA,1,40); // inet
      FSIRead(vFile, vA);
      Adr.eMail # vA; // email
      FSIRead(vFile, vA);
      Adr.USIdentNr # vA; // ustid
      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      Adr.LKZ  # StrAdj(vA,_StrAll);
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      Adr.Sprache       # 'D';
      Adr.AbmessungEH   # 'mm';
      Adr.GewichtEH     # 'kg';

      // alle verbundenen Daten anlegen:
      Erx # Adr_Data:RecSave(y);
      if (Erx<>0) then begin
        Msg(999999,'Adr. nicht speicherbar',0,0,0);
        RETURN;
      end;

      Adr.Kreditnummer # Adr.Nummer;

      Adr.Anlage.Datum  # today;
      Adr.Anlage.Zeit   # now;
      Adr.Anlage.User   # gUsername;
      Erx # Erxsert(100,0,'AUTO');
      if (Erx<>_rOK) then begin
        Msg(999999,'Adr. nicht anlegbar',0,0,0);
        RETURN;
      end;

      RecRead(103,1,_RecLock);
      Adr.K.VersichertFW # GV.Num.01;
      Erx # Erxace(103,_recUnlock,'MAN');


      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

    Msg(99,'Lieferanten wurden importiert!',0,0,0);

  end;

end;


//========================================================================
//  Import JSN_Kunden
//
//========================================================================
sub JSN_Kunden()
local begin
  cDatei : alpha;
  vNr   : int;
  vFile : int;
  vMax  : int;
  vPos  : int;
  vA    : alpha(4000);
end;
begin

  cDatei # 'C:\Adressedatei.csv';

  todo('GEHT LOS');

  vFile # FSIOpen(cDatei, _FsiStdRead );
  if (vFile<=0) then begin
    Gv.Alpha.01     # Translate('Datei nicht lesbar:')+' '+cDatei;
    todo('?')
    RETURN;
  end;
  vMax # FsiSize(vFile);

  vPos # FsiSeek(vFile);
  WHILE (vPos<vMax) do begin

    RecBufClear(100);
    RecBufClear(103);

    FSIMark(vFile, 59);   /* ; */
    FSIRead(vFile, vA);
    Adr.KundenNr # cnvIA(vA);
    FSIRead(vFile, vA);
    Adr.Stichwort # Lib_Strings:Strings_WIN2DOS(vA);
    FSIRead(vFile, vA);
    Adr.Name # Lib_Strings:Strings_WIN2DOS(vA);
    FSIRead(vFile, vA);
    Adr.Zusatz # Lib_Strings:Strings_WIN2DOS(vA);
    FSIRead(vFile, vA);
    GV.Alpha.50 # vA;
    FSIRead(vFile, vA);
    Adr.Postfach.PLZ # vA;
    FSIRead(vFile, vA);
    Adr.Postfach # StrCut(vA,1,10);
    FSIRead(vFile, vA);
    Adr.PLZ # StrCut(vA,1,8);
    FSIRead(vFile, vA);
    "Adr.Straße" # Lib_Strings:Strings_WIN2DOS(vA);
    FSIRead(vFile, vA);
    Adr.Ort # Lib_Strings:Strings_WIN2DOS(vA);
    FSIRead(vFile, vA);
    Adr.Vertreter # cnvIA(vA);
    FSIRead(vFile, vA);
    Adr.Bemerkung # Lib_Strings:Strings_WIN2DOS(vA);
    FSIRead(vFile, vA);
    GV.Num.01 # cnvFA(vA); // Kreditlimit
    FSIRead(vFile, vA);
    GV.Alpha.50 # vA; //
    FSIRead(vFile, vA);
    GV.Alpha.50 # vA; //
    FSIRead(vFile, vA);
    Adr.Telefon1 # vA; // tel1
    FSIRead(vFile, vA);
    Adr.Telefon2 # vA; // tel2
    FSIRead(vFile, vA);
    Adr.Telefax # vA; // fax
    FSIRead(vFile, vA);
    Adr.Website # StrCut(vA,1,40); // inet
    FSIRead(vFile, vA);
    Adr.eMail # vA; // email
    FSIRead(vFile, vA);
    Adr.USIdentNr # vA; // ustid
    FSIMark(vFile, 13);   /* CR */
    FSIRead(vFile, vA);
    //letzter
    if(Adr.USIdentNr = '') then
      Adr.USIdentNr  # vA;
    else
      GV.Alpha.50 # vA;
    FSIMark(vFile, 10);   /* LF */
    FSIRead(vFile, vA);

    Adr.Sprache       # 'D';
    Adr.AbmessungEH   # 'mm';
    Adr.GewichtEH     # 'kg';


    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx<>0) then begin
      Msg(999999,'Adr. nicht speicherbar',0,0,0);
      RETURN;
    end;

    Adr.Kreditnummer # Adr.Nummer;

    Adr.Anlage.Datum # today;
    Adr.Anlage.Zeit   # now;
    Adr.Anlage.User   # gUsername;
    Erx # Erxsert(100,0,'AUTO');
    if (Erx<>_rOK) then begin
      Msg(999999,'Adr. nicht anlegbar',0,0,0);
      RETURN;
    end;

    RecRead(103,1,_RecLock);
    Adr.K.VersichertFW # GV.Num.01;
    Erx # Erxace(103,_recUnlock,'MAN');




    vPos # FsiSeek(vFile);
  END;

  FSIClose(vFile);

  Msg(99,'Adressen wurden importiert!',0,0,0);

end;




/************************************************************************
  Import Venus

************************************************************************/
sub Import_Venus()
local begin
  vDatei : alpha(250);
  vNr   : int;
  vFile : int;
  vMax  : int;
  vPos  : int;
  vA    : alpha(4000);
  vAdr.P : logic;
end;
begin

  vDatei # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');
  if(vDatei <> '') then begin

    vFile # FSIOpen(vDatei, _FsiStdRead );
    if (vFile<=0) then begin
      Gv.Alpha.01     # Translate('Datei nicht lesbar:')+' '+vDatei;
      todo('?')
      RETURN;
    end;
    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);
    WHILE (vPos<vMax) do begin

      vAdr.P # true;

      RecBufClear(100);
      RecBufClear(102);
      RecBufClear(103);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Adr.Kundennr # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Stichwort # Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,20));
      FSIRead(vFile, vA);
      Adr.Name # Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      GV.Alpha.50 # vA;
      FSIRead(vFile, vA);
      GV.Alpha.50 # vA;
      FSIRead(vFile, vA);
      Adr.Zusatz # Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      if(vA = '' ) then
        vAdr.P # false;
      Adr.P.Stichwort # StrCut(vA,1,20); // ANSPRECHPARTNER !!!
      Adr.P.Name # vA; // ANSPRECHPARTNER !!!
      FSIRead(vFile, vA);
      Adr.PLZ # StrCut(vA,1,8);
      FSIRead(vFile, vA);
      Adr.Ort # Lib_Strings:Strings_WIN2DOS(vA);
      FSIRead(vFile, vA);
      "Adr.Straße" # Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      "Adr.Straße" # "Adr.Straße" + ' ' + vA;
      FSIRead(vFile, vA);
      Adr.Telefon1 # vA; // tel1
      FSIRead(vFile, vA);
      Adr.Telefon2 # vA; // tel2
      FSIRead(vFile, vA);
      Adr.Telefax # vA; // fax
      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      Erx # StrFind(vA,';',1);
      if(vA <> '') and (Erx = 0) then
        Adr.eMail # StrCut(vA,1,80); // email
      else
        Adr.eMail # '';
      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      Adr.Sprache       # 'D';
      Adr.AbmessungEH   # 'mm';
      Adr.GewichtEH     # 'kg';

      Adr.VK.Lieferbed    # 99;
      Adr.VK.Zahlungsbed  # 99;
      Adr.VK.Versandart   # 99;
      "Adr.VK.Währung"    # 1;
      Adr.VK.Verwiegeart  # 99;
      Adr.VK.Fusstext     # 99;
      Adr.Kreditnummer    # 99;



      // alle verbundenen Daten anlegen:
      Erx # Adr_Data:RecSave(y);
      if (Erx<>0) then begin
        Msg(999999,'Adr. nicht speicherbar',0,0,0);
        RETURN;
      end;

      Adr.Kreditnummer # Adr.Nummer;
      Adr.Anlage.Datum  # today;
      Adr.Anlage.Zeit   # now;
      Adr.Anlage.User   # gUsername;
      Erx # Erxsert(100,0,'AUTO');
      if (Erx<>_rOK) then begin
        Msg(999999,'Adr. nicht anlegbar',0,0,0);
        RETURN;
      end;

      RecRead(103,1,_RecLock);
      Adr.K.VersichertFW # GV.Num.01;
      Erx # RekReplace(103,_recUnlock,'MAN');

      Adr.P.Adressnr # Adr.Nummer;
      Adr.P.Nummer   # 1;

      if(vAdr.P)then begin
        Erx # Erxsert(102,0,'AUTO'); // Ansprechpartner hinzufuegen
        if(Erx <> _rOK) then begin
          Msg(999999,'Ansprechpartner nicht anlegbar',0,0,0);
          RETURN;
        end;
      end;

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

    Msg(99,'Kunden wurden importiert!',0,0,0);

  end;

end;

//========================================================================
//  Import_XTEC
//
//========================================================================
sub Import_XTEC()
local begin
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: ' + vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);


    WHILE (vPos<vMax) do begin

      RecBufClear(100);
      RecBufClear(103);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Adr.Nummer # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.KundenNr # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.KundenBuchNr # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.LieferantenNr # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.LieferantBuchNr # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Stichwort #  Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,20));
      FSIRead(vFile, vA);
      Adr.Gruppe # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      Adr.Sachbearbeiter # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      Adr.Vertreter # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Verband # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VerbandRefNr # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      Adr.ABC # StrCut(vA,1,1);
      FSIRead(vFile, vA);
      Adr.Punktzahl # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Anrede # StrCut(vA,1,40);
      FSIRead(vFile, vA);
      Adr.Name #  Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      Adr.Zusatz #  Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      "Adr.Straße" #  Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      Adr.LKZ # StrCut(vA,1,3);
      FSIRead(vFile, vA);
      Adr.PLZ # StrCut(vA,1,8);
      FSIRead(vFile, vA);
      Adr.Postfach.PLZ # StrCut(vA,1,10);
      FSIRead(vFile, vA);
      Adr.Postfach # StrCut(vA,1,10);
      FSIRead(vFile, vA);
      Adr.Ort #  Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);
      Adr.Telefon1 # StrCut(vA,1,32);
      FSIRead(vFile, vA);
      Adr.Telefon2 # StrCut(vA,1,32);
      FSIRead(vFile, vA);
      Adr.Telefax # StrCut(vA,1,32);
      FSIRead(vFile, vA);
      Adr.eMail # StrCut(vA,1,80);
      FSIRead(vFile, vA);
      Adr.Website # StrCut(vA,1,160);
      FSIRead(vFile, vA);
      Adr.Briefanrede # StrCut(vA,1,64);
      FSIRead(vFile, vA);
      Adr.Briefgruppe # StrCut(vA,1,8);
      FSIRead(vFile, vA);
      Adr.Kreditnummer # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.SperrKundeYN # cnvLI(cnvIA(vA));
      FSIRead(vFile, vA);
      Adr.SperrLieferantYN # cnvLI(cnvIA(vA));
      FSIRead(vFile, vA);
      Adr.Sperrvermerk # StrCut(vA,1,64);
      FSIRead(vFile, vA);
      Adr.Bemerkung # StrCut(vA,1,128);
      FSIRead(vFile, vA);
      Adr.Vertreter2 # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Vertr1.Prov # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Vertr2.Prov # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Bank1.Name # StrCut(vA,1,32);
      FSIRead(vFile, vA);
      Adr.Bank1.BLZ # StrCut(vA,1,15);
      FSIRead(vFile, vA);
      Adr.Bank1.Kontonr # StrCut(vA,1,15);
      FSIRead(vFile, vA);
      Adr.Bank1.IBAN # StrCut(vA,1,40);
      FSIRead(vFile, vA);
      Adr.Bank1.BIC.SWIFT # StrCut(vA,1,16);
      FSIRead(vFile, vA);
      Adr.Bank2.Name # StrCut(vA,1,32);
      FSIRead(vFile, vA);
      Adr.Bank2.BLZ # StrCut(vA,1,15);
      FSIRead(vFile, vA);
      Adr.Bank2.Kontonr # StrCut(vA,1,15);
      FSIRead(vFile, vA);
      Adr.Bank2.IBAN # StrCut(vA,1,40);
      FSIRead(vFile, vA);
      Adr.Bank2.BIC.SWIFT # StrCut(vA,1,16);
      FSIRead(vFile, vA);
      Adr.EK.Lieferbed # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.EK.Zahlungsbed # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.EK.Versandart # cnvIA(vA);
      FSIRead(vFile, vA);
      "Adr.EK.Währung" # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.EK.Referenznr # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      Adr.EK.Fusstext # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VK.Lieferbed # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VK.Zahlungsbed # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VK.Versandart # cnvIA(vA);
      FSIRead(vFile, vA);
      "Adr.VK.Währung" # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VK.Referenznr # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      "Adr.VK.ReEmpfänger" # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VK.SammelReYN # cnvLI(cnvIA(vA));
      FSIRead(vFile, vA);
      Adr.VK.Verwiegeart # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.VK.Fusstext # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.UsIdentNr # StrCut(vA,1,16);
      FSIRead(vFile, vA);
      Adr.Steuernummer # StrCut(vA,1,16);
      FSIRead(vFile, vA);
      "Adr.Steuerschlüssel" # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Sprache # StrCut(vA,1,3);
      FSIRead(vFile, vA);
      Adr.AbmessungEH # StrCut(vA,1,5);
      FSIRead(vFile, vA);
      Adr.GewichtEH # StrCut(vA,1,3);
      FSIRead(vFile, vA);
      Adr.Pfad.Bild # StrCut(vA,1,128);
      FSIRead(vFile, vA);
      Adr.Pfad.Doks # StrCut(vA,1,128);
      FSIRead(vFile, vA);
      "Adr.BonusEmpfängerYN"  # cnvLI(cnvIA(vA));
      FSIRead(vFile, vA);
      "Adr.BonusProz" # cnvFA(vA);
      FSIRead(vFile, vA);
      if(vA <> '') then
        Adr.Fibudatum.Kd # cnvDA(vA);
      FSIRead(vFile, vA);
      if(vA <> '') then
        Adr.Anlage.Datum # cnvDA(vA);
      FSIRead(vFile, vA);
      if(vA <> '') then
        Adr.Anlage.Zeit # cnvTA(vA);
      FSIRead(vFile, vA);
      Adr.Anlage.User # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      if(vA <> '') then
        "Adr.Änderung.Datum" # cnvDA(vA);
      FSIRead(vFile, vA);
      if(vA <> '') then
        "Adr.Änderung.Zeit" # cnvTA(vA);
      FSIRead(vFile, vA);
      "Adr.Änderung.User" # StrCut(vA,1,20);
      FSIRead(vFile, vA);
      Adr.Fin.Vzg.FixTag # cnvIA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.Vzg.Offset # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.Vzg.AnzZhlg # cnvIA(vA);
      FSIRead(vFile, vA);
      if(vA <> '') then
        Adr.Fin.letzterAufAm # cnvDA(vA);
      FSIRead(vFile, vA);
      if(vA <> '') then
        Adr.Fin.letzteReAm # cnvDA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.SummeOP # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.SummeAB # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.SummeABBere # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.SummeLFS # cnvFA(vA);
      FSIRead(vFile, vA);
      Adr.Fin.SummeRes # cnvFA(vA);
      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);

      //letzter
      if(vA <> '') then
        Adr.Fin.Refreshdatum # cnvDA(vA);

      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);



      // alle verbundenen Daten anlegen:
      Erx # Adr_Data:RecSave(y);
      if (Erx<>0) then begin
        Msg(999999,'Adr. nicht speicherbar',0,0,0);
        RETURN;
      end;

      Adr.Kreditnummer # Adr.Nummer;
      Adr.Anlage.Datum  # today;
      Adr.Anlage.Zeit   # now;
      Adr.Anlage.User   # gUsername;
      Erx # Erxsert(100,0,'AUTO');
      if (Erx<>_rOK) then begin
        Msg(999999,'Adr. nicht anlegbar',0,0,0);
        RETURN;
      end;

      RecRead(103,1,_RecLock);
      Adr.K.VersichertFW # GV.Num.01;
      Erx # RekReplace(103,_recUnlock,'MAN');

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

    Msg(99,'Adressen wurden importiert!',0,0,0);
  end;
end;

//========================================================================
//  Import_FL
//
//========================================================================
sub Import_FL()
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.0.2','!FL','user','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!');
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
    // FL GetInt(Adr.Verband,'Adr.Verband');
    // FL GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr');
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');
//    GetAlpha(Adr.Postfach.PLZ,'Adr.');
//    GetAlpha(Adr.Postfach,'Adr.');
    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
//    Get(Adr.Kredit,'Adr.');
    // FL GetBool(Adr.SperrKundeYN,'Adr.Sperrung');
    // FL GetBool(Adr.SperrLieferantYN,'Adr.Sperrung');
    // FL GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
    // FL GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    GetAlphaMax(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr',15);
    GetAlpha(Adr.Bank2.Name,'Adr.Bank2.Name');
    GetAlpha(Adr.Bank2.BLZ,'Adr.Bank2.BLZ');
    GetAlphaMax(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr',15);

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
    GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');
    GetAlpha(Adr.EK.Referenznr,'Adr.KdNrbeiLieferant');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
    // FL GetWord(Adr.VK.Versandart,'Adr.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
    GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
    GetBool(Adr.VK.SammelReYN,'Adr.SammelrechnungJN');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
//    GetAlpha(Adr.Steuernummer,'Adr.');
    // FL GetWord("Adr.Steuerschlüssel",'Adr.Steuerart');
//    GetAlpha(Adr.Sprache,'Adr.');
//    GetAlpha(Adr.AbmessungEH,'Adr.');
//    GetAlpha(Adr.GewichtEH,'Adr.');


    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx>0) then begin
      TRANSBRK;
      Msg(100003,'',0,0,0);
      RETURN;
    end;
    if (Erx<0) then begin
      TRANSBRK;
      RETURN;
    end;

    if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;
    Erx # Erxsert(100,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;

/*
xxx
loop partner
*/

    Erx # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;
//========================================================================

//========================================================================
//  Import_MTD
//    Metal-Traders Düsseldorf
//========================================================================
sub Import_MTD()
local begin
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
  vClear    : logic;
end;
begin

  vClear # false;
  if (Msg(99,'Wollen Sie Vertreter leeren?',_WinIcoQuestion,_WinDialogYesNo,2) = _winidYes) then
    vClear # true;

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: ' + vName,0,0,0);
      RETURN;
    end;

    if(vClear) then begin
      // Adressen 100   LÖSCHEN
      Lib_Rec:ClearFile(100);         // Hauptdaten
      Lib_Rec:ClearFile(101);         // Anschriften
      Lib_Rec:ClearFile(102);         // Ansprechpartner
      Lib_Rec:ClearFile(103);         // Kreditlimit
      Lib_Rec:ClearFile(105);         // Verpackungen
      Lib_Rec:ClearFile(106);         // +Ausführungen
      Lib_Texte:TxtDelRange('~100','~109');
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);


    WHILE (vPos<vMax) do begin

      RecBufClear(100);
      RecBufClear(103);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      Adr.KundenNr # cnvIA(vA);                                               /*1  KundenNr*/
      FSIRead(vFile, vA);
      Adr.LieferantenNr # cnvIA(vA);                                          /*2  LiefNr*/
      FSIRead(vFile, vA);
      Adr.Stichwort #  StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 20);        /*3  Stichwort*/
      FSIRead(vFile, vA);
      Adr.Name # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);              /*4  Name*/
      FSIRead(vFile, vA);
      Adr.Zusatz # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);            /*5  Zusatz*/
      FSIRead(vFile, vA);
      "Adr.Straße" # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);          /*6  Straße*/
      FSIRead(vFile, vA);
      Adr.PLZ # StrCut(vA,1 , 8);                                             /*7  PLZ  */
      FSIRead(vFile, vA);
      Adr.Ort # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);               /*8  Ort*/

      FSIRead(vFile, vA);
      Adr.Postfach.PLZ # StrCut(vA,1 , 8);                                     /*9 PLZ vom Postfach*/

      FSIRead(vFile, vA);
      Adr.Postfach  # StrCut(vA,1 ,10);                                        /*10 Postfachnummer */

      FSIRead(vFile, vA);
      Adr.LKZ # StrCut(vA, 1, 3);                                             /*11  LKZ*/
      FSIRead(vFile, vA);
      "Adr.Steuerschlüssel" # cnvIA(vA);                                      /*12 Steuerschl*/
      FSIRead(vFile, vA);                                                   /*13 SPRACHE?*/
      Adr.Sprache # vA;

      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);

      //letzter
      Adr.USIdentNr # StrCnv(StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 16),_StrLetter);         /*14  USt*/

      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      Adr.VK.Lieferbed     # 1;
      Adr.VK.Zahlungsbed   # 1;
      Adr.VK.Versandart    # 1;
      "Adr.VK.Währung"     # 1;

      Adr.EK.Lieferbed     # 1;
      Adr.EK.Zahlungsbed   # 1;
      Adr.EK.Versandart    # 1;
      "Adr.EK.Währung"     # 1;

      Adr.AbmessungEH      # 'mm';
      Adr.GewichtEH        # 'kg';

      // alle verbundenen Daten anlegen:
      Erx # Adr_Data:RecSave(y);
      if (Erx<>0) then begin
        Msg(999999,'Adr. nicht speicherbar',0,0,0);
        CYCLE;
      end;

      Adr.Kreditnummer # Adr.Nummer;
      Adr.Anlage.Datum  # today;
      Adr.Anlage.Zeit   # now;
      Adr.Anlage.User   # gUsername;
      Erx # RekInsert(100,0,'AUTO');
      if (Erx<>_rOK) then begin
        Msg(999999,'Adr. nicht anlegbar',0,0,0);
        CYCLE;
      end;

      /*
      RecRead(103,1,_RecLock);
      Adr.K.VersichertFW # GV.Num.01;

      Erx # RekReplace(103,_recUnlock,'MAN');
      */
      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

    Msg(99,'Adressen wurden importiert!',0,0,0);
  end;
end;

//========================================================================
//  call Import_Adr:Import_ProPipe
//    ProPipe
//========================================================================
sub Import_ProPipe()
local begin
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;
  vClear    : logic;
end;
begin

  vClear # false;
  if (Msg(99,'Adressdaten leeren (Hauptdaten / Anschriften / Ansprechpartner / Kreditlimit / Verpackungen / Ausfuehrungen)?',_WinIcoQuestion,_WinDialogYesNo,2) = _winidYes) then
    vClear # true;

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin
    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: ' + vName,0,0,0);
      RETURN;
    end;

    if(vClear) then begin
      // Adressen 100   LÖSCHEN
      Lib_Rec:ClearFile(100);         // Hauptdaten
      Lib_Rec:ClearFile(101);         // Anschriften
      Lib_Rec:ClearFile(102);         // Ansprechpartner
      Lib_Rec:ClearFile(103);         // Kreditlimit
      Lib_Rec:ClearFile(105);         // Verpackungen
      Lib_Rec:ClearFile(106);         // +Ausführungen
      Lib_Texte:TxtDelRange('~100','~109');
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);


    WHILE (vPos<vMax) do begin

      RecBufClear(100);
      RecBufClear(103);

      FSIMark(vFile, 59);   /* ; */

      FSIRead(vFile, vA);   // Kd.Nr.
      Adr.KundenNr  # cnvIA(vA);
      FSIRead(vFile, vA);   // Kd.Buch.Nr.
      Adr.KundenBuchNr  # cnvIA(vA);
      FSIRead(vFile, vA);   // Lf.Nr.
      Adr.LieferantenNr  # cnvIA(vA);
      FSIRead(vFile, vA);   // Lf.Buch.Nr.
      Adr.LieferantBuchNr  # cnvIA(vA);
      FSIRead(vFile, vA);   // Stichwort
      Adr.Stichwort #  StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 20);        // Stichwort
      FSIRead(vFile, vA);   // Gruppe
      Adr.Gruppe  # vA;
      FSIRead(vFile, vA);   // Sachbearbeiter
      Adr.Sachbearbeiter # vA;
      FSIRead(vFile, vA);   // Vertreter
      Adr.Vertreter  # cnvIA(vA);
      FSIRead(vFile, vA);   // Verband
      Adr.Verband  # cnvIA(vA);
      FSIRead(vFile, vA);   // Verbandref. Nr.
      Adr.VerbandRefNr  # vA;
      FSIRead(vFile, vA);   // ABC
      Adr.ABC # vA;
      FSIRead(vFile, vA);   // Punktzahl
      Adr.Punktzahl # cnvIA(vA);
      FSIRead(vFile, vA);   // Anrede
      Adr.Anrede # vA;
      FSIRead(vFile, vA);   // Name
       Adr.Name # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);              //  Name
      FSIRead(vFile, vA);
      Adr.Zusatz # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);            //  Zusatz
      FSIRead(vFile, vA);
      "Adr.Straße" # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);          //  Straße
      FSIRead(vFile, vA);   // LKZ
      Adr.LKZ # vA;
      FSIRead(vFile, vA);   // PLZ
      Adr.PLZ # vA;
      FSIRead(vFile, vA);   // Postfach PLZ
      Adr.Postfach.PLZ # vA;
      FSIRead(vFile, vA);   // Postfach
      Adr.Postfach # vA;
      FSIRead(vFile, vA);   // Ort
      Adr.Ort #  Lib_Strings:Strings_WIN2DOS(StrCut(vA,1,40));
      FSIRead(vFile, vA);   // Telefon1
      Adr.Telefon1 # vA;
      FSIRead(vFile, vA);   // Telefon2
      Adr.Telefon2 # vA;
      FSIRead(vFile, vA);   // Telefax
      Adr.Telefax # vA;
      FSIRead(vFile, vA);   // VK Lieferb
      Adr.VK.Lieferbed  # cnvIA(vA);
      FSIRead(vFile, vA);   // VK Zahlungsb
      Adr.VK.Zahlungsbed  # cnvIA(vA);
      FSIRead(vFile, vA);   // VK Versandart
      Adr.VK.Versandart  # cnvIA(vA);
      FSIRead(vFile, vA);   // VK Waehrung
      "Adr.VK.Währung"  # cnvIA(vA);
      FSIRead(vFile, vA);   // USIdent
      Adr.USIdentNr # vA;
      FSIRead(vFile, vA);   // Sts.Nummer
      Adr.Steuernummer # vA;
      FSIRead(vFile, vA);   // Sts.Schluessel
      "Adr.Steuerschlüssel"   # cnvIA(vA);
      FSIRead(vFile, vA);   // Sprache
      Adr.Sprache # vA;
      FSIRead(vFile, vA);   // Abmessung Einheit
      Adr.AbmessungEH # vA;



      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      Adr.GewichtEH # vA;

      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

/*
      Adr.VK.Lieferbed     # 1;
      Adr.VK.Zahlungsbed   # 1;
      Adr.VK.Versandart    # 1;
      "Adr.VK.Währung"     # 1;

      Adr.EK.Lieferbed     # 1;
      Adr.EK.Zahlungsbed   # 1;
      Adr.EK.Versandart    # 1;
      "Adr.EK.Währung"     # 1;

      Adr.AbmessungEH      # 'mm';
      Adr.GewichtEH        # 'kg';
*/
      // Adressnummer bestimmen!


      // alle verbundenen Daten anlegen:
      Erx # Adr_Data:RecSave(true);
      if (Erx<>0) then begin
        Msg(999999,'Adr. nicht speicherbar',0,0,0);
        CYCLE;
      end;

      Adr.Kreditnummer  # Adr.Nummer;
      Adr.Anlage.Datum  # today;
      Adr.Anlage.Zeit   # now;
      Adr.Anlage.User   # gUsername;
      Erx # Erxsert(100,0,'AUTO');
      if (Erx <> _rOK) then begin
        Msg(999999,'Adr. nicht anlegbar',0,0,0);
        CYCLE;
      end;

      /*
      RecRead(103,1,_RecLock);
      Adr.K.VersichertFW # GV.Num.01;

      Erx # Erxace(103,_recUnlock,'MAN');
      */
      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

    Msg(99,'Adressen wurden importiert!',0,0,0);
  end;
end;

//========================================================================

//========================================================================
// call Import_Adr:Import_Mertens
//
//========================================================================
sub Import_Mertens()
local begin
Ansprechpartner : int;
end;
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.10.1', 'StahlControl', 'thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
//    GetInt(Adr.Verband,'Adr.Verband');
//    GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr');
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');
//    GetAlpha(Adr.Postfach.PLZ,'Adr.');
//    GetAlpha(Adr.Postfach,'Adr.');
    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
//    Get(Adr.Kredit,'Adr.');
//    GetBool(Adr.SperrKundeYN,'Adr.SperrungKunde');
//    GetBool(Adr.SperrLieferantYN,'Adr.SperrungLiefernt');
    GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
//    GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    GetAlpha(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr');
    GetAlpha(Adr.Bank2.Name,'Adr.Bank2.Name');
    GetAlpha(Adr.Bank2.BLZ,'Adr.Bank2.BLZ');
    GetAlpha(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr');

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
//    GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');
//    GetAlpha(Adr.EK.Referenznr,'Adr.KdNrbeiLieferant');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
//    GetWord(Adr.VK.Versandart,'Adr.VK.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
//    GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
//    GetBool(Adr.VK.SammelReYN,'Adr.SammelrechnungJN');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
    //GetAlpha(Adr.Steuernummer,'Adr.Steuernummer');
    GetWord("Adr.Steuerschlüssel",'Adr.Steuerschlüssel');
    //GetAlphaUP(Adr.Sprache,'Adr.Sprachkennung');
    //GetAlpha(Adr.AbmessungEH,'Adr.AbmessungEH');
    //GetAlpha(Adr.GewichtEH,'Adr.GewichtEH');


    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx>0) then begin
      TRANSBRK;
      Msg(100003,'',0,0,0);
      RETURN;
    end;
    if (Erx<0) then begin
      TRANSBRK;
      RETURN;
    end;

    if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;
    Erx # Erxsert(100,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;

    Erx # RecLink(2102,2100,11,_recFirst); // Ansprechpartner holen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(102);

      Adr.P.Adressnr # Adr.Nummer;
      GetWord(Adr.P.Nummer,'Adr.P.Nummer');
//      GetAlpha(Adr.P.Vorname,'Adr.P.Vorname');
      GetAlpha(Adr.P.Name,'Adr.P.Name');
      //GetAlpha(Adr.P.Titel,'Adr.P.Titel');
      GetAlpha(Adr.P.Telefon,'Adr.P.Telefon');
      GetAlpha(Adr.P.Telefax,'Adr.P.Telefax');
      //GetAlpha(Adr.P.Mobil,'Adr.P.Mobiltelefon');
      GetAlpha(Adr.P.eMail,'Adr.P.eMail');

      //GetAlpha(Adr.P.Abteilung,'Adr.P.Abteilung');
      GetAlpha(Adr.P.Funktion,'Adr.P.Funktion');
      /*
      GetAlpha(Adr.P.Vorgesetzter,'Adr.P.Vorgesetzter');
      GetAlpha(Adr.P.Briefanrede,'Adr.P.Briefanrede');
      GetAlpha(Adr.P.Priv.LKZ,'Adr.P.Priv.LKZ');
      GetAlpha(Adr.P.Priv.PLZ,'Adr.P.Priv.PLZ');
      GetAlpha("Adr.P.Priv.Straße",'Adr.P.Priv.Straße');
      GetAlpha(Adr.P.Priv.Ort,'Adr.P.Priv.Ort');
      GetAlpha(Adr.P.Priv.Telefon,'Adr.P.Priv.Telefon');
      GetAlpha(Adr.P.Priv.Telefax,'Adr.P.Priv.Telefax');
      GetAlpha(Adr.P.Priv.eMail,'Adr.P.Priv.eMail');
      GetAlpha(Adr.P.Priv.Mobil,'Adr.P.Priv.Mobil');

      GetAlpha(Adr.P.Familienstand,'Adr.P.Familienstand');
      GetAlpha(Adr.P.Hobbies,'Adr.P.Hobbies');
      GetAlpha(Adr.P.Vorlieben,'Adr.P.Vorlieben');
      GetAlpha(Adr.P.Auto,'Adr.P.Auto');
      GetAlpha(Adr.P.Religion,'Adr.P.Religion');
      GetAlpha(Adr.P.Partner.Name,'Adr.P.Partner');
      GetAlpha(Adr.P.Kind1.Name,'Adr.P.Kind1.Name');
      GetAlpha(Adr.P.Kind2.Name,'Adr.P.Kind2.Name');
      GetAlpha(Adr.P.Kind3.Name,'Adr.P.Kind3.Name');
      GetAlpha(Adr.P.Kind4.Name,'Adr.P.Kind4.Name');

      GetDate(Adr.P.Geburtsdatum,'Adr.P.Geburtsdatum');
      GetDate(Adr.P.Partner.GebTag,'Adr.P.PartnerGeb');
      GetDate(Adr.P.Hochzeitstag,'Adr.P.Hochzeitstag');
      GetDate(Adr.P.Kind1.GebTag,'Adr.P.Kind1.Geb');
      GetDate(Adr.P.Kind2.GebTag,'Adr.P.Kind2.Geb');
      GetDate(Adr.P.Kind3.GebTag,'Adr.P.Kind3.Geb');
      GetDate(Adr.P.Kind4.GebTag,'Adr.P.Kind4.Geb');

      GetBool(Adr.P.PrivGeschenkYN,'Adr.P.GeschPriv?');
*/
      Erx # Erxsert(102,0,'MAN');

      Erx # RecLink(2102,2100,11,_recNext);
    END;



  Erg # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;


//========================================================================
//  Import_Neumann
//
//========================================================================
sub Import_Neumann()
local begin
Ansprechpartner : int;
end;
begin

  debugx('');
  Erx # DBAConnect(2,'X_','TCP:192.168.0.2','Neumann 4.7','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(100);
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

//    GetInt(Adr.Nummer,'Adr.Adressnummer');
    GetInt(Adr.Kundennr,'Adr.Kundennummer');
    GetInt(Adr.KundenBuchNr,'Adr.KdBuchungsnr');
    GetInt(Adr.Lieferantennr,'Adr.Lieferantennr');
    GetInt(Adr.LieferantBuchNr,'Adr.LfBuchungsnr');
    GetAlphaUp(Adr.Stichwort,'Adr.Stichwort');
    GetAlpha(Adr.Gruppe,'Adr.Gruppe');
    GetAlpha(Adr.Sachbearbeiter,'Adr.Sachbearbeiter');
    GetInt(Adr.Vertreter,'Adr.Vertreter');
//    GetInt(Adr.Verband,'Adr.Verband');
//    GetAlpha(Adr.VerbandRefNr,'Adr.VerbandsRefNr');
    GetAlpha(Adr.ABC,'Adr.ABC');
    GetWord(Adr.Punktzahl,'Adr.Punktzahl');
    GetAlpha(Adr.Anrede,'Adr.Haus.Anrede');
    GetAlpha(Adr.Name,'Adr.Haus.Name');
    GetAlpha(Adr.Zusatz,'Adr.Haus.Zusatz');
    GetAlpha("Adr.Straße",'Adr.Haus.Straße');
    GetAlpha(Adr.LKZ,'Adr.Haus.LKZ');
    GetAlpha(Adr.PLZ,'Adr.Haus.PLZ');
//    GetAlpha(Adr.Postfach.PLZ,'Adr.');
//    GetAlpha(Adr.Postfach,'Adr.');
    GetAlpha(Adr.Ort,'Adr.Haus.Ort');
    GetAlpha(Adr.Telefon1,'Adr.Telefon1');
    GetAlpha(Adr.Telefon2,'Adr.Telefon2');
    GetAlpha(Adr.Telefax,'Adr.Telefax');
    GetAlpha(Adr.eMail,'Adr.eMail');
    GetAlpha(Adr.Website,'Adr.Website');
    GetAlpha(Adr.Briefanrede,'Adr.Briefanrede');
    GetAlpha(Adr.Briefgruppe,'Adr.Briefgruppe');
//    Get(Adr.Kredit,'Adr.');
    GetBool(Adr.SperrKundeYN,'Adr.SperrungKunde');
    GetBool(Adr.SperrLieferantYN,'Adr.SperrungLiefernt');
    GetAlpha(Adr.Sperrvermerk,'Adr.Sperrvermerk');
    GetAlpha(Adr.Bemerkung,'Adr.Bemerkung');
//    GetInt(Adr.Vertreter2,'Adr.');
//    GetNum(Adr.Vertr1.Prov,'Adr.Vert.Provision');
//    GetNum(Adr.Vertr2.Prov,'Adr.');

    // ----
    GetAlpha(Adr.Bank1.Name,'Adr.Bank1.Name');
    GetAlpha(Adr.Bank1.BLZ,'Adr.Bank1.BLZ');
    GetAlpha(Adr.Bank1.Kontonr,'Adr.Bank1.Kontonr');
    GetAlpha(Adr.Bank2.Name,'Adr.Bank2.Name');
    GetAlpha(Adr.Bank2.BLZ,'Adr.Bank2.BLZ');
    GetAlpha(Adr.Bank2.Kontonr,'Adr.Bank2.Kontonr');

    // ---
    GetWord(Adr.EK.Lieferbed,'Adr.EK.Lieferbed');
    GetWord(Adr.EK.Zahlungsbed,'Adr.EK.Zahlungsbed');
    GetWord(Adr.EK.Versandart,'Adr.EK.Versandart');
    GetWord("Adr.EK.Währung",'Adr.Abrechnungsw');
    GetAlpha(Adr.EK.Referenznr,'Adr.KdNrbeiLieferant');

    // ---
    GetWord(Adr.VK.Lieferbed,'Adr.VK.Lieferbed');
    GetWord(Adr.VK.Zahlungsbed,'Adr.VK.Zahlungsbed');
    GetWord(Adr.VK.Versandart,'Adr.VK.Versandart');
    GetWord("Adr.VK.Währung",'Adr.Zahlungsw');
    GetAlpha(Adr.VK.Referenznr,'Adr.LiefNrbeiKunde');
//    GetInt("Adr.VK.ReEmpfänger",'Adr.ReEmpfänger');
    GetBool(Adr.VK.SammelReYN,'Adr.SammelrechnungJN');
//    GetWord(Adr.VK.Verwiegeart,'Adr.');

    // ---
    GetAlpha(Adr.USIdentNr,'Adr.UStIdentNr');
    GetAlpha(Adr.Steuernummer,'Adr.Steuernummer');
    GetWord("Adr.Steuerschlüssel",'Adr.Steuerschlüssel');
    GetAlphaUP(Adr.Sprache,'Adr.Sprachkennung');
    GetAlpha(Adr.AbmessungEH,'Adr.AbmessungEH');
    GetAlpha(Adr.GewichtEH,'Adr.GewichtEH');


    // alle verbundenen Daten anlegen:
    Erx # Adr_Data:RecSave(y);
    if (Erx>0) then begin
      TRANSBRK;
      Msg(100003,'',0,0,0);
      RETURN;
    end;
    if (Erx<0) then begin
      TRANSBRK;
      RETURN;
    end;

    if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;
    Erx # Erxsert(100,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;

    Erx # RecLink(2102,2100,11,_recFirst); // Ansprechpartner holen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(102);

      Adr.P.Adressnr # Adr.Nummer;
      GetWord(Adr.P.Nummer,'Adr.P.Nummer');


      GetAlpha(Adr.P.Vorname,'Adr.P.Vorname');
      GetAlpha(Adr.P.Name,'Adr.P.Nachname');
      GetAlpha(Adr.P.Titel,'Adr.P.Titel');
      GetAlpha(Adr.P.Telefon,'Adr.P.Telefon');
      GetAlpha(Adr.P.Telefax,'Adr.P.Telefax');
      GetAlpha(Adr.P.Mobil,'Adr.P.Mobiltelefon');
      GetAlpha(Adr.P.eMail,'Adr.P.eMail');

      GetAlpha(Adr.P.Abteilung,'Adr.P.Abteilung');
      GetAlpha(Adr.P.Funktion,'Adr.P.Funktion');
      GetAlpha(Adr.P.Vorgesetzter,'Adr.P.Vorgesetzter');
      GetAlpha(Adr.P.Briefanrede,'Adr.P.Briefanrede');
      GetAlpha(Adr.P.Priv.LKZ,'Adr.P.Priv.LKZ');
      GetAlpha(Adr.P.Priv.PLZ,'Adr.P.Priv.PLZ');
      GetAlpha("Adr.P.Priv.Straße",'Adr.P.Priv.Straße');
      GetAlpha(Adr.P.Priv.Ort,'Adr.P.Priv.Ort');
      GetAlpha(Adr.P.Priv.Telefon,'Adr.P.Priv.Telefon');
      GetAlpha(Adr.P.Priv.Telefax,'Adr.P.Priv.Telefax');
      GetAlpha(Adr.P.Priv.eMail,'Adr.P.Priv.eMail');
      GetAlpha(Adr.P.Priv.Mobil,'Adr.P.Priv.Mobil');

      GetAlpha(Adr.P.Familienstand,'Adr.P.Familienstand');
      GetAlpha(Adr.P.Hobbies,'Adr.P.Hobbies');
      GetAlpha(Adr.P.Vorlieben,'Adr.P.Vorlieben');
      GetAlpha(Adr.P.Auto,'Adr.P.Auto');
      GetAlpha(Adr.P.Religion,'Adr.P.Religion');
      GetAlpha(Adr.P.Partner.Name,'Adr.P.Partner');
      GetAlpha(Adr.P.Kind1.Name,'Adr.P.Kind1.Name');
      GetAlpha(Adr.P.Kind2.Name,'Adr.P.Kind2.Name');
      GetAlpha(Adr.P.Kind3.Name,'Adr.P.Kind3.Name');
      GetAlpha(Adr.P.Kind4.Name,'Adr.P.Kind4.Name');

      GetDate(Adr.P.Geburtsdatum,'Adr.P.Geburtsdatum');
      GetDate(Adr.P.Partner.GebTag,'Adr.P.PartnerGeb');
      GetDate(Adr.P.Hochzeitstag,'Adr.P.Hochzeitstag');
      GetDate(Adr.P.Kind1.GebTag,'Adr.P.Kind1.Geb');
      GetDate(Adr.P.Kind2.GebTag,'Adr.P.Kind2.Geb');
      GetDate(Adr.P.Kind3.GebTag,'Adr.P.Kind3.Geb');
      GetDate(Adr.P.Kind4.GebTag,'Adr.P.Kind4.Geb');

      GetBool(Adr.P.PrivGeschenkYN,'Adr.P.GeschPriv?');

      Erx # Erxsert(102,0,'MAN');

      Erx # RecLink(2102,2100,11,_recNext);
    END;



  Erx # RecRead(2100,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Alle Adressen wurden importiert!',0,0,0);
end;