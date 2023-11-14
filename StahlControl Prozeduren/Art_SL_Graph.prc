@A+
//===== Business-ConTRol =================================================
//
//  Prozedur    Art_SL_Graph
//                  OHNE E_R_G
//  Info
//
//
//  20.07.2010  AI  Erstellung der Prozedur
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB WriteLn(aFile : int; aText : alpha(500));
//    SUB BuildText(aFileName : Alpha) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG

define begin
  Trim(a) : STRAdj(CnvAI(a,_fmtNumNoGroup),_STRbegin)
  TrimF(a,b) : STRAdj(cnvaf(a,_Fmtnumnogroup,0,b),_STRbegin)
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
//
//
//========================================================================
sub AddRso(
  aFile       : int;
  aStart      : alpha;
  var aLevel  : int;
  aMenge      : float);
local begin
  Erx     : int;
  vA      : alpha(500);
  vB      : alpha(500);
end;
begin
  Erx # RecLink(160,256,3,_RecFirst);   // Ressource holen
  inc(aLevel);
  vB # Rso.Stichwort;
  vA # 'RSO_'+Trim(aLevel);
  vA # vA + '[shape=ellipse, label="'+vB+'", color=yellow, style=bold]';
  WriteLn(aFile, vA);
  WriteLn(aFile, 'RSO_'+Trim(aLevel)+' -> '+aStart+':e [dir=none]');
end;


//========================================================================
//
//
//========================================================================
sub AddSL(
  aFile       : int;
  aArt        : alpha;
  aStart      : alpha;
  var aLevel  : int;
  aMenge      : float);
local begin
  Erx     : int;
  vBuf250 : int;
  vBuf255 : int;
  vBuf256 : int;
  vA      : alpha(500);
  vB      : alpha(500);
  vOK     : logic;
  vLast   : alpha;
  vMenge  : float;
  vLevel  : int;
  vHatSL  : logic;
end;
begin

  vBuf250 # RekSave(250);
  Art.Nummer # aArt;
  Erx # RecRead(250,1,0);
  if (Erx>_rLocked) then begin
    RekRestore(vBuf250);
    RETURN;
  end;

  vBuf255 # RekSave(255);

  Erx # RecLink(255,250,22,_RecFirst);    // aktive Stückliste holen
  if (Erx>_rLocked) then RecbufClear(255);

  vBuf256 # RekSave(256);

  vMenge # Art.SL.Menge * aMenge;

  inc(aLevel);
  vLevel # aLevel;
  WriteLn(aFile, 'subgraph cluster_'+trim(aLevel)+' {');
  WriteLn(aFile, 'node [style=filled];');
	WriteLn(aFile, 'fontsize=15;');
	WriteLn(aFile, 'label = "";');
	WriteLn(aFile, 'color=blue;');

  vB # aNum(vMenge, Set.Stellen.Menge) +' '+Art.SL.MEH+'\n'+Art.Nummer;
  vA # 'ART_'+Trim(aLevel);
  vA # vA + '[shape=record, label="'+vB+'", color=green, style=bold]';
  WriteLn(aFile, vA);

  vB #'';
  Erx # RecLink(256,255,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Art.SL.typ=828) then begin
      if (vB<>'') then vB # vB + '|';
      vB # vB + '<b'+Trim(Art.SL.Blocknr)+'_'+Trim(Art.SL.lfdNr)+'>';
      vB # vB + Art.SL.Input.ArgAkt;
    end;
    if (Art.SL.typ=0) then begin
      if (vB<>'') then vB # vB + '|';
      vB # vB + '<b'+Trim(Art.SL.Blocknr)+'_'+Trim(Art.SL.lfdNr)+'>';
      vB # vB + Art.SL.Bemerkung;
    end;

    Erx # RecLink(256,255,2,_recNext);
  END;
  if (vB<>'') then begin
    vA # 'SL_'+Trim(aLevel);
    vA # vA + '[shape=record, label="'+vB+'", color=green, style=bold]';
    WriteLn(aFile, vA);
    vHatSL # Y;
    end
  else begin
