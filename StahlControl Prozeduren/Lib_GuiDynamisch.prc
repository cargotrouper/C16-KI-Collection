@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_GuiDynamisch
//                    OHNE E_R_G
//  Info
//
//
//  26.10.2015  AH  Erstellung der Prozedur
//  18.07.2018  AH  Umbau auf Einheitlichkeit zu WinAdd und aParent
//  04.07.2019  AH  Fix für Datalist mit OrderSortShow
//  19.05.2020  AH  "AddNbPages" und "CreateJumper"
//  27.07.2021  AH  ERX
//  04.08.2021  ST  Edit: "sub AddNbPages" erweitert, für Chromium Nutzung
//  15.05.2023  DB  "CopyObject" soll RecList kopieren können
//
//  Subprozeduren
//  SUB CopyObject(aSource : int; aPostFix : alpha; aPar : int) : int;
//  SUB CopyAdd(aWin : int; aSourceName : alpha; aDestName : alpha; aX : int; aY : int; aW : int; aH : int; aPar : int; opt aNext : int; opt aName : alpha) : int;

//  SUB CopyTemplate(aWin : alpha; aVonSource : alpha; aBisSource : alpha; aX : int; aY : int; aPar : int; aNext : int; opt aPrefix : alpha) : logic;
//  SUB Remove(aPar : int; aName : alpha  ) : logic
//  SUB CreateJumper(aNB : int; aVon : alpha; aNach : alpha);
//  SUB AddNbPages(...) : logic
//
//========================================================================
@I:Def_Global

define begin
  CopyEvtProc(a,b,c) : C->WinEvtProcNameSet(A, B->WinEvtProcNameGet(A))
end;

//========================================================================
//========================================================================
sub  _CopyGrouping(
  aSource :   int;
  aObj    :   int)
begin
  aObj->wpAlignGrouping     # aSource->wpAlignGrouping;
  aObj->wpAlignWidth        # aSource->wpAlignWidth;
  aObj->wpAlignHeight       # aSource->wpAlignHeight;
  aObj->wpAlignMarginBottom # aSource->wpAlignMarginBottom;
  aObj->wpAlignMarginTop    # aSource->wpAlignMarginTop;
  aObj->wpAlignMarginRight  # aSource->wpAlignMarginRight;
  aObj->wpAlignMarginLeft   # aSource->wpAlignMarginLeft;
end;


//========================================================================
//========================================================================
sub  _CopyGroupingExtended(
  aSource :   int;
  aObj    :   int)
begin
  aObj->wpGrouping                  # aSource->wpGrouping;
  aObj->wpAlignGroupingBottomOrder  # aSource->wpAlignGroupingBottomOrder;
  aObj->wpAlignGroupingLeftOrder    # aSource->wpAlignGroupingLeftOrder;
  aObj->wpAlignGroupingTopOrder     # aSource->wpAlignGroupingTopOrder;
  aObj->wpAlignGroupingRightOrder   # aSource->wpAlignGroupingRightOrder;
end;


//========================================================================
sub _CopyCheckBox(
  aSource   : int;
  aPrefix   : alpha;
  aPostfix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha;) : int;
local begin
  vObj    : int;
end;
begin
//debugx(aSource->wpName+aPostFix+' '+aCap+' '+aint(aPar));
  vObj # WinCreate(_WinTypecheckBox, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aSource->wpcustom;
  vObj->wparea            # aSource->wparea;

  vObj->wpCaption         # aSource->wpCaption;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;

  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpfont            # aSource->wpFont;
  vObj->wpJustifyVert     # aSource->wpJustifyVert;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  vObj->wpTabStop         # aSource->wpTabStop;

  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtClicked, aSource, vObj);
  CopyEvtProc(_WinEvtChanged, aSource, vObj);
  CopyEvtProc(_WinEvtMenuCommand, aSource, vObj);
  RETURN vObj;
end;


