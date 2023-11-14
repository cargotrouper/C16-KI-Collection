@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_Data
//                    OHNE E_R_G
//  Info
//
//
//  19.11.2003  AI  Erstellung der Prozedur
//  05.10.2010  AI  Analysewerte anderes in Material übernehmen
//  30.08.2012  ST  PosVerbuchen schreibt bei 209er Artikelnummer zusätzlich uin AufAktion (1326/287)
//  17.12.2012  AI  "VerbucheAbruf" passt Aktionsliste an
//  16.10.2013  AH  Anfragen
//  21.10.2013  ST  Ändern der Artikelnummer auch ohne vorheriger Artikelnummer möglich
//  04.12.2013  AH  Neu:Verpackung2Ein
//  18.12.2013  AH  "AusModArtikel" übernimmt auch RID, RAD usw.
//  18.12.2013  AH  "VerbucheAbruf" Bugfix: Bestellmengen im Artikel
//  18.03.2014  AH  "UpdateMaterial" löscht Mat.MEH, damit diese vom Mat_Data neu gesetzt werden kann
//  10.06.2014  AH  "VerbuchePos" setzt Auf.A.Mengen richtig
//  05.08.2014  AH  NEU: "PosReplace" + "PosInsert"
//  24.11.2014  AH  Fix: Preisberechnug bei ArtMatMix in Material
//  06.02.2015  AH  Art.AbmessString Übernnahme
//  05.11.2015  AH  Fix: "UpdateMaterial" setzt Löschmarker nicht doppelt bzw. zurück
//  14.07.2016  AH  Kopfrabatte werden mit in Position gerechnet
//  11.08.2016  AH  Edit: Bestell-Pos-Löschen entfern alle Material-Reservierungen
//  09.09.2016  AH  "VererbeKopfReferenzInPos"
//  13.12.2016  AH  "Verpackung2Ein" nimmt nur geüfllte Erzeuger
//  29.01.2018  AH  AnalyseErweitert
//  30.05.2018  AH  AFX "Ein.VerbucheAbruf.Post"
//  13.06.2018  AH  Fix: Adr.V.Datum.Bis
//  23.07.2019  AH  Edit: "VerbuchePos" nur noch mit Restmengen an Aufaktion
//  26.07.2019  AH  Fix: Statistikverbuchung
//  31.07.2019  AH  Neu: "Ein2Verpackung"
//  20.01.2020  AH  Neu: Adress-Aufpreise
//  07.04.2021  AH  AFX "Ein.P.Data.RecSave"
//  17.01.2022  AH  Fix: Bestelltes Material ohne Menge (wenn also Restmenge=0), behält den EK-Preis
//  10.05.2022  AH  ERX
//  14.06.2022  AH  Fix: PosVerbuchen (in AufAktion) passiert unabhängig vom Wgr.Datei
//  2022-07-18  AH  "CopyGesamteBestellung"
//  2023-01-03  ST  sub "ausExcel" ausgebaut
//  2023-02-06  AH  Restgewicht in Material primär über Dreisatz; "CopyPosKalkToCurrentMat"
//  2023-02-28  AH  neues Setting für Bestelltermin aus Zusagetermin (Set.Mat.BestTermin)
//  2023-03-17  AH  Kalkulationen HWN
//  2023-06-22  AH  "CopyKPosKalkToCurrentMat" kann MEH "%"
//
//  Subprozeduren
//    SUB PosReplace
//    SUB PosInsert
//
//    SUB CopyPosKalkToCurrentMat
//    sub Verpackung2Ein
//    sub DeleteKommission
//    sub SetWgrDateinr
//    sub FinalAufpreise
//    sub SumGesamtpreis
//    sub SumAufpreise
//    sub FindeEKPreis
//    sub UpdateArtikel
//    sub UpdateMaterial
//    sub Pos_BerechneMarker
//    sub BerechneMarker
//    sub ausExcel
//    sub TauscheLieferant
//    sub VerbucheAbruf
//    sub VerbuchePos
//    SUB ModifyArtikel
//    SUB AusModArtikel
//    SUB Read
//    SUB SumEinWert
//    SUB FreigabeErrechnen
//    SUB SperrPruefung
//    SUB VererbeKopfReferenzInPos
//    SUB Ein2Verpackung
//    SUB CopyGesamteBestellung
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Rights

declare VerbuchePos() : logic
declare SperrPruefung(aBuf501 : int; opt aDel : logic);
declare UpdateMaterial(opt aNurKopfdaten : logic) : logic;

//========================================================================
//  PosReplace
//========================================================================
SUB PosReplace(
  aLock   : int;
  aGrund  : alpha) : int;
local begin
  Erx     : int;
  vModNew : logic;
  v501    : int;
  vM      : float;
  vGew    : float;
  vStk    : int;
end;
begin

  vModNew # (Ein.P.Nummer<>0) and (Ein.P.Nummer<1000000000) and (Ein.P.Aktionsmarker<>'N');

  v501  # RecBufCreate(501);
  if (vModNew) then begin
    v501->Ein.P.Nummer    # Ein.P.Nummer;
    v501->Ein.P.Position  # Ein.P.Position;
    Erx # RecRead(v501,1,0);
    if (Erx>_rLocked) or (v501->Ein.P.Aktionsmarker='N')
    //or ((v501->"Ein.P.Löschmarker"='*') and ("Ein.P.Löschmarker"=''))
    then begin
      RecbufClear(v501);
      v501->"Ein.P.Löschmarker" # "Ein.P.Löschmarker";
    end;
    //RecRead(v501,0,_recId, RecInfo(501,_recID));
  end;
  
  RunAFX('Ein.P.Data.RecSave','EDIT');    // 07.04.2021 AH

  Erx # RekReplace(501, aLock, aGrund);
  if (Erx=_rOK) and (vModNew) then begin
      // 14.06.2022 AH generell HIER zum Auftrag melden:
      if (VerbuchePos()=false) then begin
        Erx # _rnorec;
        Erg # Erx;   // TODOERX
        RETURN Erx;
      end;

      Ein_P_Subs:StatistikBuchen(0, v501);

    // 23.07.2019
//debugx("Ein.P.Löschmarker"+anum(Ein.P.FM.Rest,0)+' - '+v501->"Ein.P.Löschmarker"+anum(v501->Ein.P.FM.Rest,0));
    if ((v501->"Ein.P.Löschmarker"='*') and ("Ein.P.Löschmarker"='')) then begin
      vM    # Ein.P.FM.Rest;
      vStk  # Ein.P.FM.Rest.Stk;
    end
    else if ((v501->"Ein.P.Löschmarker"='') and ("Ein.P.Löschmarker"='*')) then begin
      vM    # -Ein.P.FM.Rest;
      vStk  # -Ein.P.FM.Rest.Stk;
    end
    else begin
      vM    # Ein.P.FM.Rest - v501->Ein.P.FM.Rest;
      vStk  # Ein.P.FM.Rest.Stk - v501->Ein.P.FM.Rest.Stk;
//    vGew  # Ein.P.Gewicht - v501->"Ein.P.Gewicht";
    end;
    
    if (vM<>0.0) or (vGew<>0.0) or (vStk<>0) then begin
      if (RunAFX('Ein.P.Replace.Mengenaenderung',anum(vM,3)+'|'+anum(vGew,2)+'|'+aint(vStk))<>0) then begin
        if (AfxRes<>_rOK) then RETURN AfxRes;
      end;
    end;
  end;
  RecBufDestroy(v501);

  Erg # Erx;   // TODOERX
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

  Erx # RekInsert(501, aLock, aGrund);
  if (Erx=_rOK) and (Ein.P.Nummer<>0) and (Ein.P.Nummer<1000000000) and (Ein.P.Aktionsmarker<>'N') then begin
    // 14.06.2022 AH generell HIER zum Auftrag melden:
    if (VerbuchePos()=false) then begin
      Erx # _rnorec;
      RETURN Erx;
    end;

    Ein_P_Subs:StatistikBuchen(0, 0);
  end;

  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


/*========================================================================
2023-02-06  AH
========================================================================*/
sub CopyPosKalkToMat(
  aStk      : int;
  aKG       : float;
  aM        : float;
  aMEH      : alpha;
  aEingang  : int;
  aDat      : date;
//   opt aEKK  : logic; = (aEingang>0)  2023-06-22  AH
) : logic;
local begin
  Erx         : int;
  vMenge      : float;
  vPreis      : float;
  vDatei      : int;
  vKost       : float;
  vKostPro    : float;
  vBasisWert  : float;
  vBasisMenge : float;
  vBasisKG    : float;
end;
begin
  // 2023-06-22 AH
  if (aEingang>0) then begin
    vBasisMenge # Mat.Bestand.Menge;
    vBasisKG    # Mat.Bestand.Gew;
  end
  else begin
    vBasisMenge # Mat.Bestellt.Menge;
    vBasisKG    # Mat.Bestellt.Gew;
    if (vBasisMenge=0.0) and (vBasisKG=0.0) then begin
      vBasisMenge # 1000.0;
      vBasisKG    # Mat.Ratio.MehKg * vBasisMenge;
    end;
  end;

  vBasiswert # Mat.EK.PreisProMEH * vBasisMenge;

  
  if (aEingang=0) then vDatei # 501
  else vDatei # 505;

  // 2023-02-06 AH : ALLE löschen, nicht einzeln
  RecBufClear(204);
  REPEAT
    Mat.A.Materialnr    # Mat.Nummer;
    Mat.A.Aktionstyp    # c_Akt_Kalk;
    Erx # RecRead(204,4,0);
    if (erx>=_rNorec) or (Mat.A.Materialnr<>Mat.Nummer) or (Mat.A.Aktionstyp<>c_Akt_Kalk) then BREAK;
    Erx # Rekdelete(204,0,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  UNTIL (1=2);

//debugx('matek :'+anum(Mat.EK.PReis,2)+'/t   '+anum(Mat.EK.PReisProMEH,2)+'/'+mat.meh);

  FOR Erx # RecLink(505,501,8,_RecFirst)    // Kalkulation loopen
  LOOP Erx # RecLink(505,501,8,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ein.K.MengenbezugYN) and ("Ein.K.RückstellungYN") then begin
      vKost     # 0.0;
      vKostPro  # 0.0;
      Erx # RecLink(100,501,4,_recFirst);   // Lieferant holen
      RecBufClear(204);
      Mat.A.Aktionstyp    # c_Akt_Kalk;
      Mat.A.Aktionsnr     # Ein.K.Nummer;
      Mat.A.Aktionspos    # Ein.K.Position;
      Mat.A.Aktionspos2   # aEingang;
      Mat.A.Aktionspos3   # Ein.K.lfdNr;
      Mat.A.Aktionsmat    # Mat.Nummer;
      Mat.A.Aktionsdatum  # aDat;
      Mat.A.Adressnr      # Adr.Nummer;
      Mat.A.Bemerkung     # Ein.K.Bezeichnung;
      if (Mat.MEH=Ein.K.MEH) then begin
        vKostPro # Ein.K.Preis / Cnvfi(Ein.K.PEH);
        DivOrNull(vKost, (vKostPro * aM * 1000.0), aKG, 2);
        Mat.A.Gewicht   # aKG;
        Mat.A.Menge     # aM;
  //debugx(anum(mat.A.KostenW1,2)+'/t '+anum(Mat.A.KostenW1ProMEH,2)+'/'+ein.k.meh);
      end
      else begin
        if (Ein.K.MEH='%') then begin
// 2023-06-22 AH muss auf BASISPREIS rechnen
//          vKost    # Mat.EK.Preis / Cnvfi(Ein.K.PEH) * Ein.K.Menge;
//          vKostPro # Mat.EK.PreisProMEH / Cnvfi(Ein.K.PEH) * Ein.K.Menge;
          vPreis  # vBasiswert / Cnvfi(Ein.K.PEH) * Ein.K.Menge;
//debugx('basis:'+anum(vbasiswert,2)+' = '+anum(vPreis,2));
          if (vBasisKG<>0.0) then
            vKost   # vPreis / vBasisKG * 1000.0;
          if (vBasisMenge<>0.0) then
          vKostPro # vPreis / vBasisMenge;
        end
        else begin
          vMenge # Lib_Einheiten:WandleMEH(vDatei, aStk, aKG, aM, aMEH, Ein.K.MEH);
  //debugx(Ein.K.Bezeichnung+' = '+anum(vMenge,2)+Ein.k.MEH);
          vPreis # Ein.K.Preis / Cnvfi(Ein.K.PEH) * vMenge;   // ABSOLUT

          // pro KG
          Mat.A.Gewicht # aKG;
          DivOrNull(vKost, vPreis, (aKG/1000.0), 2);
          // pro MEH
          Mat.A.Menge # aM;
          DivOrNull(vKostPro, vPreis, aM, 2);
  //debugx(anum(vPreis,2)+'ABS auf '+anum(vMenge,5)+'t');
        end;
      end;

  // 2023-03-14 AH
  //debugx('kalk :'+anum(vKost,2)+'/t   '+anum(vKostPro,2)+'/'+mat.meh);
      Mat.A.Kosten2W1       # vKost;
      Mat.A.Kosten2W1ProME  # vKostPro;
      Mat.EK.Preis          # Mat.EK.Preis + vKost;
      Mat.EK.PreisProMEH    # Mat.EK.PreisProMEH + vKostPro;
  //debugx('matek :'+anum(Mat.EK.PReis,2)+'/t   '+anum(Mat.EK.PReisProMEH,2)+'/'+mat.meh);
      
      Mat_A_Data:Insert(0,'AUTO');

      // 2023-03-15 AH
      if (aEingang<>0) then begin // 2023-06-22 AH
        if (EKK_Data:Update(505, vBasiswert)=false) then RETURN false;
      end;
    end;
    
  END;
//    if (Mat_A_Data:Vererben()=false) then RETURN false;
    
  RETURN true;
end;


//========================================================================
//  Verpackung2Ein
//
//========================================================================
Sub Verpackung2Ein(aNeuanlage : logic) : logic;
local begin
  Erx         : int;
  vTxtName    : alpha;
  vTxtHdlAsc  : handle;
  vTxtHdlRtf  : handle;
  vTxtName2   : alpha;
end
begin
  Ein.P.Verpacknr       # Adr.V.lfdNr;
  Ein.P.VerpackAdrNr    # Adr.V.Adressnr;
  Ein.P.LieferArtNr     # Adr.V.KundenArtNr;
  Ein.P.VpgText1        # Adr.V.VpgText1;
  Ein.P.VpgText2        # Adr.V.VpgText2;
  Ein.P.VpgText3        # Adr.V.VpgText3;
  Ein.P.VpgText4        # Adr.V.VpgText4;
  Ein.P.VpgText5        # Adr.V.VpgText5;
  Ein.P.VpgText6        # Adr.V.VpgText6;
  Ein.P.Skizzennummer   # Adr.V.Skizzennummer;
  if (Adr.V.Warengruppe<>0) then Ein.P.Warengruppe     # Adr.V.Warengruppe;

  If (Adr.V.PreisW1 <> 0.0) and ("Ein.Währung" =1) and
    ((Adr.V.Datum.Bis=0.0.0) or (Adr.V.Datum.Bis>=Ein.Datum)) then begin
    Ein.P.Grundpreis      # Adr.V.PreisW1;
  end;

  RecLink(819,501,1,_recFirst);   // Warengruppe holen
  if (Wgr_Data:IstMix()=false) then begin
    Ein.P.Strukturnr      # Adr.V.Strukturnr;
    $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Strukturnr;
  End
  else begin
    Ein.P.Artikelnr       # Adr.V.Strukturnr;
    $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Artikelnr;
  End;
