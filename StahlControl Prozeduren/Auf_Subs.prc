@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_Subs
//                  OHNE E_R_G
//  Info
//
//
//  09.02.2009  AI  Erstellung der Prozedur
//  25.02.2010  AI  Lieferscheine können Reservierte Mengen vorschlagen
//  08.03.2010  ST  Auswahl für Auftragskopie aus Ablage hinzugefügt und Auswahl
//                  parameterisiert
//  30.04.2010  AI  Auftrags kopieren nimmt keine Abrufsnummern mit
//  17.05.2010  AI  Ang2Auf setzt Protokolldaten neu
//  20.01.2011  AI  Ang2Auf rechnet Aufpreise neu
//  09.02.2012  AI  NEU:BAG2Auf
//  31.05.2012  AI  alle Change... hier her verschoben
//  15.11.2012  AI  Neu: "DruckFM"
//  06.03.2013  ST  "DruckBelangensbest" zugefügt (Prj. 1443/12)
//  11.06.2013  AI  "AusChangeArtikel" löscht Auftragspos, ändert und entlöscht wieder
//  29.08.2013  AH  Neu: "ChangeKundenArtNr"
//  11.11.2013  AH  "ChangeKundenArtNr" kann auf freien Text
//  23.01.2014  ST  Ang2Auftrag: Attachments werdenmitkopiert und AUftrag bekommt Akt.Eintrag. Projekt 1488/22
//  12.02.2014  ST  Artikelnummer auch "einfügbar" gemacht Prj. 1304/237
//  14.04.2014  TM  Erweiterung "AucChangeKundennr
//  29.01.2015  AH  "Ang2Auf" verlinkt Anhänge
//  10.02.2015  AH  "BAG2Auf" erkennt VorlageBAG
//  21.03.2016  AH  "CopyBestellungAuswahl"
//  11.08.2016  ST  "Ang2Auf" Reservierungen werden nur auf nicht gelöschte Material verschoben
//  09.09.2016  AH  Wandlung von mehrzeiligen Arikel-Angebotn verbuchte nur 1. Position
//  13.09.2016  AH  "AusChangeArtikel" ändeert auch die Vorkalkulation
//  17.08.2017  AH  Neu: AFX "Auf.Druck.AB"
//  26.01.2018  AH  AnalyseErweitert
//  21.03.2018  AH  CopyBAGanAuf
//  07.01.2019  ST  Neu: AFX "Auf.Druck.FM"
//  26.02.2019  AH  "DruckFM" bucht bei Anzeige eines alten Dokumentes aus der Ablage nicht
//  16.04.2019  AH  "ZuFahrauftrag" fragt ab, ob alles VSB-Material vorbelegt werden soll
//  22.05.2019  AH  "changeArtikel" übernimmt ggf. auch Artikeltext
//  12.11.2019  AH  "Ang2Auf" leert Gültigkeitszeitraum und kann verschiedene Aufträge
//  10.08.2021  ST  Neu: AFX "Auf.Bag2Auf.CreateBag.Post"
//  14.01.2022  MR  Bugfix Änderung Angebot anch Auftrag aktualisiert Feld nicht (2346/4)
//  27.01.2022  AH  ERX
//  2023-08-22  AH  Artikeltausch nimmt WGR mit
//
//  Subprozeduren
//    SUB CopyBestellung()
//    SUB CopyAuftragAuswahl(opt aTyp : alpha) : logic;
//    SUB ausAuftragAuswahlBestand();
//    SUB ausAuftragAuswahlAblage();
//    SUB CopyAuftrag(aAufNummer : int; aAufPosition : int) : logic;
//    SUB CopyBestellungAuswahl(opt aTyp : alpha) : logic;
//    SUB ausBestellungAuswahlBestand()
//    SUB ausBestellungAuswahlAblage()
//
//    SUB Lieferschein(aMitEKVSB : logic; aZielDati : int; opt aSilent : logic);
//    SUB DruckFM() : logic;
//    SUB DruckAB() : logic;
//    SUB DruckGelangensbest() : logic;
//    SUB BAG2Auf() : logic;
//    SUB ChangeKundennr();
//    SUB ChangeKundenArtnr();
//    SUB ChangeRechnungsempf();
//    SUB ChangeArtikel();
//    SUB AusChangeArtikel()
//    SUB AusChangeKundennummer()
//    SUB AusChangeKundenMatArtNr()
//    SUB AusChangeRechnungsempf()
//    SUB AusChangeRechnungsanschr()
//    SUB ZuFahrauftrag() : logic
//    SUB _ZuFahrauftrag_EinzelAufP_Delegat() : int
//    SUB CopyBAGanAuf(var aBAG : int; aVorlage : int; aAufNr : int; aAufPos : int;) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_Rights

global Auftragsauswahl begin
  gAuf.Nummer : int;
  gAuf.Position : int;
end;

declare _ZuFahrauftrag_EinzelAufP_Delegat() : int
declare CopyAuftrag(aAufNummer : int; aAufPosition : int) : logic;


//========================================================================
//  CopyBestellung
//
//========================================================================
sub CopyBestellung(
  opt aEin  : int;
  opt aPos  : int) : logic;
local begin
  Erx     : int;
  vDatei1 : int;
  vDatei2 : int;
  vA,vB   : alpha;
  vEin    : int;
  vPos    : int;
  vPos2   : int;
  vOff    : int;
  vName   : alpha;
  vName2  : alpha;
  vAblage : logic;
end;
begin

  // Ankerfunktion?
  if (RunAFX('Auf.CopyBestellung','')<>0) then RETURN (AfxRes=_rOK);

  if (aEin=0) or (aPos=0) then begin
    if (Dlg_Standard:Standard(Translate('Bestellung'),var vA)=false) then RETURN false;
    if (StrFind(vA,'/',0)=0) then begin
      vEin  # Cnvia(vA);
      vPos # 0;
    end
    else begin
      vB    # Str_Token(vA,'/',1);
      vEin  # Cnvia(vB);
      vB    # Str_Token(vA,'/',2);
      vPos  # Cnvia(vB);
    end;
  end
  else begin
    vEin  # aEin;
    vPos  # aPos;
  end;

  // nächste temp. Position bestimmen...
  Erx # RecLink(401,400,9,_RecLast);
  if (Erx>_rLocked) then vPos2 # 0
  else vPos2 # Auf.P.Position;
  vOff # vPos2;


  Ein.Nummer # vEin;
  Erx # RecRead(500,1,0);     // Auftrag holen
  if (Erx<=_rLocked) then begin
    vAblage # false;
    vDatei1 # 500;
    vDatei2 # 501;
  end
  else begin
    "Ein~Nummer" # vEin;
    Erx # RecRead(510,1,0);   // ~Auftrag holen
    if (Erx>_rLocked) then begin
      RETURN false;
    end;
    RecBufCopy(510,500);
    vAblage # true;
    vDatei1 # 510;
    vDatei2 # 511;
  end;


  Erx # RecLink(vDatei2, vDatei1 ,9,_RecFirst);   // Bestellpositionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (vAblage) then RecBufCopy(511,501);

    // gezielt nur EINE Position?
    if (vPos<>0) and (Ein.P.Position<>vPos) then begin
      Erx # RecLink(vDatei2, vDatei1 ,9,_RecNext);
      CYCLE;
    end;

    vPos2 # vPos2 + 1;

    // neu nummerieren...
    RecBufClear(401);
    Auf.P.Nummer      # Auf.Nummer;
    Auf.P.Position    # vPos2;
    Auf.P.Kundennr    # Auf.Kundennr;
    Auf.P.KundenSW    # Auf.KundenStichwort;

    // Daten übernehmen...............
    "Auf.P.Güte"        # "Ein.P.Güte";
    "Auf.P.Gütenstufe"  # "Ein.P.Gütenstufe";
    Auf.P.AusfOben      # Ein.P.AusfOben;
    Auf.P.AusfUnten     # Ein.P.AusfUnten;
    // bisherige Ausführung löschen
    WHILE (RecLink(402,401,11,_recFirst)<=_rLocked) do begin
      Erx # RekDelete(402,0,'MAN');
      if (Erx<>_rOK) then BREAK;
    END;
    // Ausführung kopieren
    Erx # RecLink(502,501,12,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.AF.Nummer       # Auf.P.Nummer;
      Auf.AF.Position     # Auf.P.Position;
      Auf.AF.Seite        # Ein.AF.Seite;
      Auf.AF.lfdNr        # Ein.AF.lfdNr;
      Auf.AF.ObfNr        # Ein.AF.ObfNr;
      Auf.AF.Bezeichnung  # Ein.AF.Bezeichnung;
      Auf.AF.Zusatz       # Ein.AF.Zusatz;
      Auf.AF.Bemerkung    # Ein.AF.Bemerkung;
      "Auf.AF.Kürzel"     # "Ein.AF.Kürzel";
      Erx # RekInsert(402,_recunlock,'AUTO')
      if (erx<>_rOK) then BREAK;
      Erx # RecLink(502,501,12,_recNext);
    END;

    Auf.P.Erzeuger      # Ein.P.Erzeuger;
    Auf.P.Zeugnisart    # Ein.P.Zeugnisart;
    Auf.P.Intrastatnr   # Ein.P.Intrastatnr;
    Auf.P.Dicke         # Ein.P.Dicke;
    Auf.P.DickenTol     # Ein.P.DickenTol;
    Auf.P.Breite        # Ein.P.Breite;
    Auf.P.BreitenTol    # Ein.P.BreitenTol;
    "Auf.P.LängenTol"   # "Ein.P.LängenTol";
    "Auf.P.Länge"       # "Ein.P.Länge";
    Auf.P.RID           # Ein.P.RID;
    Auf.P.RIDmax        # Ein.P.RIDmax;
    Auf.P.RAD           # Ein.P.RAD;
    AUf.P.RADmax        # Ein.P.RADmax;

    "Auf.P.Stückzahl"   # "Ein.P.Stückzahl";
    Auf.P.Gewicht       # Ein.P.Gewicht;
    Auf.P.Menge.Wunsch  # Ein.P.Menge.Wunsch;
    Auf.P.MEH.Wunsch    # Ein.P.MEH.Wunsch;

    Auf.P.Auftragsart   # Ein.P.Auftragsart;
    Auf.P.Warengruppe   # Ein.P.Warengruppe;
    Auf.P.Wgr.Dateinr   # Ein.P.Wgr.Dateinr;
    Auf.P.ArtikelID     # Ein.P.ArtikelID;
    Auf.P.Artikelnr     # Ein.P.Artikelnr;
    Auf.P.ArtikelSW     # Ein.P.ArtikelSW;
    Auf.P.Sachnummer    # Ein.P.Sachnummer;
    Auf.P.Katalognr     # Ein.P.Katalognr;
    Auf.P.Strukturnr    # Ein.P.Strukturnr;
    Auf.P.TextNr1       # Ein.P.TextNr1;
    if (Auf.P.TextNr1=500) then Auf.P.TextNr1 # 400;
    if (Auf.P.TextNr1=501) then Auf.P.TextNr1 # 401;
    Auf.P.TextNr2       # Ein.P.TextNr2;
    if (Auf.P.TextNr1=400) then Auf.P.TextNr2 # Auf.P.TextNr2 + vOff;
    Auf.P.Termin1W.Art  # Ein.P.Termin1W.Art;
    Auf.P.Termin1W.Zahl # Ein.P.Termin1W.Zahl;
    Auf.P.Termin1W.Jahr # Ein.P.Termin1W.Jahr;
    Auf.P.Termin1Wunsch # Ein.P.Termin1Wunsch;
    Auf.P.Termin2W.Zahl # Ein.P.Termin2W.Zahl;
    Auf.P.Termin2W.Jahr # Ein.P.Termin2W.Jahr;
    Auf.P.Termin2Wunsch # Ein.P.Termin2Wunsch;
    Auf.P.Bemerkung     # Ein.P.Bemerkung;
    Auf.P.MEH.Preis     # Ein.P.MEH.Preis;
    Auf.P.PEH           # Ein.P.PEH;
    Auf.P.Menge         # Ein.P.Menge;
    Auf.P.MEH.Einsatz   # Ein.P.MEH;
    Auf.P.Projektnummer # Ein.P.Projektnummer;
    Auf.P.AbmessString  # Ein.P.AbmessString;
    //Auf.P.Kostenstelle  # Ein.P.Kostenstelle;


    SbrCopy(501,3,401,3); // Analysen kopieren
    SbrCopy(501,4,401,4); // Verpackung kopieren

    Auf_Data:SumEKGesamtPreis();

    Lib_MoreBufs:RecInit(501, y, y);

    // ANLEGEN:
    Erx # Auf_Data:PosInsert(0,'AUTO');
    if (erx<>_rOk) then begin
      RETURN false;
    end;
    if (Lib_MoreBufs:SaveAll(401)<>_rOK) then begin
      RETURN false;
    end;


    // Text kopieren?
    if (Auf.P.TextNr1=401) then begin
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      vName2 # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TxtCopy(vName,vName2,0);
    end;


    Erx # RecLink(vDatei2, vDatei1 ,9,_RecNext);
  END;

  $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:Refreshmode();

  RETURN true;
