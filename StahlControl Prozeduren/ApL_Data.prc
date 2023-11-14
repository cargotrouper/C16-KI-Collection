@A+
//===== Business-Control =================================================
//
//  Prozedur    ApL_Data
//
//  Info        ohne E_R_G
//
//
//  18.11.2003  AI  Erstellung der Prozedur
//  14.12.2010  AI  Automatik löscht auch bei Bestellungen
//  13.12.2012  AI  Formelfunktion
//  29.07.2013  AH  Artikelnummer immer aus Auftragspos. holen - nicht nur bei MatMix/Artikel
//  14.08.2013  AH  Formelfunktion auch bei Neuberechnen starten
//  05.02.2015  AH  Neu: VpgArtikelnr
//  08.12.2016  AH  Auftragskopf-Automatik
//  10.03.2017  ST  Neuberechnung: Bei Prozentauspreisen auch den Prozentsatz aus der Menge übernehemn
//  14.06.2017  ST  AutoGenerierung für Auftragskopf nur mit Aufpreisgruppe 999
//  11.07.2019  AH  Neu: Lieferadresse im Aufpreis
//  02.10.2019  AH  Neu: "Neuberechnen" kann auf Datei 401 (nur diese AufPos)
//  07.01.2021  AH  Neu: "ProRechnung"
//  09.04.2021  AH  Neu: Artikelgruppe2
//  23.04.2021  AH  Neu: "AutoGenerieren" mit aDatum
//  08.06.2021  AH  Neu:  aNurKopf-Logik
//  27.07.2021  AH  ERX
//  08.09.2021  AH  AFX "ApL.Autogenerieren"
//  2022-07-08  AH  DEADLOCK
//
//  Subprozeduren
//    SUB NimmAufpreis(aDatei : word; optaNurUpdate : logic)
//    SUB CheckObf(aDatei : word; aObf : word; aZusatz : alpha) : logic;
//    SUB AutoGenerieren(aDatei : word; optaNurUpdate : logic; optaSel : int; opt aDatum : date) : logic;
//    SUB HoleAufpreis(aKey  : alpha; aDat : date) : int;
//    SUB Neuberechnen(aDatei : word; aDatum : date) : logic;
//    SUB Import_TSR()
//
//========================================================================
@I:Def_Global

define begin
  TheKey : '#'+Cnvai(ApL.L.Key2,_fmtnumleadzero,0,3)+'.'+CnvAI(ApL.L.Key3,_fmtnumleadzero,0,3)+'.'+cnvai(ApL.L.Key4,_fmtnumleadzero,0,3)
end;


//========================================================================
//  NimmAufpreis
//
//========================================================================
sub NimmAufpreis(
  aDatei  : word;
  opt aNurUpdate : logic;
) : int;
local begin
  Erx       : int;
  vRefresh  : logic;
end;
begin

  case aDatei of
    400 : begin
      RecBufClear(403);
      Auf.Z.Nummer          # Auf.Nummer;
      Auf.Z.Position        # 0;
      "Auf.Z.Schlüssel"     # TheKey;
      Auf.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
      Auf.Z.Menge           # ApL.L.Menge;
      Auf.Z.MEH             # ApL.L.MEH;
      Auf.Z.PEH             # ApL.L.PEH;
      Auf.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
      Auf.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
      Auf.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
      Auf.Z.ProRechnungYN   # ApL.L.ProRechnungYN;;
      Auf.Z.PerFormelYN     # ApL.L.PerFormelYN;
      Auf.Z.FormelFunktion  # ApL.L.FormelFunktion;
      Auf.Z.Vpg.Artikelnr   # ApL.L.Vpg.Artikelnr;

      Auf.Z.Preis           # ApL.L.Preis;
      Auf.Z.Warengruppe     # ApL.L.Warengruppe;
      If (vRefresh=n) then begin
        if (aNurUpdate=n) then begin
          Auf.Z.Anlage.Datum  # today;
          Auf.Z.Anlage.Zeit   # Now;
          Auf.Z.Anlage.User   # gUserName;
          Auf.Z.lfdNr         # 0;
          REPEAT
            Auf.Z.lfdNr       # Auf.Z.lfdNr + 1;
            Erx # RekInsert(403,0,'AUTO');
            if (Erx=_rDeadLock) then RETURN Erx;
          UNTIL (Erx=_rOK);
        end;
        end
      else begin
        Erx # RecRead(403,1,_recNoload | _Reclock);
        if (Erx=_rOK) then
          Erx # RekReplace(403,_recunlock,'AUTO');
        if (Erx<>_rOK) then RETURN Erx;
      end;

    end;


    401 : begin
