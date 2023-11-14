@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_Inv_Subs
//                  OHNE E_R_G
//  Info
//    Im Art-Lagerjournal werden Invetureinträge im ABSOLUT eingetragen, egal ob die Charge Differenzen hatte oder
//    sogar komplett fehlte (kenntlich im Journal durch den Haken "ARt.InventurYN")
//    Im Mat-Bestandsbuch werden Inventureinträge immer RELATIV d.h. als DIFFERENZ eingetragen. (also Plus X oder Minus X)
//
//
//  11.11.2015  AH  Erstellung der Prozedur
//  28.11.2016  ST  BugFix "_Loesche_verlorene_Material",m RecLock(200 eingebaut
//  14.08.2017  AH  "Uebernahme_PuresMat"
//  09.10.2017  AH  Einträge ohne Menge/Stück werden als NICHT vorhanden angesehen
//  09.11.2017  AH  Inventurübernahme setzt auch Datum+LAgerplatz in Einsatzkarten, wenn Restkarte in Inventur ist
//  03.01.2018  AH  AFX: "Art.Inv.Uebernahme.Einzel.Mat"
//  15.05.2019  ST  AFX: "Art.Inv.Loesche.MatOhneInv" hinzugefügt
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//  SUB Uebernehme_Einzel(aDat : date) : logic;
//  SUB Uebernehme_Alle(aDat : date) : logic;
//  SUB Uebernehme_PuresMat(aDat : date) : logic;
//  SUB Loesche_Verlorene(aDat : date) : logic
//  SUB Loesche_verlorene_PuresMat(aDat : date) : logic
//
//  SUB InvEkFromDEK() : logic;
//  SUB InvEkProz() : logic;
//  SUB InvEktoDEK() : logic;
//
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen


//========================================================================
//  _Uebernehme_Charge
//
//========================================================================
sub _Uebernehme_Charge(
  aArt    : alpha;
  aCharge : alpha;
  aAdr    : int;
  aAnsch  : int;
  aPlatz  : alpha;
  aStk    : int;
  aMenge  : float;
  aDat    : date;
) : logic;
local begin
  Erx     : int;
  vDat    : date;
end;
begin

  if (aDat=0.0.0) then RETURN false;

  // Artikel holen...
  RecBufClear(250);
  Art.Nummer # aArt;
  RecRead(250,1,0);

  if (aCharge='') then RETURN false;
  if (Art.MEH='Stk') then aMenge # cnvfi(aStk);

  // Charge holen...
  if (aCharge<>'') then begin
    RecBufClear(252);
    Art.C.ArtikelNr     # aArt;
    Art.C.Charge.Intern # aCharge;
    Erx # RecRead(252,1,0);
    if (Erx>_rLocked) then RETURN false;
  end
  else begin
/*
    // eigene Lagercharge finden...
    RecBufClear(252);
    Art.C.Artikelnr     # aArt;
    Art.C.AdressNr      # aAdr;
    Art.C.AnschriftNr   # aAnsch;
    Art.C.Lagerplatz    # '';
    Art_Data:FindeCharge();
    if (Art_Data:OpenCharge(y,aDat)=false) then RETURN false;
//    Art.C.Eingangsdatum # aDat;
    Art.C.Bestand       # aMenge;
    Art.C.Bestand.Stk   # aStk;
    Erx # Art_Data:WriteCharge(n);
    if (Erx<>_ROK) then RETURN false;
*/
  end;


  // Journal anlegen......
  RecBufClear(253);
  Art.J.ArtikelNr     # Art.C.Artikelnr;
  Art.J.Adressnr      # Art.C.Adressnr;
  Art.J.Anschriftnr   # Art.C.AnschriftNr;
  Art.J.Charge        # Art.C.Charge.Intern;
  Art.J.Charge.Extern # Art.C.Charge.Extern;
  Art.J.lfdNr         # 10000;
  Art.J.Anlage.Datum  # Today;
  Art.J.Anlage.Zeit   # now;
  Art.J.Anlage.User   # gUserName;
  "Art.J.Trägertyp"   # 'INV';

  Art.J.Datum         # aDat;
  Art.J.Menge         # aMenge
  "Art.J.Stückzahl"   # aStk;
  Art.J.Bemerkung     # Translate('Inventur');
  Art.J.InventurYN    # y;
  REPEAT
    Erx # RekInsert(253,0,'');
    if (Erx<>_rOK) then Art.J.lfdNr # Art.J.lfdNr + 1;
  UNTIL (Erx=_rOK);


  // spätere Journale berücksichtigen...
  FOR Erx # RecLink(253,250,5,_recNext)   // Journal loopen
  LOOP Erx # RecLink(253,250,5,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Art.J.InventurYN) then RETURN false;

    if (Art.J.Charge=aCharge) then begin
      aMenge  # aMenge  + Art.J.Menge;
      aStk    # aStk    + "Art.J.Stückzahl"
    end;
  END;


  // Charge verändern...
  Erx # RecRead(252,1,_recLock);
  Art.C.Bestand       # aMenge;
  Art.C.Bestand.Stk   # aStk;
  Art.C.Inventurdatum # aDat;
  if (aPlatz<>'') then
    Art.C.Lagerplatz  # aPlatz;
