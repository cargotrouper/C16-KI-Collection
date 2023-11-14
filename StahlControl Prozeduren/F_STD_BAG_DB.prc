@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_BAG_DB
//                      OHNE E_R_G
//  Info
//    Druckt Deckblatt aus
//
//  03.04.2008  DS
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cLH       : 4.3   // Höhe einer vertikalen Linie (quasi Zeilenhöhe)

  cPosFuss1 : 10.0
  cPosFuss2 : 35.0

  cPosKopf1 : 2.0
  cPosKopf2 : cPosKopf1 + 70.0
  cPosKopf3 : cPosKopf2 + 70.0
  cPosKopf4 : cPosKopf3 + 70.0
  cPosKopf5 : cPosKopf4 + 30.0

  cPosE0   : 2.0             //
  cPosE1   : cPosE0  + 38.0  // Bearbeitungsschritt
  cPosE2   : cPosE1  + 25.0  // Coilnummer
  cPosE3   : cPosE2  + 30.0  // Dicke x Breite
  cPosE4   : cPosE3  + 10.0  // Stück
  cPosE5   : cPosE4  + 20.0  // Gewicht
  cPosE6   : cPosE5  + 35.0  // Lagerplatz
  cPosE7   : cPosE6  + 10.0  // RID
  cPosE8   : cPosE7  + 10.0  // RAD
  cPosE9  : cPosE8  + 35.0  // Oberfläche
  cPosE10  : cPosE9 + 25.0  // Qualität
  cPosE11  : cPosE10 + 10.0  // Zug1
  cPosE12  : cPosE11 + 10.0  // Zug2
  cPosE13  : cPosE12 + 15.0  // MatNr

end;

