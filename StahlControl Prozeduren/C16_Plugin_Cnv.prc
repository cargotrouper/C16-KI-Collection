//---------------------------------------------------------------------------------------
//
//  Prozedur    C16_Plugin_Cnv
//                    OHNE E_R_G
//
//---------------------------------------------------------------------------------------
@A+
@C+

@I:C16_Plugin_Core_Inc
@I:C16_Plugin_Cnv_Inc
//@I:Plugin.Trace.Inc

define
{
  mChrAlpha(c)    : (StrCnv(c,_StrUpper) >= 'A' and StrCnv(c,_StrUpper) <= 'Z')
  mChrAlphaNum(c) : (mChrAlpha(c) or mChrNum(c))

  sFindWordIgnoreCase : 0x00000001

  sCmdValueString    : 0
  sCmdValueBoolTrue  : 1
  sCmdValueBoolFalse : 2
  sCmdValueReturn    : 3
  sCmdValueNumber    : 4

  sCmdValueIdMemory  : 1              // Memory object is stored in spValueInt property.

  sAscTabulator          : 0x09       // Horizontal tabulator
  sAscLineFeed           : 0x0A       // Line feed
  sAscCarriageReturn     : 0x0D       // Carriage return
  sAscSpace              : 0x20       //
  sAscDoubleQuote        : 0x22       // "
  sAscOpeningParenthesis : 0x28       // (
  sAscClosingParenthesis : 0x29       // )
  sAscSlash              : 0x2F       // /
  sAscEqualSign          : 0x3D       // =
  sAscOpeningBracket     : 0x5B       // [
  sAscBackslash          : 0x5C       // \
  sAscClosingBracket     : 0x5D       // ]
  sAscSmallLetterB       : 0x62       // b
  sAscSmallLetterF       : 0x66       // f
  sAscSmallLetterN       : 0x6E       // n
  sAscSmallLetterR       : 0x72       // r
  sAscSmallLetterT       : 0x74       // t
}

declare AddArgStr(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : alpha(4096);    // Argument value.
  aValueCharset     : int;            // Charset of value.
  opt aReturnArg    : logic;          // Function / Return argument.
)
 
declare AddArgLogic
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : logic;          // Argument value.
  opt aReturnArg    : logic;          // Function / Return argument.
)

declare AddArgRet
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
)

declare AddArgInt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : int;            // Argument value.
  opt aReturnArg    : logic;          // Function / Return argument.
)

declare GetLastError
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
) : int;

declare GetArgCount
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  opt aRetArg       : logic;          // 'Return argument' y/n.
) : int;

declare GetArgMem
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  aValue            : handle;         // Value of argument as memory content.
  opt aMemCnvMode   : int;            // Convert option for MemCnv.
  opt aRetArg       : logic;          // 'Return argument' y/n.
) : int;


//---------------------------------------------------------------------------------------
// Private : plugin command structure.
//---------------------------------------------------------------------------------------

global Private_PluginCmd
{
  gPluginCmd.Serial    : int64;       // Command Serial number.
  gPluginCmd.Kind      : int;         // Kind of command.
  gPluginCmd.Name      : alpha(4096); // Name of command.
  gPluginCmd.Args      : handle;      // Command arguments (CteNode).
  gPluginCmd.Return    : handle;      // Command return arguments (CteNode).
  gPluginCmd.LastError : int;         // Last error result.
};

//---------------------------------------------------------------------------------------
// Private : plugin command global constants.
//---------------------------------------------------------------------------------------

global Private_PluginCmdConst
{
  gPluginCmdConst.CmdToken     : alpha(3)[3];
  gPluginCmdConst.CmdKind      : int[3];
  gPluginCmdConst.CmdValue     : alpha[16];
  gPluginCmdConst.CmdValueType : byte[16];
};

//---------------------------------------------------------------------------------------
// Private : plugin command global serial number.
//---------------------------------------------------------------------------------------

global Private_PluginCmdSerial
{
  gPluginCmdSerial : int64;
};

//---------------------------------------------------------------------------------------
// Forward declarations.
//---------------------------------------------------------------------------------------

declare Private_AddArgMem
(
  aPluginCmd        : handle;
  aName             : alpha(4096);
  aValue            : handle;
  opt aMemCnvMode   : int;
  opt aReturnArg    : logic;
)
: int;

//---------------------------------------------------------------------------------------
// Private : encode kind as string.
//---------------------------------------------------------------------------------------

sub Private_EncodeKind
(
  aKind             : int;            // (in) Kind to encode as string.
  var aKindStr      : alpha;          // (out) Encoded kind string.
)
: int;
{
  switch (aKind)
  {
    case sPluginCmdKindEvt :
      aKindStr # 'EVT';
    case sPluginCmdKindCmd :
      aKindStr # 'CMD';
    case sPluginCmdKindRet :
      aKindStr # 'RET';
    default :
      return(_ErrUnknown);
  }

  return(_ErrOK);
}

//---------------------------------------------------------------------------------------
// Private : Scan wide space.
//---------------------------------------------------------------------------------------

sub Private_ScanSpace
(
  aMem                  : handle;     // (in) Memory object with string content as UTF-8.
  aStartPos             : int;        // (in) Starting position in memory object / zero-based.
  aScanNewLine          : logic;
)
: logic;

  local
  {
    tByte               : byte;
    tPos                : int;
  }

{
  if (aStartPos >= aMem->spLen)
    return(false);

  tByte # aMem->MemReadByte(aStartPos + 1);

  if (aScanNewLine and (tByte = 13 or tByte = 10))
    return(true);

  return(tByte = 9 or tByte = 32);
}

//---------------------------------------------------------------------------------------
// Private : scan stop character.
//---------------------------------------------------------------------------------------

sub Private_ScanStop
(
  aMem                  : handle;     // (in) Memory object with string content as UTF-8.
  aStartPos             : int;        // (in) Starting position in memory object / zero-based.
)
: logic;
{
  if (aStartPos >= aMem->spLen)
    return(true);

  switch (aMem->MemReadByte(aStartPos + 1))
  {
    case sAscOpeningParenthesis, sAscOpeningBracket,
         sAscClosingParenthesis, sAscClosingBracket,
         sAscEqualSign, sAscSpace,
         sAscTabulator, sAscCarriageReturn, sAscLineFeed : return(true);
    default : return(false);
  }
}

//---------------------------------------------------------------------------------------
// Private : scan escape character.
//---------------------------------------------------------------------------------------

sub Private_ScanEscape
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aPos                  : int;        // (in)  Position in memory object / zero-based.
  var aEscape           : alpha;      // (out) Escape character.
)
: int;

  local
  {
    tByte               : byte;
  }

{
  if (aPos <= 0 or aPos >= aMem->spLen)
    return(0);

  tByte # aMem->MemReadByte(aPos + 1);
  if (tByte != sAscBackslash)
    return(0);

  if (aPos + 1 >= aMem->spLen)
    return(_ErrParserInvalidChar);

  tByte # aMem->MemReadByte(aPos + 2);
  switch (tByte)
  {
    case sAscDoubleQuote, sAscBackslash, sAscSlash,
         sAscSmallLetterN, sAscSmallLetterT, sAscSmallLetterB, sAscSmallLetterF, sAscSmallLetterR :
    {
      aEscape # StrChar(tByte);
      return(1);
    }

    default :
      return(_ErrParserInvalidChar);
  }
}

//---------------------------------------------------------------------------------------
// Private : scan name in string.
//---------------------------------------------------------------------------------------

