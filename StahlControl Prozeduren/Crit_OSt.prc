@A+
//===== Business-Control =================================================
//
//  Prozedur    Crit_OSt
//                OHNE E_R_G
//  Info
//
//
//  19.01.2012  AI  Erstellung der Prozedur
//  28.08.2018  AH  "Set.Crit.AktivYN" deaktiviert
//
//  Subprozeduren
//    sub RecalcStartTermin() : logic;
//    sub Start() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

declare Ermittle_Auftragsbestand() : logic;
declare Ermittle_Bestellbestand() : logic;
declare Ermittle_Materialbestand() : logic;

//========================================================================
//  RecalcStartTermin
//
//========================================================================
sub RecalcStartTermin() : logic;
local begin
  vErg  : int;
  vMon  : int;
  v903  : int;
end;
begin
  v903 # RekSave(903);
//debugx('starte bei '+cnvaT(set.crit.start.zeit, _FmtTimeSeconds));
//  RecRead(903,1,_recLock);
//  Set.Crit.Start.Datum  # today;
//  Set.Crit.Start.Zeit   # now;
//  Set.Crit.Start.Zeit->vmSecondsModify(60);

  RecRead(903,1,_recLock);
  if (Set.Crit.Start.Datum=0.0.0) then begin
    Set.Crit.Start.Datum  # 1.5.2012;
    Set.Crit.Start.Zeit   # 00:00;
  end
  else begin
//    Set.Crit.Start.Datum->vmmonthmodify(1);
    vMon # Set.Crit.Start.Datum->vpmonth;
    // einen Tag weiter, bis KW oder Monatswechsel
    REPEAT
      Set.Crit.Start.Datum->vmdaymodify(1);
      // bis MONTAG oder Monatswechsel
    UNTIL (Set.Crit.Start.Datum->vpDayOfWeek=1) or (Set.Crit.Start.Datum->vpmonth<>vMon);
//debugx('neues Startdatum:'+cnvad(Set.Crit.Start.Datum));
  end;



  v903->Set.Crit.Start.Datum  # Set.Crit.Start.Datum;
  v903->Set.Crit.Start.Zeit   # Set.Crit.Start.Zeit;
  vErg # RekReplace(903,_recunlock,'AUTO');
  RekRestore(v903);

//debugx('neu auf '+cnvaT(set.crit.start.zeit, _FmtTimeSeconds));

  RETURN (vErg=_rOK);

end;


//========================================================================
//  Start
//
//========================================================================
sub Start() : alpha;
local begin
  vDat    : date;
  vZ1,vJ1 : word;
  vZ2,vJ2 : word;
end;
begin

//Msg(99,'crit...',0,0,0);
//RETURN '';

  // alle "altdaten" einrechnen
  // 04.07.2016 AH : nur noch MANUELL oder JOB-SERVER !!!
//  OSt_Data:ProcessStack();


  // KW-Wechsel?
  if (Set.Crit.Start.Datum->vpdayofWeek=1) then begin
    // Wochenübertrag
    vDat # Set.Crit.Start.Datum;
    vDat->vmDayModify(-1);
    Lib_berechnungen:KW_aus_Datum(vDat, var vZ1, var vJ1);
    Lib_berechnungen:KW_aus_Datum(Set.Crit.Start.Datum, var vZ2, var vJ2);
    Ost_Data:UebertrageBestand('W',vZ1, vJ1, vZ2, vJ2);
  end;


  // Monatsanfang?
  if (Set.Crit.Start.Datum->vpday=1) then begin

//debugx('monat------------------------------------------');
//    if (Set.Crit.AktivYN) then begin
// 28.08.2018 AH "Set.Crit.AktivYN" ist nun GRUNDLEGEND bei Crit_Prozedur!
      if (Ermittle_Auftragsbestand()=false) then RETURN '401';
      if (Ermittle_Bestellbestand()=false) then RETURN '501';
      if (Ermittle_Materialbestand()=false) then RETURN '200';
//    end;


    // Monatsübertrag
    vDat # Set.Crit.Start.Datum;
    vDat->vmDayModify(-1);
    vZ1 # vDat->vpMonth;
    vJ1 # vDat->vpYear;
    vZ1 # Set.Crit.Start.Datum->vpMonth;
    vJ1 # Set.Crit.Start.Datum->vpYear;
    Ost_Data:UebertrageBestand('M',vZ1, vJ1, vZ2, vJ2);