/*
      RecBufClear(403);
      Auf.Z.Nummer          # Auf.P.Nummer;
      Auf.Z.Position        # Auf.P.Position;
      "Auf.Z.Schlüssel"     # TheKey;
      Erx # RecRead(403,2,0);
      WHILE (Erx<=_rMultikey) and
        (Auf.Z.Nummer=Auf.P.Nummer) and
        (Auf.Z.Position=Auf.P.Position) and
        ("Auf.Z.Schlüssel"=TheKey) do begin

        if (Auf.Z.Rechnungsnr=0) then begin
          vRefresh # Auf.Z.NeuberechnenYN;
          if (vRefresh=n) then RETURN;
c        end;
      END;
      if (vRefresh=n) then RETURN;
*/
      RecBufClear(403);
      Auf.Z.Nummer          # Auf.P.Nummer;
      Auf.Z.Position        # Auf.P.Position;
      "Auf.Z.Schlüssel"     # TheKey;
      Auf.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
      Auf.Z.Menge           # ApL.L.Menge;
      Auf.Z.MEH             # ApL.L.MEH;
      Auf.Z.PEH             # ApL.L.PEH;
      Auf.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
      Auf.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
      Auf.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
      Auf.Z.ProRechnungYN   # ApL.L.ProRechnungYN;;
      Auf.Z.PerFormelYN     # ApL.L.PerFormelYN;
      Auf.Z.FormelFunktion  # ApL.L.FormelFunktion;
      Auf.Z.Vpg.Artikelnr   # ApL.L.Vpg.Artikelnr;

      Auf.Z.Preis           # ApL.L.Preis;
      Auf.Z.Warengruppe     # ApL.L.Warengruppe;
      If (vRefresh=n) then begin
        if (aNurUpdate=n) then begin
          Auf.Z.Anlage.Datum  # today;
          Auf.Z.Anlage.Zeit   # Now;
          Auf.Z.Anlage.User   # gUserName;
          Auf.Z.lfdNr         # 0;
          REPEAT
            Auf.Z.lfdNr       # Auf.Z.lfdNr + 1;
            Erx # RekInsert(403,0,'AUTO');
            if (Erx=_rDeadLock) then RETURN Erx;
          UNTIL (Erx=_rOK);
        end;
        end
      else begin
        Erx # RecRead(403,1,_recNoload | _Reclock);
        if (Erx=_rOK) then
          Erx # RekReplace(403,_recunlock,'AUTO');
        if (Erx<>_rOK) then RETURN Erx;
      end;

    end;


    501 : begin
      RecBufClear(503);
      Ein.Z.Nummer          # Ein.P.Nummer;
      Ein.Z.Position        # Ein.P.Position;
      "Ein.Z.Schlüssel"     # TheKey;
      Erx # RecRead(503,1,0);
      if (Erx=_rOK) then begin
        vRefresh # Ein.Z.NeuberechnenYN;
        if (vRefresh=n) then RETURN _rOK;
      end;

      RecBufClear(503);
      Ein.Z.Nummer          # Ein.P.Nummer;
      Ein.Z.Position        # Ein.P.Position;
      "Ein.Z.Schlüssel"     # TheKey;
      Ein.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
      Ein.Z.Menge           # ApL.L.Menge;
      Ein.Z.MEH             # ApL.L.MEH;
      Ein.Z.PEH             # ApL.L.PEH;
      Ein.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
      Ein.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
      Ein.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
      Ein.Z.ProRechnungYN   # ApL.L.ProRechnungYN;;
      Ein.Z.PerFormelYN     # ApL.L.PerFormelYN;
      Ein.Z.FormelFunktion  # ApL.L.FormelFunktion;

      Ein.Z.MatAktionYN     # ApL.MatAktionYN;
      Ein.Z.Preis           # ApL.L.Preis;
      Ein.Z.Warengruppe     # ApL.L.Warengruppe;
      If (vRefresh=n) then begin
        if (aNurUpdate=n) then begin
          Ein.Z.Anlage.Datum  # today;
          Ein.Z.Anlage.Zeit   # Now;
          Ein.Z.Anlage.User   # gUserName;
          Ein.Z.lfdNr         # 0;
          REPEAT
            Ein.Z.lfdNr       # Ein.Z.lfdNr + 1;
            Erx # RekInsert(503,0,'AUTO');
          if (Erx=_rDeadLock) then RETURN Erx;
          UNTIL (Erx=_rOK);
        end;
      end
      else begin
        Erx # RecRead(503,1,_recNoload | _Reclock);
        if (Erx=_rOK) then
          Erx # RekReplace(503,_recunlock,'AUTO');
        if (Erx<>_rOK) then RETURN Erx;
      end;

    end;

  end;

