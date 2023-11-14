@A+
//===== Business-Control =================================================
//
//  Prozedur    Mdi_Cockpit_BAK   ALT ALT ALT
//
//  Info
//
//
//  26.11.2013  AH  Erstellung der Prozedur
//  22.10.2015  AH  Drag&Drop für Wiedervorlagen von Recs
//
//  Subprozeduren
//
//
//========================================================================
@I:Def_Global

define begin
//  cWidth  : 500
  cWidth  : (gMdiNotifier->wparearight -gMdiNotifier->wparealeft)  / 2

  cIconDelete   : 174
//  cIconTermin   : 56
  cIconNew      : 98


  cTypDL        : 100
  cTypEventOld  : 110
  cTypEventNew  : 111
  cTypTempOld   : 120
  cTypTempNew   : 121

  cTypGauge     : 300

  cTypDLClose   : 1
  cTypDLOpen    : 2
  cTypGauClose  : 3
  cTypGauOpen   : 4
end;

//========================================================================
//========================================================================
sub SetCustom(
  aGB   : int;
  aTyp  : int;
  aName : alpha;
  aExp  : logic);
local begin
end;
begin
  if (aExp) then
    aGB->wpcustom # aint(aTyp)+'|Y|'+aName
  else
    aGB->wpcustom # aint(aTyp)+'|N|'+aName;
end;


//========================================================================
//========================================================================
sub GetCustom(
  aGB       : int;
  var aTyp  : int;
  var aName : alpha;
  var aExp  : logic);
local begin
end;
begin
  aTyp  # cnvia(Str_Token(aGB->wpcustom,'|',1));
  aExp  # Str_Token(aGB->wpcustom,'|',2)='Y';
  aName # Str_Token(aGB->wpcustom,'|',3);
end;


//========================================================================
//========================================================================
sub FindGroup(
  aList       : int;
  aGroup      : alpha;
  opt aTyp    : int;
  opt aCreate : logic) : int;
local begin
  vItem   : int;
end;
begin

  vItem # aList->CteRead(_CteFirst | _CteSearch, 0, aGroup+'|');
  if (vItem<>0) then begin
    if (vItem->spid=cTypDLClose) or
      (vItem->spid=cTypGauClose) then vItem->spId # vItem->spID + 1;
    RETURN vItem;
  end;
  if (aCreate=false) then RETURN 0;

  // neue Gruppe erzeugen
  vItem # CteInsertItem(aList, aGroup+'|', aTyp, '');

  if (vItem>0) then RETURN vItem;
  RETURN 0;
end;

//========================================================================
sub FindDL(
  aName : alpha) : int;
local begin
  vI    : int;
  vHdl  : int;
end;
begin
  FOR vI # 1 loop inc(vI) while (vI<50) do begin
    vHdl # Winsearch(gMdiNotifier, 'bt.Zone'+aint(vI));
    if (vHdl<>0) then begin
      if (vHdl->wpcustom=aName) then begin
        vHdl # Winsearch(gMdiNotifier, 'dl.Zone'+aint(vI));
        RETURN vHdl;
      end;
    end;
  END;

  RETURN 0;
end;


//========================================================================
//========================================================================
sub CopyEvtProc(
  aEvt  : int;
  aSrc  : int;
  aDest : int);
begin
  aDest->WinEvtProcNameSet(aEvt, aSrc->WinEvtProcNameGet(aEvt));
end;

//========================================================================
sub CopyGroupbox(
  aMDI    : int;
  aSName  : alpha;
  aDName  : alpha;
  aPar    : int) : int;
local begin
  vSrc    : int;
  vGB     : int;
end;
begin

  vSrc # WinSearch(aMDI, aSName);
  vGB  # WinCreate(_WinTypeGroupbox, aDName, '', aPar);
vGB->wpVisible        # false;
vGB->wpAutoUpdate     # false;

  vGB->wpcustom         # vSrc->wpcustom;
  vGB->wpStyleBorder    # vSrc->wpStyleBorder;
  vGB->wparea           # vSrc->wparea;
  vGB->wpGrouping       # vSrc->wpGrouping;
  vGB->wpAlignGrouping  # vSrc->wpAlignGrouping;
  vGB->wpColFg          # vSrc->wpColFg;
  vGB->wpColBkg         # vSrc->wpColBkg;
  vGB->wpFrame          # vSrc->wpFrame;
  vGB->wpOleDropMode    # vSrc->wpOleDropMode;
  CopyEvtProc(_WinEvtDragInit, vSrc, vGB);
  CopyEvtProc(_WinEvtDragTerm, vSrc, vGB);
  CopyEvtProc(_WinEvtDropEnter, vSrc, vGB);
  CopyEvtProc(_WinEvtDrop, vSrc, vGB);
  RETURN vGB;
end;


//========================================================================
sub CopyButton(
  aMDI    : int;
  aSName  : alpha;
  aDName  : alpha;
  aPar    : int;
  aCap    : alpha;
  aExp    : logic) : int;
local begin
  vSrc    : int;
  vBT     : int;
end;
begin
  vSrc # WinSearch(aMDI, aSName);
  vBT  # Wincreate(_WinTypeButton, aDName, aCap, aPar);
vBT->wpVisible        # false;
vBT->wpAutoUpdate     # false;

  vBT->wpcustom         # aCap;
  vBT->wparea           # vSrc->wparea;
  vBT->wpImageTile      # vSrc->wpImageTile;

  if (aExp) then
    vBT->wpImageTile # _WinImgPageNext
  else
    vBT->wpImageTile # _WinImgNext;

  vBT->wpColFg          # vSrc->wpColFg;
  vBT->wpColBkg         # vSrc->wpColBkg;
  vBT->wpStyleBorder    # vSrc->wpStyleBorder;
  vBT->wpStyleButton    # vSrc->wpStyleButton;
  vBT->wpfont           # vSrc->wpFont;
  vBT->wpImageOption    # vSrc->wpImageOption;
  vBT->wpJustifyView    # vSrc->wpJustifyView;
  vBT->wpAlignGrouping  # vSrc->wpAlignGrouping;
  CopyEvtProc(_WinEvtClicked, vSrc, vBT);
  RETURN vBT;
end;

//========================================================================
sub CopyLabel(
  aMDI    : int;
  aSName  : alpha;
  aDName  : alpha;
  aPar    : int;
  aCap    : alpha) : int;
local begin
  vSrc    : int;
  vHdl    : int;
