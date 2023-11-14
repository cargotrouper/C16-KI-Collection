@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Kosten
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  07.03.2008  ST  Kostenstellenberechnung hinzugefügt
//  13.08.2009  ST  Kostenträgercheck bei geplanten Schrottfertigungen hinzugefügt Projekt 1161/95
//  15.10.2009  AI  Restkarten bekommen NIEMALS Produktionskosten
//  24.02.2010  AI  Vorgängerkosten an alle Nachfolgerkarten
//  10.03.2010  AI  Korrektur bei mehreren Fertigungen
//  01.06.2010  AI  Funktionen zum nachträglichen Schrotterlös
//  21.09.2010  AI  Datum der fürhesten Fertigmeldung ist Kostenzeitpunkt
//  23.11.2010  AI  HoleVorganegerKosten
//  24.01.2011  AI  NEU: LoescheVorgangerKosten
//  02.01.2012  AI  Meterberechnung bei Kosten
//  06.03.2012  AI  Verwiegungen auf Ferigungen 999 werden NICHZ zur Kostenberechnung angezogen
//  02.05.2012  AI  Setting Set.BA.Lohnkost.wie (Prj. 1347/81 + 83)
//  13.12.2012  AI  "LoescheVorgaengerKosten" entfernt auch Beistellungsaktionen
//  08.01.2013  AI  Schrottnullung auf Basis-EK
//  11.04.2013  AI  MatMEH
//  01.10.2013  AH  Bug: Kosten der Position wurden nicht in die Rest/Schrottkarte addiert und somit nicht ungelegt
//  08.05.2014  AH  Fixkosten werden auch OHNE PEH/MEH berechnet
//  04.06.2014  AH  BugFix: Fixkosten werden auch OHNE PEH/MEH berechnet
//  28.11.2014  AH  Einsatzkarten mit Durchscnitts-EK wird ein fester EK vergeben
//  13.07.2015  AH  Kompatibel zu FARHEN gemacht
//  11.01.2016  AH  Edit: "BA-UM" werden zum Abschlusdsatum eingetragen
//  11.05.2016  AH  Bug: Schrottumlage beinhaltete Lohnkosten (siehe 01.10.2015)
//  23.08.2016  AH  Einbau von aDiffText
//  08.03.2017  AH  Bug: Beim nicht erfolgreichen Speichern von Sätzen, wurde nicht zwingend abgebrochen
//  17.03.2017  AH  Parameter: aNoTrans
//  22.03.2021  AH  Schrottverkauf wird in MatAkt weiter vererbt
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB KillAllMatAktionen(aTyp : alpha; aNr : int; aPos : int; aPos2 : int; aDiffTxt  : int) : logic;
//    sub NeueAktion(aMatNr  : int;aAkt    : alpha; aBemerk : alpha; aPreis  : float;   aBasis  : float;  aAdr : int; aDatum : date; aDiffTxt : int ) : logic;
//    sub AnWeiterbearbeitungen(aPos : int; aAkt : alpha; aBem1 : alpha; aBem2 : alpha; aPreis : float; aAdr : int; aNurID : int; aDiffTxt  : int ) : logic;
//    sub _Inner(aPos : int; aAkt : alpha; aBem1 : alpha; aBem2 : alpha; aWert : float; aAdr : int; aNurID : int; aDiffTxt  : int) : logic
//    sub Pos2Fert(aPos : int; aAG : alpha; aAdr : int; aDiffTxt : int) : logic
//
//    SUB UpdatePosition(aBAG : int; aPos : int; opt aSilent : logic; opt aNoProto : logic; opt aDiffTxt : int; opt aNoTrans : logic) : logic;
//
//    SUB HoleVorgaengerKosten
//    SUB LoescheVorgaengerKosten() : logic;
//
//
//    sub FindeBAzuRestkarte(aMatNr : int) : logic;
//    sub SumKTGewichtFuerSchrott(aMatNr : int; var aKTGew  : float) : logic;
//    sub ErzeugeSondererloes(aMatNr : int; aPreis : float; aBem : alpha; aDiffTxt : int) : logic;
//
//    SUB SchrottErloes(aWert : float; opt aDiffTxt : int) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_aktionen
@I:Def_BAG

//@Define PROTOKOLL

define begin
  mydebug(a)  : debug(StrChar(32,Gv.Int.01*3)+a)
  //: TextAddLine(vProtokoll, a)//debug(StrChar(32,Gv.Int.01*3)+a)
  cVerschrotteBasis : true
  //true
  plus        : inc(gv.int.01)
  minus       : dec(gv.int.01)
  myWinclose(a) : begin if(aSilent = false) then begin Winclose(a); if (vMDI->wpcustom<>'') and (vMDI->wpcustom<>cnvai(VarInfo(WindowBonus))) then    VarInstance(WindowBonus,cnvIA(vMDI->wpcustom)); end; end
  c_Akt_BA_UmlageSchrottErloes    : 'SCHVK'
end;

declare Pos2Fert(aPos : int; aAG : alpha; aAdr : int; aDiffTxt : int) : logic

declare _Inner(  aPos      : int;
  aAkt      : alpha;
  aBem1     : alpha;
  aBem2     : alpha;
  aWert     : float;
  aAdr      : int;
  aNurID    : int;
  aDiffTxt  : int) : logic

local begin
  vAnteilKosten   : float;
  vAnteilSchrott  : float;
  vAnteilBeistell : float;
  gDatum          : date;
  vProtokoll      : int;
end;


//========================================================================
//  KillAllMatAktionen
//
//========================================================================
sub KillAllMatAktionen(
  aTyp      : alpha;
  aNr       : int;
  aPos      : int;
  aPos2     : int;
  aDiffTxt  : int): logic;
local begin
  Erx     : int;
  vTree   : int;
  vItem   : int;
  vOK     : logic;
end;
begin

  vTree # CteOpen(_CteTreeCI);

//debug('killen von: '+atyp+aint(aNr)+'/'+aint(apos));
  REPEAT
    RecBufClear(204);
    Mat.A.Aktionstyp  # aTyp;
    Mat.A.Aktionsnr   # aNr;
    if (aPos>=0) then Mat.A.Aktionspos  # aPos;
    if (aPos2>=0)then Mat.A.Aktionspos2 # aPos2;
    Erx # RecRead(204,2,0);
    if (Erx<>_rNoRec) and
      (Mat.A.Aktionstyp=aTyp) and
      (Mat.A.Aktionsnr=aNr) and
      ((Mat.A.Aktionspos=aPos) or (aPos=-1)) and
      ((Mat.A.Aktionspos2=aPos2) or (aPos2=-1)) then begin

      Erx # RecLink(200,204,1,_RecFirst);   // Material holen
      if (Erx<=_rLocked) then begin
//debug('kill:'+aint(mat.nummer)+' '+Mat.a.aktionstyp+'/'+aint(mat.a.aktionsnr)+'/'+aint(mat.a.aktionspos)+' '+mat.a.bemerkung);
        Erx # RekDelete(204,0,'AUTO');
        if (erx<>_rOK) then begin
          vTree->Cteclear(y);
          vTree->CteClose();
          RETURN false;
        end;

        vItem # CteOpen(_CteItem);
        vItem->spID     # Mat.Nummer;
        vItem->spCustom # '';
        vItem->spName   # cnvai(Mat.Nummer);
        vTree->CteInsert(vItem);
        //xxxif (Mat_A_Data:Vererben()=false) then RETURN false;

        Erx # RecRead(204,3,0);
        CYCLE;
      end;

      // sonst Ablage...
      Erx # RecLink(210,204,4,_RecFirst);  // Materialablage holen
      if (Erx>_rLockeD) then begin
        vTree->Cteclear(y);
        vTree->CteClose();
        RETURN false;
      end;

      Erx # RekDelete(204,0,'AUTO');
      if (Erx<>_rOK) then begin
        vTree->Cteclear(y);
        vTree->CteClose();
        RETURN false;
      end;

      vItem # CteOpen(_CteItem);
      vItem->spID     # "Mat~Nummer";
      vItem->spCustom # '';
      vItem->spName   # cnvai("Mat~Nummer");
      vTree->CteInsert(vItem);
      //xxxif (Mat_A_Data:Vererben()=false) then RETURN false;

      Erx # RecRead(204,3,0);
      CYCLE;
    end;

  UNTIL (1=1);


  vItem # vTree->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin

    Erx # Mat_Data:Read(vItem->spId);
    if (Erx=200) then begin
      vOK # Mat_A_Data:Vererben('', 200, aDiffTxt);
    end
    else if (Erx=210) then begin
      vOK # Mat_A_Data:Vererben('', 210, aDiffTxt);