//debug('set c:'+art.c.charge.intern+'  M:'+anum(Art.C.Bestand,0)+'  S:'+aint(art.c.Bestand.Stk));
  //RekReplace(252,_recUnlock,'MAN');

  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
  if (Wgr.OhneBestandYN=false) then begin
    if (Art.C.Bestand=0.0) and (Art.C.Bestellt=0.0) and (Art.C.Reserviert=0.0) then begin
      if (Art.C.Ausgangsdatum=0.0.0) then Art.C.Ausgangsdatum # today;
    end
    else begin
      if (Art.C.Ausgangsdatum<>0.0.0) then Art.C.Ausgangsdatum # 0.0.0;
    end;
  end;

  Erx # Art_Data:WriteCharge(n,'MAN');


  // nur Gesamtsumme...
// macht Überprozedur schon
//  RecBufClear(252);
//  Art.C.ArtikelNr     # aArt;
//  Art.C.Charge.Intern # '';
//  if (Erx<>_rOk) then Msg(0,'Artikelsumme nicht angelegt!',0,0,0);
//  Erx # RecRead(252,1,0);
//  if (Erx<=_rLocked) then Art_Data:ChargenQuersumme();

  RETURN true;
end;


//========================================================================
//  _Uebernehme_Einzel_Chargen
//
//========================================================================
sub _Uebernehme_Einzel_Chargen(aDat : date) : logic;
local begin
  Erx     : int;
  vArt    : alpha;
  vCharge : alpha;
  vStk    : int;
  vMenge  : float;
  vExist  : logic;
  vAdr    : int;
  vAnsch  : int;
  vPlatz  : alpha;
  vFehlte : logic;
end;
begin
  vArt    # Art.Nummer;

  TRANSON;

  // Echte Cahrgenartikel?
  if ("Art.ChargenführungYN") then begin
    FOR Erx # RecLink(259,250,21,_recFirst)     // Inventur loopen
    LOOP Erx # RecLink(259,250,21,_recnext)
    WHILE (Erx<=_rLocked) do begin
      if (Art.Inv.Charge.Int='') then begin
        Error(99,'Keine konkrete Charge angegeben in Inventursatz '+aint(Art.Inv.Nummer));
        TRANSBRK;
        RETURN false;
      end;
    END;
  end
  else begin
    // Alle LEER-Chargen auf neue setzen
    FOR Erx # RecLink(259,250,21,_recFirst)     // Inventur loopen
    LOOP Erx # RecLink(259,250,21,_recnext)
    WHILE (Erx<=_rLocked) do begin

      if (Art.Inv.Charge.Int<>'') then CYCLE;

      if (vCharge='') then begin
        // eigene Lagercharge finden...
        RecBufClear(252);
        Art.C.Artikelnr     # Art.Inv.Artikelnr;
        Art.C.AdressNr      # Art.Inv.AdressNr;
        Art.C.AnschriftNr   # Art.Inv.Anschrift;
        Art.C.Lagerplatz    # '';
        Art_Data:FindeCharge();
        if (Art_Data:OpenCharge(n,aDat)=false) then begin
          TRANSBRK;
          Error(99,'Fehler 12 in Inventursatz '+aint(Art.Inv.Nummer));
          RETURN false;
        end;
        vCharge # Art.C.Charge.Intern;
      end;
      RecRead(259,1,_recLock);
      Art.Inv.Charge.Int # vCharge;
      RekReplace(259,_RecUnlock,'AUTO');
    END;
  end;


  vExist # n;
  FOR Erx # RecLink(259,250,21,_recFirst)     // Inventur loopen nach CHARGEN sortiert !!!
  LOOP Erx # RecLink(259,250,21,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (vExist=n) then begin
      vCharge # Art.Inv.Charge.Int;
      vAdr    # Art.Inv.Adressnr;
      vAnsch  # Art.Inv.Anschrift;
      vPlatz  # Art.Inv.Lagerplatz;
      vFehlte # Art.Inv.ChargeFehlte;
      vExist  # y;
    end;

    Erx # RecRead(259,1,_RecLock);
    Art.Inv.Datum # aDat
    RekReplace(259);

    if (Art.Inv.Charge.Int<>vCharge) then begin

      // Basischarge suchen...
      if (vCharge='') then begin
        if ("Art.ChargenführungYN") then begin
          TRANSBRK;
          Error(99,'Fehler 13 in Inventursatz '+aint(Art.Inv.Nummer));
          RETURN false;
        end;
      end;

      // Summe übernehmen
      if (_Uebernehme_Charge(vArt, vCharge, vAdr, vAnsch, vPlatz, vStk, vMenge, aDat)=false) then begin
        TRANSBRK;
        RETURN false;
      end;

      vStk    # 0;
      vMenge  # 0.0;
      vCharge # Art.Inv.Charge.Int;
      vAdr    # Art.Inv.Adressnr;
      vAnsch  # Art.Inv.Anschrift;
      vPlatz  # Art.Inv.Lagerplatz;
      vFehlte # Art.Inv.ChargeFehlte;
    end;

    vMenge  # vMenge  + Art.Inv.Menge;
    vStk    # vStk    + "Art.Inv.Stückzahl";
  END;


  if (vExist) then begin
    // Summe übernehmen
    if (_Uebernehme_Charge(vArt, vCharge, vAdr, vAnsch, vPlatz, vStk, vMenge, aDat)=false) then begin
      TRANSBRK;
      Error(99,'Fehler 14 in Inventursatz '+aint(Art.Inv.Nummer));
      RETURN false;
    end;
  end;


  // Gesamtsumme speichern...
  Art_Data:RecalcSumCharge();
  RecRead(252,1,_RecLock);
  Art.C.Inventurdatum # aDat;
  RekReplace(252,_recunlock,'AUTO');


  // Artikel anpassen...
  RecRead(250,1,_recLock);
  Art.Inventurdatum     # aDat;
  Erx # RekReplace(250,0,'AUTO');
  if (Erx <> _rOK) then begin
    TRANSBRK;
    Error(99,'Fehler 15 bei Artikel '+Art.Nummer);
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  _Uebernehme_Einzel_Material
//
//========================================================================
sub _Uebernehme_Einzel_Material(aDat : date) : logic;
local begin
  Erx     : int;
  vArt    : alpha;
  vGew    : float;
  vFak    : float;
  v259    : int;
