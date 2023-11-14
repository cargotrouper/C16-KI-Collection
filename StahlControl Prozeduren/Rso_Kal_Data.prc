@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Kal_Data
//                  OHNE E_R_G
//  Info        Ressourcengruppen Kalender
//
//
//  28.02.2008  ST  Erstellung der Prozedur
//  27.06.2013  AH  Umbau auf Viertelstunden
//  20.02.2015  AH  Erweiterung Rso.Rsv
//  18.10.2019  AH  Erweiterungen für AZ
//  22.02.2021  AH  Fix "AZimInterval" "AZamTag"
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//  SUB IstArbeitstag(aGruppe : int; aTyp : alpha; aDatum : date) : logic
//  SUB Minuten(aVon : time; aBis : time) : float;
//  SUB Arbeitszeit(aGruppe : int; aDatum  : date) : float;
//  SUB ArbeitsStart(aGruppe : int; aDatum : date) : time;
//  SUB _InnerCalcString(aVon : time; aBis : time; aTim : Time) : alpha;
//  SUB CalcString() : alpha;
//  SUB GetPlantermin(aGruppe: int;var aDatum: date; var aZeit: time; aDauer: int;) : logic
//  SUB IstArbeitstag(aGruppe : int;aTyp    : alpha;aDatum  : date;) : logic
//  SUB Arbeitszeit(aGruppe : int; aTyp    : alpha; aDatum  : date) : float;
//
//  SUB _PasstRechtsinAz(aVon : time; aBis : time; var aTim  : time; var aMins : int; var aEnde : time) : logic;
//  SUB _PasstLinksinAz(aVon : time; aBis : time; var aTim : time; var aMins : int; var aStart : time) : logic;
//  SUB _PasstRechtsInTag(var aTim : time; var aMins : int; var aEnde : time) : logic;
//  SUB _PasstLinksInTag(var aStart : time; var aMins : int; var aEnde : time) : logic;
//  SUB PasstRechtsInKalender(aGruppe : int; var aDat1 : date; var aTim1 : time; var aMins : int; var aDat2 : date; var aTim2 : time) : logic;
//  SUB PasstLinksInKalender(aGruppe : int; var aDat1 : date; var aTim1 : time; var aMins : int; var aDat2 : date; var aTim2 : time) : logic;
//
//  SUB Min_In_StundenString(aMin : int) : Alpha
//  SUB AZimIntervall(aT1 : time; aT2 : time; aVon : time; aBis : time) : int
//  SUB AZamTag(aGrp : int; aDat : date; aVon : time; aBis : time) : int;
//  SUB sub AZimBereich(aGrp : int; aDat : date; aTim : time; aDat2 : date; aTim2 : time) : int
//
//========================================================================
@I:Def_Global
@I:Def_Rights


declare IstArbeitstag(
  aGruppe : int;
  aTyp    : alpha;
  aDatum  : date;
) : logic

define begin
  cTagVor(a) : a # CnvDi(CnvID(a)+1);
  cTagZurueck(a) : a # CnvDi(CnvID(a)-1);
  
  myReturn(a) : return a
  //: begin debugx(aint(a)); return a; end;
end;


//========================================================================
// IstArbeitstag
//            Gibt zurück, ob für den Tag Arbeitszeiten eingetragen sind
//
//========================================================================
sub IstArbeitstag(
  aGruppe : int;
  aTyp    : alpha;
  aDatum  : date;
) : logic
begin

  // Prüfen, ob der Tag im Arbeitszeitenkalender eingetragen ist
  Rso.Kal.Gruppe  # aGruppe;
  Rso.Kal.Datum   # aDatum;
  if (RecRead(163,1,0) > _rLocked) then RETURN false;

  // Tag gefunden, jetzt prüfen, ob dieer auch Arbeitszeiten besitzt
  Rso.Kal.Tag.Typ  # aTyp;
  if (RecRead(164,1,0) > _rLocked) then RETURN false;

//      vString # Rso.Kal.Tag.xString;
      // Leere Stunden extrahieren
//      vString # Str_ReplaceAll(vString,'-','');
//      if (StrAdj(vString,_StrAll) = '') then
        // Keine Zeiten hinterlegt
//        vRet # false;

  if (Rso.Kal.Tag.Bis1Zeit<>24:00) or (Rso.Kal.Tag.Von1Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis2Zeit<>24:00) or (Rso.Kal.Tag.Von2Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis3Zeit<>24:00) or (Rso.Kal.Tag.Von3Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis4Zeit<>24:00) or (Rso.Kal.Tag.Von4Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis5Zeit<>24:00) or (Rso.Kal.Tag.Von5Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis6Zeit<>24:00) or (Rso.Kal.Tag.Von6Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis7Zeit<>24:00) or (Rso.Kal.Tag.Von7Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis8Zeit<>24:00) or (Rso.Kal.Tag.Von8Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis9Zeit<>24:00) or (Rso.Kal.Tag.Von9Zeit<>24:00) then RETURN true;

  RETURN false;

