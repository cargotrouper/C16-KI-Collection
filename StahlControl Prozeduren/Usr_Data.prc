@A+
//===== Business-Control =================================================
//
//  Prozedur    Usr_Data
//                        OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  11.02.2015  AH  Bugfix: Tooltipszähler wurde immer um einen erhöht
//  25.02.2015  AH  Tooltipps nicht bei MC9090
//  09.12.2016  AH  "RecReadThisUser"
//  07.12.2017  AH  Erweiterung für Webuser
//  07.12.2017  AH  Neuer RTF-Tooltip
//  25.01.2018  ST  Neu "NeuesWebPasswortFestlegen()"
//  12.05.2021  AH  Neu "Tooltip" kann Ausnahmen in Form "$$(NR);INSTAALLATIONSNAME;"
//  02.07.2021  AH  "CountThisUserThisPC"
//  09.11.2021  AH  "IstInGruppe"
//  12.11.2021  AH  ERX
//  27.01.2022  AH  Refactured für die INIs
//  2022-08-19  AH  "HabCustomRecht"
//  2023-08-18  AH  "IstInGruppe" mit Wildcard
//
//  Subprozeduren
//  SUB RecReadThisUser();
//  SUB Sachbearbeiter(aUser : alpha) : alpha;
//  SUB Telefonnr(aUser : alpha) : alpha;
//  SUB ExportINI(aPfad : alpha(4000));
//  SUB ImportINI(aPfad : alpha(4000));
//  SUB LoadINI();
//  SUB SaveINI();
//  SUB INIKillBlock(aStart : alpha(200); aEnde  : alpha(200));
//  SUB ReadValue(aName : alpha) : alpha;
//  SUB SaveValue(aName : alpha; aValue : alpha);
//  SUB Init();
//  SUB SHA1(aKlartext : alpha) : alpha;
//  SUB RandomPasswort(aVon  : int; aBis  : int) : alpha
//  SUB NeuesWebPasswort()
//  SUB NeuesWebPasswortFestlegen()
//  SUB Fix06122017();
//  SUB _ClientVersion() : int;
//  SUB MerkeKleinstenClient()
//  SUB CountThisUserThisPC() : int
//  SUB IstInGruppe(aGrp : alpha) : logic
//  SUB HabCustomRecht
//
//========================================================================
@I:Def_global

//========================================================================
//  RecReadThisUser
//========================================================================
Sub RecReadThisUser();
local begin
  Erx : int;
end;
begin
  Usr.Username # gUserName;   // aktuellen User holen
  Erx # RecRead(800,1,0);
  if (Erx>_rLocked) then RecBufClear(800);

  // Rechtearray aufbauen
  Usr_R_Main:BuildMyRights();
end;


//========================================================================
//  Sachbearbeiter
//
//========================================================================
sub Sachbearbeiter(aUser : alpha) : alpha;
local begin
  vName : alpha;
  Erx   : int;
end;
begin
  Usr.Username # aUser;     // gewünschten User holen
  Erx # RecRead(800,1,0);
  if (Erx>_rLocked) then RecBufClear(800);

  vName # Usr.Name;
//  if (Usr.Vorname<>'') then vName # Usr.Vorname + ' '+Usr.Name;
  if (Usr.Anrede<>'') then vName # Usr.Anrede + ' ' + vName;

  RecReadThisUser();
  RETURN vName;
end;


//========================================================================
//  Telefonnr
//
//========================================================================
sub Telefonnr(aUser : alpha) : alpha;
local begin
  vName : alpha;
  Erx   : int;
end;
begin
  Usr.Username # aUser;     // gewünschten User holen
  Erx # RecRead(800,1,0);
  if (Erx>_rLocked) then RecBufClear(800);

  vName # Usr.Telefonnr;

  RecReadThisUser();
  RETURN vName;
end;


//========================================================================
//  ExportINI
//
//========================================================================
sub ExportINI(aPfad : alpha(4000));
begin
  if (gUserINI=0) then RETURN;
  gUserINI->Textwrite(aPfad, _TextExtern);
end;


//========================================================================
//  ImportINI
//
//========================================================================
sub ImportINI(aPfad : alpha(4000));
local begin
  vName : alpha;
  vA    : alpha(500);
  vI    : int;
  Erx   : int;
end;
begin
  if (gUserINI=0) then RETURN;
  Erx # gUserINI->TextRead(aPfad, _TextExtern);
end;