end;


//========================================================================
//  CheckObf
//
//========================================================================
sub CheckObf(
  aDatei  : word;
  aObf    : word;
  aZusatz : alpha;
) : logic;
local begin
  vRecMode : int;
end;
begin

  case aDatei of
    401 : begin
      vRecMode # _recFirst;
      WHILE (RecLink(402,401,11,vrecmode)<=_rLocked) do begin
        vRecMode # _recNext;
        // Oberfläche ???
        if (aObf<>0) and
          (Auf.AF.ObfNr<>aObf) then CYCLE;
        // Zusatz ???
        if (aZusatz<>'') and
          (Auf.AF.Zusatz<>aZusatz) then CYCLE;
        RETURN TRUE;
      END;
    end;

    501 : begin
      vRecMode # _recFirst;
      WHILE (RecLink(502,501,12,vrecmode)<=_rLocked) do begin
        vRecMode # _recNext;
        // Oberfläche ???
        if (aObf<>0) and
          (Ein.AF.ObfNr<>aObf) then CYCLE;
        // Zusatz ???
        if (aZusatz<>'') and
          (Ein.AF.Zusatz<>aZusatz) then CYCLE;
        RETURN TRUE;
      END;
    end;

  end;

  RETURN false;
end;


//========================================================================
//  AutoGenerieren
//
//========================================================================
sub AutoGenerieren(
  aDatei          : word;
  opt aNurUpdate  : logic;
  opt aSel        : int;
  opt aDatum      : date;
  opt aNurKopf    : alpha;
) : logic;
local begin
  Erx       : int;
  vRecMode  : int;
  vRecMode2 : int;
  vTyp      : alpha(2);
  vDat      : date;
  vGruppe   : word;
  vAdr      : int;
  vErz      : int;
  vGuete    : alpha;
  vDicke    : float;
  vBreite   : float;
  vLaenge   : float;
  vGewicht  : float;
  vStk      : float;
  vZeug     : alpha;
  vLKZ      : alpha;
  vLiefAdr    : int;
  vLiefAnschr : int;

  vArtikel  : alphA(25);
  vArtGrp   : word;

  vAfxArg   : alpha;
