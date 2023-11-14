@A+
//===== Business-Control =================================================
//
//  Prozedur  Import_Auf
//                OHNE E_R_G
//  Info
//
//
//  02.06.2008  AI  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB Import_TSR()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  GetAlphaUp(a)   : strcnv(FldAlphabyName('X_'+a),_StrUpper)
  GetAlphaMAX(a,b): StrCut(FldAlphabyName('X_'+a),1,b)
  GetAlpha(a)     : FldAlphabyName('X_'+a)
  GetInt(a)     : FldIntbyName('X_'+a)
  GetWord(a)    : FldWordbyName('X_'+a)
  GetNum(a,b)   : Rnd(FldFloatbyName('X_'+a),b)
  GetBool(a)    : FldLogicbyName('X_'+a)
  GetDate(a)    : FldDatebyName('X_'+a)
  GetTime(a)    : FldTimebyName('X_'+a)
end;



//========================================================================
//  GetText
//
//========================================================================
sub GetText(
  aName1  : alpha;
  aName2  : alpha;
)
local begin
  Erx   : int;
  vTxt  : int;
end;
begin
  vTxt # TextOpen(15);
  Erx # TextRead(vTxt,aName1,_TextDba2);
  TxtWrite(vTxt,aName2,0);
  TextClose(vTxt);
end;


//========================================================================
//  Import_TSR
//
//========================================================================
sub Import_TSR()
local begin
  Erx   : int;
  vI    : int;
  vJ    : int;
  vN    : float;
  vTxtHdl : int;
  vNewTxtHdl  : int;
  i       : int;
  vName   : alpha;
  vCount  : int;
end;
begin

// Auftrag: KEINE VPG, KEINE Analyse
// Einkauf: NUR VPG, KEINE Analyse

//DBADisconnect(2);

  Lib_rec:ClearFile(400,'TEXTE');
  Lib_Rec:ClearFile(401,'TEXTE');
  Lib_rec:ClearFile(402,'TEXTE');
  Lib_rec:ClearFile(403,'TEXTE');
  Lib_rec:ClearFile(404,'TEXTE');
  Lib_rec:ClearFile(405,'TEXTE');
  Lib_rec:ClearFile(407,'TEXTE');
  Lib_rec:ClearFile(408,'TEXTE');
  Lib_rec:ClearFile(409,'TEXTE');

