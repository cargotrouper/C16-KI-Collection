@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_Data
//                OHNE E_R_X
//  Info
//
//
//  19.01.2004  AI  Erstellung der Prozedur
//  06.02.2009  ST  Wiedervorlagedatumsberechnung hinzugefügt
//  07.08.2009  AI  Gut/Bel zu Rechnungspos. in deren AufAktion schreiben
//  06.09.2009  MS  Material zuordnen bei Gewichtsaenderungen Mat.Karte anpassen + Eintrag ins Bestandsbuch
//  10.03.2010  AI  Faktura-Routinen nach Lib_Faktura geschoben
//  07.04.2010  AI  sub Finalaufpreise
//  15.04.2010  AI  AFX Auf.P.Mat.DFakt.Plausi
//  25.10.2010  AI  BruttoNetto in LFS.P
//  03.11.2010  MS  Auf2Verpackung
//  02.12.2011  AI  VLDAW_Pos_einfügen_Mat errechnet Menge über 200 nicht 404 (Projekt 1371/32)
//  15.02.2012  ST  VLDAW_Pos_Einfuegen_Mat schreibt Paketnummer in LFS Position (Projekt 1381/8)
//  28.02.2012  AI  DFAKT bringt andere Meldungen für Teil- oder Komplettstückzahl
//  22.03.2012  AI  NEU: Adr-VPG mit Erzeuger
//  30.05.2012  AI  Rechnungsanschrift in SetRechnungsempf
//  02.10.2012  MS  SetVsbDatKommMat
//  15.11.2012  AI  "SetVsbDatKommMat" nutzt einen Tree
//  22.11.2012  AI  NEU: "ReadLohnBA"
//  04.02.2013  AI  "auf2Verpackung" übernimmt Artikelnummer
//  20.03.2013  AI  DFkatMat_DoIt: Füllt Auf.A.Artikelnr mit Material-Strukturnr
//  11.04.2013  AI  MatMEH
//  29.08.2013  AH  NEU: "SetKundenMatArtNr"
//  23.09.2013  AH  BUGFIX: "VerbucheArt" entfernt Auftragsmenge immer beim Löschen
//  15.10.2013  AH  VLDAW_Pos_Einfuegen_Mat nimmt Menge aus Material
//  11.11.2013  AH  Edit Paras: "SetKundenMatArtNr"
//  09.01.2013  AH  "Verpackung2Auf" : ggf. Artikel-Intrastatnr. nachreichen
//  18.02.2014  AH  Bug: SetWgrDateinr hat bei MAtMix ohne Art.Nr. als MEH irgendwas genommen, jetzt KG
//  14.04.2014  TM  "SetLieferAdr" hinzugefügt
//  28.04.2014  AJ  Neu: "ReadKopf"
//  15.05.2014  AH  "VLDAW_Pos_Einfuegen_Mat" nimmt Auf.P.MEH.Einsatz
//  30.07.2014  AH  NEU: "PosReplace" + "PosInsert"
//  24.09.2014  AH  Bufix: "Pos_BerechneMarker" rechnet Rech.Menge in Auf.P.MEH um
//  22.01.2015  AH  Bug: SetWgrDateinr hat bei "Mix" als "Mat" angesehen
//  09.02.2015  AH  BAG-Vorlage und EinsatzVPG
//  07.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  10.04.2015  AH  "Read" kann auch Stückliste lesen
//  18.06.2015  AH  "Rechnungslauf" optimiert (Appon/AppOff)
//  30.07.2015  AH  AFX "MatzMat.Maske.Vorbelegung"
//  01.07.2016  AH  "MatzMat" akzeptiert reserviertes Material
//  14.07.2016  AH  Kopfrabatte werden mit in Position gerechnet
//  09.09.2016  AH  "VererbeKopfReferenzInPos"
//  07.10.2016  AH  "MatzMat" akzeptiert reserviertes Material auch für aAUTO
//  02.11.2016  AH  "MatMatGuBe"
//  10.11.2016  AH  PAbruf
//  09.02.2017  AH  Lieferverträge bekommen keine Kreditlimitsperre
//  15.02.2017  AH  Fix: "FinalAufpreise" verspringt Aufpreis nicht mehr
//  08.08.2017  ST  "PasstAuf2Mat" Güte erweitert
//  07.11.2017  ST  Anker "Auf.PasstAuf2Mat" hinzugefügt
//  05.12.2017  AH  Fix "FinalAufpreis" nimmt Menge in MEH.Einsatz statt MEH.Preis !!!
//  29.01.2018  AH  AnalyseErweitert
//  13.06.2018  AH  Fix: Adr.V.Datum.Bis
//  06.12.2018  ST  Fix: Matz Plausi aufgrund Konsigeschäfte umgestellt
//  02.01.2019  AH  Fix: "Verpackung2Auf" beim nachträglichen Ändern: kopiert erweiterte Analyse + Texte
//  26.07.2019  AH  Fix: Statistikverbuchung
//  23.09.2019  ST  Fix: Auftragstexte->Kundenartikel funktioniert wieder
//  17.12.2019  ST  Fix: DFaktMat_DoIt: Aktionsdatum aus Übergabeparameter  (Verbuchungsdatum) Projekt 2036/35
//  20.01.2020  AH  Neu: Adress-Aufpreise
//  16.07.2020  AH  Fix: "SumAufpreise" ruft SperrPruef mit richtigen alten Buffern auf
//  23.11.2020  AH  Neu: AbrufVerbuchen setzt Löschmakrer am Rahmen
//  31.03.2021  AH  Neu: AFX "Auf.P.Pos.BerechneMarker"
//  07.09.2021  AH  Edit: MATZ fragt Splittung ab je nach Setting
//  07.09.2021  AH  ERX
//  05.10.2021  AH  "PasstAuf2Mat" liefert INT statt LOGIC
//  11.10.2021  AH  Rahmen/Abruf: Verbuchung in Artikel korrigiert? (VFP?)
//  10.11.2021  AH  "VeraenderteLieferadresse"
//  01.04.2022  AH  "VerteileAbrufeInSL"
//  19.05.2022  AH  Fix für Abrufmengenedit (HOW)
//  2023-03-06  AH  "FkatMat" kann auch für andere AufPos. als aktuelle
//  2023-08-01 TM: Plausibilitätskontrolle: Fehlschlagsmeldung um MatNr. erweitert
//
//  Subprozeduren
//    SUB PosReplace(aLock : int; aGrund : alpha) : int;
//    SUB PosInsert(aLock : int; aGrund : alpha) : int;
//
//    SUB SetWgrDateinr(aNr : int);
//    SUB SetVsbDatMatZuAuf()
//    SUB PasstAuf2Mat(opt aMat : int; opt aSL : logic;opt aMan : logic) : int;
//    SUB Auf2Verpackung(opt aSilent : logic);
//    SUB FinalAufpreise(aWert : float; aPosMenge : float; aPosStk : int; aPosGew : float) : float;
//    SUB SumGesamtpreis(aPosMenge : float; aPosStk : int; aPosGew : float) : float;
//    SUB SumEKGesamtpreis();
//    SUB SaveRabatt(aName : alpha; aWert : float);
//    SUB SumAufpreise();
//    SUB TerminCopy();
//    SUB BildeAFString(aSeite : alpha) : alpha;
//    SUB Pos_BerechneMarker();
//    SUB BerechneMarker();
//    SUB VerbucheArt(aAltArt: alpha; aAltMenge : float; aAltMarke : alpha);
//    SUB DeletePos();
//    SUB DeleteKopf();
    //    SUB DFaktBel();
//    SUB DFaktMat_DoIt(aUmbuchen : logic; aStk : int; aGewNetto : float; aGewBrutto : float; aMenge : float; aDatum: date) : logic;
//    SUB DFaktMat(aMatNr : int; aMan : logic; opt aDat : aDate) : logic;
//    SUB MatzMat(aAuto : logic; opt aVersand : logic; opt aStk : int; opt aGewNetto : float; opt aGewBrutto : float; opt aMenge : float; opt aSLNr : int) : logic;
//    SUB MatzMatGuBe(aMatNr : int) : logic;
//    SUB ReservMat();
//    SUB VLDAW_Pos_Einfuegen_Art(aNr : int; var aPos : int; aSLNr : int) : logic;
//    SUB VLDAW_Pos_Einfuegen_Mat(aNr : int; var aPos : int; aSLNr : int) : logic;
//    SUB UpdateVLDAW() : logic;
//    SUB Rechnungslauf();
//    SUB Read(aAufNr : int; aPos : int; amitKopf : logic; opt aSLNr : int) : int
//    SUB ReadKopf(aAufNr : int) : int
//    SUB ModifyArtikel();
//    SUB ChangeArtikel()
//    SUB VerbucheAbruf(aNeu : logic) : logic
//    SUB SetKundennr (aNeu : int);
//    SUB SetRechnungsempf (aNeu : int; ; opt aAnschrift : int);
//    SUB SetLieferAdr (aNeu : int; ; opt aAnschrift : int);

//    SUB SumAufWert() : float;
//    SUB KreditLimitCheck(aAufWert : float; aDel : logic)
//    SUB FreigabeErrechnen(aSum  : float; aUser : alpha);
//    SUB SperrPruefung(aBuf401 : int; opt aDel : logic);
//    SUB ReadLohnBA() : logic;
//    sub SetKundenMatArtNr(aAdr : int; aVpgNr : int; aCopyData : logic; aArtNr : alpha) : logic;
//    SUB VererbeKopfReferenzInPos(aAlt : alpha; aNeu : alpha);
//    SUB VeraenderteLieferadresse() : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG

declare SumGesamtpreis(aPosMenge : float; aPosStk : int; aPosGew : float) : float;
declare Pos_BerechneMarker();
declare BerechneMarker();
declare KreditlimitCheck(aAufWert : float; aDel : logic);
declare SperrPruefung(aBuf401 : int; opt aDel : logic);


//========================================================================
//  PosReplace
//========================================================================
SUB PosReplace(
  aLock   : int;
  aGrund  : alpha) : int;
local begin
  v401    : int;
  Erx     : int;
  vModNew : logic;
  vM      : float;
  vGew    : float;
  vStk    : int;
end;
begin
/*** 25.07.2019
  v401  # RecBufCreate(401);
  RecRead(v401,0,_recId, RecInfo(401,_recID));

  // 07.04.2017 AH:
//  Auf_K_Data:SumKalkulation();
  Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);

  vErx # RekReplace(401, aLock, aGrund);
  if (Erx=_rOK) and (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) and (Auf.P.Aktionsmarker<>'N') then begin
    if (v401->Auf.P.Aktionsmarker='N') then
      Auf_P_Subs:StatistikBuchen(0, 0)
    else
      Auf_P_Subs:StatistikBuchen(0, v401);
  end;
  RecBufDestroy(v401);
***/

  vModNew # (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) and (Auf.P.Aktionsmarker<>'N');

  v401  # RecBufCreate(401);
  if (vModNew) then begin
    v401->Auf.P.Nummer    # Auf.P.Nummer;
    v401->Auf.P.Position  # Auf.P.Position;
    Erx # RecRead(v401,1,0);
    if (Erx>_rLocked) or (v401->Auf.P.Aktionsmarker='N')
    //or ((v501->"Ein.P.Löschmarker"='*') and ("Ein.P.Löschmarker"=''))
    then begin
      RecbufClear(v401);
      v401->"Auf.P.Löschmarker" # "Auf.P.Löschmarker";
    end;
  end;

  Erx # RekReplace(401, aLock, aGrund);

  if (Erx=_rOK) and (vModNew) then begin
    Auf_P_Subs:StatistikBuchen(0, v401);

    // 26.07.2019
    if ((v401->"Auf.P.Löschmarker"='*') and ("Auf.P.Löschmarker"='')) then begin
      vM    # Auf.P.Prd.Rest;
      vStk  # Auf.P.Prd.Rest.Stk;
      vGew  # Auf.P.Prd.Rest.Gew;
    end
    else if ((v401->"Auf.P.Löschmarker"='') and ("Auf.P.Löschmarker"='*')) then begin
      vM    # -Auf.P.Prd.Rest;
      vStk  # -Auf.P.Prd.Rest.Stk;
      vGew  # -Auf.P.Prd.Rest.Gew;
    end
    else begin
      vM    # Auf.P.Prd.Rest      - v401->Auf.P.Prd.Rest;
      vStk  # Auf.P.Prd.Rest.Stk  - v401->Auf.P.Prd.Rest.Stk;
      vGew  # Auf.P.Prd.Rest.Gew  - v401->Auf.P.Prd.Rest.Gew;
    end;
    
    if (vM<>0.0) or (vGew<>0.0) or (vStk<>0) then begin
      if (RunAFX('Auf.P.Replace.Mengenaenderung',anum(vM,3)+'|'+anum(vGew,2)+'|'+aint(vStk))<>0) then begin
        if (AfxRes<>_rOK) then RETURN AfxRes;
      end;
    end;

  end;
  RecBufDestroy(v401);

  Erg # Erx;    // TODOERG
  
  RETURN Erx;
end;
  

//========================================================================
//  PosInsert
//========================================================================
SUB PosInsert(
  aLock   : int;
  aGrund  : alpha) : int;
local begin
  Erx     : int;
end;
begin

  Erx # RekInsert(401, aLock, aGrund);
  if (ErX=_rOK) and (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) and (Auf.P.Aktionsmarker<>'N') then
    Auf_P_Subs:StatistikBuchen(0, 0);

  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


//========================================================================
// SetWgrDateinr
//
//========================================================================
sub SetWgrDateinr(aNr : int);
local begin
  Erx : int;
end;
begin

    if (Mode<>c_modeview) and (Mode<>c_modeList) then begin
    // Materialtyp unterscheiden...
    Lib_GuiCom:Able($edAuf.P.RID_Mat,         !(Wgr_Data:WertBlockenBeiTyp(401, 'RID')));
    Lib_GuiCom:Able($edAuf.P.RIDMax_Mat,      !(Wgr_Data:WertBlockenBeiTyp(401, 'RID')));
    Lib_GuiCom:Able($edAuf.P.RAD_Mat,         !(Wgr_Data:WertBlockenBeiTyp(401, 'RAD')));
    Lib_GuiCom:Able($edAuf.P.RADMax_Mat,      !(Wgr_Data:WertBlockenBeiTyp(401, 'RAD')));
    Lib_GuiCom:Able($edAuf.P.Dicke_Mat,       !(Wgr_Data:WertBlockenBeiTyp(401, 'D')));
    Lib_GuiCom:Able($edAuf.P.Dickentol_Mat,   !(Wgr_Data:WertBlockenBeiTyp(401, 'D')));
    Lib_GuiCom:Able($edAuf.P.Breite_Mat,      !(Wgr_Data:WertBlockenBeiTyp(401, 'B')));
    Lib_GuiCom:Able($edAuf.P.Breitentol_Mat,  !(Wgr_Data:WertBlockenBeiTyp(401, 'B')));
    Lib_GuiCom:Able($edAuf.P.Laenge_Mat,      !(Wgr_Data:WertBlockenBeiTyp(401, 'L')));
    Lib_GuiCom:Able($edAuf.P.Laengentol_Mat,  !(Wgr_Data:WertBlockenBeiTyp(401, 'L')));
  end;
  Auf.P.Wgr.Dateinr # aNr;
  if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
    if (Auf.P.Artikelnr<>'') then begin
      Erx # RecLink(250,401,2,_RecFirst); // Artikel holen
      if (Erx=_rOK) and ("Art.ChargenführungYN") then Auf.P.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Auf.P.Wgr.Dateinr);
    end;
  end
//  else if (Wgr_data:IstMixArt(Auf.P.Wgr.Dateinr)) then begin
  else if (Wgr_data:IstMix(Auf.P.Wgr.Dateinr)) then begin   // 22.01.2015
    if (Auf.P.Artikelnr<>'') then begin
      Erx # RecLink(250,401,2,_RecFirst); // Artikel holen
      if (Erx<=_rLocked) then Auf.P.MEH.Einsatz  # Art.MEH;
    end
    else begin
      Auf.P.MEH.Einsatz  # 'kg';  // 18.02.2014
    end;
  end
  else if (Auf.P.Wgr.Dateinr=0) or (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_data:IstMixMat(Auf.P.Wgr.Dateinr)) then begin
    Auf.P.MEH.Einsatz  # 'kg';
    Auf.P.MEH.Wunsch   # 'kg';
  end;

end;


//========================================================================
//  SetVsbDatKommMat
//    Setzt das VSB Datum kommissionierter Materialkarten
//========================================================================
sub SetVsbDatKommMat(
  aTree : int)
local begin
  Erx     : int;
  vBuf401 : int;
  vItem   : int;
end;
begin
/**
  vBuf401 # RecBufCreate(401);
  FOR vErx # RecLink(vBuf401, 400, 9, _recFirst); // Auftragspos. loopen
  LOOP vErx # RecLink(vBuf401, 400, 9, _recNext);
  WHILE(vErx <= _rLocked) DO BEGIN

    vErx # RecLink(835, vBuf401, 5,_recFirst);   // Auftragsart holen
    if(Erx > _rLocked) then
      RecBufClear(835);

    FOR vErx # RecLink(200, vBuf401, 17, _recFirst); // Material loopen
    LOOP vErx # RecLink(200, vBuf401, 17, _recNext);
    WHILE(vErx <= _rLocked) DO BEGIN
      if(Mat.Datum.VSBMeldung <> 00.00.0000) then
        CYCLE;
***/
  FOR vItem # CteRead(aTree,_ctefirst)
  LOOP vItem # CteRead(aTree,_ctenext, vItem)
  WHILE (vItem<>0) do begin

    // Aktion loopen
    Erx # RecRead(404,0,_recid, vItem->spid);
    if (Erx<=_rLocked) and (Auf.A.Materialnr<>0) then begin
      Erx # RekLink(200,404,6,_recFirst);   // Material holen
      if (Erx<=_rLocked) then begin
        Erx # RecRead(200, 1, _recLock) // Material sperren
        if (Erx < _rOK) then begin
          Msg(001001, AInt(Mat.Nummer), 0, 0, 0);
          CYCLE;
        end;

        Mat.Datum.VSBMeldung # today; // Datum setzen

        Erx # RekReplace(200, 0, 'AUTO'); // Material zurueckspeichern
        if (Erx <> _rOK) then begin
          Msg(001000 + Erx, gTitle, 0, 0, 0);
          CYCLE;
        end;
      end; // MAt
    end; // Akt

  END;

  RecBufDestroy(vBuf401);
end;


//========================================================================
//  PasstAuf2Mat
//
//========================================================================
sub PasstAuf2Mat(
  aMat  : int;
  aSL   : logic;
  aMan  : logic;) : int;    // <0 ABBRUCH, 0=Abfrage, >0 OK
local begin
  vBuf200 : int;
  vOK     : logic;
end;
begin
  // ST 2017-11-07 Projekt 1630/1712
  if (RunAFX('Auf.PasstAuf2Mat',Aint(aMat)+ '|' + Aint(CnvIl(aSL))+'|'+aBool(aMan))<>0) then
    RETURN (AfxRes);

  vBuf200 # RecBufCreate(200);
  if (aMat=0) then begin
    RecbufCopy(200,vBuf200)
  end
  else begin
    vBuf200->mat.Nummer # aMat;
    if (RecRead(vBuf200,1,0)>_rLockeD) then RecBufClear(vBuf200);
  end;
  if (aSL) then
    vOK # (Mat.Dicke=Auf.SL.Dicke) and (Mat.Breite=Auf.SL.Breite) and ("Mat.Länge"="Auf.SL.Länge")
  else
    vOK # (Mat.Dicke=Auf.P.Dicke) and (Mat.Breite=Auf.P.Breite) and ("Mat.Länge"="Auf.P.Länge") and ("Mat.Güte"="Auf.P.Güte");
  RecBufDestroy(vBuf200);

  if (vOK) then RETURN 1  //  gut
  else RETURN 0;          //  abfragen!
end;


//========================================================================
//  Verpackung2Auf
//      Adr.Verpackung in Auftragspos. kopieren
//========================================================================
Sub Verpackung2Auf(
  aNeuanlage  : logic;
  opt aMitAP  : logic) : logic;
local begin
  Erx     : int;
  vTxtName    : alpha;
  vTxtHdlAsc  : handle;
  vTxtHdlRtf  : handle;
  vTxtName2   : alpha;
  v250        : int;
  vI          : int;
end
begin

  Auf.P.Verpacknr       # Adr.V.lfdNr;
  Auf.P.VerpackAdrNr    # Adr.V.Adressnr;
  Auf.P.KundenArtNr     # Adr.V.KundenArtNr;
  Auf.P.VpgText1        # Adr.V.VpgText1;
  Auf.P.VpgText2        # Adr.V.VpgText2;
  Auf.P.VpgText3        # Adr.V.VpgText3;
  Auf.P.VpgText4        # Adr.V.VpgText4;
  Auf.P.VpgText5        # Adr.V.VpgText5;
  Auf.P.VpgText6        # Adr.V.VpgText6;
  Auf.P.Skizzennummer   # Adr.V.Skizzennummer;

  if (aNeuanlage) then begin
    if(Adr.V.Warengruppe <> 0) then
      Auf.P.Warengruppe     # Adr.V.Warengruppe;
    RecLink(819,401,1,0);   // Warengruppe holen
    If (Wgr_Data:IstMix()=false) then begin
      Auf.P.Strukturnr      # Adr.V.Strukturnr;
      $edAuf.P.Artikelnr_Mat->wpcaption # Auf.P.Strukturnr;
    End
    else begin
      Auf.P.Artikelnr       # Adr.V.Strukturnr;
      $edAuf.P.Artikelnr_Mat->wpcaption # Auf.P.Artikelnr;

      // 09.01.2013 ggf. Intrastatnr. nachreichen
      if (Auf.P.Artikelnr<>'') then begin
        v250 # RecbufCreate(250);
        Erx # RecLink(v250,401,2,_RecFirst); // Artikel holen
        if (Erx<=_rLocked) then
          Auf.P.Intrastatnr   # v250->Art.Intrastatnr;
        RecBufDestroy(v250);
      end;

    End;
    vI # Auf.P.Wgr.Dateinr;
    SetWgrDateinr(Wgr.Dateinummer);

    if (vI<>Auf.P.Wgr.Dateinr) then begin
