@A+
//==== Business-Control ==================================================
//
//  Prozedur    Org_Data
//                OHNE E_R_G
//  Info
//
//
//  10.07.2012  AI  Erstellung der Prozedur
//  07.08.2012  AI  Abteilungne werden alphabetisch sortiert
//  20.05.2016  AH  Gruppe "SYSTEM" eingebaut
//  27.03.2020  AH  Userstatus
//  16.06.2020  AH  User "SOA_SYNC"
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetAliveDelta(aName : alpha) : bigint;
//    SUB KeepAlive(opt aZusatz : alpha)
//    SUB UpdateAllKeepAlive();
//    SUB KillMe()
//    SUB RebuildOrga(aTV : int)
//    SUB UpdateOrga(aTV : int)
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cShort : true
end;

//=========================================================================
sub SetUserStatus(aStatus : alpha)
begin
  Lib_RmtData:UserWrite('Userstatus', aStatus, gUsername);
end;

//=========================================================================
sub GetUserStatus(aUser : alpha) : alpha
begin
  RETURN Lib_RmtData:UserRead('Userstatus',n, aUser);
end;

//=========================================================================
//=========================================================================
sub GetAliveDelta(aName : alpha) : bigint;
local begin
  vA  : alpha;
  vBI : bigint;
end;
begin
  vBI # -1;
  if (RmtDataRead(aName, _recunlock, var vA)<=_rLocked) then begin
    vBI # cnvba(vA);
    vBI # Lib_Berechnungen:DatTimToBig(today, now) - vBI;
  end;

  RETURN vBI;
end;


//=========================================================================
//  KeepAlive
//
//=========================================================================
sub KeepAlive(
  opt aZusatz   : alpha;
  opt aUsername : alpha);
local begin
  vBI : bigint;
end;
begin
  if (Set.Org.IdleInterval=0) then RETURN;
  if (aUsername='') then aUsername # gUsername;
  
  // Eventuell vorhandene Befehle übernehmen
  if (aZusatz = '') then begin
    RmtDataRead(StrCnv(aUsername,_StrLetter), _recunlock, var aZusatz);
    aZusatz # StrCut(aZusatz, 11, StrLen(aZusatz)-10);
  end;

  vBI # Lib_Berechnungen:DatTimToBig(Today, now);
  RmtDataWrite(StrCnv(aUsername,_StrLetter), _recunlock | _RmtDataTemp, cnvab(vBI, _FmtNumNoGroup) + aZusatz);

//  vBI # Lib_Berechnungen:DatTimToBig(Today, now);
//  RmtDataWrite(StrCnv(gUsername,_StrLetter), _recunlock, cnvab(vBI, _FmtNumNoGroup));
end;

/***
//=========================================================================
//  UpdateAllKeepAlive
//
//=========================================================================
Sub UpdateAllKeepAlive();
local begin
  vKey                : alpha;
  vUser               : int;
  vUsername           : alpha;
  vA                  : alpha;
  vOK                 : logic;
end;
begin

  // Alle Schlüsselwerte lesen
  FOR vKey # RmtDataSearch('',_RecFirst);
  LOOP vKey # RmtDataSearch(vKey,_RecNext);
  WHILE (vKey != '') do begin
    if (RmtDataRead(vKey,0,var vA)<=_rLocked) then begin

      vOK # n;
      vUser         # CnvIa(UserInfo(_UserNextId));
      // Auswahlliste füllen
      FOR   vUser # CnvIa(UserInfo(_UserNextId))
      LOOP  vUser # CnvIa(UserInfo(_UserNextId,vUser))
      WHILE (vUser > 0) DO BEGIN
        vUserName # StrCnv(UserInfo(_UserName),_StrLEtter);
        if (vUserName=vKey) then vOK # y;
      END;
      // User nicht vorhanden? -> Löschen
      if (vOK=false) then begin
        RmtDataWrite(StrCnv(vKey,_StrLetter), _recunlock, '');
      end;
    end;
  END;
end;
***/

//=========================================================================
//  KillMe
//
//=========================================================================
sub Killme();
begin
  Lib_RmtData:UserRead('Userstatus', true, gUsername);
  RmtDataWrite(StrCnv(gUsername,_StrLetter), _recunlock | _RmtDataTemp, '');
end;


//=========================================================================
// RebuildOrga
//
//=========================================================================
sub RebuildOrga(aTV : int)
local begin
  Erx       : int;
  v800      : int;
  vItem     : handle;
  vTree     : int;
  vItemTree : handle;
  vA        : alpha(250);
