@A+
//===== Business-Control =================================================
//
//  Prozedur    Sta_Data
//
//  Info        Managed die Statistikdatei (für ODBC mit z.B.Excel)
//              ohne E_R_G
//
//  25.04.2006  AI  Erstellung der Prozedur
//  23.07.2015  AH  Neu Feld "Sta.Auf.Sachbearbeit"
//  31.07.2015  AH  "StorniereRe" LÖSCHT statt nur als gelöscht zu markieren
//  19.08.2015  AH  STA nimmt Auf.Intrastat und Lfs.Lieferant auf
//  15.08.2016  AH  Erlöskorrektur beachten
//  13.01.2017  AH  Kopfaufpreise werden in STA verbucht, AFX "Sta.Verbuchen.VorInsert"
//  16.01.2017  AH  Setting "Set.Wie.Fakt.OhneNK" zum Deaktivieren der Rundungen des VK-Preises in Aktion/Mat/Statistik
//  16.08.2017  AH  AFX "Sta.Verbuchen.Post"
//  10.11.2020  AH  BEL-LF wird gebucht
//  01.03.2021  AH  BEL-LF werde auch storniert
//  27.07.2021  AH  ERX
//  06.09.2021  AH  Stornos nicht in Statistik erneut eintragen (Proj. 2224/32)
//
//  Subprozeduren
//    SUB Verbuchen(aTyp : alpha) : logic
//    SUB StorniereRe(aNr : int; aStornoNr : int);
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  cRE   : 'RE'
  cGut  : 'GUT'
  cBel  : 'BEL'
end;

//========================================================================
//  Verbuchen
//            Verbucht einen Vorfall in die Statistikdatei
//========================================================================
sub Verbuchen(
  aTyp          : alpha;
  opt aDeltaEK  : float;
  opt aDeltaIK  : float;
  opt aDeltaVK  : float;
  opt aMatNr    : int;
) : logic
local begin
  Erx     : int;
  vFilter : int;
  vNr     : int;
  vGP     : alpha;
  vX,vF   : float;
end;
begin