local begin
  vZeilenZahl     : int;
  vCoord          : float;
  vSumStk         : int;
  vSumGewichtN    : float;
  vSumGewichtB    : float;
  vSumBreite      : float;
  vAnzBreite      : float;
  vSumLaenge      : float;
  vWtrverb        : alpha;
  vText3          : alpha;
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
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(BAG.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
//  RETURN CnvAI(BAG.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)+'/'CnvAI(BAG.P.Position,_FmtNumNoGroup | _FmtNumLeadZero,0,3);      // Dokumentennummer
end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  Erx       : int;
  vVerp     : alpha(1000);
  vText     : alpha;
  vFlag     : int;
  vMerker   : alpha;
  vPoint    : point;
  vName     : alpha;
  vBuf      : int;
end;
begin

  case aTyp of

    'Einsatzkopf' : begin
      pls_FontSize  # 10;
      //PL_Print('Einsatzmaterial',cPosE0);
      //PL_PrintLine;
      pls_FontSize  # 8;
      pls_Inverted  # y;

      PL_Print('Bearbeitungsschritt',             cPosE0 + 2.0);
      PL_Print('Coil-Nr.',                        cPosE1 + 2.0);
      PL_Print('Dicke x Breite',                  cPosE2 + 2.0);
      //PL_Print_R('Breite',                        cPosE4);
      PL_Print_R('Stk.',                          cPosE4);
      PL_Print_R('Gewicht kg',                    cPosE5);
      PL_Print('Lagerplatz',                      cPosE5 + 2.0);
      PL_Print_R('RID',                           cPosE7);
      PL_Print_R('RAD',                           cPosE8);
      PL_Print('Oberfläche',                      cPosE8 + 2.0);
      PL_Print('Qualität',                        cPosE9 + 2.0);
      PL_Print_R('Zug1',                          cPosE11);
      PL_Print_R('Zug2',                          cPosE12);
      PL_Print_R('Mat.Nr.',                       cPosE13);

      PL_Drawbox(cPosE0+1.0, cPosE13+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Einsatz' : begin
      pls_FontSize  # 8;
      RecLink(828,702,8,0);
      PL_Print(AInt(BAG.P.Position) + '  ' + ArG.Bezeichnung, cPosE0 + 6.0);
      //Materialdatei
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
      PL_Print(Mat.Coilnummer,                            cPosE1 + 2.0);

      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
           ANum(Mat.Breite,Set.Stellen.Breite);
      PL_Print(vText,                                     cPosE2 + 2.0);
      PL_PrintI(BAG.IO.Plan.Out.Stk,                          cPosE4);
      PL_PrintF(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht,  cPosE5);
      PL_Print(Mat.Lagerplatz,                            cPosE5 + 2.0);
      PL_PrintF(Mat.RID, 0,                               cPosE7);
      PL_PrintF(Mat.RAD, 0,                               cPosE8);

      // Ausführung übersetzen für Oberfläche SOLL
      vText3 # '';
      if ("Mat.AusführungOben" <> '') then begin
        Erx # RecLink(201,200,11,_RecFirst);
        While (Erx <= _rLocked) DO BEGIN
          if (Mat.AF.Seite = '1') then vText3 # vText3 + Mat.AF.Bezeichnung + ', '
          Erx # RecLink(201,200,11,_RecNext);
        END;
      end;

      //letztes Komma entfernen
      vText3 # StrCut(vText3,1,StrLen(vText3)-2);
      PL_Print(vText3,                                    cPosE8 + 2.0);
      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText # vText +  ' / ' + StrAdj("Mat.Gütenstufe",_StrEnd);
      PL_Print(vText,                                     cPosE9 + 2.0);
      PL_PrintF(Mat.Zugfestigkeit1, 0,                    cPosE11);
      PL_PrintF(Mat.Zugfestigkeit2, 0,                    cPosE12);
      PL_PrintI(Mat.Nummer,                               cPosE13);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;
    end; // EO Einsatz

/*
    'Weiterbearb.-Einsatz1' : begin
/*  DEAKTIVIERT ST, -> macht keinen Sinn
      vBuf # rekSave(701);
      reclink(701,703,3,_recfirst);
      vWtrverb # cnvai(bag.io.vonBAG) + '/' + cnvai(bag.io.vonPosition) + '/' + cnvai(bag.io.vonFertigung);
      RekRestore(vBuf);
*/
      vWtrverb # cnvai(bag.io.vonBAG) + '/' + cnvai(bag.io.vonPosition) + '/' + cnvai(bag.io.vonFertigung);

      pls_FontSize  # 8;

      PL_PrintI(BAG.IO.Plan.In.Stk,  cPosE1);
      // Abmessung
      vText # CnvAf(BAG.IO.Dicke,_FmtNumNoGroup,0,Set.Stellen.Dicke) + ' x ' +
           CnvAf(BAG.IO.Breite,_FmtNumNoGroup,0,Set.Stellen.Breite);
      PL_Print(vText, cPosE1 + 2.0);
      //Gewicht brutto
      PL_PrintF(BAG.IO.Plan.In.GewB, Set.Stellen.Gewicht,  cPosE4);
      // Güte
      vText # StrAdj("BAG.IO.Güte",_StrEnd);
      PL_Print(vText,cPosE6 + 2.0);
      //PL_PrintI(Mat.Nummer,                               cPosE6);
      Lib_PrintLine:Print('aus' + ' ' + vWtrverb ,         cPosE6);
      //Ausführung oben
      PL_Print(BAG.IO.AusfOben, cPosE7 + 2.0);

      //PL_PrintI(BAG.IO.Teilungen,cPosE11);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;
    end;
*/
    'Einsatzfuss' : begin
      pls_FontSize  # 8;
      Lib_Print:Print_LinieEinzeln(cPosE0+1.0,cPosE13+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintI(vSumStk,cPosE4);
      PL_PrintF(vSumGewichtB, Set.Stellen.Gewicht, cPosE5);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosE0+1.0,cPosE13+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosE0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE1+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE2+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE3+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE4+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE5+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE6+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE7+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE8+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE9+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE10+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE11+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE12+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE13+1.0, cLH * cnvfi(vZeilenZahl+1));
      //Lib_Print:Print_LinieVEinzeln(cPosE14+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

  end;
end;

//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx       : int;
  vTxtName  : alpha;
  vText     : alpha(250);
  vText2    : alpha(250);
end;
begin

  Erx # RecLink(160,702,11,_RecFirst);      // Hauptressource holen
  if (Erx > _rLocked) then
    RecBufClear(160);

  Pls_fontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Deckblatt '+AInt(BAg.P.Nummer)+'/'+AInt(BAG.P.Position) ,cPosKopf1);
  //PL_Print(BAG.P.Bezeichnung,cPosKopf2);
  PL_Print('Maschine: '+AInt(Rso.Nummer)+' '+Rso.Stichwort,cPosKopf2);
  //PL_Print('Seite:'+AInt(aSeite),cPosKopf4);
  //lib_PrintLine:BarCode((BAG.P.Nummer*100) + BAG.P.Position, cPosKopf5,35.0,7.0);
  PL_PrintLine;
  pls_Fontattr # 0;

  Pls_FontSize # 9;
  PL_PrintLine;

  //PL_Print('Starttermin : '+cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit)+' '+BAG.P.Plan.StartInfo, cPosKopf1);
  //PL_Print('Endtermin : '+cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit)+' '+BAG.P.Plan.EndInfo, cPosKopf3);
  //PL_PrintLine;

  //PL_PrintLine;

  if (Form_Mode='EINSATZ') then     Print('Einsatzkopf');
  //if (Form_Mode='FERTIGUNG') then   Print('Fertigungkopf');
  //if (Form_Mode='VERPACKUNG') then  Print('Verpackungkopf');

end;

//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vFirst              : logic;
  vText               : alpha(250);

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vTxtHdl             : int;
  vVpg                : logic[100]; // Merker für Verpackungen
  i                   : int;        // für FOR-Schleife

end;
begin
// ------ Druck vorbereiten ----------------------------------------------------------------

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,n,n,y) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  form_RandOben # 0.0;      // Rand oben setzen
  form_RandOben # 56693.0;  // 10mm


  // LOOP **********************************************************
  Erx # RecLink(702,700,1,_recFirst);       // Positionen loopen
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.ExternYN) then begin          // externe überspringen
      Erx # RecLink(702,700,1,_recNext);
      CYCLE;
    end;
    if (BAG.P.Aktion=c_BAG_VSB) then begin  // VSBs überspringen
      Erx # RecLink(702,700,1,_recNext);
      CYCLE;
    end;


    // ------- KOPFDATEN -----------------------------------------------------------------------

    form_Mode # 'EINSATZ';
    if (vFirst=n) then begin
      vFirst # Y;
      Lib_Print:Print_Seitenkopf();
      end
    else begin
      //Lib_Print:Print_FF();     // Seitenvorschub auf folgenden Seiten
    end;

    // ------- EINSATZMATERIAL -----------------------------------------------------------------
    // Einsatzsummen bei jedem Arbeitsgang seperat summieren
    vSumStk         # 0;
    vSumGewichtN    # 0.0;
    vSumGewichtB    # 0.0;


    Erx # RecLink(701,702,2,_RecFirst);
    WHILE (Erx<=_rLocked) DO BEGIN
      // ECHTES Material?
      if (BAG.IO.Materialtyp=c_IO_Mat) then begin
        // Material lesen

        Print('Einsatz');
        // Summierung
        vSumStk         # vSumStk      + BAG.IO.Plan.Out.Stk;
        vSumGewichtN    # vSumGewichtN + BAG.IO.Plan.Out.GewN;
        vSumGewichtB    # vSumGewichtB + BAG.IO.Plan.Out.GewB;
      end;
/*
      else
      if (BAG.IO.Materialtyp=703) then begin

          Print('Weiterbearb.-Einsatz');

          // Summierung
          vSumStk         # vSumStk +      BAG.IO.Plan.In.Stk;
          vSumGewichtN    # vSumGewichtN + BAG.IO.Plan.In.GewN;
          vSumGewichtB    # vSumGewichtB + BAG.IO.Plan.In.GewB;
      end;
*/
      Erx # RecLink(701,702,2,_RecNext);
    END;
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      Print('Einsatzfuss');
      PL_PrintLine;
    end;
    //Print('Kopftext');



    // ------- FUßDATEN --------------------------------------------------------------------------
    form_Mode # 'FUSS';
    //Print('Fusstext');
    //Print('Tabelle');

    Erx # RecLink(702,700,1,_recNext); // Positionen loopen
  END; // Positionen loopen

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================