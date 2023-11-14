//---------------------------------------------------------------------------------------
//
//  Prozedur    C16_Plugin_Cnv_Inc
//                    OHNE E_R_G
//
//  CONZEPT 16 - Plug-in Message Encoder/Decoder API
//             - (c) 2015 vectorsoft AG -
//
//---------------------------------------------------------------------------------------
//  Version : 1.0 / 2015-02-24
//---------------------------------------------------------------------------------------
//  Version : 1.1 / 2015-07-08 / - API downward compatible with CONZEPT 16 release 5.7.10
//                               - The use of new or extended functions requires
//                                 at least CONZEPT 16 designer release 5.8.01.
//                               - Added functionality to send binary data or large
//                                 strings (> 4096 characters).
//                               - Added ReplyAuth() for descriptive name and
//                                 description.
//                               - Added a comment to function declarations which
//                                 specifies the minimal version upon this function is
//                                 supported by the api.
//                / 2015-07-17 / - In some cases the Decode() function did not handle
//                                 umlaut characters correctly.
//                               - Memory leak when Decode() or Encode() was used with
//                                 memory objects or string handled as memory objects.
//---------------------------------------------------------------------------------------
@A+

//---------------------------------------------------------------------------------------
// Global macro defines.
//---------------------------------------------------------------------------------------

define begin
  sPluginCmdKindEvt : 0               // Event.
  sPluginCmdKindCmd : 1               // Command.
  sPluginCmdKindRet : 2               // Reply.

  sPluginArgStrC16  : 0               // CONZEPT 16 charset.
  sPluginArgStrISO  : 1               // ISO charset.
  sPluginArgStrUtf8 : 2               // UTF8 charset.
end;

