@A+
//===== Business-Control =================================================
//
//  Prozedur    Erl_Data
//
//  Info        ohne E_R_G
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  27.04.2010  AI  Stornieren beachtet Fibu-Datum
//  29.09.2010  AI  Stornieren von Eingangsrechnungen legt Sotrno-ER an
//  09.06.2011  ST  P:1326/157 StornoVerbuchungsdatum Vorbelegung mit RE Datum, anstatt "today"
//  22.01.2013  AI  Storno unterscheidet für Statistik GUT, BEL, RE
//  11.09.2013  ST  Gelangensbestätigung hinzugefügt (1427/49)
//  26.02.2014  AH  Storno werden ggf. informativ in die Auftragsaktionsliste geschrieben
//  31.07.2014  ST  Prüfung auf Abschlussdatum für Stornodatum hinzugefügt Projekt 1326/395
//  15.08.2016  AH  Erlöskorrektur beachten
//  21.09.2018  AH  AFX "Erl.Stornieren"
//  03.03.2020  AH  Neu: "Insert", "Replace"
//  13.03.2020  AH  "ParseDiffText" aus "Erl_Data"
//  06.05.2020  AH  Protokollierung der Löschung
//  27.07.2021  AH  ERX
//  23.02.2022  AH  Storno aktiviert eine Auftragspos korrekt
//  2022-06-23  AH  FIX: Storno toggelt nicht, sondern entfernt nur "*" am Auftrag
//  2022-08-17  AH  Neu: AFX "Erl.K.Insert.Pre", ""Erl.K.Replace.Pre"
//
//  Subprozeduren
//    sub Stornieren(): logic
//    sub DruckSammelGelangen()
//    sub DruckSammelGelangenAusSel()
//    sub DruckSammelGelangenAusSelEvtClicked (aEvt : event; )  : logic
//    sub Replace451(opt aLock : int; opt aGrund : alpha; opt aMatNr : int) : int;
//    sub Insert451(opt aLock : int; opt aGrund : alpha) : int;
//    sub Replace(opt aLock   : int; opt aGrund  : alpha;) : int;
//    sub Insert(opt aLock   : int; opt aGrund  : alpha;) : int;
//    sub ParseDiffText(aTxt : int; aAlsEK : logic; aGrund : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

declare Replace(opt aLock   : int; opt aGrund  : alpha;) : int;
declare Insert(opt aLock   : int; opt aGrund  : alpha;) : int;

//========================================================================
//  Stornieren
//
//========================================================================
sub Stornieren() : logic;
local begin
  Erx       : int;
  vStornoNr : int;
  vBemerk   : alpha;
  vReDat    : date;
  vTyp      : alpha;
  vEREok    : logic;
  vOPAblage : logic;
  vAufnr    : int;
  vAufPos   : int;
  vI        : int;
  vNr       : int;
