@A+
//===== Business-Control =================================================
//
//  Prozedur  Art_Inv_Mat_Inventur  Basis: SFX_BSP_Mat_Inventur
//                  OHNE E_R_G
//  Info    Sonderfunktionen für die Inventurbehandlung Brockhaus
//
//
//  17.04.2019  ST  Erstellung der Prozedur
//  02.10.2020  ST  Vererbung der Inventuranhänge
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    sub _Vorlauf(aVoll : logic; aLohn : logic);
//    sub _CreateInvEntry(aLager : int; aAns : int; aTeam : int)//
//    sub _Aufnahmeseiten(aLagerAdr : int; aLagerAns : int)
//
//  SFX
//    sub VorlaufLohn()
//    sub VorlaufVoll()
//    sub VorlaufVollLohn()
//    sub VorlaufReset()
//    sub Aufnahmeseiten()
//    sub AusLageradresse()
//    sub SetInvDaten()
//    sub TakeThisMat()
//    sub CheckAndResetMatKommission()
//
//    sub AddAktionsliste(aDatum : date; aInvNr : int; aBemerkung : alpha)
//
//  AFX
//    sub AusLageranschrift(aPara : alpha)
//    sub LoescheMatOhneInv(aPara : alpha) : int
//    sub Uebern.EinzelMat(aPara : alpha) : int
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Rights
@I:Def_Aktionen


define begin
  cStartSeite : 40000
  PROTOPEN(a) :  begin vProt # FsiOpen('c:\debug\'+a+'.csv',_FsiStdWrite |  _FsiSyncWrite); end;
  PROTO(a) : begin vProtLine # a;  vProt->FsiWrite((vProtline + StrChar(13)+StrChar(10)));  end;
end

local begin
  vProt  : int;
  vProtLine : alpha(4000);
end;

//========================================================================
//  sub _Reset(opt aSilent : logic)
//  Löscht die Inventurdaten
//========================================================================
sub _Reset(opt aSilent : logic)
local begin
  Erx       : int;
  vWin      : int;
  v200      : int;