//    vA # 'SL_'+Trim(aLevel);
//    vA # vA + '[shape=record, label="'+vB+'", color=green, style=bold]';
//  WriteLn(aFile, vA);
  end;
  WriteLn(aFile, '}');

  //WriteLn(aFile, 'SL_'+Trim(aLevel)+' -> '+aStart+':e');
  WriteLn(aFile, 'ART_'+Trim(aLevel)+' -> '+aStart+':e [dir=none]');

  vLast # '';
  Erx # RecLink(256,255,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Art.SL.Typ=0) or (Art.SL.Typ=828) then
      vLast # 'b'+Trim(Art.SL.Blocknr)+'_'+Trim(Art.SL.lfdNr);

    if (vHatSL) then begin
      if (vLast='') then
        vA # 'SL_'+Trim(vLevel)
      else
        vA # 'SL_'+Trim(vLevel)+':'+vLast;
      end
    else begin
        vA # 'ART_'+Trim(vLevel);
    end;

    // Artikel...
    if (Art.SL.Typ=250) then begin
      AddSL(aFile, Art.SL.Input.Artnr, vA, var aLevel, vMenge);
      end
    // Ressource...
    else if (art.SL.typ=160) then begin
      AddRso(aFile, vA, var aLevel, vMenge);
    end;

    Erx # RecLink(256,255,2,_recNext);
  END;


  RekRestore(vBuf250);
  RekRestore(vBuf255);
  RekRestore(vBuf256);
  RETURN;
end;


//========================================================================
//  BuildText
//
//========================================================================
sub BuildText(aFileName : Alpha) : logic;
local begin
  Erx     : int;
  vA      : alpha(500);
  vB      : alpha(500);
  vFile   : int;
  vOK     : logic;
  vLevel  : int;
  vLast   : alpha;
end;
begin

  vFile # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTRuncate);
  if (vFile=0) then RETURN false;

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="Stückliste '+Art.SLK.Artikelnr+' '+Trim(Art.SLK.Nummer)+' '+Art.SLK.Name+'"');
  Writeln(vFile, 'dpi=300');
  Writeln(vFile, 'rankdir=RL');
  Writeln(vFile, 'ranksep=1; size = "7.5,7.5";');
  Writeln(vFile, 'fontsize=20');
  WriteLn(vFile, 'labelloc="t"');
  WriteLn(vFile, 'node [fontsize=10]');
  WriteLn(vFile, 'labeljust="l"');

  WriteLn(vFile,'// Hauptartikel =========================');
  vLevel # 1;
  WriteLn(vFile, 'subgraph cluster_'+trim(vLevel)+' {');
  WriteLn(vFile, 'node [style=filled];');
	WriteLn(vFile, 'fontsize=15;');
	WriteLn(vFile, 'label = "'+Art.SLK.Artikelnr+'";');
	WriteLn(vFile, 'color=blue;');

  vB # '';
  Erx # RecLink(256,255,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Art.SL.typ=828) then begin
      if (vB<>'') then vB # vB + '|';
      vB # vB + '<b'+Trim(Art.SL.Blocknr)+'_'+Trim(Art.SL.lfdNr)+'>';
      vB # vB + Art.SL.Input.ArgAkt;
    end;
    if (Art.SL.typ=0) then begin
      if (vB<>'') then vB # vB + '|';
      vB # vB + '<b'+Trim(Art.SL.Blocknr)+'_'+Trim(Art.SL.lfdNr)+'>';
      vB # vB + Art.SL.Bemerkung;
    end;

    Erx # RecLink(256,255,2,_recNext);
  END;
  if (vB<>'') then begin
    vA # 'SL_'+Trim(vLevel);
    vA # vA + '[shape=record, label="'+vB+'", color=green, style=bold]';
    WriteLn(vFile, vA);
    end
  else begin
    vA # 'SL_'+Trim(vLevel);
    vA # vA + '[shape=record, label="'+vB+'", color=green, style=bold]';
    WriteLn(vFile, vA);
  end;
  WriteLn(vFile, '}');


  WriteLn(vFile,'// Bauteile =============================');
  vLast # '';
  Erx # RecLink(256,255,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Art.SL.Typ=0) or (Art.SL.Typ=828) then
      vLast # 'b'+Trim(Art.SL.Blocknr)+'_'+Trim(Art.SL.lfdNr);
    if (vLast='') then
      vA # 'SL_1'
    else
      vA # 'SL_1:'+vLast;

    // Artikel...
    if (Art.SL.Typ=250) then begin
      AddSL(vFile, Art.SL.Input.Artnr, vA, var vLevel, 1.0);
      end
    // Ressource...
    else if (Art.SL.Typ=160) then begin
      AddRso(vFile, vA, var vLevel, 1.0);
    end;

    Erx # RecLink(256,255,2,_recNext);
  END;

