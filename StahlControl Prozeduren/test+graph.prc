@A+
//===== Business-Control =================================================
//
//  Prozedur
//
//  Info
//
//
//  21.06.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
define begin
  cMaxDatei   : 910

  Aint(a)     : Cnvai(a,_FmtNumNoGroup)
  Trim(a)     : StrAdj(Cnvai(a,_FmtNumNoGroup),_Strbegin)
  TrimF(a,b)  : StrAdj(cnvaf(a,_Fmtnumnogroup,0,b),_Strbegin)
  gUsername   : UserInfo(_UserCurrent)
  TextAddLine(a,b):  TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
  Debug(a)    : Lib_Debug:Dbg_Debug(a)//;WinDialogBox(0,'DEBUG',a,_WinIcoInformation,_WinDialogOk,0)
  Str_Token(a,b,c)      : Lib_Strings:Strings_Token(a,b,c)
  Str_Count(a,b) : Lib_Strings:Strings_Count(a,b);
end;

declare BuildText(aFileName : Alpha(1000)) : logic;

//========================================================================
//
//
//========================================================================
MAIN
local begin
  vFile       : int;
  vTextName   : alpha(200);
  vBildName   : alpha(200);
  vPlainName  : alpha(200);
end;
begin
  Lib_debug:InitDebug();

  RecRead(903,1,_recFirst);

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

  // Graphtext erzeugen
  BuildText(vTextName);

  SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
  SysExecute('*'+vBildName, '',  _ExecWait);
end;


//========================================================================
//  WriteLn
//
//========================================================================
sub WriteLn(aFile : int; aText : alpha(1500));
begin
  aText # Lib_sTRings:STRings_DOS2WIN(aText);
  aText # aText + STRChar(13) + STRChar(10);
  FSIWrite(aFile, aText);
end;


//========================================================================
sub _DateiOK(aDatei : int): logic;
begin
  if (aDatei>=770) and (aDatei<=799) then RETURN false;
  if (aDatei<810) or (aDatei>889) then RETURN false;
  RETURN true;
end;


//========================================================================
//  BuildText
//
//========================================================================
sub BuildText(aFileName : Alpha(1000)) : logic;
local begin
  vI,vJ   : int;
  vK,vL   : int;
  vA      : alpha(500);
  vB,vC   : alpha(500);
  vFile   : int;
  vName   : alpha(200);
  vDatei  : int;
  vIndex  : int;
  v2Datei : int;
  v2Key   : int;
  vTxt    : int;
  v1z1    : int;
  vMax1z1 : int;
  vTiefe  : int;
  vD1,vD2 : int;
end;
begin
  vTxt # TextOpen(20);

  FOR vDatei # 1
  LOOP inc(vDatei)
  WHILE (vDatei<cMaxDatei) do begin
    if (FileInfo(vDatei, _FileExists)=0) then CYCLE;
    if (_dateiOk(vDatei)=false) then CYCLE;


    vA # '';
    v1z1 # 0;
    FOR vIndex # 1
    LOOP inc(vIndex)
    WHILE (LinkInfo(vDatei, vIndex, _LinkExists)>0) do begin
      v2Datei # LinkInfo(vDatei, vIndex,_LinkDestFileNumber);
      if (v2Datei=0) then CYCLE;

      v2Key # LinkInfo(vDatei, vIndex, _LinkDestKeyNumber);

      // 1zu1-Verknüpfung?
      if (KeyInfo(v2Datei, v2Key, _KeyFldCount) = Linkinfo(vDatei, vIndex, _LinkFldCount)) and
        (KeyInfo(v2Datei, v2Key, _KeyIsUnique)=1) then begin
        inc(v1z1);
        vA # vA + '|X'+aint(v2Datei);
      end;
    END;
    if (v1z1>vMax1z1) then vMax1z1 # v1z1;

    TextAddLine(vTxt, 'D'+aint(vDatei)+'|V'+cnvai(v1z1,0,0,3)+vA);
  END;