/*
    // 1.Quartalswechsel?
    if (Set.Crit.Start.Datum->vpMonth=1) then begin
      vZ1 # 4;
      vZ2 # 1;
      Ost_Data:UebertrageBestand('M',vZ1, vJ1, vZ2, vJ2);
    end;

    // 2.Quartalswechsel?
    if (Set.Crit.Start.Datum->vpMonth=4) then begin
      vZ1 # 1;
      vZ2 # 2;
      Ost_Data:UebertrageBestand('M',vZ1, vJ2, vZ2, vJ2);
    end;

    // 3.Quartalswechsel?
    if (Set.Crit.Start.Datum->vpMonth=7) then begin
      vZ1 # 2;
      vZ2 # 3;
      Ost_Data:UebertrageBestand('M',vZ1, vJ2, vZ2, vJ2);
    end;

    // 4.Quartalswechsel?
    if (Set.Crit.Start.Datum->vpMonth=10) then begin
      vZ1 # 3;
      vZ2 # 4;
      Ost_Data:UebertrageBestand('M',vZ1, vJ2, vZ2, vJ2);
    end;

    // Jahreswechsel?
    if (Set.Crit.Start.Datum->vpMonth=1) then begin
      Ost_Data:UebertrageBestand('J',0, vJ1, 0, vJ2);
    end;
*/
  end;

/*   ALT
  if (Ermittle_Auftragsbestand()=false) then RETURN '401';
  if (Ermittle_Bestellbestand()=false) then RETURN '501';
  if (Ermittle_Materialbestand()=false) then RETURN '200';
*/
  RETURN '';
end;


//========================================================================
//  _SaveOST
//
//========================================================================
sub _SaveOST(aName : alpha) : logic;
local begin
  vBuf890 : int;
  vErg    : int;
end;
begin
  OST.NAme  # aName;
  vBuf890 # Reksave(890);
  vErg # RecRead(890,1,_recLock);
  if (vErg=_rLocked) then begin
    RekRestore(vBuf890);
    RETURN false;
  end;
  if (vErg=_rOK) then begin
    OSt.VK.Wert         # OSt.VK.Wert + vBuf890->OSt.VK.Wert;
    "OSt.VK.Stückzahl"  # "OSt.VK.Stückzahl" + vBuf890->"OSt.VK.Stückzahl"
    OSt.VK.Gewicht      # OSt.VK.Gewicht + vBuf890->OSt.VK.Gewicht;
    OST.VK.Menge        # OSt.VK.Menge + vBuf890->OSt.VK.Menge;
    OSt.Satzanzahl.VK   # OSt.Satzanzahl.VK + vBuf890->OSt.Satzanzahl.VK;

    OSt.EK.Wert         # OSt.EK.Wert + vBuf890->OSt.EK.Wert;
    "OSt.EK.Stückzahl"  # "OSt.EK.Stückzahl" + vBuf890->"OSt.EK.Stückzahl"
    OSt.EK.Gewicht      # OSt.EK.Gewicht + vBuf890->OSt.EK.Gewicht;
    OST.EK.Menge        # OSt.EK.Menge + vBuf890->OSt.EK.Menge;
    OSt.Satzanzahl.EK   # OSt.Satzanzahl.EK + vBuf890->OSt.Satzanzahl.EK;

    OSt.Lager.Wert         # OSt.Lager.Wert + vBuf890->OSt.Lager.Wert;
    "OSt.Lager.Stückzahl"  # "OSt.Lager.Stückzahl" + vBuf890->"OSt.Lager.Stückzahl"
    OSt.Lager.Gewicht      # OSt.Lager.Gewicht + vBuf890->OSt.Lager.Gewicht;
    OST.Lager.Menge        # OSt.Lager.Menge + vBuf890->OSt.Lager.Menge;
    OSt.Satzanzahl.Lager   # OSt.Satzanzahl.Lager + vBuf890->OSt.Satzanzahl.Lager;

    vErg # RekReplace(890,_recUnlock,'AUTO');
  end
  else begin
    RecBufCopy(vBuf890,890);
    vErg # RekInsert(890,_recUnlock,'AUTO');
  end;

  RekRestore(vBuf890);
  RETURN (vErg=_rOK);
end;


//========================================================================
//  Ermittle_Auftragsbestand
//
//========================================================================
sub Ermittle_Auftragsbestand() : logic;
local begin
  vDat  : date;
  vErg  : int;
  vPrgr : int;
  vOK   : logic;
end;
begin

  // einen Tag VOR diesem Monat...
  vDat # datemake(1, datemonth(today), dateyear(today));
  vDat->vmdaymodify(-1);

  // Buffer vorbelegen
  RecBufClear(890);
  OSt.Monat   # datemonth(vDat);
  OSt.Jahr    # dateyear(vDat);

  vPrgr # Lib_Progress:Init( 'Auftragsbestand', RecInfo( 401, _recCount ), true );

  // Aufträge loopen
  FOR vErg # RecRead(401,1,_recFirst)
  LOOP vErg # RecRead(401,1,_recNext)
  WHILE (vErg<=_rLocked) do begin

    vPrgr->Lib_Progress:Step();

    // gelöschte überspringen
    if ("Auf.P.Löschmarker"<>'') then CYCLE;

    // Auftragsart KEIN Lohn!!!
    vErg # RecLink(835,401,5,_recfirst); // Auftragsart holen
    if (vErg<=_rLockeD) then begin
      vOK # ((AAr.Berechnungsart>=200) and (AAr.Berechnungsart<=209)) or
          ((AAr.Berechnungsart>=250) and (AAr.Berechnungsart<=259));
      if (vOK=false) then CYCLE;
    end;
    // Kopf holen
    vErg # RecLink(400,401,3,_RecFirst);
    // nur echte Aufträge
    if (Auf.Vorgangstyp<>c_Auf) then CYCLE;

    if (auf.P.Menge<>0.0) then
      OSt.VK.Wert       # Rnd(Auf.P.Gesamtpreis / Auf.P.Menge * Auf.P.Prd.Rest,2)
    else
      Ost.VK.Wert       # 0.0;
    OSt.VK.Gewicht      # Auf.P.Prd.Rest.Gew;
    "OSt.VK.Stückzahl"  # Auf.P.Prd.Rest.Stk;
    OST.Satzanzahl.VK   # 1;

    // per Warengruppe
    if (_SaveOST('SUM_AUF_WGR:'+aint(Auf.P.Warengruppe))=false) then BREAK;
  END;

  vPrgr->Lib_Progress:Term();

  RETURN (vErg>_rLocked);
