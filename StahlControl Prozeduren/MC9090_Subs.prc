@A+
//===== Business-Control =================================================
//
//  Prozedur  MC9090_Subs
//                  OHNE E_R_G
//  Info
//
//
//  25.11.2009  AI  Erstellung der Prozedur
//  04.03.2010  ST  FM: Vorbelegung mit der zuletzt gültigen Fertigung Prj.1251/52
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB BA_Input_Check() : logic
//    SUB BA_Abschluss() : logic
//    SUB _Vorbelege707(aID : int; aBruder : int);
//    SUB _Fertige(aPakete : int) : logic;
//    SUB BA_FM() : logic
//    SUB BA_BiS() : logic
//    SUB _LFS_InsertMat(aMat : int; var aPos : int) : logic;
//    SUB LFS();
//    SUB Mat_Inventur() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
//  BA_Input_Check
//
//========================================================================
sub BA_Input_Check() : logic
local begin
  Erx   : int;
  vA    : alpha;
  vB    : alpha;
  vNr   : int;
  vOK   : logic;
end;
begin
  if (Dlg_Standard:Standard_Small(Translate('BA-Position'),var vA,y)=false) then RETURN false;
  if (Lib_Strings:Strings_Count(vA,'/')<>1) then RETURN false;
  vB # Str_Token(vA,'/',1);
  BAG.Nummer # cnvia(vB);
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then RETURN false;

  vB # Str_Token(vA,'/',2);
  BAG.P.Nummer    # BAG.Nummer;
  BAG.P.Position  # cnvia(vB);
  Erx # RecRead(702,1,0);
  if (Erx>_rLocked) then RETURN false;

  vA # '';
  if (Dlg_Standard:Standard_Small(Translate('Materialnr.'),var vA)=false) then RETURN false;

  vNr # cnvia(vA);
  if (vNr>0) then begin
    Erx # RecLink(701,702,2,_RecFirst);   // Input loopen
    WHILE (Erx<=_rLocked) and (vOK=n) do begin
      if (BAG.IO.Materialtyp=c_IO_Mat) and (BAG.IO.MaterialNr=vNr) then vOK # y;
      Erx # RecLink(701,702,2,_RecNext);
    END;
  end;

  if (vOK) then begin
    Msg(707013,'',0,0,0);
//    Lib_Sound:Play( 'notice.wav' );
    end
  else begin
    Msg(707012,'',0,0,0);
  end;

  RETURN true;
end;


//========================================================================
//  BA_Abschluss
//
//========================================================================
sub BA_Abschluss() : logic
local begin
  Erx : int;
  vA  : alpha;
  vB  : alpha;
end;
begin
  if (Dlg_Standard:Standard_Small(Translate('BA-Position'),var vA)=false) then RETURN false;
  if (Lib_Strings:Strings_Count(vA,'/')<>1) then RETURN false;
  vB # Str_Token(vA,'/',1);
  BAG.Nummer # cnvia(vB);
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then RETURN false;
  vB # Str_Token(vA,'/',2);
  BAG.P.Nummer    # BAG.Nummer;
  BAG.P.Position  # cnvia(vB);
  Erx # RecRead(702,1,0);
  if (Erx>_rLocked) then RETURN false;

  // Fahraufträge oder Versandarbeitsgänge werden über Lieferschein fertiggemeldet
  if (BAG.P.Aktion=c_BAG_Fahr) OR (BAG.P.Aktion=c_BAG_Versand) then begin
    Error(702014,'');
    ErrorOutput;
    RETURN false;
  end;

  RETURN BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, today, now);
end;


//========================================================================
//  _Vorbelege707
//
//========================================================================
sub _Vorbelege707(
  aID     : int;
  aBruder : int);
local begin
  Erx : int;
end;
begin
  RecBufClear(707);