end;


//========================================================================
//  Minuten
//
//========================================================================
sub Minuten(aVon : time; aBis : time) : float;
local begin
  vI  : int;
end;
begin
//debug(cnvat(aVon)+' bis '+cnvat(aBis));
  if (aVon=24:00) then RETURN 0.0;

  vI # cnvit(aVon) / 60000;
  if (aBis=00:00) then RETURN cnvfi((24*60) - vI);
  vI # (cnvit(aBis) / 60000) - vI;
  if (vI<0) then vI # 0;
  RETURN cnvfi(vI);
end;


//========================================================================
// Arbeitzeit
//            Gibt die Arbeitszeiten in Minuten zurück
//
//========================================================================
sub Arbeitszeit(
  aGruppe : int;
  aDatum  : date;
) : float;
local begin
  vRet    : float;
end;
begin

  // Prüfen, ob der Tag im Arbeitszeitenkalender eingetragen ist
  Rso.Kal.Gruppe  # aGruppe;
  Rso.Kal.Datum   # aDatum;

  if (RecRead(163,1,0) > _rLocked) then RETURN 0.0;

  if (RecLink(164,163,1,_recFirst) > _rLocked) then RETURN 0.0;

//      vString # Rso.Kal.Tag.xString;
      // Leere Stunden extrahieren
//      vString # Str_ReplaceAll(vString,'-','');
//      vRet # cnvfi(StrLen(vString));
  vRet # Minuten(Rso.Kal.Tag.Von1Zeit , Rso.Kal.Tag.Bis1Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von2Zeit , Rso.Kal.Tag.Bis2Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von3Zeit , Rso.Kal.Tag.Bis3Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von4Zeit , Rso.Kal.Tag.Bis4Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von5Zeit , Rso.Kal.Tag.Bis5Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von6Zeit , Rso.Kal.Tag.Bis6Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von7Zeit , Rso.Kal.Tag.Bis7Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von8Zeit , Rso.Kal.Tag.Bis8Zeit);
  vRet # vRet + Minuten(Rso.Kal.Tag.Von9Zeit , Rso.Kal.Tag.Bis9Zeit);

  RETURN vRet;
end;


//========================================================================
// ArbeitsStart
//            Gibt die Startuhrzeit zurück
//
//========================================================================
sub ArbeitsStart(
  aGruppe : int;
  aDatum  : date;
) : time;
local begin
  vI      : int;
end;
begin

  // Prüfen, ob der Tag im Arbeitszeitenkalender eingetragen ist
  Rso.Kal.Gruppe  # aGruppe;
  Rso.Kal.Datum   # aDatum;

  if (RecRead(163,1,0) > _rLocked) then RETURN 24:00;

  if (RecLink(164,163,1,_recFirst) > _rLocked) then RETURN 24:00;

//  vString # Rso.Kal.Tag.xString;
//  vI # StrFind(vString, '+', 0);
//  if (vI=0) then RETURN 24:00;
//  dec(vI);
//  RETURN cnvti(60 * 60 * 1000 * vI);

  if (Rso.Kal.Tag.Von1Zeit<>0:0) or (Rso.Kal.Tag.Bis1Zeit<>0:0) then RETURN Rso.Kal.Tag.Von1Zeit;
  if (Rso.Kal.Tag.Von2Zeit<>0:0) or (Rso.Kal.Tag.Bis2Zeit<>0:0) then RETURN Rso.Kal.Tag.Von2Zeit;
  if (Rso.Kal.Tag.Von3Zeit<>0:0) or (Rso.Kal.Tag.Bis3Zeit<>0:0) then RETURN Rso.Kal.Tag.Von3Zeit;
  if (Rso.Kal.Tag.Von4Zeit<>0:0) or (Rso.Kal.Tag.Bis4Zeit<>0:0) then RETURN Rso.Kal.Tag.Von4Zeit;
  if (Rso.Kal.Tag.Von5Zeit<>0:0) or (Rso.Kal.Tag.Bis5Zeit<>0:0) then RETURN Rso.Kal.Tag.Von5Zeit;
  if (Rso.Kal.Tag.Von6Zeit<>0:0) or (Rso.Kal.Tag.Bis6Zeit<>0:0) then RETURN Rso.Kal.Tag.Von6Zeit;
  if (Rso.Kal.Tag.Von7Zeit<>0:0) or (Rso.Kal.Tag.Bis7Zeit<>0:0) then RETURN Rso.Kal.Tag.Von7Zeit;
  if (Rso.Kal.Tag.Von8Zeit<>0:0) or (Rso.Kal.Tag.Bis8Zeit<>0:0) then RETURN Rso.Kal.Tag.Von8Zeit;
  if (Rso.Kal.Tag.Von9Zeit<>0:0) or (Rso.Kal.Tag.Bis9Zeit<>0:0) then RETURN Rso.Kal.Tag.Von9Zeit;

  RETURN 24:00;