end;
begin

  // SFX:
  if (RunAFX('Art.Inv.Uebernahme.Einzel.Mat',cnvad(aDat))<>0) then begin
    RETURN (AfxRes=_rOK);
  end;

  vArt    # Art.Nummer;

  TRANSON;

  v259 # RekSave(259);

  FOR Erx # RecLink(259,250,21,_recFirst)     // Inventur loopen
  LOOP Erx # RecLink(259,250,21,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 09.10.2017 AH:
    if (Art.Inv.Menge<=0.0) and ("Art.Inv.Stückzahl"<=0) then
      CYCLE;

    if (Art.Inv.Materialnr=0) then begin
      TRANSBRK;
      RekRestore(v259);
      Error(99,'Keine Materialnummer in Inventursatz '+aint(Art.Inv.Nummer));
      RETURN false;
    end;

    Erx # RecLink(200,259,5,_recFirst);       // Mateiral holen
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Material "'+Aint(Art.Inv.Materialnr)+'" konnte nicht gelesen werden!');
      RekRestore(v259);
      RETURN false;
    end;
    if ("Mat.Löschmarker" <> '') then begin
      TRANSBRK;
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Material "'+Aint(Art.Inv.Materialnr)+'" bereits gelöscht!');
      RekRestore(v259);
      RETURN false;
    end;
    if (Mat.Status>=c_status_bestellt) and (Mat.Status<=c_status_bisEK) then begin
      TRANSBRK;
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Material "'+Aint(Art.Inv.Materialnr)+'" hat falschen Status!');
      RekRestore(v259);
      RETURN false;
    end;

    // Gewicht anteilig errechnen...
    if (Mat.Bestand.Menge<>0.0) then begin
      vFak # (Art.Inv.Menge / Mat.Bestand.Menge);
      vGew # Rnd(Mat.Bestand.Gew * vFak, Set.Stellen.Gewicht);
    end
    else if (Mat.Bestand.Stk<>0) then begin
      vFak # cnvfi("Art.Inv.Stückzahl" / Mat.Bestand.Stk)
      vGew # Rnd(Mat.Bestand.Gew * vFak, Set.Stellen.Gewicht);
    end
    else begin
      if (Art.Nummer<>'') then
        vGew # Lib_Einheiten:WandleMEH(250, "Art.Inv.Stückzahl", 0.0, Art.Inv.Menge, Art.Inv.MEH, 'kg')
      else
        vGew # Lib_Einheiten:WandleMEH(200, "Art.Inv.Stückzahl", 0.0, Art.Inv.Menge, Art.Inv.MEH, 'kg');
    end;

    if (Mat_Data:SetInventur(Mat.Nummer, Art.Inv.Lagerplatz, aDat, true, "Art.Inv.Stückzahl", vGew, Art.Inv.Menge, Art.Inv.ChargeFehlte, 259)=false) then begin
      TRANSBRK;
      Error(99, 'Inventursatz '+aint(Art.Inv.Nummer)+': Fehler 22');
      RekRestore(v259);
      RETURN false;
    end;

    // 09.11.2017 AH: Wenn "Restkarte", dann auch Einsatzkarte aufnehmen
    if (Mat.Status>=700) and (Mat.Status<=749) and ("Mat.Vorgänger"<>0) then begin
      Mat.Nummer # "Mat.Vorgänger";
      Erx # RecRead(200,1,0);
      if (Erx<=_rLocked) then begin
        // Aktionen loopen...
        FOR Erx # RecLink(204,200,14,_recFirst)
        LOOP Erx # RecLink(204,200,14,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Mat.A.Entstanden=Art.Inv.Materialnr) and (Mat.A.Aktionstyp=c_Akt_BA_Rest) then begin
            Erx # RecRead(200,1,_recLock);
            Mat.Lagerplatz    # Art.Inv.Lagerplatz;
            Mat.InventurDatum # aDat;
            RekReplace(200);
            BREAK;
          end;
        END;
      end;
    end;

  END;

  RekRestore(v259);

  TRANSOFF; // 20.11.2017 AH

  RETURN true;