//edEin.P.LieferMatArtNr_Mat

  //Ein.P.Wgr.Dateinr     # Wgr.Dateinummer;
  Ein_Data:SetWgrDateinr(Wgr.Dateinummer);

  "Ein.P.Güte"          # "Adr.V.Güte";
  "Ein.P.Gütenstufe"    # "Adr.V.Gütenstufe";

  Ein.P.Werkstoffnr     # MQu_data:GetWerkstoffnr("Ein.P.Güte");

  SbrCopy(105,5,501,3);   // Analyse kopieren
  if (Set.LyseErweitertYN) then begin
    Lib_MoreBufs:RecInit(105, y, y);
  end;

  Ein.P.Intrastatnr     # Adr.V.Intrastatnr;
  Ein.P.AusfOben        # Adr.V.AusfOben;
  Ein.P.AusfUnten       # Adr.V.AusfUnten;
  Ein.P.Dicke           # Adr.V.Dicke;
  Ein.P.DickenTol       # Adr.V.DickenTol;
  Ein.P.Breite          # Adr.V.Breite;
  Ein.P.BreitenTol      # Adr.V.BreitenTol;
  "Ein.P.Länge"         # "Adr.V.Länge";
  "Ein.P.LängenTol"     # "Adr.V.LängenTol";
  Ein.P.RID             # Adr.V.RID;
  Ein.P.RIDmax          # Adr.V.RIDmax;
  Ein.P.RAD             # Adr.V.RAD;
  Ein.P.RADmax          # Adr.V.RADmax;
  Ein.P.Zeugnisart      # Adr.V.Zeugnisart;
  if (Adr.V.Erzeuger<>0) then
    Ein.P.Erzeuger      # Adr.V.Erzeuger;
//    RefreshIfm('edEin.P.Erzeuger_Mat',y);

  Ein.P.AbbindungL      # Adr.V.AbbindungL;
  Ein.P.AbbindungQ      # Adr.V.AbbindungQ;
  Ein.P.Zwischenlage    # Adr.V.Zwischenlage;
  Ein.P.Unterlage       # Adr.V.Unterlage;
  Ein.P.Umverpackung    # Adr.V.Umverpackung;
  Ein.P.Wicklung        # Adr.V.Wicklung;
  Ein.P.MitLfEYN        # Adr.V.MitLfEYN;
  Ein.P.StehendYN       # Adr.V.StehendYN;
  Ein.P.LiegendYN       # Adr.V.LiegendYN;
  Ein.P.Nettoabzug      # Adr.V.Nettoabzug;
  "Ein.P.Stapelhöhe"    # "Adr.V.Stapelhöhe";
  Ein.P.StapelhAbzug    # Adr.V.StapelhAbzug;
  Ein.P.RingKgVon       # Adr.V.RingKgVon;
  Ein.P.RingKgBis       # Adr.V.RingKgBis;
  Ein.P.KgmmVon         # Adr.V.KgmmVon;
  Ein.P.KgmmBis         # Adr.V.KgmmBis;
  "Ein.P.StückProVE"      # "Adr.V.StückProVE";
  Ein.P.VEkgMax         # Adr.V.VEkgMax;
  Ein.P.RechtwinkMax    # Adr.V.RechtwinkMax;
  Ein.P.EbenheitMax     # Adr.V.EbenheitMax;
  "Ein.P.SäbeligkeitMax" # "Adr.V.SäbeligkeitMax";
  "Ein.P.SäbelProM"     # "Adr.V.SäbelProM";
  Ein.P.Etikettentyp    # Adr.V.Etikettentyp;
  Ein.P.Verwiegungsart  # Adr.V.Verwiegungsart;

  // Ausführugen löschen & kopieren
  WHILE (RecLink(502,501,12,_recFirst)=_rOK) do
    RekDelete(502,0,'MAN');

  Erx # RecLink(106,105,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Ein.AF.Nummer   # Ein.P.Nummer;
    Ein.AF.Position # Ein.P.Position;
    Ein.AF.Seite    # Adr.V.AF.Seite;
    Ein.AF.lfdNr    # Adr.V.AF.lfdNr;
    Ein.AF.ObfNr    # Adr.V.AF.ObfNr;
    Ein.AF.Bezeichnung  # Adr.V.AF.Bezeichnung;
    Ein.AF.Zusatz   # Adr.V.AF.Zusatz;
    Ein.AF.Bemerkung    # ADr.V.AF.Bemerkung;
    "Ein.AF.Kürzel" # "Adr.V.AF.Kürzel";
    Erx # RekInsert(502,0,'MAN');
    Erx # RecLink(106,105,1,_recNext);
  END;

  // Aupreise löschen & kopieren    20.01.2020 AH
  WHILE (RecLink(503,501,7,_recFirst)=_rOK) do
    RekDelete(503,0,'MAN');

  FOR Erx # RecLink(104,105,9,_recFirst)
  LOOP Erx # RecLink(104,105,9,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecBufClear(503);
    Ein.Z.Nummer      # Ein.P.Nummer;
    Ein.Z.Position    # Ein.P.Position;
    Ein.Z.lfdNr       # Adr.V.Z.lfdNr;
    "Auf.Z.Schlüssel" # "Adr.V.Z.Schlüssel";
    if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
      if (Apl_data:HoleAufpreis("Ein.Z.Schlüssel", FldDateByName('Ein.P.Cust.PreisZum'))=_rNoRec) then CYCLE
    else
      if (Apl_data:HoleAufpreis("Ein.Z.Schlüssel", today)=_rNoRec) then CYCLE;
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
    Ein.Z.Preis           # ApL.L.Preis;
    Ein.Z.Warengruppe     # ApL.L.Warengruppe;
    if (ApL.Aufpreisgruppe=999) then begin
      Ein.Z.Position    # 0;   // Kopfaufpreis
      Ein.Z.LfdNr       # 1;
      REPEAT
        Erx # RekInsert(503,0,'MAN');
        if (Erx<>_rOK) then inc(Ein.Z.LfdNr);
      UNTIL (Erx=_rOK);
    end
    else begin
      RekInsert(503,0,'MAN');
    end;
  END;
  if (Mode=c_modeview) or (Mode=c_modelist) then      // 2022-09-27 AH
    Ein_Data:SumAufpreise(c_Modeedit)
  else
    Ein_Data:SumAufpreise(Mode);
  $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
  $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);
  $lb.Aufpreise->wpcaption # ANum(Ein.P.Aufpreis,2);
  $lb.Aufpreise_Mat->wpcaption # ANum(Ein.P.Aufpreis,2);
  $lb.P.Einzelpreis->wpcaption # ANum(Ein.P.Einzelpreis,2);
  $lb.P.Einzelpreis_Mat->wpcaption # ANum(Ein.P.Einzelpreis,2);
  $lb.Poswert_Mat->wpcaption # ANum(Ein.P.Gesamtpreis,2);


  // Neu bei gefüllter Kundenartikelnummer
  if (Ein.P.LieferArtNr <> '') then begin

    // RTF-Text kopieren...
    vTxtName # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.' +
               CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4);   // 21.07.2015 Länge 7/4
    if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
      vTxtName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01'
    else
      vTxtName2 # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
    TxtCopy(vTxtName, vTxtName2,0);

    Ein.P.TextNr1 # Adr.V.TextNr1;
    Ein.P.TextNr2 # Adr.V.TextNr2;
    if (Ein.P.TextNr1=105) then begin
      vTxtName # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.' +
                 CnvAi(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01';   // 21.07.2015 Länge 7/4
      vTxtHdlAsc # $Ein.P.TextEdit1->wpdbTextBuf;
      TextRead(vTxtHdlAsc, vTxtName,0);

      if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
        vTxtName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
      else
        vTxtName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      // Geänderten Indvidualtext an Position updaten
      $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      Ein.P.TextNr1 # 501;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2b->wpCaptionInt # 0;
      $Ein.P.TextEdit1->wpcustom # vTxtName;
      $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text2->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;
      $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
//        RefreshIfm('Text');
    end;
  end;

  RunAFX('Ein.P.Auswahl.LfMatArtNr','');

  RETURN true;
end;


//========================================================================
// DeleteKommission
//
//========================================================================
sub DeleteKommission() : logic;
local begin
  Erx   : int;
  vOK   : int;
end;
begin
  Erx # RecRead(501, 0, _recID, gZLList->wpDbRecId); // Bestellpos. lesen
  if(Erx > _rLocked) then begin
    Error(200402, '501');
    RETURN false;
  end;

  // nur wenn KEIN Wareneingang...
  FOR Erx # RecLink(506, 501, 14, _recFirst)
  LOOP Erx # RecLink(506, 501, 14, _recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Ein.E.Löschmarker"<>'') then CYCLE;
    if (Ein.E.AusfallYN) then CYCLE;
    if (Ein.E.VsbYN) then CYCLE;
    Error(501004, '');
    RETURN false;
  END;

  TRANSON;

  Erx # RecRead(501, 1, _recLock) // Bestellpos. sperren
  if(Erx <> _rOK) then begin
    TRANSBRK;
    Error(200402, '501');
    RETURN false;
  end;

  Ptd_Main:Memorize(501);

  // Kommission aus Bestellung entfernen
  Ein.P.Kommission      # '';
  Ein.P.KommissionNr    # 0;
  Ein.P.KommissionPos   # 0;
  Ein.P.KommiKunde      # 0;

  Erx # PosReplace(_recUnlock, 'MAN'); // Bestellpos. zurueckspeichern
  if(Erx <> _rOK) then begin
    TRANSBRK;
    Error(200402, '501');
    RETURN false;
  end;

  Ptd_Main:Compare(501);

  if (Ein.P.Materialnr<>0) then begin
    Erx # RecLink(200, 501, 13, _recFirst); // Bestellkarte holen
    if(Erx > _rLocked) then begin
      TRANSBRK;
      Error(200402, '200');
      RETURN false;
    end;

    Erx # RecRead(200, 1, _recLock); // Materialkarte sperren
    if(Erx <> _rOK) then begin
      TRANSBRK;
      Error(200402, '200');
      RETURN false;
    end;

    Ptd_Main:Memorize(200);

    // Kommission aus Bestellkarte entfernen
    Mat.Auftragsnr      # 0;
    Mat.Auftragspos     # 0;
    Mat.Kommission      # '';
    Mat.KommKundenSWort # '';
    Mat.KommKundennr    # 0;

    /*  MS nicht verwendbar da Funktion Status auf FREI setzt
    Erx # Mat_Data:SetKommission(Mat.Nummer, 0, 0,'MAN');
    if(Erx <> _rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
    */

    Erx # RekReplace(200, _recUnlock, 'MAN'); // Bestellpos. zurueckspeichern
    if(Erx <> _rOK) then begin
      TRANSBRK;
      Error(200402, '200');
      RETURN false;
    end;
    Ptd_Main:Compare(200);
  end;

  Auf.A.Aktionstyp  # c_Akt_Bestellung;
  Auf.A.Aktionsnr   # Ein.P.Nummer;
  Auf.A.Aktionspos  # Ein.P.Position;
  Erx # RecRead(404,2,0);
  if (Erx <= _rMultikey) then begin
//    TRANSBRK;
//    Error(200402, '404');
//    RETURN false;
//  end;
    if (Auf_A_Data:Entfernen(false) = false) then begin
      TRANSBRK;
      Error(200402, '404');
      RETURN false;
    end;
  end;


  // 03.04.2017 AH: bisherige VSB-Karten entkommissionieren...
  FOR Erx # RecLink(506, 501, 14, _recFirst)
  LOOP Erx # RecLink(506, 501, 14, _recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Ein.E.Löschmarker"<>'') then CYCLE;
    if (Ein.E.VsbYN) then begin
      Erx # RecRead(506,1,_RecLock);
      Ein.E.Kommission  # '';
      if (RekReplace(506)<>_rOK) then begin
        TRANSBRK;
        Error(200402, '506');
        RETURN false;
      end;
      if (Ein.E.Materialnr<>0) then begin
        Erx # RecLink(200,506,8,_Recfirst|_RecLock);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Error(200402, '200');
          RETURN false;
        end;
        Mat.Kommission  # '';
        Mat.Auftragsnr  # 0;
        Mat.Auftragspos # 0;
        Erx # Mat_Data:Replace(_recunlock,'MAN');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Error(200402, '200');
          RETURN false;
        end;
      end;
    end;
  END;

  TRANSOFF;

  gMdi -> WinUpdate();

  RETURN true;
end;


//========================================================================
// SetWgrDateinr
//
//========================================================================
sub SetWgrDateinr(aNr : int; opt aNoVis : logic;);
local begin
  Erx : int;
end;
begin

  if (aNoVis=false) and (Mode<>c_modeview) and (Mode<>c_modeList) then begin
    // Materialtyp unterscheiden...
    Lib_GuiCom:able($edEin.P.RID_Mat,         !(Wgr_Data:WertBlockenBeiTyp(501, 'RID')));
    Lib_GuiCom:able($edEin.P.RIDMax_Mat,      !(Wgr_Data:WertBlockenBeiTyp(501, 'RID')));
    Lib_GuiCom:able($edEin.P.RAD_Mat,         !(Wgr_Data:WertBlockenBeiTyp(501, 'RAD')));
    Lib_GuiCom:able($edEin.P.RADMax_Mat,      !(Wgr_Data:WertBlockenBeiTyp(501, 'RAD')));
    Lib_GuiCom:able($edEin.P.Dicke_Mat,       !(Wgr_Data:WertBlockenBeiTyp(501, 'D')));
    Lib_GuiCom:able($edEin.P.Dickentol_Mat,   !(Wgr_Data:WertBlockenBeiTyp(501, 'D')));
    Lib_GuiCom:able($edEin.P.Breite_Mat,      !(Wgr_Data:WertBlockenBeiTyp(501, 'B')));
    Lib_GuiCom:able($edEin.P.Breitentol_Mat,  !(Wgr_Data:WertBlockenBeiTyp(501, 'B')));
    Lib_GuiCom:able($edEin.P.Laenge_Mat,      !(Wgr_Data:WertBlockenBeiTyp(501, 'L')));
    Lib_GuiCom:able($edEin.P.Laengentol_Mat,  !(Wgr_Data:WertBlockenBeiTyp(501, 'L')));
  end;

  Ein.P.Wgr.Dateinr # aNr;
  if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
    if (Ein.P.Artikelnr<>'') then begin
      Erx # RecLink(250,501,2,_RecFirst); // Artikel holen
      if (Erx=_rOK) and ("Art.ChargenführungYN") then Ein.P.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Ein.P.Wgr.Dateinr);
    end;
  end;

  if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) then begin
    Ein.P.MEH          # 'kg';
    Ein.P.MEH.Wunsch   # 'kg';
  end;

