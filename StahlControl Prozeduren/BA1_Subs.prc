@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Subs
//                  OHNE E_R_G
//
//  Info
//
//
//  26.08.2010  AI  Erstellung der Prozedur
//  09.02.2012  AI  NEU:CreateAufBAG
//  09.02.2012  AI  NEU:ShowAufBAG
//  09.02.2012  AI  NEU:EinsatzLautAuftragsliste
//  10.02.2012  AI  NEU:WeiterBearbeitungVonPos
//  01.03.2012  AI  NEU:RecalcFM
//  11.04.2013  AI  MatMEH
//  16.12.2014  AH  "CreateAufBAG" heisst nun "CreateBAG"
//  27.02.2015  AH  "EinsatzLautAuftragsListe" übernimmt Auf.Reservierungen in Theorie bzw. setzt sie daneben
//  06.03.2015  AH  "Merge"
//  07.07.2015  ST  Kreditlimitprüfung für Lohnfahren wird auch abgefragt, falls BA-Abfragesettings nicht angeben ist
//  21.01.2016  ST  Anpassung Kreditlimitprüfung, Pro Rechnungsempfänger wird nur noch einmal geprüft
//  23.08.2016  AH  "RecalcKosten" mit aDiffText
//  17.03.2017  AH  "RecalcKosten" starten KEINE Untertransaktionen in Recalc
//  13.03.2018  AH  "Clear"
//  07.08.2019  AH  Fix: "Clear" löscht auf LFS
//  13.03.2020  AH  Kostenänderungen werden fakturaseitig beachten
//  11.10.2021  AH  ERX
//
//  Subprozeduren
//    SUB Kreditlimit
//    SUB RecalcKosten(aSilent : logic; aNoProto : logic; opt aDiffTxt  : int; opt aNoTrans : logic) : logic;
//    SUB RecalcAllKosten() : logic;
//    SUB CreateBAG(opt aAuf : int) : int;
//    SUB ShowAufBAG(aBAG : int; aAufList : int) : logic;
//    SUB EinsatzLautAuftrag(aAufNr : int; aAufPos : int; opt aTheoID : int) : logic
//    SUB EinsatzLautAuftragsliste(aList : int; opt aTheoID : int) : logic
//    SUB WeiterBearbeitungVonPos(aPos : int) : logic
//    SUB RecalcOutput();
//    SUB MErxe(aBAG : int) : logic;
//    SUB Clear();
//
//========================================================================
@I:Def_Global
@I:Def_BAG

//========================================================================
// Kreditlimit
//
//  ST 2016-01-21: Prüfung pro Rechnungsempfänger als Performanceverbesserung
//========================================================================
sub Kreditlimit(opt aPos : int) : logic;
local begin
  Erx             : int;
  vKLim           : float;
  vAbbruchSetting : alpha;
  vCteListReEmpf  : int;
  vRet            : logic;
  v702            : int;
end;
begin

  v702 # RekSave(702);
