@A+
//===== Business-Control =================================================
//
//  Prozedur    OfP_Data
//                    OHNE E_R_G
//  Info
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  15.09.2008  HB  Berechnung des Skontobetrages hinzugefügt
//  08.12.2008  AI  Korrektur wegen Valuta<->Lieferdatum
//  03.02.2009  ST  Errechnung der Wiedervorlage hinzugefügt
//  16.02.2012  ST  Berechnung der Restesumme hinzugefügt
//  03.05.2012  MS  Read
//  26.11.2012  TM  BuilDZaBString: übergebenen Text aus aufrufender Prozedur vergrößert
//  26.05.2014  AH  Neu: "RecalcAllZahlunen"
//  15.08.2016  AH  Neu: "ReplaceMitLoeschmarker"
//  06.05.2019  ST  Edit: "RecalcAllZahlungen" mit Silentargument
//  06.05.2020  AH  Protokollierung der Löschung
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB BerechneZieldaten ( aLieferDatum : date; opt aGeladen : logic; ) : logic
//    SUB BuildZaBString ( aText : alpha; aSkontoDat : date; aZielDat : date; OPT aSkonto : float; OPT aBrutto : float ) : alpha
//    SUB BerechneWiedervorlage() : date
//    SUB BerechneSummeRest () : float
//    SUB RecalcAllZahlungen()
//    SUB ReplaceMitLoeschmarker(aMark : alpha) : int;
//
//========================================================================
@I:Def_Global

//========================================================================
//  Read  03.05.2012 MS
//        liest einen Offenen Posten aus dem Bestand ODER Ablage !!!
//========================================================================
sub Read(aReNr : int) : int;
local begin
  Erx : int;
end;
begin
  OfP.Rechnungsnr # aReNr; // Bestand?
  Erx # RecRead(460, 1, 0);
  if (Erx<=_rLocked) then RETURN 460;

  "OfP~Rechnungsnr" # aReNr; // Ablage?
  Erx # RecRead(470, 1, 0);
  if (Erx<=_rLocked) then begin
    RecBufCopy(470, 460);
    RETURN 470;
  end;

  RecBufClear(460); // Nicht da!
  RETURN _rNoRec;
end;

//========================================================================
//  SetMahndatum
//
//========================================================================
sub SetMahndatum (aDate : date) : logic
local begin
  Erx : int;
end;
begin
  TRANSON;

  Erx # RecRead(460,1,_recLock);
  if(Erx <> _rOK) then begin
    TRANSBRK;
    Error(001001, '');
    Error(460002, '');
    RETURN false;
  end;

  case OfP.Mahnstufe of
    0 : begin
          OfP.Mahndatum1    # aDate;
        end;

    1 : begin
          OfP.Mahndatum2  # aDate;

        end;

    2 : begin
          OfP.Mahndatum3  # aDate;
        end;

    3 : begin
          OfP.Mahndatum3  # aDate;
        end;
  end;

  Ofp.Mahnstufe   # Ofp.Mahnstufe + 1;
  if (Ofp.Mahnstufe > 3) then
    Ofp.Mahnstufe # 3;

  OfP.Wiedervorlage # OfP_Data:BerechneWiedervorlage();

  Erx # RekReplace(460,_RecUnlock,'AUTO');
  if(Erx <> _rOK) then begin
    TRANSBRK;
    Error(460002, '');
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
// BerechneZieldaten
//                Setzt Zieldatum, Skontodatum, Skontoprozent und
//                Valutadatum in OfP.
//========================================================================
sub BerechneZieldaten (
  aDatum       : date;
  opt aGeladen : logic) : logic
local begin
  vBed  : int;
