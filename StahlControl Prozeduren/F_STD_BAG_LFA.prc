@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_BAG_LFA
//                  OHNE E_R_G
//  Info
//    Druckt einen Lohnfahrauftrag aus
//
//
//  09.10.2006  ST  Erstellung der Prozedur
//  13.08.2009  ST  Artikelausgabe überarbeitet, Material/Artikelmix hinzugefügt
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB HoleEmpfaenger();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,cnvAI(b),0,0,0); RETURN false; end;

  cPos0   :  10.0

  cPos1   :  15.0 // Pos
  cPos2   :  40.0 //
  cPos3   :  50.0 // Menge1
  cPos4   :  70.0 // Menge2
  cPos5   :  90.0 // Einzelpreis
  cPos6   : 100.0 // Rabatt
  cPos7   : 140.0 // Gesamt
  cPos8   : 161.0 // Gesamt
  cPos9   : 182.0 // Gesamt

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
  RecLink(100,702,7,_recFirst);    // Spediteur lesen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);

  RETURN cnvAI(Bag.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)+'.'+cnvAI(Bag.P.Position,_FmtNumNoGroup | _FmtNumLeadZero,0,3);      // Dokumentennummer
end;

//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,702,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,702,13,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin
      RETURN;
    end;
  end // Daten aus Auf.
  else begin  // FIXE DATEN !!!

    if (Scr.B.2.anKuLfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Kunde/Lieferant holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) then begin
     RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Lieferort holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Anschrift holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin;
      RETURN;
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


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    Erx # RecLink(100,702,7,_recFirst);    // Spediteur lesen
    if(Erx > _rLocked) then
      RecBufClear(100);
    Erx # RecLink(101,100,12,_recFirst);   // erste Anschrift lesen
    if(Erx > _rLocked) then
      RecBufClear(101);
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;

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


    Adr.A.Zusatz # Adr.A.Zusatz;
    Pls_fontSize # 10;
    PL_Print("Adr.A.Straße" , cPos0);
    Pls_fontSize # 9;
    PL_Print('Sachbearbeiter:',cPosKopf1);
    PL_Print(Usr_Data:Sachbearbeiter(gUsername),cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print(StrAdj(Adr.A.PLZ,_StrBegin) + ' ' + Adr.A.Ort , cPos0);
    Pls_fontSize # 9;
    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvAD(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Lohnfahrauftrag'+' '+AInt(Bag.P.Nummer)+ '/' + AInt(Bag.P.Position)   ,cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;


    Erx # RecLink(100,702,12,_recFirst);  // Zieladresse
    if(Erx > _rLocked) then
      RecBufClear(100);

    Erx # Reclink(101,702,13,_recFirst);  // Zielanschrift
    if(Erx > _rLocked) then
      RecBufClear(101);

    PL_PrintLine;
    PL_Print('Bitte liefern Sie unten aufgeführte Positionen an folgende Adresse:',cPos0);
    PL_PrintLine;

    // Lieferadresse ausgeben
    Erx # RecLink(812,101,2,_recFirst);   // Land holen
    if(Erx > _rLocked) then
      RecBufClear(812);

    vText #  StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd);
    if (vText<>'') then
      vText # vText + ' ' + StrAdj(Adr.A.Name,_StrBegin | _StrEnd)
    else
      vText # StrAdj(Adr.A.Name,_StrBegin | _StrEnd);

    if (vText<>'') then
      vText # vText + ' ' + StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)
    else
      vText # StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd);

    if (vText<>'') then
      vText # vText + ' ' + StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)
    else
      vText # StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd);

    vText # vText + ', ' + StrAdj("Adr.A.Straße",_StrBegin | _StrEnd);
    vText2 # Adr.A.PLZ;

    if (vText2<>'') then
      vText2 # vText2 + ' ' + StrAdj(Adr.A.Ort,_StrBegin | _StrEnd)
    else
      vText2 # Adr.A.Ort;

    if (vText2<>'') then
      vText2 # vText2 + ', ' + StrAdj(Lnd.Name.L1,_StrBegin | _StrEnd)
    else
      vText2 # Lnd.Name.L1;

    // Leerzeichen am Anfang entfernen
    vText   # StrAdj(vText, _StrBegin | _StrEnd);
    vText2  # StrAdj(vText2, _StrBegin | _StrEnd);

    pls_Fontattr # _WinFontAttrBold;
    PL_Print('Lieferanschrift:',cPos0);
    PL_Print(vText,cPos2, cpos9);
    PL_PrintLine;
    PL_Print(vText2,cPos2);
    pls_Fontattr # _WinFontAttrNormal;
    PL_PrintLine;
    PL_PrintLine;



    PL_PrintLine;
    PL_Print('Das Material befindet sich an folgender Adresse und steht zur Abholung bereit:',cPos0);
    PL_PrintLine;

    // Lageradresse ausgeben
    Erx # RecLink(101,200,6,_recFirst);     // Lageranschrift lesen
    if(Erx > _rLocked) then
      RecBufClear(101);

    Erx # RecLink(812,101,2,_recFirst);    // Land holen
    if(Erx > _rLocked) then
      RecBufClear(812);

    vText #  StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd);
    if (vText<>'') then
      vText # vText + ' ' + StrAdj(Adr.A.Name,_StrBegin | _StrEnd)
    else
      vText # StrAdj(Adr.A.Name,_StrBegin | _StrEnd);

    if (vText<>'') then
      vText # vText + ' ' + StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)
    else
      vText # StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd);

    vText # vText + ', ' + StrAdj("Adr.A.Straße",_StrBegin | _StrEnd);
    vText2 # Adr.A.PLZ;

    if (vText2<>'') then
      vText2 # vText2 + ' ' + StrAdj(Adr.A.Ort,_StrBegin | _StrEnd)
    else
      vText2 # Adr.A.Ort;

    if (vText2<>'') then
      vText2 # vText2 + ', ' + StrAdj(Lnd.Name.L1,_StrBegin | _StrEnd)
    else
      vText2 # Lnd.Name.L1;

    // Leerzeichen am Anfang entfernen
    vText   # StrAdj(vText, _StrBegin | _StrEnd);
    vText2  # StrAdj(vText2, _StrBegin | _StrEnd);


    pls_Fontattr # _WinFontAttrBold;
    PL_Print('Abholanschrift:',cPos0);
    PL_Print(vText,cPos2);
    PL_PrintLine;
    PL_Print(vText2,cPos2);
    pls_Fontattr # _WinFontAttrNormal;
    PL_PrintLine;

    // Kopftext drucken
    vText # '~702.'+cnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+cnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K';
    Lib_Print:Print_Text(vText,1, cPos0);
    PL_PrintLine;

  end else begin // 1.Seite

    // folgende
    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvAD(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Lohnfahrauftrag'+' '+AInt(Bag.P.Nummer)+ '/' + AInt(Bag.P.Position)   ,cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

  end;

  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    PL_Print('Pos',cPos1-5.0);
    PL_Print('Gegenstand',cPos1+2.0);
    PL_Print_R('Stück',cPos7);
    PL_Print_R('Brutto kg',cPos8);
    PL_Print_R('Netto kg',cPos9);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 4.5);
    PL_PrintLine;
  end;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vText               : alpha;

  vGesamtStueck       : int;
  vGesamtGewichtN     : float;
  vGesamtGewichtB     : float;

  vPos                : int;
  vMatBeschr          : alpha;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
  vBuf                : int;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------
  // Erstes Einsatzmaterial lesen um an die Lageranschrift für die Kopfdaten zu gelangen
  if ( RecLink( 701, 702, 2, _recFirst ) > _rLocked ) then // Input lesen
    RecBufClear( 701 );
  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

  Lib_Print:Print_Seitenkopf();

  Pls_fontSize # 9;

// ------- EINSATZMATERIAL -----------------------------------------------------------------
  vPos # 0;
  vGesamtStueck       # 0;
  vGesamtGewichtN     # 0.0;
  vGesamtGewichtB     # 0.0;

  FOR  Erx # RecLink( 701, 702, 2, _recFirst );
  LOOP Erx # RecLink( 701, 702, 2, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    vPos # vPos + 1;

    if ( BAG.IO.Materialtyp != c_IO_VSB ) and ( BAG.IO.Materialtyp != c_IO_Mat ) and ( BAG.IO.Materialtyp != c_IO_Art ) then
      CYCLE;

    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

    if( RecLink( 441, 701, 13, _recFirst ) > _rLocked ) then // Lfs Position
      RecBufClear( 441 );

    if ( RecLink( 703, 701, 10, _recFirst ) > _rLocked ) then // Fertigungen
      RecBufClear( 703 );

    // Artikel lesen
    if ( RecLink( 250, 701, 8, _recFirst ) > _rLocked ) then begin
      RecBufClear( 250 );

      if ( RecLink( 401, 703, 9, _recFirst ) > _rLocked ) then
        RecBufClear( 401 );
      else begin
        if ( RecLink( 250, 401, 2, _recFirst ) > _rLocked ) then
          RecBufClear( 250 );
      end;
    end;

    /* Ausgabe */
    pls_fontSize # 9;
    PL_PrintI( vPos, cPos1 );

    if( Lfs.P.Materialnr != 0 ) then begin
      // Güte
      vMatBeschr # StrAdj( "Mat.Güte", _strEnd );
      if ( "Mat.Gütenstufe" != '' ) then
        vMatBeschr # vMatBeschr + ' / ' + StrAdj( "Mat.Gütenstufe", _strEnd );
      PL_Print( vMatBeschr, cPos1 + 2.0 );

      // Abmessungen
      vMatBeschr # ANum( Mat.Dicke, Set.Stellen.Dicke ) + ' x ' + ANum( Mat.Breite, Set.Stellen.Breite );
      if ( "Mat.Länge" != 0.0 ) then
        vMatBeschr # vMatBeschr + ' x ' + ANum( "Mat.Länge", "Set.Stellen.Länge" );
      PL_Print( vMatBeschr + ' mm', cPos2 );

      // Kommission
      if ( Mat.Kommission != '' ) then begin
        PL_Print( 'Komm.:' + Mat.Kommission, cPos5 );
      end;
    end
    else begin

    end;


    // Unterscheidung Materialtyp
    if ( BAG.IO.Materialtyp = c_IO_VSB or BAG.IO.Materialtyp = c_IO_Art ) then begin
      PL_Print_R( AInt( "Lfs.P.Stück" ), cPos7 );
      PL_Print_R( ANum( Lfs.P.Gewicht.Brutto, Set.Stellen.Gewicht ), cPos8 );
      PL_Print_R( ANum( Lfs.P.Gewicht.Netto, Set.Stellen.Gewicht ), cPos9 );
      PL_PrintLine;

      // Summierung
      vGesamtStueck   # vGesamtStueck   + "Lfs.P.Stück";
      vGesamtGewichtN # vGesamtGewichtN + "Lfs.P.Gewicht.Netto";
      vGesamtGewichtB # vGesamtGewichtB + "Lfs.P.Gewicht.Brutto";
    end
    else if ( BAG.IO.Materialtyp = c_IO_Mat ) then begin
      PL_Print_R( AInt( Mat.Bestand.Stk ), cPos7 );
      PL_Print_R( ANum( Mat.Gewicht.Brutto, Set.Stellen.Gewicht ), cPos8 );
      PL_Print_R( ANum( Mat.Gewicht.Netto, Set.Stellen.Gewicht ), cPos9 );
      PL_PrintLine;

      // Summierung
      vGesamtStueck   # vGesamtStueck   + "Mat.Bestand.Stk";
      vGesamtGewichtN # vGesamtGewichtN + "Mat.Gewicht.Netto";
      vGesamtGewichtB # vGesamtGewichtB + "Mat.Gewicht.Brutto";
    end;

    if ( Mat.Coilnummer != '' ) then
      PL_Print( 'Coil Nr.:' + Mat.Coilnummer, cPos2 );

    if ( Mat.Werksnummer != '') then
      PL_Print( 'Werks Nr.:' + Mat.Werksnummer, cPos5 );

    if ( Mat.Coilnummer != '' or Mat.Werksnummer != '' ) then
      PL_PrintLine;

    if ( Art.Nummer != '' ) then begin
      PL_Print( Art.Nummer, cPos1 + 2.0);
      PL_PrintLine;
    end;

    if ( Art.Bezeichnung1 != '' ) then begin
      PL_Print( Art.Bezeichnung1, cPos1 + 2.0);
      PL_PrintLine;
    end;

    if ( Art.Bezeichnung2 != '' ) then begin
      PL_Print( Art.Bezeichnung2, cPos1 + 2.0);
      PL_PrintLine;
    end;

    if ( Art.Bezeichnung3 != '' ) then begin
      PL_Print( Art.Bezeichnung3, cPos1 + 2.0 );
      PL_PrintLine;
    end;

    if ( Art.AbmessungString!= '' ) then begin
      PL_Print( Art.AbmessungString, cPos1 + 2.0);
      PL_PrintLine;
    end;


    //Leerzeile zwischen den Positionen
    PL_PrintLine;
  END; // Positionen

  // ------- FUßDATEN --------------------------------------------------------------------------
  Lib_Print:Print_LinieEinzeln();

  // Summen drucken
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Gesamt:',cPos6);
  PL_Print_R(cnvAI(vGesamtStueck),cPos7);
  PL_Print_R(cnvAF(vGesamtGewichtB,_FmtNumNoZero,0,Set.Stellen.Gewicht),cPos8);
  PL_Print_R(cnvAF(vGesamtGewichtN,_FmtNumNoZero,0,Set.Stellen.Gewicht),cPos9);

  PL_Printline;

  PL_PrintLine;
  Lib_Print:Print_LinieDoppelt();
  PL_PrintLine;
  pls_Fontattr # 0;

  form_Mode # 'FUSS';


  /*vText # '~702'+cnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+cnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
  Lib_Print:Print_Text(vText,1, cPos0);
  vText # '';*/



  // Kosten nur ausgeben, wenn diese angegeben sind
  if (BAG.P.Kosten.Fix <> 0.0) or (BAG.P.Kosten.Pro <> 0.0)  then begin
    PL_Print('Preisstellung: ',cPos0);

    if (BAG.P.Kosten.Fix <> 0.0) then begin
      // Währung lesen
      Wae.Nummer # Bag.P.Kosten.Wae;
      if (RecRead(814,1,_RecFirst) = _rNoRec) then RecBufClear(814);
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
      PL_PrintLine;
    end;

  end;

  // Fusstext drucken
  vText # '~702.'+cnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+cnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
  Lib_Print:Print_Text(vText,1, cPos0);
  vText # '';
  PL_PrintLine;

  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Mit freundlichen Grüßen',cPos0);
  PL_PrintLine;
  PL_Print(Set.mfg.Text, cPos0); PL_PrintLine;
  PL_PrintLine;


  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,cnvIA(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================