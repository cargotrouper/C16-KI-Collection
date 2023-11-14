@A+
//===== Business-Control =================================================
//
//  Prozedur    Art_Data
//                        OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  04.08.2008  PW  Selektionsquery
//  13.01.2010  AI  Chargen werden nie mehr gelöscht - nur Ausgangsdatum gesetzt
//  20.04.2010  MS  Fkt. die den Inventurpreis als Durchschnitts-EK uebernimmt
//  15.02.2011  AI  neue Chargen
//  19.10.2011  AI  Recalcall prüft Auftragsreservierung
//  25.06.2012  TM  Bedarfsträgertyp 'ANG' hinzugefügt
//  07.08.2012  AI  "Bewegung" setzt Lieferant (Projekt 1108/56)
//  25.09.2012  AI  NEU: "ReadChargeByPara"
//  03.12.2012  AI  Option "aNegativOK" bei Bewegung
//  20.12.2012  AI  BUGFIX: "InventurPreisAlsDurchschnittsEK"
//  10.01.2013  AI  BUGFIXES: für "OhneBestand" und "Chargenfühung=false"
//  26.03.2013  AI  NEU: Bewegung zieht Stückzahl automatisch bei MEH Stk
//  22.04.2013  AI  NEU: AFX Art.Bewegung.UnterMin
//  22.08.2013  AH  NEU: AFX Art.Reservierung.UnterMin
//  16.10.2013  AH  Anfragen
//  31.07.2014  ST  Prüfung auf Abschlussdatum bei "Bewegung" hinzugefügt Projekt 1326/395
//  08.01.2015  AH  "RecalcAll" kann auch nur einen Artikel
//  15.07.2015  AH  "Reservierung" mit Differenz Null gibt keinen Fehler
//  05.07.2017  AH  Bug: "ArtikelRecalc" hat bei Bestellungen nicht den richtigen Artikel geladen
//  31.08.2018  ST  Edit: "ArtikelRecalc" um optionlen Silent Parameter erweitert
//  04.02.2020  AH  Neu: Artikelcharge mit Reservierter-Menge
//  12.08.2020  AH  Fix: "OpenCharge" beachtet bei Sperrproblemen die Userantwort
//  28.09.2020  AH  Neu: Artikelrecalc für markierte
//  27.07.2021  AH  ERX
//  07.10.2021  AH  Neu: "MatStatusQuery"
//  21.01.2022  DS  Kritische Zeile verkürzt (längste Zeile im Dokument machte Probleme bei git Import in C16)
//  2022-08-15  AH  "CalcGewichtProStk", "CalcGewichtProM"
//  2022-08-25  AH  Fix für Auf.Rahmen, die überserviert sind (VFP)
//
//  Subprozeduren
//    SUB CalcGewichtProStk
//    SUB CalcGewichtProM
//    SUB ReadChargeByPara(aAdr : int; aAnsch : int; aZust : int) : logic;
//    SUB ArtAktionExist() : alpha;
//    SUB InventurpreisAlsDurchschnittsEK() : alpha;
//    SUB MatStatusQuery(aSumNr : int) : alpha
//    SUB FindeCharge() : logic;
//    SUB WriteCharge(aNeu : logic; optaTyp : alpha) : int;
//    SUB ReadCharge() : logic;
//    SUB OpenCharge(aSperren : logic; Opt aAnlage : date : ) : logic;
//    SUB Bedarf(aMenge : float; aGrund : alpha) : logic;
//    SUB Auftrag(aAufMenge : float) : logic;
//    SUB Bestellung(aBestMenge : float) : logic;
//    SUB Reservierung(aArtikel : alpha; aAdresse : int; aAnschrift : word; aCharge : alpha; aTragTyp : alpha; aTragNr1 : int; aTragNr2 : word; aTragNr3 : word; aDifMenge : float; aDifStk : int; aResID : int) : logic
//    SUB Bewegung(aEKPreis : float; VKPreis : float; opt aAdr: int;; opt aNegativOK : logic) : logic
//    SUB BerechneFelder(var aStk : int; var aKg : float; var aMenge : float; aMEH : alpha) : logic;
//    SUB SplitCharge(aProzent : float) : logic;
//    SUB ReCalcAll(opt aArtNr : alpha);
//    SUB Import_TSR();
//    SUB RecalcSumCharge();
//
//========================================================================
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Global

define begin
  gagaC : //if (Art.C.ArtikelNr<>'COIL A') and (Art.C.ArtikelNr<>'TAFEL A') then CYCLE;
  //if (Art.C.ArtikelNr<>'165000000049') and (Art.C.ArtikelNr<>'170000000145') then CYCLE;
  gagaArt :// if (Art.Nummer<>'COIL A') and (Art.Nummer<>'TAFEL A') then CYCLE;
  //if (Art.Nummer<>'165000000049') and (Art.Nummer<>'170000000145') then CYCLE;
  gagaAuf : //if (Auf.P.ArtikelNr<>'COIL A') and (Auf.P.ArtikelNr<>'TAFEL A') then CYCLE;
  //if (Auf.P.ArtikelNr<>'165000000049') and (Auf.P.ArtikelNr<>'170000000145') then CYCLE;
  gagaB : //if (Ein.P.ArtikelNr<>'COIL A') and (Ein.P.ArtikelNr<>'TAFEL A') then CYCLE;
  //if (Ein.P.ArtikelNr<>'165000000049') and (Ein.P.ArtikelNr<>'170000000145') then CYCLE;
end;

declare RecalcSumCharge();


//========================================================================
Sub Diction(
  aKey    : alpha;
  aWas    : alpha;
  aDelta  : float;
  aGrund  : alpha;
)
local begin
  Erx     : int;
end;
begin
  Dic.Value # cnvad(today)+';'+cnvat(now)+';'+gUsername+';'+anum(aDelta,3)+';'+aGrund;
  REPEAT
    Dic.Key   # aKey+'|'+aWas+'|'+aint(cnvid(today))+aint(cnvit(now));
    Erx # RecInsert(935,0);
  UNTIL (Erx<>_rExists);
end;


/*========================================================================
2022-08-15  AH
========================================================================*/
SUB CalcGewichtProStk
begin
  if (Art.GewichtProM<>0.0) then
    "Art.GewichtProStk" # "Art.GewichtProm" * "Art.Länge" / 1000.0
  else
    "Art.GewichtProStk" # Rnd(Art.Dicke / 100.0 * Art.Breite / 100.0 * "Art.Länge" / 100.0 * Art.SpezGewicht, 3);
end;


/*========================================================================
2022-08-15  AH
========================================================================*/
SUB CalcGewichtProM
begin
  if ("Art.Länge"<>0.0) then begin
    "Art.GewichtProm" # "Art.GewichtProStk" / "Art.Länge" * 1000.0;
  end;
  
end;


//========================================================================
//  ReadChargeByPara
//
//========================================================================
sub ReadChargeByPara(
  aAdr        : int;
  aAnsch      : int;
  aZust       : int;
  opt aPlatz  : alpha;
  ) : logic;
local begin
  Erx : int;
end;
begin

  Erx # Reclink(252,250,4,_recLast); // Chargen loopen
  WHILE (Erx<=_rLocked) do begin
    if (aAdr=Art.C.Adressnr) and
      (aAnsch=Art.C.Anschriftnr) and
      ((aPlatz=Art.C.Lagerplatz) or (aPlatz='')) and
      ((aZust=Art.C.Zustand) or (aZust=0)) and
      ((Art.C.Ausgangsdatum=0.0.0) or ("Art.ChargenführungYN"=n)) then begin
      RETURN true;
    end;
    Erx # Reclink(252,250,4,_recPrev);
  END;

  RecbufClear(252);
  RETURN false;
end;


//========================================================================
//  ArtAktionExist
//
//========================================================================
sub ArtAktionExist() : alpha;
local begin
  vErx : int;
  vBuf : int;
end;
begin
  if(Art.Nummer = '') then
    RETURN '';

  vBuf # RecBufCreate(252);
  vErx # RecLink(vBuf, 250, 4, _recFirst); // 1. Charge holen
  if(vErx > _rLocked) then
    RecBufClear(vBuf);

  if(vBuf -> Art.C.Bestand <> 0.0) then
    RETURN 'BESTAND';
  RecBufDestroy(vBuf);

  vErx # RecLinkInfo(252, 250, 4, _recCount); // Anzahl Chargen
  if(vErx > 1) then
    RETURN 'CHARGEN';

  vErx # RecLinkInfo(253, 250, 5, _recCount); // Anzahl Lagerjournal
  if(vErx > 0) then
    RETURN 'LAGERJOURNAL';

  vErx # RecLinkInfo(409, 250, 7, _recCount); // Anzahl Auftrag Stueckliste
  if(vErx > 0) then
    RETURN 'AUFTRAG STÜCKLISTE';

  vErx # RecLinkInfo(256, 250, 2, _recCount); // Anzahl InStueckliste
  if(vErx > 0) then
    RETURN 'IN STÜCKLISTEN';

  vErx # RecLinkInfo(401, 250, 3, _recCount); // Anzahl Auf. Positionen
  if(vErx > 0) then
    RETURN 'AUFTRAGS POSITION';

  vErx # RecLinkInfo(411, 250, 24, _recCount); // Anzahl Auf. ~Positionen
  if(vErx > 0) then
    RETURN 'AUFTRAGS ~POSITION';

  vErx # RecLinkInfo(501, 250, 12, _recCount); // Anzahl Ein. Positionen
  if(vErx > 0) then
    RETURN 'EINKAUFS POSITION';

  vErx # RecLinkInfo(511, 250, 18, _recCount); // Anzahl Ein. ~Positionen
  if(vErx > 0) then
    RETURN 'EINKAUFS ~POSITION';

  vErx # RecLinkInfo(540, 250, 14, _recCount); // Anzahl Bedarf
  if(vErx > 0) then
     RETURN 'BEDARF';

  vErx # RecLinkInfo(545, 250, 15, _recCount); // Anzahl ~Bedarf
  if(vErx > 0) then
     RETURN '~BEDARF';

  RETURN '';
end;


//========================================================================
// InventurpreisAlsDurchschnittsEK  20.04.2010  MS
//        Uebernimmt den Inventurpreis als Durchschnits EK
//========================================================================
sub InventurpreisAlsDurchschnittsEK() : alpha;
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
  if(vMarked = 0) then begin
    RETURN 'NOMARK';
  end;

  if(Msg(254004, '', 0, _WinDialogYesNo, 2) = _WinIdNo) then
    RETURN 'NO';

  vText # '';

  // Markierung loopen
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);

    // Markierung nicht aus Artikel?
    if (vMFile <> 250) then begin
      CYCLE;    //nahster Eintrag
    end;

    TRANSON; // Transaktion START!

    // Artikel lesen
    Erx # RecRead(250, 0, _recId, vMID);
    if (Erx > _rLocked) then RecBufClear(250);

    if(Art_P_Data:LiesPreis('INVEK', 0) = false) then begin // Inventur-EK lesen
      // kein InvEK? -> nächster
      CYCLE;
//      Lib_Strings:Append(var vText, Art.Nummer + '_INVEK', ';');
//      TRANSBRK;
//      RETURN vText;
    end;

    vInvPreis   # Art.P.Preis;
    vInvPreisW1 # Art.P.PreisW1;

    if (Art_P_Data:LiesPreis('Ø-EK', 0)) then begin // Durchschnitts-EK lesen

      Erx # RecRead(254, 1, _recLock); // Durchschnitts-EK sperren
      if (Erx <> _rOK) then begin
        Lib_Strings:Append(var vText, Art.Nummer + '_LOCK', ';');
        TRANSBRK;
        RETURN vText;
      end;

      // Felder belegen
      Art.P.Preis   # vInvPreis;
      Art.P.PreisW1 # vInvPreisW1;

      Erx # Art_P_Data:Replace(_recUnlock, 'MAN'); // Durchschnitts-EK zurueckspeichern
      if(Erx <> _rOK) then begin
        Lib_Strings:Append(var vText, Art.Nummer + '_ULOCK', ';');
        TRANSBRK;
        RETURN vText;
      end;

    end
    else begin
      // kein DurrchscnittEK? -> dann anlegen:
      Art_P_Data:SetzePreis('Ø-EK', vInvPreisW1, 0);