end;
begin
  vSrc # WinSearch(aMDI, aSName);
  vHdl # Wincreate(_WinTypeLabel, aDName, aCap, aPar);
vHdl->wpVisible        # false;
vHdl->wpAutoUpdate     # false;

  vHdl->wpStyleBorder     # vSrc->wpStyleBorder;
  vHdl->wpcaption         # aCap;

  vHdl->wparea            # vSrc->wparea;
  vHdl->wpColFg           # vSrc->wpColFg;
  vHdl->wpColBkg          # vSrc->wpColBkg;
  vHdl->wpfont            # vSrc->wpFont;
  vHdl->wpJustify         # vSrc->wpJustify;
  vHdl->wpJustifyVert     # vSrc->wpJustifyVert;
  vHdl->wpAlignGrouping   # vSrc->wpAlignGrouping;

  RETURN vHdl;
end;

//========================================================================
//========================================================================
sub CopyPic(
  aMDI    : int;
  aSName  : alpha;
  aDName  : alpha;
  aPar    : int) : int;
local begin
  vSrc    : int;
  vHdl    : int;
end;
begin

  vSrc # WinSearch(aMDI, aSName);
  vHdl # WinCreate(_WinTypePicture, aDName, '', aPar);
//vGB->wpVisible        # false;
//vGB->wpAutoUpdate     # false;
  vHdl->wpStyleBorder   # vSrc->wpStyleBorder;
  vHdl->wpcaption       # vSrc->wpcaption;
  vHdl->wpcustom        # vSrc->wpcustom;
  vHdl->wparea          # vSrc->wparea;
  vHdl->wpColFg         # vSrc->wpColFg;
  vHdl->wpColBkg        # vSrc->wpColBkg;
  vHdl->wpModeEffect    # vSrc->wpModeEffect;
  vHdl->wpModeDraw      # vSrc->wpModeDraw;
//  vHdl->wp # vSrc->wp
  RETURN vHdl;
end;


//========================================================================
//========================================================================
sub CreateZone_Gauge(
  aZone : int;
  aWert : int;
  aCap  : alpha;
  aSB   : int;
  aMDI  : int;
  aExp  : logic) : int;
local begin
  vGB   : int;
  vBT   : int;
  vGau  : int;
  vNee  : int;
  vLB   : int;
end;
begin

  vGB   # CopyGroupBox(aMDI, 'gb.Gauge0', 'gb.Zone'+aint(aZone), aSB);
  SetCustom(vGB, cTypGauge, aCap, aExp);

  vBT   # CopyButton(aMDI, 'bt.Gauge0', 'gb.Zone'+aint(aZone), vGB, aCap, true);
aZone # 1;
  vGau  # CopyPic(aMDI, 'pic.Gauge0', 'pic.Gauge'+aint(aZone), vGB);
  vNee  # CopyPic(aMDI, 'pic.Needle0', 'pic.Needle'+aint(aZone), vGau);
  vNee->wpRotation # aWert;


  vLB   # CopyLabel(aMDI, 'lb.Gauge0', 'lb.Gauge'+aint(aZone), vGB, '45000€ in 2013');

  RETURN vGau;
end;


//========================================================================
sub AddGaugeToZoneList(
  aList   : int;
  aGroup  : alpha;
  aName   : alpha;
  aWert   : int;
  aNew    : logic) : logic;
local begin
  vID     : int;
  vItem   : int;
  vTyp    : alpha;
end;
begin

  if (aNew) then vID # cTypGauOpen
  else vID # cTypGauClose;
  FindGroup(aList, aGroup, vID, y);

  vID # cTypGauge;

  vItem # CteOpen(_cteitem);
  vItem->spname   # aGroup+'|'+aName;
  vItem->spcustom # 'GAU|'+aint(aWert);
  vItem->spID     # vID;

  RETURN (aList->CteInsert(vItem));

end;

//========================================================================
//========================================================================
sub TestGauge(
  aZL   : int) : int;
local begin
  vSB   : int;
  vGB   : int;
  vBT   : int;
  vGau  : int;
  vNee  : int;

  vItem : int;
end;
begin
  AddGaugeToZoneList(aZL, 'Umsatz 2013', 'tralala', 100, y);
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
//========================================================================



//========================================================================
//========================================================================
sub ReadEvent(aRecID : int) : logic;
begin
  RETURN (RecRead( 989, 0, _recId, aRecID ) <= _rLocked );
end;

//========================================================================
//========================================================================
sub GetGroupFromItem(aItem : int) : alpha;
begin
  RETURN Str_Token(aItem->spName,'|',1);
end;

//========================================================================
//========================================================================
sub GetEventIDFromItem(aItem : int) : int;
begin
  RETURN (cnvia(Str_Token(aItem->spName,'|',3)));
end;

//========================================================================
//========================================================================
sub GetDateiFromItem(aItem : int) : int;
begin
  RETURN (cnvia(Str_Token(aItem->spCustom,'|',1)));
end;

//========================================================================
//========================================================================
sub GetEventType(
  aName : alpha;
  aPrio : int) : alpha;
begin
  if (StrCut(aName,1,4)='TAPI') then RETURN 'TAPI';
  if (StrCut(aName,1,7)='122>800') and (aPrio>0) then RETURN 'PROJEKTPOS*';
  if (StrCut(aName,1,7)='122>800') then RETURN 'PROJEKTPOS';
  if (StrCut(aName,1,3)='980') then RETURN 'EVENT';
  RETURN aName;
end;

//========================================================================
//========================================================================
sub GetGroupname(
  aTyp            : alpha;
  var aGroupname  : alpha) : logic;
begin

  aGroupname # '';
  if (aTyp='TAPI') then         aGroupname # ' Telefon';
  else if (aTyp='PROJEKTPOS') then   aGroupname # ' Ticket';
  else if (aTyp='PROJEKTPOS*') then  aGroupname # ' dringendes Ticket';
  else if (aTyp='EVENT') then        aGroupname # ' Aufgabe';
  else if (StrCut(aTyp,4,1)='/') and (StrCut(aTyp,1,3)>='001') and (StrCut(aTyp,1,3)<='999') then aTyp # StrCut(aTyp,1,3);

  if (StrLen(aTyp)=3) and (StrCut(aTyp,1,3)>='001') and (StrCut(aTyp,1,3)<='999') then begin
    case aTyp of
      '100' :                 aGroupname # 'Adresse';
      '102' :                 aGroupname # 'Ansprechpartner';
      '120' :                 aGroupname # 'Projekt';
      '122' :                 aGroupname # 'Projektpos.';
      '200' :                 aGroupname # 'Material';
      '250' :                 aGroupname # 'Artikel';
      '401' :                 aGroupname # 'Auftrag'
      '501' :                 aGroupname # 'Bestellung'
    end;
  end;

  if (aGroupname<>'') then RETURN true;

  aGroupname # ' Unbekannt';

  RETURN false;
