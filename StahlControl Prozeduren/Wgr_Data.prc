@A+
//===== Business-Control =================================================
//
//  Prozedur  Wgr_Data
//            OHNE E_R_G
//  Info
//
//
//  11.11.2013  AI  Erstellung der Prozedur
//  28.02.2020  AH  "Edit.Nummer"
//  05.07.2021  AH  "GetDichte"
//  27.07.2021  AH  ERX
//  14.06.2022  AH  "WertBlockenBeiTyp"
//  2023-06-23  AH  "Edit.Nummer" kann MERGE
//
//  Subprozeduren
//  sub IstArtMatMix(aWgr : int) : logic;
//  sub IstArt(aWgr : int) : logic;
//  sub IstMat(aWgr : int) : logic;
//  sub IstHuB(aWgr : int) : logic;
//  sub Edit.Nummer(aAlt  : int;  aNeu  : int) : logic;
//  sub GetDichte(aWgr : int; opt aGuete  : alpha; opt aArt    : alpha;) : float
//  SUB WertBlockenBeiTyp
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  c_Wgr_Material      : 200
  c_Wgr_bisMaterial   : 205   // 209

  c_Wgr_Artikel       : 250
  c_Wgr_bisArtikel    : 255   // 259
  c_Wgr_ArtCharge     : 252

  c_Wgr_MixMat        : 209
  c_Wgr_MixArt        : 259

  c_Wgr_HuB           : 180
end;


//========================================================================
//  IstMix
//
//========================================================================
sub IstMix(opt aWgr : int) : logic;
begin
  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  RETURN (aWgr=c_Wgr_MixArt) or (aWgr=c_Wgr_MixMat);
end;


//========================================================================
//  IstMixArt
//
//========================================================================
sub IstMixArt(opt aWgr : int) : logic;
begin
  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  RETURN (aWgr=c_Wgr_MixArt);
end;


//========================================================================
//  IstMixMat
//
//========================================================================
sub IstMixMat(opt aWgr : int) : logic;
begin
  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  RETURN (aWgr=c_Wgr_MixMat);
end;


//========================================================================
//  IstArt
//
//========================================================================
sub IstArt(opt aWgr : int) : logic;
begin
  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  RETURN (aWgr>=c_Wgr_Artikel) and (aWgr<=c_Wgr_BisArtikel);
end;


//========================================================================
//  IstMat
//
//========================================================================
sub IstMat(opt aWgr : int) : logic;
begin
  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  RETURN (aWgr>=c_Wgr_Material) and (aWgr<=c_wgr_BisMaterial);
end;


//========================================================================
//  IstHub
//
//========================================================================
sub IstHuB(opt aWgr : int) : logic;
begin
  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  RETURN (aWgr=c_Wgr_HuB);
end;


//========================================================================
//  WennArtDannCharte
//========================================================================
sub WennArtDannCharge(aWgr : int) : int;
begin
//  if (aWgr=0) then aWgr # Wgr.Dateinummer;
  if (aWgr=c_Wgr_Artikel) then
    RETURN c_Wgr_ArtCharge;

  RETURN aWgr;
end;


//========================================================================
//
//========================================================================
sub WertHUB() : int;
begin
  RETURN c_Wgr_HuB;
end;
//========================================================================
sub WertArtikel() : int;
begin
  RETURN c_Wgr_Artikel;
end;
//========================================================================
sub WertArtikelBis() : int;
begin
  RETURN c_Wgr_BisArtikel;
end;
//========================================================================
sub WertMaterial() : int;
begin
  RETURN c_Wgr_Material;
end;
//========================================================================
sub WertMaterialBis() : int;
begin
  RETURN c_Wgr_BisMaterial;
end;


//========================================================================
//  Edit.Nummer     mit GUI
//========================================================================
sub Edit.Nummer(
  aAlt        : int;
  aNeu        : int;
  aMerge      : logic;    // 2023-06-23 AH
) : logic;
local begin
  Erx         : int;
  vAnz        : int;
  vMax        : int;
  vProgress   : int;

  vPos        : int;
  vHdl,vHdl2  : int;

  vSel        : int;
  vQ          : alpha(4000);
  vSelName    : alpha;
  vNext       : int;
  vA,vB       : alpha;
