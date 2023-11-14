@A+
//===== Business-Control =================================================
//
//  Prozedur    Art_SL_Data
//                  OHNE E_R_G
//  Info
//
//
//  09.07.2007  AI  Erstellung der Prozedur
//  04.04.2022  AH  ERX
//  2023.03.10  DS  Makro cTab wg. Namenskollision auskommentiert
//
//  Subprozeduren
//  SUB CheckArtInArt(aArt1 : alpha; aArt2 : alpha) : logic)
//  SUB BuildTree(aTree : int; aTiefe : int)
//  SUB Summieren(aArt : alpha; aSL : int; var aEK : float; var aKost : float; var aDauer : float) : logic
//  SUB RecalcSLK()

//  SUB _Add255(aTree : int; aDepth : int) : int;
//  SUB _Add250(aTree : int; aDepth : int) : logic;
//  SUB RecalcStruct(aAlleArt : logic; aNurArt : alpha);

//
//========================================================================
@I:Def_global
@I:Def_BAG

define begin
  cBreite1  : 45    // Name
  cBreite2  : 15    // Anzahl
  cBreite3  : 05    // Typ
  cBreite4  : 20    // Preis
  cBreite5  : 20    // Lohnkosten
  cStellen  : 4

//  cSLKName  : CnvAI(RecInfo(255,_recId), _fmtNumHex | _fmtNumLeadZero, 0, 8)
  cSLKName  : Art.SLK.Artikelnr+'_'+CnvAI(Art.SLK.Nummer, _fmtNumLeadZero, 0, 3)
  
  
  // DS: folgendes wird hier nur in Debug-Kommentaren verwendet und kollidiert sonst
  // mit einer neuen gleichnamigen Konstante in Def_Global:
  //cTab(a)   : StrChar(32,a*3)
  
  //+aint(a)+':'
end;

//global Struct_Art_SL_Recalc begin
//  s_Art_SL_n_BAG         : int;
//end;

//========================================================================
//  CechArtInArt
//
//========================================================================
sub CheckArtInArt(
  aArt1 : alpha;
  aArt2 : alpha;
  ) : logic;
local begin
  Erx     : int;
  vBuf250 : int;
  vBuf255 : int;
  vBuf256 : int;
end;
begin
//debug('check:'+aArt1+' in '+aArt2);
  if (aArt1=aArt2) then RETURN true;

  vBuf250 # RekSave(250);
  vBuf255 # RekSave(255);
  vBuf256 # RekSave(256);

  Art.Nummer # aArt2;
//  RecRead(250,1,0);

  Erx # RecLink(255,250,1,_recFirst);   // SL-Köpfe loopen
  WHILE (Erx<=_rLocked) do begin

    Erx # RecLink(256,255,2,_recFirst);   // SL-Posten loopen
    WHILE (Erx<=_rLocked) do begin

      if (Art.SL.Typ=250) then begin
        If (CheckArtInArt(aArt1, Art.SL.Input.Artnr)) then begin
            RekRestore(vBuf250);
            RekRestore(vBuf255);
            RekRestore(vBuf256);
            RETURN true;
        end;
      end;

      Erx # RecLink(256,255,2,_recNext);
    END;

    Erx # RecLink(255,250,1,_recNext);
  END;

  RekRestore(vBuf250);
  RekRestore(vBuf255);
  RekRestore(vBuf256);
//debug('...gut');
  RETURN false;
end;


//========================================================================
//  BuildTree
//
//========================================================================
sub BuildTree(
  aTree   : int;
  aTiefe  : int;
  aMenge  : float;
  );
local begin
  Erx       : int;
  vA        : alpha(200);
  vB        : alpha;
  vNode     : int;
  vBuf250   : int;
  vBuf255   : int;
  vBuf256   : int;
  vFirst    : int;
  vPreis    : float;
  vPreisPEH : int;
  vErg      : int;
