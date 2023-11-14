@A+
//===== Business-ConTRol =================================================
//
//  Prozedur    BA1_Graph
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  07.01.2015  AH  alle Labels jetzt als HTML-Tables
//  31.08.2015  ST  Walzen gibt 1. Dicke mit aus
//  07.06.2016  AH  Directory auf %temp%
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Start(aBA : int);
//    SUB EvtInit...
//    SUB WriteLn(aFile : int; aText : alpha(500));
//    SUB BuildText(aFileName : Alpha) : logic;
//    SUB BuildText2(aFileName : Alpha) : logic;
//    SUB CreateGraph(aPic : handle; aScrollB  : handle; aKlickbar : logic);
//
//========================================================================
@I:Def_BAG
@I:Def_global

define begin
  cTitle :    'BA-Graph'
  cFile :     700
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   ''
  cZList :    0
  cKey :      0

  Trim(a)     : STRAdj(CnvAI(a,_fmtNumNoGroup),_STRbegin)
  TrimF(a,b)  : STRAdj(cnvaf(a,_Fmtnumnogroup,0,b),_STRbegin)
end;

declare CreateGraph(aPic : handle; aScrollB  : handle; aKlickbar : logic);


//========================================================================
//  Start
//========================================================================
Sub Start(aBA : int);
local begin
  vHdl  : int;
  vWin  : int;
  vG,vS : handle;
end;
begin
  vWin # Lib_GuiCom2:OpenMultiMDI(gFrmMain, 'BA1.Graph', _WinAddHidden);
  if (aBA<>0) then begin
    vHdl # Winsearch(vWin,'ie.Nummer');
    vHdl->wpcaptionint # aBA;
    Lib_Guicom:Disable(vHdl);

    BAG.Nummer # aBA;
    RecRead(700,1,0);

    vHdl # winsearch(vWin, 'ie.Nummer');
    vHdl->wpcaptionint # aBA;
//    vHdl->Winupdate(_WinUpdFld2Obj);

    vG # Winsearch(vWin,'Graph');
    vS # Winsearch(vWin,'Scrollbox');
    CreateGraph(vG, vS, y);
  end;
  vWin->WinUpdate(_WinUpdOn);
  vWin->WinFocusSet(true);
end;


//========================================================================
// EvtInit
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  WinSearchPath(aEvt:Obj);
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  w_NoList # y;

  App_Main:EvtInit(aEvt);

// SYSCLONE
// RMTDATAREAD

//  Erx # SysTimerCreate(1000 / 30, -1, aEvt:obj);
//  $Graph->wpcustom # aint(Erx);
//  $lb.Timer->wpcustom # aint(vHdl)+'|';

  mode # c_modeview;
/**
REPEAT
  BAG.Nummer # cnvif(4550.0 * Random());
  RecRead(700,1,0);
  Erx # RekLink(702,700,1,_recFirst);
UNTIL (BAG.P.Aktion=c_BAG_Spalt);

//RecRead(700,1,_recLast);
//BAG.Nummer # 1234;    // 3 s
//BAG.Nummer # 2556;    // 1 s
//BAG.Nummer # 4246;    // 4 s
//BAG.Nummer # 3497;    // 0 s
//BAG.Nummer # 2247;    // box
  RecRead(700,1,0);
***/

//  CreateGraph($Graph, $scrollbox, y);

  RETURN true;
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
//  BuildText
//
//========================================================================
sub BuildText(aFileName : Alpha) : logic;
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf702 : int;
  vBuf703 : int;
  vI      : int;
  vA      : alpha(4096);
  vB      : alpha(4096);
  vFile   : int;
  vAnzF   : int;
  vName   : alpha(200);
end;
begin

  vFile # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTRuncate);
  if (vFile=0) then RETURN false;

  vBuf701 # RecBufCreate(701);
  RecBufCopy(701,vBuf701);
  vBuf702 # RecBufCreate(702);
  RecBufCopy(702,vBuf702);
  vBuf703 # RecBufCreate(703);
  RecBufCopy(703,vBuf703);


//for Erx # 220 loop inc(Erx) while Erx<245 do
  //vA # vA + ' '+cnvai(Erx)+'_'+sTRchar(Erx);

  WriteLn(vFile, 'Digraph G {');