end;
begin
  if (aAlt=aNeu) then RETURN false;
  if (aNeu<=0) or (aNeu>60000) then RETURN false;

  if (aMerge=false) then begin
    Wgr.Nummer # aNeu;
    Erx # RecRead(819,1,_rectest);
    if (Erx<=_rLocked) then begin
      Error(001006,Translate('Warengruppe'));
      RETURN false;
    end;
  end;
 
  Wgr.Nummer # aAlt;
  Erx # RecRead(819,1,0);
  if (Erx>_rLocked) then begin
    RETURN false;
  end;

  TRANSON;
  
  vMax # 28;

  inc(vAnz);
  vProgress # Lib_Progress:Init(aint(vAnz)+'/'+aint(vMax)+' : Grobplanung', RecInfo(600, _recCount ) );

  if (Adr_Subs:LoopDataAndReplace(600, 0, 1, 'GPl.Auf.WGr.von;GPl.Auf.WGr.bis' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  600                 // Grobplanung

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Adress-Verpackung', RecInfo(105, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(105, 0, 1, 'Adr.V.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  105                 // Adr.Verpackung

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Adress-Verpackung', RecInfo(180, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(180, 0, 1, 'HuB.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  180                 // Hub

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Material', RecInfo(200, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(200, 0, 1, 'Mat.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  200                 // Material

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Materialablage', RecInfo(210, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(210, 0, 1, 'Mat~Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  210                 // MaterialAblage

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Strukturliste', RecInfo(220, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(220, 0, 1, 'MSL.von.Warengruppe;MSL.bis.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  220                 //Strukturliste

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Artikel', RecInfo(250, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(250, 0, 1, 'Art.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  250                 // Artikel
  
  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Auftrag', RecInfo(401, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(401, 0, 1, 'Auf.P.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  401                 // Auftrag

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Auftragablage', RecInfo(411, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(411, 0, 1, 'Auf~P.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  411                 // Auftragsablage

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Auftragsaufpreise', RecInfo(403, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(403, 0, 1, 'Auf.Z.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  403                 // Auftragaufpreise

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Erlöskontierung', RecInfo(451, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(451, 0, 1, 'Erl.K.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  451                 // Erlöskontierung

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Bestellung', RecInfo(501, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(501, 0, 1, 'Ein.P.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  501                 // Bestellung

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Bestellablage', RecInfo(511, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(511, 0, 1, 'Ein~P.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  511                 // Bestellablage

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Bestellaufpreise', RecInfo(503, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(503, 0, 1, 'Ein.Z.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  503                 // Bestellaufpreise

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Wareneingang', RecInfo(506, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(506, 0, 1, 'Ein.E.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  506                 // Wareneingang

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Bedarf', RecInfo(540, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(540, 0, 1, 'Bdf.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  540                 // Bedarf

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Bedarfablage', RecInfo(545, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(545, 0, 1, 'Bdf~Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  545                 // Bedarfablage

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : SammelWE', RecInfo(621, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(621, 0, 1, 'SWe.P.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  621                 // SammelWe

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : BA-Einsatz', RecInfo(701, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(701, 0, 1, 'BAG.IO.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  701                 // BA-Einsatz

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : BA-Fertigung', RecInfo(703, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(703, 0, 1, 'BAG.F.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  703                 // BA-Fertigung

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Arbeitsgang', RecInfo(828, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(828, 0, 1, 'ArG.BAG.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  828                 // Arg

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Tolernazen', RecInfo(834, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(834, 0, 1, 'MTo.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  834                 // Mto

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Texte', RecInfo(837, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(837, 0, 1, 'Txt.bei.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  837                 // Texte

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Aufpreise', RecInfo(843, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(843, 0, 1, 'ApL.L.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  843                 // Aufpreise


  inc(vAnz);
//  if (Adr_Subs:LoopDataAndReplace(890, 0, 1, 'OSt.S.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
  vA # 'WGR:'+aint(aAlt);
  vQ # '';
  Lib_Sel:QAlpha(var vQ, 'OSt.Name', '=*', '*'+vA);
//debugx(vQ);
  vSel # SelCreate(890, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Onlinestatistik', RecInfo(890, _recCount, vSel ) );

  vNext # RecbufCreate(890);
  Erx # RecRead(890 ,vSel, _recFirst);
  WHILE (Erx <= _rLocked) and (vNext<>0) DO BEGIN
    if (vProgress<>0) then vProgress->Lib_Progress:Step()
    RecBufCopy(890,vNext);
    Erx # RecRead(vNext, vSel ,_RecNext);
    if (Erx>_rLocked) then begin
      RecBufDestroy(vNext);
      vNext # 0;
    end;
//debugx(Ost.Name);
    // "12345WGR:7"
    if (StrCut(Ost.Name,StrLen(Ost.Name)-StrLen(vA)+1, 100)=vA) then begin
//      vB # Ost.Name;
      RecRead(890,1,_recLock);
      Ost.Name # Str_ReplaceAll(Ost.Name, vA, 'WGR:'+aint(aNeu));
      Erx # RekReplace(890, _recUnlock, 'AUTO');
    end;
    if (vNext<>0) then RecBufCopy(vNext,890);
    Erx # _rOK;
  END;
  SelClose(vSel);
  SelDelete(890, vSelName);
  //  890                 // OSt

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Onlinestatistik.Extended', RecInfo(892, _recCount ) );
//  if (Adr_Subs:LoopDataAndReplace(892, 0, 1, 'OSt.E.Name2' , 'WGR:'+AInt(aNeu), 'WGR:'+AInt(aAlt), vProgress) = false) then begin
  vNext # RecbufCreate(892);
  Erx # RecRead(892 ,1 , _recFirst);
  WHILE (Erx <= _rLocked) and (vNext<>0) DO BEGIN
    if (vProgress<>0) then vProgress->Lib_Progress:Step()
    RecBufCopy(892,vNext);
    Erx # RecRead(vNext, 1 ,_RecNext);
    if (Erx>_rLocked) then begin
      RecBufDestroy(vNext);
      vNext # 0;
    end;
    if (Ost.E.Name2=vA) then begin
      RecRead(892,1,_recLock);
      Ost.E.Name2 # 'WGR:'+aint(aNeu);
      Erx # RekReplace(892, _recUnlock, 'AUTO');
    end;
    if (vNext<>0) then RecBufCopy(vNext,892);
    Erx # _rOK;
  END;
  //  892                 // OSt.Extend

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Statistik', RecInfo(899, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(899, 0, 1, 'Sta.Auf.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  899                 // Statistik

  inc(vAnz);
  Lib_Progress:Reset(vProgress, aint(vAnz)+'/'+aint(vMax)+' : Controlling', RecInfo(950, _recCount ) );
  if (Adr_Subs:LoopDataAndReplace(950, 0, 2, 'Con.Warengruppe' , AInt(aNeu), AInt(aAlt), vProgress) = false) then begin
    TRANSBRK;
    vProgress->Lib_Progress:Term();
    RETURN false;
  end; //  950                 // Controlling


  if (aMerge=false) then begin
    PtD_Main:Memorize(819);     // alten Stand merken
    Erx # RecRead(819, 1, _recLock);
    if(Erx <> _rOK) then begin
      TRANSBRK;
      vProgress->Lib_Progress:Term();
      RETURN false;
    end;
    Wgr.Nummer # aNeu;
    Erx # RekReplace(819, _recUnlock, 'AUTO');
    if(Erx <> _rOK) then begin
      TRANSBRK;
      vProgress->Lib_Progress:Term();
      RETURN false;
    end;
    PtD_Main:Compare(819); // vergleichen und ggf. ins Protokoll schreiben
  end
  else begin
    Wgr.Nummer # aAlt;
    RecRead(819,1,0);
    Erx # RekDelete(819);
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;
  
  TRANSOFF;

  vProgress->Lib_Progress:Term();

  RETURN true;

end;


//========================================================================
//  GetDichte
//========================================================================
sub GetDichte(
  aWgr        : int;
  aDatei      : int;
  opt aGuete  : alpha;
  opt aArt    : alpha;
) : float
local begin
  Erx     : int;
end;
begin
//debugx('GetDichte '+aint(awgr)+'/'+aint(aDatei)+' '+aGuete+' '+aArt);
  case aDatei of
    105 : begin
      aGuete  # "Adr.V.Güte";
      aArt    # Adr.V.Strukturnr;
    end;
    200 : begin
      aGuete  # "Mat.Güte";
      aArt    # Mat.Strukturnr;
    end;
    250 : begin
      aGuete  # "Art.Güte";
      aArt    # Art.Nummer;
    end;
    401 : begin
      aGuete  # "Auf.P.Güte";
      aArt    # Auf.P.Artikelnr;
    end;
    501 : begin
      aGuete  # "Ein.P.Güte";
      aArt    # Ein.P.Artikelnr;
    end;
    506 : begin
      aGuete  # "Ein.E.Güte";
      aArt    # Ein.E.Artikelnr;
    end;
    701 : begin
      aGuete  # "BAG.IO.Güte";
      aArt    # BAG.IO.Artikelnr;
    end;
    703 : begin
      aGuete  # "BAG.F.Güte";
      if (aGuete='') then aGuete # "BAG.IO.Güte"
      aArt    # BAG.F.Artikelnummer;
      if (aArt='') then aArt # BAG.IO.Artikelnr;
    end;
    707 : begin
      aGuete  # "BAG.F.Güte";
      if (aGuete='') then aGuete # "BAG.IO.Güte"
      aArt    # BAG.FM.Artikelnr;
    end;
  end

  // 1) WARENGRUPPE
  if (aWgr<>0) then begin
    if (Wgr.Nummer<>aWgr) then begin
      Wgr.Nummer # aWgr;
      Erx # RecRead(819,1,0);
      if (Erx>_rLocked) then RecBufClear(819);
    end;
    if (Wgr.Dichte<>0.0) then RETURN Wgr.Dichte;
  end;
  
  // 2) GÜTE
  if (aGuete<>'') then begin
    if (MQU_Data:Read(aGuete)<>0) then begin
      if (MQu.Dichte<>0.0) then RETURN MQu.Dichte;
    end;
  end;

  // 3) ARTIKEL / TODO
//debugx('NULL!!!');
  RETURN 0.0;
end;


/*========================================================================
  14.06.2022  AH                                          2228/90/20

  Antwortet, ob eine abgefragtes Feld/Wert für einen Materialtyp editierbar
  sein soll. Z.B. "L"änge ist bei Coils nicht angebbar
========================================================================*/
sub WertBlockenBeiTyp(
  aDatei  : int;
  aTyp    : alpha;
) : logic
begin

  if (RunAFX('Wgr.WertBlockenBeiTyp',aint(aDatei)+'|'+aTyp)<>0) then begin
    RETURN AfxRes=_rOK;
  end;

  
  case (Wgr.Materialtyp) of

    c_WgrTyp_Tafel : begin
      if (aTyp=^'RID') then RETURN true;
      if (aTyp=^'RAD') then RETURN true;
    end;

    c_WgrTyp_Coil : begin
      if (aTyp=^'L') then RETURN true;
    end;

    c_WgrTyp_Ronde : begin
      if (aTyp=^'B') then RETURN true;
      if (aTyp=^'L') then RETURN true;
      if (aTyp=^'RID') then RETURN true;
    end;

    c_WgrTyp_FlachRing : begin
      if (aTyp=^'B') then RETURN true;
      if (aTyp=^'L') then RETURN true;
    end;

  end;
 
  RETURN false;
end;

//========================================================================