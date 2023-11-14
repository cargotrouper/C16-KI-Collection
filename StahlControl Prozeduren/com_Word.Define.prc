@A+
//                    OHNE E_R_G
DEFINE begin
  mRGB(a,b,c)           : ((((c << 8) + b) << 8) + a)

  // -------------------- WdSaveOptions - Werte --------------------

  wdDoNotSaveChanged    :   0
  wdSaveChanges         :  -1
  wdPromptToSaveChanges :  -2

  // -------------------- WdUnits - Werte --------------------------

  wdCell                :  12
  wdCharacter           :   1
  wdCharacterFormatting :  13
  wdColumn              :   9
  wdItem                :  16
  wdLine                :   5
  wdParagraph           :   4
  wdParagraphFormatting :  14
  wdScreen              :   7
  wdRow                 :  10
  wdSection             :   8
  wdSentence            :   3
  wdStory               :   6
  wdTable               :  15
  wdWindow              :  11
  wdWord                :   2

  // -------------------- WdViewType - Werte -----------------------

  wdMasterView          :   5
  wdNormalView          :   1
  wdOutlineView         :   2
  wdPrintPreview        :   4
  wdPrintView           :   3
  wdWebView             :   6

  // -------------------- WdSeekView - Werte -----------------------

  wdSeekCurrentPageFooter   :  10
  wdSeekCurrentPageHeader   :   9
  wdSeekEndnotes            :   8
  wdSeekEvenPagesFooter     :   6
  wdSeekEvenPagesHeader     :   3
  wdSeekFirstPageFooter     :   5
  wdSeekFirstPageHeader     :   2
  wdSeekFootnotes           :   7
  wdSeekMainDocument        :   0
  wdSeekPrimaryFooter       :   4
  wdSeekPrimaryHeader       :   1

  // -------------------- WdWrapType - Werte ---------------------------

  wdWrapNone            :   3
  wdWrapSquare          :   0
  wdWrapThrough         :   2
  wdWrapTight           :   1
  wdWrapTopBottom       :   4

  // -------------------- WdWrapSideType - Werte ---------------------------
  wdWrapBoth            :   0
  wdWrapLargest         :   3
  wdWrapLeft            :   1
  wdWrapRight           :   2

  // ----------- WdRelativeHorizontalPosition - Werte --------------
  wdRelativeHorizontalPositionCharacter : 3
  wdRelativeHorizontalPositionColumn    : 2
  wdRelativeHorizontalPositionMargin    : 0
  wdRelativeHorizontalPositionPage      : 1

  // ----------- WdRelativeVerticalPosition - Werte ----------------
  wdRelativeVerticalPositionLine        : 3
  wdRelativeVerticalPositionMargin      : 0
  wdRelativeVerticalPositionPage        : 1
  wdRelativeVerticalPositionParagraph   : 2

  // --------------- MsoTextOrientation - Werte --------------------
  msoTextOrientationDownward                  :  3
  msoTextOrientationHorizontal                :  1
  msoTextOrientationHorizontalRotatedFarE     :  6
  msoTextOrientationMixed                     : -2
  msoTextOrientationUpward                    :  2
  msoTextOrientationVertical                  :  5
  msoTextOrientationVerticalFarEast           :  4

  // --------------- WdCollapseDirection - Werte -------------------
  WdCollapseStart       :  1
  WdCollapseEnd         :  0

  // ------------------- WdAlignment - Werte -----------------------
  wdAlignTabBar         :  4
  wdAlignTabCenter      :  1
  wdAlignTabDecimal     :  3
  wdAlignTabLeft        :  0
  wdAlignTabList        :  6
  wdAlignTabRight       :  2

  // -------------- WdParagraphAlignment - Werte -------------------

  wdAlignParagraphCenter      : 1
  wdAlignParagraphDistribute  : 4
  wdAlignParagraphJustify     : 3
  wdAlignParagraphJustifyHi   : 7
  wdAlignParagraphJustifyLow  : 8
  wdAlignParagraphJustifyMed  : 5
  wdAlignParagraphLeft        : 0
  wdAlignParagraphRight       : 2

  // -------------- WdMovementType - Werte -------------------
  wdMove                : 0
  wdExtend              : 1

  // -------------------- WdColor - Werte --------------------------

  wdColorAutomatic      : -16777216
  wdColorBlue           : mRGB(0,0,255)
  wdColorGreen          : mRGB(0,128,0)
  wdColorRed            : mRGB(255,0,0)

  // -------------------- WdColorIndex - Werte ---------------------

  wdAutomatic           :  0
  wdBlack               :  1
  wdBlue                :  2
  wdDarkBlue            :  9
  wdDarkRed             : 13
  wdGreen               : 11
  wdRed                 :  6
  wdWhite               :  8
  wdYellow              :  7

  // -------------------- WdInformationType - Werte ----------------

  wdActiveEndPageNumber       :  3
  wdWithInTable               : 12

  // -------------------- WdTableFormat - Werte --------------------

  wdTableFormat3DEffects1     : 32
  wdTableFormat3DEffects2     : 33
  wdTableFormat3DEffects3     : 34
  wdTableFormatClassic1       :  4
  wdTableFormatClassic2       :  5
  wdTableFormatClassic3       :  6
  wdTableFormatClassic4       :  7
  wdTableFormatColorful1      :  8
  wdTableFormatColorful2      :  9
  wdTableFormatColorful3      : 10
  wdTableFormatColumns1       : 11
  wdTableFormatColumns2       : 12
  wdTableFormatColumns3       : 13
  wdTableFormatColumns4       : 14
  wdTableFormatColumns5       : 15
  wdTableFormatContemporary   : 35
  wdTableFormatElegant        : 36
  wdTableFormatGrid1          : 16
  wdTableFormatGrid2          : 17
  wdTableFormatGrid3          : 18
  wdTableFormatGrid4          : 19
  wdTableFormatGrid5          : 20
  wdTableFormatGrid6          : 21
  wdTableFormatGrid7          : 22
  wdTableFormatGrid8          : 23
  wdTableFormatList1          : 24
  wdTableFormatList2          : 25
  wdTableFormatList3          : 26
  wdTableFormatList4          : 27
  wdTableFormatList5          : 28
  wdTableFormatList6          : 29
  wdTableFormatList7          : 30
  wdTableFormatList8          : 31
  wdTableFormatNone           :  0
  wdTableFormatProfessional   : 37
  wdTableFormatSimple1        :  1
  wdTableFormatSimple2        :  2
  wdTableFormatSimple3        :  3
  wdTableFormatSubtle1        :  4
  wdTableFormatSubtle2        :  5
end;


global ComWordData begin
  comwordVarInstance    : int;
  comwordApp            : int;
  comwordDoc            : int;
  comwordSel            : int;
  comwordSelFont        : int;

  comwordError          : alpha(4096);
end;


//*****************************************************************
//*
//*  Wandelt das Float Argument von Zentimeter in ein ganzzahligen Point um
//*
//*****************************************************************

sub MillimetersToPoints
(
  aCentimeter : float
)
: int
begin return CnvIF(Rnd(aCentimeter * 7.20 / 2.54)); end;

//*****************************************************************
//*
//*  Wandelt das Float Argument von Millimeter in ein ganzzahligen Point um
//*
//*****************************************************************

sub CentimetersToPoints
(
  aCentimeter : float
)
: int
begin return CnvIF(Rnd(aCentimeter * 72.0 / 2.54)); end;