//  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2400,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
/**
    If (RecLinkInfo(2404,2400,4, _RecCOunt)>0) then begin
      Erx # RecRead(2400,1,_recNext);
      CYCLE;
    end;
**/
    RecBufClear(400);

    Auf.Nummer            # GetInt('Auf.Nummer');
    Auf.Datum             # GetDate('Auf.Datum');
    Auf.Vorgangstyp       # c_Auf;
    "Auf.GültigkeitVom"   # 0.0.0;
    "Auf.GültigkeitBis"   # 0.0.0;

    Auf.LiefervertragYN   # GetBool('Auf.Liefervertrag?');
    if (Auf.LiefervertragYN) then
      "Auf.GültigkeitBis"   # 31.12.2019;
    Auf.AbrufYN           # GetBool('Auf.Abrufauftrag?');

    Auf.Kundennr          # GetInt('Auf.Kundennummer');
    Erx # RecLink(100,400,1,_recFirst);     // Kunde holen
    Auf.KundenStichwort   # Adr.Stichwort;  //GetAlphaUP('Auf.Kundenstichwort');

    Adr.Kundennr          # GetInt('Auf.Warenempfänger');
    Erx # Recread(100,2,0); // ADresse holen
    if (Erx>_rMultikey) then RecBufClear(100);
    Auf.Lieferadresse     # Adr.Nummer;
    Auf.Lieferanschrift   # 1;
    //GetWord('Auf.Lieferanschrift');
    //if (Auf.Lieferanschrift=0) then Auf.Lieferanschrift # 1
    //else Auf.Lieferanschrift # Auf.Lieferanschrift + 1;

    Auf.Tour              # '';
    Adr.Kundennr          # GetInt('Auf.Verbraucher');
    Erx # Recread(100,2,0); // Adresse holen
    if (Erx>_rMultikey) then RecBufClear(100);
    Auf.Verbraucher       # Adr.Nummer;
    Auf.Rechnungsempf     # GetInt('Auf.Rechempfänger');
    Auf.Rechnungsanschr   # 1;

    Erx # RecLink(100,400,1,_recFirst);     // Kunde holen

    if (Auf.Rechnungsempf=0) then Auf.Rechnungsempf # Auf.Kundennr;
    if (Auf.Lieferadresse=0) then Auf.Lieferadresse # Adr.Nummer;

    Auf.Sachbearbeiter    # GetAlpha('Auf.Sachbearbeiter');
    case Auf.Sachbearbeiter of
      'KOCHENHEIM' :    Auf.Sachbearbeiter # 'GUKO';
      'ROHRANDT' :      Auf.Sachbearbeiter # 'HARO';
      'SUCKER' :        Auf.Sachbearbeiter # 'HASU';
      'RUEFFER' :       Auf.Sachbearbeiter # 'HERÜ';
      'FELDHAUS' :      Auf.Sachbearbeiter # 'HOFE';
      'WEBER' :         Auf.Sachbearbeiter # 'IRWE';
      'HED' :           Auf.Sachbearbeiter # 'KUHE';
      'LAGER' :         Auf.Sachbearbeiter # 'LAGER';
      'WEISS' :         Auf.Sachbearbeiter # 'MAWE';
      'MRO' :           Auf.Sachbearbeiter # 'MIRO';
      'HART' :          Auf.Sachbearbeiter # 'MOHA';
      'NICOLE' :        Auf.Sachbearbeiter # 'NIFE';
      'SCHMIDT' :       Auf.Sachbearbeiter # 'PESCH';
      'RATHMANN' :      Auf.Sachbearbeiter # 'NN';
    end;

    //Auf.Lieferbed         # GetWord('Auf.Lieferbed');
    //Auf.Zahlungsbed       # GetWord('Auf.Zahlungsbed');
    //Auf.Versandart        # GetWord('Auf.Zahlungsbed');
    Auf.Versandart          # GetWord('Auf.Lieferbed');
    Auf.Zahlungsbed         # GetWord('Auf.Zahlungsbed');
    Auf.Lieferbed           # GetWord('Auf.Preisstellung');

    "Auf.Währung"         # GetWord('Auf.Währung');
    "Auf.Währungskurs"    # GetNum('Auf.Währungskurs',5);
    "Auf.WährungFixYN"    # "Auf.Währungskurs"<>0.0;
    Auf.AbmessungsEH      # 'mm';
    Auf.GewichtsEH        # 'kg';
    Auf.Sprache           # Adr.Sprache;
    Auf.Best.Nummer       # GetAlpha('Auf.Bestellnummer');
    Auf.Best.Datum        # GetDate('Auf.Bestelldatum');
    Auf.Best.Bearbeiter   # GetAlpha('Auf.Besteller');
    Auf.BDSNummer         # 0;
    Auf.Land              # '';
    Auf.Vertreter         # GetInt('Auf.Vertreter');
    Auf.Vertreter.Prov    # GetNum('Auf.ProvisionPrz',2);
    Auf.Vertreter.ProT    # GetNum('Auf.ProvisionProT',2);
    "Auf.Löschmarker"     # GetAlpha('Auf.Löschmarker');
    Auf.Aktionsmarker     # GetAlpha('Auf.Aktionsmarker');
    Auf.Aktionsmarker # '';
    "Auf.Steuerschlüssel" # "Adr.Steuerschlüssel";
    Auf.Vertreter2        # 0;
    Auf.Vertreter2.Prov   # 0.0;
    Auf.Vertreter2.ProT   # 0.0;
    Auf.Anlage.Datum      # GetDate('Auf.Anlage.Datum');
    Auf.Anlage.Zeit       # GetTime('Auf.Anlage.Zeit');
    Auf.Anlage.User       # GetAlpha('Auf.Anlage.User');

    // Kopf anlegen...
    Erx # RekInsert(400,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;


    // Positionen loopen...
    Erx # RecLink(2401,2400,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(401);
      RecBufClear(402);

      Auf.P.Nummer          # GetInt('Auf.P.Nummer');
      Auf.P.Position        # GetWord('Auf.P.Position');
      Auf.P.Kundennr        # GetInt('Auf.P.Kundennr');
      Auf.P.KundenSW        # Adr.Stichwort;
      Auf.P.Best.Nummer     # Auf.Best.Nummer;
      Auf.P.Auftragsart     # GetWord('Auf.P.Auftragsart');
      Auf.P.AbrufAufNr      # GetInt('Auf.Abrufauftragsnr');
      Auf.P.AbrufAufPos     # GetWord('Auf.Abrufauftragspos');
      Auf.P.Warengruppe     # GetWord('Auf.P.Warengruppe');
      Erx # RecLink(819,401,1,_recfirst);   // Warengruppe holen

      Auf.P.Artikelnr       # GetAlpha('Auf.P.ArtikelNr');
      Erx # RecLink(250,401,2,_recfirst);   // Artikel holen
      Auf.P.ArtikelID       # Art.ID;
      Auf.P.ArtikelSW       # Art.Stichwort;

      Auf.P.KundenArtNr     # '';
      Auf.P.Sachnummer      # Art.Sachnummer;
      Auf.P.Katalognr       # Art.Katalognr;
      Auf.AF.ObfNr          # GetWord('Auf.P.Oberfläche');
      if (Auf.AF.ObfNr>0) then begin
        Auf.AF.Nummer       # Auf.P.Nummer;
        Auf.AF.Position     # Auf.P.Position;
        Auf.AF.Seite        # '1';
        Auf.AF.lfdNr        # 1;
        RecLink(841,402,1,_recFirst);   // Obf holen
        Auf.AF.Bezeichnung  # Obf.Bezeichnung.L1;
        "Auf.AF.Kürzel"     # "Obf.Kürzel";
        RekInsert(402,0,'MAN');
      end;
      Auf.P.AusfOben        # Auf.AF.Bezeichnung;
      Auf.P.AusfUnten       # '';
      "Auf.P.Güte"          # GetAlpha('Auf.P.Qualität');
      //MQU_Data:Autokorrektur(v"Auf.P.Güte", var Auf.P.Werkstoffnr);
      "Auf.P.Gütenstufe"    # '';
      Auf.P.Werkstoffnr     # GetAlpha('Auf.P.Werkstoffnr');
      Auf.P.Intrastatnr     # '';
      Auf.P.Strukturnr      # '';
      Auf.P.TextNr1         # 401;    // immer individuel
      Auf.P.TextNr2         # 0;
      Auf.P.Dicke           # GetNum('Auf.P.Dicke',Set.Stellen.Dicke);
      Auf.P.Breite          # GetNum('Auf.P.Breite',Set.Stellen.Breite);
      "Auf.P.Länge"         # GetNum('Auf.P.Länge',"Set.Stellen.Länge");
      Auf.P.Dickentol       # GetAlpha('Auf.P.Dickentol');
      Auf.P.Breitentol      # GetAlpha('Auf.P.Breitentol');
      "Auf.P.Längentol"     # GetAlpha('Auf.P.Längentol');
      Auf.P.Zeugnisart      # GetAlpha('Auf.P.Zeugnis');
      //Auf.P.RID             # GetNum('Auf.P.Innendurchm',Set.Stellen.Radien);
      //Auf.P.RIDMax          # GetNum('Auf.P.InnendurchmMax',Set.Stellen.Radien);
      //Auf.P.RAD             # GetNum('Auf.P.Außendurchm',Set.Stellen.Radien);
      //Auf.P.RADMax          # GetNum('Auf.P.AußendurchmMax',Set.Stellen.Radien);

      "Auf.P.Stückzahl"     # GetInt('Auf.P.Stückzahl');
      vI                    # GetInt('Auf.P.GeliefertStk');

      Auf.P.Gewicht         # GetNum('Auf.P.Gewicht',Set.Stellen.Gewicht);
      vN                    # GetNum('Auf.P.Geliefert',Set.Stellen.Gewicht);

      if (vI<>0) or (vN<>0.0) then begin