//      Lib_Strings:Append(var vText, Art.Nummer + '_Ø-EK', ';');
//      TRANSBRK;
//      RETURN vText;
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
        if(Erx <> _rOK) then begin
          Lib_Strings:Append(var vText, Art.Nummer + '_LOCK', ';');
          TRANSBRK;
          RETURN vText;
        end;

        Art.C.EKDurchschnitt # vInvPreis;

        Erx # RekReplace(252, _recUnlock, 'MAN'); // Durchschnitts-EK zurueckspeichern
        if(Erx <> _rOK) then begin
          Lib_Strings:Append(var vText, Art.Nummer + '_ULOCK', ';');
          TRANSBRK;
          RETURN vText;
        end;

      END;
    end;
  END;

  TRANSOFF; // Transaktion ENDE!

  RETURN vText;

end;


//========================================================================
//  MatStatusQuery
//========================================================================
sub MatStatusQuery(aSumNr : int) : alpha
local begin
  Erx : int;
  vQ  : alpha(4000);
end;
begin
  FOR Erx # RecRead(820,1,_recFirst)
  LOOP Erx # RecRead(820,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.Sta.Nummer<>Mat.Sta.neueNummer) then CYCLE;
    if ((aSumNr=0) and (Mat.Sta.ArtSumFormel=*'*IST0*')) or
      (Mat.Sta.ArtSumFormel=*'*SUM'+aint(aSumNr)+'*') then begin
      if (vQ<>'') then vQ# vQ + ' OR ';
      vQ # vQ+ 'Mat.Status='+aint(Mat.Sta.Nummer);
    end;
  END;
  RETURN vQ;
end;


//========================================================================
// FindeCharge
//
//========================================================================
sub FindeCharge() : logic;
local begin
  Erx     : int;
  vBuf252 : int;
  vCharge : alpha;
  vNr     : int;
end;
begin

  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen


  // bei Chargenführung ist JEDES Charge ein UNIKAT
  if ("Art.ChargenführungYN") then begin
    vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;
    Art.C.Charge.intern # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
//todo('neu MIT charge:'+Art.C.Charge.intern);
    RETURN true;
  end;


  // passende Lageradresse + Anschrift + Lagerplatz Charge suchen.......
  vBuf252 # RekSave(252);
  Erx # Reclink(252,250,4,_recLast); // Chargen loopen
  WHILE (Erx<=_rLocked) do begin
    if (vBuf252->Art.C.Adressnr=Art.C.Adressnr) and
      (vBuf252->Art.C.Anschriftnr=Art.C.Anschriftnr) and
(vBuf252->Art.C.Zustand=Art.C.Zustand) and
      (vBuf252->Art.C.Lagerplatz=Art.C.Lagerplatz) and
      ((Art.C.Ausgangsdatum=0.0.0) or ("Art.ChargenführungYN"=n)) then begin
      vCharge # Art.C.Charge.Intern;
//todo('ALTE gefunden:'+vcharge);
      BREAK;
    end;
    Erx # Reclink(252,250,4,_recPrev);
  END;

  Rekrestore(vBuf252);

  // keine existierende Charge gefunden?
  if (vCharge='') then begin

    if (WGr.OhneBestandYN=false) then begin
      // neue Charge anlegen...
      vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
      if (vNr<>0) then Lib_Nummern:SaveNummer()
      else RETURN false;
      vCharge # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    end;
//todo('neu ohne charge:'+vCharge);

    // Lagerortchargen haben KEINE speziellen Daten!
//    if ("Art.ChargenführungYN"=n) then begin
//todo('leere'+art.nummer);
      Art.C.Charge.Extern   # '';
      Art.C.Lieferantennr   # 0;
      Art.C.Kommission      # '';
      Art.C.Auftragsnr      # 0;
      Art.C.AuftragsPos     # 0;
      Art.C.AuftragsFertig  # 0;
      Art.C.Bestellnummer   # '';
      Art.C.Bezeichnung     # '';
      Art.C.Zustand         # 0;
      Art.C.Dicke           # 0.0;
      Art.C.Breite          # 0.0;
      "Art.C.Länge"         # 0.0;
      Art.C.RID             # 0.0;
      Art.C.RAD             # 0.0;
//    end;
  end;

  Art.C.Charge.intern # vCharge;
  RETURN true
end;


//========================================================================
// WriteCharge
//            Inserted bzw. replaced eine Charge
//========================================================================
sub WriteCharge(
  aNeu                  : logic;
  opt aTyp              : alpha;
  opt aVrfNichtRechnen  : logic) : int;
local begin
  Erx     : int;
  vBasis  : float;
end;
begin

  if (aTyp='') then aTyp # 'AUTO';

  Art.C.Bestand         # Rnd(Art.C.Bestand, Set.Stellen.Menge);
  Art.C.Bestellt        # Rnd(Art.C.Bestellt, Set.Stellen.Menge);
  Art.C.offeneAuf       # Rnd(Art.C.offeneAuf, Set.Stellen.Menge);
  Art.C.Reserviert      # Rnd(Art.C.Reserviert, Set.Stellen.Menge);
  Art.C.Kommissioniert  # Rnd(Art.C.Kommissioniert, Set.Stellen.Menge);
  Art.C.Fremd           # Rnd(Art.C.Fremd, Set.Stellen.Menge);
  Art.C.Frei1           # Rnd(Art.C.Frei1, Set.Stellen.Menge);
  Art.C.Frei2           # Rnd(Art.C.Frei2, Set.Stellen.Menge);
  Art.C.Frei3           # Rnd(Art.C.Frei3, Set.Stellen.Menge);

  RecLink(250,252,1,_recFirst);     // Artikel holen
  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen

  if (Art.MEH='mm') or (Art.MEH='lfdmm') then
    vBasis # "Art.C.Länge";
  if (Art.MEH='m') or (Art.MEH='lfdm') then
    vBasis # "Art.C.Länge" / 1000.0;
  if (Art.MEH='qm') then
    vBasis # "Art.C.Länge" * Art.C.Breite / 1000000.0;
  if (Art.MEH='kg') and ("Art.Gewichtprom"<>0.0) and ("Art.C.Länge"<>0.0) then
    vBasis # "Art.GewichtProm" * ("Art.C.Länge" / 1000.0);
  if (Art.MEH='kg') and ("Art.GewichtPRoStk"<>0.0) and ("Art.C.Länge"=0.0) then
    vBasis # "Art.GewichtProStk";

  if (Wgr_Data:IstMix()=false) then begin
    if (vBasis<>0.0) then begin
      Art.C.Bestand.Stk     # CnvIF(Art.C.Bestand / vBasis);
      Art.C.Bestellt.Stk    # CnvIF(Art.C.Bestellt / vBasis);
      Art.C.offeneAuf.Stk   # CnvIF(Art.C.offeneAuf / vBasis);
    end;
  end;

  if (Art.C.Bestand.Stk=0) and (Art.C.Bestand>0.0) then Art.C.Bestand.Stk # 1;
  if (Art.C.Bestellt.Stk=0) and (Art.C.Bestellt>0.0) then Art.C.Bestellt.Stk # 1;
  if (Art.C.offeneAuf.Stk=0) and (Art.C.offeneAuf>0.0) then Art.C.offeneAuf.Stk # 1;
//  if (aVrfNichtRechnen=false) then begin    // 06.10.2021 AH
    "Art.C.Verfügbar.Stk"   # Art.C.Bestand.Stk - Art.C.Reserviert.Stk;
    "Art.C.Verfügbar"       # Art.C.Bestand - Art.C.Reserviert;
//  end;
  if (Set.Art.Vrfgb.AufRst) then begin
    "Art.C.Verfügbar.Stk"   # "Art.C.Verfügbar.Stk" - Art.C.OffeneAuf.Stk;
    "Art.C.Verfügbar"       # "Art.C.Verfügbar"     - Art.C.OffeneAuf;
  end;

  Art.C.Kommission  # '';
  if (Art.C.Auftragsnr<>0) then begin
    Art.C.Kommission # cnvai(Art.C.Auftragsnr,_FmtNumNoGroup);
    if (Art.C.AuftragsPos<>0) then begin
      Art.C.Kommission # Art.C.Kommission + '/'+ cnvai(Art.C.AuftragsPos,_FmtNumNoGroup);
      if (Art.C.AuftragsFertig<>0) then Art.C.Kommission # Art.C.Kommission + '/'+ cnvai(Art.C.AuftragsFertig,_FmtNumNoGroup);
    end;
  end;

  if (aNeu) then begin
    Erx # RekInsert(252,0,aTyp);
  end
  else begin
    Erx # RekReplace(252,_recUnlock,aTyp);
  end;

  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
// ReadCharge
//        Liest eine Charge
//========================================================================
sub ReadCharge(opt aSilent : logic): logic;
local begin
  Erx         : int;
  vX          : int;
  vBuf        : int;
end;
begin

  if (Art.C.AdressNr = 0) then
    RecBufClear(101);

  if (Art.C.AdressNr <> Adr.A.Nummer) then begin
    Adr.A.Adressnr # Art.C.AdressNr;
    Adr.A.Nummer # Art.C.AnschriftNr;
    Erx # RecRead(101,1,0);
    if (Erx > _rLockeD) then
      RecBufClear(101);
  end;

  /* Fehler bei Auswahl, durch Artikel suchen */
  /* MS 22.12.2010
     Buffer anstatt direkt auf die 250
  */

  if (Art.C.ArtikelNr <>  '') then begin  // Artikel suchen
    vBuf # RecBufCreate(250);
    vBuf -> Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(vBuf, 1, 0);
    if (Erx>=_rMultiKey) then begin
      RecBufDestroy(vBuf);
      if (aSilent=false) then
        Msg(253000, Art.C.ArtikelNr,0,0,0);
      RETURN false;
    end;
    RecBufDestroy(vBuf);
  end;


// Findecharge()
  Erx # RecRead(252, 1 ,0);
  if (Erx = _rOK) then
    RETURN true;

  RecBufClear(252);
  RETURN false;
end;


//========================================================================
// OpenCharge
//        Liest eine Charge bzw. legt sie neu an und sperrt sie ggf.
//========================================================================
sub OpenCharge(
  aSperren    : logic;
  opt aAnlage : date;
  ): logic;
local begin
  Erx         : int;
  vX          : int;
  vNr         : int;
end;
begin

  if (aAnlage=0.0.0) then aAnlage # today;

  if (Art.C.AdressNr=0) then RecBufClear(101);
  if (Art.C.AdressNr<>Adr.A.Nummer) then begin
    Adr.A.Adressnr # Art.C.AdressNr;
    Adr.A.Nummer # Art.C.AnschriftNr;
    Erx # RecRead(101,1,0);
    if (Erx>_rLockeD) then RecBufClear(101);
  end;

  if (Art.C.ArtikelNr<>'') and (Art.Nummer<>Art.C.Artikelnr) then begin  // Artikel suchen    12.02.2020 AH: nur laden, wenn nicht schon im Buf
    Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Msg(253000,Art.C.ArtikelNr,0,0,0);
      RETURN false;
    end;
  end;

  REPEAT