end;


//========================================================================
//========================================================================
sub _InnerCalcString(
  aVon : time;
  aBis : time;
  aTim : Time) : alpha;
begin
  if (aVon<>24:00) then
    if (aVon<=aTim) and ((aBis=0:0) or (aBis>aTim)) then RETURN '+';
  RETURN '';
end;


//========================================================================
// CalcString
//            baut aus den 9 Von-Bis-Zeiten einen +-String
//
//========================================================================
sub CalcString() : alpha;
local begin
  vA,vB : alpha(100);
  vI,vJ : int;
  vMin  : int;
  vTim  : time;
end;
begin


  FOR vI # 0 loop inc(vI) WHILE (vI< 24*4) do begin
    vMin  # vI * 15;
    vJ    # vMin div 60;
    vMin  # vMin - (vJ * 60);
    vTim # TimeMake(vJ, vMin, 0, 0);
    vA # '';
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von1Zeit, Rso.Kal.Tag.Bis1Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von2Zeit, Rso.Kal.Tag.Bis2Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von3Zeit, Rso.Kal.Tag.Bis3Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von4Zeit, Rso.Kal.Tag.Bis4Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von5Zeit, Rso.Kal.Tag.Bis5Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von6Zeit, Rso.Kal.Tag.Bis6Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von7Zeit, Rso.Kal.Tag.Bis7Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von8Zeit, Rso.Kal.Tag.Bis8Zeit, vTim);
    if (vA='') then vA # _InnerCalcString(Rso.Kal.Tag.Von9Zeit, Rso.Kal.Tag.Bis9Zeit, vTim);
    if (vA='') then vA # '-';
    vB # vB + vA;
  END;

  RETURN vB;
end;


//========================================================================
// GetPlantermin
//            Gibt den frühsten Startpunkt eines Kalendereintrages zurück
//
//  aGruppe     : int;      ->  Kalendergruppe
//  var aDatum  : date;     ->  Gewünschter Starttermin
//  var aZeit   : time;     ->  Gewünschter Startzeitpunkt
//  aDauer      : int;      ->  zu Prüfende Dauer (in Minuten) AUCH NEGATIV !!!
//========================================================================
sub GetPlantermin(
  aGruppe     : int;
  var aDatum  : date;
  var aZeit   : time;
  aDauer      : int;
  var aDatum2 : date;
  var aZeit2  : time;
) : logic
local begin
  vRet        : logic;
  vRichtung   : alpha;
  i           : int;
  vErg        : int;
  vFirst      : logic;
  vFirstEnd   : logic;
  vOffset     : int;
//  vHours      : alpha(1)[24*4];
  vNoDayCnt   : int;
  vCount      : int;
  vString     : alpha(100);
end;
begin
//debug('start plan '+aint(bag.p.nummer)+'/'+aint(bag.p.position));
  // Aufruf prüfen
  if ((aGruppe = 0) OR (aDatum = 00.00.0000) OR //(aZeit = 00:00) OR
      (aDauer = 0)) then begin

    aDatum  # 00.00.00;
    aZeit   # 00:00;
    RETURN false;
  end;

  // DUMMY(keine Ressource) ?
  if (aGruppe>=32000) then begin
    lib_Berechnungen:TerminModify(var aDatum, var aZeit, cnvfi(aDauer));
    RETURN true;
  end;


  vRet # true;
  vFirstEnd # true;

  // nach Suchrichtung differenzieren
  if (aDauer >= 0) then begin
    vRichtung # 'rechts';
    if ((aDauer % 60) = 0) then
      aDauer # aDauer + 1;   // Eine Minute für Stundenwechsel addieren
  end
  else begin
    vRichtung # 'links';
    aDauer    # aDauer * -1;
  end;



  // Dauer in VIERTEL-Stunden umrechnen
  if ((aDauer % 15) > 0) then
    aDauer # (aDauer DIV 15) + 1
  else
    aDauer # aDauer / 15;