TextWrite(vTxt,'e:\debug\bla.txt', _TextExtern);

  // LOOPS killen
  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=TextInfo(vTxt,_TextLines)) do begin
    vA  # TextLineRead(vTxt, vI, 0);
    vD1 # cnvia(Str_Token(vA,'|',1));
    vA  # Str_Token(vA,'|',3);
    if (vA='') then CYCLE;
    FOR vJ # 1
    LOOP inc(vJ)
    WHILE vJ<=Str_Count(vA,'X') do begin
      vD2 # cnvia(Str_Token(vA, 'X', vJ+1));

      vL # TextSearch(vTxt, 1, 1, 0, 'D'+aint(vD2));
      if (vL=0) then CYCLE;
      vB # TextLineRead(vTxt, vL, 0);
      if (StrFind(vB,'X'+aint(vD1),0)>0) then begin
        vA # TextLineRead(vTxt, vI, _TextLineDelete);
        vA # Lib_Strings:Strings_ReplaceAll(vA, '|X'+aint(vD2),'');
        TextLineWrite(vTxt, vI, vA, _TextLineInsert);
//debug('ZIRKEL bei '+aint(vD1)+' nach '+aint(vD2));
      end;
    END;
  END;

TextWrite(vTxt,'e:\debug\bla2.txt', _TextExtern);

//TextRead(vTxt, 'E:\debug\bla99.txt', _TextExtern);
//vMax1z1 # 6;

  vTiefe # 0;
  REPEAT

debug('TIEFE:'+aint(vTiefe));
    FOR vI # TextSearch(vTxt, 1, 1, 0, 'V  0')
    LOOP vI # TextSearch(vTxt, 1, 1, 0, 'V  0')
    WHILE (vI<>0) do begin
      vA # TextLineRead(vTxt, vI, _TextLineDelete);
      vDatei # cnvia(Str_token(vA, '|',1));
      vName # Lib_Strings:Strings_DOS2XML(FileName(vDatei));

  Debug('    '+aint(vDatei)+' '+vName);

      FOR vI # TextSearch(vTxt, 1, 1, 0, '|X'+aint(vDatei))
      LOOP vI # TextSearch(vTxt, 1, 1, 0, '|X'+aint(vDatei))
      WHILE (vI<>0) do begin
        vA # TextLineRead(vTxt, vI, _TextLineDelete);
        vA # Lib_Strings:Strings_ReplaceAll(vA, '|X'+aint(vDatei),'');
/**
        vJ # cnvia(StrCut(vA,7,3));
        vJ # vJ - 1;
        if (vJ<0) then begin
          TextWrite(vTxt,'e:\debug\bla.txt', _TextExtern);
          TextClose(vTxt);
          RETURN true;
        end;
        vA # StrDel(vA,7,3);
        vA # StrIns(vA,cnvai(vJ,0,0,3),7);
**/
        TextAddLine(vTxt, vA);
      END;
    END;

    FOR vI # 1
    LOOP inc(vI);
    WHILE (vI<=TextInfo(vTxt,_TextLines)) do begin
      vA # TextLineRead(vTxt, vI, _TextLineDelete);
      vJ # Str_Count(vA,'X');
      vA # StrDel(vA,7,3);
      vA # StrIns(vA,cnvai(vJ,0,0,3),7);
      TextLineWrite(vTxt, vI, vA, _TextLineInsert);
    END;

    inc(vTiefe);
  UNTIL (vTiefe=vMax1z1);

