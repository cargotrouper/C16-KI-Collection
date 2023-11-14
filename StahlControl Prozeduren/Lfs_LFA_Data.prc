@A+
//===== Business-Control =================================================
//
//  Prozedur  Lfs_LFA_Data
//              OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  22.04.2010  AI  VSB auf WE füllt Bestandsbuch
//  REM 05.10.2010  AI  Verwiegungsart bei LFA aus LFS.Pos
//  12.10.2010  AI  Stornieren
//  25.10.2010  AI  BruttoNetto
//  04.11.2010  AI  Erweiterung für LFA-MultiLFS
//  13.01.2011  AI  NEU: UpdateLFSKopfzuLFA
//  03.02.2012  AI  GesamtFM mit aDatum umd übernimmt nun LFs.P.Menge
//  09.03.2012  AI  Projekt 1326/209: LFA-Umlagern setzt NIEMALS Kommission im LFS
//  15.03.2012  AI  MEH beim Theorie-Fertigmelden ist immer die von der Fertigung bzw. Output
//  14.05.2012  AI  neue LFS-Position rechnet sich FremdMEH aus (aus FM z.B.)
//  29.08.2012  AI  Löschen von Theorie Input, löscht LFS-Position (Projekt 1370/102)
//  22.02.2013  AI  Bugfix bei "Set.LFS.proKommissYN"
//  11.04.2013  AI  MatMEH
//  16.04.2013  AI  "Verwiegung_Art" nimmt Stückzahl "erstmal" auf, Umstellung dass FM AUCH Einsatz des LFA sind
//  17.02.2014  ST  sub Abschluss(..) POST Afx hinzugefügt
//  31.07.2014  ST  Prüfung auf Abschlussdatum bei "Verwiegung_Mat" & "Verwiegung_ARt" hinzugefügt Projekt 1326/395
//  24.05.2016  AH  Neu: "MeldeWEaufVSB"
//  31.05.2016  ST  Afx "BAG.FM.Fahr.Mat.Post" bei "Verwiegung_Mat" hinzugefügt
//  20.07.2016  ST  Edit: Verwiegungsart wird jetzt aus der Auftragsposition gelesen
//  01.02.2017  AH  Bug mit VWa
//  08.02.2017  AH  Bug mit Umlagern im nächsten Schritt
//  17.01.2018  ST  Arbeitsgang "Umlagern" hinzugefügt
//  28.01.2019  AH  Edit: "GesamtFM" hat optional Lagerplatz als Para
//  29.01.2019  AH  Neu: AFX "Lfs.ErzeugeAusLFA"
//  22.07.2019  AH  Edit: Aufruf von "Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen"
//  21.08.2019  AH  Edit: "GesamtFM" abgesichert mit Buffer
//  03.03.2020  AH  Neu: "GesamtFM" kann auch Artikel
//  09.02.2021  AH  Neu: WOF für LFS
//  27.07.2021  AH  ERX
//  04.11.2021  AH  "IstNurAusVersandNr"
//  16.12.2021  AH  Fix: BAG.FM.Fertigungsnr mit 999 vorbelegen!
//  2022-07-05  AH  DEADLOCK
//  2023-01-02  MR  Neue AFX Lfs.LFA.Data.GesamtFM.Post
//
//  Subprozeduren
//    SUB AbschlussInput(aBAG : int; aID : int) : logic;
//    SUB UpdateLFSKopfzuLFA() : logic;
//    SUB ErzeugeLFSausMultiLFA() : logic;
//    SUB ErzeugeLFSausLFA() : logic;
//    SUB Fertigmeldung(aBAG : int; aID : int; aDatum  : date ) : logic;
//    SUB Verwiegung_Mat(aStk : int; aNetto : float; aBrutto : float; aMenge : float; aMEH : alpha; aDatum :date; aBem : alpha; aWerksNr  : alpha;opt aMenge  : float) : logic
//    SUB Verwiegung_Art(aInput : float; aMEHIn : alpha; aOutput : float; aMEHOut : alpha; aStk : int; aGew : float; aDatum :date; aBem : alpha) : logic
//    SUB Abschluss();
//    SUB IstNurAusVersandNr() : int;
//    SUB GesamtFM(aDatum : date) : logic;
//    SUB ImportCSVzuVSB();
//    SUB Storniere() : logic
//    SUB MeldeWEaufVSB(aMatVSB : int; aErsetzen : logic; aVSBKillen : logic; aAutoFM : logic) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
//  AbschlussInput  +ERR
//
//========================================================================
sub AbschlussInput(
  aBAG  : int;
  aID   : int;
) : logic
local begin
  Erx : int;
end;
begin

  BAG.IO.Nummer # aBAG;
  BAG.IO.ID     # aID;
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then begin
    Error(010027,AInt(aBAG)+'|'+AInt(aID));
    RETURN false;
  end;

  // 08.02.2017 AH: Neu für Umlager-Fahren in späteren Schritten
  if (BAG.io.nachFertigung=0) then bag.IO.NachFertigung # 1;

  Erx # RecLink(703,701,10,_RecFirst);    // Nach Fertigung holen
  if (Erx<>_rOK) then begin
    Error(010028,AInt(aBAG)+'|'+AInt(aID));
    RETURN false;
  end;

/***
  Lfs.P.zuBA.Nummer     # BAG.F.Nummer;
  Lfs.P.zuBA.Position   # BAG.F.Position;
  Lfs.P.zuBA.Fertigung  # BAG.F.Fertigung;
  Lfs.P.zuBA.Fertigmel  # 0;
  Erx # RecRead(441,4,0);     // LFS-Position holen
***/
  Erx # RecLink(441,701,13,_recFirst);  // LFS-Pos. holen
  if (Erx>=_rLocked) then begin
    Error(010029,AInt(BAG.F.Nummer)+'/'+AInt(BAG.F.Position)+'/'+AInt(bag.F.Fertigung));
    RETURN false;
  end;
  RecLink(440,441,1,_recFirst); // LFS-Kopf holen
  if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=False) then begin
    RETURN false;
  end;


  // wenn der Posten aus dem Versand gekommen ist,
  // muss der Rest wieder inden Versandpool gestellt werden....
  if (Lfs.P.Versandpoolnr<>0) then begin
    VsP_Data:Rest2Pool(Lfs.P.Versandpoolnr);
  end;

  Erx # RekDelete(441,0,'AUTO');
  if (erx<>_rOK) then begin
    Error(010030,AInt(Lfs.P.Position));
    RETURN false;
  end

  // Erfolg!
  RETURN true;
end;


//========================================================================
//  UpdateLFSKopf  +ERR
//
//========================================================================
sub UpdateLFSKopfzuLFA() : logic;
local begin
  Erx : int;
end;
begin
  FOR Erx # RecLink(440,702,14,_Recfirst)     // LFS-Köpfe loopen
  LOOP Erx # RecLink(440,702,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if ("LFs.Löschmarker"='*') then CYCLE;
    Erx # RecRead(440,1,_recLock);
    if (erx=_rOK) then begin
      Lfs.Zieladresse   # BAG.P.Zieladresse;
      Lfs.Zielanschrift # BAG.P.Zielanschrift;
      // Kosten in LFS übernehmen...
      Lfs.Kosten.Pro    # BAG.P.Kosten.Pro;
      Lfs.Kosten.PEH    # BAG.P.Kosten.PEH;
      Lfs.Kosten.MEH    # BAG.P.Kosten.MEH;
      if (BAg.P.Kosten.Fix<>0.0) then begin
        Lfs.Kosten.Pro    # BAG.P.Kosten.Fix;
        Lfs.Kosten.PEH    # 1;
        Lfs.Kosten.MEH    # Translate('pauschal');
      end;
      Wae_Umrechnen(Lfs.Kosten.Pro, BAG.P.Kosten.Wae, var Lfs.Kosten.Pro, 1);

      if (BAG.P.ExternYN) then begin
        Erx # RecLink(100,702,7,_recFirst);   // Spediteur holen
        if (Erx>_Rlocked) or (BAG.P.ExterneLiefNr=0) then RecBufClear(100);
      end
      else begin
        if (Set.LFS.SpediLeerYN=false) then begin
          Adr.Nummer # Set.EigeneAdressnr;
          RecRead(100,1,0);
        end
        else begin
          RecBufClear(100);
        end;
      end;
      Lfs.Spediteurnr   # Adr.Nummer;
      Lfs.Spediteur     # Adr.Stichwort;
    //  Lfs.Bemerkung     # BAG.P.Bemerkung;
      Lfs.Lieferdatum   # BAG.P.Plan.EndDat;
      Erx # RekReplace(440,_recUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then RETURN false;

  END;

  RETURN true;
end;


//========================================================================
//  ErzeugeLFSausMultiLFA  +ERR
//
//========================================================================
sub ErzeugeLFSausMultiLFA() : logic;
local begin
  Erx         : int;
  vLfsNr      : int;
  vPos        : int;
  vExist      : logic;
  vBuf441     : int;
  vDel        : logic;
  vIstID      : int;
  vRestID     : int;
  vBuf701     : int;
  vBuf440b    : int;
  vBuf441b    : int;
  vAufNr      : int;
  vAufPos     : int;