end;


//========================================================================
// FinalAufpreise
//
//========================================================================
sub FinalAufpreise(
  aWert       : float;
  aPosMenge   : float;
  aMEH        : alpha;
  aPosStk     : int;
  aPosGew     : float) : float;
local begin
  Erx             : int;
  vMenge          : float;
  vPosNetto       : float;
  vPosNettoRabBar : float;
  vWert           : float;
  vX              : float;
end;
begin
  vPosNettoRabBar # aWert;
  vPosNetto       # aWert;

  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') then begin

      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(501, aPosStk, aPosGew, aPosMenge, aMEH, Ein.Z.MEH)
      vX # Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;
      vWert # vWert + vX;

//debug('P:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));

    end;
  END;

  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
    if (Ein.Z.MengenbezugYN=n) then begin

      if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,501);

      if (Ein.Z.Menge<>0.0) then begin

        vX # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

        vPosNetto # vPosNetto + vX;
        if (Ein.Z.RabattierbarYN) then
          vPosNettoRabBar # vPosNettoRabBar + vX;
        vWert # vWert + vX;
//debug('P:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
      end;
    end;
  END;


  // Aufpreise: %
  // Aufpreise: %
  // Aufpreise: %
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') then begin

      Ein.Z.Preis # vPosNettoRabBar;
      Ein.Z.PEH   # 100;
      vX # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;

      vWert  # vWert + vX;
//debug('P:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
    end;
  END;

/*** ???
  if (gFile=500) or (gFile=501) then begin

    if (Ein.Z.Menge<>0.0) then begin
      Ein.Z.Preis # vPosNettoRabBar;
      Ein.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      vWert  # vWert + Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
    end;

    if (Ein.Z.Menge<>0.0) then begin
      Ein.Z.Preis # vPosNettoRabBar;
      Ein.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      vWert  # vWert + Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
    end;
  end;
***/

  // KopfAufpreise: MEH-bezogen
  // KopfAufpreise: MEH-Bezogen
  // KopfAufpreise: MEH-Bezogen
  Ein.Z.Nummer    # Ein.P.Nummer;
  Ein.Z.Position  # 0;
  Ein.Z.LfdNr     # 0;
  FOR Erx # RecRead(503,1,0)
  LOOP Erx # RecRead(503,1,_recNext)
  WHILE (Erx<=_rLastRec) and (Ein.Z.Nummer=Ein.P.Nummer) and (Ein.Z.Position=0) do begin
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') then begin
      if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(503, aPosStk, aPosGew, aPosMenge, aMEH, Ein.Z.MEH)
      vX # Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;
      vWert # vWert + vX;
//debug('P:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
    end;
  END;


  // Kopf-Aufpreise: % siet 14.07.2016
  Ein.Z.Nummer    # Ein.P.Nummer;
  Ein.Z.Position  # 0;
  Ein.Z.LfdNr     # 0;
  FOR Erx # RecRead(503,1,0)
  LOOP Erx # RecRead(503,1,_recNext)
  WHILE (Erx<=_rLastRec) and (Ein.Z.Nummer=Ein.P.Nummer) and (Ein.Z.Position=0) do begin
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') then begin
      Ein.Z.Preis # vPosNettoRabBar;
      Ein.Z.PEH   # 100;
      vX # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);
      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;
      vWert  # vWert + vX;
    end;
  END;

  RETURN vWert;
end;


//========================================================================
// SumGesamtpreis
//
//========================================================================
sub SumGesamtpreis(aPosMenge : float; aMEH : alpha; aPosStk : int; aPosGew : float) : float;
local begin
  vMenge          : float;
  vPosNetto       : float;
  vPosNettoRabBar : float;
  vWert           : float;
end;
begin
  vWert # 0.0;
  vMenge # Lib_Einheiten:WandleMEH(501, aPosStk, aPosGew, aPosMenge, aMEH, Ein.P.MEH.Preis);
  if (Ein.P.PEH<>0) then
    vWert # Ein.P.Grundpreis * vMenge / Cnvfi(Ein.P.PEH);

  vWert # vWert + FinalAufpreise(vWert, aPosMenge, aMEH, aPosStk, aPosGew);
  RETURN vWert;
end;


//========================================================================
// SumAufpreise
//
//========================================================================
sub SumAufpreise(aMode : alpha);
local begin
  Erx           : int;
  vAufpreis     : float;
  vAufpreisRab  : float;
  vMenge        : float;
  vRab          : float;
  vEinzel       : float;
  vBuf501       : int;
  vBuf501ori    : int;
  vBuf500       : int;
  vErx          : int;
  vGes          : float;
end
begin
  if (amode='') then aMode # Mode;

  vAufpreis # 0.0;
  vAufpreisRab # 0.0;
  // Kalkulation der Aufpreise
  Erx # RecLink(503,501,7,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') and (Ein.Z.MEH=Ein.P.MEH.Preis) then begin
//      vMenge # Lib_Einheiten:WandleMEH(403, "Ein.P.Stückzahl" , Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.Z.MEH)
//        vMenge # 1.0;
      vRab # Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);
      vRab # Ein.Z.Preis / CnvFI(Ein.Z.PEH) * CnvFI(Ein.P.PEH);
      vAufpreis # vAufpreis + vRab;
      if (Ein.Z.RabattierbarYN) then
        vAufpreisRab # vAufpreisRab + vRab;
    end;
    Erx # RecLink(503,501,7,_RecNext);
  END;
//debug('1:'+cnvaf(vAufpreis)+'    stk:'+cnvai("Ein.p.Stückzahl"));
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') then begin
      vRab # Rnd( (Ein.Z.Menge/100.0) * (Ein.P.Grundpreis+vAufpreisRab),2);
      vAufpreis # vAufpreis + vRab;
      if (Ein.Z.RabattierbarYN=n) then begin
        vAufpreisRab # vAufpreisRab + vRab;
        end;
    end;
  END;

  // Kopf-Aufpreise: % siet 14.07.2016
  Ein.Z.Nummer    # Ein.P.Nummer;
  Ein.Z.Position  # 0;
  Ein.Z.LfdNr     # 0;
  FOR Erx # RecRead(503,1,0)
  LOOP Erx # RecRead(503,1,_recNext)
  WHILE (Erx<=_rLastRec) and (Ein.Z.Nummer=Ein.P.Nummer) and (Ein.Z.Position=0) do begin
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') then begin
      vRab # Rnd( (Ein.Z.Menge/100.0) * (Ein.P.Grundpreis+vAufpreisRab),2);
      vAufpreis # vAufpreis + vRab;
      if (Ein.Z.RabattierbarYN=n) then begin
        vAufpreisRab # vAufpreisRab + vRab;
        end;
    end;
  END;


  //if (Ein.P.Aufpreis=vAufpreis) then RETURN;

  vBuf501 # RekSave(501);
  vBuf500 # RekSave(500);

  if (aMode = c_ModeEdit) then begin

    Erx # RecRead(501,1,_RecLock);  // Satz sperren

    SpeziAFX('VBS','VBS.SumAufpreiseEin','1');
    
    Ein.P.Aufpreis # vAufpreis;     // Aufpreise aktualisieren
    Ein.P.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    vEinzel # Ein.P.Einzelpreis;
    vGes    # Ein.P.Gesamtpreis;
    Erx # PosReplace(_RecUnlock,'MAN');
    if (Erx<>_rOK) then RETURN;
    
    SpeziAFX('VBS','VBS.SumAufpreiseEin','2');

    SperrPruefung(ProtokollBuffer[501]);
    Erx # RecRead(501,1,_RecLock);  // Satz sperren
    RecBufCopy(vBuf501,501,n);
    Erx # RecRead(500,1,_RecLock);  // Satz sperren
    RecBufCopy(vBuf500,500,n);
    Ein.P.Aufpreis    # vAufpreis;
// 18.12.2018    Ein.P.Einzelpreis # vEinzel;
    Ein.P.Einzelpreis # vEinzel;   // 17.07.2020 AH: DOCH !!!
    Ein.P.Gesamtpreis # vGes;

    SpeziAFX('VBS','VBS.SumAufpreiseEin','3');

  end
  else if (aMode = c_ModeSave) then begin

    SpeziAFX('VBS','VBS.SumAufpreiseEin','1');
    
    Ein.P.Aufpreis # vAufpreis;     // Aufpreise aktualisieren
    Ein.P.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    vEinzel # Ein.P.Einzelpreis;
    vGes    # Ein.P.Gesamtpreis;
   
    SpeziAFX('VBS','VBS.SumAufpreiseEin','2');

    Ein.P.Aufpreis    # vAufpreis;
    Ein.P.Gesamtpreis # vGes;

    SpeziAFX('VBS','VBS.SumAufpreiseEin','3');

  end
  else if (aMode = c_ModeNew2) then begin

    Ein.P.Aufpreis # vAufpreis;     // Aufpreise aktualisieren
    Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);

  end
    // Falls Benutzer NICHT im NEW-Modus, speichern (für EDIT gesperrt)
  else if (aMode = c_ModeView) or (aMode=c_ModeList) then begin
    vErx # RecRead(501,1,_RecLock);  // Satz sperren
    vBuf501ori # RekSave(501);
    Ein.P.Aufpreis # vAufpreis;     // Aufpreise aktualisieren
    Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    if (vErx <= _rLocked) then begin
      Erx # PosReplace(_RecUnlock,'MAN');
      // Materialkarten updaten
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        if (UpdateMaterial()=false) then begin
          RecBufDestroy(vBuf501ori);
          Msg(501200,gTitle,0,0,0);
          RETURN;
        end;
      end;
      SperrPruefung(vBuf501Ori);
      RecBufDestroy(vBuf501ori);
    end;
  end
  else if (aMode = c_ModeList) then begin
    vErx # RecRead(501,0,_RecID | _RecLock,$ZL.EKPositionen->wpDbRecID);
    vBuf501ori # RekSave(501);
    Ein.P.Aufpreis # vAufpreis;
    Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    if (vErx <= _rLocked) then begin
      Erx # PosReplace(_RecUnlock,'MAN');
      // Materialkarten updaten
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        if (UpdateMaterial()=false) then begin
          RecBufDestroy(vBuf501ori);
          Msg(501200,gTitle,0,0,0);
          RETURN;
        end;
      end;
      SperrPruefung(vBuf501ori);
      RecBufDestroy(vBuf501ori);
    end;
  end;

  RecBufDestroy(vBuf500);
  RecBufDestroy(vBuf501);

end;


//========================================================================
// FindeEKPreis
//    versucht zu dem Artikel+Lieferant+Menge einen Preis zu finden
//========================================================================
sub FindeEKPreis();
local begin
  Erx     : int;
  vMenge  : float;
end;
begin

  if ((Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)=false) and (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)=false)) then RETURN;

  Ein.P.Grundpreis # 0.0;
  RecLink(250,501,2,_RecFirst);   // Artikel holen
  RecLink(100,501,4,_RecFirst);   // Lieferant holen

  Erx # RecLink(254,250,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    // Bestellmenge in Preismenge umwandeln
    vMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Art.P.MEH)
    if (Art.P.Adressnr<>Adr.Nummer) or (Art.P.PreisTyp<>'EK') or
      (vMenge<Art.P.AbMenge) then begin
      Erx # RecLink(254,250,6,_RecNext);
      CYCLE;
    end;
    if (Art.P.Datum.Bis<>0.0.0) and
      ((Art.P.Datum.Von>Ein.Datum) or (Art.P.Datum.Bis<Ein.Datum)) then begin
      Erx # RecLink(254,250,6,_RecNext);
      CYCLE;
    end;

    Ein.P.PEH           # Art.P.PEH;
    Ein.P.MEH.Preis     # Art.P.MEH;
    Ein.P.LieferArtNr   # Art.P.AdressArtNr;
    Wae_Umrechnen(Art.P.Preis,"Art.P.Währung",var Ein.P.Grundpreis, "Ein.Währung");
    BREAK;
  END;

end;


//========================================================================
// UpdateBAG
//
//========================================================================
sub UpdateBAG() : logic;
local begin
  Erx : int;
end;
begin

  FOR Erx # RecLink(504,501,15,_recFirst)   // Aktionen loopen...
  LOOP Erx # RecLink(504,501,15,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Ein.A.Löschmarker"='*') then CYCLE;
    if (Ein.A.Aktionstyp<>c_Akt_BA) then CYCLE;

    BAG.P.Nummer    # Ein.A.Aktionsnr;
    BAG.P.Position  # Ein.A.Aktionspos;
    Erx # RecRead(702,1,0);               // BAG-Position holen
    if (Erx<=_rLocked) then begin

      if (BA1_P_Lib:StatusInAnfrage()) and (Ein.Vorgangstyp<>c_Anfrage) then CYCLE;
      if (BA1_P_Lib:StatusInAnfrage()=false) and (Ein.Vorgangstyp=c_Anfrage) then CYCLE;

      RecRead(702,1,_recLock);
      BAG.P.ExternYN      # y;
      BAG.P.ExterneLiefNr # Ein.P.Lieferantennr;
      BAG.P.Plan.StartDat # Ein.P.Termin1Wunsch;
      BAG.P.Plan.EndDat   # Ein.P.Termin2Wunsch;
      BAG.P.Kosten.Wae    # "Ein.Währung";
      BAG.P.Kosten.Fix    # Ein.P.Gesamtpreis;
      BAG.P.Kosten.Pro    # 0.0;
      BAG.P.Kosten.PEH    # Ein.P.PEH;
      BAG.P.Kosten.MEH    # Ein.P.MEH.Preis;
      RekReplace(702);
    end;
  END;

  RETURN true;
end;


//========================================================================
// UpdateArtikel
//                erzeugt bzw. updated die Artikel-Bestellmenge
//========================================================================
sub UpdateArtikel(aAlterRest : float) : logic;
local begin
  Erx     : int;
  vX      : int;
  vNeu    : logic;
end;
begin

  if (EIn.Vorgangstyp<>c_Bestellung) then RETURN true;

  Erx # RecLink(250,501,2,0);
  if (Erx>_rLocked) then RETURN false;
//  if (VerbuchePos()=false) then RETURN false; 14.06.2022 AH hat ja nix mit Artikel zu tun - muss also IMMER laufen!

  RecBufClear(252);
  Art.C.ArtikelNr     # Ein.P.ArtikelNr;
  Art.C.Lieferantennr # Ein.P.Lieferantennr;
  Art.C.Dicke         # Ein.P.Dicke;
  Art.C.Breite        # Ein.P.Breite;
  "Art.C.Länge"       # "Ein.P.Länge";
  Art.C.RID           # Ein.P.RID;
  Art.C.RAD           # Ein.P.RAD;
  if ("Ein.P.Löschmarker"='') then
    RETURN Art_Data:Bestellung(Ein.P.FM.Rest - aAlterRest)

  else
    RETURN Art_Data:Bestellung(-Ein.P.FM.Rest);