//    $edAuf.P.KundenArtNr->winupdate(_Winupdon,_WinUpdFld2Obj);
//    $edAuf.P.KundenArtNr->wpcaption # Auf.P.KundenArtNr;
//debugx(Auf.P.KundenArtNr);
      Auf_P_SMain:Switchmask(false);    // 06.04.2020
      Auf.P.KundenArtNr # Adr.V.KundenArtNr;
      $edAuf.P.KundenArtNr->winupdate(_Winupdon,_WinUpdFld2Obj);
      $edAuf.P.KundenMatArtNr_Mat->winupdate(_Winupdon,_WinUpdFld2Obj);
//    $edAuf.P.KundenArtNr->wpcaption # Auf.P.KundenArtNr;
//debugx(Auf.P.KundenArtNr);
    end;  // Dateinr wechsel?
      
  end
  else begin
    if ((Adr.v.Strukturnr<>'') and (Auf.P.Artikelnr<>Adr.V.Strukturnr)) or
       ((Adr.v.Warengruppe<>0) and (Auf.P.Warengruppe<>Adr.V.Warengruppe)) then begin
      Error(401022,'');
      RETURN false;
     end;
  end;



  "Auf.P.Güte"          # "Adr.V.Güte";
  "Auf.P.Gütenstufe"    # "Adr.V.Gütenstufe";

  Auf.P.Werkstoffnr     # MQu_data:GetWerkstoffnr("Auf.P.Güte");

  SbrCopy(105,5,401,3);   // Analyse kopieren
  if (Set.LyseErweitertYN) then begin
    if (aNeuanlage) then begin
      Lib_MoreBufs:RecInit(105, y, y);
    end
    else begin
      Lib_MoreBufs:CopyNew(231, '', 105, 401, true);
    end;
  end;
  
  Auf.P.Intrastatnr     # Adr.V.Intrastatnr;
  Auf.P.AusfOben        # Adr.V.AusfOben;
  Auf.P.AusfUnten       # Adr.V.AusfUnten;
  Auf.P.Dicke           # Adr.V.Dicke;
  Auf.P.DickenTol       # Adr.V.DickenTol;
  Auf.P.Breite          # Adr.V.Breite;
  Auf.P.BreitenTol      # Adr.V.BreitenTol;
  "Auf.P.Länge"         # "Adr.V.Länge";
  "Auf.P.LängenTol"     # "Adr.V.LängenTol";
  Auf.P.RID             # Adr.V.RID;
  Auf.P.RIDmax          # Adr.V.RIDmax;
  Auf.P.RAD             # Adr.V.RAD;
  Auf.P.RADmax          # Adr.V.RADmax;
  Auf.P.Zeugnisart      # Adr.V.Zeugnisart;
  Auf.P.Erzeuger        # Adr.V.Erzeuger;
  Auf.P.VorlageBAG      # Adr.V.VorlageBAG;
  Auf.P.EinsatzVPG.Adr  # Adr.V.EinsatzVPG.Adr;
  Auf.P.EinsatzVPG.Nr   # Adr.V.EinsatzVPG.Nr;

//  RefreshIfm('edAuf.P.Erzeuger_Mat',y);

  // RTF-Text kopieren...
  vTxtName # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.' +
             CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4); // 21.07.2015 Länge 7/4
  if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
    vTxtName2 # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01'
  else
    vTxtName2 # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
   TxtDelete(vTxtName2,0);
   TxtCopy(vTxtName, vTxtName2,0);

  Auf.P.TextNr1 # Adr.V.TextNr1;
  Auf.P.TextNr2 # Adr.V.TextNr2;
  if (Auf.P.TextNr1=105) then begin
    vTxtName # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.' +
               CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01'; // 21.07.2015 Länge 7/4
    vTxtHdlAsc # $Auf.P.TextEditPos->wpdbTextBuf;
    if (vTxtHdlAsc<>0) then TextRead(vTxtHdlAsc, vTxtName,0);

    if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
      vTxtName2 # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vTxtName2 # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);

    if (aNeuanlage=false) then begin
      TxtDelete(vTxtName2,0);
      TxtCopy(vTxtName, vTxtName2,0);
    end;

    // Geänderten Indvidualtext an Position updaten
    $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
    Auf.P.TextNr1 # 401;
    Auf.P.TextNr2 # 0;
    $edAuf.P.TextNr2b->wpCaptionInt # 0;
    $Auf.P.TextEditPos->wpcustom # vTxtName2;
    $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
    $cb.Text2->wpcheckstate # _WinStateChkUnchecked;
    $cb.Text3->wpCheckState # _WinStateChkChecked;
    $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
//    RefreshIfm('Text');
  end;

  // ggf. Preis übernehmen....
  if (Adr.V.PreisW1<>0.0) and
    ((Adr.V.Datum.Bis=0.0.0) or (Adr.V.Datum.Bis>=Auf.Datum)) then begin
    Auf.P.MEH.Preis # Adr.V.MEH;
    Auf.P.PEH       # Adr.V.PEH;
    Auf.P.Grundpreis # Adr.V.PreisW1;
    if ("Auf.Währung"<>1) then begin
      Erx # RecLink(814,400,8,_recFirst);  // Währung holen
      if ("Auf.WährungFixYN") then
        Wae.VK.Kurs       # "Auf.Währungskurs";
      Auf.P.Grundpreis # Rnd(Adr.V.PreisW1 * "Wae.VK.Kurs",2)
    end;
  end;

  Auf.P.AbbindungL      # Adr.V.AbbindungL;
  Auf.P.AbbindungQ      # Adr.V.AbbindungQ;
  Auf.P.Zwischenlage    # Adr.V.Zwischenlage;
  Auf.P.Unterlage       # Adr.V.Unterlage;
  Auf.P.Umverpackung    # Adr.V.Umverpackung;
  Auf.P.Wicklung        # Adr.V.Wicklung;
  Auf.P.MitLfEYN        # Adr.V.MitLfEYN;
  Auf.P.StehendYN       # Adr.V.StehendYN;
  Auf.P.LiegendYN       # Adr.V.LiegendYN;
  Auf.P.Nettoabzug      # Adr.V.Nettoabzug;
  "Auf.P.Stapelhöhe"    # "Adr.V.Stapelhöhe";
  Auf.P.StapelhAbzug    # Adr.V.StapelhAbzug;
  Auf.P.RingKgVon       # Adr.V.RingKgVon;
  Auf.P.RingKgBis       # Adr.V.RingKgBis;
  Auf.P.KgmmVon         # Adr.V.KgmmVon;
  Auf.P.KgmmBis         # Adr.V.KgmmBis;
  "Auf.P.StückProVE"      # "Adr.V.StückProVE";
  Auf.P.VEkgMax         # Adr.V.VEkgMax;
  Auf.P.RechtwinkMax    # Adr.V.RechtwinkMax;
  Auf.P.EbenheitMax     # Adr.V.EbenheitMax;
  "Auf.P.SäbeligkeitMax" # "Adr.V.SäbeligkeitMax";
  "Auf.P.SäbelProM"     # "Adr.V.SäbelProM";
  Auf.P.Etikettentyp    # Adr.V.Etikettentyp;
  Auf.P.Verwiegungsart  # Adr.V.Verwiegungsart;

  // Ausführugen löschen & kopieren
  WHILE (RecLink(402,401,11,_recFirst)=_rOK) do
    RekDelete(402,0,'MAN');
  Erx # RecLink(106,105,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Auf.AF.Nummer   # Auf.P.Nummer;
    Auf.AF.Position # Auf.P.Position;
    Auf.AF.Seite    # Adr.V.AF.Seite;
    Auf.AF.lfdNr    # Adr.V.AF.lfdNr;
    Auf.AF.ObfNr    # Adr.V.AF.ObfNr;
    Auf.AF.Bezeichnung  # Adr.V.AF.Bezeichnung;
    Auf.AF.Zusatz   # Adr.V.AF.Zusatz;
    Auf.AF.Bemerkung    # ADr.V.AF.Bemerkung;
    "Auf.AF.Kürzel" # "Adr.V.AF.Kürzel";
    Erx # RekInsert(402,0,'MAN');
    Erx # RecLink(106,105,1,_recNext);
  END;

  if (aMitAP) then begin
    // Aupreise löschen & kopieren    20.01.2020 AH
    WHILE (RecLink(403,401,6,_recFirst)=_rOK) do
      RekDelete(403,0,'MAN');

    FOR Erx # RecLink(104,105,9,_recFirst)
    LOOP Erx # RecLink(104,105,9,_recNext)
    WHILE (Erx<=_rLocked) do begin
      RecBufClear(403);
      Auf.Z.Nummer      # Auf.P.Nummer;
      Auf.Z.Position    # Auf.P.Position;
      Auf.Z.lfdNr       # Adr.V.Z.lfdNr;
      "Auf.Z.Schlüssel" # "Adr.V.Z.Schlüssel";
      if (Apl_data:HoleAufpreis("Auf.Z.Schlüssel", today)=_rNoRec) then CYCLE;
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
      if (ApL.Aufpreisgruppe=999) then begin
        Auf.Z.Position    # 0;   // Kopfaufpreis
        Auf.Z.LfdNr       # 1;
        REPEAT
          Erx # RekInsert(403,0,'MAN');
          if (Erx<>_rOK) then inc(Auf.Z.LfdNr);
        UNTIL (Erx=_rOK);
      end
      else begin
        RekInsert(403,0,'MAN');
      end;
    END;
  end;
  
  
  if (aNeuanlage=false) then
    Auf_Data:SumAufpreise(c_ModeEdit)
  else
    Auf_Data:SumAufpreise();
  $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
  $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);

  $lb.P.Einzelpreis_Mat->wpcaption  # ANum(Auf.P.Einzelpreis,2);
  $lb.Kalkuliert->wpcaption         # ANum(Auf.P.Kalkuliert,2);
  $lb.Poswert->wpcaption            # ANum(Auf.P.Gesamtpreis,2);
  $lb.Poswert_Mat->wpcaption        # ANum(Auf.P.Gesamtpreis,2);
  $lb.Rohgewinn->wpcaption          # ANum(Auf.P.Gesamtpreis - "Auf.P.GesamtwertEKW1",2);
  $lb.Aufpreise->wpcaption          # ANum(Auf.P.Aufpreis,2);
  $lb.Aufpreise_Mat->wpcaption      # ANum(Auf.P.Aufpreis,2);

  // ST 2010-02-25: Projekt 1161/190
  // ggf. Übernahme des Kundenartikeltextes
  begin

    // Neu bei gefüllter Kundenartikelnummer
    if (Auf.P.KundenArtNr <> '') then begin

      // Prüfen ob es einen Kundenartikeltext gibt,
      // wenn ja, dann den Text in den Individualtext kopieren

      // RTF-Text kopieren...
      vTxtName # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.' +
                 CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4); // 21.07.2015 Länge 7/4
      if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
        vTxtName2 # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01'
      else
        vTxtName2 # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
      TxtCopy(vTxtName, vTxtName2,0);

      Auf.P.TextNr1 # Adr.V.TextNr1;
      Auf.P.TextNr2 # Adr.V.TextNr2;
      if (Auf.P.TextNr1=105) then begin
        vTxtName # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.' +
                   CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01'; // 21.07.2015 Länge 7/4
        vTxtHdlAsc # $Auf.P.TextEditPos->wpdbTextBuf;
        if (vTxtHdlAsc<>0) then TextRead(vTxtHdlAsc, vTxtName,0);

        if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
          vTxtName # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
        else
          vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        // Geänderten Indvidualtext an Position updaten
        $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
        Auf.P.TextNr1 # 401;
        Auf.P.TextNr2 # 0;
        $edAuf.P.TextNr2b->wpCaptionInt # 0;
        $Auf.P.TextEditPos->wpcustom # vTxtName;
        $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
        $cb.Text2->wpcheckstate # _WinStateChkUnchecked;
        $cb.Text3->wpCheckState # _WinStateChkChecked;
        $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
//        RefreshIfm('Text');
      end;
    end;
  end;

// 2023-05-30 AH Fix
  if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) and (Art.Nummer<>'') then begin    // 03.06.2020 AH Proj. 2101/14
    Auf.P.ArtikelSW   # Art.Stichwort;
    Auf.P.MEH.Einsatz   # Art.MEH;
    Auf.P.MEH.Wunsch    # Auf.P.MEH.Einsatz;
  end;

  RunAFX('Auf.P.Auswahl.KdMatArtNr','');

  RETURN true;
end;


//========================================================================
// Auf2Verpackung
//  generiert eine Verpackungsvorschrift, fuer den Kunden des Auftrags
//  mit den Auftragsdaten
//========================================================================
sub Auf2Verpackung(opt aSilent : logic);
local begin
  Erx     : int;
  vBuf105       : int;
  vTxtNameAdrV  : alpha;
  vTxtNameAuf   : alpha;
  vI            : int;
end;
begin
  if (Mode=c_ModeList) then
    RecRead(gFile,0,0,gZLList->wpdbrecid);

  Erx # RecLink(100, 401, 4, _recFirst); // Kunden Adr. lesen
  if(Erx > _rLocked) then
    RecBufClear(100);

  if (!aSilent) then
    if (Msg(401019, Adr.Stichwort + '|' +  AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position), _WinIcoQuestion, _WinDialogYesNo, 2) <> _WinIdYes) then
      RETURN;

  Erx # RekLink(819,401,1,_RecFirst);   // Warengruppe holen

  TRANSON;

  // Hauptdaten
  Adr.V.Adressnr          # Adr.Nummer;
  Adr.V.KundenArtNr       # Auf.P.KundenArtNr;
  Adr.V.VerkaufYN         # true;
  Adr.V.EinkaufYN         # true;

  if (Wgr_data:IstMix()) or (Wgr_Data:IstArt()) then
    Adr.V.Strukturnr        # Auf.P.Artikelnr
  else
    Adr.V.Strukturnr        # Auf.P.Strukturnr;
  Adr.V.VpgText1          # Auf.P.VpgText1;
  Adr.V.VpgText2          # Auf.P.VpgText2;
  Adr.V.VpgText3          # Auf.P.VpgText3;
  Adr.V.VpgText4          # Auf.P.VpgText4;
  Adr.V.VpgText5          # Auf.P.VpgText5;
  Adr.V.VpgText6          # Auf.P.VpgText6;
  if ((Adr.V.Datum.Bis=0.0.0) or (Adr.V.Datum.Bis>=Auf.Datum)) then begin
    Adr.V.PreisW1           # Auf.P.Grundpreis;
  end;
  Adr.V.PEH               # Auf.P.PEH;
  Adr.V.MEH               # Auf.P.MEH.Preis;

  Adr.V.VorlageBAG        # Auf.P.VorlageBAG;
  Adr.V.EinsatzVPG.Adr    # Auf.P.EinsatzVPG.Adr;
  Adr.V.EinsatzVPG.Nr     # Auf.P.EinsatzVPG.Nr;

  // Material
  Adr.V.Warengruppe       # Auf.P.Warengruppe;
  "Adr.V.Güte"              # "Auf.P.Güte";
  "Adr.V.Gütenstufe"        # "Auf.P.Gütenstufe";
  Adr.V.Intrastatnr         # Auf.P.Intrastatnr;
  Adr.V.Dicke             # Auf.P.Dicke;
  Adr.V.DickenTol         # Auf.P.Dickentol;
  Adr.V.Breite            # Auf.P.Breite;
  Adr.V.BreitenTol        # Auf.P.Breitentol;
  "Adr.V.Länge"             # "Auf.P.Länge";
  "Adr.V.LängenTol"         # "Auf.P.Längentol";
  Adr.V.RID               # Auf.P.RID;
  Adr.V.RIDmax            # Auf.P.RIDMax;
  Adr.V.RAD               # Auf.P.RAD;
  Adr.V.RADmax            # Auf.P.RADMax;
  Adr.V.Zeugnisart        # Auf.P.Zeugnisart;
  Adr.V.Erzeuger          # Auf.P.Erzeuger;
  Auf.P.VorlageBAG        # Adr.V.VorlageBAG;
  Auf.P.EinsatzVPG.Adr    # Adr.V.EinsatzVPG.Adr;
  Auf.P.EinsatzVPG.Nr     # Adr.V.EinsatzVPG.Nr;

  // Verpackung
  Adr.V.AbbindungL        # Auf.P.AbbindungL;
  Adr.V.AbbindungQ        # Auf.P.AbbindungQ;
  Adr.V.Zwischenlage      # Auf.P.Zwischenlage;
  Adr.V.Unterlage         # Auf.P.Unterlage;
  Adr.V.MitLfEYN          # Auf.P.MitLfEYN;
  Adr.V.StehendYN         # Auf.P.StehendYN;
  Adr.V.LiegendYN         # Auf.P.LiegendYN;
  Adr.V.Nettoabzug        # Auf.P.Nettoabzug;
  "Adr.V.Stapelhöhe"      # "Auf.P.Stapelhöhe";
  Adr.V.StapelhAbzug      # Auf.P.StapelhAbzug;
  Adr.V.RingKgVon         # Auf.P.RingKgVon;
  Adr.V.RingKgBis         # Auf.P.RingKgBis;
  Adr.V.KgmmVon           # Auf.P.KgmmVon;
  Adr.V.KgmmBis           # Auf.P.KgmmBis;
  "Adr.V.StückProVE"        # "Auf.P.StückProVE";
  Adr.V.VEkgMax           # Auf.P.VEkgMax;
  Adr.V.RechtwinkMax      # Auf.P.RechtwinkMax;
  Adr.V.EbenheitMax       # Auf.P.EbenheitMax;
  "Adr.V.SäbeligkeitMax"  # "Auf.P.SäbeligkeitMax";
  "Adr.V.SäbelProM"       # "Auf.P.SäbelProM";
  Adr.V.Etikettentyp      # Auf.P.Etikettentyp;
  Adr.V.Verwiegungsart    # Auf.P.Verwiegungsart;
  Adr.V.Skizzennummer     # Auf.P.Skizzennummer;
  Adr.V.Umverpackung      # Auf.P.Umverpackung;
  Adr.V.Wicklung          # Auf.P.Wicklung;

  // Analyse
  Adr.V.Streckgrenze1     # Auf.P.Streckgrenze1;
  Adr.V.Streckgrenze2     # Auf.P.Streckgrenze2;
  Adr.V.Zugfestigkeit1    # Auf.P.Zugfestigkeit1;
  Adr.V.Zugfestigkeit2    # Auf.P.Zugfestigkeit2;
  Adr.V.DehnungA1         # Auf.P.DehnungA1;
  Adr.V.DehnungA2         # Auf.P.DehnungA2;
  Adr.V.DehnungB1         # Auf.P.DehnungB1;
  Adr.V.DehnungB2         # Auf.P.DehnungB2;
  Adr.V.DehngrenzeA1      # Auf.P.DehngrenzeA1;
  Adr.V.DehngrenzeA2      # Auf.P.DehngrenzeA2;
  Adr.V.DehngrenzeB1      # Auf.P.DehngrenzeB1;
  Adr.V.DehngrenzeB2      # Auf.P.DehngrenzeB2;
  "Adr.V.Körnung1"          # "Auf.P.Körnung1";
  "Adr.V.Körnung2"          # "Auf.P.Körnung2";
  Adr.V.Chemie.C1         # Auf.P.Chemie.C1;
  Adr.V.Chemie.C2         # Auf.P.Chemie.C2;
  Adr.V.Chemie.Si1        # Auf.P.Chemie.Si1;
  Adr.V.Chemie.Si2        # Auf.P.Chemie.Si2;
  Adr.V.Chemie.Mn1        # Auf.P.Chemie.Mn1;
  Adr.V.Chemie.Mn2        # Auf.P.Chemie.Mn2;
  Adr.V.Chemie.P1         # Auf.P.Chemie.P1;
  Adr.V.Chemie.P2         # Auf.P.Chemie.P2;
  Adr.V.Chemie.S1         # Auf.P.Chemie.S1;
  Adr.V.Chemie.S2         # Auf.P.Chemie.S2;
  Adr.V.Chemie.Al1        # Auf.P.Chemie.Al1;
  Adr.V.Chemie.Al2        # Auf.P.Chemie.Al2;
  Adr.V.Chemie.Cr1        # Auf.P.Chemie.Cr1;
  Adr.V.Chemie.Cr2        # Auf.P.Chemie.Cr2;
  Adr.V.Chemie.V1         # Auf.P.Chemie.V1;
  Adr.V.Chemie.V2         # Auf.P.Chemie.V2;
  Adr.V.Chemie.Nb1        # Auf.P.Chemie.Nb1;
  Adr.V.Chemie.Nb2        # Auf.P.Chemie.Nb2;
  Adr.V.Chemie.Ti1        # Auf.P.Chemie.Ti1;
  Adr.V.Chemie.Ti2        # Auf.P.Chemie.Ti2;
  Adr.V.Chemie.N1         # Auf.P.Chemie.N1;
  Adr.V.Chemie.N2         # Auf.P.Chemie.N2;
  Adr.V.Chemie.Cu1        # Auf.P.Chemie.Cu1;
  Adr.V.Chemie.Cu2        # Auf.P.Chemie.Cu2;
  Adr.V.Chemie.Ni1        # Auf.P.Chemie.Ni1;
  Adr.V.Chemie.Ni2        # Auf.P.Chemie.Ni2;
  Adr.V.Chemie.Mo1        # Auf.P.Chemie.Mo1;
  Adr.V.Chemie.Mo2        # Auf.P.Chemie.Mo2;
  Adr.V.Chemie.B1         # Auf.P.Chemie.B1;
  Adr.V.Chemie.B2         # Auf.P.Chemie.B2;
  "Adr.V.Härte1"            # "Auf.P.Härte1";
  "Adr.V.Härte2"            # "Auf.P.Härte2";
  Adr.V.Chemie.Frei1.1    # Auf.P.Chemie.Frei1.1;
  Adr.V.Chemie.Frei1.2    # Auf.P.Chemie.Frei1.2;
  Adr.V.Mech.Sonstig1     # Auf.P.Mech.Sonstig1;
  Adr.V.RauigkeitA1       # Auf.P.RauigkeitA1;
  Adr.V.RauigkeitA2       # Auf.P.RauigkeitA2;
  Adr.V.RauigkeitB1       # Auf.P.RauigkeitB1;
  Adr.V.RauigkeitB2       # Auf.P.RauigkeitB2;


  vBuf105 # RecBufCreate(105);
  // letzte Verpackung der Adresse lesen
  Erx # RecLink(vBuf105, 100, 33,_recLast);
  if(Erx > _rLocked) then
    RecBufClear(vBuf105);
  ADr.V.LfdNr # vBuf105 -> ADr.V.LfdNr + 1;
  RecBufDestroy(vBuf105);

  // Ausführung kopieren
  FOR Erx # RecLink(402, 401, 11, _recFirst);
  LOOP Erx # RecLink(402, 401, 11, _recNext);
  WHILE (Erx <= _rLocked) do begin
    Adr.V.AF.AdressNr  # Adr.V.Adressnr;
    Adr.V.AF.Verpacknr # ADr.V.LfdNr;

    Adr.V.AF.Seite        # Auf.AF.Seite;
    Adr.V.AF.ObfNr        # Auf.AF.ObfNr;
    Adr.V.AF.Bezeichnung  # Auf.AF.Bezeichnung;
    Adr.V.AF.Zusatz       # Auf.AF.Zusatz;
    Adr.V.AF.Bemerkung    # Auf.AF.Bemerkung;
    "Adr.V.AF.Kürzel"     # "Auf.AF.Kürzel";

    REPEAT
      Erx # RekInsert(106,0,'AUTO');
      if (Erx <> _rOK) then
        Adr.V.AF.lfdNr # Adr.V.AF.lfdNr + 1;
    UNTIL (Erx = _rOK);
  END;

  Adr.V.AusfOben # Obf_Data:BildeAFString(105, '1');
  Adr.V.AusfUnten # Obf_Data:BildeAFString(105, '2');

  if (Auf.P.TextNr1 = 0) then begin  // Standardtext
   Adr.V.TextNr1 # 0;
   Adr.V.TextNr2 # Auf.P.TextNr2;
  end;
  if (Auf.P.TextNr1 = 400) then begin // anderer Positionstext
    Adr.V.TextNr1 # 105;
    Adr.V.TextNr2 # 0;
  end;
  if (Auf.P.TextNr1 = 401) then begin // Idividuell
    Adr.V.TextNr1 # 105;
    Adr.V.TextNr2 # 0;
  end;

  // neuen Datensatz hinzufuegen
  Erx # RekInsert(105, 0, 'AUTO');
  if(Erx <> _rOK) then begin
    TRANSBRK;
    Msg(105000, '', 0, 0, 0);
    RETURN;
  end;

  if (Set.LyseErweitertYN) then begin
    Lib_MoreBufs:CopyNew(231, '', 401, 105);
  end;

  // RTF-Text kopieren...
  vTxtNameAuf   # '';
  vTxtNameAdrV # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.'
             + cnvAI(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4);   // 21.07.2015 Länge 7/4

  if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
    // ST 2019-09-23 Bugfix 1992/33
    //vTxtNameAuf # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    vTxtNameAuf # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3) + '.01'
  else
    vTxtNameAuf  # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'
                 + cnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
  TxtCopy(vTxtNameAuf, vTxtNameAdrV, 0);


  // Text kopieren...
  vTxtNameAdrV  # '';
  vTxtNameAuf   # '';
  vTxtNameAdrV # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.'
               + cnvAI(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4) + '.01';   // 21.07.2015 Länge 7/4
  if (Auf.P.TextNr1 = 0) then begin  // Standardtext
   //vTxtNameAuf # '~837.'+CnvAI(Adr.V.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
   //Adr.V.TextNr1 # 0;
   //Adr.V.TextNr2 # Auf.P.TextNr2;
  end;
  if (Auf.P.TextNr1 = 400) then begin // anderer Positionstext

    if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
      // ST 2019-09-23 Bugfix 1992/33
      //vTxtNameAuf # myTmpText+'.401.'+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
      vTxtNameAuf # myTmpText+'.401'+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vTxtNameAuf # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);

    //Adr.V.TextNr1 # 105;
    //Adr.V.TextNr2 # 0;
  end;
  if (Auf.P.TextNr1 = 401) then begin // Idividuell
    if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
      // ST 2019-09-23 Bugfix 1992/33
      //vTxtNameAuf # myTmpText+'.401.'+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
      vTxtNameAuf # myTmpText+'.401'+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vTxtNameAuf # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    //Adr.V.TextNr1 # 105;
    //Adr.V.TextNr2 # 0;
  end;

  if (Adr.V.TextNr1 = 105) then
    TxtCopy(vTxtNameAuf, vTxtNameAdrV, 0);

  // Aufpreise kopieren   20.01.2020 AH
  vI # 1;
  FOR Erx # RecLink(403,401,6,_recFirst)
  LOOP Erx # RecLink(403,401,6,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Strcut("Auf.Z.Schlüssel",1,1)='#') then begin
      RecBufClear(104);
      Adr.V.Z.Adressnr    # Adr.V.Adressnr;
      Adr.V.Z.VpgNr       # Adr.V.lfdNr;
      "Adr.V.Z.Schlüssel" # "Auf.Z.Schlüssel";
      Adr.V.Z.lfdNr       # vI;
      RekInsert(104);
      inc(vI);
    end;
  END;
  

  // Verpackungsnr. in Auftrag übernehmen
  RecRead(401,1,_recLock);
  Auf.P.Verpacknr       # Adr.V.lfdNr;
  Auf.P.VerpackAdrNr    # Adr.V.Adressnr;
  PosReplace(_recUnlock,'AUTO');


  TRANSOFF;

  if (!aSilent) then Msg(999998, '', 0, 0, 0);