//        Auf.P.Kundenartnr # cnvai("Auf.P.Stückzahl")+' Stk   '+ANum(Auf.P.Gewicht,0)+' kg';
        RecBufClear(404);
        Erx # RecLink(100,401,4,_Recfirst);   // Kunde holen...
        Auf.A.Nummer      # Auf.P.Nummer;
        Auf.A.Position    # Auf.P.Position;
        Auf.A.Aktion      # 1;
        Auf.A.Aktionstyp  # 'INFO';
        Auf.A.MEH           # Auf.P.MEH.Preis;
        Auf.A.MEH.Preis     # '';//Auf.P.MEH.Preis;
        Auf.A.Adressnummer  # Adr.Nummer;
        Auf.A.TerminStart   # today;
        Auf.A.TerminEnde    # today;
        Auf.A.Aktionsdatum  # today;
        Auf.A.Bemerkung     # 'ALT:'+cnvai("Auf.P.Stückzahl")+' Stk   '+ANum(Auf.P.Gewicht,0)+' kg';
        RekInsert(404,0,'AUTO');
      end;

      "Auf.P.Stückzahl" # "Auf.P.Stückzahl" - vI;
      Auf.P.Gewicht # Auf.P.Gewicht - vN;
      Auf.P.Menge.Wunsch    # Auf.P.Gewicht;


      Auf.P.MEH.Wunsch      # 'kg';
      Auf.P.PEH             # GetInt('Auf.P.Preiseinheit');
      Auf.P.MEH.Preis       # GetAlpha('Auf.P.Mengeneinheit');
      Auf.P.Grundpreis      # GetNum('Auf.P.Grundpreis',2);
      Auf.P.AufpreisYN      # GetBool('Auf.P.Aufpreise?');
      Auf.P.Aufpreis        # GetNum('Auf.P.Aufpreis',2);
      Auf.P.Einzelpreis     # GetNum('Auf.P.Einzelpreis',2);
      Auf.P.Gesamtpreis     # GetNum('Auf.P.Gesamtpreis',2);
      Auf.P.Kalkuliert      # 0.0;
      Auf.P.Termin1W.Art    # 'KW';
      Auf.P.Termin1W.Zahl   # GetWord('Auf.P.WTerminKW');
      Auf.P.Termin1W.Jahr   # GetWord('Auf.P.WTerminJahr');
      Auf.P.Termin1Wunsch   # GetDate('Auf.P.WTerminDatum');
      Auf.P.Termin2W.Zahl   # 0;
      Auf.P.Termin2W.Jahr   # 0;
      Auf.P.Termin2Wunsch   # 0.0.0;
      Auf.P.TerminZ.Zahl    # GetWord('Auf.P.TerminKW');
      Auf.P.TerminZ.Jahr    # GetWord('Auf.P.TerminJahr');
      Auf.P.TerminZusage    # GetDate('Auf.P.TerminDatum');
      if (Auf.LiefervertragYN) and (Auf.P.TerminZusage=0.0.0) then
        Auf.P.TerminZusage   # 31.12.2019;

      Auf.P.Bemerkung       # GetAlpha('Auf.P.Positionstext');
      Auf.P.Erzeuger        # 0;
      Auf.P.Menge           # Auf.P.Gewicht;
      Auf.P.MEH.Einsatz     # 'kg';
      Auf.P.Projektnummer   # 0;
      Auf.P.Termin.Zusatz   # '';
      Auf.P.Vertr1.Prov     # Auf.Vertreter.Prov;
      Auf.P.Vertr2.Prov     # 0.0;

      "Auf.P.Löschmarker"   # GetAlpha('Auf.P.Löschmarker');
      if ("Auf.P.Löschmarker"='') then begin
        "Auf.P.Lösch.Datum"  # 0.0.0;
        "Auf.P.Lösch.Zeit"   # 0:0;
        "Auf.P.Lösch.User"   # '';
        end
      else begin
        "Auf.P.Lösch.Datum"  # today;
        "Auf.P.Lösch.Zeit"   # now;
        "Auf.P.Lösch.User"   # gUsername;
      end;

      Auf.P.Aktionsmarker   # GetAlpha('Auf.P.Aktionsmarker');
      Auf.P.Aktionsmarker # '';
      Auf.P.Wgr.Dateinr     # Wgr.Dateinummer;
      Auf.P.Artikeltyp      # Art.Typ;
      Auf.P.Materialnr      # 0;
      Auf.P.GesamtwertEKW1  # 0.0;
      Auf.P.Prd.Plan        # 0.0;
      Auf.P.Prd.Plan.Stk    # 0;
      Auf.P.Prd.Plan.Gew    # 0.0;
      Auf.P.Prd.VSB         # 0.0;
      Auf.P.Prd.VSB.Stk     # 0;
      Auf.P.Prd.VSB.Gew     # 0.0;
      Auf.P.Prd.VSAuf       # 0.0;
      Auf.P.Prd.VSAuf.Stk   # 0;
      Auf.P.Prd.VSAuf.Gew   # 0.0;
      Auf.P.Prd.LFS         # 0.0;
      Auf.P.Prd.LFS.Stk     # 0;
      Auf.P.Prd.LFS.Gew     # 0.0;
      Auf.P.Prd.Rech        # 0.0;
      Auf.P.Prd.Rech.Stk    # 0;
      Auf.P.Prd.Rech.Gew    # 0.0;
      Auf.P.Prd.zuBere      # 0.0;
      Auf.P.Prd.zuBere.Stk  # 0;
      Auf.P.Prd.zuBere.Gew  # 0.0;
      Auf.P.GPl.Plan        # 0.0;
      Auf.P.GPl.Plan.Stk    # 0;
      Auf.P.GPl.Plan.Gew    # 0.0;
      Auf.P.Prd.Rest        # Auf.P.Menge - Auf.P.Prd.LFS;
      Auf.P.Prd.Rest.Stk    # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
      Auf.P.Prd.Rest.Gew    # Auf.P.Gewicht - Auf.P.Prd.LFS.Gew;

      Auf.P.Anlage.Datum    # GetDate('Auf.P.Anlage.Datum');
      Auf.P.Anlage.Zeit     # GetTime('Auf.P.Anlage.Zeit');
      Auf.P.Anlage.User     # GetAlpha('Auf.P.Anlage.User');

      // Position anlegen...
      Erx # Auf_Data:PosInsert(0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;

      // Text kopieren...
      Erx # RecLink(2402,2401,2,_RecFirst);   // Text holen
      if (Erx<=_rLocked) then begin
        vI # GetWord('Auf.T.Texttyp');
        vJ # GetInt('Auf.T.TextNummer');
        if (vI=402) then begin
          //'it.402.x.001'
          GetText('~it.402.'+cnvai(Auf.P.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.001',
                  '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+
                      CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3));
          end
        else if (vI=830) then begin
          //'it.830.x.000'
          GetText('~it.830.'+cnvai(vJ,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',
                  '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+
                      CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3));
        end
        else if (vI=250) then begin
          //'it.250.ARTID.000'
          GetText('~it.250.'+cnvai(vJ,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',
                  '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+
                      CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3));
        end;
      end;




      // Stückliste anlegen...
      RecBufClear(409);
      Auf.SL.Nummer         # Auf.P.Nummer;
      Auf.SL.Position       # Auf.P.Position;
      Auf.SL.lfdNr          # 1;
      Auf.SL.Bemerkung      # '';
      Auf.SL.MEH            # 'kg';
      Auf.SL.PreisW1.EK     # 0.0;
      Auf.SL.PEH.EK         # 1000;
      Auf.SL.MEH.EK         # 'kg';
      Auf.SL.Gesamtwert.EK  # 0.0;
      Auf.SL.ArtikelNr      # Auf.P.Artikelnr;
      Auf.SL.Dicke          # Art.Dicke;
      Auf.SL.Breite         # Art.Breite;
      "Auf.SL.Länge"        # "Art.Länge";
      Auf.SL.Menge          # GetNum('Auf.P.Außendurchm',Set.Stellen.Gewicht);
      "Auf.SL.Stückzahl"    # cnvif(GetNum('Auf.P.Innendurchm',0));
      Auf.SL.Gewicht        # Auf.SL.Menge;
      Auf.SL.Anlage.User    # Auf.P.Anlage.User;
      Auf.SL.Anlage.Datum   # Auf.P.Anlage.Datum;
      Auf.SL.Anlage.Zeit    # Auf.P.Anlage.Zeit;
      Erx # RekInsert(409,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;

      Erx # RecLink(2401,2400,1,_recNext);
    END;    // Positionen



    vI # 0;
    // Aufpreise loopen...
    Erx # RecLink(2403,2400,3,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      vI # vI + 1;
      RecbufClear(403);
      Auf.Z.Nummer            # GetInt('Auf.Z.Nummer');
      Auf.Z.Position          # GetWord('Auf.Z.Position');
      Auf.Z.lfdNr             # vI;
      "Auf.Z.Schlüssel"       # GetAlpha('Auf.Z.Schlüssel');
      Auf.Z.Menge             # GetNum('Auf.Z.Menge',Set.Stellen.Menge);
      Auf.Z.MEH               # GetAlpha('Auf.Z.Mengeneinheit');
      if (StrCnv(Auf.Z.MEH,_StrUpper)='POS') then
        Auf.Z.MEH # 'Stk';
      Auf.Z.PEH               # GetInt('Auf.Z.Preiseinheit');
      Auf.Z.MengenbezugYN     # Getbool('Auf.Z.Mengenaufpreis');
      Auf.Z.RabattierbarYN    # GetBool('Auf.Z.Rabattierfähig');
      Auf.Z.NeuberechnenYN    # GetBool('Auf.Z.Neuberechnung');
      Auf.Z.Preis             # GetNum('Auf.Z.Aufpreis',2);
      Auf.Z.Bezeichnung       # GetAlpha('Auf.Z.Bezeichnung');
      if (StrCut("Auf.Z.Schlüssel",1,1)>='0') and
        (StrCut("Auf.Z.Schlüssel",1,1)<='9') then
        "Auf.Z.Schlüssel" # '#0'+"Auf.Z.Schlüssel";

      // Aufpreis anlegen...
      Erx # RekInsert(403,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;

      Erx # RecLink(2403,2400,3,_recNext);
    END;  // Aufpreise


    Erx # RecRead(2400,1,_recNext);
  END;    // Köpfe


  TRANSOFF;

  DBADisconnect(2)



  // Texte reparieren...
  vTxtHdl # TextOpen(23);
  vNewTxtHdl # TextOpen(23);

  Erx # RecRead(400,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(401,400,9,_recFirst);     // Positionen loopen
    WHILE (Erx<=_rLocked) do begin
      // überhaupt ein $$ suchen...
      // ja -> $$+(D) suchen...
      TextClear(vTxtHdl);
      TextClear(vNewTxtHdl);
      vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TextRead(vTxtHdl,vName,0);
      Erx # TextSearch(vTxtHdl,1,1,0,'$$')
      if (Erx > 0) then begin
        Erx # TextSearch(vTxtHdl,1,1,0,'$$'+Auf.Sprache);
        if (Erx<=0) then begin
          Auf.Sprache # 'D';
          Erx # TextSearch(vTxtHdl,1,1,0,'$$'+Auf.Sprache);
        end;
        if (Erx > 0) then begin
          vCount # 1;
          FOR i # Erx+1;
          LOOP begin inc(i); inc(vCount); end;
          WHILE ((StrFind(TextLineRead(vTxtHdl,i,0),'$$',1)=0) and TextInfo(vTxtHdl,_TextLines)>=i) DO begin
             TextLineWrite(vNewTxtHdl,vCount,TextLineRead(vTxtHdl,i,0),_TextLineInsert);
          END;
        end;

        //TxtWrite(vNewTxtHdl,'!!!1Thyssentest',0);
        TxtDelete(vName,0);
        TxtWrite(vNewTxtHdl,vName,0);
      end;

      Erx # RecLink(401,400,9,_recNext);
    END;

    Erx # RecRead(400,1,_recNext);
  END;

  TextClose(vNewTxtHdl);
  TextClose(vTxtHdl);




  Msg(99,'Alle Aufträge wurden importiert!',0,0,0);
end;


//========================================================================