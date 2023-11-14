@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Mat_MatKarte
//                              OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  07.12.2009  TM  Erstellung der Prozedur
//  17.12.2009  MS  Designanpassung
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  09.10.2012  TM  Randeinstellung "oben" aus Settings wird jetzt ignoriert, fix 15mm
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  15.04.2019  ST  Bemerkung hinzugefügt 1937/13
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB HoleEmpfaenger();
//    SUB AddChem(aName : alpha; aName2 : alpha; pMin : float; pMax : float);
//    SUB AddMech(Name : alpha; pMin : float; pMax : float; Einheit : alpha;);
//    SUB MaterialDruck();
//    SUB MaterialDruck_Lohn();
//    SUB BAGDruck();
//    SUB SeitenKopf();
//    SUB Print(aTyp : alpha);
//    SUB PrintMain (opt aFilename : alpha(4096))
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================

@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG
@I:Def_Aktionen

declare Print(aTyp : alpha);
declare PrintLohnBA(aTyp : alpha);
declare PrintMain (opt aFilename : alpha(4096))

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,cnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPos0     : 5.0
  cPos1     : cPos0   + 15.0
  cPos2     : cPos1   + 25.0
  cPos3     : cPos2   + 15.0
  cPos4     : cPos3   + 40.0
  cPos5     : cPos4   + 15.0
  cPos6     : cPos5   + 25.0
  cPos7     : cPos6   + 15.0
  cPos8     : cPos7   + 20.0
  cPos9     : cPos8   + 20.0
  cPos10    : cPos9   + 20.0
  cPos11    : cPos10  + 20.0
  cPos12    : cPos11  + 20.0
  cPos13    : cPos12  + 20.0


  // Hauptdaten
  cPosH0     :  0.0
  cPosH1     : cPosH0   + 5.0
  cPosH2     : cPosH1   + 40.0
  cPosH3     : cPosH2   + 50.0
  cPosH4     : cPosH3   + 40.0
  cPosH5     : cPosH4   + 40.0
  cPosH6     : cPosH5   + 40.0
  cPosH7     : cPosH6   + 40.0
  cPosH8     : cPosH7   + 40.0
  cPosH9     : cPosH8   + 40.0
  cPosH10    : cPosH9   + 30.0
  cPosH11    : cPosH10  + 30.0
  cPosH12    : cPosH11  + 30.0
  cPosH13    : cPosH12  + 30.0

  cPosHAbm0     :  0.0
  cPosHAbm1     : cPosHAbm0   + 5.0
  cPosHAbm2     : cPosHAbm1   + 35.0
  cPosHAbm3     : cPosHAbm2   + 5.0
  cPosHAbm4     : cPosHAbm3   + 55.0
  cPosHAbm5     : cPosHAbm4   + 30.0


  // Bewegung
  cPosB0     :  0.0
  cPosB1     : cPosB0   + 5.0
  cPosB2     : cPosB1   + 40.0
  cPosB3     : cPosB2   + 55.0
  cPosB4     : cPosB3   + 40.0
  cPosB5     : cPosB4   + 40.0
  cPosB6     : cPosB5   + 40.0
  cPosB7     : cPosB6   + 40.0
  cPosB8     : cPosB7   + 40.0
  cPosB9     : cPosB8   + 40.0
  cPosB10    : cPosB9   + 30.0
  cPosB11    : cPosB10  + 30.0
  cPosB12    : cPosB11  + 30.0
  cPosB13    : cPosB12  + 30.0




  cHauptdatenYN  : GV.Logic.01
  cBewegungYN    : GV.Logic.02
  cAnalyseYN     : GV.Logic.03
  cSonstigesYN   : GV.Logic.04
  cBildYN        : GV.Logic.05
end;

local begin
  vZeilenZahl         : int;
  vCoord              : float;
  vSumStk             : int;
  vSumGewichtN        : float;
  vSumGewichtB        : float;
  vSumBreite          : float;
  vSumLaenge          : float;

  vAdresse            : int;      // Nummer des Empfängers
  vPreis              : float;
  vFirst              : logic;
  vA                  : alpha;
  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers

  // Für Mehrwertsteuer
  vMwstSatz1          : float;
  vMwstWert1          : float;
  vMwstSatz2          : float;
  vMwstWert2          : float;
  vMwstText           : alpha;
  vPosMwSt            : float;

  // Für Preise
  vGesamtNetto        : float;
  vGesamtNettoRabBar  : float;
  vGesamtMwSt         : float;
  vGesamtBrutto       : float;

  vPosCount           : int;
  vPosAnzahlAkt       : int;

  vMenge              : float;
  vPosMenge           : float;
  vPosGewicht         : float;
  vPosStk             : int;
  vPosNetto           : float;
  vPosNettoRabbar     : float;
  vRB1                : alpha;
  vKopfAufpreis       : float;


  // für Verpckungen als Aufpreise
  vVPGPreis           : float;
  vVPGPEH             : int;
  vVPGMEH             : alpha;

  vWtrverb        : alpha;

  // Lohnbearbeitung
  vGedrucktePos     : int;
  vVerpCheck        : alpha;
  vVerpUsed         : alpha;
  vBAGPrinted       : logic;