//  if ("Set.KLP.BA-Druck"='') then RETURN true;
// ST 2015-07-07: Fahraufträge sollen auch geprüft werden, wenn das Setting für
//                BA - Druck nicht angegeben ist
  vAbbruchSetting # "Set.KLP.BA-Druck";
  if (vAbbruchSetting ='') AND ("Set.KLP.LFA-Druck" <> '') then
    vAbbruchSetting # "Set.KLP.LFA-Druck";


  vCteListReEmpf  # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vRet  # true;
  FOR   Erx # RecLink(702,700,1,_RecFirst);   // Positionen loopen
  LOOP  Erx # RecLink(702,700,1,_RecNext);    // Positionen loopen
  WHILE (Erx<=_rLocked) do begin

    if (aPos<>0) and (aPos<>BAG.P.Position) then CYCLE;

    if (BAG.P.Typ.VSBYN=n) or (BAG.P.Auftragsnr=0) OR (BAG.P.Auftragspos = 0) then
      CYCLE;


    Erx # RecLink(401,702,16,_recfirst);    // Auftragsposition holen
    if (Erx<=_rLocked) then begin
      Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
      if (Erx>_rLocked) or (Auf.Vorgangstyp<>c_Auf) then begin
        vRet # false;
        BREAK;
      end;

      if (vCteListReEmpf->CteRead(_CteFirst | _CteSearch,0,Aint(Auf.Rechnungsempf)) <> 0) then
        CYCLE;
      vCteListReEmpf->CteInsertItem(Aint(Auf.Rechnungsempf),Auf.Rechnungsempf,'');

      //if (Adr_K_Data:Kreditlimit_BA(Auf.Rechnungsempf, "Set.KLP.BA-Druck", var vKLim, Auf.Nummer)=false) then
      if (Adr_K_Data:Kreditlimit_BA(Auf.Rechnungsempf, vAbbruchSetting, var vKLim, Auf.Nummer)=false) then begin
        vRet # false;
        BREAK;
      end;
    end;


  END;

  vCteListReEmpf->CteClose();

  RekRestore(v702);

  RETURN vRet;
end;


//========================================================================
//  BuildPosNAchfolger
//========================================================================
sub BuildPosNachfolger(
  var aDict   : int);
local begin
  Erx       : int;
  v702,v701 : int;
  vInhalt   : alpha;
  vI        : int;
end;
begin

  if (BAG.P.Aktion=c_BAG_VSB) or (BAG.P.Fertig.Dat=0.0.0) then RETURN;

  // als neu aufnehmbar? -> sonst schon da!
  if (Lib_Dict:Add(var aDict, aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position), cnvai(BAG.P.Level, _fmtnumleadzero|_FmtNumnoGroup, 0 ,8))=false) then RETURN;

  // Output loopen
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.NachPosition=0) then CYCLE;

    v702 # RekSave(702);
    Erx # RecLink(702,701,4,_RecFirst);   // NACH-POS holen
    if (Erx>_rLocked) then begin
      RekRestore(v702);
      CYCLE;
    end;
    v701 # RekSave(701);
    BuildPosNachfolger(var aDict);
    RekRestore(v701);
    RekRestore(v702);
  END;

end;


//========================================================================
// RecalcKosten
//
//========================================================================
sub RecalcKosten(
  aSilent       : logic;
  aNoProto      : logic;
  opt aDiffTxt  : int;
  opt aDict     : int;
) : logic;
local begin
  Erx       : int;
  v702      : int;
  vAbDatum  : date;
  vItem     : int;
  vMyDiff   : logic;
end;
begin

  if (BAG.VorlageYN) then RETURN true;

  APPOFF();

  // 13.03.2020 AH: auch hier Kostenänderungen fakturaseitig beachten
  if (aDiffTxt=0) then begin
    vMyDiff # true;
    aDiffTxt # TextOpen(20);
  end;

  if (aDict=0) then begin
    FOR Erx # RecLink(702,700,4,_RecFirst)    // Positionen PEr LEVEL loopen
    LOOP Erx # RecLink(702,700,4,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.P.Aktion=c_BAG_VSB) or (BAG.P.Fertig.Dat=0.0.0) then CYCLE;

      v702 # RekSave(702);
      if (BA1_Kosten:UpdatePosition(BAG.Nummer, BAG.P.Position, aSilent, aNoProto, true, aDiffTxt, TRUE)=false) then begin  // OHNE TRANSAKTIONEN !!!!
        RekRestore(v702);
        APPON();