end;
begin

  vBuf440b # RekSave(440);
  vBuf441b # RekSave(441);

  TRANSON;

  // LFS-Kopf anlegen *******************************************
  vExist # n;
  FOR Erx # RecLink(440,702,14,_recfirst)   // LFS loopen
  LOOP Erx # RecLink(440,702,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lfs.zuAuftragsnr=BAG.F.Auftragsnummer) or
      (Lfs.zuAuftragsnr=0) then begin
      vExist  # y;
      vLfsNr # Lfs.Nummer;
      Erx # RecRead(440,1,_recLock);
      if (Erx=_rDeadLock) then begin
        TRANSBRK
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        Error(1010,thisline);
        RETURN false;
      end;
      BREAK;
    end;
  END;

  if (vExist=n) then begin
    vLFSNr # Lib_Nummern:ReadNummer('Lieferschein');
    if (vLFSNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(019999,'LFS-Nummer nicht bestimmbar!');
      RETURN false;
    end;
    RecBufClear(440);
    Lfs.Nummer        # vLFSNr;
    Lfs.zuAuftragsnr  # BAG.F.Auftragsnummer;
    Lfs.Bemerkung     # Translate('Kommission')+' '+aint(Lfs.zuAuftragsnr);
  end;

  RecBufClear(401);
  if (BAG.P.Auftragsnr<>0) then begin
    vAufNr  # BAG.P.Auftragsnr;
    vAufPos # BAG.P.Auftragsnr;
  end
  else if (BAG.F.Auftragsnummer<>0) then begin
    vAufNr  # BAG.F.Auftragsnummer
    vAufPos # BAG.F.Auftragspos;
  end;
  if (vAufNr<>0) then begin
    Auf.Nummer # vAufNr;
    Erx # RecRead(400,1,0);
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(010031,AInt(Bag.P.nummer)+'/'+AInt(bag.P.Position)+'|'+AInt(vAufNr));
      RETURN false;
    end;
    Lfs.Kundennummer    # Auf.Kundennr;
    Lfs.Kundenstichwort # Auf.KundenStichwort;
  end;


  Lfs.Zieladresse   # BAG.P.Zieladresse;
  Lfs.Zielanschrift # BAG.P.Zielanschrift;

  // Kosten in LFS übernehmen...
  Lfs.Kosten.Pro    # BAG.P.Kosten.Pro;
  Lfs.Kosten.PEH    # BAG.P.Kosten.PEH;
  Lfs.Kosten.MEH    # BAG.P.Kosten.MEH;
  if (BAg.P.Kosten.Fix<>0.0) then begin
    Lfs.Kosten.Pro    # BAG.P.Kosten.Fix;
    Lfs.Kosten.PEH    # 1;
    Lfs.Kosten.MEH    # Translate('pauschal');
  end;
  Wae_Umrechnen(Lfs.Kosten.Pro, BAG.P.Kosten.Wae, var Lfs.Kosten.Pro, 1);

  if (BAG.P.ExternYN) then begin
    Erx # RecLink(100,702,7,_recFirst);   // Spediteur holen
    if (Erx>_Rlocked) or (BAG.P.ExterneLiefNr=0) then RecBufClear(100);
  end
  else begin
    if (Set.LFS.SpediLeerYN=false) then begin
      Adr.Nummer # Set.EigeneAdressnr;
      RecRead(100,1,0);
    end
    else begin
      RecBufClear(100);
    end;
  end;
  Lfs.Spediteurnr   # Adr.Nummer;
  Lfs.Spediteur     # Adr.Stichwort;
//  Lfs.Bemerkung     # BAG.P.Bemerkung;
  Lfs.zuBA.Nummer   # BAG.P.Nummer;
  Lfs.zuBA.Position # BAG.P.Position;
  Lfs.Lieferdatum   # BAG.P.Plan.EndDat;

  if (vExist) then begin
    Erx # RekReplace(440,_recUnlock,'AUTO');
  end
  else begin
    Lfs.Anlage.Datum  # Today;
    Lfs.Anlage.Zeit   # Now;
    Lfs.Anlage.User   # gUserName;
    Erx # RekInsert(440,0,'AUTO');
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf440b);
    RekRestore(vBuf441b);
    Error(010032,'');
    RETURN false;
  end;


  // falls BAG bereits gelöscht, KEINE Positionen weiter updaten...
  if ("BAG.P.Löschmarker"='*') then begin
    TRANSOFF
    RekRestore(vBuf440b);
    RekRestore(vBuf441b);
    RETURN true;
  end;


  Erx # RecLink(441,440,4,_recLast);
  if (Erx>_rLocked) then vPos # 1
  else vPos # Lfs.P.Position + 1;

  // LFS-Positionen anlegen für Input **************************************
  Erx # RecLink(701,702,2,_recFirst);     // Input loopen
  WHILE (Erx<=_rLockeD) do begin
    // Weiterbearbeitungen überspringen
    if (BAG.IO.Materialtyp=c_IO_BAG) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;
    if ("BAG.IO.LöschenYN") then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;
    if (BAG.IO.NachFertigung<>BAG.F.Fertigung) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

    // für MatMEH 16.04.2013: nicht eigene FM als Einsatz übernehmen
    if (BAG.IO.VonPosition=BAG.IO.NachPosition) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

    if (BAG.IO.Materialtyp<>c_IO_Theo) and
      (BAG.IO.Materialtyp<>c_IO_MAT) and (BAG.IO.Materialtyp<>c_IO_Art) and
      (BAG.IO.Materialtyp<>c_IO_VSB) then begin
      TRANSBRK;
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(019999,'unbekannter Einsatztyp!');
      RETURN false;
    end;

    if (BAG.IO.MaterialTyp=c_IO_Theo) and (BAG.IO.BruderID=0) then begin
      vIstID  # 0;
      vRestID # 0;
    end
    else if (BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID=0) then begin
      vIstID  # BAG.IO.MaterialRstNr;
      vRestID # BAG.IO.Materialnr;
    end
    else if (BAG.IO.MaterialTyp=c_IO_VSB) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID<>0)) then begin
      vIstID  # BAG.IO.MaterialNr;
      vRestID # BAG.IO.MaterialNr;
    end
    else if (BAG.IO.MaterialTyp=c_IO_ART) and (BAG.IO.BruderID=0) then begin
      vIstID  # 0;//BAG.IO.MaterialNr;
      vRestID # 0;//BAG.IO.MaterialNr;
    end
    else begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

    Erx # RecLink(441,701,13,_recFirst);  // LFS-Pos. holen
    if (Erx>=_rLocked) or (Lfs.Nummer<>Lfs.P.Nummer) then vExist # n
    else vExist # y;

    if (vExist) then begin
      vBuf441 # RekSave(441); // Lfs-Pos merken
      Erx # RecRead(441,1,_recLock);
      if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
    end
    else begin
      RecBufClear(441);
      Lfs.P.Nummer          # Lfs.Nummer;
      Lfs.P.Position        # vPos;//BAG.IO.ID;
      Lfs.P.VersandpoolNr   # BAG.IO.Versandpoolnr;
    end;

    if (BAG.F.Auftragsnummer<>0) then begin
      Lfs.P.Kommission      # BAG.F.Kommission;
      Lfs.P.Auftragsnr      # BAG.F.Auftragsnummer;
      Lfs.P.AuftragsPos     # BAG.F.Auftragspos;
      Lfs.P.AuftragsPos2    # BAG.F.AuftragsFertig;
    end
    else begin
      // passenden Output holen
      vBuf701 # RecBufCreate(701);
      Erx # RecLink(vBuf701, 703, 4,_recfirst);
      WHILE (Erx<=_rLocked) and (BAG.IO.NachID<>vBuf701->BAG.IO.ID) do begin
        Erx # RecLink(vBuf701, 703, 4,_recNext);
      END;
      if (Erx<=_rLocked) then begin
        // Projekt 1326/209: Umlagern setzt NIEMALS Kommission im LFS
        if (BAG.P.ZielVerkaufYN) then begin
          Lfs.P.Auftragsnr      # vBuf701->BAG.IO.Auftragsnr;
          Lfs.P.AuftragsPos     # vBuf701->BAG.IO.Auftragspos;
          Lfs.P.AuftragsPos2    # 0;
          if (Lfs.P.Auftragsnr<>0) then
            Lfs.P.Kommission      # AInt(Lfs.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos);
        end;
      end;
      vBuf701->recBufDestroy();
    end;

    "Lfs.P.Stück"         # BAG.IO.Plan.Out.Stk   - BAG.IO.Ist.Out.Stk;
    Lfs.P.Gewicht.Netto   # BAG.IO.Plan.Out.GewN  - BAG.IO.Ist.Out.GewN;
    Lfs.P.Gewicht.Brutto  # BAG.IO.Plan.Out.GewB  - BAG.IO.Ist.Out.GewB;
    Lfs.P.Menge           # BAG.IO.Plan.Out.Meng  - BAG.IO.Ist.Out.Menge;
    Lfs.P.MEH             # BAG.IO.MEH.Out;

    if (BAG.IO.Materialtyp=c_IO_Art) then begin
      Lfs.P.Menge.Einsatz   # BAG.IO.Plan.In.Menge  - BAG.IO.Ist.In.Menge;
      Lfs.P.MEH.Einsatz     # BAG.IO.MEH.In;
    end
    else begin
      Lfs.P.Menge.Einsatz   # BAG.IO.Plan.Out.Meng  - BAG.IO.Ist.Out.Menge;
      Lfs.P.MEH.einsatz     # BAG.IO.MEH.Out;
    end;

    Lfs.P.Kundennummer    # "BAG.F.ReservFürKunde";
    Lfs.P.Verwiegungsart  # 0;

    Lfs.P.zuBA.Nummer     # BAG.IO.Nummer;// xxx BAG.F.Nummer;
    Lfs.P.zuBA.Position   # BAG.F.Position;
    Lfs.P.zuBA.Fertigung  # BAG.F.Fertigung;
//    Lfs.P.zuBA.Fertigmel  # 0;//BAG.IO.vonFertigmeld;
    Lfs.P.zuBA.InputID    # BAG.IO.ID;

    Lfs.P.Materialtyp     # BAG.IO.Materialtyp;
    if (BAG.IO.Materialtyp=c_IO_Art) then begin  // Artikel
      Lfs.P.ArtikelNr       # BAG.IO.Artikelnr;
      Lfs.P.Art.Adresse     # BAG.IO.Lageradresse;
      Lfs.P.Art.Anschrift   # BAg.IO.Lageranschr;
      Lfs.P.Art.Charge      # BAG.IO.Charge;
      Erx # RecLink(252,441,14,_recFirst);  // Charge holen
      if (Erx>_rLocked) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
      Lfs.P.Bemerkung # Art.C.Bezeichnung;
    end;

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin  // Material
      Lfs.P.Materialnr      # vIstID;   // xxx BAG.IO.MaterialRstnr;
      Lfs.P.Ursprungsmatnr  # vRestID;  //  BAG.IO.Materialnr;
      Lfs.P.Paketnr         # 0; // TODO??
    end;

    if (BAG.IO.Materialtyp=c_IO_VSB) then begin  // VSB-Material
      Lfs.P.Materialnr      # vIstID;   // xxx BAG.IO.Materialnr;
      Lfs.P.Ursprungsmatnr  # vRestID;  // xxx BAG.IO.Materialnr;
      Lfs.P.Paketnr         # 0; // TODO??
    end;

    if (vExist=n) then begin
      REPEAT
        Lfs.P.Position        # vPos;
        erx # RekInsert(441,0,'AUTO');
        if (erx=_rDeadlock) then begin
          TRANSBRK;
          RekRestore(vBuf440b);
          RekRestore(vBuf441b);
          RETURN false;
        end;
        vPos # vPos + 1;
      UNTIL (erx=_rOK);

      // Position verbuchen
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n)=falsE) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
    end
    else begin
      erx # RekReplace(441,_recUnlock,'AUTO');

      // Position verbuchen
      if (erx<>_rOK) or (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n, vBuf441)=false) then begin
        RecBufDestroy(vBuf441);
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
      RecBufDestroy(vBuf441);

    end;

    Erx # RecLink(701,702,2,_recNext);
  END; // Pos anlegen


  // LFS-Positionen OHNE Input löschen *************************************
  Erx # RecLink(441,440,4,_recFirst);     // LFS-Pos. loopen
  WHILE (Erx<=_rLockeD) do begin

    // Verbuchte überspringen
    if (Lfs.P.Datum.Verbucht<>0.0.0) or (Lfs.Datum.Verbucht<>0.0.0) then begin
      Erx # RecLink(441,440,4,_recNext);
      CYCLE;
    end;

    vDel # n;
    Erx # RecLink(703,441,10,_RecFirst);  // BA-Fertigung holen
    if (Erx>_rMultikey) then vDel # y;

    if (vDel=n) then begin
      Erx # RecLink(702,441,9,_RecFirst);  // BA-Position holen
      if (Erx>_rMultikey) then vDel # y;
      if (vDel=n) then begin
        // 29.08.2012 AI
        Erx # RecLink(701,441,11,_recFirst);   // Input loopen
        if (Erx>_rLocked) or ("BAG.IO.LöschenYN") then vDel # y;
      end;
    end;

    if (vDel) then begin
      // bisherige VLDAW stornieren
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
      Erx # RekDelete(441,0,'AUTO');
      Erx # RecLink(441,440,4,0);
      Erx # RecLink(441,440,4,0);
      CYCLE;
    end;

    Erx # RecLink(441,440,4,_recNext);
  END;

  // Kopfgewichte addieren...
  Lfs_Data:SumLFS();

  Lib_Workflow:Trigger(440, 440, _WOF_KTX_NEU);   // 09.02.2021 AH

  // ERFOLG
  TRANSOFF


  RekRestore(vBuf440b);
  RekRestore(vBuf441b);

  RETURN true;
end;


//========================================================================
//  ErzeugeLFSausLFA  +ERR
//
//========================================================================
sub ErzeugeLFSausLFA() : logic;
local begin
  Erx         : int;
  vLfsNr      : int;
  vPos        : int;
  vExist      : logic;
  vBuf441     : int;
  vDel        : logic;
  vIstID      : int;
  vRestID     : int;
  vBuf701     : int;
  vBuf440b    : int;
  vBuf441b    : int;
  vAufNr      : int;
  vAufPos     : int;
  vOK         : logic;
  v702,v703   : int;
end;
begin
  if (BAG.VorlageYN) then RETURN true;    // 09.12.2021 AH

  // 29.01.2019
  if (RunAfx('Lfs.ErzeugeAusLFA','')<>0) then RETURN (AfxRes=_rOK);


//Set.LFS.proKommissYN # y;

  // nur Fahren kann LFS generieren
  if (BAG.P.Aktion<>c_BAG_Fahr) AND (Bag.P.Aktion <> c_BAG_Umlager) then RETURN true;
  // Einzel LFS pro Kommission anlegen?
  if (Set.LFS.proKommissYN) then begin
    Erx # RecLink(701,702,2,_recFirst);   // 1. Input holen
    if (Erx<=_rLocked) then begin
      if (BAG.IO.NachFertigung<>0) then begin

