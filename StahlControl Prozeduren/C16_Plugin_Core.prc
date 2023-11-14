//---------------------------------------------------------------------------------------
//
//  Prozedur    C16_Plugin_Cnv_Inc
//                    OHNE E_R_G
//
//---------------------------------------------------------------------------------------
@A+
@C+

@I:C16_Plugin_Core_Inc
//@I:Plugin.Trace.Inc

//@define PLUGIN_DEBUG_READWORKER
//@define PLUGIN_DEBUG_REPLYWORKER

//---------------------------------------------------------------------------------------
// Private : global macro defines.
//---------------------------------------------------------------------------------------

define
{
  mApiVersion         : '1.1.00'
  mApiVersionCompare  : '010100'
  mMaxPluginInstances : 10
  mChunkSize          : _Mem16K

  mGetJobState(aJob,aState) : ((aJob->spJobStatus & (aState)) = aState)
  mSetJobState(aJob,aState) : aJob->spJobStatus # aJob->spJobStatus | (aState)
  mClearJobState(aJob,aState) : aJob->spJobStatus # aJob->spJobStatus & ~(aState)

  // MSX messages.
  mMsxMsgLine         : 1   // Message line existing.
  mMsxMsgThreadTerm   : 2   // Socket-read thread has been terminated.
  mMsxMsgWaitSerial   : 3   // Wait for serial.

  // MSX items.
  mMsxItemInstanceID  : 1
  mMsxItemTextUtf8    : 2
  mMsxItemCode        : 3
}

declare SendLine
(
  aInstanceID      : int;    // Instance ID.
  aMem             : handle; // Memory object containing content to send.
  opt aWaitTimeout : int;    // > 0 = sync mode (wait time in milli seconds for reply).
  opt aMemReply    : handle; // Reply data in case of sync mode.
) : int;                       // Result error code.

declare GetJobControl
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
) : handle;                    // Handle to job control object.


//---------------------------------------------------------------------------------------
// Private : global plug-in data.
//---------------------------------------------------------------------------------------
global gPluginGlobalData
{
  gPluginGlobalDataUsage : int;
  gPluginInstanceID      : int[mMaxPluginInstances];
  gPluginInstances       : handle[mMaxPluginInstances];
  gPluginInstanceCounter : int;
  gPluginRuntime         : int;
  gPluginGUI             : logic;
  gPluginLastError       : int;
  gPluginSerial          : int64;
}

//---------------------------------------------------------------------------------------
// Private : global plug-in instance data.
//---------------------------------------------------------------------------------------
global gPluginInstanceData
{
  gPluginSocket        : handle;
  gPluginSckReadJob    : handle;
  gPluginReplyMsgJobID : int;
}

//---------------------------------------------------------------------------------------
// Private : decode serial number.
//---------------------------------------------------------------------------------------

sub Private_DecodeSerial
(
  aInput            : handle;         // (in)  Memory object with encoded content.
  var aStartPos     : int;            // (out) Starting position of message.
)
: int64;

 local
 {
   tPos             : int;
   tEndPos          : int;
   tSerial          : int64;
   tBuf             : alpha(32);
 }

{
  aStartPos # 0;
  tBuf # aInput->MemReadStr(1,min(32,aInput->spLen),_CharsetC16_1252);

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'Start','Buf',tBuf);
@endif

  tEndPos # StrFind(tBuf,'|',1);

  if (tEndPos > 0)
  {
    for tPos # 1 loop inc(tPos) while (tPos < tEndPos)
    {
      if (!mChrNum(StrCut(tBuf,tPos,1)))
        return(0\b);
    }

    try
    {
      ErrTryIgnore(_ErrCnv,_ErrCnv);
      tSerial # CnvBA(StrCut(tBuf,1,tEndPos - 1),0);
    }

    aStartPos # tEndPos;
  }

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaConverter,'End','Serial',mInt64ToAlphaDec(tSerial));
@endif
  return(tSerial);
}

//---------------------------------------------------------------------------------------
// Private : scan memory object from starting position for RET string.
//---------------------------------------------------------------------------------------

sub Private_ScanRET
(
  aInput            : handle;         // (in) Memory object with encoded content.
  aStartPos         : int;            // (in) Starting position of message.
)
: logic;                              // True if RET detected, false any other case.

  local
  {
    tPos     : int;
    tByte    : byte;
    tScanLen : int;
    tStr     : alpha(3);
  }

{
  tScanLen # min(aInput->spLen,64);

  for tPos # aStartPos loop inc(tPos) while (tPos <= tScanLen)
  {
    tByte # aInput->MemReadByte(tPos);
    if (tByte != 9 and tByte != 32)
      break;
  }

  if (tPos > tScanLen)
    return(false);

  tStr # StrCnv(aInput->MemReadStr(tPos,min(3,aInput->spLen - tPos + 1)),_StrUpper);
  return(tStr = 'RET');
}

//---------------------------------------------------------------------------------------
// Private : set last error code.
//---------------------------------------------------------------------------------------

sub Private_SetLastError
(
  opt aReturnCode  : int;
  opt aLastError   : int;
)
: int;
{
  if (VarInfo(gPluginGlobalData) != 0)
  {
    if (aLastError < _ErrOK)
      gPluginLastError # aLastError;
    else
      gPluginLastError # 0;
  }

  return(aReturnCode);
}

//---------------------------------------------------------------------------------------
// Private : get instance index.
//---------------------------------------------------------------------------------------

sub Private_InstanceIndexGet
(
  aInstanceID : int;
)
: handle;

  local
  {
    tIndex : int;
  }

{
  for tIndex # 1 loop inc(tIndex) while (tIndex <= mMaxPluginInstances)
  {
    if (gPluginInstanceID[tIndex] = aInstanceID)
      return(tIndex);
  }

  return(0);
}

//---------------------------------------------------------------------------------------
// Private : get unused instance entry.
//---------------------------------------------------------------------------------------