//  BAG.FM.Nummer   # BAG.Nummer;
//  BAG.FM.Position # BAG.P.Position;
//FertigAbfrage(BAG.FM.Nummer
//BAG.P.Position, BAG.F.Fertigung, B
//AG.FM.InputBAG, BAG.FM.InputID, BAG.FM.OutputID

  // Input holen
  BAG.IO.Nummer   # BAG.Nummer;
  BAG.IO.ID       # aID;
  RecRead(701,1,0);
  if (BAG.IO.MaterialTyp=c_IO_Mat) or (BAG.IO.MaterialTyp=c_IO_VSB) then begin
    Erx # RecLink(200,701,11,_recFirst);    // Restkarte holen
    if (Erx>_rLocked) then RecBufClear(200);
  end;

  // Einsatz + Fertigung zusammenführen
  if (BAG.F.Dicke=0.0) then           BAG.F.Dicke         # BAG.IO.Dicke;
  if (BAG.F.Dickentol='') then        BAG.F.Dickentol     # BAG.IO.Dickentol;
  if (BAG.F.Breite=0.0) then          BAG.F.Breite        # BAG.IO.Breite;
  if (BAG.F.Breitentol='') then       BAG.F.Breitentol    # BAG.IO.Breitentol;
  if ("BAG.F.Länge"=0.0) then         "BAG.F.Länge"       # "BAG.IO.Länge";
  if ("BAG.F.Längentol"='') then      "BAG.F.LÄngentol"   # "BAG.IO.Längentol";
  if ("BAG.F.Güte"='') then           "BAG.F.Güte"        # "BAG.IO.Güte";
  if ("BAG.F.GütenStufe"='') then     "BAG.F.GütenStufe"  # "BAG.IO.GütenStufe";
  if (BAG.F.AusfOben='') then         BAG.F.AusfOben      # BAG.IO.AusfOben;
  if (BAG.F.AusfUnten='') then        BAG.F.AusfUnten     # BAG.IO.AusfUnten;
  if (BAG.F.Warengruppe=0) then       BAG.F.Warengruppe   # BAG.IO.Warengruppe;
  if (BAG.F.Artikelnummer='') then    BAG.F.Artikelnummer # BAG.IO.Artikelnr;

  // Output holen
  BAG.IO.Nummer   # BAG.Nummer;
  BAG.IO.ID       # aBruder;
  RecRead(701,1,0);

  // Verpackung holen
  Erx # RecLink(704,703,6,_recfirst);
  if (Erx>_rLockeD) then RecBufClear(704);

  "BAG.F.Stückzahl" # BAG.IO.Plan.In.Stk;
  BAG.F.Gewicht     # BAG.IO.Plan.In.GewN;
  BAG.F.Menge       # BAG.IO.Plan.In.Menge;

  "BAG.F.Fertig.Stk"  # BAG.IO.Ist.In.Stk;
  BAG.F.Fertig.Gew    # BAG.IO.Ist.In.GewN;
  BAG.F.Fertig.Menge  # BAG.IO.Ist.In.Menge;

  // Input holen
  BAG.IO.Nummer   # BAG.Nummer;
  BAG.IO.ID       # aID;
  RecRead(701,1,0);


  // weitere Vorbelegungen:
  BAG.FM.Nummer         # myTmpNummer;
  BAG.FM.Position       # BAG.P.Position;
  BAG.FM.Fertigung      # BAG.F.Fertigung;
  BAG.FM.InputBAG       # BAG.Nummer;
  BAG.FM.InputID        # aID;
  BAG.FM.BruderID       # aBruder;
  BAG.FM.Werksnummer    # Mat.Werksnummer;
  BAG.FM.Verwiegungart  # BAG.Vpg.Verwiegart;
  BAG.FM.Status         # 1;

  // alle Daten eintragen...
  BA1_FM_Data:Vorbelegen();
end;


//========================================================================
//  _Fertige
//
//========================================================================
sub _Fertige(aPakete : int) : logic;
local begin
  Erx     : int;
  vI      : int;
  vL      : float;
  vBuf700 : handle;
  vBuf701 : handle;
  vBuf702 : handle;
  vBuf703 : handle;
  vBuf704 : handle;
  vBuf707 : handle;
end;
begin
  // fehlende Gewichte errechnen
  Erx # RecLink(818,707,6,_recfirst);
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;
  RecLink(819,703,5,_recFirst);   // Warengruppe holen

  // Theoretische Werte errechnen...
  if (BAG.FM.Gewicht.Netto=0.0) and (VWa.BruttoYN=false) then begin
//debug(aint("bag.fm.stück")+' '+anum(bag.fm.dicke,2)+' ' +anum(bag.fm.breite,2)+' '+anum("bag.fm.Länge",2)+' '+anum(wgr.dichte,5));
    BAG.FM.Gewicht.Netto # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.FM.Stück", BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr.Dichte, "Wgr.TränenKgProQM");