/***
//---------------------------------------------------------------------------------------
// (1.0) Create plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:CreateCmd
(
  opt aKind             : int;
  opt aName             : alpha(4096);
  opt aSerial           : int64;
)
: handle;

//---------------------------------------------------------------------------------------
// (1.0) Delete plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:DeleteCmd
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
);

//---------------------------------------------------------------------------------------
// (1.0) Clear plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:ClearCmd
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  opt aKind         : int;
  opt aName         : alpha(4096);
  opt aSerial       : int64;
);

//---------------------------------------------------------------------------------------
// (1.0) Retrieve command name.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetCmdName
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: alpha;

//---------------------------------------------------------------------------------------
// (1.0) Compare given command name with plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:IsCmdName
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aCmdName          : alpha(4096);    // Command name to compare.
)
: logic;

//---------------------------------------------------------------------------------------
// (1.0) Retrieve command kind.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetCmdKind
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Test command kind.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:IsCmdKindEvt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: logic;

declare C16_Plugin_Cnv:IsCmdKindCmd
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: logic;

declare C16_Plugin_Cnv:IsCmdKindRet
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: logic;

//---------------------------------------------------------------------------------------
// (1.0) Retrieve command serial number (> 0 if any, 0 if omitted).
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetCmdSerial
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int64;

//---------------------------------------------------------------------------------------
// (1.0) Retrieve last error occured.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetLastError
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Add argument to plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:AddArgStr
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : alpha(4096);    // Argument value.
  aValueCharset     : int;            // Charset of value.
  opt aReturnArg    : logic;          // Function / Return argument.
);

declare C16_Plugin_Cnv:AddArgInt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : int;            // Argument value.
  opt aReturnArg    : logic;          // Function / Return argument.
);

declare C16_Plugin_Cnv:AddArgLogic
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : logic;          // Argument value.
  opt aReturnArg    : logic;          // Function / Return argument.
);

//---------------------------------------------------------------------------------------
// (1.1) Add argument to plug-in command with arbitrary content.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:AddArgMem
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
  aValue            : handle;         // Argument value (copies memory object).
  opt aMemCnvMode   : int;            // Convert option for MemCnv.
  opt aReturnArg    : logic;          // Function / Return argument.
);

//---------------------------------------------------------------------------------------
// (1.0) Add return argument to plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:AddArgRet
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Argument name.
);

//---------------------------------------------------------------------------------------
// (1.1) Add 'execution result' return argument to plug-in command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:AddExecResult
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
);

//---------------------------------------------------------------------------------------
// (1.0) Get argument by name.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArg
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: handle;                             // Handle to CteNode object.

//---------------------------------------------------------------------------------------
// (1.0) Get argument by number.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgByNum
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aArgNum           : int;            // Argument number / one-based.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: handle;

//---------------------------------------------------------------------------------------
// (1.0) Get string argument value.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgStr
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : alpha;          // Value of argument (UTF-8).
  opt aRetArg       : logic;          // (1.1) 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.1) Get string argument value from base64 coded string.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgStrDecB64
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : alpha;          // Value of argument (UTF-8).
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.1) Get string argument value length.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgStrLen
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Get integer argument value.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgInt
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : int;            // Value of argument.
  opt aRetArg       : logic;          // (1.1) 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Get logic argument value.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgLogic
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  var aValue        : logic;          // Value of argument.
  opt aRetArg       : logic;          // (1.1) 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.1) Get string argument as memory content.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgMem
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  aName             : alpha(4096);    // Name of argument to retrieve.
  aValue            : handle;         // Value of argument as memory content.
  opt aMemCnvMode   : int;            // Convert option for MemCnv.
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Get argument count.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetArgCount
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
  opt aRetArg       : logic;          // 'Return argument' y/n.
)
: int;

//---------------------------------------------------------------------------------------
// (1.1) Get value of 'ExecResult' return argument.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:GetExecResult
(
  aPluginCmd        : handle;         // Handle of plug-in command (0 = current).
)
: int;                                // Error code / ExecResult.

//---------------------------------------------------------------------------------------
// (1.0) Plug-in command encoding.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:Encode
(
  aPluginCmd        : handle;         // (in)  Handle of plug-in command (0 = current).
  aOutput           : handle;         // (out) Memory object with encoded content.
)
: int;                                // Result.

//---------------------------------------------------------------------------------------
// (1.0) Plug-in command decoding.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:Decode
(
  aInput            : handle;         // (in)     Memory object with encoded content.
  aPluginCmd        : handle;         // (in/out) Handle to decoded plug-in command.
)
: int;                                // Result.

//---------------------------------------------------------------------------------------
// (1.0) Receive command for instance.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:ReceiveCmd
(
  aReceiverType    : int;             // (in)  Type of receiver.
  aReceiver        : int;             // (in)  Job control object / instance id.
  aPluginCmd       : handle;          // (in)  Received plug-in command.
  var aInstanceID  : int;             // (out) Regarding Instance ID.
  opt aWaitTimeout : int;             // (in)  Wait for message in milliseconds (0 = no wait).
)
: int;                                // Instance ID or error code.

//---------------------------------------------------------------------------------------
// (1.0) Send command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:SendCmd
(
  aInstanceID      : int;             // (in) Instance ID.
  aPluginCmd       : handle;          // (in) Plug-in command to send.
  opt aWaitTimeout : int;             // (in) > 0 = sync mode (wait time in milli seconds for reply).
  opt aReplyCmd    : handle;
)
: int;

//---------------------------------------------------------------------------------------
// (1.0) Receive authentication command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:ReceiveAuth
(
  aReceiverType    : int;    // (in)  Type of receiver.
  aReceiver        : int;    // (in)  Job control object / instance id.
  var aSerial      : int64;  // (out) Serial number.
  var aUser        : alpha;  // (out) User name
  opt aWaitTimeout : int;    // (in)  Maximum wait time in milli seconds.
)
: int;                       // Handle to plug-in command or error code.

//---------------------------------------------------------------------------------------
// (1.0) Reply to authentication command.
//---------------------------------------------------------------------------------------

declare C16_Plugin_Cnv:ReplyAuth
(
  aInstanceID          : int;         // (in) Instance ID.
  aSerial              : int64;       // (in) Serial number.
  aPluginName          : alpha(40);   // (in) Plugin short name.
  var aPassword        : alpha;       // (in) password (C16 charset).
  opt aWaitTimeout     : int;         // (in) Maximum wait time in milli seconds.
  opt aDescriptiveName : alpha(4096); // (1.1) (in) Plugin descriptive name.
  opt aDescription     : alpha(4096); // (1.1) (in) Plugin description.
)
: int;

***/
