@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_GuiCom
//                      OHNE E_R_G
//  Info
//
//  12.11.2008  PW  Nachtragung des Headers
//  23.09.2009  MS  Beweglichkeit der Toolbar abgeschaltet
//  21.10.2010  AI  RunChildWindow passt Sortierung an gKey an
//  26.06.2012  AI  cbBAG.P.ZielVerkaufYN kann nicht verändert erden Projekt 1326/249
//  29.06.2012  AI  Neu:Able
//  06.07.2012  AI  Neu:GetAbsluteXY
//  // 21.05.2013 raus 06.05.2013  AI  "AuswahlEnable" nur bei beschreibbaren Feldern
//  29.08.2013  AH  "RunChildWindow" refreshet die Grösse etwas "später" (Problem: F9 in Abrufnr. im Auftrag und dann anfängliche RecList)
//  17.02.2014  ST  "Able(...)" Sicherheitsabfrage auf "Enable/Disable" für leeres/falsches Objekt hinzugefügt
//  26.06.2014  AH  Fix: Context beim INI-ffnen beachten
//  24.07.2014  AH  AuswahlDieable setzt Farbe zurück
//  06.11.2014  AH  sub ScaleObjects nutzt nicht mehr den globalen Zoomfaktor, sondern einen gepufferten
//  15.12.2014  AH  "OpenMDI" erlaubt mehr Events
//  04.03.2016  AH  AddChildWindow handlet gMdiNotifier als Starter gleich wie das gFrmMain oder gMdiMainmeu etc. (also KEINE Child-Parent-Beziehung)
//  27.03.2017  TM  ResetColumnWidth setzt alle Spalten einer Zugriffsliste auf 50. Die Reihenfolge und Fixierung bleibt dabei erhalten.
//  27.07.2021  AH  ERX
//  29.08.2021  AH  "GetAlternativeMain"
//  02.03.2022  AH  Splits werden in der User.Ini gespeichert
//  21.06.2022  AH  "RememberList" behält den Key auch bei zwischenzeitlichen Selektionen/Linked-Listen
//
//  Subprozeduren
//    SUB GetAlternativeName(aName : alpha) : alpha;
//    SUB GetAlternativeMain(aMdi  : int; aStd  : alpha) : alpha
//    SUB GetAbsolutXY(aHdl : int; var aX : int; var aY : int);
//    SUB SetWindowArea(aHdl : int; aX : int; aY : int; aXX : int; aYY : int)
//    SUB ObjSetPos(aMdi : int; aX : int; aY : int)
//    SUB MdiOptSize(aMdi : int)
//    SUB OpenMDI(aParent : int; aName : alpha; aMode : int) : int;
//    SUB ReOpenMDI(aMDI : int);
//    SUB AddChildWindow(aParent : int; aName : alpha; aProc : alpha; opt aMuendig : logic; opt aNoList : logic; opt aContext : alpha; opt aTermPara : alpha) : int;
//    SUB RunChildWindow(aChild : int; optaParent : int; optaOpt : int);
//    SUB RecallList(aObj : int; opt aPrefix : alpha)
//    SUB RecallWindow ( aObj : handle; )
//    SUB RememberList(aObj : int; opt aPrefix : alpha)
//    SUB RememberWindow ( aObj : handle; )
//    SUB ZLSetSort(aKey : int; opt aKeyLdf :int)
//    SUB RePos(var aMDI  : int; aName : alpha; aRecID : int; aView : logic)
//    SUB FindMDI(aObj : int) : int
//    SUB AuswahlEnable(aObj : int)
//    SUB AuswahlDisable(aObj : int)
//    SUB Enable(aObj : int)
//    SUB Disable(aObj : int)
//    SUB Able(aObj : int; aEnable : logic)
//    SUB SMState_Obj(aObj : int; aStatus : logic)
//    SUB SMState_Obj2(aObj : int; aStatus : logic)
//    SUB SetMaskState(aStatus : logic)
//    SUB SetWindowState(aObj : int; aStatus : logic)
//    SUB BuildObjectList(aList : int; aObj : int)
//    SUB ExpandTree(aObj : int)
//    SUB Gui_Translate ( aName : alpha(64) ) : alpha;
//    SUB TranslateObject ( aObj : int )
//    SUB ZLColorLine ( aObj : int; aColor : int; opt aUnfixed : logic ) : logic
//    SUB Pflichtfeld(aObj : int)
//    SUB FixColumnsEvtMenuContext ( aEvt : event; aHittest : int; aItem : handle; aId : int ) : logic
//    SUB Tree_refresh(aNode : int)
//    SUB Tree_find_default(aNode : int; sName : alpha; set_ : logic)
//    SUB node_set_default(sdesc : int)
//    SUB node_del_default(sdesc : int)
//
//    SUB BuildScaleList(aList : int; aObj  : int)
//    SUB ScaleObjects(aList : int; aRecalc : logic);
//    SUB ResetColumnWidth(aObj : int; opt aPrefix   : alpha;)
//    SUB Save_Windows_Splits( aobj : int; windowname : alpha )   UN 02.03.2022
//    SUB Get_Windows_SplitElemets( aobj : int )                  UN 02.03.2022
//    SUB Recall_Splits(aobj : int; awindowname : alpha)          UN 02.03.2022
//
//========================================================================
@I:Def_Global
//@I:var.Def

define begin
//  ColInactive : ((((235<<8)+235)<<8)+235);
//  ColInactive : ((((216<<8)+233)<<8)+236);
//  ColInactive : ((((225<<8)+225)<<8)+225)
//  ColInactive : _WinColInactiveCaptionText;//((((225<<8)+225)<<8)+225);
//  ColFocus    : _WinColBlack;//((((000<<8)+240)<<8)+240);
end;

//========================================================================
declare Gui_Translate ( aName : alpha(1000) ) : alpha;
declare RecallWindow ( aObj : handle );
declare ScaleObjects(aList : int; aRecalc : logic);
declare ZLSetSort(aKey : int; opt aKeyLfd :int);
declare Save_Windows_Splits( aobj : int; windowname : alpha );
declare Recall_Splits(aobj : int; awindowname : alpha)

//========================================================================
// GetAlternativeName
//
//========================================================================
sub GetAlternativeName(aName : alpha) : alpha;
local begin
  vBuf906 : int;
  vA      : alpha;
end;
begin
  vBuf906 # Reksave(906);
  Dia.Bereich # aName;
  if (RecRead(906,1,0)<=_rLocked) and (Dia.Name<>'') then
    vA # Dia.Name
  else
    vA # aName;
  RekRestore(vBuf906);
  RETURN vA;
end;

//========================================================================
//========================================================================
sub GetAlternativeMain(
  aMdi  : int;
  aStd  : alpha) : alpha
local begin
  vProc : alpha
end;
begin
  if (aMDI=0) then RETURN aStd;
  if (HdlInfo(aMdi, _HdlExists)=0) then RETURN aStd;
  if (WinInfo(aMdi, _wintype)<>_WinTypeMdiFrame) then RETURN aStd;
  vProc # Str_Token(WinEvtProcNameGet(aMdi, _Winevtinit),':',1);
  if (vProc='') then vProc # aStd;
  RETURN vProc;
end;


//========================================================================
//  GetAbsolutXY
//    Holt die abolute Bildschirmkoordinate
//========================================================================
sub GetAbsolutXY(
  aHdl    : int;
  var aX  : int;
  var aY  : int);
local begin
  vParent : int;
end;
begin
  WHILE (aHdl<>0) do begin
//debug('add:'+aHdl->wpname+aint(aHdl->wpArea:left));
    aX # aX + aHdl->wpArea:left;
    aY # aY + aHdl->wpArea:Top;

    case (Wininfo(aHdl,_WinType)) of
      _WinTypeDialog : begin
        aX # aX + 8;
        aY # aY + 13;
        RETURN;
      end;

      _WinTypeAppFrame : begin
        aX # aX + 11;
        aY # aY + 82;
      end;
      _WinTypeMdiFrame : begin
        aX # aX + 8;
        aY # aY + 13;
      end;
    end;
    aHdl # WinInfo(aHdl, _WinParent);
  END;
end;


//========================================================================
// SetWindowArea
//              Setzt die Position eines Fenster und rückt es in den sichtbaren
//              Bereich
//========================================================================
sub SetWindowArea(
  aHdl    : int;
  aX      : int;
  aY      : int;
  aXX     : int;
  aYY     : int;
)
local begin
  vRect   : rect;
end;
begin

  vRect # RectMake(aX,aY,aX+aXX,aY+aYY);
  WHILE (vRect:Right>gFrmMain->wpAreaRight-20) do begin
    vRect:Right       # vRect:Right-10;
    vRect:Left        # vRect:Left-10;
  END;
  WHILE (vRect:Bottom>gFrmMain->wpAreaBottom-30) do begin
    vRect:Top         # vRect:Top-10;
    vRect:Bottom      # vRect:Bottom-10;
  END;
  aHdl->wpArea # vRect;

/***
  aHdl->wpAreaLeft          # aX+50;
  aHdl->wpAreaTop           # aY+120;
  aHdl->wpAreaRight         # aHdl->wpAreaLeft + aXX;
  aHdl->wpAreabottom        # aHdl->wpAreaTop + aYY;
  WHILE (aHdl->wpAreaRight>gFrmMain->wpAreaRight-20) do begin
    aHdl->wpAreaRight       # aHdl->wpAreaRight-10;
    aHdl->wpAreaLeft        # aHdl->wpAreaLeft-10;
  END;
  WHILE (aHdl->wpAreaBottom>gFrmMain->wpAreaBottom-30) do begin
    aHdl->wpAreaTop         # aHdl->wpAreaTop-10;
    aHdl->wpAreaBottom      # aHdl->wpAreaBottom-10;
  END;
***/
end;


//========================================================================
// ObjSetPos
//
//========================================================================
sub ObjSetPos(
  aObj                  : int;        // Name des Mdi-Fensters
  aX                    : int;
  aY                    : int;
  opt aXX               : int;
  opt aYY               : int;
)
local begin
  tMdi                : int;          // Deskriptor des Fensters
  tPosRight           : int;          // Rechte Position
  tPosBottom          : int;          // Untere Position
  vFrmWidth           : int;          // Breite des Hauptfensters
  vFrmHeight          : int;          // Länge des Hauptfensters
  vRect               : rect;
end

begin

  if (aX<0) or (aY<0) or (aXX<0) or (aYY<0) then RETURN;

  // Fensterpostion einstellen
  vFrmWidth  # aObj->wpAreaRight - aObj->wpAreaLeft;
  vFrmHeight # aObj->wpAreaBottom - aObj->wpAreaTop;
/*
  vRect:Left    # aMdi->wpAreaLeft;
  vRect:Right   # aMdi->wpAreaLeft;
  vRect:Top     # aMdi->wpAreaTop;
  vRect:Bottom  # aMdi->wpAreabottom;
*/

  vRect # aObj->wparea;
  if (aX<>0) then begin
    vRect:Left   # aX;
    if (aXX=0) then
      vRect:Right  # vFrmWidth + aX
    else
      vRect:Right  # aX + aXX;
  end
  else if (aXX<>0) then begin
    vRect:Right  # aX + aXX;
  end;


//  if (aY<>0) then begin
//    vRect:Top    # aY;
//    vRect:Bottom # vFrmHeight + aY;
//  end;


  if (aY<>0) then begin
    vRect:Top    # aY;
    if (aYY=0) then
      vRect:Bottom # vFrmHeight + aY
    else
      vRect:Bottom # aY + aYY;
  end
  else if (aYY<>0) then begin
    vRect:Bottom # aY + aYY;
  end;


  aObj->wparea # vRect;
end;


//========================================================================
// MdiOptSize
//            Fenster wird auf die optimale Grösse und -position geändert.
//========================================================================
sub MdiOptSize (
  aMdi                  : int;        // Name des Mdi-Fensters
)
begin

  if (aMdi <> 0) then begin
    // Fensterpostion einstellen
    ObjSetPos(aMdi,15,0);
  end;
end;