end;


//========================================================================
//  Uebernehme_Einzel
//
//========================================================================
sub Uebernehme_Einzel(aDat : date) : logic;
local begin
  Erx : int;
end;
begin

  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
  if (Wgr_Data:IstMix()) then RETURN _Uebernehme_Einzel_Material(aDat);

  RETURN _Uebernehme_Einzel_Chargen(aDat);
end;


//========================================================================
//  Uebernehme_Alle
//
//========================================================================
sub Uebernehme_Alle(aDat : date) : logic;
local begin
  Erx     : int;
  vBuf250 : int;
end;
begin

  vBuf250 # RekSave(250);

  TRANSON;

  FOR Erx # RecRead(250,1,_recFirst)
  LOOP Erx # RecRead(250,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Uebernehme_Einzel(aDat)=false) then begin
      TRANSBRK;
      RekRestore(vBuf250);
      RETURN false;
    end;

  END;

  TRANSOFF;

  RekRestore(vBuf250);

  RETURN true;
end;


//========================================================================
//  sub Uebernehme_PuresMat
//
//========================================================================
sub Uebernehme_PuresMat(aDat : date) : logic;
local begin
  vBuf250 : int;
end;
begin

  vBuf250 # RekSave(250);

  RecBufClear(250);   // Material hat KEINEN Artikel

//  TRANSON;

  if (_Uebernehme_Einzel_Material(aDat)=false) then begin
//    TRANSBRK;
    RekRestore(vBuf250);
    RETURN false;
  end;

//  TRANSOFF;

  RekRestore(vBuf250);

  RETURN true;
end;


//========================================================================
//  _Loesche_verlorene_Chargen
//
//========================================================================
sub _Loesche_verlorene_Chargen(
  aBisDat   : date ) : logic;
//  opt aDat  : date) : logic;
local begin
  Erx     : int;
  vOK       : logic;
  vErgArt   : int;
  vMax      : int;
  vProgress : handle; // Handle für Fortschrittsbalken
end;
begin

//  if (aDat=0.0.00) then aDat # aBisDat;

  vMax # RecInfo(250,_RecCount);
  vProgress # Lib_Progress:Init('Bereinige Chargen ohne Inventur', vMax);

  TRANSON;

  FOR     vErgArt # RecRead(250,1,_recFirst);
  LOOP    vErgArt # RecRead(250,1,_recNext);
  WHILE ( vErgArt <=_rLocked) do begin

    if (!vProgress->Lib_Progress:Step()) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      RETURN false;
    end;

    FOR Erx # RecLink(252,250,4,_recFirst)    // Chargen loopen
    LOOP Erx # RecLink(252,250,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      // Inventurdatum passt? -> nächste Charge
      if (Art.C.Adressnr=0) or
        (Art.C.Inventurdatum>=aBisDat) or (Art.C.Ausgangsdatum<>0.0.0) then CYCLE;

      // Sammelchargen überspringen...
// ST 2011-30-12: Alle Chargen egal, ob Chargenführung an (Basischarge) laut UB
/*
      if ("Art.ChargenführungYN") and (Art.C.Charge.Intern='') then begin
        Erx # RecLink(252,250,4,_recNext);
        CYCLE;
      end;
      if (Art.C.Adressnr=0) or (Art.C.Anschriftnr=0) then begin
        Erx # RecLink(252,250,4,_recNext);
        CYCLE;
      end;
*/

      // Kommissionierte oder Gelöschte überspringen...
      if (Art.C.Kommission<>'') or (Art.C.Ausgangsdatum<>0.0.0) then CYCLE;

      // Bestellte, Reservierte überspringen...
      if (Art.C.OffeneAuf<>0.0) or (Art.C.Reserviert<>0.0) or (Art.C.Bestellt<>0.0) then CYCLE;


      // Artikelbewegung, damit löschen
      RecBufClear(253);
      Art.J.Datum           # aBisDat;
      Art.J.Bemerkung       # Translate('Inventur');
      Art.J.Charge          # Art.C.Charge.Intern;
      "Art.J.Stückzahl"     # -Art.C.Bestand.Stk;
      Art.J.Menge           # -Art.C.Bestand;
      "Art.J.Trägertyp"     # 'INV';
      vOK # Art_Data:Bewegung(0.0, 0.0);
      if (vOK=false) then begin
        TRANSBRK;
        vProgress->Lib_Progress:Term();
        ErrorOutput;
        RETURN false;
      end;

    END;

  END;

  TRANSOFF;

  vProgress->Lib_Progress:Term();


  RETURN true;