end;
begin

  if ( aGeladen = false ) and ( RecLink( 816, 460, 8, _recFirst ) > _rLocked ) then
    RETURN false;

  if ( ZaB.IndividuellYN ) then
    RETURN true;

  /* Valutadatum & Zieldatum */
  OfP.Valutadatum # aDatum; //CnvDI( CnvID( aDatum ) + "ZaB.Valutatage" );
  OfP.Zieldatum   # OfP.Valutadatum;

  vBed # 0;
  if ( "ZaB.Sknt1.VonTag" <= OfP.Rechnungsdatum->vpDay ) and ( OfP.Rechnungsdatum->vpDay <= "ZaB.Sknt1.BisTag" ) then
    vBed # 1
  else if ( "ZaB.Sknt2.VonTag" <= OfP.Valutadatum->vpDay ) and ( OfP.Valutadatum->vpDay <= "ZaB.Sknt2.BisTag" ) then
    vBed # 2;
  else vBed # 1;

  // 1. BEDINGUNG--------------------
  if (vBed=1) then begin

    // Zieldatum errechnen...
    if ( "ZaB.Fällig1.Zieltage" > 0 ) then
      OfP.Zieldatum # CnvDI( CnvID( OfP.Zieldatum ) + "ZaB.Fällig1.Zieltage" );
    else if ( "ZaB.Fällig1.FixTag" > 0 ) and ( "ZaB.Fällig1.FixTag" <= 31 ) then begin
      OfP.Zieldatum->vpDay # "ZaB.Fällig1.FixTag";
      OfP.Zieldatum->vmMonthModify( "ZaB.Fällig1.FixMonat" );
    end;

    // Skonto1
    OfP.Skontoprozent # "ZaB.Sknt1.Prozent";

    if ( "ZaB.Sknt1.Tage" > 0 ) then begin
      if ( "ZaB.Sknt1.VorZielYN" = false ) then
        OfP.Skontodatum # CnvDI( CnvID( OfP.Valutadatum ) + "ZaB.Sknt1.Tage" )
      else
        OfP.Skontodatum # CnvDI( CnvID( OfP.Zieldatum ) - "ZaB.Sknt1.Tage" );
    end
    else if ( "ZaB.Sknt1.FixTag" > 0 ) and ( "ZaB.Sknt1.FixTag" <= 31 ) then begin
      OfP.Skontodatum        # OfP.Valutadatum;
      OfP.Skontodatum->vpDay # "ZaB.Sknt1.FixTag";
      OfP.Skontodatum->vmMonthModify( "ZaB.Sknt1.ZielMonat" );
    end;

    RETURN true;

  end; // 1.Bedingung

  // 2. BEDINGUNG--------------------
  // Zieldatum errechnen...
  if ( "ZaB.Fällig2.Zieltage" > 0 ) then
    OfP.Zieldatum # CnvDI( CnvID( OfP.Zieldatum ) + "ZaB.Fällig2.Zieltage" );
  else if ( "ZaB.Fällig2.FixTag" > 0 ) and ( "ZaB.Fällig2.FixTag" <= 31 ) then begin
    OfP.Zieldatum->vpDay # "ZaB.Fällig2.FixTag";
    OfP.Zieldatum->vmMonthModify( "ZaB.Fällig2.FixMonat" );
  end;

  // Skonto2
  OfP.Skontoprozent # ZaB.Sknt2.Prozent;

  if ( "ZaB.Sknt2.Tage" > 0 ) then begin
    if ( "ZaB.Sknt1.VorZielYN" = false ) then
      OfP.Skontodatum # CnvDI( CnvID( OfP.Valutadatum ) + "ZaB.Sknt2.Tage" );
    else
      OfP.Skontodatum # CnvDI( CnvID( OfP.Zieldatum ) - "ZaB.Sknt2.Tage" );
  end
  else if ( "ZaB.Sknt2.FixTag" > 0 ) and ( "ZaB.Sknt2.FixTag" <= 31 ) then begin
    OfP.Skontodatum        # OfP.Valutadatum;
    OfP.Skontodatum->vpDay # "ZaB.Sknt2.FixTag";
    OfP.Skontodatum->vmMonthModify( "ZaB.Sknt2.ZielMonat" );
  end;

  RETURN true;
end;


//========================================================================
// BuildZabString
//
//========================================================================
sub BuildZaBString(
  aText       : alpha(4096);
  aSkontoDat  : date;
  aZielDat    : date;
  OPT aSkonto : float;
  OPT aBrutto : float) : alpha