end;
begin
//debug('loope:'+art.nummer);

  vBuf250 # RekSave(250);
  vBuf256 # RekSave(256);

  if (aTiefe=0) then begin
    //if (Art_P_Data:LiesPreis('PRD',0)) then vPreis # Art.P.PreisW1
    if (Art_P_Data:LiesPreis('Ø-EK',0)) then vPreis # Art.P.PreisW1
    else if (Art_P_Data:LiesPreis('L-EK',0)) then vPreis # Art.P.PreisW1
    else if (Art_P_Data:LiesPreis('L-EK',-1)) then vPreis # Art.P.PreisW1
    else if (Art_P_Data:LiesPreis('EK',0)) then vPreis # Art.P.PreisW1
    else if (Art_P_Data:LiesPreis('EK',-1)) then vPreis # Art.P.PreisW1
    else vPreis # 0.0;
    if (Art.P.PEH=0) then Art.P.PEH # 1;
    vPreisPEH # Art.P.PEH;

    aTree->wpINdexColFg(0)  # _WinColBlack;
    aTree->wpINdexColBkg(0) # _WinColWhite;
    aTree->wpINdexColFg(1)  # _WinColBlack;
    aTree->wpINdexColBkg(1) # _WinColGrayText;

    aTree->wpINdexColFg(2)  # _WinColBlack;
    aTree->wpINdexColBkg(2) # Set.ARt.SL.Col.Sperr;
    aTree->wpINdexColFg(3)  # _WinColBlack;
    aTree->wpINdexColBkg(3) # Set.ARt.SL.Col.Refsh;
    aTree->wpINdexColFg(4)  # _WinColBlack;
    aTree->wpINdexColBkg(4) # Set.ARt.SL.Col.Resso;
    aTree->wpINdexColFg(5)  # _WinColBlack;
    aTree->wpINdexColBkg(5) # Set.ARt.SL.Col.Arg;
    aTree->wpINdexColFg(6)  # _WinColBlack;
    aTree->wpINdexColBkg(6) # Set.ARt.SL.Col.Text;

    // Label bauen:
    vA      # StrFmt('Eintrag'  ,cBreite1 - aTiefe + 2,_StrEnd)+
            StrFmt('Menge    ',cBreite2,_StrBegin)+
            StrFmt('Typ',cBreite3 ,_StrBegin)+
            StrFmt('Preis '+"Set.HausWährung.Kurz"+'      ',cBreite4,_strBegin)+
            StrFmt('Lohn '+"Set.HausWährung.Kurz"+'      ',cBreite5,_strBegin);
    vNode  # aTree->WinTreeNodeAdd(Art.SLK.ArtikelNr,vA);
    vNode->wpindexdata(_WinFlagIndexColBkg) # 1;

    // Label bauen:
    vA      # StrFmt(Art.SLK.Artikelnr,cBreite1 - aTiefe + 2,_StrEnd)+
            StrFmt('',cBreite2 + cBreite3 ,_StrBegin)+
            StrFmt(cnvaf(vPreis,_FmtNumNoGroup,0,2,10)+' / '+StrFmt(cnvai(vPreisPEH,_FmtNumNoGroup),5,_strEnd) ,cBreite4,_strBegin)+
            StrFmt('',cBreite5,_strBegin);
    vNode  # aTree->WinTreeNodeAdd(Art.SLK.ArtikelNr,vA);
