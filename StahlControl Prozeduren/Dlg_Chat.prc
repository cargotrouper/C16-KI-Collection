@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_Chat
//                    OHNE E_R_G
//  Info
//
//
//  28.03.2020  AH  Erstellung der Prozedur
//
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//
//========================================================================
@I:Def_Global


//========================================================================
// TextLoad
//              Text lesen
//========================================================================
sub TextLoad(opt aName : alpha)
local begin
  vTxtHdl     : int;          // Handle des Textes
  vDat        : date;
  vTim        : time;
  vUsr        : alpha;
end
begin
  $rtf.RtfEditor->wpautoupdate # false;

  // Text laden
  vTxtHdl # $rtf.RtfEditor->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $rtf.RtfEditor->wpdbTextBuf # vTxtHdl;
  end;

  if (aName='') then aName # Str_Token($rtf.RtfEditor->wpcustom,'|',1);
  
  if (TextRead(vTxtHdl, aName, _TextUnlock)>_rLocked) then begin
    // NEUER TEXT???
    TextClear(vTxtHdl);
    TextAddLine(vTxtHdl, '{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deftab1000{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fswiss\fprq2\fcharset0 Calibri;}}');
    TextAddLine(vTxtHdl, '{\colortbl ;\red100\green100\blue100;\red0\green176\blue80;\red190\green78\blue177;\red0\green0\blue0;}');
    TextAddLine(vTxtHdl, '{\*\generator Riched20 10.0.19041}\viewkind4\uc1');
//    TextAddLine(vTxtHdl, '{\comment USERLISTE}');
    TextAddLine(vTxtHdl, '\par');
//\b\cf0\strike\fs18                                                                                                     \strike0 30.03.2020\par
//\cf1\fs18 19:27 Uhr\tab\cf3\b\fs24 Alexander Herold \cf4\b0 los\par
    TextAddLine(vTxtHdl, '}');
    TextWrite(vTxtHdl, aName,0);
  end;

  // letzte Änderungsdaten holen
  vDat # TextInfoDate(vTxtHdl, _TextModified);
  vTim # TextInfotime(vTxtHdl, _TextModified);
  vUsr # TextInfoAlpha(vTxtHdl, _TextUserLast);
  $lbInfo->wpCustom # cnvad(vDat)+'|'+cnvat(vTim)+'|'+vUsr;
  $rtf.RtfEditor->wpcustom # aName+'|'+aint(TextInfo(vTxtHdl,_TextSize));
  $rtf.RtfEditor->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);

  $rtf.RtfEditor->wpautoupdate # true;
end;


//========================================================================
// EvtInit
//
//========================================================================
Sub EvtInit(
  aEvt  : event;
) : logic
local begin
  vHdl  : int;
end;
begin
  WinsearchPath(aEvt:obj);

  Lib_GuiCom:TranslateObject( aEvt:Obj );
end;


//========================================================================
sub ChatAddLine(
  aTxt      : int;
  aTxtName  : alpha;
  aDat      : alpha;
  aTim      : alpha;
  aUser     : alpha;
  aInhalt   : alpha(250)) : logic
local begin
  vI        : int;
  vA        : alpha(250);
  vDat      : alpha;
  vTim      : alpha;
  vUser     : alpha;
  vInhalt   : alpha(250);
  vTag      : alpha;
  vErg      : int;
  vAnz      : int;
end;
begin
  if (aTxt=0) then RETURN false;
  vI # TextInfo(aTxt, _TextLines);
  if (vI=0) then RETURN false;
  if (aTxtName='') then RETURN false;

  REPEAT
    inc(vAnz);
    if (vAnz>100) then RETURN false;
    vErg # TextRead(aTxt, aTxtName, _Textlock);
    if (vErg<>_rOK) then begin
      Winsleep(50);
      CYCLE;
    end;
  UNTIL (vErg=_rOK);

  vDat  # Str_Token($lbInfo->wpCustom,'|',1);
  vTim  # Str_Token($lbInfo->wpCustom,'|',2);
  vUser # Str_Token($lbInfo->wpCustom,'|',3);
  
  if (aUser<>vUser) or (aDat<>vDat) or (aTim<>vTim) then begin
    vTim  # '';
    vUser # '';
  end;

  aInhalt # Lib_Strings:Strings_DOS2RTF(aInhalt);

  if (vTim=aTim) then begin
    vInhalt # '\tab';
  end
  else begin
    vInhalt # '\cf1\fs18 '+aTim+' Uhr\tab';
  end;
  
  if (aUser=vUser) then
    vInhalt # vInhalt + '\cf4\b0 '+ aInhalt + '\par'
  else
    vInhalt # vInhalt + '\cf3\b\fs24 '+aUser+' \cf4\b0 '+ aInhalt + '\par'

  $lbInfo->wpCustom # aDat+'|'+aTim+'|'+aUser;

//  aInhalt # '\cf2\fs18 '+cnvat(now)+' Uhr\tab\cf4\b\fs24 '+aUser+' \cf1\b0 '+ aInhalt + '\par';     // Zeilenumbruch
//\cf2\fs18 09:11 Uhr\tab\cf4\b\fs24 Alexanderererre\par
//\pard\cf2\fs18 09:12 Uhr\cf3\fs16\tab\b\fs24 Sebastian Tennie \cf1\b0 Wer war das denn jetzt?\par
//\cf2\fs18 09:13 Uhr\tab\cf3\b\fs24 Sebastian Tennie \cf1\b0 Wer war das denn jetzt?\par
  
  // Ende des Textes = "}" suchen
  WHILE (vI>3) do begin
    vA # TextLineRead(aTxt, vI, 0);