end;


//========================================================================
// UpdateMaterial
//                erzeugt bzw. updated die Bestell-Materialkarte
//                UND setzt ggf. Auftragsatkion
//========================================================================
sub UpdateMaterial(opt aNurKopfdaten : logic) : logic;
local begin
  Erx     : int;
  vI      : int;
  vX,vY   : float;
  vWert   : float;
  vPreis  : float;
  vNeu    : logic;
  vOK     : logic;
  vBuf100 : int;
  vRestKG : float;
  vStk    : int;
  vGew    : float;
  vM      : float;
end;
begin

  if (Ein.Nummer<>Ein.P.Nummer) then
    Erx # RecLink(500,501,3,_RecFirst);   // Bestellkopf holen

  if (Ein.Vorgangstyp<>c_Bestellung) then RETURN true;

  // 22.03.2016 AH: Lohn-Bestellung erzeugt KEIN Material
  if (AAr.Nummer<>Ein.P.Auftragsart) then
    Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen
   if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then RETURN true;

  if (Wgr.Nummer<>Ein.P.Warengruppe) then
    Erx # RekLink(819,501,1,0);   // Warengruppe holen
  if ( (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)=false)) then RETURN true;

  // neue Karte ???
  if (Ein.P.Materialnr=0) then begin
    vNeu # y;
    RecBufClear(200);
    Mat.Nummer # Lib_Nummern:ReadNummer('Material');
    if (Mat.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;
    Mat.Ursprung # Mat.Nummer;
    Mat.Anlage.Datum  # sysdate();
    Mat.Anlage.Zeit   # Now;
    Mat.Anlage.User   # gUserName;
  end
  else begin
    // Karte MUSS vorhanden sein
    Erx # Mat_Data:Read(Ein.P.Materialnr, 0,0, true);
    if (Erx<>200) then begin
      Error(210011,AInt(Ein.P.Materialnr));
      RETURN false;
    end;

    // MS 15.09.2009 Karte MUSS jetzt vorhanden sein
    Erx # RecLink(200,501,13,_recLock);   // Bestand versuchen
    if (Erx=_rLocked) then begin
      Error(001000+Erx,Translate('Material')+' '+AInt(Ein.P.Materialnr));
      RETURN false;
    end;

    vNeu # n;

    // bisherige Ausführung löschen
    WHILE (RecLink(201,200,11,_recFirst)<=_rLocked) do begin
      Erx # RekDelete(201,0,'MAN');
      if (Erx<>_rOK) then begin
        RecRead(200,1,_recunlock);
        RETURN false;
      end;
    END;

  end;

  Mat.Warengruppe       # Ein.P.Warengruppe;
  "Mat.Güte"            # "Ein.P.Güte";
  "Mat.Gütenstufe"      # "Ein.P.Gütenstufe";
  Mat.Werkstoffnr       # ''
  "Mat.AusführungOben"  # '';
  "Mat.AusführungUnten" # '';
  Mat.EigenmaterialYN   # y;
  Mat.Dicke             # Ein.P.Dicke;
  if (Ein.P.DickenTol<>'') then Mat.DickenTolYN       # y;
  Mat.DickenTol         # Ein.P.Dickentol;
  Mat.Breite            # Ein.P.Breite;
  if (Ein.P.BreitenTol<>'') then Mat.BreitenTolYN      # y;
  Mat.BreitenTol        # Ein.P.Breitentol;
  "Mat.Länge"           # "Ein.P.Länge";
  if ("Ein.P.LängenTol"<>'') then "Mat.LängenTolYN"    # y;
  "Mat.LängenTol"       # "Ein.P.Längentol";
  Mat.RID               # Ein.P.RID;
  Mat.RAD               # Ein.P.RAD;
  Mat.Dichte            # Wgr_Data:GetDichte(Wgr.Nummer, 501);
  if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then
    Mat.Strukturnr      # Ein.P.Artikelnr;
  else if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) then
    Mat.Strukturnr      # Ein.P.Strukturnr;
  Mat.Intrastatnr       # Ein.P.Intrastatnr;
  "Mat.CO2EinstandProT" # 0.0;
  "Mat.CO2ZuwachsProT"  # 0.0;

//  Mat.Ursprungsland     # Ein.Land;
  vBuf100 # RecBufCreate(100);
  Erx # RecLink(vBuf100,501,11,_recFirst);   // Erzeuger holen
  if (Erx>=_rLocked) then RecBufClear(vBuf100);
  Mat.Ursprungsland     # vBuf100->Adr.LKZ;
  RecBufDestroy(vBuf100);

  Mat.EK.Projektnr      # Ein.P.Projektnummer;
  Mat.Zeugnisart        # Ein.P.Zeugnisart;
  Mat.Kommission        # Ein.P.Kommission;
  Mat.Auftragsnr        # 0;
  Mat.AuftragsPos       # 0;
  Mat.KommKundennr      # Ein.P.KommiKunde;
  Mat.Bestellt.Stk      # Ein.P.FM.Rest.Stk;

// 2023-02-06 AH : NEU
  Mat.Bestellt.Gew        # Lib_Berechnungen:Dreisatz(Ein.P.FM.Rest, Ein.P.Menge, Ein.P.Gewicht);
  if (Mat.Bestellt.Gew=0.0) then
    Mat.Bestellt.Gew      # Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, 'kg');

  if (Mat.Bestellt.Gew=0.0) and (Ein.P.Artikelnr<>'') then begin
    Erx # RekLink(250,501,2,_RecFirst); // Artikel holen
    Mat.Bestellt.Gew    # Lib_Einheiten:WandleMEH(250, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, 'kg');
  end;
  vRestKG # Mat.Bestellt.Gew;
  
//debugx('===' +aint(ein.p.fm.rest.stk)+'stk '+anum(ein.p.fm.rest,0)+ein.p.meh+' '+anum(mat.bestellt.gew,0)+'kg');
//debugx(aint(ein.p.fm.rest.stk)+'Stk   '+anum(ein.p.fm.rest,0)+Ein.P.MEH+' = '+anum(mat.bestellt.gew,0));

  // VORLÄUFIG:
  Mat.Bestellt.Menge    # 0.0;
  Mat.MEH               # '';

  if (Ein.P.Artikelnr<>'') then begin
    Erx # RekLink(250,501,2,_RecFirst); // Artikel holen
    if (Erx<=_rLocked) then begin
      Mat.MEH # Art.MEH;    // 2023-06-19 AH
      if (Ein.P.MEH = Art.MEH) then
        Mat.Bestellt.Menge # Ein.P.Fm.Rest;
    end;
  end;
  if (Mat.MEH='') then begin  // 2023-06-14  AH  wenn OHNE Artikel=> MATERIAL
    Mat.Bestellt.Menge # Ein.P.Gewicht;
    Mat.MEH           # 'kg';
  end;

  Mat_Data:SetLoeschmarker("Ein.P.Löschmarker");

/*** 05.11.2015 ?????
  if (Mat.Bestellt.Stk<=0) and (Mat.Bestellt.Gew<=0.0) then begin
    "Mat.Löschmarker" # '*';
  end
  else begin
    "Mat.Löschmarker" # '';
  end;
***/


// KUZ
/***
  //vPreis # Lib_Einheiten:PreisProT(Ein.P.Einzelpreis, Ein.P.PEH, Ein.P.MEH.Preis,"Ein.P.Stückzahl",Ein.P.Gewicht,Ein.P.Dicke,Ein.P.Breite,"Ein.P.Länge");
  vPreis # Lib_Einheiten:PreisProT(Ein.P.Grundpreis, Ein.P.PEH, Ein.P.MEH.Preis,"Ein.P.Stückzahl",Ein.P.Gewicht,Ein.P.Dicke,Ein.P.Breite,"Ein.P.Länge");
//debug('Basis/t:'+cnvaf(vPreis));
//Mat.Bemerkung1 # 'GP: '+cnvaf(vPreis)+' pro t';

  Ein.P.MEH          # 'kg';
  Ein.P.MEH.Wunsch   # 'kg';
debugx(ein.p.meh+' '+ein.p.meh.wunsch);
  vY # Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, Ein.P.FM.Rest, Ein.P.FM.Rest, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis);
debugx('das sind:'+anum(vY,0)+ein.p.meh.preis);
  vX # Ein.P.Grundpreis * vY / cnvfi(Ein.P.PEH);
//debug('SumBasis:'+cnvaf(vX)+' auf '+cnvaf(vY)+Ein.P.MEH.Preis);
  vX # FinalAufpreise(vX, Ein.P.FM.Rest, Ein.P.FM.Rest.Stk , Ein.P.FM.Rest);
  if (Ein.P.FM.Rest<>0.0) then begin
    vPreis # vPreis + vX / Ein.P.FM.Rest*1000.0;
//Mat.Bemerkung2 # 'APSum: '+cnvaf(vX)+'  =   '+cnvaf(vX / Ein.P.FM.Rest*1000.0)+' pro t';
  end;
***/

  vPreis # Lib_Einheiten:PreisProT(Ein.P.Grundpreis, Ein.P.PEH, Ein.P.MEH.Preis, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, Ein.P.Dicke, Ein.P.Breite, "Ein.P.Länge", "Ein.P.Güte", Ein.P.Artikelnr);
//debugx(anum(vPreis,2));
                                  // Stk, Gew, Menge...
  vY  # Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, vRestKG, Ein.P.FM.Rest, Ein.P.MEH, Ein.P.MEH.Preis);
  vStk # Ein.P.FM.Rest.Stk;
  vGew # vRestKG;
  vM   # Ein.P.FM.Rest;
  if (vY=0.0) then begin        // 2023-06-19 AH
    vStk # "Ein.P.Stückzahl";
    vGew # Ein.P.Gewicht;
    vM   # Ein.P.Menge;
    vY # Lib_Einheiten:WandleMEH(501, vStk, vGew, vM, Ein.P.MEH, Ein.P.MEH.Preis);
  end;
  if (vY=0.0) and (Ein.P.Artikelnr<>'') then begin
    Erx # RekLink(250,501,2,_RecFirst); // Artikel holen
    vY  # Lib_Einheiten:WandleMEH(250, Ein.P.FM.Rest.Stk, vRestKG, Ein.P.FM.Rest, Ein.P.MEH, Ein.P.MEH.Preis);
    vStk # Ein.P.FM.Rest.Stk;
    vGew # vRestKG;
    vM   # Ein.P.FM.Rest;
  end;
  if (Ein.P.PEH=0) then Ein.P.PEH # 1;

  if (vY<>0.0) then // 2023-03-14 AH
    vPreis # Ein.P.Grundpreis * vY / cnvfi(Ein.P.PEH);
//debugx('SumBasis:'+cnvaf(vPreis)+' auf '+cnvaf(vY)+Ein.P.MEH.Preis+'     FAktor:'+anum(vY,3));

// 2023-06-19 AH  vPreis # vPreis + FinalAufpreise(vX, Ein.P.FM.Rest, Ein.P.MEH, Ein.P.FM.Rest.Stk, 0.0);//Ein.P.FM.Rest);
  vPreis # vPreis + FinalAufpreise(vX, vM, Ein.P.MEH, vStk, 0.0);
//  if (Ein.P.FM.Rest<>0.0) then begin
//    vPreis # vPreis + vX / Ein.P.FM.Rest*1000.0;
//Mat.Bemerkung2 # 'APSum: '+cnvaf(vX)+'  =   '+cnvaf(vX / Ein.P.FM.Rest*1000.0)+' pro t';
//  end;
//debugx('finalekpreis:'+anum(vPreis,2));

  Erx # RecLink(814,500,8,_recFirst);   // Währung holen
  if ("Ein.WährungFixYN"=n) then
    "Ein.Währungskurs" # Wae.EK.Kurs;
  if ("Ein.Währungskurs"=0.0) then "Ein.Währungskurs" # 1.0;
  vWert # vPreis / "Ein.Währungskurs";
/* 2023-06-19 AH
  if (Mat.Bestellt.Gew<>0.0) then
    Mat.EK.Preis        # Rnd(vWert / Mat.Bestellt.Gew * 1000.0, 2);
  if (Mat.Bestellt.Menge<>0.0) then
    Mat.EK.PreisProMEH  # Rnd(vWert / Mat.Bestellt.Menge, 2);
dafür : */
  if (vGew<>0.0) then
    Mat.EK.Preis        # Rnd(vWert / vGew * 1000.0, 2);
  if (vM<>0.0) then
    Mat.EK.PreisProMEH  # Rnd(vWert / vM, 2);

//todo('X');

  if (Ein.Freigabe.Datum=0.0.0) then
    Mat_Data:SetStatus(c_Status_Bestellt_sperr)
  else
    Mat_Data:SetStatus(c_Status_Bestellt);
  Mat.Bestellnummer     # AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position);
//  Mat.BestellABNr       # Ein.AB.Nummer;
//  if (Ein.P.AB.Nummer<>'') then
  Mat.BestellABNr       # Ein.P.AB.Nummer;

  Mat.Bestelldatum      # Ein.P.Anlage.Datum;
  Mat.BestellTermin     # Ein.P.Termin1Wunsch;
  // 2023-02-28 AH
  if (Set.Mat.BestTermin=1) and (Ein.P.TerminZusage<>0.0.0) then
    Mat.BestellTermin     # Ein.P.TerminZusage;
  
  Mat.Erzeuger          # Ein.P.Erzeuger;
  Mat.Lieferant         # Ein.P.Lieferantennr;
  Mat.Lageradresse      # Ein.Lieferadresse;
  Mat.Lageranschrift    # Ein.Lieferanschrift;

  Mat.Streckgrenze1     # Ein.P.Streckgrenze1;
  Mat.StreckgrenzeB1    # Ein.P.Streckgrenze2;
  Mat.Zugfestigkeit1    # Ein.P.Zugfestigkeit1;
  Mat.ZugfestigkeitB1   # Ein.P.Zugfestigkeit2;

  Mat.DehnungA1         # Ein.P.DehnungA1;
  Mat.DehnungB1         # Ein.P.DehnungB1;
  if (Set.Mech.Dehnung.Wie=1) then
    Mat.DehnungC1       # Ein.P.DehnungB2;
  if (Set.Mech.Dehnung.Wie=2) then
    Mat.DehnungC1       # Ein.P.DehnungA2;