end;


//========================================================================
// FinalAufpreise
//
//========================================================================
sub FinalAufpreise(
  aWert     : float;
  aPosMenge : float;
  aPosStk   : int;
  aPosGew   : float) : float;
local begin
  Erx     : int;
  vMenge          : float;
  vPosNetto       : float;
  vPosNettoRabBar : float;
  vWert           : float;
  vX              : float;
  v403            : int;
end;
begin
  v403 # RekSave(403);
  vPosNettoRabBar # aWert;
  vPosNetto       # aWert;

  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  FOR Erx # RecLink(403,401,6,_RecFirst)
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') then begin
      // PosMEH in AufpreisMEH umwandeln
      //vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
// 01.12.2017      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Einsatz, Auf.Z.MEH)

      vX # Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;
      vWert # vWert + vX;
    end;
  END;

  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  FOR Erx # RecLink(403,401,6,_RecFirst)
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN=n) and (Auf.Z.Rechnungsnr=0) then begin

      if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,401);
      if (Auf.Z.Menge<>0.0) then begin

        vX # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

        vPosNetto # vPosNetto + vX;
        if (Auf.Z.RabattierbarYN) then
          vPosNettoRabBar # vPosNettoRabBar + vX;
        vWert # vWert + vX;
      end;
    end;
  END;


  // Aufpreise: %
  // Aufpreise: %
  // Aufpreise: %
  FOR Erx # RecLink(403,401,6,_RecFirst)
  LOOP Erx # RecLink(403,401,6,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.Z.Schlüssel"='*RAB1') or ("Auf.Z.Schlüssel"='*RAB2') then
      CYCLE;

    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vX # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      vPosNetto # vPosNetto + vX;
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;

      vWert  # vWert + vX;
    end;
  END;

  if (gFile=400) or (gFile=401) then begin
    Auf.Z.Menge # 0.0;
    if ($edRabatt<>0) then
      Auf.Z.Menge # (-1.0) * $edRabatt1->wpcaptionfloat;
    if (Auf.Z.Menge<>0.0) then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      vWert     # vWert     + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
    end;
  end;


  // KopfAufpreise: MEH-bezogen
  // KopfAufpreise: MEH-Bezogen
  // KopfAufpreise: MEH-Bezogen
  Auf.Z.Nummer    # Auf.P.Nummer;
  Auf.Z.Position  # 0;
  Auf.Z.LfdNr     # 0;
  FOR Erx # RecRead(403,1,0)
  LOOP Erx # RecRead(403,1,_recNext)
  WHILE (Erx<=_rLastRec) and (Auf.Z.Nummer=Auf.P.Nummer) and (Auf.Z.Position=0) do begin

    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') then begin
      if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
      // PosMEH in AufpreisMEH umwandeln
// 01.12.2017      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Einsatz, Auf.Z.MEH)

      vX # Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;

      vWert # vWert + vX;
    end;
  END;


  // Kopf-Aufpreise: % seit 14.07.2016
  Auf.Z.Nummer    # Auf.P.Nummer;
  Auf.Z.Position  # 0;
  Auf.Z.LfdNr     # 0;
  FOR Erx # RecRead(403,1,0)
  LOOP Erx # RecRead(403,1,_recNext)
  WHILE (Erx<=_rLastRec) and (Auf.Z.Nummer=Auf.P.Nummer) and (Auf.Z.Position=0) do begin
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vX # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      vPosNetto # vPosNetto + vX;
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;
      vWert  # vWert + vX;
    end;
  END;

  // Stückliste EKs addieren
//  Erx # RecLink(409,401,15,_recFirst);
//  WHILE (Erx=_rOK) do begin
//  Erx # RecLink(409,401,15,_recNext);
//  END;
  RekRestore(v403);

  RETURN vWert;
end;


//========================================================================
// SumGesamtpreis
//
//========================================================================
sub SumGesamtpreis(aPosMenge : float; aPosStk : int; aPosGew : float) : float;
local begin
  vMenge          : float;
  vPosNetto       : float;
  vPosNettoRabBar : float;
  vWert           : float;
end;
begin
  vWert # 0.0;
  //vMenge # Lib_Einheiten:WandleMEH(401, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.wunsch, Auf.P.MEH.Preis);
  //vMenge # Lib_Einheiten:WandleMEH(401, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Preis, Auf.P.MEH.Preis);
  vMenge # Lib_Einheiten:WandleMEH(401, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.einsatz, Auf.P.MEH.Preis);

  if (Auf.P.PEH<>0) then
    vWert # Auf.P.Grundpreis * vMenge / Cnvfi(Auf.P.PEH);

  vWert # vWert + FinalAufpreise(vWert, aPosMenge, aPosStk, aPosGew);

  RETURN Rnd(vWert,2);
/************
  vPosNettoRabBar # vWert;
  vPosNetto       # vWert;

  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  Erx # RecLink(403,401,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') then begin
      // PosMEH in AufpreisMEH umwandeln
      //vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      vWert # vWert + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
    end;
    Erx # RecLink(403,401,6,_RecNext);
  END;

  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  Erx # RecLink(403,401,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN=n) and (Auf.Z.Menge<>0.0) and
      (Auf.Z.Rechnungsnr=0) then begin
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      vWert # vWert + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
    end;
    Erx # RecLink(403,401,6,_RecNext);
  END;


  // Aufpreise: %
  // Aufpreise: %
  // Aufpreise: %
  Erx # RecLink(403,401,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.Z.Schlüssel"='*RAB1') or ("Auf.Z.Schlüssel"='*RAB2') then begin
      Erx # RecLink(403,401,6,_RecNext);
      CYCLE;
    end;

    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

      vWert  # vWert + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
    end;
    Erx # RecLink(403,401,6,_RecNext);
  END;

  if (gFile=400) or (gFile=401) then begin
    Auf.Z.Menge # (-1.0) * $edRabatt1->wpcaptionfloat;
    if (Auf.Z.Menge<>0.0) then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      vWert  # vWert + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
    end;

  // KopfAufpreise: MEH-bezogen
  // KopfAufpreise: MEH-Bezogen
  // KopfAufpreise: MEH-Bezogen
  Erx # RecLink(403,400,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') and (Auf.Z.Position=0) then begin
      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);

        vWert # vWert + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
     end;
    Erx # RecLink(403,400,13,_RecNext);
  END;


  // Stückliste EKs addieren
//  Erx # RecLink(409,401,15,_recFirst);
//  WHILE (Erx=_rOK) do begin
//  Erx # RecLink(409,401,15,_recNext);
//  END;

  RETURN vWert;
*****/
end;


//========================================================================
// SumEKGesamtpreis
//
//========================================================================
sub SumEKGesamtpreis();
local begin
  Erx     : int;
  vX  : float;
end;
begin
/**
  Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
  if (Erx<=_rLocked) and (RecLinkInfo(409,401,15,_RecCount)=0) then begin

    if (Art.P.MEH<>Auf.P.MEH.einsatz) then begin
      Art_Data:BerechneFelder(var "Auf.P.Stückzahl", var Auf.P.Gewicht, var vX, Art.P.MEH);
    end
    else begin
      vX # Auf.P.Menge;
    end;

    "Auf.P.GesamtwertEKW1"  # 0.0;
    if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then
      if (Art_P_Data:FindePreis('L-EK', 0, 0.0, '', 1)=false) then
        Art_P_Data:FindePreis('EK', 0, 0.0, '', 1);
    if (art.P.PEH<>0) then
      "Auf.P.GesamtwertEKW1"  # Art.P.PreisW1 * vX / cnvfi(Art.P.PEH);
  end;
**/
  // STÜCKLISTE???
  if (RecLinkInfo(409,401,15,_RecCount)<>0) then begin
    "Auf.P.GesamtwertEKW1" # 0.0;
    // Summe errechnen
    Erx # RecLink(409,401,15,_Recfirst);
    WHILE (Erx<=_rLockeD) do begin
      "Auf.P.GesamtwertEKW1" # Rnd("Auf.P.GesamtwertEKW1" + Auf.SL.Gesamtwert.EK,2);
      Erx # RecLink(409,401,15,_RecNext);
    END;

    RETURN;

  end
  else begin
    // KEINE Stückliste
    if (Auf.P.MEH.Preis<>Auf.P.MEH.einsatz) then begin
//      Art_Data:BerechneFelder(var "Auf.P.Stückzahl", var Auf.P.Gewicht, var vX, Auf.P.Preis.MEH);
      if (Auf.P.MEH.Preis=Auf.P.Meh.Wunsch) then
        vX  # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis)
      else
        vX  # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.einsatz, Auf.P.MEH.Preis);
    end
    else begin
      vX # Auf.P.Menge;
    end;
//todo(anum(vX,0));
    if (Auf.P.PEH<>0) then
      "Auf.P.GesamtwertEKW1"  # Rnd(Auf.P.Kalkuliert * vX / cnvfi(Auf.P.PEH),2);
  end;

end;


//========================================================================
// SaveRabatt
//
//========================================================================
sub SaveRabatt (aName : alpha; aWert : float);
local begin
  Erx : int;
end;
begin
  RecBufClear(403);
  Auf.Z.Nummer      # Auf.P.Nummer;
  Auf.Z.Position    # Auf.P.Position;
  "Auf.Z.Schlüssel" # aName;
  Erx # RecRead(403,2,_RecTest);
  if (Erx=_rOk) or (Erx=_rMultikey) then begin
    RecRead(403,2,0);
    RekDelete(403,0,'MAN');
  end;
  if (aWert<>0.0) then begin
    Auf.Z.Menge     # (-1.0) * aWert;
    Auf.Z.MEH       # '%';
    Auf.Z.PEH       # 100;
    Auf.Z.MengenbezugYN   # y;
    Auf.Z.RabattierbarYN  # y;
    Auf.Z.Anlage.Datum  # Today;
    Auf.Z.Anlage.Zeit   # Now;
    Auf.Z.Anlage.User   # gUsername;
    Auf.Z.lfdNr     # 1;
    REPEAT
      Erx # RekInsert(403,0,'AUTO');
      if (Erx<>_rOK) then Auf.Z.lfdNr # Auf.Z.lfdNr + 1;
    UNTIL (Erx=_rOK);
  end;

end;


//========================================================================
// SumAufpreise
//
//========================================================================
sub SumAufpreise(opt aMode : alpha);
local begin
  Erx     : int;
  vAufpreis     : float;
  vAufpreisRab  : float;
  vMenge        : float;
  vRab          : float;
  vGes          : float;
  vEinzel       : float;
  vBuf401       : int;
  vBuf400       : int;
  vBuf401Ori    : int;
end
begin
  if (aMode='') then aMode # Mode;

  vAufpreis # 0.0;
  vAufpreisRab # 0.0;
  // Kalkulation der Aufpreise
  Erx # RecLink(403,401,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') and (Auf.Z.MEH=Auf.P.MEH.Preis) then begin
//      vMenge # Lib_Einheiten:WandleMEH(403, "Auf.P.Stückzahl" , Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.Z.MEH)
//        vMenge # 1.0;
//      vRab # Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      vRab # Auf.Z.Preis / CnvFI(Auf.Z.PEH) * CnvFI(Auf.P.PEH);
      vAufpreis # vAufpreis + vRab;
      if (Auf.Z.RabattierbarYN) then
        vAufpreisRab # vAufpreisRab + vRab;
    end;
    Erx # RecLink(403,401,6,_RecNext);
  END;
//debug('1:'+cnvaf(vAufpreis)+'    stk:'+cnvai("auf.p.Stückzahl"));
  Erx # RecLink(403,401,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      vRab # Rnd((Auf.Z.Menge/100.0) * (Auf.P.Grundpreis+vAufpreisRab),2);
      vAufpreis # vAufpreis + vRab;
      if (Auf.Z.RabattierbarYN=n) then begin
        vAufpreisRab # vAufpreisRab + vRab;
        end;
    end;
    Erx # RecLink(403,401,6,_RecNext);
  END;


  // Kopf-Aufpreise: % seit 14.07.2016
  Auf.Z.Nummer    # Auf.P.Nummer;
  Auf.Z.Position  # 0;
  Auf.Z.LfdNr     # 0;
  FOR Erx # RecRead(403,1,0)
  LOOP Erx # RecRead(403,1,_recNext)
  WHILE (Erx<=_rLastRec) and (Auf.Z.Nummer=Auf.P.Nummer) and (Auf.Z.Position=0) do begin
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      vRab # Rnd((Auf.Z.Menge/100.0) * (Auf.P.Grundpreis+vAufpreisRab),2);
      vAufpreis # vAufpreis + vRab;
      if (Auf.Z.RabattierbarYN=n) then begin
        vAufpreisRab # vAufpreisRab + vRab;
        end;
    end;
  END;


//  if (vAufpreis=Auf.P.Aufpreis) then RETURN;

  vBuf401 # RekSave(401);
  vBuf400 # RekSave(400);

  if (aMode = c_ModeEdit) then begin
    Erx # RecRead(401,1,_RecLock);  // Satz sperren
    
    SpeziAFX('VBS','VBS.SumAufpreiseAuf','1');
    
    Auf.P.Aufpreis    # vAufpreis;     // Aufpreise aktualisieren
    // 17.07.2020 AH: Preis NICHT aus Buffer!
//    Auf.P.Grundpreis  # vBuf401->Auf.P.Grundpreis;
    Auf.P.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
    if (Auf.P.Menge != 0.0) then
      Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht)
    else
      Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Gewicht, "Auf.P.Stückzahl" , Auf.P.Gewicht);
    vGes # Auf.P.Gesamtpreis;
    vEinzel # Auf.P.Einzelpreis;
    PosReplace(_recUnlock,'MAN');
//debugx('ALT:'+anum(vBuf401->Auf.P.Gesamtpreis,2)+' NEU:'+anum(Auf.P.Gesamtpreis,2));

    SpeziAFX('VBS','VBS.SumAufpreiseAuf','2');
    SperrPruefung(ProtokollBuffer[401]);
    Erx # RecRead(401,1,_RecLock);  // Satz sperren
    RecBufCopy(vBuf401,401,n);
    Erx # RecRead(400,1,_RecLock);  // Satz sperren
    RecBufCopy(vBuf400,400,n);
    Auf.P.Aufpreis # vAufpreis;
    Auf.P.Gesamtpreis # vGes;
    Auf.P.Einzelpreis # vEinzel;

    SpeziAFX('VBS','VBS.SumAufpreiseAuf','3');
  end
  else if (aMode = c_ModeNew2) or (aMode = c_ModeSave) then begin
    Auf.P.Aufpreis # vAufpreis;     // Aufpreise aktualisieren
    Auf.p.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
  end
    // Falls Benutzer NICHT im NEW-Modus, speichern (für EDIT gesperrt)
  else if (aMode = c_ModeView) then begin

    Erx # RecRead(401,1,_RecLock);  // Satz sperren
    if (Erx <= _rLocked) then begin
      vBuf401Ori # RekSave(401);
      Auf.P.Aufpreis # vAufpreis;     // Aufpreise aktualisieren
      Auf.p.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
      vGes # Auf.P.Gesamtpreis;
      if (Auf.P.Menge != 0.0) then
        Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht)
      else
        Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Gewicht, "Auf.P.Stückzahl" , Auf.P.Gewicht);
      Erx # PosReplace(_recUnlock,'MAN');
      SperrPruefung(vBuf401Ori);
      RecBufDestroy(vBuf401Ori);
    end;

  end
  else if (aMode = c_ModeList) then begin

    Erx # RecRead(401,0,_RecID | _RecLock,$ZL.AufPositionen->wpDbRecID);
    if (Erx <= _rLocked) then begin
      vBuf401Ori # RekSave(401);
      Auf.P.Aufpreis # vAufpreis;
      Auf.p.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
      vGes # Auf.P.Gesamtpreis;
      if (Auf.P.Menge != 0.0) then
        Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht)
      else
        Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Gewicht, "Auf.P.Stückzahl" , Auf.P.Gewicht);
      Erx # PosReplace(_recUnlock,'MAN');
      SperrPruefung(vBuf401Ori);
      RecBufDestroy(vBuf401Ori);
    end;
  end;

  RecBufDestroy(vBuf400);
  RecBufDestroy(vBuf401);

end;


//========================================================================
// TerminCopy
//
//========================================================================
sub TerminCopy();
local begin
  Erx     : int;
  vArt : alpha;
  vT1,vT2,vT3 : date;
  vZ1,vZ2,vZ3 : int;
  vJ1,vJ2,vJ3 : int;
  vZusatz : alpha;