//========================================================================
//  LoadINI
//
//========================================================================
sub LoadINI();
local begin
  vName : alpha;
end;
begin
  vName # StrCut('INI.'+Username(_UserCurrent),1,20);

  // Text anlegen, falls bisher nicht vorhanden
  TxtCreate(vName, 0);

  //Text laden
  gUserINI # Textopen(10);
  gUserINI->TextRead(vName, 0);
end;


//========================================================================
//  SaveINI
//
//========================================================================
sub SaveINI();
local begin
  vName : alpha;
  vA    : alpha(500);
  vI    : int;
end;
begin

  if (gUserINI=0) then RETURN;

  // Leerzeilen entfernen
  vI # 1;
  REPEAT
    vA # TextLineRead(gUserINI, vI, 0);
    if (vA='') then TextLineRead(gUserINI, vI, _TextLineDelete)
    else inc(vI);
  UNTIL (vI>TextInfo(gUserINI, _TextLines));

  vName # StrCut('INI.'+Username(_UserCurrent),1,20);
  TxtWrite(gUserINI, vName, _TextUnlock);
//debugx('write');
//textwrite(gUserIni,'d:\debug\debug2.txt',_textExtern);
//  TextClose(gUserINI);
//  gUserINI # 0;
end;


//========================================================================
//  INIKillBlock
//
//========================================================================
Sub INIKillBlock(
  aStart : alpha(200);
  aEnde  : alpha(200));
local begin
  vX  : int;
  vY  : int;
end
begin

  // 27.01.2022 AH: REFACTORED !!!
  
  vX # TextSearch(gUserINI, 1, 1, _TextSearchtoken, aStart);
  if (vX=0) then RETURN;

  vY # TextSearch(gUserINI, vX, 1, _TextSearchtoken, aEnde);
  if (vY=0) then RETURN;
  WHILE (vX<=vY) do begin
//debugx('DEL '+
    TextLineRead(gUserINI, vX, _TextLineDelete);
    DEC(vY);
  END;

/* ALT
  aEnde # '*'+aEnde+'*';
  vX # TextSearch(gUserINI, 1, 1, _TextSearchtoken, aStart);
  if (vX=0) then RETURN;
  REPEAT
    vX # TextSearch(gUserINI, 1, 1, _TextSearchtoken, aStart);
    if (vX=0) then RETURN;
    // 25.01.2022 AH: mit WILDCARDS
//    WHILE (TextLineRead(gUserINI, vX, _TextLineDelete)<>aEnde) and (vX<=TextInfo(gUserINI,_TextLines)) do begin
    WHILE ((TextLineRead(gUserINI, vX, _TextLineDelete)=aEnde)=false) and (vX<=TextInfo(gUserINI,_TextLines)) do begin
    END;
  UNTIL (vX=0);
*/
end;


//========================================================================
//========================================================================
sub ReadValue(
  aName     : alpha) : alpha;
local begin
  vI,vJ,vK  : int;
  vA        : alpha;
end;
begin
  // 27.01.2022 AH: Fix für falsche TAGS mit \ statt /
  TextSearch(gUserINI, 1, 1, _TextSearchCI, '<\Settings>','</Settings>',99);

  vI # TextSearch(gUserINI, 1, 1, _TextSearchtoken, '<Settings>');
  if (vI=0) then RETURN '';
  vJ # TextSearch(gUserINI, vI, 1, _TextSearchtoken, '</Settings>');

  vK # TextSearch(gUserINI, vI, 1, 0, aName+'=');
  if (vK>vJ) or (vK=0) then RETURN '';

  vA # TextLineRead(gUserINI, vK, 0);
  vA # Str_Token(vA,'=',2);

  RETURN vA;
end;


//========================================================================
//========================================================================
sub SaveValue(
  aName     : alpha;
  aValue    : alpha);
local begin
  vI,vJ,vK  : int;
  vA        : alpha;
end;
begin
  // 27.01.2022 AH: Fix für falsche TAGS mit \ statt /
  TextSearch(gUserINI, 1, 1, _TextSearchCI, '<\Settings>','</Settings>',99);

  vI # TextSearch(gUserINI, 1, 1, _TextSearchtoken, '<Settings>');
  if (vI=0) then begin
    // neuen Block anlegen
    TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, '<Settings>', _TextLineInsert);
    TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, aName+'='+aValue, _TextLineInsert);
    TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, '</Settings>', _TextLineInsert);
    RETURN;
  end;
  vJ # TextSearch(gUserINI, vI, 1, _TextSearchtoken, '</Settings>');

  vK # TextSearch(gUserINI, vI, 1, 0, aName+'=');
  if (vK>vJ) or (vK=0) then begin
    TextLineWrite(gUserINI, vI+1, aName+'='+aValue, _TextLineInsert);
    RETURN;
  end;

  TextLineWrite(gUserINI, vK, aName+'='+aValue, 0);

