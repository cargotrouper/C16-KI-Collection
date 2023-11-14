@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_SFX
//              OHNE E_R_G
//  Info
//
//
//  06.08.2008  AI  Erstellung der Prozedur
//  29.04.2013  AI  AFX werden aus Text gelesen und nicht online aus Datenbank
//  14.04.2014  AH  Korrektur: AFX mit gleicher Endung wurden als "gleich" angesehen. Nun Differenzierung
//  20.07.2016  AH  User-Vertretung
//  11.08.2016  AH  SFX können anderes Hauptmenü bekommen
//  17.08.2017  AH  Neu: "RechtOK"
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  27.07.2021  AH  ERX
//  2023-08-22  MR Sonderfunktionen können jetzt auch Parameter entgegennehmen
//
//  Subprozeduren
//
//  SUB InitAFX();
//  SUB TermAFX();
//  SUB RechtOK(aNr : int) : logic;
//
//  SUB CreateMenu(aMenu : int; aBereich : alpha);
//  SUB Run(aNummer : int);
//
//  SUB Check_AFX(aName : alpha) : logic
//  SUB Run_AFX(aName : alpha; opt aPara : alpha) : int;
//
//========================================================================
@I:Def_Global

//========================================================================
//  InitAFX
//========================================================================
sub InitAFX();
local begin
  vErg  : int;
end;
begin
  if (gAFXText<>0) then RETURN;

  gAFXText # TextOpen(16);

  FOR vErg # RecRead(923,1,_recFirst)
  LOOP vErg # RecRead(923,1,_recnext)
  WHILe (vErg<=_rLocked) do begin
    if (AFX.Prozedur<>'') then
      TextAddLine(gAFXText, '|'+AFX.Name+'|'+AFX.Prozedur+'||')
    else if (AFX.WoF.Nummer<>0) then
      TextAddLine(gAFXText, '|'+AFX.Name+'||'+aint(AFX.WOF.Nummer)+'|'+aint(AFX.WOF.Datei));
  END;

end;


//========================================================================
//  TermAFX
//========================================================================
sub TermAFX();
begin
  if (gAFXText=0) then RETURN;

  TextClose(gAFXText);
  gAFXText # 0;
  RETURN;
end;


//========================================================================
//  RechtOK
//
//========================================================================
sub RechtOK(aNr : int) : logic;
local begin
  erx   : int;
  v800  : int;
end;
begin

  SFX.Usr.Nummer    # aNr;
  SFX.Usr.Username  # gUsername;
  Erx # RecRead(924,1,0);
  if (Erx<=_rLocked) then RETURN true;

  // Vertretung?
  v800 # RecBufCreate(800);
  v800->Usr.VertretungUser # gUsername;
  Erx # RecRead(v800,4,0);
  WHILE (Erx<=_rMultiKey) and (v800->Usr.VertretungUser=gUsername) do begin

    if (today<v800->Usr.VertretungVonDat) or (today>v800->Usr.VertretungBisDat) then begin
      Erx # RecRead(v800,4,_recNext);
      CYCLE;
    end;

    SFX.Usr.Nummer    # SFX.Nummer;
    SFX.Usr.Username  # v800->Usr.Name;
    Erx # RecRead(924,1,0);
    if (Erx<=_rLocked) then begin
      RecBufDestroy(v800);
      RETURN true;
    end;
  END;
  RecBufDestroy(v800);

end;


//========================================================================
//  CreateMenu
//
//========================================================================
sub CreateMenu(aMenu : int; aBereich : alpha);
local begin
  Erx   : int;
  vHdl  : int;
  vHdl2 : int;
  vI    : int;
  vOK   : logic;
  v800  : int;
  vHdl3 : int;
  vFirst  : logic;
end;
begin

  if (aMenu=0) then RETURN;

  GV.Alpha.01 # aBereich;
  if (RecLinkInfo(922,999,4,_recCount)=0) then RETURN;