end;


//========================================================================
//========================================================================
sub _Loesche_Verlorenes_Mat_Inner(
  aDat    : date;
  aMitArt : logic) : logic;
local begin
  Erx : int;
end;
begin

  if ("Mat.Löschmarker"<>'') then RETURN true;
  if (Mat.VK.Rechnr<>0) then RETURN true;

  if (Wgr.Nummer<>Mat.Warengruppe) then begin
    Erx # RekLink(819,200,1,_recFirst);     // Warengruppe holen
    if (Erx>_rLocked) then RETURN false;
  end;

  // kein Artikel zugehörig?
  if (aMitArt) then begin
    if (Wgr_Data:IstMix()=false) then RETURN true;

    if (Art.Nummer<>Mat.Strukturnr) then begin
      Erx # RekLink(250,200,26,_recFirst);    // Artikel holen
      if (Erx>_rLocked) then RETURN False;
    end;
  end;


  // ggf. Reservierungen löschen...
  WHILE (RecLink(203,200,13,_recfirst)<=_rLocked) do begin
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      TRANSBRK;
      Error(99,'Reservierung nicht löschbar in Material '+aint(mat.Nummer));
      RETURN false;
    end;
  END;

  // ggf. Kommission entfernen
  if (Mat.Auftragsnr<>0) then begin
    if (Mat_Data:SetKommission(Mat.Nummer, 0,0,0 ,'MAN')<>0) then begin
      TRANSBRK;
      Error(99,'Reservierung nicht löschbar in Material '+aint(mat.Nummer));
      RETURN false;
    end;
    RunAFX('Mat.SetKommission','');
  end;

  RecRead(200,1,_RecLock);
  Mat_Data:SetLoeschmarker('*', Translate('Inventur')+' '+cnvad(aDat));
  Mat.Ausgangsdatum   # aDat;
  Mat_Data:Replace(_recunlock,'AUTO');

  RETURN true;
end;


//========================================================================
//  _Loesche_verlorene_Material
//========================================================================
sub _Loesche_verlorene_Material(
  aDat  : date) : logic;
local begin
  Erx       : int;
  vOK       : logic;
  vMax      : int;
  vProgress : handle; // Handle für Fortschrittsbalken

  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);
end;
begin

  // Material selektieren...
  vQ  # '';
  Lib_Sel:QDate(var vQ, '"Mat.Eingangsdatum"',  '>', 1.1.1950);
  Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"',   '=', '');
  Lib_Sel:QAlpha(var vQ, '"Mat.Strukturnr"',    '>', '');
  Lib_Sel:QDate(var vQ, '"Mat.Inventurdatum"',  '<', aDat);
  Lib_Sel:QFloat(var vQ, '"Mat.Bestellt.Gew"',  '=', 0.0);
  Lib_Sel:QLogic(var vQ, '"Mat.Inventur.DruckYN"', true);

  vSel # SelCreate(200, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vMax # RecInfo( 200, _recCount, vSel);
  vProgress # Lib_Progress:Init('Bereinige Material ohne Inventur', vMax);

  TRANSON;

  FOR Erx # RecRead(200,vSel, _recFirst);
  LOOP Erx # RecRead(200,vSel, _recNext);
  WHILE ( Erx <=_rLocked) do begin

    if (!vProgress->Lib_Progress:Step()) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      SelClose(vSel);
      SelDelete(200, vSelName);
      RETURN false;
    end;

    if (_Loesche_verlorenes_Mat_inner(aDat, y)=false) then begin
      vProgress->Lib_Progress:Term();
      SelClose(vSel);
      SelDelete(200, vSelName);
      RETURN false;
    end;

  END;

  TRANSOFF;

  vProgress->Lib_Progress:Term();

  SelClose(vSel);
  SelDelete(200, vSelName);

  RETURN true;
end;



//========================================================================
// Loesche_verlorene_PuresMat
//========================================================================
sub Loesche_verlorene_PuresMat(
  aDat  : date) : logic;
local begin
  Erx       : int;
  vOK       : logic;
  vMax      : int;
  vProgress : handle; // Handle für Fortschrittsbalken

  vSel        : int;
  vSelName    : alpha;
  vQ,vQ2      : alpha(4000);