local begin
  vaD1,vaD2   : alpha;
  vA          : alpha(250);
end;
begin
  if (aSkontoDat<>0.0.0) then vaD1 # cnvad(aSkontoDat);
  if (aZielDat<>0.0.0) then vaD2 # cnvad(aZielDat);

  vA # Str_ReplaceAll(aText, '#1', vaD1);
  vA # Str_ReplaceAll(vA   , '#2', vaD2);
  if (aSkonto <> 0.0) then
    vA # Str_ReplaceAll(vA   , '#3', cnvaf(aBrutto*aSkonto/100.0,_FmtNumNoGroup | _FmtNumNoZero)+ ' '+"Wae.Kürzel");

  if (vaD1<>'') then
    vA # Str_ReplaceAll(vA, '#(1)', '('+vaD1+')');
  else
    vA # Str_ReplaceAll(vA, '#(1)', '');

  if (vaD2<>'') then
    vA # Str_ReplaceAll(vA   , '#(2)', '('+vaD2+')')
  else
    vA # Str_ReplaceAll(vA   , '#(2)', '');

  if (aSkonto <> 0.0) and (StrFind(vA,'#(3)',1) >= 1) then
    vA # Str_ReplaceAll(vA   , '#(3)','('+ cnvaf(aBrutto*aSkonto/100.0,_FmtNumNoGroup | _FmtNumNoZero)+' '+ "Wae.Kürzel"+')')
  else
    vA # Str_ReplaceAll(vA   , '#(3)','');

  RETURN (vA);

end;





//========================================================================
// BerechneWiedervorlage
//    Berechnet die Wiedervorlage aus dem Fälligkeitsdatum und ggf. den
//    Mahndaten
//
//========================================================================
sub BerechneWiedervorlage() : date
local begin
  vWiedervorlage  : date;           // neues Wiedervorlagedatum
end;
begin

  // Folgende Datumswerte sind ausschlaggebend für die Wahl des
  // Wiedervorlagedatums:
  //    1.  Fälligkeit der Rechnung (Zieldatum)
  //    2.  Mahndatum 1
  //    3.  Mahndatum 2

  vWiedervorlage # 00.00.0000;

  // Wiedervorlage bezogen auf Zahlungsziel
  if (OfP.Zieldatum <> 00.00.0000) then
    vWiedervorlage # CnvDi( CnvID(Ofp.Zieldatum) + Set.Fin.MahnTage0);

  // Wiedervorlage nach erster Mahnung
  if (OfP.Mahndatum1 <> 00.00.0000) then
    vWiedervorlage # CnvDi( CnvID(OfP.Mahndatum1) + Set.Fin.MahnTage1);

  // Wiedervorlage nach zweiter Mahnung
  if (OfP.Mahndatum2 <> 00.00.0000) then
    vWiedervorlage # CnvDi( CnvID(OfP.Mahndatum2) + Set.Fin.MahnTage2);

/*
 So ähnlich könnte man es auch lösen
 //OfP.Wiedervorlage->vmDayModify(Set.Fin.MahnTage2);
*/



  // neues Wiedervorlagedatum zurückgeben
  return vWiedervorlage;

end;


//========================================================================
// siehe Doku von Args und Return
//========================================================================
sub BerechneSummeRest (
  var vNetto : float  // analog zum Rückgabewert, aber bzgl. OfP.NettoW1 statt OfP.RestW1
) : float  // Summe der Spaltenwerte in OfP.RestW1 für selektierte bzw. alle offene Posten
local begin
  Erx           : int;
  vRest         : float;
  v460          : int;
  vMarked       : logic;
  vMarkedItem   : int;
  vMFile        : int;
  vMID          : int;
