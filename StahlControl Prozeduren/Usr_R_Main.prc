@A+
//==== Business-Control ==================================================
//
//  Prozedur    Usr_R_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  09.05.2016  AH  Vertretung
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB BuildMyRights()
//    SUB AddRightString(aA1 : alpha(cMaxRights); aA2 : Alpha(cMaxRights)) : alpha
//    SUB SwitchRight(aId : int)
//    SUB ManageRights(aUsrRights : alpha(cMaxRights); aGrpRights : alpha(cMaxRights); aUserYN : logic) : alpha
//
//    SUB EvtClicked(aEvt : event) : logic;
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecId : int) : logic
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//
//========================================================================
@I:Def_global
@I:Def_Rights

declare AddRightString(aA1 : alpha(4000); aA2 : Alpha(4000);aMax  : int) : alpha

//========================================================================
//  BuildMyRights
//                Rechte des aktuellen Benutzers errechnen
//========================================================================
SUB BuildMyRights()
local begin
  vIch      : alpha;
  vGString  : alpha(cMaxRights);
  vGStringC : alpha(cMaxCustomRights);
  vX        : int;
  vAdm      : logic;
  v800      : int;
  vMaxR     : int;
  vMaxRC    : int;
  Erx       : int;
end;
begin
  vIch # UserInfo(_UserName,CnvIA(UserInfo(_UserCurrent)));

  // Rechtearray aufbauen
  Usr.Username # vIch;
  Erx # RecRead(800,1,0);
  if (Erx>_Rlocked) then RecBufClear(800);
  if (Usr.Rights1='') then
    WHILE (StrLen(Usr.Rights1)<250) do
      Usr.Rights1 # Usr.Rights1 + '.';
  if (Usr.Rights2='') then
    WHILE (StrLen(Usr.Rights2)<250) do
      Usr.Rights2 # Usr.Rights2 + '.';
  if (Usr.Rights3='') then
    WHILE (StrLen(Usr.Rights3)<250) do
      Usr.Rights3 # Usr.Rights3 + '.';
  if (Usr.Rights4='') then
    WHILE (StrLen(Usr.Rights4)<250) do
      Usr.Rights4 # Usr.Rights4 + '.';
  if (Usr.Customrights1='') then
    WHILE (StrLen(Usr.Customrights1)<cMaxCustomRights) do
      Usr.Customrights1 # Usr.Customrights1 + '.';
  if (Erx>_rLocked) then begin
    Usr.Username # UserInfo(_UserName,CnvIA(UserInfo(_UserCurrent)));
    RekInsert(800,0,'AUTO');
  end;


  // Gruppenrechte bauen...
  vGString # '';
  FOR Erx # RecLink(802,800,1,_RecFirst)    // Gruppen loopen
  LOOP Erx # RecLink(802,800,1,_RecNext)
  WHILE (Erx=_ROk) do begin
    RecLink(801,802,1,0);                   // Gruppenrecht holen
    vGString  # AddRightString(vGString, Usr.Grp.Rights1+Usr.Grp.Rights2+Usr.Grp.Rights3+Usr.Grp.Rights4, cMaxRights);
    vGStringC # AddRightString(vGStringC, Usr.Grp.Customright1, cMaxCustomRights);
  END;

  // Programmierer sind IMMER Admins:
  if (UserInfo(_UserGroup, cnvia(UserInfo(_UserCurrent))) = 'PROGRAMMIERER') then vAdm # y;


  vMaxR   # StrLen(Usr.Rights1+Usr.Rights2+Usr.Rights3+Usr.Rights4);
  vMaxRC  # StrLen(Usr.Customrights1);
  // finale Rechte bauen...
  FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=vMaxR do begin
    if ((StrCut(Usr.Rights1+Usr.Rights2+Usr.Rights3+Usr.Rights4,vX,1)='+') or (vAdm)) then Rechte[vx] # y
    else if StrCut(Usr.Rights1+Usr.Rights2+Usr.Rights3+Usr.Rights4,vX,1)='-' then Rechte[vx] # n
    else if StrCut(vGString,vX,1)='+' then Rechte[vx] # y;
    if (vX=Rgt_Admin) then vAdm # Rechte[vX];
  END;
  FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=vMaxRC do begin
    if ((StrCut(Usr.Customrights1,vX,1)='+') or (vAdm)) then CustomRechte[vx] # y
    else if StrCut(Usr.Customrights1,vX,1)='-' then CustomRechte[vx] # n
    else if StrCut(vGStringC,vX,1)='+' then CustomRechte[vx] # y;
  END;


  // Ist aktiver User eine Vertretung?
  v800 # RecBufCreate(800);
  v800->Usr.VertretungUser # vIch;
  Erx # RecRead(v800,4,0);
  WHILE (Erx<=_rMultiKey) and (v800->Usr.VertretungUser=vIch) do begin

    if (today<v800->Usr.VertretungVonDat) or (today>v800->Usr.VertretungBisDat) then begin
      Erx # RecRead(v800,4,_recNext);
      CYCLE;
    end;

    // Gruppenrechte bauen...
    vGString # '';
    FOR Erx # RecLink(802,v800,1,_RecFirst)    // Gruppen loopen
    LOOP Erx # RecLink(802,v800,1,_RecNext)
    WHILE (Erx=_ROk) do begin
      RecLink(801,802,1,0);                   // Gruppenrecht holen
      vGString  # AddRightString(vGString, Usr.Grp.Rights1 + Usr.Grp.Rights2 + Usr.Grp.Rights3 + Usr.Grp.Rights4, cMaxRights);
      vGStringC # AddRightString(vGStringC, Usr.Grp.Customright1, cMaxCustomRights);
    END;

    // finale Rechte bauen...
    FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=vMaxR do begin
        if ((StrCut(v800->Usr.Rights1 + v800->Usr.Rights2 + v800->Usr.Rights3 + v800->Usr.Rights4,vX,1)='+') or (vAdm)) then Rechte[vx] # y
    //    else if StrCut(v800->Usr.Rights1 + v800->Usr.Rights2 + v800->Usr.Rights3 + v800->Usr.Rights4,vX,1)='-' then Rechte[vx] # n
        else if StrCut(vGString,vX,1)='+' then Rechte[vx] # y;
        if (vX=Rgt_Admin) then vAdm # Rechte[vX];
    END;
    FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=vMaxRC do begin
        if ((StrCut(v800->Usr.Customrights1,vX,1)='+') or (vAdm)) then CustomRechte[vx] # y
        else if StrCut(vGStringC,vX,1)='+' then CustomRechte[vx] # y;
    END;

    Erx # RecRead(v800,4,_recNext);
  END;
  RecBufDestroy(v800);