sub Private_FindUnused
: int;

  local
  {
    tIndex : int;
  }

{
  for tIndex # 1 loop inc(tIndex) while (tIndex <= mMaxPluginInstances)
  {
    if (gPluginInstanceID[tIndex] = 0)
      return(tIndex);
  }

  return(0);
}

//---------------------------------------------------------------------------------------
// Private : activate instance.
//---------------------------------------------------------------------------------------

sub Private_InstanceActivate
(
  aInstanceID : int;
)
: int;

  local
  {
    tIndex : int;
  }

{
  if (VarInfo(gPluginGlobalData) = 0)
    return(_ErrPluginCoreInit);
  if (aInstanceID < 1 or aInstanceID > mMaxPluginInstances)
    return(_ErrPluginCoreNoInstance);

  ErrTryCatch(_ErrAll,true);
  try
  {
    tIndex # Private_InstanceIndexGet(aInstanceID);
    VarInstance(gPluginInstanceData,gPluginInstances[tIndex]);
  }

  if (ErrGet() = _ErrOK)
    return(tIndex);

  return(Private_SetLastError(_ErrPluginCoreNoInstance,ErrGet()));
}

//---------------------------------------------------------------------------------------
// Private : terminate job by ID.
//---------------------------------------------------------------------------------------

sub Private_TerminateJob
(
  aJobID : int;
)

 local
 {
   tReplyJob : handle;
 }

{
  tReplyJob # JobOpen(aJobID);
  if (tReplyJob > 0)
  {
    tReplyJob->JobControl(_JobTerminate);
    tReplyJob->JobClose();
  }
}

//---------------------------------------------------------------------------------------
// Private : Send shut down command.
//---------------------------------------------------------------------------------------

sub Private_SendShutdown
(
  aIndex : int;
)

  local
  {
    tMem : handle;
  }

{
  if (gPluginInstanceID[aIndex] = 0)
    return;

  tMem # MemAllocate(_MemAutoSize);
  tMem->MemWriteStr(1,'CMD Designer.Plugins.Shutdown()');

  SendLine(gPluginInstanceID[aIndex],tMem);

  tMem->MemFree();
}

//---------------------------------------------------------------------------------------
// Private : instance close internally.
//---------------------------------------------------------------------------------------

sub Private_InstanceClose
(
  aIndex : int;
)
{
  // SignOff plugin.
  Private_SendShutdown(aIndex);

  // Terminate and close socket read worker.
  gPluginSckReadJob->JobControl(_JobTerminate);
  gPluginSckReadJob->JobClose();

  // Terminate reply worker.
  Private_TerminateJob(gPluginReplyMsgJobID);

  // Close socket connection.
  gPluginSocket->SckClose();

  // Cleanup instance data.
  VarFree(gPluginInstanceData);

  // Make index available.
  gPluginInstanceID[aIndex] # 0;
  gPluginInstances[aIndex] # 0;
}

//---------------------------------------------------------------------------------------
// Private : Get argument in string.
//---------------------------------------------------------------------------------------

sub Private_StrGetArg
(
  var aArguments : alpha; // Colon-separated arguments.
  aArgNo         : int;   // Argument number (>= 1).
)
: alpha;                  // Returns n-th argument value.

  local
  {
    tArg : int;
    tPos : int;
    tLen : int;
  }

{
  tPos # 1;

  for tArg # 1 loop inc(tArg) while (tArg < aArgNo)
  {
    tPos # StrFind(aArguments,',',tPos);

    if (tPos = 0)
      return('');

    inc(tPos);
  }

  tLen # StrFind(aArguments,',',tPos);
  if (tLen = 0)
    tLen # StrLen(aArguments);
  else
    dec(tLen,tPos);

  return(StrCut(aArguments,tPos,tLen));
}

//---------------------------------------------------------------------------------------
// Private : Add argument of type 'integer' to arguments.
//---------------------------------------------------------------------------------------

sub Private_StrAddArgInt
(
  var aArguments : alpha; // Colon-separated arguments.
  aValue         : int;   // Argument value.
)
: int;
{
  if (aArguments != '')
    aArguments # aArguments + ',';
  aArguments # aArguments + mIntToAlphaDec(aValue);
}

//---------------------------------------------------------------------------------------
// Private : Get argument of type 'integer' from arguments.
//---------------------------------------------------------------------------------------

sub Private_StrGetArgInt
(
  aArguments : alpha(4096); // Colon-separated arguments.
  aArgNo     : int;         // Argument number (>= 1).
)
: int;
{
  return(mAlphaToIntDec(Private_StrGetArg(var aArguments,aArgNo)));
}

//---------------------------------------------------------------------------------------
// Private : Add argument of type 'boolean' to arguments.
//---------------------------------------------------------------------------------------

sub Private_StrAddArgBool
(
  var aArguments : alpha; // Colon-separated arguments.
  aValue         : logic; // Argument value.
)
{
  if (aArguments != '')
    aArguments # aArguments + ',';
  aArguments # aArguments + mBoolToAlphaDec(aValue);
}

//---------------------------------------------------------------------------------------
// Private : Get argument of type 'boolean' from arguments.
//---------------------------------------------------------------------------------------

sub Private_StrGetArgBool
(
  aArguments : alpha(4096); // Colon-separated arguments.
  aArgNo     : int;         // Argument number (>= 1).
)
: logic;
{
  return(mAlphaToBoolDec(Private_StrGetArg(var aArguments,aArgNo)));
}

//---------------------------------------------------------------------------------------
// Private : read line into memory object.
//---------------------------------------------------------------------------------------

sub Private_SckReadMemAuto
(
  aMem       : handle;  // Memory object target.
  aSck       : handle;  // Socket handle.
  aChunkSize : int;     // Size for partial read.
)
: int;                  // Error result code.

  local
  {
    tLen : int;
    tRes : int;
  }

