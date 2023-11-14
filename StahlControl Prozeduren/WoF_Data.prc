@A+
//===== Business-Control =================================================
//
//  Prozedur  WoF_Data
//                OHNE E_R_G
//  Info
//
//
//  27.04.2011  AI  Erstellung der Prozedur
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//  SUB Job_Timeout() : logic
//  SUB ZeigeGraph()
//
//========================================================================
@I:Def_Global

define begin
  WriteLn(a,b): BA1_Graph:Writeln(a,b)
end;

//========================================================================
//  Job_Timeout
//
//========================================================================
sub Job_Timeout() : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(980);
  TeM.Typ             # 'WOF';
  TeM.Erledigt.Datum  # 0.0.0;
  Erx # RecRead(980,2,0);
  Erx # RecRead(980,1,0);
  WHILE (Erx<=_rMultikey) and (TeM.Typ='WOF') and (TeM.Erledigt.Datum=0.0.0) and
    ((TeM.Ende.Bis.Datum<today) or
      ((Tem.Ende.Bis.Datum=today) and (TeM.Ende.Bis.Zeit<now)) ) do begin

//todo('TINEOUT!');
    RecRead(980,1,_recLock);
    TeM.Erledigt.Datum  # today;
    TeM.Erledigt.User   # gUserName;
    TeM.Erledigt.Zeit   # now;
    TeM.Erledigt.Datum  # today;
    RekReplace(980,_recUnlock,'AUTO');
Lib_Workflow:NextWOF('T');


    RecBufClear(980);
    TeM.Typ             # 'WOF';
    TeM.Erledigt.Datum  # 0.0.0;
    Erx # RecRead(980,2,0);
    Erx # RecRead(980,1,0);

//    Erx # RecRead(980,2,_RecNext);
  END;


  RETURN true;

end;



//========================================================================
//========================================================================
sub _BuildSub(
  aFile : int;
);
local begin
  Erx     : int;
  vA      : alpha;
  v941    : int;
  v942    : int;
end;
begin

  WriteLn(aFile, 'p'+AInt(WoF.Akt.Position)+' [label="'+AInt(WoF.Akt.Position)+') '+WoF.Akt.Name+'", shape=box]');

  v942 # RekSave(942);

  FOR Erx # RecLink(942,941,2,_RecFirst)  // nachfolgende Bed. holen
  LOOP Erx # RecLink(942,941,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
//  debugx('KEY942');
    case WoF.Bed.VonStatus of
      'Y' : vA # 'green';
      'N' : vA # 'red';
      otherwise
            vA # 'yellow';
    end;
    WriteLn(aFile,'p'+AInt(WoF.Bed.VonPosition)+' -> p'+AInt(WoF.Bed.Position)+' [style=dashed, color='+vA+']');

    v941 # RekSave(941);
    Erx # RekLink(941,942,2,_recFirst);   // Nachfolger holen
    if (Erx<=_rLocked) then _BuildSub(aFile);
    RekRestore(v941);
  END;

  RekRestore(v942);
end;


//========================================================================
// BuildGraphText
//
//========================================================================
sub BuildGraphText(
  aFileName : alpha;
  aWof      : int) : logic;
local begin
  Erx     : int;
  vS1,vS2 : int;
  vBuf941 : handle;
  vBuf942 : handle;
  vFile   : handle;
  vA,vC   : alpha;
  vTxt    : int;
  vI,vJ   : int;
end;
begin

  vFile # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTRuncate);
  if (vFile=0) then RETURN false;

  vBuf941 # RekSave(941);
  vBuf942 # RekSave(942);

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="Workflow '+AInt(aWof)+'"');
  Writeln(vFile, 'fontsize=20');
  WriteLn(vFile, 'labelloc="t"');
  WriteLn(vFile, 'labeljust="l"');
  WriteLn(vFile, 'rankdir="LR"');
  WriteLn(vFile, 'rank="same"');

  vTxt # TextOpen(20);

  RecBufClear(980);
  TeM.Wof.Nummer # aWOF;
  // alle erzeugten Termine aufnehmen...
  FOR Erx # RecRead(980,5,0)
  LOOP Erx # RecRead(980,5,_RecNext)
  WHILE (Erx<=_rMultikey) and (TeM.Wof.Nummer=aWOF) do begin
    if (vS1=0) then begin
      vS1 # TeM.Wof.SchemaNr;
      vS2 # TeM.Wof.Kontext;