end;


//========================================================================
// Init
//    Wird einmalig NACH dem Hauptfenster aufgerufen
//========================================================================
SUB Init();
local begin
  vTT   : int;
  vTxt  : int;
  vMax  : int;
  vI    : int;
  vA,vB : alpha(4090);
  vJ    : int;
  vTxt2 : int;
  vRtf  : int;
  vFirst  : logic;
end;
begin

  if (gUsergroup='BETRIEB') then RETURN;
  if (gUsergroup='BDE') then RETURN;
  if (gUsergroup='MC9090') then RETURN;


  vTT # cnvia(ReadValue('Tooltip'));

  if (Set.Installname='GWS') then vTT # 1000;   // GWS überschreibt die User-INIs!

  vTxt # TextOpen(20);
  TextRead(vTxt, 'Tooltip',0);

//vTT # 10;
  REPEAT
    vI # TextSearch(vTxt, vMax, 1, 0, '$$');
    if (vI<>0) then vMax # vI+1;
  UNTIl (vI=0);

  if (vMax>0) then begin
    vA # TextLineread(vTxt, vMax-1, 0);
    vMax # cnvia(vA);
  end;

//debugx(aint(vTT)+'/'+aint(vMax));
  vTxt2 # TextOpen(16);
  vRTF  # TextOpen(16);
  FOR vTT # vTT+1 LOOP inc(vTT) while (vTT<=vMax) do begin
    TextClear(vTxt2);

    vB # '';
    vI # TextSearch(vTxt, 1, 1, 0, '$$'+aint(vTT));
//debugx('read:'+vA);
    // AUSNAHMEN vom Tooltip:
    vA # TextLineread(vTxt, vI, 0);
    if (StrFind(vA,';',1)>0) then begin
      if (StrFind(vA,';'+Set.Installname+';',1)>0) then CYCLE;
    end;

    vJ # TextSearch(vTxt, vI+1, 1, 0, '$$');
    if (vJ=0) then vJ # TextInfo(vTxt, _TextLines)+1;
    vFirst # true;
    FOR vI # vI+1 loop inc(vI) while (vI<vJ) do begin
      vA # TextLineread(vTxt, vI, 0);
      if (vFirst) then begin
        vFirst # false;
        vA # '\fs28'+vA+'\fs22'; // cf2 = rot sonst cf1
      end;
      TextAddLine(vTxt2, vA);
    END;
    TextAddLine(vTxt2,'------------------------------------------------------------------------------------------------------------');
    Lib_Texte:Txt2Rtf(vTxt2, vRTF, 'Arial', 12, 0, (TextInfo(vRTF,_textLines)>0));
  END;  // nächster Tooltip

  vTT # vTT - 1;  // einen zurück

  if (TextInfo(vRtf,_textLines)>0) then
    Dlg_Standard:TooltipRTF(vRTF);
  TextClose(vRTF);
  TextClose(vTxt2);

/**
  FOR vTT # vTT+1 LOOP inc(vTT) while (vTT<=vMax) do begin

    if (vTT=1) then begin
      App_Main:StartMdi('Mdi.Dashboard');
    end;

    vB # '';
    vI # TextSearch(vTxt, 1, 1, 0, '$$'+aint(vTT));
    vJ # TextSearch(vTxt, vI+1, 1, 0, '$$');
    if (vJ=0) then vJ # TextInfo(vTxt, _TextLines)+1;
    FOR vI # vI+1 loop inc(vI) while (vI<vJ) do begin
      vA # TextLineread(vTxt, vI, 0);
      vB # vB + vA + StrChar(13);
    END;

    Dlg_Standard:Tooltip(vB);
  END;

  vTT # vTT - 1;  // einen zurück

  TextClose(vTxt);
**/

  // merken
  SaveValue('Tooltip',aint(vTT));

end;


//========================================================================
//========================================================================
Sub SHA512(aKlartext : alpha) : alpha;
local begin
  vMem  : int;
  vHash : alpha(128);
