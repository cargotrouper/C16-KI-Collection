@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_SL_Data
//                  OHNE E_R_G
//  Info
//
//
//  15.12.2004  AI  Erstellung der Prozedur
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB ProjektSLImport(aPrj : int) : logic;
//    SUB Reservieren(aDel : logic);
//    SUB BAGProduziere; localbeginvMenge : float; vOk : logic; vNr : int; vCharge : alpha; vText : alpha; vMaxMenge : float; end; beginErg#RecLink(250,401,2,_recFirst);
//    SUB BAGResAbschluss() : logic;
//    SUB BAGSchrottAbschluss() : logic;
//    SUB BAGAbschluss();
//    SUB BAGAbschluss_allePos();
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG


//========================================================================
//  ProjektSLImport
//
//========================================================================
sub ProjektSLImport(aPrj : int) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vFirst  : int;
  vLast   : int;
  vMenge  : float;
  vTree   : int;
  vItem   : int;
  vDat    : date;
end;
begin

  TRANSON;

  Prj.Nummer # aPrj;
  RecRead(120,1,0);                     // Projekt holen


  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  Erx # RecLink(121,120,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(250,121,2,_recFirst); // Artikel holen
    if (Erx>_rLocked) then RecBufClear(250);
    Sort_ItemAdd(vTree, cnvaf(100000000.0-Art.Dicke,_fmtNumNogroup,0,2,15), 121, RecInfo(121,_RecId));
    Erx # RecLink(121,120,2,_recNext);
  END;



  vItem # Sort_ItemFirst(vTree);        // Projekt-SL loopen
  WHILE (vItem>0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);


    Erx # RecLink(401,400,9,_recFirst);   // erste Auf.Positionen holen
    if (Erx<=_rLocked) then vDat # Auf.P.Termin1Wunsch;

    vOK # n;
    Erx # RecLink(401,400,9,_recFirst);   // Auf.Positionen loopen
    WHILE (Erx<=_rLocked) and (vOK=n) do begin
      if (Auf.P.ArtikelNr=Prj.SL.ArtikelNr) and (Auf.P.Projektnummer=Prj.Nummer) then begin  // gibts diesen Artikel schon??
        vOK # y;
        BREAK;
      end;
      Erx # RecLink(401,400,9,_recNext);
    END;


    // neue Auf.Position anlegen
    if (vOK=n) then begin
      RecLink(250,121,2,_recFirst);   // Artikel holen
      RecBufClear(401);
      Auf.P.Kundennr      # Auf.Kundennr;
      Auf.P.KundenSW      # Auf.KundenStichwort;
      Auf.P.MEH.Preis     # Set.Auf.MEH.PEH;
      Auf.P.PEH           # Set.Auf.PEH;
      Auf.P.MEH.Wunsch    # Auf.P.MEH.Preis;
      Auf.P.Warengruppe   # Art.Warengruppe;
      Auf.P.Termin1Wunsch # vDat;
      RecLink(819,401,1,_RecFirst);   // Warengruppe holen
      Auf.P.Wgr.Dateinr   # Wgr.Dateinummer;
      if ("Art.ChargenführungYN") then Auf.P.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Auf.P.Wgr.Dateinr);
      Auf.P.ArtikelTyp    # Art.Typ;

      Auf.P.Auftragsart   # Set.Auf.Auftragsart;
      Auf.P.Termin1W.Art  # Set.Auf.TerminArt;
      Auf.P.Best.Nummer   # Auf.Best.Nummer;
      Auf.P.Nummer        # Auf.Nummer;
      Auf.P.Projektnummer # Prj.Nummer;

      Auf.P.ArtikelNr     # Prj.SL.Artikelnr;