//========================================================================
sub _CopyGroupbox(
  aSource   : int;
  aPrefix   : alpha;
  aPostfix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj # WinCreate(_WinTypeGroupbox, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpMenuNameCntxt  # aSource->wpMenuNameCntxt;
  vObj->wpcaption        # aSource->wpcaption;
  vObj->wpcustom         # aSource->wpcustom;
  vObj->wpStyleBorder    # aSource->wpStyleBorder;
//24.08.2018  vObj->wpStyleTheme     # aSource->wpStyleTheme;
  vObj->wparea           # aSource->wparea;
  vObj->wpGrouping       # aSource->wpGrouping;
  vObj->wpAlignGrouping  # aSource->wpAlignGrouping;
  vObj->wpColFg          # aSource->wpColFg;
  vObj->wpColBkg         # aSource->wpColBkg;
  vObj->wpFrame          # aSource->wpFrame;
  vObj->wpOleDropMode    # aSource->wpOleDropMode;

  vObj->wpVisible        # aSource->wpVisible;
  vObj->wpAutoUpdate     # aSource->wpAutoupdate;


  _CopyGrouping(aSource, vObj);
  _CopyGroupingExtended(aSource, vObj);

  CopyEvtProc(_WinEvtDragInit, aSource, vObj);
  CopyEvtProc(_WinEvtDragTerm, aSource, vObj);
  CopyEvtProc(_WinEvtDropEnter, aSource, vObj);
  CopyEvtProc(_WinEvtDrop, aSource, vObj);
  CopyEvtProc(_WinEvtMenuInitPopup, aSource, vObj);
  CopyEvtProc(_WinEvtMenuCommand, aSource, vObj);
  RETURN vObj;
end;


//========================================================================
sub _CopyButton(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeButton, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpMenuNameCntxt  # aSource->wpMenuNameCntxt;
  vObj->wpcustom         # aCap;
  vObj->wparea           # aSource->wparea;
  vObj->wpImageTile      # aSource->wpImageTile;
  vObj->wpImageTileUser  # aSource->wpImageTileUser;
  vObj->wpcaption        # aSource->wpCaption;

//    vBT->wpImageTile # _WinImgPageNext
//    vBT->wpImageTile # _WinImgNext;

  vObj->wpColFg          # aSource->wpColFg;
  vObj->wpColBkg         # aSource->wpColBkg;
  vObj->wpStyleBorder    # aSource->wpStyleBorder;
  vObj->wpStyleButton    # aSource->wpStyleButton;
  vObj->wpfont           # aSource->wpFont;
  vObj->wpImageOption    # aSource->wpImageOption;
  vObj->wpJustifyView    # aSource->wpJustifyView;
  vObj->wpAlignGrouping  # aSource->wpAlignGrouping;

  vObj->wpVisible        # aSource->wpVisible;
  vObj->wpAutoUpdate     # aSource->wpAutoupdate;

  CopyEvtProc(_WinEvtClicked, aSource, vObj);
  CopyEvtProc(_WinEvtMenuInitPopup, aSource, vObj);
  CopyEvtProc(_WinEvtMenuCommand, aSource, vObj);
  RETURN vObj;
end;


//========================================================================
sub _CopyLabel(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeLabel, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom         # aCap;
  vObj->wparea           # aSource->wparea;
  vObj->wpCaption        # aSource->wpCaption;

  vObj->wpColFg          # aSource->wpColFg;
  vObj->wpColBkg         # aSource->wpColBkg;
  vObj->wpStyleBorder    # aSource->wpStyleBorder;
//24.08.2018  vObj->wpStyleTheme     # aSource->wpStyleTheme;
  vObj->wpfont           # aSource->wpFont;
  vObj->wpJustifyVert    # aSource->wpJustifyVert;
  vObj->wpJustify        # aSource->wpJustify;
//  vObj->wpAlignGrouping  # aSource->wpAlignGrouping;
  vObj->wpVisible        # aSource->wpVisible;
  vObj->wpAutoUpdate     # aSource->wpAutoupdate;

  _CopyGrouping(aSource, vObj);
  
  RETURN vObj;
end;


//========================================================================
sub _CopyEditAlpha(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeEdit, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aCap;
  vObj->wparea            # aSource->wparea;
  vObj->wpCaption         # aSource->wpCaption;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;

  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpStyleBorder     # aSource->wpStyleBorder;
  vObj->wpfont            # aSource->wpFont;
  vObj->wpJustifyVert     # aSource->wpJustifyVert;
  vObj->wpJustifyView     # aSource->wpJustifyView;
  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  vObj->wpFocusSelect     # aSource->wpFocusSelect;
  vObj->wpShowFocus       # aSource->wpShowFocus;
  vObj->wpInputMode       # aSource->wpInputMode;
  vObj->wpTabStop         # aSource->wpTabStop;

  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtMouse, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);
  CopyEvtProc(_WinEvtChanged, aSource, vObj);

  RETURN vObj;
end;


//========================================================================
sub _CopyTextEdit(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeTextEdit, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aCap;
  vObj->wparea            # aSource->wparea;
  vObj->wpCaption         # aSource->wpCaption;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;

  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpStyleBorder     # aSource->wpStyleBorder;
  vObj->wpfont            # aSource->wpFont;
//  vObj->wpJustifyVert     # aSource->wpJustifyVert;
//  vObj->wpJustifyView     # aSource->wpJustifyView;
  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
//  vObj->wpFocusSelect     # aSource->wpFocusSelect;
//  vObj->wpShowFocus       # aSource->wpShowFocus;
  vObj->wpInputMode       # aSource->wpInputMode;
  vObj->wpTabStop         # aSource->wpTabStop;

  vObj->wpAutoWrap        # aSource->wpAutoWrap;
  vObj->wpLengthMax        # aSource->wpLengthMax;
  
  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtMouse, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);

  RETURN vObj;
end;


//========================================================================
sub _CopyEditFloat(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeFloatEdit, aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aCap;
  vObj->wparea            # aSource->wparea;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;
  vObj->wpDecimals        # aSource->wpDecimals;
  vObj->wpFmtFloatFlags   # aSource->wpFmtFloatFlags;
  vObj->wpFmtOutput       # aSource->wpFmtOutput;
  vObj->wpFmtNumLen       # aSource->wpFmtNumLen;

  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpStyleBorder     # aSource->wpStyleBorder;
  vObj->wpfont            # aSource->wpFont;
  vObj->wpJustifyVert     # aSource->wpJustifyVert;
  vObj->wpJustifyView     # aSource->wpJustifyView;
  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  vObj->wpFocusSelect     # aSource->wpFocusSelect;
  vObj->wpShowFocus       # aSource->wpShowFocus;
  vObj->wpInputMode       # aSource->wpInputMode;
  vObj->wpTabStop         # aSource->wpTabStop;

  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtMouse, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);
  CopyEvtProc(_WinEvtChanged, aSource, vObj);

  RETURN vObj;
end;


//========================================================================
sub _CopyEditInt(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeIntEdit, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aCap;
  vObj->wparea            # aSource->wparea;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;
  vObj->wpFmtIntFlags     # aSource->wpFmtIntFlags;
  vObj->wpFmtOutput       # aSource->wpFmtOutput;
  vObj->wpFmtNumLen       # aSource->wpFmtNumLen;

  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpStyleBorder     # aSource->wpStyleBorder;
  vObj->wpfont            # aSource->wpFont;
  vObj->wpJustifyVert     # aSource->wpJustifyVert;
  vObj->wpJustifyView     # aSource->wpJustifyView;
  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  vObj->wpFocusSelect     # aSource->wpFocusSelect;
  vObj->wpShowFocus       # aSource->wpShowFocus;
  vObj->wpInputMode       # aSource->wpInputMode;
  vObj->wpTabStop         # aSource->wpTabStop;

  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtMouse, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);
  CopyEvtProc(_WinEvtChanged, aSource, vObj);

  RETURN vObj;
end;

//========================================================================
sub _CopyEditDate(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeDateEdit, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aCap;
  vObj->wparea            # aSource->wparea;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;

  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpStyleBorder     # aSource->wpStyleBorder;
  vObj->wpfont            # aSource->wpFont;
  vObj->wpJustifyVert     # aSource->wpJustifyVert;
  vObj->wpJustifyView     # aSource->wpJustifyView;
  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  vObj->wpFocusSelect     # aSource->wpFocusSelect;
  vObj->wpShowFocus       # aSource->wpShowFocus;
  vObj->wpTabStop         # aSource->wpTabStop;
  
  vObj->wpInputCheck      # aSource->wpInputCheck;
  vObj->wpInputCtrl       # aSource->wpInputCtrl;
  vObj->wpAlignInputCtrl  # aSource->wpAlignInputCtrl;
  vObj->wpFmtOutput       # aSource->wpFmtOutput;
  vObj->wpFormatDate      # aSource->wpFormatDate;
  vObj->wpFmtDateStyle    # aSource->wpFmtDateStyle;
  vObj->wpFmtDateString   # aSource->wpFmtDateString;
  vObj->wpMinDate         # aSource->wpMinDate;
  vObj->wpMaxDate         # aSource->wpMaxDate;
  vObj->wpDefaultDate     # aSource->wpDefaultDate;
 

  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtMouse, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);
  CopyEvtProc(_WinEvtChanged, aSource, vObj);

  RETURN vObj;
end;


//========================================================================
sub _CopyEditTime(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeTimeEdit, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpcustom          # aCap;
  vObj->wparea            # aSource->wparea;
  vObj->wpDbFieldName     # aSource->wpDbFieldName;

  vObj->wpColFg           # aSource->wpColFg;
  vObj->wpColBkg          # aSource->wpColBkg;
  vObj->wpStyleBorder     # aSource->wpStyleBorder;
  vObj->wpfont            # aSource->wpFont;
  vObj->wpJustifyVert     # aSource->wpJustifyVert;
  vObj->wpJustifyView     # aSource->wpJustifyView;
  vObj->wpAlignGrouping   # aSource->wpAlignGrouping;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  vObj->wpFocusSelect     # aSource->wpFocusSelect;
  vObj->wpShowFocus       # aSource->wpShowFocus;
  vObj->wpTabStop         # aSource->wpTabStop;

  vObj->wpFmtOutput       # aSource->wpFmtOutput;
  vObj->wpFmtTimeFlags    # aSource->wpFmtTimeFlags;
  vObj->wpFormatTime      # aSource->wpFormatTime;
  vObj->wpMinTime         # aSource->wpMinTime;
  vObj->wpMaxTime         # aSource->wpMaxTime;

  CopyEvtProc(_WinEvtFocusInit, aSource, vObj);
  CopyEvtProc(_WinEvtFocusTerm, aSource, vObj);
  CopyEvtProc(_WinEvtMouse, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);
  CopyEvtProc(_WinEvtChanged, aSource, vObj);

  RETURN vObj;
end;


//========================================================================
sub _CopyDataList(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj      : int;
//  vClm  : int;
//  vFont : font;
//  vHdl  : int;
end;
begin

  vObj  # Wincreate(_WinTypeDataList, aPrefix+aSource->wpName+aPostFix, aCap, aPar);

  vObj->wpMenuNameCntxt  # aSource->wpMenuNameCntxt;

  vObj->wparea           # aSource->wparea;
  vObj->wpColFg          # aSource->wpColFg;
  vObj->wpColBkg         # aSource->wpColBkg;
  vObj->wpColGrid        # aSource->wpColGrid;
  vObj->wpColSeparator   # aSource->wpColSeparator;
  vObj->wpColFocusFg     # aSource->wpColFocusFg;
  //vDL->wpColFocusBkg    # Set.Col.RList.Cursor;//vSrc->wpColFocusBkg;
  vObj->wpColFocusBkg    # aSource->wpColFocusBkg;
  vObj->wpColBkgApp      # aSource->wpColBkgApp;
  vObj->wpColDisabledFg  # aSource->wpColDisabledFg;
  vObj->wpColDisabledBkg # aSource->wpColDisabledBkg;
  vObj->wpColFocusOffFg  # aSource->wpColFocusOffFg;
  vObj->wpColFocusOffBkg # aSource->wpColFocusOffBkg;
  vObj->wpFont           # aSource->wpFont;
  vObj->wpLstStyle       # aSource->wpLstStyle;
  vObj->wpTileNameUser   # aSource->wpTileNameUser
  vObj->wpSBarStyle      # aSource->wpSBarStyle;
  vObj->wpFocusByMouse   # aSource->wpFocusByMouse;
  vObj->wpMultiSelect    # aSource->wpMultiSelect;
  vObj->wpOleDropMode    # aSource->wpOleDropMode;
  vObj->wpORderPass       # aSource->wpOrderPass;

  vObj->wpVisible        # aSource->wpVisible;
  vObj->wpAutoUpdate     # aSource->wpAutoupdate;
  
  _CopyGrouping(aSource, vObj);

  CopyEvtProc(_WinEvtMouseItem, aSource, vObj);
  CopyEvtProc(_WinEvtMenuContext, aSource, vObj);
  CopyEvtProc(_WinEvtMenuCommand, aSource, vObj);
  CopyEvtProc(_WinEvtKeyItem, aSource, vObj);

  CopyEvtProc(_WinEvtLstDataInit, aSource, vObj);
  CopyEvtProc(_WinEvtLstSelect, aSource, vObj);
  CopyEvtProc(_WinEvtLstEditStart, aSource, vObj);
  CopyEvtProc(_WinEvtLstEditCommit, aSource, vObj);
  CopyEvtProc(_WinEvtLstEditFinished, aSource, vObj);

  CopyEvtProc(_WinEvtDragInit, aSource, vObj);
  CopyEvtProc(_WinEvtDragTerm, aSource, vObj);
  CopyEvtProc(_WinEvtDropEnter, aSource, vObj);
  CopyEvtProc(_WinEvtMenuInitPopup, aSource, vObj);
  CopyEvtProc(_WinEvtDrop, aSource, vObj);
/**
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
**/

  RETURN vObj;
end;


//========================================================================
sub _CopyColumn(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeListColumn, aPrefix+aSource->wpName+aPostFix, aCap, aPar);
  vObj->wpName          # aSource->wpName;
  vObj->wpCaption       # aSource->wpCaption;
  vObj->wpCustom        # aSource->wpCustom;
  vObj->wpClmWidth      # aSource->wpClmWidth;
  vObj->wpClmStretch    # aSource->wpClmStretch;
  vObj->wpClmType       # aSource->wpClmType;
  vObj->wpClmTypeImage  # aSource->wpClmTypeImage;
  vObj->wpClmTypeSort   # aSource->wpClmTypeSort;
  vObj->wpFontParent    # aSource->wpFontParent
  vObj->wpClmFixed      # aSource->wpClmFixed;
  vObj->wpClmSortImage  # aSource->wpClmSortImage;
  vObj->wpClmAlign      # aSource->wpClmAlign;
  vObj->wpClmSortFlags  # aSource->wpClmSortFlags;
  vObj->wpClmOrder      # aSource->wpClmOrder
  vObj->wpFmtPostComma # aSource->wpFmtPostComma;
  vObj->wpFmtFloatFlags # aSource->wpFmtFloatFlags;
  vObj->wpFmtIntFlags   # aSource->wpFmtIntFlags;
  vObj->wpHdrShadeCol1 # aSource->wpHdrShadeCol1;
  vObj->wpHdrWordBreak  # aSource->wpHdrWordBreak;

  vObj->wpVisible       # aSource->wpvisible;
  RETURN vObj;
end;


//========================================================================
sub _CopyDivider(
  aSource   : int;
  aPrefix   : alpha;
  aPostFix  : alpha;
  opt aPar  : int;
  opt aCap  : alpha;
  ) : int;
local begin
  vObj    : int;
end;
begin

  vObj  # Wincreate(_WinTypeDivider, aPrefix+aSource->wpName+aPostFix, aCap, aPar);
  vObj->wpName            # aSource->wpName;
  vObj->wparea            # aSource->wparea;
  vObj->wpVisible         # aSource->wpVisible;
  vObj->wpAutoUpdate      # aSource->wpAutoupdate;
  
  vObj->wpJustify         # aSource->wpJustify;
  vObj->wpShapeType       # aSource->wpShapeType;
  _CopyGrouping(aSource, vObj);
  
  RETURN vObj;
end;


//========================================================================
sub CopyObject(
  aSource     : int;
  aPostFix    : alpha;
  aPar        : int;
  aAdd        : logic;
  opt aPrefix : alpha;) : int;
local begin
  vTyp      : int;
  vHdl      : int;
  vNew      : int;
  vI        : int;
  vDL       : int;
end;
begin

  if (aAdd=false) then aPar # 0;

  vNew # 0;
  case Wininfo(aSource,_wintype) of
    _WinTypeNoteBookPage : vNew # 1;
    _WinTypeCheckbox    : vNew # 1;
    _WintypeGroupBox    : vNew # 0;
    _WintypeButton      : vNew # 1;
    _WinTypeDataList    : vNew # 0;
    _WinTypeRecList     : vNew # 1;
    _WinTypeListColumn  : vNew # 0;
    _WinTypeLabel       : vNew # 1;
    _WinTypeEdit        : vNew # 1;
    _WinTypeFloatEdit   : vNew # 1;
    _WinTypeIntEdit     : vNew # 1;
    _WinTypeTextEdit    : vNew # 1;
    _WinTypeDateEdit    : vNew # 1;
    _WinTypeTimeEdit    : vNew # 1;
    _WinTypeDivider     : vNew # 1;
  end;
//debug(aSource->wpname);
  if (vNew=1) then begin
//debug('jup');
    vNew # Wincopy(aSource, _WincopyDefault);
    if (vNew>0) then begin
      vNew->wpName # aPrefix+vNew->wpName+aPostfix;
      if (aPar<>0) then
        WinAdd(aPar, vNew, 0);

      // bei DataListe ggf. Reihenfolge ändern für Loop
      if (Wininfo(aSource,_wintype)=_WintypeDataList) then begin
        vDL # aSource->wpOrderPass + 100;
        aSource->wpOrderPass # _WinOrderCreate;
      end;
  /***
      // Unterobjekte loopen...
      FOR vHdl # aSource->Wininfo(_winFirst)
      LOOP vHdl # vHdl->Wininfo(_winNext)
      WHILE (vHdl<>0) do begin
        CopyObject(vHdl, aPostFix, vNew, true);   // ADDEN
      END;
  ***/
      if (vDL<>0) then begin
        aSource->wpOrderPass # vDL - 100;
      end;
    end;
    RETURN vNew;
  end;



  // MANUELLES KOPIEREN...
  case Wininfo(aSource,_wintype) of
    _WinTypeCheckbox    : vNew # _CopyCheckBox(aSource, aPrefix, aPostfix, aPar);
    _WintypeGroupBox    : vNew # _CopyGroupBox(aSource, aPrefix, aPostfix, aPar);
    _WintypeButton      : vNew # _CopyButton(aSource, aPrefix, aPostfix, aPar);
    _WinTypeDataList    : begin
      vNew # _CopyDataList(aSource, aPrefix, aPostfix, aPar);
      vDL # aSource->wpOrderPass + 100;
    end;
    _WinTypeListColumn  : vNew # _CopyColumn(aSource, aPrefix, aPostfix, aPar);
    _WinTypeLabel       : vNew # _CopyLabel(aSource, aPrefix, aPostfix, aPar);
    _WinTypeEdit        : vNew # _CopyEditAlpha(aSource, aPrefix, aPostfix, aPar);
    _WinTypeFloatEdit   : vNew # _CopyEditFloat(aSource, aPrefix, aPostfix, aPar);
    _WinTypeIntEdit     : vNew # _CopyEditInt(aSource, aPrefix, aPostfix, aPar);
    _WinTypeTextEdit    : vNew # _CopyTextEdit(aSource, aPrefix, aPostfix, aPar);
    _WinTypeDateEdit    : vNew # _CopyEditDate(aSource, aPrefix, aPostfix, aPar);
    _WinTypeTimeEdit    : vNew # _CopyEditTime(aSource, aPrefix, aPostfix, aPar);
    _WinTypeDivider     : vNew # _CopyDivider(aSource, aPrefix, aPostfix, aPar);
    otherwise           debugx('Unbekannter Typ:'+aSource->wpname);
  end;

  // Unterobjekte loopen...

  // bei DataListe ggf. Reihenfolge ändern für Loop
  if (vDL<>0) then begin
    aSource->wpOrderPass # _WinOrderCreate;
  end;
  
  FOR vHdl # aSource->Wininfo(_winFirst)
  LOOP vHdl # vHdl->Wininfo(_winNext)
  WHILE (vHdl<>0) do begin
    CopyObject(vHdl, aPostFix, vNew, true);   // ADDEN
  END;
  
  if (vDL<>0) then begin
    aSource->wpOrderPass # vDL - 100;
  end;

  RETURN vNew;
  
end;


//========================================================================
//  CopyAdd
//========================================================================
sub CopyAdd(
  aWin            : int;
  aSourceName     : alpha;
  aDestName       : alpha;
  aX              : int;
  aY              : int;
  aW              : int;
  aH              : int;
  aPar            : int;
  opt aNext       : int;
  opt aName       : alpha) : int;
local begin
  vHdl,vHdl2      : int;
  vNext           : int;
end;
begin

  vHdl  # Winsearch(aWin, aSourceName);
  if (vHdl<>0) then begin
    vHdl2 # CopyObject(vHdl, 'xxx', 0, false);//vHdl);   10.07.2018 AH???? Parent besser NULL
    vHdl2->wpName       # aDestName;

    if (aName<>'') then begin
      if (Wininfo(vHdl2,_wintype)=_WinTypeLabel) then
        vHdl2->wpCaption      # aName
      else
        vHdl2->wpDbFieldName  # aName;
    end;
    vHdl2->wpArea       # RectMake(aX, aY, aX + aW, aY + aH);

    WinAdd(aPar, vHdl2, 0, aNext);
  end;

  RETURN vHdl2;
end;


//========================================================================
//========================================================================
sub CopyTemplate(
  aWin        : alpha;
  aVonSource  : alpha;
  aBisSource  : alpha;
  aX          : int;
  aY          : int;
  aPar        : int;
  aNext       : int;
  opt aPrefix : alpha) : logic;
local begin
  vBonus    : int;
  vWin      : int;
  vHdl      : int;
  vHdl2     : int;
  vRect     : rect;
  vFirst    : logic;
end;
begin
  vBonus # VarInfo(windowbonus);

  vWin # Winopen(aWin,_WinOpenEventsOff);
  if (vWin=0) then RETURN false;
//debugx(aint(vWin)+' '+aint(errget()));
  vFirst # true;

  vHdl # WinSearch(vWin, aVonSource);
  WHILE (vHdl <> 0) do begin
  
    if (vFirst) then begin
      vFirst # false;
      if (aX<>0) or (aY<>0) then begin
        vRect # vHdl->wpArea;
        // soll 10, ist 30 => Offset = 10-30 = -20
        aX # aX - vRect:Left;
        aY # aY - vRect:Top;
      end;
    end;

    vHdl2 # CopyObject(vHdl, '', 0, false, aPrefix);
    if (vHdl2<=0) then BREAK;
//vHdl2->wpHelptip # vHdl2->wpName;

    if (aX<>0) or (aY<>0) then begin
      vRect # vHdl2->wpArea;
      vRect:left    # vRect:Left + aX;
      vRect:Right   # vRect:Right + aX;
      vRect:Top     # vRect:Top + aY;
      vRect:Bottom  # vRect:Bottom + aY;
      vHdl2->wpArea # vRect;
    end;
    
    WinAdd(aPar, vHdl2, 0, aNext);
   
    if (vHdl->wpName=^aBisSource) then BREAK;
    if (aBisSource='') then BREAK;

    vHdl # WinInfo(vHdl, _WinNext);
  END;

  Winclose(vWin);
  VarInstance(Windowbonus, vBonus);

  RETURN true;
end;


//========================================================================
//========================================================================
sub Remove(
  aPar      : int;
  aName     : alpha;    // mit ÄHNLICH
  ) : logic
local begin
  vHdl  : int;
  vPrev : int;
end;
begin

//debugx('suche '+aName);
  FOR vHdl # Winsearch(aPar, aName)
  LOOP  vHdl # WinInfo(vHdl, _WinNext)
  WHILE (vHdl<>0) do begin
    if (vPrev<>0) then begin
//debugx('destroy '+vPrev->wpname);
      try begin
        ErrTryCatch(_ErrHdlInvalid,y);
        WinRemove(vPrev);
        WinDestroy(vPrev, true);
      end;
      if (ErrGet() != _ErrOk) then RETURN false;
    end;
    vPrev # vHdl;
  END;

  if (vPrev<>0) then begin
//debugx('destroy '+vPrev->wpname);
    try begin
      ErrTryCatch(_ErrHdlInvalid,y);
      WinRemove(vPrev);
      WinDestroy(vPrev, true);
    end;
    if (ErrGet() != _ErrOk) then RETURN false;
  end;

  RETURN false;
end;


//========================================================================
// CreateJumper
//    Erzeugt die Feldsprunglogik von NotebookPage zu NotebookPage
//========================================================================
sub CreateJumper(
  aNB     : int;
  aVon    : alpha;
  aNach   : alpha)
local begin
  vP1,vP2 : int;
  vHdl    : int;
  vVon    : int;
  vNach   : int;
  vNext   : int;
  vFirst  : int;
  vRect   : rect;
end;
begin
  vVon # Winsearch(aNB, aVon);
  if (vVon=0) then RETURN;
  vP1 # wininfo(vVon, _Winparent);
  vNext # Wininfo(vVon, _Winnext);

  vNach # Winsearch(aNB, aNach);
  if (vNach=0) then RETURN;
  vP2 # wininfo(vNach, _Winparent);
  
  vRect:top # 1;
  vRect:left # 1;
  vRect:right # 2;
  vRect:bottom # 2;
  
  // Jump "Next"
  vHdl # WinCreate(_wintypeedit, 'jumpfix', '');
  vHdl->WinEvtProcNameSet(_WinEvtFocusInit, 'App_Main_Sub:JumperEvtFocusInit');
  vHdl->wpArea # vRect;
  vHdl->wpcustom # vP2->wpname+'|'+aNach+'|Next';
  WinAdd(vP1, vHdl, 0, vNext);

  // Jump "Prev"
  vHdl # WinCreate(_wintypeedit, 'jumpfix', '');
  vHdl->WinEvtProcNameSet(_WinEvtFocusInit, 'App_Main_Sub:JumperEvtFocusInit');
  vHdl->wpArea # vRect;
  vHdl->wpcustom # vP1->wpname+'|'+aVon+'|prev';
  WinAdd(vP2, vHdl, 0, vNach);
  vFirst # vHdl;
  
  // Jump "start"
  vHdl # WinCreate(_wintypeedit, 'jumpfix', '');
  vHdl->WinEvtProcNameSet(_WinEvtFocusInit, 'App_Main_Sub:JumperEvtFocusInit');
  vHdl->wpArea # vRect;
  vHdl->wpcustom # vP2->wpname+'|'+aNach+'|start';
  WinAdd(vP2, vHdl, 0, vFirst);
end;


//========================================================================
//  AddNbPages
//      Importiert alle Notebook-Pages eines Dialoges in ein geladenes anderes Notebook
//========================================================================
sub AddNbPages(
  aParNB        : int;
  aWin          : alpha;
//  aPrefix       : alpha;
  opt aVorPage  : int;
  opt aCaption  : alpha;
  opt aCustom   : alpha(1000);
  ) : logic
local begin
  vBonus    : int;
  vWin      : int;
  vNB       : int;
  vHdl      : int;
  vPage     : int;
  vPos      : int;
  vAnz      : int;
end;
begin
  vBonus # VarInfo(windowbonus);

  vWin # Winopen(aWin,_WinOpenEventsOff);
  if (vWin<=0) then RETURN false;

  if (aVorPage=0) then begin
    vHdl # WinInfo(aParNB, _Winlast, 1, _WintypeNotebookpage);
    vPos # vHdl->wpTabPos;
  end
  else begin
    vPos # aVorPage->wpTabPos;
  end;
  
  vNB # WinInfo(vWin, _WinFirst, 1, _WinTypeNoteBook)
  if (vNB<=0) then RETURN false;

  FOR vPage # Wininfo(vNB, _Winfirst, 1, _WinTypeNotebookPage)
  LOOP vPage # Wininfo(vPage, _WinNext, 1, _WinTypeNotebookPage)
  WHILE (vPage<>0) do begin
    vHdl # CopyObject(vPage, '', 0, false);//, aPrefix);    ohne Prefix, da "WinCopy" das nicht unterstützt
    aParNB->WinAdd(vHdl, 0, aVorPage);
    vHdl->wpTabPos # vPos+vAnz;
    
    // ST 2021-08-04: Wenn nur ein Element eingefügt wird,
    //       kann dieses beschriftet werden z.B. Chromium Page
    if (vAnz = 0) then begin
      if (aCaption <> '') then
        vHdl->wpCaption # aCaption;
      if (aCustom<> '') then
        vHdl->wpCustom  # aCustom;
    end;
    
    inc(vAnz);
  END;

  Winclose(vWin);
  VarInstance(Windowbonus, vBonus);

  RETURN true;
end;

//========================================================================
//========================================================================