sub Private_ScanNameStr
(
  var aStr              : alpha;        // (in)  String to scan (C16 charset).
  var aName             : alpha;        // (out) Scanned name.
  aUrlStyle             : logic;       // (in) Scan name in URL-Style ?
)
: logic;

  local
  {
    tChar               : int;
    tLen                : int;
    tLastDot            : int;
    tStr                : alpha(1);
  }

{
  tLen # StrLen(aStr);
  tLastDot # -1;

  if (tLen = 0)
    return(false);

  if (!mChrAlpha(StrCut(aStr,1,1)))
    return(false);

  for tChar # 2 loop inc(tChar) while (tChar <= tLen)
  {
    tStr # StrCut(aStr,tChar,1);

    if (tStr = '.')
    {
      if (!aUrlStyle or tLastDot + 1 = tChar or tChar = tLen)
        return(false);
      tLastDot # tChar;
    }
    else
    {
      if (!mChrAlphaNum(tStr) and tStr != '_')
        return(false);
    }
  }

  aName # StrCut(aStr,1,tChar);
  return(true);
}

//---------------------------------------------------------------------------------------
// Private : scan name at given position in memory object.
//---------------------------------------------------------------------------------------

sub Private_ScanNameMem
(
  aMem                  : handle;      // (in) Memory object with string content as UTF-8.
  var aName             : alpha;       // (out) Scanned name.
  aStartPos             : int;         // (in) Starting position in memory object / zero-based.
  aUrlStyle             : logic;       // (in) Scan name in URL-Style ?
)
: int;

  local
  {
    tPos                : int;
    tStr                : alpha(4096);
  }

{
  for tPos # aStartPos loop inc(tPos) while (!Private_ScanStop(aMem,tPos));

  if (tPos - aStartPos > 4096)
    return(_ErrNameInvalid);

  tStr # aMem->MemReadStr(aStartPos + 1,tPos - aStartPos,_CharsetC16_1252)

  if (!Private_ScanNameStr(var tStr,var aName,aUrlStyle))
    return(_ErrNameInvalid);

  return(tPos);
}

//---------------------------------------------------------------------------------------
// Private : Find first word in string.
//---------------------------------------------------------------------------------------

sub Private_FindFirstWord
(
  aMem                  : handle;     // (in) Memory object with string content as UTF-8.
  aStartPos             : int;        // (in) Starting position in memory object / zero-based.
  opt aScanNewLine      : logic;
)
: int;                                // zero-based character position.

  local
  {
    tPos                : int;
  }

{
  if (aStartPos >= 0 and aStartPos < aMem->spLen)
  {
    for tPos # aStartPos loop inc(tPos) while (tPos < aMem->spLen)
    {
      if (!Private_ScanSpace(aMem,tPos,aScanNewLine))
        return(tPos);
    }
  }

  return(-1);
}

//---------------------------------------------------------------------------------------
// Private : Find word in string and skip leading white space characters.
//---------------------------------------------------------------------------------------

sub Private_FindWord
(
  aMem                  : handle;     // (in) Memory object with string content as UTF-8.
  aWord                 : alpha;      // (in) Word to find / C16 charset.
  aFlags                : long;       // (in) Currently 0 or sFindWordIgnoreCase.
  opt aStartPos         : int;        // (in) Starting position in memory object / zero-based.
)
: int;                                // zero-based character position.

  local
  {
    tPos                : int;
    tWord               : alpha(4*80);
    tStr                : alpha(4*80);
  }

{
  tPos # Private_FindFirstWord(aMem,aStartPos);

  if (tPos >= 0)
  {
    if (tPos + StrLen(aWord) > aMem->spLen)
      return(-1);

    tWord # StrCnv(aWord,_StrToUtf8);

    tStr # aMem->MemReadStr(tPos + 1,StrLen(tWord),_CharsetC16_1252);

    if ((aFlags & sFindWordIgnoreCase) != 0)
    {
      tStr # StrCnv(tStr,_StrUpper);
      aWord # StrCnv(aWord,_StrUpper);
    }

    if (tStr != aWord)
      return(-1);
  }

  return(tPos);
}

//---------------------------------------------------------------------------------------
// Private : find first space in string.
//---------------------------------------------------------------------------------------

sub Private_FindFirstSpace
(
  aMem                  : handle;     // (in) Memory object with string content as UTF-8.
  aStartPos             : int;        // (in) Starting position in memory object / zero-based.
  opt aScanNewLine      : logic;
)
: int;

  local
  {
    tPos                : int;
  }

{
  if (aStartPos >= 0 and aStartPos < aMem->spLen)
  {
    for tPos # aStartPos loop inc(tPos) while (tPos < aMem->spLen)
    {
      if (Private_ScanSpace(aMem,tPos,aScanNewLine))
        return(tPos);
    }
  }

  return(-1);
}

//---------------------------------------------------------------------------------------
// Private : is opening bracket.
//---------------------------------------------------------------------------------------

sub Private_IsOpenBracket
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
  aRetArgs              : logic;      // (in)  aArgs are return arguments.
)
: logic

  local
  {
    tByte               : int;
  }

{
  tByte # aMem->MemReadByte(aStartPos + 1);

  if (aRetArgs)
    return(tByte = StrToChar('[',1));
  else
    return(tByte = StrToChar('(',1));
}

//---------------------------------------------------------------------------------------
// Private : is closing bracket.
//---------------------------------------------------------------------------------------

sub Private_IsCloseBracket
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
  aRetArgs              : logic;      // (in)  aArgs are return arguments.
)
: logic;

  local
  {
    tByte               : int;
  }

{
  tByte # aMem->MemReadByte(aStartPos + 1);

  if (aRetArgs)
    return(tByte = StrToChar(']',1));
  else
    return(tByte = StrToChar(')',1));
}

//---------------------------------------------------------------------------------------
// Private : scan string (enclosed in "").
//---------------------------------------------------------------------------------------

sub Private_ScanString
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aValue                : handle;     // (out) Memory object with string value.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
)
: int;

  local
  {
    tByte               : byte;
    tStrChar            : alpha(1);
    tResult             : int;
  }

{
  if (aStartPos >= 0 and aStartPos < aMem->spLen)
  {
    tByte # aMem->MemReadByte(aStartPos + 1);
    if (tByte != sAscDoubleQuote)
      return(_ErrGeneric);

    aValue->spLen # 0;

    inc(aStartPos);

    while (aStartPos < aMem->spLen)
    {
      tResult # Private_ScanEscape(aMem,aStartPos,var tStrChar);

      // Invalid character.
      if (tResult < 0)
        return(tResult);

      // Escape character detected.
      if (tResult > 0)
      {
        aValue->MemWriteStr(_MemAppend,tStrChar);
        inc(aStartPos);
      }

      // Regular character.
      else
      {
        tByte # aMem->MemReadByte(aStartPos + 1);
        if (tByte = sAscDoubleQuote)
          break;

        aValue->MemWriteByte(_MemAppend,tByte);
      }

      inc(aStartPos);
    }

    if (aStartPos >= aMem->spLen)
      return(_ErrParserEndOfText);

    inc(aStartPos);
  }

  return(aStartPos);
}

//---------------------------------------------------------------------------------------
// Private : scan number.
//---------------------------------------------------------------------------------------

sub Private_ScanNumber
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aValue                : handle;     // (out) Memory object with string value.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
)
: int;

  local
  {
    tPos                : int;
    tHasDigit           : logic;
    tChar               : alpha(1);
  }