//========================================================================
//  OpenMDI
//
//========================================================================
sub OpenMDI(
  aParent         : int;
  aName           : alpha;
  aMode           : int;
  opt aFixedSize  : logic) : int;
local begin
  vMdi    : int;
  vVar    : int;
  vHdl    : int;
  vHdl2   : int;
  vName   : alpha;
  vActMDI : int;
  vSoll   : int;
end;
begin

//debug('OPENMDI '+aName+' mit gMDI:'+gMDI->wpname+'   '+w_name);
  vActMDI # gMDI;
  vVar # VarInfo(WindowBonus);

  if (aParent<>gFrmMain) then begin
    vSoll # cnvia(aParent->wpCustom);
    if (vSoll<>0) then begin
      if (vSoll<>vVar) then begin
Lib_Debug:Protokoll('!!!DEBUG_ENDE','AddChildWindow beim falschen:'+aParent->wpname+' -> '+aName+' aber '+w_Name);
      Msg(99,'Fehler beim Fensteröffnen (2)!',0,0,0);
//      varInstance(WindowBonus, vSoll);
//      vVar # vSoll;
      end;
    end;
  end;


  WinEvtProcessSet(_winevtall,n);
  WinEvtProcessSet(_WinEvtInit,y);
  WinEvtProcessSet(_WinEvtMdiActivate,y);

  // 15.12.2014: auch diese Events, für "App_Main_Subs:SStartVerwaltung" von z.B. BA1.Qck.Saegen
  WinEvtProcessSet(_WinEvtCreated,y);
  WinEvtProcessSet(_WinEvtFocusInit,y);

  // ggf. anderes Objekt benutzen
  vName # GetAlternativeName(aName);

//aMode # aMode | _WinaddHidden;
  vMdi # WinAddByName(gFrmMain, vName, aMode);
  if (vMDI<=0) then begin
    vMdi # WinAddByName(gFrmMain, aName, aMode);
    if (vMDI<=0) then begin
      TODO('DIALOG '+aName+' NICHT GEFUNDEN!');
      WinHalt();
    end;
  end;

  // 08.02.2013:
  Help_Main:AddButton(aName, vMDI);

//winsleep(2000);
  // 23.09.2009 MS "Beweglichkeit der Toolbar abschalten"
  //if(vMdi->winsearch('Std.Windowsbar') > 0) then begin
  if(vMdi->winsearch('*Windowsbar') > 0) then begin
    vHdl # vMdi->winsearch('*Windowsbar');
    vHdl->wpFloatable # false;
  end;
  // --------

  vHdl # vMdi->winsearch('NB.Main');
  if (vHdl<>0) then begin
    vHdl2 # vMdi->winsearch('NB.List');
    if (vHdl2<>0) then vHdl->wpcurrent # 'NB.List';
  end;
  WinEvtProcessSet(_winevtall,y);

  if (aParent<>0) and (aParent<>gFrmMain) then w_Parent # vMdi;

  // Aufrufer merken
  if (vActMDI<>gMdiMenu) and
    (vActMDI<>gMdiNotifier) and
    (vActMDI<>gMdiWorkbench) then w_AufruferMDI # vActMDI;

  if (aFixedSize=false) then begin
  // 07.08.2012 AI
    RecallWindow(vMdi); // Usersettings wiederherstellen
//  MdiOptSize(vMdi); deaktiviert 09.08.2012 AI
  end;

  varInstance(WindowBonus, vVar);
  if (vSoll<>0) and (vSoll<>vVar) then
    VarInstance(WindowBonus, vSoll);

  if (aParent<>0) and (aParent<>gFrmMain) then
    w_Child # vMdi;

//  MdiOptSize(vMdi);
//  RecallWindow(vMdi); // Usersettings wiederherstellen

  RETURN vMdi;
end;


//========================================================================
//  ReOpenMDI
//
//========================================================================
sub ReOpenMDI(aMDI : int);
local begin
  vMdi : int;
  vVar : int;
end;
begin
  vVar # VarInfo(WindowBonus);


  // bisher kein Aufufer? nein, dann diesen mal nehmen
  if (w_AufruferMDI=0) then w_aufruferMDI # gMDI;
  
  // 27.08.2019 AH:
  if (varInfo(WindowBonus)=0) then RETURN;
  if (HdlInfo(aMDI,_hdlExists)=0) then RETURN;
  if (cnvia(aMDI->wpcustom)=0) then RETURN;
  if (HdlInfo(cnvia(aMDI->wpCustom), _HdlExists)=0) then RETURN; // 28.01.2021 AHGWS

  REPEAT
    varInstance(WindowBonus, cnvia(aMDI->wpcustom));
    if (w_child<>0) then aMDI # w_Child;
  UNTIL (w_child=0);

  varInstance(WindowBonus, vVar);

//  aMdi->WinFocusSet(true);
  WinUpdate(aMDI, _winupdactivate);

  RETURN;
end;


//========================================================================
//  AddChildWindow
//
//========================================================================
sub AddChildWindow(
  aParent       : int;
  aName         : alpha;
  opt aProc     : alpha;
  opt aMuendig  : logic;
  opt aNoList   : logic;
  opt aContext  : alpha;
  opt aTermPara : alpha) : int;
local begin
  vMdi  : int;
  vHdl  : int;
  vVar  : int;
  vFoc  : int;
  vX    : int;
  vY    : int;
  vName : alpha;
  vSoll : int;
end;
begin

  if (HdlInfo(aParent,_hdlExists)=0) then RETURN 0;

  WinEvtProcessSet(_winevtTimer,false);

  // bisherige Daten merken
  vVar # VarInfo(WindowBonus);
  vSoll # cnvia(aParent->wpCustom);
  if (aParent<>gFrmMain) then begin
    vSoll # cnvia(aParent->wpCustom);
    if (vSoll<>0) then begin
      if (vSoll<>vVar) then begin
Lib_Debug:Protokoll('!!!DEBUG_ENDE','AddChildWindow beim falschen:'+aParent->wpname+' -> '+aName+' aber '+w_Name);
      Msg(99,'Fehler beim Fensteröffnen (2)!',0,0,0);
//      varInstance(WindowBonus, vSoll);
//      vVar # vSoll;
      end;
    end;
  end;


  if (aParent<>0) and (aParent<>gfrmMain) then vFoc # Winfocusget();
  if (aParent<>0) then begin
    if (aParent<>gMdiWorkbench) and
      (aParent<>gMDiMenu) and
      (aParent<>gMdiNotifier) then begin
      vX # aParent->wpAreaLeft;
      vY # aParent->wpAreaTop;
    end;
  end;
  w_LastFocus   # vFoc;

  // ggf. anderes Objekt benutzen
  vName # GetAlternativeName(aName);

  // speziell für Adressverwaltung
  if (vName='Adr.Verwaltung') and (Set.DokumentePFad='CA1') then vName # vName + '2';


  // anderer Kontext? (andere INI Datei)
  if (aContext<>'') then Context # StrCnv(aContext,_StrUpper);

  // neues Fenster laden
  vMDI # WinOpen(vName);
  if (vMDI<=0) then begin
    vMDI # WinOpen(aName);
    if (vMDI<=0) then begin
      TODO('DIALOG '+aName+' NICHT GEFUNDEN!');
      WinHalt();
    end;
  end;

  // 08.02.2013:
  Help_Main:AddButton(aName, vMDI);


//  vMDI # WinOpen(aName);

  if (aParent<>0) and (aParent<>gFrmMain) and (aParent<>gMdiNotifier) then begin
    w_Parent # aParent;
  end;
  w_NoList # aNoList;
  if (aNoList) then w_NoClrList # Y;
  ObjSetPos(vMDI,vX+15,vY+15);


  w_AuswahlMode   # !(aMuendig);
  w_TermProc      # aProc;
  w_TermProcPara  # aTermPara;

  varInstance(WindowBonus, vVar);
  if (vSoll<>vVar) and (vSoll<>0) then
    VarInstance(WindowBonus, vSoll);

  // Child eintragen
  if (aParent<>0) and (aParent<>gMDIMenu) and (aParent<>gFrmMain) and (aParent<>gMdiNotifier) then begin
    w_Child # vMdi;
  end;

  // Parent deaktivieren
  if (aParent<>gFrmMain) and (aParent<>gMDIMenu) and (aParent<>gMdiNotifier) then
    aParent->wpdisabled # true;
  
  if (gZLList<>0) then gZLList->wpdisabled # true;

  // 23.09.2009 MS "Beweglichkeit der Toolbar abschalten"
  //if(w_Child->winsearch('Std.Windowsbar') > 0) then begin
  if(vMdi->winsearch('*Windowsbar') > 0) then begin
    vHdl # vMdi->winsearch('*Windowsbar');
    vHdl->wpFloatable # false;
  end;
  // --------

  RETURN vMdi;
end;


//========================================================================
//  RunChildWindow
//
//========================================================================
sub RunChildWindow(
  aChild      : int;
  opt aParent : int;
  opt aOpt    : int;
  );
local begin
  Erx         : int;
  vDLSort     : int;
  vFilter     : int;
  vX          : int;
  vA          : alpha;
end;
begin

//RecallWindow(aChild);
  WinEvtProcessSet(_winevtall,n);
  WinEvtProcessSet(_WinEvtMdiActivate,y);
  WinEvtProcessSet(_WinEvtFocusInit,y);
  WinEvtProcessSet(_WinEvtCreated,y);

//debug('>>>>>>>>>>>>>>>>>>>>>>>');
/***/

  // 29.08.2013 AH: etwsa später machen...
//  WinEvtProcessSet(_WinEvtPosChanged,y);

  aOpt # aOpt | _WinAddHidden;
  if (aParent<>0) then aParent -> WinAdd(aChild,aOpt)
  else gFRMMain -> WinAdd(aChild,aOpt)

  // 29.08.2013 AH:
  WinEvtProcessSet(_WinEvtPosChanged,y);

  RecallWindow(aChild);
  aChild->winupdate(_WinUpdOn);

/***
  if (aParent<>0) then aParent -> WinAdd(aChild,aOpt)
  else gFRMMain -> WinAdd(aChild,aOpt)
***/

  // andere Sortierung?

  if (gZLList<>0) then begin
    if (gKey<>0) and (gZLList->wpDbKeyNo<>gKey) then begin
      vDLSort # aChild->winSearch('DL.Sort');
      if (vDLSort<>0) then begin
        vDLSort->wpautoupdate # false;
        // Sortiermenü setzen
        vDLSort->WinLstDatLineRemove(_WinLstDatLineAll);
        vFilter # RecFilterCreate(901,2);
        RecFilterAdd(vFilter,1,_FltAND, _FltEq, gFile);
        Erx # RecRead(901,2,_RecFirst,vFilter);
        WHILE (Erx=_rOk) do begin
          vX # vX + 1;
          vDLSort->WinLstDatLineAdd(Prg.Key.Name);
//          vDLSort->WinLstCellSet(CnvAI(Prg.Key.Key),2,_WinLstDatLineLast);
//          if (gKey=Prg.Key.Key) then vDLSort->wpcurrentint # vX;
        if (Prg.Key.EchteKeyNr=0) then Prg.Key.EchteKeyNr # Prg.Key.Key;
        vA # CnvAI(Prg.Key.Key,_fmtNumLeadZero,0,3)+'|'+CnvAI(Prg.Key.EchteKeyNr,_fmtNumLeadZero,0,3)+'|'+Prg.Key.SuchProzedur;
        $DL.Sort->WinLstCellSet(vA,2,_WinLstDatLineLast);
        if ((gKeyID<>0) and (gKeyID=Prg.Key.EchteKeyNr)) or
          ((gKeyID=0) and (gKey=Prg.Key.Key)) then begin
          vDLSort->wpcurrentint # vX;
          gSuchProc # Prg.Key.SuchProzedur;
        end;


          Erx # RecRead(901,2,_RecNext,vFilter);
        END;
        RecFilterDestroy(vFilter);