end;
begin

  // ST 2015-06-19 Projekt 1512/22: Muss erst noch getestet werden
  // 08.09.2021 AH: Freigabe :p
  vAfxArg # Aint(aDatei)+ '|';
  if (aNurUpdate) then vAfxArg  # vAfxArg  + 'y' else vAfxArg  # vAfxArg  + 'n';
  vAfxArg # vAfxArg + '|' + Aint(aSel);
  vAfxArg # vAfxArg + '|' + cnvad(aDatum);
  vAfxArg # vAfxArg + '|' + aNurKopf;
  if (RunAFX('ApL.Autogenerieren', vAfxArg ) < 0) then RETURN true;

  
  case aDatei of

    250 : begin // Artikel
      vTyp # 'VK';
      vDat # today;
      Erx # RecLink(819,250,10,0);   // Warengruppe holen
      if (erx<=_rLocked) then vGruppe # Wgr.Aufpreisgruppe;
      vArtGrp   # Art.Artikelgruppe;
      vArtikel  # Art.Nummer;
      vAdr      # 0;
      vErz      # 0;
      vLKZ      # '';
      vGuete    # '';
      vLiefAdr    # 0;
      vLiefAnschr # 0;
      vDicke    # Art.Dicke;
      vBreite   # Art.Breite;
      vLaenge   # "Art.Länge";
      vGewicht  # "Art.GewichtProStk";
      if (Art.MEH='Stk') then vStk # 1.0;
      vZeug     # '';
    end;


    400 : begin // Auftragskopf
      Erx # RecLink(403,400,13,_recFirst);
      WHILE (erx=_rOK) do begin
        if (Auf.Z.Position=0) and (Auf.Z.Rechnungsnr=0) and ("Auf.Z.Schlüssel"<>'') then begin
          Erx # Rekdelete(403,0,'AUTO');
          Erx # RecLink(403,400,13,_recFirst);
          CYCLE;
        end;
        Erx # RecLink(403,400,13,_recNext);
      END;

      vTyp # 'VK';
      vDat # today;
      vLiefAdr    # Auf.Lieferadresse;
      vLiefAnschr # Auf.Lieferanschrift;
      vGruppe   # 999;    // ST 2017-06-14: von 0 auf 999 um Kopfaufpreise klarer zu trennen
      Erx # RecLink(100,400,1,0);   // Kunde holen
      if (erx<=_rLocked) then vAdr # Adr.Nummer;
    end;


    401 : begin // Auftragspositionen
      Erx # RecLink(403,401,6,_recFirst);
      WHILE (erx=_rOK) do begin
        if (Auf.Z.Rechnungsnr=0) and ("Auf.Z.Schlüssel"<>'') then begin
          Erx # Rekdelete(403,0,'AUTO');
          Erx # RecLink(403,401,6,_recFirst);
          CYCLE;
        end;
        Erx # RecLink(403,401,6,_recNext);
      END;

      vTyp # 'VK';
      vDat # today;
      Erx # RecLink(819,401,1,0);   // Warengruppe holen
      if (erx<=_rLocked) then vGruppe # Wgr.Aufpreisgruppe;
      vArtikel  # Auf.P.Artikelnr;
      if (Wgr_Data:IstMix() or Wgr_Data:IstArt()) then begin
//      if (Auf.p.Wgr.Dateinr=c_Wgr_ArtMatMix) or
//        ((Auf.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisArtikel)) then begin
        Erx # RecLink(250,401,2,0); // Artikel holen
        if (erx<=_rLocked) then begin
          vArtGrp   # Art.Artikelgruppe;
          vArtikel  # Art.Nummer;
        end;
      end;
      Erx # RecLink(100,401,4,0);   // Kunde holen
      if (erx<=_rLocked) then vAdr # Adr.Nummer;
      Erx # RecLink(100,401,10,0);  // Erzeuger holen
      if (erx<=_rLocked) then begin
        vErz # Adr.Nummer;
        vLKZ # Adr.LKZ;
      end;
      vGuete    # "Auf.P.Güte";
      vDicke    # Auf.P.Dicke;
      vBreite   # Auf.P.Breite;
      vLaenge   # "Auf.P.Länge";
      vGewicht  # Auf.P.Gewicht;
      if (Art.MEH='Stk') then vStk # cnvfi("Auf.P.Stückzahl");
      vZeug     # Auf.P.Zeugnisart;
      vLiefAdr    # Auf.Lieferadresse;
      vLiefAnschr # Auf.Lieferanschrift;
    end;


    501 : begin // Bestellpositionen

      vLiefAdr    # Ein.Lieferadresse;
      vLiefAnschr # Ein.Lieferanschrift;

      Erx # RecLink(503,501,7,_recFirst);
      WHILE (erx=_rOK) do begin
        if ("Ein.Z.Schlüssel"<>'') then begin
          Erx # Rekdelete(503,0,'AUTO');
          Erx # RecLink(503,501,7,_recFirst);
          CYCLE;
        end;
        Erx # RecLink(503,501,7,_recNext);
      END;

      vTyp # 'EK';
      vDat # today;
      Erx # RecLink(819,501,1,0);   // Warengruppe holen
      if (erx<=_rLocked) then vGruppe # Wgr.Aufpreisgruppe;

        if (Wgr_Data:IstMix() or Wgr_Data:IstArt()) then begin
