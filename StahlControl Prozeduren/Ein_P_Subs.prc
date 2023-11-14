@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_P_Subs
//                OHNE E_R_G
//  Info
//
//
//  16.08.2011  AI  Erstellung der Prozedur
//  17.08.2012  AI  "ToggleLoeschmarker" buffert 506
//  17.12.2012  AI  Löschen von Abrufen passt den Rahmen an
//  05.08.2014  AH  "ToggleLoeschmarker" managed Storniert-Aktion
//  15.04.2016  AH  Neu "CopyMatToPos"
//  26.07.2019  AH  Fix: Statistikverbuchung
//  10.05.2022  AH  ERX
//  22.06.2022  AH  "CalcGewicht"
//  2022-09-30  AH  Ein.Position löschen entfernt Mat.Reservierungen    (Proj. 2333/88)
//
//  Subprozeduren
//    SUB ToggleLoeschmarker(aManuell : logic) : logic;
//    SUB StatistikBuchen(opt a400  : int; opt a401  : int; opt aDat : date; opt aOhneEingang : logic; opt aOhneBestand  : logic)
//    SUB CopyMatToPos(opt aNoVis : logic);
//    SUB CalcGewicht
//
//========================================================================
@I:Def_global
@I:Def_Aktionen

//========================================================================
// ToggleLoeschmarker
//
//========================================================================
sub ToggleLoeschmarker(aManuell : logic) : logic;
local begin
  Erx       : int;
  vBuf501   : int;
  vRes      : logic;
  vVSA      : logic;
  vVSB      : logic;
  vPrd      : logic;
  xvBuf200  : int;
  v506      : int;
  vStorno   : logic;
end;
begin


  RecLink(500,501,3,_RecFirst);         // Kopf holen
  Erx # RecLink(835,501,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);


  // 05.08.2014:
  if ("Ein.P.Löschmarker"='') then
    vStorno # (Ein.P.FM.Eingang=0.0) and (Ein.P.FM.VSB=0.0) and (Ein.P.FM.Ausfall=0.0);


  // Satz löschen --------------------------------------------------------
  if ("Ein.P.Löschmarker"='') then begin

    v506 # RekSave(506);
    Erx # RecLink(506,501,14,_recFirst);  // WE loopen
    WHILE (Erx<=_rLocked) do begin
      if (Ein.E.VSBYN) and ("Ein.E.Löschmarker"='') then begin
        if (aManuell) then Msg(501001,'',0,0,0);
        RekRestore(v506);
        AfxRes # 66;
        RETURN false;
      end;
      Erx # RecLink(506,501,14,_recNext);
    END;
    RekRestore(v506);

    if (aManuell) then begin
      // 2022-09-30 AH    Proj. 2333/88
      Erx # 0;
      if (Ein.P.Materialnr<>0) then begin
        Erx # Mat_data:read(Ein.P.Materialnr,_recunLock,0,false);
        // Mat-Reservierungen existieren???
        if (Erx>=200) then begin
          if (RecLinkInfo(203,200,13,_recCount)<>0) then begin
            if (Msg(401014,'',0,_WinDialogOkCancel,2)<>_WinIdOK) then RETURN true;
            Erx # 1;
          end;
        end;
      end
      if (Erx<>1) then
        if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;

      if (vStorno) then
        vStorno # (Msg(401025,'',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes);
    end;

    TRANSON;

    PtD_Main:Memorize(501);
    RecRead(501,1,_recLock);
    Ein.P.StorniertYN       # vStorno;
    "Ein.P.Löschmarker"     # '*';
    "Ein.P.Lösch.Datum"     # today;
    "Ein.P.Lösch.Zeit"      # now;
    "Ein.P.Lösch.User"      # gUsername;
    Erx # Ein_Data:PosReplace(_Recunlock,'MAN');
    if (Erx<>_rOk) then begin
      PtD_Main:Forget(501);
      TRANSBRK;
      if (aManuell) then Msg(001000+Erx,Translate(gTitle),0,0,0);
      AfxRes # 94;
      RETURN false;
    end;

    if (vStorno) then begin
      RecBufClear(504);
      Ein.A.Aktionstyp    # c_Akt_Storniert;
      Ein.A.Bemerkung     # c_AktBem_Storniert;
      Ein.A.Aktionsnr     # Ein.P.Nummer;
      Ein.A.Aktionspos    # Ein.P.Position;
      Ein.A.Aktionsdatum  # Today;
      Ein.A.TerminStart   # Today;
      Ein.A.TerminEnde    # Today;
      Ein_A_Data:NeuAnlegen();
    end;

    PtD_Main:Compare(501);

    // so tun, als ob die Position neu wäre...
    vBuf501 # RecBufCreate(501);
    Ein_Data:SperrPruefung(vBuf501,y);
    RecBufDestroy(vBuf501);


    if (Ein.AbrufYN) and (Ein.P.AbrufAufNr<>0) then begin
      Ein_Data:VerbucheAbruf(n);
    end;

    // Materialkarten update
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      if (Ein_Data:UpdateMaterial()=false) then begin
        TRANSBRK;
        ErrorOutput;
        if (aManuell) then Msg(501200,gTitle,0,0,0);
        AfxRes # 128;
        RETURN false;
      end;

      // ST 2011-04-19: Nach manueller Löschung den Löschmarker
      //                am Material auch mit Restgewichten
      //                (siehe EIN_DATA_:UPDATE_MATERIAL) setzen
      if (Ein.P.Materialnr<>0) then begin