//$dl.Stueckliste->WinLstDatLineAdd(vA,_WinLstDatLineLast);
    vNode->WinPropSet(_WinPropNodeStyle,_WinNodeGreenBall);

    vFirst # aTree;
    aTree # vNode;
  end;


  Erx # RecLink(256,255,2,_recFirst);   // SL-Posten loopen
  WHILE (Erx<=_rLocked) do begin

    Art.SL.Menge # Art.SL.Menge * aMenge;

    case Art.SL.Typ of

      250 : begin // Artikel

        vErg # RecLink(250,256,2,_recFirst);   // InputArtikel holen

        if (Art_P_Data:LiesPreis('Ø-EK',0)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('L-EK',0)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('L-EK',-1)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('EK',0)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('EK',-1)) then vPreis # Art.P.PreisW1
        else vPreis # 0.0;
        if (Art.P.PEH=0) then Art.P.PEH # 1;
        vPreisPEH # Art.P.PEH;

        // Label bauen:
        vA    # StrFmt(Art.SL.Input.ArtNr,cBreite1 - aTiefe,_StrEnd)+
                StrFmt(cnvaf(Art.SL.Menge,_FmtNumNoGroup,0,cStellen,10)+' '+StrFmt(Art.SL.MEH,3,_strEnd),cBreite2, _StrBegin)+
                StrFmt(Art.Typ, cBreite3, _StrBegin) +
                StrFmt(cnvaf(vPreis,_FmtNumNoGroup,0,2,10)+' / '+StrFmt(cnvai(vPreisPEH,_FmtNumNoGroup),5,_strEnd) ,cBreite4,_strBegin)+
                StrFmt('',cBreite5,_strBegin);
        vNode  # aTree->WinTreeNodeAdd(cnvai(RecInfo(254,_recID)),vA);
        vNode->wpcustom # Art.SL.Input.ARtNr;

        if (Art.GesperrtYN) then
          vNode->wpindexdata(_WinFlagIndexColBkg) # 2
        else if ("Art.SLRefreshNötigYN") then
          vNode->wpindexdata(_WinFlagIndexColBkg) # 3;


//        vNode->wphelptip # Art.Bezeichnung1;

//vA # '+- '+Art.SL.Input.ArtNr;
//$dl.Stueckliste->WinLstDatLineAdd(aPrefix + vA,_WinLstDatLineLast);
//if (vMore) then aPrefix # aPrefix + '|  '
//else aPrefix # aPrefix + '   ';
        vNode->WinPropSet(_WinPropNodeStyle,_WinNodeGreenBall);

        if (vErg<=_rLocked) then begin
          vBuf255 # RekSave(255);
//          Erx # RecLink(255,250,1,_RecLast);  // letzte SLK-holen
          Erx # RecLink(255,250,22,_RecFirst);    // aktive Stückliste holen

          if (Erx<=_rLocked) then begin
//vA # '|';
//aPrefix # aPrefix + '   ';
//$dl.Stueckliste->WinLstDatLineAdd(aPrefix + vA,_WinLstDatLineLast);
            vNode->WinPropSet(_WinPropNodeStyle,_WinNodeFolder);
            BuildTree(vNode, aTiefe + 2, Art.SL.Menge);
            vNode->wpNodeExpanded # y;
           end
          else begin
//vA # '';
//$dl.Stueckliste->WinLstDatLineAdd(aPrefix + vA,_WinLstDatLineLast);
//debug('nix SL bei '+art.nummer);
          end;
          RekRestore(vBuf255);
        end;
      end; // Artikel


      828 : begin   // Arbeitsgang
        vPreis    # Art.SL.Kosten.FixW1;
        vPreisPEH # 0;
        if (Art.SL.Kosten.VarW1<>0.0) then begin
          vPreis    # Art.SL.Kosten.VarW1;
          vPreisPEH # Art.SL.Kosten.PEH;
        end;
        vA # cnvaf(vPreis,_FmtNumNoGroup,0,2,10);
        if (vPreisPEH<>0) then vA # vA + ' / '+StrFmt(cnvai(vPreisPEH,_FmtNumNoGroup),5,_strEnd)
        else vA # vA + '        ';