//      if (Ein.p.Wgr.Dateinr=c_Wgr_ArtMatMix) or
//        ((Ein.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Ein.P.Wgr.Dateinr<=c_Wgr_bisArtikel)) then begin
        Erx # RecLink(250,501,2,0); // Artikel holen
        if (erx<=_rLocked) then begin
          vArtGrp   # Art.Artikelgruppe;
          vArtikel  # Art.Nummer;
        end;
      end;

      Erx # RecLink(100,501,4,0);   // Lieferant holen
      if (erx<=_rLocked) then vAdr # Adr.Nummer;
      Erx # RecLink(100,501,11,0);  // Erzeuger holen
      if (erx<=_rLocked) then begin
        vErz # Adr.Nummer;
        vLKZ # Adr.LKZ;
      end;
      vGuete    # "Ein.P.Güte";
      vDicke    # Ein.P.Dicke;
      vBreite   # Ein.P.Breite;
      vLaenge   # "Ein.P.Länge";
      vGewicht  # Ein.P.Gewicht;
      if (Art.MEH='Stk') then vStk # cnvfi("Ein.P.Stückzahl");
      vZeug     # Ein.P.Zeugnisart;
    end;

    otherwise Todo('autopreise für diese Datei');
  end;

  if (aDatum<>0.0.0) then vDat # aDatum;


  vRecMode # _RecFirst;
  if (aNurKopf<>'') then begin
    if (StrCut(aNurKopf,1,1)='#') and (Str_COunt(aNurKopf,'/')=2) then begin
      ApL.Key1 # cnvia(Str_Token(aNurKopf,'/',1));
      ApL.Key2 # cnvia(Str_Token(aNurKopf,'/',2));
      ApL.Key3 # cnvia(Str_Token(aNurKopf,'/',3));
      aNurKopf # 'Y';
      vRecMode # 0;
    end;
  end;
  WHILE (RecRead(842,1,vRecmode)<=_rLocked) do begin
    if (aNurKopf<>'Y') then begin
      vRecMode # _RecNext;
//debug('test: '+cnvai(APL.Key1)+'.'+cnvai(APL.Key2)+'.'+cnvai(APL.Key3));
    // Automatische Anlage ???
      if (ApL.autoAnlegenYN=false) or (ApL.KalkulatorischYN) then CYCLE;

      // Gruppe ???
      if (ApL.Aufpreisgruppe<>0) and
        (ApL.Aufpreisgruppe<>vGruppe) then CYCLE;

      // für EK ???
      if (ApL.EinkaufYN=false) and (vTyp='EK') then CYCLE;

      // für VK ???
      if (ApL.VerkaufYN=false) and (vTyp='VK') then CYCLE;

      // Datumsbereich ???
      if ((ApL.Datum.Von<>0.0.0) or (ApL.Datum.Bis<>0.0.0)) and
        ((vDat<ApL.Datum.Von) or (vDat>ApL.Datum.Bis)) then CYCLE;
  //    if (ApL.Datum.Von<>0.0.0) and (vDat<ApL.Datum.Von) then CYCLE;
  //    if (ApL.Datum.Bis<>0.0.0) and (vDat>ApL.Datum.Bis) then CYCLE;

      // LKZ ???
      if ("ApL.gültigeLKZ"<>'') and
        (StrFind("ApL.gültigeLKZ",vLKZ,0)=0) then CYCLE;

      // Adresse ???
      if (ApL.Adressnummer<>0) and
        (ApL.Adressnummer<>vAdr) then CYCLE;

      // Erzeuger ???
      if (ApL.Erzeugernummer<>0) and
        (ApL.Erzeugernummer<>vErz) then CYCLE;
    end;  // NurKopf
  
//debug('KOPF ok '+cnvai(apl.key1)+'/'+cnvai(apl.key2)+'/'+cnvai(apl.key3));

    // Aufpreiskopf ist ok !!!
    vRecMode2 # _RecFirst;
    WHILE (RecLink(843,842,1,vRecmode2)<=_rLocked) do begin
      vRecMode2 # _RecNext;
      // Gruppe ???
      if (ApL.L.Aufpreisgruppe<>0) and
        (ApL.L.Aufpreisgruppe<>vGruppe) then CYCLE;
      // Güte ???
      if ("ApL.L.Güte"<>'') then begin
        "ApL.L.Güte"  # StrCnv("ApL.L.Güte",_StrLetter);
        vGuete        # StrCnv(vGuete,_StrLetter);
        if ((vGuete=*"ApL.L.Güte")=false) then CYCLE;
      end;