//      Auf.P.Bemerkung     # Prj.SL.Bemerkung;
      Auf.P.ArtikelSW     # Art.Stichwort;
      Auf.P.Sachnummer    # Art.Sachnummer;
      Auf.P.Menge.Wunsch  # 0.0;
      Auf.P.MEH.Einsatz   # Art.MEH;
      Auf.P.MEH.Wunsch    # Art.MEH;
      Auf.P.Menge         # 0.0;
      Auf.P.PEH           # Art.PEH;
      Auf.P.MEH.Preis     # Art.MEH;

      RecLink(100,400,1,_RecFirst);             // Kunde holen
      if (Art_P_Data:FindePreis('VK', Adr.Nummer, 1.0, '', 1)) then begin
        Auf.P.MEH.Preis      # Art.P.MEH;
        Auf.P.PEH            # Art.P.PEH;
        Auf.P.Grundpreis     # Art.P.PreisW1;
      end;


      Auf.P.Position      # 0;
      REPEAT
        Auf.P.Position      # Auf.P.Position + 1;
        Auf.P.Best.Nummer   # cnvai(Auf.P.Position,_FmtNumLeadZero,0,2);
        Erx # Auf_Data:PosInsert(0,'AUTO');
      UNTIL (Erx=_rOK);
      if (vFirst=0) then vFirst # Auf.P.Position;
      if (vLast<Auf.P.Position) then vLast # Auf.P.Position;
    end;



    // Auf.Pos.SL anhängen

    RecBufClear(409);
    Auf.SL.Nummer         # Auf.P.Nummer;
    Auf.SL.Position       # Auf.P.Position;
    Auf.SL.ArtikelNr      # Prj.SL.Artikelnr;
    Auf.SL.Bemerkung      # Prj.SL.Bemerkung;
    "Auf.SL.Stückzahl"    # "Prj.SL.Stückzahl";
    Auf.SL.Dicke          # Prj.SL.Dicke;
    Auf.SL.Breite         # Prj.SL.Breite;
    "Auf.SL.Länge"        # "Prj.SL.Länge";
    Auf.SL.Gewicht        # Prj.SL.Gewicht;
    Auf.SL.MEH            # Auf.P.MEH.Einsatz;
    if (Auf.P.MEH.Einsatz='qm') then begin
      Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge"*Auf.SL.Breite / 1000000.0;
      end
    else
    if (Auf.P.MEH.Einsatz='mm') then begin
      Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge";
      end
    else
    if (Auf.P.MEH.Einsatz='m') then begin
      Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge" / 1000.0;
    end;
    if (Auf.P.MEH.Einsatz='kg') then begin
      Auf.SL.Menge # Auf.SL.Gewicht;
    end;

