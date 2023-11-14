@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_FM_Messen
//                  OHNE E_R_G
//  Info
//
//
//  07.05.2021  AH  Erstellung der Prozedur
//  11.10.2021  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

define begin
end;

//========================================================================
//  ChooseEchtenOutput
//
//========================================================================
sub ChooseEchtenOutput() : logic;
local begin
  Erx   : int;
  vHdl  : int;
  vText : alpha(200);
  vTmp  : int;
  v707  : int;
  vDL   : int;
end;
begin

  // 19.05.2021 AH
  if (RunAFX('BA1.FM.Messen.ChooseOutput','')<>0) then RETURN (AfxRes=_rOK);

  // bei Prüfen keine Fertigungsauswahl!
  if (BAG.P.Aktion=c_BAG_Check) or (BAG.P.Aktion=c_BAG_Paket) then begin
    Erx # RecLink(701,702,18,_RecFirsT);  // Output holen
    if (Erx>_rLocked) then RETURN false;
    BAG.FM.OutputID   # BAG.IO.ID;
    BAG.FM.Fertigung  # BAG.IO.VonFertigung;
    RETURN true;
  end;


  vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('BA1.FM.O.Auswahl'),_WinOpenDialog);

  vDL # Winsearch(vHdl,'ZL.BAG.IO.Auswahl');

  Lib_GuiCom:RecallList(vDL);     // Usersettings holen

//  if ("BAG.P.Typ.1In-1OutYN") or ("BAG.P.Typ.1In-yOutYN") then
//    vDL->wpcustom # AInt(BAG.FM.InputID);
//  BAG.IO.Nummer # BAG.FM.Nummer;
//  BAG.IO.ID     # BAG.FM.InputID;
//  Erx # RecRead(701,1,0);
//  if (Erx<=_rLocked) then begin
//    if (BAG.IO.BruderID<>0) then
//      vDL->wpcustom # AInt(BAG.IO.BruderID);
//  end;

  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)+' '+BAG.P.Bezeichnung;
  vTmp # Winsearch(vHdl,'LB.Info2');
  if (BAG.IO.Materialtyp=c_IO_Mat) then begin
    vText # Translate('Einsatz:')+' '+Translate('Mat.')+AInt(BAG.IO.Materialnr)+' '+ANum(BAG.IO.Dicke,Set.Stellen.Dicke);
    if (BAG.IO.Breite<>0.0) or ("BAG.IO.Länge"<>0.0) then
      vText # vText + ' x '+ANum(BAG.IO.Breite,Set.Stellen.Breite);
    if ("BAG.IO.Länge"<>0.0) then
      vText # vText + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
    vText # vText + '   '+ANum(BAG.IO.Plan.Out.Meng,"Set.Stellen.Menge")+BAG.IO.MEH.Out;
    vTmp->wpcaption # vText;
  end;
  vTmp # Winsearch(vHdl,'LB.Info3');
  vTmp->wpcaption # Translate('Fertigung wählen:');
  v707 # RekSave(707);    // 13.10.2017

  vHdl->WinDialogRun(_WinDialogCenter,gMDI);    // DIALOG ANZEIGEN

  Lib_GuiCom:RememberList(vDL);     // Usersettings holen

  WinClose(vHdl);
  RekRestore(v707);
  if (gSelected=0) then RETURN false;
  RecRead(701,0,_RecId,gSelected);
  gSelected # 0;

//  if (BAG.IO.Materialtyp<>c_IO_BAG) then begin
//    Msg(701009,'',0,0,0);
//    RETURN false;
//  end;

//  if (BAG.IO.Plan.In.Stk<=BAG.IO.Ist.In.Stk) and
//    ((BAG.F.Fertigung<>999) or (BAG.IO.Plan.In.Stk<>0)) then begin
//    Erx # Msg(701015,'',_WinIcoQuestion, _WinDialogYesNo, 2);
//    if (Erx<>_WinIdYes) then RETURN false;
//  end;
//  BAG.FM.OutputID   # BAG.IO.ID;
//  BAG.FM.Fertigung  # BAG.IO.VonFertigung;

  RETURN true;
end;


//========================================================================
//  FM
//========================================================================
sub FM() : logic
local begin
  Erx : int;
end;
begin
//lib_Debug:StartBlueMode();

  Erx # RecLinkInfo(707,702,5,_recCount);   // gibts schon FMS?
  if (Erx=0) then begin                     // NEIN -> Alles erst mal Theo FM
    // Position lesen
    if ("BAG.P.Typ.xIn-yOutYN") then begin
      Error(702033,'');
      RETURN false;
    end;
    RecBufClear(707);
    BAG.FM.Nummer   # BAG.Nummer;
    BAG.FM.Position # BAG.P.Position;

    if (BA1_Fertigmelden:FMTheorie(BAG.FM.Nummer, BAG.FM.Position, today, y, y, n, c_Status_BAGfertUnklar)=false) then RETURN false;
    RecBufClear(701);
    RecBufClear(200);
  end;