end;


//========================================================================
//  CopyAuftragAuswahl
//
//========================================================================
sub CopyAuftragAuswahl(opt aTyp : alpha) : logic;
local begin
  vHdl    : int;
  vFilter : int;
  vA      : alpha;
  vNumNeu : int;
  vQ      : alpha;
  tErx    : int;
end
begin

  // Auftragspositionsauswahl aus Auftragsbestand?
  if (aTyp = '') or (aTyp='BESTAND') then begin
    RecBufClear(401);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':ausAuftragAuswahlBestand');
    Lib_GuiCom:RunChildWindow(gMDI);
  end
  else

  // Auftragspositionsauswahl aus Auftragsablage?
  if (aTyp='ABLAGE') then begin

      RecBufclear(411);
      RecLink(411,100,71,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Auf.P.Ablage',here+':ausAuftragAuswahlAblage',n,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      // Selektion aufbauen...
      vQ # '';
      // hier ggf. spezielle Aufträge selektieren
      Lib_Sel:QInt( var vQ, 'Auf~P.Kundennr', '=', Auf.Kundennr );

      vHdl # SelCreate(411, gKey);
      tErx # vHdl->SelDefQuery('', vQ);
      if (tErx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
  end;


end;


//========================================================================
//  ausAuftragAuswahlBestand
//
//========================================================================
sub ausAuftragAuswahlBestand()
begin

  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;

    // Kopierfunktion mit Auftragsnummer aufrufen
    CopyAuftrag(Auf.P.Nummer,Auf.P.Position);
  end;

end;


//========================================================================
//  ausAuftragAuswahlAblage
//
//========================================================================
sub ausAuftragAuswahlAblage()
begin
  if (gSelected<>0) then begin
    RecRead(411,0,_RecId,gSelected);
    gSelected # 0;

    // Kopierfunktion mit Auftragsnummer aufrufen
    CopyAuftrag("Auf~P.Nummer","Auf~P.Position");
  end;

end;


//========================================================================
//  CopyAuftrag
//
//========================================================================
sub CopyAuftrag(aAufNummer : int; aAufPosition : int) : logic;
local begin
  Erx     : int;
  vDatei1 : int;
  vDatei2 : int;
  vA,vB   : alpha;
  vAuf    : int;
  vPos    : int;
  vPos2   : int;
  vOff    : int;
  vName   : alpha;
  vName2  : alpha;
  vAblage : logic;
  vBuf400 : int;
  vBuf401 : int;
  vBuf402 : int;
  vBuf403 : int;
  vBuf405 : int;
  vTxt    : handle;
end;
begin

//debug(Aint(aAufNummer) + aINt(aAufPosition));

  // Auftragspositionsauswahl per Eingabe über Auftragsnummer + Pos
  if (aAufNummer = 0) then begin
    if (Dlg_Standard:Standard(Translate('Auftrag'),var vA)=false) then RETURN false;
    if (StrFind(vA,'/',0)=0) then begin
      vAuf  # Cnvia(vA);
      vPos # 0;
    end
    else begin
      vB    # Str_Token(vA,'/',1);
      vAuf  # Cnvia(vB);
      vB    # Str_Token(vA,'/',2);
      vPos  # Cnvia(vB);
    end
  end
  else begin
    // Übernahme der Argumente
    vAuf # aAufNummer;
    vPos # aAufPosition;
  end;


  // nächste temp. Position bestimmen...
  Erx # RecLink(401,400,9,_RecLast);
  if (Erx>_rLocked) then vPos2 # 0
  else vPos2 # Auf.P.Position;
  vOff # vPos2;


  vBuf400 # RekSave(400);

  Auf.Nummer # vAuf;
  Erx # RecRead(400,1,0);     // Auftrag holen
  if (Erx<=_rLocked) then begin
    vAblage # false;
    vDatei1 # 400;
    vDatei2 # 401;
  end
  else begin
    "Auf~Nummer" # vAuf;
    Erx # RecRead(410,1,0);   // ~Auftrag holen
    if (Erx>_rLocked) then begin
      RekRestore(vBuf400);
      RETURN false;
    end;
    RecBufCopy(410,400);
    vAblage # true;
    vDatei1 # 410;
    vDatei2 # 411;
  end;


  Erx # RecLink(vDatei2,vDatei1,9,_RecFirst)  // Auftragspositionen loopen
  WHILE (Erx<=_rLocked) do begin

    if (vAblage) then RecBufCopy(411,401);

    // gezielt nur EINE Position?
    if (vPos<>0) and (Auf.P.Position<>vPos) then begin
      Erx # RecLink(vDatei2,vDatei1,9,_RecNext);
      CYCLE;
    end;
    vBuf401 # RekSave(401);

    vPos2 # vPos2 + 1;

    Lib_MoreBufs:RecInit(401, y, y);


    // 21.03.2018 AH:
    if (vBuf400->Auf.VorgangsTyp=c_Auf) then begin
      Erx # RekLink(835,401,5,_RecFirst);     // Auftragsart holen
      if (Erx<=_rLocked) and (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then begin
        FOR Erx # RecLink(404,401,12,_RecFirst)  // Aktionen loopen
        LOOP Erx # RecLink(404,401,12,_RecNext)
        WHILE (Erx <= _rLocked) DO BEGIN
          if (Auf.A.Aktionstyp = c_Akt_BA) then begin
            if (Msg(401030,'',_WinIcoQuestion, _WinDialogYesNo,1)=_winidyes) then
              Lib_RmtData:UserWrite('400|'+aint(vPos2), cnvai(Auf.A.Aktionsnr, _FmtNumNoGroup|_FmtNumleadzero,0,10)+'/'+cnvai(Auf.A.Aktionspos, _FmtNumNoGroup|_FmtNumleadzero,0,3));
            BREAK;
          end;
        END;
      end;
    end;

    // neu nummerieren...
    Auf.P.Nummer          # vBuf400->Auf.Nummer;
    Auf.P.Position        # vPos2;
    Auf.P.Kundennr        # vBuf400->Auf.Kundennr;
    Auf.P.KundenSW        # vBuf400->Auf.KundenStichwort;
    Auf.P.Best.Nummer     # vBuf400->Auf.Best.Nummer;
    Auf.P.Prd.Reserv      # 0.0;
    Auf.P.Prd.Reserv.Gew  # 0.0;
    Auf.P.Prd.Reserv.Stk  # 0;
    Auf.P.Prd.Plan        # 0.0;
    Auf.P.Prd.Plan.Gew    # 0.0;
    Auf.P.Prd.Plan.Stk    # 0;
    Auf.P.Prd.VSB         # 0.0;
    Auf.P.Prd.VSB.Gew     # 0.0;
    Auf.P.Prd.VSB.Stk     # 0;
    Auf.P.Prd.VSAuf       # 0.0;
    Auf.P.Prd.VSAuf.Gew   # 0.0;
    Auf.P.Prd.VSAuf.Stk   # 0;
    Auf.P.Prd.LFS         # 0.0;
    Auf.P.Prd.LFS.Gew     # 0.0;
    Auf.P.Prd.LFS.Stk     # 0;
    Auf.P.Prd.Rech        # 0.0;
    Auf.P.Prd.Rech.Gew    # 0.0;
    Auf.P.Prd.Rech.Stk    # 0;
    Auf.P.Prd.zuBere      # 0.0;
    Auf.P.Prd.zuBere.Stk  # 0;
    Auf.P.Prd.zuBere.Gew  # 0.0;
    Auf.P.GPL.Plan        # 0.0;
    Auf.P.GPL.Plan.Gew    # 0.0;
    Auf.P.GPL.Plan.Stk    # 0;
    Auf.P.Materialnr      # 0;
    "Auf.P.Löschmarker"   # '';
    Auf.P.Aktionsmarker   # '';
    "Auf.P.Lösch.Datum"   # 0.0.0;
    "Auf.P.Lösch.Zeit"    # 0:0;
    "Auf.P.Lösch.User"    # '';
    // 30.04.2010 AI: keine Abrufnummern übernehmen
    Auf.P.AbrufAufNr      # 0;
    Auf.P.AbrufAufPos     # 0;
    Auf.P.Flags           # ''; // 06.03.2019 AH

    // Ausführung kopieren
    Erx # RecLink(402, vBuf401,11,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf402 # RekSave(402);
      Auf.AF.Nummer       # Auf.P.Nummer;
      Auf.AF.Position     # Auf.P.Position;
      RekInsert(402,_recunlock,'AUTO')
      RekRestore(vBuf402);
      Erx # RecLink(402, vBuf401,11,_recNext);
    END;

    // Aufpreise kopieren
    Erx # RecLink(403, vBuf401,6,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf403 # RekSave(403);
      Auf.Z.Nummer       # Auf.P.Nummer;
      Auf.Z.Position     # Auf.P.Position;
      Auf.Z.Rechnungsnr  # 0;
      RekInsert(403,_recunlock,'AUTO')

      // Aufpreise refreshen  02.10.2019
      ApL_Data:Neuberechnen(401, today);

      RekRestore(vBuf403);
      Erx # RecLink(403, vBuf401,6,_recNext);
    END;

    // Kalkulation kopieren
    Erx # RecLink(405, vBuf401,7,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf405 # RekSave(405);
      Auf.K.Nummer       # Auf.P.Nummer;
      Auf.K.Position     # Auf.P.Position;
      RekInsert(405,_recunlock,'AUTO')
      RekRestore(vBuf405);
      Erx # RecLink(405, vBuf401,7,_recNext);
    END;

    Auf_Data:SumEKGesamtPreis();

    // ANLEGEN:
    Erx # Auf_Data:PosInsert(0,'AUTO');
    if (Erx<>_rOk) then begin
      RekRestore(vBuf401);
      RekRestore(vBuf400);
      RETURN false;
    end;

    if (Lib_MoreBufs:SaveAll(401)<>_rOK) then begin
      RekRestore(vBuf401);
      RekRestore(vBuf400);
      RETURN false;
    end;

    // Text kopieren?
/***
    if (Auf.P.TextNr1=401) then begin
      vName # '~401.'+CnvAI(vBuf401->Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vBuf401->Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      vName2 # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TxtCopy(vName,vName2,0);
    end;

    // Internen Text umkopieren
    vName   # '~401.'+CnvAI(vBuf401->Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vBuf401->Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
    vName2  # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
    TxtCopy(vName,vName2,0);
***/
    vName   # '~401.'+CnvAI(vBuf401->Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vBuf401->Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    vName2  # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    Lib_Texte:CopyAllAehnlich(vName, 18, vName2);   // 2022-06-27 AH besser so

    RekRestore(vBuf401);

    Erx # RecLink(vDatei2,vDatei1,9,_RecNext);
  END;

  RekRestore(vBuf400);

  // 2022-12-01 AH  Fix gegen Versprung:
  Auf.P.Nummer   # Auf.Nummer;
  Auf.P.Position # vPos2;

  $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:Refreshmode();

  RETURN true;
end;


//========================================================================
//  CopyBestellungAuswahl
//
//========================================================================
SUB CopyBestellungAuswahl(opt aTyp : alpha) : logic;
local begin
  vHdl    : int;
  vA      : alpha;
  vQ      : alpha;
  tErx    : int;
end;
begin
 // Auftragspositionsauswahl aus Auftragsbestand?
  if (aTyp = '') or (aTyp='BESTAND') then begin
    RecBufClear(501);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':ausBestellungAuswahlBestand');
    Lib_GuiCom:RunChildWindow(gMDI);
  end
  // Auftragspositionsauswahl aus Auftragsablage?
  else if (aTyp='ABLAGE') then begin
    RecBufclear(511);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ein.P.Ablage',here+':ausBestellungAuswahlAblage',n,n,'-INFO');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    Lib_GuiCom:RunChildWindow(gMDI);
  end;
end;


//========================================================================
//  ausBestellungAuswahlBestand
//
//========================================================================
sub ausBestellungAuswahlBestand()
begin
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    gSelected # 0;

    // Kopierfunktion mit Auftragsnummer aufrufen
    CopyBestellung(Ein.P.Nummer ,Ein.P.Position);
  end;
end;


//========================================================================
//  ausBestellungAuswahlAblage
//
//========================================================================
sub ausBestellungAuswahlAblage()
begin
  if (gSelected<>0) then begin
    RecRead(511,0,_RecId,gSelected);
    gSelected # 0;
    // Kopierfunktion mit Auftragsnummer aufrufen
    CopyBestellung("Ein~P.Nummer","Ein~P.Position");
  end;

end;


//========================================================================
// Lieferschein
//
//========================================================================
sub Lieferschein(
  aMitEKVSB   : logic;
  aZielDatei  : int;    // 440 oder 700
  opt aSilent : logic);
local begin
  Erx   : int;
  vPos  : int;
  vKomm : logic;
  vSel  : int;
  vSelN : alpha;
  vQ    : alpha(250);
  vA    : alpha;
  v401  : int;
end;
begin

  v401 # RekSave(401);

  // Ankerfunktion:
  if (aMitEKVSB) then vA # 'Y|'
  else vA # 'N|';
  vA # vA + aInt(aZieldatei);
  if (aSilent) then vA # vA + '|Y'
  else vA # vA + '|N';
  if (RunAFX('Auf.LFS.Vorbelegen',vA)<>0) then begin
    RekRestore(v401);
    RETURN;
  end;


  vPos # 1;

  // Abfragen
  vKomm # true;
  if ( !aSilent ) then begin
    if ( Msg( 440004, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdNo ) then
      vKomm # false;

    /* reserviertes Material übernehmen [04.02.2010/PW] */
    if ( !vKomm ) then begin
      Lib_Sel:QInt( var vQ, 'Mat.R.Auftragsnr', '=', Auf.P.Nummer );
      //Lib_Sel:QInt( var vQ, 'Mat.R.Auftragspos', '=', Auf.P.Position );
      vQ # vQ + ' AND LinkCount( Material ) > 0 ';

      vSel # SelCreate( 203, 1 );
      vSel->SelAddLink( '', 200, 203, 1, 'Material' );
      vSel->SelDefQuery( '', vQ );
      vSel->SelDefQuery( 'Material', '"Mat.Löschmarker" = ''''' );
      vSelN # Lib_Sel:SaveRun( var vSel, 0, aSilent );

      if (RecInfo( 203, _recCount, vSel) > 0 ) then begin
        if (Msg( 440005, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdYes ) then begin
          FOR  Erx # RecRead( 203, vSel, _recFirst );
          LOOP Erx # RecRead( 203, vSel, _recNext );
          WHILE ( Erx <= _rLocked ) DO BEGIN
            Erx # RecLink( 200, 203, 1, _recFirst );    // MAterial holne
            if (Erx>_rLockeD) then CYCLE;
            if (RecLinkInfo(203,200,13,_recCount)<>1) then CYCLE;

            if ( "Mat.R.Stückzahl" = 0 ) then begin
              Msg( 440006, AInt( Mat.R.ReservierungNr ), _winIcoWarning, _winDialogOK, 1 );
              CYCLE;
            end;

            Auf.P.Nummer   # Mat.R.AuftragsNr;
            Auf.P.Position # Mat.R.AuftragsPos;
            RecRead( 401, 1, 0 );
            if (Auf_Data:VLDAW_Pos_Einfuegen_Mat( myTmpNummer, var vPos, 0, true )=false) then begin
              ErrorOutput;
              CYCLE;
            end;
            ErrorOutput;

            // auf Res.Menge ändern
            RecRead( 441, 1, _recLock );
            "Lfs.P.Stück"         # "Mat.R.Stückzahl";
            Lfs.P.Gewicht.Brutto  # Mat.R.Gewicht;
            Lfs.P.Gewicht.Netto   # Mat.R.Gewicht;
            Lfs.P.Menge.Einsatz   # Mat.R.Gewicht;

            if (Mat.Bestand.Gew=Mat.R.Gewicht) then begin
              if (Mat.Gewicht.Netto<>Mat.Bestand.Gew) then begin
                Lfs.P.Gewicht.Netto   # Mat.Gewicht.Netto;
                Lfs.P.Menge.Einsatz   # Lfs.P.Gewicht.Brutto;
              end
              else begin
                Lfs.P.Gewicht.Brutto  # Mat.Gewicht.Brutto;
                Lfs.P.Menge.Einsatz   # Lfs.P.Gewicht.Netto;
              end;
            end;

            Lfs.P.Menge           # Lib_Einheiten:WandleMEH(404, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge.Einsatz, Lfs.P.MEH.Einsatz, Lfs.P.MEH);
            Rekreplace( 441, _recUnlock, 'AUTO' );
          END;
        end;
      end;

      vSel->SelClose();
      SelDelete( 203, vSelN );
    end;
  end;

  if ( !vKomm ) then begin
    RekRestore(v401);
    RETURN;
  end;

  /* kommissioniertes Material übernehmen */
  FOR  Erx # RecLink( 401, 400, "Set.Auf.Kopf<>PosRel", _recFirst );
  LOOP Erx # RecLink( 401, 400, "Set.Auf.Kopf<>PosRel", _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN // Positionen loopen
    if ("Auf.P.Löschmarker"='*') then
      CYCLE;
    RecLink( 819, 401, 1, 0 ); // Warengruppe holen

    // Material
    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
      FOR  Erx # RecLink( 200, 401, 17, _recFirst );
      LOOP Erx # RecLink( 200, 401, 17, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        if ( "Mat.Löschmarker" != '' ) then
          CYCLE;

        if ((Mat.Lageradresse <> Lfs.Zieladresse) or
           ((Mat.Lageradresse = Lfs.Zieladresse) and (Mat.Lageranschrift <> Lfs.Zielanschrift))) and
             ((Mat.Status <= c_Status_bisFrei) or
             ((Mat.Status = c_Status_EKVSB) and (aMitEKVSB)) or
             (Mat.Status = c_Status_VSB) or
             (Mat.Status = c_Status_VSBKonsi)) then begin
          // Position aufnehmen
          Auf_Data:VLDAW_Pos_Einfuegen_Mat(myTmpNummer, var vPos, Mat.Auftragspos2);
          ErrorOutput;
        end;
      END;
    end;

    // Artikel
    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      FOR  Erx # RecLink( 404, 401, 12, _recFirst );
      LOOP Erx # RecLink( 404, 401, 12, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN // Aktionen loopen
        if ( "Auf.A.Löschmarker" != '*' ) and ( Auf.A.Aktionstyp = c_Akt_VSB ) and ( Auf.A.Menge > 0.0 ) then begin
          // Position aufnehmen
          Auf_Data:VLDAW_Pos_Einfuegen_Art(myTmpNummer, var vPos, Auf.A.Aktionspos2);
        end;
      END;
    end;
  END;

  RekRestore(v401);
end;


//========================================================================
//  DruckFM
//
//========================================================================
sub DruckFM() : logic;
local begin
  Erx   : int;
  v401  : int;
  vNeu  : logic;
end;
begin
  if (RunAFX('Auf.Druck.FM','')<0) then
    RETURN (AfxRes=_rOK);
    
  RecLink(400,401,3,_RecFirst);  // Kopf holen
  v401 # RekSave(401);


  gFormParaHdl # CteOpen(_CteList);
  FOR Erx # RecLink(404, 400, 15, _recFirst); // Aktionen. loopen
  LOOP Erx # RecLink(404, 400, 15, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Auf.A.Aktionstyp<>c_AKt_VSB) then CYCLE;

    if (Auf.A.Materialnr<>0) then begin
      Erx # RekLink(200,404,6,_recFirst);   // Material holen
      if (Erx>_rLocked) then CYCLE;
      if (Mat.Datum.VSBMeldung<>0.0.0) then CYCLE;
    end;
    gFormParaHdl->CteInsertItem(aint(RecInfo(404,_recId)), RecInfo(404,_recID),'');

  END;

  // 26.02.2019 AH: wenn aus Ablage, dann NICHT verbuchen
  vNeu # Lib_Dokumente:Printform(400,'Fertigmeldung',true);

  RekRestore(v401);
  if (vNeu) then begin
    if (Msg(401021,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinidYes) then begin
      Auf_Data:SetVsbDatKommMat(gFormParaHdl); // VSB Datum setzen
    end;
  end;

  if (gFormParaHdl<>0) then
    Sort_KillList(gFormParaHdl);
  gFormParaHdl # 0;
  RETURN true;
end;


//========================================================================
// DruckAB
//
//========================================================================
sub DruckAB() : logic;
local begin
  vZList  : handle;
  vKLim   : float;
  vBuf401 : int;
end;
begin

  if (RunAFX('Auf.Druck.AB','')<0) then
    RETURN (AfxRes=_rOK);

  vZList # gZLList;
  // Kreditlimit prüfen...
  if (Auf.LiefervertragYN) then begin
    if ("Set.KLP.ABLV-Druck"<>'') then
      if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.ABLV-Druck",y, var vKLim, 0, Auf.P.Nummer)=false) then RETURN false;
  end
  else begin
    if ("Set.KLP.AB-Druck"<>'') then
      if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.AB-Druck",y, var vKLim, 0, Auf.P.Nummer)=false) then RETURN false;
  end;

  RecLink(400,401,3,_RecFirst);  // Kopf holen
  vBuf401 # RekSave(401);
  if (Lib_Dokumente:Printform(400,'Auftragsbest',true)) and
    (Set.Auf.DruckInAktYN) then begin
    RecLink(401,400,9,_RecFirst);  // 1.Position holen
    // Druck-Aktion anlegen
    RecBufClear(404);
    Auf.A.Aktionstyp    # c_Akt_Druck;
    Auf.A.Bemerkung     # c_AktBem_AB;
    Auf.A.Aktionsnr     # Auf.Nummer;
    Auf.A.Aktionspos    # 0;
    Auf.A.Aktionsdatum  # Today;
    Auf.A.TerminStart   # Today;
    Auf.A.TerminEnde    # Today;
    //RecLink(100,400,1,_RecFirst);  // Kunde holen
    //Aufx.A.Adressnummer  # Adr.Nummer;
    Auf_A_Data:NeuAmKopfAnlegen();
    Auf_Data:BerechneMarker();
  end;

  RekRestore(vBuf401);

  vZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  RETURN true;
end;



//========================================================================
// DruckGelangensbestätigung
//
//========================================================================
sub DruckGelangensbest() : logic;
local begin
  vZList  : handle;
  vKLim   : float;
//  vBuf401 : int;
end;
begin
//  vZList # gZLList;


  // Prüfen wieviele Lieferscheine hinterlegt sind

  // Keine Lieferung mit Rechnung-> keine Ausgabe

  // Nur einer-> Datum lesen

  // Verschiedene Daten, dann Lieferscheinnummer, oder Datum abfragen?
  // ggf. Lieferdatum vorgeben
  Dlg_Standard:Datum('ggf. Lieferdatum', var GV.Datum.01, today);


  Lib_Dokumente:Printform(400,'Gelangensbestätigung',true);

  //vZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  RETURN true;
end;



//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
 if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;

    Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
    if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then RETURN;

    // Feldübernahme
/*
    BAG.F.Kommission        # CnvAI(Auf.P.Nummer, _FmtNumNoGroup) + '/' + CnvAI(Auf.P.Position, _FmtNumNoGroup);
    BAG.F.Auftragsnummer    # Auf.P.Nummer;
    BAG.F.Auftragspos       # Auf.P.Position;
    "BAG.F.ReservFürKunde"  # Auf.P.Kundennr;
    BAG.F.ReservierenYN     # y;
*/
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
    "BAG.F.KostenträgerYN"  # y;
    BA1_F_Data:AusKommission(Auf.P.Nummer, Auf.P.Position,0);
    BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
    BA1_F_Data:ErrechnePlanmengen(y,y,y);
    gMDI->winUpdate(_WinUpdFld2Obj);
  end;

end;


//========================================================================
// Ang2Auf
//        kopiert markierte Angebotspositionen in einen neuen Auftrag
//
////[+] 14.01.2022 MR Bugfix Änderung Angebot anch Auftrag aktualisiert Feld nicht (2346/4)
//========================================================================
sub Ang2Auf();
local begin
  Erx         : int;
  vItem       : int;
  vAufNr      : int;
  vKdNr       : int;
  vAufMix     : logic;
  vPos        : int;
  vNummer     : Int;

  vMFile      : Int;
  vMID        : Int;
  vBuf400     : int;
  v401        : int;
  v401b       : int;
  vMatNr      : int;
  vOK         : logic;
  vKLim       : float;
  vA,vB       : alpha;
  vAttachKey  : alpha;
end
begin


  vPos # 0;
  FOR vItem # gMarkList->CteRead(_CteFirst)  // erste Element holen
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem) // nächstes Element
  WHILE (vItem > 0) do begin  // Elemente durchlaufen

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=401) then begin
      Erx # RecRead(401,0,_RecID, vMID);
      if (Erx=_rOK) and ("Auf.P.Löschmarker"='') then begin
        RecLink(400,401,3,_recFirsT);   // Kopf holen
        if (Auf.Vorgangstyp<>c_Ang) then begin
          Msg(400007,'',0,0,0);
          RETURN;
        end;
        
        vPos # vPos + 1;
        if (vAufNr=0) then
          vAufNr # Auf.Nummer;
        if (vAufNr<>Auf.Nummer) then vAufMix # true;
        if (vKdNr=0) then
          vKdNr # Auf.Kundennr
        else if (vKdNr<>Auf.Kundennr) then vKdNr # -1;
      end;
    end;
  END;

  // Nicht richtig markiert?
  if (vKdNr<=0) then begin
    Msg(400007,'',0,0,0);
    RETURN;
  end;
  
  if (vAufMix) then begin
    if (Msg(400043,aint(vAufNr),_WinIcoQuestion,_WinDialogYesNo,2)<>_winidyes) then RETURN;
  end;

  Auf.Nummer # vAufNr;  // Auftragskopf holen
  RecRead(400,1,0);
  Erx # RecLink(100,400,1,_RecFirst);     // Kunde holen
  if (Adr.SperrKundeYN) then begin
    Msg(100005,Adr.Stichwort,0,0,0);
    RETURN;
  end;
  Erx # RecLink(100,400,4,_recFirst);     // Rechnungsempfänger holen
  if (Adr.SperrKundeYN) then begin
    Msg(100005,Adr.Stichwort,0,0,0);
    RETURN;
  end;

  // Kreditlimit prüfen
  if ("Set.KLP.Auf-Anlage"<>'') and ("Set.KLP.Auf-Anlage"<>'A') then begin
    if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.Auf-anlage",y, var vKLim)=false) then RETURN;
  end;


  // Sicherheitsabfrage
  if (Msg(400008,AInt(vPos),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
    RETURN;
  end;

  // Wandeln...
  TRANSON;

  vPos # 1;
  vNummer # Lib_Nummern:ReadNummer('Auftrag');
  if (vNummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN;
  end;

  Auf.Nummer # vAufNr;  // Auftragskopf holen
  RecRead(400,1,0);
  vBuf400 # RekSave(400);

  // Kopfaufpreise kopieren
  Erx # RecLink(403,400,13,_RecFirst);
  WHILE (Erx=_rOK) do begin
    if (Auf.Z.Position<>0) then begin
      Erx # RecLink(403,400,13,_RecNext);
      CYCLE;
    end;

    Auf.Z.Nummer # vNummer;
    Erx # RekInsert(403,0,'AUTO');
    if (erx<>_rOk) then begin
      TRANSBRK;
      Msg(400009,'1304',0,0,0);
      RETURN;
    end;
    Auf.Z.Nummer # vAufNr;  // Restore
    RecRead(403,1,0);

    Erx # RecLink(403,400,13,_RecNext);
  END;

  // Kopf anlegen

  Auf.VorgangsTyp   # c_AUF;
  Auf.Datum         # today;
  Auf.Anlage.Datum  # today;
  Auf.Anlage.Zeit   # now;
  Auf.Anlage.User   # gUsername;
  "Auf.GültigkeitVom" # 0.0.0;
  "Auf.GültigkeitBis" # 0.0.0;
  Auf.Nummer # vNummer;
  Erx # RekInsert(400,0,'AUTO');
  if (erx<>_rOk) then begin
    TRANSBRK;
    Msg(400009,'1317',0,0,0);
    RETURN;
  end;

  vItem # gMarkList->CteRead(_CteFirst);       // erste Element holen
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>401) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem) // nächstes Element
      CYCLE;
    end;
    Erx # RecRead(401,0,_RecID, vMID);
    if (Erx<>_rOK) or ("Auf.P.Löschmarker"='*') then CYCLE;

    v401 # RekSave(401);

    // Texte ggf. umkopieren
/***
    if (Auf.P.TextNr1=401) then begin // Idividuell
      vA # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3);
      vB # '~401.'+CnvAI(vNummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero| _FmtNumNogroup,0,3);
      TxtCopy(vA,vB,0);
    end;

    // Internen Text umkopieren
    vA # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3)+'.01';
    vB # '~401.'+CnvAI(vNummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero| _FmtNumNogroup,0,3)+'.01';
    TxtCopy(vA,vB,0);
***/
    vA # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3);
    vB # '~401.'+CnvAI(vNummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero| _FmtNumNogroup,0,3);
    Lib_Texte:CopyAllAehnlich(vA, 18, vB);   // 2022-06-27 AH besser so

                              // Kalkulation kopieren
    Erx # RecLink(405,401,7,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.K.Nummer        # vNummer;
      Auf.K.Position      # vPos;
      Auf.K.Anlage.Datum  # today;
      Auf.K.Anlage.Zeit   # now;
      Auf.K.Anlage.User   # gUsername;
      RekDelete(405,0,'MAN');
      Erx # RekInsert(405,0,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(400009,'1342',0,0,0);
        RETURN;
      end;

      Auf.K.Nummer    # Auf.P.Nummer
      Auf.K.Position  # Auf.P.Position;
      RecRead(405,1,0);
      Erx # RecLink(405,401,7,_recNext);
    END;

                              // Aufpreise kopieren
    Erx # RecLink(403,401,6,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.Z.Nummer    # vNummer;
      Auf.Z.Position  # vPos;
      Auf.Z.Anlage.Datum  # today;
      Auf.Z.Anlage.Zeit   # now;
      Auf.Z.Anlage.User   # gUsername;
      RekDelete(403,0,'MAN');
      Erx # RekInsert(403,0,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(400009,'1358',0,0,0);
        RETURN;
      end;

      Auf.Z.Nummer    # Auf.P.Nummer
      Auf.Z.Position  # Auf.P.Position;
      RecRead(403,1,0);
      Erx # RecLink(403,401,6,_recNext);
    END;
                              // Ausführungen kopieren
    Erx # RecLink(402,401,11,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.AF.Nummer     # vNummer;
      Auf.AF.Position   # vPos;
      RekDelete(402,0,'MAN');
      Erx # RekInsert(402,0,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(400009,'1373',0,0,0);
        RETURN;
      end;

      Auf.AF.Nummer    # Auf.P.Nummer
      Auf.AF.Position  # Auf.P.Position;
      RecRead(402,1,0);
      Erx # RecLink(402,401,11,_recNext);
    END;
                              // Aktionen kopieren
    Erx # RecLink(404,401,12,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.A.Nummer    # vNummer;
      Auf.A.Position  # vPos;
      Auf.A.Anlage.Datum  # today;
      Auf.A.Anlage.Zeit   # now;
      Auf.A.Anlage.User   # gUsername;
      RekDelete(404,0,'MAN');
      Erx # RekInsert(404,0,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(400009,'1388',0,0,0);
        RETURN;
      end;

      Auf.A.Nummer    # Auf.P.Nummer
      Auf.A.Position  # Auf.P.Position;
      RecRead(404,1,0);
      Erx # RecLink(404,401,12,_recNext);
    END;
                              // Feinabrufe kopieren
    Erx # RecLink(408,401,13,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.FA.Nummer     # vNummer;
      Auf.FA.Position   # vPos;
      RekDelete(408,0,'MAN');
      Erx # RekInsert(408,0,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(400009,'1403',0,0,0);
        RETURN;
      end;

      Auf.FA.Nummer    # Auf.P.Nummer
      Auf.FA.Position  # Auf.P.Position;
      RecRead(408,1,0);
      Erx # RecLink(408,401,13,_recNext);
    END;

                              // Stückliste kopieren
    Erx # RecLink(409,401,15,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Auf.SL.Nummer   # vNummer;
      Auf.SL.Position # vPos;
      Auf.SL.Anlage.Datum  # today;
      Auf.SL.Anlage.Zeit   # now;
      Auf.SL.Anlage.User   # gUsername;
      RekDelete(409,0,'MAN');
      Erx # RekInsert(409,0,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(400009,'1418',0,0,0);
        RETURN;
      end;

      Auf.SL.Nummer    # Auf.P.Nummer
      Auf.SL.Position  # Auf.P.Position;
      RecRead(409,1,0);
      Erx # RecLink(409,401,15,_recNext);
    END;


    // Position anlegen
    Lib_MoreBufs:RecInit(401, y, y);
    Auf.P.Nummer        # vNummer;
    Auf.P.Position      # vPos;
    Auf.P.Anlage.Datum  # today;
    Auf.P.Anlage.Zeit   # now;
    Auf.P.Anlage.User   # gUsername;
    Erx # Auf_data:PosInsert(0,'AUTO');
    if (erx<>_rOk) then begin
      TRANSBRK;
      Msg(400009,'1000',0,0,0);
      RETURN;
    end;
    if (Lib_MoreBufs:SaveAll(401)<>_rOK) then begin
      TRANSBRK;
      Msg(400009,'1226',0,0,0);
      RETURN;
    end;

    // ST 2014-01-23 Projekt 1488/22: Externe Anhänge kopieren
    Anh_Data:Copyall(v401, 401, n, y);   // 29.01.2015 : "...,n,Y)"

    // nötige Verbuchungen im Artikel druchführen...
    RekLink(400,401,3,0);   // Kopf lesen
    Auf_data:VerbucheArt('',0.0,'*');


    // ST 2014-01-23 Projekt 1488/22: Urpsrungs Angebotnummer an Auftragaktion hinterlgen
    RecBufClear(404);
    Auf.A.Aktionstyp    # c_Akt_Angebot;
    Auf.A.Aktionsnr     # v401->Auf.P.Nummer;
    Auf.A.Aktionspos    # v401->Auf.P.Position;
    Auf.A.Aktionsdatum  # Today;
    Auf.A.TerminStart   # Today;
    Auf.A.TerminEnde    # Today;
    Auf.A.Bemerkung     # 'Angebot wurde Auftrag';
    vOK # (Auf_A_Data:NeuAnlegen()=_rOK);
    if (vOK=false) then begin
      TRANSBRK;
      Error(400009,'1000');
      ERROROUTPUT;
      RETURN;
    end;


    // Reservierungen verschieben bzw. Bestellen bei Fremdmaterial...
    v401b # RekSave(401);
    RecBufCopy(v401, 401);
    Erx # RecLink(203,401,18,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      Erx # RecLink(200,203,1,_recFirst);   // Material holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(203,401,18,_recNext);
        CYCLE;
      end;

      // 31.07.2017 AH: Fehler, wenn Karte schon gelöscht ist
      if ("Mat.Löschmarker" <> '') then begin
        RecBufDestroy(v401);
        RecBufDestroy(v401b);
        TRANSBRK;
        Msg(010002,aint(Mat.R.Reservierungnr)+'|'+aint(Mat.Nummer),0,0,0);
        RETURN;
      end;

      if (Mat_Rsv_Data:Entfernen()=false) then begin
        RecBufDestroy(v401);
        RecBufDestroy(v401b);
        TRANSBRK;
        Msg(400009,'1233',0,0,0);
        RETURN;
      end;

      RecBufCopy(v401b, 401);

      Mat.R.Materialnr      # Mat.Nummer;
      "Mat.R.Stückzahl"     # "Mat.Bestand.Stk";
      Mat.R.Gewicht         # Mat.Bestand.Gew;
      "Mat.R.Trägertyp"     # '';
      "Mat.R.TrägerNummer1" # 0;
      "Mat.R.TrägerNummer2" # 0;
      Mat.R.Kundennummer    # Auf.P.Kundennr;
      Mat.R.KundenSW        # Auf.P.KundenSW;
      Mat.R.Auftragsnr      # Auf.P.Nummer;
      Mat.R.AuftragsPos     # Auf.P.Position;
      if (Mat_Rsv_Data:Neuanlegen()=false) then begin
        RecBufDestroy(v401);
        RecBufDestroy(v401b);
        TRANSBRK;
        Msg(400009,'1258',0,0,0);
        RETURN;
      end;

      RecBufCopy(v401, 401);


      Erx # RecLink(203,401,18,_recFirst);
    END;
    RecBufDestroy(v401b);


    // Aktionen anlegen
    RekRestore(v401);
    RecRead(401,1,0);

    RecBufClear(404);
    Auf.A.Aktionstyp    # c_Akt_Ang2Auf;
    Auf.A.Aktionsnr     # vNummer;
    Auf.A.Aktionspos    # vPos;
    Auf.A.Aktionsdatum  # Today;
    Auf.A.TerminStart   # Today;
    Auf.A.TerminEnde    # Today;
    //RecLink(100,401,4,_RecFirst);     // Kunde holen
    //Aufx.A.Adressnummer  # Adr.Nummer;
    vOk # Auf_A_Data:NeuAnlegen()=_rOK;
    if (vOK=false) then begin
      TRANSBRK;
      Error(400009,'1000');
      ERROROUTPUT;
      RETURN;
    end;

    // Angebot "löschen"
    if (Auf_P_Subs:ToggleLoeschmarker(n)=false) then begin
      TRANSBRK;
      Msg(400009,'1570',0,0,0);
      RETURN;
    end;


    vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
    // Markierung entfernen
    Lib_Mark:MarkAdd(401, n,y);

    vPos # vPos + 1;
  END;
  RecBufdestroy(vBuf400);

  // Kopftexte kopieren
  Lib_Texte:CopyAllAehnlich('~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.K', 16, '~401.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.K');
  Lib_Texte:CopyAllAehnlich('~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.F', 16, '~401.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.F');

  if (RunAFX('Auf.Ang2Auf.Post',aint(vNummer))<>0) then begin
    if (AfxRes<>_rOK) then begin
      // TRANSBRK schon in AFX
      RETURN;
    end;
  end;

  TRANSOFF;

  Auf.Nummer # vNummer;
  RecRead(400,1,0);
  RecLink(401,400,9,_RecFirst);   // 1.Pos holen

  // Aufpreise refreshen
  ApL_Data:Neuberechnen(400, today);

  // KREDITLIMIT
  Auf_Data:SperrPruefung(0);
  
  //[+] 14.01.2022 MR Bugfix Änderung Angebot anch Auftrag aktualisiert Feld nicht (2346/4)
   Erx # RecLink(100,400,1,_recFirst);  // Kunde holen
   RecRead(100,1,_recLock);
   Adr.Fin.letzterAufam # today;
   RekReplace(100,_recUnlock,'AUTO');
  
  // Erfolg!!!
  Msg(400010,AInt(vNummer),0,0,0);

  RETURN;

end;


//========================================================================
// BAG2Auf
//
//========================================================================
SUB BAG2Auf() : logic;
local begin
  Erx         : int;
  vItem       : int;
  vMFile      : int;
  vMID        : int;
  vAnz        : int;
  vBAG        : int;
  vAuf        : int;
  vBuf401     : int;
  vList       : int;
  vItem2      : int;
end;
begin

  if (RunAFX('Auf.Bag2Auf','')<0) then begin
    RETURN (AfxRes=_rOK);
  end;
  
  // BA zu aktueller Aufpos suchen
  FOR  Erx # RecLink(404,401,12,_RecFirst)     // AufAktionen loopen
  LOOP Erx # RecLink(404,401,12,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // 05.11.2015 Sollmenge oder Lohnba
    if (Auf.A.Aktionstyp=c_Akt_BA_Plan) or
      (Auf.A.Aktionstyp=c_Akt_BA) then begin
      if (vBAG=0) then vBAG # Auf.A.Aktionsnr
      else if (vBAG<>Auf.A.Aktionsnr) then begin
        Msg(401700,'',0,0,0);
        RETURN false;
      end;
    end;

  END;

  // BA exisitert? -> diesen Anzeigen
  if (vBAG>0) then begin
    BA1_Subs:ShowAufBAG(vBAG, 0);
    RETURN true;
  end;

  // 10.02.2015 AH BA aus Vorlage?
  if (Auf.P.VorlageBAG<>0) then begin
    if ("Auf.P.Löschmarker"<>'') then RETURN true;
    if (Msg(401705,aint(Auf.P.VorlageBAG),_WinIcoQuestion,_WinDialogYesNo,2)<>_WinidYes) then RETURN false;
    vBAG # BA1_Lohn_Subs:ErzeugeBAausVorlage(Auf.P.VorlageBAG, Auf.P.Nummer, Auf.P.Position);
    if (vBAG=0) then begin
      ErrorOutput;
      Msg(999999,'',0,0,0);
      RETURN false;
    end;
    
    // ST 2021-08-10 2298/13
    RunAFX('Auf.Bag2Auf.CreateBag.Post',Aint(vBAG));

    // ST 2022-01-07 2297/32
    //BA1_Subs:ShowAufBAG(vBAG, 0);
    BA1_Subs:ShowAufBAG(Bag.Nummer, 0);
    RETURN true;
  end;



  vBuf401 # RekSave(401);
  vList   # CteOpen(_CteList);
  vBAG    # -1;

  // Markierungen testen...
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>401) then CYCLE;

    RecRead(vMFile,0,_RecId,vMID);
    if ("Auf.P.Löschmarker"<>'') then CYCLE;

    if (vAuf=0) then
      vAuf # Auf.P.Nummer
    else if (vAuf<>Auf.P.Nummer) then begin
      vList->CteClear(true);
      vList->CteClose();
      Msg(401701,aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position),0,0,0);
      RekRestore(vBuf401);
      RETURN false;
    end;

    Erx # RecLink(404,401,12,_RecFirst);    // AufAktionen loopen
    WHILE (Erx<=_rLocked) do begin

      if (Auf.A.Aktionstyp=c_Akt_BA_Plan) then begin
        if (vBAG=-1) then vBAG # Auf.A.Aktionsnr
        else if (vBAG<>Auf.A.Aktionsnr) then begin
          vList->CteClear(true);
          vList->CteClose();
          Msg(401702,aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position)+'|'+aint(Auf.A.Aktionsnr),0,0,0);
          RekRestore(vBuf401);
          RETURN false;
        end;
      end;

      Erx # RecLink(404,401,12,_RecNext);
    END;
    if (vBAG=-1) then vBAG # 0;

    // in Liste aufnehmen
    vItem2 # CteOpen(_CteItem);
    vItem2->spname   # Aint(Auf.P.Nummer)+'/'+aint(auf.p.position);
    vList->CteInsert(vItem2);

    inc(vAnz);
  END;

  RekRestore(vBuf401);


  // keine Markierungen?
  if (vAnz=0) then begin
    if ("Auf.P.Löschmarker"<>'') then RETURN true;
    // SINGLE-BA anlegen?
    if (Msg(401703,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinidYes) then RETURN false;

    // in Liste aufnehmen
    vItem2 # CteOpen(_CteItem);
    vItem2->spname   # Aint(Auf.P.Nummer)+'/'+aint(auf.p.position);
    vList->CteInsert(vItem2);

    vBAG # BA1_Subs:CreateBAG(Auf.P.Nummer);
    if (vBAG=0) then begin
      vList->CteClear(true);
      vList->CteClose();
      Msg(999999,'',0,0,0);
      RETURN false;
    end;
    
    // ST 2021-08-10 2298/13
    RunAFX('Auf.Bag2Auf.CreateBag.Post',Aint(vBAG));

    BA1_Subs:ShowAufBAG(vBAG, vList);
    RETURN true;
  end;


  // vorhanden Multi-BA anzeigen...
  if (vBAG>0) then begin
    vList->CteClear(true);
    vList->CteClose();
    BA1_Subs:ShowAufBAG(vBAG,0);
    RETURN true;
  end;


  // neuer MULTI-BA anlegen...
  if (Msg(401704,aint(vAnz),_WinIcoQuestion,_WinDialogYesNo,2)<>_WinidYes) then RETURN false;

  vBAG # BA1_Subs:CreateBAG(vAuf);
  if (vBAG=0) then begin
    Msg(999999,'',0,0,0);
    RETURN false;
  end;

  // ST 2021-08-10 2298/13
  RunAFX('Auf.Bag2Auf.CreateBag.Post',Aint(vBAG));


  BA1_Subs:ShowAufBAG(vBAG, vList);
  RETURN true;
end;


//========================================================================
//  ChangeKundennr
//
//========================================================================
sub ChangeKundennr();
begin

  if (Rechte[Rgt_Auf_Change_Kundennr] = false) then RETURN;

  RecBufClear(100);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung', here + ':AusChangeKundennummer');
  VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
  Lib_Sel:QRecList(0, 'Adr.KundenNr > 0');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  ChangeKundenArtnr
//
//========================================================================
sub ChangeKundenArtnr();
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vA    : alpha;
end;
begin

  // bisher NICHT bei Artikel!
  if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMixArt(Auf.P.Wgr.Dateinr)) then RETURN;

  if (Msg(401024,'',_WinIcoQuestion, _WinDialogYesNo, 2)=_WinIdNo) then begin
    if (Dlg_Standard:Standard(Translate('Kundenartikelnr.'),var vA, n, 40)=false) then RETURN;
    TRANSON;
    if (Auf_Data:SetKundenMatArtNr(0,0,n,vA)=false) then begin
      TRANSBRK;
      ERROROUTPUT;
      RETURN;
    end;
    TRANSOFF;
    gMdi->WinUpdate();
    RETURN;
  end;


  Erx # RecLink(100,400,1,_RecFirst);         // Kunde holen
  if (Erx<>_rOK) then RecBufClear(100);
  RecBufClear(105);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusChangeKundenMatArtNr');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ # '';
  if ("Set.Auf.!EigeneVPG") then begin
    Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
  end
  else begin
    Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
    Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Set.eigeneAdressnr, 'OR');
  end;
  vQ # 'Adr.V.VerkaufYN AND ('+vQ+')'; // 21.07.2015
  Lib_Sel:QRecList(0, vQ);
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  ChangeRechnungsempf
//
//========================================================================
sub ChangeRechnungsempf();
begin
  if (Rechte[Rgt_Auf_Change_Rechnungsempf] = false) then RETURN;

  RecBufClear(100);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung', here + ':AusChangeRechnungsempf');
  VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
  Lib_Sel:QRecList(0, 'Adr.KundenNr > 0');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// ChangeArtikel
//
//========================================================================
sub ChangeArtikel();
local begin
  vHdl  : int;
end;
begin

  if (Auf.P.Prd.LFS>0.0) or (Auf.P.Prd.VSB>0.0) or (Auf.P.Prd.Rech>0.0) then RETURN;
  // ST 2014-02-12: Artikelnummer auch "einfügbar" machen Prj. 1304/237
  if ("Auf.P.Löschmarker"='*') /*or (Auf.P.Artikelnr='') */ then RETURN;

  RecBufClear(250);         // ZIELBUFFER LEEREN

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusChangeArtikel');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vHdl # Winsearch(gMDI,'ZL.Artikel');
  Lib_Sel:QRecList(vHdl,'Art.Nummer>'''' AND NOT(Art.GesperrtYN)');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusChangeArtikel
//
//========================================================================
sub AusChangeArtikel()
local begin
  Erx     : int;
  vAlt    : alpha;
  vNeu    : alpha;
  vMode   : alpha;
  vmitABM : logic;
  vmitTxt : logic;
  vTxtHdl : int;
  vName   : alpha;
end;
begin

  if (RunAFX('Auf.P.ChangeArtikel','')<>0) then RETURN;

  if (gSelected=0) then RETURN;

  RecRead(250,0,_RecId,gSelected);
  gSelected # 0 ;
  vNeu # Art.Nummer;
  if (Auf.P.ArtikelNr=vNeu) then RETURN;
  if ("Auf.P.Löschmarker"='*') then RETURN;


  RecRead(401,1,0);
  if (Msg(401012,vAlt+'|'+vNeu ,_WinIcoQuestion, _WinDialogYesNo, 2)<>_WinidYes) then RETURN;

  RecRead(401,1,0);
  if (Auf.P.Prd.LFS>0.0) or (Auf.P.Prd.VSB>0.0) or (Auf.P.Prd.Rech>0.0) then RETURN;
  if ("Auf.P.Löschmarker"='*') then RETURN;

  if (Auf.P.Dicke<>Art.Dicke) or (Auf.P.Breite<>Art.Breite) or ("Auf.P.Länge"<>"Art.Länge") then begin
    if (Msg(401013,'',_WinIcoQuestion, _WinDialogYesNo, 2) = _WinidYes) then vmitABM # true;
  end;
 
  // 22.05.2019 AH:
  if (Msg(401031,'',_WinIcoQuestion, _WinDialogYesNo, 2) = _WinidYes) then vmitTxt # true;

  TRANSON;

  if (Auf_P_Subs:ToggleLoeschmarker(n)=false) then begin
    TRANSBRK;
    Msg(400009,'1404',0,0,0);
    RETURN;
  end;

  Art.Nummer # vNeu;
  Erx # Recread(250,1,0)

  RecRead(401,1,_recLock);
  PtD_Main:Memorize(401);

  vAlt # Auf.P.Artikelnr;
  Auf.P.ArtikelNr     # vNeu;
  "Auf.P.Güte"        # "Art.Güte";     // 08.05.2019
  Auf.P.ArtikelSW     # Art.Stichwort;  // 27.03.2020
  $lb.P.Bez1->wpcaption # Art.Bezeichnung1;
  $lb.P.Bez2->wpcaption # Art.Bezeichnung2;
  $lb.P.Bez3->wpcaption # Art.Bezeichnung3;
  if (vmitABM) then begin
    Auf.P.Dicke       # Art.Dicke;
    Auf.P.Breite      # Art.Breite;
    "Auf.P.Länge"     # "Art.Länge";
    Auf.P.Dickentol   # Art.Dickentol;
    Auf.P.Breitentol  # Art.Breitentol;
    "Auf.P.Längentol" # "Art.Längentol";
    Auf.P.RID         # Art.Innendmesser;
    Auf.P.RAD         # Art.Aussendmesser;
    Auf.P.Intrastatnr # Art.Intrastatnr;
    Auf.P.Sachnummer  # Art.Sachnummer;
    Auf.P.ArtikelTyp  # Art.Typ;
    // 2023-08-22 AH
    Erx # RecLink(819,250,10,_RecFirst);    // Warengruppe holen
    if (Erx>_rLocked) or (Wgr.Dateinummer<>Auf.P.Wgr.Dateinr) then begin
      TRANSBRK;
      Msg(400009,'1404',0,0,0);
      RETURN;
    end
    Auf.P.Warengruppe # Art.Warengruppe;
  end;
  
  // 22.05.2019 AH:
  if (vMitTxt) then begin
    // Text übernehmen...
    Auf.P.TextNr1 # 401;
    Auf.P.TextNr2 # 0;
    vTxtHdl # TextOpen(20);
    vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    Lib_Texte:TxtLoadLangBuf('~250.VK.'+CnvAI(ART.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, Auf.Sprache);
    TxtWrite(vTxtHdl,vName, _TextUnlock);
    TextClose(vTxtHdl);
  end;

  Auf_Data:PosReplace(_recUnlock,'MAN');
  PtD_Main:Compare(401);


  // 13.09.2016 AH: auch Vorklakulation anpassen
  FOR Erx # RecLink(405,401,7,_recFirst)    // Kalkulation loopen
  LOOP Erx # RecLink(405,401,7,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.K.Bezeichnung=vAlt) and (Auf.K.Typ='POS') then begin
      RecRead(405,1,_recLock);
      Auf.K.Bezeichnung # vNeu;
      Auf.K.Preis       # 0.0;
      if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)) then begin
        Auf.K.Preis       # Art.P.PreisW1;
        RecLink(814,400,8,_recfirst); // Währung holen
        if ("Auf.WährungFixYN") then
          Wae.VK.Kurs   # "Auf.Währungskurs";
        Auf.K.Preis   # Rnd(Auf.K.Preis * "Wae.VK.Kurs",2)
      end;
      RekReplace(405);
      BREAK;
    end;
  END;


  // Sonderfunktion:
  vMode # mode;
  mode # c_ModeEdit;
  if (RunAFX('Auf.P.RecSave','')<>0) then begin
  end;
  mode # vMode;


  // nötige Verbuchungen im Artikel druchführen...
//  Auf_Data:VerbucheArt(vAlt, Auf.P.Menge-Auf.P.Prd.LFS, '');
  if (Auf_P_Subs:ToggleLoeschmarker(n)=false) then begin
    TRANSBRK;
    Msg(400009,'1445',0,0,0);
    RETURN;
  end;

  TRANSOFF;

  if (mode=c_modeView) then App_Main:Refresh();
  gMdi->WinUpdate();

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  AusChangeKundennummer
//
//========================================================================
sub AusChangeKundennummer()

begin

  if (gSelected = 0) then
    RETURN;

  RecRead(100, 0, _recId, gSelected);
  gSelected # 0;

  if (Adr.Kundennr != Auf.Kundennr) then
    if (Auf_Data:SetKundennr(Adr.Kundennr)) then begin

    if (Adr.Kundennr != Auf.Rechnungsempf) then begin
      if (Msg( 400040, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdYes ) then begin
        Auf_Data:SetRechnungsempf(Adr.Kundennr, 1);
      end;
    end;

    if (Adr.Nummer != Auf.Lieferadresse) then begin
      if (Msg( 400041, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdYes ) then begin
        Auf_Data:SetLieferAdr(Adr.Nummer, 1);
      end;
    end;
  end;

  gZLList->WinUpdate(_WinUpdOn, _winLstRecFromRecid | _winLstRecDoSelect);
  $edAuf.KundenNr->WinUpdate(_winUpdFld2Obj);
  Auf_P_SMain:RefreshIfm_Kopf('edAuf.KundenNr', true);
  Auf_P_Main:RefreshIfm();
end;


//========================================================================
//  AusChangeKundenMatArtNr
//
//========================================================================
sub AusChangeKundenMatArtNr()
local begin
  vHdl        : int;
  vMitDaten   : logic;
end
begin
  if (gSelected = 0) then
    RETURN;

  RecRead(105,0,_RecId,gSelected);
  gSelected # 0;

  vHDL # Msg(401023,'',_WinIcoQuestion,_WinDialogYesNoCancel,_winidyes);
  if (vHDL<>_WinIdCancel) then begin
    if (Auf_Data:SetKundenMatArtNr(Adr.V.Adressnr, Adr.V.Lfdnr, vHdl=_Winidyes,'')=false) then begin
      ERROROUTPUT;
      RETURN;
    end;
  end;
//  RefreshIfm('edAuf.P.Erzeuger_Mat',y);
//  RefreshIfm('Text');

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);

  gMdi->WinUpdate();

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  AusChangeRechnungsempf
//
//========================================================================
sub AusChangeRechnungsempf()
local begin
  Erx   : int;
  vQ    : alpha;
  vHdl  : int;
end;
begin
  if (gSelected = 0) then
    RETURN;

  RecRead(100, 0, _recId, gSelected);
  gSelected # 0;

  if (RecLinkInfo(101,100,12,_recCount)>1) then begin // Mehr als eine Anschrift vorhanden?
    // Event für Anschriftsauswahl starten
    RecBufClear(101);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusChangeRechnungsanschr');

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

    vQ # '';
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
    vHdl # SelCreate(101, 1);
    Erx # vHdl->SelDefQuery('', vQ);
    if (Erx <> 0) then
      Lib_Sel:QError(vHdl);
    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
    // Liste selektieren...
    gZLList->wpDbSelection # vHdl;

    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end
  else begin
    Auf_Data:SetRechnungsempf(Adr.Kundennr, 1);
  end;

  gZLList->WinUpdate(_WinUpdOn, _winLstRecFromRecid | _winLstRecDoSelect);
  $edAuf.Rechnungsempf->WinUpdate(_winUpdFld2Obj);
  $edAuf.Rechnungsanschr->WinUpdate(_winUpdFld2Obj);
  Auf_P_SMain:RefreshIfm_Kopf('edAuf.Rechnungsempf', true);
end;


//========================================================================
//  AusChangeRechnungsanschr
//
//========================================================================
sub AusChangeRechnungsanschr()
begin
  if (gSelected = 0) then
    RETURN;

  RecRead(101, 0, _recId, gSelected);
  gSelected # 0;
  Reclink(100,101,1,_recFirst); // Adresse holen
//  if (Adr.Kundennr != Auf.Rechnungsempf) or () then
//  Auf_Data:SetRechnungsempf(Adr.Kundennr, 1);
  Auf_Data:SetRechnungsempf(Adr.Kundennr, Adr.A.Nummer);

  gZLList->WinUpdate(_WinUpdOn, _winLstRecFromRecid | _winLstRecDoSelect);
  $edAuf.Rechnungsempf->WinUpdate(_winUpdFld2Obj);
  $edAuf.Rechnungsanschr->WinUpdate(_winUpdFld2Obj);
  Auf_P_SMain:RefreshIfm_Kopf('edAuf.Rechnungsempf', true);
end;



//========================================================================
//  ZuFahrauftrag             ST 2013-02-27 Projekt 1449/5
//    Legt einen Fahrauftrag für alle markierten Aufträge an
//========================================================================
sub ZuFahrauftrag() : logic
local begin
  Erx           : int;
  vMarked       : int;        // Descriptor für den Marierungsbaum
  vMarkedItem   : int;        // Descriptor für markierten Eintrag
  vMFile        : int;
  vMID          : int;

  vMerkKunde        : int;        //  Kundenmerker
  vMerkLieferziel   : alpha;      //  Lieferanschriftsmerker
  vMarkedOK         : logic;      //  Merker ob markierte Aufträge ok sind
  vEinzel           : logic;
  vAlleVSBs         : logic;
end
begin

  // -------------------------
  // --- Prüfungen -----------

  // Prüfen ob Aufträge markiert sind?
  if (Lib_Mark:Count(401) = 0) then begin
    // Kein Auftrag markiert, dann aktuelle Auftragspositin markieren
    RecRead(401,1,0);
    
    
    // NICHT markieren, sondern einzeln aufrufen (09.07.2015 AH)
    vMerkKunde        # Auf.Kundennr;
    vMerkLieferziel   # Aint(Auf.Lieferadresse) + '/' + Aint(Auf.Lieferanschrift);      //  Lieferanschriftsmerker
    vMarkedOK         # true;
    vEinzel           # true;
    
    // 16.04.2019 AH:
    // Abfragen, ob alles?
    vAlleVSBS # true;
    if ( Msg( 440004, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdNo ) then
      vAlleVSBS # false;
  end
  else begin

    // Markierte Aufträge prüfen
    vMarkedOK # true;
    FOR     vMarked # gMarkList->CteRead(_CteFirst);
    LOOP    vMarked # gMarkList->CteRead(_CteNext, vMarked);
    WHILE ( vMarked > 0) DO BEGIN
      Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);

      // nur Auftragspositionen relevant
      if (vMFile <> 401) then
        CYCLE;

      Erx # RecRead(401, 0, _recId, vMID);
      RekLink(400,401,3,0);   // Kopf lesen

      if (vMerkKunde = 0) then begin
        // bei erster Iteration Prüfwerte bestimmen...
        vMerkKunde        # Auf.Kundennr;
        vMerkLieferziel   # Aint(Auf.Lieferadresse) + '/' + Aint(Auf.Lieferanschrift);      //  Lieferanschriftsmerker
      end
      else begin
        // ...ansonsten Prüfen

        if (vMerkKunde <> Auf.Kundennr) OR
           (vMerkLieferziel <> Aint(Auf.Lieferadresse) + '/' + Aint(Auf.Lieferanschrift)) then begin

          // Kunde, und/oder Lieferanschriften passen nicht
          vMarkedOK # false;
          BREAK;
        end;

      end;

      // Nächste Maerkierung
    END;
  end;


  if (vMarkedOK = false) then begin
    // Kunde, und/oder Lieferanschriften passen nicht
    Error(99,'Kunde und/oder Lieferanschriften sind nicht identisch.');
    RETURN false;
  end;

  // --------------------------------------------
  // --- Maerkierung IO, jetzt Fahrauftrag anlegen
  RecBufClear(440);
  Lfs.Nummer        # myTmpNummer;
  Lfs.Anlage.Datum  # today;
  Lfs.Kundennummer  # Auf.P.Kundennr;
  Lfs.Kundenstichwort # Auf.P.KundenSW;
  Lfs.Zieladresse   # Auf.Lieferadresse;
  Lfs.Zielanschrift # Auf.Lieferanschrift;

  if (vEinzel) then begin
    if (vAlleVSBs) then
      Erx # _ZuFahrauftrag_EinzelAufP_Delegat();
  end
  else begin
    Erx # Lib_Mark:Foreach(401, 'Auf_Subs:_ZuFahrauftrag_EinzelAufP_Delegat');
  end;

  if (Erx < _errOK) then
    RETURN false;

  RETURN true;
end;


//========================================================================
//  sub _ZuFahrauftrag_EinzelAufP_Delegat() : int ST 2013-02-27 Projekt 1449/5
//    Legt einen Fahrauftrag für einen Auftrag an
//========================================================================
sub _ZuFahrauftrag_EinzelAufP_Delegat() : int
local begin
  Erx     : int;
  vKLim   : float;
end
begin

  // Auftragsposition ist gelesen
  RecLink(400,401,3,_recFirst);   // Kopf holen

  // Kreditlimit prüfen...
  if ("Set.KLP.LFA-Druck"<>'') then
    if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFA-Druck",n, var vKLim)=false) then RETURN -1;

  // MATERIAL -----------------------------------
  if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
    // tmp. Lieferschein aufbauen
    Lieferschein(y,700, true);
    Erx # RecLink(441,440,4,_recFirst); // temp. Lieferpositionen holen
    if (Erx<=_rlocked) then begin
      RecLink(401,441,5,_recFirst);     // Auftragspos holen
    end;
  end
   // ARTIKEL ------------------------------------
  else if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin

    // gibts schon offene VLDAW ??
    if (Auf_Data:UpdateVLDAW()=true) then RETURN 0;

    // sonst neuen LFS generieren:
    // tmp. Lieferschein aufbauen
    Lieferschein(y,700, true);

    if (RecLinkInfo(441,440,4,_recCount)=0) then begin
      Error(440105,'');     //      Msg(440105,'',0,0,0);
      RETURN -2;
    end;
  end; // Artikel

end;


//========================================================================
//  CopyBAGanAuf
//      kopiert BA für neuen Auftrag mit Ersetzung der Kommission und Mat durch Theo
//      27.03.2019 AH: ohne Zeiten
//========================================================================
sub CopyBAGanAuf(
  var aBAG  : int;
  aVorlage  : int;
  aAufNr    : int;
  aAufPos   : int;
  ) : logic;
local begin
  vPos      : int;
end;
begin

  TRANSON;

  // Kopf anlegen...
  if (aBAG=0) then begin
    if (BA1_Lohn_Subs:Erzeuge700()=false) then begin
      TRANSBRK;
      ERROROUTPUT;
      RETURN false;
    end;
    aBAG # BAG.Nummer;
  end;

  if (BA1_P_Data:ImportBA(aBAG, aVorlage, aAufNr, aAufPos, y, true)=0) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;

//========================================================================