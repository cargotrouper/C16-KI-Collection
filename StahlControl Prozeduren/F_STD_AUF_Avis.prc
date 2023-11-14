@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_AUF_Avis
//                    OHNE E_R_G
//  Info
//    Druckt eine Versandanzeige
//
//
//  10.01.2008  DS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB Ueberschrift();
//    SUB MaterialDruck();
//    SUB HoleEmpfaenger();
//    SUB SeitenFuss(aSeite : int);
//    SUB SeitenKopf(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_Aktionen

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cFont1  : 9
  cFont2  : 8
  cFont3  : 7

  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Waggonnummer
  cPos3   :  45.0   // Charge
  cPos4   :  70.0   // Güte
  cPos5   :  95.0   // Dicke
  cPos6   : 115.0   // Breite
  cPos7   : 135.0   // Länge
  cPos8   : 160.0   // Stück
  cPos9   : 182.0   // Gewicht

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...
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
  RecLink(100,400,1,_RecFirst);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  Ueberschrift
//
//========================================================================
sub Ueberschrift();
begin

  if (Wgr.Nummer<>Auf.P.Warengruppe) or ("MQu.Güte1"<>"Auf.P.Güte") then begin
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPos0,cPos9);
    RecLink(819,401,1,_RecFirst); // Warengrupppe holen
    "MQu.Güte1" # "Auf.P.Güte";
    pls_FontSize # cFont1;
    pls_Fontattr # _WinFontAttrBold;
    PL_Print('Material / Güte:',cPos0);
    PL_Print(Wgr.Bezeichnung.L1 + ' / ' + "Auf.P.Güte"  , cPosFuss2);
    PL_PrintLine;
    PL_Print(Auf.P.Bemerkung,cPosFuss2);
    PL_PrintLine;
  end;

  pls_Fontattr  # 0;
  pls_Inverted  # n;
  pls_FontSize  # cFont3;
  PL_Print('Pos.',cPos1);
  PL_Print('LKW-Nr.',cPos2);
  PL_Print('Charge',cPos3);
  PL_Print('Güte',cPos4);
  PL_Print('Dicke',cPos5);
  PL_Print('Breite',cPos6);
  PL_Print('Länge',cPos7);
  PL_Print_R('Stück',cPos8);
  PL_Print_R('Gewicht(To)',cPos9);
//  PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln(cPos0,cPos9);

end;


//========================================================================
//  MaterialDruck
//            Druckt die Materialdaten für ein Druckformular
//            Wird benötigt allen Druckroutinen
//========================================================================
sub MaterialDruck(
  );
local begin
  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;
end;
begin

    if (Wgr.Nummer<>Auf.P.Warengruppe) or ("MQu.Güte1"<>"Auf.P.Güte") then begin
      Ueberschrift();
    end;


    pls_FontSize  # cFont2;

    // -- Positionsdaten --
    PL_Print(AInt(Auf.P.Position),cPos1);
    PL_Print(Mat.Bemerkung1,cPos2);
    PL_Print(Mat.Chargennummer,cPos3);
    PL_Print("Mat.Güte",cPos4);
    PL_Print(ANum(Mat.Dicke,Set.Stellen.Dicke)+' mm',cPos5);

    if (Mat.Breite<>0.0) then
      PL_Print(ANum(Mat.Breite,Set.Stellen.Breite)+' mm',cPos6);
    if ("Mat.Länge"<>0.0) then
      PL_Print(ANum("Mat.Länge"/1000.0,"Set.Stellen.Länge")+' m',cPos7);

    if("Auf.A.Stückzahl" <> 0) then
      PL_PrintI("Auf.A.Stückzahl",cPos8);
    PL_PrintF(Auf.A.Gewicht/1000.0,3,cPos9);

    PL_PrintLine;
end;

