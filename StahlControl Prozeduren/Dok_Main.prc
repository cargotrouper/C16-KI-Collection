@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dok_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB RefreshIfm(optaName : alpha)
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtClose(aEvt : Event) : logic
//    SUB RecInit()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB Auswahl(aBereich : alpha)
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtKeyItem(aEvt : event; aKey : int; arecID : int) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHittest : int; aItem : int; aID : int) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtLstSelect(aEvt : event; aRecId : int) : logic
//    SUB EvtLstDataInit(aEvt : event; arecid : int);
//
//========================================================================

@I:Def_Global


declare Auswahl(aBereich : alpha;)


define begin
  cTitle :    'Dokumente'
  cFile :     915
  cMenuName : 'Frm.Bearbeiten'
  cPrefix :   'Dok'
  cZList :    $ZL.Dokumente
  cKey :      1
end;


//========================================================================
//  EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(
	aEvt         : event     // Ereignis
) : logic
begin
  If ($ZL.Dokumente->wpDbFilter = 0) then Auswahl(gDokTyp)
	return (App_Main:EvtMdiActivate(aEvt));
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin
end;


//========================================================================
// EvtInit
//
//========================================================================
sub EvtInit(
  aEvt : event;
) : logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

//  If ($ZL.Dokumente->wpDbFilter = 0) then Auswahl(gDokTyp)
//  $Nb.Main->wpCurrent # 'NB.List'

  App_Main:EvtInit(aEvt);

end;


//========================================================================
// EvtClose
//          Fenster schliessen
//========================================================================
sub EvtClose(
  aEvt : Event;
) : logic
begin
  If $ZL.Dokumente->wpDbFilter <> 0 then begin
    RecFilterDestroy($ZL.Dokumente->wpDbFilter);
    $ZL.Dokumente->wpDbFilter # 0;
  end;
  RETURN true;
end;


//========================================================================
//  RecInit
//          Datensatz wurde geändert
//========================================================================
sub RecInit()
local begin
  vPath : alpha;
end;
begin
  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;
  $pjDokument->wpCaption  # '*'+vPath+ "Dok.Kürzel" +'\'+CnvAI(Dok.Nummer,_FmtInternal)+'.Job';
  $pjDokument->ppRuler    # _PrtRulerNone;
  $pjDokument->ppPageZoom # _PrtPageZoomPage;
end;


//========================================================================
//  Refreschmode
//
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
LOCAL begin
  v_X         : int;
  v_text      : int;
  v_frame     : int;
  v_Button    : int;
  v_MenuItem  : int;
end;
begin
  v_Button # gMdi->WinSearch('Save');
  if (v_Button <> 0) then
    v_Button->wpDisabled # true;

  v_Button # gMdi->WinSearch('Cancel');
  if (v_Button <> 0) then
    v_Button->wpDisabled # !(
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Mode=c_ModeView)));

  v_Button # gMdi->WinSearch('New');
  if (v_Button <> 0) then
    v_Button->wpDisabled # true;

  v_Button # gMdi->WinSearch('Mark');
  if (v_Button <> 0) then
    v_Button->wpDisabled # true;

  v_Button # gMdi->WinSearch('RecPrev');
  if (v_Button <> 0) then
    v_Button->wpDisabled # !(
      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_Button # gMdi->WinSearch('RecNext');
  if (v_Button <> 0) then
    v_Button->wpDisabled # !(
      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_Button # gMdi->WinSearch('Edit');
  if (v_Button <> 0) then
    v_Button->wpDisabled # y;//!(