//debug('A:'+anum(bag.fm.gewicht.netto,0));
  end;
  if (BAG.FM.Gewicht.Brutt=0.0) and (VWa.NettoYN=false) then begin
    BAG.FM.Gewicht.Brutt # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.FM.Stück", BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr.Dichte, "Wgr.TränenKgProQM");
//debug('B:'+anum(bag.fm.gewicht.brutt,0));
  end;
  vL # "BAG.F.Länge";
  if (vL=0.0) then begin
    RecLink(819,701,7,_recFirst);   // Warengruppe holen
    vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr.Dichte, "Wgr.TränenKGproQM");
  end;
  If (BAG.P.Aktion <> c_BAG_AbLaeng)or (BAG.FM.Menge =0.0) then begin
    if (BAG.FM.MEH='qm') then
      BAG.FM.Menge # BAG.F.Breite * Cnvfi("BAG.FM.Stück") * vL / 1000000.0;
    if (BAG.FM.MEH='Stk') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück");
    if (BAG.FM.MEH='kg') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto;
    if (BAG.FM.MEH='t') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0;
    if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück") * vL / 1000.0;
  end;
//debug('C:'+anum(BAG.FM.Menge,0));
  if (BAG.FM.Gewicht.Brutt = 0.0) AND (BAG.FM.Gewicht.Netto <> 0.0) then
    BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto;
  if (BAG.FM.Gewicht.Brutt <> 0.0) AND (BAG.FM.Gewicht.Netto = 0.0) then
    BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt;

  If (BAG.P.Aktion = c_BAG_AbLaeng) then begin
    "BAG.F.Länge" # ((BAG.FM.Menge * 1000.0) / cnvFI("BAG.FM.Stück"));
  End;


  TRANSON;

  // Verbuchen....................
  FOR vI # 1 loop inc(vI) while (vI<=aPakete) do begin

    vBuf700 # RekSave(700);
    vBuf701 # RekSave(701);
    vBuf702 # RekSave(702);
    vBuf703 # RekSave(703);
    vBuf704 # RekSave(704);
    vBuf707 # RekSave(707);

    // Ankerfunktion
    if (RunAFX('BAG.FM.Recsave','')<>0) then begin
      if (AfxRes<>_rOK) then RETURN false;
    end;
    if (BA1_Fertigmelden:Verbuchen(true)=false) then begin
      TRANSBRK;
      Error(707002,'');
      ErrorOutput;
      RETURN false;
    end;

    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    RekRestore(vBuf704);
    RekRestore(vBuf707);

  END;  // Verbuchen

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  BA_FM
//
//========================================================================
sub BA_FM() : logic
local begin
  Erx     : int;
  vA      : alpha;
  vB      : alpha;
  vNr     : int;
  vID     : int;
  vBruder : int;
  vHdl    : handle;
  vHdl2   : handle;
  vName   : alpha;
  vI      : int;
  vPakete : int;
  vFertigung : alpha;
end;
begin

