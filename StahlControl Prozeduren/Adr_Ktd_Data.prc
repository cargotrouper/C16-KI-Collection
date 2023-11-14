@A+
//===== Business-Control =================================================
//
//  Prozedur  Adr_Ktd_Date
//                    OHNE E_R_G
//
//  Info
//  11.07.2012  AI  Erstellung der Prozedur
//  14.07.2016  AH  Bugfix: Ansprechpartner und Anschriften wurden  mitfalschem Schlüssel gehandelt
//  26.07.2016  AH  "Rebuild" löscht nicht die Userdaten
//  25.11.2016  AH  Bug: Partner/Anschrift-Kontakte wurden gelöscht bei Update der Adresse
//  01.02.2022  ST  E r g --> Erx
//
//  Subprozeduren
//
//  SUB AdresseToKontakt(aAdresse : int; aTyp : alpha; aName : alpha; aDaten : alpha(160)) : logic;
//  SUB PartnerToKontakt(aAdresse : int; aPartner : word; aTyp : alpha; aName : alpha; aDaten : alpha(160)) : logic;
//  SUB AnschrToKontakt(aAdresse : int; aAnschr : word; aTyp : alpha; aName : alpha; aDaten : alpha(160)) : logic;
//  SUB VertreterToKontakt(aVer : int; aTyp : alpha; aName : alpha; aDaten : alpha(160)) : logic;
//  SUB UserToKontakt(aUser : alpha; aTyp : alpha; aName : alpha; aDaten : alpha(160)) : logic;
//  SUB UpdateFromAdresse();
//  SUB UpdateFromAnschr();
//  SUB UpdateFromPartner();
//  SUB UpdateFromVer();
//  SUB UpdateFromUser(opt aDL : int);
//  SUB DeleteUser();
//  SUB ReadUserData(aUser : alpha; aTyp : alpha; aName : alpha) : alpha;
//  SUB ReadLinkedBuf(var aDatei : int; var aBuf : int) : int;
//  SUB Rebuild()
//  SUB FillUserDL(aDL : int);
//
//========================================================================
@I:Def_Global
@I:Def_Kontakte

//========================================================================
//  _ToKontakt
//========================================================================
sub _ToKontakt(
  aKey      : int;
  aFilter   : int;
  aAdresse  : int;
  aPartner  : word;
  aAnschr   : word;
  aVer      : int;
  aUser     : alpha;
  aTyp      : alpha;
  aName     : alpha;
  aDaten    : alpha(160))
: logic;
local begin
  Erx : int;
end
begin

  RecbufClear(107);

  // LÖSCHEN?
  if (aDaten='') or (aName='') then begin
    WHILE (RecRead(107,aKey,_recfirst,aFilter)<_rNokey) do begin
//debug('del '+Adr.Ktd.Name);
      RekDelete(107,0,'AUTO');
    END;
//debug('dele');
    RecFilterDestroy(aFilter);
    RETURN true;
  end;

  // UPDATE?
  if (RecRead(107,aKey,_recfirst,aFilter)<=_rMultikey) then begin
    RecRead(107,1,_recLock);
    Adr.Ktd.Daten # aDaten;
//debug('update:'+Adr.Ktd.Name+' auf '+aDaten);
    Erx # RekReplace(107,_recunlock,'AUTO');
    RecFilterDestroy(aFilter);
    RETURN (Erx=_rOK);
  end;

  RecFilterDestroy(aFilter);


  // NEUANLAGE
  Erx # RecRead(107,1,_recLast);
  if (Erx=_rNoRec) then RecBufClear(107);

  Inc(Adr.Ktd.Nummer);

  Adr.Ktd.zuAdressNr  # aAdresse;
  Adr.Ktd.zuPartnerNr # aPartner;
  Adr.Ktd.zuAnschrNr  # aAnschr;
  Adr.Ktd.zuVerNr     # aVer;
  Adr.Ktd.zuUser      # aUser;
  Adr.Ktd.Typ         # aTyp;
  Adr.Ktd.Name        # aName;
  Adr.Ktd.Daten       # aDaten;
  REPEAT
    Erx # RekInsert(107,_Recunlock, 'AUTO');