//      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_Button # gMdi->WinSearch('Search');
  if (v_Button <> 0) then
    v_Button->wpDisabled # true;

  v_Button # gMdi->WinSearch('Delete');
  if (v_Button <> 0) then
    v_Button->wpDisabled # true;


  // Menüleiste setzen
  v_MenuItem # gMenu->WinSearch('Mnu.Save');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # true;

  v_MenuItem # gMenu->WinSearch('Mnu.Cancel');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Mode=c_ModeView) or (Mode=c_ModeList)));

  v_MenuItem # gMenu->WinSearch('Mnu.New');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # true;

  v_MenuItem # gMenu->WinSearch('Mnu.Edit');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # true;

  v_MenuItem # gMenu->WinSearch('Mnu.Mark');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # true;

  v_MenuItem # gMenu->WinSearch('Mnu.RecPrev');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpdisabled # !(
      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_MenuItem # gMenu->WinSearch('Mnu.RecNext');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_MenuItem # gMenu->WinSearch('Mnu.RecLast');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_MenuItem # gMenu->WinSearch('Mnu.RecFirst');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeList) or (Mode=c_ModeView)));

  v_MenuItem # gMenu->WinSearch('Mnu.Search');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # true;

  v_MenuItem # gMenu->WinSearch('Mnu.Delete');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # true;


  v_MenuItem # gMenu->WinSearch('Mnu.Auswahl');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Mode=c_ModeView)));

  v_MenuItem # gMenu->WinSearch('Mnu.NextPage');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Mode=c_ModeView)));

  v_MenuItem # gMenu->WinSearch('Mnu.PrevPage');
  if (v_MenuItem <> 0) then
    v_MenuItem->wpDisabled # !(
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Mode=c_ModeView)));


end;


//========================================================================
//  Auswahl
//
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  vA      : alpha;
  vA2     : alpha;
  vText   : alpha;
  vKurz   : alpha;
  vFilter : int;
  vFile   : int;