end;
begin
  if (Rechte[Rgt_Erl_Stornieren]=n) then RETURN false;

  // 21.09.2018 AH:
  vI # RunAFX('Erl.Stornieren', '');
  if (vI<>0) then begin
    if (vI<0) then RETURN (AfxRes=_rOK);
    if (vI>0) and (AfxRes<>_rOK) then RETURN false;
  end;


  If (Erl.StornoRechNr<>0) then RETURN false;

  if (Lib_Faktura:AbschlussTest(Erl.Rechnungsdatum)=n) then RETURN false;

  if (Erl.Rechnungstyp<>c_Erl_VK) and (Erl.Rechnungstyp<>c_Erl_SammelVK) and
    (Erl.Rechnungstyp<>c_Erl_BOGUT) and
    (Erl.Rechnungstyp<>c_Erl_REKOR) and (Erl.Rechnungstyp<>c_Erl_Bel_KD) and
    (Erl.Rechnungstyp<>c_Erl_Gut) and (Erl.Rechnungstyp<>c_Erl_Bel_LF) then begin
    todo('Storno dieses Rechnungstyps');
    RETURN false;
  end;

  if (Erl.FibuDatum=0.0.0) then begin
    if (Msg(450000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidNo) then RETURN false;
    end
  else begin
    if (Msg(450001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidNo) then RETURN false;
  end;

  if (EKK_Data:BereitsVerbuchtYN(450)) then begin
    Msg(450009,'',0,0,0);
    RETURN false;
  end;


  // Datum für Storno abfragen
  // ST 2011-06-09: P:1326/157 Vorbelegung mit RE Datum, anstatt "today"
  if (Dlg_Standard:Datum('Verbuchungsdatum',var vReDat, Erl.Rechnungsdatum)=false) then RETURN false;
  if (vReDat=0.0.0) then RETURN false;

  if (Lib_Faktura:AbschlussTest(vReDat) = false) then begin
    Msg(001400 ,Translate('Verbuchungsdatum') + '|'+ CnvAd(vReDat),0,0,0);
    RETURN false;
  end;

  TRANSON;

  // Nummer holen
  // ggf. ersetzende Nummernvergabe aufrufen, sonst Standard mit Settings   2022-11-08  AH
  vNr # Erl.Rechnungsnr;
  if (RunAFX('Fakt.Nummernvergabe','Storno') = 0) then begin
    if ("Set.Wie.GutBel#SepYN") and
      ((Erl.Rechnungstyp=c_Erl_BOGUT) or (Erl.Rechnungstyp=c_ERL_REKOR) or (Erl.Rechnungstyp=c_ERL_BEL_KD) or
       (Erl.Rechnungstyp=c_ERL_Gut) or (Erl.Rechnungstyp=c_ERL_BEL_LF)) then
      vStornoNr # Lib_Nummern:ReadNummer('Storno-Gut/Bel');
    else
      vStornoNr # Lib_Nummern:ReadNummer('Storno-Rechnung');
  end
  else begin
    vStornoNr # Erl.Rechnungsnr;
    Erl.Rechnungsnr # vNr;
  end;
  if (vStornoNr=0) then begin
    TRANSBRK;
    RETURN false;
  end;
  Lib_Nummern:SaveNummer()


  // **********************************************************************
  // Reanimation

  // Aktionen durchlaufen
  FOR Erx # RecLink(404,450,4,_RecFirst)
  LOOP Erx # RecLink(404,450,4,_RecFirst)
  WHILE (erx<_rLocked) do begin

    if (Erx=_rLocked) then begin
      TRANSBRK;
      Msg(450003,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position)+'/'+AInt(Auf.A.Aktion),0,0,0);
      RETURN false;
    end;

    Erx # Reclink(401,404,1,_recFirst);   // Position holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      Msg(450004, AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position)+'/'+AInt(Auf.A.Aktion),0,0,0);
      RETURN false;
    end;
    if (Erx=_rLocked) then begin
      TRANSBRK;
      Msg(450005,AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position),0,0,0);
      RETURN false;
    end;

    Erx # RecLink(819,401,1,_recFirst);   // Warengruppe holen
    if (erx>_rLocked) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;

    Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      Msg(450006,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position)+'/'+AInt(Auf.A.Aktion),0,0,0);
      RETURN false;
    end;
    if (Erx=_rLocked) then begin
      TRANSBRK;
      Msg(450007,AInt(Auf.Nummer),0,0,0);
      RETURN false;
    end;

    // Aktion reanimieren
    RecRead(404,1,_RecLock);
    Auf.A.Rechnungsmark   # '$';
    Auf.A.Rechnungsdatum  # 0.0.0;
    Auf.A.Rechnungsnr     # 0;
    Auf.A.RechPreisW1     # 0.0;
    Auf.A.Rechnungspreis  # 0.0;
    Auf.A.RechKorrektW1   # 0.0;
    Auf.A.RechKorrektur   # 0.0;
    Erx # RekReplace(404,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;


    // ggf. Materialkarte updaten
    if ( Wgr_Data:IstMat(Auf.P.Wgr.Dateinr) or Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) and
      (Auf.A.MaterialNr<>0) then begin
      Mat.Nummer # Auf.A.MaterialNr;
      Erx # RecRead(200,1,_RecLock);
      if (Erx>_rLocked) then begin
        // ---- Material aus Ablage zurückholen
        If (Mat_Abl_Data:RestoreAusAblage(Auf.A.MaterialNr)) = false then
          RETURN false;

      end;
      Mat.VK.Kundennr   # 0;
      Mat.VK.Rechnr     # 0;
      Mat.VK.Rechdatum  # 0.0.0;
      Mat.VK.Gewicht    # 0.0
      Mat.VK.Preis      # 0.0;
      Mat.VK.Korrektur  # 0.0;
      Mat_data:Replace(_RecUnlock,'AUTO');
    end;


    // Stornoaktion informativ anlegen
    if (vAufNr<>Auf.P.Nummer) or (vAufPos<>Auf.P.Position) then begin
      RecBufClear(404);
      Auf.A.Aktionstyp    # c_Akt_Info;
      Auf.A.Aktionsnr     # 0;
      Auf.A.Aktionspos    # 0;
      Auf.A.Aktionsdatum  # vReDat;
      Auf.A.TerminStart   # Erl.Rechnungsdatum;
      Auf.A.TerminEnde    # vReDat;
      Auf.A.Bemerkung     # Translate('Stornorechnung')+' '+aint(vstornoNr)+' '+Translate('zu')+' '+translate('Rechnung')+' '+aint(Erl.Rechnungsnr);
      Auf_A_Data:NeuAnlegen();
      vAufNr  # Auf.P.Nummer;
      vAufPos # Auf.P.Position;
    end;


    // Position reanimieren
    if (Auf_A_Data:RecalcAll()=false) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;