end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
local begin
  vBuf100 : int;
end;
begin
  vBuf100 # RekSave(100);
  RecBufClear(100);
  if (Mat.KommKundennr<>0) then
    RecLink(100,200,7,_RecFirst);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN cnvAI(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
begin
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vBuf200     : int;
end;
begin

  form_FaxNummer  # '';//'11';
  Form_EMA        # '';//'mk@stahl-control.de';
  Form_Betreff    # 'Material'+aint(Mat.Nummer);

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();


  pls_fontSize # 14;
  pls_FontAttr # _WinFontAttrBold;
  //PL_Print('M A T E R I A L K A R T E ' + AInt(Mat.Nummer) ,cPos1);
  PL_Print('Materialkarte ' + AInt(Mat.Nummer) ,cPosH0);
  PL_PrintLine;
  if ("Mat.Löschmarker" = '*') then begin
    PL_Print('!!!GELÖSCHT!!!'          ,cPosH0);
    PL_PrintLine;
  end;
  pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;

  /*
  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
  end; // 1.Seite
  */

  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # n;
    pls_FontSize  # 9;
    // PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;

end;


//========================================================================
//  Hauptdaten
//
//========================================================================
sub Hauptdaten()
local begin
  erx     : int;
  vText   : alpha(120);
end;
begin
  pls_fontSize # 12;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print('Hauptdaten',cPosH0);
  PL_PrintLine;
  pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;

  PL_Print('Vorgänger:'                ,cPosH1);
  PL_Print(AInt("Mat.Vorgänger")     ,cPosH2);
  PL_Print('Ursprung:'                 ,cPosH3);
  PL_Print(AInt(Mat.Ursprung)        ,cPosH4);
  PL_PrintLine;

  vText # ''
  PL_Print('Güte:'                     ,cPosH1);
  if("Mat.Gütenstufe" <> '') then
    vText # vText + "Mat.Gütenstufe";
  if(vText <> '') then
    vText # vText + '';
  if("Mat.Güte" <> '') then
    vText # vText + "Mat.Güte";
  PL_Print(vText           ,cPosH2);
  PL_PrintLine;
  vText # ''

  PL_Print('Warengruppe:'              ,cPosH1);
  PL_Print('(' + cnvAI(Mat.Warengruppe) + ') ' + Wgr.Bezeichnung.L1              ,cPosH2);
  PL_PrintLine;

  Erx # RecLink(820, 200, 9, _recFirst); // Status
  if(Erx > _rLocked) then
    RecBufClear(820);
  PL_Print('Status:'                     ,cPosH1);
  PL_Print('(' + AInt(Mat.Status) + ') '+ Mat.Sta.Bezeichnung     ,cPosH2);
  PL_PrintLine;

  PL_Print('Ausf. Oben:'                 ,cPosH1);
  PL_Print("Mat.AusführungOben"         ,cPosH2);
  PL_PrintLine;

  PL_Print('Ausf. Unten:'                ,cPosH1);
  PL_Print("Mat.AusführungUnten"        ,cPosH2);
  PL_PrintLine;

  PL_Print('Eigenmaterial:'                             , cPosH1);
  if (Mat.EigenmaterialYN = true) then
    PL_Print('JA seit ' + cnvAD("Mat.Übernahmedatum")   , cPosH2);
  else
    PL_Print('NEIN'    , cPosH2);
  PL_PrintLine;

  PL_Print('Lieferant:'                  ,cPosH1);
  Erx # RecLink(100, 200, 4, 0);
  if(Erx > _rLocked) then
    RecBufClear(100);
  PL_Print('(' + cnvAI(Mat.Lieferant) + ') ' + Adr.Stichwort     ,cPosH2);
  PL_PrintLine;

  Erx # RecLink(100, 200, 5, _recFirst); // Lageradresse
  if(Erx > _rLocked) then
    RecBufClear(100);
  PL_Print('Lagerort:'                   ,cPosH1);
  PL_Print(Mat.LagerStichwort           ,cPosH2);
  PL_PrintLine;

  Erx # RecLink(100, 200, 7, _recFirst); // Kommission
  if((Erx > _rLocked) or (Mat.KommKundennr = 0)) then
    RecBufClear(100);
  PL_Print('Kommission:'                           ,cPosH1);
  PL_Print(Mat.Kommission + ' ' + Adr.Stichwort    ,cPosH2);
  PL_PrintLine;

  PL_PrintLine;

  PL_Print_R('mm'                       ,cPosHAbm2);
  PL_Print('Toleranzen'                 ,cPosHAbm3);
  PL_Print('gemessene Werte:'         ,cPosH3);
  PL_PrintLine;
  PL_Print('Dicke:'                      ,cPosHAbm1);
  PL_PrintF(Mat.Dicke, Set.Stellen.Dicke ,cPosHAbm2);
  PL_Print(Mat.Dickentol                ,cPosHAbm3);
  PL_PrintF(Mat.Dicke.Von, Set.Stellen.Dicke         ,cPosHAbm4);
  PL_PrintF(Mat.Dicke.Bis, Set.Stellen.Dicke         ,cPosHAbm5);
  PL_PrintLine;
  PL_Print('Breite:'                     ,cPosHAbm1);
  PL_PrintF(Mat.Breite, Set.Stellen.Breite       ,cPosHAbm2);
  PL_Print(Mat.Breitentol               ,cPosHAbm3);
  PL_PrintF(Mat.Breite.Von, Set.Stellen.Breite        ,cPosHAbm4);
  PL_PrintF(Mat.Breite.Bis, Set.Stellen.Breite        ,cPosHAbm5);
  PL_PrintLine;
  PL_Print('Länge:'                      ,cPosHAbm1);
  PL_PrintF("Mat.Länge", "Set.Stellen.Länge"           ,cPosHAbm2);
  PL_Print("Mat.Längentol"              ,cPosHAbm3);
  PL_PrintF("Mat.Länge.Von", "Set.Stellen.Länge"       ,cPosHAbm4);
  PL_PrintF("Mat.Länge.Bis", "Set.Stellen.Länge"       ,cPosHAbm5);
  PL_PrintLine;
  PL_PrintLine;

  PL_Print('Gewicht:'                ,cPosH1);
  PL_Print(ANum(Mat.Bestand.Gew, Set.Stellen.Gewicht) + 'kg' ,cPosH2);
  PL_PrintLine;
  PL_PrintLine;

  PL_Print('Coilnummer:'                ,cPosH1);
  PL_Print(Mat.Coilnummer               ,cPosH2);
  PL_Print('Ringnummer:'                ,cPosH3);
  PL_Print(Mat.Ringnummer               ,cPosH4);
  PL_PrintLine;
  PL_Print('Chargennummer:'             ,cPosH1);
  PL_Print(Mat.Chargennummer            ,cPosH2);
  PL_Print('Werksnummer:'               ,cPosH3);
  PL_Print(Mat.Werksnummer              ,cPosH4);
  PL_PrintLine;
  PL_Print('Intrastatnummer:'              ,cPosH1);
  PL_Print(Mat.Intrastatnr              ,cPosH2);
  PL_Print('Strukturnummer:'               ,cPosH3);
  PL_Print(Mat.Strukturnr               ,cPosH4);
  PL_PrintLine;
  PL_Print('Zeugnisart:'                ,cPosH1);
  PL_Print(Mat.Zeugnisart               ,cPosH2);
  PL_Print('Zeugnisakte:'               ,cPosH3);
  PL_Print(Mat.Zeugnisakte              ,cPosH4);
  PL_PrintLine;
  
  // ST 2019-04-15 Projekt 1937/13
  PL_Print('Bemerkung:'                 ,cPosH1);
  PL_Print(Mat.Bemerkung1               ,cPosH2);
  PL_PrintLine;
  PL_Print(Mat.Bemerkung2               ,cPosH2);
  PL_PrintLine;
  
  PL_PrintLine;

  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln();
  PL_PrintLine;
end;


//========================================================================
//  Bewegung
//
//========================================================================
sub Bewegung();
local begin
  Erx : int;
end;
begin
  pls_fontSize # 12;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print('Bewegungsdaten',cPosH0);
  PL_PrintLine;
  pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;

  PL_Print('Bestellnummer:'              ,cPosB1);
  PL_Print(Mat.Bestellnummer            ,cPosB2);
  PL_Print('Bestelldatum:'               ,cPosB3);
  PL_Print(cnvAD(Mat.Bestelldatum)      ,cPosB4);
  PL_PrintLine;
  PL_Print('Lief.-AB-Nr.:'               ,cPosB1);
  PL_Print(Mat.BestellABNr              ,cPosB2);
  PL_Print('Bestelltermin:'              ,cPosB3);
  PL_Print(cnvAD(Mat.Bestelltermin)     ,cPosB4);
  PL_PrintLine;

  Erx # RecLink(501, 200, 18, 0); // Ein.P
  if(Erx > _rLocked) then
    RecBufClear(501);
  Erx # RecLink(500, 501, 3, 0); // Ein.Kopf
  if(Erx > _rLocked) then
    RecBufClear(500);
  PL_Print('Projektnummer:'              ,cPosB1);
  PL_Print(cnvAI(Ein.P.Projektnummer)   ,cPosB2);
  PL_Print('EK-Steuerschl.:'             ,cPosB3);
  PL_Print(cnvAI("Ein.Steuerschlüssel") ,cPosB4);
  PL_PrintLine;

  PL_PrintLine;


  Erx # RecLink(100,200,5,0);
  if(Erx > _rLocked) then
    RecBufClear(100);
  Erx # RecLink(101,200,6,0);
  if(Erx > _rLocked) then
    RecBufClear(101);
  PL_Print('Lagerort:'                   ,cPosB1);
  PL_Print('(' + cnvAI(Mat.Lageradresse) + '/' + cnvAI(Mat.Lageranschrift) + ') ' + Adr.A.Name + ' ' + Adr.A.Ort  ,cPosB2);
  PL_PrintLine;

  PL_Print('Ein-/Ausgang:'               ,cPosB1);
  PL_Print(cnvAD(Mat.Eingangsdatum) + ' - ' + cnvAD(Mat.Ausgangsdatum)  ,cPosB2);
  PL_Print('Erzeugt am:'                 ,cPosB3);
  PL_Print(cnvAD(Mat.Datum.Erzeugt)     ,cPosB4);
  PL_PrintLine;

  PL_Print('Lagerplatz:'                 ,cPosB1);
  PL_Print(Mat.Lagerplatz               ,cPosB2);
  PL_Print('Letztes Lagergeld am:'       ,cPosB3);
  PL_Print(cnvAD(Mat.Datum.Lagergeld)   ,cPosB4);
  PL_PrintLine;

  PL_Print('Inventur:'                   ,cPosB1);
  PL_Print(cnvAD(Mat.Inventurdatum)     ,cPosB2);
  PL_Print('Letzte Zinsen am:'           ,cPosB3);
  PL_Print(cnvAD(Mat.Datum.Zinsen)      ,cPosB4);
  PL_PrintLine;

  Erx # RecLink(100,200,4,0); // Lieferant
  if(Erx > _rLocked) then
    RecBufClear(100);
  PL_Print('Lieferant:'                  ,cPosB1);
  PL_Print('(' + cnvAI(Mat.Lieferant) + ') ' + Adr.Name + ' ' + Adr.Ort, cPosB2);
  PL_PrintLine;

  Erx # RecLink(100,200,3,0); // Erzeuger
  if(Erx > _rLocked) then
    RecBufClear(100);
  PL_Print('Erzeuger:'                   ,cPosB1);
  PL_Print('(' + cnvAI(Mat.Erzeuger) + ') ' + Adr.Name + ' ' + Adr.Ort ,cPosB2);
  PL_PrintLine;

  Erx # RecLink(812,200,2,0); // Ursprungsland
  if(Erx > _rLocked) then
    RecBufClear(812);
  PL_Print('Ursprungsland:'              ,cPosB1);
  PL_Print(Lnd.Name.L1                  ,cPosB2);
  PL_PrintLine;
  PL_Print('VK Rechn.Nr.:'               ,cPosB1);
  PL_Print(cnvAI(Mat.VK.Rechnr) + ' vom ' + cnvAD(Mat.VK.Rechdatum)  ,cPosB2);
  Erx # RecLink(100, 200, 7, _recFirst); // Komm. Kd.
  if((Erx > _rLocked) or (Mat.VK.Kundennr = 0)) then
    RecBufClear(100);
  PL_Print('an Kunde:'                   ,cPosB3);
  PL_Print('(' + cnvAI(Mat.VK.Kundennr) + ') ' + Adr.Stichwort ,cPosB4);
  PL_PrintLine;
  PL_Print('EK Rechn.Nr.:'               ,cPosB1);
  PL_Print(cnvAI(Mat.EK.Rechnr) + ' vom ' + cnvAD(Mat.EK.Rechdatum), cPosB2);
  PL_PrintLine;
  PL_PrintLine;


  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln();
  PL_PrintLine;
end;


//========================================================================
//  Analyse
//
//========================================================================
sub Analyse
begin
  pls_fontSize # 12;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print('Analyse',cPosH0);
  PL_PrintLine;
  pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;

  // ==== Block 2 ====
  PL_Print('1. Messung'                 ,cPosB1);
  PL_PrintLine;

  PL_Print('Streckg.(ReH):'                        ,cPosB1);
  PL_Print(cnvAF(Mat.Streckgrenze1) + ' N/mm² - ' + cnvAF(Mat.StreckgrenzeB1) + ' N/mm²'        ,cPosB2);
  PL_Print('Zugfest.(Rm):'                         ,cPosB3);
  PL_Print(cnvAF(Mat.Zugfestigkeit1) + ' N/mm² - ' + cnvAF(Mat.ZugfestigkeitB1) + ' N/mm²'        ,cPosB4);
  PL_PrintLine;

  PL_Print('Dehnung:'                              ,cPosB1);
  if (Set.Mech.Dehnung.Wie=1) then
    PL_Print('A'+anum(Mat.DehnungA1,2) + ' = ' + ANum(Mat.DehnungB1,2) + ' - '+ANum(Mat.DehnungC1,2)+ '%'  ,cPosB2)
  else
    PL_Print(ANum(Mat.DehnungA1,2) + ' % / A' + ANum(Mat.DehnungB1,2)    ,cPosB2);

  if ("Set.Mech.Titel.Härte" = '') then
    PL_Print('Härte:'                               ,cPosB3);
  else
    PL_Print("Set.Mech.Titel.Härte"+ ':'            ,cPosB3);
  PL_Print(cnvAF("Mat.HärteA1") + ' - ' + cnvAF("Mat.HärteB1")         ,cPosB4);
  PL_PrintLine;

  PL_Print('Rp 0,2:'                               ,cPosB1);
  PL_Print(cnvAF("Mat.RP02_V1") + ' - ' + cnvAF("Mat.RP02_B1")         ,cPosB2);
  PL_Print('Rp 10:'                                ,cPosB3);
  PL_Print(cnvAF("Mat.RP10_V1") + ' - ' + cnvAF("Mat.RP10_B1")         ,cPosB4);
  PL_PrintLine;

  if (Set.Mech.Titel.Rau1 = '') then
    PL_Print('Rauhigkeit OS:'              ,cPosB1);
  else
    PL_Print(Set.Mech.Titel.Rau1    +':'              ,cPosB1);
  PL_Print(cnvAF(Mat.RauigkeitA1) + ' - ' + cnvAF(Mat.RauigkeitB1)        ,cPosB2);

  if (Set.Mech.Titel.Rau2 = '') then
    PL_Print('Rauhigkeit US:'              ,cPosB3);
  else
    PL_Print(Set.Mech.Titel.Rau2 + ':'      ,cPosB3);
  PL_Print(cnvAF(Mat.RauigkeitC1) + ' - ' + cnvAF(Mat.RauigkeitD1)      ,cPosB4);
  PL_PrintLine;

  if ("Set.Mech.Titel.Körn" = '') then
    PL_Print('Körnung:'                 ,cPosB1);
  else
    PL_Print("Set.Mech.Titel.Körn"+':'  ,cPosB1);
  PL_Print(cnvAF("Mat.Körnung1")                  ,cPosB2);

  if (Set.Mech.Titel.Sonst = '') then
    PL_Print('Sonstiges:'                           ,cPosB3);
  else
    PL_Print(Set.Mech.Titel.Sonst+':'                           ,cPosB3);
  PL_Print(Mat.Mech.Sonstiges1                    ,cPosB4);
  PL_PrintLine;

  PL_Print('C:'                          ,cPos0);
  PL_Print(ANum(Mat.Chemie.C1, 3)         ,cPos1);
  PL_Print('Si:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Si1, 3)        ,cPos3);
  PL_Print('Mn:'                         ,cPos4);
  PL_Print(ANum(Mat.Chemie.Mn1, 3)        ,cPos5);
  PL_Print('P:'                          ,cPos6);
  PL_Print(ANum(Mat.Chemie.P1, 3)         ,cPos7);
  PL_PrintLine;

  PL_Print('S:'                          ,cPos0);
  PL_Print(ANum(Mat.Chemie.S1, 3)         ,cPos1);
  PL_Print('Al:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Al1, 3)        ,cPos3);
  PL_Print('Cr:'                         ,cPos4);
  PL_Print(ANum(Mat.Chemie.Cr1, 3)        ,cPos5);
  PL_Print('V:'                          ,cPos6);
  PL_Print(ANum(Mat.Chemie.V1, 3)         ,cPos7);
  PL_PrintLine;

  PL_Print('Nb:'                         ,cPos0);
  PL_Print(ANum(Mat.Chemie.Nb1, 3)        ,cPos1);
  PL_Print('Ti:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Ti1, 3)        ,cPos3);
  PL_Print('N:'                          ,cPos4);
  PL_Print(ANum(Mat.Chemie.N1, 3)         ,cPos5);
  PL_Print('Cu:'                         ,cPos6);
  PL_Print(ANum(Mat.Chemie.Cu1, 3)        ,cPos7);
  PL_PrintLine;

  PL_Print('Ni:'                         ,cPos0);
  PL_Print(ANum(Mat.Chemie.Ni1, 3)        ,cPos1);
  PL_Print('Mo:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Mo1, 3)        ,cPos3);
  PL_Print('B:'                          ,cPos4);
  PL_Print(ANum(Mat.Chemie.B1, 3)         ,cPos5);
  PL_Print('?:'                          ,cPos6);
  PL_Print(ANum(Mat.Chemie.Frei1.1, 3)    ,cPos7);
  PL_PrintLine;

  PL_PrintLine;


  PL_Print('Analysenummer'              ,cPosB1);
  PL_Print(AInt(Mat.Analysenummer)     ,cPosB2);
  PL_PrintLine;


  PL_Print('2. Messung'                 ,cPosB1);
  PL_PrintLine;

  PL_Print('Streckg.(ReH):'                        ,cPosB1);
  PL_Print(cnvAF(Mat.Streckgrenze2) + ' N/mm² - ' + cnvAF(Mat.StreckgrenzeB2) + ' N/mm²'        ,cPosB2);
  PL_Print('Zugfest.(Rm):'                         ,cPosB3);
  PL_Print(cnvAF(Mat.Zugfestigkeit2) + ' N/mm² - ' + cnvAF(Mat.ZugfestigkeitB2) + ' N/mm²'        ,cPosB4);
  PL_PrintLine;

  PL_Print('Dehnung:'                              ,cPosB1);
  PL_Print(cnvAF(Mat.DehnungA2) + ' N/mm² / A ' + aNum(Mat.DehnungB2,0) ,cPosB2);


  if ("Set.Mech.Titel.Härte" = '') then
    PL_Print('Härte:'                               ,cPosB3);
  else
    PL_Print("Set.Mech.Titel.Härte"+ ':'            ,cPosB3);
  PL_Print(cnvAF("Mat.HärteA2") + ' - ' + cnvAF("Mat.HärteB2")         ,cPosB4);
  PL_PrintLine;

  PL_Print('Rp 0,2:'                               ,cPosB1);
  PL_Print(cnvAF("Mat.RP02_V2") + ' - ' + cnvAF("Mat.RP02_B2")         ,cPosB4);
  PL_Print('Rp 10:'                                ,cPosB3);
  PL_Print(cnvAF("Mat.RP10_V2") + ' - ' + cnvAF("Mat.RP10_B2")         ,cPosB4);
  PL_PrintLine;

  if (Set.Mech.Titel.Rau1 = '') then
    PL_Print('Rauhigkeit OS:'              ,cPosB1);
  else
    PL_Print(Set.Mech.Titel.Rau1    +':'              ,cPosB1);
  PL_Print(cnvAF(Mat.RauigkeitA2) + ' - ' + cnvAF(Mat.RauigkeitB2)        ,cPosB2);


  if (Set.Mech.Titel.Rau2 = '') then
    PL_Print('Rauhigkeit US:'              ,cPosB3);
  else
    PL_Print(Set.Mech.Titel.Rau2 + ':'      ,cPosB3);
  PL_Print(cnvAF(Mat.RauigkeitC2) + ' - ' + cnvAF(Mat.RauigkeitD2)      ,cPosB4);
  PL_PrintLine;

  if ("Set.Mech.Titel.Körn" = '') then
    PL_Print('Körnung:'                 ,cPosB1);
  else
    PL_Print("Set.Mech.Titel.Körn"+':'  ,cPosB1);
  PL_Print(cnvAF("Mat.Körnung2")                  ,cPosB2);

  if (Set.Mech.Titel.Sonst = '') then
    PL_Print('Sonstiges:'                           ,cPosB3);
  else
    PL_Print(Set.Mech.Titel.Sonst+':'                           ,cPosB3);
  PL_Print(Mat.Mech.Sonstiges2                    ,cPosB4);
  PL_PrintLine;

  PL_Print('C:'                          ,cPos0);
  PL_Print(ANum(Mat.Chemie.C2, 3)         ,cPos1);
  PL_Print('Si:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Si2, 3)        ,cPos3);
  PL_Print('Mn:'                         ,cPos4);
  PL_Print(ANum(Mat.Chemie.Mn2, 3)        ,cPos5);
  PL_Print('P:'                          ,cPos6);
  PL_Print(ANum(Mat.Chemie.P2, 3)         ,cPos7);
  PL_PrintLine;

  PL_Print('S:'                          ,cPos0);
  PL_Print(ANum(Mat.Chemie.S2, 3)         ,cPos1);
  PL_Print('Al:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Al2, 3)        ,cPos3);
  PL_Print('Cr:'                         ,cPos4);
  PL_Print(ANum(Mat.Chemie.Cr2, 3)        ,cPos5);
  PL_Print('V:'                          ,cPos6);
  PL_Print(ANum(Mat.Chemie.V2, 3)         ,cPos7);
  PL_PrintLine;

  PL_Print('Nb:'                         ,cPos0);
  PL_Print(ANum(Mat.Chemie.Nb2, 3)        ,cPos1);
  PL_Print('Ti:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Ti2, 3)        ,cPos3);
  PL_Print('N:'                          ,cPos4);
  PL_Print(ANum(Mat.Chemie.N2, 3)         ,cPos5);
  PL_Print('Cu:'                         ,cPos6);
  PL_Print(ANum(Mat.Chemie.Cu2, 3)        ,cPos7);
  PL_PrintLine;

  PL_Print('Ni:'                         ,cPos0);
  PL_Print(ANum(Mat.Chemie.Ni2, 3)        ,cPos1);
  PL_Print('Mo:'                         ,cPos2);
  PL_Print(ANum(Mat.Chemie.Mo2, 3)        ,cPos3);
  PL_Print('B:'                          ,cPos4);
  PL_Print(ANum(Mat.Chemie.B2, 3)         ,cPos5);
  PL_Print('?:'                          ,cPos6);
  PL_Print(ANum(Mat.Chemie.Frei1.2, 3)    ,cPos7);
  PL_PrintLine;
  PL_PrintLine;

  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln();
  PL_PrintLine;
end;


//========================================================================
//  Sonstiges
//
//========================================================================
sub Sonstiges
local begin
  Erx : int;
end;
begin
  pls_fontSize # 12;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print('Sonstiges',cPosH0);
  PL_PrintLine;
  pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;

  PL_Print('Verwiegung'             ,cPosB1);
  PL_PrintLine;
  Erx # RecLink(818,200,10,0)
  if(Erx > _rLocked) then
    RecBufClear(818);
  PL_Print('Verwieg.Art:'            ,cPosB1);
  PL_Print(AInt(Mat.Verwiegungsart) + Vwa.Bezeichnung.L1,cPosB2);
  PL_PrintLine;

  PL_Print('Gewicht netto:'          ,cPosB1);
  PL_Print(ANum(Mat.Gewicht.Netto, Set.Stellen.Gewicht) + 'kg', cPosB2);
  PL_Print('Gewicht brutto:'         ,cPosB3);
  PL_Print(ANum(Mat.Gewicht.Brutto, Set.Stellen.Gewicht) + 'kg', cPosB4);
  PL_PrintLine;

  PL_PrintLine;

  PL_Print('Verpackung'             ,cPosB1);
  PL_PrintLine;
  PL_Print('Zwischenlage:'           ,cPosB1);
  PL_Print(Mat.Zwischenlage         ,cPosB2);
  PL_PrintLine;
  PL_Print('Abbind.längs:'           ,cPosB1);
  PL_Print(cnvAI(Mat.AbbindungL)    ,cPosB2);
  if (Mat.StehendYN = true) then
    PL_Print('STEHEND'              ,cPosB3)
  else if (Mat.LiegendYN = true) then
    PL_Print('LIEGEND'              ,cPosB3);
  PL_PrintLine;
  PL_Print('Unterlage:'              ,cPosB1);
  PL_Print(Mat.Unterlage            ,cPosB2);
  PL_PrintLine;
  PL_Print('Abbind.Quer:'            ,cPosB1);
  PL_Print(cnvAI(Mat.AbbindungQ)    ,cPosB2);
  PL_Print('Stapelhöhe:'             ,cPosB3);
  PL_Print(cnvAF("Mat.Stapelhöhe")  ,cPosB4);
  PL_PrintLine;
  PL_Print('in Paketnr:'                 ,cPosB1);
  PL_Print(cnvAI(Mat.Paketnr)            ,cPosB2);
  PL_Print('Höhenabzug:'                 ,cPosB3);
  PL_Print(cnvAF("Mat.Stapelhöhenabzug") ,cPosB4);
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Etikettierung'          ,cPosB1);
  PL_PrintLine;
  PL_Print('Dicke'                  ,cPosB1);
  PL_Print(cnvAF(Mat.Etk.Dicke)     ,cPosB2);
  PL_PrintLine;
  PL_Print('Breite'                 ,cPosB1);
  PL_Print(cnvAF(Mat.Etk.Breite)    ,cPosB2);
  PL_PrintLine;
  PL_Print('Länge'                  ,cPosB1);
  PL_Print(cnvAF("Mat.Etk.Länge")   ,cPosB2);
  PL_PrintLine;
  PL_Print('Güte'                   ,cPosB1);
  PL_Print("Mat.Etk.Güte"           ,cPosB2);
  PL_PrintLine;

  PL_PrintLine;

  PL_Print('Sonstiges'              ,cPosB1);
  PL_PrintLine;
  PL_Print('Rechtwinkligk.'         ,cPosB1);
  PL_Print(cnvAF(Mat.Rechtwinkligkeit)        ,cPosB2);
  If (Mat.QS.FehlerYN = Y) then
    PL_Print('FEHLERHAFT'           ,cPosB3);
  PL_PrintLine;
  PL_Print('Ebenheit'               ,cPosB1);
  PL_Print(cnvAF(Mat.Ebenheit)      ,cPosB2);
  PL_PrintLine;
  PL_Print('Säbeligkeit'            ,cPosB1);
  PL_Print(cnvAF("Mat.Säbeligkeit") ,cPosB2);
  PL_PrintLine;

  PL_PrintLine;

  PL_Print('QS'                     ,cPosB1);
  PL_PrintLine;
  PL_Print('Datum'                  ,cPosB1);
  PL_Print(cnvAD(Mat.QS.Datum)      ,cPosB2);
  PL_Print('Zeit'                  ,cPosB3);
  PL_Print(cnvat(Mat.QS.Zeit)      ,cPosB4);
  PL_PrintLine;
  PL_Print('User'                  ,cPosB1);
  PL_Print(Mat.QS.User             ,cPosB2);
  PL_Print('Status'                 ,cPosB3);
  PL_Print(cnvAI(Mat.QS.Status)     ,cPosB4);
  PL_PrintLine;
  PL_PrintLine;

  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln();
  PL_PrintLine;
End;


//========================================================================
//  Bild
//
//========================================================================
sub Bild()
local begin
  vPicWidth  : float;
  vPicHeight : float;
end;
begin
  pls_fontSize # 12;
  pls_FontAttr # _WinFontAttrBold;
  PL_Print('Bild',cPosB1);
  PL_PrintLine;
  pls_fontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;
  PL_Print('Bilddatei: ' ,cPosB1);
  PL_Print(Mat.Bilddatei ,cPosB2);
  PL_PrintLine;
  /*
  vPicWidth  # $pdf.Materialpic->wpPicWidth;
  vPicHeight # $pdf.Materialpic->wpPicHeight;
  Lib_PrintLine:PrintPic(cPosB1, vPicWidth, vPicHeight, '*' + Mat.Bilddatei);
  PL_PrintLine;
  */

  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln();
  PL_PrintLine;
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vText     : alpha;
  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;
  vPoint    : point;
  vName     : alpha;
  vBuf      : int;
end;
begin

  case aTyp of

    'Hauptdaten' : begin
      Hauptdaten();
    end;

    'Bewegung' : begin
      Bewegung();
    end;

    'Analyse' : begin
      Analyse();
    end;

    'Sonstiges' : begin
      Sonstiges()
    end;

    'Bild' : begin
      Bild();
    end;
  end; // case
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
end;
begin
  RecBufClear(999);



  GV.Logic.01 # true;  //cHauptdatenYN
  GV.Logic.02 # true;  //cBewegungYN
  GV.Logic.03 # true;  //cAnalyseYN
  GV.Logic.04 # true;  //cSonstigesYN
  GV.Logic.05 # true;  //cBildYN

  if (aFilename = '') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mat.MatKarte',here+':PrintMain');
    gMDI->wpcaption # Lfm.Name;
    Lib_GuiCom:RunChildWindow(gMDI);
  end else begin
    PrintMain(aFilename);
  end;


end;

//=======================================================================


//========================================================================
//  PrintMain
//
//========================================================================
sub PrintMain (opt aFilename : alpha(4096))
local begin
  Erx                 : int;
  // Datenspezifische Variablen
  vTxtName            : alpha;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
end;
begin
// ------ Druck vorbereiten ----------------------------------------------------------------

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter, false, true, false) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  form_randOben   # rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 15.0));
  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  //form_RandOben   # rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0));

  // ARCFLOW
  //DMS_ArcFlow:SetDokName('!SC\Verkauf','AB',Auf.Nummer);

  Erx # RecLink(819, 200, 1, _recFirst); // Warengruppe
  if(Erx > _rLocked)then
    RecBufClear(819);

  //Seitenkopf(1);
  Lib_Print:Print_Seitenkopf();

  if(cHauptdatenYN = true) then
    Print('Hauptdaten');

  if(cBewegungYN = true) then
    Print('Bewegung');

  if(cAnalyseYN = true) then
    Print('Analyse');

  if(cSonstigesYN = true) then
    Print('Sonstiges');

  if(cBildYN = true) then
    Print('Bild');

// -------- Druck beenden ----------------------------------------------------------------

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;


//=======================================================================
//=======================================================================