end;


//========================================================================
//  AddRightString
//                  Rchte verknüpfen
//========================================================================
sub AddRightString(
  aA1   : alpha(4000);
  aA2   : Alpha(4000);
  aMax  : int;
) : alpha
local begin
  vA  : alpha(4000);
  vX  : int;
end;
begin

  WHILE StrLen(aA1)<aMax do
    aA1 # aA1 + '.';

  WHILE StrLen(aA2)<aMax do
    aA2 # aA2 + '.';

  FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=aMax do begin
    if StrCut(aA2,vX,1)='+' then vA # vA + '+'
    else if StrCut(aA2,vX,1)='-' then vA # vA + '-'
    else if StrCut(aA1,vX,1)='+' then vA # vA + '+'
    else if StrCut(aA2,vX,1)='-' then vA # vA + '-'
    else vA # vA + '.';
  END;

  RETURN vA;
end;


//========================================================================
//  GrpSwitchRight
//                  GruppenRecht umsetzen
//========================================================================
sub SwitchRight(
  aId : int;
)
local begin
  vStatus : int;
end;
begin

                                        // Userrecht verändert?
  if ($UsrStatus->wpvisible) then begin
    $DL.Rechte->WinLstCellGet(vStatus, 4, aId);
    if (vStatus=41) then vStatus # 42 //41,42 / 102,102
    else if (vStatus=42) then vStatus # 0
    else vStatus # 41;
    $DL.Rechte->WinLstCellSet(vStatus, 4, aID);
  end
  else begin                            // Gruppenrecht verändert
    $DL.Rechte->WinLstCellGet(vStatus, 3, aId);
    if (vStatus=41) then vStatus # 0 //41,42 / 102,102
    else vStatus # 41;
    $DL.Rechte->WinLstCellSet(vStatus, 3, aID);
  end;
end;


//========================================================================
//  ManageRights
//
//========================================================================
sub ManageRights(
  aUsrRights  : alpha(cMaxRights);
  aGrpRights  : alpha(cMaxRights);
  aUserYN     : logic;
): alpha
local begin
  vHdl        : int;
  vHdl2       : int;
  vT          : int;
  vX          : int;
  vY          : int;
  vZeile      : int;
  vAnzRechte  : int;
  vA          : alpha(cMaxRights);
  vNr         : int;
  vSpalte     : int;

  vTree       : int;
  vItem       : int;
  vAusGruppe  : logic;