// 27.04.2015
//        Erx # RecLink(200,501,13,_recLock);   // Bestand versuchen
        Erx # Mat_data:read(Ein.P.Materialnr,_recLock,0,true);
        if (Erx<200) then begin
//        if (Erx=_rLocked) then begin
          Error(001000+Erx,Translate('Material')+' '+AInt(Ein.P.Materialnr));
          TRANSBRK;
          ErrorOutput;
          AfxRes # 144;
          RETURN false;
        end;
        Mat_Data:SetLoeschmarker("Ein.P.Löschmarker");
        Erx # Mat_Data:Replace(0,'AUTO');
        if (Erx<>_rOK) then begin
          Error(001000+Erx,Translate('Material')+' '+AInt(Ein.P.Materialnr));
          TRANSBRK;
          ErrorOutput;
          AfxRes # 153;
          RETURN false;
        end;

        // 2022-09-30 AH    Proj. 2333/88
        if ("Ein.P.Löschmarker"<>'') then begin
          FOR Erx # RecLink(203,200,13,_recFirst)
          LOOP Erx # RecLink(203,200,13,_recFirst)
          WHILE (erx=_rOK) do begin
            if (Mat_Rsv_Data:Entfernen()=false) then begin
              Erx # -1;
              BREAK;
            end;
          END;
          if (Erx=_rDeadLock) or (Erx<0) then begin
            if (aManuell) then begin
              if (Erx<>_rDeadLock) then TRANSBRK;
              Msg(401010,'',0,0,0);
            end;
  Erx # 185;
  AfxRes # Erx;
            RETURN false;
          end;
        end;
        
      end;  // ST 2011-04-19
    end;



    // Artikelbestellung updaten
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
      if (Ein_Data:UpdateArtikel(0.0)=false) then begin
        TRANSBRK;
        ErrorOutput;
        if (aManuell) then Msg(501250,gTitle,0,0,0);
        AfxRes # 167;
        RETURN false;
      end;
    end;

  end
  else begin  // AKTIVIEREN -------------------------------------------------

    if (aManuell) then
      if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;

    TRANSON;

    PtD_Main:Memorize(501);
    RecRead(501,1,_recLock);
    Ein.P.StorniertYN     # false;
    "Ein.P.Löschmarker"   # '';
    "Ein.P.Lösch.Datum"   # 0.0.0;
    "Ein.P.Lösch.Zeit"    # 0:0;
    "Ein.P.Lösch.User"    # '';
    Erx # Ein_Data:PosReplace(_Recunlock,'MAN');
    if (Erx<>_rOk) then begin
      PtD_Main:Forget(501);
      TRANSBRK;
      if (Erx<999) and (aManuell) then Msg(001000+Erx,Translate(gTitle),0,0,0);
      AfxRes # 192;
      RETURN false;
    end;
    PtD_Main:Compare(501);

    // Storno vorhanden?
    RecBufClear(504);
    Ein.A.Aktionstyp    # c_Akt_Storniert;
    Ein.A.Aktionsnr     # Ein.P.Nummer;
    Ein.A.Aktionspos    # Ein.P.Position;
    Erx # RecRead(504,2,0);
    if (Erx<=_rMultikey) then
      Ein_A_Data:Entfernen();

    // so tun, als ob die Position neu wäre...
    vBuf501 # RecBufCreate(501);
    Ein_Data:SperrPruefung(vBuf501);
    RecBufDestroy(vBuf501);

    if (Ein.AbrufYN) and (Ein.P.AbrufAufNr<>0) then begin
      Ein_Data:VerbucheAbruf(n);
    end;

    // Materialkarten update
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      if (Ein_Data:UpdateMaterial()=false) then begin
        TRANSBRK;
        ErrorOutput;
        if (aManuell) then Msg(501200,gTitle,0,0,0);
        AfxRes # 21;
        RETURN false;
      end;
    end;

    // Artikelbestellung updaten
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
      if (Ein_Data:UpdateArtikel(0.0)=false) then begin
        TRANSBRK;
        ErrorOutput;
        if (aManuell) then Msg(501250,gTitle,0,0,0);
        AfxRes # 232;
        RETURN false;
      end;
    end;

  end;

  TRANSOFF;

  // alles ok
  RETURN true;