//    BuildChargenString();
//    FindeCharge();
    Erx # RecRead(252,1,_RecTest);
    if (Erx>_rLocked) then begin
      Art.C.ArtikelNr       # Art.Nummer;
      Art.C.ArtStichwort    # Art.Stichwort;
      Art.C.AdrStichwort    # Adr.A.Stichwort;
      Art.C.Eingangsdatum   # aAnlage;
      Art.C.Anlage.Datum    # today;
      Art.C.Anlage.Zeit     # now;
      Art.C.Anlage.User     # gUsername;

      Art.C.Bestand         # 0.0;
      Art.C.Bestellt        # 0.0;
      Art.C.Reserviert      # 0.0;
      Art.C.Kommissioniert  # 0.0;
      "Art.C.Verfügbar"     # 0.0;
      Art.C.OffeneAuf       # 0.0;
      Art.C.Fremd           # 0.0;
      Art.C.Frei1           # 0.0;
      Art.C.Frei2           # 0.0;
      Art.C.Frei3           # 0.0;
      Art.C.Bestand.Stk     # 0;
      Art.C.Bestellt.Stk    # 0;
      Art.C.Reserviert.Stk  # 0;
      Art.C.Kommission.Stk  # 0;
      "Art.C.Verfügbar.Stk" # 0;
      Art.C.OffeneAuf.Stk   # 0;
      Art.C.Fremd.Stk       # 0;
      Art.C.Frei1.Stk       # 0;
      Art.C.Frei2.Stk       # 0;
      Art.C.Frei3.Stk       # 0;
      Art.C.EKDurchschnitt  # 0.0;
      Art.C.EKLetzter       # 0.0;
      Art.C.VKDurchschnitt  # 0.0;
      Art.C.VKLetzter       # 0.0;
      Erx # WriteCharge(y);
    end
    else begin
      Erx # RecRead(252,1,0);
      if (Erx=_rLocked) then begin
        if (aSperren=n) then begin
          RecRead(252,1,0);
          Erx # _rOk;
        end
        else begin
          Winsleep(100);
          vX # vX + 1;
        end;
      end;
    end;

    if (vX>=30) then begin
      if (Msg(252000,UserInfo(_UserName,CnvIA(UserInfo(_UserLocked))),0,0,0)=_winidno) then begin
        RETURN false;
      end;
      vX # 0;
    end;

  UNTIL (Erx=_rOk);


  if (aSperren) then begin
    vX # 0;
    REPEAT
      Erx # RecRead(252,1,_Reclock);
      if (Erx=_rLocked) then begin
        Winsleep(100);
        vX # vX + 1;
      end;
      if (vX>=30) then begin
        if (Msg(252000,UserInfo(_UserName,CnvIA(UserInfo(_UserLocked))),0,0,0)=_winidno) then begin
          RETURN false;
        end;
        vX # 0;
      end;
    UNTIL (Erx=_rOK);
  end;

  RETURN true;
end;


//========================================================================
// Bedarf
//      legt einen Bedarf an bzw. ädert vorhandenen...
//========================================================================
sub Bedarf(
  aMenge          : float;    //
  aGrund          : alpha;    // Träger
): logic;
local begin
  Erx             : int;
  vA              : Alpha;
  vBDFTyp         : alpha;
  vBDF1           : int;
  vBDF2           : int;
  vBDF3           : int;end;
begin

  if (aMenge=0.0) then RETURN true;

  if (Art.C.ArtikelNr<>'') and (Art.Nummer<>Art.C.Artikelnr) then begin  // Artikel suchen
    Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Msg(253000,Art.C.ArtikelNr,0,0,0);
      RETURN false;
    end;
  end;

  // ggf. sofort Bedarf anlegen !!!
  if (Art.AutoBestellYN=n) or (Art.Dispotage<>0) then RETURN true;

  // gibts noch "alten" Bedarf?
  vA # Str_Token(aGrund,' ',1);
  aGrund # Str_Token(aGrund,' ',2);
  RecBufClear(540);
  // BA war Auslöser?
  if (vA=c_Akt_BA) then begin
    "Bdf.Trägertyp" # c_Akt_BA;
    vA # Str_Token(aGrund,'/',1);
    "Bdf.Trägernummer1" # cnvIA(vA);
    vA # Str_Token(aGrund,'/',2);
    "Bdf.Trägernummer2" # cnvIA(vA);
    vA # Str_Token(aGrund,'/',3);
    "Bdf.Trägernummer3" # cnvIA(vA);
  end;
  if (vA=c_Auf) then begin
    "Bdf.Trägertyp" # c_Auf;
    vA # Str_Token(aGrund,'/',1);
    "Bdf.Trägernummer1" # cnvIA(vA);
    vA # Str_Token(aGrund,'/',2);
    "Bdf.Trägernummer2" # cnvIA(vA);
    "Bdf.Trägernummer3" # 0;
  end;
  if (vA=c_Ang) then begin
    "Bdf.Trägertyp" # c_Auf;
    vA # Str_Token(aGrund,'/',1);
    "Bdf.Trägernummer1" # cnvIA(vA);
    vA # Str_Token(aGrund,'/',2);
    "Bdf.Trägernummer2" # cnvIA(vA);
    "Bdf.Trägernummer3" # 0;
  end;

  vBDFTyp # "Bdf.Trägertyp";
  vBDF1 # "Bdf.Trägernummer1";
  vBDF2 # "Bdf.Trägernummer2";
  vBDF3 # "Bdf.Trägernummer3";

  if ("Bdf.Trägertyp"<>'') then begin
    Erx # RecRead(540,2,0);
    WHILE (Erx<=_rMultikey) and (vBDFTyp="Bdf.Trägertyp") and
      (vBDF1="Bdf.Trägernummer1") and (vBDF2="Bdf.Trägernummer2") and
      (vBDF3="Bdf.Trägernummer3") do begin
      if (Bdf.ArtikelNr=Art.Nummer) then begin
        // existierit noch -> anpassen bzw. LÖSCHEN und Ende
        if (Bdf.Menge>(aMenge*-1.0)) then begin
          Erx # RecRead(540,1,_RecLock);
          if (Erx=_rOK) then begin
            Bdf.Menge # Bdf.Menge + aMenge;
            Erx # RekReplace(540,_recUnlock,'AUTO');
          end;
        end
        else begin
          Erx # Rekdelete(540,0,'AUTO');
        end;
        if (Erx<>_rOK) then RETURN false;   // 2022-07-05 AH DEADLOCK
        RETURN true;
      end;

      Erx # RecRead(540,2,_RecNext);
    END;
  end;


  // Bedarf NEGATIV??
  if (aMenge<0.0) then begin
    // keine Bestellung/Bedarf da -> dann kann man nichts abziehen...
    if (Art.C.Bestellt<=0.0) and (RecLinkInfo(540,250,19,_RecCount)=0) then RETURN true;
  end;


  if (Bdf_Data:BlankoAnlegen()=false) then begin
    Msg(0,'Bedarf nicht angelegt!',0,0,0);
  end
  else begin
    RecRead(540,1,_recLock);
    "Bdf.Trägertyp"       # 'ART';
    Bdf.ArtikelNr         # Art.Nummer;
    Bdf.ArtikelNr         # Art.Nummer;
    Bdf.ArtikelStichwort  # Art.Stichwort;
    Bdf.Charge            # Art.C.Charge.Intern;
    Bdf.Warengruppe       # Art.Warengruppe;

    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
    Bdf.Wgr.Dateinr       # Wgr.Dateinummer;
    if ("Art.ChargenführungYN") then Bdf.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Bdf.Wgr.Dateinr);

    Bdf.MEH               # Art.MEH;
    Bdf.Menge             # aMenge;
    if (StrCnv(Bdf.MEH,_StrUpper)='STK') then
      "Bdf.Stückzahl"     # CnvIF(aMenge);
    if (StrCnv(Bdf.MEH,_StrUpper)='KG') then
      Bdf.Gewicht         # aMenge

    // BA war Auslöser?
    if (vBDFTyp=c_akt_BA) then begin
      "Bdf.Trägertyp" # c_Akt_BA;
      "Bdf.Trägernummer1" # vBDF1;
      "Bdf.Trägernummer2" # vBDF2;
      "Bdf.Trägernummer3" # vBDF3;
    end;
    if (vBDFTyp=c_Auf) then begin
      "Bdf.Trägertyp" # c_Auf;
      "Bdf.Trägernummer1" # vBDF1;
      "Bdf.Trägernummer2" # vBDF2;
      "Bdf.Trägernummer3" # vBDF3;
    end;
    if (vBDFTyp=c_Ang) then begin
      "Bdf.Trägertyp" # c_Ang;
      "Bdf.Trägernummer1" # vBDF1;
      "Bdf.Trägernummer2" # vBDF2;
      "Bdf.Trägernummer3" # vBDF3;
    end;

    Erx # RekReplace(540,_recUnlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Auftrag
//            verändert die offenen Auftragsmenge in den Chargen
//========================================================================
sub Auftrag(
  aAufDelta : float;
  opt aInit : logic): logic;
local begin
  Erx       : int;
  vWert     : float;
end;
begin
//debugx(Art.C.Artikelnr+'/'+art.Nummer+': offenerAufmenge '+cnvaf(aAufMenge));

  if (RunAFX('Art.Data.Auftrag',anum(aAufDelta,5))<>0) then RETURN (AfxRes=_rOK);

  if (aAufDelta=0.0) then RETURN true;

  RecBufClear(101);               // Anschrift holen
  if (Art.C.AdressNr<>0) then begin
    Adr.A.Adressnr # Art.C.AdressNr;
    Adr.A.Nummer # Art.C.AnschriftNr;
    Erx # RecRead(101,1,0);
    if (Erx>_rLockeD) then RecBufClear(101);
  end;

  if (Art.C.ArtikelNr<>'') and (Art.Nummer<>Art.C.Artikelnr) then begin  // Artikel suchen
    Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Msg(253000,Art.C.ArtikelNr,0,0,0);
      RETURN false;
    end;
  end;
/***
debugx('KEY401 Menge='+anum(Auf.P.Menge,0));
debug('- VSB'+anum(Auf.P.Prd.VSB,0));
debug('- LFS'+anum(Auf.P.Prd.LFS,0));
debug('- Plan'+anum(Auf.P.Prd.Plan,0));
debug('- Rsrv'+anum(Auf.P.Prd.Reserv,0)); // per setting
***/
//x  FindeCharge();

  // echte Charge angegeben?
  if (Art.C.Charge.Intern<>'') then begin

    if (Wgr.Nummer<>Art.Warengruppe) then
      Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen

    // DatailCharge buchen
    OpenCharge(y);
    Art.C.offeneAuf     # Art.C.offeneAuf + aAufDelta;
    if (Wgr.OhneBestandYN=false) then begin
      if (Art.C.Bestand=0.0) and (Art.C.Bestellt=0.0) and (Art.C.Reserviert=0.0) then begin
        if (Art.C.Ausgangsdatum=0.0.0) then Art.C.Ausgangsdatum # today;
      end
      else begin
        if (Art.C.Ausgangsdatum<>0.0.0) then Art.C.Ausgangsdatum # 0.0.0;
      end;
    end;
    Erx # WriteCharge(n);
    if (erx<>_rOk) then Msg(0,'Charge nicht angelegt!',0,0,0);
  end;


  // Artikelsumme buchen
  Art.C.Charge.Intern # '';
  Art.C.Adressnr      # 0;
  Art.C.AnschriftNr   # 0;
  OpenCharge(y);
  Art.C.offeneAuf   # Art.C.offeneAuf + aAufDelta;