//debug('dauer in Viertelstunden: '+aint(aDauer));

  vCount # 0;
  vFirst # true;
  REPEAT
    // Tag lesen
    Rso.Kal.Gruppe # aGruppe;
    Rso.Kal.Datum  # aDatum;

    Inc(vCount);
    if (vCount>150) then begin
      aDatum  # 00.00.00;
      aZeit   # 00:00;
      RETURN false;
    end;

    vErg # RecRead(163,1,0);
    if (vErg=_rNoRec) then begin
      aDatum  # 00.00.00;
      aZeit   # 00:00;
      RETURN false;
    end;

//debug('suche kal:'+AInt(aGruppe)+' '+cnvad(aDatum)+'@'+cnvat(aZeit)+'   '+vRichtung+'  '+cnvai(verg));
//debug('Ist:'+AInt(Rso.Kal.Gruppe)+' '+cnvad(Rso.Kal.Datum));
    if (vErg >= _rLocked) then begin

      // Der angegebene Tag existiert nicht,
      // versuchen den Vortag zu lesen
      if (vRichtung = 'links') then begin
//        if (vErg = _rNoKey) AND ((Rso.Kal.Gruppe <> aGruppe) OR (Rso.Kal.Datum  <> aDatum)) then begin
          vNoDayCnt  # vNoDayCnt + 1;
          if (vNoDayCnt = 30) then begin  // Nach 30 Tagen ohne gefunden Plantag-> ABBRUCH
            aDatum  # 00.00.00;
            aZeit   # 00:00;
            RETURN false;
          end;
//          aZeit   # 23:45;  // Offset neu einstellen, da Startzeit nicht eingehalten werden kann
aZeit # 24:00;
//        end;
        aDatum->vmDayModify(-1);
      end
      else begin
        if (vErg = _rNoKey) AND ((Rso.Kal.Gruppe <> aGruppe) OR (Rso.Kal.Datum  <= aDatum)) then begin
          aDatum  # 00.00.00;
          aZeit   # 00:00;
          RETURN false;
        end;
        aDatum->vmDayModify(1);
//        aDatum # Rso.Kal.Datum;
      end;

      CYCLE;
    end;



    // Tag gefunden
    vNoDayCnt # 0; // Beim nächsten Tag wieder neu anfangen zu zählen

    // Ist kein Arbeitstag?
    if (!IstArbeitstag(Rso.Kal.Gruppe,Rso.Kal.Tagtyp,aDatum)) then begin
      // Dieser Tag ist kein Arbeitstag, Vortag prüfen
      if (vRichtung = 'links') then
        aDatum->vmDayModify(-1)
      else
        aDatum->vmDayModify(1);
//debug('kein AT!');
      CYCLE;
    end;

    // Arbeitszeiten lesen
    Rso.Kal.Tag.Typ # Rso.Kal.Tagtyp;
    RecRead(164,1,0);
    vErg # RecRead(163,1,0);
    if (vErg > _rLocked) then begin
      aDatum  # 00.00.00;
      aZeit   # 00:00;
      RETURN false;
    end;

    vString # CalcString();
    // 0 - 23 umwandeln in 1 - 24
//    vString # StrCut(vString,2,( 24*4)-1 )+StrCut(vString,1,1);


    if (vRichtung = 'links') then begin
      // ------------------
      // Rückwärtsplanung
      // ------------------
      vOffSet # (24*4);
      if (vFirst) then begin
//        vOffSet # TimeHour(aZeit)-1;
        vOffSet # (TimeHour(aZeit)*4);
        vFirst # false;
      end;
//debug('probiere ab zeit '+cnvat(aZeit)+' = '+aint(vOffset));
      FOR i # vOffSet;
      LOOP dec(i)
      WHILE (i > 0) DO BEGIN
        if (StrCut(vString,i,1)='+') then begin
          aDauer # aDauer - 1;
//          aZeit # TimeMake(i,0,0,0);
          aZeit # cnvti((i-1) * 15 * 60000);
          if (vFirstEnd) then begin
            vFirstEnd # false;
            aDatum2   # aDatum;
            aZeit2    # aZeit;
            Lib_Berechnungen:TerminModify(var aDatum2, var aZeit2, 15.0);
          end;