//      vOK # Mat_A_Abl_Data:Abl_Vererben();
    end;

    if (vOK=false) then begin
      vTree->Cteclear(y);
      vTree->CteClose();
      RETURN false;
    end;
    vItem # vTree->CteRead(_Ctenext, vItem);
  END;

  vTree->Cteclear(y);
  vTree->CteClose();

  RETURN true;
end;


//========================================================================
//  KillAllAbwertungen
//
//========================================================================
sub KillAllAbwertungen(
  aTyp      : alpha;
  aNr       : int;
  aPos      : int;
  aPos2     : int;
  aDiffTxt  : int): logic;
local begin
  Erx     : int;
  vTree   : int;
  vItem   : int;
  vOK     : logic;
end;
begin

  vTree # CteOpen(_CteTreeCI);

//debug('killen von Abwertung: '+atyp+aint(aNr)+'/'+aint(apos));
  REPEAT

    RecBufClear(202);
    "Mat.B.Trägertyp"     # aTyp;
    "Mat.B.Trägernummer1" # aNr;
    if (aPos>=0) then   "Mat.B.Trägernummer2" # aPos;
    if (aPos2>=0) then  "Mat.B.Trägernummer3" # aPos2;
    Erx # RecRead(202,3,0);
//debug('ist: '+"Mat.B.Trägertyp"+aint("Mat.B.Trägernummer1")+'/'+aint("Mat.B.Trägernummer2")+'/'+aint("Mat.B.Trägernummer3"));
    if (Erx<>_rNoRec) and
      ("Mat.B.Trägertyp"=aTyp) and
      ("Mat.B.Trägernummer1"=aNr) and
      (("Mat.B.Trägernummer2"=aPos) or (aPos=-1)) and
      (("Mat.B.Trägernummer3"=aPos2) or (aPos2=-1)) then begin
      Erx # RecLink(200,202,1,_RecFirst);   // Material holen
      if (Erx<=_rLocked) then begin
//debug('kill:'+aint(mat.nummer)+' '+Mat.a.aktionstyp+'/'+aint(mat.a.aktionsnr)+'/'+aint(mat.a.aktionspos)+' '+mat.a.bemerkung);

        if (StrCut(Mat.B.Bemerkung,1,1)<>'>') then begin  // 16.07.2015 nur wenn keine Folge-Abwertung
          RecRead(200,1,_recLock);
          Mat.EK.Preis        # Mat.EK.Preis - Mat.B.PreisW1;
//  if (Mat.ek.preis=0.0) then debugx('KEY200 BAM NULL');
          Mat.EK.PreisProMEH  # 0.0;
          Erx # Mat_Data:Replace(_recUnlock,'AUTO');
          if (Erx<>_rOK) then begin
            RecRead(200,1,_recUnlock);
            vTree->Cteclear(y);
            vTree->CteClose();
            RETURN false;
          end;
        end;

        Erx # RekDelete(202,0,'AUTO');
        if (Erx<>_rOK) then begin
          vTree->Cteclear(y);
          vTree->CteClose();
          RETURN false;
        end;

        vItem # CteOpen(_CteItem);
        vItem->spID     # Mat.Nummer;
        vItem->spCustom # '';
        vItem->spName   # cnvai(Mat.Nummer);
        vTree->CteInsert(vItem);
        //xxxif (Mat_A_Data:Vererben()=false) then RETURN false;

        Erx # RecRead(202,3,0);
        CYCLE;
      end;

      // sonst Ablage...
      Erx # RecLink(210,202,2,_RecFirst);  // Materialablage holen
      if (Erx>_rLockeD) then begin
        vTree->Cteclear(y);
        vTree->CteClose();
        RETURN false;
      end;

      RecRead(210,1,_recLock);
      "Mat~EK.Preis" # "Mat~EK.Preis" - Mat.B.PreisW1;
      Erx # Mat_Abl_Data:ReplaceAblage(_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        RecRead(210,1,_recUnlock);
        vTree->Cteclear(y);
        vTree->CteClose();
        RETURN false;
      end;

      Erx # RekDelete(202,0,'AUTO');
      if (erx<>_rOK) then begin
        vTree->Cteclear(y);
        vTree->CteClose();
        RETURN false;
      end;

      vItem # CteOpen(_CteItem);
      vItem->spID     # "Mat~Nummer";
      vItem->spCustom # '';
      vItem->spName   # cnvai("Mat~Nummer");
      vTree->CteInsert(vItem);
      //xxxif (Mat_A_Data:Vererben()=false) then RETURN false;

      Erx # RecRead(202,3,0);
      CYCLE;
    end;

  UNTIL (1=1);


  vItem # vTree->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin

    Erx # Mat_Data:Read(vItem->spId);
    if (Erx=200) then begin
      vOK # Mat_A_Data:Vererben('', 200, aDiffTxt);
    end
    else if (Erx=210) then begin
//      vOK # Mat_A_Abl_Data:Abl_Vererben();
      vOK # Mat_A_Data:Vererben('', 210, aDiffTxt);
    end;

    if (vOK=false) then begin
      vTree->Cteclear(y);
      vTree->CteClose();
      RETURN false;
    end;

    vItem # vTree->CteRead(_Ctenext, vItem);
  END;

  vTree->Cteclear(y);
  vTree->CteClose();

  RETURN true;
end;


//========================================================================
//  NeueAktion
//
//========================================================================
sub NeueAktion(
  aPos    : int;
  aMatNr  : int;
  aAkt    : alpha;
  aBemerk : alpha;
  aPreis  : float;
  aBasis  : float;
  aBproM  : float;
  aAdr    : int;
  aDatum  : date;
  aDiffTxt : int) : logic;
local begin
  Erx     : int;
  vBuf702 : int;
  vDatei  : int;
  v200    : int;
end;
begin

@ifdef PROTOKOLL
mydebug(aint(aMatNr)+' '+aAkt+' '+aBemerk+'  für pos '+aint(aPos));
@endif

  vDatei # Mat_Data:Read(aMatNr);
  if (vDatei<200) then RETURN false;


  vBuf702 # RecBufCreate(702);
  RecbufCopy(702,vBuf702);
  if (BAG.P.position<>aPos) then begin
    vBuf702->BAG.P.Position # aPos;
    RecRead(vBuf702,1,0);
  end;

  RecBufClear(204);
  Mat.A.Materialnr    # Mat.Nummer;
  Mat.A.Aktionsmat    # Mat.Nummer;
  Mat.A.Aktionstyp    # aAkt;
  Mat.A.Aktionsnr     # vBuf702->BAG.P.Nummer;
  Mat.A.Aktionspos    # vBuf702->BAG.P.Position;
  Mat.A.Bemerkung     # aBemerk;
  Mat.A.Aktionsdatum  # aDatum; //vBuf702->BAG.P.Fertig.Dat;
  Mat.A.Terminstart   # vBuf702->BAG.P.Plan.StartDat;
  Mat.A.Terminende    # vBuf702->BAG.P.Plan.EndDat;
  Mat.A.Adressnr      # aAdr;
  Mat.A.KostenW1      # aPreis;