end;
begin
  vMem # MemAllocate(_MemAutoSize);
  MemWriteStr(vMem, 1, aKlarText);
  vHash # MemHash(vMem, _MemHashSHA512 | _MemResultHex);   // 40 Zeichen ////2023-05-20 MR 1923/19 Änderung auf SHA-2 mit 512 Bit daher 128 Zeichen
  MemFree(vMem);

  RETURN Strcnv(vHash, _StrUpper);
end;


//========================================================================
//========================================================================
Sub RandomPasswort(
  aVon  : int;
  aBis  : int
) : alpha
local begin
  vMax  : int;
  vI    : int;
  vJ    : int;
  vA,vB : alpha;
end;
begin

  aBis # aBis + 1;
  vMax # cnvif(Random() * cnvfi(aBis - aVon) + cnvfi(aVon));

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    vJ # cnvif(Random() * (123\f-33\f) + 33\f);
    vA # StrChar(vJ);

    // Unleserliche Zeichen ignorieren
    case vA of
      'Ú','`',
      '^','°',
      'l','1',
      '0','O' : begin
        dec(vI);
        CYCLE;
      end;
    end;

    vB # vB + vA;
  END;

  RETURN vB;
end;


//========================================================================
//  NeuesWebPasswort
//========================================================================
sub NeuesWebPasswort()
local begin
  vA  : alpha;
  Erx : int;
end;
begin

  if (Usr.Typ<>'W') then RETURN;

  vA # RandomPasswort(10,12); // 10 bis 12 Stellen

  Erx # RecRead(800,1,_RecLock);
  Usr.Passwort # StrCnv(SHA512(vA),_StrUpper);
  RekReplace(800);

  ClipboardWrite(vA);

  Msg(99,'Neues Passwort gesetzt und in die Zwischenablage kopiert!',0,0,0);
end;



//========================================================================
//  NeuesWebPasswortFestlegen
//========================================================================
sub NeuesWebPasswortFestlegen()
local begin
  vA  : alpha;
  vB  : alpha;
  Erx : int;
end;
begin

  if (Usr.Typ<>'W') then RETURN;

  if (Dlg_Standard:Standard('neues Passwort:', var vA, true) = false) then
    RETURN;

  if (Dlg_Standard:Standard('Passwort wiederholen:', var vB, true) = false) then
    RETURN;

  if (vA <> vB) then begin
    Msg(99,'Die eingegebenen Passwörter sind nicht identisch!',0,0,0);
    RETURN;
  end;

  Erx # RecRead(800,1,_RecLock);
  Usr.Passwort # StrCnv(SHA512(vA),_StrUpper);
  RekReplace(800);

  ClipboardWrite(vA);

  Msg(99,'Neues Passwort gesetzt und in die Zwischenablage kopiert!',0,0,0);
end;




//========================================================================
// call Usr_DatA:Fix06122017
//========================================================================
SUB Fix06122017();
local begin
  vHdl  : int;
  vID   : int;
  vGrp  : alpha;
  Erx   : int;
end;
begin

//lib_Debug:Startbluemode();

  FOR Erx # RecRead(800,1,_recFirst)
  LOOP Erx # RecRead(800,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Usr.Typ<>'') then CYCLE;

    vHdl # UrmOpen(_UrmTypeUser,0,Usr.UserName);
    if (vHdl<0) then CYCLE;
    vHdl->UrmPropGet(_UrmPropUserGroup, vGrp);
    UrmClose(vHdl);

    RecRead(800,1,_recLock);
    case vGrp of

      'USER'          : Usr.Typ # 'N';

      'PROGRAMMIERER' : Usr.Typ # 'S';

      'BETRIEB',
      'BETRIEB_TS'    : Usr.Typ # 'B';

//      'JOB-SERVER',
//      'MC9090',
//      '_Administrators'
      otherwise
                        Usr.Typ # 'S';
    end;
    RekReplace(800);
  END;


  // RESTORE
  Usr.Username      # gUsername;
  RecRead( 800, 1, 0 );

end;


//========================================================================
//========================================================================
sub _ClientVersion() : int;
local begin
  vI  : int;