end
begin

  if (aSilent = false) then begin
    if (Msg(99,'Inventurdaten zurücksetzen?',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then
      RETURN;
  end;

  // alte Inventur löschen...
  RekDeleteAll(259);

  // 23.11.2017 AH: Nummern Reset
  Lib_Nummern:ReadNummer('INVENTUR');
  Prg.Nr.Nummer  # 0;
  Lib_Nummern:SaveNummer();

  // Material reset
  vWin # Lib_Progress:Init('Berechnung...', RecInfo(200, _recCount ) );
  RecBufClear(200);
  gZLList->wpAutoUpdate # false;

  v200 # RecBufCreate(200);

  // Markierung setzen...
  FOR Erx # RecRead(v200,1,_recFirst)
  LOOP Erx # RecRead(v200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vWin->Lib_Progress:Step();

    if (v200->Mat.Inventur.DruckYN) then begin
      RecRead(v200,1,_recLock);
      v200->Mat.Inventur.DruckYN  # false;
      Erx # RekReplace(v200, _recunlock);
      if (Erx<>_rOK) then begin
        Msg(1001,'Mat. '+aint(v200->Mat.Nummer),0,0,0);
        BREAK;
      end;
    end;
  END;

  vWin->Lib_Progress:Term();
  gZLList->wpAutoUpdate # true;
  RecBufDestroy(v200);
  if (aSilent = false) then
    Msg(999998,'',0,0,0);

end;

//========================================================================
//  SFX InventurVorlauf
//  SFX_BSP_MAT_Inventur:Vorlauf
//========================================================================
sub _Vorlauf(aVoll : logic; aLohn : logic);
local begin
  Erx       : int;
  vWin      : int;
  vInv      : logic;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vTyp      : alpha;
  v200Alt   : int;

  vErr      : alpha;

  vType     : alpha;

  vMarkedYN : logic;
  vMarked   : int;
  vMFile    : int;
  vMID      : int;
end;
begin


   if (aVoll AND aLohn) then begin
    vType # 'Voll-& Lohngeschäft';
   end else begin
    if (aVoll) then
      vType # 'Vollgeschäft';
    else
      vType # 'Lohngeschäft';
   end;


  if (Msg(99,'Inventursolldaten für das ' +vType+ ' jetzt berechnen und in Inventurdatei füllen?',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then
      RETURN;

  vWin # Lib_Progress:Init('Berechnung ' + vType +'...', RecInfo(200, _recCount ) );
  RecBufClear(200);

  gZLList->wpAutoUpdate # false;


  PROTOpen('inventur_01_mat_zu_inventur_1von2');
  PROTO('Material;Daten;Bemerkung;');

  // Markierung setzen...
  vMarkedYN # (Lib_Mark:Count(200) > 0);
  FOR begin
    if (vMarkedYN) then
      vMarked # gMarkList->CteRead(_CteFirst);
     else
      Erx # RecRead(200,1,_recFirst);
    end;
  LOOP begin
    if (vMarkedYN) then
      vMarked # gMarkList->CteRead(_CteNext, vMarked);
    else
      Erx # RecRead(200,1,_recNext)
  end;
  WHILE (vMarkedYN = false  AND Erx<=_rLocked) OR (vMarkedYN AND vMarked > 0) do begin
    vWin->Lib_Progress:Step();

    if (vMarkedYN) then  begin
      Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
      if (vMFile<>200) then
        CYCLE;

      RecRead(200, 0, _recId, vMID);
    end;

    // KRITERIEN FÜR INVENTUR:
    vInv # ("Mat.ÜbernahmeDatum">0.0.0) AND ("Mat.Löschmarker"='') and
            (Mat.Bestand.Gew>0.0) AND (Mat.Bestand.Stk>0);

    if (aVoll <> aLohn) then begin
      if (aVoll = true) then
        vInv # (vInv AND(Mat.EigenmaterialYN = true));
      if (aLohn = true) then
        vInv # (vInv AND(Mat.EigenmaterialYN = false));
    end;

    if (Mat.Inventur.DruckYN<>vInv) then begin
      RecRead(200,1,_recLock);
      Mat.Inventur.DruckYN  # vInv;
      Erx # RekReplace(200, _recunlock);
      if (Erx<>_rOK) then begin
        vWin->Lib_Progress:Term();
        Msg(1001,'Mat. '+aint(Mat.Nummer),0,0,0);
        gZLList->wpAutoUpdate # true;
//        RecBufDestroy(200);
        RETURN;
      end;
      Proto(CnvAI(Mat.Nummer,_FmtNumNoGroup) + ';' + Aint(CnvIl(Mat.Inventur.DruckYN)) + ';zur Inventur');
    end else begin
      Proto(CnvAI(Mat.Nummer,_FmtNumNoGroup) + ';' + Aint(CnvIl(Mat.Inventur.DruckYN))+ ';nicht zur Inventur');
    end;

  END;
  vProt->FsiClose();

  vWin->Lib_Progress:Term();

  // Sortierung setzen...
  Lib_Sel:QLogic(var vQ, 'Mat.Inventur.DruckYN', y);

  vSel # SelCreate(200, 0);
// ST 2019-05-13: Keine Sortierung nach Lageranschrift
/*
  vSel->SelAddSortFld(2, 10);   // Lageranschrift
  vSel->SelAddSortFld(2, 11);   // Lageranschrift
*/
  vSel->SelAddSortFld(1, 56 );  // Paketnummner
  vSel->SelAddSortFld(1, 1 );   // MatNr

  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  PROTOpen('inventur_02_mat_zu_inventur_2von2');
  PROTO('Material;Daten;Bemerkung;');

  vWin # Lib_Progress:Init( 'Transfer in Inventurtabelle...', RecInfo( 200, _recCount, vSel ) );
  FOR  Erx # RecRead(200,vSel, _recFirst);
  LOOP Erx # RecRead(200,vSel, _recNext);
  WHILE (Erx<=_rLocked) and (vErr='') do begin
    vWin->Lib_Progress:Step();

    RecBufClear(259);
    RekLink(819,200,1,0); //  Warengruppe lesen

    // ST 2019-11-19: Zusätzliche Checks
    if (Mat.Lageradresse = 0) OR (Mat.Lageranschrift = 0) OR (RecLink(101,200,6,0)<>_rOK) then begin
      Proto(Aint(Mat.Nummer) + ';' + Aint(Mat.Lageradresse) + '/' + Aint(Mat.Lageranschrift )+ ';' + 'Lageranschrift ungültig');
    end;
    if (Wgr.Dateinummer = 209) AND (Mat.Strukturnr<>'') AND (RecLink(250,200,26,0) <> _rOK) then begin
      Proto(Aint(Mat.Nummer) + ';' + Mat.Strukturnr +';' + 'Artikel nicht gefunden');

    end;

    Art.Inv.Materialnr  # Mat.Nummer;
    Art.Inv.Adressnr    # Mat.Lageradresse;
    Art.Inv.Anschrift   # Mat.Lageranschrift;
    Art.Inv.Lagerplatz  # Mat.Lagerplatz;

    Art.Inv.MEH         # 'kg';
// // ST 2019-05-13: Keine Artikeldaten für Inventur nutzen
/*
    Erx # RecLink(819,200,1,0);                 // Warengruppe holen
    if (Wgr_Data:IstMix()) then begin
      Art.Inv.Artikelnr # Mat.Strukturnr;
    end;
*/
    Art.Inv.Cust.Sort   # Aint(Mat.Paketnr);
    Art.Inv.Anlage.Datum  # Today;
    Art.Inv.Anlage.Zeit   # Now;
    Art.Inv.Anlage.User   # gUserName;
    Art.Inv.Nummer        # Lib_Nummern:ReadNummer('INVENTUR');
    if (Art.Inv.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      vErr # '"INVENTUR"-Nummernkreisproblem !';
      BREAK;
    end;
    RekInsert(259,0,'MAN');
    Proto(Aint(Mat.Nummer) + ';' + Aint(Art.Inv.Nummer) +';' + 'Zur Aufnahme übertragen');

  END;
  vProt->FsiClose();
  vWin->Lib_Progress:Term();

  if (vErr<>'') then begin
    Msg(99,vErr,0,0,0);
  end else begin
    gZLList->wpAutoUpdate # true;
    Msg(999998,'',0,0,0);
  end;
end;



//========================================================================
//  SFX_BSP_MAT_Inventur:VorlaufLohn
//========================================================================
sub VorlaufLohn()
begin
  _Vorlauf(false,true);
end;

sub VorlaufVoll()
begin
  _Vorlauf(true,false);
end;

sub VorlaufVollLohn()
begin
  _Vorlauf(true,true);
end;

sub VorlaufReset()
begin
  _Reset();
end;





//========================================================================
//  sub _CreateInvEntry(aTeam : int) begin
//  Erstellt "Leerseiten" für ein Team
//========================================================================
sub _CreateInvEntry(aLager : int; aAns : int; aTeam : int) begin
  RecBufClear(259);

  Art.Inv.Adressnr    # aLager;
  Art.Inv.Anschrift   # aAns;
  Art.Inv.MEH         # 'kg';
  Art.Inv.Cust.Sort   # 'TEAM' + Aint(aTeam);

  Art.Inv.Anlage.Datum  # Today;
  Art.Inv.Anlage.Zeit   # Now;
  Art.Inv.Anlage.User   # gUserName;
  Art.Inv.Nummer        # Lib_Nummern:ReadNummer('INVENTUR');
  if (Art.Inv.Nummer<>0) then
    Lib_Nummern:SaveNummer();

  Art.Inv.Nummer #  Art.Inv.Nummer + (10000 * aTeam);

  RekInsert(259,0,'MAN');
end;


//========================================================================
//  sub Aufnahmeseiten()
//  Startet die Leerseitenerstellung pro Team
//  SFX_BSP_Mat_Inventur:Aufnahmeseiten
//========================================================================
sub Aufnahmeseiten()
begin
  GV.Int.01   # 0;
  GV.Int.02   # 0;

  RecBufClear(100);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLageradresse');
  Lib_GuiCom:RunChildWindow(gMDI);
end;

//========================================================================
//  sub _Aufnahmeseiten(aLagerAdr : int; aLagerAns : int)
//  Erstellt "Leerseiten" für ein Team
//========================================================================
sub _Aufnahmeseiten(aLagerAdr : int; aLagerAns : int)
local begin
  vAbfrage        : alpha;
  vTeams          : alpha;
  vSeiten         : int;
  vZeilenProSeite : int;

  vTeam      : int;
  vTeamCount : int;
  vI,vJ      : int;
end
begin

  vZeilenProSeite # 16;

  vTeams  # '1,2,3,4,5,6,7';
  if (Dlg_Standard:Standard('Team (1,2,3,4,5,6,7)',var vTeams) = false) then
    RETURN;

  vAbfrage  # '5';
  if (Dlg_Standard:Standard('Anzahl Seiten)',var vAbfrage) = false) then
    RETURN;
  vSeiten # CnvIa(vAbfrage);

  vSeiten # vSeiten * vZeilenProSeite;
  vTeamCount # Lib_Strings:Strings_Count(vTeams,',')+1;
  FOR   vI # 1;
  LOOP  inc(vI);
  WHILE (vI <= vTeamCount) DO BEGIN
    vTeam # CnvIa(Str_Token(vTeams,',',vI));

    FOR   vJ # 1;
    LOOP  inc(vJ);
    WHILE (vJ <= vSeiten) DO BEGIN
      _CreateInvEntry(aLagerAdr, aLagerAns,vTeam);
    END;

  END;

  Msg(999998,'',_WinIcoInformation,_WinDialogOk,0);
end;

//========================================================================
//  sub AusLageranschrift()
//  Erstellt die Leerseiten für die gewählte Lageranschrift
//========================================================================
sub AusLageranschrift(aPara : alpha)
local begin
  vHdl  : int;
  vQ    : alpha;
end;
begin
  if (gSelected=0) then
    RETURN;

  RecRead(101,0,_RecId,gSelected);
  _Aufnahmeseiten(CnvIa(aPara),Adr.A.Nummer);
end;

//========================================================================
//  sub AusLageradresse()
//  Erstellt die Leerseiten für die gewählte Lageradresse
//========================================================================
sub AusLageradresse()
local begin
  Erx   : int;
  vHdl  : int;
  vQ    : alpha;
end;
begin
  if (gSelected=0) then
    RETURN;

  RecRead(100,0,_RecId,gSelected);
  Erx # RecLinkInfo(101,100,12,_recCount); // Mehr als eine Anschrift vorhanden?
  if (Erx > 1) then begin

      RecBufClear(101);         // ZIELBUFFER LEEREN

      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLageranschrift', false,false,'',Aint(Adr.Nummer));
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);

  end
  else begin
    Erx # RecLink(101,100,12,_recFirst); // Wenn nur 1, diese holen
    if(Erx > _rLocked) then
      RecBufClear(101);
    _Aufnahmeseiten(Adr.Nummer,1);
    RETURN;
  end;

end;


//========================================================================
//  SFX Set
//
//  SFX_BSP_MAt_Inventur:SetInvDaten
//========================================================================
sub SetInvDaten()
local begin
  Erx : int;
end;
begin
  if (RecRead(259,0,0,gZLList->wpdbrecid)<>_rOK) then RETURN;

  Erx # Mat_Data:Read(Art.inv.materialnr)
  if (Erx <> 200) then begin
    Msg(99,'Material konnte nicht gelesen werden',_WinIcoError,_WinDialogOk,1);
    RETURN;
  end;

  RecRead(259,1,_recLock);

  If (Art.Inv.Menge<=0.0) and ("Art.Inv.Stückzahl"<=0) then begin
    Art.Inv.Menge       # Mat.Bestand.Gew;
    "Art.Inv.Stückzahl" # Mat.Bestand.Stk;

    if (Art.Inv.LAgerplatz = '') AND (Mat.Lagerplatz <> '') then
      Art.Inv.LAgerplatz  # Mat.Lagerplatz;
  end else begin
    Art.Inv.Menge       # 0.0;
    "Art.Inv.Stückzahl" # 0;
  end;

  RekReplace(259);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
  /*
  if (gZLList->wpDbSelection<>0) then
    RecRead(259,gZLList->wpDbSelection, _recNext)
  else
  */
  RecRead(259,gZLList->wpDbKeyno, _recNext);
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
end;


//========================================================================
//  SFX Set
//
//  SFX_BSP_MAt_Inventur:TakeThisMat
//========================================================================
sub TakeThisMat()
local begin
  Erx   : int;
  vMat  : int;
  vInv  : int;
end;
begin

  if (RecRead(259,0,0,gZLList->wpdbrecid)<>_rOK) then RETURN;

  RecRead(259,1,0);
  if (Art.Inv.Menge = 0.0) then begin
    Msg(99,'Inventursatz hat keine Menge',_WinIcoError,_WinDialogOk,1);
    RETURN;
  end;
  vMat # Art.Inv.Materialnr;
  vInv # Art.Inv.Nummer;

  Art.Inv.Materialnr # vMat;
  FOR   Erx # RecRead(259,4,0)
  LOOP  Erx # RecREad(259,4,_RecNext)
  WHILE Erx <= _rMultiKey AND (Art.Inv.Materialnr = vMat) DO BEGIN

    if (Art.Inv.Nummer = vInv) then
      CYCLE;

    RecRead(259,1,_RecLock);
    Art.Inv.Menge       # 0.0;
    "Art.Inv.Stückzahl" # 0;
    Art.Inv.Lagerplatz # '';
    RekReplace(259);
  END;

  Art.Inv.Nummer # vInv ;
  RecRead(259,1,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
end;


//========================================================================
//  CheckAndResetMatKommission()
//  Prüft ob die Kommission für das geladene Material vorhanden ist und
//  entfernt diese, falls SIe nicht vorhanden ist
//========================================================================
sub CheckAndResetMatKommission()
local begin
  Erx : int;
end;
begin
  // ST 2019-12-04
  // Prüfung auf Kommission?
  if (Mat.Auftragsnr <> 0) then begin
    Erx # Auf_Data:Read(Mat.Auftragsnr, Mat.Auftragspos,true);
    if (Erx <= 400) then begin

      // Kommission entfernen
      PROTO(Aint(Art.Inv.Nummer) + ';' + Aint(Art.Inv.Materialnr) + ';' + ' Kommission '+Mat.Kommission+' entfernt, Auftrag nicht gefunden');

      // Lagerort aus Inventur übernehmen
      Erx # RecRead(200,1,_RecLock);
      Mat.Bemerkung2 # StrCut(Mat.Bemerkung2 + '; InvKom:'+Mat.Kommission,1,72);
      Mat.Kommission    # '';
      Mat.Auftragsnr    # 0;
      Mat.Auftragspos   # 0;
      Mat.KommKundennr  # 0;
      Mat.KommKundenSWort # '';
      RekReplace(200);
    end;
  end;
end;


//========================================================================
//  AFX Art.Inv.Loesche.MatOhneInv(aPara : alpha) : int
//  Löscht alle Materialien, die nicht in der Inventur waren
//
//  SFX_BSP_Mat_Inventur:LoescheMatOhneInv
//========================================================================
sub LoescheMatOhneInv(aPara : alpha) : int
local begin
  Erx       : int;
  aDat      : date;

  vOK       : logic;
  vMax      : int;
  vProgress : handle;

  vSel      : int;
  vSelName  : alpha;
  vQ,vQ2    : alpha(4000);
end
begin

  PROTOpen('inventur_04_mat_del_ohne_inventur');
  PROTO('Material;Bemerkung;');

  // Material selektieren...
  aDat # CnvDA(aPara);

  vQ  # '';
  Lib_Sel:QDate(var vQ,   '"Mat.Eingangsdatum"',  '>', 1.1.1950);
  Lib_Sel:QAlpha(var vQ,  '"Mat.Löschmarker"',    '=', '');
  Lib_Sel:QDate(var vQ,   '"Mat.Inventurdatum"',  '<', aDat);
  Lib_Sel:QFloat(var vQ,  '"Mat.Bestellt.Gew"',   '=', 0.0);
  Lib_Sel:QLogic(var vQ,  '"Mat.Inventur.DruckYN"', true);
//debug(vQ);
/*
  // oder REINES Material?
  vQ2 # '';
  Lib_Sel:QInt(var vQ2, '"Wgr.Dateinummer"',  '=', Wgr_Data:WertMaterial());
*/

  vSel # SelCreate(200, 1);
//  vSel->SelAddLink('',819, 200, 1, 'Wgr');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);

/*
  Erx # vSel->SelDefQuery('Wgr', vQ2);
  if (Erx != 0) then Lib_Sel:QError(vSel);
*/
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vMax # SelInfo(vSel, _SelCount);
  vProgress # Lib_Progress:Init('Bereinige Material ohne Inventur', vMax);

  TRANSON;

  FOR Erx # RecRead(200,vSel, _recFirst);
  LOOP Erx # RecRead(200,vSel, _recNext);
  WHILE ( Erx <=_rLocked) do begin

    if (!vProgress->Lib_Progress:Step()) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      SelClose(vSel);
      SelDelete(200, vSelName);
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      ErrSet(Erx);
      RETURN -1;
    end;

    // ST 2019-12-12  Kommission ggf. hier geradeziehen, wie bei Übernahme
    CheckAndResetMatKommission();

    if (Art_Inv_Subs:_Loesche_verlorenes_Mat_inner(aDat, false)=false) then begin  // FÜR MATERIAL
      vProgress->Lib_Progress:Term();
      SelClose(vSel);
      SelDelete(200, vSelName);
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      ErrSet(Erx);
      RETURN -1;
    end;

    Proto(Aint(Mat.Nummer) + ';' + 'erfolgreich geläöscht');

  END;

  TRANSOFF;

  vProt->FsiClose();
  vProgress->Lib_Progress:Term();

  SelClose(vSel);
  SelDelete(200, vSelName);

  Erx # _rOK;
  Erg # Erx;    // TODOERX
  ErrSet(Erx);
  RETURN 1;
end;



//========================================================================
//  sub AddAktionsliste(aData : alpha) begin
//========================================================================
sub AddAktionsliste(aDatum : date; aInvNr : int; aBemerkung : alpha)
local begin
end
begin

  RecBufClear(204);
  Mat.A.Materialnr  # Mat.Nummer;
  Mat.A.Aktionsmat  # Mat.Nummer;
  Mat.A.Bemerkung   # StrCut(aBemerkung,1,32);
  Mat.A.Aktionstyp  # 'INV';
  Mat.A.Aktionsnr   # aInvNr;
  Mat.A.Aktionsdatum  # aDatum;
  Mat_A_Data:Insert(_RecUnlock,'AUTO');
/*
  Cus_Data:Insert(200,RecInfo(200,_RecID),17,StrCut(aDatum + ' / ' + aInvNr,    1,128));
  Cus_Data:Insert(200,RecInfo(200,_RecID),18,StrCut(aDatum + ' / ' + aBemerkung,1,128));
*/

end;

//========================================================================
//  AFX Uebern.EinzelMat(aPara : alpha) : int
//  Verbucht die MAteiralinventur
//
//  SFX_BSP_Mat_Inventur:Uebern.EinzelMat
//========================================================================
sub Uebern.EinzelMat(aPara : alpha) : int
local begin
  Erx     : int;
  aDat    : date;
  vGew    : float;
  vFak    : float;

  vProgr : int;
end;
begin

  aDat  # CnvDa(aPAra);

  PROTOpen('inventur_03_inv_uebernahme');
  PROTO('Inventur;Material;Daten;Bemerkung;');


  vProgr # Lib_Progress:Init( 'Inventurübernahme ', RecInfo( 259, _recCount),true );

  APPOFF();

  TRANSON;

  FOR   Erx # RecRead(259,1,_recFirst)     // Inventur loopen
  LOOP  Erx # RecRead(259,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vProgr->Lib_Progress:Step();

/*
    if (Art.Inv.Materialnr = 916025) then begin
      debug('xcxxx');
    end;
*/
//debug(Aint(Art.Inv.Nummer));

    // 09.10.2017 AH:
    if (Art.Inv.Menge<=0.0) and ("Art.Inv.Stückzahl"<=0) then begin
      PROTO(Aint(Art.Inv.Nummer) + ';' + Aint(Art.Inv.Materialnr) + ';' + ' Menge = null, nicht übernommen in Materialbestand');
      CYCLE;
    end;

    if (Art.Inv.Materialnr=0) then begin
      TRANSBRK;
      APPON();
      vProgr->Lib_Progress:Term();
      Error(99,'Keine Materialnummer in Inventursatz '+aint(Art.Inv.Nummer));
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      vProt->FsiClose();
      RETURN -1;
    end;

    Erx # Mat_Data:Read(Art.Inv.Materialnr);
    if (Erx <> 200) then begin
      TRANSBRK;
      APPON();
      vProgr->Lib_Progress:Term();
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Material "'+Aint(Art.Inv.Materialnr)+'" konnte nicht gelesen werden!');
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      vProt->FsiClose();
      RETURN -1;
    end;
    if ("Mat.Löschmarker" <> '') then begin
      TRANSBRK;
      APPON();
      vProgr->Lib_Progress:Term();
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Material "'+Aint(Art.Inv.Materialnr)+'" bereits gelöscht!');
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      vProt->FsiClose();
      RETURN -1;
    end;
    if (Mat.Status>=c_status_bestellt) and (Mat.Status<=c_status_bisEK) then begin
      TRANSBRK;
      APPON();
      vProgr->Lib_Progress:Term();
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Material "'+Aint(Art.Inv.Materialnr)+'" hat falschen Status!');
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      vProt->FsiClose();
      RETURN -1;
    end;


    CheckAndResetMatKommission();

    // ST 2019-12-09 Projekt 2035/15 Keine Mengenberechnung bei Brockhaus; Geht nur um kgs
    vGew  # Art.Inv.Menge;
    //if (Mat_Data:SetInventur(Mat.Nummer, Art.Inv.Lagerplatz, aDat, true, "Art.Inv.Stückzahl", vGew, Art.Inv.Menge, Art.Inv.ChargeFehlte, 259)=false) then begin
    if (Mat_Data:SetInventur(Mat.Nummer, Art.Inv.Lagerplatz, aDat, false, "Art.Inv.Stückzahl", vGew, Art.Inv.Menge, Art.Inv.ChargeFehlte, 259)=false) then begin
      TRANSBRK;
      APPON();
      vProgr->Lib_Progress:Term();
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Inventurmengen konnte nicht in das Bestandsbuch eingetragen werden');
      Erx # _rNoRec;
      Erg # Erx;    // TODOERX
      vProt->FsiClose();
      RETURN -1;
    end;

    // ST 2020-10-02 2042/158/4: Anhänge ins Mat verschieben
    if (Art.Inv.Nummer = 2620) then begin
      debug('');
    end;
    Anh_Data:CopyAll(259,200,true,false);


    // Lagerort aus Inventur übernehmen
    Erx # RecRead(200,1,_RecLock);
    Mat.Lageradresse    # Art.Inv.Adressnr;
    Mat.Lageranschrift  # Art.Inv.Anschrift;
    RekLink(101,200,6,0); //  Stichwort lesen
    Mat.LagerStichwort # Adr.A.Stichwort;
    RekReplace(200);

    PROTO(Aint(Art.Inv.Nummer) + ';' + Aint(Art.Inv.Materialnr) + ';' + ' übernommen in Materialbestand');
    AddAktionsliste(aDat,Art.Inv.Nummer,Art.Inv.Bemerkung);

    // 09.11.2017 AH: Wenn "Restkarte", dann auch Einsatzkarte aufnehmen
    if (Mat.Status>=700) and (Mat.Status<=749) and ("Mat.Vorgänger"<>0) then begin
      Mat.Nummer # "Mat.Vorgänger";
      Erx # RecRead(200,1,0);
      if (Erx<=_rLocked) then begin
        // Aktionen loopen...
        FOR Erx # RecLink(204,200,14,_recFirst)
        LOOP Erx # RecLink(204,200,14,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Mat.A.Entstanden=Art.Inv.Materialnr) and (Mat.A.Aktionstyp=c_Akt_BA_Rest) then begin
            Erx # RecRead(200,1,_recLock);
            Mat.Lagerplatz      # Art.Inv.Lagerplatz;
            Mat.InventurDatum   # aDat;

            Mat.Lageradresse    # Art.Inv.Adressnr;
            Mat.Lageranschrift  # Art.Inv.Anschrift;
            RekLink(101,200,6,0); //  Stichwort lesen
            Mat.LagerStichwort # Adr.A.Stichwort;

            RekReplace(200);
            PROTO(Aint(Art.Inv.Nummer) + ';' + Aint(Art.Inv.Materialnr) + ';' + ' verebtes Mat aktualisiert: ' + Aint(Mat.Nummer) );
            AddAktionsliste(aDat,Art.Inv.Nummer,Art.Inv.Bemerkung);
            BREAK;
          end;
        END;
      end;
    end;

  END;

  TRANSOFF; // 20.11.2017 AH
  APPON();
  vProgr->Lib_Progress:Term();

  vProt->FsiClose();


  Erx # _rOK;
  Erg # Erx;    // TODOERX
  RETURN 1;
end;


//========================================================================