{
  if (aSck->SckInfo(_SckReadyRead) != '0')
    return(_ErrUnavailable);

  if (aMem->spSize != aChunkSize)
  {
    tRes # aMem->MemResize(aChunkSize);
    if (tRes != _ErrOK)
      return(tRes);
  }

  // Read line from socket.
  tRes # aSck->SckReadMem(_SckLine,aMem,1,aChunkSize);

  // Line too long.
  while (tRes = _ErrSckReadOverflow)
  {
    inc(tLen,aChunkSize);

    // Resize memory buffer.
    tRes # aMem->MemResize(aMem->spSize + aChunkSize);
    if (tRes != _ErrOK)
      break;

    // Continue line.
    tRes # aSck->SckReadMem(_SckLine,aMem,tLen + 1,aChunkSize);
  }

  if (tRes >= 0)
  {
    aMem->spLen # tLen + tRes;
    tRes # _ErrOK;
  }
  else
    aMem->spLen # 0;

  return(tRes);
}

//---------------------------------------------------------------------------------------
// Private : write line message to msx channel.
//---------------------------------------------------------------------------------------

sub Private_MsxWriteMsgLine
(
  aMsx        : handle;
  aInstanceID : int;
  aMem        : handle;

)

  local
  {
    tLen      : int;
  }

{
  tLen # aMem->spLen;

  aMsx->MsxWrite(_MsxMessage,mMsxMsgLine);
  aMsx->MsxWrite(_MsxItem,mMsxItemInstanceID);
  aMsx->MsxWrite(_MsxData,aInstanceID);
  aMsx->MsxWrite(_MsxItem,mMsxItemTextUtf8);
  aMsx->MsxWrite(_MsxData,tLen);
  aMsx->MsxWriteMem(aMem,1,tLen);
  aMsx->MsxWrite(_MsxEnd,0);
}

//---------------------------------------------------------------------------------------
// Private : write thread term message to msx channel.
//---------------------------------------------------------------------------------------

sub Private_MsxWriteMsgThreadTerm
(
  aMsx        : handle;
  aInstanceID : int;
  aCode       : int;
)
{
  aMsx->MsxWrite(_MsxMessage,mMsxMsgThreadTerm);
  aMsx->MsxWrite(_MsxItem,mMsxItemInstanceID);
  aMsx->MsxWrite(_MsxData,aInstanceID);
  aMsx->MsxWrite(_MsxItem,mMsxItemCode);
  aMsx->MsxWrite(_MsxData,aCode);
  aMsx->MsxWrite(_MsxEnd,0);
}

//---------------------------------------------------------------------------------------
// Private : read line message from msx channel.
//---------------------------------------------------------------------------------------

sub Private_MsxReadMsgLine
(
  aMsx            : handle;
  var aInstanceID : int;
  var aMem        : handle;
)
: int;

  local
  {
    tMsxItem  : int;
    tLen      : int;
    tResult   : int;
@ifdef PLUGIN_DEBUG_TRACE
    tLine     : alpha(4096);
@endif
  }

{
  while (aMsx->MsxRead(_MsxItem,tMsxItem) = _ErrOK)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceInfo1(_TraceAreaCore,'Item received','MsxItem',mIntToAlphaDec(tMsxItem));
@endif
    switch (tMsxItem)
    {
      // Instance ID.
      case mMsxItemInstanceID :
      {
        aMsx->MsxRead(_MsxData,aInstanceID);
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceInfo1(_TraceAreaCore,'mMsxItemInstanceID','InstanceID',mIntToAlphaDec(aInstanceID));
@endif
      }

      // Memory object containing UTF8-coded line of text.
      case mMsxItemTextUtf8 :
      {
        aMsx->MsxRead(_MsxData,tLen);

@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceInfo1(_TraceAreaCore,'mMsxItemTextUtf8','Len',mIntToAlphaDec(tLen));
@endif

        aMem->spCharset # _CharsetUtf8;
        aMem->MemResize(tLen);
        tResult # aMsx->MsxReadMem(aMem,1,tLen);

        if (tResult = _ErrOK)
          aMem->spLen # tLen;
        else
          aMem->spLen # 0;

@ifdef PLUGIN_DEBUG_TRACE
        tLine # aMem->MemReadStr(1,min(4096,tLen),_CharsetC16_1252);
        mPluginTraceInfo3(_TraceAreaCore,'mMsxItemTextUtf8','Len',mIntToAlphaDec(tLen),'Result',mIntToAlphaDec(tResult),'Line',tLine);
@endif
      }

      // End of message.
      case 0 :
        break;
    }
  }

  aMsx->MsxRead(_MsxEnd,tMsxItem);
  return(tResult);
}

//---------------------------------------------------------------------------------------
// Private : read thread term message from msx channel.
//---------------------------------------------------------------------------------------

sub Private_MsxReadMsgThreadTerm
(
  aMsx            : handle;
  var aInstanceID : int;
  var aCode       : int;
)

  local
  {
    tMsxItem      : int;
  }

{
  while (aMsx->MsxRead(_MsxItem,tMsxItem) = _ErrOK)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceInfo1(_TraceAreaCore,'Item received','MsxItem',mIntToAlphaDec(tMsxItem));
@endif
    switch (tMsxItem)
    {
      // Instance ID.
      case mMsxItemInstanceID :
      {
        aMsx->MsxRead(_MsxData,aInstanceID);
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceInfo1(_TraceAreaCore,'mMsxItemInstanceID','InstanceID',mIntToAlphaDec(aInstanceID));
@endif
      }

      case mMsxItemCode :
      {
        aMsx->MsxRead(_MsxData,aCode);
@ifdef PLUGIN_DEBUG_TRACE
        mPluginTraceInfo1(_TraceAreaCore,'mMsxItemCode','Code',mIntToAlphaDec(aCode));
@endif
      }

      // End of message.
      case 0 :
        break;
    }
  }

  aMsx->MsxRead(_MsxEnd,tMsxItem);
}

