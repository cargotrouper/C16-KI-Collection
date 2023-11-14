@A+
//===== Business-Control =================================================
//
//  Prozedur  Import_Ein
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
  GetInt(a)       : FldIntbyName('X_'+a)
  GetWord(a)      : FldWordbyName('X_'+a)
  GetNum(a,b)     : Rnd(FldFloatbyName('X_'+a),b)
  GetBool(a)      : FldLogicbyName('X_'+a)
  GetDate(a)      : FldDatebyName('X_'+a)
  GetTime(a)      : FldTimebyName('X_'+a)
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
  vA    : alpha;
  vName       : alpha;
  vCount      : int;
  vTxtHdl     : int;
  I           : int;
  vNewTxtHdl  : int
end;
begin

// Auftrag: KEINE VPG, KEINE Analyse
// Einkauf: NUR VPG, KEINE Analyse

//DBADisconnect(2);

  Lib_Rec:ClearFile(500,'TEXTE');
  Lib_Rec:ClearFile(501,'TEXTE');
  Lib_Rec:ClearFile(502,'TEXTE');
  Lib_Rec:ClearFile(503,'TEXTE');
  Lib_Rec:ClearFile(504,'TEXTE');
  Lib_Rec:ClearFile(505,'TEXTE');
  Lib_Rec:ClearFile(507,'TEXTE');