// s.u.  if (RunAFX('Sta_Verbuchen',aTyp+'|'+anum(aDeltaEK,2)+'|'+anum(aDeltaIK,2)+'|'+anum(aDeltaVK,2)+'|'+aint(aMatNr))<>0) then RETURN (Erx=_rOK);


  // Statistik abgeschaltet? -> Ende
  if (Set.StatistikYN=n) then RETURN true;

  vGP # Translate('Grundpreis');

  case aTyp of
    'BEL-LF-POS' : begin
      vFilter # RecFilterCreate(899,1);
      vFilter->RecFilterAdd(1,_FltAnd,_flteq,y);
      vFilter->RecFilterAdd(2,_FltAnd,_flteq,'VK');
      Erx # RecRead(899,1,_recLast,vFilter);  // nächste Nummer bestimmen
      if (erx=_rnorec) then vNr # 1
      else vNr # Sta.Nummer + 1;

      RecBufClear(899);
      Sta.EigenYN         # y;
      Sta.Typ             # 'BEL-LF';

      // Rechnungsdaten setzen...
      Sta.Re.StornoRechNr # Erl.StornoRechnr;
      Sta.Re.Typ          # Erl.Rechnungstyp;
      Sta.Re.Nummer       # Erl.K.Rechnungsnr;
      Sta.Re.Position     # Erl.K.Rechnungspos;
      Sta.Re.Datum        # Erl.Rechnungsdatum;
      Sta.Re.Empf.KdNr    # Erl.Kundennummer;
      Sta.Re.Empf.SW      # Erl.Kundenstichwort;
      Sta.Re.Vertreter.Nr # Erl.Vertreter;
      Sta.Re.Verband.Nr   # Erl.Verband;
      "Sta.Re.Währung"    # "Erl.Währung";
      Sta.Re.Adr.Steuersch  # Erl.Adr.Steuerschl;
      Sta.Re.Art.Steuersch  # Erl.K.Steuerschl;


      Erx # RecLink(110,899,4,_recFirst);     // Vertreter holen
      if (erx>_rLocked) then RecBufClear(110);
      Sta.Re.Vertreter.SW   # Ver.Stichwort;
      Erx # RecLink(110,899,5,_recFirst);     // Verband holen
      if (erx>_rLocked) then RecBufClear(110);
      Sta.Re.Verband.SW     # Ver.Stichwort;
      Erx # RecLink(814,899,6,_recFirst);     // Währung holen
      if (erx>_rLocked) then RecBufClear(814);
      "Sta.Re.Währung.Kurz" # "Wae.Kürzel";

      // Steuerschlüssel holen...
      //StS.Nummer # (Sta.Re.Art.Steuersch * 100) + Sta.Re.Adr.Steuersch;
      StS.Nummer # Sta.Re.Art.Steuersch;
      Erx # RecRead(813,1,0);
      if (erx<=_rLocked) then Sta.Re.Steuerprozent # StS.Prozent;

      // Auftragskopfdaten setzen...
      Sta.Auf.Nummer        # Erl.K.Auftragsnr;
      Sta.Auf.Vorgangstyp   # Auf.Vorgangstyp;
      Sta.Auf.Datum         # Auf.Datum;
      Sta.Auf.Bestell.Nr    # Auf.Best.Nummer;
      Sta.Auf.Bestell.Dat   # Auf.Best.Datum;
      Sta.Auf.Kunden.Nr     # Auf.Kundennr;
      Sta.Auf.Kunden.SW     # Auf.Kundenstichwort;
      Sta.Auf.Sachbearbeit  # Auf.Sachbearbeiter;

      Erx # RecLink(100,899,1,_recFirst);     // Kunde holen
      if (erx>_rLocked) then RecBufClear(100);
      Sta.Auf.Kunden.LKZ    # Adr.LKZ;
      Adr_Data:HoleOrt(Adr.LKZ, Adr.PLZ);     // Region holen...
      Sta.Auf.Kunden.Regio  # Ort.Bundesland;

      Sta.Auf.LieferAdr.Nr  # Auf.Lieferadresse;
      Sta.Auf.LiefAnsch.Nr  # Auf.Lieferanschrift;
      Erx # RecLink(101,899,7,_recFirst);     // Lieferanschrift holen
      if (erx>_rLocked) then RecBufClear(101);
      Sta.Auf.LiefAnschLKZ  # Adr.A.LKZ;
      Adr_Data:HoleOrt(Adr.A.LKZ, Adr.A.PLZ); // Region holen...
      Sta.Auf.LiefAnschReg  # Ort.Bundesland;

      Sta.Auf.VerbrauAdrNr  # Auf.Verbraucher;
      Erx # RecLink(100,899,8,_recFirst);     // Verbraucher holen
      if (erx>_rLocked) then RecBufClear(100);
      Sta.Auf.Verbrauch.SW  # Adr.Stichwort;


      // Positionsdaten setzen...
      Sta.Auf.Position      # Auf.P.Position;
      Sta.Auf.Auftragsart   # Erl.K.Auftragsart;
      Sta.Auf.Warengruppe   # Erl.K.Warengruppe;
      Sta.Auf.Projekt.Nr    # Auf.P.Projektnummer;
      Sta.Auf.PEH           # Auf.P.PEH;

      Sta.Auf.Artikel.Nr    # Auf.P.Artikelnr;
      Sta.Auf.Strukturnr    # Auf.P.Strukturnr;
      Sta.Auf.IntrastatNr   # Auf.P.Intrastatnr;
      Sta.Auf.Artikel.SW    # Auf.P.ArtikelSW;
      Sta.Auf.ArtikelRefNr  # Auf.P.KundenArtNr;
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
        Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
        if (erx<=_rLocked) then
          Sta.Auf.Artikelgrp    # Art.Artikelgruppe;
      end;

      "Sta.Auf.Güte"          # "Auf.P.Güte";
      Sta.Auf.Werkstoff.Nr    # Auf.P.Werkstoffnr;
      "Sta.Auf.Ausführung.O"  # Auf.P.AusfOben;
      "Sta.Auf.Ausführung.U"  # Auf.P.AusfUnten;
      Sta.Auf.Dicke           # Auf.P.Dicke;
      Sta.Auf.Breite          # Auf.P.Breite;
      "Sta.Auf.Länge"         # "Auf.P.Länge";
      Sta.Auf.Termin.Art      # Auf.P.Termin1W.Art;
      Sta.Auf.Termin.Zahl     # Auf.P.Termin1W.Zahl;
      Sta.Auf.Termin.Jahr     # Auf.P.Termin1W.Jahr;
      Sta.Auf.Termin          # Auf.P.Termin1Wunsch;

      vX # 0.0;
      if (Erl.K.Menge<>0.0) then
        vX # ((Erl.K.BetragW1 + Erl.K.KorrekturW1) / Erl.K.Menge);

      Sta.Lfs.Artikelnr     # Erl.K.Artikelnummer;

      Sta.Menge.VK          # Erl.K.Menge;
      Sta.MEH.VK            # Erl.K.MEH;
      "Sta.Stück.VK"        # "Erl.K.Stückzahl";
      Sta.Gewicht.Netto.VK  # Erl.K.Gewicht;
      Sta.Gewicht.BruttoVK  # Erl.K.Gewicht;

      Sta.Betrag.EK         # Erl.K.EKPreisSummeW1;
      Sta.Lohnkosten        # Erl.K.InterneKostW1;
      Sta.Betrag.VK         # Erl.K.BetragW1;
      Sta.Korrektur.VK      # 0.0;
      Sta.Steuer.VK         # Rnd((Sta.Betrag.VK + Sta.Aufpreis.VK) * Sta.Re.Steuerprozent / 100.0, 2);

      if (RunAFX('Sta.Verbuchen.VorInsert','')<>0) then begin
        if (AfxRes<>_rOK) then RETURN false;
      end;

      REPEAT
        Sta.Nummer            # vNr;
        Erx # Rekinsert(899,0,'AUTO');
        if (Erx<>_rOK) then  vNr # vNr + 1;
      UNTIl (erx=_rOK);

      RETURN True;
    end;



    'KORREKTUR' : begin
      if (Erl.K.AuftragsPos=0) then RETURN true; // Kopfaufpreis

      Erx # Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, true);
      if (erx<400) then RETURN false;

      if (Erl.K.BetragW1<>0.0) then
        vF # aDeltaVK / Erl.K.BetragW1;

      RecBufClear(899);
      vFilter # RecFilterCreate(899,2);
      vFilter->RecFilterAdd(1,_FltAnd,_flteq,y);
      vFilter->RecFilterAdd(2,_FltAnd,_flteq,'VK');
      vFilter->RecFilterAdd(3,_FltAnd,_flteq, Erl.K.Rechnungsnr);

      FOR Erx # RecRead(899,2,_RecFirst,vFilter)
      LOOP Erx # RecRead(899,2,_recNext,vFilter)
      WHILE (erx<=_rMultiKey) do begin
        if (Sta.Auf.Position<>Erl.K.Auftragspos) then CYCLE;

        if (aMatNr<>0) and (aDeltaVk=0.0) then begin
          if (Sta.Lfs.Materialnr<>aMatNr) then CYCLE;
        end;

        RecRead(899,1,_recLock);
        // VK-Korrektur...
        if (aDeltaVK<>0.0) then begin
          if (vF<>0.0) then begin
            //Sta.Korrektur.VK # Rnd(Sta.Korrektur.VK + (Sta.Betrag.VK * vF),2);
            Sta.Korrektur.VK # Rnd(Sta.Korrektur.VK + (Erl.K.BetragW1 * vF),2);
          end
          else begin  // per Menge verteilen
            vX # 0.0;
            if (Erl.K.Menge<>0.0) then
              vX # Sta.Menge.VK / Erl.K.Menge;
            Sta.Korrektur.VK # Rnd(Sta.Korrektur.VK + (aDeltaVK * vF),2);
          end;
        end;

        if (aMatNr=Sta.Lfs.Materialnr) then begin
          Sta.Betrag.EK   # Sta.Betrag.EK + aDeltaEK;
          Sta.Lohnkosten  # Sta.Lohnkosten + aDeltaIk;
        end;

        RekReplace(899);
      END;

      vFilter->RecFilterDestroy();

      RunAFX('Sta.Verbuchen.Post',aTyp);

      RETURN true;
    end;



    // *********************************************************************
    cRE,cBEL,cGUT : begin            // VK-Rechnung

    // 06.09.2021 AH: KEINE STORNOS !!!!
      if (Erl.Rechnungstyp<>c_Erl_VK) and
      (Erl.Rechnungstyp<>c_Erl_Gut) and
      (Erl.Rechnungstyp<>c_Erl_ReKor) and // 15.09.2021 AH
      (Erl.Rechnungstyp<>c_Erl_Bogut) and
      (Erl.Rechnungstyp<>c_Erl_Bel_KD) and
      (Erl.Rechnungstyp<>c_Erl_Bel_LF) then RETURN true;

      vFilter # RecFilterCreate(899,1);
      vFilter->RecFilterAdd(1,_FltAnd,_flteq,y);
      vFilter->RecFilterAdd(2,_FltAnd,_flteq,'VK');

      FOR Erx # RecLink(451,450,1,_RecFirst)    // Erlöskonten loopen
      LOOP Erx # RecLink(451,450,1,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        if (Erl.K.Steuerschl=0) then CYCLE;  // 05.08.2016 AH: Holzrichters "Sonderkonten" überspringen

        // 13.01.2017 AH: Neu für Kopfaufpreise
        if (Erl.K.AuftragsPos=0) then begin // Kopfaufpreis
          if (Erl.K.AuftragsNr=0) then CYCLE;
          Auf.Nummer # Erl.K.AuftragsNr;
          Erx # RecRead(400,1,0);
          if (Erx>_rLocked) then begin
            "Auf~Nummer" # Erl.K.AuftragsNr;
            Erx # RecRead(410,1,0);
            if (Erx>_rLocked) then CYCLE;
            RecBufCopy(410,400);
          end;


          Erx # RecRead(899,1,_recLast,vFilter);  // nächste Nummer bestimmen
          if (erx=_rnorec) then vNr # 1
          else vNr # Sta.Nummer + 1;

          RecBufClear(899);
          Sta.EigenYN         # y;
          Sta.Typ             # 'VK';

          // Rechnungsdaten setzen...
          Sta.Re.StornoRechNr # Erl.StornoRechnr;
          Sta.Re.Typ          # Erl.Rechnungstyp;
          Sta.Re.Nummer       # Erl.K.Rechnungsnr;
          Sta.Re.Position     # Erl.K.Rechnungspos;
          Sta.Re.Datum        # Erl.Rechnungsdatum;
          Sta.Re.Empf.KdNr    # Erl.Kundennummer;
          Sta.Re.Empf.SW      # Erl.Kundenstichwort;
          Sta.Re.Vertreter.Nr # Erl.Vertreter;
          Sta.Re.Verband.Nr   # Erl.Verband;
          "Sta.Re.Währung"    # "Erl.Währung";
          Sta.Re.Adr.Steuersch  # Erl.Adr.Steuerschl;
          Sta.Re.Art.Steuersch  # Erl.K.Steuerschl;


          Erx # RecLink(110,899,4,_recFirst);     // Vertreter holen
          if (erx>_rLocked) then RecBufClear(110);
          Sta.Re.Vertreter.SW   # Ver.Stichwort;
          Erx # RecLink(110,899,5,_recFirst);     // Verband holen
          if (erx>_rLocked) then RecBufClear(110);
          Sta.Re.Verband.SW     # Ver.Stichwort;
          Erx # RecLink(814,899,6,_recFirst);     // Währung holen
          if (erx>_rLocked) then RecBufClear(814);
          "Sta.Re.Währung.Kurz" # "Wae.Kürzel";

          // Steuerschlüssel holen...
          StS.Nummer # Sta.Re.Art.Steuersch;
          Erx # RecRead(813,1,0);
          if (erx<=_rLocked) then Sta.Re.Steuerprozent # StS.Prozent;

          // Auftragskopfdaten setzen...
          Sta.Auf.Nummer        # Erl.K.Auftragsnr;
          Sta.Auf.Vorgangstyp   # Auf.Vorgangstyp;
          Sta.Auf.Datum         # Auf.Datum;
          Sta.Auf.Bestell.Nr    # Auf.Best.Nummer;
          Sta.Auf.Bestell.Dat   # Auf.Best.Datum;
          Sta.Auf.Kunden.Nr     # Auf.Kundennr;
          Sta.Auf.Kunden.SW     # Auf.Kundenstichwort;
          Sta.Auf.Sachbearbeit  # Auf.Sachbearbeiter;

          Erx # RecLink(100,899,1,_recFirst);     // Kunde holen
          if (erx>_rLocked) then RecBufClear(100);
          Sta.Auf.Kunden.LKZ    # Adr.LKZ;
          Adr_Data:HoleOrt(Adr.LKZ, Adr.PLZ);     // Region holen...
          Sta.Auf.Kunden.Regio  # Ort.Bundesland;

          Sta.Auf.LieferAdr.Nr  # Auf.Lieferadresse;
          Sta.Auf.LiefAnsch.Nr  # Auf.Lieferanschrift;
          Erx # RecLink(101,899,7,_recFirst);     // Lieferanschrift holen
          if (erx>_rLocked) then RecBufClear(101);
          Sta.Auf.LiefAnschLKZ  # Adr.A.LKZ;
          Adr_Data:HoleOrt(Adr.A.LKZ, Adr.A.PLZ); // Region holen...
          Sta.Auf.LiefAnschReg  # Ort.Bundesland;

          Sta.Auf.VerbrauAdrNr  # Auf.Verbraucher;
          Erx # RecLink(100,899,8,_recFirst);     // Verbraucher holen
          if (erx>_rLocked) then RecBufClear(100);
          Sta.Auf.Verbrauch.SW  # Adr.Stichwort;


          // Positionsdaten setzen...
          Sta.Auf.Position      # Erl.K.Auftragspos;
          Sta.Auf.Auftragsart   # Erl.K.Auftragsart;
          Sta.Auf.Warengruppe   # Erl.K.Warengruppe;
          Sta.Auf.Projekt.Nr    # 0;
          Sta.Auf.PEH           # 0;

          Sta.Auf.Artikel.Nr    # Erl.K.Artikelnummer;
          if (Sta.Auf.Artikel.Nr<>'') then begin
            Art.Nummer # Sta.Auf.Artikel.Nr;
            Erx # RecRead(250,1,0);   // Artikel holen
            if (erx<=_rLocked) then begin
              Sta.Auf.Artikelgrp    # Art.Artikelgruppe;
              Sta.Auf.Artikel.SW    # '';
            end;
          end;
          Sta.Auf.Strukturnr    # '';
          Sta.Auf.IntrastatNr   # '';
          Sta.Auf.ArtikelRefNr  # '';

          vX # 0.0;
          if (Erl.K.Menge<>0.0) then
            vX # ((Erl.K.BetragW1 + Erl.K.KorrekturW1) / Erl.K.Menge);

          Sta.Menge.VK          # Erl.K.Menge;
          Sta.MEH.VK            # Erl.K.MEH;
          "Sta.Stück.VK"        # "Erl.K.Stückzahl";
          Sta.Gewicht.Netto.VK  # Erl.K.Gewicht;
          Sta.Gewicht.BruttoVK  # Erl.K.Gewicht;

          Sta.Betrag.EK         # Erl.K.EKPreisSummeW1;// - Auf.A.InterneKostW1;
          Sta.Lohnkosten        # Erl.K.InterneKostW1;

          Sta.Aufpreis.VK       # Erl.K.BetragW1;
          Sta.Betrag.VK         # 0.0;
          Sta.Korrektur.VK      # Erl.K.KorrekturW1;
          Sta.Steuer.VK         # Rnd((Sta.Betrag.VK + Sta.Aufpreis.VK) * Sta.Re.Steuerprozent / 100.0, 2);

          if (RunAFX('Sta.Verbuchen.VorInsert','')<>0) then begin
            if (AfxRes<>_rOK) then CYCLE;
          end;

          REPEAT
            Sta.Nummer            # vNr;
            Erx # Rekinsert(899,0,'AUTO');
            if (Erx<>_rOK) then  vNr # vNr + 1;
          UNTIl (erx=_rOK);

          CYCLE;
        end;


        // NICHT Kopfaufpreis -------------------------------------------------------------
        // kein Grundpreis??? -> ENDE
        if (Erl.K.Bemerkung<>vGP) then CYCLE;

        Erx # RecLink(401,451,8,_recFirst);     // Auftragspos. holen
        if (erx>_rLocked) then begin
          Erx # RecLink(411,451,9,_recFirst);   // ~Auftragspos. holen
          if (erx>_rLocked) then begin
            CYCLE;
          end;

          Erx # RecLink(410,411,3,_recFirst);   // ~AufKopf holen
          RecBufCopy(411,401);
          RecBufCopy(410,400);
        end
        else begin
          Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
        end;

        RecBufClear(250);
        if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
          Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
          if (erx>_rLocked) then begin
            RecBufClear(250);
            RecBufClear(254);
          end
          else begin
            Art_P_Data:LiesPreis('Ø-EK',0);     // Durchschnittspreis holen
          end;
        end;



        Erx # RecRead(899,1,_recLast,vFilter);  // nächste Nummer bestimmen
        if (erx=_rnorec) then vNr # 1
        else vNr # Sta.Nummer + 1;

        RecBufClear(899);
        Sta.EigenYN         # y;
        Sta.Typ             # 'VK';

        // Rechnungsdaten setzen...
        Sta.Re.StornoRechNr # Erl.StornoRechnr;
        Sta.Re.Typ          # Erl.Rechnungstyp;
        Sta.Re.Nummer       # Erl.K.Rechnungsnr;
        Sta.Re.Position     # Erl.K.Rechnungspos;
        Sta.Re.Datum        # Erl.Rechnungsdatum;
        Sta.Re.Empf.KdNr    # Erl.Kundennummer;
        Sta.Re.Empf.SW      # Erl.Kundenstichwort;
        Sta.Re.Vertreter.Nr # Erl.Vertreter;
        Sta.Re.Verband.Nr   # Erl.Verband;
        "Sta.Re.Währung"    # "Erl.Währung";
        Sta.Re.Adr.Steuersch  # Erl.Adr.Steuerschl;
        Sta.Re.Art.Steuersch  # Erl.K.Steuerschl;


        Erx # RecLink(110,899,4,_recFirst);     // Vertreter holen
        if (erx>_rLocked) then RecBufClear(110);
        Sta.Re.Vertreter.SW   # Ver.Stichwort;
        Erx # RecLink(110,899,5,_recFirst);     // Verband holen
        if (erx>_rLocked) then RecBufClear(110);
        Sta.Re.Verband.SW     # Ver.Stichwort;
        Erx # RecLink(814,899,6,_recFirst);     // Währung holen
        if (erx>_rLocked) then RecBufClear(814);
        "Sta.Re.Währung.Kurz" # "Wae.Kürzel";

        // Steuerschlüssel holen...
        //StS.Nummer # (Sta.Re.Art.Steuersch * 100) + Sta.Re.Adr.Steuersch;
        StS.Nummer # Sta.Re.Art.Steuersch;
        Erx # RecRead(813,1,0);
        if (erx<=_rLocked) then Sta.Re.Steuerprozent # StS.Prozent;

        // Auftragskopfdaten setzen...
        Sta.Auf.Nummer        # Erl.K.Auftragsnr;
        Sta.Auf.Vorgangstyp   # Auf.Vorgangstyp;
        Sta.Auf.Datum         # Auf.Datum;
        Sta.Auf.Bestell.Nr    # Auf.Best.Nummer;
        Sta.Auf.Bestell.Dat   # Auf.Best.Datum;
        Sta.Auf.Kunden.Nr     # Auf.Kundennr;
        Sta.Auf.Kunden.SW     # Auf.Kundenstichwort;
        Sta.Auf.Sachbearbeit  # Auf.Sachbearbeiter;

        Erx # RecLink(100,899,1,_recFirst);     // Kunde holen
        if (erx>_rLocked) then RecBufClear(100);
        Sta.Auf.Kunden.LKZ    # Adr.LKZ;
        Adr_Data:HoleOrt(Adr.LKZ, Adr.PLZ);     // Region holen...
        Sta.Auf.Kunden.Regio  # Ort.Bundesland;

        Sta.Auf.LieferAdr.Nr  # Auf.Lieferadresse;
        Sta.Auf.LiefAnsch.Nr  # Auf.Lieferanschrift;
        Erx # RecLink(101,899,7,_recFirst);     // Lieferanschrift holen
        if (erx>_rLocked) then RecBufClear(101);
        Sta.Auf.LiefAnschLKZ  # Adr.A.LKZ;
        Adr_Data:HoleOrt(Adr.A.LKZ, Adr.A.PLZ); // Region holen...
        Sta.Auf.LiefAnschReg  # Ort.Bundesland;

        Sta.Auf.VerbrauAdrNr  # Auf.Verbraucher;
        Erx # RecLink(100,899,8,_recFirst);     // Verbraucher holen
        if (erx>_rLocked) then RecBufClear(100);
        Sta.Auf.Verbrauch.SW  # Adr.Stichwort;


        // Positionsdaten setzen...
        Sta.Auf.Position      # Auf.P.Position;
        Sta.Auf.Auftragsart   # Erl.K.Auftragsart;
        Sta.Auf.Warengruppe   # Erl.K.Warengruppe;
        Sta.Auf.Projekt.Nr    # Auf.P.Projektnummer;
        Sta.Auf.PEH           # Auf.P.PEH;

        Sta.Auf.Artikel.Nr    # Auf.P.Artikelnr;
        Sta.Auf.Strukturnr    # Auf.P.Strukturnr;
        Sta.Auf.IntrastatNr   # Auf.P.Intrastatnr;
        Sta.Auf.Artikel.SW    # Auf.P.ArtikelSW;
        Sta.Auf.ArtikelRefNr  # Auf.P.KundenArtNr;
        if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
          Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
          if (erx<=_rLocked) then
            Sta.Auf.Artikelgrp    # Art.Artikelgruppe;
        end;

        "Sta.Auf.Güte"          # "Auf.P.Güte";
        Sta.Auf.Werkstoff.Nr    # Auf.P.Werkstoffnr;
        "Sta.Auf.Ausführung.O"  # Auf.P.AusfOben;
        "Sta.Auf.Ausführung.U"  # Auf.P.AusfUnten;
        Sta.Auf.Dicke           # Auf.P.Dicke;
        Sta.Auf.Breite          # Auf.P.Breite;
        "Sta.Auf.Länge"         # "Auf.P.Länge";
        Sta.Auf.Termin.Art      # Auf.P.Termin1W.Art;
        Sta.Auf.Termin.Zahl     # Auf.P.Termin1W.Zahl;
        Sta.Auf.Termin.Jahr     # Auf.P.Termin1W.Jahr;
        Sta.Auf.Termin          # Auf.P.Termin1Wunsch;


        vX # 0.0;
        if (Erl.K.Menge<>0.0) then
          vX # ((Erl.K.BetragW1 + Erl.K.KorrekturW1) / Erl.K.Menge);

        // AKTIONEN LOOPEN ******************************
        FOR Erx # RecLink(404,451,7,_recFirst)
        LOOP Erx # RecLink(404,451,7,_recNext)
        WHILE (erx<=_rLocked) do begin

          if (Auf.A.Aktionstyp=c_Akt_LFS) then begin
            Sta.Lfs.Nummer    # Auf.A.AktionsNr;
            Sta.Lfs.Position  # Auf.A.Aktionspos;
            Sta.Lfs.Datum     # Auf.A.TerminEnde;
          end;

          if (Auf.A.Aktionstyp=cGUT) and
            (Auf.A.Menge.Preis=0.0) then Auf.A.Menge.Preis # Auf.A.Menge;

