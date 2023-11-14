@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_REK_BerichtLf
//                    OHNE E_R_G
//  Info
//    Druckt einen Beanstandungsbericht Lieferant
//
//
//  25.06.2008  DS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB MaterialDruck();
//    SUB HoleEmpfaenger();
//    SUB SeitenKopf();
//    SUB Print(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_Aktionen

declare Print(aTyp : alpha);

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
//  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Bez.
  cPos2a  :  50.0   // Werte
  cPos2c  :  70.0   // Dimensions Toleranzen
  cPos2d  :  80.0   // Werte Toleranzen
  cPos5   : 120.0   // Stückzahl Aktionen
  cPos5a  : 122.0   // Einheit Stk
  cPos8   : 155.0   // Stück
  cPos8a  : 157.0   // Einheit
  cPos9   : 182.0   // Gewicht

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 170.0
  cPosKopf4 : 172.0
end;

local begin
  vSumStk             : int;
  vSumGewicht         : float;
  vSumGesamt          : float;
  vSumAnerkannt       : float;
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
  RecLink(100,300,10,_RecFirst);   // Lieferanten holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Rek.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)+'.1'; // Dokumentennummer
end;


//========================================================================
//  MaterialDruck
//            Druckt die Materialdaten für ein Druckformular
//            Wird benötigt allen Druckroutinen
//========================================================================
sub MaterialDruck();
local begin
  Erx       : int;
  vVerp     : alpha(1000);
  vFlag     : int;
  vStk      : int;
  vGewicht  : float;
  vMerker   : alpha;
  vTxtName  : alpha;
  vFirst    : logic;
  vWert     : float;
  vUrsprung : int;