//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  Erx       : int;
  vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      Adr.P.Adressnr # Adr.Nummer;
      Adr.P.Nummer   # cnvia(StrCut(Auf.Best.Bearbeiter,2,3));
      Erx # RecRead(102,1,_recFirst);   // Ansprechpartner holen
      if (Erx>_rLocked) then RETURN;
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,400,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,400,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RecLink(100,400,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,400,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      Erx # RecLink(110,400,20,_recFirst);  // Vertreter holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      Erx # RecLink(110,400,21,_recFirst);  // Verband holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
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
      // fixe Adresse testen...
      if (RecLink(102,921,3,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(102,921,3,_recfirst);   // Partner holen
      RecLink(100,102,1,_recFirsT);   // seine Adresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
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
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Empfänger holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen

      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Vertreter  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Verband  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin;
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Lagerort holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
local begin
  vTxtHdl_all : int;
  vJ,vI,vZ    : int;
  vAlpha      : alpha;
end;
begin
  vTxtHdl_all # TextOpen(160);

  TextRead(vTxtHdl_all,'~837.'+CnvAI(10000,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
  vJ # 1;
  FOR  vI # 1
  LOOP vI # vI + 1
  WHILE (vI <= TextInfo(vTxtHdl_all,_TextLines)) DO BEGIN

    IF (StrFind(TextLineRead(vTxtHdl_all,vI,0),StrChar(254,3),0) <> 0) then begin
      vAlpha # TextLineRead(vTxtHdl_all,vI,0);
      vAlpha # StrCut(vAlpha,StrFind(TextLineRead(vTxtHdl_all,vI,0),StrChar(254,3),0)+3,1);
      vJ # CnvIa(vAlpha);
    end else begin
      if (vJ=1) then begin
        vZ # vZ + 1;
        case vZ of
          1   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 1.0, 28.0, 6);
          2   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 1.0, 28.3, 6);
          3   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 1.0, 28.6, 6);
          4   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 1.0, 28.9, 6);
          5   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 1.0, 29.2, 6);

          6   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 5.0, 28.0, 6);
          7   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 5.0, 28.3, 6);
          8   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 5.0, 28.6, 6);
          9   : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 5.0, 28.9, 6);
          10  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 5.0, 29.2, 6);

          11  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 9.0, 28.0, 6);
          12  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 9.0, 28.3, 6);
          13  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 9.0, 28.6, 6);
          14  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 9.0, 28.9, 6);
          15  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0), 9.0, 29.2, 6);

          16  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),13.0, 28.0, 6);
          17  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),13.0, 28.3, 6);
          18  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),13.0, 28.6, 6);
          19  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),13.0, 28.9, 6);
          20  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),13.0, 29.2, 6);

          21  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),16.0, 28.0, 6);
          22  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),16.0, 28.3, 6);
          23  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),16.0, 28.6, 6);
          24  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),16.0, 28.9, 6);
          25  : Lib_Print:Print_TextAbsolut(TextLineRead(vTxtHdl_all,vI,0),16.0, 29.2, 6);

//          TextLineWrite(vTxtHdl_L1,TextInfo(vTxtHdl_L1,_TextLines)+1,TextLineRead(vTxtHdl_all,i,0),_TextLineInsert);
        end;
      end;
    end;
  END;

  TextClose(vTxtHdl_All);