//          vOK # ErzeugeLFSausMultiLFA();
        // 02.03.2020 AH : da Update seit 14.02.2020 nur EINMAL passiert, muss man jetzt jede Fertigung loopen (VBS)
        vOK # y;
        FOR Erx # RecLink(703,702,4,_RecFirst)
        LOOP Erx # RecLink(703,702,4,_Recnext)
        WHILE (Erx<=_rLocked) and (vOK) do begin
          v702 # RekSave(702);
          v703 # RekSave(703);
          vOK # ErzeugeLFSausMultiLFA();
          RekRestore(v702);
          RekRestore(v703);
        END;
        RETURN vOK;
      end;
    end;
  end;

  vBuf440b # RekSave(440);
  vBuf441b # RekSave(441);

  TRANSON;

  // LFS-Kopf anlegen *******************************************

  vExist # n;
  RecBufClear(440);
  Lfs.zuBA.Nummer   # BAG.P.Nummer;
  Lfs.zuBA.Position # BAG.P.Position;
  Erx # RecRead(440,2,0);
  if (Erx<=_rMultiKey) then begin
    vExist  # y;
    Erx # RecRead(440,1,_recLock);
    if (erx=_rDeadlock) then begin    // 2022-07-05 AH DEADLOCK
      TRANSBRK
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(1010,thisline);
      RETURN false;
    end;
    vLfsNr  # Lfs.Nummer;
  end
  else begin
    vLFSNr # Lib_Nummern:ReadNummer('Lieferschein');
    if (vLFSNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(019999,'LFS-Nummer nicht bestimmbar!');
      RETURN false;
    end;
    RecBufClear(440);
    Lfs.Nummer        # vLFSNr;
  end;


  RecBufClear(401);
  if (BAG.P.Auftragsnr<>0) then begin
    vAufNr  # BAG.P.Auftragsnr;
    vAufPos # BAG.P.Auftragsnr;
  end
  else if (BAG.F.Auftragsnummer<>0) then begin
    vAufNr  # BAG.F.Auftragsnummer
    vAufPos # BAG.F.Auftragspos;
  end;
  if (vAufNr<>0) then begin
    Auf.Nummer # vAufNr;
    Erx # RecRead(400,1,0);
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(010031,AInt(Bag.P.nummer)+'/'+AInt(bag.P.Position)+'|'+AInt(vAufNr));
      RETURN false;
    end;
    Lfs.Kundennummer    # Auf.Kundennr;
    Lfs.Kundenstichwort # Auf.KundenStichwort;
  end;



  Lfs.Zieladresse   # BAG.P.Zieladresse;
  Lfs.Zielanschrift # BAG.P.Zielanschrift;



  // Kosten in LFS übernehmen...
  Lfs.Kosten.Pro    # BAG.P.Kosten.Pro;
  Lfs.Kosten.PEH    # BAG.P.Kosten.PEH;
  Lfs.Kosten.MEH    # BAG.P.Kosten.MEH;
  if (BAg.P.Kosten.Fix<>0.0) then begin
    Lfs.Kosten.Pro    # BAG.P.Kosten.Fix;
    Lfs.Kosten.PEH    # 1;
    Lfs.Kosten.MEH    # Translate('pauschal');
  end;
  Wae_Umrechnen(Lfs.Kosten.Pro, BAG.P.Kosten.Wae, var Lfs.Kosten.Pro, 1);

  if (BAG.P.ExternYN) then begin
    Erx # RecLink(100,702,7,_recFirst);   // Spediteur holen
    if (Erx>_Rlocked) or (BAG.P.ExterneLiefNr=0) then RecBufClear(100);
  end
  else begin
    if (Set.LFS.SpediLeerYN=false) then begin
      Adr.Nummer # Set.EigeneAdressnr;
      RecRead(100,1,0);
    end
    else begin
      RecBufClear(100);
    end;
  end;
  Lfs.Spediteurnr   # Adr.Nummer;
  Lfs.Spediteur     # Adr.Stichwort;
  Lfs.Bemerkung     # BAG.P.Bemerkung;
  Lfs.zuBA.Nummer   # BAG.P.Nummer;
  Lfs.zuBA.Position # BAG.P.Position;
  Lfs.Lieferdatum   # BAG.P.Plan.EndDat;

  if (vExist) then begin
    Erx # RekReplace(440,_recUnlock,'AUTO');
  end
  else begin
    Lfs.Anlage.Datum  # Today;
    Lfs.Anlage.Zeit   # Now;
    Lfs.Anlage.User   # gUserName;
    Erx # RekInsert(440,0,'AUTO');
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf440b);
    RekRestore(vBuf441b);
    Error(010032,'');
    RETURN false;
  end;


  // falls BAG bereits gelöscht, KEINE Positionen weiter updaten...
  if ("BAG.P.Löschmarker"='*') then begin
    TRANSOFF
    RekRestore(vBuf440b);
    RekRestore(vBuf441b);
    RETURN true;
  end;



  Erx # RecLink(441,440,4,_recLast);
  if (Erx>_rLocked) then vPos # 1
  else vPos # Lfs.P.Position + 1;


  // LFS-Positionen anlegen für Input **************************************
  Erx # RecLink(701,702,2,_recFirst);     // Input loopen
  WHILE (Erx<=_rLockeD) do begin
    // Weiterbearbeitungen überspringen
    if (BAG.IO.Materialtyp=c_IO_BAG) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;
    if ("BAG.IO.LöschenYN") then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

    if (BAG.IO.Materialtyp<>c_IO_Theo) and (BAG.IO.Materialtyp<>c_IO_Beistell) and
      (BAG.IO.Materialtyp<>c_IO_MAT) and (BAG.IO.Materialtyp<>c_IO_Art) and
      (BAG.IO.Materialtyp<>c_IO_VSB) then begin
      TRANSBRK;
      RekRestore(vBuf440b);
      RekRestore(vBuf441b);
      Error(019999,'unbekannter Einsatztyp!');
      RETURN false;
    end;

    // 17.01.2017 AH: Neu für Umlager-Fahren in späteren Schritten
    if (BAG.io.nachFertigung=0) then bag.IO.NachFertigung # 1;

    Erx # RecLink(703,701,10,_recFirst);  // nachFertigung holen
    if (Erx>_rLocked) then begin
    //RecBufClear(703);
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

    if (BAG.IO.MaterialTyp=c_IO_Theo) and (BAG.IO.BruderID=0) then begin
      vIstID  # 0;
      vRestID # 0;
    end
    else if (BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID=0) then begin
      vIstID  # BAG.IO.MaterialRstNr;
      vRestID # BAG.IO.Materialnr;
    end
    else if (BAG.IO.MaterialTyp=c_IO_VSB) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID<>0)) then begin
      vIstID  # BAG.IO.MaterialNr;
      vRestID # BAG.IO.MaterialNr;
    end
    else if (BAG.IO.MaterialTyp=c_IO_ART) and (BAG.IO.BruderID=0) then begin
      vIstID  # 0;//BAG.IO.MaterialNr;
      vRestID # 0;//BAG.IO.MaterialNr;
    end
    else if (BAG.IO.MaterialTyp=c_IO_Beistell) and (BAG.IO.BruderID=0) then begin
      vIstID  # 0;//BAG.IO.MaterialNr;
      vRestID # 0;//BAG.IO.MaterialNr;
    end
    else begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

/*
    RecBufClear(441);
    Lfs.P.zuBA.Nummer     # BAG.F.Nummer;
    Lfs.P.zuBA.Position   # BAG.F.Position;
    Lfs.P.zuBA.Fertigung  # BAG.F.Fertigung;
x    Lfs.P.zuBA.Fertigmel  # 0;
    Lfs.P.zuBA.InputID    # BAG.IO.ID;
    vExist # n;
x    Erx # RecRead(441,4,0);
    WHILE (Erx<=_rMultikey) do begin
      if (LFS.P.Nummer<>Lfs.Nummer) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        Error(019999,'LFS-Position nicht gefunden!');
        RETURN false;
      end;
      if (Lfs.P.Materialnr=vIstID) then begin
        vExist # Y;
        BREAK;
      end;
      Erx # RecRead(441,4,_recNext);
    END;
*/
    Erx # RecLink(441,701,13,_recFirst);  // LFS-Pos. holen
    if (Erx>=_rLocked) or (Lfs.Nummer<>Lfs.P.Nummer) then vExist # n
    else vExist # y;

    if (vExist) then begin
      vBuf441 # RekSave(441); // Lfs-Pos merken
      Erx # RecRead(441,1,_recLock);
      if (erx=_rDeadlock) then begin    // 2022-07-05 AH DEADLOCK
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        Error(1010,thisline);
        RETURN false;
      end;
     
    end
    else begin
      RecBufClear(441);
      Lfs.P.Nummer          # Lfs.Nummer;
      Lfs.P.Position        # vPos;//BAG.IO.ID;
      Lfs.P.VersandpoolNr   # BAG.IO.Versandpoolnr;
    end;

    if (BAG.F.Auftragsnummer<>0) then begin
      Lfs.P.Kommission      # BAG.F.Kommission;
      Lfs.P.Auftragsnr      # BAG.F.Auftragsnummer;
      Lfs.P.AuftragsPos     # BAG.F.Auftragspos;
      Lfs.P.AuftragsPos2    # BAG.F.AuftragsFertig;
    end
    else begin
      // passenden Output holen
      vBuf701 # RecBufCreate(701);
      Erx # RecLink(vBuf701, 703, 4,_recfirst);
      WHILE (Erx<=_rLocked) and (BAG.IO.NachID<>vBuf701->BAG.IO.ID) do begin
        Erx # RecLink(vBuf701, 703, 4,_recNext);
      END;
      if (Erx<=_rLocked) then begin
        // Projekt 1326/209: Umlagern setzt NIEMALS Kommission im LFS
        if (BAG.P.ZielVerkaufYN) then begin
          Lfs.P.Auftragsnr      # vBuf701->BAG.IO.Auftragsnr;
          Lfs.P.AuftragsPos     # vBuf701->BAG.IO.Auftragspos;
          Lfs.P.AuftragsPos2    # 0;
          if (Lfs.P.Auftragsnr<>0) then
            Lfs.P.Kommission      # AInt(Lfs.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos);
        end;
      end;
      vBuf701->recBufDestroy();
    end;


//    if (Lfs.P.Auftragspos<>0) then begin
//todo('kunde:'+aint(bag.f.
//    end;


    "Lfs.P.Stück"         # BAG.IO.Plan.Out.Stk   - BAG.IO.Ist.Out.Stk;
    Lfs.P.Gewicht.Netto   # BAG.IO.Plan.Out.GewN  - BAG.IO.Ist.Out.GewN;
    Lfs.P.Gewicht.Brutto  # BAG.IO.Plan.Out.GewB  - BAG.IO.Ist.Out.GewB;
    Lfs.P.Menge           # BAG.IO.Plan.Out.Meng  - BAG.IO.Ist.Out.Menge;
    Lfs.P.MEH             # BAG.IO.MEH.Out;

    if (BAG.IO.Materialtyp=c_IO_Art) then begin
      Lfs.P.Menge.Einsatz   # BAG.IO.Plan.In.Menge  - BAG.IO.Ist.In.Menge;
      Lfs.P.MEH.Einsatz     # BAG.IO.MEH.In;
    end
    else begin
      Lfs.P.Menge.Einsatz   # BAG.IO.Plan.Out.Meng  - BAG.IO.Ist.Out.Menge;
      Lfs.P.MEH.einsatz     # BAG.IO.MEH.Out;
    end;

    Lfs.P.Kundennummer    # "BAG.F.ReservFürKunde";

    // ST 2016-07-20 Verwiegungsart immer aus Auftragspos übernehmen
    //Lfs.P.Verwiegungsart  # 0;  // Vorher
    Auf_Data:Read(Lfs.P.Auftragsnr,Lfs.P.AuftragsPos,false);
    Lfs.P.Verwiegungsart  # Auf.P.Verwiegungsart;


    // 01.02.2017
    if (Lfs.P.MEH='kg') or (Lfs.P.MEH='t') then begin
      Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
      if (Erx>_rLocked) then begin
        RecBufClear(818);
        VWa.NettoYN # Y;
      end;
      if (VWa.NettoYN) then
        Lfs.P.Menge           # Lfs.P.Gewicht.Netto
      else
        Lfs.P.Menge           # Lfs.P.Gewicht.Brutto;
      if (Lfs.P.MEH='t') then Lfs.P.Menge # Rnd(Lfs.P.Menge / 1000.0, Set.Stellen.Menge);;
    end;


    Lfs.P.zuBA.Nummer     # BAG.IO.Nummer;// xxx BAG.F.Nummer;
    Lfs.P.zuBA.Position   # BAG.F.Position;
    Lfs.P.zuBA.Fertigung  # BAG.F.Fertigung;