//  vHdl # aMenu->WinMenuItemAdd('SFX','&Sonderfunktionen',0);

  FOR Erx # RecLink(922,999,4,_recFirst)
  LOOP  Erx # RecLink(922,999,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // berechtigter User?
    if (SFX.EinzelrechtYN) then begin
      if (RechtOK(SFX.Nummer)=false) then CYCLE;  // KEIN RECHT !!!
    end;

    if (SFX.Name<>'') then begin
      vHdl3 # 0;
      if (SFX.Hauptmenuname<>'') then begin
        vHdl3 # Winsearch(aMenu, SFX.Hauptmenuname);
        if (vHdl3<>0) then begin
          if (vFirst=false) then begin
            vHdl2 # vHdl3->WinMenuItemAdd('seperator','');
            vHdl2->wpMenuSeparator # true;
          end;
          vFirst # true;
        end;
      end;

      if (vHdl3=0) then begin
        if (vHdl=0) then
          vHdl # aMenu->WinMenuItemAdd('SFX','&Sonderfunktionen',0);
        vHdl3 # vHdl;
      end;

//      if (SFX.Prozedur='') then
//        vHdl2 # vHdl->WinMenuItemAdd('SFX.'+cnvai(SFX.Nummer,_FmtNumNoGroup),StrCnv(SFX.Stichwort,_strUppeR)+' :   '+SFX.Name)
//      else
        vHdl2 # vHdl3->WinMenuItemAdd('SFX.'+cnvai(SFX.Nummer,_FmtNumNoGroup),SFX.Name);

      if (SFX.HotKey<>'') then begin
        vI # _WinKeyShift + (StrToChar(SFX.Hotkey,1) - 65 + 17);
        vHdl2->wpMenuKey # vI;
      end;
    end
    else begin
      if (vHdl=0) then
        vHdl # aMenu->WinMenuItemAdd('SFX','&Sonderfunktionen',0);
      vHdl2 # vHdl->WinMenuItemAdd('','');
      vHdl2->wpMenuSeparator # true;
    end;

  END;

end;


//========================================================================
//  Run
//
//========================================================================
sub Run(aNummer : int);
local begin
  Erx : int;
  vProz : alpha;
  aPara : alpha;
end;
begin
  SFX.Nummer # aNummer;
  Erx # RecRead(922,1,0);

  if (Erx<=_rLocked) and (SFX.Prozedur<>'') then begin

    if (SFX.EinzelrechtYN) then begin
      if (RechtOK(SFX.Nummer)=false) then begin
        Msg(921002,'',0,0,0);
        RETURN;
      end;
    end;

    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      //ErrTryIgnore(_ErrFsiNoFile, _ErrFsiExists); // 15.06.2022 AH
      ErrTryCatch(_ErrNoProcInfo,y);
      ErrTryCatch(_ErrNoSub,y);
      
      //2023-08-22 MR Parameter übergabe freischalten
      vProz # strcut(SFX.Prozedur,0,strfind(SFX.Prozedur,'(',0)-1);
      if(vProz='') then vProz # SFX.Prozedur
      
      aPara # strcut(SFX.Prozedur,strfind(SFX.Prozedur,'(',0)+2, strfind(SFX.Prozedur,')',0)-strfind(SFX.Prozedur,'(',0)-3);
      
      if(aPara <> '') then
        Call(vProz, aPara);
      else Call(vProz);
      
    end;
    if (ErrGet()<>_ErrOK) then begin
      if (gUsergroup <> 'SOA_SERVER') then
        Todo('Prozedur '+SFX.Prozedur);
      else
        Error(99,'TODO: Prozedur '+vProz);
      RETURN;
    end;
    RETURN;
  end;

end;


/****
  // Öffnen des Verzeichnisses
  tDirHdl # StoDirOpen(0, 'Menu');

  if (tDirHdl != 0) then begin
    // Ersten Eintrag lesen
    tObjName # StoDirRead(tDirHdl, _StoFirst);

    // Solange Einträge vorhanden sind
    while (tObjName != '') do begin
      // Füge Eintrag zu Liste hinzu
      tLine # aHdlDls->WinLstDatLineAdd(tObjName, _WinLstDatLineLast);

      // Öffne Storage-Objekt für weitere Informationen
      tObjHdl # StoOpen(tDirHdl, tObjName);

      // Füge auch diese Informationen zur DataList hinzu
      if (tObjHdl != 0) then begin
        //ID
        aHdlDls->WinLstCellSet(tObjHdl->spID                  , 2, tLine);
        //Originialgröße
        aHdlDls->WinLstCellSet(tObjHdl->spSizeOrg             , 3, tLine);
        //Größe in der Datenbank
        aHdlDls->WinLstCellSet(tObjHdl->spSizeDba             , 4, tLine);
        //Erstellunsdatum
        aHdlDls->WinLstCellSet(FmtCalTime(tObjHdl->spCreated) , 5, tLine);
        //Bearbeitungsdatum
        aHdlDls->WinLstCellSet(FmtCalTime(tObjHdl->spModified), 6, tLine);
        //Erstellt von
        aHdlDls->WinLstCellSet(tObjHdl->spCreatedUser         , 7, tLine);
        //Bearbeitet von
        aHdlDls->WinLstCellSet(tObjHdl->spModifiedUser        , 8, tLine);
        tObjHdl->StoClose();
      end;

      // Nächsten Verzeichnis-Eintrag lesen
      tObjName # StoDirRead(tDirHdl, _StoNext);
    end;

    // Verzeichnis schliessen
    tDirHdl->StoClose();
  end;
RETURN;
***/