//debug('neu'+Adr.Ktd.Name+' mit '+aDaten);
    if (Erx<>_ROK) then Inc(Adr.Ktd.Nummer);
  UNTIl (Erx=_rOK);

  RETURN true;
end;


//========================================================================
// AdresseToKontakt
//
//========================================================================
sub AdresseToKontakt(
  aAdresse  : int;
  aTyp      : alpha;
  aName     : alpha;
  aDaten    : alpha(160);
) : logic;
local begin
  vFilter : int;
end;
begin
  vFilter # RecFilterCreate(107,2);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aAdresse);
  vFilter->RecFilterAdd(2,_FltAnd, _FltEq, 0);
  vFilter->RecFilterAdd(3,_FltAnd, _FltEq, 0);
//  vFilter->RecFilterAdd(2,_FltAnd, _FltEq, aPartner);
  if (aName<>'') then begin
    vFilter->RecFilterAdd(4,_FltAnd, _FltEq, aTyp);
    vFilter->RecFilterAdd(5,_FltAnd, _FltEq, aName);
  end;
  RETURN _ToKontakt(2, vFilter, aAdresse, 0,0,0,'', aTyp, aName, aDaten);
end;


//========================================================================
//  PartnerToKontakt
//
//========================================================================
sub PartnerToKontakt(
  aAdresse  : int;
  aPartner  : word;
  aTyp      : alpha;
  aName     : alpha;
  aDaten    : alpha(160);
) : logic;
local begin
  vFilter : int;
end;
begin
//  vFilter # RecFilterCreate(107,3);
  vFilter # RecFilterCreate(107,2);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aAdresse);
  vFilter->RecFilterAdd(2,_FltAnd, _FltEq, aPartner);
  vFilter->RecFilterAdd(3,_FltAnd, _FltEq, 0);
  if (aName<>'') then begin
    vFilter->RecFilterAdd(4,_FltAnd, _FltEq, aTyp);
    vFilter->RecFilterAdd(5,_FltAnd, _FltEq, aName);
  end;
  RETURN _ToKontakt(2, vFilter, aAdresse, aPartner, 0,0,'', aTyp, aName, aDaten);
end;


//========================================================================
//  AnschrToKontakt
//
//========================================================================
sub AnschrToKontakt(
  aAdresse  : int;
  aAnschr   : word;
  aTyp      : alpha;
  aName     : alpha;
  aDaten    : alpha(160);
) : logic;
local begin
  vFilter : int;
end;
begin
//  vFilter # RecFilterCreate(107,4);
  vFilter # RecFilterCreate(107,2);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aAdresse);
  vFilter->RecFilterAdd(2,_FltAnd, _FltEq, 0);
  vFilter->RecFilterAdd(3,_FltAnd, _FltEq, aAnschr);
  if (aName<>'') then begin
    vFilter->RecFilterAdd(4,_FltAnd, _FltEq, aTyp);
    vFilter->RecFilterAdd(5,_FltAnd, _FltEq, aName);
  end;
  RETURN _ToKontakt(2, vFilter, aAdresse,0,aAnschr, 0, '', aTyp, aName, aDaten);
end;


//========================================================================
//  VertreterToKontakt
//
//========================================================================
sub VertreterToKontakt(
  aVer      : int;
  aTyp      : alpha;
  aName     : alpha;
  aDaten    : alpha(160);
) : logic;
local begin
  vFilter : int;
end;
begin
  vFilter # RecFilterCreate(107,5);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aVer);
  if (aName<>'') then begin
    vFilter->RecFilterAdd(2,_FltAnd, _FltEq, aTyp);
    vFilter->RecFilterAdd(3,_FltAnd, _FltEq, aName);
  end;
  RETURN _ToKontakt(5, vFilter, 0,0,0,aVer, '', aTyp, aName, aDaten);
end;


//========================================================================
//  UserToKontakt
//
//========================================================================
sub UserToKontakt(
  aUser     : alpha;
  aTyp      : alpha;
  aName     : alpha;
  aDaten    : alpha(160);
) : logic;
local begin
  vFilter : int;
end;
begin

  vFilter # RecFilterCreate(107,6);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aUser);
  if (aName<>'') then begin