//  Mat.DehnungA2         # Ein.P.DehnungA2;
//  Mat.DehnungB2         # Ein.P.DehnungB2;
//  Mat.DehnungC2         # Ein.P.DehnungC2;

  Mat.RP02_V1           # Ein.P.DehngrenzeA1;
  Mat.RP02_B1           # Ein.P.DehngrenzeA2
  Mat.RP10_V1           # Ein.P.DehngrenzeB1;
  Mat.RP10_B1           # Ein.P.DehngrenzeB2;
  "Mat.Körnung1"        # "Ein.P.Körnung1";
  "Mat.KörnungB1"       # "Ein.P.Körnung2";
  "Mat.HärteA1"         # "Ein.P.Härte1";
  "Mat.HärteB1"         # "Ein.P.Härte2";
  Mat.RauigkeitA1       # Ein.P.RauigkeitA1;
  Mat.RauigkeitB1       # Ein.P.RauigkeitA2;
  Mat.RauigkeitC1       # Ein.P.RauigkeitB1;
  Mat.RauigkeitD1       # Ein.P.RauigkeitB2;
  Mat.Chemie.C1         # Ein.P.Chemie.C1;
  Mat.Chemie.Si1        # Ein.P.Chemie.Si1;
  Mat.Chemie.Mn1        # Ein.P.Chemie.Mn1;
  Mat.Chemie.P1         # Ein.P.Chemie.P1;
  Mat.Chemie.S1         # Ein.P.Chemie.S1;
  Mat.Chemie.Al1        # Ein.P.Chemie.Al1;
  Mat.Chemie.Cr1        # Ein.P.Chemie.Cr1;
  Mat.Chemie.V1         # Ein.P.Chemie.V1;
  Mat.Chemie.Nb1        # Ein.P.Chemie.Nb1;
  Mat.Chemie.Ti1        # Ein.P.Chemie.Ti1;
  Mat.Chemie.N1         # Ein.P.Chemie.N1;
  Mat.Chemie.Cu1        # Ein.P.Chemie.Cu1;
  Mat.Chemie.Ni1        # Ein.P.Chemie.Ni1;
  Mat.Chemie.Mo1        # Ein.P.Chemie.Mo1;
  Mat.Chemie.B1         # Ein.P.Chemie.B1;
  Mat.Chemie.Frei1.1    # Ein.P.Chemie.Frei1.1;

  Mat.Chemie.C2         # Ein.P.Chemie.C2;
  Mat.Chemie.Si2        # Ein.P.Chemie.Si2;
  Mat.Chemie.Mn2        # Ein.P.Chemie.Mn2;
  Mat.Chemie.P2         # Ein.P.Chemie.P2;
  Mat.Chemie.S2         # Ein.P.Chemie.S2;
  Mat.Chemie.Al2        # Ein.P.Chemie.Al2;
  Mat.Chemie.Cr2        # Ein.P.Chemie.Cr2;
  Mat.Chemie.V2         # Ein.P.Chemie.V2;
  Mat.Chemie.Nb2        # Ein.P.Chemie.Nb2;
  Mat.Chemie.Ti2        # Ein.P.Chemie.Ti2;
  Mat.Chemie.N2         # Ein.P.Chemie.N2;
  Mat.Chemie.Cu2        # Ein.P.Chemie.Cu2;
  Mat.Chemie.Ni2        # Ein.P.Chemie.Ni2;
  Mat.Chemie.Mo2        # Ein.P.Chemie.Mo2;
  Mat.Chemie.B2         # Ein.P.Chemie.B2;
  Mat.Chemie.Frei1.2    # Ein.P.Chemie.Frei1.2;

  Mat.Mech.Sonstiges1   # Ein.P.Mech.Sonstig1;

