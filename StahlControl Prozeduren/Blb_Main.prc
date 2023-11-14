@A+
//===== Business-Control =================================================
//
//  Prozedur    Blb_Main
//                    OHNE E_R_G
//  Info
//
//
//  14.04.2014  AH  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//  SUB EvtInit(
//  SUB EvtTerm
//  SUB EvtMenuCommand(
//  SUB AusRechte()
//
//========================================================================
@I:def_Global

define begin
  cDBA        : _BinDba3
  cTitle      : 'Adress-Dokumente'
  cFile       : 0
  cMenuName   : ''//Std.Bearbeiten'
  cPrefix     : 'blb_'
  cZList      : 0
  cKey        : 0
  cMdiVar     : gMDIPara
end;

//========================================================================
//  EvtInit
//
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;


  vHdl # Winsearch(aEvt:obj, 'tvStrukturen');

  if (gDBAConnect<>0) then begin
//    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then begin
//      gDBAConnect # 3;
      Lib_Blob:ShowBinDir(vHdl, 0, 'Templates', cDBA);
  end;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtTerm
//
//========================================================================
sub EvtTerm(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  if (gDBAConnect<>0) then begin
    try begin
      ErrTryIgnore(_ErrValueInvalid);
      DbaDisConnect(gDBACOnnect);
    end;
    gDBAConnect # 0;
  end;

  RETURN App_Main:EvtTerm(aEvt);
end;


//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüpunkt / Toolbar-Button
) : logic;
local begin
  vHdl  : int;
  vA    : alpha;
  vPath : alpha(4000);
end;
begin

  vHdl  # aEvt:Obj->wpCurrentInt;
  if (vHdl=0) then RETURN true;
  vPath # vHdl->wpHelpTip;

  case (aMenuItem->wpname) of

    'ktx.New' : begin
      if (Dlg_Standard:Standard(Translate('Name'), var vA)=false) then RETURN true;
      Lib_Blob:CreateDir(vPath, vA, cDBA, vHdl);
    end;


    'ktx.Delete' : begin
      if (Msg(917002,'', _WinIcoQuestion, _WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      Lib_blob:DeleteDir(vPath, cDBa, aEvt:obj, vHdl);
    end;


    'ktx.Rename' : begin
      vA # FsiSplitName(vPath, _FsiNameNE);
      if (Dlg_Standard:Standard(Translate('Name'), var vA)=false) then RETURN true;
      Lib_Blob:RenameDir(vPath, vA, cDBA, vHdl);
    end;


    'ktx.Rechte' : begin
      RecBufClear(917);
      Gv.Int.20   # vHdl->wpid;
      Gv.Alpha.01 # vPath;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Blb.R.Verwaltung',here+':AusRechte');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

  RETURN(true);
end;


//========================================================================
//  AusRechte
//
//========================================================================
sub AusRechte()
local begin
  Erx   : int;
  vPath : alpha(4000);
  vName : alpha(4000);
  vHdl  : int;
end;
begin
  gSelected # 0;

  vHdl # Winsearch(w_MDI, 'tvStrukturen');
  if (vHdl=0) then RETURN;
  vHdl # vHdl->wpCurrentint;
  if (vHdl=0) then RETURN;

  vPath # vHdl->wpHelpTip;
  vName # Str_Token(vPath,'Templates\Adressen\',2);

  if (Msg(917003,'',_WinIcoQuestion, _WinDialogYesNo, 2)<>_Winidyes) then RETURN;

  // ADressen loopen...
  FOR Erx # RecRead(100,1,_recFirst)
  LOOP Erx # RecRead(100,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Blob:ExistsDir('Adresse\'+aint(Adr.Nummer)+'\'+vName, cDBA)>0) then begin
      Lib_Blob:CopyRechteDir(vPath, 'Adresse\'+aint(Adr.Nummer)+'\'+vName, cDBA);
    end;
  END;

  Msg(999998,'',0,0,0);
end;

//========================================================================