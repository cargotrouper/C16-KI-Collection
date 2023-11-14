@A+
//@I:Var_Sys
//                    OHNE E_R_G
@I:Com_Word.Define
@I:Def_Global

//******************************************************************
//*
//* Diese Prozedur beinhaltet Funktionen zur Kommunikation mit Word
//* über die COM-Schnittstelle
//*
//* RuntimeError(alpha): logic
//* RuntimeErrorDialog(): logic
//* IsOK(): logic
//* Clear()
//* Close()
//* CreateDoc(opt logic): logic
//* VisibleSet(logic): logic
//* SetFirstHeader(float,float,float,alpha): logic
//* FooterFirstBegin(): logic
//* FooterEnd(): logic
//* SetAddressBegin(float,float,float,float,alpha,alpha,alpha): logic
//* SetAddressEnd(): logic
//* TypeText(alpha,opt int): logic
//* Information(int): int
//* Move(int,int): logic
//* MoveDirection(alpha,opt int,opt int,opt logic): logic
//* MoveLeft(opt int, opt int, opt logic): logic
//* MoveRight(opt int, opt int, opt logic): logic
//* MoveUp(opt int, opt int, opt logic): logic
//* MoveDown(opt int, opt int, opt logic): logic
//* FontName(alpha, opt int): logic
//* FontSize(int): logic
//* FontColorIndex(int): logic
//* FontBold(logic): logic
//* FontItalic(logic): logic
//* FontUnderline(logic): logic
//* Align(int): logic
//* PageBreak: logic
//* TabsClear: logic
//* TabsAdd(float, int): logic
//* TableBegin(int,int, opt int): logic
//* TableEnd(): logic
//* TableColumnWidth(int, float): logic
//* TableCellColorBkg(int): logic
//* SaveAs(alpha,logic): logic
//*
//******************************************************************

define begin
  sSpace                : StrChar(32)
  sTab                  : StrChar(9)
  sCR                   : StrChar(13)
  sLF                   : StrChar(10)
  sCRLF                 : sCR + sLF
end;

//******************************************************************
//*
//* COM Laufzeitfehlernachricht setzen
//*
//******************************************************************
sub RuntimeError
(
  aSubFunction         : alpha
)
: logic
begin
  if (ErrGet() = _ErrOk) then
    RETURN false;

  comwordError # aSubFunction+sCRLF+
                 CnvAI(ErrGet())+sCRLF+
                 CnvAI(ErrPos())+sCRLF+
                 ComInfo(0,_ComInfoErrCode)+sCRLF+
                 ComInfo(0,_ComInfoErrText);
  RETURN true;
end;


//*******************************************************************
//*
//* COM Laufzeitfehler anzeigen
//*
//*******************************************************************
sub RuntimeErrorDialog
: logic
begin
  if (comwordError = '') then
    RETURN FALSE;

  WinDialogBox(0,'Com-Runtime-Error',comwordError,
               _WinIcoError,_WinDialogOk,0);

  comwordError # '';
  RETURN TRUE;
end;


//******************************************************************
//*
//* War COM Operation erfolgreich
//*
//******************************************************************
sub IsOK
: logic
begin RETURN comwordError = ''; end;


//******************************************************************
//*
//* Globalen Datenbereich schliessen
//*
//******************************************************************
sub Clear
local begin
  tHdlInstance : int;
end;
begin
  tHdlInstance # comwordVarInstance;
  VarFree(ComWordData);
  if (tHdlInstance > 0) then
    VarInstance(comWordData,tHdlInstance);
end;


//******************************************************************
//*
//* COM Verbindung zu Word schliessen
//*
//******************************************************************
sub Close
local begin
  tHdlInstance : int;
end;
begin
  RuntimeErrorDialog();

  if (comwordApp > 0) then begin
    try
    begin
      // mit dieser Word-Methode wird die Applikation geschlossen
      comwordApp->ComCall('Quit',wdDoNotSaveChanged);

      // und den Deskriptor des COM-Objektes freigeben
      comwordApp->ComClose();
    end;
  end;

  Clear();