end;
begin

  vText # '';
  case StrCnv(gDokTyp,_StrUpper) of
    'ANF' : begin
      Dlg_Standard:Standard('Anfragenummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 540;
      vKurz # 'ANF';
    end;
    'MWZ' : begin
      Dlg_Standard:Standard('Materialnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 200;
      vKurz # 'MWZ';
    end;
     'LFSWZ' : begin
      Dlg_Standard:Standard('Lieferscheinnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 440;
      vKurz # 'LFSWZ';
    end;

    'ANG' : begin
      Dlg_Standard:Standard('Angebotsnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 400;
      vKurz # 'ANG';
    end;

    'AUFBE' : begin
      Dlg_Standard:Standard('Auftragsnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 400;
      vKurz # 'AB';
    end;

    'LFS' : begin
      Dlg_Standard:Standard('Lieferscheinnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 440;
      vKurz # 'LFS';
    end;

    'RECH' : begin
      Dlg_Standard:Standard('Rechnungsnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 450;
      vKurz # 'RE';
    end;

    'BEST' : begin
      Dlg_Standard:Standard('Bestellnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
//        vText # CnvAI(CnvIA(vText),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 500;
      vKurz # 'BEST';
    end;

    'BESTH' : begin
      Dlg_Standard:Standard('Bestellnummer:',var vA);
      if (vA<>'') then
        vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
//      vText # CnvAI(CnvIA(vText),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      vFile # 190;
      vKurz # 'BESTH';
    end;

    'BAG' : begin
      Dlg_Standard:Standard('Betriebsauftragsnummer:',var vA);
      If (vA <> '') then begin
        Dlg_Standard:Standard('ID:',var vA2);
        if (vA2<>'') then
          vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8)+CnvAI(CnvIA(vA2),_FmtNumNoGroup | _FmtNumLeadZero,0,8)
        else
          vText # CnvAI(CnvIA(vA),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;
      vFile # 701;
      vKurz # 'BAG';
    end;

    otherwise begin
      //Formulartyp unbekannt?
      Msg(915001,StrCnv(gDokTyp,_StrUpper),_WinIcoError,_WinDialogOkCancel,1);
      RETURN;
    end
  end;//case

  If ($ZL.Dokumente->wpDbFilter <> 0) then begin
    RecFilterDestroy($ZL.Dokumente->wpDbFilter);
    $ZL.Dokumente->wpDbFilter # 0;
  end;

  vFilter # RecFilterCreate(915,1);
  vFilter->RecFilterAdd(1,_FltAnd,_FltEq,vFile);
  vFilter->RecFilterAdd(2,_FltAnd,_FltEq,vKurz);
  if (CnvIA(vText)<>0) then
    vFilter->RecFilterAdd(3,_FltAnd,_FltScan,vText);

  Dok.Bereich       # vFile;
  "Dok.Kürzel"      # vKurz;
  Dok.FormularName  # vText;
  RecRead(915,1,0);

  $ZL.Dokumente->wpDbkeyno # 1;   // 26.05.2020
  $ZL.Dokumente->wpDbFilter # vFilter;
  $ZL.Dokumente->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

  RETURN;
end;


//========================================================================
//  MenuCommand
//              Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vMode : alpha;
  vA    : alpha(250);
  vParent : int;
  vTmp  : int;
  vHdl  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
    'Listen' : begin
//      Lfm_Ausgabe:Auswahl('Dokumente');
    end;
    'Mnu.Auswahl' : begin
      vHdl # WinFocusGet();
      if vHdl<>0 then begin
/*
        case vHdl->wpname of
          'edFrm.Bereich'   : Auswahl('File');
          'edFrm.Prozedur'  : Auswahl('Prozedur');
          'edFrm.Drucker'   : Auswahl('Drucker');
        end;
*/
      end;
    end;
  end;

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vParent : int;
end;
begin
  case (aEvt:Obj->wpName) of
    'Edit' : begin
//debug('TATA '+Dok.Formularname);
      if (RecRead(915,0,0,gZLList->wpdbrecid)<>_rOK) then RETURN false;
      Lib_Dokumente:ShowDok(Dok.Nummer);
    end;
  end;
end;


//========================================================================
//  EvtKeyItem
//              Taste gedrückt
//========================================================================
sub EvtKeyItem (
  aEvt    : event;
  aKey    : int;
  arecID  : int;
) : logic
begin
  if (aKey=_WinKeyReturn) then begin
    if (RecRead(915,0,0,gZLList->wpdbrecid)<>_rOK) then RETURN false;
    Lib_Dokumente:ShowDok(Dok.Nummer);
    RETURN false;
  end;
  RETURn true;
end;


//========================================================================
//  EvtmouseItem
//              Mousebutton gedrückt
//========================================================================
sub EvtMouseItem (
  aEvt      : event;
  aButton   : int;
  aHittest  : int;
  aItem     : int;
  aID       : int;
) : logic
begin
  If (aButton = (_WinMouseLeft | _WinMouseDouble)) and (aHitTest = _WinHitLstView) then begin
//debug('TATA '+Dok.Formularname);
    if (RecRead(915,0,0,gZLList->wpdbrecid)<>_rOK) then RETURN false;
//debug('TATA '+Dok.Formularname);
    Lib_Dokumente:ShowDok(Dok.Nummer);
//debug('TATA '+Dok.Formularname);
  end;

  if (abutton = _winmouseright)  and (ahittest = _winlstheader) then
  begin
   if ($ZL.Dokumente -> wpdbfilter <> 0) then begin
      recfilterdestroy($ZL.Dokumente -> wpdbfilter );
      $ZL.Dokumente -> wpdbfilter  # 0;
    end;
  end;
end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin
  If aPage->wpName = 'NB.List' then return true

//debug('TATA '+Dok.Formularname);
  if (RecRead(915,0,0,gZLList->wpdbrecid)<>_rOK) then RETURN false;
//debug('TATA '+Dok.Formularname);
  Lib_Dokumente:ShowDok(Dok.Nummer);
//debug('TATA '+Dok.Formularname);
  Return False
end;


//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin
/*
  if  (aEvt:Obj->wpname='edFrm.Bereich')  or
      (aEvt:Obj->wpname='edFrm.Prozedur') or
      (aEvt:Obj->wpName='edFrm.Drucker')  then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);
*/
end;


//========================================================================
//  EvtLstSelect
//                Datensatz in ZL gewählt
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecId                : int;          // REcord-ID) : logic
) : logic
local begin
  vPath : alpha;
end;
begin
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
                   );
begin
  Refreshmode();
end;


//========================================================================