end;
begin

  // alle entfernen
  aTV->WinTreeNodeRemove( true );

  v800 # RecBufCreate(800);

  // Abteilungen ermitteln
  vTree # CteOpen(_cteTreeCI);
  FOR  Erx # RecRead( v800, 1, _recFirst );
  LOOP Erx # RecRead( v800, 1, _recNext );
  WHILE ( Erx <= _rLocked) DO BEGIN
    if (v800->Usr.Abteilung='') then CYCLE;
    Sort_ItemAdd(vTree, v800->Usr.Abteilung, 800, RecInfo(v800, _recId));
  END;
  // Abteilungen anlegen
  FOR  vItemTree # Sort_ItemFirst(vTree)
  LOOP vItemTree # Sort_ItemNext(vTree, vItemTree)
  WHILE (vItemTree != 0) DO BEGIN
    vA # StrCut(vItemTree->spName,1, StrLen(vItemTree->spname)-8);
    if (vA = '') then CYCLE;

    // Abteilung prüfen...
    vItem # aTV->Winsearch(StrCnv(vA, _StrLetter));
    if (vItem<>0) then
      CYCLE;

    // Abteilung neu anlegen
    vItem # aTV->WinTreeNodeAdd(StrCnv(vA, _StrLetter) , vA);
    vItem->WinPropSet( _winPropNodeStyle, _WinNodeRedBook);
  END;
  Sort_KillList(vTree);
  // ENDE Abteilungen anlegen



  v800 # RecBufCreate(800);
  FOR  Erx # RecRead( v800, 1, _recFirst );
  LOOP Erx # RecRead( v800, 1, _recNext );
  WHILE ( Erx <= _rLocked) DO BEGIN
    if (v800->Usr.Abteilung='') then CYCLE;

    // bei leerern Namen den Usernamen nehmen
    if (v800->Usr.Name + v800->Usr.Vorname='') then v800->Usr.Name # v800->usr.Username;

    // Abteilung prüfen...
    vItem # aTV->Winsearch(StrCnv(v800->Usr.Abteilung, _StrLetter));
    if (vItem<>0) then begin
      // Abteilung existiert bereits, dann User eintragen
    
      if (cShort) then begin
        vItem # vItem->WinTreeNodeAdd(StrCnv(v800->Usr.UserName,_StrLetter) ,v800->Usr.Username);
        vItem->wphelptip # v800->Usr.Vorname+' '+v800->Usr.Name;
      end
      else begin
        vItem # vItem->WinTreeNodeAdd(StrCnv(v800->Usr.UserName,_StrLetter) ,v800->Usr.Vorname+' '+v800->Usr.Name);
      end;
      CYCLE;
    end;

    // Abteilung neu anlegen
    vItem # aTV->WinTreeNodeAdd(StrCnv(v800->Usr.Abteilung, _StrLetter) , v800->Usr.Abteilung);
    vItem->WinPropSet( _winPropNodeStyle, _WinNodeRedBook);

    // User eintragen
    vItem # vItem->WinTreeNodeAdd(Strcnv(v800->Usr.UserName,_StrLetter), v800->Usr.Vorname+' '+v800->Usr.Name);
//    vItem->WinPropSet( _WinPropCustom, _WinNodeRedBall );
//    vItem->WinPropSet( _winPropNodeStyle, _WinNodeRedBall );
  END;
  RecbufDestroy(v800);


  // SYSTEM
  vItem # aTV->Winsearch('System');
  if (vItem=0) then begin
    vItem # aTV->WinTreeNodeAdd('System' , 'System');
    vItem->WinPropSet( _winPropNodeStyle, _WinNodeRedBook);
  end;
  vItem->WinTreeNodeAdd('FILESCANNER', 'Filescanner');
  vItem->WinTreeNodeAdd('JOBSERVER', 'JobServer');

  if (Set.SQL.SoaYN) or (gOdbcCon<>0) then begin
    // Abteilung neu anlegen
    vItem # aTV->Winsearch('System');
    if (vItem=0) then begin
      vItem # aTV->WinTreeNodeAdd('System' , 'System');
      vItem->WinPropSet( _winPropNodeStyle, _WinNodeRedBook);
    end;

    // User eintragen
    if (Set.SQL.SoaYN) then
      vItem->WinTreeNodeAdd('SYNC', 'Sync');
    if (gOdbcCon<>0) then
      vItem->WinTreeNodeAdd('PRINTSERVER', 'PrintServer');
  end;


//  vItem->WinPropSet( _winPropCustom, Usr.Fav.Custom );
//  vMenu->WinPropSet( _winPropNodeExpanded, true );