/*** 23.02.2022 AH, Fix
    RecRead(401,1,_recLock);
    "Auf.P.Löschmarker"     # '';
    "Auf.P.Lösch.Datum"     # 0.0.0;
    "Auf.P.Lösch.Zeit"      # 0:0;
    "Auf.P.Lösch.User"      # '';
    Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;
***/
    if ("Auf.P.Löschmarker"='*') then begin     // 2022-06-23  AH
      if (Auf_P_Subs:ToggleLoeschmarker(n)=n) then begin
        TRANSBRK;
        Msg(450099,'',0,0,0);
        RETURN false;
      end;
    end;

    // AuftragsKopf reanmimieren 06.06.2011 MS BUG behoben Kopf wurde nicht gesperrt
    RecLink(400,401,3,_RecFirst);

    Erx # RecRead(400, 1, _recLock);
    if (Erx <> _rOK) then begin
      TRANSBRK;
      Msg(450007, '', 0, 0, 0);
      RETURN false;
    end;

    Auf_Data:BerechneMarker();
    Erx # RekReplace(400,_recUnlock,'AUTO');
    if (Erx <> _rOK) then begin
      TRANSBRK;
      Msg(400018, '', 0, 0, 0);
      RETURN false;
    end;

    // ggf. Aufpreise reanimieren
    Erx # RecLink(403,400,13,_RecFirst);
    WHILE (erx<=_rLocked) do begin

      if (Auf.Z.Rechnungsnr=Erl.Rechnungsnr) then begin
        if (Erx=_rLocked) then begin
          TRANSBRK;
          Msg(450008,"Auf.Z.Schlüssel"+'|'+AInt(Auf.Z.Nummer)+'/'+AInt(Auf.Z.Position),0,0,0);
          RETURN false;
        end;

        RecRead(403,1,_RecLock);
        Auf.Z.Rechnungsnr # 0;
        Erx # RekReplace(403,_recUnlock,'AUTO');
        if (erx<>_rOK) then begin
          TRANSBRK;
          Msg(450099,'',0,0,0);
          RETURN false;
        end;
      end;

      Erx # RecLink(403,400,13,_RecNext);
    END;

  END;  // Auf.Akt loopen


  // **********************************************************************
  // ggf. Offenen Posten "bezahlen"
  if ((Erl.Rechnungstyp<>c_ERL_Gut) and (Erl.Rechnungstyp<>c_ERL_BEL_LF)) then begin
    // OP eventuell vorher aus der Ablage holen
    begin
      "OfP~Rechnungsnr" # Erl.Rechnungsnr;
      Erx # RecRead(470,1,_RecLock);
      if (ERx = _rOK) then begin
        OfP_Abl_Data:RestoreAusAblage("OfP~Rechnungsnr");
        vOPAblage # true;
      end;
    end;

    OfP.Rechnungsnr # Erl.Rechnungsnr;
    Erx # RecRead(460,1,_RecLock);
    if (erx<_rLocked) then begin
      RecBufClear(461);
      OfP.Z.Rechnungsnr # OfP.Rechnungsnr;  // Zahlung anlegen
      OfP.Z.Betrag      # Erl.Brutto;
      OfP.Z.BetragW1    # Erl.BruttoW1;
      OfP.Z.Zahlungsnr  # 0;
      OfP.Z.Anlage.Datum  # today;
      OfP.Z.Anlage.Zeit   # now;
      OfP.Z.Anlage.User   # gUsername;
      Erx # RekInsert(461,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        Msg(450099,'',0,0,0);
        RETURN false;
      end;
/***
      WHILE (erx<>_rOK) do begin
        OfP.Z.Zahlungsnr  # OfP.Z.Zahlungsnr  + 1;
        RekInsert(461,0,'AUTO');
      END;
***/
      OfP.Zahlungen   # OfP.Zahlungen   + OfP.Z.Betrag; // OfP updaten
      OfP.ZahlungenW1 # OfP.ZahlungenW1 + OfP.Z.BetragW1;
      OfP.Rest        # OfP.Brutto      - OfP.Zahlungen;
      OfP.RestW1      # OfP.BruttoW1    - OfP.ZahlungenW1;
      if (OFP.Bemerkung='') then
        OfP.Bemerkung   # Translate('STORNIERT')
      else
        OfP.Bemerkung   # StrCut(OfP.Bemerkung + ';'+Translate('STORNIERT'),1,64);
      "OfP.Löschmarker" # '*';
      "OfP.Lösch.Datum" # today;
      "OfP.Lösch.Zeit"  # now;
      "OfP.Lösch.User"  # gUsername;
      Erx # RekReplace(460,_recUnlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        Msg(450099,'',0,0,0);
        RETURN false;
      end;
      end
    else begin