end;
begin
  if (Msg(401004,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;

  vArt # Auf.P.Termin1W.Art;
  vT1 # Auf.P.Termin1Wunsch;
  vZ1 # Auf.P.Termin1W.Zahl;
  vJ1 # Auf.P.Termin1W.Jahr;
  vT2 # Auf.P.Termin2Wunsch;
  vZ2 # Auf.P.Termin2W.Zahl;
  vJ2 # Auf.P.Termin2W.Jahr;
  vT3 # Auf.P.TerminZusage;
  vZ3 # Auf.P.TerminZ.Zahl;
  vJ3 # Auf.P.TerminZ.Jahr;
  vZusatz # Auf.P.Termin.Zusatz;

  Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.P.Termin1Wunsch=0.0.0) then begin
      RecRead(401,1,_recLock);
      Auf.P.Termin1W.Art # vArt;
      Auf.P.Termin1Wunsch # vT1;
      Auf.P.Termin1W.Zahl # vZ1;
      Auf.P.Termin1W.Jahr # vJ1;
      Auf.P.Termin2Wunsch # vT2;
      Auf.P.Termin2W.Zahl # vZ2;
      Auf.P.Termin2W.Jahr # vJ2;
      Auf.P.TerminZusage # vT3;
      Auf.P.TerminZ.Zahl # vZ3;
      Auf.P.TerminZ.Jahr # vJ3;
      Auf.P.Termin.Zusatz # vZusatz;
      PosReplace(_recUnlock,'MAN');
    end;
    Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recNext);
  END;

end;


//========================================================================
// BildeAFString
//              generiert den Kürzelstring für eine Seite
//========================================================================
sub BildeAFString(
  aSeite : alpha;
) : alpha;
local begin
  vAf   : alpha;
  vStr  : alpha(200);
  Erx   : int;
end;
begin
  vAf # '';
  FOR  Erx # RecLink( 402, 401, 11, _recFirst );
  LOOP Erx # RecLink( 402, 401, 11, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( Auf.AF.Seite != aSeite ) then
      CYCLE;

    // Einzelwert
    if ( vAf = '' ) then
      vAf # Auf.AF.Bezeichnung + Auf.AF.Zusatz;
    else
      vAf # '#';

    // Kürzelstring
    if ( "Auf.AF.Kürzel" != '' ) then begin
      if ( vStr != '' ) then
        vStr # vStr + ',';
      vStr # vStr + "Auf.AF.Kürzel" + "Auf.AF.Zusatz";
    end;
  END;

  if ( vAf != '#' ) then
    RETURN StrCut( vAf, 1, 32 );
  else
    RETURN StrCut( vStr, 1, 32 );
end;


//========================================================================
// Pos_BerechneMarker
//          setzt Positionsmarker anhand der Aktionsmarker
//========================================================================
sub Pos_BerechneMarker();
local begin
  Erx     : int;
  vBuf  : int;
  vProz : float;
  vM    : float;
end
begin
  if (RunAfx('Auf.P.Pos.BerechneMarker','')<>0) then RETURN;

// debugx(anum(Auf.P.Prd.VSB,0)+'/'+anum(Auf.P.Prd.VSAuf,0)+anum(Auf.P.Prd.Plan,0));
  
  if (RecLinkInfo(203,401,18,_recCount)<>0) or
    (Auf.P.Prd.VSB>0.0) or (Auf.P.Prd.VSAuf>0.0) or
    (Auf.P.Prd.Plan>0.0) then RETURN;;

  // Save
  vBuf # RekSave(404);
  Auf.P.Aktionsmarker # '';

  Erx # RecLink(835,401,5,_RecFirst);   // Auftragsart holen
  if (Erx>=_rLocked) then RecBufClear(835);

  Erx # RecLink(404,401,12,_RecFirst);
  WHILE (Erx<=_rLocked) and (Auf.P.Aktionsmarker='') do begin
    if ("Auf.A.Löschmarker"='') and (Auf.A.RechnungsMark='$') then
      Auf.P.Aktionsmarker # '$';
    Erx # RecLink(404,401,12,_RecNext);
  END;

  if (Auf.P.Aktionsmarker<>'') then begin
    RekRestore(vBuf);
    RETURN;
  end;

  // Verkäufe?
  if (AAr.Berechnungsart>=700) or (AAr.Berechnungsart=200) or (AAr.Berechnungsart=250) then begin
    if (Auf.LiefervertragYN=false) then begin
      if (Auf.P.MEH.Preis=Auf.P.MEH.Wunsch) then vM # Auf.P.Prd.Rech
      else if (Auf.P.MEH.Wunsch='Stk') then vM # cnvfi(Auf.P.Prd.Rech.Stk)
      else if (Auf.P.MEH.Wunsch='kg') then vM # Auf.P.Prd.Rech.Gew
      else if (Auf.P.MEH.Wunsch='t') then vM # Auf.P.Prd.Rech.Gew / 1000.0
      else vM # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.Rech.Stk, Auf.P.Prd.Rech.Gew, Auf.P.Prd.Rech, Auf.P.MEH.Preis, Auf.P.MEH.Wunsch)
    end
    else begin
      vM # Auf.P.Prd.LFS;
    end;
  end;

//debug(Auf.P.MEH.Preis+' '+Auf.P.MEH.Wunsch);
//  if ((Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF)) then begin

  // interne Verrechnung?
  if (AAr.Berechnungsart=100) then begin
    vM # Auf.P.Prd.LFS;
  end;

  // 2023-04-20 AH Proj. 2333/89/1
  if ((Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF)) then begin
    if (vM=0.0) then vM # abs(Auf.A.Menge);
    vM # abs(vM);
    vProz # Lib_Berechnungen:Prozent(vM, abs(Auf.P.Menge.Wunsch));
  end
  else begin
    vProz # Lib_Berechnungen:Prozent(vM, Auf.P.Menge.Wunsch);
  end;

//debugx(anum(vM,2)+' '+anum(vProz,2)+'%');

  // Löschen:
  // Mat-Reservierungen dürfen NICHT vorhanden sein,
  // kein weiteres Material kommissioniert oder in Auslieferung
  // und Sollmengentoleranz erreicht sein !
//debugx("Auf.P.Löschmarker"+', '+Auf.P.Aktionsmarker+',' +anum(Auf.P.Prd.VSB,0)+', '+anum(Auf.P.Prd.VSAuf,0)+', '+anum(Auf.P.Prd.Plan,0)+', '+aint(RecLinkInfo(203,401,18,_recCount)));
//debugx(anum(vProz,2));

  if ("Auf.P.Löschmarker"='') and
    (vProz>="Set.Wie.RechDelAuf%") then begin
//    (Auf.P.Prd.Rech>=Auf.P.Menge.Wunsch) then
    //(Auf.P.Prd.Rest<=0.0) then
    Auf_P_Subs:ToggleLoeschmarker(n);
    RecRead(401,1,_recLock);
    Auf.P.Aktionsmarker # '';
  end
  // Rahemmn ggf. wieder AKTIVIEREN
  else if ("Auf.P.Löschmarker"='*') and
    (vProz<"Set.Wie.RechDelAuf%") and (Auf.LiefervertragYN) then begin
    Auf_P_Subs:ToggleLoeschmarker(n);
    RecRead(401,1,_recLock);
    Auf.P.Aktionsmarker # '';
  end;

  // Restore
  RekRestore(vBuf);
end;


//========================================================================
// BerechneMarker
//          setzt Kopfmarker anhand der Positionsmarker
//========================================================================
sub BerechneMarker();
local begin
  Erx     : int;
  vBuf : int
end
begin
  // Save
  vBuf # RecBufCreate(401);
  RecBufCopy(401,vBuf);

  Auf.Aktionsmarker # '';
  "Auf.Löschmarker" # '*';
  Erx # RecLink(401,400,9,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.P.Aktionsmarker='$') then Auf.Aktionsmarker # '$';
    if ("Auf.P.Löschmarker"='') then "Auf.Löschmarker" # '';
    Erx # RecLink(401,400,9,_RecNext);
  END;

  // Restore
  RecBufCopy(vBuf,401);
  RecBufDestroy(vBuf);
end;


//========================================================================
// VerbucheArt
//
//========================================================================
sub VerbucheArt(
  aAltArt   : alpha;
  aAltOffen : float;
  aAltMarke : alpha;
  opt aMDelta : float); // 22.11.2021
local begin
  Erx     : int;
  vM        : float;
end;
begin

  if (Auf.Vorgangstyp<>c_AUF) then RETURN;


  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);

  Erx # RecLink(819,401,1,_RecFirst);   // Warengruppe holen

  // alten Artikel freimachen...
  if (aAltArt<>'') and (aAltMarke='') then begin

    if (AAr.ReservierePosYN) then begin
      Art.Nummer # aAltArt;
      Erx # RecRead(250,1,0);   // Artikel holen
      if (Erx<=_rLocked) then begin
        RecBufClear(252);
        Art.C.ArtikelNr     # Auf.P.ArtikelNr;
        Art.C.Dicke         # Auf.P.Dicke;
        Art.C.Breite        # Auf.P.Breite;
        "Art.C.Länge"       # "Auf.P.Länge";
        Art.C.RID           # Auf.P.RID;
        Art.C.RAD           # Auf.P.RAD;
//        if (aAltMenge>Auf.P.Prd.LFS) then
        if (aAltOffen>0.0) then begin   // 01.06.2022 AH
//debugx('KEY401 altraus '+anum(aAltOffen,0));
          Art_Data:Auftrag(-1.0*aAltOffen);
        end;
      end;
    end;

    if (AAr.ReserviereSLYN) then begin

      Erx # RecLink(409,401,15,_recFirst);
      WHILE (Erx<=_rLocked) do begin

        // Stückliste entreservieren
        Auf_SL_Data:Reservieren(y);

        Erx # RecLink(409,401,15,_recNext);
      END;
    end;

  end;

  // neuen Artikel bebuchen...
  if (Auf.P.Artikelnr='') or ("Auf.P.Löschmarker"='*') then RETURN;

  if (AAr.ReservierePosYN) then begin
    Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
    if (Erx<=_rLocked) then begin
      RecBufClear(252);
      Art.C.ArtikelNr     # Auf.P.ArtikelNr;
      Art.C.Dicke         # Auf.P.Dicke;
      Art.C.Breite        # Auf.P.Breite;
      "Art.C.Länge"       # "Auf.P.Länge";
      Art.C.RID           # Auf.P.RID;
      Art.C.RAD           # Auf.P.RAD;

      vM # Auf.P.Menge - Auf.P.Prd.Plan - Auf.P.Prd.VSB - Auf.P.Prd.LFS; // 01.02.2018 AH Dipotest
      if (aMDelta<>0.0) then vM # aMDelta;
      if (vM>0.0) then begin
//debugx('KEY401 neuRein '+anum(vM,0));
        Art_Data:Auftrag(vM); // 01.02.2018 AH Dipotest
//      if (Auf.P.Menge>Auf.P.Prd.LFS) then begin
//        Art_Data:Auftrag(Auf.P.Menge - Auf.P.Prd.VSB - Auf.P.Prd.LFS);
      end;
/** DIREKTE MATZ ; WEG!
      if (aAltMenge=0.0) then begin
      // sofort MATZ/Reservierungen anlegen
      //if (Auf.P.Wgr.DateiNr=c_Wgr_Artikel) then begin
        if (RecLinkInfo(252,250,4,_recCount)>1) then begin
          Auf_Data:MatzArt(0,0,'',n,n,Auf.P.Menge - Auf.P.Prd.VSB - Auf.P.Prd.VSAuf - Auf.P.Prd.LFS);
      //end;
      end;
**/
    end;
  end;

  if (AAr.ReserviereSLYN) and (aAltArt='') then begin
    Erx # RecLink(409,401,15,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      // Stückliste reservieren
      Auf_SL_Data:Reservieren(n);

      Erx # RecLink(409,401,15,_recNext);
    END;
  end;

end;


//========================================================================
// DeletePos
//        löscht eine Position samt Anhang + Texte
//========================================================================
sub DeletePos();
begin

  TRANSON;
                                    // Texte ggf. löschen
  if (Auf.P.Nummer<1000000000) then begin
//    TxtDelete('~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNogroup,0,3),0);
    // Internen Text löschen