//debug(aint(vI)+':'+vA);
    if (StrFind(vA,'{',1)>0) then RETURN false;
    if (StrFind(vA,'}',1)>0) then BREAK;
    dec(vI);
  END;
  if (vI<=3) then RETURN false;
  
  // \widctlpar     - irgendwas mit Umbruch
  // \pard...\par   - paragraphtext dazwischen
  // \fs            - fontsize*2
  // \sa \sb        - space after/before
  // \sl            - space beween lines
  // \slmutl        - line spacing 0=exact, 1=multi
  
  // anderers Datum?
  if (aDat<>vDat) then begin
//    vA # '\pard\brdrt\brdrs\brdrw10\brsp20 \widctlpar\sa160\sl252\slmult1\cf0\strike\fs22                                                                                                        \strike0 '+aDat+'\par';
    vA # '\b\cf0\strike\fs18                                                                                                                   \strike0 '+aDat+'\b0\par';
//\cf2\fs18
    TextLineWrite(aTxt, vI, vA, _TextLineInsert);
    inc(vI);
  end;
  
  TextLineWrite(aTxt, vI, vInhalt, _TextLineInsert);

//  TxtWrite(aTxt, aTxtName, _TextUnlock);
  vErg # TextWrite(aTxt, aTxtName, _TextUnlock);
  if (vErg<>_rOK) then RETURN false;
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtFocusInit(
  aEvt                  : event;        // Ereignis
  aFocusObject          : handle;       // Objekt, das den Fokus zuvor hatte
) : logic;
local begin
  vHdl  : int;
end;
begin

  if (aEvt:Obj->wpcustom='Start') then begin
    aEvt:Obj->wpColFocusBkg # Set.Col.Field.Cursor;
    aEvt:Obj->wpcustom # '';
    $rtf.RtfEditor->wpCurrentInt # 1;
    $rtf.RtfEditor->wpCurrentInt # TextInfo($rtf.RtfEditor->wpdbTextBuf,_textLines);  // letzte Zeile anspringen
  end;
  
  RETURN(true);
end;


//========================================================================
//========================================================================
sub Send()
local begin
  vDat  : date;
  vTim  : time;
  vUsr  : alpha;
  v800  : int;
end;
begin
  vDat # today;
  vTim # now;

  v800 # RecBufCreate(800);
  v800->Usr.USerName # gUsername;
  RecRead(v800,1,0);
  if (v800->Usr.Name<>'') then
    vUsr # v800->Usr.Name;
  if (v800->Usr.Vorname<>'') then begin
    if (vUsr='') then vUsr # v800->Usr.Vorname
    else vUsr # v800->Usr.vorname+' '+vUsr;
  end;
  RecBufDestroy(v800);
  
if (ChatAddLine($rtf.rtfeditor->wpDbTextBuf, Str_Token($rtf.RtfEditor->wpcustom,'|',1), cnvad(vDat), cnvat(vTim) , vUsr, $edText->wpcaption)) then
    $edText->wpcaption # '';
end;


//========================================================================
//  EvtFocusTerm
//            Fokus von Objekt wegnehmen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // nachfolgendes Objekt
) : logic
begin
  if (WinInfo(aEvt:Obj, _WinFocusKey) =_WinKeyReturn) then begin
    Send();
    RETURN False;
  end;
  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  Send();
  Winfocusset($edText, true);
  RETURN(true);
end;


//========================================================================
// Start
//
//========================================================================
sub Start(
  opt aThema    : alpha;
  opt aTextname : alpha) : logic;
local begin
  vID     : int;
  vMDI    : int;
  vDlg    : int;
  vTimer  : int;
end;
begin

  if (aTextName='') then aTextname # '!CHAT!2';

  vMDI # gMDI;
  if (gMDI=0) then vMDI # gFrmMain;
  if (gMDI=gMDINOtifier) or (gMDI=gMdiWorkbench) or (gMDI=gMdiMenu) then vMDI # gFrmMain;

  vDlg  # WinOpen('Dlg.Chat',_WinOpenDialog)
  
  if (aThema<>'') then vDlg->wpCaption # Translate('Diskussion')+' '+aThema;
  // Text laden
  TextLoad(aTextName);

  vTimer # SysTimerCreate(500, -1, vDlg);
  $lbTimer->wpcustom # aint(vTimer);

  vID     # vDlg->Windialogrun(0,vMDI);

  If (vId = _WinIdOk) then begin
    vDlg->winclose();
    RETURN true;
  end;

  vDlg->winclose();
  RETURN false;
end;


//========================================================================
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerID              : int;          // Timer-ID
) : logic;
local begin
  vTxtHdl   : int;
  vA,vB     : alpha;
end;
begin

  vTxtHdl # $rtf.RtfEditor->wpdbTextBuf;
  if (vTxtHdl=0) then RETURN true;

  vA # Str_Token($rtf.RtfEditor->wpcustom,'|',1);
  if (vA='') then RETURN true;

  if (Textread(vTxtHdl, vA, _TextNoContents)>_rLocked) then
    TextClear(vTxtHdl);
  
  if (Str_Token($rtf.RtfEditor->wpcustom,'|',2) <> aint(TextInfo(vTxtHdl,_textSize))) then begin
    TextLoad();
  end;
//# aName+'|'+aint(TextInfo(vTxtHdl,_TextSize));
  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  vHdl # cnvia($lbTimer->wpcustom);
  SysTimerClose(vHdl);
  TextClose($Rtf.RtfEditor->wpdbTextBuf);
  RETURN(true);
end;

//=========================================================================
//=========================================================================