todo('OP Ablage');
      RecBufClear(460);
    end;
  end;


  // **********************************************************************
  // Eingangsrechnung ggf. löschen...
  vEREOK # n;
  vTyp # '';
  if (Erl.Rechnungstyp=c_ERL_GUT) then vTyp # c_GUT;
  if (Erl.Rechnungstyp=c_ERL_BEL_LF) then vTyp # c_BEL_LF;
  if (vTyp<>'') then begin
    RecBufClear(560);
    ERe.Rechnungsnr     # vTyp+' '+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup);
    Erx # RecRead(560,4,0);
    if (erx<=_rMultikey) then begin
      vEREOK # y;
      Erx # RecRead(560,1,0);
      //if ("ERe.Löschmarker"<>'') then vEREOK # n;
      //if (ERe.Zahlungen<>0.0) then vEREOK # n;
      if (vEREok) then begin
        Erx # RecRead(560,1,_recLock);
        "ERe.Löschmarker" # '*';
        Rekreplace(560,0,'AUTO');
      end;
    end;
  end;


  // **********************************************************************
  // ggf. EKK löschen
  RecBufClear(555);
  EKK.Datei           # 450;
  EKK.ID1             # Erl.Rechnungsnr;
  EKK.ID2             # 0;
  EKK.ID3             # 0;
  EKK.ID4             # 0;
  Erx # RecRead(555,1,0);
  Erx # RecRead(555,1,0);
  WHILE (erx<=_rLocked) and (EKK.ID1=Erl.REchnungsnr) do begin
    if (EKK.EingangsreNr<>0) then begin
      TRANSBRK;
      Msg(450009,'',0,0,0);
      RETURN false;
    end;
    Erx # RekDelete(555,0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(450009,'',0,0,0);
      RETURN false;
    end;

    Erx # RecRead(555,1,0);
    Erx # RecRead(555,1,0);
  END;


  // **********************************************************************
  // Stornorechnung anlegen

  // Erlöskonten kopieren
  Erx # RecLink(451,450,1,_recFirst);
  WHILE (erx<_rLocked) do begin
    Erl.K.Rechnungsnr     # vStornoNr;
    Erl.K.Rechnungsdatum  # vReDat;
    Erl.K.Betrag          # Erl.K.Betrag * (-1.0);
    Erl.K.BetragW1        # Erl.K.BetragW1 * (-1.0);
    "Erl.K.Stückzahl"     # "Erl.K.Stückzahl" * (-1);
    Erl.K.Gewicht         # Erl.K.Gewicht * (-1.0);
    Erl.K.Menge           # Erl.K.Menge * (-1.0);
    Erl.K.EKPreisSummeW1  # Erl.K.EKPreisSummeW1 * (-1.0);
    Erl.K.InterneKostW1   # Erl.K.InterneKostW1 * (-1.0);
    Erl.K.Korrektur       # Erl.K.Korrektur * (-1.0);
    Erl.K.KorrekturW1     # Erl.K.KorrekturW1 * (-1.0);
    Erx # RekInsert(451,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;
    Erl.K.Rechnungsnr # Erl.Rechnungsnr;

    Erx # RecLink(451,450,1,_recNext);
  END;

  // Erlös ändern
  RecRead(450,1,_recLock);
  vBemerk # Erl.Bemerkung;
  Erl.StornoRechNr  # vStornoNr;
  if (Erl.Bemerkung='') then
    Erl.Bemerkung   # Translate('STORNIERT')
  else
    Erl.Bemerkung   # StrCut(Erl.Bemerkung + ';'+Translate('STORNIERT'),1,64);
  Erx # Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Msg(450099,'',0,0,0);
    RETURN false;
  end;


  // Statistik stornieren
  Sta_Data:StorniereRe(Erl.Rechnungsnr, vStornoNr);


  // neuen Erlös anlegen
  Erl.StornoRechNr    # Erl.Rechnungsnr;
  Erl.Rechnungsnr     # vStornoNr;
  Erl.Rechnungsdatum  # vReDat;

  if (Erl.Rechnungstyp=c_Erl_REKOR) then        Erl.Rechnungstyp    # c_Erl_StornoREKOR
  else if (Erl.Rechnungstyp=c_Erl_Bogut) then   Erl.Rechnungstyp    # c_Erl_StornoBoGut
  else if (Erl.Rechnungstyp=c_Erl_Bel_KD) then  Erl.Rechnungstyp    # c_Erl_StornoBel_KD
  else if (Erl.Rechnungstyp=c_Erl_Gut) then     Erl.Rechnungstyp    # c_Erl_StornoGut
  else if (Erl.Rechnungstyp=c_Erl_Bel_LF) then  Erl.Rechnungstyp    # c_Erl_StornoBel_LF
  else                                          Erl.Rechnungstyp    # c_Erl_StornoVK

  Erl.Bemerkung       # vBemerk;
  if (Erl.FibuDatum<>0.0.0) then begin
    if (Erl.Bemerkung='') then
      Erl.Bemerkung # Translate('FÜR FIBU')
    else
      Erl.Bemerkung # StrCut(Erl.Bemerkung + '; '+Translate('FÜR FIBU'),1,64);
  end;
  Erl.FibuDatum       # 0.0.0;

  Erl.Netto         # Erl.Netto * (-1.0);
  Erl.NettoW1       # Erl.NettoW1 * (-1.0);
  Erl.Steuer        # Erl.Steuer * (-1.0);
  Erl.SteuerW1      # Erl.SteuerW1 * (-1.0);
  Erl.Brutto        # Erl.Brutto * (-1.0);
  Erl.BruttoW1      # Erl.BruttoW1 * (-1.0);
  Erl.Korrektur     # Erl.Korrektur * (-1.0);
  Erl.KorrekturW1   # Erl.KOrrekturW1 * (-1.0);

  "Erl.Stückzahl"   # "Erl.Stückzahl" * (-1);
  Erl.Gewicht       # Erl.Gewicht * (-1.0);
  Erl.VerpEinheiten # Erl.Verpeinheiten * (-1);

  Erx # RekInsert(450,0,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Msg(450099,'',0,0,0);
    RETURN false;
  end;


  // **********************************************************************
  // Storno-ER anlegen
  if ((Erl.Rechnungstyp=c_ERL_Gut) or (Erl.Rechnungstyp=c_ERL_BEL_LF) or (Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF)) and
    (vEREOK) then begin

    vNr # Vbk.Nummer;
    if (RunAFX('Fakt.Nummernvergabe','Storno-Eingangsrechnung') = 0) then begin   // 2022-11-08 AH
      vStornoNr # Lib_Nummern:ReadNummer('Storno-Eingangsrechnung');
    end
    else begin
      vStornoNr # Vbk.Nummer;
      Vbk.Nummer # vNr;
    end;
    if (vStornoNr<>0) then begin
      Lib_Nummern:SaveNummer();
    end
    else begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;

    // Kontierung kopieren
    Erx # RecLink(551,560,3,_recFirst);
    WHILE (erx<_rLocked) do begin
      Vbk.K.Nummer        # vStornoNr;
      Vbk.K.Betrag        # Vbk.K.Betrag * (-1.0);
      Vbk.K.BetragW1      # Vbk.K.BetragW1 * (-1.0);
      "Vbk.K.Stückzahl"   # "Vbk.K.Stückzahl" * (-1);
      Vbk.K.Gewicht       # Vbk.K.Gewicht * (-1.0);

      Erx # RekInsert(551,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        Msg(450099,'',0,0,0);
        RETURN false;
      end;
      Vbk.K.Nummer        # ERe.Nummer;

      Erx # RecLink(551,560,3,_recNext);
    END;


    ERe.Nummer            # vStornoNr;
    ERe.Rechnungsnr       # StrCut(ERe.Rechnungsnr + ' STORNO',1,20);
    ERe.Rechnungstyp      # Erl.Rechnungstyp;
    ERe.Rechnungsdatum    # Erl.Rechnungsdatum;
    ERe.Valuta            # Erl.Rechnungsdatum;