//    TxtDelete('~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3)+'.01',0);
    // 2022-06-27 AH : besser so
    Lib_Texte:DelAllAehnlich('~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3));
  end;

                                  // Ausführung ggf. löschen
  WHILE (RecLink(402,401,11,_recFirst)=_rOk) do begin
    RekDelete(402,0,'AUTO');
  END;
                                  // Aufpreise ggf. löschen
  WHILE (RecLink(403,401,6,_recFirst)=_rOk) do begin
    RekDelete(403,0,'AUTO');
  END;
                                  // Aktionen ggf. löschen
  WHILE (RecLink(404,401,12,_recFirst)=_rOk) do begin
    if (Auf.A.Rechnungsnr<>0) then begin
      TRANSBRK;
      RETURN;
    end;
    RekDelete(404,0,'AUTO');
  END;
                                  // Kalkulation ggf. löschen
  WHILE (RecLink(405,401,7,_recFirst)=_rOk) do begin
    RekDelete(405,0,'AUTO');
  END;
                                  // Feinabrufe ggf. löschen
  WHILE (RecLink(408,401,13,_recFirst)=_rOk) do begin
    RekDelete(408,0,'AUTO');
  END;
                                  // Stückliste ggf. löschen
  WHILE (RecLink(409,401,15,_recFirst)=_rOk) do begin
    RekDelete(409,0,'AUTO');
  END;

  RekDelete(401,0,'AUTO');

  TRANSOFF;

end;


//========================================================================
// DeleteKopf
//
//========================================================================
sub DeleteKopf();
begin

  // Kopftexte löschen
  if (Auf.Nummer<99999999) then begin
    Lib_Texte:DelAllAehnlich('~401.'+CnvAI(Auf.nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.K');
    Lib_Texte:DelAllAehnlich('~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.F');
  end;

  // Kopfaufpreise löschen
  WHILE (RecLink(403,400,13,_RecFirst)<=_rLocked) do begin
    RekDelete(403,0,'AUTO');
  END;

  // Position löschen
  WHILE (RecLink(401,400,9,_RecFirst)<=_rLocked) do begin
    DeletePos();
  END;

  RekDelete(400,0,'AUTO');

end;

/****
//========================================================================
// DFaktBel
//        Belastung direkt fakturieren
//========================================================================
sub DFaktBel();
local begin
  vMenge  : float;
end;
begin

  // gibts schon eine Aktion??
  Erx # RecLink(404,401,12,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLockeD) do begin
    if (Auf.A.Aktionstyp=c_Akt_DFaktBel) and (Auf.A.Rechnungsnr=0)  then RETURN;
    Erx # RecLink(404,401,12,_recNext);
  END;

  vMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, cnvfi("Auf.P.Stückzahl"), 'Stk', Auf.P.MEH.Preis);
  if (Msg(401011,ANum(vMenge,-1)+' '+Auf.P.MEH.Preis,_WinIcoQuestion,_WinDialogyesno,1)=_WinIdNo) then RETURN;


  RecBufclear(404);
  Auf.A.Aktionsnr       # 0;
  Auf.A.AktionsPos      # 0;
  Auf.A.Materialnr      # 0;
  Auf.A.Aktionstyp      # c_Akt_DFaktBel;
  Auf.A.Bemerkung       # c_AktBem_DFakt;
  Auf.A.TerminStart     # Today;
  Auf.A.TerminEnde      # Today;
  Auf.A.AktionsDatum    # Today;
  Auf.A.EKPreisSummeW1  # 0.0;
  Auf.A.InterneKostW1   # 0.0;
  Auf.A.Menge           # vMenge;
  Auf.A.MEH             # Auf.P.MEH.Preis;
  Auf.A.Menge.Preis     # vMenge;
  Auf.A.MEH.Preis       # Auf.P.MEH.Preis;
  //RecLink(100,401,4,_recFirst);   // Kunde holen
  //Aufx.A.Adressnummer    # Adr.Nummer;
  "Auf.A.Stückzahl"     # "Auf.P.Stückzahl";
  //if (VWA.NettoYN) then
  //  Auf.A.Gewicht       # Auf.P.Gewicht;
  //Auf.A.Nettogewicht    # Auf.P.Gewicht;
  if (Auf_A_Data:NeuAnlegen(n)=false) then begin
    Error(401404,'');
    ERROROUTPUT;
    RETURN;
  end;

  // ERFOLG !!!
  Msg(999998,'',0,0,0);
end;
****/


//========================================================================
// DFaktMat_DoIt
//
//========================================================================
sub DFaktMat_DoIT(
  aUmbuchen   : logic;
  aStk        : int;
  aGewNetto   : float;
  aGewBrutto  : float;
  aMenge      : float;
  aDatum      : date;
  aZeit       : time;
) : logic;
local begin
  Erx     : int;
  vA          : alpha(200);
  vAlteNr     : int;
  vNeueNr     : int;
  vStk,vStk2  : int;
  vGew ,vGew2 : float;
end;
begin

  // AFX
  if (aUmbuchen) then vA # 'Y|'
  else vA # 'N|';
  vA # vA + aint(aStk) + '|' + anum(aGewNetto,3)+'|'+anum(aGewBrutto,3)+'|'+anum(aMenge,3)+'|'+cnvad(aDatum)+'|'+cnvat(aZeit);
  if (RunAFX('Auf.P.Mat.DFakt.DoIt',vA)<0) then begin
    RETURN (AfxRes=_rOK);
  end;

  TRANSON;

  // SPLITTEN???
  vNeueNr # Mat.Nummer;
  vAlteNr # Mat.Nummer;
  if (aStk<>Mat.Bestand.Stk) then begin
    // Splitten schiebt Reservierungen weiter und setzt VLDAWs um
    if (Mat_Data:Splitten(aStk, aGewNetto, aGewBrutto, 0.0, aDatum, aZeit, var vNeueNr, '')=false) then begin
      TRANSBRK;
      Error(401203,'1');
      RETURN false;
    end;

    // Material ausbuchen
    Mat.Nummer # vNeueNr;
    RecRead(200,1,0);

    // Reservierungen ggf. übernehmen....
    vStk # Mat.Bestand.Stk;
    vGew # Mat.Bestand.Gew;
    Mat.Nummer # vAlteNr;
    Erx # RecLink(203,200,13,_RecFirst);
    WHILE (Erx<=_rLocked) and ((vStk>0) or (vGew>0.0)) do begin
      if ("Mat.R.Trägernummer1"=0) then begin
        if ((Mat.R.Auftragsnr=Auf.P.Nummer) and (Mat.R.Auftragspos=Auf.P.Position)) or
          ((Mat.R.Auftragsnr=0) and (Mat.R.Kundennummer=Auf.P.Kundennr)) then begin
          if (vStk>"Mat.Verfügbar.Stk") then vStk2 # "Mat.Verfügbar.Stk"
          else vStk2 # vStk;
          if (vGew>"Mat.Verfügbar.Gew") then vGew2 # "Mat.Verfügbar.Gew"
          else vGew2 # vGew;
          Mat_Rsv_Data:Takeover(Mat.R.Reservierungnr, vNeueNr, vStk2, vGew2, 0.0);
          vStk # vStk - "Mat.R.Stückzahl";
          vGew # vGew - Mat.R.Gewicht;
          Erx # RecLink(203,200,13,_RecFirst);
          CYCLE;
        end;
      end;

      Erx # RecLink(203,200,13,_RecNext);
    END;
  end;



  // Material ausbuchen
  Mat.Nummer # vNeueNr;
  RecRead(200,1,0);

  // alle Reservierungen löschen...
  Erx # RecLink(203,200,13,_recFirst);
  WHILE (Erx=_rOK) do begin
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      Erx # _rLocked;
      BREAK;
    end;
    //RekDelete(203,0,aGrund);
    Erx # RecLink(203,200,13,_recFirst);
  END;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    Error(401203,'2');
    RETURN false;
  end;


  // Material ausbuchen
  Mat.Nummer # vNeueNr;
  RecRead(200,1,_recLock);
  Mat_Data:SetStatus(c_Status_Verkauft);

  // "Mat.Löschmarker"   # '*';
  Mat_Data:SetLoeschmarker('*');

  Mat.Ausgangsdatum   # aDatum;
  Mat.VK.Kundennr     # Auf.P.Kundennr;
  Mat.Auftragsnr      # Auf.P.Nummer;
  Mat.Auftragspos     # Auf.P.Position;
  Mat.KommKundennr    # Auf.P.Kundennr;
  Mat.KommKundenSWort # Auf.P.KundenSW;
  Mat.Kommission      # '';
  if (vAlteNr=vNeueNr) then begin   // MENGENDIFFERENZ??
    vGew # Mat.Bestand.Gew;
    Mat.Bestand.Gew     # 0.0;
    Mat.Gewicht.Netto   # aGewNetto;
    Mat.Gewicht.Brutto  # aGewBrutto;
  end;
  Erx # Mat_data:Replace(_RecUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Error(401203,'10');
    RETURN false;
  end;
  if (vAlteNr=vNeueNr) then begin   // MENGENDIFFERENZ??
    vGew # Mat.Bestand.Gew - vGew;
    Mat_Data:Bestandsbuch(0, vGew, 0.0, 0.0, 0.0, c_Akt_DFakt+' '+cnvai(Auf.P.Nummer)+'/'+cnvai(Auf.P.Position), aDatum, aZeit, c_Akt_DFakt, Auf.P.Nummer, Auf.P.Position);
    // eigene Schrottumlage...
    if ("Set.Mat.!InternUmlag"=false) then begin
      RecBufClear(204);
      Mat.A.Aktionsmat    # vNeueNr;
      Mat.A.Aktionstyp    # c_Akt_Mat_Umlage;
      Mat.A.Bemerkung     # c_AktBem_Mat_Umlage;
      Mat.A.Aktionsdatum  # aDatum;
      Mat.A.Terminstart   # Mat.A.Aktionsdatum;
      Mat.A.Terminende    # Mat.A.Aktionsdatum;
      Mat.A.Adressnr      # 0;
      if (Mat.Bestand.Gew<>0.0) then
        Mat.A.KostenW1      # Rnd(- (vGew * Mat.EK.Effektiv / Mat.Bestand.Gew),2);
      if (Mat.A.KostenW1<>0.0) then begin   // 18.09.2018 AH: nur wenn Betrag da ist
        Mat_A_Data:Insert(0,'AUTO')
        if (Mat_A_Data:Vererben()=false) then begin
          TRANSBRK;
          ErrorOutput;
          RETURN false;
        end;
      end;
    end;
  end;

  // Aktion anlegen
  RecBufClear(404);
  Auf.A.Aktionsnr       # vNeueNr;
  Auf.A.AktionsPos      # 0;
  Auf.A.Materialnr      # vNeueNr;
  Auf.A.Aktionstyp      # c_Akt_DFakt;

  // 20.03.2013
  if (Wgr_data:IstMix(Auf.P.Wgr.Dateinr)) then  // ggf. Artikelnummer für 209er übernehmen
    Auf.A.ArtikelNr # Mat.Strukturnr;

  Auf.A.Bemerkung       # c_AktBem_DFakt;
  Auf.A.TerminStart     # aDatum;
  Auf.A.TerminEnde      # aDatum;
  
  // ST 2019-12-17 Projekt 2036/35 Brockhaus Std Bug
  //Auf.A.AktionsDatum    # Today;
  Auf.A.AktionsDatum    # aDatum;

  
  
  //Auf.A.EKPreisSummeW1  # Rnd(Mat.EK.effektiv * Mat.Bestand.Gew / 1000.0,2);
  Auf.A.EKPreisSummeW1  # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
  Auf.A.InterneKostW1   # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);

  Auf.A.MEH.Preis       # Auf.P.MEH.Preis;

  // 15.05.2014
  //Auf.A.MEH             # 'kg';
  Auf.A.MEH             # Auf.P.MEH.Einsatz;

  Auf.A.Menge           # Mat.Bestand.Gew;
  if (Auf.P.MEH.Preis='kg') then
    Auf.A.Menge         # aMenge;
  if (Auf.P.MEH.PReis='t') then
    Auf.A.Menge         # Rnd(aMenge / 1000.0, Set.Stellen.Menge);
  Auf.A.Menge.Preis     # aMenge;
//  RecLink(100,401,4,_recFirst);   // Kunde holen
  "Auf.A.Stückzahl"     # aStk;
  Auf.A.Gewicht         # aGewBrutto;
  Auf.A.Nettogewicht    # aGewNetto;
  if ( Lib_Einheiten:TransferMengen('200>404,DFAKT')=false) then begin
    TRANSBRK;
    Error(401203,'11');
    RETURN false;
  end;


  if (Auf_A_Data:NeuAnlegen(n)<>_rOK) then begin
    TRANSBRK;
    Error(401203,'11');
    RETURN false;
  end;


  // Materialkopie anlegen bei "BEHALTEN"
  if (aUmbuchen) then begin
    Mat.Nummer # 0;
    Mat.Nummer # Lib_Nummern:ReadNummer('Material');
    if (Mat.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      Error(401203,'20');
      RETURN false;
    end;
    Mat.Ursprung    # Mat.Nummer;
    "Mat.Vorgänger" # 0;

    Mat_Data:SetStatus(c_Status_Frei);

    // "Mat.Löschmarker"   # '';
    Mat_Data:SetLoeschmarker('');

    Mat.EigenmaterialYN   # n;
    "Mat.Übernahmedatum"  # 0.0.0;
    Mat.Eingangsdatum     # aDatum;
    Mat.Ausgangsdatum     # 0.0.0;
    Mat.Lieferant         # Adr.Lieferantennr;
    Mat.VK.Kundennr       # 0;
    Mat.Auftragsnr        # 0;
    Mat.Auftragspos       # 0;
    Mat.Kommission        # '';
    Mat.KommKundennr      # 0;

    Erx # Mat_Data:Insert(0,'AUTO', aDatum);
    if (erx<>_rOK) then begin
      TRANSBRK;
      Error(401203,'21');
      RETURN false;
    end;

    TRANSOFF;
  end
  else begin
    TRANSOFF;
  end;

  RETURN true;  // alles OK
end;


//========================================================================
// DFaktMat
//        Material(200) direkt MANUELL verkaufen
//========================================================================
sub DFaktMat(
  aMatNr      : int;
  aMan        : logic;
  aDat    : date;
  aTim    : time) : logic;
local begin
  Erx     : int;
  vUrStk      : int;
  vStk        : int;
  vMenge      : float;
  vDatum      : date;
  vZeit       : time;
  vGewNetto   : float;
  vGewBrutto  : float;
  vAlteNr     : int;
  vNeueNr     : int;
  vRestNr     : int;
  vVSP        : logic;
  vDat1,vDat2 : date;
  vZusatz     : alpha;
  vOK         : logic;
  vBehalten   : logic;
  v401        : int;
end;
begin

  Mat.Nummer # aMatNr;
  Erx # RecRead(200,1,0);         // Material holen
  if (Erx>=_rLocked) then begin
    Msg(401203,'1',0,0,0);
    RETURN false;
  end;

  // 2023-03-06 AH , Proj. 2470/5 : auch für andere AufPos gängig gemacht
  if (Mat.Auftragsnr<>0) and (Mat.Auftragsnr<>Auf.P.Nummer) then begin
    v401 # Reksave(401);
    Erx # RecLink(401,200,16,_RecFirst);  // AufPos holen
    if (erx>_rLocked) then begin
      RekRestore(v401);
      Msg(99,'Auftragspos ncich gefunden!',0,0,0);
      RETURN false;
    end;
  end;


  RecLink(100,401,4,_recFirst);   // Kunde holen

  // PLAUSI --------------------------------
//  // ST 2018-12-06: Plausi aufgrund neuer Konsistatus umgestellt
/*
  if (Mat.Status>c_Status_bisfrei) and (Mat.Status<>c_Status_VSB) and (Mat.Status<>c_Status_VSBKonsi) then begin
*/
  
  // 2023-08-01 TM: Plausibilitätskontrolle: Fehlschlagsmeldung um MatNr. erweitert
  if (Mat.Status>c_Status_VSBKonsiRahmen) then begin
    if (v401<>0) then RekRestore(v401);
    Msg(401200,Translate('dem Status'),0,0,0);
    RETURN false;
  end;
  if ("Mat.EigenmaterialYN"=n) then begin
    if (v401<>0) then RekRestore(v401);
    Msg(401200,Translate('dem Besitzer, Materialnr. '+cnvai(mat.nummer)),0,0,0);
    RETURN false;
  end;
  if ("Mat.Löschmarker"<>'') then begin
    if (v401<>0) then RekRestore(v401);
    Msg(401200,Translate('dem Löschmarker, Materialnr. '+cnvai(mat.nummer)),0,0,0);
    RETURN false;
  end;
  if ("Mat.Bestand.Gew"=0.0) then begin
    if (v401<>0) then RekRestore(v401);
    Msg(401200,Translate('dem Gewicht, Materialnr. '+cnvai(mat.nummer)),0,0,0);
    RETURN false;
  end;

  vOK # y;
  if (Mat.Auftragsnr<>0) then begin
    vOK # n;
    if (Auf.P.AbrufAufNr = 0) and     // normaler Auftrag...
      (Mat.AuftragsNr=Auf.P.Nummer) and
      (Mat.Auftragspos=Auf.P.Position) then vOK # y;
    else begin                        // Abruf...
      if ((Mat.AuftragsNr=Auf.P.AbrufAufNR) and (Mat.Auftragspos=Auf.P.AbrufAufPos)) or
        ((Mat.AuftragsNr=Auf.P.Nummer) and (Mat.Auftragspos=Auf.P.Position)) then vOK # y;
    end;
  end
  if (vOK=n) then begin
    if (v401<>0) then RekRestore(v401);
    Msg(401200,Translate('der Kommission'),0,0,0);
    RETURN false;
  end;
  Erx # PasstAuf2Mat(0,false,aMan);
  if (erx<0) then RETURN false;
  if (erx=0) then begin
    if (Rechte[Rgt_Auf_MATZ_Konf_Abm]) then begin
      if (aMan) then
        if (Msg(401015,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;
    end
    else begin
      if (v401<>0) then RekRestore(v401);
      Msg(401016,'',_WinIcoError,_WinDialogOk,1);
      RETURN false;
    end;
  end;

  // Ankerfunktion
  if (RunAFX('Auf.P.Mat.DFakt.Plausi','')<>0) then begin
    if (AfxRes<>_rOK) then begin
      if (v401<>0) then RekRestore(v401);
      RETURN false;
    end;
  end;


  vBehalten # (Mat.Lageradresse=Set.EigeneAdressnr)

  vStk        # Mat.Bestand.Stk;
  vUrStk      # vStk;
  vGewNetto   # Mat.Gewicht.Netto;
  vGewBrutto  # Mat.Gewicht.Brutto;
//  vMenge      # 0.0;
  if (aDat=0.0.0) then begin
    aDat  # today;
    aTim  # now;
  end;
  vDatum      # aDat;
  vZeit       # aTim;

  // Verwiegungsart holen
  Erx # RecLink(818,401,9,_recFirst);
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;
  if (VWa.NettoYN) then
    vMenge # Lib_Einheiten:WandleMEH(200, vStk, vGewNetto, 0.0, '', Auf.P.MEH.Preis)
  else
    vMenge # Lib_Einheiten:WandleMEH(200, vStk, vGewBrutto, 0.0, '', Auf.P.MEH.Preis);


  // Zuordnungsdialog anzeigen
  if (aMan=y) then begin
    vVSP # n;
    REPEAT
      if (Dlg_Standard:MATZ('MATZ', var vVSP, var vBehalten, var vStk,var vGewNetto, var vGewBrutto, var vMenge, var vDatum, var vDat1, var vDat2, var vZusatz)=false) then begin
        if (v401<>0) then RekRestore(v401);
        RETURN false;
      end;
    UNTIl (vMenge<>0.0);
  end;

  if (vBehalten) then begin
    if (Adr.Lieferantennr=0) then begin
      if (v401<>0) then RekRestore(v401);
      Msg(401205,'',0,0,0);
      RETURN false;
    end;
    // Material zuordnen aber BEHALTEN
    if (aMan) then
      if (vUrStk=vStk) then begin
        if (Msg(401201,'',_WinIcoQuestion,_WinDialogOkCancel,1)=_WinIdCancel) then begin
          if (v401<>0) then RekRestore(v401);
          RETURN false;
        end;
      end
      else begin
        if (Msg(401210,aint(vUrStk-vStk),_WinIcoQuestion,_WinDialogOkCancel,1)=_WinIdCancel) then begin
          if (v401<>0) then RekRestore(v401);
          RETURN false;
        end;
      end;
  end
  else begin
    // Material zuordnen und LÖSCHEN
    if (aMan) then
      if (vUrStk=vStk) then begin
        if (Msg(401202,'',_WinIcoQuestion,_WinDialogOkCancel,1)=_WinIdCancel) then begin
          if (v401<>0) then RekRestore(v401);
          RETURN false;
        end;
      end
      else begin
        if (Msg(401211,aint(vUrStk-vStk),_WinIcoQuestion,_WinDialogOkCancel,1)=_WinIdCancel) then begin
          if (v401<>0) then RekRestore(v401);
          RETURN false;
        end;
      end;
  end;

  // jetzt buchen...
  if (DFaktMat_DoIt(vBehalten, vStk, vGewNetto, vGewBrutto, vMenge, vDatum, vZeit)=false) then begin
    if (v401<>0) then RekRestore(v401);
    ErrorOutput;
    RETURN false;
  end;

  if (v401<>0) then RekRestore(v401);
  if (aMan) then begin
    if (vBehalten) then
      Msg(401206,AInt(Mat.Nummer),0,0,0)
    else
      Msg(401204,'',0,0,0);
  end;

  RETURN true;  // alles OK
end;


//========================================================================
// MatzMat    +ERR
//        Material(200) VSB setzen
// Material muss erstmal reserviert werden (203)
// dann kann von der Reservierung etwas VSB gesetzt werden
// was die Splittung der Karte zu Folge hat und die Kommission+Status setzt
// das kann dann in einen LFS eingetragen werden....
//========================================================================
sub MatzMat(
  aAuto           : logic;
  opt aVersand    : logic;
  // ST: Ab hier neu
  opt aStk        : int;
  opt aGewNetto   : float;
  opt aGewBrutto  : float;
  opt aMenge      : float;
  opt aSLNr       : int) : logic;
local begin
  vStk          : int;
  vGewNetto     : float;
  vGewBrutto    : float;
  vGew          : float;
  vMenge        : float;
  vDatum        : date;
  vZeit         : time;
  vNeuesMat     : int;
  vAltesMat     : int;
  vVersand      : logic;
  vDat1,vDat2   : date;
  vZusatz       : alpha;
  vPool         : int;
  vDiff         : float;
  vBehalten     : logic;

  vFremdResGew  : float;
  vFremdResStk  : int;

  v401          : int;
  Erx           : int;
  vPflichtSplit : logic;
end;
begin
  v401 # RekSave(401);
  vAltesMat # Mat.Nummer;

  if ("Mat.Löschmarker"='*') then begin
    RekRestore(v401);
    Error(200006,'');
    RETURN false
  end;

  // neue Kommission setzen
  if (Mat.Kommission<>'') and (Mat.Auftragsnr<>Auf.P.Nummer) then begin
    RekRestore(v401);
    Error(200011,'');
    RETURN false;
  end;

  if (aAuto=false) then begin
    Erx # PasstAuf2Mat(0,(aSLNr<>0),true);
    if (Erx<0) then begin
      RekRestore(v401);
      RETURN false;
    end;
    if (Erx=0) then begin
      if (Rechte[Rgt_Auf_MATZ_Konf_Abm]) then begin
        if (Msg(401015,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then begin
          RekRestore(v401);
          RETURN false;
        end;
      end
      else begin
        Msg(401016,'',_WinIcoError,_WinDialogOk,1);
        RekRestore(v401);
        RETURN false;
      end;
    end;
    RecBufCopy(v401,401);
  end;


  // Verwiegungsart holen
  Erx # RecLink(818,200,10,_recFirst);
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;


  RecBufCopy(v401, 401);

/***
  // AUTOMATISCH ------------------------------------------------------
  if (aAuto) then begin
    // Reservierung prüfen
    if (RecLinkInfo(203,200,13,_recCount)>1) then begin
      Error(200009,'');
      RekRestore(v401);
      RETURN false;
    end;
    if (RecLinkInfo(203,200,13,_recCount)=1) then begin
      Erx # RecLink(203,200,13,_recFirst);     // Reservierung holen
      WHILE (Erx<=_rLocked) do begin
        if ((Mat.R.AuftragsNr=0) and (Mat.R.Kundennummer<>Auf.P.Kundennr)) or
          ( (Mat.R.AuftragsNr<>0) and ((Mat.R.Auftragsnr<>Auf.P.Nummer) or (Mat.R.Auftragspos<>Auf.P.Position)) ) then begin
          Error(200009,'');
          RekRestore(v401);
          RETURN false;
        end;
        Erx # RecLink(203,200,13,_recNext);
      END;
    end;
  end
  // MANUELL ------------------------------------------------------------
  else begin
***/

    // Maskenvorbelegun mit Reservierungsmengen...
    FOR Erx # RecLink(203,200,13,_recFirst)     // Reservierungen loopen...
    LOOP Erx # RecLink(203,200,13,_recNext)
    WHILE (Erx<=_rLocked) do begin

      // für diesen Auftrag/Kunden?
      if ((Mat.R.AuftragsNr=0) and (Mat.R.Kundennummer=Auf.P.Kundennr)) or
        ((Mat.R.AuftragsNr<>0) and (Mat.R.Auftragsnr=Auf.P.Nummer) and (Mat.R.Auftragspos=Auf.P.Position)) then begin
        if (aAuto=false) then begin
          vStk          # vStk + "Mat.R.Stückzahl";
          if (VwA.NettoYN) then begin
            vGewNetto   # vGewNetto + Mat.R.Gewicht
            vGewBrutto  # vGewBrutto + Rnd(Lib_Berechnungen:Dreisatz(Mat.Gewicht.Brutto, Mat.Gewicht.Netto, vGewNetto), Set.Stellen.Gewicht);
          end
          else begin
            vGewBrutto  # vGewBrutto + Mat.R.Gewicht;
            vGewNetto   # vGewNetto  + Rnd(Lib_Berechnungen:Dreisatz(Mat.Gewicht.Netto, Mat.Gewicht.Brutto, vGewBrutto), Set.Stellen.Gewicht);
          end;
        end;
      end
      else if ((Mat.R.AuftragsNr=0) and (Mat.R.Kundennummer<>Auf.P.Kundennr)) or
        ( (Mat.R.AuftragsNr<>0) and ((Mat.R.Auftragsnr<>Auf.P.Nummer) or (Mat.R.Auftragspos<>Auf.P.Position)) ) then begin
        // "fremde" Reservierunge
        vFremdResStk # vFremdResStk + "Mat.R.Stückzahl";
        vFremdResGew # vFremdResGew + Mat.R.Gewicht;
      end;
    END;
//  end;



  if (aAuto=false) then begin
    if (vFremdResGew<>0.0) or (vFremdResStk<>0) then begin
      if (Msg(401027,'',_WinIcoWarning, _WinDialogOkCancel, 1)=_WinIdCancel) then begin
        RekRestore(v401);
        RETURN false;
      end;
      RecBufCopy(v401,401);
    end;
  end
  else begin
    vStk        # aStk;
    vGewNetto   # aGewNetto;
    vGewBrutto  # aGewBrutto;
    vMenge      # aMenge;
  end;



  if (vStk=0) then
    vStk        # Mat.Bestand.Stk;
  if (vGewNetto=0.0) and (vGewBrutto=0.0) then begin
    vGewNetto   # Mat.Gewicht.Netto;
    vGewBrutto  # Mat.Gewicht.Brutto;
  end;
  vDatum      # today;
  vZeit       # Now;
  vVersand    # Set.LFS.mitVersandYN;
  vZusatz     # Auf.P.Termin.Zusatz;
  vNeuesMat   # vAltesMat;

  // Zeitfenster errechnen...
  if (Auf.P.TerminZusage<>0.0.0) then begin
    vDat1       # Auf.P.TerminZusage;
    vDat2       # vDat1;
    Lib_Berechnungen:EndDatum_aus_ZahlJahr(Auf.P.Termin1W.Art, var Auf.P.TerminZ.Zahl, var Auf.P.TerminZ.Jahr, var vDat2);
  end
  else begin
    vDat1       # Auf.P.Termin1Wunsch;
    vDat2       # vDat1;
    if (Auf.P.Termin2Wunsch<>0.0.0) then begin
      vDat2     # Auf.P.Termin2Wunsch;
      Lib_Berechnungen:EndDatum_aus_ZahlJahr(Auf.P.Termin1W.Art, var Auf.P.Termin2W.Zahl, var Auf.P.Termin2W.Jahr, var vDat2);
    end
    else begin
      Lib_Berechnungen:EndDatum_aus_ZahlJahr(Auf.P.Termin1W.Art, var Auf.P.Termin1W.Zahl, var Auf.P.Termin1W.Jahr, var vDat2);
    end;
  end;

  if (aAuto=n) then begin
    Gv.int.01   # vStk;
    Gv.Num.01   # vGewNetto;
    Gv.Num.02   # vGewBrutto;
    Gv.Datum.01 # vDatum;
    if (RunAFX('MatzMat.Maske.Vorbelegung','')<>0) then begin
      vStk        # Gv.int.01;
      vGewNetto   # Gv.Num.01;
      vGewBrutto  # Gv.Num.02;
      vDatum      # Gv.Datum.01;
      if (vDAtum<>today) then vZeit # 0:0;
    end;
    // Eingabedialog starten
    if (Dlg_Standard:MATZ('VSB', var vVersand, var vBehalten, var vStk,var vGewNetto, var vGewBrutto, var vMenge, var vDatum, var vDat1, var vDat2, var vZusatz)=false) then begin
      RekRestore(v401);
      RETURN true;
    end;
  end
  else begin
    // Übergebene Werte nur übergeben wenn alle Werte gefüllt sind
    if (aStk <> 0) AND (aGewNetto <> 0.0) AND (aGewBrutto <> 0.0) AND (aMenge <> 0.0) then begin
      // Übergebene Werte nehmen
      // vVersand    # aVersand; // nicht relevant, nur Mengenangaben sind "neu" hinzugekommen
      vStk        # aStk;
      vGewNetto   # aGewNetto;
      vGewBrutto  # aGewBrutto;
      vMenge      # aMenge;
    end;
  end;

  if (VWa.NettoYN) then
    vGew # vGewNetto;
  else
    vGew # vGewBrutto;

  // Soll Rest bleiben?
  if ((vFremdResStk<>0) or (vFremdResGew<>0.0)) then begin
    if (vStk=Mat.Bestand.Stk) then begin
      Msg(401028,'',0,0,0);
      RekRestore(v401);
      RETURN false;
    end;
    if (Mat.Bestand.Stk - vStk < vFremdResStk) or (Mat.Bestand.Gew - vGew< vFremdResGew) then begin
      if (Msg(401029,aint(vFremdResStk)+'|'+anum(vFremdResGew, Set.Stellen.Gewicht),_WinIcoWarning, _WinDialogYesNo,2)<>_Winidyes) then begin
        RekRestore(v401);
        RETURN false;
      end;
    end;
    RecBufCopy(v401,401);
  end;

  // ohne Versand?
  if (vVersand=false) then begin
    // 07.09.2021 AH: Proj. 2190/119
    if (aAuto=false) and (Set.Wie.MATZ='A') then begin
      // keine Stückzahl mehr, aber Restgewicht?
      if (Mat.Bestand.Stk<=vStk) and ((Mat.Bestand.Gew-vGewNetto)>1.0) then begin
        Erx # Msg(200030, anum(Mat.Bestand.Gew-vGewNetto, Set.Stellen.Gewicht),0,_WinDialogYesNoCancel ,1);
        if (erx=_Winidcancel) then begin
          RekRestore(v401);
          RETURN true;
        end;
        vPflichtSplit # (Erx=_winidyes);
      end;
    end;

    // SPLITTEN???
    vNeuesMat # Mat.Nummer;
    if (vStk<>Mat.Bestand.Stk) or (vPflichtSplit) then begin
      if (aAuto=false) then begin
        if (Msg(200010,'',0,_WinDialogOkCancel,2)<>_WinidOk) then begin
          RekRestore(v401);
          RETURN true;
        end;
        if (Mat.Bestand.Gew<vGewNetto) then
          if (Msg(200016,'',0,_WinDialogOkCancel,2)<>_WinidOk) then begin
            RekRestore(v401);
            RETURN true;
          end;
      end;

      RecBufCopy(v401,401);

      TRANSON;

      // Alle "fremden" Reservierungen löschen...
      Erx # RecLink(203,200,13,_recFirst);
      WHILE (Erx<=_rLocked) do begin

        if ((Mat.R.AuftragsNr=0) and (Mat.R.Kundennummer=Auf.P.Kundennr)) or
          ( (Mat.R.AuftragsNr<>0) and (Mat.R.Auftragsnr=Auf.P.Nummer) and (Mat.R.Auftragspos=Auf.P.Position) ) then begin
          if (Mat_Rsv_data:Entfernen()=false) then begin
            TRANSBRK;
            Error(10004,aint(Auf.P.Position));
            RekRestore(v401);
            RETURN false;
          end;
          Erx # RecLink(203,200,13,_recFirst);
          CYCLE;
        end;

        Erx # RecLink(203,200,13,_recNext);
      END;


      // Splitten schiebt Reservierungen weiter und setzt VLDAWs um
      if (Mat_Data:Splitten(vStk, vGewNetto, vGewBrutto, 0.0, vDatum, vZeit, var vNeuesMat, c_Akt_VSB+' '+AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position))=false) then begin
        TRANSBRK;
        Error(200102,'');
        RekRestore(v401);
        RETURN false;
      end;

      Mat.Nummer # vNeuesMat;
      Erx # RecRead(200,1,0);

    end
    else begin  // ohne Split...

      TRANSON;

      // 06.10.2009 MS Brutto oder Netto gaendert? Material aktualisieren ueber Bestandsbuch
      if (vGewNetto <> Mat.Bestand.Gew) or (vGewBrutto <> Mat.Bestand.Gew) then begin

        Erx # RecRead(200, 1, _recLock);  // Material sperren
        if(Erx <> _rOK) then begin
          TRANSBRK;
          Error(200106, AInt(Mat.Nummer));
          RekRestore(v401);
          RETURN false;
        end;

        // Gucken ob Brutto oder Netto Verwiegung
        //
        // Bei Differenz Bestand korrigieren und eintrag ins Bestandsbuch
        if (VWa.NettoYN) then begin
          if(Mat.Bestand.Gew <> vGewNetto) then
            vGew # vGewNetto;
        end
        else if (VWa.BruttoYN) then begin
          if(Mat.Bestand.Gew <> vGewBrutto) then
            vGew # vGewBrutto;
        end
        else begin
          if(Mat.Bestand.Gew <> vGewBrutto) then
            vGew # vGewBrutto;
        end;

        // Bestaendsaenderung?
        if(vGew <> 0.0) and (vGew<>Mat.Bestand.Gew) then begin
          Mat_Data:Bestandsbuch(0, vGew - Mat.Bestand.Gew, 0.0, 0.0, 0.0, c_Akt_VSB+' '+cnvai(Auf.P.Nummer)+'/'+cnvai(Auf.P.Position), vDatum, vZeit, c_Akt_VSB, Auf.P.Nummer, Auf.P.Position);
          vDiff # vGew - Mat.Bestand.Gew;
          Mat.Bestand.Gew # vGew;
        end;

        // Brutto/Netto Werte uebernehmen
        Mat.Gewicht.Netto  # vGewNetto;
        Mat.Gewicht.Brutto # vGewBrutto;

        Erx # Mat_Data:Replace(_RecUnlock,'MAN');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Error(200106, AInt(Mat.Nummer));
          RekRestore(v401);
          RETURN false;
        end;
        if ("Set.Mat.!InternUmlag"=false) and (vDiff<>0.0) then begin
          // eigene Schrottumlage...
          RecBufClear(204);
          Mat.A.Aktionsmat    # Mat.Nummer;
          Mat.A.Aktionstyp    # c_Akt_Mat_Umlage;
          Mat.A.Bemerkung     # c_AktBem_Mat_Umlage;
          Mat.A.Aktionsdatum  # vDatum;
          Mat.A.Aktionszeit   # vZeit;
          Mat.A.Terminstart   # Mat.A.Aktionsdatum;
          Mat.A.Terminende    # Mat.A.Aktionsdatum;
          Mat.A.Adressnr      # 0;
          if (Mat.Bestand.Gew<>0.0) then
            Mat.A.KostenW1      # Rnd(- (vDiff * Mat.EK.Effektiv / Mat.Bestand.Gew),2);
          Mat_A_Data:Insert(0,'AUTO')
          if (Mat_A_Data:Vererben()=false) then begin
            TRANSBRK;
            ErrorOutput;
            RekRestore(v401);
            RETURN false;
          end;
        end;

      end;

    end;
  end   // ohne Versand
  else begin
    // mit Versand...
    TRANSON;
  end;

  Erx # Mat_Data:SetKommission(vNeuesMat, Auf.P.Nummer, Auf.P.position, aSLNr, 'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(200402,AInt(Erx));
    RekRestore(v401);
    RETURN false;
  end;

  // Versand beauftragen?
  if (vVersand) and (Mat.Bestellt.Gew=0.0) then begin

    vPool # VsP_Data:Mat2Pool(vNeuesMat, c_VSPTyp_Auf, Auf.P.Nummer, Auf.P.Position, 0);
    if (vPool=0) then begin
      TRANSBRK;
      Error(655000,'');
      ErrorOutput;
      RekRestore(v401);
      RETURN false;
    end;

    // weitere Daten nachtragen...
    RecRead(655,1,_recLock);
    VsP.Termin.MinDat # vDat1;
    VsP.Termin.MaxDat # vDat2;
    VsP.Termin.Zusatz # vZusatz;
    RekReplace(655,_recUnlock,'AUTO');

    // Aktion auf Versand setzen...
    Erx # RecLink(404,401,12,_recFirst);  // Aktionen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.A.Aktionstyp=c_Akt_VSB) or (Auf.A.Aktionstyp=c_Akt_VSBPool) and (Auf.A.Materialnr=vNeuesMat) then begin
        Erx # 99;
        BREAK;
      end;
      Erx # RecLink(404,401,12,_recNext);
    END;
    if (Erx<>99) then begin
      TRANSBRK;
      Error(655000,'');
      ErrorOutput;
      RekRestore(v401);
      RETURN false;
    end;
    RecRead(404,1,_recLock);
    Auf.A.VersandPoolnr # vPool;
    Erx # Rekreplace(404,_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Error(655000,'');
      ErrorOutput;
      RekRestore(v401);
      RETURN false;
    end;
  end;

  TRANSOFF;
  if (aAuto=n) then Msg(200401,'',0,0,0);           // Erfolg !

  RekRestore(v401);

  RETURN true; // ST 2009-09-07: Auf_P_Main erwartet bool als Abfrageergebnis
end;


//========================================================================
//========================================================================
sub MatzMatGuBe(aMatNr : int) : logic;
local begin
  Erx : int;
end;
begin
  Mat.Nummer # aMatNr;
  Erx # RecRead(200,1,0);         // Material holen
  if (Erx>=_rLocked) then begin
    Msg(401203,'1',0,0,0);
    RETURN false;
  end;

//  Mat_B_Data:BewegungenRueckrechnen(1.1.1900);
  // Bestand rückrechnen...
  // 17.11.2016 MACHT FAKTURA
/***
  Erx # RecLink(202,200,12,_RecLast);     // Bestandsbuch loopen
  WHILE (Erx<=_rLocked) do begin
    if (Mat.B.Menge<>0.0) or ("Mat.B.Stückzahl"<>0) or (Mat.B.gewicht<>0.0) then begin
      Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
      Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
      Mat.Bestand.Menge # Mat.Bestand.Menge - Mat.B.Menge;
    end;
    Erx # RecLink(202,200,12,_RecPrev);
  END;
***/

  // Aktion anlegen
  RecBufClear(404);
  Auf.A.Aktionsnr       # Auf.P.Nummer;
  Auf.A.AktionsPos      # Auf.P.Position;
  Auf.A.Materialnr      # aMatNr;
  Auf.A.Aktionstyp      # c_Akt_GBMat;

  if (Wgr_data:IstMix(Auf.P.Wgr.Dateinr)) then  // ggf. Artikelnummer für 209er übernehmen
    Auf.A.ArtikelNr # Mat.Strukturnr;

  Auf.A.Bemerkung       # c_AktBem_GBMat;
  Auf.A.TerminStart     # today;
  Auf.A.TerminEnde      # today;
  Auf.A.AktionsDatum    # Today;
  Auf.A.MEH.Preis       # Auf.A.MEH.Preis;
  Auf.A.MEH             # Auf.P.MEH.Einsatz;
// 17.11.2016 macht FAKTURA if (Lib_Einheiten:TransferMengen('200>404,VSB')=false) then begin
//    Error(401203,'141');
//    RETURN false;
//  end;

  if (Auf_A_Data:NeuAnlegen(n)<>_rOK) then begin
    Error(401203,'11');
    RETURN false;
  end;


  RETURN true;
end;


//========================================================================
// ReservMat    +ERR
//========================================================================
sub ReservMat() : logic;
begin
  RecBufClear(203);
  Mat.R.Materialnr      # Mat.Nummer;
  "Mat.R.Stückzahl"     # "Auf.P.Stückzahl";
  Mat.R.Gewicht         # Auf.P.Gewicht;
  "Mat.R.Trägertyp"     # '';
  "Mat.R.TrägerNummer1" # 0;
  "Mat.R.TrägerNummer2" # 0;
  Mat.R.Kundennummer    # Auf.P.Kundennr;
  Mat.R.KundenSW        # Auf.P.KundenSW;
  Mat.R.Auftragsnr      # Auf.P.Nummer;
  Mat.R.AuftragsPos     # Auf.P.Position;
  if (Mat_Rsv_Data:Neuanlegen()=false) then RETURN false

 RETURN true;
end;


//========================================================================
// VLDAW_Pos_Einfuegen_Art
//
//========================================================================
sub VLDAW_Pos_Einfuegen_Art(
  aNr       : int;
  var aPos  : int;
  aSLNr     : int) : logic;
local begin
  Erx : int;
end;
begin

  // Zuordnung gefunden!!!
  RecBufClear(441);
  Lfs.P.Nummer        # aNr;
  Lfs.P.Auftragsnr    # Auf.P.Nummer;
  Lfs.P.AuftragsPos   # Auf.P.Position;
  Lfs.P.AuftragsPos2  # aSLNr;
  Lfs.P.Kommission    # AInt(Lfs.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos);
  if (Lfs.P.Auftragspos2<>0) then
    Lfs.P.Kommission  # Lfs.P.Kommission + '/'+AInt(Lfs.P.Auftragspos2);


  Lfs.P.Kundennummer  # Auf.P.Kundennr;

  Lfs.Kundennummer    # Auf.P.Kundennr;
  Lfs.Kundenstichwort # Auf.P.KundenSW;
  Lfs.Zieladresse     # Auf.Lieferadresse;
  Lfs.Zielanschrift   # Auf.Lieferanschrift;

  "Lfs.P.Stück"         # "Auf.A.Stückzahl";
  Lfs.P.Gewicht.Brutto  # Auf.A.Gewicht;
  Lfs.P.Gewicht.Netto   # Auf.A.Nettogewicht;

  Lfs.P.Menge.Einsatz   # Auf.A.Menge;
  Lfs.P.MEH.Einsatz     # Auf.A.MEH;

  Lfs.P.Menge           # Auf.A.Menge.Preis;
  Lfs.P.MEH             # Auf.A.MEH.Preis;

  RecLink(250,404,3,_RecFirst);       // Artikel holen
  RecLink(252,404,4,_RecFirsT);       // Charge holen
  Lfs.P.Materialtyp   # c_IO_ART;
  Lfs.P.ArtikelNr     # Auf.A.ArtikelNr;
  Lfs.P.Art.Charge    # Auf.A.Charge;
  Lfs.P.Art.Adresse   # Auf.A.Charge.Adresse;
  Lfs.P.Art.Anschrift # Auf.A.Charge.Anschr;
  Lfs.P.Bemerkung     # Auf.A.Bemerkung;

  // LFS-Position anlegen
  Lfs.P.Anlage.Datum  # today;
  Lfs.P.Anlage.Zeit   # now;
  Lfs.P.Anlage.User   # gUsername;

  REPEAT
    Lfs.P.Position      # aPos;
    Erx # RekInsert(441,0,'AUTO');
    aPos # aPos + 1;
  UNTIL (erx=_rOk);

  RETURN true;
end;


//========================================================================
// VLDAW_Pos_Einfuegen_Mat
//
//========================================================================
sub VLDAW_Pos_Einfuegen_Mat(
  aNr           : int;
  var aPos      : int;
  aSLNr         : int;
  opt aRsrvMat  : logic ) : logic;;
local begin
  Erx     : int;
  vBuf441   : int;
  vOK       : logic;
end;
begin

  // Mat. bereits zum fahren?
  if (Mat.Status=c_Status_BAGZumFahren) then RETURN false;

  if ("Mat.Löschmarker"='*') then begin
    Error(441002,'');
    RETURN false;
  end;
  if (Mat.Status>c_Status_bisFrei) and (Mat.Status<>c_STATUS_VSB) and (Mat.Status<>c_STATUS_VSBKonsi) and
    (Mat.Status<>c_Status_EKWE) and (Mat.Status<>c_Status_EKVSB) and
    (Mat.Status<>c_Status_Versand)    // 27.04.2022 AH
    then begin
    Error(441002,'');
    RETURN false;
  end;

  // Bei Übernahme von reservierten Materialien für FA/Lfs nicht kommisionierte auch betrachten [04.02.2010/PW]
  if ( !aRsrvMat ) then begin
    // ursprüngliche Abfrage
    if (Mat.Auftragsnr<>Auf.P.Nummer) or (Mat.Auftragspos<>Auf.P.Position) then begin
      Error(441009,'');
      RETURN false;
    end;
  end;

  // Zuordnung gefunden!!!
  RecBufClear(441);
  Lfs.P.Nummer        # aNr;
  Lfs.P.Auftragsnr    # Auf.P.Nummer;
  Lfs.P.AuftragsPos   # Auf.P.Position;
  Lfs.P.AuftragsPos2  # aSLNr;
  Lfs.P.Kommission    # AInt(Lfs.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos);
  if (Lfs.P.Auftragspos2<>0) then
    Lfs.P.Kommission  # Lfs.P.Kommission + '/'+AInt(Lfs.P.Auftragspos2);

  Lfs.P.Kundennummer  # Auf.P.Kundennr;

  Lfs.Kundennummer    # Auf.P.Kundennr;
  Lfs.Kundenstichwort # Auf.P.KundenSW;
  Lfs.Zieladresse     # Auf.Lieferadresse;
  Lfs.Zielanschrift   # Auf.Lieferanschrift;

  Lfs.P.Verwiegungsart  # Auf.P.Verwiegungsart;
  Lfs.P.Materialtyp     # c_IO_Mat;
  if (Mat.Status=c_Status_EKVSB) then Lfs.P.Materialtyp # c_IO_VSB;   // VSB-EK?

  Lfs.P.Materialnr      # Mat.Nummer;
  Lfs.P.Paketnr         # Mat.Paketnr;
  Lfs.P.Reservierungnr  # 0;
  Lfs.P.Ursprungsmatnr  # Lfs.P.Materialnr;

// 15.05.5014
//  Lfs.P.Menge.Einsatz   # Mat.Bestand.Gew;
//  Lfs.P.MEH.Einsatz     # 'kg';
  Lfs.P.MEH             # Auf.P.MEH.Preis;
  Lfs.P.MEH.Einsatz     # Auf.P.MEH.Einsatz;

  Erx # RecLink(818,441,2,_recFirst);   // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  if (Lib_Einheiten:TransferMengen('200>441,VLDAW')=false) then begin
    RETURN false;
  end;
/*
  "Lfs.P.Stück"         # Mat.Bestand.Stk;
  Lfs.P.Gewicht.Brutto  # Mat.Gewicht.Brutto;
  Lfs.P.Gewicht.Netto   # Mat.Gewicht.Netto;
  Lfs.P.Menge.Einsatz   # Lib_Einheiten:WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Netto, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH.Einsatz);
  if (Lfs.P.MEH='kg') or (Lfs.P.MEH='t') then begin
    Erx # RecLink(818,441,2,_recFirst);   // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    // AI 02.12.2011: war ...WandleMEH(404,...
    if (VWa.NettoYN) then
      Lfs.P.Menge         # Lib_Einheiten:WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Netto, 0.0, '', Lfs.P.MEH)
    else
      Lfs.P.Menge         # Lib_Einheiten:WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, 0.0, '', Lfs.P.MEH);
  end
  else begin
    // 15.10.2013 AH
    if (Mat.MEH<>'') and (Mat.MEH<>'kg') then
      Lfs.P.Menge           # Lib_Einheiten:WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH)
    else
      Lfs.P.Menge           # Lib_Einheiten:WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge.Einsatz, Lfs.P.MEH.Einsatz, Lfs.P.MEH);
  end;
*/


  // bereits in anderen VLDAWs?
  vOK # y;
  vBuf441 # RekSave(441);
  Erx # RecRead(vBuf441,3,0);     // bereits in VLDAW?
  WHILE (Erx<=_rMultikey) and (vBuf441->Lfs.P.Materialnr=Mat.Nummer) and (vOK) do begin
    if (vBuf441->Lfs.P.Datum.Verbucht=0.0.0) then begin
      vOK # false;
    end;
    Erx # RecRead(vBuf441,3,_RecNext);
  END;
  RecbufDestroy(vBuf441);
  if (vOK=False) then begin
    //Error(441010,'');
    RETURN false;
  end;

  // LFS-Position anlegen
  Lfs.P.Anlage.Datum  # today;
  Lfs.P.Anlage.Zeit   # now;
  Lfs.P.Anlage.User   # gUsername;

  REPEAT
    Lfs.P.Position      # aPos;
    Erx # RekInsert(441,0,'AUTO');
    aPos # aPos + 1;
  UNTIL (erx=_rOk);

  RETURN true;
end;


//========================================================================
// UpdateVLDAW
//
//========================================================================
sub UpdateVLDAW() : logic;
local begin
  Erx     : int;
  vLfPos  : int;
  vVLDAW  : int;
  vVLDAW2 : int;
  vBuf400 : int;
  vBuf401 : int;
  vBuf404 : int;
end;
begin

  // nie updaten?
  if (Set.Wie.Auf2Lfs='NEU') then RETURN false;


  // bisherigen VLDAW suchen
  Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recFirst);
  WHILE (vVLDAW=0) and (Erx<=_rLocked) do begin   // Positionen loopen

    if ("Auf.P.Löschmarker"='*') then begin
      Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recNext);
      CYCLE;
    end;

    Erx # RecLink(404,401,12,_recFirst);
    WHILE (vVLDAW=0) and (Erx<=_rLocked) do begin // Aktionen loopen

      if ("Auf.A.Löschmarker"<>'*') and
          (Auf.A.Aktionstyp=c_Akt_VLDAW) then begin
          vVLDAW # Auf.A.Aktionsnr;
      end;

      Erx # RecLink(404,401,12,_recNext);
    END;

    Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recNext);
  END;

  // bisher keine VLDAW - dann Ende
  if (vVLDAW=0) then RETURN false;

  // keine 2. VLDAW generieren?
  if (Set.Wie.Auf2Lfs='SPERRE') then begin
    Msg(400014,cnvai(vVLDAW),_WinIcoError,_WinDialogOk,1);
    RETURN true;
  end;

  if (Set.Wie.Auf2Lfs='FRAGE') then begin
    Erx # Msg(400015,cnvai(vVLDAW),_WinIcoQuestion,_WinDialogYesNoCancel,3);
    if (Erx=_WinIdCancel) then RETURN true; // Abbruch
    if (Erx=_WinidNo) then RETURN false;    // neuen LFS anlegen
  end;

  if (Set.Wie.Auf2Lfs='UPDATE') then begin
    Erx # Msg(400016,cnvai(vVLDAW),_WinIcoWarning,_WinDialogYesNo,2);
    if (Erx=_WinIdNo) then RETURN true;     // Abbruch
  end;



  // bisherige VLDAW ersetzen ------------------------------------------
  vLfPos # 1;

  TRANSON;

  Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recFirst);
  WHILE (Erx<=_rLocked) do begin          // Positionen loopen

    if ("Auf.P.Löschmarker"='*') then begin
      Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recNext);
      CYCLE;
    end;

    Erx # RecLink(404,401,12,_RecFirst);  // Aktionen loopen
    WHILE (Erx<=_rLocked) do begin

      if ("Auf.A.Löschmarker"='*') or
        (Auf.A.Aktionstyp<>c_Akt_VSB) or
        (Auf.A.Menge<=0.0) then begin
        Erx # RecLink(404,401,12,_RecNext);
        CYCLE;
      end;

      // alles merken
      vBuf400 # RekSave(400);
      vBuf401 # RekSave(401);
      vBuf404 # RekSave(404);


      vVLDAW2 # 0;
      Erx # RecLink(404,401,12,_RecFirst);  // Aktionen loopen
      WHILE (Erx<=_rLocked) do begin
        if ("Auf.A.Löschmarker"<>'*') and (Auf.A.Aktionstyp=c_Akt_VLDAW) then begin
          vVLDAW2 # Auf.A.Aktionsnr;
          BREAK;
        end;
        Erx # RecLink(404,401,12,_RecNext);
      END;

      // Position existiert bereits?
      if (vVLDAW2<>0) then begin
        Lfs.Nummer  # Auf.A.AktionsNr;
        Erx # RecRead(440,1,0);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(440100,AInt(Auf.A.Aktionsnr),0,0,0);
          RETURN true;
        end;
        Lfs.P.Nummer    # Auf.A.AktionsNr;
        Lfs.P.Position  # Auf.A.AktionsPos;
        Erx # RecRead(441,1,0);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos),0,0,0);
          RETURN true;
        end;

        // bisherige VLDAW stornieren
        if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
          TRANSBRK;
//          Msg(440441,ErxA,0,0,0);
          Error(440441,'');
          ErrorOutput;
          RETURN true;
        end;
        // Position löschen
        Erx # RekDelete(441,0,'AUTO');
        if (erx<>_rOK) then begin
          TRANSBRK;
          Msg(441000,AInt(Lfs.P.Position),0,0,0);
          RETURN true;
        end;
      end;

      // Restore
      RekRestore(vBuf400);
      RekRestore(vBuf401);
      RekRestore(vBuf404);
      RecRead(400,1,0);
      RecRead(401,1,0);
      RecRead(404,1,0);
      // alles merken
      vBuf400 # RekSave(400);
      vBuf401 # RekSave(401);
      vBuf404 # RekSave(404);

      // Position neu anlegen:
      // Position aufnehmen
      // Material:
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
        Erx # RecLink(200,441,4,_recFirst);   // Material holen
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(440441,AInt(Lfs.P.Position),0,0,0);
          RETURN false;
        end;
        if (vVLDAW2=0) then
          VLDAW_Pos_einfuegen_Mat(vVLDAW,var vLfPos, Auf.A.Aktionspos2)
        else
          VLDAW_Pos_einfuegen_Mat(vVLDAW2,var vLfPos, Auf.A.Aktionspos2);
      end;
      // Artikel
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
        if (vVLDAW2=0) then
          VLDAW_Pos_einfuegen_Art(vVLDAW,var vLfPos, Auf.A.Aktionspos2)
        else
          VLDAW_Pos_einfuegen_Art(vVLDAW2,var vLfPos, Auf.A.Aktionspos2);
      end;

      // VLDAW verbuchen
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n,0)=false) then begin
        TRANSBRK;
        Error(440441,'');
        ErrorOutput;
        RETURN true;
      end;


      // Restore
      RekRestore(vBuf400);
      RekRestore(vBuf401);
      RekRestore(vBuf404);
      RecRead(400,1,0);
      RecRead(401,1,0);
      RecRead(404,1,0);

      Erx # RecLink(404,401,12,_RecNext);
    END;

    Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_recNext);
  END;

  TRANSOFF;

  Msg(400017,AInt(vVLDAW),0,0,0);

  RETURN true;