//  TODO         Sta.Menge.Einsatz
//   "       Sta.MEH.Einsatz
//   "       Sta.Stück.Einsatz
          Sta.Lfs.Materialnr    # Auf.A.Materialnr;
          if (Auf.A.Materialnr<>0) then begin
            Erx # Mat_Data:Read(Auf.A.Materialnr);
            if (erx>=200) then
              Sta.Lfs.Lieferant.nr  # Mat.Lieferant;
          end;
          Sta.Lfs.Artikelnr     # Auf.A.Artikelnr;
          Sta.Lfs.Art.Charge    # Auf.A.Charge;
          if (Auf.A.Artikelnr<>'') and (Auf.A.Charge<>'') then begin
            Erx # RecLink(252,404,4,_recfirst); // Charge holen
            if (erx<=_rLocked) then
              Sta.Lfs.Lieferant.nr  # Art.C.Lieferantennr;
          end;

          Sta.Menge.VK          # Auf.A.Menge.Preis;
          Sta.MEH.VK            # Auf.A.MEH.Preis;
          "Sta.Stück.VK"        # "Auf.A.Stückzahl";
          Sta.Gewicht.Netto.VK  # Auf.A.Nettogewicht;
          Sta.Gewicht.BruttoVK  # Auf.A.Gewicht;

          Sta.Betrag.EK         # Auf.A.EKPreisSummeW1;// - Auf.A.InterneKostW1;
          Sta.Lohnkosten        # Auf.A.InterneKostW1;

          if (Set.Wie.Fakt.OhneNK) then
            Sta.Aufpreis.VK       # Auf.A.RechPreisW1 - (vX * Auf.A.Menge.Preis)
          else
            Sta.Aufpreis.VK       # Auf.A.RechPreisW1 - Rnd(vX * Auf.A.Menge.Preis,2);
          Sta.Betrag.VK         # Auf.A.RechPreisW1 - Sta.Aufpreis.VK;
          Sta.Korrektur.VK      # Auf.A.RechKorrektW1;
          Sta.Steuer.VK         # Rnd((Sta.Betrag.VK + Sta.Aufpreis.VK) * Sta.Re.Steuerprozent / 100.0, 2);

          if (RunAFX('Sta.Verbuchen.VorInsert','')<>0) then begin
            if (AfxRes<>_rOK) then CYCLE;
          end;

          REPEAT
            Sta.Nummer            # vNr;
            Erx # Rekinsert(899,0,'AUTO');
            if (Erx<>_rOK) then  vNr # vNr + 1;
          UNTIl (erx=_rOK);

        END;  // Auf.Aktionen

      END;  // Erlös.Kontierung


      vFilter->RecFilterDestroy();
    end // RE
    // *********************************************************************


    otherwise
      TODO('STA-Typ '+aTyp);
  end;


  RunAFX('Sta.Verbuchen.Post',aTyp);


  RETURN true;