{
  aValue->spLen # 0;

  for tPos # aStartPos loop inc(tPos) while (tPos < aMem->spLen)
  {
    tChar # StrChar(aMem->MemReadByte(tPos + 1),1);

    if (tPos = aStartPos and (tChar = '+' or tChar = '-'))
      aValue->MemWriteStr(_MemAppend,tChar);
    else if (mChrNum(tChar))
    {
      aValue->MemWriteStr(_MemAppend,tChar);
      tHasDigit # true;
    }
    else
    {
      if (tPos = aStartPos)
        return(_ErrParserInvalidChar);
      if (!tHasDigit)
        return(_ErrParserInvalidConst);
      break;
    }
  }

  return(tPos);
}

//---------------------------------------------------------------------------------------
// Private : scan argument value.
//---------------------------------------------------------------------------------------

sub Private_ScanValue
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aValue                : handle;     // (out) Memory object with value.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
  var aCmdValueType     : byte;       // (out) Type of value.
)
: int;

  local
  {
    tPos                : int;
    tSlot               : int;
    tCount              : int;
    tResult             : int;
    tEscape             : alpha(1);
  }

{
  aValue->spLen # 0;

  tCount # VarInfo(gPluginCmdConst.CmdValue);
  for tSlot # 1 loop inc(tSlot) while (tSlot <= tCount)
  {
    tPos # Private_FindWord(aMem,gPluginCmdConst.CmdValue[tSlot],sFindWordIgnoreCase,aStartPos);

    if (tPos >= 0)
    {
      tResult # Private_ScanEscape(aMem,tPos - 1,var tEscape);
      if (tResult < 0)
        return(tResult);
      if (tResult = 0)
        break;
    }
  }

  if (tPos < 0)
    return(_ErrParserIllegalElement);

  aCmdValueType # gPluginCmdConst.CmdValueType[tSlot];

  switch (aCmdValueType)
  {
    case sCmdValueString :
    {
      tPos # Private_ScanString(aMem,aValue,tPos);
    }

    case sCmdValueBoolTrue :
    {
      aValue->MemWriteStr(1,'true');
      aValue->spLen # 4;
      inc(tPos,4);
    }

    case sCmdValueBoolFalse :
    {
      aValue->MemWriteStr(1,'false');
      aValue->spLen # 5;
      inc(tPos,5);
    }

    case sCmdValueReturn :
    {
      aValue->MemWriteStr(1,'?');
      aValue->spLen # 1;
      inc(tPos,1);
    }

    case sCmdValueNumber :
    {
      tPos # Private_ScanNumber(aMem,aValue,tPos);
    }

    default :
      return(_ErrGeneric);
  }

  return(tPos);
}

//---------------------------------------------------------------------------------------
// Private : scan single argument.
//---------------------------------------------------------------------------------------

sub Private_ScanArg
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aPluginCmd            : handle;     // (out) Plugin command handle with arguments.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
  aRetArgs              : logic;      // (in)  aArgs are return arguments.
  aRetCmd               : logic;      // (in)  aArgs is part of a RET command.
  aArgEmpty             : logic;
)
: int;

  local
  {
    tPos                : int;
    tName               : alpha(4096);
    tValueStr           : alpha(4096);
    tValueInt           : int;
    tValue              : handle;
    tCmdValueType       : byte;
  }

{
  tPos # Private_FindFirstWord(aMem,aStartPos);

  if (tPos >= 0)
  {
    if (!Private_IsCloseBracket(aMem,tPos,aRetArgs))
    {
      // Scan argument name.
      tPos # Private_ScanNameMem(aMem,var tName,tPos,FALSE);
      if (tPos < 0)
        return(tPos);

      // Find equal sign.
      tPos # Private_FindWord(aMem,'=',0,tPos);
      if (tPos < 0)
        return(_ErrParserSyntax);

      // Scan argument value.
      tValue # MemAllocate(_MemAutoSize);
      if (tValue = 0)
        return(_ErrOutOfMemory);

      tValue->spCharset # _CharsetUtf8;

      tPos # Private_ScanValue(aMem,tValue,tPos + 1,var tCmdValueType);
      if (tPos < 0)
        return(tPos);

      switch (tCmdValueType)
      {
        case sCmdValueString :
        {
          if (aRetArgs and !aRetCmd)
            tPos # _ErrParserIllegalElement;
          else if (tValue->spLen > 4096)
            aPluginCmd->Private_AddArgMem(tName,tValue,0,aRetArgs);
          else
          {
            tValueStr # tValue->MemReadStr(1,tValue->spLen);
            aPluginCmd->AddArgStr(tName,tValueStr,sPluginArgStrUtf8,aRetArgs);
          }
        }

        case sCmdValueBoolFalse :
        {
          if (aRetArgs and !aRetCmd)
            tPos # _ErrParserIllegalElement;
          else
            aPluginCmd->AddArgLogic(tName,false,aRetArgs);
        }

        case sCmdValueBoolTrue :
        {
          if (aRetArgs and !aRetCmd)
            tPos # _ErrParserIllegalElement;
          else
            aPluginCmd->AddArgLogic(tName,true,aRetArgs);
        }

        case sCmdValueReturn :
        {
          if (!aRetArgs or aRetCmd)
            tPos # _ErrParserIllegalElement;
          else
            aPluginCmd->AddArgRet(tName);
        }

        case sCmdValueNumber :
        {
          if (aRetArgs and !aRetCmd)
            tPos # _ErrParserIllegalElement;

          else if (tValue->spLen > 4096)
            tPos # _ErrParserOutOfRange;
          else
            tValueStr # tValue->MemReadStr(1,tValue->spLen);

          if (tPos >= 0)
          {
            try
            {
              ErrTryIgnore(_ErrCnv,_ErrCnv);
              tValueInt # CnvIA(tValueStr,_FmtInternal);
              if (tValueInt < _MinInt)
                tPos # _ErrParserOutOfRange;
            }

            if (ErrGet() != _ErrOK)
              tPos # _ErrParserOutOfRange;
            else
              aPluginCmd->AddArgInt(tName,tValueInt,aRetArgs);
          }
        }

        default :
          tPos # _ErrGeneric;
      }

      if (tPos >= 0 and aPluginCmd->GetLastError() != _ErrOK)
        tPos # aPluginCmd->GetLastError();

      tValue->MemFree();
    }
    else if (!aArgEmpty)
      tPos # _ErrParserSyntax;
  }
  else
    tPos # _ErrParserMissingComma; // _ErrParserMissingBracket; 17.03.2022 AH

  return(tPos);
}

//---------------------------------------------------------------------------------------
// Private : scan arguments.
//---------------------------------------------------------------------------------------

sub Private_ScanArgs
(
  aMem                  : handle;     // (in)  Memory object with string content as UTF-8.
  aPluginCmd            : handle;     // (out) Plugin command handle with arguments.
  aStartPos             : int;        // (in)  Starting position in memory object / zero-based.
  aRetArgs              : logic;      // (in)  aArgs are return arguments.
  aRetCmd               : logic;      // (in)  aArgs is part of a RET command.
)
: int;

  local
  {
    tStartPos           : int;
    tPos                : int;
    tPosComma           : int;
    tBracket            : alpha(1);
  }