//debug('passt einmal am '+cnvad(aDatum)+' um '+cnvat(aZeit));
//        end
//        else begin
//debug('passt NICHT am '+cnvad(aDatum)+' um '+cnvai(I));
        end;

        if (aDauer = 0) then
          break;
      END;

    end
    else begin
      // ------------------
      // Vorwärtsplanung
      // ------------------
      vOffSet # 1;
      if (vFirst) then begin
        vOffSet # TimeHour(aZeit)*4;
        vFirst  # false;
      end;

      FOR i # vOffSet
      LOOP inc(i)
      WHILE (i <= 24*4) DO BEGIN

        if (vOffset > 0) AND (StrCut(vString,i,1)='+') then begin //(vHours[i] = '+') then begin
          aDauer # aDauer - 1;
          aZeit # TimeMake(i,0,0,0);
          if (vFirstEnd) then begin
            vFirstEnd # false;
            aDatum2   # aDatum;
            aZeit2    # aZeit;
            Lib_Berechnungen:TerminModify(var aDatum2, var aZeit2, 15.0);
          end;
        end;
//debug(cnvAT(aZeit));
        if (aDauer = 0) then
          break;
      END;

    end;

    // Fertig?, falls nicht dann nächsten Tag lesen
    if (aDauer = 0) then begin
      vRet # true;
      BREAK;
    end;

    if (vRichtung = 'links') then
      aDatum->vmDayModify(-1)
    else
      aDatum->vmDayModify(1);

  UNTIL (false);


  if !(vRet) then begin
    aDatum  # 00.00.00;
    aZeit   # 00:00;
  end;


  RETURN vRet;

end; // EO sub GetPlantermin(...)


//========================================================================
//========================================================================
sub _PasstRechtsinAz(
  aVon      : time;
  aBis      : time;
  var aTim  : time;
  var aMins : int;
  var aEnde : time;
) : logic;
local begin
  vI          : int;
end;
begin
  if (aMins<=0) then RETURN false;
  if (aVon=24:00) and (aBis=24:00) then RETURN false;

  if (aVon=00:00) and (aBis=00:00) then
    aBis # 24:00;

  if (aBis=00:00) then aBis # 24:00;  // 21.11.2017 AH
  if (aTim>=aBis) then RETURN false;

//debugx(cnvat(aVon)+' - '+cnvat(aBis)+' @'+cnvat(aTim)+' '+aint(aMins)+'min ?');

  // liegt VOR Arbeitszeit? -> dann auf VON schieben
  if (aTim<aVon) then aTim # aVon;

  // ist AZ!
//  if (aBis=0:0) then aBis # 24:00;
  vI # cnvit(aBis) / 60000;           // Ende in Sekunden
  vI # vI - (cnvit(aTim) / 60000);    // Differenz

  // weniger AZ als Minuten?
  if (vI<aMins) then begin
    aMins # aMins - vI;
    aEnde # cnvti(((cnvit(aTim) / 60000) + vI) * 60000);
    if (aEnde=24:00) then aEnde # 0:0;
    RETURN true;
  end;

  // mehr AZ als Minuten...
  vI # cnvit(aTim) / 60000; // Start in Sekunden
  vI # vI + aMins;
  aMins # 0;
  aEnde # cnvti(vI * 60000);

  if (aEnde=24:00) then aEnde # 0:0;
  RETURN true;
end;


//========================================================================
//========================================================================
sub _PasstLinksinAz(
  aVon        : time;
  aBis        : time;
  var aTim    : time;   // Endzeit
  var aMins   : int;
  var aStart  : time;
) : logic;
local begin
  vI          : int;
end;
begin

  if (aMins<=0) then RETURN false;
  if (aVon=24:00) and (aBis=24:00) then RETURN false;
  if (aVon=00:00) and (aBis=00:00) then
    aBis # 24:00;
  if (aTim<=aVon) then RETURN false;

  if (aBis=00:00) then aBis # 24:00;  // 21.11.2017  AH

  // liegt NACH Arbeitszeit? -> dann auf BIS schieben
  if (aTim>aBis) then aTim # aBis;

  // ist AZ!
//  if (aBis=0:0) then aBis # 24:00;
  vI # cnvit(aTim) / 60000;           // Ende in Sekunden
  vI # vI - (cnvit(aVon) / 60000);    // Differenz

  // weniger AZ als Minuten?
  if (vI<aMins) then begin
    aMins   # aMins - vI;
    aStart  # cnvti(((cnvit(aTim) / 60000) - vI) * 60000);
    RETURN true;
  end;

  // mehr AZ als Minuten...
  vI # cnvit(aTim) / 60000; // Ende in Sekunden
  vI # vI - aMins;
  aMins # 0;
  aStart # cnvti(vI * 60000);

  RETURN true;
end;


//========================================================================
//========================================================================
sub _PasstRechtsInTag(
  var aTim  : time;
  var aMins : int;
  var aEnde : time;
) : logic;
local begin
  vStart    : time;
  vFirst    : logic;