//    ERe.Zieldatum         # Erl.Rechnungsdatum;   11.11.2020 AH dank VFP
    ERe.Skontodatum       # Erl.Rechnungsdatum;
//    ERe.Wiedervorlage     # ERe.Zieldatum;        11.11.2020 AH dank VFP
    ERe.Netto             # ERe.Netto * (-1.0);
    ERe.NettoW1           # ERe.NettoW1 * (-1.0);
    Ere.Brutto            # ERe.Brutto * (-1.0);
    Ere.BruttoW1          # ERe.BruttoW1 * (-1.0);
    Ere.Steuer            # ERe.Steuer * (-1.0);
    Ere.SteuerW1          # ERe.SteuerW1 * (-1.0);
    Ere.Skonto            # ERe.Skonto * (-1.0);
    Ere.SkontoW1          # ERe.SkontoW1 * (-1.0);
    ERe.Zahlungen         # 0.0;
    ERe.ZahlungenW1       # 0.0;
    ERe.KontiertBetrag    # ERe.KontiertBetrag * (-1.0);
    ERe.KontiertBetragW1  # ERe.KontiertBetragW1 * (-1.0);
    "ERe.Kontiert.Stück"  # "ERe.Kontiert.Stück" * (-1);
    ERe.Kontiert.Gewicht  # ERe.Kontiert.Gewicht * (-1.0);
    ERe.KontrollBetrag    # 0.0;
    ERe.KontrollBetragW1  # 0.0;
    "ERe.Kontroll.Stück"  # 0;
    ERe.Kontroll.Gewicht  # 0.0;
    "ERe.Stückzahl"       # "ERe.Stückzahl" * (-1);
    ERe.Gewicht           # ERe.Gewicht * (-1.0);
    ERe.Rest              # Rnd(ERe.Brutto - ERe.Zahlungen,2);
    ERe.RestW1            # Rnd(ERe.BruttoW1 - ERe.ZahlungenW1,2);
    ERe.Bemerkung         # Translate('STORNO-ER');
    "ERe.Löschmarker"     # '';
    ERe.FibuDatum         # 0.0.0;
    Erx # RekInsert(560,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;
  end;


  // **********************************************************************
  // Storno-Offenen Posten anlegen
  if (Erl.Rechnungstyp<>c_ERL_Gut)       and (Erl.Rechnungstyp<>c_ERL_BEL_LF) and
     (Erl.Rechnungstyp<>c_Erl_StornoGut) and (Erl.Rechnungstyp<>c_Erl_StornoBel_LF) then begin
    OfP.Rechnungsnr     # vStornoNr;
    OfP.Rechnungsdatum  # Erl.Rechnungsdatum;
    OfP.Rechnungstyp    # Erl.Rechnungstyp;
    OfP.Netto           # OfP.Netto * (-1.0);
    OfP.NettoW1         # OfP.NettoW1 * (-1.0);
    OfP.Brutto          # OfP.Brutto * (-1.0);
    OfP.BruttoW1        # OfP.BruttoW1 * (-1.0);
    OfP.Steuer          # OfP.Steuer * (-1.0);
    OfP.SteuerW1        # OfP.SteuerW1 * (-1.0);
    OfP.Skonto          # OfP.Skonto * (-1.0);
    OfP.SkontoW1        # OfP.SkontoW1 * (-1.0);
    "OfP.Mahngebühr"    # 0.0;
    "OfP.MahngebührW1"  # 0.0;
    OfP.Zinsen          # 0.0;
    OfP.ZinsenW1        # 0.0;
    OfP.Rest            # 0.0;
    OfP.RestW1          # 0.0;
    OfP.Zahlungen       # OfP.Brutto;
    OfP.ZahlungenW1     # OfP.BruttoW1;
    OfP.Bemerkung       # Translate('STORNO-OP');
    if (vOPAblage = true) then
      "OfP.Löschmarker" # ''
    else
      "OfP.Löschmarker" # '*';

    if ("OfP.Löschmarker"='*') then begin
      "OfP.Lösch.Datum" # today;
      "OfP.Lösch.Zeit"  # now;
      "OfP.Lösch.User"  # gUsername;
    end
    else begin
      "OfP.Lösch.Datum" # 0.0.0;
      "OfP.Lösch.Zeit"  # 0:0;
      "OfP.Lösch.User"  # '';
    end;
      
    Erx # RekInsert(460,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;

    RecBufClear(461);
    OfP.Z.Rechnungsnr # OfP.Rechnungsnr;  // Zahlung anlegen
    OfP.Z.Betrag      # Erl.Brutto;// * (-1.0);
    OfP.Z.BetragW1    # Erl.BruttoW1;// * (-1.0);
    OfP.Z.Zahlungsnr  # 0;
    Erx # RekInsert(461,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;