//---------------------------------------------------------------------------------------
// Private : add memory object to socket read queue.
//---------------------------------------------------------------------------------------

sub Private_SocketReadQueueAdd
(
  aQueue : handle;      // CteList handle.
  aMem   : handle;      // Memory object to add.
)
: int;

  local
  {
    tCteItem : handle;
    tMem     : handle;
    tResult  : int;
  }

{
  tResult # _ErrOK;

  while (true)
  {
    tCteItem # CteOpen(_CteItem);
    if (tCteItem = 0)
    {
      tResult # _ErrOutOfMemory;
      break;
    }

    if (aMem->spLen > 0)
    {
      tMem # MemAllocate(aMem->spLen);
      if (tMem < 0)
      {
        tResult # tMem;
        break;
      }

      aMem->MemCopy(1,aMem->spLen,1,tMem);
      tMem->spLen # aMem->spLen;
    }

    tCteItem->spID # tMem;
    aQueue->CteInsert(tCteItem,_CteLast);
    break;
  }

  if (tResult != _ErrOK)
  {
    if (tCteItem > 0)
      tCteItem->CteClose();
    if (tMem > 0)
      tMem->MemFree();
  }

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Private : remove first queue element and return memory object to caller.
//---------------------------------------------------------------------------------------

sub Private_SocketReadQueueRemoveFirst
(
  aQueue : handle;    // CteList handle.
  aMem   : handle;    // Handle to target memory object.
)
: logic;

  local
  {
    tCteItem : handle;
    tMem     : handle;
  }

{
  tCteItem # aQueue->CteRead(_CteFirst);

  if (tCteItem > 0)
  {
    tMem # tCteItem->spID;
    tCteItem->CteClose();

    if (tMem > 0)
    {
      tMem->MemCopy(1,tMem->spLen,1,aMem);
      aMem->spLen # tMem->spLen;
    }
    else
      aMem->spLen # 0;
  }

  return(tCteItem > 0);
}

//---------------------------------------------------------------------------------------
// Private : reply message worker thread.
//---------------------------------------------------------------------------------------

sub Private_ReplyMessageWorker
(
  aObjHdl  : handle;    // Task-object
  aEvtType : int;       // Event-type
)

  local
  {
    tMsxR       : handle;
    tMsxW       : handle;
    tHasWaitMsg : logic;
    tMem        : handle;
    tInstanceID : int;
    tMsxMsgId   : int;
  }

{
@ifdef PLUGIN_DEBUG_REPLYWORKER
  DbgConnect('127.0.0.1',n,n);
  Plugin.Trace:Init(_TraceAreaCore);
  mPluginTraceInfo(_TraceAreaCore,'Start');
@endif

  tMsxR # MsxOpen(_MsxThread | _MsxRead,aObjHdl);
  tMsxW # MsxOpen(_MsxThread | _MsxWrite,aObjHdl);

  tMem # MemAllocate(_MemAutoSize);

  while (!aObjHdl->spStopRequest)
  {
    if (aObjHdl->spJobMsxReadQ > 0)
    {
      // Open message.
      tMsxR->MsxRead(_MsxMessage,tMsxMsgId);

      if (tMsxMsgId = mMsxMsgLine and tMsxR->Private_MsxReadMsgLine(var tInstanceID,var tMem) = _ErrOK)
        mSetJobState(aObjHdl,mJobStateHaveReplyMsg);
      else
        mClearJobState(aObjHdl,mJobStateHaveReplyMsg);

@ifdef PLUGIN_DEBUG_REPLYWORKER
      mPluginTraceInfo2(_TraceAreaCore,'Reply Message Received','HaveReply',mBoolToAlphaDec(mGetJobState(aObjHdl,mJobStateHaveReplyMsg)),'InstanceID',mIntToAlphaDec(tInstanceID));
@endif
    }

    if (mGetJobState(aObjHdl,mJobStateSendReplyMsg | mJobStateHaveReplyMsg))
    {
@ifdef PLUGIN_DEBUG_REPLYWORKER
      mPluginTraceInfo1(_TraceAreaCore,'Send reply Message requested','InstanceID',mIntToAlphaDec(tInstanceID));
@endif

      tMsxW->Private_MsxWriteMsgLine(tInstanceID,tMem);
      mClearJobState(aObjHdl,mJobStateSendReplyMsg | mJobStateHaveReplyMsg);
    }

    SysSleep(10);
  }

  tMem->MemFree();

  tMsxR->MsxClose();
  tMsxW->MsxClose();

@ifdef PLUGIN_DEBUG_REPLYWORKER
  mPluginTraceInfo(_TraceAreaCore,'End');
  Plugin.Trace:Term();
@endif
}

//---------------------------------------------------------------------------------------
// Private : socket-read worker thread.
//---------------------------------------------------------------------------------------

sub Private_SocketReadWorker
(
  aObjHdl  : handle;    // Task-object
  aEvtType : int;       // Event-type
)

  local
  {
    tMsxR         : handle;
    tMsxW         : handle;
    tMsxWaitW     : handle;
    tMsgQueue     : handle;
    tMem          : handle;
    tRes          : int;
    tInstanceID   : int;
    tGUI          : logic;
    tReplyJob     : handle;
    tReplyJobID   : int;
    tDoJobEvent   : logic;
    tFireJobEvent : logic;
    tReplyMessage : logic;
    tStartPos     : int;
    tStopRequest  : logic;
@ifdef PLUGIN_DEBUG_READWORKER
    tLine         : alpha(4096);
@endif
  }

{
@ifdef PLUGIN_DEBUG_READWORKER
  DbgConnect('127.0.0.1',n,n);
  Plugin.Trace:Init(_TraceAreaCore);
  mPluginTraceInfo(_TraceAreaCore,'Start');
@endif

  tInstanceID # Private_StrGetArgInt(aObjHdl->spJobData,1);
  tGUI        # Private_StrGetArgBool(aObjHdl->spJobData,2);
  tReplyJobID # Private_StrGetArgInt(aObjHdl->spJobData,3);

@ifdef PLUGIN_DEBUG_READWORKER
  mPluginTraceInfo3(_TraceAreaCore,'Arguments','Instance ID',mIntToAlphaDec(tInstanceID),'GUI',mBoolToAlphaDec(tGUI),'ReplyJobID',mIntToAlphaDec(tReplyJobID));
@endif

  // Allocate memory and set charset.
  tMem # MemAllocate(mChunkSize);
  if (tMem < _ErrOK)
    return;

  tMem->spCharset # _CharsetUtf8;

  // Open msx channels.
  tMsxR # MsxOpen(_MsxThread | _MsxRead,aObjHdl);
  tMsxW # MsxOpen(_MsxThread | _MsxWrite,aObjHdl);

  // Create message queue.
  tMsgQueue # CteOpen(_CteList);

  tStopRequest # aObjHdl->spStopRequest;

  // Worker loop.
  while (!tStopRequest and tRes != _ErrSckDown and tRes != _ErrOutOfMemory)
  {
    if (tReplyJob = 0)
    {
      tRes # tMem->Private_SckReadMemAuto(aObjHdl->spJobSckHandle,mChunkSize);
      tDoJobEvent # tGUI and mGetJobState(aObjHdl,mJobStateDoJobEvent);

@ifdef PLUGIN_DEBUG_READWORKER
      if (tRes = _ErrOK)
      {
        tLine # tMem->MemReadStr(1,min(tMem->spLen,4096),_CharsetC16_1252);
        mPluginTraceInfo1(_TraceAreaCore,'Received message','Line',tLine);
      }
@endif
    }

    // Write received data to message channel.
    if (tRes = _ErrOK)
    {
      if (tReplyJob = 0)
        tReplyMessage # Private_DecodeSerial(tMem,var tStartPos) > 0\b and Private_ScanRet(tMem,tStartPos + 1);

      if (tReplyMessage)
      {
        tReplyJob # JobOpen(tReplyJobID);

@ifdef PLUGIN_DEBUG_READWORKER
        mPluginTraceInfo1(_TraceAreaCore,'Write reply (RET)','Job handle',mIntToAlphaDec(tReplyJob));
@endif

        if (tReplyJob > 0)
        {
          tMsxWaitW # MsxOpen(_MsxThread | _MsxWrite,tReplyJob);
          tMsxWaitW->Private_MsxWriteMsgLine(tInstanceID,tMem);
          tMsxWaitW->MsxClose();
          tReplyJob->JobClose();
          tReplyJob # 0;
        }
        else
          SysSleep(125);
      }
      else
      {
        tRes # tMsgQueue->Private_SocketReadQueueAdd(tMem);

@ifdef PLUGIN_DEBUG_READWORKER
        mPluginTraceInfo1(_TraceAreaCore,'Queue: Add message','Result',mIntToAlphaDec(tRes));
@endif
      }
    }

@ifdef PLUGIN_DEBUG_READWORKER
      mPluginTraceInfo1(_TraceAreaCore,'Queue: message count','Count',mIntToAlphaDec(tMsgQueue->CteInfo(_CteCount)));
@endif

    if (aObjHdl->spJobMsxWriteQ = 0)
    {
@ifdef PLUGIN_DEBUG_READWORKER
      mPluginTraceInfo(_TraceAreaCore,'Queue: processing next message');
@endif

      if (tMsgQueue->Private_SocketReadQueueRemoveFirst(tMem))
      {
        tMsxW->Private_MsxWriteMsgLine(tInstanceID,tMem);
        tFireJobEvent # tDoJobEvent;

@ifdef PLUGIN_DEBUG_READWORKER
        mPluginTraceInfo1(_TraceAreaCore,'MSX: Writing message','FireJobEvent',mBoolToAlphaDec(tFireJobEvent));
@endif
      }
      else
      {
@ifdef PLUGIN_DEBUG_READWORKER
        mPluginTraceInfo(_TraceAreaCore,'Queue: no waiting messages');
@endif
        tFireJobEvent # false;
      }
    }
@ifdef PLUGIN_DEBUG_READWORKER
    else
      mPluginTraceInfo(_TraceAreaCore,'MSX: queue not empty');
@endif

    if (tDoJobEvent and tFireJobEvent)
    {
      tFireJobEvent # aObjHdl->JobEvent() != _ErrOK;
@ifdef PLUGIN_DEBUG_READWORKER
      mPluginTraceInfo1(_TraceAreaCore,'Fired JobEvent','OK',mBoolToAlphaDec(!tFireJobEvent));
@endif
    }

    tStopRequest # aObjHdl->spStopRequest;
  }

  // Delete message queue.
  tMsgQueue->CteClear(true);
  tMsgQueue->CteClose();

  // Send thread-terminated message.
  if (tStopRequest)
    tRes # 0;

  tMsxW->Private_MsxWriteMsgThreadTerm(tInstanceID,tRes);

  if (tGUI)
    aObjHdl->JobEvent();

  // Cleanup resources.
  tMem->MemFree();
  tMsxW->MsxClose();
  tMsxR->MsxClose();

@ifdef PLUGIN_DEBUG_READWORKER
  mPluginTraceInfo1(_TraceAreaCore,'End','Result',mIntToAlphaDec(tRes));
  Plugin.Trace:Term();
@endif
}

//---------------------------------------------------------------------------------------
// Private : set or clear job state.
//---------------------------------------------------------------------------------------

sub Private_SetJobState
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
  aState           : long;
  opt aClear       : logic;
)
  : int;

  local
  {
    tJobControl    : int;
  }