//  RecRead(200,1,_recFirst);
//  RecRead(840,1,_recFirst);
//  Mat_Etikett:Init(100);
//RETURN true;

  vFertigung  # '';
  WHILE (true) DO BEGIN

    vID # 0;
    vA # vFertigung;// ST 2010-03-04: Vorbelegung mit der zuletzt gültigen Fertigung

    if (Dlg_Standard:Standard_Small(Translate('BA-Fertigung'),var vA)=false) then RETURN false;
    if (Lib_Strings:Strings_Count(vA,'/')<>2) then RETURN false;

    vFertigung # vA;
    vB # Str_Token(vA,'/',1);
    BAG.Nummer # cnvia(vB);
    Erx # RecRead(700,1,0);
    if (Erx>_rLocked) then RETURN false;
    vB # Str_Token(vA,'/',2);
    BAG.P.Nummer    # BAG.Nummer;
    BAG.P.Position  # cnvia(vB);
    Erx # RecRead(702,1,0);
    if (Erx>_rLocked) then RETURN false;
    vB # Str_Token(vA,'/',3);
    BAG.F.Nummer      # BAG.P.Nummer;
    BAG.F.Position    # BAG.P.Position;
    BAG.F.Fertigung   # cnvia(vB);
    Erx # RecRead(703,1,0);
    if (Erx>_rLocked) then RETURN false;


    if (BAG.P.Aktion=c_BAG_Spulen) then RETURN false;
    if (BAG.P.Aktion=c_BAG_SpaltSpulen) then RETURN false;
    if (BAG.P.Aktion=c_BAG_Spalt) then RETURN false;


    vA # '';
    if (Dlg_Standard:Standard_Small(Translate('Einsatzmat.'),var vA)=false) then RETURN false;

    vNr # cnvia(vA);
    if (vNr>0) then begin
      Erx # RecLink(701,702,2,_RecFirst);   // Input loopen
      WHILE (Erx<=_rLocked) and (vID=0) do begin
        if (BAG.IO.Materialtyp=c_IO_Mat) and (BAG.IO.MaterialNr=vNr) then begin
          vID # BAG.IO.ID;
          BREAK;
        end;
        Erx # RecLink(701,702,2,_RecNext);
      END;
    end;

    // Kein Einsatz für diesen BA?
    if (vID=0) then begin
      Msg(707012,'',0,0,0);
      RETURN false;
    end;

    // passenden Output suchen...
    Erx # RecLink(701,703,4,_recFirst);   // Output loopen
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.BruderID=0) then vBruder # BAG.IO.ID;
      Erx # RecLink(701,703,4,_recNext);
    END;

    // Kein Einsatz für diesen BA?
    if (vBruder=0) then begin
      Msg(707012,'',0,0,0);
      RETURN false;
    end;


    // Verweigung vorbereiten...
    _Vorbelege707(vId, vBruder);


    // Dialog starten....
    vName # 'Frame.MC9090.BA.FM';
    vName # Lib_GuiCom:GetAlternativeName(vName);
    vHdl # WinOpen(vName,_WinOpenDialog);
    vHdl2 # Winsearch(vHdl,'lb.Info1');
    vHdl2->wpcaption # c_AKt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)+' '+BAG.P.Bezeichnung;
    vHdl2 # Winsearch(vHdl,'lb.Info2');
    vHdl2->wpcaption # "BAG.IO.Güte";
    vHdl2 # Winsearch(vHdl,'lb.Info3');
    vA #  ANum(BAG.FM.Dicke, Set.Stellen.Dicke);
    if (BAG.FM.Breite<>0.0) then vA # vA + ' '+ANum(BAG.FM.Breite, Set.Stellen.Breite);
    if ("BAG.FM.Länge"<>0.0) then vA # vA + ' '+ANum("BAG.FM.Länge", "Set.Stellen.Länge");
    vHdl2->wpcaption # vA;

    GV.Num.01   # 0.0;
    GV.Int.01   # 0;
    GV.Int.02   # 0;
    GV.Logic.01 # n;
    Lib_guiCom:ObjSetPos(vHDL, -4,-30);
    vI # WinDialogrun(vHdl);//, _Windialogcenter | _windialogapp);
    Winclose(vHdl);
    if (vI=_WinIDCancel) then RETURN false;
    //vPakete         # GV.Int.01;

    vPakete               # 1;
    "BAG.FM.Stück"        # GV.Int.02;
    BAG.FM.Gewicht.Brutt  # GV.Num.01;
    BAG.FM.Gewicht.Netto  # GV.Num.01;
    if (GV.Logic.01) then BAG.FM.Status # c_Status_BAGAusfall;    // fürher 790

    // Verbuchen...
    _Fertige(vPakete);

  END;

  RETURN true;
end;


//========================================================================
//  BA_Bis
//
//========================================================================
sub BA_BiS() : logic
local begin
  Erx     : int;
  vA      : alpha;
  vB      : alpha;
  vNr     : int;
  vID     : int;
  vBruder : int;