end;
begin
  //Ursprungsmaterial holen
  Erx # RecLink(200,301,3,_recFirst);
  if(Erx > _rLocked) then begin
    Erx # RecLink(210,301,4,_recFirst);
    if (Erx > _rLocked) then RecBufClear(210);
    RecBufCopy(210,200);
  end;

  vUrsprung # Mat.Ursprung;
  Mat.Nummer # vUrsprung;

  Erx # Mat_Data:Read(Mat.Nummer);

  Erx # RecLink(819,200,1,_recFirst);
  if (Erx > _rLocked) then RecBufClear(819);

  // -- Positionsdaten --
  PL_Print(AInt(Rek.P.Position),cPos1);
  PL_Print(Wgr.Bezeichnung.L1+'/'+"Mat.Güte",cPos2);
  PL_PrintI("Rek.P.Stückzahl",cPos8);
  PL_PrintF(Rek.P.Gewicht,Set.Stellen.Gewicht,cPos9)
  PL_PrintLine;
  PL_Print('',cpos2)
  PL_PrintLine;

  //Ausführung
  if "Mat.AusführungOben" <> '' or "Mat.AusführungUnten" <> '' then begin
    PL_Print('Ausführung:',cPos2);
    //vVerp ausgeliehen für Ausführungstext
    // Oben/Vorderseite
    if ("Mat.AusführungOben" <> '') then begin
        //Kürzel nach Bezeichnung auflösen
        vFlag # _RecFirst;
        WHILE (RecRead(201,1,vFlag) <= _rLocked ) DO BEGIN
          vFlag # _RecNext;
          if ("Mat.AF.Kürzel" = "Mat.AusführungOben") then vVerp # 'Vorderseite: ' + Mat.AF.Bezeichnung;
        END;
    end;
    // Unten/Rückseite
    if ("Mat.AusführungUnten" <> '') then begin
      //Kürzel nach Bezeichnung auflösen
      vFlag # _RecFirst;
      WHILE (RecRead(201,1,vFlag) <= _rLocked ) DO BEGIN
        vFlag # _RecNext;
        if ("Mat.AF.Kürzel" = "Mat.AusführungUnten")then vMerker # Mat.AF.Bezeichnung;
      END;
      if (vVerp <> '') then
        vVerp # vVerp + '    Rückseite: ' + vMerker;
      else
        vVerp # 'Rückseite: ' + vMerker;
    end;
    PL_Print(vverp,cpos2a);
    PL_PrintLine;
  end;

  //Dicke
  if (Mat.Dicke<>0.0) then begin
    PL_Print('Dicke mm:',cpos2);
    PL_PrintF_L(Mat.Dicke,Set.Stellen.Dicke,cpos2a);
    if (Mat.Dickentol<>'') then begin
      PL_Print('Tol.:',cpos2c);
      PL_Print(Mat.Dickentol,cpos2d)
    end;
    PL_PrintLine;
  end;

  //Breite
  if (Mat.Breite<>0.0) then begin
    PL_Print('Breite mm:',cpos2);
    PL_PrintF_L(Mat.Breite,Set.Stellen.Breite,cpos2a);
    if (Mat.Breitentol <> '') then begin
      PL_Print('Tol.:',cPos2c);
      PL_Print(Mat.Breitentol,cPos2d);
    end;
    PL_PrintLine;
  end;

  //Länge
  if ("Mat.Länge"<>0.0)then begin
    PL_Print('Länge mm:', cpos2);
    PL_PrintF_L("Mat.Länge","Set.Stellen.Länge",cpos2a)
    if ("Mat.Längentol" <> '') then begin
      PL_Print('Tol.:',cPos2c);
      PL_Print("Mat.Längentol",cPos2d);
    end;
    PL_PrintLine;
  end;

  PL_PrintLine;

  //Materialdaten
  if (Mat.Coilnummer<>'') then vVerp # 'Band  '+Mat.Coilnummer;
  else vVerp # '          ' + Mat.Coilnummer;
  if (Mat.Ringnummer<>'') then vVerp # vVerp + '  Tafel  '+ Mat.Ringnummer;
  if (Mat.Chargennummer<>'') then vVerp # vVerp + '  Charge  '+Mat.Chargennummer;
    vVerp # vVerp + '        ' +AInt("Rek.P.Stückzahl")+' Stk. / '+ANum(Rek.P.Gewicht,Set.Stellen.Gewicht)+' kg'
  PL_Print(vVerp, cPos2);
  PL_PrintLine;
  PL_PrintLine;

  //Beanstandungsgrund
  PLs_FontSize # 8;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Beanstandungsgrund:', cPos2);
  PL_PrintLine;
  PL_PrintLine;
  pls_Fontattr # 0;
  vTxtName # '~301.'+CnvAI(Rek.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Rek.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.1';
  Lib_Print:Print_Text(vTxtName, 1, cPos2, cPos9);

  PL_PrintLine;

  //Aktionen durchlaufen
  vFirst # y;
  Erx # RecLink(302,301,2,_recFirst);
  While (Erx<=_rLocked) do begin
    if (vFirst) then begin
    vFirst # n;
      PL_Print('Datum',cPos2);
      PL_Print('Aktion',cPos2a);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPos2,cPos8a+5.0);
    end;
    PL_PrintD_L(Rek.A.Aktionsdatum,cPos2);
    PL_Print(Rek.A.Aktionstyp+' '+cnvAI(Rek.A.Aktionsnr,_FmtNumNoGroup,0,0)+'/'
                                 +cnvAI(Rek.A.Aktionspos,_FmtNumNoGroup,0,0),cPos2a);
    PL_PrintI("Rek.A.Stückzahl",cPos5);
    PL_Print('Stk',cPos5a);
    PL_PrintF(Rek.A.Menge,2,cPos8);
    PL_Print(Rek.A.MEH,cPos8a);
    PL_PrintLine;
    PL_Print(Rek.A.Bemerkung,cPos2a);
    vWert # ((Rek.A.Menge * Rek.A.Kosten)/cnvFI(Rek.A.PEH));
    PL_PrintF(vWert,2,cPos8);
    PL_Print("Wae.Kürzel",cPos8a);
    PL_PrintLine;
    Erx # RecLink(302,301,2,_recNext);
  END;

  PL_PrintLine;  //Leerzeile


  // Ursache andrucken
  PL_Print('Ursache',cPos2);
  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln(cPos2,cPos8a+5.0);
  Erx # RecLink(851,301,8,_recFirst);
  if (Erx > _rLocked) then RecBufClear(851);
  PL_Print(FhC.Bezeichnung,cPos2);
  PL_PrintI("Rek.P.Stückzahl",cPos5);
  PL_Print('Stk',cPos5a);
  PL_PrintF(Rek.P.Menge,2,cPos8);
  PL_Print(Rek.P.MEH,cPos8a);
  PL_PrintLine;
  if (Rek.P.Verursacher = 1) then begin
    PL_Print('Verursacher: '+Rek.P.VerursacherSW,cPos2);
    PL_PrintF(Rek.P.Wert,2,cPos8);
    PL_Print("Wae.Kürzel",cPos8a);
  end else if (Rek.P.Verursacher = 2) then begin
    PL_Print('Verursacher: '+Rek.P.VerursacherSW,cPos2);
    PL_PrintF(Rek.P.Wert,2,cPos8);
    PL_Print("Wae.Kürzel",cPos8a);
  end else if (Rek.P.Verursacher = 3) then begin
    // Person nicht im Verursacherstichwort
    PL_PrintF(Rek.P.Wert,2,cPos8);
    PL_Print("Wae.Kürzel",cPos8a);
  end else if (Rek.P.Verursacher = 4) then begin
    PL_Print('Verursacher: Unbekannt',cPos2);
    PL_PrintF(Rek.P.Wert,2,cPos8);
    PL_Print("Wae.Kürzel",cPos8a);
  end;
  PL_PrintLine;

  PL_PrintLine;

end;