end;
begin
  
  if (RunAFX('Art.Inv.Loesche.MatOhneInv',cnvad(aDat))<>0) then
    RETURN (AfxRes=_rOK);

  // Material selektieren...
  vQ  # '';
  Lib_Sel:QDate(var vQ, '"Mat.Eingangsdatum"',  '>', 1.1.1950);
  Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"',   '=', '');
  Lib_Sel:QDate(var vQ, '"Mat.Inventurdatum"',  '<', aDat);
  Lib_Sel:QFloat(var vQ, '"Mat.Bestellt.Gew"',  '=', 0.0);

  // oder REINES Material?
  vQ2 # '';
  Lib_Sel:QInt(var vQ2, '"Wgr.Dateinummer"',  '=', Wgr_Data:WertMaterial());


  vSel # SelCreate(200, 1);
  vSel->SelAddLink('',819, 200, 1, 'Wgr');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Wgr', vQ2);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vMax # RecInfo( 200, _recCount, vSel);
  vProgress # Lib_Progress:Init('Bereinige Material ohne Inventur', vMax);

  TRANSON;

  FOR Erx # RecRead(200,vSel, _recFirst);
  LOOP Erx # RecRead(200,vSel, _recNext);
  WHILE ( Erx <=_rLocked) do begin

    if (!vProgress->Lib_Progress:Step()) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      SelClose(vSel);
      SelDelete(200, vSelName);
      RETURN false;
    end;

    if (_Loesche_verlorenes_Mat_inner(aDat, false)=false) then begin  // FÜR MATERIAL
      vProgress->Lib_Progress:Term();
      SelClose(vSel);
      SelDelete(200, vSelName);
      RETURN false;
    end;

  END;

  TRANSOFF;

  vProgress->Lib_Progress:Term();

  SelClose(vSel);
  SelDelete(200, vSelName);

  RETURN true;
end;


//========================================================================
// Loesche_Verlorene
//========================================================================
sub Loesche_Verlorene(
  aDat   : date) : logic;
//  opt aDat  : date) : logic;
begin

//  if (Wgr.Nummer<>Art.Warengruppe) then
//    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
//  if (Wgr_Data:IstMix()) then RETURN _Loesche_Verlorene_Chargen(aDat);
//  RETURN _Loesche_Verlorene_Material(aDat);

  if (_Loesche_Verlorene_Chargen(aDat)=false) then RETURN false;
  if (_Loesche_Verlorene_Material(aDat)=false) then RETURN false;
  RETURN true;

end;


//========================================================================
// InvEkFromDEK
//========================================================================
sub InvEkFromDEK() : logic;
local begin
  Erx           : int;
  vInvPreis     : float;
  vInvPreisW1   : float;
  vText         : alpha;
end;
begin

  if (Msg(254005, '', 0, _WinDialogYesNo, 2) = _WinIdNo) then RETURN true;


  TRANSON; // Transaktion START!

  APPOFF();

  // ALLE Artikel loopen...
  FOR     Erx # RecRead(250,1,_recFirst)
  LOOP    Erx # RecRead(250,1,_recNext)
  WHILE ( Erx <=_rLocked) do begin

    if (Art_P_Data:LiesPreis('Ø-EK', 0) = false) then begin // DEK lesen
      vInvPreis   # 0.0;
      vInvPreisW1 # 0.0;
    end
    else begin
      vInvPreis   # Art.P.Preis;
      vInvPreisW1 # Art.P.PreisW1;
    end;


    if (Art_P_Data:LiesPreis('INVEK', 0)) then begin // Inv-EK lesen
      Erx # RecRead(254, 1, _recLock);
      if (Erx <> _rOK) then begin
        TRANSBRK;
        vText # Art.Nummer;
        APPON();
        Msg(254006,vText,0,0,0);
        RETURN false;
      end;

      // Felder belegen
      Art.P.Preis   # vInvPreis;
      Art.P.PreisW1 # vInvPreisW1;

      Erx # Art_P_Data:Replace(_recUnlock, 'MAN'); // Preis rückspeichern
      if (Erx <> _rOK) then begin
        TRANSBRK;
        vText # Art.Nummer;
        APPON();
        Msg(254006,vText,0,0,0);
        RETURN false;
      end;

    end
    else begin
      Art_P_Data:SetzePreis('INVEK', vInvPreisW1, 0);
    end;
  END;

  APPON();

  TRANSOFF; // Transaktion ENDE!

  Msg(999998,'',0,0,0);

  RETURN true;

end;


//========================================================================
//  InvEkProz
//========================================================================
sub InvEkProz() : logic;
local begin
  Erx           : int;
  vMarked       : int;        // Descriptor für den Marierungsbaum
  vMarkedItem   : int;        // Descriptor für markierten Eintrag
  vMFile        : int;
  vMID          : int;
  vText         : alpha(4000);
  vI            : int;
  vA            : alpha;
  vProz         : float;