end;


//******************************************************************
//*
//* COM Verbindung zu Word starten und ein neues Dokument anlegen
//*
//******************************************************************
sub CreateDoc
(
  opt aVisible         : logic
)
: logic
local begin
  tHdlInstance       : int;
end;

begin
  // Instanz sichern und Datenbereich neu anlegen
  tHdlInstance # VarInfo(ComWordData);
  if (VarAllocate(ComWordData) = 0) then
    RETURN false;

  ErrTryCatch(_ErrHdlInvalid,TRUE);
  ErrTryCatch(_ErrPropInvalid,TRUE);
  ErrTryCatch(_ErrFldType,TRUE);

  try
  begin
    // Verbindung zur COM-Schnittstelle öffnen/Word Applikation starten. (Word startet im Hintergrund)
    comwordApp # ComOpen('Word.Application', _ComAppCreate);

    // ein Dokument hinzufügen
    comWordDoc # comwordApp->ComCall('Documents.Add');

    // Selektion ermitteln
    comWordSel     # comwordApp->cphSelection;
    comWordSelFont # comwordSel->cphFont;

    if (aVisible) then
      comwordApp->cplVisible # aVisible;
  end;

  if (RuntimeError('CreateDoc')) then begin
    Clear();
    WinDialogBox(0,'','Com-Applikation WORD ist nicht verfügbar!',_WinIcoError,0,0);
    return false;
    end
  else begin
    comwordVarInstance # tHdlInstance;
    return true;
  end;
end;


//******************************************************************
//*
//* Word Dokument sichtbar machen
//*
//******************************************************************
sub VisibleSet
(
  aOnOff : logic
)
: logic
begin
  if (IsOK()=n) then RETURN false;

  try
  begin
    comwordApp->cplVisible # aOnOff;
  end;

  RETURN !RuntimeError('VisibleSet');
end;


//******************************************************************
//*
//* Definiert die Kopfzeile für die erste Seite
//*
//******************************************************************
sub SetFirstHeader
(
  aLeft                : float;
  aTop                 : float;
  aHeight              : float;
  aPicture             : alpha;
)
: logic
local begin
  tcomView        : int;
  tcomViewType    : int;
  tcomShapes      : int;
  tcomPageSetup   : int;
  tcomPicture     : int;
  tcomTextBox     : int;
end;
begin
  if (!IsOK()) then RETURN false;

  try
  begin
    // Ansicht auf Seitenlayout ändern
    tcomView     # comwordApp->cphActiveWindow.ActivePane.View;
    tcomViewType # tcomView->cpiType;
    if (tcomViewType = wdNormalView) or
        (tcomViewType = wdOutlineView) then
      tcomView->cpiType # wdPrintView;

    // Seite einrichten, separate Kopf- und Fußzeile für erste Seite
    tcomPageSetup # comwordDoc->cphPageSetup;
    tcomPageSetup->cpiDifferentFirstPageHeaderFooter # -1;

    // Selektiere Kopfzeile der ersten Seite und ermittle Shape-Auflistung
    tcomView->cpiSeekView # wdSeekFirstPageHeader;
    tcomShapes # comwordSel->cphHeaderFooter.Shapes;

    // Füge das Bild hinzu
    tcomPicture # tcomShapes->ComCall('AddPicture',
      aPicture,false,true);

    // Textumbruch oben und unten
    tcomPicture->cpiWrapFormat.Type # wdWrapTopBottom;
    //tcomPicture->cpiWrapFormat.Side # wdWrapBoth;
    //tcomPicture->cplLockAnchor      # true;

    // Bildposition absolute position relativ zur Seite
    tcomPicture->cpiRelativeHorizontalPosition #
      wdRelativeHorizontalPositionPage;
    tcomPicture->cpiRelativeVerticalPosition #
      wdRelativeVerticalPositionPage;
    tcomPicture->cpiLeft # CentimetersToPoints(aLeft);
    tcomPicture->cpiTop  # CentimetersToPoints(aTop);

    // Füge leeres Textobjekt ein, dient nur als fester
    // Platzhalter
    tcomTextbox # tcomShapes->ComCall('AddTextbox',
      msoTextOrientationHorizontal,
      CentimetersToPoints(0.0),CentimetersToPoints(0.0),
      CentimetersToPoints(1.0),CentimetersToPoints(aHeight));

    // selektiere nun das hinzugefügte Textobjekt
    tcomTextbox->ComCall('TextFrame.TextRange.Select');
    comwordSel->ComCall('Collapse');
    comwordSel->ComCall('ShapeRange.Select');
    tcomTextbox # comwordSel->cphShapeRange;

    // Füllung und Linie nicht sichtbar
    tcomTextBox->cplFill.Visible # false;
    tcomTextBox->cplLine.Visible # false;
    // Textumbruch oben und unten
    tcomTextBox->cpiWrapFormat.Type # wdWrapTopBottom;
    // Bildposition absolute position relativ zur Spalte und Absatz
    tcomTextBox->cpiRelativeHorizontalPosition #
      wdRelativeHorizontalPositionColumn;
    tcomTextBox->cpiRelativeVerticalPosition #
      wdRelativeVerticalPositionParagraph;
    tcomTextBox->cpiLeft # 0;
    tcomTextBox->cpiTop  # 0;

    tcomView->cpiSeekView # wdSeekMainDocument;
  end;

  return !RuntimeError('SetFirstHeader');