//    Lfs.P.zuBA.Fertigmel  # 0;//BAG.IO.vonFertigmeld;
    Lfs.P.zuBA.InputID    # BAG.IO.ID;

    if (BAG.IO.Materialtyp=c_IO_Beistell) then
      Lfs.P.Materialtyp     # c_IO_VPG
    else
      Lfs.P.Materialtyp     # BAG.IO.Materialtyp;
    if (BAG.IO.Materialtyp=c_IO_Beistell) or
      (BAG.IO.Materialtyp=c_IO_Art) then begin  // Artikel
      Lfs.P.ArtikelNr       # BAG.IO.Artikelnr;
      Lfs.P.Art.Adresse     # BAG.IO.Lageradresse;
      Lfs.P.Art.Anschrift   # BAg.IO.Lageranschr;
      Lfs.P.Art.Charge      # BAG.IO.Charge;
      Erx # RecLink(252,441,14,_recFirst);  // Charge holen
      if (Erx>_rLocked) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
      Lfs.P.Bemerkung # Art.C.Bezeichnung;
    end;

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin  // Material
      Lfs.P.Materialnr      # vIstID;   // xxx BAG.IO.MaterialRstnr;
      Lfs.P.Ursprungsmatnr  # vRestID;  //  BAG.IO.Materialnr;
      Lfs.P.Paketnr         # 0; // TODO??
    end;

    if (BAG.IO.Materialtyp=c_IO_VSB) then begin  // VSB-Material
      Lfs.P.Materialnr      # vIstID;   // xxx BAG.IO.Materialnr;
      Lfs.P.Ursprungsmatnr  # vRestID;  // xxx BAG.IO.Materialnr;
      Lfs.P.Paketnr         # 0; // TODO??
    end;

    if (vExist=n) then begin
      REPEAT
        Lfs.P.Position        # vPos;
        Erx # RekInsert(441,0,'AUTO');
        if (erx=_rDeadlock) then begin
          TRANSBRK;
          RekRestore(vBuf440b);
          RekRestore(vBuf441b);
          RETURN false;
        end;
        vPos # vPos + 1;
      UNTIL (erx=_rOK);

      // Position verbuchen
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n)=falsE) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
    end
    else begin
      Erx # RekReplace(441,_recUnlock,'AUTO');

      // Position verbuchen
      if (erx<>_rOK) or (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n, vBuf441)=false) then begin
        RecBufDestroy(vBuf441);
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
      RecBufDestroy(vBuf441);

    end;

    Erx # RecLink(701,702,2,_recNext);
  END; // Pos anlegen


  // LFS-Positionen OHNE Input löschen *************************************
  Erx # RecLink(441,440,4,_recFirst);     // LFS-Pos. loopen
  WHILE (Erx<=_rLockeD) do begin

    // Verbuchte überspringen
    if (Lfs.P.Datum.Verbucht<>0.0.0) or (Lfs.Datum.Verbucht<>0.0.0) then begin
      Erx # RecLink(441,440,4,_recNext);
      CYCLE;
    end;

    vDel # n;
    Erx # RecLink(703,441,10,_RecFirst);  // BA-Fertigung holen
    if (Erx>_rMultikey) then vDel # y;

    if (vDel=n) then begin
      Erx # RecLink(702,441,9,_RecFirst);  // BA-Position holen
      if (Erx>_rMultikey) then vDel # y;
      if (vDel=n) then begin
        // 29.08.2012 AI
        Erx # RecLink(701,441,11,_recFirst);   // Input loopen
        if (Erx>_rLocked) or ("BAG.IO.LöschenYN") then vDel # y;
      end;
    end;

    if (vDel) then begin
      // bisherige VLDAW stornieren
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
        TRANSBRK;
        RekRestore(vBuf440b);
        RekRestore(vBuf441b);
        RETURN false;
      end;
      Erx # RekDelete(441,0,'AUTO');
      Erx # RecLink(441,440,4,0);
      Erx # RecLink(441,440,4,0);
      CYCLE;
    end;

    Erx # RecLink(441,440,4,_recNext);
  END;

  // Kopfgewichte addieren...
  Lfs_Data:SumLFS();

  Lib_Workflow:Trigger(440, 440, _WOF_KTX_NEU);   // 09.02.2021 AH

  // ERFOLG
  TRANSOFF

  RekRestore(vBuf440b);
  RekRestore(vBuf441b);

  RETURN true;
end;


//========================================================================
//  Fertigmeldung +ERR
//
//========================================================================
sub Fertigmeldung(
  aBAG    : int;
  aID     : int;
  aDatum  : date;
  aZeit   : time; ) : logic
local begin
  Erx         : int;
  vLfsNr      : int;
  vPos        : int;
  vBuf701     : int;
  vMatUr      : int;
  vMatNeu     : int;
  vGew        : float;
  vStk        : int;
  vArtEinsatz : float;
  vArtMEH     : alpha;
  vPreisOK    : logic;
end;
begin

  BAG.IO.Nummer # aBAG;
  BAG.IO.ID     # aID;
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then begin
    Error(010027,AInt(aBAG)+'|'+AInt(aID));
    RETURN false;
  end;

  Erx # RecLink(702,701,2,_recFirst);   // BAG-Position holen
  if (Erx<>_rOk) then begin
    Error(010028,AInt(aBAG)+'|'+AInt(aID));
    RETURN false;
  end;

  // nur Fahren kann LFS generieren
  if (BAG.P.Aktion<>c_BAG_Fahr) AND (BAG.P.Aktion<>c_BAG_Umlager)  then RETURN true;

  BAG.IO.ID # BAG.IO.vonID;               // Einsatz Input holen
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then begin
    Error(010027,AInt(aBAG)+'|'+AInt(BAG.IO.vonID));
    RETURN false;
  end;

  // 08.02.2017 AH: Neu für Umlager-Fahren in späteren Schritten
  if (BAG.io.nachFertigung=0) then bag.IO.NachFertigung # 1;

  Erx # RecLink(703,701,10,_RecFirst);    // nach Fertigung holen
  if (Erx<>_rOK) then begin
    Error(010028,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.ID));
    RETURN false;
  end;

  Erx # RecLink(441,701,13,_recFirst);  // LFS-Pos. holen
  if (Erx>=_rLocked) then begin
    Error(010029,AInt(BAG.F.Nummer)+'/'+AInt(BAG.F.Position)+'/'+AInt(BAG.F.Fertigung));
    RETURN false;
  end;
  Erx # RecLink(440,441,1,_recFirst);   // LFS-Hope holen
  Erx # RecLink(441,440,4,_recLast);
  if (Erx>_rLocked) then vPos # 1
  else vPos # Lfs.P.Position + 1;
  Erx # RecLink(441,701,13,_recFirst);  // LFS-Pos. holen

  vLFSNr  # Lfs.P.Nummer;
  vPos    # Lfs.P.Position;

  TRANSON;

  // bisherige Position löschen
  if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
    TRANSBRK;
    RETURN false;
  end;
  Erx # RecRead(441,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(010008,AInt(Lfs.P.Nummer)+'/'+AInt(Lfs.P.Position));
    RETURN false;
  end;

  Lfs.P.ReservierungNr  # 0;
  if (BAG.F.AuftragsNummer<>0) then begin
    Lfs.P.Kommission      # BAG.F.Kommission;
    Lfs.P.Auftragsnr      # BAG.F.Auftragsnummer;
    Lfs.P.AuftragsPos     # BAG.F.Auftragspos;
    Lfs.P.AuftragsPos2    # BAG.F.AuftragsFertig;
  end
  else begin
    // passenden Output holen
    vBuf701 # RecBufCreate(701);
    Erx # RecLink(vBuf701, 703, 4,_recfirst);
    WHILE (Erx<=_rLocked) and (BAG.IO.NachID<>vBuf701->BAG.IO.ID) do begin
      Erx # RecLink(vBuf701, 703, 4,_recNext);
    END;
    if (Erx<=_rLocked) then begin
      // Projekt 1326/209: Umlagern setzt NIEMALS Kommission im LFS
      if (BAG.P.ZielVerkaufYN) then begin
        Lfs.P.Auftragsnr      # vBuf701->BAG.IO.Auftragsnr;
        Lfs.P.AuftragsPos     # vBuf701->BAG.IO.Auftragspos;
        Lfs.P.AuftragsPos2    # 0;
        if (Lfs.P.Auftragsnr<>0) then
          Lfs.P.Kommission      # AInt(Lfs.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos);
      end;
    end;
    vBuf701->recBufDestroy();
  end;

  "Lfs.P.Stück"         # BAG.IO.Plan.Out.Stk   - BAG.IO.Ist.Out.Stk;
  Lfs.P.Gewicht.Netto   # BAG.IO.Plan.Out.GewN  - BAG.IO.Ist.Out.GewN;
  Lfs.P.Gewicht.Brutto  # BAG.IO.Plan.Out.GewB  - BAG.IO.Ist.Out.GewB;
  Lfs.P.Menge           # BAG.IO.Plan.Out.Meng  - BAG.IO.Ist.Out.Menge;
  Lfs.P.MEH             # BAG.IO.MEH.Out;

  // 02.02.2017
  if (Lfs.P.Auftragsnr<>0) and
    ((Lfs.P.MEH='kg') or (Lfs.P.MEH='t')) then begin
    Erx # RecLink(401,441,5,_recFirst);   // Aufposition holen
    Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
    if (VWa.NettoYN) then
      Lfs.P.Menge       # Lfs.P.Gewicht.Netto
    else
      Lfs.P.Menge       # Lfs.P.Gewicht.Brutto;
    if (Lfs.P.MEH='t') then Lfs.P.Menge # Rnd(Lfs.P.Menge / 1000.0, Set.Stellen.Menge);;
  end;

  Lfs.P.Menge.Einsatz   # BAG.IO.Plan.Out.Meng  - BAG.IO.Ist.Out.Menge;
  Lfs.P.MEH.Einsatz     # BAG.IO.MEH.Out;
  Lfs.P.Kundennummer    # "BAG.F.ReservFürKunde";

  // ST 2016-07-20 Verwiegungsart immer aus Auftragspos übernehmen
  //Lfs.P.Verwiegungsart  # 0;  // Vorher
  Auf_Data:Read(Lfs.P.Auftragsnr,Lfs.P.AuftragsPos,false);
  Lfs.P.Verwiegungsart  # Auf.P.Verwiegungsart;


  Lfs.P.Materialtyp     # BAG.IO.Materialtyp;

  if (BAG.IO.Materialtyp=c_IO_Art) then begin  // Artikel
    Lfs.P.ArtikelNr       # BAG.IO.Artikelnr;
    Lfs.P.Art.Adresse     # BAG.IO.Lageradresse;
    Lfs.P.Art.Anschrift   # BAG.IO.Lageranschr;
    Lfs.P.Art.Charge      # BAG.IO.Charge;

    //vArtEinsatz # BAG.IO.Ist.In.Menge;
    vArtMEH     # BAG.IO.MEH.In;
    Erx # RecLink(708,707,12,_recFirst);  // BAG-Bewegungen loopen
    WHILE (Erx<=_rLocked) do begin
      if (BAG.FM.B.Artikelnr=BAG.IO.Artikelnr) and (BAG.FM.B.MEH=vArtMEH) then begin
        vArtEinsatz # vArtEinsatz - BAG.FM.B.Menge;
      end;
      Erx # RecLink(708,707,12,_recNext);
    END;

    Lfs.P.Menge.Einsatz   # BAG.IO.Plan.In.Menge - BAG.IO.Ist.In.Menge;
    Lfs.P.MEH.Einsatz     # BAG.IO.MEH.In;
  end
  else  if (BAG.IO.Materialtyp=c_IO_Mat) then begin  // Material
    Lfs.P.Materialnr      # BAG.IO.MaterialRstnr;