end;


//========================================================================
// Rechnungslauf
//
//========================================================================
sub Rechnungslauf();
local begin
  Erx     : int;
  vReDatum            : date;
  vBisLiefDatum       : date;
  vSkontoDatum        : date;
  vSkontoProzent      : float;
  vZielDatum          : date;
  vValutadatum        : date;
  vLetztesLiefDatum   : date;
  v400                : int;
  v903                : int;
  vOK                 : logic;
end;
begin
  if (Rechte[Rgt_Auf_Druck_RE]=n) then RETURN;

  if (Msg(400011,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;

  // erstmal keine Zahlungsbedingung
  RecBufClear(816);
  // Eingabemaske aufrufen
  if (Lib_Faktura:RE_Eingabemaske(var vReDatum, var vBisLiefDatum, var vSkontoDatum, var vSkontoProzent, var vZielDatum, var vValutadatum)=false) then
    RETURN;

  v903 # RecbufCreate(903);
  Erx # RecRead(v903,1,_recfirst);
  if (Erx<>_rOK) then begin
    RecBufDestroy(v903);
    RETURN;
  end;
  "Set.Wie.GutBel#SepYN"  # v903->"Set.Wie.GutBel#SepYN";
//      Set.Auf.GutBelLFNull    # v903->Set.Auf.GutBelLFNull;
  RecBufDestroy(v903);

  APPOFF();

  RecBufCreate(v400);
  FOR Erx # RecRead(400,1,_RecFirst)  // Aufträge loopen
  LOOP Erx # RecRead(400,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    RecBufCopy(400,v400);

    if ("Auf.Löschmarker"='*') or (Auf.Vorgangstyp<>c_AUF) then CYCLE;

    // Marker berechnen
    Erx # RecLink(401,400,9,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      RecRead(401,1,_RecNoLoad | _RecLock);
      Pos_BerechneMarker();
      PosReplace(_recUnlock,'AUTO');
      Erx # RecLink(401,400,9,_RecNext);
    END;
    RecRead(400,1,_RecNoLoad | _RecLock);
    BerechneMarker();
    RekReplace(400,_recUnlock,'AUTO');

    if (Auf.Aktionsmarker<>'$') then CYCLE;

    // Aufpreise prüfen
    vOK # y;
    FOR Erx # RecLink(403,400,13,_RecFirst)
    LOOP Erx # RecLink(403,400,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (Auf.Z.Vpg.ArtikelNr<>'') and (Auf.Z.Vpg.OKYN=n) then begin
        vOK # false;
        BREAK;
      end;
    END;
    if (vOK=false) then begin
      APPON();
      Msg(400006,'',0,0,0);
      APPOFF();
      RecBufCopy(v400,400);
      CYCLE;
    end;

    // Zahlungsbedingung holen
    Erx # RecLink(816,400,6,_recFirst);
    if (Erx>_rLocked) then begin
      APPON();
      Msg(001201,Translate('Zahlungsbedingung'),0,0,0);
      APPOFF();
      RecBufCopy(v400,400);
      CYCLE;
    end;
    if (Zab.IndividuellYN) or (ZaB.SperreYN) then CYCLE;

    // Aktionen durchtesten, OFP & Erlöse vorbelegen
    if (Lib_Faktura:RE_Vorbereiten(var vReDatum, vBisLiefDatum,vSkontoDatum,vSkontoProzent,vZielDatum,vValutadatum, y)=false) then begin
      CYCLE;
    end;


    //*********************************************************************
    // VERBUCHUNG
    //*********************************************************************
    TRANSON;

    if ("Set.Wie.GutBel#SepYN") and
      ((Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF)) then
      Erl.Rechnungsnr # Lib_Nummern:ReadNummer('Gutschrift/Belastung')
    else
      Erl.Rechnungsnr # Lib_Nummern:ReadNummer('Rechnung');

    if (Erl.Rechnungsnr=0) then begin
      TRANSBRK;
      APPON();
      Msg(400012,AInt(Auf.Nummer),_WinIcoInformation,0,0);
      RecBufDestroy(v400);
      RETURN;
    end;
    Lib_Nummern:SaveNummer()

    // Verbuchen
    if (Lib_Faktura:RE_Verbuchen(vBisLiefDatum)=false) then begin
//      TRANSBRK; in Sub
      APPON();
      Msg(400012,AInt(Auf.Nummer),_WinIcoInformation,0,0);
      RecBufDestroy(v400);
      RETURN;
    end;

    TRANSOFF;

    APPON();

    //*********************************************************************
    // DRUCK
    //*********************************************************************
    Lib_Dokumente:Printform(450,'Rechnung',true);

    APPOFF();
    RecBufCopy(v400,400);
  END;

  // Fertig !
  Msg(400013,AInt(Erl.Rechnungsnr),_WinIcoInformation,0,0);

end;


//========================================================================
//  Read
//        liest eine Auf.Position aus dem Bestand ODER Ablage + ggf. Kopf
//========================================================================
sub Read(
  aAufNr    : int;
  aPos      : int;
  aMitKopf  : logic;
  opt aSLNr : int) : int;
local begin
  Erx : int;
end;
begin

  if (aSLNr<>0) then begin
    Auf.SL.Nummer     # aAufNr;
    Auf.SL.Position   # aPos;
    Auf.SL.LfdNr      # aSLNr;
    Erx # RecRead(409,1,0);
    if (Erx>_rLocked) then RecBufClear(409);
  end;

  // Bestand?
  Auf.P.Nummer    # aAufNr;
  Auf.P.Position  # aPos;
  Erx # RecRead(401,1,0);
  if (Erx<=_rLocked) then begin
    if (aMitKopf) then RecLink(400,401,3,_recFirst);
    RETURN 401;
  end;

  // Ablage?
  "Auf~P.Nummer"    # aAufNr;
  "Auf~P.Position"  # aPos;
  Erx # RecRead(411,1,0);
  if (Erx<=_rLocked) then begin
    RecBufCopy(411,401);
    if (aMitKopf) then begin
      RecLink(410,411,3,_recFirst);
      RecBufCopy(410,400);
    end;
    RETURN 411;
  end;

  // Nicht da!
  RecBufClear(401);
  if (aMitKopf) then RecBufClear(400);
  RETURN _rNoRec;
end;


//========================================================================
//  ReadKopf
//        liest einen Auftrag aus dem Bestand ODER Ablage
//========================================================================
sub ReadKopf(
  aAufNr    : int) : int;
local begin
  Erx : int;
end;
begin
  // Bestand?
  Auf.Nummer    # aAufNr;
  Erx # RecRead(400,1,0);
  if (Erx<=_rLocked) then begin
    RETURN 400;
  end;

  // Ablage?
  "Auf~Nummer"    # aAufNr;
  Erx # RecRead(410,1,0);
  if (Erx<=_rLocked) then begin
    RecBufCopy(410,400);
    RETURN 410;
  end;

  // Nicht da!
  RecBufClear(400);
  RETURN _rNoRec;
end;


//========================================================================
sub _SetAbrufinSL(
  aM    : float;
  aStk  : int;
  aGew  : float)
begin
//debugx('set KEY409 auf '+anum(agew,0));
  if (Auf.SL.Prd.Lfs<>aM) or (Auf.SL.Prd.Lfs.Stk<>aStk) or (Auf.SL.Prd.Lfs.Gew<>aGew) then begin
    RecRead(409,1,_recLock);
    Auf.SL.Prd.Lfs      # aM;
    Auf.SL.Prd.Lfs.Stk  # aStk;
    Auf.SL.Prd.Lfs.Gew  # aGew;
    RekReplace(409);
  end;
end;
  

//========================================================================
//  VerteileAbrufeInSL
//      rekalkuliert Abrufe in die Stückliste(Feinterminierung des Rahmens
//========================================================================
sub VerteileAbrufeInSL(
  aRa401    : int;
  opt aTyp  : alpha) : logic;
local begin
  v409    : int;
  Erx     : int;
  vA,vB   : alpha(200);
  vAb401  : int;
  vDat    : Date;
  vTxt    : int;
  vM      : float;
  vGew    : float;
  vStk    : int;
  vI,vJ   : int;
end;
begin
  if (aTyp='') then aTyp # c_Akt_Abruf;

  v409  # RekSave(409);
  vAb401 # RekSave(401);
  vTxt # TextOpen(20);

//  vM   # aRa401->Auf.P.Prd.LFS;     // Auf.P.Menge.Wunsch;
//  vStk # aRa401->Auf.P.Prd.LFs.Stk; //"Auf.P.Stückzahl";
//  vGew # aRa401->Auf.P.Prd.Lfs.Gew; //Auf.P.Gewicht;
  /***
  RecBufClear(404);
  Auf.A.Aktionstyp    # aTyp;
  Auf.A.Aktionsnr     # vAb401->Auf.P.Nummer;
  Auf.A.Aktionspos    # vAb401->Auf.P.Position;
  Auf.A.Aktionspos2   # 0;
  FOR Erx   # RecRead(404,2,0)
  LOOP Erx  # RecRead(404,2,_recNext)
  WHILE (Erx<_rnorec) and (Auf.A.Aktionstyp=aTyp) and
    (Auf.A.Aktionsnr=vAb401->Auf.P.Nummer) and (Auf.A.Aktionspos=vAb401->Auf.P.Position) do begin

    if (Erx=_rLocked) then begin
      Rekrestore(vAb401);
      TextClose(vTxt);
      RETURN false;
    end;

    // falscher Artikel?
    if (Auf.A.Artikelnr<>'') and (Auf.A.ArtikelNr<>vAb401->Auf.P.Artikelnr) then CYCLE;
    
    // Aktion merken:
    vA # Auf.A.Artikelnr;
    vA # vA + '|' + anum(Auf.A.Menge,3);
    vA # vA + '|' + aint(Auf.SL.lfdNr);
    vA # vA + '|' + anum(Auf.SL.Menge,3);     // Max
    vA # vA + '|' + anum(Auf.SL.Prd.LFS,3);   // Abgerufen
    TextAddLine(vTxt, vA);
  
    vM2 # vM2 + Auf.A.Menge;
  END;
***/
  // Abrufsummen pro ARTIKEL erstellen
  RecBufClear(404);
  Auf.A.Nummer        # aRa401->Auf.P.Nummer;
  Auf.A.Position      # aRa401->Auf.P.Position;
  Auf.A.Aktionspos2   # 0;
  Auf.A.Aktionstyp    # aTyp;
  FOR Erx   # RecRead(404,6,0)
  LOOP Erx  # RecRead(404,6,_recNext)
  WHILE (Erx<_rnorec) and (Auf.A.Aktionstyp=aTyp) and
    (Auf.A.Nummer=aRa401->Auf.P.Nummer) and (Auf.A.Position=aRa401->Auf.P.Position) do begin
    vA # 'Sum|'+Auf.A.ArtikelNr+'|';
    vI # TextSearch(vTxt, 1, 1, _TextsearchCI, vA);
    if (vI=0) then begin
      vA # vA + anum(Auf.A.Menge,3)+ '|';
      vA # vA + aint("Auf.A.Stückzahl")+ '|';
      vA # vA + anum(Auf.A.Gewicht,3)+ '|';
      TextAddLine(vTxt, vA);
//debugx('add '+vA);
      CYCLE;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vM    # cnvfa(Str_token(vA,'|',3));
    vStk  # cnvia(Str_token(vA,'|',4));
    vGew  # cnvfa(Str_token(vA,'|',5));
    vA # 'Sum|'+Str_Token(vA,'|',2)+'|';
    vA # vA + anum(vM + Auf.A.Menge,3)+ '|';
    vA # vA + aint(vStk + "Auf.A.Stückzahl")+ '|';
    vA # vA + anum(vGew + Auf.A.Gewicht,3)+ '|';
    TextLineWrite(vTxt, vI, vA, 0);
//debugx('mod '+vA);
  END;

  // ArtikelXYZ | 100,000|Stk|Gew
  
  // SL loopen...
  FOR Erx # RecLink(409,aRa401,23,_recFirst)    // 23=nach Termin, 9=normal
  LOOP Erx # RecLink(409,aRa401,23,_recNext)
  WHILE (erx<=_rLocked) do begin

    // spätester SL merken
    vA # 'Last|'+Auf.SL.ArtikelNr+'|';
    vI # TextSearch(vTxt, 1, 1, _TextsearchCI, vA);
    if (vI=0) then begin
      vA # vA + cnvad(Auf.SL.Termin)+'|';
      vA # vA + aint(Auf.Sl.LfdNr)+'|';
      TextAddLine(vTxt, vA);
//debugx('add '+vA);
    end
    else begin
      vB # Str_Token(vA,'|',3);
      if (vB<>'') then
        vDat # cnvda(vB)
      else
        vDat # 0.0.0;
      if (Auf.Sl.Termin>vDat) then begin
        vA # TextLineRead(vTxt, vI, 0);
        vA # 'Last|'+Auf.SL.ArtikelNr+'|';
        vA # vA + cnvad(Auf.SL.Termin)+'|';
        vA # vA + aint(Auf.Sl.LfdNr)+'|';
        TextLineWrite(vTxt, vI, vA, 0);
//debugx('mod '+vA);
      end;
    end;
    
    vA # 'Sum|'+Auf.SL.ArtikelNr+'|';
    vI # TextSearch(vTxt, 1, 1, _TextsearchCI, vA);
    if (vI=0) then begin  // dieser Artikel ist gar NICHT abgerufen !!
      _SetAbrufInSL(0.0,0,0.0);
      CYCLE;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vM    # cnvfa(Str_token(vA,'|',3));
    vStk  # cnvia(Str_token(vA,'|',4));
    vGew  # cnvfa(Str_token(vA,'|',5));

    // weniger Ist als Plan
    // 80 von 100
    if (vM<=Auf.SL.Menge) then begin
      _SetAbrufInSL(vM, vStk, vGew);
      vM    # 0.0;
      vStk  # Max(vStk - "Auf.SL.Stückzahl",0);
      vGew  # Max(vGew - Auf.SL.Gewicht, 0.0);
    end
    else begin  // mehr Ist als Plan ,130 von 100
      _SetAbrufInSL(Auf.SL.Menge, "Auf.SL.Stückzahl", Auf.SL.Gewicht);
      vM    # vM - Auf.SL.Menge;
      vStk  # Max(vStk - "Auf.SL.Stückzahl",0);
      vGew  # Max(vGew - Auf.SL.Gewicht, 0.0);
    end;

    vA # 'Sum|'+Auf.SL.ArtikelNr+'|';
    vA # vA + anum(vM,3)+ '|';
    vA # vA + aint(vStk)+ '|';
    vA # vA + anum(vGew,3)+ '|';
    TextLineWrite(vTxt, vI, vA, 0);
//debugx('mod '+vA);
  END;

  
  // überige Reste auf letzen SL buchen:
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<TextInfo(vTxt, _textLines)) do begin
    vA # TextLineRead(vTxt, vI,0);
    if (StrCut(vA,1,3)<>'Sum') then CYCLE;
    vM    # cnvfa(Str_token(vA,'|',3));
    vStk  # cnvia(Str_token(vA,'|',4));
    vGew  # cnvfa(Str_token(vA,'|',5));
    if (vM<=0.0) then CYCLE;

    vA # 'Last|'+Str_Token(vA, '|',2)+'|';
    vJ # TextSearch(vTxt, 1, 1, _TextsearchCI, vA);
    if (vJ=0) then CYCLE;
    
    vB # TextLineRead(vTxt, vJ,0);
    Auf.SL.Nummer   # aRa401->Auf.P.Nummer;
    Auf.SL.Position # aRa401->Auf.P.Position;
    Auf.SL.LfdNr    # cnvia(Str_Token(vB,'|',4));
    Erx # RecRead(409,1,0);
    if (Erx>_rok) then CYCLE;
    _SetAbrufInSL(Auf.SL.Prd.Lfs + vM, Auf.SL.Prd.Lfs.Stk + vStk, Auf.SL.Prd.Lfs.Gew + vGew);
  END;
  
//textwrite(vTxt, 'd:\debug\bla.txt',_textExtern);
  TextClose(vTxt);

  RekRestore(v409);
  RETURN true;
end;


//========================================================================
// VerbucheAbruf
//
//========================================================================
sub VerbucheAbruf(aNeu : logic) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vRa401  : int;
  vAb400  : int;
  vAb401  : int;
  vBuf409 : int;
  vAktion : int;
  vNeu    : logic;
  vA      : alpha;
  vTyp    : alpha;
  vmitSL  : logic;
end;
begin

  if (aNeu) then vA # 'Y' else vA # 'N';
  if (RunAFX('Auf.VerbucheAbruf',vA)<>0) then RETURN (Afxres=_rOK);

  vRa401 # RekSave(401);
  vRa401->Auf.P.Nummer    # Auf.P.AbrufAufNr;
  vRa401->Auf.P.Position  # Auf.P.AbrufAufPos;
  RecRead(vRa401,1,0);
  vMitSL # RecLinkInfo(409, vRa401, 15, _Reccount)>0;


  RecLink(100,400,1,_RecFirst);     // Kunde holen
  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);

  // Aktion prüfen...
  if (Auf.PAbrufYN) then
    vTyp  # c_Akt_PAbruf
  else
    vTyp  # c_Akt_Abruf;
  RecBufClear(404);
  Auf.A.Aktionstyp    # vTyp;
  Auf.A.Aktionsnr     # Auf.P.Nummer;
  Auf.A.Aktionspos    # Auf.P.Position;
  Auf.A.Aktionspos2   # 0;

  vAb400 # RekSave(400);
  vAb401 # RekSave(401);

  vNeu # aNeu;
  if (aNeu=n) then begin
    Erx # RecRead(404,2,0);
    if (Erx=_rLocked) then begin
      RecBufDestroy(vRa401);
      RecBufDestroy(vAb400);
      RecBufDestroy(vAb401);
      RETURN false;
    end;
    if (Erx>_rMultikey) then begin
      vNeu # y;
      RecBufClear(404);
      Auf.A.Aktionstyp    # vTyp;
      Auf.A.Aktionsnr     # Auf.P.Nummer;
      Auf.A.Aktionspos    # Auf.P.Position;
      Auf.A.Aktionspos2   # Auf.SL.lfdNr;
    end
    else begin
      vAktion # Auf.A.Aktion;