{
  tJobControl # GetJobControl(aReceiverType,aReceiver);
  if (tJobControl < 0)
    return(tJobControl);

  if (aClear)
    mClearJobState(gPluginSckReadJob,aState);
  else
    mSetJobState(gPluginSckReadJob,aState);

  return(_ErrOK);
}

//---------------------------------------------------------------------------------------
// Private : wait for reply message to receive.
//---------------------------------------------------------------------------------------

sub Private_WaitForReply
(
  aJobID          : int;
  aWaitTimeout    : int;
  var aJobControl : handle;
)
: int;

  local
  {
    tStart    : int;
    tNow      : int;
    tTimeout  : int;
    tResult   : int;
  }

{
  aJobControl # 0;

  tResult # _ErrPluginCoreNoData;
  tStart  # SysTics();
  tNow    # tStart;

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaCore,'Start wait','WaitTimeout',mIntToAlphaDec(aWaitTimeout));
@endif

  // Wait loop.
  tTimeout # max(aWaitTimeout,0);
  while (tNow - tStart < tTimeout)
  {
    if (aJobControl <= 0)
      aJobControl # JobOpen(aJobID);

    if (aJobControl > 0)
    {
      if (mGetJobState(aJobControl,mJobStateHaveReplyMsg))
      {
        tResult # _ErrOK;
        break;
      }

      aJobControl->JobClose();
      aJobControl # 0;
    }

    tNow # SysTics();
    SysSleep(min(10,tTimeout));
  }

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaCore,'End wait');
@endif
  return(tResult);
}

