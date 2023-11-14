@A+
//===== Business-Control =================================================
//
//  Prozedur  Blb_R_Main
//                    OHNE E_R_G
//  Info
//
//
//  14.04.2014  AH  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//  SUB EvtInit
//  SUB EvtClicked
//  SUB AusUser()
//  SUB AusGruppe()
//  SUB EvtLstDataInit
//  SUB EvtMouseItem
//  SUB EvtMouseItem
//
//========================================================================
@I:Def_Global

define begin
  cTitle      : 'Berechtigungen'
  cFile       : 0
  cMenuName   : ''//Std.Bearbeiten'
  cPrefix     : 'blb_R'
  cZList      : 0
  cKey        : 0
  cMdiVar     : gMDIPara
  cRecList    : $rlBlbRechte
end;


//========================================================================
//  EvtInit
//
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  $lb.ID->wpcaption # Gv.Alpha.01;
  $lb.ID->wpcustom  # aint(gv.int.20);

  App_Main:EvtInit(aEvt);
  RETURN(true);
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  if (aEvt:Obj->wpname='bt.NewUser') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusUser');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  if (aEvt:Obj->wpname='bt.NewGruppe') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.G.Verwaltung',here+':AusGruppe');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  if (aEvt:Obj->wpname='bt.Del') then begin
    if (cRecList->wpDbRecId<>0) then begin
      if (Msg(917001, Blb.R.Name,_WinIcoQuestion, _WinDialogYesNo, 2)<>_Winidyes) then RETURN true;
      RekDelete(917,_recunlock,'MAN');
      cRecList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
    end;
  end;

  RETURN(true);
end;


//========================================================================
//  AusUser
//
//========================================================================
sub AusUser()
local begin
  vTmp  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;

    RecBufClear(917);
    Blb.R.ID  # Cnvia($lb.ID->wpcustom);
    Blb.R.Typ # 'U';
    Blb.R.Name # Usr.Username;
    RekInsert(917,_recunlock,'MAN');
  end;
  Usr_data:RecReadThisUser();

  cRecList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);

end;


//========================================================================
//  AusGruppe
//
//========================================================================
sub AusGruppe()
local begin
  vTmp  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(801,0,_RecId,gSelected);
    gSelected # 0;

    RecBufClear(917);
    Blb.R.ID  # Cnvia($lb.ID->wpcustom);
    Blb.R.Typ # 'G';
    Blb.R.Name # Usr.Grp.Gruppenname;
    RekInsert(917,_recunlock,'MAN');
  end;

  cRecList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);

end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt                 : event;    // Ereignis
  aID                  : int;      // Datensatz ID oder Zeilennummer
) : logic;
begin

  Gv.int.01 # 42;
  if (Blb.R.NewYN) then Gv.int.01 # 41;
  Gv.int.02 # 42;
  if (Blb.R.EditYN) then Gv.int.02 # 41;
  Gv.int.03 # 42;
  if (Blb.R.DelYN) then Gv.int.03 # 41;

  Gv.int.04 # 41; // View

  RETURN(true);
end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : handle;   // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
  vErx  : int;
end;
begin

  vErx # -1;
  if (aItem=0) then RETURN true;
  if (aEvt:obj->wpDbRecID=0) then RETURN true;

  if (aButton=_WinMouseLeft | _WinMouseDouble) then begin
    if (aItem->wpname='clmNew') then begin
      vErx # RecRead(917,0, _recId|_recLock, aEvt:obj->wpDbRecId);
      Blb.R.NewYN # !Blb.R.NewYN;
    end;
    if (aItem->wpname='clmEdit') then begin
      vErx # RecRead(917,0, _recId|_recLock, aEvt:obj->wpDbRecId);
      Blb.R.EditYN # !Blb.R.EditYN;
    end;
    if (aItem->wpname='clmDel') then begin
      vErx # RecRead(917,0, _recId|_recLock, aEvt:obj->wpDbRecId);
      Blb.R.DelYN # !Blb.R.DelYN;
    end;

    if (vErx=_rOK) then begin
      RekReplace(917,_recunlock,'MAN');
      aEvt:Obj->winupdate(_WinUpdon);
    end;
  end;

  RETURN(true);
end;


//========================================================================