/***
  // Analyse kopieren
  FOR vI # 1 LOOP vI # vI + 1 WHILE (vI<=46) do begin
    FldDef(200,4,vI, FldFloat(501,3,vI));
  END;
***/

  Mat.Verwiegungsart    # Ein.P.Verwiegungsart;
  Mat.AbbindungL        # Ein.P.AbbindungL;
  Mat.AbbindungQ        # Ein.P.AbbindungQ;
  Mat.Zwischenlage      # Ein.P.Zwischenlage;
  Mat.Unterlage         # Ein.P.Unterlage;
  Mat.Umverpackung      # Ein.P.Umverpackung;
  Mat.Wicklung          # Ein.P.Wicklung;
  if (Ein.P.MitLfEYN) then
    Mat.LfENr # -1
  else
    Mat.LfeNr # 0;
  Mat.StehendYN         # Ein.P.StehendYN;
  Mat.LiegendYN         # Ein.P.LiegendYN;
  Mat.Nettoabzug        # Ein.P.Nettoabzug;
  "Mat.Stapelhöhe"      # "Ein.P.Stapelhöhe";
  "Mat.Stapelhöhenabzug" # "Ein.P.StapelhAbzug";
  Mat.Ratio.MehKg       # 0.0;

  // Ausführung kopieren
  Erx # RecLink(502,501,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    RecBufClear(201);
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.Seite        # Ein.AF.Seite;
    Mat.AF.lfdNr        # Ein.AF.lfdNr;
    Mat.AF.ObfNr        # Ein.AF.ObfNr;
    Mat.AF.Bezeichnung  # Ein.AF.Bezeichnung;
    Mat.AF.Zusatz       # Ein.AF.Zusatz;
    Mat.AF.Bemerkung    # Ein.AF.Bemerkung;
    "Mat.AF.Kürzel"     # "Ein.AF.Kürzel";
    Erx # RekInsert(201,_recunlock,'AUTO')
    if (Erx<>_rOK) then begin
      RecRead(200,1,_recunlock);
      RETURN false;
    end;

    Erx # RecLink(502,501,12,_recNext);
  END;

  // ANKER
  RunAFX('Ein.P.UpdateMaterial','');

  // 2023-03-14 AH
  if (CopyPosKalkToMat("Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, 0, 0.0.0)=false) then RETURN false;

  // Material sichern
  if (vNeu) then begin
    Erx # Mat_Data:Insert(_recunlock,'AUTO',Mat.Bestelldatum);
  end
  else begin
    Erx # Mat_Data:Replace(_recunlock,'AUTO');

    // 11.08.2016 AH:
    // ggf. Material-Reservierungen löschen...
    if ("Mat.Löschmarker"='*') then begin
      // Reservierungen loopen...
// 19.07.2017 AH: deaktiviert?
// 18.05.2020 AH: wieder REIN, da NIE gelöschtes Mat. MIT Res. existieren darf!!!
      WHILE (RecLink(203,200,13,_recFirst)<=_rLocked) do begin
        if (Mat_Rsv_Data:Entfernen()=false) then begin
          Error(203007,aint(Mat.R.Reservierungnr)+'|'+aint(Mat.Nummer));
          RETURN false;
        end;
      END;
    end;

  end;
  if (Erx<>_rOK) then RETURN false;

  // 2023-02-06 AH: NEU
//  if (CopyPosKalkToCurrentMat("Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, 0, 0.0.0)=false) then RETURN false;

  // Materialnr. in Bestellposition übergeben
  Ein.P.MaterialNr # Mat.Nummer;

  // hier war mal Auf.Aktionanlage c_Akt_Bestell

//  if (VerbuchePos()=false) then RETURN false;   14.06.2022 AH hat ja nix speziell mit Material zu tun - muss also IMMER laufen!

  RETURN true;
end;


//========================================================================
// Pos_BerechneMarker
//          setzt Positionsmarker anhand der Aktionsmarker
//========================================================================
sub Pos_BerechneMarker();
begin
  if (RecLinkInfo(504,501,15,_RecCount)>0) then
    Ein.P.Aktionsmarker # '!'
  else
    Ein.P.Aktionsmarker # '';

  if (RecLinkInfo(506,501,14,_RecCount)>0) then
    Ein.P.Eingangsmarker # '!'
  else
    Ein.P.Eingangsmarker # '';
end;


//========================================================================
// BerechneMarker
//          setzt Kopfmarker anhand der Positionsmarker
//========================================================================
sub BerechneMarker();
local begin
  Erx   : int;
  vBuf  : int
end
begin
  // Save
  vBuf # RecBufCreate(501);
  RecBufCopy(501,vBuf);

  Ein.Aktionsmarker # '';
  Ein.Eingangsmarker # '';

  Erx # RecLink(501,500,9,_RecFirst);
  WHILE (Erx<=_rLocked) and ((Ein.Aktionsmarker='') or (Ein.Eingangsmarker='')) do begin
    if (Ein.P.Aktionsmarker<>'') then Ein.Aktionsmarker # Ein.P.Aktionsmarker;
    if (Ein.P.Eingangsmarker<>'') then Ein.Eingangsmarker # Ein.P.Eingangsmarker;
    Erx # RecLink(501,500,9,_RecNext);
  END;

  // Restore
  RecBufCopy(vBuf,501);
  RecBufDestroy(vBuf);
end;


//========================================================================
// DeletePos
//        löscht eine Position samt Anhang + Texte
//========================================================================
sub DeletePos();
begin
                                    // Texte ggf. löschen
  if (Ein.P.Nummer<1000000000) then
    TxtDelete('~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero,0,3),0);

                                  // Kalkulation ggf. löschen
  WHILE (RecLink(505,501,8,_recFirst)=_rOk) do begin
    RekDelete(505,0,'AUTO');
  END;
                                  // Aufpreise ggf. löschen
  WHILE (RecLink(503,501,7,_recFirst)=_rOk) do begin
    RekDelete(503,0,'AUTO');
  END;
                                  // Ausführung ggf. löschen
  WHILE (RecLink(502,501,12,_recFirst)=_rOk) do begin
    RekDelete(502,0,'AUTO');
  END;
                                  // Aktionen ggf. löschen
  WHILE (RecLink(504,501,15,_recFirst)=_rOk) do begin
    RekDelete(504,0,'AUTO');
  END;
                                  // Eingägne ggf. löschen
  WHILE (RecLink(506,501,14,_recFirst)=_rOk) do begin
    RekDelete(506,0,'AUTO');
  END;

  RekDelete(501,0,'AUTO');

end;


//========================================================================
// DeleteKopf
//
//========================================================================
sub DeleteKopf();
begin

  // Kopftexte löschen
  if (Ein.Nummer<99999999) then begin
    TxtDelete('~501.'+CnvAI(Ein.nummer,_FmtNumLeadZero|_Fmtnumnogroup,0,8)+'.K',0);
    TxtDelete('~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero|_Fmtnumnogroup,0,8)+'.F',0);
  end;

  // Kopfaufpreise löschen
  WHILE (RecLink(503,500,13,_RecFirst)<=_rLocked) do begin
    RekDelete(503,0,'AUTO');
  END;

  // Position löschen
  WHILE (RecLink(501,500,9,_RecFirst)<=_rLocked) do begin
    DeletePos();
  END;

  RekDelete(500,0,'AUTO');

end;





//========================================================================
// ausExcel
//    liest Bestellpositionen aus einer CSV Datei ein
//========================================================================
sub ausExcel() : logic;
local begin
  Erx       : int;
  vFileName : alpha;
  vFile     : int;
  vA        : alpha;
  vPos      : int;
end;
begin

//  ST 2023-01-03 Fuinktion Obsolete
  RETURN FALSE;

/*

  vFilename # Lib_FileIO:FileIO(_WINCOMFILEOPEN, gMDI, 'C:\', 'Exceldatei|*.csv');

  if (vFileName='') then RETURN false;

  vFile # FsiOpen(vFilename,_FsiAcsR|_FsiDenyNone);
  if (vFile=0) then RETURN false;

  // Kopfzeile einlesen
  vFile->FsiMark(10);
  vFile->FsiRead(vA);

  // Position vorbereiten
  vPos # 1;
  RecBufClear(501);
  Ein.P.Nummer        # Ein.Nummer;
  Ein.P.Lieferantennr # Ein.Lieferantennr;
  Ein.P.LieferantenSW # Ein.LieferantenSW;
  Ein.P.MEH.Preis     # 'kg';
  Ein.P.MEH.Wunsch    # 'kg';
  Ein.P.MEH           # 'kg';
  Ein.P.PEH           # 1000;
  Ein.P.Warengruppe   # 1;//Set.Ein.Warengruppe;
  Ein.P.Auftragsart   # Set.Ein.Auftragsart;
  Ein.P.Termin1W.Art  # Set.Ein.TerminArt;
  Ein.P.Termin1Wunsch # today;

  vFile->FsiMark(StrToChar(';',1));
  WHILE (vFile->FsiRead(vA)>0) do begin

    Ein.P.Dicke # CnvFA(vA);
    vFile->FsiRead(vA); Ein.P.Breite      # CnvFA(vA);
    vFile->FsiRead(vA); "Ein.P.Länge"     # CnvFA(vA);
    vFile->FsiRead(vA); "Ein.P.Güte"      # vA;
    MQU_Data:Autokorrektur(var "Ein.P.Güte");
    Ein.P.Werkstoffnr # MQu.Werkstoffnr;
    vFile->FsiRead(vA); "Ein.P.Stückzahl" # CnvIA(vA);
    vFile->FsiRead(vA); "Ein.P.Gewicht"   # CnvFA(vA);
    vFile->FsiMark(13);
    vFile->FsiRead(vA); Ein.P.Bemerkung   # vA;
    vFile->FsiRead(vA,1);
    vFile->FsiMark(StrToChar(';',1));

    Ein.P.Menge         # Ein.P.Gewicht;
    Ein.P.Menge.Wunsch  # Ein.P.Gewicht;

    Ein.P.Position      # vPos;
    vPos # vPos + 1;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      FsiClose(vFile);
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

  END;

  FsiClose(vFile);
*/
  RETURN true;

end;


//========================================================================
// TauscheLieferant
//
//========================================================================
sub TauscheLieferant() : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vBuf501 : int;
end
begin

  vBuf501 # RekSave(501);

  vOK # y;
  Erx # RecLink(500,501,3,_recFirst); // Kopf holen
  Erx # RecLink(501,500,9,_recFirst); // 1.Pos holen
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (Ein.P.FM.VSB<>0.0) or (Ein.P.FM.Ausfall<>0.0) or
      (Ein.P.FM.Eingang<>0.0) then vOK # n;
    Erx # RecLink(501,500,9,_recNext);
  END;

  RekRestore(vBuf501);
  if (vOK=n) then begin
    Msg(501002,'',0,0,0);
    RETURN false;
  end;

  Msg(501003,'',0,0,0);

  RecBufClear(100);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusTauscheLieferant');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;


//========================================================================
//  AusTauscheLieferant
//
//========================================================================
sub AusTauscheLieferant()
local begin
  Erx     : int;
  vBuf501 : int;
end
begin

  if (gSelected=0) then RETURN;

  RecRead(100,0,_RecId,gSelected);
  gSelected # 0;

  Erx # RecLink(500,501,3,_recFirst); // Kopf holen
  if (Ein.Lieferantennr=Adr.Lieferantennr) then RETURN;

  TRANSON;

  Erx # RecRead(500,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(1000+Erx,gTitle,0,0,0);
    RETURN;
  end;
  Ein.Lieferantennr # Adr.Lieferantennr;
  Ein.LieferantenSW # Adr.Stichwort;

  vBuf501 # RekSave(501);
  FOR Erx # RecLink(501,500,9,_recFirst)  // 1.Pos holen
  LOOP Erx # RecLink(501,500,9,_recNext)
  WHILE (Erx=_rOK) do begin
    RecRead(501,1,_recLock);
    Ein.P.Lieferantennr # Ein.Lieferantennr;
    Ein.P.LieferantenSW # Ein.LieferantenSW;
    Erx # PosReplace(_recUnlock,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(1000+Erx,gTitle,0,0,0);
      RekRestore(vBuf501);
      RETURN;
    end;

    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      // Materialkarten anlegen
      if (UpdateMaterial()=false) then begin
        TRANSBRK;
        ErrorOutput;
        Msg(501200,gTitle,0,0,0);
        RekRestore(vBuf501);
        RETURN;
      end;
    end;

      // Lohnbestellung...
    if (AAr.Nummer<>Ein.P.Auftragsart) then
      Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen
    if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then
      Ein_Data:UpdateBAG();

  END;    // Positionen

  if (Erx=_rLocked) then begin
    TRANSBRK;
    Msg(1000+Erx,'',0,0,0);
    RekRestore(vBuf501);
    RETURN;
  end;

  // AufKops speichern
  if (RekReplace(500, _recUnlock,'AUTO') != _rOk) then begin
    TRANSBRK;
    Msg(999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0);
    RETURN;
  end;

  TRANSOFF;

  RekRestore(vBuf501);

  Msg(999998,'',0,0,0);
end;


//========================================================================
// VerbucheAbruf
//
//========================================================================
sub VerbucheAbruf(
  aNeu          : logic;
  opt aRemove   : logic;    // 2023-06-05 AH
  ) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vBuf500 : int;
  vBuf501 : int;
  vAktion : int;
  vNeu    : logic;
  vA      : alpha;
  vRest   : float;
end;
begin

  if (Ein.Vorgangstyp<>c_Bestellung) then RETURN true;

  if (aNeu) then vA # 'Y' else vA # 'N';
  if (RunAFX('Ein.VerbucheAbruf',vA)<>0) then RETURN (AfxRes=_rOK);

  RekLink(100,500,1,_RecFirst);     // Lieferanten holen

  // Aktion prüfen...
  RecBufClear(504);
  Ein.A.Aktionstyp    # c_Akt_Abruf;
  Ein.A.Aktionsnr     # Ein.P.Nummer;
  Ein.A.Aktionspos    # Ein.P.Position;
  Ein.A.Nummer        # Ein.P.AbrufAufNr;   // 2023-06-02 AH
  Ein.A.Position      # Ein.P.AbrufAufPos;  // 2023-06-02 AH
  vBuf500 # RekSave(500);
  vBuf501 # RekSave(501);

  vNeu # aNeu;
  if (aNeu=n) then begin
//  2023-06-02  AH   Erx # RecRead(504,2,0);
    Erx # RecRead(504,5,0);
//debugx('KEY501 KEY504 '+aint(ERX));
    if (Erx=_rLocked) then begin
      RecBufDestroy(vBuf500);
      RecBufDestroy(vBuf501);
      RETURN false;
    end;
    if (Erx>_rMultikey) then begin
      vNeu # y;
      RecBufClear(504);
      Ein.A.Aktionstyp    # c_Akt_Abruf;
      Ein.A.Aktionsnr     # Ein.P.Nummer;
      Ein.A.Aktionspos    # Ein.P.Position;
    end
    else begin
      vAktion # Ein.A.Aktion;
      Erx # RecLink(501,504,1,_recFirst);   // Position holen
      vRest # Ein.A.Menge;
      if (Ein_A_Data:Entfernen()=false) then begin
        RekRestore(vBuf500);
        RekRestore(vBuf501);
        RETURN false;  // Aktion löschen
      end;
    end;
  end;

  // wenn Abruf gelöscht OHNE jegliche Lieferung, dann als storniert ansehen und nichts verbuchen...
  if (vBuf501->"Ein.P.LÖschmarker"='*') and (vBuf501->Ein.P.FM.Ausfall=0.0) and
    (vBuf501->Ein.P.FM.Eingang=0.0) and (vBuf501->Ein.P.FM.VSB=0.0) then begin

    vRest # Ein.P.FM.Rest - vBuf501->Ein.P.FM.Rest;
    // Karte updaten
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      vOK # UpdateMaterial();
    end
    else if ((Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr))) then begin
      // Artikelbestellung anlegen
      vOK # UpdateArtikel(vRest);
    end;

    RekRestore(vBuf500);
    RekRestore(vBuf501);
    RETURN vOK;
  end;

  RecBufCopy(vBuf501,501);

  // 2023-06-05 AH
  if (aRemove) then begin
    RekRestore(vBuf500);
    RekRestore(vBuf501);
    RETURN true;
  end;


  Ein.A.Menge         # Ein.P.Menge.Wunsch;
  Ein.A.MEH           # Ein.P.MEH.Wunsch;
  "Ein.A.Stückzahl"   # "Ein.P.Stückzahl";
  Ein.A.Gewicht       # Ein.P.Gewicht;
  
//  Ein.A.Nettogewicht  # Ein.P.Gewicht;    // CHECKEN, Durch Übernahme der Auftragsfunktion: Feld gibt es nicht

  if (vNeu) then begin  // neu anlegen...
    Ein.A.Aktionsdatum  # Today;
    Ein.A.TerminStart   # Today;
    Ein.A.TerminEnde    # Today;
    Ein.A.Adressnummer  # Adr.Nummer;
    Ein.A.ArtikelNr     # Ein.P.ArtikelNr;

    Ein.P.Nummer    # Ein.P.AbrufAufNr;
    Ein.P.Position  # Ein.P.AbrufAufPos;
    Erx # RecRead(501,1,0);
    vRest # Ein.P.FM.Rest;
    if (Erx<=_rOK) then
      vOK # Ein_A_Data:NeuAnlegen()
    else
      vOK # false;
  end
  else begin            // ändern...
    Ein.A.Aktion    # vAktion;
    Ein.P.Nummer    # Ein.P.AbrufAufNr;
    Ein.P.Position  # Ein.P.AbrufAufPos;
    Erx # RecRead(501,1,0);
    vRest # Ein.P.FM.Rest - vRest;
    if (Erx<=_rOK) then
      vOK # Ein_A_Data:NeuAnlegen(y)    // CHECKEN
    else
      vOK # false;
  end;  // Ändern

  if (vOK) then begin
    // Karte updaten
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      UpdateMaterial();
    end
    else if ((Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr))) then begin
      // Artikel updaten
      vOK # UpdateArtikel(vRest);
    end;
    
    if (aNeu) then
      RunAFX('Ein.VerbucheAbruf.Post','Y|'+aint(vBuf501->Ein.P.Nummer)+'/'+aint(vBuf501->Ein.P.Position))
    else
      RunAFX('Ein.VerbucheAbruf.Post','N'+aint(vBuf501->Ein.P.Nummer)+'/'+aint(vBuf501->Ein.P.Position));
  end;

  RekRestore(vBuf500);
  RekRestore(vBuf501);
  if (vOK=false) then RETURN false;

  RETURN true;

end;


//========================================================================
// VerbuchePos
//    23.07.2019  AH: nur noch die RESTMENGEN
//========================================================================
sub VerbuchePos() : logic;
local begin
  Erx   : int;
  vOK   : logic;
  vGew  : float;
  vStk  : int;
  vM    : float;
end;
begin

  if (Ein.Vorgangstyp<>c_Bestellung) then RETURN true;

  // Auftragsaktion ********************************************************
  if ("Ein.P.Löschmarker"='*') then begin
    RecBufClear(404);
    Auf.A.Aktionstyp  # c_Akt_Bestellung;
    Auf.A.Aktionsnr   # Ein.P.Nummer;
    Auf.A.Aktionspos  # Ein.P.Position;
    Erx # RecRead(404,2,0);
    if (Erx<=_rMultikey) then begin
//      RecRead(404,1,_recLock); 09.06.2022 AH
//      "Auf.A.Löschmarker" # '*';
//      RekReplace(404,_recUnlock,'AUTO');
      Auf_A_Data:Entfernen(y);
    end;

  end
  else begin  // Bestellung aktiv --------------------

    //Auf.A.Menge         # Max(Ein.P.Menge, 0.0);
    //"Auf.A.Stückzahl"   # Max("Ein.P.Stückzahl", 0);
    //Auf.A.Gewicht       # Max(Ein.P.Gewicht ,0.0);
    //Auf.A.NettoGewicht  # Max(Ein.P.Gewicht, 0.0);
    vStk # Ein.P.FM.Rest.Stk;
    vGew # Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, 'kg');
    vM   # Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, vGew, Ein.P.FM.Rest, Ein.P.MEH, Auf.P.MEH.Wunsch);

    vOK # n;
    RecBufClear(404);
    Auf.A.Aktionstyp  # c_Akt_Bestellung;
    Auf.A.Aktionsnr   # Ein.P.Nummer;
    Auf.A.Aktionspos  # Ein.P.Position;
    Erx # RecRead(404,2,0);
    if (Erx<=_rMultikey) then begin  // existiert?

      if (Ein.Freigabe.Datum=0.0.0) or
        (Auf.A.Nummer<>Ein.P.KommissionNr) or (Auf.A.Position<>Ein.P.KommissionPos) then begin
        vOK # n;
        if (Auf_A_Data:Entfernen(n)=false) then RETURN false;
      end
      else begin  // Aktion Updaten...
        Erx # RecLink(401,404,1,_recFirst);     // Pos holen
        if (Erx>_rLocked) then RETURN false;

        vOK # y;
/* 09.06.2022 AH
        RecRead(404,1,_recLock);
        "Auf.A.Löschmarker" # '';
        Auf.A.TerminStart   # Ein.P.Termin1Wunsch;
        Auf.A.TerminEnde    # Ein.P.Termin2Wunsch;
        Auf.A.MEH           # Auf.P.MEH.Wunsch; //Ein.P.MEH;
        Auf.A.Bemerkung     # c_AktBem_Bestell;

        Auf.A.Menge         # Max(vM, 0.0);
        "Auf.A.Stückzahl"   # Max(vStk, 0);
        Auf.A.Gewicht       # Max(vGew, 0.0);
        Auf.A.NettoGewicht  # Max(vGew, 0.0);

        Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
        if (Auf.A.MEH.Preis=Auf.A.MEH) then
          Auf.A.Menge.Preis # Auf.A.Menge
        else if (Auf.A.MEH.Preis='Stk') then
          Auf.A.Menge.Preis # cnvfi("Auf.A.Stückzahl")
        else if (Auf.A.MEH.Preis='kg') then
          Auf.A.Menge.Preis # Auf.A.Gewicht
        else if (Auf.A.MEH.Preis='t') then
          Auf.A.Menge.Preis # Auf.A.Gewicht / 1000.0
        else Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

        Auf.A.Dicke         # Ein.P.Dicke;
        Auf.A.Breite        # Ein.P.Breite;
        "Auf.A.Länge"       # "Ein.P.Länge";
*/
//        RekReplace(404,_recUnlock,'AUTO');
        Auf_A_Data:Entfernen();
        Erx # Auf_A_Data:NeuAnlegen(true)
        if (erx<>_rOK) then RETURN false;
      end;
    end;

    // neue AufAkt anlegen ?? --------------------
    if (vOK=n) and
      (Ein.Freigabe.Datum<>0.0.0) and
      (Ein.P.KommissionNr<>0) and (Ein.P.KommissionPos<>0) then begin

      Erx # RecLink(401,501,18,_recFirst);      // AufPos holen
      if (Erx<>_rOK) then RETURN false;

      RecBufClear(404);
      Auf.A.Aktionstyp    # c_Akt_Bestellung;
      Auf.A.Bemerkung     # c_AktBem_Bestell;
      Auf.A.Aktionsnr     # Ein.P.Nummer;
      Auf.A.Aktionspos    # Ein.P.Position;
      Auf.A.Aktionsdatum  # today;

      Auf.A.TerminStart   # Ein.P.Termin1Wunsch;
      Auf.A.TerminEnde    # Ein.P.Termin2Wunsch;

      Auf.A.MEH           # Auf.P.MEH.Einsatz;// Ein.P.MEH;
      Auf.A.Menge         # Max(vM, 0.0);
      "Auf.A.Stückzahl"   # Max(vStk, 0);
      Auf.A.Gewicht       # Max(vGew, 0.0);
      Auf.A.NettoGewicht  # Max(vGew, 0.0);

      Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
      if (Auf.A.MEH.Preis=Auf.A.MEH) then
        Auf.A.Menge.Preis # Auf.A.Menge
      else if (Auf.A.MEH.Preis='Stk') then
        Auf.A.Menge.Preis # cnvfi("Auf.A.Stückzahl")
      else if (Auf.A.MEH.Preis='kg') then
        Auf.A.Menge.Preis # Auf.A.Gewicht
      else if (Auf.A.MEH.Preis='t') then
        Auf.A.Menge.Preis # Auf.A.Gewicht / 1000.0
      else Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

      Auf.A.MaterialNr    # Ein.P.Materialnr;

      if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) then
        Auf.A.ArtikelNr # Ein.P.Artikelnr;

      Auf.A.Dicke         # Ein.P.Dicke;
      Auf.A.Breite        # Ein.P.Breite;
      "Auf.A.Länge"       # "Ein.P.Länge";
      if (Auf_A_Data:NeuAnlegen()<>_rOK) then RETURN false;
    end;  // neue Aktion anlegen

  end;  // Bestellung aktiv

  RETURN true;
end;


//========================================================================
// ModifyArtikel
//
//========================================================================
sub ModifyArtikel();
begin

  if (Ein.P.FM.VSB>0.0) or (Ein.P.FM.Eingang>0.0) or (Ein.P.FM.Ausfall>0.0) then RETURN;

  // ST 2013-10-21: Artikelnummer auch "einfügbar" machen Prj. 1304/215
  if ("Ein.P.Löschmarker"='*')
    /* or (Ein.P.Artikelnr='') */ then RETURN;

  RecBufClear(250);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusModArtikel');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusModArtikel
//
//========================================================================
sub AusModArtikel()
local begin
  vAlt    : alpha;
  vNeu    : alpha;
  vMode   : alpha;
  vmitABM : logic;
  vMenge  : float;
end;
begin

  if (gSelected=0) then RETURN;

  RecRead(250,0,_RecId,gSelected);
  gSelected # 0 ;
  vNeu # Art.Nummer;
  if (Ein.P.ArtikelNr=vNeu) then RETURN;


  RecRead(501,1,0);
  if (vAlt <> '') then begin
    if (Msg(401012,vAlt+'|'+vNeu ,_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinidYes) then RETURN;
  end
  else begin
    if (Msg(401024,vNeu ,_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinidYes) then RETURN;
  end;

  RecRead(501,1,0);
  if (Ein.P.FM.VSB>0.0) or (Ein.P.FM.Eingang>0.0) or (Ein.P.FM.Ausfall>0.0) then RETURN;

//  21.10.2013  ST  Ändern der Artikelnummer auch ohne vorheriger Artikelnummer möglich
  /* or (Ein.P.Artikelnr='') */
  if ("Ein.P.Löschmarker"='*')
    then RETURN;


  if (Ein.P.Dicke<>Art.Dicke) or (Ein.P.Breite<>Art.Breite) or ("Ein.P.Länge"<>"Art.Länge") then begin
    if (Msg(401013,'',_WinIcoQuestion, _WinDialogYesNo, 2) = _WinidYes) then vmitABM # true;
  end;

  TRANSON;

  RecRead(501,1,_recLock);
  PtD_Main:Memorize(501);

  vAlt # Ein.P.Artikelnr;

  // ST 2013-10-21: Artikelnummer auch "einfügbar" machen Prj. 1304/215
  if (vAlt <> '') then begin
    // abbuchen...
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
      UpdateArtikel( Ein.P.FM.Rest * 2.0);
    end;
  end;


  Ein.P.ArtikelNr # vNeu;


  if (vmitABM) then begin
    Ein.P.Dicke       # Art.Dicke;
    Ein.P.Breite      # Art.Breite;
    "Ein.P.Länge"     # "Art.Länge";
    Ein.P.Dickentol   # Art.Dickentol;
    Ein.P.Breitentol  # Art.Breitentol;
    "Ein.P.Längentol" # "Art.Längentol";
    Ein.P.RID         # Art.Innendmesser;
    Ein.P.RAD         # Art.Aussendmesser;
    Ein.P.Intrastatnr # Art.Intrastatnr;
    Ein.P.ArtikelSW   # Art.Stichwort;
    Ein.P.Sachnummer  # Art.Sachnummer;
//    Ein.P.ArtikelTyp  # Art.Typ;
    Ein.P.RID         # Art.Innendmesser;
    Ein.P.RAD         # Art.Aussendmesser;
    Ein.P.AbmessString  # Art.Abmessungstring;
  end;
  PosReplace(_recUnlock,'MAN');
  PtD_Main:Compare(501);


  // Sonderfunktion:
  vMode # mode;
  mode # c_ModeEdit;
  if (RunAFX('Ein.P.Data.RecSave','')<>0) then begin
  end;
  mode # vMode;


  // zubuchen...
  if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
    // Materialkarten anlegen
    if (UpdateMaterial()=false) then begin
      TRANSBRK;
      ErrorOutput;
      Msg(501200,gTitle,0,0,0);
      RETURN;
    end;

  end
//  else if (Ein.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Ein.P.Wgr.Dateinr<=c_Wgr_bisArtikel) then begin
  else if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr))) then begin
    // Artikelbestellung anlegen
    if (Ein_Data:UpdateArtikel(0.0)=false) then begin
      TRANSBRK;
      Msg(501250,gTitle,0,0,0);
      RETURN;
    end;
  end;


  // nötige Verbuchungen im Artikel druchführen...
  //VerbucheArt(vAlt, Ein.P.Menge-Ein.P.Prd.LFS, '');

  TRANSOFF;

  Msg(999998,'',0,0,0);