//debug('filter ext');
    vFilter->RecFilterAdd(2,_FltAnd, _FltEq, aTyp);
    vFilter->RecFilterAdd(3,_FltAnd, _FltEq, aName);
  end;
  RETURN _ToKontakt(6, vFilter, 0,0,0,0,aUser, aTyp, aName, aDaten);

end;


//========================================================================
//  UpdateFromAdresse
//
//========================================================================
Sub UpdateFromAdresse();
begin
  AdresseToKontakt(Adr.Nummer, c_KTD_TYP_TEL, c_KTD_TEL, Adr.Telefon1);
  AdresseToKontakt(Adr.Nummer, c_KTD_TYP_TEL, c_KTD_TEL2, Adr.Telefon2);
  AdresseToKontakt(Adr.Nummer, c_KTD_TYP_FAX, c_KTD_FAX, Adr.Telefax);
  AdresseToKontakt(Adr.Nummer, c_KTD_TYP_EMAIL, c_KTD_EMAIL, Adr.eMail);
  AdresseToKontakt(Adr.Nummer, c_KTD_TYP_URL, c_KTD_HOMEPAGE, Adr.Website);
end;


//========================================================================
//  UpdateFromAnschr
//
//========================================================================
Sub UpdateFromAnschr();
begin
  AnschrToKontakt(Adr.A.Adressnr, Adr.A.Nummer, c_KTD_TYP_TEL, c_KTD_TEL, Adr.A.Telefon);
  AnschrToKontakt(Adr.A.Adressnr, Adr.A.Nummer, c_KTD_TYP_FAX, c_KTD_FAX, Adr.A.Telefax);
  AnschrToKontakt(Adr.A.Adressnr, Adr.A.Nummer, c_KTD_TYP_EMAIL, c_KTD_EMAIL, Adr.A.email);
end;


//========================================================================
//  UpdateFromPartner
//
//========================================================================
Sub UpdateFromPartner();
begin
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_TEL, c_KTD_TEL, Adr.P.Telefon);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_FAX, c_KTD_FAX, Adr.P.Telefax);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_TEL, c_KTD_MOBIL, Adr.P.Mobil);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_EMAIL, c_KTD_EMAIL, Adr.P.Email);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_TEL, c_KTD_TEL_PRIV, Adr.P.Priv.Telefon);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_FAX, c_KTD_FAX_PRIV, Adr.P.Priv.Telefax);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_TEL, c_KTD_MOBIL_PRIV, Adr.P.Priv.Mobil);
  PartnerToKontakt(Adr.P.Adressnr, Adr.P.Nummer, c_KTD_TYP_EMAIL, c_KTD_EMAIL_PRIV, Adr.P.Priv.Email);
end;


//========================================================================
//  UpdateFromVer
//
//========================================================================
Sub UpdateFromVer();
begin
  VertreterToKontakt(Ver.Nummer, c_KTD_TYP_TEL, c_KTD_TEL, Ver.Telefon1);
  VertreterToKontakt(Ver.Nummer, c_KTD_TYP_TEL, c_KTD_TEL2, Ver.Telefon2);
  VertreterToKontakt(Ver.Nummer, c_KTD_TYP_FAX, c_KTD_FAX, Ver.Telefax);
  VertreterToKontakt(Ver.Nummer, c_KTD_TYP_EMAIL, c_KTD_EMAIL, Ver.email);
  VertreterToKontakt(Ver.Nummer, c_KTD_TYP_URL, c_KTD_HOMEPAGE, Ver.Website);
end;


//========================================================================
//  UpdateFromUser
//
//========================================================================
Sub UpdateFromUser(
  opt aDL : int);
local begin
  vI    : int;
  vA    : alpha(4096);
  vTyp  : alpha;
  vName : alpha;
  vCap  : alpha(4096);
end;
begin
  UserToKontakt(Usr.Username, c_KTD_TYP_TEL, c_KTD_TEL, Usr.Telefonnr);
  UserToKontakt(Usr.Username, c_KTD_TYP_FAX, c_KTD_FAX, Usr.Telefaxnr);
  UserToKontakt(Usr.Username, c_KTD_TYP_EMAIL, c_KTD_EMAIL, Usr.Email);

  if (aDL=0) then RETURN;

  FOR vI # 1 loop inc(vI) WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    aDL->WinLstCellGet(vCap,2,vI);
    aDL->WinLstCellGet(vA,3,vI);
    aDL->WinLstCellGet(vTyp,4,vI);
    aDL->WinLstCellGet(vName,5,vI);
    if (vTyp=c_KTD_TYP_TEL_SONST) or
      (vTyp=c_KTD_TYP_FAX_SONST) or
      (vTyp=c_KTD_TYP_EMAIL_SONST) or
      (vTyp=c_KTD_TYP_URL_SONST) then begin