//debugx('BUCHE '+Art.C.ArtikelNr+' '+anum(aAufDelta,0)+'offenAuf');
  Erx # WriteCharge(n);
  if (erx<>_rOk) then Msg(0,'Artikelsumme nicht angelegt!',0,0,0);

  if (Set.Installname='HOWVFP') and (aInit=false) then begin
    Diction(Art.Nummer, 'OffeneAuf', aAufDelta, aint(Auf.P.nummer)+'/'+aint(Auf.P.Position));
  end;

  RETURN true;
end;


//========================================================================
// Bestellung
//            bestellt in den Chargen
//========================================================================
sub Bestellung(aBestMenge : float): logic;
local begin
  Erx       : int;
  vWert     : float;
  v819      : int;
  vDateinr  : int;
end;
begin

  if (Wgr.Nummer<>Art.Warengruppe) then begin
    v819 # RecBufCreate(819);
    Erx # RekLink(v819,250,10,_recFirst);    // Warengruppe holen
    vDateinr # v819->Wgr.Dateinummer;
    RecbufDestroy(v819);
  end
  else begin
    vDateinr # Wgr.Dateinummer;
  end;
  if (Wgr_Data:IstMix(vDateinr)) then RETURN true;  // 05.02.2020 AH

  if (RunAFX('Art.Data.Bestellung',anum(aBestMenge,5))<>0) then RETURN (AfxRes=_rOK);


  if (aBestMenge=0.0) then RETURN true;

  if (Art.C.ArtikelNr<>'') and (Art.Nummer<>Art.C.Artikelnr) then begin  // Artikel suchen
    Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Msg(253000,Art.C.ArtikelNr,0,0,0);
      RETURN false;
    end;
  end;


  // Artikelsumme buchen
  Art.C.Charge.Intern # '';
  Art.C.Adressnr      # 0;
  Art.C.AnschriftNr   # 0;
  OpenCharge(y);
  Art.C.Bestellt    # Art.C.Bestellt + aBestMenge;
  Erx # WriteCharge(n);
  if (erx<>_rOk) then Msg(0,'Artikelsumme nicht angelegt!',0,0,0);

  RETURN true;
end;


//========================================================================
// MatFremdReserv
//            Matreservierung "fremd" (d.h. Auftrag will Art.X, Reserviert wird Art.Y)
//========================================================================
sub MatFremdReserv(
  aMengeDelta : float;
  opt aInit   : logic): logic;
local begin
  Erx       : int;
  vWert     : float;
  v819      : int;
  vDateinr  : int;
end;
begin

  if (aMengeDelta=0.0) then RETURN true;

  if (Art.C.ArtikelNr<>'') and (Art.Nummer<>Art.C.Artikelnr) then begin  // Artikel suchen
    Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Msg(253000,Art.C.ArtikelNr,0,0,0);
      RETURN false;
    end;
  end;

  // Artikelsumme buchen
  Art.C.Charge.Intern # '';
  Art.C.Adressnr      # 0;
  Art.C.AnschriftNr   # 0;
  OpenCharge(y);
  Art.C.Fremd # Art.C.Fremd + aMengeDelta;
//debugx('BUCHE '+Art.C.ArtikelNr+' '+anum(aMengeDelta,0)+'fremd');
  Erx # WriteCharge(n);
  if (erx<>_rOk) then Msg(0,'Artikelsumme nicht angelegt!',0,0,0);

  if (Set.Installname='HOWVFP') and (aInit=false) then begin
    Diction(Art.Nummer, 'FremdAuf', aMengeDelta, aint(Auf.P.nummer)+'/'+aint(Auf.P.Position));
  end;

  RETURN true;
end;


//========================================================================
// Reservierung
//            reserviert in den Chargen
//========================================================================
sub Reservierung(
  aArtikel      : alpha;
  aAdresse      : int;
  aAnschrift    : word;
  aCharge       : alpha;
  aZustand      : int;
  aTragTyp      : alpha;
  aTragNr1      : int;
  aTragNr2      : word;
  aTragNr3      : word;
  aDifMenge     : float;
  aDifStk       : int;
  aResID        : int;
): logic;
local begin
  Erx           : int;
  vWert         : float;
  vA            : alpha;
  vNeu          : logic;
  vBuf252       : int;
  vUnterdeckung : logic;
end;
begin
//debug(aArtikel+'/'+aint(aAdresse)+'/'+AInt(aAnschrift)+'/'+aCharge+': Reserviere '+ANum(aDifMenge,2));

  if (aDifMenge=0.0) and (aDifStk=0) then RETURN true;

  if (aArtikel<>Art.Nummer) then begin  // Artikel suchen
    Art.Nummer # aArtikel;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Msg(253000,aArtikel,0,0,0);
      RETURN false;
    end;
  end;

  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen


  // Reservierungsjournal-Eintrag suchen.......................................
  RecbufClear(251);
  Art.R.Artikelnr       # aArtikel;
  "Art.R.TrägerTyp"     # aTragTyp;
  "Art.R.TrägerNummer1" # aTragNr1;
  "Art.R.TrägerNummer2" # aTragNr2;
  "Art.R.TrägerNummer3" # aTragNr3;
  Erx # RecRead(251,2,0);
  vNeu # y;
  // nicht vorhanden?
  if (Erx>_rMultikey) then begin
    if (aDifMenge<=0.0) then RETURN TRUE; // mindern von NIX geht nicht!  15.07.2015 AH : TRUE
  end
  else begin
    WHILE (Erx<=_rMultikey) and
        (Art.R.Artikelnr=aArtikel) and ("Art.R.TrägerTyp"=aTragTyp) and
        ("Art.R.TrägerNummer1"=aTragNr1) and ("Art.R.TrägerNummer2"=aTragNr2) and
        ("Art.R.TrägerNummer3"=aTragNr3) do begin
      // Reservierung genau für diese Charge?
      if (Art.R.Zustand=aZustand) and (Art.R.Adressnr=aAdresse) and (Art.R.Anschrift=aAnschrift) and (Art.R.Charge.intern=aCharge) then begin
        vNeu # n;
        BREAK;
      end;
      Erx # RecRead(251,2,_recNext);
    END;
  end;


  if (aCharge='') then begin
    FindeCharge();
  end
  else begin
    if (aCharge<>Art.C.Charge.intern) then begin
//todo('chargen chaos');
//RETURN false;
      RecBufCleaR(252);
      Art.C.ArtikelNr     # aArtikel;
      Art.C.Charge.Intern # aCharge;
      OpenCharge(n);
    end;
  end;

  TRANSON

  // NEUER EINTRAG.....
  if (vNeu) then begin
    RecBufClear(251);
    Art.R.Artikelnr       # aArtikel;
    Art.R.Adressnr        # aAdresse;
    Art.R.Anschrift       # aAnschrift;
    Art.R.Charge.Intern   # aCharge;
    Art.R.Zustand         # aZustand;

    "Art.R.TrägerTyp"     # aTragTyp;
    "Art.R.TrägerNummer1" # aTragNr1;
    "Art.R.TrägerNummer2" # aTragNr2;
    "Art.R.TrägerNummer3" # aTragNr3;
    "Art.R.Stückzahl"     # aDifStk;
    Art.R.Menge           # aDifMenge;
    Art.R.MEH             # Art.MEH;
    if (aResID=0) then begin
      Art.R.Reservierungnr  # Lib_Nummern:ReadNummer('Artikel-Reservierung');
      if (Art.R.ReservierungNr<>0) then Lib_Nummern:SaveNummer()
      else begin
        TRANSBRK;
        RETURN false;
      end;
    end
    else begin
      Art.R.Reservierungnr # aResID;
    end;
    Erx # RekInsert(251,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
  end
  else begin  // ändern
    if (Art.R.MEH<>Art.MEH) then begin
      TRANSBRK;
      RETURN false;
    end;
    Recread(251,1,_recLock);
    "Art.R.Stückzahl"     # "Art.R.Stückzahl" + aDifStk;
    Art.R.Menge           # Art.R.Menge + aDifMenge;
    Erx # RekReplace(251,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
    if (Art.R.Menge=0.0) then begin
      Erx # RekDelete(251,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;
  end;
  // Reservierungsjorunal Ende



  // Datail-Charge holen
  if (aCharge<>'') then begin
    RecBufCleaR(252);
    Art.C.ArtikelNr     # aArtikel;
    Art.C.Charge.Intern # aCharge;
    OpenCharge(y);
    Art.C.Reserviert      # Art.C.Reserviert      + aDifMenge;
    Art.C.Reserviert.stk  # Art.C.Reserviert.Stk  + aDifStk;
    if (Wgr.OhneBestandYN=false) then begin
      if (Art.C.Bestand=0.0) and (Art.C.Bestellt=0.0) and (Art.C.Reserviert=0.0) then begin
        if (Art.C.Ausgangsdatum=0.0.0) then Art.C.Ausgangsdatum # today;
      end
      else begin
        if (Art.C.Ausgangsdatum<>0.0.0) then Art.C.Ausgangsdatum # 0.0.0;
      end;
    end;
    Erx # WriteCharge(n);
  end;

  vBuf252 # RekSave(252);

  // Artikelsumme buchen
  Art.C.ArtikelNr     # aArtikel;
  Art.C.Charge.Intern # '';
  Art.C.Adressnr      # 0;
  Art.C.AnschriftNr   # 0;
  OpenCharge(y);

  if (Wgr.OhneBestandYN=false) then begin
    vUnterdeckung     # (aDifMenge>0.0) and ((Art.C.Bestand - Art.C.Reserviert) >= Art.Bestand.Min) and (Art.Bestand.Min > ((Art.C.Bestand - Art.C.Reserviert) - aDifMenge));
  end;

  Art.C.Reserviert      # Art.C.Reserviert + adifMenge;
  Art.C.Reserviert.stk  # Art.C.Reserviert.Stk  + aDifStk;

  Erx # WriteCharge(n);

  RekRestore(vBuf252);

  TRANSOFF;

  if (vUnterdeckung) then RunAFX('Art.Reservierung.UnterMin','');

  RETURN true;
end;


//========================================================================
// Bewegung
//        bucht in den Chargen Reserviert, Bestellt, Bestand um
//        und führt ggf. Buch darüber
//========================================================================
sub Bewegung(
  aEKPreis        : float;    // auf Art.PEH bezogen !!!
  aVKPreis        : float;    // auf Art.PEH bezogen !!!
  opt aAdr        : int;
  opt aNegativOK  : logic;
): logic;
local begin
  Erx             : int;
  vWert           : float;
  vChargeExtern   : alpha;
  vFilter         : int;
  vNr             : int;
  vBuf253         : int;
  vBuf252         : int;
  v100            : int;
  vUnterdeckung   : logic;
end;
begin

  if (Art.J.Menge=0.0) and ("Art.J.Stückzahl"=0) then RETURN true;
  aEKPreis # rnd(aEKPreis,2);
  aVKPreis # rnd(aVKPreis,2);
  if (Art.J.Datum=0.0.0) then Art.J.Datum # today;

  // Abschlußdatum beachten
  if (Lib_Faktura:Abschlusstest(Art.J.Datum) = false) then begin
    Error(001400 ,Translate('Journaldatum') + '|'+ CnvAd(Art.J.Datum));
    RETURN false;
  end;


  RecBufClear(101);               // Anschrift holen
  if (Art.C.AdressNr<>0) then begin
    Adr.A.Adressnr # Art.C.AdressNr;
    Adr.A.Nummer # Art.C.AnschriftNr;
    Erx # RecRead(101,1,0);
    if (Erx>_rLockeD) then RecBufClear(101);
  end;

  if (Art.C.ArtikelNr<>'') and (Art.Nummer<>Art.C.Artikelnr) then begin  // Artikel suchen
    Art.Nummer # Art.C.ArtikelNr;
    Erx # RecRead(250,1,0);
    if (Erx>=_rMultiKey) then begin
      Error(253000,Art.C.ArtikelNr);
      RETURN false;
    end;
  end;

  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen

  // 26.03.2013
  if ("Art.J.Stückzahl"=0) and (Art.MEH='Stk') then
    "Art.J.Stückzahl" # cnvif(Art.J.Menge);

  vChargeExtern # Art.C.Charge.Extern;

  if (Art.C.Charge.intern='') then FindeCharge();