//WriteLn(vFile, 'graph [label="Teil" ,compound="true" ];');
  WriteLn(vFile, 'label="Betriebsauftrag '+TRim(BAG.Nummer)+vA+'";');
  Writeln(vFile, 'fontsize=20;');
  Writeln(vFile, 'fontname="Arial";');
  WriteLn(vFile, 'labelloc="t";');
  WriteLn(vFile, 'labeljust="l";');


  // Einsatz suchen
  WriteLn(vFile,'// Einsatz ==============================');
  FOR Erx # RecLink(701,700,3,_recFirst)
  LOOP Erx # RecLink(701,700,3,_recnext)
  WHILE (Erx<=_rOK) do begin

    if (BAG.IO.VonBAG=BAG.Nummer) then CYCLE;

    vA # 'id'+TRim(BAG.IO.ID);

    // Artikel?
    if (BAG.IO.MaterialTyp=c_IO_Art) or
      (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
//        vA # vA + ' [fontname="Arial", label="';
//        vA # vA + 'Art.'+BAG.IO.Artikelnr+'\n';
//        vA # vA + TrimF(BAG.IO.Plan.In.Menge, Set.Stellen.Menge)+BAg.IO.MEH.In;
      vA # vA + ' [fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
      vA # vA + '<TR><TD>Art.'+StrCnv(BAG.IO.Artikelnr,_StrToHtml)+'</TD></TR>';
      vA # vA + '<TR><TD>'+TrimF(BAG.IO.Plan.In.Menge, Set.Stellen.Menge)+BAg.IO.MEH.In+'</TD></TR>';
    end;

    // echtes Material?
    if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
//        vA # vA + ' [fontname="Arial", label="E'+TRim(BAG.IO.ID)+' \n';
//        vA # vA + 'Mat.'+TRim(BAG.IO.MaterialNr)+' \n';
      vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
      vA # vA + '<TR><TD>E'+Trim(BAG.IO.ID)+'</TD></TR>';
      vA # vA + '<TR><TD>Mat.'+Trim(BAG.IO.MaterialNr)+'</TD></TR>';
//        vA # vA + '</TABLE>>';
    end;
    if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
//        vA # vA + ' [fontname="Arial", label="E'+TRim(BAG.IO.ID)+' \n';
//        vA # vA + 'VSB-Mat.'+TRim(BAG.IO.MaterialNr)+' \n';
      vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
      vA # vA + '<TR><TD>E'+TRim(BAG.IO.ID)+'</TD></TR>';
      vA # vA + '<TR><TD>VSB-Mat.'+TRim(BAG.IO.MaterialNr)+'</TD></TR>';
    end;

    // Theoretisches Mat?
    if (BAG.IO.MaterialTyp=c_IO_Theo) then begin
//        vA # vA + ' [fontname="Arial", label="E'+Trim(BAG.IO.ID)+' \n';
//        vA # vA + 'theoretisch \n';
      vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
      vA # vA + '<TR><TD>E'+Trim(BAG.IO.ID)+'</TD></TR>';
      vA # vA + '<TR><TD>theoretisch</TD></TR>';
    end;

    if (BAG.IO.MaterialTyp<>c_IO_Art) and (BAG.IO.MaterialTyp<>c_IO_Beistell) then begin
//        vA # vA + TrimF(BAG.IO.Dicke,2)+'x'+TrimF(BAG.IO.Breite,1);
      vA # vA + '<TR><TD>'+TrimF(BAG.IO.Dicke,2)+'x'+TrimF(BAG.IO.Breite,1);
      if ("BAG.IO.Länge"<>0.0) then
        vA # vA + 'x'+TRimF("BAG.IO.Länge",1);
//        vA # vA + 'mm\n'+ TRim(BAG.IO.Plan.Out.Stk)+'Stk '+TRimF(BAG.IO.Plan.Out.GewN,0)+'kg';
      vA # vA + 'mm</TD></TR><TR><TD>'+ TRim(BAG.IO.Plan.Out.Stk)+'Stk '+TRimF(BAG.IO.Plan.Out.GewN,0)+'kg</TD></TR>';
    end;

//      vA # vA + '", style=bold, color=green, shape=invhouse]';
    vA # vA + '</TABLE></FONT>>, style=bold, color=green, shape=invhouse]';

    WriteLn(vFile, vA+';');

  END;
  WriteLn(vFile,'');


  // "Offene Enden" suchen
  WriteLn(vFile,'// Offene Enden =========================');
  FOR Erx # RecLink(701,700,3,_recFirst)
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rOK) do begin
    if (BAG.IO.VonBAG=BAG.Nummer) and (BAG.IO.NachBAG=0) then begin
      vA # 'id'+TRim(BAG.IO.ID)+' [fontname="Arial", label="", shape=plaintext, color=red]';
      WriteLn(vFile, vA+';');
    end;
  END;
  WriteLn(vFile,'');