end begin

  vRest # 0.0;
  vNetto # 0.0;
  
  v460 # RekSave(460);

  // Markierung vorhanden?
  // Wenn ja, dann direkt Summieren
  FOR  vMarkedItem # gMarkList->CteRead(_CteFirst);
  LOOP vMarkedItem # gMarkList->CteRead(_CteNext, vMarkedItem);
  WHILE (vMarkedItem > 0) DO BEGIN

    Lib_Mark:TokenMark(vMarkedItem, var vMFile, var vMID);
    if (vMFile = 460) then begin
      RecRead(460, 0, _recId, vMID);
      vMarked # true;
      vRest  # vRest  + OfP.RestW1;
      vNetto # vNetto + OfP.NettoW1;
    end;

  END;

  // Keine Markierung gefunden? -> Dann alle nicht gelöschten OfPs summieren
  if (vMarked = false) then begin

    FOR   Erx # RecRead(460, 1, _recFirst)
    LOOP  Erx # RecRead(460, 1, _recNext)
    WHILE (Erx = _rOK) DO BEGIN
       if("OfP.Löschmarker" = '') then
        vRest  # vRest  + OfP.RestW1;
        vNetto # vNetto + OfP.NettoW1;
    END;

  end;

  RekRestore(v460);
  RETURN vRest;
end;


//========================================================================
//  RecalcAllZahlungen
//
//========================================================================
sub RecalcAllZahlungen(opt aSilent : logic)
local begin
  Erx : int;
end;
begin

  FOR Erx # Recread(460,1,_recfirst)
  LOOP Erx # Recread(460,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(460,1,_recLock);
    OFP.Zahlungen   # 0.0;
    OFP.ZahlungenW1 # 0.0;
    FOR Erx # RecLink(461,460,1,_recFirst)
    LOOP Erx # RecLink(461,460,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Erx # RecLink(465,461,2,_recFirst);   // ZEi holen
      if ("Zei.Währungskurs"<>"Ofp.Währungskurs") then begin
        "ZEi.Währungskurs" # "Ofp.Währungskurs";
      end;
      if ("Zei.Währung"<>1) and ("ZEi.Währungskurs"<>0.0) then begin
        RecRead(461,1,_recLock);
        OfP.Z.BetragW1        # Rnd(OfP.Z.Betrag / "Zei.Währungskurs",2);
        OfP.Z.SkontobetragW1  # Rnd(OfP.Z.SkontoBetrag / "Zei.Währungskurs",2);
        RekReplace(461,_Recunlock,'AUTO');
      end;
      OfP.Zahlungen   # Rnd(OfP.Zahlungen   + OfP.Z.Betrag + OfP.Z.Skontobetrag,2);
      OfP.ZahlungenW1 # Rnd(OfP.ZahlungenW1 + OfP.Z.BetragW1 + OfP.Z.SkontobetragW1,2);
    END;
    OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
    OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);
    RekReplace(460,_recunlock,'AUTO');
  END;


  FOR Erx # Recread(465,1,_recfirst)
  LOOP Erx # Recread(465,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(465,1,_recLock);
    ZEi.Zugeordnet    # 0.0;
    ZEi.ZugeordnetW1  # 0.0;
    FOR Erx # RecLink(461,465,1,_recFirst)
    LOOP Erx # RecLink(461,465,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      ZEi.Zugeordnet    # Rnd(ZEi.Zugeordnet + OfP.Z.Betrag,2);
      ZEi.ZugeordnetW1  # Rnd(ZEi.ZugeordnetW1 + OfP.Z.BetragW1,2);
    END;
    RekReplace(465,_recunlock,'AUTO');
  END;

  if (aSilent = false) then
    Msg(999998,'',0,0,0);

end;


//========================================================================
//  ReplaceMitLoeschmarker
//========================================================================
SUB ReplaceMitLoeschmarker(aMark : alpha) : int;
local begin
  Erx     : int;
  vF      : float;
  vFW1    : float;
  vMitKor : logic;
  vDiff   : logic;