//debugx('aus Schema:'+aint(vS1));
    end;

    if (TeM.InOrdnungYN) or (TeM.NichtInOrdnungYN) or (TeM.Erledigt.Datum<>0.0.0) then
      WriteLn(vFile, 'p'+AInt(TeM.WoF.Position)+' [label="'+AInt(Tem.Wof.Position)+') '+TeM.Bezeichnung+'", shape=box, style=filled, fillcolor=grey]')
    else
      WriteLn(vFile, 'p'+AInt(TeM.WoF.Position)+' [label="'+AInt(Tem.Wof.Position)+') '+TeM.Bezeichnung+'", shape=box, style=filled, fillcolor=cyan]');

    TextAddLine(vTxt, 'TEM'+aint(Tem.Nummer)+'x|aus'+aint("TeM.Wof.VorgängerTeM")+'x|Pos'+aint(TeM.Wof.Position)+'x');
  END;

TextAddLine(vTxt, '--------------');

  vI # 1;
  WHILE (vI<=TextInfo(vTxt,_TextLines)) do begin
    vA # TextLineRead(vTxt, vI, 0);
    vI # vI + 1;
    if (StrFind(vA,'TEM',0)=0) then CYCLE;

    vJ # cnvia(Lib_strings:Strings_Token(vA,'|',2));
    if (vJ<>0) then begin
      Tem.Nummer # vJ;
      RecRead(980,1,0);

      if (Tem.InOrdnungYN) then           vC # 'green'
      else if (TeM.NichtInOrdnungYN) then vC # 'red'
      else                                vC # 'yellow';

      vJ # cnvia(Lib_strings:Strings_Token(vA,'|',3));
      WriteLn(vFile,'p'+AInt(Tem.Wof.Position)+' -> p'+AInt(vJ)+' [color='+vC+']');
//TextAddline(vTxt, 'p'+AInt(Tem.Wof.Position)+' -> p'+AInt(vJ)+' [color='+vC+']');
    end;


    vJ # cnvia(Lib_strings:Strings_Token(vA,'|',1));
//debug('suche "aus'+aint(vJ));
    // sind Kinder da?
    if (TextSearch(vTxt, 1, 1, _TextSearchCI, 'aus'+aint(vJ)+'x')=0) then begin
//debug('kein Kind '+aint(vJ));
//        TextLineRead(vTxt, vJ, _TextLineDelete);
//        CYCLE;
      TextAddLine(vTxt,'Kinderlos'+aint(vJ));
    end;
  END;


//TextWrite(vTxt, '!!!1',0);


  // Kinderlose suchen...
  vI # 1;
  WHILE (vI<=TextInfo(vTxt,_TextLines)) do begin
    vA # TextLineRead(vTxt, vI, 0);
    vI # vI + 1;
    if (StrFind(vA,'Kinderlos',0)=0) then CYCLE;

    vJ # cnvia(vA);

    Tem.Nummer # vJ;
    RecRead(980,1,0); // Termin holen
    if (TeM.Erledigt.Datum<>0.0.0) then CYCLE;


    Wof.Akt.Nummer    # TeM.Wof.SchemaNr;
    Wof.Akt.Kontext   # TeM.WoF.Kontext;
    WoF.Akt.Position  # TeM.WoF.Position;
    RecRead(941,1,0); // WoF.Aktion holen

    _BuildSub(vFile);
  END;

  TextClose(vTxt);


  WriteLn(vFile, '}');
  FSIClose(vFile);

  RekRestore(vBuf941);
  RekRestore(vBuf942);

  RETURN TRue;
end;


//========================================================================
// ZEigeGraph
//========================================================================
Sub ZeigeGraph(aWof : int);
local begin
  vBildName : alpha;
  vTextName : alpha;
end;
begin

  if (aWof=0) then RETURN;

//debugx(aint(_Sys->spProcessMemorykb / 1024)+'MB');

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

  // Graphtext erzeugen
  BuildGraphText(vTextName, aWof);

  // Graph erstellen
  SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

  // externes Bild anzeigen
  Dlg_Bild('*'+vBildName);
end;

//========================================================================