//debug('güte OK');
      // Dicke ???
      if ((ApL.L.Dicke.Von<>0.0) or (ApL.L.Dicke.Bis<>0.0)) and
        ((vDicke<ApL.L.Dicke.Von) or (vDicke>=ApL.L.Dicke.Bis)) then CYCLE;
      // Breite ???
      if ((ApL.L.Breite.Von<>0.0) or (ApL.L.Breite.Bis<>0.0)) and
        ((vBreite<ApL.L.Breite.Von) or (vBreite>=ApL.L.Breite.Bis)) then CYCLE;
      // Länge ???
      if (("ApL.L.Länge.Von"<>0.0) or ("ApL.L.Länge.Bis"<>0.0)) and
        ((vLaenge<"ApL.L.Länge.Von") or (vLaenge>="ApL.L.Länge.Bis")) then CYCLE;
      // Dicke ???
//      if (ApL.L.Dicke.Von<>0.0) and (vDicke<ApL.L.Dicke.Von) then CYCLE;
//      if (ApL.L.Dicke.Bis<>0.0) and (vDicke>ApL.L.Dicke.Bis) then CYCLE;
      // Breite ???
//      if (ApL.L.Breite.Von<>0.0) and (vBreite<ApL.L.Breite.Von) then CYCLE;
//      if (ApL.L.Breite.Bis<>0.0) and (vBreite>ApL.L.Breite.Bis) then CYCLE;
      // Länge ???
//      if ("ApL.L.Länge.Von"<>0.0) and (vLaenge<"ApL.L.Länge.Von") then CYCLE;
//      if ("ApL.L.Länge.Bis"<>0.0) and (vLaenge>"ApL.L.Länge.Bis") then CYCLE;

//debug('Abm OK');

      // Oberfläche ???
      if ((ApL.L.ObfNr<>0) or (ApL.L.ObfZusatz<>'')) and
        (CheckObf(aDatei,ApL.L.ObfNr,ApL.L.ObfZusatz)=false) then CYCLE;

      // Zeugnis ???
      if (ApL.L.Zeugnis<>'') and
        (vZeug<>ApL.L.Zeugnis) then CYCLE

      // Artikel ???
      if (ApL.L.Artikelnummer<>'') and
        (ApL.L.Artikelnummer<>vArtikel) then CYCLE;
//debug('Art OK');

      // Artikelgruppe ???
      if (ApL.L.Artikelgruppe<>0) and (ApL.L.Artikelgruppe2=0) and
        (ApL.L.Artikelgruppe<>vArtGrp) then CYCLE;
      if (ApL.L.Artikelgruppe>0) and (ApL.L.Artikelgruppe2>0) and
        ((ApL.L.Artikelgruppe>vArtGrp) or (ApL.L.Artikelgruppe2<vArtGrp)) then CYCLE;

      // Menge ???
      case ApL.L.Menge.MEH of

        '' : begin end;

        'kg' : if ((ApL.L.Menge.von<>0.0) or (ApL.L.Menge.bis<>0.0)) and
                  ((vGewicht<ApL.L.Menge.von) or (vGewicht>=ApL.L.Menge.bis)) then CYCLE

        'Stk' : if ((ApL.L.Menge.von<>0.0) or (ApL.L.Menge.bis<>0.0)) and
                  ((vStk<ApL.L.Menge.von) or (vStk>=ApL.L.Menge.bis)) then CYCLE

        otherwise TODO(ApL.L.Menge.MEH+' in AutoAufpreisen!!!');

      end;
//debug('Menge OK');

      // Adresse ???
      if (ApL.L.Adresse<>0) and
       (ApL.L.Adresse<>vAdr) then CYCLE;
//debug('Adr OK');

      // Erzeuger ???
      if (ApL.L.Erzeuger<>0) and
       (ApL.L.Erzeuger<>vErz) then CYCLE;
       
     
      // 11.07.2019
      if (ApL.L.LieferAdr<>0) then begin
        if (ApL.L.LieferAdr<>vLiefAdr) then CYCLE;
        if (ApL.L.LieferAnschr<>0) and (ApL.L.LieferAnschr<>vLiefAnschr) then CYCLE;
      end;
      