//  Lib_Print:Print_TextAbsolut('HALLO', 3.0, 28.0);
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vBuf100     : int;
  vBuf101     : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin
  vBuf100 # RekSave(100);
  vBuf101 # RekSave(101);
  RecLink(100,400,1,_RecFirst);   // Kunde holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();


  if (aSeite=1) then begin
    vBesteller # '';
    if ((Auf.Best.Bearbeiter <> '') AND (StrLen(Auf.Best.Bearbeiter) > 4)) then begin
      if (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
        vBesteller # StrCut(Auf.Best.Bearbeiter,4,StrLen(Auf.Best.Bearbeiter)-4);
      end;
    end;

    Pls_fontSize # 6
    pls_Fontattr # _WinFontAttrU;
    PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

    pls_Fontattr # 0;
    Pls_fontSize # 10;
    PL_Print(Adr.A.Anrede   , cPos0);
    PL_PrintLine;

    PL_Print(Adr.A.Name     , cPos0);
    PL_PrintLine;

    PL_Print(Adr.A.Zusatz   , cPos0);
    PL_PrintLine;

    PL_Print("Adr.A.Straße" , cPos0);
    PL_PrintLine;

    PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
    PL_PrintLine;

    RecLink(812,101,2,_recFirst);   // Land holen
    if ("Lnd.kürzel"<>'D') then
      PL_Print(Lnd.Name.L1, cPos0);
    PL_PrintLine;
    PL_PrintLine;
  end;

  pls_Fontattr # _WinFontAttrBold;
  if (Auf.Vorgangstyp = c_AUF) then
    Pl_Print('Versandanzeige zu Auftragsbestätigung'+' '+AInt(Auf.P.Nummer) ,cPos0);
//    if (Auf.P.Nummer<100000) then
//      Pl_Print('Versandanzeige zu Auftragsbestätigung'+' '+CnvAi(Auf.P.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,5) ,cPos0)
//    else
//      Pl_Print('Versandanzeige zu Auftragsbestätigung'+' '+CnvAi(Auf.P.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,7) ,cPos0);
//  end;
//  if (Auf.Vorgangstyp = cANG) then
//    Pl_Print('Angebot'+' '+CnvAi(Auf.P.Nummer)   ,cPos0 );

//  PL_Print(Frm.Markierung, cPos0+75.0);

  Pls_FontSize # 9;
  pls_Fontattr # 0;
  PL_Print('Datum:',cPos0+116.0);
  PL_Print(cnvAD(today,_FmtDateLongYear),cPos0+130.0);
  PL_Print('Seite:',cPos0+158.0);
  PL_PrintI(aSeite,cPos9);

  pl_PrintLine;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    Auf.P.Position # 0;
    // Kopftext drucken
    vTxtName # '~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
    Lib_Print:Print_Text(vTxtName,1, cPos0, cPos9);

    PL_Print('Kunden-Bestell-Nr.:',cPos0);
    PL_Print(Auf.Best.Nummer,cPosFuss2);
    PL_PrintLine;
  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    Ueberschrift();
  end;

  RekRestore(vBuf100);
  RekRestore(vBuf101);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vText               : alpha(500);

  // Für Summierungen
  vGesamtGewicht      : float;
  vGesamtStk          : int;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;
  vHdl                : int;

  vFlag               : int;        // Datensatzlese option
  vFlag2              : int;
  vA                  : alpha(4000);

end;
begin

  // ------ Druck vorbereiten ----------------------------------------------------------------
  Erx # RecLink(100,400,1,_RecFirst);   // Kunde holen
  Erx # RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  Erx # RecLink(814,400,8,_RecFirst);   // Währung holen
  Erx # RecLink(836,400,11,_RecFirst);  // BDS holen
  if (Erx>_rLocked) then RecBufClear(836);
  RecbufClear(819); // WGR Reset
  RecBufClear(832); // Güten reset


  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
//  vFooter # PrtFormOpen(_PrtTypePrintForm,'xFRM.Formularfuss');
//  vHdl # vFooter->WinSearch('pl1');
//  vHdl->ppCaption # 'xxxx';
//  Lib_Print:FrmJobOpen(CnvAi(vNummer,_FmtNumNogroup),vHeader , vFooter,y,y,n);
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);


  // ARCFLOW
//  DMS_ArcFlow:SetDokName('!SC\Verkauf','AB',Auf.Nummer);


// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

  //vAdresse    # Adr.Nummer;
  //vMwstSatz1 # -1.0;
  //vMwstSatz2 # -1.0;