end;
begin

  if (aMins=0) then RETURN true;

  aEnde # 24:00;
  vFirst # y;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von1Zeit, Rso.Kal.Tag.Bis1Zeit, var aTim, var aMins, var aEnde)) then begin
    vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von2Zeit, Rso.Kal.Tag.Bis2Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von3Zeit, Rso.Kal.Tag.Bis3Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von4Zeit, Rso.Kal.Tag.Bis4Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von5Zeit, Rso.Kal.Tag.Bis5Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von6Zeit, Rso.Kal.Tag.Bis6Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von7Zeit, Rso.Kal.Tag.Bis7Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;
  if (_PasstRechtsinAz(Rso.Kal.Tag.Von8Zeit, Rso.Kal.Tag.Bis8Zeit, var aTim, var aMins, var aEnde)) then begin
    if (vFirst) then vStart # aTim;
    vFirst # n;
  end;

  if (vFirst=false) then begin
    aTim # vStart;
    RETURN true;
  end;

  RETURN false;
end;


//========================================================================
//========================================================================
sub _PasstLinksInTag(
  var aStart  : time;
  var aMins   : int;
  var aEnde   : time;
) : logic;
local begin
  vEnde     : time;
  vFirst    : logic;
end;
begin

  if (aMins=0) then RETURN true;

  aStart  # 0:0;
  vFirst  # y;

  if (_PasstLinksinAz(Rso.Kal.Tag.Von8Zeit, Rso.Kal.Tag.Bis8Zeit, var aEnde, var aMins, var aStart)) then begin
    vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von7Zeit, Rso.Kal.Tag.Bis7Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von6Zeit, Rso.Kal.Tag.Bis6Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von5Zeit, Rso.Kal.Tag.Bis5Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von4Zeit, Rso.Kal.Tag.Bis4Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von3Zeit, Rso.Kal.Tag.Bis3Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von2Zeit, Rso.Kal.Tag.Bis2Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;
  if (_PasstLinksinAz(Rso.Kal.Tag.Von1Zeit, Rso.Kal.Tag.Bis1Zeit, var aEnde, var aMins, var aStart)) then begin
    if (vFirst) then vEnde  # aEnde;
    vFirst # n;
  end;

  if (vFirst=false) then begin
    aEnde # vEnde;
    RETURN true;
  end;

  RETURN false;
end;


//========================================================================
//========================================================================
sub PasstRechtsInKalender(
  aGruppe     : int;
  var aDat1   : date;   // Vorgabe Start
  var aTim1   : time;
  var aMins   : int;
  var aDat2   : date;   // Ergebnis Ende
  var aTim2   : time;
) : logic;
local begin
  Erx         : int;
  vCount      : int;
  vDat1       : date;
  vTim1       : time;
  vTim2       : time;
  vFirst      : logic;
  vI          : int;
end;
begin
//debug('check >>> '+cnvad(aDat1)+' '+cnvat(aTim1));

  if (aDat1=0.0.0) then RETURN false;
  if (aMins=0) then RETURN true;

  vDat1   # aDat1;
  vTim1   # aTim1;
  vFirst  # true;

  // Tag lesen
  Rso.Kal.Gruppe # aGruppe;
  Rso.Kal.Datum  # vDat1;

  FOR Erx # RecRead(163,1,0)
  LOOP Erx # RecRead(163,1,_recNext)
  WHILE (Erx<_rNoRec) and (Rso.Kal.Gruppe=aGruppe) and (Rso.Kal.Datum>=vDat1) and (aMins>0) do begin

    // wenn nicht mehr erster Tag, dann kann auch sofort um 0:0 Uhr gestartet werden!
    if (Rso.Kal.Datum<>vDat1) then vTim1 # 0:0;

    Inc(vCount);
    if (vCount>100) then begin
      RETURN false;
    end;

    Erx # RecLink(164,163,1,_recFirst);  // Typ holen
    if (Erx>_rLocked) then CYCLE;

    vI # aMins;
    _PasstRechtsInTag(var vTim1, var aMins, var vTim2);
    if (vI<>aMins) then begin
//debug('am '+cnvad(rso.kal.datum)+' '+cnvat(vTim1)+' bis '+cnvat(vTim2)+' passen '+aint(vI-aMins)+' => '+cnvat(vTIm2));
      if (vFirst) then begin
        vFirst  # false;
        aDat1   # Rso.Kal.Datum;
        aTim1   # vTim1;
      end;
    end;
    if (aMins<=0) then begin
      aDat2   # Rso.Kal.Datum;
      aTim2   # vTim2;
    end;
  END;

  RETURN (aMins=0);
end;