end;
begin

  vMarked # gMarkList->CteRead(_CteFirst);

  vI # Lib_mark:Count(250);
  if (vI=0) then RETURN false;

  if (Dlg_Standard:menge(Translate('Änderung um Prozent (z.N. -10% oder +10%)'), var vProz, 0.0)=false) then RETURN true;
  if (vProz=0.0) then RETURN true;

  if (Msg(254007,aint(vI)+'|'+anum(vProz,2), _WinIcoQuestion, _WinDialogYesNo,0)<>_Winidyes) then RETURN true;

  AppOFF();

  TRANSON;

  // Markierung loopen
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);

    // Markierung nicht aus Artikel?
    if (vMFile <> 250) then CYCLE;

    // Artikel lesen
    Erx # RecRead(250, 0, _recId, vMID);
    if (Erx>_rLocked) then CYCLE;

    if(Art_P_Data:LiesPreis('INVEK', 0) = false) then begin // Inventur-EK lesen
      // kein InvEK? -> nächster
      CYCLE;
    end;

    Erx # RecRead(254, 1, _recLock); // Durchschnitts-EK sperren

    // Felder belegen
    Art.P.Preis   # Rnd((Art.P.Preis * (100.0 + vProz)) / 100.0 , 2);
    Art.P.PreisW1 # Rnd((Art.P.PreisW1 * (100.0 + vProz)) / 100.0 , 2);

    Erx # Art_P_Data:Replace(_recUnlock, 'MAN'); // Durchschnitts-EK zurueckspeichern
    if (Erx <> _rOK) then begin
      TRANSBRK;
      vText # Art.Nummer;
      APPON();
      Msg(254006,vText,0,0,0);
      RETURN false;
    end;
  END;

  APPON();

  TRANSOFF; // Transaktion ENDE!

  Msg(999998,'',0,0,0);

  RETURN true;

end;


//========================================================================
// InvEKtoDEK
//        Uebernimmt den Inventurpreis als Durchschnits EK
//========================================================================
sub InvEKtoDEK() : logic;
local begin
  Erx           : int;
  vMarked       : int;        // Descriptor für den Marierungsbaum
  vMarkedItem   : int;        // Descriptor für markierten Eintrag
  vMFile        : int;
  vMID          : int;
  vText         : alpha(4000);
  vInvPreis     : float;
  vInvPreisW1   : float;
end;
begin

  vMarked # gMarkList->CteRead(_CteFirst);

  if (Msg(254004, '', 0, _WinDialogYesNo, 2) = _WinIdNo) then RETURN true;

  TRANSON; // Transaktion START!

  APPOFF();

  // Markierung loopen
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
    // Markierung nicht aus Artikel?
    if (vMFile <> 250) then CYCLE;

    // Artikel lesen
    Erx # RecRead(250, 0, _recId, vMID);
    if (Erx > _rLocked) then RecBufClear(250);

    if (Art_P_Data:LiesPreis('INVEK', 0) = false) then begin // Inventur-EK lesen
      // kein InvEK? -> nächster
      CYCLE;
    end;

    vInvPreis   # Art.P.Preis;
    vInvPreisW1 # Art.P.PreisW1;

    if (Art_P_Data:LiesPreis('Ø-EK', 0)) then begin // Durchschnitts-EK lesen
      Erx # RecRead(254, 1, _recLock); // Durchschnitts-EK sperren

      // Felder belegen
      Art.P.Preis   # vInvPreis;
      Art.P.PreisW1 # vInvPreisW1;

      Erx # Art_P_Data:Replace(_recUnlock, 'MAN'); // Durchschnitts-EK zurueckspeichern
      if (Erx <> _rOK) then begin
        TRANSBRK;
        vText # Art.Nummer;
        APPON();
        Msg(254006,vText,0,0,0);
        RETURN false;
      end;

    end
    else begin
      // kein DurrchscnittEK? -> dann anlegen:
      Art_P_Data:SetzePreis('Ø-EK', vInvPreisW1, 0);
    end;

    if (Wgr.Nummer<>Art.Warengruppe) then
      Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen

    // falls es ein reiner Artikel ist und es Chargen zu diesem gibt
    // dann den Chargen Durchschnitts-EK auch aendern
    if (Wgr_Data:IstArt()) and
      (RecLinkInfo(252, 250, 4, _recCount) > 0) then begin

      FOR Erx # RecLink(252, 250, 4, _recFirst);
      LOOP Erx # RecLink(252, 250, 4, _recNext);
      WHILE(Erx <= _rLocked) DO BEGIN
        Erx # RecRead(252, 1, _recLock);

        Art.C.EKDurchschnitt # vInvPreisW1;

        Erx # RekReplace(252, _recUnlock, 'MAN'); // Durchschnitts-EK zurueckspeichern
        if (Erx <> _rOK) then begin
          TRANSBRK;
          vText # Art.Nummer;
          APPON();
          Msg(01011,Translate('Artikel')+' '+vText+'|'+Translate('Charge'),0,0,0);
          RETURN false;
        end;

      END;
    end;
  END;

  APPON();

  TRANSOFF; // Transaktion ENDE!

  Msg(999998,'',0,0,0);

  RETURN true;

end;


//========================================================================
// sfx call art_inv_subs:KUZ
//========================================================================
Sub KUZ();
local begin
  Erx     : int;
  vNr     : int;
end;
begin

  ADr.Nummer # 1;
  RecRead(100,1,0);
  RekLink(101,100,12,_RecFirst);

debugX('START');

//Lib_Debug:StartBLueMode();


  // MEH richtig setzen:
  FOR Erx # RecRead(259,1,_recFirst)
  LOOP Erx # RecRead(259,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Art.Inv.Artikelnr='') then begin