end;
begin

  if ("Ofp.Löschmarker"=aMark) then
    RETURN RekReplace(460,_RecUnlock,'AUTO');

  "OfP.Löschmarker" # aMark;
  if (aMark='*') then begin
    "OfP.Lösch.Datum" # today;
    "OfP.Lösch.Zeit"  # now;
    "OfP.Lösch.User"  # gUsername;
  end
  else begin
    "OfP.Lösch.Datum" # 0.0.0;
    "OfP.Lösch.Zeit"  # 0:0;
    "OfP.Lösch.User"  # '';
  end;
  
  if (Set.Ofp.DB_Korrektur) and (Ofp.Brutto<>0.0) then begin
    Erx # RecLink(450,460,2,_RecFirst);    // Erlös holen
    if (Erx<=_rLocked) then
      vMitKor # true;
  end;

  if (vMitKor=false) then begin
    RETURN RekReplace(460,_RecUnlock,'AUTO');
  end;


  // mit Zahlungskorrektur ----------------------
  Erx # RecRead(450,1,_recLock);
  if ("Ofp.Löschmarker"='*') then begin
    Erl.Korrektur   # - Ofp.Brutto;
    Erl.KorrekturW1 # - Ofp.BruttoW1;
    // reine Zahlungen loopen und einrechen...
    FOR Erx # Reclink(461,460,1,_recFirst)
    LOOP Erx # Reclink(461,460,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Erl.Korrektur   # Rnd(Erl.Korrektur + Ofp.Z.Betrag, 2)
      Erl.KorrekturW1 # Rnd(Erl.KorrekturW1 + Ofp.Z.BetragW1, 2)
    END;
    vF    # Erl.Korrektur;
    vFW1  # Erl.KorrekturW1;
    vDiff # (vF<>0.0) or (vFw1<>0.0);
  end
  else begin
//    vF    # Erl.Korrektur;
//    vFW1  # Erl.KorrekturW1;
    vDiff # (Erl.Korrektur<>0.0) or (Erl.KorrekturW1<>0.0);
    Erl.Korrektur   # 0.0;
    Erl.KorrekturW1 # 0.0;
  end;
  Erx # Erl_data:Replace();

  // Differenz zu buchen?
  if (vDiff) then begin
    // in Faktor umwandeln
    vF    # vF    / Ofp.Brutto;
    vFW1  # vFw1  / Ofp.BruttoW1;
// ?? MwSt rausrechnen

// Kontierung loopen
    FOR Erx # Reclink(451,450,1,_recFirst)
    LOOP Erx # Reclink(451,450,1,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (Erl.K.Steuerschl=0) then CYCLE;  // Holzrichters "Sonderkonten" überspringen

      RecRead(451,1,_recLock);
      Erl.K.Korrektur   # Rnd(Erl.K.Betrag    * vF, 2);
      Erl.K.KorrekturW1 # Rnd(Erl.K.BetragW1  * vFw1, 2);
      Erx # Erl_data:Replace451();
      if (erx<>_rOK) then begin
        Erg # Erx; // TODOERX
        RETURN Erx;
      end;

      // Auftragsaktionen loopen...
      FOR Erx # Reclink(404,451,7,_recFirst)
      LOOP Erx # Reclink(404,451,7,_recNext)
      WHILE (Erx<=_rLocked) do begin
        RecRead(404,1,_recLock);
        Auf.A.RechKorrektur # Rnd(Auf.A.Rechnungspreis * vF, 2);
        Auf.A.RechKorrektW1 # Rnd(Auf.A.RechPreisW1 * vFw1, 2);
        RekReplace(404);
        // Material updaten...
        if (Auf.A.Materialnr<>0) then begin
          Erx # Mat_Data:Read(Auf.A.materialnr);
          if (Erx=200) then begin
            if (Mat.Bestand.Gew<>0.0) then begin
              RecRead(200,1,_recLock);
              Mat.VK.Korrektur # Rnd(Auf.A.RechKorrektW1 / Mat.Bestand.Gew * 1000.0,2);
              RekReplace(200);
            end;
          end
          else if (Erx=210) then begin
            if ("Mat~Bestand.Gew"<>0.0) then begin
              RecRead(210,1,_recLock);
              "Mat~VK.Korrektur" # Rnd(Auf.A.RechKorrektW1 / "Mat~Bestand.Gew" * 1000.0,2);
              RekReplace(210);
            end;
          end;
        end;
      END;

    END;
  end;


  RETURN RekReplace(460,_RecUnlock,'AUTO');
end;


//========================================================================