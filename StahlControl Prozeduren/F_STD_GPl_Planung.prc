@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_GPL_Planung
//                        OHNE E_R_G
//  Info
//    Druckt die Grobplanung aus
//
//
//  28.05.2007  AI  Erstellung der Prozedur
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
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cLH       : 4.3   // Höhe einer vertikalen Linie (quasi Zeilenhöhe)

  cPosFuss1 : 10.0
  cPosFuss2 : 35.0

  cPosKopf1 : 2.0
  cPosKopf2 : cPosKopf1 + 70.0
  cPosKopf3 : cPosKopf2 + 70.0
  cPosKopf4 : cPosKopf3 + 70.0

  cPosE0   : 2.0            //
  cPosE1   : cPosE0 + 10.0  // RF
  cPosE2   : cPosE1 + 60.0  // Abmessung
  cPosE3   : cPosE2 + 30.0  // Güte
  cPosE4   : cPosE3 + 20.0  // Matnr
  cPosE5   : cPosE4 + 40.0  // Charge
  cPosE6   : cPosE5 + 10.0  // Stück
  cPosE7   : cPosE6 + 20.0  // Gewicht

  cPosF0   : 2.0            //
  cPosF1   : cPosF0 + 10.0  // RF
  cPosF2   : cPosF1 + 60.0  // Abmessung
  cPosF3   : cPosF2 + 30.0  // Güte
  cPosF4   : cPosF3 + 60.0  // Auftrag
  cPosF5   : cPosF4 + 10.0  // Plan Stk
  cPosF6   : cPosF5 + 20.0  // Plan Gewicht
end;