//debug('bewege:'+art.c.charge.intern+' '+anum(art.J.Menge,0));

  // echte Charge angegeben?
  if (Art.C.Charge.Intern<>'') then begin

    // DatailCharge buchen
    OpenCharge(y, Art.J.Datum);
    if (aEKPreis<>0.0) and (Art.C.Bestand + Art.J.Menge<>0.0) then begin
      vWert # (Art.C.EKDurchschnitt * (Art.C.Bestand / CnvFI(Art.PEH)));
      vWert # vWert + (aEKPreis * (Art.J.Menge / CnvFI(Art.PEH)))
      Art.C.EKDurchschnitt # vWert / (Art.C.Bestand + Art.J.Menge) * CnvFI(Art.PEH);
      Art.C.EKLetzter # aEKPreis;
    end;
    if (aVKPreis<>0.0) and (Art.C.Bestand + Art.J.Menge<>0.0) then begin
      vWert # (Art.C.VKDurchschnitt * (Art.C.Bestand / CnvFI(Art.PEH)));
      vWert # vWert + (aVKPreis * (Art.J.Menge / CnvFI(Art.PEH)))
      Art.C.VKDurchschnitt # vWert / (Art.C.Bestand + Art.J.Menge) * CnvFI(Art.PEH);
      Art.C.VKLetzter # aVKPreis;
    end;

    if (Wgr.OhneBestandYN=false) then begin
      Art.C.Bestand     # Art.C.Bestand + Art.J.Menge;
      Art.C.Bestand.Stk # Art.C.Bestand.Stk + "Art.J.Stückzahl";
    end
    else begin
      Art.C.Bestand     # 0.0;
      Art.C.Bestand.Stk # 0;
    end;
    if (Art.C.Bestand=0.0) and (Art.C.Bestellt=0.0) and (Art.C.Reserviert=0.0) then begin
      if (Art.C.Ausgangsdatum=0.0.0) then Art.C.Ausgangsdatum # today;
    end
    else begin
      if (Art.C.Ausgangsdatum<>0.0.0) then Art.C.Ausgangsdatum # 0.0.0;
    end;

    Erx # WriteCharge(n);
    if (erx<>_rOk) then Error(253005,'');


    // Unterbuchung sperren
    if (aNegativOK=false) and (Art.C.Bestand<0.0) then begin
      Error(253006,Art.C.ArtikelNr+'@'+Aint(art.C.Adressnr)+'/'+aint(Art.C.Anschriftnr));
      RETURN false;
    end;

    vBuf252 # RekSave(252);
  end;


  // Lagerjournal ggf. vorbereiten...
  if (Art.LagerjournalYN) then begin
    vBuf253 # RekSave(253);
    RecBufClear(253);
    Art.J.ArtikelNr     # Art.Nummer;
    Art.J.Charge        # Art.C.Charge.Intern;
    Art.J.Datum         # vBuf253->Art.J.Datum;

    // letzten Datensatz dieses Tages suchen...
    vFilter # RecFilterCreate(253,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.J.Artikelnr);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, Art.J.Charge);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, Art.J.Datum);
    Erx # RecRead(253,1,_recLast);
    RecFilterDestroy(vFilter);
    if (Erx>_rMultiKey) then vNr # 1
    else vNr # Art.J.lfdNr + 1;

    RekRestore(vBuf253);

    Art.J.ArtikelNr     # Art.Nummer;
    Art.J.Charge        # Art.C.Charge.Intern;
    Art.J.Adressnr      # Art.C.Adressnr;
    Art.J.Anschriftnr   # Art.C.AnschriftNr;
    Art.J.Lagerplatz    # Art.C.Lagerplatz;
    Art.J.lfdNr         # vNr;
    Art.J.Charge.Extern   # Art.C.Charge.Extern;
  end;


  // Artikelsumme buchen
  Art.C.Charge.Intern # '';
  Art.C.Adressnr      # 0;
  Art.C.AnschriftNr   # 0;
  OpenCharge(y, Art.J.Datum);
//todo('duchschnitt für EK:'+cnvaf(aEKPReis));
  if (aEKPreis<>0.0) and (Art.C.Bestand + Art.J.Menge<>0.0) then begin
    vWert # (Art.C.EKDurchschnitt * (Art.C.Bestand / CnvFI(Art.PEH)));
    vWert # vWert + (aEKPreis * (Art.J.Menge / CnvFI(Art.PEH)))
    Art.C.EKDurchschnitt # vWert / (Art.C.Bestand + Art.J.Menge) * CnvFI(Art.PEH);
    Art.C.EKLetzter # aEKPreis;
    // Preise updaten
    Art_P_Data:SetzePreis('Ø-EK', Art.C.EKDurchschnitt, 0);
    Art_P_Data:SetzePreis('L-EK', Art.C.EKLetzter, aAdr, 0, '', Art.J.Datum);
  end;
  if (aVKPreis<>0.0) and (Art.C.Bestand + Art.J.Menge<>0.0) then begin
    vWert # (Art.C.VKDurchschnitt * (Art.C.Bestand / CnvFI(Art.PEH)));
    vWert # vWert + (aVKPreis * (Art.J.Menge / CnvFI(Art.PEH)))
    Art.C.VKDurchschnitt # vWert / (Art.C.Bestand + Art.J.Menge) * CnvFI(Art.PEH);
    Art.C.VKLetzter # aVKPreis;
  end;
  if (Wgr.OhneBestandYN=false) then begin
    vUnterdeckung     # (Art.J.Menge<0.0) and (Art.C.Bestand>=Art.Bestand.Min) and (Art.Bestand.Min > (Art.C.Bestand + Art.J.Menge));
    Art.C.Bestand     # Art.C.Bestand + Art.J.Menge;
    Art.C.Bestand.Stk # Art.C.Bestand.Stk + "Art.J.Stückzahl";
  end;

  Erx # WriteCharge(n);
  if (erx<>_rOk) then Error(253004,'');


  if (vUnterdeckung) then RunAFX('Art.Bewegung.UnterMin','');

  // Lagerjournal ggf. anlegen
  if (Art.LagerjournalYN) then begin
    Art.J.EKDurchschnitt  # Art.C.EKDurchschnitt;
    Art.J.Anlage.Datum    # Today;
    Art.J.Anlage.Zeit     # now;
    Art.J.Anlage.User     # gUserName;
    REPEAT
      Erx # RekInsert(253,0,'');
      if (Erx=_rDeadLock) then begin    // 2022-07-05 AH DEADLOCK
        if (vBuf252<>0) then RekRestore(vBuf252);
        Error(999999,thisline);
        RETURN false;
      end;
      if (Erx<>_rOK) then Art.J.lfdNr # Art.J.lfdNr + 1;
    UNTIL (Erx=_rOK);
  end;

  if (vBuf252<>0) then RekRestore(vBuf252);

  RETURN true;
end;


//========================================================================
// BerechneFelder
//
//========================================================================
sub BerechneFelder(var aStk : int; var aKg : float; var aMenge : float; aMEH : alpha) : logic;
local begin
  vB,vL : float;
end;
begin
  vB  # Art.Breite;
  vL  # "Art.Länge";

  // alles Null? dann fertig
  if (aStk=0) and (aKg=0.0) and (aMenge=0.0) then RETURN true;

  // einfache Umrechnungen
  if (aMenge=0.0) then begin
    if (aMEH='Stk') then  aMenge # cnvfi(aStk);
    if (aMEH='kg') then   aMenge # aKg;
    if (aMEH='t') then    aMenge # akg / 1000.0;
  end;
  if (aStk=0) then begin
    if (aMEH='Stk') then  aStk   # cnvif(aMenge);
  end;
  if (aKg=0.0) then begin
    if (aMEH='kg') then   aKg    # aMenge;
    if (aMEH='t') then    aKg    # aMenge * 1000.0;
  end;

  aKg # Rnd(aKg,2);
  aMenge # Rnd(aMenge,2);

  // alles geklärt? dann fertig!
  if (aStk<>0) and (aKg<>0.0) and (aMenge<>0.0) then RETURN true;


  // aus Stück berechnen
  if (aStk<>0) then begin
    if (aKg=0.0) and ("Art.GewichtProStk"<>0.0) then  aKg # "Art.GewichtProStk" * cnvfi(aStk);
    if (aMenge=0.0) then begin
      if (aMEH='m') then  aMenge # vL * cnvfi(aStk) / 1000.0;
      if (aMEH='qm') then aMenge # vL * vB * cnvfi(aStk) / 1000000.0;
    end;
  end;

  // aus Gewicht berechnen
  if (aKg<>0.0) then begin
    if (aStk=0) and ("Art.GewichtProStk"<>0.0) then begin
      aStk # cnvif(aKg / "Art.GewichtProStk");
      if (cnvfi(aStk) * "Art.GewichtProStk"<aKg) then aStk # aStk + 1;
    end;
    if (aMenge=0.0) then begin
      if (aMEH='m') and ("Art.GewichtProm"<>0.0) then aMenge # aKg / "Art.GewichtProm";
    end;
  end;

  // aus Länge berechnen
  if (aMenge<>0.0) and (aMEH='m') then begin
    if (aStk=0) and (vL<>0.0) then begin
      aStk # CnvIF(aMenge * 1000.0 / vL);
      if (cnvfi(aStk) * vL<aMenge*1000.0) then aStk # aStk + 1;
    end;
    if (aKg=0.0) and ("Art.GewichtProm"<>0.0) then    aKg  # aMenge * "Art.GewichtProm";
  end;
  if (aMenge<>0.0) and (aMEH='qm') then begin
    if (aStk=0) and (vL<>0.0) and (vB<>0.0) then begin
      aStk # CnvIF(aMenge * 1000000.0 / vL / vB);
      if (cnvfi(aStk)*vL*vB<aMenge * 1000000.0) then aStk # aStk + 1;
    end;
  end;



  // einfache Umrechnungen
  if (aMenge=0.0) then begin
    if (aMEH='Stk') then  aMenge # cnvfi(aStk);
    if (aMEH='kg') then   aMenge # aKg;
    if (aMEH='t') then    aMenge # akg / 1000.0;
  end;
  if (aStk=0) then begin
    if (aMEH='Stk') then  aStk   # cnvif(aMenge);
  end;
  if (aKg=0.0) then begin
    if (aMEH='kg') then   aKg    # aMenge;
    if (aMEH='t') then    aKg    # aMenge * 1000.0;
  end;

  aKg # Rnd(aKg,2);
  aMenge # Rnd(aMenge,2);

  if (aStk=0) or (aKg=0.0) or (aMenge=0.0) then RETURN false;

  RETURN true;
end;


//========================================================================
// SplitCharge
//
//========================================================================
sub SplitCharge(aProzent : float) : logic;
local begin
  Erx         : int;
  vNr         : int;
  vMenge      : float;
  vChargealt  : alpha;
  vChargeNeu  : alpha;
  vBuf252     : int;
  vBuf404     : int;
  vAktNr      : int;