//	Art_A [label="Artikel A", shape=box,color=red, style=bold]
//  AddSL(vFile, Art.SLK.Artikelnr, Art.SLK.Nummer);

  WriteLn(vFile, '}');
  FSIClose(vFile);

RETURN TRue;



    // Einsatz suchen
    WriteLn(vFile,'// Einsatz ==============================');
    Erx # RecLink(701,700,3,_recFirsT);
    WHILE (Erx=_rOK) do begin
      if (BAG.IO.VonBAG<>BAG.Nummer) then begin
        vA # 'id'+TRim(BAG.IO.ID);

        // Artikel?
        if (BAG.IO.MaterialTyp=c_IO_Art) or
          (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
          vA # vA + ' [label="';
          vA # vA + 'Art.'+BAG.IO.Artikelnr+'\n';
          vA # vA + TrimF(BAG.IO.Plan.In.Menge, Set.Stellen.Menge)+BAg.IO.MEH.In;
        end;

        // echtes Material?
        if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
          vA # vA + ' [label="E'+TRim(BAG.IO.ID)+' \n';
          vA # vA + 'Mat.'+TRim(BAG.IO.MaterialNr)+' \n';
        end;
        if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
          vA # vA + ' [label="E'+TRim(BAG.IO.ID)+' \n';
          vA # vA + 'VSB-Mat.'+TRim(BAG.IO.MaterialNr)+' \n';
        end;

        // Theoretisches Mat?
        if (BAG.IO.MaterialTyp=c_IO_Theo) then begin
          vA # vA + ' [label="E'+TRim(BAG.IO.ID)+' \n';
          vA # vA + 'theoretisch \n';
        end;

        if (BAG.IO.MaterialTyp<>c_IO_Art) and (BAG.IO.MaterialTyp<>c_IO_Beistell) then begin
          vA # vA + TRimF(BAG.IO.Dicke,2)+'x'+TRimF(BAG.IO.Breite,1);
          if ("BAG.IO.Länge"<>0.0) then
            vA # vA + 'x'+TRimF("BAG.IO.Länge",1);
          vA # vA + 'mm\n'+ TRim(BAG.IO.Plan.Out.Stk)+'Stk '+TRimF(BAG.IO.Plan.Out.GewN,0)+'kg';
        end;

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

      vB # '';
      if ("BAG.P.Typ.VSBYN") then begin         // VSB Arbeitsgang?
        vA # 'p'+TRim(BAG.P.Position);
        vA # vA + ' [label="'+BAG.P.Bezeichnung+' '+BAG.P.Kommission;
        if (BAG.P.AufTRagsnr<>0) then begin
          Auf.P.Nummer    # BAG.P.AufTRagsnr;
          Auf.P.Position  # BAG.P.AufTRagsPos;
          Erx # RecRead(401,1,0);
          if (Erx<=_rLocked) then
            vA # vA +'\n'+Auf.P.KundenSW;
        end;
        vA # vA + '", color=blue, style=bold, shape=house]';
        end
      else


          vOk # (RecLinkInfo(701,702,3,_RecCount)>0); // Output vorhanden?
          Erx # RecLink(703,702,4,_recFirsT);
          WHILE (Erx=_rOK) do begin
            if (vb<>'') then vB # vB + ' | ';
            vB # vB + ' <f'+TRim(BAG.F.Fertigung)+'p'+TRim(BAG.f.Position)+'>';
            vB # vB + ' F'+TRim(BAG.F.Fertigung)+'\n'
            vB # vB + TRim(BAG.F.STReifenanzahl)+' '+sTRchar(224)+' '+TRimF(BAG.F.Breite,1)
            Erx # RecLink(703,702,4,_recNext);
          END;
          vB # ' |{ '+vB+' } ';
          vA # 'p'+TRim(BAG.P.Position);
          vA # vA + ' [label="{'+BAG.P.Bezeichnung+vB+'}", shape=record';
          if (vOK=n) then vA # vA + ',color=red, style=bold';
          vA # vA + ']';

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
        vA # 'id'+TRim(BAG.IO.ID)+' -> p'+TRim(BAG.IO.NachPosition)+';';
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
          vA # vA + ' [weight=500, minlen=2, label="E'+TRim(BAG.IO.UrsprungsID)+'\n';
          vA # vA + TRim(BAG.IO.Plan.IN.Stk)+'Stk\n';
          vA # vA + TRimF(BAG.IO.Plan.IN.GewN,0)+'kg';
          if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '\n('+TRimF(BAG.IO.Ist.IN.GewN,0)+'kg)';
          vA # vA + '"'+vB+', labeldistance=0.1]';
          end
        else begin
          vA # vA + ' [style=dashed, weight=500, minlen=2, label="E'+TRim(BAG.IO.UrsprungsID)+'\n';
          vA # vA + TRim(BAG.IO.Plan.IN.Stk)+'Stk\n';
          vA # vA + TRimF(BAG.IO.Plan.IN.GewN,0)+'kg';
          if (BAG.IO.Ist.In.GewN<>0.0) then vA # vA + '\n('+TRimF(BAG.IO.Ist.IN.GewN,0)+'kg)';
          vA # vA + '"' + vB+', labeldistance=0.1]';
        end;
        WriteLn(vFile, vA);

      end;
      Erx # RecLink(701,700,3,_recNext);
    END;
    WriteLn(vFile,'');


  WriteLn(vFile, '}');
  FSIClose(vFile);

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
  vOK   : logic;
  vSort : alpha;
  vWert : int;
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

    // Daten aus temp. RAMBaum holen
    if (aTreeObj<>0) then begin
      BA1_Plan_Data:HoleTreeDaten(aTreeObj);
    end;

    vWert # BA1_Plan_data:PlanTerminOK();

    vB # '';
    if ("BAG.P.Typ.VSBYN") then begin         // VSB Arbeitsgang?
      vA # 'p'+TRim(BAG.P.Position);
      vA # vA + ' [label="'+TRim(Bag.P.Position)+'.'+BAG.P.Bezeichnung;
      if (BAG.P.AufTRagsnr<>0) then begin
        Auf.P.Nummer    # BAG.P.AufTRagsnr;
        Auf.P.Position  # BAG.P.AufTRagsPos;
        Erx # RecRead(401,1,0);
        if (Erx<=_rLocked) then
          vA # vA +'\n'+Auf.P.KundenSW;
      end;
      vA # vA + '", color=blue, style=bold, shape=house]';
      end
    else begin
/**
      vB # '"'+cnvad(bag.p.Plan.StartDat)+' '+cnvat(bag.p.Plan.StartZeit)+'|{';
      vB # vB + cnvad(bag.p.fenster.mindat)+' '+cnvat(bag.p.fenster.minzei)+'|';
      vB # vB + TRim(Bag.P.Position)+'.'+BAG.P.Bezeichnung+'|';
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
      vB # vB + Trim(Bag.P.Position)+'.'+BAG.P.Bezeichnung;
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
/****
digraph G {
label="Stückliste 004605007 1 Standard"
//rankdir=BT
rankdir=RL
//nodesep=.05
ranksep=1; size = "7.5,7.5";
dpi=150;

//concentrate=true
//remincross=true

fontsize=20
labelloc="t"
labeljust="l"

/***
subgraph cluster_Art_A{
	node [style=filled];
	label = "";
	color=blue;
	Art_A [label="Artikel A", shape=box,color=red, style=bold]
	Art_A_1_1 [label="waschen", shape=ellipse,color=green, style=bold]
	Art_A_1_2 [label="legen", shape=ellipse,color=green, style=bold]
	Art_A_1_3 [label="foehnen", shape=ellipse,color=green, style=bold]
}

subgraph cluster_Art_B{
	node [style=filled];
	label = "";
	Art_B [label="3m\nArtikel B", shape=box,color=red, style=bold]
	Art_B_1_1 [label="biegen", shape=ellipse,color=green, style=bold]
}

subgraph cluster_Art_C{
	node [style=filled];
	label = "";
	Art_C [label="2Stk\nArtikel C", shape=box,color=red, style=bold]
	Art_C_1_1 [label="tackern", shape=ellipse,color=green, style=bold]
	Art_C_2_1 [label="lochen", shape=ellipse,color=green, style=bold]
}

subgraph cluster_Art_C2{
	node [style=filled];
	label = "";
	Art_C2 [label="1Stk\nArtikel C", shape=box,color=red, style=bold]
	Art_C2_1_1 [label="tackern", shape=ellipse,color=green, style=bold]
	Art_C2_2_1 [label="lochen", shape=ellipse,color=green, style=bold]
}

// Ressourcen
Res_1 [label="10 min\nMas.1", style=bold, color=blue, shape=circle]
Res_1b [label="15 min\nMas.1", style=bold, color=blue, shape=circle]
Res_2 [label="20 min\nMas.2", style=bold, color=blue, shape=circle]

//idA_1 [label="Art.B", style=bold, color=green, shape=invhouse]

Art_B->Art_A_1_1;
Art_C->Art_A_1_3;
Art_C2->Art_B_1_1;

Res_1->Art_A_1_2:1:e;
Res_2->Art_A_1_1:3:e;
Res_1b->Art_B_1_1:1:e;

***/

subgraph cluster_Art_A{
	node [style=filled];
	fontsize=15;
	label = "Artikel A";
	color=blue;
	SL_A [shape=record, label="<1>waschen | <2>legen | <3>foehnen", color=green, style=bold]
//	Art_A [label="Artikel A", shape=box,color=red, style=bold]
}

subgraph cluster_Art_B{
	node [style=filled];
	label = "";
	Art_B [label="3 m\nArtikel B", shape=box,color=red, style=bold]
	SL_B [shape=record, label="<1>schweissen", color=green, style=bold]
}

subgraph cluster_Art_C{
	node [style=filled];
	label = "";
	Art_C [label="2 Stk\nArtikel C", shape=box,color=red, style=bold]
	SL_C [shape=record, label="<1>tackern | <2>lochen", color=green, style=bold]
}

subgraph cluster_Art_C2{
	node [style=filled];
	label = "";
	Art_C2 [label="1 Stk\nArtikel C", shape=box,color=red, style=bold]
	SL_C2 [shape=record, label="<1>tanzen | <2>singen | <3>springen", color=green, style=bold]
}

// Ressourcen
Res_1 [label="10 min\nMas.1", style=bold, color=blue, shape=circle]
Res_1b [label="15 min\nMas.1", style=bold, color=blue, shape=circle]
Res_2 [label="20 min\nMas.2", style=bold, color=blue, shape=circle]

//idA_1 [label="Art.B", style=bold, color=green, shape=invhouse]

Art_B->SL_A:1:e [dir=none];
Art_C->SL_A:3:e [dir=none];
Art_C2->SL_B:1:e [dir=none];

Res_1->SL_A:1:e [dir=none];
Res_2->SL_A:3:e [dir=none];
Res_1b->SL_B:1:e [dir=none];

}

****/