/*
  // Fertigungen von 1zuY und XzuY Arbeitsgänge suchen
  WriteLn(vFile,'// Fertigungen Spalten/Tafeln ===========');
  Erx # RecLink(702,700,1,_recFirst);
  WHILE (Erx=_rOK) do begin
    if ("BAG.P.1In-yOutYN") or ("BAG.P.xIn-yOutYN") then begin
      Erx # RecLink(703,702,4,_recFirst);
      WHILE (Erx=_rOK) do begin
        vA # 'f'+TRim(BAG.F.Fertigung)+'p'+TRim(BAG.F.Position);
        vA # vA + ' [label="F'+TRim(BAG.F.Fertigung)+'", style=bold]';
        WriteLn(vFile, vA);
        Erx # RecLink(703,702,4,_recNext);
      END;
    end;
    Erx # RecLink(702,700,1,_recNext);
  END;
  WriteLn(vFile,'');
*/

  // Arbeitsgänge suchen
  WriteLn(vFile,'// Arbeitsgänge =========================');
  FOR Erx # RecLink(702,700,1,_recFirst)
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rOK) do begin

    vName # Lib_Strings:Strings_Dos2XML(BAG.P.Bezeichnung);

    vB # '';
    if ("BAG.P.Typ.VSBYN") then begin         // VSB Arbeitsgang?
      vA # 'p'+TRim(BAG.P.Position);
//        vA # vA + ' [fontname="Arial", label="'+aint(bag.p.position)+')'+vName+' '+BAG.P.Kommission;
      vA # vA + ' [fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
      vA # vA + '<TR><TD>'+aint(bag.p.position)+')'+vName+' '+BAG.P.Kommission;
      if (BAG.P.AufTRagsnr<>0) then begin
        Erx # Auf_Data:Read(BAG.P.Auftragsnr, BAG.P.AuftragsPos, y);
        if (Erx>=400) then begin
//            vA # vA +'\n'+Auf.P.KundenSW;
          vA # vA +'</TD></TR><TR><TD>'+StrCnv(Auf.P.KundenSW,_StrToHtml)
        end;
      end;
//        vA # vA + '", color=blue, style=bold, shape=house]';
      vA # vA +'</TD></TR></TABLE></FONT>>, color=blue, style=bold, shape=house]';

      WriteLn(vFile, vA+';');
      CYCLE;
    end;


    vAnzF # RecLinkInfo(701,702,3,_RecCount);

    case BAG.P.Aktion of

      c_BAG_Spalt : begin      // -----------------------------------------
        vB # '';
        vB # vB + '<FONT FACE="Arial" POINT-SIZE="14">';
        if (vAnzF=0) then
          vB # vB + '<TABLE COLOR="red" BORDER="2" CELLBORDER="1" CELLSPACING="0">'
        else
          vB # vB + '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">';
        vB # vB + '<TR><TD COLSPAN="'+aint(vAnzF)+'">';
        vB # vB + ''+aint(bag.p.position)+') '+vName;
        vB # vB + '</TD></TR>';
        vB # vB + '<TR>';
        FOR Erx # RecLink(703,702,4,_recFirst)
        LOOP Erx # RecLink(703,702,4,_recNext);
        WHILE (Erx<=_rOK) do begin
          vB # vB + '<TD PORT="f'+aint(bag.F.Fertigung)+'p'+aint(BAg.f.position)+'" WIDTH="100">';
          vB # vB + 'F'+TRim(BAG.F.Fertigung)+'<BR/>'
          vB # vB + TRim(BAG.F.Streifenanzahl)+' je '+TRimF(BAG.F.Breite,1);
          vB # vB + '</TD>';
        END;
        if (vAnzF=0) then vB # vB + '<TD></TD>';
        vB # vB + '</TR>';
        vB # vB + '</TABLE>';
        vB # vB + '</FONT>';

        vA # 'p'+TRim(BAG.P.Position);
        vA # vA + ' [label=<'+vB+'>, shape=plaintext';
        vA # vA + ']';
      end;


      c_BAG_Fahr, c_BAG_Versand : begin // ------------------------------------------------

        vB # '';
        Erx # RecLink(101,702,13,_RecFirsT);    // Zieladresse holen
        if (Erx<=_rLocked) then vB # ' '+Adr.A.Stichwort;

        vA # 'p'+TRim(BAG.P.Position);