/***
    WHILE (erx<>_rOK) do begin
      OfP.Z.Zahlungsnr  # OfP.Z.Zahlungsnr  + 1;
      RekInsert(461,0,'AUTO');
    END;
***/

    // Onlinestatistik verbuchen  22.01.2013
    OSt_Data:StackErloes();
    if (Erl.Rechnungstyp=c_Erl_StornoBel_KD) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF) then
      vTyp # 'BEL';
    else if (Erl.Rechnungstyp=c_Erl_StornoREKOR) or (Erl.Rechnungstyp=c_Erl_StornoGut) then
      vTyp # 'GUT';
    else
      vTyp # 'RE';
    if (OsT_Data:BucheRechnung(vTyp)=False) then begin
      TRANSBRK;
      Msg(450099,'',0,0,0);
      RETURN false;
    end;
  end;


  TRANSOFF;

//  if (vEREok=n) then begin
//    Msg(450106,'',0,0,0);
//  end;

  Msg(450002,'',0,0,0);

  RETURN true;

end;


//========================================================================
//  sub DruckSammelGelangen()                                ST 2013-09-11
///                                                       Projekt 1427/49
//    Startet den Druck für die Sammelgelangensbestätigung
//========================================================================
sub DruckSammelGelangen()
local begin
end;
begin

  RecBufClear(998);
  Sel.bis.Datum         # today;
  Sel.Fin.bis.Rechnung  # 9999999;
  Sel.Auf.Kundennr      # 0;
  Sel.Fin.GutschriftYN  # true;
  Sel.Fin.LiefGutBelYN  # false;
  Sel.Fin.nurMarkeYN    # false;

  // Dialog anzeigen
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Erl.Gelangensbest',here+':DruckSammelGelangenAusSel');
  gMDI->wpcaption # Lfm.Name;
  $cbSel.DE->wpCheckState   # _WinStateChkchecked;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  sub DruckSammelGelangenAusSel()          ST 2013-09-11  Projekt 1427/49
//
//    Regelt den Druck für die Sammelgelangensbestätigung
//========================================================================
sub DruckSammelGelangenAusSel()
local begin
  Erx         : int;
  vQ450       : alpha(4000);
  vSel        : int;
  vSelName    : alpha;
  vKey        : int;
  vMFile,vMID : int;
  vItem       : int;
  vSortKey    : alpha;

  vProgress   : int;
  vTree       : int;
  vTree2Print : int;

  vKunde      : int;
  vPrinted    : logic;

  v450        : int;
end;
begin

  // Selektionsquery
  vQ450 # '';
  Lib_Sel:QVonBisD( var vQ450, 'Erl.Rechnungsdatum',Sel.von.Datum ,Sel.bis.Datum);
  Lib_Sel:QAlpha(   var vQ450, 'Erl.Adr.USIdentNr','<>', '');
  Lib_Sel:QFloat(   var vQ450, 'Erl.Steuer','=', 0.0);
  Lib_Sel:QInt(     var vQ450, 'Erl.StornoRechNr','=', 0);
  Lib_Sel:QInt(     var vQ450, 'Erl.Rechnungstyp','=', 400);

  if (Sel.Auf.Kundennr <> 0) then
    Lib_Sel:QInt( var vQ450, 'Erl.Kundennummer','=', Sel.Auf.Kundennr);

  // Selektion starten...
  vSel # SelCreate(450, 1 );
  Erx # vSel->SelDefQuery( '', vQ450 );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  // ... Progress
  vProgress # Lib_Progress:Init('Ermittle EU Rechnungen', vSel->SelInfo(_SelCount));
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  FOR   Erx # RecRead(450,vSel,_RecFirst)
  LOOP  Erx # RecRead(450,vSel,_RecNext)
  WHILE (Erx <= _rLocked ) DO BEGIN // Erlöse
    if (vProgress->Lib_Progress:Step() = false) then begin
      SelClose(vSel);
      SelDelete(450, vSelName);
      vSel # 0;
      vProgress->Lib_Progress:Term();
      Sort_KillList(vTree);
      RETURN;
    end;

    if (Erl.StornoRechNr <> 0) then
      CYCLE;

    // Keine Rechnungen an Deutsche Unternehmen
    if (StrFind(Erl.Adr.USIdentNr,'DE',1) > 0) then
      CYCLE;

    vSortKey # Lib_Strings:Intforsort(Erl.Kundennummer)+  Lib_Strings:Intforsort(Erl.Rechnungsnr);
    Sort_ItemAdd(vTree,vSortKey,450,RecInfo(450,_RecId));
  END;

  // Selektion loeschen
  SelClose(vSel);
  SelDelete(450, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Term();

  // Sortierte Liste durchlaufen und Pro Kunde ein Formular drucken
  gFormParaHdl # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vKunde # -1;
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) DO BEGIN

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    if (vKunde = -1) then
      vKunde # Erl.Kundennummer;