end;


//========================================================================
//  StorniereRe
//
//========================================================================
sub StorniereRe(
  aNr       : int;
  aStornoNr : int;
)
local begin
  Erx     : int;
end;
begin

  RecBufClear(899);
  Sta.EigenYN   # y;
  Sta.Typ       # 'VK';
  Sta.Re.Nummer # aNr;
  Erx # RecRead(899,2,0);
  WHILE (erx<=_rMultikey) and (Sta.EigenYN) and (Sta.Typ='VK') and (Sta.Re.Nummer=aNr) do begin
//    RecRead(899,1,_recLock);
//    Sta.Re.StornoRechNr # aStornoNr;
//    RekReplace(899,_RecUnlock,'AUTO');
//    Erx # RecRead(899,2,_recNext);

    // 31.07.2015 nur "als storiert markieren" nützt nichts, da OST_NEU versuchen würde die komplett neu aufzubauen und das mangels
    //          AUFTRAGSAKTIONEN nicht klappen würde. D.h. VOR der OST_Neu wären die stornierten Erlöse drinm danach weg -> BÖSe
    Erx # RekDelete(899);

    Erx # RecRead(899,2,0);
  END;

  // 01.03.2021 AH: auch BEL-LF
  RecBufClear(899);
  Sta.EigenYN   # y;
  Sta.Typ       # 'BEL-LF';
  Sta.Re.Nummer # aNr;
  Erx # RecRead(899,2,0);
  WHILE (erx<=_rMultikey) and (Sta.EigenYN) and (Sta.Typ='BEL-LF') and (Sta.Re.Nummer=aNr) do begin
    Erx # RekDelete(899);
    Erx # RecRead(899,2,0);
  END;

end;

//========================================================================