//          vA # vA + ' [fontname="Arial", label="'+aint(bag.p.position)+')'+vName+'", shape=box]';
        vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0"><TR><TD>'+aint(bag.p.position)+')'+vName+StrCnv(vB,_StrToHtml)+'</TD></TR></TABLE></FONT>>, shape=box]';
      end;


      c_BAG_TAFEL, c_BAG_ABCOIL : begin // -----------------------------------------------
        vB # '';
        vB # vB + '<FONT FACE="Arial" POINT-SIZE="14">';
        if (vAnzF=0) then
          vB # vB + '<TABLE COLOR="red" BORDER="2" CELLBORDER="1" CELLSPACING="0">'
        else
          vB # vB + '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">';
        vB # vB + '<TR><TD COLSPAN="'+aint(vAnzF)+'">';
        vB # vB + ''+aint(bag.p.position)+') '+vName;
        vB # vB + '</TD></TR>';
        vB # vB + '<TR>';
        FOR Erx # RecLink(703,702,4,_recFirst)
        LOOP Erx # RecLink(703,702,4,_recNext);
        WHILE (Erx<=_rOK) do begin
          vB # vB + '<TD PORT="f'+aint(bag.F.Fertigung)+'p'+aint(BAg.f.position)+'" WIDTH="150">';
          if (BAG.F.AutomatischYN) then begin
            vB # vB + 'REST<BR/>';
          end
          else begin
            vB # vB + 'F'+TRim(BAG.F.Fertigung)+'<BR/>'
            vB # vB + TRim(BAG.F.Streifenanzahl)+' je '+TRimF(BAG.F.Breite,1);
          end;
          vB # vB + '</TD>';
        END;
        if (vAnzF=0) then vB # vB + '<TD></TD>';
        vB # vB + '</TR>';
        vB # vB + '</TABLE>';
        vB # vB + '</FONT>';

        vA # 'p'+TRim(BAG.P.Position);
        vA # vA + ' [label=<'+vB+'>, shape=plaintext';
//          if (vOK=n) then vA # vA + ',color=red, style=bold';
        vA # vA + ']';
      end;

      c_BAG_WALZ : begin

        Erx # RecLink(703,702,4,_recFirst); // Erste Fertigung lesen
        vA # 'p'+TRim(BAG.P.Position);
        if (vAnzF=0) then
          vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0"><TR><TD>'+aint(bag.p.position)+')'+vName+'</TD></TR></TABLE></FONT>>, shape=box, color=red, style=bold]';
        else
          vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0"><TR><TD>'+aint(bag.p.position)+')'+vName+'</TD></TR>'+
            '<TR><TD>'+ Anum(Bag.F.Dicke,Set.Stellen.Dicke) +' mm</TD></TR></TABLE></FONT>>, shape=box]';
      end;


      otherwise begin
        vA # 'p'+TRim(BAG.P.Position);
        if (vAnzF=0) then begin
//            vA # vA + '[fontname="Arial", label="'+TRim(BAG.P.Position)+') '+vName+'", shape=box ,color=red, style=bold]';
          vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0"><TR><TD>'+aint(bag.p.position)+')'+vName+'</TD></TR></TABLE></FONT>>, shape=box, color=red, style=bold]';
        end
        else begin
//            vA # vA + ' [fontname="Arial", label="'+TRim(BAG.P.Position)+') '+vName+'", shape=box]';
          vA # vA + ' [label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0"><TR><TD>'+aint(bag.p.position)+')'+vName+'</TD></TR></TABLE></FONT>>, shape=box]';
        end;
      end;

    end; // case

    WriteLn(vFile, vA+';');
  END;
  WriteLn(vFile,'');
  WriteLn(vFile,'');
  WriteLn(vFile,'');





  // Entnahmeschritte suchen
  WriteLn(vFile,'// Entnahme =============================');
  FOR Erx # RecLink(701,700,3,_recFirst)
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rOK) do begin
    if (BAG.IO.VonBAG<>BAG.Nummer) and (BAG.IO.NachPosition<>0) then begin
      vA # 'id'+TRim(BAG.IO.ID)+' -> p'+TRim(BAG.IO.NachPosition);//+ ' [headport="n"]';
      WriteLn(vFile, vA+';');
    end;
  END;
  WriteLn(vFile,'');

