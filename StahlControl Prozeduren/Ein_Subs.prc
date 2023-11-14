@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_Subs
//                  OHNE E_R_G
//  Info
//
//
//  09.02.2009  AI  Erstellung der Prozedur
//  30.04.2010  AI  Bestellung kopieren nimmt keine Abrufnr. mit
//  17.10.2013  AH  Anfragen
//  21.03.2016  AH  "CopyBestellungAblage"
//  09.09.2016  AH  "Bag2Anf" kann direkt bestellen
//  26.01.2018  AH  AnalyseErweitert
//  15.10.2018  AH  Neu: AFX "Ein.Druck.Best"
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB CopyAuftrag(aAufNummer : int; aAufPosition : int) : logic;
//    SUB CopyAuftragAuswahl(opt aTyp : alpha) : logic;
//    SUB CopyBestellung()
//    SUB CopyBestellungAuswahl(opt aTyp : alpha) : logic;

//    SUB Auf2Anf();
//    SUB AusLieferant_Auf2Anf();
//    SUB Anf2Anf();
//    SUB AusLieferant_Anf2Anf();
//    SUB Anf2Best();

//    SUB DruckBest() : logic;
//    SUB DruckAnfrage() : logic;
//    SUB Bag2Anf(aDirektBestellen : logic) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

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
  vI      : int;
end;
begin
  if (aAufNummer = 0) then begin
    if (Dlg_Standard:Standard(Translate('Auftrag'),var vA)=false) then
      RETURN false;
    if (StrFind(vA,'/',0)=0) then begin
      vAuf # Cnvia(vA);
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
  Erx # RecLink(501,500,9,_RecLast);
  if (Erx>_rLocked) then vPos2 # 0
  else vPos2 # Ein.P.Position;
  vOff # vPos2;



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
    if (Erx>_rLocked) then RETURN false;
    RecBufCopy(410,400);
    vAblage # true;
    vDatei1 # 410;
    vDatei2 # 411;
  end;


  Erx # RecLink(vDatei2, vDatei1 ,9,_RecFirst);   // Auftragspositionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (vAblage) then RecBufCopy(411,401);

    // gezielt nur EINE Position?
    if (vPos<>0) and (Auf.P.Position<>vPos) then begin
      Erx # RecLink(vDatei2, vDatei1 ,9,_RecNext);
      CYCLE;
    end;


    vPos2 # vPos2 + 1;

    // neu nummerieren...
    RecBufClear(501);
    Ein.P.Nummer    # Ein.Nummer;
    Ein.P.Position  # vPos2;
    Ein.P.Lieferantennr # Ein.Lieferantennr;
    Ein.P.LieferantenSW # Ein.LieferantenSW;

    /* MS 14.06.2010 Prj. 1246/18*/
    /* AI 22.06.2010 MUSS SEIN */
    // Daten übernehmen...............
    if (vAblage=false) and
      (Auf.Vorgangstyp=c_AUF)then begin   // 01.06.2022 AH
      Ein.P.Kommissionnr  # Auf.P.Nummer;
      Ein.P.Kommissionpos # Auf.P.Position;
      Ein.P.Kommission    # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position)
      Ein.P.KommiKunde    # Auf.P.Kundennr;
    end;

    /**/
    "Ein.P.Güte"        # "Auf.P.Güte";
    "Ein.P.Gütenstufe"  # "Auf.P.Gütenstufe";
    Ein.P.AusfOben      # Auf.P.AusfOben;
    Ein.P.AusfUnten     # Auf.P.AusfUnten;
    // bisherige Ausführung löschen
    WHILE (RecLink(502,501,12,_recFirst)<=_rLocked) do begin
      Erx # RekDelete(502,0,'MAN');
      if (Erx<>_rOK) then BREAK;
    END;
    // Ausführung kopieren
    Erx # RecLink(402,401,11,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Ein.AF.Nummer       # Ein.P.Nummer;
      Ein.AF.Position     # Ein.P.Position;
      Ein.AF.Seite        # Auf.AF.Seite;
      Ein.AF.lfdNr        # Auf.AF.lfdNr;
      Ein.AF.ObfNr        # Auf.AF.ObfNr;
      Ein.AF.Bezeichnung  # Auf.AF.Bezeichnung;
      Ein.AF.Zusatz       # Auf.AF.Zusatz;
      Ein.AF.Bemerkung    # Auf.AF.Bemerkung;
      "Ein.AF.Kürzel"     # "Auf.AF.Kürzel";
      Erx # RekInsert(502,_recunlock,'AUTO')
      if (erx<>_rOK) then BREAK;
      Erx # RecLink(402,401,11,_recNext);
    END;

    Ein.P.Erzeuger      # Auf.P.Erzeuger;
    Ein.P.Zeugnisart    # Auf.P.Zeugnisart;
    Ein.P.Intrastatnr   # Auf.P.Intrastatnr;
    Ein.P.Dicke         # Auf.P.Dicke;
    Ein.P.DickenTol     # Auf.P.DickenTol;
    Ein.P.Breite        # Auf.P.Breite;
    Ein.P.BreitenTol    # Auf.P.BreitenTol;
    "Ein.P.LängenTol"   # "Auf.P.LängenTol";
    "Ein.P.Länge"       # "Auf.P.Länge";
    Ein.P.RID           # Auf.P.RID;
    Ein.P.RIDmax        # Auf.P.RIDmax;
    Ein.P.RAD           # Auf.P.RAD;
    Ein.P.RADmax        # Auf.P.RADmax;

    "Ein.P.Stückzahl"   # "Auf.P.Stückzahl";
    Ein.P.Gewicht       # Auf.P.Gewicht;
    Ein.P.Menge.Wunsch  # Auf.P.Menge.Wunsch;
    Ein.P.MEH.Wunsch    # Auf.P.MEH.Wunsch;

    Ein.P.Auftragsart   # Auf.P.Auftragsart;
    Ein.P.Warengruppe   # Auf.P.Warengruppe;
    Ein.P.Wgr.Dateinr   # Auf.P.Wgr.Dateinr;
    Ein.P.ArtikelID     # Auf.P.ArtikelID;
    Ein.P.Artikelnr     # Auf.P.Artikelnr;
    Ein.P.ArtikelSW     # Auf.P.ArtikelSW;
    Ein.P.Sachnummer    # Auf.P.Sachnummer;
    Ein.P.Katalognr     # Auf.P.Katalognr;
    Ein.P.Strukturnr    # Auf.P.Strukturnr;
    Ein.P.TextNr1       # Auf.P.TextNr1;
    if (Ein.P.TextNr1=400) then Ein.P.TextNr1 # 500;
    if (Ein.P.TextNr1=401) then Ein.P.TextNr1 # 501;
    Ein.P.TextNr2       # Auf.P.TextNr2;
    if (Ein.P.TextNr1=500) then Ein.P.TextNr2 # Ein.P.TextNr2 + vOff;
    Ein.P.Termin1W.Art  # Auf.P.Termin1W.Art;
    Ein.P.Termin1W.Zahl # Auf.P.Termin1W.Zahl;
    Ein.P.Termin1W.Jahr # Auf.P.Termin1W.Jahr;
    Ein.P.Termin1Wunsch # Auf.P.Termin1Wunsch;
    Ein.P.Termin2W.Zahl # Auf.P.Termin2W.Zahl;
    Ein.P.Termin2W.Jahr # Auf.P.Termin2W.Jahr;
    Ein.P.Termin2Wunsch # Auf.P.Termin2Wunsch;
    Ein.P.Bemerkung     # Auf.P.Bemerkung;
    Ein.P.MEH.Preis     # Auf.P.MEH.Preis;
    Ein.P.PEH           # Auf.P.PEH;
    Ein.P.Menge         # Auf.P.Menge;
    Ein.P.MEH           # Auf.P.MEH.Einsatz;
    Ein.P.Projektnummer # Auf.P.Projektnummer;
    Ein.P.AbmessString  # Auf.P.AbmessString;
    //Ein.P.Kostenstelle  # Auf.P.Kostenstelle;

    SbrCopy(401,3,501,3); // Analysen kopieren