/**
  if (ChooseEchtenOutput()=false) then begin
    RETURN false;
  end;

  Erx # RecLink(707,701,18,_recFirst);    // FM dazu holen
  RETURN true;
**/

// per EDLIST
  BA1_FM_Main:Start(BAG.P.Nummer, BAG.P.Position, 1, 0, '', true, true);

  RETURN false;
end;


//========================================================================
//========================================================================
sub QsFreigabe() : logic
local begin
  Erx         : int;
  v707        : int;
  vHdl        : int;
  vStatus     : int;
  vBuf702     : int;
  vNextAktion : alpha;
  vBuf100     : int;
  vBruder     : int;
end;
begin

  // Restore Bruder
  vBruder # RecBufCreate(701);
  vBruder->BAG.IO.Nummer # BAG.FM.Nummer;
  vBruder->BAG.IO.ID     # BAG.FM.BruderID;
  Erx # RecRead(vBruder,1,0);

  vStatus # c_Status_BAGOutput;
  if (vBruder->BAG.IO.NachBAG<>0) then begin     // Weiterbearbeitung?
    vBuf702 # RekSave(702);

    Erx # RecLink(702,vBruder,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      vNextAktion # BAG.P.Aktion;
      vStatus # BA1_Mat_Data:StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr);
    end;
    RekRestore(vBuf702);

    RecRead(701,1,_recLock);
    BAG.IO.NachBAG        # vBruder->BAG.IO.NachBAG;
    BAG.IO.NachPosition   # vBruder->BAG.IO.NachPosition;
    BAG.IO.NachFertigung  # vBruder->BAG.IO.NachFertigung;
    BAG.IO.NachID         # vBruder->BAG.IO.NachID;
    RekReplace(701);
  end;
  RecBufDestroy(vBruder);

  RecRead(200,1,_recLock);
  Mat_Data:SetStatus(vStatus);      // auf fertig setzen
  if (Bag.F.PlanSchrottYN) then begin
    Mat_Data:SetLoeschmarker('');             // Nicht löschen
    Mat_Data:SetStatus(c_Status_BAGSchrott);  // Status Schrott
  end;
  Mat_Data:Replace(_recUnlock,'AUTO');

  // evtl. Material reservieren?
  if (BA1_P_Data:ReservierenStattStatus(vNextAktion,703)) then begin
    // Reservieruen für FAHREN NACH Anlage weiter unten....
  end
  else if (BAG.FM.Status=1) and (BAG.F.ReservierenYN) and (BAG.F.Auftragsnummer=0) and (BAG.P.Aktion<>c_BAG_Fahr09) then begin
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    "Mat.R.Trägertyp"     # '';
    "Mat.R.TrägerNummer1" # 0;
    "Mat.R.TrägerNummer2" # 0;
    Mat.R.Kundennummer    # "BAG.F.ReservFürKunde";
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,203,3,_recFirst); // Kunde holen
    Mat.R.KundenSW        # vBuf100->Adr.Stichwort;
    RecBufDestroy(vBuf100);
    Mat.R.Auftragsnr      # BAG.F.Auftragsnummer;
    Mat.R.AuftragsPos     # BAG.F.AuftragsPos;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      Error(707104,AInt(Mat.Nummer));
      RETURN false;
   end;
  end;

  if (BAG.FM.Status=1) and (BA1_P_Data:ReservierenStattStatus(vNextAktion,703)) then begin
    // FAHR-Reservierung neu anlegen ---------------------------------------
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    // für MATMEH
    Mat.R.Menge           # Mat.Bestand.Menge;

    Mat.R.Bemerkung       # vNextAktion;
    "Mat.R.Trägertyp"     # c_Akt_BAInput;
    "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
    "Mat.R.TrägerNummer2" # BAG.IO.ID;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      Error(707106,'');
      RETURN false;
    end;
  end;

  v707 # RekSave(707);

  // nachfolgender LFA? dann LFS updaten,,,
  // bzw. VERSAND? dann VSP updaten...
  if (BAG.FM.Status=1) and (BAG.IO.NachBAG<>0) then begin
    vBuf702 # RekSave(702);
    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      if (BAG.P.Aktion=c_BAG_Fahr) then begin
        // Output aktualisieren
        if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
          Error(707109,AInt(Bag.P.Nummer)+'/'+AInt(Bag.P.Position));
          RETURN false;
        end;
      end;

    end;
    RekRestore(vBuf702);
  end;

  RekRestore(v707);

  RETURN true;
end;


//========================================================================
sub UpdateMaterial() : logic
local begin
  Erx       : int;
  vAuflageA : float;
  vAuflageB : float;