//debug('Erz OK');
//debug('nimm!!!!!!!!!!!!!!');

      // Aufpreis PASST !!!
      if (aSel=0) then
        NimmAufpreis(aDatei, aNurUpdate)
      else
        SelRecInsert(aSel,843);

    END;

    if (aNurKopf='Y') then BREAK;
  END;

  RETURN true;
end;


//========================================================================
//  HoleAufpreis
//
//========================================================================
sub HoleAufpreis(
  aKey          : alpha;
  aDat          : date;
  opt aNurKopf  : alpha) : int;
local begin
  Erx           : int;
  vK1,vK2,vK3   : int;
  vRecMode      : int;
  vK0           : int;
end;
begin

  vK1 # CnvIA(Str_Token(aKey,'.',1));
  vK2 # CnvIA(Str_Token(aKey,'.',2));
  vK3 # CnvIA(Str_Token(aKey,'.',3));


  if (aNurKopf<>'') then begin
    if (StrCut(aNurKopf,1,1)='#') and (Str_Count(aNurKopf,'/')=2) then begin
      vK0 # cnvia(Str_Token(aNurKopf,'/',1));
      if (cnvia(Str_Token(aNurKopf,'/',2))<>vK1) then RETURN _rNoRec;
      if (cnvia(Str_Token(aNurKopf,'/',3))<>vK2) then RETURN _rNoRec;
      ApL.L.Key1 # vK0;
      ApL.L.Key2 # vK1;
      ApL.L.Key3 # vK2;
      ApL.L.Key4 # vK3;
      Erx # RecRead(843,1,0);
      Erg # Erx; // TODOERX
      RETURN Erx;
    end;
  end;


  RecBufClear(842);
  ApL.Key2 # vK1;
  ApL.Key3 # vK2;

//debug(cnvad(aDat)+' suche APL :'+aint(vK1)+'/'+aint(vK2));
//  vRecMode # _recFirst;
  vRecMode # 0;
  WHILE (RecRead(842,2,vRecmode)<=_rMultiKey) and
   (ApL.Key2=vK1) and (ApL.Key3=vK2) do begin
//debug('check '+aint(apl.key1)+'/'+aint(apl.key2)+'/'+aint(apl.key3));
//debug('cehck KEY842');
    vRecMode # _RecNext;
    if ((ApL.Datum.Von<>0.0.0) or (ApL.Datum.Bis<>0.0.0)) and
      ((aDat<ApL.Datum.Von) or ((Apl.Datum.bis<>0.0.0) and (aDat>ApL.Datum.Bis))) then CYCLE;
    RecBufClear(843);
    ApL.L.Key1 # ApL.Key1;
    ApL.L.Key2 # vK1;
    ApL.L.Key3 # vK2;
    ApL.L.Key4 # vK3;
    Erx # RecRead(843,1,0);
//debug('read '+aint(apl.key1)+'/'+aint(apl.L.key1)+'/'+aint(apl.L.key2)+'/'+aint(apl.L.key3)+'   erg:ERG');
    if (Erx=_rOK) then begin
      Erg # Erx; // TODOERX
      RETURN _rOK;
    end;
  END;

  Erg # _rNoRec; // TODOERX
  RETURN _rNoRec;
end;


//========================================================================
//  Neuberechnen
//
//========================================================================
sub Neuberechnen(
  aDatei        : word;
  aDatum        : date;
  opt aNurKopf  : alpha;
) : int;
local begin
  Erx           : int;
  vTyp          : alpha(2);
  vNeuBerechnen : logic;
end;

