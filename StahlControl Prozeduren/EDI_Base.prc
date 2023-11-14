@A+
//===== Business-Control =================================================
//
//  Prozedur  EDI_Base
//                    OHNE E_R_G
//  Info
//
//
//  21.09.2017  AH  Erstellung der Prozedur
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  05.04.2022  AH  ERX
//
//  mögliche Anker:
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_EDI


//========================================================================
//========================================================================
sub _StartWoF(
  aStarter  : int;
  aWoF      : int;
  aText     : alpha)
begin
//debugx('neue wof:'+aint(aStarter)+', '+aint(aWof)+' : '+aText);
  Lib_Workflow:Trigger(aStarter, aWoF,'', '' , aText);
end;


//========================================================================
//========================================================================
sub _EdiError(
  aStarter  : int;
  aWoF      : int;
  aText     : alpha)
begin

  if ( gUsergroup = 'JOB-SERVER' ) OR (gUsergroup = 'SOA_SERVER' ) then begin
    _StartWoF(aStarter, aWoF, aText);
    RETURN;
  end;

  Msg(99, aText+StrChar(13)+'(Workflow: '+aint(aWoF)+')', _WinIcoError, _windialogok, 1);
end;


//========================================================================
//========================================================================
sub _TryI(
  aA        : alpha;
  var aWert : int) : logic
begin
  try begin
    ErrTryCatch(_ErrCnv, y);
    aWert # Cnvia(aA);
  end;
  RETURN (ErrGet()=0);
end;


//========================================================================
//========================================================================
sub _TryF(
  aA        : alpha;
  var aWert : float) : logic
begin
  try begin
    ErrTryCatch(_ErrCnv, y);
    aWert # Cnvfa(aA, _FmtNumPoint);
  end;
  RETURN (ErrGet()=0);
end;


//========================================================================
//========================================================================
sub _TryD(
  aA        : alpha;
  var aWert : Date) : logic
begin
  try begin
    ErrTryCatch(_ErrCnv, y);
    aWert # Cnvda(aA);
  end;
  RETURN (ErrGet()=0);
end;


//========================================================================
//========================================================================
sub _NodeA(
  aNode     : int;
  var aErr  : alpha;
  aName     : alpha;
  var aWert : alpha) : logic;
local begin
  vCan      : logic;
  vNode     : int;
  vA        : alpha(1000);
end;
begin

  aWert # '';
  aErr  # '';
  if (StrCut(aName,1,1)='?') then begin
    vCan  # y;
    aName # StrCut(aName,2,100);
  end;

  if (Lib_EDI:_ReadNode(aNode, aName, var vNode)) then begin
    aErr # 'Element "'+aName+'" nicht gefunden';
    if (vCan) then RETURN true;
    RETURN false;
  end;
  Lib_XML:GetValue(vNode, var vA);

  try begin
    ErrTryCatch(_ErrCnv, y);
    ErrTryCatch(_ErrStringOverflow, y);
    aWert # vA;
  end;
  if (ErrGet()<>0) then begin
    aErr # 'Element "'+aName+'" zu lang';
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NodeI(
  aNode     : int;
  var aErr  : alpha;
  aName     : alpha;
  var aWert : int) : logic;
local begin
  vCan  : logic;
  vNode : int;
  vA    : alpha(1000);
end;
begin

  aWert # 0;
  aErr  # '';
  if (StrCut(aName,1,1)='?') then begin
    vCan  # y;
    aName # StrCut(aName,2,100);
  end;

  if (Lib_EDI:_ReadNode(aNode, aName, var vNode)) then begin
    aErr # 'Element "'+aName+'" nicht gefunden';
    if (vCan) then RETURN true;
    RETURN false;
  end;
  Lib_XML:GetValue(vNode, var vA);

  if (_TryI(vA, var aWert)=false) then begin
    aErr # 'Inhalt von "'+aName+'" ist kein Integer';
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub NodeW(
  aNode     : int;
  var aErr  : alpha;
  aName     : alpha;
  var aWert : word) : logic;
local begin
  vCan  : logic;
  vNode : int;
  vA    : alpha(1000);
end;
begin

  aWert # 0;
  aErr  # '';
  if (StrCut(aName,1,1)='?') then begin
    vCan  # y;
    aName # StrCut(aName,2,100);
  end;

  if (Lib_EDI:_ReadNode(aNode, aName, var vNode)) then begin
    aErr # 'Element "'+aName+'" nicht gefunden';
    if (vCan) then RETURN true;
    RETURN false;
  end;
  Lib_XML:GetValue(vNode, var vA);

  try begin
    ErrTryCatch(_ErrCnv, y);
    aWert # Cnvia(vA);
  end;
  if (ErrGet()<>0) then begin
    aErr # 'Inhalt von "'+aName+'" ist kein Word';
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NodeF(
  aNode     : int;
  var aErr  : alpha;
  aName     : alpha;
  var aWert : float) : logic;