end
begin
  if (BAG.FM.Materialnr=0) then RETURN true;
  Erx # RecLink(200,707,7,_recFirst|_reclock);    // mmaterial holen
  if (Erx>_rLocked) then RETURN false;

  if Mat.Dicke.von !=0.0 and BAG.FM.Dicke.1 =0.0 then BAG.FM.Dicke.1 # Mat.Dicke.von;
  if Mat.Dicke.bis !=0.0 and BAG.FM.Dicke.2 =0.0 then BAG.FM.Dicke.2 # Mat.Dicke.bis;

  Mat.Dicke             # BAG.FM.Dicke;
  Mat.Dickentol         # BAG.F.DickenTol;
  BA1_Fertigmelden:MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
  Mat.Breite            # BAG.FM.Breite;
  Mat.Breitentol        # BAG.F.BreitenTol;
  BA1_Fertigmelden:MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
  "Mat.Länge"           # "BAG.FM.Länge";
  "Mat.Längentol"       # "BAG.F.Längentol";
  BA1_Fertigmelden:MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
  Mat.RID # BAG.FM.RID;
  Mat.RAD # BAG.FM.RAD;

  // bisherige Ausführungen löschen...
  FOR  Erx # RecLink(201,200,11,_recFirst)
  LOOP Erx # RecLink(201,200,11,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    RekDelete(201);
  END;

  // hier eingreifen
  vAuflageA  # cnvfa(BAG.FM.AusfOben);
  vAuflageB # cnvfa(BAG.FM.AusfUnten)

  // Ausführung kopieren
  FOR Erx # RecLink(705, 707, 13, _recFirst)
  LOOP Erx # RecLink(705, 707, 13, _recNext)
  WHILE (Erx<=_rLocked) do begin
    RecBufClear(201);
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.Seite        # BAG.AF.Seite;
    Mat.AF.lfdNr        # BAG.AF.lfdNr;
    Mat.AF.ObfNr        # BAG.AF.ObfNr;
    Mat.AF.Bezeichnung  # BAG.AF.Bezeichnung;

    if (Mat.AF.Seite ='1' and Mat.AF.ObfNr =1) then
      Mat.AF.Zusatz # cnvaf(vAuflageA);
    else if (Mat.AF.Seite ='2' and Mat.AF.ObfNr =1) then
      Mat.AF.Zusatz # cnvaf(vAuflageB);
    else
    Mat.AF.Zusatz       # BAG.AF.Zusatz;

    Mat.AF.Bemerkung    # BAG.AF.Bemerkung;
    "Mat.AF.Kürzel"     # "BAG.AF.Kürzel";
    REPEAT
      Erx # RekInsert(201,0,'AUTO');
      if (Erx<>_rOK) then Mat.AF.lfdNr # Mat.AF.lfdNr + 1;
    UNTIL (Erx=_rOK);
  END;

  // Analyse...
  Mat.Analysenummer2 # BAG.FM.Analysenummer;
  Lys_Data:CopyToMat();

  RekReplace(200);
  RETURN true;
end


//========================================================================
//
//========================================================================
sub Save() : logic
local begin
  vNextAktion : alpha;
  vBruder     : int;
  vStatus     : int;
  vBuf702     : int;
  vStatusAlt  : int;
  Erx         : int;
end;
begin
//debugx('FM:'+anum(BAG.FM.Menge,0));
  TRANSON;

// ANALYSE
  if (BAG.FM.Analysenummer=0) then begin
    Lys.K.Datum           # BAG.FM.Datum;
    Lys.K.Quelle          # Translate('Fertigmeldung');
    "Lys.K.Trägernummer1" # BAG.FM.Nummer;
    "Lys.K.Trägernummer2" # BAG.FM.Position;
    "Lys.K.Trägernummer3" # BAG.FM.Fertigung;
    "Lys.K.Trägernummer4" # BAG.FM.Fertigmeldung;
    if (Lys_Data:Anlegen()=false) then begin
      TRANSBRK;
      RETURN false;
    end;
    BAG.FM.Analysenummer # Lys.K.Analysenr;
  end
  else begin
    RecRead(231,1,_recLock|_recNoLoad);
    RekReplace(231);
  end;

  vStatusAlt # ProtokollBuffer[707]->BAG.FM.Status;

  // Material ändern...
  if (BAG.FM.Materialnr<>0) then begin
    if (UpdateMaterial()=false) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;

  Erx # RekReplace(707,_recUnlock,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  PtD_Main:Compare(707);

  if (BAG.FM.Status=c_status_Frei) and (vStatusalt<>c_Status_Frei) then begin
    Erx # RecLink(701,707,8,_recFirst);   // Output holen
    if (QsFreigabe()=false) then begin
      TRANSBRK;
      ErrorOutput;
      RETURN false;
    end;
  end
  else if (BAG.FM.Status=c_Status_BAGfertSperre) and (vStatusAlt<>c_Status_BAGFertSperre) then begin
//    Erx # RecLink(701,707,5,_recFirst);   // BAG-Output holen
//    if (BA1_FM_Data:SetSperre(TRUE)=false) then begin
//      TRANSBRK;
//      ErrorOutput;
//      RETURN false;
//    end;
    RecRead(200,1,_recLock);
    Mat_Data:SetStatus(c_Status_BAGfertSperre);    // Sperr-Status
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(200106,AInt(BAG.FM.Materialnr));
      ErrorOutput;
      RETURN false;
    end;
  end;

  TRANSOFF;

  RETURN true;
end;

//========================================================================
