@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Storage
//                      OHNE E_R_G
//  Info
//
//
//  28.08.2006  AI  Erstellung der Prozedur
//
//  Subprozeduren
//========================================================================
@I:Def_Global

declare FmtCalTime(aTime : caltime;) : alpha;
declare FindName(aDirName : alpha; aName : alpha) : alpha;

//========================================================================
//  FmtCalTime - caltime in formatierten Datums-/Zeitwert
//              umwandeln
//========================================================================
sub FmtCalTime(
  aTime           : caltime   // umzuwandelnder Kalenderwert
) : alpha
begin
  RETURN CnvAI(aTime->vpYear   , _FmtNumNoGroup, 0, 4) + '-' +
         CnvAI(aTime->vpMonth  , _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + '-' +
         CnvAI(aTime->vpDay    , _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + ' ' +
         CnvAI(aTime->vpHours  , _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + ':' +
         CnvAI(aTime->vpMinutes, _FmtNumNoGroup | _FmtNumLeadZero, 0, 2) + ':' +
         CnvAI(aTime->vpSeconds, _FmtNumNoGroup | _FmtNumLeadZero, 0, 2);
end;


sub RekSearch(
  aObj        : int;
  aName       : alpha;
) : logic;
local begin
  vObj : int;
  vHdl : int;
end;
begin

  if (aObj=0) then RETURN false;
/***
  if (StrFind(StrCnv(aObj->wpname,_StrUpper),'CLM',0)<>0) then begin
    if (StrFind(StrCnv(aObj->wpname,_StrUpper),'BREITE',0)<>0) and (aObj->wpcustom='') then begin
      vHdl # Wininfo(aObj,_WinParent);
      debug(aObj->wpname + ' in '+vHdl->wpname);
    end;
  end;
***/

  if (StrFind(StrCnv(aObj->wpname,_StrUpper),aName,0)<>0) then begin
//debug('found in :'+aObj->wpname);
    RETURN true;
  end;


  vObj # aObj->WinInfo(_Winfirst,0);
  WHILE (vObj<>0) do begin
    if (RekSearch(vObj, aName)) then RETURN true;
    aObj # vobj->WinInfo(_WinNext,0);
    vobj # aObj;
  END;

  RETURN false;

end;


//========================================================================
//  FindName
//
//========================================================================
/*
    return 'Dialog';
    return 'Menu';
    return 'PrintForm';
    return 'PrintFormList';
    return 'PrintDocument';
    return 'PrintDocTable';
    return 'Picture';
    return 'MetaPicture';
*/
sub FindName(
  aDirName        : alpha;  // Verzeichnisname
  aName           : alpha;
) : alpha;
local begin
  vDirHdl       : int;    // Verzeichnis-Deskriptor
  vObjName      : alpha;  // Objektname
  vObjHdl       : int;
  vHdl          : int;
  vC            : int;
  vFound        : logic;
end;
begin

  WinEvtProcessSet(_WinEvtAll,false);

  // Öffnen des Verzeichnisses
  vDirHdl # StoDirOpen(0, aDirName);

  if (vDirHdl != 0) then begin
    // Ersten Eintrag lesen
    vObjName # StoDirRead(vDirHdl, _StoFirst);

    // Solange Einträge vorhanden sind
    WHILE (vObjName != '') and (vC<300) do begin
      inc(vC);
//      vObjHdl # StoOpen(vDirHdl, vObjName);
//      vObjHdl->StoClose();
//WinDialog(vObjName,

      vHdl # WinOpen(vObjName);
      if (vHdl<=0) then begin
        debug('error: '+vObjName+'   '+cnvai(vHdl));
//        vHdl # WinOpen(vObjName);
        end
      else begin
        vFound # RekSearch(vHdl,aName);
        vHdl->winClose();
        if (vFound) then RETURN vObjName;
      end;

      // Nächsten Verzeichnis-Eintrag lesen
      vObjName # StoDirRead(vDirHdl, _StoNext);
    END;

    // Verzeichnis schliessen
    vDirHdl->StoClose();
  end;

  WinEvtProcessSet(_WinEvtAll,true);

  RETURN '';
end;

//========================================================================
//
//
//========================================================================
main
local begin
  vA : alpha;
end;
begin
//  vA # FindName('Dialog','LNGE');
  vA # FindName('Dialog','HHE');

  WindialogBox(gFrmMain,'Dialoge', vA, 0,0,0);
end;