/*
  // Fertigungen suchen
  WriteLn(vFile,'// Fertigungen ==========================');
  Erx # RecLink(702,700,1,_recFirst);
  WHILE (Erx=_rOK) do begin
    if ("BAG.P.1In-1OutYN"=n) then begin
      Erx # RecLink(703,702,4,_recFirsT);
      WHILE (Erx=_rOK) do begin
        vA # 'p'+TRim(BAG.P.Position)+' ->';
        vA # vA + ' f'+TRim(BAG.F.Fertigung)+'p'+TRim(BAG.f.Position)+' [minlen=1];';
        WriteLn(vFile, vA);
        Erx # RecLink(703,702,4,_recNext);
      END;
    end;
    Erx # RecLink(702,700,1,_recNext);
  END;
  WriteLn(vFile,'');
*/

  // Verbindungen suchen
  WriteLn(vFile,'// Ketten ===============================');
  FOR Erx # RecLink(701,700,3,_recFirst)
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rOK) do begin

    if (BAG.IO.BruderID<>0) then CYCLE;

    if (BAG.IO.VonBAG=BAG.Nummer) then begin
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

      if (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Ist.In.GewN<>0.0) then begin
//          vA # vA + ' [weight=500, minlen=2, fontname="Arial", label="E'+TRim(BAG.IO.UrsprungsID)+'\n';
//          vA # vA + TRim(BAG.IO.Plan.IN.Stk)+'Stk\n';
//          vA # vA + TRimF(BAG.IO.Plan.IN.GewN,0)+'kg';
//          if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '\n('+TRimF(BAG.IO.Ist.IN.GewN,0)+'kg)';
        vA # vA + ' [weight=500, minlen=2, fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
        vA # vA + '<TR><TD>E'+TRim(BAG.IO.UrsprungsID)+'</TD></TR>';
        vA # vA + '<TR><TD>'+Trim(BAG.IO.Plan.IN.Stk)+'Stk</TD></TR>';
        vA # vA + '<TR><TD>'+TrimF(BAG.IO.Plan.IN.GewN,0)+'kg</TD></TR>';
        if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '<TR><TD>('+TrimF(BAG.IO.Ist.IN.GewN,0)+'kg)</TD></TR>';
      end
      else begin
//          vA # vA + ' [style=dashed, weight=500, minlen=2, fontname="Arial", label="E'+TRim(BAG.IO.UrsprungsID)+'\n';
//          vA # vA + TRim(BAG.IO.Plan.IN.Stk)+'Stk\n';
//          vA # vA + TRimF(BAG.IO.Plan.IN.GewN,0)+'kg';
//          if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '\n('+TRimF(BAG.IO.Ist.IN.GewN,0)+'kg)';

if (gUsername='AHxx') then begin
        vA # vA + ' [style=dashed, weight=500, minlen=2, fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
        vA # vA + '<TR><TD>E'+TRim(BAG.IO.UrsprungsID)+' (E'+aint(BAG.IO.ID)+')</TD></TR>';
        vA # vA + '<TR><TD>'+Trim(BAG.IO.Plan.IN.Stk)+'Stk</TD></TR>';
        vA # vA + '<TR><TD>'+TrimF(BAG.IO.Plan.IN.GewN,0)+'kg</TD></TR>';
        if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '<TR><TD>('+TRimF(BAG.IO.Ist.IN.GewN,0)+'kg)</TD></TR>';
end
else begin
        vA # vA + ' [style=dashed, weight=500, minlen=2, fontname="Arial", label=<<FONT FACE="Arial" POINT-SIZE="14"><TABLE border="0" cellpadding="0" cellspacing="0">';
        vA # vA + '<TR><TD>E'+TRim(BAG.IO.UrsprungsID)+'</TD></TR>';
        vA # vA + '<TR><TD>'+Trim(BAG.IO.Plan.IN.Stk)+'Stk</TD></TR>';
        vA # vA + '<TR><TD>'+TrimF(BAG.IO.Plan.IN.GewN,0)+'kg</TD></TR>';
        if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '<TR><TD>('+TRimF(BAG.IO.Ist.IN.GewN,0)+'kg)</TD></TR>';