// 16.07.2015  Mat.A.Kosten2W1     # aBasis;

  Erx # RecRead(204,4,_recTest);
  if (Erx<=_rMultikey) then begin
    RecBufDestroy(vBuf702);
    RETURN true;
  end;



  // Kostenstelle ermitteln
  if (Bag.P.ExternYN) then begin
    // Bei externen Bearbeitungen Kostenstelle aus dem Arbeitsgang holen

    Erx # RecLink(828,vBuf702,8,0);
    if (Erx = _rOK) then
      Mat.A.Kostenstelle # ArG.Kostenstelle;
  end
  else begin
    // Bei internen Bearbeitungen Kostenstelle aus Resource lesen,
    // sollte dies nicht erfolgreich oder 0 sein, dann die Kst aus
    // dem Arbeitsgang lesen

    // Resource lesen
    Erx # RecLink(160,vBuf702,11,0);
    if ((Erx <= _rLocked) AND (Rso.Kostenstelle > 0)) then begin
      Mat.A.Kostenstelle  # Rso.Kostenstelle;
    end
    else begin
      // Lesen aus Arbeitsgang
      Erx # RecLink(828,vBuf702,8,0);
      if (Erx <= _rLocked) then
        Mat.A.Kostenstelle # ArG.Kostenstelle;
    end;
  end;


  if (vDatei=200) then begin
    Mat_A_data:Insert(0,'AUTO')
    if (vProtokoll<>0) then TextAddLine(vProtokoll,'Material '+aint(mat.nummer)+' erhält Kosten '+aAkt+' '+aBemerk);

    if (Mat_A_Data:Vererben('', 200, aDiffTxt)=false) then begin
      RecBufDestroy(vBuf702);
      RETURN false;
    end;
  end
  else begin
    Mat_A_Data:Insert(0,'AUTO')
//    if (Mat_A_Abl_Data:Abl_Vererben()=false) then begin
    if (Mat_A_Data:Vererben('', 210, aDiffTxt)=false) then begin
      RecBufDestroy(vBuf702);
      RETURN false;
    end;
  end;


  // 08.01.2013 AI:
  if (aBasis<>0.0) then begin
    RecRead(vDatei,1,_recLock);
    if (vDatei=200) then begin
      Mat.EK.Preis          # Mat.EK.Preis + aBasis;
      Mat.EK.PreisProMEH    # 0.0;
    end
    else begin
      "Mat~EK.Preis"        # "Mat~EK.Preis" + aBasis;
      "Mat~EK.PreisProMEH"  # 0.0;
    end;
//      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    Erx # RekReplace(vDatei,_RecUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      RecRead(vDatei,1,_recUnlock);
      RecBufDestroy(vBuf702);
      RETURN false;
    end;
    if (vDatei=210) then RecBufCopy(210,200);

    // Eintrag in Bestandbuch anlegen...
    Mat_Data:Bestandsbuch(0, 0.0, 0.0, aBasis, aBproM, aBemerk, aDatum, 0:0, aAkt, vBuf702->BAG.P.Nummer, vBuf702->BAG.P.Position,0,0, y);
//debug('KEY200 neue abwertung: '+anum(aBasis,2)+'    '+"Mat.B.Trägertyp"+aint("Mat.B.Trägernummer1")+'/'+aint("Mat.B.Trägernummer2")+'/'+aint("Mat.B.Trägernummer3"));

    // vererben...
    if (Mat_Data:VererbeNeubewertung(aBasis, aBproM, aBemerk, aDatum, 0:0, y, aAkt, vBuf702->BAG.P.Nummer, vBuf702->BAG.P.Position,0,0)=false) then begin
      RecBufDestroy(vBuf702);
      RETURN false;
    end;
  end;


//if (Mat.A.KostenW1>0.0) then
//mydebug('neue Akt:'+aint(mat.nummer)+' '+Mat.a.aktionstyp+' '+mat.a.bemerkung+'  für pos '+aint(vBuf702->bag.p.position));

  RecBufDestroy(vBuf702);
  RETURN true;
end;


//========================================================================
//  AnWeiterbearbietungen
//
//========================================================================
sub AnWeiterbearbeitungen(
  aPos    : int;
  aAkt    : alpha;
  aBem1   : alpha;
  aBem2   : alpha;
  aPreis  : float;
  aAdr    : int;
  aNurID  : int;
  aDiffTxt  : int) : logic;
local begin
  Erx       : int;
  vBuf702   : int;
  vBuf701   : int;
end;
begin
@ifdef PROTOKOLL
mydebug('Fert '+aint(bag.F.position)+'/'+aint(bag.f.fertigung)+'   nurID:'+aint(aNurID));
plus;
@endif

  vBuf701 # RekSave(701);

  Erx # RecLink(701,703,4,_recFirst);         // Fert->Output loopen
  WHILE (Erx<=_rLocked) do begin

    if ((BAG.IO.VonID=aNurID) or (aNurID=0)) and
      (BAG.IO.Materialnr<>0) and
      (BAg.IO.BruderID<>0) then begin
//mydebug('id:'+aint(bag.io.id));

      vBuf702 # RekSave(702);
      BAG.P.Position # aPos;
      Erx # RecRead(702,1,0);
      if (Erx<>_rOK) then todo('Interner Fehler 741');
      if (BAG.P.Aktion<>c_BAG_VSB) and (BAG.P.Aktion<>c_BAG_VERSAND) then begin
        if (NeueAktion(aPos, BAG.IO.Materialnr, aAkt, aBem1+':'+aBem2, aPreis, 0.0, 0.0, aAdr, gDatum, aDiffTxt)=false) then begin
          RekRestore(vBuf702);
          RETURN false;
        end;

        if (BAG.IO.NachPosition<>0) and (BAG.IO.NachPosition<>BAG.F.Position) then begin
          Erx # RecLink(702,701,4,_RecFirst);   // nachPos holen
          if (Erx<>_rOK) then TODO('Interner Fehler 2212');
          if (_Inner(aPos, aAkt, aBem1, aBem2, aPreis, aAdr, BAG.IO.ID, aDiffTxt)=faLse) then begin
            RETURN false;
          end;
        end;
      end;

      RekRestore(vBuf702);
    end;

    Erx # RecLink(701,703,4,_recNext);
  END;

  RekRestore(vBuf701);

@ifdef PROTOKOLL
minus;
mydebug('<Fert '+aint(bag.F.position)+'/'+aint(bag.f.fertigung));
@endif

  RETURN true;
end;


//========================================================================
//  _Inner
//
//========================================================================
sub _Inner(
  aPos      : int;
  aAkt      : alpha;
  aBem1     : alpha;
  aBem2     : alpha;
  aWert     : float;
  aAdr      : int;
  aNurID    : int;
  aDiffTxt  : int) : logic
local begin
  Erx     : int;
  vBuf703 : int;
  vBuf702 : int;
  vBuf701 : int;
end;
begin

@ifdef PROTOKOLL
mydebug('Inner '+aint(bag.P.position));
plus;
@endif

  vBuf703 # RekSave(703);

  Erx # RecLink(703,702,4,_recFirst);           // Fertigungen loopen
  WHILE (Erx<=_rLocked) do begin
    if (AnWeiterbearbeitungen(aPos, aAkt, aBem1, aBem2, aWert, aAdr, aNurID, aDiffTxt)=false) then begin
      RETURN false;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;

  RekRestore(vBuf703);

  RETURN true;

@ifdef PROTOKOLL
minus;
mydebug('<inner '+aint(bag.P.position));
@endif

end;


//========================================================================
//  Pos2Fert
//
//========================================================================
sub Pos2Fert(
  aPos      : int;
  aAG       : alpha;
  aAdr      : int;
  aDiffTxt  : int) : logic
local begin
  Erx     : int;
  vBuf703 : int;
  vBuf702 : int;
  vBuf701 : int;
end;
begin

  vBuf703 # RekSave(703);

  Erx # RecLink(703,702,4,_recFirst);           // Fertigungen loopen
  WHILE (Erx<=_rLocked) do begin

    if ("BAG.F.KostenträgerYN"=n) then begin    //  kein Träger?
      Erx # RecLink(703,702,4,_recNext);
      CYCLE;
    end;
/** ??? 16.06.2014
    if (BAG.FM.Materialtyp<>c_IO_Mat) or (BAG.FM.Materialnr=0) or
      (BAG.FM.Status=798) then begin    // Material??
      Erx # RecLink(703,702,4,_recNext);
      CYCLE;
    end;
***/
    // Umlage eintragen

    if (vAnteilSchrott<>0.0) then begin