end;


//========================================================================
//  Read
//        liest eine Ein.Position aus dem Bestand ODER Ablage + ggf. Kopf
//========================================================================
sub Read(
  aEinNr    : int;
  aPos      : int;
  aMitKopf  : logic) : int;
local begin
  Erx : int;
end;
begin

  // Bestand?
  Ein.P.Nummer    # aEinNr;
  Ein.P.Position  # aPos;
  Erx # RecRead(501,1,0);
  if (Erx<=_rLocked) then begin
    if (aMitKopf) then RecLink(500,501,3,_recFirst);
    RETURN 501;
  end;

  // Ablage?
  "Ein~P.Nummer"    # aEinNr;
  "Ein~P.Position"  # aPos;
  Erx # RecRead(511,1,0);
  if (Erx<=_rLocked) then begin
    RecBufCopy(511,501);
    if (aMitKopf) then begin
      RecLink(510,511,3,_recFirst);
      RecBufCopy(510,500);
    end;
    RETURN 511;
  end;

  // Nicht da!
  RecBufClear(501);
  if (aMitKopf) then RecBufClear(500);
  RETURN _rNoRec;
end;


//========================================================================
//  SumEinWert
//
//========================================================================
SUB SumEinWert() : float;
local begin
  Erx     : int;
  vBuf501 : int;
  vWert   : float;
  vSum    : float;
end;
begin

  RecLink(814,500,8,_recfirst); // Währung holen
  if ("Ein.WährungFixYN") then
    Wae.EK.Kurs       # "Ein.Währungskurs";
  vBuf501 # RecBufCreate(501);
  Erx # RecLink(vBuf501,500,9,_recFirst);   // positionen loopen
  WHILE (Erx<=_rLocked) do begin

    if (vBuf501->"Ein.P.Löschmarker"='') then begin
      if (Wae.EK.Kurs<>0.0) then
        vWert # Rnd(vBuf501->Ein.P.Gesamtpreis / "Wae.VK.Kurs",2)
      else
        vWert # vBuf501->Ein.P.Gesamtpreis;
      vSum # vSum + vWert
    end;

    Erx # RecLink(vBuf501,500,9,_recNext);
  END;
  RecBufDestroy(vBuf501);

  RETURN vSum;
end;


//========================================================================
//  FreigabeErrechnen
//
//========================================================================
SUB FreigabeErrechnen(
  aSum  : float;
  aUser : alpha);
local begin
  Erx       : int;
  vBuf504   : int;
  vBuf501   : int;
  vOK       : logic;
  vChanged  : logic;
end;
begin

  vBuf504 # RekSave(504);
  vBuf501 # RekSave(501);

  // SPERR-Aktion suchen...
  vOK # y;
  Erx # RecLink(504,500,15,_recFirst);
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (Ein.A.Position<>0) then begin
      Erx # RecLink(501,504,1,_recFirst);   // Position holen
      if (Erx>_rLocked) or ("Ein.P.Löschmarker"='*') then begin
        Erx # RecLink(504,500,15,_recNext);
        CYCLE;
      end;
    end;

    if (Ein.A.Aktionstyp=c_Akt_Sperre) and ("Ein.A.Löschmarker"='') then vOK # n;
    Erx # RecLink(504,500,15,_recNext);
  END;

  if (vOK=false) then begin
    if (Ein.Freigabe.Datum<>0.0.0) then begin
      RecRead(500,1,_recLock);
      Ein.Freigabe.WertW1 # 0.0;
      Ein.Freigabe.User   # aUser;
      Ein.Freigabe.Zeit   # 0:0;
      Ein.Freigabe.Datum  # 0.0.0;
      RekReplace(500,_recUnlock,'AUTO');
      vChanged # y;
    end;
  end
  else begin
    if (Ein.Freigabe.Datum=0.0.0) then begin
      RecRead(500,1,_recLock);
      Ein.Freigabe.WertW1 # aSum;
      Ein.Freigabe.User   # aUser;
      Ein.Freigabe.Zeit   # now;
      Ein.Freigabe.Datum  # today;
      RekReplace(500,_recUnlock,'AUTO');
      vChanged # y;
    end;
  end;

  RekRestore(vBuf504);

  if (vChanged) then begin
    Erx # RecLink(501,500,9,_RecFirst); // Positionen loopen
    WHILE (Erx<=_rLocked) do begin
      UpdateMaterial(n);
      VerbuchePos();
      Erx # RecLink(501,500,9,_RecNext);
    END;
  end;

  RekRestore(vBuf501);

end;


//========================================================================
//  SperrPruefung
//
//========================================================================
SUB SperrPruefung(
  aBuf501   : int;
  opt aDel  : logic;
);
local begin
  vBuf501   : int;
  vSum      : float;
  vLimit    : float;
  vBuf504   : int;
  vDel      : logic;
end;
begin

  if (Ein.Vorgangstyp=c_Anfrage) then RETURN;


  // Gesamtwert ermitteln...
  vSum # SumEinwert();
//todo('GESWERT: '+anum(vSum,2));

  // Kreditlimit................
  if (aBuf501=0) then begin // neuer Auftrag...
//Ein_A_Data:SetSperre(0,c_AktBem_Sperre_Kredit, y, aDel);
    //KreditlimitCheck(vSum, aDel);
  end
  else begin                // eine Position verändert...
    // nur Rechnen bei Änderung des Wertes...
    if (aBuf501->Ein.P.GesamtPreis<Ein.P.GesamtPreis) then begin
//Ein_A_Data:SetSperre(0,c_AktBem_Sperre_Kredit, y, aDel);
      //KreditlimitCheck(vSum, aDel);
    end;
  end;


  // weitere Prüfungen...
  if (aDel) then
    RunAFX('Ein.SperrPruefung',aint(aBuf501)+'|'+anum(vSum,2)+'|Y')
  else
    RunAFX('Ein.SperrPruefung',aint(aBuf501)+'|'+anum(vSum,2)+'|N');

  FreigabeErrechnen(vSum,'AUTO');
end;


//========================================================================
//  VererbeKopfReferenzInPos
//========================================================================
sub VererbeKopfReferenzInPos(
  aAlt  : alpha;
  aNeu  : alpha);
local begin
  Erx     : int;
  v501    : int;
end;
begin
  v501 # RekSave(501);

  // Fertige Positionen nochmals durchlaufen!
  FOR Erx # RecLink(501,500,9,_RecFirst)
  LOOP Erx # RecLink(501,500,9,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.P.AB.Nummer=aAlt) then begin
      RecRead(501,1,_RecLock);
      Ein.P.AB.Nummer # aNeu;
      Rekreplace(501);
      if (Ein.P.Position<>v501->Ein.P.Position) then begin
        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
          // Materialkarten anlegen
          UpdateMaterial(n);
        end;
      end;
    end;
  END;

  RekRestore(v501);
  if (Ein.P.AB.Nummer=aAlt) then
    Ein.P.AB.Nummer # aNeu;
end;


//========================================================================
// Ein2Verpackung
//  generiert eine Verpackungsvorschrift, fuer den Lieferanten der Bestellung
//  mit den Einkaufsdaten
//========================================================================
sub Ein2Verpackung(opt aSilent : logic);
local begin
  Erx           : int;
  vBuf105       : int;
  vTxtNameAdrV  : alpha;
  vTxtNameEin   : alpha;
  vI            : int;
end;
begin
  if (Mode=c_ModeList) then
    RecRead(gFile,0,0,gZLList->wpdbrecid);

  Erx # RecLink(100, 501, 4, _recFirst); // Lieferant Adr. lesen
  if(Erx > _rLocked) then
    RecBufClear(100);

  if (!aSilent) then
    if (Msg(501007, Adr.Stichwort + '|' +  AInt(Ein.P.Nummer) + '/' + AInt(Ein.P.Position), _WinIcoQuestion, _WinDialogYesNo, 2) <> _WinIdYes) then
      RETURN;

  Erx # RekLink(819,501,1,_RecFirst);   // Warengruppe holen

  TRANSON;

  // Hauptdaten
  Adr.V.Adressnr          # Adr.Nummer;
  Adr.V.KundenArtNr       # Ein.P.LieferArtNr;
  Adr.V.VerkaufYN         # true;
  Adr.V.EinkaufYN         # true;

  if (Wgr_data:IstMix()) or (Wgr_Data:IstArt()) then
    Adr.V.Strukturnr        # Ein.P.Artikelnr
  else
    Adr.V.Strukturnr        # Ein.P.Strukturnr;
  Adr.V.VpgText1          # Ein.P.VpgText1;
  Adr.V.VpgText2          # Ein.P.VpgText2;
  Adr.V.VpgText3          # Ein.P.VpgText3;
  Adr.V.VpgText4          # Ein.P.VpgText4;
  Adr.V.VpgText5          # ein.P.VpgText5;
  Adr.V.VpgText6          # Ein.P.VpgText6;
  if ((Adr.V.Datum.Bis=0.0.0) or (Adr.V.Datum.Bis>=Ein.Datum)) then begin
    Adr.V.PreisW1           # Ein.P.Grundpreis;
  end;
  Adr.V.PEH               # Ein.P.PEH;
  Adr.V.MEH               # Ein.P.MEH.Preis;

//  Adr.V.VorlageBAG        # Ein.P.VorlageBAG;
//  Adr.V.EinsatzVPG.Adr    # Ein.P.EinsatzVPG.Adr;
//  Adr.V.EinsatzVPG.Nr     # Ein.P.EinsatzVPG.Nr;

  // Material
  Adr.V.Warengruppe       # Ein.P.Warengruppe;
  "Adr.V.Güte"            # "Ein.P.Güte";
  "Adr.V.Gütenstufe"      # "Ein.P.Gütenstufe";
  Adr.V.Intrastatnr       # Ein.P.Intrastatnr;
  Adr.V.Dicke             # Ein.P.Dicke;
  Adr.V.DickenTol         # Ein.P.Dickentol;
  Adr.V.Breite            # Ein.P.Breite;
  Adr.V.BreitenTol        # Ein.P.Breitentol;
  "Adr.V.Länge"           # "Ein.P.Länge";
  "Adr.V.LängenTol"       # "Ein.P.Längentol";
  Adr.V.RID               # Ein.P.RID;
  Adr.V.RIDmax            # Ein.P.RIDMax;
  Adr.V.RAD               # Ein.P.RAD;
  Adr.V.RADmax            # Ein.P.RADMax;
  Adr.V.Zeugnisart        # Ein.P.Zeugnisart;
  Adr.V.Erzeuger          # Ein.P.Erzeuger;
