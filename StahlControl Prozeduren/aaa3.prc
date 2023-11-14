@A+
//===== Business-Control =================================================
//
//  Prozedur
//
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

sub Msg(aText : alpha)
begin
  WindialogBox(0, 'Sockettext', aText ,0,0,0)
end

//========================================================================
MAIN
local begin
  vSock : int;
  vA    : alpha(4000);
end;
begin

  vSock # SckConnect('ip4:127.0.0.1', 13000);
Msg('connected');
  SckRead(vSock,_SckLine, vA);
Msg('Got:'+vA);
  SckWrite(vSock,_SckLine, 'exit');
  
  SckClose(vSock);
  
end;

//========================================================================