//    SbrCopy(401,4,501,4); // Verpackung kopieren
    FOR vI # 1 loop inc(vI) WHILE (vI<=26) do begin
      FldCopy(401,4,vI, 501,4,vI);
    END;
    Ein.P.Verpacknr       # Auf.P.Verpacknr;
    Ein.P.VerpackAdrNr    # Auf.P.VerpackAdrNr;
    Ein.P.VpgText6        # Auf.P.VpgText6;
    Ein.P.Umverpackung    # Auf.P.Umverpackung;
    Ein.P.Wicklung        # Auf.P.Wicklung;
    "Ein.P.SäbelProM"     # "Auf.P.SäbelProM";
    Ein.P.Skizzennummer   # Auf.P.Skizzennummer;

    // ANLEGEN:
    Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
    Ein.P.Gesamtpreis   # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    Ein.P.Anlage.Datum  # today;
    Ein.P.Anlage.Zeit   # now;
    Ein.P.Anlage.User   # gUsername;
    Lib_MoreBufs:RecInit(401, y, y);
    Erx # Ein_Data:PosInsert(0,'AUTO');
    if (erx<>_rOk) then begin
      RETURN false;
    end;
    if (Lib_MoreBufs:SaveAll(501)<>_rOK) then begin
      RETURN false;
    end;

    // Text kopieren?
    if (Ein.P.TextNr1=501) then begin
      vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TxtCopy(vName,vName2,0);
    end;

    Erx # RecLink(vDatei2, vDatei1 ,9,_RecNext);
  END;

  $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:Refreshmode();

  RETURN true;
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
    Ein_Subs:CopyAuftrag(Auf.P.Nummer ,Auf.P.Position);
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
    Ein_Subs:CopyAuftrag("Auf~P.Nummer","Auf~P.Position");
  end;

end;


//========================================================================
//  CopyAuftragAuswahl
//
//========================================================================
sub CopyAuftragAuswahl(opt aTyp : alpha) : logic;
local begin
  vHdl    : int;
  vA      : alpha;
  vQ      : alpha;
  tErx    : int;
end;
begin
 // Auftragspositionsauswahl aus Auftragsbestand?
  if (aTyp = '') or (aTyp='BESTAND') then begin
    RecBufClear(401);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':ausAuftragAuswahlBestand');
    Lib_GuiCom:RunChildWindow(gMDI);
  end
  // Auftragspositionsauswahl aus Auftragsablage?
  else if (aTyp='ABLAGE') then begin
    RecBufclear(411);
    RecLink(411,100,71,_recFirst);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Auf.P.Ablage',here+':ausAuftragAusswahlAblage',n,n,'-INFO');
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
  vBuf500 : int;
  vBuf501 : int;
  vBuf502 : int;
  vBuf503 : int;
  vBuf505 : int;
end;
begin

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
    end
  end
  else begin
    vEin  # aEin;
    vPOs  # aPos;
  end;


  // nächste temp. Position bestimmen...
  Erx # RecLink(501,500,9,_RecLast);
  if (Erx>_rLocked) then vPos2 # 0
  else vPos2 # Ein.P.Position;
  vOff # vPos2;


  vBuf500 # RekSave(500);

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
      RekRestore(vBuf500);
      RETURN false;
    end;
    RecBufCopy(510,500);
    vAblage # true;
    vDatei1 # 510;
    vDatei2 # 511;
  end;


  Erx # RecLink(vDatei2, vDatei1, 9,_RecFirst);   // Bestellpositionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (vAblage) then RecBufCopy(511,501);

    // gezielt nur EINE Position?
    if (vPos<>0) and (Ein.P.Position<>vPos) then begin
      Erx # RecLink(vDatei2, vDatei1 ,9,_RecNext);
      CYCLE;
    end;
    vBuf501 # RekSave(501);

    vPos2 # vPos2 + 1;

    Lib_MoreBufs:RecInit(501, y, y);

    // neu nummerieren...
    Ein.P.Nummer          # vBuf500->Ein.Nummer;
    Ein.P.Position        # vPos2;
    Ein.P.Lieferantennr   # vBuf500->Ein.Lieferantennr;
    Ein.P.LieferantenSW   # vBuf500->Ein.LieferantenSW;
    Ein.P.AB.Nummer       # vBuf500->Ein.AB.Nummer;   // 11.10.2019
    Ein.P.Flags           # '';
    Ein.P.FM.Eingang      # 0.0;
    Ein.P.FM.VSB          # 0.0;
    Ein.P.FM.Ausfall      # 0.0;
    Ein.P.FM.Eingang.Stk  # 0;
    Ein.P.FM.VSB.Stk      # 0;
    Ein.P.FM.Ausfall.Stk  # 0;
    Ein.P.Materialnr      # 0;
    "Ein.P.Löschmarker"   # '';
    Ein.P.Aktionsmarker   # '';
    Ein.P.Eingangsmarker  # '';
    "Ein.P.Lösch.Datum"   # 0.0.0;
    "Ein.P.Lösch.Zeit"    # 0:0;
    "Ein.P.Lösch.User"    # '';
    // 30.04.2010 AI: keine Abrufnummern übernehmen
    Ein.P.AbrufAufNr      # 0;
    Ein.P.AbrufAufPos     # 0;

    /* MS 14.06.2010 Prj. 1246/18
    if (vAblage) then begin

    end;
    */
    if (Ein.Vorgangstyp=c_Bestellung) then begin
      Ein.P.Kommissionnr  # 0;
      Ein.P.Kommissionpos # 0;
      Ein.P.Kommission    # '';
      Ein.P.KommiKunde    # 0;
    end;

    // Ausführung kopieren
    Erx # RecLink(502, vBuf501, 12, _recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf502 # RekSave(502);
      Ein.AF.Nummer       # Ein.P.Nummer;
      Ein.AF.Position     # Ein.P.Position;
      RekInsert(502,_recunlock,'AUTO')
      RekRestore(vBuf502);
      Erx # RecLink(502, vBuf501, 12, _recNext);
    END;

    // Aufpreise kopieren
    Erx # RecLink(503,vBuf501,7,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf503 # RekSave(503);
      Ein.Z.Nummer       # Ein.P.Nummer;
      Ein.Z.Position     # Ein.P.Position;
      RekInsert(503,_recunlock,'AUTO')
      RekRestore(vBuf503);
      Erx # RecLink(503,vBuf501,7,_recNext);
    END;

    // Kalkulation kopieren
    Erx # RecLink(505,vBuf501,8,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      vBuf505 # RekSave(505);
      Ein.AF.Nummer       # Ein.P.Nummer;
      Ein.AF.Position     # Ein.P.Position;
      RekInsert(505,_recunlock,'AUTO')
      RekRestore(vBuf505);
      Erx # RecLink(505,vBuf501,8,_recNext);
    END;

    Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
    Ein.P.Gesamtpreis   # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    Ein.P.Anlage.Datum  # today;
    Ein.P.Anlage.Zeit   # now;
    Ein.P.Anlage.User   # gUsername;
    // ANLEGEN:
    Erx # Ein_Data:PosInsert(0,'AUTO');
    if (Erx<>_rOk) then begin
      RekRestore(vBuf501);
      RekRestore(vBuf500);
      RETURN false;
    end;

    if (Lib_MoreBufs:SaveAll(501)<>_rOK) then begin
      RekRestore(vBuf501);
      RekRestore(vBuf500);
      RETURN false;
    end;

    // Text kopieren?
    if (Ein.P.TextNr1=501) then begin
      vName # '~501.'+CnvAI(vBuf501->Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vBuf501->Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TxtCopy(vName,vName2,0);
    end;

    RekRestore(vBuf501);

    Erx # RecLink(vDatei2, vDatei1 ,9,_RecNext);
  END;

  RekRestore(vBuf500);
  
  // 2022-12-01 AH  Fix gegen Versprung:
  Ein.P.Nummer   # Ein.Nummer;
  Ein.P.Position # vPos2;
  

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
    RecLink(511,100,29,_recFirst);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ein.P.Ablage',here+':ausBestellungAuswahlAblage',n,n,'-INFO');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

    // Selektion aufbauen...
    vQ # '';
    // hier ggf. spezielle Aufträge selektieren
    Lib_Sel:QInt( var vQ, 'Ein~P.Lieferantennr', '=', Ein.Lieferantennr );

    vHdl # SelCreate(511, gKey);
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
//  ausBestellungAuswahlBestand
//
//========================================================================
sub ausBestellungAuswahlBestand()
begin
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    gSelected # 0;

    // Kopierfunktion mit Auftragsnummer aufrufen
    Ein_Subs:CopyBestellung(Ein.P.Nummer ,Ein.P.Position);
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
    Ein_Subs:CopyBestellung("Ein~P.Nummer","Ein~P.Position");
  end;
end;


//========================================================================
// Auf2Anf
//        kopiert markierte Auftragspositionen in einen neuen Anfrage
//========================================================================
sub Auf2Anf();
local begin
  Erx     : int;
  vItem   : int;
  vPos    : int;
  vMFile  : Int;
  vMID    : Int;
  v400    : int;
  v401    : int;