@ifdef PROTOKOLL
gv.int.01 # 0;
mydebug('schorttumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (AnWeiterbearbeitungen(aPos, c_Akt_BA_UmlagePLUS, c_AktBem_BA_Umlage, aAG, vAnteilSchrott, aAdr, 0, aDiffTxt)=false) then begin
        RETURN false;
      end;
    end;
//debug('..............................................');

    // Kosten eintragen
    if (vAnteilKosten<>0.0) then begin
@ifdef PROTOKOLL
mydebug('Kostenumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (AnWeiterbearbeitungen(aPos, c_Akt_BA_Kosten, c_AktBem_BA_Kosten, aAG, vAnteilKosten, aAdr, 0, aDiffTxt)=false) then begin
        RETURN false;
      end;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;

  RekRestore(vBuf703);
  RETURN true;
end;


//========================================================================
//  UpdatePosition
//
//  FAHREN darf so NICHT die Kosten berechnen(bzw. Abwertungen vom Schrott vornehmen), WENN es das 1. Fahren im BA ist,
//  da dann dirkete Kinder des Fahr-Einsatzmaterials existieren
//  (Fahren leigt nicht wie Spalten etc. schon eine Restkarte "zum Fahren" an)
//  Würde man dann in dieser die Abwertung machen, würde sie auf alle Kinder vererbt werden => FALSCH
//  Wird das Fahren "später" in BA gemacht, klappt das aber.
//  Beim Spalten etc. finden die Abwertungen im "Reststrang" statt
//========================================================================
sub UpdatePosition(
  aBAG            : int;
  aPos            : int;
  opt aSilent     : logic;
  opt aNoProto    : logic;
  opt aRecalc     : logic;
  opt aDiffTxt    : int;
  opt aNoTrans    : logic) : logic;
local begin
  Erx           : int;
  vBeistellSum  : float;

  vKostenSum    : float;
  vEinsatz      : float;
  vFertigGew    : float;
  vTraegerGew   : float;

  vSchrottWert  : float;
  vSchrottGew   : float;

  vAdr          : int;
  vBuf100       : int;

  vPreis        : float;
  vBasis        : float;
  vBproM        : float;
  vI            : int;

  vFlag         : int;
  vKtraeg       : logic;
  vSchrottFert  : logic;

  vVorKosten    : float;

  vDia          : int;
  vMsg          : int;

  vMDI          : int;
  vDatei        : int;
  vOK           : logic;
  vA            : alpha;

  vAbschlussam  : date;
end;
begin

// 13.04.2017 AH:
// NEU NEU NEU NEU
// NEU NEU NEU NEU
// NEU NEU NEU NEU
  RETURN BA1_Kosten2:UpdatePosition(aBAG, aPos, aSilent, aNoProto, aRecalc, aDiffTxt, aNoTrans);
// NEU NEU NEU NEU
// NEU NEU NEU NEU
// NEU NEU NEU NEU


// BCS- intern??
//if (DbaLicense(_DbaSrvLicense)='CD152667MN/H') then begin
//  RETURN BA1_Kosten2:UpdatePosition(aBAG, aPos, aSilent, aNoProto, aRecalc, aDiffTxt, aNoTrans);
//end;


  // Settings prüfen
  if (Set.Ba.lohnKost.Wie<>'G') and (Set.Ba.lohnKost.Wie<>'K') then RETURN false;

  // Ankerfunktion starten
  if (aSilent) then
    vA # aint(aBAG)+'|'+aint(aPos)+'|Y'
  else
    vA # aint(aBAG)+'|'+aint(aPos)+'|N';
  if (RunAFX('BAG.Kosten',vA)<>0) then begin
    RETURN (AfxRes=_rOK);
  end;

//if (aPos<>2) then RETURN true;

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (Erx<>_rOK) then RETURN false;
  if (BAG.P.Aktion=c_BAG_VSB) then RETURN true;
  if (BAG.P.Aktion=c_BAG_VERSAND) then RETURN true;

  vAbschlussAm # BAG.P.Fertig.Dat;
  // LOHN???

  // ST 2009-08-13  Projekt: 1161/95
  // Kostenträgercheck
  // Falls geplante Schrottfertigungen eingetragen sind,
  // muss mindestens eine Kostenträgerfertigung vorhanden sein
  begin
    vKtraeg      # false;
    vSchrottFert # false;
    vFlag #  _recFirst;
    WHILE (RecLink(703,702,4,vFlag) <= _rLocked) DO BEGIN
      vFlag # _RecNext;

      if ("BAG.F.KostenträgerYN") then
        vKtraeg # true;

      if (BAG.F.PlanSchrottYN) then
        vSchrottFert # true;
    END;

    if (vSchrottFert) AND (!vKtraeg) then begin
      Error(702026,'');
      RETURN false; // FEHLER!!!!
    end;
  end; // Kostenträgercheck

  // Dienstleister holen
  if (BAG.P.ExternYN) then begin
    vBuf100 # RekSave(100);
    RecLink(100,702,7,_recFirst);
    vAdr # Adr.Nummer;
    RekRestore(vBuf100);
  end;

  if (aSilent = false) then begin
    vMDI # gMDI;
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
    vMsg # Winsearch(vDia,'Progress');
    vMsg->wpvisible # false;
    vMsg # Winsearch(vDia,'Bt.Abbruch');
    vMsg->wpvisible # false;
    vMsg # Winsearch(vDia,'Label1');
    vMsg->wpcaption # Translate('Berechne Position')+' '+aint(Bag.P.Position)+'...';
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter, vMDI);
  end;

  // ALFA???
//  if (DbaLicense(_DbaSrvLicense)='CE101437MU') then begin
//    vProtokoll # TextOpen(20);
//    TextAddLine(vProtokoll,'START KOSTENLAUF FÜR BA '+aint(BAG.P.Nummer)+'/'+aint(Bag.P.Position));
//  end;


  BAG.P.Kosten.Gesamt   # 0.0;
  BAG.P.Kosten.Ges.Stk  # 0;
  BAG.P.Kosten.Ges.Gew  # 0.0;
  BAG.P.Kosten.Ges.Men  # 0.0;
  BAG.P.Kosten.Ges.MEH  # '';
@ifdef PROTOKOLL
mydebug('POS '+aint(bag.p.position)+' -----------------------------------------------------------');
@endif

  // Jüngste Fertigmeldung ermitteln ---------------------------------------
  Erx # RecLink(707,702,5,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (gDatum=0.0.0) then gDatum # BAG.FM.Datum;
    if (gDatum>BAG.FM.Datum) then gDatum # BAG.FM.Datum;
    Erx # RecLink(707,702,5,_recNext);
  END;
  if (gDatum=0.0.0) then gDatum # today;
//debugx(cnvad(gdatum));

  // Einsatz summieren + Lohnkosten errechnen ------------------------------
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Aktion=c_BAG_Fahr09) then begin
      BAG.IO.Plan.Out.GewN # BAG.IO.Ist.Out.GewN;
      BAG.IO.Plan.Out.GewB # BAG.IO.Ist.Out.GewB;
      BAG.IO.Plan.Out.Stk  # BAG.IO.Ist.Out.Stk;
      if (BAG.IO.MEH.In=BAG.IO.MEH.Out) then
        BAG.IO.Plan.Out.Meng # BAG.IO.Ist.Out.Menge;
    end;

    if (BAG.IO.Materialtyp=c_IO_Beistell) then begin    // Beistell-Artikel?
      vBeistellSum # vBeistellSum + BAG.IO.GesamtKostW1;
    end;

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin    // Material??

      // Setting: Kompletten Einsatz
      if (Set.Ba.lohnKost.Wie='K') then begin

        Erx # Mat_Data:read(BAG.IO.MaterialRstNr);
        If (Erx<200) then begin
          MyWinClose(vDia);
          if (vProtokoll<>0) then TextCLose(vProtokoll);
          RETURN false;
        end;

        if (BAG.P.Kosten.MEH='m') then begin
          vEinsatz # vEinsatz + cnvfi(BAG.IO.Plan.Out.Stk) * "BAG.IO.Länge" / 1000.0;
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.IO.Plan.Out.GewN;
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + BAG.IO.Plan.Out.Stk;
        end;
        if (BAG.P.Kosten.MEH='Stk') then begin
          vEinsatz # vEinsatz + cnvfi(BAG.IO.Plan.Out.Stk);//cnvfi(BAG.IO.Plan.In.Stk);
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + BAG.IO.Plan.Out.Stk;//BAG.IO.Plan.In.Stk;
        end;
        if (BAG.P.Kosten.MEH='kg') then begin
          vEinsatz # vEinsatz + BAG.IO.Plan.Out.GewN;//BAG.IO.Plan.In.GewB;
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.IO.Plan.Out.GewN;//BAG.IO.Plan.In.GewB;
        end;
        if (BAG.P.Kosten.MEH='t') then begin
          vEinsatz # vEinsatz + (BAG.IO.Plan.Out.GewN / 1000.0);//(BAG.IO.Plan.In.GewB / 1000.0);
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.IO.Plan.Out.GewN;//BAG.IO.Plan.In.GewB;
        end;