//        Msg(999999,'',0,0,0);
        if (vMyDiff) then TextClose(aDiffTxt);
        RETURN false;
      end;
      RekRestore(v702);
      RecRead(702,1,0);

    END;
    if (vMyDiff) then begin
      Erl_Data:ParseDiffText(aDiffTxt, false, 'ERE');
      TextClose(aDiffTxt);
    end;

    APPON();
    RETURN true;
  end;


  // Dictionary mit Posten vorhanden...
  if (aDict<>0) then begin
    v702 # RekSave(702);
    FOR vItem # aDict->CteRead(_CteFirst|_CteCustom);
    LOOP vItem # aDict->CteRead(_CteNext|_CteCustom, vItem);
    WHILE (vItem<>0) do begin
      BAG.P.Nummer    # cnvia(str_token(vItem->spname,'/',1));
      BAG.P.Position  # cnvia(str_token(vItem->spname,'/',2));
      Erx # RecRead(702,1,0);
      if (Erx>_rLocked) then CYCLE;
      Erx # RecLink(700,702,1,_RecFirst); // BA-Kopf holen
      if (BA1_Kosten:UpdatePosition(BAG.Nummer, BAG.P.Position, aSilent, aNoProto, true, aDiffTxt, TRUE)=false) then begin  // OHNE TRANSAKTIONEN !!!!
        RekRestore(v702);
        if (vMyDiff) then TextClose(aDiffTxt);
        APPON();
//        Msg(999999,'',0,0,0);
        RETURN false;
      end;
    END;
    RekRestore(v702);
  end;

  if (vMyDiff) then begin
    Erl_Data:ParseDiffText(aDiffTxt, false, 'ERE');
    TextClose(aDiffTxt);
  end;

  APPON();

  RETURN true;
end;


//========================================================================
// RecalcAllKosten
//
//========================================================================
sub RecalcAllKosten() : logic;
local begin
  Erx       : int;
  vBuf700   : int;
  vBuf702   : int;
  vAbDatum  : date;
end;
begin

  if (Dlg_Standard:Datum(translate('ab') + ' ' + translate('Abschlussdatum'), var vAbDatum, today) = false) then RETURN true;

  vBuf700 # RekSave(700);

  RecBufClear(700);
  BAG.Fertig.DAtum # vAbDatum;
  Erx # RecRead(700,3,0);
  Erx # RecRead(700,1,0);
  WHILE (Erx<=_rMultikey) and (BAG.Fertig.Datum>=vAbDatum) do begin
    RecalcKosten(n,y);

    Erx # RecRead(700,3,_recNext);
  END;

  RekRestore(vBuf700);
  Msg(999998,'',0,0,0);
end;


//========================================================================
//  CreateBAG
//
//========================================================================
sub CreateBAG(opt aAuf : int) : int;
local begin
  Erx : int;