//        Art.SL.MEH  # 'min';
        vA    # StrFmt(Art.SL.Input.ArGAkt, cBreite1 - aTiefe,_StrEnd) +
                StrFmt(cnvaf(Art.SL.Menge,_FmtNumNoGroup,0,cStellen,10)+' '+StrFmt(Art.SL.Kosten.MEH,3,_strEnd),cBreite2, _StrBegin)+
                StrFmt('',cBreite3, _StrBegin) +
                StrFmt('',cBreite4, _StrBegin) +
                StrFmt(vA,cBreite5,_strBegin);
        vNode # aTree->WinTreeNodeAdd(cnvai(RecInfo(254,_recID)),vA);
        vNode->wpindexdata(_WinFlagIndexColBkg) # 5;
        vNode->WinPropSet(_WinPropNodeStyle,_WinNodeBlueBook);
      end; // Arbeitsgang


      160 : begin   // Ressource
        vPreis  # 0.0;
        vPreis    # Art.SL.Kosten.FixW1;
        vPreisPEH # 0;
        if (Art.SL.Kosten.VarW1<>0.0) then begin
          vPreis    # Art.SL.Kosten.VarW1;
          vPreisPEH # Art.SL.Kosten.PEH;
        end;
        vA # cnvaf(vPreis,_FmtNumNoGroup,0,2,10);
        if (vPreisPEH<>0) then vA # vA + ' / '+StrFmt(cnvai(vPreisPEH,_FmtNumNoGroup),5,_strEnd)
        else vA # vA + '        ';

        vB # cnvai(Art.SL.Input.ResGrp)+'/'+cnvai(Art.SL.Input.ResNr);
        vA    # StrFmt('Res.'+vB,cBreite1 - aTiefe,_StrEnd)+
                StrFmt(cnvaf(Art.SL.Menge,_FmtNumNoGroup,0,cStellen,10)+' '+StrFmt(Art.SL.Kosten.MEH,3,_strEnd),cBreite2, _StrBegin)+
                StrFmt('',cBreite3, _StrBegin) +
                StrFmt('',cBreite4, _StrBegin) +
                StrFmt(vA,cBreite5,_strBegin);
        vNode # aTree->WinTreeNodeAdd(cnvai(RecInfo(254,_recID)),vA);
        vNode->wpindexdata(_WinFlagIndexColBkg) # 4;
        vNode->WinPropSet(_WinPropNodeStyle,_WinNodeRedBall);
      end; // Ressource


      otherwise begin
        vA # Art.SL.Bemerkung;
        vA    # StrFmt(vA,cBreite1+cBreite2+cBreite3+cBreite4+cBreite5 - aTiefe,_StrEnd);
        vNode # aTree->WinTreeNodeAdd(Art.SL.Input.ArtNr,vA);
        vNode->wpindexdata(_WinFlagIndexColBkg) # 6;
        vNode->WinPropSet(_WinPropNodeStyle,_WinNodeDoc);
      end

    end;


    Erx # RecLink(256,255,2,_recNext);
  END;

  RekRestore(vBuf256);

  if (vFirst<>0) then
    aTree->wpNodeExpanded # y;

  RekRestore(vBuf250);
  RETURN;
end;
/**
  aTree->WinTreeNodeRemove();

  vA # StrFmt(aArtNr,72,_StrEnd)+'1 Stk      20€';
  vNode # aTree->WinTreeNodeAdd(Adr.Stichwort,va);
  vDummy # vNode;

  Erx # RecRead(100,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (vDummy=0) then begin
      vA # StrFmt(adr.Stichwort,72,_StrEnd)+'1 Stk      20€';
      vNode # aTree->WinTreeNodeAdd(Adr.Stichwort,va);
      end;
    else begin
      vA # StrFmt(adr.Stichwort,70,_strEnd)+'2 Stk     110€';
      vNode # vDummy->WinTreeNodeAdd(Adr.Stichwort,va);
      vNode->WinPropSet(_WinPropNodeStyle,_WinNoderedbook);

      vA # StrFmt(adr.Stichwort,68,_strEnd)+'1 Stk      17€';
      vNode # vNode->WinTreeNodeAdd(Adr.Stichwort,va);
      vNode->WinPropSet(_WinPropNodeStyle,_WinNodeFolder);

      vA # StrFmt(adr.Stichwort,66,_strEnd)+'4 Stk      33€';
      vNode # vNode->WinTreeNodeAdd(Adr.Stichwort,va);
      vNode->WinPropSet(_WinPropNodeStyle,_WinNodeDoc);
    end;

    vNode->WinPropSet(_WinPropNodeStyle,_WinNodeBlueBall);

    vA # StrFmt(adr.Stichwort,72,_StrEnd)+'3 Stk       5€';
    vNode # aTree->WinTreeNodeAdd(Adr.Stichwort,va);
    vNode->WinPropSet(_WinPropNodeStyle,_WinNodeGreenBall);
    vDummy # vNode;
/*
    vNode # vTree2->WinTreeNodeAdd(Adr.Name,Adr.Stichwort);
    vNode->WinPropSet(_WinPropNodeStyle,0);
    vNode->WinPropSet(_WinPropImageTileUser,12);
*/
    Erx # RecRead(100,1,_recNext);
  END;
  Lib_GuiCom:ExpandTree(aTree);