{
  if (aRetArgs)
  {
    tStartPos # Private_FindWord(aMem,'[',0,aStartPos + 1);

    // Optional return arguments.
    if (tStartPos < 0)
    {
      if (Private_FindFirstWord(aMem,aStartPos + 1,true) < 0)
        return(aStartPos);
      return(_ErrParserSyntax);
    }

    aStartPos # tStartPos;
  }
  else
  {
    if (aStartPos >= aMem->spLen)
      return(_ErrParserEndOfText);

    if (!Private_IsOpenBracket(aMem,aStartPos,false))
      return(_ErrParserMissingComma); // _ErrParserMissingBracket; 17.03.2022 AH
  }

  tPos # Private_ScanArg(aMem,aPluginCmd,aStartPos + 1,aRetArgs,aRetCmd,true);

  while (tPos >= 0)
  {
    tPosComma # Private_FindWord(aMem,',',0,tPos);

    if (tPosComma < 0)
    {
      if (aRetArgs)
        tBracket # ']';
      else
        tBracket # ')';

      tPos # Private_FindWord(aMem,tBracket,0,tPos);
      if (tPos < 0)
        return(_ErrParserMissingComma); // _ErrParserMissingBracket; 17.03.2022 AH
      return(tPos);
    }
    else
      tPos # tPosComma + 1;

    tPos # Private_ScanArg(aMem,aPluginCmd,tPos,aRetArgs,aRetCmd,false);
  }

  return(tPos);
}

//---------------------------------------------------------------------------------------
// Private : terminate decode.
//---------------------------------------------------------------------------------------

sub Private_DecodeKind
(
  aMem                  : handle;     // (in)  Memory object with string to decode.
  aStartPos             : int;        // (in)  Start position in memory object.
  var aKind             : int;        // (out) Kind of command.
)
: int;

  local
  {
    tPos                : int;
    tStrPos             : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'Start','Startpos',mIntToAlphaDec(aStartPos));
@endif

  tStrPos # -1;

  for tPos # 1 loop inc(tPos) while (tStrPos < 0 and tPos <= VarInfo(gPluginCmdConst.CmdToken))
    tStrPos # Private_FindWord(aMem,gPluginCmdConst.CmdToken[tPos],sFindWordIgnoreCase,aStartPos);

  if (tStrPos < 0)
    return(_ErrParserIllegalElement);

  aKind # gPluginCmdConst.CmdKind[tPos-1];

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'End','StrPos',mIntToAlphaDec(tStrPos));
@endif
  return(tStrPos);
}

//---------------------------------------------------------------------------------------
// Private : Encode arguments as string.
//---------------------------------------------------------------------------------------

sub Private_EncodeArgs
(
  aOutput           : handle;         // (out) Memory object receiving arguments.
  aArgs             : handle;         // (in)  CteNode tree with arguments.
  aKind             : int;            // (in)  Command kind.
  aRetArgs          : logic;          // (int) Return argument y/n.
)
: int;

  local
  {
    tArg            : handle;
    tMem            : handle;
    tName           : alpha(4096);
    tTemp           : alpha(4096);
  }

{
  tArg # aArgs->CteRead(_CteFirst | _CteChildTree);

  while (tArg > 0)
  {
    tTemp # tArg->spName;

    if (!Private_ScanNameStr(var tTemp,var tName,false))
      return(_ErrNameInvalid);

    aOutput->MemWriteStr(_MemAppend,tArg->spName,_CharsetC16_1252);
    aOutput->MemWriteStr(_MemAppend,'=');

    switch (tArg->spType)
    {
      case _TypeLogic :
      {
        if (!aRetArgs and aKind = sPluginCmdKindRet)
          return(_ErrType);

        if (tArg->spValueLogic)
          aOutput->MemWriteStr(_MemAppend,'true');
        else
          aOutput->MemWriteStr(_MemAppend,'false');
      }

      case _TypeInt :
      {
        if (!aRetArgs and aKind = sPluginCmdKindRet)
          return(_ErrType);

        if (tArg->spID = sCmdValueIdMemory)
        {
          tMem # tArg->spValueInt;
          aOutput->MemWriteByte(_MemAppend,sAscDoubleQuote);
          tMem->MemCopy(1,tMem->spLen,_MemAppend,aOutput);
          aOutput->MemWriteByte(_MemAppend,sAscDoubleQuote);
        }
        else
          aOutput->MemWriteStr(_MemAppend,CnvAI(tArg->spValueInt,_FmtInternal));
      }

      case _TypeAlpha :
      {
        if (!aRetArgs and aKind = sPluginCmdKindRet)
          return(_ErrType);

        aOutput->MemWriteByte(_MemAppend,sAscDoubleQuote);
        aOutput->MemWriteStr(_MemAppend,tArg->spValueAlpha,_CharsetUtf8);
        aOutput->MemWriteByte(_MemAppend,sAscDoubleQuote);
      }

      case _TypeNone :
      {
        if (!aRetArgs or aKind = sPluginCmdKindRet)
          return(_ErrType);

        aOutput->MemWriteStr(_MemAppend,'?');
      }
    }

    tArg # aArgs->CteRead(_CteNext | _CteChildTree,tArg);

    if (tArg > 0)
      aOutput->MemWriteStr(_MemAppend,',');
  }

  return(_ErrOK);
}

//---------------------------------------------------------------------------------------
// Private : validate argument name.
//---------------------------------------------------------------------------------------

sub Private_ValidateName
(
  var aName         : alpha;          // Argument name to validate.
)
: logic;

  local
  {
    tLen            : int;
    tPos            : int;
    tChar           : alpha(1);
  }

{
  if (aName = '' or !mChrAlpha(aName))
    return(false);

  tLen # StrLen(aName);

  for tPos # 2 loop inc(tPos) while (tPos <= tLen)
  {
    tChar # StrCut(aName,tPos,1);

    if (!mChrAlphaNum(tChar) and tChar != '_')
      return(false);
  }

  return(true);
}

//---------------------------------------------------------------------------------------
// Private : add argument to plug-in command.
//---------------------------------------------------------------------------------------

sub Private_AddArg
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aArg              : handle;         // Argument to add
  aArgRet           : logic;          // true = return args, false = normal args.
)

  local
  {
    tResult         : logic;
  }

{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (aArgRet)
    tResult # gPluginCmd.Return->CteInsert(aArg);
  else
    tResult # gPluginCmd.Args->CteInsert(aArg);

  if (tResult)
    gPluginCmd.LastError # _ErrOK;
  else
    gPluginCmd.LastError # _ErrExists;

  if (gPluginCmd.LastError != _ErrOK)
    aArg->CteClose();
}

//---------------------------------------------------------------------------------------
// Private : initialize decode.
//---------------------------------------------------------------------------------------

sub Private_DecodeInit
()
{
  VarAllocate(Private_PluginCmdConst);

  gPluginCmdConst.CmdToken[1] # 'EVT';
  gPluginCmdConst.CmdToken[2] # 'CMD';
  gPluginCmdConst.CmdToken[3] # 'RET';

  gPluginCmdConst.CmdKind[1] # sPluginCmdKindEvt;
  gPluginCmdConst.CmdKind[2] # sPluginCmdKindCmd;
  gPluginCmdConst.CmdKind[3] # sPluginCmdKindRet;

  gPluginCmdConst.CmdValue[1] # '"';
  gPluginCmdConst.CmdValue[2] # 'true';
  gPluginCmdConst.CmdValue[3] # 'false';
  gPluginCmdConst.CmdValue[4] # '?';
  gPluginCmdConst.CmdValue[5] # '-';
  gPluginCmdConst.CmdValue[6] # '+';
  gPluginCmdConst.CmdValue[7] # '0';
  gPluginCmdConst.CmdValue[8] # '1';
  gPluginCmdConst.CmdValue[9] # '2';
  gPluginCmdConst.CmdValue[10] # '3';
  gPluginCmdConst.CmdValue[11] # '4';
  gPluginCmdConst.CmdValue[12] # '5';
  gPluginCmdConst.CmdValue[13] # '6';
  gPluginCmdConst.CmdValue[14] # '7';
  gPluginCmdConst.CmdValue[15] # '8';
  gPluginCmdConst.CmdValue[16] # '9';

  gPluginCmdConst.CmdValueType[1] # sCmdValueString;
  gPluginCmdConst.CmdValueType[2] # sCmdValueBoolTrue;
  gPluginCmdConst.CmdValueType[3] # sCmdValueBoolFalse;
  gPluginCmdConst.CmdValueType[4] # sCmdValueReturn;
  gPluginCmdConst.CmdValueType[5] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[6] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[7] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[8] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[9] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[10] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[11] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[12] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[13] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[14] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[15] # sCmdValueNumber;
  gPluginCmdConst.CmdValueType[16] # sCmdValueNumber;
}

