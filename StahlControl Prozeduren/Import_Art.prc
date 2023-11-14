@A+
//===== Business-Control =================================================
//
//  Prozedur    Import_Art
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2008  MS  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB Import_TSR();
//    SUB Import_JSN()
//    SUB Import_KTM();
//
//========================================================================
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Global

define begin
  GetAlphaUp(a,b) : a # strcnv(FldAlphabyName('X_'+b),_StrUpper);
  GetAlpha(a,b)   : a # FldAlphabyName('X_'+b);
  GetInt(a,b)     : a # FldIntbyName('X_'+b);
  GetWord(a,b)    : a # FldWordbyName('X_'+b);
  GetNum(a,b)     : a # FldFloatbyName('X_'+b);
  GetBool(a,b)    : a # FldLogicbyName('X_'+b);
  GetDate(a,b)    : a # FldDatebyName('X_'+b);
  GetTime(a,b)    : a # FldTimebyName('X_'+b);

  SetFld(a,b)     : FldDefByName('X_'+a,b)
end;


//========================================================================
//  Import_TSR
//
//  GetAlphaUp
//  GetAlpha
//  GetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime
//========================================================================
sub Import_TSR()
local begin
  Erx             : int;
  Ansprechpartner : int;
  vTxt            : int;
end;
begin

  // ALLE ARTIKEL LÖSCHEN...
  Lib_rec:ClearFile(250,'TEXT');


  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
//  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin

    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2250,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(250);

    /*
    GetInt(,'');
    GetWord(,'');
    GetAlpha(,'');
    GetNum(,'');
    GetDate(,'');
    GetBool(,'');
    */
    Art.Artikelgruppe # 1;
    Art.Typ # 'HDL';

    GetInt(Art.ID,'Art.Nummer');
    GetAlpha(Art.Stichwort,'Art.Stichwort');
    GetWord(Art.Warengruppe,'Art.Warengruppe');

    GetInt(Art.PEH,'Art.PreiseinhEK');