//debugx('RE ' + Aint(Erl.Rechnungsnr));

    v450  # RekSave(450);

    // Kundenwechsel ?
    vPrinted # false;
    if (vKunde <> Erl.Kundennummer) then begin

      //  Kunde lesen
      Adr.Kundennr  # vKunde;
      RecREad(100,2,0);
//debugx('------Print: ' + Aint(vKunde));
      Lib_Dokumente:Printform(450,'SammelGelangen',false);
      gFormParaHdl->CteClear(true);
      vPrinted # true;

    end;
    RekRestore(v450);

    vKunde # Erl.Kundennummer;

    vSortkey # Lib_Strings:Intforsort(Erl.Rechnungsnr);
    Sort_ItemAdd(gFormParaHdl,vSortKey,450,RecInfo(450,_RecId));

  END;
  if (vPrinted = false) or (vKunde = Erl.Kundennummer) then begin
//    debugx('------Print: ' + Aint(vKunde));
    Adr.Kundennr  # vKunde;
    RecREad(100,2,0);

    Lib_Dokumente:Printform(450,'SammelGelangen',false);
  end;


  // Löschen der Liste
  Sort_KillList(vTree);
  Sort_KillList(gFormParaHdl);

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub DruckSammelGelangenAusSelEvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (aEvt:obj->wpName = 'cbSel.DE') then   begin
    $cbSel.DE->wpCheckState   # _WinStateChkchecked;
    $cbSel.EN->wpCheckState   # _WinStateChkUnchecked;
    $cbSel.FR->wpCheckState   # _WinStateChkUnchecked;
    Sel.Fin.GutschriftYN      # true;
    Sel.Fin.LiefGutBelYN      # false;
    Sel.Fin.nurMarkeYN        # false;
  end else
  if (aEvt:obj->wpName = 'cbSel.EN') then   begin
    $cbSel.DE->wpCheckState   # _WinStateChkUnchecked;
    $cbSel.EN->wpCheckState   # _WinStateChkChecked;
    $cbSel.FR->wpCheckState   # _WinStateChkUnchecked;
    Sel.Fin.GutschriftYN      # false;
    Sel.Fin.LiefGutBelYN      # true;
    Sel.Fin.nurMarkeYN        # false;
  end else
  if (aEvt:obj->wpName = 'cbSel.FR') then   begin
    $cbSel.DE->wpCheckState   # _WinStateChkUnchecked;
    $cbSel.EN->wpCheckState   # _WinStateChkUnChecked;
    $cbSel.FR->wpCheckState   # _WinStateChkchecked;
    Sel.Fin.GutschriftYN      # false;
    Sel.Fin.LiefGutBelYN      # false;
    Sel.Fin.nurMarkeYN        # true;
  end;

end;


//========================================================================
//  Replace451
//========================================================================
sub Replace451(
  opt aLock   : int;
  opt aGrund  : alpha;
  opt aMatNr  : int) : int;
local begin
  Erx     : int;
  vErg    : int;
  v451    : int;
  vEkKorr : float;
  vIkKorr : float;
  vVkKorr : float;
  v450    : int;
end;
begin

  v451 # RecBufCreate(451);
  RecbufCopy(451, v451);
  if (RecRead(v451,1,0)<=_rLocked) then begin
    vVkKorr # Erl.K.KorrekturW1 - v451->Erl.K.KorrekturW1;
    vIkKorr # Erl.K.InterneKostW1 - v451->Erl.K.InterneKostW1;
    vEKKorr # Erl.K.EkPreisSummeW1 - v451->Erl.K.EkPreisSummeW1;
  end;
  RecBufDestroy(v451);

  Erx # RekReplace(451, aLock, aGrund);
  if (Erx<>_rOK) then begin
    Erg # Erx; // TODOERX
    RETURN Erx;
  end;
  vErg # Erx;

  if (vEkKorr<>0.0) or (vIkKorr<>0.0) or (vVkKorr<>0.0) then begin
    if (Erl.Rechnungsnr<>Erl.K.Rechnungsnr) then begin
      v450 # RekSave(450);
      RekLink(450,451,1,_recFirst);   // Erlös holen
    end;

    OSt_Data:StackKontoKorrektur(vEkKorr, vIkKorr, vVkKorr);

    Ost_Data:BucheKorrektur(vEkKorr, vIkKorr, vVkKorr, aMatNr);

    RunAFX('Erl.K.Korrektur', aGrund+'|'+anum(vEkKorr,2)+'|'+anum(vIkKorr,2)+'|'+anum(vVkKorr,2));

    if (v450<>0) then
      RekRestore(v450);
  end;

  Erx # vErg;
  Erg # Erx; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Insert451