//---------------------------------------------------------------------------------------
// Private : terminate decode.
//---------------------------------------------------------------------------------------

sub Private_DecodeTerm
()
{
  VarFree(Private_PluginCmdConst);
}

//---------------------------------------------------------------------------------------
// Private : clear argument list.
//---------------------------------------------------------------------------------------

sub Private_ClearArguments
(
  aCmdArgs              : handle;
)

  local
  {
    tCteNode            : handle;
    tMem                : handle;
  }

{
  tCteNode # aCmdArgs->CteRead(_CteFirst | _CteChildTree);

  while (tCteNode > 0)
  {
    if (tCteNode->spType = _TypeInt and tCteNode->spID = sCmdValueIdMemory)
    {
      tMem # tCteNode->spValueInt;

      if (tMem > 0 and HdlInfo(tMem,_HdlExists) = 1 and HdlInfo(tMem,_HdlType) = _HdlMem)
        tMem->MemFree();
    }

    tCteNode # aCmdArgs->CteRead(_CteNext | _CteChildTree,tCteNode)
  }

  aCmdArgs->CteClear(true);
}

//---------------------------------------------------------------------------------------
// Private : add memory object as argument.
//---------------------------------------------------------------------------------------

sub Private_AddArgMem
(
  aPluginCmd        : handle;
  aName             : alpha(4096);
  aValue            : handle;
  opt aMemCnvMode   : int;
  opt aReturnArg    : logic;
)

: int;

  local
  {
    tArg            : handle;
    tMem            : handle;
  }

{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (aValue = 0 or HdlInfo(aValue,_HdlExists) = 0)
    gPluginCmd.LastError # _ErrHdlInvalid;
  else if (HdlInfo(aValue,_HdlType) != _HdlMem)
    gPluginCmd.LastError # _ErrHdlInvalid;
  else
  {
    tMem # MemAllocate(_MemAutoSize);

    if (tMem > 0)
    {
      tMem->spCharset # _CharsetUtf8;

      if (aMemCnvMode != 0)
        gPluginCmd.LastError # aValue->MemCnv(tMem,aMemCnvMode);
      else
      {
        aValue->MemCopy(1,aValue->spLen,1,tMem);
        gPluginCmd.LastError # _ErrOK;
      }

      if (gPluginCmd.LastError = _ErrOK)
      {
        tArg # CteOpen(_CteNode,0);
        tArg->spName # aName;
        tArg->spID # sCmdValueIdMemory;
        tArg->spValueInt # tMem;

        Private_AddArg(0,tArg,aReturnArg);
      }

      if (gPluginCmd.LastError != _ErrOK)
        tMem->MemFree();
    }
    else
      gPluginCmd.LastError # tMem;
  }

  return(gPluginCmd.LastError);
}

//---------------------------------------------------------------------------------------
// Public : create plug-in command.
//---------------------------------------------------------------------------------------

sub CreateCmd
(
  opt aKind             : int;
  opt aName             : alpha(4096);
  opt aSerial           : int64;
)
: handle;

  local
  {
    tCmd : handle;
  }

{
  tCmd # VarAllocate(Private_PluginCmd);

  gPluginCmd.Kind   # aKind;
  gPluginCmd.Name   # aName;
  gPluginCmd.Serial # aSerial;

  gPluginCmd.Args # CteOpen(_CteNode,_CteChildTreeCI);
  gPluginCmd.Return # CteOpen(_CteNode,_CteChildTreeCI);
  return(tCmd);
}

//---------------------------------------------------------------------------------------
// Public : delete plug-in command.
//---------------------------------------------------------------------------------------

sub DeleteCmd
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (VarInfo(Private_PluginCmd) > 0)
  {
    if (gPluginCmd.Args > 0)
    {
      gPluginCmd.Args->Private_ClearArguments();
      gPluginCmd.Args->CteClose();
    }

    if (gPluginCmd.Return > 0)
    {
      gPluginCmd.Return->Private_ClearArguments();
      gPluginCmd.Return->CteClose();
    }

    VarFree(Private_PluginCmd);
  }
}

//---------------------------------------------------------------------------------------
// Public : clear plug-in command.
//---------------------------------------------------------------------------------------

sub ClearCmd
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  opt aKind         : int;
  opt aName         : alpha(4096);
  opt aSerial       : int64
)
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (VarInfo(Private_PluginCmd) > 0)
  {
    gPluginCmd.Kind      # aKind;
    gPluginCmd.Name      # aName;
    gPluginCmd.Serial    # aSerial;
    gPluginCmd.LastError # 0;

    if (gPluginCmd.Args > 0)
      gPluginCmd.Args->Private_ClearArguments();

    if (gPluginCmd.Return > 0)
      gPluginCmd.Return->Private_ClearArguments();
  }
}

//---------------------------------------------------------------------------------------
// Public : retrieve command name.
//---------------------------------------------------------------------------------------

sub GetCmdName
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: alpha;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Name);
}

//---------------------------------------------------------------------------------------
// Public : compare given command name with plug-in command.
//---------------------------------------------------------------------------------------

sub IsCmdName
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aCmdName          : alpha(4096);    // Command name to compare.
)
: logic;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Name =^ aCmdName);
}

//---------------------------------------------------------------------------------------
// Public : retrieve command kind.
//---------------------------------------------------------------------------------------

sub GetCmdKind
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Kind);
}

//---------------------------------------------------------------------------------------
// Public : test command kind.
//---------------------------------------------------------------------------------------

sub IsCmdKindEvt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: logic;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Kind = sPluginCmdKindEvt);
}

sub IsCmdKindCmd
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: logic;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Kind = sPluginCmdKindCmd);
}

sub IsCmdKindRet
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: logic;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Kind = sPluginCmdKindRet);
}

//---------------------------------------------------------------------------------------
// Public : retrieve command serial number (> 0 if any, 0 if omitted).
//---------------------------------------------------------------------------------------

sub GetCmdSerial
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int64;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.Serial);
}

//---------------------------------------------------------------------------------------
// Public : retrieve last error occured.
//---------------------------------------------------------------------------------------

sub GetLastError
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  return(gPluginCmd.LastError);
}

//---------------------------------------------------------------------------------------
// Public : add argument of given type to plug-in command.
//---------------------------------------------------------------------------------------

sub AddArgStr
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : alpha(4096);    // Argument value.
  aValueCharset     : int;            // Charset of value.
  opt aReturnArg    : logic;          // Function / Return argument.
)

  local
  {
    tValue          : alpha(4096);
    tArg            : handle;
  }