end;
*/


//========================================================================
//  Summieren
//
//========================================================================
SUB Summieren(
  aArt        : alpha;
  aSL         : int;
  var aMKost  : float;
  var aFKost  : float;
  var aFDauer : float) : logic
local begin
  Erx         : int;
  vBuf250     : int;
  vBuf256     : int;
  vPreis      : float;
  vPreisPEH   : int;
end;
begin

  Art.SLK.Artikelnr # aArt;
  Art.SLK.Nummer    # aSL;
  vBuf256 # RekSave(256);

  Erx # RecLink(256,255,2,_recFirst);   // SL-Posten loopen
  WHILE (Erx<=_rLocked) do begin
    vPreis    # 0.0;
    vPreisPEH # 0;

    // Arbeitsgang?
    if (Art.SL.Typ=828) then begin
      if (Art.SL.MEH='min') then aFDauer  # aFDauer + Art.SL.Menge;

      vPreis    # Art.SL.Kosten.FixW1;
      vPreisPEH # 0;
      if (Art.SL.Kosten.VarW1<>0.0) then begin
        vPreis    # Art.SL.Kosten.VarW1;
        vPreisPEH # Art.SL.Kosten.PEH;
      end;
      if (vPreisPEH=0) then
        aFKost # aFKost + Rnd(vPreis,2)
      else
        aFKost # aFKost + Rnd(vPreis * Art.SL.Menge / cnvfi(vPreisPEH),2);;

      end
    // Artikel?
    else if (Art.SL.Typ=250) then begin
      vBuf250 # RekSave(250);
      Erx # RecLink(250,256,2,_recFirst);   // Inputartikel holen
      if (Erx<=_rLocked) then begin
        aFDauer # aFDauer + Art.Fert.Dauer;
        if (Art_P_Data:LiesPreis('Ø-EK',0)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('L-EK',0)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('L-EK',-1)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('EK',0)) then vPreis # Art.P.PreisW1
        else if (Art_P_Data:LiesPreis('EK',-1)) then vPreis # Art.P.PreisW1
        else vPreis # 0.0;
        if (Art.P.PEH=0) then Art.P.PEH # 1;
        vPreisPEH # Art.P.PEH;
      end;
      if (vPreisPEH=0) then
        aMKost # aMKost + Rnd(vPreis,2)
      else
        aMKost # aMKost + Rnd(vPreis * Art.SL.Menge / cnvfi(vPreisPEH),2);

      RekRestore(vBuf250);
      end
    // Ressource?
    else if (Art.SL.Typ=160) then begin
      vPreis    # Art.SL.Kosten.FixW1;
      vPreisPEH # 0;
      if (Art.SL.Kosten.VarW1<>0.0) then begin
        vPreis    # Art.SL.Kosten.VarW1;
        vPreisPEH # Art.SL.Kosten.PEH;
      end;
      if (vPreisPEH=0) then
        aFKost # aFKost + Rnd(vPreis,2)
      else
        aFKost # aFKost + Rnd(vPreis * Art.SL.Menge / cnvfi(vPreisPEH),2);;
    end;

    Erx # RecLink(256,255,2,_recNext);
  END;

  RekRestore(vBuf256);
  RETURN true;
end;


//========================================================================
//  RecalcSKK
//
//========================================================================
sub RecalcSLK(
  opt aRefreshed : logic;
);
local begin
  Erx       : int;
  vDauer    : float;
  vFkost    : float;
  vMKost    : float;
  vChanged  : logic;