//========================================================================
sub Insert451(
  opt aLock   : int;
  opt aGrund  : alpha;
) : int;
local begin
  Erx : int;
end;
begin
  RunAFX('Erl.K.Insert.Pre', aGrund);
  Erx # RekInsert(451,aLock,aGrund);
  RETURN Erx;
end;


//========================================================================
//  Replace
//========================================================================
sub Replace(
  opt aLock   : int;
  opt aGrund  : alpha;
) : int;
local begin
  Erx : int;
end;
begin
  RunAFX('Erl.K.Replace.Pre', aGrund);
  Erx # RekReplace(450,aLock,aGrund);
  RETURN Erx;
end;


//========================================================================
//  Insert
//========================================================================
sub Insert(
  opt aLock   : int;
  opt aGrund  : alpha;
) : int;
local begin
  Erx : int;
end;
begin
  Erl.Anlage.Datum  # today;
  Erl.Anlage.Zeit   # now;
  Erl.Anlage.User   # gUserName;

  Erx # RekInsert(450,aLock,aGrund);
  if (Erx=_rOK) then begin
    RunAFX('Erl.Insert', '');
  end;
  
  Erg # Erx; // TODOERX
  RETURN Erx;
end;


//========================================================================
//========================================================================
sub ParseDiffText(
  aTxt    : int;
  aAlsEK  : logic;
  aGrund  : alpha);
local begin
  Erx       : int;
  vI        : int;
  vA, vB    : alpha;
  vDiff     : float;
end
begin
//Proto('Prüfe Abweichungen...');
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=TextInfo(aTxt, _TextLines)) do begin
    vA    # TextLineRead(aTxt, vI, 0);
    vDiff # cnvfa(Str_Token(vA, '|', 2));
//debugx(vA);
    if (vDiff<>0.0) then begin

//Proto('!!! Abweichung gefunden : '+vA);

      Erl.Rechnungsnr # cnvia(Str_Token(vA,'|',3));
      Erx # RecRead(450,1,0);
      if (erx>_rLocked) then begin
//Proto('Keine RE!??!?!!');
        // 11.02.2019 AH: wenn Karte zwar ausbebucht (z.B. LFS), aber noch nicht fakturiert ist...
        if (cnvia(Str_Token(vA,'|',3))=0) then begin
          Mat.Nummer # cnvia(Str_Token(vA,'|',1));
          FOR Erx # RecLink(404,200,24,_recFirst)     // Auftragsaktion zum Material loopen...
          LOOP Erx # RecLink(404,200,24,_recNext)
          WHILE (erx<=_rLocked) do begin
            if (Auf.A.Rechnungsnr<>0) then CYCLE;
            if (Auf.A.Aktionstyp<>c_akt_LFS) and
              (Auf.A.Aktionstyp=c_akt_DFakt) then CYCLE;

            // Auftragsaktion korrigieren...
            RecRead(404,1,_recLock);
            if (aAlsEK) then
              Auf.A.EkPreisSummeW1  # Auf.A.EkPreisSummeW1 + vDiff
            else
              Auf.A.InterneKostW1   # Auf.A.InterneKostW1 + vDiff;
            RekReplace(404);
          END;
        end;
        
        CYCLE;
      end;
      
      Mat.Nummer # cnvia(Str_Token(vA,'|',1));
      FOR Erx # RecLink(404,200,24,_recFirst)     // Auftragsaktion zum Material loopen...
      LOOP Erx # RecLink(404,200,24,_recNext)
      WHILE (erx<=_rLocked) do begin
        if (Auf.A.Rechnungsnr=Erl.Rechnungsnr) then begin // $-Aktion suchen
          FOR Erx # RecLink(451,450,1,_recFirst)  // Erlöskonten loopen...
          LOOP Erx # RecLink(451,450,1,_recNext)
          WHILE (erx<=_rLocked) do begin
//Proto('...betrifft Erlös KEY450..,');
            if (Erl.K.Bemerkung<>Translate('Grundpreis')) then CYCLE;
            if (Erl.K.Auftragsnr<>Auf.A.Nummer) or (Erl.K.Auftragspos<>Auf.A.Position) then CYCLE;

            // Auftragskation korrigieren...
            RecRead(404,1,_recLock);
            if (aAlsEK) then
              Auf.A.EkPreisSummeW1  # Auf.A.EkPreisSummeW1 + vDiff
            else
              Auf.A.InterneKostW1   # Auf.A.InterneKostW1 + vDiff;
            RekReplace(404);

            // Erlöskonto korrigieren...
            RecRead(451,1,_recLock);
            if (aAlsEK) then
              Erl.K.EkPreisSummeW1  # Erl.K.EkPreisSummeW1 + vDiff
            else
              Erl.K.InterneKostW1   # Erl.K.InterneKostW1 + vDiff;

            erx # Replace451(_recunlock, aGrund, Mat.Nummer);

            BREAK;
          END;
          BREAK;
        end;
      END;
    end;
    
  END;
end;


//========================================================================