end;


//========================================================================
// StatistikBuchen
//
//========================================================================
Sub StatistikBuchen(
  opt a500          : int;
  opt a501          : int;
  opt aDat          : date;
  opt aOhneEingang  : logic;
  opt aOhneBestand  : logic;
);
local begin
  Erx       : int;
  vLocal500 : logic;
  vLocal501 : logic;
  vTyp      : alpha;
  vUmbuchen : logic;
  vDat      : date;
  vVorgang  : alpha;

  vAdr1     : int;
  vWert1    : float;
  vStk1     : int;
  vGew1     : float;
  vMenge1   : float;
  vKurs1    : float;
  vKonto1A  : alpha;
  vKonto1B  : alpha;

  vAdr2     : int;
  vWert2    : float;
  vStk2     : int;
  vGew2     : float;
  vMenge2   : float;
  vKurs2    : float;
  vKonto2A  : alpha;
  vKonto2B  : alpha;

  vDifWert  : float;
  vDifStk   : int;
  vDifGew   : float;
  vDifMenge : float;
  vDif      : logic;
end;
begin

  vDat # today;
  if (aDat<>0.0.0) then vDat # aDat;
  if (Ein.Vorgangstyp='REK') then RETURN;

  vVorgang # aint(Ein.P.Nummer)+'/'+aint(Ein.P.Position);

  // 25.07.2019
  if (a500<>0) then if (a500->Ein.Nummer=0) then a500 # 0;
  if (a501<>0) then if (a501->Ein.P.Nummer=0) then a501 # 0;

  if (a501=0) then vTyp # '-'
  else begin
    if (a501->"Ein.P.Löschmarker"='') then vTyp # 'B'
    else if (a501->Ein.P.StorniertYN) then vTyp # 'S'
    else vTyp # 'G';
  end;

  if ("Ein.P.Löschmarker"='') then vTyp # vTyp + 'B'
  else if (Ein.P.StorniertYN) then vTyp # vTyp + 'S'
  else vTyp # vTyp + 'G';



  if (a501=0) then begin
    vLocal501 # true;
    a501 # RecBufCreate(501);
    RecBufCopy(501,a501);
  end
  else begin
    if (a501->Ein.P.StorniertYN) then aOhneEingang # false;   // 26.07.2019
  end;