//    GetInt(,'Art.Bestand.Stk');
//    debug(Art.Nummer);
//    debug(Art.Stichwort);

    GetAlpha(Art.Nummer,'Art.Artikelnummer');
    GetAlpha(Art.Stichwort,'Art.Stichwort');
    GetAlpha(Art.Meh,'Art.MengeneinhEK');
    GetAlpha("Art.Güte",'Art.Variantentyp');
    GetNum("Art.Länge",'Art.Länge');
    GetNum(Art.Breite,'Art.Breite');
    GetNum(Art.Dicke,'Art.Dicke');
    GetNum(Art.Innendmesser,'Art.Innendurchm');
    GetNum(Art.Aussendmesser,'Art.Außendurchm');
    GetNum(Art.SpezGewicht,'Art.Dichte');
    GetAlpha(Art.AbmessungString,'Art.Abmessungstext');
    GetBool(Art.LagerjournalYN,'Art.Bestandsführung');
    GetBool(Art.GesperrtYN,'Art.Inaktiv?');
    GetNum(Art.Bestand.Min,'Art.Meldebestand');
    GetNum(Art.Bestand.Soll,'Art.Optimalbestand');
    GetAlpha(Art.Sperrgrund,'Art.Bemerkung1');
    GetAlpha(Art.Bemerkung,'Art.Bemerkung2');
    GetAlpha(GV.Alpha.23,'Art.Werkstoffnummer');
    Art.Werkstoffnr # strcut(GV.Alpha.23,0,8);
    GetAlpha(Art.DickenTol,'Art.Dickentoleranz');
    GetAlpha(Art.BreitenTol,'Art.Breitentoleranz');
    GetAlpha("Art.LängenTol",'Art.Längentoleranz');
    GetWord("Art.Oberfläche",'Art.Oberfläche');

    GetNum("Art.Bestand.Inventur",'Art.MinBestellmenge');
    GetNum("Art.GewichtProStk",'Art.Berechnung');

    Erx # RecLink(819,250,10,0);    // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);
    if (Wgr.Dichte<>0.0) then Art.SpezGewicht # Wgr.Dichte;

    "Art.Fläche"  # Rnd(Art.Breite / 1000.0 * "Art.Länge" / 1000.0, 2);
    Art.Volumen   # Rnd(Art.Dicke / 1000.0 * Art.Breite / 1000.0 * "Art.Länge" / 1000.0, 2);
    if ("Art.GewichtProStk"=0.0) then
      //"Art.GewichtProStk" # Art.SpezGewicht * Art.Dicke * Art.Breite * "Art.Länge" / 1000000.0;
      "Art.GewichtProStk" # Art.Dicke / 100.0 * Art.Breite / 100.0 * "Art.Länge" / 100.0 * Art.SpezGewicht;
    "Art.GewichtProStk" # Rnd("Art.GewichtProStk", 3);


    // ANLEGEN...
    Erx #  RekInsert(250,0,'MAN');


    vTxt # TextOpen(15);
    TextRead(vTxt,'~it.250.'+cnvai(Art.ID,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+'.000',_TextDba2);
    TextSearch(vTxt,1,1,_TextSearchCi, '$$D', StrChar(27,3)+'1');
    TextSearch(vTxt,1,1,_TextSearchCi, '$$E', StrChar(27,3)+'2');
    TextSearch(vTxt,1,1,_TextSearchCi, '$$I', StrChar(27,3)+'3');
    TextSearch(vTxt,1,1,_TextSearchCi, '$$S', StrChar(27,3)+'4');
    TextSearch(vTxt,1,1,_TextSearchCi, '$$A', StrChar(27,3)+'5');

    if (TextSearch(vTxt,1,1,_TextSearchCi, StrChar(27,3)+'1')=0) then
      TextLineWrite(vTxt,1, StrChar(27,3)+'1', _TextLineInsert);
    if (TextSearch(vTxt,1,1,_TextSearchCi, StrChar(27,3)+'2')=0) then
      TextLineWrite(vTxt, TextInfo(vTxt, _TextLines)+1, StrChar(27,3)+'2', _TextLineInsert);
    if (TextSearch(vTxt,1,1,_TextSearchCi, StrChar(27,3)+'3')=0) then
      TextLineWrite(vTxt, TextInfo(vTxt, _TextLines)+1, StrChar(27,3)+'3', _TextLineInsert);
    if (TextSearch(vTxt,1,1,_TextSearchCi, StrChar(27,3)+'4')=0) then
      TextLineWrite(vTxt, TextInfo(vTxt, _TextLines)+1, StrChar(27,3)+'4', _TextLineInsert);
    if (TextSearch(vTxt,1,1,_TextSearchCi, StrChar(27,3)+'5')=0) then
      TextLineWrite(vTxt, TextInfo(vTxt, _TextLines)+1, StrChar(27,3)+'5', _TextLineInsert);


    TxtWrite(vTxt,'~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8) ,0);
    TextClose(vTxt);


    Erx # RecRead(2250,1,_recNext);

  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Artikel wurden importiert!',0,0,0);
end;


//========================================================================
//========================================================================
//  Import_JSN
//
//========================================================================
sub Import_JSN()
local begin
  Erx       : int;
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vAdresse  : int;

  vProjekt : int;
  vArtikel : alpha;
  vBemerkung : alpha;
  vLaenge : float;
vMenge : float;
vPreis : float;
vGewicht : float;
vCharge : alpha;
vOK : logic;
vStueck : int;
end;
begin

  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);

    // Dlg_Standard:Anzahl('Lagerort ',var vAdresse,0);

    FSIMark(vFile, 13);   /* CR */
    FSIRead(vFile, vA);
    FSIMark(vFile, 10);   /* LF */
    FSIRead(vFile, vA);

    WHILE (vPos<vMax) do begin

      FSIMark(vFile, 59);   /* ; */

      FSIRead(vFile, vA);
      vProjekt # cnvIA(vA);         /* 01 Projektnummer */

      Prj.Nummer # vProjekt;
      Erx # RecRead(120,1,0);
      If Erx <= _rLocked then begin
        vAdresse # Prj.Adressnummer;
      end
      else RecBufClear(120,y);

      FSIRead(vFile, vA);
      /* 02 Artikelnummer               */
      vArtikel # vA;

      FSIRead(vFile, vA);
      /* 03 Chargennummer   (Dummy)     */

      FSIRead(vFile, vA);
      /* 04 Bemerkung       (Dummy)     */

      FSIRead(vFile, vA);
      /* 05 Anzahl Bunde    (Dummy)     */

      FSIRead(vFile, vA);
      /* 06 Titel Bunde     (Dummy)     */

      FSIRead(vFile, vA);
      /* 07 Stk. pro Bund   (Bemerkung) */
      vBemerkung # StrCut(vA,0,3) + ' Stk. je Bund';

      FSIRead(vFile, vA);
      /* 08 Titel Stk.      (Dummy)     */

      FSIRead(vFile, vA);
      /* 08  Stk.      (Dummy)     */
      vStueck # cnvIA(vA);

      FSIRead(vFile, vA);
      /* 09 Länge / Stk.                */
      vLaenge # cnvFA(vA);

      FSIRead(vFile, vA);
      /* 10 Länge gesamt                */
      vMenge # cnvFA(vA);

      FSIRead(vFile, vA);
      /* 11 EK Preis / PEH              */
      vPreis # cnvFA(vA);

      FSIRead(vFile, vA);
      /* 12 kg gesamt                   */
      vGewicht # cnvFA(vA);


      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);
      //letzter
      /* 13 Abmessung       (Dummy)     */


      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      RecBufClear(252);
      vOK # true;
      debug('vor  ReadNummer' +  cnvai(Erx) + '   ' + cnvAI(cnvIL(vOK)) + '   ' + cnvai(vnr));
      vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
      debug('nach ReadNummer' +  cnvai(Erx) + '   ' + cnvAI(cnvIL(vOK)) + '   ' + cnvai(vnr));
      if (vNr<>0) then Lib_Nummern:SaveNummer();
      debug('nach SaveNummer' +  cnvai(Erx) + '   ' + cnvAI(cnvIL(vOK)) + '   ' + cnvai(vnr));

      if (vOK=false) then begin
        FSIClose(vFile);
        TODO('ERROR 001!!');
        RETURN;
      end;


      vCharge # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);


      Art.C.ArtikelNr     # vArtikel;
      Art.C.Charge.Intern # vCharge;
      Art.C.AdressNr      # vAdresse;
      Art.C.AnschriftNr   # 1;
      Art.C.Lieferantennr # Ein.E.Lieferantennr;
      Art.C.Dicke         # 0.0;
      Art.C.Breite        # 0.0;
      "Art.C.Länge"       # vLaenge;
      Art.C.RID           # 0.0;
      Art.C.RAD           # 0.0
      Art.C.Lagerplatz    # '';
      Art.C.Charge.Extern # '';
      Art.C.Bezeichnung   # vBemerkung;