//========================================================================
// Check_AFX
//
//========================================================================
sub Check_AFX(aName : alpha) : logic
local begin
  vErg  : int;
  vA,vB : alpha;
end;
begin
//debugx(aName);
  if (aName='') or (gAFXText=0) then RETURN false;
//  AFX.Name # aName;
//  vErg # RecRead(923,1,0);    // AFX holen
//  if (vErg>_rLocked) then RETURN false;
  vErg # TextSearch(gAFXText, 1,1, _TextSearchCI, '|'+aName+'|');
  if (vErg=0) then RETURN false;
  vA # TextLineRead(gAFXText, vErg, 0)
  AFX.Prozedur # Str_Token(vA, '|',2+1);
  if (AFX.Prozedur='') then begin
    vB # Str_Token(vA, '|',3+1);
    AFX.WoF.Nummer # cnvia(vB);
    vB # Str_Token(vA, '|',4+1);
    AFX.WoF.Datei  # cnvia(vB);
  end
  else begin
    AFX.WoF.Nummer # 0;
    AFX.WoF.Datei  # 0;
  end;


//debug('gesucht:'+aName+'   found:'+AFX.prozedur);
  if (AFX.Prozedur='') and (AFX.WoF.Nummer=0) then RETURN false;
  RETURN true;
end;


//========================================================================
// Run_AFX
//        MÖGLICHES ERGBNIS ÜBER -ERG- ÜBERGEBEN !!!
//        Ergebnis  0   - keine Funktion vorhanden
//                  >0  - AFX ausgeführt und std. Funktion ZUSÄTZLICH auch
//                  <0  - AFX ausgeführt aber std. Funktion NICHT ausführen
//========================================================================
sub Run_AFX(
  aName     : alpha;
  opt aPara : alpha(1000)
  ) : int;
local begin
  vErr  : int;
  vErg  : int;
  v923  : int;
  vP    : alpha;
  vDatei  : int;
  vNr     : int;
end;
begin
  if (VarInfo(Windowbonus)>0) then
    if (gFile=923) then v923 # RekSave(923);
  if (Check_AFX(aName)=false) then begin
    if (v923<>0) then RekRestore(v923);
    RETURN 0;
  end;

  // Workflow statt Anker???
  if (AFX.WoF.Nummer<>0) then begin
    vDatei  # AFX.Wof.Datei;
    vNr     # AFX.Wof.Nummer;
    if (v923<>0) then RekRestore(v923);
    Lib_Workflow:Trigger(vDatei, vNr, '');   // WOF starten
    RETURN 1;
  end;
  vP # AFX.Prozedur;
  if (v923<>0) then RekRestore(v923);

//debug('starte:'+AFX.Prozedur+'  ERR:'+aint(ErrGet()));
  AfxRes # -123;
  Erg # _rOK;       // 20.06.2022 AH
  try begin
    ErrTryIgnore(_rlocked,_rNoRec);
    //ErrTryIgnore(_ErrFsiNoFile, _ErrFsiExists); // 15.06.2022 AH
    ErrTryCatch(_ErrNoProcInfo,y);
    ErrTryCatch(_ErrNoSub,y);
    vErg # Call(vP, aPara);
  end;
  vErr # ErrGet();
  if (afxres=-123) then AfxRes # Erg;  // 27.05.2021 AH TODOERX
  
  if (vErr<>_ErrOK) then begin
//debug('error:'+aint(vErr));
    if (gUsergroup <> 'SOA_SERVER') then
      Todo('AFX Prozedur: '+vP);
    else
      Error(99,'TODO: AFX Prozedur: '+vP);

    RETURN 0;
  end;

  RETURN vErg;
end;

//========================================================================