//  Ein.P.VorlageBAG        # Adr.V.VorlageBAG;
//  Ein.P.EinsatzVPG.Adr    # Adr.V.EinsatzVPG.Adr;
//  Ein.P.EinsatzVPG.Nr     # Adr.V.EinsatzVPG.Nr;

  // Verpackung
  Adr.V.AbbindungL        # Ein.P.AbbindungL;
  Adr.V.AbbindungQ        # Ein.P.AbbindungQ;
  Adr.V.Zwischenlage      # Ein.P.Zwischenlage;
  Adr.V.Unterlage         # Ein.P.Unterlage;
  Adr.V.MitLfEYN          # Ein.P.MitLfEYN;
  Adr.V.StehendYN         # Ein.P.StehendYN;
  Adr.V.LiegendYN         # Ein.P.LiegendYN;
  Adr.V.Nettoabzug        # Ein.P.Nettoabzug;
  "Adr.V.Stapelhöhe"      # "Ein.P.Stapelhöhe";
  Adr.V.StapelhAbzug      # Ein.P.StapelhAbzug;
  Adr.V.RingKgVon         # Ein.P.RingKgVon;
  Adr.V.RingKgBis         # Ein.P.RingKgBis;
  Adr.V.KgmmVon           # Ein.P.KgmmVon;
  Adr.V.KgmmBis           # Ein.P.KgmmBis;
  "Adr.V.StückProVE"      # "Ein.P.StückProVE";
  Adr.V.VEkgMax           # Ein.P.VEkgMax;
  Adr.V.RechtwinkMax      # Ein.P.RechtwinkMax;
  Adr.V.EbenheitMax       # Ein.P.EbenheitMax;
  "Adr.V.SäbeligkeitMax"  # "Ein.P.SäbeligkeitMax";
  "Adr.V.SäbelProM"       # "Ein.P.SäbelProM";
  Adr.V.Etikettentyp      # Ein.P.Etikettentyp;
  Adr.V.Verwiegungsart    # Ein.P.Verwiegungsart;
  Adr.V.Skizzennummer     # Ein.P.Skizzennummer;
  Adr.V.Umverpackung      # Ein.P.Umverpackung;
  Adr.V.Wicklung          # Ein.P.Wicklung;

  // Analyse
  Adr.V.Streckgrenze1     # Ein.P.Streckgrenze1;
  Adr.V.Streckgrenze2     # Ein.P.Streckgrenze2;
  Adr.V.Zugfestigkeit1    # Ein.P.Zugfestigkeit1;
  Adr.V.Zugfestigkeit2    # Ein.P.Zugfestigkeit2;
  Adr.V.DehnungA1         # Ein.P.DehnungA1;
  Adr.V.DehnungA2         # Ein.P.DehnungA2;
  Adr.V.DehnungB1         # Ein.P.DehnungB1;
  Adr.V.DehnungB2         # Ein.P.DehnungB2;
  Adr.V.DehngrenzeA1      # Ein.P.DehngrenzeA1;
  Adr.V.DehngrenzeA2      # Ein.P.DehngrenzeA2;
  Adr.V.DehngrenzeB1      # Ein.P.DehngrenzeB1;
  Adr.V.DehngrenzeB2      # Ein.P.DehngrenzeB2;
  "Adr.V.Körnung1"        # "Ein.P.Körnung1";
  "Adr.V.Körnung2"        # "Ein.P.Körnung2";
  Adr.V.Chemie.C1         # Ein.P.Chemie.C1;
  Adr.V.Chemie.C2         # Ein.P.Chemie.C2;
  Adr.V.Chemie.Si1        # Ein.P.Chemie.Si1;
  Adr.V.Chemie.Si2        # Ein.P.Chemie.Si2;
  Adr.V.Chemie.Mn1        # Ein.P.Chemie.Mn1;
  Adr.V.Chemie.Mn2        # Ein.P.Chemie.Mn2;
  Adr.V.Chemie.P1         # Ein.P.Chemie.P1;
  Adr.V.Chemie.P2         # Ein.P.Chemie.P2;
  Adr.V.Chemie.S1         # Ein.P.Chemie.S1;
  Adr.V.Chemie.S2         # Ein.P.Chemie.S2;
  Adr.V.Chemie.Al1        # Ein.P.Chemie.Al1;
  Adr.V.Chemie.Al2        # Ein.P.Chemie.Al2;
  Adr.V.Chemie.Cr1        # Ein.P.Chemie.Cr1;
  Adr.V.Chemie.Cr2        # Ein.P.Chemie.Cr2;
  Adr.V.Chemie.V1         # Ein.P.Chemie.V1;
  Adr.V.Chemie.V2         # Ein.P.Chemie.V2;
  Adr.V.Chemie.Nb1        # Ein.P.Chemie.Nb1;
  Adr.V.Chemie.Nb2        # Ein.P.Chemie.Nb2;
  Adr.V.Chemie.Ti1        # Ein.P.Chemie.Ti1;
  Adr.V.Chemie.Ti2        # Ein.P.Chemie.Ti2;
  Adr.V.Chemie.N1         # Ein.P.Chemie.N1;
  Adr.V.Chemie.N2         # Ein.P.Chemie.N2;
  Adr.V.Chemie.Cu1        # Ein.P.Chemie.Cu1;
  Adr.V.Chemie.Cu2        # Ein.P.Chemie.Cu2;
  Adr.V.Chemie.Ni1        # Ein.P.Chemie.Ni1;
  Adr.V.Chemie.Ni2        # Ein.P.Chemie.Ni2;
  Adr.V.Chemie.Mo1        # Ein.P.Chemie.Mo1;
  Adr.V.Chemie.Mo2        # Ein.P.Chemie.Mo2;
  Adr.V.Chemie.B1         # Ein.P.Chemie.B1;
  Adr.V.Chemie.B2         # Ein.P.Chemie.B2;
  "Adr.V.Härte1"          # "Ein.P.Härte1";
  "Adr.V.Härte2"          # "Ein.P.Härte2";
  Adr.V.Chemie.Frei1.1    # Ein.P.Chemie.Frei1.1;
  Adr.V.Chemie.Frei1.2    # Ein.P.Chemie.Frei1.2;
  Adr.V.Mech.Sonstig1     # Ein.P.Mech.Sonstig1;
  Adr.V.RauigkeitA1       # Ein.P.RauigkeitA1;
  Adr.V.RauigkeitA2       # Ein.P.RauigkeitA2;
  Adr.V.RauigkeitB1       # Ein.P.RauigkeitB1;
  Adr.V.RauigkeitB2       # Ein.P.RauigkeitB2;


  vBuf105 # RecBufCreate(105);
  // letzte Verpackung der Adresse lesen
  Erx # RecLink(vBuf105, 100, 33,_recLast);
  if(Erx > _rLocked) then
    RecBufClear(vBuf105);
  ADr.V.LfdNr # vBuf105 -> ADr.V.LfdNr + 1;
  RecBufDestroy(vBuf105);

  // Ausführung kopieren
  FOR Erx # RecLink(502, 501, 12, _recFirst);
  LOOP Erx # RecLink(502, 501, 12, _recNext);
  WHILE (Erx <= _rLocked) do begin
    Adr.V.AF.AdressNr  # Adr.V.Adressnr;
    Adr.V.AF.Verpacknr # ADr.V.LfdNr;

    Adr.V.AF.Seite        # Ein.AF.Seite;
    Adr.V.AF.ObfNr        # Ein.AF.ObfNr;
    Adr.V.AF.Bezeichnung  # Ein.AF.Bezeichnung;
    Adr.V.AF.Zusatz       # Ein.AF.Zusatz;
    Adr.V.AF.Bemerkung    # Ein.AF.Bemerkung;
    "Adr.V.AF.Kürzel"     # "Ein.AF.Kürzel";

    REPEAT
      Erx # RekInsert(106,0,'AUTO');
      if (Erx <> _rOK) then
        Adr.V.AF.lfdNr # Adr.V.AF.lfdNr + 1;
    UNTIL (Erx = _rOK);
  END;

  Adr.V.AusfOben # Obf_Data:BildeAFString(105, '1');
  Adr.V.AusfUnten # Obf_Data:BildeAFString(105, '2');

  if (Ein.P.TextNr1 = 0) then begin  // Standardtext
   Adr.V.TextNr1 # 0;
   Adr.V.TextNr2 # Ein.P.TextNr2;
  end;
  if (Ein.P.TextNr1 = 500) then begin // anderer Positionstext
    Adr.V.TextNr1 # 105;
    Adr.V.TextNr2 # 0;
  end;
  if (Ein.P.TextNr1 = 501) then begin // Idividuell
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
    Lib_MoreBufs:CopyNew(231, '', 501, 105);
  end;

  // RTF-Text kopieren...
  vTxtNameAdrV  # '';
  vTxtNameEin   # '';
  vTxtNameAdrV # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.'
             + cnvAI(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4);   // 21.07.2015 Länge 7/4

  if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
    vTxtNameEin # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
  else
    vTxtNameEin  # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'
                 + cnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
  TxtCopy(vTxtNameEin, vTxtNameAdrV, 0);

  // Text kopieren...
  vTxtNameAdrV  # '';
  vTxtNameEin   # '';
  vTxtNameAdrV # '~105.'+ CnvAI(Adr.V.Adressnr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+ '.'
               + cnvAI(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4) + '.01';   // 21.07.2015 Länge 7/4
  if (Ein.P.TextNr1 = 0) then begin  // Standardtext
  end;
  if (Ein.P.TextNr1 = 500) then begin // anderer Positionstext

    if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
      vTxtNameEin # myTmpText+'.501.'+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vTxtNameEin # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  end;
  if (Ein.P.TextNr1 = 501) then begin // Idividuell
    if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
      vTxtNameEin # myTmpText+'.501.'+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vTxtNameEin # '~401.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  end;

  if (Adr.V.TextNr1 = 105) then
    TxtCopy(vTxtNameEin, vTxtNameAdrV, 0);

  // Aufpreise kopieren   20.01.2020 AH
  vI # 1;
  FOR Erx # RecLink(503,501,7,_recFirst)
  LOOP Erx # RecLink(503,501,7,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Strcut("Ein.Z.Schlüssel",1,1)='#') then begin
      RecBufClear(104);
      Adr.V.Z.Adressnr    # Adr.V.Adressnr;
      Adr.V.Z.VpgNr       # Adr.V.lfdNr;
      "Adr.V.Z.Schlüssel" # "Ein.Z.Schlüssel";
      Adr.V.Z.lfdNr       # vI;
      RekInsert(104);
      inc(vI);
    end;
  END;


  // Verpackungsnr. in Auftrag übernehmen
  RecRead(501,1,_recLock);
  Ein.P.Verpacknr       # Adr.V.lfdNr;
  Ein.P.VerpackAdrNr    # Adr.V.Adressnr;
  PosReplace(_recUnlock,'AUTO');

  TRANSOFF;

  if (!aSilent) then Msg(999998, '', 0, 0, 0);
end;


//========================================================================
//  SetLieferantenMatArtNr
//
//========================================================================
sub SetLieferantenMatArtNr(
  aAdr      : int;
  aVpgNr    : int;
  aCopyData : logic;
  aArtNr    : alpha) : logic;
local begin
  Erx   : int;
  vBuf  : int;
  vI    : int;
end;
begin
  Erx # RecRead(501,1,_recLock);
  if (Erx<>_rOK) then RETURN false;

//  Ein.P.Verpacknr       # 0;    2022-12-07  AH
//  Ein.P.VerpackAdrNr    # 0;

  if (aAdr<>0) then begin
    Adr.V.Adressnr  # aAdr;
    Adr.v.lfdNr     # aVpgNr;
    Erx # RecRead(105,1,0);
    if (Erx>_rLocked) then RETURN false;
    if (aCopyData) then begin
      Ein.P.Verpacknr       # aVpgNr; //    2022-12-07  AH
      Ein.P.VerpackAdrNr    # aAdr;
      if (Verpackung2Ein(false)=false) then begin
        RecRead(501,1,_recunlock);
        RETURN false;
      end;
    end;

    aArtNr  # Adr.V.KundenArtNr;
  end
  else begin
    Ein.P.Verpacknr       # 0;  //    2022-12-07  AH
    Ein.P.VerpackAdrNr    # 0;
  end;
  Ein.P.LieferArtNr   # aArtNr;

  Erx # PosReplace(_recUnlock,'MAN');
  RETURN (Erx=_rOK);
end;


/*========================================================================
2022-07-18  AH
    kopiert eine Bestellung samt Kopf und aller Positionen
========================================================================*/
sub CopyGesamteBestellung()
local begin
  Erx   : int;
  vHdl  : int;
end;
begin
  if (Mode<>c_Modelist) then RETURN;
  if (Rechte[Rgt_EK_P_Anlegen]=n) then RETURN;
  
  Erx # RecLink(500,501,3,_recFirst);     // Kopf holen

  // Kopf/Fusstext kopieren
  TextCopy('~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F', myTmpText+'.501.F', 0);
  TextCopy('~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K', myTmpText+'.501.K', 0);


  FOR Erx # RecLink(501,500,9,_recFirst)  // Positionen loopen
  LOOP Erx # RecLink(501,500,9,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // PostText kopieren
    if (Ein.P.TextNr1=501) then begin // Idividuell
      TxtCopy('~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3), myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3), 0);
    end
    else if (Ein.P.TextNr1=500) then begin // anderer dieser Bestellung
      TxtCopy('~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3), myTmpText+'.501.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3), 0);
    end;

    // Individuellen Text kopieren
    TxtCopy('~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01', myTmpText+ '.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01',0);
                              // Kalkulation kopieren
    FOR Erx # RecLink(505,501,8,_recFirst)
    LOOP Erx # RecLink(505,501,8,_recNext)
    WHILE (erx<=_rLocked) do begin
      Ein.K.Nummer    # myTmpNummer;
      Erx # RekInsert(505,_recUnlock,'MAN');
      Ein.K.Nummer    # Ein.P.Nummer;
      RecRead(505,1,0);
    END;

                              // Aufpreise kopieren
    FOR Erx # RecLink(503,501,7,_recFirst)
    LOOP Erx # RecLink(503,501,7,_recNext)
    WHILE (erx<=_rLocked) do begin
      Ein.Z.Nummer    # MyTmpNummer;
      Erx # RekInsert(503,_recUnlock,'MAN');
      Ein.Z.Nummer    # Ein.P.Nummer;
      RecRead(503,1,0);
    END;

                              // Ausführungen kopieren
    FOR Erx # RecLink(502,501,12,_recFirst)
    LOOP Erx # RecLink(502,501,12,_recNext)
    WHILE (erx<=_rLocked) do begin
      Ein.AF.Nummer    # MyTmpNummer;
      Erx # RekInsert(502,_recUnlock,'MAN');
      Ein.AF.Nummer    # Ein.P.Nummer;
      RecRead(502,1,0);
    END;


    Ein.P.Nummer          # myTmpNummer;
    "Ein.P.Löschmarker"   # '';
    "Ein.P.Lösch.User"    # '';
    "Ein.P.Lösch.Datum"   # 0.0.0;
    "Ein.P.Lösch.Zeit"    # 0:0;
    Ein.P.Eingangsmarker  # '';
    Ein.P.Erfuellgrad     # 0.0;
    Ein.P.FM.Ausfall      # 0.0;
    Ein.P.FM.Ausfall.Stk  # 0;
    Ein.P.FM.Eingang      # 0.0;
    Ein.P.FM.Eingang.Stk  # 0;
    Ein.P.FM.VSB          # 0.0;
    Ein.P.FM.VSB.Stk      # 0;
    Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
    Ein.P.StorniertYN     # false;
    Ein.P.Anlage.Datum    # today;
    Ein.P.Anlage.User     # gusername;
    Ein.P.Anlage.Zeit     # now;
    RekInsert(501);
    Ein.P.Nummer # Ein.Nummer;
    RecRead(501,1,0);
  END;
  
  Ein.Nummer          # myTmpNummer;
  Ein.Anlage.Datum    # today;
  Ein.Anlage.User     # gusername;
  Ein.Anlage.Zeit     # now;

  Erx # RecLink(501,500,9,_RecFirst); // 2023-01-11 AH

  mode # c_ModeList2;
  vHdl # gMdi->winsearch('NB.Erfassung');
  vHdl->wpdisabled # false;
  vHdl->wpvisible # true;
  vHdl # gMdi->winsearch('NB.Main');
  vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.Erfassung';
//  if (vLeer) then RecBufClear($ZL.Erfassung->wpDbLinkFileNo);
  $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.Erfassung->Winfocusset(true);
  App_Main:Refreshmode();

  RETURN;
end;


//========================================================================