//  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2500,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
/**
    If (RecLinkInfo(2404,2400,4, _RecCOunt)>0) then begin
      Erx # RecRead(2400,1,_recNext);
      CYCLE;
    end;
**/
    RecBufClear(500);
    Ein.Vorgangstyp       # c_Bestellung;
    Ein.Nummer            # GetInt('Ein.Nummer');
    Ein.Datum             # GetDate('Ein.Datum');
    //Ein.Vorgangstyp       # c_Auf;
    Ein.LiefervertragYN   # GetBool('Ein.Abschluß?');

    Ein.Lieferantennr     # GetInt('Ein.Lieferant');
    Erx # RecLink(100,500,1,_recFirst);     // Lieferant holen
    Ein.LieferantenSW     # Adr.Stichwort;  //GetAlphaUP('Ein.Kundenstichwort');

    RecBufClear(100);
    Adr.Kundennr          # GetInt('Ein.Lieferadresse');
    Erx # Recread(100,2,0); // Adresse holen
    if (Erx>_rMultikey) then RecBufClear(100);
    Ein.Lieferadresse     # Adr.Nummer;
    Ein.Lieferanschrift   # 1;
    //GetWord('Ein.Lieferanschrift');
    //if (Ein.Lieferanschrift=0) then Ein.Lieferanschrift # 1
    //else Ein.Lieferanschrift # Ein.Lieferanschrift + 1;

    Ein.Tour              # '';
    RecBufClear(100);
    Adr.Kundennr          # GetInt('Ein.Verbraucher');
    Erx # Recread(100,2,0); // ADresse holen
    if (Erx>_rMultikey) then RecBufClear(100);
    Ein.Verbraucher       # Adr.Nummer;
    Ein.Rechnungsempf     # 0;

    Erx # RecLink(100,500,1,_recFirst);     // Lieferant holen

    //if (Ein.Rechnungsempf=0) then Ein.Rechnungsempf # Ein.Kundennr;
    if (Ein.Lieferadresse=0) then begin
      Ein.Lieferadresse   # Set.eigeneAdressnr;
      Ein.Lieferanschrift # 1;
    end;

    Ein.Sachbearbeiter    # GetAlpha('Ein.Sachbearbeiter');
    case Ein.Sachbearbeiter of
      'KOCHENHEIM' :    Ein.Sachbearbeiter # 'GUKO';
      'ROHRANDT' :      Ein.Sachbearbeiter # 'HARO';
      'SUCKER' :        Ein.Sachbearbeiter # 'HASU';
      'RUEFFER' :       Ein.Sachbearbeiter # 'HERÜ';
      'FELDHAUS' :      Ein.Sachbearbeiter # 'HOFE';
      'WEBER' :         Ein.Sachbearbeiter # 'IRWE';
      'HED' :           Ein.Sachbearbeiter # 'KUHE';
      'LAGER' :         Ein.Sachbearbeiter # 'LAGER';
      'WEISS' :         Ein.Sachbearbeiter # 'MAWE';
      'MRO' :           Ein.Sachbearbeiter # 'MIRO';
      'HART' :          Ein.Sachbearbeiter # 'MOHA';
      'NICOLE' :        Ein.Sachbearbeiter # 'NIFE';
      'SCHMIDT' :       Ein.Sachbearbeiter # 'PESCH';
      'RATHMANN' :      Ein.Sachbearbeiter # 'NN';
    end;


    Ein.Lieferbed         # GetWord('Ein.Lieferbed');
    Ein.Zahlungsbed       # GetWord('Ein.Zahlungsbed');   // ???
    Ein.Versandart        # 0;//GetWord('Ein.Preisstellung'); // ???
    "Ein.Währung"         # GetWord('Ein.Währung');
    "Ein.Währungskurs"    # 0.0;//GetNum('Ein.Währungskurs',5);
    "Ein.WährungFixYN"    # "Ein.Währungskurs"<>0.0;
    Ein.AbmessungsEH      # 'mm';
    Ein.GewichtsEH        # 'kg';
    Ein.Sprache           # Adr.Sprache;
    Ein.AB.Nummer         # GetAlpha('Ein.Bestellnummer');
    Ein.AB.Datum          # GetDate('Ein.Bestelldatum');
    Ein.AB.Bearbeiter     # GetAlpha('Ein.Bearbeiter');
    Ein.BDSNummer         # 0;
    Ein.Land              # '';
    "Ein.Löschmarker"     # GetAlpha('Ein.Löschmarker');
    //Ein.Aktionsmarker     # GetAlpha('Ein.Aktionsmarker');
    Ein.Aktionsmarker # '';
    Ein.Anlage.Datum      # GetDate('Ein.Anlage.Datum');
    Ein.Anlage.Zeit       # GetTime('Ein.Anlage.Zeit');
    Ein.Anlage.User       # GetAlpha('Ein.Anlage.User');

    // Kopf anlegen...
    Erx # RekInsert(500,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;


    // Positionen loopen...
    Erx # RecLink(2501,2500,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(501);
      RecBufClear(502);

      Ein.P.Nummer          # GetInt('Ein.P.Nummer');
      Ein.P.Position        # GetWord('Ein.P.Position');
      Ein.P.Lieferantennr   # Ein.Lieferantennr;
      Ein.P.LieferantenSW   # Ein.LieferantenSW;
      Ein.P.AB.Nummer       # Ein.AB.Nummer;
      Ein.P.Auftragsart     # 500;//GetWord('Ein.P.Auftragsart');
      Ein.P.AbrufAufNr      # 0;//GetInt('Ein.Abrufauftragsnr');
      Ein.P.AbrufAufPos     # 0;//GetWord('Ein.Abrufauftragspos');
      Ein.P.Warengruppe     # GetWord('Ein.P.Warengruppe');
      Erx # RecLink(819,501,1,_recfirst);   // Warengruppe holen

      Ein.P.Artikelnr       # GetAlpha('Ein.P.ArtikelNr');
      Erx # RecLink(250,501,2,_recfirst);   // Artikel holen
      Ein.P.ArtikelID       # Art.ID;
      Ein.P.ArtikelSW       # Art.Stichwort;

      Ein.P.LieferArtNr     # '';
      Ein.P.Sachnummer      # Art.Sachnummer;
      Ein.P.Katalognr       # Art.Katalognr;
      Ein.AF.ObfNr          # GetWord('Ein.P.Oberfläche');
      if (Ein.AF.ObfNr>0) then begin
        Ein.AF.Nummer       # Ein.P.Nummer;
        Ein.AF.Position     # Ein.P.Position;
        Ein.AF.Seite        # '1';
        Ein.AF.lfdNr        # 1;
        RecLink(841,502,1,_recFirst);   // Obf holen
        Ein.AF.Bezeichnung  # Obf.Bezeichnung.L1;
        "Ein.AF.Kürzel"     # "Obf.Kürzel";
        RekInsert(502,0,'MAN');
      end;
      Ein.P.AusfOben        # Ein.AF.Bezeichnung;
      Ein.P.AusfUnten       # '';
      "Ein.P.Güte"          # GetAlpha('Ein.P.Qualität');
      //"Ein.P.Güte" # MQU_Data:Autokorrektur("Ein.P.Güte");
      "Ein.P.Gütenstufe"    # '';
      Ein.P.Werkstoffnr     # GetAlphaMAX('Ein.P.Werkstoffnr',8);
      Ein.P.Intrastatnr     # '';
      Ein.P.Strukturnr      # '';
      Ein.P.TextNr1         # 501;    // immer individuel
      Ein.P.TextNr2         # 0;
      Ein.P.Dicke           # GetNum('Ein.P.Dicke',Set.Stellen.Dicke);
      Ein.P.Breite          # GetNum('Ein.P.Breite',Set.Stellen.Breite);
      "Ein.P.Länge"         # GetNum('Ein.P.Länge',"Set.Stellen.Länge");
      Ein.P.Dickentol       # GetAlpha('Ein.P.Dickentol');
      Ein.P.Breitentol      # GetAlpha('Ein.P.Breitentol');
      "Ein.P.Längentol"     # GetAlpha('Ein.P.Längentol');
      Ein.P.Zeugnisart      # GetAlpha('Ein.P.Zeugnis');
      Ein.P.Kommission      # GetAlpha('Ein.P.Kommission');

      if (StrLen(Ein.p.Kommission)<10) and
        (Ein.P.Kommission<>'') and (StrFind(Ein.P.Kommission,'/',0)<>0) then begin
