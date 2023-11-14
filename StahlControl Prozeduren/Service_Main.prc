@A+
//==== Business-Control ==================================================
//
//  Prozedur    Service_Main
//                    OHNE E_R_G
//  Info        Servicedaten können gespeichert und geladen werden
//
//
//  22.10.2003  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB SchreibeDatei2File(aDatei : int; aName : alpha);
//    SUB LiesFile2Datei(aName : alpha; aDatei : int; aUpdate : logic) : logic;
//    SUB SchreibeService();
//    SUB LeseService();
//    SUB EvtClicked(aEvt : event) : logic
//========================================================================
@I:Def_Global


define begin
  c_Version : 'SC-V240105'
  c_seperator : 255
end;

LOCAL begin
  vFile : int;
  vDialog : int;
  vA : alpha(254);
  vD : date;
  vF : float;
  vI : int;
  vS : word;
  vT : time;
  vL : logic;
end;


//========================================================================
//  SchreibeDatei2File
//
//========================================================================
sub SchreibeDatei2File(
  aDatei : int;
  aName : alpha;
);
local begin
  Erx     : int;
  vSub    : int;
  vFld    : int;
  vMaxSub : int;
  vMaxFld : int;
end;
begin

  vFile # FsiOpen(aName,_FsiCreate | _FsiAcsRW);
  vA # c_version+':'+AInt(aDatei)+Strchar(c_seperator);
  FsiWrite(vFile,vA);

  vMaxSub # 1;
  WHILE (Sbrinfo(aDatei,vMaxSub+1,_SbrExists)=1) do
    vMaxSub # vMaxSub + 1;


  Erx # RecRead(aDatei,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    FOR vSub # 1 LOOP vSub # vSub + 1 WHILE (vSub<=vMaxSub) do begin
      vMaxFld # Sbrinfo(aDatei, vSub, _SbrFldCount);
      FOR vFld # 1 LOOP vFld # vFld + 1 WHILE (vFld<=vMaxFld) do begin

        case FldInfo(aDatei,vSub,vFld,_FldType) of
          _TypeAlpha  : begin vA # FldAlpha(aDatei,vSub,vFld)+Strchar(c_seperator); FsiWrite(vFile,vA); end;
          _Typebyte   : begin vS # Fldword(aDatei,vSub,vFld); FsiWrite(vFile,vS); end;
          _Typedate   : begin vD # Flddate(aDatei,vSub,vFld); FsiWrite(vFile,vD); end;
          _TypeFloat  : begin vF # Fldfloat(aDatei,vSub,vFld); FsiWrite(vFile,vF); end;
          _Typeint    : begin vI # Fldint(aDatei,vSub,vFld);  FsiWrite(vFile,vI); end;
          _TypeLogic  : begin vL # Fldlogic(aDatei,vSub,vFld); FsiWrite(vFile,vL); end;
          _Typetime   : begin vT # Fldtime(aDatei,vSub,vFld);  FsiWrite(vFile,vT); end;
          _Typeword   : begin vS # Fldword(aDatei,vSub,vFld); FsiWrite(vFile,vS); end;
        end;
//        vA # strchar(c_seperator);
//        FsiWrite(aFile,vA);

      END;
   END;

//   vA # strchar(c_seperataor);
  // FsiWrite(aFile,vA);

   Erx # RecRead(aDatei,1,_RecNext);
  END;

  FsiClose(vFile);

end;


//========================================================================
//  LiesFile2Datei
//
//========================================================================
sub LiesFile2Datei(
  aName : alpha;
  aDatei : int;
  aUpdate : logic;
) : logic;
local begin
  Erx     : int;
  vSub    : int;
  vFld    : int;
  vMaxSub : int;
  vMaxFld : int;
end;
begin
  vFile # FsiOpen(aName,_Fsistdread | _fsidenynone);
  FsiMark(vFile,c_seperator);
  fsiSeek(vFile,0);
  FsiRead(vFile,vA);
  if (vA<>c_version+':'+AInt(aDatei)) then begin
      WindialogBox(gFrmMain,'Servicedaten','Falsche Version!',_WinIcoerror,_WinDialogokcancel,0)
    FsiClose(vFile);
    RETURN false;
  end;

  vMaxSub # 1;
  WHILE (Sbrinfo(aDatei,vMaxSub+1,_SbrExists)=1) do
    vMaxSub # vMaxSub + 1;

  WHILE (Fsiseek(vFile)<Fsisize(vFile)) do begin

    FOR vSub # 1 LOOP vSub # vSub + 1 WHILE (vSub<=vMaxSub) do begin
      vMaxFld # Sbrinfo(aDatei, vSub, _SbrFldCount);
      FOR vFld # 1 LOOP vFld # vFld + 1 WHILE (vFld<=vMaxFld) do begin
        case FldInfo(aDatei,vSub,vFld,_FldType) of
          _TypeAlpha  : begin FsiRead(vFile,vA); FldDef(aDatei,vsub,vFld,vA); end;
          _Typebyte   : begin FsiRead(vFile,vS); FldDef(aDatei,vsub,vFld,vS); end;
          _Typedate   : begin FsiRead(vFile,vD); FldDef(aDatei,vsub,vFld,vD); end;
          _TypeFloat  : begin FsiRead(vFile,vF); FldDef(aDatei,vsub,vFld,vF); end;
          _Typeint    : begin FsiRead(vFile,vI); FldDef(aDatei,vsub,vFld,vI); end;
          _TypeLogic  : begin FsiRead(vFile,vL); FldDef(aDatei,vsub,vFld,vL); end;
          _Typetime   : begin FsiRead(vFile,vT); FldDef(aDatei,vsub,vFld,vT); end;
          _Typeword   : begin FsiRead(vFile,vS); FldDef(aDatei,vsub,vFld,vS); end;
        end;
      END;
    END;

    Erx # RecRead(aDatei,1,_RecTest);
    if (Erx<=_rLocked) then begin
      if (aUpdate) then begin
        RekDelete(aDatei,0,'MAN');
        RekInsert(aDatei,0,'MAN');
      end;
      end
    else begin
      RekInsert(aDatei,0,'MAN');
    end;

  END;

  FsiClose(vFile);

  RETURN true;