//if (aOhneEingang) then debug('ohne Eingang') else debug('mit Eingang');


  if (a500<>0) then begin
    RecLink(814,a500,8,_recfirst);    // Währung holen
    if (a500->"Ein.WährungFixYN") then
      vKurs1 # a500->"Ein.Währungskurs"
    else
      vKurs1 # "Wae.VK.Kurs";
  end
  else begin
    vLocal500 # true;
    a500 # RecBufCreate(500);
    RecLink(a500,501,3,_recFirst);    // Kopf holen
    RecLink(814,a500,8,_recfirst);    // Währung holen
    if (a500->"Ein.WährungFixYN") then
      vKurs1 # a500->"Ein.Währungskurs"
    else
      vKurs1 # "Wae.VK.Kurs";
  end;
  RecLink(814,500,8,_recfirst);       // Währung holen
  if ("Ein.WährungFixYN") then
    vKurs2 # "Ein.Währungskurs"
  else
    vKurs2 # "Wae.VK.Kurs";
  if (vKurs1=0.0) then vKurs1 # 1.0;
  if (vKurs2=0.0) then vKurs2 # 1.0;


  vUmbuchen # (a500->Ein.LiefervertragYN<>Ein.LiefervertragYN) or (a500->Ein.AbrufYN<>Ein.AbrufYN) or
              (a500->Ein.Vorgangstyp<>Ein.Vorgangstyp);

  if (a500->Ein.Vorgangstyp='') then
    vKonto1a  # 'BEST_'
  else
    vKonto1a  # a500->Ein.Vorgangstyp+'_';
  if (a500->Ein.AbrufYN) then vKonto1a # vKonto1a + 'AR_';
  if (a500->Ein.LiefervertragYN) then vKonto1a # vKonto1a + 'LV_';
  if (Ein.Vorgangstyp='') then
    vKonto2a  # 'BEST_'
  else
    vKonto2a   # Ein.Vorgangstyp+'_';
  if (Ein.AbrufYN) then vKonto2a # vKonto2a + 'AR_';
  if (Ein.LiefervertragYN) then vKonto2a # vKonto2a + 'LV_';


  if (Adr.Lieferantennr<>a500->Ein.Lieferantennr) then Erx # Reklink(100,a500,1,_recFirst);   // Lieferant holen
  vAdr1 # Adr.Nummer;
  if (Adr.Lieferantennr<>Ein.Lieferantennr) then Erx # Reklink(100,500,1,_recFirst);          // Lieferant holen
  vAdr2 # Adr.Nummer;

  RecLink(814,a500,8,_recfirst);    // Währung holen
  if (a500->"Ein.WährungFixYN") then
    vKurs1 # a500->"Ein.Währungskurs"
  else
    vKurs1 # "Wae.VK.Kurs";

  vUmbuchen # (vUmbuchen) or
              (a501->Ein.P.Lieferantennr<>Ein.P.Lieferantennr) or
              (a501->Ein.P.Auftragsart<>Ein.P.Auftragsart) or (a501->Ein.P.Warengruppe<>Ein.P.Warengruppe) or
              (a501->Ein.P.Artikelnr<>Ein.P.Artikelnr) or (a501->"Ein.P.Güte"<>"Ein.P.Güte");