//    Lfs.P.Reservierungnr  # 0; // TODO??
    Lfs.P.Ursprungsmatnr  # BAG.IO.Materialnr;
    Lfs.P.Paketnr         # 0; // TODO??
  end;

  vMatUr   # Lfs.P.MaterialNr;

  Erx # RekReplace(441,_recUnlock,'AUTO');

  // neue Aktion anlegen
  if (erx<>_ROK) or (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n,0, y)=false) then begin
    TRANSBRK;
    RETURN false;
  end;


  // neue LFS-Positionen anlegen für neuen Output *******************************
  vPos # vPos + 1;
  BAG.IO.Nummer # aBAG;
  BAG.IO.ID     # aID;
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(010027,AInt(aBAG)+'|'+AInt(aID));
    RETURN false;
  end;

  "Lfs.P.Stück"         # BAG.IO.Ist.In.Stk;
  Lfs.P.Gewicht.Netto   # BAG.IO.Ist.In.GewN;
  Lfs.P.Gewicht.Brutto  # BAG.IO.Ist.In.GewB;
  Lfs.P.Menge           # BAG.IO.Ist.In.Menge;

  Lfs.P.MEH             # BAG.IO.MEH.In;
  Lfs.P.Menge.Einsatz   # BAG.IO.Ist.In.Menge;
  Lfs.P.MEH.Einsatz     # BAG.IO.MEH.In;
  Lfs.P.zuBA.Nummer     # BAG.IO.vonBAG;
  Lfs.P.zuBA.Position   # BAG.IO.vonPosition;
  Lfs.P.zuBA.Fertigung  # BAG.IO.vonFertigung;