@ifdef PROTOKOLL
mydebug('Planin '+ANum(BAG.IO.Plan.In.GewN,0)+'   Istin '+ANum(BAG.IO.Ist.In.GewN,0)+'   PlanOut '+ANum(BAG.IO.Plan.Out.GewN,0)+'   IstOut '+ANum(BAG.IO.Ist.Out.GewN,0));
mydebug('addKarte:'+aint(mat.nummer));
@endif
      end // Setting: kompletten Einsatz
      // Setting: nur Gutteile
      else if (Set.Ba.lohnKost.Wie='G') then begin

        FOR Erx # RecLink(707,701,12,_recFirst) // Verwiegungen loopen
        LOOP Erx # RecLink(707,701,12,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (BAG.FM.Fertigung>900) then CYCLE;
          if (BAG.FM.Gewicht.Netto=0.0) then BAG.FM.Gewicht.Netto # BAg.FM.Gewicht.Brutt;
          if (BAG.FM.MEH=BAG.P.kosten.MEH) then begin
            vEinsatz # vEinsatz + BAG.FM.Menge;
          end
          else if (BAG.P.Kosten.MEH='m') then begin
            vEinsatz # vEinsatz + cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" / 1000.0;
          end
          else if (BAG.P.Kosten.MEH='qm') then begin
            vEinsatz # vEinsatz + cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" * BAG.FM.Breite / 1000000.0;
          end
          else if (BAG.P.Kosten.MEH='Stk') then begin
            vEinsatz # vEinsatz + cnvfi("BAG.FM.Stück");
          end
          else if (BAG.P.Kosten.MEH='kg') then begin
            vEinsatz # vEinsatz + BAG.FM.Gewicht.Netto;
          end
          else if (BAG.P.Kosten.MEH='t') then begin
            vEinsatz # vEinsatz + (BAG.FM.Gewicht.Netto / 1000.0);
          end;

          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.FM.Gewicht.Netto;
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + "BAG.FM.Stück";
        END;
      end;  // Setting: nur Gutteile

//todo('B:'+anum(bag.p.kosten.ges.gew,0));
    end;  // Material

  END;

  // 08.05.2014 AH:
  vKostenSum # BAG.P.Kosten.Fix;
  if (BAG.P.Kosten.PEH<>0) then
    vKostenSum # vKostenSum + (BAG.P.Kosten.pro * vEinsatz / cnvfi(BAG.P.Kosten.PEH));

  RecRead(702,1,_recLock | _recNoLoad);       // Position sperren
  BAG.P.Kosten.Gesamt # vKostenSum;
  BA1_P_Data:Replace(_recUnlock,'AUTO');          // Position speichern

@ifdef PROTOKOLL
mydebug('summe gesamt '+aint(bag.p.position)+'  '+anum(bag.p.kosten.ges.gew,0));
@endif
  Lib_Berechnungen:Waehrung_Umrechnen(vKostenSum, BAG.P.Kosten.Wae, var vKostenSum, 1);


  // Fertigmeldungen summieren ---------------------------------------------
  FOR Erx # RecLink(703,702,4,_recFirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    FOR Erx # RecLink(707,703,10,_recFirst)
    LOOP Erx # RecLink(707,703,10,_recNext)
    WHILE (Erx<=_rLocked) do begin

    if (BAG.FM.Materialtyp<>c_IO_Mat) or (BAG.FM.Materialnr=0) or
        (BAG.FM.Status=798) then CYCLE;   // Material??

      vFertigGew # vFertigGew + BAG.FM.Gewicht.Netto;
      if ("BAG.F.KostenträgerYN") then
        vTraegerGew # vTraegerGew + BAG.FM.Gewicht.Netto;
    END;
  END;

  if (vTraegerGew<>0.0) then
    vAnteilKosten   # Rnd(vKostenSum*1000.0 / vTraegerGew ,2);

  if (vTraegerGew<>0.0) then
    //vAnteilBeistell # Rnd(vBeistellSum*1000.0 / vTraegerGew,2);
    vAnteilKosten # vAnteilKosten + Rnd(vBeistellSum*1000.0 / vTraegerGew,2);

  // ST 2009-08-14  Projekt 1161/95
  if (vTraegerGew <= 0.0) AND (vAnteilKosten > 0.0) then begin
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    Error(702026,'');
    RETURN false;
  end;


@ifdef PROTOKOLL
mydebug('traegergew:'+anum(vtraegerGew,0)+'   schrottgew:'+anum(vSchrottGew,0));
mydebug('geskost:'+anum(vKostensum,2) + '    anteil:'+anum(vAnteilKosten,2));
mydebug('killen...');
@endif

  if(aSilent = false) then
    vMsg->wpcaption # Translate('Lösche alte Kosten...');

  if (aNoTrans=false) then TRANSON;

  // bisherige Aktionseinträge löschen -------------------------------------

  // 08.01.2013 AI
  if (KillAllAbwertungen(c_Akt_BA_UmlageMINUS, BAG.P.Nummer, BAG.P.Position, 0, aDiffTxt)<>true) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN false;
  end;

  if (KillAllMatAktionen(c_Akt_BA_Kosten, BAG.P.Nummer, BAG.P.Position, 0, aDiffTxt)<>true) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN false;
  end;
  if (KillAllMatAktionen('BA UM', BAG.P.Nummer, BAG.P.Position, 0, aDiffTxt)<>true) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN false;
  end;
  if (KillAllMatAktionen(c_Akt_BA_UmlagePLUS, BAG.P.Nummer, BAG.P.Position, 0, aDiffTxt)<>true) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN false;
  end;
  if (KillAllMatAktionen(c_Akt_BA_UmlageMINUS, BAG.P.Nummer, BAG.P.Position, 0, aDiffTxt)<>true) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN false;
  end;
  if (KillAllMatAktionen(c_Akt_BA_Beistell, BAG.P.Nummer, BAG.P.Position, 0, aDiffTxt)<>true) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN false;
  end;
@ifdef PROTOKOLL
mydebug('...killen');
@endif

  // BA-Position ist noch offen?? -> dann keine Kosten eintragen
  if ("BAG.P.Löschmarker"='') then begin
//mydebug('NOCH OFFEN -> ENDE');
    if (aNoTrans=false) then TRANSOFF;
    // Einkaufskontrolle durchführen
    Recread(702,1,0);
    if (EKK_Data:Update(702)=false) then begin
      MyWinClose(vDia);
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      RETURN false;
    end;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    RETURN true;
  end;


  // in Restkarten Lohnkosten eintragen ------------------------------------
  if ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09)) or
     ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09)) then begin

    // Schrottwiegungen addieren ---------------------------------------------
    FOR Erx # RecLink(703,702,4,_recFirst)
    LOOP Erx # RecLink(703,702,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.F.PlanSchrottYN=false) then CYCLE;

      FOR Erx # RecLink(707,703,10,_recFirst)
      LOOP Erx # RecLink(707,703,10,_recNext)
      WHILE (Erx<=_rLocked) do begin

        if (BAG.FM.Materialtyp<>c_IO_Mat) or (BAG.FM.Materialnr=0) or
          (BAG.FM.Status=798) then CYCLE;   // Material??


        if (Mat_Data:Read(BAG.FM.Materialnr)>=200) then begin

          if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;

          vSchrottGew   # vSchrottGew + Mat.Bestand.Gew;
          vSchrottWert  # vSchrottwert + (Mat.Bestand.Gew*Mat.EK.Effektiv / 1000.0);
        end;
      END;
    END;


    FOR Erx # RecLink(701,702,2,_recFirst)        // Input loopen
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.IO.Materialtyp<>c_IO_Mat) then CYCLE;   // kein Material??

      Erx # Mat_Data:Read(BAG.IO.MaterialRstNr,0,0,false);//true);
      If (Erx<200) then begin
        if (aNoTrans=false) then TRANSBRK;
        MyWinClose(vDia);
        if (vProtokoll<>0) then TextCLose(vProtokoll);
        RETURN false;
      end;

      if (BAG.IO.Materialnr<>BAG.IO.MaterialRstNr) then begin     // ist bei echtem Einsatz und NICHT Fahren so
        // 28.11.2014:
        if (Erx=200) then begin
          if (Mat_Data:SetAktuellenEKPreis(true)=false) then TODOX('DurchscnittsEK nicht setzbar!');
        end
        else if (Erx=210) then begin
          if (Mat_Abl_Data:SetAktuellenEKPreis(true)=false) then TODOX('DurchscnittsEK nicht setzbar!');
        end;

        // 01.10.2013 AH Kosten DIESER Position auch im Schrott eintragen
        // 11.05.2016 AH: BUG : WAR SCHON EINGERECHNET!!