end;

//========================================================================
//========================================================================
sub GetEventFullname(
  a989          : int;
  var aFullname : alpha;
  var aGroup    : alpha) : logic;
local begin
  v980  : int;
  vTyp  : alpha;
end;
begin

  vTyp # GetEventType(a989->TeM.E.Aktion, a989->"TeM.E.Priorität"); //Str_Token(a989->TeM.E.Aktion,'|',1);
  GetGroupname(vTyp, var aGroup);
  aFullname # a989->TeM.E.Bemerkung;

  if (vTyp='EVENT') then begin
    v980 # RecBufCreate(980);
    v980->TeM.Nummer # a989->TeM.E.Aktionsnr;
    RecRead(v980, 1, 0);
    aGroup # ' '+Lib_Termine:GetTypeName(v980->TeM.Typ);
    RecbufDestroy(v980);
    RETURN true;
  end;

//22.10.2015  if (StrLen(vTyp)=3) and (StrCut(vTyp,1,3)>='001') and (StrCut(vTyp,1,3)<='999') then begin
//    if (StrFind(a989->TeM.E.Bemerkung,':',0)>0) then
//      aFullname # Str_token(a989->TeM.E.Bemerkung,':',2);
//  end;

  RETURN true;
end;

//========================================================================
//========================================================================
sub Jump(aItem : int);
local begin
  vA      : alpha;
  vRecID  : int;
  vTyp    : alpha;
end;
begin

  vA # Str_Token(aItem->spcustom, '|', 1);

  if (vA='100') then begin
    vRecId # cnvia(Str_Token(aItem->spName, '|', 2));
    adr_main:start(vRecID);
  end
  else if (vA='989') then begin
    vRecId # cnvia(Str_Token(aItem->spName, '|', 3));
    Erg # RecRead(989,0,_recId, vRecID);
    if (erg>_rLocked) then RETURN;

    vTyp # GetEventType(TeM.E.Aktion, "TeM.E.Priorität");

    if (vTyp='EVENT') then begin
      Tem_main:start(0, TeM.E.Aktionsnr, y);
    end
    else if (vTyp='PROJEKTPOS') or (vTyp='PROJEKTPOS*') then begin
      Prj_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), y);
    end
    else if (StrCut(vTyp,4,1)='/') then begin
    // Wiedervorlagen in Form "122/1001/3"
      vTyp # StrCut(vTyp,1,3);
      if (vTyp='100') then
        Adr_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), y);
      else if (vTyp='122') then
        Prj_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), y);
      else if (vTyp='401') then
        Auf_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), y);
    end;
  end;


end;


//========================================================================
//========================================================================
sub AddEventToZoneList(
  aList : int;
  a989  : int;
  aNew  : logic) : logic;
local begin
  vID     : int;
  vA      : alpha;
  vName   : alpha;
  vGroup  : alpha;
  vItem   : int;
  vTyp    : alpha;
end;
begin
  vA    # a989->TeM.e.Aktion;

  vTyp # GetEventType(vA, a989->"TeM.E.Priorität");
  GetEventFullname(a989, var vName, var vGroup);

  if (aNew) then vID # cTypDLOpen
  else vID # cTypDLClose;
  FindGroup(aList, vGroup, vID, y);

  if (aNew) then vID # cTypEventNew
  else vID # cTypEventOld;

  vItem # CteOpen(_cteitem);
  vItem->spname   # vGroup+'|'+vName+'|'+aint(RecInfo(a989,_recID));
  vItem->spcustom # '989|'+vName;
  vItem->spID     # vID;
//  Erg # CteInsertItem(aList, vGroup+'|'+vName+'|'+aint(RecInfo(a989,_recID)), vID, '989|'+vName);
//debug('Add item hdl:'+aint(vItem)+'   inhalt:'+vItem->spname+'___'+vItem->spcustom);
  RETURN (aList->CteInsert(vItem));

end;

//========================================================================
sub FindEventInZoneList(
  aList : int;
  a989  : int) : int;
local begin
  vItem   : int;
  vRecId  : int;
end;
begin

  vRecId # RecInfo(a989,_recID);

  FOR vItem # CteRead(aList, _CteFirst)
  LOOP vItem # CteRead(aList, _Ctenext, vItem);
  WHILE (vItem>0) do begin
//  debug('found:'+vItem->spname+'   '+vitem->spcustom);
// cust 1 = 989
// name 3 = recid
    if (GetDateiFromItem(vItem)=989) then begin
      if (GetEventIDFromItem(vItem)=vRecID) then RETURN vItem;
    end;
  END;

  RETURN 0;
end;


//========================================================================
//========================================================================
sub FindTempInZoneList(
  aList   : int;
  aDatei  : int) : int;
local begin
  vGroup  : alpha;
  vName   : alpha;
  vItem   : int;
end;
begin
  GetGroupname(aint(aDatei), var vGroup);
  vName # aint(RecInfo(aDatei, _RecId));
  vItem # aList->CteRead(_CteFirst | _CteSearch, 0, vGroup+'|'+vName+'|*');
  RETURN vItem;
end;


//========================================================================
//========================================================================
sub AddTempToZoneList(
  aList   : int;
  aDatei  : int;
  aBem    : alpha) : logic;
local begin
  vGroup  : alpha;
  vName   : alpha;
  vItem   : int;
end;
begin

  vItem # FindTempInZoneList(aList, aDatei);
  if (vItem>0) then RETURN false;

  GetGroupname(aint(aDatei), var vGroup);
  FindGroup(aList, vGroup, cTypDLOpen, y);    // neue Gruppe

  vName # aint(RecInfo(aDatei, _RecId));

  vItem # CteOpen(_cteitem);
  vItem->spname   # vGroup+'|'+vName+'|'+aint(vItem);
  vItem->spcustom # aint(aDatei)+'|'+aBem;
  vItem->spID     # cTypTempNew;

  RETURN aList->CteInsert(vItem);
end;


//========================================================================
//========================================================================
sub AddTAPIToZoneList(
  aList   : int;
  aGroup  : alpha;
  aBem    : alpha) : logic;