{
  switch (aValueCharset)
  {
    case sPluginArgStrC16 :
      tValue # StrCnv(aValue,_StrToUtf8);

    case sPluginArgStrISO :
      tValue # StrCnv(StrCnv(aValue,_StrFromAnsi),_StrToUtf8);

    case sPluginArgStrUtf8 :
      tValue # aValue;

    default :
      return;
  }

  tArg # CteOpen(_CteNode,0);
  tArg->spName # aName;
  tArg->spValueAlpha # tValue;
  Private_AddArg(aPluginCmd,tArg,aReturnArg);
}

sub AddArgInt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : int;            // Argument value.
  opt aReturnArg    : logic;          // Function / Return argument.
)

  local
  {
    tArg            : handle;
  }

{
  tArg # CteOpen(_CteNode,0);
  tArg->spName # aName;
  tArg->spValueInt # aValue;
  Private_AddArg(aPluginCmd,tArg,aReturnArg);
}

sub AddArgLogic
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : logic;          // Argument value.
  opt aReturnArg    : logic;          // Function / Return argument.
)

  local
  {
    tArg            : handle;
  }

{
  tArg # CteOpen(_CteNode,0);
  tArg->spName # aName;
  tArg->spValueLogic # aValue;
  Private_AddArg(aPluginCmd,tArg,aReturnArg);
}

sub AddArgMem
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : handle;         // Argument value (copies memory object).
  opt aMemCnvMode   : int;            // Convert option for MemCnv.
  opt aReturnArg    : logic;          // Function / Return argument.
)

  local
  {
    tArg            : handle;
    tMem            : handle;
  }

{
  aPluginCmd->Private_AddArgMem(aName,aValue,aMemCnvMode,aReturnArg);
}

sub AddArgRet
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
)

  local
  {
    tArg            : handle;
  }

{
  tArg # CteOpen(_CteNode,0);

  tArg->spName # aName;
  tArg->spType # _TypeNone;
  Private_AddArg(aPluginCmd,tArg,true);
}

sub AddExecResult
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
{
  aPluginCmd->AddArgRet('ExecResult');
}

//---------------------------------------------------------------------------------------
// Public : get argument by name.
//---------------------------------------------------------------------------------------

sub GetArg
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: handle;                             // Handle to CteNode object.

  local
  {
    tResult         : handle;
  }