end;
begin
  if (Dlg_Standard:Standard_Small(Translate('BA-Position'),var vA)=false) then RETURN false;
  if (Lib_Strings:Strings_Count(vA,'/')<>1) then RETURN false;
  vB # Str_Token(vA,'/',1);
  BAG.Nummer # cnvia(vB);
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then RETURN false;
  vB # Str_Token(vA,'/',2);
  BAG.P.Nummer    # BAG.Nummer;
  BAG.P.Position  # cnvia(vB);
  Erx # RecRead(702,1,0);
  if (Erx>_rLocked) then RETURN false;

  // gültiger AG?
  if (BAG.P.Aktion=c_BAG_Fahr) then RETURN false;
  if (BAG.P.Aktion=c_BAG_Versand) then RETURN false;
  if (BAG.P.Aktion=c_BAG_Check) then RETURN false;
  if (BAG.P.Aktion=c_BAG_VSB) then RETURN false;

  // BA-Pos. bereits abgeschlossen?
  if (BAG.P.Fertig.Dat<>0.0.0) then begin
    Msg(702001,'',0,0,0);
    RETURN false;
  end;


  vA # '';
  if (Dlg_Standard:Standard_Small(Translate('Einsatzmat.'),var vA)=false) then RETURN false;

  vNr # cnvia(vA);
  if (vNr>0) then begin
    Erx # RecLink(701,702,2,_RecFirst);   // Input loopen
    WHILE (Erx<=_rLocked) and (vID=0) do begin
      if (BAG.IO.Materialtyp=c_IO_Mat) and (BAG.IO.MaterialNr=vNr) then begin
        vID # BAG.IO.ID;
        BREAK;
      end;
      Erx # RecLink(701,702,2,_RecNext);
    END;
  end;

  // Kein Einsatz für diesen BA?
  if (vID=0) then begin
    Msg(707012,'',0,0,0);
    RETURN false;
  end;

  // Menge noch vorhanden?
  if (BAG.IO.Plan.Out.Meng<=BAG.IO.Ist.Out.Menge) then begin
    Msg(701024,'',0,0,0);
    RETURN false;
  end;

  // BIS anlegen...
  if (BA1_IO_Data:CreateBIS()=false) then begin
    ErrorOutput;
    RETURN false;
  end;


  BAG.F.Nummer      # BAG.P.Nummer;
  BAG.F.Position    # BAG.P.Position;
  BAG.F.Fertigung   # 999;
  Erx # RecRead(703,1,0);
  if (Erx>_rLocked) then RETURN false;

  // passenden Output suchen...
  Erx # RecLink(701,703,4,_recFirst);   // Output loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID=0) then vBruder # BAG.IO.ID;
    Erx # RecLink(701,703,4,_recNext);
  END;

  // Kein Einsatz für diesen BA?
  if (vBruder=0) then begin
    Msg(707012,'',0,0,0);
    RETURN false;
  end;

  // Verweigung vorbereiten...
  _Vorbelege707(vId, vBruder);

  "BAG.FM.Stück"        # BAG.IO.Plan.In.Stk;
  BAG.FM.Gewicht.Netto  # BAG.IO.Plan.Out.GewN;
  BAG.FM.Gewicht.Brutt  # BAG.IO.Plan.Out.GewB;
  BAG.FM.Menge          # BAG.IO.Plan.Out.Meng;

  // Verbuchen...
  _Fertige(1);

  RETURN true;
end;


//========================================================================
//  _LFS_InsertMat
//
//========================================================================
sub _LFS_InsertMat(
  aMat      : int;
  var aPos  : int) : logic;
local begin
  Erx : int;
end;
begin

  Mat.Nummer # aMat;        // Material holen...
  Erx # RecRead(200,1,0);
  if (Erx>_rLocked) then begin
    Msg(001003,Translate('Material')+' '+AInt(aMat),0,0,0);
    RETURN false;
  end;

  if (Mat.AuftragsNr=0) then begin
    Msg(441007,AInt(aMat),0,0,0);
    RETURN false;
  end;

  if ("Mat.Löschmarker"='*') then begin
    Msg(200006,'',0,0,0);
    RETURN false;
  end;

  if (Mat.Status>c_Status_bisFrei) and (Mat.Status<>c_STATUS_VSB) and (Mat.Status<>c_STATUS_VSBKonsi) then begin
    Msg(441002,'',0,0,0);
    RETURN false;
  end;

  Erx # RecLink(401,200,16,_RecFirst);      // Auftragspos holen
  if (Erx>_rLocked) then begin
    Msg(401999,Translate('Auftrag')+' '+AInt(Mat.Auftragsnr)+'/'+AInt(Mat.auftragspos),0,0,0);
    RETURN false;
  end;
  Erx # RecLink(400,401,3,_RecFirst);       // Kopf holen
  if (Erx>_rLocked) then RETURN false;


  if (Lfs.Kundennummer=0) then begin
    Lfs.Kundennummer    # Auf.P.Kundennr;
    Lfs.Kundenstichwort # Auf.P.KundenSW;
    Lfs.Zieladresse     # Auf.Lieferadresse;
    Lfs.Zielanschrift   # Auf.Lieferanschrift;
  end;

  if((Lfs.Kundennummer<>Auf.P.Kundennr) or
    (Lfs.Zieladresse<>Auf.Lieferadresse) or
    (Lfs.Zielanschrift<>Auf.Lieferanschrift)) then begin
    Msg(441006,'',0,0,0);
    RETURN false;
  end;

  // Position in temp. Lieferschein aufnehmen...
  RETURN Auf_Data:VLDAW_Pos_Einfuegen_Mat(Lfs.Nummer, var aPos, 0);