end;
begin

  TRANSON;

  RecBufClear(700);
  BAG.Nummer # Lib_Nummern:ReadNummer('Betriebsauftrag');
  if (BAG.Nummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN 0;
  end;

  if (aAuf<>0) then
    BAG.Bemerkung     # Translate('Auftrag')+' '+aint(aAuf);

  BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
  BAG.Anlage.Datum  # Today;
  BAG.Anlage.Zeit   # Now;
  BAG.Anlage.User   # gUserName;
  Erx # RekInsert(700,0,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RETURN 0;
  end;

  TRANSOFF;

  RETURN BAG.Nummer;
end;


//========================================================================
//  ShowAufBAG
//        oder "BA1_Main:Start"
//========================================================================
SUB ShowAufBAG(
  aBAG      : int;
  aAufList  : int) : logic;
local begin
  Erx     : int;
  vHdl    : int;
end;
begin

  BAG.Nummer # aBAG;
  Erx # RecRead(700,1,0);   // BA holen
  if (Erx>_rLocked) then RETURN false;

  RecBufClear(702);
//  gMDi->wpvisible # false;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);//here+':AusBA1Combo',y);

  vHdl # WinSearch(gMDI, 'lb.zuAuftragsList');
  vHdl->wpcustom # aint(aAufList);

// 29.08.2021 AH
//  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//  lib_Guicom:RecallWindow(gMDI); // Usersettings wiederherstellen
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;


//========================================================================
// EinsatzLautAuftrag
//
//========================================================================
SUB EinsatzLautAuftrag(
  aAufNr      : int;
  aAufPos     : int;
  opt aTheoID : int) : logic
local begin
  Erx       : int;
  vBuf401   : int;
  vBuf401B  : int;
  vA        : alpha;
  vItem     : int;
  vFreiKG   : float;
  vResKG    : float;
  vResStk   : int;
  vNeuesMat : int;
  vOK       : logic;
end;
begin

  TRANSON;

  vBuf401 # RekSave(401);

  if (Auf.P.Nummer<>aAufNr) or (Auf.P.Position<>aAufPos) then begin
    Auf.P.Nummer    # aAufNr;
    Auf.P.Position  # aAufPos;
    Erx # RecRead(401,1,0);   // Aufpos holen
  end;

  vBuf401b # RekSave(401);
  Erx # RecLink(203, 401, 18,_recFirst);   // Reservierungen loopen
  WHILE (Erx<=_rLocked) do begin

    Erx # RecLink(200,203,1,_RecFirst);    // Material holen
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(203008,aint(Mat.R.Reservierungnr)+'|'+aint(mat.Nummer)+'|'+aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position),_WinIcoError,_WinDialogOk,0);
      Recbufdestroy(vBuf401b);
      RekRestore(vBuf401);
      RETURN false;
    end;

    vFreiKG # Mat.Bestand.Gew - Mat.R.Gewicht;
    vResKG  # Mat.R.Gewicht;
    vResStk # "Mat.R.Stückzahl";
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      TRANSBRK;
      Msg(203008,aint(Mat.R.Reservierungnr)+'|'+aint(mat.Nummer)+'|'+aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position),_WinIcoError,_WinDialogOk,0);
      Recbufdestroy(vBuf401b);
      RekRestore(vBuf401);
      RETURN false;
    end;

    if (vFreiKG>0.0) and (BAG.P.Aktion<>c_BAG_Fahr) then begin
      if (Mat_Data:Splitten(vResStk, vResKG, vResKG, 0.0, today, now, var vNeuesMat)=false) then begin
        TRANSBRK;
        Msg(010005, AInt(Auf.P.Position)+'|'+AInt(Mat.Nummer),_WinIcoError,_WinDialogOk,0);
        Recbufdestroy(vBuf401b);
        RekRestore(vBuf401);
        RETURN false;
      end;
      Mat.Nummer # vNeuesMat;
      Erx # RecRead(200,1,0);
      vFreiKG # 0.0;
    end;

    // 27.02.2015
    if (aTheoID=0) or (aTheoID>100000) then begin
      if (BAG.P.Aktion=c_BAG_FAHR) then
        vOK # BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer, vResStk, vResKG, vResKG, vResKG )
      else
        vOK # BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer);

      if (vOK) and (aTheoID>100000) then begin
        vOK # BA1_IO_I_Data:KlonenVon(aTheoID - 100000);
      end;
    end
    else if (aTheoID<100000) then begin
      if (BAG.P.Aktion<>c_BAG_FAHR) then
        vOK # BA1_IO_I_Data:TheorieWirdEcht(aTheoID, Mat.Nummer)
      else
        vOK # BA1_IO_I_Data:TheorieWirdEcht(aTheoID, Mat.Nummer, vResStk, vResKG, vResKG, vResKG );
      aTheoID # aTheoID + 100000;
    end;


    if (vOK=false) then begin
      TRANSBRK;
      Msg(701031, AInt(Mat.Nummer)+'|('+Translate('Auftrag')+' '+aint(Auf.P.Nummer)+'('+aint(Auf.P.Position)+')',_WinIcoError,_WinDialogOk,0);
      Recbufdestroy(vBuf401b);
      RekRestore(vBuf401);
      RETURN false;
    end;

    RecBufCopy(vBuf401b,401);

    Erx # RecLink(203, 401, 18,_recFirst);   // Reseriverungen loopen
  END;
  RecBufDestroy(vBuf401b);

  RekRestore(vBuf401);
  TRANSOFF;

  RETURN true;