end;


//========================================================================
//  SchreibeService
//
//========================================================================
sub SchreibeService();

local begin
  vName : alpha;
end

begin

  vName # $ed.Path->wpcaption+'\';
  FsiDelete(vName+'SD901.DAT');
  FsiDelete(vName+'SD902.DAT');
  FsiDelete(vName+'SD903.DAT');
  FsiDelete(vName+'SD910.DAT');
  FsiDelete(vName+'SD912.DAT');

  if ($CB.S901->wpCheckState=_WinStateChkChecked) then begin
    SchreibeDatei2File(901,vName+'SD901.DAT');
  end;
  if ($CB.S902->wpCheckState=_WinStateChkChecked) then begin
    SchreibeDatei2File(902,vName+'SD902.DAT');
  end;
  if ($CB.S903->wpCheckState=_WinStateChkChecked) then begin
    SchreibeDatei2File(903,vName+'SD903.DAT');
  end;
  if ($CB.S910->wpCheckState=_WinStateChkChecked) then begin
    SchreibeDatei2File(910,vName+'SD910.DAT');
  end;
  if ($CB.S912->wpCheckState=_WinStateChkChecked) then begin
    SchreibeDatei2File(912,vName+'SD912.DAT');
  end;

  WindialogBox(gFrmMain,'Servicedaten','Servicedaten wurden gespeichert!',_WinIcoInformation,_WinDialogOk,0)

end;


//========================================================================
//  LeseService
//
//========================================================================
sub LeseService();

local begin
  vName : alpha;
end

begin

  vName # $ed.Path->wpcaption+'\';

  vFile # fsiopen(vName+'SD901.DAT',_FsiStdRead);
  if (vFile>0) then begin
    Fsiclose(vFile);
    LiesFile2Datei(vName+'SD901.DAT',901,($CB.U901->wpCheckState=_WinStateChkChecked));
  end;

  vFile # fsiopen(vName+'SD902.DAT',_FsiStdRead);
  if (vFile>0) then begin
    Fsiclose(vFile);
    LiesFile2Datei(vName+'SD902.DAT',902,($CB.U902->wpCheckState=_WinStateChkChecked));
  end;

  vFile # fsiopen(vName+'SD903.DAT',_FsiStdRead);
  if (vFile>0) then begin
    Fsiclose(vFile);
    LiesFile2Datei(vName+'SD903.DAT',903,($CB.U903->wpCheckState=_WinStateChkChecked));
  end;

  vFile # fsiopen(vName+'SD910.DAT',_FsiStdRead);
  if (vFile>0) then begin
    Fsiclose(vFile);
    LiesFile2Datei(vName+'SD910.DAT',910,($CB.U910->wpCheckState=_WinStateChkChecked));
  end;

  vFile # fsiopen(vName+'SD912.DAT',_FsiStdRead);
  if (vFile>0) then begin
    Fsiclose(vFile);
    LiesFile2Datei(vName+'SD912.DAT',912,($CB.U912->wpCheckState=_WinStateChkChecked));
  end;

  WindialogBox(gFrmMain,'Servicedaten','Servicedaten wurden eingelesen!',_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin
  case (aEvt:Obj->wpName) of
    'bt.Sichern'  :   SchreibeService();
    'bt.Lesen'    :   LeseService();
  end;

end;

//========================================================================

MAIN begin
  vDialog # WinOpen('Servicedaten',_WinOpenDialog);
  $ed.Path->wpcaption # 'c:';
  $CB.S901->wpCheckState # _WinStateChkChecked;
  $CB.S902->wpCheckState # _WinStateChkChecked;
  $CB.S903->wpCheckState # _WinStateChkChecked;
  $CB.S910->wpCheckState # _WinStateChkChecked;
  $CB.S912->wpCheckState # _WinStateChkChecked;
  WinDialogRun(vDialog,_WinDialogCenter);
  WinClose(vDialog);
end;

//========================================================================