/*      vOK # Art_Data:Bewegung(vMenge, vStueck,
       Translate('Anfangsbestand')+' '+(vArtikel)+'/'+(vCharge)+':'+cnvAI(vAdresse),
       vPreis,
       0.0,
       TODAY);
      if (vOK=false) then begin
        FSIClose(vFile);
        TODO('ERROR 002!!');
        RETURN;
      end;
*/
      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

  end;

  TODO('OK !');

end;


//========================================================================
// call import_art:import_KTM
//========================================================================
sub Import_KTM()
local begin
  Erx             : int;
  vTxt            : int;
  vA              : alpha(1000);
  vI              : int;
  vOK             : logic;
  vProgress       : handle;
  vBLock          : int;
  vBuf256         : int;
end;
begin

  // ALLE ARTIKEL LÖSCHEN...
  Lib_rec:ClearFile(250,'TEXT');
  Lib_rec:ClearFile(251,'TEXT');
  Lib_rec:ClearFile(252,'TEXT');
  Lib_rec:ClearFile(253,'TEXT');
  Lib_rec:ClearFile(254,'TEXT');
  Lib_rec:ClearFile(255,'TEXT');
  Lib_rec:ClearFile(256,'TEXT');
  Lib_rec:ClearFile(259,'TEXT');


//dbadisconnect(2);
  Erx # DBAConnect(2,'X_','TCP:192.168.0.2','Kottmann 5.5','thomas','','');