// debug(Ein.p.kommission);
        vA # Str_Token(Ein.P.Kommission,'/',1);
        Ein.P.Kommissionnr  # Cnvia(vA);
        vA # Str_Token(Ein.P.Kommission,'/',2);
        Ein.P.Kommissionpos # Cnvia(vA);
        Erx # RecLink(401,501,18,_RecFirst);
        if (Erx<>_rOK) then RecBufClear(401);
        Ein.P.Kommissionnr  # Auf.P.Nummer;
        Ein.P.Kommissionpos # Auf.P.Position;
/*
        if (Auf.P.nummer<>0) then
          Ein.P.Kommission # CnvAI(Auf.P.Nummer, _FmtNumNoGroup) + '/' + CnvAI(Auf.P.Position, _FmtNumNoGroup)
        else
          Ein.P.Kommission # '';
*/
        Ein.P.KommiKunde    # Auf.P.Kundennr;
      end;

      Ein.P.RID             # GetNum('Ein.P.Innendurchm',Set.Stellen.Radien);
      Ein.P.RIDMax          # GetNum('Ein.P.InnendurchmMax',Set.Stellen.Radien);
      Ein.P.RAD             # GetNum('Ein.P.Außendurchm',Set.Stellen.Radien);
      Ein.P.RADMax          # GetNum('Ein.P.AußendurchmMax',Set.Stellen.Radien);

      "Ein.P.Stückzahl"     # GetInt('Ein.P.Stückzahl');
      //vI                    # GetInt('Ein.P.FM.EingangStk') + GetInt('Ein.P.FM.VSBStk');
      vI                    # GetInt('Ein.P.FM.VSBStk');

      Ein.P.Gewicht         # GetNum('Ein.P.Gewicht',Set.Stellen.Gewicht);
      //vN                    # GetNum('Ein.P.FM.Eingang',Set.Stellen.Gewicht) + GetNum('Ein.P.FM.VSB',Set.Stellen.Gewicht);
      vN                    # GetNum('Ein.P.FM.VSB',Set.Stellen.Gewicht);

      if (vI<>0) or (vN<>0.0) then
        Ein.P.Lieferartnr # cnvai("Ein.P.Stückzahl")+'Stk  '+ANum(Ein.P.Gewicht,0)+'kg';

      "Ein.P.Stückzahl"   # "Ein.P.Stückzahl" - vI;
      Ein.P.Gewicht       # Ein.P.Gewicht - vN;
      Ein.P.Menge.Wunsch  # Ein.P.Gewicht;

      Ein.P.Materialnr      # GetInt('Ein.P.Materialnr');

      Ein.P.MEH.Wunsch      # 'kg';
      Ein.P.PEH             # GetInt('Ein.P.Preiseinheit');
      Ein.P.MEH.Preis       # GetAlpha('Ein.P.Mengeneinheit');
      Ein.P.Grundpreis      # GetNum('Ein.P.Bestellpreis',2);
      Ein.P.AufpreisYN      # GetBool('Ein.P.Aufpreise?');
      Ein.P.Aufpreis        # GetNum('Ein.P.Aufpreis',2);
      Ein.P.Einzelpreis     # GetNum('Ein.P.Einzelpreis',2);
      Ein.P.Gesamtpreis     # GetNum('Ein.P.Gesamtpreis',2);
      Ein.P.Kalkuliert      # 0.0;
      Ein.P.Termin1W.Art    # GetAlpha('Ein.P.TerminArt');
      Ein.P.Termin1W.Zahl   # GetWord('Ein.P.TerminZahl');
      Ein.P.Termin1W.Jahr   # GetWord('Ein.P.TerminJahr');
      Ein.P.Termin1Wunsch   # GetDate('Ein.P.TerminDatum');
      Ein.P.Termin2W.Zahl   # 0;
      Ein.P.Termin2W.Jahr   # 0;
      Ein.P.Termin2Wunsch   # 0.0.0;
      Ein.P.TerminZ.Zahl    # 0;
      Ein.P.TerminZ.Jahr    # 0;
      Ein.P.TerminZusage    # 0.0.0;
      Ein.P.Bemerkung       # GetAlphaMAX('Ein.P.Positionstext',64);
      Ein.P.Erzeuger        # 0;
      Ein.P.Menge           # Ein.P.Gewicht;
      //Ein.P.MEH.Einsatz     # 'kg';
      Ein.P.Projektnummer   # 0;
      //Ein.P.Termin.Zusatz   # '';

      "Ein.P.Löschmarker"   # GetAlpha('Ein.P.Löschmarker');
      if ("Ein.P.Löschmarker"='') then begin
        "Ein.P.Lösch.Datum"  # 0.0.0;
        "Ein.P.Lösch.Zeit"   # 0:0;
        "Ein.P.Lösch.User"   # '';
        end
      else begin
        "Ein.P.Lösch.Datum"  # today;
        "Ein.P.Lösch.Zeit"   # now;
        "Ein.P.Lösch.User"   # gUsername;
      end;
      Ein.P.Aktionsmarker   # '';//GetAlpha('Ein.P.Aktionsmarker');
      Ein.P.Aktionsmarker # '';
      Ein.P.Wgr.Dateinr     # Wgr.Dateinummer;
      //Ein.P.Artikeltyp      # Art.Typ;
      Ein.P.Materialnr      # 0;
      //Ein.P.GesamtwertEKW1  # 0.0;
      Ein.P.FM.VSB          # 0.0;
      Ein.P.FM.VSB.Stk      # 0;
      Ein.P.FM.Eingang      # 0.0;
      Ein.P.FM.Eingang.Stk  # 0;
      Ein.P.FM.Ausfall      # 0.0;
      Ein.P.FM.Ausfall.Stk  # 0;
      Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
      Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
      if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
      if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;

      Ein.P.Anlage.Datum    # GetDate('Ein.P.Anlage.Datum');
      Ein.P.Anlage.Zeit     # GetTime('Ein.P.Anlage.Zeit');
      Ein.P.Anlage.User     # GetAlpha('Ein.P.Anlage.User');


      // Verpackung...
      Ein.P.AbbindungL    # GetWord('Ein.P.V.AbbindungL');
      Ein.P.AbbindungQ    # GetWord('Ein.P.V.AbbindungQ');
      Ein.P.StehendYN     # GetBool('Ein.P.V.Stehend?');
      Ein.P.LiegendYN     # GetBool('Ein.P.V.Liegend?');
      Ein.P.Zwischenlage  # GetAlpha('Ein.P.V.Zwischenholz');
      if (Ein.P.Zwischenlage='') and (GetBool('Ein.P.V.Zwischen?')) then
        Ein.P.Zwischenlage # 'JA';
      Ein.P.kgmmVon       # GetNum('Ein.P.V.RGvon',0);
      Ein.P.kgmmBis       # GetNum('Ein.P.V.RGbis',0);
      Ein.P.RingkgBis     # GetNum('Ein.P.V.RGmax',0);
      Ein.P.VEkgmax       # GetNum('Ein.P.V.VEmax',0);
      "Ein.P.StückProVE"    # GetInt('Ein.P.V.StückVE');
      Ein.P.Nettoabzug    # GetNum('Ein.P.V.Nettoabzug',0);
      Ein.P.VpgText1      # GetAlphaMAX('Ein.P.V.Text1',64);
      Ein.P.VpgText2      # GetAlphaMAX('Ein.P.V.Text2',64);
      Ein.P.VpgText3      # GetAlphaMAX('Ein.P.V.Text3',64);
      Ein.P.VpgText4      # GetAlphaMAX('Ein.P.V.Bemerkung1',64);
      Ein.P.VpgText5      # GetAlphaMAX('Ein.P.V.Bemerkung2',64);
      Ein.P.RingkgVon     # GetNum('Ein.P.V.RGmin',0);
      //GetAlpha('Ein.P.V.Art');
      //GetAlpha('Ein.P.V.Schlüsselz');
      //GetWord('Ein.P.V.Verwiegung');


      // Position anlegen...
      Erx # Ein_Data:PosInsert(0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;

      // Text kopieren...
      Erx # RecLink(2502,2501,2,_RecFirst);   // Text holen
      if (Erx<=_rLocked) then begin
        vI # GetWord('Ein.T.Texttyp');
        vJ # GetInt('Ein.T.TextNummer');
        if (vI=502) then begin
          //'it.402.x.001'
          GetText('~it.502.'+cnvai(Ein.P.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.001',
                  '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+
                      CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3));
          end
        else if (vI=830) then begin
          //'it.830.x.000'
          GetText('~it.830.'+cnvai(vJ,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',
                  '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+
                      CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3));
          end
        else if (vI=250) then begin
          //'it.250.ARTID.000'
          GetText('~it.250.'+cnvai(vJ,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',
                  '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+
                      CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3));
        end;
      end;


      Erx # RecLink(2501,2500,1,_recNext);
    END;    // Positionen



    vI # 0;
    // Aufpreise loopen...
    Erx # RecLink(2503,2500,3,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      vI # vI + 1;
      RecbufClear(503);
      Ein.Z.Nummer            # GetInt('Ein.Z.Nummer');
      Ein.Z.Position          # GetWord('Ein.Z.Position');
      Ein.Z.lfdNr             # vI;
      "Ein.Z.Schlüssel"       # GetAlpha('Ein.Z.Schlüssel');
      Ein.Z.Menge             # GetNum('Ein.Z.Menge',Set.Stellen.Menge);
      Ein.Z.MEH               # GetAlpha('Ein.Z.Mengeneinheit');
      Ein.Z.PEH               # GetInt('Ein.Z.Preiseinheit');
      Ein.Z.MengenbezugYN     # Getbool('Ein.Z.Mengenaufpreis');
      Ein.Z.RabattierbarYN    # GetBool('Ein.Z.Rabattierfähig');
      Ein.Z.NeuberechnenYN    # GetBool('Ein.Z.Neuberechnung');
      Ein.Z.Preis             # GetNum('Ein.Z.Aufpreis',2);
      Ein.Z.Bezeichnung       # GetAlpha('Ein.Z.Bezeichnung');
      if (StrCut("Ein.Z.Schlüssel",1,1)>='0') and
        (StrCut("Ein.Z.Schlüssel",1,1)<='9') then
        "Ein.Z.Schlüssel" # '#0'+"Ein.Z.Schlüssel";

      // Aufpreis anlegen...
      Erx # RekInsert(503,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;

      Erx # RecLink(2503,2500,3,_recNext);
    END;  // Aufpreise


    Erx # RecRead(2500,1,_recNext);
  END;    // Köpfe


  TRANSOFF;

  DBADisconnect(2)



  // Texte reparieren...
  vTxtHdl # TextOpen(23);
  vNewTxtHdl # TextOpen(23);

  Erx # RecRead(500,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(501,500,9,_recFirst);     // Positionen loopen
    WHILE (Erx<=_rLocked) do begin
      // überhaupt ein $$ suchen...
      // ja -> $$+(D) suchen...
      TextClear(vTxtHdl);
      TextClear(vNewTxtHdl);
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TextRead(vTxtHdl,vName,0);
      Erx # TextSearch(vTxtHdl,1,1,0,'$$')
      if (Erx > 0) then begin
        Erx # TextSearch(vTxtHdl,1,1,0,'$$'+Ein.Sprache);
        if (Erx<=0) then begin
          Ein.Sprache # 'D';
          Erx # TextSearch(vTxtHdl,1,1,0,'$$'+Ein.Sprache);
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

      Erx # RecLink(501,500,9,_recNext);
    END;

    Erx # RecRead(500,1,_recNext);
  END;

  TextClose(vNewTxtHdl);
  TextClose(vTxtHdl);



  Msg(99,'Alle Bestellungen wurden importiert!',0,0,0);
end;


//========================================================================