//========================================================================
//========================================================================
sub PasstLinksInKalender(
  aGruppe     : int;
  var aDat1   : date;   // Ergebnis Start
  var aTim1   : time;
  var aMins   : int;
  var aDat2   : date;   // Vorgabe Ende
  var aTim2   : time;
) : logic;
local begin
  Erx         : int;
  vCount      : int;
  vDat2       : date;
  vTim1       : time;
  vTim2       : time;
  vFirst      : logic;
  vI          : int;
end;
begin
//debug('check <<< '+cnvad(aDat2)+' '+cnvat(aTim2));

  if (aDat2=0.0.0) then RETURN false;
  if (aMins=0) then RETURN true;

  vDat2   # aDat2;
  vTim2   # aTim2;
  vFirst  # true;

  // Tag lesen
  Rso.Kal.Gruppe # aGruppe;
  Rso.Kal.Datum  # vDat2;
  Erx # RecRead(163,1,0)
  if (Erx<_rNoRec) and (Rso.Kal.Gruppe=aGruppe) and (Rso.Kal.Datum>vDat2) then begin
    Erx # RecRead(163,1,_recPrev);  // Einen Satz zurück
    if (Erx>=_rNoRec) then RETURN false;
  end;


  FOR Erx # RecRead(163,1,0)
  LOOP Erx # RecRead(163,1,_recPrev)
  WHILE (Erx<_rNoRec) and (Rso.Kal.Gruppe=aGruppe) and (Rso.Kal.Datum<=vDat2) and (aMins>0) do begin

    // wenn nicht mehr letzer Tag, dann kann auch sofort um 24:0 Uhr geendet werden!
    if (Rso.Kal.Datum<>vDat2) then vTim2 # 24:0;

    Inc(vCount);
    if (vCount>100) then begin
      RETURN false;
    end;

    Erx # RecLink(164,163,1,_recFirst);  // Typ holen
    if (Erx>_rLocked) then CYCLE;

    vI # aMins;
//debug('links:'+cnvat(vTim1)+' '+aint(aMins)+' '+cnvat(vTim2));
    _PasstLinksInTag(var vTim1, var aMins, var vTim2);
//debug('links:'+cnvat(vTim1)+' '+aint(aMins)+' '+cnvat(vTim2));
    if (vI<>aMins) then begin
//debug('am '+cnvad(rso.kal.datum)+' '+cnvat(vTim1)+' bis '+cnvat(vTim2)+' passen '+aint(vI-aMins));
      if (vFirst) then begin
//debugx('');
        vFirst  # false;
        aDat2   # Rso.Kal.Datum;
        aTim2   # vTim2;
      end;
    end;
    if (aMins<=0) then begin
//debugx('');
      aDat1   # Rso.Kal.Datum;
      aTim1   # vTim1;
    end;
  END;

  RETURN (aMins=0);
end;


//========================================================================
sub Min_In_StundenString(
  aMin  : int) : Alpha
local begin
  vI    : int;
end;
begin
  vI    # aMin / 60;
  aMin  # aMin % 60;
  if (vI=0) then RETURN aint(aMin)+' Min.';
  RETURN aint(vI)+'h '+aint(aMin)+' Min.';
end;
  

//========================================================================
sub _hatAZ() : logic;
begin
  if (Rso.Kal.Tag.Bis1Zeit<>24:00) or (Rso.Kal.Tag.Von1Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis2Zeit<>24:00) or (Rso.Kal.Tag.Von2Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis3Zeit<>24:00) or (Rso.Kal.Tag.Von3Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis4Zeit<>24:00) or (Rso.Kal.Tag.Von4Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis5Zeit<>24:00) or (Rso.Kal.Tag.Von5Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis6Zeit<>24:00) or (Rso.Kal.Tag.Von6Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis7Zeit<>24:00) or (Rso.Kal.Tag.Von7Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis8Zeit<>24:00) or (Rso.Kal.Tag.Von8Zeit<>24:00) then RETURN true;
  if (Rso.Kal.Tag.Bis9Zeit<>24:00) or (Rso.Kal.Tag.Von9Zeit<>24:00) then RETURN true;
  RETURN false;
end;


//========================================================================
sub AZimIntervall(
  aT1   : time;
  aT2   : time;
  aVon  : time;
  aBis  : time;
) : int
begin
  if (aT2=0:0) then aT2 # 24:00;