/*
Vorher,   Jetzt     =Eingang    =Rest   Typ (Bestand, Storno, Gelöscht)
-,-       ok, 10    = +10       +10     -B*
ok, 10    ok, 13    = +3        +3      BB*
ok, 13    ok, 10    = -3        -3      BB*

-,-       del, 10   = +10       nix     -G*
del, 10   del, 13   = +3        nix     GG*
del, 13   del, 10   = -3        nix     GG*

-,-       sto, 10   = nix       nix     -S*
sto, 10   sto, 13   = nix       nix     SS*
sto, 13   Sto, 10   = nix       nix     SS*

del, 10   ok, 10    = nix       +10     GB*
del, 10   ok, 13    = +3        +13     GB*
del, 13   ok, 10    = -3        +10     GB*

sto, 10   ok, 10    = +10       +10     SB*
sto, 10   ok, 13    = +13       +13     SB*
sto, 13   ok, 10    = +10       +10     SB*

ok, 10    del, 10   = nix       -10     BG
ok, 10    del, 13   = +3        -10     BG
ok, 13    del, 10   = -3        -13     BG

ok, 10    sto, 10   = -10       -10     BS
ok, 10    sto, 13   = -10       -10     BS
ok, 13    sto, 10   = -13       -13     BS
*/
  // Stack(aTyp, aAdrNr, aVert, aAufArt, aWGr, aArtNr, aGuete, aKst, aWertW1, aStk, aGew, aMenge, aMEH);

  // BESTELLEINGANG ---------------------------------------------------------------------------
  if (aOhneEingang=false) then begin
    vKonto1b  # vKonto1a + 'EINGANG';
    vKonto2b  # vKonto2a + 'EINGANG';

    vStk1     # a501->"Ein.P.Stückzahl";
    vGew1     # a501->Ein.P.Gewicht;
    vMenge1   # a501->Ein.P.Menge;
    vWert1    # a501->Ein.P.Gesamtpreis;
    vWert1    # Rnd(vWert1 / vKurs1,2)

    vStk2     # "Ein.P.Stückzahl";
    vGew2     # Ein.P.Gewicht;
    vMenge2   # Ein.P.Menge;
    vWert2    # ein.P.Gesamtpreis;
    vWert2    # Rnd(vWert2 / vKurs2,2)

    vDifStk   # vStk2 - vStk1;
    vDifGew   # vGew2 - vGew1;
    vDifMenge # vMenge2 - vMenge1;
    vDifWert  # vWert2 - vWert1;
    vDif # (vDifStk<>0) or (vDifGew<>0.0) or (vDifMenge<>0.0) or (vDifWert<>0.0);