end
begin

  if (Set.Ein.AnfragenYN=false) then RETURN;

  v400 # RekSave(400);
  v401 # RekSave(401);

  vItem # gMarkList->CteRead(_CteFirst);  // erste Element holen

  vPos # 0;
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=401) then begin
      Erx # RecRead(401,0,_RecID, vMID);
      if (Erx<=_rOK) then begin
        RecLink(400,401,3,_recFirsT);   // Kopf holen
        if (Auf.Vorgangstyp=c_Auf) or (Auf.Vorgangstyp=c_Ang) then begin
          vPos # vPos + 1;
        end;
      end;
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  END;
  if (vPos=0) then begin
    RekRestore(v400);
    RekRestore(v401);
    RETURN;
  end;

  // Sicherheitsabfrage
  if (Msg(400027,AInt(vPos),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
    RekRestore(v400);
    RekRestore(v401);
    RETURN;
  end;


  if (Msg(400030,'',_WinIcoInformation,_WinDialogOkCancel,1)<>_WinIdOk) then begin
    RekRestore(v400);
    RekRestore(v401);
    RETURN;
  end;

  RekRestore(v400);
  RekRestore(v401);

  // ggf. mehrere Lieferanten markieren! / übernehmen aus voriger Prozedur
  RecBufClear(100);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant_Auf2Anf');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');  // hier Selektion
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  _AufPos2AngPos
//========================================================================
SUB _AufPos2AngPos(
  a100    : int;
  aPos    : int) : int;
local begin
  Erx     : int;
  vI      : int;
  vName   : alpha;
  vName2  : alpha;
end;
begin
  RecBufClear(501);
  Ein.P.Nummer          # Ein.Nummer;
  Ein.P.Position        # aPos;

  Ein.P.Lieferantennr   # Ein.Lieferantennr;
  Ein.P.LieferantenSW   # Ein.LieferantenSW;
  if (Set.Installname<>'HWN') then    // 2022-12-15 AH Proj. 2228/215
    Ein.P.Erzeuger        # a100->Adr.Nummer;
  Ein.P.Verwiegungsart  # a100->Adr.EK.Verwiegeart;

//  Ein.P.MEH.Preis       # Set.Ein.MEH.PEH;
//  Ein.P.PEH             # Set.Ein.PEH;
//  Ein.P.MEH.Wunsch      # Ein.P.MEH.Preis;
//  Ein.P.Auftragsart     # Set.Ein.Auftragsart;
//  Ein.P.Termin1W.Art    # Set.Ein.TerminArt;
  Ein.P.Termin1W.Art  # Auf.P.Termin1W.Art;
  Ein.P.Termin1W.Zahl # Auf.P.Termin1W.Zahl;
  Ein.P.Termin1W.Jahr # Auf.P.Termin1W.Jahr;
  Ein.P.Termin1Wunsch # Auf.P.Termin1Wunsch;
  Ein.P.Termin2W.Zahl # Auf.P.Termin2W.Zahl;
  Ein.P.Termin2W.Jahr # Auf.P.Termin2W.Jahr;
  Ein.P.Termin2Wunsch # Auf.P.Termin2Wunsch;
  Ein.P.Bemerkung     # Auf.P.Bemerkung;
  Ein.P.MEH.Preis     # Auf.P.MEH.Preis;
  Ein.P.PEH           # Auf.P.PEH;
  Ein.P.Menge         # Auf.P.Menge;
  Ein.P.MEH           # Auf.P.MEH.Einsatz;
  Ein.P.Projektnummer # Auf.P.Projektnummer;
  Ein.P.AbmessString  # Auf.P.AbmessString;


  Ein.P.Kommissionnr    # Auf.P.Nummer;
  Ein.P.Kommissionpos   # Auf.P.Position;
  Ein.P.Kommission      # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position)
  Ein.P.KommiKunde      # Auf.P.Kundennr;
  Ein.P.Artikelnr       # Auf.P.Artikelnr;
  Ein.P.ArtikelSW       # Auf.P.ArtikelSW;
  Ein.P.Sachnummer      # Auf.P.Sachnummer;
  "Ein.P.Güte"          # "Auf.P.Güte";
  "Ein.P.Gütenstufe"    # "Auf.P.Gütenstufe";
  Ein.P.Werkstoffnr     # Auf.P.Werkstoffnr;
  Ein.P.AusfOben        # Auf.P.AusfOben;
  Ein.P.AusfUnten       # Auf.P.AusfUnten;
  // bisherige Ausführung löschen
  WHILE (RecLink(502,501,12,_recFirst)<=_rLocked) do begin
    Erx # RekDelete(502,0,'MAN');
    if (Erx<>_rOK) then BREAK;
  END;
  // Ausführung kopieren
  Erx # RecLink(402,401,11,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Ein.AF.Nummer       # Ein.P.Nummer;
    Ein.AF.Position     # Ein.P.Position;
    Ein.AF.Seite        # Auf.AF.Seite;
    Ein.AF.lfdNr        # Auf.AF.lfdNr;
    Ein.AF.ObfNr        # Auf.AF.ObfNr;
    Ein.AF.Bezeichnung  # Auf.AF.Bezeichnung;
    Ein.AF.Zusatz       # Auf.AF.Zusatz;
    Ein.AF.Bemerkung    # Auf.AF.Bemerkung;
    "Ein.AF.Kürzel"     # "Auf.AF.Kürzel";
    Erx # RekInsert(502,_recunlock,'AUTO')
    if (Erx<>_rOK) then RETURN -502;
    Erx # RecLink(402,401,11,_recNext);
  END;


  Ein.P.Auftragsart   # Auf.P.Auftragsart;
  Ein.P.Warengruppe   # Auf.P.Warengruppe;
  Erx # RecLink(819,501,1,_RecFirst);   // Warengruppe holen
  Ein.P.Wgr.Dateinr     # Wgr.Dateinummer;

  Ein.P.Strukturnr    # Auf.P.Strukturnr;
  if (Auf.P.Erzeuger<>0) then Ein.P.Erzeuger      # Auf.P.Erzeuger;
  Ein.P.Zeugnisart    # Auf.P.Zeugnisart;
  Ein.P.Intrastatnr   # Auf.P.Intrastatnr;
  Ein.P.Dicke         # Auf.P.Dicke;
  Ein.P.DickenTol     # Auf.P.DickenTol;
  Ein.P.Breite        # Auf.P.Breite;
  Ein.P.BreitenTol    # Auf.P.BreitenTol;
  "Ein.P.LängenTol"   # "Auf.P.LängenTol";
  "Ein.P.Länge"       # "Auf.P.Länge";
  Ein.P.RID           # Auf.P.RID;
  Ein.P.RIDmax        # Auf.P.RIDmax;
  Ein.P.RAD           # Auf.P.RAD;
  Ein.P.RADmax        # Auf.P.RADmax;
  "Ein.P.Stückzahl"   # "Auf.P.Stückzahl";
  Ein.P.Gewicht       # Auf.P.Gewicht;
  Ein.P.Menge.Wunsch  # Auf.P.Menge.Wunsch;
  Ein.P.MEH.Wunsch    # Auf.P.MEH.Wunsch;
  Ein.P.Menge         # Ein.P.Menge.Wunsch;

  SbrCopy(401,3,501,3); // Analysen kopieren
  FOR vI # 1 loop inc(vI) WHILE (vI<=26) do begin
    FldCopy(401,4,vI, 501,4,vI);
  END;
  Ein.P.Verpacknr       # Auf.P.Verpacknr;
  Ein.P.VerpackAdrNr    # Auf.P.VerpackAdrNr;
  Ein.P.VpgText6        # Auf.P.VpgText6;
  Ein.P.Umverpackung    # Auf.P.Umverpackung;
  Ein.P.Wicklung        # Auf.P.Wicklung;
  "Ein.P.SäbelProM"     # "Auf.P.SäbelProM";
  Ein.P.Skizzennummer   # Auf.P.Skizzennummer;


  // Text kopieren...
  if (Auf.P.TextNr1=0) then begin
    Ein.P.TextNr1 # 0;
    Ein.P.TextNr2 # Auf.P.TextNr2;
  end;
  if (Auf.P.TextNr1=401) then begin
    Ein.P.TextNr1 # 501;
    Ein.P.TextNr2 # 0;
    vName  # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    vName2 # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    TxtCopy(vName, vName2, 0);
  end;
  if (Auf.P.TextNr1=400) then begin
    Ein.P.TextNr1 # 501;
    Ein.P.TextNr2 # 0;
    vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    TxtCopy(vName, vName2, 0);
  end;


  Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
  Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
  if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
  if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
  Ein.P.Gesamtpreis   # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
  Ein.P.Anlage.Datum  # today;
  Ein.P.Anlage.Zeit   # now;
  Ein.P.Anlage.User   # gUsername;

  Lib_MoreBufs:RecInit(401, y, y);

  Erx # Ein_data:PosInsert(_recunlock,'AUTO');
  if (Erx<>_rOK) then RETURN -1;

  if (Lib_MoreBufs:SaveAll(501)<>_rOK) then begin
    RETURN -1;
  end;

  // Sonderfunktion:
  if (RunAFX('Ein.Auf2Anf.P.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then RETURN -1;
  end;


  // Auftragsaktion anlegen...
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_Anfrage;
  Auf.A.Bemerkung     # c_AktBem_Anfrage+' '+Ein.P.LieferantenSW;
  Auf.A.Aktionsnr     # Ein.P.Nummer;
  Auf.A.Aktionspos    # Ein.P.Position;
  Auf.A.Aktionsdatum  # Today;
  Auf.A.TerminStart   # Today;
  Auf.A.TerminEnde    # Today;
  if (Auf_A_Data:NeuAnlegen()<>_rOK) then begin
    TRANSBRK;
    RETURN -404;
  end;

  RETURN 0;
end;


//========================================================================
// AusLieferant_Auf2Anf
//        kopiert markierte Auftragspositionen in einen neuen Anfrage
//========================================================================
sub AusLieferant_Auf2Anf();
local begin
  Erx     : int;
  vItem   : int;
  vMFile  : Int;
  vMID    : Int;
  vHdl    : int;
  vPos    : int;
  vNummer : int;
  v100    : int;
  v400    : int;
  v401    : int;
end
begin

  if (gSelected=0) then RETURN;

  v400 # RekSave(400);
  v401 # RekSave(401);

  v100 # RecBufCreate(100);
  RecRead(v100,0,_RecId,gSelected);
  gSelected # 0;

  TRANSON;

  vPos # 1;
  vNummer # Lib_Nummern:ReadNummer('Anfrage');
  if (vNummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RecBufDestroy(v100);
    RekRestore(v400);
    RekRestore(v401);
    RETURN;
  end;

  // Kopf anlegen
  RecbufClear(500);
  Ein.Nummer            # vNummer;
  Ein.VorgangsTyp       # c_Anfrage;
  Ein.Datum             # today;
  Ein.Sachbearbeiter    # gUserName;

  Ein.Lieferantennr     # v100->Adr.Lieferantennr;
  Ein.LieferantenSW     # v100->Adr.Stichwort;
  "Ein.Währung"         # v100->"Adr.EK.Währung";
  Ein.Lieferbed         # v100->Adr.EK.Lieferbed;
  Ein.Zahlungsbed       # v100->Adr.EK.ZAhlungsbed;
  Ein.Versandart        # v100->Adr.EK.Versandart;
  Ein.Sprache           # v100->Adr.Sprache;
  Ein.AbmessungsEH      # v100->Adr.AbmessungEH;
  Ein.GewichtsEH        # v100->Adr.GewichtEH;
  "Ein.Steuerschlüssel" # v100->"Adr.Steuerschlüssel";
  if (Set.Ein.Lieferadress=-1) then begin
    Ein.Lieferadresse   # v100->Adr.Nummer;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end
  else begin
    Ein.Lieferadresse   # Set.Ein.Lieferadress;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end;


  Ein.Anlage.Datum  # today;
  Ein.Anlage.Zeit   # now;
  Ein.Anlage.User   # gUsername;
  Erx # RekInsert(500,0,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(400028,aint(__LINE__),0,0,0);
    RecBufDestroy(v100);
    RekRestore(v400);
    RekRestore(v401);
    RETURN;
  end;

  vPos # 1;

  // alle Positionen kopieren
  vItem # gMarkList->CteRead(_CteFirst);  // erste Element holen
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=401) then begin
      Erx # RecRead(401,0,_RecID, vMID);
      if (Erx<=_rOK) then begin
        RecLink(400,401,3,_recFirsT);   // Kopf holen
        if (Auf.Vorgangstyp=c_Auf) or (Auf.Vorgangstyp=c_Ang) then begin
          if (_AufPos2AngPos(v100, vPos)<>0) then begin
            TRANSBRK;
            RecBufDestroy(v100);
            RekRestore(v400);
            RekRestore(v401);
            Msg(400028,aint(__LINE__),0,0,0);
            RETURN;
          end;
          inc(vPos);
        end;
      end;
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  END;


  // Sonderfunktion:
  RunAFX('Ein.Auf2Anf.RecSave.Post','');


  RecBufDestroy(v100);

  TRANSOFF;

  RekRestore(v400);
  RekRestore(v401);


  Lib_Mark:Reset(401);


  // Erfolg!!!
  Msg(400029,AInt(vNummer),0,0,0);

  RETURN;

end;


//========================================================================
// Anf2Anf
//        kopiert markierte Anfragen in eine neue Anfrage
//========================================================================
sub Anf2Anf();
local begin
  Erx     : int;
  vItem   : int;
  vPos    : int;
  vMFile  : Int;
  vMID    : Int;
  v500    : int;
  v501    : int;
end
begin

  if (Set.Ein.AnfragenYN=false) then RETURN;

  v500 # RekSave(500);
  v501 # RekSave(501);

  vItem # gMarkList->CteRead(_CteFirst);  // erste Element holen

  vPos # 0;
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=501) then begin
      Erx # RecRead(501,0,_RecID, vMID);
      if (Erx<=_rOK) then begin
        RecLink(500,501,3,_recFirsT);   // Kopf holen
        if (Ein.Vorgangstyp=c_Anfrage) then begin
          vPos # vPos + 1;
        end;
      end;
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  END;
  if (vPos=0) then begin
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;

  // Sicherheitsabfrage
  if (Msg(500002,AInt(vPos),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;


  if (Msg(500003,'',_WinIcoInformation,_WinDialogOkCancel,1)<>_WinIdOk) then begin
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;

  RekRestore(v500);
  RekRestore(v501);

  // ggf. mehrere Lieferanten markieren! / übernehmen aus voriger Prozedur
  RecBufClear(100);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant_Anf2Anf');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');  // hier Selektion
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// AusLieferant_Anf2Anf
//        kopiert markierte Anfragepositionen in einen neuen Anfrage
//========================================================================
sub AusLieferant_Anf2Anf();
local begin
  Erx     : int;
  vItem   : int;
  vMFile  : Int;
  vMID    : Int;
  vHdl    : int;
  vPos    : int;
  vNummer : int;
  v100    : int;
  v500    : int;
  v501    : int;
  v500Neu : int;
  v501Alt : int;
end
begin

  if (gSelected=0) then RETURN;

  v500 # RekSave(500);
  v501 # RekSave(501);

  v100 # RecBufCreate(100);
  RecRead(v100,0,_RecId,gSelected);
  gSelected # 0;

  TRANSON;

  vPos # 1;
  vNummer # Lib_Nummern:ReadNummer('Anfrage');
  if (vNummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RecBufDestroy(v100);
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;

  // Kopf anlegen
  RecbufClear(500);
  Ein.Nummer            # vNummer;
  Ein.VorgangsTyp       # c_Anfrage;
  Ein.Datum             # today;
  Ein.Sachbearbeiter    # gUserName;

  Ein.Lieferantennr     # v100->Adr.Lieferantennr;
  Ein.LieferantenSW     # v100->Adr.Stichwort;
  "Ein.Währung"         # v100->"Adr.EK.Währung";
  Ein.Lieferbed         # v100->Adr.EK.Lieferbed;
  Ein.Zahlungsbed       # v100->Adr.EK.ZAhlungsbed;
  Ein.Versandart        # v100->Adr.EK.Versandart;
  Ein.Sprache           # v100->Adr.Sprache;
  Ein.AbmessungsEH      # v100->Adr.AbmessungEH;
  Ein.GewichtsEH        # v100->Adr.GewichtEH;
  "Ein.Steuerschlüssel" # v100->"Adr.Steuerschlüssel";
  if (Set.Ein.Lieferadress=-1) then begin
    Ein.Lieferadresse   # v100->Adr.Nummer;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end
  else begin
    Ein.Lieferadresse   # Set.Ein.Lieferadress;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end;


  Ein.Anlage.Datum  # today;
  Ein.Anlage.Zeit   # now;
  Ein.Anlage.User   # gUsername;
  Erx # RekInsert(500,0,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(500004,aint(__LINE__),0,0,0);
    RecBufDestroy(v100);
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;

  vPos # 1;

  // alle Positionen kopieren
  FOR vItem # gMarkList->CteRead(_CteFirst)         // erste Element holen
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)   // nächstes Element
  WHILE (vItem > 0) do begin                        // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=501) then begin
      Erx # RecRead(501,0,_RecID, vMID);
      if (Erx<=_rOK) then begin

        v500Neu # RekSave(500);
        RecLink(500,501,3,_recFirsT);   // alten Kopf holen
        if (Ein.Vorgangstyp=c_Anfrage) then begin
          RecBufCopy(v500Neu, 500);     // 2023-01-12 AH
          v501Alt # RekSave(501);
          if (CopyBestellung(Ein.P.Nummer, Ein.p.Position)=false) then begin
            TRANSBRK;
            RecBufDestroy(v100);
            RecBufDestroy(v501Alt);
            RecBufDestroy(v500Neu);
            RekRestore(v500);
            RekRestore(v501);
            Msg(500004,aint(__LINE__),0,0,0);
            RETURN;
          end;
          RekRestore(v501Alt);
          RekRestore(v500Neu);
          RecRead(500,1,0);

          v500Neu # RekSave(500);
          // Druck-Aktion anlegen
          RecBufClear(504);
          Ein.A.Aktionstyp    # c_Akt_Anfrage;
          Ein.A.Bemerkung     # c_AktBem_Anfrage+' '+Adr.Stichwort;
          Ein.A.Aktionsnr     # Ein.Nummer;
          Ein.A.Aktionspos    # vPos;
          Ein.A.Aktionsdatum  # Today;
          Ein.A.TerminStart   # Today;
          Ein.A.TerminEnde    # Today;
          Ein.A.Adressnummer  # v100->Adr.Nummer;
          Ein_A_Data:NeuAnlegen();
          RecRead(501,1,_RecLock);
          Ein_Data:Pos_BerechneMarker();
          Ein_Data:PosReplace(_recUnlock,'AUTO');
          REkRestore(v500Neu);

          inc(vPos);
        end
        else begin
          RekRestore(v500Neu);
        end;

      end;
    end;

  END;


  RecBufDestroy(v100);

  TRANSOFF;

  RekRestore(v500);
  RekRestore(v501);

  Lib_Mark:Reset(501);

  // Erfolg!!!
  Msg(500005,AInt(vNummer),0,0,0);

  RETURN;

end;


//========================================================================
// Anf2Best
//        kopiert markierte Anfragen in eine neue Bestellung
//========================================================================
sub Anf2Best();
local begin
  Erx     : int;
  vItem   : int;
  vPos    : int;
  vMFile  : Int;
  vMID    : Int;
  vEinNr  : int;
  vNummer : int;
  v500    : int;
  v501    : int;
  v500Alt : int;
  v501Alt : int;
  vA,vB   : alpha;
  vPreis  : float;
  v504    : int;
end
begin

  if (Set.Ein.AnfragenYN=false) then RETURN;

  v500 # RekSave(500);
  v501 # RekSave(501);

  vItem # gMarkList->CteRead(_CteFirst);  // erste Element holen

  vPos # 0;
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=501) then begin
      Erx # RecRead(501,0,_RecID, vMID);
      if (Erx<=_rOK) then begin
        RecLink(500,501,3,_recFirsT);   // Kopf holen
        if (Ein.Vorgangstyp=c_Anfrage) then begin
          vPos # vPos + 1;
          if (vEinNr=0) then
            vEinNr # Ein.Nummer
          else
            if (vEinNr<>Ein.Nummer) then vEinNr # -1;
        end;
      end;
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  END;

  // Nicht richtig markiert?
  if (vPos=0) then begin
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;

  if (vEinNr=-1) then begin
    Msg(500006,'',0,0,0);
    RETURN;
  end;

  Ein.Nummer # vEinNr;  // Bestellkopf holen
  RecRead(500,1,0);
  Erx # RecLink(100,500,1,_RecFirst);     // Lieferant holen
  if (Adr.SperrLieferantYN) then begin
    Msg(100005,Adr.Stichwort,0,0,0);
    RETURN;
  end;


  // Sicherheitsabfrage
  if (Msg(500007,AInt(vPos),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
    RekRestore(v500);
    RekRestore(v501);
    RETURN;
  end;

  // Wandeln...
  TRANSON;

  vPos # 1;
  vNummer # Lib_Nummern:ReadNummer('Einkauf');
  if (vNummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN;
  end;

  Ein.Nummer # vEinNr;  // Bestellkopf holen
  RecRead(500,1,0);
  v500Alt # RekSave(500);

  // Kopfaufpreise kopieren
  Erx # RecLink(503,500,13,_RecFirst);
  WHILE (Erx=_rOK) do begin
    if (Ein.Z.Position<>0) then begin
      Erx # RecLink(503,500,13,_RecNext);
      CYCLE;
    end;

    Ein.Z.Nummer # vNummer;
    Erx # RekInsert(503,0,'AUTO');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      RecBufDestroy(v500Alt);
      RekRestore(v500);
      RekRestore(v501);
      Msg(500008,aint(__LINE__),0,0,0);
      RETURN;
    end;
    Ein.Z.Nummer # vEinNr;  // Restore
    RecRead(503,1,0);

    Erx # RecLink(503,500,13,_RecNext);
  END;

  // Kopf anlegen
  Ein.Nummer        # vNummer;
  Ein.VorgangsTyp   # c_Bestellung;
  Ein.Datum         # today;
  Ein.Anlage.Datum  # today;
  Ein.Anlage.Zeit   # now;
  Ein.Anlage.User   # gUsername;
  Erx # RekInsert(500,0,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RecBufDestroy(v500Alt);
    RekRestore(v500);
    RekRestore(v501);
    Msg(500008,aint(__LINE__),0,0,0);
    RETURN;
  end;

  // Sonderfunktion:
  RunAFX('Ein.Anf2Best.RecSave.Post','');


  FOR Erx # RecLink(501,v500Alt,9,_recFirst)    // Positionen loopen
  LOOP Erx # RecLink(501,v500Alt,9,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (lib_mark:istmarkiert(501,RecInfo(501,_recId))=false) then CYCLE;

    v501Alt # RekSave(501);

    // Texte ggf. umkopieren
    if (Ein.P.TextNr1=501) then begin // Idividuell
      vA # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3);
      vB # '~501.'+CnvAI(vNummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero| _FmtNumNogroup,0,3);
      TxtCopy(vA,vB,0);
    end;

    // Internen Text umkopieren
    vA # '~e01.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3)+'.01';
    vB # '~e01.'+CnvAI(vNummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero| _FmtNumNogroup,0,3)+'.01';
    TxtCopy(vA,vB,0);

                              // Kalkulation kopieren
    FOR Erx # RecLink(505,501,8,_recFirst)
    LOOP Erx # RecLink(505,501,8,_recFirst)
    WHILE (Erx<=_rLocked) do begin
      Ein.K.Nummer        # vNummer;
      Ein.K.Position      # vPos;
      Ein.K.Anlage.Datum  # today;
      Ein.K.Anlage.Zeit   # now;
      Ein.K.Anlage.User   # gUsername;
      RekDelete(505,0,'MAN');
      Erx # RekInsert(505,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(500008,aint(__LINE__),0,0,0);
        RETURN;
      end;

      Ein.K.Nummer    # Ein.P.Nummer
      Ein.K.Position  # Ein.P.Position;
      RecRead(505,1,0);
    END;

                              // Aufpreise kopieren
    FOR Erx # RecLink(503,501,7,_recFirst)
    LOOP Erx # RecLink(503,501,7,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Ein.Z.Nummer    # vNummer;
      Ein.Z.Position  # vPos;
      Ein.Z.Anlage.Datum  # today;
      Ein.Z.Anlage.Zeit   # now;
      Ein.Z.Anlage.User   # gUsername;
      RekDelete(503,0,'MAN');
      Erx # RekInsert(503,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(500008,aint(__LINE__),0,0,0);
        RETURN;
      end;

      Ein.Z.Nummer    # Ein.P.Nummer
      Ein.Z.Position  # Ein.P.Position;
      RecRead(503,1,0);
    END;
                              // Ausführungen kopieren
    FOR Erx # RecLink(502,501,12,_recFirst)
    LOOP Erx # RecLink(502,501,12,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Ein.AF.Nummer     # vNummer;
      Ein.AF.Position   # vPos;
      RekDelete(502,0,'MAN');
      Erx # RekInsert(502,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(500008,aint(__LINE__),0,0,0);
        RETURN;
      end;

      Ein.AF.Nummer    # Ein.P.Nummer
      Ein.AF.Position  # Ein.P.Position;
      RecRead(502,1,0);
    END;
                              // Aktionen kopieren
    FOR Erx # RecLink(504,501,15,_recFirst)
    LOOP Erx # RecLink(504,501,15,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Ein.A.Nummer    # vNummer;
      Ein.A.Position  # vPos;
      Ein.A.Anlage.Datum  # today;
      Ein.A.Anlage.Zeit   # now;
      Ein.A.Anlage.User   # gUsername;
      RekDelete(504,0,'MAN');
      Erx # RekInsert(504,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(500008,aint(__LINE__),0,0,0);
        RETURN;
      end;

      Ein.A.Nummer    # Ein.P.Nummer
      Ein.A.Position  # Ein.P.Position;
      RecRead(504,1,0);
    END;

    // Kommission ENTFERNEN
    Ein.P.Kommissionnr  # 0;
    Ein.P.Kommissionpos # 0;
    Ein.P.Kommission    # '';
    Ein.P.KommiKunde    # 0;


    // Lohnbestellung?
    Erx # RekLink(835,501,5,_recFirst);         // Auftragsart holen
    if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then begin
      FOR Erx # RecLink(504,501,15,_recFirst)   // Aktionen loopen...
      LOOP Erx # RecLink(504,501,15,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Ein.A.Aktionstyp=c_Akt_BA) and ("Ein.A.Löschmarker"='') then begin
          BAG.P.Nummer    # Ein.A.Aktionsnr;
          BAG.P.Position  # Ein.A.AktionsPos;
          Erx # RecRead(702,1,0);        // BA-Position holen
          if (Erx<=_rLocked) then begin
            if (BA1_P_Lib:StatusInAnfrage()) then begin
              Erx # RecRead(702,1,_recLock);
              BA1_Data:SetStatus(c_BagStatus_Offen);
              RekReplace(702);
            end;

            v504 # RekSave(504);
            RecRead(504,1,_recLock);
            "Ein.A.Löschmarker" # '*';
            RekReplace(504);
            BREAK;
          end;
        end;
      END;
    end;


    // Position anlegen
    Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
    Ein.P.Gesamtpreis   # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);

    Lib_MoreBufs:RecInit(501, y, y);

    Ein.P.Nummer        # vNummer;
    Ein.P.Position      # vPos;

    // Aufpreise refreshen    2023-02-23  AH
    if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
      ApL_Data:AutoGenerieren(501,n ,0, FldDateByName('Ein.P.Cust.PreisZum'))
    else
      ApL_Data:Neuberechnen(501, today);
    Ein_Data:SumAufpreise(c_Modenew);

    // nötige Verbuchungen im Artikel druchführen...
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      // Materialkarten anlegen
      if (Ein_Data:UpdateMaterial(n)=false) then begin
        TRANSBRK;
        if (v504<>0) then RecBufDestroy(v504);
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(501200,gTitle,0,0,0);
        RETURN;
      end;
    end
    else if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin

      // Artikelbestellung anlegen
      if (Ein_Data:UpdateArtikel(0.0)=false) then begin
        TRANSBRK;
        if (v504<>0) then RecBufDestroy(v504);
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(501250,gTitle,0,0,0);
        RETURN;
      end;

      // Preisdatei ggf. anlegen
      RecLink(100,500,1,0);       // Lieferant holen
      if (Art_P_Data:LiesPreis('EK',Adr.Nummer)=false) then begin
        // neu anlegen
        Wae_Umrechnen(Ein.P.Grundpreis,"Ein.Währung",var vPreis, 1);
        Art_P_Data:SetzePreis('EK', vPreis, Adr.Nummer, Ein.P.PEH, Ein.P.MEH.Preis);
      end;
    end;

    Ein.P.Anlage.Datum  # today;
    Ein.P.Anlage.Zeit   # now;
    Ein.P.Anlage.User   # gUsername;
    Erx # Ein_Data:PosInsert(0,'AUTO');
    if (Erx=_rOK) then begin
      Erx # Lib_MoreBufs:SaveAll(501)
    end;
    if (Erx<>_rOk) then begin
      TRANSBRK;
      if (v504<>0) then RecBufDestroy(v504);
      RecBufDestroy(v500Alt);
      RecBufDestroy(v501Alt);
      RekRestore(v500);
      RekRestore(v501);
      Msg(500008,aint(__LINE__),0,0,0);
      RETURN;
    end;


    // Lohnbestellung übernehmen?
    if (v504<>0) then begin
      RekRestore(v504);
/*
      Ein.A.Nummer    # Ein.P.Nummer;
      Ein.A.Position  # Ein.P.Position;
      if (Ein_A_Data:NeuAnlegen()=false) then begin
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(500008,aint(__LINE__),0,0,0);
        RETURN;
      end;
*/
    end;



    // Sonderfunktion:
    if (RunAFX('Ein.Anf2Best.P.RecSave','')<>0) then begin
      if (AfxRes<>_rOk) then begin
        TRANSBRK;
        RecBufDestroy(v500Alt);
        RecBufDestroy(v501Alt);
        RekRestore(v500);
        RekRestore(v501);
        Msg(500008,aint(__LINE__),0,0,0);
        RETURN;
      end;
    end;


    // Aktionen anlegen
    RekRestore(v501Alt);
    RecRead(501,1,0);

    RecBufClear(504);
    Ein.A.Aktionstyp    # c_Akt_Anf2Best;
    Ein.A.Aktionsnr     # vNummer;
    Ein.A.Aktionspos    # vPos;
    Ein.A.Aktionsdatum  # Today;
    Ein.A.TerminStart   # Today;
    Ein.A.TerminEnde    # Today;
    if (Ein_A_Data:NeuAnlegen()=false) then begin
      TRANSBRK;
      RecBufDestroy(v500Alt);
      RekRestore(v500);
      RekRestore(v501);
      Msg(500008,aint(__LINE__),0,0,0);
      ERROROUTPUT;
      RETURN;
    end;
    RecRead(501,1,_RecLock);
    Ein_Data:Pos_BerechneMarker();
    Ein_Data:PosReplace(_recUnlock,'AUTO');

    // Anfrage "löschen"
    if (Ein_P_Subs:ToggleLoeschmarker(n)=false) then begin
      TRANSBRK;
      RecBufDestroy(v500Alt);
      RekRestore(v500);
      RekRestore(v501);
      Msg(500008,aint(__LINE__),0,0,0);
      RETURN;
    end;

    // Markierung entfernen
    Lib_Mark:MarkAdd(501, n,y);

    vPos # vPos + 1;
  END;

  RecBufdestroy(v500);
  RecBufdestroy(v501);
  RecBufDestroy(v500Alt);

  // Kopftexte kopieren
  TxtCopy('~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.K', '~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.K',0);
  TxtCopy('~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.F','~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNogroup,0,8)+'.F',0);

  TRANSOFF;


  Ein.Nummer # vNummer;
  RecRead(500,1,0);
  RecLink(501,500,9,_RecFirst);   // 1.Pos holen

  // KREDITLIMIT
  Ein_Data:SperrPruefung(0);

  // Sonderfunktion:
  RunAFX('Ein.Auf2Anf.RecSave.Post','');

  // Erfolg!!!
  Msg(500009,AInt(vNummer),0,0,0);

end;


//========================================================================
//  DruckBest
//
//========================================================================
sub DruckBest() : logic;
local begin
  Erx     : int;
  vBuf501 : int;
end;
begin
  if (RunAFX('Ein.Druck.Best','')<0) then
    RETURN (AfxRes=_rOK);

  RecLink(500,501,3,_RecFirst);  // Kopf holen
  if (Ein.Freigabe.Datum=0.0.0) then begin
    RETURN false;
  end;

  // 29.01.2020 AH: Prüfe AB-Freigabe
  if ("Set.KLP.Auf-Anlage"='A') then begin
    vBuf501 # RekSave(501);
    FOR Erx # RecLink(501,500,9,_RecFirst)
    LOOP Erx # RecLink(501,500,9,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (Ein.P.KommissionNr=0) then CYCLE;
      Auf.Nummer # Ein.P.KommissionNr;
      Erx # RecRead(400,1,0);   // Auftragskopf holen
      if (Erx<=_rLocked) then begin
        if (Auf.Freigabe.Datum=0.0.0) then begin
          RekRestore(vBuf501);
          Msg(103004,aint(Auf.Nummer),0,0,0);
          RETURN false;
        end;
      end;
    END;
    RekRestore(vBuf501);
  end;
    
    
  vBuf501 # RekSave(501);

  if (Lib_Dokumente:Printform(500,'Bestellung',true)) then begin
    RecLink(100,500,1,_RecFirst);  // Kunde holen
    Erx # RecLink(501,500,9,_RecFirst);  // 1.Position holen
    // Druck-Aktion anlegen
    RecBufClear(504);
    Ein.A.Aktionstyp    # c_Akt_Druck;
    Ein.A.Bemerkung     # c_AktBem_Bestell;
    Ein.A.Aktionsnr     # Ein.Nummer;
    Ein.A.Aktionspos    # 0;
    Ein.A.Aktionsdatum  # Today;
    Ein.A.TerminStart   # Today;
    Ein.A.TerminEnde    # Today;
    Ein.A.Adressnummer  # Adr.Nummer;
    Ein_A_Data:NeuAmKopfAnlegen();
    Ein_Data:BerechneMarker();
  /*        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);*/
  end;

  RekRestore(vBuf501);
end;


//========================================================================
//  DruckAnfrage
//
//========================================================================
sub DruckAnfrage() : logic;
local begin
  Erx     : int;
  vItem   : int;
  vMFile  : Int;
  vMID    : Int;
  vAdr    : int;
  v501    : int;
end;
begin

  // Schnellanfrage?
  v501 # RekSave(501);
  Erx # Msg(500010,'',0,0,2);
  RekRestore(v501);
  if (Erx=_Winidyes) then begin
    RecBufClear(100);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant_DruckAnfrage');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');  // hier Selektion
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  v501 # RekSave(501);
  RecLink(500,501,3,_RecFirst);  // Kopf holen
  RecLink(100,500,1,_RecFirst);  // Lf holen
  Adr.Sprache # Ein.Sprache;
  if (Lib_Dokumente:Printform(500,'Anfrage',true)) then begin
    RecLink(100,500,1,_RecFirst);  // Kunde holen
    Erx # RecLink(501,500,9,_RecFirst);  // 1.Position holen
    // Druck-Aktion anlegen
    RecBufClear(504);
    Ein.A.Aktionstyp    # c_Akt_Druck;
    Ein.A.Bemerkung     # c_AktBem_Anfrage;
    Ein.A.Aktionsnr     # Ein.Nummer;
    Ein.A.Aktionspos    # 0;
    Ein.A.Aktionsdatum  # Today;
    Ein.A.TerminStart   # Today;
    Ein.A.TerminEnde    # Today;
    Ein.A.Adressnummer  # Adr.Nummer;
    Ein_A_Data:NeuAmKopfAnlegen();
    Ein_Data:BerechneMarker();
  /*        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);*/
  end;

  RekRestore(v501);
end;


//========================================================================
// _DruckSchnellanfrage
//========================================================================
Sub _DruckSchnellanfrage(a100 : int);
local begin
  Erx     : int;
  v501  : int;
end;
begin

  v501 # RekSave(501);
  RecLink(500,501,3,_RecFirst);  // Kopf holen

  // Daten temporär ändern
  Ein.Lieferantennr     # a100->Adr.Lieferantennr;
  Ein.LieferantenSW     # a100->Adr.Stichwort;
  //"Ein.Währung"         # a100->"Adr.EK.Währung";
  Ein.Lieferbed         # a100->Adr.EK.Lieferbed;
  Ein.Zahlungsbed       # a100->Adr.EK.ZAhlungsbed;
  Ein.Versandart        # a100->Adr.EK.Versandart;
  Ein.Sprache           # a100->Adr.Sprache;
  //Ein.AbmessungsEH      # a100->Adr.AbmessungEH;
  //Ein.GewichtsEH        # a100->Adr.GewichtEH;
  "Ein.Steuerschlüssel" # a100->"Adr.Steuerschlüssel";
  if (Set.Ein.Lieferadress=-1) then begin
    Ein.Lieferadresse   # a100->Adr.Nummer;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end
  else begin
    Ein.Lieferadresse   # Set.Ein.Lieferadress;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end;

  if (Lib_Dokumente:Printform(500,'Anfrage',true)) then begin
    RekRestore(v501);

    Erx # RecLink(501,500,9,_RecFirst);  // 1.Position holen
    // Druck-Aktion anlegen
    RecBufClear(504);
    Ein.A.Aktionstyp    # c_Akt_Druck;
    Ein.A.Bemerkung     # c_AktBem_Anfrage+' '+a100->Adr.Stichwort;
    Ein.A.Aktionsnr     # Ein.Nummer;
    Ein.A.Aktionspos    # 0;
    Ein.A.Aktionsdatum  # Today;
    Ein.A.TerminStart   # Today;
    Ein.A.TerminEnde    # Today;
    Ein.A.Adressnummer  # Adr.Nummer;
    Ein_A_Data:NeuAmKopfAnlegen();
    Ein_Data:BerechneMarker();
  end
  else begin
    RekRestore(v501);
  end;

end;


//========================================================================
//  AusLieferant_DruckAnfrage
//
//========================================================================
sub AusLieferant_DruckAnfrage();
local begin
  Erx     : int;
  vItem   : int;
  vMFile  : Int;
  vMID    : Int;
  vAnz    : int;
  v501    : int;
  v100    : int;
end;
begin

  if (gSelected=0) then RETURN;

  v501 # RekSave(501);

  RecRead(100,0,_RecId,gSelected);
  gSelected # 0;


  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=100) then begin
      Erx # RecRead(100,0,_RecID, vMID);
      if (Erx<=_rOK) and (Adr.Lieferantennr>0) then begin
        inc(vAnz);
        v100 # RekSave(100);
        _DruckSchnellAnfrage(v100);
        RekRestore(v100);
      end;
    end;
  END;

  if (vAnz=0) then begin
    v100 # RekSave(100);
    _DruckSchnellAnfrage(v100);
    RekRestore(v100);
  end;

  Lib_Mark:Reset(100);

  RekRestore(v501);
end;


//========================================================================
//  _Bag2Anf_Pos
//
//========================================================================
SUB _Bag2Anf_Pos(aPos : int) : int;
local begin
  Erx     : int;
  vI      : int;
  vName   : alpha;
  vName2  : alpha;
end;
begin

  // erstes ordentliches Einsatzmaterial bestimmen...
  FOR Erx # RecLink(701,702,2,_recFirst)  // Input loopen...
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderId=0) then BREAK;
  END;
  if (Erx>_rLocked) then begin
    RETURN -200;
  end;

  RecBufClear(501);
  Ein.P.Nummer          # Ein.Nummer;
  Ein.P.Position        # aPos;

  Ein.P.Lieferantennr   # Ein.Lieferantennr;
  Ein.P.LieferantenSW   # Ein.LieferantenSW;
  Ein.P.Verwiegungsart  # Adr.EK.Verwiegeart;

  Ein.P.Termin1W.Art    # 'DA';
  Ein.P.Termin1Wunsch   # BAG.P.Plan.StartDat;
  Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin1Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin1W.Zahl,var Ein.P.Termin1W.Jahr);
  Ein.P.Termin2Wunsch   # BAG.P.Plan.EndDat;
  Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin2Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin2W.Zahl,var Ein.P.Termin2W.Jahr);

  Ein.P.Bemerkung       # BAG.P.Bemerkung;
  Ein.P.Artikelnr       # BAG.IO.Artikelnr;
  RekLink(250,701,8,_recFirst);             // Artikel holen
  Ein.P.ArtikelSW       # Art.Stichwort;
  Ein.P.Sachnummer      # Art.Sachnummer;

  "Ein.P.Güte"          # "BAG.IO.Güte";
  "Ein.P.Gütenstufe"    # "BAG.IO.Gütenstufe";
  Ein.P.Werkstoffnr     # MQu_data:GetWerkstoffnr("Ein.P.Güte");

/*** ???
  Ein.P.AusfOben        # BAG.IO.AusfOben;
  Ein.P.AusfUnten       # BAG.IO.AusfUnten;
  // Ausführung kopieren
  Erx # RecLink(402,701,11,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Ein.AF.Nummer       # Ein.P.Nummer;
    Ein.AF.Position     # Ein.P.Position;
    Ein.AF.Seite        # Auf.AF.Seite;
    Ein.AF.lfdNr        # Auf.AF.lfdNr;
    Ein.AF.ObfNr        # Auf.AF.ObfNr;
    Ein.AF.Bezeichnung  # Auf.AF.Bezeichnung;
    Ein.AF.Zusatz       # Auf.AF.Zusatz;
    Ein.AF.Bemerkung    # Auf.AF.Bemerkung;
    "Ein.AF.Kürzel"     # "Auf.AF.Kürzel";
    Erx RekInsert(502,_recunlock,'AUTO')
    if (Erx<>_rOK) then RETURN -502;
    Erx # RecLink(402,401,11,_recNext);
  END;
***/

  Erx # RekLink(828,702,8,_recFirst);       // Arbeitsgang holen
  if (Arg.Auftragsart=0) then begin
    RETURN -828;
  end;
  Ein.P.Auftragsart   # Arg.Auftragsart;
  Ein.P.Warengruppe   # BAG.IO.Warengruppe;
  Erx # RecLink(819,501,1,_RecFirst);       // Warengruppe holen
  Ein.P.Wgr.Dateinr     # Wgr.Dateinummer;

//  Ein.P.Strukturnr    # Auf.P.Strukturnr;

  Ein.P.Dicke         # BAG.IO.Dicke;
  Ein.P.DickenTol     # BAG.IO.DickenTol;
  Ein.P.Breite        # BAG.IO.Breite;
  Ein.P.BreitenTol    # BAG.IO.BreitenTol;
  "Ein.P.LängenTol"   # "BAG.IO.LängenTol";
  "Ein.P.Länge"       # "BAG.IO.Länge";
//  Ein.P.RID           # BAG.IO.RID;
//  Ein.P.RIDmax        # BAG.IO.RIDmax;
//  Ein.P.RAD           # BAG.P.RAD;
//  Ein.P.RADmax        # BAG.P.RADmax;

  Ein.P.MEH.Preis       # 'kg';
  Ein.P.PEH             # 1000;
  Ein.P.MEH             # 'kg';
  Ein.P.MEH.Wunsch      # Ein.P.MEH;

  // !!! Mengen werden über UpdateEinAktion der BA-Position gesetzt !!!
  "Ein.P.Stückzahl"   # 0;
  Ein.P.Gewicht       # 0.0;
  Ein.P.Menge.Wunsch  # 0.0;
  Ein.P.Menge         # 0.0;

  Ein.P.TextNr1 # 501;
  Ein.P.TextNr2 # 0;
/***
  // Text kopieren...
  if (Auf.P.TextNr1=0) then begin
    Ein.P.TextNr1 # 0;
    Ein.P.TextNr2 # Auf.P.TextNr2;
  end;
  if (Auf.P.TextNr1=401) then begin
    Ein.P.TextNr1 # 501;
    Ein.P.TextNr2 # 0;
    vName  # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    vName2 # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    TxtCopy(vName, vName2, 0);
  end;
  if (Auf.P.TextNr1=400) then begin
    Ein.P.TextNr1 # 501;
    Ein.P.TextNr2 # 0;
    vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    TxtCopy(vName, vName2, 0);
  end;
***/

  Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
  Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
  if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
  if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
  Ein.P.Gesamtpreis   # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
  Ein.P.Anlage.Datum  # today;
  Ein.P.Anlage.Zeit   # now;
  Ein.P.Anlage.User   # gUsername;
  Ein.P.Aktionsmarker # '!';
  Erx # Ein_data:PosInsert(_recunlock,'AUTO');
  if (Erx<>_rOK) then RETURN -1;


  // Auftragsaktion anlegen...
  RecBufClear(504);
  Ein.A.Aktionstyp    # c_Akt_BA;
  Ein.A.Bemerkung     # BAG.P.Bezeichnung;
  Ein.A.Aktionsnr     # BAG.P.Nummer;
  Ein.A.Aktionspos    # BAG.P.Position;
  Ein.A.Aktionsdatum  # Today;
  Ein.A.TerminStart   # Today;
  Ein.A.TerminEnde    # Today;
  if (Ein_A_Data:NeuAnlegen()=false) then begin
    RETURN -504;
  end;

  BA1_P_Data:UpdateEinAktion(false);

  RETURN 0;
end;


//========================================================================
//  Bag2Anf
//      kpierten die aktuelle BA-Position in ein Bestell-Anfrage
//========================================================================
SUB Bag2Anf(aDirektBestellen : logic) : logic;
local begin
  Erx     : int;
  vNummer : int;
  vPos    : int;
  vAnz    : int;
  vLF     : int;
end
begin

  // PRÜFUNGEN --------------------------------------------------------------
  FOR Erx # Reklink(702,700,1,_recFirst)    // BA-Positionen loopen...
  LOOP Erx # Reklink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Mark:IstMarkiert(702,RecInfo(702,_recID))=false) then CYCLE;

    if (vLF=0) then vLF # BAG.P.ExterneLiefNr;
    if (vLF<>BAG.P.ExterneLiefNr) then begin
      Msg(702505,'',0,0,0);
      RETURN false;
    end;

    if (BA1_P_Lib:StatusInAnfrage()=false) then begin
      Msg(702501,c_BagStatus_Anfrage,0,0,0);
      RETURN false;
    end;

    Erx # RekLink(828,702,8,_recFirst);       // Arbeitsgang holen
    if (Arg.Auftragsart=0) then begin
      Msg(828001,BAG.P.Aktion2,0,0,0);
      RETURN false;
    end;


    // erstes ordentliches Einsatzmaterial bestimmen...
    FOR Erx # RecLink(701,702,2,_recFirst)  // Input loopen...
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.BruderId=0) then BREAK;
    END;
    if (Erx>_rLocked) then begin
      Msg(702502,aint(BAG.P.Position),0,0,0);
      RETURN false;
    end;

    // Bestellaktion suchen...
    RecBufClear(504);
    Ein.A.Aktionsnr   # BAG.P.Nummer;
    Ein.A.Aktionspos  # BAG.P.Position;
    Ein.A.Aktionstyp  # c_Akt_BA;
    FOR Erx # RecRead(504,2,0)   // Bestellaktion loopen...
    LOOP Erx # RecRead(504,2,_recNext)
    WHILE (Erx<=_rMultikey) and
      (Ein.A.Aktionsnr=BAG.P.Nummer) and
      (Ein.A.Aktionspos=BAG.P.Position) and
      (Ein.A.Aktionstyp=c_Akt_BA) do begin

      if ("Ein.A.Löschmarker"<>'') then CYCLE;

      Msg(702503,aint(BAG.P.Position),0,0,0);
      RETURN false;
    end;

    inc(vAnz);
  END;

  if (vAnz=0) then RETURN false;

  if (aDirektBestellen) then begin
    if (Msg(702506,aint(vAnz),_WinIcoQuestion,_WinDialogYesNo,_WinIdNo)<>_WinIdYes) then RETURN false;
  end
  else begin
    if (Msg(702504,aint(vAnz),_WinIcoQuestion,_WinDialogYesNo,_WinIdNo)<>_WinIdYes) then RETURN false;
  end;

  TRANSON;

  if (aDirektBestellen) then
    vNummer # Lib_Nummern:ReadNummer('Einkauf')
  else
    vNummer # Lib_Nummern:ReadNummer('Anfrage');
  if (vNummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN false;
  end;

  // Kopf anlegen
  RecbufClear(500);
  Ein.Nummer            # vNummer;
  if (aDirektBestellen) then
    Ein.VorgangsTyp       # c_Bestellung
  else
    Ein.VorgangsTyp       # c_Anfrage;
  Ein.Datum             # today;
  Ein.Sachbearbeiter    # gUserName;


  Ein.Lieferantennr     # vLF;
  Erx # RekLink(100,500,1,_RecFirst);       // Lieferant holen
  Ein.LieferantenSW     # Adr.Stichwort;
  Ein.Lieferadresse     # Adr.Nummer;
  Ein.Lieferanschrift   # Set.Ein.Lieferanschr;

  "Ein.Währung"         # "Adr.EK.Währung";
  Ein.Lieferbed         # Adr.EK.Lieferbed;
  Ein.Zahlungsbed       # Adr.EK.ZAhlungsbed;
  Ein.Versandart        # Adr.EK.Versandart;
  Ein.Sprache           # Adr.Sprache;
  Ein.AbmessungsEH      # Adr.AbmessungEH;
  Ein.GewichtsEH        # Adr.GewichtEH;
  "Ein.Steuerschlüssel" # "Adr.Steuerschlüssel";


  Ein.Anlage.Datum  # today;
  Ein.Anlage.Zeit   # now;
  Ein.Anlage.User   # gUsername;
  Erx # RekInsert(500,0,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RETURN false;
  end;


  vPos # 1;

  // alle markierten Positionen kopieren
  FOR Erx # Reklink(702,700,1,_recFirst)
  LOOP Erx # Reklink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BA1_P_Lib:StatusInAnfrage()=false) then CYCLE;
    if (Lib_Mark:IstMarkiert(702,RecInfo(702,_recID))=false) then CYCLE;

    Erx # _Bag2Anf_Pos(vPos);
    if (Erx<>0) then begin
      TRANSBRK;
      Msg(400028,aint(__LINE__),0,0,0);
      RETURN false;
    end;

    if (aDirektBestellen) then begin
      Erx # RecRead(702,1,_recLock);
      BA1_Data:SetStatus(c_BagStatus_Offen);
      RekReplace(702);
    end;

    inc(vPos);
  END;

  // Sonderfunktion:
//  RunAFX('Ein.Bag2Anf.RecSave.Post','');

  TRANSOFF;

  Lib_Mark:Reset(702);


  Msg(999998,'',0,0,0);

  RETURN true;
end;


//========================================================================
//  ChangeLieferantenArtnr
//
//========================================================================
sub ChangeLieferantenArtnr();
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vA    : alpha;
end;
begin

  // bisher NICHT bei Artikel!
  if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMixArt(Ein.P.Wgr.Dateinr)) then RETURN;

  if (Msg(401024,'',_WinIcoQuestion, _WinDialogYesNo, 2)=_WinIdNo) then begin
    if (Dlg_Standard:Standard(Translate('Lieferantenartikelnr.'),var vA, n, 40)=false) then RETURN;
    TRANSON;
    if (Ein_Data:SetLieferantenMatArtNr(0,0,n,vA)=false) then begin
      TRANSBRK;
      ERROROUTPUT;
      RETURN;
    end;
    TRANSOFF;
    gMdi->WinUpdate();
    RETURN;
  end;


  Erx # RecLink(100,500,1,_RecFirst);         // Lieferant holen
  if (Erx<>_rOK) then RecBufClear(100);
  RecBufClear(105);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusChangeLieferantenMatArtNr');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ # '';
  if ("Set.Auf.!EigeneVPG") then begin
    Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
  end
  else begin
    Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
    Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Set.eigeneAdressnr, 'OR');
  end;
  vQ # 'Adr.V.EinkaufYN AND ('+vQ+')';
  Lib_Sel:QRecList(0, vQ);
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusChangeLieferantenMatArtNr
//
//========================================================================
sub AusChangeLieferantenMatArtNr()
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
    if (Ein_Data:SetLieferantenMatArtNr(Adr.V.Adressnr, Adr.V.Lfdnr, vHdl=_Winidyes,'')=false) then begin
      ERROROUTPUT;
      RETURN;
    end;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);

  gMdi->WinUpdate();

  Msg(999998,'',0,0,0);
end;


//========================================================================