//  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin
    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  vProgress # Lib_Progress:Init( 'Import', RecInfo( 2200, _recCount) );




  Erx # RecRead(2200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    vProgress->Lib_Progress:Step();

    RecBufClear(250);

    GetInt(Art.ID,'Art.InterneArtikelNr');
    GetAlpha(Art.Nummer,'Art.Nummer');
    GetAlpha(vA,'Art.Stichwort');
    Art.Stichwort # StrCut(vA,1,20);
    GetAlpha(Art.Katalognr,'Art.KatalogNr');
    //GetAlpha(Art.Sachnummer,'');
    GetAlpha(vA, 'Art.Name1');
    "Art.Bezeichnung1" # StrCut(vA,1,64);
    GetAlpha(vA, 'Art.Name2');
    "Art.Bezeichnung2" # StrCut(vA,1,64);
    //GetAlpha(Art.Bezeichnung3,);
    GetAlpha(Art.Typ,'Art.Typ');
    case Art.Typ of
      'P' : Art.Typ # 'PRD';
      'X' : Art.Typ # 'EXP';
      'H' : ARt.Typ # 'HDL';
      'B' : Art.Typ # 'BGR';
      'K','V' : begin   // Keine Verbuchung = Ersatzartikel für Kunde
        Erx # RecRead(2200,1,_recNext);
        CYCLE;
      end;
      // 'X', 'V' :
    end;
    GetWord(Art.Warengruppe,'Art.WGr');
    GetWord(Art.Artikelgruppe,'Art.ArtGr');
    GetWord(Art.PEH, 'Art.PEH');
    GetWord(vI, 'Art.MEH');
    case vI of    // unten nochmal!!
      1 : Art.MEH # 'Stk';
      2 : ARt.MEH # 'kg';
      3 : ARt.MEH # 'm';
      4 : ARt.MEH # 'g';
      5 : ARt.MEH # 'mg';
      6 : ARt.MEH # '???';
      7 : ARt.MEH # '???';
      8 : ARt.MEH # 'min';
      9 : ARt.MEH # 'h';
    end;
    GetAlpha(Art.Intrastatnr,'Art.Intrastatnr');
    GetBool(Art.LagerjournalYN,'Art.LagerverwaltJN');
    "Art.ChargenführungYN" # Art.LagerjournalYN;
    Art.SeriennummerYN  # n;
    Getbool(Art.AutoBestellYN,'Art.Bestellvorschlg?');
    GetNum(Art.Bestand.Min,'Art.Min_Bestand');
    GetNum(Art.Bestand.Soll, 'Art.SollBestand');
    GetNum(Art.Bestand.Inventur, 'Art.Inventur_Bestand');
    GetDate(Art.Inventurdatum,'Art.Inventur.Datum');
    GetAlpha(vA, 'Art.Bemerkung');
    Art.Bemerkung # StRCut(vA,1,64);
    GetBool(Art.GesperrtYN, 'Art.GesperrtJN');
    GetAlpha(vA, 'Art.Sperrgrund');
    Art.Sperrgrund # StrCut(vA,1,64);
    //Getint(Art.Dispotage,
    //GetInt(Art.Bestelltage,
/***
Art.ZeichnungsNr
Art.ZeichnungsVers
    GetNum("Art.GewichtProStk",'Art.Berechnung');
    GetNum("Art.Länge",'Art.Länge');
    GetNum(Art.Breite,'Art.Breite');
    GetNum(Art.Dicke,'Art.Dicke');
Art.Volumen
Art.Fläche
Art.Bilddatei
Art.Prod.Dauer
Art.Prod.KostenW1
    GetNum(Art.Aussendmesser,'Art.Außendurchm');
    GetAlpha(Art.AbmessungString,'Art.Abmessungstext');
Art.KubischYN
Art.RotativYN
    GetNum(Art.Innendmesser,'Art.Innendurchm');
    GetNum(Art.SpezGewicht,'Art.Dichte');
Art.GewichtProm
Art.Bild.DruckenYN
    GetAlpha("Art.Güte",'Art.Variantentyp');
    GetAlpha(Art.Werkstoffnr,'Art.Werkstoffnummer');
    GetWord("Art.Oberfläche",'Art.Oberfläche');
    GetAlpha(Art.DickenTol,'Art.Dickentoleranz');
    GetAlpha(Art.BreitenTol,'Art.Breitentoleranz');
    GetAlpha("Art.LängenTol",'Art.Längentoleranz');
***/
    Erx # RecLink(819,250,10,0);    // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);
    if (Wgr.Dichte<>0.0) then Art.SpezGewicht # Wgr.Dichte;

    "Art.Fläche"  # Rnd(Art.Breite / 1000.0 * "Art.Länge" / 1000.0, 2);
    Art.Volumen   # Rnd(Art.Dicke / 1000.0 * Art.Breite / 1000.0 * "Art.Länge" / 1000.0, 2);
    if ("Art.GewichtProStk"=0.0) then
      //"Art.GewichtProStk" # Art.SpezGewicht * Art.Dicke * Art.Breite * "Art.Länge" / 1000000.0;
      "Art.GewichtProStk" # Art.Dicke / 100.0 * Art.Breite / 100.0 * "Art.Länge" / 100.0 * Art.SpezGewicht;
    "Art.GewichtProStk" # Rnd("Art.GewichtProStk", 3);

    GetDate(Art.Anlage.Datum, 'Art.Anlage.Datum');
    GetTime(Art.Anlage.Zeit, 'Art.Anlage.Zeit');
    GetAlpha(Art.Anlage.User, 'Art.Anlage.User');

    // ANLEGEN...
    Erx #  RekInsert(250,0,'MAN');


    // CHARGEN ------------------------------------------
    // Artikel-Summen-Charge anlegen
    RecBufClear(252);
    Art.C.ArtikelNr   # Art.Nummer;
    Art_Data:OpenCharge(y);

    GetNum(Art.C.Bestand, 'Art.Bestand');