//      if (AAr.ReservierePosYN) then
//11.10.2021        Art_Data:Auftrag(Auf.A.Menge);  AH HOWVFP-Problem!??
      if (Auf_A_Data:Entfernen()=false) then begin
        RecBufDestroy(vRa401);
        RekRestore(vAb400);
        RekRestore(vAb401);
        RETURN false;  // Aktion löschen
      end;
    end;

  end;

  RecBufCopy(vAb401,401);

  // wenn Abruf gelöscht OHNE jegliche berechnt, dann als storniert ansehen und nichts verbuchen...
  if ("Auf.P.LÖschmarker"='*') and (Auf.P.Prd.Rech=0.0) then begin
    RecBufDestroy(vRa401);
    RekRestore(vAb400);
    RekRestore(vAb401);
    RETURN true;
  end;


  Auf.A.Menge         # Auf.P.Menge.Wunsch;
  Auf.A.MEH           # Auf.P.MEH.Wunsch;
  "Auf.A.Stückzahl"   # "Auf.P.Stückzahl";
  Auf.A.Gewicht       # Auf.P.Gewicht;
  Auf.A.Nettogewicht  # Auf.P.Gewicht;
  Auf.A.Bemerkung     # ''
  if ("Auf.P.Löschmarker"='*') then begin
    Auf.A.Bemerkung   # Translate('erledigt')+' '+aNum(Auf.P.Prd.Rech,Set.Stellen.Menge)+' '+Auf.P.MEH.Einsatz;
  end;