//xx
        ZLSetSort(gKey, gKeyID);         // Sortierung setzen

        vDLSort->Winupdate(_WinUpdOn,_WinLstRecEvtSkip);
      end;
    end;
  end;

  WinEvtProcessSet(_winevtall,y);

//debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

end;


//========================================================================
//  RlsSetSort DEAKTIVIERT
//              Setzt die Sortierung einer ZL
//========================================================================
sub ___RlsSetSort(
  aObj  : int;
  aSort : int;
  )
local begin
  vHdl : int;
end;

begin


  RETURN;

  // Erstes Objekt ermitteln
  vHdl # aObj->WinInfo(_WinFirst);
  WHILE (vHdl > 0) and (vHdl->WinInfo(_WinType)=_WinTypeListColumn) do begin
    if (CnvIA(vHdl->wpCustom)<>aSort) then begin
      vHdl->wpClmColFg # _WinColBlack;
    end
    else begin
      vHdl->wpClmColFg # _WinColLightBlue;
    end;
    vHdl # vHdl->WinInfo(_WinNext);
  END;
end;


//========================================================================
// GetRecListString
//========================================================================
sub GetRecListSort(
  aOName  : alpha;
) : alpha
local begin
  vX      : int;
  vA      : alpha;
end;
begin
  // Block suchen
  vX # TextSearch(gUserINI, 1, 1, _TextSearchtoken, '<RecList name='+aOName+'>');
  if (vX=0) then RETURN '';

  vX # vX + 1;
  vA # TextLineRead(gUserINI, vX, 0);
  if (vA=*'Sort=*') then RETURN vA;

  RETURN '';
end;


//========================================================================
//  ReCallList
//              Holt sich ggf. die Usereinstellungen einer ZL
//========================================================================
sub RecallList(
  aObj        : int;
  opt aPrefix : alpha;
  opt aOName  : alpha;
)
local begin
  vHdl    : int;
  vOName  : alpha;
  vX      : int;
  vA      : alpha;
  vB      : alpha;
  vTyp    : int;
  vFixed  : int;
end;

begin

  if (aObj=0) then RETURN;

  vTyp # aObj->WinInfo(_Wintype);

  aObj->wpautoupdate # false;
  aObj->wpvisible    # false;

  // Block suchen
  vOName # aObj->wpName;
  if (aOname<>'') then vOname # aOName;
  if (Context<>'') then begin
    if (Strcut(Context,1,1)<>'-') then
      vOName # vOName+'.'+Context
    w_Context # Context;
//    Context # ''; RecallWindows macht das
    // Reihenfolge QB, List, Windows
  end;
  vOName # aPrefix + vOName;

//debug('LOAD '+vOName);

  vX # TextSearch(gUserINI, 1, 1, _TextSearchtoken, '<RecList name='+vOName+'>');
  if (vX<>0) then begin
    vX # vX + 1;
    vA # TextLineRead(gUserINI, vX, 0);

    // Sort
    if (vTyp<>_WinTypeDataList) then begin
      vB # StrCut(vA, StrFind(vA,'Sort=',1)+5, 99);
      // 100 | 1
      if (StrFind(vB,'|',0)>0) then begin
        gKeyID # cnvia(Str_Token(vB,'|',1));
        vB    # Str_Token(vB,'|',2);
        gKey  # cnvia(vB);
        if (gKeyID=999) then gKeyId # gKey;
      end
      else begin    // alt
        gKey            # CnvIA(vB);
        gKeyID          # gKey;
      end;
      if (gKey>100) then gKey # 0;
      if (aObj->wpDbLinkFileNo=0) then begin
        aObj->wpDBKeyNo # CnvIA(vB);
      end;

      vX # vX + 1;
      vA # TextLineRead(gUserINI, vX, 0);
    end;

    WHILE (vA<>'</RecList>') do begin
//debugx('Read '+vA);
      vB # Str_Token(vA,',',1);
      vHdl # aObj->WinSearch(vB);
      if (vHdl<>0) then begin
        // Breite setzen
        vB # Str_Token(vA,',',3);
        vHdl->wpClmwidth # Max(CnvIA(vB), 10);

        // Reihenfolge setzen
        vB # Str_Token(vA,',',2);
        vHdl->wpClmOrder # CnvIA(vB);

        // Spaltenfixierung [06.10.2010/PW]
        vB # Str_Token(vA,',',4);
        if ( vB != '' ) then begin
          vHdl->wpClmFixed # CnvIA(vB);

          if ( vHdl->wpClmFixed != _winClmFixedNone ) then
            vFixed # vFixed + 1;
        end;
      end;

      vX # vX + 1;
      vA # TextLineRead(gUserINI, vX, 0);
    END;

    // Spaltenfixierung [30.09.2010/PW]
    if ( vFixed != 0 ) then
      aObj->wpCustom # '_FIXED' + CnvAI( vFixed );
  end;

  if (vTyp<>_WinTypeDataList) then begin
    if (aObj->wpDbFilter=0) then
      if (gKey=0) then gKey # 1;
  end;

  aObj->wpautoupdate # true;
  aObj->wpvisible    # true;

end;


//========================================================================
//  RecallWindow
//        Liest die Fenstergrößen und Positionen userbezogen ein
//========================================================================
sub RecallWindow ( aObj : handle; )
local begin
  vOName  : alpha;
  vX      : int;
  vA      : alpha;
  vB      : alpha;

  vHdl    : int;
  vVar    : handle;
  vRect   : rect;
  vMaxX   : int;
  vMaxY   : int;
  vW,vH   : int;
end;
begin

  if ( aObj = 0 ) then RETURN;
//  if (w_Obj2Scale=0) then RETURN;
//debugx('recall '+aObj->wpname);
  vVar # VarInfo(WindowBonus);


  // Block suchen
  vOName # aObj->wpName;
  if ( Context <> '' ) then begin
    if ( Strcut( Context, 1, 1 ) != '-' ) then
      vOName # vOName + '.' + Context
    w_Context # Context;
    Context   # '';
  end;

  if (HdlInfo(cnvia(aObj->wpcustom),_HdlExists)=0) then RETURN;   // 13.08.2015

  VarInstance(Windowbonus, cnvia(aObj->wpcustom));
  vHDL # w_Obj2Scale;
  if (vVar<>0) then
    VarInstance(Windowbonus, vVar);
//debugx('LOAD '+vONAme);
  vX # gUserINI->TextSearch( 1, 1, _textSearchToken, '<Window name=' + vOName + '>' );
  if ( vX != 0 ) then begin
    // Position...
    vA                 # gUserINI->TextLineRead( vX + 1, 0 );
//debugx('load XY:'+Str_Token( vA, ',', 4 )+'/'+Str_Token( vA, ',', 1));

    vRect:Top    # CnvIA( Str_Token( vA, ',', 1 ) );
    vRect:Right  # CnvIA( Str_Token( vA, ',', 2 ) );
    vRect:Bottom # CnvIA( Str_Token( vA, ',', 3 ) );
    vRect:Left   # CnvIA( Str_Token( vA, ',', 4 ) );
/* 2022-09-14 AH  : Versuch, alles "in Sichtweite" zu öffnen
    vW # vRect:Right - vRect:Left;
    vH # vRect:Bottom - vRect:Top;
//debugx(aObj->wpname+' : '+vA+' = '+aint(vW)+'/'+aint(vH));
//debug('appframeR:'+aint(gFrmMain->wparea:right)+' | '+aint(gFrmMain->wpAreaRight)+' | '+aint(gFrmMain->wpAreaWidth));
    vMaxX # gFrmMain->wpareaWidth;
    vMaxY # gFrmMain->wpareaHeight;
    if (1=2) and (aObj<>gFrmMain) then begin
      if (vRect:Left>vMaxX) then begin
        vRect:Left # vMaxX - vW;
debugx('resetLeft');
      end;
      if (vRect:Top>vMaxY) then begin
        vRect:Top # vMaxY - vH;
debugx('resetTop');
      end;
    end;
//debugx('Max:'+aint(vMaxX)+'/'+aint(vMaxY));
    vRect:Bottom # vRect:Top + vH;
    vRect:right  # vRect:left + vW;
*/
    aObj->wpArea # vRect;

    // Zoomfaktor...
    vA                 # gUserINI->TextLineRead( vX + 2, 0 );
    if (vA<>'</Window>') then begin
      w_ZoomX # cnvfa(Str_Token( vA, ';', 1 ) );
      w_ZoomY # cnvfa(Str_Token( vA, ';', 2 ) );
      // 01.12.2017 AH:
      if (w_ZoomX=0.0) then w_ZoomX # 1.0;
      if (w_ZoomY=0.0) then w_ZoomY # 1.0;
      if (w_Zoomx<>1.0) or (w_ZoomY<>1.0) then begin
//if (w_Name<>vOName) then
//debug('global '+w_name+': open with INI of: '+vOName+' '+vA);
//        ScaleObjects(w_Obj2Scale, n);
        ScaleObjects(vHDL, n);
      end;

      // Hier der Split Restore UN 02.03.2022
       Recall_Splits(aobj, voname)

    end;
  end;

end;


//========================================================================
//  RememberList
//                Speichert die Zugriffslisteneinstellungen Userbezogen ab
//========================================================================
sub RememberList(
  aObj          : int;
  opt aPrefix   : alpha;
)
local begin
//  vBuf    : int;
  vHdl    : int;
//  vName   : alpha;
  vOName  : alphA;
  vX      : int;
  vTyp    : int;
  vSort   : alpha;
end;

begin
  if (aObj=0) then RETURN;
  if (HdlInfo(aObj, _HdlExists)=0) then RETURN; // 28.01.2021 AHGWS
  vTyp # aObj->WinInfo(_Wintype);

  vOName # aObj->wpName;
  if (w_Context<>'') then
    if (Strcut(w_Context,1,1)<>'-') then
      vOName # vOName+'.'+w_Context
  vOname # aPrefix + vOname;

  if (vTyp<>_WinTypeDataList) then begin
//    if (aObj->wpDBLinkFileNo<>0) then vSort # 'Sort=1|1'
//    else
    vSort # GetRecListSort(vOName);
  end;
  
  // alten Block löschen
  Usr_Data:INIKillBlock('<RecList name='+vOName+'>', '</RecList>');
//debug('SAVE '+vOName);
  //neuen Block anlegen
  TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, '<RecList name='+vOName+'>', _TextLineInsert);

  // 21.06.2022 AH
  if (vTyp<>_WinTypeDataList) then begin
    if (aObj->wpDBLinkFileNo=0) then
      vSort # 'Sort='+aint(gKeyID)+'|'+AInt(aObj->wpDBKeyno);
    if (vSort='') then vSort # 'Sort=1|1';
    TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, vSort, _TextLineInsert);
  end;

  vHdl # aObj->WinInfo(_WinFirst);
  WHILE (vHdl > 0) and (vHdl->WinInfo(_WinType)=_WinTypeListColumn) do begin
    TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1,(vHdl->wpName)+','+AInt(vHdl->wpClmOrder)+','+AInt(vHdl->wpClmWidth)+','+AInt(vHdl->wpClmFixed), _TextLineInsert);
    vHdl # vHdl->WinInfo(_WinNext);
  END;
  TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1,'</RecList>', _TextLineInsert);

  // Text sichern & beenden
  Usr_Data:SaveINI();

end;


//========================================================================
//  RememberWindow
//        Speichert die Fenstergrößen und Positionen userbezogen ab
//========================================================================
sub RememberWindow ( aObj : handle; )
local begin
  vOName  : alpha;
  vX,vY   : int;
  vXX,vYY : int;
  vHdl    : int;
  vMyBon  : int;
  vA      : alpha(200);