end;
begin
//todo('recalc');
  if (Summieren(Art.SLK.Artikelnr, Art.SLK.Nummer, var vMKost, var vFKost, var vDauer)=false) then
    RETURN;

  if (vDauer<>Art.SLK.Fert.Dauer) or (vMKost<>Art.SLK.Mat.KostW1) or (vFKost<>Art.SLK.Fert.KostW1) then begin
    RecRead(255,1,_recLock);
    Art.SLK.Fert.Dauer  # vDauer;
    Art.SLK.Fert.KostW1 # vFKost;
    Art.SLK.Mat.KostW1  # vMKost;
    Erx # RekReplace(255,_recUnlock,'AUTO');
    vChanged # y;
  end;

  if ("Art.Stückliste"=Art.SLK.Nummer) and
    ((vChanged) or (aRefreshed)) then begin

    if (Art.Typ=c_Art_PRD) then begin
      Art_P_Data:SetzePreis('EK', Rnd(vFKost+vMKost * cnvfi(Art.PEH),2), 0, Art.PEH, Art.MEH);
//debug('set '+art.nummer+' preus auf '+anum(vfKost+vMKost,5));
    end;

    RecRead(250,1,_recLock);
    Art.Fert.Dauer          # Art.SLK.Fert.Dauer;
    if (Art.Typ=c_Art_PRD) then "Art.SLRefreshNötigYN"  # y;
    if (aRefreshed) then "Art.SLRefreshNötigYN"  # n;
    Erx # RekReplace(250,_recUnlock,'AUTO');
//if "Art.SLRefreshNötigYN" then debug('C Y') else debug('C N');
 end;

end;


//========================================================================
//  _Add255
//
//========================================================================
sub _Add255(
  aTree   : int;
  aDepth  : int;
  ) : int;
local begin
  vItem     : int;
  vDepth    : int;
end;
begin

  vItem # CteRead(aTree, _CteFirst | _CteSearchCI | _CTeCustom,0, cSLKName);

  if (vItem=0) then begin
    vItem # CteOpen( _cteItem );
  //  if ( vItem = 0 ) then RETURN false;

    vItem->spName   # cnvai(aDepth,_FmtNumLeadZero,0,8) + CnvAI( vItem, _fmtNumHex | _fmtNumLeadZero, 0, 8 );
    vItem->spCustom # cSLKName;
    vItem->spId     # RecInfo(255,_recID);

//debug(cTab(aDepth)+'NEW '+vItem->spcustom+' mit '+aint(aDepth));

    // Einsortieren
    aTree->CteInsert( vItem );

    RETURN 1;
  end;

  // bereits tiefer verschachtelt???
  vDepth  # cnvia(StrCut(vItem->spname,1,8));
  if (vDepth>=aDepth) then begin
//debug(cTab(aDepth)+'nix '+vItem->spcustom);
    RETURN 0;
  end;


  // NEIN -> Tiefe erhöhen...
  aTree->CteDelete(vItem);

//debug(cTab(aDepth)+'INC '+vItem->spcustom+' auf '+aint(aDepth));
  vItem->spname # cnvai(aDepth,_FmtNumLeadZero,0,8) + CnvAI( vItem, _fmtNumHex | _fmtNumLeadZero, 0, 8);

  aTree->CteInsert( vItem );

  RETURN 1;
end;


//========================================================================
//  _Add250
//
//========================================================================
sub _Add250(
  aTree   : int;
  aDepth  : int;
  ) : logic;
local begin
  Erx       : int;
  vItem     : int;
  vBuf250   : int;
  vBuf255   : int;
  vBuf256   : int;
  vBuf256b  : int;
  vDepth    : int;
end;
begin