//    GetNum(Art.C.Bestand.Stk,
    GetNum(Art.C.EKDurchschnitt, 'Art.EK_Durchschnitt');
    GetNum(Art.C.EKLetzter, 'Art.letzterEK');
    GetNum(Art.C.VKDurchschnitt, 'Art.VK_Durchschnitt');
    GetNum(Art.C.VKLetzter, 'Art.StdVK');

    Erx # Art_data:WriteCharge(y);


    // PREISE --------------------------------------------
    RecBufClear(254);
    Art.P.ArtikelNr     # Art.Nummer;
    Art.P.Nummer        # 0;
    Art.P.ArtStichwort  # Art.Stichwort;
    "Art.P.Währung"     # 1;
    Art.P.PEH           # Art.PEH;
    Art.P.MEH           # Art.MEH;
    Art.P.Anlage.Datum  # Today;
    Art.P.Anlage.Zeit   # Now;
    Art.P.Anlage.User   # gUserName;

    Art.P.Preistyp      # 'Ø-EK';
    Art.P.Preis         # Art.C.EKDurchschnitt;
    Art.P.PreisW1       # Art.P.Preis;
    REPEAT
      Art.P.Nummer # Art.P.Nummer + 1;
      Erx # Art_P_Data:Insert(0,'AUTO');
    UNTIL (erx=_rOK) or (Art.P.Nummer=1000);

    Art.P.Preistyp      # 'L-EK';
    Art.P.Preis         # Art.C.EKLetzter;
    Art.P.PreisW1       # Art.P.Preis;
    REPEAT
      Art.P.Nummer # Art.P.Nummer + 1;
      Erx # Art_P_Data:Insert(0,'AUTO');
    UNTIL (Erx=_rOK) or (Art.P.Nummer=1000);


    // Stücklist ------------------------------------
    vBlock # 1;
    RecbufClear(255);
    Erx # RecLink(2204,2200,9,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (Art.SLK.Artikelnr='') then begin
        Art.SLK.Artikelnr # Art.Nummer;
        Art.SLK.Nummer    # 1;
        Art.SLK.Name      # 'Standard';
        Art.SLK.Bemerkung # 'aus Altsystem';
        RekInsert(255,_recUnlock,'AUTO');
      end;
      RecbufClear(256);
      Art.SL.Artikelnr    # Art.SLK.Artikelnr;
      Art.SL.Nummer       # 1;