TextWrite(vTxt,'e:\debug\bla3.txt', _TextExtern);
  TextClose(vTxt);


  vFile # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTRuncate);
  if (vFile=0) then RETURN false;

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="Strukturgramm";');
  Writeln(vFile, 'fontsize=20;');
  Writeln(vFile, 'ratio = "auto";');
  Writeln(vFile, 'mincross = 2.0;');
  Writeln(vFile, 'fontname="Arial";');
  WriteLn(vFile, 'labelloc="t";');
  WriteLn(vFile, 'labeljust="l";');


  WriteLn(vFile,'// Nodes ================================');
  FOR vDatei # 1
  LOOP inc(vDatei)
  WHILE (vDatei<cMaxDatei) do begin
    if (FileInfo(vDatei, _FileExists)=0) then CYCLE;
    if (_dateiOk(vDatei)=false) then CYCLE;

    vName # Lib_Strings:Strings_DOS2XML(FileName(vDatei));

    vA # 'id'+aint(vDatei);;
    vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
    vA # vA + '<TR><TD>'+vName+'</TD></TR>';
    vA # vA + '</TABLE></FONT>>, style=bold, color=green, shape=box]';
    WriteLn(vFile, vA+';');

    FOR vIndex # 1
    loop inc(vIndex)
    WHILE (LinkInfo(vDatei, vIndex, _LinkExists)>0) do begin
      if (_dateiOk(vDatei)=false) then CYCLE;

      v2Datei # LinkInfo(vDatei, vIndex,_LinkDestFileNumber);
      if (v2Datei=0) then CYCLE;

      v2Key # LinkInfo(vDatei, vIndex, _LinkDestKeyNumber);

      if (KeyInfo(v2Datei, v2Key, _KeyFldCount) = Linkinfo(vDatei, vIndex, _LinkFldCount)) and
        (KeyInfo(v2Datei, v2Key, _KeyIsUnique)=1) then begin
        vA # 'id'+aint(v2Datei)+' -> id'+aint(vDatei);
//        vA # vA + ' [weight=500, minlen=2, fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
//        vA # vA + '<TR><TD>Efwef'+'</TD></TR>';
        WriteLn(vFile, vA+';');
      end
      else begin
        CYCLE;
      end;

    END;

  END;
  WriteLn(vFile,'');

/**
  // Verbindungen suchen
  WriteLn(vFile,'// Ketten ===============================');

  FOR
      vB # '';
      RecLink(702,701,2,_recFirst);       // Arbeitsgang holen
      if ("BAG.P.Typ.1In-1OutYN") then begin  // 1zu1 ?
        vA # 'p'+TRim(BAG.IO.VonPosition)+' ->';
      end
      else begin
        //vA # 'p'+TRim(BAG.IO.VonPosition)+' ->';
        vA # 'p'+TRim(BAG.IO.VonPosition)+':';
        vA # vA + 'f'+TRim(BAG.IO.VonFertigung)+'p'+TRim(BAG.IO.VonPosition)+' ->';
      end;

      if (BAG.IO.NachBAG=0) then begin    // keine Weiterbearbeitung??
        vA # vA + ' id'+TRim(BAG.IO.id);
        vB # ', style=bold, color=red'; // dashed dotted
      end
      else begin
        vA # vA + ' p'+TRim(BAG.IO.NachPosition);
      end;

        vA # vA + ' [weight=500, minlen=2, fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
        vA # vA + '<TR><TD>E'+TRim(BAG.IO.UrsprungsID)+'</TD></TR>';
        vA # vA + '<TR><TD>'+Trim(BAG.IO.Plan.IN.Stk)+'Stk</TD></TR>';
        vA # vA + '<TR><TD>'+TrimF(BAG.IO.Plan.IN.GewN,0)+'kg</TD></TR>';
        if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '<TR><TD>('+TrimF(BAG.IO.Ist.IN.GewN,0)+'kg)</TD></TR>';

        vA # vA + '</TABLE></FONT>>'+ vB+', labeldistance=0.1]';

      WriteLn(vFile, vA+';');


  WriteLn(vFile,'');
**/


  WriteLn(vFile, '}');
  FSIClose(vFile);


  RETURN TRue;
end;

//========================================================================