end;


//========================================================================
// EinsatzLautAuftragsliste
//
//========================================================================
SUB EinsatzLautAuftragsliste(
  aList       : int;
  aSilent     : logic;      // 2023-07-19 AH wegen der MSGBOX
  opt aTheoID : int;
  ) : logic
local begin
  Erx       : int;
  vBuf401   : int;
  vBuf401B  : int;
  vA        : alpha;
  vItem     : int;
  vFreiKG   : float;
  vResKG    : float;
  vResStk   : int;
  vNeuesMat : int;
  vOK       : logic;
end;
begin

  // Ankerfunktion
  if (RunAFX('BAG.Subs.EinsatzLautAuftragsliste',aint(aList)+'|'+abool(aSilent))<>0) then RETURN (AfxRes=_rOK);

  if (aSilent=false) then
    if (Msg(701032,'',_WinIcoQuestion,_WinDialogYesNo,1)<>_WinIdYes) then RETURN true;

  TRANSON;

  vBuf401 # RekSave(401);

  FOR vItem # aList->CteRead( _cteFirst );
  LOOP vItem # aList->CteRead( _cteNext, vItem );
  WHILE (vItem<>0) do begin
    vA # Str_Token(vItem->spname,'/',1);
    Auf.P.Nummer # cnvia(vA);
    vA # Str_Token(vItem->spname,'/',2);
    Auf.P.Position # cnvia(vA);
    Erx # RecRead(401,1,0);   // Aufpos holen

    // 1. Position?
//    if (BAG.P.Position=1) then begin
//      BA1_Lohn_Subs:Erzeuge701();
//      CYCLE;
//    end;
    vOK # EinsatzLautAuftrag(Auf.P.Nummer, Auf.P.Position, aTheoID);
    if (vOK=false) then begin
      TRANSBRK;
      RETURN false;
    end;
  END;  // Liste

  RekRestore(vBuf401);
  TRANSOFF;

  RETURN true;
end;


//========================================================================
// WeiterBearbeitungVonPos
//
//========================================================================
SUB WeiterBearbeitungVonPos(aPos : int) : logic
local begin
  Erx     : int;
  vBuf702 : int;