local begin
  vCan  : logic;
  vNode : int;
  vA    : alpha(1000);
end;
begin

  aWert # 0.0;
  aErr  # '';
  if (StrCut(aName,1,1)='?') then begin
    vCan  # y;
    aName # StrCut(aName,2,100);
  end;

  if (Lib_EDI:_ReadNode(aNode, aName, var vNode)) then begin
    aErr # 'Element "'+aName+'" nicht gefunden';
    if (vCan) then RETURN true;
    RETURN false;
  end;
  Lib_XML:GetValue(vNode, var vA);

  if (_TryF(vA, var aWert)=false) then begin
    aErr # 'Inhalt von "'+aName+'" ist kein Float';
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NodeD(
  aNode     : int;
  var aErr  : alpha;
  aName     : alpha;
  var aWert : Date) : logic;
local begin
  vCan  : logic;
  vNode : int;
  vA    : alpha(1000);
end;
begin

  aWert # 0.0.0;
  aErr  # '';
  if (StrCut(aName,1,1)='?') then begin
    vCan  # y;
    aName # StrCut(aName,2,100);
  end;

  if (Lib_EDI:_ReadNode(aNode, aName, var vNode)) then begin
    aErr # 'Element "'+aName+'" nicht gefunden';
    if (vCan) then RETURN true;
    RETURN false;
  end;
  Lib_XML:GetValue(vNode, var vA);

  if (_TryD(vA, var aWert)=false) then begin
    aErr # 'Inhalt von "'+aName+'" ist kein Datum';
    RETURN false;
  end;

  RETURN true;
end;



//========================================================================
// _WertMinMax
//========================================================================
Sub _WertMinMax(
  aName     : alpha;
  aInhalt   : alpha;
  var aErr  : alpha;
  var aW1   : float;
  var aW2   : float) : logic;
local begin
  vF        : float;
end;
begin
  if (_TryF(aInhalt, var vF)=false) then begin
    aErr # 'Inhalt von "'+aName+'" ist kein Float';
    RETURN false;
  end;

  if (aW1=0.0) then
    aW1 # vF;
  aW1 # Min(aW1, vF);
  aW2 # Max(aW2, vF);

  RETURN true;
end;


//========================================================================
// _WertF
//========================================================================
Sub _WertF(
  aName     : alpha;
  aInhalt   : alpha;
  var aErr  : alpha;
  var aW1   : float;
) : logic;
local begin
  vF        : float;
end;
begin

  if (_TryF(aInhalt, var vF)=false) then begin
    aErr # 'Inhalt von "'+aName+'" ist kein Float';
    RETURN false;
  end;

  aW1 # vF;

  RETURN true;
end;


//========================================================================
//  CloseXML
//========================================================================
SUB CloseXML(
  aDoc  : int);
begin
    aDoc->CteClear( true );
    aDoc->CteClose();
end;


//========================================================================
//  OpenXML
//
//========================================================================
SUB OpenXML(
  aFileName   : alpha(1000);
  aTyp        : alpha;
  var aDoc    : int;
  var aRoot   : int;
) : alpha;
local begin
  Erx       : int;
  vOK       : logic;
  vVersuch  : int;
end;
begin

  if (aFilename='') then begin
    aFileName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'XML-Dateien|*.xml');
    if ( aFilename = '' ) then RETURN '';
  end;

  // 2023-01-25 AH  : Exlusiver Zugriff?
  REPEAT
    Erx # FsiOpen(aFileName, _FsiAcsRW);
    if (Erx=-27) then begin // Zugriff verweigert???
      inc(vVersuch);
      if (vVersuch>10) then RETURN 'Access denied!';
      Winsleep(250);
      CYCLE;
    end;
  UNTIL 1=1;
  FsiClose(Erx);

  /* XML Initialisierung */
  aDoc # CteOpen( _cteNode );
  aDoc->spId # _xmlNodeDocument;

  Erx # aDoc->XmlLoad(aFilename);
  if (Erx != _errOk ) then begin
    Msg(998017,' ('+xmlerror(_xmlerrortext)+')',0,0,0);
    CloseXML(aDoc);
    RETURN 'keine gültige XML-Datei';
  end;

  aRoot # aDoc->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aTyp);
  if (aRoot=0) then begin
    CloseXML(aDoc);
    RETURN 'XML-Datei nicht vom Typ "'+aTyp+'"';
  end;

  RETURN '';
end;


//========================================================================