//    Auf.SL.Rest.Menge   # Auf.SL.Menge;
//    "Auf.SL.Rest.Stück" # "Auf.SL.Stückzahl";
//    Auf.SL.Rest.Gewicht # Auf.SL.Gewicht;
    if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then
      Art_P_Data:FindePreis('EK', 0, 0.0, '', 1);
    Auf.SL.MEH.EK         # Art.P.MEH;
    Auf.SL.PEH.EK         # Art.P.PEH;
    Auf.SL.PreisW1.EK     # Art.P.PreisW1;
    vMenge # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.P.MEH.Wunsch, Auf.SL.MEH.EK)
    Auf.SL.Gesamtwert.EK # 0.0;
    if (Auf.SL.PEH.EK<>0) then
      Auf.SL.Gesamtwert.EK # vMenge * Auf.SL.PreisW1.EK / cnvfi(Auf.SL.PEH.EK);

    Auf.SL.lfdNr # 1;
    WHILE (RecRead(409,1,_RecTest)<=_rLocked) do
      Auf.SL.lfdNr # Auf.SL.lfdNR + 1;

    Auf.SL.Anlage.Datum  # Today;
    Auf.Sl.Anlage.Zeit   # Now;
    Auf.SL.Anlage.User   # gUserName;

    Erx # RekInsert(409,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      RETURN false;
    end;


    // Auf.Position updaten
    RecRead(401,1,_recLock);
    Auf.P.Menge.Wunsch  # Auf.P.Menge.Wunsch + Auf.SL.Menge;
    if (Auf.P.MEH.Wunsch='kg') then
      Auf.P.Menge.Wunsch # Rnd(Auf.P.Menge.Wunsch,0);
    "Auf.P.Stückzahl"   # "Auf.P.Stückzahl" + "Auf.SL.Stückzahl";
    Auf.P.Gewicht       # Rnd(Auf.P.Gewicht + Auf.SL.Gewicht,0);
    if (Auf.P.MEH.Wunsch=Auf.P.MEH.Einsatz) then begin
      Auf.P.Menge       # Auf.P.Menge.Wunsch;
    end;

    Auf.P.Prd.Rest      # Auf.P.Menge - Auf.P.Prd.LFS;
    Auf.P.Prd.Rest.Stk  # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
    Auf.P.Prd.Rest.Gew  # Auf.P.Gewicht - Auf.P.Prd.LFS.Gew;
    if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin
      if (Auf.P.Prd.Rest>0.0) then Auf.P.Prd.Rest # 0.0;
      if (Auf.P.Prd.Rest.Stk>0) then Auf.P.Prd.Rest.Stk # 0;
      if (Auf.P.Prd.Rest.Gew>0.0) then Auf.P.Prd.Rest.Gew # 0.0;
      end
    else begin
      if (Auf.P.Prd.Rest<0.0) then Auf.P.Prd.Rest # 0.0;
      if (Auf.P.Prd.Rest.Stk<0) then Auf.P.Prd.Rest.Stk # 0;
      if (Auf.P.Prd.Rest.Gew<0.0) then Auf.P.Prd.Rest.Gew # 0.0;
    end;

    Auf.P.GesamtwertEKW1 # Auf.P.GesamtwertEKW1 + Auf.SL.Gesamtwert.EK;

    Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);

    Auf_Data:PosReplace(_recUnlock,'AUTO');


    vItem->CteClose();
    vItem # Sort_ItemFirst(vTree);
  END;


  // Löschen der Liste
  Sort_KillList(vTree);


  // letzte Position mit Text versehen
  RecBufClear(401);
  Auf.P.Nummer    # Auf.Nummer;
  Auf.P.Position  # vLast;
  RecRead(401,1,_recLock);
  Auf.P.Bemerkung # 'Pos. '+AInt(vFirst)+' bis '+AInt(vLast)+' laut Stückliste '+AInt(Prj.nummer);
  Auf_Data:PosReplace(_recUnlock,'AUTO');

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  Reservieren
//
//========================================================================
sub Reservieren(aDel : logic);
local begin
  Erx : int;
end;
begin

  if (Auf.SL.Nummer<1000000000) and (Auf.SL.ArtikelNr<>'') and (Auf.Vorgangstyp=c_AUF) then begin
    Erx # RecLink(250,409,3,_RecFirst);   // SL-Artikel holen
    if (Erx>_rLocked) then RETURN;

    Erx # RecLink(819,250,10,_RecFirst);  // WGr holen

    Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
    if (Erx>_rLocked) then RecBufClear(835);

    if (AAr.ReserviereSLYN) then begin

      // sofort MATZ/Reservierungen anlegen
      //if ("Art.ChargenführungYN"=n) and
        //((Art.Typ=c_art_HDL) or (Art.Typ=c_art_CUT)) and

      // mehre Chargen vorhanden?
//1910      if (RecLinkInfo(252,250,4,_recCount)=1) and
//        (Wgr.Dateinummer<>c_WGR_ArtMatMix) then
//        Auf_Data_Buchen:MatzArt(Art.Nummer, 0,0,'',n,y,Auf.SL.Menge - Auf.SL.Prd.VSB - Auf.SL.Prd.VSAuf - Auf.SL.Prd.LFS);


      if ("Art.ChargenführungYN"=n) and (Wgr_data:IstMix()) then begin
        if (aDel=n) then begin
          RecBufClear(252);
          Art.C.ArtikelNr     # Auf.SL.ArtikelNr;
          Art.C.Dicke         # Auf.SL.Dicke;
          Art.C.Breite        # Auf.SL.Breite;
          "Art.C.Länge"       # "Auf.SL.Länge";
          Art_Data:Auftrag(Auf.SL.Menge - Auf.SL.Prd.VSAuf - Auf.SL.Prd.Plan - Auf.SL.Prd.VSB - Auf.SL.Prd.LFS);
        end
        else begin
          RecBufClear(252);
          Art.C.ArtikelNr     # Auf.SL.ArtikelNr;
          Art.C.Dicke         # Auf.SL.Dicke;
          Art.C.Breite        # Auf.SL.Breite;
          "Art.C.Länge"       # "Auf.SL.Länge";
          Art_Data:Auftrag(-1.0 * (Auf.SL.Menge - Auf.SL.Prd.VSAuf - Auf.SL.Prd.Plan - Auf.SL.Prd.VSB - Auf.SL.Prd.LFS));
        end;
      end;

    end;

  end;