//debug(ctab(aDepth)+'Add art:'+Art.Nummer);


  if ("Art.SLRefreshNötigYN") then begin
    RecRead(250,1,_recLock);
    "Art.SLRefreshNötigYN"  # n;
    RekReplace(250,0,'AUTO');
  end;


  vBuf256 # RekSave(256);
  vBuf255 # RekSave(255);

  // Vorgänger loopen...
  Erx # RecLink(256,250,2,_recFirst);    // "inStückliste" holen
  WHILE (Erx<=_rLocked) do begin

    Erx # RecLink(255,256,5,_RecFirst);   // SLK holen
    if (_Add255(aTree,aDepth+1)<>1) then begin
      Erx # RecLink(256,250,2,_recNext);
      CYCLE;
    end;

    vBuf250 # RekSave(250);
    Erx # RecLink(250,256,1,_recFirst); // Hauptartikel holen
    if ("Art.Stückliste"=Art.SLK.Nummer) then begin
      _Add250(aTree,aDepth+1);
//      end
//    else begin
//debug(ctab(aDepth)+' uninetressant '+cSLKNAme);
    end;
    RekRestore(vBuf250);

    Erx # RecLink(256,250,2,_recNext);
  END;

  RekRestore(vBuf256);
  RekRestore(vBuf255);

//debug(ctab(aDepth)+'---Add art:'+Art.Nummer);

end;


//========================================================================
//  RecalcStruct
//
//========================================================================
sub RecalcStruct(
  aAlleArt  : logic;
  aNurArt   : alpha;
);
local begin
  Erx       : int;
  vTree     : int;
  vItem     : int;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vI        : int;
  vFoc      : int;

  vProgress : int;
end;
begin

  vFoc # WinFocusget();

  APPOFF();

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen


  if (aNurArt<>'') then begin
    // Nur einen ARtikel durchrechnen -----------------------------------
    Art.Nummer # aNurArt;
    RecRead(250,1,0);
    _Add250(vTree,0);
    end
  else begin
    // ALLE modifizierten Artikel durchrechnen --------------------------

    // Selektionsquery
    vQ # '';
//    Lib_Sel:QAlpha(var vQ, 'Art.Typ', '=', c_Art_PRD);
    if (aAlleArt=false) then
      Lib_Sel:QLogic( var vQ, 'Art.SLRefreshNötigYN', true);

    // Selektion starten...
    vSel # SelCreate( 250, 1);
    vSel->SelDefQuery( '', vQ );
    vSelName # Lib_Sel:SaveRun( var vSel, 0);


    vProgress # Lib_Progress:Init('Refresh (2/2)', RecInfo(250,_RecCount,vSel));

    // selektierte Artikel loopen...
    Erx # RecRead(250,vSel,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      // Progress
      vProgress->Lib_Progress:Step();

//debug('START ART:'+art.nummer);
      _Add250(vTree,0);

      Erx # RecRead(250,vSel,_RecNext);
    END;
    SelClose(vSel);
    vSel # 0;
    SelDelete(250,vSelName);
  end;
  vProgress->Lib_Progress:Term();


  vProgress # Lib_Progress:Init('Refresh (2/2)', CteInfo(vTree,_CteCount));
//    if (!vProgress->Lib_Progress:Step()) then begin

  // Struktur durchlaufen und jeden einzlenen summieren --------------------------
  vItem # vTree->CteRead(_CteFirst);  // erstes Element holen
  WHILE (vItem<>0) do begin

    // Progress
    vProgress->Lib_Progress:Step();

    RecRead(255,0,_RecId,vItem->spid);
    vI # cnvia(strcut(vITem->spname,1,8));

//debug('CALC '+vITem->spcustom+' d:'+aint(vI));
    Erx # RecLink(250,255,1,_RecFirst);   // Artikel holen
    RecalcSLK(y);

    vTree->CteDelete(vItem);          //
    CteClose(vItem);
    vItem # vTree->CteRead(_CteFirst);
  END;
  vProgress->Lib_Progress:Term();



  // Aufräumen ---------------------------------------------------------
  // Löschen der Liste
  Sort_KillList(vTree);

  APPON();

  Msg(999998,'',0,0,0);   // ERFOLG

  WinFocusSet(vFoc);
end;


//========================================================================