//---------------------------------------------------------------------------------------
// Private : wait for message to receive.
//---------------------------------------------------------------------------------------

sub Private_WaitForMessage
(
  aJobControl  : handle;
  aWaitTimeout : int;
)
: int;

  local
  {
    tStart    : int;
    tNow      : int;
    tTimeout  : int;
    tResult   : int;
  }

{
  if (aJobControl->spJobMsxReadQ = 0)
  {
    tResult # _ErrPluginCoreNoData;
    tStart  # SysTics();
    tNow    # tStart;

@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceInfo1(_TraceAreaCore,'Start wait','WaitTimeout',mIntToAlphaDec(aWaitTimeout));
@endif

    // Wait loop.
    tTimeout # max(aWaitTimeout,0);
    while (tNow - tStart < tTimeout)
    {
      if (aJobControl->spJobMsxReadQ != 0)
      {
        tResult # _ErrOK;
        break;
      }

      tNow # SysTics();
      SysSleep(min(10,tTimeout));
    }

@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceInfo(_TraceAreaCore,'End wait');
@endif
  }

  return(tResult);
}

//---------------------------------------------------------------------------------------
// Public : get plug-in version.
//---------------------------------------------------------------------------------------

sub ApiInfo
(
  aMode : int;            // Type of information to retrieve
)
: alpha;
{
  switch (aMode)
  {
    case _ApiVersion :
      return(mApiVersion);
    case _ApiVersionCompare :
      return(mApiVersionCompare);
    default :
      return('');
  }
}

//---------------------------------------------------------------------------------------
// Retrieve last error code.
//---------------------------------------------------------------------------------------

sub GetLastError
()
: int
{
  if (VarInfo(gPluginGlobalData) = 0)
    return(_ErrPluginCoreInit);

  return(gPluginLastError);
}

//---------------------------------------------------------------------------------------
// Public : generate new plug-in instance.
//---------------------------------------------------------------------------------------

sub InstanceNew
(
  aPluginPort  : word;    // Plug-in port to connect to.
  opt aTimeout : int;     // Timeout (connect/read/write) in milliseconds.
  opt aFrame   : handle;  // Frame to receive EvtJob (Client only).
)
: int;

  local
  {
    tSck        : handle;
    tJob        : handle;
    tIndex      : int;
    tJobID      : int;
    tReplyJobID : int;
    tRuntime    : int;
    tStart      : int;
    tNow        : int;
    tJobData    : alpha(4096);
    tResult     : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo2(_TraceAreaCore,'Start','aPluginPort',CnvAI(aPluginPort),'aTimeout',CnvAI(aTimeout));
@endif

  // Allocate global plug-in data.
  if (VarInfo(gPluginGlobalData) = 0)
  {
    // Check platform.
    tRuntime # _Sys->spPlatform;
    if (tRuntime != _PfmClient4 and tRuntime != _PfmClient5 and tRuntime != _PfmSOA)
      return(_ErrPluginCorePlatform);

    VarAllocate(gPluginGlobalData);
    gPluginRuntime # tRuntime;
    gPluginGUI # tRuntime = _PfmClient4 or tRuntime = _PfmClient5;
  }

  // Clear last error.
  Private_SetLastError();

  tIndex # Private_FindUnused();
  if (tIndex = 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'Find unused instance',_ErrLimitExceeded);
@endif
    return(_ErrPluginCoreLimitReached);
  }

  // Connect to socket port.
  tStart # SysTics();
  tNow # tStart;
  tSck # SckConnect('*',aPluginPort,_SckOptDelay,aTimeout);

  while (tSck < 0 and tNow - tStart < aTimeout)
  {
    tSck # SckConnect('*',aPluginPort,_SckOptDelay,aTimeout);

    if (gPluginGUI)
      WinSleep(0);
    else
      SysSleep(0);

    tNow # SysTics();
  }

  if (tSck < 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'SckConnect',tSck);
@endif

    if (tNow >= tStart)
      return(Private_SetLastError(_ErrPluginCoreConnectTimeout,tSck));
    else
      return(Private_SetLastError(_ErrPluginCoreSckConnect,tSck));
  }

  // Start wait-message thread.
  tReplyJobID # JobStart(_JobThread,0,__PROC__ + ':Private_ReplyMessageWorker');

  if (tReplyJobID < 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'JobStart failed / wait-message worker',tReplyJobID);