end;


//========================================================================
// BAGProduziere
//          verbraucht alle zugewiesenen Artikel und erzeugt Hauptartikel
//========================================================================
sub BAGProduziere;
local begin
  vMenge    : float;
  vOk       : logic;
  vNr       : int;
  vCharge   : alpha;
  vText     : alpha;
  vMaxMenge : float;
end;
begin
TODO('simple PRD');
RETURN
/******
  Erx # RecLink(250,401,2,_recFirst); // Positionsartikel holen
  if (Erx>=_rLocked) or (Art.Typ<>c_Art_PRD) then RETURN;

  if (Msg(409702,Auf.P.Artikelnr,_WinIcoQuestion,_WinDialogYesNo,1)<>_WinIdYes) then RETURN;

  vMaxMenge # Auf.P.Menge;
  vText # 'AUF '+Cnvai(Auf.P.Nummer,_FmtNumNoGroup)+'/'+Cnvai(Auf.P.Position,_FmtNumNoGroup);

  REPEAT
    if (Dlg_Standard:Menge(Translate('zu produzierende Menge ['+Art.MEH+']'), var vMenge, 0.0)<>true) then RETURN;
  UNTIl (vMenge>=0.0);

  TRANSON;

  // bisherige Materialzuordnungen "verbrauchen"
  // Aktionsliste loopen
  Erx # RecLink(404,401,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.A.Löschmarker"<>'') or (Auf.A.Aktionstyp<>c_Akt_VSB) or
      (Auf.A.Position2=0) then begin
      Erx # RecLink(404,401,12,_recNext);
      CYCLE;
    end;


    // Stückliste anpassen
    Erx # RecLink(409,404,5,_recFirst);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(409705,'274',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;

    // MATZ wird zu VERBRAUCH
    Auf_A_Data:Entfernen();
    "Auf.A.Aktionstyp"  # c_Akt_PRD_Verbrauch;
    Auf.A.Bemerkung     # c_AktBem_Prd_Verbrauch;
    ERx # Auf_A_Data:NeuAnlegen(n,y);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(409705,'266',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;

    // Stückliste anpassen
//debug('aaa:'+auf.A.artikelnr+ ' :'+cnvai(auf.a.position2));
    Erx # RecLink(409,404,5,_recFirst);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(409705,'274',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;
/***
    RecRead(409,1,_recLock);
    Auf.SL.Prd.VSB      # Auf.SL.Prd.VSB      - Auf.A.Menge;
    Auf.SL.Prd.VSB.Stk  # Auf.SL.Prd.VSB.Stk  - "Auf.A.Stückzahl";
    Auf.SL.Prd.VSB.Gew  # Auf.SL.Prd.VSB.Gew  - Auf.A.Gewicht;
debug('+lfs:'+auf.sl.artikelnr+ ' :'+cnvaf(auf.a.Menge));
    Auf.SL.Prd.LFS      # Auf.SL.Prd.LFS      + Auf.A.Menge;
    Auf.SL.Prd.LFS.Stk  # Auf.SL.Prd.LFS.Stk  + "Auf.A.Stückzahl";
    Auf.SL.Prd.LFS.Gew  # Auf.SL.Prd.LFS.Gew  + Auf.A.Gewicht;
    ERx # RekReplace(409,_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(409705,'287',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;
***/

    RecLink(250,404,3,_RecFirst);         // Artikel holen
    // Reservierung entfernen
    RecBufClear(252);
    Art.C.ArtikelNr     # Auf.A.ArtikelNr;
    Art.C.Adressnr      # Auf.A.Charge.Adresse;
    Art.C.Anschriftnr   # Auf.A.Charge.Anschr;
    Art.C.Charge.Intern # Auf.A.Charge;
    vOk # Art_Data:Reservierung((-1.0) * Auf.A.Menge, 'AUF', n);
    if (vOK=false) then begin
      TRANSBRK;
      Msg(409705,'302',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;


    // Abgang buchen
    RecBufClear(252);
    Art.C.ArtikelNr     # Auf.A.ArtikelNr;
    Art.C.Adressnr      # Auf.A.Charge.Adresse;
    Art.C.Anschriftnr   # Auf.A.Charge.Anschr;
    Art.C.Charge.Intern # Auf.A.Charge;
    vOK # Art_Data:Bewegung(
        (-1.0) * Auf.A.Menge,
        Translate('Auftragsprod.')+' '+CnvAI(Auf.P.Nummer,_FmtNumNoGroup)+'/'+CnvAI(Auf.P.Position),
        0.0, 0.0, today);
    if (vOK=false) then begin
      TRANSBRK;
      Msg(409703,Auf.A.ArtikelNr+' '+Auf.A.Charge,_WinIcoError,_WinDialogOk,0);
      Msg(409705,'',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;


    Erx # RecLink(404,401,12,_recFirst);
//    Erx # RecLink(404,401,12,_recNext);
  END;



  Erx # RecLink(100,401,4,_recFirst); // Kunde holen
  Erx # RecLink(250,401,2,_recFirst); // Positionsartikel holen

  // Zugang buchen
  RecBufClear(252);
  Art.C.ArtikelNr     # Auf.P.ArtikelNr;
  Art.C.Adressnr      # 0;
  Art.C.Anschriftnr   # 0;
  vCharge # '';
  if ("Art.ChargenführungYN") then begin
    vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      Msg(409704,Auf.P.ArtikelNr,_WinIcoError,_WinDialogOk,0);
      Msg(409705,'',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;
    vCharge # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  end;
  Art.C.Charge.Intern # vCharge;

  vOK # Art_Data:Bewegung(vMenge,
      Translate('Auftragsprod.')+' '+CnvAI(Auf.P.Nummer,_FmtNumNoGroup)+'/'+CnvAI(Auf.P.Position),
      0.0, 0.0, today);
  if (vOK=false) then begin
    TRANSBRK;
    Msg(409704,Auf.P.ArtikelNr,_WinIcoError,_WinDialogOk,0);
    Msg(409705,'',_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;

  if (vCharge<>'') then begin
    RecBufClear(252);
    Art.C.ArtikelNr     # Auf.P.ArtikelNr;
    Art.C.Adressnr      # 0;
    Art.C.Anschriftnr   # 0;
    Art.C.Charge.intern # vCharge;
    RecRead(252,1,_recLock);
    Art.C.Kommission      # '';
    Art.C.Auftragsnr      # Auf.A.Nummer;
    Art.C.Auftragspos     # Auf.A.Position;
    Art.C.AuftragsFertig  # 0;
    if (Art_Data:WriteCharge(n,'AUTO')<>_rOK) then begin
      TRANSBRK;
      Msg(409705,'375',_WinIcoError,_WinDialogOk,0);
      RETURN;
    end;
  end;

  // MATZ Aktion anlegen
  RecbufClear(404);
  Auf.A.ArtikelNr     # Art.Nummer;
  Auf.A.Aktionsnr     # Auf.P.Nummer;
  Auf.A.AktionsPos    # Auf.P.Position;
  Auf.A.AktionsPos2   # 0;
  Aufx.A.Adressnummer  # Adr.Nummer;
  if (StrCnv(Art.MEH,_StrUppeR)='STK') then
    "Auf.A.Stückzahl"   # CnvIF(vMenge);
  Auf.A.Dicke         # Art.Dicke;
  Auf.A.Breite        # Art.Breite;
  "Auf.A.Länge"       # "Art.Länge";
  Auf.A.Menge         # vMenge;
  Auf.A.MEH           # Art.MEH;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;

  Auf.A.ArtikelNr     # Auf.P.Artikelnr;
  Auf.A.Charge        # vCharge;

  Auf.A.Gewicht       # 0.0;
  Auf.A.Gewicht       # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", 0.0, Auf.A.Menge, Auf.A.MEH, 'kg');
  // Umrechnen in Berechnungseinheit
  Auf.A.Menge.Preis   # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, vMenge, Auf.A.MEH, Auf.A.MEH.Preis);

  Auf.A.AktionsTyp    # c_Akt_VSB;
  Auf.A.Bemerkung     # c_AktBem_VSB;
  Auf.A.AktionsDatum  # today;
  if (Auf_A_Data:NeuAnlegen(n,n)=false) then begin
    TRANSBRK;
    Msg(409705,'405',_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;

  // Artikel reservieren
  RecBufClear(252);
  Art.C.ArtikelNr     # Auf.P.ArtikelNr;
  Art_Data:Reservierung(vMenge,vText);

  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);

  if (AAr.ReserviereSLYN) then begin
    if (vMenge>vMaxMenge) then begin
      Art_Data:Auftrag(-1.0 * vMaxMenge);
      end
    else begin
      Art_Data:Auftrag(-1.0 * vMenge);
    end;
  end;

  TRANSOFF;


  Msg(409706,Auf.A.ArtikelNr,_WinIcoInformation,_WinDialogOk,0);
****/
end;


//========================================================================
// BAGResAbschluss
//          schliesst eine theoretische Reservierung ab
//========================================================================
sub BAGResAbschluss() : logic;
local begin
  Erx   : int;
  vOK   : logic;
  vAnz  : int;
  vNr   : int;
  vChargeNeu : alpha;
  vChargeAlt : alpha;
end;
begin

  Erx # RecLink(409,404,5,_RecFirst);   // Stückliste holen
  if (Erx<>_rOK) then RETURN false;

  Erx # RecLink(252,404,4,_RecFirst);   // Charge holen
  if (Erx<>_rOK) then RETURN false;

  Erx # RecLink(250,252,1,_RecFirst);   // Artikel holen
  if (Erx<>_rOK) then RETURN false;

  vAnz # "Auf.A.Stückzahl" / Art.C.Bestand.Stk;   // Stück pro Einzelteil
  vChargeAlt # Art.C.Charge.Intern;

  // alte Charge reduzieren
  RecRead(252,1,_recLock);
  if ("Art.C.Länge"<>0.0) then
    "Art.C.Länge" # "Art.C.Länge" - ("Auf.SL.Länge" * cnvfi(vAnz));
  Art.C.Bestand     # Art.C.Bestand - Auf.A.Menge;
  Art.C.Reserviert  # Art.C.Reserviert - Auf.A.Menge;
  if (Art.C.Bestand=0.0) and (Art.C.Bestellt=0.0) and (Art.C.Reserviert=0.0) then begin
    RecRead(252,1,_RecUnlock);
    RekDelete(252,0,'');          // Charge löschen
    end
  else begin
    if (Art_Data:WriteCharge(n,'AUTO')<>_rOK) then RETURN false;
  end;


/****
  vOK # Art_Data:Bewegung(
      (-1.0) * Auf.A.Menge,
      Translate('Auftragsprod.')+' '+CnvAI(Auf.A.Nummer,_FmtNumNoGroup)+'/'+CnvAI(Auf.A.Position)+'/'+CnvAI(Auf.A.Position2),
      0.0, 0.0, today);
  if (vOK=false) then RETURN false;
****/

  // neue Charge generieren
  vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else RETURN false;
  vChargeNeu # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  Art.C.Charge.Intern # vChargeNeu;
  Art.C.Dicke         # Auf.SL.Dicke;
  Art.C.Breite        # Auf.SL.Breite;
  "Art.C.Länge"       # "Auf.SL.Länge";
  Art.C.Bestand       # Auf.A.Menge;
  Art.C.Reserviert    # 0.0;
  Art.C.Bestellt      # 0.0;
  Art.C.Kommission    # '';
  Art.C.Bestand.Stk   # "Auf.A.Stückzahl";;
  Art.C.Auftragsnr    # Auf.A.Nummer;
  Art.C.Auftragspos   # Auf.A.Position;
  Art.C.AuftragsFertig  # Auf.SL.lfdNr;
  if (Art_Data:WriteCharge(y,'AUTO')<>_rOK) then RETURN false;
/***
  vOK # Art_Data:Bewegung(
      Auf.A.Menge,
      Translate('Auftragsprod.')+' '+CnvAI(Auf.A.Nummer,_FmtNumNoGroup)+'/'+CnvAI(Auf.A.Position)+'/'+CnvAI(Auf.A.Position2),
      0.0, 0.0, today);
  if (vOK=false) then RETURN false;
***/

  // Auf.Aktion anpassen
  RecRead(404,1,_recLock);
  Auf.A.Charge      # vChargeNeu;
  Auf.A.AktionsTyp  # c_Akt_VSB;
  Auf.A.Bemerkung   # c_AktBem_VSB;
  Erx # RekReplace(404,_recUnlock,'AUTO');
  if (Erx<>_rOK) then RETURN false;

  // SL anpassen
  RecRead(409,1,_recLock);
  Auf.SL.Prd.Plan      # Auf.SL.Prd.Plan - Auf.A.Menge;
  Auf.SL.Prd.Plan.Stk  # Auf.SL.Prd.Plan.Stk - "Auf.A.Stückzahl";
  Auf.Sl.Prd.Plan.Gew  # Auf.SL.Prd.Plan.Gew - Auf.A.Gewicht;
  Auf.SL.Prd.VSB       # Auf.SL.Prd.VSB + Auf.A.Menge;
  Auf.SL.Prd.VSB.Stk   # Auf.SL.Prd.VSB.Stk + "Auf.A.Stückzahl";
  Auf.SL.Prd.VSB.Gew   # Auf.SL.Prd.VSB.Gew + Auf.A.Gewicht;
  Erx # RekReplace(409,_recUnlock,'AUTO');
  if (Erx<>_rOK) then RETURN false;

  // Auftrag ggf. anpassen
  if (Auf.P.ArtikelTyp=c_Art_CUT) then begin
    RecRead(401,1,_recLock);
    Auf.P.Prd.Plan      # Auf.P.Prd.Plan - Auf.A.Menge;
    Auf.P.Prd.Plan.Stk  # Auf.P.Prd.Plan.Stk - "Auf.A.Stückzahl";
    Auf.P.Prd.Plan.Gew  # Auf.P.Prd.Plan.Gew - Auf.A.Gewicht;
    Auf.P.Prd.VSB       # Auf.P.Prd.VSB + Auf.A.Menge;
    Auf.P.Prd.VSB.Stk   # Auf.P.Prd.VSB.Stk + "Auf.A.Stückzahl";
    Auf.P.Prd.VSB.Gew   # Auf.P.Prd.VSB.Gew + Auf.A.Gewicht;
    Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// BAGSchrottAbschluss
//          schliesst eine theoretische Schrottmenge ab
//========================================================================
sub BAGSchrottAbschluss() : logic;
local begin
  vOK : logic;
  vAnz : int;
  vNr : int;
  vChargeNeu : alpha;
  vChargeAlt : alpha;
end;
begin
todo('simple PRD Abschluss');
/***
  Erx # RecLink(252,404,4,_RecFirst);   // Charge holen
  if (Erx<>_rOK) then RETURN false;

  Erx # RecLink(250,252,1,_RecFirst);   // Artikel holen
  if (Erx<>_rOK) then RETURN false;

  if (RecLinkInfo(404,252,2,_RecCOunt)<>1) then RETURN false;
  if (Rnd(Art.C.Bestand,2)<>Rnd(Auf.A.Menge,2)) then RETURN False;


  // Charge LÖSCHEN
  Art_Data:Reservierung( (-1.0) * Art.C.Reserviert, 'RV',y);
  Erx # RecLink(252,404,4,_RecFirst);   // Charge holen
  Art_Data:Bewegung((-1.0) * Art.C.Bestand, Translate('Schrott'+' '+cnvai(Auf.A.Nummer,_FmtNumNoGroup)+'/'+cnvai(Auf.A.Position) ));


  // Auf.Aktion anpassen
  RecRead(404,1,_recLock);
  Auf.A.Charge        # '';
  Auf.A.Bemerkung     # c_AktBem_Schrott;
  "Auf.A.Löschmarker" # '*';
  ERx # RekReplace(404,_recUnlock,'AUTO');
  if (Erx<>_rOK) then RETURN false;
***/
  RETURN true;
end;


//========================================================================
// BAGAbschluss
//          schliesst einen theoretischen Zuschnittsreservierung-BA ab
//========================================================================
sub BAGAbschluss();
local begin
  Erx   : int;
  vOK   : logic;
end;
begin

  if ("Auf.P.Löschmarker"<>'') then RETURN;

  RekLink(819,401,1,_RecFirst);         // Warengruppe holen
  if (Wgr_data:IstArt()=false) then RETURN;


  // keine Stückliste vorhanden?
  if (RecLinkInfo(409,401,15,_RecCount)=0) then RETURN;

  // Aktionsliste durchlaufen
  Erx # RecLink(404,401,12,_recFirst);
  vOk # n;
  WHILE (Erx<=_rLocked) and (vOK=n) do begin
    if (Auf.A.Aktionstyp=c_Akt_PRD_Plan) then vOK # y;
    Erx # RecLink(404,401,12,_recNext);
  END;

//  if (vOK=n) then RETURN;

//  if (Msg(409700,'',_WinIcoQuestion,_WinDialogOkCancel,2)<>_WinIdOk) then RETURN;


  TRANSON;

  // Aktionsliste durchlaufen und Reservierungen suchen
  Erx # RecLink(404,401,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Auf.A.Aktionstyp=c_Akt_PRD_Plan) and ("Auf.A.Löschmarker"='') then begin
      if (BAGResAbschluss()=n) then begin
        TRANSBRK;
todo('FEHLER');
        RETURN;
      end;
    end;

    Erx # RecLink(404,401,12,_recNext);
  END;

  // Aktionsliste durchlaufen und Schrott suchen
  Erx # RecLink(404,401,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Auf.A.Aktionstyp=c_Akt_Schrott) and ("Auf.A.Löschmarker"='') then begin
      if (BAGSchrottAbschluss()=n) then begin
        TRANSBRK;
        RETURN;
      end;
    end;

    Erx # RecLink(404,401,12,_recNext);
  END;

  TRANSOFF;

//  Msg(409701,'',0,0,0);

  // ggf. Positionsartikel herstellen
  BAGProduziere();

end;


//========================================================================
// BAGAbschluss_allePos
//          schliesst jede Posotion eines Auftrages ab
//========================================================================
sub BAGAbschluss_allePos();
local begin
  Erx : int;
end;
begin

  if (Msg(409707,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdyes) then begin
    if (Msg(409700,'',_WinIcoQuestion,_WinDialogYesno,2)<>_WinIdyes) then RETURN;

    BAGAbschluss();                     // eine Position abschliessen
    Msg(409701,'',0,0,0);
    RETURN;
  end;


  RecLink(400,401,3,_recFirst);         // Kopf holen
  Erx # RecLink(401,400,9,_recFirst);   // Posten loopen
  WHILE (Erx<_rLocked) do begin
    BAGAbschluss();                     // eine Position abschliessen
    Erx # RecLink(401,400,9,_recNext);
  END;

  Msg(409701,'',0,0,0);

end;


//========================================================================