//  vB          : alpha;
end;
begin

  if (aUsrRights='') then vAusGruppe # y;

  WHILE StrLen(aUsrRights)<cMaxRights do
    aUsrRights # aUsrRights + '.';

  WHILE StrLen(aGrpRights)<cMaxRights do
    aGrpRights # aGrpRights + '.';


  vHdl # WinOpen('Usr.R.Verwaltung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('lb.User');
  if (vAusGruppe) then
    vHdl2->wpcaption # Usr.Grp.GruppenName
  else
    vHdl2->wpcaption # Usr.UserName;

  vHdl2 # vHdl->WinSearch('DL.Rechte');
  //vHdl # WinxAddByName(gFrmMain,'Usr.R.Verwaltung', _WinxAddHidden);
  //Lib_GuiCom:AddChildWindow(gMdi, vHdl, '',c_ModeOther);
  //vHdl2 # vHdl->WinSearch('DL.Rechte');

                                        // "Def_Rights" in Datalist schreiben

  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN '';


  vT # TextOpen(3);
  TextRead(vT,'Def_Rights',_TextProc);
  vZeile # 1;
  WHILE (vZeile<=TextInfo(vT,_TextLines)) do BEGIN
    vA # TextLineRead(vT,vZeile,0);

    if (StrFind(Strcnv(vA,_StrUpper),'RGT_',0)<>0) then begin

      vX # StrFind(vA,':',0);
      vNr # CnvIA(StrCut(vA,vX+1,StrFind(vA,'//',0)-vX));

      vX # StrFind(vA,'//',0);
      if (vX<>0) then
        vA # StrCut(vA, vX+3, 999);

      Sort_ItemAdd(vTree,vA+'|',999,vNr);
    end;
    vZeile # vZeile + 1;
  END;
  TextClose(vT);


  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
      vA # vItem->spName;
      vNr # vItem->spID;

      vX # StrFind(vA,'|',0);
      vA # StrCut(vA,1,vX-1);
//debug('angelegt: '+vA+' '+cnvai(vNr));

      vHdl2->WinLstDatLineAdd(vA);
      vHdl2->WinLstCellSet(vNr,2,_WinLstDatLineLast);

      if (StrCut(aGrpRights,vNr,1)='+') then
        vHdl2->WinLstCellSet(41,3,_WinLstDatLineLast);
      if (StrCut(aUsrRights,vNr,1)='+') then
        vHdl2->WinLstCellSet(41,4,_WinLstDatLineLast);
      if (StrCut(aUsrRights,vNr,1)='-') then
        vHdl2->WinLstCellSet(42,4,_WinLstDatLineLast);

      vAnzRechte # vAnzRechte + 1;
  END;

  // Löschen der Liste
  Sort_KillList(vTree);


  vA # aUsrRights;
  vSpalte # 4;
                                    // Gruppenrechte verwalten?
  if (aUserYN=false) then begin
    $UsrStatus->wpvisible # false;
    $ErgStatus->wpvisible # false;
    $bt.All.Set->wpvisible # true;
    $bt.All.Clear->wpvisible # true;
    vA # aGrpRights;
    vSpalte # 3;
  end;

  if (vHdl->WinDialogRun(_WinDialogCenter,gMdi))<>2 then begin
    vHdl->WinClose();
    RETURN vA;
  end;

  FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=vAnzRechte do begin
//vHdl2->WinLstCellGet(vB, 1, vX);
    vHdl2->WinLstCellGet(vY, 2, vX);
    vHdl2->WinLstCellGet(vNr, vSpalte, vX);

    vA # StrDel(vA, vY,1);
    if (vNr=41) then vA # StrIns(vA, '+', vY);
    if (vNr=42) then vA # StrIns(vA, '-', vY);
    if (vNr=0)  then vA # StrIns(vA, '.', vY);
//if (vB='Administrator') or (vNr=1) then debug(vB+' '+aint(vy)+' '+aint(vNr)+'  string'+StrCut(vA,1,20));
//if (StrCut(vA,1,1)<>'+') then debug(vB);
  END;

  vHdl->WinClose();

  RETURN vA;
end;


//========================================================================
//  ManageCustomRights
//
//========================================================================
sub ManageCustomRights(
  aUsrRights  : alpha(cMaxCustomRights);
  aGrpRights  : alpha(cMaxCustomRights);
  aUserYN     : logic;
): alpha
local begin
  ERx         : int;
  vHdl        : int;
  vHdl2       : int;
  vX          : int;
  vY          : int;
  vZeile      : int;
  vAnzRechte  : int;
  vA          : alpha(cMaxCustomRights);
  vNr         : int;
  vSpalte     : int;

  vTree       : int;
  vItem       : int;
  vAusGruppe  : logic;