//  Lfs.P.zuBA.Fertigmel  # BAG.IO.vonFertigmeld;

  Lfs.P.Materialtyp     # BAG.IO.Materialtyp;
  if (BAG.IO.Materialtyp=c_IO_Art) then begin  // Artikel
    Lfs.P.ArtikelNr       # BAG.IO.Artikelnr;
    Lfs.P.Art.Adresse     # BAG.IO.Lageradresse;
    Lfs.P.Art.Anschrift   # BAG.IO.Lageranschr;
    Lfs.P.Art.Charge      # BAG.IO.Charge;

    Lfs.P.Menge           # BAG.IO.Ist.In.Menge;
    Lfs.P.MEH             # BAG.IO.MEH.In;

    Lfs.P.Menge.Einsatz   # vArtEinsatz;
    Lfs.P.MEH.Einsatz     # vArtMEH;
  end
  else if (BAG.IO.Materialtyp=c_IO_Mat) then begin  // Material
    Lfs.P.Materialnr      # BAG.IO.Materialnr;
    Lfs.P.Reservierungnr  # 0;
    Lfs.P.Ursprungsmatnr  # BAG.IO.Materialnr;
    Lfs.P.Paketnr         # 0; // TODO??
  end;

  // 02.02.2017
  if (Lfs.P.Auftragsnr<>0) and
    ((Lfs.P.MEH='kg') or (Lfs.P.MEH='t')) then begin
    Erx # RecLink(401,441,5,_recFirst);   // Aufposition holen
    Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
    if (VWa.NettoYN) then
      Lfs.P.Menge       # Lfs.P.Gewicht.Netto
    else
      Lfs.P.Menge       # Lfs.P.Gewicht.Brutto;
    if (Lfs.P.MEH='t') then Lfs.P.Menge # Rnd(Lfs.P.Menge / 1000.0, Set.Stellen.Menge);;
  end;


  // NEU 14.05.2012
  if (Lfs.P.Menge=0.0) then begin
    Lfs.P.Menge # Lib_Einheiten:WandleMEH(701, "LFS.P.Stück", Lfs.P.Gewicht.Netto, 0.0,'', Lfs.P.MEH);
  end;
  if (Lfs.P.Menge.Einsatz=0.0) then begin
    Lfs.P.Menge.Einsatz # Lib_Einheiten:WandleMEH(701, "LFS.P.Stück", Lfs.P.Gewicht.Netto, 0.0,'', Lfs.P.MEH);
  end;


  vMatNeu  # Lfs.P.MaterialNr;

  REPEAT
    Lfs.P.Position        # vPos;
    Erx # RekInsert(441,0,'AUTO');
    if (Erx=_rDeadLock) then begin
      TRANSBRK;
      RETURN false;
    end;
    vPos # vPos + 1;
  UNTIL (erx=_rOK);

  // Position verbuchen

  // erst als Verladung....
  if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n,0, y)=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  // dann als Lieferschein verbuchen OHNE Pauschalkosten
  if (Lfs_Data:Pos_Verbuchen(aDatum, aZeit, false, var vPreisOK)=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

//  if (vPReisOK=false) then begin
//todox('Preis wird sich noch veärndern!!!');
//  end;

  // ERFOLG
  RETURN true;
end;


//========================================================================
//  Verwiegung_Mat  +ERR
//
//========================================================================
sub Verwiegung_Mat(
  aStk        : int;
  aNetto      : float;
  aBrutto     : float;
  aMenge      : float;
  aMEH        : alpha;
  aDatum      : date;
  aBem        : alpha;
  aWerksNr    : alpha;
  aLagerplatz : alpha;
  opt aEtkTxt : int;
) : logic
local begin
  Erx       : int;
  vFM       : int;
  vBruderID : int;
  v441      : int;
  vLfd      : int;
end;
begin

  APPOFF();

  if (Lib_Faktura:Abschlusstest(aDatum) = false) then begin
    APPON();
    Error(001400 ,Translate('Fertigmeldungsdatum') + '|'+ CnvAd(aDatum));
    RETURN false;
  end;

  Erx # RecLink(702,441,9,_recFirst);   // BA-Position holen
  if (Erx>_rLocked) then begin
    APPON();
    Error(019999,'BA-Pos. nicht gefunden!');
    RETURN false;
  end;

  Erx # RecLink(703,441,10,_recFirst);  // BA-Fertigung holen
  if (Erx>_rLocked) then begin
    APPON();
    Error(019999,'BA-Fertigung nicht gefunden!');
    RETURN false;
  end;

  Erx # RecLink(700,702,1,_recFirst);   // BA-Kopf holen
  if (Erx>_rLocked) then begin
    APPON();
    Error(019999,'BA-Kopf nicht gefunden!');
    RETURN false;
  end;

  Erx # RecLink(701,441,11,_recFirst);    // Input holen
  if (Erx<=_rLocked) then begin
    vBruderId # BAG.IO.NachID;
  end;
  if (vBruderID=0) then begin
    APPON();
    Error(019999,'BA-Input nicht gefunden!');
    RETURN false;
  end;

//  Erx # RecLink(707,703,10,_RecLast);   // letzte FM holen
//  if (Erx<=_rLocked) then vFM # BAG.FM.Fertigmeldung + 1
//  else vFM # 1;
  vFM # 999;    // 16.12.2021 AH: temporäre Nummer


  Erx # RecLink(200,441,4,_recFirst);   // Material holen


  // Fahren erstellt echt Fertigmeldungen
  if (Bag.P.Aktion = c_BAG_Fahr09) then begin

    RecBufClear(707);
    //BAG.FM.Nummer     # BAG.F.Nummer;

    BAG.FM.Nummer     # myTmpNummer;
    BAG.FM.Position   # BAG.F.Position;
    BAG.FM.Fertigung  # BAG.F.Fertigung;
    BAG.FM.InputBAG   # BAG.IO.Nummer;
    BAG.FM.InputID    # BAG.IO.ID;
    BAG.FM.BruderID   # vBruderID;
    // 14.09.2016 AH
    BAG.FM.Lagerplatz # aLagerplatz;

    BAG.FM.Fertigmeldung  # vFM;
    BAG.FM.Verwiegungart  # Mat.Verwiegungsart;//1;

  //  BAG.FM.Verwiegungart  # Lfs.P.Verwiegungsart;
    BAG.FM.Materialtyp    # Lfs.P.Materialtyp;    // c_IO_Mat;
    BAG.FM.Status         # 1;
  //  BAG.FM.Artikelnr      # Mat.Strukturnr;    // vorherige übernehmen

    "BAG.FM.Stück"        # aStk;
    BAG.FM.Gewicht.Brutt  # aBrutto;
    BAG.FM.Gewicht.Netto  # aNetto;
  /*
    Erx # RecLink(818,707,6,_recfirst); // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
    if (VWa.NettoYN) then
      BAG.FM.Menge          # aNetto
    else
      BAG.FM.Menge          # aBrutto;
  */

  //  BAG.FM.MEH            # 'kg';
  //  BAG.FM.Menge          # aNetto;

  //  BAG.FM.MEH              # BAG.IO.MEH.In;
    BAG.FM.MEH              # BAG.F.MEH;

    if (aMenge<>0.0) then begin
      BAG.FM.MEH2             # aMEH;
      BAG.FM.Menge2           # aMenge;
    end;


    if (BAG.FM.MEH='kg') then
      BAG.FM.Menge          # aNetto
    else if (BAG.FM.MEH='Stk') then
      BAG.FM.Menge          # cnvfi(aStk);
    else if (aMEH=BAG.F.MEH) then
      BAG.FM.Menge          # aMenge;

    BAG.FM.Datum          # aDatum;
    BAG.FM.Bemerkung      # aBem;
    BAG.FM.Werksnummer    # aWerksNr;
    
    // 17.02.2020 AH
    // Beistellungen aufnehmen...
    v441 # RekSave(441);
    FOR Erx # RecLink(441,440,4,_recFirst)
    LOOP Erx # RecLink(441,440,4,_recNext)
    WHILE (2=2) and (Erx<=_rLocked) do begin
      if (Lfs.P.Materialtyp<>c_IO_VPG) or (Lfs.P.Datum.Verbucht<>0.0.0) then CYCLE;
//debug('beistellung KEY441');
      RecbufClear(708);
      BAG.FM.B.Nummer       # BAG.FM.Nummer;
      BAG.FM.B.Position     # BAG.FM.Position;
      BAG.FM.B.Fertigung    # BAG.FM.Fertigung;
      BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
      BAG.FM.B.Artikelnr    # Lfs.P.Artikelnr;
      BAG.FM.B.Art.Adresse  # Lfs.P.Art.Adresse;
      BAG.FM.B.Art.Anschr   # Lfs.P.Art.Anschrift;
      BAG.FM.B.Art.Charge   # Lfs.P.Art.Charge;
      BAG.FM.B.Bemerkung    # '';
      BAG.FM.B.Menge        # Lfs.P.Menge;
      BAG.FM.B.MEH          # Lfs.P.MEH;
      "BAG.FM.Stück"        # "Lfs.P.Stück";
      vLfd # 1;
      REPEAT
        BAG.FM.B.lfdNr       # vLfd;
        Erx # Rekinsert(708,0,'MAN');
        if (erx=_rDeadLock) then begin
          Error(707002,'');
          APPON();
          RETURN false;
        end;
        if (Erx<>_rOK) then vLfd # vLfd + 1;
      UNTIL (erx=_rOK);
      // LFS-Verpackung als verbucht markieren
      Erx # RecRead(441,1,_recLock);
      if (erx=_rOK) then begin
        Lfs.P.Datum.Verbucht # aDatum;
        Erx # RekReplace(441);
      end;
     
      if (erx<>_rOK) or (Lfs_Data:AnAuftragsAufpreis(aDatum)=false) then begin
        Error(707002,'');
        APPON();
        RETURN false;
      end;


    END;
    RekRestore(v441);


    if (BA1_Fertigmelden:Verbuchen(true, n, n, aEtkTxt, true)=false) then begin
      Error(707002,'');
      APPON();
      RETURN false;
    end;

  end;

  // Umlagern setzt nur den Lagerort um
  if (Bag.P.Aktion = c_BAG_Umlager) then begin
    Erx # RecRead(200,1,_RecLock);
    if (erx=_rOK) then begin
      Mat.Lagerplatz        # '';
      Mat.Lageradresse      # Lfs.Zieladresse;
      Mat.Lageranschrift    # Lfs.Zielanschrift;
      Erx # Mat_Data:Replace(_RecUnlock,'MAN');
    end;
    if (Erx <> _rOK) then begin
      Error(707002,'');
      APPON();
      RETURN false;
    end;

    // Reservierung entfernen
    FOR   Erx # RecLink(203,200,13,_RecFirst)
    LOOP  Erx # RecLink(203,200,13,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      if ("Mat.R.Trägertyp"=c_Akt_BAInput) and ("Mat.R.TrägerNummer1"=BAG.IO.Nummer) and
        ("Mat.R.TrägerNummer2"=BAG.IO.ID) then BREAK;
      Erx # RecLink(203,200,13,_recNext);
    END;
    if (Erx<=_rLocked) then
      if (Mat_Rsv_Data:Entfernen()=false) then RETURN false;
  end;


  RunAfx('BAG.FM.Fahr.Mat.Post','');

  APPON();

  RETURN true;
end;


//========================================================================
//  Verwiegung_Art  +ERR
//
//========================================================================
sub Verwiegung_Art(
  aInput    : float;
  aMEHIn    : alpha;
  aOutput   : float;
  aMEHOut   : alpha;
  aOutStk   : int;
  aOutGew   : float;
  aDatum    : date;
  aBem      : alpha;) : logic
local begin
  Erx       : int;
  vFM       : int;
  vBruderID : int;
end;
begin

  APPOFF();
  
  if (Lib_Faktura:Abschlusstest(aDatum) = false) then begin
    APPON();
    Error(001400 ,Translate('Fertigmeldungsdatum') + '|'+ CnvAd(aDatum));
    RETURN false;
  end;

  Erx # RecLink(702,441,9,_recFirst);   // BA-Position holen
  if (Erx>_rLocked) then begin
    APPON();
    Error(019999,'BA-Pos. nicht gefunden!');
    RETURN false;
  end;

  Erx # RecLink(703,441,10,_recFirst);  // BA-Fertigung holen
  if (Erx>_rLocked) then begin
    APPON();
    Error(019999,'BA-Fertigung nicht gefunden!');
    RETURN false;
  end;

  Erx # RecLink(700,702,1,_recFirst);   // BA-Kopf holen
  if (Erx>_rLocked) then begin
    APPON();
    Error(019999,'BA-Kopf nicht gefunden!');
    RETURN false;
  end;

  Erx # RecLink(701,441,11,_recFirst);    // Input holen
  if (Erx<=_rLocked) then begin
    vBruderId # BAG.IO.NachID;
  end;
  if (vBruderID=0) then begin
    APPON();
    Error(019999,'BA-Input nicht gefunden!');
    RETURN false;
  end;

//  Erx # RecLink(707,703,10,_RecLast);   // letzte FM holen
//  if (Erx<=_rLocked) then vFM # BAG.FM.Fertigmeldung + 1
//  else vFM # 1;
  vFM # 999;    // 16.12.2021 AH: temporäre Nummer


  RecBufClear(707);
  BAG.FM.Nummer     # myTmpNummer;
  BAG.FM.Position   # BAG.F.Position;
  BAG.FM.Fertigung  # BAG.F.Fertigung;
  BAG.FM.InputBAG   # BAG.IO.Nummer;
  BAG.FM.InputID    # BAG.IO.ID;
  BAG.FM.BruderID   # vBruderID;

  BAG.FM.Fertigmeldung  # vFM;
  BAG.FM.Verwiegungart  # 0;
  BAG.FM.Materialtyp    # Lfs.P.Materialtyp;
  BAG.FM.Status         # 1;

  // für MATMEH
  "BAG.FM.Stück"        # aOutStk
  if (aMEHIn='Stk') then
    "BAG.FM.Stück"      # cnvif(aInput)
  else if (aMEHOut='Stk') then
    "BAG.FM.Stück"      # cnvif(aOutput);

  BAG.FM.Gewicht.Netto # aOutGew;
  BAG.FM.Gewicht.Brutt # aOutGew;

  if (aOutGew=0.0) then begin
    if (aMEHIn='kg') then
      BAG.FM.Gewicht.Netto  # aInput
    else if (aMEHIn='t') then
      BAG.FM.Gewicht.Netto  # aInput * 1000.0
    else if (aMEHOut='kg') then
      BAG.FM.Gewicht.Netto  # aOutput
    else if (aMEHOut='t') then
      BAG.FM.Gewicht.Netto  # aOutput * 1000.0;

    if (aMEHOut='kg') then
      BAG.FM.Gewicht.Brutt  # aOutput
    else if (aMEHOut='t') then
      BAG.FM.Gewicht.Brutt  # aOutput * 1000.0
    else if (aMEHIn='kg') then
      BAG.FM.Gewicht.Brutt  # aInput
    else if (aMEHIn='t') then
      BAG.FM.Gewicht.Brutt  # aInput * 1000.0;
  end;

  BAG.FM.Menge          # aOutput;
  BAG.FM.MEH            # aMEHOut;
  BAG.FM.Datum          # aDatum;

  // BAG-Bewegung für den Einsatz durchführen...
  RecBufClear(708);
  BAG.FM.B.Nummer       # BAG.FM.Nummer;
  BAG.FM.B.Position     # BAG.FM.Position;
  BAG.FM.B.Fertigung    # BAG.FM.Fertigung;
  BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
  BAG.FM.B.lfdNr        # 1;
  BAG.FM.B.Artikelnr    # Lfs.P.Artikelnr;
  BAG.FM.B.Art.Adresse  # Lfs.P.Art.Adresse;
  BAG.FM.B.Art.Anschr   # Lfs.P.Art.Anschrift;
  BAG.FM.B.Art.Charge   # Lfs.P.Art.Charge;
  BAG.FM.B.Bemerkung    # '';
  BAG.FM.B.Menge        # -aInput;
  BAG.FM.B.MEH          # aMEHIn;
  REPEAT
    Erx # RecRead(708,1,_recTest);
    if (Erx<=_rLocked) then BAG.FM.B.lfdNr # BAG.FM.B.lfdNr + 1;
  UNTIL (Erx>_rLocked);
  Erx # RekInsert(708,0,'AUTO');
  if (erx<>_rOK) then RETURN false;

  if (BA1_Fertigmelden:Verbuchen(n,n,n,0,true)=false) then begin
    Error(707002,'');
    RETURN false;
  end;

  APPON();

  RETURN true;
end;


//========================================================================
//  Abschluss +ERR
//
//========================================================================
sub Abschluss(
  aDat        : date;
  opt aSilent : logic) : logic
begin

  if(BA1_Fertigmelden:AbschlussPos(Lfs.zuBA.Nummer, Lfs.zuBA.Position, aDat, now, aSilent)=false) then
    RETURN false;

  RunAFX('BAG.LFA.Abschluss.Post',Aint(Lfs.zuBA.Nummer)+'/'+Aint(Lfs.zuBA.Position));
  RETURN true;
end;


//========================================================================
//  IstNurAusVersandNr
//========================================================================
sub IstNurAusVersandNr() : int;
local begin
  Erx : int;
  vNr : int;
end;
begin
  RecbufClear(441);
  FOR Erx # RecLink(441,440,4,_recFirst)    // Posten loopen
  LOOP Erx # RecLink(441,440,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lfs.P.Versandpoolnr=0) then RETURN 0;
    Erx # RecLink(651,441,17,_recFirst);    // Versandpos holen
    if (erx>_rMultikey) then CYCLE;
    if (vNr=0) then vNr # Vsd.P.Nummer;
    if (vNr<>Vsd.P.Nummer) then RETURN -1;
  END;

  RETURN vNr;
end;


//========================================================================
//  GesamtFM +ERR
//
//========================================================================
sub GesamtFM(
  aDatum      : date;
  opt aPlatz  : alpha) : logic;
local begin
  Erx     : int;
  v441    : int;
  vNetto  : float;
  vBrutto : float;
  vMenge  : float;
  vLager  : alpha;
  vEtkTxt : int;
end;
begin

  if (aDatum=0.0.0) then aDatum # today;

  vEtkTxt # TextOpen(16);
  
  TRANSON;
  APPOFF();   // 11.12.2019
 
  FOR Erx # RecLink(441,440,4,_recFirst)    // Posten loopen
  LOOP Erx # RecLink(441,440,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    
    if (LFS.P.Datum.Verbucht<>0.0.0) then CYCLE;

    if (LFS.P.Materialtyp<>c_IO_MAT) and (LFS.P.Materialtyp<>c_IO_ART) then begin
      // Fehler!
      TRANSBRK;
      Error(702444,AInt(Lfs.P.Position));
      RETURN false;
    end;

    // Fertigmelden...
    vMenge  # Lfs.P.Menge;
    vNetto  # Lfs.P.Gewicht.Netto;
    vBrutto # Lfs.P.Gewicht.Brutto;
    if (vNetto=0.0) then  vNetto # vBrutto;
    if (vBrutto=0.0) then vBrutto # vNetto;
    Erx # RecRead(441,1,_recunlock);
    
    if (LFS.P.Materialtyp=c_IO_MAT) then begin
      Erx # RecLink(200,441,4,0); // 2017-09-18 TM: NEU / Material lesen, benötigt für korrekten Lagerplatz
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Error(999999,'Mat.'+aint(Lfs.P.Materialnr)+' nicht lesbar');
        RETURN false;
      end;
      
      if (vNetto<>0.0) or (vBrutto<>0.0) then begin
        v441 # RekSave(441);
        // 14.09.2016 AH
        if (BAG.P.ZielVerkaufYN=false) then
          vLager # Mat.Lagerplatz
        else
          vLager  # '';
        if (aPlatz<>'') then vLager # aPlatz;
        if (Verwiegung_Mat("Lfs.P.Stück", vNetto, vBrutto, vMenge, Lfs.P.MEH, aDatum, '', '', vLager, vEtkTxt)=false) then begin
          // Fehler!
          RecBufDestroy(v441);
          TRANSBRK;
          TextClose(vEtkTxt);
          Error(441701,'');
          RETURN false;
        end;
        RekRestore(v441);
        RecRead(441,1,0);
      end;
    end
    else if (LFS.P.Materialtyp=c_IO_ART) then begin   // 03.03.2020 AH
      v441 # RekSave(441);
      if (Verwiegung_Art(Lfs.P.Menge.Einsatz, Lfs.P.MEH.Einsatz, Lfs.P.Menge, Lfs.P.MEH, "Lfs.P.Stück", vBrutto, aDatum, '')=false) then begin
        // Fehler!
        RecBufDestroy(v441);
        TRANSBRK;
        TextClose(vEtkTxt);
        Error(441701,'');
        RETURN false;
      end;
      RekRestore(v441);
      RecRead(441,1,0);
    end;

  END;

  TRANSOFF;
  RunAFX('Lfs.LFA.Data.GesamtFM.Post','');
  APPON();

  if (Set.Installname='BSP') then
    BA1_Fertigmelden:EtkDruckAusTxt(vEtkTxt);
  
  TextClose(vEtkTxt);

  RETURN true;
end;


//========================================================================
//  _ImportFeld
//
//========================================================================
sub _ImportFeld(
  aTxt    : int;
  var aA  : alpha;
  aNr     : int;
  opt aL  : int;
  ) : alpha;
local begin
  vX          : int;
  vA          : alpha;
  vD1,vD2,vD3 : int;
  vDat        : date;
end
begin

  aA # Str_ReplaceAll(aA,'""',strchar(254));
  aA # Str_ReplaceAll(aA,strchar(254),'"');
  aA # Lib_Strings:STRINGS_Win2Dos(aA);

  // spezielle Kontrollen

  case aNr of
    1 : begin // LFS-Nummer
      vX # cnvia(aA);
      if (vX<>Lfs.Nummer) then RETURN ('falsche LFS-Nummer');
    end;

    2 : begin // Datum
      vA # Str_Token(aA, '.', 1);
      vD1 # cnvia(vA);
      vA # Str_Token(aA, '.', 2);
      vD2 # cnvia(vA);
      if (vD1<1) or (vD1>31) then RETURN ('falsches Datum');
      if (vD2<1) or (vD2>12) then RETURN ('falsches Datum');

      vA # Str_Token(aA, '.', 3);
      if (vA='') then RETURN ('falsches Datum');
      vD3 # cnvia(vA);
      if (vD3>0) and (vD3<100) then vD3 # vD3 + 100
      else if (vD3>=2000) then vD3 # vD3 - 1900;
      vDat # Datemake(vD1,vD2,vD3);
      if (vDat=0.0.0) then RETURN ('falsches Datum');

      aA # cnvad(vDat);
    end;

    6 : begin // Gewicht
      if (cnvia(aA)<=0) then RETURN ('falsche Gewicht');
    end;

    7 : begin // Stück
      if (cnvia(aA)<=0) then RETURN ('falsche Stückzahl');
    end;

  end;

  if (aL<>0) then aA # StrCut(aA,1,aL);
  aTxt->TextLineWrite(TextInfo(aTxt,_textLines)+1, aA, _TextLineInsert);

  RETURN '';
end;



//========================================================================
//  _CreateWE
//
//========================================================================
sub _CreateWE(aTxt : int) : logic;
local begin
  Erx     : int;
  vA      : alpha(250);
  vNr     : int;
  vLfd    : int;
  vStk    : int;
  vGew    : float;
  vMenge  : float;
  vGegen  : int;
  vVSBMat : int;
  vZeit   : time;
end;
begin

  Erx # RecLink(702,441, 9,_recFirst);    // BA-Position holen
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(703,441,10,_recFirst);    // BA-Fertigung holen
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(701,703,3,_recFirst);     // Input loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialnr=Lfs.P.Materialnr) then begin
      Erx # 99;
      BREAK;
    end;
    Erx # RecLink(701,703,3,_recNext);
  END;
  if (Erx<>99) then RETURN false;

  RecBufClear(707);
  BAG.FM.Nummer     # BAG.P.Nummer;
  BAG.FM.Position   # BAG.P.Position;
  BAG.FM.Fertigung  # BAG.F.Fertigung;
  BAG.FM.InputBAG   # BAG.P.Nummer;
  BAG.FM.InputID    # BAG.IO.ID;
  BAG.FM.OutputID   # 0;
  BAG.FM.BruderID   # 0;

  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
  if (Erx<200) then begin
    Msg(701012,'',0,0,0);
    RETURN false;
  end;

  Erx # RecLink(501,200,18,_recFirst);  // Bestellpos holen
  If (Erx>_rLocked) then begin
    Msg(701013,'',0,0,0);
    RETURN false;
  end;

  Erx # RecLink(500,501,3,_recFirst);   // Kopf holen
  If (Erx>_rLocked) then begin
    RETURN false;
  end;

  Erx # RecLink(506,200,20,_recFirst);  // Wareneingang holen
  If (Erx>_rLocked) then begin
    Msg(701013,'',0,0,0);
    RETURN false;
  end;

  Ein.E.VSByn       # n;
  Ein.E.EingangYN   # y;
  Ein.E.Materialnr  # 0;


  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // LFSNr

  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Datum
  Ein.E.Eingang_Datum # cnvda(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Dicke
  if (vA<>'') then Ein.E.dicke # cnvfa(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Breite
  if (vA<>'') then Ein.E.Breite # cnvfa(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Länge
  if (vA<>'') then "Ein.E.Länge" # cnvfa(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Gewicht
  if (vA<>'') then begin
    Ein.E.Gewicht # cnvfa(vA);
    Ein.E.Menge           # Ein.E.Gewicht;
    Ein.E.Gewicht.Brutto  # Ein.E.Gewicht;
    Ein.E.Gewicht.Netto   # Ein.E.Gewicht;
  end;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Stück
  if (vA<>'') then "Ein.E.Stückzahl" # cnvia(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // RID
  if (vA<>'') then Ein.E.RID # cnvfa(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // RAD
  if (vA<>'') then Ein.E.RAD # cnvfa(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // CoilNr
  if (vA<>'') then Ein.E.Coilnummer # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // RingNr
  if (vA<>'') then Ein.E.Ringnummer # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Chargennr
  if (vA<>'') then Ein.E.Chargennummer # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Werksnr
  if (vA<>'') then Ein.E.Werksnummer # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // LFSnr.
  if (vA<>'') then Ein.E.Lieferscheinnr # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Bemerkung
  if (vA<>'') then Ein.E.Bemerkung # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Intrastat
  if (vA<>'') then Ein.E.Intrastatnr # vA;
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Erzeuger
  if (vA<>'') then Ein.E.Erzeuger # cnvia(vA);
  vA # TextLineRead(aTxt, 1, _TextLineDelete);  // Ursprungsland
  if (vA<>'') then Ein.E.Ursprungsland # vA;


  // Gegenbuchung vorbereiten...
  vGegen # Ein.E.Eingangsnr;


  // WE anlegen *****************************************************

  "Ein.E.Währung" # "Ein.Währung";
  Wae_Umrechnen(Ein.E.Preis, "Ein.E.Währung", var Ein.E.PreisW1, 1);

  TRANSON;

  Ein.E.Nummer        # Ein.P.Nummer;
  Ein.E.Anlage.User   # gUserName;
  vLfd                # Ein.E.Eingangsnr;
  REPEAT
    Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
    Ein.E.Anlage.Datum  # Today;
    Ein.E.Anlage.Zeit   # Now;
    Erx # RekInsert(506,0,'MAN');
    if (erx=_rDeadLock) then begin
      TRANSBRK;
      Msg(506001,'',0,0,0);
      RETURN false;
    end;
  UNTIL (erx=_rOK);

  vNr               # Ein.E.Eingangsnr;

  // Vorgang buchen
  if (Ein_E_Data:Verbuchen(y)=false) then begin
    TRANSBRK;
    Msg(506001,'',0,0,0);
    RETURN false;
  end;


  // Gegenbuchung------------------------------
  vStk    # "Ein.E.Stückzahl";
  vGew    # Ein.E.Gewicht;
  vMenge  # Ein.E.Menge;
  Ein.E.Eingangsnr # vGegen;
  Erx # RecRead(506,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  vVSBMat # Ein.E.Materialnr;
  PtD_Main:Memorize(506);   // für die Gegenbuchung!!
  "Ein.E.Stückzahl" # "Ein.E.Stückzahl" - vStk;
  Ein.E.Gewicht     # Ein.E.Gewicht     - vGew;
  Ein.E.Menge       # Ein.E.Menge       - vMenge;
  if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  end;
  if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    Ein.E.Menge # Ein.E.Gewicht;
  end;
  if ("Ein.E.Stückzahl"<0) then "Ein.E.Stückzahl" # 0;
  if (Ein.E.Gewicht<0.0) then   Ein.E.Gewicht     # 0.0;
  if (Ein.E.Menge<0.0) then     Ein.E.Menge       # 0.0;
  Erx # RekReplace(506,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    PtD_Main:Forget(506);
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  //   Vorgang buchen
  if (Ein_E_Data:Verbuchen(n)=false) then begin
    PtD_Main:Forget(506);
    TRANSBRK;
    Msg(506001,'',0,0,0);
    RETURN false;
  end;
  PtD_Main:Forget(506);

 if (Ein.E.Eingang_Datum=today) then vZeit # now;
  // Restore
  Ein.E.Nummer      # Ein.P.Nummer;
  Ein.E.Eingangsnr  # vNr;
  Erx # RecRead(506,1,0);
  if (Erx<=_rLocked) and (Ein.E.Materialnr<>0) then begin
    // 22.04.2010 AI Abgang in Bestandsbuch eintragen
    Mat.Nummer # vVSBMat;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then
      if (Mat_Data:Bestandsbuch(-vStk, -vGew, 0.0, 0.0, 0.0, Translate('WE')+' '+aint(Ein.E.Nummer)+'/'+aint(ein.E.Position)+'/'+aint(ein.e.eingangsnr), Ein.E.Eingang_datum, vZeit,'')=false) then begin
        TRANSBRK;
        Msg(506001,'',0,0,0);
        RETURN false;
      end;
//    gSelected # Recinfo(506,_RecID);
  end;
  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  ImportCSVzuVSB
//
//========================================================================
sub ImportCSVzuVSB();
local begin
  Erx     : int;
  vOldFoc : int;
  vOldVar : int;

  vBuf441 : int;
  vName   : alpha(500);
  vTxt    : int;

  vFile   : int;
  vMax    : int;
  vDia    : int;
  vHdl    : int;
  vA      : alpha(4000);
  vB      : alpha(250);
  vAnz    : int;
  vX      : int;

  vNetto  : float;
  vBrutto : float;
  vBem    : alpha;
  vDatum  : date;
  vLager  : alpha;
end;
begin


  if (Lfs.Datum.Verbucht<>0.0.0) or (Lfs.zuBA.Nummer=0) or (Lfs.P.zuBA.Nummer=0) or (Lfs.P.Materialtyp<>c_IO_VSB) then RETURN;

  Erx # RecLink(702,441, 9,_recFirst);    // BA-Position holen
  if (Erx>_rLocked) then RETURN;

  Erx # RecLink(703,441,10,_recFirst);    // BA-Fertigung holen
  if (Erx>_rLocked) then RETURN;

  Erx # RecLink(701,703,3,_recFirst);     // Input loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialnr=Lfs.P.Materialnr) then begin
      Erx # 99;
      BREAK;
    end;
    Erx # RecLink(701,703,3,_recNext);
  END;
  if (Erx<>99) then RETURN;

  RecBufClear(707);
  BAG.FM.Nummer     # BAG.P.Nummer;
  BAG.FM.Position   # BAG.P.Position;
  BAG.FM.Fertigung  # BAG.F.Fertigung;
  BAG.FM.InputBAG   # BAG.P.Nummer;
  BAG.FM.InputID    # BAG.IO.ID;
  BAG.FM.OutputID   # 0;
  BAG.FM.BruderID   # 0;


  // Datei auswählen
  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');
  if (vName='') then RETURN;

  If (Msg(441001,vName+'|'+AInt(Lfs.P.Materialnr),_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;


  // VORLAUF****************************************************************

  vFile # FSIOpen(vName, _FsiStdRead );
  if (vFile<=0) then begin
    Msg(999999, Translate('Datei nicht lesbar:')+' '+vName ,_WinIcoError,0,0);
    RETURN;
  end;

  vTxt # TextOpen(3);

  vMax # FsiSize(vFile);

  // Öffnen des Dialoges
  vOldFoc # Winfocusget();
  vOldVar # VarInfo(Windowbonus);
  vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Lese aus Exceldatei')+' '+vName;
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # vMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter, gMDI);
  end;

  /* Überschrift lesen */
  FSIMark(vFile, 10);
  FSIRead(vFile, vA);
  vA # Str_ReplaceAll(vA,'""',strchar(254));
  vA # Str_ReplaceAll(vA,strchar(254),'"');

  /* Satz lesen */
  FSIMark(vFile, 59); // Semikolon

  vAnz # 0;
  FSIRead(vFile, vA);

  // neue Zeile da?
  WHILE (vA<>'') do begin
    inc(vAnz);
    if (vDia<>0) then $Progress->wpProgressPos # FsiSeek(vFile);

    // LFS-Nummer
    vB # _ImportFeld(vTxt, var vA, 1);
    if (vB<>'') then BREAK;

    // Datum
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 2);
    if (vB<>'') then BREAK;

    // Dicke
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 3);
    if (vB<>'') then BREAK;

    // Breite
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 4);
    if (vB<>'') then BREAK;

    // Länge
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 5);
    if (vB<>'') then BREAK;

    // Gewicht
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 6);
    if (vB<>'') then BREAK;

    // Stück
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 7);
    if (vB<>'') then BREAK;

    // RID
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 8);
    if (vB<>'') then BREAK;

    // RAD
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 9);
    if (vB<>'') then BREAK;

    // CoilNr.
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 10 , 16);
    if (vB<>'') then BREAK;

    // RingNr.
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 11, 16);
    if (vB<>'') then BREAK;

    // ChargenNr.
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 12, 16);
    if (vB<>'') then BREAK;

    // Werksnr.
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 13, 16);
    if (vB<>'') then BREAK;

    // LFSNr.
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 14, 16);
    if (vB<>'') then BREAK;

    // Bemerkung
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 15, 32);
    if (vB<>'') then BREAK;

    // Intrastat
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 16, 16);
    if (vB<>'') then BREAK;

    // Erzeuger
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 17);
    if (vB<>'') then BREAK;

    // Ursprungsland
    FSIMark(vFile, 13);
    FSIRead(vFile, vA);
    vB # _ImportFeld(vTxt, var vA, 18, 3);
    if (vB<>'') then BREAK;

    FSIMark(vFile, 10);
    FSIRead(vFile, vA);
    FSIMark(vFile, 59);   // Semikolon

    FSIRead(vFile, vA);   // nächste Zeile
  END;
  FSIClose(vFile);
  if (vDia<>0) then begin
    vDia->WinClose();
    vOldFoc->WinFocusSet(true);
    VarInstance(Windowbonus, vOldVar);
  end;
  if (vB<>'') then begin
    TextClose(vTxt);
    Msg(999999,vB+' in Zeile '+AInt(vAnz),0,0,0);
    RETURN;
  end;


  // WARENEINGANG BUCHEN****************************************************
  vBuf441 # RekSave(441); // Lfs-Pos merken
  FOR vX # 1 LOOP inc(vX) WHILE (vX<=vAnz) do begin

    vA # TextLineRead(vTxt, 2,0);    // Datum
    vDatum # cnvda(vA);
    vA # TextLineRead(vTxt, 15,0);   // Bemerkung
    vBem    # StrCut(vA,1,32);

    RecBufCopy(vBuf441,441);
    if (_CreateWE(vTxt)=false) then BREAK;

    // BA holen
    BAG.Nummer      # BAG.FM.Nummer;
    RecRead(700,1,0);

    // BA-Position holen
    BAG.P.Nummer    # BAG.FM.Nummer;
    BAG.P.Position  # BAG.FM.Position;
    RecRead(702,1,0);

    Erx # RecLink(200,506,8,_recFirst);   // Material holen
    if (Erx>_rLocked) then RETURN;

    if (BA1_Fertigmelden:ErzeugeMatAusVSB()=false) then BREAK;

    BA1_P_Data:ErrechnePosRek();


    // Sofort FM **********************
    vNetto  # Lfs.P.Gewicht.Netto;
    vBrutto # Lfs.P.Gewicht.Brutto;
    if (vNetto=0.0) then vNetto   # vBrutto;
    if (vBrutto=0.0) then vBrutto # vNetto;

    // 14.09.2016 AH
    if (BAG.P.ZielVerkaufYN=false) then
      vLager # Mat.Lagerplatz
    else
      vLager  # '';

    if (Verwiegung_Mat("Lfs.P.Stück", vNetto, vBrutto, Lfs.P.Menge, Lfs.P.MEH, vDatum,'','', vLager)=false) then BREAK;
    Erx # RecRead(441,1,_reclock);
    if (erx=_rOK) then begin
      Lfs.P.Bemerkung # vBem;
      Erx # RekReplace(441,_recUnlock,'AUTO');
    end;

  END;
  RekRestore(vBuf441);

  TextClose(vTxt);

  if (vX<=vAnz) then begin
    Msg(999999,'Abbruch bei Zeile '+AInt(vX),0,0,0);
    ErrorOutput;
    RETURN;
  end;

  ErrorOutput;

  Msg(999998,'',0,0,0);