//          Mat.EK.Effektiv # Mat.EK.Effektiv + vAnteilKosten;
      end;

      if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;

@ifdef PROTOKOLL
mydebug('schrott von Karte:'+aint(mat.nummer)+' '+anum(mat.ek.effektiv,2)+'/t');
@endif
      vSchrottGew   # vSchrottGew + Mat.Bestand.Gew;
      vSchrottWert  # vSchrottwert + (Mat.Bestand.Gew*Mat.EK.Effektiv / 1000.0);

    END;
  end;


  if (vTraegerGew<>0.0) then
    vAnteilSchrott  # Rnd(vSchrottwert*1000.0 / vTraegerGew,2);

@ifdef PROTOKOLL
mydebug('schrottgew:'+anum(vSchrottGew,0)+'   schrottwert:'+anum(vschrottwert,2)+'  anteil:'+anum(vAnteilSchrott,2));
@endif

  // neue Kostenaktionen anlegen -------------------------------------------
  if (vTraegerGew<>0.0) then begin
@ifdef PROTOKOLL
mydebug('umlegen...');
@endif
    if(aSilent = false) then
      vMsg->wpcaption # Translate('Kosten werden umgelegt...');
    if (Pos2Fert(BAG.P.Position, BAG.P.Aktion2, vAdr, aDiffTxt)=false) then begin
      if (aNoTrans=false) then TRANSBRK;
      MyWinClose(vDia);
      ErrorOutput;
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      RETURN false;
    end;
@ifdef PROTOKOLL
mydebug('...umlegen...');
@endif

    // Schrottnullungen ========================================================
  if ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09)) or
     ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09)) then begin

      // Schrottverwiegungen nullen --------------------------------------------
      FOR Erx # RecLink(703,702,4,_recFirst)
      LOOP Erx # RecLink(703,702,4,_recNext)
      WHILE (Erx<=_rLocked) do begin

        if (BAG.F.PlanSchrottYN=false) then CYCLE;

        FOR Erx # RecLink(707,703,10,_recFirst)
        LOOP Erx # RecLink(707,703,10,_recNext)
        WHILE (Erx<=_rLocked) do begin

          if (BAG.FM.Materialtyp<>c_IO_Mat) or (BAG.FM.Materialnr=0) or
            (BAG.FM.Status=798) then CYCLE;    // Material??

          vI # Mat_Data:Read(BAG.FM.Materialnr);
          if (vI>=200) then begin
            // 08.01.2013 AI;
            if (cVerschrotteBasis=false) then begin
              vPreis  # -1.0 * Mat.EK.Effektiv;
            end
            else begin
              vPreis  # -1.0 * Mat.Kosten;
              vBasis  # -1.0 * Mat.EK.Preis;
              vBproM  # -1.0 * Mat.EK.PreisProMEH;
            end;
            if (vPreis<>0.0) or (vBasis<>0.0) then begin
//debugx('BA-Minus bei '+aint(mat.nummer)+' von '+anum(vPreis,2)+'   Preis:'+anum(vPreis,2));
//              if (NeueAktion(BAG.P.Position, Mat.Nummer, c_Akt_BA_UmlageMINUS, c_AktBem_BA_Umlage+':'+BAG.P.Aktion2, vPreis, vBasis, vAdr, gDatum)=false) then begin
// 19.08.2016 AH           if (NeueAktion(BAG.P.Position, Mat.Nummer, c_Akt_BA_UmlageMINUS, c_AktBem_BA_Umlage+':'+BAG.P.Aktion2, vPreis, vBasis, vAdr, vAbschlussAm)=false) then begin
              if (NeueAktion(BAG.P.Position, Mat.Nummer, c_Akt_BA_UmlageMINUS, c_AktBem_BA_Nullung+':'+BAG.P.Aktion2, vPreis, vBasis, vBproM, vAdr, vAbschlussAm, aDiffTxt)=false) then begin
                if (aNoTrans=false) then TRANSBRK;
                MyWinClose(vDia);
                ErrorOutput;
                if (vProtokoll<>0) then TextCLose(vProtokoll);
                RETURN false;
              end;
            end;
            if (vI=200) then begin
              if (Mat_A_Data:Vererben('', 200, aDiffTxt)=false) then begin
                if (aNoTrans=false) then TRANSBRK;
                MyWinClose(vDia);
                ErrorOutput;
                if (vProtokoll<>0) then TextCLose(vProtokoll);
                RETURN false;
              end;
            end;
            if (vI=210) then begin
//             if (Mat_A_Abl_Data:Abl_Vererben()=false) then begin
              if (Mat_A_Data:Vererben('', 210, aDiffTxt)=false) then begin
                if (aNoTrans=false) then TRANSBRK;
                MyWinClose(vDia);
                ErrorOutput;
                if (vProtokoll<>0) then TextCLose(vProtokoll);
                RETURN false;
              end;
            end;

          end;

        END;

      END;
//debug('...umlegen');

//debug('Nullen...');
      // Restkarten "nullen" -------------------------------------------------
      FOR Erx # RecLink(701,702,2,_recFirst)            // Input loopen
      LOOP Erx # RecLink(701,702,2,_recNext)
      WHILE (Erx<=_rLocked) do begin

        if (BAG.IO.Materialtyp=c_IO_Mat) then begin     // Material??

          vDatei # Mat_Data:Read(BAG.IO.MaterialRstNr);
          If (vDatei<200) then begin
            if (aNoTrans=false) then TRANSBRK;
            MyWinClose(vDia);
            Erroroutput;
            if (vProtokoll<>0) then TextCLose(vProtokoll);
            RETURN false;
          end;

          if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;

          // 08.01.2013 AI
          if (cVerschrotteBasis=false) then begin
            vPreis # -1.0 * Mat.EK.Effektiv;
          end
          else begin
            vPreis # -1.0 * Mat.Kosten;
            vBasis # -1.0 * Mat.EK.Preis;
            vBproM # -1.0 * Mat.EK.PreisProMeh;
          end;
          if (vPreis<>0.0) or (vBasis<>0.0) then begin
//debugx('nullen '+aint(mat.nummer)+' von '+anum(vPreis,2)+'   akt:'+anum(mat.kosten,2));
//            if (NeueAktion(BAG.P.Position, BAG.IO.MaterialRstNr, c_Akt_BA_UmlageMINUS, c_AktBem_BA_Umlage+':'+BAG.P.Aktion2, vPreis, vBasis, vAdr, gDatum)=false) then begin
// 19.08.2016 AH            if (NeueAktion(BAG.P.Position, BAG.IO.MaterialRstNr, c_Akt_BA_UmlageMINUS, 'B'+c_AktBem_BA_Umlage+':'+BAG.P.Aktion2, vPreis, vBasis, vAdr, vAbschlussAm)=false) then begin
            if (NeueAktion(BAG.P.Position, BAG.IO.MaterialRstNr, c_Akt_BA_UmlageMINUS, c_AktBem_BA_Nullung+':'+BAG.P.Aktion2, vPreis, vBasis, vBproM, vAdr, vAbschlussAm, aDiffTxt)=false) then begin
              if (aNoTrans=false) then TRANSBRK;
              MyWinClose(vDia);
              if (vProtokoll<>0) then TextCLose(vProtokoll);
              RETURN false;
            end;
          end;

          if (vDatei=200) then
            vOK # Mat_A_Data:Vererben('', 200, aDiffTxt)
          else
            vOK # Mat_A_Data:Vererben('', 210, aDiffTxt);
          if (vOK=false) then begin
            if (aNoTrans=false) then TRANSBRK;
            MyWinClose(vDia);
            ErrorOutput;
            if (vProtokoll<>0) then TextCLose(vProtokoll);
            RETURN false;
          end;

        end;
      END;