local begin
  vItem   : int;
  vOK     : logic;
end;
begin

  FindGroup(aList, aGroup, cTypDLOpen, y);    // neue Gruppe

  vItem # CteOpen(_cteitem);
  vItem->spname   # aGroup+'||'+aint(vItem);
  vItem->spcustom # 'TAPI|'+aBem;
  vItem->spID     # cTypTempNew;
  vOK # aList->CteInsert(vItem);

  RETURN vOK;
end;


//========================================================================
//========================================================================
sub DeleteItem(
  aZonelist : int;
  aItem     : int;
  aDL       : int;
  opt aMan  : logic) : logic
local begin
  vGroup  : alpha;
  vItem   : int;
  vA      : alpha;
  vTyp    : alpha;
  v980    : int;
end;
begin
//debug('delete item:'+aint(aItem)+'   inhalt:'+aItem->spname+'___'+aItem->spcustom);

// 26.11.2014  gFrmMain->WinUpdate(_WinUpdOff);

  if (ReadEvent(GetEventIDFromItem(aItem))) then begin

    // 21.10.2015
    if (aMan) then begin
      vTyp # GetEventType(TeM.E.Aktion, "TeM.E.Priorität");
      if (vTyp='EVENT') then begin
        v980 # RecBufCreate(980);
        v980->TeM.Nummer # TeM.E.Aktionsnr;
        RecRead(v980, 1, 0);
        // TELEFONAT???
        if (v980->TeM.Typ='TEL') or (v980->TeM.Typ='4') then begin
          if (Msg(99,'Aktivität damit auch löschen?',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
            RecBufCopy(v980,980);
            Tem_Data:delete();
            RecbufDestroy(v980);
            RETURN true;
          end;
        end;
        RecbufDestroy(v980);
      end;
    end;

    RekDelete( 989, 0, 'MAN' );
    if (Erg>_rLocked) then RETURN false;
  end;

  CteDelete(aZonelist, aItem);  // Eintrag löschen

  vGroup # GetGroupFromItem(aItem);

aDL # 0;
if (aDL=0) then begin
  aDL # FindDL(vGroup);
//  vItem # aZoneList->CteRead(_CteFirst | _CteSearch, 0, vGroup+'|');
//  if (vItem<>0) then begin
//debugx(vItem->spname+'  '+aint(vItem->spid)+'  '+vItem->spcustom);
//  end;
//  RETURN true;
end;
if (aDL=0) then RETURN true;
//aDL # $dl.Zone3;


//  aDataList->WinLstDatLineRemove(aID);
  if (WinLstDatLineInfo(aDL, _WinLstDatInfoCount)=1) then begin
    vItem # aZoneList->CteRead(_CteFirst | _CteSearch, 0, vGroup+'|');
    if (vItem<>0) then
      CteDelete(aZonelist, vItem);  // Gruppe löschen
  end;

  RETURN true;
end;

//========================================================================
//========================================================================
sub RefreshButtonFromDataList(
  aBT       : int;
  aDL       : int;
  opt aCap  : alpha;);
local begin
  vI, vN  : int;
end;
begin

  vI # WinLstDatLineInfo(aDL, _WinLstDatInfoCount);
  vN # cnvia(aDL->wpcustom);
  if (vN<=0) then
    aBT->wpcaption  # aBT->wpcustom+'   ('+aint(vI)+')'
  else
    aBT->wpcaption  # aBT->wpcustom+'   ('+aint(vN)+' neu / '+aint(vI)+')';

end;


//========================================================================
//========================================================================
Sub ToggleItemStar(
  aDL   : int;
  aID   : int;
  aItem : int);
local begin
  vName : alpha;
  vBT   : int;
  vNew  : logic;
end;
begin

  vName # StrCut(aDL->wpname,4,100);
  vBT   # WinSearch(gMDI, 'bt.'+vName);

  if (aItem->spID=cTypEventOld) then begin
    aItem->spID # cTypEventNew;
    aDL->wpcustom # aint(cnvia(aDL->wpcustom)+1);    // NEU Zähler erhöhen
    vNew # y;
  end
  else if (aItem->spID=cTypTempOld) then begin
    aItem->spID # cTypTempNew;
    aDL->wpcustom # aint(cnvia(aDL->wpcustom)+1);    // NEU Zähler erhöhen
    vNew # y;
  end
  else if (aItem->spID=cTypEventNew) then begin
    aItem->spID # cTypEventOld;
    aDL->wpcustom # aint(cnvia(aDL->wpcustom)-1);    // NEU Zähler erhöhen
  end
  else if (aItem->spID=cTypTempNew) then begin
    aItem->spID # cTypTempOld;
    aDL->wpcustom # aint(cnvia(aDL->wpcustom)-1);    // NEU Zähler erhöhen
  end;

  RefreshButtonFromDataList(vBT, aDL);

  if (vNew) then
    aDL->WinLstCellSet(cIconNew, 3, aID)
  else
    aDL->WinLstCellSet(0, 3, aID);

end;

//========================================================================
//========================================================================
sub ResizeZone(
  aSB         : int;
  aZone       : int;
  aGB         : int;
  var aMaxY   : int;
  var aSpalte : int;
  var aY      : int);
local begin
  vBT         : int;
  vDL         : int;
  vH          : int;
  vB          : int;

  vRect       : rect;
  vI          : int;
  vExp        : logic;
  vCap        : alpha;

  vTyp        : int;
end
begin

  GetCustom(aGB, var vTyp, var vCap, var vExp);
  vBT # Winsearch(aSB, 'bt.Zone'+aint(aZone));

  vI # 6;
  vB # 128;
  if (vTyp=cTypDL) then begin
    vB # cWidth;
    vDL # Winsearch(aSB, 'dl.Zone'+aint(aZone));
    vI # WinLstDatLineInfo(vDL, _WinLstDatInfoCount);
  end;

  if (vExp) then begin
//    if (vI>5) then vH # 58 + (5 * 23)
//    else vH # 58 + (vI * 23);
vH # 58 + (vI * 23);

//if (vH> (aMaxY-aY-20) ) then

  end
  else begin
    vH # 30;
  end;

  if (20 + aY+vH>aMaxY) and (aZone>1) then begin
    aY # 2;
    inc(aSpalte);
  end;

if (20 + aY+vH>aMaxY) then begin
  vH # aMaxY -aY - 20;
end;

  if (vTyp=cTypDL) then RefreshButtonFromDataList(vBT, vDL);

  vRect         # aGB->wpArea;
  vRect:Left    # 2 + ((2 + cWidth) * (aSpalte - 1));
  vRect:right   # vRect:Left + vB;
  vRect:Top     # aY;
  vRect:bottom  # aY + vH;
  aGB->wparea   # vRect;
/**
vBT->wpVisible    # true;
vBT->wpAutoupdate # true;
vDL->wpvisible  # vExp;
vDL->wpAutoupdate # true;
aGB->wpVisible  # true;
aGB->wpAutoupdate # true;
**/
  if (vDL<>0) then vDL->wpvisible  # vExp;

  aY # aY + vH + 10;
end;


//========================================================================
//========================================================================
sub CreateZone_DL(
  aZone   : int;
  aCap    : alpha;
  aSB     : int;
  aMDI    : int;
  aExp    : logic;
) : int;
local begin
  vGB   : int;
  vBT   : int;
  vDL   : int;
  vClm  : int;
  vFont : font;
  vSrc  : int;
  vHdl  : int;
end;
begin

  vGB # CopyGroupBox(aMDI, 'gb.Zone0', 'gb.Zone'+aint(aZone), aSB);
  SetCustom(vGB, cTypDL, aCap, aExp);

  vBT # CopyButton(aMDI, 'bt.Zone0', 'bt.Zone'+aint(aZone), vGB, aCap, aExp);

  vSrc # WinSearch(aMDI, 'dl.Zone0');
  vDL  # Wincreate(_WinTypeDataList, 'dl.Zone'+aint(aZone), aCap, vGB);
vDL->wpVisible        # false;
vDL->wpAutoUpdate     # false;

  vDL->wparea           # vSrc->wparea;
  vDL->wpColFg          # vSrc->wpColFg;
  vDL->wpColBkg         # vSrc->wpColBkg;
  vDL->wpColGrid        # vSrc->wpColGrid;
  vDL->wpColSeparator   # vSrc->wpColSeparator;
  vDL->wpColFocusFg     # vSrc->wpColFocusFg;
  vDL->wpColFocusBkg    # Set.Col.RList.Cursor;//vSrc->wpColFocusBkg;
  vDL->wpColBkgApp      # vSrc->wpColBkgApp;
  vDL->wpColDisabledFg  # vSrc->wpColDisabledFg;
  vDL->wpColDisabledBkg # vSrc->wpColDisabledBkg;
  vDL->wpColFocusOffFg  # vSrc->wpColFocusOffFg;
  vDL->wpColFocusOffBkg # vSrc->wpColFocusOffBkg;
  vDL->wpFont           # vSrc->wpFont;
  vDL->wpLstStyle       # vSrc->wpLstStyle;
  vDL->wpTileNameUser   # vSrc->wpTileNameUser
  vDL->wpSBarStyle      # vSrc->wpSBarStyle;
  vDL->wpFocusByMouse   # vSrc->wpFocusByMouse;
  vDL->wpOleDropMode    # vSrc->wpOleDropMode;
  CopyEvtProc(_WinEvtLstDataInit, vSrc, vDL);
  CopyEvtProc(_WinEvtLstSelect, vSrc, vDL);
  CopyEvtProc(_WinEvtMouseItem, vSrc, vDL);
  CopyEvtProc(_WinEvtDragInit, vSrc, vDL);
  CopyEvtProc(_WinEvtDragTerm, vSrc, vDL);

  FOR vHdl # vSrc->WinInfo(_WinFirst);
  LOOP vHdl # vHdl->WinInfo(_WinNext);
  WHILE (vHdl<>0) do begin
    vClm  # Wincreate(_WinTypeListColumn, vHdl->wpname, vHdl->wpcaption, vDL);
    vClm->wpVisible       # vHdl->wpvisible;
    vClm->wpClmWidth      # vHdl->wpClmWidth;
    vClm->wpClmStretch    # vHdl->wpClmStretch;
    vClm->wpClmType       # vHdl->wpClmType;
    vClm->wpClmTypeImage  # vHdl->wpClmTypeImage;
    vClm->wpFontParent    # vHdl->wpFontParent
  END;

  RETURN vDL;
end;


//========================================================================
//========================================================================
sub ItemToDataList(
  aDL     : int;
  aItem   : int;
);
local begin
  vTyp    : int;
  vText   : alpha;
end;
begin

  vTyp    # aItem->spID;;
  vText   # Str_Token(aItem->spCustom,'|',2);

  aDL->WinLstDatLineAdd(aItem);

  aDL->WinLstCellSet(cIconDelete, 2, _WinLstDatLineLast);

/*
  if (vTyp=cTypEventOld) or (vTyp=cTypEventNew) then begin
    aDL->WinLstCellSet(cIconTermin, 3, _WinLstDatLineLast);
  end
  else if (vTyp=cTypTempnew) or (vTyp=cTypTempOld) then begin
    aDL->WinLstCellSet(0, 3, _WinLstDatLineLast);
  end;
*/
  if (vTyp=cTypEventNew) or (vTyp=cTypTempNew) then begin
    aDL->WinLstCellSet(cIconNew, 3, _WinLstDatLineLast);
    aDL->wpcustom # aint(cnvia(aDL->wpcustom)+1);    // NEU Zähler erhöhen
  end;
  aDL->WinLstCellSet(vText, 4, _WinLstDatLineLast);

end;


//========================================================================
//========================================================================
sub RedrawZones(aMdi      : int);
local begin
  vZone       : int;
  vSB         : int;
  vGB         : int;
  vBT         : int;
  vDL         : int;
  vY          : int;
  vH,vW       : int;
  vRect       : rect;
  vMaxX       : int;
  vMaxY       : int;
  vI          : int;
  vSpalte     : int;
  vExp        : logic;
  vCap        : alpha;
end;
begin

  vRect   # gMdiNotifier->wparea;
  vMaxX   # vRect:right - vRect:left-8 -10;
  vMaxY   # vRect:Bottom - vRect:Top - 30 - 12;

  vSB # Winsearch(gMDINotifier, 'scrollbox1');
  vRect         # vSB->wpArea;
  vRect:right   # vMaxX;
  vRect:Bottom  # vMaxY;
  vSB->wparea   # vRect;


  vZone   # 1;
  vSpalte # 1;
  vY # 0;    // YPos erste Spalte 2+25

//    vZone # aZone;
//    vGB # Winsearch(aMDI, 'gb.Zone'+aint(vZone));
//    ResizeZone(aMdi, vZone, vGB, var vMaxY, var vSpalte, var vY);
//  FOR vGB # Winsearch(aMDI, 'gb.Zone'+aint(vZone))
//  LOOP begin inc(vZone); vGB # Winsearch(aMDI, 'gb.Zone'+aint(vZone)) end
  FOR vGB # Winsearch(vSB, 'gb.Zone'+aint(vZone))
  LOOP begin inc(vZone); vGB # Winsearch(vSB, 'gb.Zone'+aint(vZone)) end
  WHILE (vGB<>0) do begin
    ResizeZone(aMdi, vZone, vGB, var vMaxY, var vSpalte, var vY);
//vGB->wpAutoupdate # true;
//vGB->wpvisible    # true;
  END;

  vSB->wpScrollHeight # vMaxY;
  vSB->wpScrollWidth  # 15 + (vSpalte * cWidth);

end;



//========================================================================
//========================================================================
sub CreateZonesFromList(
  aMDI  : int;
  aList : int);
local begin
  vItem   : int;
  vName   : alpha;
  vGroup  : alpha;
  vAnz    : int;
  vSB     : int;
  vDL     : int;
  vExp    : logic;
  vWert   : int;
end;
begin

  vSB     # Winsearch(aMDI, 'scrollbox1');

  FOR vItem # CteRead(aList, _ctefirst);
  LOOP vItem # CteRead(aList, _cteNext, vItem);
  WHILE (vItem<>0) do begin

    // DataList?
    if (vItem->spID=cTypDLOpen) or (vItem->spID=cTypDLClose) then begin
      vName # Str_Token(vItem->spname, '|',1);
      inc(vAnz);
      vExp    # (vItem->spId = cTypDLOpen);
      vDL     # CreateZone_DL(vAnz, vName, vSB, aMDI, vExp);
      CYCLE;
    end;

    // Gauge?
    if (vItem->spID=cTypGauOpen) or (vItem->spID=cTypGauClose) then begin
      vName # Str_Token(vItem->spname, '|',1);
      inc(vAnz);
      vExp    # (vItem->spId = cTypGauOpen);
      vWert   # cnvia(Str_Token(vItem->spcustom,'|',2));
      vDL     # CreateZone_Gauge(vAnz, vWert, vName, vSB, aMDI, vExp);
      CYCLE;
    end;

    ItemToDataList(vDL, vItem);
  END;

end;



//========================================================================
sub DeAktiv(aObj : int);
local begin
  vHdl : int;
end;
begin

  FOR vHdl # Wininfo(aObj, _WInfirst)
  LOOP vHdl # Wininfo(vHdl, _WinNext)
  WHILE (vHdl<>0) do begin
    vHdl->wpAutoUpdate     # false;
    if (Wininfo(vHdl, _wintype)<>_WinTypeDataList) then begin
      Deaktiv(vHdl);
    end;
  END;

end;

//========================================================================
sub Aktiv(aObj : int);
local begin
  vHdl : int;
end;
begin

  FOR vHdl # Wininfo(aObj, _WInfirst)
  LOOP vHdl # Wininfo(vHdl, _WinNext)
  WHILE (vHdl<>0) do begin
    vHdl->wpVisible        # true;
    vHdl->wpAutoUpdate     # true;
    if (Wininfo(vHdl, _wintype)<>_WinTypeDataList) then begin
      Aktiv(vHdl);
    end;
  END;

end;

//========================================================================
//========================================================================
sub RebuildZones(
  aMDI  : int;
  aList : int);
local begin
  vZone : int;
  vGB   : int;
  vSB   : int;
  vHdl  : int;
  vFoc  : int;
end;
begin

//  vFoc # WinFocusget();
//aMDI->wpautoupdate # false;
//gFrmMain->WinUpdate(_WinUpdOff);


  vSB # Winsearch(aMDI, 'scrollbox1');

//  Deaktiv(vSB);

  // Kill all zones
  vZone # 1;
  FOR vGB # Winsearch(aMDI, 'gb.Zone'+aint(vZone))
  LOOP begin inc(vZone); vGB # Winsearch(aMDI, 'gb.Zone'+aint(vZone)) end
  WHILE (vGB<>0) do begin
//    vGB->wpname # 'xx.Zone'+aint(vZone);
    WinDestroy(vGB);
  END;

  CreateZonesFromList(aMDI, aList);

  RedrawZones(aMDI);

  Aktiv(vSB);

//gFrmMain->WinUpdate(_WinUpdOn);
//aMDI->wpautoupdate # true;
//Winupdate(aMDI, _WinUpdOn);

//  Lib_GuiCom2:TryWinFocusSet(vFoc);
end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect       : rect;
  v989        : int;
end
begin

  // First Start?
  if (gZoneList=0) then begin
    gZoneList # CteOpen(_CteTreeCI);

    GV.Sys.Username   # gUsername;
    v989 # RecBufCreate(989);
    FOR Erg # RecLink(v989, 999, 6, _recFirst);
    LOOP Erg # RecLink(v989, 999, 6, _recNext);
    WHILE (Erg<=_rLocked) do begin
/*
    FOR Erg # RecRead(100, 1, _recFirst);
    LOOP Erg # RecRead(100, 1, _recNext);
    WHILE (Erg<=_rLocked) do begin
if (Adr.LKZ<>'D') and (Adr.STichwort<>'SLC')then
*/
//      CteInsertItem(gZoneList, Adr.LKZ+'|'+CnvAI( RecInfo(100, _recID), _fmtNumHex | _fmtNumLeadZero, 0, 8 ), 0, Adr.STichwort);

      AddEventToZoneList(gZoneList, v989, v989->TeM.E.NeuYN);
    END;
    RecBufDestroy(v989);


//TestGauge(gZoneList);


    RebuildZones(aEvt:Obj, gZoneList);

    RETURN true;
  end;

  if (aFlags & _WinPosSized != 0) then begin
    RedrawZones(aEvt:obj);
  end;


	RETURN (true);
end;


//========================================================================
//========================================================================
sub EvtLstDataInit(
  aEvt                 : event;    // Ereignis
  aID                  : int;      // Datensatz ID oder Zeilennummer
) : logic;
local begin
  vItem : int;
  vHdl  : int;
  vCol  : int;
  vCol2 : int;
end;
begin
/***/
  WinLstCellGet(aEvt:obj, vItem, 1, aID);
  if (vItem<>0) then begin
    if (ReadEvent(GetEventIDFromItem(vItem))) then begin
      if ("TeM.E.Priorität">0) then
        vCol2 # _WincolLightYellow;
    end;
  end;
/***/
  if ((aID % 2)>0) then begin
    vCol  # _WinColWhite;
  end
  else begin
    vCol  # RGB(230,230,230);
  end;


  FOR vHdl # aEvt:Obj->WinInfo(_WinFirst);
  LOOP vHdl # vHdl->WinInfo(_WinNext);
  WHILE (vHdl<>0) do begin

/***/
    if (vCol2<>0) and (vHdl->wpname='clm3') then begin
      vHdl->wpClmColBkg         # vCol2;
//      vHdl->wpClmColFocusOffBkg # vCol2;
      CYCLE;
    end;
/***/
    vHdl->wpClmColBkg         # vCol;
//    vHdl->wpClmColFocusOffBkg # vCol;
  END;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtLstSelect(
  aEvt                 : event;    // Ereignis
  aID                  : int;      // Record-ID des Datensatzes oder Zeilennummer
) : logic;
local begin
  vName : alpha;
  vBT   : int;
  vDL   : int;
  vItem : int;
  vTyp  : int;
end;
begin
/*
  WinLstCellGet(aEvt:obj, vItem, 1, aID);
  if (vItem=0) then RETURN true;

  vName # StrCut(aEvt:Obj->wpname,4,100);
  vBT   # WinSearch(gMDI, 'bt.'+vName);
  vDL   # WinSearch(gMDI, 'dl.'+vName);

  if (vItem->spID=cTypEold) then begin
    vItem->spID # cTypNew;
    aEvt:OBj->wpcustom # aint(cnvia(aEvt:OBj->wpcustom)+1);    // NEU Zähler erhöhen
  end
  else begin
    vItem->spID # cTypold;
    aEvt:OBj->wpcustom # aint(cnvia(aEvt:OBj->wpcustom)-1);    // NEU Zähler erhöhen
  end;

  RefreshButtonFromDataList(vBT, vDL);


  if (vItem->spID=cTypOld) then begin
    aEvt:obj->WinLstCellSet(0, 4, aID);
  end
  else if (vItem->spID=cTypNew) then begin
    aEvt:obj->WinLstCellSet(cIconNew, 4, aID);
  end;
*/

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vName   : alpha;
  vGB     : int;
  vExp    : logic;
  vCap    : alpha;
  vItem   : int;

  vTyp    : int;
  vI      : int;
end;
begin

  vName # StrCut(aEvt:Obj->wpname,4,100);

  vGB # Winsearch(gMDINotifier, 'gb.'+vName);
  GetCustom(vGB, var vTyp, var vCap, var vExp);


  if (vExp) then begin
    SetCustom(vGB, vTyp, vCap, false);
    aEvt:obj->wpImageTile # _WinImgNext;
//    vDL->wpvisible # true;
//    vRect # vGB->wpArea;
//    vGB->wpAreaBottom # 100;
  end
  else begin
    SetCustom(vGB, vTyp, vCap, true);
    aEvt:obj->wpImageTile # _WinImgPageNext;
  //  vDL->wpvisible # false;
  //  vRect # vGB->wpArea;
//    vGB->wpAreaBottom # 30;
  end;

  // Toggle Type
  vItem # FindGroup(gZonelist, vCap);
  if (vItem<>0) then begin
    case vItem->spid of
      cTypDLOpen    : vItem->spid # cTypDLClose;
      cTypDLClose   : vItem->spid # cTypDLOpen;
      cTypGauOpen   : vItem->spid # cTypGauClose;
      cTypGauClose  : vItem->spid # cTypGauOpen;
    end;
  end;

  RedrawZones(gMdiNotifier);

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtMouseItem(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : handle;   // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
  vItem     : int;
  vGroup    : alpha;
  vZonelist : int;
end;
begin
  // nur Doppelklick akzeptieren
  if ( aButton & _winMouseLeft = 0 ) or ( aButton & _winMouseDouble = 0 ) then
    RETURN true;

  if ( aItem = 0 ) or ( aId = 0 ) then
    RETURN true;


  vZoneList # gZoneList;


  // DELETE?
  if ( aItem->wpName = 'clm1' ) then begin

    WinLstCellGet(aEvt:obj, vItem, 1, aID);

    DeleteItem(vZoneList, vItem, aEvt:obj);

    RebuildZones(gMDINotifier, gZonelist);

    RETURN true;
  end;  // delete



  // STAR?
  if ( aItem->wpName = 'clm2' ) then begin
    WinLstCellGet(aEvt:obj, vItem, 1, aID);

    if (vItem<>0) then
      ToggleItemStar(aEvt:obj, aID, vItem);

    vGroup # GetGroupFromItem(vItem);
    if (ReadEvent(GetEventIDFromItem(vItem))=false) then RETURN false;
    RecRead(989,1,_recLock);
    TeM.E.NeuYN     # !TeM.E.NeuYN;
    RekReplace(989,_recunlock,'MAN');

  end;


  // LINK?
  if ( aItem->wpName = 'clm3' ) then begin
    WinLstCellGet(aEvt:obj, vItem, 1, aID);
    if (vItem<>0) then Jump(vItem);
  end;


end;


//========================================================================
//  EvtDragInit
//              Sourceobjekt auswählen
//========================================================================
sub EvtDragInit(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  vItem : int;
  vFile : int;
  vID   : int;
  vTyp  : alpha;

  vRecId  : int;
end;
begin

  if (aEvt:obj->wpcurrentint=0) then RETURN false;
  aEvt:obj->WinLstCellGet(vItem,1,_WinLstDatLineCurrent);

  if (ReadEvent(GetEventIDFromItem(vItem))=false) then RETURN false;

  vTyp # GetEventType(TeM.E.Aktion, "TeM.E.Priorität"); //Str_Token(a989->TeM.E.Aktion,'|',1);
  if (StrLen(vTyp)=3) and (StrCut(vTyp,1,3)>='001') and (StrCut(vTyp,1,3)<='999') then begin
    aDataObject->wpName # vTyp+'|'+aint(Tem.E.Aktionsnr);
    aDataObject->wpFormatEnum(_WinDropDataText) # true;
    aEffect # _WinDropEffectCopy | _WinDropEffectMove;
    RETURN true;
  end else begin

    // Prüfen ob Event auch ein Termin hat
    if (StrAdj(vTyp,_StrAll) = 'EVENT') then begin

      // Event Lesen
      vRecId # cnvia(Str_Token(vItem->spName, '|', 3));
      RecRead(989,0,_recId, vRecID);

      // Aktion lesen
      // Alles was Start und Endzeit hat, kann als mögliche Projektzeit genutzt werden
      Tem.Nummer  # Tem.E.Aktionsnr;
      if  (RecRead(980,1,0) = _rOK) AND
          (TeM.Start.Von.Datum <> 0.0.0) AND (TeM.Start.Von.Zeit <> 0:0:0) AND
          (TeM.Ende.Von.Datum <> 0.0.0) AND (TeM.Ende.Von.Zeit <> 0:0:0) then begin

          aDataObject->wpName # vTyp+'|'+aint(Tem.E.Aktionsnr);
          aDataObject->wpFormatEnum(_WinDropDataText) # true;
          aEffect # _WinDropEffectCopy | _WinDropEffectMove;
          RETURN true;
      end;

    end; //  if (vTyp = 'EVENT') then begin

  end;

  RETURN false;
end;


//========================================================================
//  EvtDragTerm
//              D&D beenden
//========================================================================
sub EvtDragTerm(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt;Durchgeführte Dragoperation (_WinDropEffectNome = abgebrochen)
	aEffect      : int
) : logic
local begin
  vFormat : int;
  vTxtBuf : int;
  vHdl    : int;
end;
begin
  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    // Format-Objekt ermitteln.
    vFormat # aDataObject->wpData(_WinDropDataText);

    debugx(here+'EvtDragTerm:' +  StrFmt(aDataObject->wpName,30,_strend));
    // Format schliessen.
    aDataObject->wpFormatEnum(_WinDropDataText) # false;
  end;

  // Eintrag löschen...
//  if (aEffect=_WinDropEffectMove) or (aEffect=_WinDropEffectCopy) then begin
//    vHdl # $DL.Workbench;
//    vHdl->WinLstDatLineRemove(_WinLstDatLineCurrent);
//  end;

end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vFormat : int;
  vTxt    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
	RETURN (true);
end;


//=========================================================================
//=========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vPref     : alpha;
  vA        : alpha;
  vDatei    : int;
  vID       : int;
  vDetail   : logic;
  vZonelist : int;
  vBuf      : int;
  vKey      : alpha(200);
end;
begin
  if (aEffect | _WinDropEffectCopy=0) or (aEffect | _WinDropEffectMove=0) then RETURN false;


  if (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpcustom<>'') then begin

    vA      # StrFmt(aDataObject->wpName,30,_strend);
    vDatei  # Cnvia(StrCut(vA,1,3));
    vID     # Cnvia(StrCut(vA,5,15));
    Lib_Workbench:CreateName(vDatei, var vPref, var vA);

    if (Dlg_Notifier:Dlg_Drop(var vA, var vDetail)=false) then RETURN false;

    if (vDetail) then begin

      RecBufClear(980);
      Tem2_Main:RecInit();
      TeM.Typ   # 'AFG';

      // Add User to TEM
      //TeM_A_Data:New(800,'MAN');
      TeM_A_Data:Anker(800,'MAN');

      // Datensatz verankern
      RecRead(vDatei, 0, _recId, vID);
//      RecBufClear(981);
//      TeM.A.Nummer          # TeM.Nummer;
//      TeM.A.Datei           # vDatei;
//      TeM.A.Start.Datum     # today;
//      TeM.A.Start.Zeit      # now;
//      TeM.A.lfdNr           # 1;
//      TeM.A.EventErzeugtYN  # y;
//      REPEAT
//        TeM_A_Data:Insert(0,'AUTO');
//        if (erg<>_rOK) then inc(TeM.A.lfdNr);
//      UNTIl (Erg=_rOK);
      TeM_A_Data:Anker(800,'AUTO');

      TeM.Start.Von.Datum   # today;
      TeM.Start.Von.Zeit    # now;
      TeM.Ende.Von.Datum    # 0.0.0;
      TeM.Ende.Von.Zeit     # 24:0;
      TeM.SichtbarPlanerYN  # y;
      TeM.Bezeichnung       # vA;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.Maske','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain, _WinAddHidden);
      gMdi->WinUpdate(_WinUpdOn);

/**
      if (Lib_Notifier:NewTermin('AFG', vA, vBem, true)=false) then RETURN false;

      // User verankern
      Usr.Username # gUsername;
      RecRead(800,1,0);
      RecBufClear(981);
      TeM.A.Nummer      # TeM.Nummer;
      TeM.A.Code        # gUsername;
      TeM.A.Datei       # 800;
      TeM.A.Start.Datum # today;
      TeM.A.Start.Zeit  # now;
      TeM.A.lfdNr       # 1;
      TeM.A.EventErzeugtYN # y;
      REPEAT
        TeM_A_Data:Insert(0,'AUTO');
        if (erg<>_rOK) then inc(TeM.A.lfdNr);
      UNTIl (Erg=_rOK);


      // Datensatz verankern
      RecRead(vDatei, 0, _recId, vID);
      RecBufClear(981);
      TeM.A.Nummer      # TeM.Nummer;
      TeM.A.Datei       # vDatei;
      TeM.A.Start.Datum # today;
      TeM.A.Start.Zeit  # now;
      TeM.A.lfdNr       # 1;
      TeM.A.EventErzeugtYN # y;
      REPEAT
        TeM_A_Data:Insert(0,'AUTO');
        if (erg<>_rOK) then inc(TeM.A.lfdNr);
      UNTIl (Erg=_rOK);
      vID # RecInfo(980,_recid);

      Lib_Notifier:NewEvent(gUsername, '989', vA, vID ,today, now, 0);
**/
    end
    else begin

//      Lib_Notifier:NewEvent(gUsername, aint(vDatei), vA, vID ,today, now, 0);
      vBuf # VarInfo(WindowBonus);
      VarInstance(WindowBonus,cnvIA(gMDINotifier->wpcustom));
      vZonelist # gZonelist;
      VarInstance(WindowBonus, vBuf);

      vKey # Lib_Rec:MakeKey(vDatei,y,'/');
      Lib_Notifier:NewEvent( 'AH', aint(vDatei)+'/'+vKey, vA);

      // TEMPRÄR?
//AddTempToZoneList(vZoneList, vDatei, vA);
//ReBuildZones(gMDINotifier, vZonelist);

    end;

  end;


  RETURN(true);
end;


//========================================================================