end;


//========================================================================
//  Storniere
//      + Error
//========================================================================
sub Storniere() : logic;
local begin
  Erx     : int;
  vBuf700 : handle;
  vBuf701 : handle;
  vBuf702 : handle;
  vBuf703 : handle;
  vBuf707 : handle;
  vGew    : float;
  vA      : alpha;
  vOk     : logic;

  vVK     : logic;
end;
begin

  if (Lfs.P.Datum.Verbucht=0.0.0) then RETURN false;
  if (Lfs.P.Materialnr=0) then RETURN false;
  if (Lfs.P.zuBA.Nummer=0) then RETURN false;

  Erx # RecLink(702,441,9,_recFirst);   // BA-Pos holen
  if (Erx>_rLocked) then RETURN false;
  Erx # RecLink(700,702,1,_RecFirst);   // BA-Kopf holen
  if (Erx>_rLocked) then RETURN false;
  Erx # RecLink(701,441,11,_recFirst);  // BA-Input holen
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(707,701,12,_recfirst);  // Fertigmeldugnen loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.FM.Materialnr=Lfs.P.Materialnr) then BREAK;
    Erx # RecLink(707,701,12,_recNext);
  END;
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(200,441,4,_recFirst);   // Material holen
  if (Erx>_rLocked) then RETURN false;
  if (Mat.VK.Rechnr<>0) then RETURN false;

  if (Lfs.P.Auftragsnr<>0) and (Lfs.Kundennummer<>0) then begin
    Erx # RecLink(401,441,5,_RecFirst);   // Auftragspos holen
    if (Erx>_rLocked) then RETURN false;
    Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
    if (Erx>_rLocked) then RecBufClear(835);
    if (AAr.KonsiYN=n) then vVK # y;
  end;

  if (vVK) and (("Mat.Löschmarker"<>'*') or (Mat.Ausgangsdatum=0.0.0)) then RETURN false;



  TRANSON;

  // Verkaufte KArte wieder aktivieren...
  if (vVK) then begin
    Erx # RecRead(200,1,_recLock);
    if (Erx=_rOK) then begin
      Mat_Data:SetLoeschmarker('');
      Mat.Ausgangsdatum   # 0.0.0;
      Mat.VK.Kundennr     # 0;
      Mat.Auftragsnr      # 0;
      Mat.Auftragspos     # 0;
      Mat.KommKundennr    # 0;
      Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;


  // Mataktion löschen
  RecBufClear(204);
  Mat.A.AktionsTyp  # c_Akt_LFS;
  Mat.A.Aktionsnr   # Lfs.P.Nummer;
  Mat.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(204,2,0);
  if (Erx=_rOK) or (Erx=_rMultikey) then begin
    Erx # RekDelete(204,0,'AUTO');
    if (Erx<>_rOK) then begin