debugx('Kein Art bei KEY259');
CYCLE;
    end;
    Erx # RekLink(250,259,1,_recFirst);   // Artikel holen
    if (Art.MEH<>Art.Inv.MEH) then begin
      RecRead(259,1,_RecLock);
      Art.Inv.MEH # Art.MEH;
      RekReplace(259);
    end;
  END;


  TRANSON;


  FOR Erx # RecRead(259,1,_recFirst)
  LOOP Erx # RecRead(259,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Art.Inv.Artikelnr='') then begin
debugx('Kein Art bei KEY259');
CYCLE;
    end;
    Erx # RekLink(250,259,1,_recFirst);   // Artikel holen

    Art_P_Data:LiesPreis('Ø-EK',0);


    Erx # Reklink(819,250,10,_RecFirst);  // Warengruppe holen

    // neue Charge anlegen
    RecBufClear(200);
    Mat.Strukturnr  # Art.Nummer;
    Mat.MEH         # Art.MEH;
    Mat.Warengruppe # Art.Warengruppe;
    "Mat.Güte"      # "Art.Güte";
    Mat.Dicke       # Art.Dicke;
    Mat.Breite      # Art.Breite;
    "Mat.Länge"     # "Art.Länge";
    Mat.Dickentol   # Art.DickenTol;
    Mat.Breitentol  # Art.BreitenTol;
    "Mat.Längentol" # "Art.LängenTol";
    Mat.RID         # Art.Innendmesser;
    Mat.RAD         # Art.Aussendmesser;
//    if ("Mat.Güte"='') then "Mat.Güte" # 'x';

    Mat.Bestand.Stk   # "Art.Inv.Stückzahl";
    Mat.Bestand.Menge # Art.Inv.Menge;
    if (Art.Inv.MEH='m') then begin
      "Mat.Länge" # Art.Inv.Menge / cnvfi("Art.Inv.Stückzahl") * 1000.0;
    end
    else if (Art.Inv.MEH='kg') then begin
      Mat.Bestand.Gew # Art.Inv.Menge;
    end;

    if (Mat.Bestand.Gew=0.0) then begin
      Mat.Bestand.Gew # "Mat.Länge" * "Art.GewichtProm" / 1000.0 * cnvfi(Mat.Bestand.Stk);
    end;
    if (Mat.Bestand.Gew=0.0) then begin
      Mat.Bestand.Gew # "Art.GewichtProStk" * cnvfi(Mat.Bestand.Stk);
    end;
    if (mat.Bestand.Gew=0.0) then begin
//      TRANSBRK;
debug('Kein Gewicht bei '+aint(art.inv.nummer));
    end;

    Mat.Lieferant         # 1;
    Mat.EK.Preis          # Art.P.PreisW1;
    Mat.Bewertung.Laut    # 'D';
    Mat.EigenmaterialYN   # y;
    "Mat.Übernahmedatum"  # today;
    Mat.Eingangsdatum     # today;
    Mat.Inventurdatum     # today;
    Mat.Status            # 1;
    Mat.Lageradresse      # 1;
    Mat.Lageranschrift    # 1;



    if (Wgr_Data:IstArt()) then begin
//debugx('MANUELL bei Art '+art.Nummer);
    RecBufClear(252);
    Art.C.ArtikelNr       # Art.Nummer;
    Art.C.ArtStichwort    # Art.Stichwort;
    Art.C.AdrStichwort    # Adr.A.Stichwort;

    Art.C.Adressnr  # 1;
    Art.C.Anschriftnr # 1;
    Art.C.Eingangsdatum   # today;
    Art.C.Anlage.Datum    # today;
    Art.C.Anlage.Zeit     # now;
    Art.C.Anlage.User     # gUsername;

    Art.C.Dicke   # MAt.Dicke;
    Art.C.Breite  # Mat.Breite;
    "Art.C.Länge" # "Mat.Länge";
    Art.C.Bestand.Stk # Mat.Bestand.stk;
    Art.C.Bestand     # Mat.Bestand.Menge;

    vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
todox('');
      RETURN;
    end;
    Art.C.Charge.Intern # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);

    if (Art_Data:WriteCharge(y,'AUTO')<>_rOK) then begin
      TRANSBRK;
TODO('ArtC NICHT anlegbar für '+aint(art.inv.nummer));
      RETURN;
    end;
CYCLE;
    end;




    Mat.Nummer # Lib_Nummern:ReadNummer('Material');
    if (Mat.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
todox('');
      RETURN;
    end;
    Mat.Ursprung          # Mat.Nummer;


    Erx # Mat_Data:Insert(_recunlock,'AUTO',Today, Mat.Inventurdatum);
    if (Erx<>_rOK) then begin
      TRANSBRK;
TODO('Mat NICHT anlegbar für '+aint(art.inv.nummer));
      RETURN;
    end;

    RecRead(259,1,_RecLock);
    Art.Inv.Materialnr  # Mat.Nummer;
    Art.Inv.ChargeFehlte # y;
    RekReplace(259);
  END;

  TRANSOFF;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
//========================================================================
//========================================================================