//debug('savec:'+vName+' '+vCap);
      UserToKontakt(Usr.Username, vTyp, vCap, vA);
    end
    else begin
//debug('save:'+vName+' '+vName);
      if (vTyp<>'') then
        UserToKontakt(Usr.Username, vTyp, vName, vA);
    end;
  END;  // ...For Einzelkarte

end;


//========================================================================
//  DeleteUser
//
//========================================================================
Sub DeleteUser();
begin
  UserToKontakt(Usr.Username, '','','');
end;


//========================================================================
//  ReadUserData
//
//========================================================================
Sub ReadUserData(
  aUser : alpha;
  aTyp  : alpha;
  aName : alpha) : alpha;
local begin
  Erx : int;
  vFilter : int;
end;
begin
  vFilter # RecFilterCreate(107,6);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, aUser);
  if (aTyp<>'') then
    vFilter->RecFilterAdd(2,_FltAnd, _FltEq, aTyp);
  if (aName<>'') then
    vFilter->RecFilterAdd(3,_FltAnd, _FltEq, aName);
//debug('suche:'+aUser+', '+aTyp+', '+aName);
  Erx # RecRead(107,6,_recfirst,vFilter);
  RecFilterDestroy(vFilter);
  if (Erx<=_rMultikey) then RETURN Adr.Ktd.Daten;

  RETURN '';
end;


//========================================================================
//  ReadLinkedBuf
//
//========================================================================
Sub ReadLinkedBuf(
  var aDatei  : int;
  var aBuf    : int;
) : int;
begin
  if (Adr.Ktd.zuUser<>'') then begin
    aDatei  # 800;
    aBuf # RecBufCreate(aDatei);
    RETURN RecLink(aBuf, 107, 5, _recFirst);
  end;
  if (Adr.Ktd.zuVerNr<>0) then begin
    aDatei  # 110;
    aBuf # RecBufCreate(aDatei);
    RETURN RecLink(aBuf, 107, 4, _recFirst);
  end;
  if (Adr.Ktd.zuPartnerNr<>0) then begin
    aDatei  # 102;
    aBuf # RecBufCreate(aDatei);
    RETURN RecLink(aBuf, 107, 3, _recFirst);
  end;
  if (Adr.Ktd.zuAnschrNr<>0) then begin
    aDatei  # 101;
    aBuf # RecBufCreate(aDatei);
    RETURN RecLink(aBuf, 107, 2, _recFirst);
  end;
  if (Adr.Ktd.zuAdressnr<>0) then begin
    aDatei  # 100;
    aBuf # RecBufCreate(aDatei);
    RETURN RecLink(aBuf, 107, 1, _recFirst);
  end;

  RETURN _rNoRec;
end;


//========================================================================
//  Rebuild
//      Kopiert alle Kontaktdaten aus den anderen Dateien in die Kontaktdatei
//      Call Adr_Ktd_Data:Rebuild
//========================================================================
sub Rebuild()
local begin
  Erx : int;
end
begin

  // Alle Konakte löschen
  // 26.07.2016 AH: nicht die Usersettings
//  RekDeleteAll(107);
  Erx # RecRead(107,1,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    if (Adr.Ktd.ZuUser<>'') then begin
      Erx # RecRead(107,1,_recNext);
      CYCLE;
    end;
    RekDelete(107);
    Erx # RecRead(107,1,0);
    Erx # RecRead(107,1,0);
  END;


  // Adressen loopen...
  FOR Erx # RecRead(100,1,_recFirst)
  LOOP Erx # RecRead(100,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    UpdateFromAdresse();
  END;

  // Anschriften loopen...
  FOR Erx # RecRead(101,1,_recFirst)
  LOOP Erx # RecRead(101,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    UpdateFromAnschr();
  END;

  // Partner loopen...
  FOR Erx # RecRead(102,1,_recFirst)
  LOOP Erx # RecRead(102,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    UpdateFromPartner();
  END;

  // Vertreter loopen...
  FOR Erx # RecRead(110,1,_recFirst)
  LOOP Erx # RecRead(110,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    UpdateFromVer();
  END;

  // User loopen...
  FOR Erx # RecRead(800,1,_recFirst)
  LOOP Erx # RecRead(800,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    UpdateFromUser();
  END;
  Usr_data:RecReadThisUser();

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  FillUserDL
//
//========================================================================
sub FillUserDL(
  aDL         : int);