// ------- POSITIONEN --------------------------------------------------------------------------
  vFlag # _RecFirst;

  WHILE (RecLink(401,400,9,vFlag) <= _rLocked ) DO BEGIN      // Auftragspos. holen
    vFlag # _RecNext;

    if ("Auf.P.Löschmarker"='*') then CYCLE;

    // NUR MATERIAL drucken
    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and
      (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false) then CYCLE;

    vFlag2 # _RecFirst;
    WHILE (RecLink(404,401,12,vFlag2) <= _rLocked ) DO BEGIN   //Aktionen holen
      vFlag2 # _RecNext;

      if ("Auf.A.Löschmarker"='*') then CYCLE;

      //
      if (Auf.A.Aktionstyp=c_Akt_DFakt) and (Auf.A.Rechnungsmark='$') then begin
        Erx # Mat_Data:Read(Auf.A.Materialnr);
        if (Erx<200) then CYCLE;
        MaterialDruck();
        vGesamtGewicht # vGesamtGewicht + Auf.A.Gewicht;
        vGesamtStk     # vGesamtStk + "Auf.A.Stückzahl";
      end;

    END; // WHILE: Aktionen ************************************************
 END;   // WHILE:  Positionen **********************************


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
//  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
//    PL_PrintLine;

  Lib_Print:Print_LinieEinzeln(cPos0,cPos9);

  // Summen drucken
  pls_FontAttr # _WinFontAttrBold;
  pls_Fontsize # cFont1;
  PL_Print('Total',cPos7);
  PL_PrintI(vGesamtStk, cPos8);
  PL_PrintF(vGesamtGewicht/1000.0,3, cPos9);

  PL_PrintLine;

  pls_FontAttr # 0;
  PL_PrintLine;

// Produzent erstmal auskommentiert
//  Erx # RecLink(401,400,9,_RecFirst);     // 1.Position holen
//  if (Auf.P.Erzeuger <> 0) then begin
//    PL_Print('Produzent/Ursprung:',cPos0);
//    Erx # RecLink(100,401,10,_recFirst);  // Erzeuger holen
//    PL_Print(Adr.Name,cPosFuss2);
//    PL_PrintLine;
//  end;
  RecLink(815,400,5,_RecFirst);
  PL_Print('Lieferbedingung:',cPos0);
  vA # Lib.Bezeichnung.L1;

  RecLink(835,401,5,_RecFirst);   // Auftragsart holen
  RecLink(101,400,2,_RecFirst);   // Lieferanschrift holen
  vA # Str_ReplaceAll(vA,'%1%',Adr.A.Ort);
  if (AAr.KonsiYN) then vA # vA + ' / Konsignationslager';
  PL_Print(vA,cPosFuss2);
  PL_PrintLine;


  Erx # RecLink(101,400,2,_RecFirst);   // Lieferanschrift holen
  Erx # RecLink(812,101,2,_recFirst);   // Land holen

  vText #  StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd);
  if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Name,_StrBegin | _StrEnd)
  else vText # StrAdj(Adr.A.Name,_StrBegin | _StrEnd);
  if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)
  else vText # StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd);
  if (vText<>'') then vText # vText + ', ' + StrAdj("Adr.A.Straße",_StrBegin | _StrEnd)
  else vText # StrAdj("Adr.A.Straße",_StrBegin | _StrEnd);
  if (vText<>'') then vText # vText + ', ' + StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd)
  else vText # StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd);
  if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Ort,_StrBegin | _StrEnd)
  else vText # StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
  if (vText<>'') then vText # vText + ', ' + StrAdj(Lnd.Name.L1,_StrBegin | _StrEnd)
  else vText # StrAdj(Lnd.Name.L1,_StrBegin | _StrEnd);

  // Leerzeichen am Anfang entfernen
  vText   # StrAdj(vText, _StrBegin | _StrEnd);

  PL_Print('Lieferadresse:',cPos0);
  PL_Print(vText,cPosFuss2,cPos9);
  PL_PrintLine;

  //if (Auf.P.Verwiegungsart <> 0) then begin
  //  PL_Print('Berechnung:',cPos0);
  //  Erx # RecLink(818,401,9,_recFirst)
  //  PL_Print(VwA.Bezeichnung.L1,cPosFuss2);
  //  PL_PrintLine;
  //end;

  //PL_PrintLine;


  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

// -------- Druck beenden ----------------------------------------------------------------

  SeitenFuss(999);

  // letzte Seite & Job schließen, ggf. mit Vorschau
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();


end;



//========================================================================