//      GetInt(Art.SL.Blocknr, 'Art.S.Eintrag');
      Art.SL.BlockNr      # vBlock;
      Art.SL.lfdNr        # 1;
      Art.SL.Typ          # 250;
      GetBool(vok, 'Art.S.DrkLFS');
      if (vok) then Art.SL.Bemerkung # 'Druck auf LFS';
      GetNum(Art.SL.Menge,'Art.S.Menge');
      GetWord(vI, 'Art.S.MEH');
      case vI of    // oben nochmal!!
        1 : Art.SL.MEH # 'Stk';
        2 : ARt.SL.MEH # 'kg';
        3 : ARt.SL.MEH # 'm';
        4 : ARt.SL.MEH # 'g';
        5 : ARt.SL.MEH # 'mg';
        6 : ARt.SL.MEH # '???';
        7 : ARt.SL.MEH # '???';
        8 : ARt.SL.MEH # 'min';
        9 : ARt.SL.MEH # 'h';
      end;
      Getalpha(Art.SL.Input.ArtNr, 'Art.S.Artikel');
      Art.SL.Kosten.StdYN # y;

      Art.SL.Anlage.Datum # today;
      Art.SL.Anlage.Zeit  # now;
      Art.SL.Anlage.User  # 'ALTSYSTEM';

      RekInsert(256,_recUnlock,'AUTO');
      inc(vBlock);

      Erx # RecLink(2204,2200,9,_recNext);
    END;

    if (Art.SLK.Nummer<>0) then begin
      RecRead(250,1,_recLock);
      "Art.Stückliste" # Art.SLK.Nummer;
      Erx # RekReplace(250,_recUnlock,'AUTO');
    end;

    Erx # RecRead(2200,1,_recNext);
  END;

  DBADisconnect(2)

  vProgress->Lib_Progress:Term();



  // SL loopen --------------------------------
  vProgress # Lib_Progress:Init( 'Kalkuliere SLK...', RecInfo( 255, _recCount) );
  Erx # RecRead(255,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    vProgress->Lib_Progress:Step();

    Erx # RecLink(256,255,2,_recfirst);   // SL-Loopen
    WHILE (Erx<=_rLocked) do begin

      if (Art.SL.Typ=250) then begin
/***
        Erx # RecLink(250,256,2,_recFirst);   // Input-Artikel holen
        if (Erx<=_rLocked) then begin
          SetFld('Art.Nummer', Art.Nummer);
          Erx # RecRead(2200,1,0);
          if (Erx<=_rLocked) then begin
            GetAlpha(Art.Typ,'Art.Typ');
***/
        Erx # RecLink(250,256,2,_recFirst);   // Input-Artikel holen
        if (Erx>_rLocked) then begin
        //    if (Art.Typ='V') then begin
              if (Art.SL.Blocknr<>1) or (art.SL.lfdNr<>1) then begin
                vBuf256 # RekSave(256);
                Art.SL.BlockNr  # 1;
                Art.SL.lfdNr    # 1;
                Erx # RecRead(256,1,_recLock);
                if (Erx<=_rLockeD) then begin
                  REPEAT
                    Art.SL.lfdNr  # Art.SL.lfdNr + 1;
                    Erx # RekReplace(256,_RecUnlock,'AUTO');
                  UNTIL (Erx=_rOK);
                end;
                RekRestore(vBuf256);
              end;
              RecRead(256,1,_recLock);
              Art.SL.BlockNr      # 1;
              Art.SL.lfdNr        # 1;
              Art.SL.Typ          # 828;
              Art.SL.Bemerkung    # Art.SL.Input.ArtNr;
              Art.SL.Input.ArtNr  # '';
              Art.SL.Input.ArGAkt # 'VEREDL';
              RekReplace(256,_RecUnlock,'AUTO');
              Erx # RecLink(256,255,2,_recFirst);
              CYCLE;
        end;

        Erx # RecLink(256,255,2,_recNext);
      END;

      Art_SL_Data:RecalcSLK();

    end;

    Erx # RecRead(255,1,_RecNext);
  END;
  vProgress->Lib_Progress:Term();


  Msg(99,'Artikel-SL wurden berechnet!',0,0,0);
end;

//========================================================================

//========================================================================
//  call Import_Art:Import_ProPipe
//
//========================================================================
sub Import_ProPipe()
local begin
  Erx         : int;
  vNr         : int;
  vFile       : int;
  vMax        : int;
  vPos        : int;
  vA          : alpha(4000);
  vName       : alpha;
  vAdresse    : int;

  vProjekt    : int;
  vArtikel    : alpha;
  vBemerkung  : alpha;
  vLaenge     : float;
  vMenge      : float;
  vPreis      : float;
  vGewicht    : float;
  vCharge     : alpha;
  vOK         : logic;
  vStueck     : int;
end;
begin


  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
      RETURN;
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);

    // Dlg_Standard:Anzahl('Lagerort ',var vAdresse,0);
/*
    FSIMark(vFile, 13);   /* CR */
    FSIRead(vFile, vA);
    FSIMark(vFile, 10);   /* LF */
    FSIRead(vFile, vA);