end;


//=========================================================================
// UpdateOrga
//
//=========================================================================
sub UpdateOrga(aTV : int)
local begin
  v800      : int;
  vItem     : handle;
  vItem2    : handle;
  vBI       : bigint;
  vI        : int;
  vMax      : int;
  vA        : alpha(1000);
  vStatus   : alpha;
end;
begin

  if (aTV=0) then RETURN;

  vItem # WinInfo(aTV,_Winfirst);
  WHILE (vItem<>0) do begin

//debug(vItem->wpname+'  '+aint(WinInfo(vItem, _wintype)));

    // Abteilung...
    vMax  # 0;
    vItem2 # WinInfo(vItem,_Winfirst);
    WHILE (vItem2<>0) do begin

      vI # 0;
      if (vItem2->wpname='PRINTSERVER') then begin
/*
        vA # Lib_DotNetServices:Active(Lib_DotNetServices:ServerURL());
        if (vA<>'OK') then
          vA # Lib_DotNetServices:Version(Lib_DotNetServices:ServerURL());
*/
        vA # Lib_DotNetServices:Active('AUTO',1);   // Timeout uninteressant, da NICHT auf Antwort gewartet wird!!!
        if (vA='OK') then vI # 2;
      end;

//      if (RmtDataRead(vItem2->wpname, _recunlock, var vA)<=_rLocked) then begin
//        vBI # cnvba(vA);
//        vBI # Lib_Berechnungen:DatTimToBig(today, now) - vBI;
      vBI # GetAliveDelta(vItem2->wpName);
      
      vStatus # GetUserStatus(vItem2->wpname);
      
      if (cShort) then begin
        if (vStatus<>'') then
          vItem2->wpCaption # vItem2->wpName + ' ('+vStatus+')'
        else
          vItem2->wpCaption # vItem2->wpName;
      end
      else begin
        vItem2->wpHelpTip # vStatus;
      end;
      
      if (vBI>=0) then begin
        if (vItem2->wpname='FILESCANNER') or (vItem2->wpname='JOBSERVER') then begin
          if (vBI>cnvbi(2)) then begin                  // 2 Sekunden Timeout beim SOA
            vI # 0;                                     // SYNC STEHT bei 2 Sekunden!!!
          end
          else begin
            vI # 2; // grün
          end;
        end
        else if (vItem2->wpname='SYNC') then begin
          if (vBI>cnvbi(2)) then begin                  // 2 Sekunden Timeout beim SOA
            vI # 0;                                     // SYNC STEHT bei 2 Sekunden!!!
          end
          else begin
            GV.Sys.UserID # gUserID;
            if (RecLinkInfo(992,999,10,_recCount)=0) then     // kein Sync für mich?
              vI # 1  // blau
            else
              vI # 2; // grün
          end;
        end
        else begin
          // ------------- START Hubert
          RmtDataRead(vItem2->wpname, _recunlock, var vA);
          if (StrFind(vA, 'CALLSTART', 0) > 0) then begin
            vI # 3;
          end
          else if (StrFind(vA, 'CALLENDE', 0) > 0) then begin
            vI # 2;
          end
          else begin
            vBI # cnvba(vA);
            vBI # Lib_Berechnungen:DatTimToBig(today, now) - vBI;
            if (vBI>cnvbi(Set.Org.IdleInterval)) then vI # 1
            else vI # 2;
          end;
          // ------------- ENDE Hubert
        end;
      end;

      case vI of
        1 : vItem2->WinPropSet( _winPropNodeStyle, _WinNodeblueBall);
        2 : vItem2->WinPropSet( _winPropNodeStyle, _WinNodegreenBall);
        3 : vItem2->WinPropSet( _winPropNodeStyle, _WinNodeDoc);
        otherwise
            vItem2->WinPropSet( _winPropNodeStyle, _WinNodeRedBall);
//          vItem2->wpImageTileUser # 7;  // Telefon
      end;
      vMax # max(vMax,vI);

      vItem2 # WinInfo(vItem2,_WinNext);
    END;


    case vMax of
      1 : vItem->WinPropSet( _winPropNodeStyle, _WinNodeblueBook);
      2 : vItem->WinPropSet( _winPropNodeStyle, _WinNodegreenBook);
      3 : vItem->WinPropSet( _winPropNodeStyle, _WinNodeDoc);
      otherwise
          vItem->WinPropSet( _winPropNodeStyle, _WinNodeRedBook);
    end;


    vItem # WinInfo(vItem,_WinNext);
  END;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================