//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  Erx     : int;
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
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx         : int;
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
  RecLink(100,300,10,_RecFirst);   // Lieferanten holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  Erx # RecLink(501,300,5,_recFirst);
  if (Erx <= _rLocked) then RecLink(500,501,3,_recFirst);
  else begin
    Erx # RecLink(511,300,7,_recFirst);
    if (Erx <= _rLocked) then begin
      RecBufCopy(511,501);
      RecBufCopy(510,500);
    end
    else begin
      RecBufClear(511);
      RecBufClear(510);
      RecBufCopy(511,501);
      RecBufCopy(510,500);
    end;
  end;

  // SCRIPTLOGIK
  //if (Scr.B.Nummer<>0) then HoleEmpfaenger();


  ///Pls_fontSize # 6
  //pls_Fontattr # _WinFontAttrU;
  //PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Name     , cPos0);
  //Pls_fontSize # 9;
  PL_Print('vom:',cPosKopf1);
  PL_PrintD_L(Rek.Datum,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Zusatz   , cPos0);
  //Pls_fontSize # 9;
  PL_Print('Kundennummer:',cPosKopf1);
  PL_PrintI_L(Ein.Lieferantennr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  //Pls_fontSize # 9;
  Usr.Username # Rek.Sachbearbeiter;            // Sachbearbeiter holen
  Erx # RecRead(800,1,0);
  PL_Print('Sachbearbeiter:',cPosKopf1);
  PL_Print(Usr.Vorname +' '+Usr.Name,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
  //Pls_fontSize # 9;
  Usr.Username # Rek.Aktenuser;            // Aktenuser holen
  Erx # RecRead(800,1,0);
  PL_Print('Akte:',cPosKopf1);
  PL_Print(Usr.Vorname +' '+Usr.Name,cPosKopf2);
  PL_PrintLine;

  RecLink(812,101,2,_recFirst);   // Land holen
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  PL_PrintLine;

  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  PL_PrintLine;
  pl_PrintLine;
  pl_PrintLine;
  Pl_Print('Beanstandungsbericht'+' '+AInt(Rek.P.Nummer)   ,cPos0 );
  PL_Print('Datum: '+cnvAD(today,_FmtInternal),cPosKopf1);
  PL_Print_R('Seite: '+cnvAI(aSeite,_FmtNone,0,0),cPos9);
  PL_PrintLine;
  pl_PrintLine;
  pl_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print('Auftragsnummer:',cPos0);
  PL_Print(Ein.AB.Nummer,cPos2a);
  PL_Print('Gesamtwert:',cPosKopf1);
  PL_PrintF(vSumGesamt,2,cPosKopf3);
  PL_Print("Wae.Kürzel",cPosKopf4);
  PL_PrintLine;

  PL_Print('Bestellnummer:',cPos0);
  PL_PrintI_L(Ein.Nummer,cPos2a);
  PL_Print('Anerkannt:',cPosKopf1);
  PL_PrintF(vSumAnerkannt,2,cPosKopf3);
  PL_Print("Wae.Kürzel",cPosKopf4);
  PL_PrintLine;
  PL_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # 0;

/*
  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('Wir bestätigen den Eingang Ihrer Beanstandung über die nachfolgenden Positionen:',cPos0);
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;


    // Kopftext drucken
    //vTxtName # '~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
    //Lib_Print:Print_Text(vTxtName,1, cPos0);
  end; // 1.Seite
*/

  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('Pos.',cPos1);
    PL_Print('Beschreibung',cPos2);
    PL_Print_R('Stück',cPos8);
    PL_Print_R('Gewicht kg',cPos9);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;

  RekRestore(vBuf100);
  RekRestore(vBuf101);
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
    'Summe' : begin
      // Summen drucken
      //pls_Fontsize # 9;
      //pls_FontAttr # _WinFontAttrBold;
      PL_PrintI(vSumStk,cPos8);
      PL_PrintF(vSumGewicht,Set.Stellen.Gewicht,cPos9);
      pls_FontAttr # 0;
      PL_PrintLine;
    end;  // Summe ----------------------------

  end;  // case

end;

//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
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
  RecLink(300,301,1,_recFirst)    // Kopf holen
  RecLink(100,300,9,_RecFirst);   // Kunde holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  RecLink(814,300,8,_RecFirst);   // Währung holen

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);


  // ARCFLOW
  //DMS_ArcFlow:SetDokName('!SC\Verkauf','AB',Auf.Nummer);

// ------- KOPFDATEN -----------------------------------------------------------------------
  vSumGesamt # 0.0;
  vSumAnerkannt # 0.0;
  WHILE (RecLink(301,300,1,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    if ("Rek.P.Löschmarker"='*') then CYCLE;

    vSumGesamt # vSumGesamt + Rek.P.Wert;
    vSumAnerkannt # vSumAnerkannt + Rek.P.Aner.Wert;

  END; // WHILE: Positionen ************************************************

  Lib_Print:Print_Seitenkopf();

  //vAdresse    # Adr.Nummer;

// ------- POSITIONEN --------------------------------------------------------------------------

  vSumStk # 0;
  vSumGewicht # 0.0;
  vFlag # _RecFirst;

  WHILE (RecLink(301,300,1,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    if ("Rek.P.Löschmarker"='*') then CYCLE;

    MaterialDruck();

  END; // WHILE: Positionen ************************************************


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss

  //WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(100.0,_PrtUnitMillimetres)) do
  //  PL_PrintLine;
  //Lib_Print:Print_LinieDoppelt();


  //Print('Summe');
  //PL_PrintLine;
  //PL_PrintLine;
  pls_FontSize  # 10;
  //PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;


//=======================================================================