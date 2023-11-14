@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_COM_Word
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2005  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

DEFINE begin
  mRGB(a,b,c)           : ((((c << 8) + b) << 8) + a)

  // -------------------- WdSaveOptions - Werte --------------------

  wdDoNotSaveChanged    :  0
  wdSaveChanges         : -1
  wdPromptToSaveChanges : -2

  // -------------------- WdColor - Werte --------------------------

  wdColorAutomatic      : -16777216
  wdColorBlue           : mRGB(0,0,255)
  wdColorGreen          : mRGB(0,128,0)
  wdColorRed            : mRGB(255,0,0)

  // -------------------- WdColorIndex - Werte ---------------------

  wdColorIndexAutomatic :  0
  wdColorIndexBlue      :  2
  wdColorIndexGreen     : 11
  wdColorIndexRed       :  6

  // -------------------- WdGotoDirection - Werte ---------------------

  wdGoToAbsolute  : 1
  wdGoToFirst     : 1
  wdGoToLast      : -1
  wdGoToNext      : 2
  wdGoToPrevious  : 3
  wdGoToRelative  : 2

  // -------------------- WdGotoItem - Werte ---------------------

  wdGoToBookmark        : -1
  wdGoToComment         : 6
  wdGoToEndnote         : 5
  wdGoToEquation        : 10
  wdGoToField           : 7
  wdGoToFootnote        : 4
  wdGoToGrammaticalError  : 14
  wdGoToGraphic         : 8
  wdGoToHeading         : 11
  wdGoToLine            : 3
  wdGoToObject          : 9
  wdGoToPage            : 1
  wdGoToPercent         : 12
  wdGoToProofreadingError : 15
  wdGoToSection         : 0
  wdGoToSpellingError   : 13
  wdGoToTable           : 2

end;