local begin
  Erx     : int;
  vFilter : int;
  vI      : int;
  vIcon   : int;
  vName   : alpha;
end;
begin
  aDL->WinLstDatLineRemove(_WinLstDatLineAll);
  aDL->wpcustom # '|'+c_KTD_TEL+'||'+c_KTD_FAX+'||'+c_KTD_EMAIL+'|';
  if (Usr.Username='') then RETURN;

  vFilter # RecFilterCreate(107,6);
  vFilter->RecFilterAdd(1,_FltAnd, _FltEq, Usr.Username);
  FOR Erx # RecRead(107,6,_recfirst, vFilter)
  LOOP Erx # RecRead(107,6,_recNext, vFilter)
  WHILE (Erx<=_rLocked) do begin

    vIcon # _WinImgNone;
    case (Adr.Ktd.Typ) of
      c_KTD_TYP_TEL,
      c_KTD_TYP_TEL_SONST       : vIcon # _WinImgPhone;
      c_KTD_TYP_FAX,
      c_KTD_TYP_FAX_SONST       : vIcon # _WinImgFax;
      c_KTD_TYP_EMAIL,
      c_KTD_TYP_EMAIL_SONST     : vIcon # _WinImgeMail;
      c_KTD_TYP_URL,
      c_KTD_TYP_URL_SONST       : vIcon # _WinImgInternet;
    end;
//debug('hab '+adr.ktd.name);

    if (Adr.Ktd.Typ=c_KTD_TYP_TEL) or
      (Adr.Ktd.Typ=c_KTD_TYP_FAX) or
      (Adr.Ktd.Typ=c_KTD_TYP_EMAIL) or
      (Adr.Ktd.Typ=c_KTD_TYP_URL) then begin

//debug('cylce '+adr.ktd.name);
//debugx('suche '+Adr.Ktd.Name+' in '+aDL->wpcustom);
      if (StrFind(aDL->wpcustom,'|'+Adr.Ktd.Name+'|',0)>0) then CYCLE;
//debugx(Adr.Ktd.Name);
      aDL->wpcustom # aDL->wpcustom + '|'+Adr.Ktd.Name+'|';
    end;

    inc(vI);
    aDL->WinLstDatLineAdd(vIcon);
    aDL->WinLstCellSet(Adr.Ktd.Name,2);
    aDL->WinLstCellSet(Adr.Ktd.Daten,3);
    aDL->WinLstCellSet(Adr.Ktd.Typ,4);
    vName # Adr.Ktd.Name;
    if (Adr.Ktd.Typ=c_KTD_TYP_TEL_SONST) then vName # c_KTD_SONST_TEL;
    if (Adr.Ktd.Typ=c_KTD_TYP_FAX_SONST) then vName # c_KTD_SONST_FAX;
    if (Adr.Ktd.Typ=c_KTD_TYP_EMAIL_SONST) then vName # c_KTD_SONST_EMAIL;
    if (Adr.Ktd.Typ=c_KTD_TYP_URL_SONST) then vName # c_KTD_SONST_URL;
    aDL->WinLstCellSet(vName,5);
  END;
  RecFilterDestroy(vFilter);
end;


//========================================================================
//========================================================================
sub output();
local begin
  Erx : int;
end
begin
  // Adressen loopen...
  FOR Erx # RecRead(107,1,_recFirst)
  LOOP Erx # RecRead(107,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
debug(aint(adr.ktd.zuvernr)+'/'+adr.ktd.zuuser+'   :   '+adr.ktd.typ+'  '+adr.ktd.daten);
  END;
debug('----');
end;

//========================================================================