end;


//========================================================================
//  LFS
//
//========================================================================
sub LFS();
local begin
  vKLim : float;
  vPos  : int;
  vA    : alpha;
  vOK   : logic;
  vNr   : int;
end;
begin

  vPos # 1;

  if (Dlg_Standard:Standard_Small('1. '+Translate('Materialnr.'),var vA)=false) then RETURN;

  vNr # cnvia(vA);
  if (vNr=0) then RETURN;

  RecBufClear(440);
  Lfs.Nummer        # myTmpNummer;
  Lfs.Anlage.Datum  # today;
  if (_LFS_InsertMat(vNr,var vPos)=false) then begin
    ErrorOutput;
    RETURN;
  end;

  // Kreditlimit prüfen...
  if ("Set.KLP.LFS-Druck"<>'') then
    if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFS-Druck",n, var vKLim)=false) then RETURN;

  vOK # n;
  vPos # 2;
  REPEAT

    vA # '';
    if (Dlg_Standard:Standard_Small(AInt(vPos)+'. '+Translate('Materialnr.'),var vA)=true) then begin
      vNr # cnvia(vA);
      if (vNr=0) then CYCLE;
      if (_LFS_InsertMat(vNr,var vPos)=false) then begin
        ErrorOutput;
        Msg(441008,'',0,0,0);
      end;
      CYCLE;
    end;

    // weitere Positionen erfassen?
    if (Msg(000005,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIDYes ) then CYCLE;

    // Speichern?
    if (Msg(440002,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIdno) then begin

      // Cleanup...
      WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do
        RekDelete(441,0,'MAN');

      RETURN;
    end;

    vOk # y;
  UNTIL (vOK);

  if (Lfs_Data:SaveLFS()=false) then begin
    ErrorOutput;
    RETURN;
  end;

  // Drucken + Verbuchen?
  if (Msg(440003,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIdYes) then begin
    if (Lfs_Data:Druck_LFS()) then begin
      Lfs_Data:Verbuchen(Lfs.Nummer, today, now);
    end;
    ErrorOutput;
  end;

end;


//========================================================================
//  Mat_Inventur
//
//========================================================================
sub Mat_Inventur() : logic;
local begin
  Erx     : int;
  vPlatz  : alpha;
  vA      : alpha;
end;
begin

  vPlatz # '';
  if (Dlg_Standard:Standard_Small(Translate('Lagerplatz'),var vPlatz)=false) then RETURN true;
  Lpl.Lagerplatz # StrCut(vPlatz,1,20);
  Erx # RecRead(844,1,0);   // Lagerplatz holen
  If (Erx>_rLocked) then begin
    Msg(844017 ,vPlatz,_WinIcoError,_WinDialogOk,1);
    RETURN(False);
  end;

  REPEAT
    vA  # '';
    if (Dlg_Standard:Standard_Small(Translate('Materialnr.'),var vA)=false) then RETURN true;

    Mat.Nummer # cnvia(vA);

    // ST 2010-06-18: Inventurdaten werden jetzt zentral gesetzt
    begin
      if (!Mat_Data:SetInventur(Mat.Nummer,Lpl.Lagerplatz,today, false)) then begin
        Msg(844016 ,vA,_WinIcoError,_WinDialogOk,1);
        RETURN(False);
      end;

    end; // ST 2010-06-18: Inventurdaten werden jetzt zentral gesetzt


  UNTIL (1=2);

  RETURN false;
end;


//========================================================================