//debug('...Nullen');

    end;  // Nullung

  end;  // Träger<>0


  // Pauschalkosten des LFS vererben...
  if (BAG.P.Aktion=c_BAG_Fahr09) then begin
    Erx # RecLink(440,702,14,_recFirst);    // Lieferschein holen
    if (Erx>_rLocked) then begin
      if (aNoTrans=false) then TRANSBRK;
      MyWinClose(vDia);
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      RETURN false;
    end;
    if (aRecalc=false) then
      Lfs_Data:KostenAusLFA();
  end;

  if (aNoTrans=false) then TRANSOFF;

  if (vProtokoll<>0) then TextAddLine(vProtokoll,'[ENDE]');

  MyWinClose(vDia);

  if (vProtokoll<>0) then begin
    TextDelete(myTmpText,0);
    TextWrite(vProtokoll,MyTmpText,0);
    TextClose(vProtokoll);
    if (aNoProto=false) then Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll');
    TextDelete(myTmpText,0);
  end;

//winsleep(2000);
  // Einkaufskontrolle durchführen
  Recread(702,1,0);

  if (EKK_Data:Update(702)=false) then RETURN false;

//odo('einsatz: '+cnvaf(vEinsatz)+'   Fertig:'+cnvaf(vFertigGew)+'  Kostenträger:'+cnvaf(vTraegerGew)+Strchar(13)+' Kosten/t:'+cnvaf(vAnteilKosten)+'  Schrott/t:'+cnvaf(vAnteilSchrott));

  // Alles IO
  RETURN true;
end;


//=======================================================================
//  HoleVorgaengerKosten
//
//=======================================================================
SUB HoleVorgaengerKosten();
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf200 : int;
  vBuf204 : int;
end;
begin

  if (BAG.IO.VonID=0) then RETURN;

  vBuf701 # RekSave(701);

  BAG.IO.Nummer # BAG.FM.InputBAG;
  BAG.IO.ID     # BAG.FM.InputID;
  Erx # RecRead(701,1,0);
  if (Erx>_rLocked) then begin
    RekRestore(vBuf701);
    RETURN;
  end;

  if (BAG.IO.Materialtyp<>c_IO_Mat) then begin
    RekRestore(vBuf701);
    RETURN;
  end;

  vBuf200 # RecBufCreate(200);
  Erx # Mat_Data:Read(BAG.IO.Materialnr,0,vBuf200); // Material holen
  if (Erx<200) then begin
    RekRestore(vBuf701);
    RETURN;
  end;

  Erx # RecLink(204,vBuf200,14,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin

    // 21.05.2021 AH: Manuell immer löschen
    // nur BA-Aktionen vererben...
    if ((Mat.A.Aktionstyp=c_Akt_MAN) or
        ((Mat.A.Aktionstyp=c_Akt_BA_Beistell) or
        (Mat.A.Aktionstyp=c_Akt_BA_Kosten) or
        (Mat.A.Aktionstyp=c_Akt_BA_UmlagePlus)) and
        ((Mat.A.Aktionsnr=BAG.FM.Nummer))) then begin

      vBuf204 # RekSave(204);
//todo('kopiere von '+aint(vBuf200->mat.Nummer)+' nach '+aint(Mat.Nummer)+'  '+mat.a.aktionstyp);
      Mat.A.Materialnr    # Mat.Nummer;
      Mat.A.Aktionsmat    # Mat.Nummer;
      Mat_A_Data:insert(0,'AUTO');
      RekRestore(vBuf204);
    end;

    Erx # RecLink(204,vBuf200,14,_recNext);
  END;
//todo('kopiere von '+aint(mat.Nummer)+' nach '+aint(vBuf200->Mat.Nummer));

  RekRestore(vBuf701);

end;


//=======================================================================
//  LoescheVorgaengerKosten
//
//=======================================================================
SUB LoescheVorgaengerKosten() : logic;
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf200 : int;
end;
begin

  if (BAG.FM.Materialnr=0) then RETURN true;

  Erx # RecLink(200,707,7,_recFirst);   // Material holen
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
    // 13.12.2012 AI
    // 13.12.2012 AI
    if (
        (Mat.A.Aktionstyp=c_Akt_MAN) or
        (
          ((Mat.A.Aktionstyp=c_Akt_BA_Beistell) or (Mat.A.Aktionstyp=c_Akt_BA_Kosten) or (Mat.A.Aktionstyp=c_Akt_BA_UmlagePlus)) and
          (Mat.A.Aktionsnr=BAG.FM.Nummer)
        )
      ) then begin
      RekDelete(204,0,'AUTO');
      Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
      CYCLE;
    end;
    RETURN false;
  END;

  Mat_A_data:Addkosten();

  RETURN true;
end;


//=======================================================================
//=======================================================================
//=======================================================================

//=======================================================================
//  FindeBAzuRestkarte
//
//=======================================================================
sub FindeBAzuRestkarte(aMatNr : int) : logic;
local begin
  Erx   : int;
  vNr   : int;
end;
begin

  if (Mat_data:Read(aMatNr)<200) then RETURN false;
  if ("Mat.Vorgänger"=0) or (Mat.Nummer="Mat.Vorgänger") then RETURN false;

  Mat.Nummer # "Mat.Vorgänger";
  Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Entstanden=aMatNr) then begin
      if (MAt.A.Aktionstyp=c_Akt_BA_Rest) then begin
        vNr # "Mat.Vorgänger";
      end
      else if (Mat.A.Aktionstyp=c_Akt_BA_Fertig) then begin
        vNr # aMatNr;
        BREAK;
      end;
    end;
    Erx # RecLink(204,200,14,_recNext);
  END;

  if (vNr=0) then RETURN false;


//debug('suche von C '+aint(aMatnr));

  Mat.Nummer # vNr;
  Erx # RecLink(701,200,29,_recfirst);
  WHILE (Erx<=_rLocked) do begin        // BA-Input loopen
//debug('found bei '+ aint(vNr));
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      if (BAG.IO.NachBAG=0) then begin
        if (BAG.IO.VonBAG=0) then RETURN false;
        Erx # RecLink(702,701,2,_recFirst);   // VON Pos holen



        RETURN true;
      end;
      Erx # RecLink(702,701,4,_recFirst);   // nach BA-Position holen
      if (BAG.P.Typ.VSBYN) then begin
        Erx # RecLink(702,701,2,_recFirst);   // von BA-Position holen
      end;
      RETURN (Erx=_rOK);
    end;
    Erx # RecLink(701,200,29,_recNext);
  END;

  RETURN false;
//debug('found BA:'+aint(bag.p.nummeR)+'/'+aint(bag.p.position));
end;


//=======================================================================
//  SumGewichtFuerSchrott
//
//=======================================================================
sub SumGewichtFuerSchrott(
  aMatNr      : int;
  var aGew    : float;
  ) : logic;
local begin
  Erx : int;