@endif
    tSck->SckClose();
    return(Private_SetLastError(_ErrPluginCoreInternal,tJobID));
  }

  // Set job data.
  Private_StrAddArgInt(var tJobData,gPluginInstanceCounter+1);
  Private_StrAddArgBool(var tJobData,gPluginGUI);
  Private_StrAddArgInt(var tJobData,tReplyJobID);
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaCore,'JobStart','JobData',tJobData);
@endif

  // Start socket-read thread.
  tJobID # JobStart(_JobThread,0,__PROC__ + ':Private_SocketReadWorker',tJobData,'',tSck);

  //DbgTrace('Instance=' + CnvAI(gPluginInstanceCounter+1) + ', Socket='+CnvAI(tSck));

  if (tJobID < 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'JobStart failed / socket-read worker',tJobID);
@endif
    tSck->SckClose();
    Private_TerminateJob(tReplyJobID);
    return(Private_SetLastError(_ErrPluginCoreInternal,tJobID));
  }

  if (gPluginGUI and aFrame > 0)
    tJob # JobOpen(tJobID,aFrame);
  else
    tJob # JobOpen(tJobID);
  if (tJob < 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'JobOpen failed / socket-read worker',tJob);
@endif
    tSck->SckClose();
    Private_TerminateJob(tReplyJobID);
    return(Private_SetLastError(_ErrPluginCoreInternal,tJob));
  }

  // Global data usage counter.
  inc(gPluginGlobalDataUsage);

  // Unique counter, always incremented (= instance ID).
  inc(gPluginInstanceCounter);

  // Allocate per-instance data.
  gPluginInstances[tIndex] # VarAllocate(gPluginInstanceData);
  gPluginInstanceID[tIndex] # gPluginInstanceCounter;

  // Set instance data.
  gPluginSocket # tSck;
  gPluginSckReadJob # tJob;
  gPluginReplyMsgJobID # tReplyJobID;

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaCore,'End');
@endif

  // Return instance ID.
  return(gPluginInstanceCounter);
}

//---------------------------------------------------------------------------------------
// Public : close plug-in instance.
//---------------------------------------------------------------------------------------

sub InstanceClose
(
  aID : int;          // Plug-in instance ID to close.
)

  local
  {
    tIndex : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaCore,'Start','aID',CnvAI(aID));
@endif

  // Activate instance by ID.
  tIndex # Private_InstanceActivate(aID);
  if (tIndex <= 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'Instance activate',tIndex);
@endif
    return;
  }

  Private_InstanceClose(tIndex);

  // Free global data if unused.
  dec(gPluginGlobalDataUsage);
  if (gPluginGlobalDataUsage = 0)
    VarFree(gPluginGlobalData);

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaCore,'End');
@endif
}

//---------------------------------------------------------------------------------------
// Public : close all plug-in instances.
//---------------------------------------------------------------------------------------

sub InstanceCloseAll

  local
  {
    tIndex : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaCore,'Start');
@endif

  if (VarInfo(gPluginGlobalData) > 0)
  {
    ErrTryCatch(_ErrAll,true);
    try
    {
      for tIndex # 1 loop inc(tIndex) while (tIndex <= mMaxPluginInstances)
      {
        if (gPluginInstances[tIndex] > 0)
        {
@ifdef PLUGIN_DEBUG_TRACE
          mPluginTraceInfo1(_TraceAreaCore,'Closing instance','ID',CnvAI(gPluginInstanceID[tIndex]));
@endif
          VarInstance(gPluginInstanceData,gPluginInstances[tIndex]);
          Private_InstanceClose(tIndex);
        }
      }

      VarFree(gPluginGlobalData);
    }
  }

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceAuto(_TraceAreaCore,'End',ErrGet());
@endif
}

//---------------------------------------------------------------------------------------
// Public : get first or next instance ID.
//---------------------------------------------------------------------------------------

sub InstanceGet
(
  aMode           : int; // _InstanceModeGetFirst, _InstanceModeGetNext
  opt aInstanceID : int; // Reference in case of _InstanceModeGetNext
)
: int;

  local
  {
    tIndex      : int;
    tIndexFirst : int;
  }

{
  if (VarInfo(gPluginGlobalData) = 0)
    return(_ErrPluginCoreInit);

  switch (aMode)
  {
    case _InstanceModeGetFirst :
    {
      for tIndex # 1 loop inc(tIndex) while (tIndex <= mMaxPluginInstances)
      {
        if (gPluginInstanceID[tIndex] > 0)
          return(gPluginInstanceID[tIndex]);
      }
    }

    case _InstanceModeGetNext :
    {
      tIndexFirst # Private_InstanceIndexGet(aInstanceID);

      if (tIndexFirst < 1)
        return(0);

      for tIndex # tIndexFirst + 1 loop inc(tIndex) while (tIndex <= mMaxPluginInstances)
      {
        if (gPluginInstanceID[tIndex] > 0)
          return(gPluginInstanceID[tIndex]);
      }
    }
  }

  return(0);
}

//---------------------------------------------------------------------------------------
// Public : get Job control object from given information type.
//---------------------------------------------------------------------------------------
sub GetJobControl
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
)
: handle;                    // Handle to job control object.

  local
  {
    tJobControl    : handle;
    tResult        : int;
  }

{
  // Retrieve job control object.
  switch (aReceiverType)
  {
    case _ReceiverByJobControl :
      tJobControl # aReceiver;
    case _ReceiverByInstanceID :
    {
      tResult # Private_InstanceActivate(aReceiver);
      if (tResult < 0)
        return(tResult);

      tJobControl # gPluginSckReadJob;
    }
    default :
      tJobControl # _ErrPluginCoreArgumentInvalid;
  }

  return(tJobControl);
}

//---------------------------------------------------------------------------------------
// Public : get next serial number.
//---------------------------------------------------------------------------------------

sub NextSerial
()
: int64;
{
  if (VarInfo(gPluginGlobalData) = 0)
    return(CnvBI(_ErrPluginCoreInit));

  inc(gPluginSerial);
  return(gPluginSerial);
}

//---------------------------------------------------------------------------------------
// Public : receive line from job message queue.
//---------------------------------------------------------------------------------------