end;

      end;
//        vA # vA + '"' + vB+', labeldistance=0.1]';
        vA # vA + '</TABLE></FONT>>'+ vB+', labeldistance=0.1]';

      WriteLn(vFile, vA+';');

    end;
  END;
  WriteLn(vFile,'');


  WriteLn(vFile, '}');
  FSIClose(vFile);


  RecBufCopy(vBuf701,701);
  RecBufDesTRoy(vBuf701);
  RecBufCopy(vBuf702,702);
  RecBufDesTRoy(vBuf702);
  RecBufCopy(vBuf703,703);
  RecBufDesTRoy(vBuf703);

  RETURN TRue;
end;


/*
    Info zu Nodes:
        N1 [label="<f0> Teil1 <here> | <f1> Teil2 | { <f2> Teil3.1 | <f3> Teil3.2 }, shape=record, ...];
        durch "<here>" wird das Zielfeld der Pfeile bestimmt

    Info zu Kanten:
        N1:f0 -> N2:f2 [label="name"];

        ranksep=1
        page="11,17"
        ordering="out"
        rankdir="LR"
        P1 [label="{<f0> # 58103| <f1> 5 Stk \n 5.000 kg} | <f2> STW 22\n ungebeizt \n 2,00 x 1000,00 mm | <f3> Co#: C34882Ab \n Lf:Thyssen \n Ort:Stahl Stannes",shape=record];
*/


//========================================================================
//  BuildText2
//
//========================================================================
sub BuildText2(
  aFileName     : Alpha;
  opt aTreeObj  : int;
  ) : logic;
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf702 : int;
  vBuf703 : int;
  vA    : alpha(1500);
  vB    : alpha(1500);
  vFile : int;
  vSort : alpha;
  vItem : int;
  vWert : int;
  vName   : alpha(200);
end;
begin

  vFile # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTRuncate);
  if (vFile=0) then RETURN false;


  vBuf701 # RecBufCreate(701);
  RecBufCopy(701,vBuf701);
  vBuf702 # RecBufCreate(702);
  RecBufCopy(702,vBuf702);
  vBuf703 # RecBufCreate(703);
  RecBufCopy(703,vBuf703);

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="Betriebsauftrag '+TRim(BAG.Nummer)+vA+'"');
  Writeln(vFile, 'fontsize=20');
  WriteLn(vFile, 'labelloc="t"');
  WriteLn(vFile, 'labeljust="l"');

  // Einsatz suchen
  WriteLn(vFile,'// Einsatz ==============================');
  Erx # RecLink(701,700,3,_recFirsT);
  WHILE (Erx=_rOK) do begin
    if (BAG.IO.VonBAG<>BAG.Nummer) then begin
      vA # 'id'+TRim(BAG.IO.ID);
      vA # vA + ' [label="';
      // echtes Material?
      if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
        vA # vA + 'Mat.'+TRim(BAG.IO.MaterialNr)+' \n';
      end;
      if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
        vA # vA + 'VSB-Mat.'+TRim(BAG.IO.MaterialNr)+' \n';
      end;
      // Theoretisches Mat?
      if (BAG.IO.MaterialTyp=c_IO_Theo) then begin
        vA # vA + 'theoretisch \n';
      end;