begin

  case aDatei of

    400 : begin // Aufträge
      vTyp # 'VK';
      Erx # RecLink(403,400,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin

        if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,400, aDatum); // 25.11.2019 NEU: Datum

        if (Auf.Z.NeuberechnenYN) and (StrFind("Auf.Z.Schlüssel",'#',0)=1) then begin

          if (HoleAufpreis("Auf.Z.Schlüssel", aDatum, aNurKopf)=_rOK) then begin
            // Aufpreis PASST !!!
            RecRead(403,1,_recLock);
            Auf.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
            Auf.Z.MEH             # ApL.L.MEH;
            Auf.Z.PEH             # ApL.L.PEH;
            Auf.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
            Auf.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
            Auf.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
            Auf.Z.Preis           # ApL.L.Preis;

            // ST 2017-03-10: Bei Prozentauspreisen auch den Prozentsatz aus der Menge übernehemn
            if (ApL.L.MEH = '%') then
              Auf.Z.Menge # ApL.L.Menge;

            Erx # RekReplace(403,_recunlock,'AUTO');
            if (Erx<>_rOK) then RETURN Erx;
          end;
        end;

        Erx # RecLink(403,400,13,_RecNext);
      END;
    end;


    401 : begin // Auftragspos
      vTyp # 'VK';
      FOR Erx # RecLink(403,401,6,_RecFirst)
      LOOP Erx # RecLink(403,401,6,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,400, aDatum); // 25.11.2019 NEU: Datum

        if (Auf.Z.NeuberechnenYN) and (StrFind("Auf.Z.Schlüssel",'#',0)=1) then begin

          if (HoleAufpreis("Auf.Z.Schlüssel", aDatum, aNurKopf)=_rOK) then begin
            // Aufpreis PASST !!!
            RecRead(403,1,_recLock);
            Auf.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
            Auf.Z.MEH             # ApL.L.MEH;
            Auf.Z.PEH             # ApL.L.PEH;
            Auf.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
            Auf.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
            Auf.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
            Auf.Z.Preis           # ApL.L.Preis;

            // ST 2017-03-10: Bei Prozentauspreisen auch den Prozentsatz aus der Menge übernehemn
            if (ApL.L.MEH = '%') then
              Auf.Z.Menge # ApL.L.Menge;

            Erx # RekReplace(403,_recunlock,'AUTO');
            if (Erx<>_rOK) then RETURN Erx;
          end;
        end;
      END;
    end;


    500 : begin // Bestellungen
      vTyp # 'EK';
      Erx # RecLink(503,500,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin

        if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,500);

        if (Ein.Z.NeuberechnenYN) and (StrFind("Ein.Z.Schlüssel",'#',0)=1) then begin

          if (HoleAufpreis("Ein.Z.Schlüssel", aDatum, aNurKopf)=_rOK) then begin
            // Aufpreis PASST !!!
            RecRead(503,1,_recLock);
            Ein.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
            Ein.Z.MEH             # ApL.L.MEH;
            Ein.Z.PEH             # ApL.L.PEH;
            Ein.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
            Ein.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
            Ein.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
            Ein.Z.Preis           # ApL.L.Preis;

            // ST 2017-03-10: Bei Prozentauspreisen auch den Prozentsatz aus der Menge übernehemn
            if (ApL.L.MEH = '%') then
              Ein.Z.Menge # ApL.L.Menge;

            Erx # RekReplace(503,_recunlock,'AUTO');
            if (Erx<>_rOK) then RETURN Erx;
          end;
        end;

        Erx # RecLink(503,500,13,_RecNext);
      END;
    end;

    501 : begin // Einkaufspos
      vTyp # 'EK';
      FOR Erx # RecLink(503,501,7,_RecFirst)
      LOOP Erx # RecLink(503,501,7,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,500, aDatum); // 25.11.2019 NEU: Datum

        if (Ein.Z.NeuberechnenYN) and (StrFind("Ein.Z.Schlüssel",'#',0)=1) then begin

          if (HoleAufpreis("Ein.Z.Schlüssel", aDatum, aNurKopf)=_rOK) then begin
            // Aufpreis PASST !!!
            RecRead(503,1,_recLock);
            Ein.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
            Ein.Z.MEH             # ApL.L.MEH;
            Ein.Z.PEH             # ApL.L.PEH;
            Ein.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
            Ein.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
            Ein.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
            Ein.Z.Preis           # ApL.L.Preis;

            // ST 2017-03-10: Bei Prozentauspreisen auch den Prozentsatz aus der Menge übernehemn
            if (ApL.L.MEH = '%') then
              Ein.Z.Menge # ApL.L.Menge;

            Erx # RekReplace(503,_recunlock,'AUTO');
            if (Erx<>_rOK) then RETURN Erx;
          end;
        end;
      END;
    end;

    
    otherwise Todo('Aufpreis-Neuberechnung für diese Datei');
  end;

  RETURN _rOK;
end;

//========================================================================