end;
begin

  TRANSON;

  vBuf702 # RekSave(702);

  FOR Erx # RecLink(701,700,3,_recfirst)  // alle IOs loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.MaterialTyp<>c_IO_BAG) or (BAG.IO.NachBAG<>0) then CYCLE;
    if (BAG.IO.vonPosition<>aPos) then CYCLE;

    Erx # RecRead(701,1,_recLock);
    if (erx<>_rOK) then begin
      TRANSBRK;
      RekRestore(vBuf702);
      Error(701010,'');
      ErrorOutput;
      RETURN false;
    end;

    BAG.IO.NachBag        # vBuf702->BAG.P.Nummer;
    BAG.IO.NachPosition   # vBuf702->BAG.P.Position;
    BAG.IO.NachFertigung # 0;
    // 11.2.2011
    if ("BAG.P.Typ.1in-1outYN") and
      ((BAG.P.Aktion<>c_BAG_Fahr09) or (BAG.P.ZielVerkaufYN=n)) then    // 1zu1 Arbeitsgang?
      BAG.IO.NachFertigung # 1;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');

      // Output aktualisieren
    if (erx<>_rOK) or (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      RekRestore(vBuf702);
      Error(701010,'');
      ErrorOutput;
      RETURN false;
    end;

  END;

  RekRestore(vBuf702);

  TRANSOFF;

  RETURN true;
end;


// call Ba1_Subs:RecalcOutput
//========================================================================
// RecalcOutput
//
//========================================================================
sub RecalcOutput() : logic;
local begin
  Erx   : int;
  vStk  : int;
  vGewN : float;
  vGewB : float;
  vM    : float;
  v701  : int;
end;
begin

  // Errechnet die OUT-Mengen neu
  RecBufClear(701);

  FOR Erx # RecRead(701,1,_recfirst)
  LOOP Erx # RecRead(701,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.Materialtyp<>c_IO_BAG) and (BAG.IO.Materialtyp<>c_IO_MAT) then CYCLE;

    v701 # RekSave(701);
    vStk  # 0;
    vGewN # 0.0;
    vGewB # 0.0;
    vM    # 0.0;

    // bei echtem Einsatz
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      FOR Erx # RecLink(707,701,12,_recFirst);  // FMs aus DIESEM Input
      LOOP Erx # RecLink(707,701,12,_recNext)
      WHILE (Erx<=_rLocked) do begin
        vStk   # vStk   + "BAG.FM.Stück";
        vGewN  # vGewN  + BAG.FM.Gewicht.Netto;
        vGewB  # vGewB  + BAG.FM.Gewicht.Brutt;
        if (BAG.FM.MEH=BAG.IO.MEH.Out) then
          vM # vM + BAG.FM.Menge
        else
          vM # vM + Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);
      END;
    end;

    // bei Weiterbearbeitung
    if (BAG.IO.Materialtyp=c_IO_BAG) then begin

      BAG.Nummer # BAG.IO.Nummer;
      FOR Erx # RecLink(707,700,5,_recFirst);    // all FMs loopen
      LOOP Erx # RecLink(707,700,5,_recNext)
      WHILE (Erx<=_rLocked) do begin

        Erx # RecLink(701,707,9,_RecFirst);   // Input holen
        if (Erx>_rLocked) then CYCLE;

        if (v701->BAG.IO.ID<>BAG.IO.BruderID) then CYCLE;

        vStk   # vStk   + "BAG.FM.Stück";
        vGewN  # vGewN  + BAG.FM.Gewicht.Netto;
        vGewB  # vGewB  + BAG.FM.Gewicht.Brutt;
        if (BAG.FM.MEH=BAG.IO.MEH.Out) then
          vM # vM + BAG.FM.Menge
        else
          vM # vM + Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);

      END;
    end;

/***
      BAG.Nummer # BAG.IO.Nummer;
      FOR Erx # RecLink(707,700,5,_recFirst);    // all FMs loopen
      LOOP Erx # RecLink(707,700,5,_recNext)
      WHILE (Erx<=_rLocked) do begin

        if (BAG.FM.BruderID<>BAG.IO.ID) then CYCLE;

        vStk   # vStk   + "BAG.FM.Stück";
        vGewN  # vGewN  + BAG.FM.Gewicht.Netto;
        vGewB  # vGewB  + BAG.FM.Gewicht.Brutt;
        if (BAG.FM.MEH=BAG.IO.MEH.Out) then
          vM # vM + BAG.FM.Menge
        else
          vM # vM + Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);

      END;

***/
/***
    Erx # RecLink(702,701,4,_recfirst);     // NACH-Pos holen

    vStk  # 0;
    vGewN # 0.0;
    vGewB # 0.0;
    vM    # 0.0;
    FOR Erx # RecLink(707,702,5,_recFirst)  // ALLE FM loopen
    LOOP Erx # RecLink(707,702,5,_recNext)
    WHILE (Erx<=_rLocked) do begin

      Erx # RecLink(701,707,9,_RecFirst);   // Input holen
      if (Erx>_rLocked) then CYCLE;

//      if (BAG.IO.BruderID<>v701->BAG.IO.ID) and (BAG.IO.BruderID<>0) then CYCLE;
debug('A');
      if (BAG.FM.BruderID<>v701->BAG.IO.ID) then CYCLE;
debug('B');
      vStk   # vStk   + "BAG.FM.Stück";
      vGewN  # vGewN  + BAG.FM.Gewicht.Netto;
      vGewB  # vGewB  + BAG.FM.Gewicht.Brutt;
      if (BAG.FM.MEH=BAG.IO.MEH.Out) then
        vM # vM + BAG.FM.Menge
      else
        vM # vM + Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);
    END;
***/
    RekRestore(v701);


    // Korrektur...
    if (BAG.IO.Ist.Out.Stk<>vStk) or
      (BAG.IO.Ist.Out.GewN<>vGewN) or
      (BAG.IO.Ist.Out.GewB<>vGewB) or
      (BAG.IO.Ist.Out.Menge<>vM) then begin

//debug('Korrketur bei '+aint(bag.io.nummer)+'/'+aint(bag.io.ID));
//debug('von '+aint(bag.io.ist.out.stk)+'stk '+anum(bag.io.ist.out.Gewn,0)+'N '+anum(bag.io.ist.out.gewB,0)+'B '+anum(bag.io.ist.out.Menge,0)+'M');
      Erx # RecRead(701,1,_RecLock);
      if (Erx=_rOK) then begin
        BAG.IO.Ist.Out.Stk    # vStk;
        BAG.IO.Ist.Out.GewN   # vGewN;
        BAG.IO.Ist.Out.GewB   # vGewB;
        BAG.IO.Ist.Out.Menge  # vM;
        Erx # RekReplace(701,_recunlock,'AUTO');
      end;
      if (Erx<>_rOK) then RETURN false;
//debug('auf '+aint(bag.io.ist.out.stk)+'stk '+anum(bag.io.ist.out.Gewn,0)+'N '+anum(bag.io.ist.out.gewB,0)+'B '+anum(bag.io.ist.out.Menge,0)+'M');
    end;

  END;

  // Erfolg
  RETURN true;
end;


//========================================================================
//  Merge
//
//========================================================================
sub Merge(aBAG : int) : logic;
local begin
  Erx     : int;
  vBAG    : int;
end;
begin

  BAG.Nummer # aBAG;
  Erx # RecRead(700,1,0);
  if (Erx<>_rOK) then begin
    Msg(700002,aint(aBAG),0,0,0);
    RETURN false;
  end;

  if ("BAG.Löschmarker"<>'') then begin
    Msg(702009,'',0,0,0);
    RETURN false;
  end;

  if (Dlg_Standard:Anzahl(Translate('von')+' '+Translate('BAG'),var vBAG)=false) then RETURN false;

//  if (BA1_Data:Merge(aBAG, vBAG)=false) then begin
  if (BA1_P_Data:ImportBA(aBAG, vBAG, 0, 0, false)=0) then begin
    ErrorOutput;
    RETURN false;
  end;

  Msg(999998,'',0,0,0);

  RETURN true;
end;


//========================================================================
//  _DeleteAllInput
//    Entfernt alle Inputs          +TRANS +ERROR
//========================================================================
Sub _DeleteAllInput() : logic
local begin
  Erx       : int;
  vBuf701   : int;
  vBuf707   : int;
  vKill707  : logic;
end;
begin

  FOR Erx # RecLink(701, 702, 2, _recFirst) // Input loopen..
  LOOP Erx # RecLink(701, 702, 2, _recFirst)
  WHILE (Erx<=_rLocked) do begin

    // hierauf bereits verwogen?
    if (BA1_IO_I_Data:BereitsVerwogen() = true) then begin
      Error(701007,'');
      RETURN false;
    end;

    // MS 18.03.2010
    if (BAG.P.Aktion = c_BAG_VSB) then begin
      if(BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) then begin
        Error(701026, '');
        RETURN false;
      end;
    end;

    // Weiterbearbeitung?
    if (BAG.IO.Materialtyp=c_IO_BAG) then begin
      vBuf701 # RecBufCreate(701);
      vBuf707 # RecBufCreate(707);
      vKill707 # n;
      FOR Erx # RecLink(vBuf707,701,20,_recFirst)   // Brüder durchlaufen
      LOOP Erx # RecLink(vBuf707,701,20,_recNext)
      WHILE (Erx<=_rLocked) and (vKill707=n) do begin
        Erx # RecLink(vBuf701,vBuf707,8,_recFirst);
        if (Erx<=_rLocked) then begin
          if (vBuf701->BAG.IO.NachBAG<>0) then
            vKill707 # y;
        end;
      END;
      RecBufDestroy(vBuf707);
      RecBufDestroy(vBuf701);
    end;


    if (vKill707) then begin
      Error(701026,'');
      RETURN false;
    end;

    if (BA1_IO_I_Data:DeleteInput(false) = false) then begin
      RETURN false;
    end;

  END;


  RETURN true;
end;


//========================================================================
// _DeletePos
//    Entfernt eine Position      +TRANS +ERROR
//========================================================================
sub _DeletePos() : logic
local begin
  Erx     : int;
  vOK     : logic;
end;
begin

  // bereits gelöscht?
  if ("BAG.P.Löschmarker"<>'') then begin
    Error(702001,gTitle);
    RETURN false;
  end;

  // bereits fertiggemeldet?
  if (BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) or
    (RecLinkInfo(709,702,6,_RecCount)>0) then begin
    Error(702002,gTitle);
    RETURN false;
  end;

  // Input checken
  if (BA1_P_Data:EinsatzVorhanden() = true) then begin
    Error(702013,gTitle);
    RETURN false;
  end;

   // Fertigungen prüfen
  vOK # y;
  Erx # RecLink(703,702,4,_RecFirst);
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (RecLinkInfo(701,703,4,_recCount)>0) then vOK # n;
    Erx # RecLink(703,702,4,_RecNext);
  END
  if (vOK=n) then begin
    Error(702003,gTitle);
    RETURN false;
  END;


  RETURN BA1_P_Data:Delete(vOK);
end;


//========================================================================
//  Clear   löscht alle Positionen, Fertigungen, Arbeitsgänge...
//========================================================================
SUB Clear();
local begin
  Erx     : int;
  vErr    : logic;
  vTxt    : int;
  vA      : alpha;
end
begin
  if (Msg(700015,'',_WinIcoQuestion, _WinDialogYesNo, 2)!=_WinIdYes) then
    RETURN;

  APPOFF();
  TRANSON;

  vTxt # TextOpen(20);
  FOR Erx # RecLink(702, 700, 4, _RecLast)    // Positionen RÜCKWÄRTS nach LEVEL loopen...
  LOOP Erx # RecLink(702, 700, 4, _RecPrev)
  WHILE (Erx<=_rLocked) and (vErr=false) do begin

    // LFS merken...    seit 07.08.2019
    if (BA1_P_Data:DarfLfsHaben(BAG.P.Aktion)) then begin
      FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
      LOOP Erx # RecLink(440,702,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        TextAddLine(vTxt, aint(Lfs.Nummer));
      END;
    end;

    if (_DeleteAllInput()=false) then begin
      vErr # true;
      BREAK;
    end;

    if (_DeletePos()=false) then begin
      vErr # true;
      BREAK;
    end;

  END;

  if (vErr) then begin
    TextClose(vTxt);
    TRANSBRK;
    APPON();
    ErrorOutput;
    RETURN;
  end;

  // ggf. LFS löschen, wenn diese keine Pos. mehr tragen
  FOR vA # TextLineRead(vTxt, 1, _TextLineDelete)
  LOOP vA # TextLineRead(vTxt, 1, _TextLineDelete)
  WHILE (vA<>'') do begin
    Lfs.Nummer # cnvia(vA);
    Erx # RecRead(440,1,0);
    if (Erx<=_rLocked) and ("Lfs.Löschmarker"='') then begin
      if (RecLinkInfo(441,440,4,_recCount)=0) then begin
        RecRead(440,1,_recLock);
        "Lfs.Löschmarker" # '*';
        RekReplace(440,_recUnlock,'MAN');
      end;
    end;
  END;

  TextClose(vTxt);

  TRANSOFF;
  APPON();

  Msg(999998,'',0,0,0);

end;


//========================================================================