end;
begin
  if ( aObj = 0 ) then
    RETURN;

  if (HdlInfo(aObj,_HdlExists)=0) then RETURN;  // 27.01.2017
  vOName # aObj->wpName;

  // 05.11.2021 AH : bei USER kommt es vor, dass das Appframe OHNE WindowBonus geschlossen wird -> dann hier was faken
  if (VarInfo(Windowbonus)=0) then begin
    vMyBon # VarAllocate(Windowbonus);
  end;
  
  if ( w_Context <> '' ) then begin
    if ( Strcut( w_Context, 1, 1 ) != '-' ) then
      vOName # vOName + '.' + w_Context
  end;

  // alten Block löschen
  Usr_Data:INIKillBlock('<Window name='+vOName+'>', '</Window>');

  // neuen Block anlegen
  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '<Window name=' + vOName + '>', _textLineInsert );

  // 0,281,692,-2     OK
  // -21,281,671,-2   hoch

  vY # aObj->wpAreaTop;
  vXX # aObj->wpAreaRight;
  vYY # aObj->wpAreaBottom;
  vX # aObj->wpAreaLeft;
  // in sichtbaren Bereich schieben...    09.12.2020 AH
  if (vY<0) then begin
    vYY # vYY - vY;
    vY  # 0;
  end;
  if (vX<0) then begin
//debugx('Unterlauf!');
    vXX # vXX - vX;
    vX # 0;
  end;

  // Position... TOP,RIGHT,BOTTOM,LEFT
  vA # AInt( vY ) + ',' + AInt( vXX ) + ',' + AInt( vYY ) + ',' + aInt( vX )
  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
//debugx('SAVE '+vOname);
//debugx(vOname+' top,rgh,bot,lft: '+vA);
//debug('appframe L:'+aint(gFrmMain->wparea:left)+' | '+aint(gFrmMain->wpAreaLeft)+' | '+aint(gFrmMain->wpAreaWidth));
//debug('appframe R:'+aint(gFrmMain->wparea:right)+' | '+aint(gFrmMain->wpAreaRight)+' | '+aint(gFrmMain->wpAreaWidth));

  // Zoomfaktor...
  if (w_Name<>aObj->wpname) then begin
    vHdl # VarInfo(WindowBonus);
    VarInstance(WindowBonus,cnvIA(aOBJ->wpcustom));
  end;

  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, cnvaf( w_ZoomX ) + ';' + cnvaf( w_ZoomY ), _textLineInsert );
// 21.06.2022 AH später  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '</Window>', _textLineInsert );


  // zum schluss die Split.Section
  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '<WindowSplits name=' + vOName +'>', _textLineInsert );
  Save_Windows_Splits( aobj, voname )
  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '</WindowSplits name=' + vOName + '>', _textLineInsert );
  // Ende Split Sektion

  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '</Window>', _textLineInsert );

  if (vHdl<>0) then
    VarInstance(WindowBonus,vHDL);

  // Text sichern
  Usr_data:SaveINI();

  if (vMyBon<>0) then
    VarFree(WindowBonus);
end;



//========================================================================
//  ZLSetSort
//            Sortierung für Quicksearch setzen
//========================================================================
sub ZLSetSort (
  aKey        : int;
  opt aKeyLfd : int )
local begin
  Erx       : int;
  vHdl      : int;
  vDLSort   : int;
  vEdSort   : int;
  vA        : alpha;
  vX        : int;
  vSel      : int;
  vSel2     : int;
  vSelName  : alpha;
  vPrgr     : handle;
  vInst     : int;
  vOK       : logic;
  vKeyLfd   : int;
  vKey      : int;
end;
begin

  if ( gZLList = 0 ) or ( gZLList->wpDbLinkFileNo != 0 ) then
    RETURN;