//  if (AAr.ReservierePosYN) then
//11.10.2021    Art_Data:Auftrag(0.0 - Auf.A.Menge);  AH HOWVFP-Probleme!?

  Auf.A.ArtikelNr     # Auf.P.ArtikelNr;
  if (vNeu) then begin  // neu anlegen...
    Auf.A.Aktionsdatum  # Today;
    Auf.A.TerminStart   # Today;
    Auf.A.TerminEnde    # Today;

    Auf.P.Nummer    # Auf.P.AbrufAufNr;
    Auf.P.Position  # Auf.P.AbrufAufPos;
    Erx # RecRead(401,1,0);
    if (Erx<=_rOK) then
      vOK # (Auf_A_Data:NeuAnlegen()=_rOK)
    else
      vOK # false;
  end
  else begin            // ändern...
    Auf.A.Aktion    # vAktion;
    Auf.P.Nummer    # Auf.P.AbrufAufNr;
    Auf.P.Position  # Auf.P.AbrufAufPos;
    Erx # RecRead(401,1,0);
    if (Erx<=_rOK) then
      vOK # (Auf_A_Data:NeuAnlegen(true)=_rOK)
    else
      vOK # false;
  end;  // Ändern

  if (Set.Auf.AutoDelRahme>0) then begin
    // Markierungen richtig setzen...
    FOR Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecFirst)
    LOOP Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecNext)
    WHILE (Erx<_rLocked) do begin
      RecRead(401,1,_RecLock);
      Pos_BerechneMarker();
      RekReplace(401);
    END;
    RecRead(400,1,_RecLock);
    BerechneMarker();
    RekReplace(400,_recUnlock,'AUTO');
  end;

  RekRestore(vAb400);
  RekRestore(vAb401);
  if (vOK=false) then begin
    RecBufDestroy(vRa401);
    RETURN false;
  end;


  // ABRUF-STÜCKLISTE...
  Erx # RecLink(409,401,15,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    vBuf409 # RekSave(409);

    vAktion # 0;
    // Aktion anlegen
    RecBufClear(404);
    Auf.A.Aktionstyp    # c_Akt_AbrufSL;
    Auf.A.Aktionsnr     # Auf.P.Nummer;
    Auf.A.Aktionspos    # Auf.P.Position;
    Auf.A.Aktionspos2   # Auf.SL.lfdNr;

    vAb400 # RekSave(400);
    vAb401 # RekSave(401);

    vNeu # aNeu;
    if (aNeu=n) then begin
      Erx # RecRead(404,2,0);
      if (Erx=_rLocked) then begin
        RekRestore(vAb400);
        RekRestore(vAb401);
        RETURN false;
      end;
      if (Erx>_rMultikey) then begin
        vNeu # y;
        RecBufClear(404);
        Auf.A.Aktionstyp    # c_Akt_AbrufSL;
        Auf.A.Aktionsnr     # Auf.P.Nummer;
        Auf.A.Aktionspos    # Auf.P.Position;
        Auf.A.Aktionspos2   # Auf.SL.lfdNr;
      end
      else begin
        vAktion # Auf.A.Aktion;

        if (AAr.ReserviereSLYN) then
          Art_Data:Auftrag(Auf.A.Menge);

        if (Auf_A_Data:Entfernen(false)=false) then begin
          RecBufDestroy(vRa401);
          RekRestore(vAb400);
          RekRestore(vAb401);
          RETURN false;  // Aktion löschen
        end;
        RecBufCopy(vAb401,401);
      end;
    end;

    Auf.A.Menge         # vBuf409->Auf.SL.Menge;
    Auf.A.MEH           # vBuf409->Auf.SL.MEH;
    "Auf.A.Stückzahl"   # vBuf409->"Auf.SL.Stückzahl";
    Auf.A.Gewicht       # vBuf409->Auf.SL.Gewicht;
    Auf.A.Nettogewicht  # vBuf409->Auf.SL.Gewicht;

    if (AAr.ReserviereSLYN) then
      Art_Data:Auftrag(0.0 - Auf.A.Menge);

//    if (vNeu) then begin  // neu anlegen...
    if (vAktion=0) or (vNeu) then begin
      Auf.A.Aktionsdatum  # Today;
      Auf.A.TerminStart   # Today;
      Auf.A.TerminEnde    # Today;
      //Aufx.A.Adressnummer  # Adr.Nummer;
      Auf.A.ArtikelNr     # vBuf409->Auf.SL.ArtikelNr;

      Auf.P.Nummer    # Auf.P.AbrufAufNr;
      Auf.P.Position  # Auf.P.AbrufAufPos;
      Erx # RecRead(401,1,0);
      if (Erx<=_rOK) then
        vOK # (Auf_A_Data:NeuAnlegen(n,y)=_rOK)
      else
        vOK # false;
    end
    else begin            // ändern...

      Auf.A.Aktion    # vAktion;
      Auf.P.Nummer    # Auf.P.AbrufAufNr;
      Auf.P.Position  # Auf.P.AbrufAufPos;
      Erx # RecRead(401,1,0);
      if (Erx<=_rOK) then
        vOK # (Auf_A_Data:NeuAnlegen(y,y)=_rOK)
      else
        vOK # false;
    end;  // Ändern

    RekRestore(vAb400);
    RekRestore(vAb401);
    RekRestore(vBuf409);
    if (vOK=false) then begin
      RecBufDestroy(vRa401);
      RETURN false;
    end;

    Erx # RecLink(409,401,15,_recNext);
  END;


//
  if (vMitSL) then begin
    VerteileAbrufeInSL(vRa401,vTyp);
  end;
  
  RecBufDestroy(vRa401);

  RETURN true;

end;


//========================================================================
//  SetKundennr
//
//========================================================================
sub SetKundennr (aNeu : int) : logic;
local begin
  Erx     : int;
  vAlt  : int;
  vBuf  : int;
  vI    : int;
end;
begin
  vBuf # RekSave(401);

/*
  vI   # vI + RecLinkInfo(404,400,15,_recCount); // Aktionen
  if (vI > 0) then begin
    Msg(400019, '', 0, 0, 0);
    RekRestore(vBuf);
    RETURN;
  end;
*/

  if (RecRead(400, 1, _recLock) = _rOk) then begin
    TRANSON;
    vAlt                # Auf.KundenNr;
    Auf.KundenNr        # aNeu;
    RecLink(100, 400, 1, _recFirst);
    Auf.KundenStichwort # Adr.Stichwort;

    FOR  Erx # RecLink(401, 400, 9, _recLock | _recFirst);
    LOOP Erx # RecLink(401, 400, 9, _recLock | _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN

      if (Erx = _rLocked) then begin
        TRANSBRK;
        Msg(450005, AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position), 0, 0, 0);
        RETURN false;
      end;

      Auf.P.Kundennr # Auf.KundenNr;
      Auf.P.KundenSW # Auf.KundenStichwort;
      if (PosReplace(_recUnlock,'AUTO') != _rOk) then begin
        TRANSBRK;
        Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
        RETURN false;
      end;


      // Aktionen ändern
      FOR Erx # RecLink(404,400,15,_recFirst)
      LOOP Erx # RecLink(404,400,15,_recnext)
      WHILE (Erx<=_rLocked) do begin

        if (Auf.A.Aktionstyp<>c_Akt_Druck) and (Auf.A.Aktionstyp<>c_Akt_BA) and (Auf.A.Aktionstyp<>c_Akt_BA_Plan) then begin
          TRANSBRK;
          Msg(400019, '', 0, 0, 0);
          RekRestore(vBuf);
          RETURN false;
        end;

        // Aktion ändern...
        RecRead(404,1,_recLock);
        Auf.A.Adressnummer # Adr.Nummer;
        Erx # RekReplace(404,_recunlock,'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(400019, '', 0, 0, 0);
          RekRestore(vBuf);
          RETURN false;
        end;
      END;

    END;

    // BA-Pos. suchen...
    RecBufClear(702);
    BAG.P.Auftragsnr  # Auf.P.Nummer;
    BAG.P.Auftragspos # Auf.P.Position;
    FOR Erx # RecRead(702,2,0);
    LOOP Erx # RecRead(702,2,_recNext);
    WHILE (Erx<_rNoKey) and (BAG.P.Auftragsnr=Auf.P.Nummer) and (BAG.P.Auftragspos=Auf.P.Position) do begin
      FOR Erx # RekLink(703,702,4,_recFirst)
      LOOP Erx # RekLink(703,702,4,_recnext)
      WHILE (Erx<=_rLocked) do begin
        if (BAG.F.Auftragsnummer<>Auf.P.Nummer) then begin
          if ("BAG.F.ReservFürKunde"=vAlt) then begin
            Erx # RecRead(703,1,_recLock);
            "BAG.F.ReservFürKunde"  # aNeu;
            Erx # RekReplace(703,_recUnLock,'AUTO');
            if (Erx<>_rOK) then begin
              TRANSBRK;
              RekRestore(vBuf);
              Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
              RETURN false;
            end;
          end;
        end;


      END;
    end;

    // BA-Fertigungen suchen...
    RecBufClear(703);
    BAG.F.Auftragsnummer  # Auf.P.Nummer;
    BAG.F.AuftragsPos     # Auf.P.Position;
    FOR Erx # RecRead(703,5,0);
    LOOP Erx # RecRead(703,5,_recNext);
    WHILE (Erx<_rNoKey) and (BAG.F.Auftragsnummer=Auf.P.Nummer) and (BAG.F.Auftragspos=Auf.P.Position) do begin
      if ("BAG.F.ReservFürKunde"=vAlt) then begin
        Erx # RecRead(703,1,_recLock);
        "BAG.F.ReservFürKunde"  # aNeu;
        Erx # RekReplace(703,_recUnLock,'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          RekRestore(vBuf);
          Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
          RETURN false;
        end;
      end;
    END;



    // AufKops speichern
    if (RekReplace(400, _recUnlock,'AUTO') != _rOk) then begin
      TRANSBRK;
      Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
      RETURN false;
    end;
    TRANSOFF;
  end;

  RekRestore(vBuf);
  
  RETURN true;
end;


//========================================================================
//  SetRechnungsempf
//
//========================================================================
sub SetRechnungsempf(aNeu : int; opt aAnschrift : int);
local begin
  vBuf : int;
  vI   : int;
end;
begin

//  vI # vI + RecLinkInfo(404,400,15,_recCount); // Aktionen
  if (aAnschrift=0) then aAnschrift # 1;
  if (RecRead(400, 1, _recLock) = _rOk) then begin
    TRANSON;
    Auf.Rechnungsempf   # aNeu;
    Auf.Rechnungsanschr # aAnschrift;
    if (RekReplace(400, _recUnlock,'AUTO') != _rOk) then begin
      TRANSBRK;
      Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
      RETURN;
    end;
    TRANSOFF;
  end;

end;

//========================================================================
//  SetLieferAdr
//
//========================================================================
sub SetLieferAdr(aNeu : int; opt aAnschrift : int);
local begin
  vBuf : int;
  vI   : int;
end;
begin

//  vI # vI + RecLinkInfo(404,400,15,_recCount); // Aktionen
  if (aAnschrift=0) then aAnschrift # 1;
  if (RecRead(400, 1, _recLock) = _rOk) then begin
    TRANSON;
    Auf.LieferAdresse   # aNeu;
    Auf.Lieferanschrift # aAnschrift;
    if (RekReplace(400, _recUnlock,'AUTO') != _rOk) then begin
      TRANSBRK;
      Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
      RETURN;
    end;
    TRANSOFF;
  end;

end;


//========================================================================
//  SumAufWert
//
//========================================================================
SUB SumAufWert() : float;
local begin
  Erx     : int;
  vBuf401 : int;
  vWert   : float;
  vSum    : float;
end;
begin

  RecLink(814,400,8,_recfirst); // Währung holen
  if ("Auf.WährungFixYN") then
    Wae.VK.Kurs       # "Auf.Währungskurs";
  vBuf401 # RecBufCreate(401);
  Erx # RecLink(vBuf401,400,9,_recFirst);   // positionen loopen
  WHILE (Erx<=_rLocked) do begin

    if (vBuf401->"Auf.P.Löschmarker"='') then begin
      if (Wae.VK.Kurs<>0.0) then
        vWert # Rnd(vBuf401->Auf.P.Gesamtpreis / "Wae.VK.Kurs",2)
      else
        vWert # vBuf401->Auf.P.Gesamtpreis;
      vSum # vSum + vWert
    end;

    Erx # RecLink(vBuf401,400,9,_recNext);
  END;
  RecBufDestroy(vBuf401);

  RETURN vSum;
end;


//========================================================================
//  KreditlimitCheck
//
//========================================================================
SUB KreditLimitCheck(
  aAufWert  : float;
  aDel      : logic;
);
local begin
  vLimit  : float;
end;
begin

  if ("Set.KLP.Auf-Anlage"<>'A') then RETURN;

  // 28.08.2017 AH:
  if (Auf.LiefervertragYN) then
    if ("Set.KLP.ABLV-Druck"<>'A') then RETURN;

//  if (RunAFX('Auf.Kreditlimitcheck',anum(aAufWert,2))<>0) then RETURN;

  // Limit errechnen OHNE DIESEN AUFTRAG...
  if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,'',y, var vLimit, Auf.Nummer)) then begin
  end;

  // Aktionseintrag passen setzen...
  if (Auf_A_Data:SetSperre(0,c_AktBem_Sperre_Kredit, vLimit < aAufWert, aDel)>0) then begin
    RunAFX('Auf.Kreditlimit.Sperrt','');
  end;

end;


//========================================================================
//  FreigabeErrechnen
//
//========================================================================
SUB FreigabeErrechnen(
  aSum  : float;
  aUser : alpha);
local begin
  Erx     : int;
  vBuf404 : int;
  vBuf401 : int;
  vOK     : logic;
end;
begin

  vBuf404 # RekSave(404);
  vBuf401 # RekSave(401);
  // Finale Prüfung auf SPERRE...
//  if (Auf_A_Data:LiesAktion(Auf.Nummer, 0,0, c_Akt_Sperre, Auf.Nummer,0,0)) then begin

  // SPERR-Aktion suchen...
  vOK # y;
  Erx # RecLink(404,400,15,_recFirst);
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (Auf.A.Position<>0) then begin
      Erx # RecLink(401,404,1,_recFirst);   // Position holen
      if (Erx>_rLocked) or ("Auf.P.Löschmarker"='*') then begin
        Erx # RecLink(404,400,15,_recNext);
        CYCLE;
      end;
    end;

    if (Auf.A.Aktionstyp=c_Akt_Sperre) and ("Auf.A.Löschmarker"='') then vOK # n;
    Erx # RecLink(404,400,15,_recNext);
  END;

  if (vOK=false) then begin
//Todo('SPERRE');
    if (Auf.Freigabe.Datum<>0.0.0) then begin
      RecRead(400,1,_recLock);
      Auf.Freigabe.WertW1 # 0.0;
      Auf.Freigabe.User   # aUser;
      Auf.Freigabe.Zeit   # 0:0;
      Auf.Freigabe.Datum  # 0.0.0;
      RekReplace(400,_recUnlock,'AUTO');
    end;
  end
  else begin
//Todo('FREI');
    if (Auf.Freigabe.Datum=0.0.0) then begin
      RecRead(400,1,_recLock);
      Auf.Freigabe.WertW1 # aSum;
      Auf.Freigabe.User   # aUser;
      Auf.Freigabe.Zeit   # now;
      Auf.Freigabe.Datum  # today;
      RekReplace(400,_recUnlock,'AUTO');
    end;
  end;

  RekRestore(vBuf401);
  RekRestore(vBuf404);
end;


//========================================================================
//  SperrPruefung
//
//========================================================================
SUB SperrPruefung(
  aBuf401   : int;
  opt aDel  : logic;
);
local begin
  vBuf401   : int;
  vSum      : float;
  vLimit    : float;
  vBuf404   : int;
  vDel      : logic;
end;
begin

  // NUR Aufträge werden geprüft...
  if (Auf.Vorgangstyp<>c_AUF) then RETURN;

//todo('PRÜFUNG...');
//debugx('ALT:'+anum(aBuf401->Auf.P.Gewicht,0)+'kg '+anum(aBuf401->Auf.P.Einzelpreis,2)+'Eur'+' = '+anum(aBuf401->Auf.P.GesamtPreis,2));
//debugx('NEU:'+anum(Auf.P.Gewicht,0)+'kg '+anum(Auf.P.Einzelpreis,2)+'Eur'+' = '+anum(Auf.P.GesamtPreis,2));

  // Gesamtwert ermitteln...
  vSum # SumAufwert();

  // Kreditlimit................
  if (aBuf401=0) then begin // neuer Auftrag...
    KreditlimitCheck(vSum, aDel);
  end
  else begin                // eine Position verändert...
//debugx('ALT:'+anum(aBuf401->Auf.P.GesamtPreis,2)+' NEU '+anum(Auf.P.GesamtPreis,2));
    // nur Rechnen bei Änderung des Wertes...
    if (aBuf401->Auf.P.GesamtPreis<Auf.P.GesamtPreis) then begin
      KreditlimitCheck(vSum, aDel);
    end;

//    if (aBuf401->Auf.P.Dicke<>Auf.P.Dicke) then begin
//debug(anum(aBuf401->auf.p.dicke,0)+' wurde '+anum(auf.p.dicke,0));
//      Auf_A_Data:SetSperre(Auf.P.Position, 'DICKE', Auf.P.Dicke>2.0);
//    end;
  end;


  // weitere Prüfungen...
  if (aDel) then
    RunAFX('Auf.SperrPruefung',aint(aBuf401)+'|'+anum(vSum,2)+'|Y')
  else
    RunAFX('Auf.SperrPruefung',aint(aBuf401)+'|'+anum(vSum,2)+'|N');

  FreigabeErrechnen(vSum,'AUTO');
end;


//========================================================================
//  ReadLohnBA
//
//========================================================================
Sub ReadLohnBA() : logic;
local begin
  Erx : int;
end;
begin

  RecBufClear(700);
  RecBufClear(702);
  FOR Erx # RecLink(404,401,12,_recFirst);    // Aktionen loopen
  LOOP Erx # RecLink(404,401,12,_recNext)
  WHILE (Erx<=_rLocked) and (BAG.P.Nummer=0) do begin
    if (Auf.A.Aktionstyp=c_Akt_BA) AND ("Auf.A.Löschmarker" = '')then begin
      BAG.P.Nummer    # Auf.A.Aktionsnr;
      BAG.P.Position  # Auf.A.AktionsPos;
      Erx # RecRead(702,1,0);  // BAG holen
      if (Erx>_rLocked) then begin
        RecbufClear(702);
        CYCLE;
      end;
      RekLink(700,702,1,_recFirst);         // BA-Kopf holen
      BREAK;
    end;
  END;

  RETURN (BAG.P.Nummer<>0);
end;


//========================================================================
//  SetKundenMatArtNr
//
//========================================================================
sub SetKundenMatArtNr(
  aAdr      : int;
  aVpgNr    : int;
  aCopyData : logic;
  aArtNr    : alpha) : logic;
local begin
  Erx     : int;
  vBuf : int;
  vI   : int;
end;
begin
//debugx(aint(aAdr)+'/'+aint(aVpgNr));
  Erx # RecRead(401,1,_recLock);
  if (Erx<>_rOK) then RETURN false;

//  Auf.P.Verpacknr       # 0;    2022-12-07  AH
//  Auf.P.VerpackAdrNr    # 0;

  if (aAdr<>0) then begin
    Adr.V.Adressnr  # aAdr;
    Adr.v.lfdNr     # aVpgNr;
    Erx # RecRead(105,1,0);
    if (Erx>_rLocked) then begin
      RecRead(401,1,_recunlock);
      RETURN false;
    end;
    if (aCopyData) then begin
      Auf.P.Verpacknr       # aVpgNr; //    2022-12-07  AH
      Auf.P.VerpackAdrNr    # aAdr;
      if (Verpackung2Auf(false)=false) then begin
        RecRead(401,1,_recunlock);
        RETURN false;
      end;
    end;
    aArtNr  # Adr.V.KundenArtNr;
  end
  else begin
    Auf.P.Verpacknr       # 0;  //    2022-12-07  AH
    Auf.P.VerpackAdrNr    # 0;
  end;

//debugx('Set artNr');
  Auf.P.KundenArtNr     # aArtNr;

  Erx # RekReplace(400,0);    // 2022-10-17 AH
  Erx # PosReplace(_recUnlock,'MAN');

  RETURN (Erx=_rOK);
end;


//========================================================================
//  VererbeKopfReferenzInPos
//========================================================================
sub VererbeKopfReferenzInPos(
  aAlt  : alpha;
  aNeu  : alpha);
local begin
  Erx     : int;
  v401  : int;
end;
begin
  v401 # RekSave(401);

  // Fertige Positionen nochmals durchlaufen!
  FOR Erx # RecLink(401,400,9,_RecFirst)
  LOOP Erx # RecLink(401,400,9,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.P.Best.Nummer=aAlt) then begin
      RecRead(401,1,_RecLock);
      Auf.P.Best.Nummer # aNeu;
      Rekreplace(401);
    end;
  END;

  RekRestore(v401);
  if (Auf.P.Best.Nummer=aAlt) then
    Auf.P.Best.Nummer # aNeu;
end;


//========================================================================
//  VeraenderteLieferadresse
//    + Error
//========================================================================
sub VeraenderteLieferadresse() : logic
local begin
  Erx : int;
end;
begin

  // kein Versandpool?
  if (Set.LFS.mitVersandYN=n) then RETURN true;
  
  TRANSON;
  
  // Versandpool loopen...
  RecBufClear(655);
  VsP.Auftragsnr # Auf.Nummer;
  FOR Erx # RecRead(655,6,0)
  LOOP Erx # RecRead(655,6,_recNext)
  WHILE (erx<_rNorec) and (VsP.Auftragsnr=Auf.Nummer) do begin
    if (VsP.Gewicht.Rest<>VsP.Gewicht.Soll) then CYCLE;  // Schon VERSAND!!?
    if (VsP.Ziel.Adresse<>Auf.Lieferadresse) or (VsP.Ziel.Anschrift<>Auf.Lieferanschrift) then begin
      RecRead(655,1,_RecLock);
      VsP.Ziel.Adresse    # Auf.Lieferadresse;
      VsP.Ziel.Anschrift  # Auf.Lieferanschrift;
      Erx # RekReplace(655);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Error(99,'Versandpoolnr. '+aint(Vsp.Nummer));
        RETURN false;
      end;
    end;
  END;
  
  TRANSOFF;

  RETURN true;
end;


//========================================================================
//========================================================================