end;
begin

  case SysOS() of
    'Windows 2000 Professional'         : RETURN 1;
    'Windows 2000 Server'               : RETURN 2;
    'Windows XP'                        : RETURN 3;
    'Windows XP (64-Bit)'               : RETURN 4;
    'Windows Server 2003'               : RETURN 5;
    'Windows Server 2003 (64-Bit)'      : RETURN 6;
    'Windows Server 2008'               : RETURN 7;
    'Windows Server 2008 (64-Bit)'      : RETURN 8;
    'Windows Vista'                     : RETURN 9;
    'Windows Vista (64-Bit)'            : RETURN 10;
    'Windows 7'                         : RETURN 11;
    'Windows 7 (64-Bit)'                : RETURN 12;
    'Windows Server 2008 R2 (64-Bit)'   : RETURN 13;
    'Windows 8'                         : RETURN 14;
    'Windows 8 (64-Bit)'                : RETURN 15;
    'Windows Server 2012 (64-Bit)'      : RETURN 16;
    'Windows 8.1'                       : RETURN 17;
    'Windows 8.1 (64-Bit)'              : RETURN 18;
    'Windows Server 2012 R2 (64-Bit)'   : RETURN 19;
    'Windows 10'                        : RETURN 20;
    'Windows 10 (64-Bit)'               : RETURN 21;
    'Windows Server 2016 (64-Bit)'      : RETURN 22;
  end;

  RETURN 0;
end;


//========================================================================
//========================================================================
SUB MerkeKleinstenClient()
local begin
  vI    : int;
  v903  : int;
end;
begin

  vI # _ClientVersion();
  if (vI=0) then RETURN;

  if ((vI>=Set.MinClientOS) and (Set.MinClientOS>0)) then RETURN;

  // MERKEN
  v903 # RecBufCreate(903);
  RecRead(v903,1,0);
  RecRead(v903,1,_RecLock);
  v903->Set.MinClientOS # vI;
  Set.MinClientOS # vI;
  RecReplace(v903,_recUnlock);
  RecBufDestroy(v903);

end;


//========================================================================
//========================================================================
Sub SearchLoggedInUser(aName : alpha) : logic
local begin
  vUser : int;
end;
begin

  aName # StrCnv(aName, _StrUpper);

  vUser # CnvIa(UserInfo(_UserNextId));
  FOR   vUser # CnvIa(UserInfo(_UserNextId))
  LOOP  vUser # CnvIa(UserInfo(_UserNextId,vUser))
  WHILE (vUser > 0) DO BEGIN
    if (StrCnv(UserInfo(_Username, vUser),_strUpper) = aName) then RETURN true;
  END;

  RETURN false;
end;


//========================================================================
//  CountThisUserThisPC
//            Prüft aktuelle User+PC
//========================================================================
sub CountThisUserThisPC() : int
local begin
  vIchUser  : alpha;
  vIchPC    : alpha;
  vID       : int;
  vUser     : alpha;
  vPC       : alpha;
  vA        : alpha;
  vI        : int;
end;
begin

  UserInfo(_UserCurrent);
  vIchUser  # UserInfo(_UserName);
  vIchPC    # UserInfo(_UserSysNameIP);
  
  FOR   vID # CnvIa(UserInfo(_UserNextId))
  LOOP  vID # CnvIa(UserInfo(_UserNextId,vID))
  WHILE (vID > 0) DO BEGIN

    // ist THREAD?
    vA # '|'+cnvai(vID, _FmtNumnogroup)+'|';

    if (RmtDataRead(vA, _recunlock, var vA)=_rOK) then CYCLE;

    vUser  # UserInfo(_UserName, vID);
    vPC    # UserInfo(_UserSysNameIP, vID);

    if (vIchUser=vUser) and (vIchPC=vPC) then begin
      inc(vI);
    end;

  END;

  RETURN vI;
end;


//========================================================================
//  IstInGruppe
//========================================================================
sub IstInGruppe(aGrp : alpha) : logic
local begin
  Erx : int;
end;
begin
  aGrp # StrCnv(aGrp, _Strupper);
  FOR Erx # RecLink(802,800,1,_RecFirst)    // Gruppen loopen
  LOOP Erx # RecLink(802,800,1,_RecNext)
  WHILE (Erx=_ROk) do begin
    if ("Usr.U<>G.Gruppe"=*^aGrp) then RETURN true;   // 2023-08-18 AH Wildcard
  END;
  RETURN false;
end;


/*========================================================================
2022-08-19  AH
========================================================================*/
SUB HabCustomRecht(aName : alpha) : logic
local begin
  Erx : int;
end;
begin
  RecBufClear(804);
  Usr.CR.Name # aName;
  Erx # RecRead(804,2,0);
  if (Erx>_rMultikey) then RETURN false;
  RETURN CustomRechte[Usr.CR.Nummer];
end;


//========================================================================