{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (aRetArg)
    tResult # gPluginCmd.Return->CteRead(_CteChildTree | _CteCmpE,0,aName);
  else
    tResult # gPluginCmd.Args->CteRead(_CteChildTree | _CteCmpE,0,aName);

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : get argument by number.
//---------------------------------------------------------------------------------------

sub GetArgByNum
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aArgNum           : int;            // Argument number / one-based.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: handle

  local
  {
    tArgNum         : int;
    tArgs           : handle;
    tResult         : int;
  }

{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (aArgNum < 1 or aArgNum >GetArgCount(aPluginCmd,aRetArg))
    return(_ErrRange);

  if (aRetArg)
    tArgs # gPluginCmd.Return;
  else
    tArgs # gPluginCmd.Args;

  tArgNum # 1;
  tResult # tArgs->CteRead(_CteFirst | _CteChildTree);

  while (tArgNum < aArgNum)
  {
    tResult # tArgs->CteRead(_CteNext | _CteChildTree,tResult);
    inc(tArgNum);
  }

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : get string argument value.
//---------------------------------------------------------------------------------------

sub GetArgStr
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : alpha;          // Value of argument (UTF-8).
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

  local
  {
    tArg            : handle;
    tMem            : handle;
    tMaxLen         : int;
  }

{
  tArg # GetArg(aPluginCmd,aName,aRetArg);
  if (tArg = 0)
    return(_ErrUnavailable);

  tMaxLen # VarInfo(aValue);

  if (tArg->spType = _TypeInt and tArg->spID = sCmdValueIdMemory)
  {
    tMem # tArg->spValueInt;

    if (tMem->spLen > 0)
      aValue # tMem->MemReadStr(1,min(tMem->spLen,tMaxLen),_CharsetUtf8);
    else
      aValue # '';

    return(_ErrOK);
  }
  else if (tArg->spType = _TypeAlpha)
  {
    aValue # StrCut(tArg->spValueAlpha,1,tMaxLen);
    return(_ErrOK);
  }

  return(_ErrType);
}

//---------------------------------------------------------------------------------------
// Public : get string argument value from base64 coded string.
//---------------------------------------------------------------------------------------

sub GetArgStrDecB64
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : alpha;          // Value of argument (UTF-8).
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

  local
  {
    tMem            : handle;
    tResult         : int;
    tMaxLen         : int;
  }

{
  tMem # MemAllocate(_MemAutoSize);
  if (tMem < _ErrOK)
    return(tMem);

  tResult # aPluginCmd->GetArgMem(aName,tMem,_MemDecBase64,aRetArg);

  if (tResult = _ErrOK)
  {
    tMaxLen # VarInfo(aValue);
    aValue # tMem->MemReadStr(1,min(tMaxLen,tMem->spLen),_CharsetUtf8);
    tMem->MemFree();
  }

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : get string argument value length.
//---------------------------------------------------------------------------------------

sub GetArgStrLen
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

  local
  {
    tArg            : handle;
  }

{
  tArg # GetArg(aPluginCmd,aName,aRetArg);
  if (tArg = 0)
    return(_ErrUnavailable);

  if (tArg->spType = _TypeInt and tArg->spID = sCmdValueIdMemory)
    return(tArg->spValueInt->spLen);
  else if (tArg->spType = _TypeAlpha)
    return(StrLen(tArg->spValueAlpha));
}

//---------------------------------------------------------------------------------------
// Public : get integer argument value.
//---------------------------------------------------------------------------------------

sub GetArgInt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : int;            // Value of argument.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

  local
  {
    tArg            : handle;
  }

{
  tArg # GetArg(aPluginCmd,aName,aRetArg);
  if (tArg = 0)
    return(_ErrUnavailable);

  if (tArg->spType != _TypeInt or tArg->spID != 0)
    return(_ErrType);

  aValue # tArg->spValueInt;
  return(_ErrOK);
}

//---------------------------------------------------------------------------------------
// Public : get logic argument value.
//---------------------------------------------------------------------------------------

sub GetArgLogic
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : logic;          // Value of argument.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

  local
  {
    tArg            : handle;
  }

{
  tArg # GetArg(aPluginCmd,aName,aRetArg);
  if (tArg = 0)
    return(_ErrUnavailable);

  if (tArg->spType != _TypeLogic)
    return(_ErrType);

  aValue # tArg->spValueLogic;
  return(_ErrOK);
}

//---------------------------------------------------------------------------------------
// Public : get string argument as memory content.
//---------------------------------------------------------------------------------------
sub GetArgMem
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  aValue            : handle;         // Value of argument as memory content.
  opt aMemCnvMode   : int;            // Convert option for MemCnv.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

  local
  {
    tArg            : handle;
    tMem            : handle;
    tResult         : int;
  }

{
  tArg # GetArg(aPluginCmd,aName,aRetArg);
  if (tArg = 0)
    return(_ErrUnavailable);

  if (aValue = 0 or HdlInfo(aValue,_HdlExists) = 0)
    return(_ErrHdlInvalid);
  if (HdlInfo(aValue,_HdlType) != _HdlMem)
    return(_ErrHdlInvalid);

  if (tArg->spType = _TypeInt and tArg->spID = sCmdValueIdMemory)
    tMem # tArg->spValueInt;
  else if (tArg->spType = _TypeAlpha)
  {
    tMem # MemAllocate(4096);
    if (tMem < 0)
      return(tMem);

    tMem->spCharset # _CharsetUtf8;
    tMem->MemWriteStr(1,tArg->spValueAlpha,_CharsetUtf8);
  }
  else
    return(_ErrType);

  aValue->spCharset # _CharsetUtf8;

  if (aMemCnvMode != 0)
    tResult # tMem->MemCnv(aValue,aMemCnvMode);
  else
  {
    if (tMem->spLen > 0 and aValue->MemResize(tMem->spLen) != _ErrOK)
      tResult # _ErrOutOfMemory;
    else
    {
      tMem->MemCopy(1,tMem->spLen,1,aValue);
      tResult # _ErrOK;
    }

    aValue->spLen # tMem->spLen;
  }

  if (tArg->spType = _TypeAlpha)
    tMem->MemFree();

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : get argument count.
//---------------------------------------------------------------------------------------
sub GetArgCount
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;
{
  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  if (aRetArg)
    return(gPluginCmd.Return->CteInfo(_CteCount));

  return(gPluginCmd.Args->CteInfo(_CteCount));
}

//---------------------------------------------------------------------------------------
// Public : get value of 'ExecResult' return argument.
//---------------------------------------------------------------------------------------

sub GetExecResult
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int;                                // Error code / ExecResult.

  local
  {
    tResult         : int;
    tExecResult     : int;
  }

{
  tResult # aPluginCmd->GetArgInt('ExecResult',var tExecResult,true);

  if (tResult = _ErrOK)
    return(tExecResult);

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : plug-in command encoding.
//---------------------------------------------------------------------------------------

sub Encode
(
  aPluginCmd        : handle;         // (in)  Handle to plug-in command.
  aOutput           : handle;         // (out) Memory object with encoded content.
)
: int;                                // Result.

  local
  {
    tResult         : int;
    tKindStr        : alpha;
    tName           : alpha(4096);
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaConverter,'Start');
@endif

  if (aPluginCmd > 0)
    VarInstance(Private_PluginCmd,aPluginCmd);

  while (true)
  {
    // Reset memory object.
    aOutput->spLen # 0;
    aOutput->spCharset # _CharsetUtf8;

    // Encode serial number.
    if (gPluginCmd.Serial > 0\b)
    {
      aOutput->MemWriteStr(_MemAppend,mInt64ToAlphaDec(gPluginCmd.Serial));
      aOutput->MemWriteStr(_MemAppend,'|');
    }
    else if (gPluginCmd.Serial < 0\b)
    {
      tResult # _ErrRange;
      break;
    }

    // Encode kind.
    tResult # Private_EncodeKind(gPluginCmd.Kind,var tKindStr);
    if (tResult != _ErrOK)
      break;

    aOutput->MemWriteStr(_MemAppend,tKindStr);

    if (gPluginCmd.Kind != sPluginCmdKindRet)
    {
      aOutput->MemWriteStr(_MemAppend,' ');

      // Encode command name.

      if (!Private_ScanNameStr(var gPluginCmd.Name,var tName,true))
      {
        tResult # _ErrNameInvalid;
        break;
      }

      aOutput->MemWriteStr(_MemAppend,gPluginCmd.Name,_CharsetUtf8);

      // Encode arguments.
      aOutput->MemWriteStr(_MemAppend, ' (');

      tResult # aOutput->Private_EncodeArgs(gPluginCmd.Args,gPluginCmd.Kind,FALSE);
      if (tResult != _ErrOK)
        break;

      aOutput->MemWriteStr(_MemAppend,')');
    }

    // Encode return values.
    aOutput->MemWriteStr(_MemAppend,' [');
    tResult # aOutput->Private_EncodeArgs(gPluginCmd.Return,gPluginCmd.Kind,TRUE);
    aOutput->MemWriteStr(_MemAppend,']');
    break;
  }

  if (tResult != _ErrOK)
    aOutput->spLen # 0;

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'End','Result',mIntToAlphaDec(tResult));
@endif
  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : plug-in command decoding.
//---------------------------------------------------------------------------------------

sub Decode
(
  aInput            : handle;         // (in)     Memory object with decoded content.
  aPluginCmd        : handle;         // (in/out) Handle to plug-in command.
)
: int;                                // Result.

  local
  {
    tResult         : int;
    tStartPos       : int;
    tEndPos         : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaConverter,'Start');
@endif

  if (aPluginCmd > 0)
  {
    VarInstance(Private_PluginCmd,aPluginCmd);
    aPluginCmd->ClearCmd();
  }

  tResult # _ErrOK;

  Private_DecodeInit();

  while (true)
  {
    // Decode (optional) serial number.
    gPluginCmd.Serial # C16_Plugin_Core:Private_DecodeSerial(aInput,var tStartPos);

    // Decode command kind.
    tStartPos # Private_DecodeKind(aInput,tStartPos,var gPluginCmd.Kind);
    if (tStartPos < 0)
    {
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaConverter,'Decode kind',tStartPos);
@endif
      tResult # tStartPos;
      break;
    }

    if (gPluginCmd.Kind != sPluginCmdKindRet)
    {
      // Decode command name.
      tStartPos # Private_FindFirstSpace(aInput,tStartPos);
      if (tStartPos < 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Decode command name',tStartPos);
@endif
        tResult # _ErrNameInvalid;
        break;
      }

      // Start of command name.
      tStartPos # Private_FindFirstWord(aInput,tStartPos);
      if (tStartPos < 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Start of command name',tStartPos);
@endif
        tResult # _ErrNameInvalid;
        break;
      }

      // End of command name.
      tEndPos # Private_ScanNameMem(aInput,var gPluginCmd.Name,tStartPos,true);
      if (tEndPos < 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'End of command name',tEndPos);
@endif
        tResult # tEndPos;
        break;
      }

      // Start of arguments.
      tStartPos # Private_FindFirstWord(aInput,tEndPos);
      if (tStartPos < 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Start of regular arguments',tStartPos);
@endif
        tResult # _ErrParserMissingComma; // _ErrParserMissingBracket; 17.03.2022 AH
        break;
      }

      tStartPos # Private_ScanArgs(aInput,aPluginCmd,tStartPos,false,false);
      if (tStartPos < 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Scan regular arguments',tStartPos);
@endif
        tResult # tStartPos;
        break;
      }
    }
    else
    {
      // Start of arguments.
      tStartPos # Private_FindFirstWord(aInput,tStartPos + StrLen(gPluginCmdConst.CmdToken[3]) - 1);
      if (tStartPos < 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Start of return arguments',tStartPos);
@endif
        tResult # _ErrParserMissingComma; // _ErrParserMissingBracket; 17.03.2022 AH
        break;
      }
    }

    tStartPos # Private_ScanArgs(aInput,aPluginCmd,tStartPos,true,gPluginCmd.Kind = sPluginCmdKindRet);
    if (tStartPos < 0)
    {
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaConverter,'Scan return arguments',tStartPos);
@endif
      tResult # tStartPos;
      break;
    }

    if (tStartPos + 1 != aInput->spLen)
    {
      if (Private_FindFirstWord(aInput,tStartPos + 1,true) >= 0)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Extra text at end',_ErrParserSyntax);
@endif
        tResult # _ErrParserSyntax;
        break;
      }
    }

    break;
  }

  Private_DecodeTerm();

  if (tResult != _ErrOK)
    aPluginCmd->ClearCmd();

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'End','Result',mIntToAlphaDec(tResult));
@endif
  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : receive command for instance.