//        vA # vA + TRim(BAG.IO.Plan.Out.Stk)+'Stk '+TRimF(BAG.IO.Plan.Out.GewN,0)+'kg';
      vA # vA + '", style=bold, color=green, shape=invhouse]';
      WriteLn(vFile, vA);
    end;
    Erx # RecLink(701,700,3,_recNext);
  END;
  WriteLn(vFile,'');


  // "Offene Enden" suchen
  WriteLn(vFile,'// Offene Enden =========================');
  Erx # RecLink(701,700,3,_recFirsT);
  WHILE (Erx=_rOK) do begin
    if (BAG.IO.VonBAG=BAG.Nummer) and (BAG.IO.NachBAG=0) then begin
      vA # 'id'+TRim(BAG.IO.ID)+' [label="", shape=plaintext, color=red]';
      WriteLn(vFile, vA);
    end;
    Erx # RecLink(701,700,3,_recNext);
  END;
  WriteLn(vFile,'');

  // Arbeitsgänge suchen
  WriteLn(vFile,'// Arbeitsgänge =========================');
  Erx # RecLink(702,700,1,_recFirst);
  WHILE (Erx=_rOK) do begin

    vName # Lib_Strings:Strings_Dos2XML(BAG.P.Bezeichnung);

    // Daten aus temp. RAMBaum holen
    if (aTreeObj<>0) then begin
      BA1_Plan_Data:HoleTreeDaten(aTreeObj);
    end;

    vWert # BA1_Plan_data:PlanTerminOK();

    vB # '';
    if ("BAG.P.Typ.VSBYN") then begin         // VSB Arbeitsgang?
      vA # 'p'+TRim(BAG.P.Position);
      vA # vA + ' [label="'+TRim(Bag.P.Position)+'.'+vName;
      if (BAG.P.AufTRagsnr<>0) then begin
        Erx # Auf_Data:Read(BAG.P.Auftragsnr, BAG.P.AuftragsPos, y);
        if (Erx>=400) then
          vA # vA +'\n'+Auf.P.KundenSW;
      end;
      vA # vA + '", color=blue, style=bold, shape=house]';
    end
    else begin
/**
      vB # '"'+cnvad(bag.p.Plan.StartDat)+' '+cnvat(bag.p.Plan.StartZeit)+'|{';
      vB # vB + cnvad(bag.p.fenster.mindat)+' '+cnvat(bag.p.fenster.minzei)+'|';
      vB # vB + TRim(Bag.P.Position)+'.'+vName+'|';
      vB # vB + cnvad(bag.p.fenster.maxdat)+ ' '+cnvat(bag.p.fenster.maxzei)+'}"';

      vA # 'p'+TRim(BAG.P.Position);
      vA # vA + ' [label='+vB+', shape=record]';
**/
      /* -----------------  HTML von ST --------------------------------- */
      vB # '<<TABLE border="0" cellpadding="0" cellspacing="0" width="200">';
      vB # vB + '<TR>';

      if (vWert&1<>0) then
        vB # vB + '<TD port="oben_links" height="20" width="100" bgcolor="#FF4040" align="center">'
      else
        vB # vB + '<TD port="oben_links" height="20" width="100" bgcolor="#00FF00" align="center">';

      vB # vB + '<FONT face="Arial" POINT-SIZE="12" color="#000000">';
      vB # vB + cnvad(bag.p.fenster.mindat)+' '+cnvat(bag.p.fenster.minzei);
      vB # vB + '</FONT>';
      vB # vB + '</TD>';
      vB # vB + '<TD border="0" height="20" width="100"> </TD>';
      vB # vB + '</TR>';
      vB # vB + '<TR>';
      vB # vB + '<TD height="40" width="200" colspan="2" rowspan="1" bgcolor="#0080C0" align="center" name="mitte_oben">';
      vB # vB + '<FONT face="Arial" POINT-SIZE="20" color="#000000">';
      vB # vB + Trim(Bag.P.Position)+'.'+vName;
      vB # vB + '</FONT>';
      vB # vB + '</TD>';
      vB # vB + '</TR>';
      vB # vB + '<TR>';
     if (vWert<>0) then
        vB # vB + '<TD height="40" width="200" colspan="2" rowspan="1" bgcolor="#FF4040" align="center" name="mitte_unten">'
      else
        vB # vB + '<TD height="40" width="200" colspan="2" rowspan="1" bgcolor="#00FF00" align="center" name="mitte_unten">';
      vB # vB + '<FONT face="Arial" POINT-SIZE="20" color="#000000">';
      vB # vB + cnvad(bag.p.Plan.StartDat)+' '+cnvat(bag.p.Plan.StartZeit);
      vB # vB + '</FONT>';
      vB # vB + '</TD>';
      vB # vB + '</TR>';
      vB # vB + '<TR>';
      vB # vB + '<TD height="20" width="100"> </TD>';
      if (vWert&2<>0) then
        vB # vB + '<TD port="unten_rechts" height="20" width="100" bgcolor="#ff4040" align="center">'
      else
        vB # vB + '<TD port="unten_rechts" height="20" width="100" bgcolor="#00FF00" align="center">'
      vB # vB + '<FONT face="Arial" POINT-SIZE="12" color="#000000">';
      vB # vB + cnvad(bag.p.fenster.maxdat)+' '+cnvat(bag.p.fenster.maxzei);
      vB # vB + '</FONT>';
      vB # vB + '</TD>';
      vB # vB + '</TR>';
      vB # vB + '</TABLE>>';
      /*--------------------------------------------------------------  */
      vA # 'p'+TRim(BAG.P.Position);
      vA # vA + ' [shape=plaintext, label='+vB+']';
    end;

    WriteLn(vFile, vA);
    Erx # RecLink(702,700,1,_recNext);
  END;
  WriteLn(vFile,'');
  WriteLn(vFile,'');
  WriteLn(vFile,'');



  // Entnahmeschritte suchen
  WriteLn(vFile,'// Entnahme =============================');
  Erx # RecLink(701,700,3,_recFirsT);
  WHILE (Erx=_rOK) do begin
    if (BAG.IO.VonBAG<>BAG.Nummer) and (BAG.IO.NachPosition<>0) then begin
      vA # 'id'+TRim(BAG.IO.ID)+' -> p'+TRim(BAG.IO.NachPosition)+':oben_links;';
      WriteLn(vFile, vA);
    end;
    Erx # RecLink(701,700,3,_recNext);
  END;
  WriteLn(vFile,'');



  // Verbindungen suchen
  WriteLn(vFile,'// Ketten ===============================');
  Erx # RecLink(701,700,3,_recFirsT);
  WHILE (Erx=_rOK) do begin

    if (BAG.IO.BruderID<>0) then begin
      Erx # RecLink(701,700,3,_recNext);
      CYCLE;
    end;

    if (BAG.IO.VonBAG=BAG.Nummer) then begin
      vB # '';
      RecLink(702,701,2,_recFirst);       // Arbeitsgang holen
      vA # 'p'+TRim(BAG.IO.VonPosition)+':unten_rechts ->';

      if (BAG.IO.NachBAG=0) then begin    // keine Weiterbearbeitung??
        vA # vA + ' id'+TRim(BAG.IO.id);
        vB # ', style=bold, color=red'; // dashed dotted
      end
      else begin
        vA # vA + ' p'+TRim(BAG.IO.NachPosition)+':oben_links';
      end;

      if (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Ist.In.GewN<>0.0) then begin
        vA # vA + ' [weight=500, minlen=2';
        vA # vA + vB+']';
      end
      else begin
        vA # vA + ' [weight=500, minlen=2';
        vA # vA + vB+']';
      end;
      WriteLn(vFile, vA);

    end;
    Erx # RecLink(701,700,3,_recNext);
  END;
  WriteLn(vFile,'');


  WriteLn(vFile, '}');
  FSIClose(vFile);


  RecBufCopy(vBuf701,701);
  RecBufDesTRoy(vBuf701);
  RecBufCopy(vBuf702,702);
  RecBufDesTRoy(vBuf702);
  RecBufCopy(vBuf703,703);
  RecBufDesTRoy(vBuf703);

  RETURN TRue;
