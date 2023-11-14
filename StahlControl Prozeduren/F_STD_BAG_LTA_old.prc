@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_BAG_LTA
//
//  Info
//    Druckt einen Lohntafelauftrag aus
//
//
//  17.10.2006  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//
//========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cPos0   :  10.0

  cPos1   :   50.0  // Mat.Nr
  cPos2   :   60.0  // Abmessung
  cPos3   :  110.0  // Coilnr.
  cPos4   :  145.0  // Stück
  cPos5   :  170.0  // Gewicht

  cPosFuss1 : 10.0
  cPosFuss2 : 35.0

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
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
  RecLink(100,702,7,_recFirst);    // Lohnbetrieb lesen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Bag.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)+'.'+CnvAI(Bag.P.Position,_FmtNumNoGroup | _FmtNumLeadZero,0,3);      // Dokumentennummer
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


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    RecLink(100,702,7,_recFirst);    // Lohnbetrieb lesen
    RecLink(101,100,12,_recFirst);   // erste Anschrift lesen

    Pls_fontSize # 6
    pls_Fontattr # _WinFontAttrU;
    PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

    pls_Fontattr # 0;
    Pls_fontSize # 10;
    PL_Print(Adr.A.Anrede   , cPos0); PL_PrintLine;
    PL_Print(Adr.A.Name     , cPos0); PL_PrintLine;

    PL_Print(Adr.A.Zusatz   , cPos0);
    Pls_fontSize # 9;
    PL_Print('Unsere Knd.Nr.:',cPosKopf1);
    PL_Print(Adr.VK.Referenznr,cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print("Adr.A.Straße" , cPos0);
    Pls_fontSize # 9;
    PL_Print('Sachbearbeiter:',cPosKopf1);
    PL_Print(Usr_Data:Sachbearbeiter(gUsername),cPosKopf2);
    PL_PrintLine;

    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvad(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Lohntafelauftrag'+' '+AInt(Bag.P.Nummer)+ '/' + AInt(Bag.P.Position)   ,cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

    PL_PrintLine;
    PL_Print('Bitte tafeln Sie unten aufgeführte Materialien wie angegeben:',cPos0);
    PL_PrintLine;
    PL_PrintLine;

    // Kopftext drucken
    vTxtName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K';
    Lib_Print:Print_Text(vTxtName,1, cPos0);

    end       // 1. Seite
  else begin  // weitere Seiten
    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvad(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Lohntafelauftrag '+AInt(Bag.P.Nummer)+ '/' + AInt(Bag.P.Position)   ,cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

  end;

  Lib_Print:Print_LinieDoppelt();

end;


//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vText               : alpha;
  vTxtName            : alpha;

  vGesamtStueck       : int;
  vGesamtGewichtN     : float;
  vGesamtGewichtB     : float;
  vGesamtBreite       : float;

  vPos                : int;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y,n);
  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------
  // Erstes Einsatzmaterial lesen um an die Lageranschrift für die Kopfdaten zu gelangen
  RecLink(701,702,2,_RecFirst); // Input lesen
  Erg # Mat_Data:Read(BAG.IO.Materialnr); // Material holen


  Lib_Print:Print_Seitenkopf();

// ------- EINSATZMATERIAL -----------------------------------------------------------------
  Pls_FontSize # 10;
  PL_Print('Einsatzmaterial:',cPos0);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print_R('Mat.Nr.',cPos1);
  PL_Print('Abmessungs / Qualität',cPos2);
  PL_Print('Coil-/Tafelnr.',cPos3);
  PL_Print_R('Stück',cPos4);
  PL_Print_R('Gewicht kg',cPos5);
  PL_PrintLine;
  pls_Inverted  # n;
  Lib_Print:Print_LinieEinzeln(cPos1-12.0,cPos5);


  vFlag # _RecFirst;
  vPos # 0;
  vGesamtStueck       # 0;
  vGesamtGewichtN     # 0.0;
  vGesamtGewichtB     # 0.0;

  WHILE (RecLink(701,702,2,vFlag) <> _rNoRec) DO BEGIN
    vFlag # _RecNext;
    vPos # vPos + 1;

    // Leerzeile zwischen den Positionen
    if (vPos>1) then PL_PrintLine;

    // Material lesen
    if (BAG.IO.Materialtyp=200) then begin
      Erg # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
      end
    else begin
      RecbufClear(200);
    end;


    // Einsatzmaterial ausgeben
    pls_FontSize  # 9;
    PL_PrintI(Mat.Nummer,cPos1);

    // Abmessung
    vText # ANum(BAG.IO.Dicke,Set.Stellen.Dicke) + ' x ' +
            ANum(BAG.IO.Breite,Set.Stellen.Breite);
    if ("BAG.IO.Länge" <> 0.0) then
      vText # vText + ' x ' +
              ANum("BAG.IO.Länge","Set.Stellen.Länge");
    PL_Print(vText + ' mm',cPos2);

    PL_Print(Mat.Coilnummer,cPos3);
    PL_PrintI(BAG.IO.Plan.In.Stk,cPos4);
    PL_PrintF(BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht, cPos5);
    PL_Printline;


    // Güte
    vText # StrAdj("BAG.IO.Güte",_StrEnd);
    if ("Mat.Gütenstufe" <> '') then
      vText # vText +  ' / ' +
                  StrAdj("Mat.Gütenstufe",_StrEnd);
    PL_Print(vText,cPos2);
    PL_Printline;


    // Summierung
    vGesamtStueck       # vGesamtStueck   + BAG.IO.Plan.In.Stk;
    vGesamtGewichtN     # vGesamtGewichtN + BAG.IO.Plan.In.GewN;
    vGesamtGewichtB     # vGesamtGewichtB + BAG.IO.Plan.In.GewB

  END;

  // Summen drucken
  Lib_Print:Print_LinieEinzeln(cPos1-12.0,cPos5);
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Gesamt:',cPos3);
  PL_PrintI(vGesamtStueck,cPos4);
  PL_PrintF(vGesamtGewichtN,Set.Stellen.Gewicht,cPos5);
  PL_Printline;
  pls_Fontattr # 0;




// ------- FERTIGUNGEN ---------------------------------------------------------------------
  vGesamtStueck       # 0;
  vGesamtGewichtN     # 0.0;
  vGesamtGewichtB     # 0.0;
  vGesamtBreite       # 0.0;

  PL_PrintLine;
  PL_PrintLine;
  Pls_FontSize # 10;
  PL_Print('Tafeln auf:',cPos0);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print_R('Streifenzahl',cPos2-5.0);
  PL_Print('Breite x Länge',cPos2);
  PL_Print_R('Stück',cPos4);
  PL_Print_R('Gewicht kg',cPos5);
  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln(cPos2-25.0,cPos5);

  vFlag # _RecFirst;
  WHILE (RecLink(703,702,4,vFlag) <> _rNoRec) DO BEGIN
    vFlag # _RecNext;

    PL_PrintI(BAG.F.Streifenanzahl,cPos2-5.0);
    vText #  ANum(BAG.F.Breite,Set.Stellen.Breite);
    vText # vText + ' x ' +
            ANum("BAG.F.Länge","Set.Stellen.Länge");
    PL_Print(vText + ' mm',cPos2);
    PL_PrintI("BAG.F.Stückzahl",cPos4);
    PL_PrintF(BAG.F.Gewicht,0,cPos5);
    PL_PrintLine;

    // Summierung
    vGesamtStueck       # vGesamtStueck   + "BAG.F.Stückzahl";
    vGesamtGewichtB     # vGesamtGewichtB + BAG.F.Gewicht;
  END;

  // Summen drucken
  Lib_Print:Print_LinieEinzeln(cPos2-25.0,cPos5);
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Gesamt :',cPos3);
  PL_PrintI(vGesamtStueck,cPos4);
  PL_PrintF(vGesamtGewichtB,Set.Stellen.Gewicht,cPos5);
  PL_Printline;
  pls_Fontattr # 0;


// ------- FUßDATEN --------------------------------------------------------------------------
  form_Mode # 'FUSS';
  PL_PrintLine;
  Lib_Print:Print_LinieDoppelt();
  PL_PrintLine;
  pls_Fontattr # 0;

  // Fusstext drucken
  vTxtName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
  Lib_Print:Print_Text(vTxtName,1, cPos0);

  // Starttermin
  vText # '';
  if (BAG.P.Plan.StartDat<>0.0.0) then begin
    vText # cnvad(BAG.P.Plan.StartDat);
    if (BAG.P.Plan.StartZeit<>0:0) then
      vText # vText + ' um '+cnvat(BAG.P.Plan.StartZeit);
    vText # vText + ' '+BAG.P.Plan.StartInfo;
  end;
  if (vText<>'') then begin
    PL_Print('Starttermin: ',cPos0);
    PL_Print(vText,cPos2);
    PL_PrintLine;
  end;

  // Endtermin
  vText # '';
  if (BAG.P.Plan.EndDat<>0.0.0) then begin
    vText # cnvad(BAG.P.Plan.EndDat);
    if (BAG.P.Plan.EndZeit<>0:0) then
      vText # vText + ' um '+cnvat(BAG.P.Plan.EndZeit);
    vText # vText + ' '+BAG.P.Plan.EndInfo;
  end;
  if (vText<>'') then begin
    PL_Print('Endtermin: ',cPos0);
    PL_Print(vText,cPos2);
    PL_PrintLine;
  end;


  vText # '';
  // Kosten nur ausgeben, wenn diese angegeben sind
  if (BAG.P.Kosten.Fix <> 0.0) or (BAG.P.Kosten.Pro <> 0.0)  then begin
    PL_Print('Preisstellung: ',cPos0);

    if (BAG.P.Kosten.Fix <> 0.0) then begin
      // Währung lesen
      Wae.Nummer # Bag.P.Kosten.Wae;
      if (RecRead(814,702,_RecFirst) = _rNoRec) then RecBufClear(814);
      vText  #  'Pauschal ' + ANum(BAG.P.Kosten.Fix,2) +' '  +  "Wae.Kürzel";
    end;

    if (BAG.P.Kosten.Pro <> 0.0) then begin
      // Währung lesen
      Wae.Nummer # Bag.P.Kosten.Wae;

      if (RecRead(814,1,_RecFirst) = _rNoRec) then RecBufClear(814);

      if (vText = '') then
        vText # ANum(BAG.P.Kosten.Pro,2) + ' ' +  "Wae.Kürzel" + ' pro ' +
                AInt(Bag.P.Kosten.PEH) + ' ' + Bag.P.Kosten.MEH;
      else
        vText # vText + ', ' +
                ANum(BAG.P.Kosten.Pro,2) + ' ' +  "Wae.Kürzel" + ' pro ' +
                AInt(Bag.P.Kosten.PEH) + ' ' + Bag.P.Kosten.MEH;
    end;

    if (vText <> '') then begin
      PL_Print(vText,cPos2);
      PL_PrintLine;
    end;
  end;

  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Mit freundlichen Grüßen',cPos0);
  PL_PrintLine;
  PL_Print(Set.mfg.Text,cPos0);
  PL_PrintLine;


  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================