//        Error(010017, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      TRANSBRK;
      RETURN false;
    end;
  end;

  // ggf. Auftrags-Aktion löschen...
  RecBufClear(404);
  Auf.A.AktionsTyp  # c_Akt_LFS;
  Auf.A.Aktionsnr   # Lfs.P.Nummer;
  Auf.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(404,2,0);     // bisherige Aktion suchen...
  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=c_Akt_LFS) and   // gibts schon?
      (Auf.A.Aktionsnr=Lfs.P.Nummer) and
      (Auf.A.AktionsPos=Lfs.P.Position) then begin
    if (Auf_A_Data:Entfernen()=false) then begin
//        Error(010019, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      TRANSBRK;
      RETURN false;
    end;
  end;  // Auftrag anpassen
  // Mataktion löschen
  RecBufClear(204);
  Mat.A.AktionsTyp  # c_Akt_VLDAW;
  Mat.A.Aktionsnr   # Lfs.P.Nummer;
  Mat.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(204,2,0);
  if (Erx=_rOK) or (Erx=_rMultikey) then begin
    Erx # RekDelete(204,0,'AUTO');
    if (Erx<>_rOK) then begin
//        Error(010017, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      TRANSBRK;
      RETURN false;
    end;
  end;

  // ggf. Auftrags-Aktion löschen...
  RecBufClear(404);
  Auf.A.AktionsTyp  # c_Akt_VLDAW;
  Auf.A.Aktionsnr   # Lfs.P.Nummer;
  Auf.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(404,2,0);     // bisherige Aktion suchen...
  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=c_Akt_VLDAW) and   // gibts schon?
      (Auf.A.Aktionsnr=Lfs.P.Nummer) and
      (Auf.A.AktionsPos=Lfs.P.Position) then begin
    if (Auf_A_Data:Entfernen()=false) then begin
//        Error(010019, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      TRANSBRK;
      RETURN false;
    end;
  end;  // Auftrag anpassen

  // LFS-Position löschen
  Erx # RekDelete(441,0,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  if (Ba1_FM_Data:Entfernen()=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    TRANSBRK;
    Error(701010,'');
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;

end;


//========================================================================
//  MeldeWEaufVSB
//    Ein.E  (506) muss geladen sein !!!
//    BAG.FM (707) muss geladen sein !!!
//    +ERR
//========================================================================
Sub MeldeWEaufVSB(
  aMatVSB     : int;
  aErsetzen   : logic;
  aVSBKillen  : logic;
  aAutoFM     : logic;
) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vGewN   : float;
  vGewB   : float;
  vLager  : alpha;
end;
begin

  // BA holen
  BAG.Nummer      # BAG.FM.Nummer;
  RecRead(700,1,0);

  // BA-Position holen
  BAG.P.Nummer    # BAG.FM.Nummer;
  BAG.P.Position  # BAG.FM.Position;
  RecRead(702,1,0);
  Erx # RecLink(200,506,8,_recFirst);   // Material holen
  if (Erx>_rLocked) then begin
    Error(506003,'');
    RETURN false;;
  end;

  if (aErsetzen) then begin
    vOK # BA1_Fertigmelden:ErzeugeMatAusVSB_genau1();

    if (vOK) and (aVSBKillen) then begin
//  15.09.2016 AH:
//      Mat.Nummer # aMatVSB;
//      RecRead(200,1,0);
      Erx # Mat_Data:Read(aMatVSB);
      if (Erx=200) then begin
        Erx # RecLink(501,200,18,_recFirst);  // Bestellpos holen
        If (Erx>_rLocked) then begin
          Error(701013,'');
          RETURN false;
        end;
        Erx # RecLink(500,501,3,_recFirst);   // Bestellkopf holen
        Erx # RecLink(506,200,20,_recFirst);  // Wareneingang holen
        If (Erx>_rLocked) then begin
          error(701013,'');
          RETURN false;
        end;

        // nur wenn nicht eh schon gelöscht ist...
        if ("Ein.E.Löschmarker"='') then
          if (Ein_E_Data:StornoVSBMat()=false) then begin
//        ErrorOutput;
          RETURN false;
        end;

        RunAfx('BAG.LFA.WEaufVSB','');

      end;
    end;

  end
  else begin
    vOK # BA1_Fertigmelden:ErzeugeMatAusVSB();
  end;
  if (vOK=false) then begin
//    ErrorOutput;
    RETURN false;
  end;

  BA1_P_Data:ErrechnePosRek();

  if (aAutoFM) then begin
    RecRead(440,1,0);
    RecRead(441,1,0);
    vGewN # Lfs.P.Gewicht.Netto;
    vGewB # Lfs.P.Gewicht.Brutto;
    if (vGewN=0.0) then vGewN # vGewB;
    if (vGewB=0.0) then vGewB # vGewN;
    // 14.09.2016 AH
    if (BAG.P.ZielVerkaufYN=false) then begin
      Erx # RecLink(200,441,4,_recFirst);   // Material holen
      vLager # Mat.Lagerplatz;
    end
    else
      vLager  # '';
    if (Lfs_LFA_Data:Verwiegung_Mat("Lfs.P.Stück", vGewN, vGewB, 0.0, '', today, '', '', vLager)=false) then begin
      // Fehler!
//      TRANSBRK;
      Error(441701,'');
      RETURN false;
    end;
  end

  RETURN true;
end;

//========================================================================