//---------------------------------------------------------------------------------------
//
//  Prozedur    C16_Plugin_Core_Inc
//                    OHNE E_R_G
//
//  CONZEPT 16 - Plug-in Application Programming Interface (Core API)
//                 - (c) 2015 vectorsoft AG -
//
//---------------------------------------------------------------------------------------
//  Version : 1.0 / 2015-01-22
//---------------------------------------------------------------------------------------
//  Version : 1.1 / 2015-07-08 / - API downward compatible with CONZEPT 16 release 5.7.10
//                               - The use of new or extended functions requires
//                                 at least CONZEPT 16 designer release 5.8.01.
//                               - SendLine() can be executed in sync/async mode.
//                               - Extended ReceiveLine() to wait for reply message.
//                               - New function NextSerial() to obtain unique serial
//                                 respone id.
//                               - New information type _ApiVersionCompare for function
//                                 ApiVersion().
//---------------------------------------------------------------------------------------
@A+
//---------------------------------------------------------------------------------------
// Global macro defines.
//---------------------------------------------------------------------------------------
define begin
  // Values for argument 'aMode' of function 'ApiInfo'.

  _ApiVersion        : 1 // (1.0) Displayable api version.
  _ApiVersionCompare : 2 // (1.1) Compareable api version.

  // Values for argument 'aMode' of function 'InstanceGet'.

  _InstanceModeGetFirst : 1
  _InstanceModeGetNext  : 2

  // Values for argument 'aReceiverType' of function 'ReceiveLine'.
  _ReceiverByJobControl : 1
  _ReceiverByInstanceID : 2

  // Read worker status flags.
  mJobStateDoJobEvent     : 0x00000001  // Fire job event.

  // Wait message worker status flags.
  mJobStateHaveReplyMsg   : 0x00000001  // Reply message existing.
  mJobStateSendReplyMsg   : 0x00000002  // Send reply message.

  // Standard number conversion.
  mIntToAlphaHex(a)   : CnvAI(a,_FmtNumHex,0,8)
  mIntToAlphaDec(a)   : CnvAI(a,_FmtInternal)
  mInt64ToAlphaHex(a) : CnvAB(a,_FmtNumHex,0,16)
  mInt64ToAlphaDec(a) : CnvAB(a,_FmtInternal)
  mBoolToAlphaDec(a)  : CnvAI(CnvIL(a),_FmtInternal)

  mAlphaToIntHex(a)   : CnvIA(a,_FmtNumHex)
  mAlphaToIntDec(a)   : CnvIA(a)
  mAlphaToInt64Hex(a) : CnvBA(a,_FmtNumHex)
  mAlphaToInt64Dec(a) : CnvBA(a)
  mAlphaToBoolDec(a)  : CnvLI(CnvIA(a))

  // Digit verification.
  mChrNum(c)      : (c >= '0' and c <= '9')
end;

//---------------------------------------------------------------------------------------
// Error values.
//---------------------------------------------------------------------------------------
define begin
  _ErrPluginCoreBase            : -11000
  _ErrPluginCorePlatform        : _ErrPluginCoreBase - 1  // Platform not supported.
  _ErrPluginCoreLimitReached    : _ErrPluginCoreBase - 2  // Resource limit reached.
  _ErrPluginCoreSckConnect      : _ErrPluginCoreBase - 3  // Socket connect failed.
  _ErrPluginCoreConnectTimeout  : _ErrPluginCoreBase - 4  // Socket connect timeout.
  _ErrPluginCoreInternal        : _ErrPluginCoreBase - 5  // Internal error occured.
  _ErrPluginCoreInit            : _ErrPluginCoreBase - 6  // Plugin initialisation not done.
  _ErrPluginCoreNoData          : _ErrPluginCoreBase - 7  // No data.
  _ErrPluginCoreReceive         : _ErrPluginCoreBase - 8  // Receive data failed.
  _ErrPluginCoreNoInstance      : _ErrPluginCoreBase - 9  // Instance not existing.
  _ErrPluginCoreThreadTerm      : _ErrPluginCoreBase - 10 // Thread has been terminated.
  _ErrPluginCoreSckWriteFailed  : _ErrPluginCoreBase - 11 // Write to socket failed.
  _ErrPluginCoreCmdKindMismatch : _ErrPluginCoreBase - 12 // (1.1) Command kind mismatch.
  _ErrPluginCoreArgumentInvalid : _ErrPluginCoreBase - 13 // (1.1) Invalid argument.
end;


/****

//---------------------------------------------------------------------------------------
// (1.0) Get plug-in version.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:ApiInfo
(
  aMode : int;            // Type of information to retrieve
)
: alpha;

//---------------------------------------------------------------------------------------
// (1.0) Retrieve last error code.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:GetLastError
()
: int;

//---------------------------------------------------------------------------------------
// (1.0) Generate new plug-in instance.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:InstanceNew
(
  aPluginPort  : word;    // Plug-in port to connect to.
  opt aTimeout : int;     // Timeout (connect/read/write) in milliseconds.
  opt aFrame   : handle;  // Frame to receive EvtJob (Client only).
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Close plug-in instance.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:InstanceClose
(
  aID : int;          // Plug-in instance ID to close.
);

//---------------------------------------------------------------------------------------
// (1.0) Close all plug-in instances.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:InstanceCloseAll
();

//---------------------------------------------------------------------------------------
// (1.0) Get first or next instance ID.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:InstanceGet
(
  aMode           : int; // _InstanceModeGetFirst, _InstanceModeGetNext
  opt aInstanceID : int; // Reference in case of _InstanceModeGetNext
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Get Job control object from given information type.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:GetJobControl
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
)
: handle;                    // Handle to job control object.

//---------------------------------------------------------------------------------------
// (1.1) Get next serial number to use with synchronous command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:NextSerial
()
: int64;                     // Next serial number (> 0) or error code (<0).

//---------------------------------------------------------------------------------------
// (1.0) Receive message for instance.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:ReceiveLine
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
  aTargetMem       : handle; // Memory object containing received line.
  var aInstanceID  : int;    // Regarding Instance ID.
  opt aWaitTimeout : int;    // Wait for message in milliseconds (0 = no wait).
  opt aWaitReply   : logic;  // (1.1) Wait for reply message.
)
: int;                       // Instance ID or error code.

//---------------------------------------------------------------------------------------
// (1.0) Send message from instance.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Core:SendLine
(
  aInstanceID      : int;    // Instance ID.
  aMem             : handle; // Memory object containing content to send.
  opt aWaitTimeout : int;    // > 0 = sync mode (wait time in milli seconds for reply).
  opt aMemReply    : handle; // Reply data in case of sync mode (aWaitTimeout > 0).
)
: int;                      // Result error code.

***/