//debugx('Statistik EKdif:'+anum(vDifGew,0)+'kg, typ='+vTyp);
  //debugx('ein_P:'+vtyp+' '+vKonto1b+' -> '+vKonto2b);

    // Konten:
    //  Erfasst(+), Storniert(-) und Summe

    case vTyp of

      '-G' : begin
        if (aDat<>0.0.0) then begin
          OSt_Data:Stack('+', '+'+vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
        end;
      end;

      '-B' : begin  // neu erfasst
        OSt_Data:Stack('+', '+'+vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
        OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
      end;

      'GB', 'BB' : begin  // (wie) verändert mit ggf. Umbuchung
        if (vUmbuchen) then begin
          OSt_Data:Stack('-', '+'+vKonto1b, vVorgang, vAdr1, 0, a501->Ein.P.Auftragsart, a501->Ein.P.Warengruppe, a501->Ein.P.Artikelnr, a501->"Ein.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a501->Ein.P.MEH);
          OSt_Data:Stack('-', vKonto1b, vVorgang, vAdr1, 0, a501->Ein.P.Auftragsart, a501->Ein.P.Warengruppe, a501->Ein.P.Artikelnr, a501->"Ein.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a501->Ein.P.MEH);

          OSt_Data:Stack('+', '+'+vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
        end
        else begin
          if (vDif) then begin
            OSt_Data:Stack('', '+'+vKonto1b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Ein.P.MEH);
            OSt_Data:Stack('', vKonto1b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Ein.P.MEH);
          end;
        end
      end;

      'BS' : begin  // stornieren = Ursprungsmengen entfernen
        OSt_Data:Stack('+', '-'+vKonto1b, vVorgang, vAdr1, 0, a501->Ein.P.Auftragsart, a501->Ein.P.Warengruppe, a501->Ein.P.Artikelnr, a501->"Ein.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a501->Ein.P.MEH);
        OSt_Data:Stack('', vKonto1b, vVorgang, vAdr1, 0, a501->Ein.P.Auftragsart, a501->Ein.P.Warengruppe, a501->Ein.P.Artikelnr, a501->"Ein.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a501->Ein.P.MEH);
      end;

      'SB' : begin  // von Storno zurückholen
        OSt_Data:Stack('-', '-'+vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
        OSt_Data:Stack('', vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
      end;

    end;
  end;  // EINGANG



  // BESTELLBESTAND ---------------------------------------------------------------------------
  if (aOhneBestand=false) then begin
    vKonto1b  # vKonto1a + 'BESTAND';
    vKonto2b  # vKonto2a + 'BESTAND';

    vStk1   # a501->Ein.P.FM.Rest.Stk;
    if (a501->Ein.P.MEH='kg') then
      vGew1 # a501->Ein.P.FM.Rest;
    else if (a501->Ein.P.MEH='t') then
      vGew1 # a501->Ein.P.FM.Rest * 1000.0
    else
      vGew1 # 0.0;
    vMenge1 # a501->Ein.P.FM.Rest;;
    vWert1  # Lib_Berechnungen:Dreisatz(a501->Ein.P.Gesamtpreis, a501->Ein.P.Menge, vMenge1);
    vWert1  # Rnd(vWert1 / vKurs1,2)

    vStk2   # Ein.P.FM.Rest.Stk;
    if (Ein.P.MEH='kg') then
      vGew2 # Ein.P.FM.Rest;
    else if (Ein.P.MEH='t') then
      vGew2 # Ein.P.FM.Rest * 1000.0
    else
      vGew2 # 0.0;
    vMenge2 # Ein.P.FM.Rest;
    vWert2  # Lib_Berechnungen:Dreisatz(Ein.P.Gesamtpreis, Ein.P.Menge, vMenge2);
    vWert2  # Rnd(vWert2 / vKurs2,2)

    vDifStk   # vStk2 - vStk1;
    vDifGew   # vGew2 - vGew1;
    vDifMenge # vMenge2 - vMenge1;
    vDifWert  # vWert2 - vWert1;
    vDif # (vDifStk<>0) or (vDifGew<>0.0) or (vDifMenge<>0.0) or (vDifWert<>0.0);

//debugx('Statistik EKdif:'+anum(vDifGew,0)+'kg, typ='+vTyp);
    case vTyp of
      '-B', 'GB','SB' : begin  // (wie) neu erfasst
        OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
      end;

      'BB' : begin  //  verändert mit ggf. Umbuchung
        if (vUmbuchen) then begin
          OSt_Data:Stack('-', vKonto1b, vVorgang, vAdr1, 0, a501->Ein.P.Auftragsart, a501->Ein.P.Warengruppe, a501->Ein.P.Artikelnr, a501->"Ein.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a501->Ein.P.MEH);
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Ein.P.MEH);
        end
        else begin
          if (vDif) then
            OSt_Data:Stack('', vKonto1b, vVorgang, vAdr2, 0, Ein.P.Auftragsart, Ein.P.Warengruppe, Ein.P.Artikelnr, "Ein.P.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Ein.P.MEH);
        end
      end;

      'GS', 'SG' : todox('');

      'BG', 'BS' : begin  // stornieren = Ursprungsmengen entfernen
        OSt_Data:Stack('-', vKonto1b, vVorgang, vAdr1, 0, a501->Ein.P.Auftragsart, a501->Ein.P.Warengruppe, a501->Ein.P.Artikelnr, a501->"Ein.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a501->Ein.P.MEH);
      end;

    end;
  end; // BESTAND


  if (vLocal500) then RecBufDestroy(a500);
  if (vLocal501) then RecBufDestroy(a501);

//debug('');

end;


//========================================================================
//  CopyMatToPos
//========================================================================
Sub CopyMatToPos(opt aNoVis : logic);
local begin
  Erx : int;
end;
begin
//    Ein.P.KundenArtNr     # '';
  Ein.P.VpgText1        # '';
  Ein.P.VpgText2        # '';
  Ein.P.VpgText3        # '';
  Ein.P.VpgText4        # '';
  Ein.P.VpgText5        # '';
  Ein.P.VpgText6        # '';
  "Ein.P.Güte"          # "Mat.Güte";
  "Ein.P.Gütenstufe"    # "Mat.Gütenstufe";

  Ein.P.Werkstoffnr     # MQu_data:GetWerkstoffnr("Ein.P.Güte");

  // 25.06.2012 AI
  Ein.P.Warengruppe     # Mat.Warengruppe;
  Erx # RecLink(819,501,1,_RecFirst);   // Warengruppe holen
  Ein_Data:SetWgrDateinr(Wgr.Dateinummer, aNoVis);

  Ein.P.AusfOben        # "Mat.AusführungOben";
  Ein.P.AusfUnten       # "Mat.AusführungUnten";
  Ein.P.Dicke           # Mat.Dicke;
  Ein.P.DickenTol       # Mat.DickenTol;
  Ein.P.Breite          # Mat.Breite;
  Ein.P.BreitenTol      # Mat.BreitenTol;
  "Ein.P.Länge"         # "Mat.Länge";
  "Ein.P.LängenTol"     # "Mat.LängenTol";
  Ein.P.RID             # Mat.RID;
  Ein.P.RIDmax          # Mat.RID;
  Ein.P.RAD             # Mat.RAD;
  Ein.P.RADmax          # Mat.RAD;
  Ein.P.Zeugnisart      # Mat.Zeugnisart;
  Ein.P.AbbindungL      # Mat.AbbindungL;
  Ein.P.AbbindungQ      # Mat.AbbindungQ;
  Ein.P.Zwischenlage    # Mat.Zwischenlage;
  Ein.P.Unterlage       # Mat.Unterlage;
  Ein.P.Umverpackung    # Mat.Umverpackung;
  Ein.P.Wicklung        # Mat.Wicklung;
//    Ein.P.MitLfEYN        # Mat.MitLfEYN;
  Ein.P.StehendYN       # Mat.StehendYN;
  Ein.P.LiegendYN       # Mat.LiegendYN;
  Ein.P.Nettoabzug      # Mat.Nettoabzug;
  "Ein.P.Stapelhöhe"    # "Mat.Stapelhöhe";
  Ein.P.StapelhAbzug    # "Mat.StapelhöhenAbzug";
  Ein.P.RingKgVon       # 0.0;
  Ein.P.RingKgBis       # 0.0;
  Ein.P.KgmmVon         # Mat.Kgmm;
  Ein.P.KgmmBis         # Mat.Kgmm;
  "Ein.P.StückProVE"      # 0;
  Ein.P.VEkgMax         # 0.0;
  Ein.P.RechtwinkMax    # Mat.Rechtwinkligkeit;
  Ein.P.EbenheitMax     # Mat.Ebenheit;
  "Ein.P.SäbeligkeitMax" # "Mat.Säbeligkeit";
  "Ein.P.SäbelProM"     # "Mat.SäbelProM";
  Ein.P.Etikettentyp    # 0;
  Ein.P.Verwiegungsart  # Mat.Verwiegungsart;
  Ein.P.Intrastatnr     # Mat.Intrastatnr;

  Ein.P.Gewicht         # Mat.Bestand.Gew;
  "Ein.P.Stückzahl"     # Mat.Bestand.Stk;
  Ein.P.MEH             # 'kg';
  Ein.P.MEH.Wunsch      # 'kg';
  Ein.P.Menge           # Ein.P.Gewicht;

  Ein.P.Materialnr      # 0;

  Ein.P.Materialnr      # Mat.Nummer;

  Ein.P.Erzeuger        # Mat.Erzeuger;

  // Ausführugen löschen & kopieren
  WHILE (RecLink(502,501,12,_recFirst)=_rOK) do
    RekDelete(502,0,'MAN');

  Erx # RecLink(201,200,11,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Ein.AF.Nummer       # Ein.P.Nummer;
    Ein.AF.Position     # Ein.P.Position;
    Ein.AF.Seite        # Mat.AF.Seite;
    Ein.AF.lfdNr        # Mat.AF.lfdNr;
    Ein.AF.ObfNr        # Mat.AF.ObfNr;
    Ein.AF.Bezeichnung  # Mat.AF.Bezeichnung;
    Ein.AF.Zusatz       # Mat.AF.Zusatz;
    Ein.AF.Bemerkung    # Mat.AF.Bemerkung;
    "Ein.AF.Kürzel"     # "Mat.AF.Kürzel";
    RekInsert(502,0,'MAN');
    Erx # RecLink(201,200,11,_recNext);
  END;

  Ein.P.Auftragsart   # Set.Ein.Auftragsart;

  RunAFX('Ein.P.AusMaterial.Post','');
end;


//========================================================================
// SelEinNr
//          Selektiert nur diese Bestellnummer
//========================================================================
sub SelEinNr();
local begin
  Erx : int;
end;
begin

  if (gZLList=0) then RETURN;

  if (gZLList->wpdbselection<>0) then begin
    if (w_AktiverFilter='EinNr') then begin
      if (Sel_Main:Filter_Stop(gZLList->wpdbrecid)) then RETURN;
    end
    else begin
      gZLList->wpAutoUpdate # false;
      Sel_Main:Filter_Stop(gZLList->wpdbrecid);
    end;
  end;

  Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
  if (Erx>_rLocked) then RETURN;

  Ein_P_Mark_Sel:DefaultSelection();
  Sel.Auf.Von.Nummer     # Ein.P.Nummer;
  Sel.Auf.bis.Nummer     # Ein.P.Nummer;

  Ein_P_Mark_Sel:StartSel('EinNr', w_selName);
  gZLList->wpAutoUpdate # true;
end;


//========================================================================
// SelAbruf
//          Selektiert nur Abrufe des Liefervertrages
//========================================================================
sub SelAbruf();
local begin
  Erx : int;
end;
begin

  if (gZLList=0) then RETURN;

  if (gZLList->wpdbselection<>0) then begin
    if (w_AktiverFilter='Abruf') then begin
      if (Sel_Main:Filter_Stop(gZLList->wpdbrecid)) then RETURN;
    end
    else begin
      gZLList->wpAutoUpdate # false;
      Sel_Main:Filter_Stop(gZLList->wpdbrecid);
    end;
  end;

  Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
  if (Erx>_rLocked) then RETURN;

  Ein_P_Mark_Sel:DefaultSelection();
  Sel.Auf.NurRahmen       # Ein.P.Nummer;
  Sel.Auf.NurRahmenPos    # Ein.P.Position;
  Ein_P_Mark_Sel:StartSel('Abruf', w_SelName);
  gZLList->wpAutoUpdate # true;
end;


//========================================================================
// 2020-06-21 AH
//      Berechnet das Positionsgewicht über diverse Formeln
//========================================================================
sub CalcGewicht() : float;
local begin
  vDich : float;
  vX    : float;
  vGew  : float;
end;
begin

  // über Konvertierung ???  -> wäre bei Artikel?
//  vGew # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", 0.0, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, 'kg');
//  if (vGew<>0.0) then RETURN vGew;

  // über DxBxL ???
  vGew # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.P.Stückzahl", Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
  if (vGew<>0.0) then RETURN vGew;


  // über Zylinderformeln ???
  RekLink(819,501,1,0);   // Warengruppe holen
  vDich # Wgr_Data:GetDichte(Wgr.Nummer, 401);

  if (Wgr.Materialtyp='ST') then begin
    vGew #  Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD("Ein.P.Stückzahl", "Ein.P.Länge", vDich, 0.0, Auf.P.RAD);
  end
  else if (Wgr.Materialtyp='RO') then begin
    vGew #  Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD("Ein.P.Stückzahl", "Ein.P.Länge", vDich, Ein.P.RID, Ein.P.RAD);
  end
  else if (Wgr.Materialtyp='RONDE') then begin
    vGew #  Lib_Berechnungen:kg_aus_StkDAdDichte2("Ein.P.Stückzahl", Ein.P.Dicke, Ein.P.RAD, vDich, 0.0);
  end
  else if (Wgr.Materialtyp='FR') then begin
    vGew #  Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD("Ein.P.Stückzahl", "Ein.P.Dicke", vDich, Ein.P.RID, Ein.P.RAD);
  end
  else if (Wgr.Materialtyp='TA') then begin   // 2022-08-25 AH
    vGew #  Lib_Berechnungen:kg_aus_StkDBLDichte2("Ein.P.Stückzahl", "Ein.P.Dicke", Ein.P.Breite, "Ein.P.Länge", Wgr.Dichte, "Wgr.TränenKgProQM");
  end;

  RETURN vGew;
end;

//========================================================================