//---------------------------------------------------------------------------------------

sub ReceiveCmd
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
  aPluginCmd       : handle; // Received plug-in command.
  var aInstanceID  : int;    // Regarding Instance ID.
  opt aWaitTimeout : int;    // Wait for message in milliseconds (0 = no wait).
)
: int;                       // Instance ID or error code.

  local
  {
    tResult        : int;
    tMem           : handle;
  }

{
  tMem # MemAllocate(_MemAutoSize);

  tResult # C16_Plugin_Core:ReceiveLine(aReceiverType,aReceiver,tMem,var aInstanceID,aWaitTimeout);

  if (tResult = _ErrOK)
    tResult # Decode(tMem,aPluginCmd);

  tMem->MemFree();
  return(tResult);
}

//---------------------------------------------------------------------------------------
// Plugin : send command.
//---------------------------------------------------------------------------------------

sub SendCmd
(
  aInstanceID      : int;             // (in) Instance ID.
  aPluginCmd       : handle;          // (in) Plug-in command to send.
  opt aWaitTimeout : int;             // (in) > 0 = sync mode (wait time in milli seconds for reply).
  opt aReplyCmd    : handle;
)
: int;

  local
  {
    tMemSend       : handle;
    tMemReply      : handle;
    tSerialSend    : int64;
    tSerialReply   : int64;
    tResult        : int;
    tWaitTimeout   : int;
  }

{
  tMemSend # MemAllocate(_MemAutoSize);

  // Encode plug-in command.
  tResult # Encode(aPluginCmd,tMemSend);
  if (tResult != _ErrOK)
  {
    tMemSend->MemFree();
    return(tResult);
  }

  if (aWaitTimeout > 0 and aReplyCmd > 0 and !aPluginCmd->IsCmdKindRet())
    tWaitTimeout # aWaitTimeout;
  else
    tWaitTimeout # 0;

  if (tWaitTimeout > 0)
  {
    tSerialSend # aPluginCmd->GetCmdSerial();
    tMemReply # MemAllocate(_MemAutoSize);
  }

  // Send command.
  tResult # C16_Plugin_Core:SendLine(aInstanceID,tMemSend,tWaitTimeout,tMemReply);
  tMemSend->MemFree();

  if (tResult = _ErrOK and tSerialSend > 0\b)
  {
    // Decode plug-in command.
    tResult # Decode(tMemReply,aReplyCmd);

    // Verify received serial number.
    tSerialReply # aReplyCmd->GetCmdSerial();
    if (tResult = _ErrOK)
    {
      if (tSerialSend != tSerialReply)
        tResult # _ErrGeneric;
      else if (!aReplyCmd->IsCmdKindRet())
        tResult # _ErrPluginCoreCmdKindMismatch;
    }
  }

  if (tWaitTimeout > 0)
    tMemReply->MemFree();

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : receive authentication command.
//---------------------------------------------------------------------------------------

sub ReceiveAuth
(
  aReceiverType    : int;    // (in)  Type of receiver.
  aReceiver        : int;    // (in)  Job control object / instance id.
  var aSerial      : int64;  // (out) Serial number.
  var aUser        : alpha;  // (out) User name
  opt aWaitTimeout : int;    // (in)  Maximum wait time in milli seconds.
)
: int;

  local
  {
    tInstanceID    : int;
    tCmd           : handle;
    tResult        : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaConverter,'Start');
@endif

  tCmd # CreateCmd();

  while (true)
  {
    // Receive command.
    tResult # ReceiveCmd(aReceiverType,aReceiver,tCmd,var tInstanceID,aWaitTimeout);

    if (tResult != _ErrOK)
    {
      C16_Plugin_Core:Private_SetJobState(aReceiverType,aReceiver,mJobStateDoJobEvent);
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaConverter,'ReceiveCmd failed',tResult);
@endif
      break;
    }

    // Verify instance id.
    if (aReceiverType = _ReceiverByInstanceID and tInstanceID != aReceiver)
    {
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaConverter,'Instance ID mismatch',_ErrGeneric);
@endif
      tResult # _ErrGeneric;
      break;
    }

@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceInfo1(_TraceAreaConverter,'Command received','Name',tCmd->GetCmdName());
@endif

    // Verify command.
    if (!tCmd->IsCmdName('designer.auth'))
    {
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaConverter,'Command name mismatch',_ErrGeneric);
@endif
      tResult # _ErrGeneric;
      break;
    }

    // Get user name.
    tResult # tCmd->GetArgStr('user',var aUser);
    if (tResult != _ErrOK)
    {
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaConverter,'Error retrieving argument "user"',tResult);
@endif
      break;
    }

    aSerial # tCmd->GetCmdSerial();
    break;
  }

  tCmd->DeleteCmd();

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'End','Result',mIntToAlphaDec(tResult));
@endif
  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : reply to authentication command.
//---------------------------------------------------------------------------------------

sub ReplyAuth
(
  aInstanceID          : int;         // (in) Instance ID.
  aSerial              : int64;       // (in) Serial number.
  aPluginName          : alpha(40);   // (in) Plugin short name.
  aPassword             : alpha;       // (in) password (C16 charset).
  opt aWaitTimeout     : int;         // (in) Maximum wait time in milli seconds.
  opt aDescriptiveName : alpha(4096); // (in) Plugin descriptive name.
  opt aDescription     : alpha(4096); // (in) Plugin description.
)
: int;

  local
  {
    tJobControl    : handle;
    tCmd           : handle;
    tResult        : int;
    tInstanceID    : int;
    tAccessGranted : logic;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaConverter,'Start');
@endif

  tCmd # CreateCmd(sPluginCmdKindRet,'',aSerial);
  tCmd->AddArgStr('pluginname',aPluginName,sPluginArgStrC16,true);
  tCmd->AddArgStr('password',aPassword,sPluginArgStrC16,true);
  tCmd->AddArgStr('descriptivename',aDescriptiveName,sPluginArgStrC16,true);
  tCmd->AddArgStr('description',aDescription,sPluginArgStrC16,true);

  // Send reply to A
  tResult # SendCmd(aInstanceID,tCmd);

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'SendCmd','Result',mIntToAlphaDec(tResult));
@endif

  if (tResult = _ErrOK)
  {
    tResult # ReceiveCmd(_ReceiverByInstanceID,aInstanceID,tCmd,var tInstanceID,aWaitTimeout);

    while (tResult = _ErrOK)
    {
      // Verify instance id.
      if (tInstanceID != aInstanceID)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Instance ID mismatch',_ErrGeneric);
@endif
        tResult # _ErrGeneric;
        break;
      }

      // Verify command.
      if (!tCmd->IsCmdName('designer.auth'))
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Command name mismatch',_ErrGeneric);
@endif
        tResult # _ErrGeneric;
        break;
      }

      // Get access granted / denied.
      tResult # tCmd->GetArgLogic('AccessGranted',var tAccessGranted);
      if (tResult != _ErrOK)
      {
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceError(_TraceAreaConverter,'Error retrieving argument "AccessGranted"',tResult);
@endif
        break;
      }

      if (!tAccessGranted)
        tResult # _ErrRights;
      break;
    }
  }

  C16_Plugin_Core:Private_SetJobState(_ReceiverByInstanceID,aInstanceID,mJobStateDoJobEvent);

  tCmd->DeleteCmd();

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'End','Result',mIntToAlphaDec(tResult));
@endif
  return(tResult);
}