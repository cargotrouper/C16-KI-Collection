@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_LFS_Nachweis
//                        OHNE E_R_G
//  Info
//    Druckt einen Lieferschein aus
//
//
//  19.10.2006  ST  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
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
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cPos0   :  10.0   // linke Starposition
  cPos1   :   30.0  // Mat.Nr
  cPos2   :   32.0  // Güte
  cPos3   :   70.0  // Abmessung
  cPos4   :  120.0  // Auftrag
  cPos5   :  146.0  // Stk
  cPos6   :  164.0  // Gewicht Brutto
  cPos7   :  182.0  // Gewicht Netto
  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cFussSign1 : 10.0  // Unterschriften
  cFussSign2 : 70.0  //  Unterschriften
  cFussSign3 :130.0  //Unterschriften

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
  RecLink(100,440,2,_recFirst);    // Zieladresse lesen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Lfs.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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
      RecLink(100,440,2,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,440,3,_recFirst);   // Lieferanschrift holen
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

    if (Scr.B.2.anLagerortYN) then RETURN;

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
  vDat  : date;
  vFlag : int;
end;
begin


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    vFlag # _RecFirst;
    WHILE (RecLink(441,440,4,vFlag) <= _rLocked) DO BEGIN
      vFlag # _RecNext;
      // nur markierte Sätze
      if (Lib_Mark:IstMarkiert(441,RecInfo(441,_recId))) then
        vDat # Lfs.P.Datum.Verbucht;
    END;

    RecLink(100,440,2,_recFirst);    // Zieladresse lesen
    RecLink(101,440,3,_recFirst);    // Zielanschrift lesen
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

    Pls_fontSize # 10;
    PL_Print("Adr.A.Straße" , cPos0);
    Pls_fontSize # 9;
    PL_Print('Sachbearbeiter:',cPosKopf1);
    PL_Print(Usr_Data:Sachbearbeiter(gUsername),cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print(StrAdj(Adr.A.LKZ + ' ' + Adr.A.PLZ + ' ' + Adr.A.Ort,_StrBegin), cPos0);
    Pls_fontSize # 9;
    PL_Print('Datum:',cPosKopf1);
    PL_Print(cnvad(today),cPosKopf2);
    PL_PrintLine;

    PL_Print('Seite:',cPosKopf1);
    PL_PrintI_L(aSeite,cPosKopf2);
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;

    Pls_FontSize # 10;
    pls_Fontattr # _WinFontAttrBold;
    Pl_Print('Liefernachweiss zu Lieferung '+' '+AInt(Lfs.Nummer),cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

    PL_PrintLine;
    PL_Print('Folgende Positionen wurden am '+cnvad(vDat)+' geliefert:',cPos0);
    PL_PrintLine;
    PL_PrintLine;

    if (Lfs.Bemerkung <> '') then begin
      PL_Print(Lfs.Bemerkung,cPos0);
      PL_PrintLine;
      PL_PrintLine;
    end;

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
    Pl_Print('Liefernachweiss zu Lieferung '+' '+AInt(Lfs.Nummer),cPos0 );
    pl_PrintLine;

    Pls_FontSize # 9;
    pls_Fontattr # 0;

  end;

  if (form_mode <> 'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    PL_Print('Pos'      ,cPos0);
    PL_Print_R('Material' ,cPos1);
    PL_Print('Güte'     ,cPos2);
    PL_Print('Abmessung' ,cPos3);
    PL_Print('Auftrag'  ,cPos4);
    PL_Print_R('Stück'     ,cPos5);
    PL_Print_R('Brutto ' + StrAdj(Lfs.P.MEH,_StrBegin),cPos6);
    PL_Print_R('Netto '  + StrAdj(Lfs.P.MEH,_StrBegin),cPos7);
    PL_Drawbox(cPos0-1.0,cPos7+1.0,_WinColblack, 4.5);
    PL_PrintLine;
  end;


end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  // Formularspezifische Variablen
  vText               : alpha(250);    // Variable zur angepassten Textgenerierung
  vGesamtStueck       : int;      // Summe Stückzahl
  vGesamtGewichtN     : float;    // Summe Nettogewicht
  vGesamtGewichtB     : float;    // Summe Bruttogewicht
  vFusstexttyp        : int;      // Textinikator für z.B. EG Verbringungsnachweis etc.

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
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------

  form_Mode # '';
  Lib_Print:Print_Seitenkopf();

// ------- POSITIONSDATEN ------------------------------------------------------------------

  vFlag # _RecFirst;
  WHILE (RecLink(441,440,4,vFlag) <= _rLocked) DO BEGIN
    vFlag # _RecNext;

    // nur markierte Sätze
    if (Lib_Mark:IstMarkiert(441,RecInfo(441,_recId))=false) then begin
      CYCLE;
    end;


    // -------------Material liefern---------------
    if (Lfs.P.Materialtyp = c_IO_VSB) then begin

      // Materialkarte lesen
      if (RecLink(200,441,4,_RecFirst) > _rOK) then
        CYCLE;

      // Posiionsnummerierung
      PL_Print(CnvAi(Lfs.P.Position,_FmtNumNoGroup,0,2)       ,cPos0);

      // MAterialnummmer
      PL_Print_R(CnvAi(Lfs.P.Materialnr,_FmtNumNoGroup,0,8)   ,cPos1);

      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText #  vText + '/' + "Mat.Gütenstufe";
      PL_Print(vText,cPos2);

      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
              ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");
      vText # vText + ' mm';
      PL_Print(vText,cPos3);

      // Kommission
      PL_Print(Lfs.P.Kommission,cPos4);

      // Stückzahl
      PL_Print_R(CnvAi("Lfs.P.Stück",_FmtNumNoZero | _FmtNumNoGroup),cPos5);

      // Gewicht Brutto
      PL_Printf("Lfs.P.Gewicht.Brutto",0,cPos6);

      // Gewicht Netto
      PL_Printf("Lfs.P.Gewicht.Netto",0,cPos7);

      PL_Printline;

      // Summierung
      vGesamtStueck   #  vGesamtStueck   + "Lfs.P.Stück";
      vGesamtGewichtN #  vGesamtGewichtN + "Lfs.P.Gewicht.Netto";
      vGesamtGewichtB #  vGesamtGewichtB + "Lfs.P.Gewicht.Brutto"

    end else
    // -----------VSB-------------
    if (Lfs.P.Materialtyp = c_IO_Mat) then begin

      // Materialkarte lesen
      if (RecLink(200,441,4,_RecFirst) > _rOK) then
        CYCLE;

      // Posiionsnummerierung
      PL_Print(CnvAi(Lfs.P.Position,_FmtNumNoGroup,0,2)       ,cPos0);

      // MAterialnummmer
      PL_Print_R(CnvAi(Mat.Nummer,_FmtNumNoGroup,0,8)   ,cPos1);

      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText #  vText + '/' + "Mat.Gütenstufe";
      PL_Print(vText,cPos2);

      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
              ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");
      vText # vText + ' mm';
      PL_Print(vText,cPos3);

      // Kommission
      PL_Print(Mat.Kommission,cPos4);

      // Stückzahl
      PL_Print_R(CnvAi("Mat.Bestand.Stk",_FmtNumNoZero | _FmtNumNoGroup),cPos5);

      // Gewicht Brutto
      PL_Printf("Mat.Gewicht.Brutto",0,cPos6);

      // Gewicht Netto
      PL_Printf("Mat.Gewicht.Netto",0,cPos7);

      PL_Printline;

      // Summierung
      vGesamtStueck   #  vGesamtStueck   + "Mat.Bestand.Stk";
      vGesamtGewichtN #  vGesamtGewichtN + "Mat.Gewicht.Netto";
      vGesamtGewichtB #  vGesamtGewichtB + "Mat.Gewicht.Brutto"

    end;

    PL_Printline;     // Leerzeichen zwischen den Positionen

  END;

// ------- FUßDATEN ------------------------------------------------------------------------
  form_Mode # 'FUSS';
  Lib_Print:Print_LinieEinzeln();
  pls_Fontattr # 0;

  // Summen ausgeben
  PL_Print('Gesamt:',cPos4);
  PL_Print_R(CnvAi(vGesamtStueck,_FmtNumNoZero | _FmtNumNoGroup),cPos5); // Stückzahl
  PL_Printf(vGesamtGewichtB,0,cPos6);                                    // Gewicht Brutto
  PL_Printf(vGesamtGewichtN,0,cPos7);                                    // Gewicht Netto
  PL_Printline;  PL_Printline;  PL_Printline;

  PL_Printline;

  PL_PrintLine;
  Lib_Print:Print_LinieDoppelt();
  // Speditionsdaten füllen
  if (Lfs.Spediteurnr <> 0) then begin

    // Spedition aus den Stammdaten?
    RecLink(100,440,6,_RecFirst);
    vText # StrAdj(Adr.Name,_StrBegin | _StrEnd) + ' ' +
            StrAdj(Adr.Zusatz,_StrBegin | _StrEnd) + ', ' +
            StrAdj("Adr.Straße",_StrBegin | _StrEnd) + ', ' +
            StrAdj(StrAdj(Adr.LKZ,_StrBegin | _StrEnd) + ' ' +
            StrAdj(Adr.PLZ,_StrBegin | _StrEnd),_StrBegin) + ' ' +
            StrAdj(Adr.Ort,_StrBegin | _StrEnd);
    if (Adr.LKZ <> 'D') then begin
        RecLink(812,100,10,_RecFirst);
      vText # vText + ', '+ Lnd.Name.L1;
    end;
  end else begin

    // Spedition, die nicht hinterlegt ist?
    if (Lfs.Spediteur <> '') then
      vText # Lfs.Spediteur;

  end;

  // Spedition drucken
  if (vText <> '') then begin
    PL_Print('Spediteur: ',cPos0);
    PL_Print(vText,cPos2);
    PL_PrintLine;
  end;

  // Fahrer drucken
  if (Lfs.Fahrer <> '') then begin
    PL_Print('Fahrer: ',cPos0);
    PL_Print(Lfs.Fahrer,cPos2);
    PL_PrintLine;
  end;

  // Kennzeichen drucken
  if (Lfs.Kennzeichen <> '') then begin
    PL_Print('Kennzeichen: ',cPos0);
    PL_Print(Lfs.Kennzeichen,cPos2);
    PL_PrintLine;
  end;

  // Palettentausch drucken
  // Hier die Texte für EG Geschäfte drucken
  vFusstexttyp # 0; // deaktiviert, muss auf Anfrage angepasst

  if (vFusstexttyp <> 0) then begin
    PL_Printline;
    PL_Printline;

    if (vFusstexttyp = 1) then begin
      // Standardfusstext

    end else
    if (vFusstexttyp = 2) then begin
      // Nicht EG Auslandtext
      PL_Print('Der Ausführer der Waren erklärt, dass diese Waren, soweit nicht andersn angegeben, präferenzbegünstigte EG - ',cPos0);
      PL_Printline;
      PL_Print('Ursprungswaren sind.',cPos0);
      PL_Printline;
    end else
    if (vFusstexttyp = 3) then begin
      // EG Auslandtext
      PL_Print('*********************************** EG - VERBRINGUNGSNACHWEIS ***********************************',cPos0);
      PL_PrintLine;
      PL_Print('Wir bestätigen, die Ware an den oben genannten Empfänger in das übrige Gemeinschaftsgebiet zu transportieren.',cPos0);
      PL_PrintLine;
      PL_Print('Unsere Angaben sind aufgrund von Geschäftsunterlagen gemacht worden, die im Gemeinschaftsgebiet nachprüfbar sind.',cPos0);
      PL_Printline;
    end;

  end;
  PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================