sub ReceiveLine
(
  aReceiverType    : int;    // Type of receiver.
  aReceiver        : int;    // Job control object / instance id.
  aTargetMem       : handle; // Memory object containing received line.
  var aInstanceID  : int;    // Regarding Instance ID.
  opt aWaitTimeout : int;    // Wait for message in milliseconds (0 = no wait).
  opt aWaitReply   : logic;  // Wait for reply message.
)
: int;                       // Instance ID or error code.

  local
  {
    tMsx          : handle;
    tMsxMsgId     : int;
    tCode         : int;
    tResult       : int;
    tJobControl   : handle;
    //tTics : int;
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaCore,'Start');
@endif

  // Wait for reply message.
  if (aWaitReply)
  {
    if (aReceiverType != _ReceiverByInstanceID)
      return(_ErrPluginCoreArgumentInvalid);

    tResult # Private_InstanceActivate(aReceiver);
    if (tResult < 0)
      return(tResult);

  //tTics # SysTics();

    tResult # Private_WaitForReply(gPluginReplyMsgJobID,aWaitTimeout,var tJobControl);

  //DbgTrace('ReceiveLine <1> ' + CnvAI(SysTics() - tTics));
  //tTics # SysTics();

     if (tResult = _ErrOK)
       mSetJobState(tJobControl,mJobStateSendReplyMsg);
  }

  // Wait for message.
  else
  {
    tJobControl # GetJobControl(aReceiverType,aReceiver);
    if (tJobControl < 0)
    {
@ifdef PLUGIN_DEBUG_TRACE
      mPluginTraceError(_TraceAreaCore,'GetJobControl',tJobControl);
@endif
      return(tJobControl);
    }

    tResult # tJobControl->Private_WaitForMessage(aWaitTimeout);
  }

  if (tResult != _ErrOK)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'No data received.',tResult);
@endif
    return(tResult);
  }

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo(_TraceAreaCore,'Receive Message');
@endif

  //DbgTrace('ReceiveLine <2> ' + CnvAI(SysTics() - tTics));
  //tTics # SysTics();

  // Open job's read queue.
  tMsx # MsxOpen(_MsxThread | _MsxRead,tJobControl);

  //DbgTrace('ReceiveLine <3> ' + CnvAI(SysTics() - tTics));
  //tTics # SysTics();

  // Open message.
  tResult # tMsx->MsxRead(_MsxMessage,tMsxMsgId);

  //DbgTrace('ReceiveLine <4> ' + CnvAI(SysTics() - tTics));
  //tTics # SysTics();

  // Process message.
  switch (tMsxMsgId)
  {
    case mMsxMsgLine :
      tResult # tMsx->Private_MsxReadMsgLine(var aInstanceID,var aTargetMem);

    case mMsxMsgThreadTerm :
      tMsx->Private_MsxReadMsgThreadTerm(var aInstanceID,var tCode);

    default :
      tResult # _ErrData;
  }

  //DbgTrace('ReceiveLine <5> ' + CnvAI(SysTics() - tTics));
  //tTics # SysTics();

  tMsx->MsxClose();

  //DbgTrace('ReceiveLine <6> ' + CnvAI(SysTics() - tTics));
  //tTics # SysTics();

  if (aWaitReply and tJobControl > 0)
    tJobControl->JobClose();

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo2(_TraceAreaCore,'End','Result',mIntToAlphaDec(tResult),'Code',mIntToAlphaDec(tCode));
@endif

  if (tCode != _ErrOK)
    return(Private_SetLastError(_ErrPluginCoreThreadTerm,tCode));
  if (tResult != _ErrOK)
    return(Private_SetLastError(_ErrPluginCoreReceive,tResult));

  return(_ErrOK);
}

//---------------------------------------------------------------------------------------
// Public : send message from instance.
//---------------------------------------------------------------------------------------
sub SendLine
(
  aInstanceID      : int;    // Instance ID.
  aMem             : handle; // Memory object containing content to send.
  opt aWaitTimeout : int;    // > 0 = sync mode (wait time in milli seconds for reply).
  opt aMemReply    : handle; // Reply data in case of sync mode.
)
: int;                       // Result error code.

  local
  {
    tResult       : int;
    tSck          : handle;
    tInstanceID   : int;
@ifdef PLUGIN_DEBUG_TRACE
    tLine         : alpha(4096);
@endif
  }

{
@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo2(_TraceAreaCore,'Start','InstanceID',mIntToAlphaDec(aInstanceID),'WaitTimeout',mIntToAlphaDec(aWaitTimeout));
@endif

  // Activate instance data.
  tResult # Private_InstanceActivate(aInstanceID);
  if (tResult < 0)
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'InstanceActivate',tResult);
@endif
    return(tResult);
  }

@ifdef PLUGIN_DEBUG_TRACE
  tLine # aMem->MemReadStr(1,min(4096,aMem->spLen),_CharsetC16_1252);
  mPluginTraceInfo1(_TraceAreaCore,'SckWriteMem','mem',tLine);
@endif

  // Send memory content.
  tResult # gPluginSocket->SckWriteMem(_SckLine,aMem,1,aMem->spLen);
  if (tResult = aMem->spLen)
    tResult # _ErrOK;
  else
  {
@ifdef PLUGIN_DEBUG_TRACE
    mPluginTraceError(_TraceAreaCore,'SckWriteMem',tResult);
@endif
    return(Private_SetLastError(_ErrPluginCoreSckWriteFailed,tResult));
  }

  // Receive reply.
  if (aWaitTimeout > 0 and aMemReply > 0)
    tResult # ReceiveLine(_ReceiverByInstanceID,aInstanceID,aMemReply,var tInstanceID,aWaitTimeout,true);

@ifdef PLUGIN_DEBUG_TRACE
  mPluginTraceInfo1(_TraceAreaCore,'End','Result',mIntToAlphaDec(tResult));
@endif
  return(tResult);
}