end;


//========================================================================
//  CreateGraph
//========================================================================
sub CreateGraph(
  aPic      : handle;
  aScrollB  : handle;
  aKlickbar : logic);
local begin
  vFile       : int;
  vTextName   : alpha(200);
  vBildName   : alpha(200);
  vPlainName  : alpha(200);
end;
begin

//  aPic->winupdate(_winupdoff);
  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';
  if (aKlickbar) then
    vPlainName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

//  Mode # c_modeview;

  // Graph deaktivieren
//  aPic->wpcaption # '';

  // Graphtext erzeugen
  BuildText(vTextName);

  // Graph erstellen
//    SysExecute('c:\programme\att\graphviz\bin\fdp.exe','-Tjpg -oc:\graph\Graph.jpg c:\graph\graph.txt',_execminimized|_execwait);
//    SysExecute('c:\graph\dot.exe','-Tjpg -oc:\graph\Graph.jpg c:\graph\graph.txt',_execminimized|_execwait);
//    SysExecute(set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
//    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

  //  auch als PLAIN?
  if (vPlainName<>'') then
    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tplain -o'+vPlainName+' -Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
  else
    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

  // Graph derstellen
  aPic->wpcaption # '';
  aPic->wpcaption # '*'+vBildName;
//  aPic->winupdate(_winupdon);

  if (vPlainName<>'') then begin
    Lib_Graph:CreateGraphFromPlain(0, aPic, aScrollB, null, vPlainName, false);
  end;

//  aPic->wpcaption # '*'+vBildName;

end;

//========================================================================