end;
begin
  if (aProzent=0.0) then RETURN false;

  vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else RETURN false;

  vChargeNeu # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  vChargeAlt # Art.C.Charge.Intern;

  vBuf252 # RecBufCreate(252);    // neue Charge vorbelegen
  RecBufCopy(252,vBuf252);
  vBuf252->Art.C.Charge.Intern  # vChargeNeu;
  vBuf252->Art.C.Bestand        # Rnd(Art.C.Bestand / 100.0 * aProzent,2);
  vBuf252->Art.C.Reserviert     # Rnd(Art.C.Reserviert / 100.0 * aProzent,2);
  vBuf252->"Art.C.Verfügbar"    # Rnd("Art.C.verfügbar" / 100.0 * aProzent,2);
  vBuf252->Art.C.Kommissioniert # Rnd(Art.C.Kommissioniert / 100.0 * aProzent,2);

  RecRead(252,1,_recLock);        // alte Charge minimeren
  Art.C.Bestand         # Art.C.Bestand - (vBuf252->Art.C.Bestand);
  Art.C.Reserviert      # Art.C.Reserviert - (vBuf252->Art.C.Reserviert);
  Art.C.Kommissioniert  # Art.C.Kommissioniert - (vBuf252->Art.C.Kommissioniert);
  "Art.C.Verfügbar" # "Art.C.Verfügbar" - (vBuf252->"Art.C.Verfügbar");
  Erx # WriteCharge(n);
  if (erx<>_rOK) then begin
    RecBufDestroy(vBuf252);
    RETURN false;
  end;

  vBuf404 # RecBufCreate(404);

  Erx # RecLink(404,252,2,_RecFirst);   // Reservierungen splitten
  WHILE (Erx=_rOK) do begin

    if ((Auf.A.Aktionstyp=c_Akt_BA_Plan) or (Auf.A.Aktionstyp=c_Akt_PRD_Plan)) and
      ("Auf.A.Löschmarker"='') and (Auf.A.Charge=vChargeAlt) then begin

      RecBufCopy(404,vBuf404);
      vBuf404->Auf.A.Charge       # vChargeNeu;
      vBuf404->Auf.A.Menge        # Rnd(Auf.A.Menge / 100.0 * aProzent,2);
      vBuf404->"Auf.A.Stückzahl"  # CnvIF(CnvFI("Auf.A.Stückzahl") / 100.0 * aProzent);
      vBuf404->Auf.A.Gewicht      # Rnd(Auf.A.Gewicht / 100.0 * aProzent,2);
      vBuf404->Auf.A.Menge.Preis  # Rnd(Auf.A.Menge.Preis / 100.0 * aProzent,2);

      if (Auf_A_Data:Entfernen()=false) then begin  // bisherige Aktion löschen
        Erx # _rLocked;
        BREAK;
      end;

      // Aktion minimieren
      Auf.A.Menge       # Auf.A.Menge - (vBuf404->Auf.A.Menge);
      Auf.A.Menge.Preis # Auf.A.Menge.Preis - (vBuf404->Auf.A.Menge.Preis);
      "Auf.A.Stückzahl" # "Auf.A.Stückzahl" - (vBuf404->"Auf.A.Stückzahl");
      Auf.A.Gewicht     # Auf.A.Gewicht - (vBuf404->Auf.A.Gewicht);
      Auf.A.Charge      # vChargeAlt;
      if (Auf_A_Data:NeuAnlegen()<>_ROK) then begin // Aktion wieder anlegen
        Erx # _rLocked;
        BREAK;
      end;
      vAktNr # Auf.A.Aktion;

      RecBufCopy(vBuf404,404);
      if (Auf_A_Data:NeuAnlegen()<>_ROK) then begin // neue Aktion anlegen
        Erx # _rLocked;
        BREAK;
      end;

      Auf.A.Aktion # vAktNr;
      RecRead(404,1,0);
    end;

    Erx # RecLink(404,252,2,_RecNext);
  END;
  RecBufDestroy(vBuf404);
  if (Erx=_rLocked) then begin
    RecBufDestroy(vBuf252);
    RETURN false;
  end;


  RecBufCopy(vBuf252,252);
  Erx # WriteCharge(y);             // neue Charge anlegen
  if (erx<>_rOK) then begin
    RecBufDestroy(vBuf252);
    RETURN false;
  end;


  RecBufDestroy(vBuf252);
  RETURN true;

end;


//========================================================================
// RecalcAll
//  1. Alle Chargen löschen
//  2. offene Bestellungen einrechnen
//  3. offene Auftrage einrechnen
//
//========================================================================
sub ReCalcAll(
  opt aArtNr  : alpha;
  opt aSilent : logic;
  opt aMarked : logic);
local begin
  Erx       : int;
  vMenge    : float;
  vStk      : int;
  vOffen    : float;
  vResStk   : int;
  vResMenge : float;
  vResGew   : float;
  vOK       : logic;
  vProgress : handle;
  vCount    : int;
end;
begin

//aArtNr # 'COILS';
  // Alle Chargen nullen *****************************************************
  if (aArtNr='') then begin
    vProgress # Lib_Progress:Init('Chargen nullen', RecInfo(252, _recCount));
    Erx # RecRead(252,1,_RecFirst);
  end
  else begin
    vProgress # Lib_Progress:Init('Chargen nullen', RecLinkInfo(252, 250, 4, _recCount));
    RecBufClear(252);
    Art.C.Artikelnr # aArtNr;
    Erx # RecRead(252,1,0);
  end;

  // Chargen loopen...
  FOR Erx # RecRead(252,1,0)
  LOOP Erx # RecRead(252,1,_RecNext)
  WHILE (Erx<=_rLocked) and ((Art.C.Artikelnr=aArtNr) or (aArtNr='')) do begin

    if (!vProgress->Lib_Progress:Step()) then begin       // Progress
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecLink(250,252,1,_recFirst);     // Artikel holen
    if (aMarked) and (Lib_mark:IstMarkiert(250, RecInfo(250, _recID))=false) then CYCLE;    // 28.09.2020
GagaC;

    if (aArtNr<>'') then
      if (Art.C.Artikelnr<>aArtNr) then CYCLE;

    RecRead(252,1,_RecLock);
    Art.C.Bestellt.Stk    # 0;
    Art.C.Reserviert.Stk  # 0;
    Art.C.Kommission.Stk  # 0;
    Art.C.OffeneAuf.Stk   # 0;
    Art.C.Fremd.Stk       # 0;
    Art.C.Frei1.Stk       # 0;
    Art.C.Frei2.Stk       # 0;
    Art.C.Frei3.Stk       # 0;
    Art.C.Bestellt        # 0.0;
    Art.C.Reserviert      # 0.0;
    Art.C.Kommissioniert  # 0.0;
    Art.C.OffeneAuf       # 0.0;
    Art.C.Fremd           # 0.0;
    Art.C.Frei1           # 0.0;
    Art.C.Frei2           # 0.0;
    Art.C.Frei3           # 0.0;

   if (Wgr.Nummer<>Art.Warengruppe) then
      Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen

    if (Wgr.OhneBestandYN=false) then begin
      if (Art.C.Bestand=0.0) and (Art.C.Bestellt=0.0) and (Art.C.Reserviert=0.0) then begin
        if (Art.C.Ausgangsdatum=0.0.0) then Art.C.Ausgangsdatum # today;
      end
      else begin
  //      if (Art.C.Ausgangsdatum<>0.0.0) then Art.C.Ausgangsdatum # 0.0.0;
      end;
    end;
    Erx # WriteCharge(n, 'LAUF');
  END;

  vProgress -> Lib_Progress:Reset('Artikel', RecInfo(250, _recCount));


  
  // Artikel durchlaufen + evtl. MATERIAL ************************************************
  FOR Erx # RecRead(250,1,_RecFirst)
  LOOP Erx # RecRead(250,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (!vProgress->Lib_Progress:Step()) then begin       // Progress
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

gagaArt;

    if (aArtNr<>'') then
      if (Art.Nummer<>aArtNr) then CYCLE;

    if (aMarked) and (Lib_mark:IstMarkiert(250, RecInfo(250, _recID))=false) then CYCLE;    // 28.09.2020

    if (Wgr.Nummer<>Art.Warengruppe) then
      Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen

//    if ("Art.ChargenführungYN") then begin
      vMenge  # 0.0;
      vStk    # 0;

//if (Art.nummer='PRGSTD-ST') then begin
//debug(anum(art.c.bestand,2));
//end;

    RecalcSumCharge();
//    end;


    // Materialdatei als Chargen?
    if (Wgr_Data:IstMix()) then begin
      RecBufClear(252);
      Art.C.ArtikelNr     # Art.Nummer;
      OpenCharge(y);
      Art.C.Bestand         # 0.0;
      Art.C.Bestand.Stk     # 0;
      Art.C.Bestellt        # 0.0;
      Art.C.Bestellt.Stk    # 0;
      Art.C.Reserviert      # 0.0;
      Art.C.Reserviert.Stk  # 0;
      Art.C.Kommissioniert  # 0.0;
      Art.C.Kommission.Stk  # 0;
      Art.C.Fremd           # 0.0;
      Art.C.Fremd.Stk       # 0;
      Art.C.Frei1           # 0.0;
      Art.C.Frei1.Stk       # 0;
      Art.C.Frei2           # 0.0;
      Art.C.Frei2.Stk       # 0;
      Art.C.Frei3           # 0.0;
      Art.C.Frei3.Stk       # 0;
      Erx # WriteCharge(n);

      // Material loopen...
      FOR Erx # RecLink(200,250,8,_recFirst)
      LOOP Erx # RecLink(200,250,8,_recNext)
      WHILE (Erx<=_rLocked) do begin
        Mat_Data:_UpdateArtikel(y);
      END;
    end
    else begin
      // Reservierungen loopen
      Erx # RecLink(251,250,19,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        RekDelete(251,0,'AUTO');
        vOK # y;

        if ("Art.R.Trägertyp"=c_Akt_BAInput) then begin
          vOK # n;
          Erx # RecLink(701,251,5,_recFirst);   // BAG-Input holen
          if (Erx<=_rLocked) then begin
            Erx # RecLink(702,701,4,_recFirst); // BAG-NachPos holen
            if (Erx<=_rLocked) and ("BAG.P.Löschmarker"='') or (BAG.P.Typ.VSBYN=false) then begin
              vOK # y;
            end;
          end;
        end;

        // Auftrag??
        if ("Art.R.Trägertyp"=c_Auf) then begin
          vOK # n;
  //debug('suche '+aint(art.r.reservierungnr));
          if (Auf_A_Data:LiesAktion("Art.R.Trägernummer1", "Art.R.Trägernummer2", "Art.R.Trägernummer3", c_Akt_VSB, "Art.R.Trägernummer1", "Art.R.Trägernummer2", "Art.R.Trägernummer3")) then begin
            if (Auf.A.Menge<>0.0) or ("Auf.A.Stückzahl"<>0) then begin
              vOK # y;
              Art.R.Menge         # Auf.A.Menge;
              "Art.R.Stückzahl"   # "Auf.A.Stückzahl";
            end;
          end;
        end;

        if (vOK=false) then begin
          Erx # RecLink(251,250,19,0);
          Erx # RecLink(251,250,19,0);
          CYCLE;
        end;

        //  21.01.2022  DS  Kritische Zeile verkürzt (längste Zeile im Dokument machte Probleme bei git Import in C16)
        Reservierung(Art.R.Artikelnr,Art.R.Adressnr,Art.R.Anschrift,Art.R.Charge.Intern,Art.R.Zustand,"Art.R.Trägertyp","Art.R.TrägerNummer1","Art.R.TrägerNummer2","Art.R.Trägernummer3",Art.R.Menge,"Art.R.Stückzahl",Art.R.ReservierungNr);
        
        Erx # RecLink(251,250,19,_recNext);
      END;
    end;

  END;  // ARTIKEL ---


  // EINKAUF ***************************************************************
  // Bestellungen durchlaufen
  vProgress -> Lib_Progress:Reset('Bestellungen', RecInfo(501, _recCount));
  FOR Erx # RecRead(501,1,_RecFirst)
  LOOP Erx # RecRead(501,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (!vProgress->Lib_Progress:Step()) then begin       // Progress
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