end;
begin

  if (FindeBAzuRestkarte(aMatNr)=false) then begin
    Msg(99,'KEIN BA gefunden!',0,0,0);
    RETURN false;
  end;

  // Aktionen suchen...
  RecBufClear(204);
  Mat.A.Aktionstyp  # c_Akt_BA_UmlagePLUS;
  Mat.A.Aktionsnr   # BAG.P.Nummer;
  Mat.A.Aktionspos  # BAG.p.position;
  Mat.A.Aktionspos2 # 0;
  Erx # RecRead(204,2,0);
  WHILE (Erx<>_rNoRec) and
    (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) and
    (Mat.A.Aktionsnr=BAG.P.nummer) and
    (Mat.A.Aktionspos=BAG.P.Position) and
    (Mat.A.Aktionspos2=0) DO begin

    if (Mat_Data:Read(MAt.A.Materialnr)<200) then begin
      Msg(99,'Material nicht gefunden!',0,0,0);
      RETURN false;
    end;

    FOR Erx # RecLink(202,200,12,_RecLast)      // Bestandsbuch loopen
    LOOP Erx # RecLink(202,200,12,_RecPrev)
    WHILE (Erx<=_rLocked) do begin
      if ("Mat.B.Stückzahl"<>0) or (Mat.B.gewicht<>0.0) then begin
        Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
        Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
      end;
    END;

    aGew # aGew + Mat.Bestand.Gew;

    Erx # RecRead(204,2,_RecNext);
  END;

  RETURN true;
end;


//=======================================================================
//  ErzeugeSondererloes
//
//=======================================================================
sub ErzeugeSondererloes(
  aMatNr      : int;
  aPreis      : float;
  aBem        : alpha;
  aDiffTxt    : int
  ) : logic;
local begin
  Erx     : int;
  vBuf204 : int;
  vTmp    : int;
end;
begin

  if (FindeBAzuRestkarte(aMatNr)=false) then begin
//todo('KEIN BA gefudnen!');
    RETURN false;
  end;


  // Aktionen suchen...
  RecBufClear(204);
  Mat.A.Aktionstyp  # c_Akt_BA_UmlagePLUS;
  Mat.A.Aktionsnr   # BAG.P.Nummer;
  Mat.A.Aktionspos  # BAG.p.position;
  Mat.A.Aktionspos2 # 0;
  Erx # RecRead(204,2,0);
  WHILE (Erx<>_rNoRec) and
    (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) and
    (Mat.A.Aktionsnr=BAG.P.nummer) and
    (Mat.A.Aktionspos=BAG.P.Position) and
    (Mat.A.Aktionspos2=0) DO begin

    vTmp # Mat_Data:Read(Mat.A.Materialnr)
    if (vTmp<200) then begin
//todo('Mat nicht gefunden!?');
      RETURN false;
    end;


    vBuf204 # RekSave(204);

    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # c_Akt_Sondererloes;
    Mat.A.Aktionsnr     # BAG.P.Nummer;
    Mat.A.Aktionspos    # BAG.P.Position;
    Mat.A.Bemerkung     # aBem;
    Mat.A.Aktionsdatum  # today;
    Mat.A.Terminstart   # today;
    Mat.A.Terminende    # Today;
    Mat.A.Adressnr      # 0;
    Mat.A.KostenW1      # aPreis;
    Mat.A.Kostenstelle  # 0;

    Erx # Mat_a_data:Insert(0,'AUTO')
    if (Erx<>_rOK) then begin
      RecBufDestroy(vBuf204);
      RETURN false;
    end;
    if (vTmp=200) then begin
      if (Mat_A_Data:Vererben('', 200, aDiffTxt)=false) then begin
        RecBufDestroy(vBuf204);
        RETURN false;
      end;
    end
    else if (vTmp=210) then begin
      if (Mat_A_Data:Vererben('', 210, aDiffTxt)=false) then begin
        RecBufDestroy(vBuf204);
        RETURN false;
      end;
    end;

    RekRestore(vbuf204);

    Erx # RecRead(204,2,_RecNext);
  END;

  RETURN true;
end;


//=======================================================================
//  SchrottErloes
//
//=======================================================================
sub SchrottErloes(
  aWert         : float;
  opt aDiffTxt  : int) : logic;
local begin
  Erx       : int;
  vGew      : float;
  vWertProT : float;

  vMarked   : int;
  vMFile    : int;
  vMID      : int;

  vTree700  : int;
  vItem     : int;
  vProgress : int;
  vProgressLabel : alpha;
end;
begin
/***
  Mat.Nummer # 32;
  RecRead(200,1,0);
  Lib_MarK:MarkAdd(200);
  Mat.Nummer # 30;
  RecRead(200,1,0);
  Lib_MarK:MarkAdd(200);
  Mat.Nummer # 31;
  RecRead(200,1,0);
  Lib_MarK:MarkAdd(200);
  Mat.Nummer # 33;
  RecRead(200,1,0);
  Lib_MarK:MarkAdd(200);
***/

  // Gesamtgewicht errechnen ---------------------------------------------
  vProgressLabel # 'Summiere Schrott...';
  vProgress # Lib_Progress:Init(vProgressLabel, CteInfo(gMarkList, _cteCount));

  // Markierung loopen...
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN
    vProgress->Lib_Progress:Step();

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
    if (vMFile=200) then begin
      Erx # RecRead(200, 0, _recId, vMID);
      vProgress->Lib_Progress:SetLabel(vProgressLabel + ' ' + Aint(Mat.Nummer));

      if (SumGewichtFuerSchrott(Mat.Nummer, var vGew)=false) then begin
        vProgress->Lib_Progress:Term();
        RETURN false;
      end;
    end;

  END;  // ...Markierungen
  vProgress->Lib_Progress:Term();


  if (vGew=0.0) then begin
    Msg(99,'KEINE Kostenträger-Gewichte gefunden!',0,0,0);
    RETURN false;
  end;


  // Schrotterlös pro Tonne errechnen...
  vWertProT # aWert / vGew * 1000.0;
//todo('gesamt FM:'+anum(vKTGew,0)+'   Wert/t:'+anum(vWertProT,2));



  TRANSON;

  vTree700 # CteOpen(_CteTreeCI);

  // Sonererlöse eintragen-------------------------------------------------
  vProgresslabel # 'Lege Sondererlöse an...'
  vProgress # Lib_Progress:Init(vProgresslabel, CteInfo(gMarkList, _cteCount));
  // Markierung loopen...
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN
    vProgress->Lib_Progress:Step();

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
    if (vMFile=200) then begin
      Erx # RecRead(200, 0, _recId, vMID);
      vProgress->Lib_Progress:SetLabel(vProgressLabel + ' ' + Aint(Mat.Nummer));

      if (ErzeugeSondererloes(Mat.Nummer, -vWertProT, 'Schrottverkauf '+aint(Mat.Nummer), aDiffTxt)=false) then begin
        vTree700->Cteclear(y);
        vTree700->CteClose();
        TRANSBRK;
        vProgress->Lib_Progress:Term();
        Msg(99,'Sondererlös konnte in Mat.'+aint(mat.nummer)+' nicht verbucht werden!',0,0,0);
        RETURN false;
      end;

      vItem # CteOpen(_CteItem);
      vItem->spID     # BAG.P.Nummer;
      vItem->spCustom # '';
      vItem->spName   # cnvai(BAG.P.Nummer);
      vTree700->CteInsert(vItem);
    end;

  END;  // ...Markierungen
  vProgress->Lib_Progress:Term();

  TRANSOFF;


  // BAs neu kalkulieren ---------------------------------------------------
//  vProgressLabel # 'Aktuallisiere die BA Kosten...'
//  vProgress # Lib_Progress:Init(vProgressLabel, CteInfo(gMarkList, _cteCount));

  vItem # vTree700->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    BAg.P.Nummer # vItem->spid;
    RecReaD(700,1,0);
    Erx # RecLink(702,700,1,_RecFirst);   // Positionen loopen
    WHILE (Erx<=_rLocked) do begin
//      vProgress->Lib_Progress:Step();
//      vProgress->Lib_Progress:SetLabel(vProgressLabel + ' ' + Aint(BAG.P.Nummer) + '/' + Aint(BAG.P.Position));
      if (BAG.P.Aktion<>c_BAG_VSB) then
        UpdatePosition(BAG.Nummer, BAG.P.Position);
      Erx # RecLink(702,700,1,_RecNext);
    END;
    vItem # vTree700->CteRead(_Ctenext, vItem);
  END;

//  vProgress->Lib_Progress:Term();

  vTree700->Cteclear(y);
  vTree700->CteClose();

  Msg(999998,'',0,0,0);
  RETURN true;
end;


//=======================================================================
//=======================================================================
//=======================================================================