*/
    WHILE (vPos<vMax) do begin
      FSIMark(vFile, 59);   /* ; */

      FSIRead(vFile, vA);
      Art.ID  # Lib_Strings:AlphaToInt(vA);

      FSIRead(vFile, vA);
      Art.Nummer  # vA;

      FSIRead(vFile, vA);
      Art.Stichwort # vA;

      FSIRead(vFile, vA);
      Art.Sachnummer # vA;

      FSIRead(vFile, vA);
      Art.Bezeichnung1 # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 64);

      FSIRead(vFile, vA);
      Art.Bezeichnung2 # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 64);

      FSIRead(vFile, vA);
      Art.Bezeichnung3 # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 64);

      FSIRead(vFile, vA);
      Art.Typ # vA;

      FSIRead(vFile, vA);
      Art.Warengruppe # cnvIA(vA);

      FSIRead(vFile, vA);
      Art.Artikelgruppe # cnvIA(vA);

      FSIRead(vFile, vA);
      Art.PEH # cnvIA(vA);

      FSIRead(vFile, vA);
      Art.MEH # vA;

      FSIRead(vFile, vA);
      Art.Intrastatnr # vA;


      FSIRead(vFile, vA);
      if(vA = 'Y') then
        Art.LagerjournalYN # true;
      else
        Art.LagerjournalYN # false;

      FSIRead(vFile, vA);
      if(vA = 'Y') then
        "Art.ChargenführungYN" # true;
      else
        "Art.ChargenführungYN" # false;

      FSIRead(vFile, vA);
      "Art.GewichtProStk" # cnvFA(vA);

      FSIRead(vFile, vA);
      "Art.Länge" # cnvFA(vA);

      FSIRead(vFile, vA);
      "Art.Breite" # cnvFA(vA);

      FSIRead(vFile, vA);
      "Art.Dicke" # cnvFA(vA);

      FSIRead(vFile, vA);
      Art.Aussendmesser # cnvFA(vA);

      FSIRead(vFile, vA);
      Art.AbmessungString # vA;

      FSIRead(vFile, vA);
      Art.Innendmesser # cnvFA(vA);

      FSIRead(vFile, vA);
      "Art.GewichtProm" # cnvFA(vA);;

      FSIRead(vFile, vA);
      "Art.Güte" # vA;

      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);  // letzter
      "Art.Oberfläche" # cnvIA(vA);

      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      RecBufClear(252);
      vOK # true;
      debug('vor  ReadNummer' +  cnvai(Erx) + '   ' + cnvAI(cnvIL(vOK)) + '   ' + cnvai(vnr));
      vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
      debug('nach ReadNummer' +  cnvai(Erx) + '   ' + cnvAI(cnvIL(vOK)) + '   ' + cnvai(vnr));
      if (vNr<>0) then Lib_Nummern:SaveNummer();
      debug('nach SaveNummer' +  cnvai(Erx) + '   ' + cnvAI(cnvIL(vOK)) + '   ' + cnvai(vnr));

      if (vOK=false) then begin
        FSIClose(vFile);
        TODO('ERROR 001!!');
        RETURN;
      end;

      // ANLEGEN...
      Erx #  RekInsert(250,0,'MAN');


      vCharge # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);


      Art.C.ArtikelNr     # Art.Nummer;
      Art.C.Charge.Intern # vCharge;
      Art.C.AdressNr      # Set.eigeneAdressnr;
      Art.C.AnschriftNr   # 1;
      Art.C.Lieferantennr # 0;
      Art.C.Dicke         # 0.0;
      Art.C.Breite        # 0.0;
      "Art.C.Länge"       # vLaenge;
      Art.C.RID           # 0.0;
      Art.C.RAD           # 0.0
      Art.C.Lagerplatz    # '';
      Art.C.Charge.Extern # '';
      Art.C.Bezeichnung   # '';
      Erx # Art_data:WriteCharge(y);
/*      vOK # Art_Data:Bewegung(vMenge, vStueck,
       Translate('Anfangsbestand')+' '+(vArtikel)+'/'+(vCharge)+':'+cnvAI(vAdresse),
       vPreis,
       0.0,
       TODAY);
      if (vOK=false) then begin
        FSIClose(vFile);
        TODO('ERROR 002!!');
        RETURN;
      end;
*/
      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

  end;

  TODO('OK !');

end;
//========================================================================