//debug('SETSORT KEY/ID='+aint(aKey)+'/'+aint(aKeyLfd));
  vInst   # VarInfo(WindowBonus);
  vHdl    # gZLList;
  vDLSort # gMDI->WinSearch('DL.Sort');
  vEdSort # gMDI->WinSearch('ed.Sort');

  FOR  vX # 1;
  LOOP vX # vX + 1;
  WHILE ( vDLSort->WinLstCellGet( vA, 2, vX ) ) DO BEGIN
    vKey # 0;
    if (Str_Count(vA,'|')=2) then begin
      vKeyLfd   # CnvIA(Strcut(vA,1,3));    // Nummerierter     z.B. 100
      vKey      # CnvIA(Strcut(vA,5,3));    // physikalischer   z.B. 1
      gSuchProc # Str_token(vA,'|',3);
    end;
    if (vKey=0) then vKey # vKeyLfd;
    if (vKey=0) then vKey # 1;
    if ((aKeyLfd<>0) and (vKeyLfd=aKeyLfd)) or
      ((aKeyLfd=0) and (aKey=vKey)) then begin
      WinLstCellGet( vDLSort, vA, 1, vX );
      vEdSort->wpCaption # vA;
      vOK # y;
      BREAK;
    end;
    
  END;
  if (vOK=false) then begin
    aKeyLfd  # 1;
  end;
  if (vKey=0) then vKey # 1;

  vHdl->WinUpdate( _winUpdOff );

  // ggf. Selektion neu aufbauen und umsortieren
  if ( vHdl->wpDbSelection != 0 ) then begin
    vSel # vHdl->wpDbSelection;
    if ( vSel->SelInfo( _selSort ) != vKey) then begin
      // auf Markierung basierende Selektion
      if ( StrFind( w_SelName, '.MARK', 1 ) > 0 ) then begin
        vX # vSel->SelInfo( _selFile );
        gZLList->wpDbSelection # 0;

        vSel2    # SelCreate( vX, vKey);
        vSelName # Lib_Sel:Save( vSel2, '.MARK' );
        vSel2    # SelOpen();
        vSel2->SelRead( vX, _selLock, vSelName );

        vPrgr # Lib_Progress:Init( 'Sortierung...', RecInfo( vX, _recCount, vSel ) );
        FOR  Erx # RecRead( vX, vSel, _recFirst );
        LOOP Erx # RecRead( vX, vSel, _recNext );
        WHILE ( Erx <= _rLocked ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
          vSel2->SelRecInsert( vX );
        END;
        vPrgr->Lib_Progress:Term();
        vSel->SelClose();

        SelDelete( vX, w_SelName );
        w_SelName # vSelName;
        gZLList->wpDbSelection # vSel2;
      end
      else begin
        // Selektion neustarten
        vSel->SelInfo( _SelSort, vKey);
        vSel->SelRun( _selDisplay | _selServer | _selServerAutoFld );
      end;
    end;
  end;

  vHdl->wpDbKeyNo # vKey;
  vHdl->WinUpdate( _winUpdOn, _winLstFromSelected );

  if (vInst>0) then VarInstance(Windowbonus, vInst);
  //RlsSetSort(vHdl, aKey);
end;


//========================================================================
//  Repos
//
//========================================================================
sub Repos(
  var aMDI  : int;
  aName     : alpha;
  aRecID    : int;
  aView     : logic)
local begin
  vHDL  : Handle;
  vList : Handle;
  vFile : int;
  vNew  : logic;
end;
begin

  if (aMDI<>0) then begin
    VarInstance(WindowBonus,cnvIA(aMDI->wpcustom));
    if (Mode<>c_ModeList) and (Mode<>c_modeView) then begin
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RETURN;
    end;
    vHdl # gZLList->wpDbSelection;
    if (w_SelName<>'') and (vHdl<>0) then begin
      gZLList->wpautoupdate # false;
      gZLList->wpdbselection # 0;
      SelClose(vHdl);
      SelDelete(gFile,w_selName);
    end;
  end
  else begin
    aMDI # Lib_GuiCom:OpenMdi(gFrmMain, aName, _WinAddHidden);
    vNew # y;
  end;

  VarInstance(WindowBonus,cnvIA(aMDI->wpcustom));
  vFile # gFile;
  w_Command   # 'REPOS';
  if (vNew) then w_Command   # 'NEWREPOS';
  w_Cmd_Para  # aInt(aRecId);
  vList # gZLList;
  if (aView) then
    mode # c_modeBald+c_ModeView
  vHdl # Winsearch(aMDI,'NB.Main');
  if (vNew) then begin
    aMDI->WinUpdate(_WinUpdOn);
  end
  else begin
    vHdl->WinFocusSet(true);
    RecRead(gFile,0,_recId, aRecID);
    vList->Winupdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
    aMDI->WinFocusSet(true);
  end;
end;


//========================================================================
//  FindMDI
//
//========================================================================
sub FindMDI(aObj : int) : int
begin
  if (aObj=0) then RETURN 0;

  if (aObj->Wininfo(_WinType)=_WinTypeMdiFrame) then RETURN aObj;

  RETURN FindMDI(aOBj->Wininfo(_WinParent));
end;


//========================================================================
//  AuswahlEnable
//                Aktiviert ein Feld zur Auswahl
//========================================================================
sub AuswahlEnable(
  aObj      : int;
)
local begin
  d_MenuItem : int;
end;
begin

  // 06.05.2013: nur bei beschreibbaren Feldern!
//  if (aObj->wpreadonly) then RETURN;
  if (aObj->wpColBkg=c_ColInactive) then RETURN;

  if (aObj->Wininfo(_WinType)=_WinTypeCheckbox) then begin
    aObj->wpColBkg # _WinColRed;
  end
  else begin
    aObj->wpColFocusBkg # _WinColRed;
    aObj->wpColFocusFg  # _WinColLightYellow;
  end;
  d_MenuItem # gMenu->WinSearch('Mnu.Auswahl');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled # false;
  d_MenuItem # gMenu->WinSearch('Mnu.SelAuswahl');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled # false;
end;


//========================================================================
//  AuswahlDisable
//                  Deaktiviert ein Feld zur Auswahl
//========================================================================
sub AuswahlDisable(
  aObj  : int;
)
local begin
  d_MenuItem : int;
end;
begin
//  aObj->wpColFocusBkg # _WinColParent;

  // 24.07.2014 + 19.08.2014 AH
  if (aObj->Wininfo(_WinType)<>_WinTypeCheckbox) and (aObj->Wininfo(_WinType)<>_WinTypeRtfEdit) then begin
    aObj->wpColFocusFg  # _WinColparent;
  end;


  d_MenuItem # gMenu->WinSearch('Mnu.Auswahl');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled # true;
  d_MenuItem # gMenu->WinSearch('Mnu.SelAuswahl');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled # true;

end;


//========================================================================
//  Enable
//          Aktiviert ein Feld
//========================================================================
sub Enable(
  aObj  : int;
)
local Begin
  x : int;
end;
begin
  if (aObj=0) then RETURN;
//debugx('enable:'+aObj->wpname);

  x # (aObj->WinInfo(_WinType));

  if (x=_WinTypeButton) then begin
    if (StrFind(aObj->wpname,'btnRtf',0)<>0) then RETURN;
  end;

  if (x=_wintypeRTFedit) then begin
    aObj->wpReadOnly  # false;
//    aObj->wpColBkgApp # _WinColWindow;
    RETURN;
  end;

  if (x=_WinTypeColorButton) then begin
    aObj->wpdisabled # false;
    RETURN;
  end;
  if ((x=_WinTypeEdit)         or (x=_WinTypeFloatEdit)  or
    (x=_WinTypeIntEdit)      or (x=_WinTypeTimeEdit)   or
    (x=_WinTypeTextEdit)     or (x=_WinTypeDateEdit))  then begin
    if (aObj->wpname<>'jump') then aObj->wpColBkg # _WinColWindow;
    aObj->wpReadOnly # false;
// 20.02.2018 AH: WARUM???
// 04.04.2018 AH: damit TAB darüber hinweg geht
aObj->wpTabstop # true;
    RETURN;
  end;

  aObj->wpDisabled # false;
  
  If (x <> _WinTypeRadioButton) and (x <> _WinTypeCheckBox) and (x<>_WinTypeButton) then begin
    aObj->wpColBkg # _WinColWindow;
    aObj->wpStyleBorder # _WinBorSunken;
  end;
end;


//========================================================================
//  Disable
//          Deaktiviert ein Feld
//========================================================================
sub Disable(
  aObj  : int;
)
local Begin
  x : int;
end;
begin
//debugx('disse:'+aObj->wpname);

  if (aObj=0) then RETURN;
  x # (aObj->WinInfo(_WinType));

  if (x=_WinTypeButton) then begin
    if (StrFind(aObj->wpname,'btnRtf',0)<>0) then RETURN;
  end;

  if (x=_wintypeRTFedit) then begin
    aObj->wpReadOnly  # true;
//    aObj->wpColBkgApp # c_ColInactive;
    RETURN;
  end;

  if (x=_WinTypeColorEdit) then begin
    aObj->wpColBkg # c_ColInactive;
    RETURN;
  end;
  if (x=_WinTypeColorButton) then begin
    aObj->wpdisabled # true;
    RETURN;
  end;

  if (x=_WinTypeEdit)         or (x=_WinTypeFloatEdit)  or
     (x=_WinTypeIntEdit)      or (x=_WinTypeTimeEdit)   or
     (x=_WinTypeTextEdit)     or (x=_WinTypeDateEdit)   then begin
//     aObj->wpAutoUpdate # false;
     aObj->wpReadOnly # true;
// 20.02.2018 AH: WARUM???
// 04.04.2018 AH: damit TAB darüber hinweg geht
aObj->wpTabstop # false;
     if (aObj->wpname<>'jump') then aObj->wpColBkg # c_ColInactive;
//     aObj->wpAutoUpdate # true;
     RETURN;
  end;

  aObj->wpDisabled # true;

end;


//========================================================================
//  Albe
//
//========================================================================
SUB Able(aObj : int; aEnable : logic)
begin
  if (aObj <= 0) then     // ST 2014-02-17: Sicherheitsabfrage
    RETURN;

  winupdate(aObj);        // 10.06.2022 AH
  if (aEnable) then Enable(aObj)
    else Disable(aObj);
end;


//========================================================================
//========================================================================
//========================================================================
sub SMState_Obj(
  aObj : int;
  aStatus : logic;
)
local begin
  x       : int;
  t.iObj  : int;
end;
begin

  WHILE (aObj<>0) do begin
    x # (aObj->WinInfo(_WinType));
    if ((x=_WinTypeEdit)         or (x=_WinTypeFloatEdit)  or
       (x=_WinTypeIntEdit)      or (x=_WinTypeTimeEdit)   or
       (x=_WinTypeTextEdit)     or (x=_WinTypeDateEdit)   or
       (x=_WinTypeButton) or
       (x=_WinTypeRtfEdit) or
       (x=_WinTypeColorButton) or
       (x=_WinTypeRadioButton)  or (x=_WinTypeCheckBox)) then begin
      if (aObj->wpname<>'ed.Suche') and (aObj->wpname<>'ed.Sort') and (aObj->wpname<>'DUMMYNEW') and
       (aobj->wpcustom<>'_ALWAYS') then begin

        //if (aObj->wpcustom<>'_N') then begin
          if (aStatus) and (aObj->wpcustom<>'_N') and (aObj->wpcustom<>'_SKIP') and
            ((aObj->wpcustom<>'_E') or (Mode<>c_ModeEdit)) then begin
            Enable(aObj)
          end
          else begin
            Disable(aObj);
          end;
//        end; //...never

      end;
    end;
    t.iObj # aObj;

    aObj # t.iObj->WinInfo(_WinFirst,0);
    if (aObj<>0) then SMState_Obj(aObj,aStatus);
    aObj # t.iObj->WinInfo(_WinNext,0);
    t.iObj # aObj;
  END;
end;


//========================================================================
sub SMState_Obj2(
  aObj : int;
  aStatus : logic;
)
local begin
  x       : int;
  t.iObj  : int;
end;
begin

  WHILE (aObj<>0) do begin
    t.iObj # HdlLink(aObj);
/*
    if (t.iObj->WinInfo(_WinType)=_WinTypeFloatEdit) then begin
      if (StrFind(t.iObj->wpname,'Dicke',0)<>0) then        t.iObj->wpdecimals  # 3
      else if (StrFind(t.iObj->wpname,'Breite',0)<>0) then  t.iObj->wpdecimals  # 2
      else if (StrFind(t.iObj->wpname,'Laenge',0)<>0) then  t.iObj->wpdecimals  # 1
      else if (StrFind(t.iObj->wpname,'Länge',0)<>0) then   t.iObj->wpdecimals  # 1;
    end;
*/
if (Hdlinfo(t.iObj,_HdlExists)>0) then begin    // 27.08.2019
    if (t.iObj->wpcustom<>'_I') then begin
      if (aStatus) and (t.iObj->wpcustom<>'_N') and (t.iObj->wpcustom<>'_SKIP') and
        ((t.iObj->wpcustom<>'_E') or (Mode<>c_ModeEdit)) then begin
        Enable(t.iObj)
      end
      else begin
        Disable(t.iObj);
      end;
    end;
end;

    aObj # w_Objects->cteread(_ctenext,aObj);
  END;
end;


//========================================================================
//  SetMaskState
//                Dis-/Enabled alle Felder einer Maske
//========================================================================
sub SetMaskState(
  aStatus : logic
)
local begin
  t.iObj : int;
end;
begin
// ennable neu=15, enable alt=30
//if (aStatus) then debugstamp(gMdi->wpname+'  ENABLED')
//else debugstamp(gmdi->wpname+'  DISABLED');
//  gMDI->wpAutoUpdate # false;
//$NB.Main->wpautoupdate # true;
  if (w_objects<>0) then begin
    t.IObj # w_objects->CteRead(_ctefirst);
    SMState_Obj2(t.iobj,aStatus);
  end;

//  t.iObj # gmdi->WinInfo(_WinFirst,0);
//  if (t.iObj<>0) then SMState_Obj(t.iObj,aStatus);
//$NB.Main->wpautoupdate # true;
//  gMDI->wpAutoUpdate # true;
//debugstamp('ENDE---ENDE');
end;


//========================================================================
//  SetWindowState
//                  En-/Disabeld alle Unterobjekte eines Fensters
//========================================================================
sub SetWindowState(
  aObj : int;
  aStatus : logic;
)
local begin
  vx      : int;
  t.iObj  : int;
end;
begin
  RETURN;

  if (aObj=0) then RETURN;

  vX # 0;
  t.iObj # aObj->WinInfo(_Winfirst,0);
  WHILE (t.iObj<>0) do begin
    // Seltsamerweise machen Divider _manchmal_ Schwierigkeiten
    if (t.iObj->WinInfo(_WinType) != _WinTypeDivider ) then
      t.iObj->wpdisabled # !(aStatus);

    aObj # t.iobj->WinInfo(_WinNext,0);
    t.iobj # aObj;
  END;
end;


//========================================================================
//  BuildObjectList
//                  baut eine<Liste aller Unterobjekte des MDIs auf
//========================================================================
sub BuildObjectList(
  aList : int;
  aObj : int;
)
local begin
  x       : int;
  t.iObj  : int;
  vItem   : int;
end;
begin
  WHILE (aObj<>0) do begin
    x # (aObj->WinInfo(_WinType));

    // Quickbar
    if (aOBj->wpname='gt.Quickbar') then begin
      aObj # aObj->WinInfo(_WinNext,0);
      CYCLE;
    end;

    if ((x=_WinTypeEdit)         or (x=_WinTypeFloatEdit)  or
       (x=_WinTypeIntEdit)      or (x=_WinTypeTimeEdit)   or
       (x=_WinTypeTextEdit)     or (x=_WinTypeDateEdit)   or
      (x=_wintypeColorEdit) or
      (x=_WinTypeColorButton) or
       (x=_WinTypeButton) or
       (x=_WinTypeRtfEdit) or
       (x=_WinTypeRadioButton)  or (x=_WinTypeCheckBox)) then begin

      if (aObj->wpname<>'ed.Suche') and (aObj->wpname<>'ed.Sort') and (aObj->wpname<>'DUMMYNEW') and
       (aobj->wpcustom<>'_ALWAYS') then begin
       vItem # cteopen(_cteitem);
       HdlLink(vItem,aObj);
       CteInsert(aList, vItem);
      end;
    end;
    t.iObj # aObj;
    aObj # t.iObj->WinInfo(_WinFirst,0);
    if (aObj<>0) then BuildObjectList(aList,aObj);
    aObj # t.iObj->WinInfo(_WinNext,0);
    t.iObj # aObj;
  END;
end;


//========================================================================
//  ExpandTree
//
//========================================================================
sub ExpandTree(
  aObj : int;
)
local begin
  vx    : int;
  vObj  : int;
end;
begin
  if (aObj=0) then RETURN;

  vX # 0;
  vObj # aObj->WinInfo(_Winfirst,0,_WinTypeTreeNode);
  WHILE (vObj<>0) do begin
    vObj->wpNodeExpanded # y;
    aObj # vobj->WinInfo(_WinNext,0,_WinTypeTreeNode);
    vobj # aObj;
  END;
end;


//========================================================================
//  Translate
//            Übersetze einen Begriff
//========================================================================
sub Gui_Translate ( aName : alpha(1000) ) : alpha;
local begin
  vErg : int
end;
begin

  if ( Set.TranslateYN = n ) or ( gUserSprachnummer = 0 ) or ( aName = '' ) then
    RETURN aName;
  if (StrLen(aName)>64) then RETURN aName;

  RecBufClear( 904 );
  "Prg.ÜSe.Deutsch" # aName;
  if ( RecRead( 904, 1, 0 ) < _rLocked ) then begin
    if      ( gUserSprachnummer = 1 ) and ( "Prg.ÜSe.Sprache1" != '' ) then RETURN "Prg.ÜSe.Sprache1";
    else if ( gUserSprachnummer = 2 ) and ( "Prg.ÜSe.Sprache2" != '' ) then RETURN "Prg.ÜSe.Sprache2";
    else if ( gUserSprachnummer = 3 ) and ( "Prg.ÜSe.Sprache3" != '' ) then RETURN "Prg.ÜSe.Sprache3";
  end;

  RecBufClear( 904 );
  RETURN aName;
end;


//========================================================================
//  TranslateObject
//
//========================================================================
sub TranslateObject ( aObj : int )
local begin
  vObj  : int;
  vType : int;
end;
begin

  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
    vType # vObj->WinInfo( _winType );
    if ( vObj->wpCustom = '_NO_TRANSLATE' ) then
      CYCLE;

    if ( vType = _winTypeListColumn ) then begin
      if ( vObj->wpCustom = 'Menge' )                         then vObj->wpFmtPostComma # "Set.Stellen.Menge";
      else if ( StrFind( vObj->wpName, '.Dicke',   0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Dicke";
      else if ( StrFind( vObj->wpName, '.Breite',  0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Breite";
      else if ( StrFind( vObj->wpName, '.Laenge',  0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Länge";
      else if ( StrFind( vObj->wpName, '.Gew',     0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'gewicht',  0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'Gewicht',  0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'Nettogew', 0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'RID',      0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Radien";
      else if ( StrFind( vObj->wpName, 'RAD',      0 ) != 0 ) then vObj->wpFmtPostComma # "Set.Stellen.Radien";
    end;

    if ( vType = _winTypeFloatEdit ) then begin
      if (      StrFind( vObj->wpName, 'Meng',     0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Menge";
      else if ( StrFind( vObj->wpName, '.Dicke',   0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Dicke";
    //else if ( StrFind( vObj->wpname, '.Höhe',    0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Dicke";
      else if ( StrFind( vObj->wpName, '.Breite',  0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Breite";
      else if ( StrFind( vObj->wpName, '.Laenge',  0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Länge";
    //else if ( StrFind( vObj->wpname, '.Länge',   0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Länge";
    //else if ( StrFind( vObj->wpname, '.Lnge',    0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Länge";
      else if ( StrFind( vObj->wpName, '.Gew',     0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'gewicht',  0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'Gewicht',  0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'Nettogew', 0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Gewicht";
      else if ( StrFind( vObj->wpName, 'RID',      0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Radien";
      else if ( StrFind( vObj->wpName, 'RAD',      0 ) != 0 ) then vObj->wpDecimals # "Set.Stellen.Radien";
    end;

    if ( Set.TranslateYN ) then begin
      if ( vType = _winTypeLabel       or vType = _winTypeGroupBox     or vType = _winTypeButton     or
           vType = _winTypeCheckBox    or vType = _winTypeRadioButton  or vType = _winTypeCheckBox   or
           vType = _winTypeRadioButton or vType = _winTypeNotebookPage or vType = _winTypeListColumn or
           vType = _winTypeTreeNode    or vType = _winTypeToolbarButton ) then begin
        vObj->wpCaption # Translate( vObj->wpCaption );
        vObj->wpHelpTip # Translate( vObj->wpHelpTip );
      end;

      if ( vType = _winTypeEdit     or vType = _winTypeIntEdit  or vType = _winTypeFloatEdit or
           vType = _winTypeTimeEdit or vType = _winTypeDateEdit or vType = _winTypeColorEdit or
           vType = _winTypeTextEdit or vType = _winTypeRTFEdit ) then begin
        vObj->wpHelpTip # Translate( vObj->wpHelpTip );
      end;

      if ( vType = _winTypeMenuItem or vType = _winTypeMdiFrame ) then begin
        vObj->wpCaption # Translate( vObj->wpCaption );
      end;
    end;

    TranslateObject( vObj );
  END;
end;


//=========================================================================
// ZLColorLine
//        Färbt die (aktuelle) Zeile einer Zugriffsliste.
//        Ist aUnfixed true, so werden nur unfixierte Spalten gefärbt. Gibt
//        true zurück, wenn fixierte Spalten vorhanden sind.
//=========================================================================
sub ZLColorLine ( aObj : int; aColor : int; opt aUnfixed : logic ) : logic
local begin
  vCell   : int;
  vEven   : logic;
  vFixed  : int;
  vI      : int;

//  vList   : int;
end;
begin

  if (aObj=0) then RETURN false;

/* TEST 29.04.2013: */
/*
  vList # cnvia($lb.Suche->wpcustom);
  if (vList=0) then begin
    vList # CteOpen(_CteList);
    FOR vCell # aOBJ->WinInfo( _winFirst, 0, _winTypeListColumn );
    LOOP vCell # vCell->WinInfo( _winNext, 0, _winTypeListColumn );
    WHILE ( vCell != 0 ) do begin
      CteInsertItem(vList,'a',vCell,'',_CteLast);
    END;
    $lb.Suche->wpcustom # aint(vList);
  end;

    FOR vI # CteRead(vList,_CteFirst)
    LOOP vI # CteRead(vList,_CteNext,vI)
    WHILE (vI<>0) do begin
      vCell # vI->spID;
      if ( vCell->wpClmFixed != _winClmFixedNone ) then
        CYCLE;

      vCell->wpClmColBkg # aColor;
      if ( vEven ) then begin
        vCell->wpClmColFocusBkg    # aColor;
        vCell->wpClmColFocusOffBkg # aColor;
      end;
      vEven # !vEven;
    END;
RETURN ( vFixed > 0 );
/* ende 29.04.2013 */
***/

  if ( StrCut( aObj->wpCustom, 1, 6 ) = '_FIXED' ) then
    vFixed # CnvIA( StrCut( aObj->wpCustom, 7, 100 ) );
//vFixed # 0;
  if ( !aUnfixed ) and ( vFixed > 0 ) then begin
    // Fixierte Spalten färben
    FOR  vCell # aObj->WinInfo( _winFirst, 0, _winTypeListColumn )
    LOOP vCell # vCell->WinInfo( _winNext, 0, _winTypeListColumn )
    WHILE ( vCell != 0 ) and ( vFixed > 0 ) DO BEGIN
      if ( vCell->wpClmFixed = _winClmFixedNone ) then
        CYCLE;
//      if (vCell->wpCustom='_NOCOL') then CYCLE;   // 26.05.2020 AH
      vCell->wpClmColBkg         # aColor;
      vCell->wpClmColFocusBkg    # aColor;
      vCell->wpClmColFocusOffBkg # aColor;
      vFixed                     # vFixed - 1;
    END;
    RETURN true;
  end
  else begin
    // Unfixierte Spalten färben
    FOR  vCell # aObj->WinInfo( _winFirst, 0, _winTypeListColumn )
    LOOP vCell # vCell->WinInfo( _winNext, 0, _winTypeListColumn )
    WHILE ( vCell != 0 ) do begin //and (vI<14) DO BEGIN
      inc(vI);
      if ( vCell->wpClmFixed != _winClmFixedNone ) then CYCLE;
      if (vCell->wpCustom='_NOCOL') then CYCLE;   // 26.05.2020 AH
//if vCell->wpname<>'clmAuf.Vorgangstyp' then CYCLE;
      vCell->wpClmColBkg # aColor;

      if ( vEven ) then begin
        vCell->wpClmColFocusBkg    # aColor;
        vCell->wpClmColFocusOffBkg # aColor;
      end;
      vEven # !vEven;
    END;
  end;

  RETURN ( vFixed > 0 );
end;


//========================================================================
//  Pflichtfeld
//              Färbt ein Pflichtfeld ggf. gelb ein
//========================================================================
sub Pflichtfeld(
  aObj              : int;
  opt aDeaktiviere  : logic;
)
local begin
  vA  : alpha;
  vOk : logic;
end;
begin

  if (aObj=0) then RETURN;
  if (aObj->wpdisabled=y) then RETURN
// 2022-12-13 AH HWN   if (aObj->wpreadonly) then RETURN;
  if (mode<>c_ModeNew) and (mode<>c_ModeEdit) and
    (mode<>c_ModeNew2) and (mode<>c_ModeEdit2) then RETURN;

  if (aDeaktiviere) then begin
    aObj->wpColBkg # _WinColWindow;
    RETURN;
  end;

  errtrycatch(_ErrNoFld,true);
  errtrycatch(_ErrPropinvalid,true);
  errtrycatch(_ErrFldType,true);
  try begin
    vA # aObj->wpDbFieldName;
    if (vA<>'') then begin
      case (FldInfobyName(vA,_fldType)) of
        _TypeAlpha  : vOk # (FldAlphaByName(vA)<>'');
        _TypeByte   : vOk # (FldintbyName(vA)<>0);
        _TypeDate   : vOk # (FlddateByName(vA)<>0.0.0000);
        _TypeFloat  : vOk # (FldfloatByName(vA)<>0.0);
        _Typeint    : vOk # (FldIntByName(vA)<>0);
        _TypeTime   : vOk # (FldTimebyName(vA)<>0:0);
        _TypeWord   : vOk # (FldWordByName(vA)<>0);
      end;
    end
    else begin
      case (WinInfo(aObj,_Wintype)) of
        _WinTypeEdit      : vOk # (aObj->wpcaption<>'');
        _WinTypeIntEdit   : vOk # (aObj->wpcaptionint<>0);
        _WinTypeDateEdit  : vOk # (aObj->wpcaptiondate<>0.0.0000);
        _WinTypeFloatEdit : vOk # (aObj->wpcaptionfloat<>0.0);
        _WinTypeTimeEdit  : vOk # (aObj->wpcaptiontime<>0:0);
      end;
    end;

    if (vOk) then begin
      if (aObj->wpColBkg<>c_ColInactive) then
        aObj->wpColBkg # _WinColWindow;
    end
    else begin
      aObj->wpcolBkg # _WinColLightYellow;
    end;
  end; // try
end;


//=========================================================================
// FixColumnsEvtMenuContext [06.10.2010/PW]
//        Kontextmenü für Listen mit Spaltenfixierung aufgerufen
//=========================================================================
sub FixColumnsEvtMenuContext (
  aEvt      : event;
  aHittest  : int;
  aItem     : handle;
  aId       : int) : logic
begin
  gSelectedColumn # aItem;
  gSelectedRowID  # aID;
  RETURN true;
end;


//========================================================================
//========================================================================
//====================================================================
// Tree_refresh
// Löscht den * im Baum
//
// ===================================================================
SUB Tree_refresh(
  aNode         : int;
)
local begin
  tNode : int;
end;
begin
  // kein gültiger Knoten-Deskriptor
  if (aNode <= 0) then RETURN;
  // rekursiv alle Kind-Objekte iterieren
  tNode # aNode->WinInfo(_WinFirst);
  WHILE (tNode > 0) do begin
    // rekursiver Aufruf dieser Funktion
     if (strfind(tnode -> wpcaption,'*',1) > 0) then begin
       tnode -> wpcaption # strdel( tnode -> wpcaption,strfind(tnode -> wpcaption,'*',1),1);
     end;
     tree_refresh(tNode);
    tNode # tNode->WinInfo(_WinNext);
  END;
end;


//==============================================================================
// Tree_find_default
// Findet die Speicherung des * in custom und setzt dies zur Caption hinzu
//
//==============================================================================
SUB Tree_find_default(
  aNode         : int;
  sName         : alpha;
  set_          : logic;
  )
local begin
  tNode : int;
  parent  : int;
  parname : alpha;
  s       : alpha;
end;
begin
  // kein gültiger Knoten-Deskriptor
  if (aNode <= 0) then RETURN;
  // rekursiv alle Kind-Objekte iterieren
  tNode # aNode->WinInfo(_WinFirst);
  WHILE(tNode > 0) do begin
    parent # wininfo(tnode,_winparent);
    if (parent -> wpname = 'Favoriten') then begin
      s # parent -> wpname + tnode -> wpname;
    end
    else begin
      s # tnode -> wpname;
    end;
    if (stradj(s,_strall) = stradj(sname,_strall)) then begin
     // anode -> wpcustom # strdel( anode -> wpcustom,strfind(anode -> wpcustom,'*',1),1);
      //WindialogBox(gFrmMain,'TREE',anode -> wpname ,_winicoinformation,_windialogok|_windialogalwaysontop,0);
      if (strfind(tnode -> wpcaption,'*',1) > 0) then begin
        tnode -> wpcaption # strdel( tnode -> wpcaption,strfind(tnode -> wpcaption,'*',1),1);
      end;
      tnode -> wpcaption #  tnode -> wpcaption +'*';
      if (set_ ) then begin
        $TV.Hauptmenue -> wpcurrentint # tnode;
      end;
    end;
    tree_find_default(tNode,sname,set_);
    tNode # tNode->WinInfo(_WinNext);
  end;

  // Änderungen sichtbar machen
   if (aNode->WinInfo(_WinType) = _WinTypeTreeView) then
       aNode->WinUpdate(_WinUpdOn);
end;


//========================================================================
// node_set_default ()
// Setzt den Defaultknoten
//
//========================================================================
sub node_set_default ( sdesc : int;)
local begin
   vHdl       : int;
   ierr       : int;
   vrecflag   : int;
   vHdlNode   : int;
   firstnode  : int;
   parent     : int;
end;
begin
  vHdl              # sdesc->wpcurrentint;
  firstnode # sdesc -> wininfo(_winfirst);
  Tree_refresh(sdesc);
  Usr.Username #  gUserName   ;
  ierr # recread(800,1,_reclock);
  if (ierr = _rok) then begin
    parent # vhdl -> wininfo(_winparent)
    if ( parent -> wpname  <> 'Favoriten') then begin
      usr.tree.default  # vhdl -> wpname;
    end
    else begin
      usr.tree.default  # 'Favoriten'+vhdl -> wpname;
    end;
    ierr # recreplace(800,_recunlock);
  end;
  Usr_data:RecReadThisUser();

   // WindialogBox(gFrmMain,'TREE',user.tree.default + ' User' +uname ,_winicoinformation,_windialogok|_windialogalwaysontop,0);
  vhdl -> wpcustom # /*vhdl -> wpcustom + */  usr.tree.default ; // '*';
  vhdl -> wpcaption # vhdl -> wpcaption + '*';
 // vhdl -> winfocusset();
end;


//=======================================================================
// node _del_default
// Löscht den Defaultknoten
//
//=======================================================================
sub node_del_default ( sdesc : int;)
local begin
   vHdl       : int;
   ierr       : int;
   vrecflag   : int;
   vHdlNode   : int;
   parent     : int;
end;
begin
  vHdl #  sdesc->wpcurrentint;
  Usr.Username #  gUserName   ;
  ierr # recread(800,1,_reclock);
  ierr # recread(800,1,_reclock);
  if (ierr = _rok) then begin
   usr.tree.default  # ''; // vhdl -> wpname;
   ierr # recreplace(800,_recunlock);
  end;
  Usr_data:RecReadThisUser();
  vhdl -> wpcaption # strdel(vhdl -> wpcaption,strfind(vhdl -> wpcaption,'*',1),1);
end;


//========================================================================
//  BuildScaleList
//
//========================================================================
sub BuildScaleList(
  aList : int;
  aObj  : int;
)
local begin
  x       : int;
  vObj    : int;
  vItem   : int;
  vRect   : rect;
  vFont   : font;
end;
begin

  // bisher nichts eingetragen? Dann MDI-Fenster aufnehmen
  if (cteInfo(aList,_CteCount)=0) then begin
    vRect # aObj->wparea;
    vItem # cteopen(_cteitem);
    vItem->spcustom # aint(vRect:right-vRect:left)+'|'+aint(vRect:bottom-vRect:Top);
    CteInsert(aList, vItem);
    aObj # aObj->WinInfo(_WinFirst,0);
  end;

  WHILE (aObj<>0) do begin

    x # (aObj->WinInfo(_WinType));

    // eiige Objkete komplett ignorieren...
    if (aObj->wpname='xxxNB.List') or
      (aOBj->wpname='gt.Quickbar') or
      (x=_wintypeToolbardock) or    // 31.08.2012 AI: Toolbardocks nicht mehr resizen
      (x=_WinTypeToolbarRtf) or
      (x=_WinTypeToolbar) or
      (x=_WinTypeTreeNode) or
      (x=_WinTypeListColumn) or
//      (x=_WinTypeRecList) or
      (x=_WinTypeGanttGraph) then begin//or (x=_WinTypeToolbarDock) then begin
      aObj # aObj->WinInfo(_WinNext,0);
      CYCLE;
    end;


  if (x=_WinTypeEdit)         or (x=_WinTypeFloatEdit)  or
     (x=_WinTypeIntEdit)      or (x=_WinTypeTimeEdit)   or
     (x=_WinTypeTextEdit)     or (x=_WinTypeDateEdit)   then
  aObj->WinEvtProcNameSet(_WinEvtMouse, 'App_Main:EvtMouse');


//debug(aObj->wpname);
    if //(x<>_WinTypeNotebook) and
      (x<>_WinTypeNotebookPage) and
        (x<>_WinTypeChromium) and // 2023-02-09 AH
      (x<>_WinTypeGroupSplit) and
      (x<>_WinTypeGroupTile) and
      (x<>60817667) then begin

      vItem # cteopen(_cteitem);
      vItem->spname # cnvai(aObj);
      //vItem->spname # aObj->wpname;
      vRect # aObj->wpArea;
      // mit Font...
      if (x<>_WintypeToolbarDock) and
        (x<>_WinTypeRecList) and (x<>_WinTypePrtJobPreview) and
        (x<>_WinTypeWebNavigator) and (x<>_WinTypeCtxOffice) and
        (x<>_WintypeRtfedit) and (x<>_WinTypeDivider) and (x<>_WinTypePicture) and (x<>_WinTypeMetaPicture) and (x<>_WinTypeCtxAdobeReader) then begin
        vFont # aObj->wpfont;
        vItem->spcustom # aint(vRect:left)+'|'+aint(vRect:right)+'|'+aint(vRect:top)+'|'+aint(vRect:bottom)+'|'+aint(vFont:size);
      end
      else begin // ohne Font...
        vItem->spcustom # aint(vRect:left)+'|'+aint(vRect:right)+'|'+aint(vRect:top)+'|'+aint(vRect:bottom)+'|0';
      end;
//debug('Add:'+aobj->wpname);
      CteInsert(aList, vItem);
    end;

    vObj # aObj;
    aObj # vObj->WinInfo(_WinFirst,0);
    if (aObj<>0) then BuildScaleList(aList,aObj);
    aObj # vObj->WinInfo(_WinNext,0);
//    vObj # aObj;
  END;
end;


//========================================================================
//  ScaleObjects
//
//========================================================================
sub ScaleObjects(
  aList   : int;
  aReCalc : logic );
local begin
  vMDI      : int;
  vX1,vX2   : float;
  vY1,vY2   : float;
  vZX,vZY   : float;
  vHDL      : int;
  vHDL2     : int;
  vRect     : rect;
  vA,vB     : alpha;
  vFont     : font;
  vWinScale : float;
end;
begin

  if (aList=0) then RETURN;

  vWinScale # 10.0;   // 22.02.2018 AH: Skalierung bei Windows 7 (z.B. 125% )
  if (Usr.Zoomfaktor<>0) then begin
    // 100 => 10
    // 125 => 7.5
    // 140 =/ 5.0
    vWinScale # 10.0 - cnvfi((Usr.Zoomfaktor - 100)/10);
  end;

  // original Grösse ermitteln
  vHDL # aList->CteRead(_ctefirst);
  if (vHDL=0) then RETURN;

  if (aRecalc) or (w_ZoomX=0.0) or (w_ZoomY=0.0) then begin
    // aktuelle Grösse ermitteln...
    w_ZoomX # Cnvfi(gMDI->wpArea:right - gMDI->wparea:left);
    w_ZoomY # cnvfi(gMDI->wpArea:bottom - gMDI->wparea:top - w_QBHeight);

    vA # vHDL->spcustom;
    vB # Str_token(vA,'|',1);
    w_ZoomX # w_ZoomX / cnvfa(vB);
    vB # Str_token(vA,'|',2);
    w_ZoomY # w_ZoomY / cnvfa(vB);
  end;
  vZX # w_ZoomX;
  vZY # w_ZoomY;

//debugx('ANZ:'+aint(CteInfo(aList, _CteCount))+'    zoom:'+anum(w_ZoomX,2)+'/'+anum(w_ZoomY,2));


  FOR vHDL # aList->cteread(_ctenext,vHDL)
  LOOP vHDL # aList->cteread(_ctenext,vHDL)
  WHILE (vHDL<>0) do begin
    vHDL2 # cnvia(vHDL->spname);
    //vHDL2 # winsearch(gMDI, vHDL->spname);
 vA # vHDL->spcustom;
    vB # Str_token(vA,'|',1);
    vX2 # cnvfa(vB);
    vX1 # Rnd(cnvfa(vB) * vZX,0);
    vB # Str_token(vA,'|',2);
//    vX2  # cnvfa(vB) * vZX;
    vX2  # Rnd((cnvfa(vB)-vX2) * vZX);

    vB # Str_token(vA,'|',3);
    vY2 # cnvfa(vB);
    vY1 # cnvfa(vB) * vZY;
    vB # Str_token(vA,'|',4);
//    vY2 # cnvfa(vB) * vZY;
    vY2  # Rnd((cnvfa(vB)-vY2) * vZY);

//vRect # RecTmake(cnvif(vX1),cnvif(vY1),cnvif(vX2),cnvif(vY2));
vRect # RecTmake(cnvif(vX1),cnvif(vY1),cnvif(vX1 + vX2),cnvif(vY1 + vY2));


//debug(vHdl2->wpname+' : '+anum(vX1,0)+','+anum(vY1,0)+','+anum(vX2,0)+','+anum(vY2,0)+'    '+vA+'    zoom:'+anum(w_ZoomX,2)+'/'+anum(w_ZoomY,2));
/**
    vRect:left    # cnvif(vX1);
    vRect:right   # cnvif(vX2);
debug('rechts:'+aint(vrect:right));
    vRect:top     # cnvif(vY1);
    vRect:Bottom  # cnvif(vY2);
**/
/**
if (vHdl2->wpname='Std.Windowsbar') then begin
debug(vHdl2->wpname);
debug('X:'+anum(vX1,2)+'  '+anum(vX2,2));
debug('Y:'+anum(vY1,2)+'  '+anum(vY2,2));
//  debug(vHdl2->wpname+' '+vA+'  '+anum(w_zoomx,2)+' '+anum(w_zoomY,2));
//vRect # vHdl2->wparea;
debug('SET:'+aint(vRect:left)+'|'+aint(vRect:right)+'|'+aint(vRect:top)+'|'+aint(vRect:Bottom));

    vHDL2->wparea # vRect;

vRect # vHdl2->wparea;
debug('ist:'+aint(vRect:left)+'|'+aint(vRect:right)+'|'+aint(vRect:top)+'|'+aint(vRect:Bottom));

end
else begin
***/
    if (vHdl2<>0) then begin

      vHDL2->wparea # vRect;
//end;
      vB # Str_token(vA,'|',5);
      if (vB<>'0') then begin
        vFont # vHDL2->wpfont;
        // 25.11.2016 AH: RUNDEN !!!
        if (w_ZoomX>w_ZoomY) then
          vFont:size # cnvif(Rnd((cnvfa(vB) * vZY / 10.0),0)*vWinScale)   // war * 10.0
        else
          vFont:size # cnvif(Rnd((cnvfa(vB) * vZX / 10.0),0)*vWinScale);
        vHDL2->wpfont # vFont;
      end;
    end;

  END;

end;



// quickbar
//========================================================================
// _QBButonstate
//
//========================================================================
sub _QBButtonstate(
  aButton : int;
  aActive : logic) : int;
local begin
  vH    : int;
end;
begin

  if (aActive) then begin
    aButton->wpvisible   # true;
    aButton->wpdisabled  # false;
    aButton->wpdesign    # true;
//    aButton->wpDesignFlags # _WinDesignDragInterior;
    // 2022-08-08 AH 2166/203     vH # aButton->wpArea:Bottom - aButton->wpArea:Top + 16);
    vH # aButton->wpArea:Bottom + 16;// - aButton->wpArea:Top + 16;
    //vH # aButton->wpArea:Top + 30 ;// Max(vH,25);
    aButton->wpArea # RectMake(aButton->wpArea:left, aButton->wpArea:Top, aButton->wpArea:Right, vH);//aButton->wpArea:Top + vH);
    RETURN 0;
  end;

  vH # aButton->wpArea:Bottom - 16;
  aButton->wpArea # RectMake(aButton->wpArea:left, aButton->wpArea:Top, aButton->wpArea:Right, vH);//aButton->wpArea:Top + vH);

  if (aButton->wpcustom='') then begin
    aButton->wpdesign  # false;
    aButton->wpvisible # false;
    RETURN 0;
  end
  else begin
    aButton->wpdesign  # false;
    RETURN aButton->wpAreaBottom;
  end;

end;


//========================================================================
// SetQBButon
//
//========================================================================
Sub SetQBButton(aButton : int);
local begin
  vOk   : logic;
  vMax  : int;
end;
begin

  // Konfiguration starten
  if (aButton<>0) and (w_QBButton=0) then begin
//    gMDI->wpcolbkg # RGB(255,200,200);
    $gt.Dialog->wpvisible # false;
    $gt.Quickbar->wpvisible # true;
    _QBButtonState($bt.Quick1,y);
    _QBButtonState($bt.Quick2,y);
    _QBButtonState($bt.Quick3,y);
    _QBButtonState($bt.Quick4,y);
    _QBButtonState($bt.Quick5,y);
    _QBButtonState($bt.Quick6,y);
    _QBButtonState($bt.Quick7,y);
    _QBButtonState($bt.Quick8,y);
    _QBButtonState($bt.Quick9,y);
    _QBButtonState($bt.Quick10,y);
  end;

  // bisherigen Button zurücksetze
  if (w_QBButton>10000) then begin
    w_QBButton->wpcolBkg      # _WinColparent;
    w_QBButton->wpStylebutton # _WinStyleButtonNormal;
  end;
  w_QBButton # aButton;
  // "echter" neuer Button auswählen
  if (w_QBButton>10000) then begin
    w_QBButton->wpcaption     # '';
    w_QBButton->wpcustom      # '';
    w_QBButton->wpcolBkg      # _WinColLightRed;
    w_QBButton->wpStylebutton # _WinStyleButtonTBar;
  end
  else if (w_QBButton=0) then begin
    // Konfiguration ausschalten
    gMDI->wpcolbkg          # _WinColparent;
    $gt.Dialog->wpvisible # true;
    vMax # 0;
    vMax # _QBButtonState($bt.Quick1,n);
    vMax # Max(_QBButtonState($bt.Quick2,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick3,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick4,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick5,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick6,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick7,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick8,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick9,n), vMax);
    vMax # Max(_QBButtonState($bt.Quick10,n), vMax);

    // Quickbar anzeigen?
    if (vMax>0) then begin
      $gt.Quickbar->wpvisible # true;
      w_QBHeight    # vMax + 10;    // war 9
      $gt.Quickbar->wpHeight # -w_QBHeight;
    end
    else begin
      $gt.Quickbar->wpHeight # 0;
      $gt.Quickbar->wpvisible # false;
      w_QBHeight    # 0;
    end;
  end;

end;


//========================================================================
// EvtChangeDesign
//
//========================================================================
sub EvtChangedDesign(
  aEvt                 : event;    // Ereignis
  aAction              : int;      // Aktion
) : logic;
local begin
  vTop    : int;
  vBottom : int;
  vLeft   : int;
  vRight  : int;
end;
begin

  // Rastern...
  vLeft   # Max(0,aEvt:Obj->wpArea:left);
  vRight  # Max(0,aEvt:Obj->wpArea:right);
  vTop    # Max(0,aEvt:Obj->wpArea:Top);
  vBottom # Max(0,aEvt:Obj->wpArea:Bottom);

  vLeft   # 2 + ((vLeft / 8) * 8);
  vTop    # 8 + ((vTop / 14) * 14);
  vRight  # vLeft + 6 + (((vRight - vLeft) / 8) * 8);
// 2022-08-08 AH  vBottom # 16 + 30 + vTop;
  vBottom # vTop + 16 + (((vBottom - vTop) / 14) * 14);
  aEvt:obj->wpArea # RectMake(vLeft, vTop, vRight, vBottom);

  // minimum size 16 x 16
  RETURN(aEvt:Obj->wpAreaBottom - aEvt:Obj->wpAreaTop >= 32 AND
         aEvt:Obj->wpAreaRight - aEvt:Obj->wpAreaLeft >= 16);
end;


//========================================================================
// RememberQuickBar
//
//========================================================================
sub RememberQuickBar();
local begin
  vBar    : int;
  vHdl    : int;
  vOName  : alpha;
  vA      : alpha(250);
  vX      : int;
end;
begin

  if (gMDI=0) then RETURN;

  if (HdlInfo(gMDI,_HdlExists)=0) then RETURN;  // 13.08.2015
  vBar # Winsearch(gMDI, 'gt.Quickbar');
  if (vBar=0) then RETURN;

  vOName # gMDI->wpName;
  if ( w_Context <> '' ) then begin
    if ( Strcut( w_Context, 1, 1 ) != '-' ) then
      vOName # vOName + '.' + w_Context
  end;

  // alten Block löschen
  Usr_Data:INIKillBlock('<Quickbar name='+vOName+'>', '</Quickbar>');

//debug('vorher:'+aint( vTxtHdl->TextInfo( _textLines )));
  // neuen Block anlegen
  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '<Quickbar name=' + vOName + '>', _textLineInsert );

  // Gesamthöhe speichern
  vA # aint(w_QBHeight);
  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );

  vHdl # Winsearch(vBar,'bt.Quick1');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick2');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick3');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick4');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick5');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick6');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick7');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick8');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick9');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;
  vHdl # Winsearch(vBar,'bt.Quick10');
  if (vHdl->wpvisible) then begin
    vA # vHdl->wpname;
    vA # vA + '|' + aint(vHdl->wparea:top)+'|'+aint(vHdl->wparea:right)+'|'+aint(vHdl->wparea:bottom)+'|'+aint(vHdl->wparea:left);
    vA # vA + '|' + vHdl->wpcaption;
    vA # vA + '|' + vHdl->wpcustom;
    gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, vA, _textLineInsert );
  end;

  gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '</Quickbar>', _textLineInsert );

  // Text sichern
  Usr_Data:SaveINI();
end;


//========================================================================
//  RecallQuickbar
//
//========================================================================
sub RecallQuickbar(aMDI : int)
local begin
  vBar    : int;
  vOName  : alpha;
  vX      : int;
  vA      : alpha(250);
  vHdl    : int;
  vRect   : rect;
end;
begin

  if (aMDI=0) then RETURN;

  vBar # Winsearch(aMDI, 'gt.Quickbar');
  if (vBar=0) then RETURN;


  // Block suchen
  vOName # aMDI->wpName;
  if ( Context <> '' ) then begin
    if ( Strcut( Context, 1, 1 ) != '-' ) then
      vOName # vOName + '.' + Context
    w_Context # Context;
//    Context # ''; RecallWindows macht das
  end;

  vX # gUserINI->TextSearch( 1, 1, _textSearchToken, '<Quickbar name=' + vOName + '>' );
  if ( vX != 0 ) then begin
    // Gesamthöhe
    vA # gUserINI->TextLineRead( vX + 1, 0 );
    w_QBHeight # cnvia(vA);

    vX # vX + 2;
    vA # gUserINI->TextLineRead( vX, 0 );
    WHILE (vA<>'</Quickbar>') do begin
      vHdl # winsearch(vBar,Str_Token( vA, '|', 1 ));
      if (vHdl<>0) then begin
        vRect # RectMake( cnvIA( Str_Token( vA, '|', 5 ) ),
                          CnvIA( Str_Token( vA, '|', 2 ) ),
                          CnvIA( Str_Token( vA, '|', 3 ) ),
                          Cnvia( Str_Token( vA, '|', 4 ) ) );
        vHdl->wpcaption # Str_Token( vA, '|', 6 );
        vHdl->wpcustom  # Str_Token( vA, '|', 7 );
        vHdl->wpArea # vRect;
        vHdl->wpvisible # true;
      end;
      inc(vX);
      vA # gUserINI->TextLineRead( vX, 0 );
    END;
  end;


  // Quickbar aktiv?
  if (w_QBHeight<>0) then begin
    $gt.Quickbar->wpvisible # true;
    $gt.Quickbar->wpHeight # -w_QBHeight;
  end;

end;


//=========================================================================
// ZLColorLine
//        Färbt die (aktuelle) Zeile einer Zugriffsliste.
//        Ist aUnfixed true, so werden nur unfixierte Spalten gefärbt. Gibt
//        true zurück, wenn fixierte Spalten vorhanden sind.
//=========================================================================
sub ZLQuickJumpInfo( aObj : int; )
begin
  if (aObj=0) then RETURN;
  aObj->wpFontAttr # _WinFontAttrU;
end;


//========================================================================
//  ResetColumnWidth
//    Speichert die Zugriffslisteneinstellungen Userbezogen ab
//    mit fester Spaltenbreite
//========================================================================
sub ResetColumnWidth(
  aObj          : int;
  opt aPrefix   : alpha;
)
local begin
  vHdl    : int;
  vOName  : alphA;
  vX      : int;
  vTyp    : int;
end;

begin
  if (aObj=0) then RETURN;

  vTyp # aObj->WinInfo(_Wintype);

  vOName # aObj->wpName;
  if (w_Context<>'') then
    if (Strcut(w_Context,1,1)<>'-') then
      vOName # vOName+'.'+w_Context
  vOname # aPrefix + vOname;

  // alten Block löschen
  Usr_Data:INIKillBlock('<RecList name='+vOName+'>', '</RecList>');

  //neuen Block anlegen
  TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, '<RecList name='+vOName+'>', _TextLineInsert);
  if (vTyp<>_WinTypeDataList) then begin
    if (aObj->wpDBLinkFileNo<>0) then
      TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, 'Sort=999', _TextLineInsert)
    else
      TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1, 'Sort='+AInt(gKeyID)+'|'+aint(aObj->wpDBKeyno), _TextLineInsert);
  end;

  vHdl # aObj->WinInfo(_WinFirst);
  vHdl->wpClmWidth # 50;
  WHILE (vHdl > 0) and (vHdl->WinInfo(_WinType)=_WinTypeListColumn) do begin
    TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1,(vHdl->wpName)+','+AInt(vHdl->wpClmOrder)+','+AInt(vHdl->wpClmWidth)+','+AInt(vHdl->wpClmFixed), _TextLineInsert);
    vHdl # vHdl->WinInfo(_WinNext);
  END;
  TextLineWrite(gUserINI, gUserINI->TextInfo(_TextLines)+1,'</RecList>', _TextLineInsert);

  // Text sichern & beenden
  Usr_Data:SaveINI();

end;



//=====================================================================
// Get_Windows_SplitElemets, rekursiv...
//====================================================================
sub Get_Windows_SplitElemets( aobj : int; awindowname : alpha )
local begin
  x       : int;
  t.iObj  : int;
  vItem   : int;
  aSplitname : alpha;
  vx : int;
  va  : alpha;
  ww, wh : int;
end;
begin
  WHILE (aObj<>0) do begin
    x # aObj->WinInfo(_WinType);

    if ( x= _wintypegrouptile ) then begin
      aSplitname # aObj  -> wpname
       
       vX # gUserINI->TextSearch( 1, 1, _textSearchToken, '<Split name='+ awindowname+aSplitname+'>' );
       vA # gUserINI->TextLineRead( vX + 1, 0 );
       // Nur wenn fehlerfrei gelesen wird:
       try begin
         errtrycatch(_errcnv,y)
         ww  # cnvia(Str_Token( vA, ',', 1 ))
         wh # cnvia(Str_Token( vA, ',', 2 ))
        
      end
      if (errget() = _errok) and (aObj->wpvisible) then begin
       if ww > 0 and wh > 0 then begin
        if (ww<=2000) then
            aObj -> wpwidth # ww;
        if (wh<=10000) then
          aObj -> wpheight # wh;
         end
      end
    end;
    t.iObj # aObj;
    aObj # t.iObj->WinInfo(_WinFirst,0);
    if (aObj<>0) then Get_Windows_SplitElemets( aobj, awindowname   )
    aObj # t.iObj->WinInfo(_WinNext,0);
    t.iObj # aObj;
  END;
end


//============================================================
//
//==========================================================
sub Recall_Splits(aobj : int; awindowname : alpha)

 local begin
  vHdl    : int;
  vOName  : alpha;
  vX , vy     : int;
  vA      : alpha;
  vB      : alpha;
  vTyp    : int;
  vFixed  : int;
  itest   : int;
end;
begin

 vX # gUserINI->TextSearch( 1, 1, _textSearchToken, '<WindowSplits name=' +  awindowname +'>' );
 vy # gUserINI->TextSearch( 1, 1, _textSearchToken, '</WindowSplits name=' +  awindowname +'>' );
 // Nur wenn beide Zeilen gefunden werden:
 if vx > 0 and vy > 0 then begin
  Get_Windows_SplitElemets( aobj, awindowname  )
 end;
 
end


//=====================================================================
// Save_Windows_Splits rekursiv...
//====================================================================
sub Save_Windows_Splits( aobj : int; windowname : alpha )
local begin
  x       : int;
  t.iObj  : int;
  vItem   : int;
  aSplitname : alpha;
  iType : int;
end;
begin
  WHILE (aObj<>0) do begin
    x # aObj->WinInfo(_WinType);
 
    if ( x  = _wintypegrouptile ) then begin
      aSplitname # aobj -> wpname
      gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '<Split name=' +  windowname+asplitname + '>', _textLineInsert );
      // Split Prozente wegschreiben:
       gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, AInt( aObj->wpwidth ) + ',' +   AInt( aObj->wpheight ) , _textLineInsert );
      
       gUserINI->TextLineWrite( gUserINI->TextInfo( _textLines ) + 1, '</Split>', _textLineInsert );
    end;
    t.iObj # aObj;
    aObj # t.iObj->WinInfo(_WinFirst,0);
    if (aObj<>0) then Save_Windows_Splits( aobj,windowname  )// BuildObjectList(aList,aObj);
    aObj # t.iObj->WinInfo(_WinNext,0);
    t.iObj # aObj;
  END;
end



//========================================================================
//========================================================================
//========================================================================