end;


//========================================================================
//  Ermittle_Bestellbestand
//
//========================================================================
sub Ermittle_Bestellbestand() : logic;
local begin
  vDat  : date;
  vErg  : int;
  vPrgr : int;
  vGew  : float;
end;
begin

  // einen Tag VOR diesem Monat...
  vDat # datemake(1, datemonth(today), dateyear(today));
  vDat->vmdaymodify(-1);

  // Buffer vorbelegen
  RecBufClear(890);
  OSt.Monat   # datemonth(vDat);
  OSt.Jahr    # dateyear(vDat);

  vPrgr # Lib_Progress:Init( 'Bestellbestand', RecInfo( 501, _recCount ), true );

  // Aufträge loopen
  FOR vErg # RecRead(501,1,_recFirst)
  LOOP vErg # RecRead(501,1,_recNext)
  WHILE (vErg<=_rLocked) do begin

    vPrgr->Lib_Progress:Step();

    // gelöschte überspringen
    if ("Ein.P.Löschmarker"<>'') then CYCLE;

    RekLink(500,501,3,_recFirst); // Kopf holen
    if (Ein.Vorgangstyp<>c_Bestellung) then CYCLE;

    // Gewicht errechnen
    vGew # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.P.FM.Rest.Stk", Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
    if (vGew = 0.0) then
      vGew #  Ein.P.FM.Rest;

    if (Ein.P.Menge<>0.0) then
      OSt.EK.Wert       # Rnd(Ein.P.Gesamtpreis / Ein.P.Menge * Ein.P.FM.Rest,2)
    else
      Ost.EK.Wert       # 0.0;
    OSt.EK.Gewicht      # vGew;
    "OSt.EK.Stückzahl"  # Ein.P.FM.Rest.Stk;
    OST.Satzanzahl.EK   # 1;

    // per Warengruppe
    if (_SaveOST('SUM_BEST_WGR:'+aint(Ein.P.Warengruppe))=false) then BREAK;
  END;

  vPrgr->Lib_Progress:Term();

  RETURN (vErg>_rLocked);
end;


//========================================================================
//  Ermittle_Materialbestand
//
//========================================================================
sub Ermittle_Materialbestand() : logic;
local begin
  vDat  : date;
  vErg  : int;
  vPrgr : int;
end;
begin

  // einen Tag VOR diesem Monat...
  vDat # datemake(1, datemonth(today), dateyear(today));
  vDat->vmdaymodify(-1);

  // Buffer vorbelegen
  RecBufClear(890);
  OSt.Monat   # datemonth(vDat);
  OSt.Jahr    # dateyear(vDat);

  vPrgr # Lib_Progress:Init( 'Materialbestand', RecInfo( 200, _recCount ), true );

  // Aufträge loopen
  FOR vErg # RecRead(200,1,_recFirst)
  LOOP vErg # RecRead(200,1,_recNext)
  WHILE (vErg<=_rLocked) do begin

    vPrgr->Lib_Progress:Step();

    // gelöschte überspringen
    if ("Mat.Löschmarker"<>'') then CYCLE;
    if (Mat.EigenMaterialYN=false) then CYCLE;
    if (Mat.Bestellt.Gew<>0.0) or (Mat.Bestellt.Stk<>0) then CYCLE;
    if (Mat.Bestand.Gew=0.0) then CYCLE;

    OSt.Lager.Wert        # Rnd(Mat.EK.Effektiv / 1000.0 * Mat.Bestand.Gew)
    OSt.Lager.Gewicht     # Mat.Bestand.Gew;
    "OSt.Lager.Stückzahl" # Mat.Bestand.Stk;
    OST.Satzanzahl.Lager  # 1;

    // per Warengruppe
    if (_SaveOST('SUM_WGR:'+aint(Mat.Warengruppe))=false) then BREAK;
  END;

  vPrgr->Lib_Progress:Term();

  RETURN (vErg>_rLocked);
end;


//========================================================================