gagaB;

    if (aArtNr<>'') then
      if (Ein.P.Artikelnr<>aArtNr) then CYCLE;

    if (Ein.P.Artikelnr='') then CYCLE;
    // 05.07.2017 AH
    if (Ein.P.Artikelnr<>Art.Nummer) then begin
      Erx # RecLink(250,501,2,_RecFirst); // Positionsartikel holen
      if (Erx>_rLocked) then CYCLE;
    end;

    if (aMarked) and (Lib_mark:IstMarkiert(250, RecInfo(250, _recID))=false) then CYCLE;    // 28.09.2020

    if (Wgr.Nummer<>Art.Warengruppe) then
        Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen    2022-08-25  AH
    if (Wgr_Data:IstMix()) then CYCLE;    // 06.10.2021 AH schon über Material passiert

    RekLink(500,501,3,_recFirst); // Kopf holen
    if (EIn.Vorgangstyp<>c_Bestellung) then CYCLE;

    if ("Ein.P.Löschmarker"='*') or (Ein.P.Nummer>1000000000) or
      ((Wgr_data:IstArt(Ein.P.Wgr.Dateinr)=false)) then CYCLE;

    RecRead(501,1,_RecLock);
    Ein.P.FM.Rest     # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.Ausfall;

//debugx('KEY501 '+anum(Ein.P.Menge,0)+' - '+anum(Ein.P.FM.Eingang,0)+' - '+anum(Ein.P.FM.Ausfall,0));
    Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
    Erx # Ein_Data:PosReplace(_recUnlock,'LAUF');

    vMenge # Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, Art.MEH);
//debugx('KEY250 = '+anum(vMenge,0)+Art.MEH);
    RecBufClear(252);
    Art.C.ArtikelNr     # Ein.P.ArtikelNr;
    Art.C.LieferantenNr # Ein.P.Lieferantennr;
    Art.C.Dicke         # Ein.P.Dicke;
    Art.C.Breite        # Ein.P.Breite;
    "Art.C.Länge"       # "Ein.P.Länge";
    Art.C.RID           # Ein.P.RID;
    Art.C.RAD           # Ein.P.RAD;
    Bestellung(vMenge);
  END;



  // VERKAUF ***************************************************************
  // Aufträge durchlaufen
  vProgress -> Lib_Progress:Reset('Aufträge', RecInfo(401, _recCount));
  FOR Erx # RecRead(401,1,_RecFirst)
  LOOP Erx # RecRead(401,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (!vProgress->Lib_Progress:Step()) then begin       // Progress
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

gagaAuf;

    if ("Auf.P.Löschmarker"='*') or (Auf.P.Nummer>1000000000) or
        ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr))) then CYCLE;

    if (Auf.P.Artikelnr='') then CYCLE;
    if (aArtNr<>'') then
      if (Auf.P.Artikelnr<>aArtNr) then CYCLE;

    if (Auf.P.Artikelnr<>Art.Nummer) then begin
      Erx # RecLink(250,401,2,_RecFirst); // Positionsartikel holen
      if (Erx>_rLocked) then CYCLE;
    end;
    
    if (aMarked) and (Lib_mark:IstMarkiert(250, RecInfo(250, _recID))=false) then CYCLE;    // 28.09.2020

    Erx # RecLink(400,401,3,_RecFirst); // Kopf holen
    if (Erx>_rLocked) or (Auf.Vorgangstyp<>c_AUF) then CYCLE;

    Erx # RecLink(835,401,5,_recFirst); // Auftragsart holen
    if (Erx>_rLocked) then CYCLE;

    // HOW : Reservierungen loopen...
    FOR Erx # RecLink(203,401,18,_recFirst)
    LOOP Erx # RecLink(203,401,18,_recNext)
    WHILE (Erx<=_rLocked) do begin

      Erx # RecLink(200,203,1,_recFirst);   // Material holen
      if (Erx>_rLocked) then CYCLE;
      if (Mat.Strukturnr='') then CYCLE;
      if (Mat.Strukturnr=Auf.P.Artikelnr) then CYCLE;
      // Meenge in Ziel-Art.MEH...
      if (Art.MEH='kg') then
        vMenge # Mat.R.Gewicht
      else if (Art.MEH='t') then
        vMenge # (Mat.R.Gewicht / 1000.0)
      else if (Art.MEH='Stk') then
        vMenge # cnvfi("Mat.R.Stückzahl")
      else if (Art.MEH=Mat.MEH) then
        vMenge # Mat.R.Menge
      else
        vMenge # Lib_Einheiten:WandleMEH(200, "Mat.R.Stückzahl", Mat.R.Gewicht, Mat.R.Menge, Mat.MEH, Art.MEH);

      RecBufClear(252);
      Art.C.ArtikelNr     # Art.Nummer;
      Art.C.Dicke         # Auf.P.Dicke;
      Art.C.Breite        # Auf.P.Breite;
      "Art.C.Länge"       # "Auf.P.Länge";
      Art.C.RID           # Auf.P.RID;
      Art.C.RAD           # Auf.P.RAD;
      MatFremdReserv(vMenge, true);
    END;



    // Position reservieren...
    if (AAr.ReservierePosYN) then begin
      RecRead(401,1,_RecLock);
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
      Erx # Auf_Data:PosReplace(_recUnlock,'LAUF');

      // offener Auftrag...
      RecBufClear(252);
      Art.C.ArtikelNr     # Auf.P.ArtikelNr;
      Art.C.Dicke         # Auf.P.Dicke;
      Art.C.Breite        # Auf.P.Breite;
      "Art.C.Länge"       # "Auf.P.Länge";
      Art.C.RID           # Auf.P.RID;
      Art.C.RAD           # Auf.P.RAD;
      vOffen # Auf.P.Menge - Auf.P.Prd.VSB - Auf.P.Prd.LFS;// - Auf.P.Prd.VSAuf;
      vOffen # vOffen - Auf.P.Prd.Plan; // 01.02.2018 AH Dispotest

      if (Set.Art.AufRst.Rsrv) then begin   // 07.02.2020
        vOffen # vOffen - Auf.P.Prd.Reserv;
        if (Auf.LiefervertragYN) or (vOffen>0.0) then Auftrag(vOffen, true);    // 2022-08-17 AH Rahmen drüfen das!
      end
      else begin
        if (vOffen>0.0) then Auftrag(vOffen, true);
      end;
    end;    // Position resrevieren


    // Stückliste reservieren...
    if (AAr.ReserviereSLYN) then begin

      // Auftrags Stücklisten loopen
      Erx # RecLink(409,401,15,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        RecBufClear(252);
        Art.C.ArtikelNr     # Auf.SL.ArtikelNr;
        Art.C.Dicke         # Auf.SL.Dicke;
        Art.C.Breite        # Auf.SL.Breite;
        "Art.C.Länge"       # "Auf.SL.Länge";
        Auftrag(Auf.SL.Menge - Auf.SL.Prd.Plan - Auf.SL.Prd.VSB - Auf.SL.Prd.LFS, true);//- Auf.SL.Prd.VSAuf) ;
        Erx # RecLink(409,401,15,_recNext);
      END;

    end;

  END;  // Positionen loopen


  vProgress->Lib_Progress:Term();

  if (aSilent = false) then
    Msg(999998,'',0,0,0);
end;


//========================================================================
//  Chargenquersumme
//
//========================================================================
sub ChargenPreisaenderung();
local begin
  Erx       : int;
  vArt.C.EKDurchschnitt,
  vArt.C.EKLetzter,
  vArt.C.VKDurchschnitt,
  vArt.C.VKLetzter : float;
end
begin

  if (Dlg_Standard:Menge('Ø Ein.-Preis', var vArt.C.EKDurchschnitt, Art.C.EKDurchschnitt))        AND
     (Dlg_Standard:Menge('letzter Ein.-Preis', var vArt.C.EKLetzter,  Art.C.EKLetzter))           AND
     (Dlg_Standard:Menge('Ø Aus.-Preis',       var vArt.C.VKDurchschnitt, Art.C.VKDurchschnitt))  AND
     (Dlg_Standard:Menge('letzter Aus.-Preis', var vArt.C.VKLetzter,      Art.C.VKLetzter))     then begin

    if ( RecRead(252,1,_RecLock) = _rOK) then begin
      Art.C.EKDurchschnitt  # vArt.C.EKDurchschnitt;
      Art.C.EKLetzter       # vArt.C.EKLetzter;
      Art.C.VKDurchschnitt  # vArt.C.VKDurchschnitt;
      Art.C.VKLetzter       # vArt.C.VKLetzter;
      Erx # RekReplace(252,_recUnlock,'AUTO');
    end;

  end;

end;


//========================================================================
//  InventurmengenErmittlung        // ST 2011-12-28 laut Projekt 1326/194
//
//========================================================================
sub InventurmengenErmittlung() : logic;
local begin
  Erx         : int;
  vErx        : int;
  vErxInv     : int;
  vProgress   : handle; // Handle für Fortschrittsbalken
  vMax        : int;

  vLetztesDatum   : date;
  vInvStk         : int;
  vInvMenge       : float;
end
begin

  vMax # RecInfo(250,_RecCount);

  vProgress # Lib_Progress:Init('Ermittle Inventurmengen', vMax);

  TRANSON;

  // Alle Artikel loopen
  FOR   vErx # RecRead(250,1,_RecFirst)
  LOOP  vErx # RecRead(250,1,_RecNext)
  WHILE (vErx = _rOK) DO BEGIN

    if (!vProgress->Lib_Progress:Step()) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      RETURN false;
    end;


    vInvStk       # 0;
    vInvMenge     # 0.0;
    vLetztesDatum # 0.0.0;

    // Inventurdaten loopen
    FOR    vErxInv # RecLink(259,250,21,_RecFirst)
    LOOP   vErxInv # RecLink(259,250,21,_RecNext)
    WHILE (vErxInv = _rOK) DO BEGIN

      vInvStk   # vInvStk +   "Art.Inv.Stückzahl";
      vInvMenge # vInvMenge + "Art.Inv.Menge";

      if ("Art.Inv.Anlage.Datum" > vLetztesDatum) or (vLetztesDatum = 0.0.0) then
        vLetztesDatum # "Art.Inv.Anlage.Datum";

    END;  // EO Inventurloop für diesen Artikel

    Erx # Recread(250,1,_RecLock);
    if (Erx <> _rOK) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      Msg(999999,Art.Nummer + ' konnte nicht gesperrt werden',0,0,0);
      RETURN false;
    end;

    Art.Bestand.Inventur  # vInvMenge;
//    Art.Inventurdatum     # vLetztesDatum;
    Erx # RekReplace(250,0,'AUTO');
    if (Erx <> _rOK) then begin
      vProgress->Lib_Progress:Term();
      TRANSBRK;
      Msg(999999,Art.Nummer + ' konnte nicht gesperrt werden',0,0,0);
      RETURN false;
    end;

  END; // EO Artikelloop

  TRANSOFF;

  vProgress->Lib_Progress:Term();

  return true;
end;