end;

//******************************************************************
//*
//* Definiere die Fußzeile auf der ersten Seite
//*
//******************************************************************

sub FooterFirstBegin : logic

  local
  begin
    tcomView       : int;
    tcomViewType   : int;
    tcomPageSetup  : int;
  end;
begin
  if (isOK()=n) then RETURN false;

  try
  begin
    // Ansicht auf Seitenlayout ändern
    tcomView     # comwordApp->cphActiveWindow.ActivePane.View;
    tcomViewType # tcomView->cpiType;
    if (tcomViewType = wdNormalView) or
        (tcomViewType = wdOutlineView) then
      tcomView->cpiType # wdPrintView;

    // Seite einrichten, separate Kopf- und Fußzeile für erste Seite
    tcomPageSetup # comwordDoc->cphPageSetup;
    tcomPageSetup->cpiDifferentFirstPageHeaderFooter # -1;

    // Selektiere Fußzeile der ersten Seite
    tcomView->cpiSeekView # wdSeekFirstPageFooter;

    comwordSel->cpaFont.Name # 'Arial';
    comwordSel->cpiFont.Size # 8;
    comwordSel->cpiParagraphFormat.Alignment # wdAlignParagraphCenter;
  end;

  return !RuntimeError('FirstFooterBegin');
end;

//******************************************************************
//*
//* Wechsel zurück zum Hauptdokument
//*
//******************************************************************

sub FooterEnd
: logic

  local
  begin
    tcomView       : int;
  end;
begin
  if (IsOK()=n) then return false;

  try
  begin
    // Ansicht auf Seitenlayout ändern
    tcomView     # comwordApp->cphActiveWindow.ActivePane.View;
    tcomView->cpiSeekView # wdSeekMainDocument;
  end;

  return !RuntimeError('FooterEnd');
end;

//******************************************************************
//*
//* Starte Definition der Anschrift
//*
//******************************************************************

sub SetAddressBegin
(
  aLeft                : float;
  aTop                 : float;
  aWidth               : float;
  aHeight              : float;
  aTitle1              : alpha;
  opt aTitle2          : alpha;
  opt aTitle3          : alpha;
)
: logic

  local
  begin
    tcomTextbox        : int;
    tcomParagraph      : int;
  end;
