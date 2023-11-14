@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_COM_Outlook
//                    OHNE E_R_G
//  Info
//
//
//  14.01.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin

  cApplication  : 'OL'
//usr.outlookcalendar # '000000001D4860CA8B6D16449504555E5EEE51F50180D04AACF7EBFBFE4DACAF2D76D1FC3BC700007AC0C3EE0100';     // öffentlich
cCalKey : '00000000CC9D27224EBAF44B80FCABC8F6F9722B0100D04AACF7EBFBFE4DACAF2D76D1FC3BC70000624C75430000'   // AH


  cT         : StrChar(  9 )
  cN         : StrChar( 10 )
  cR         : StrChar( 13 )
  xlRGB( x ) : ( x >> 16 | ( x & 0xFF00 ) | ( ( x & 0xFF ) << 16 ) )

  // COM Bug; Access to some object members will raise "Illegal function" exception without affecting the result
  _ComCall    ( aHdl, aName )         : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComCall( aName ); end;
  _ComCall2   ( aHdl, a,b)            : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComCall( a,b ); end;
  _ComPropSet ( aHdl, aName, aValue ) : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComPropSet( aName, aValue ); end;
  _ComPropGet ( aHdl, aName, aValue ) : Try begin ErrTryIgnore( _errPropInvalid ); aHdl->ComPropGet( aName, aValue ); end;


  // OlItemType enumeration
  olMailItem                      :  0
  olAppointmentItem	              :  1
  olContactItem	                  :  2
  olTaskItem                      :  3
  olJournalItem                   :  4
  olNoteItem                      :  5
  olPostItem                      :  6
  olDistributionListItem          :  7

  // OlDefaultFolders enumeration
  olFolderDeletedItems            :  3
  olFolderOutbox                  :  4
  olFolderSentMail                :  5
  olFolderInbox                   :  6
  olFolderCalendar                :  9
  olFolderContacts                : 10
  olFolderJournal                 : 11
  olFolderNotes                   : 12
  olFolderTasks                   : 13
  olFolderDrafts                  : 16
  olPublicFoldersAllPublicFolders : 18
  olFolderConflicts               : 19
  olFolderSyncIssues              : 20
  olFolderLocalFailures           : 21
  olFolderServerFailures          : 22
  olFolderJunk                    : 23
  olFolderRssFeeds                : 25
  olFolderToDo                    : 28
  olFolderManagedEmail            : 29

  // OlColor enumeration
  olAutoColor                     :  0
  olColorBlack                    :  1
  olColorMaroon                   :  2
  olColorGreen                    :  3
  olColorOlive                    :  4
  olColorNavy                     :  5
  olColorPurple                   :  6
  olColorTeal                     :  7
  olColorGray                     :  8
  olColorSilver                   :  9
  olColorRed                      : 10
  olColorLime                     : 11
  olColorYellow                   : 12
  olColorBlue                     : 13
  olColorFuchsia                  : 14
  olColorAqua                     : 15
  olColorWhite                    : 16

  // OlImportance enumeration
  olImportanceLow                 :  0
  olImportanceNormal              :  1
  olImportanceHigh                :  2

  // OlTaskStatus enumeration
  olTaskNotStarted                : 0
  olTaskInProgress                : 1
  olTaskComplete                  : 2
  olTaskWaiting                   : 3
  olTaskDeferred                  : 4

  // OlBusyStatus enumeration
  olFree                          :  0
  olTentative                     :  1
  olBusy                          :  2
  olOutOfOffice                   :  3


  // OlSensitivity
  olConfidential	                : 3
  olNormal	                      : 0
  olPersonal	                    : 1
  olPrivate	                      : 2


  // OlUserPropertyType
  olCombination	                  : 19  // The property type is a combination of other types. It corresponds to the MAPI type PT_STRING8.
  olCurrency                      : 14  // Represents a Currency property type. It corresponds to the MAPI type PT_CURRENCY.
  olDateTime                      : 5   // Represents a DateTime property type. It corresponds to the MAPI type PT_SYSTIME.
  olDuration                      : 7   // Represents a time duration property type. It corresponds to the MAPI type PT_LONG.
  olEnumeration                   : 21  // Represents an enumeration property type. It corresponds to the MAPI type PT_LONG.
  olFormula                       : 18  // Represents a formula property type. It corresponds to the MAPI type PT_STRING8. See UserDefinedProperty.Formula property.
  olInteger                       : 20  // Represents an Integer number property type. It corresponds to the MAPI type PT_LONG.
  olKeywords                      : 11  // Represents a String array property type used to store keywords. It corresponds to the MAPI type PT_MV_STRING8.
  olNumber                        : 3   // Represents a Double number property type. It corresponds to the MAPI type PT_DOUBLE.
  olOutlookInternal               : 0   // Represents an Outlook internal property type.
  olPercent                       : 12  // Represents a Double number property type used to store a percentage. It corresponds to the MAPI type PT_LONG.
  olSmartFrom                     : 22  // Represents a smart from property type. This property indicates that if the From property of an Outlook item is empty, then the To property should be used instead.
  olText                          : 1   // Represents a String property type. It corresponds to the MAPI type PT_STRING8.
  olYesNo                         : 6   // Represents a yes/no (Boolean) property type. It corresponds to the MAPI type PT_BOOLEAN.


  // WdGoToItem enumeration
  wdGoToBookmark                  : -1
  wdGoToSection                   :  0
  wdGoToPage                      :  1
  wdGoToTable                     :  2
  wdGoToLine                      :  3
  wdGoToFootnote                  :  4
  wdGoToEndnote                   :  5
  wdGoToComment                   :  6
  wdGoToField                     :  7
  wdGoToGraphic                   :  8
  wdGoToObject                    :  9
  wdGoToEquation                  : 10
  wdGoToHeading                   : 11
  wdGoToPercent                   : 12
  wdGoToSpellingError             : 13
  wdGoToGrammaticalError          : 14
  wdGoToProofreadingError         : 15

  // WdFieldType enumeration (incomplete)
  //wdFieldEmpty                    : -1
  //wdFieldComments                 : 19
  //wdFieldAddressBlock             : 93
  //wdFieldGreetingLine             : 94

  wdFieldAddin	                  : 81	// Add-in field. Not available through the Field dialog box. Used to store data that is hidden from the user interface.
  wdFieldAddressBlock             : 93	// AddressBlock field.
  wdFieldAdvance                  : 84	// Advance field.
  wdFieldAsk                      : 38	// Ask field.
  wdFieldAuthor                   : 17	// Author field.
  wdFieldAutoNum	                : 54	// AutoNum field.
  wdFieldAutoNumLegal	            : 53	// AutoNumLgl field.
  wdFieldAutoNumOutline	          : 52	// AutoNumOut field.
  wdFieldAutoText	                : 79	// AutoText field.
  wdFieldAutoTextList             : 89	// AutoTextList field.
  wdFieldBarCode	                : 63	// BarCode field.
  wdFieldBidiOutline	            : 92	// BidiOutline field.
  wdFieldComments	                : 19	// Comments field.
  wdFieldCompare	                : 80	// Compare field.
  wdFieldCreateDate	              : 21	// CreateDate field.
  wdFieldData	                    : 40	// Data field.
  wdFieldDatabase                 : 78	// Database field.
  wdFieldDate	                    : 31	// Date field.
  wdFieldDDE	                    : 45	// DDE field. No longer available through the Field dialog box, but supported for documents created in earlier versions of Word.
  wdFieldDDEAuto	                : 46	// DDEAuto field. No longer available through the Field dialog box, but supported for documents created in earlier versions of Word.
  wdFieldDocProperty	            : 85	// DocProperty field.
  wdFieldDocVariable              : 64	// DocVariable field.
  wdFieldEditTime	                : 25	// EditTime field.
  wdFieldEmbed	                  : 58	// Embedded field.
  wdFieldEmpty    	              : -1	// Empty field. Acts as a placeholder for field content that has not yet been added. A field added by pressing Ctrl+F9 in the user interface is an Empty field.
  wdFieldExpression	              : 34	// = (Formula) field.
  wdFieldFileName	                : 29	// FileName field.
  wdFieldFileSize	                : 69	// FileSize field.
  wdFieldFillIn	                  : 39	// Fill-In field.
  wdFieldFootnoteRef	            : 5	  // FootnoteRef field. Not available through the Field dialog box. Inserted programmatically or interactively.
  wdFieldFormCheckBox	            : 71	// FormCheckBox field.
  wdFieldFormDropDown	            : 83	// FormDropDown field.
  wdFieldFormTextInput	          : 70	// FormText field.
  wdFieldFormula	                : 49	// EQ (Equation) field.
  wdFieldGlossary	                : 47	// Glossary field. No longer supported in Word.
  wdFieldGoToButton	              : 50	// GoToButton field.
  wdFieldGreetingLine	            : 94	// GreetingLine field.
  wdFieldHTMLActiveX	            : 91	// HTMLActiveX field. Not currently supported.
  wdFieldHyperlink	              : 88	// Hyperlink field.
  wdFieldIf	                      : 7	  // If field.
  wdFieldImport	                  : 55	// Import field. Cannot be added through the Field dialog box, but can be added interactively or through code.
  wdFieldInclude	                : 36	// Include field. Cannot be added through the Field dialog box, but can be added interactively or through code.
  wdFieldIncludePicture	          : 67	// IncludePicture field.
  wdFieldIncludeText	            : 68	// IncludeText field.
  wdFieldIndex	                  : 8	  // Index field.
  wdFieldIndexEntry	              : 4	  // XE (Index Entry) field.
  wdFieldInfo	                    : 14	// Info field.
  wdFieldKeyWord	                : 18	// Keywords field.
  wdFieldLastSavedBy	            : 20	// LastSavedBy field.
  wdFieldLink	                    : 56	// Link field.
  wdFieldListNum	                : 90	// ListNum field.
  wdFieldMacroButton	            : 51	// MacroButton field.
  wdFieldMergeField	              : 59	// MergeField field.
  wdFieldMergeRec	                : 44	// MergeRec field.
  wdFieldMergeSeq	                : 75	// MergeSeq field.
  wdFieldNext	                    : 41	// Next field.
  wdFieldNextIf	                  : 42	// NextIf field.
  wdFieldNoteRef	                : 72	// NoteRef field.
  wdFieldNumChars	                : 28	// NumChars field.
  wdFieldNumPages	                : 26	// NumPages field.
  wdFieldNumWords	                : 27	// NumWords field.
  wdFieldOCX	                    : 87	// OCX field. Cannot be added through the Field dialog box, but can be added through code by using the AddOLEControl method of the Shapes collection or of the InlineShapes collection.
  wdFieldPage	                    : 33	// Page field.
  wdFieldPageRef	                : 37	// PageRef field.
  wdFieldPrint	                  : 48	// Print field.
  wdFieldPrintDate	              : 23	// PrintDate field.
  wdFieldPrivate	                : 77	// Private field.
  wdFieldQuote	                  : 35	// Quote field.
  wdFieldRef	                    : 3	  // Ref field.
  wdFieldRefDoc	                  : 11	// RD (Reference Document) field.
  wdFieldRevisionNum	            : 24	// RevNum field.
  wdFieldSaveDate	                : 22	// SaveDate field.
  wdFieldSection	                : 65	// Section field.
  wdFieldSectionPages	            : 66	// SectionPages field.
  wdFieldSequence	                : 12	// Seq (Sequence) field.
  wdFieldSet	                    : 6	  // Set field.
  wdFieldShape	                  : 95	// Shape field. Automatically created for any drawn picture.
  wdFieldSkipIf	                  : 43	// SkipIf field.
  wdFieldStyleRef	                : 10	// StyleRef field.
  wdFieldSubject	                : 16	// Subject field.
  wdFieldSubscriber	              : 82	// Macintosh only. For information about this constant, consult the language reference Help included with Microsoft Office Macintosh Edition.
  wdFieldSymbol	                  : 57	// Symbol field.
  wdFieldTemplate	                : 30	// Template field.
  wdFieldTime	                    : 32	// Time field.
  wdFieldTitle	                  : 15	// Title field.
  wdFieldTOA	                    : 73	// TOA (Table of Authorities) field.
  wdFieldTOAEntry	                : 74	// TOA (Table of Authorities Entry) field.
  wdFieldTOC	                    : 13	// TOC (Table of Contents) field.
  wdFieldTOCEntry	                : 9	  // TOC (Table of Contents Entry) field.
  wdFieldUserAddress	            : 62	// UserAddress field.
  wdFieldUserInitials	            : 61	// UserInitials field.
  wdFieldUserName	                : 60	// UserName field.
  wdFieldBibliography	            : 97	// Bibliography field.
  wdFieldCitation	                : 96	// Citation field.

  // WdUnits enumeration
  wdCharacter                     :  1
  wdWord                          :  2
  wdSentence                      :  3
  wdParagraph                     :  4
  wdLine                          :  5
  wdStory                         :  6
  wdScreen                        :  7
  wdSection                       :  8
  wdColumn                        :  9
  wdRow                           : 10
  wdWindow                        : 11
  wdCell                          : 12
  wdCharacterFormatting           : 13
  wdParagraphFormatting           : 14
  wdTable                         : 15
  wdItem                          : 16

  // XlAlign enumeration
  xlTop                           : -4160
  xlRight                         : -4152
  xlLeft                          : -4131
  xlJustify                       : -4130
  xlDistributed                   : -4117
  xlCenter                        : -4108
  xlBottom                        : -4107

  // XlInsertShiftDirection enumeration
  xlShiftToRight                  : -4161
  xlShiftDown                     : -4121

  // XlBordersIndex enumeration
  xlDiagonalDown                  :  5
  xlDiagonalUp                    :  6
  xlEdgeLeft                      :  7
  xlEdgeTop                       :  8
  xlEdgeBottom                    :  9
  xlEdgeRight                     : 10
  xlInsideVertical                : 11
  xlInsideHorizontal              : 12

  // XlBorderWeight enumeration
  xlMedium                        : -4138
  xlHairline                      : 1
  xlThin                          : 2
  xlThick                         : 4

  // XlLineStyle enumeration
  xlLineStyleNone                 : -4142
  xlDouble                        : -4119
  xlDot                           : -4118
  xlDash                          : -4115
  xlContinuous                    : 1
  xlDashDot                       : 4
  xlDashDotDot                    : 5
  xlSlantDashDot                  : 13

  // XlChartType enumeration (incomplete)
  xlArea                          :     1
  xlLine                          :     4
  xlPie                           :     5
  xlBubble                        :    15
  xlColumnClustered               :    51
  xlColumnStacked                 :    52
  xlColumnStacked100              :    53
  xl3DColumnClustered             :    54
  xl3DColumnStacked               :    55
  xl3DColumnStacked100            :    56
  xlBarClustered                  :    57
  xlBarStacked                    :    58
  xlBarStacked100                 :    59
  xl3DBarClustered                :    60
  xl3DBarStacked                  :    61
  xl3DBarStacked100               :    62
  xlLineStacked                   :    63
  xlLineStacked100                :    64
  xlLineMarkers                   :    65
  xlLineMarkersStacked            :    66
  xlLineMarkersStacked100         :    67
  xlAreaStacked                   :    76
  xlAreaStacked100                :    77
  xl3DAreaStacked                 :    78
  xl3DAreaStacked100              :    79
  xlDoughnutExploded              :    80
  xlRadarMarkers                  :    81
  xlRadarFilled                   :    82
end;

//========================================================================