local begin
  vZeilenZahl     : int;
  vCoord          : float;
  vSumStk         : int;
  vSumGewicht     : float;
  vSumBreite      : float;
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
  RETURN CnvAI(GPl.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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
end;
begin

  case aTyp of

    'Einsatzkopf' : begin
      pls_FontSize  # 10;
      PL_Print('Einsatz',cPosE0);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('RF',        cPosE1);
      PL_Print('Abmessung',   cPosE1 + 2.0);
      PL_Print('Qualität',    cPosE2);
      PL_Print_R('Mat.Nr.',   cPosE4);
      PL_Print('Coilnummer',  cPosE4 + 2.0);
      PL_Print_R('Stück'     ,cPosE6);
      PL_Print_R('Gewicht kg',cPosE7);
      PL_Drawbox(cPosE0+1.0, cPosE7+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;


    'Einsatz' : begin
      pls_FontSize  # 9;
      PL_PrintI(GPL.P.Reihenfolge,  cPosE1);
      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
           ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     ANum("Mat.Länge","Set.Stellen.Länge");
      PL_Print(vText + ' mm', cPosE1 + 2.0);

      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText # vText +  ' / ' + StrAdj("Mat.Gütenstufe",_StrEnd);
      PL_Print(vText,cPosE2);

      PL_PrintI(Mat.Nummer,                               cPosE4);
      PL_Print(Mat.Coilnummer,                            cPosE4 + 2.0);
      PL_PrintI("GPL.P.Stückzahl",                        cPosE6);
      PL_PrintF(GPL.P.Gewicht, Set.Stellen.Gewicht,       cPosE7);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;
    end; // EO Einsatz


    'Einsatzfuss' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosE0+1.0,cPosE7+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintI(vSumStk,cPosE6);
      PL_PrintF(vSumGewicht , Set.Stellen.Gewicht, cPosE7);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosE0+1.0,cPosE7+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosE0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE1+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE2-1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE3+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE4+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE5+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE6+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE7+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;


    'Fertigungkopf' : begin
      pls_FontSize  # 10;
      PL_Print('Aufträge',cPosE0);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('RF',        cPosF1);
      PL_Print('Abmessung',   cPosF1 + 2.0);
      PL_Print('Qualität',    cPosF2);
      PL_Print('Auftrag' ,    cPosF3);
      PL_Print_R('Stück',     cPosF5);
      PL_Print_R('Gewicht kg',cPosF6);
      PL_Drawbox(cPosF0+1.0, cPosF6+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Fertigung' : begin
      pls_FontSize  # 9;
      PL_PrintI(GPL.P.Reihenfolge,                  cPosF1);

     // Abmessung
      vText # ANum(Auf.P.Dicke,Set.Stellen.Dicke) + ' x ' +
           ANum(Auf.P.Breite,Set.Stellen.Breite);
      if ("Auf.P.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     ANum("Auf.P.Länge","Set.Stellen.Länge");
      PL_Print(vText + ' mm', cPosF1 + 2.0);

      PL_Print("Auf.P.Güte",                        cPosF2);
      vText # AInt(Auf.P.Nummer)+'/'+AInt(auf.p.Position)+' '+Auf.P.KundenSW;
      PL_Print(vText,                               cPosF3);
      PL_PrintI("GPL.P.Stückzahl",                  cPosF5);
      PL_PrintF(GPL.P.Gewicht, Set.Stellen.GEwicht, cPosF6);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Fertigungfuss' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosF0+1.0,cPosF6+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_Printi(vSumStk   ,                       cPosF5);
      PL_PrintF(vSumGewicht ,Set.Stellen.Gewicht, cPosF6);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosF0+1.0,cPosF6+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2-1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3-1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;
  end;

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vTxtName  : alpha;
  vText     : alpha(250);
  vText2    : alpha(250);
end;
begin

  Pls_fontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('GROBPLANUNG '+AInt(GPl.Nummer) ,cPosKopf1);
  PL_Print(GPL.Bezeichnung,cPosKopf2);
  PL_Print('Seite:'+AInt(aSeite),cPosKopf3);
  PL_PrintLine;
  pls_Fontattr # 0;

  Pls_FontSize # 9;
  PL_PrintLine;

  PL_Print('Termin : '+cnvad(GPL.Termin), cPosKopf1);
  PL_PrintLine;

  PL_PrintLine;

  if (Form_Mode='EINSATZ') then     Print('Einsatzkopf');
  if (Form_Mode='FERTIGUNG') then   Print('Fertigungkopf');

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
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------
  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,n,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  form_RandOben # 0.0;


  GV.Int.01   # GPl.Nummer;
  GV.Ints.01  # 200;
  GV.Ints.02  # 401;

  // ------- KOPFDATEN -----------------------------------------------------------------------
  form_Mode # 'EINSATZ';
  if (vFirst=n) then begin
    vFirst # Y;
    Lib_Print:Print_Seitenkopf();
    end
  else begin
    Lib_Print:Print_FF();
  end;

  // ------- EINSATZMATERIAL -----------------------------------------------------------------
  Erx # RecLink(601,999,1,_RecFirst);
  WHILE (Erx<=_rLocked) DO BEGIN

    // Material lesen
    Mat_Data:Read(GPl.P.ID1);

    Print('Einsatz');

    // Summierung
    vSumStk         # vSumStk + "GPL.P.Stückzahl";
    vSumGewicht     # vSumGewicht  + GPL.P.Gewicht;

    Erx # RecLink(601,999,1,_RecNext);
  END;
  Print('Einsatzfuss');
  PL_PrintLine;


  // ------- FERTIGUNGEN -----------------------------------------------------------------------
  vSumStk       # 0;
  vSumGewicht   # 0.0;
  form_Mode # '';
  Print('Fertigungkopf');
  form_Mode # 'FERTIGUNG';
  Erx # RecLink(601,999,2,_RecFirst);
  WHILE (Erx<=_rLocked) DO BEGIN

    // Auftrag holen
    Auf_Data:Read(GPl.P.ID1,GPl.P.ID2,n);

    Print('Fertigung');

    // Summierung
    vSumStk       # vSumStk + "GPl.P.Stückzahl";
    vSumgewicht   # vSumGewicht  + GPL.P.Gewicht;

    Erx # RecLink(601,999,2,_RecNext);
  END;
  Print('Fertigungfuss');
  PL_PrintLine;



// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();
end;

//========================================================================