end;
begin

  if (aUsrRights='') then vAusGruppe # y;

  WHILE StrLen(aUsrRights)<cMaxCustomRights do
    aUsrRights # aUsrRights + '.';

  WHILE StrLen(aGrpRights)<cMaxCustomRights do
    aGrpRights # aGrpRights + '.';

  vHdl # WinOpen('Usr.R.Verwaltung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('lb.User');
  if (vAusGruppe) then
    vHdl2->wpcaption # Usr.Grp.GruppenName
  else
    vHdl2->wpcaption # Usr.UserName;

  vHdl2 # vHdl->WinSearch('DL.Rechte');

  // Datei 804 in Datalist schreiben
  vTree # CteOpen(_CteTreeCI);
  If (vTree = 0) then RETURN '';

  FOR Erx # RecRead(804,1,_recFirst)
  LOOP Erx # RecRead(804,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vNr # Usr.CR.Nummer;
    vA  # Usr.CR.Name;
    Sort_ItemAdd(vTree,vA+'|',999,vNr);
  END;


  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
      vA # vItem->spName;
      vNr # vItem->spID;

      vX # StrFind(vA,'|',0);
      vA # StrCut(vA,1,vX-1);

      vHdl2->WinLstDatLineAdd(vA);
      vHdl2->WinLstCellSet(vNr,2,_WinLstDatLineLast);

      if (StrCut(aGrpRights,vNr,1)='+') then
        vHdl2->WinLstCellSet(41,3,_WinLstDatLineLast);
      if (StrCut(aUsrRights,vNr,1)='+') then
        vHdl2->WinLstCellSet(41,4,_WinLstDatLineLast);
      if (StrCut(aUsrRights,vNr,1)='-') then
        vHdl2->WinLstCellSet(42,4,_WinLstDatLineLast);

      vAnzRechte # vAnzRechte + 1;
  END;

  // Löschen der Liste
  Sort_KillList(vTree);

  vA # aUsrRights;
  vSpalte # 4;
                                    // Gruppenrechte verwalten?
  if (aUserYN=false) then begin
    $UsrStatus->wpvisible # false;
    $ErgStatus->wpvisible # false;
    $bt.All.Set->wpvisible # true;
    $bt.All.Clear->wpvisible # true;
    vA # aGrpRights;
    vSpalte # 3;
  end;

  if (vHdl->WinDialogRun(_WinDialogCenter,gMdi))<>2 then begin
    vHdl->WinClose();
    RETURN vA;
  end;

  FOR vX # 1 LOOP vX # vX + 1 WHILE vX<=vAnzRechte do begin
    vHdl2->WinLstCellGet(vY, 2, vX);
    vHdl2->WinLstCellGet(vNr, vSpalte, vX);
    vA # StrDel(vA, vY,1);
    if (vNr=41) then vA # StrIns(vA, '+', vY);
    if (vNr=42) then vA # StrIns(vA, '-', vY);
    if (vNr=0)  then vA # StrIns(vA, '.', vY);
  END;

  vHdl->WinClose();

  RETURN vA;
end;


//========================================================================
//========================================================================
//========================================================================

//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vI  : int;
end;
begin


  if (aEvt:OBj->wpname='bt.All.Set') then begin
    $DL.Rechte->wpautoupdate # false;
    FOR vI # 1 loop inc(vI) WHILE (vI<=cMaxRights) do begin
      $DL.Rechte->WinLstCellSet(41, 3, vI);
    END;
    $DL.Rechte->wpautoupdate # true;
  end;

  if (aEvt:OBj->wpname='bt.All.Clear') then begin
    $DL.Rechte->wpautoupdate # false;
    FOR vI # 1 loop inc(vI) WHILE (vI<=cMaxRights) do begin
      $DL.Rechte->WinLstCellSet(0, 3, vI);
    END;
    $DL.Rechte->wpautoupdate # true;
  end;

  return(true);
end;


//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
begin
  if (aKey=_WinKeyReturn) then begin
    SwitchRight(aID);
  end;
end;


//========================================================================
//  EvtMouseItem
//                Mausclick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin

  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    SwitchRight(aId);
  end;

end;


//========================================================================
//  EvtLstDataInit
//                  Kontrolle der Rechteübersicht
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
) : logic
local begin
  vGrp  : int;
  vUsr  : int;
end;
begin
  aEvt:obj->WinLstCellGet(vGrp, 3,aRecId);
  aEvt:obj->WinLstCellGet(vUsr, 4,aRecId);
  if (vUsr=41) then aEvt:Obj->WinLstCellSet(41,5,aRecId)
  else if (vUsr=42) then aEvt:Obj->WinLstCellSet(42,5,aRecId)
  else if (vGrp=41) then aEvt:Obj->WinLstCellSet(41,5,aRecId)
  else if (vGrp=42) then aEvt:Obj->WinLstCellSet(42,5,aRecId)
  else aEvt:Obj->WinLstCellSet(42,5,aRecId);
  RETURN true;
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
//========================================================================