begin
  if (IsOK()=n) then return false;

  try
  begin
    tcomTextbox # comwordDoc->ComCall('Shapes.AddTextbox',
       msoTextOrientationHorizontal,0,0,0,0);

    tcomTextBox->cpiWrapFormat.Type        # wdWrapTopBottom;
    tcomTextBox->cplLockAnchor             # true;
    tcomTextBox->cplFill.Visible           # false;
    tcomTextBox->cplLine.Visible           # false;
    tcomTextBox->cpiTextFrame.MarginLeft   # 0;
    tcomTextBox->cpiTextFrame.MarginTop    # 0;
    tcomTextBox->cpiTextFrame.MarginRight  # 0;
    tcomTextBox->cpiTextFrame.MarginBottom # 0;
    tcomTextBox->cpiRelativeHorizontalPosition #
      wdRelativeHorizontalPositionPage;
    tcomTextBox->cpiRelativeVerticalPosition #
      wdRelativeVerticalPositionPage;
    tcomTextBox->cpiLeft   # CentimetersToPoints(aLeft);
    tcomTextBox->cpiTop    # CentimetersToPoints(aTop);
    tcomTextBox->cpiWidth  # CentimetersToPoints(aWidth);
    tcomTextBox->cpiHeight # CentimetersToPoints(aHeight);

    tcomTextBox->ComCall('TextFrame.TextRange.Select');

    comwordSel->cpaFont.Name # 'Arial';
    comwordSel->cpiFont.Size # 8;
    comwordSel->cplFont.Underline # true;

    comwordSel->ComCall('TypeText',aTitle1);
    if (aTitle2 != '') then begin
      comwordSel->ComCall('TypeText',sSpace);
      comwordSel->cpaFont.Name # 'Wingdings';
      comwordSel->ComCall('TypeText',StrChar(159));
      comwordSel->cpaFont.Name # 'Arial';
      comwordSel->ComCall('TypeText',sSpace + aTitle2);

      if (aTitle3 != '') then begin
        comwordSel->ComCall('TypeText',sSpace);
        comwordSel->cpaFont.Name # 'Wingdings';
        comwordSel->ComCall('TypeText',StrChar(159));
        comwordSel->cpaFont.Name # 'Arial';
        comwordSel->ComCall('TypeText',sSpace + aTitle3);
      end;
      comwordSel->cplFont.Underline # false;
    end;

    comwordSel->cpiFont.Size # 11;
    comwordSel->ComCall('TypeText',sCR+sCR);
  end;

  return !RuntimeError('SetAddressBegin');
end;

//******************************************************************
//*
//* Wechseln zum Hauptdokument
//*
//******************************************************************

sub SetAddressEnd
: logic

  local
  begin
    tcomParagraph      : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    tcomParagraph # comwordApp->cphActiveDocument.Paragraphs(1);
    tcomParagraph->ComCall('Range.Select');
  end;

  return !RuntimeError('SetAddressEnd');
end;

//******************************************************************
//*
//* Fügt den Text ein.
//*
//******************************************************************

sub TypeText
(
  aText                : alpha(4096);
  opt aCountCR         : int;
)
: logic

  local
  begin
    tStr               : alpha;
    tLoop              : int;
  end;

begin
  if (!IsOK()) then return false;

  try
  begin
    for tLoop # 0 loop inc(tLoop) while (tLoop < aCountCR) do
      tStr # tStr + sCR;

    comwordSel->ComCall('TypeText',aText + tStr);
  end;

  return !RuntimeError('TypeText');
end;

//******************************************************************
//*
//*  Ermittelt Informationen zum Dokument.
//*
//******************************************************************

sub Information
(
  aType                : int
)
: int

  local
  begin
    tValue : int;
  end;
begin
  if (!IsOK()) then return 0;

  try
  begin
    tValue # comwordSel->cpiInformation(aType);
  end;

  if (!RuntimeError('Information')) then
    return tValue;
  else
    return 0;
end;

//******************************************************************
//*
//* Bewegt die aktuelle Selektion
//*
//******************************************************************