//========================================================================
//  Chargenquersumme
//
//========================================================================
/*
sub ChargenQuersumme();
local begin
  vBuf252 : handle;
end;
begin

//debug('quersumme:'+art.c.charge.intern+' '+aint(art.c.adressnr));
  vBuf252 # RecBufCreate(252);

  RecRead(252,1,_recLock);
  Art.C.Bestand     # 0.0;
  Art.C.Bestand.Stk # 0;

  // "Quersummen"-Chargen addieren...
  Erx # RecLink(vBuf252,250,4,_RecFirst);     // Chargen loopen
  WHILE (Erx<=_rLocked) do begin

    // eigenen Satz überspringen
    if (Art.C.Charge.Intern=vBuf252->Art.C.Charge.Intern) and
        (Art.C.Adressnr=vBuf252->Art.C.Adressnr) then begin
      Erx # RecLink(vBuf252,250,4,_RecNext);
      CYCLE;
    end;


    if (Art.C.Charge.Intern<>'') then begin
      if (Art.C.Charge.Intern<>vBuf252->Art.C.Charge.Intern) then begin
        Erx # RecLink(vBuf252,250,4,_RecNext);
        CYCLE;
      end
      end
    else if (Art.C.Adressnr<>0) then begin
        if (Art.C.Adressnr<>vBuf252->Art.C.Adressnr) then begin
          Erx # RecLink(vBuf252,250,4,_RecNext);
          CYCLE;
        end;
      end
    else if (vBuf252->Art.C.Adressnr=0) or (vBuf252->Art.C.Charge.Intern<>'') then begin
      Erx # RecLink(vBuf252,250,4,_RecNext);
      CYCLE;
    end;

//debug('add '+vBuf252->art.c.charge.intern+' '+aint(vBuf252->art.c.adressnr)+' '+anum(vBuf252->art.c.bestand,0));

    Art.C.Bestand     # Art.C.Bestand + vBuf252->Art.C.Bestand;
    Art.C.Bestand.Stk # Art.C.Bestand.Stk + vBuf252->Art.C.Bestand.Stk;

    Erx # RecLink(vBuf252,250,4,_RecNext);
  END;

  RekReplace(252,_recUnlock,'AUTO');

  RecBufDestroy(vBuf252);

end;
*/

//========================================================================
//========================================================================
sub RecalcSumCharge();
local begin
  Erx     : int;
  vOK     : logic;
  vMenge  : float;
  vStk    : int;
end;
begin
  // Chargen durchlaufen
  Erx # Reclink(252,250,4,_recFirst);
  WHILE (Erx<=_rlocked) do begin
    vOK # n;

    if (Art.C.Ausgangsdatum=0.0.0) then begin
      if ("Art.ChargenführungYN") then begin
        if (Art.C.Charge.intern<>'') and (Art.C.Adressnr<>0) then vOK # y;
      end
      else begin
        if (Art.C.Charge.intern<>'') and (Art.C.Adressnr<>0) then vOK # y;
      end;
    end;

    if (vOK) then begin
      vMenge  # vMenge + Art.C.Bestand;
      vStk    # vStk + Art.C.Bestand.Stk;
    end;
    Erx # RecLink(252,250,4,_recNext);
  END;
  RecBufClear(252);
  Art.C.ArtikelNr     # Art.Nummer;
  OpenCharge(y);
  Art.C.Bestand     # vMenge;
  Art.C.Bestand.Stk # vStk;
  Erx # WriteCharge(n);
end;


//========================================================================
//========================================================================
sub _ReadProto(
  aTxt        : int;
  aArt        : alpha;
  var aOffen  : float;
  var aFremd  : float;
  opt aDelete : logic) : int
local begin
  vA          : alpha;
  vI          : int;
end;
begin
  aArt # '|'+aArt+'|';
  vI # TextSearch(aTxt, 1, 1, 0, aArt);
  if (vI<>0) then begin
    if (aDelete) then
      vA # TextLineRead(aTxt, vI, _TextLinedelete)
    else
      vA # TextLineRead(aTxt, vI, 0);
    aOffen  # cnvfa(Str_Token(vA,'|',3));
    aFremd  # cnvfa(Str_Token(vA,'|',4));
    RETURN vI;
  end;
  aOffen # 0.0;
  aFremd  # 0.0;
  RETURN 0;
end;


//========================================================================
//========================================================================
sub _AddProto(
  aTxt    : int;
  aArt    : alpha;
  aOffen  : float;
  aFremd  : float;)
local begin
  vA      : alpha;
  vI      : int;
  vOffen  : float;
  vFremd  : float;
end;
begin
  vI # _readProto(aTxt, aArt, var vOffen, var vFremd, y);

  vA # '|' + aArt + '|' + anum(vOffen+aOffen,3) + '|' + anum(vFremd+aFremd,3)+'|';
  TextAddLine(aTxt, vA);
  RETURN;
end;


//========================================================================
sub _CopyDic(
  aKey  : alpha;
  aWas  : alpha;
  aTxt  : int);
local begin
  Erx : int;
end;
begin
  RecBufClear(935);
  aKey # aKey + '|' + aWas + '|';
  Dic.Key # aKey;
  Erx # recRead(935,1,0);
//debugx('suche '+aKey+' ergab '+Dic.Key+' mit '+aint(Erx));
  WHILE (erx<_rNoRec) and (Dic.Key=*aKey+'*') do begin
//debugx('!');
    TextAddLine(aTxt,'       '+Dic.Value);
    Erx # recRead(935,1,_recNext);
  END;
  
end;

//========================================================================
sub _ClearDic(
  aKey  : alpha;
  aWas  : alpha;
);
local begin
  Erx : int;
end;
begin
  RecBufClear(935);
  aKey # aKey + '|' + aWas + '|';
  Dic.Key # aKey;
  Erx # recRead(935,1,0);
  WHILE (erx<_rNoRec) and (Dic.Key=*aKey+'*') do begin
    RecDelete(935,0);
    Erx # recRead(935,1,0);
    Erx # recRead(935,1,0);
  END;
  
end;


//========================================================================
// StimmenSummen
//  (todo bestand)
//  (todo offene Bestellungen einrechnen)
//  3. offene Auftrage einrechnen
//
//  Call Art_Data:StimmenSummen
//========================================================================
sub StimmenSummen(opt aEMA : alpha) : alpha
local begin
  Erx       : int;
  vMenge    : float;
  vOffen    : float;
  vFremd    : float;
  vTxt      : int;
  vEmail    : int;
end;
begin

  vTxt # TextOpen(20);

  // VERKAUF ***************************************************************
  // Aufträge durchlaufen.......
  FOR Erx # RecRead(401,1,_RecFirst)
  LOOP Erx # RecRead(401,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Auf.P.Löschmarker"='*') or (Auf.P.Nummer>1000000000) or
        ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr))) then CYCLE;

    Erx # RecLink(400,401,3,_RecFirst); // Kopf holen
    if (Erx>_rLocked) or (Auf.Vorgangstyp<>c_AUF) then CYCLE;

    Erx # RecLink(835,401,5,_recFirst); // Auftragsart holen
    if (Erx>_rLocked) then CYCLE;

    if (Auf.P.Artikelnr<>Art.Nummer) then begin
      Erx # RecLink(250,401,2,_RecFirst); // Positionsartikel holen
      if (Erx>_rLocked) then CYCLE;
    end;

    // HOW : Reservierungen loopen...
    FOR Erx # RecLink(203,401,18,_recFirst)
    LOOP Erx # RecLink(203,401,18,_recNext)
    WHILE (Erx<=_rLocked) do begin

      Erx # RecLink(200,203,1,_recFirst);   // Material holen
      if (Erx>_rLocked) then CYCLE;
      if (Mat.Strukturnr='') then CYCLE;
      if (Mat.Strukturnr=Auf.P.Artikelnr) then CYCLE;
      // Menge in Ziel-Art.MEH...
      if (Art.MEH='kg') then
        vMenge # Mat.R.Gewicht
      else if (Art.MEH='t') then
        vMenge # (Mat.R.Gewicht / 1000.0)
      else if (Art.MEH='Stk') then
        vMenge # cnvfi("Mat.R.Stückzahl")
      else if (Art.MEH=Mat.MEH) then
        vMenge # Mat.R.Menge
      else
        vMenge # Lib_Einheiten:WandleMEH(200, "Mat.R.Stückzahl", Mat.R.Gewicht, Mat.R.Menge, Mat.MEH, Art.MEH);

      if (vMenge<>0.0) then
        _AddProto(vTxt, Art.Nummer, 0.0, vMenge);
    END;


   // Position reservieren...
    if (AAr.ReservierePosYN) then begin
//      RecRead(401,1,_RecLock);
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

      // offener Auftrag...
      vOffen # Auf.P.Menge - Auf.P.Prd.VSB - Auf.P.Prd.LFS;
      vOffen # vOffen - Auf.P.Prd.Plan;
      if (Set.Art.AufRst.Rsrv) then begin
        vOffen # vOffen - Auf.P.Prd.Reserv;
      end;
//      if (vOffen>0.0) then begin
//        _AddProto(vTxt, Art.Nummer,vOffen, 0.0);
      if (Auf.LiefervertragYN) or (vOffen>0.0) then   // 2022-08-17 AH Rahmen drüfen das!
        _AddProto(vTxt, Art.Nummer,vOffen, 0.0);
    end;    // Position reservieren

    // Stückliste reservieren...
    if (AAr.ReserviereSLYN) then begin
      // Auftrags Stücklisten loopen
      FOR Erx # RecLink(409,401,15,_recFirst)
      LOOP Erx # RecLink(409,401,15,_recNext)
      WHILE (Erx<=_rLocked) do begin
        vOffen # Auf.SL.Menge - Auf.SL.Prd.Plan - Auf.SL.Prd.VSB - Auf.SL.Prd.LFS;
        if (vOffen>0.0) then begin
          _AddProto(vTxt, Art.Nummer,vOffen, 0.0);
        end;
      END;
    end;  // SL-Reserv.

  END; // alle 401
  
  
  // ARTIKEL loopen -------------------------
  FOR Erx # RecRead(250,1,_recFirst)
  LOOP Erx # RecRead(250,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    _ReadProto(vTxt, Art.Nummer, var vOffen, var vFremd);
    RecBufClear(252);
    Art.C.ArtikelNr   # Art.Nummer;
    Art_Data:ReadCharge();
//if (random()<0.2) then begin
//  vOffen # vOffen + 1.0;
//  vFremd # vFremd + 1.0;
//end;
    if (vOffen<>Art.C.OffeneAuf) then begin
      if (vEmail=0) then vEmail # Textopen(20);
      TextAddLine(vEmail,'Differenz bei '+Art.Nummer + ' : AuftragSoll '+anum(vOffen,3)+' <> AuftragIst '+anum(Art.C.OffeneAuf,3));
      _CopyDic(Art.Nummer, 'OffeneAuf', vEmail);
    end;
    if (vFremd<>Art.C.Fremd) then begin
      if (vEmail=0) then vEmail # Textopen(20);
      TextAddLine(vEMail,'Differenz bei '+Art.nummer + ' : FremdSoll '+anum(vFremd,3)+' <> FremdIst '+anum(Art.C.Fremd,3));
      _CopyDic(Art.Nummer, 'FremdAuf', vEmail);
    end;
    
    _ClearDic(Art.Nummer, 'OffeneAuf');
    _ClearDic(Art.Nummer, 'FremdAuf');
  END;
//textwrite(vemail, 'd:\debug\debug.txt', _textExtern);
TextClose(vTxt);

  if (vEMail<>0) then begin
    //Erx # Dlg_EMail:SmtpMail(vEmail, 0, 'ah@stahl-control.de', 'AutoMail: Artikelmengendifferenz', 0);
    if (aEMA<>'') then begin
      Erx # Dlg_EMail:SmtpMail(vEmail, 0, aEMA, 'AutoMail: Artikelmengendifferenz', 0);
      if (Erx<0) then debugx('Error SmptMail:'+aint(Erx));
    end;
    textwrite(vemail, 'd:\debug\debug.txt', _textExtern);
    TextClose(vEmail);
  end;
  
end;

//========================================================================