//debugx(cnvat(aT1)+'-'+cnvat(aT2)+' '+cnvat(aVon)+'-'+cnvat(aBis));
  if (aT1=0:0) and (aT2=0:0) then RETURN 0;

  // AZ 6 - 12
  // 4-5 => 0 NUR LINKS
  if (aBis<=aT1) then myRETURN(0);
  // 13-15=>0 NUR RECHTS
  if (aVon>=aT2) then myRETURN(0);
  // 7-10=> 3 DAZWISCHEN
  if (aVon>=aT1) and (aBis<=aT2) then myRETURN(cnvif(Minuten(aVon, aBis)));
  // 4-7 => 1 LINKS RAUS
  if (aVon<aT1) and (aBis<=aT2) then myRETURN(cnvif(Minuten(aT1, aBis)));
  // 10-15=>2 RECHTS RAUS
  if (aVon>=aT1) and (aBis>aT2) then myRETURN(cnvif(Minuten(aVon, aT2)));

  // DRÜBER
  myRETURN(cnvif(Minuten(aT1, aT2)));
 
end;


//========================================================================
sub AZamTag(
  aGrp  : int;
  aDat  : date;
  aVon  : time;
  aBis  : time) : int;
local begin
  Erx   : int;
  vMin  : int;
end;
begin
  Rso.Kal.Gruppe  # aGrp;
  Rso.Kal.Datum   # aDat;
  if (RecRead(163,1,0) > _rLocked) then RETURN 0;
  Erx # RecLink(164,163,1,_recFirst);
  if (Rso.Kal.Tag.Bis1Zeit=0:0) then Rso.Kal.Tag.Bis1Zeit # 24:00;
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von1Zeit, Rso.Kal.Tag.Bis1Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von2Zeit, Rso.Kal.Tag.Bis2Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von3Zeit, Rso.Kal.Tag.Bis3Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von4Zeit, Rso.Kal.Tag.Bis4Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von5Zeit, Rso.Kal.Tag.Bis5Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von6Zeit, Rso.Kal.Tag.Bis6Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von7Zeit, Rso.Kal.Tag.Bis7Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von8Zeit, Rso.Kal.Tag.Bis8Zeit, aVon, aBis);
  vMin # vMin + AZimIntervall(Rso.Kal.Tag.Von9Zeit, Rso.Kal.Tag.Bis9Zeit, aVon, aBis);
  RETURN vMin;
end;


//========================================================================
sub AZimBereich(
  aGrp  : int;
  aDat  : date;
  aTim  : time;
  aDat2 : date;
  aTim2 : time) : int
local begin
  Erx   : int;
  vMin  : int;
  vDat  : date;
  vTim  : time;
  vAZ   : int;
end;
begin
debug('AZ:'+cnvad(aDat)+'@'+cnvat(aTim)+' bis '+cnvad(aDat2)+'@'+cnvat(aTim2));
//  if (Rso_Kal_data:GetPlantermin(aGrp, var aDat, var aTim, 1, var vDat, var vTim)=false) then RETURN 0;
  // Start in AZ schieben...
  WHILE (1=1) do begin
    if (aDat>aDat2) or ((aDat=aDat2) and (aTim>aTim2)) then RETURN 0;
    Rso.Kal.Gruppe  # aGrp;
    Rso.Kal.Datum   # aDat;
    if (RecRead(163,1,0) <= _rLocked) then begin
      Erx # RecLink(164,163,1,_recFirst);
      if (_hatAZ()) then BREAK;
    end;
    aDat->vmDayModify(1);
    aTim # 0:0;
  END;
  vMin # 1;
  _PasstRechtsInTag(var aTim, var vMin, var vTim);
//debugx('Start:'+cnvad(aDat)+'@'+cnvat(aTim));//+' '+aint(vMin)+' '+cnvat(vTim));

  // Ende rückwärts in AZ schieben...
  WHILE (1=1) do begin
    if (aDat>aDat2) or ((aDat=aDat2) and (aTim>aTim2)) then RETURN 0;
    Rso.Kal.Gruppe  # aGrp;
    Rso.Kal.Datum   # aDat2;
    if (RecRead(163,1,0) <= _rLocked) then begin
      Erx # RecLink(164,163,1,_recFirst);
      if (_hatAZ()) then BREAK;
    end;
    aDat2->vmDayModify(-1);
    aTim2 # 24:0;
  END;
  vMin # 1;
  _PasstLinksInTag(var vTim, var vMin, var aTim2);
//debugx('Ende:'+cnvad(aDat2)+'@'+cnvat(aTim2));
  
  vMin # 0;
  WHILE (aDat<aDat2) do begin
    vMin # vMin + AZamTag(aGrp, aDat, aTim, 24:00);
    aDat->vmDayModify(1);
    aTim # 0:0;
  END;
  if (aDat=aDat2) then
    vMin # vMin + AZamTag(aGrp, aDat, aTim,aTim2);

  RETURN vMin;
//debug('AZMINUTEN : '+Min_In_StundenString(vMin));
end;


//========================================================================
//========================================================================
//========================================================================