sub Move
(
  aType                : int;
  aCount               : int;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSel->ComCall('Move',aType,aCount);
  end;

  return !RuntimeError('Move');
end;

//******************************************************************
//*
//* Bewegt oder erweitert die aktuelle Selektion
//*
//******************************************************************

sub MoveDirection
(
  aDirection           : alpha;
  opt aType            : int;
  opt aCount           : int;
  opt aExtend          : logic;
)
: logic

  local
  begin
    tMoveType : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    if (aType = 0) then
      comwordSel->ComCall('Move'+aDirection);
    else if (aCount = 0) then
      comwordSel->ComCall('Move'+aDirection,aType);
    else begin
      if (aExtend) then
        tMoveType # wdExtend;
      else
        tMoveType # wdMove;

      comwordSel->ComCall('Move'+aDirection,aType,aCount,tMoveType);
    end;
  end;

  return !RuntimeError('Move'+aDirection);
end;

//******************************************************************
//*
//*  Bewegt oder erweitert die aktuelle Selektion
//*
//******************************************************************

sub MoveLeft
(
  opt aType            : int;
  opt aCount           : int;
  opt aExtend          : logic;
)
: logic
begin
  return MoveDirection('Left',aType,aCount,aExtend);
end;

//******************************************************************
//*
//*  Bewegt oder erweitert die aktuelle Selektion
//*
//******************************************************************

sub MoveRight
(
  opt aType            : int;
  opt aCount           : int;
  opt aExtend          : logic;
)
: logic
begin
  return MoveDirection('Right',aType,aCount,aExtend);
end;

//******************************************************************
//*
//*  Bewegt oder erweitert die aktuelle Selektion
//*
//******************************************************************

sub MoveUp
(
  opt aType            : int;
  opt aCount           : int;
  opt aExtend          : logic;
)
: logic
begin
  return MoveDirection('Up',aType,aCount,aExtend);
end;

//******************************************************************
//*
//*  Bewegt oder erweitert die aktuelle Selektion
//*
//******************************************************************

sub MoveDown
(
  opt aType            : int;
  opt aCount           : int;
  opt aExtend          : logic;
)
: logic
begin
  return MoveDirection('Down',aType,aCount,aExtend);
end;

//******************************************************************
//*
//*  Setzt Font mit Namen
//*
//******************************************************************

sub FontName
(
  aFontName            : alpha;
  opt aPointSize       : int;
)
: logic

begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSelFont->cpaName # aFontName;
    if (aPointSize > 0) then
      comwordSelFont->cpiSize # aPointSize;
  end;

  return !RuntimeError('FontName');
end;

//******************************************************************
//*
//*  Setzt Fontgröße
//*
//******************************************************************

sub FontSize
(
  aPointSize           : int;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
     comwordSelFont->cpiSize # aPointSize;
  end;

  return !RuntimeError('FontSize');
end;

//******************************************************************
//*
//*  Setzt Fontfarbe über Index
//*
//******************************************************************

sub FontColorIndex
(
  aIndex               : int;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
     comwordSelFont->cpiColorIndex # aIndex;
  end;

  return !RuntimeError('FontColorIndex');
end;

//******************************************************************
//*
//*  Setzt Font auf fett
//*
//******************************************************************

sub FontBold
(
  aOnOff               : logic;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSelFont->cplBold # aOnOff;
  end;
  return !RuntimeError('FontBold');
end;

//******************************************************************
//*
//*  Setzt Font auf kursiv
//*
//******************************************************************

sub FontItalic
(
  aOnOff               : logic;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSelFont->cplItalic # aOnOff;
  end;
  return !RuntimeError('FontItalic');
end;

//******************************************************************
//*
//*  Setzt Font auf unterstrichen
//*
//******************************************************************

sub FontUnderline
(
  aOnOff               : logic;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSelFont->cplUnderline # aOnOff;
  end;
  return !RuntimeError('FontUnderline');
end;

//******************************************************************
//*
//*  Setzt Ausrichtung für den aktuellen Abschnitt
//*
//******************************************************************

sub Align
(
  aType                 : int;
)
: logic
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSel->cpiParagraphFormat.Alignment # aType;
  end;
  return !RuntimeError('Align');
end;

//******************************************************************
//*
//*  Setzt manuellen Seitenwechsel
//*
//******************************************************************

sub PageBreak
: logic

  local
  begin
    tOnOff : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordSel->ComCall('InsertBreak',7);
  end;
  return !RuntimeError('PageBreak');
end;

//******************************************************************
//*
//*  Löscht die Tabulatoren für den aktuellen Abschnitt
//*
//******************************************************************

sub TabsClear : logic

  local
  begin
    tcomTabStops : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    tcomTabStops # comwordSel->cphParagraphFormat.TabStops;
    tcomTabStops->ComCall('ClearAll');
  end;
  return !RuntimeError('TabsClear');
end;

//******************************************************************
//*
//*  Fügt einen Tabulator für den aktuellen Abschnitt ein
//*
//******************************************************************

sub TabsAdd
(
  aPos                 : float;
  aType                : int;
)
: logic

  local
  begin
    tcomTabStops : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    tcomTabStops # comwordSel->cphParagraphFormat.TabStops;
    tcomTabStops->ComCall('Add',CentimetersToPoints(aPos),aType);
  end;
  return !RuntimeError('TabsAdd');
end;

//******************************************************************
//*
//*  Fügt eine Tabelle ein
//*
//******************************************************************

sub TableBegin
(
  aRows                : int;
  aColumns             : int;
  opt aTableFormat     : int;
)
: logic

  local
  begin
    tcomRange : int;
    tcomTable : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    tcomRange # comwordDoc->cphContent;
    tcomRange->ComCall('Collapse',wdCollapseEnd);

    tcomTable # comwordDoc->ComCall('Tables.Add',HANDLE tcomRange,aRows,aColumns);

    if (aTableFormat != wdTableFormatNone) then
      tcomTable->ComCall('AutoFormat',aTableFormat);

    tcomTable->ComCall('Select');
  end;
  return !RuntimeError('TableBegin');
end;

//******************************************************************
//*
//*  Beendet Tabellen Modus
//*
//******************************************************************

sub TableEnd
: logic

  local
  begin
    tcomRange : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    tcomRange # comwordDoc->cphContent;
    tcomRange->ComCall('Collapse',wdCollapseEnd);
    tcomRange->ComCall('Select');
  end;
  return !RuntimeError('TableEnd');
end;

//******************************************************************
//*
//*  Setzt Spalten-Breite
//*
//******************************************************************

sub TableColumnWidth
(
  aColumnNo            : int;
  aWidth               : float;
)
: logic

  local
  begin
    tcomColumn : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    if (comwordSel->cplInformation(wdWithinTable)) then begin
      tcomColumn # comwordSel->cphColumns(aColumnNo);
      tcomColumn->cpiWidth # CentimetersToPoints(aWidth);
    end;
  end;
  return !RuntimeError('TableColumnWidth');
end;

//******************************************************************
//*
//*  Setzt Zellen-Hintergrund
//*
//******************************************************************

sub TableCellColorBkg
(
  aColorBkg            : int;
)
: logic

  local
  begin
    tcomCell : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    if (comwordSel->cplInformation(wdWithinTable)) then begin
      tcomCell # comwordSel->cphCells(1);
      tcomCell->cpiShading.BackgroundPatternColorIndex # aColorBkg;
    end;
  end;
  return !RuntimeError('TableCellColorBkg');
end;

//******************************************************************
//*
//*  Dokument speichern
//*
//******************************************************************

sub SaveAs
(
  aFileName            : alpha;
  aRead0nly            : logic;
)
: logic

  local
  begin
    tcomCell : int;
  end;
begin
  if (!IsOK()) then return false;

  try
  begin
    comwordDoc->ComCall('SaveAs',aFileName, NULL, NULL, NULL, NULL, NULL,aRead0nly);
  end;
  return !RuntimeError('SaveAs');
end;
